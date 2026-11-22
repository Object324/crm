<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
/*
edit:duan
date:2022-5-12
reason:编辑推进权限和任务信息弹出层
*/
$smarty=new lingdangCRM_Smarty();
$advanceid = $_REQUEST['advanceid'];
$arr = array();
//获取推进的角色权限和基本设置信息
$sql = "SELECT tabid,stagename,stagename_target,autopush,fieldname,profileid,userid,userfieldid,taskdescription from ld_advancepicklist where advanceid = ?;";
$result = $adb->pquery($sql,array($advanceid));
if($adb->num_rows($result)>0){
    $tabid = $adb->query_result($result,0,'tabid'); //模块id
    $stagename_start = $adb->query_result($result,0,'stagename');//起始阶段
    $stagename_target = $adb->query_result($result,0,'stagename_target');//目标阶段
    $autopush = $adb->query_result($result,0,'autopush');//是否任务完成后自动推进
    $fieldname = $adb->query_result($result,0,'fieldname');//追踪字段，选择必填字段时排除在外
    $profileid = $adb->query_result($result,0,'profileid');//角色权限id
    $userid = $adb->query_result($result,0,'userid');//用户id
    $userfieldid = $adb->query_result($result,0,'userfieldid');//用户字段id
    $taskdescription = $adb->query_result($result,0,'taskdescription');// 任务描述
}else{
    ConvertTojsonString(-1,$arr,"success");
}
$smarty->assign('STAGENAME_START',$stagename_start);
$smarty->assign('STAGENAME_TARGET',$stagename_target);
$smarty->assign('ADVANCEID',$advanceid);
$smarty->assign('AUTOPUSH',$autopush);
$smarty->assign('TaskDescription',$taskdescription);
//获取权限相关设置信息
$profileid_arr=explode(',',trim($profileid));//指定角色
if(sizeof($profileid_arr)>0){
    $profile = new Profile();
    foreach($profileid_arr as $tmp_profileid)
    {
        $profileinfo = $profile->getProfileinfo($tmp_profileid);
        $profilename_arr[] = $profileinfo['profilename'];
    }
    $smarty->assign('PROFILENAME',implode(',',$profilename_arr));
    $smarty->assign('PROFILEID',$profileid);
}

$userid_arr=explode(',',trim($userid));//指定用户
if(sizeof($userid_arr)>0){
    foreach($userid_arr as $tmp_userid){
        $username_arr[] = getUserFullName($tmp_userid);
    }
    $smarty->assign('USERNAME',implode(',',$username_arr));
    $smarty->assign('USERID',$userid);
}

$smarty->assign('USERFIELDID',explode(',',$userfieldid));//用户字段

$module = getTabname($tabid);
$focus = CRMEntity::getInstance($module);
$fieldobjs=$focus->fieldobj->getModuleFields();
//四种任务类型对应翻译
$Tasktype_arr = array('field'=>getFixedLabel('FieldTasks'),'module'=>getFixedLabel('CREATERECORD'),
                        'select'=>getFixedLabel('SELECTTYPE').'('.getFixedLabel('PickList').')',
                        'checkbox'=>getFixedLabel('CHECKTYPE').'('.getFixedLabel('CHECK_BOX').')',
                        'validata'=>getFixedLabel('CheckValidataRules'));
//获取推进关系的任务详细信息
$sql = "SELECT * from ld_advancepicklisttask where advanceid = ? order by task_sequence, sequence asc";
$result = $adb->pquery($sql,array($advanceid));
$num_row = $adb->num_rows($result);
$fieldid_arr = array();
$fieldilabel_arr = array();
$AdvanceTaskInfoArr = array();
$Tasklabel_withTaskid = array();// 记录任务内容对应的taskid
$TaskInfoArr = array('field'=>[''=>''],'module'=>[''=>''],'select'=>[''=>''],'checkbox'=>[''=>''],'validata'=>[''=>'']);

