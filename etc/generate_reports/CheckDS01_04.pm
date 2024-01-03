
sub CheckDS01_04 {

    my ($self,$order)=@_;

    $selection="2" if (!$selection);
    my $data;
    my $structure;
    my $birthyear;
    my @ar_data;
    my $vtable=' animal ';
    my $sql;

    if ($order eq 'far_id') {
        $sql="select far_id, ext_id as cage_no, collected_eggs, incubated_eggs, hatched_eggs, hatch_dt, event_dt from hatch_cage a inner join entry_unit b on a.db_cage=b.db_unit inner join event c on a.db_event=c.db_event order by substring(far_id from '(.+):::'),substring(far_id from ':::(.+)')::numeric ";
    }
    else {
        $sql="select far_id, ext_id as cage_no, collected_eggs, incubated_eggs, hatched_eggs, hatch_dt, event_dt from hatch_cage a inner join entry_unit b on a.db_cage=b.db_unit inner join event c on a.db_event=c.db_event order by ext_id::numeric"
    }

    my $sql_ref = $apiis->DataBase->sys_sql($sql);
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status(1);
        $apiis->errors( $sql_ref->errors );
    }
    else {

        while ( my $q = $sql_ref->handle->fetch ) {
           push(@ar_daten, [@$q]);
        }
    }

    return \@ar_daten, ['FarID','CageNumber','CollectedEggs','IncubatedEggs','HatchedEggs', 'HatchDt', 'EventDt'];
}

1;

