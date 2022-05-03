#/usr/bin/perl

use strict;
use warnings;

open (IN, "2/merkebok.csv") || die "can not open merkebok.csv";
my @mb=<IN>;
close (IN);

open (IN, "2/klekkebok.csv") || die "can not open klekkebok.csv";
my @kb=<IN>;
close (IN);

open (IN, "2/body_weights.csv") || die "can not open body_weights.csv";
my @bw=<IN>;
close (IN);

my %hs_kb;
my %hs_kb_cage;
my %hs_mb_sire;
my %hs_mb_dam;

#-- Schleife über das gesamte merkebok zur Erstellung 
foreach (@kb) {
    
    chomp;

    #-- erste Zeile überspringen 
    next if ($_=~/year/);

    #-- Daten zerhacken 
    my @data=split('\|', $_);

    #-- Vorjahr 
    my $year=$data[0]-1;

    #-- cage_index=cage_number:::year 
    my $cage_year=$data[3].':::'.$year;

    #-- index=Far:::Rasse:::Jahr => Datensatz 
    my $far_index= $data[2].':::'.$data[1].':::'.$data[0];

    #-- index=Far:::Jahr => Datensatz 
    $hs_kb_cage{ $far_index }=$cage_year;
}

#-- Schleife über das gesamte klekkebook
foreach (@mb) {
   
    chomp;

    #-- erste Zeile überspringen 
    next if ($_=~/year/);

    #-- Daten zerhacken 
    my @data=split('\|', $_);

    my $cage_index= $data[2].':::'. $data[3];

    $hs_mb_sire{ $cage_index }=[] if (!exists $hs_mb_sire{ $cage_index });
    $hs_mb_dam{ $cage_index  }=[]  if (!exists $hs_mb_dam{ $cage_index });

    #-- index=cage:::year:::sex => Datensatz 
    push(@{$hs_mb_sire{ $cage_index }},[$data[7]]) if ($data[6] eq '1');
    
    #-- index=cage:::year:::sex => Datensatz 
    push(@{$hs_mb_dam{ $cage_index }},[$data[7]])  if ($data[6] eq '2');
}


open (OUT, ">2/merkebok.csv") || die "kann 2/merkebok.csv nicht öffnen";

#-- Schleife über das gesamte merkebok
foreach (@mb) {
   
    chomp;

    my $db_dam=2;
    my $db_sire=1;

    #-- erste Zeile überspringen 
    next if ($_=~/year/);

    #-- Daten zerhacken 
    my @data=split('\|', $_);

    #-- index=Far:::Rasse:::Jahr => Datensatz 
    my $far_index= $data[4].':::'.$data[5].':::'.$data[3];

    my $cage_year=$hs_kb_cage{ $far_index };    

    if ($cage_year) {

        $db_sire=$hs_mb_sire{ $cage_year } if (exists $hs_mb_sire{ $cage_year });

        $db_dam=$hs_mb_dam{ $cage_year } if (exists $hs_mb_dam{ $cage_year });
    }

    if (($db_sire ne '1')  and ( $db_sire->[0][0] ))  {
        $data[8]=$db_sire->[0][0]; 
    }
    if (($db_dam ne '2')  and ( $db_dam->[0][0] ))  {
    
        for (my $i=9; $i<=18; $i++) {
            $data[$i]=$db_dam->[$i-9][0];
            $data[$i]=''  if (!$data[$i]);
        }
    }

    print OUT join('|',@data)."\n";

}

close(OUT);

open (OUT, ">2/body_weights.csv") || die "kann 2/body_weights.csv nicht öffnen";

#-- Schleife über das gesamte merkebok
foreach (@bw) {
   
    chomp;

    my $db_sire=1;

    #-- erste Zeile überspringen 
    next if ($_=~/year/);


    #-- Daten zerhacken 
    my @data=split('\|', $_);

    my $cage_year=$data[15];

    $db_sire=$hs_mb_sire{ $cage_year } if (exists $hs_mb_sire{ $cage_year });


    if (($db_sire ne '1')  and ( $db_sire->[0][0] ))  {
        $data[19]=$db_sire->[0][0]; 
	print("---found $data[19]\n");
    }

    print OUT join('|',@data)."\n";

}
close(OUT);

#-- neu klekkebok neu schreiben mit Jahr-1, damit das der Elterngeneration zugeordnet werden kann
open (OUT, ">2/klekkebok.csv") || die "kann 2/klekkebok.csv nicht öffnen";

foreach (@kb) {
 
    chomp; 
    
    #-- erste Zeile überspringen 
    next if ($_=~/year/);

    #-- Daten zerhacken 
    my @data=split('\|', $_);

    #-- Vorjahr 
    my @year=split(':::', $data[7]);

    $year[1]=$year[1]-1;
    $data[7]=$year[0].':::'.$year[1];

    print OUT join('|',@data)."\n";
}
close(OUT);
