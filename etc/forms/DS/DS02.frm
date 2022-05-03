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
  <General Name="G177" StyleSheet="/etc/apiis.css" Description="__('Number of eggs collected')"/>

  <Block Name="DS021" Description="'DS02:Number of eggs collected'">
    <DataSource Name="DataSource_493"  Connect="no">
        <none/>
        <Parameter Name="Parameter1" Key="LO" Value="LO_DS020304"/>
    </DataSource>
		    
    <Label Name="DS022" Content="__('DS02: Number of eggs collected.')">
      <Position Column="0" Columnspan="5" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="none"/>
      <Format PaddingBottom="10px"/>
    </Label>

    <Label Name="DS023" Content="__('Event')">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>
    
 <Field Name="db_event" FlowOrder="3" Check="NotNull" InternalData="yes" >
      <DataSource Name="DataSource_123">
	<Sql Statement="set datestyle to 'german'; SELECT b.db_event as id,  CASE WHEN b.event_dt::text isnull THEN 'unknown' ELSE b.event_dt::text END   || ', ' ||  CASE WHEN d.ext_id::text isnull THEN 'unknown' ELSE d.ext_id::text END  as ext_trait FROM  event AS b LEFT OUTER JOIN  codes AS c ON c.db_code=b.db_event_type LEFT OUTER JOIN  unit AS d ON d.db_unit=b.db_location  where date_part('year', b.event_dt)>=date_part('year', current_date)-3 GROUP BY id,b.event_dt, ext_trait ORDER BY b.event_dt desc limit 1"/>
      </DataSource>
      <ScrollingList Size="1" ReduceEntries="yes" />  
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
 
    <Label Name="DS024" Content="__('Cage-ID')">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>
    
    
    <!--  "db_cage" ist Verbindung zum Ladestrom, Namen müssen gleich sein  --> 
    <!--  übergeben wird die erste Spalte des SQL, angezeigt die zweite  -->

    <Field Name="db_cage" FlowOrder="1" Check="NotNull" InternalData="yes" >
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
 
    <Label Name="DS025" Content="__('Number of eggs collected')">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>
    <Field Name="collected_eggs" FlowOrder="2" Check="NotNull" >
       <TextField Override="no" Size="2" MaxLength="2"/>  
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    &NavigationButtons_Fields;
    &StatusLine_Block;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>

  </Block>
</Form>
