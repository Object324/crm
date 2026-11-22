<?php
//云之家网页端 跳转的域名 -传参获得
$corpurl = empty($_REQUEST['corpurl'])?'':$_REQUEST['corpurl'];
$_REQUEST['diony']='yes';
//验证tokenrand
if(isset($_REQUEST['loginajax'])&&$_REQUEST['loginajax'] == 'yes'){
    $sessiontokenrand = isset($_SESSION[md5(globalStatic::$root_directory.'tokenrand')])?$_SESSION[md5(globalStatic::$root_directory.'tokenrand')]:'';
    $ldtokenrand = isset($_REQUEST['ldtokenrand'])?$_REQUEST['ldtokenrand']:"";
    if($ldtokenrand !== $sessiontokenrand){
        //zkt 20241122 BUG20241122-03 order和81的每天第一次登录会先报错“没有访问权限，请刷新重试”，关掉弹窗直接进行第二次登录就可以直接登录，应该不报错
        //AuthenticateLoginUnSuccessful(-2,array(),'没有访问权限，请刷新重试');
    }
}
//require_once('include/logging.php');
//require $root_directory.'/user_privileges/audit_trail.php';
//require_once("Register/RegOp.php");

//@edit:liushuai,2020-09-10,reason:【ID1000980】/CRM服务器磁盘满了（95%），控制CRM无法登陆，并给出提示信息
if(strtoupper(substr(PHP_OS,0,3))==='WIN'){  //windows服务器
    $disk_free_space = disk_free_space(globalStatic::$root_directory);
    $disk_total_space = disk_total_space(globalStatic::$root_directory);
    if(!empty($disk_free_space) && !empty($disk_total_space))
        $free_space = number_format(($disk_free_space/$disk_total_space), 2);
    else
        $free_space = 1;
}else{//linux服务器暂时不做提醒
    /*$sh = shell_exec('df -lh | grep -E "^(/)"');
    $sh = preg_replace("/\s{2,}/", ' ', $sh);
    $hd = explode(" ", $sh);
    if (isset($hd[4]) && !empty($hd[4])) {
        $free_space = number_format((1 - trim($hd[4],'%')/100),2);  //剩余空间   trim($hd[4],'%'):已使用 51
    }else{
        $free_space = 1;//为避免没有权限获取或者解析错误导致客户无法登陆，默认不做提醒处理
    }*/
    $free_space = 1;

//    $hd_avial = trim($hd[3],'G');//可用空间G
//    $hd_usage = trim($hd[4],'%');//已使用百分比
//    $hd_usage = number_format(trim($hd[4],'%')/100,2);
//    $free_space = 1 - $hd_usage; //剩余空间
}

$languageType = $_REQUEST['languageType'] == 'en'?'en':'zh';
if($free_space < 0.01){
//if($free_space < 1){
    if($languageType=='zh'){
        if($_REQUEST['loginajax'] == 'yes'){
            AuthenticateLoginUnSuccessful(-2,array(),'您的CRM服务器磁盘已超过99%，请清理磁盘后重新登录！');
        }
        $_SESSION['login_usererror']="您的CRM服务器磁盘已超过99%，请清理磁盘后重新登录！";
        header("Location: index.php?languageType=zh");
    } else {
        if($_REQUEST['loginajax'] == 'yes'){
            AuthenticateLoginUnSuccessful(-2,array(),'Your CRM server disk has exceeded 99%, please clean the disk and log in again!');
        }
        $_SESSION['login_usererror']="Your CRM server disk has exceeded 99%, please clean the disk and log in again!";
        header("Location: index.php?languageType=en");
    }
    exit();
}

require globalStatic::$root_directory.'/modules/Reminds/Reminds.php';

$reg = RegOp::getInstance();
$testFile = $reg->isExistFile();
$focus = CRMEntity::getInstance('Users');// new Users();

