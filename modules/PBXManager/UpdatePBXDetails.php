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
savePBXDetails();

function savePBXDetails(){
	global $adb;
	$semodule = $_REQUEST['semodule'];
	
	if($semodule == 'asterisk'){
		$server = $_REQUEST['qserver'];
		$port = $_REQUEST['qport'];
		$username = $_REQUEST['qusername'];
		$password = $_REQUEST['qpassword'];
		$version = $_REQUEST['version'];
		
		$sql = "delete from ld_asterisk";
		$adb->query($sql);	//delete older records (if any)
		
		$sql = "insert into ld_asterisk (server, port, username, password, version) values (?,?,?,?,?)";
		$params = array($server,$port, $username, $password, $version);
		$adb->pquery($sql, $params);
	}
}
?>