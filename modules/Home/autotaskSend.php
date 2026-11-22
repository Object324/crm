<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @project PROT145 自动任务
 * @author Tujt 2015-01-14

 error_reporting(E_ALL^E_NOTICE^E_WARNING);
 chdir('./../../');
$auto_root_directory= dirname(dirname(dirname(__FILE__))).'/';

require_once($auto_root_directory.'includefile.php');

require_once $auto_root_directory.'modules/Settings/AutoTaskController.class.php';
global $current_user;
$current_user->id = (int)$_REQUEST['userid'];
$autoquery = new AutoTaskController();
if(isset($_REQUEST['fld_tabid']) && $_REQUEST['record'] > 0){//手动执行
	$fld_module = getTabname($_REQUEST['fld_tabid']);
     
	$autoquery->SendAutoTask($fld_module,$_REQUEST['record']);
}else{//自动执行
	$autoquery->AllSendAutoTask();
}
 *  */
?>