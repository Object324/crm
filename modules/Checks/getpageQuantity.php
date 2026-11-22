<?php

//获取账面数量
//盘点新增界面修改批次
global $adb;
crm_load_function_file('getProductQtySaveOrCheck','include/Stock','CommonStock');
$productid=$_REQUEST['productid'];
$wareid=$_REQUEST['wareid'];
$tmpbatchtext=$_REQUEST['batchtext'];

$tmpproductqtys= getProductQtySaveOrCheck($productid,$wareid,$tmpbatchtext);
if(array_key_exists($productid,$tmpproductqtys))
{
    if($tmpbatchtext=='')
    {
     
        $pagequantity=$tmpproductqtys[$productid][$wareid][DEFAULTBATCHTEXT];
    }
    else
    {
        $pagequantity=$tmpproductqtys[$productid][$wareid][$tmpbatchtext];
    }
}
$_REQUEST['diony']='yes';
if(empty($pagequantity))
{
    $pagequantity=0;
}
$deploy_values=getSys_deploy(49);
$lengthdecimaldigits=$deploy_values['deploy_value'];

$arr['pagequantity']=number_format($pagequantity,$lengthdecimaldigits,".","");
ConvertTojsonString(1,$arr,'success');

?>