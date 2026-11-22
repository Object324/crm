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
//产品相关信息暂时隐藏新增按钮  gyqTE
if (isPermitted($module, 'Create', '') == 'yes'&&$relatemodule!='Products') {
    if(strpos($mobj->relatedModuleActions,'add')!==false || empty($mobj->relatedModuleActions)){
        $list_buttons = array(1);
    }else{
        $list_buttons = array();
    }
} else {
    $list_buttons = array();
}

//reason:关联信息列表不会出现拍名片创建 date:20170310
if(empty($mobj->relatedModuleActions)) {
    $camcard = -5;
    if (!empty($list_buttons)) {
        require_once(globalStatic::$root_directory . 'expansion/camcard/cls_camcard.php');
        $camobj = new cls_camcard();
        $camcard = $camobj->judgeForCreate($currentModule);
        if ($camcard > 0) {
            $list_buttons[] = 4;
        }
    }
}
// ljj 20231220 XUQIU1002130 销售线索增加查重、合并和自动查重合并功能（戚涛）
if (isPermitted($currentModule,'accountdatadup')=='yes'){
    $list_buttons[] = 'Datadupcheck';
}
$details['list2'] = array(
    'viewname' => $_REQUEST['viewid'],
    'camcard'=>$camcard,
    'create_html'=>$list_buttons);
ConvertTojsonString(1, $details, 'success');
?>