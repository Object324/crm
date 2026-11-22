<?php
global $currentModule,$adb;
$record = vtlib_purify($_REQUEST['record']);
$module = vtlib_purify($_REQUEST['module']);
if($record != '') {
    $focus = CRMEntity::getInstance($currentModule);
	$focus->id = $record;
	$focus->retrieve_entity_info($record, $currentModule);
    $query='';
    $query .='update ld_projecttask set projecttaskstatus=\'已完成\'';
    $query .=' where projecttaskid='.$record;
    $adb->pquery($query,array());
    if(!empty($focus->column_fields['projectid'])){
        
        InsertProjectabstract($focus->column_fields['projectid'],$record,$module,'close');
        $focus->updateRelated_Project(array($focus->column_fields['projectid']));
    }
}

if(isset($_SESSION['lvs'][$module]['viewname'])){
				$viewid = $_SESSION['lvs'][$module]['viewname'];
				$start = $_SESSION['lvs'][$module][$viewid]['start'];
			}
if(!$start) $start = 1;
$entity['start']['value'] = $start;
require_once(globalStatic::$root_directory.'include/Zend/Json.php');
$json = new Zend_Json();                                 
$jsonentity = $json->encode($entity);            
echo $jsonentity;die;
?>