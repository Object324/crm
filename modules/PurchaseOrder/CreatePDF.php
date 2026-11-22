<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 ********************************************************************************/
include_once 'modules/PurchaseOrder/PurchaseOrderPDFController.php';
$controller = new lingdang_PurchaseOrderPDFController($currentModule);
$controller->loadRecord(vtlib_purify($_REQUEST['record']));
//$purchaseorder_no = getModuleSequenceNumber($currentModule,vtlib_purify($_REQUEST['record']));
//$controller->Output('PurchaseOrder_'.$purchaseorder_no.'.pdf', 'D');//added file name to make it work in IE, also forces the download giving the user the option to save
exit();
?>