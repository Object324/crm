<?php

global $current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
$smarty=new lingdangCRM_Smarty();
$focus=CRMEntity::getInstance("Contacts");
$fieldobj=$focus->fieldobj;

foreach($fieldobj->getModuleFields() as $fieldname=>$fieldinfo)
{
     if($fieldinfo->getFieldDataType()=='mobile')
     {
        $contact_SMS[]=array(
        'tabid'=>4,
        'fieldlabel'=>$fieldinfo->getFieldLabel(),
        'tablename'=>$fieldinfo->getTableName(),
        'fieldname'=>$fieldinfo->getFieldName()
        
        );
     }
    
}
for($i=0;$i<sizeof($contact_SMS);$i++)
{
    if($i==0)
    {
        $html_contact_SMS .= "<tr>";
        $html_contact_SMS .= "<td>";
        $html_contact_SMS .= "<input type='checkbox' id='".$i."_checkbox_contact_sms' checked='checked' onclick='isselect_checkboxsms_contact();' value='".$contact_SMS[$i]['fieldname']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".getTranstab('Contacts').":&nbsp".$contact_SMS[$i]['fieldlabel']."";
        $html_contact_SMS .= "</td>";
        $html_contact_SMS .= "</tr>";
    }
    else
    {
        $html_contact_SMS .= "<tr>";
        $html_contact_SMS .= "<td>";
        $html_contact_SMS .= "<input type='checkbox' id='".$i."_checkbox_contact_sms' onclick='isselect_checkboxsms_contact();' value='".$contact_SMS[$i]['fieldname']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".getTranstab('Contacts').":&nbsp".$contact_SMS[$i]['fieldlabel']."";
        $html_contact_SMS .= "</td>";
        $html_contact_SMS .= "</tr>";
    }
}
$smarty->assign("html_contact_SMS",$html_contact_SMS);
$smarty->assign("num_rows",sizeof($contact_SMS));
$smarty->assign('ALLIDSINFO',$_REQUEST['allids']);
$smarty->assign('MODULE','Contacts');
$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel('PLEASESELECTPHONE');
$arr['oktext'] = getFixedLabel('CONFIRME');
$arr['canceltext'] = getFixedLabel('CANCEL');
$str=$smarty->fetch("sendSMSField.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>