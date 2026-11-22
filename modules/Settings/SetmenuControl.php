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


$Iconimg = array('1'=>'Icon_user','2'=>'Icon_xiset','3'=>'Icon_other');
$smarty->assign("ICONIMG",$Iconimg);
$smarty->assign("BLOCKIDSETTING", $_REQUEST['blockidsetting']);
$smarty->assign("FIELDIDSETTING", $_REQUEST['fieldidsetting']);
if(isset($_REQUEST['menufile']) && !empty($_REQUEST['menufile'])){//2024-3-18 xxy 跳转或刷新后台设置页面，导航栏没有选中当前页的标签(BUG20240318-03 从客户跳转工商的时候，工商信息设置没有选中)
    $menufile = $_REQUEST['menufile'];
    $sql = "SELECT fieldid from ld_settings_field where linkto like 'index.php?module=%&action=".$menufile."%&parenttab=Settings%'";
    $result = $adb->pquery($sql,array());
    $fieldidselected = $adb->query_result($result, 0, "fieldid");
    $smarty->assign("FIELDIDSELECTED", $fieldidselected);
}


global $adb;
//部门设置，审批流程：角色权限
if($_REQUEST['action'] == 'RoleDetailView'){
    $name = 'LBL_USERS';
}else{
    $name = 'LBL_ROLES';
}
$query = "select fieldid,blockid from ld_settings_field where active=0 and `name`= ?";
$result = $adb->pquery($query,array($name));
if(is_object($result)){
	$fieldidspecial = $adb->query_result($result, 0, "fieldid");
	$blockidspecial = $adb->query_result($result, 0, "blockid");
	$smarty->assign("FIELDIDSPECIAL", $fieldidspecial);
	$smarty->assign("BLOCKIDSPECIAL", $blockidspecial);
}
$SettingsBlocks = getSettingsBlocks();
$SettingsFields = getSettingsFields();
//wyt 220819 BUG0055311 系统设置-订单小程序设置，一些字段没有标题
foreach($SettingsFields as $settingnum=>$blockid){
    $block_arr[] = $blockid;
    $Service='selftype=service';
    foreach($blockid as $entrynum=>$info) {
        if(isset($SettingsFields[$settingnum][$entrynum]['link']) && strpos($SettingsFields[$settingnum][$entrynum]['link'],'selftype=service')){
            $SettingsFields[$settingnum][$entrynum]['miniprogram_service'] = 'Service';
        }
    }

}
foreach($SettingsBlocks as $blockid){
	if(!in_array($blockid,$block_arr)){
		unset($SettingsBlocks[$blockid]);
	}
}

$menu_num = 0;
if(!empty($_REQUEST['menufile'])){
    foreach($SettingsFields as $key => $arr){
        foreach($arr as $info){
            if($info['action'] == $_REQUEST['menufile']){
                //duan 202207029 服务小程序和订单小程序跳转判断，因为访问的menufile相同，所以增加判断selftype
                if($_REQUEST['menufile'] == 'SelfServiceConfig'&& isset($_REQUEST['page_addurl']) && strpos($info['link'],'selftype='.$_REQUEST['page_addurl'])===false ){
                    continue;
                }
                $menu_num = $key;
                break;
            }
        }
    }
}
$smarty->assign("MENU_NUM",$menu_num); 
$smarty->assign("BLOCKS",$SettingsBlocks);
$smarty->assign("FIELDS",$SettingsFields);
setGLobalURLSmarty($smarty);//js,css加载的url
?>