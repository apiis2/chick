#####################################################################
# load object: LO_DS07
# $Id: LO_DS07_2.pm,v 1.3 2022/04/01 13:16:31 lfgroene Exp $
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
use strict;
use warnings;
our $apiis;

sub LO_DS07_2 {
    my $self     = shift;
    my $args     = shift;
 
    use GetDbUnit;
    use JSON;
    use URI::Escape;
    use GetDbEvent;

#TEST-DATA    
#    $args = {
#        db_cage  => '3080'  ,
#        db_event => '4',
#        body_wt_ptindiv => '12',
#        hen_number => '1',
#        body_wt1 => '12',
#    };


    my $json;
    my $err_ref;
    my $err_status;
    my @record;
    my $extevent;
    my %hs_cages_per_line;
    my %hs_found_cages_for_line;
            
    my %hs_event = ();
    my $db_event;
    my $event='1';

    our $hs_animal;
    my @field;
    my $hs_fields={};
    my $fileimport;
    my $filetype;

    if (exists $args->{ 'FILE' }) {
        $fileimport=$args->{ 'FILE' };
    }
    my $onlycheck='off';
    if (exists $args->{ 'onlycheck' }) {
        $onlycheck=lc($args->{ 'onlycheck' });
    }
    my $event_date;
    if (exists $args->{ 'event_date' }) {
        $event_date=$args->{ 'event_date' };
    }
    
    #-- Wenn ein File geladen werden soll, dann zuerst umwandeln in
    #   einen JSON-String, damit einheitlich weiterverarbeitet werden kann
    if ( $fileimport ) {

        #-- Datei öffnen
        open( IN, "$fileimport" ) || die "error: kann $fileimport nicht öffnen";

        $json = { 'Info'        => [],
                  'RecordSet'   => [],
                  'Bak'         => [],
                };

        #-- Schleife über alle Datensätze
        while ( <IN> ) {

            push( @{ $json->{ 'Bak' } },$_); 
            
            #-- Zeilenumbruch entfernen
            chomp();

            $filetype='csv' if ($_=~/(veining)/ and !$filetype);
            $filetype='ds'  if ($_=~/(weighing)/ and !$filetype);
            $event   ='2'   if ($_=~/(veining 40 uke|weighing_date_40)/ and !$event);
            $event   ='3'   if ($_=~/(veining 20 uke|weighing_date_20).*?(veining 40 uke|weighing_date_40)/  and !$event) ;

            #-- declare
            my @data;
            my $record;
            my $hs = {};

            #-- skip first record 
            next if ($.<2);

            #-- file

            if (( $filetype eq 'csv') and ($event eq '1') ) {
#                $hs_fields->{'ahb'}     ={'ext_breed'=>'breed', 'ext_id'=>'cage', 'event_dt0'=>'date', 'rooster_id0'=>'4', 'rooster_body_wt_20_weeks'=>'5', 'hen1_body_wt_20_weeks'=>'6', 'hen2_body_wt_20_weeks'=>'7', 'hen3_body_wt_20_weeks'=>'8', 'hen4_body_wt_20_weeks'=>'9', 'hen5_body_wt_20_weeks'=>'10', 'hen6_body_wt_20_weeks'=>'11', 'hen7_body_wt_20_weeks'=>'12', 'hen8_body_wt_20_weeks'=>'13', 'hen9_body_wt_20_weeks'=>'14', 'hen10_body_wt_20_weeks'=>'15'};
                @field=('ext_breed', 'ext_id', 'event_dt0', 'rooster_id0', 'rooster_body_wt_20_weeks', 'hen1_body_wt_20_weeks', 'hen2_body_wt_20_weeks', 'hen3_body_wt_20_weeks', 'hen4_body_wt_20_weeks', 'hen5_body_wt_20_weeks', 'hen6_body_wt_20_weeks', 'hen7_body_wt_20_weeks', 'hen8_body_wt_20_weeks', 'hen9_body_wt_20_weeks', 'hen10_body_wt_20_weeks');
            }
            elsif (( $filetype eq 'csv') and ($event eq '2') ) {
#                $hs_fields->{'ahb'}     ={'ext_breed'=>'breed', 'ext_id'=>'cage', 'event_dt1'=>'3', 'rooster'=>'4', 'rooster_body_wt_40_weeks'=>'5', 'hen1_body_wt_40_weeks'=>'6', 'hen2_body_wt_40_weeks'=>'7', 'hen3_body_wt_40_weeks'=>'8', 'hen4_body_wt_40_weeks'=>'9', 'hen5_body_wt_40_weeks'=>'10', 'hen6_body_wt_40_weeks'=>'11', 'hen7_body_wt_40_weeks'=>'12', 'hen8_body_wt_40_weeks'=>'13', 'hen9_body_wt_40_weeks'=>'14', 'hen10_body_wt_40_weeks'=>'13'};
                @field=('breed', 'ext_id', 'event_dt1', 'rooster', 'rooster_body_wt_40_weeks', 'hen1_body_wt_40_weeks', 'hen2_body_wt_40_weeks', 'hen3_body_wt_40_weeks', 'hen4_body_wt_40_weeks', 'hen5_body_wt_40_weeks', 'hen6_body_wt_40_weeks', 'hen7_body_wt_40_weeks', 'hen8_body_wt_40_weeks', 'hen9_body_wt_40_weeks', 'hen10_body_wt_40_weeks');
            }
            else {
#                $hs_fields->{'ahb'}     ={'ext_breed'=>'breed', 'ext_id'=>'cage', 'event_dt0'=>'date', 'rooster'=>'4', 'rooster_body_wt_20_weeks'=>'5', 'hen1_body_wt_20_weeks'=>'6', 'hen2_body_wt_20_weeks'=>'7', 'hen3_body_wt_20_weeks'=>'67', 'hen4_body_wt_20_weeks'=>'9', 'hen5_body_wt_20_weeks'=>'', 'hen6_body_wt_20_weeks'=>'', 'hen7_body_wt_20_weeks'=>'', 'hen8_body_wt_20_weeks'=>'', 'hen9_body_wt_20_weeks'=>'', 'hen10_body_wt_20_weeks'=>'', 'event_dt1'=>'', 'rooster'=>'', 'rooster_body_wt_40_weeks'=>'', 'hen1_body_wt_40_weeks'=>'', 'hen2_body_wt_40_weeks'=>'', 'hen3_body_wt_40_weeks'=>'', 'hen4_body_wt_40_weeks'=>'', 'hen5_body_wt_40_weeks'=>'', 'hen6_body_wt_40_weeks'=>'', 'hen7_body_wt_40_weeks'=>'', 'hen8_body_wt_40_weeks'=>'', 'hen9_body_wt_40_weeks'=>'', 'hen10_body_wt_40_weeks'=>'22'};

                @field=('ext_breed', 'ext_id', 'event_dt0', 'rooster_id0', 'rooster_body_wt_20_weeks', 'hen1_body_wt_20_weeks', 'hen2_body_wt_20_weeks', 'hen3_body_wt_20_weeks', 'hen4_body_wt_20_weeks', 'hen5_body_wt_20_weeks', 'hen6_body_wt_20_weeks', 'hen7_body_wt_20_weeks', 'hen8_body_wt_20_weeks', 'hen9_body_wt_20_weeks', 'hen10_body_wt_20_weeks', 'event_dt1', 'rooster', 'rooster_body_wt_40_weeks', 'hen1_body_wt_40_weeks', 'hen2_body_wt_40_weeks', 'hen3_body_wt_40_weeks', 'hen4_body_wt_40_weeks', 'hen5_body_wt_40_weeks', 'hen6_body_wt_40_weeks', 'hen7_body_wt_40_weeks', 'hen8_body_wt_40_weeks', 'hen9_body_wt_40_weeks', 'hen10_body_wt_40_weeks');
            }



            #-- alle Leerzeichen entfernen 
            $_=~s/\s+//g;

            @data = split(',', $_ ,28);

            #-- remove leading zeros or spaces and comma to dot
            map { $_ =~ s/^[0\s]+//g; $_ =~ s/\s+$//g; $_='' if (!$_) } @data;

            #-- wenn wägedaten 
            if ($filetype eq 'csv') {

                #-- umspeichern der Daten  
                my @datacsv=@data;
                
                #-- leeren des arrays, damit es neu gefüllt werden kann 
                @data=();

                $data[1]=$datacsv[1];

                if (($event eq '1' ) or ($event eq '3')) {
                    $data[2]=$event_date;
                    $data[4]=$datacsv[2];
                    $data[5]=$datacsv[3];
                    $data[6]=$datacsv[4];
                    $data[7]=$datacsv[5];
                    $data[8]=$datacsv[6];
                    $data[9]=$datacsv[7];
                    $data[10]=$datacsv[8];
                    $data[11]=$datacsv[9];
                    $data[12]=$datacsv[10];
#                    $data[13]=$datacsv[12];
                }
               
                if (($event eq '2' ) or ($event eq '3')) {
                    $data[15]=$event_date;
                    $data[17]=$datacsv[2];
                    $data[18]=$datacsv[2];
                    $data[19]=$datacsv[3];
                    $data[20]=$datacsv[4];
                    $data[21]=$datacsv[5];
                    $data[22]=$datacsv[6];
                    $data[23]=$datacsv[7];
                    $data[24]=$datacsv[8];
                    $data[25]=$datacsv[9];
                    $data[26]=$datacsv[10];
                    $data[27]=$datacsv[12];
                }
            }

            #-- skip if no cage-ID
            next if ( !$data[ 1 ] );
            next if ( $data[ 1 ] eq '' );

            #-- define format for record 
            $record = {
                    'ext_event_type0'   => ['weighingbody20weeks','weighingbody20weeks',[] ],
                    'ext_event_type1'   => ['weighingbody40weeks','weighingbody40weeks',[] ],
                    
                    'ext_unit_event'    => ['location', 'location',[] ],
                    'ext_id_event'      => ['Hvam','Hvam',[]],
                    'event_dt0'         => [ $data[ 2 ],'', [] ], # 
                    'event_dt1'         => [ $data[ 15 ],'', [] ], # 

                    'ext_breed'         => [ $data[0],'',[] ],
                    'ext_unit'          => [ 'cage',  '',[] ], # externe unit
                    'ext_id'            => [ $data[1],'',[] ], # externe id
                    
                    'rooster_id0'      => [ $data[3],'',[] ],
                    'rooster_id1'      => [ $data[16],'',[] ],

                    'rooster_body_wt_20_weeks'      => [ $data[4],'',[] ],
                    'hen1_body_wt_20_weeks'      => [ $data[5],'',[] ],
                    'hen2_body_wt_20_weeks'      => [ $data[6],'',[] ],
                    'hen3_body_wt_20_weeks'      => [ $data[7],'',[] ],
                    'hen4_body_wt_20_weeks'      => [ $data[8],'',[] ],
                    'hen5_body_wt_20_weeks'      => [ $data[9],'',[] ],
                    'hen6_body_wt_20_weeks'      => [ $data[10],'',[] ],
                    'hen7_body_wt_20_weeks'      => [ $data[11],'',[] ],
                    'hen8_body_wt_20_weeks'      => [ $data[12],'',[] ],
                    'hen9_body_wt_20_weeks'      => [ $data[13],'',[] ],
                    'hen10_body_wt_20_weeks'      => [ $data[14],'',[] ],
                    
                    'rooster_body_wt_40_weeks'      => [ $data[17],'',[] ],
                    'hen1_body_wt_40_weeks'      => [ $data[18],'',[] ],
                    'hen2_body_wt_40_weeks'      => [ $data[19],'',[] ],
                    'hen3_body_wt_40_weeks'      => [ $data[20],'',[] ],
                    'hen4_body_wt_40_weeks'      => [ $data[21],'',[] ],
                    'hen5_body_wt_40_weeks'      => [ $data[22],'',[] ],
                    'hen6_body_wt_40_weeks'      => [ $data[23],'',[] ],
                    'hen7_body_wt_40_weeks'      => [ $data[24],'',[] ],
                    'hen8_body_wt_40_weeks'      => [ $data[25],'',[] ],
                    'hen9_body_wt_40_weeks'      => [ $data[26],'',[] ],
                    'hen10_body_wt_40_weeks'      => [ $data[27],'',[] ],
            };

            #-- Datensatz mit neuen Zeiger wegschreiben
            push( @{ $json->{ 'RecordSet' } },{ 'Info' => [], 'Data' => { %{$record} },'Insert'=>[]} );
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

    #--------------------- CHECKS
    
    #-- creates a hash to count how many hens are in a cage to check the input
    #-- must be >0
    my %hs_n_hens_per_cage;

    #-- Zuchten holen 
    my $sql="select  user_get_ext_id(b.db_cage) as cage, count(db_animal) as nhens from v_active_animals_and_cages b left outer join hatch_cage a on a.db_cage=b.db_cage where db_sex=(select db_code from codes where class='SEX' and ext_code='2') group by b.db_cage";

    #-- SQL auslösen 
    my $sql_ref = $apiis->DataBase->sys_sql( $sql );

    #-- Fehlerbehandlung 
    if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
        $self->errors( $apiis->errors);
        $self->status(1);
        $apiis->status(1);
        goto EXIT;
    }   
    
    # Auslesen des Ergebnisses der Datenbankabfrage
    while ( my $q = $sql_ref->handle->fetch ) {
        $hs_n_hens_per_cage{$q->[0]}=$q->[1];
    }
    #------------------------------------

    #-- Ab hier ist es egal, ob die Daten aus einer Datei
    #   oder aus einer Maske kommen
    #-- Schleife über alle Records und INFO füllen
    foreach my $hs_record ( @{ $json->{ 'RecordSet' } } ) {

        my $args;

        #-- Daten aus Hash holen
        foreach (keys %{ $hs_record->{ 'Data' } }) {
            $args->{$_}=$hs_record->{ 'Data' }->{$_}->[0];
        }

        #-- declare
        #-- drei checks 
        for (my $k=0; $k<3; $k++) { 
        
            my $msg;
            my $extfield;
            my $msgtype='Info';

            #-- Interne cage-Id holen
            if ($k==0 ) {
                $args->{'db_cage'} = GetDbUnit( $args );
           
                if (!$args->{'db_cage'}) {
                    $msg=main::__('There is no active cage with ID: '. $args->{'ext_id'} );
                    $extfield='ext_id';
                }
            }   

            #--  more hens in file as in cage 
            elsif (($k==1) and $args->{'number_hens1'} and $hs_n_hens_per_cage{$args->{'ext_id'}} 
                           and (($hs_n_hens_per_cage{$args->{'ext_id'}} < $args->{'number_hens1'}) 
                           and  ($args->{'number_hens2'} eq ''))) {
                $msg=main::__('Less hens in cage [_1] as in file: [_3]<[_2]', $args->{'ext_id'},$args->{'number_hens1'}, $hs_n_hens_per_cage{$args->{'ext_id'}});
                    $extfield='number_hens1';
            }

            #--  more hens in file as in cage 
            elsif (($k==2) and $hs_n_hens_per_cage{$args->{'ext_id'}} and $args->{'number_hens2'} 
                     and ($hs_n_hens_per_cage{$args->{'ext_id'}} < $args->{'number_hens2'})) {
                $msg=main::__('Less hens in cage [_1] as in file: [_3]<[_2]', $args->{'ext_id'},$args->{'number_hens2'}, $hs_n_hens_per_cage{$args->{'ext_id'}});
                    $extfield='number_hens2';
                    $msgtype='Warn';
            }

            #-- if error => $msg is defined 
            if ($msg and $fileimport) {

                #-- Fehler in Info des Records schreiben
                push(@{$hs_record->{ $msgtype}},$msg);

                #-- Fehler in Info des Records schreiben
                $apiis->status(0);
                $apiis->del_errors;
                next;
            }
            elsif($msg) {
                #-- set errorstatus 
                $self->status(1);

                #-- create error-object for forms 
                $self->errors(
                    $err_ref = Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LO_DS08',
                        ext_fields => [$extfield],
                        msg_short =>$msg,
                    )
                );
                $apiis->status(1);

                #-- break the routine 
                goto EXIT;
            }
        }

        #-----------------------------------------------------------------
        # close unit

        if (( $filetype eq 'csv') and ($event eq '1') ) {
        #-- name of columns in header 
            $json->{'Tables'}=['rooster1-20','hen1-20','hen2-20','hen3-20','hen4-20','hen5-20','hen6-20','hen7-20','hen8-20','hen9-20','hen10-20'];
            $hs_record->{'Insert'}= ['-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-']; 
        }
        elsif (( $filetype eq 'csv') and ($event eq '2') ) {
             $json->{'Tables'}=['rooster2-40','hen1-40','hen2-40','hen3-40','hen4-40','hen5-40','hen6-40','hen7-40','hen8-40','hen9-40','hen10-40'];
            $hs_record->{'Insert'}= ['-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-']; 
        }
        elsif (( $filetype eq 'csv') and ($event eq '3') ) {
            $json->{'Tables'}=['rooster1-20','hen1-20','hen2-20','hen3-20','hen4-20','hen5-20','hen6-20','hen7-20','hen8-20','hen9-20','hen10-20','rooster2-40','hen1-40','hen2-40','hen3-40','hen4-40','hen5-40','hen6-40','hen7-40','hen8-40','hen9-40','hen10-40'];
            $hs_record->{'Insert'}= ['-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-','-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-']; 
        }

        my $hs_roosters;
        my $hs_guids;

        #-- number of eventtyps
        my $maxcnt=2;
        $maxcnt=1 if ($fileimport);

        for (my $i=0; $i<$maxcnt; $i++) {

            #-- default for week 
            my $week='20';
            $week='40' if ($i eq '1');

            #-- Alle Events sammeln und anlegen bzw. aus dem Hash holen für die,
            #   die schon angelegt wurden.
            
            if ($fileimport) {
                    
                #-- remove 
                $args->{'event_dt'}            = $args->{'event_dt'.$i};
                $args->{'ext_event_type'}      = $args->{'ext_event_type'.$i};
                $args->{'db_cage'}             = $args->{'db_cage'};
            }

            #-- create ext event 
            $extevent="$args->{'ext_event_type'}:::$args->{'event_dt'}:::$args->{'ext_id_event'}";
            delete $args->{'db_event'};

            #-- Wenn Event im Hash, dann interne Nummer des events holen
            if ( ($onlycheck eq 'off') and exists $hs_event{ $extevent } and ( $hs_event{ $extevent } ) ) {
                $db_event = $hs_event{ $extevent };
                $args->{'db_event'}=$db_event;
            }

            #-- Sonst Ladestrom füllen und Event anlegen bzw. db_event holen
            else {

                #-- db_event holen bzw. anlegen
                $db_event = GetDbEvent( $args, 'yes' );

                $args->{'db_event'}=$db_event;

                #-- db_event in temp Speicher
                $hs_event{ $extevent } = $db_event;
            }

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
            
            #-- loop over 1 rooster and 10 hens 
            for (my $k=0; $k<11; $k++) {
                
                if ($fileimport) {
                    
                    #-- 0 eq rooster 
                    if ($k==0) {
                        $args->{'animal'}          = '';
                        $args->{'body_wt'}         = $args->{'rooster_body_wt_'.$week.'_weeks'};

                    }
                    #-- hens 
                    else {
                        $args->{'hen_number'}          = $k;
                        $args->{'body_wt'}             = $args->{'hen'.$k.'_body_wt_'.$week.'_weeks'};
                    }
                }

                #-- no data
                next if (!$args->{'event_dt'} or !$args->{'body_wt'} or ($args->{'event_dt'} eq '') or ($args->{'body_wt'} eq ''));
            

                if ($k==0) {
                    
                    #-- Check, ob insert oder update
                    
                    #-- hole das männliche Tier des angegebenen Cages 
                    my $sql1="select db_animal from animal where db_cage=$args->{'db_cage'} and db_sex=(select db_code from codes where class='SEX' and ext_code='1')";

                    #-- SQL auslösen 
                    my $sql_ref = $apiis->DataBase->sys_sql( $sql1 );
                    
                    #-- Fehlerbehandlung 
                    if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
                       
                        #-- Sonderbehandlung bei einem File
                        if ($fileimport) {

                            #-- Fehler in Info des Records schreiben
                            push(@{$hs_record->{ 'Info'}},$sql_ref->errors->[0]->msg_short);

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
                    
                    # Auslesen des Ergebnisses der Datenbankabfrage
                    while ( my $q = $sql_ref->handle->fetch ) {
                        
                        #-- flag für Fehlermeldung 
                        $args->{'db_animal'}=$q->[0];
                    }
                    
                    $sql="select guid from pt_indiv where db_cage=".$args->{ 'db_cage'}." and db_event=".$args->{'db_event'};
                }
                else {
                    $sql="select guid from pt_cage where db_cage=".$args->{ 'db_cage'}." and db_event=".$args->{'db_event'}
                        ." and hen_number='". $k ."'";
                }

                #-- SQL auslösen 
                my $sql_ref = $apiis->DataBase->sys_sql( $sql );
            
                #-- Fehlerbehandlung 
                if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {

                    #-- Sonderbehandlung bei einem File
                    if ($fileimport) {

                        #-- Fehler in Info des Records schreiben
                        push(@{$hs_record->{ 'Info'}},$sql_ref->errors->[0]->msg_short);

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
            
                #-- Voreinstellung
                my $insert=main::__('Insert');
                
                # Auslesen des Ergebnisses der Datenbankabfrage
                while ( my $q = $sql_ref->handle->fetch ) {
                    $insert         = $q->[0];
                    $args->{'guid'} = $q->[0];
                }

                $hs_record->{'Insert'}->[ $i*10+$k+$i*1 ]=$insert;

           
            if ($k==0) {
                #-- Gewicht des Hahnes wegschreiben 
                my $pt_indiv = Apiis::DataBase::Record->new( tablename => 'pt_indiv' );


                $pt_indiv->column( 'db_animal' )->intdata( $args->{ 'db_animal'} );
                $pt_indiv->column( 'db_animal' )->encoded( 1 );

                $pt_indiv->column( 'db_event' )->intdata( $args->{ 'db_event'} );
                $pt_indiv->column( 'db_event' )->encoded( 1 );
                $pt_indiv->column( 'db_event' )->ext_fields( qw/ db_event / );

                $pt_indiv->column( 'db_cage' )->intdata( $args->{ 'db_cage'} );
                $pt_indiv->column( 'db_cage' )->encoded( 1 );
                $pt_indiv->column( 'db_cage' )->ext_fields( qw/ db_cage / );

                $pt_indiv->column( 'body_wt' )->extdata( $args->{ 'body_wt'} );
                $pt_indiv->column( 'body_wt' )->ext_fields( qw/ body_wt / );

                if ($insert eq main::__('Insert')) {
                    
                    #-- neuen DS anlegen
                    $pt_indiv->insert;
                }
                else {

                    #-- guid
                    if ($args->{ 'guid' } and ($args->{ 'guid' } ne '')) {
                        $pt_indiv->column( 'guid' )->extdata( $args->{ 'guid' } );
                    }   

                    #-- DS modifizieren
                    $pt_indiv->update;
                }

                if ( $pt_indiv->status ) {

                    #-- Sonderbehandlung bei einem File
                    if ($fileimport) {

                        $hs_record->{'Insert'}->[ $i*10+$k+$i*1 ]='-';

                        #-- Fehler in Info des Records schreiben
                        push(@{$hs_record->{ 'Info'}},$pt_indiv->errors->[0]->msg_short.', '.$pt_indiv->errors->[0]->msg_long);

                        #-- Fehler in Info des Records schreiben
                        $apiis->status(0);
                        $apiis->del_errors;
                        next;
                    }
                    else {
                        $self->errors( $pt_indiv->errors);
                        $self->status(1);
                        $apiis->status(1);
                        goto EXIT;
                    }
                }
            }
            else {

                #-- weibliche Gewichte abspeichern
                my $pt_cage = Apiis::DataBase::Record->new( tablename => 'pt_cage' );

                $pt_cage->column( 'db_event' )->intdata( $args->{ 'db_event'} );
                $pt_cage->column( 'db_event' )->encoded( 1 );
                $pt_cage->column( 'db_event' )->ext_fields( qw/ db_event / );

                $pt_cage->column( 'db_cage' )->intdata( $args->{ 'db_cage'} );
                $pt_cage->column( 'db_cage' )->encoded( 1 );
                $pt_cage->column( 'db_cage' )->ext_fields( qw/ db_cage / );

                $pt_cage->column( 'hen_number' )->extdata( $k );

                $pt_cage->column( 'body_wt' )->extdata( $args->{ 'body_wt' } );
                $pt_cage->column( 'body_wt' )->ext_fields( 'body_wt'  );

                if ($insert eq main::__('Insert')) {
                    
                    #-- neuen DS anlegen
                    $pt_cage->insert;
                }
                else {

                    #-- guid
                    if ($args->{ 'guid' } and ($args->{ 'guid' } ne '')) {
                        $pt_cage->column( 'guid' )->extdata( $args->{ 'guid' } );
                    }   

                    #-- DS modifizieren
                    $pt_cage->update;
                }

                if ( $pt_cage->status ) {

                    $hs_record->{'Insert'}->[ $i*10+$k+$i*1 ]='-';

                    #-- Sonderbehandlung bei einem File
                    if ($fileimport) {

                        #-- Fehler in Info des Records schreiben
                        push(@{$hs_record->{ 'Info'}},$pt_cage->errors->[0]->msg_short);

                        #-- Fehler in Info des Records schreiben
                        $apiis->status(0);
                        $apiis->del_errors;
                        next;
                    }
                    else {
                        $self->errors( $pt_cage->errors);
                        $self->status(1);
                        $apiis->status(1);
                        goto EXIT;
                    }
                }
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
    }
     
    if ($fileimport) {
        return $json;
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;
__END__

