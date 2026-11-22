<?php
/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2016/11/28 0028
 * Time: 下午 3:45
 */
$actionname = $_REQUEST['action'];
if(empty($_REQUEST['action'])){
    $actionname = 'ListView';
}
if($actionname == 'EditView' || $actionname == 'CreateView' || $actionname == 'DetailView'){
    include(globalStatic::$root_directory . 'WeiXinApp/modules/'.$currentModule.'/DetailView.php');
}else{
    include(globalStatic::$root_directory . 'WeiXinApp/modules/'.$currentModule.'/'.$actionname.'.php');
}
?>