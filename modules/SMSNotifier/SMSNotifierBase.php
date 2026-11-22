<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
require_once('data/CRMEntity.php');
require_once('data/Tracker.php');

class SMSNotifierBase extends CRMEntity {
	var $db, $log; // Used in class functions of CRMEntity

	var $table_name = 'ld_smsnotifier';
	var $table_index= 'smsnotifierid';

	/** Indicator if this is a custom module or standard module */
	var $IsCustomModule = true;

	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_smsnotifiercf', 'smsnotifierid');

	/**
	 * Mandatory for Saving, Include tables related to this module.
	 */
	var $tab_name = Array('ld_crmentity', 'ld_smsnotifier', 'ld_smsnotifiercf');

	/**
	 * Mandatory for Saving, Include tablename and tablekey columnname here.
	 */
	var $tab_name_index = Array(
		'ld_crmentity' => 'crmid',
		'ld_smsnotifier' => 'smsnotifierid',
		'ld_smsnotifiercf'=>'smsnotifierid');

	/**
	 * Mandatory for Listing (Related listview)
	 */
	var $list_fields = Array (
		/* Format: Field Label => Array(tablename, columnname) */
		// tablename should not have prefix 'lingdang_'
		'Message' => Array('smsnotifier', 'message'),
		'Assigned To' => Array('crmentity','smownerid')
	);
	var $list_fields_name = Array (
		/* Format: Field Label => fieldname */
		'Message' => 'message',
		'Assigned To' => 'assigned_user_id'
	);

	// Make the field link to detail view 
	var $list_link_field = 'message';

	// For Popup listview and UI type support
	var $search_fields = Array(
		/* Format: Field Label => Array(tablename, columnname) */
		// tablename should not have prefix 'lingdang_'
		'Message' => Array('smsnotifier', 'message')
	);
	var $search_fields_name = Array (
		/* Format: Field Label => fieldname */
		'Message' => 'message'
	);

	// For Popup window record selection
	var $popup_fields = Array ('message');

	// Allow sorting on the following (field column names)
	var $sortby_fields = Array ('message');

	// Should contain field labels
	//var $detailview_links = Array ('Message');

	// For Alphabetical search
	var $def_basicsearch_col = 'message';

	// Column value to use on detail view record text display
	var $def_detailview_recname = 'message';

	// Required Information for enabling Import feature
	var $required_fields = Array ('assigned_user_id'=>1);

	// Callback function list during Importing
	var $special_functions = Array('set_import_assigned_user');

	var $default_order_by = 'smsnotifierid';
	var $default_sort_order='DESC';
	
	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
	var $mandatory_fields = Array('createdtime', 'modifiedtime', 'message');
	
	function __construct() {
		global  $currentModule;
		$this->column_fields = getColumnFields($currentModule);
		$this->db = new PearDatabase();
		$this->log = $log;
	}

	function getSortOrder() {
		global $currentModule;

		$sortorder = $this->default_sort_order;
		if($_REQUEST['sorder']) $sortorder = $_REQUEST['sorder'];
		else if($_SESSION[$currentModule.'_Sort_Order']) 
			$sortorder = $_SESSION[$currentModule.'_Sort_Order'];

		return $sortorder;
	}

	function getOrderBy() {
		$orderby = $this->default_order_by;
		if($_REQUEST['order_by']) $orderby = $_REQUEST['order_by'];
		else if($_SESSION[$currentModule.'_Order_By'])
			$orderby = $_SESSION[$currentModule.'_Order_By'];
		return $orderby;
	}

	function save_module($module) {
	}

	/**
	 * Return query to use based on given modulename, fieldname
	 * Useful to handle specific case handling for Popup
	 */
	function getQueryByModuleField($module, $fieldname, $srcrecord) {
		// $srcrecord could be empty
	}

