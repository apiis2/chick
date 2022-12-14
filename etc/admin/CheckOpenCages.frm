<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "form2.dtd"
[  <!ENTITY NavigationButtons_Fields SYSTEM "/home/zwisss/database_stuff/apiis/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "/home/zwisss/database_stuff/apiis/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "/home/zwisss/database_stuff/apiis/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "/home/zwisss/database_stuff/apiis/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "/home/zwisss/database_stuff/apiis/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "/home/zwisss/database_stuff/apiis/etc/callform_button_block.xml">
]>
<Form Name="EventChange">
  <General Name="General_515" StyleSheet="/etc/apiis.css" Description="EM-Event aendern"/>

  <Block Name="Block_488" >
    <DataSource Name="DataSource_493" >
      <none/>
    </DataSource>

    <Label Name="Label_490" Content="__('Check open cages'):">
      <Position Column="0" Columnspan="3" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    
    <Field Name="Field_5140">
      <Button ButtonLabel="__('Search open cages')" URL="/etc/reports/SearchOpenCages.rpt" Command="do_open_report"/>
      <Position Column="0" Columnspan="3" Position="absolute" Row="6"/>
      <Miscellaneous/>
      <Text/>
      <Color  BackGround="lightgreen"/>
      <Format MarginTop="10px" MarginRight="20px"/>
    </Field>
    
    <Field Name="Field_51401">
      <Button ButtonLabel="__('Close open Cages')" URL="/etc/reports/CloseOpenCages.rpt" Command="do_open_report"/>
      <Position Column="0" Columnspan="3" Position="absolute" Row="6"/>
      <Miscellaneous/>
      <Text/>
      <Color BackGround="red"/>
      <Format MarginTop="10px"/>
    </Field>
    
    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>

  </Block>
</Form>
