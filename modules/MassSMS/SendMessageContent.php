<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/*客户服务单内容模板*/

global $adb;
global $current_user;

$sqlContent="select * from ld_sendinformcontent where type in (11,12)";
$sqlContentResult=$adb->query($sqlContent,array());
$num_rows=$adb->num_rows($sqlContentResult);

if($num_rows){   
   $contents['accounts'] = $adb->query_result($sqlContentResult,0,'content');
   $contents['servicer'] = $adb->query_result($sqlContentResult,1,'content');
}

$module_arr = array('HelpDesk','Accounts','Contacts','Users');
for($i=0;$i<count($module_arr);$i++){
    $module = $module_arr[$i];
    $tabid = getTabid($module);
    $printtabs[$tabid] = getTranstab($module);
}




$smarty->assign('FROMMODULE',$_REQUEST['frommodule']);

$smarty->assign('TABID',getTabid($_REQUEST['frommodule']));
$smarty->assign("CONTENTS",$contents);
$smarty->assign("PRINTTABS",$printtabs);
$smarty->assign("TICKETID",$_REQUEST['out_id']);
$smarty->assign('CONTENTTYPE',$contenttype);
$smarty->assign('FROMVIEW',$_REQUEST['fromview']);
echo "####:###";

$smarty->display("modules/MassSMS/SendMessageContent.tpl");

exit();

?>