if($testFile==1&&$reg->isExpired()=='yes')
{
   // $_SESSION['login_usererror']=$counterror;
   if($_REQUEST['loginajax'] == 'yes'){
       AuthenticateLoginUnSuccessful(-2,array(),'您的软件已到期，请联系供应商!');
    }
   $_SESSION['login_usererror']="您的软件已到期，请联系供应商!";
   if($_REQUEST['loginajax'] == 'yes'){
       AuthenticateLoginUnSuccessful(-1,array(),'您的软件已到期，请联系供应商！');
    }
   $_SESSION['login_error']='您的软件已到期，请联系供应商！';
   
    //exit('软件已到期');
}
else if($testFile==1&&$reg->isCorrectFile()!="1")
{
    if($_REQUEST['loginajax'] == 'yes'){
        AuthenticateLoginUnSuccessful(-2,array(),$reg->isCorrectFile());
    }
    $_SESSION['login_usererror']=$reg->isCorrectFile();
   // exit('软件特征码错误');
}
else if($testFile==0)
{
    
    $_REQUEST['user_name']='admin';
    if($languageType=='zh'){
        $error_tips = '未注册不允许登录，请立即注册';
    }else{
        $error_tips = 'You are not allowed to log in without registering. Please register now.';
    }
    if($_REQUEST['loginajax'] == 'yes'){
        AuthenticateLoginUnSuccessful(-2,array(),$error_tips);
    }
    $_SESSION['login_usererror'] = $error_tips;
}

global $current_user;
$version_account = getVersionInfo()['account'];

// 判断验证码是否正确
$sys73 = getSys_deploy(73);
if($sys73['deploy_value'] == 0){
    if(isset($_SESSION[md5('codenum')])){
        if(md5($_REQUEST['secutity_code']) != $_SESSION[md5('codenum')]){
            $_SESSION[md5('codenum')] = 'error';
            AuthenticateLoginUnSuccessful(-3,array(),'验证码不正确，请重新输入！');
        }
        $_SESSION[md5('codenum')] = 'success';
    }
}

/**
*演示平台短信验证 
* by andy
* date 20140307
*/
include(globalStatic::$root_directory."modules/Users/AuthenticateUserLogin.php");





if(file_exists('noPwd.php'))//汇付天下
{
            
             include("noPwd.php");
            //$_REQUEST['user_password'] = "##@@bossnopassword##";
}
else
{
       
        
        if(isLoginCrm()=='yes')
           {
            if($_REQUEST['loginajax'] == 'yes'){
                ConvertTojsonString(1,array('href'=>'index.php'),'success');
            }
             header("Location:".$corpurl."index.php");
             exit();
           }
           
            	  //防止模拟登陆
            if($_REQUEST['sessionrand']!=$_SESSION[md5(globalStatic::$root_directory."loginbtn")])
            {
               // exit("参数错误！");
            }
}
if($LOGIN_SECURITY_CODE == 1 && $_REQUEST['login_method'] != 1)
{
    //这个地方请不要更改
    global $global_dandianlogin;
    $global_dandianlogin='yes'; 
    $_REQUEST['user_name'] = oem_config::$loginconfig['user'];
    //$_REQUEST['user_password'] = "##@@bossnopassword##";
}
//必须放到 noPwd.php 之后，否则无法使用全局变量$global_dandianlogin
include(globalStatic::$root_directory."modules/Users/AuthenticateOtherLogin.php");

