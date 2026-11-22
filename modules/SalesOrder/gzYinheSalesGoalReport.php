<?php
//XUQIU20241101-01 目标管理个性化开发需求  权限和数据范围跟销售订单走  但实际上这算一个报表 所以把类文件写到了报表分析下 入口文件放在了销售订单下
//index.php?module=SalesOrder&action=SalesOrderAjax&file=gzYinheSalesGoalReport
//zkt 20231010 XUQIU1001341 SQL注入
require_once(globalStatic::$root_directory."/include/cls_UrlEncryptyJudge.php");
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once globalStatic::$root_directory.'modules/ReportAnalysis/cls_gzYinheSalesGoalReport.php';
$function = $_REQUEST['function_name'];
$function = empty($function)?'index':$function;
$_REQUEST['diony'] = 'yes';
SqlSearchFilter($_REQUEST);

$obj = new cls_gzYinheSalesGoalReport();
$obj->setParams($_REQUEST);
$obj->$function();

