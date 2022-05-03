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
  <General Name="DS061" StyleSheet="/etc/apiis.css" Description="__('Mating')"/>

  <Block Name="DS062" Description="Mating">
    <DataSource Name="DataSource_493"  Connect="no">
        <none/>
        <Parameter Name="Parameter1" Key="LO" Value="LO_DS06"/>
    </DataSource>
		    
    <Label Name="DS063" Content="__('Mating')">
      <Position Column="0" Columnspan="5" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    
    
    <Label Name="DS065" Content="__('Cage')">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>
    <Field Name="ext_cage" FlowOrder="2" Check="NotNull">
      <TextField Override="no" Size="4" MaxLength="4"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
 

    <Label Name="DS064" Content="__('Wingnumber male')">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>
    <Field Name="db_animal_id1" FlowOrder="1" Check="NotNull" >
      <DataSource Name="DS_id1">
       <Sql Statement="SELECT db_animal, user_get_ext_id_animal(db_animal) FROM entry_animal WHERE db_sex=(select db_code from codes where class='SEX' and ext_code='1') and db_cage isnull"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
   
 
    <Label Name="DS0641" Content="__('Wingnumber female')">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>
    <Field Name="db_animal_id2" FlowOrder="1" Check="NotNull" >
      <DataSource Name="DS_id2">
       <Sql Statement="SELECT db_animal, user_get_ext_id_animal(db_animal) FROM entry_animal WHERE db_sex=(select db_code from codes where class='SEX' and ext_code='2') and db_cage isnull"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
   
    <Label Name="DS0642" Content="__('Wingnumber female')">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>
    <Field Name="db_animal_id3" FlowOrder="1" Check="NotNull" >
      <DataSource Name="DS_id3">
       <Sql Statement="SELECT db_animal, user_get_ext_id_animal(db_animal) FROM entry_animal WHERE db_sex=(select db_code from codes where class='SEX' and ext_code='2') and db_cage isnull"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
   
    <Label Name="DS0643" Content="__('Wingnumber female')">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>
    <Field Name="db_animal_id4" FlowOrder="1" Check="NotNull" >
      <DataSource Name="DS_id4">
       <Sql Statement="SELECT db_animal, user_get_ext_id_animal(db_animal) FROM entry_animal WHERE db_sex=(select db_code from codes where class='SEX' and ext_code='2') and db_cage isnull"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
   
    <Label Name="DS0644" Content="__('Wingnumber female')">
      <Position Column="0" Position="absolute" Row="9"/>
    </Label>
    <Field Name="db_animal_id5" FlowOrder="1" Check="NotNull" >
      <DataSource Name="DS_id5">
       <Sql Statement="SELECT db_animal, user_get_ext_id_animal(db_animal) FROM entry_animal WHERE db_sex=(select db_code from codes where class='SEX' and ext_code='2') and db_cage isnull"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="9"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
   
    <Label Name="DS0645" Content="__('Wingnumber female')">
      <Position Column="0" Position="absolute" Row="10"/>
    </Label>
    <Field Name="db_animal_id6" FlowOrder="1" Check="NotNull" >
      <DataSource Name="DS_id6">
       <Sql Statement="SELECT db_animal, user_get_ext_id_animal(db_animal) FROM entry_animal WHERE db_sex=(select db_code from codes where class='SEX' and ext_code='2') and db_cage isnull"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="10"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
   
    <Label Name="DS0646" Content="__('Wingnumber female')">
      <Position Column="0" Position="absolute" Row="11"/>
    </Label>
    <Field Name="db_animal_id7" FlowOrder="1" Check="NotNull" >
      <DataSource Name="DS_id7">
       <Sql Statement="SELECT db_animal, user_get_ext_id_animal(db_animal) FROM entry_animal WHERE db_sex=(select db_code from codes where class='SEX' and ext_code='2') and db_cage isnull"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="11"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
   
    <Label Name="DS0647" Content="__('Wingnumber female')">
      <Position Column="0" Position="absolute" Row="12"/>
    </Label>
    <Field Name="db_animal_id8" FlowOrder="1" Check="NotNull" >
      <DataSource Name="DS_id8">
       <Sql Statement="SELECT db_animal, user_get_ext_id_animal(db_animal) FROM entry_animal WHERE db_sex=(select db_code from codes where class='SEX' and ext_code='2') and db_cage isnull"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="12"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
   
    <Label Name="DS0648" Content="__('Wingnumber female')">
      <Position Column="0" Position="absolute" Row="13"/>
    </Label>
    <Field Name="db_animal_id9" FlowOrder="1" Check="NotNull" >
      <DataSource Name="DS_id9">
       <Sql Statement="SELECT db_animal, user_get_ext_id_animal(db_animal) FROM entry_animal WHERE db_sex=(select db_code from codes where class='SEX' and ext_code='2') and db_cage isnull"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="13"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
   
    <Label Name="DS0649" Content="__('Wingnumber female')">
      <Position Column="0" Position="absolute" Row="14"/>
    </Label>
    <Field Name="db_animal_id10" FlowOrder="1" Check="NotNull" >
      <DataSource Name="DS_id10">
       <Sql Statement="SELECT db_animal, user_get_ext_id_animal(db_animal) FROM entry_animal WHERE db_sex=(select db_code from codes where class='SEX' and ext_code='2') and db_cage isnull"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="14"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
   
    <Label Name="DS06410" Content="__('Wingnumber female')">
      <Position Column="0" Position="absolute" Row="15"/>
    </Label>
    <Field Name="db_animal_id11" FlowOrder="1" Check="NotNull" >
      <DataSource Name="DS_id11">
       <Sql Statement="SELECT db_animal, user_get_ext_id_animal(db_animal) FROM entry_animal WHERE db_sex=(select db_code from codes where class='SEX' and ext_code='2') and db_cage isnull"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="15"/>
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
