#-- EDIT --
#-- Name of modul and name of function has to be identically

my @datastreams=('LO_DS020304', 'LO_DS05','LO_DS10','LO_DS06','LO_DS07', 'LO_DS08');

#-- END


use CGI qw/:standard :html3 :html4 /;

use strict;
use warnings;

#-- load datastream moduls
foreach (@datastreams) {
    my $vstr="use $_"; 
    eval($vstr);
}

#-- upload a general ascii-file
sub FileUpload {
    my ( $self, $filename, $importfilter,$onlycheck, $breed,$ft_m ) = @_;
    my @bak;
    my $json;
    my @data;    
    my $pack;
    my $table;
    my @rdata;
    my @title;
    my $row='<td>'.main::__('No').'</td><td></td>';
    my $pruefort;
    my $db_event;
    my @field;
    my $zeile;
    my $error;
    my $insert_ok=0;
    my $insert_false=0;
    my $lo='';
     
    $onlycheck='off' if (!$onlycheck);
    
    #-- leeren json-String generieren
    my $args={'JSON'=>{},
              'FILE'=>$filename,
              'importfilter'=>$importfilter};

    $args->{'onlycheck'}=$onlycheck;

    #-- Tabelle drucken, wenn nur check 
    if ((!$onlycheck) or (lc($onlycheck) eq 'on')) {
        print '<style type="text/css">
            .tip { border-bottom:1px dotted #000000; }
            a.tip,
            a.tip:link,
            a.tip:visited,
            a.tip:active { color: #616161; text-decoration: none; position: relative; }
            a.tip:hover { background: transparent; z-index: 100; }
            a.tip span { display: none; text-decoration: none; }
            a.tip:hover span {
            display: block;
            position: absolute;
            top: 40px;
            left: 0;
            width: 400px;
            z-index: 100;
            color: #2f2f2f;
            font-family: Helvetica, Geneva, Arial, SunSans-Regular, sans-serif;
            padding: 2px 10px;
            background-color: #ebebeb;
             text-align: left;
             border-color: #780303;
             border-style: solid;
             border-width: 1px 4px; }
             </style>';
        print h2(main::__('Import:').' '.$importfilter);
        print '<table border="1">';
    }
   
    my $tt="$importfilter".'($apiis,$args)';
    $json=eval($tt);
    #-- Ausgabe der fehlerhaften Daten
    my $filenameout=$filename.'.false';
    $filenameout=~s/.*\/(.*)/$1/g;


    if ( exists $json->{'Tables'}) {
        for (my $i=0; $i<=$#{ $json->{'Tables'}};$i++) {
            $row.='<td>'.$json->{'Tables'}->[$i].'</td>';
        }
    }

    #-- Kopf drucken 
    map {    $row.="<td>".$_."</td>" } @{$json->{'Fields'}};

    if (lc($onlycheck) eq 'on') {
        print $row ;
    }

    #-- Auswertung des json-Strings
    my $counter=-1;
    foreach my $hs_record ( @{ $json->{ 'RecordSet' } } ) {
    
        $counter++;
        my $err;
        my $warn;
        my $row='';
        my %hs_error;
        my $firstrow='<td>'.$counter.'</td>';
        my $up_ins;

        #-- Fehler des gesamten Records ermitteln   
        foreach my $error (@{ $hs_record->{'Info'}} ) {
            $err.=$error;
        }

        #-- Fehler des gesamten Records ermitteln   
        foreach my $error (@{ $hs_record->{'Warn'}} ) {
            $warn.=$error;
        }

        #-- Schleife über alle externen Felder
        foreach my $ext_field ( @{ $json->{ 'Fields'}} ) {

            my $msg;
            
            #-- Schleife über alle Fehler des Feldes, steht an pos 2 
            foreach my $error (@{$hs_record->{'Data'}->{ $ext_field }->[2]}) {
                #-- wenn Feld einen Fehler hat
                #-- wenn nicht long, dann short
                if ($error->[0]->msg_long) {
                    $msg=$error->[0]->msg_long;
                }
                else {
                    $msg=$error->[0]->msg_short;
                }
           
                #-- zwischen speichern 
                $hs_error{$ext_field}=$msg;
            }

        }



        #-- Warnung 
        if (( %hs_error ) and (!$err)) {
            $zeile='style="background-color:lightgray"';
            $firstrow.='<td>ERR</td>';
            $insert_false++;
            push(@bak,$counter);
        }

        #-- Datensatz sperren
        elsif ($err) {
            $zeile='style="background-color:lightgray"';
            $firstrow.='<td ><a class="tip" href="#" style="color:red">ERR<span>'.$err.'</span></a></td>';
            $insert_false++;
            push(@bak,$counter);
        }

        #-- ok 
        else {
            $zeile='style="background-color:lightgreen"';
            $firstrow.='<td>OK</td>';
            $insert_ok++;
        }
       
        #-- Update/Insert-Spalte generieren 
        for (my $i=0; $i<=$#{$json->{'Tables'}};$i++) {
            my $color='lightgray';
            my $insert='';
            if ($hs_record->{'Insert'}->[$i]) {
                $color='yellow'      if ($hs_record->{'Insert'}->[$i] =~/\d+/);            
                $color='yellow'      if (lc($hs_record->{'Insert'}->[$i]) =~/update/);            
                $color='lightblue'   if (lc($hs_record->{'Insert'}->[$i]) eq 'insert') ;            
                $insert=$hs_record->{'Insert'}->[$i] if (!$err) ;
            }
            my $table=$json->{'Tables'}->[$i];
            $up_ins.='<td  style="background-color:'.$color.'" >'.$insert.'</td>';
        }
        
        #-- undef beseitigen
        map {if (!defined $hs_record->{'Data'}->{$_}->[0]) {$hs_record->{'Data'}->{$_}->[0] = ''} } @{ $json->{ 'Fields'}};

        #-- html-Tabelle erzeugen
        foreach my $ext_field ( @{ $json->{ 'Fields'}} ) {
            
            #-- Errormessage integrieren
            if (exists $hs_error{ $ext_field }) {
               $row.='<td style="background-color:red">';
               $row.='<a class="tip" href="#" style="color:white">'.$hs_record->{'Data'}->{$ext_field}->[0].'<span>'.$hs_error{$ext_field }.'</span></a>'; 
            }
            else {
                $row.="<td>";
                $row.=$hs_record->{'Data'}->{$ext_field}->[0];
            }
            $row.="</td>";    
        }

        #-- if error, then write first column 
#       if ($err or $apiis->status ) {
#        
#            my $i; 
#            $zeile='style="background-color:lightgray"';
#            foreach ($apiis->errors) {
#                $err.=$apiis->errors->[$i++]->msg_short.'; ';
#            }
#            $firstrow.='<td ><a class="tip" href="#" style="color:red">ERR<span>'.$err.'</span></a></td>';
#        }

        #-- Check Status oder wenn nur Prüfen  
        if (($apiis->status) or (lc($onlycheck) eq 'on')) {
            
            #--  Fehlerauswertung

            #-- Druck wenn onlycheck 
            if ((!$onlycheck) or (lc($onlycheck) eq 'on')) {
           
                print "<tr $zeile >". $firstrow . $up_ins . $row. '</tr>';
                
                if ( $err) {
                    print "<tr $zeile >".'<td colspan="100">'.$err.'</td></tr>';
                }
                if ( %hs_error ) {
                    foreach (keys %hs_error) {
                        print "<tr $zeile >".'<td colspan="100">'."$_: $hs_error{$_}".'</td></tr>';
                    }
                }
                if ($warn ) {
                    $zeile='style="background-color:orange"';
                        print "<tr $zeile >".'<td colspan="100">'.$warn.'</td></tr>';
                }

            }
        }

        $apiis->status(0);
        $apiis->del_errors;
    }

    #-- Tabelle drucken, wenn nur check 
    if ((!$onlycheck) or (lc($onlycheck) eq 'on')) {
   
        my $vbreed='';

        if ($breed) {
            $vbreed="&breed=$breed".
        }

        print '</table>';
        print '<p>';
        print '<a style="background-color:lightgray;border:3px outset darkgray" href="/cgi-bin/GUI?user=lfgroene&pw_user=agrum1&m=chick&o=htm2htm&g=/etc/reports/FileUpload.rpt&f=1&user=apiis&importfilter='.$importfilter.'&filename='.$filename.'&onlycheck=off&Field_514=Datei hochladen'.$vbreed.'&__form=/etc/reports/FileUpload.rpt">'.main::__('Upload file and fill database').'</a>';
        
        print '<h4>'.main::__('Result of loading:').'</h4><p>';
        print '<table>';
        print '<tr><td>'.main::__('No. of animals loaded without errors:').' </td><td>'.$insert_ok.'</td></tr>';
        print '<tr><td>'.main::__('No. of animals not loaded:').' </td><td>'.$insert_false.'</td></tr>';
        print '</table>';
    }
    else {
        
            open(OUT, ">".$apiis->APIIS_LOCAL."/tmp/$filenameout") || print "kann ".$apiis->APIIS_LOCAL."/tmp/$filenameout nicht öffnen";
            foreach my $i ( @bak ) {
                print OUT $json->{'Bak'}->[$i];
            }
            close (OUT);

        print '<h4>'.main::__('Result of loading:').'</h4><p>';
        print '<table>';
        print '<tr><td>'.main::__('No. of animals loaded without errors:').' </td><td>'.$insert_ok.'</td></tr>';
        print '<tr><td>'.main::__('No. of animals not loaded:').' </td><td>'.$insert_false.'</td></tr>';
        print '</table>';
        print '<p>';

        if ($insert_false > 0) {
            print '<a style="background-color:lightgray;border:3px outset darkgray" href="/tmp/'.$filenameout.'">'.main::__('Errorfile check/download').'</a>';
        }
    }
    
Exit:

    return undef, [];
}
1;
