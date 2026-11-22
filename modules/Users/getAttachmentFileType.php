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
global $adb;
$module_name=$_REQUEST['module_name'];
if(!empty($_REQUEST['save']) && $_REQUEST['save'] == 'yes'){
	if(!empty($_REQUEST['fileformat'] && $_REQUEST['module_name'])  ){
        $adb->pquery(' delete from ld_attachmentstype where module_name=?',array($module_name));
		$fileformat = explode(',',$_REQUEST['fileformat']);
		foreach($fileformat as $filetype){
			if(!empty($filetype && $module_name) ){
                $adb->pquery('insert into ld_attachmentstype(file_type,module_name) values (?,?)',array(strtolower(trim($filetype)),$module_name));
            }
		}
		echo 'success';
	}
	echo 'error';
	exit();
}
//wyt 220706_XUQIU1000243_附件字段设置允许上传的文件格式新增模块控制
$query = 'select file_type from ld_attachmentstype where module_name=?';
$result = $adb->pquery($query,array($module_name));
$num_rows = $adb->num_rows($result);
if($num_rows > 0){
	for($i=0; $i<$num_rows; $i++){
		$file_type[] = $adb->query_result($result,$i,'file_type');
	}
}else{
    $query1 = "select file_type from ld_attachmentstype where module_name ='' or module_name is null ";
    $result1 = $adb->pquery($query1,array());
    $num_rows1 = $adb->num_rows($result1);
    for($i=0; $i<$num_rows1; $i++){
        $file_type[] = $adb->query_result($result1,$i,'file_type');
    }
}
if(!empty($_REQUEST['stype'])){
	if($_REQUEST['stype'] == 'set'){
		$title = getFixedLabel('setthefileformat');
		$entity = array(
			'content' => implode(',',$file_type),
			'title' => $title
		);
	}else{
		$title = getFixedLabel('viewthefileformat');
		$entity = array(
			'content' => implode(',',$file_type),
			'title' => $title
		);
	}
}
// require_once('./include/Zend/Json.php');
$json = new Zend_Json();
$jsonentity = $json->encode($entity);
echo $jsonentity;die;
?>