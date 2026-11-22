<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
global $entityDel;
global $display;
global $category;
global $mobileversion;
ob_start();
error_reporting(E_ALL^E_NOTICE^E_WARNING);

global $currentModule;
global $mobile_pagerecordcount;
$mobile_pagerecordcount=10;
 function stripslashes_checkstrings($value){
        if(is_string($value)){
                return stripslashes($value);
        }
        return $value;

 }
 if(get_magic_quotes_gpc() == 1){
        $_REQUEST = array_map("stripslashes_checkstrings", $_REQUEST);
        $_POST = array_map("stripslashes_checkstrings", $_POST);
        $_GET = array_map("stripslashes_checkstrings", $_GET);

}


// Allow for the session information to be passed via the URL for printing.
if(isset($_REQUEST['PHPSESSID']))
{
	session_id($_REQUEST['PHPSESSID']);
	//Setting the same session id to Forums as in CRM
        $sid=$_REQUEST['PHPSESSID'];
}
/*require_once('config.inc.php');
include($root_directory.'include/utils/globalStatic.php');
globalStatic::$root_directory=$root_directory;
*/
include('includefile.php');


function insert_charset_header()
{
 	global $app_strings, $default_charset;
 	$charset = $default_charset;
 	
 	if(isset($app_strings['LBL_CHARSET']))
 	{
 	        $charset = $app_strings['LBL_CHARSET'];
 	}
		header('Content-Type: text/html; charset='. $charset);
}
 	
insert_charset_header();
// Create or reestablish the current session
session_start();
$_SESSION['KCFINDER'] = array();
$_SESSION['KCFINDER']['disabled'] = false;
$_SESSION['KCFINDER']['uploadURL'] = "dataCache/test/upload";
$_SESSION['KCFINDER']['uploadDir'] = "../dataCache/test/upload";




global $adb, $lingdang_current_version;

$default_config_values = Array( "allow_exports"=>"all","upload_maxsize"=>"3000000", "listview_max_textlength" => "40", "php_max_execution_time" => "0");
	foreach ($default_config_values as $name=>$value)
	{
		if ( ! isset($GLOBALS[$name]) )
		{
			$GLOBALS[$name] = $value;
		}
	}
// Set the default timezone preferred by user
global $default_timezone;
if(isset($default_timezone) && function_exists('date_default_timezone_set')) {
	@date_default_timezone_set($default_timezone);
}

if(strtolower($_REQUEST['responseType'])=='htmlfive')//html5
{
    require_once("Register/RegOp.php");
    require_once('htmlIndex.php');
    exit();
}
include('lingdangversion.php');
if(isset($_REQUEST['appversion'])&&$_REQUEST['appversion']!=''){
    $mobileversion = $_REQUEST['appversion'];
    $dir = "mobileapi/".$mobileversion;
    if(!is_dir($dir)){
        //echo "当前目录下，目录".$dir."不存在";echo '<br>';
        if($mobileversion == '7.0.0'){
          $dir = "mobileapi/6.6.0";
          if(!is_dir($dir)){
            ConvertTojsonStringIndex(-1,array(),'服务器端程序版本较低，请升级服务器端程序！','');    
          }
          else{
            $mobileversion = '6.6.0';
          }
        }
        else{
          ConvertTojsonStringIndex(-1,array(),'服务器端程序版本较低，请升级服务器端程序！','');
        }
    }
}
else{
    $mobileversion = '2.1.0';
}

function ConvertTojsonStringIndex($code,$str,$msg,$obj='')
{
    $str['appname']='灵当软件';
    if(!is_array($obj))
    {
        $json_obj = array(
        'code' => $code,
        'result' => $str,
        'msg' => $msg
        );
    }
    else
    {
        $json_obj = array(
        'code' => $code,
        'result' => $str,
        'obj'=>$obj,
        'msg' => $msg
        );
    }
    $str=json_encode($json_obj);
    @ob_clean();
    @ob_start();
    @header('Content-type: text/html;charset=utf-8');
    if(isset($_REQUEST['diony']) && $_REQUEST['diony']!= ''){
        echo $str;//老版登陆使用这个 diony 2015-06-02
    }
    else{
        echo $_GET['jsoncallback'].'('.$str.')';//新版登陆使用这个 diony 2015-06-02
    }
    exit();
}

