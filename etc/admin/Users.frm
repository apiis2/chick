<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://chick.zwisss.net/etc/form2.dtd"
[  <!ENTITY NavigationButtons_Fields SYSTEM "http://chick.zwisss.net/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://chick.zwisss.net/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://chick.zwisss.net/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://chick.zwisss.net/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://chick.zwisss.net/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://chick.zwisss.net/etc/callform_button_block.xml">
]>
<Form Name="Users">
  <General Name="Users_General" StyleSheet="/etc/apiis.css" Description="Create/Update Users"/>

  <Block Name="Users_B1" >
    <DataSource Name="Users_DS_1" >
      <Record TableName="ar_users"/>
      <Column DBName="user_login"       Name="C1203" Order="1" Type="DB"/>
      <Column DBName="user_marker"      Name="C1229" Order="2" Type="DB"/>
      <Column DBName="user_language_id" Name="C1230" Order="3" Type="DB"/>
<!--
      <Column DBName="user_disabled"    Name="C1231" Order="4" Type="DB"/>
      <Column DBName="user_status"      Name="C1232" Order="5" Type="DB"/>
-->
      <Column DBName="guid"             Name="C1244" Order="6" Type="DB"/>
    </DataSource>

    <Label Name="Users_L1" Content="__('Users')">
      <Position Column="0" Columnspan="3" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    
    <Label Name="Users_L2" Content="__('Login-Name'):">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>
    <Field Name="login" DSColumn="C1203" FlowOrder="1"  Check="NotNull">
      <DataSource Name="Users_DS_2">
       <Sql Statement="SELECT user_login,user_login FROM ar_users"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" Default="no" />  
      <Position Column="0" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>    
    </Field>
    
    <Label Name="Users_L3" Content="__('User-Marker'):">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>
    <Field Name="user_marker" DSColumn="C1229" FlowOrder="2" Check="NotNull">
      <TextField Override="no" Size="15"/>
      <Position Column="0" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    
    <Label Name="Users_L5" Content="__('Language'):">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>
    <Field Name="language" DSColumn="C1230" FlowOrder="5" Check="NotNull" InternalData="yes">
      <DataSource Name="Users_DS_4">
       <Sql Statement="SELECT lang_id, iso_lang FROM languages where iso_lang in ('en', 'de', 'no')"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" Default="no" />  
      <Position Column="0" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>    
    </Field>
   
<!--
    <Label Name="Users_L6" Content="__('User disabled'):">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>
    <Field Name="user_disabled" DSColumn="C1231" FlowOrder="5" Check="NotNull">
      <DataSource Name="Users_DS_6">
       <Sql Statement="SELECT true,'true' union select false, 'false'"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" Default="false" />  
      <Position Column="0" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>    
    </Field>

    <Label Name="Users_L7" Content="__('User Status'):">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>
    <Field Name="user_status" DSColumn="C1232" FlowOrder="5" Check="NotNull" >
      <DataSource Name="Users_DS_7">
       <Sql Statement="SELECT true,'true' union select false, 'false'"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" Default="false" />  
      <Position Column="0" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>    
    </Field>
-->

    <Label Name="L1243" Content="__('Internal ID')">
      <Position Column="0" Position="absolute" Row="14"/>
      <Format  PaddingBottom="10px"/>
    </Label>

    <Field Name="F1245" DSColumn="C1244" FlowOrder="4" >
      <TextField Override="no" Size="8"/>
      <Position Column="1" Position="absolute" Row="14"/>
      <Miscellaneous Enabled="no"/>
      <Text />
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"  PaddingBottom="10px"/>
    </Field>
    
    <Image Name="Users_I1" Alt="Test" Src="/icons/blank1.gif">
      <Position Column="0" Columnspan="1" Row="9"/>
      <Format PaddingTop="20px"/>
    </Image>
    
    &NavigationButtons_Fields;
    &ActionButtons_Fields;
    &StatusLine_Block;
    
    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>
  </Block>
</Form>
