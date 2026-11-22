<?php 
global $smarty;
$modulename = $_REQUEST['modulename'];
$record = $_REQUEST['record'];
$stagename = $_REQUEST['stagename'];

crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance = cls_module_advance::getInstance($modulename);

//更新任务日志
if(!empty($_REQUEST['complete_task'])&&$_REQUEST['complete_task']=="yes"){//完成任务
    global $adb,$current_user;
    $tasktype = $_REQUEST['tasktype'];
    $taskresult = $_REQUEST['taskresult'];
    $taskid = $_REQUEST['taskid'];
    if($taskresult=='chebox_empty'&&$tasktype=='checkbox'){//复选框取消勾选时删除任务记录
        $delete_sql_tasklog = "delete from ld_advancepicklistlog where taskid=? and record =?";
        $adb->pquery($delete_sql_tasklog,array($taskid,$record));
    }else{
        $insert_sql_tasklog = "insert into ld_advancepicklistlog(taskid,record,taskresult,smcreatorid,createdtime) values(?,?,?,?,?)";
        $adb->pquery($insert_sql_tasklog,array($taskid,$record,$taskresult,$current_user->id,date('Y-m-d H:i:s')));
    }
    $TaskcheckResult_arr = $cls_module_advance->TaskCompleteCheck($record,'');
    $arr['push_success'] = $TaskcheckResult_arr['push_success'];
}else if(!empty($_REQUEST['pushcheck'])&&$_REQUEST['pushcheck']=="yes"){//判断当前阶段能否向前推进
    $stagename_target = $_REQUEST['stagename_target'];

    $TaskcheckResult_arr = $cls_module_advance->TaskCompleteCheck($record,$stagename_target);
    $return_msg = implode('<br>',(array)$TaskcheckResult_arr['errormsg_arr'][$stagename_target]);

    $arr['allow_push'] = $TaskcheckResult_arr['allow_push'][$stagename_target];
    $arr['confirm_save'] = 'no';
    if($arr['allow_push'] == 'yes' && $return_msg != ''){
        $arr['confirm_save'] = 'yes';
    }
    $arr['return_msg'] = $return_msg;
}else if(!empty($_REQUEST['refresh_moduletask'])&&$_REQUEST['refresh_moduletask']=="yes"){

    $stagename_now = $cls_module_advance->getStagenameNow($record);
    //判断当前阶段是否发生了变化
    $arr['refresh_detailviewpage'] = 'no';
    if($stagename_now != $_REQUEST['stagename_now']){
        $arr['refresh_detailviewpage'] = 'yes';
    }else{
        $frommodule = $_REQUEST['frommodule'];
        $fromrecord = $_REQUEST['fromrecord'];
        $advanceid = $_REQUEST['advanceid'];

        $all_taskinfo_arr = $cls_module_advance->getadvancetask();
        $tmp_taskinfo_arr = $all_taskinfo_arr[$advanceid];
        $tmp_taskid = 0;
        $effect_range = '';
        foreach($tmp_taskinfo_arr['taskvalue'] as $taskinfo){
            if($taskinfo['type']=='module'&&$taskinfo['tasklabel']==$frommodule){
                $tmp_taskid = $taskinfo['taskid'];
                $effect_range = $taskinfo['effect_range'];
                break;
            }
        }
        if($tmp_taskid >0){

            $all_tasklog_arr = $cls_module_advance->getallTasklogbyrecord($record);
            $cur_tasklog_arr = $all_tasklog_arr[$advanceid];
            $cur_tasklog_arr = $cls_module_advance->addAllModuletasklog($tmp_taskinfo_arr['taskvalue'],$cur_tasklog_arr,$record);

            $tmp_tasklog_arr = $cur_tasklog_arr[$tmp_taskid];
            $record_no_arr = $tmp_tasklog_arr['record_no_arr'];

            if(!empty($record_no_arr)){
                $task_content = '<div class="advance_showrecord">';
                foreach ($record_no_arr as $tmp_key=>$tmp_record_arr){
                    if($tmp_key>0)$task_content.=',';
                    $task_content .= '<a module="'.$frommodule.'" record="'.$tmp_record_arr['crmid'].'" 
                  href="index.php?pageto_module='.$frommodule.'&pageto_action=index&pageto_record='.$tmp_record_arr['crmid'].'" 
                  onclick="ListLinkClick(ld(this),event)"  title="'.$tmp_record_arr['record_no'].'">'.$tmp_record_arr['record_no'].'</a>';

                }
                if($effect_range == 'sum' || true){
                    $task_content .=" <a title='".getFixedLabel('LBL_Creates')."' href='javascript:void(0);'
                     onclick=".'"'."related_add_url('index.php?module=$frommodule&action=EditView&return_module=$frommodule&return_action=DetailView&relatedcreate=yes&Create=true&frommodule=$modulename&fromid=$record&parent_id=$record&potential_id=$record','$modulename','$frommodule','$record')".'"'."
                         modulename='$modulename' stagename='$stagename_now'  tasktype='module' record='$record' taskid='$tmp_taskid'><span>".getFixedLabel('LBL_Creates')."</span></a>";
                }
                $task_content .= '</div>';

            }else{
                $task_content = getFixedLabel('NOCREATED').",<a title='".getFixedLabel('LBL_Creates')."' href='javascript:void(0);'
                     onclick=".'"'."related_add_url('index.php?module=$frommodule&action=EditView&return_module=$frommodule&return_action=DetailView&relatedcreate=yes&Create=true&frommodule=$modulename&fromid=$record&parent_id=$record&potential_id=$record','$modulename','$frommodule','$record')".'"'."
                         modulename='$modulename' stagename='$stagename_now'  tasktype='module' record='$record' taskid='$tmp_taskid'><span>".getFixedLabel('LBL_Creates')."</span></a>";
            }
            $arr['task_content'] = $task_content;
        }
    }
}

$_REQUEST['diony']='diony';
ConvertTojsonString(1,$arr,"success");
exit();
?>