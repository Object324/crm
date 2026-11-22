<?php
//ljj 20240915 XUQIU1001487 客户增加【客户图谱】，类似于联系人图谱（戚涛） 选择相关客户
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

$frommodule = $_REQUEST['frommodule'];
$fromrecord = $_REQUEST['fromrecord'];
$chartmodule = $_REQUEST['chartmodule'];
crm_load_class_file('cls_relationshipChart','modules/lingdang');
$cls_relationshipChartobj = cls_relationshipChart::getInstance($frommodule,$fromrecord,$chartmodule);
$mode = $_REQUEST['mode'];
$code = 1;
$arr = [];
$msg = 'success';
switch ($mode){
    case 'editChart':
        $cls_relationshipChartobj->setShowType('edit');
        $arr = $cls_relationshipChartobj->getRelationshipChartHtml();
        break;
    case 'saveChart':
        $relatedRecords = $_REQUEST['relatedRecords'];
        $relationshipChartDataArr = ldcrm_json_decode($_REQUEST['relationshipChartDataArr']);
        $haveNodeRecords = $_REQUEST['haveNodeRecords'];
        $tmpstatus = $cls_relationshipChartobj->saveChart($relatedRecords,$haveNodeRecords,$relationshipChartDataArr);
        unset($leftListData,$relationshipChartData);
        if (!$tmpstatus){
            $code = -1;
            $msg = getFixedLabel('UNLOCKSAVETIPS');
        }else{
            $arr = $cls_relationshipChartobj->getRelationshipChartHtml();
        }
        unset($tmpstatus);
        break;
    case 'getRelatedChart':
        $chartrecord = $_REQUEST['chartrecord'];
        $maxnodeid = $_REQUEST['maxnodeid'];
        $currentnodeid = $_REQUEST['currentnodeid'];
        $relatedRecords = $_REQUEST['relatedRecords'];
        $arr = $cls_relationshipChartobj->getRelatedChart($currentnodeid,$relatedRecords,$maxnodeid);
        $code = empty($arr) ? 2 : $code;
        break;
    case 'getRelatedRecords':
        $selectRelatedRecords = $_REQUEST['selectRelatedRecords'];
        $oldRelatedRecords = $_REQUEST['oldRelatedRecords'];
        $arr = $cls_relationshipChartobj->getRelatedRecordsBySelect($selectRelatedRecords,$oldRelatedRecords);
        break;
    case 'getChartByParentid':
        $relationshipChartData = $cls_relationshipChartobj->getAccountsChartDataByParentid();
        if (empty($relationshipChartData)){
            unset($relationshipChartData);
            ConvertTojsonString(-1,'','nodata');
        }else{
            $relatedRecords_arr = explode(',',$_REQUEST['relatedRecords']);
            $chart_relatedRecords_arr = array_values($cls_relationshipChartobj->haveRecordNodeArr);
            $relatedRecords_arr = array_unique(array_merge($relatedRecords_arr,$chart_relatedRecords_arr));
            $relatedRecords_arr = array_filter($relatedRecords_arr);
            $cls_relationshipChartobj->setRelatedRecords($relatedRecords_arr);
            $arr =$cls_relationshipChartobj->refreshChartAndList('getParentidChart');
        }
        break;
    case 'changeLock':
        $newlockstatus = $_REQUEST['newlockstatus'];
        $arr['lockstatus'] = $cls_relationshipChartobj->updateLockStatus($newlockstatus);
        break;
    case 'fullscreen':
        $cls_relationshipChartobj->setShowType('fullscreen');
        $arr = $cls_relationshipChartobj->getRelationshipChartHtml();
        break;
    case 'showFieldSet':
        $arr = $cls_relationshipChartobj->getShowFieldSetHtml();
        break;
    case 'saveShowFieldSet':
        $showFields = $_REQUEST['showFields'];
        $cls_relationshipChartobj->saveShowFieldSet($showFields);
        $relatedRecords = $_REQUEST['relatedRecords'];
        $cls_relationshipChartobj->setRelatedRecords($relatedRecords);
        $arr =$cls_relationshipChartobj->refreshChartAndList('saveShowFieldSet');
        unset($relatedRecords,$showFields);
        break;
}
//清除对象相关引用后 才能unset清掉该对象
$cls_relationshipChartobj->clearSelfRelatedObj();
unset($cls_relationshipChartobj);

//global $global_cls_relationshipChartobjs,$GLOBALS;
//$key = $frommodule.'_'.$fromrecord.'_'.$chartmodule;
//dump([$global_cls_relationshipChartobjs[$key],$GLOBALS['global_cls_relationshipChartobjs'][$key]]);

ConvertTojsonString($code,$arr,$msg);


?>