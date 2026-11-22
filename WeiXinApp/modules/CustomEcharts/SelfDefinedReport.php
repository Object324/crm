<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
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
