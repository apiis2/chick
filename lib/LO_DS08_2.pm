#####################################################################
# load object: LO_DS08
# $Id: LO_DS08_2.pm,v 1.4 2022/04/01 13:16:31 lfgroene Exp $
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

sub LO_DS08_2 {

    use JSON;
    use URI::Escape;
    use GetDbEvent;
    use GetDbUnit;

    my $self = shift;
    my $args  = shift;

#TEST-DATA    
#    $args = {
#        db_event => '4',
#        db_cage  => '3080'  ,
#        number_hens => '10',
#        n_eggs => '5',
#        total_weight_eggs => '40',
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

    our $hs_animal;
    my @field;
    my $hs_fields={};
    my $fileimport;
    if (exists $args->{ 'FILE' }) {
        $fileimport=$args->{ 'FILE' };
    }
    my $onlycheck='off';
    if (exists $args->{ 'onlycheck' }) {
        $onlycheck=lc($args->{ 'onlycheck' });
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
            $hs_fields->{'ahb'}     ={'ext_breed'=>'breed','ext_id'=>'cage', 'event_dt1'=>'date_33_weeks','event_dt2'=>'date_53_weeks', 'number_hens1'=>'number_hens_33_weeks', 'total_weight_eggs1'=>'totalweigh_33_weeks', 'n_eggs1'=>'n_eggs_33_week', 'number_hens2'=>'number_hens_53_weeks', 'total_weight_eggs2'=>'totalweigh_53_weeks', 'n_eggs2'=>'n_eggs_53_week'};

            @field=('ext_breed', 'ext_id', 'event_dt1', 'number_hens1', 'total_weight_eggs1', 'n_eggs1', 'event_dt2', 'number_hens2', 'total_weight_eggs2', 'n_eggs2');

            @data = split(',', $_ ,10);

            #-- remove leading zeros or spaces and comma to dot
            map { $_ =~ s/^[0\s]+//g; $_ =~ s/\s+$//g;  $_=~s/,/./g; $_='' if (!$_) } @data;

            #-- skip if no cage-ID
            next if ( !$data[ 1 ] );
            next if ( $data[ 1 ] eq '' );

            #-- define format for record 
            $record = {
                    'ext_event_type1'   => ['weighingeggs33weeks','weighingeggs33weeks',[] ],
                    'ext_event_type2'   => ['weighingeggs53weeks','weighingeggs53weeks',[] ],
                    
                    'ext_unit_event'    => ['location', 'location',[] ],
                    'ext_id_event'      => ['Hvam','Hvam',[]],
                    'event_dt1'         => [ $data[ 2 ],'', [] ], # 
                    'event_dt2'         => [ $data[ 6 ],'', [] ], # 

                    'ext_breed'         => [ $data[0],'',[] ],
                    'ext_unit'          => [ 'cage',  '',[] ], # externe unit
                    'ext_id'            => [ $data[1],'',[] ], # externe id
                    'number_hens1'      => [ $data[3],'',[] ],
                    'total_weight_eggs1'=> [ $data[4],'',[] ],
                    'n_eggs1'           => [ $data[5],'',[] ],
                    'number_hens2'      => [ $data[7],'',[] ],
                    'total_weight_eggs2'=> [ $data[8],'',[] ],
                    'n_eggs2'           => [ $data[9],'',[] ],
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

         my $cnt++;
         if ($cnt==72) {
             print "kk";
         }

        #-- declare
        #-- drei checks 
        for (my $k=0; $k<5; $k++) { 
        
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

            #-- check for roosters in cage 
            elsif(($k==3) and $args->{'number_hens1'} and $args->{'total_weight_eggs1'} 
                          and ((($args->{'number_hens1'}*10) > $args->{'total_weight_eggs1'}) 
                          or   (($args->{'number_hens1'}*85) < $args->{'total_weight_eggs1'}))) {

                $msg=main::__('The total weight of eggs [_1] is outside the range [_2] - [_3] ', $args->{'total_weight_eggs1'}, $args->{'number_hens1'}*40, $args->{'number_hens1'}*75);
                    $extfield='total_weight_eggs1';
            }

            #-- check for roosters in cage 
            elsif(($k==4) and $args->{'number_hens2'} and $args->{'total_weight_eggs2'} 
                          and ((($args->{'number_hens2'}*40) > $args->{'total_weight_eggs2'}) 
                          or   (($args->{'number_hens2'}*75) < $args->{'total_weight_eggs2'}))) {

                $msg=main::__('The total weight of eggs [_1] is outside the range [_2] - [_3] ', $args->{'total_weight_eggs2'}, $args->{'number_hens2'}*40, $args->{'number_hens2'}*75);
                    $extfield='total_weight_eggs2';
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

        $json->{'Tables'}=['weighingeggs33weeks', 'weighingeggs53weeks'];
        $hs_record->{'Insert'}= ['-', '-' ];
      
        my $maxcnt=2;
        $maxcnt=1 if (!$fileimport);

        for (my $i=0; $i<$maxcnt; $i++) {

            if ($fileimport) {
                
                #-- remove 
                if ($i==0 ) {
                    $args->{'event_dt'}            = $args->{'event_dt1'};
                    $args->{'db_cage'}             = $args->{'db_cage'};
                    $args->{'number_hens'}         = $args->{'number_hens1'};
                    $args->{'n_eggs'}              = $args->{'n_eggs1'};
                    $args->{'total_weight_eggs'}   = $args->{'total_weight_eggs1'};
                    $args->{'ext_event_type'}      = $args->{'ext_event_type1'};
                }
                else {
                    $args->{'event_dt'}            = $args->{'event_dt2'};
                    $args->{'db_cage'}             = $args->{'db_cage'};
                    $args->{'number_hens'}         = $args->{'number_hens2'};
                    $args->{'n_eggs'}              = $args->{'n_eggs2'};
                    $args->{'total_weight_eggs'}   = $args->{'total_weight_eggs2'};
                    $args->{'ext_event_type'}      = $args->{'ext_event_type2'};
                }
            }

            #-- no data
            next if (($args->{'event_dt'} eq'') and ($args->{'number_hens'} eq '') and 
                     ($args->{'n_eggs'} eq '') and ($args->{'total_weight_eggs'} eq ''));

            #-- Alle Events sammeln und anlegen bzw. aus dem Hash holen für die,
            #   die schon angelegt wurden.
            
            #-- create ext event 
            $extevent="$args->{'ext_event_type'}:::$args->{'event_dt'}:::$args->{'ext_id_event'}";
            delete $args->{'db_event'};

            #-- Wenn Event im Hash, dann interne Nummer des events holen
            if ( exists $hs_event{ $extevent }
                and ( $hs_event{ $extevent } ) ) {
                $db_event = $hs_event{ $extevent };
                $args->{'db_event'}=$db_event;
            }

            #-- Sonst Ladestrom füllen und Event anlegen bzw. db_event holen
            else {

                #-- db_event holen bzw. anlegen
                $db_event = GetDbEvent( $args );

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

            #-- Check, ob insert oder update
            my $sql="select guid from eggs_cage where db_cage=".$args->{ 'db_cage'}." and db_event=".$args->{'db_event'};

            #-- SQL auslösen 
            my $sql_ref = $apiis->DataBase->sys_sql( $sql );
        
            #-- Fehlerbehandlung 
            if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
                $self->errors( $apiis->errors);
                $self->status(1);
                $apiis->status(1);
                goto EXIT;
            }   
            
            #-- Voreinstellung
            my $insert=main::__('Insert');
            
            # Auslesen des Ergebnisses der Datenbankabfrage
            while ( my $q = $sql_ref->handle->fetch ) {
                $insert         = $q->[0];
                $args->{'guid'} = $q->[0];
            }

            $hs_record->{'Insert'}->[$i]=$insert;

            #-- Gewicht des Hahnes wegschreiben 
            my $eggs_cage = Apiis::DataBase::Record->new( tablename => 'eggs_cage' );

            if ( $eggs_cage->status ) {

                $self->status(1);
                $err_ref = scalar $eggs_cage->errors;
                last EXIT;
            }

            $eggs_cage->column( 'db_event' )->intdata( $args->{ 'db_event'} );
            $eggs_cage->column( 'db_event' )->encoded( 1 );
            $eggs_cage->column( 'db_event' )->ext_fields( qw/ db_event / );

            $eggs_cage->column( 'db_cage' )->intdata( $args->{ 'db_cage'} );
            $eggs_cage->column( 'db_cage' )->encoded( 1 );
            $eggs_cage->column( 'db_cage' )->ext_fields( qw/ db_cage / );

            $eggs_cage->column( 'n_eggs' )->extdata( $args->{ 'n_eggs'} );
            $eggs_cage->column( 'n_eggs' )->ext_fields( qw/ n_eggs / );

            $eggs_cage->column( 'total_weight_eggs' )->extdata( $args->{ 'total_weight_eggs'} );
            $eggs_cage->column( 'total_weight_eggs' )->ext_fields( qw/ total_weight_eggs / );

            $eggs_cage->column( 'number_hens' )->extdata( $args->{ 'number_hens'} );
            $eggs_cage->column( 'number_hens' )->ext_fields( qw / number_hens / );

            if ($insert eq main::__('Insert')) {
                
                #-- neuen DS anlegen
                $eggs_cage->insert;
            }
            else {

                #-- guid
                if ($args->{ 'guid' } and ($args->{ 'guid' } ne '')) {
                    $eggs_cage->column( 'guid' )->extdata( $args->{ 'guid' } );
                }   

                #-- DS modifizieren
                $eggs_cage->update;
            }

            if ( $eggs_cage->status ) {

                $self->status(1);
                $err_ref = scalar $eggs_cage->errors;
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
     
    if ($fileimport) {
        return $json;
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;
__END__

