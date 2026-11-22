<?php
/*
edit:duan
date:2021-11-18
reason:工单模块催单，结单，重新打开功能
*/
global $current_user,$adb;
$module = $_REQUEST['module'];
$record = $_REQUEST['record'];
$mode = $_REQUEST['mode'];
$focus = CRMEntity::getInstance($module);
$hour_limit = 2;
$datetime_now = date('Y-m-d H:i:s');

//催单
if($mode=='urged'){    
    $sql = 'select urgedtime,smownerid from '.$focus->table_name.' where '.$focus->table_index.'= ?';
    $result = $adb->pquery($sql,array($record));
    $urgedtime  = $adb->query_result($result,0,'urgedtime');
    $smownerid = $adb->query_result($result,0,'smownerid');
    if(!empty($urgedtime)){
        
        $interval = (strtotime($datetime_now)-strtotime($urgedtime))/3600;//计算两个时间的小时差
        if($interval < $hour_limit){
            $arr['confirmstr'] = getvarFixedLabel('CANOTURGED',$hour_limit).$urgedtime;
            ConvertToJsonString(-1,$arr,'success');
        }
    }
    
    if(isset($_REQUEST['frommodule'])&&$_REQUEST['frommodule']!='Users'){
        $modifiedmodule = $_REQUEST['frommodule'];
        $modifiedby = $_REQUEST['recordid'];
    }else{
        $modifiedmodule = 'Users';
        $modifiedby = $current_user->id;
    }
    
    //催单后将状态更新为已催单，如果已分配服务人员，则向服务人员发送消息提醒；
    $sql = 'update '.$focus->table_name.' set worksheet_status=?,urgedtime=? where '.$focus->table_index.'= ?';
    $focus->db->pquery($sql,array('urged',$datetime_now,$record));
    //添加工单日志
    $focus->saveWorkTrends($record,$modifiedmodule,$modifiedby,'urged');
    //添加消息提醒
    if($smownerid > 0){
         if($modifiedmodule!='Users'){
            $RemindsContent .= getTranstab($modifiedmodule).':';
         }
         $RemindsContent .= $focus->getName($modifiedmodule,$modifiedby);
         $RemindsContent .= getFixedLabel('URGEREMIND');
         
         $Remind_id = $focus->AddReminds($RemindsContent,$datetime_now,$smownerid,$record);
    }
    $arr['remindid'] = $Remind_id;
    $arr['confirmstr'] = getFixedLabel('BEURGED');
    ConvertToJsonString(1,$arr,'success');
}else if($mode == 'ended'){
    if(isset($_REQUEST['frommodule'])&&$_REQUEST['frommodule']!='Users'){
        $modifiedmodule = $_REQUEST['frommodule'];
        $modifiedby = $_REQUEST['recordid'];
    }else{
        $modifiedmodule = 'Users';
        $modifiedby = $current_user->id;
    }
    
    //结单后将状态更新为已结单
    $sql = 'update '.$focus->table_name.' set worksheet_status=?,endedtime=? where '.$focus->table_index.'= ?';
    $focus->db->pquery($sql,array('closed',$datetime_now,$record));
    //添加工单日志
    $focus->saveWorkTrends($record,$modifiedmodule,$modifiedby,'ended');
    $arr['confirmstr'] = getFixedLabel('CLOSEBILL').getFixedLabel('SUCCESS');
    ConvertToJsonString(1,$arr,'success');
}else if($mode=='reopen'){
    $sql = 'select smownerid from '.$focus->table_name.' where '.$focus->table_index.'= ?';
    $result = $adb->pquery($sql,array($record));
    $smownerid = $adb->query_result($result,0,'smownerid');
    
    if(isset($_REQUEST['frommodule'])&&$_REQUEST['frommodule']!='Users'){
        $modifiedmodule = $_REQUEST['frommodule'];
        $modifiedby = $_REQUEST['recordid'];
    }else{
        $modifiedmodule = 'Users';
        $modifiedby = $current_user->id;
    }
    
    //重新打开后后将状态更新为处理中，并向服务人员发送消息提醒；
    $sql = 'update '.$focus->table_name.' set worksheet_status=?,receivedtime=? where '.$focus->table_index.'= ?';
    $result = $focus->db->pquery($sql,array('inprocess',$datetime_now,$record));
    //添加工单日志
    $focus->saveWorkTrends($record,$modifiedmodule,$modifiedby,'reopen');
    //添加消息提醒
    if($smownerid > 0){
         if($modifiedmodule!='Users'){
            $RemindsContent .= getTranstab($modifiedmodule).':';
         }
         $RemindsContent .= $focus->getName($modifiedmodule,$modifiedby);
         $RemindsContent .= getFixedLabel('REOPENWORKSHEET');
         
         $Remind_id = $focus->AddReminds($RemindsContent,$datetime_now,$smownerid,$record);
    }
    $arr['remindid'] = $Remind_id;
    
    ConvertToJsonString(1,$arr,'success');
}

?>