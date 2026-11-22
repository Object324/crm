<?php

global $current_user;
$languageType= getLanguageType($current_user);
 /***
更新操作
edit：cdw
date：20131126
reason：营销界面群发短信功能改进
**/
$focus=CRMEntity::getInstance('Contacts');
$fieldobj=$focus->fieldobj;
global  $adb;

    

    foreach($fieldobj->getModuleFields() as $fieldname=>$fieldinfo)
    {
        if($fieldinfo->getFieldDataType()!='mobile')
         {
             continue;
         }
        $contact_SMS[]=array(
        'tabid'=>4,
        'fieldlabel'=>$fieldinfo->getFieldLabel(),
        'tablename'=>$fieldinfo->getTableName(),
        'fieldname'=>$fieldinfo->getFieldName()
        );
    }
    for($i=0;$i<sizeof($contact_SMS);$i++)
    {
   
        if($i==0)
        {
            $html_contact_SMS .= "<tr>";
            $html_contact_SMS .= "<td>";
            $html_contact_SMS .= "<input type='checkbox' id='".$i."_checkbox_pop_sms' name='".$i."_checkbox_pop_sms' checked='checked' onclick='isselect_checkbox_sms_pop()' value='".$contact_SMS[$i]['fieldname']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".getTranstab('Contacts').":&nbsp".$contact_SMS[$i]['fieldlabel']."";
            $html_contact_SMS .= "</td>";
            $html_contact_SMS .= "</tr>";
        }
        else
        {
            $html_contact_SMS .= "<tr>";
            $html_contact_SMS .= "<td>";
            $html_contact_SMS .= "<input type='checkbox' id='".$i."_checkbox_pop_sms' name='".$i."_checkbox_pop_sms' onclick='isselect_checkbox_sms_pop()' value='".$contact_SMS[$i]['fieldname']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".getTranstab('Contacts').":&nbsp".$contact_SMS[$i]['fieldlabel']."";
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
    $sql_contact_Email .= " select ld_field.tabid,ld_tranlabel.fieldlabel,ld_field.tablename,ld_tab.name ";
    $sql_contact_Email .= " from ld_field inner join ld_tranlabel  ";
    $sql_contact_Email .= " on ld_field.fieldid = ld_tranlabel.Relateid inner join ld_tab  on ld_tab.tabid=ld_field.tabid ";
    $sql_contact_Email .= " where ld_field.tabid = 4  and ld_tranlabel.tabid=4  and uitype = 13 and ld_field.presence<>1  and ld_tranlabel.languagetype=? order by fieldlabel desc ";
     require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
     //echo $sql_contact_Email;
    $contact_Email_result = $adb->pquery($sql_contact_Email,array($languageType));
    $num_rows_contact_Email = $adb->num_rows($contact_Email_result);
    $contact_Email = array();

    for($i=0;$i<$num_rows_contact_Email;$i++)
    {

        $contact_Email[]=array(
        'tabid'=>$adb->query_result($contact_Email_result,$i,'tabid'),
        'fieldlabel'=>$adb->query_result($contact_Email_result,$i,'fieldlabel'),
        'tablename'=>$adb->query_result($contact_Email_result,$i,'tablename')
        //'newchinesename'=>$adb->query_result($contact_Email_result,$i,'newchinesename')
        
        );
    }
    for($i=0;$i<$num_rows_contact_Email;$i++)
    {
   
        if($i==0)
        {
            $html_contact_Email .= "<tr>";
            $html_contact_Email .= "<td>";
            $html_contact_Email .= "<input type='checkbox' id='".$i."_checkbox_pop_email' name='".$i."_checkbox_pop_email' checked='checked' onclick='isselect_checkbox_pop_contact_email()' value='".$contact_Email[$i]['tabid']."_".$contact_Email[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".getTranstab('Contacts').":&nbsp".$contact_Email[$i]['fieldlabel']."";
            $html_contact_Email .= "</td>";
            $html_contact_Email .= "</tr>";
        }
        else
        {
            $html_contact_Email .= "<tr>";
            $html_contact_Email .= "<td>";
            $html_contact_Email .= "<input type='checkbox' id='".$i."_checkbox_pop_email' name='".$i."_checkbox_pop_email' onclick='isselect_checkbox_pop_contact_email()' value='".$contact_Email[$i]['tabid']."_".$contact_Email[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".getTranstab('Contacts').":&nbsp".$contact_Email[$i]['fieldlabel']."";
            $html_contact_Email .= "</td>";
            $html_contact_Email .= "</tr>";
        }
    }

$mail_field = sizeOf($contact_Email);
require_once('Popup.php');
?>