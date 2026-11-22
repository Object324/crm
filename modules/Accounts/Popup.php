<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the SugarCRM Public License Version 1.1.2
 * ("License"); You may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.sugarcrm.com/SPL
 * Software distributed under the License is distributed on an  "AS IS"  basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * The Original Code is:  SugarCRM Open Source
 * The Initial Developer of the Original Code is SugarCRM, Inc.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.;
 * All Rights Reserved.
 * Contributor(s): ______________________________________.
 ********************************************************************************/
/**
更新操作
edit:cdw
date:20131119
reason:营销界面群发短信功能改进
**/
global $current_user;
$languageType= getLanguageType($current_user);
$focus=CRMEntity::getInstance('Accounts');
$fieldobj=$focus->fieldobj;


$accounttype_SMS = array();
foreach($fieldobj->getModuleFields() as $fieldname=>$fieldinfo)
{
     if($fieldinfo->getFieldDataType()!='mobile')
     {
         continue;
     }
    $tabid=6;
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
$html_accounttype_SMS = "";
for($i=0;$i<sizeof($accounttype_SMS);$i++)
{
    $smstabid = $accounttype_SMS[$i]['tabid'];
    if($smstabid==6)
    {
        $tabname = getTranstab('Accounts');
        $smsmodule="Accounts";
    }
    else
    {
        $tabname = getTranstab('Contacts');
        $smsmodule="Contacts";
    }
    if($i==0)
    {
        $html_accounttype_SMS .= "<tr>";
        $html_accounttype_SMS .= "<td>";
        $html_accounttype_SMS .= "<input type='checkbox' id='".$i."_checkbox_pop_sms_account' name='".$i."_checkbox_pop_sms_account' checked='checked' onclick='isselect_checkbox_pop_sms_account()' value='$smsmodule#".$accounttype_SMS[$i]['fieldname']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$tabname.":&nbsp".$accounttype_SMS[$i]['fieldlabel']."";
        $html_accounttype_SMS .= "</td>";
        $html_accounttype_SMS .= "</tr>";
    }
    else
    {
        $html_accounttype_SMS .= "<tr>";
        $html_accounttype_SMS .= "<td>";
        $html_accounttype_SMS .= "<input type='checkbox' id='".$i."_checkbox_pop_sms_account' name='".$i."_checkbox_pop_sms_account' onclick='isselect_checkbox_pop_sms_account()' value='$smsmodule#".$accounttype_SMS[$i]['fieldname']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$tabname.":&nbsp".$accounttype_SMS[$i]['fieldlabel']."";
        $html_accounttype_SMS .= "</td>";
        $html_accounttype_SMS .= "</tr>";
    }
}
/**
更新操作
edit:cdw
date:20131128
reason:营销界面群发邮件功能改进
**/
$sql_accounttype_Email = "";
$sql_accounttype_Email .= " select ld_field.tabid,ld_tranlabel.fieldlabel,ld_field.tablename ";
$sql_accounttype_Email .= " from ld_field inner join ld_tranlabel  ";
$sql_accounttype_Email .= " on ld_field.fieldid = ld_tranlabel.relateid ";
$sql_accounttype_Email .= " where ld_tranlabel.languagetype=? and trantable=? and  (ld_tranlabel.tabid=6 or ld_tranlabel.tabid=4) and uitype = 13 and ld_field.presence<>1 order by tabid desc ";
$accounttype_Email_result = $adb->pquery($sql_accounttype_Email,array($languageType,'ld_field'));
$num_rows_account_Email=$adb->num_rows($accounttype_Email_result);
$accounttype_Email = array();
for($i=0;$i<$num_rows_account_Email;$i++)
{
    //$tabname=$adb->query_result($accounttype_Email_result,$i,'name');
    $accounttype_Email[]=array(
    'tabid'=>$adb->query_result($accounttype_Email_result,$i,'tabid'),
    'fieldlabel'=>$adb->query_result($accounttype_Email_result,$i,'fieldlabel'),
    'tablename'=>$adb->query_result($accounttype_Email_result,$i,'tablename')
    //'newchinesename'=>$adb->query_result($accounttype_Email_result,$i,'newchinesename')
    
    );
}
$html_accounttype_Email = "";
for($i=0;$i<$num_rows_account_Email;$i++)
{
    $emailtabid = $accounttype_Email[$i]['tabid'];
    if($emailtabid==6)
    {
        $tabname = getTranstab('Accounts');
    }
    else
    {
        $tabname = getTranstab('Contacts');
    }
    if($i==0)
    {
        $html_accounttype_Email .= "<tr>";
        $html_accounttype_Email .= "<td>";
        $html_accounttype_Email .= "<input type='checkbox' id='".$i."_checkbox_pop_email_account' name='".$i."_checkbox_pop_email_account' checked='checked' onclick='isselect_checkbox_pop_email_account()' value='".$accounttype_Email[$i]['tabid']."_".$accounttype_Email[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$tabname.":&nbsp".$accounttype_Email[$i]['fieldlabel']."";
        $html_accounttype_Email .= "</td>";
        $html_accounttype_Email .= "</tr>";
    }
    else
    {
        $html_accounttype_Email .= "<tr>";
        $html_accounttype_Email .= "<td>";
        $html_accounttype_Email .= "<input type='checkbox' id='".$i."_checkbox_pop_email_account' name='".$i."_checkbox_pop_email_account' onclick='isselect_checkbox_pop_email_account()' value='".$accounttype_Email[$i]['tabid']."_".$accounttype_Email[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$tabname.":&nbsp".$accounttype_Email[$i]['fieldlabel']."";
        $html_accounttype_Email .= "</td>";
        $html_accounttype_Email .= "</tr>";
    }
}
$mail_field = sizeOf($accounttype_Email);
require_once('AccountPopup.php');
?>