for($i=0;$i<$num_row;$i++){
    $taskid = $adb->query_result($result,$i,'taskid');
    $type = $adb->query_result($result,$i,'type');
    $tasklabel = $adb->query_result($result,$i,'tasklabel');
    $sequence = $adb->query_result($result,$i,'sequence');
    $completerequest = $adb->query_result($result,$i,'completerequest');
    $presence = $adb->query_result($result,$i,'presence');
    $task_sequence = $adb->query_result($result,$i,'task_sequence');
    $effect_range = $adb->query_result($result,$i,'effect_range');
    $approve_demand = $adb->query_result($result,$i,'approve_demand');
    $tmp_arr = array(
        'taskid'=>$taskid,
        'tasklabel'=>$tasklabel,
        'completerequest'=>$completerequest,
        'sequence'=>$sequence,
        'presence'=>$presence,
        'effect_range'=>$effect_range,
        'approve_demand'=>$approve_demand,
    );

    if($type == 'select'){
        $query = "select selectinfo from ld_advancepicklist_selectinfo where taskid = ? order by sequence";
        $result_list = $adb->pquery($query,array($taskid));
        $num_row_list = $adb->num_rows($result_list);
        $listvaluearr = array();
        for($j=0;$j<$num_row_list;$j++){
            $tmp_selectinfo = $adb->query_result($result_list,$j,'selectinfo');
            if(trim($tmp_selectinfo)!=""){
                $listvaluearr[] = $tmp_selectinfo;
            }
        }
        $tmp_arr['selectinfo'] = $listvaluearr;
    }
    if($type == 'field'){
        $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('fieldname',$tasklabel);
        if($fieldinfo){
            $fieldname_arr[] = $tasklabel;
            $tmp_arr['fieldlabel'] = $fieldinfo->getFieldLabelKey();
        }
    }
    if($type == 'validata'){
        $tmp_query = "select rulename from ld_validatasavemain where id = ? order by sequence";
        $tmp_result = $adb->pquery($tmp_query,[$tasklabel]);
        if($adb->num_rows($tmp_result)>0){
            $tmp_arr['showlabel'] = $adb->query_result($tmp_result,0,'rulename');
        }
    }
    $AdvanceTaskInfoArr[$task_sequence]['tasktype'] = $type;
    $AdvanceTaskInfoArr[$task_sequence]['typelabel'] = $Tasktype_arr[$type];
    $AdvanceTaskInfoArr[$task_sequence][$type][] = $tmp_arr;

    if($type == 'select'){
        $tmp_TaskInfoArr[$task_sequence][$type] = $listvaluearr;
    }else if($type == 'module'){
        $tmp_TaskInfoArr[$task_sequence][$type][] = getTabid($tasklabel);
    }else{
        $tmp_TaskInfoArr[$task_sequence][$type][] = $tasklabel;
    }

    $Tasklabel_withTaskid[$task_sequence][$taskid] = $tasklabel;// taskid与tasklabel对应关系
}
if(empty($AdvanceTaskInfoArr)){// 任务内容为空时，组装一个只包含任务类型和翻译的数组，以此默认生成四行
    foreach ($Tasktype_arr as $type => $label) {
        $AdvanceTaskInfoArr[] = array('tasktype' => $type,'typelabel' => $label);
    }

}else{
    $AdvanceTaskInfoArr = array_values($AdvanceTaskInfoArr);// 重置数组的索引
    $tmp_TaskInfoArr = array_values($tmp_TaskInfoArr);// 重置数组的索引

    foreach ($tmp_TaskInfoArr as $seq => $taskinfoarr) {
        $tmp_tasktype = array_keys($taskinfoarr)[0];
        $TaskInfoArr[$tmp_tasktype][$seq] = implode('##',$taskinfoarr[$tmp_tasktype]).'##';
    }

    $Tasklabel_withTaskid = array_values($Tasklabel_withTaskid);
}

$smarty->assign('ADVANCETASKINFO',$AdvanceTaskInfoArr);
$arr['TaskInfoArr'] = $TaskInfoArr;
$arr['Tasklabel_withTaskid'] = $Tasklabel_withTaskid;

//当前模块的用户字段
$select_approve_type = array();
foreach($fieldobjs as $fieldname=>$fieldinfo)
{
    $columnname=$fieldinfo->getColumnName();
    $fieldname = $fieldinfo->getFieldName();
    $fieldlabel=$fieldinfo->getFieldLabel();
    $fieldid = $fieldinfo->getFieldid();
    $bigtype=$fieldinfo->getBigType();
    if($fieldinfo->getSaveDataBase()=='no'||$fieldinfo->isRelatedModuleField())
        continue;
    //单选用户字段和多选用户字段
    if($fieldinfo->getUIType() == 153 || $fieldinfo->getUIType() == 154){
    	$select_userfield_type[$fieldid] = $fieldlabel;
    }
    //负责人字段和创建人字段
    if($fieldinfo->getUIType() == 53 || $fieldinfo->getUIType() == 52){
    	$select_userfield_type[$fieldid] = $fieldlabel;
    }
    //获取必填字段的中英文翻译
    if(is_array($fieldname_arr) && in_array($fieldname,$fieldname_arr)){
        $fieldlabel_arr[$fieldname] = $fieldlabel;
    }
}
$smarty->assign('SELECT_USERFIELD_TYPE',$select_userfield_type);
$smarty->assign('FROMMODULE',$module);
//考虑到排序的问题，需要对字段翻译重新进行排序
$fieldlabel_str = '';
foreach($fieldname_arr as $key=>$tmp_fieldname){
    if(empty($fieldlabel_str)){
        $fieldlabel_str = $fieldlabel_arr[$tmp_fieldname];
    }else{
        $fieldlabel_str .= ','.$fieldlabel_arr[$tmp_fieldname];
    }
}

$smarty->assign('TASKTYPEARR',$Tasktype_arr);

$content = $smarty->fetch('Settings/EditAdvanceRelationInfo.tpl');

$_REQUEST['diony']='diony';
$arr['content'] = $content;
$arr['title'] = getFixedLabel('CONFIGURATIONTASKANDUSER');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
ConvertTojsonString(1,$arr,"success");
?>