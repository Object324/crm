<?php
/**
 * zxm
 * 2020-1223
 * 移动端增加待办菜单 审批数据 销售助手信息数据
 */
global $adb,$current_user;
crm_load_class_file('cls_ApproveFunctions','WeiXinApp/modules/Approve');
$obj = new cls_ApproveFunctions();
$method = $_REQUEST['method'];

if(method_exists ($obj,$method)){
    $obj->$method();
}else{
    ConvertTojsonString('-1',null,getFixedLabel('PARAMETERINPUTERROR'));
}
?>

