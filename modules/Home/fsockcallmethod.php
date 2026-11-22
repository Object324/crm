<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-27
 */
$root_dir= dirname(dirname(dirname(__FILE__)));

include($root_dir.'/includefile.php');

global $adb;
$adb=PearDatabase::getInstance();
$current_user->id = $_REQUEST['userid'];
$input = $_REQUEST;
$static = $input['static'];

require $root_dir.'/modules/'.$static.'/static'.$static.'.class.php';
$static = 'static'.$static;
$method = $input['method'];
$focus = new $static();
if(method_exists($focus,$method)){
	$focus->$method($input);
}
echo '';die;
?>