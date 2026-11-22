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
crm_load_class_file('cls_FieldMerge','include/Functions');
$objFieldMerge = new cls_FieldMerge($module);
if($mode == 'mergesave') {

    $return_module=vtlib_purify($_REQUEST['return_module']);
    $action=vtlib_purify($_REQUEST['action']);
    $return_action=vtlib_purify($_REQUEST['return_action']);
    $parenttab=vtlib_purify($_REQUEST['parent']);
    $merge_id=vtlib_purify($_REQUEST['record']);
    $recordids=vtlib_purify($_REQUEST['pass_rec']);
    $result =  $adb->pquery('SELECT count(1) AS count FROM '.$focus->table_name.' WHERE '.$focus->table_index.'=? and deleted=0 ', array($merge_id));
    $count = $adb->query_result($result,0,'count');
    $_REQUEST['ajxaction']='fieldmergersave';

    if($count > 0)
    {
        // First, save the primary record
        $focus->mode="edit";
        $focus->id=$merge_id;
        $focus->retrieve_entity_info($merge_id,$module);//edit:can reason:12740: 客户叙事簿界面：查重合并后，客户编号被清空了
        setObjectValuesFromRequest($focus);


        //wym 合并两表后要把对应模块的关联多选字段中的值更新
        update_multi($module,$recordids,$merge_id);
        //editor:gyq 20180809 	0034753: （1.6登录）客户模块：合并弹出层中应显示“是否公海”字段
        //editor:gyq_20180914	0035230: （http://ynszkj.ldcrm.net:85/crm [^]）客户列表界面：客户模块做“自动查重合并”后，在客户列表里就找不到了这些客户，在首页快速查找里是有的.
        if($module=='Accounts' && isset($_REQUEST['publicaccount'])){
            $sql_update = 'update ld_account set publicaccount=? where accountid=?';
            $adb->pquery($sql_update,array($_REQUEST['publicaccount'],$merge_id));
        }
        $del_value=explode(",",$recordids,-1);
        $offset = array_search($merge_id,$del_value);
        unset($del_value[$offset]);

        $sql='update ld_singin set record=?,accountid=?,entityname=? where record in( '.implode(',',$del_value).')';

        $adb->pquery($sql,array($merge_id,$merge_id,$focus->column_fields[$focus->list_link_field]));

        $rec_values=$focus->column_fields;
        // Remove the id of primary record from the list of records to be deleted.



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

        //38453: （51,mis.com/kfbcrm）客户合并后，其他相关信息可以合并，但是签到记录不会合并，只会保留主记录的签到数据。预期结果：签到记录也应该可以合并

		//44872: （61mis.com/kfbcrm）查重合并功能；客户管理-客户，客户模块查重合并时，“标签”的信息没有合并
		if($merge_id != $_REQUEST['tag']){
			$query = "delete from ld_moduledata_tag where record = ?";
			$adb->pquery($query,array($merge_id));
			$query = "update ld_moduledata_tag set record = ? where record = ?";
			$adb->pquery($query,array($merge_id,$_REQUEST['tag']));
		}
        
        // 合并后，将被删除记录的单据负责人自动添加到主记录团队成员中
        $add_teammember = 'no';
        if(isset($_REQUEST['add_teammember']) && !empty($_REQUEST['add_teammember'])){
            $add_teammember = $_REQUEST['add_teammember'];
            setUsersettingByLabel($module,$current_user->id,'AfterMergeAddToTeamMember',$add_teammember);
        }
        if($add_teammember == 'yes'){
            $objFieldMerge->addTeamMember($focus,$merge_id,$del_value);
        }
        
        // Delete the records by id specified in the list
        foreach($del_value as $value)
        {
            DeleteEntity($_REQUEST['module'],$_REQUEST['return_module'],$focus,$value,"","yes");
        }
        //duan 20240426 删除次要单据后再进行保存,避免单据编号重复的问题
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

    $mergetype = '';
    if(isset($_REQUEST['mergetype']) && !empty($_REQUEST['mergetype'])){
        $mergetype = $_REQUEST['mergetype'];
    }

    if($idstring=='all'){
        $storearray = getSelectedRecords($_REQUEST, $module, 'all',$_REQUEST['excludedRecords']);
        $idstring = implode(',',$storearray).',';
    }

    $permit_result = $objFieldMerge->judgePermit($idstring);
    $smarty = new lingdangCRM_Smarty;
    $smarty->assign("EDIT_DUPLICATE",$permit_result['permit']);
    if(!empty($permit_result['ids'])){
        $all_values_array = $objFieldMerge->getRecordValues($permit_result['ids']);
    }else{
        $all_values_array = array();
    }
    if($mergetype == 'bigmerge'){
        
        $bigmerge_all_values = $all_values_array[4];
        $multifields_value = $objFieldMerge->getMultiFieldsValue($bigmerge_all_values);
        $smarty->assign("ALLVALUES", $bigmerge_all_values);
        
        $arr["multifields_value"] = $multifields_value;

    }else{
        $all_values=$all_values_array[0];
        $js_arr_val=$all_values_array[1];
        $fld_array=$all_values_array[2];
        $js_arr=implode(",",$js_arr_val);

        $smarty->assign("JS_ARRAY", $js_arr);
        $smarty->assign("ALLVALUES", $all_values);
        $smarty->assign("FIELD_ARRAY", $fld_array);
    }

    $params_arr = $all_values_array[3];
    $bigtype_arr = $objFieldMerge->getFieldBigtypes($params_arr);
    $arr["params_arr"] = $params_arr;
    $arr["bigtype_arr"] = $bigtype_arr;

    // 当前用户之前一次的选择
    $pre_settings = getUsersettingByLabel($module,$current_user->id,'AfterMergeAddToTeamMember');
    if(!empty($pre_settings)){
        $add_teammember = $pre_settings=='yes'?'checked':'';
    }else{
        $add_teammember = 'checked';
    }
    $smarty->assign("AddTeamMemberChecked", $add_teammember);

    $smarty->assign("MOD", $mod_strings);
    $smarty->assign("APP", $app_strings);
    $smarty->assign("RECORD_COUNT",count($permit_result['ids']));
    $smarty->assign("THEME", $theme);
    $smarty->assign("IMAGE_PATH", $image_path);
    $smarty->assign("MODULENAME", $module);
    $smarty->assign("PARENT_TAB", $parent_tab);
    $smarty->assign("ID_ARRAY", $permit_result['ids']);
    $smarty->assign("IDSTRING",$idstring);
    $smarty->assign("IMPORTED_RECORDS", $imported_records);
    $smarty->assign("NO_EXISTING", $no_existing);
    //editor:gyq_72  date:20180710	0034508: 客户、联系人、服务收费管理列表界面>更多>自动查重合并>选择字段查重>勾选单据合并：合并单据后应该回到查重界面而不是跳转到单据列表界面去。
    $smarty->assign("SECOND_ACTION", $_REQUEST['second_action']);
    $smarty->assign("mergetype", $mergetype);

    $_REQUEST['diony']='diony';
    $arr['title']=getFixedLabel("MERGERECORDSIN");
//    $arr['title']=getFixedLabel("MERGERECORDSIN").'>'.getTranstab($module);
//    if(!empty($mergetype)){
//        if($mergetype == 'bigmerge'){
//            $tmp_tips = getFixedLabel("PRIMARRECORDMERGE2");
//        }else{
//            $tmp_tips = getFixedLabel("PRIMARRECORDMERGE");
//        }
//        $titlehtml = '<span class="gray" style="font-size:12px">（'.$tmp_tips.'）</span>';
//        $arr['title'] .= $titlehtml;
//    }
    $arr['oktext']=getFixedLabel("Merge");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $str=$smarty->fetch("Functions/field_merge.tpl");
    $arr['content']=$str;
    ConvertTojsonString(1,$arr,"success");
}

function  update_multi($module,$recordids,$merge_id){
    global $adb;
    $array=explode(",", rtrim($recordids,","));
    if (($key = array_search($merge_id, $array)) !== false) {
        unset($array[$key]);
    }
    $update_recordids = $array;

    $multi_uitypes_arr = cls_module_uitype::getModuleAllUtitype_multi($module);
    $multi_uitypes = !empty($multi_uitypes_arr)?implode(',', $multi_uitypes_arr):'';
    if(!empty($multi_uitypes)){
        //字段启用 删除模块
        $sql = 'SELECT tablename,columnname FROM ld_field where uitype in ('.$multi_uitypes.') and presence in (0,2)';
        $result = $adb->pquery($sql);
        $num_rows = $adb->num_rows($result);
        for($i=0;$i<$num_rows;$i++){
            $multi_tablename = $adb->query_result($result, $i, 'tablename');
            $multi_columnname = $adb->query_result($result, $i, 'columnname');
            // 更新查询
            foreach ($update_recordids as $update_recordid){
                $sql = "UPDATE $multi_tablename SET $multi_columnname = CASE 
                    WHEN FIND_IN_SET($merge_id,$multi_columnname) THEN TRIM(BOTH ',' FROM REPLACE(CONCAT(',',$multi_columnname, ','), ',$update_recordid,', ','))
                    ELSE REPLACE($multi_columnname,$update_recordid,$merge_id)
                    END";
                $adb->pquery($sql);
            }
        }
    }
}
?>