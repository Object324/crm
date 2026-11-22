<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
global $mod_strings,$app_strings,$currentModule,$theme,$current_user,$adb;
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty;
$tmp_field_obj=Field::getInstance($currentModule,$adb);
$moduleFields=$tmp_field_obj->getModuleFields();
$smarty->assign('TABID',getTabid($currentModule));
//派息、反派息后是否立即发送短信
if(isset($_REQUEST['save_sms']) && $_REQUEST['save_sms'] == 'yes'){
    $query='delete from ld_dividendorder_sms ';
    $adb->pquery($sql,array());
    
	$query = 'insert into  ld_dividendorder_sms  (is_dividend ,is_anti_dividend ,mobile_fieldname)value(?,?,?) ';
	$adb->pquery($query,array($_REQUEST['is_dividend_checked'],$_REQUEST['is_anti_dividend_checked'],$_REQUEST['mobile_fieldname']));
	if(isset($_REQUEST['textDividendContent'])){
		$query = 'update ld_sendinformcontent set content = ? where type = 9';
		$adb->pquery($query,array($_REQUEST['textDividendContent']));
	}
	if(isset($_REQUEST['textAntiDividendContent'])){
		$query = 'update ld_sendinformcontent set content = ? where type = 10';
		$adb->pquery($query,array($_REQUEST['textAntiDividendContent']));
	}
	exit();
}
//获取短信内容
$query = 'select content from ld_sendinformcontent where type in (9,10)';
$result = $adb->pquery($query,array());
$num_rows = $adb->num_rows($result);
if($num_rows > 0){
	$dividend_content = $adb->query_result($result,0,'content');
	$anti_dividend_content = $adb->query_result($result,1,'content');
}
//设置短信格式
if(isset($_REQUEST['get_sms_content']) && $_REQUEST['get_sms_content'] == 'yes'){
	$printtabs[getTabid($currentModule)]=getTranstab($currentModule);
	if(isset($_REQUEST['dividend_type'])){
		if($_REQUEST['dividend_type'] == 1){//派息短信内容
			$smarty->assign('sms_contents',$dividend_content);
		}else{//反派息短信内容
			$smarty->assign('sms_contents',$anti_dividend_content);
		}
	}
	$smarty->assign('DIVIDENDTYPE',$_REQUEST['dividend_type']);
	$smarty->assign("PRINTTABS",$printtabs);
	$smarty->display("modules/DividendOrder/SmsContent.tpl");
	exit();
}
if(isset($_REQUEST['sms_templates']) && $_REQUEST['sms_templates'] == 'yes'){
	if($_REQUEST['dividend_type'] == 1){
		$dividend_content = $_REQUEST['sms_content'];
	}else{
		$anti_dividend_content = $_REQUEST['sms_content'];
	}
}
//获取派息 短信设置信息
$dividend_sms = $focus->getDividendSms();
$smarty->assign('is_dividend',$dividend_sms['is_dividend']);
$smarty->assign('is_anti_dividend',$dividend_sms['is_anti_dividend']);
$mobile_fieldname = $dividend_sms['mobile_fieldname'];

//获取模块手机字段
foreach($moduleFields as $fieldname => $field){
	if(!empty($field)){
		if($field->getFieldDataType() == 'mobile'){
			$columnname = $field->getColumnName();
			$fieldlabel = $field->getfieldLabel();
			$selected= '';
			if(in_array($fieldname,$mobile_fieldname)){
				$checked = 'checked';
			}
			$mobile_info[$fieldname] = array(
				'columnname' =>	$fieldlabel,
				'chk' => $checked,
			);
		}
	}
}

$smarty->assign('dividend_content',$dividend_content);
$smarty->assign('anti_dividend_content',$anti_dividend_content);
$smarty->assign('MODULE_NAME',getTranstab($currentModule));
$smarty->assign('MOBILEINFO',$mobile_info);
$smarty->display("modules/DividendOrder/SmsSettings.tpl");
exit();
?>