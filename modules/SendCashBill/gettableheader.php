<?php
crm_load_class_file('cls_SendCashBill_EntityHtml','modules/SendCashBill/EntityData');
ob_clean();
$obj_entity=new cls_SendCashBill_EntityHtml('0',"",$_REQUEST['sourcemodule']);

$arr['content']= $obj_entity->getTableHeader();
$arr['tdspan']=sizeof($obj_entity->table_header)+1;
$_REQUEST['diony']='yes';
ConvertTojsonString(1,$arr,"success");
exit();
?>