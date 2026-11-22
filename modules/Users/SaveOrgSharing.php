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


global $adb;

$sql2 = "select * from ld_def_org_share where editstatus=0";
$result2 = $adb->pquery($sql2, array());
$num_rows = $adb->num_rows($result2);

for($i=0; $i<$num_rows; $i++) {
	$ruleid=$adb->query_result($result2,$i,'ruleid');
	$tabid=$adb->query_result($result2,$i,'tabid');
	$reqval = $tabid.'_per';	
	$permission=$_REQUEST[$reqval];
 /**
  * edit:can
  * reason:7384: 控制面板 > 共享规则 ：编辑规则把日程管理设为：公开：只读或者公开：读取、编辑或者公开：读取、编辑、删除保存时，自动变为私有了
  * 36684: 系统设置-模块共享规则，客户和联系人模块共享规则，分开显示， 客户共享规则 ,联系人共享规则
	if($tabid == 6) {
		$sql8="update ld_def_org_share set permission=? where tabid=4 or tabid=6";
		$adb->pquery($sql8, array($permission));
        continue;
	}*/

	if($tabid == 9) {
		$sql8="update ld_def_org_share set permission=? where tabid=16 or tabid=9";
		$adb->pquery($sql8, array($permission));	
        continue;	
	}
	$sql7="update ld_def_org_share set permission=? where tabid=? and ruleid=?";
	$adb->pquery($sql7, array($permission, $tabid, $ruleid));

}
$cachekey = 'cache_getmoduleshareinfo';
unsetCache($cachekey);
$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
?>