<?php
if(!empty($_REQUEST['record'])){
	$record = $_REQUEST['record'];
	crm_load_class_file("cls_DelayLeads", 'modules/Leads');
	$cls_DelayAccount = new cls_DelayLeads($record,'Leads');
	$txtdelay = $_REQUEST['txtdelay'];	//延期天数
	$cls_DelayAccount->setDelayAccount($txtdelay);
	$viewid = vtlib_purify($_REQUEST['viewname']);
	$SearchScope=$_REQUEST['SearchScope'];
	if(isset($_REQUEST['start']) && $_REQUEST['start']!=''){
			$rstart = "&start=".vtlib_purify($_REQUEST['start']);
		}
	$accounttype=$_REQUEST['pagepublicaccounttype'];
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,array(),"success");
	//header("Location: index.php?module=Accounts&action=ListView&parenttab=Parent Accounts$rstart&SearchScope=$SearchScope&pagepublicaccounttype=$accounttype&viewid=$viewid");
}

?>