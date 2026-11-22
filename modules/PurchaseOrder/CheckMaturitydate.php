<?php
crm_load_class_file('CheckMaturitydate','modules/lingdang');

$relate_id = $_REQUEST['vendorid'];

$obj=new CheckMaturitydate('Vendors',$relate_id);
$obj->ret_Check();
?>