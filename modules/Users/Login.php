<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
  * The contents of this file are subject to the lingdang CRM Public License Version 1.0
  * ("License"); You may not use this file except in compliance with the License
  * The Original Code is:  lingdang CRM Open Source
  * The Initial Developer of the Original Code is lingdang.
  * Portions created by lingdang are Copyright (C) lingdang.
  * All Rights Reserved.
  *********************************************************************************/

//we don't want the parent module's string file, but rather the string file specifc to this subpanel
global $current_languageIN_SECURITY_CODE,$global_iskehu001,$adb;

/**
*@author:andy
*@data:
*@reason:手机短信验证登陆 安全中心 ‘重新登陆’操作，清空SESSION
*@version:|
*/
//if(isset($_REQUEST['unsetsession']) && $_REQUEST['unsetsession']=='true')
if($_SESSION['USERPMLogin']=='yes'||(isset($_REQUEST['unsetsession']) && $_REQUEST['unsetsession']=='true'))
    session_destroy(); 

define("IN_LOGIN", true);
if(!function_exists('createCachefolder'))
{
    //预先准备缓存文件夹
    function createCachefolder(){
        @mkdir(globalStatic::$root_directory.'dataCache/tabdatas',0777);
        chmod(globalStatic::$root_directory.'dataCache/tabdatas', 0777);
        @mkdir(globalStatic::$root_directory.'dataCache/Login',0777);
        chmod(globalStatic::$root_directory.'dataCache/Login', 0777);
        @mkdir(globalStatic::$root_directory.'dataCache/execDays',0777);
        chmod(globalStatic::$root_directory.'dataCache/execDays', 0777);
        @mkdir(globalStatic::$root_directory.'dataCache/sqlhandlers',0777);
        chmod(globalStatic::$root_directory.'dataCache/sqlhandlers', 0777);
        @mkdir(globalStatic::$root_directory.'dataCache/test',0777);
    	chmod(globalStatic::$root_directory.'dataCache/test', 0777);
        @mkdir(globalStatic::$root_directory.'dataCache/test/logo',0777);
    	chmod(globalStatic::$root_directory.'dataCache/test/logo', 0777);
        @mkdir(globalStatic::$root_directory.'dataCache/test/vtlib',0777);
    	chmod(globalStatic::$root_directory.'dataCache/test/vtlib', 0777);
        @mkdir(globalStatic::$root_directory.'dataCache/test/vtlib/HTML',0777);
    	chmod(globalStatic::$root_directory.'dataCache/test/vtlib/HTML', 0777);
        @mkdir(globalStatic::$root_directory.'dataCache/pdf',0777);
    	chmod(globalStatic::$root_directory.'dataCache/pdf', 0777);
        @mkdir(globalStatic::$root_directory.'dataCache/pdf/tmp',0777);
    	chmod(globalStatic::$root_directory.'dataCache/pdf/tmp', 0777);
         $dir = opendir(globalStatic::$root_directory.'dataCache/mpdf/tmp'); 
         $ml = 0; 
        $cs=0;
        while ($dir&&($file = readdir($dir)) !== false) 
        {     
            
            if(is_dir($file))
                continue;
           
            $cs = $ml++; 
            if(intval($cs) ==2){
                break;
            } 
          } 
          closedir($dir); 
         
          if(empty($cs)){
            
            @rmdir(globalStatic::$root_directory.'dataCache/mpdf/tmp');
            @rmdir(globalStatic::$root_directory.'dataCache/mpdf');
          }
          
        @mkdir(globalStatic::$root_directory.'dataCache/mpdf',0777);
    	chmod(globalStatic::$root_directory.'dataCache/mpdf', 0777);
        @mkdir(globalStatic::$root_directory.'dataCache/mpdf/tmp',0777);
    	chmod(globalStatic::$root_directory.'dataCache/mpdf/tmp', 0777);
        //转移LoginSettingsInfo.php到dataCache/Login目录下
        if(file_exists(globalStatic::$root_directory.'LoginSettingsInfo.php')&&!file_exists(globalStatic::$root_directory.'dataCache/Login/LoginSettingsInfo.php')){
            //转移文件时修改网页封面的路径
            $content =file_get_contents(globalStatic::$root_directory.'LoginSettingsInfo.php');
            if(!strpos($content,'dataCache/test/logo') && strpos($content,'test/logo')>=0){
                $content = str_replace('test/logo','dataCache/test/logo',$content);
            }
            file_put_contents(globalStatic::$root_directory.'dataCache/Login/LoginSettingsInfo.php',$content);
        }
        //转移test路径下的文件,用于登录界面显示
        $old2new_foldername = array(globalStatic::$root_directory.'test/logo/'=>globalStatic::$root_directory.'dataCache/test/logo/',
                                    globalStatic::$root_directory.'test/vtlib/'=>globalStatic::$root_directory.'dataCache/test/vtlib/',
                                    globalStatic::$root_directory.'test/vtlib/HTML/'=>globalStatic::$root_directory.'dataCache/test/vtlib/HTML/'
                                    );
        //客户可以修改的图片,可能会出现客户图片名称与现有的重复的情况,以旧图片为准
        $special_filename_arr = array('logo.png','logo_mini_1.png');
        foreach($old2new_foldername as $pre_folder=>$post_folder){
            $folder = @opendir($pre_folder);
        	if ($folder == false) continue;
        	while(false !== ($file = readdir($folder))){
                if(is_dir($pre_folder.$file))continue;
        		if(file_exists($pre_folder.$file)&&(!file_exists($post_folder.$file)||in_array($file,$special_filename_arr))){
                    file_put_contents($post_folder.$file,file_get_contents($pre_folder.$file));
                }
        	}
            closedir($folder);
        }
    }
}
//edit:duan 预先新建文件夹
 createCachefolder();


