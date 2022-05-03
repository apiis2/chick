sub GetData {
    my ( $self ) = @_;
    my $structure = ['field'];

#user=lfgroene&sid=67e456c1029f8ffc8baba0872a84a017&m=chick&o=htm2htm&g=%2Fetc%2Freports%2FDS05List.rpt

    my $sql     = "Set datestyle to 'german'";
    my $sql_ref = $apiis->DataBase->sys_sql($sql);

    my @breeds;
    my @actions=('','N multiple roosters in cages','N lines','N open cages','N open animals','N body weights roosters 20weeks','N body weights roosters 40weeks','N body weights hens 20weeks','N body weights hens 40weeks','N eggs weights 33weeks','N eggs weights 53weeks','N cages with collected eggs','N cages with incubated eggs','N cages with hateched eggs');
    
    my @sqls=("select distinct user_get_ext_code(db_breed, 's') as ext_breed from animal where date_part('year',birth_dt)=(select user_get_last_birth_years(1)) order by ext_breed;",
    
            "select distinct date_part('year', birth_dt) from animal where birth_dt notnull order by date_part('year', birth_dt) desc limit 2;");

    #-- loop over all sqls defined in @sqls; 
    for (my $i=0; $i<=$#sqls;$i++) {
        
        #-- execute 
        $sql_ref = $apiis->DataBase->sys_sql($sqls[$i] );
        if ( $sql_ref->status == 1 ) {
            $apiis->status(1);
            $apiis->errors( $sql_ref->errors );
            return;
        }

        #-- actions depends on sql 
        if ( ( !$sql_ref->status ) and ( $sql_ref->{_rows} eq '0E0' ) ) {
            push( @{$data}, ["Keine Geburtsjahrgänge gefunden"] );
            return $data, $structure;
        }
        else {

            while ( my $q = $sql_ref->handle->fetch ) {
                if ($i==1) {
                    push(@birth_year, $q->[0]);
                }
                if ($i==0) {
                    push (@breeds, $q->[0]);    
                }
            }
        }
    }

    #--- Check for closed generations; 
    my $generation_closed=1;

    $sql="select * from v_active_animals_and_cages";
    
    my $sql_ref = $apiis->DataBase->sys_sql($sql);
    if ( $sql_ref->status == 1 ) {
        $apiis->status(1);
        $apiis->errors( $sql_ref->errors );
    }
    else {
        while ( my $q = $sql_ref->handle->fetch ) {
        
           $generation_closed=undef;
        }
    }
    
    #-- check for each birthyear 
    foreach (@birth_year) {

        push( @{$data}, ['<p style="text-align:left">'."<strong>Geburtsjahrgang : $_</strong><style>td{padding-right:20px;text-align: right}</style>"] );

        push( @{$data}, ['<style>color:red</style><table><TR><td style="text-align: left">Rassen:</td><td>'.join('</td><td>',@breeds).'</td></TR>']);
        
        $sql="select ext_breed, 
                     user_get_check_multiple_roosters_in_cages(b.ext_breed,'$_'),
                     user_get_check_multiple_cages(b.ext_breed,'$_'),
                     user_get_check_open_cages(b.ext_breed,'$_'),
                     user_get_check_open_animals(b.ext_breed,'$_'),
                     user_get_check_body_weigh_20weeks(b.ext_breed,'$_'),
                     user_get_check_body_weigh_40weeks(b.ext_breed,'$_'),
                     user_get_check_body_weigh_20weeks_hens(b.ext_breed,'$_'),
                     user_get_check_body_weigh_40weeks_hens(b.ext_breed,'$_'),
                     user_get_check_eggs_weigh_33weeks(b.ext_breed,'$_'),
                     user_get_check_eggs_weigh_53weeks(b.ext_breed,'$_'),
                     user_get_check_eggs_collected(b.ext_breed,'$_'),
                     user_get_check_eggs_incubated(b.ext_breed,'$_'),
                     user_get_check_eggs_hatched(b.ext_breed,'$_')
              from (select distinct user_get_ext_code(db_breed, 's') as ext_breed from animal where date_part('year',birth_dt)='$_' order by ext_breed) as b";
        $sql_ref = $apiis->DataBase->sys_sql($sql);
        if ( $sql_ref->status == 1 ) {
            $apiis->status(1);
            $apiis->errors( $sql_ref->errors );
        }
        if ( ( !$sql_ref->status ) and ( $sql_ref->{_rows} eq '0E0' ) ) {
#push( @{$data}, ["No open cages found"] );
        }
        else {
            while ( my $q = $sql_ref->handle->fetch ) {

                if (($q->[1]>0) and ($q->[3]>0))  {
                
                    $sql="
                          select user_get_ext_id(db_cage) as cage,
                                 user_get_full_db_animal(db_animal) as animal,
                                 user_get_ext_code(db_sex,'s') as sex,
                                 user_get_ext_code(db_breed,'s') as breed,
                                 birth_dt as birth_dt,
                                 user_get_ext_id_animal(db_sire) as sire,
                                 user_get_ext_id_animal(db_dam) as dam
                          from v_active_animals_and_cages
                          where db_cage in (
                          select db_cage 
                          from (select user_get_ext_code(db_sex,'e'),db_cage from v_active_animals_and_cages 
                          where user_get_ext_code(db_sex,'e')='1' and 
                                db_breed=(select db_code from codes where class='BREED' and ext_code='$q->[0]')) as a
                          group by db_cage 
                          having  count(db_cage)>1)"    ;
                    
                    system("psql chick -U apiis_admin -A -q -F ',' -c ".'"'.$sql.'"'.' >$APIIS_LOCAL/tmp/multiple_roosters_in_cage_'.$q->[0].'.csv');

                    $q->[1]='<a href="/tmp/multiple_roosters_in_cage_'.$q->[0].'.csv">'.$q->[1].'</a>';
                }
                $hs{$q->[0]}=[@$q];
            }
        }


        for (my $i=1; $i<12; $i++) {
            my @traits;

            foreach (sort keys %hs) {
                push(@traits, $hs{$_}->[$i]);
            }
            push(  @{$data}, ['<TR><td style="text-align:left">'.$actions[$i].'</td><td>'.join('</td><td>',@traits).'</td></TR>'] );
        }
        push(  @{$data}, ['</table>']);
        push(  @{$data}, ['<table><TR><td  style="text-align: left">Check Errors</td><td>Download Lists </td><td>Upload lists</td></TR>']);
        
        my $sql;
        my @a=();
        my @c=();

        #-- check for open cages;
        my $opencage;
        my $hatched_eggs;
        map { if ($hs{$_}->[3])  {$opencage=1}} keys %hs;
        map { if ($hs{$_}->[11]) {$hatched_eggs=1}} keys %hs;


        if ($hatched_eggs and $opencage) {

            open (OUT, ">".$apiis->APIIS_LOCAL."/tmp/wingnumbers.csv");
            print OUT "wingnumber,sex,far,breed\n";
            
            close(OUT);            
            push(@a, '<a href="/tmp/wingnumbers.csv">Inputlist wingnumbers</a>');
        }


        if ($generation_closed) {

            open (OUT, ">".$apiis->APIIS_LOCAL."/tmp/cagenumbers.csv");
            print OUT "breed,wingnumber,sex,far,cagenumber\n";
            $sql="select user_get_ext_code(db_breed,'s') as breed, user_get_ext_animal(db_animal) as animal, user_get_ext_code(db_sex,'e') as sex, (select far_id from animal inner join hatch_cage on animal.db_cage=hatch_cage.db_cage where db_animal=a.db_sire), '' as cage from animal a where a.db_cage isnull  and db_breed notnull;";
            
            my $sql_ref = $apiis->DataBase->sys_sql($sql);
            if ( $sql_ref->status == 1 ) {
                $apiis->status(1);
                $apiis->errors( $sql_ref->errors );
            }
            if ( ( !$sql_ref->status ) and ( $sql_ref->{_rows} eq '0E0' ) ) {
                #push( @{$data}, ["No open cages found"] );
            }
            else {
                while ( my $q = $sql_ref->handle->fetch ) {
                
                    for(my $i=0; $i<=$q->[2];$i++) {
                        print OUT "$q->[0],$q->[1],$q->[2],$q->[3],\n";
                    }
                }
            }
            close(OUT);            
            push(@a, '<a href="/tmp/cagenumbers.csv">Inputlist cagenumbers</a>');
        }

        #-- there are open cages 
        if ($opencage) {
            #-- sql to export input list for eggs 
            $sql="select x.breed,
                x.cage, 
                (select b.event_dt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody20weeks' and hen_number='1' and db_cage=x.db_cage) as date_body_wt_20_weeks,
                user_get_ext_id_animal(x.db_animal) as rooster, 
                (select body_wt from pt_indiv a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody20weeks' and a.db_animal=x.db_animal and a.db_cage=x.db_cage) as rooster_body_wt_20_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody20weeks' and a.hen_number='1' and a.db_cage=x.db_cage) as hen1_body_wt_20_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody20weeks' and a.hen_number='2' and a.db_cage=x.db_cage) as hen2_body_wt_20_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody20weeks' and a.hen_number='3' and a.db_cage=x.db_cage) as hen3_body_wt_20_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody20weeks' and a.hen_number='4' and a.db_cage=x.db_cage) as hen4_body_wt_20_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody20weeks' and a.hen_number='5' and a.db_cage=x.db_cage) as hen5_body_wt_20_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody20weeks' and a.hen_number='6' and a.db_cage=x.db_cage) as hen6_body_wt_20_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody20weeks' and a.hen_number='7' and a.db_cage=x.db_cage) as hen7_body_wt_20_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody20weeks' and a.hen_number='8' and a.db_cage=x.db_cage) as hen8_body_wt_20_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody20weeks' and a.hen_number='9' and a.db_cage=x.db_cage) as hen9_body_wt_20_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody20weeks' and a.hen_number='10' and a.db_cage=x.db_cage) as hen10_body_wt_20_weeks,

                (select b.event_dt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody40weeks' and hen_number='1' and db_cage=x.db_cage) as date_body_wt_40_weeks,
                user_get_ext_id_animal(x.db_animal) as rooster, 
                (select body_wt from pt_indiv a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody40weeks' and a.db_animal=x.db_animal and a.db_cage=x.db_cage) as rooster_body_wt_40_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody40weeks' and a.hen_number='1' and a.db_cage=x.db_cage) as hen1_body_wt_40_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody40weeks' and a.hen_number='2' and a.db_cage=x.db_cage) as hen2_body_wt_40_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody40weeks' and a.hen_number='3' and a.db_cage=x.db_cage) as hen3_body_wt_40_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody40weeks' and a.hen_number='4' and a.db_cage=x.db_cage) as hen4_body_wt_40_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody40weeks' and a.hen_number='5' and a.db_cage=x.db_cage) as hen5_body_wt_40_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody40weeks' and a.hen_number='6' and a.db_cage=x.db_cage) as hen6_body_wt_40_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody40weeks' and a.hen_number='7' and a.db_cage=x.db_cage) as hen7_body_wt_40_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody40weeks' and a.hen_number='8' and a.db_cage=x.db_cage) as hen8_body_wt_40_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody40weeks' and a.hen_number='9' and a.db_cage=x.db_cage) as hen9_body_wt_40_weeks,
                (select body_wt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody40weeks' and a.hen_number='10' and a.db_cage=x.db_cage) as hen10_body_wt_40_weeks
                from (select distinct user_get_ext_code(c.db_breed,'s') as breed,  user_get_ext_id(c.db_cage)::numeric as cage, c.db_cage, db_animal from  v_active_animals_and_cages c where user_get_ext_id(c.db_cage)>'1' ) as x
                order by x.breed, x.cage"; 
            
            system("psql chick -U apiis_admin -A -q -F ',' -c ".'"'.$sql.'"'.' >$APIIS_LOCAL/tmp/inputlist_weights.csv');
            
            push(@a, '<a href="/tmp/inputlist_weights.csv">Inputlist weights</a>');
        
            #-- hatch-eggs

            open (OUT, ">".$apiis->APIIS_LOCAL."/tmp/hatch_cages.csv");
            print OUT "rase,far,bur,velge ny generasjon,dato innlagte egg,innlagte egg,til klekking,klekka,dato klekka\n";
            
            $sql="select distinct user_get_ext_code(b.db_breed,'s') as breed, b.db_sire, user_get_ext_id(b.db_cage)::numeric, '' as sel, user_get_event_dt(a.db_event) as event_dt, collected_eggs, incubated_eggs, hatched_eggs, hatch_dt from v_active_animals_and_cages b left outer join hatch_cage a on a.db_cage=b.db_cage where user_get_ext_code(b.db_sex,'e')='2' order by user_get_ext_id(b.db_cage)::numeric, breed";
            
            
            my $sql_ref = $apiis->DataBase->sys_sql($sql);
            if ( $sql_ref->status == 1 ) {
                $apiis->status(1);
                $apiis->errors( $sql_ref->errors );
            }
            if ( ( !$sql_ref->status ) and ( $sql_ref->{_rows} eq '0E0' ) ) {
                #push( @{$data}, ["No open cages found"] );
            }
            else {

                my $cnt=0;
                my $tmp='xx';
                my $far='xx';

                while ( my $q = $sql_ref->handle->fetch ) {
                
                    #-- new breed -> reset counter to 1; 
                    if ($tmp ne $q->[0]) {
                        $cnt=0;
                    }
                    if ($far ne $q->[1]) {
                        $cnt++;
                    }

                    $tmp=$q->[0];
                    $far=$q->[1];
                    $q->[1]=$cnt;

                    print OUT join(',',@$q)."\n";

                }
            }
            close(OUT);            
            
            push(@a, '<a href="/tmp/hatch_cages.csv">Hatch cages</a>');
            
            #-- sql to export input list for eggs 
            $sql="select x.breed, x.cage, x.event_dt as date_33_weeks, x.number_hens  as number_hens_33_weeks, x.total_weight_eggs as totalweigh_33_weeks, x.n_eggs as n_eggs_33_weeks, y.event_dt as date_53_weeks, y.number_hens  as number_hens_53_weeks, y.total_weight_eggs as totalweigh_53_weeks, y.n_eggs as n_eggs_53_weeks from (select distinct user_get_ext_code(c.db_breed,'s') as breed,  user_get_ext_id(c.db_cage)::numeric as cage, event_dt, user_get_ext_code(z.db_event_type,'e'), number_hens, total_weight_eggs, n_eggs from  v_active_animals_and_cages c left outer join (select a.*,b.* from eggs_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingeggs33weeks') z on c.db_cage=z.db_cage  where user_get_ext_id(c.db_cage)>'1' order by user_get_ext_id(c.db_cage)::numeric, breed) as x , (select distinct user_get_ext_code(c.db_breed,'s') as breed,  user_get_ext_id(c.db_cage)::numeric as cage, event_dt, user_get_ext_code(z.db_event_type,'e'), number_hens, total_weight_eggs, n_eggs from  v_active_animals_and_cages c left outer join (select a.*,b.* from eggs_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingeggs53weeks') z on c.db_cage=z.db_cage  where user_get_ext_id(c.db_cage)>'1' order by user_get_ext_id(c.db_cage)::numeric, breed) as y where x.cage=y.cage ;";

            system("psql chick -U apiis_admin -A -q -F ',' -c ".'"'.$sql.'"'.' >$APIIS_LOCAL/tmp/inputlist_eggs.csv');
            
            push(@a, '<a href="/tmp/inputlist_eggs.csv">Inputlist eggs</a>');
           
            #-- Check errors
            my %hs_cage_m;
            my %hs_cage_w;

            $sql="select distinct user_get_full_db_unit(db_cage) ,user_get_full_db_animal( db_sire), (select ext_id::numeric from unit where db_unit=db_cage) from v_active_animals_and_cages where db_sex=(select db_code from codes where class='SEX' and ext_code='2') order by (select ext_id::numeric from unit where db_unit=db_cage);";
            $sql_ref = $apiis->DataBase->sys_sql($sql);
            if ( $sql_ref->status == 1 ) {
                $apiis->status(1);
                $apiis->errors( $sql_ref->errors );
            }
            if ( ( !$sql_ref->status ) and ( $sql_ref->{_rows} eq '0E0' ) ) {
                #push( @{$data}, ["No open cages found"] );
            }
            else {
                while ( my $q = $sql_ref->handle->fetch ) {

                    $hs_cage_w{$q->[0]}=[] if (!exists  $hs_cage_w{$q->[0]});
                    push(@{$hs_cage_w{$q->[0]}},$q->[1]);
                }
            }

            $sql="select distinct user_get_full_db_unit(db_cage), user_get_full_db_animal(db_sire), (select ext_id::numeric from unit where db_unit=db_cage) from v_active_animals_and_cages where db_sex=(select db_code from codes where class='SEX' and ext_code='1') order by (select ext_id::numeric from unit where db_unit=db_cage);";
            $sql_ref = $apiis->DataBase->sys_sql($sql);
            if ( $sql_ref->status == 1 ) {
                $apiis->status(1);
                $apiis->errors( $sql_ref->errors );
            }
            if ( ( !$sql_ref->status ) and ( $sql_ref->{_rows} eq '0E0' ) ) {
                #push( @{$data}, ["No open cages found"] );
            }
            else {
                while ( my $q = $sql_ref->handle->fetch ) {

                    $hs_cage_m{$q->[0]}=[] if (!exists  $hs_cage_m{$q->[0]});
                    push(@{$hs_cage_m{$q->[0]}},$q->[1]);
                }
            }

            my $data1;

            #-- Schleife über alle Käfige
            foreach my $vcage  (keys %hs_cage_w) {
              
                if ((!exists $hs_cage_m{$vcage}) or 
                    (exists $hs_cage_m{$vcage}) and  (($#{$hs_cage_m{$vcage}}>1 ) or ($#{$hs_cage_w{$vcage}}>1))) {
                    $data1.=$vcage.',2,'.join('|',@{$hs_cage_w{$vcage}}).',1,'.join('|',@{$hs_cage_m{$vcage}})."\n"
                    
                }
            }
            if ($data1) {
                open (OUT, ">".$apiis->APIIS_LOCAL."/tmp/check_errors.csv") || print "Fehler"; 
                print OUT $data1;
                close (OUT);
                push(@c, '<a href="/tmp/check_errors.csv">Check errors</a>');
            }
        }

        push(  @{$data}, ['<TR><td>'.join('<br>', @c).'</td><td>'.join('<br>', @a).'</td><td></td></TR>']);
        push(  @{$data}, ['</table><style>body{text-align:left}</style>']);
    }

    if ( $#{$data} == -1 ) {
        push( @{$data}, 'Keine Daten' );
    }
    return $data, $structure;

}

1;

