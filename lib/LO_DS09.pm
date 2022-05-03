#####################################################################
# load object: LO_DS09
#####################################################################
# Das Ladeobjekt initialisiert eine neue Adresse
# events:
#           1. Create a new animal
#           2. create an entry in transfer and animal
#####################################################################
#-- db_cage wird übergeben. In dem Cage sind Vater und Mutter + Rasse
#-- Verfahrensweise: db_cage in animal suchen -> es müssen soviel Tiere
#-- davon existieren, wie Tiere im Käfig sind/waren
#--
#-- alle Tiere für den Cage aus animal holen
#-- männliches Tier ist der Vater
#-- weibliche Tiere sind mögliche Mütter
#-- Väter/Mütter müssen gelebt haben, als die Eier abgesammelt wurden

#TEST-DATA    
# wing_nr,sex,far_nr,breed,parentalcage,birthdate
# 1,1,1,IH,1,02.06.2014
#    $args={
#        'db_cage' =>'4608',
#        'db_sex'  =>'1',
#        'ext_animal'=>'W123',
#    };

use strict;
use warnings;
our $apiis;

sub LO_DS09 {

    use JSON;
    use URI::Escape;
    use GetDbEvent;
    use GetDbUnit;

    my $self = shift;
    my $args  = shift;

    my $json;
    my $err_ref;
    my $err_status;
    my @record;
    my $extevent;
    my %hs_cages_per_line;
    my %hs_found_cages_for_line;
    my %hs_ext_animal;
    my $birth_dt;

    my %hs_event = ();
    my $db_event;

    our $hs_animal;
    my @field;
    my $hs_fields={};
    my $fileimport;
    if (exists $args->{ 'FILE' }) {
        $fileimport=$args->{ 'FILE' };
    }
    my $onlycheck='off';
    if (exists $args->{ 'onlycheck' }) {
        $onlycheck=lc($args->{ 'onlycheck' });
    }
    my $action;
    if (exists $args->{ 'action' }) {
        $action=lc($args->{ 'action' });
    }

    $json = { 'Info'        => [],
              'RecordSet'   => [],
              'Bak'         => [],
            };

    #-- Wenn ein File geladen werden soll, dann zuerst umwandeln in
    #   einen JSON-String, damit einheitlich weiterverarbeitet werden kann
    if ( $fileimport ) {

        #-- Datei öffnen
        open( IN, "$fileimport" ) || die "error: kann $fileimport nicht öffnen";

        $json = { 'Info'        => [],
                  'RecordSet'   => [],
                  'Bak'         => [],
                };

        #-- Schleife über alle Datensätze
        while ( <IN> ) {

            push( @{ $json->{ 'Bak' } },$_); 
            
            #-- Zeilenumbruch entfernen
            chomp();

            #-- declare
            my @data;
            my $record;
            my $hs = {};

            #-- skip first record 
            next if ($.<2);

            #-- file
            $hs_fields->{'ahb'}     ={'ext_id'=>'cage', 'ext_sex'=>'sex','ext_animal'=>'wingnumber', 'ext_breed'=>'ext_breed'};

            @field=('ext_animal','ext_sex','far','ext_cage', 'ext_breed','birth_dt','ext_sire','ext_dam');

            @data = split(';', $_ ,6);

            #-- remove leading zeros or spaces and comma to dot
            map { $_ =~ s/^[\s]+//g; $_ =~ s/\s+$//g;   $_=~s/,/./g; $_='' if (!$_) } @data;

            #-- skip if no cage-ID
            next if ( !$data[ 2 ] and !$data[3] );

            #-- define format for record 
            $record = {
                    'ext_unit_animal'   => [ 'wing_id_system','',[] ],
                    'ext_id_animal'     => [ 'Hvam'.substr($data[5],6,4),'',[] ],
                    'ext_animal'        => [ $data[0],'',[] ],
                    'ext_sex'           => [ $data[1],'',[] ],
                    'far'               => [ $data[2],'',[] ],
                    'ext_breed'         => [ $data[3],'',[] ],
                    'birth_dt'          => [ $data[5],'',[] ],
                    'ext_cage'          => [ $data[4],'',[] ],
            };

            $birth_dt=substr($data[5],6,4) if (!$birth_dt);

            #-- Datensatz mit neuen Zeiger wegschreiben
            push( @{ $json->{ 'RecordSet' } },{ 'Info' => [], 'Data' => { %{$record} },'Insert'=>[], 'Tables'=>['animal','transfer','possible_dams']} );
        }

        #-- Datei schließen
        close( IN );
        
        $json->{ 'Fields'}  = [@field];
    }
    else {

        #-- String in einen Hash umwandeln
        if (exists $args->{ 'JSON' }) {
            $json = from_json( $args->{ 'JSON' } );
        }
        else {
            $json={ 'RecordSet' => [{Info=>[],'Data'=>{}}]};
            map { $json->{ 'RecordSet'}->[0]->{ 'Data' }->{$_}=[];
                  $json->{ 'RecordSet'}->[0]->{ 'Data' }->{$_}[0]=$args->{$_}} keys %$args;
        }
    }

    
#-- Ab hier ist es egal, ob die Daten aus einer Datei

    my $birth_old=$birth_dt;
    $birth_old--;

    my $parentno=1;
    my $ext_cage='';
    my $ext_sire;
    my $ext_dam;
    my $cnt;

    #   oder aus einer Maske kommen
    #-- Schleife über alle Records und INFO füllen
    foreach my $hs_record ( @{ $json->{ 'RecordSet' } } ) {

        my $args={};
        my $insert;

        #-- Daten aus Hash holen
        foreach (keys %{ $hs_record->{ 'Data' } }) {
            $args->{$_}=$hs_record->{ 'Data' }->{$_}->[0];
        }

        $cnt++;
#        if ($cnt==13) {
#            print "kk";
#        }

        #-- create a sequence number for unknown parents, the assumption is, that each animal from the same cage 
        #-- has the same parents 
        if ($ext_cage ne $args->{'ext_cage'}) {
            my $ext_breed=$args->{'ext_breed'};
            $ext_sire=$ext_breed.'_'.$parentno++;
            $ext_dam =$ext_breed.'_'.$parentno++;
            $ext_cage=$args->{'ext_cage'};
        }
        
        $args->{'ext_sire'}=$ext_sire;
        $args->{'ext_dam'}=$ext_dam;

        #-- im ersten Schritt muss der Käfig neu angelegt werden.
        #-- wenn es den Käfig gibt, dann db_unit als db_cage verwenden 
        $args->{'ext_cage'}='' if (!$args->{'ext_cage'});
        $args->{'db_cage'}=GetDbUnit( {
                                'ext_unit'=>'cage',
                                'ext_id'  =>$args->{'ext_cage'}
                                 });

        my $msg;
        my $extfield;
        my $msgtype='Info';
        my $e=-2;
        #-----------------------------------------------------------------
        # close unit

        $json->{'Tables'}=['transfer', 'animal','transfer', 'animal','transfer', 'animal','possible_dams'];
        $hs_record->{'Insert'}= ['-', '-' ,'-','-', '-' ,'-', '-'];

        my ($ext_unit, $ext_id, $ext_animal, $ext_breed, $ext_sex, $guidp);
        
        for my $elter ( 'Vater', 'Mutter', 'Tier' ) {

            #-- position for insert-array 
            $e=$e+2;

            my ( $ext_animal_field, $ext_unit_field, $ext_id_field, $db_animal, $guida, $guidt );
            if ( $elter eq 'Vater' ) {
                $ext_unit         = $args->{'ext_unit_animal'};
                $ext_id           = 'Hvam'.$birth_old;
                $ext_animal       = $args->{'ext_sire'};
                $ext_breed        = $args->{'ext_breed'};
                $ext_sex          = '1';
            }
            elsif ( $elter eq 'Mutter' ) {
                $ext_unit         = $args->{'ext_unit_animal'};
                $ext_id           = 'Hvam'.$birth_old;
                $ext_animal       = $args->{'ext_dam'};
                $ext_breed        = $args->{'ext_breed'};
                $ext_sex          = '2';
            }
            else {
                #--check for double wingnumber 
                $hs_ext_animal{ $args->{'ext_animal'}}++;

                if ( $hs_ext_animal{ $args->{'ext_animal'}} >1 ) {
            
                    #-- Fehler in Info des Records schreiben
                    push(@{$hs_record->{ 'Info'}}, main::__("Wingnumber [_1] exists", $args->{'ext_animal'}));

                    goto EXIT;
                }

                $ext_unit         = $args->{'ext_unit_animal'};
                $ext_id           = $args->{'ext_id_animal'};
                $ext_animal       = $args->{'ext_animal'};
                $ext_breed        = $args->{'ext_breed'};
                $ext_sex          = $args->{'ext_sex'};
            }


            # Nachschauen, ob es das Tier in der Datenbank gibt
            #-- Check, ob insert oder update
            my $sql="select a.guid, c.guid, b.guid, b.db_animal  from possible_dams a full outer join transfer b on a.db_animal=b.db_animal
                    left outer join animal c on c.db_animal=b.db_animal inner join unit d on b.db_unit=d.db_unit where d.ext_unit='"
                    .$ext_unit."' and d.ext_id='$ext_id' and b.ext_animal='$ext_animal'";

            #-- SQL auslösen 
            my $sql_ref = $apiis->DataBase->sys_sql( $sql );
            
            #-- Fehlerbehandlung 
            if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {

                if ($fileimport) {

                    #-- Fehler in Info des Records schreiben
                    push(@{$hs_record->{ 'Info'}},$sql_ref->errors->[0]->msg_long);

                    #-- Fehler in Info des Records schreiben
                    $apiis->status(0);
                    $apiis->del_errors;
                    next;
                }
                else {
                    $self->errors( $apiis->errors);
                    $self->status(1);
                    $apiis->status(1);
                    goto EXIT;
                }   
            }

            #-- Voreinstellung
            $insert=main::__('Insert');
            
            # Auslesen des Ergebnisses der Datenbankabfrage
            while ( my $q = $sql_ref->handle->fetch ) {
                $insert          = $q->[2];
                $guidp = $q->[0];
                $guida = $q->[1];
                $guidt = $q->[2];
                $db_animal       = $q->[3];

                $hs_record->{'Insert'}->[$e]  =$guidt;
                $hs_record->{'Insert'}->[$e+1]=$guida;
            }

            if ( defined $db_animal ) {
                $args->{'db_sire'}   = $db_animal if ( $elter eq 'Vater' );
                $args->{'db_dam'}    = $db_animal if ( $elter eq 'Mutter' );
                $args->{'db_animal'} = $db_animal if ( $elter eq 'Tier' );
            }
            else {

                my $now = $apiis->now;
                if ( ($ext_animal) and ( $ext_animal ne '' ) ) {

                    my $transfer = Apiis::DataBase::Record->new( tablename => 'transfer', );
                
                    #-- db_animal wird nicht mit pre_insert gesetzt
                    my $db_animal=$apiis->DataBase->seq_next_val('seq_transfer__db_animal');

                    $transfer->column('db_animal')->intdata($db_animal);
                    $transfer->column('db_animal')->encoded(1);
                    
                    $transfer->column('db_unit')->extdata( $ext_unit, $ext_id );
                    $transfer->column('db_unit')->ext_fields( $ext_unit_field, $ext_id_field );

                    $transfer->column('ext_animal')->extdata($ext_animal);
                    $transfer->column('ext_animal')->ext_fields($ext_animal_field);

                    #-- opening_dt 
                    my $od = $args->{ 'birth_dt' } ;

                    #-- opening_dt muss besetzt sein: mit aktuellem Datum, falls undef
                    $od = $apiis->now  if ( !$od or ( $od eq '' ) );
                    $transfer->column('opening_dt')->extdata( $od );

                    $transfer->column('id_set')->extdata($ext_unit);

                    if ($guidt) {

                        #-- guid
                        if ($guidt and ($guidt ne '')) {
                            $transfer->column( 'guid' )->extdata( $guidt );
                        }   

                        #-- DS modifizieren
                        $hs_record->{'Insert'}->[$e]=$guidt;
                
                        $transfer->update;
                    }
                    else {
            
                        $hs_record->{'Insert'}->[$e]=$insert;

                        $transfer->insert();
                    }
                    
                    #-- Fehlerbehandlung 
                    if ( $transfer->status ) {
                        if ($fileimport) {

                            #-- Fehler in Info des Records schreiben
                            push(@{$hs_record->{ 'Info'}},$transfer->errors->[0]->msg_short);

                            #-- Fehler in Info des Records schreiben
                            $apiis->status(0);
                            $apiis->del_errors;
                            next;
                        }
                        else {
                            $apiis->status(1);
                            $apiis->errors( scalar $transfer->errors );

                            goto EXIT;
                        }
                    }
                
                    $args->{'db_sire'}   = $db_animal if ( $elter eq 'Vater' );
                    $args->{'db_dam'}    = $db_animal if ( $elter eq 'Mutter' );
                    $args->{'db_animal'} = $db_animal if ( $elter eq 'Tier' );

                    #-- übernahme db_animal  
                    $args->{'db_animal'}=$transfer->column('db_animal')->intdata();

                    my $animal = Apiis::DataBase::Record->new( tablename => 'animal', );
                    
                    if ( $animal->status ) {

                        if ($fileimport) {

                            #-- Fehler in Info des Records schreiben
                            push(@{$hs_record->{ 'Info'}},$animal->errors->[0]->msg_long);

                            #-- Fehler in Info des Records schreiben
                            $apiis->status(0);
                            $apiis->del_errors;
                            next;
                        }
                        else {
                            $self->status(1);
                            $err_ref = scalar $animal->errors;
                            last EXIT;
                        }
                    }
                    $animal->column('db_animal')->intdata(  $args->{'db_animal'} );
                    $animal->column('db_animal')->encoded(1);

                    if ( $elter eq 'Tier' ) {

                        $animal->column('db_sire')->intdata( $args->{'db_sire'} );
                        $animal->column('db_sire')->encoded(1);
                        $animal->column('db_dam')->intdata( $args->{'db_dam'} );
                        $animal->column('db_dam')->encoded(1);

                        $animal->column('db_sex')->extdata( $args->{'ext_sex'} );
                        $animal->column('db_sex')->ext_fields('sex');

                        $animal->column('birth_dt')->extdata( $args->{'birth_dt'} );
                        $animal->column('birth_dt')->ext_fields('birth_dt');
                    }
                    elsif ( $elter eq 'Vater' ) {

                        $animal->column('db_sex')->extdata('1');
                        $animal->column('db_sire')->intdata('1');
                        $animal->column('db_sire')->encoded(1);
                        $animal->column('db_dam')->intdata('2');
                        $animal->column('db_dam')->encoded(1);
                        $animal->column('db_cage')->intdata( $args->{'db_cage'} );
                        $animal->column('db_cage')->encoded(1);
                    
                    }
                    else {

                        $animal->column('db_sex')->extdata('2');
                        $animal->column('db_sire')->intdata('1');
                        $animal->column('db_sire')->encoded(1);
                        $animal->column('db_dam')->intdata('2');
                        $animal->column('db_dam')->encoded(1);
                        $animal->column('db_cage')->intdata( $args->{'db_cage'} );
                        $animal->column('db_cage')->encoded(1);
                    
                    }
                    
                    $animal->column('db_breed')->extdata( $args->{'ext_breed'} );
                    $animal->column('db_breed')->ext_fields('breed');

                    #-- if animal exists in table animal  
                    if ($guida and  ($guida  ne '')) {

                        #-- guid
                        if ($guida and ($guida ne '')) {
                            $animal->column( 'guid' )->extdata( $guida );
                        }   

                        #-- DS modifizieren
                        $hs_record->{'Insert'}->[$e+1]=$guida;
                            
                        $animal->update;
                    }
                    else {
                        
                        $hs_record->{'Insert'}->[$e+1]=$insert;

                        $animal->insert();
                    }

                    if ( $animal->status ) {
                        if ($fileimport) {

                            #-- Fehler in Info des Records schreiben
                            push(@{$hs_record->{ 'Info'}},$animal->errors->[0]->msg_short);

                            #-- Fehler in Info des Records schreiben
                            $apiis->status(0);
                            $apiis->del_errors;
                            next;
                        }
                        else {
                            $self->status(1);
                            if ( $animal->errors->[0]->msg_short =~ /dupliziert/ ) {
                                $animal->errors->[0]->msg_short('Animal-Id exists already.');
                                $animal->errors->[0]->msg_long('');
                                $animal->errors->[0]->ext_fields( ['ext_animal'] );
                            }
                            $err_ref = scalar $animal->errors;
                            last EXIT;
                        }
                    }
                }
            }
        }

        #-- Tabelle der möglichen Mütter füllen 
        my $possible_dams = Apiis::DataBase::Record->new( tablename => 'possible_dams' );
        
        $possible_dams->column( 'db_animal' )->intdata( $args->{ 'db_animal'} );
        $possible_dams->column( 'db_animal' )->encoded( 1 );
        $possible_dams->column( 'db_animal' )->ext_fields( qw/ ext_animal / );
        
        #-- Schleife über die Anzahl der Hennen im Käfig 
        for (my $i=1; $i<=1;$i++ ) {

            $possible_dams->column( 'db_dam'.$i )->intdata( $args->{ 'db_dam'} );
            $possible_dams->column( 'db_dam'.$i )->encoded( 1 );
            $possible_dams->column( 'db_dam'.$i )->ext_fields( qw/ ext_animal / );
        }
        
        #-- if animal exists in table animal  
        if ($guidp and  ($guidp  ne '')) {

            #-- guid
            if ($guidp and ($guidp ne '')) {
                $possible_dams->column( 'guid' )->extdata( $guidp );
            }   

            #-- DS modifizieren
            $hs_record->{'Insert'}->[6]=$guidp;
               
            $possible_dams->update;
        }
        else {
            
            #-- if form says "only inserts", then ignore and give a warning 
            $hs_record->{'Insert'}->[6]=$insert;

            $possible_dams->insert();
        }

        if ( $possible_dams->status ) {

            if ($fileimport) {

                #-- Fehler in Info des Records schreiben
                push(@{$hs_record->{ 'Info'}},$possible_dams->errors->[0]->msg_long);

                #-- Fehler in Info des Records schreiben
                $apiis->status(0);
                $apiis->del_errors;
                next;
            }
            else {
                $self->status(1);
                if ( $possible_dams->errors->[0]->msg_short =~ /dupliziert/ ) {
                    $possible_dams->errors->[0]->msg_short('Animal-Id exists already.');
                    $possible_dams->errors->[0]->msg_long('');
                    $possible_dams->errors->[0]->ext_fields( ['ext_animal'] );
                }
                $err_ref = scalar $possible_dams->errors;
                last EXIT;
            }
        }

EXIT:
        if ((!$apiis->status) and ($onlycheck eq 'off')) {
            $apiis->DataBase->commit;
        }
        else {
            $apiis->DataBase->rollback;
        }
    }
     
    if ($fileimport) {
        return $json;
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;
__END__

