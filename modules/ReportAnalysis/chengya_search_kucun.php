<?php
global $adb,$theme,$current_user;
//删除tmp下的tmp缓存你文件
$root_directory = explode('www',globalStatic::$root_directory);
$handle = opendir($root_directory[0].'/tmp');
while(($file = readdir($handle)) != false){
	if($file != '.' && $file != '..'){
		if(strpos($file,'.tmp') !== false){ 
			unlink($root_directory[0].'/tmp/'.$file);
		}
	}
}
$smarty=new lingdangCRM_Smarty();
$is_ajax = $_REQUEST['is_ajax'];
$_REQUEST['diony']='yes';
require_once globalStatic::$root_directory.'modules/Home/CustomMade/ChengYaUtils.php';
$chengyaObj = new ChengYaUtils();
$list = $chengyaObj->getList();

$smarty->assign('LISTENTITY',$list);
$kuandu = ceil(($_SESSION['bodywidth']-30)/10);
$header[] = array('label' => '物料编码','width' => $kuandu);
$header[] = array('label' => '物料名称','width' => $kuandu);
$header[] = array('label' => '规格型号','width' => $kuandu*2);
$header[] = array('label' => '库存量（主单位）','width' => $kuandu);
$header[] = array('label' => '可用量（主单位）','width' => $kuandu);
$header[] = array('label' => '库存状态','width' => $kuandu);
$header[] = array('label' => '仓库名称','width' => $kuandu);
$header[] = array('label' => '库存组织','width' => $kuandu*2);

$width = 0;
foreach($header as $arr){
    $width += $arr['width'];
}
$smarty->assign('HEADER',$header);
$smarty->assign('WIDTH',$width);
$smarty->assign('CURRENT_USER_ID',$current_user->id);
$_REQUEST['diony'] = 'yes';

if($is_ajax == "yes"){
    $smarty->display('chengya/search_content.tpl');
}else{
    $smarty->assign('list',$list);
    $smarty->display('chengya/search.tpl');
}

