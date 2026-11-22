<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once(globalStatic::$root_directory.'Smarty_setup.php');
crm_load_class_file('cls_ButtonsCustomization','modules/Settings');
global $current_user,$adb,$languageType;
$smarty = new lingdangCRM_Smarty();
$mode = '';
if(isset($_REQUEST['mode']) && !empty($_REQUEST['mode'])){
    $mode = $_REQUEST['mode'];
}
$module = '';
// if(isset($_REQUEST['selectedmodule']) && !empty($_REQUEST['selectedmodule'])){
//     $module = $_REQUEST['selectedmodule'];
// }
$tabid = 0;
if(isset($_REQUEST['selected_tabid']) && !empty($_REQUEST['selected_tabid'])){
    $tabid = $_REQUEST['selected_tabid'];
}
if(!empty($tabid) && $tabid > 0){
	$module = getTabModuleName($tabid);
}
if($tabid == 0 && isset($_REQUEST['btn_module']) && !empty($_REQUEST['btn_module'])){
    $module = $_REQUEST['btn_module'];
}
$btnid = 0;
if(isset($_REQUEST['btnid']) && !empty($_REQUEST['btnid'])){
    $btnid = $_REQUEST['btnid'];
}
$buttoncustomizationObj = new cls_ButtonsCustomization($module);
$_REQUEST['diony']='yes';

