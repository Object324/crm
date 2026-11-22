<?php

$actionname = $_REQUEST['action'];
if($actionname == $currentModule.'Ajax'){
    $file = $_REQUEST['file'];
    include(globalStatic::$root_directory . 'WeiXinApp/modules/'.$currentModule.'/'.$file.'.php');
}else{
    //gyq_117 reason:企业微信增加个人资料及修改密码  2019/5/31 15:03 
    if($actionname == 'EditView'  || $actionname == 'DetailView'){
        include(globalStatic::$root_directory . 'WeiXinApp/modules/'.$currentModule.'/DetailView.php');
    }else{
        include(globalStatic::$root_directory . 'WeiXinApp/modules/'.$currentModule.'/'.$actionname.'.php');
    }
}
