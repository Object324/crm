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
/*********************************************************************************
 * $Header: /advent/projects/wesat/lingdang_crm/sugarcrm/modules/Leads/Popup.php,v 1.7 2005/03/23 14:19:48 samk Exp $
 * Description:  TODO: To be written.
 ********************************************************************************/

if($_REQUEST['popuptype'] == 'MultiplePopup' && $_REQUEST['module'] == 'Users' && $_REQUEST['selectmodule'] && $_REQUEST['selectmodule'] != 'Users'){
    //关联选择单据 将moduel 改为 Users
    if($currentModule == 'Users' && isset($_REQUEST['selectmodule']) && !empty($_REQUEST['selectmodule'])){
        $currentModule = $_REQUEST['selectmodule'];
        $_REQUEST['module'] = $_REQUEST['selectmodule'];
        $module = $_REQUEST['selectmodule'];
    }
    require_once(globalStatic::$root_directory.'modules/'.$_REQUEST['selectmodule'].'/Popup.php');
    exit();
}
global $current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
$sql_userstype_SMS = "";
$sql_userstype_SMS .= " select ld_field.tabid,ld_tranlabel.fieldlabel,ld_field.tablename ";
$sql_userstype_SMS .= " from ld_field inner join ld_tranlabel  ";
$sql_userstype_SMS .= " on ld_field.fieldid = ld_tranlabel.relateid ";
$sql_userstype_SMS .= " where ld_tranlabel.languagetype=? and trantable=? and  (ld_tranlabel.tabid=29) and uitype = 1101 and ld_field.presence<>1 order by tabid desc ";
$userstype_SMS_result = $adb->pquery($sql_userstype_SMS,array($languageType,'ld_field'));
$num_rows_users=$adb->num_rows($userstype_SMS_result);
$userstype_SMS = array();
for($i=0;$i<$num_rows_users;$i++)
{
    $tabname=$adb->query_result($userstype_SMS_result,$i,'name');
    $userstype_SMS[]=array(
    'tabid'=>$adb->query_result($userstype_SMS_result,$i,'tabid'),
    'fieldlabel'=>$adb->query_result($userstype_SMS_result,$i,'fieldlabel'),
    'tablename'=>$adb->query_result($userstype_SMS_result,$i,'tablename'),
    'newchinesename'=>$adb->query_result($userstype_SMS_result,$i,'newchinesename')
    
    );
}
$html_userstype_SMS = "";
for($i=0;$i<$num_rows_users;$i++)
{
    $smstabid = $userstype_SMS[$i]['tabid'];
    if($smstabid==6)
    {
        $tabname = getTranstab('Accounts');
    }
    else if($smstabid==4)
    {
        $tabname = getTranstab('Contacts');
    }
    else if($smstabid==29)
    {
        $tabname = getTranstab('Users');
    }
    if($i==0)
    {
        $html_userstype_SMS .= "<tr>";
        $html_userstype_SMS .= "<td>";
        $html_userstype_SMS .= "<input type='checkbox' id='".$i."_checkbox_pop_sms_account' checked='checked' onclick='isselect_checkbox_pop_sms_account()' value='".$userstype_SMS[$i]['tabid']."_".$userstype_SMS[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$tabname.":&nbsp".$userstype_SMS[$i]['fieldlabel']."";
        $html_userstype_SMS .= "</td>";
        $html_userstype_SMS .= "</tr>";
    }
    else
    {
        $html_userstype_SMS .= "<tr>";
        $html_userstype_SMS .= "<td>";
        $html_userstype_SMS .= "<input type='checkbox' id='".$i."_checkbox_pop_sms_account' onclick='isselect_checkbox_pop_sms_account()' value='".$userstype_SMS[$i]['tabid']."_".$userstype_SMS[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$tabname.":&nbsp".$userstype_SMS[$i]['fieldlabel']."";
        $html_userstype_SMS .= "</td>";
        $html_userstype_SMS .= "</tr>";
    }
}
$html_contact_SMS = $html_userstype_SMS;


$sql_userstype_Email = "";
$sql_userstype_Email .= " select ld_field.tabid,ld_tranlabel.fieldlabel,ld_field.tablename ";
$sql_userstype_Email .= " from ld_field inner join ld_tranlabel  ";
$sql_userstype_Email .= " on ld_field.fieldid = ld_tranlabel.relateid ";
$sql_userstype_Email .= " where ld_tranlabel.languagetype=? and trantable=? and  (ld_tranlabel.tabid=29) and uitype = 13 and ld_field.presence<>1 order by tabid desc ";
$userstype_Email_result = $adb->pquery($sql_userstype_Email,array($languageType,'ld_field'));
$num_rows_users_Email=$adb->num_rows($userstype_Email_result);
$userstype_Email = array();
for($i=0;$i<$num_rows_users_Email;$i++)
{
    $tabname=$adb->query_result($userstype_Email_result,$i,'name');
    $userstype_Email[]=array(
    'tabid'=>$adb->query_result($userstype_Email_result,$i,'tabid'),
    'fieldlabel'=>$adb->query_result($userstype_Email_result,$i,'fieldlabel'),
    'tablename'=>$adb->query_result($userstype_Email_result,$i,'tablename'),
    'newchinesename'=>$adb->query_result($userstype_Email_result,$i,'newchinesename')
    
    );
}
$html_userstype_Email = "";

for($i=0;$i<$num_rows_users_Email;$i++)
{
    $emailtabid = $userstype_Email[$i]['tabid'];
    if($emailtabid==6)
    {
        $tabname = getTranstab('Accounts');
    }
    else if($emailtabid==4)
    {
        $tabname = getTranstab('Contacts');
    }
    else if($emailtabid==29)
    {
        $tabname = getTranstab('Users');
    }
    if($i==0)
    {
        $html_userstype_Email .= "<tr>";
        $html_userstype_Email .= "<td>";
        $html_userstype_Email .= "<input type='checkbox' id='".$i."_checkbox_pop_email_account' checked='checked' onclick='isselect_checkbox_pop_email_account()' value='".$userstype_Email[$i]['tabid']."_".$userstype_Email[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$tabname.":&nbsp".$userstype_Email[$i]['fieldlabel']."";
        $html_userstype_Email .= "</td>";
        $html_userstype_Email .= "</tr>";
    }
    else
    {
        $html_userstype_Email .= "<tr>";
        $html_userstype_Email .= "<td>";
        $html_userstype_Email .= "<input type='checkbox' id='".$i."_checkbox_pop_email_account' onclick='isselect_checkbox_pop_email_account()' value='".$userstype_Email[$i]['tabid']."_".$userstype_Email[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$tabname.":&nbsp".$userstype_Email[$i]['fieldlabel']."";
        $html_userstype_Email .= "</td>";
        $html_userstype_Email .= "</tr>";
    }
}
 
$html_contact_Email = $html_userstype_Email;
 
require_once('Popup.php');
?>