	/**
	 * Get list view query (send more WHERE clause condition if required)
	 */
	function getListQuery($module, $usewhere=false) {
		$query = "SELECT ld_crmentity.*, $this->table_name.*";

		// Select Custom Field Table Columns if present
		if(!empty($this->customFieldTable)) $query .= ", " . $this->customFieldTable[0] . ".* ";

		$query .= " FROM $this->table_name";

		$query .= "	INNER JOIN ld_crmentity ON ld_crmentity.crmid = $this->table_name.$this->table_index";

		// Consider custom table join as well.
		if(!empty($this->customFieldTable)) {
			$query .= " INNER JOIN ".$this->customFieldTable[0]." ON ".$this->customFieldTable[0].'.'.$this->customFieldTable[1] .
				      " = $this->table_name.$this->table_index"; 
		}
		$query .= " LEFT JOIN ld_users ON ld_users.id = ld_crmentity.smownerid";
		$query .= " LEFT JOIN ld_groups ON ld_groups.groupid = ld_crmentity.smownerid";

		$linkedModulesQuery = $this->db->pquery("SELECT distinct fieldname, columnname, relmodule FROM ld_field" .
				" INNER JOIN ld_fieldmodulerel ON ld_fieldmodulerel.fieldid = ld_field.fieldid" .
				" WHERE uitype='10' AND ld_fieldmodulerel.module=?", array($module));
		$linkedFieldsCount = $this->db->num_rows($linkedModulesQuery);
		
		for($i=0; $i<$linkedFieldsCount; $i++) {
			$related_module = $this->db->query_result($linkedModulesQuery, $i, 'relmodule');
			$fieldname = $this->db->query_result($linkedModulesQuery, $i, 'fieldname');
			$columnname = $this->db->query_result($linkedModulesQuery, $i, 'columnname');
			
			checkFileAccessForInclusion("modules/$related_module/$related_module.php");
			require_once("modules/$related_module/$related_module.php");
			$other = new $related_module();
			vtlib_setup_modulevars($related_module, $other);
			
			$query .= " LEFT JOIN $other->table_name ON $other->table_name.$other->table_index = $this->table_name.$columnname";
		}

		$query .= "	WHERE ld_crmentity.deleted = 0 ";
		if($usewhere) {
			$query .= $usewhere;
		}
		$query .= $this->getListViewSecurityParameter($module);
		return $query;
	}

	/**
	 * Apply security restriction (sharing privilege) query part for List view.
	 */
	function getListViewSecurityParameter($module) {
		global $current_user,$adb;
		$ScopOfAuthority = ScopOfAuthority::getInstance($adb,$module);
		return $ScopOfAuthority->getModuleListViewQuery();
	}

	/**
	 * Create query to export the records.
	 */
	function create_export_query($where)
	{
		global $current_user,$adb;
		$thismodule = $_REQUEST['module'];
		
		include("include/utils/ExportUtils.php");

		//To get the Permitted fields query and the permitted fields list
		$sql = getPermittedFieldsQuery($thismodule, "detail_view");
		
		$fields_list = getFieldsListFromQuery($sql);

		$query = "SELECT $fields_list, ld_users.user_name AS user_name 
					FROM ld_crmentity INNER JOIN $this->table_name ON ld_crmentity.crmid=$this->table_name.$this->table_index";

		if(!empty($this->customFieldTable)) {
			$query .= " INNER JOIN ".$this->customFieldTable[0]." ON ".$this->customFieldTable[0].'.'.$this->customFieldTable[1] .
				      " = $this->table_name.$this->table_index"; 
		}

		$query .= " LEFT JOIN ld_groups ON ld_groups.groupid = ld_crmentity.smownerid";
		$query .= " LEFT JOIN ld_users ON ld_crmentity.smownerid = ld_users.id and ld_users.status='Active'";
		
		$linkedModulesQuery = $this->db->pquery("SELECT distinct fieldname, columnname, relmodule FROM ld_field" .
				" INNER JOIN ld_fieldmodulerel ON ld_fieldmodulerel.fieldid = ld_field.fieldid" .
				" WHERE uitype='10' AND ld_fieldmodulerel.module=?", array($thismodule));
		$linkedFieldsCount = $this->db->num_rows($linkedModulesQuery);

		for($i=0; $i<$linkedFieldsCount; $i++) {
			$related_module = $this->db->query_result($linkedModulesQuery, $i, 'relmodule');
			$fieldname = $this->db->query_result($linkedModulesQuery, $i, 'fieldname');
			$columnname = $this->db->query_result($linkedModulesQuery, $i, 'columnname');
			
			checkFileAccessForInclusion("modules/$related_module/$related_module.php");
			require_once("modules/$related_module/$related_module.php");
			$other = new $related_module();
			vtlib_setup_modulevars($related_module, $other);
			
			$query .= " LEFT JOIN $other->table_name ON $other->table_name.$other->table_index = $this->table_name.$columnname";
		}

		$where_auto = " ld_crmentity.deleted=0";

		if($where != '') $query .= " WHERE ($where) AND $where_auto";
		else $query .= " WHERE $where_auto";

		require('user_privileges/user_privileges_'.$current_user->id.'.php');
		$ScopOfAuthority = ScopOfAuthority::getInstance($adb,$thismodule);
		// Security Check for Field Access
		if($is_admin==false && $ScopOfAuthority->getModuleShareInfo() == SHARE_PRIVATE)
		{
			//Added security check to get the permitted records only
			$query = $query." ".getListViewSecurityParameter($thismodule);
		}
		return $query;
	}
	
