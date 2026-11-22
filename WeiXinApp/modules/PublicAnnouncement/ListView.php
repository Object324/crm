<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
$mobj = cls_Instance::get_moduleAction_Instance($currentModule,'ListView');
$details = $mobj->get_listdetail(null);
if (isPermitted($currentModule, 'Create', '') == 'yes') {
    if(strpos($mobj->relatedModuleActions,'add')!==false || empty($mobj->relatedModuleActions)){
        $list_buttons = array(1);
    }else{
        $list_buttons = array();
    }
} else {
    $list_buttons = array();
}
//editor:gyq_89 reason:小程序有分录的模块暂隐藏新增按钮 2018/12/6 13:14
if(judge_productdetail($currentModule)){
    $list_buttons = array();
}
$details['list2'] = array(
    'viewname' => $_REQUEST['viewid'],
    'create_html'=>$list_buttons);
ConvertTojsonString(1,$details,'success');
?>
