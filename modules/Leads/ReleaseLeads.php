<?php
global $adb;
global $current_user;
//释放
if(!empty($_REQUEST['record'])){
	$record = $_REQUEST['record'];
}else if(!empty($_REQUEST['idstring'])){
	$record = $_REQUEST['idstring'];
}
crm_load_class_file("cls_ReleaseLeads", 'modules/Leads');
$cls_ReleaseAccount = new cls_ReleaseLeads($record,'Leads');
$releaseAccountReasons = $_REQUEST['releaseAccountReasons'];	//释放原因
$cls_ReleaseAccount->setReleaseAccount($releaseAccountReasons);

$viewid = vtlib_purify($_REQUEST['viewname']);
$SearchScope=$_REQUEST['SearchScope'];
if(isset($_REQUEST['start']) && $_REQUEST['start']!=''){
    	$rstart = "&start=".vtlib_purify($_REQUEST['start']);
    }
$accounttype=$_REQUEST['pagepublicaccounttype'];
if(isset($_SESSION['lvs']['Leads']['viewname'])){
	$start = $_SESSION['lvs']['Leads'][$viewid]['start'];
}
if(!$start) $start = 1;

@ob_clean();
@ob_flush();
echo $start;
//header("Location: index.php?module=Accounts&action=ListView&parenttab=Parent Accounts$rstart&SearchScope=$SearchScope&pagepublicaccounttype=$accounttype&viewid=$viewid");
exit();
?>