	/**
	 * Transform the value while exporting (if required)
	 */
	function transform_export_value($key, $value) {
		return parent::transform_export_value($key, $value);
	}
	
	/** 
	 * Function which will give the basic query to find duplicates
	 */
	function getDuplicatesQuery($module,$table_cols,$field_values,$ui_type_arr,$select_cols='') {
		$select_clause = "SELECT ". $this->table_name .".".$this->table_index ." AS recordid, ld_users_last_import.deleted,".$table_cols;

		// Select Custom Field Table Columns if present
		if(isset($this->customFieldTable)) $query .= ", " . $this->customFieldTable[0] . ".* ";

		$from_clause = " FROM $this->table_name";

		$from_clause .= "	INNER JOIN ld_crmentity ON ld_crmentity.crmid = $this->table_name.$this->table_index";

		// Consider custom table join as well.
		if(isset($this->customFieldTable)) {
			$from_clause .= " INNER JOIN ".$this->customFieldTable[0]." ON ".$this->customFieldTable[0].'.'.$this->customFieldTable[1] .
				      " = $this->table_name.$this->table_index"; 
		}
		$from_clause .= " LEFT JOIN ld_users ON ld_users.id = ld_crmentity.smownerid
						LEFT JOIN ld_groups ON ld_groups.groupid = ld_crmentity.smownerid";
		
		$where_clause = "	WHERE ld_crmentity.deleted = 0";
		$where_clause .= $this->getListViewSecurityParameter($module);
					
		if (isset($select_cols) && trim($select_cols) != '') {
			$sub_query = "SELECT $select_cols FROM  $this->table_name AS t " .
				" INNER JOIN ld_crmentity AS crm ON crm.crmid = t.".$this->table_index;
			// Consider custom table join as well.
			if(isset($this->customFieldTable)) {
				$sub_query .= " LEFT JOIN ".$this->customFieldTable[0]." tcf ON tcf.".$this->customFieldTable[1]." = t.$this->table_index";
			}
			$sub_query .= " WHERE crm.deleted=0 GROUP BY $select_cols HAVING COUNT(*)>1";	
		} else {
			$sub_query = "SELECT $table_cols $from_clause $where_clause GROUP BY $table_cols HAVING COUNT(*)>1";
		}	
		
		
		$query = $select_clause . $from_clause .
					" LEFT JOIN ld_users_last_import ON ld_users_last_import.bean_id=" . $this->table_name .".".$this->table_index .
					" INNER JOIN (" . $sub_query . ") AS temp ON ".get_on_clause($field_values,$ui_type_arr,$module) .
					$where_clause .
					" ORDER BY $table_cols,". $this->table_name .".".$this->table_index ." ASC";
					
		return $query;		
	}

