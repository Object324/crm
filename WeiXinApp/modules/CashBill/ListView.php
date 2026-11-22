<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
crm_load_class_file('cls_ListViewWX', 'WeiXinApp/list');
$module = $currentModule;
$relatemodule = $_REQUEST['related_module'];

$mobj = new cls_ListViewWX($currentModule);

$details = $mobj->get_listdetail(null);
//editor:gyq_20180813 0034694: （珞落计划企业微信登录）付款单模块：设置付款单模块没有新增权限时付款单模块仍有新增权限
$list_buttons = array();
if (isPermitted($currentModule, 'Create', '') == 'yes') {
    $list_buttons=array(1,'Debuction');
}

if(strpos($mobj->relatedModuleActions,'add')!==false){
    if($relatemodule == 'PaymentPlan'){
        $cur_focus = CRMEntity::getInstance($relatemodule);
		$cur_focus->retrieve_entity_info($_REQUEST['recordid'], $relatemodule);
		if($cur_focus->column_fields['paymentstatus'] == '已收'){
			$list_buttons = array();
		}
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
