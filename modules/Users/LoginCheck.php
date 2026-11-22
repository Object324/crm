<?php
//云之家网页端 跳转的域名 -传参获得
$corpurl = $_REQUEST['corpurl'];
$corpurl = empty($corpurl)?'':$corpurl;
/**
 * @author andy
 * @copyright 20140304
 */


if($_SESSION)
{

    if(!empty($corpurl))

    header("Location: ".$corpurl."index.php?module=Home&action=index&parenttab=My Home Page");
}
else
{
	$str_url=$_SERVER['HTTP_HOST']. $_SERVER['PHP_SELF'];
	$smarty->assign('CURRENCT_URL',$str_url);
	$smarty->assign('WEB_URL',oem_config::$web_url);
	$smarty->assign('TITLE',oem_config::$title);
	$smarty->assign('SUBJECT',oem_config::$subject);
	$smarty->assign('DESCRIPTION_ONE',oem_config::$decription1);
	$smarty->assign('HOT_LINE',oem_config::$hot_line);
    $_SESSION['sms_send_jsrand']=rand(1,999999);
    $smarty->assign("jsrand",$_SESSION['sms_send_jsrand']);
	if(strpos($_SERVER['SERVER_NAME'],'51mis.com') !==false ||strpos($_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'],'xiaoshou360.com/KH/zhuanye') !==false||strpos($_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'],'xiaoshou360.com/KH/lingdang') !==false||strpos($_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'],'xiaoshou360.com/KH/puyong/') !==false){
		$smarty->display('demoLoginCheck.tpl');
	}else{
		$smarty->display('SMSLoginCheck.tpl');
	}
}


?>