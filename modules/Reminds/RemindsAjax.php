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

    //include("modules/Reminds/RemindsPopup.php");
    /**
     * edit:kevin
     * date:2013-07-02
     * reason:4298
     */ 
	//require_once('include/Ajax/CommonAjax.php');
    if(!file_exists('modules/Reminds/'.$_REQUEST['file'].'.php'))
    {
        include('modules/lingdang/'.$_REQUEST['file'].'.php');
    }
    else
    include('modules/Reminds/'.$_REQUEST['file'].'.php');
?>