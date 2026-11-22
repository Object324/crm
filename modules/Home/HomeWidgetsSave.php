<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/
 //zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once 'include/utils/utils.php';
require_once 'modules/PickList/PickListUtils.php';
require_once "include/Zend/Json.php";

$values = vtlib_purify($_REQUEST['values']);
$val = Zend_Json::decode($values);
HomeDefaultWidgets::saveSelected($val);

class HomeDefaultWidgets {
	public static function saveSelected($values){
		global $adb, $current_user;
		$userId = $current_user->id;
		for($i = 0;$i < count($values);$i++)
		{	if($values[$i] != null){
				$query=" update ld_homestuff,ld_homedefault set ld_homestuff.visible=0 where ld_homestuff.stuffid=ld_homedefault.stuffid and ld_homestuff.userid=".$userId." and ld_homedefault.hometype='".$values[$i]."'";//To show the default Homestuff on the the Home Page
				$result=$adb->query($query);
			}
		}
	}
}
?>