<?php
crm_load_class_file('CheckMaturitydate','modules/lingdang');

$relate_id = $_REQUEST['accountid'];

$obj=new CheckMaturitydate('Accounts',$relate_id);
$obj->ret_Check();
?>