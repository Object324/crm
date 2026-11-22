<?php
//审批回撤
global $adb,$current_user;
$record=$_REQUEST['id'];
$frommodule=$_REQUEST['frommodule'];

$approve=new Approve();
$approveinfo=$approve->getlastapproveinfo($record,$frommodule);
$nextstepapproveby = $approveinfo['nextstepapproveby'];//下一步审批人 zxm 20230223
$nextstepapproveby_arr = explode(',',$nextstepapproveby);

$_REQUEST['diony']='diony';
if($approve->get_retrace_permit($record,$frommodule) != 'yes')
{
    ConvertTojsonString(-1,array(),getFixedLabel("Approvestephavechangetip"));
}
$focus=CRMEntity::getInstance($frommodule);
$tablename=$focus->table_name;
$table_index=$focus->table_index;

crm_load_class_file("cls_savereverse",'include/SaveReverse');
$pagemode='RetractApprove';
$workflowreverseobj=cls_savereverse::getInstance($frommodule);
$workflowreverseobj->setPageMode($pagemode);

$workflowreverseobj->getInfo();
 if($adb->num_rows($workflowreverseobj->workflowresut)>0)
 {
      global $reset_retrieve_entity_info;//修改日志需要重新获取数据
      $reset_retrieve_entity_info='yes';//批量提交
     $focus->retrieve_entity_info($record, $frommodule);
     $beforefieldvalue_arr=$focus->column_fields;
 }
      
      
         
$updatesql=" update $tablename set approvestatus=? ,approveby=?,currentapprover=?,approvetime=?,currentapprovestepid=? where  $table_index=?";
$adb->pquery($updatesql,array(D_A_S_UNAPPROVED,'','','','-2',$record));

 if($adb->num_rows($workflowreverseobj->workflowresut)>0)
 {
 
    $workflowreverseobj->setRecord($record);
    
    $focus->column_fields['approvestatus']=D_A_S_UNAPPROVED;
    $focus->column_fields['approvesubmitter']='';
    $focus->column_fields['currentapprover']='';
    $focus->column_fields['approveby']='';
    $workflowreverseobj->setPageMode($pagemode);
    if($workflowreverseobj->checkCallApiPop() == 'yes')
     $workflowreverseobj->setNotCallActionType(array('API','Link2ERP'));//无需处理的API类型
    $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$focus->column_fields,$pagemode);
 }
//检查是否有API调用
$receive_msg = $workflowreverseobj->checkCallApiPop();
$arr['workflow']['receive_msg'] = $receive_msg;
if ($receive_msg == 'yes') {
    $arr['workflow']['record'] = $record;
    $arr['workflow']['module'] = $frommodule;
    $arr['workflow']['pagemode'] = $workflowreverseobj->getPageMode();

    $arr['workflow']['before_save_infos'] = $beforefieldvalue_arr;
    $arr['workflow']['after_save_infos'] = $focus->column_fields;
}
 
$maxid=$adb->getUniqueID('ld_approvelog');
// @edit:dong @date:2021/04/13 @reason: 时间千分秒
$sql='insert into ld_approvelog(id,crmid,approveid,stepid,approved_by,approveresult,createdtime,seqtime,stepseq)value(?,?,?,?,?,?,now(),current_timestamp(6),0)';
$approveid=$approveinfo['approveid'];
$adb->pquery($sql,array($maxid,$record,$approveid,-2,$current_user->id,4));
//提交审批 一下步骤是并发，然后提交人回撤，导致首页组件待审批显示错误
//edit:can 在首页“待审批”视图中有一个待审批的项目，但是实际上这个项目已经审批通过了，在审批中心里查询就没有。
$sql='update ld_approvelog set isfinished=? where crmid=? and id<?';
$adb->pquery($sql,array("yes",$record,$maxid));


