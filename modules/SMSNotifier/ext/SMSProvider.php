<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
class SMSProvider {
	
	static function getInstance($providername) {
		if(!empty($providername)) {
			$providername = trim($providername);

			$filepath = dirname(__FILE__) . "/providers/{$providername}.php";
			checkFileAccessForInclusion($filepath);
			
			if(!class_exists($providername)) { 
				include_once $filepath;
			}
			return new $providername();
		}
		return false;
	}

	static function listAll() {
		$providers = array();
		if ($handle = opendir( dirname(__FILE__) . '/providers')){
			while (false !== ($file = readdir($handle))) {
				if (!in_array($file, array('.', '..', '.svn', 'CVS'))) {
					if(preg_match("/(.*)\.php$/", $file, $matches)) {
						$providers[] = $matches[1];
					}
				}
			}
		}
		return $providers;

	}


}
?>