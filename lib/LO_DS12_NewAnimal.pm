#####################################################################
# load object: LO_NewAnimal
# $Id: LO_DS12_NewAnimal.pm,v 1.1 2021/01/09 08:22:37 lfgroene Exp $
#####################################################################
# This is the Load Object for a new record.
# events:
#           1. Insert new record into ANIMAL, TRANSFER
#
# Conditions:
# 1. The load object is one transevent: either it succeeds or
#    everything is rolled back.
# 2. The Load_object is aborted on the FIRST error.
#####################################################################
sub LO_NewAnimal {
    my $self     = shift;
    my $hash_ref = shift();
    my $err_ref;

    #    $hash_ref = {
    #        Tanimal_ext_unit   => '15-herdbuchnummer',
    #        Tanimal_ext_id     => '1-we06029',
    #        Tanimal_ext_animal => '3314',
    #        Vanimal_ext_unit   => '15-herdbuchnummer',
    #        Vanimal_ext_id     => '1-we06000',
    #        Vanimal_ext_animal => '4728',
    #        Manimal_ext_unit   => '15-herdbuchnummer',
    #        Manimal_ext_id     => '2-we06000',
    #        Manimal_ext_animal => '62953',
    #        sex                => '1',
    #        breed            => '6',
    #        birth_dt          => '15.01.2004',
    #    };

    #    require apiis_alib;

    ##################################################################
    # %data_hash must have the following keys from @LO_keys and the
    # appropriate values from the datastream:
    ##################################################################
    #    # some basic checks:
    #    my ( $err_status, $err_ref ) = main::CheckLO( $hash_ref, \@LO_keys );
    #    return ( $err_status, $err_ref ) if $err_status;
    ##################################################################

    $hash_ref->{'db_sire'} = 1;
    $hash_ref->{'db_dam'}  = 2;
    $hash_ref->{'db_breed_sire'} = '';
    $hash_ref->{'db_breed_dam'}  = '';

    #-- check for full animal number
    if ($hash_ref->{'Tanimal_ext_animal'} eq '') {
        #-- sonst Fehler 
        $self->status( 1 );
        $err_ref = Apiis::Errors->new(
            type      => 'CONFIG',
            severity  => 'ERR',
            from      => 'LO_NewAnimal',
             ext_fields => [ 'Tanimal_ext_animal' ],
            msg_short => __('Keine Tiernummer angegeben.'),
        );
        return ( $self->status, $err_ref );
    }

    EXIT: {
        for my $elter ( 'Tier' ) {
            my ( $ext_animal_field, $ext_unit_field, $ext_id_field );
            if ( $elter eq 'Vater' ) {
                $ext_animal       = $hash_ref->{'Vanimal_ext_animal'};
                $ext_unit         = lc( $hash_ref->{'Vanimal_ext_unit'} );
                $ext_id           = $hash_ref->{'Vanimal_ext_id'};
                $db_breed         = $hash_ref->{'db_breed_sire'};
                $ext_animal_field = 'Vanimal_ext_animal';
                $ext_unit_field   = 'Vanimal_ext_unit';
                $ext_id_field     = 'Vanimal_ext_id';
            }
            elsif ( $elter eq 'Mutter' ) {
                $ext_animal       = $hash_ref->{'Manimal_ext_animal'};
                $ext_unit         = lc( $hash_ref->{'Manimal_ext_unit'} );
                $ext_id           = $hash_ref->{'Manimal_ext_id'};
                $db_breed         = $hash_ref->{'db_breed_dam'};
                $ext_animal_field = 'Manimal_ext_animal';
                $ext_unit_field   = 'Manimal_ext_unit';
                $ext_id_field     = 'Manimal_ext_id';
            }
            else {
                $ext_animal       = $hash_ref->{'Tanimal_ext_animal'};
                $ext_unit         = lc( $hash_ref->{'Tanimal_ext_unit'} );
                $ext_id           = $hash_ref->{'Tanimal_ext_id'};
                $db_breed         = $hash_ref->{'breed'};
                $ext_animal_field = 'Tanimal_ext_animal';
                $ext_unit_field   = 'Tanimal_ext_unit';
                $ext_id_field     = 'Tanimal_ext_id';
            }

            #-- Skip, if no animal number
            next if ($ext_animal eq '');

            # Nachschauen, ob es das Tier in der Datenbank gibt
            my $transfer = Apiis::DataBase::Record->new( tablename => 'transfer', );
            $transfer->column('ext_animal')->extdata($ext_animal);
            $transfer->column('db_unit')->extdata( $ext_unit, $ext_id );
            my @q_transfers = $transfer->fetch(
                expect_rows    => 'one',
                expect_columns => qw/ db_animal /,
            );
            my $q_transfer = shift @q_transfers;
            my $db_animal = $q_transfer->column('db_animal')->intdata if ($q_transfer);

            if ( defined $db_animal ) {
                $hash_ref->{'db_sire'}   = $db_animal if ( $elter eq 'Vater' );
                $hash_ref->{'db_dam'}    = $db_animal if ( $elter eq 'Mutter' );
                $hash_ref->{'db_animal'} = $db_animal if ( $elter eq 'Tier' );
            }
            else {

                # now fill transfer record:
                my $now = $apiis->today;
                if ( ($ext_animal) and ( $ext_animal ne '' ) ) {


                    $transfer = Apiis::DataBase::Record->new( tablename => 'transfer', );
                
                    #-- db_animal wird nicht mit pre_insert gesetzt
                    my $db_animal=$apiis->DataBase->seq_next_val('seq_transfer__db_animal');

                    $transfer->column('db_animal')->intdata($db_animal);
                    $transfer->column('db_animal')->encoded(1);
                    
                    $transfer->column('db_unit')->extdata( $ext_unit, $ext_id );
                    $transfer->column('db_unit')->ext_fields( $ext_unit_field, $ext_id_field );

                    $transfer->column('ext_animal')->extdata($ext_animal);
                    $transfer->column('ext_animal')->ext_fields($ext_animal_field);

                    $transfer->column('opening_dt')->extdata($now);

                    $transfer->column('id_set')->extdata($ext_unit);

                    $transfer->insert();

                    if ( $transfer->status ) {
                        $self->status(1);
                        $err_ref = scalar $transfer->errors;
                        last EXIT;
                    } 

                    #-- übernahme db_animal  
                    $hash_ref->{'db_animal'}=$transfer->column('db_animal')->intdata();

                    my $animal = Apiis::DataBase::Record->new( tablename => 'animal', );
                    
                    $animal->column('db_animal')->intdata(  $hash_ref->{'db_animal'} );
                    $animal->column('db_animal')->encoded(1);
                    
                    if ( $elter eq 'Tier' ) {

                        $animal->column('db_sire')->intdata( $hash_ref->{'db_sire'} );
                        $animal->column('db_sire')->encoded(1);
                        $animal->column('db_dam')->intdata( $hash_ref->{'db_dam'} );
                        $animal->column('db_dam')->encoded(1);

                        $animal->column('db_sex')->intdata( $hash_ref->{'sex'} );
                        $animal->column('db_sex')->encoded(1);
                        $animal->column('db_sex')->ext_fields('sex');

                        $animal->column('db_breed')->intdata( $db_breed );
                        $animal->column('db_breed')->encoded(1);
                        $animal->column('db_breed')->ext_fields('breed');

                        $animal->column('birth_dt')->extdata( $hash_ref->{'birth_dt'} );
                        $animal->column('birth_dt')->ext_fields('birth_dt');
                    }
                    elsif ( $elter eq 'Vater' ) {
                        $hash_ref->{'db_sire'} = $db_animal;
                        $animal->column('db_breed')->intdata( $db_breed );
                        $animal->column('db_breed')->encoded(1);
                        $animal->column('db_breed')->ext_fields('breed');

                        $animal->column('db_sex')->extdata('1');
                        $animal->column('db_sire')->intdata('1');
                        $animal->column('db_sire')->encoded(1);
                        $animal->column('db_dam')->intdata('2');
                        $animal->column('db_dam')->encoded(1);
                    }
                    else {
                        $animal->column('db_breed')->intdata( $db_breed );
                        $animal->column('db_breed')->encoded(1);
                        $animal->column('db_breed')->ext_fields('breed');

                        $hash_ref->{'db_dam'} = $db_animal;
                        $animal->column('db_sex')->extdata('2');
                        $animal->column('db_sire')->intdata('1');
                        $animal->column('db_sire')->encoded(1);
                        $animal->column('db_dam')->intdata('2');
                        $animal->column('db_dam')->encoded(1);
                    }

                    $animal->insert;
                    if ( $animal->status ) {
                        $self->status(1);
                        $err_ref = scalar $animal->errors;
                        last EXIT;
                    }
                }
            }

            $self->status(0);
            $self->del_errors;
        }
    }

    if ( $self->status ) {
        $apiis->DataBase->dbh->rollback;
    }
    else {
        $apiis->DataBase->dbh->commit;
    }
    return ( $self->status, $err_ref );

}

1;

