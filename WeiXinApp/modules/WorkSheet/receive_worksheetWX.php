<?php
/*
edit:duan
date:2021-11-16
reason:工单模块移动端领取功能
*/
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//判断当前用户能否领取单据
global $current_user,$currentModule,$adb;
$_REQUEST['diony']='yes';
$focus = CRMEntity::getInstance($currentModule);
$limit_amount = 1000;
$module = $currentModule;
$record = $_REQUEST['record'];

//判断用户负责的工单数量是否会到达上限
$sql = 'select * from ld_worksheet where smownerid =? and worksheet_status <> ? and deleted = 0';
$result = $adb->pquery($sql,array($current_user->id,'closed'));
$cur_amount = $adb->num_rows($result);

//读取选中的工单信息
$sql = 'select smownerid,worksheetid,worksheet_no,worksheet_status from ld_worksheet where worksheetid in ('.$record.');';
$result = $adb->pquery($sql,array());
$num_rows = $adb->num_rows($result);

$batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');//单据[%s]%s成功！
$batcherrorlog = getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVERGUANLIANSS');//单据[%s]%s失败！原因：该单据已经%s!
$documenterrorinfo = getFixedLabel('documenterrorinfo');//单据[%s]%s失败！原因：%s!
$batchnum = getFixedLabel('BATCHSUBMITLOG_INFO');//共选择 %d 条记录，成功 %d 条，失败 %d 条
$successid = 0;
for($i=0;$i<$num_rows;$i++){
    $smownerid = $adb->query_result($result,$i,'smownerid');
    $worksheetid = $adb->query_result($result,$i,'worksheetid');
    $worksheet_no = $adb->query_result($result,$i,'worksheet_no');
    
    $link = '<a referencemodule="'.$module.'" referencerecord="'.$worksheetid.'" onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636">'.$worksheet_no.'</a>';
    //判断单据是否已有服务人员
    if($smownerid>0){
        $remind = getFixedLabel('RECEIVEDORALLOCATED');
        ConvertToJsonString(-1,array(),$remind);
    }else if($cur_amount >= $limit_amount){
        $remind = getFixedLabel('DOCUMENTSREACHEDUPPERLIMIT');
        ConvertToJsonString(-1,array(),$remind);
    }else{
        $remind = sprintf($batchsuccesslog,$link,getFixedLabel('RECEIVE')).'<br>';
        $successid = $worksheetid;
    }
    $cur_amount += 1;
}

$tablename = $focus->table_name;
$tableindex =  $focus->table_index;
$columnname = 'smownerid';
$fieldname = 'assigned_user_id';
if($successid>0){
    $worksheetid = $successid;
    $time = date('Y-m-d H:i:s',time());
    //更新工单服务人员
    $sql = 'update '.$tablename.' set smownerid = ?,modifiedtime=?,modifiedby=?,worksheet_status=?,receivedtime=? where '.$tableindex.'= ?';
    $adb->pquery($sql,array($current_user->id,$time,$current_user->id,'inprocess',$time,$worksheetid));
    
    //添加日志
    $status = 0;
    $id = $adb->getUniqueID('ld_modtracker_basic');
    $query = 'insert into ld_modtracker_basic(id,crmid,module,whodid,changedon,status) 
    					values(?,?,?,?,?,?);';
    $adb->pquery($query,array($id,$worksheetid,$module,$current_user->id,$time,$status));
    $query = 'insert into ld_modtracker_detail(id,fieldname,prevalue,postvalue) values(?,?,?,?);';
    $adb->pquery($query,array($id,$fieldname,'',$current_user->id));
    
    //添加工单动态信息
    $description = 'receive';
    $modifiedmodule = 'Users';
    $modifiedby = $current_user->id;
    $focus->saveWorkTrends($worksheetid,$modifiedmodule,$modifiedby,$description);
}

$arr['remind'] = $remind;
ConvertToJsonString(1,$arr,'success');

?>