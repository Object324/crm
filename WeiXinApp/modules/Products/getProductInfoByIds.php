<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//@edit:liushuai,2021-03-18,reason:【ID1001451】产品管理单据查看详情界面，相关信息关联创建自动带出产品分录信息
global $adb;
require_once globalStatic::$root_directory . 'WeiXinApp/modules/Products/getProductInfo.php';

if(!empty($_REQUEST['cartid'])){
    $version = getVersionInfo();
    //edit:duan reason:从购物车带出产品分录信息;
    $cartid = $_REQUEST['cartid'];
    $sql = "select productid,quantity,productdetail_lineitem_id from ld_shopcartdetails where cartid in ($cartid)";
    $result = $adb->pquery($sql,array());
    if($result){
        if($adb->num_rows($result) >= 1){
            for($i = 0; $i < $adb->num_rows($result); $i++){
                $productid = $adb->query_result($result,$i,'productid');
                $quantity = $adb->query_result($result,$i,'quantity');
                $productdetail_lineitem_id = $adb->query_result($result,$i,'productdetail_lineitem_id');
                //$query = 'select productid from ld_products where productid=? and deleted=0';
                //$qu_result = $adb->pquery($query, array($productid));
                if($productdetail_lineitem_id>0){
                    //zxm @date:2024/10/31 @reason: 产品开启属性 且选择了属性
                    $query = 'select ld_products.productid,ld_products.property_status,ld_productdetail.line_unit_price from ld_products left join ld_productdetail on ld_products.productid=ld_productdetail.productid where deleted=0 and ld_products.productid=? and ld_productdetail.lineitem_id=? ';
                    $qu_result = $adb->pquery($query, array($productid,$productdetail_lineitem_id));
                }else{
                    $query = 'select productid,property_status from ld_products where ld_products.productid=? and deleted=0';
                    $qu_result = $adb->pquery($query, array($productid));
                }

                if ($adb->num_rows($qu_result) > 0) {
                    $return_module = $_REQUEST['return_module'];
                    $currencyid = $_REQUEST['currencyid'];
                    $wareid = $_REQUEST['wareid'];
                    $row_id = $_REQUEST['row_id'];
                    $accountid = $_REQUEST['accvenid'];
                    $property_status = $adb->query_result($qu_result,0,'property_status');

                    
                    $jsonArray = getProductInfo($return_module, $productid, $currencyid, $wareid, $row_id, $accountid);

                    //从购物车获取产品数量
                    if($quantity>0){
                        //呼博士特殊控制
                        if($version['account'] == 'huboshi'){
                            $jsonArray['list']['quantity'] = number_format($quantity,0,".","");
                        }
                        else{
                            $jsonArray['list']['quantity'] = number_format($quantity,2,".","");
                        }
                    }
                    if($property_status==1&&$productdetail_lineitem_id>0){
                        //zxm @date:2024/10/31 @reason: 产品开启属性 且选择了属性
                        $line_unit_price = $adb->query_result($qu_result,0,'line_unit_price');
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
                            //chj 2022/7/13 订货商城结合定价策略优化
                            foreach($jsonArray['list']['pricestrategy']['info'][$productid] as $arr){
                                if($arr['count_from'] <= $quantity && $quantity <= $arr['count_to']){
                                    $jsonArray['list']['tax_amount'] = $arr['money'];
                                    //$jsonArray['list']['taxprice'] = sprintf('%.2f', $arr['money']/$quantity);
                                }
                            }
                        }

                    $arr['list'][$i] =  $jsonArray['list'];

                }
            }
            ConvertTojsonString(1, $arr, '');
        }
        
    }else{
        ConvertTojsonString('-2', array(), getFixedLabel('NOSUCHPRODUCT'));
    }
}
else if(!empty($_REQUEST['productid_qty'])){
    $productid_qty = $_REQUEST['productid_qty'];
    $productid_qtyArr = explode('&&##&&',$productid_qty);
    $productids = $productid_qtyArr[0];
    $productidsArr = explode(',',$productids);
    $qtys = $productid_qtyArr[1];
    $qtysArr = explode(',',$qtys);
    $sysdeploy = getSys_deploy(49);
    $lengthdecimaldigits = $sysdeploy['deploy_value'];

    crm_load_class_file('cls_module_api','include/Module_Api');
    $cls_module_api = new cls_module_api($_REQUEST['return_module']);
    for($i=0;$i<sizeof($productidsArr);$i++){
        $jsonArray = getProductInfo($_REQUEST['return_module'], $productidsArr[$i], $_REQUEST['currencyid'], $_REQUEST['wareid'], $_REQUEST['row_id'], $_REQUEST['accvenid']);
        //BUG20241121-87 微信小程序>销售订单新建>多选产品，任意勾选两个产品，点击确认>带到分录里面，数量字段显示的还是2位小数。然后后台已经设置的是整数 
        $jsonArray['list']['quantity'] = number_format($qtysArr[$i], (int)$lengthdecimaldigits, ".", "");

        
        $cls_module_api->setProductInfo($jsonArray['list']);
        $api_data = $cls_module_api->get();
        if(!empty($api_data)){
            foreach($api_data as $colname => $value){
                $jsonArray['list'][$colname]=$value;
            }
        }
        $arr['list'][$i] = $jsonArray['list'];
    }
    ConvertTojsonString(1, $arr, '');
}
else{
    $productid = $_REQUEST['productid'];
}