<?php
/**
 * edit:cyb
 * date:2015-10-27
 * reason:设置查重字段
 **/
global $adb,$current_user;
$setmodule = $_REQUEST['setmodule'];
$focus=CRMEntity::getInstance($setmodule);
if($_REQUEST['settype']=='save'){
    $SQL = 'UPDATE ld_field SET duplicatefield=0 WHERE tabid=(SELECT tabid FROM ld_tab WHERE name=?) AND fieldid IN ('.$_REQUEST['checklist'].')';
    
    $adb->pquery($SQL,array($setmodule));
    $SQL = 'UPDATE ld_field SET duplicatefield=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE name=?) AND fieldid NOT IN ('.$_REQUEST['checklist'].')';
    
    $adb->pquery($SQL,array($setmodule));
    $arrfields=$focus->getSelectOption();
     
    //清除字段缓存
     unsetCacheDirectory('fields');  
    exit();
}



$tabarray = $focus->tab_name;

foreach($tabarray as $key=>$arr){
    $tabarray[$key]=strtolower($arr);
}
$entityfieldname = getEntityFieldNames($module);
$entityname = $entityfieldname['fieldname'];
$smarty = new lingdangCRM_Smarty;
$frommodule = $_REQUEST['frommodule'];
$smarty->assign("FROMMODULE",$frommodule);
$smarty->assign("TYPE",$_REQUEST['type']);
$setDupFieldList = setSearchFieldList($setmodule,$tabarray);
$smarty->assign("MODULE",$setmodule);
$smarty->assign("SETDUPFIELDLIST",$setDupFieldList);
$smarty->display("setDuplicateField.tpl");
exit();

function setSearchFieldList($setmodule,$tabarray){    
    global $adb,$current_user;    
    $languageType= getLanguageType($current_user);
    $fieldobj=Field::getInstance($setmodule,$adb);
    $modulefields=$fieldobj->getModuleFields();
    foreach($modulefields as $fieldname=>$fieldinfo)
    {
        
        $tablename =$fieldinfo->getTableName();
        
        if($fieldinfo->getDisplaytype()==1){
            $fieldid=$fieldinfo->getFieldid();           
            $fieldlist[$fieldid]['fieldlabel']=$fieldinfo->getFieldLabelKey();
            $fieldlist[$fieldid]['columnname']=$fieldinfo->getColumnName();
            $fieldlist[$fieldid]['duplicatefield']=$fieldinfo->getduplicatefield();
            $fieldlist[$fieldid]['tablename']=$tablename;
        }
    }    
    return $fieldlist;
    
}
?>