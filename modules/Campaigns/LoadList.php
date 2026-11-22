<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 * Contributor(s): mmbrich
 ********************************************************************************/

require_once('modules/CustomView/CustomView.php');
require_once('user_privileges/default_module_view.php');

global $currentModule, $current_user;
$queryGenerator = new QueryGenerator(vtlib_purify($_REQUEST["list_type"]), $current_user);
if ($_REQUEST["cvid"] != "0") {
	$queryGenerator->initForCustomViewById(vtlib_purify($_REQUEST["cvid"]));
} else {
	$queryGenerator->initForDefaultCustomView();
}

$rs = $adb->query($queryGenerator->getQuery());

if($_REQUEST["list_type"] == "Leads"){
		$reltable = "ld_campaignleadrel";
		$relid = "leadid";
}
elseif($_REQUEST["list_type"] == "Contacts"){

		$reltable = "ld_campaigncontrel";
		$relid = "contactid";
}
elseif($_REQUEST["list_type"] == "Accounts"){
		$reltable = "ld_campaignaccountrel";
		$relid = "accountid";
}

$focus = CRMEntity::getInstance($currentModule);
while($row=$adb->fetch_array($rs)) {
	relateEntities($focus, $currentModule, vtlib_purify($_REQUEST['return_id']), vtlib_purify($_REQUEST["list_type"]), $row[$relid]);
}

header("Location: index.php?module=Campaigns&action=CampaignsAjax&file=CallRelatedList&ajax=true&".
			"record=".vtlib_purify($_REQUEST['return_id']));

?>