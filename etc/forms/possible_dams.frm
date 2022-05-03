<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://chick.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://chick.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://chick.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://chick.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://chick.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://chick.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://chick.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1571424431">
  <General Name="G327.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B328" Description="Update possible_dams">
     
    <DataSource Name="DS329" Connect="no">
      <Record TableName="possible_dams"/>
      <Column DBName="db_animal" Name="C270" Order="0" Type="DB"/>
      <Column DBName="db_dam1" Name="C275" Order="4" Type="DB"/>
      <Column DBName="db_dam10" Name="C280" Order="8" Type="DB"/>
      <Column DBName="db_dam2" Name="C285" Order="12" Type="DB"/>
      <Column DBName="db_dam3" Name="C290" Order="16" Type="DB"/>
      <Column DBName="db_dam4" Name="C295" Order="20" Type="DB"/>
      <Column DBName="db_dam5" Name="C300" Order="24" Type="DB"/>
      <Column DBName="db_dam6" Name="C305" Order="28" Type="DB"/>
      <Column DBName="db_dam7" Name="C310" Order="32" Type="DB"/>
      <Column DBName="db_dam8" Name="C315" Order="36" Type="DB"/>
      <Column DBName="db_dam9" Name="C320" Order="40" Type="DB"/>
      <Column DBName="guid" Name="C325" Order="44" Type="DB"/>
    </DataSource>
      

    <Label Name="L268" Content="__('possible_dams'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L269" Content="__('db_animal'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F273" DSColumn="C270" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS272">
        <Sql Statement="SELECT a.db_animal as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM possible_dams AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_animal LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L274" Content="__('db_dam1'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F278" DSColumn="C275" FlowOrder="1" InternalData="yes">
      <DataSource Name="DS277">
        <Sql Statement="SELECT a.db_dam1 as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM possible_dams AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_dam1 LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L279" Content="__('db_dam10'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F283" DSColumn="C280" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS282">
        <Sql Statement="SELECT a.db_dam10 as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM possible_dams AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_dam10 LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L284" Content="__('db_dam2'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F288" DSColumn="C285" FlowOrder="3" InternalData="yes">
      <DataSource Name="DS287">
        <Sql Statement="SELECT a.db_dam2 as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM possible_dams AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_dam2 LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L289" Content="__('db_dam3'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F293" DSColumn="C290" FlowOrder="4" InternalData="yes">
      <DataSource Name="DS292">
        <Sql Statement="SELECT a.db_dam3 as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM possible_dams AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_dam3 LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L294" Content="__('db_dam4'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F298" DSColumn="C295" FlowOrder="5" InternalData="yes">
      <DataSource Name="DS297">
        <Sql Statement="SELECT a.db_dam4 as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM possible_dams AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_dam4 LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L299" Content="__('db_dam5'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F303" DSColumn="C300" FlowOrder="6" InternalData="yes">
      <DataSource Name="DS302">
        <Sql Statement="SELECT a.db_dam5 as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM possible_dams AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_dam5 LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L304" Content="__('db_dam6'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F308" DSColumn="C305" FlowOrder="7" InternalData="yes">
      <DataSource Name="DS307">
        <Sql Statement="SELECT a.db_dam6 as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM possible_dams AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_dam6 LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L309" Content="__('db_dam7'): ">
      <Position Column="0" Position="absolute" Row="9"/>
    </Label>

    <Field Name="F313" DSColumn="C310" FlowOrder="8" InternalData="yes">
      <DataSource Name="DS312">
        <Sql Statement="SELECT a.db_dam7 as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM possible_dams AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_dam7 LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="9"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L314" Content="__('db_dam8'): ">
      <Position Column="0" Position="absolute" Row="10"/>
    </Label>

    <Field Name="F318" DSColumn="C315" FlowOrder="9" InternalData="yes">
      <DataSource Name="DS317">
        <Sql Statement="SELECT a.db_dam8 as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM possible_dams AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_dam8 LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="10"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L319" Content="__('db_dam9'): ">
      <Position Column="0" Position="absolute" Row="11"/>
    </Label>

    <Field Name="F323" DSColumn="C320" FlowOrder="10" InternalData="yes">
      <DataSource Name="DS322">
        <Sql Statement="SELECT a.db_dam9 as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM possible_dams AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_dam9 LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="11"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L324" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="12"/>
    </Label>

    <Field Name="F326" DSColumn="C325" FlowOrder="11" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="12"/>
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
