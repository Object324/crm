<?php
$module=$_REQUEST['moduleName'];
$sourceField=$_REQUEST['sourcefield'];
$targetField=$_REQUEST['targetfield'];

$picktext=$_REQUEST['picktext'];
global $adb,$current_user;
if($current_user->getHaveSetProfile("Settings")=="yes"){
     $_REQUEST['diony']='yes';
    $sql="select * from ld_picklist_dependency where tabid=? and sourcefield=? and targetfield=? and sourcevalue=?";
  
    $tabid=getTabid($module);
   
    $result=$adb->pquery($sql,array($tabid,$sourceField,$targetField,$picktext));
    if($adb->num_rows($result)>0)
    {
        $targetValues=$adb->query_result($result,0,'targetvalues');
        
        $arr['picklist'] = Zend_Json::decode(html_entity_decode($targetValues));
        ConvertTojsonString(1,$arr,"success");
    }
    else
    {
        $arr['picklist']=array();
    }
   
    ConvertTojsonString(1,$arr,"success");
    
}

?>