$_REQUEST['languageType']='zh';

//include('include/fields/fieldInfo.php');
//include('include/fields/Field.Class.php');
//include('modules/Users/Profile.class.php');

//include('data/CRMEntity.php');
//include('modules/CustomView/CustomView.php');
//include('include/utils/utils.php');
//include($root_directory.'/modules/Users/Users.php');
//include('include/language/zh_cn_version.lang.php');
//include('include/utils/CacheInfo.php');

include('mobileapi/'.$mobileversion.'/mobileinclude/CommonFun.php');
//include($root_directory.'include/utils/CommonUtils.php');
//include($root_directory.'include/Currency/Currency.class.php');
//include('include/ScopOfAuthority/ScopOfAuthority.php');

//从开始程序中的快捷方式直接进入注册页面
if(isset($_REQUEST['action'])&& $_REQUEST['action']=='isReg')
{

     include("Register/Register.php");
}
$NoRegister=0;
//如果没有注册，则进入注册页面
if(!isset($_SESSION["RegOp"])&&$_SESSION["RegOp"]!="RegOp")
{
        require_once("Register/RegOp.php");
        $reg=RegOp::getInstance();
    //判断注册文件是否存在
    $testFile=$reg->isExistFile();
    if($testFile==0)//不存在
    {
        /**
         * edit:can
         * date:20130703
         * reason:未注册版本允许登陆
         */
        require_once("VersionType.php");
        global $VersionNo;
        $NoRegister=1;

        $RegisterVersionNo=$VersionNo;
    }
    else if($testFile==1)//存在
    {


        $isCorrect= $reg->isCorrectFile();

          if($isCorrect!="1")
          {

              $errorContent=$isCorrect;
               include("Register/Register.php");
                exit();
          }
        $RegisterVersionNo=$reg->GetVersionNo();
    }
    else //异常
    {
        //echo $testFile;
    }
}
else
{
    require_once("Register/RegOp.php");
    $reg=RegOp::getInstance();
    $RegisterVersionNo=$reg->GetVersionNo();
  
}
$reg->__destruct();

global $currentModule;
$result = $adb->query("SELECT versiontype FROM ld_version");
$versiontype = $adb->query_result($result, 0, 'versiontype');
//修改版本类别和数据库，配置文件
 if($versiontype!=$RegisterVersionNo)
 {
    include('Version/VersionConvert.php');
    $versionconvert=new VersionConvert($RegisterVersionNo,$adb);
    $versionconvert->EditDataBase();
    $versiontype=$RegisterVersionNo;
   
 }  


  $VersionNo=$versiontype;

if(!isset($_SERVER['REQUEST_URI']))
{
	$_SERVER['REQUEST_URI'] = '';
}
//add by tifa 20130201 reason:when  export, the global $currentModule has no value
if(isset($_REQUEST['module'])&&$_REQUEST['module']!=''){
    $currentModule=$_REQUEST['module'];
}
else if(isset($module))
$currentModule=$module;
$action = '';

if(isset($_REQUEST['action']))
{
	$action = $_REQUEST['action'];
}



//Code added for 'Path Traversal/File Disclosure' security fix - Philip
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
     
         ConvertTojsonString('-1',array(),'模块名称丢失');
        
	}
	if(!$is_action)
	{
	 
         ConvertTojsonString('-1',array(),'操作信息丢失！') ;
       
	}
}


//Code added for 'Multiple SQL Injection Vulnerabilities & XSS issue' fixes - Philip
if(isset($_REQUEST['record']) && !is_numeric($_REQUEST['record']) && $_REQUEST['record']!='')
{
        
          ConvertTojsonString('-1',array(),'该记录编号无效！');
}

// Check to see if there is an authenticated user in the session.
$use_current_login = false;
if(isset($_REQUEST['userid']))
{
        $use_current_login = true;
}

// Prevent loading Login again if there is an authenticated user in the session.
if (isset($_SESSION["authenticated_user_id"]) && $module == 'Users' && $action == 'Login') {

    header("Location: index.php?action=$default_action&module=$default_module");

} 

 