if (!empty($mode)) {
    switch ($mode) {
        // 获取分类
        case 'list':
			
			$listheader_arr = $buttoncustomizationObj->getListHeader();
			$listdata_arr = $buttoncustomizationObj->getListData();
			// $arr['optionmodule_arr'] = $optionmodule_arr;
			// dump($listdata_arr);
			$smarty->assign("listheader_arr", $listheader_arr);
			$smarty->assign("listdata_arr", $listdata_arr);
			// $smarty->assign("listdata_arr_json", ldcrm_json_encode($listdata_arr));
			$arr['listdata_arr'] = $listdata_arr;
			$arr['popuptype'] = 'ButtonsCustomization';
            if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){

				$arr['content'] = $smarty->fetch('ButtonsCustomization/ButtonsCustomizationList.tpl');
			}
			else{
				$tmp_optionmodule = ['tabid' => -1, 'module' => 'All', 'label' => getFixedLabel('ALL')];
				$optionmodule_arr = $buttoncustomizationObj->getOptionModules();
				array_unshift($optionmodule_arr, $tmp_optionmodule);
				// $arr['optionmodule_arr'] = $optionmodule_arr;
				$smarty->assign("optionmodule_arr", $optionmodule_arr);
				// dump($listdata_arr);
				$arr['content'] = $smarty->fetch('ButtonsCustomization/ButtonsCustomizationEntries.tpl');
			}
			unset($buttoncustomizationObj);
			ConvertTojsonString(1,$arr,"success");
            break;
		
        // 编辑-弹出层
        case 'edit':

			$buttoninfo_arr = $buttoncustomizationObj->getButtonInfo($btnid);
			$smarty->assign('buttoninfo_arr',$buttoninfo_arr);
			$arr['buttoninfo_arr'] = $buttoninfo_arr;
			if($buttoninfo_arr['type'] == 'workflow'){
				$smarty->assign('WORKFLOW_ID',$buttoninfo_arr['related_id']);
				$smarty->assign('WORKFLOW_ACTIONS',$buttoninfo_arr['relatedinfo']);
			}
			// dump($buttoninfo_arr);
			$cur_module = $module;
			// 按钮权限 - 获取已保存的角色id，用户id
			$profileid_arr = explode(',', trim($buttoninfo_arr['profileid']));//指定角色
			if (sizeof($profileid_arr) > 0) {
				$profile = new Profile();
				foreach ($profileid_arr as $tmp_profileid) {
					$profileinfo = $profile->getProfileinfo($tmp_profileid);
					$profilename_arr[] = $profileinfo['profilename'];
				}
				$smarty->assign('PROFILENAME', implode(',', $profilename_arr));
				$smarty->assign('PROFILEID', $buttoninfo_arr['profileid']);
			}

			$userid_arr = explode(',', trim($buttoninfo_arr['userid']));//指定用户
			if (sizeof($userid_arr) > 0) {
				foreach ($userid_arr as $tmp_userid) {
					$username_arr[] = getUserFullName($tmp_userid);
				}
				$smarty->assign('USERNAME', implode(',', $username_arr));
				$smarty->assign('USERID', $buttoninfo_arr['userid']);
			}
			
			$smarty->assign('USERFIELDID', explode(',', $buttoninfo_arr['userfieldid']));//用户字段
			// 数据库中保存的显示条件
			$advft_criteria = $buttoninfo_arr['advft_criteria'];
			$advft_criteria_groups = $buttoninfo_arr['advft_criteria_groups'];

        // 新增-弹出层
        case 'create':

            $smarty->assign('MODE',$mode);
			// 可选模块
			$optionmodule_arr = $buttoncustomizationObj->getOptionModules();
			$smarty->assign("optionmodule_arr", $optionmodule_arr);
			//当前模块的用户字段
			if(!empty($tabid)){
				$cur_module = $module;
			}
			if(empty($cur_module)){
				$cur_module = $optionmodule_arr[0]['module'];
			}
			$userfields_arr = $buttoncustomizationObj->getUserFields($cur_module);
			$smarty->assign('userfields_arr',$userfields_arr);
			// 按钮位置翻译
			$smarty->assign("btnposition_label_arr", $buttoncustomizationObj->btnposition_label_arr);
			$cur_tabid = getTabid($cur_module);
			if ($cur_tabid == 16) {
				$cur_tabid = 9;
			}
			// 显示条件
			$_REQUEST['tabid'] = $cur_tabid;
			include(globalStatic::$root_directory.'modules/Settings/WorkflowAdvSearch.php');

			$fLabels = CommonView::getComparatorLabel();
			$arr['flabels'] = $fLabels;
			$arr['btn_addnewcombinationtext'] = getFixedLabel('NEWCOMBINATION');// 高级查询"新组合"
			$arr['btn_addnewcondtiontext'] = getFixedLabel('NEWCONDITIONS');// 按钮”新条件"
			$arr['datetimestr'] = CommonView::stdFilterDateTimeStr();
            $advfilterhtml = CommonView::getAdvCriteriaHTML($comparatorArr);
            // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
            $controller = ListViewController::getInstance($cur_module);
            $arr['advanceFields'] = $controller->getAdvanceFields();
            $arr['foption'] = $advfilterhtml;
			if(!empty($advfilterlist))
				$arr['criteria_groups']=$advfilterlist;	
			else
				$arr['criteria_groups']="";

			$smarty->assign('FROMMODULE_TABLE',$cur_tabid);
			$arr['title'] = getFixedLabel("ButtonsCustomization");
			$arr['oktext'] = getFixedLabel("SAVE");
			$arr['canceltext'] = getFixedLabel("CANCEL");
			$arr['content'] = $smarty->fetch('ButtonsCustomization/ButtonsCustomizationPopup.tpl');
			unset($buttoncustomizationObj);
            ConvertTojsonString(1,$arr,"success");
            break;
		// 选择模块
		case 'selectmodule':
			// 模块的用户字段
			$userfields_arr = $buttoncustomizationObj->getUserFields($module);
			// $smarty->assign('userfields_arr',$userfields_arr);
			$arr['userfields_arr'] = $userfields_arr;
			$_REQUEST['tabid'] = $tabid;
			include(globalStatic::$root_directory.'modules/Settings/WorkflowAdvSearch.php');
			unset($buttoncustomizationObj);
			ConvertTojsonString(1,$arr,"success");
			break;

        // 保存自定义按钮
        case 'save':
            $params_arr = $_REQUEST['params_arr'];
			$buttoncustomizationObj->saveButton($btnid,$params_arr);
			$cachekey = 'cache_custom_activebuttons_'.$module;
			unsetCache($cachekey);
			unset($buttoncustomizationObj);
            ConvertTojsonString(1,$arr,"success");
            break;

		// 删除自定义按钮
		case 'delete':
			$buttoncustomizationObj->deleteButton($btnid,$_REQUEST['type'],$_REQUEST['related_id']);
			$cachekey = 'cache_custom_activebuttons_'.$module;
			unsetCache($cachekey);
			unset($buttoncustomizationObj);
			ConvertTojsonString(1,$arr,"success");
			break;

		// 启用/不启用 自定义按钮
		case 'changeactive':
			$buttoncustomizationObj->changeButtonActive($btnid,$_REQUEST['is_active'],$_REQUEST['type'],$_REQUEST['related_id']);
			$cachekey = 'cache_custom_activebuttons_'.$module;
			// dump($cachekey);
			unsetCache($cachekey);
			unset($buttoncustomizationObj);
			ConvertTojsonString(1,$arr,"success");
			break;

        // 自定义按钮点击事件
        case 'buttonclick':
			$record = $_REQUEST['record'];
			// $values['btn_from'] = $_REQUEST['btn_from'];
			// $values['position'] = $_REQUEST['position'];

			// 判断当前按钮是否还符合条件
			$focus = CRMEntity::getInstance($module);
			$focus->retrieve_entity_info($record,$module);
			$current_btninfo = $buttoncustomizationObj->getButtonInfo($btnid);
			$btn_permit = $buttoncustomizationObj->getButtonPermit($current_btninfo,$record);
			if($btn_permit != 'yes'){
				ConvertTojsonString(-1, array(), getFixedLabel('NOPERMITTEDEXECUTE'));
			}
			
            //工作流程反写
            crm_load_class_file("cls_savereverse", 'include/SaveReverse');
			$pagemode = 'ButtonsCustomization';
            $workflowreverseobj = cls_savereverse::getInstance($module);
			$workflowreverseobj->setPageMode($pagemode);
			$workflowreverseobj->custombutton_id = $btnid;
			$workflowreverseobj->getInfo();
			// dump($workflowreverseobj->checkCallApiPop());

			if ($adb->num_rows($workflowreverseobj->workflowresut) > 0) {
				$workflowreverseobj->setRecord($record);
				$beforefieldvalue_arr = [];
				$afterfieldvalue_arr = [];
				$focus = CRMEntity::getInstance($module);

				if ($workflowreverseobj->checkCallApiPop() == 'yes')
					$workflowreverseobj->setNotCallActionType(array('API', 'Link2ERP'));//无需处理的API类型
				$workflowreverseobj->getStartComputer($beforefieldvalue_arr, $afterfieldvalue_arr, $pagemode);

				$receive_msg = $workflowreverseobj->checkCallApiPop();
				$workflow_apiinfo['receive_msg'] = $receive_msg;
				if ($receive_msg == 'yes') {
					$workflow_apiinfo['record'] = $record;
					$workflow_apiinfo['module'] = $module;
					$workflow_apiinfo['pagemode'] = $workflowreverseobj->getPageMode();

					$workflow_apiinfo['before_save_infos'] = $beforefieldvalue_arr;
					$workflow_apiinfo['after_save_infos'] = $focus->column_fields;
				}
				$arr['workflow'] = $workflow_apiinfo;
				// dump($workflow_apiinfo);
			}
			unset($buttoncustomizationObj);
            ConvertTojsonString(1,$arr,getFixedLabel('SUCCESSFULOPERATION'));
            break;

        default:
            
            break;
    }

    ConvertTojsonString(-1, array(), getFixedLabel('NOMATCHINGITEMS'));

} else {
    ConvertTojsonString(-1, array(), getFixedLabel('NOMATCHINGITEMS'));
}

?>