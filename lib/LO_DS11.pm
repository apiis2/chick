#####################################################################
# load object: LO_DS11
# $Id: LO_DS11.pm,v 1.5 2022/04/01 13:16:31 lfgroene Exp $
#####################################################################
# This is the Load Object to close an open unit.
#
#--  test-data
#    $args = {
#        db_cage  => '2692',
#    };
#
# Conditions:
# 1. The load object is one transevent: either it succeeds or
#    everything is rolled back.
# 2. The Load_object is aborted on the FIRST error.
#####################################################################

sub LO_DS11 {
    my $self     = shift;
    my $args     = shift;
    
    use JSON;
    use URI::Escape;
    use GetDbEvent;
    use GetDbUnit;

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

    my $db_animal;
    if (exists $args->{ 'db_animal' }) {
        $db_animal=$args->{ 'db_animal' };
    }

    #-- wenn ein file geladen werden soll, dann zuerst umwandeln in
    #   einen json-string, damit einheitlich weiterverarbeitet werden kann
            #-- file
    $hs_fields->{'ahb'}     ={'cagenumber'=>'cage', 'ext_sex'=>'sex','ext_animal'=>'wingnumber', 'ext_breed'=>'ext_breed'};

    @field=('ext_animal', 'birth_dt', 'ext_breed','exit_dt');

    $json = { 'Info'        => [],
                'RecordSet'   => [],
                'Bak'         => [],
                'Tables'      => ['animal'],
                };
    
    if ($db_animal) {
        $sql="update animal set exit_dt=current_date where db_animal=$db_animal";    
        $sql_ref = $apiis->DataBase->sys_sql( $sql );

        if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
            $self->errors( $apiis->errors);
            $self->status(1);
            $apiis->status(1);
        
            $apiis->DataBase->rollback;
        }
        else {
            $apiis->DataBase->commit;

            print '<h4>Animal closed.</h4>';
        }
        return ( $self->status, $self->errors );
    }    
    elsif ($fileimport and ($fileimport=~/__sql__/) ) {
        
        #-- aktuelles Jahr holen
        $sql="select user_get_ext_id_animal(db_animal), birth_dt, user_get_ext_code(db_breed, 'l'), birth_dt+365 from animal where exit_dt isnull and db_cage isnull";
        #-- SQL auslösen 
        $sql_ref = $apiis->DataBase->sys_sql( $sql );
        
        my $vext_id_animal;
        my $birthyear;
        while ( my $q = $sql_ref->handle->fetch ) {
            
            push( @{ $json->{ 'Bak' } },join(',',@$q) ); 
           
            #-- define format for record 
            $record = {
                    'ext_animal'      => [ $q->[ 0 ],'', [] ],  
                    'birth_dt'        => [ $q->[ 1 ],'', [] ],  
                    'ext_breed'       => [ $q->[ 2 ],'',[] ],
                    'exit_dt'         => [ $q->[ 3 ],'',[] ],
            };

            #-- datensatz mit neuen zeiger wegschreiben
            push( @{ $json->{ 'RecordSet' } },{ 'Info' => [], 'Data' => { %{$record} },'Insert'=>[]} );
        }
        
        $json->{ 'Fields'}  = [@field];
    }
    elsif ( $fileimport ) {

        
        #-- datei öffnen
        open(IN, "$fileimport" ) || die "error: kann $fileimport nicht öffnen";

        #-- schleife über alle datensätze
        while ( <IN> ) {
            
            push( @{ $json->{ 'Bak' } },$_); 
            
            #-- zeilenumbruch entfernen
            chomp();
            
            #-- declare
            my @data;
            my $record;
            my $hs = {};

            #-- skip first record 
            next if ($.<2);

            @data = split(',', $_ ,9);

            #-- remove leading zeros or spaces and comma to dot
            map { $_ =~ s/^\s+//g; $_ =~ s/\s+$//g;  $_=~s/,/./g; $_='' if (!$_) } @data;

            #-- skip if no cage-id
            next if ( !$data[ 2 ] );
            next if ( $data[ 2 ] eq '' );

            #-- define format for record 
            $record = {
                    'ext_animal'      => [ $q->[ 0 ],'', [] ],  
                    'birth_dt'           => [ $q->[ 1 ],'', [] ],  
                    'ext_breed'          => [ $q->[ 2 ],'',[] ],
            };

            #-- Datensatz mit neuen Zeiger wegschreiben
            push( @{ $json->{ 'RecordSet' } },{ 'Info' => [], 'Data' => { %{$record} },'Insert'=>[]} );
        }

        #-- datei schließen
        close( IN );
        
        $json->{ 'Fields'}  = [@field];
        
    }
    else {

        #-- string in einen hash umwandeln
        if (exists $args->{ 'JSON' }) {
            $json = from_json( $args->{ 'JSON' } );
        }
        else {
            $json={ 'RecordSet' => [{info=>[],'Data'=>{}}]};
            map { $json->{ 'RecordSet'}->[0]->{ 'Data' }->{$_}=[];
                  $json->{ 'RecordSet'}->[0]->{ 'Data' }->{$_}[0]=$args->{$_}} keys %$args;
        }
    }
    

    #------------------------------------

    #-- Ab hier ist es egal, ob die Daten aus einer Datei
    #   oder aus einer Maske kommen
    #-- Schleife über alle Records und INFO füllen
    foreach my $hs_record ( @{ $json->{ 'RecordSet' } } ) {

        #-- Daten aus Hash holen
        foreach (keys %{ $hs_record->{ 'Data' } }) {
            $args->{$_}=$hs_record->{ 'Data' }->{$_}->[0];
        }
    
        #-- Get data of a cage for checking 
        my $sql="select a.guid from animal a inner join transfer b on a.db_animal=b.db_animal inner join unit c on b.db_unit=c.db_unit where c.ext_id || '-' || b.ext_animal='$args->{'ext_animal'}'";
        
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
            
            $args->{'guid'}=$q->[0];
        }

        my $action='insert';
        $hs_insert{'animal'}='insert';
        $hs_record->{ 'Insert' }->[ 0 ]= 'insert';

        if (exists $args->{'guid'}) {
            $action='update';
            $hs_record->{ 'Insert' }->[ 0 ]= $args->{'guid'};
            $hs_insert{'animal'}='update';
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
                next;
            }
            else {
                $self->status(1);
                $err_ref = scalar $animal->errors;
                last EXIT;
            }
        }

        $animal->column( 'exit_dt' )->intdata( $args->{ 'exit_dt'} );
        $animal->column( 'exit_dt' )->ext_fields( qw/ exit_dt / );

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
        return $json;
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;
__END__

