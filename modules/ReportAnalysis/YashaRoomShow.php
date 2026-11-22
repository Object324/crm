<?php
//zkt 20231010 XUQIU1001341 SQL×¢Èë
//$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
//$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once globalStatic::$root_directory.'modules/ReportAnalysis/YashaRoomShowClass.php';
$function = $_REQUEST['function_name'];
$function = empty($function)?'index':$function;
$_REQUEST['diony'] = 'yes';
SqlSearchFilter($_REQUEST);

$obj = new YashaRoomShowClass();
$obj->$function();

?>