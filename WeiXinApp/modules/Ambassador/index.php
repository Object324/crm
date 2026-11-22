<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$actionname = $_REQUEST['action'];
if(empty($_REQUEST['action'])){
    $actionname = 'ListView';
}
if($actionname == 'EditView' || $actionname == 'CreateView' || $actionname == 'DetailView'){
    include(globalStatic::$root_directory . 'WeiXinApp/modules/'.$currentModule.'/DetailView.php');
}else{
    include(globalStatic::$root_directory . 'WeiXinApp/modules/'.$currentModule.'/'.$actionname.'.php');
}
?>