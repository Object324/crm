<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
$productcode=$_REQUEST['qrcodeinfo'];
$arr=json_decode($info,true);
$sql='select productid,productcode from ld_products where productcode=? and deleted=0';

$result=$adb->pquery($sql,array($productcode));

if($adb->num_rows($result)>0)
{
    if($adb->num_rows($result)==1)
    {
        $productid=$adb->query_result($result,0,'productid');
        
        if(empty($productid)){
            ConvertTojsonString('-2',array(),getFixedLabel('NOSUCHPRODUCTCONTINUECREATING'));
        }
//        $_REQUEST['productid']=$productid;
//        include(globalStatic::$root_directory.'WeiXinApp/modules/Products/ProductInfo.php');
//@edit:liushuai,2021-03-18,reason:【ID1001451】产品管理单据查看详情界面，相关信息关联创建自动带出产品分录信息
        $return_module = $_REQUEST['return_module'];
//        $productid = $_REQUEST['productid'];
        $currencyid = $_REQUEST['currencyid'];
        $wareid = $_REQUEST['wareid'];
        $row_id = $_REQUEST['row_id'];
        $accountid = $_REQUEST['accvenid'];
        require globalStatic::$root_directory.'WeiXinApp/modules/Products/getProductInfo.php';
        $jsonArray = getProductInfo($return_module, $productid, $currencyid, $wareid, $row_id, $accountid);
        ConvertTojsonString(1,$jsonArray,'');
    }
    else{
        crm_load_class_file('cls_QrCodeListWX','WeiXinApp/modules/Products/cls_Products');
        $selectmodule='Products';
        $_REQUEST['searchcontent']=$productcode;
        $mobj = new cls_QrCodeListWX($selectmodule);
        $poptype = 'popup';
        $title = getTranstab($selectmodule);
         $details = $mobj->get_listdetail($poptype, 'PopQueryGeneratorWX');
        $details['poptitle'] = '关联' . $title;
        $details['showQuickCreate'] = 'yes';
        unset($details['list']);
        unset($details['listtab']);
        ConvertTojsonString(2, $details, 'success');
    }
    
}
else
{
    if(isPermitted('Products','Create','') == 'yes'){
        ConvertTojsonString('-2',array(),getFixedLabel('NOSUCHPRODUCTCONTINUECREATING'));
    }
    else{
        ConvertTojsonString('no_products_create',array(),getFixedLabel('SCANNINGPRODUCTNOTEXIST'));
    }
}
?>