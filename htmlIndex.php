<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);
include('Smarty_setup.php');

$is_module = true;
$is_action = true;
if(isset($_REQUEST['module']))
{
    $module = $_REQUEST['module'];
	$dir = @scandir($root_directory."modules");
	$temp_arr = Array("CVS","Attic");
	$res_arr = @array_intersect($dir,$temp_arr);
	if(count($res_arr) == 0  && !preg_match("/[\/.]/",$module)) {
		if(@in_array($module,$dir))
			$is_module = true;
	}
	$in_dir = @scandir($root_directory."modules/".$module);
	$res_arr = @array_intersect($in_dir,$temp_arr);
	if(count($res_arr) == 0 && !preg_match("/[\/.]/",$module)) {
		if(@in_array($action.".php",$in_dir))
			$is_action = true;
	}	
	if(!$is_module)
	{
     
         die('模块名称丢失');
        
	}
	if(!$is_action)
	{
	 
        die('操作信息丢失！') ;
       
	}
}

$appversion = '2.1.0';
if(isset($_REQUEST['appversion']) && $_REQUEST['appversion']!=''){
	$appversion = $_REQUEST['appversion'];
  $dir = "mobileapi/".$appversion;
  if(!is_dir($dir)){
    if($appversion == '7.0.0'){
      $appversion = '6.6.0';
    }
  }
}
$mobileversion = $appversion;

//Code added for 'Multiple SQL Injection Vulnerabilities & XSS issue' fixes - Philip
if(isset($_REQUEST['record']) && !is_numeric($_REQUEST['record']) && $_REQUEST['record']!='')
{
        
          die('该记录编号无效！');
}
if($_REQUEST['userid'])
{
    
    $_SESSION['authenticated_user_id']=$_REQUEST['userid'];
    $_SESSION['app_unique_key'] = $application_unique_key;
}

$module = (isset($_REQUEST['module'])) ? ($_REQUEST['module']) : "";
$action = (isset($_REQUEST['action'])) ? ($_REQUEST['action']) : "";
$record = (isset($_REQUEST['record'])) ? ($_REQUEST['record']) : "";

if(!isset($_REQUEST['ajax'])&&$_REQUEST['ajax']!='yes')
{
     $currentModuleFile='mobileapi/'.$appversion.'/htmlmodules/'.$module.'/'.$action.'.php';
	 include($currentModuleFile);
     exit();
}
require_once($root_directory.'include/utils/globalStatic.php');
globalStatic::$root_directory=$root_directory;
require_once('include/fields/fieldInfo.php');
require_once('include/fields/Field.Class.php');
require_once('modules/Users/Profile.class.php');
require_once('data/CRMEntity.php');
require_once('include/utils/utils.php');
require_once($root_directory.'/modules/Users/Users.php');
require_once('include/utils/CacheInfo.php');
require_once('mobileapi/'.$appversion.'/mobileinclude/CommonFun.php');
require_once('modules/CustomView/CustomView.php');
require_once($root_directory.'include/utils/CommonUtils.php');
require_once($root_directory.'include/Currency/Currency.class.php');
require_once('include/ScopOfAuthority/ScopOfAuthority.php');

if(file_exists($root_directory."dataCache/Login/zh_cn_version_new.lang.php")){
    require_once($root_directory."dataCache/Login/zh_cn_version_new.lang.php");
}else{
    require_once($root_directory."include/language/zh_cn_version.lang.php");
}

$skipHeaders=false;
$skipFooters=false;
$viewAttachment = false;
$skipSecurityCheck= false;

$currentModule = $module;


$lang_crm = (isset($_SESSION['authenticated_user_language'])) ? $_SESSION['authenticated_user_language'] : "";
$GLOBALS['request_string'] = "&module=$module&action=$action&record=$record&lang_crm=$lang_crm";
$use_current_login=true;
global $current_user,$PlatformMC;//gyq170706 reason:增加移动类型标识区分微信和app;
$current_user = new Users();
$PlatformMC['type'] = 'app';
$PlatformMC['userid'] = $_REQUEST['userid'];
$PlatformMC['mobileapp']='yes';
if($use_current_login)
{
   
 	$result = $current_user->retrieveCurrentUserInfoFromFile($_SESSION['authenticated_user_id']);
    //echo $_SESSION['authenticated_user_id'];
    if($result == null)
	{
        session_destroy();
	    die('用户不存在');
	}
  
    
    $app_currency_strings = return_apps_currency_strings_language('zh');
	  
	$app_strings = return_applications_language('zh');
  
    $app_list_strings = return_apps_list_strings_language('zh');
      
  //  $mod_strings = return_modules_language('zh', $currentModule);
}

