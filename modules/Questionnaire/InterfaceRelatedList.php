<?php

$root_dir=dirname( dirname(dirname(__FILE__)));
$root_dir.=DIRECTORY_SEPARATOR;
$root_directory=$root_dir;
include($root_directory.'includefile.php');
//require_once($root_directory.'Register/RegOp.php');
//require_once ($root_directory.'data/CRMEntity.php');
//require_once ($root_directory.'include/utils/CommonFun.php');
global $adb;
$_REQUEST['diony'] = 'diony';

$topicid = intval(vtlib_purify($_REQUEST['topicid']));

$sql = 'select referencemodule,advance_demand,advance_demand_groups,maxrowsshow,fieldonly,approve_demand from ld_questionnaire_topic where topicid = ? and deleted = 0';
$result=$adb->pquery($sql,array($topicid));
$rows=$adb->num_rows($result);
if($rows>0){
    $referencemodule = $adb->query_result($result,0,'referencemodule');
    $advance_demand = $adb->query_result($result,0,'advance_demand');
    $advance_demand_groups = $adb->query_result($result,0,'advance_demand_groups');
    $maxrowsshow = $adb->query_result($result,0,'maxrowsshow');
    $fieldonly = $adb->query_result($result,0,'fieldonly');
    $approve_demand = $adb->query_result($result,0,'approve_demand');

    require_once (globalStatic::$root_directory.'modules/Questionnaire/cls_QustionDuplicateColumn.php');
    $obj = new cls_QustionDuplicateColumn($referencemodule,$advance_demand,$advance_demand_groups,$approve_demand,$maxrowsshow,$_REQUEST['languege'],$topicid);
    $obj->displayTpl();
}
?>
