#####################################################################
# load object: LO_DS07
# $Id: LO_DS07_1.pm,v 1.6 2022/04/01 13:16:31 lfgroene Exp $
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

sub LO_DS07_1 {
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

            #-- declare
            my @data;
            my $record;
            my $hs = {};

            #-- skip first record 
            next if ($.<2);

            #-- file

            $hs_fields->{'ahb'}     ={'ext_id'=>'cage', 'event_dt'=>'date', 'rooster_id'=>'4', 'rooster_body_wt'=>'5', 'hen1_body_wt'=>'6', 'hen2_body_wt'=>'7', 'hen3_body_wt'=>'8', 'hen4_body_wt'=>'9', 'hen5_body_wt'=>'10', 'hen6_body_wt'=>'11', 'hen7_body_wt'=>'12', 'hen8_body_wt'=>'13', 'hen9_body_wt'=>'14', 'hen10_body_wt'=>'15','birth_year'=>'16'};
                @field=('ext_id', 'event_dt', 'rooster_body_wt', 'hen1_body_wt', 'hen2_body_wt', 'hen3_body_wt', 'hen4_body_wt', 'hen5_body_wt', 'hen6_body_wt', 'hen7_body_wt', 'hen8_body_wt', 'hen9_body_wt', 'hen10_body_wt','birth_year');

            #-- alle Leerzeichen entfernen 
            $_=~s/\s+//g;

            @data = split(';', $_ ,28);

            #-- remove leading zeros or spaces and comma to dot
            map { $_ =~ s/^\s+//g; $_ =~ s/\s+$//g; $_=~s/,/./g; $_='' if (!$_) } @data;

            #-- skip if no cage-ID
            next if ( !$data[ 2 ] );
            next if ( $data[ 2 ] eq '' );

            #-- 0-Käfig raus
            next if ( $data[ 2 ] eq '0' );

            if ($data[0] < '30') {
                $data[0]='weighingbody20weeks';
            }
            else {
                $data[0]='weighingbody40weeks';
            }


            #-- define format for record 
            $record = {
                    'ext_unit_event'    => ['location', 'location',[] ],
                    'ext_id_event'      => ['Hvam','Hvam',[]],
                    'ext_unit'          => [ 'cage',  '',[] ], # externe unit
                    
                    'ext_event_type'    => [ $data[0],'',[] ],
                    
                    'event_dt'          => [ $data[ 1 ],'', [] ], # 

                    'ext_id'            => [ $data[2],'',[] ], # externe id
                    
                    'rooster_body_wt'      => [ $data[3],'',[] ],
                    'hen1_body_wt'      => [ $data[4],'',[] ],
                    'hen2_body_wt'      => [ $data[5],'',[] ],
                    'hen3_body_wt'      => [ $data[6],'',[] ],
                    'hen4_body_wt'      => [ $data[7],'',[] ],
                    'hen5_body_wt'      => [ $data[8],'',[] ],
                    'hen6_body_wt'      => [ $data[9],'',[] ],
                    'hen7_body_wt'      => [ $data[10],'',[] ],
                    'hen8_body_wt'      => [ $data[11],'',[] ],
                    'hen9_body_wt'      => [ $data[12],'',[] ],
                    'hen10_body_wt'     => [ $data[13],'',[] ],
                    'birth_year'        => [ $data[14],'',[] ],
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
    my $sql;
    my $current_year;
    my $vyear;
    my $history;
    my $sql_ref;

    #-- aktuelles Jahr holen
    $sql="select  date_part('year',birth_dt) as vyear,count(animal) from animal group by date_part('year',birth_dt) having count(animal)>50 order by vyear desc nulls last limit 1 ";
    
    #-- SQL auslösen 
    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    
    while ( my $q = $sql_ref->handle->fetch ) {
        $current_year=$q->[0]; 
    }
    
    if (exists $args->{'Fanimal_ext_id'} ) {

        ($vyear)=( $args->{'Fanimal_ext_id'}=~/Hvam(.*)/);

        $history=1 if ($vyear<$current_year);
    } 
    if (exists $json->{'RecordSet'}->[0]->{'Data'}->{'birth_year'} ) {

        $vyear=$json->{'RecordSet'}->[0]->{'Data'}->{'birth_year'}->[0];

        $history=1 if ($vyear<$current_year);
    } 
    
    #-- wenn historische Daten 
    if ($history) {
        $sql="select  user_get_ext_id(b.db_cage) as cage, count(db_animal) as nhens from v_animals_and_cages b left outer join hatch_cage a on a.db_cage=b.db_cage where date_part('year',birth_dt)='".$vyear."' and db_sex=(select db_code from codes where class='SEX' and ext_code='2') group by b.db_cage";
    }
    else {
        #-- Zuchten holen 
        $sql="select  user_get_ext_id(b.db_cage) as cage, count(db_animal) as nhens from v_active_animals_and_cages b left outer join hatch_cage a on a.db_cage=b.db_cage where db_sex=(select db_code from codes where class='SEX' and ext_code='2') group by b.db_cage";
    }

    #-- SQL auslösen 
    $sql_ref = $apiis->DataBase->sys_sql( $sql );

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
        for (my $k=0; $k<2; $k++) { 
        
            my $msg;
            my $extfield;
            my $msgtype='Info';

            #-- Interne cage-Id holen
            if ($k==0 ) {

                #-- wenn historische Daten geladen werden sollen, dann muss db_cage über das Geburtsjahr geholt werden 
                if ($history) {

                    #-- aktuelles Jahr holen
                    $sql="select user_get_old_db_cages('$args->{'ext_id'}','$vyear') ";        
                    
                    #-- SQL auslösen 
                    $sql_ref = $apiis->DataBase->sys_sql( $sql );
                    
                    while ( my $q = $sql_ref->handle->fetch ) {
                        $args->{'db_cage'}=$q->[0]; 
                    }
                }
                else {
                    $args->{'db_cage'} = GetDbUnit( $args );
                }
           
                if (!$args->{'db_cage'}) {
                    $msg=main::__('There is no active cage with ID: '. $args->{'ext_id'} );
                    $extfield='ext_id';
                }
            }   

            #--  more hens in file as in cage 
            elsif (($k==1) and $args->{'number_hens1'} and $hs_n_hens_per_cage{$args->{'ext_id'}} 
                           and ($hs_n_hens_per_cage{$args->{'ext_id'}} < $args->{'number_hens1'}) 
                           ) {
                $msg=main::__('Less hens in cage [_1] as in file: [_3]<[_2]', $args->{'ext_id'},$args->{'number_hens1'}, $hs_n_hens_per_cage{$args->{'ext_id'}});
                $msgtype='Warn';
                $extfield='number_hens1';
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

        #-- name of columns in header 
        $json->{'Tables'}=['rooster1','hen1','hen2','hen3','hen4','hen5','hen6','hen7','hen8','hen9','hen10'];
        $hs_record->{'Insert'}= ['-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-']; 

        my $hs_roosters;
        my $hs_guids;

        #-- number of eventtyps
        my $maxcnt=1;
        $maxcnt=1 if ($fileimport);

        for (my $i=0; $i<$maxcnt; $i++) {

            #-- Alle Events sammeln und anlegen bzw. aus dem Hash holen für die,
            #   die schon angelegt wurden.
            
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
                        $args->{'body_wt'}         = $args->{'rooster_body_wt'};

                    }
                    #-- hens 
                    else {
                        $args->{'hen_number'}          = $k;
                        $args->{'body_wt'}             = $args->{'hen'.$k.'_body_wt'};
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
     
    if ($fileimport) {
        return $json;
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;
__END__

