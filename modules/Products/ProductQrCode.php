<?php
require_once globalStatic::$root_directory . '/vendor/autoload.php';
global $adb;
global $currentModule, $current_user, $theme, $singlepane_view;
$record = $_REQUEST['record'];
//根据id查询编码或条码字段是否开启
$focus = CRMEntity::getInstance($currentModule);
$fieldobj = $focus->fieldobj;
$focus->id = $record;
$field_info = $fieldobj->getFieldInfoobjBykey("columnname",'productcode');
if(empty($field_info)){
    ConvertTojsonString(-1,[],getFixedLabel('PRODUCTQRCODETIPS'));
}
//根据id查询编码或条码字段是否有值
$select_sql = "select productid,productcode,product_no from ld_products where productid=? and deleted=0";
$res = $adb->pquery($select_sql,[$record]);
$nums = $adb->num_rows($res);
$productcode = '';
if($nums>0){
    $productcode = $adb->query_result($res,0,'productcode');
    $product_no =  $adb->query_result($res,0,'product_no');
}
if(empty($productcode)){
    ConvertTojsonString(-1,[],getFixedLabel('PRODUCTQRCODETIPS'));
}

//递归创建目录
$dirpath_qr = 'storage/products/qrcode';
$dirpath_bar = 'storage/products/barcode';
if(!is_dir($dirpath_qr)){
    mkdir($dirpath_qr,999,true);
}
if(!is_dir($dirpath_bar)){
    mkdir($dirpath_bar,999,true);
}
//生成二维码
$imageQr= $dirpath_qr.'/'.$record.'-'.$product_no.'.jpg';
$builder = new Endroid\QrCode\Builder\Builder();
$builder
    ->data($productcode)
    ->size(300)
    ->ForegroundColor(new Endroid\QrCode\Color\Color(0,0,0))
    ->BackgroundColor(new Endroid\QrCode\Color\Color(255,255,255))
    // ->labelText($productcode)
    ->margin(10);
$result = $builder->build();
file_put_contents($imageQr, $result->getString());

//生成条形码
$imageBar= $dirpath_bar.'/'.$record.'-'.$product_no.'.jpg';
$generator = new Picqer\Barcode\BarcodeGeneratorJPG();
file_put_contents($imageBar, $generator->getBarcode($productcode, $generator::TYPE_CODE_128,1,25));

$_REQUEST['diony'] = 'yes';
//加后缀防止缓存
ConvertTojsonString(1,['qrcode'=>$imageQr.'?a='.rand(0,9999),'barcode'=>$imageBar.'?a='.rand(0,9999)],'success');
