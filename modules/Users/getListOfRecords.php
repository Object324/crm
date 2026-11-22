<?php
/*+*******************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
session_start();
require_once('include/CustomFieldUtil.php');


global $mod_strings,$app_strings,$app_list_strings,$theme,$adb,$current_user;
global $list_max_entries_per_page_new;

$theme_path="themes/".$theme."/";

require_once('modules/lingdang/layout_utils.php');

$iCurRecord = vtlib_purify($_REQUEST['CurRecordId']);
$sModule = vtlib_purify($_REQUEST['CurModule']);

require_once('data/CRMEntity.php');
$foc_obj = CRMEntity::getInstance($sModule);

//$query = $adb->pquery("SELECT tablename,entityidfield, fieldname from ld_entityname WHERE modulename = ?",array($sModule));
$entitynames=getEntitynameByModulename($sModule);
$table_name = $entitynames['tablename'];
$field_name = $entitynames['fieldname'];
$id_field = $entitynames['entityidfield'];
$fieldname = split(",",$field_name);
$fields_array = array($sModule=>$fieldname);
$id_array = array($sModule=>$id_field);
$tables_array = array($sModule=>$table_name);

$permittedFieldNameList = array();
foreach ($fieldname as $fieldName) {
	$checkForFieldAccess = $fieldName;
	// Handling case where fieldname in lingdang_entityname mismatches fieldname in lingdang_field
	if($sModule == 'HelpDesk' && $checkForFieldAccess == 'title') {
		$checkForFieldAccess = 'ticket_title';	
	} else if($sModule == 'Documents' && $checkForFieldAccess == 'title') {
		$checkForFieldAccess = 'notes_title';	
	}
	// END
	if(getFieldVisibilityPermission($sModule,$current_user->id, $checkForFieldAccess) == '0'){
		$permittedFieldNameList[] = $fieldName;
	}
}

$cv = new CustomView();
$viewId = $cv->getViewId($sModule);
if(!empty($_SESSION[$sModule.'_DetailView_Navigation'.$viewId])){
    print_r($recordNavigationInfo);
	$recordNavigationInfo = Zend_Json::decode($_SESSION[$sModule.'_DetailView_Navigation'.$viewId]);
	$recordList = array();
	$recordIndex = null;
	$recordPageMapping = array();
	foreach ($recordNavigationInfo as $start=>$recordIdList){
		foreach ($recordIdList as $index=>$recordId) {
			if(!isRecordExists($recordId)) continue;
			$recordList[] = $recordId;
			$recordPageMapping[$recordId] = $start;
			if($recordId == $iCurRecord){
				$recordIndex = count($recordList)-1;
			}
		}
	}
}else{
	$recordList = array();
}
$output = '

<div class="Title">
    <img src="themes/softed/tier/icon_loto.png" class="Logo" />
    <span class="Name">'.getFixedLabel('JUMPURL').' ' .getTranstab($sModule).'</span>
	<a href="javascript:fninvshnew(\'lstRecordLayout\');">
		<img src="themes/softed/tier/icon_close.png" class="Close" />
	</a>
</div>	
<div class="Content_div">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td class="Note">
               <ul class="LdPop_ul1">
               <table class="Ldstable0" width="100%" border="0" align="center" cellspacing="1" cellpadding="0">';

/**
* edit:chj
* date:2014-1-20
* reason: 有产品详细信息的模块， 去除数组中的相同元素
**/
if(get_file_address($sModule,'ProductDetails'))
    $recordList = array_unique($recordList);
