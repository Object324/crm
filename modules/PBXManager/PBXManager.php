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

require_once('data/CRMEntity.php');
require_once('data/Tracker.php');

class PBXManager extends CRMEntity {
	var $db, $log; // Used in class functions like CRMEntity

	var $table_name = 'ld_pbxmanager';
	var $table_index= 'pbxmanagerid';
	var $column_fields = Array();

	// Mandatory for function getGroupName
	// Array(groupTableName, groupColumnId)
	// groupTableName should have (groupname column)
	//var $groupTable = Array('lingdang_pbxmanagergrouprel','pbxmanagerid');

	// Mandatory table for supporting custom fields
	var $customFieldTable = Array();

	// Mandatory for Saving, Include tables related to this module.

	var $tab_name = Array('ld_crmentity', 'ld_pbxmanager');

	// Mandatory for Saving, Include the table name and index column mapping here.
	var $tab_name_index = Array(

		'ld_crmentity' => 'crmid',
		'ld_pbxmanager' => 'pbxmanagerid',

	    );

	// Mandatory for Listing
	var $list_fields = Array (
		// Field Label=> Array(tablename, columnname)
		'Call To'=> Array('pbxmanager', 'callto'),
		'Call From'=>Array('pbxmanager', 'callfrom'),
	);
	var $list_fields_name = Array(
		// Field Label=>columnname
		'Call To'=> 'callto',
		'Call From' => 'callfrom'
	);
	var $sortby_fields = Array('callto', 'callfrom', 'callid', 'timeofcall', 'status');
	// Should contain field labels
	var $detailview_links = Array();

	// For alphabetical search
	var $def_basicsearch_col = 'callid';

	// Column value to use on detail view record text display.
	var $def_detailview_recname = '';

	// Required information for enabling Import feature
	var $required_fields = Array();

	// Callback function list during Importing
	var $special_functions =  array();

	var $default_order_by = 'timeofcall';
	var $default_sort_order='DESC';

	function PBXManager() {
		
		$this->column_fields = getColumnFields('PBXManager');
		$this->db = PearDatabase::getInstance();
		$this->log = $log;
	}

	function save_module($module) {
	}

	/**
	 * Get list view query.
	 */
	function getListQuery($module) {
		$query = "SELECT $this->table_name.*, ld_crmentity.*";
		$query .= " FROM $this->table_name";

		$query .= "	INNER JOIN ld_crmentity
						ON ld_crmentity.crmid = $this->table_name.$this->table_index
					 LEFT JOIN ld_groups
						ON ld_groups.groupid = ld_crmentity.smownerid";

		// Consider custom table join as well.
		if(!empty($this->customFieldTable)) {
			$query .= " INNER JOIN ".$this->customFieldTable[0]." ON ".$this->customFieldTable[0].'.'.$this->customFieldTable[1] .
				      " = $this->table_name.$this->table_index"; 
		}
		$query .= " LEFT JOIN ld_users ON ld_users.id = ld_crmentity.smownerid ";

		$query .= "	WHERE ld_crmentity.deleted = 0";
		$query .= $this->getListViewSecurityParameter($module);
		return $query;
	}

