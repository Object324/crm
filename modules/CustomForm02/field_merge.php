<?php
//Eidtor:gyq_65 Reason:原查重合并改为合并 Date:2018/3/28 0028 上午 9:14
require_once('Smarty_setup.php');
require_once('database/DatabaseConnection.php');
require_once('modules/Users/Users.php');
require_once('include/utils/utils.php');

$module = vtlib_purify($_REQUEST['module']);
$focus = CRMEntity::getInstance($module);

global $mod_strings, $app_strings, $app_list_strings;
global $current_language, $currentModule, $theme;
global $adb;

$mode = vtlib_purify($_REQUEST['mergemode']);

if($mode == 'mergesave') {
	$return_module=vtlib_purify($_REQUEST['return_module']);
	$action=vtlib_purify($_REQUEST['action']);
	$return_action=vtlib_purify($_REQUEST['return_action']);
	$parenttab=vtlib_purify($_REQUEST['parent']);
	$merge_id=vtlib_purify($_REQUEST['record']);
	$recordids=vtlib_purify($_REQUEST['pass_rec']);
	
	$result =  $adb->pquery("SELECT count(*) AS count FROM ld_contactdetails WHERE contactid=? and deleted=0", array($merge_id));
	$count = $adb->query_result($result,0,'count');
	
	if($count > 0)
	{	
		// First, save the primary record
		$focus->mode="edit";
		setObjectValuesFromRequest($focus);
		$focus->save($module);
		$rec_values=$focus->column_fields;

		// Remove the id of primary record from the list of records to be deleted.
		$del_value=explode(",",$recordids,-1);
		$offset = array_search($merge_id,$del_value);
		unset($del_value[$offset]);
//editor:gyq date:20180810 0034754: （1.6登录）联系人模块：联系人合并，合并后的单据查看明细界面“附件”和“图片”应都保留下来
        crm_load_class_file('cls_FieldMerge','include/Functions');
        $objFieldMerge = new cls_FieldMerge($module);
        $objFieldMerge->merge_attachment($merge_id,$del_value);

        // Transfer the related lists of the records to be deleted, to the primary record's related list
		if(method_exists($focus, 'transferRelatedRecords')){
			$focus->transferRelatedRecords($module,$del_value,$merge_id);
		} else {
			transferRelatedRecords($module,$del_value,$merge_id);
		}
		
		// Delete the records by id specified in the list
		foreach($del_value as $value)
		{
			DeleteEntity($_REQUEST['module'],$_REQUEST['return_module'],$focus,$value,"");
		}
        //editor:gyq_72  date:20180710	0034508: 客户、联系人、服务收费管理列表界面>更多>自动查重合并>选择字段查重>勾选单据合并：合并单据后应该回到查重界面而不是跳转到单据列表界面去。
        if($_REQUEST['second_action']=='merge'){ //合并
            header("Location: index.php?action=ListView&module=$module&parenttab=$parenttab&id=$return_id&record=$return_id&SearchScope=$SearchScope&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']));
        }else{//$_REQUEST['second_action']=='find_duplicate' 查重合并
            header("Location: index.php?action=FindDuplicateRecords&module=$module");
        }
	}
} elseif ($mode == 'mergefields') {
	$theme_path="themes/".$theme."/";
	$image_path=$theme_path."images/";

	$idstring=vtlib_purify($_REQUEST['passurl']);
	$parent_tab=getParentTab();

    if($idstring=='all'){
        $storearray = getSelectedRecords($_REQUEST, $module, 'all',$_REQUEST['excludedRecords']);
        $idstring = implode(',',$storearray).',';
    }
    crm_load_class_file('cls_FieldMerge','include/Functions');
    $objFieldMerge = new cls_FieldMerge($module);
    $permit_result = $objFieldMerge->judgePermit($idstring);

	$smarty = new lingdangCRM_Smarty;
	$smarty->assign("EDIT_DUPLICATE",$permit_result['permit']);

    if(!empty($permit_result['ids'])){
        $all_values_array = $objFieldMerge->getRecordValues($permit_result['ids']);
    }else{
        $all_values_array = array();
    }
	$all_values=$all_values_array[0];
	$js_arr_val=$all_values_array[1];
	$fld_array=$all_values_array[2];
	$js_arr=implode(",",$js_arr_val);

	
	$smarty->assign("MOD", $mod_strings);
	$smarty->assign("APP", $app_strings);
	$smarty->assign("RECORD_COUNT",count($permit_result['ids']));
	$smarty->assign("THEME", $theme);
	$smarty->assign("IMAGE_PATH", $image_path);
	$smarty->assign("MODULENAME", $module);
	$smarty->assign("PARENT_TAB", $parent_tab);
	$smarty->assign("JS_ARRAY", $js_arr);
	$smarty->assign("ID_ARRAY", $permit_result['ids']);
	$smarty->assign("IDSTRING",$idstring);
	$smarty->assign("ALLVALUES", $all_values);
	$smarty->assign("FIELD_ARRAY", $fld_array);
	$smarty->assign("IMPORTED_RECORDS", $imported_records);
	$smarty->assign("NO_EXISTING", $no_existing);
    //editor:gyq_72  date:20180710	0034508: 客户、联系人、服务收费管理列表界面>更多>自动查重合并>选择字段查重>勾选单据合并：合并单据后应该回到查重界面而不是跳转到单据列表界面去。
    $smarty->assign("SECOND_ACTION", $_REQUEST['second_action']);
    $_REQUEST['diony']='diony';
    $arr['title']=getFixedLabel("MERGERECORDSIN").'>'.getTranstab($module);
    $arr['oktext']=getFixedLabel("Merge");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $str=$smarty->fetch("Functions/field_merge.tpl");
    $arr['content']=$str;
    ConvertTojsonString(1,$arr,"success");
}

?>