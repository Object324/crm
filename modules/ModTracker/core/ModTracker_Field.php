<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************** */
class ModTracker_Field {

	var $parent;
	var $moduleMeta = null;
	var $fieldInfo = null;

	function __construct($parent) {
		$this->parent = $parent;
	}

	function getFieldLabel() {
		return $this->fieldInfo->getFieldLabelKey();
	}

	function getDisplayLabel($value) {
		$recordId = $this->parent->getRecordId();
		$fieldInstance = $this->fieldInfo;
		$moduleName = $this->parent->getModuleName();
		$value = $this->getFieldDisplayValue($moduleName, $recordId, $fieldInstance, $value);
		return $value;
	}

	function getFieldDisplayValue($moduleName, $recordId, $fieldInstance, $value) {
		global $current_user;
		$adb = PearDatabase::getInstance();
         if(!isset($fieldInstance))
         {
            return '';
         }
		$fieldName = $fieldInstance->getFieldName();
		$uitype = $fieldInstance->getUIType();
           
            
		if ($moduleName == 'Documents') {
			if ($fieldName == 'filesize') {
				$filesize = $value;
				if (empty($fieldsize)) {
					$value = '--';
				} elseif ($filesize < 1024) {
					$value = $filesize . ' B';
				} elseif ($filesize > 1024 && $filesize < 1048576) {
					$value = round($filesize / 1024, 2) . ' KB';
				} else if ($filesize > 1048576) {
					$value = round($filesize / (1024 * 1024), 2) . ' MB';
				}
			}
			if ($fieldName == 'filestatus') {
				if ($value == 1) {
					$value = getFixedLabel('YES');
				} elseif ($value == 0) {
					$value = getFixedLabel('NO');
				} else {
					$value = '--';
				}
			}
			if ($fieldName == 'filetype') {
				if ($value == 1) {
					$value = getFixedLabel('YES');
				} elseif ($value == 0) {
					$value = getFixedLabel('NO');
				} else {
					$value = '--';
				}
			}
		}

		if ($fieldInstance->getUIType() == '27') {
			if ($value == 'I') {
				$value = getFixedLabel('INTERNAL');
			} elseif ($value == 'E') {
				$value = getFixedLabel('EXTERNAL');
			} else {
				$value = ' --';
			}
		}else if($fieldInstance->getUIType() == '251' || $fieldInstance->getUIType() == '252'){//账户
			$query = "select Accountname from ld_bankaccountset where Bankaccountsetid = ? limit 1";
			$result = $adb->pquery($query,array($value));
			$value = $adb->query_result($result,0,'accountname');
		}
		else if($fieldInstance->getUIType() == '151')
		{
			$query = "select name from ld_warehouse where id = ? limit 1";
			$result = $adb->pquery($query,array($value));
			$value = $adb->query_result($result,0,'name');
		}

		if ($fieldInstance->getFieldDataType() == 'picklist') {
			$isRoleBased = vtws_isRoleBasedPicklist($fieldName);
			if ($isRoleBased && ($fieldName != 'activitytype' || $value != '任务')) {
				$accessiblePicklistValues = getAssignedPicklistValues($fieldName, $current_user->profileid, $adb);
				if (!empty($value) && !is_admin($current_user) && !in_array($value, $accessiblePicklistValues)) {
					
					$value = "<font color='red'>" .getFixedLabel('NOTACCESS') . "</font>";
				} else {
					$value = $value;
				}
			} else {
				$value = $value;
			}
		}

		if ($fieldInstance->getFieldDataType() == 'date'
				|| $fieldInstance->getFieldDataType() == 'datetime'
				|| $fieldInstance->getFieldDataType() == 'time') {

			if ($value != '' && $value != '0000-00-00') {
				$date = new DateTimeField($value);
				if ($fieldInstance->getFieldDataType() == 'date') {
					$value = $date->getDisplayDate();
				}
				if ($fieldInstance->getFieldDataType() == 'datetime') {
					$value = $date->getDisplayDateTimeValue();
				}
				if ($fieldInstance->getFieldDataType() == 'time') {
					$value = $date->getDisplayTime();
				}
			} else {
				$value = '';
			}
		}

		if ($fieldInstance->getFieldDataType() == 'currency') {
			if ($value != '' && $value != 0) {
				if ($fieldInstance->getUIType() == 72) {
					$currencyInfo = getInventoryCurrencyInfo($moduleName,$recordId);
					$currencySymbol = $currencyInfo['currency_symbol'];
					$currencyValue = CurrencyField::convertToUserFormat($value, null, true);
					$value = CurrencyField::appendCurrencySymbol($currencyValue, $currencySymbol);
				} else {
					$currencyField = new CurrencyField($value);
					$value = $currencyField->getDisplayValueWithSymbol();
				}
			}
		}

		if ($fieldInstance->getFieldDataType() == 'url') {
			$matchPattern = "^[\w]+:\/\/^";
			preg_match($matchPattern, $value, $matches);
			if (!empty($matches[0])) {
				$value = '<a href="' . $value . '" target="_blank">' . $value . '</a>';
			} else {
				$value = '<a href="http://' . $value . '" target="_blank">' . $value . '</a>';
			}
		}
		if ($fieldInstance->getFieldDataType() == 'boolean') {
			if ($value == 1) {
				$value = getFixedLabel('YES');
			} elseif ($value == 0) {
				$value = getFixedLabel('NO');
			} else {
				$value = '--';
			}
		}

		if ($fieldInstance->getFieldDataType() == 'multipicklist') {
			$value = ($value != "") ? str_replace(' |##| ', ', ', $value) : "";
			$isRoleBased = vtws_isRoleBasedPicklist($fieldName);
			if (!is_admin($current_user) && $value != '' && $isRoleBased) {
				$accessiblePicklistValues = getAssignedPicklistValues($fieldName, $current_user->profileid, $adb);
				$valueArray = ($value != "") ? explode(', ', $value) : array();
				$notaccess = '<font color="red">' . getFixedLabel('NOTACCESS') . "</font>";
				$tmpArray = array();
				foreach ($valueArray as $index => $val) {
					if (!in_array(trim($val), $accessiblePicklistValues)) {
						$tmpArray[] = $notaccess;
					} else {
						$tmpArray[] = $val;
					}
				}
				$value = implode(', ', $tmpArray);
			}
		}
		if ($fieldInstance->getFieldDataType() == 'reference') {
			if (!empty($value)) {
				$referenceList = $fieldInstance->getReferenceList();
				if (count($referenceList) > 0) {
					$firstReferenceModule = $referenceList[0];
					if ($firstReferenceModule == 'Users') {
						$value = getUserFullName($value);
					} elseif ($firstReferenceModule == 'DocumentFolders') {
						$wsFolderId = vtws_getWebserviceEntityId('DocumentFolders', $value);
						$value = vtws_getName($wsFolderId, $current_user);
					} elseif ($firstReferenceModule == 'Currency') {
						$currencyobj=Currency::getInstance($adb,$value);
						$value = $currencyobj->getCurrencyName();
					} else {
						$referenceModule = getSalesEntityType($value);
						$entityNames = getEntityName($referenceModule, array($value));
						$value = $entityNames[$value];
					}
				} else {
					$value = '--';
				}
			} else {
				$value = '--';
			}
		}
		if ($fieldInstance->getFieldDataType() == 'owner') {
			$ownerName = trim(getUserFullName($value));
			if (empty($ownerName)) {
				include 'modules/Users/Group.class.php';
				$group_focus = new Group();
				$ownerInfo = $group_focus->getGroupInfoByid($value);
				if(!empty($ownerInfo) && isset($ownerInfo['groupname'])){
					$ownerName = $ownerInfo['groupname'];
				}
			}
			$value = $ownerName;
		}
		/**
		 * @reason 0013841: 产品-明细：修改日志弹出层中：最低库存字段值小数位数不正确
		 * @author Tujt 2015-03-04
		 */
		$numfldarray = array('firstqty'=>'1','inputqty'=>'1','outputqty'=>'1','lastqty'=>'1',
								'qtyinstock'=>'1','qtyearly'=>'1');
		if(isset($numfldarray[$fieldName])){
			$sysdeploy = getSys_deploy(49);
			if(isset($sysdeploy['deploy_value']))
				$lengthdecimaldigits = $sysdeploy['deploy_value'];
			else
				$lengthdecimaldigits = 2;
			$value = setNumberFormat($value,$lengthdecimaldigits);
		}//tujt end
		return $value;
	}

	function initialize() {
		global $adb, $current_user;
		if ($this->moduleMeta === null) {
			include_once('include/Webservices/Utils.php');
			$moduleHandler = vtws_getModuleHandlerFromName($this->parent->getModuleName(), $current_user);//lingdangModuleOpertion.php
			$this->moduleMeta = $moduleHandler->getMeta();//lingdangCRMObjectMeta.php
		}
		$moduleFields = $this->moduleMeta->getModuleFields();
		$this->fieldInfo = $moduleFields[$this->parent->getFieldName()];
	}

}

?>