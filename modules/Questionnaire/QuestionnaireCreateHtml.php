<?php
global   $theme, $currentModule, $current_user , $adb,$site_URL;
$smarty = new lingdangCRM_Smarty();
$record =$_REQUEST['record'];
$focus = CRMEntity::getInstance($currentModule);
$focus->id =$record;
$focus->mode = 'edit';
$focus->retrieve_entity_info($focus->id, $currentModule);

//加载二维码配置文件
require_once ('QuestionnaireConfig.php');

if(!is_dir($htmlPath)){
    mkdir($htmlPath,0777,true);
}
$htmlFileName = $prefix.$record.$suffix;
/*//iframe类型 生成两个文件 一个为iframe 一个为form
if($_REQUEST['form'] == 1){
    $htmlFileName = $prefix.$record.'_form'.$suffix;
}*/

//用于判断
//$activitytypeArr = array('仅表单'=>'onlyForm','H5页面链接 + 表单'=>'H5+form');

ob_start();
ob_clean();

$questionnaire = $focus->column_fields;

//获取题目
$data = [];
$query = "SELECT questionnaireid,questionnaire_no,`name`,description,recovery_endremarks FROM ld_questionnaire WHERE questionnaireid = ? and deleted = 0";//and questionnaireid
$params = array($record);
$result = $adb->pquery($query, $params);
if($adb->num_rows($result) >= 1)
{
    $questionnaire_no = $adb->query_result($result,0,"questionnaire_no");
    $name = $adb->query_result($result,0,"name");
    $description = $adb->query_result($result,0,"description");
    $recovery_endremarks = $adb->query_result($result,0,"recovery_endremarks");

    $data['record'] = $record;
    $data['questionnaire_no'] = $questionnaire_no;
    $data['name'] = $name;
    $data['description'] = $description;
    $data['recovery_endremarks'] = $recovery_endremarks;
}

$bloacktopic_array = $focus->getLayoutBlock($record);
$data['blockinfo'] = $bloacktopic_array;

$smarty->assign('record',$record);
$smarty->assign('questionnaire_no',$questionnaire_no);
$smarty->assign('name',$name);
$smarty->assign('description',$description);
$smarty->assign('recovery_endremarks',$recovery_endremarks);

$smarty->assign('data',$data);
$smarty->assign('datajson',ldcrm_json_encode($data));


$smarty->caching = false;
//$smarty->display('modules/SocialPromotion/SocialPromotionActivity.tpl');
$smarty->display('modules/Questionnaire/QuestionnaireHtml.tpl');
$html=ob_get_contents();
file_put_contents($htmlPath.$htmlFileName, $html);
ob_end_flush();//输出并关闭缓冲区
