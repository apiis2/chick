<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "form2.dtd"
[  <!ENTITY NavigationButtons_Fields SYSTEM "/home/zwisss/database_stuff/apiis/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "/home/zwisss/database_stuff/apiis/etc//actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "/home/zwisss/database_stuff/apiis/etc//statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "/home/zwisss/database_stuff/apiis/etc//dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "/home/zwisss/database_stuff/apiis/etc//statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "/home/zwisss/database_stuff/apiis/etc//callform_button_block.xml">
]>
<Form Name="F8">
  <General Name="G177" StyleSheet="/etc/apiis.css" Description="Tiere"/>

  <Block Name="B178" Description="Update animal">
    <DataSource Name="DataSource_493"  Connect="no">
        <none/>
        <Parameter Name="Parameter1" Key="LO" Value="LO_NewAnimal"/>
    </DataSource>
		    
    <Label Name="L694" Content="__('Data stream: DS12_CreateNewAnimal')">
      <Position Column="0" Columnspan="5" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    <Label Name="L695" Content="__('Animal'):">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="Tanimal_ext_unit" FlowOrder="1" Check="NotNull" >
      <DataSource Name="DataSource_1015a">
       <Sql Statement="SELECT short_name,short_name FROM codes WHERE class='ID_SET' "/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_unit" />  
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Tanimal_ext_id" FlowOrder="2"  Check="NotNull">
      <DataSource Name="DataSource_1015ak">
       <Sql Statement="SELECT ext_id, ext_id from unit inner join codes on ext_unit=codes.ext_code and class='ID_SET' and ext_unit='wing_id_system' order by ext_unit,ext_id"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" />  
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Tanimal_ext_animal" FlowOrder="3"  Check="NotNull">
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    
    <Label Name="L104" Content="__('Rooster'):">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>
    <Field Name="Vanimal_ext_unit" FlowOrder="4"  Check="NotNull">
      <DataSource Name="DataSource_1015a1">
       <Sql Statement="SELECT short_name,short_name FROM codes WHERE class='ID_SET'"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_unit" />  
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Vanimal_ext_id" FlowOrder="5"  Check="NotNull">
      <DataSource Name="DataSource_1015al">
       <Sql Statement="SELECT ext_id, ext_id from unit inner join codes on ext_unit=codes.ext_code and class='ID_SET' order by ext_unit,ext_id"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" />  
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Vanimal_ext_animal" FlowOrder="6"  Check="NotNull">
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    
    <Label Name="L115" Content="__('Hen'):">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>
    <Field Name="Manimal_ext_unit" FlowOrder="7"  Check="NotNull">
      <DataSource Name="DataSource_1015a2">
       <Sql Statement="SELECT short_name,short_name FROM codes WHERE class='ID_SET'"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_unit" />  
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Manimal_ext_id" FlowOrder="8"  Check="NotNull">
      <DataSource Name="DataSource_1015am">
       <Sql Statement="SELECT ext_id, ext_id from unit inner join codes on ext_unit=codes.ext_code and class='ID_SET' order by ext_unit,ext_id"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" />  
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Manimal_ext_animal" FlowOrder="9"  Check="NotNull">
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L92" Content="__('Sex'):">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>
    <Field Name="sex" FlowOrder="10"  InternalData="yes"  Check="NotNull">
      <DataSource Name="DataSource_1015a3">
       <Sql Statement="SELECT db_code, ext_code FROM codes WHERE class='SEX' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" />  
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L165" Content="__('Breed'):">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>
    <Field Name="breed" FlowOrder="11"  InternalData="yes"  Check="NotNull">
      <DataSource Name="DataSource_1015a4">
       <Sql Statement="SELECT db_code, ext_code FROM codes WHERE class='BREED' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" />  
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L101" Content="__('Birthdate'):">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>
    <Field Name="birth_dt"  FlowOrder="12" >
      <TextField Size="5" InputType="date"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous/>
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

