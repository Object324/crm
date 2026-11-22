<?php
global $adb;
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$boardid = $_REQUEST['boardid'];
if($boardid==-100){
    //移动端老看板删除  只有移动端老看板的id是-100 更改ld_systems_deploy表type是487的value为no
    $deploy_update = "update ld_systems_deploy set deploy_value = 'no' where deploy_type = 487;";
    $adb->pquery($deploy_update,array());
    unsetCache('systems_deploy');
}else{
    //新看板删除
    $module = (empty($_REQUEST['module']) && $_REQUEST['module'] == 'undefined') ? 'Home' : $_REQUEST['module'];
    $sql_update = 'update ld_homeboard set deleted = 1 where boardid = ?;';
    $adb->pquery($sql_update,array($boardid));
    crm_load_class_file("cls_related_scope",'include/utils');
    cls_related_scope::delete_related_scope($module,'Homeboard_scope',$boardid);
}
ConvertTojsonString(1,'',"success");
?>