if(!file_exists(globalStatic::$root_directory."dataCache/Login/LoginSettingsInfo.php"))
{
    file_put_contents(globalStatic::$root_directory.'dataCache/Login/LoginSettingsInfo.php',file_get_contents(globalStatic::$root_directory."LoginSettingsInfo_default.php"));
}

require_once(globalStatic::$root_directory.'dataCache/Login/LoginSettingsInfo.php');

require_once(globalStatic::$root_directory.'Smarty_setup.php');

require_once(globalStatic::$root_directory. 'Register/softInfo.php');

//require_once('Register/RegOp.php');

require_once(globalStatic::$root_directory. "appCommon/appCommon.php");
if($global_iskehu001=='no')
{
    if(file_exists(globalStatic::$root_directory. 'user_privileges/oem_config.php'))
    {
        require_once(globalStatic::$root_directory. 'user_privileges/oem_config.php');
        $LOGIN_SECURITY_CODE=oem_config::$LOGIN_SECURITY_CODE;
    }
    else if(file_exists(globalStatic::$root_directory. 'lingdang.php'))
    {
         require_once(globalStatic::$root_directory. 'lingdang.php');
        $LOGIN_SECURITY_CODE=oem_config::$LOGIN_SECURITY_CODE;
    }
}

if($_REQUEST['module']!=""&&$_REQUEST['module']!="Users")
{
    //微信客户001
    $url=getQRcodeForLogin();
    //http://www.kehu001.com/weixin
    $current_url = $_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];
    if(stripos($current_url,'kehu001.com/weixin')!==false)
    {
        if(!empty($url))
        {
            header("Location:".$url);
            exit();
        }
    }
}
else if($_REQUEST['module']=='Users'&&$_REQUEST['action']!="Login"&&$_REQUEST['action']!="LoginCheck")
{
    //微信客户001
    $url=getQRcodeForLogin();
    //http://www.kehu001.com/weixin
    $current_url = $_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];
    if(stripos($current_url,'kehu001.com/weixin')!==false)
    {
        if(!empty($url))
        {
            header("Location:".$url);
            exit();
        }
    }
}

$current_module_strings['VLD_ERROR'] = base64_decode('UGxlYXNlIHJlcGxhY2UgdGhlIFN1Z2FyQ1JNIGxvZ29zLg==');


 
if(isset($_SESSION["login_error"]) && $_REQUEST['login_method'] != 1)
{
	$login_error = $_SESSION['login_error'];
  
}
if(isset($_SESSION['login_usererror']))
{
    $login_usererror=$_SESSION['login_usererror'];
    //027261: 登录超过可以用户数的问题
   unset($_SESSION['login_usererror']);
}


//require_once 'lingdangversion.php';

global $currentModule, $moduleList, $lingdang_current_version,$VersionNo;
$image_path="include/images/";
 
//edit:duan reason:判断当前设置的背景图片不存在时改用默认图片
$background_url = $global_logininfo['backgroundbg']['content'];
if(!file_exists($background_url))
{
    file_put_contents($background_url,file_get_contents(globalStatic::$root_directory."dataCache/test/logo/login_bg_001_default.png"));
}

if(stripos($global_welcome['updateexplain'],'http://www.51mis.com/other/up')!==false)
{
    //37198: 升级说明的超链接修改为71mis.com上的版本更新说明
      createLoginParam('no'); 
}
//edit:


global $global_loginpage_url;

if(!is_array($global_loginpage_url))
{
    //登录界面添加超连接
    createLoginParam('no');       
}
/*
edit:Can
date:20130418
reason:3638: 登录界面：标题名称不完整

*/
//$app_strings = return_application_language('zh_cn');
require_once(globalStatic::$root_directory. "Register/RegOp.php");
$regop=RegOp::getInstance();

$smarty=new lingdangCRM_Smarty;

