<?php
$method = $_REQUEST['method'];
crm_load_class_file('cls_CommonJsonBack','WeiXinApp/include');
$obj = new cls_CommonJsonBack();

if(method_exists($obj,$method)){
    $entity = $obj->$method();
    ConvertTojsonString(1,$entity,'success');
}else{
    ConvertTojsonString(-1,'','failed');
}

?>