// $log->debug($_REQUEST);
$skipHeaders=false;
$skipFooters=false;
$viewAttachment = false;
$skipSecurityCheck= false;

$currentModule = $module;
	
// for printing
$module = (isset($_REQUEST['module'])) ? ($_REQUEST['module']) : "";
$action = (isset($_REQUEST['action'])) ? ($_REQUEST['action']) : "";
$record = (isset($_REQUEST['record'])) ? ($_REQUEST['record']) : "";
$lang_crm = (isset($_SESSION['authenticated_user_language'])) ? $_SESSION['authenticated_user_language'] : "";
$GLOBALS['request_string'] = "&module=$module&action=$action&record=$record&lang_crm=$lang_crm";

$current_user = new Users();

if($use_current_login)
{

 	$result = $current_user->retrieveCurrentUserInfoFromFile($_REQUEST['userid']);
    if($result == null)
	{
        session_destroy();
	   ConvertTojsonString('-10',array(),'用户不存在');
	}
    $app_currency_strings = return_apps_currency_strings_language('zh');
}


$focus = "";

if($action == "DetailView")
{
	switch($currentModule)
	{
		case 'Webmails':
			//No need to create a webmail object here
			break;
        //gyqX160920 reason:仪表盘模块无需实例化模块类
		case 'Dashboard':
			break;
		default:
			$focus = CRMEntity::getInstance($currentModule);
			break;
		}
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
    ConvertTojsonString('-1',array(),getFixedLabel('NOPERMITTEDEXECUTE'));
} 

else if(!isset($_REQUEST['module'])&&!isset($_REQUEST['action']))
{
    include('mobileapi/'.$mobileversion.'/mobilemodules/Home/HomePage.php');
    exit();
}
else
{
	execDaysQuery();//editor:gyqX170619 	0028713: 需求讨论：建议手机端或者微信端登录的时候可以触发公海自动回收、自动提醒、自动任务等功能
    $currentModuleFile='mobileapi/'.$mobileversion.'/htmlmodules/'.$module.'/'.$action.'.php';
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
if((!$viewAttachment) && (!$viewAttachment && $action != 'home_rss') && $action != 'Tickerdetail' && $action != $Ajx_module."Ajax" && $action != "chat" && $action != "HeadLines" && $action != 'massdelete'  &&  $action != "DashboardAjax" && $action != "ActivityAjax")
{
	// Under the SPL you do not have the right to remove this copyright statement.	
	$copyrightstatement="<style>
		.bggray
		{
			background-color: #dfdfdf;
		}
	.bgwhite
	{
		background-color: #FFFFFF;
	}
	.copy
	{
		font-size:9px;
		font-family: Verdana, Arial, Helvetica, Sans-serif;
	}
	</style>
		<script language=javascript>
		function LogOut(e)
		{
			var nav4 = window.Event ? true : false;
			var iX,iY;
			if (nav4)
			{
				iX = e.pageX;
				iY = e.pageY;
			}
			else
			{
				iX = event.clientX + document.body.scrollLeft;
				iY = event.clientY + document.body.scrollTop;

			}
			if (iX <= 30 && iY < 0 )
			{
				w=window.open(\"index.php?action=Logout&module=Users\");
				w.close();
			}
		}
	//window.onunload=LogOut
	</script>
		";

	if((!$skipFooters) && $action != "about_us" && $action != "vtchat" && $action != "ChangePassword" && $action != "body" && $action != $module."Ajax" && $action!='Popup' && $action != 'ImportStep3' && $action != 'ActivityAjax' && $action != 'getListOfRecords')
	
	{
		echo $copyrightstatement;
		// Status tracking
		$statimage = '';
		if($currentModule == 'Users' && empty($current_user->id)) {
			global $disable_stats_tracking;
			if(isset($disable_stats_tracking) && !empty($disable_stats_tracking)) {
				$statimage = "";
			} else {
				$statimage = "<img src='http://stats.lingdang.com/stats.php?uid=$application_unique_key&v=$lingdang_current_version&type=U' 
				alt='|' title='' border=0 width='1px' height='1px'>";
			}
		}
		// END
		echo "<div class='Footer'><div>";
        echo $versions[$VersionNo]['lblversion']."<br />";
        if($reg->isExistFile()==1&&$action!='LoginCheck')
        {
            echo  getFixedLabel('AUTHORIZEDIN')."：";
            echo $reg->softCompany();
            echo getFixedLabel('LICENSEDUSER')."：";
            echo $reg->GetUserCount();
            echo '  '.getFixedLabel('AUTHENTYPE').'：'.$reg->softGetTypeLabel();
        }
        if($HELP_SALES_HOT_PHONE!=''&&$HELP_SERVICE_HOT_PHONE!='')
        {
            //$HELPDESK_SUPPORT_ContactInfo = iconv("gbk", "utf-8", $HELPDESK_SUPPORT_ContactInfo);
            echo '<br>'. getFixedLabel('SALESHOTLINE').":".$HELP_SALES_HOT_PHONE.'  '.getFixedLabel('SERVICEHOTLINE').':'.$HELP_SERVICE_HOT_PHONE;
        }
        echo "</div>";
        
		
        
	}
	if(($action != 'mytkt_rss') && ($action != 'home_rss') && ($action != $module."Ajax") && ($action != "body") && ($action != 'ActivityAjax'))
	{
	?>
		<script type="text/javascript">
			var userDateFormat = "<?php echo $current_user->date_format ?>";
			var default_charset = "<?php echo $default_charset; ?>";
			var userCurrencySeparator = "<?php if(isset($current_user->currency_grouping_separator)
													&& $current_user->currency_grouping_separator == '') {
													echo ' ';
												} else {
													echo html_entity_decode($current_user->currency_grouping_separator, ENT_QUOTES, $default_charset);
												}
										?>";
			var userDecimalSeparator = "<?php if(isset($current_user->currency_decimal_separator)
													&& $current_user->currency_decimal_separator == '') {
													echo ' ';
												} else {
													echo html_entity_decode($current_user->currency_decimal_separator, ENT_QUOTES, $default_charset);
												}
										?>";
		</script>
<?php
	}
	// ActivityReminder Customization for callback

	// End
	echo "</table></div>";
	if((!$skipFooters) && ($action != "body") && ($action != $module."Ajax") && ($action != "ActivityAjax"))
		include('modules/lingdang/footer.php');
}
ob_end_flush();


