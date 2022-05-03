sub Export  {
    my ( $self,$exportfilter,$breed,$year ) = @_;
    my $cmd;
    my  $out;

    #-- wenn nur katalog ausgelagert werden soll 
    if ($exportfilter eq 'cages.csv') {
        $cmd='psql chick -U apiis_admin -q -A -F '."','".' -c "'
        ."    
        select 
        (select user_get_ext_code(db_breed, 's') from animal where db_animal in (select user_get_animal_from_cage(a.db_cage, '1', 0) limit 1)) as breed, 
        user_get_full_db_unit(db_cage) as ext_cage, 
        b.event_dt, 
        collected_eggs ,
        incubated_eggs, 
        hatched_eggs, 
        hatch_dt, 
        far_id,  
        user_get_full_db_animal(user_get_animal_from_cage(db_cage, '1', 0)) as sire, 
        user_get_ext_id_animal(user_get_animal_from_cage(db_cage, '2', 0)) as hen1, 
        user_get_ext_id_animal(user_get_animal_from_cage(db_cage, '2', 1)) as hen2,
        user_get_ext_id_animal(user_get_animal_from_cage(db_cage, '2', 2)) as hen3,
        user_get_ext_id_animal(user_get_animal_from_cage(db_cage, '2', 3)) as hen4,
        user_get_ext_id_animal(user_get_animal_from_cage(db_cage, '2', 4)) as hen5,
        user_get_ext_id_animal(user_get_animal_from_cage(db_cage, '2', 5)) as hen6,
        user_get_ext_id_animal(user_get_animal_from_cage(db_cage, '2', 6)) as hen7,
        user_get_ext_id_animal(user_get_animal_from_cage(db_cage, '2', 7)) as hen8,
        user_get_ext_id_animal(user_get_animal_from_cage(db_cage, '2', 8)) as hen9, 

        (select body_wt from pt_indiv z inner join event b on z.db_event=b.db_event where b.db_event_type=(select db_code from codes where class='EVENT' and ext_code='event_weighing_body') and z.db_animal=user_get_animal_from_cage(a.db_cage, '1', 0)  limit 1) as sire_wght_1,
        (select body_wt from pt_indiv z inner join event b on z.db_event=b.db_event where b.db_event_type=(select db_code from codes where class='EVENT' and ext_code='event_weighing_body') and z.db_animal=user_get_animal_from_cage(a.db_cage, '1', 0) limit 1) as sire_wght_2,

        user_get_body_wt_hens('event_weighing_body', a.db_cage, '1') as hen1_wght_1,
        user_get_body_wt_hens('event_weighing_body', a.db_cage, '1') as hen1_wght_2,
        user_get_body_wt_hens('event_weighing_body', a.db_cage, '2') as hen1_wght_1,
        user_get_body_wt_hens('event_weighing_body', a.db_cage, '2') as hen1_wght_2,
        user_get_body_wt_hens('event_weighing_body', a.db_cage, '3') as hen1_wght_1,
        user_get_body_wt_hens('event_weighing_body', a.db_cage, '3') as hen1_wght_2,
        user_get_body_wt_hens('event_weighing_body', a.db_cage, '4') as hen1_wght_1,
        user_get_body_wt_hens('event_weighing_body', a.db_cage, '4') as hen1_wght_2,
        user_get_body_wt_hens('event_weighing_body', a.db_cage, '5') as hen1_wght_1,
        user_get_body_wt_hens('event_weighing_body', a.db_cage, '5') as hen1_wght_2,
        user_get_body_wt_hens('event_weighing_body', a.db_cage, '6') as hen1_wght_1,
        user_get_body_wt_hens('event_weighing_body', a.db_cage, '6') as hen1_wght_2,
        user_get_body_wt_hens('event_weighing_body', a.db_cage, '7') as hen1_wght_1,
        user_get_body_wt_hens('event_weighing_body', a.db_cage, '7') as hen1_wght_2,
        user_get_body_wt_hens('event_weighing_body', a.db_cage, '8') as hen1_wght_1,
        user_get_body_wt_hens('event_weighing_body', a.db_cage, '8') as hen1_wght_2,
        user_get_body_wt_hens('event_weighing_body', a.db_cage, '9') as hen1_wght_1,
        user_get_body_wt_hens('event_weighing_body', a.db_cage, '9') as hen1_wght_2




        from hatch_cage a inner join event b on a.db_event=b.db_event 
        where 1=1
        ";
        if ($year ne 'all years') {
           $cmd.=" and  date_part('year', b.event_dt)=$year ";
        }
        if ($breed ne 'all breeds') {
            $cmd.= " and (select user_get_ext_code(db_breed, 's') from animal where db_animal in (select user_get_animal_from_cage(a.db_cage, '1', 0) limit 1))='$breed'";
        }

        $cmd.=" order by ext_cage" 
                .'" > '
                .$apiis->APIIS_LOCAL.'/tmp/cages.csv;';
        
        $out='<p>';
        system ( $cmd );

        $out.='<a href="/tmp/cages.csv">Download cages.csv</a>';
         
    }

    elsif ($exportfilter eq 'pedigree') {

        $cmd='psql chick -U apiis_admin -q -A -F '."','".' -c "select a.db_animal,a.birth_dt,a.ext_sex,a.ext_breed,a.db_sire,db_dam1,db_dam2,db_dam3,db_dam4,db_dam5,db_dam6,db_dam7,db_dam8,db_dam9,db_dam10 from v_animal a inner join possible_dams b on a.db_animal=b.db_animal" > '.$apiis->APIIS_LOCAL.'/tmp/pedigree.csv;'; 
        
        print '<p>Command: '.$cmd.'<p>';

        system ( $cmd );
        
        $out='<a href="/tmp/pedigree.csv">Download Pedigree</a>';
    }
    elsif ($exportfilter eq 'poprep') {

        #-- hole alle möglichen Rassen 
        my $sql="select distinct db_breed, ext_breed from v_animal where db_breed notnull;";

        #-- führe den SQL aus
        my $sql_ref = $apiis->DataBase->sys_sql($sql);
        
        #-- Fehlerbehandlung 
        if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
            $self->errors( $sql_ref->errors);
            $self->status(1);
            $apiis->status(1);
            goto EXIT;
        }   
    
        chdir $apiis->APIIS_LOCAL."/tmp/";

        # Auslesen des Ergebnisses der Datenbankabfrage
        my $vbreed;
        while ( my $q = $sql_ref->handle->fetch ) {
            $vbreed = $q->[0];
            $ebreed = $q->[1];
        
            $cmd='psql chick -U apiis_admin -q -A -t -F "|" -c "'
                ."set datestyle to 'ISO'; select a.db_animal,
                case when a.db_sire=1 then 'unknown_sire' else a.db_sire::text end ,
                case when db_dam1 isnull then 'unknown_dam' else db_dam1::text end,
                  a.birth_dt,
                  case when a.ext_sex='1' then 'M' else 'F' end 
                  from v_animal a inner join possible_dams b on a.db_animal=b.db_animal
                  where a.db_breed=$vbreed"
                .'" > '
                ."pedigree_$ebreed.csv;";

            print '<p>Command: '.$cmd.'<p>';

            system ( $cmd );
            
            $out.="pedigree_$ebreed.csv ";

        }
        
        system( "zip -q poprep.zip $out" ) ;
        
        $out='<a href="'."/tmp/poprep.zip".'">Download PopRep Pedigree(s) as zip</a><br>';
    }
    elsif ($exportfilter eq 'blup') {

        chdir $apiis->APIIS_LOCAL."/zwisss/";
        
        my $cmd='perl $REFERENCE_HOME/bin/extract_for_something.pl -q -d '.$apiis->User->id." -w  agrum1 -p ".$apiis->Model->db_name." -f ".$apiis->APIIS_LOCAL."/zwisss/chick.par -m -s";
       
        print '<p>Command: '.$cmd.'<p>';

        system( $cmd );

        $out=__("BLUP data exported");
    }
    elsif ($exportfilter eq 'blup_random') {

        chdir $apiis->APIIS_LOCAL."/zwisss/";
       
        my $cmd='perl $REFERENCE_HOME/bin/extract_for_something.pl -q -d '.$apiis->User->id." -w  agrum1 -p ".$apiis->Model->db_name." -f ".$apiis->APIIS_LOCAL."/zwisss/chick_random.par -m -s";

        print '<p>Command: '.$cmd.'<p>';

        system( $cmd );

        $out=__("BLUP data exported");
    }

EXIT:
    
    return [[__('Auslagerung erfolgreich')],[ $out ]], ['code1'];
}
1;

