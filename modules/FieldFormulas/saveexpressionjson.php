<?php
/*+*******************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ******************************************************************************/
require_once "include/Zend/Json.php";
require 'include.inc';

function vtSaveExpressionJson($adb, $request){
	$moduleName=$request['modulename'];
	$fieldName=$request['fieldname'];
	$expression=$request['expression'];
	$mem = new VTModuleExpressionsManager($adb);
	$me = $mem->retrieve($moduleName);

	$me->add($fieldName, $expression);
	if($me->state=='savable'){
		$mem->save($me);
		echo Zend_Json::encode(array('status'=>'success'));
	}else{
		echo Zend_Json::encode(array('status'=>'fail', 'message'=>$me->message));
	}
}
vtSaveExpressionJson($adb, $_GET);
?>