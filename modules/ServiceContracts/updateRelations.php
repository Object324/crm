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
require_once('include/database/PearDatabase.php');
@include_once('user_privileges/default_module_view.php');

global $adb, $singlepane_view, $currentModule;
$idlist            = vtlib_purify($_REQUEST['idlist']);
$destinationModule = vtlib_purify($_REQUEST['destination_module']);
$parenttab         = getParentTab();

$forCRMRecord = vtlib_purify($_REQUEST['parentid']);
$mode = $_REQUEST['mode'];

if($singlepane_view == 'true')
	$action = "DetailView";
else
	$action = "CallRelatedList";

$focus = CRMEntity::getInstance($currentModule);

if($mode == 'delete') {
	// Split the string of ids
	$ids = explode (";",$idlist);
	if(!empty($ids)) {
		$focus->delete_related_module($currentModule, $forCRMRecord, $destinationModule, $ids);
	}
} else {
	if(!empty($_REQUEST['idlist'])) {
		// Split the string of ids
		$ids = explode (";",trim($idlist,";"));
	} else if(!empty($_REQUEST['entityid'])){
		$ids = $_REQUEST['entityid'];
	}
	if(!empty($ids)) {
	           /*
        andrew 
        20140226
        服务合同添加服务次数统计，计数加1
        */
        if($currentModule=='ServiceContracts'&&$destinationModule=='HelpDesk'){
            if(is_array($ids)){
                foreach($ids as $arr){
                               $csdl =$adb->pquery("SELECT * FROM ld_crmentityrel where crmid=? and relcrmid=?",array($forCRMRecord,$arr));
            $rowCount = $adb->num_rows($csdl);
     
            if($rowCount==0){
       	        $su_qry = $adb->pquery("select service_units from ld_servicecontracts where servicecontractsid=?", array($forCRMRecord));
	            $service_units = $adb->query_result($su_qry,0,"service_units");
    
            if(empty($service_units)){
                $service_units=1;
            }else{
                $service_units=$service_units+1;
            }
            $adb->pquery("update ld_servicecontracts set service_units=$service_units where servicecontractsid=?", array($forCRMRecord));
        
                }
                }
            }else{
                           $csdl =$adb->pquery("SELECT * FROM ld_crmentityrel where crmid=? and relcrmid=?",array($forCRMRecord,$ids));
            $rowCount = $adb->num_rows($csdl);
      
            if($rowCount==0){
       	        $su_qry = $adb->pquery("select service_units from ld_servicecontracts where servicecontractsid=?", array($forCRMRecord));
	            $service_units = $adb->query_result($su_qry,0,"service_units");
    
            if(empty($service_units)){
                $service_units=1;
            }else{
                $service_units=$service_units+1;
            }
            $adb->pquery("update ld_servicecontracts set service_units=$service_units where servicecontractsid=?", array($forCRMRecord));
        
            }
            }
 
        }
        
		relateEntities($focus, $currentModule, $forCRMRecord, $destinationModule, $ids);
       

	}
}
header("Location: index.php?module=$currentModule&record=$forCRMRecord&action=$action&parenttab=$parenttab");
?>