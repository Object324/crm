<?php
$actionname = $_REQUEST['action'];

include(globalStatic::$root_directory . 'WeiXinApp/modules/'.$currentModule.'/'.$actionname.'.php');
?>