	/**
	 * Apply security restriction (sharing privilege) query part for List view.
	 */
	function getListViewSecurityParameter($module) {
		global $current_user,$adb;
		require('user_privileges/user_privileges_'.$current_user->id.'.php');

		$sec_query = '';
		$tabid = getTabid($module);
		$ScopOfAuthority = ScopOfAuthority::getInstance($adb,$module);
		if($is_admin==false && $ScopOfAuthority->getModuleShareInfo() == SHARE_PRIVATE) {

				$sec_query .= " AND (ld_crmentity.smownerid in($current_user->id) OR ld_crmentity.smownerid IN 
					(
						SELECT ld_user2role.userid FROM ld_user2role 
						INNER JOIN ld_users ON ld_users.id=ld_user2role.userid 
						INNER JOIN ld_role ON ld_role.roleid=ld_user2role.roleid 
						WHERE ld_role.parentrole LIKE '".$current_user_parent_role_seq."::%'
					) 
					OR ld_crmentity.smownerid IN 
					(
						SELECT shareduserid FROM ld_tmp_read_user_sharing_per 
						WHERE userid=".$current_user->id." AND tabid=".$tabid."
					) 
					OR 
					(
						ld_crmentity.smownerid in (0)";

				if(!empty($this->groupTable)) {
					$sec_query .= " AND 
						(";
		
					// Build the query based on the group association of current user.
					if(sizeof($current_user_groups) > 0) {
						$sec_query .= " ld_groups.groupid IN (". implode(",", $current_user_groups) .") OR ";
					}
					$sec_query .= " ld_groups.groupid IN 
						(
							SELECT ld_tmp_read_group_sharing_per.sharedgroupid 
							FROM ld_tmp_read_group_sharing_per
							WHERE userid=".$current_user->id." and tabid=".$tabid."
						)";
					$sec_query .= ") ";
				}

				$sec_query .= ")
				)";
		}
		return $sec_query;
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

		$query = "SELECT $fields_list, 'ld_groups_groupname as Assigned To Group', 
				CASE WHEN (ld_users.user_name NOT LIKE '') THEN ld_users.user_name ELSE ld_groups.groupname END 
				AS user_name FROM ld_crmentity INNER JOIN $this->table_name ON ld_crmentity.crmid=$this->table_name.$this->table_index";

		if(!empty($this->customFieldTable)) {
			$query .= " INNER JOIN ".$this->customFieldTable[0]." ON ".$this->customFieldTable[0].'.'.$this->customFieldTable[1] .
				      " = $this->table_name.$this->table_index"; 
		}

		$query .=  
			//"LEFT JOIN " . $this->groupTable[0] . " ON " . $this->groupTable[0].'.'.$this->groupTable[1] . " = $this->table_name.$this->table_index
			"LEFT JOIN ld_groups ON ld_groups.groupid = ld_crmentity.smownerid";
		$query .= " LEFT JOIN ld_users ON ld_crmentity.smownerid = ld_users.id and ld_users.status='Active'";

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
	 * Handle getting related list information.
	 * NOTE: This function has been added to CRMEntity (base class).
	 * You can override the behavior by re-defining it here.
	 */
	//function get_related_list($id, $cur_tab_id, $rel_tab_id, $actions=false) { }

	/** 
	 * Handle saving related module information.
	 * NOTE: This function has been added to CRMEntity (base class).
	 * You can override the behavior by re-defining it here.
	 */
	// function save_related_module($module, $crmid, $with_module, $with_crmid) { }

 	/**
	* Invoked when special actions are performed on the module.
	* @param String Module name
	* @param String Event Type
	*/	
	function vtlib_handler($moduleName, $eventType) {
		require_once('include/utils/utils.php');			
		global $adb;
 		$tabid = getTabid("Users");
 		if($eventType == 'module.postinstall') {		
			// Add a block and 2 fields for Users module
			$blockid = $adb->getUniqueID('ld_blocks');
			$adb->query("insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status)" .
					" values ($blockid,$tabid,'Asterisk Configuration',6,0,0,0,0,0,1)");
			
			$adb->query("insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly," .
					" presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type) " .
					" values ($tabid,".$adb->getUniqueID('ld_field').",'asterisk_extension','ld_asteriskextensions',1,1,'asterisk_extension'," .
					" 'Asterisk Extension',1,0,0,30,1,$blockid,1,'V~O',1,NULL,'BAS')");
			
			$adb->query("insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly," .
					" presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type) " .
					" values ($tabid,".$adb->getUniqueID('ld_field').",'use_asterisk','ld_asteriskextensions',1,56,'use_asterisk'," .
					"' Receive Incoming Calls',1,0,0,30,2,$blockid,1,'C~O',1,NULL,'BAS')");
			
			// Mark the module as Standard module
			$adb->pquery('UPDATE ld_tab SET customized=0 WHERE name=?', array($moduleName));
			
		} else if($eventType == 'module.disabled') {
		// TODO Handle actions when this module is disabled.
		} else if($eventType == 'module.enabled') {
		// TODO Handle actions when this module is enabled.
		} else if($eventType == 'module.preuninstall') {
		// TODO Handle actions when this module is about to be deleted.
		} else if($eventType == 'module.preupdate') {
		// TODO Handle actions before this module is updated.
		} else if($eventType == 'module.postupdate') {
		// TODO Handle actions after this module is updated.
		}
	}

	function getListButtons($app_strings) {
		$list_buttons = Array();

		if(isPermitted('PBXManager','Delete','') == 'yes') $list_buttons['del'] = getFixedLabel('DELETE');

		return $list_buttons;
	}

}

?>