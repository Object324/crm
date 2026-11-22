<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
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
//gyq_20
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

//导入外部联系人按钮
global $weixin_user;
if ($weixin_user->environment=='weixinh5') {
    if(cls_StaticCommonFun::isExternalContactUser()) $list_buttons[] = 5;
}

$details['list2'] = array(
    'viewname' => $_REQUEST['viewid'],
   // 'moduletitle' => getTranstab('Contacts'),
    'camcard'=>$camcard,
    'create_html'=>$list_buttons);
ConvertTojsonString(1, $details, 'success');

?>
