<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$smarty=new lingdangCRM_Smarty;
$tasktype = $_REQUEST['tasktype'];
$stagenum = $_REQUEST['stagenum'];
$module = $_REQUEST['modulename'];
if(!empty($_REQUEST['taskmode'])){
    $taskmode = $_REQUEST['taskmode'];
}else{
    //切换任务类型时先清除原任务信息
    $smarty->assign('stagenum',$stagenum);
    $smarty->assign('type',$tasktype);
    $smarty->assign('FROMMODULE',$module);
    $str=$smarty->fetch('Settings/advancetaskinfo.tpl');
    $arr['content']=$str;
}
//任务设置界面
if($taskmode=='edit'||$taskmode=='create'){
    $stagename = $_REQUEST['stagename'];
    if($tasktype == 'module'){
        $tabid=getTabid($_REQUEST['modulename']);
        if($tabid==16){
            $tabid=9;
        }
        if($taskmode=='edit'){
            $modulestr = $_REQUEST['modulestr'];
            $modulearr = explode(',',(string)$modulestr);
        }
        $other_modulestr = $_REQUEST['other_modulestr'];// 已被其他任务选择的模块
        $other_module_arr = explode('##',(string)$other_modulestr);

        $sql="SELECT related_tabid from ld_relatedlists where tabid=? and actions = 'add' ORDER BY sequence";
        $result=$adb->pquery($sql,array($tabid));
        $nums=$adb->num_rows($result);
        $related_module_selected=array();
        $relation_tabid_arr = getRelationPresence($module);
        for($i=0;$i<$nums;$i++)
        {
            //只选择带单据的相关信息
            $related_tabid = $adb->query_result($result,$i,'related_tabid');
            $presence = 1;
            if($taskmode=='edit' && in_array(getTabname($related_tabid),$modulearr)){
                $presence = 0;
            }
    		$key = $related_tabid;
            $related_module = getTabname($related_tabid);
            // 排除已被其他任务选择的字段
            if(in_array($related_tabid,$other_module_arr)){
                continue;
            }
            if(vtlib_isModuleActive(getTabname($related_tabid))&&in_array($related_tabid,$relation_tabid_arr)){
                $related_module_selected[$presence][$key] = getTranstab($related_module);
            }
        }
        if(is_array($modulearr) && sizeof($modulearr)>0&&!empty($modulearr[0])){
            foreach($modulearr as $value){
                $selected_module[getTabid($value)]=getTranstab($value);
            }
        }
        if(isset($_REQUEST['approve_demand'])){
            $approve_demand = $_REQUEST['approve_demand'];
        }else{
            $approve_demand = 'no';
        }
        if(isset($_REQUEST['effect_range'])){
            $effect_range = $_REQUEST['effect_range'];
        }else{
            $effect_range = 'getlast';
        }

        $smarty->assign('related_modules',$related_module_selected[1]);
        $smarty->assign('related_module_selected',$selected_module);
        $smarty->assign('approve_demand',$approve_demand);
        $smarty->assign('effect_range',$effect_range);
        $smarty->assign('tabid',$tabid);
        $smarty->assign('modulename',$module);
    	// $arr['title']=getFixedLabel('CREATERECORDTASK');
    }else if($tasktype == 'field'){
        //当前模块的用户字段
        $select_fieldnamestr = $_REQUEST['fieldnamestr'];
        $select_fieldname_arr = explode(',',$select_fieldnamestr);
        $other_fieldnamestr = $_REQUEST['other_fieldnamestr'];// 已被其他任务选择的字段
        $other_fieldname_arr = explode('##',$other_fieldnamestr);
        $focus = CRMEntity::getInstance($module);
        $fieldobjs=$focus->fieldobj->getModuleFields();
        foreach($fieldobjs as $fieldname=>$fieldinfo)
        {
            $columnname=$fieldinfo->getColumnName();
            $fieldlabel=$fieldinfo->getFieldLabel();
            $fieldname = $fieldinfo->getFieldName();
            $fieldid = $fieldinfo->getFieldid();
            $bigtype = $fieldinfo->getBigType();
            $displaytype = $fieldinfo->getDisplaytype();
            if($fieldinfo->getSaveDataBase()=='no')
                continue;
            //引用字段和手写签名字段不能设置为任务
            if($fieldinfo->isRelatedModuleField()||$bigtype=='handwriting'){
                continue;
            }
            //筛选出不允许编辑的字段
            if($displaytype!=1 || $fieldinfo->get_allowedit()!='yes'){
                continue;
            }
            // 排除已被其他任务选择的字段
            if(in_array($fieldname,$other_fieldname_arr)){
                continue;
            }
            if(in_array($fieldname,$select_fieldname_arr)){
                $actions_arr_used[$fieldname] = $fieldlabel;
            }else{
                $actions_arr[$fieldname] = $fieldlabel;
            }
        }
        if(isset($_REQUEST['effect_range'])){
            $effect_range = $_REQUEST['effect_range'];
        }else{
            $effect_range = 'getlast';
        }
        $smarty->assign('effect_range',$effect_range);
        $smarty->assign('actions_arr', $actions_arr);
        $smarty->assign('actions_arr_userd',$actions_arr_used);
		$smarty->assign('MODULE',$module);
		$_REQUEST['diony']='diony';
		// $arr['title']=getFixedLabel('Setmandatoryfield');
        $arr['reminds_field'] = getFixedLabel('pleaseenterthecategoryyouarelookingforfield');
    }else if($tasktype == 'checkbox'){
        $alltext = $_REQUEST['alltext'];
        $textarr = explode('##',(string)$alltext);
        $smarty->assign('TEXTARR',$textarr);
        $smarty->assign('countTEXTARR',count($textarr));
    	// $arr['title']=getFixedLabel('CHECKTYPETASK');
    }else if($tasktype == 'select'){
        $allselect = $_REQUEST['allselect'];
        $selecttaskname = $_REQUEST['selecttaskname'];
        $selectarr = explode('##',$allselect);
        $smarty->assign('SELECTTASKNAME',$selecttaskname);
        $smarty->assign('SELECTARR',$selectarr);
        // $arr['title']=getFixedLabel('SELECTEDTYPETASK');    
    }
    $smarty->assign('type',$tasktype);
    //四种任务类型对应翻译
    $Tasktype_arr = array('field'=>getFixedLabel('FieldTasks'),'module'=>getFixedLabel('CREATERECORD'),
                        'select'=>getFixedLabel('SELECTTYPE').'('.getFixedLabel('PickList').')',
                        'checkbox'=>getFixedLabel('CHECKTYPE').'('.getFixedLabel('CHECK_BOX').')');
    $smarty->assign('typelabel',$Tasktype_arr[$tasktype]);
    $arr['title']=getFixedLabel('ADVANCETASK');    

    $str = $smarty->fetch('Settings/Advancetask.tpl');
    $arr['content'] = $str;
}
//任务保存后更新任务信息
if($taskmode=='save'){
    if($tasktype == 'module'){
        $selectedmodule = $_REQUEST['selectedmodule'];
        $selectedmodulearr = explode('##',$selectedmodule);
        $taskvalue = array();
        if(isset($_REQUEST['approve_demand'])){
            $approve_demand = $_REQUEST['approve_demand'];
        }else{
            $approve_demand = 'no';
        }
        if(isset($_REQUEST['effect_range'])){
            $effect_range = $_REQUEST['effect_range'];
        }else{
            $effect_range = 'getlast';
        }

        foreach($selectedmodulearr as $value)
        {
            if($value=="")
                continue;
            $modulename = getTabname($value);
            $taskinfo = array('type'=>'module','tasklabel'=>$modulename);
            $taskinfo['approve_demand'] = $approve_demand;
            $taskinfo['effect_range'] = $effect_range;
            $modulenamearr[] = $modulename;
            $taskvalue[] = $taskinfo;
        }
    }elseif($tasktype == 'field'){
        $selectedfieldname = $_REQUEST['selectedfieldname'];
        $selectedfieldnamearr = explode('##',$selectedfieldname);
        $fieldlabel_arr = array();
        $fieldid_arr = array();
        $focus = CRMEntity::getInstance($module);
        $fieldobjs=$focus->fieldobj->getModuleFields();
        $select_approve_type = array();
        if(isset($_REQUEST['effect_range'])){
            $effect_range = $_REQUEST['effect_range'];
        }else{
            $effect_range = 'getlast';
        }

        foreach($fieldobjs as $fieldname=>$fieldinfo)
        {
            $fieldlabel=$fieldinfo->getFieldLabel();
            $fieldname = $fieldinfo->getFieldName();
            if(!empty($fieldname)&&in_array($fieldname,$selectedfieldnamearr)){
                $fieldname_arr[] = $fieldname;
                $fieldlabel_arr[] = $fieldlabel;
            }
        }
        $fieldnamestr = implode(',',$fieldname_arr);
        $smarty->assign('effect_range',$effect_range);
        $smarty->assign('fieldnamestr',$fieldnamestr);
        $smarty->assign('fieldlabelstr',implode(',',$fieldlabel_arr));
    }elseif($tasktype == 'checkbox'){
        $checkboxstr = $_REQUEST['checkboxstr'];
        $checkboxarr = explode('##',$checkboxstr);
        $taskvalue = array();
        foreach($checkboxarr as $value)
        {
            if($value=="")
                continue;
            $taskinfo = array('type'=>'module','tasklabel'=>$value);
            $taskvalue[] = $taskinfo;
        }
    }elseif($tasktype='select'){
        $selectstr = $_REQUEST['selectstr'];
        $selecttaskname = $_REQUEST['selecttaskname'];
        $selectarr = explode('##',$selectstr);
        foreach($selectarr as $key=>$value){
            if(trim($value)==""){
                unset($selectarr[$key]);
            }
        }
        $taskvalue = array();
        $taskvalue[] = array(
            'type' => $tasktype,
            'tasklabel' =>$selecttaskname,
            'selectinfo' =>$selectarr
        );
    }
    $smarty->assign('SELECTTASKNAME',$selecttaskname);
    $smarty->assign('taskvalue',$taskvalue);
    $smarty->assign('stagenum',$stagenum);
    $smarty->assign('type',$tasktype);
    $smarty->assign('FROMMODULE',$module);
    $str=$smarty->fetch('Settings/advancetaskinfo.tpl');
    $arr['content']=$str;
}
$_REQUEST['diony']='diony';
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
ConvertTojsonString(1,$arr,"success");
exit();

