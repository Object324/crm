<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);
header('Access-Control-Allow-Origin: *');
$root_dir = dirname(__FILE__);
if (substr(PHP_OS, 0, 3) == 'WIN') {
    $root_dir = str_replace('\\','/', $root_dir);
}
include($root_dir.'/includefile.php');
require_once("Register/cls_wxSelfbuiltApplicationLogin.php");



?>
