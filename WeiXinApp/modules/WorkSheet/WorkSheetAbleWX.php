<?php
/*
edit:duan
date:2021-11-18
reason:工单模块催单，结单，重新打开功能
*/
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
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
            $remind = getvarFixedLabel('CANOTURGED',$hour_limit).$urgedtime;
            ConvertToJsonString(-1,array(),$remind);
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
    //$arr['remindid'] = $Remind_id;
    $arr['remind'] = getFixedLabel('BEURGED');
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
    $arr['remind'] = getFixedLabel('CLOSEBILL').getFixedLabel('SUCCESS');
    ConvertToJsonString(1,$arr,'success');
}else if($mode=='reopen'){
    $sql = 'select smownerid,worksheet_status from '.$focus->table_name.' where '.$focus->table_index.'= ?';
    $result = $adb->pquery($sql,array($record));
    $smownerid = $adb->query_result($result,0,'smownerid');
    $worksheet_status = $adb->query_result($result,0,'worksheet_status');
    if(isset($_REQUEST['frommodule'])&&$_REQUEST['frommodule']!='Users'){
        $modifiedmodule = $_REQUEST['frommodule'];
        $modifiedby = $_REQUEST['recordid'];
    }else{
        $modifiedmodule = 'Users';
        $modifiedby = $current_user->id;
    }
    if($worksheet_status!='closed'){
        $remind = getFixedLabel('DOCUMENTISBEINGPROCESSED');
        ConvertToJsonString(-1,array(),$remind);
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
    $arr['remind']='打开成功';
    ConvertToJsonString(1,$arr,'success');
}

?>