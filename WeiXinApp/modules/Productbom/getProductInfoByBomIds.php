<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

// 多选产品套餐，返回所有产品信息
global $adb,$currentModule;

$productbomid_arr = [];// 产品套餐id
$productbomquantity_arr = [];// 产品套餐id对应套餐数量

$productbomid_arr = ldcrm_json_decode($_REQUEST['productbomIds']);
$productbomQtys = ldcrm_json_decode($_REQUEST['productbomQtys']);

foreach ($productbomid_arr as $index => $bomid) {
    $productbomquantity_arr[$bomid] = $productbomQtys[$index];
}
$productbomid_str = implode(',',$productbomid_arr);

// ljj 2024-11-4 XUQIU20241029-01 产品套餐字段需要能带到单据上（含移动端）选择产品套餐走选择原单业务,将明细数据带出
$_REQUEST['withproductdetail'] = 'yes';
$_REQUEST['selectmodule'] = $currentModule;
$_REQUEST['popup_selectsource'] = 'true';

$sql = "SELECT ld_products.productid,ld_products.productname,
					ld_products.unit_price,ld_products.costprice,
					ld_productbomdetail.quantity,ld_productbomdetail.taxprice,
					ld_productbom.productbomid ,ld_productbom.subject,ld_productbom.total ,ld_productbomdetail.lineitem_id 
						FROM ld_productbom 
					INNER JOIN ld_productbomdetail 
						ON ld_productbomdetail.id = ld_productbom.productbomid 
					INNER JOIN ld_products 
						ON ld_products.productid = ld_productbomdetail.productid 
					WHERE ld_productbom.deleted = 0 and ld_productbom.productbomid in ( ".$productbomid_str.") order by ld_productbom.productbomid desc";
$result = $adb->pquery($sql, array());
$num_rows = $adb->num_rows($result);

require_once globalStatic::$root_directory . 'WeiXinApp/modules/Products/getProductInfo.php';
$jsonArrays = [];
if ($num_rows > 0) {
    for($i = 0; $i<$num_rows; $i++){
        $jsonArray= [];
        $productid = $adb->query_result($result, $i, 'productid');
        $lineitem_id = $adb->query_result($result, $i, 'lineitem_id');
        $quantity = $adb->query_result($result,$i,'quantity');
        $productbomid = $adb->query_result($result, $i, 'productbomid');
        $subject = $adb->query_result($result, $i, 'subject');// 套餐名称
        $costprice = sprintf('%.2f',$adb->query_result($result,$i,'costprice'));
        $taxprice = sprintf('%.2f',$adb->query_result($result,$i,'taxprice'));

        $return_module = $_REQUEST['return_module'];
        $currencyid = $_REQUEST['currencyid'];
        $wareid = $_REQUEST['wareid'];
        $row_id = $_REQUEST['row_id'];
        $accountid = $_REQUEST['accvenid'];
        $bomquantity = floatval($productbomquantity_arr[$productbomid]);// 产品套餐的数量
        // 产品套餐信息放在最前面
        $jsonArray['list']['productbomid'] = $productbomid;
        $jsonArray['list']['productbomname'] = urlencode(vtlib_purify($subject));
        $jsonArray['list']['productbomquantity'] = $bomquantity;

        crm_load_function_file('setProductsInfo','include/utils','ListViewUtils');
        $tmp_arr = setProductsInfo($return_module,$lineitem_id,$currencyid,'',$bomquantity,'mobile');
        unset($tmp_arr['entitytype'],$tmp_arr['entitytype_module'],$tmp_arr['entitytype_transmodule'],$tmp_arr['selectSourceModuleid']);
        unset($tmp_arr['lineitem_id'],$tmp_arr['hidden_lineitem_id']);
        $tmp_arr['hdnProductId'] = $productid;
        $tmp_jsonArray['list'] = $tmp_arr;
        //$tmp_jsonArray = getProductInfo($return_module, $productid, $currencyid, $wareid, $row_id, $accountid);

        $jsonArray['list'] = array_merge($jsonArray['list'],$tmp_jsonArray['list']);

        $jsonArray['list']['productbomquantity'] = $bomquantity;// tmp_jsonArray里有productbomquantity键，但值为0，array_merge时会覆盖原本的值，所以需要重新赋值
        $jsonArray['list']['listprice'] = $taxprice;
        $jsonArray['list']['listprice'] = $taxprice;
        $jsonArray['list']['taxprice'] = $taxprice;
        $jsonArray['list']['productcost'] = $costprice;

        if($bomquantity===0||$bomquantity==='0'){
            $jsonArray['list']['quantity'] = 0;
        }
        //chj 2022/7/13 订货商城结合定价策略优化
        if($bomquantity>0){
            $jsonArray['list']['quantity'] = floatval($quantity) * $bomquantity;// 产品的数量：套餐里的产品数量 × 套餐数量
            if(!empty($jsonArray['list']['pricestrategy']['info'][$productid])){
                foreach($jsonArray['list']['pricestrategy']['info'][$productid] as $arr){
                    if($arr['count_from'] <= $jsonArray['list']['quantity'] && $jsonArray['list']['quantity'] <= $arr['count_to']){
                        $jsonArray['list']['tax_amount'] = $arr['money'];
                        //$jsonArray['list']['taxprice'] = sprintf('%.2f', $arr['money']/$quantity);
                    }
                }
            }
        }

        //接口调用
        crm_load_class_file('cls_module_api','include/Module_Api');
        $cls_module_api = new cls_module_api($return_module);
        $cls_module_api->setProductInfo($jsonArray['list']);
        $api_data = $cls_module_api->get();
        if(!empty($api_data)){
            foreach($api_data as $colname => $value){
                $jsonArray['list'][$colname]=$value;
            }
        }

        // dump($jsonArray['list']);
        $jsonArrays['list'][$i] = $jsonArray['list'];

    }
    ConvertTojsonString(1, $jsonArrays, '');

} else {
    ConvertTojsonString('-2', array(), getFixedLabel('NOSUCHPRODUCT'));
}