<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $languageType,$currentModule;
$module = $_REQUEST['module'];
$smarty=new lingdangCRM_Smarty;
if(!file_exists('storage/VisualAnalysisIcon/')){
    mkdir('storage/VisualAnalysisIcon/',0777);
    crm_load_class_file("VisualAnalysisBoard",'modules/VisualAnalysis');
    VisualAnalysisBoard::xCopy('include/images/reportimage','storage/VisualAnalysisIcon/',1);
}

if(isset($_REQUEST['ShowType']) && !empty($_REQUEST['ShowType'])){
    $ShowType = $_REQUEST['ShowType'];
}else{
    crm_load_class_file("cls_SaveUserChoosen",'modules/lingdang');
    $getShowTypeObj = new cls_SaveUserChoosen($module,'VisualAnalysis_ShowType');
    $getShowType = $getShowTypeObj -> getValueByType();
    $ShowType = ($getShowType == '') ? 'Card' : $getShowType;//默认卡片视图
}
//$ShowType = 'List';
$smarty->assign("SHOWTYPE", $ShowType);//type；类型


crm_load_class_file("VisualAnalysisBoardList",'modules/VisualAnalysis');
if(isset($_REQUEST['BoardType']) && !empty($_REQUEST['BoardType'])){
    $BoardType = $_REQUEST['BoardType'];
}else{
    $BoardType = 'All';//默认全部类别
}

$VisualAnalysisBoardObj = new VisualAnalysisBoardList($module,$BoardType);
$BoardList = $VisualAnalysisBoardObj -> getBoardListByType();
$BoardTypeList = $VisualAnalysisBoardObj -> BoardTypeList;//dump($BoardTypeList);
$SearchTypeList = $VisualAnalysisBoardObj -> getBoardBySearchTypeList();
$permit_array = $VisualAnalysisBoardObj -> get_PermitList();
$smarty->assign('BOARDTYPECHOOSEN',$BoardType);
$smarty->assign('BOARDTYPELIST',$BoardTypeList);
$smarty->assign('SEARCHTYPELIST',$SearchTypeList);
$smarty->assign("PERMITARR", $permit_array);
if(isset($_REQUEST['SearchType'])){
    $BoardList = $VisualAnalysisBoardObj -> getBoardListBySearchValue();
}
//dump($BoardList);
if($ShowType == 'List'){
    $list_header= $VisualAnalysisBoardObj -> get_ListHeader();
    $smarty->assign('LIST_HEADER',$list_header);
}
$smarty->assign("HomeboardList",$BoardList);
$smarty->assign("from_module",$module);
$smarty->assign("languageType",$languageType);

setGLobalURLSmarty($smarty);//设置js,css等访问路径

if($_REQUEST['ajax'] == 'true'){
    $arr['title'] = getTranstab('VisualAnalysis');
    $arr['searchvalue'] = $_REQUEST['SearchValue'];
    $arr['content'] = $smarty->fetch("modules/$module/ListViewContent.tpl");
    ConvertTojsonString(1,$arr,"success");
}
else{
    $smarty->display("modules/$module/ListView.tpl");
    exit();
}

?>