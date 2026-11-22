<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-04-29
 */
header("Content-type: text/html; charset=utf-8");
if($_REQUEST['static'] == 'puyoung'){
    $_REQUEST['static'] = 'lingdang';
}
$input = $_REQUEST;
$static = $input['static'];
import('modules.'.$static.'.static'.$static,'class');
$static = 'static'.$static;
$method = $input['method'];
$focus = new $static();

if(method_exists($focus,$method)){
    
	$entity = $focus->$method($input);
	if(!empty($entity)){
	//	require_once('./include/Zend/Json.php');
        @ob_clean();
        @ob_flush();
		$json = new Zend_Json();
		$jsonentity = $json->encode($entity);
		echo $jsonentity;die;
	}
}
echo '';die;
?>