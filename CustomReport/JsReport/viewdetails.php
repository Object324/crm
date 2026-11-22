<?php
$root_dir=dirname(dirname(dirname(__FILE__)));//获取根目录
define("ROOT_DIR",$root_dir);
include($root_dir.'/includefile.php');
global $adb;
$record=$_GET['id'];

$sql = 'select setype from ld_crmentity where crmid=? LIMIT 0,1;';

$result = $adb->pquery($sql,array($record));
$nums=$adb->num_rows($result);


if($nums > 0){
    $currentModule=$adb->query_result($result,0,0);
}else{
    $sql2 = 'select 1 from ld_users where id=? ;';
    $result2 = $adb->pquery($sql2,array($record));
    $nums_two=$adb->num_rows($result2);
    if($nums_two > 0){
        $currentModule ='Users';
    }
}


$dizhi=substr($_SERVER['PHP_SELF'],0,strpos($_SERVER['PHP_SELF'],'CustomReport'));

//zxm BUG0054672	2022-0804 报表库，销售提成表——按收款统计，源单的超链接打开错误
if(!empty($currentModule)){
    if($currentModule=='Calendar'){
        $url= $_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['HTTP_HOST'].$dizhi.'index.php?pageto_action=index&pageto_module='.$currentModule.'&pageto_record='.$record.'&activity_mode=Events';
    }elseif($currentModule == ''){
        $url= $_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['HTTP_HOST'].$dizhi.'index.php?pageto_module='.$currentModule.'&pageto_action=index&pageto_record='.$record.'&modechk=prefview';
    }else{
        $url= $_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['HTTP_HOST'].$dizhi.'index.php?pageto_module='.$currentModule.'&pageto_action=index&pageto_record='.$record;
    }
}

header("Location: $url");

?>