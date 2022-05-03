<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "form.dtd">
<Form Name="FORM_1418894848">
  <General Name="G747.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B748" Description="Update pt_cage">
     
    <DataSource Name="DS749" Connect="no">
      <Record TableName="pt_cage"/>
      <Column DBName="body_wt" Name="C729" Order="0" Type="DB"/>
      <Column DBName="db_cage" Name="C732" Order="1" Type="DB"/>
      <Column DBName="db_event" Name="C737" Order="4" Type="DB"/>
      <Column DBName="guid" Name="C742" Order="9" Type="DB"/>
      <Column DBName="hen_number" Name="C745" Order="10" Type="DB"/>
    </DataSource>
      

    <Label Name="L727" Content="__('pt_cage'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L728" Content="__('body_wt'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F730" DSColumn="C729" FlowOrder="0" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L731" Content="__('db_cage'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F735" DSColumn="C732" FlowOrder="1" InternalData="yes">
      <DataSource Name="DS734">
        <Sql Statement="SELECT a.db_cage as id,  CASE WHEN b.ext_unit::text isnull THEN 'unknown' ELSE b.ext_unit::text END   || ':::' ||   CASE WHEN b.ext_id::text isnull THEN 'unknown' ELSE b.ext_id::text END  as ext_trait FROM pt_cage AS a LEFT OUTER JOIN  unit AS b ON b.db_unit=a.db_cage GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L736" Content="__('db_event'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F740" DSColumn="C737" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS739">
        <Sql Statement="SELECT a.db_event as id,  CASE WHEN c.ext_code::text isnull THEN 'unknown' ELSE c.ext_code::text END   || ':::' ||   CASE WHEN b.event_dt::text isnull THEN 'unknown' ELSE b.event_dt::text END   || ':::' ||   CASE WHEN d.ext_unit::text isnull THEN 'unknown' ELSE d.ext_unit::text END   || ':::' ||   CASE WHEN d.ext_id::text isnull THEN 'unknown' ELSE d.ext_id::text END  as ext_trait FROM pt_cage AS a LEFT OUTER JOIN  event AS b ON b.db_event=a.db_event LEFT OUTER JOIN  codes AS c ON c.db_code=b.db_event_type LEFT OUTER JOIN  unit AS d ON d.db_unit=b.db_location GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L741" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F743" DSColumn="C742" FlowOrder="3" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L744" Content="__('hen_number'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F746" DSColumn="C745" FlowOrder="4" >
      <TextField Override="no" Size="255"/>
      <Position Column="1" Position="absolute" Row="5"/>
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
