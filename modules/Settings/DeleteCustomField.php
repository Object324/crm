<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

require_once('include/database/PearDatabase.php');

$fld_module = vtlib_purify($_REQUEST["fld_module"]);
$id = vtlib_purify($_REQUEST["fld_id"]);
$colName = vtlib_purify($_REQUEST["colName"]);
$uitype = vtlib_purify($_REQUEST["uitype"]);

//Deleting the CustomField from the Custom Field Table
$query='delete from ld_field where fieldid=?';
$adb->pquery($query, array($id));

//Deleting from ld_profile2field table
$query='delete from ld_profile2field where fieldid=?';
$adb->pquery($query, array($id));

//Deleting from ld_def_org_field table
$query='delete from ld_def_org_field where fieldid=?';
$adb->pquery($query, array($id));

//Drop the column in the corresponding module table
$delete_module_tables = Array(
				"Leads"=>"ld_leadscf",
				"Accounts"=>"ld_accountscf",
				"Contacts"=>"ld_contactscf",
				"Potentials"=>"ld_potentialscf",
				"HelpDesk"=>"ld_ticketcf",
				"Products"=>"ld_productcf",
				"Vendors"=>"ld_vendorcf",
				"PriceBooks"=>"ld_pricebookcf",
				"PurchaseOrder"=>"ld_purchaseordercf",
				"SalesOrder"=>"ld_salesordercf",
				"Quotes"=>"ld_quotescf",
				"Invoice"=>"ld_invoicecf",
				"Campaigns"=>"ld_campaignscf",
				"Calendar"=>"ld_activitycf",
			     );

// vtlib customization: Hook added to allow action for custom modules too
$cftablename = $delete_module_tables[$fld_module];
if(empty($cftablename)) {
	include_once('data/CRMEntity.php');
	$focus = CRMEntity::getInstance($fld_module);
	$cftablename = $focus->customFieldTable[0];
}

$dbquery = 'alter table '. $cftablename .' drop column '. $adb->sql_escape_string($colName);
$adb->pquery($dbquery, array());

//To remove customfield entry from ld_field table
$dbquery = 'delete from ld_field where tablename= ? and fieldname=?';
$adb->pquery($dbquery, array($cftablename, $colName));
//we have to remove the entries in customview and report related tables which have this field ($colName)
$adb->pquery("delete from ld_cvcolumnlist where columnname like ?", array('%'.$colName.'%'));
$adb->pquery("delete from ld_cvstdfilter where columnname like ?", array('%'.$colName.'%'));
$adb->pquery("delete from ld_cvadvfilter where columnname like ?", array('%'.$colName.'%'));
$adb->pquery("delete from ld_selectcolumn where columnname like ?", array('%'.$colName.'%'));
$adb->pquery("delete from ld_relcriteria where columnname like ?", array('%'.$colName.'%'));
$adb->pquery("delete from ld_reportsortcol where columnname like ?", array('%'.$colName.'%'));
$adb->pquery("delete from ld_reportdatefilter where datecolumnname like ?", array('%'.$colName.'%'));
$adb->pquery("delete from ld_reportsummary where columnname like ?", array('%'.$colName.'%'));


//Deleting from convert lead mapping lingdang_table- Jaguar
if($fld_module=="Leads")
{
	$deletequery = 'delete from ld_convertleadmapping where leadfid=?';
	$adb->pquery($deletequery, array($id));
}elseif($fld_module=="Accounts" || $fld_module=="Contacts" || $fld_module=="Potentials")
{
	$map_del_id = array("Accounts"=>"accountfid","Contacts"=>"contactfid","Potentials"=>"potentialfid");
	$map_del_q = "update ld_convertleadmapping set ".$map_del_id[$fld_module]."=0 where ".$map_del_id[$fld_module]."=?";
	$adb->pquery($map_del_q, array($id));
}
//HANDLE HERE - we have to remove the table for other picklist type values which are text area and multiselect combo box 
if($uitype == 15)
{
	//Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/7 0007 下午 3:04
	$objPickList = crm_load_class_obj("cls_PickList",'modules/PickList',array());
	$objPickList->delPickField($colName,'ld_field');
	/*旧代码 $deltablequery = 'drop table ld_'.$adb->sql_escape_string($colName);
	$adb->pquery($deltablequery, array());*/
}

header("Location:index.php?module=Settings&action=CustomFieldList&fld_module=".$fld_module."&parenttab=Settings");
?>