<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/**
 * AUTHOR:BY LD KEVIN
 * DATE:20130227
 * 库存资产
 */ 
 
 function getProductsCount($scope='',$senioruserid=0,$stuffid=0,$boardid=0,$boardstuffid=0,$search_date=''){
    global $adb,$default_charset;
    $system_351 = getSys_deploy(351);//单据分录明细金额字段和单据头货币字段小数位数
    $system_deploy_351 = 2;
    if(is_numeric($system_351['deploy_value'])){
        $system_deploy_351 = $system_351['deploy_value'];    
    }

    /**新的条件解析 兼容了旧的看板start */
    $date_serach = getHomeDateScope($search_date);
    $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($boardid);
    $DataRangeHomeboardObj->getDataRangeSql($stuffid,$boardstuffid,$scope,$senioruserid,$date_serach,$_REQUEST['approve_value']);
    $datarangesqlArr = $DataRangeHomeboardObj->datarangesqlArr;
    //获取排序
    $productGenerator = $DataRangeHomeboardObj->get_query_obj('Products');
    $sortfield = $productGenerator->customview->getCustomViewOrderBy($productGenerator->customview->cvid);
    $sortfield = ' order by '.trim($sortfield,',');
    /**新的条件解析 兼容了旧的看板end */
	$query="select ld_products.productid,ld_products.productname,ld_products.unit_price,
    ld_products.qtyinstock as qtyinstock,ld_products.qtyinstock * ld_products.unit_price as productcapital";
	$queryFrom=" from ld_products ".$datarangesqlArr['datarangesql_Products'];
	$queryLimit=$sortfield."   limit 12";
    $result=$adb->query($query.$queryFrom.$queryLimit);
    $queryCountSql = "select
	sum(t.qtyinstock) AS qtyinstock,
	sum(
		t.qtyinstock * t.unit_price
	) AS productcapital from (" . $query.$queryFrom.$queryLimit . ") as t";
    //zxm BUG20241212-04
    $resultCountRes=$adb->pquery($queryCountSql);
    $resultCountRow=$adb->query_result_all($resultCountRes);
    $open_products_list=array();
    $num_rows=$adb->num_rows($result);
    if($num_rows){
        for($i=0;$i<$num_rows;$i++) 
		{
			$open_products_list[] = Array(
                'productid' => $adb->query_result($result,$i,'productid'),
                'productname' => $adb->query_result($result,$i,'productname'),
                'productqty' => $adb->query_result($result,$i,'qtyinstock'),
                'productcapital' => $adb->query_result($result,$i,'productcapital'),
            );
		}
    }
    
    $title=array();
    $product_field_obj=Field::getInstance('Products',$adb);
    $arrFieldLabel=$product_field_obj->getFieldLables();
    $header=array();
	$header[]='<span title="'.$arrFieldLabel['productname'].'">'.$arrFieldLabel['productname'].'</span>';	
    $header[]='<span title="'.$arrFieldLabel['qtyinstock'].'">'.$arrFieldLabel['qtyinstock'].'</span>';
    //BUG0054684	zxm 20220804 首页-库存资料-产品报价改为“库存金额”
	$header[] = '<span title="'.getFixedLabel('INVENTORY').getFixedLabel('AMOUNT').'">'.getFixedLabel('INVENTORY').getFixedLabel('AMOUNT').'</span>';
    
    $entries=array();
	foreach($open_products_list as $product)
	{
		$value=array();
		$Product_Name = (strlen($product['productname']) > 18) ? (mb_substr($product['productname'],0,18,$default_charset).'...') : $product['productname'];
		$value[]='<a href="javascript:;" referencemodule="Products" referencerecord="'.$product['productid'].'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" title="'.$Product_Name.'">'.$Product_Name.'</a>';
		$value[]='<span title="'.setNumberFormat($product['productqty']).'">'.setNumberFormat($product['productqty']).'</span>';
        $value[] ='<span title="¥'.setNumberFormat($product['productcapital']).'">'. '¥'.setNumberFormat($product['productcapital'],$system_deploy_351).'</span>';
		$entries[$product['productid']]=$value;	
	}
    if($num_rows){
        foreach($resultCountRow as $countrow){
            $valuecount[]= getFixedLabel('SUBTOTAL');
            $valuecount[]=setNumberFormat($countrow['qtyinstock']);
            $valuecount[]='¥'.setNumberFormat($countrow['productcapital'],$system_deploy_351);
            $entries[]=$valuecount;
        }        
    }
    $values=Array('ModuleName'=>'Products','Title'=>$title,'Header'=>$header,'Entries'=>$entries);
    if (($display_empty_home_blocks && count($entries) == 0 ) || (count($entries)>0))
		return $values;
 }
?>