if(!$skipHeaders) {
  
	if($use_current_login)
	{
	
         
		

	}
	
	if(isset($_SESSION['administrator_error']))
	{
	
		if(is_admin($current_user)) 
			echo $_SESSION['administrator_error'];
		unset($_SESSION['administrator_error']);
	}
	
	//echo "<!-- startscrmprint -->";
}
 

if(!$skipSecurityCheck && $use_current_login)
{


    //require_once('include/utils/UserInfoUtil.php');
	if(preg_match('/Ajax/',$action)) {
		if($_REQUEST['ajxaction'] == 'LOADRELATEDLIST'){
			$now_action = 'DetailView';
		} else {
			$now_action=($_REQUEST['file']);
		}
	} else {
		$now_action=$action;
	}
    
}

if($_REQUEST['announce_save']&&$_REQUEST['announce_save']=='yes')
{
    $display='yes';
}
$display='yes';
if($display == "no")
{
    die(getFixedLabel('NOPERMITTEDEXECUTE'));
} 

else
{
	//gyq_23 提醒优化 date:20170221    gyq_31
	include(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');
	$corpindex = file_get_contents(globalStatic::$root_directory . 'dataCache/weixin/weixinapp_corpindex.php');
	if (!empty($corpindex) && $corpindex != -5) {
		crm_load_class_file('cls_remindsWX', 'WeiXinApp/modules/Reminds');
		$remind = new cls_remindsWX();
		$remind->time_interval();
	}
	$currentModuleFile='mobileapi/'.$appversion.'/htmlmodules/'.$module.'/'.$action.'.php';
    include($currentModuleFile);
    unset($adb);
}

	if((!$viewAttachment) && (!$viewAttachment && $action != 'home_rss' && $action != $module."Ajax" && $action != "chat" && $action != 'massdelete' && $action != "body") )
	{
		echo "<!-- stopscrmprint -->";
	}
//added to get the theme . This is a bad fix as we need to know where the problem lies yet
if(isset($_SESSION['lingdang_authenticated_user_theme']) && $_SESSION['lingdang_authenticated_user_theme'] != '')
{
        $theme = $_SESSION['lingdang_authenticated_user_theme'];
}
else
{
        $theme = $default_theme;
}
$Ajx_module= $module;
if($module == 'Events')
	$Ajx_module = 'Calendar';

ob_end_flush();

function return_applications_language($language)
{
//	global $log;
	//$log->debug("Entering return_application_language(".$language.") method ...");
	global $app_strings, $default_language, $translation_string_prefix,$current_user;
	$temp_app_strings = $app_strings;
	$language_used = $language;

/*	require('user_privileges/user_language_'.$current_user->id.'.php');
    if($languageType=='zh')
    {
        $language='zh_cn';
        
    }
    else
    {
        $language='en_us';
    }
    $default_language=$language;*/
	@include("include/language/$language.lang.php");
   
	if(!isset($app_strings))
	{
		//$log->warn("Unable to find the application language file for language: ".$language);
		require("include/language/$default_language.lang.php");
		$language_used = $default_language;
	}

	if(!isset($app_strings))
	{
		//$log->fatal("Unable to load the application language file for the selected language($language) or the default language($default_language)");
		//$log->debug("Exiting return_application_language method ...");
		return null;
	}

	// If we are in debug mode for translating, turn on the prefix now!
	if($translation_string_prefix)
	{
		foreach($app_strings as $entry_key=>$entry_value)
		{
		  if(array_key_exists($entry_key,$tab_string))
          {
            	$app_strings[$entry_key]=$tab_string[$entry_key];
          }
          else
          {
                $app_strings[$entry_key]= $language_used.' '.$entry_value;
          }
		 	
		}
	}
 //$temp_mod_strings[$str]=($tab_string[$str]!='')?$tab_string[$str]:$temp_mod_strings[$str];
	
	$return_value = $app_strings;
	$app_strings = $temp_app_strings;

	//$log->debug("Exiting return_application_language method ...");
	return $return_value;
}


?>