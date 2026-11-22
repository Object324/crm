<?php

 $_REQUEST['diony']='yes';
global $adb,$currentModule,$current_user;
$selectid=$_REQUEST['selectid'];//


crm_load_class_file('cls_getLangJieSalesOrderInfo','modules/CustomForm18');
$obj=new cls_getLangJieSalesOrderInfo($_REQUEST['selectmodule'],$selectid);

ConvertTojsonString(1,$obj->getData(),'success');


?>