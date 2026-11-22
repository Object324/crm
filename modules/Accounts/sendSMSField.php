<?php

global $current_user;
$languageType= getLanguageType($current_user);
$smarty=new lingdangCRM_Smarty();

$account_focus=CRMEntity::getInstance('Accounts');
$contact_focus=CRMEntity::getInstance('Contacts');
$users_focus=CRMEntity::getInstance('Users');//成员-销售负责人
$account_fieldobj=$account_focus->fieldobj;
$contact_fieldobj=$contact_focus->fieldobj;
$users_fieldobj=$users_focus->fieldobj;//成员-销售负责人

$account_SMS = array();
foreach ($account_fieldobj->getModuleFields() as $fieldinfo)
{
     
    if($fieldinfo->getUIType()!='1101')
    {
        continue;
    }
   
    if(in_array($fieldinfo->getTableName(),$contact_focus->tab_name))
    {
        continue;
    }
    $account_SMS[]=array(
    'tabid'=>6,
    'module'=>'Accounts',
    'fieldlabel'=>$fieldinfo->getFieldLabel(),
    'tablename'=>$fieldinfo->getTableName(),
    'fieldname'=>$fieldinfo->getFieldName(),
    'newchinesename'=>$fieldinfo->getFieldLabel()
    
    );
}
foreach ($contact_fieldobj->getModuleFields() as $fieldinfo)
{
    if($fieldinfo->getFieldDataType()!='mobile')
    {
        continue;
    }

    $account_SMS[]=array(
    'tabid'=>4,
    'module'=>'Contacts',
    'fieldlabel'=>$fieldinfo->getFieldLabel(),
    'tablename'=>$fieldinfo->getTableName(),
    'fieldname'=>$fieldinfo->getFieldName(),
    'newchinesename'=>$fieldinfo->getFieldLabel()
    
    );
}
//贵州阳光创信 发送短信给销售负责人 zxm 2021-0908  account="ygchuangxin";
$version = getVersionTradeInfo();
if($version['account']=="ygchuangxin") {
    foreach ($users_fieldobj->getModuleFields() as $fieldinfo) {
        if ($fieldinfo->getFieldDataType() != 'mobile') {
            continue;
        }
        $account_SMS[] = array(
            'tabid' => getTabid("Users"),
            'module' => 'Users',
            'fieldlabel' => $fieldinfo->getFieldLabel(),
            'tablename' => $fieldinfo->getTableName(),
            'fieldname' => $fieldinfo->getFieldName(),
            'newchinesename' => $fieldinfo->getFieldLabel()

        );
    }
}
$html_account_SMS = "";
for($i=0;$i<sizeof($account_SMS);$i++)
{
   // $account_SMS[$i]['fieldlabel']
    $smsmodule = $account_SMS[$i]['module'];
    $tabname=getTranstab($smsmodule);
    if($i==0)
    {
        $html_account_SMS .= "<tr>";
        $html_account_SMS .= "<td class='ld-form-item-content select-input padL0'>";
        $html_account_SMS .= "<input type='checkbox' id='".$i."_checkbox_sms' name='".$i."_checkbox_sms' checked='checked' onclick='isselect_checkboxsms()' value='$smsmodule#".$account_SMS[$i]['fieldname']."'/><label for='".$i."_checkbox_sms'>".$tabname.$account_SMS[$i]['fieldlabel']."</label>";
        $html_account_SMS .= "</td>";
        $html_account_SMS .= "</tr>";
    }
    else
    {
        $html_account_SMS .= "<tr>";
        $html_account_SMS .= "<td class='ld-form-item-content select-input padL0'>";
        $html_account_SMS .= "<input type='checkbox' id='".$i."_checkbox_sms' name='".$i."_checkbox_sms' onclick='isselect_checkboxsms()' value='$smsmodule#".$account_SMS[$i]['fieldname']."'/><label for='".$i."_checkbox_sms'>".$tabname.$account_SMS[$i]['fieldlabel']."</label>";
        $html_account_SMS .= "</td>";
        $html_account_SMS .= "</tr>";
    }
}
$smarty->assign('MODULE','Accounts');
//消息类型  SMS文字短信   SMS_VOICE语音电话
$smarty->assign('SMStype',$_REQUEST['SMStype']);
$smarty->assign("html_account_SMS",$html_account_SMS);
$smarty->assign("num_rows",sizeof($account_SMS));
$smarty->assign('ALLIDSINFO',$_REQUEST['allids']);
$_REQUEST['diony']='diony';
$SMStype = $_REQUEST['SMStype'];
if($SMStype=="SMS_VOICE"){
    $subtitle = getFixedLabel('PCWYWTSTMTMP_VOICE');
}else{
    $subtitle = getFixedLabel('PCWYWTSTMTMP');
}
$smarty->assign('subtitle',$subtitle);

$arr['title']=getFixedLabel('PLEASESELECTPHONE');
$arr['oktext'] = getFixedLabel('CONFIRME');
$arr['canceltext'] = getFixedLabel('CANCEL');
$str=$smarty->fetch("sendSMSField.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>