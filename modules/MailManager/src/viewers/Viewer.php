<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
  * The contents of this file are subject to the lingdang CRM Public License Version 1.1
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/

class MailManager_Viewer extends lingdangCRM_Smarty {
	
	function __construct() {
		parent::__construct();
		
		global $app_strings, $mod_strings, $currentModule, $theme;
		
		$this->assign('CUSTOM_MODULE', true);

		$this->assign('APP', $app_strings);
		$this->assign('MOD', $mod_strings);
		$this->assign('MODULE', $currentModule);
		// TODO: Update Single Module Instance name here.
		$this->assign('SINGLE_MOD', 'SINGLE_'.$currentModule); 
		$this->assign('CATEGORY', getParentTab());
		$this->assign('IMAGE_PATH', "themes/$theme/images/");
		$this->assign('THEME', $theme);
		return parent::__construct();
	}
}
?>