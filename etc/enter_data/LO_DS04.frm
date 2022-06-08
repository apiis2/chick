<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://chick.local/etc/form2.dtd"
[  <!ENTITY NavigationButtons_Fields SYSTEM "http://chick.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://chick.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://chick.local/etc/statusbar.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://chick.local/etc/statusbar.xml">
]>
<Form Name="FORM_1418894848">
  <General Name="G861.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B862" Description="Update DS020304">
     
    <DataSource Name="DS863" Connect="no">
      <none/>
      <Parameter Name="Parameter1" Key="LO" Value="LO_DS020304"/>
    </DataSource>
      

    <Label Name="Label_490" Content="__('Loadingstream DS020304'):">
      <Position Column="0" Columnspan="8" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>


    <Label Name="L839" Content="__('Breed'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="ext_breed" FlowOrder="0">
      <DataSource Name="DataSource_101">
        <Sql Statement="select ext_code, ext_code from codes where class='BREED'  order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" />  
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L849" Content="__('Far nummer'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="far" FlowOrder="1" >
      <TextField Override="no" Size="2"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color />
      <Format/>
    </Field>

    <Label Name="L839a" Content="__('Cage'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>
    <Field Name="cage" FlowOrder="2">
      <TextField Override="no" Size="3"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L844" Content="__('Collect date'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>
    <Field Name="event_dt" FlowOrder="3" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L852" Content="__('collected_eggs'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>
    <Field Name="collected_eggs" DSColumn="C853" FlowOrder="3" >
      <TextField Override="no" Size="2"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L855" Content="__('incubated_eggs'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>
    <Field Name="incubated_eggs" DSColumn="C856" FlowOrder="5" >
      <TextField Override="no" Size="2"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L858" Content="__('hatched_eggs'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>
    <Field Name="hatched_eggs" DSColumn="C859" FlowOrder="6" >
      <TextField Override="no" Size="2"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L844a" Content="__('Hatch date'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>
    <Field Name="hatch_dt" FlowOrder="7" >
      <TextField Override="no" Size="10"/>
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
