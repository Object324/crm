<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//editor:gyq_100 reason:微信销售线索增加推进  2019/1/25 13:43
if(!empty($_REQUEST['record']) && !empty($_REQUEST['select_status_value'])){
    global $adb,$currentModule;
    $record = $_REQUEST['record'];
	$focus = CRMEntity::getInstance($currentModule);
	$fieldobj=Field::getInstance($currentModule,$adb);
    $modulefields=$fieldobj->getModuleFields();
	$status = $_REQUEST['select_status_value'];
	$fileurereason = $_REQUEST['fileure_reason'];
	$focus->id = $record;
	$focus->mode = 'edit';
	$focus->retrieve_entity_info($record, $currentModule);

	$field = $modulefields['accountname'];
	if($focus->column_fields['accountname'] == '' && $status == 'Upgrade'){;
		$error_mes = $field->getfieldLabel() . getFixedLabel('ISNULLUpgradeFAILED');
		$entity['result']['value'] = 'error';
	}else{
		//不能重复
		if($field->getfieldOnly() == 1 && $status == 'Upgrade'){
			$query = 'select 1 from ld_account where accountname = ? and deleted = 0';
			$result = $adb->pquery($query,array($focus->column_fields['accountname']));
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				$error_mes = $field->getfieldLabel() . getFixedLabel('RepeatUpgradeFAILED');
				$entity['result']['value'] = 'error';
			}else{
				$focus->updateStatus($_REQUEST['record'],$status,$fileurereason);
				$entity['result']['value'] = 'success';
			}
		}else{
			$focus->updateStatus($_REQUEST['record'],$status,$fileurereason);
			$entity['result']['value'] = 'success';
		}
	}
	$customView = CustomView::getInstance($currentModule);
	$viewid = $customView->getViewId($currentModule);
	if(isset($_SESSION['lvs'][$currentModule]['viewname'])){
		$start = $_SESSION['lvs'][$currentModule][$viewid]['start'];
	}
	if(!$start) $start = 1;
	$entity['start']['value'] = $start;//当前页数
	$entity['error_mes']['value'] = $error_mes;
    ConvertTojsonString(1,$entity,'');
}
?>