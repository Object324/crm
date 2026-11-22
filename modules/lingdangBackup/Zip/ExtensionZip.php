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

/**
 * Description of Zip
 *
 * @author MAK
 */
class lingdang_ExtensionZip extends lingdang_BackupZip {

	private $zip;

	public function __construct($fileName) {
		$this->fileName = $fileName;
		$this->zip = new ZipArchive();
		// open archive
		if ($this->zip->open($this->fileName, ZIPARCHIVE::CREATE) !== TRUE) {
			throw new lingdangBackupException(lingdangBackupErrorCode::$ZIP_CREATE_FAILED, 
					getTranslatedString('LBL_CREATE_ZIP_FAILURE', 'lingdangBackup'));
		}
	}

	public function addDirectory($directoryPath, $zipPath) {
		// initialize an iterator
		// pass it the directory to be processed
		$iterator = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($directoryPath),
				RecursiveIteratorIterator::SELF_FIRST);

		// iterate over the directory
		// add each file found to the archive
		foreach ($iterator as $file) {
			$file = realpath($file);
			if (is_dir($file) === true) {
				$file = $this->addTrailingSlash($file);
				$this->zip->addEmptyDir($zipPath.str_replace($directoryPath, '', $file));
			}else if (is_file($file) === true) {
				$this->zip->addFromString($zipPath.str_replace($directoryPath, '', $file), file_get_contents($file));
			}
		}
	}

	public function addFile($filePath, $parentDirectory) {
		if(empty($parentDirectory)) {
			$this->addTrailingSlash($parentDirectory);
		}
		
		$sucess = $this->zip->addFromString($parentDirectory.'database.sql',file_get_contents($filePath));
		if($sucess == false) {
			throw new lingdangBackupException(lingdangBackupErrorCode::$ZIP_CREATE_FAILED,
				getTranslatedString('LBL_ZIP_FILE_ADD_FAILURE', 'lingdangBackup'));
		}
	}

	public function close() {
		// close and save archive
		$this->zip->close();
	}
	
}
?>