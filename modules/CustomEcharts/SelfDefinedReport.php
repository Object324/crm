<?php
//zkt 20231011 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$function = $_REQUEST['function_name'];
$function = empty($function)?'index':$function;
$_REQUEST['diony'] = 'yes';
crm_load_class_file('cls_SelfDefinedReport','modules/CustomEcharts/');
$obj = new cls_SelfDefinedReport($_REQUEST);
$is_ajax = $_REQUEST['is_ajax'];
$obj->$function($is_ajax);
?>
