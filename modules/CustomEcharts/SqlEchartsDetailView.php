<?php

$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once(globalStatic::$root_directory."include/simple_html_dom.php");
require_once(globalStatic::$root_directory."appCommon/appCommon.php");
$function = $_REQUEST['function_name'];
$function = empty($function)?'index':$function;
$_REQUEST['diony'] = 'yes';
include_once globalStatic::$root_directory.'modules/CustomEcharts/cls_SqlEchartsDetailView.php';

$obj = new cls_SqlEchartsDetailView($_REQUEST);
$is_ajax = $_REQUEST['is_ajax'];
$obj->$function($is_ajax);


