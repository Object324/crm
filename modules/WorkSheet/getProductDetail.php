<?php

$_REQUEST['diony']='yes';
$selectmodule = $_REQUEST['selectedmodule'];
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$sourcemodule_ProductDetailsHtml = $ProductDetailsHtml->getDetailobjbyEntitytype($selectmodule);
$arr['htmlcontent']=$sourcemodule_ProductDetailsHtml->create_html('edit');
$arr['headcolumn']=$sourcemodule_ProductDetailsHtml->product_columnname_arr;
ConvertToJsonString(1,$arr,'success');
?>