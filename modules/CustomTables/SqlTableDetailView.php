<?php
require_once(globalStatic::$root_directory."include/simple_html_dom.php");
require_once(globalStatic::$root_directory."appCommon/appCommon.php");

$function = $_REQUEST['function_name'];
$function = empty($function)?'index':$function;

$class_name = $_REQUEST['class_name'];
$class_name = empty($class_name)?'cls_SqlTableDetailView':$class_name;
$_REQUEST['diony'] = 'yes';
crm_load_class_file($class_name,'modules/CustomTables/');

$obj = new $class_name($_REQUEST);
$is_ajax = $_REQUEST['is_ajax'];
$obj->$function($is_ajax);


?>