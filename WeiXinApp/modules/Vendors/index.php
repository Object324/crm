<?php
/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2016/11/28 0028
 * Time: 下午 3:45
 */
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
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