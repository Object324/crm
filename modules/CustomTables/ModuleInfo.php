<?php
$function = $_REQUEST['function_name'];
$function = empty($function)?'index':$function;
$_REQUEST['diony'] = 'yes';
include_once globalStatic::$root_directory . 'modules/CustomTables/cls_ModuleInfo.php';
$obj = new cls_ModuleInfo($_REQUEST);
$res = $obj->$function();
ConvertTojsonString(1,$res,'success');die;
