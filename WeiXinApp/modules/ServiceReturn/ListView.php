<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule,$adb;
crm_load_class_file('cls_ListViewWX', 'WeiXinApp/list');

$mobj = new cls_ListViewWX($currentModule);
$relatemodule = $_REQUEST['related_module'];
$record = $_REQUEST['recordid'];

$details = $mobj->get_listdetail(null);
$list_buttons = array();
//服务回访单移动端允许 新增
if(isPermitted($module, 'Create', '') == 'yes' && (strpos($mobj->relatedModuleActions,'add')!==false || empty($mobj->relatedModuleActions))){
    //判断该服务单是否已创建回访单
    /*客户服务单可以创建多条服务回访单
    if($relatemodule == 'HelpDesk'){
        $sql = "select 1 from ld_servicereturn where troubleticketid = ? and deleted = 0";
    }elseif($relatemodule == 'ProjectTask'){
        $sql = "select 1 from ld_servicereturn where projecttaskid = ? and deleted = 0";
    }

    $result=$adb->pquery($sql,array($record));
   
    $num_rows=$adb->num_rows($result);
    if(!$num_rows) $list_buttons = array(1);*/
    $list_buttons = array(1);
}
//editor:gyq_89 reason:小程序有分录的模块暂隐藏新增按钮 2018/12/6 13:14
if(judge_productdetail($currentModule)){
    $list_buttons = array();
}
$details['list2'] = array(
    'viewname' => $_REQUEST['viewid'],
    'create_html'=>$list_buttons);
ConvertTojsonString(1, $details, 'success');
?>