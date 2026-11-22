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
 * $Header: /advent/projects/wesat/lingdang_crm/sugarcrm/modules/Contacts/Popup.php,v 1.15 2005/04/19 15:33:44 rank Exp $
 * Description:  TODO: To be written.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 ********************************************************************************/
 /***
更新操作
edit：cdw
date：20131126
reason：营销界面群发短信功能改进
**/
global $app_strings, $mod_strings, $adb;


    $sql_contact_SMS = "";
    $sql_contact_SMS .= " select ld_field.tabid,ld_field.fieldlabel,ld_field.tablename,ld_languagepackage.newchinesename,ld_tab.name ";
    $sql_contact_SMS .= " from ld_field inner join ld_languagepackage  ";
    $sql_contact_SMS .= " on ld_field.tabid = ld_languagepackage.tabid inner join ld_tab  on ld_tab.tabid=ld_field.tabid ";
    $sql_contact_SMS .= " where ld_field.tabid = 4 and uitype = 1101 and ld_field.presence<>1 order by fieldlabel desc ";
    
    $contact_SMS_result = $adb->pquery($sql_contact_SMS,array());
    $num_rows_contact = $adb->num_rows($contact_SMS_result);
    $contact_SMS = array();

    for($i=0;$i<$num_rows_contact;$i++)
    {
        //影响取值
       // $tabname=$adb->query_result($contact_SMS_result,$i,'name');
        //require_once('modules/'.$tabname.'/language/zh_cn.lang.php');
//        $fieldlabel=$adb->query_result($contact_SMS_result,$i,'fieldlabel');
//        if(array_key_exists($fieldlabel,$mod_strings))
//        {
//            $fieldlabel=$mod_strings[$fieldlabel];
//        }
//        else if(array_key_exists($fieldlabel,$app_strings))
//        {
//            $fieldlabel=$app_strings[$fieldlabel];
//        }
        $contact_SMS[]=array(
        'tabid'=>$adb->query_result($contact_SMS_result,$i,'tabid'),
        'fieldlabel'=>$adb->query_result($contact_SMS_result,$i,'fieldlabel'),
        'tablename'=>$adb->query_result($contact_SMS_result,$i,'tablename'),
        'newchinesename'=>$adb->query_result($contact_SMS_result,$i,'newchinesename')
        
        );
    }
    for($i=0;$i<$num_rows_contact;$i++)
    {
   
        if($i==0)
        {
            $html_contact_SMS .= "<tr>";
            $html_contact_SMS .= "<td>";
            $html_contact_SMS .= "<input type='checkbox' id='".$i."_checkbox_pop_sms' checked='checked' onclick='isselect_checkbox_sms_pop()' value='".$contact_SMS[$i]['tabid']."_".$contact_SMS[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$contact_SMS[$i]['newchinesename'].":&nbsp".getTranslatedString($contact_SMS[$i]['fieldlabel'])."";
            $html_contact_SMS .= "</td>";
            $html_contact_SMS .= "</tr>";
        }
        else
        {
            $html_contact_SMS .= "<tr>";
            $html_contact_SMS .= "<td>";
            $html_contact_SMS .= "<input type='checkbox' id='".$i."_checkbox_pop_sms' onclick='isselect_checkbox_sms_pop()' value='".$contact_SMS[$i]['tabid']."_".$contact_SMS[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$contact_SMS[$i]['newchinesename'].":&nbsp".getTranslatedString($contact_SMS[$i]['fieldlabel'])."";
            $html_contact_SMS .= "</td>";
            $html_contact_SMS .= "</tr>";
        }
    }
    
/***
更新操作
edit：cdw
date：20131128
reason：营销界面群发邮件功能改进
**/
    $sql_contact_Email = "";
    $sql_contact_Email .= " select ld_field.tabid,ld_field.fieldlabel,ld_field.tablename,ld_languagepackage.newchinesename,ld_tab.name ";
    $sql_contact_Email .= " from ld_field inner join ld_languagepackage  ";
    $sql_contact_Email .= " on ld_field.tabid = ld_languagepackage.tabid inner join ld_tab  on ld_tab.tabid=ld_field.tabid ";
    $sql_contact_Email .= " where ld_field.tabid = 4 and uitype = 13 and ld_field.presence<>1 order by fieldlabel desc ";
    
    $contact_Email_result = $adb->pquery($sql_contact_Email,array());
    $num_rows_contact_Email = $adb->num_rows($contact_Email_result);
    $contact_Email = array();

    for($i=0;$i<$num_rows_contact_Email;$i++)
    {
        //影响取值
       // $tabname=$adb->query_result($contact_SMS_result,$i,'name');
        //require_once('modules/'.$tabname.'/language/zh_cn.lang.php');
//        $fieldlabel=$adb->query_result($contact_SMS_result,$i,'fieldlabel');
//        if(array_key_exists($fieldlabel,$mod_strings))
//        {
//            $fieldlabel=$mod_strings[$fieldlabel];
//        }
//        else if(array_key_exists($fieldlabel,$app_strings))
//        {
//            $fieldlabel=$app_strings[$fieldlabel];
//        }
        $contact_Email[]=array(
        'tabid'=>$adb->query_result($contact_Email_result,$i,'tabid'),
        'fieldlabel'=>$adb->query_result($contact_Email_result,$i,'fieldlabel'),
        'tablename'=>$adb->query_result($contact_Email_result,$i,'tablename'),
        'newchinesename'=>$adb->query_result($contact_Email_result,$i,'newchinesename')
        
        );
    }
    for($i=0;$i<$num_rows_contact_Email;$i++)
    {
   
        if($i==0)
        {
            $html_contact_Email .= "<tr>";
            $html_contact_Email .= "<td>";
            $html_contact_Email .= "<input type='checkbox' id='".$i."_checkbox_pop_email' checked='checked' onclick='isselect_checkbox_pop_contact_email()' value='".$contact_Email[$i]['tabid']."_".$contact_Email[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$contact_Email[$i]['newchinesename'].":&nbsp".$contact_Email[$i]['fieldlabel']."";
            $html_contact_Email .= "</td>";
            $html_contact_Email .= "</tr>";
        }
        else
        {
            $html_contact_Email .= "<tr>";
            $html_contact_Email .= "<td>";
            $html_contact_Email .= "<input type='checkbox' id='".$i."_checkbox_pop_email' onclick='isselect_checkbox_pop_contact_email()' value='".$contact_Email[$i]['tabid']."_".$contact_Email[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$contact_Email[$i]['newchinesename'].":&nbsp".$contact_Email[$i]['fieldlabel']."";
            $html_contact_Email .= "</td>";
            $html_contact_Email .= "</tr>";
        }
    }

require_once('Popup.php');
?>