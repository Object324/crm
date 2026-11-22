<?php
global $adb;
require_once(globalStatic::$root_directory.'modules/Quotes/Haigequotefunction.php');
$_REQUEST['diony']='yes';
$arr=array();
if(isset($_REQUEST['record'])&&$_REQUEST['record']>0){
    $record = $_REQUEST['record'];
    $module = $_REQUEST['module'];
    $check_type = $_REQUEST['check_type'];
    if($check_type=='order'){
        //检查是否有出货记录
        $deal_info = CheckProductDetail($record);
        $num_rows = sizeof($deal_info);
        if($num_rows>0){
            $arr['deal_info'] = $deal_info;
            $arr['num_row'] = $num_rows;
        }else{
            $arr['num_row'] = $num_rows;
        }
    }else if($check_type=='discount'){
        //检查此次添加产品的产品组是否已存在
        $productid = $_REQUEST['productid'];
        $arr = CheckProductGroup($record,$productid);
    }
}

ConvertTojsonString(1,$arr,'success');


?>