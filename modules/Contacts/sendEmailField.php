<?php

global $current_user;
$languageType= getLanguageType($current_user);
$smarty=new lingdangCRM_Smarty();

$sql_contact_Email = "";
$sql_contact_Email .= " select ld_field.tabid,ld_tranlabel.fieldlabel,ld_field.tablename ";
$sql_contact_Email .= " from ld_field inner join ld_tranlabel  ";
$sql_contact_Email .= " on ld_field.fieldid = ld_tranlabel.relateid ";
$sql_contact_Email .= " where ld_tranlabel.languagetype=? and trantable=? and  ld_tranlabel.tabid=4 and uitype = 13 and ld_field.presence<>1 order by fieldlabel desc ";
$contact_Email_result = $adb->pquery($sql_contact_Email,array($languageType,'ld_field'));
$num_rows_Email = $adb->num_rows($contact_Email_result);
$contact_Email = array();

for($i=0;$i<$num_rows_Email;$i++)
{
    $contact_Email[]=array(
    'tabid'=>$adb->query_result($contact_Email_result,$i,'tabid'),
    'fieldlabel'=>$adb->query_result($contact_Email_result,$i,'fieldlabel'),
    'tablename'=>$adb->query_result($contact_Email_result,$i,'tablename'),
    'newchinesename'=>$adb->query_result($contact_Email_result,$i,'newchinesename')
    
    );
}
for($i=0;$i<$num_rows_Email;$i++)
{
    if($i==0)
    {
        $html_contact_Email .= "<tr>";
        $html_contact_Email .= "<td class='ld-form-item-content select-input padL0'>";
        $html_contact_Email .= "<input type='checkbox' id='".$i."_checkbox_email_contact' checked='checked' onclick='isselect_checkboxemail_contact()' value='".$contact_Email[$i]['tabid']."_".$contact_Email[$i]['fieldlabel']."'/><label for='".$i."_checkbox_email_contact'>".getTranstab('Contacts').":&nbsp".$contact_Email[$i]['fieldlabel']."</label>";
        $html_contact_Email .= "</td>";
        $html_contact_Email .= "</tr>";
    }
    else
    {
        $html_contact_Email .= "<tr>";
        $html_contact_Email .= "<td class='ld-form-item-content select-input padL0'>";
        $html_contact_Email .= "<input type='checkbox' id='".$i."_checkbox_email_contact' onclick='isselect_checkboxemail_contact()' value='".$contact_Email[$i]['tabid']."_".$contact_Email[$i]['fieldlabel']."'/><label for='".$i."_checkbox_email_contact'>".getTranstab('Contacts').":&nbsp".$contact_Email[$i]['fieldlabel']."</label>";
        $html_contact_Email .= "</td>";
        $html_contact_Email .= "</tr>";
    }
}
//print_r($html_contact_Email);
$smarty->assign("html_contact_Email",$html_contact_Email);
$smarty->assign("num_rows",$num_rows_Email);
$smarty->assign('MODULE','Contacts');
$smarty->assign('ALLIDSINFO',$_REQUEST['allids']);
echo '&#&#&#';
$smarty->display('sendEmailField.tpl');
exit();
?>