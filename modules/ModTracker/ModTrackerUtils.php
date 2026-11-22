<?php

/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
require_once('include/utils/utils.php');
require_once 'vtlib/lingdang/Module.php';
require_once dirname(__FILE__) .'/ModTracker.php';
class ModTrackerUtils
{
	function modTrac_changeModuleVisibility($tabid,$status) {
		if($status == 'module_disable'){
			ModTracker::disableTrackingForModule($tabid);
		} else {
			ModTracker::enableTrackingForModule($tabid);
		}
	}
	function modTrac_getModuleinfo(){
		global $adb;
		$query = $adb->pquery("SELECT ld_modtracker_tabs.visible,ld_tab.name,ld_tab.tabid
								FROM ld_tab
								LEFT JOIN ld_modtracker_tabs ON ld_modtracker_tabs.tabid = ld_tab.tabid
								WHERE ld_tab.presence in (0,2) and ld_tab.isentitytype = 1 AND ld_tab.name NOT IN('Emails', 'Webmails','Reminds')",array());
		$rows = $adb->num_rows($query);

        for($i = 0;$i < $rows; $i++){
			$infomodules[$i]['tabid']  = $adb->query_result($query,$i,'tabid');
			$infomodules[$i]['visible']  = $adb->query_result($query,$i,'visible');
			$infomodules[$i]['name'] = $adb->query_result($query,$i,'name');
		}

		return $infomodules;
	}
}
?>