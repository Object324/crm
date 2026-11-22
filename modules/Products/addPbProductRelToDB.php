<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/


global $adb,$singlepane_view;	

$idlist = vtlib_purify($_REQUEST['idlist']);

$returnmodule=vtlib_purify($_REQUEST['return_module']);
$returnaction=vtlib_purify($_REQUEST['return_action']);
$pricebook_id=vtlib_purify($_REQUEST['pricebook_id']);
$productid=vtlib_purify($_REQUEST['product_id']);
$parenttab = getParentTab();

if(isset($_REQUEST['pricebook_id']) && $_REQUEST['pricebook_id']!='')
{
    crm_load_function_file('getPriceBookCurrency','include/utils','InventoryUtils');
	$currency_id = getPriceBookCurrency($pricebook_id);
	//split the string and store in an array
	$storearray = explode(";",$idlist);
    
	foreach($storearray as $productid)
	{
		if($productid != '') {
			$lp_name = $productid.'_listprice';
			$list_price = $_REQUEST[$lp_name];
            $list_price = str_replace(",", "", $list_price);
			//Updating the lingdang_pricebook product rel lingdang_table
			$query= "insert into ld_pricebookproductrel (pricebookid,productid,listprice,usedcurrency) values(?,?,?,?)";
			//echo $query;
          //  echo json_encode(array($pricebook_id,$productid,$list_price,$currency_id));
            $adb->pquery($query, array($pricebook_id,$productid,$list_price,$currency_id));
		}
	}
    
    $_REQUEST['diony']='yes';
    ConvertTojsonString(1,array(),'success');
    
	//if($singlepane_view == 'true')
//		header("Location: index.php?module=PriceBooks&action=DetailView&record=$pricebook_id&parenttab=$parenttab");
//	else
//		header("Location: index.php?module=PriceBooks&action=CallRelatedList&record=$pricebook_id&parenttab=$parenttab");
}
elseif(isset($_REQUEST['product_id']) && $_REQUEST['product_id']!='')
{
	//split the string and store in an array
	$storearray = explode(";",$idlist);
	foreach($storearray as $id)
	{
		if($id != '') {
			$currency_id = getPriceBookCurrency($id);
			$lp_name = $id.'_listprice';
			$list_price = setNumberFormat($_REQUEST[$lp_name], null,	false);
			$query= "insert into ld_pricebookproductrel (pricebookid,productid,listprice,usedcurrency) values(?,?,?,?)";
			$adb->pquery($query, array($id,$productid,$list_price,$currency_id));
		}
	}
//	header("Location: index.php?module=$returnmodule&action=$returnaction&record=$productid&parenttab=$parenttab");
}

?>