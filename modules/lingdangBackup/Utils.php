<?php
/*+*******************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 *  The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 *********************************************************************************/

require_once 'include/utils/utils.php';

/**
 * Description of Utils
 *
 * @author MAK
 */
class lingdang_BackupUtils {

	public static function getFTPBackupDetails() {
		$db = PearDatabase::getInstance();
		$details = array();
		$query = "select * from ld_systems where server_type=?";
		$result = $db->pquery($query, array('ftp_backup'));
		$rowCount = $db->num_rows($result);
		if($rowCount > 0) {
			$details['server'] = $db->query_result($result,0,'server');
			$details['username'] = $db->query_result($result,0,'server_username');
			$details['password'] = $db->query_result($result,0,'server_password');
			return $details;
		}
		return null;
	}

	public static function doFTPBackup($source,$details) {
		//TODO wirte a cleaner ftp handle
		ftpBackupFile($source, $details['server'], $details['username'], $details['password']);
		if(file_exists($source)){
			unlink($source);
		}
	}

	public static function getLocalBackupPath() {
		$db = PearDatabase::getInstance();
		$path_query = $db->pquery("SELECT * FROM ld_systems WHERE server_type = ?",
				array('local_backup'));
        $path = $db->query_result($path_query,0,'server_path');
		return $path;
	}

}
?>