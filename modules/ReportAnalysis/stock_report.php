<?php
global $adb,$theme,$current_user;

if(!file_exists(globalStatic::$root_directory.'user_privileges/Config_ERP_Api.php') && file_exists(globalStatic::$root_directory.'user_privileges/Config_ERP_Api_Default.php')) {
    copy(globalStatic::$root_directory.'user_privileges/Config_ERP_Api_Default.php',globalStatic::$root_directory.'user_privileges/Config_ERP_Api.php');
}
require_once(globalStatic::$root_directory.'user_privileges/Config_ERP_Api.php');
$is_ajax = $_REQUEST['is_ajax'];
$_REQUEST['diony']='yes';

$stock_view = getErpStockView();
if(strpos(strtolower($stock_view),'erp')===false) {
    ConvertTojsonString(-1,array(),'库存查询未授权或者Config_ERP_Api配置文件未配置');
}

// @edit:dong @date:2024/04/12 @reason:  没有找到类似方法先增加到这里。
if(!function_exists('arrayKeyToLower')){
    function arrayKeyToLower($array)
    {
        if (is_array($array)) {
            $array = array_change_key_case($array, CASE_LOWER);
            foreach ($array as $key => $value) {
                if (is_array($value)) {
                    $array[$key] = arrayKeyToLower($value);
                }
                if (is_object($value)) {
                    $array[$key] = arrayKeyToLower(object_array($value));
                }
            }
        }
        if (is_object($array)) {
            $array = arrayKeyToLower(object_array($array));
        }
        return $array;
    }

}
if(!function_exists('object_array')){
    function object_array($array)
    {
        if (is_object($array)) {
            $array = (array)$array;
        }
        if (is_array($array)) {
            foreach ($array as $key => $value) {
                $array[$key] = object_array($value);
            }
        }
        return $array;
    }
}


if (Config_ERP_Api::$product_type == 'k3') {
    require_once(globalStatic::$root_directory . 'modules/ReportAnalysis/stock_report_k3.php');
} elseif (Config_ERP_Api::$product_type == 'u8') {
    require_once(globalStatic::$root_directory . 'modules/ReportAnalysis/stock_report_u8.php');
} elseif (Config_ERP_Api::$product_type == 'k3cloud') {
    require_once(globalStatic::$root_directory . 'modules/ReportAnalysis/stock_report_k3cloud.php');
} elseif (Config_ERP_Api::$product_type == 'tcloudnew') {
    require_once(globalStatic::$root_directory . 'modules/ReportAnalysis/stock_report_tcloudnew.php');
}elseif (Config_ERP_Api::$product_type == 'u9c') {
    require_once(globalStatic::$root_directory . 'modules/ReportAnalysis/stock_report_u9c.php');
} else {
    ConvertTojsonString(-1, array(), '库存查询配置错误，检查user_privileges/Config_ERP_Api.php中$product_type的值');
}


