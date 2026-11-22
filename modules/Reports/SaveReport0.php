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
require_once('modules/Reports/Reports.php');
require_once('include/logging.php');
require_once('include/database/PearDatabase.php');

global $adb;



$primarymodule_req = vtlib_purify($_REQUEST["primarymodule"]);
$sec_module_name = $_REQUEST["primarymodule"]."relatedmodule";
if(isset($_REQUEST[$sec_module_name])) $secondarymodule_req = vtlib_purify($_REQUEST[$sec_module_name]); 

if(count($secondarymodule_req)>0) {
	$secondarymodule_req = implode(":",$secondarymodule_req);
}

if($primarymodule_req!="")
{
	header("Location: index.php?action=NewReport1&module=Reports&primarymodule=$primarymodule_req&secondarymodule=$secondarymodule_req");	
}
?>