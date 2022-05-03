#####################################################################
# load object: LO_DS10
# $Id: LO_DS10.pm,v 1.20 2022/04/26 13:14:44 lfgroene Exp $
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

sub LO_DS10 {
    my $self     = shift;
    my $args     = shift;
    
    #-- schließt alle Käfige der letzten Generation und die darin befindlichen Tiere
    #-- sicherstellen, dass es wirklich die letzte Generation ist
    #-- ->Es müssen Tiere mit Wingnummern aktiv existieren und deren Eltern noch aktiv sein. 
    #-- die db_cage der neuen Wingtiere ist noch null, weil die Tiere noch nicht zugeordnet worden sind. 
    #-- sobald es keine Tiere mit offenen cages gibt, wird die Aktion nicht ausgeführt 

    use JSON;
    use URI::Escape;
    use GetDbEvent;
    use GetDbUnit;
    use chick;

    my $json;
    my $err_ref;
    my $err_status;
    my @record;
    my $extevent;
    my %hs_cages_per_line;
    my %hs_found_cages_for_line;
    my $birthyear;
    my $year;

    my %hs_event = ();
    my $db_event;
    my @breeds;

    our $hs_animal;
    my @field;
    my $hs_fields={};
    my $fileimport='1';

    my $onlycheck='off';
    if (exists $args->{ 'onlycheck' }) {
        $onlycheck=lc($args->{ 'onlycheck' });
    }

    my $breed;
    if (exists $args->{ 'breed' }) {
        $breed=$args->{ 'breed' };
    }
   
    my $msg=main::__('Close generation');
    my $row2='';

    $json = { 'Info'        => [],
              'RecordSet'   => [],
              'Bak'         => [],
            };

    ($json) = chick::CheckStatusDS($apiis,$json,$breed);

    if (exists $json->{'Critical'}) {
   
        if ($onlycheck eq 'off') {
            $json->{'Critical'}=[[main::__('DS10 always finished.')]];
        }
        return $json;
    }

####################################################################################

    #-- 
    if ($onlycheck eq 'on') {
        $msg  =main::__('Number of eggs in table hatch_cage and number of animals in table activ_animals_and_cages ');
        $row2.="<h5><strong>$msg</strong></h5>";   
        $row2.='<table border=".5">';
        $row2.="<TR><th>".main::__('Breed')."</th><th>".main::__('Cage')."</th><th>".main::__('CollEggs')."</th><th>".main::__('IncEggs')."</th><th>".main::__('HatEgs')."</th><th>".main::__('Nm')."</th><th>".main::__('Nw')."</th></TR>";
        
        my $sql="select distinct
                   user_get_ext_code(db_breed,'s'), 
                   ext_id::numeric, 
                   collected_eggs, 
                   incubated_eggs,
                   hatched_eggs,
                   (select count(*) from animal where db_sire in (select db_animal from animal where db_cage=a.db_cage and db_sex=(select db_code from codes where class='SEX' and ext_code='1'))  and db_sex=(select db_code from codes where class='SEX' and ext_code='1')),
                   (select count(*) from animal where db_sire in (select db_animal from animal where db_cage=a.db_cage and db_sex=(select db_code from codes where class='SEX' and ext_code='1')) and db_sex=(select db_code from codes where class='SEX' and ext_code='2')) 
                  
                 from v_active_animals_and_cages a inner join hatch_cage b on a.db_cage=b.db_cage ";
        if ($breed) {
            $sql.=" where  user_get_ext_code(db_breed, 's') = '$breed'";
        }

        $sql.=" order by user_get_ext_code(db_breed,'s'), ext_id::numeric";

        #-- SQL auslösen 
        my $sql_ref = $apiis->DataBase->sys_sql( $sql );
        
        # Auslesen des Ergebnisses der Datenbankabfrage
        while ( my $q = $sql_ref->handle->fetch ) {
     
            map {$_='' if (!defined $_) } @$q;
            $row2.="<TR><td>$q->[0]</td><td>$q->[1]</td><td>$q->[2]</td><td>$q->[3]</td><td>$q->[4]</td><td>$q->[5]</td><td>$q->[6]</td></TR>";
        }
        $row2.='</table>';

        $msg  =main::__('Sums of eggs in table hatch_cage and number of animals in table activ_animals_and_cages per breed');
        $row2.="<h5><strong>$msg</strong></h5>";   
        $row2.='<table border=".5">';
        $row2.="<TR><th>Breed</th><th>Cage</th><th>CollEggs</th><th>IncEggs</th><th>HatEgs</th><th>Nm</th><th>Nw</th></TR>";

        $sql="select 
                 breed, 
                 count(cage), 
                 sum(ce), sum(ie), 
                 sum(he), 
                 sum(nm), 
                 sum(nw) 
              from (select distinct user_get_ext_code(db_breed,'s') as breed , ext_id::numeric as cage, collected_eggs as ce, incubated_eggs as ie,hatched_eggs as he,(select count(*) from animal where db_sire in (select db_animal from animal where db_cage=a.db_cage and db_sex=(select db_code from codes where class='SEX' and ext_code='1')) and db_sex=(select db_code from codes where class='SEX' and ext_code='1') ) as nm,(select count(*) from animal where db_sire in (select db_animal from animal where db_cage=a.db_cage and db_sex=(select db_code from codes where class='SEX' and ext_code='1'))  and db_sex=(select db_code from codes where class='SEX' and ext_code='2') ) as nw from v_active_animals_and_cages a inner join hatch_cage b on a.db_cage=b.db_cage ";
        
        if ($breed) {
            $sql.=" where  user_get_ext_code(db_breed, 's') = '$breed'";
        }
        
        $sql.=" order by user_get_ext_code(db_breed,'s'), ext_id::numeric) as z group by breed;";

        #-- SQL auslösen 
        $sql_ref = $apiis->DataBase->sys_sql( $sql );
        
        # Auslesen des Ergebnisses der Datenbankabfrage
        while ( my $q = $sql_ref->handle->fetch ) {
      
            $row2.="<TR><td>$q->[0]</td><td>$q->[1]</td><td>$q->[2]</td><td>$q->[3]</td><td>$q->[4]</td><td>$q->[5]</td><td>$q->[6]</td></TR>";
        }
        $row2.='</table>';

        $json->{ 'Before' }=$row2;
    }
    else {
        
        my $sql=" select distinct date_part('year', birth_dt), date_part('year', birth_dt)+1 from v_active_animals_and_cages ;";

        #-- SQL auslösen 
        my $sql_ref = $apiis->DataBase->sys_sql( $sql );
        
        # Auslesen des Ergebnisses der Datenbankabfrage
        while ( my $q = $sql_ref->handle->fetch ) {
        
            $birthyear=$q->[0];
            $year=$q->[1];
        }
        
        $sql="update animal set exit_dt=current_date where db_animal in (select distinct db_animal from v_active_animals_and_cages) and exit_dt isnull ";
        
        if ($breed) {
            $sql.=" and user_get_ext_code(db_breed, 's') = '$breed'";
        }
        
        #-- SQL auslösen 
        $sql_ref = $apiis->DataBase->sys_sql( $sql );
        
        #-- Fehlerbehandlung 
        if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
            if ($sql_ref->errors->[0]->msg_short=~/No records affected by/) {
            
                $msg  =main::__('There are no active animals');
                $row2.="<strong>$msg</strong>";   

            }
            else {
                $self->errors( $sql_ref->errors);
                $self->status(1);
                $apiis->status(1);
                last EXIT;
            }
        }
        
        $row2.='<h4>Count of closed animals per breed</h4>';
        $row2.='<table border=".5">';
        $row2.="<TR><th>Breed</th><th>Animals</th></TR>";

        $sql=" select user_get_ext_code(db_breed,'s') as ext_breed, count(db_animal) from animal where exit_dt=current_date group by db_breed order by ext_breed;";

        #-- SQL auslösen 
        $sql_ref = $apiis->DataBase->sys_sql( $sql );
        
        # Auslesen des Ergebnisses der Datenbankabfrage
        while ( my $q = $sql_ref->handle->fetch ) {
        
            $q->[0]='-' if (!defined $q->[0]);
            $q->[1]='-' if (!defined $q->[1]);

            $row2.="<TR><td>$q->[0]</td><td>$q->[1]</td></TR>";
        }
        $row2.='</table>';

        $sql="update unit set closing_dt=current_date where ext_unit='cage' and closing_dt isnull ";

        if ($breed) {
            $sql.=" and db_unit in (select db_cage from animal where user_get_ext_code(db_breed, 's') = '$breed')";
        }
        
        #-- SQL auslösen 
        $sql_ref = $apiis->DataBase->sys_sql( $sql );
        
        #-- Fehlerbehandlung 
        if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
            if ($sql_ref->errors->[0]->msg_short=~/No records affected by/) {
            
                $msg  =main::__('There are no active cages');
                $row2.="<p><strong>$msg</strong>";   

            }
            else {
                $self->errors( $sql_ref->errors);
                $self->status(1);
                $apiis->status(1);
                last EXIT;
            }
        }
        
        $row2.='<p><h4>Count of closed cages per breed</h4>';
        $row2.='<table border=".5">';
        $row2.="<TR><th>Breed</th><th>Cages</th></TR>";

        $sql="select (select distinct user_get_ext_code(db_breed, 's') from animal where db_cage=a.db_unit) as ext_breed, count(db_unit) from unit a where ext_unit='cage' and closing_dt=current_date group by ext_breed order by ext_breed";

        #-- SQL auslösen 
        $sql_ref = $apiis->DataBase->sys_sql( $sql );
        
        # Auslesen des Ergebnisses der Datenbankabfrage
        while ( my $q = $sql_ref->handle->fetch ) {
      
            $q->[0]='-' if (!defined $q->[0]);
            $q->[1]='-' if (!defined $q->[1]);

            if (($q->[0] ne '-') and ($q->[1] ne '-')) {
                push(@breeds, $q->[0]);
            }

            $row2.="<TR><td>$q->[0]</td><td>$q->[1]</td></TR>";
        }
        $row2.='</table>';

        $json->{ 'Before' }=$row2;
    }

EXIT:
    if ((!$apiis->status) and ($onlycheck eq 'off')) {

         
        if ($fileimport) {
            my $tbreed='';
            $tbreed=join('+',@breeds) if ( @breeds);

            chick::SaveDatabase( $apiis, 'DS10', $tbreed, $birthyear, $year) ;
        }

        $apiis->DataBase->commit;
    }
    else {
        $apiis->DataBase->rollback;
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

