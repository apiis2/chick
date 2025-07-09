#######################
# noch offen
# cage ausgrauen, wenn keine Eier
# cage durchstreichen, wenn nicht mehr aktiv
# Linienübersicht mit Anzahl Eiern
# Linienauswertung mit Eiergewichten und Tiergewichten auf Startseite
#######################

use TeXTemplates;
use CheckLines;
use Apiis::Misc;
use strict;
use warnings;

sub CagesBook {
    
    my ($self, $ext_id, $year,$breed)=@_;
    my $i=0;
    my $hscheck={};

#-- für test;
#    $breed='NB8';
#    $year='2019';
#    $ext_id=undef;

    my $sql="Set datestyle to 'german';";
    my $sql_ref = $apiis->DataBase->sys_sql($sql);
    my (@data,  $d) ;

    my $config={'year'=>$year,'ext_id'=>$ext_id,'tab_eggs'=>{}, 'tab_eggs_wt'=>{},'tab_body_wt'=>{}};

    #-- gets all db_cages, cage-ids for breed
    #     db_cage | ext_breed | ext_id
    #    ---------+-----------+--------
    #       68535 | NB8       |    438
    #
    # Es werden die Käfige aller Tiere des betreffenden Jahres und der angegebenen Zucht gesammelt
    $sql=" select distinct a.db_cage as db_cage, user_get_ext_code(a.db_breed,'s') as ext_breed, b.ext_id::numeric 
           from animal a inner join unit b on a.db_cage=b.db_unit 
           where date_part('year', birth_dt)='$year' ";

    $sql.=" and user_get_ext_code(db_breed,'s')='$breed'" if ($breed);
    $sql.=" and b.ext_id='$ext_id' " if ($ext_id);; 
    $sql.=" order by ext_breed, b.ext_id::numeric";

    $sql_ref = $apiis->DataBase->sys_sql($sql);
    goto ERR if (  $sql_ref->status and ($sql_ref->status == 1 ));

    while ( my $q = $sql_ref->handle->fetch ) {

        #-- create an empty hash for each cage 
        push(@data, $q->[0]);
        my $db_cage=$q->[0] ;
        $hscheck->{ $db_cage } = {'cage'=>{'11'=>{},'22'=>{},'21'=>{}},'line'=>{} };
    }   

    my ($hs_cage, $hsline);
    ($hs_cage, $hscheck, $hsline)=
        CheckLines::CheckLines($apiis,$hscheck,{ 'year'=>$year,'breed'=>$breed,'ext_id'=>$ext_id});

    #-- Käfige pro Breed 
    my $sql1="select distinct b.db_cage from animal b inner join unit a on b.db_cage=a.db_unit 
              where date_part('year', birth_dt)='$year' ";
    $sql1.=  "and user_get_ext_code(db_breed,'s')='$breed'" if ($breed);
   
    my $sql_ref1 = $apiis->DataBase->sys_sql($sql1);
    goto ERR if (  $sql_ref1->status and ($sql_ref1->status == 1 ));

    while ( my $q1 = $sql_ref1->handle->fetch ) {
    
        my $vcage= $q1->[0];

        my $vbreed=$hs_cage->{ $vcage }->{'general'}->{'Data'}->[0];
        my $excage=$hs_cage->{ $vcage }->{'general'}->{'Data'}->[1];
        my $vss =$hs_cage->{ $vcage }->{'animals'}->{'Data'}->[0][2];
        my $vds =$hs_cage->{ $vcage }->{'animals'}->{'Data'}->[1][2];
        
        #-- wenn nicht existiert, dann array anlegen
        if (!exists $hsline->{ $vbreed }->{ $vss }->{'no_eggs'}->{  'ss' }) {
            $hsline->{ $vbreed }->{ $vss }->{'no_eggs'}->{  'ss' }=[];
        }
        if (!exists $hsline->{ $vbreed }->{ $vss }->{'no_eggs'}->{  'ds' }) {
            $hsline->{ $vbreed }->{ $vss }->{'no_eggs'}->{  'ds' }=[];
        }
            
#        push( @{$hsline->{ $vbreed }->{ $vss }->{'no_eggs'}->{  'ss' }}, [$excage,'-',$vcage]);  
#        push( @{$hsline->{ $vbreed }->{ $vds }->{'no_eggs'}->{  'ds' }}, [$excage,'-',$vcage]);  
    }

    #-- Gesammelte Eier pro Käfig 
    $sql1="select distinct a.db_cage, c.event_dt, user_get_ext_code(c.db_event_type,'s'), collected_eggs || ' / ' || incubated_eggs || ' / ' || hatched_eggs,hatched_eggs  from hatch_cage a inner join animal b on a.db_cage=b.db_cage inner join event c on a.db_event=c.db_event where date_part('year', birth_dt)='$year' ";

    $sql1.=" and user_get_ext_code(db_breed,'s')='$breed'" if ($breed);
   
    $sql_ref1 = $apiis->DataBase->sys_sql($sql1);
    goto ERR if (  $sql_ref1->status and ($sql_ref1->status == 1 ));

    while ( my $q1 = $sql_ref1->handle->fetch ) {
   
        my $vcage= $q1->[0];

        push(@{$hs_cage->{ $vcage }->{'events'}->{'Data'}}, [$q1->[1], $q1->[2], $q1->[3]]);    
    
        #-- Sire der Hennen für den Cage holen
        my $vbreed=$hs_cage->{ $vcage }->{'general'}->{'Data'}->[0];
        my $excage=$hs_cage->{ $vcage }->{'general'}->{'Data'}->[1];
        my $vss =$hs_cage->{ $vcage }->{'animals'}->{'Data'}->[0][2];
        my $vds =$hs_cage->{ $vcage }->{'animals'}->{'Data'}->[1][2];

#        $hsline->{ $vbreed }->{'eggs'}=1;

        #-- wenn nicht existiert, dann array anlegen
        if (!exists $hsline->{ $vbreed }->{ $vss }->{'no_eggs'}->{  'ss' }) {
            $hsline->{ $vbreed }->{ $vss }->{'no_eggs'}->{  'ss' }=[];
        }
        if (!exists $hsline->{ $vbreed }->{ $vss }->{'no_eggs'}->{  'ds' }) {
            $hsline->{ $vbreed }->{ $vss }->{'no_eggs'}->{  'ds' }=[];
        }
        
        #-- Käfig zur Linie schreiben, wenn Eier gesammelt wurden 
        if ($q1->[4]) {
            
            $hsline->{ $vbreed }->{ $vds }->{'eggs'}->{  $vss.':::'.$vds } = $excage;
            
            #-- array füllen
            push( @{$hsline->{ $vbreed }->{ $vss }->{'no_eggs'}->{  'ss' }}, [$excage,$q1->[4],$vcage]);  
            push( @{$hsline->{ $vbreed }->{ $vds }->{'no_eggs'}->{  'ds' }}, [$excage,$q1->[4],$vcage]);  
        }
        else {
            push( @{$hsline->{ $vbreed }->{ $vss }->{'no_eggs'}->{  'ss' }}, [$excage,'-',$vcage]);  
            push( @{$hsline->{ $vbreed }->{ $vds }->{'no_eggs'}->{  'ds' }}, [$excage,'-',$vcage]);  
        }
    }

    $sql1=" select distinct a.db_cage, c.event_dt, user_get_ext_code(c.db_event_type,'s'), number_hens || ' / ' || n_eggs || ' / ' || total_weight_eggs   from eggs_cage a inner join animal b on a.db_cage=b.db_cage inner join event c on a.db_event=c.db_event where date_part('year', birth_dt)='$year'";
    
    $sql1.=" and user_get_ext_code(db_breed,'s')='$breed'" if ($breed);

    $sql_ref1 = $apiis->DataBase->sys_sql($sql1);
    
    goto ERR if (  $sql_ref1->status and ($sql_ref1->status == 1 ));

    while ( my $q1 = $sql_ref1->handle->fetch ) {
   
        my $vcage= $q1->[0];

        push(@{$hs_cage->{ $vcage }->{'events'}->{'Data'}}, [$q1->[1], $q1->[2], $q1->[3]]);    
    }

    #-- Zusammenstellung Gewichte
    
    $sql="
        select distinct 
            c.db_cage as cage,
            d.event_dt,
            user_get_ext_code(d.db_event_type,'s') as ext_event,  
            user_get_ext_id_animal(c.db_animal) as ext_animal, 
            body_wt 
         from animal a inner join unit b on a.db_cage=b.db_unit 
         inner join pt_indiv c on a.db_cage=c.db_cage 
         inner join event d on c.db_event=d.db_event
         where date_part('year', birth_dt)='$year' ";
    
     $sql.=" and user_get_ext_code(db_breed,'s')='$breed'" if ($breed);
    
     $sql_ref1 = $apiis->DataBase->sys_sql($sql);
    
     goto ERR if (  $sql_ref1->status and ($sql_ref1->status == 1 ));
    
     while ( my $q1 = $sql_ref1->handle->fetch ) {
   
        my $vcage= $q1->[0];

        $hs_cage->{ $vcage }->{ $q1->[2].':::rooster' }->{'Data'}=[$q1->[1], $q1->[2], $q1->[3], $q1->[4]];    
    }

    $sql="
        select distinct
            c.db_cage as cage,
            d.event_dt,
            user_get_ext_code(d.db_event_type,'s') as ext_event,  
            hen_number as hen_number, 
            body_wt 
         from animal a inner join unit b on a.db_cage=b.db_unit 
         inner join pt_cage c on a.db_cage=c.db_cage 
         inner join event d on c.db_event=d.db_event
         where date_part('year', birth_dt)='$year' ";
    
     $sql.=" and user_get_ext_code(db_breed,'s')='$breed'" if ($breed);
    
     $sql_ref1 = $apiis->DataBase->sys_sql($sql);
    
     goto ERR if (  $sql_ref1->status and ($sql_ref1->status == 1 ));
    
     while ( my $q1 = $sql_ref1->handle->fetch ) {
   
        my $vcage= $q1->[0];

        push(@{$hs_cage->{ $vcage }->{$q1->[2].':::hens'}->{'Data'}}, [$q1->[1], $q1->[3], $q1->[4]]);    
    }

    #-- Auswertungen
    $sql="select  user_get_ext_code(a.db_breed,'s') as ext_breed, 
             user_get_ext_code(d.db_event_type,'s') as ext_event,  
             user_get_ext_id_animal(db_sire) as ext_sire, 
             sum(number_hens) as sum_hens, 
             sum(n_eggs) as sum_eggs, 
             round((sum(n_eggs)/sum(number_hens))::numeric,2) as egg_per_hen, 
             round((sum(total_weight_eggs)/sum(n_eggs))::numeric,1) as avg_eggs 
          from animal a 
          inner join unit b on a.db_cage=b.db_unit 
          inner join eggs_cage c on a.db_cage=c.db_cage 
          inner join event d on c.db_event=d.db_event 
          where date_part('year', birth_dt)='$year' ";
    
     $sql.=" and user_get_ext_code(db_breed,'s')='$breed'" if ($breed);
    
     $sql.=" group by ext_breed, db_event_type, db_sire 
             order by ext_breed;";

    $sql_ref1 = $apiis->DataBase->sys_sql($sql);

    goto ERR if (  $sql_ref1->status and ($sql_ref1->status == 1 ));

    while ( my $q1 = $sql_ref1->handle->fetch ) {

        my $vfar=[keys %{$hsline->{ $q1->[0] }->{ $q1->[2] }->{'far'}}]->[0];

        #--  
        next if (!$vfar);

        $config->{'tab_eggs_wt'}->{$q1->[0]}->{ $vfar }->{$q1->[1] }=[$q1->[3],$q1->[4],$q1->[5],$q1->[6],join(', ', values %{$hsline->{ $q1->[0] }->{ $q1->[2] }->{'cage'}})];
    }

    #-- Auswertungen
    $sql="
        select  
            user_get_ext_code(a.db_breed,'s') as ext_breed, 
            user_get_ext_code(d.db_event_type,'s') as ext_event,  
            user_get_ext_id_animal(db_sire) as ext_sire, 
            count(body_wt), 
            round(avg(body_wt)::numeric,1) as avg_wt, 
            round(stddev(body_wt)::numeric,1) as std_wt, 
            round(min(body_wt)::numeric,1) as min_wt, 
            round(max(body_wt)::numeric,1) as max_wt 
         from animal a inner join unit b on a.db_cage=b.db_unit 
         inner join pt_cage c on a.db_cage=c.db_cage 
         inner join event d on c.db_event=d.db_event
         where date_part('year', birth_dt)='$year' ";
    
     $sql.=" and user_get_ext_code(db_breed,'s')='$breed'" if ($breed);
    
     $sql.=" group by ext_breed, db_event_type, db_sire 
             order by ext_breed;";

    $sql_ref1 = $apiis->DataBase->sys_sql($sql);

    goto ERR if (  $sql_ref1->status and ($sql_ref1->status == 1 ));

    while ( my $q1 = $sql_ref1->handle->fetch ) {

        my $vfar=[keys %{$hsline->{ $q1->[0] }->{ $q1->[2] }->{'far'}}]->[0];

        #--  
        next if (!$vfar);

        $config->{'tab_body_wt'}->{$q1->[0]}->{ $vfar }->{$q1->[1] }=[$q1->[3],$q1->[4],$q1->[5],$q1->[6], $q1->[7],join(', ', values %{$hsline->{ $q1->[0] }->{ $q1->[2] }->{'cage'}})];
    }

    #-- Auswertungen
    $sql="
        select  
            user_get_ext_code(a.db_breed,'s') as ext_breed, 
            user_get_ext_code(d.db_event_type,'s') as ext_event,  
            user_get_ext_id_animal(db_sire) as ext_sire, 
            round(avg(collected_eggs)::numeric,0), 
            round(avg(incubated_eggs)::numeric,0), 
            round(avg(hatched_eggs)::numeric,0) 
        from animal a 
        inner join unit b on a.db_cage=b.db_unit 
        inner join hatch_cage c on a.db_cage=c.db_cage 
        inner join event d on c.db_event=d.db_event 
        where date_part('year', birth_dt)='$year' ";
    
     $sql.=" and user_get_ext_code(db_breed,'s')='$breed'" if ($breed);
    
     $sql.=" group by ext_breed, db_event_type, db_sire 
             order by ext_breed;";

    $sql_ref1 = $apiis->DataBase->sys_sql($sql);

    goto ERR if (  $sql_ref1->status and ($sql_ref1->status == 1 ));

    while ( my $q1 = $sql_ref1->handle->fetch ) {

        my $vfar=[ keys %{$hsline->{ $q1->[0] }->{ $q1->[2] }->{'far'}}]->[0];

        #--  
        next if (!$vfar);

        $config->{'tab_eggs'}->{$q1->[0]}->{ $vfar }->{$q1->[1] }=[$q1->[3],$q1->[4],$q1->[5],join(', ', values %{$hsline->{ $q1->[0] }->{ $q1->[2] }->{'cage'}})];
    }

    $config->{'data'}    =$hs_cage;

    ($hs_cage, $config)=CheckLines::EvaluateLines($apiis, $hs_cage, $hsline, $config, $hscheck);

    $config->{'lines'}=$hsline;

    #-- for testing 
    pdf($self, \@data, $config);
ERR:

    return \@data, $config;

}