global $dbversion;
 if(empty($dbversion))
 {
	 require_once(globalStatic::$root_directory.'include/database/PearDatabase.php');

	 if(!$adb)
	 {
		 $adb=PearDataBase::getInstance();
	 }
    //37132:PC端：设置密码严格管理，当密码不符合严格管理要求，提示页面点击浏览器的返回按钮“<-”就可以登录进入系统
    //37144:开启“登录时启用手机短信验证”参数，用户登录时点击登录跳转页面不对(不是这个导致，是跳转到登录界面后，会提示升级，升级后跳转不正确)
      $sql='select * from ld_version';
      $result=$adb->pquery($sql,array());
      $dbversion=$adb->query_result($result,0,'current_version');
      
 }
$smarty->assign("LOGINPAGEURL", $global_loginpage_url);

if(!array_key_exists('after_zh_content',$global_welcome))
{
    $global_welcome['after_zh_content']=$global_welcome['zh'];
    
}
if(!array_key_exists('after_en_content',$global_welcome))
{
    $global_welcome['after_en_content']=$global_welcome['en'];
    
}
if(method_exists($regop,'getauthenshow')&&$regop->getauthenshow()=='no')
{
    $global_logininfo['autheninfo']['isshow']='yes';
    
}
//duan PC端登录效果优化
if(empty($global_logininfo['weixin'])){
    $global_logininfo['weixin'] = array('zh'=>'安装企业微信','en'=>'Install WeChat','isshow'=>'yes','isedit'=>'no','content'=>'http://www.51mis.cn/webapi/weixinapi_v5/wx_suite/authorize.html');
}else if($global_logininfo['weixin']['zh']!='安装企业微信'||$global_logininfo['weixin']['en']!='Install WeChat'){
    $global_logininfo['weixin']['zh'] = '安装企业微信';
    $global_logininfo['weixin']['en'] = 'Install WeChat';
}
//frank 查看版权所有可否更改的授权
$copyrightmodify = '0';
if(method_exists($regop,'getCopyRightModify'))
    $copyrightmodify=$regop->getCopyRightModify();
if($copyrightmodify=='0'){
    $global_logininfo['copyrightinfo']['isshow']='yes';
}

$smarty->assign("LOGININFO",$global_logininfo);



require_once globalStatic::$root_directory.'dataCache/Login/LoginSettingsInfo.php';
if($regop->GetVersionNo()=='65'||$regop->GetVersionNo()=='66'||$regop->GetVersionNo()=='67'||$regop->GetVersionNo()=='68')
{
    //不考虑客户修改欢迎语 了
 //   $global_welcome['after_zh_content']="欢迎 登录助华CRM";
 //   $global_welcome['after_en_content']="欢迎 登录助华CRM";
}


$smarty->assign("LOGINWELCOME",$global_welcome);

$smarty->assign("lddatafile",'no');
 if(file_exists(globalStatic::$root_directory.'user_privileges/lddatafile.dat'))
 {
    $smarty->assign("lddatafile",'yes');
 }

$NoRegister=$regop->isExistFile();
if(isset($app_strings['LBL_CHARSET'])) {
	$smarty->assign("LBL_CHARSET", $app_strings['LBL_CHARSET']);
} else {
	$smarty->assign("LBL_CHARSET", $default_charset);
}

$smarty->assign("NOREGISTER",$NoRegister);

$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
$smarty->assign("LINGDANG_VERSION", $lingdang_current_version);
if($global_iskehu001=='no')
{
    //获取oem信息，动态读取登录界面显示信息（diony）
    $sql="select * from ld_organizationdetails";
    $result = $adb->pquery($sql, array());
    if($adb->num_rows($result) > 0) {
        //Handle for allowed organation logo/logoname likes UTF-8 Character
        $companyDetails = array();
        $companyDetails['name'] = $adb->query_result($result, 0, 'organizationname');
        $companyDetails['website'] = $adb->query_result($result, 0, 'website');
        $companyDetails['logo'] = ($adb->query_result($result, 0, 'logoname'));
        $smarty->assign("LOGO", $companyDetails['logo']);

        $smarty->assign("COMPANY_DETAILS", $companyDetails);
    }

}
else
{
    
    $smarty->assign("LOGO","logo.png");
   
}
if(isset($login_error) && $login_error != "") {
     
	$smarty->assign("LOGIN_ERROR", $login_error);
}

$languageType = ($default_language != '')?substr($default_language,0,2):'zh';
if(isset($_REQUEST['languageType']) && !empty($_REQUEST['languageType'])){
	$languageType = $_REQUEST['languageType'];
    if($languageType!='zh'&&$languageType!='en')
    {
        $strurl=$_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['SERVER_NAME'].':'.$_SERVER['SERVER_PORT'].$_SERVER['SCRIPT_NAME'];
        header("Location:".$strurl);
    }
}
else
{
    $_REQUEST['languageType']='zh';

}


$reg=RegOp::getInstance();
$enorzh=$reg->isEnorZh();
 $smarty->assign('ENORZH',$enorzh);
