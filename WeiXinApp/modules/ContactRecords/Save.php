<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$mobj = cls_Instance::get_moduleAction_Instance('ContactRecords','Save');
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
$mobj->common_save();
$mobj->ConvertTojsonStringInSave();

//duan 20221117 因为移动端跟进记录原有的逻辑已经移动到pc端了，所以将保存改成通用的格式，便于以后做逻辑控制
/*
global $adb;
crm_load_class_file('cls_SaveWX','WeiXinApp/detail');
$mobj = new cls_SaveWX($currentModule);
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
$mobj->common_save();
if(isset($_REQUEST['account_id'])&&!empty($_REQUEST['account_id'])){
    $accountid=$_REQUEST['account_id'];

    $SQL = 'SELECT accountname from ld_account WHERE accountid='.$accountid;
    $result = $adb->pquery($SQL,array());
    $accountname = $adb->query_result($result,0,0);
}
// @edit:dong @date:2020/07/24 @reason: 集成到common_save中
////editor:gyq_96 reason:企业微信客户服务单增加签到  2019/1/9 15:13
//$mobj->insert_signin();

//duan 2022-6-8 将pc端和移动端的代码整合到一起，并支持小编辑调用
//$datetime=$_REQUEST['nextcontactdate'];
//$recieverid=$_REQUEST['assigned_user_id'];
//
//if($_REQUEST['previousAction']=='CreateView')
//{
//    if($_REQUEST['contactdate'] < $_REQUEST['nextcontactdate']){
//        $RemindsContent=getFixedLabel('RETURNVISIT').getTranstab('Accounts').':'.$accountname;
//        $record=$_REQUEST['currentid'];
//        //新建创建提醒
//        AddReminds($RemindsContent,$datetime,$recieverid,$record,$_REQUEST['contactdate'],$_REQUEST['nextcontactdate']);
//    }
//}
//else
//{
//    if($_REQUEST['contactdate'] < $_REQUEST['nextcontactdate']){
//        $RemindsContent=getFixedLabel('RETURNVISIT').getTranstab('Accounts').':'.$accountname;
//        $record=$_REQUEST['record'];
//        //编辑创建提醒
//        AddReminds($RemindsContent,$datetime,$recieverid,$record,$_REQUEST['contactdate'],$_REQUEST['nextcontactdate']);
//    }
//}

//function AddReminds($RemindsContent,$datetime,$recieverid,$record,$date1,$date2)
//{
//    global $adb,$current_user;
//    if($date1<$date2){
//        //下次回访日期更新，首先删除该联系记录关联的未读的提醒
//        $sql="delete from ld_reminds where related_to='{$record}' and status_rmd='未读'";
//        $result = $adb->query($sql);
//        
//        $sql="delete from ld_reminds_accepted where related_to='{$record}' and status_rmd='未读'";
//        $result = $adb->query($sql);
//    }
//    $smownersql = "select * from ld_crmentity where crmid = ".$record;
//    $smownerresult = $adb->query($smownersql);
//    $setype = $adb->query_result($smownerresult,0,'setype');
//    $focus_rel =CRMEntity::getInstance('Reminds');
//    $focus_rel->column_fields['date_time'] = $datetime;
//    $focus_rel->column_fields['related_to']=$record;
//    $focus_rel->column_fields['reltab']=$setype;
//    $focus_rel->column_fields['remindstype']='ContactRecordsDate';
//    $focus_rel->column_fields['recieverid']=$recieverid;
//
//    $focus_rel->column_fields['status_rmd']='未读';
//    $focus_rel->column_fields['content']=$RemindsContent;
//    $focus_rel->mode="create";
//    $focus_rel->save('Reminds');
//}

$mobj->ConvertTojsonStringInSave();
*/
?>