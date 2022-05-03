package chick;
our $apiis;

sub SaveDatabase {
    my $apiis=shift;
    my $ls=shift;
    my $breeds=shift;
    my $birthyear=shift;
    my $year=shift;
    my $fileimport;

    if (-d $apiis->APIIS_LOCAL.'/dump/') {
        
        my $command='pg_dump chick -U apiis_admin > '.$apiis->APIIS_LOCAL.'/dump/'.$ls.'_BY'.$birthyear.'_'.$year.'_'.$breeds.'_$(date +%d.%m.%Y-%H:%M).dump';

        system($command);

#        $command='gzip '.$apiis->APIIS_LOCAL.'/dump/'.$ls.'_BY'.$birthyear.'_'.$year.'_'.$breeds.'_$(date +%d.%m.%Y-%H:%M).dump';
#        
#        system($command);
    }

    if (-d $apiis->APIIS_LOCAL.'/archiv/' and $fileimport) {
    
        #-- save loading stream
        
        my $command='mv -f '."$fileimport ".$apiis->APIIS_LOCAL.'/archiv/'.$ls.'_BY'.$birthyear.'_'.$year.'_'.$breeds.'_$(date +%d.%m.%Y-%H:%M).csv';
        
        system($command);
        
    }  
}





sub CheckStatusDS {
    my $apiis= shift;
    my $json = shift;
    my $breed= shift;

    #-- Get Status
    my $sql1="select z0.ext_breed,  z1.nanimal as aaac, z2.nanimal as aaacwe, z3.nanimal as aaacwewp, z4.nanimal as aaa

from  
(select ext_code as ext_breed from codes where class='BREED') as z0 left outer join  

/*keine Tiere in aktiven Käfigen => DS06, Sonst DS01-04*/
(select count(db_animal) as nanimal, user_get_ext_code(db_breed,'s') as ext_breed from v_active_animals_and_cages group by db_breed order by ext_breed) as z1 on z0.ext_breed=z1.ext_breed

left outer join 
 /*Tiere in aktiven Käfigen => DS06, Sonst DS01-04*/
(select count(a.db_animal) as nanimal, user_get_ext_code(a.db_breed,'s') as ext_breed from v_active_animals_and_cages a inner join  hatch_cage c on a.db_cage=c.db_cage  group by a.db_breed order by ext_breed) as z2 on z0.ext_breed=z2.ext_breed

left outer join 
 (select count(a.db_animal) as nanimal, user_get_ext_code(b.db_breed,'s') as ext_breed from entry_transfer a inner join animal b on a.db_animal=b.db_animal where b.db_sire in (select db_animal from v_active_animals_and_cages) group by b.db_breed order by ext_breed ) as z3 on z0.ext_breed=z3.ext_breed

left outer join 
/* aktive Tiere ohne Käfige => DS10 zu Ende und DS06 noch nicht gestartet*/
(select count(a.db_animal) as nanimal, user_get_ext_code(b.db_breed,'s') as ext_breed from entry_transfer a inner join animal b on a.db_animal=b.db_animal where db_cage isnull group by b.db_breed order by ext_breed) as z4 on z0.ext_breed=z4.ext_breed;";

    my $sql_ref2= $apiis->DataBase->sys_sql( $sql1);
   
    # Auslesen des Ergebnisses der Datenbankabfrage
    
    my %hs_check;
    my $row1='';
    my %ds_status;

    while ( my $q = $sql_ref2->handle->fetch ) {

        #-- wenn Rasse definiert ist und nur diese betrachtet werden soll, dann andere überspringen 
        next if ($breed and ($breed ne $q->[0]));

        no warnings;
        $hs_check{$q->[0]}=[@$q];
        use warnings;
    }
   
    #-- Schleife über alle Rassen und DS-Status prüfen 
    foreach my $vbreed (sort keys %hs_check) {
    
        #-- Check auf korrekten Ladestrom
        #-- es gibt aktive Käfige, mit aktiven Tieren (Eltern) und aktive Tiere ohne Käfige (Nachkommen)
        if ($hs_check{$vbreed}->[1] and $hs_check{$vbreed}->[2] and $hs_check{$vbreed}->[3] and $hs_check{$vbreed}->[4]) {
           $hs_check{$vbreed}->[5]= 'DS05';
           $hs_check{$vbreed}->[6]= 'DS10';
        }

        #-- es gibt aktive Tiere ohne Käfige, aber keine aktiven Käfige
        elsif (!$hs_check{$vbreed}->[1] and !$hs_check{$vbreed}->[2] and !$hs_check{$vbreed}->[3] and $hs_check{$vbreed}->[4]) {
           $hs_check{$vbreed}->[5]= 'DS10';
           $hs_check{$vbreed}->[6]= 'DS06';
        }

        #-- es gibt aktive Tiere und aktive Käfige, aber keine Tiere ohne aktive Käfige
        elsif ($hs_check{$vbreed}->[1] and $hs_check{$vbreed}->[2] and !$hs_check{$vbreed}->[3] and !$hs_check{$vbreed}->[4]) {
           $hs_check{$vbreed}->[5]= 'DS06';
           $hs_check{$vbreed}->[6]= 'DS020304';
        }

        #-- es gibt aktive Tiere und aktive Käfige und gesammelte und gebrütete Eier (hatched cages) 
        elsif ($hs_check{$vbreed}->[1] and $hs_check{$vbreed}->[2] and !$hs_check{$vbreed}->[3] and $hs_check{$vbreed}->[4]) {
           $hs_check{$vbreed}->[5]= 'DS020304';
           $hs_check{$vbreed}->[6]= 'DS05';
        }
        else {
           $hs_check{$vbreed}->[5]= 'unknown status';
           $hs_check{$vbreed}->[6]= 'unknown status';
        }
    }

    $json->{'Before'}.=main::__("<h4><strong>".main::__("Database status (count of animals in each breed)")."</strong></h4>"); 
    $json->{'Before'}.='<table border=".5">';
    $json->{'Before'}.="<TR><th>".main::__('Breed')."</th><th>".main::__('DS06')."</th><th>".main::__('DS020304')."</th><th>".main::__('DS05')."</th><th>".main::__('DS10')."</th><th>".main::__('finished')."</th><th>".main::__('ready for')."</th></TR>";

    foreach (sort keys %hs_check) {
        $json->{'Before'}.='<TR><td>'.join('</td><td>',@{$hs_check{$_}}).'</td></TR>';    

        #-- check, ob alle Rassen den Ladestrom abgeschlossen haben 
        $ds_status{$hs_check{$_}->[5]}=1;
    }
    
    $json->{'Before'}.='</table><p>';
            
    $json->{'Before'}.=main::__('ready for:').'<br><small>';
    $json->{'Before'}.=main::__('- DS10: there are active cages with active animals (parents) AND active animals without cages (progenies)').'<br>';
    $json->{'Before'}.=main::__('- DS06: there are ONLY active animals without cages (next parent generation)').'<br>';
    $json->{'Before'}.=main::__('- DS020304: there are active animals in active cages').'<br>';
    $json->{'Before'}.=main::__('- DS05: there are hatched eggs/chicken from active cages').'<br></small>';

    $json->{'Critical'}=undef if ((scalar keys %ds_status) == 1);

    return ($json); 
}
1;

