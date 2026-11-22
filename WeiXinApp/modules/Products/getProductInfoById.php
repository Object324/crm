<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//@edit:liushuai,2021-03-18,reason:【ID1001451】产品管理单据查看详情界面，相关信息关联创建自动带出产品分录信息
global $adb;
$productdetail_lineitem_id = 0;
if(!empty($_REQUEST['cartid'])){
    //edit:duan reason:从购物车带出产品分录信息;
    $cartid = $_REQUEST['cartid'];
    $sql = 'select productid,quantity,productdetail_lineitem_id from ld_shopcartdetails where cartid = ?';
    $result = $adb->pquery($sql,array($cartid));
    if($result){
        $productid = $adb->query_result($result,0,'productid');
        $quantity = $adb->query_result($result,0,'quantity');
        $productdetail_lineitem_id = $adb->query_result($result,0,'productdetail_lineitem_id');//产品属性id
    }else{
        ConvertTojsonString('-2', array(), getFixedLabel('NOSUCHPRODUCT'));
    }
}else{
    $productid = $_REQUEST['productid'];
    if(!empty($_REQUEST['productidqyt']) || $_REQUEST['productidqyt'] == '0'){
        $quantity = $_REQUEST['productidqyt'];
    }
}
if($productdetail_lineitem_id>0){
    $sql = 'select ld_products.productid,ld_products.property_status,ld_productdetail.line_unit_price from ld_products left join ld_productdetail on ld_products.productid=ld_productdetail.productid where deleted=0 and ld_products.productid=? and ld_productdetail.lineitem_id=? ';
    $result = $adb->pquery($sql, array($productid,$productdetail_lineitem_id));
}else{
    $sql = 'select productid,property_status from ld_products where productid=? and deleted=0';
    $result = $adb->pquery($sql, array($productid));
}


if ($adb->num_rows($result) > 0) {
    $return_module = $_REQUEST['return_module'];
    $currencyid = $_REQUEST['currencyid'];
    $wareid = $_REQUEST['wareid'];
    $row_id = $_REQUEST['row_id'];
    $accountid = $_REQUEST['accvenid'];
    $property_status = $adb->query_result($result,0,'property_status');

    require globalStatic::$root_directory . 'WeiXinApp/modules/Products/getProductInfo.php';
    $jsonArray = getProductInfo($return_module, $productid, $currencyid, $wareid, $row_id, $accountid);
	if($quantity===0||$quantity==='0'){
        $jsonArray['list']['quantity'] = 0;
	}
    //chj 2022/7/13 订货商城结合定价策略优化
    if($quantity>0){
        $jsonArray['list']['quantity'] = $quantity;
        if($property_status==1&&$productdetail_lineitem_id>0){
            //zxm @date:2024/10/31 @reason: 产品开启属性 且选择了属性
            $line_unit_price = $adb->query_result($result,0,'line_unit_price');
            $jsonArray['list']['taxprice'] = sprintf('%.2f', $line_unit_price);
            $jsonArray['list']['tax_amount'] = $line_unit_price*$quantity;
            $jsonArray['list']['productdetail_lineitem_id'] = $productdetail_lineitem_id;
            crm_load_class_file('ProductPropertyUtils','modules/Products');
            $productproperty_info = ProductPropertyUtils::getPropertyInfoByProductDetailId($productdetail_lineitem_id);
            if(isset($productproperty_info[$productdetail_lineitem_id])){
                $jsonArray['list']['productdetail_lineitem_id_value'] = implode(',',$productproperty_info[$productdetail_lineitem_id]['productdetail_lineitem_id_value']);
            }else{
                $jsonArray['list']['productdetail_lineitem_id_value'] = "";
            }

        }else
            if(!empty($jsonArray['list']['pricestrategy']['info'][$productid])){
			foreach($jsonArray['list']['pricestrategy']['info'][$productid] as $arr){
				if($arr['count_from'] <= $quantity && $quantity <= $arr['count_to']){
					$jsonArray['list']['tax_amount'] = $arr['money'];
					//$jsonArray['list']['taxprice'] = sprintf('%.2f', $arr['money']/$quantity);
				}
			}
		}
    }

    //接口调用
    crm_load_class_file('cls_module_api','include/Module_Api');
    $cls_module_api = new cls_module_api($_REQUEST['return_module']);
    $cls_module_api->setProductInfo($jsonArray['list']);
    $api_data = $cls_module_api->get();
    if(!empty($api_data)){
        foreach($api_data as $colname => $value){
            $jsonArray['list'][$colname]=$value;
        }
    }

    ConvertTojsonString(1, $jsonArray, '');

} else {
    ConvertTojsonString('-2', array(), getFixedLabel('NOSUCHPRODUCT'));
}