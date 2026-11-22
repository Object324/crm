<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
require('Smarty/libs/Smarty.class.php');

class lingdangCRM_Smarty extends Smarty{


	/** END */
	
	/**This function sets the smarty directory path for the member variables	
	*/
	function __construct()
	{
		global $RegisterVersionNo,$CALENDAR_DISPLAY, $WORLD_CLOCK_DISPLAY, $CALCULATOR_DISPLAY, $CHAT_DISPLAY, $current_user,$LAST_READ;
		require('config.inc.php');
		//$this->Smarty();
        parent::__construct();
		$this->template_dir = $root_directory.'Smarty/templates';
		$this->compile_dir = $root_directory.'Smarty/templates_c';
		$this->config_dir = $root_directory.'Smarty/configs';
		$this->cache_dir = $root_directory.'Smarty/cache';
        //$this->use_sub_dirs=true;
		//$this->caching = true;
	        //$this->assign('app_name', 'Login');
		$this->assign('CALENDAR_DISPLAY', $CALENDAR_DISPLAY); 
 		$this->assign('WORLD_CLOCK_DISPLAY', $WORLD_CLOCK_DISPLAY); 
 		$this->assign('CALCULATOR_DISPLAY', $CALCULATOR_DISPLAY);
         $this->assign('LAST_READ',$LAST_READ);
        if($RegisterVersionNo!=2)//2:销售通
        {
            $this->assign('CHAT_DISPLAY', $CHAT_DISPLAY);
        }
       
 		
		$this->assign('CURRENT_USER_ID',$current_user->id);
        require_once(globalStatic::$root_directory . "CRMSecurity.php");
 		setGLobaLURLSmarty($this);//返回css,js全局变量
	}
}

?>