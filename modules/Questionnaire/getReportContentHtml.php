<?php
global $currentModule,$adb;
$record = intval($_REQUEST['record']);
$startmonth = $_REQUEST['startmonth'];


$focus = CRMEntity::getInstance($currentModule);
$focus->id =$record;
$focus->retrieve_entity_info($focus->id, $currentModule);
$smarty = new lingdangCRM_Smarty();
$betweenTime = explode(' - ',$startmonth);

$search_topic_type = trim($_REQUEST['search_topic_type']);
$search_topic_name = trim($_REQUEST['search_topic_name']);//模糊搜索

//获取表单数据的内容
$questionnaireInfo = $focus->getQuestionnaireInfo($record);
$reportArr = $focus->getReportData($record,$betweenTime[0],$betweenTime[1],$search_topic_type,$search_topic_name);
$smarty->assign('reportArr',$reportArr);
$smarty->assign('recoverys',$questionnaireInfo['recoverys']);
$smarty->assign('views',$questionnaireInfo['views']);
$content = $smarty->fetch('modules/Questionnaire/ReportHtml.tpl');

$_REQUEST['diony'] = 'yes';
ConvertTojsonString(1,array('content'=>$content,'reportArr'=>$reportArr),'success');