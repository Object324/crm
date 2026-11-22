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
 * Description of lingdangBackupException
 *
 * @author MAK
 */
class lingdangBackupException extends Exception{
	public $code;
	public $message;

	function __construct($errCode,$msg){
		$this->code = $errCode;
		$this->message = $msg;
	}
}

class lingdangBackupErrorCode {
	public static $ZIP_CREATE_FAILED = 'CONNECT_ERROR';
	public static $TABLE_NAME_ERROR = 'TABLE_LIST_FETCH_ERROR';
	public static $SQL_EXECUTION_ERROR = 'SQL_EXECUTION_ERROR';
	public static  $FTP_CONNECT_FAILED = 'FTP_CONNECT_FAILED';
	public static  $FTP_LOGIN_FAILED = 'FTP_LOGIN_FAILED';
}

?>