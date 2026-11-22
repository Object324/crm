<?php

global $current_user;
$languageType= getLanguageType($current_user);
$smarty=new lingdangCRM_Smarty();

$sql_account_Email = "";
$sql_account_Email .= " select ld_field.tabid,ld_tranlabel.fieldlabel,ld_field.tablename ";
$sql_account_Email .= " from ld_field inner join ld_tranlabel  ";
$sql_account_Email .= " on ld_field.fieldid = ld_tranlabel.relateid ";
$sql_account_Email .= " where ld_tranlabel.languagetype=? and trantable=? and  (ld_tranlabel.tabid=6 or ld_tranlabel.tabid=4) and uitype = 13 and ld_field.presence<>1 order by tabid desc ";
$account_Email_result = $adb->pquery($sql_account_Email,array($languageType,'ld_field'));
$num_rows_Email=$adb->num_rows($account_Email_result);
$account_Email = array();
for($i=0;$i<$num_rows_Email;$i++)
{
    $tabname=$adb->query_result($account_Email_result,$i,'name');
    $account_Email[]=array(
    'tabid'=>$adb->query_result($account_Email_result,$i,'tabid'),
    'fieldlabel'=>$adb->query_result($account_Email_result,$i,'fieldlabel'),
    'tablename'=>$adb->query_result($account_Email_result,$i,'tablename'),
    'newchinesename'=>$adb->query_result($account_Email_result,$i,'newchinesename')
    
    );
}

$html_account_Email = "";
for($i=0;$i<$num_rows_Email;$i++)
{
    $emailtabid = $account_Email[$i]['tabid'];
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
        $html_account_Email .= "<tr>";
        $html_account_Email .= "<td class='ld-form-item-content select-input padL0'>";
        $html_account_Email .= "<input type='checkbox' id='".$i."_checkbox_email' checked='checked' onclick='isselect_checkboxemail_account()' value='".$account_Email[$i]['tabid']."_".$account_Email[$i]['fieldlabel']."'/><label for='".$i."_checkbox_email'>".$tabname.":&nbsp".$account_Email[$i]['fieldlabel']."</label>";
        $html_account_Email .= "</td>";
        $html_account_Email .= "</tr>";
    }
    else
    {
        $html_account_Email .= "<tr>";
        $html_account_Email .= "<td class='ld-form-item-content select-input padL0'>";
        $html_account_Email .= "<input type='checkbox' id='".$i."_checkbox_email' onclick='isselect_checkboxemail_account()' value='".$account_Email[$i]['tabid']."_".$account_Email[$i]['fieldlabel']."'/><label for='".$i."_checkbox_email'>".$tabname.":&nbsp".$account_Email[$i]['fieldlabel']."</label>";
        $html_account_Email .= "</td>";
        $html_account_Email .= "</tr>";
    }
}
$smarty->assign("html_account_Email",$html_account_Email);
$smarty->assign("num_rows",$num_rows_Email);
$smarty->assign('ALLIDSINFO',$_REQUEST['allids']);
$smarty->assign('MODULE','Accounts');
echo '&#&#&#';
$smarty->display('sendEmailField.tpl');
exit();
?>