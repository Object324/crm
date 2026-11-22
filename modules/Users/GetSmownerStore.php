<?php

/*中能 特殊控制   
*	选择负责人带出对应的门店
*/
global $PlatformMC;
if(!empty($_REQUEST['smownerid'])){
	$userid = $_REQUEST['smownerid'];
	$focus = CRMEntity::getInstance('Users');
	$focus->retrieve_entity_info($userid, 'Users');
	$wareid = $focus->column_fields['wareid'];
    if(!empty($PlatformMC)){
        $wareinfo = getWarehouseInfo($wareid);
        $warename = $wareinfo['name'];
        ConvertTojsonString(1,array('wareid'=>$wareid,'warename'=>$warename),'success');
    }else{
        echo $wareid;
    }
	
}else if(!empty($_REQUEST['prdid'])){
	$wareid = $_REQUEST['wareid'];
	$proid = explode(',', $_REQUEST['prdid']);
	crm_load_function_file('getZN_ProductQty','include/utils','ListViewUtils');
	foreach($proid as $productid){
		if($productid > 0){
			$value = getZN_ProductQty($productid,$wareid);
			$data[$productid] = $value;
		}
	}
    if(!empty($PlatformMC)){
        ConvertTojsonString(1,$data,'success');
    }else{
        $jsonentity = Zend_Json::encode($data);
	    echo $jsonentity;
    }
}
exit();
?>