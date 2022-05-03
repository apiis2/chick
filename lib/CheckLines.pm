package CheckLines;

use Apiis::Misc;
use warnings;
use strict;

#####################################################################                
sub GetFar {
#####################################################################
    my $config= shift;
    my $vs    = shift;
    my $cage  = shift;
    my $vbreed= shift;

    my $a=keys %{$config->{'data'}->{$cage}->{$vs}};

    #-- if more then one rooster with diffenent parents in a cage 
    if ($a > 1) {
        return '\\textcolor{red}{'.main::__('ERR').'}';
    }
    else {
        my @a=keys %{$config->{'data'}->{$cage}->{$vs}};

        my $erg=$config->{'lines'}->{$vbreed}->{$a[0]}->{'sc_far'};
        if ($erg) {
            return $config->{'lines'}->{$vbreed}->{$a[0]}->{'sc_far'}
        }
        else {
            return '\\textcolor{red}{'.main::__('ERR').'}';
        }
    }
}
#####################################################################


sub CheckLines {

    my $apiis=shift;
    my $hscheck=shift;

    my $args=shift;
    my $year=$args->{'year'};
    my $breed=$args->{'breed'};
    my $ext_id=$args->{'ext_id'};
    
    my ($hs_cage, %hsline, %hscntfar);

    my $sql;
    my $sql_ref;

    #-- aktuelle Abstammungen holen
    $sql="select 
            user_get_ext_id_animal(a.db_animal) as ext_animal, 
            user_get_ext_id_animal(a.db_sire), 
            user_get_ext_id_animal(a.db_dam) 
          from animal a inner join transfer b on a.db_animal=b.db_animal 
          where date_part('year',birth_dt)='$year'";
            
    #-- SQL auslösen 
    $sql_ref = $apiis->DataBase->sys_sql( $sql );
              
    my %hs_pedigree;
    while ( my $q = $sql_ref->handle->fetch ) { 
         $hs_pedigree{$q->[0]}={'s'=>$q->[1], 'd'=>$q->[2]}; 
    }  


    $sql=" select 
           a.db_cage,  
           user_get_ext_code(a.db_breed,'s') as ext_breed, 
           b.ext_id, 
           user_get_ext_id_animal(db_animal) as ext_animal,   
           user_get_ext_code(db_sex,'s') as ext_sex, 
           user_get_ext_id_animal(db_sire) as ext_sire, 
           user_get_ext_id_animal(db_dam) as ext_dam, 
           exit_dt as exit_dt_animal, 
           closing_dt as exit_dt_cage,
           birth_dt,
           db_animal

           from animal a inner join unit b on a.db_cage=b.db_unit  
           where date_part('year', birth_dt)='$year' ";

    $sql.=" and user_get_ext_code(db_breed,'s')='$breed'" if ($breed);
    $sql.=" and b.ext_id='$ext_id' " if ($ext_id);; 
    $sql.=" order by ext_breed, ext_id, ext_sex, ext_animal";

    $sql_ref = $apiis->DataBase->sys_sql($sql);
    goto ERR if (  $sql_ref->status and ($sql_ref->status == 1 ));

    while ( my $q = $sql_ref->handle->fetch ) {

        my $vbreed= $q->[1];
        my $vsire = $q->[5];
        my $vdam  = $q->[6];
        my $vcage = $q->[0];
        my $ecage = $q->[2];
        my $ext_animal = $q->[3];
        my $ext_sex    = $q->[4];
        my $db_animal = $q->[10];

#if ($vsire eq 'Hvam2013-1950') {
#    print "kk";
#}


        $hs_cage->{ $vcage }={'cnt'=>0, 'm'=>[],'w'=>[],'m_int'=>[],'w_int'=>[],'b'=>{},'ss'=>{},'sd'=>{},'ds'=>{},'dd'=>{},
                              'general'=>{},'animals'=>{}, 'events'=>{}, 'checks'=>{}} if (!exists $hs_cage->{ $vcage}) ;

        $hs_cage->{ $vcage }->{'general'}->{'Ident'}=['Breed', 'Cage-ID', 'Exit Date'];
        $hs_cage->{ $vcage }->{'general'}->{'Data'}=[ $vbreed , $q->[2], $q->[8]];

        $hs_cage->{ $vcage }->{'animals'}->{'Ident'}=['ID', 'Sex', 'Sire', 'Dam', 'Birthdate', 'Exit date'];
        push(@{$hs_cage->{ $vcage }->{'animals'}->{'Data'}}, [$q->[3], $q->[4], $vsire ,$q->[6],$q->[9],$q->[7]]);

        if ( $ext_sex eq '1') { 

             push( @{ $hs_cage->{ $vcage}->{'m'} }, $ext_animal );  
             push( @{ $hs_cage->{ $vcage}->{'m_int'} }, $db_animal );  
             $hs_cage->{ $vcage}->{'ss'}->{ $hs_pedigree{$ext_animal}->{'s'}}=1; 
             $hs_cage->{ $vcage}->{'sd'}->{ $hs_pedigree{$ext_animal}->{'d'}}=1; 
        }
        else {
             push( @{ $hs_cage->{ $vcage}->{'w'} }, $ext_animal );
             push( @{ $hs_cage->{ $vcage}->{'w_int'} }, $db_animal );  
             $hs_cage->{ $vcage}->{'ds'}->{ $hs_pedigree{$ext_animal}->{'s'}}=1; 
             $hs_cage->{ $vcage}->{'dd'}->{ $hs_pedigree{$ext_animal}->{'d'}}=1; 
        }

        $hs_cage->{ $vcage}->{'b'}->{$vbreed}=1;
    
        $hs_cage->{ $vcage }->{'events'}->{'Ident'}=['Event date', 'Event', 'Traits'];
        $hs_cage->{ $vcage }->{'checks'}->{'Ident'}=['Check'];    
        $hs_cage->{ $vcage }->{'checks'}->{'Errors'}=[];    
        $hs_cage->{ $vcage }->{'checks'}->{'Warnings'}=[];    

        #-- wenn männlich 
        if ($q->[4] eq '1') {
            $hscheck->{  $vcage  }->{'cage'}->{'11'}->{  $vsire  }=1;
        }

        #-- wenn Henne 
        else {

            #-- Väter und Mütter zählen 
            $hscheck->{  $vcage  }->{'cage'}->{'21'}->{  $vsire  }=1;
            $hscheck->{  $vcage  }->{'cage'}->{'22'}->{ $q->[6] }=1;
       
            #-- Linien-Zähler initialisieren, wenn es ihn für die Rasse noch nicht gibt 
            $hscntfar{ $vbreed }=1 if (!exists $hscntfar{ $vbreed });

            #-- Farnummer für den Käfig sichern 
            $hscheck->{  $vcage  }->{'far'} = $hscntfar{ $vbreed };
            
            #-- Initialisieren 
            $hscntfar{ $vbreed }          = 0  if (!exists $hsline{ $vbreed });
            $hsline{ $vbreed }            = {} if (!exists $hsline{ $vbreed });

            $hscntfar{ $vbreed }++             if (!exists $hsline{ $vbreed }->{ $vsire });
            $hsline{ $vbreed }->{ $vsire }= {} if (!exists $hsline{ $vbreed }->{ $vsire });

            $hsline{ $vbreed }->{ $vsire }->{'cage'}->{ $vcage } = $ecage;
            $hsline{ $vbreed }->{ $vsire }->{'far'}->{ $hscntfar{ $vbreed }} = 1;
            $hsline{ $vbreed }->{ $vsire }->{'sc_far'}= $hscntfar{ $vbreed };
        }
    }   
    return $hs_cage,$hscheck, \%hsline;
}
    
