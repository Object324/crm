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
include_once dirname(__FILE__) . '/ModTracker_Detail.php';

class ModTracker_Basic {

	var $id;
	var $crmid;
	var $module;
	var $whodid;
	var $changedon;

	function __construct() {

	}

	function exists() {
		return!empty($this->id);
	}

	function initialize($valuemap) {
		$this->id = $valuemap['id'];
		$this->crmid = $valuemap['crmid'];
		$this->module = $valuemap['module'];
		$this->whodid = $valuemap['whodid'];
		$this->changedon = $valuemap['changedon'];
	}

	function getTabid() {
		return getTabid($this->module);
	}

	function getDisplayName() {
		if (!isset($this->_entityName)) {
			$entityName = getEntityName($this->module, array($this->crmid));
			$this->_entityName = $entityName[$this->crmid];
		}
		return $this->_entityName;
	}

	function getViewLink() {
		if (!isset($this->_viewlink)) {
			$entityName = $this->getDisplayName();
			$this->_viewlink = "<a href='javascript:;' onclick='DetailViewReferenceLinkClick(ld(this),event)' referencemodule='".$this->module."' referencerecord='" . $this->crmid . "' >" . $entityName . "</a>";
		}
		return $this->_viewlink;
	}

	function getModifiedOn() {
		$changedOn = new DateTimeField($this->changedon);
		return $changedOn->getDisplayDateTimeValue();
	}

	function getModifiedByLabel() {
		global $current_user, $currentModule;
		if (isset($current_user) && $current_user->id == $this->whodid) {
			return $current_user->last_name;
		}
		return getUserFullName($this->whodid);
	}

	function getDetails() {
		return ModTracker_Detail::listAll($this);
	}

	function isViewPermitted() {
		global $current_user;
		if (isset($current_user) && is_admin($current_user))
			return true;
		// Does current user has access to view the record that was tracked?
		if ($this->module == 'Events') {
			$moduleName = 'Calendar';
		} else {
			$moduleName = $this->module;
		}
		return (isPermitted($moduleName, 'DetailView', $this->crmid) == "yes");
	}

	static function getById($id) {
		global $adb;
		$instance = false;
		$result = $adb->pquery('SELECT * FROM ld_modtracker_basic WHERE id=?', Array($id));
		if ($adb->num_rows($result)) {
			$rowmap = $adb->fetch_array($result);
			$instance = new self();
			$instance->initialize($rowmap);
		}
		return $instance;
	}
    //edit:can reason:11465: 修改日志功能异常 ,other:获取日志记录数目
   static function gethistorylistCount($crmid)
   {
        global $adb;
        $result = $adb->pquery("SELECT * FROM ld_modtracker_basic WHERE crmid=?",
						array($crmid));
       if($adb->num_rows($result))
       {
        return $adb->num_rows($result);
       }
       else
       {
        return 0;
       }
   }
	static function getByCRMId($crmid, $atpoint) {
		global $adb, $current_user, $log;
		$instance = false;

		// Avoid SQL Injection attacks
		$purifiedAtPoint = $adb->sql_escape_string($atpoint);
        //print_r($crmid);
		$result = $adb->pquery("SELECT * FROM ld_modtracker_basic WHERE crmid=? ORDER BY changedon DESC LIMIT $purifiedAtPoint, 1",
						array($crmid));
        //var_dump($result);        
		if ($adb->num_rows($result)) {
			$rowmap = $adb->fetch_array($result);
			$instance = new self();
			$instance->initialize($rowmap);
		}
        //var_dump($instance);
		return $instance;
	}

	static function listAll($module=false, $asc=true) {
		global $adb;
		$instances = Array();
		$result = false;

		if ($module) {
			if ($asc)
				$result = $adb->pquery('SELECT * FROM ld_modtracker_basic
				WHERE module=? ORDER BY id', Array($module));
			else
				$result = $adb->pquery('SELECT * FROM ld_modtracker_basic
				WHERE module=? ORDER BY id DESC', Array($module));
		}

		if ($result && $adb->num_rows($result)) {
			for ($index = 0; $index < $adb->num_rows($result); ++$index) {
				$rowmap = $adb->fetch_array($result);
				$instance = new self();
				$instance->initialize($rowmap);
				$instances[] = $instance;
			}
		}
		return $instances;
	}

}

?>