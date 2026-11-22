<?php

 $_REQUEST['diony']='yes';
global $adb,$currentModule,$current_user;
$selectid=$_REQUEST['selectid'];//


crm_load_class_file('cls_getLangJiePurchaseOrderInfo','modules/CustomForm19');
$obj=new cls_getLangJiePurchaseOrderInfo($_REQUEST['selectmodule'],$selectid);

ConvertTojsonString(1,$obj->getData(),'success');


?>