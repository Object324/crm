<?php
/*********************************************************************************
  *{*修改编码格式:统一编码：UTF-8*} 
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
  * ("License"); You may not use this file except in compliance with the License
  * The Original Code is:  lingdang CRM Open Source
  * The Initial Developer of the Original Code is lingdang.
  * Portions created by lingdang are Copyright (C) lingdang.
  * All Rights Reserved.
 *
  ********************************************************************************/
 if(!empty($_REQUEST['accountid']) && !empty($_REQUEST['frommodule'])){
	global $current_user;
	$languageType= getLanguageType($current_user);
	crm_load_class_file('ProductToolFields','include/ProductDetails');
	$producttoolfieldobj =  new ProductToolFields($_REQUEST['frommodule']);
	$tabid = getTabid($_REQUEST['frommodule']);
	$ModuleProductToolField = $producttoolfieldobj->getModuleProductToolField($tabid,$languageType);
	$productids = $_REQUEST['productids'];
	$productid_arr = explode(',',$productids);
	$sysdeploys = getSys_deploy(93);	// 系统参数控制单价小数位
    $currencyid = $_REQUEST['currency_id'];    
	foreach($productid_arr as $productid){
		if(!empty($productid)){
			foreach($ModuleProductToolField as $toolfield){
				//最近价格(未税)	最近价格(含税)
				if($toolfield->getColumnName() == 'lastlistprice' || $toolfield->getColumnName() == 'lasttaxprice'){
					if($toolfield->getUIType() == 730 || $toolfield->getUIType() == '810'){
						crm_load_function_file('getLastPrice','include/utils','InventoryUtils');
						$lastprice = getLastPrice($_REQUEST['frommodule'],$productid,$_REQUEST['accountid'],$toolfield->getUIType(),$currencyid);
						foreach($lastprice as $key => $value){
							if($value == null)$value = 0;
							$value = sprintf('%.'.$sysdeploys['deploy_value'].'f',$value);
							$lastprice[$key] = $value;
						}
						
						$lastpricearr[$productid] = $lastprice;
					}
				}
			}
		}
	}
    global $PlatformMC;//注意：微信直接调用此文件
    if((!empty($PlatformMC)&&$PlatformMC['type']=='weixin')||$_REQUEST['responseType']=='htmlfive'){
        ConvertTojsonString(1,$lastpricearr,'');
    }else{
        require_once('./include/Zend/Json.php');
    	$json = new Zend_Json();
    	$jsonentity = $json->encode($lastpricearr);
    	echo $jsonentity;die;
    }
	
 }
?>