if($testFile==1)
{
    $focus->column_fields["user_name"] = ($_REQUEST['user_name']);
}
else
{
    $focus->column_fields["user_name"] =("admin");
}
$user_password = isset($_REQUEST['user_password'])?$_REQUEST['user_password']:'';////36888: （1.6）成员管理>选择第一个用户明细界面>修改密码>将密码修改为0：修改密码后该成员登录是录入密码0提示密码错误。
require_once(globalStatic::$root_directory.'include/utils/LoginFun.php');
$loginerror=LoginSecurityCheck($focus->column_fields["user_name"]);
if($loginerror!='')
{
    if($_REQUEST['loginajax'] == 'yes'){
        AuthenticateLoginUnSuccessful(-2,array(),$loginerror);
    }
    header("Location: ".$corpurl."index.php?action=LoginCheck&module=Users&login_method=true&languageType=".$_REQUEST['languageType']);
}
else
{

    $focus->load_user($user_password);
    

    if($focus->is_authenticated())
    { 
       
        if($reg->isEnorZh()=='no') $_REQUEST['languageType'] = 'zh';
        $current_user = $focus;
        if(function_exists('opcache_invalidate'))
        {
            opcache_invalidate(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php',true);
        }
        crm_load_class_file('LoginHistory','modules/Users');
        //登录限制
        // $clientip=$_REQUEST['CrmClientIp'];
        $loginpolicy = LoginHistory::loginPolicy($focus->column_fields["user_name"],'web',$_REQUEST['languageType']);
        if(!$loginpolicy){
            unset($_SESSION['authenticated_user_id']);
            if($_REQUEST['loginajax'] == 'yes'){
                $errormsg = LoginHistory::$error_message;
                AuthenticateLoginUnSuccessful(-1,array(),$errormsg);
            }
            header("Location: ".$corpurl."index.php");
        }
    	include(globalStatic::$root_directory.'modules/Users/AuthenSuccess.php');
    
        /*
        edit by LD Can
        date:20130325
        reason:用户注册需求
        edit:can
        date:20130703
        reason:未注册版本允许登陆
        */
      
         if($testFile==1||$global_iskehu001=='yes'){//存在
            setSession('RegOp', 'RegOp');
            $codefile = $reg->isCorrectFile();
            /**
             * 更新操作
             * edit:can
             * date:20131130
             * reason: 0005816:加密注册严重错误：从别的电脑上拷贝VldSysregister.dat到本机下，本机也能正常运行
             */
          
            if($codefile!='1'){
                setSession('login_user_name', $focus->column_fields["user_name"]);
                setSession('login_password', $user_password);
                if($_REQUEST['loginajax'] == 'yes'){
                    AuthenticateLoginUnSuccessful(-2,array(),$codefile);
                }
                setSession('login_usererror', $codefile);
                header("Location: ".$corpurl."index.php");
                exit();
            }
            if($reg->getPrmAuth()=='yes'){
                $sql = 'select crm_user_type from ld_users where status=\'active\' and user_name= \''.$focus->column_fields["user_name"] . '\'';
                $result =$adb->pquery($sql,array());
                $crmprm = $adb->query_result($result, 0, 'crm_user_type');
                
                $sql = 'select user_name from ld_users where status=\'active\' and crm_user_type = ?';//获取启动的用户数
                $result=$adb->pquery($sql,array($crmprm));

                if($crmprm == 'crm'){
                    $crmprmUserCount = $reg->GetUserCount();
                }elseif ($crmprm=='prm'){
                    $crmprmUserCount = $reg->getPrmUserCount();
                }

                if($reg->compareCount($crmprmUserCount,$adb->num_rows($result))<=0 && strtolower($focus->column_fields["user_name"]) != 'admin'){
                    $_SESSION['login_user_name'] = $focus->column_fields["user_name"];
                    $_SESSION['login_password'] = $user_password;

                    $counterror=getLoginerrorInfo($_REQUEST['languageType'],'NUMUSEREXCEEDPERMITTED');
                    $counterror=str_replace('{count}',$crmprmUserCount,$counterror);
                    $counterror=str_replace('{crmprm}',$crmprm,$counterror);
                    if($_REQUEST['loginajax'] == 'yes'){
                        AuthenticateLoginUnSuccessful(-2,array(),$counterror);
                    }
                    $_SESSION['login_usererror']=$counterror;
                    header("Location: ".$corpurl."index.php");
                    exit();
                }
            }else{
                $sql = 'select crm_user_type from ld_users where status=\'active\' and user_name= \''.$focus->column_fields["user_name"] . '\'';
                $result =$adb->pquery($sql,array());
                $crmprm = $adb->query_result($result, 0, 'crm_user_type');

                if($crmprm!= 'crm'){
                    $_SESSION['login_user_name'] = $focus->column_fields["user_name"];
                    $_SESSION['login_password'] = $user_password;

                    $prmerror=getLoginerrorInfo($_REQUEST['languageType'],'PRMUSERNOAUTH');
                    if($_REQUEST['loginajax'] == 'yes'){
                        AuthenticateLoginUnSuccessful(-2,array(),$prmerror);
                    }
                    $_SESSION['login_usererror']=$prmerror;
                    header("Location: ".$corpurl."index.php");
                    exit();
                }

                $sql = 'select user_name from ld_users where status=\'active\' and crm_user_type = \'crm\' ';//获取启动的用户数
                $result=$adb->pquery($sql,array());

                if($reg->compareCount($reg->GetUserCount(),$adb->num_rows($result))<=0 && strtolower($focus->column_fields["user_name"]) != 'admin'){
                    $_SESSION['login_user_name'] = $focus->column_fields["user_name"];
                    $_SESSION['login_password'] = $user_password;

                    $counterror=getLoginerrorInfo($_REQUEST['languageType'],'NUMUSEREXCEEDPERMITTED');
                    $counterror=str_replace('{count}',$reg->GetUserCount(),$counterror);
                    $counterror=str_replace('{crmprm}','',$counterror);
                    if($_REQUEST['loginajax'] == 'yes'){
                        AuthenticateLoginUnSuccessful(-2,array(),$counterror);
                    }
                    $_SESSION['login_usererror']=$counterror;
                    header("Location: ".$corpurl."index.php");
                    exit();
                }
            }
        }
         
        //注册SESSION
        if(isset($_REQUEST['login_method']))
            $_SESSION['login_method'] = $_REQUEST['login_method'];
       
            
        setSession('authenticated_user_id',$focus->id);
        global $application_unique_key;
        setSession('app_unique_key',$application_unique_key);
          
        //edit:can reason:13229: 同一个apache虚拟目录发布的CRM，用户登录后，只要知道其他用户的虚拟目录，就能够绕过密码，进入其他用户的CRM系统中。
        setSession('lingdang_User_Password',$focus->user_password);
        setSession(globalStatic::$root_directory,'lingdang');


        
       
        if(!empty($focus->column_fields["theme"])) {
    		$authenticated_user_theme = $focus->column_fields["theme"];
    	} else {
    		$authenticated_user_theme = $default_theme;
    	}
    	// store the user's language in the session
    	if(!empty($focus->column_fields["language"])) {
    		$authenticated_user_language = $focus->column_fields["language"];
    	} else {
    		$authenticated_user_language = $default_language;
    	}
    	// If this is the default user and the default user theme is set to reset, reset it to the default theme value on each login
    	if($reset_theme_on_default_user && $focus->user_name == $default_user_name)
    	{
    		$authenticated_user_theme = $default_theme;
    	}
    	if(isset($reset_language_on_default_user) && $reset_language_on_default_user && $focus->user_name == $default_user_name)
    	{
    		$authenticated_user_language = $default_language;
    	}
    	$_SESSION['lingdang_authenticated_user_theme'] = $authenticated_user_theme;
    	$_SESSION['authenticated_user_language'] = $authenticated_user_language;
    
    
        /*
         * editor : gyq_01
         * reason : 新增用户密码严格管理
         * date   : 2016.1.15
         * */
            $system_deploy = getSys_deploy(90);
          
            	$arr = $_SESSION['lastpage'];
              //微信烧苗登录不需要判断
            $deploy_values= getSys_deploy(105);
          
          //edit:can 20210414 点登录，密码严格管理】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001556
        //BUG20241128-08 edit:can
        if((!$_REQUEST['dandian_weixin']&&($system_deploy)&&$system_deploy['deploy_value'] == 0&&$global_dandianlogin!='yes')) {
            //BUG20241206-37 ls 241211 （中天火箭）成员管理-登录控制-设置用户的密码是否严格管理为是时，密码每30天就强制你改一次。需要修改为不需要30天就强制修改，只保留密码规则即可（已在会议上讨论，针对这个客户先单独修改）

        //36905: 单点登录API：如果设置密码严格管理，单点登录的时候会判断密码是否符合规范
                require_once(globalStatic::$root_directory.'modules/Users/CheckPwd.php');
        
                $temp = new cls_CheckPwd($focus);
             
                /*
                 * editor:gyq
                 * reason:调换超时，格式先后顺序
                 * date : 2016.1.20
                 * */
              
                if($temp->PasswordManage()) {
                    if($_REQUEST['loginajax'] == 'yes'){
                        ConvertTojsonString(2,array('href'=>'UserPMLogin.php'),'success');
                    }
    
                    header("Location:UserPMLogin.php");
    
                    exit;
                }elseif($temp->PasswordInterval() && $version_account!='zhongtian') {
                    if($_REQUEST['loginajax'] == 'yes'){
                        ConvertTojsonString(2,array('href'=>'UserPMLogin.php?PasswordTimeout=1'),'success');
                    }
                    header("Location:UserPMLogin.php?PasswordTimeout=1");
                    exit;
    
                }
    
              
    
            }
            if($_REQUEST['hantianlogin']=='yes'){
                $_SESSION['hantianlogin'] = 'yes';
            }
          $_SESSION[md5(globalStatic::$root_directory."loginbtn")]=md5(rand(1,999999999));
            //登陆用户短信验证码
         
          include(globalStatic::$root_directory.'modules/Users/UserSMSLogin.php');
     
    }
    else
    {
        $_SESSION[md5(globalStatic::$root_directory."loginbtn")]=md5(rand(1,999999999));
           $focus->id=0;
           if($reg->isEnorZh()=='no')
        {
            $_REQUEST['languageType']='zh';
        }
        CreateUseLanguageType($focus);
        
       $current_user=$focus;

        	$languageType = ($default_language != '')?substr($default_language,0,2):'zh';
        		if(isset($_REQUEST['languageType'])){
        			$languageType = $_REQUEST['languageType'];
        		}
    
            $tmplogin_error = '';
    		if($_SESSION['userprofileerror'] != ''){
    		    $tmplogin_error = getLoginerrorInfo($languageType,'LOGINPROFILEMESSAGE');
    			$_SESSION['login_error'] = getLoginerrorInfo($languageType,'LOGINPROFILEMESSAGE');
                unset($_SESSION['userprofileerror']);
    		}
            else if( $_SESSION['useraccountnotexists']==1)
            {
                $tmplogin_error = getLoginerrorInfo($languageType,'USERACCOUNTNOTEXIST');
                $_SESSION['login_error'] = getLoginerrorInfo($languageType,'USERACCOUNTNOTEXIST');
                 unset($_SESSION['useraccountnotexists']);
            }
    		else
    		{
    		  
                  $status='Active';
                $sql="select status from ld_users where user_name=? and status='Inactive'";
                $result=$adb->pquery($sql,array($focus->column_fields["user_name"]));
                if($adb->num_rows($result)>0)
                 $status=$adb->query_result($result,0,0);
                $_SESSION['login_user_name'] = $focus->column_fields["user_name"];
            	$_SESSION['login_password'] = $user_password;
        	  
    			if($status=='Inactive'){
    			 //22832: 登录界面：停用用户登录系统，应该告诉明确的提示信息：用户已停用
                    $tmplogin_error = getLoginerrorInfo($languageType,'LOGININACTIVE');
    				$_SESSION['login_error'] =getLoginerrorInfo($languageType,'LOGININACTIVE');
    			}
    			else{
    			    $tmplogin_error = getLoginerrorInfo($languageType,'LOGINCORRECTACCOUNT');
    				$_SESSION['login_error'] = getLoginerrorInfo($languageType,'LOGINCORRECTACCOUNT');
    
    			}
    		}
            $_SESSION['error_user_name'] = to_html($_REQUEST['user_name']);
            if($_REQUEST['loginajax'] == 'yes'&&!empty($tmplogin_error)){
                unset($_SESSION['login_error']);
                AuthenticateLoginUnSuccessful(-1,array(),$tmplogin_error);
            }
    		
    
      //header("Location: index.php?languageType=".$_REQUEST['languageType']);
        /**
         *@更新操作
         *@edit: andy
         *@reason: 0008669: 外网密码登陆失败后，跳转到需要输入验证码界面,始终跳转到手机验证码页面
         *@date:20140504
         */
         if($_REQUEST['loginajax'] == 'yes'){
            $returnarr['href'] = "index.php?action=LoginCheck&module=Users&login_method=true&languageType=".$_REQUEST['languageType'];
            ConvertTojsonString(1,array('href'=>"index.php?action=LoginCheck&module=Users&login_method=true&languageType=".$_REQUEST['languageType']),"success");
        }
        header("Location: index.php?action=LoginCheck&module=Users&login_method=true&languageType=".$_REQUEST['languageType']);
    }

}

//登录失败，信息
function AuthenticateLoginUnSuccessful($code,$array,$msg)
{
    header_remove("Set-Cookie"); // 移除失败时的任何会话设置
    //http_response_code(401); // 登录失败返回 401
    //生成新的tokenrand
    $tokenrand = bin2hex(random_bytes(8)).'|'.time();
    $_SESSION[md5(globalStatic::$root_directory.'tokenrand')]=$tokenrand;
    if(is_array($array)){
        $array['ldtokenrand'] = $tokenrand;
    }
    ConvertTojsonString($code,$array,$msg);
}

/**
 * 如果数据库配置变更，则清空缓存
 * @author Tujt 2014-08-28
 */
function checkisunsetCache() {
    global $current_user,$adb;
    //清空菜单缓存
	//$cachekey = 'cache_getparenttabrelinfo';
	//unsetCache($cachekey);
  //  $cachekey = 'cache_getannouncement';
   // unsetCache($cachekey);//清空滚动信息缓存
	global $dbconfig;
	$cachekey = 'cache_checkisunsetcache';
	$cache_dbconfig = MemoryCache($cachekey);
//	if(!$cache_dbconfig){
	//	MemoryCache($cachekey,$dbconfig);
//	}else{
		$iscache = false;
      
	if(is_array($cache_dbconfig))
  		foreach($dbconfig as $key=>$config){
  			if(!isset($cache_dbconfig[$key]) || $cache_dbconfig[$key] != $config){
  				$iscache = true;break;
  			}
  		}
    if(!$cache_dbconfig)
 	   MemoryCache($cachekey,$dbconfig);
     
      $sql='select * from ld_version ';
      $result=$adb->pquery($sql,array());
      
      $currentversion=$adb->query_result($result,0,'current_version');
      $versiontype=$adb->query_result($result,0,'versiontype');
       $prevversioninfo=getVersionInfo();
       if($prevversioninfo['current_version']!=$currentversion||$versiontype!=$prevversioninfo['versiontype'])
       {
        //版本号改变或者版本（企业版，标准版)改变
            $iscache=true;
       }
       
		if($iscache){//配置做了变更
               
                 clearAllCache();
                 //23579: 登录的时候删除 tabdata.php parent_tabdata.php 文件
                create_parenttab_data_file();
                setFixedLable($current_user);//重新生成语言包
                setJsPopLabel($current_user);
                createUserPrivilegesfile($current_user->id,'');//如果数据库变更后则重新生成user_privileges
		        deleteUserPrivileges();
                MemoryCache($cachekey,$dbconfig);
		}
        else
        {
            require_once globalStatic::$root_directory.'modules/Cache/checkDeleteCash.php';
        
            if(checkDeleteCache()=='yes')
            {
                setFixedLable($current_user);//重新生成语言包
                setJsPopLabel($current_user);
                
            }
        }
        getVersionInfo();
	//}
  

    /*deldir(globalStatic::$root_directory."modules/Leads");
    deldir(globalStatic::$root_directory."modules/Yahoo");
    deldir(globalStatic::$root_directory."modules/Rss");
    deldir(globalStatic::$root_directory."modules/WSAPP");
    deldir(globalStatic::$root_directory."modules/com_lingdang_workflow");
    deldir(globalStatic::$root_directory."modules/GraphicalReports");
    deldir(globalStatic::$root_directory."modules/Services");
    deldir(globalStatic::$root_directory."modules/Assets");
    deldir(globalStatic::$root_directory."modules/Migration");
    deldir(globalStatic::$root_directory."modules/Import");
    deldir(globalStatic::$root_directory."modules/Webforms");
    deldir(globalStatic::$root_directory."modules/Report");
    eldir(globalStatic::$root_directory."modules/Tooltip");
    deldir(globalStatic::$root_directory."include/ckeditor");
    deldir(globalStatic::$root_directory."include/LanguageTranslate");
    deldir(globalStatic::$root_directory."include/Webservices");*/
    
    
    
}
function deldir($dir) {
  //先删除目录下的文件：
  $dh=opendir($dir);
  while ($file=readdir($dh)) {
    if($file!="." && $file!="..") {
      $fullpath=$dir."/".$file;
      if(!is_dir($fullpath)) {
          unlink($fullpath);
      } else {
          deldir($fullpath);
      }
    }
  }
  
  closedir($dh);
  //删除当前文件夹：
  if(rmdir($dir)) {
    return true;
  } else {
    return false;
  }
}
//默认false表示加密，传入true表示解密

?>