sub EvaluateLines {

    my $apiis       =shift;
    my $hs_cage     =shift;
    my $hsline      =shift;
    my $config      =shift;
    my $hscheck     =shift;


    #-- Auswertung mit Schleife über alle Käfige
    foreach my $vcage (keys %$hscheck) {

        my $warning;
        
        #-- Vaterlinie ohne gesammelte Eier
        my $vbreed= $hs_cage->{ $vcage }->{'general'}->{'Data'}->[0]  ;
        my $vsire= $hs_cage->{ $vcage }->{'animals'}->{'Data'}->[1][2];
        $vsire='1' if (!defined $vsire);

        #-- wenn es Vater nicht als Hennen-Linie gibt
        if (!$hsline->{$vbreed}->{$vsire}->{'sc_far'}) {
            $warning=main::__('There are no hens-sireline for rooster');
                
            #-- Fehler allgemein wegschreiben 
            push(@{$config->{'errors'}->{ $vbreed }}, $warning.': '.$hs_cage->{$vcage}->{'general'}->{'Data'}[1]);

            #-- Fehler pro Cage wegschreiben 
            push(@{$hs_cage->{ $vcage }->{'checks'}->{'Errors'}},$warning);
        }   

        #--  
        if ($#{$hsline->{$vbreed}->{$vsire}->{'no_eggs'}->{'ss'}}>0) {
            
            $warning=main::__('Line mismatch - Check line in Table 3');
                
            #-- Fehler allgemein wegschreiben 
            push(@{$config->{'errors'}->{ $vbreed }}, $warning.': '.$hs_cage->{$vcage}->{'general'}->{'Data'}[1]);

            #-- Fehler pro Cage wegschreiben 
            push(@{$hs_cage->{ $vcage }->{'checks'}->{'Errors'}},$warning);
        }

        #-- kein Hahn im Käfig 
        if ($#{$hs_cage->{ $vcage }->{'m'}}<0) {
            $warning=main::__('No coke in cage');

                #-- Fehler allgemein wegschreiben 
            push(@{$config->{'errors'}->{ $vbreed }}, $warning.': '.$hs_cage->{$vcage}->{'general'}->{'Data'}[1]);

            #-- Fehler pro Cage wegschreiben 
            push(@{$hs_cage->{ $vcage }->{'checks'}->{'Errors'}},$warning);
        }
        #-- kein Hahn im Käfig 
        if ($#{$hs_cage->{ $vcage }->{'w'}}<0) {
            $warning=main::__('No hen in cage');

            #-- Fehler allgemein wegschreiben 
            push(@{$config->{'errors'}->{ $vbreed }}, $warning.': '.$hs_cage->{$vcage}->{'general'}->{'Data'}[1]);

            #-- Fehler pro Cage wegschreiben 
            push(@{$hs_cage->{ $vcage }->{'checks'}->{'Errors'}},$warning);
        }

        #-- to less animals in cage 
        if (($#{$hs_cage->{ $vcage}->{'m'}}+1+$#{$hs_cage->{ $vcage}->{'w'}}+1)<2) {
            $warning=main::__('To less animals in cage. ');
        
            push(@{$config->{'errors'}->{ $vbreed }}, $warning.': '.$hs_cage->{$vcage}->{'general'}->{'Data'}[1]);

            #-- Fehler pro Cage wegschreiben 
            push(@{$hs_cage->{ $vcage }->{'checks'}->{'Errors'}},$warning);
        }

        #-- check for different pedigree by roosters
        if (($#{$hs_cage->{ $vcage}->{'m'}}+1>1) and
            ((scalar keys %{$hs_cage->{ $vcage }->{'ss'}}>1) or (scalar keys %{$hs_cage->{ $vcage }->{'sd'}}>1))) {

            $warning=main::__('Different pedigree between roosters. ');
            
            push(@{$config->{'errors'}->{ $vbreed }}, $warning.': '.$hs_cage->{$vcage}->{'general'}->{'Data'}[1]);

            #-- Fehler pro Cage wegschreiben 
            push(@{$hs_cage->{ $vcage }->{'checks'}->{'Errors'}},$warning);
                                        
        }

        #-- check for different pedigree by roosters
        if (($#{$hs_cage->{ $vcage}->{'w'}}+1>1) and
            ((scalar keys %{$hs_cage->{ $vcage }->{'ds'}}>1) or (scalar keys %{$hs_cage->{ $vcage }->{'dd'}}>1))) {

            $warning=main::__('Different pedigree between hens.  ');
            
            push(@{$config->{'errors'}->{ $vbreed }}, $warning.': '.$hs_cage->{$vcage}->{'general'}->{'Data'}[1]);

            #-- Fehler pro Cage wegschreiben 
            push(@{$hs_cage->{ $vcage }->{'checks'}->{'Errors'}},$warning);
                                        
        }

        if (scalar keys  %{$hs_cage->{ $vcage }->{'b'}}>1) {
            
            $warning=main::__('Animals has more then one breed or the same cage number in several breeds.  ');
            
            push(@{$config->{'errors'}->{ $vbreed }}, $warning.': '.$hs_cage->{$vcage}->{'general'}->{'Data'}[1]);

            #-- Fehler pro Cage wegschreiben 
            push(@{$hs_cage->{ $vcage }->{'checks'}->{'Errors'}},$warning);
         }


        if ( scalar keys %{$hsline->{ $vbreed}->{ $vsire}->{'eggs'}}  > 1) {
            $warning=main::__('Equal farnumber but different Pedigree between cages');

            #-- Fehler allgemein wegschreiben 
            push(@{$config->{'errors'}->{ $vbreed }}, $warning.': '.join(', ',values %{ $hsline->{ $vbreed}->{ $vsire}->{'eggs'} }) );

            #-- Fehler pro Cage wegschreiben 
            push(@{$hs_cage->{ $vcage }->{'checks'}->{'Errors'}},$warning.': '.join(', ',values %{ $hsline->{ $vbreed}->{ $vsire}->{'eggs'} }) );
        }


    }

    return ($hs_cage, $config);
}
1;