if(count($recordList) > 0){
	$displayRecordCount = 10;
	$count = count($recordList);
	$idListEndIndex = ($count < ($recordIndex+$displayRecordCount))? ($count+1) : ($recordIndex+$displayRecordCount+1);
	$idListStartIndex = $recordIndex-$displayRecordCount;
	if($idListStartIndex < 0){
		$idListStartIndex = 0;
	}
	$idsArray = array_slice($recordList,$idListStartIndex,($idListEndIndex - $idListStartIndex));
	
	$selectColString = implode(',',$permittedFieldNameList).', '.$id_array[$sModule];
	/**
     * 更新操作
     * edit:diony
     * time:2014-06-25
     * reason:跳转加客户名称 
     * * reason:9399
     * */
    if($sModule == 'Accounts' || $sModule == 'Attachment' || $sModule == 'ModComments')
    {
        $fieldQuery = "SELECT $selectColString from ".$tables_array[$sModule]." WHERE ".$id_array[$sModule]." IN (". generateQuestionMarks($idsArray) .")";
    }
    else if($sModule == 'Vendors')
    {
        $fieldQuery = "SELECT $selectColString,ld_crmentity.createdtime from ".$tables_array[$sModule].
        " left join ld_crmentity on ".$tables_array[$sModule].".vendorid = ld_crmentity.crmid ".
        " WHERE ".$id_array[$sModule]." IN (". generateQuestionMarks($idsArray) .")";
    }
    else if($sModule == 'VendorContact' || $sModule == 'VendorContactRecords'|| $sModule == 'PurchaseOrder' || $sModule == 'SendCashBill' || $sModule == 'SendPayment' || $sModule == 'PurchaseBack')
    {
        $fieldQuery = "SELECT $selectColString,ld_vendor.vendorname from ".$tables_array[$sModule].
        " left join ld_vendor on ".$tables_array[$sModule].".vendorid = ld_vendor.vendorid ".
        " WHERE ".$id_array[$sModule]." IN (". generateQuestionMarks($idsArray) .")";
    }
    else if($sModule == 'Stock')
    {
        $fieldQuery = "SELECT $selectColString,ld_vendor.vendorname from ".$tables_array[$sModule].
        " left join ld_vendor on ".$tables_array[$sModule].".vendor_id = ld_vendor.vendorid ".
        " WHERE ".$id_array[$sModule]." IN (". generateQuestionMarks($idsArray) .")";
    }
    else if($sModule == 'ProjectTask' || $sModule == 'ProjectMilestone')
    {
        $fieldQuery = "SELECT $selectColString,ld_project.projectname from ".$tables_array[$sModule].
        " left join ld_project on ".$tables_array[$sModule].".projectid = ld_project.projectid ".
        " WHERE ".$id_array[$sModule]." IN (". generateQuestionMarks($idsArray) .")";
    }
    else if($sModule == 'Faq')
    {
        $fieldQuery = "SELECT $selectColString,ld_products.productname from ".$tables_array[$sModule].
        " left join ld_products on ".$tables_array[$sModule].".product_id = ld_products.productid ".
        " WHERE ".$id_array[$sModule]." IN (". generateQuestionMarks($idsArray) .")";
    }
    else if($sModule == 'Campaigns')
    {
        $fieldQuery = "SELECT $selectColString,closingdate from ".$tables_array[$sModule].
        " WHERE ".$id_array[$sModule]." IN (". generateQuestionMarks($idsArray) .")";
    }
    else if($sModule == 'BankAccountSet')
    {
        $fieldQuery = "SELECT $selectColString,bankNum from ".$tables_array[$sModule].
        " WHERE ".$id_array[$sModule]." IN (". generateQuestionMarks($idsArray) .")";
    }
    else if($sModule == 'PutCash')
    {
        $fieldQuery = "SELECT $selectColString,putcashdate from ".$tables_array[$sModule].
        " WHERE ".$id_array[$sModule]." IN (". generateQuestionMarks($idsArray) .")";
    }
    else if($sModule == 'CashDeposit')
    {
        $fieldQuery = "SELECT $selectColString,cashdepositdate from ".$tables_array[$sModule].
        " WHERE ".$id_array[$sModule]." IN (". generateQuestionMarks($idsArray) .")";
    }
    else if($sModule == 'Checks')
    {
        $fieldQuery = "SELECT $selectColString,checksdate from ".$tables_array[$sModule].
        " WHERE ".$id_array[$sModule]." IN (". generateQuestionMarks($idsArray) .")";
    } 
    else if($sModule == 'Documents')
    {
        $fieldQuery = "SELECT $selectColString,note_no from ".$tables_array[$sModule]." WHERE ".$id_array[$sModule]." IN (". generateQuestionMarks($idsArray) .")";
    } 
    else if($sModule == 'Products')
    {
        $fieldQuery = "SELECT $selectColString,productcode from ".$tables_array[$sModule]." WHERE ".$id_array[$sModule]." IN (". generateQuestionMarks($idsArray) .")";
    }
    else if($sModule == 'PriceBooks')
    {
        $fieldQuery = "SELECT $selectColString,pricebook_no from ".$tables_array[$sModule]." WHERE ".$id_array[$sModule]." IN (". generateQuestionMarks($idsArray) .")";
    }
    else
    {
        $fieldQuery = "SELECT $selectColString,ld_account.accountname from ".$tables_array[$sModule].
        " left join ld_account on ".$tables_array[$sModule].".accountid = ld_account.accountid ".
        " WHERE ".$id_array[$sModule]." IN (". generateQuestionMarks($idsArray) .")";
    }
    echo $fieldQuery;
    $fieldResult = $adb->pquery($fieldQuery,$idsArray);
	$numOfRows = $adb->num_rows($fieldResult);
	$recordNameMapping = array();
    $recordNameMappingR = array();
	for($i=0; $i<$numOfRows; ++$i) {
		$recordId = $adb->query_result($fieldResult,$i,$id_array[$sModule]);
		$fieldValue = '';
		foreach ($permittedFieldNameList as $fieldName) {
			$fieldValue .= " ".$adb->query_result($fieldResult,$i,$fieldName);
		}
        $fieldValue = textlength_check($fieldValue);
        $fieldValue = mb_substr($fieldValue, 0, 10, 'utf-8');
        if($sModule == 'Accounts' || $sModule == 'Attachment' || $sModule == 'ModComments')
        {
            $recordNameMapping[$recordId] = $fieldValue;
        }
        else if($sModule == 'Vendors')
        {
            $createdtime = $adb->query_result($fieldResult,$i,'createdtime');
            $recordNameMapping[$recordId] = $fieldValue;
            $recordNameMappingR[$recordId] = $createdtime;
        }
        else if($sModule == 'VendorContact' || $sModule == 'VendorContactRecords'|| $sModule == 'PurchaseOrder' 
        || $sModule == 'SendCashBill' || $sModule == 'SendPayment'|| $sModule == 'PurchaseBack')
        {            
            $vendorname = $adb->query_result($fieldResult,$i,'vendorname');
            $vendorname = mb_substr($vendorname, 0, 10, 'utf-8');
            $recordNameMapping[$recordId] = $fieldValue;
            $recordNameMappingR[$recordId] = $vendorname;
        }
        else if($sModule == 'Stock')
        {
            $vendorname = $adb->query_result($fieldResult,$i,'vendorname');
            $vendorname = mb_substr($vendorname, 0, 10, 'utf-8');
            $recordNameMapping[$recordId] = $fieldValue;
            $recordNameMappingR[$recordId] = $vendorname;
        }
        else if($sModule == 'ProjectTask' || $sModule == 'ProjectMilestone')
        {
            $projectname = $adb->query_result($fieldResult,$i,'projectname');
            $projectname = mb_substr($projectname, 0, 10, 'utf-8');
            $recordNameMapping[$recordId] = $fieldValue;
            $recordNameMappingR[$recordId] = $projectname;
        }
        else if($sModule == 'Faq')
        {
            $productname = $adb->query_result($fieldResult,$i,'productname');
            $productname = mb_substr($productname, 0, 10, 'utf-8');
            $recordNameMapping[$recordId] = $fieldValue;
            $recordNameMappingR[$recordId] = $productname;
        }
        else if($sModule == 'Campaigns')
        {
            $closingdate = $adb->query_result($fieldResult,$i,'closingdate');
            $recordNameMapping[$recordId] = $fieldValue;
            $recordNameMappingR[$recordId] = $closingdate;
        }
        else if($sModule == 'BankAccountSet')
        {
            $bankNum = $adb->query_result($fieldResult,$i,'banknum');
            $recordNameMapping[$recordId] = $fieldValue;
            $recordNameMappingR[$recordId] = $bankNum;
        }  
        else if($sModule == 'PutCash')
        {
            $putcashdate = $adb->query_result($fieldResult,$i,'putcashdate');
            $recordNameMapping[$recordId] = $fieldValue;
            $recordNameMappingR[$recordId] = $putcashdate;
        }
        else if($sModule == 'CashDeposit')
        {
            $cashdepositdate = $adb->query_result($fieldResult,$i,'cashdepositdate');
            $recordNameMapping[$recordId] = $fieldValue;
            $recordNameMappingR[$recordId] = $cashdepositdate;
        }
        else if($sModule == 'Checks')
        {
            $checksdate = $adb->query_result($fieldResult,$i,'checksdate');
            $recordNameMapping[$recordId] = $fieldValue;
            $recordNameMappingR[$recordId] = $checksdate;
        } 
        else if($sModule == 'Documents')
        {
            $note_no = $adb->query_result($fieldResult,$i,'note_no');
            $recordNameMapping[$recordId] = $fieldValue;
            $recordNameMappingR[$recordId] = $note_no;
        } 
        else if($sModule == 'Products')
        {
            $productcode = $adb->query_result($fieldResult,$i,'productcode');
            $recordNameMapping[$recordId] = $fieldValue;
            $recordNameMappingR[$recordId] = $productcode;
        }    
        else if($sModule == 'PriceBooks')
        {
            $pricebook_no = $adb->query_result($fieldResult,$i,'pricebook_no');
            $recordNameMapping[$recordId] = $fieldValue;
            $recordNameMappingR[$recordId] = $pricebook_no;
        }
        else
        {
            $accountname = $adb->query_result($fieldResult,$i,'accountname');
            $accountname = mb_substr($accountname, 0, 10, 'utf-8');
            $recordNameMapping[$recordId] = $fieldValue;
            $recordNameMappingR[$recordId] = $accountname;
        }
        
        
	}
	foreach ($idsArray as $id) {
		if($id===$iCurRecord){
			//$output .= '<li><div class="Character-Names">'.$recordNameMapping[$id].'</div><div class="clear"></div></li>';
            $output .= '<tr><td>'.$recordNameMapping[$id].'</td><td>'.$recordNameMappingR[$id].'</td></tr>';
		}else{
			/*$output .= '<li><div class="Character-Names"><a href="index.php?module='.$sModule.
				'&action=DetailView&parenttab='.vtlib_purify($_REQUEST['CurParentTab']).'&record='.$id.
				'&start='.$recordPageMapping[$id].'">'.$recordNameMapping[$id].'</a></div><div class="clear"></div></li>';*/
            $output .= '<tr><td><a href="index.php?module='.$sModule.
				'&action=DetailView&parenttab='.vtlib_purify($_REQUEST['CurParentTab']).'&record='.$id.
				'&start='.$recordPageMapping[$id].'">'.$recordNameMapping[$id].'</a></td><td>'.$recordNameMappingR[$id].'</td></tr>';
		}
	}
}
$output .= '</table></ul>';
$output .= '</td>
      </tr>
    </table>
</div>';
echo '###SUCCESS###';
echo $output;



?>