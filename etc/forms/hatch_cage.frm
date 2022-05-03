<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "form.dtd">
<Form Name="FORM_1418894848">
  <General Name="G861.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B862" Description="Update hatch_cage">
     
    <DataSource Name="DS863" Connect="no">
      <Record TableName="hatch_cage"/>
      <Column DBName="db_cage" Name="C840" Order="0" Type="DB"/>
      <Column DBName="db_event" Name="C845" Order="3" Type="DB"/>
      <Column DBName="guid" Name="C850" Order="8" Type="DB"/>
      <Column DBName="collected_eggs" Name="C853" Order="9" Type="DB"/>
      <Column DBName="hatched_eggs" Name="C856" Order="10" Type="DB"/>
      <Column DBName="incubated_eggs" Name="C859" Order="11" Type="DB"/>
    </DataSource>
      

    <Label Name="L838" Content="__('hatch_cage'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L839" Content="__('db_cage'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F843" DSColumn="C840" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS842">
        <Sql Statement="SELECT a.db_cage as id,  CASE WHEN b.ext_unit::text isnull THEN 'unknown' ELSE b.ext_unit::text END   || ':::' ||   CASE WHEN b.ext_id::text isnull THEN 'unknown' ELSE b.ext_id::text END  as ext_trait FROM hatch_cage AS a LEFT OUTER JOIN  unit AS b ON b.db_unit=a.db_cage GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L844" Content="__('db_event'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F848" DSColumn="C845" FlowOrder="1" InternalData="yes">
      <DataSource Name="DS847">
        <Sql Statement="SELECT a.db_event as id,  CASE WHEN c.ext_code::text isnull THEN 'unknown' ELSE c.ext_code::text END   || ':::' ||   CASE WHEN b.event_dt::text isnull THEN 'unknown' ELSE b.event_dt::text END   || ':::' ||   CASE WHEN d.ext_unit::text isnull THEN 'unknown' ELSE d.ext_unit::text END   || ':::' ||   CASE WHEN d.ext_id::text isnull THEN 'unknown' ELSE d.ext_id::text END  as ext_trait FROM hatch_cage AS a LEFT OUTER JOIN  event AS b ON b.db_event=a.db_event LEFT OUTER JOIN  codes AS c ON c.db_code=b.db_event_type LEFT OUTER JOIN  unit AS d ON d.db_unit=b.db_location GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L849" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F851" DSColumn="C850" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L852" Content="__('collected_eggs'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F854" DSColumn="C853" FlowOrder="3" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L855" Content="__('hatched_eggs'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F857" DSColumn="C856" FlowOrder="4" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L858" Content="__('incubated_eggs'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F860" DSColumn="C859" FlowOrder="5" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="6"/>
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
