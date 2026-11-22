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
global $adb,$current_user;
crm_load_class_file('cls_RelatedEntryField_Data','include/RelatedField');
$relatedfielddata = array();
if(!empty($_REQUEST['clear']) && $_REQUEST['clear'] == 'yes'){
	//清除
	$cls_RelatedEntryField_Data = new cls_RelatedEntryField_Data($_REQUEST['curmodule'],$_REQUEST['trigger_columnname']);
	$relatedfielddata = $cls_RelatedEntryField_Data->getClearData();
}else{
	if(!empty($_REQUEST['curmodule']) && !empty($_REQUEST['trigger_columnname'])){
		$_REQUEST['relatedtype'] = 'trigger';
		$cls_RelatedEntryField_Data = new cls_RelatedEntryField_Data($_REQUEST['curmodule'],$_REQUEST['trigger_columnname']);
		$relatedfielddata = $cls_RelatedEntryField_Data->getData();
	}
}
$_REQUEST['diony']='diony';
ConvertTojsonString(1,$relatedfielddata,"success");
exit();
	
?>