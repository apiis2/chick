#####################################################################
# load object: LO_DS05
#####################################################################
# Das Ladeobjekt initialisiert eine neue Adresse
# events:
#           1. Create a new animal
#           2. create an entry in transfer and animal
#####################################################################
#-- db_cage wird übergeben. In dem Cage sind Vater und Mutter + Rasse
#-- Verfahrensweise: db_cage in animal suchen -> es müssen soviel Tiere
#-- davon existieren, wie Tiere im Käfig sind/waren
#--
#-- alle Tiere für den Cage aus animal holen
#-- männliches Tier ist der Vater
#-- weibliche Tiere sind mögliche Mütter
#-- Väter/Mütter müssen gelebt haben, als die Eier abgesammelt wurden

#TEST-DATA    
#    $args={
#        'db_cage' =>'4608',
#        'db_sex'  =>'1',
#        'ext_animal'=>'W123',
#    };

use strict;
use warnings;
use Spreadsheet::Read;
use Encode;
use chick;

sub LO_DS05 {

    use JSON;
    use URI::Escape;
    use GetDbEvent;
    use GetDbUnit;

    use chick;

    my $self = shift;
    my $args  = shift;

    my $json;
    my $err_ref;
    my $err_status;
    my @record;
    my $extevent;
    my %hs_cages_per_line;
    my %hs_found_cages_for_line;
    my (%hs_ext_animal, %breeds,$curryear);

    my %hs_event = ();
    my $db_event;

    our $hs_animal;
    my @field;
    my $hs_fields={};
    my $fileimport;
    my $history;
    my %hs_unit;

    if (exists $args->{ 'history' }) {
        $history=$args->{ 'history' };
    }
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

goto Debug;
    my $vfound;
    $json = { 'Info'        => [],
              'RecordSet'   => [],
              'Bak'         => [],
            };

    my $sql="select distinct user_get_full_db_unit(a.db_cage), (select count(*) from animal where db_cage=a.db_cage and db_sex=(select db_code from codes where class='SEX' and ext_code='1')), (select count(*) from animal where db_cage=a.db_cage and db_sex=(select db_code from codes where class='SEX' and ext_code='2')), (select count(z.*) from (select distinct db_sire from animal where db_cage=a.db_cage )  z ), (select count(z.*) from (select distinct db_dam from animal where db_cage=a.db_cage )  z) , a.db_cage, ext_id  from v_active_animals_and_cages a order by a.ext_id ;
    ";

    #-- SQL auslösen 
    my $sql_ref = $apiis->DataBase->sys_sql( $sql );
    # Auslesen des Ergebnisses der Datenbankabfrage
    while ( my $q = $sql_ref->handle->fetch ) {
      
        
        my $msg='';
        if ($q->[1] == 0) {
            $msg.=main::__("No rooster in cage");
        }
        if ($q->[1] > 1) {
            $msg.=main::__("More than one rooster in cage");
        }
        if ($q->[2] < 1) {
            $msg.=main::__("No hen in cage");
        }
        if (($q->[1] == 1) and ($q->[2]>0) and ($q->[3]!=2)) {
            $msg.=main::__("Pedigree of sire is wrong");
        }
        if (($q->[1] == 1) and ($q->[2]>0) and $q->[4]!=2) {
            $msg.=main::__("Pedigree of hen is wrong");
        }
        
        #-- Stammdaten aller Tiere holen und ausdrucken 
        if ($msg) {

            $vfound=1;
            print "<h5><strong>$msg</strong></h5>";   
            my $sql1="select user_get_ext_id_animal(db_animal), user_get_ext_id_animal(db_sire), user_get_ext_id_animal(db_dam), user_get_ext_code(db_sex,'e'), user_get_ext_code(db_breed,'s'), birth_dt, (select ext_id from unit where db_unit=db_cage) from animal where db_cage=$q->[5]" ;

            #-- SQL auslösen 
            my $sql_ref1 = $apiis->DataBase->sys_sql( $sql1 );
       

            print '<table border=".5">';
            print "<TR><th>Animal</th><th>Sire</th><th>Dam</th><th>Sex</th><th>Breed</th><th>Birth_dt</th><th>Cage</th></TR>";
            while ( my $q = $sql_ref1->handle->fetch ) {
                print "<TR><td>$q->[0]</td><td>$q->[1]</td><td>$q->[2]</td><td>$q->[3]</td><td>$q->[4]</td><td>$q->[5]</td><td>$q->[6]</td></TR>";
            }   
            print '</table>';
        }
    }    

    last EXIT if ($vfound);
Debug:
#############################################################################################
    my $t=1;

    my ($hs_check,$row1)=chick::CheckStatusDS($apiis);

    #-- Wenn ein File geladen werden soll, dann zuerst umwandeln in
    #   einen JSON-String, damit einheitlich weiterverarbeitet werden kann
    if ( $fileimport ) {

        my (@in,$max_rows,$max_cols,$book,$sheet);

        #-- Datei öffnen
        open( IN, "$fileimport" ) || die "error: kann $fileimport nicht öffnen";

        #-- if csv file
        if ($fileimport=~/\.csv_.*$/) {
            @in=<IN>;
        }
        
        #-- if xlsx-file
        else {

            #-- Excel-Tabelle öffnen 
            $book = Spreadsheet::Read->new ("$fileimport", dtfmt => "dd.mm.yyyy");
            $sheet = $book->sheet (1);

            #-- Fehlermeldung, wenn es nicht geht 
            if(defined $book->[0]{'error'}){
                print "Error occurred while processing $fileimport:".
                    $book->[0]{'error'}."\n";
                exit(-1);
            }
            
            $max_rows = $sheet->{'maxrow'};
            $max_cols = $sheet->{'maxcol'};

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

        $json = { 'Info'        => [],
                  'RecordSet'   => [],
                  'Bak'         => [],
                };

        my $rec=0;

#        $json->{'Before'}.='<table border="1">'.$row1.'</table><p>';

        #-- Schleife über alle Datensätze
        foreach (@in) {

            $rec++;

            push( @{ $json->{ 'Bak' } },$_); 

            #-- Zeilenumbruch entfernen
            $_ =~ s/\r|\n//g;

            #-- declare
            my @data;
            my $record;
            my $hs = {};

            #-- skip first record 
            next if ($rec<2);

            #-- file
            $hs_fields->{'ahb'}     ={'ext_id'=>'cage', 'ext_sex'=>'sex','ext_animal'=>'wingnumber', 'ext_breed'=>'ext_breed'};

            @field=('ext_animal','ext_sex','far','ext_cage', 'ext_breed','ext_sire', 'ext_dam', 'birth_dt');

            @data = split(';', $_ ,5);

            #-- remove leading zeros or spaces and comma to dot
            map { $_ =~ s/^[0\s]+//g; $_ =~ s/\s+$//g; $_=~s/,/./g; $_='' if (!$_) } @data;

            #-- skip if no cage-ID
            next if ( !$data[ 2 ] and !$data[4] );

            #-- Check auf gültigen Ladestrom Spalte 2 Geschlecht=1 oder 1 und Rasse muss Buchstaben enthalten 
            if (($data[3]!~/^[^0-9]{2}/) or ($data[1]!~/^(1|2)$/)) {
                print __('Wrong dataset format for LO_DS05. Column 2 has to be sex as 1 or 2 and column 4 is defined as breed with a character at the first place');
                print '<p><p>'.join(' ; ', @data);
                return;
            }

            #-- define format for record 
            $record = {
                    'ext_sex'           => [ $data[1],'',[] ],
                    'ext_animal'        => [ $data[0],'',[] ],
                    'ext_unit_animal'   => [ 'wing_id_system','',[] ],
                    'far'               => [ $data[2],'',[] ],
                    'far_id'            => [ $data[3].':::'.$data[2],'',[] ],
                    'ext_breed'         => [ $data[3],'',[] ],
#                    'ext_cage'          => [ $data[4],'',[] ],
            };

            #-- collect all breeds for filename 
            $breeds{$data[3]}=1;

            #-- Datensatz mit neuen Zeiger wegschreiben
            push( @{ $json->{ 'RecordSet' } },{ 'Info' => [], 'Data' => { %{$record} },'Insert'=>[], 'Tables'=>['animal','transfer','possible_dams']} );
        }

        #-- Datei schließen
        close( IN );
        
        $json->{ 'Fields'}  = [@field];
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

    my $vext_id_animal;
    if ( $fileimport ) { 
        
        #-- aktuelles Jahr holen
        if (exists $args->{ 'history'} and ($args->{ 'history'})) {
            $vext_id_animal= 'Hvam'.$args->{'history'};
        }
        else {
            $sql="select distinct date_part('year',hatch_dt) from hatch_cage a inner join v_active_animals_and_cages b on a.db_cage=b.db_cage where hatch_dt notnull order by date_part('year',hatch_dt) desc limit 1 ";
            
            #-- SQL auslösen 
            $sql_ref = $apiis->DataBase->sys_sql( $sql );
            
            while ( my $q = $sql_ref->handle->fetch ) {
                $vext_id_animal= 'Hvam'.$q->[0]; 
                $history=$q->[0];
                $curryear=$q->[0];
            }
        }
    }
    else {
        $vext_id_animal= $json->{'RecordSet'}->[0]->{'Data'}->{'Fanimal_ext_id'}->[0];
    }

    my $cnt;

    $sql="select a.far_id, a.ext_cage from v_hatch_cage a left outer join v_active_animals_and_cages b on a.db_cage=b.db_cage where date_part('year', hatch_dt)='$history' and  b.ext_id isnull ;";

    #-- SQL auslösen 
    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    
    my %cageerror;
    while ( my $q = $sql_ref->handle->fetch ) {
        $cageerror{$q->[0]}=[@$q];
    }

    if (%cageerror) {
    
        $json->{'Before'}.=main::__("There are cages without a connection to an active parent cage");

        $json->{'Before'}.='<ul>';
        
        foreach my $key (sort keys %cageerror) {
            $json->{'Before'}.='<li>'.join(' => ',@{ $cageerror{$key} }).'</li>';
        }
        $json->{'Before'}.='</ul>';
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

        #-- Check auf korrekten Ladestrom
        #-- muss aktive Tiere haben, aktive Tiere in hatch_cage und kein aktiven Eltern
        if ($hs_check->{$args->{'ext_breed'}}->[1] and $hs_check->{$args->{'ext_breed'}}->[2] and !$hs_check->{$args->{'ext_breed'}}->[3]) {
            my $at=1;
        }
        else {
            push(@{$hs_record->{ 'Err'}},"Wrong datastream for this breed");
        }
            
        $cnt++;
#        if ($cnt<2453) {
#            next;
#        }

        #-- declare
        #-- drei checks 
        
        my $msg;
        my $extfield;
        my $msgtype='Info';
      
        #-- wenn kein externer Käfig und kein Jahr angegeben wurde, dann Abbruch, weil far und cages nicht zugeordent werden können 
        if (!$history and !$args->{'ext_cage'}) {
        
            print __('There are no cagenumbers in the dataset'). ' <a href="'.$fileimport.'">'. $fileimport.'</a>';
            print '<p>';
            print __('Please put in the cage number in loadingstream or put in the year of birth from chicken in the FileUpload-form');

            goto EXIT;
            
        }
        
        my $sql;
        #--  
        if ($history) {
            $sql="set datestyle to 'german';
            select b.db_cage, 
                   b.far_id, 
                   (select db_animal from animal where db_cage=b.db_cage and db_sex=(select db_code from codes where class='SEX' and ext_code='1') limit 1) as db_sire, 
                   (select db_animal from animal where db_cage=b.db_cage and db_sex=(select db_code from codes where class='SEX' and ext_code='2') limit 1) as db_dam, 
                   (select db_breed from animal where db_cage=b.db_cage limit 1) as db_breed, 
                   case when b.hatch_dt::date isnull then c.event_dt+39 else b.hatch_dt::date end,  
                   case when b.hatch_dt::date isnull then date_part('year', c.event_dt+39) else date_part('year', b.hatch_dt::date) end, 
                   db_animal, 
                   (select user_get_ext_id_animal(db_animal) from animal where db_cage=b.db_cage and db_sex=(select db_code from codes where class='SEX' and ext_code='1') limit 1) as ext_sire, 
                   (select user_get_ext_id_animal(db_animal) from animal where db_cage=b.db_cage and db_sex=(select db_code from codes where class='SEX' and ext_code='2') limit 1) as ext_dam, 
                   (select ext_id from unit where db_unit=b.db_cage) as ext_cage

            from v_active_animals_and_cages a inner join v_hatch_cage b on a.db_cage=b.db_cage  inner join event c on b.db_event=c.db_event 
            where b.far_id='".$args->{'ext_breed'}.":::".$args->{'far'}."' and case when b.hatch_dt::date isnull then date_part('year', c.event_dt+39) else date_part('year', b.hatch_dt::date) end='".$history."' and db_sex=(select db_code from codes where class='SEX' and ext_code='2')";

        }
        else {
            $sql="set datestyle to 'german';
            select b.db_cage, 
                   b.far_id, 
                   (select db_animal from animal where db_cage=b.db_cage and db_sex=(select db_code from codes where class='SEX' and ext_code='1') limit 1) as db_sire, 
                   (select db_animal from animal where db_cage=b.db_cage and db_sex=(select db_code from codes where class='SEX' and ext_code='2') limit 1) as db_dam, 
                   (select db_breed from animal where db_cage=b.db_cage limit 1) as db_breed, 
                   case when b.hatch_dt::date isnull then c.event_dt+39 else b.hatch_dt::date end,  
                   case when b.hatch_dt::date isnull then date_part('year', c.event_dt+39) else date_part('year', b.hatch_dt::date) end, 
                   db_animal, 
                   (select user_get_ext_id_animal(db_animal) from animal where db_cage=b.db_cage and db_sex=(select db_code from codes where class='SEX' and ext_code='1') limit 1) as ext_sire, 
                   (select user_get_ext_id_animal(db_animal) from animal where db_cage=b.db_cage and db_sex=(select db_code from codes where class='SEX' and ext_code='2') limit 1) as ext_dam, 
                   (select ext_id from unit where db_unit=b.db_cage) as ext_cage

            from v_active_animals_and_cages a inner join hatch_cage b on a.db_cage=b.db_cage  inner join event c on b.db_event=c.db_event 
            where a.ext_id='$args->{'ext_cage'}' and db_sex=(select db_code from codes where class='SEX' and ext_code='2')";
        }

        #-- SQL auslösen 
        my $sql_ref = $apiis->DataBase->sys_sql( $sql );
        
        #-- Fehlerbehandlung 
        if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
            $self->errors( $sql_ref->errors);
            $self->status(1);
            $apiis->status(1);
            goto EXIT;
        }
       
        my $vfound;

        $args->{'possible_dams'}=[];

        # Auslesen des Ergebnisses der Datenbankabfrage
        while ( my $q = $sql_ref->handle->fetch ) {
            
            #-- flag für Fehlermeldung 
            $vfound=1;
            
            #-- Käfig 
            $args->{'db_cage'}=$q->[0];
            $args->{'ext_cage'}=$q->[10];
            
            #-- far-ID 
            $args->{'far'}=$q->[1];
            
            #-- sire 
            $args->{'db_sire'}=$q->[2];
            $args->{'ext_sire'}=$q->[8];
            
            $args->{'ext_dam'}=$q->[9];
            
            #-- dam 
            push(@{$args->{'possible_dams'}},$q->[7]);
            
            #-- db_breed 
            $args->{'int_breed'}=$q->[4];
            
            #-- Geburtsdatum des Tieres 
            $args->{'birth_dt'}=$q->[5];
                    
            #-- ext_id animal  
            $args->{'ext_id_animal'}= $vext_id_animal;
        }

        #-- Käfig wurde in animal nicht gefunden 
        if ( !$vfound ) {
            
            push(@{$hs_record->{ 'Warn'}},"No Parent-Cage found in table 'hatch_cage' => <a target='FAQ' href='/doc/FAQ.html'>Solutions</a>  ");

            #-- sire 
            $args->{'db_sire'}=1;
            
            #-- dam 
            push(@{$args->{'possible_dams'}},2);
            
            #-- ext_id animal  
            $args->{'ext_id_animal'}= $vext_id_animal;
        }

        $hs_record->{ 'Data' }->{'db_sire'}->[0]=$args->{'db_sire'}; 
        $hs_record->{ 'Data' }->{'db_dam'}->[0]=$args->{'possible_dams'}[0]; 
        $hs_record->{ 'Data' }->{'birth_dt'}->[0]=$args->{'birth_dt'}; 
        
        $hs_record->{ 'Data' }->{'ext_sire'}->[0]=$args->{'ext_sire'}; 
        $hs_record->{ 'Data' }->{'ext_dam' }->[0]=$args->{'ext_dam'}; 
        $hs_record->{ 'Data' }->{'ext_cage'}->[0]=$args->{'ext_cage'}; 

        # 1.         
        #-- check if numbersystem exists each year needs a new entry
        #-- wing_id_system:::Hvam2015

        if ((exists $hs_unit{$args->{'ext_unit_animal'}.':::'.$args->{'ext_id_animal'}})) {
            $args->{'db_unit'}=$hs_unit{$args->{'ext_unit_animal'}.':::'.$args->{'ext_id_animal'}};
        }
        else {
            if ($args->{'ext_id_animal'}) {
                $args->{'db_unit'}=GetDbUnit( {
                                                'ext_unit'=>$args->{'ext_unit_animal'},
                                                'ext_id'  =>$args->{'ext_id_animal'}
                                                });
              
                #--  
                $apiis->DataBase->commit;

            }
            $args->{'db_unit'}=0 if (!$args->{'db_unit'});

            $hs_unit{$args->{'ext_unit_animal'}.':::'.$args->{'ext_id_animal'}}=$args->{'db_unit'};
        }

        #-----------------------------------------------------------------
        # close unit

        $json->{'Tables'}=['transfer', 'animal','possible_dams'];
        $hs_record->{'Insert'}= ['-', '-' ,'-'];

        #-- Check, ob insert oder update
        $sql="select a.guid, c.guid, b.guid from possible_dams a left outer join transfer b on a.db_animal=b.db_animal
            left outer join animal c on c.db_animal=b.db_animal where b.db_unit=".$args->{ 'db_unit'}." and b.ext_animal='".$args->{'ext_animal'}."'";
                         ;

        #-- SQL auslösen 
        $sql_ref = $apiis->DataBase->sys_sql( $sql );
       

        #-- Fehlerbehandlung 
        if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {

            if ($fileimport) {

                #-- Fehler in Info des Records schreiben
                push(@{$hs_record->{ 'Info'}},$sql_ref->errors->[0]->msg_long);

                #-- Fehler in Info des Records schreiben
                $apiis->status(0);
                $apiis->del_errors;
                goto EXIT;
            }
            else {
                $self->errors( $apiis->errors);
                $self->status(1);
                $apiis->status(1);
                goto EXIT;
            }   
        }

        #-- Voreinstellung
        my $insert=main::__('Insert');
        
        # Auslesen des Ergebnisses der Datenbankabfrage
        while ( my $q = $sql_ref->handle->fetch ) {
            $insert          = $q->[2];
            $args->{'guidp'} = $q->[0];
            $args->{'guida'} = $q->[1];
            $args->{'guid'}  = $q->[2];
        }


        #--check for double wingnumber 
        $hs_ext_animal{ $args->{'ext_animal'}}++;

        if ( $hs_ext_animal{ $args->{'ext_animal'}} >1 ) {
       
            #-- Fehler in Info des Records schreiben
            push(@{$hs_record->{ 'Info'}}, main::__("Wingnumber [_1] exists", $args->{'ext_animal'}));

            goto EXIT;
        }


        # 2. Neues Tier anlegen      
        #------------------------- Transfer --------------------------
        
        #-- Neue Tiernummer holen 
        $args->{'db_animal'} = $apiis->DataBase->seq_next_val('seq_transfer__db_animal');
        
        #-- mit den Wurfdaten ein neues Tier in transfer erzeugen
        my $transfer = Apiis::DataBase::Record->new( tablename => 'transfer' );

        #-- interne Tiernummer
        $transfer->column('db_animal')->intdata($args->{'db_animal'});
        $transfer->column('db_animal')->encoded(1);
        $transfer->column('db_animal')->ext_fields(qw /ext_animal/);

        #-- ext_animal
        $transfer->column('ext_animal')->extdata( $args->{ 'ext_animal' } );
        $transfer->column('ext_animal')->ext_fields( 'ext_animal');

        #-- db_unit 
        $transfer->column('db_unit')->extdata( $args->{'ext_unit_animal'}, $args->{'ext_id_animal'} );
        $transfer->column('db_unit')->ext_fields( 'ext_animal' );

        #-- opening_dt 
        my $od = $args->{ 'birth_dt' } ;

        #-- opening_dt muss besetzt sein: mit aktuellem Datum, falls undef
        $od = $apiis->now  if ( !$od or ( $od eq '' ) );
        $transfer->column('opening_dt')->extdata( $od );
        $transfer->column('opening_dt')->ext_fields( 'ext_animal' );
    
        #-- id_set
        $transfer->column( 'id_set' )->extdata( $args->{'ext_unit_animal'} );
        $transfer->column( 'id_set' )->ext_fields( 'ext_animal' );

        #-- if animal exists in table transfer  
        if ($args->{ 'guid' }) {

            #-- if form says "only inserts", then ignore and give a warning 
            if ($action eq 'insert') {
                
                $hs_record->{'Insert'}->[0]=$args->{ 'guid' };
            }
            else {    
                
                #-- guid
                if ($args->{ 'guid' } and ($args->{ 'guid' } ne '')) {
                    $transfer->column( 'guid' )->extdata( $args->{ 'guid' } );
                }   

                #-- DS modifizieren
                $hs_record->{'Insert'}->[0]=$args->{ 'guid' };
                
                $transfer->update;
            }
        }
        else {
            
            #-- if form says "only inserts", then ignore and give a warning 
            if ($action eq 'update') {
                
                push(@{$hs_record->{ 'Err'}},main::__("Only inserts are allowed -> ignore"));
                
                $hs_record->{'Insert'}->[0]=main::__('Ignore');
            }
            else {    
                
                $hs_record->{'Insert'}->[0]=$insert;

                $transfer->insert();
            }
        }

        #-- Fehlerbehandlung 
        if ( $transfer->status ) {
            if ($fileimport) {

                #-- Fehler in Info des Records schreiben
                push(@{$hs_record->{ 'Info'}},$transfer->errors->[0]->msg_short);

                goto EXIT;
            }
            else {
                $apiis->status(1);
                $apiis->errors( scalar $transfer->errors );

                goto EXIT;
            }
        }
       
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
                goto EXIT;
            }
            else {
                $self->status(1);
                $err_ref = scalar $animal->errors;
                goto EXIT;
            }
        }

        $animal->column( 'db_animal' )->intdata( $args->{ 'db_animal'} );
        $animal->column( 'db_animal' )->encoded( 1 );
        $animal->column( 'db_animal' )->ext_fields( qw/ ext_animal / );

        $animal->column( 'db_sire' )->intdata( $args->{ 'db_sire'} );
        $animal->column( 'db_sire' )->encoded( 1 );
        $animal->column( 'db_sire' )->ext_fields( qw/ ext_id_animal / );

        $animal->column( 'db_dam' )->intdata( $args->{ 'possible_dams'}[0] );
        $animal->column( 'db_dam' )->encoded( 1 );
        $animal->column( 'db_dam' )->ext_fields( qw/ ext_id_animal / );

        $animal->column( 'db_sex' )->extdata( $args->{ 'ext_sex'} );
        $animal->column( 'db_sex' )->ext_fields( qw/ ext_sex / );

        if (exists $args->{ 'int_breed'}) {
            $animal->column( 'db_breed' )->intdata( $args->{ 'int_breed'} );
            $animal->column( 'db_dam' )->encoded( 1 );
        }
        else {
            $animal->column( 'db_breed' )->extdata( $args->{ 'ext_breed'} );
        }
        $animal->column( 'db_breed' )->ext_fields( qw/ ext_breed / );

        $animal->column( 'birth_dt' )->extdata( $args->{ 'birth_dt'} );
        $animal->column( 'birth_dt' )->ext_fields( qw/ ext_animal / );

        #-- if animal exists in table animal  
        if ($args->{ 'guida' } and  ($args->{ 'guida' }  ne '')) {

            #-- if form says "only inserts", then ignore and give a warning 
            if ($action eq 'insert') {
                
                $hs_record->{'Insert'}->[1]=$args->{ 'guida' };
            }
            else {    
                
                #-- guid
                if ($args->{ 'guida' } and ($args->{ 'guida' } ne '')) {
                    $animal->column( 'guida' )->extdata( $args->{ 'guida' } );
                }   

                #-- DS modifizieren
                $hs_record->{'Insert'}->[1]=$args->{ 'guida' };
                
                $animal->update;
            }
        }
        else {
            #-- if form says "only inserts", then ignore and give a warning 
            if ($action eq 'update') {
                
                push(@{$hs_record->{ 'Err'}},main::__("Only updates are allowed -> ignore"));
                
                $hs_record->{'Insert'}->[1]=main::__('Ignore');
            }
            else {    
                
                $hs_record->{'Insert'}->[1]=$insert;

                $animal->insert();
            }
        }

        if ( $animal->status ) {

            if ($fileimport) {

                #-- Fehler in Info des Records schreiben
                push(@{$hs_record->{ 'Info'}},$animal->errors->[0]->msg_long);

                #-- Fehler in Info des Records schreiben
                $apiis->status(0);
                $apiis->del_errors;
                goto EXIT;
            }
            else {
                $self->status(1);
                if ( $animal->errors->[0]->msg_short =~ /dupliziert/ ) {
                    $animal->errors->[0]->msg_short('Animal-Id exists already.');
                    $animal->errors->[0]->msg_long('');
                    $animal->errors->[0]->ext_fields( ['ext_animal'] );
                }
                $err_ref = scalar $animal->errors;
                goto EXIT;
            }
        }


        #-- Tabelle der möglichen Mütter füllen 
        my $possible_dams = Apiis::DataBase::Record->new( tablename => 'possible_dams' );
        
        $possible_dams->column( 'db_animal' )->intdata( $args->{ 'db_animal'} );
        $possible_dams->column( 'db_animal' )->encoded( 1 );
        $possible_dams->column( 'db_animal' )->ext_fields( qw/ ext_animal / );
        
        #-- Schleife über die Anzahl der Hennen im Käfig 
        for (my $i=1; $i<=$#{$args->{'possible_dams'}};$i++ ) {

            if  ( $args->{ 'possible_dams'}->[$i-1] ) {
                if (!$possible_dams->column( 'db_dam'.$i )) {
                    push(@{$hs_record->{ 'Warn'}},main::__("More then 10 dams -> ignore ".$args->{ 'possible_dams'}->[$i-1]));
                    $possible_dams->status(0);
                    $possible_dams->del_errors;
                    next;
                }

                $possible_dams->column( 'db_dam'.$i )->intdata( $args->{ 'possible_dams'}->[$i-1] );
                $possible_dams->column( 'db_dam'.$i )->encoded( 1 );
                $possible_dams->column( 'db_dam'.$i )->ext_fields( qw/ ext_animal / );
            }
        }
        
        #-- if animal exists in table animal  
        if ($args->{ 'guidp' } and  ($args->{ 'guidp' }  ne '')) {

            #-- if form says "only inserts", then ignore and give a warning 
            if ($action eq 'insert') {
                
                $hs_record->{'Insert'}->[2]=$args->{ 'guidp' };
            }
            else {    
                
                #-- guid
                if ($args->{ 'guidp' } and ($args->{ 'guidp' } ne '')) {
                    $possible_dams->column( 'guidp' )->extdata( $args->{ 'guidp' } );
                }   

                #-- DS modifizieren
                $hs_record->{'Insert'}->[2]=$args->{ 'guidp' };
                
                $possible_dams->update;
            }
        }
        else {
            
            #-- if form says "only inserts", then ignore and give a warning 
            if ($action eq 'update') {
                
                push(@{$hs_record->{ 'Warn'}},main::__("Only updates are allowed -> ignore"));
                
                $hs_record->{'Insert'}->[2]=main::__('Ignore');
            }
            else {    
                
                $hs_record->{'Insert'}->[2]=$insert;

                $possible_dams->insert();
            }
        }

        if ( $possible_dams->status ) {

            if ($fileimport) {

                #-- Fehler in Info des Records schreiben
                push(@{$hs_record->{ 'Info'}},$possible_dams->errors->[0]->msg_short);

                #-- Fehler in Info des Records schreiben
                $apiis->status(0);
                $apiis->del_errors;
                goto EXIT;
            }
            else {
                $self->status(1);
                if ( $possible_dams->errors->[0]->msg_short =~ /dupliziert/ ) {
                    $possible_dams->errors->[0]->msg_short('Animal-Id exists already.');
                    $possible_dams->errors->[0]->msg_long('');
                    $possible_dams->errors->[0]->ext_fields( ['ext_animal'] );
#}
                $err_ref = scalar $possible_dams->errors;
                goto EXIT;
                }
            }
        }

EXIT:
        if ((!$apiis->status) and ($onlycheck eq 'off')) {
            $apiis->DataBase->commit;
        }
        else {
            $apiis->DataBase->rollback;
        }

        $apiis->status(0);
        $apiis->del_errors;
    }
    
    #-- save database, save loading stream     
    if ($fileimport) {

        if ((!$apiis->status) and ($onlycheck eq 'off')) {

            my $birthyear=$curryear-1;

            if ($fileimport) {
                my $tbreed='';
                $tbreed=join('+', sort keys %breeds) if ( %breeds);

                chick::SaveDatabase( $apiis, 'DS05', $tbreed, $birthyear, $curryear, $fileimport) ;
            }
        }

        return $json;
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;
__END__

