<?php

global $current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
$smarty=new lingdangCRM_Smarty();

$account_focus=CRMEntity::getInstance('ServiceCharge');
$contact_focus=CRMEntity::getInstance('Contacts');
$account_fieldobj=$account_focus->fieldobj;
$contact_fieldobj=$contact_focus->fieldobj;

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

$html_account_SMS = "";

for($i=0;$i<sizeof($account_SMS);$i++)
{
   // $account_SMS[$i]['fieldlabel']
    $smsmodule = $account_SMS[$i]['module'];
    $tabname=getTranstab($smsmodule);
    if($smsmodule=='Accounts')
    {
        $smsmodule='ServiceCharge';
    }
    if($i==0)
    {
        $html_account_SMS .= "<tr>";
        $html_account_SMS .= "<td>";
        $html_account_SMS .= "<input type='checkbox' id='".$i."_checkbox_sms' name='".$i."_checkbox_sms' checked='checked' onclick='isselect_checkboxsms()' value='$smsmodule#".$account_SMS[$i]['fieldname']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$tabname.":&nbsp".$account_SMS[$i]['fieldlabel']."";
        $html_account_SMS .= "</td>";
        $html_account_SMS .= "</tr>";
    }
    else
    {
        $html_account_SMS .= "<tr>";
        $html_account_SMS .= "<td>";
        $html_account_SMS .= "<input type='checkbox' id='".$i."_checkbox_sms' name='".$i."_checkbox_sms' onclick='isselect_checkboxsms()' value='$smsmodule#".$account_SMS[$i]['fieldname']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$tabname.":&nbsp".$account_SMS[$i]['fieldlabel']."";
        $html_account_SMS .= "</td>";
        $html_account_SMS .= "</tr>";
    }
}
$smarty->assign('MODULE','ServiceCharge');
$smarty->assign("html_account_SMS",$html_account_SMS);
$smarty->assign("num_rows",sizeof($account_SMS));
$smarty->assign('ALLIDSINFO',$_REQUEST['allids']);
$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel('PLEASESELECTPHONE');
$arr['oktext'] = getFixedLabel('CONFIRME');
$arr['canceltext'] = getFixedLabel('CANCEL');
$str=$smarty->fetch("sendSMSField.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>