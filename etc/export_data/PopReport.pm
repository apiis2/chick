sub ExportPopReport  {
    my ( $self,$breed,$only_export ) = @_;
    my $cmd;
    my  $out;

    my  @breeds=('BI','JH','NB1','NB4','NB7','NB8','RK','RRI','SM','SX','TPR');

    $cmd.='rm -f '.$apiis->APIIS_LOCAL.'/tmp/*';

    system($cmd);
   
    my $sql="select  distinct  user_get_ext_code(db_breed, 's') as breed from animal where db_breed  notnull order by user_get_ext_code(db_breed, 's') ;";



    #-- create table 
    print '<table ><TR><td>';

    foreach my $breed (@breeds) {
        
        print  "<strong>$breed</strong> <br>";
        my $vpath=$apiis->APIIS_LOCAL.'/tmp/'.$breed.'.ped';

        my $cmd="psql chick -U apiis_admin -A -q -t -F'|' -c ".'"'." set datestyle to 'iso'; select db_animal, case when db_sire=1 then 'unknown_sire' else db_sire::text end, case when  db_dam=2 then 'unknown_dam' else db_dam::text end, birth_dt, case when b.ext_code='1' then 'M' else 'F' end  from animal a inner join codes b on a.db_sex=b.db_code where db_breed=(select db_code from codes where short_name='".$breed."' and class='BREED') and db_sex in (select db_code from codes where (ext_code='1' or ext_code='2') and class='SEX');".'" > '.$vpath;

        system($cmd);

        opendir(my $dh, $apiis->APIIS_LOCAL.'/tmp')  || print "fehler in dir";
        my @dir=  readdir($dh);
        closedir($dh);
        #-- loop over this files 
        foreach (sort @dir) {
            #-- if filename is a dir, then next 
            next if (-d $_);
            next if ($_!~/^$breed/);
            
            print '<a target="_blank" href="/tmp/'.$_.'">'.$_.'</a><br>';
        }
         
        print '</td><td style="padding:10px">';
    }

    print "<td></TR></table>";

    $out=__("PopReport exported.");
EXIT:
    
    return [[__('Auslagerung erfolgreich')],[ $out ]], ['code1'];
}
1;

