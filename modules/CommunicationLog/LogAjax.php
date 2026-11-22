<?php
/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 ********************************************************************************/

global $current_user;
global $adb;
if(isset($_REQUEST['file']) && ($_REQUEST['file'] !=''))
{
   
	checkFileAccessForInclusion('modules/CommunicationLog/'.$_REQUEST['file'].'.php');
	require_once('modules/CommunicationLog/'.$_REQUEST['file'].'.php');
}
?>