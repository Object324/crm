<?php
global $default_charset,$adb,$current_user;
//$smarty = new lingdangCRM_Smarty;
$corpurl = $_REQUEST['corpurl'];
$filename = $_REQUEST['filename'];
$title = $_REQUEST['title'];
$token=$_REQUEST['token'];

global $global_js_url;
if($global_js_url){
    global $lingdang_cdn_version;
    $tmpglobal_js_url = $global_js_url.$lingdang_cdn_version.'/';
}else{
    $tmpglobal_js_url = $corpurl;
}
$smarty = new lingdangCRM_Smarty();
$smarty->assign("token",$token);

$smarty->assign('title',$title);
$smarty->assign('JSURL', $tmpglobal_js_url);
$smarty->assign('fileallpath', $filename);
$smarty->display('pdfView/pdfh5.tpl');