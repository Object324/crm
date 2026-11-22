<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $currentModule,$current_user,$adb;
$smarty=new lingdangCRM_Smarty();

$json = new Zend_Json();
$advft_criteria = $json->decode($_REQUEST['advft_criteria']);
$advft_criteria_groups = $json->decode($_REQUEST['advft_criteria_groups']);
//$criteria_groups_arr = getAdvancedSearchCriteriaList($advft_criteria, $advft_criteria_groups, $currentModule,'');
if(!empty($advft_criteria)){
    $criteria_groups_arr = [];
    foreach($advft_criteria as $index => $info){
        if(isset($info['columnname'])){
            $groupid = $info['groupid'];
            $info['search_comparator'] = $info['comparator'];
            $info['column_condition'] = $info['columncondition'];
            $criteria_groups_arr[$groupid]['columns'][] = $info;
            $criteria_groups_arr[$groupid]['condition'] = $advft_criteria_groups[$groupid]['groupcondition'];
        }
    }
}
$arr['criteria_groups_arr'] = $criteria_groups_arr;

//选择条件
crm_load_class_file('CommonView',"modules/CustomView");
$comparatorArr = CommonView::getComparatorLabel();
$comparatorArr['belong'] = getFixedLabel('BELONG');
$comparatorArr['notbelong'] = getFixedLabel('NOTBELONG');
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$comparatorArr['new_belong'] = getFixedLabel('BELONG');
$comparatorArr['new_notbelong'] = getFixedLabel('NOTBELONG');
$advfilterhtml = CommonView::getAdvCriteriaHTML($comparatorArr);
$arr['advfilterhtml'] = $advfilterhtml;
$arr['fLabels'] = $comparatorArr;
$arr['datetimestr']=CommonView::stdFilterDateTimeStr("");

// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$fromModule = $_REQUEST['fromModule'];
$controller = ListViewController::getInstance($currentModule, $fromModule);
$arr['advanceFields'] = $controller->getAdvanceFields();

if (isset($_REQUEST['showSearchHistory'])){//是否显示历史记录部分
    $smarty->assign("showSearchHistory",$_REQUEST['showSearchHistory']);
}
//$arr['arrJsPopupLabel'] = array('and'=>getFixedLabel('SEARCHAND'),'or'=>getFixedLabel('OR'),
//    'none'=>getFixedLabel('NONE'),
//    );

$arr['customview_permit'] = isPermitted($currentModule,'CustomView');
$arr['customview_btn'] = '<input name="button" onClick="saveAsDataClass();" class="ld-button" value="'.getFixedLabel('SAVEASDATACLASS').'"type="button" class="ld-button">';


$arr['content']=$smarty->fetch("newAdvanceFilter.tpl");
$_REQUEST['diony']='yes';
$arr['title']=getFixedLabel('CUSTOMIZESEARCH');
$arr['oktext']=getFixedLabel('screen');
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['clearAllText']=getFixedLabel("ClearTiledFilterValues");
$arr['module']=$currentModule;
ConvertTojsonString(1,$arr,'success');


?>