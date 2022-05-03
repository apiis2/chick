#!/usr/bin/perl
use strict;
use warnings;

BEGIN {
   use Env qw( APIIS_HOME );
   die "\n\tAPIIS_HOME is not set!\n\n" unless $APIIS_HOME;
   push @INC, "$APIIS_HOME/lib";
}
use Apiis;
use Apiis::DataBase::User;
Apiis->initialize( VERSION => '$Revision: 1.2 $' );

use lib '~/database_stuff/chick/lib';
use GetDbEvent;

my $testuser = Apiis::DataBase::User->new(
   id       => 'lfgroene',
   password => 'agrum1',
);
$testuser->check_status;
$apiis->join_model('chick', userobj => $testuser );
$apiis->check_status;
no strict "refs";
my $args;

my $sql="select b.db_cage, a.birth_dt, a.birth_dt+47*7 from animal a inner join (select db_animal, user_get_ext_code(db_sex,'e'),db_cage from animal where user_get_ext_code(db_sex,'e')='1') as b on a.db_animal=b.db_animal order by b.db_cage desc;";

#-- SQL auslösen 
my $sql_ref = $apiis->DataBase->sys_sql( $sql );
        
        
#-- Fehlerbehandlung 

if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {

    $apiis->status(1);
    print $apiis->errors-[0]->print;
    exit;
}

my $event_dt;

# Auslesen des Ergebnisses der Datenbankabfrage
while ( my $q = $sql_ref->handle->fetch ) {
        
        my $args;

        $args->{'db_cage'}=$q->[0];
        
        $args->{'event_dt'}=$q->[2];
        $args->{'ext_event_type'}='eggs_for_hatching';
        $args->{'ext_id_event'}='Hvam';        
        $args->{'ext_unit_event'}='location';        

        #-- Alle Events sammeln und anlegen bzw. aus dem Hash holen für die,
        #   die schon angelegt wurden.
        my %hs_event = ();
        my $db_event;
        my $extevent;

        #-- extevent=
        if (exists $args->{'db_event'} and $args->{'db_event'}) {
            $extevent=$args->{'db_event'};
        }
        else {
            $extevent="$args->{'ext_event_type'}:::$args->{'event_dt'}:::$args->{'ext_id_event'}";
        }

        #-- Wenn Event im Hash, dann interne Nummer des events holen
        if ( exists $hs_event{ $extevent }
             and ( $hs_event{ $extevent } ) ) {
            $db_event = $hs_event{ $extevent };
        }

        #-- Sonst Ladestrom füllen und Event anlegen bzw. db_event holen
        else {

            #-- db_event holen bzw. anlegen
            $db_event = GetDbEvent( $args );

            #-- db_event in temp Speicher
            $hs_event{ $extevent } = $db_event;
        }

        $sql="update hatch_cage set db_event=$db_event where db_cage=$args->{'db_cage'}";

        my $sql_ref1= $apiis->DataBase->sys_sql( $sql );
        
    if ( $sql_ref1->status and ( $sql_ref1->status == 1 ) ) {

        print $sql_ref1->errors->[0]->print;
        $apiis->DataBase->dbh->rollback;
    }
    else {
        $apiis->DataBase->dbh->commit;
    }

}
