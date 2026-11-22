<?php

$root_dir=dirname(dirname(__FILE__));//获取根目录
define("ROOT_DIR",$root_dir);
include($root_dir.'/includefile.php');

$AddModule=$_GET['module'];
$ParentTab=$_GET['parenttab'];

$mulu = ''; //获取主目录名称，下面判断时为了区分linux和windows系统
if(strrpos($root_dir,'\\')==""){
    $mulu =strrpos($root_dir,'/')+1;
}else{
    $mulu =strrpos($root_dir,'\\')+1;
}
$dizhi =substr($root_dir,$mulu);

if(!empty($AddModule)){
	 $url= 'http://'.$_SERVER['HTTP_HOST'].'/'.$dizhi.'/index.php?module='.$AddModule.'&action=index&parenttab='.$ParentTab;
}

header("Location: $url");

?>