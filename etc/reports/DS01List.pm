use TeXTemplates;
use Apiis::Misc;
use strict;
use warnings;

sub DS01List {
    
    my ($self)=@_;
    
    my $config={};
    my @data;
    my $data;

    #-- Header für Bericht speichern 
    #-- Die Anzahl der Spalten muss gleich den Spalten im SQL sein, sonst
    #-- erzeugt latex einen fehler 
    #-- 'Header' ist ein Keyword und muss genauso geschrieben werden
    $data->{'Header'}= [['Breed', 'Cage', 'Cock', 'Sire Cock', 'Date','coll. eggs', 'inc. eggs','hatch eggs']];
    
    #-- SQL erzeugen mit allen Inhalten wie in der Liste dargestellt werden soll
    #-- nicht unbedingt zwingend, weil man auch noch Nacharbeiten mit Perl machen könnte 
    my $sql="
        select
            user_get_ext_code(d.db_breed,'s') as breed,
            c.ext_id,
            user_get_full_db_animal( d.db_animal ),
            user_get_full_db_animal( d.db_sire) ,
            b.event_dt, 
            collected_eggs,
            incubated_eggs,
            hatched_eggs
        from hatch_cage a inner join event b on a.db_event=b.db_event
        inner join entry_unit c on a.db_cage=c.db_unit 
        inner join animal d on a.db_cage=d.db_cage
        where d.db_sex=(select db_code from codes where class='SEX' and ext_code='1')
        order by breed , c.ext_id;
        ";

    #-- Führt den SQL aus und macht die Fehlerbehandlung 
    my $sql_ref = $apiis->DataBase->sys_sql($sql);
    goto ERR if (  $sql_ref->status and ($sql_ref->status == 1 ));
 
    #-- Holt die Records und schreibt Sie  
    while ( my $q = $sql_ref->handle->fetch ) {
        
        #-- umspeichern 
        my @record=@$q;

        #--null werte behandeln 
        map {if (!$_) {$_=''} } @record;

        #- speichern in array 
        #-- Data ist ein Keyword und muss genauso geschrieben werden 
        push( @{$data->{'Data'}},[[@record]]);
    }

    #-- Zusammenfassung
    $sql="
        select
            date_part('year',b.event_dt)::text as vgroup, 
            round(avg(collected_eggs)::numeric,1),
            round(avg(incubated_eggs)::numeric,1),
            round(avg(hatched_eggs)::numeric,1)
        from hatch_cage a inner join event b on a.db_event=b.db_event
        inner join unit c on a.db_cage=c.db_unit 
        inner join animal d on a.db_cage=d.db_cage
        group by vgroup
        union
        select
            user_get_ext_code(d.db_breed,'l')::text as vgroup, 
            round(avg(collected_eggs)::numeric,1),
            round(avg(incubated_eggs)::numeric,1),
            round(avg(hatched_eggs)::numeric,1)
        from hatch_cage a inner join event b on a.db_event=b.db_event
        inner join unit c on a.db_cage=c.db_unit 
        inner join animal d on a.db_cage=d.db_cage
        group by vgroup
        order by vgroup
        ;
            ";
            
    $sql_ref = $apiis->DataBase->sys_sql($sql);
    goto ERR if (  $sql_ref->status and ($sql_ref->status == 1 ));


    #-- Schleife über alle Daten 
    #-- 'Summary' ist ein bliebiges Keyword unter dem wir später die Daten ansprechen 
    while ( my $q = $sql_ref->handle->fetch ) {
        
        push( @{$data->{'Summary'}},[[@{$q}]]);
    }

    #-- for testing 
    #pdf($self, $data, $config);
ERR:

    #--  
    return $data, $config;

}

sub pdf {
  my $self =shift;
  my $data = shift;
  my $config = shift;

  # use Data::Dumper;
  # print "++++>".Dumper($data)."<++++\n";
 
  #-- hier nur ändern, wenn das Format der Liste verändert werden soll 
  my $latex_header = '
\documentclass[10pt,a4paper,DIV14,pdftex]{scrartcl}
%\usepackage{german}
\usepackage[utf8]{inputenc}
\usepackage{multicol}
\usepackage{color}
\usepackage{colortbl}
\usepackage{longtable}
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

    #-- die Latexbefehle bzw. Ergebnisse zum Drucken IMMER auf 
    #-- $self->{'_longtablecontent'} legen, diese Variable wird für den pdf-druck abgefragt
    $self->{'_longtablecontent'} .= $latex_header;

    #-- erzeugt latexcode für die Fußzeile 
    $self->{'_longtablecontent'} .= '\cfoot{\vspace{-3mm}\vspace*{9mm} DS01 List '.' $\bullet$ Druckdatum: '.$apiis->today .'} \rfoot{}';

    #-- Druck von Fehlern, sofern welche existieren 
    if (exists $config->{'error'}) {
        
         $self->{'_longtablecontent'}.="\\LARGE{$config->{'error'}}";
         return;
    }

    #-- überschrift 
    $self->{'_longtablecontent'} .='{\\LARGE DS01 List \\\\ } \\\\ ';

    #-- erste Tabelle mit den List-Daten 
    $self->{'_longtablecontent'} .= TeXTemplates::Template_Mehrzeilige_Liste($data);

    #-- Überschrift für die zweite Tabelle 
    $self->{'_longtablecontent'} .= '{\\LARGE Summary} \\';

    #-- Umspeichern von Summary auf Data, weil nur Data abgefragt wird 
    $data->{'Data'}=$data->{'Summary'};

    #-- erzeugen des Headers, weil es den noch nicht gibt. Eckige Spalten müssen so bleiben 
    $data->{'Header'}=[['Year/Breed','coll. eggs', 'inc. eggs','hatch eggs']];

    #-- Druck der Summary 
    $self->{'_longtablecontent'} .= TeXTemplates::Template_Mehrzeilige_Liste($data);

    #-- restlicher Druck erledigt apiis
    #-- die tex-Quellen liegen in $PROJECT/tmp 
}
1;
