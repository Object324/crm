<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$function = $_REQUEST['function_name'];
$function = empty($function)?'index':$function;
$_REQUEST['diony'] = 'yes';
include_once globalStatic::$root_directory.'modules/CustomEcharts/cls_SqlEchartsEditView.php';

$obj = new cls_SqlEchartsEditView($_REQUEST);
$is_ajax = $_REQUEST['is_ajax'];
$obj->$function($is_ajax);

?>