$smarty->assign("LINGDANGTIP","no");
if($global_iskehu001=='no')
{
    $RegisterVersionNo=$reg->GetVersionNo();

    if(is_array($versions)&&  ($versions[$RegisterVersionNo]['titleisshow']=='yes'||!array_key_exists('titleisshow',$versions[$RegisterVersionNo])))
    {
        if($languageType=='zh'){
            if($versions[$RegisterVersionNo]['after_zh_title']!=""){
                $smarty->assign("BROWSETITLE",$versions[$RegisterVersionNo]['after_zh_title']);
            }
            else{
                $smarty->assign("BROWSETITLE",$versions[$RegisterVersionNo]['LBL_BROWSER_TITLE']);
            }
        }
        else{

            if($versions[$RegisterVersionNo]['after_en_title']!=""){
                $smarty->assign("BROWSETITLE",$versions[$RegisterVersionNo]['after_en_title']);
            }
            else{
                $smarty->assign("BROWSETITLE",$versions[$RegisterVersionNo]['EN_LBL_BROWSER_TITLE']);
            }
        }
    }
    if(empty($global_login_wxbtn))
    {
        $global_login_wxbtn=array('zh'=>"企业微信登录",'en'=>"WeChat login",'isshow'=>'yes','after_en_content'=>"WeChat login","after_zh_content"=>"企业微信登录");
    }
    if(!array_key_exists('after_en_content',$global_login_wxbtn))
    {
        $global_login_wxbtn['after_en_content']='WeChat login';
        
    }
    $smarty->assign("WXLOGINBTN",$global_login_wxbtn);
    if($enorzh=='no'){
        $languageType = 'zh';
    }
    $smarty->assign('ENORZH',$enorzh);


   
}
else
{
   if($enorzh=='no'){
        $languageType = 'zh';
    }
    
}
 if($reg->isExistFile()==1)
{
    //edit:can 20230403 XUQIU1000768 账套到期提示优化
    $smarty->assign("HAVEREGISTERED",'YES');
    $AuthInfoArr = judgeCorpInfo('kehu001');//editor:gyq date:2018:01:22 0032106: 登录界面：未注册前和客户001预置账套，授权信息和序列号显示
    if(!empty($AuthInfoArr)){
       $company = $AuthInfoArr['crm']['auth_corp_info']['corp_name'];
        $smarty->assign("SOFTCOMPANY",$company);
        $smarty->assign("WXCORPMARKGETROOTPATH",1);//	0032477: 客户001登录界面中的关于我们，和授权信息， 都有问题
    }else{
        $smarty->assign("SOFTCOMPANY",$reg->softCompany());
    }
    //$smarty->assign("REGUSERCOUNT",$regop->GetUserCount());
   $reg_expireddate=$reg->getExpireDate();
   $reg_spsexpireddate = $reg->getcjt_service_expdate();
   require_once(globalStatic::$root_directory.'include/DateOperation.php');
 
    //crm_load_class_file('DateOperation','include');
    $days=DateOperation::days_between_date(date("Y-m-d"),$reg_expireddate);
    $spsdays=DateOperation::days_between_date(date("Y-m-d"),$reg_spsexpireddate);
    
   if($reg_spsexpireddate != '1600-01-01' && $reg_spsexpireddate != '-0001-11-30' && $reg_spsexpireddate != '1970-01-01'){
    if($reg_spsexpireddate <= date("Y-m-d")){
        $smarty->assign("SPSEXPIREDTIP",'yes');
    }
    elseif($spsdays<=15&&$spsdays>0){
        $smarty->assign("SPSEXPIREDDAYS",$spsdays);
        $smarty->assign("SPSEXPIRINGTIP",'yes');
    }
   }

    if($reg->isExpired()=='yes')
    {
        
        $smarty->assign("EXPIREDTIP",'yes');
         if($languageType=='zh')
            $smarty->assign("REGINFOTIP","您的软件已经过期，请联系供应商！");
        else
            $smarty->assign('REGINFOTIP',"Your software has expired, please contact with the supplier!");
            
        $smarty->assign("LINGDANGTIP","Permitted");
    }
    else if($days<=15&&$days>0)
    {
        $smarty->assign("EXPIREDDAYS",$days);
        $smarty->assign("EXPIRINGTIP",'yes');
        if($languageType=='zh')
            $smarty->assign("REGINFOTIP","您的软件$days 天后即将到期，请联系供应商！");
        else
            $smarty->assign('REGINFOTIP',"Your software will expire in $days days, please contact with the supplier!");
        $smarty->assign("LINGDANGTIP","Permitted");
    }
    else if($reg->softGetType()==2)
    {
        $smarty->assign("REGTESTTIP",'yes');
        
        if($languageType=='zh')
            $smarty->assign("REGINFOTIP","您的软件仅供内部演示使用，不可销售给客户！");
        else
            $smarty->assign('REGINFOTIP',"Your software is for internal demo use only, not allowed to sell to customers！");
        $smarty->assign("LINGDANGTIP","Permitted");
            
    }
    else 
    {
       
          $fullyear=date("Y");
          $fullmonth=date("m");
          $fullday=date("d");
          $str= $fullyear+$fullmonth+$fullday;
          //echo $str;
          $checkinfo=chr(substr($str,0,2)+30);
          $checkinfo.=chr(substr($str,2,4)+30);
          $checkinfo=str_replace('\\','2',$checkinfo);
        $smarty->assign("REGINFOTIP",$checkinfo);
        
    }
       
    if(!empty($AuthInfoArr)){//editor:gyq date:2018:01:22 0032106: 登录界面：未注册前和客户001预置账套，授权信息和序列号显示
        $urls=$_SERVER['REQUEST_URI'];//参数来自客户001上的cls_weixinInfo
        $urls=explode("/",$urls);
        $url=$urls[2];
        $CorpUrl_Num=str_pad($_SESSION["kehu001".$url]['pre_no'],11,"0",STR_PAD_LEFT);
        $CorpTransArr = array(55=>2,56=>3,57=>4,58=>1);
        $smarty->assign("SERIALNUM",$CorpTransArr[checkVersionIs001()].$CorpUrl_Num);
    }else{
        $smarty->assign("SERIALNUM",$reg->GetSerialNum());
    }
}
else
{
   $smarty->assign("SOFTCOMPANY", $common_version['CopyRight']);
   $smarty->assign("REGUSERCOUNT",1);
   $smarty->assign("AUTHENTYPES",'试用(未注册)');
   $smarty->assign("SERIALNUM",'');
    $fullyear=date("Y");
    $fullmonth=date("m");
    $fullday=date("d");
    $str= $fullyear+$fullmonth+$fullday;
    $checkinfo=chr(substr($str,0,2)+30);
    $checkinfo.=chr(substr($str,2,4)+30);
       
    $smarty->assign("REGINFOTIP","");
}
$smarty->assign('LANGUAGETYPE',$languageType);
/*
edit by LD Can
date:20130325
reason:用户注册需求
*/
if(isset($login_usererror)&&$login_usererror!="")
{
    $smarty->assign("login_usererror",$login_usererror);
    
}
$_SESSION[md5(globalStatic::$root_directory.'loginbtn')]=md5(rand(1,9999999));
$smarty->assign("SESSIONRAND",$_SESSION[md5(globalStatic::$root_directory.'loginbtn')]);
$tokenrand = bin2hex(random_bytes(8)).'|'.time();// 生成8字节长度的随机数并转换为16进制字符串
$_SESSION[md5(globalStatic::$root_directory.'tokenrand')]=$tokenrand;
$smarty->assign("TOKENRAND",$tokenrand);
if($global_iskehu001=='no')
{
    
    $query="select deploy_value from ld_systems_deploy where deploy_type = 73";
    $result=$adb->query($query);
    $num_rows=$adb->num_rows($result);
    if($num_rows){
    	$status=$adb->query_result($result,0,'deploy_value');
    }
    if($status == 1){
        $code='false';
    }
    else{
        $code='true';
    }
    if($code=='true')
        $smarty->assign('CODE','1');
}

