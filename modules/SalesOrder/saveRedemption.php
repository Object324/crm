<?php
crm_load_class_file('cls_fund_Redemption','include/trade/Jijin');
cls_fund_Redemption::save();
$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
?>