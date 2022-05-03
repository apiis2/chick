#####################################################################
# load object: LO_DS01p
# $Id: LO_DS01p.pm,v 1.1 2016/04/14 06:54:05 ulm Exp $
#####################################################################
# This is the Load Object to close an open unit.
#
#--  test-data
#    $args = {
#        db_cage_id0..70  => '2692',
#        selected_cage0..70  => 'true',
#    };
#
# Conditions:
# 1. The load object is one transevent: either it succeeds or
#    everything is rolled back.
# 2. The Load_object is aborted on the FIRST error.
#####################################################################

sub LO_DS01p {
    my $self     = shift;
    my $args     = shift;
    
    my $err_ref;

    #-- loop over all fields from form
    for(my $i=0; $i<=70; $i++) {

        $args->{'selected_cage'} =$args->{'selected_cage'.'_id'.$i};
        $args->{'db_cage'}       =$args->{'db_cage'.'_id'.$i};

        #-- unit not close
        next if ($args->{'db_cage'} eq '');
        next if ($args->{'selected_cage'} eq 'true');

        #-- open table unit via record-object
        my $unit= Apiis::DataBase::Record->new( tablename => 'unit' );

        #-- fill recordobject
        #-- intdata=internal number db_cage is db_unit see DataSource in form  
        $unit->column( 'db_unit' )->intdata( $args->{ 'db_cage'} );

        #-- info for recordobject: internal data havn't do translate from external to internal 
        $unit->column( 'db_unit' )->encoded( 1 );

        #-- if errors connect it to field db_cage in form 
        $unit->column( 'db_unit' )->ext_fields( qw/ db_cage / );

        #-- get data from database where db_unit=db_cage
        #-- and get additional columns guid db_unit ext_unit ext_id closing_dt
        #-- guid is necessary to find the record in the database 
        my @fetch_unit = $unit->fetch(
            expect_rows => 'one',
            expect_columns => [qw/ guid db_unit ext_unit ext_id closing_dt/],
        );

        #-- check errors 
        if ( $unit->status ) {

            #-- write special error to general with $self->errors will worked on  
            $self->errors( scalar $unit->errors );

            #-- set to inform that there is an error 
            $self->status(1);

            goto EXIT;
        }
        
        #-- -1 means: SQL was true but no records was found 
        if ( $#fetch_unit == -1 ) {

            #-- set errorstatus 
            $self->status(1);

            #-- create error-object for forms 
            $self->errors(
                $err_ref = Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LO_DS01',
                    ext_fields => ['db_cage'],
                    msg_short =>
                        "There is no active cage with this ID.",
                )
            );
            $apiis->status(1);

            #-- break the routine 
            goto EXIT;
        }

        #--Loop over all records and close unit
        for my $rec (@fetch_unit) {

            #-- überspringen, wenn der Kanal bereits zu ist
            next if ( $rec->column('closing_dt')->intdata() );
        
            #-- set closing_dt 
            $rec->column( 'closing_dt' )->extdata( $apiis->now );

            #-- copy data from int to ext 
            $rec->column( 'ext_unit' )->extdata( $rec->column( 'ext_unit' )->intdata() );

            #-- copy data from int to ext 
            $rec->column( 'ext_id' )->extdata( $rec->column( 'ext_id' )->intdata() );

            #-- send data to database 
            $rec->update();
            
            #-- check for errors  
            if ( $rec->status ) {
                $self->status(1);
                $self->errors(
                    $err_ref = Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LO_DS01',
                        ext_fields => ['db_cage'],
                        msg_short =>
                            "Error in update. Please try again or contact system administrator."
                    )
                );
                $apiis->status(1);
                goto EXIT;
            }
        }   
    }
EXIT: 

    #-- if errors than rollback 
    if ( $self->status ) {
        $apiis->DataBase->dbh->rollback;
    }

    #-- otherwise transmit 
    else {
        $apiis->DataBase->dbh->commit;
    }

    #-- return error objects 
    return ( $self->status, $self->errors );
}

1;

