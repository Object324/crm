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

require_once 'include/db_backup/backup.php';

/**
 * Description of lingdang_PHPZip
 *
 * @author MAK
 */
class lingdang_PHPZip extends lingdang_BackupZip {

	private $createZip;

	public function __construct($fileName) {
		$this->fileName = $fileName;
		$this->createZip = new createDirZip();
	}

	public function addDirectory($directoryPath, $zipPath) {
		$this->createZip->addDirectory($zipPath);
		$this->createZip->get_files_from_folder($directoryPath, $zipPath);
	}

	public function addFile($filePath, $parentDirectory) {
		if(empty($parentDirectory)) {
			$this->addTrailingSlash($parentDirectory);
		}
		$filedata = implode("", file($filePath));
		$this->createZip->addFile($filedata,$parentDirectory.'database.sql');
	}

	public function close() {
		$fd = fopen ($this->fileName, 'wb');
		$out = fwrite ($fd, $this->createZip->getZippedfile());
		fclose ($fd);
	}

}
?>