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
//获取单据关联信息
	global $adb;
	if(!empty($_REQUEST['linktype']) && !empty($_REQUEST['linklabel'])){
		$linkurl = '';
		if(!empty($_REQUEST['curmodule'])){
			$curmodule = $_REQUEST['curmodule'];
			$tabid = getTabid($curmodule);
		}
		if(!empty($tabid)){
			$query = 'select linkurl from ld_links where tabid = ? and linktype = ? and linklabel = ? limit 1';	
			$result = $adb->pquery($query,array($tabid,$_REQUEST['linktype'],$_REQUEST['linklabel']));
		}else{
			$query = 'select linkurl from ld_links where linktype = ? and linklabel = ? limit 1';
			$result = $adb->pquery($query,array($_REQUEST['linktype'],$_REQUEST['linklabel']));
		}
		$num_rows = $adb->num_rows($result);
		if($num_rows > 0){
			$linkurl = $adb->query_result($result,0,0);
		}
		echo $linkurl;die;
		
	}
?>