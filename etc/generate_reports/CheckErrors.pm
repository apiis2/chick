
sub CheckErrors {

    my ($self,$selection)=@_;

    $selection="2" if (!$selection);
    my $data;
    my $structure;
    my $birthyear;
    my @ar_data;
    my $vtable=' animal ';
    my $hs;
    my $flag_ani_ohne_cage;

    my $sql=  "select distinct date_part('year', birth_dt) from $vtable where birth_dt notnull order by date_part('year', birth_dt) desc limit 1;";

    #-- loop over all sqls defined in @sqls; 
        
    #-- execute 
    my $sql_ref = $apiis->DataBase->sys_sql($sql );
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status(1);
        $apiis->errors( $sql_ref->errors );
        return;
    }

    #-- actions depends on sql 
    if ( ( !$sql_ref->status ) and ( $sql_ref->{_rows} eq '0E0' ) ) {
        push( @{$data}, [main::__('Keine Geburtsjahrgänge gefunden')] );
        return $data, $structure;
    }
    else {

        while ( my $q = $sql_ref->handle->fetch ) {
            $vbirthyear= $q->[0];
        }
    }

    $sql="select ext_breed as v0, 
                    user_get_check_open_animals(b.ext_breed,'$vbirthyear') as v1,
                    user_get_check_open_cages(b.ext_breed,'$vbirthyear') as v2,
                    user_get_check_multiple_roosters_in_cages(b.ext_breed,'$vbirthyear') as v3,
                    user_get_check_multiple_cages(b.ext_breed,'$vbirthyear') as v4,
                    user_get_check_body_weigh_20weeks(b.ext_breed,'$vbirthyear') as v5,
                    user_get_check_body_weigh_40weeks(b.ext_breed,'$vbirthyear') as v6,
                    user_get_check_body_weigh_20weeks_hens(b.ext_breed,'$vbirthyear') as v7,
                    user_get_check_body_weigh_40weeks_hens(b.ext_breed,'$vbirthyear') as v8,
                    
                    user_get_check_eggs_weigh_33weeks(b.ext_breed,'$vbirthyear') as v9,
                    user_get_check_eggs_weigh_53weeks(b.ext_breed,'$vbirthyear') as v10,
                    user_get_check_eggs_collected(b.ext_breed,'$vbirthyear') as v11,
                    user_get_check_eggs_incubated(b.ext_breed,'$vbirthyear') as v12,
                    user_get_check_eggs_hatched(b.ext_breed,'$vbirthyear') as v13,
                    user_get_check_open_animals_without_cages(b.ext_breed,'$vbirthyear') as v14,
                    user_get_check_open_animals_without_cages(b.ext_breed,'$vbirthyear1') as v15

            from (select distinct user_get_ext_code(db_breed, 's') as ext_breed from animal where date_part('year',birth_dt)='$vbirthyear' order by ext_breed) as b";

    $sql_ref = $apiis->DataBase->sys_sql($sql);
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status(1);
        $apiis->errors( $sql_ref->errors );
    }
    else {
        while ( my $q = $sql_ref->handle->fetch ) {

            if ($q->[14]>0) {
                $flag_ani_ohne_cage+=$q->[14];
            }
        }
    }
print "kk".$selection;
    if ($flag_ani_ohne_cage) {
        my $link='<a target="_blank" href="/cgi-bin/GUI?user='.
                 $apiis->{'_cgisave'}->{'user'}.'&sid='.$apiis->{'_cgisave'}->{'sid'}.'&m='
                 .$apiis->{'_cgisave'}->{'m'}.'&o=htm2htm&g='.$apiis->{'_cgisave'}->{'g'}
                 .'&__form=/etc/menu/3_Reports/CheckErrors.rpt&selection=1">'
                 .main::__("[_1] Open Animals without cages", $flag_ani_ohne_cage).'</a>';
        push(@ar_daten,[$link]);
    }

    return \@ar_daten, ['CheckErrors'];
}

1;

