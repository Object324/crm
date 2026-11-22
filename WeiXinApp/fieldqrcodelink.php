<?php
//链接码 扫描链接码跳转链接时 显示的内容
error_reporting(E_ALL^E_NOTICE^E_WARNING);
header('Content-Type:text/html;charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Origin, No-Cache, X-Requested-With, If-Modified-Since, Pragma, Last-Modified, Cache-Control, Expires, Content-Type, X-E4M-With");

$root_dir=dirname(dirname(__FILE__));//获取根目录
include($root_dir.'/includefile.php');
// require_once($root_dir.'/include/Zend/Json.php');
//include (globalStatic::$root_directory.'./appCommon/appCommon.php');
include (globalStatic::$root_directory.'./Smarty_setup.php');
global $adb;
$_REQUEST['weixin_pdf'] = 'yes';//生成html的方法里面有这个参数的判断 来显示图片文件
$module = $_REQUEST['module'];
$fieldid = $_REQUEST['fieldid'];
$uitype = $_REQUEST['uitype'];
$recordid = $_REQUEST['recordid'];
$tabid = getTabid($module);
$_REQUEST['diony']='diony';
require_once(globalStatic::$root_directory.'include/TemplatePrint/TemplatePrint.php');
$template=new TemplatePrint($module,$tabid,$fieldid,$recordid,$adb,0,'yes');
$pdfhtml = $template->createPrintHtml();

$domain = $_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['HTTP_HOST'].$_SERVER['PHP_SELF'];
$domain = explode('WeiXinApp',$domain);
$domain = $domain[0];
$pdfhtml = str_replace('storage/',$domain.'storage/',$pdfhtml);
$smarty = new lingdangCRM_Smarty();
$smarty->assign("Content",htmlspecialchars_decode(trim($pdfhtml))) ;
$smarty->display("fieldqrcodelink.tpl");
