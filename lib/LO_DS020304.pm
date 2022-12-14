#####################################################################
# load object: LO_DS07
# $Id: LO_DS020304.pm,v 1.18 2022/04/01 13:21:35 lfgroene Exp $
#####################################################################
# This is the Load Object to store collected, incubated and hatched eggs of a cage.
#
#--  test-data
#
# Conditions:
# 1. The load object is one transevent: either it succeeds or
#    everything is rolled back.
# 2. The Load_object is aborted on the FIRST error.
######################################################################
use strict;
use warnings;
our $apiis;
use chick;
use Spreadsheet::Read;
use Encode;

sub LO_DS020304 {
    my $self     = shift;
    my $args     = shift;
 
    use GetDbUnit;
    use JSON;
    use URI::Escape;
    use GetDbEvent;

#TEST-DATA    
#    $args = {
#        db_cage  => '2165',
#        db_event => '14',
#        collected_eggs =>'48',
#        incubated_eggs => '45',
#        hatched_eggs   =>'80',
#        hatch_dt       => '01.01.2014'    
#    };


    my $json;
    my $err_ref;
    my $err_status;
    my @record;
    my $extevent;
    my %hs_cages_per_line;
    my %hs_found_cages_for_line;
    my @in; 

    my %hs_event = ();
    my $db_event;
    my $event='1';

    our $hs_animal;
    my @field;
    my $hs_fields={};
    my $fileimport;
    my $filetype;
    my %chk_cage;
    my %chk_act_cage;

    if (exists $args->{ 'FILE' }) {
        $fileimport=$args->{ 'FILE' };
    }
    my $onlycheck='off';
    if (exists $args->{ 'onlycheck' }) {
        $onlycheck=lc($args->{ 'onlycheck' });
    }
    my $event_date;
    if (exists $args->{ 'event_dt' }) {
        $event_date=$args->{ 'event_dt' };
    }
   
    my ($hs_dscheck,$row1)=chick::CheckStatusDS($apiis);

    #-- Wenn ein File geladen werden soll, dann zuerst umwandeln in
    #   einen JSON-String, damit einheitlich weiterverarbeitet werden kann
    if ( $fileimport ) {

        
        #-- Datei öffnen
        open( IN, "$fileimport" ) || die "error: kann $fileimport nicht öffnen";

        $json = { 'Info'        => [],
                  'RecordSet'   => [],
                  'Critical'    => [],
                  'Bak'         => [],
                  'Tables'      => ['hatch_cage'],
                };

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
                map { if (!defined $_) {$_=''} } @data;

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
            next if (lc($_)=~/rase.*stamme.*antal/);

            @data = split(';', $_ ,10);

            #-- remove leading zeros or spaces and comma to dot
            map { $_ =~ s/^\s+//g; $_ =~ s/\s+$//g; $_=~s/[\/,]/./g; $_='' if (!defined $_) } @data;

            #-- wenn yyyy-mm-dd oder yyy/mm/dd 
            $data[ 8 ]=~s/^(\d{4})[-.\/](\d{2})[-.\/](\d{2})$/$3.$2.$1/g;
            $data[ 4 ]=~s/^(\d{4})[-.\/](\d{2})[-.\/](\d{2})$/$3.$2.$1/g;

            #-- Check auf gültigen Ladestrom Spalte 2 Geschlecht=1 oder 1 und Rasse muss Buchstaben enthalten 
            if ((($data[0]!~/^\w+[0-9]*/) or $data[1]!~/^[0-9].*/) or ($data[2]!~/^[0-9].*$/) or ($data[8]!~/^.+\..+\..+$/) ) {
                print __('Wrong dataset format for LO_DS020304. It has to be: rase;Far nummer (ST);bur nummer;velg ny generasjon;dato innlagte egg;Innlagte egg;Til Klekking ;Klekka;Dato klekka and it is [_1]', $_);
                print '<p><p>'.join(' ; ', @data);
                return;
            }

            #-- skip if no cage-ID
            next if ( !$data[ 2 ] );
            next if ( $data[ 2 ] eq '' );

            #-- define format for record 
            $record = {
                    'ext_unit_event'    => ['location', 'location',[] ],
                    'ext_event_type'    => ['eggs_for_hatching','eggs_for_hatching',[] ],
                    'ext_id_event'      => ['Hvam','Hvam',[]],
                    'event_dt'          => [ $data[ 4 ],'', [] ], # 
                    
                    'ext_unit'          => ['cage'   ,'',[] ], # externe id
                    'cage'            => [ $data[2],'',[] ], # externe id
                    'cagenextgen'       => [ $data[3],'',[] ], # externe id
                    
                    'hatch_dt'          => [ $data[ 8 ],'', [] ], # 

                    'ext_breed'         => [ $data[0],'',[] ],
                    'far'               => [ $data[0].':::'.$data[1],'',[] ],
                    
                    'collected_eggs'    => [ $data[5],'',[] ], # externe unit
                    'incubated_eggs'    => [ $data[6],'',[] ], # externe unit
                    'hatched_eggs'      => [ $data[7],'',[] ], # externe unit
            };

            #-- only one far per cage otherwise error 
            if (!exists $chk_cage{ $record->{'cage'}->[0] }) {
                $chk_cage{ $record->{'cage'}->[0] }=[$record->{'far'}->[0] ];
            }
            else {
                push(@{$chk_cage{ $record->{'cage'}->[0] }},$record->{'far'}->[0] );
            }

            #-- only one cage per file otherwise error 
            if (!exists $chk_act_cage{ $record->{'cage'} }) {
                $chk_act_cage{ $record->{'cage'}->[0] }=undef;
            }

            #-- Datensatz mit neuen Zeiger wegschreiben
            push( @{ $json->{ 'RecordSet' } },{ 'Info' => [], 'Data' => { %{$record} },'Insert'=>[]} );
        }

        #-- Datei schließen
        close( IN );
        
        $hs_fields->{'ahb'}     ={'ext_breed'=>'breed', 'ext_id'=>'cage', 'event_dt0'=>'date', 'rooster_id0'=>'4', 'rooster_body_wt_20_weeks'=>'5', 'hen1_body_wt_20_weeks'=>'6', 'hen2_body_wt_20_weeks'=>'7', 'hen3_body_wt_20_weeks'=>'8', 'hen4_body_wt_20_weeks'=>'9', 'hen5_body_wt_20_weeks'=>'10', 'hen6_body_wt_20_weeks'=>'11', 'hen7_body_wt_20_weeks'=>'12', 'hen8_body_wt_20_weeks'=>'13', 'hen9_body_wt_20_weeks'=>'14', 'hen10_body_wt_20_weeks'=>'15'};
        
        $json->{ 'Fields'}  = ['ext_breed', 'far', 'cage', 'cagenextgen', 'event_dt',
                               'collected_eggs', 'incubated_eggs', 'hatched_eggs', 'hatch_dt'];
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

    #--------------------- checks
    
    #-- creates a hash to count how many hens are in a cage to check the input
    #-- must be >0
    my %hs_n_hens_per_cage;
    my %hs_insert;

    #-- zuchten holen 
    my $sql="select  user_get_ext_id(b.db_cage) as cage, count(db_animal) as nhens 
             from v_active_animals_and_cages b left outer join hatch_cage a on a.db_cage=b.db_cage 
             where db_sex=(select db_code from codes where class='SEX' and ext_code='2') 
             group by b.db_cage";

    #-- sql auslösen 
    my $sql_ref = $apiis->DataBase->sys_sql( $sql );

    #-- fehlerbehandlung 
    if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
        $self->errors( $apiis->errors);
        $self->status(1);
        $apiis->status(1);
        goto EXIT;
    }   
    
    # auslesen des ergebnisses der datenbankabfrage
    while ( my $q = $sql_ref->handle->fetch ) {
        $hs_n_hens_per_cage{$q->[0]}=$q->[1];
    }
   
    $sql="select distinct user_get_ext_id(db_cage) as cage from v_active_animals_and_cages;";
    
    #-- sql auslösen 
    my $sql_ref1 = $apiis->DataBase->sys_sql( $sql );

    #-- fehlerbehandlung 
    if ( $sql_ref1->status and ( $sql_ref1->status == 1 ) ) {
        $self->errors( $apiis->errors);
        $self->status(1);
        $apiis->status(1);
        goto EXIT;
    }   

    while ( my $q = $sql_ref1->handle->fetch ) {
        if (exists $chk_act_cage{$q->[0]}) {
            $chk_act_cage{$q->[0]}=1;   
        }
    }

    $sql="select ext_code from codes where class='BREED';";
    
    #-- sql auslösen 
    $sql_ref1 = $apiis->DataBase->sys_sql( $sql );

    #-- fehlerbehandlung 
    if ( $sql_ref1->status and ( $sql_ref1->status == 1 ) ) {
        $self->errors( $apiis->errors);
        $self->status(1);
        $apiis->status(1);
        goto EXIT;
    }   

    my %breeds;
    while ( my $q = $sql_ref1->handle->fetch ) {
        $breeds{$q->[0]}=1;   
    }

    my $error;
    foreach my $key (keys %chk_act_cage) {
        
        #-- of no active cage 
        if (!$chk_act_cage{$key}) {
            $error=1;
        }
    }
    
    if ($error) {
    
        $json->{'Before'}.=main::__("There are cages without a connection to an active parent cage");

        $json->{'Before'}.='<ul>';
        
        foreach my $key (keys %chk_act_cage) {
            
            #-- of no active cage 
            if (!$chk_act_cage{$key}) {
                $json->{'Before'}.='<li>'.join(' => ', ($key, $chk_cage{$key}->[0]) ).'</li>';
            }
        }
        $json->{'Before'}.='</ul>';
    }
    
    $error=undef;

    foreach my $key (keys %chk_cage) {
        
        #-- of no active cage 
        if ($#{ $chk_cage{$key}}>0) {
            $error=1;
        }
    }
    
    if ($error) {
    
        $json->{'Before'}.=main::__("There are equal cages for different lines");

        $json->{'Before'}.='<ul>';
        
        foreach my $key (keys %chk_cage) {
            
            #-- of no active cage 
            if ($#{ $chk_cage{$key}}>0) {
                $json->{'Before'}.='<li>cage='.$key.': '. join(', ', @{$chk_cage{$key}} ).'</li>';
            }
        }
        $json->{'Before'}.='</ul>';
    }

    #-- check eventdt-1=birthdate otherwise it would have been a wrong dataset
    $sql="select 
             (select  distinct date_part('year', birth_dt) as birth_dt from v_active_animals_and_cages) as birth_dt,
             (select count(*) from animal where exit_dt isnull and db_cage isnull);
             ";

    #-- sql auslösen 
    $sql_ref = $apiis->DataBase->sys_sql( $sql );

    #-- fehlerbehandlung 
    if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
        $self->errors( $apiis->errors);
        $self->status(1);
        $apiis->status(1);
        goto EXIT;
    }   
   
    # auslesen des ergebnisses der datenbankabfrage
    my $birth_dt; my $act_animal_cage_null;
    while ( my $q = $sql_ref->handle->fetch ) {
        $birth_dt=$q->[0];
        $act_animal_cage_null=$q->[1];
    }

    my %hs_birth_dt; 
    foreach my $hs_record ( @{ $json->{ 'RecordSet' } } ) {

        my ($args);

        #-- daten aus hash holen
        foreach (keys %{ $hs_record->{ 'Data' } }) {
            $args->{$_}=$hs_record->{ 'Data' }->{$_}->[0];
        }

        my $year;
        ($year)=($args->{'event_dt'}=~/^..\...\.(....)/);

        $hs_birth_dt{$year}++;
    }

    if (!$birth_dt and $act_animal_cage_null>0) {
        push(@{$json->{ 'Critical'}},[main::__('There are [_1] active animals without a connection to a cage. You may have to run LO_DS06 first?', $act_animal_cage_null)]);
        $self->status(1);
        $apiis->status(1);
        goto EXIT_ALL;    

#    elsif () {    
#        my $link='<a target="_blank" href="/cgi-bin/GUI?user='.
#                 $apiis->{'_cgisave'}->{'user'}.'&sid='.$apiis->{'_cgisave'}->{'sid'}.'&m='.$apiis->{'_cgisave'}->{'m'}.'&o=htm2htm&g='.$apiis->{'_cgisave'}->{'g'}.'&importfilter=LO_DS11&filename=__sql__&onlycheck=ON&action=update&__form=/etc/enter_data/FileUpload.rpt">'.main::__('Follow this link to close animals (DS11)').'</a>';
#
##        push(@{$json->{ 'critical'}},[main::__('There are [_1] animals without cages', $act_animal_cage_null)]);
#        push(@{$json->{ 'Critical'}},[ $link ]);
#        goto EXIT_ALL;    
    }
    if (scalar keys %hs_birth_dt > 1) {
        push(@{$json->{ 'Critical'}},[main::__('Several years of birth in dataset [_1] or data has not format dd.mm.yyyy', $fileimport)]);
        $self->status(1);
        $apiis->status(1);
        goto EXIT_ALL;    
    }
    if (($birth_dt+1) ne (keys %hs_birth_dt)[0]) {
        push(@{$json->{ 'Critical'}},[main::__('Year of event [_1] do not corresponds to year of birth [_2] + 1 in file [_3]', (keys %hs_birth_dt)[0], $birth_dt,$fileimport)]);
        $self->status(1);
        $apiis->status(1);
        goto EXIT_ALL;    
    }

    #------------------------------------

    #-- Ab hier ist es egal, ob die Daten aus einer Datei
    #   oder aus einer Maske kommen
    #-- Schleife über alle Records und INFO füllen
    foreach my $hs_record ( @{ $json->{ 'RecordSet' } } ) {

        my ($args, $vcoll, $vinc, $vhat);

        #-- Daten aus Hash holen
        foreach (keys %{ $hs_record->{ 'Data' } }) {
            $args->{$_}=$hs_record->{ 'Data' }->{$_}->[0];
        }

        $args->{'ext_id'}=$args->{'cage'};


        if (!exists $breeds{ $args->{'ext_breed'} } ) {
            my $msg=main::__("Breed doesn't exists in database");
            push(@{$hs_record->{ 'Warn'}}, $msg);
        }

        if ($#{ $chk_cage{ $args->{'cage'} }} >0) {
            my $msg=main::__("There are equal cages for different lines");
            push(@{$hs_record->{ 'Warn'}}, $msg);
        }


        if (!$chk_act_cage{ $args->{'cage'} } ) {
            my $msg=main::__("There are cages without a connection to an active parent cage");
            push(@{$hs_record->{ 'Warn'}}, $msg);
        }

        #-- Get db for cage 
        $args->{'db_cage'} = GetDbUnit( $args );
    
        if (!$args->{'db_cage'}) {
            my $msg=main::__('There is no active cage with ID: '. $args->{'ext_id'} );
            push(@{$hs_record->{ 'Info'}}, $msg);
        }

        #-- Get data of a cage for checking 
        my $sql="select db_cage, db_event, guid, collected_eggs, incubated_eggs, hatched_eggs 
                 from hatch_cage  
                 where db_cage=$args->{'db_cage'}";

        #-- SQL auslösen 
        my $sql_ref = $apiis->DataBase->sys_sql( $sql );
        
        #-- Fehlerbehandlung 
        if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
            $self->errors( $apiis->errors);
            $self->status(1);
            $apiis->status(1);
            last EXIT;
        }
        
        # Auslesen des Ergebnisses der Datenbankabfrage
        while ( my $q = $sql_ref->handle->fetch ) {
            
            $args->{'guid'}=$q->[2];

            $vcoll=$q->[3];
            $vinc =$q->[4];
            $vhat =$q->[5];
        }    

        $vcoll=$args->{'collected_eggs'} if (exists $args->{'collected_eggs'});
        $vinc =$args->{'incubated_eggs'} if (exists $args->{'incubated_eggs'});
        $vhat =$args->{'hatched_eggs'}   if (exists $args->{'hatched_eggs'});

        my $action='insert';
        $hs_insert{'hatch_cage'}='insert';
        $hs_record->{ 'Insert' }->[ 0 ]= 'insert';

        if (exists $args->{'guid'}) {
            $action='update';
            $hs_record->{ 'Insert' }->[ 0 ]= $args->{'guid'};
            $hs_insert{'hatch_cage'}='update';
        }

        #-- mehr einer in der nachfolgenden Stufe las vorher 
        if (exists $args->{'guid'} and 
        ($vcoll and $vinc and ($vinc>$vcoll)) or
        ($vhat and $vinc  and ($vhat>$vinc)) or 
        ($vhat and $vcoll and ($vhat>$vcoll))) {
            
            if ($fileimport) {

                #-- Fehler in Info des Records schreiben
                push(@{$hs_record->{ 'Warn'}},"Wrong number: collected_eggs:$vcoll > incubated_eggs:$vinc > hatched_eggs: $vhat");

                #-- Fehler in Info des Records schreiben
                $apiis->status(0);
                $apiis->del_errors;
                next;
            }
            else {
                $self->status(1);
                $self->errors(
                    $err_ref = Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'WARN',
                        from       => 'LO_DS020304',
                        ext_fields => ['db_cage'],
                        msg_short =>
                            "Wrong number: collected_eggs:$vcoll > incubated_eggs:$vinc > hatched_eggs: $vhat"
                    )
                );
                $apiis->status(1);
                goto EXIT;
            }
        }

        #-- Wenn Daten aus den Forms DS03 und FDS04 kommen, müssen vorher Daten aus DS02 
        #-- gekommen sein. DS(03|04) können also nur updates sein. 
        #-- ob Daten aus DS(03|04) kommen, kann über die Eingabespalten abgefragt werden.  
        
        if (( $action eq 'insert') and !exists $args->{'collected_eggs'}) {
            
            if ($fileimport) {

                #-- Fehler in Info des Records schreiben
                push(@{$hs_record->{ 'Info'}},"Please run form DS02 before. Insert with form DS03 or DS04 not possible.");

                #-- Fehler in Info des Records schreiben
                $apiis->status(0);
                $apiis->del_errors;
                next;
            }
            else { 
                $self->status(1);
                $self->errors(
                    $err_ref = Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LO_DS020304',
                        ext_fields => ['db_cage'],
                        msg_short =>
                            "Please run form DS02 before. Insert with form DS03 or DS04 not possible."
                    )
                );
                $apiis->status(1);
                goto EXIT;
            }
        }

        #-- Alle Events sammeln und anlegen bzw. aus dem Hash holen für die,
        #   die schon angelegt wurden.
        
        #-- create ext event 
        $extevent="$args->{'ext_event_type'}:::$args->{'event_dt'}:::$args->{'ext_id_event'}";
