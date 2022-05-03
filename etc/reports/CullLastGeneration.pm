sub GetData {
    my ( $self, $birth_year,$exit_dt ) = @_;
    my $structure = ['field'];

    if (!$birth_year or ( $birth_year eq '' ) or ($birth_year!~/20../)) {
        push( @{$data}, [__("Year of birth empty or wrong")] );
        return $data, $structure;
    }   

    if (!$exit_dt or ( $exit_dt eq '' )) {
        push( @{$data}, ["Exit date is empty."] );
        return $data, $structure;
    }   

    #-- Käfige auf closing_dt setzen, da Elterngeneration nicht mehr genutzt    
    $sql="update unit set closing_dt='".$exit_dt."' where db_unit in (select distinct db_cage from animal where db_cage notnull and date_part('year', birth_dt)='$birth_year') and closing_dt isnull";
    
    $sql_ref = $apiis->DataBase->sys_sql($sql);
    if ( $sql_ref->status == 1 ) {
        $apiis->status(1);
        $apiis->errors( $sql_ref->errors );
        return;
    }
    if ( ( !$sql_ref->status ) and ( $sql_ref->{_rows} eq '0E0' ) ) {
        push( @{$data}, ["No units found: $exit_dt "] );
        return $data, $structure;
    }
    else {
        push( @{$data}, $sql_ref->{_rows} .' units updated' );
    }
    
    #-- Tiernummern auf exit_dt setzen für db_cage notnull und einem definierten Geburtsdatum 
    $sql="update animal set exit_dt='".$exit_dt."' where db_animal in (select  db_animal from animal where db_cage notnull and date_part('year', birth_dt)='$birth_year') and exit_dt isnull";
    
    $sql_ref = $apiis->DataBase->sys_sql($sql);
    if ( $sql_ref->status == 1 ) {
        $apiis->status(1);
        $apiis->errors( $sql_ref->errors );
        return;
    }
    if ( ( !$sql_ref->status ) and ( $sql_ref->{_rows} eq '0E0' ) ) {
        push( @{$data}, ["No animals found: $exit_dt "] );
        return $data, $structure;
    }
    else {
        push( @{$data}, $sql_ref->{_rows} .' animals updated' );
    }

    $apiis->DataBase->dbh->commit;
    
    return $data, $structure;

}

1;

