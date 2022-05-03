sub SearchOpenCages {
    my ( $self ) = @_;

    # Tiernummer suchen und mit db_animal vergleichen 
    # Wenn Tier nicht gefunden, dann nicht vorhanden in dieser Kombination extern-intern 
    $sql="select user_get_ext_code(db_breed,'e') as ext_breed, user_get_ext_id_animal( db_animal ), user_get_ext_code(db_sex,'e') as ext_sex,  (select ext_id from unit where db_unit=db_cage) as ext_id, birth_dt from animal where db_cage notnull and date_part('year', birth_dt)='".$birth_year."' and exit_dt isnull order by ext_breed, ext_id, ext_sex";
    
    $sql_ref = $apiis->DataBase->sys_sql($sql);
    if ( $sql_ref->status == 1 ) {
        $apiis->status(1);
        $apiis->errors( $sql_ref->errors );
        return;
    }
    if ( ( !$sql_ref->status ) and ( $sql_ref->{_rows} eq '0E0' ) ) {
        push( @{$data}, ["No records found: $exit_dt "] );
        return $data, $structure;
    }
    else {
        while ( my $q = $sql_ref->handle->fetch ) {
            for ( my $i = 0; $i <= $#cols; $i++ ) {
                $q->[$i]='NULL' if (! $q->[$i]);
                $cols[$i]=~s/.*?\) as (.*)/$1/g;
                $q->[$i] = '<b>' . $cols[$i] . ':</b> ' . $q->[$i];
            }

            push( @{$data}, [ '    ' . join( ', ', @$q ) ] );
        }
    }

    if ( $#{$data} == -1 ) {
        push( @{$data}, 'Keine Daten' );
    }
    return $data, $structure;

}

1;

