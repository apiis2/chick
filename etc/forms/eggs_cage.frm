<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://chick.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://chick.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://chick.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://chick.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://chick.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://chick.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://chick.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1461240601">
  <General Name="G561.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B562" Description="Update eggs_cage">
     
    <DataSource Name="DS563" Connect="no">
      <Record TableName="eggs_cage"/>
      <Column DBName="db_cage" Name="C540" Order="1" Type="DB"/>
      <Column DBName="db_event" Name="C545" Order="4" Type="DB"/>
      <Column DBName="guid" Name="C550" Order="9" Type="DB"/>
      <Column DBName="n_eggs" Name="C553" Order="10" Type="DB"/>
      <Column DBName="number_hens" Name="C556" Order="11" Type="DB"/>
      <Column DBName="total_weight_eggs" Name="C559" Order="12" Type="DB"/>
    </DataSource>
      

    <Label Name="L535" Content="__('eggs_cage'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L539" Content="__('db_cage'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F543" DSColumn="C540" FlowOrder="1" InternalData="yes">
      <DataSource Name="DS542">
        <Sql Statement="SELECT a.db_cage as id,  CASE WHEN b.ext_unit::text isnull THEN 'unknown' ELSE b.ext_unit::text END   || ':::' ||   CASE WHEN b.ext_id::text isnull THEN 'unknown' ELSE b.ext_id::text END  as ext_trait FROM eggs_cage AS a LEFT OUTER JOIN  unit AS b ON b.db_unit=a.db_cage GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L544" Content="__('db_event'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F548" DSColumn="C545" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS547">
        <Sql Statement="SELECT a.db_event as id,  CASE WHEN c.ext_code::text isnull THEN 'unknown' ELSE c.ext_code::text END   || ':::' ||   CASE WHEN b.event_dt::text isnull THEN 'unknown' ELSE b.event_dt::text END   || ':::' ||   CASE WHEN d.ext_unit::text isnull THEN 'unknown' ELSE d.ext_unit::text END   || ':::' ||   CASE WHEN d.ext_id::text isnull THEN 'unknown' ELSE d.ext_id::text END  as ext_trait FROM eggs_cage AS a LEFT OUTER JOIN  event AS b ON b.db_event=a.db_event LEFT OUTER JOIN  codes AS c ON c.db_code=b.db_event_type LEFT OUTER JOIN  unit AS d ON d.db_unit=b.db_location GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L549" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F551" DSColumn="C550" FlowOrder="3" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L552" Content="__('n_eggs'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F554" DSColumn="C553" FlowOrder="4" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L555" Content="__('number_hens'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F557" DSColumn="C556" FlowOrder="5" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L558" Content="__('total_weight_eggs'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F560" DSColumn="C559" FlowOrder="6" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="7"/>
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
