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
  <General Name="G177" StyleSheet="/etc/apiis.css" Description="__('Individual tagging')"/>

  <Block Name="DS051" Description="'Individual tagging'">
    <DataSource Name="DataSource_493"  Connect="no">
        <none/>
        <Parameter Name="Parameter1" Key="LO" Value="LO_DS05"/>
    </DataSource>
		    
    <Label Name="DS052" Content="__('Individual tagging')">
      <Position Column="0" Columnspan="5" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="none"/>
      <Format PaddingBottom="10px"/>
    </Label>

    <Label Name="DS053" Content="__('Parental cage-ID')">
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
 
    <Label Name="DS054" Content="__('Wing ID')">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>
    <Field Name="db_animal" FlowOrder="3" Check="NotNull" >
       <TextField Override="no" Size="2" MaxLength="4"/>  
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="DS055" Content="__('Sex')">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="db_sex" FlowOrder="2" Check="NotNull" InternalData="yes" >
      <DataSource Name="DataSource_2345">
      <Sql Statement="SELECT db_code, short_name   
              FROM entry_codes
              WHERE class='SEX'"/> 

      </DataSource>
      <ScrollingList Size="1" ReduceEntries="yes" />  
      <Position Column="1" Position="absolute" Row="5"/>
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
