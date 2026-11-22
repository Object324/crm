<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the SugarCRM Public License Version 1.1.2
 * ("License"); You may not use this file except in compliance with the 
 * License. You may obtain a copy of the License at http://www.sugarcrm.com/SPL
 * Software distributed under the License is distributed on an  "AS IS"  basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * The Original Code is:  SugarCRM Open Source
 * The Initial Developer of the Original Code is SugarCRM, Inc.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.;
 * All Rights Reserved.
 * Contributor(s): ______________________________________.
 ********************************************************************************/
/*********************************************************************************
 * $Header: /advent/projects/wesat/lingdang_crm/sugarcrm/modules/Contacts/index.php,v 1.5 2005/03/25 13:37:45 samk Exp $
 * Description:  TODO: To be written.
 ********************************************************************************/

if(!empty($_REQUEST['record']) && !empty($_REQUEST['select_status_value'])){
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
	$json = new Zend_Json();
	$jsonentity = $json->encode($entity);
	echo $jsonentity;die;

}
?>