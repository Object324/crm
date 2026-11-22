<?php
global $default_charset,$adb,$current_user;
//$smarty = new lingdangCRM_Smarty;
$corpurl = $_REQUEST['corpurl'];
$filename = $_REQUEST['filename'];
$parsed_url = parse_url($filename);
parse_str($parsed_url['query'], $query_params);
$file_url = $query_params['url'];
$title = $_REQUEST['title'];
global $global_js_url;
if($global_js_url){
    global $lingdang_cdn_version;
    $tmpglobal_js_url = $global_js_url.$lingdang_cdn_version.'/';
}else{
    $tmpglobal_js_url = $corpurl;
}
$smarty = new lingdangCRM_Smarty();
$smarty->assign('title',$title);
$smarty->assign('JSURL', $tmpglobal_js_url);
$smarty->assign('FILE_URL', $file_url);
$smarty->assign('BASE_URL', curPageURL());
$smarty->display('Preview_OFD.tpl');