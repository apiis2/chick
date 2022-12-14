#####################################################################
# load object: LO_DS06
# $Id: LO_DS06.pm,v 1.46 2022/06/07 14:42:59 lfgroene Exp $
#####################################################################
# This is the Load Object to store number of eggs to an cage.
#
#--  test-data
#
# Conditions:
# 1. The load object is one transevent: either it succeeds or
#    everything is rolled back.
# 2. The Load_object is aborted on the FIRST error.
#####################################################################
use chick;
use Spreadsheet::Read;
use Encode;
use chick;

sub KeyMaxValueHash {
    my $hs=shift;

    my $max=0;
    my $vkey=0;

    foreach my $key (keys %$hs) {
        if ($hs->{$key}>$max) {
            $max=$hs->{$key};
            $vkey=$key;
        }
    }

    return $vkey;
}

sub LO_DS06 {
    my $self     = shift;
    my $args     = shift;
    
#TEST-DATA    
#    $args = {
#        ext_cage  => '255'  ,
#        db_animal => '4',
#    };

    use JSON;
    use URI::Escape;
    use GetDbEvent;
    use GetDbUnit;

    use strict;
    use warnings;

    my $json;
    my $err_ref;
    my $err_status;
    my @record;
    my $extevent;
    my @in;
    my %breeds;
    my $hs_dscheck;

    my @field;
    my $hs_fields={};
    my $hs_check={};
    my $fileimport;
    if (exists $args->{ 'FILE' }) {
        $fileimport=$args->{ 'FILE' };
    }
    my $onlycheck='off';
    if (exists $args->{ 'onlycheck' }) {
        $onlycheck=lc($args->{ 'onlycheck' });
    }
    my $action='insert';
    if (exists $args->{ 'action' }) {
        $action=lc($args->{ 'action' });
    }

    $json = { 'Info'        => [],
              'RecordSet'   => [],
              'Bak'         => [],
            };

    ($json, $hs_check)=chick::CheckStatusDS($apiis,$json,'','DS06');

    if (exists $json->{'Critical'} and ($json->{'Critical'})) {
   
        if ($onlycheck eq 'off') {
            $json->{'Critical'}=[[main::__('DS10 always finished.')]];
        }
        return $json;
    }

    #-- Wenn ein File geladen werden soll, dann zuerst umwandeln in
    #   einen JSON-String, damit einheitlich weiterverarbeitet werden kann
    if ( $fileimport ) {

        #-- Datei öffnen
        open( IN, "$fileimport" ) || die "error: kann $fileimport nicht öffnen";

        #-- if csv file
        if ($fileimport=~/\.csv_.*$/) {
            @in=<IN>;
        }
        
        #-- if xlsx-file
        else {

            #-- Excel-Tabelle öffnen 
            my $book = Spreadsheet::Read->new ("$fileimport", dtfmt => "dd.mm.yyyy");
            my $sheet = $book->sheet (1);

            #-- Fehlermeldung, wenn es nicht geht 
            if(defined $book->[0]{'error'}){
                print "Error occurred while processing $fileimport:".
                    $book->[0]{'error'}."\n";
                exit(-1);
            }
            
            my $max_rows = $sheet->{'maxrow'};
            my $max_cols = $sheet->{'maxcol'};

            #--Schleife über alle Zeilen 
            for my $row_num (1..($max_rows))  {

                #-- declare
                my $col='A';
                my @data=();

                #-- Schleife über alle Spalten       
                for my $col_num (1..($max_cols)){

                    #-- einen ";" String erzeugen  
                    push(@data, encode_utf8 $sheet->{$col.$row_num});
            
                    $col++;
                }
                
                #-- initialisieren mit '' 
                map { if (!$_) {$_=''} } @data;

                #-- Daten sichern  
                push(@in,join(';',@data));
            }
        }

        my $rec=0;

        #-- Schleife über alle Datensätze
        foreach (@in) {

            $rec++;
             
            push( @{ $json->{ 'Bak' } },$_); 
            
            #-- Zeilenumbruch entfernen
            chomp();

            $_ =~ s/\r|\n//g;

            #-- declare
            my @data;
            my $record;
            my $hs = {};

            #-- skip first record 
            next if ($rec<2);

            @data = split(';', $_ ,6);

            #-- remove leading zeros or spaces and comma to dot
            map { $_ =~ s/^[0\s]+//g; $_ =~ s/\s+$//g;  $_=~s/,/./g; $_='' if (!$_) } @data;

            #-- Check auf gültigen Ladestrom Spalte 2 Geschlecht=1 oder 1 und Rasse muss Buchstaben enthalten 
            if (($data[4]!~/^[^0-9].*/) or ($data[2]!~/^(1|2)$/)) {
                print __('Wrong dataset format for LO_DS65. Column 3 has to be sex as 1 or 2 and column 5 is defined as breed with a character at the first place');
                print '<p><p>'.join(' ; ', @data);
                return;
            }
            
            #-- define format for record 
            $record = {
                    'ext_breed'         => [ $data[4],'',[] ],
                    
                    'ext_unit_animal'   => [ 'wing_id_system','',[] ],
                    'ext_animal'        => [ $data[0],'',[] ],
                    
                    'ext_sex'           => [ $data[2],'',[] ],
                    'far'               => [ $data[3],'',[] ],
                    'ext_cage'          => [ $data[1],'',[] ],
            };

            #-- collect breeds 
            $breeds{$data[4] }=1;

            #-- Datensatz mit neuem Zeiger wegschreiben
            push( @{ $json->{ 'RecordSet' } },{ 'Info' => [], 'Data' => { %{$record} },'Insert'=>[], 'Tables'=>['animal']} );
        }

        #-- Datei schließen
        close( IN );
        
        #-- file
        $hs_fields->{'ahb'}     ={'cagenumber'=>'cage', 'ext_sex'=>'sex','ext_animal'=>'wingnumber', 'ext_breed'=>'ext_breed'};

        $json->{ 'Fields'}  = [ 'ext_breed', 'ext_animal','ext_sex','far','ext_cage' ];
    }
    else {

        #-- String in einen Hash umwandeln
        if (exists $args->{ 'JSON' }) {
            $json = from_json( $args->{ 'JSON' } );
        }
        else {
            $json={ 'RecordSet' => [{Info=>[],'Data'=>{}}]};
            map { $json->{ 'RecordSet'}->[0]->{ 'Data' }->{$_}=[];
                  $json->{ 'RecordSet'}->[0]->{ 'Data' }->{$_}[0]=$args->{$_}} keys %$args;
        }
    }

    #-- Check, that all cages are closed
    my $sql="select count(*) from entry_unit where ext_unit='cage'";;
    
    #-- SQL auslösen 
    my $sql_ref = $apiis->DataBase->sys_sql( $sql );
    
    my $vcount;
    while ( my $q = $sql_ref->handle->fetch ) {
        $vcount= $q->[0]; 

        if ($vcount > 0) {
            print main::__("There are still [_1] open cages", $vcount).'<p>';
            print main::__("Please start at first DS10 and close all to terminate generation.");
            exit;
        }
    }


    #-- aktuelles Jahr holen
    $sql="select distinct date_part('year',birth_dt),date_part('year',birth_dt)+1 ,birth_dt from animal where birth_dt notnull order by birth_dt desc limit 1;";
    
    #-- SQL auslösen 
    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    
    my $vext_id_animal;
    my $birthyear;
    my $year;

    while ( my $q = $sql_ref->handle->fetch ) {
        $vext_id_animal = 'Hvam'.$q->[0]; 
        $birthyear      = $q->[0]; 
        $year           = $q->[1]; 
    }

    #-- aktuelle Abstammungen holen
    $sql="select ext_animal, user_get_ext_animal(db_sire), user_get_ext_animal(db_dam),a.guid, user_get_ext_code(db_breed,'s'),a.db_animal, user_get_ext_code(db_sex,'e') from animal a inner join transfer b on a.db_animal=b.db_animal where (birth_dt isnull or date_part('year',birth_dt)='$birthyear')";
    
    #-- SQL auslösen 
    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    
    my $hs_pedigree;
    while ( my $q = $sql_ref->handle->fetch ) {
        $hs_pedigree->{$q->[0]}={'s'=>$q->[1], 'd'=>$q->[2], 'guid'=>$q->[3], 'breed'=>$q->[4], 'db_animal'=>$q->[5], 'sex'=>$q->[6]}; 
    }

    #-- alle Tiere ohne Käfige holen
    $sql="set datestyle to 'german'; select user_get_ext_animal(db_animal), user_get_ext_code(db_breed,'s') as ext_breed, user_get_ext_id_animal(db_animal),user_get_ext_id_animal(db_sire), user_get_ext_id_animal(db_dam),user_get_ext_code(db_sex,'e'),birth_dt from animal where db_cage isnull and exit_dt isnull";
    
    #-- SQL auslösen 
    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    
    my %hs_cage_null;
    while ( my $q = $sql_ref->handle->fetch ) {
        $hs_cage_null{$q->[1]}={} if (!exists $hs_cage_null{$q->[1]});    
        $hs_cage_null{$q->[1]}->{$q->[0]}=[@$q]; 
    }

    #-- Check cages 
    my %hs_cage; 
   
    #-- check, ob Reihenfolge der fars richtig ist. 
    my $vcage;
    
    #-- erste Runde durch den Datensatz 
    foreach my $hs_record ( @{ $json->{ 'RecordSet' } } ) {
        
        my $args;

        #-- Daten aus Hash holen
        foreach (keys %{ $hs_record->{ 'Data' } }) {
            $args->{$_}=$hs_record->{ 'Data' }->{$_}->[0];
        }
        
        my $breed     = $args->{'ext_breed'};
        my $far       = $args->{'far'};
        my $cage      = $args->{'ext_cage'};
        my $grandsire = $hs_pedigree->{ $args->{'ext_animal'} }->{'s'};
        my $sex       = 'dam';

#        if ($breed) {
#            #-- Check auf korrekten Ladestrom
#            if (!$hs_dscheck->{$breed}->[1] and !$hs_dscheck->{$breed}->[2] and !$hs_dscheck->{$breed}->[3]) {
#                my $at=1;
#            }
#            else {
#                $json->{'Before'}.=main::__("Wrong datastream for breed: [_1]", $breed);    
#                return $json;
#            }
#        }
#        else {
#            #-- Schleife über alle Rassen 
#            foreach my $breed (keys %$hs_dscheck) {
#            
#                #-- Check auf korrekten Ladestrom
#                if (!$hs_dscheck->{$breed}->[1] and !$hs_dscheck->{$breed}->[2] and !$hs_dscheck->{$breed}->[3]) {
#                    my $at=1;
#                }
#                else {
#                    $json->{'Before'}.=main::__("Wrong datastream for breed: [_1]", $breed);    
#                    return $json;
#                }
#            }
#        }
                
        $grandsire='' if (!$grandsire);

        #-- Tier ist männlich
        if ($args->{'ext_sex'} eq '1') {
            $sex='sire';
        }

        #-- INIT 
        if (!exists $hs_check->{$breed}->{'fars'}->{$far}) {
            $hs_check->{$breed}->{'fars'}->{$far}={};
        }
        if (!exists $hs_check->{$breed}->{'cages'}->{$cage}) {
            $hs_check->{$breed}->{'cages'}->{$cage}={};
        }

        #-- fars
        if (!exists $hs_check->{$breed}->{'fars'}->{$far}->{$sex.'_cages'}->{$cage}) {
            $hs_check->{$breed}->{'fars'}->{$far}->{$sex.'_cages'}->{$cage}=1; 
        }
        else {
            $hs_check->{$breed}->{'fars'}->{$far}->{$sex.'_cages'}->{$cage}++; 
        }
        
        if (!exists $hs_check->{$breed}->{'fars'}->{$far}->{$sex.'_sire'}->{$grandsire}) {
            $hs_check->{$breed}->{'fars'}->{$far}->{$sex.'_sire'}->{$grandsire}=1; 
        }
        else {
            $hs_check->{$breed}->{'fars'}->{$far}->{$sex.'_sire'}->{$grandsire}++; 
        }
       
        #--- cages 
        if (!exists $hs_check->{$breed}->{'cages'}->{$cage}->{$sex.'_far'}->{$far}) {
            $hs_check->{$breed}->{'cages'}->{$cage}->{$sex.'_far'}->{$far}=1; 
        }
        else {
            $hs_check->{$breed}->{'cages'}->{$cage}->{$sex.'_far'}->{$far}++; 
        }
        
        if (!exists $hs_check->{$breed}->{'cages'}->{$cage}->{$sex.'_sire'}->{$grandsire}) {
            $hs_check->{$breed}->{'cages'}->{$cage}->{$sex.'_sire'}->{$grandsire}=1; 
        }
        else {
            $hs_check->{$breed}->{'cages'}->{$cage}->{$sex.'_sire'}->{$grandsire}++; 
        }

        if (!exists $hs_check->{$breed}->{'cages'}->{$cage}->{$sex.'_animals'}->{$args->{'ext_animal'}}) {
            $hs_check->{$breed}->{'cages'}->{$cage}->{$sex.'_animals'}->{$args->{'ext_animal'}}=1; 
        }
        else {
            $hs_check->{$breed}->{'cages'}->{$cage}->{$sex.'_animals'}->{$args->{'ext_animal'}}++; 
        }
    }

    #-- Berechnung des Rotationsschemas
    #-- Schleife über alle Rassen 
    foreach my $breed (sort keys %{ $hs_check }) {
   
        #-- Initialisieren - Distanzen der Far-Nummern muss über die Käfige immer gleich sein 
        #-- innerhalb der Gruppe 'd>s' oder 'd<s' 
        $hs_check->{$breed}->{'d<s'}={};
        $hs_check->{$breed}->{'d>s'}={};

        #-- Schleife über alle Käfige 
        foreach my $cage (keys %{ $hs_check->{$breed}->{'cages'} }) {

            my $mfd= KeyMaxValueHash( $hs_check->{$breed}->{'cages'}->{$cage}->{'dam_far'} ); 
            my $mfs= KeyMaxValueHash( $hs_check->{$breed}->{'cages'}->{$cage}->{'sire_far'} ); 
           
            if ($mfd<$mfs) {

                my $dd=$mfs-$mfd;

                #-- Zählen, wie oft das vorkommt 
                if (!exists $hs_check->{$breed}->{'d<s'}->{$dd}) {
                    $hs_check->{$breed}->{'d<s'}->{$dd}=1;
                }
                else {
                    $hs_check->{$breed}->{'d<s'}->{$dd}++;
                }
            }
            else {
                my $dd=$mfd-$mfs;

                #-- Zählen, wie oft das vorkommt 
                if (!exists $hs_check->{$breed}->{'d>s'}->{$dd}) {
                    $hs_check->{$breed}->{'d>s'}->{$dd}=1;
                }
                else {
                    $hs_check->{$breed}->{'d>s'}->{$dd}++;
                }
            }
        }
       
        #-- Rotationsschema ermitteln, dazu die fars entsprechend der Nummer in ein Array schreiben

        #-- wenn es Rasse noch nicht gibt, dann far nummernarray für Vater und Mutter initialisieren
        if (!exists $hs_check->{$breed}) {
            $hs_check->{$breed}->{'far_cage'}=[];
            $hs_check->{$breed}->{'far_sire'}=[];
            $hs_check->{$breed}->{'far_dam'} =[];
        }

        #-- Schleife über alle Käfige 
        foreach my $cage (keys %{ $hs_check->{$breed}->{'cages'} }) {
           
            #-- sortierte liste ausgeben
            #-- wenn mehrere keys, dann wird der mit der höchsten Anzahl genutzt 
            my $pos=KeyMaxValueHash( $hs_check->{$breed}->{'cages'}->{$cage}->{'dam_far'} );

            my @b= sort {      $b     <=>      $a     } keys %{$hs_check->{$breed}->{'cages'}->{$cage}->{'sire_far'}};
            my @a= sort {      $b     <=>      $a     } keys %{$hs_check->{$breed}->{'cages'}->{$cage}->{'dam_far'}};

            #-- initialisieren 
            if (!exists $hs_check->{$breed}->{'far_cage'}->[$pos]) {
                $hs_check->{$breed}->{'far_cage'}->[$pos]=[];
            }

            push(@{$hs_check->{$breed}->{'far_cage'}->[$pos]},$cage);

            $hs_check->{$breed}->{'far_sire'}->[$pos] =join(', ',@b);
            $hs_check->{$breed}->{'far_dam' }->[$pos] =join(', ',@a);
        }

        $json->{'Before'}.='<h4>Rotationscheme '.$breed.'</h4>';  
        
        my $row1='<td>Cage</td>';
        my $row2='<td>Far sire</td>';
        my $row3='<td>Far dam</td>';
        my %errors;

        my $dks= KeyMaxValueHash($hs_check->{$breed}->{'d<s'});
        my $dgs= KeyMaxValueHash($hs_check->{$breed}->{'d>s'});

        
        #-- Schleife über alle weibliche Linien
        for (my $i=1;$i<=$#{$hs_check->{$breed}->{'far_dam'}};$i++) {
      
            if ($hs_check->{$breed}->{'far_dam'}->[$i]) {
            
            #-- Schleife über alle Käfige der weiblichen Linie 
            foreach my $cage (sort {$a<=>$b} @{ $hs_check->{$breed}->{'far_cage'}->[$i] }) {

                my $color='';
                my $colord='';
                
                #-- welcher Vaterlinie ist drin? 
#                my $far =$hs_check->{$breed}->{'far_sire'}->[$i];

#                if (!$hs_check->{$breed}->{'far_dam'}->[$i]) {
#                    $errors{main::__('Missing line')}=[''];
#                    $colord='red';
#                }
#                else {

#                    if (!$hs_check->{$breed}->{'far_sire'}->[$i]) {

                my @sfar=keys %{$hs_check->{$breed}->{'cages'}->{$cage}->{'sire_far'}};
        
                #-- check auf kein Hahn im Käfig
                if (keys %{$hs_check->{$breed}->{'cages'}->{$cage}->{'sire_far'}}==0) {
                
                    $color='red';
                        
                    if (!exists $errors{main::__('No rooster in cage')}) {
                        $errors{main::__('No rooster in cage')}=[$cage];
                    }
                    else {
                        push(@{ $errors{main::__('No rooster in cage')} },$cage);
                    }
                }
#                    }

                #-- check auf zu viele Hähne im Käfig
                if (keys %{$hs_check->{$breed}->{'cages'}->{$cage}->{'sire_far'}}>1) {
                
                    $color='red';
                    
                    if (!exists $errors{main::__('To many rooster-lines in cage')}) {
                        $errors{main::__('To many rooster-lines in cage')}=[$cage];
                    }
                    else {
                        push(@{ $errors{main::__('To many rooster-lines in cage')} },$cage);
                    }
                }
                    
                my $diff=-1;

                $color ='red' if (!$hs_check->{$breed}->{'far_sire'}->[$i]);
                $colord='red' if (!$hs_check->{$breed}->{'far_dam'}->[$i]);

                if ((keys %{$hs_check->{$breed}->{'cages'}->{$cage}->{'sire_animals'}}==0) 
                         or
                    (keys %{$hs_check->{$breed}->{'cages'}->{$cage}->{'sire_animals'}}>1)) {
                    $diff=-1;
                }
                else {
                    if ($hs_check->{$breed}->{'far_sire'}->[$i]) {
                        $diff=$i-$sfar[0]; #$hs_check->{$breed}->{'far_sire'}->[$i];
                    }
                }

                if ( $diff<0) {
                    if (abs($diff) ne $dks) {
                        $color='red';
                    }
                }
                else {
                    if ($diff ne $dgs) {
                        $color='red';
                    }
                }
                    
                #-- Großvater des Vaters muss gleich Großvater der Mutterlinie sein.  
                #-- wenn möglicher Fehler im Rotationsschema 
                if ($color eq 'red') {
            
                    my $sire_sire= KeyMaxValueHash( $hs_check->{$breed}->{'cages'}->{$cage}->{'sire_sire'} );

                    #--- das gleiche auf der Mutterseite
                    my $dam_sire= KeyMaxValueHash( $hs_check->{$breed}->{'cages'}->{$cage}->{'dam_sire'} );

                    if ($sire_sire ne $dam_sire) {
                        if (!exists $errors{main::__('Possible error in rotationscheme in cage')}) {
                            $errors{main::__('Possible error in rotationscheme in cage')}=[$cage];
                        }
                        else {
                            push(@{$errors{main::__('Possible error in rotationscheme in cage')}},$cage);
                        }
                        $color='orange';
                    }
                }

                #-- check auf kein Hahn im Käfig
                if (keys %{$hs_check->{$breed}->{'cages'}->{$cage}->{'dam_animals'}}<2) {
                    
                    $colord='red';
                    
                    if (!exists $errors{main::__('To less hens in cage')}) {
                        $errors{main::__('To less hens in cage')}=[$cage];
                    }
                    else {
                        push(@{ $errors{main::__('To less hens in cage')} },$cage);
                    }
                }

                #-- check auf zu viele Hähne im Käfig
                if (keys %{$hs_check->{$breed}->{'cages'}->{$cage}->{'dam_far'}}>1) {
                    
                    $colord='red';
                    
                    if (!exists $errors{main::__('To many hen-lines in cage')}) {
                        $errors{main::__('To many hen-lines in cage')}=[$cage];
                    }
                    else {
                        push(@{ $errors{main::__('To many hen-lines in cage')} },$cage);
                    }

                }
#                }

                #-- initialisieren
                my $sfar=join(', ',keys %{$hs_check->{$breed}->{'cages'}->{$cage}->{'sire_far'}});
                my $dfar=join(', ',keys %{$hs_check->{$breed}->{'cages'}->{$cage}->{'dam_far'}});

                $sfar='-' if (!$sfar);
                $dfar='-' if (!$dfar);

                $row1.='<td>'.$cage.'</td>';
                
                if ($color eq '' ) {
                    $row2.='<td>'.$sfar.'</td>';
                } else {    
                    $row2.='<td style="background-color:'.$color.'">'.$sfar.'</td>';
                }

                if ($colord eq '' ) {
                    $row3.='<td>'.$dfar.'</td>';
                } else {
                    $row3.='<td style="background-color:'.$colord.'">'.$dfar.'</td>';
                }
            }
        } else {    
                my $color='';
                my $colord='red';
                
                $row1.='<td>-</td>';
                $row2.='<td style="background-color:'.$colord.'">-</td>';
                $row3.='<td>'.$i.'</td>';
            }
        }

        foreach my $cage (keys %{$hs_check->{ $breed }->{'cages'}} ) {
            #-- check auf keine Hennen im Käfig
            if (!exists $hs_check->{ $breed }->{'cages'}->{$cage}->{'dam_animals'}) {
                
                if (!exists $errors{main::__('No hens in cage')}) {
                    $errors{main::__('No hens in cage')}=[$cage];
                }
                else {
                    push(@{ $errors{main::__('No hens in cage')}},$cage);
                }
            }
        }

        $json->{'Before'}.='<table border="1"><TR>'.$row1.'</TR><TR>'.$row2.'</TR><TR>'.$row3.'</TR></table><p>';
        $json->{'Before'}.='<ul>';
        foreach my $key (sort keys %errors) {
            $json->{'Before'}.='<li>'.join('</li><li>',$key.': '.join(', ',@{ $errors{$key} }) ).'</li>';
        }
        $json->{'Before'}.='</ul>';
    }
  
    foreach my $hs_record ( @{ $json->{ 'RecordSet' } } ) {

        my $args;

        #-- Daten aus Hash holen
        foreach (keys %{ $hs_record->{ 'Data' } }) {
            $args->{$_}=$hs_record->{ 'Data' }->{$_}->[0];
        }
    
        $hs_cage{ $args->{'ext_cage'}}={'cnt'=>0, 'm'=>[],'w'=>[],'b'=>{},'ss'=>{},'sd'=>{},'ds'=>{},'dd'=>{}} if (!exists $hs_cage{ $args->{'ext_cage'}}) ;

#        next if (!exists $hs_pedigree->{$args->{'ext_animal'}});
        
        if ( $args->{'ext_sex'} eq '1') { 
            
            push( @{ $hs_cage{ $args->{'ext_cage'}}->{'m'} }, $args->{'ext_animal'} ); 
           
            #-- es muss was im Hash stehen  
            if (keys %{$hs_cage{ $args->{'ext_cage'}}->{'ss'}}>0) {
                $hs_cage{ $args->{'ext_cage'}}->{'ss'}->{ $hs_pedigree->{$args->{'ext_animal'}}->{'s'}}=1; 
            }
            if (keys %{$hs_cage{ $args->{'ext_cage'}}->{'sd'}}>0) {
                $hs_cage{ $args->{'ext_cage'}}->{'sd'}->{ $hs_pedigree->{$args->{'ext_animal'}}->{'d'}}=1; 
            }
        }
        else {
            push( @{ $hs_cage{ $args->{'ext_cage'}}->{'w'} }, $args->{'ext_animal'} );
        
            if (keys %{$hs_cage{ $args->{'ext_cage'}}->{'ds'}}>0) { 
                $hs_cage{ $args->{'ext_cage'}}->{'ds'}->{ $hs_pedigree->{$args->{'ext_animal'}}->{'s'}}=1; 
            }
            if (keys %{$hs_cage{ $args->{'ext_cage'}}->{'dd'}}>0) {
                $hs_cage{ $args->{'ext_cage'}}->{'dd'}->{ $hs_pedigree->{$args->{'ext_animal'}}->{'d'}}=1; 
            }
        }

        $hs_cage{ $args->{'ext_cage'}}->{'b'}->{$args->{'ext_breed'}}=1; 
    }


    #-- Ab hier ist es egal, ob die Daten aus einer Datei
    #   oder aus einer Maske kommen
    #-- Schleife über alle Records und INFO füllen
    foreach my $hs_record ( @{ $json->{ 'RecordSet' } } ) {

        my $args;

        #-- Daten aus Hash holen
        foreach (keys %{ $hs_record->{ 'Data' } }) {
            $args->{$_}=$hs_record->{ 'Data' }->{$_}->[0];
        }

#-- debug
        if ($args->{'ext_breed'} eq 'ISL' ) { 

           my $a=1;    
        }

        my $cnt++;

        #-- several checks to cage
        #-- no rooster
        if ( !$hs_pedigree->{$args->{'ext_animal'}}->{'breed'}) {
            push(@{$hs_record->{ 'Info'}},main::__('Animal [_1] number not exists in database. ',$args->{'ext_animal'}));
            next;
        }
        else { 
            if ( $hs_pedigree->{ $args->{'ext_animal'}}->{'s'}=~/unknown/) {
                push(@{$hs_record->{ 'Warn'}},main::__("Animal [_1] has no parents. ", $args->{'ext_animal'}));
            }
            else {
                if ( $hs_pedigree->{ $args->{'ext_animal'} }->{'breed'} ne $args->{'ext_breed'}) {
                    push(@{$hs_record->{ 'Info'}},main::__("Animal [_1] has another breed ([_2]) in database. ", $args->{'ext_animal'},$hs_pedigree->{ $args->{'ext_animal'} }->{'breed'}));
                }
                if ( $hs_pedigree->{ $args->{'ext_animal'} }->{'sex'} ne $args->{'ext_sex'}) {
                    push(@{$hs_record->{ 'Warn'}},main::__("Animal [_1] has another sex ([_2]) in database. ", $args->{'ext_animal'},$hs_pedigree->{ $args->{'ext_animal'} }->{'sex'}));
                }
            }
        }
        
        if ( $args->{'ext_cage'} eq '') {
            push(@{$hs_record->{ 'Info'}},main::__('No cage number. '));
        }
        if ($#{$hs_cage{ $args->{'ext_cage'}}->{'m'}}<0) {
            push(@{$hs_record->{ 'Info'}},main::__('No rooster in cage. '));
        }
        if ($#{$hs_cage{ $args->{'ext_cage'}}->{'w'}}<0) {
            push(@{$hs_record->{ 'Info'}},main::__('No hen in cage. '));
        }
        if (($#{$hs_cage{ $args->{'ext_cage'}}->{'m'}}+1+$#{$hs_cage{ $args->{'ext_cage'}}->{'w'}}+1)<2) {
            push(@{$hs_record->{ 'Warn'}},main::__('To less animals in cage. '));
        }
        if (($#{$hs_cage{ $args->{'ext_cage'}}->{'m'}}>1) and 
           ((scalar keys %{$hs_cage{  $args->{'ext_cage'} }->{'ss'}}>1) or (scalar keys %{$hs_cage{  $args->{'ext_cage'} }->{'sd'}}>1))) {
            push(@{$hs_record->{ 'Info'}},main::__('Different pedigree between roosters. '));
        }
        if ((scalar keys %{$hs_cage{  $args->{'ext_cage'} }->{'ds'}}>1) or (scalar keys %{$hs_cage{  $args->{'ext_cage'} }->{'dd'}}>1)) {
            push(@{$hs_record->{ 'Info'}},main::__('Different pedigree between hens. '));
        }
        if (scalar keys  %{$hs_cage{ $args->{'ext_cage'}}->{'b'}}>1) {
            push(@{$hs_record->{ 'Info'}},main::__('Animals has more then one breed or the same cage number in serveral breeds. '));
        }
        if ($hs_cage{ $args->{'ext_cage'}}->{'cnt'}>1) {
            push(@{$hs_record->{ 'Info'}},main::__('Cage-No [_1] not unique. ', $args->{'ext_cage'} ));
        }

        if (exists $hs_cage_null{$args->{'ext_breed'}}->{$args->{'ext_animal'}}) {
            push(@{$hs_cage_null{$args->{'ext_breed'}}->{$args->{'ext_animal'}}},$args->{'ext_cage'});
        }
#-- ist nicht ganz korrekt, weil Tiere mit falscher Rasse im Hash nicht gefunden werden und dann als nicht existent 
#-- deklariert werden, obwohl sie ja da sind, nur nicht zugeordnet werden können        
#        else {
#            push(@{$hs_record->{ 'Info'}},main::__('Animal [_1] does not exists in database. ', $args->{'ext_animal'} ));
#        }
        
        goto EXIT if ($#{$hs_record->{ 'Info'}}>-1);

        $args->{'ext_id_animal'}=$vext_id_animal;

        # 1.         
        #-- check if numbersystem exists each year needs a new entry
        #-- wing_id_system:::Hvam2015
        $args->{'db_unit'}=GetDbUnit( {
                                            'ext_unit'=>$args->{'ext_unit_animal'},
                                            'ext_id'  =>$args->{'ext_id_animal'}
                                            });

        #-- im ersten Schritt muss der Käfig neu angelegt werden.
        #-- wenn es den Käfig gibt, dann db_unit als db_cage verwenden 
        $args->{'ext_cage'}='' if (!$args->{'ext_cage'});
        $args->{'db_cage'}=GetDbUnit( {
                                'ext_unit'=>'cage',
                                'ext_id'  =>$args->{'ext_cage'}
                                 });

        #-----------------------------------------------------------------
        # close unit

        #-- Voreinstellung
        my $insert=main::__('Insert');
        
        $json->{'Tables'}=['animal'];
        $hs_record->{'Insert'}= ['-'];

        $args->{'guid'} = $hs_pedigree->{ $args->{'ext_animal'}}->{'guid'} ;
        $insert         = $hs_pedigree->{ $args->{'ext_animal'}}->{'guid'} ;

        #--------------------------------------------------------------------------------
        #-- prepare LO to create an entry in table animal           
        my $animal = Apiis::DataBase::Record->new( tablename => 'animal' );

        if ( $animal->status ) {

            if ($fileimport) {

                #-- Fehler in Info des Records schreiben
                push(@{$hs_record->{ 'Info'}},$animal->errors->[0]->msg_long);

                #-- Fehler in Info des Records schreiben
                $apiis->status(0);
                $apiis->del_errors;
                next;
            }
            else {
                $self->status(1);
                $err_ref = scalar $animal->errors;
                last EXIT;
            }
        }

        $animal->column( 'db_animal' )->intdata( $args->{ 'db_animal'} );
        $animal->column( 'db_animal' )->encoded( 1 );

        $animal->column( 'db_cage' )->intdata( $args->{ 'db_cage'} );
        $animal->column( 'db_cage' )->encoded( 1 );
        $animal->column( 'db_cage' )->ext_fields( qw/ db_cage / );

        $animal->column( 'db_sex' )->extdata( $args->{ 'ext_sex'} );
        $animal->column( 'db_sex' )->ext_fields( qw/ext_sex / );

        $animal->column( 'guid' )->intdata( $args->{ 'guid'} );
        
        #-- if animal exists in table animal  
        if ($args->{ 'guid' }) {

            #-- DS modifizieren
            $hs_record->{'Insert'}->[0]=$args->{ 'guid' };
            
            $animal->update;
        }

        if ( $animal->status ) {

            if ($fileimport) {

                #-- Fehler in Info des Records schreiben
                push(@{$hs_record->{ 'Info'}},$animal->errors->[0]->db_column.':'.$animal->errors->[0]->msg_long);

                #-- Fehler in Info des Records schreiben
                $apiis->status(0);
                $apiis->del_errors;
                next;
            }
            else {
                $self->status(1);
                if ( $animal->errors->[0]->msg_short =~ /dupliziert/ ) {
                    $animal->errors->[0]->msg_short('Animal-Id exists already.');
                    $animal->errors->[0]->msg_long('');
                    $animal->errors->[0]->ext_fields( ['ext_animal'] );
                }
                $err_ref = scalar $animal->errors;
                last EXIT;
            }
        }


EXIT:
        if ((!$apiis->status) and ($onlycheck eq 'off')) {
            $apiis->DataBase->commit;
        }
        else {
            $apiis->DataBase->rollback;
        }
    }
     
    if ($fileimport) {

#use Data::Dumper;
#open(LOG, ">/tmp/dumper");
#print LOG Dumper( $apiis );
#close(LOG);
#exit;
        my $user;
        my $pw;
        my $path;
        my $found;
        my $row='';
        my $row2='';
        
        foreach my $vbreed (sort keys %hs_cage_null) {
        
            foreach my $cage (keys %{$hs_check->{ $vbreed }->{'cages'}} ) {
                #-- check auf keine Hennen im Käfig
#                if (!exists $hs_check->{ $vbreed }->{'cages'}->{$cage}->{'dam_animals'}) {
                    
                    #-- Schleife über alle Tiere     
                    foreach my $animal (keys %{$hs_cage_null{$vbreed}}) {
            
                        #-- wenn Tier in einem Käfig gefunden wurde, dann aus dem Hash rauslöschen    
                        if ($hs_cage_null{$vbreed}->{$animal}->[7] and ($hs_cage_null{$vbreed}->{$animal}->[7]==$cage)) {
                            delete $hs_cage_null{$vbreed}->{$animal};
                        }
                    }
#                }
            }

            #-- Schleife über alle Tiere, die in keinem Käfig sind 
            foreach my $vanimal (sort keys %{$hs_cage_null{$vbreed}}) {
                
#                next if (defined $hs_cage_null{$vbreed}->{$vanimal});
                $found=1; 
                $row.='<tr><td>'.$vbreed.'</td><td>'.$vanimal.'</td><td>'
                    .$hs_cage_null{$vbreed}->{$vanimal}->[3].'</td><td>'
                    .$hs_cage_null{$vbreed}->{$vanimal}->[4].'</td><td>'
                    .$hs_cage_null{$vbreed}->{$vanimal}->[5].'</td><td>'
                    .$hs_cage_null{$vbreed}->{$vanimal}->[6].'</td><td><a href="/cgi-bin/GUI?user='.
                      $apiis->{'_cgisave'}->{'user'}.'&sid='.$apiis->{'_cgisave'}->{'sid'}.'&m='.$apiis->{'_cgisave'}->{'m'}.'&o=htm2htm&g='.$apiis->{'_cgisave'}->{'g'}.'&importfilter=LO_DS11&onlycheck=OFF&action=update&filename=LO_DS11&db_animal='.$hs_pedigree->{$vanimal}->{'db_animal'}.'" target="_blank">'.
                      main::__('Close animal').'</a></td></tr>' if (exists $apiis->{'_cgisave'}); 
            }
        }
        if ($found) {
            $row2.= '<strong>'.main::__("These animals have no assignment to a cage.").'<br>'
                            .main::__("Follow each link to close animalnumber or use form Menu->Edit->Animal: fill exit_dt and db_exit").'</strong>';
            $row2.= '<table border="1"><TR><th>'.main::__('Breed').'</th><th>'.main::__('Animal').'</th><th>'.main::__('Rooster').'</th><th>'.main::__('Hen').'</th><th>'.main::__('Sex').'</th><th>'.main::__('Birth').'</th><th>'.main::__('Action').'</th></TR>';
            $row2.= $row;
            $row2.= '</table>';
        }
        $json->{ 'Before' }.=$row2;


        #-- Close animals without a cagenumber 
        if (lc($onlycheck) eq 'off') {
            print 'close animals';
            $sql="update animal set exit_dt = current_date where db_cage isnull and exit_dt isnull";
            $sql_ref = $apiis->DataBase->sys_sql( $sql );
           
            if ($fileimport) {
                my $tbreed='';
                $tbreed=join('+', sort keys %breeds) if ( %breeds);

                chick::SaveDatabase( $apiis, 'DS06', $tbreed, $birthyear, $year, , $fileimport) ;
            }

            $apiis->DataBase->commit;
        }

        return $json;
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;
__END__

