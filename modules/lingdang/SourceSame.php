<?php
/**
 * 判断选择源单客户是否为同一客户
 * 判断选择源单供应商是否同一供应商
 * */
 crm_load_class_file('cls_SourceSame','include/OptionModule');
global $currentModule;
$idstring=$_REQUEST['idstring'];
$obj=new cls_SourceSame($currentModule,$idstring);

echo $obj->existsSameBill();
exit();
?>