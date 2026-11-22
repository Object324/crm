<?php
//服务合同选择合同订单，当销售机会有产品明细

$selectmodule=$_REQUEST['selectmodule'];
$selectid=$_REQUEST['selectid'];
$frommodule=$_REQUEST['frommodule'];
$focus=CRMEntity::getInstance($frommodule);
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$frommodule/ProductDetails",array($frommodule));
$VersionInfo = getVersionInfo();
$so_focus = CRMEntity::getInstance($selectmodule);
$so_focus->lineitemIds = getLineitemId($selectid,$selectmodule);
            
$so_focus->mode = 'edit';
$so_focus->id=$selectid;
//克莱门特：仅当关联的销售合同的合同性质是”维保合同“时才能保存。
if($VersionInfo['account'] == 'climaveneta'&&$frommodule=='ServiceContracts'&&$selectmodule=='SalesOrder'){
					$so_focus->retrieve_entity_info($selectid, 'SalesOrder');
				//	$smarty->assign('ORDERTYPE',$so_focus->column_fields['cf_2323']);
					//$smarty->assign('VERSION_ACCOUNT',$VersionInfo['account']);
}

$_REQUEST['diony']='yes';

if($_REQUEST['adddetails']=='yes'){
    $ProductDetailsHtml->ProductDetailsData->adddetails = 'yes';
}
$arr['content']=$ProductDetailsHtml->getProductDetailsHtml($so_focus,'module_create');
$arr['detaildatavalues'] = $ProductDetailsHtml->productToolFieldsValues;
ConvertTojsonString(1,$arr,'success');


?>