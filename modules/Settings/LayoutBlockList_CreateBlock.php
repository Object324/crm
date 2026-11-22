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

global $adb,$current_user;
require_once 'modules/PickList/PickListUtils.php';
require('user_privileges/user_language_'.$current_user->id.'.php');
$smarty=new lingdangCRM_Smarty;
$tabid = getTabid($_REQUEST['frommodule']);
$blockquery = "select ld_tranlabel.fieldlabel as blocklabel,blockid from ld_blocks inner join ld_tranlabel on ld_tranlabel.relateid=ld_blocks.blockid

where languagetype=? and trantable=? and ld_tranlabel.tabid = ? and visible=0 and blocklabel<>'LBL_PUBLICACCOUNT_LOG' and blocklabel <> 'LBL_CURRENCY_CONFIGURATION' and blocklabel<> 'LBL_MORE_INFORMATION' and blocklabel<> 'LBL_LABEL' order by sequence asc ";


$blockres = $adb->pquery($blockquery,array($languageType,'ld_blocks',$tabid));
while($blockinfo = $adb->fetch_array($blockres)) {
	$block_array[$blockinfo['blockid']] = ($blockinfo['blocklabel']);
}
$smarty->assign("SETTINGBLOCKS",$block_array);
$smarty->assign("MODULE",$_REQUEST['frommodule']);
$smarty->assign('LANGUAGETYPE',$languageType);
$str=$smarty->fetch('Settings/LayoutBlockList_CreateBlock.tpl');
$arr['title'] = getFixedLabel('NEWBLOCK');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$str;
ConvertTojsonString(1,$arr,'success');
?>