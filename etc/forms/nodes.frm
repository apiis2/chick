<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://chick.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://chick.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://chick.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://chick.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://chick.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://chick.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://chick.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1571424431">
  <General Name="G265.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B266" Description="Update nodes">
     
    <DataSource Name="DS267" Connect="no">
      <Record TableName="nodes"/>
      <Column DBName="address" Name="C257" Order="0" Type="DB"/>
      <Column DBName="guid" Name="C260" Order="1" Type="DB"/>
      <Column DBName="nodename" Name="C263" Order="2" Type="DB"/>
    </DataSource>
      

    <Label Name="L255" Content="__('nodes'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L256" Content="__('address'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F258" DSColumn="C257" FlowOrder="0" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L259" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F261" DSColumn="C260" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L262" Content="__('nodename'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F264" DSColumn="C263" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    &NavigationButtons_Fields;
    &ActionButtons_Fields;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" MarginTop="10px"/>

  </Block>
</Form>
