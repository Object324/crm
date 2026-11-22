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

require_once('include/utils/utils.php');

class RecurringInvoiceHandler extends VTEventHandler {
	public function handleEvent($handlerType, $entityData){
		global  $adb;
		$moduleName = $entityData->getModuleName();
		if ($moduleName == 'CustomForm165') {
			$soId = $entityData->getId();
			$data = $entityData->getData();
			if($data['enable_recurring'] == 'on' || $data['enable_recurring'] == 1) {
				$frequency = $data['recurring_frequency'];
				$startPeriod = getValidDBInsertDateValue($data['start_period']);
				$endPeriod = getValidDBInsertDateValue($data['end_period']);
				$paymentDuration = $data['payment_duration'];
				$invoiceStatus = $data['invoicestatus'];
				if (isset($frequency) && $frequency != '' && $frequency != '--None--') {
					$check_query = "SELECT * FROM ld_invoice_recurring_info WHERE customform165id=?";
					$check_res = $adb->pquery($check_query, array($soId));
					$noofrows = $adb->num_rows($check_res);
					if ($noofrows > 0) {
						$row = $adb->query_result_rowdata($check_res, 0);
						$query = "UPDATE ld_invoice_recurring_info SET recurring_frequency=?, start_period=?, end_period=?, payment_duration=?, invoice_status=? WHERE customform165id=?";
						$params = array($frequency,$startPeriod,$endPeriod,$paymentDuration,$invoiceStatus,$soId);
					} else {
						$query = "INSERT INTO ld_invoice_recurring_info VALUES (?,?,?,?,?,?,?)";
						$params = array($soId,$frequency,$startPeriod,$endPeriod,$startPeriod,$paymentDuration,$invoiceStatus);
					}
					$adb->pquery($query, $params);
				}
			} else {
				$query = "DELETE FROM ld_invoice_recurring_info WHERE customform165id = ?";
				$adb->pquery($query, array($soId));	
			}
		}
	}
} 


?>