<?php
//edit: xll 2023/07/13 将原方法整理成类，以适用于其他根据用户记住信息的需求
global $adb;
if(!isset($adb))
{
    exit();
}
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file("cls_SaveUserChoosen",'modules/lingdang');

$module = $_REQUEST['module'];
$saveObj = new cls_SaveUserChoosen($module);
$saveObj -> saveValue();

?>