function return_apps_currency_strings_language($language) {

	global $app_currency_strings, $default_language, $translation_string_prefix,$current_user;

	$temp_app_currency_strings = $app_currency_strings;
    //require('user_privileges/user_language_'.$current_user->id.'.php');
   
        $language='zh_cn';
        
  
    //$default_language=$language;
	@include("include/language/$language.lang.php");
	if(!isset($app_currency_strings))
	{
	
		require("include/language/$language.lang.php");
		$language_used = $default_language;
	}
	if(!isset($app_currency_strings))
	{
	
		return null;
	}
	$return_value = $app_currency_strings;

	// Restore the value back
	$app_currency_strings = $temp_app_currency_strings;

	//$log->debug("Exiting return_app_currency_strings_language method ...");
	return $return_value;
}

function return_apps_list_strings_language($language)
{
	//global $log;
	//$log->debug("Entering return_app_list_strings_language(".$language.") method ...");
	global $app_list_strings, $default_language, $translation_string_prefix,$current_user;
	$temp_app_list_strings = $app_list_strings;
	$language_used = $language;
 /* require('user_privileges/user_language_'.$current_user->id.'.php');
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
	if(!isset($app_list_strings))
	{
		//$log->warn("Unable to find the application language file for language: ".$language);
		require("include/language/$default_language.lang.php");
		$language_used = $default_language;
	}

	if(!isset($app_list_strings))
	{

		return null;
	}


	$return_value = $app_list_strings;
	$app_list_strings = $temp_app_list_strings;

	//$log->debug("Exiting return_app_list_strings_language method ...");
	return $return_value;
}

function return_modules_language($language, $module)
{
//	global $log;
//	$log->debug("Entering return_module_language(".$language.",". $module.") method ...");
	global $mod_strings, $default_language, $currentModule, $translation_string_prefix,$current_user;
	static $cachedModuleStrings = array();

	if(!empty($cachedModuleStrings[$module])) {
	//	$log->debug("Exiting return_module_language method ...");
		return $cachedModuleStrings[$module];
	}

	$temp_mod_strings = $mod_strings;
	$language_used = $language;
    /*require('user_privileges/user_language_'.$current_user->id.'.php');
    if($languageType=='zh')
    {
        $language='zh_cn';
        
    }
    else
    {
        $language='en_us';
    }
    $default_language=$language;*/
    
    @include("modules/".$module."/language/".$language.".lang.php");
   
	if(!isset($mod_strings))
	{
	  
	
		if($default_language == 'en_us') {
			require("modules/$module/language/$default_language.lang.php");
			$language_used = $default_language;
		} else {
			@include("modules/$module/language/$default_language.lang.php");
			if(!isset($mod_strings)) {
			
				require("modules/$module/language/en_us.lang.php");
				$language_used = 'en_us';
			} else {
				$language_used = $default_language;
			}
		}
	}
    
	if(!isset($mod_strings))
	{
		return null;
	}
	if($translation_string_prefix)
	{
		foreach($mod_strings as $entry_key=>$entry_value)
		{
			$mod_strings[$entry_key] = $language_used.' '.$entry_value;
		}
	}

    $return_value = $mod_strings;
	$mod_strings = $temp_mod_strings;

	//$log->debug("Exiting return_module_language method ...");
	$cachedModuleStrings[$module] = $return_value;    
	return $return_value;
}

