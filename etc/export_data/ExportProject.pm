sub ExportProject  {
    my ( $self ) = @_;
    my $cmd;
    my  $out;

    $cmd.='rm -f '.$apiis->APIIS_LOCAL.'/tmp/*';

    system($cmd);
   
    my $vvpath=$apiis->APIIS_LOCAL.'/tmp/';
    #-- create table 
    print '<table><TR><th>Tables</td></TR>';

    foreach my $vtable ('v_animal', 'v_codes','v_unit','v_eggs_cage','v_event', 'v_hatch_cage','v_locations','v_possible_dams','v_pt_cage','v_pt_indiv','v_transfer' ) {
        
        my $vpath=$apiis->APIIS_LOCAL.'/tmp/'.$vtable.'.txt';

        my $cmd="psql chick -U apiis_admin -A -q -F'|' -c ".'"'." set datestyle to 'iso'; select * from $vtable;".'" > '.$vpath;

        system($cmd);

        opendir(my $dh, $apiis->APIIS_LOCAL.'/tmp')  || print "fehler in dir";
        my @dir=  readdir($dh);
        closedir($dh);
        #-- loop over this files 
        foreach (sort @dir) {
            #-- if filename is a dir, then next 
            next if (-d $_);
            next if ($_!~/^$vtable/);
            
            print '<TR><td><a target="_blank" href="/tmp/'.$_.'">'.$_.'</a></td></TR>';
        }
         
    }

    print "</table>";
   
    print "<p>";

    my $cmd="tar cfz ".$apiis->APIIS_LOCAL.'/tmp/'."chick.tar.gz ".$apiis->APIIS_LOCAL.'/tmp/'."*";

    system($cmd);

    print '<a target="_blank" href="/tmp/chick.tar.gz">chick.tar.gz</a>';
    $out=__("Project exported.");
EXIT:
    
    return [[__('Auslagerung erfolgreich')],[ $out ]], ['code1'];
}
1;

