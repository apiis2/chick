<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://chick.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://chick.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://chick.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://chick.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://chick.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://chick.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://chick.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1461240601">
  <General Name="G470.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B471" Description="Update pt_indiv">
     
    <DataSource Name="DS472" Connect="no">
      <Record TableName="pt_indiv"/>
      <Column DBName="body_wt" Name="C450" Order="1" Type="DB"/>
      <Column DBName="db_animal" Name="C453" Order="2" Type="DB"/>
      <Column DBName="db_cage" Name="C458" Order="6" Type="DB"/>
      <Column DBName="db_event" Name="C463" Order="9" Type="DB"/>
      <Column DBName="guid" Name="C468" Order="14" Type="DB"/>
    </DataSource>
      

    <Label Name="L445" Content="__('pt_indiv'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L449" Content="__('body_wt'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F451" DSColumn="C450" FlowOrder="1" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L452" Content="__('db_animal'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F456" DSColumn="C453" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS455">
        <Sql Statement="SELECT a.db_animal as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM pt_indiv AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_animal LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L457" Content="__('db_cage'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F461" DSColumn="C458" FlowOrder="3" InternalData="yes">
      <DataSource Name="DS460">
        <Sql Statement="SELECT a.db_cage as id,  CASE WHEN b.ext_unit::text isnull THEN 'unknown' ELSE b.ext_unit::text END   || ':::' ||   CASE WHEN b.ext_id::text isnull THEN 'unknown' ELSE b.ext_id::text END  as ext_trait FROM pt_indiv AS a LEFT OUTER JOIN  unit AS b ON b.db_unit=a.db_cage GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L462" Content="__('db_event'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F466" DSColumn="C463" FlowOrder="4" InternalData="yes">
      <DataSource Name="DS465">
        <Sql Statement="SELECT a.db_event as id,  CASE WHEN c.ext_code::text isnull THEN 'unknown' ELSE c.ext_code::text END   || ':::' ||   CASE WHEN b.event_dt::text isnull THEN 'unknown' ELSE b.event_dt::text END   || ':::' ||   CASE WHEN d.ext_unit::text isnull THEN 'unknown' ELSE d.ext_unit::text END   || ':::' ||   CASE WHEN d.ext_id::text isnull THEN 'unknown' ELSE d.ext_id::text END  as ext_trait FROM pt_indiv AS a LEFT OUTER JOIN  event AS b ON b.db_event=a.db_event LEFT OUTER JOIN  codes AS c ON c.db_code=b.db_event_type LEFT OUTER JOIN  unit AS d ON d.db_unit=b.db_location GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L467" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F469" DSColumn="C468" FlowOrder="5" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>

    &NavigationButtons_Fields;
    &ActionButtons_Fields;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" MarginTop="10px"/>

  </Block>
</Form>
