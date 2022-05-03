<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://chick.local/etc/form2.dtd"[  
  <!ENTITY NavigationButtons_Fields SYSTEM "http://chick.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://chick.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://chick.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://chick.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://chick.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://chick.local/etc/callform_button_block.xml">
]>
<Form Name="F8">
  <General Name="G177" StyleSheet="/etc/apiis.css" Description="__('DS08: Egg weights')"/>

  <Block Name="DS081" Description="DS08: Egg weights">
    <DataSource Name="DataSource_493"  Connect="no">
        <none/>
        <Parameter Name="Parameter1" Key="LO" Value="LO_DS08"/>
    </DataSource>
		    
    <Label Name="DS082" Content="__('DS08: Egg weights')">
      <Position Column="0" Columnspan="5" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>
 
   <Label Name="DS083" Content="__('Event')">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>
    
 <Field Name="db_event" FlowOrder="2" Check="NotNull" InternalData="yes" >
      <DataSource Name="DataSource_123">
	<Sql Statement="select db_event, event_dt || ':::' || ext_code from event a inner join codes b on a.db_event_type=b.db_code where b.ext_code='event_weighing_eggs' order by event_dt desc limit 2; "/>
      </DataSource>
      <ScrollingList Size="1" ReduceEntries="yes" />  
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="DS085" Content="__('Cage-ID')">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>
        
    <!--  "db_cage" ist Verbindung zum Ladestrom, Namen müssen gleich sein  --> 
    <!--  übergeben wird die erste Spalte des SQL, angezeigt die zweite  -->

    <Field Name="db_cage" FlowOrder="2" Check="NotNull" InternalData="yes" >
      <DataSource Name="DataSource_1015ba">
       <Sql Statement="SELECT distinct db_cage as id,  ext_id as ext_id  
              FROM v_active_animals_and_cages  
              WHERE ext_unit='cage'  
              ORDER BY ext_id"/>
      </DataSource>
      <ScrollingList Size="1" ReduceEntries="yes" />  
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

 
    <Label Name="DS086" Content="__('number of hens')">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>
    <Field Name="number_hens" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="2" MaxLength="2"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

  <Label Name="DS087" Content="__('number of eggs')">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>
    <Field Name="n_eggs" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="2" MaxLength="2"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
 
 <Label Name="DS088" Content="__('total weight eggs')">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>
    <Field Name="total_weight_eggs" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="2" MaxLength="8"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


 <!--
    <Label Name="L6958" Content="__('Hatched Eggs')">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>
    <Field Name="hatched_eggs" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="2" MaxLength="2"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
-->
    &NavigationButtons_Fields;
    &StatusLine_Block;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>

  </Block>
</Form>