$arr['refreshdetailmodules']=array($frommodule);
//zxm 20230223 单据审批回撤 需要删除云之家待办
$remindsid_arr = [];
foreach($nextstepapproveby_arr as $approvebyid){
    $sql_temp = "select remindsid from ld_reminds where  remindstype='Approve' and related_to=? and push_to_yzj=3 and recieverid=? order by createdtime desc limit 1 ";
    $res_temp = $adb->pquery($sql_temp,array($record,$approvebyid));
    $num_temp = $adb->num_rows($res_temp);
    if($num_temp>0){
        $remindsid_arr[] = $adb->query_result($res_temp,0,'remindsid');
    }
}
if(!empty($remindsid_arr)){
    //云之家消息中心、待审批 流转 --- 变更待办单据的状态，变为已读，已处理 或者删除
    //20230222 zxm 暂时只做单据的回撤 待办单据的状态变为删除
    require_once(globalStatic::$root_directory . "WeiXinApp/modules/Reminds/cls_reminds_yzj.php");
    $yzj_remind = new cls_reminds_yzj();
    $remindsid_str = implode(',',$remindsid_arr);
    $yzj_remind->UpdateMessageStatus($remindsid_str,$yzj_remind->statusProcessed);
}

//泛微回撤 ls 240429 XUQIU20240322-04 推送消息到泛微
require_once(globalStatic::$root_directory . "WeiXinApp/modules/Reminds/cls_reminds_fanwei.php");
$fanwei_remind = new cls_reminds_fanwei();
if ($fanwei_remind->setInstallFanwei()) {
    $remindsid_arr = [];
    foreach($nextstepapproveby_arr as $approvebyid){
        $sql_temp = "select remindsid from ld_reminds where  remindstype='Approve' and related_to=? and push_to_fw=3 and recieverid=? order by createdtime desc limit 1 ";
        $res_temp = $adb->pquery($sql_temp,array($record,$approvebyid));
        $num_temp = $adb->num_rows($res_temp);
        if($num_temp>0){
            $remindsid_arr[] = $adb->query_result($res_temp,0,'remindsid');
        }
    }
    if(!empty($remindsid_arr)){
        $remindsid_str = implode(',',$remindsid_arr);
        $fanwei_remind->UpdateMessageStatus($remindsid_str,$fanwei_remind->statusProcessed);
    }
}

require_once(globalStatic::$root_directory . "WeiXinApp/modules/Reminds/MessageCorpconversation.php");
$remind = new MessageCorpconversation();
if ($remind->setEventModel()) {
    $remindsid_arr = [];
    foreach($nextstepapproveby_arr as $approvebyid){
        $sql_temp = "select remindsid from ld_reminds where  remindstype='Approve' and related_to=? and push_to_ding=3 and recieverid=? order by createdtime desc limit 1 ";
        $res_temp = $adb->pquery($sql_temp,array($record,$approvebyid));
        $num_temp = $adb->num_rows($res_temp);
        if($num_temp>0){
            $remindsid_arr[] = $adb->query_result($res_temp,0,'remindsid');
        }
    }
    if(!empty($remindsid_arr)){
        $remindsid_str = implode(',',$remindsid_arr);
        $remind->UpdateDingtalkMessageStatus($remindsid_str,$remind->statusProcessedDing);
    }
}
if (judgeCorpInfo('install_app')) {
    $remindsid_weixin_arr = [];
    foreach($nextstepapproveby_arr as $approvebyid){
        $sql_temp = "select remindsid from ld_reminds where  remindstype='Approve' and related_to=? and push_to_weixin=3 and recieverid=? order by createdtime desc limit 1 ";
        $res_temp = $adb->pquery($sql_temp,array($record,$approvebyid));
        $num_temp = $adb->num_rows($res_temp);
        if($num_temp>0){
            $remindsid_weixin_arr[] = $adb->query_result($res_temp,0,'remindsid');
        }
    }
    if(!empty($remindsid_weixin_arr)){
        $remindsid_weixin_str = implode(',',$remindsid_weixin_arr);
        $remind->UpdateWeixinMessageStatus($remindsid_weixin_str);
    }
}

require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_fw.php");
$fw_remind = new cls_reminds_fw();
if($fw_remind->setInstallFw()){
    $fw_remind->UpdateMessageStatus($record);
}

ConvertTojsonString(1,$arr,'success');
?>