#
#        #-- Wenn Event im Hash, dann interne Nummer des events holen
#        if ( exists $hs_event{ $extevent }
#            and ( $hs_event{ $extevent } ) ) {
#            $db_event = $hs_event{ $extevent };
#            $args->{'db_event'}=$db_event;
#        }
#
#        #-- Sonst Ladestrom füllen und Event anlegen bzw. db_event holen
#        else {

            #-- db_event holen bzw. anlegen
            $db_event = GetDbEvent( $args );

            $args->{'db_event'}=$db_event;

            #-- db_event in temp Speicher
            $hs_event{ $extevent } = $db_event;
#        }

        if ( !$db_event ) {

            #-- Sonderbehandlung bei einem File
            if ($fileimport) {

                #-- Fehler in Info des Records schreiben
                push(@{$hs_record->{ 'Info'}},$apiis->errors->[0]->msg_short);

                #-- Fehler in Info des Records schreiben
                $apiis->status(0);
                $apiis->del_errors;
                next;
            }
            else {
                $self->errors( $apiis->errors);
                $self->status(1);
                $apiis->status(1);
                goto EXIT;
            }
        }
        
        #-- open table unit via record-object
        my $hatch_cage= Apiis::DataBase::Record->new( tablename => 'hatch_cage' );

        #-- fill recordobject
        #-- intdata=internal number db_cage is db_unit see DataSource in form  
        $hatch_cage->column( 'db_cage' )->intdata( $args->{ 'db_cage'} );

        #-- info for recordobject: internal data havn't do translate from external to internal 
        $hatch_cage->column( 'db_cage' )->encoded( 1 );

        #-- if errors connect it to field db_cage in form 
        $hatch_cage->column( 'db_cage' )->ext_fields( qw/ ext_id / );

        #-- intdata=internal number db_cage is db_unit see DataSource in form  
        $hatch_cage->column( 'db_event' )->intdata( $args->{ 'db_event'} );

        #-- info for recordobject: internal data havn't do translate from external to internal 
        $hatch_cage->column( 'db_event' )->encoded( 1 );

        if (exists $args->{'collected_eggs'}) {
            $hatch_cage->column( 'collected_eggs' )->extdata( $args->{'collected_eggs'} );    
            $hatch_cage->column( 'collected_eggs' )->ext_fields( qw/ collected_eggs  / );    
        }

        if (exists $args->{'incubated_eggs'}) {
            $hatch_cage->column( 'incubated_eggs' )->extdata( $args->{'incubated_eggs'} );    
            $hatch_cage->column( 'incubated_eggs' )->ext_fields( qw/ incubated_eggs  / );    
        }
        if (exists $args->{'hatched_eggs'}) {
            $hatch_cage->column( 'hatched_eggs' )->extdata( $args->{'hatched_eggs'} );    
            $hatch_cage->column( 'hatched_eggs' )->ext_fields( qw/ hatched_eggs  / );    
            
        }
        if (exists $args->{'hatch_dt'}) {
            $hatch_cage->column( 'hatch_dt' )->extdata( $args->{'hatch_dt'} );    
            $hatch_cage->column( 'hatch_dt' )->ext_fields( qw/ hatch_dt  / );    
        }
        if (exists $args->{'far'}) {
            $hatch_cage->column( 'far_id' )->extdata( $args->{'far'} );    
            $hatch_cage->column( 'far_id' )->ext_fields( qw/ far  / );    
        }

        #-- send data to database 
        if ($action eq 'update') {

            $hatch_cage->column('guid')->intdata(  $args->{'guid'}  ) ;
            
            $hatch_cage->update();
        }
        else {
            
            $hatch_cage->insert();
        }

        #-- check for errors  
        if ( $hatch_cage->status ) {
            if ($fileimport) {

                #-- Fehler in Info des Records schreiben
                push(@{$hs_record->{ 'Info'}},$hatch_cage->errors->[0]->msg_long);

                #-- Fehler in Info des Records schreiben
                $apiis->status(0);
                $apiis->del_errors;
                next;
            }
            else {
                $self->status(1);
                $self->errors(
                    $err_ref = Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LO_DS020304',
                        ext_fields => ['db_cage'],
                        msg_short =>
                            "Error in update. Please try again or contact system administrator."
                    )
                );
                $apiis->status(1);
                goto EXIT;
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
     
EXIT_ALL:     

    if ($fileimport) {
        return $json;
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;
__END__