//获取版本信息
$smarty->assign("VERSIONINFO",$versions[$VersionNo]);
$smarty->assign("COMMON_VERSIONINFO",$common_version);
$smarty->assign("SOFTVERSION",$common_version['lblversion']);
/**************editor:gyq date:20171229**************/
//客户001未分配预置账套不允许登录 D:\wamp\www\ldcrm\modules\Users\Login.php D:\wamp\www\ldcrm\Smarty\templates\Login.tpl
$smarty->assign("WEIXINLOGINURL",'');

if($global_iskehu001=='no')
{
    $KEHU001_NO_DISTRIBUTE = true;
    preg_match('#weixin/(\w+)/#i',$_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'],$matches);
    preg_match('#kh/(\w+)/#i',$_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'],$khmatches);
    if(!empty($matches)||!empty($khmatches)) {
        
        
        $crmversion=$regop->GetVersionNo();
        if(!judgeCorpInfo('install_app')){
            $smarty->assign('WEIXINLOGIN','no');
            $smarty->assign('KEHU001_NO_DISTRIBUTE','yes');
            $KEHU001_NO_DISTRIBUTE = false;
        }
    }
    if($KEHU001_NO_DISTRIBUTE){
        //判断是否授权安装CRM微信套件应用 gyq_51  20171128
        $corpurl = getQRcodeForLogin();
        $smarty->assign('WEIXINLOGINURL',$corpurl);//
     
    }
    //自建应用
    crm_load_class_file("cls_WeiXinSelfBuiltApp", 'WeiXinApp/WeiXin_common');
    $wxselfbuilt_obj = new cls_WeiXinSelfBuiltApp();
 
    $corpid = $wxselfbuilt_obj->corpid;
    $corpsecret = $wxselfbuilt_obj->corpsecret;//自建应用的secret
    $agentid = $wxselfbuilt_obj->agentid;//自建应用生成前端链接时，agentid传上去
    $smarty->assign("agentid",$agentid);
    $smarty->assign("corpid",$corpid);
    if(!empty($agentid))
   {
    $corpurl = $wxselfbuilt_obj->corp_link;// 同 $corpurl
     $smarty->assign('WEIXINLOGINURL',constant("WxSelfBuildURL").'/wxSelfbuiltQrCodeLogin.php?corpurl='.$corpurl);//
   }
    
}
else if($global_iskehu001=='yes')
{
    $corpurl = getQRcodeForLogin();
     $smarty->assign('WEIXINLOGINURL',$corpurl);
}
if(empty($corpurl)){
            $smarty->assign('WEIXINLOGIN','no');
}else{
            $smarty->assign('WEIXINLOGIN','yes');
}
$smarty->assign('WEIXINLOGINERROR',$_REQUEST['weixinloginerror']);

/****************************/

/**
 *@ 演示平台获取版本
 *@ by andy 20140307
 * 用户体验改进
 */ 
//获取版本信息
$version=$versions[$VersionNo]['Version'];
if($version== 2)
{
    $version='jichu';
}
else if($version== 7)
{
    $version='jichu';
}
else if($version== 10)
{
    $version='biaozhun';
}
else if($version== 1)
{
    $version='crm';
}
else if($version==6)
{
    $version="xiaoshou360_mini";
}
else if($version==40)
{
    $version="crm_mini";
}
else if($version==41)
{
    $version="crm_jinrong";
}
else if($version==42)
{
    $version="xiaoshou360_jichu";
}
else if($version==43)
{
    $version="xiaoshou360_biaozhun";
}
else if($version==44)
{
    $version="xiaoshou360_qiye";
}
else if($version==55)
{
    $version="kehu001_biaozhun";
}
else if($version==56)
{
    $version="kehu001_xszq";
}
else if($version==57)
{
    $version="kehu001_fwzq";
}
else
{
	$version='crm';
}
$smarty->assign('CVERSION',$version);

if(isset($_SESSION['error_user_name']))
{
	$smarty->assign('LOGINUSERNAME',$_SESSION['error_user_name']);
}
/*else
{*/
    
    if($NoRegister==0)//无注册文件
    {
        $smarty->assign('LOGINUSERNAME','admin');
    }
//}

//页面清除缓存，防止黑客恶搞
$arr=range(1,10);
shuffle($arr);
$rand_num='';
foreach($arr as $values)
{
  $rand_num.=$values;
}
$smarty->assign("TOKEN",$rand_num);

$_SESSION['login_clear_cache'.$root_directory]=$rand_num;
//判断当前浏览版本是否支持
//$whetherPalyBox=whetherPalyBox();
//$smarty->assign('PALYBOX',$whetherPalyBox);
$LingDang = 'no';
if(($languageType == 'zh' && strpos($soft_Info['CopyRight'],'上海灵当') !== false) || ($languageType == 'en' && strpos($soft_Info['EN_CopyRight'],'Shanghai Lingdang Information Tech') !== false)){
	$LingDang = 'yes';
}
$westore = array('zh' => '企业微信', 'en' => 'WeStore');
$smarty->assign('WESTORE',$westore);
$smarty->assign('LINGDANG',$LingDang);
$smarty->assign("SOFTINFO",$soft_Info);
setGLobalURLSmarty($smarty);

if($global_iskehu001=='yes')
{
    $smarty->display("Loginkh001.tpl");
    exit();
}

// XUQIU1001174  ls 20230426 百特集成okta
$VersionInfo = getVersionInfo();
$smarty->assign("account_version",$VersionInfo['account']);
//XUQIU1002510 圣拉维，新增开发需求
$have_remember_password = 'yes';//默认显示记住密码
if($VersionInfo['account'] == 'shenglawei'){
    $have_remember_password = 'no';//圣拉维不显示记住密码
}
$smarty->assign("have_remember_password",$have_remember_password);

if(!isset($reglogin_check))
{
    //注册界面登录
    $reglogin_check='no';
}
$smarty->assign("reglogin_check",$reglogin_check);
$_SESSION['regloginsession']='';
$_SESSION['reglogin_userid']='';

if($reglogin_check=='yes')
{
    //注册界面登录
    $_SESSION['regloginsession']=rand(1000000000,9999999999);
    $smarty->assign("reloginsession",$_SESSION['regloginsession']);
}

else
    $smarty->assign("reloginsession","");

if($LOGIN_SECURITY_CODE == 0)
{   
    if(empty($lingdang_current_version)||!isset($lingdang_current_version))
    {
        
        require_once("lingdangversion.php");
    }
   
    
    if(version_compare($dbversion, $lingdang_current_version, '='))
    {

            if($_REQUEST['update']==2)
            {
                //脚本升级后，清楚tabdata缓存
                global $current_user;
                $current_user=new Users();
                $current_user->id=1;
                create_parenttab_data_file();
                create_tab_data_file();

            }

         	  $_SESSION['LINGDANG_DB_VERSION']= $dbversion;
    }
    else if(version_compare($dbversion,$lingdang_current_version)==1)
    {

            if($_REQUEST['update']==2)
            {
                create_parenttab_data_file();
                create_tab_data_file();

            }
    }
    else if(!isset($_REQUEST['update'])&&$_REQUEST['update']!=2)
    {
     
      $smarty->assign("ISUPATE",'yes');//升级数据库
    }
    $updateing='no';
    if(file_exists("dataCache/sqlhandlers/update1.txt"))
    {
        $update=file_get_contents("dataCache/sqlhandlers/update1.txt");
       
        if($update!='2')
        {
            $_REQUEST['update']=2;
               
            $smarty->assign("ISUPATE",'yes');//
            $smarty->assign("UPDATEING",'yes');//数据库正在升级中
            $smarty->assign("ISUPATE",'no');//升级数据库
            //edit:can 2021-01-08 38177: 升级过程中，多个人打开登录界面，停留在升级界面，但是数据库已升级到最新
            $updateing='yes';
        }
    }

    $historylogin = getUsersettingByLabel('Settings',1,'historyloginui');
    if($historylogin == 'new'||$reglogin_check=='yes'){
        $global_loginpage_url_arr = [];
        for($i = 0;$i < count($global_loginpage_url);$i++){
            if($global_loginpage_url[$i]['isshow'] == 'yes'){
                $global_loginpage_url_arr[] = array('label'=>$global_loginpage_url[$i]['content'],'value'=>$global_loginpage_url[$i]['content'],'url'=>$global_loginpage_url[$i]['url']);
            }
        }
        $smarty->assign("global_loginpage_url_arr",json_encode($global_loginpage_url_arr));
        $smarty->assign("loginpage_url_num",count($global_loginpage_url_arr));
        $getLoginInfoData = getLoginInfoData();
        $loginswiperarr = $getLoginInfoData['loginswiperarr'];
        $swiperratio = $getLoginInfoData['swiperratio'];
        $smarty->assign("LOGINSWIPERARR",$loginswiperarr);
        $smarty->assign("SWIPERRATIO",$swiperratio);

        $copyrightmodify = 0;
        if(method_exists($regop,'getCopyRightModify')){
            $copyrightmodify=$reg->getCopyRightModify();
        }
        $smarty->assign("copyrightmodify",$copyrightmodify);

        $smarty->display('loginnewswiper.tpl');
    }
    else{
        $smarty->display('loginnew.tpl');
    }

   
     if(version_compare($dbversion, $lingdang_current_version, '='))
    {
         	  $_SESSION['LINGDANG_DB_VERSION']= $dbversion;
              //edit:can 2021-01-08 38177: 升级过程中，多个人打开登录界面，停留在升级界面，但是数据库已升级到最新
              $smarty->assign("UPDATEING",'no');//数据库正在升级中
              @unlink("dataCache/sqlhandlers/update1.txt");
              $updateing='no';
              
    }
    else if(version_compare($dbversion,$lingdang_current_version)==1)
    {
            
    }
    else if(!isset($_REQUEST['update'])&&$_REQUEST['update']!=2&&$updateing=='no')
    {
       
       include(globalStatic::$root_directory."sql/updateVersion/updatesql.php");
    }
    
    exit();
}
else
{
    if($_REQUEST['login_method'] == true)
    {
        $smarty->assign('LOGINMETHOD',1);
        $historylogin = getUsersettingByLabel('Settings',1,'historyloginui');
        if($historylogin == 'new'){
            $global_loginpage_url_arr = [];
            for($i = 0;$i < count($global_loginpage_url);$i++){
                if($global_loginpage_url[$i]['isshow'] == 'yes'){
                    $global_loginpage_url_arr[] = array('label'=>$global_loginpage_url[$i]['content'],'value'=>$global_loginpage_url[$i]['content'],'url'=>$global_loginpage_url[$i]['url']);
                }
            }
            $smarty->assign("global_loginpage_url_arr",json_encode($global_loginpage_url_arr));
            $smarty->assign("loginpage_url_num",count($global_loginpage_url_arr));
            $getLoginInfoData = getLoginInfoData();
            $loginswiperarr = $getLoginInfoData['loginswiperarr'];
            $swiperratio = $getLoginInfoData['swiperratio'];
            $smarty->assign("LOGINSWIPERARR",$loginswiperarr);
            $smarty->assign("SWIPERRATIO",$swiperratio);

            $copyrightmodify = 0;
            if(method_exists($regop,'getCopyRightModify')){
                $copyrightmodify=$reg->getCopyRightModify();
            }
            $smarty->assign("copyrightmodify",$copyrightmodify);

            $smarty->display('loginnewswiper.tpl');
        }
        else{
            $smarty->display('loginnew.tpl');
        }
    }
    else
    {


        if(version_compare($dbversion, $lingdang_current_version, '='))
        {

            if($_REQUEST['update']==2)
            {
                //脚本升级后，清楚tabdata缓存
                global $current_user;
                $current_user=new Users();
                $current_user->id=1;
                create_parenttab_data_file();
                create_tab_data_file();

            }
             	  $_SESSION['LINGDANG_DB_VERSION']= $dbversion;
        }
        else if(version_compare($dbversion,$lingdang_current_version)==1)
        {

            if($_REQUEST['update']==2)
            {
                create_parenttab_data_file();
                create_tab_data_file();

            }
        }
        else if(!isset($_REQUEST['update'])&&$_REQUEST['update']!=2)
        {
           // include('sql/updateVersion/updateWareSql.php');
           header('Location:sql/updateVersion/updateWareSql.php');
        }
            $str_url=$_SERVER['HTTP_HOST']. $_SERVER['PHP_SELF'];
            $smarty->assign('CURRENCT_URL',$str_url);
            $smarty->assign('WEB_URL',oem_config::$web_url);
            $smarty->assign('TITLE',oem_config::$title);
            $smarty->assign('SUBJECT',oem_config::$subject);
            $smarty->assign('DESCRIPTION_ONE',oem_config::$decription1);
            $smarty->assign('HOT_LINE',oem_config::$hot_line);
             $_SESSION['sms_send_jsrand']=rand(1,999999);
			$_SESSION['sms_demologin_jsrand']=rand(1,999999);
            $smarty->assign("jsrand",$_SESSION['sms_send_jsrand']);
			$smarty->assign("demologinrand",$_SESSION['sms_demologin_jsrand']);
            if(strpos($_SERVER['SERVER_NAME'],'51mis.com') !==false ||strpos($_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'],'xiaoshou360.com/KH/zhuanye') !==false||strpos($_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'],'xiaoshou360.com/KH/lingdang') !==false||strpos($_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'],'xiaoshou360.com/KH/puyong') !==false){
                $smarty->display('demoLoginCheck.tpl');
            }else{
                $smarty->display('SMSLoginCheck.tpl');
            }   
    }
        
}
/*
if(checkBrowserIsSupport()=='no'){
    require_once('Smarty_setup.php');
    $smarty=new lingdangCRM_Smarty;        
    $smarty->display('LoginNotSupport.tpl');
    exit;
}*/

/*

function whetherPalyBox(){

    $play=false;
    $getBrowser=getBrowser();
    $getBrowserVer=getBrowserVer();
    if($getBrowser=='firefox'||$getBrowser=='chrome'||$getBrowser=='maxthon'||$getBrowser=='opera'){

		$play=false;
    }elseif($getBrowser=='360EE'){
        if(stripos($_SERVER['HTTP_USER_AGENT'],"Trident")){
          $play=false;
        }else{
          $play=true;
        }
    }elseif($getBrowser=='sogou'){
        if(stripos($_SERVER['HTTP_USER_AGENT'],"Trident")){
          $play=false;
        }else{
          $play=true;
        }
    }elseif($getBrowser=='ie'){
	//	if(preg_match('/Trident\/(\d+)\../i', $_SERVER['HTTP_USER_AGENT'], $regs)){
			 if($regs[1]>=4){
				 $play=false;
			 }else{
				 $play=true;
			 }
		}else{
			$play=true;
		}
    }else{
        $play=true;
    }
    if($play==true){
        $box = 'yes';
    }else{
		$box = 'no';
    }
	return $box;
}*/

//获取当前浏览器版本号
/*
function getBrowserVer(){
	//当浏览器没有发送访问者的信息的时候
    if(empty($_SERVER['HTTP_USER_AGENT'])){
        return 'unknown';
    }
    $agent= $_SERVER['HTTP_USER_AGENT'];
    if (preg_match('/MSIE\s(\d+)\../i', $agent, $regs)){
        return $regs[1];}
    elseif (preg_match('/FireFox\/(\d+)\../i', $agent, $regs)){
        return $regs[1];}
    elseif (preg_match('/Opera[\s|\/](\d+)\../i', $agent, $regs)){
        return $regs[1];}
    elseif (preg_match('/Chrome\/(\d+)\../i', $agent, $regs)){
        return $regs[1];}
    elseif (preg_match('/Maxthon\/(\d+)\../i', $agent, $regs)){
		return $regs[1];}
    elseif (preg_match('/360\/(\d+)\../i', $agent, $regs)){
		return $regs[1];}
    elseif (preg_match('/Sogou\/(\d+)\../i', $agent, $regs)){
		return $regs[1];}
    else{
        return 'unknown';}
}*/

?>