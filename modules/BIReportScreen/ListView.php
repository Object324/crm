<?php
function ConvertToJsonBIReprotScreen($code, $str, $msg, $obj = [])
{
    $json_obj = array_merge([
        'code' => $code,
        'data' => $str,
        'msg' => $msg
    ],$obj);

    @ob_clean();
    @ob_start();
    @header('Content-type: text/html;charset=utf-8');
    echo json_encode($json_obj);
    exit();
}
crm_load_class_file('BIReportScreen','modules/BIReportScreen');
$funName = $_REQUEST['funName'];
(new BIReportScreen())->$funName();

?>