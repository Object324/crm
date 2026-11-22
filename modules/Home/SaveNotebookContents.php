<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
/**
 * Created on 10-Oct-08
 * this file saves the notebook contents to database
 */
Zend_Json::$useBuiltinEncoderDecoder = true;
$status = SaveNotebookContents();
if($status == true) {
    require_once('include/home.php');
    $homeObj=new Homestuff;
    $contents = $homeObj->getNoteBookContents($_REQUEST['notebookid']);
}
$returnvalue = array('status' => $status, 'contents' => $contents);
echo Zend_Json::encode($returnvalue);

function SaveNotebookContents(){
	if(empty($_REQUEST['notebookid'])){
		return false;
	}else{
		$notebookid = $_REQUEST['notebookid'];
	}
	
	global $adb,$current_user;
	
	$contents = $_REQUEST['contents'];
	$query='select * from ld_notebook_contents where notebookid=? and userid=?';
    $result=$adb->pquery($query,array($notebookid,$current_user->id));
    $num_rows=$adb->num_rows($result);
    if($adb->num_rows($result)>0){
        $sql = "update ld_notebook_contents set contents=? where userid=? and notebookid=?";
	   $adb->pquery($sql, array($contents, $current_user->id, $notebookid));
    }
    else{
        $sql = "insert into ld_notebook_contents(userid,notebookid,contents)values(?,?,?)";
	   $adb->pquery($sql, array($current_user->id, $notebookid,$contents));
    }
	
	return true;
}
?>