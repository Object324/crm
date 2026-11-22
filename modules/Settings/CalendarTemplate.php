<?php
/* creator:gyq_13 reason: */
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='CalendarTemplate';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
    require_once(globalStatic::$root_directory.'modules/Calendar/TemplateCalendar/TemplateCalendar.php');
?>