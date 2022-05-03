package ListDumps;

sub listdump {

    $apiis = shift;

    my $dir=[];

    opendir(my $dh, $apiis->APIIS_LOCAL."/dump") || die "Can't open $some_dir: $!";
    while (readdir $dh) {

        next if ($_!~/dump/);

        push(@$dir, [$_,$_]);
    }
    closedir $dh;

    return $dir;
}

1;
