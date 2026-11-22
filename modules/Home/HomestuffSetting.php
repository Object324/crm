<?php
/*+*******************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/
/*require_once(globalStatic::$root_directory.'include/home.php');
global $theme, $current_user;
if(!empty($_REQUEST['getHomeStuffUserName']) && $_REQUEST['getHomeStuffUserName'] == 'yes' && !empty($_REQUEST['selected_user'])){	//更改查看范围
	$selected_user = $_REQUEST['selected_user'];
	$selected_user_arr = explode(',', $selected_user);
	foreach($selected_user_arr as $userid){
		$users[$userid] = getUserFullName($userid);
	}
	$homeObj=new Homestuff;
	$users_str = $homeObj->getHomeScopeUserName($users);
	
	$json = new Zend_Json();
	$jsonentity = $json->encode($users_str);
	echo $jsonentity;die;
}else if(!empty($_REQUEST['selectedStuffStr']) && !empty($_REQUEST['stype']) && $_REQUEST['stype'] == 'save'){	//首页设置组建保存
	$selectedStuffStr = explode(';',$_REQUEST['selectedStuffStr']);
	//更新所有的组建显示状态和顺序
	$query = 'update ld_templatesstuff set presence = 1,stuffsequence = 0';
	$adb->pquery($query,array());
	$i = 0;
	foreach($selectedStuffStr as $key => $stuffid){
		if(in_array($stuffid,array(35,36))){
			$i++;
			$query = 'update ld_templatesstuff set presence = 0,stuffsequence = ? where stuffid = ?';
			$adb->pquery($query,array($i,$stuffid));
		}
	}
	foreach($selectedStuffStr as $key => $stuffid){
		if(!in_array($stuffid,array(35,36))){
			$i++;
			$query = 'update ld_templatesstuff set presence = 0,stuffsequence = ? where stuffid = ?';
			$adb->pquery($query,array($i,$stuffid));
		}
	}
	exit();
}else{
	$homeObj=new Homestuff;
	$homedetails = $homeObj->getHomePageFrame();
	if(!empty($homedetails)){
		foreach($homedetails as $info){
			if($info['presence'] == 1){
				$balaStuff[] = $info;
			}else{
				$haveStuff[] = $info;
			}
		}
	}
	$smarty=new lingdangCRM_Smarty;
	$smarty->assign('BALASTUFF',$balaStuff);
	$smarty->assign('HAVESTUFF',$haveStuff);
	$smarty->display("Home/HomestuffSetting.tpl");
	exit();
}
*/
?>