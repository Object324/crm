<?php


class CRMEntity_Del_Restore
{
    
    	/** Function to delete an entity with given Id */
	static function trash($module, $id,$focus) {
		global  $current_user, $adb;
		$focus->mark_deleted($id);
		$focus->unlinkDependencies($module, $id);
        $focus->getModuleStatic('ModTracker');
		$focus->modstatic->saveFieldLogOne($module,'deleted',$id,0,1);
        ////27427: 单据删除的时候，删除审批日志
        $focus->deleteRelatedDatas($module, $id);
        //33609: 删除单据，不删除审批历史
        $sql="delete from ld_approvelog where crmid=?";
        $adb->pquery($sql,array($id));
		//2024-4-11 xxy 删除单据后，更新主表中的审批状态为“未提交”
		crm_load_class_file('cls_ApproveCache','modules/Approve');
		$approvemodules = cls_ApproveCache::getAllModuleInfo();
		if(array_key_exists($module,$approvemodules)){
			$update_sql = 'update '.$focus->table_name.' set approvestatus="未提交" where '.$focus->table_index.' = ?;';
			$adb->pquery($update_sql, array($id));
		}
        //系统操作日志
		crm_load_class_file('cls_OperationLogs','modules/Settings/cls_OperationLogs');
		cls_OperationLogs::saveLogs($module,'Delete',$id,$_REQUEST);
		//duan 20240818 删除后判断是否需要重算客户和线索的保护结束日期
        $focus->check_recount_protectdate($id);
	}

	/** Function to unlink all the dependent entities of the given Entity by Id */
	static function unlinkDependencies($module, $id,$focus) {
		

		$fieldRes = $focus->db->pquery('SELECT tabid, tablename, columnname FROM ld_field WHERE fieldid IN (
			SELECT fieldid FROM ld_fieldmodulerel WHERE relmodule=?)', array($module));
		$numOfFields = $focus->db->num_rows($fieldRes);
		for ($i = 0; $i < $numOfFields; $i++) {
			$tabId = $focus->db->query_result($fieldRes, $i, 'tabid');
			$tableName = $focus->db->query_result($fieldRes, $i, 'tablename');
			$columnName = $focus->db->query_result($fieldRes, $i, 'columnname');

			$relatedModule = getTabname($tabId);
			$focusObj = CRMEntity::getInstance($relatedModule);

			//Backup Field Relations for the deleted entity
			$relQuery = "SELECT $focusObj->table_index FROM $tableName WHERE $columnName=?";
			$relResult = $focus->db->pquery($relQuery, array($id));
			$numOfRelRecords = $focus->db->num_rows($relResult);
			if ($numOfRelRecords > 0) {
				$recordIdsList = array();
				for ($k = 0; $k < $numOfRelRecords; $k++) {
					$recordIdsList[] = $focus->db->query_result($relResult, $k, $focusObj->table_index);
				}
				$params = array($id, RB_RECORD_UPDATED, $tableName, $columnName, $focusObj->table_index, implode(",", $recordIdsList));
				$focus->db->pquery('INSERT INTO ld_relatedlists_rb VALUES (?,?,?,?,?,?)', $params);
			}
		}
	}

