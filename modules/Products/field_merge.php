<?php
/**
 * Created by PhpStorm.
 * Eidtor:gyq_65 Reason:原查重合并改为合并 Date:2018/3/27 0027 下午 3:09
 * Date: 2018/3/27 0027
 * Time: 下午 3:09
 */

$module = vtlib_purify($_REQUEST['module']);
global $mod_strings, $app_strings, $app_list_strings;
global $current_language, $currentModule, $theme;
global $adb;
$focus = CRMEntity::getInstance($module);
$mode = $_REQUEST['mergemode'];
if($mode == 'mergesave') {
    
    $return_module=vtlib_purify($_REQUEST['return_module']);
    $action=vtlib_purify($_REQUEST['action']);
    $return_action=vtlib_purify($_REQUEST['return_action']);
    $parenttab=vtlib_purify($_REQUEST['parent']);
    $merge_id=vtlib_purify($_REQUEST['record']);
    $recordids=vtlib_purify($_REQUEST['pass_rec']);
    $result =  $adb->pquery('SELECT count(1) AS count FROM '.$focus->table_name.' WHERE '.$focus->table_index.'=? and deleted=0 ', array($merge_id));
    $count = $adb->query_result($result,0,'count');
    // $nums = $adb->num_rows($result);
    // for($i = 0;$i < $nums;$i++){
    //     $arr_tmp[] = $count = $adb->query_result($result,0,'count');
    // }
    // dump($arr_tmp);
    $_REQUEST['ajxaction']='fieldmergersave';
    if($count > 0)
    {
        // First, save the primary record
        $focus->mode="edit";
        $focus->retrieve_entity_info($merge_id,$module);//edit:can reason:12740: 客户叙事簿界面：查重合并后，客户编号被清空了
        setObjectValuesFromRequest($focus);

        //editor:gyq_20180914	0035230: （http://ynszkj.ldcrm.net:85/crm [^]）客户列表界面：客户模块做“自动查重合并”后，在客户列表里就找不到了这些客户，在首页快速查找里是有的.
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
       
		//44872: （61mis.com/kfbcrm）查重合并功能；客户管理-客户，客户模块查重合并时，“标签”的信息没有合并
		if($merge_id != $_REQUEST['tag']){
			$query = "delete from ld_moduledata_tag where record = ?";
			$adb->pquery($query,array($merge_id));
			$query = "update ld_moduledata_tag set record = ? where record = ?";
			$adb->pquery($query,array($merge_id,$_REQUEST['tag']));
		}
        
        // Delete the records by id specified in the list
        foreach($del_value as $value)
        {
            DeleteEntity($_REQUEST['module'],$_REQUEST['return_module'],$focus,$value,"","yes");
        }
        //BUG20240311-01 ls 20240315 产品物料合并后，物料编码不是按照合并规则合并，而是重新生成了一个新的物料号。(被合并的单据此时还没有被删除，所以单号会重建，需要下移至此)
        $focus->save($module);
        //editor:gyq_72  date:20180710	0034508: 客户、联系人、服务收费管理列表界面>更多>自动查重合并>选择字段查重>勾选单据合并：合并单据后应该回到查重界面而不是跳转到单据列表界面去。
        //editor:gyq_170 reason:自动查重合并返回值修改  2020/3/9 15:44 
       
        if($_REQUEST['second_action']=='merge'){ //合并
            $_REQUEST['diony']='yes';
            ConvertTojsonString(1,array(),"success");
        }else{//$_REQUEST['second_action']=='find_duplicate' 查重合并
            $_REQUEST['diony']='yes';
            ConvertTojsonString(1,$_REQUEST,"success");
            //header("Location: index.php?action=FindDuplicateRecords&module=$module");
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
    $arr['title']=getFixedLabel("MERGERECORDSIN");
    $arr['oktext']=getFixedLabel("Merge");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $str=$smarty->fetch("Functions/field_merge.tpl");
    $arr['content']=$str;
    ConvertTojsonString(1,$arr,"success");
}

?>