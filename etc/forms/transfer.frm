<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://chick.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://chick.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://chick.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://chick.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://chick.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://chick.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://chick.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1571424431">
  <General Name="G191.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B192" Description="Update transfer">
     
    <DataSource Name="DS193" Connect="no">
      <Record TableName="transfer"/>
      <Column DBName="closing_dt" Name="C167" Order="0" Type="DB"/>
      <Column DBName="db_animal" Name="C170" Order="1" Type="DB"/>
      <Column DBName="db_unit" Name="C173" Order="2" Type="DB"/>
      <Column DBName="ext_animal" Name="C178" Order="5" Type="DB"/>
      <Column DBName="guid" Name="C181" Order="6" Type="DB"/>
      <Column DBName="id_set" Name="C184" Order="7" Type="DB"/>
      <Column DBName="opening_dt" Name="C189" Order="9" Type="DB"/>
    </DataSource>
      

    <Label Name="L165" Content="__('transfer'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L166" Content="__('closing_dt'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F168" DSColumn="C167" FlowOrder="0" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L169" Content="__('db_animal'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F171" DSColumn="C170" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L172" Content="__('db_unit'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F176" DSColumn="C173" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS175">
        <Sql Statement="SELECT a.db_unit as id,  CASE WHEN b.ext_unit::text isnull THEN 'unknown' ELSE b.ext_unit::text END   || ':::' ||   CASE WHEN b.ext_id::text isnull THEN 'unknown' ELSE b.ext_id::text END  as ext_trait FROM transfer AS a LEFT OUTER JOIN  unit AS b ON b.db_unit=a.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L177" Content="__('ext_animal'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F179" DSColumn="C178" FlowOrder="3" >
      <TextField Override="no" Size="30"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L180" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F182" DSColumn="C181" FlowOrder="4" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L183" Content="__('id_set'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F187" DSColumn="C184" FlowOrder="5" InternalData="yes">
      <DataSource Name="DS186">
        <Sql Statement="SELECT a.id_set as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM transfer AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.id_set GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L188" Content="__('opening_dt'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F190" DSColumn="C189" FlowOrder="6" >
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
