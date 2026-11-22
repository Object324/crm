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

require_once 'include/db_backup/StagedBackup.php';
require_once 'include/db_backup/DatabaseBackup.php';
require_once 'include/db_backup/Source/MysqlSource.php';
require_once 'include/db_backup/Targets/File.php';
require_once 'modules/lingdangBackup/Zip/BackupZip.php';
require_once 'modules/lingdangBackup/Exception/lingdangBackupException.php';
require_once 'include/utils/utils.php';
require_once 'modules/lingdangBackup/Utils.php';
require_once 'modules/lingdangBackup/Locations/FTPBackup.php';
require_once 'modules/lingdangBackup/Locations/LocalBackup.php';

/**
 * Description of lingdangBackup
 *
 * @author MAK
 */
class lingdangBackup {
	//'storage',
	private $folderList = array('user_privileges','templatePrintFile');
	private $location = null;
	/**
	 *
	 * @var lingdang_BackupZip
	 */
	private $zip = null;

	public function __construct($filename) {
		$path = null;
		$limit = $this->getBackupLimit();
		if($this->isLocalBackupEnabled()) {
			$this->location = lingdang_Location::getInstance(lingdang_Location::$LOCAL, $limit);
			$path = $this->location->getPath();
		}else{
			$this->location = lingdang_Location::getInstance(lingdang_Location::$FTP, $limit);
		}
		$this->zip = lingdang_BackupZip::getInstance($path,$filename);
		ini_set('memory_limit', $this->getMemoryLimit());
		ini_set('max_execution_time', $this->getExecutionTimeLimit());
	}

	public function backup() {
		if($this->isLocalBackupEnabled() || $this->isFTPBackupEnabled()) {
			$sourceConfig = DatabaseConfig::getInstanceFromConfigFile();
			$source = new MysqlSource($sourceConfig);
			$fileDest = new File($sourceConfig);
			$dbBackup = new DatabaseBackup($source, $fileDest);
			$dbBackup->backup();

			$this->location->limitBackup();

			$this->zip->addFile($fileDest->getFilePath(), false);
			foreach ($this->folderList as $folder) {
				$path = $this->getFolderPath($folder);
				$folder = $this->addTrailingSlash($folder);
				$this->zip->addDirectory($path, $folder);
			}
			$this->zip->close();
			$this->location->save($this->getBackupFileName());
			if(file_exists($fileDest->getFilePath())) {
				//unlink($fileDest->getFilePath());
			}
		}
	}
    public function setBackupFileName($filename)
    {
        $this->filename=$filename;
    }
	public function getBackupFileName() {
		return $this->zip->getBackupFileName();
	}

	public function getBackupFileList() {
		return $this->location->getBackupFileList();
	}
	public function getBackupLimit() {
		require 'modules/lingdangBackup/backup.config.php';
		return $backupLimit;
	}

	public function getMemoryLimit() {
		require 'modules/lingdangBackup/backup.config.php';
		return $memoryLimit;
	}

	public function getExecutionTimeLimit() {
		require 'modules/lingdangBackup/backup.config.php';
		return $executionTimeLimit;
	}

	private function getFolderPath($folder) {
		switch($folder) {
			case 'storage': return $this->getStorageFolderPath();
			case 'test': return $this->getTestFolderPath();
			case 'user_privileges': return $this->getUserPreviligesPath();
            case 'templatePrintFile': return $this->getTemplatePrintFilePath();
		}
	}

	public function addTrailingSlash($path) {
		return (strrpos($path, DIRECTORY_SEPARATOR) !== strlen($path) -1 )? $path.DIRECTORY_SEPARATOR:$path;
	}

	public function fixPathSeparator($path) {
		$start = 0;
		do {
			$done = false;
			$index = strpos($path, '/',$start);
			$start = $index + 1;
			if($index != false && $path[$index - 1] == '\\'.DIRECTORY_SEPARATOR) {
				continue;
			}else if($index != false){
				$path[$index] = DIRECTORY_SEPARATOR;
			}
		}while($index != false);
		return $path;
	}

	public function getStorageFolderPath() {
		require 'config.inc.php';
		$rootPath = $this->addTrailingSlash($this->fixPathSeparator($root_directory));
		return $rootPath.'storage'.DIRECTORY_SEPARATOR;
	}

	public function getTestFolderPath() {
		require 'config.inc.php';
		$rootPath = $this->addTrailingSlash($this->fixPathSeparator($root_directory));
		return $rootPath.'test'.DIRECTORY_SEPARATOR;
	}

	public function getUserPreviligesPath() {
		require 'config.inc.php';
		$rootPath = $this->addTrailingSlash($this->fixPathSeparator($root_directory));
		return $rootPath.'user_privileges'.DIRECTORY_SEPARATOR;
	}
    
    public function getTemplatePrintFilePath() {
		require 'config.inc.php';
		$rootPath = $this->addTrailingSlash($this->fixPathSeparator($root_directory));
		return $rootPath.'templatePrintFile'.DIRECTORY_SEPARATOR;
	}

	public function isLocalBackupEnabled() {
		require 'user_privileges/enable_backup.php';
		return $enable_local_backup == 'true';
	}

	public function isFTPBackupEnabled() {
		require 'user_privileges/enable_backup.php';
		return $enable_ftp_backup == 'true';
	}

	 /**
     * Invoked when special actions are performed on the module.
     * @param String Module name
     * @param String Event Type (module.postinstall, module.disabled, module.enabled, module.preuninstall)
     */
    function vtlib_handler($modulename, $event_type) {
        if($event_type == 'module.postinstall') {
			global $adb;
			// Mark the module as Standard module
			$adb->pquery('UPDATE ld_tab SET customized=0 WHERE name=?', array($modulename));
        } else if($event_type == 'module.disabled') {
            // TODO Handle actions when this module is disabled.
        } else if($event_type == 'module.enabled') {
            // TODO Handle actions when this module is enabled.
        } else if($event_type == 'module.preuninstall') {
            // TODO Handle actions when this module is about to be deleted.
        } else if($event_type == 'module.preupdate') {
            // TODO Handle actions before this module is updated.
        } else if($event_type == 'module.postupdate') {
            // TODO Handle actions after this module is updated.
        }
    }

}
?>