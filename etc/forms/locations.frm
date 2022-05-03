<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://chick.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://chick.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://chick.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://chick.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://chick.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://chick.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://chick.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1571424431">
  <General Name="G224.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B225" Description="Update locations">
     
    <DataSource Name="DS226" Connect="no">
      <Record TableName="locations"/>
      <Column DBName="db_animal" Name="C196" Order="0" Type="DB"/>
      <Column DBName="db_entry_action" Name="C201" Order="4" Type="DB"/>
      <Column DBName="db_exit_action" Name="C206" Order="6" Type="DB"/>
      <Column DBName="db_location" Name="C211" Order="8" Type="DB"/>
      <Column DBName="entry_dt" Name="C216" Order="11" Type="DB"/>
      <Column DBName="exit_dt" Name="C219" Order="12" Type="DB"/>
      <Column DBName="guid" Name="C222" Order="13" Type="DB"/>
    </DataSource>
      

    <Label Name="L194" Content="__('locations'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L195" Content="__('db_animal'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F199" DSColumn="C196" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS198">
        <Sql Statement="SELECT a.db_animal as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM locations AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_animal LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L200" Content="__('db_entry_action'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F204" DSColumn="C201" FlowOrder="1" InternalData="yes">
      <DataSource Name="DS203">
        <Sql Statement="SELECT a.db_entry_action as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM locations AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_entry_action GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L205" Content="__('db_exit_action'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F209" DSColumn="C206" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS208">
        <Sql Statement="SELECT a.db_exit_action as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM locations AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_exit_action GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L210" Content="__('db_location'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F214" DSColumn="C211" FlowOrder="3" InternalData="yes">
      <DataSource Name="DS213">
        <Sql Statement="SELECT a.db_location as id,  CASE WHEN b.ext_unit::text isnull THEN 'unknown' ELSE b.ext_unit::text END   || ':::' ||   CASE WHEN b.ext_id::text isnull THEN 'unknown' ELSE b.ext_id::text END  as ext_trait FROM locations AS a LEFT OUTER JOIN  unit AS b ON b.db_unit=a.db_location GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L215" Content="__('entry_dt'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F217" DSColumn="C216" FlowOrder="4" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L218" Content="__('exit_dt'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F220" DSColumn="C219" FlowOrder="5" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L221" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F223" DSColumn="C222" FlowOrder="6" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="7"/>
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
