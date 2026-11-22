<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
require_once('include/database/PearDatabase.php');
require_once('user_privileges/default_module_view.php');
global $singlepane_view, $currentModule;
$idlist = vtlib_purify($_REQUEST['idlist']);
$dest_mod = vtlib_purify($_REQUEST['destination_module']);
$record = vtlib_purify($_REQUEST['record']);
$parenttab = getParentTab();

$forCRMRecord = vtlib_purify($_REQUEST['parentid']);

if($singlepane_view == 'true')
	$action = "DetailView";
else
	$action = "CallRelatedList";

$storearray = array();
if(!empty($_REQUEST['idlist'])) {
	// Split the string of ids
	$storearray = explode (";",trim($idlist,";"));
} else if(!empty($_REQUEST['entityid'])){
	$storearray = array($_REQUEST['entityid']);
}elseif(!empty($_REQUEST['pot_id'])) {
	$forCRMRecord = $record;
	$storearray = array(vtlib_purify($_REQUEST["pot_id"]));
	$dest_mod = 'Potentials';
}
$focus = CRMEntity::getInstance($currentModule);
if(!empty($storearray)) {
	relateEntities($focus, $currentModule, $forCRMRecord, $dest_mod, $storearray);
}

header("Location: index.php?action=$action&module=$currentModule&record=".$forCRMRecord."&parenttab=".$parenttab);

?>