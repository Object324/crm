<?php
/*+*******************************************************************************
 *  The contents of this file are subject to the lingdang CRM Public License Version 1.0
 *  ("License"); You may not use this file except in compliance with the License
 *  The Original Code is:  lingdang CRM Open Source
 *  The Initial Developer of the Original Code is lingdang.
 *  Portions created by lingdang are Copyright (C) lingdang.
 *  All Rights Reserved.
 ******************************************************************************** */

/**
 * Function to get the field information from module name and field label
 */
function getFieldByReportLabel($module, $label) {

	// this is required so the internal cache is populated or reused.
	global $adb;
	//lookup all the accessible fields

      $fieldobj=Field::getInstance($module,$adb);
      $cachedModuleFields=$fieldobj->getFieldInfoList();
	if(empty($cachedModuleFields)) {
		return null;
	}
	foreach ($cachedModuleFields as $fieldInfo) {
		$fieldLabel = str_replace(' ', '_', $fieldInfo['fieldlabel']);
		if($label == $fieldLabel) {
			return $fieldInfo;
		}
	}
	return null;
}

function isReferenceUIType($uitype) {
	static $options = array('101', '116', '117', '26', '357',
		'50', '51', '52', '53', '57', '58', '59', '66', '68',
		'73', '75', '76', '77', '78', '80', '81'
	);

	if(in_array($uitype, $options)) {
		return true;
	}
	return false;
}

/**
 *
 * @global Users $current_user
 * @param ReportRun $report
 * @param Array $picklistArray
 * @param ADOFieldObject $dbField
 * @param Array $valueArray
 * @param String $fieldName
 * @return String
 */
