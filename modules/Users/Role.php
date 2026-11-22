<?php
/*+***********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************ */

class lingdang_Role {

	private $id;
	private $name;
	private $parentRoleSequence;
	private $depth;

	private function __construct($id,$name,$parentRole,$depth) {
		$this->id = $id;
		$this->name = $name;
		$this->parentRoleSequence = $parentRole;
		$this->depth = $depth;
	}

	public function getId() {
		return $this->id;
	}

	public function getName() {
		return $this->name;
	}

	public function getParentRole() {
		return $this->parentRoleSequence;
	}

	public function getDepth() {
		return $this->depth;
	}

	public function setDepty($depth) {
		$this->depth = $depth;
	}

	public function setParentRole($parentRole) {
		$this->parentRoleSequence = $parentRole;
	}

	/**
	 *
	 * @param QueryResult $result
	 * @param Number $row
	 * @return self
	 */
	public static function getInstanceByResult($result, $row) {
		$db = PearDatabase::getInstance();
		$rowData = $db->query_result_rowdata($result, $row);
		$depth = $rowData['depth'];
		$id = $rowData['roleid'];
		$name = $rowData['rolename'];
		$parentRole = $rowData['parentrole'];
		return new self($id, $name, $parentRole, $depth);

	}

	/**
	 *
	 * @param Role id $id
	 * @return lingdang_Role
	 */
	public static function getInstanceById($id) {
		$db = PearDatabase::getInstance();
		$sql = "select * from ld_role where roleid=?";
		$params = array($id);
		$result = $db->pquery($sql, $params);
		return self::getInstanceByResult($result, 0);
	}

	/**
	 *
	 * @param lingdang_Role $role
	 */
	public function moveTo($role) {
		//parent role has current role id in parent role sequence, remove current role id.
		$parentRoleSequence = $role->getParentRole().'::'.$this->getId();
		$subDepth=$role->getDepth() + 1;
		$query="update ld_role set parentrole=?,depth=? where roleid=?";
		$adb->pquery($query, array($parentRoleSequence, $subDepth, $this->getId()));
		$this->setDepty($subDepth);
		$this->setParentRole($parentRoleSequence);
	}

	public function delete($role) {
		$db = PearDatabase::getInstance();
		$db->dieOnError = true;
		$sql = "update ld_user2role set roleid=? where roleid=?";
		$db->pquery($sql, array($role->getId(), $this->getId()));

		//Deleteing from ld_role2profile lingdang_table
        /*
        edit:can
        date:20130401
        reason:用户授权
        other:在权限删除中删除角色和权限管理内容
        */
	//	$sql = "delete from ld_role2profile where roleid=?";
		//$db->pquery($sql, array($this->getId()));

		//delete handling for ld_groups
		$sql = "delete from ld_group2role where roleid=?";
		$db->pquery($sql, array($this->getId()));

		$sql = "delete from ld_group2rs where roleandsubid=?";
		$db->pquery($sql, array($this->getId()));

		//delete handling for sharing rules
		deleteRoleRelatedSharingRules($this->getId());
		
		//delete from ld_role lingdang_table;
		$sql = "delete from ld_role where roleid=?";
		$db->pquery($sql, array($this->getId()));

		$targetParentRoleSequence = $role->getParentRole();
		$parentRoleSequence = $this->getParentRole();
		$roleInfoList = getRoleAndSubordinatesInformation($roleId);
		foreach ($roleInfoList as $roleId => $roleInfo) {
			// Invalidate any cached information
			VTCacheUtils::clearRoleSubordinates($roleId);
			if($roleId == $this->getId()) {
				continue;
			}
			$currentParentRoleSequence = $roleInfo[1];
			$currentParentRoleSequence = str_replace($parentRoleSequence,$targetParentRoleSequence,
					$currentParentRoleSequence);
			$subDepth = count(explode('::', $currentParentRoleSequence))-1;
			$query="update ld_role set parentrole=?,depth=? where roleid=?";
			$db->pquery($query, array($currentParentRoleSequence, $subDepth, $roleId));
		}

	}

}

?>