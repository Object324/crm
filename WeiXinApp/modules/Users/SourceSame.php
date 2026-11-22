<?php
/**
 * 判断选择源单客户是否为同一客户
 * 判断选择源单供应商是否同一供应商
 * */
 crm_load_class_file('cls_SourceSame','include/OptionModule');

$idstring=$_REQUEST['idstring'];
$module = $_REQUEST['frommodule'];
$obj=new cls_SourceSame($module,$idstring);

$msg = $obj->existsSameBill();

if($msg=='success'){
    ConvertTojsonString(1,array(),'success');
}else{
    
    $errormsg = explode('$$##error###$$$',$msg);
    ConvertTojsonString(-1,array(),$errormsg[1]);
}
exit();
?>