sub pdf {
  my $self =shift;
  my $data = shift;
  my $config = shift;

  # use Data::Dumper;
  # print "++++>".Dumper($data)."<++++\n";
  
  my $latex_header = '
\documentclass[11pt,a4paper,DIV14,pdftex]{scrartcl}
\usepackage[utf8]{inputenc}
\usepackage{multicol}
\usepackage{color}
\usepackage{colortbl}

\usepackage[dvipsnames]{xcolor}
\usepackage{ltablex}

%mue\usepackage{longtable}

\usepackage[pdftex]{graphicx}
\pagestyle{empty}

\usepackage{fancyhdr}
\pagestyle{fancy}
\renewcommand{\headrulewidth}{0pt}
\cfoot{}

\parindent0mm
%\sloppy{}

\begin{document}
\definecolor{coral}{rgb}{1.0, 0.5, 0.31}';

    $self->{'_longtablecontent'} .= $latex_header;

    $self->{'_longtablecontent'} .= '\cfoot{\vspace{-3mm}\vspace*{9mm} '.main::__('CagesBook').' $\bullet$ '.main::__('date of printing:').' '.$apiis->today .'} \rfoot{}';

    my $graycol = '\parbox{0mm}{\colorbox[gray]{.8}{\parbox{162.9mm}{\rule[-4mm]{0mm}{0mm}}} } ';
    my $graycol2 = '\parbox{0mm}{\colorbox[gray]{.8}{\parbox{162.9mm}{\rule[0mm]{0mm}{5mm}}} }';

    if (exists $config->{'error'}) {
        
         $self->{'_longtablecontent'}.="\\LARGE{$config->{'error'}}";
         return;

    }

    my $vbreed='::';

    foreach my $key ( @{$data} ) {

        my $cage=$config->{'data'}->{$key};

        #-- wenn einen neue Rasse, dann neue Hauptseite 
        if ($vbreed ne $config->{'data'}->{ $key }->{'general'}->{'Data'}->[0]) {

            my @stammdaten;
            $vbreed=$config->{'data'}->{ $key }->{'general'}->{'Data'}->[0];
            
            $self->{'_longtablecontent'}.="{\\LARGE ".main::__('Conclusion for breed')." "
                 .$config->{'data'}->{ $key }->{'general'}->{'Data'}->[0]."  \\vspace{3mm}} ";

            $self->{'_longtablecontent'}.="{\\LARGE  \\vspace{1mm} } \\\\ ";
           
            #-- Linien; 
            push(@stammdaten,main::__('No.Lines'));
            push(@stammdaten, scalar keys %{$config->{'lines'}->{$vbreed}});

            #-- Linien; 
            push(@stammdaten,main::__('DS Lines'));

            my @tt;
            foreach my $vkey (sort keys %{$config->{'lines'}->{$vbreed}}) {
                
                my $color='green';
               
                #-- für Linie wurden keine Eier gesammelt 
                if (!exists $config->{'lines'}->{$vbreed}->{$vkey}->{'eggs'}) {
                    $color='coral';

                    my $warning=main::__('No eggs were collected.');

                    #-- Fehler allgemein wegschreiben 
                    push(@{$config->{'warnings'}->{ $vbreed }}, $warning.': '.$vkey);
                }

                #-- für Linie wurden aus zwei Käfigen Eier gesammelt 
                if ((exists $config->{'lines'}->{$vbreed}->{$vkey}->{'eggs'}) and 
                    (scalar keys %{$config->{'lines'}->{$vbreed}->{$vkey}->{'eggs'}} > 1)) {
                    $color='red';

                    my @ttt;
                    map {
                        push( @ttt, $_);
                    } values %{$config->{'lines'}->{$vbreed}->{$vkey}->{'eggs'}};
                    $vkey.="(".join(', ',@ttt).")";
                }

                push(@tt,'\\textcolor{'.$color.'}{'.$vkey.'}');
            }

            push(@stammdaten,join(', ',@tt));

            #-- Cages; 
            push(@stammdaten,main::__('No.Cages'));
            
            my $cnt=0;;
            map {
               $cnt+=scalar keys %{$config->{'lines'}->{$vbreed}->{$_}->{'cage'}};
            } keys %{$config->{'lines'}->{$vbreed}};
            
            push(@stammdaten,$cnt);

            push(@stammdaten,main::__('Cages'));

            #-- Käfige sammeln mit Farnummer 
            my %vhscage;
            foreach my $vkey (sort keys %{$config->{'lines'}->{$vbreed}}) {
                
                map {
                    $vhscage{$_}->{'far'} ='('.join(', ', keys %{$config->{'lines'}->{$vbreed}->{$vkey}->{'far'}}).')';
                    $vhscage{$_}->{'eggs'}=scalar keys %{$config->{'lines'}->{$vbreed}->{$vkey}->{'eggs'}};
                } values %{$config->{'lines'}->{$vbreed}->{$vkey}->{'cage'}};
            }


            @tt=();
            foreach my $vkey (sort {$a<=>$b} keys %vhscage) {
                
                my $color='green';
           
                if (($vhscage{$vkey}->{'eggs'} > 1)) {
                    $color='red';
                }

                push(@tt, '\\textcolor{'.$color.'}{'. $vkey.$vhscage{$vkey}->{'far'}.'}');
            }

            push(@stammdaten,join(', ',@tt));

            if ($#{$config->{'errors'}->{ $vbreed }} != -1) {
                #-- Fehler eindampfen
                push(@stammdaten,main::__('Errors'));
                
                my %tt;           
                foreach my $verr ( @{$config->{'errors'}->{ $vbreed }} ) {
                    $tt{$verr}=1;
                }
                push(@stammdaten,'\\textcolor{red}{'.join(', ',keys %tt).'}');
            }

            if ($#{$config->{'warnings'}->{ $vbreed }} != -1) {
                push(@stammdaten,main::__('Warnings'));
                
                my %tt;           
                foreach my $verr ( @{$config->{'warnings'}->{ $vbreed }} ) {
                    $tt{$verr}=1;
                }
                push(@stammdaten,'\\textcolor{coral}{'.join(', \newline ',keys %tt).'}');
            }

            $self->{'_longtablecontent'} .=TeXTemplates::Katalog_TTA(\@stammdaten);
            
            $self->{'_longtablecontent'}.="  \\newpage \n";
            
            #-- Tab Eggs
            my $list;
                
            $list->{'Header'}=[main::__('Far (Cages)'),main::__('NHens'),main::__('NEggs'),main::__('eggPerHen'), main::__('avgEggs'), main::__('NHens'),main::__('NEggs'),main::__('eggPerHen'),main::__('avgEggs')];
                
            $list->{'Data'}=[];

            foreach my $far (sort {$a<=>$b} keys %{$config->{'tab_eggs_wt'}->{ $vbreed }}) {

                my @vdata;
                my $vcage;
                push(@vdata, $far);
                
                foreach my $event (sort keys %{$config->{'tab_eggs_wt'}->{ $vbreed }->{$far} }) {

                    my @data=@{$config->{'tab_eggs_wt'}->{$vbreed}->{ $far }->{$event}};

                    push(@vdata,  ($data[0], $data[1], $data[2], $data[3]));
                    
                    $vcage=$data[4];
                }
                
                #-- Käfignummern anfügen 
                $vdata[0].='  ('. $vcage.')';

                push(@{$list->{'Data'}},[@vdata]);
            }
            $self->{'_longtablecontent'} .= main::__('Table 1: statistics to eggs (33th week and 53th week)')." \\\\";

            $self->{'_longtablecontent'} .=TeXTemplates::Template_Mehrspaltige_Liste($list);
        
            $self->{'_longtablecontent'}.="  \\newpage \n";
        
            
            #-- Table Weights 
            $list->{'Header'}=[main::__('Far (Cages)'),main::__('N'),main::__('AVG'),main::__('STD'),main::__('MIN'),main::__('MAX'),main::__('N'),main::__('AVG'),main::__('STD'), main::__('MIN'), main::__('MAX')];
                
            $list->{'Data'}=[];

            foreach my $far (sort {$a<=>$b} keys %{$config->{'tab_body_wt'}->{ $vbreed }}) {

                my @vdata;
                my $vcage;
                push(@vdata, $far);
                
                foreach my $event (sort keys %{$config->{'tab_body_wt'}->{ $vbreed }->{$far} }) {

                    my @data=@{$config->{'tab_body_wt'}->{$vbreed}->{ $far }->{$event}};

                    push(@vdata,  ($data[0], $data[1], $data[2], $data[3], $data[4]));
                    $vcage=$data[5];
                }
           
                #-- Käfignummern anfügen 
                $vdata[0].='  ('. $vcage.')';

                push(@{$list->{'Data'}},[@vdata]);
            }
            $self->{'_longtablecontent'} .= main::__('Table 2: statistics to weights (20th week and 40th week)')." \\\\";

            $self->{'_longtablecontent'} .=TeXTemplates::Template_Mehrspaltige_Liste($list);
        
            $self->{'_longtablecontent'}.="  \\newpage \n";
        
            #-- Table Weight
            $list->{'Header'}=[main::__('Far'), main::__('Grandsire'),main::__('for Cook/Hens'),main::__('cage (sire line x dam line): hatched eggs')];
                
            $list->{'Data'}=[];

            my %hsfar;my $kk='1000';

            map {

                #-- wenn es Vater nicht als Hennen-Linie gibt
                if (!$config->{'lines'}->{$vbreed}->{$_}->{'sc_far'}) {
                    $hsfar{$kk++}=$_;
                }
                else {
                    $hsfar{$config->{'lines'}->{$vbreed}->{$_}->{'sc_far'}}=$_;
                }
            } keys %{$config->{'lines'}->{$vbreed}};

            foreach my $far (sort {$a<=>$b} keys %hsfar) {

                my @vdata;

                if ($far==1000) {
                    push(@vdata, "\\textcolor{red}{".main::__('ERR')."}");
                }
                else {
                    push(@vdata, "\\textcolor{blue}{$far}");
                }
                push(@vdata, $hsfar{$far});
                push(@vdata, main::__('rooster'));

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

                if ($#{$config->{'lines'}->{$vbreed}->{$hsfar{$far}}->{'no_eggs'}->{'ss'}}>0) {
                    my @vvdata;
                    my %verr; 

                    #-- Sammeln der far-Kombinationen (müssen eigentlich 1 sein, Rest ist Fehler) 
                    map {
                   
                        #-- überspringen, weil es Käfige mit Eiern gibt, da können die ohne unberücksichtigt bleiben 
                        if ( $_->[1] ne '-') {
                            $verr{GetFar($config,'ds', $_->[2],$vbreed)}=1;
                        }

                    } @{$config->{'lines'}->{$vbreed}->{$hsfar{$far}}->{'no_eggs'}->{'ss'}};
                   
                    my $t=keys %verr;

                    map {
                
                        #-- überspringen, weil es Käfige mit Eiern gibt, da können die ohne unberücksichtigt bleiben 
                        if ( $_->[1] ne '-') {

                            my $fard=GetFar($config,'ds', $_->[2],$vbreed);

                            if ($t>1) {
                                push(@vvdata," \\textcolor{red}{$_->[0] ($far x $fard): $_->[1]}") 
                            }
                            else {
                                push(@vvdata," $_->[0] (\\textcolor{blue}{$far} x $fard): $_->[1]") 
                            }
                        }  
              
                    } @{$config->{'lines'}->{$vbreed}->{$hsfar{$far}}->{'no_eggs'}->{'ss'}};

                    push(@vdata,join(', ',@vvdata));
                }
                else {
                    map {
                            
                        my $fard=GetFar($config,'ds', $_->[2],$vbreed);
                            
                        if ($_->[1] eq '-') {
                            if (exists $config->{'lines'}->{ $vbreed }->{'eggs'}) {
                                push(@vdata,'\\textcolor{coral}{'."$_->[0] (\\textcolor{blue}{$far} x $fard): $_->[1]".'}') 
                            }
                            else {
                                push(@vdata,"$_->[0] (\\textcolor{blue}{$far} x $fard): $_->[1]") 
                            }
                        }
                        else {
                        
                            push(@vdata," $_->[0] (\\textcolor{blue}{$far} x $fard): $_->[1]") 
                        }
                    } @{$config->{'lines'}->{$vbreed}->{$hsfar{$far}}->{'no_eggs'}->{'ss'}};
                }
                
                push(@{$list->{'Data'}},[@vdata]);

                @vdata=();
                push(@vdata, '');
                push(@vdata, '');
                push(@vdata, main::__('hens'));
               
                if ($#{$config->{'lines'}->{$vbreed}->{$hsfar{$far}}->{'no_eggs'}->{'ds'}}>0) {
                    my @vvdata;
                    my %verr; 
                    
                    #-- Sammeln der far-Kombinationen (müssen eigentlich 1 sein, Rest ist Fehler) 
                    map {
                    
                        $verr{GetFar($config,'ss', $_->[2],$vbreed)}=1;

                    } @{$config->{'lines'}->{$vbreed}->{$hsfar{$far}}->{'no_eggs'}->{'ds'}};
                   
                    my $t=keys %verr;

                    map {
                        
                        my $fard=GetFar($config,'ss', $_->[2],$vbreed);
                        
                        if ($t>1) {
                            push(@vvdata," \\textcolor{red}{$_->[0] ($fard x $far): $_->[1]}") 
                        }
                        else {
                            push(@vvdata," $_->[0] ($fard x \\textcolor{blue}{$far}): $_->[1]");
                        }

                    } @{$config->{'lines'}->{$vbreed}->{$hsfar{$far}}->{'no_eggs'}->{'ds'}};

                    push(@vdata,join(', ',@vvdata));
                }
                else {
                    map {
                            
                        my $fard=GetFar($config,'ss', $_->[2],$vbreed);
                        
                        if ($_->[1] eq '-') {
                            if (exists $config->{'lines'}->{ $vbreed }->{'eggs'}) {
                                push(@vdata,'\\textcolor{coral}{'."$_->[0] ($fard x \\textcolor{blue}{$far}): $_->[1]".'}') 
                            }
                            else {
                                push(@vdata,"$_->[0] ($fard x \\textcolor{blue}{$far}): $_->[1]"); 
                            }

                        }
                        else {
                        
                            push(@vdata," $_->[0] ($fard x \\textcolor{blue}{$far}): $_->[1]"); 
                        }

                    } @{$config->{'lines'}->{$vbreed}->{$hsfar{$far}}->{'no_eggs'}->{'ds'}};
                }

                push(@{$list->{'Data'}},[@vdata]);
            }
              
            $self->{'_longtablecontent'} .= main::__('Table 3: statistics to collected eggs')." \\\\";

            $self->{'_longtablecontent'} .=TeXTemplates::Template_Mehrspaltige_Liste($list);
            
#            $self->{'_longtablecontent'} .= main::__('1000 - there are no far number for such animals');

        
            $self->{'_longtablecontent'}.="  \\newpage \n";
        }

        #-- Tab Eggs
        my $list;
            
        $list->{'Data'}=[];

        $list->{'Header'}=[@{$cage->{'animals'}->{'Ident'}}];

        $list->{'Data'}=[@{$cage->{'animals'}->{'Data'}}];

        $self->{'_longtablecontent'}.="{\\LARGE ".main::__('Cage')." ".$cage->{'general'}->{'Data'}->[1]."  \\vspace{3mm}} ";
        $self->{'_longtablecontent'}.="{\\LARGE  \\vspace{1mm} } \\\\ ";
        
        #-- information about cage 
        my @stammdaten;
        foreach my $i (0,2) {
            push(@stammdaten,$cage->{'general'}->{'Ident'}->[$i]);
            push(@stammdaten,$cage->{'general'}->{'Data'}->[$i]);
        }

        my $vbreed=$cage->{general}->{Data}[0];
        my @ssire=keys %{$cage->{ss}};
        my @dsire=keys %{$cage->{ds}};

        push(@stammdaten,main::__('Far rooster'));
        push(@stammdaten, [keys %{$config->{lines}->{ $cage->{general}->{Data}[0]}->{ $ssire[0] }->{far}}]->[0]);
        
        push(@stammdaten,main::__('Far hens'));
        push(@stammdaten,[keys %{$config->{lines}->{ $cage->{general}->{Data}[0]}->{ $dsire[0] }->{far}}]->[0]);
        
        #-- information about cage 
        foreach (@{$cage->{'checks'}->{'Errors'}}) {
            push(@stammdaten,main::__('Errors'));
            push(@stammdaten,'\\textcolor{red}{'.$_.'}');
        }
        
        $self->{'_longtablecontent'} .=TeXTemplates::Katalog_TTA(\@stammdaten);
    
        $self->{'_longtablecontent'}.="\n ";
    
        #-- animallist
        $self->{'_longtablecontent'}.="\n ".main::__('Animals')."\n  ";
        $self->{'_longtablecontent'} .=TeXTemplates::Template_Mehrspaltige_Liste($list);
    
        #-- Zitzenbild 
        $self->{'_longtablecontent'}.="\n \\vspace{1mm} \n";
        $self->{'_longtablecontent'}.="\n ".main::__('Events')." \n";
        $self->{'_longtablecontent'} .=TeXTemplates::Template_Mehrspaltige_Liste( {
                'Data'=>$cage->{'events'}->{'Data'},
                'Header'=> $cage->{'events'}->{'Ident'}} );

        #-- Gewichte 
        $self->{'_longtablecontent'}.="\n \\vspace{1mm} \n";
        $self->{'_longtablecontent'}.="\n ".main::__('Weights')." \n";
        
        my $ar_weights=[];
        
        if (exists $cage->{'weighingbody20weeks:::rooster'}) {
            push(@$ar_weights,[$cage->{'weighingbody20weeks:::rooster'}->{'Data'}->[0],
                            main::__('weighingbody20weeks'),
                            $cage->{'weighingbody20weeks:::rooster'}->{'Data'}->[2],
                            $cage->{'weighingbody20weeks:::rooster'}->{'Data'}->[3]]);
        }

        if (exists $cage->{'weighingbody40weeks:::rooster'}) {
            push(@$ar_weights,[$cage->{'weighingbody40weeks:::rooster'}->{'Data'}->[0],
                            main::__('weighingbody40weeks'),
                            $cage->{'weighingbody40weeks:::rooster'}->{'Data'}->[2],
                            $cage->{'weighingbody40weeks:::rooster'}->{'Data'}->[3]]);
        }

        if (exists $cage->{'weighingbody20weeks:::hens'}) {

            my @vweight=();
            map { push(@vweight,$_->[2]) } @{$cage->{'weighingbody20weeks:::hens'}->{'Data'}};

            push(@$ar_weights,[$cage->{'weighingbody20weeks:::hens'}->{'Data'}->[0][0],
                            main::__('weighingbody20weeks'),
                            main::__('Hens'),
                            join(', ', @vweight)]);
        }

        if (exists $cage->{'weighingbody40weeks:::hens'}) {
            my @vweight=();
            map { push(@vweight,$_->[2]) } @{$cage->{'weighingbody40weeks:::hens'}->{'Data'}};

            push(@$ar_weights,[$cage->{'weighingbody40weeks:::hens'}->{'Data'}->[0][0],
                            main::__('weighingbody40weeks'),
                            main::__('Hens'),
                            join(', ', @vweight)]);
        }

        $self->{'_longtablecontent'} .=TeXTemplates::Template_Mehrspaltige_Liste( {
                'Data'=>$ar_weights,
                'Header'=> [main::__('Event'), main::__('Eventtype'), main::__('Cook/Hens'), main::__('Weight')] 
                } );




        $self->{'_longtablecontent'}.="  \\newpage \n";
    }
}

1;
__END__
Auswertung Eier nach beiden Events
select  user_get_ext_code(a.db_breed,'s') as ext_breed, user_get_ext_code(d.db_event_type,'s') as ext_event,  db_sire, sum(number_hens) as sum_hens, sum(n_eggs) as sum_eggs, round((sum(n_eggs)/sum(number_hens))::numeric,2) as egg_per_hen, sum(total_weight_eggs)/sum(n_eggs) as avg_eggs from animal a inner join unit b on a.db_cage=b.db_unit inner join eggs_cage c on a.db_cage=c.db_cage inner join event d on c.db_event=d.db_event where date_part('year', birth_dt)='2013' and user_get_ext_code(db_breed,'s')='JH' group by ext_breed, db_event_type, db_sire order by ext_breed;

Auswertung Gewichte

Auswertung collected

