<?php
//zkt 20231024 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file('cls_GroupUser','WeiXinApp/WeiXin_common/SearchScope');
$method = $_REQUEST['method'];
if($method=='getShareUser'){
    $_REQUEST['checkprivilege'] = 'no';
    $searchscope = array(
        'module'=>$_REQUEST['popup_module'],
        'searchtype'=>$_REQUEST['searchtype'],
        'filterown'=>$_REQUEST['filterown'],
        'scopetype'=>$_REQUEST['scopetype'], 
        'common'=>$_REQUEST['common'], 
        'isactive'=>$_REQUEST['isactive'] 
    );
    $cls_GroupUser = new cls_GroupUser($searchscope);
    $orignalTree = $cls_GroupUser->getGroupUser();
    
    //duan 20221012 移动端增加翻译文本返回
    crm_load_class_file('WorkReportControllerWX','WeiXinApp/modules/Home');
    $focus = new WorkReportControllerWX();
    $orignalTree['arrFixedLabel'] = $focus->getChooseUserFiexedlabel();
    ConvertTojsonString(1,$orignalTree,'success');
}elseif($method=='setShareUser'){
    $_REQUEST['change_share_mobile'] = 'yes';
    require_once globalStatic::$root_directory.'modules/Users/setModuleShare.php';
}


?>