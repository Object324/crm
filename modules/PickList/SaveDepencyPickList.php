<?php
require_once 'modules/PickList/DependentPickListUtils.php';
$dependencymapping=vtlib_purify($_REQUEST['dependencymapping']);
$dependencymapping=json_decode($dependencymapping,true);

$module=$_REQUEST['moduleName'];
$tabid=getTabid($module);
global $adb,$current_user;
if($current_user->getHaveSetProfile("Settings")!="yes")
{
    exit();
}
$sourceField=$dependencymapping['sourcefield'];
$targetField=$dependencymapping['targetfield'];


foreach($dependencymapping['valuemapping'] as $index=>$depencycontent)
{
    $sourceValue=$depencycontent['sourcevalue'];
 //  $sourceValues[]="'".$sourceValue."'";
   
    lingdang_DependencyPicklist::savePickListDependencies($module,$sourceField,$targetField,$sourceValue,$depencycontent['targetvalue']);
    
}
$tabid=getTabid($module);
/*
$sql='delete from ld_picklist_dependency where tabid=? and sourcefield=? AND targetfield=? and 
sourcevalue not in(  '.implode($sourceValues,",").")";
$adb->pquery($sql,array($tabid,$sourceField,$targetField));
*/
 if(function_exists('opcache_invalidate'))
    {
        opcache_invalidate(globalStatic::$root_directory.'dataCache/picklist/datacache_'.$module.'_pickdepencylist.php',true);
         
         
    }
  @unlink(globalStatic::$root_directory.'dataCache/picklist/datacache_'.$module.'_pickdepencylist.php');
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');

exit();
?>