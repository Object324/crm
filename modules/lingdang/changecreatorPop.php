<?php
//wyt 220929 BUG0057319 客户-更改创建人-弹出来的数据范围没受权限控制
$fld_module = isset($_REQUEST['popup_module'])?$_REQUEST['popup_module']:'yes';//模块
$focus=CRMEntity::getInstance($fld_module);
$fld_fieldname=$focus->getCreateColumnName();
$_REQUEST['fieldname']=$fld_fieldname;
include(globalStatic::$root_directory.'modules/Users/viewuserinfo.php');


?>