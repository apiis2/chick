sub ReplaceDatabase {
    my ( $self, $dump ) = @_;
    my $structure = ['field'];

    if (!$dump or ( $dump eq '' )) {
        push( @{$data}, [__('no dump selected')] );
        return $data, $structure;
    }   


    my $command="pg_dump chick -U apiis_admin >$ENV{'APIIS_LOCAL'}/tmp/chick.last.dump; gzip -f $ENV{'APIIS_LOCAL'}/tmp/$dump";
    system($command );
    push(@{$data}, [__('Last dump before replacing: ').'<a href="'.$ENV{'APIIS_HOME'}.'/tmp/chick.last.dump.gz">'.$ENV{'APIIS_HOME'}.'/tmp/chick.last.dump.gz</a>']);

    $apiis->disconnect_project;

    #-- Drop DB 
    $command="dropdb chick -U apiis_admin" ;
    system($command);
    push(@{$data}, [__('DropDB chick')]);


    #-- check id droped
    $command="psql -H -l -U apiis_admin >$ENV{'APIIS_LOCAL'}/tmp/psql-l.csv" ;
    system($command);

    my $found;

    open(IN,"<$ENV{'APIIS_LOCAL'}/tmp/psql-l.csv") || push(@{$data}, [__("can [_1] not open", "$ENV{'APIIS_LOCAL'}/tmp/psql-l.csv") ] );
    while (<IN>) {
        $found=1 if ($_=~/chick/) ;
    }
    close(IN);

    if (!$found) {
        push(@{$data}, [__('Database chick was droped')]);
    }
    else {
        push(@{$data}, [__('ERROR: Database chick was not droped')]);
        goto LAST;
    }

    #-- Createdb  
    $command="createdb chick -U apiis_admin;";
    system($command );
    push(@{$data}, [__('CreateDB chick ')]);
    
    #-- check if created
    $command="psql -H -l -U apiis_admin >$ENV{'APIIS_LOCAL'}/tmp/psql-l.csv" ;
    system($command);

    #-- 
    open(IN,"<$ENV{'APIIS_LOCAL'}/tmp/psql-l.csv") || push(@{$data}, [__("can [_1] not open", "$ENV{'APIIS_LOCAL'}/tmp/psql-l.csv") ] );
    while (<IN>) {
        $found=1 if ($_=~/chick/) ;
    }
    close(IN);

    if ($found) {
        push(@{$data}, [__('Database chick was created')]);
    }
    else {
        push(@{$data}, [__('ERROR: Database chick was not created')]);
        goto LAST;
    }

    #-- load data 
    $command="psql chick -q -U apiis_admin <$ENV{'APIIS_LOCAL'}/dump/$dump >/dev/null";
    system($command );
    push(@{$data}, [__('Load DB chick file [_1]',"$ENV{'APIIS_LOCAL'}/dump/$dump")]);

    #-- Datencheck
    my $c="select 'animal' as tablename, (select count(db_animal) as Records from transfer)  as Records union select 'hatch_cage'  as Table, (select count(db_cage)  as Records from hatch_cage)  as Records union select 'event'  as Table, (select count(db_event)  as Records from event)  as Records union select 'address'  as Table, (select count(db_address)  as Records from address)  as Records union select 'codes'  as Table, (select count(db_code)  as Records from codes)  as Records union select 'unit'  as Table, (select count(db_unit)  as Records from unit)  as Records  union select 'eggs_cage'  as Table, (select count(db_cage)  as Records from eggs_cage)  as Records union select 'pt_cage'  as Table, (select count(db_cage)  as Records from pt_cage)  as Records union select 'possible_dams'  as Table, (select count(db_animal)  as Records from possible_dams)  as Records union select 'pt_indiv'  as Table, (select count(db_animal)  as Records from pt_indiv)  as Records order by tablename        ";

    $command='psql chick -H -U apiis_admin -c "'.$c.'"  >'.$ENV{'APIIS_LOCAL'}.'/tmp/psql-l.csv';

    system($command );
   
    my @info;
    open(IN,"<$ENV{'APIIS_LOCAL'}/tmp/psql-l.csv") || push(@{$data}, [__("can [_1] not open", "$ENV{'APIIS_LOCAL'}/tmp/psql-l.csv") ] );
    
    while (<IN>) {
        push(@info, $_) ;
    }
    close(IN);

    push(@{$data}, [join(' ',@info)]);

    push(@{$data}, [__('OK: DB chick was loaded')]);

    #-- file löschen
    system("rm $ENV{'APIIS_LOCAL'}/tmp/psql-l.csv");


LAST:

    return $data, $structure;

}

1;

