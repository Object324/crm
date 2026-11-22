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

require_once 'modules/lingdangBackup/Locations/Location.php';

/**
 * Description of FTPBackup
 *
 * @author MAK
 */
class lingdang_FTPBackup extends lingdang_Location{

	protected $server;
	protected $username;
	protected $password;
	protected $connection;
	private $initialized = false;

	public function __construct($limit) {
		parent::__construct($limit);
		$db = PearDatabase::getInstance();
		$details = array();
		$query = "select * from ld_systems where server_type=?";
		$result = $db->pquery($query, array('ftp_backup'));
		$rowCount = $db->num_rows($result);
		if($rowCount > 0) {
			$this->server = $db->query_result($result,0,'server');
			$this->username = $db->query_result($result,0,'server_username');
			$this->password = $db->query_result($result,0,'server_password');
		}else{
			//TODO handler error;
		}
	}

	public function init() {
		$this->connection = @ftp_connect($this->server);
		if(empty($this->connection)) {
			throw new lingdangBackupException(lingdangBackupErrorCode::$FTP_CONNECT_FAILED,
					getTranslatedString('LBL_FTP_CONNECT_FAILED', 'lingdangBackup'));
		}
		$result = @ftp_login($this->connection, $this->username, $this->password);
		if(empty($result)) {
			throw new lingdangBackupException(lingdangBackupErrorCode::$FTP_LOGIN_FAILED,
					getTranslatedString('LBL_FTP_LOGIN_FAILED', 'lingdangBackup'));
		}
		ftp_pasv($this->connection, true);
		$this->initialized = true;
	}

	public function limitbackup() {
		$fileList = $this->getBackupTimeList();
		$connection = $this->getConnection();
		for ($index=0; count($fileList) > $this->limit -1 ; ++$index) {
			$fileName = lingdang_BackupZip::getDefaultFileName($fileList[$index]);
			@ftp_delete($connection, $fileName);
			unset($fileList[$index]);
		}
	}

	public function getBackupTimeList() {
		$backupFileList = array();
		$connection = $this->getConnection();
		$fileList = ftp_nlist($connection, '.');
		foreach ($fileList as $file) {
			if ($file == "." || $file == "..") {
				continue;
			}
			$fileName = $this->getFileName($file,'/');
			$fileName = explode('-',$fileName);
			$fileName = $fileName[1];
			$date = substr($fileName, 0, strrpos($fileName,'.'));
			$date = str_replace('_',':',$date);
			if(strtotime($date) !== false) {
				$backupFileList[] = strtotime($date);
			}
		}
		sort($backupFileList);
		return $backupFileList;
	}

	public function getBackupFileList() {
		$backupFileList = array();
		$connection = $this->getConnection();
		$fileList = ftp_nlist($connection, '.');
		foreach ($fileList as $file) {
			if ($file == "." || $file == "..") {
				continue;
			}
			$origFileName = $this->getFileName($file, '/');
			$fileName = explode('-',$origFileName);
			$fileName = $fileName[1];
			$date = substr($fileName, 0, strrpos($fileName,'.'));
			$date = str_replace('_',':',$date);
			if(strtotime($date) !== false) {
				$backupFileList[] = $origFileName;
			}
		}
		return $backupFileList;
	}

	public function save($source) {
		$dest=$this->getFileName($source);
		$connection = $this->getConnection();
		$upload = @ftp_put($connection, $dest, $source, FTP_BINARY);
		// check upload status
		if (empty($upload)) {
			//TODO handle error
		}
		$this->close();
		if(file_exists($source)){
			unlink($source);
		}
	}

	public function close() {
		$connection = $this->getConnection();
		ftp_close($connection);
		$this->initialized = false;
	}

	public function getConnection() {
		if(!$this->initialized) {
			$this->init();
		}
		return $this->connection;
	}
}
?>