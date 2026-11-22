<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user;
/* gyq_17 */
crm_load_class_file('cls_ReportDetailInfoWX','WeiXinApp/modules/Dashboard');
crm_load_class_file('report_saleskit_yangduan','WeiXinApp/modules/Dashboard');
if($_REQUEST['selectuid']=='me'){
    $_REQUEST['selectuid'] = $current_user->id;
}
//editor:gyq_126 reason:迅达别墅梯特殊开发  2019/6/21 16:38
$static_report = array('SalesFunnelReport','ClueSourceReport','CluedistributionReport','FailureAnalysisReport');
//editor:gyq_147 reason:扬锻销售报表  2019/9/29 20:49 
$report_name = $_REQUEST['report_name'];

if($report_name=='saleskit_yangduan'){
    $detailObj = new report_saleskit_yangduan($_REQUEST['record']);
    $list = $detailObj->saleskit_yangduan();
    $list['arrFixedLabel'] = $detailObj->getlabel_arr();
    ConvertTojsonString(1,$list,'success');
}elseif(in_array($report_name,$static_report)){
    $detailObj = new cls_ReportDetailInfoWX(null);
    $list =  $detailObj->report_detail($_REQUEST['report_name']);
    $list['arrFixedLabel'] = $detailObj->getlabel_arr();
    ConvertTojsonString(1,$list,'success');
}else if($report_name=='huboshivendorscompleteinfo'||$report_name=='huboshiuserscompleteinfo'){
    //呼博士 zxm 2022-5-16 1.经销商任务完成情况表 huboshivendorscompleteinfo  2.业务员任务完成情况表 huboshiuserscompleteinfo
    require_once globalStatic::$root_directory.'modules/Home/CustomMade/HuboshiUtils.php';
    $HuboshiObj = new HuboshiUtils();
    $HuboshiObj->$report_name();
    die;
}else{
    $detailObj = new cls_ReportDetailInfoWX($_REQUEST['record']);
    $detailObj->DashboardDetail();
}




