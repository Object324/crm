<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
$module = $currentModule;
$relatemodule = $_REQUEST['related_module'];

if(isset($_REQUEST['worksheet_status'])&&$_REQUEST['worksheet_status']!=""){   
    $worksheet_status = $_REQUEST['worksheet_status'];
    $_SESSION['lvs'][$currentModule]['worksheet_status'] = $worksheet_status;
}else if(isset($_SESSION['lvs'][$currentModule]['worksheet_status'])&&$_SESSION['lvs'][$currentModule]['worksheet_status']!=""){
    $worksheet_status = $_SESSION['lvs'][$currentModule]['worksheet_status'];
}else{
    $worksheet_status = 'all';
}

$mobj = cls_Instance::get_moduleAction_Instance($module,'ListView');
$details = $mobj->get_listdetail("",null);

//产品相关信息暂时隐藏新增按钮  gyqTE
if (isPermitted($module, 'Create', '') == 'yes'&&$relatemodule!='Products') {
    if(empty($mobj->relatedModuleActions) || strpos($mobj->relatedModuleActions,'add')!==false){
        $list_buttons = array(1);
    }else{
        $list_buttons = array();
    }
} else {
    $list_buttons = array();
}
//$list_buttons = array();
$details['list2'] = array(
    'viewname' => $_REQUEST['viewid'],
    'create_html'=>$list_buttons);
ConvertTojsonString(1, $details, 'success');

?>