	/** Function to unlink an entity with given Id from another entity */
	static function unlinkRelationship($id, $return_module, $return_id,$focus) {
		global $adb, $currentModule;

		$query = 'DELETE FROM ld_crmentityrel WHERE (crmid=? AND relmodule=? AND relcrmid=?) OR (relcrmid=? AND module=? AND crmid=?)';
		$params = array($id, $return_module, $return_id, $id, $return_module, $return_id);
		$adb->pquery($query, $params);

		$fieldRes = $adb->pquery('SELECT tabid, tablename, columnname FROM ld_field WHERE fieldid IN (
			SELECT fieldid FROM ld_fieldmodulerel WHERE module=? AND relmodule=?)', array($currentModule, $return_module));
		$numOfFields = $adb->num_rows($fieldRes);
		for ($i = 0; $i < $numOfFields; $i++) {
			$tabId = $adb->query_result($fieldRes, $i, 'tabid');
			$tableName = $adb->query_result($fieldRes, $i, 'tablename');
			$columnName = $adb->query_result($fieldRes, $i, 'columnname');

		//	$relatedModule = getTabname($tabId);
			//$focusObj = CRMEntity::getInstance($relatedModule);

			$updateQuery = "UPDATE $tableName SET $columnName=? WHERE $columnName=? AND $focusObj->table_index=?";
			$updateParams = array(null, $return_id, $id);
			$adb->pquery($updateQuery, $updateParams);
		}
      
	}

	/** Function to restore a deleted record of specified module with given crmid
	 * @param $module -- module name:: Type varchar
	 * @param $entity_ids -- list of crmids :: Array
	 */
	static function restore($module, $id,$focus) {
		global $current_user, $adb;

		$focus->db->println("TRANS restore starts $module");
		$focus->db->startTransaction();
        
		$date_var = date("Y-m-d H:i:s");
		$query = 'UPDATE '.$focus->table_name.' SET deleted=0,modifiedtime=?,modifiedby=? WHERE '.$focus->table_index.' = ?;';
		$focus->db->pquery($query, array($focus->db->formatDate($date_var, true), $current_user->id, $id), true, "Error restoring records :");
		$focus->getModuleStatic('ModTracker');//字段修改日志
       
        $focus->modstatic->saveFieldLogOne($module,'deleted',$id,1,0);
       
        //Restore related entities/records
		$focus->restoreRelatedRecords($module, $id);
		//系统操作日志
		crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');
		cls_OperationLogs::saveLogs($module,'Reduction',$id);
	}

	/** Function to restore all the related records of a given record by id */
	static function restoreRelatedRecords($module, $record,$focus) {

		$result = $focus->db->pquery('SELECT * FROM ld_relatedlists_rb WHERE entityid = ?', array($record));
		$numRows = $focus->db->num_rows($result);
		for ($i = 0; $i < $numRows; $i++) {
			$action = $focus->db->query_result($result, $i, "action");
			$rel_table = $focus->db->query_result($result, $i, "rel_table");
			$rel_column = $focus->db->query_result($result, $i, "rel_column");
			$ref_column = $focus->db->query_result($result, $i, "ref_column");
			$related_crm_ids = $focus->db->query_result($result, $i, "related_crm_ids");

			if (strtoupper($action) == RB_RECORD_UPDATED) {
				$related_ids = explode(",", $related_crm_ids);
				if ($rel_table == 'ld_crmentity' && $rel_column == 'deleted') {
					$sql = "UPDATE $rel_table set $rel_column = 0 WHERE $ref_column IN (" . generateQuestionMarks($related_ids) . ")";
					$focus->db->pquery($sql, array($related_ids));
				} else {
					$sql = "UPDATE $rel_table set $rel_column = ? WHERE $rel_column = 0 AND $ref_column IN (" . generateQuestionMarks($related_ids) . ")";
					$focus->db->pquery($sql, array($record, $related_ids));
				}
			} elseif (strtoupper($action) == RB_RECORD_DELETED) {
				if ($rel_table == 'ld_seproductrel') {
					$sql = "INSERT INTO $rel_table($rel_column, $ref_column, 'setype') VALUES (?,?,?)";
					$focus->db->pquery($sql, array($record, $related_crm_ids, $module));
				} else {
					$sql = "INSERT INTO $rel_table($rel_column, $ref_column) VALUES (?,?)";
					$focus->db->pquery($sql, array($record, $related_crm_ids));
				}
			}
		}

		//Clean up the the backup data also after restoring
		$focus->db->pquery('DELETE FROM ld_relatedlists_rb WHERE entityid = ?', array($record));
	}
}

?>