	/**
	 * Invoked when special actions are performed on the module.
	 * @param String Module name
	 * @param String Event Type (module.postinstall, module.disabled, module.enabled, module.preuninstall)
	 */
	function vtlib_handler($modulename, $event_type) {
		
		//adds sharing accsess 
        $SMSNotifierModule  = lingdang_Module::getInstance('SMSNotifier'); 
        lingdang_Access::setDefaultSharing($SMSNotifierModule);
 
		$registerLinks = false;
		$unregisterLinks = false;
		
		if($event_type == 'module.postinstall') {
			global $adb;
			$unregisterLinks = true;
			$registerLinks = true;
			
			// Mark the module as Standard module
			$adb->pquery('UPDATE ld_tab SET customized=0 WHERE name=?', array($modulename));
		
		} else if($event_type == 'module.disabled') {
			$unregisterLinks = true;
		
		} else if($event_type == 'module.enabled') {
			$registerLinks = true;
			
		} else if($event_type == 'module.preuninstall') {
			// TODO Handle actions when this module is about to be deleted.
		} else if($event_type == 'module.preupdate') {
			// TODO Handle actions before this module is updated.
		} else if($event_type == 'module.postupdate') {
			// TODO Handle actions after this module is updated.
		}
		
		if($unregisterLinks) {
			
			$smsnotifierModuleInstance = lingdang_Module::getInstance('SMSNotifier');
			$smsnotifierModuleInstance->deleteLink("HEADERSCRIPT", "SMSNotifierCommonJS", "modules/SMSNotifier/SMSNotifierCommon.js");
			
			$leadsModuleInstance = lingdang_Module::getInstance('Leads');
			$leadsModuleInstance->deleteLink('LISTVIEWBASIC', 'Send SMS');
			$leadsModuleInstance->deleteLink('DETAILVIEWBASIC', 'Send SMS');
			
			$contactsModuleInstance = lingdang_Module::getInstance('Contacts');
			$contactsModuleInstance->deleteLink('LISTVIEWBASIC', 'Send SMS');
			$contactsModuleInstance->deleteLink('DETAILVIEWBASIC', 'Send SMS');

			$accountsModuleInstance = lingdang_Module::getInstance('Accounts');
			$accountsModuleInstance->deleteLink('LISTVIEWBASIC', 'Send SMS');
			$accountsModuleInstance->deleteLink('DETAILVIEWBASIC', 'Send SMS');
		}
		
		if($registerLinks) {
			
			$smsnotifierModuleInstance = lingdang_Module::getInstance('SMSNotifier');
			$smsnotifierModuleInstance->addLink("HEADERSCRIPT", "SMSNotifierCommonJS", "modules/SMSNotifier/SMSNotifierCommon.js");
			
			$leadsModuleInstance = lingdang_Module::getInstance('Leads');
			
			$leadsModuleInstance->addLink("LISTVIEWBASIC", "Send SMS", "SMSNotifierCommon.displaySelectWizard(this, '\$MODULE\$');");
			$leadsModuleInstance->addLink("DETAILVIEWBASIC", "Send SMS", "javascript:SMSNotifierCommon.displaySelectWizard_DetailView('\$MODULE\$', '\$RECORD\$');");
			
			$contactsModuleInstance = lingdang_Module::getInstance('Contacts');
			$contactsModuleInstance->addLink('LISTVIEWBASIC', 'Send SMS', "SMSNotifierCommon.displaySelectWizard(this, '\$MODULE\$');");
			$contactsModuleInstance->addLink("DETAILVIEWBASIC", "Send SMS", "javascript:SMSNotifierCommon.displaySelectWizard_DetailView('\$MODULE\$', '\$RECORD\$');");
	
			$accountsModuleInstance = lingdang_Module::getInstance('Accounts');
			$accountsModuleInstance->addLink('LISTVIEWBASIC', 'Send SMS', "SMSNotifierCommon.displaySelectWizard(this, '\$MODULE\$');");
			$accountsModuleInstance->addLink("DETAILVIEWBASIC", "Send SMS", "javascript:SMSNotifierCommon.displaySelectWizard_DetailView('\$MODULE\$', '\$RECORD\$');");
		}
		
		
		
	}
	/** 
	 * Handle saving related module information.
	 * NOTE: This function has been added to CRMEntity (base class).
	 * You can override the behavior by re-defining it here.
	 */
	// function save_related_module($module, $crmid, $with_module, $with_crmid) { }
	
	/**
	 * Handle deleting related module information.
	 * NOTE: This function has been added to CRMEntity (base class).
	 * You can override the behavior by re-defining it here.
	 */
	//function delete_related_module($module, $crmid, $with_module, $with_crmid) { }

	/**
	 * Handle getting related list information.
	 * NOTE: This function has been added to CRMEntity (base class).
	 * You can override the behavior by re-defining it here.
	 */
	//function get_related_list($id, $cur_tab_id, $rel_tab_id, $actions=false) { }

	/**
	 * Handle getting dependents list information.
	 * NOTE: This function has been added to CRMEntity (base class).
	 * You can override the behavior by re-defining it here.
	 */
	//function get_dependents_list($id, $cur_tab_id, $rel_tab_id, $actions=false) { }
}
?>