<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
crm_load_class_file('cls_ListViewWX', 'WeiXinApp/list');
$module = $currentModule;
$relatemodule = $_REQUEST['related_module'];

$mobj = new cls_ListViewWX($currentModule);

$details = $mobj->get_listdetail(null);

$list_buttons = array();
//报价变更单  新增->追加/新增->变更
if(strpos($mobj->relatedModuleActions,'add')!==false){
    if (isPermitted($module, 'QuotesChange_Add', '') == 'yes') {
        $list_buttons[] = 6;
    }
    if(isPermitted($module, 'QuotesChange_Replace', '') == 'yes'){
        $list_buttons[] = 7;
    }
    //editor:gyq_20190726 reason:报价单相关界面：报价变更单新增中显示“新增->修改” 2019/7/26 11:42
    if(isPermitted($module, 'QuotesChange_Edit', '') == 'yes'){
        $list_buttons[] = 'quoteschange_edit';
    }
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
