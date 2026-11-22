<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/
if(isset($_REQUEST['fromModule']))
{
    $fromModule=$_REQUEST['fromModule'];
}
global $current_user;
$languageType= getLanguageType($current_user);
$focus=CRMEntity::getInstance('ServiceCharge');
$fieldobj=$focus->fieldobj;


$accounttype_SMS = array();
foreach($fieldobj->getModuleFields() as $fieldname=>$fieldinfo)
{
     if($fieldinfo->getFieldDataType()!='mobile')
     {
         continue;
     }
    $tabid=102;
     if(!in_array($fieldinfo->getTableName(),$focus->tab_name))
     {
        $tabid=4;
     }
    $accounttype_SMS[]=array(
    'tabid'=>$tabid,
    'fieldlabel'=>$fieldinfo->getFieldLabel(),
    'tablename'=>$fieldinfo->getTableName(),
    'fieldname'=>$fieldinfo->getFieldName()
    //'newchinesename'=>$adb->query_result($accounttype_SMS_result,$i,'newchinesename')
    
    );
}
$html_contact_SMS = "";
for($i=0;$i<sizeof($accounttype_SMS);$i++)
{
    $smstabid = $accounttype_SMS[$i]['tabid'];
    if($smstabid==102)
    {
        $tabname = getTranstab('ServiceCharge');
        $smsmodule="ServiceCharge";
    }
    else
    {
        $tabname = getTranstab('Contacts');
        $smsmodule="Contacts";
    }
    if($i==0)
    {
        $html_contact_SMS .= "<tr>";
        $html_contact_SMS .= "<td>";
        $html_contact_SMS .= "<input type='checkbox' id='".$i."_checkbox_pop_sms_account' name='".$i."_checkbox_pop_sms_account' checked='checked' onclick='isselect_checkbox_pop_sms_account()' value='$smsmodule#".$accounttype_SMS[$i]['fieldname']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$tabname.":&nbsp".$accounttype_SMS[$i]['fieldlabel']."";
        $html_contact_SMS .= "</td>";
        $html_contact_SMS .= "</tr>";
    }
    else
    {
        $html_contact_SMS .= "<tr>";
        $html_contact_SMS .= "<td>";
        $html_contact_SMS .= "<input type='checkbox' id='".$i."_checkbox_pop_sms_account' name='".$i."_checkbox_pop_sms_account' onclick='isselect_checkbox_pop_sms_account()' value='$smsmodule#".$accounttype_SMS[$i]['fieldname']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$tabname.":&nbsp".$accounttype_SMS[$i]['fieldlabel']."";
        $html_contact_SMS .= "</td>";
        $html_contact_SMS .= "</tr>";
    }
}
require_once('AccountPopup.php');

?>