//判断当前模块和关联模块的关联字段，或选择源单字段是否启用
function getRelationPresence($module){
    global $adb;
    //判断关联选择单据字段是否启用
    $sql = "SELECT GROUP_CONCAT(ld_field.tabid) as all_tabid from ld_ws_fieldtype 
            INNER JOIN ld_ws_referencetype on ld_ws_fieldtype.fieldtypeid = ld_ws_referencetype.fieldtypeid
            INNER JOIN ld_field on ld_field.uitype = ld_ws_fieldtype.uitype
            where  ld_ws_referencetype.type = ? and ld_field.presence in (0,2)
            GROUP BY ld_ws_referencetype.type;";
    $result = $adb->pquery($sql,array($module));
    $num_rows = $adb->num_rows($result);
    $related_tabid_arr = array();
    
    if($num_rows>0){
        $all_tabid = $adb->query_result($result,0,'all_tabid');
        if(!empty($all_tabid)){
            $related_tabid_arr = explode(',',$all_tabid);
        }
    }
    
    //判断选择源单字段以及相关的源单是否启用
    $sql = "SELECT GROUP_CONCAT(ld_field.tabid) as all_tabid_source from ld_field INNER JOIN 
            (select tabid from ld_option_module where option_tabid = ? AND presence in (0,2)) as tmp
            on ld_field.tabid = tmp.tabid AND (bigtype = 'selectsource' or uitype = 112)
            where presence in (0,2) GROUP BY bigtype";
    $result = $adb->pquery($sql,array(getTabid($module)));
    $num_rows = $adb->num_rows($result);
    
    if($num_rows>0){
        for($i=0;$i<$num_rows;$i++){
            $all_tabid_source = $adb->query_result($result,$i,'all_tabid_source');
            if(!empty($all_tabid_source)){
                $related_tabid_arr = array_merge($related_tabid_arr,explode(',',$all_tabid_source));
                $related_tabid_arr = array_unique($related_tabid_arr);
            }
        }
    }
    return $related_tabid_arr;
}

?>