use CheckLines;

sub CheckStatus {
    my ( $self ) = @_;
    my $structure = ['field'];

#user=lfgroene&sid=67e456c1029f8ffc8baba0872a84a017&m=chick&o=htm2htm&g=%2Fetc%2Freports%2FDS05List.rpt

    my $sql     = "Set datestyle to 'german'";
    my $sql_ref = $apiis->DataBase->sys_sql($sql);

    #--- Check for closed generations; 
    my $generation_closed=1;
    my $limit=1;
    my $vtable=' animal ';

    $sql="select * from v_active_animals_and_cages";
    
    $sql_ref = $apiis->DataBase->sys_sql($sql);
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status(1);
        $apiis->errors( $sql_ref->errors );
    }
    else {
        while ( my $q = $sql_ref->handle->fetch ) {
        
           $generation_closed=undef;
           $limit=2;
           $vtable=' v_active_animals_and_cages '
        }
    }
    
    my @breeds;
    my @actions=('',main::__('N open animals'),main::__('N open cages'),main::__('N multiple roosters in cages'),main::__('N lines'),main::__('N body weights roosters 20weeks'),main::__('N body weights roosters 40weeks'),main::__('N body weights hens 20weeks'),main::__('N body weights hens 40weeks'),main::__('N eggs weights 33weeks'),main::__('N eggs weights 53weeks'),main::__('N cages with collected eggs'),main::__('N cages with incubated eggs'),main::__('N cages with hatched eggs'),main::__('Next Steps'), '',main::__('Mating'),main::__('1st body weighing'),main::__('1st egg counting'), main::__('2nd body weighing'), main::__('2nd egg counting'), main::__('choose 1 cage per line'), main::__('collect eggs'), main::__('incubate eggs'), main::__('hatch eggs'), main::__('animal ID next generation'),main::__('close generation') );
    
    
    $sql=  "select distinct date_part('year', birth_dt) from $vtable where birth_dt notnull order by date_part('year', birth_dt) desc limit 1;";

    #-- loop over all sqls defined in @sqls; 
        
    #-- execute 
    $sql_ref = $apiis->DataBase->sys_sql($sql );
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status(1);
        $apiis->errors( $sql_ref->errors );
        return;
    }

    #-- actions depends on sql 
    if ( ( !$sql_ref->status ) and ( $sql_ref->{_rows} eq '0E0' ) ) {
        push( @{$data}, [main::__("Keine Geburtsjahrgänge gefunden")] );
        return $data, $structure;
    }
    else {

        while ( my $q = $sql_ref->handle->fetch ) {
            push(@birth_year, $q->[0]);
        }
    }

    #-- check for each birthyear 
    foreach my $vbirthyear (@birth_year) {

        my $vbirthyear1=$vbirthyear+1;
        my $sql="select distinct user_get_ext_code(db_breed, 's') as ext_breed from animal where date_part('year',birth_dt)='$vbirthyear' order by ext_breed;";

        @breeds=();
        my @a=();
        my @c=();
        my $vds='';

        $sql_ref = $apiis->DataBase->sys_sql($sql );
        
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status(1);
            $apiis->errors( $sql_ref->errors );
            return;
        }

        #-- actions depends on sql 
        if ( ( !$sql_ref->status ) and ( $sql_ref->{_rows} eq '0E0' ) ) {
            push( @{$data}, [main::__("Keine Rassen im Jahrgang [_1] gefunden"),$vbirthyear] );
            return $data, $structure;
        }
        else {

            while ( my $q = $sql_ref->handle->fetch ) {
                push (@breeds, $q->[0]);    
            }
        }


        push( @{$data}, ['<p style="text-align:left">'."<strong>".main::__('Geburtsjahrgang')." : $vbirthyear</strong><style>td, th{padding-right:20px;text-align: right}</style>"] );

        push( @{$data}, ['<table style="background-color:white;"><TR style="background-color:lightgray"><th style="text-align: left">'.main::__('Rassen').':</th><th>'.$vds.'</th><th>'.join('</th><th>',@breeds).'</th></TR>']);
        
        $sql="select ext_breed, 
                     user_get_check_open_animals(b.ext_breed,'$vbirthyear'),
                     user_get_check_open_cages(b.ext_breed,'$vbirthyear'),
                     user_get_check_multiple_roosters_in_cages(b.ext_breed,'$vbirthyear'),
                     user_get_check_multiple_cages(b.ext_breed,'$vbirthyear'),
                     user_get_check_body_weigh_20weeks(b.ext_breed,'$vbirthyear'),
                     user_get_check_body_weigh_40weeks(b.ext_breed,'$vbirthyear'),
                     user_get_check_body_weigh_20weeks_hens(b.ext_breed,'$vbirthyear'),
                     user_get_check_body_weigh_40weeks_hens(b.ext_breed,'$vbirthyear'),
                     
                     user_get_check_eggs_weigh_33weeks(b.ext_breed,'$vbirthyear'),
                     user_get_check_eggs_weigh_53weeks(b.ext_breed,'$vbirthyear'),
                     user_get_check_eggs_collected(b.ext_breed,'$vbirthyear'),
                     user_get_check_eggs_incubated(b.ext_breed,'$vbirthyear'),
                     user_get_check_eggs_hatched(b.ext_breed,'$vbirthyear'),
                     user_get_check_open_animals_without_cages(b.ext_breed,'$vbirthyear'),
                     user_get_check_open_animals_without_cages(b.ext_breed,'$vbirthyear1')

              from (select distinct user_get_ext_code(db_breed, 's') as ext_breed from animal where date_part('year',birth_dt)='$vbirthyear' order by ext_breed) as b";
        $sql_ref = $apiis->DataBase->sys_sql($sql);
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status(1);
            $apiis->errors( $sql_ref->errors );
        }
        else {
            while ( my $q = $sql_ref->handle->fetch ) {

                $hs{$q->[0]}=[@$q];
            }
        }


        for (my $i=1; $i<14; $i++) {
            my @traits;

            foreach (sort keys %hs) {
        
                push(@traits, $hs{$_}->[$i]);
            }
            push(  @{$data}, ['<TR><td style="text-align:left">'.$actions[$i].'</td><td></td><td>'.join('</td><td>',@traits).'</td></TR>'] );
        }

        #0 = no open cages, 1 one cage per line, 2 more then one per line 
        my $color;

        #-- Loop over all breeds 
        for (my $i=16; $i<27; $i++) {
            my @traits;

            foreach (sort keys %hs) {
                

                my $hsbreed=$_;

                my $check='3';
                my $vref="#"; 
                my $verrref; 
                #-- mating

                if ($i==16) {

                    $vds='DS06';
                    
                    $color="#EFF8FB";
                    
                    my $year=$vbirthyear;
                    my $breed=$hs{$_}->[0];

                    ($hs_cage, $hscheck, $hsline)=
                        CheckLines::CheckLines($apiis,$hscheck,{ 'year'=>$year,'breed'=>$breed,'ext_id'=>$ext_id});

                    ($hs_cage, $config)=CheckLines::EvaluateLines($apiis, $hs_cage, $hsline, $config, $hscheck);

                    #-- wenn Tiere ohne Käfige 
                    if ($hs{$_}->[14] > 0) {
                     
                        if (($hs{$_}->[1]>0) and ($hs{$_}->[3]>0))  {
                        
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
                                        db_breed=(select db_code from codes where class='BREED' and ext_code='$hs{$_}->[0]')) as a
                                group by db_cage 
                                having  count(db_cage)>1)"    ;
                            
                            system("psql chick -U apiis_admin -A -q -F ',' -c ".'"'.$sql.'"'
                                    .' >$APIIS_LOCAL/tmp/multiple_roosters_in_cage_'.$hs{$_}->[0].'.csv');
                            
                            $verrref='/tmp/multiple_roosters_in_cage_'.$hs{$_}->[0].'.csv';
                            $check='3';
                        }
                        elsif ($#{$config->{'errors'}->{ $vbreed }}>0) {
                            $vref='/cgi-bin/GUI?user='.$apiis->{'User'}->{'_id'}.'&sid='.$apiis->{'_cgisave'}->{'sid'}
                                  .'&m=chick&o=htm2htm&g='.$apiis->APIIS_LOCAL.'%2Fetc%2Fmenu%2F3_Reports%2FCagesBook.rpt&year='
                                  .$year.'&breed='.$breed.'&ext_id=&Field_514=Create+CagesBook';
                            $check='2';
                        }
                        elsif (($hs{$_}->[1]>0) and ($hs{$_}->[2]>0)) {
                            $vref='/cgi-bin/GUI?user='.$apiis->{'User'}->{'_id'}.'&sid='.$apiis->{'_cgisave'}->{'sid'}
                                  .'&m=chick&o=htm2htm&g='.$apiis->APIIS_LOCAL.'%2Fetc%2Fmenu%2F3_Reports%2FCagesBook.rpt&year='
                                  .$year.'&breed='.$breed.'&ext_id=&Field_514=Create+CagesBook';
                            $check='1';
                        }
                        else {    
                            $check='2';
                        }

                    }
                    else {
                        $vref='/cgi-bin/GUI?user='.$apiis->{'User'}->{'_id'}.'&sid='.$apiis->{'_cgisave'}->{'sid'}.'&m=chick&o=htm2htm&g='.$apiis->APIIS_LOCAL.'%2Fetc%2Fmenu%2F3_Reports%2FCagesBook.rpt&year='.$year.'&breed='.$breed.'&ext_id=&Field_514=Create+CagesBook';
                        $check='1';
                    }
                }

                #-- weighing, counting
                if (($i>16 and $i<21) )  {

                    $color="#CEECF5";
                    $check='2';
                    if ($i==17 and (($hs{$_}->[5] > 0) or ($hs{$_}->[7] > 0))) {
                        $check='1';
                    }

                    if ($i==19 and (($hs{$_}->[6] > 0) or ($hs{$_}->[8] > 0))) {
                        $check='1';
                    }
                
                    if ($i==18 and ($hs{$_}->[9] > 0) ) {
                        $check='1';
                    }
                    
                    if ($i==20 and ($hs{$_}->[10] > 0) ) {
                        $check='1';
                    }

                    if ($i==18 or $i==20) {
                        #-- sql to export input list for eggs 
                        $sql="set datestyle to 'german'; select x.breed, x.cage, x.event_dt as date_33_weeks, x.number_hens  as number_hens_33_weeks, x.total_weight_eggs as totalweigh_33_weeks, x.n_eggs as n_eggs_33_weeks, y.event_dt as date_53_weeks, y.number_hens  as number_hens_53_weeks, y.total_weight_eggs as totalweigh_53_weeks, y.n_eggs as n_eggs_53_weeks from (select distinct user_get_ext_code(c.db_breed,'s') as breed,  user_get_ext_id(c.db_cage)::numeric as cage, event_dt, user_get_ext_code(z.db_event_type,'e'), number_hens, total_weight_eggs, n_eggs from  v_active_animals_and_cages c left outer join (select a.*,b.* from eggs_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingeggs33weeks') z on c.db_cage=z.db_cage  where user_get_ext_id(c.db_cage)>'1' order by user_get_ext_id(c.db_cage)::numeric, breed) as x , (select distinct user_get_ext_code(c.db_breed,'s') as breed,  user_get_ext_id(c.db_cage)::numeric as cage, event_dt, user_get_ext_code(z.db_event_type,'e'), number_hens, total_weight_eggs, n_eggs from  v_active_animals_and_cages c left outer join (select a.*,b.* from eggs_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingeggs53weeks') z on c.db_cage=z.db_cage  where user_get_ext_id(c.db_cage)>'1' and user_get_ext_code(c.db_breed,'s')='".$hs{$_}->[0]."' order by user_get_ext_id(c.db_cage)::numeric, breed) as y where x.cage=y.cage ;";

                        system("psql chick -U apiis_admin -A -q -F ',' -c ".'"'.$sql.'"'.' >$APIIS_LOCAL/tmp/ds08_inputlist_eggs_'.$hs{$_}->[0].'.csv');
                        
                        $vref="/tmp/ds08_inputlist_eggs_".$hs{$_}->[0].".csv";
                    
                        $vds='DS08';
                    
                    }

                    if ($i==17 or $i==19) {

                        #-- sql to export input list for weights 
                        $sql="set datestyle to 'german'; select distinct x.breed,
                            x.cage, 
                            (select b.event_dt from pt_cage a inner join event b on a.db_event=b.db_event where user_get_ext_code(b.db_event_type,'e')='weighingbody20weeks' and hen_number='1' and db_cage=x.db_cage) as date_body_wt_20_weeks,
                            (select user_get_ext_animal(db_animal) from animal where animal.db_cage=x.db_cage and db_sex=(select db_code from codes where class='SEX' and ext_code='1' )) as rooster, 
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
                            (select user_get_ext_animal(db_animal) from animal where animal.db_cage=x.db_cage and db_sex=(select db_code from codes where class='SEX' and ext_code='1' )) as rooster, 
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
                            from (select distinct user_get_ext_code(c.db_breed,'s') as breed,  user_get_ext_id(c.db_cage)::numeric as cage, c.db_cage, db_animal from  v_active_animals_and_cages c where user_get_ext_id(c.db_cage)>'1' and user_get_ext_code(c.db_breed,'s')='".$hs{$_}->[0]."')  x
                            order by x.breed, x.cage"; 
                        
                        system("psql chick -U apiis_admin -A -q -F ',' -c ".'"'.$sql.'"'.' >$APIIS_LOCAL/tmp/ds07_inputlist_weights_'.$hs{$_}->[0].'.csv');
                        
                        $vref="/tmp/ds07_inputlist_weights_".$hs{$_}->[0].".csv";
                    
                        $vds='DS07';
                    
                    }
                    
                }
              
                if (($i >20) and ($i<25)) { 

                    $color="#58D3F7";
                    $check='1';

                    #-- Ladestrom  
                    #-- hatch-eggs

                    $vds='DS01-04';
                    
                    open (OUT, ">".$apiis->APIIS_LOCAL."/tmp/ds01-04_hatch_cages_".$hs{$_}->[0].".csv");
                    print OUT main::__("rase").','.main::__('far').','.main::__('bur').','.main::__('velge ny generasjon').','.main::__('dato innlagte egg').','.main::__('innlagte egg').','.main::__('til klekking').','.main::__('klekka').','.main::__('dato klekka')."\n";
                    
                    $sql="select distinct user_get_ext_code(b.db_breed,'s') as breed, b.db_sire, user_get_ext_id(b.db_cage)::numeric, '' as sel, user_get_event_dt(a.db_event) as event_dt, collected_eggs, incubated_eggs, hatched_eggs, hatch_dt from v_active_animals_and_cages b left outer join hatch_cage a on a.db_cage=b.db_cage where user_get_ext_code(b.db_sex,'e')='2' and  user_get_ext_code(b.db_breed,'s')='".$hs{$_}->[0]."' order by user_get_ext_id(b.db_cage)::numeric, breed ";
                    
                    
                    my $sql_ref = $apiis->DataBase->sys_sql($sql);
                    if ( $sql_ref->status and ( $sql_ref->status == 1) ) {
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
        
                            no warnings;
                            print OUT join(',',@$q)."\n";
                            use warnings;
                        }
                    }
                    close(OUT);            
                    
                    $vref='/tmp/ds01-04_hatch_cages_'.$hs{$_}->[0].'.csv';
               
                   $check='1' if ($i==22 and ($hs{$_}->[11] >  0) );
                   $check='2' if ($i==22 and ($hs{$_}->[11] == 0) );
                        
                   $check='1' if ($i==23 and ($hs{$_}->[12] >  0) );
                   $check='2' if ($i==23 and ($hs{$_}->[12] == 0) );
                        
                   $check='1' if ($i==24 and ($hs{$_}->[13] >  0) );
                   $check='2' if ($i==24 and ($hs{$_}->[13] == 0) );
                }

                
                if ($i==21) {
                   
                    if ($hs{$_}->[13] == 0) {
                        $check='2';
                    } else {
                        $check='1';
                    }

                    #-- Check errors
                    my %hs_cage_m;
                    my %hs_cage_w;

                    $sql="select distinct user_get_full_db_unit(db_cage) ,user_get_full_db_animal( db_sire), (select ext_id::numeric from unit where db_unit=db_cage) from v_active_animals_and_cages where db_sex=(select db_code from codes where class='SEX' and ext_code='2') and user_get_ext_code(db_breed,'s')='".$hs{$_}->[0]."' order by (select ext_id::numeric from unit where db_unit=db_cage);";
                    
                    $sql_ref = $apiis->DataBase->sys_sql($sql);
                    
                    if ($sql_ref->status and ( $sql_ref->status == 1 )) {
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

                    $sql="select distinct user_get_full_db_unit(db_cage), user_get_full_db_animal(db_sire), (select ext_id::numeric from unit where db_unit=db_cage) from v_active_animals_and_cages where db_sex=(select db_code from codes where class='SEX' and ext_code='1') and user_get_ext_code(db_breed,'s')='".$hs{$_}->[0]."' order by (select ext_id::numeric from unit where db_unit=db_cage);";
                    
                    $sql_ref = $apiis->DataBase->sys_sql($sql);
                    
                    if ($sql_ref->status and ( $sql_ref->status == 1 )) {
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
                        
                        if (!exists $hs_cage_m{$vcage}) {
                            $data1.=$vcage.','.main::__("No rooster in cage").','.join('|',@{$hs_cage_w{$vcage}}).','.join('|',@{$hs_cage_m{$vcage}})."\n"
                        }
                        if ((exists $hs_cage_m{$vcage}) and  (($#{$hs_cage_m{$vcage}}>1 ) or ($#{$hs_cage_w{$vcage}}>1))) {
                            $data1.=$vcage.','.main::__("Multiple roosters in cage").','.join('|',@{$hs_cage_w{$vcage}}).','.join('|',@{$hs_cage_m{$vcage}})."\n"
                        }
                    }
                    if ($data1) {
                        open (OUT, ">".$apiis->APIIS_LOCAL."/tmp/sex_errors_in_cages_".$hs{$_}->[0].".csv") || print main::__("Fehler"); 
                        print OUT main::__('Cage-ID').','.main::__('Error message').','.main::__('SireID of Hens').','.main::__('SireID of roosters')."\n";
                        print OUT $data1;
                        close (OUT);
                        
                        $verrref="/tmp/sex_errors_in_cages_".$hs{$_}->[0].".csv"
                    }
                }
               
                #-- wingnumbers
                if ($i==25)   {

                    $vds='DS05';

                    my $ext_id;
                    my $year=$vbirthyear;
                    my $breed=$hs{$_}->[0];
                    my $hscheck=$hs_cage_w;
                    my $hs_cage;
                    my $hsline;
                    my $config={};
                    $config->{'errors'}={};
                       
                    # hole alle Käfignummern von allen Tieren (auch nicht aktive) mit dem entsprechenden Geburtsjahr 
                    my $sql=" select distinct a.db_cage as ext_id 
                        from animal a inner join unit b on a.db_cage=b.db_unit 
                        where date_part('year', birth_dt)='$year' ";

                    $sql.=" and user_get_ext_code(db_breed,'s')='$breed'" if ($breed);
            
#$hscheck->{ $q->[0] } = {'cage'=>{'11'=>{},'22'=>{},'21'=>{}},'line'=>{} };
                    $hscheck={};
                    
                    ($hs_cage, $hscheck, $hsline)=
                        CheckLines::CheckLines($apiis,$hscheck,{ 'year'=>$year,'breed'=>$breed,'ext_id'=>$ext_id});

                    #-- Anzahl gesammelter Eier pro Käfig und Rasse 
                    my $sql1="select a.db_cage, c.event_dt, user_get_ext_code(c.db_event_type,'s'), 
                                     collected_eggs || ' / ' || incubated_eggs || ' / ' || hatched_eggs  
                              from hatch_cage a inner join animal b on a.db_cage=b.db_cage 
                              inner join event c on a.db_event=c.db_event 
                              where date_part('year', birth_dt)='$year' ";

                    $sql1.=" and user_get_ext_code(db_breed,'s')='$breed'" if ($breed);
                    
                    $sql1.=" union
                             select a.db_cage, c.event_dt, user_get_ext_code(c.db_event_type,'s'), 
                                    number_hens || ' / ' || n_eggs || ' / ' || total_weight_eggs  
                             from eggs_cage a inner join animal b on a.db_cage=b.db_cage 
                             inner join event c on a.db_event=c.db_event 
                             where date_part('year', birth_dt)='$year'";
                    
                    $sql1.=" and user_get_ext_code(db_breed,'s')='$breed'" if ($breed);

                    my $sql_ref1 = $apiis->DataBase->sys_sql($sql1);
                    goto ERR if (  $sql_ref1->status and ($sql_ref1->status == 1 ));

                    my $vbreed;

                    while ( my $q1 = $sql_ref1->handle->fetch ) {
                
                        my $vcage= $q1->[0];

                        push(@{$hs_cage->{ $vcage }->{'events'}->{'Data'}}, [$q1->[1], $q1->[2], $q1->[3]]);    
                    
                        #-- Sire der Hennen für den Cage holen
                        $vbreed=$hs_cage->{ $vcage }->{'general'}->{'Data'}->[0];
                        my $excage=$hs_cage->{ $vcage }->{'general'}->{'Data'}->[1];
                        my $vss =$hs_cage->{ $vcage }->{'animals'}->{'Data'}->[0][2];
                        my $vsd =$hs_cage->{ $vcage }->{'animals'}->{'Data'}->[1][2];
                        my $vsire =$hs_cage->{ $vcage }->{'animals'}->{'Data'}->[1][2];

                        #-- Käfig zur Linie schreiben, wenn Eier gesammelt wurden 
                        $hsline->{ $vbreed }->{ $vsire }->{'eggs'}->{  $vss.':::'.$vsd } = $excage;  
                    } 

                    ($hs_cage, $config)=CheckLines::EvaluateLines($apiis, $hs_cage, $hsline, $config, $hscheck);

                    #-- wenn ein Fehler in den Linien, dann Ausgabe der Datei aber über roten Punkt 
                    open (OUT, ">".$apiis->APIIS_LOCAL."/tmp/ds05_wingnumbers_".$hs{$_}->[0].".csv");
                
                    print OUT main::__('wingnumber').','.main::__('sex').','.main::__('farnumber').','.main::__('breed').','.main::__('cagenumber')."\n";
                    close(OUT);            
                    
                   
                    my $year1=$year+1;

                    $sql="select user_get_ext_animal(db_animal)  from animal where db_breed=(select db_code from codes where class='BREED' and ext_code='$vbreed') and date_part('year', birth_dt)='$year1'";

                    my $sql_ref1 = $apiis->DataBase->sys_sql($sql);
                    goto ERR if (  $sql_ref1->status and ($sql_ref1->status == 1 ));

                    my $vcheck=0;
                    while ( my $q1 = $sql_ref1->handle->fetch ) {
                        $vcheck++;
                    }

                    if (($hs{$_}->[13]>0) and ($hs{$_}->[15]==0)) {
                        $check='2';
                    }
                    if (($hs{$_}->[13]>0) and ($hs{$_}->[15]>0)) {
                        $check='1';
                    }
                        
                    $vref='/tmp/ds05_wingnumbers_'.$hs{$_}->[0].'.csv';
               
                    if ($vcheck==0) {
                        $check=10 if (scalar keys %{$config->{'warnings'}} > 0) ;
                        $check=10 if (scalar keys %{$config->{'errors'}} > 0) ;
                    }
                    
#                        $verrref='/cgi-bin/GUI?user='.$apiis->{'User'}->{'_id'}.'&sid='.$apiis->{'_cgisave'}->{'sid'}.'&m=chick&o=htm2htm&g='.$apiis->APIIS_LOCAL.'%2Fetc%2Fmenu%2F3_Reports%2FCagesBook.rpt&year='.$year.'&breed='.$breed.'&ext_id=&Field_514=Create+CagesBook';
#                    if (scalar keys %{$config->{'errors'}}>0) {
#                        $check=3;
#                    }
                }

                #-- Alle offenen Tiere und Käfige schließen 
                if ($i == 26) {
                    $check=3; 
                    
                    $vds='DS10';

                    
                    if (($hs{$_}->[2]>0) and ($hs{$_}->[15]>0)) {
                        $check=2;
                    }
                    if (($hs{$_}->[2]==0) and ($hs{$_}->[15]==0)) {
                        $check=1;
                    }
                    $vref='/cgi-bin/GUI?user='.$apiis->{'User'}->{'_id'}.'&sid='.$apiis->{'_cgisave'}->{'sid'}.'&m=chick&o=htm2htm&g='.$apiis->APIIS_LOCAL.'%2Fetc%2Fmenu%2F0_Enter%2FFileUpload.rpt&importfilter=LO_DS10&onlycheck=ON&action=insert&Field_514=Upload+file&breed='.$hsbreed;
                }

                my $tt;
                if ($verrref) {
                    $tt='<a href="'.$verrref.'" target="CageBook"><img width="22px" src="/icons/Error.jpeg"/></a>';
                }
                elsif (($i>16) and ((($hs{$_}->[1] == 0) or ($hs{$_}->[2] == 0)) and ($hs{$_}->[14] > 0))) {
                   $tt='<img width="22px"  src="/icons/Exit.jpeg"/>';
                }
                elsif ($check==1) {
                   $tt='<a href="'.$vref.'" target="_blank"><img width="22px" src="/icons/OK.jpeg"/></a>';
                    
                }
                elsif ($check==2) {
                    $tt='<a href="'.$vref.'" target="_blank"><img width="22px" src="/icons/Weiter.jpeg"/></a>';
                }
                elsif ($check==10) {
                    $tt='<a href="'.$vref.'" target="_blank"><img width="22px" src="/icons/WeiterWarning.jpeg"/></a>';
                }
                else {
                   $tt='<img width="22px"  src="/icons/Exit.jpeg"/>';
                }

                push(@traits, $tt);
            }
            
            $color="#FFFFFF";

            push(  @{$data}, ['<TR style=" margin-top:-2px; background-color:'.$color.'"><td style="text-align:left">'.$actions[$i].'</td><td>'.$vds.'</td><td>'.join('</td><td>',@traits).'</td></TR>'] );
        }

        push(  @{$data}, ['</table>']);
        
        #-- check for open cages;
        my $opencage;
        my $hatched_eggs;
        map { if ($hs{$_}->[3])  {$opencage=1}} keys %hs;
        map { if ($hs{$_}->[11]) {$hatched_eggs=1}} keys %hs;




        if ($generation_closed) {

            open (OUT, ">".$apiis->APIIS_LOCAL."/tmp/cagenumbers.csv");
            print OUT main::__('breed').','.main::__('number_id').','.main::__('wingnumber').','.main::__('sex').','.main::__('far').','.main::__('cagenumber')."\n";
            $sql="select user_get_ext_code(db_breed,'s') as breed, (select  user_get_ext_id(db_unit) from transfer inner join animal  on a.db_animal=animal.db_animal limit 1) as ext_id,  user_get_ext_animal(db_animal) as animal, user_get_ext_code(db_sex,'e') as sex, (select far_id from animal inner join hatch_cage on animal.db_cage=hatch_cage.db_cage where db_animal=a.db_sire), '' as cage from animal a where a.db_cage isnull  and db_breed notnull;";
            
            my $sql_ref = $apiis->DataBase->sys_sql($sql);
            if ( $sql_ref->status and ($sql_ref->status == 1 )) {
                $apiis->status(1);
                $apiis->errors( $sql_ref->errors );
            }
            if ( ( !$sql_ref->status ) and ( $sql_ref->{_rows} eq '0E0' ) ) {
                #push( @{$data}, ["No open cages found"] );
            }
            else {
                while ( my $q = $sql_ref->handle->fetch ) {
                
                    map {$_='' if (!defined $_)} @{$q};

                    print OUT "$q->[0],$q->[1],$q->[2],$q->[3],$q->[4],\n";
                }
            }
            close(OUT);            
            push(@a, '<a href="/tmp/cagenumbers.csv">'.main::__('Inputlist cagenumbers').'</a>');
        }

        #-- there are open cages 
        if ($opencage) {
            
            

        
            
        }

        push(  @{$data}, ['<style>body{text-align:left}</style>']);
    }

    if ( $#{$data} == -1 ) {
        push( @{$data}, main::__('Keine Daten') );
    }
    return $data, $structure;

}

1;

