<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://chick.zwisss.net/etc/form2.dtd"
[ <!ENTITY NavigationButtons_Fields SYSTEM "http://chick.local/etc/navigationbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://chick.local/etc/statusbar.xml">
]>
<Form Name="F23a">
  <General Name="General_515" StyleSheet="/etc/apiis.css" Description="Tier"/>

  <Block Name="Block_488" Description="Ladestrom - Tier" >
    <DataSource Name="DataSource_493" >
      <none/>
      <Parameter Name="Parameter1" Key="LO" Value="LO_DS05"/> 
    </DataSource>

    <Label Name="Label_490" Content="__('Ladestrom DS05'):">
      <Position Column="0" Columnspan="8" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    <Label Name="L695" Content="__('Animal'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="Fanimal_ext_unit" FlowOrder="1" >
      <DataSource Name="DataSource_101">
        <Sql Statement="select ext_code, ext_code from codes where class='ID_SET' and ext_code='wing_id_system' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_unit" />  
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Fanimal_ext_id" FlowOrder="2" Check="Notnull" >
      <DataSource Name="DataSource_1015aa">
        <Sql Statement="select distinct ext_id as nr from unit where ext_unit in (select  ext_code from codes where class='ID_SET') and ext_id not in ('ID') order by nr desc"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_id" StartCompareString="right" ReduceEntries="yes" />  
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="ext_animal" FlowOrder="3" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
   

    <Label Name="L343" Content="__('Sex'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="int_sex" FlowOrder="4" InternalData="yes">
      <DataSource Name="DS346">
        <Sql Statement="SELECT a.db_sex as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM animal AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_sex GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"  DefaultFunction="lastrecord" />
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L320" Content="__('Breed'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="int_breed" FlowOrder="5" InternalData="yes">
      <DataSource Name="DS323">
        <Sql Statement="SELECT a.db_breed as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM animal AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_breed GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"  DefaultFunction="lastrecord" />
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

<!-- 
    <Label Name="L312" Content="__('birth_dt'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="birth_dt" FlowOrder="6" >
      <TextField Override="no" Size="10"  MaxLength="10" InputType="date"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    
-->
    <Label Name="L325" Content="__('Cage'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="ext_cage" FlowOrder="7">
      <TextField Override="no" Size="10"  MaxLength="3"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Image Name="Image_" Alt="Test" Src="/icons/blank1.gif">
      <Position Column="0" Columnspan="6" Row="7"/>
      <Format PaddingTop="20px"/>
    </Image>
    
    &NavigationButtons_Fields;
    &StatusLine_Block;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>

  </Block>
</Form>