function getReportFieldValue ($report, $picklistArray, $dbField, $valueArray, $fieldName,$headerLabel="") {
	global $current_user,$adb,$app_strings;
    
	$db = PearDatabase::getInstance();
	$value = $valueArray[$fieldName];
	$fld_type = $dbField->type;
	list($module, $fieldLabel) = explode('_', $dbField->name, 2);
     $tabid=getTabid($module);
    /*
    edit:can
    date:20130409
    reason:0003610: 报表--"产品"报表中，"产品有效"显示不正确。
    other:获取字段的Uitype
    */
     if($headerLabel!="")
     {
        $headers=explode(" ",$headerLabel);
        $headerLabel=$headers[1];
     }
     $sql="select uitype from ld_field where tabid=".$tabid. " and (fieldlabel='". $fieldLabel."' or fieldlabel='".$headerLabel."')";

    $results=$adb->pquery($sql,array());
    	foreach($results as $rows)
        {
            $uitype=$rows['uitype'];
            
        }
 	$fieldInfo = getFieldByReportLabel($module, $fieldLabel);
	$fieldType = null;
	$fieldvalue = $value;
    if($uitype==56)
    {
        if($fieldvalue==1)
        {
            return getFixedLabel('YES');
        }
        else 
        {
            return getFixedLabel('NO');
        }
    }
	if(!empty($fieldInfo)) {
		$field = WebserviceField::fromArray($db, $fieldInfo);
        
		$fieldType = $field->getFieldDataType();
       
	}
    $defaultFields=array('stRemain','stBack','stNeed','ExpenseTotal');
    if(in_array($fieldLabel,$defaultFields))
    $fieldType='currency';

	if ($fieldType == 'currency' && $value != '') {
		// Some of the currency fields like Unit Price, Total, Sub-total etc of Inventory modules, do not need currency conversion
		if(in_array($fieldLabel,$defaultFields)||$field->getUIType() == '72') {
			$curid_value = explode("::", $value);
			$currency_id = $curid_value[0];
			$currency_value = $curid_value[1];
			$currencyobj=Currency::getInstance($adb,$currency_id);
			$currencySymbol = $currencyobj->getCurrencySymbol();
			if($value!='') {
				$formattedCurrencyValue = CurrencyField::convertToUserFormat($currency_value, null, true);
				$fieldvalue = CurrencyField::appendCurrencySymbol($formattedCurrencyValue, $currencySymbol);			
                //add by ld tifa 20130201 reason:export report the value of  currency column with symbol is null
                if(isset($_REQUEST['action'])&&($_REQUEST['action']=="CreatePDF"||$_REQUEST['action']=="CreateXL")){
                $fieldvalue=$currency_value;
                }
            }
		} else {
			$currencyField = new CurrencyField($value);
			$fieldvalue = $currencyField->getDisplayValue();
		}

	} elseif ($dbField->name == "PurchaseOrder_Currency" || $dbField->name == "SalesOrder_Currency"
				|| $dbField->name == "Invoice_Currency" || $dbField->name == "Quotes_Currency" || $dbField->name == "PriceBooks_Currency") {
		if($value!='') {
			$fieldvalue = getTranslatedCurrencyString($value);
		}
	} elseif (in_array($dbField->name,$report->ui101_fields) && !empty($value)) {
		$entityNames = getEntityName('Users', $value);
		$fieldvalue = $entityNames[$value];
	} elseif( $fieldType == 'date' && !empty($value)) {
		if($module == 'Calendar' && $field->getFieldName() == 'due_date') {
			$endTime = $valueArray['calendar_end_time'];
			if(empty($endTime)) {
				$recordId = $valueArray['calendar_id'];
				$endTime = getSingleFieldValue('ld_activity', 'time_end', 'activityid', $recordId);
			}
			$date = new DateTimeField($value.' '.$endTime);
			$fieldvalue = $date->getDisplayDate();
		} else {
			//$fieldvalue = DateTimeField::convertToUserFormat($value);
		}
	} elseif( $fieldType == "datetime" && !empty($value)) {
		//$date = new DateTimeField($value);
	//	$fieldvalue = $date->getDisplayDateTimeValue();
	} elseif( $fieldType == 'time' && !empty($value) && $field->getFieldName()
			!= 'duration_hours') {
		$date = new DateTimeField($value);
		$fieldvalue = $date->getDisplayTime();
	} elseif( $fieldType == "picklist" && !empty($value) ) {
		if(is_array($picklistArray)) {
			if(is_array($picklistArray[$dbField->name]) &&
					$field->getFieldName() != 'activitytype' && !in_array(
					$value, $picklistArray[$dbField->name])){
				$fieldvalue =$app_strings['LBL_NOT_ACCESSIBLE'];
			} else {
				$fieldvalue = getTranslatedString($value, $module);
			}
		} else {
			$fieldvalue = getTranslatedString($value, $module);
		}
	} elseif( $fieldType == "multipicklist" && !empty($value) ) {
		if(is_array($picklistArray[1])) {
			$valueList = explode(' |##| ', $value);
			$translatedValueList = array();
			foreach ( $valueList as $value) {
				if(is_array($picklistArray[1][$dbField->name]) && !in_array(
						$value, $picklistArray[1][$dbField->name])) {
					$translatedValueList[] =
							$app_strings['LBL_NOT_ACCESSIBLE'];
				} else {
					$translatedValueList[] = getTranslatedString($value,
							$module);
				}
			}
		}
		if (!is_array($picklistArray[1]) || !is_array($picklistArray[1][$dbField->name])) {
			$fieldvalue = str_replace(' |##| ', ', ', $value);
		} else {
			implode(', ', $translatedValueList);
		}
	}
	if($fieldvalue == "") {
		return "-";
	}
	$fieldvalue = str_replace("<", "&lt;", $fieldvalue);
	$fieldvalue = str_replace(">", "&gt;", $fieldvalue);
	$fieldvalue = decode_html($fieldvalue);

	if (stristr($fieldvalue, "|##|") && empty($fieldType)) {
		$fieldvalue = str_ireplace(' |##| ', ', ', $fieldvalue);
	} elseif ($fld_type == "date" && empty($fieldType)) {
		$fieldvalue = DateTimeField::convertToUserFormat($fieldvalue);
	} elseif ($fld_type == "datetime" && empty($fieldType)) {
		$date = new DateTimeField($fieldvalue);
		$fieldvalue = $date->getDisplayDateTimeValue();
	}

	return $fieldvalue;
}

?>