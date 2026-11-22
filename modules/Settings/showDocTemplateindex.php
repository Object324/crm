<?php
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='showDocTemplateindex';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
include(globalStatic::$root_directory.'modules/Documents/showindex.php');


?>