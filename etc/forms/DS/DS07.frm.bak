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
  <General Name="G177" StyleSheet="/etc/apiis.css" Description="__('DS07: Body weights')"/>

  <Block Name="DS071" Description="DS07: Body weights">
    <DataSource Name="DataSource_493"  Connect="no">
        <none/>
        <Parameter Name="Parameter1" Key="LO" Value="LO_DS07"/>
    </DataSource>
		    
    <Label Name="DS072" Content="__('DS07: Body  weights')">
      <Position Column="0" Columnspan="5" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    <Label Name="DS073" Content="__('Event')">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>
    

 <Field Name="db_event" FlowOrder="2" Check="NotNull" InternalData="yes" >
      <DataSource Name="DataSource_456">
	<Sql Statement="select db_event, event_dt || ':::' || ext_code from event a inner join codes b on a.db_event_type=b.db_code where b.ext_code='event_weighing_body' order by event_dt desc limit 2; "/>
      </DataSource>
      <ScrollingList Size="1" ReduceEntries="yes" />  
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="DS074" Content="__('Cage')">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>
 <Field Name="db_cage" FlowOrder="2" Check="NotNull" InternalData="yes" >
      <DataSource Name="DataSource_567">
	<Sql Statement="select distinct ext_id from unit where ext_unit='cage' order by ext_id ; "/>
      </DataSource>
      <ScrollingList Size="1" ReduceEntries="yes" />  
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

<!--
    <Field Name="ext_id_cage" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="5"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
-->   
    <Label Name="DS075" Content="__('Weight rooster')">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>
    <Field Name="body_wt_ptindiv" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="2" MaxLength="8"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="DS076" Content="__('Weight hen 1')">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>
    <Field Name="body_wt1" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="2" MaxLength="8"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="DS077" Content="__('Weight hen 2')">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>
    <Field Name="body_wt2" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="2" MaxLength="8"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="DS078" Content="__('Weight hen 3')">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>
    <Field Name="body_wt3" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="2" MaxLength="8"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="DS079" Content="__('Weight hen 4')">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>
    <Field Name="body_wt4" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="2" MaxLength="8"/>
      <Position Column="1" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="DS0710" Content="__('Weight hen 5')">
      <Position Column="0" Position="absolute" Row="9"/>
    </Label>
    <Field Name="body_wt5" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="2" MaxLength="8"/>
      <Position Column="1" Position="absolute" Row="9"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="DS0711" Content="__('Weight hen 6')">
      <Position Column="0" Position="absolute" Row="10"/>
    </Label>
    <Field Name="body_wt6" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="2" MaxLength="8"/>
      <Position Column="1" Position="absolute" Row="10"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="DS0712" Content="__('Weight hen 7')">
      <Position Column="0" Position="absolute" Row="11"/>
    </Label>
    <Field Name="body_wt7" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="2" MaxLength="8"/>
      <Position Column="1" Position="absolute" Row="11"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="DS0713" Content="__('Weight hen 8')">
      <Position Column="0" Position="absolute" Row="12"/>
    </Label>
    <Field Name="body_wt8" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="2" MaxLength="8"/>
      <Position Column="1" Position="absolute" Row="12"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="DS0714" Content="__('Weight hen 9')">
      <Position Column="0" Position="absolute" Row="13"/>
    </Label>
    <Field Name="body_wt9" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="2" MaxLength="8"/>
      <Position Column="1" Position="absolute" Row="13"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="DS0715" Content="__('Weight hen 10')">
      <Position Column="0" Position="absolute" Row="14"/>
    </Label>
    <Field Name="body_wt10" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="2" MaxLength="8"/>
      <Position Column="1" Position="absolute" Row="14"/>
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
