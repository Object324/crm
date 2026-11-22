<?php
$_REQUEST['diony']='diony';
$versionAccount = getVersionInfo()['account'];

if ($versionAccount == 'yilin') {
    crm_load_class_file('cls_module_sql','include/Module_Api');
    $cls_module_sql = new cls_module_sql($_REQUEST['frommodule']);
    $productInfo = [];
    //ls 240129 XUQIU20240125-03 深圳市意林电锁订单增加录单预警功能（徐江平）
    $productid = trim($_REQUEST['productid']);
    $warehousename = trim($_REQUEST['sf4882']);
    if (empty($productid) || empty($warehousename)) {
        ConvertTojsonString(-1,[],"productid or sf4882 not null");
    }

    //$productInfo['hdnProductId'] = $productid;
    $productInfo['productid'] = $productid;
    $productInfo['sf4882'] = $warehousename;
    $cls_module_sql->setProductInfo($productInfo);

    $data = $cls_module_sql->get();
}

// @edit:dong @date:2024/10/15 @reason: 中山佳建
if ($versionAccount == 'zsjiajian'){

    crm_load_class_file('cls_module_api_link2erp','include/Module_Api');
    $cls_module_sql = new cls_module_api_link2erp($_REQUEST['frommodule']);
    $productInfo = [];
    $productid = trim($_REQUEST['productid']);
    $warehousename = trim($_REQUEST['sf6309']);
    if (empty($productid) || empty($warehousename)) {
        ConvertTojsonString(-1,[],"productid or sf6309 not null");
    }

    //$productInfo['hdnProductId'] = $productid;
    $productInfo['productid'] = $productid;
    $productInfo['sf6309'] = $warehousename;
    $cls_module_sql->setProductInfo($productInfo);

    $data = $cls_module_sql->get();

}



ConvertTojsonString(1,$data,"success");

?>