/**
 * Check if module is set active (or enabled)
 */
function vtlib_isModuleActives($module) {
	global $adb, $__cache_module_activeinfo;

	if(in_array($module, vtlib_moduleAlwaysActives())){
		return true;
	}

	if(!isset($__cache_module_activeinfo[$module])) {
		include 'dataCache/tabdatas/tabdata.php';
		$presence = isset($tab_info_array[$module])? 0: 1;
		$__cache_module_activeinfo[$module] = $presence;
	} else {
		$presence = $__cache_module_activeinfo[$module];
	}

	$active = false;
	if($presence != 1) $active = true;

	return $active;
}

/**
 * 更新操作
 * edit：cui
 * data：2014-3-17
 * reson：应收款统计表链接是否显示
**/
function vtlib_isCircumstances($type){
    global $adb;
	$resultant_array = Array();

	$query = "select * from ld_specialcircumstances where special_type=?";

	$result = $adb->pquery($query, array($type));
	
	return $adb->query_result($result, 0, 'special_value'); 
}

function vtlib_moduleAlwaysActives() {
	$modules = Array (
		'Administration', 'CustomView', 'Settings', 'Users', 'Migration',
		'Utilities', 'uploads', 'Import', 'System', 'com_lingdang_workflow', 'PickList',
		'Ondemand','Approve'
	);
	return $modules;
}

function getParentTabFromModules($module) {
//	global $log;
	//$log->debug("Entering getParentTabFromModule(" . $module . ") method ...");
	
	if (file_exists('dataCache/tabdatas/tabdata.php') && (filesize('dataCache/tabdatas/tabdata.php') != 0) && file_exists('dataCache/tabdatas/parent_tabdata.php') && (filesize('dataCache/tabdatas/parent_tabdata.php') != 0)) {
		include('dataCache/tabdatas/tabdata.php');
		include('dataCache/tabdatas/parent_tabdata.php');
		$tabid = $tab_info_array[$module];
		foreach ($parent_child_tab_rel_array as $parid => $childArr) {
			if (in_array($tabid, $childArr)) {
				$parent_tabname = $parent_tab_info_array[$parid];
				break;
			}
		}
	//	$log->debug("Exiting getParentTabFromModule method ...");
		return $parent_tabname;
	} else {
	   global $adb;
		$sql = "select ld_parenttab.* from ld_parenttab inner join ld_parenttabrel on ld_parenttabrel.parenttabid=ld_parenttab.parenttabid inner join ld_tab on ld_tab.tabid=ld_parenttabrel.tabid where ld_tab.name=?";        
		$result = $adb->pquery($sql, array($module));
		$tab = $adb->query_result($result, 0, "parenttab_label");
		//$log->debug("Exiting getParentTabFromModule method ...");
		return $tab;
	}
}