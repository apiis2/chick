<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "form2.dtd"
[ <!ENTITY NavigationButtons_Fields SYSTEM "/home/zwisss/database_stuff/apiis/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "/home/zwisss/database_stuff/apiis/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "/home/zwisss/database_stuff/apiis/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "/home/zwisss/database_stuff/apiis/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "/home/zwisss/database_stuff/apiis/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "/home/zwisss/database_stuff/apiis/etc/callform_button_block.xml">
]>
<Form Name="FORM_1461240601">
  <General Name="G368.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B369" Description="Update animal">
     
    <DataSource Name="DS370" Connect="no">
      <Record TableName="animal"/>
      <Column DBName="db_animal" Name="C316" Order="0" Type="DB">
          <IdSet Name="idset_Column_1"  SetName="wing_id_system"/>
      </Column> 
      <Column DBName="ext_unit" Name="C86" Order="0" RelatedColumn="C316" RelatedOrder="0" Type="Related"/>
      <Column DBName="ext_unit" Name="C88" Order="1" RelatedColumn="C316" RelatedOrder="1" Type="Related"/>
      <Column DBName="ext_animal" Name="C90" Order="2" RelatedColumn="C316" RelatedOrder="2" Type="Related"/>

      <Column DBName="db_breed" Name="C321" Order="4" Type="DB"/>
      <Column DBName="db_cage" Name="C326" Order="5" Type="DB"/>
      
      <Column DBName="db_dam" Name="C331" Order="6" Type="DB">
          <IdSet Name="idset_Column_2"  SetName="wing_id_system"/>
      </Column> 
      <Column DBName="ext_unit" Name="C91" Order="7" RelatedColumn="C331" RelatedOrder="0" Type="Related"/>
      <Column DBName="ext_id" Name="C92" Order="8" RelatedColumn="C331" RelatedOrder="1" Type="Related"/>
      <Column DBName="ext_animal" Name="C93" Order="9" RelatedColumn="C331" RelatedOrder="2" Type="Related"/>
      
      <Column DBName="db_exit" Name="C336" Order="10" Type="DB"/>
      <Column DBName="db_sex" Name="C344" Order="12" Type="DB"/>
      <Column DBName="birth_dt" Name="C313" Order="13" Type="DB"/>

      <Column DBName="db_sire" Name="C349" Order="14" Type="DB">
          <IdSet Name="idset_Column_3"  SetName="wing_id_system"/>
      </Column> 
      <Column DBName="ext_unit" Name="C94" Order="15" RelatedColumn="C349" RelatedOrder="0" Type="Related"/>
      <Column DBName="ext_id" Name="C95" Order="16" RelatedColumn="C349" RelatedOrder="1" Type="Related"/>
      <Column DBName="ext_animal" Name="C96" Order="17" RelatedColumn="C349" RelatedOrder="2" Type="Related"/>
      
      <Column DBName="exit_dt" Name="C354" Order="18" Type="DB"/>
      <Column DBName="guid" Name="C357" Order="19" Type="DB"/>
    </DataSource>
      

    <Label Name="L311" Content="__('Animal'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>


    <Label Name="L695" Content="__('Animal'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F699" DSColumn="C316" >
      <TextField Override="no" Size="20"/>
      <Position Column="0" Position="absolute" Row="2"/>
      <Miscellaneous Visibility="hidden" Enabled="no"/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    
    <Field Name="Fanimal_ext_unit" DSColumn="C86" FlowOrder="1" >
      <DataSource Name="DataSource_101">
        <Sql Statement="select ext_code, ext_code from codes where class='ID_SET' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_unit" />  
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Fanimal_ext_id" DSColumn="C88" FlowOrder="2" Check="Notnull" >
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
    <Field Name="Fanimal_ext_animal" DSColumn="C90" FlowOrder="3" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    

    <Label Name="L695a" Content="__('Sire'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F699a" DSColumn="C349" >
      <TextField Override="no" Size="20"/>
      <Position Column="0" Position="absolute" Row="3"/>
      <Miscellaneous Visibility="hidden" Enabled="no"/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Fsire_ext_unit" DSColumn="C94" FlowOrder="4" >
      <DataSource Name="DataSource_101sire">
        <Sql Statement="select ext_code, ext_code from codes where class='ID_SET' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_unit" />  
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Fsire_ext_id" DSColumn="C95" FlowOrder="5" >
      <DataSource Name="DataSource_1015aasire">
        <Sql Statement="select distinct ext_id, ext_id from unit where ext_unit in (select  ext_code from codes where class='ID_SET') order by ext_id"/>
      </DataSource>
      <ScrollingList Size="1" StartCompareString="right" ReduceEntries="yes" />  
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Fsire_ext_animal" DSColumn="C96" FlowOrder="6" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    

    <Label Name="L695b" Content="__('Dam'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F699b" DSColumn="C331" >
      <TextField Override="no" Size="20"/>
      <Position Column="0" Position="absolute" Row="4"/>
      <Miscellaneous Visibility="hidden" Enabled="no"/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Fdam_ext_unit" DSColumn="C91" FlowOrder="7" >
      <DataSource Name="DataSource_101dam">
        <Sql Statement="select ext_code, ext_code from codes where class='ID_SET' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_unit" />  
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Fdam_ext_id" DSColumn="C92" FlowOrder="8" >
      <DataSource Name="DataSource_1015aadam">
        <Sql Statement="select distinct ext_id, ext_id from unit where ext_unit in (select  ext_code from codes where class='ID_SET') order by ext_id"/>
      </DataSource>
      <ScrollingList Size="1" StartCompareString="right" ReduceEntries="yes" />  
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    
    
    
    <Field Name="Fdam_ext_animal" DSColumn="C93" FlowOrder="9" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    
    <Label Name="L343" Content="__('Sex'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F347" DSColumn="C344" FlowOrder="10" InternalData="yes">
      <DataSource Name="DS346">
        <Sql Statement="SELECT a.db_sex as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM animal AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_sex GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L320" Content="__('Breed'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F324" DSColumn="C321" FlowOrder="11" InternalData="yes">
      <DataSource Name="DS323">
        <Sql Statement="SELECT a.db_breed as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM animal AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_breed GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L325" Content="__('Cage'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F329" DSColumn="C326" FlowOrder="12" InternalData="yes">
      <DataSource Name="DS328">
        <Sql Statement="SELECT a.db_cage as id,  user_get_ext_id(a.db_cage) from v_active_animals_and_cages a order by user_get_ext_id(a.db_cage) "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L312" Content="__('Birthdate'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F314" DSColumn="C313" FlowOrder="13" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

<!--
    <Label Name="L338" Content="__('db_selection'): ">
      <Position Column="0" Position="absolute" Row="9"/>
    </Label>

    <Field Name="F342" DSColumn="C339" FlowOrder="14" InternalData="yes">
      <DataSource Name="DS341">
        <Sql Statement="SELECT a.db_selection as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM animal AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_selection GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="9"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
-->

    <Label Name="L353" Content="__('Exit-Date'): ">
      <Position Column="0" Position="absolute" Row="10"/>
    </Label>

    <Field Name="F355" DSColumn="C354" FlowOrder="15" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="10"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L335" Content="__('Exit Reason'): ">
      <Position Column="0" Position="absolute" Row="11"/>
    </Label>

    <Field Name="F337" DSColumn="C336" FlowOrder="16"  InternalData="yes">
      <DataSource Name="DS328exit">
        <Sql Statement="SELECT db_code as id,  short_name from codes where class='EXIT_REASON'"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="11"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L356" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="13"/>
    </Label>

    <Field Name="F358" DSColumn="C357" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="13"/>
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
