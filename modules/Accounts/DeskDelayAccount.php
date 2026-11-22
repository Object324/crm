<?php


global $adb;

require_once('Smarty_setup.php');
$smarty = new lingdangCRM_Smarty();

$smarty->assign("RECORD",$_REQUEST['record']);

$sql='select accountname,protectdate from ld_account  where accountid=?';
$result=$adb->pquery($sql,array($_REQUEST['record']));
$accountname=$adb->query_result($result,0,0);
$protectdate = $adb->query_result($result,0,1);
$smarty->assign("ACCOUNTNAME",$accountname);
$smarty->assign('PROTECTDATE',$protectdate);
$smarty->assign('MODULENAME',getTranstab('Accounts'));
$smarty->assign("VIEWID",$_REQUEST['viewid']);
$smarty->assign("SEARCHSCOPE",$_REQUEST['SearchScope']);
$smarty->assign("ACCOUNTTYPE",$_REQUEST['pagepublicaccounttype']);
if($_REQUEST['start'])
{
    $smarty->assign("START",$_REQUEST['start']);
}
$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel('ACCOUNTDELAY');
$str=$smarty->fetch("DelayAccount.tpl");	
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
exit();


?>