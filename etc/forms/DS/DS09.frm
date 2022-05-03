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
  <General Name="DS091" StyleSheet="/etc/apiis.css" Description="__('DS09: Sold or dead individuals')"/>

  <Block Name="DS092" Description="DS09: Sold or dead individuals">
    <DataSource Name="DataSource_493"  Connect="no">
        <none/>
        <Parameter Name="Parameter1" Key="LO" Value="DS01"/>
    </DataSource>
		    
    <Label Name="DS093" Content="__('DS08: Sold or dead individuals')">
      <Position Column="0" Columnspan="5" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    <Label Name="DS094" Content="__('Date')">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>
    <Field Name="date" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    
    <Label Name="DS095" Content="__('Wingnumber')">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>
    <Field Name="Wingnumber" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="5"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="DS096" Content="__('Reason')">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>
    
 <Field Name="db_event" FlowOrder="2" Check="NotNull" InternalData="yes" >
      <DataSource Name="DataSource_123">
	<Sql Statement=" "/>
      </DataSource>
      <ScrollingList Size="1" ReduceEntries="yes" />  
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

<!--   
    <Label Name="L6956" Content="__('Reason')">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>
    <Field Name="reason" FlowOrder="1" Check="NotNull" >
      <TextField Override="no" Size="2" MaxLength="2"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

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
