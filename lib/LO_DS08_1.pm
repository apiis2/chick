#####################################################################
# load object: LO_DS08
# $Id: LO_DS08_1.pm,v 1.7 2022/04/01 13:16:31 lfgroene Exp $
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

sub LO_DS08_1 {

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

            @field=('ext_id', 'event_dt', 'number_hens', 'total_weight_eggs', 'n_eggs');

            @data = split(';', $_ ,10);

            #-- remove leading zeros or spaces and comma to dot
            map { $_ =~ s/^[\s]+//g; $_ =~ s/\s+$//g;  $_=~s/,/./g; $_='' if (!$_) } @data;

            #-- skip if no cage-ID
            next if ( $data[ 0 ] eq '' );

            if ($data[5] eq '33') {
                $data[5]='weighingeggs33weeks';
            } 
            else {
                $data[5]='weighingeggs53weeks';
            }

            $hs_fields->{'ahb'}     ={'ext_id'=>'cage', 'event_dt'=>$data[5],'number_hens'=>'number_hens', 'total_weight_eggs'=>'totalweigh_eggs', 'n_eggs'=>'n_eggs'};

            #-- define format for record 
            $record = {
                    'ext_unit_event'    => ['location', 'location',[] ],
                    'ext_id_event'      => ['Hvam','Hvam',[]],
                    'ext_unit'          => [ 'cage',  '',[] ], # externe unit
                    
                    'ext_id'            => [ $data[0],'',[] ], # externe id
                    'n_eggs'            => [ $data[1],'',[] ],
                    'number_hens'       => [ $data[2],'',[] ],
                    'total_weight_eggs' => [ $data[3],'',[] ],
                    'event_dt'          => [ $data[4],'',[] ], 
                    'ext_event_type'    => [ $data[5],'',[] ],
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
        my $msgtype='Info';

        #-- Daten aus Hash holen
        foreach (keys %{ $hs_record->{ 'Data' } }) {
            $args->{$_}=$hs_record->{ 'Data' }->{$_}->[0];
        }

        my $cnt++;
#        if ($cnt==72) {
#             print "kk";
#         }

        #--three checks 
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
                    $msgtype='Err';
                }
            }   

            #--  more hens in file as in cage 
            elsif (($k==1) and $args->{'number_hens'} and $hs_n_hens_per_cage{$args->{'ext_id'}} 
                           and (($hs_n_hens_per_cage{$args->{'ext_id'}} < $args->{'number_hens'}) 
                           )) {
                $msg=main::__('Less hens in cage [_1] as in file: [_3]<[_2]', $args->{'ext_id'},$args->{'number_hens'}, $hs_n_hens_per_cage{$args->{'ext_id'}});
                $msgtype='Warn';
                $extfield='number_hens';
            }

            #-- check for roosters in cage 
            elsif(($k==2) and $args->{'number_hens'} and $args->{'total_weight_eggs'} 
                          and ((($args->{'number_hens'}*10) > $args->{'total_weight_eggs'}) 
                          or   (($args->{'number_hens'}*85) < $args->{'total_weight_eggs'}))) {

                $msg=main::__('The total weight of eggs [_1] is outside the range [_2] - [_3] ', $args->{'total_weight_eggs'}, $args->{'number_hens'}*40, $args->{'number_hens'}*75);
                    $extfield='total_weight_eggs';
            }

            #-- if error => $msg is defined 
            if ($msg and $fileimport) {

                #-- Fehler in Info des Records schreiben
                push(@{$hs_record->{ $msgtype}},$msg);

                #-- Fehler in Info des Records schreiben
                $apiis->status(0);
                $apiis->del_errors;
                if ($msgtype eq 'Err') {
                    next;
                }
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

        $json->{'Tables'}=['eggs_cage'];
        $hs_record->{'Insert'}= ['-' ];
      
        my $maxcnt=1;
        $maxcnt=1 if (!$fileimport);

        for (my $i=0; $i<$maxcnt; $i++) {

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

            #-- Gewicht der Eier wegschreiben 
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
        $apiis->status(0);
        $apiis->del_errors;
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

