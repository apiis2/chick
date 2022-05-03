<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://chick.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://chick.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://chick.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://chick.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://chick.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://chick.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://chick.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1571424431">
  <General Name="G252.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B253" Description="Update languages">
     
    <DataSource Name="DS254" Connect="no">
      <Record TableName="languages"/>
      <Column DBName="creation_dt" Name="C229" Order="0" Type="DB"/>
      <Column DBName="creation_user" Name="C232" Order="1" Type="DB"/>
      <Column DBName="end_dt" Name="C235" Order="2" Type="DB"/>
      <Column DBName="end_user" Name="C238" Order="3" Type="DB"/>
      <Column DBName="guid" Name="C241" Order="4" Type="DB"/>
      <Column DBName="iso_lang" Name="C244" Order="5" Type="DB"/>
      <Column DBName="lang" Name="C247" Order="6" Type="DB"/>
      <Column DBName="lang_id" Name="C250" Order="7" Type="DB"/>
    </DataSource>
      

    <Label Name="L227" Content="__('languages'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L228" Content="__('creation_dt'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F230" DSColumn="C229" FlowOrder="0" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L231" Content="__('creation_user'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F233" DSColumn="C232" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L234" Content="__('end_dt'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F236" DSColumn="C235" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L237" Content="__('end_user'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F239" DSColumn="C238" FlowOrder="3" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L240" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F242" DSColumn="C241" FlowOrder="4" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L243" Content="__('iso_lang'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F245" DSColumn="C244" FlowOrder="5" >
      <TextField Override="no" Size="2"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L246" Content="__('lang'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F248" DSColumn="C247" FlowOrder="6" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L249" Content="__('lang_id'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F251" DSColumn="C250" FlowOrder="7" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="8"/>
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
