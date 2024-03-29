<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "form2.dtd"
[  <!ENTITY NavigationButtons_Fields SYSTEM "/home/zwisss/database_stuff/apiis/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "/home/zwisss/database_stuff/apiis/etc//actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "/home/zwisss/database_stuff/apiis/etc//statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "/home/zwisss/database_stuff/apiis/etc//dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "/home/zwisss/database_stuff/apiis/etc//statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "/home/zwisss/database_stuff/apiis/etc//callform_button_block.xml">
]>
<Form Name="Umnummerieren">
  <General Name="Umnummerieren_General" StyleSheet="/etc/apiis.css" Description="LS-Umnummerieren"/>

  <Block Name="Umnummerieren_B1" >
    <DataSource Name="Umnummerieren_DS_1" >
      <none/>
      <Parameter Name="Parameter1" Key="LO" Value="LO_Transfer"/>
    </DataSource>

    <Label Name="Umnummerieren_L1" Content="__('Renumber animal')">
      <Position Column="0" Columnspan="3" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    
    <Label Name="Umnummerieren_L2" Content="__('Animal-ID (old)'):">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>
    <Field Name="Tanimal_ext_unit" FlowOrder="1">
      <DataSource Name="Umnummerieren_DS_2">
       <Sql Statement="SELECT short_name,short_name FROM codes WHERE class='ID_SET'"/>
      </DataSource>
      <ScrollingList Size="1"  DefaultFunction="apiisrc" Default="ext_unit" />  
      <Position Column="0" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>    
    </Field>
    <Field Name="Tanimal_ext_id" FlowOrder="2">
      <DataSource Name="Umnummerieren_DS_3">
        <Sql Statement="select distinct ext_id, ext_id from unit inner join codes on ext_unit=short_name where
       codes.class='ID_SET' order by ext_id "/>
      </DataSource>
      <ScrollingList Size="1"  DefaultFunction="lastrecord" Default="ext_id" StartCompareString="right" ReduceEntries="yes" />  
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/> 
    </Field>
    <Field Name="Tanimal_ext_animal" FlowOrder="3" >
      <TextField Override="no" Size="15" DefaultFunction="lastrecord" />
      <Position Column="2" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    
    <Label Name="Umnummerieren_L3" Content="__('Animal-ID (internal)'):">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>
    <Field Name="Tanimal_db_animal" FlowOrder="4" Check="NotNull">
      <TextField Override="no" Size="7"/>
      <Position Column="0" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    
    <Label Name="Umnummerieren_L4" Content="__('Animal-ID (new)'):">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>
    <Field Name="Tanimal_ext_unit2" FlowOrder="5">
      <DataSource Name="Umnummerieren_DS_4">
       <Sql Statement="SELECT short_name,short_name FROM codes WHERE class='ID_SET'"/>
      </DataSource>
      <ScrollingList Size="1"  DefaultFunction="apiisrc" Default="ext_unit" />  
      <Position Column="0" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>    
    </Field>
    <Field Name="Tanimal_ext_id2" FlowOrder="6">
      <DataSource Name="Umnummerieren_DS_5">
        <Sql Statement="select distinct ext_id, ext_id from unit inner join codes on ext_unit=short_name where
       codes.class='ID_SET' order by ext_id"/>
      </DataSource>
      <ScrollingList Size="1"  DefaultFunction="lastrecord" Default="ext_id" StartCompareString="right" ReduceEntries="yes" />  
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/> 
    </Field>
    <Field Name="Tanimal_ext_animal2" FlowOrder="7" >
     <TextField Override="no" Size="15" DefaultFunction="lastrecord" />
      <Position Column="2" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
   
    <Label Name="Umnummerieren_L5" Content="__('What's going on with the old Animal-ID'):">
      <Position Column="0" Columnspan="3" Position="absolute" Row="7"/>
    </Label>
    <Field Name="ext_closing" FlowOrder="8" Check="NotNull">
      <DataSource Name="Umnummerieren_DS_6">
       <Sql Statement="SELECT '1' as a , 'close old Animal-ID' as b 
                 union select '2' as a , 'close all old Animal-IDs' as c 
		 union select '3' as a , 'delete old Animal-ID' as d
		 union select '4' as a , 'nothing' as e
		 union select '5' as a , 'change into new' as f"/>
      </DataSource>
      <ScrollingList Size="0" Default="nothing"/>  
      <Position Column="0" Columnspan="3" Position="absolute" Row="8"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
    
    
    <Image Name="Umnummerieren_I1" Alt="Test" Src="/icons/blank1.gif">
      <Position Column="0" Columnspan="1" Row="9"/>
      <Format PaddingTop="20px"/>
    </Image>
    
    &NavigationButtons_Fields;
    &StatusLine_Block;
    
    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>
  </Block>
</Form>
