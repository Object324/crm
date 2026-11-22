<?php 
global $adb,$current_user;
$modulename = $_REQUEST['modulename'];
$record = $_REQUEST['record'];
crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance = new cls_module_advance($modulename);
$stagename_now = $cls_module_advance->getStagenameNow($record);
$before_taskresult = $cls_module_advance->TaskCompleteCheck($record,'');
$tasktype = $_REQUEST['tasktype'];
$taskid = $_REQUEST['taskid'];
//复选框无法获取按钮状态，特殊处理
if($tasktype=='checkbox'){
    $tasklog = $cls_module_advance->getTasklogbyrecord($record,$stagename_now);
    if(isset($_REQUEST['answer'])&&$_REQUEST['answer']!=''){
        $taskresult = $_REQUEST['answer'];
        if($tasklog[$taskid]['taskresult']==$taskresult){
            $taskresult = 'chebox_empty';
        }
    }else{
        if($tasklog[$taskid]['effective']=='yes'){
            $taskresult = 'no';
        }else{
            $taskresult = 'yes';
        }    
    }
}else{
    $taskresult = $_REQUEST['answer'];  
}
if($taskresult=='chebox_empty'&&$tasktype=='checkbox'){//复选框取消勾选时删除任务记录
    $delete_sql_tasklog = "delete from ld_advancepicklistlog where taskid=? and record =?";
    $adb->pquery($delete_sql_tasklog,array($taskid,$record));
}else{
    //插入记录
    $insert_sql_tasklog = "insert into ld_advancepicklistlog(taskid,record,taskresult,smcreatorid,createdtime) values(?,?,?,?,?)";
    $adb->pquery($insert_sql_tasklog,array($taskid,$record,$taskresult,$current_user->id,date('Y-m-d H:i:s')));
}
unset($cls_module_advance->stagement_timearr);
unset($cls_module_advance->allTasklog);

//判断是否需要自动推进
$TaskcheckResult_arr = $cls_module_advance->TaskCompleteCheck($record,'');

//在任务完成后才能推进的条件下：任务完成后，需要更新按钮状态时，刷新页面
$arr['push_success'] = $TaskcheckResult_arr['push_success'];
if($TaskcheckResult_arr['push_success']!='yes'){
    $arr['advancestage'] = $cls_module_advance->getWeiXin($record);
}


$_REQUEST['diony']='diony';
ConvertTojsonString(1,$arr,"success");

?>