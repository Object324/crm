<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/

require_once('include/database/PearDatabase.php');
require_once('user_privileges/default_module_view.php');

global $adb;
if(!empty($_REQUEST['entitytypeid'])){
    $fieldobjs=Field::getInstance("SalesOrder",$adb);
   	$data['code'] = 1;
    if($fieldobjs->getFieldInfoBykeyValue("columnname",'overdue_date','fieldname')=='')
    {
        
    }
    else
    {
        $entitytypeid_array = array();
    	$entitytypeids = explode(',',$_REQUEST['entitytypeid']);
    	foreach($entitytypeids as $id){
    		$entitytypeid_array[$id] = $id;
    	}
    
    	$error = array();
    	foreach($entitytypeid_array as $id){
    		if($id > 0){
    		  
    			$query = 'select overdue_date,salesorder_no from ld_salesorder where salesorderid = ? and deleted = 0';
                //echo $id;
                //exit();
    			$result= $adb->pquery($query,array($id));
    			$overdue_date = $adb->query_result($result,0,0);
    			$salesorder_no = $adb->query_result($result,0,1);
    			if(!empty($overdue_date) && $overdue_date != '0000-00-00' && $overdue_date < date('Y-m-d')){
    				$error[] = '该销售合同【'.$salesorder_no.'】设定的逾期时间已经逾期，逾期时间为：' . $overdue_date;
    			}
    		}
    	}
    
    	if(count($error) >= 1){
    		$data['code'] = 2;
    		$data['error'] = implode('<br>',$error);
    	}
    }
	
	require_once('./include/Zend/Json.php');
	$json = new Zend_Json();
	$jsonentity = $json->encode($data);
	echo $jsonentity;die;
}

?>