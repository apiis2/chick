use TeXTemplates;
use Apiis::Misc;
use strict;
use warnings;

sub CagesBook {
    
    my ($self, $ext_id, $year)=@_;
    my %hs_cage=();my $i=0;

    my $sql="Set datestyle to 'german';";
    my $sql_ref = $apiis->DataBase->sys_sql($sql);
    my @data;
    my @parity;
    my $d;
    my $db_animal;
    my $vtype;
    my $j;

    my $config={'year'=>$year,'ext_id'=>$ext_id};

    $sql="
    select distinct a.db_cage as ext_id, user_get_ext_code(a.db_breed,'s') as ext_breed from animal a inner join unit b on a.db_cage=b.db_unit where date_part('year', birth_dt)='$year' ";
    $sql.=" and b.ext_id='$ext_id' " if ($ext_id);; 
    $sql.=" order by ext_breed, ext_id";

    $sql_ref = $apiis->DataBase->sys_sql($sql);
    goto ERR if (  $sql_ref->status and ($sql_ref->status == 1 ));

    while ( my $q = $sql_ref->handle->fetch ) {

        push(@data, $q->[0]);
    }   

    $sql="
    select a.db_cage,  user_get_ext_code(a.db_breed,'s') as ext_breed, b.ext_id, user_get_ext_id_animal(db_animal) as ext_animal,   user_get_ext_code(db_sex,'s') as ext_sex, exit_dt from animal a inner join unit b on a.db_cage=b.db_unit where date_part('year', birth_dt)='$year' ";
    $sql.=" and b.ext_id='$ext_id' " if ($ext_id);; 
    $sql.=" order by ext_breed, ext_id, ext_sex";

    $sql_ref = $apiis->DataBase->sys_sql($sql);
    goto ERR if (  $sql_ref->status and ($sql_ref->status == 1 ));

    while ( my $q = $sql_ref->handle->fetch ) {

        $hs_cage{$q->[0]}->{'general'}->{'Ident'}=[main::__('Breed'), main::__('Cage-ID')];
        $hs_cage{$q->[0]}->{'general'}->{'Data'}=[$q->[1], $q->[2]];

        $hs_cage{$q->[0]}->{'animals'}->{'Ident'}=[main::__('ID'), main::__('Sex'), main::__('Exit date')];
        push(@{$hs_cage{$q->[0]}->{'animals'}->{'Data'}}, [$q->[3], $q->[4],$q->[5]]);

    
        $hs_cage{$q->[0]}->{'events'}->{'Ident'}=[main::__('Event date'), main::__('Event'), main::__('Traits')];
        $hs_cage{$q->[0]}->{'checks'}->{'Ident'}=['Check'];    
    }    

    my $sql1="select a.db_cage, c.event_dt, user_get_ext_code(c.db_event_type,'s'), collected_eggs || ' / ' || incubated_eggs || ' / ' || hatched_eggs  from hatch_cage a inner join animal b on a.db_cage=b.db_cage inner join event c on a.db_event=c.db_event where date_part('year', birth_dt)='$year'
        union
        select a.db_cage, c.event_dt, user_get_ext_code(c.db_event_type,'s'), number_hens || ' / ' || n_eggs || ' / ' || total_weight_eggs  from eggs_cage a inner join animal b on a.db_cage=b.db_cage inner join event c on a.db_event=c.db_event where date_part('year', birth_dt)='$year'";

    my $sql_ref1 = $apiis->DataBase->sys_sql($sql1);
    goto ERR if (  $sql_ref1->status and ($sql_ref1->status == 1 ));

    while ( my $q1 = $sql_ref1->handle->fetch ) {
    
        push(@{$hs_cage{$q1->[0]}->{'events'}->{'Data'}}, [$q1->[1], $q1->[2], $q1->[3]]);    
    }

    $config->{'data'}=\%hs_cage;

    #-- for testing 
#    pdf($self, \@data, $config);
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

\usepackage[pdftex]{graphicx}
\pagestyle{empty}

\usepackage{fancyhdr}
\pagestyle{fancy}
\renewcommand{\headrulewidth}{0pt}
\cfoot{}

\parindent0mm
%\sloppy{}

\begin{document}
';

    $self->{'_longtablecontent'} .= $latex_header;

    $self->{'_longtablecontent'} .= '\cfoot{\vspace{-3mm}\vspace*{9mm} '.main::__('CagesBook').'$\bullet$'.main::__('date of printing:'). '.$apiis->today .'} \rfoot{}';

    my $graycol = '\parbox{0mm}{\colorbox[gray]{.8}{\parbox{162.9mm}{\rule[-4mm]{0mm}{0mm}}} } ';
    my $graycol2 = '\parbox{0mm}{\colorbox[gray]{.8}{\parbox{162.9mm}{\rule[0mm]{0mm}{5mm}}} }';

    if (exists $config->{'error'}) {
        
         $self->{'_longtablecontent'}.="\\LARGE{$config->{'error'}}";
         return;

    }


    foreach my $key ( @{$data} ) {


        my $cage=$config->{'data'}->{$key};

        my $list;
            
        $list->{'Data'}=[];

        $list->{'Header'}=[@{$cage->{'animals'}->{'Ident'}}];

        $list->{'Data'}=[@{$cage->{'animals'}->{'Data'}}];

        $self->{'_longtablecontent'}.="{\\LARGE ".main::__('Cage')." ".$cage->{'general'}->{'Data'}->[1]."  \\vspace{3mm}} ";
        $self->{'_longtablecontent'}.="{\\LARGE  \\vspace{1mm} } \\\\ ";
        
        #-- information about cage 
        my @stammdaten;
        for (my $i=0; $i<=$#{$cage->{'general'}->{'Ident'}}; $i++) {
            push(@stammdaten,$cage->{'general'}->{'Ident'}->[$i]);
            push(@stammdaten,$cage->{'general'}->{'Data'}->[$i]);
        }

        $self->{'_longtablecontent'} .=TeXTemplates::Katalog_TTA(\@stammdaten);
    
        $self->{'_longtablecontent'}.="\n ";
    
        #-- animallist
        $self->{'_longtablecontent'}.="\n ".main::__('Animals')."\n  ";
        $self->{'_longtablecontent'} .=TeXTemplates::Template_Mehrspaltige_Liste($list);
    
        $self->{'_longtablecontent'}.="\n \\vspace{1mm} \n";
        $self->{'_longtablecontent'}.="\n ".main::__('Events')." \n";
    
        #-- Zitzenbild 
        $self->{'_longtablecontent'} .=TeXTemplates::Template_Mehrspaltige_Liste( {
                'Data'=>$cage->{'events'}->{'Data'},
                'Header'=> $cage->{'events'}->{'Ident'}} );

        $self->{'_longtablecontent'}.="  \\newpage \n";
    }
}

1;


