<?php

global $current_user;
$focus=$current_user;
CreateUseLanguageType($focus);
$type='authen';
    if(file_exists(globalStatic::$root_directory.'user_privileges/user_privileges_'.$current_user->id.'.php'))
    {
      
       $user_info=getuserInfoByPrivileges($current_user);
        if($user_info['user_password']!=$current_user->user_password
            ||$user_info['profileid']!=$current_user->profileid
            ||$user_info['status']!=$current_user->status
            ||$user_info['edit_other_mobile']!=$current_user->edit_other_mobile
            ||$user_info['edit_me_mobile']!=$current_user->edit_me_mobile)
        {
            
            //如果用户登录成功，但是缓存文件的密码或角色和数据库不一样重新生成缓存文件
            $type='';
        }
    }
    else{
        $type='';
        
    }
	//浏览器可见区块宽度
	$_SESSION['bodywidth'] = $_REQUEST['bodywidth'];
    crm_load_function_file("createUserPrivilegesfile",'modules/Users','CreateUserPrivilegeFile');
    
    createUserPrivilegesfile($focus->id,$type);
     
    // require_once(globalStatic::$root_directory."appCommon/appCommon.php");
     require_once(globalStatic::$root_directory."include/utils/LoginFun.php");
     if(judgeCorpInfo("kehu001")===false)
      {
          
    	//调用登录执行函数
    	checkisunsetCache();
      }
    //每天执行	
     execDaysQuery();
     //edit:can 2020-10-13 php7 redis 
   // session_regenerate_id(false);
    
 
      
    /**
     * @author:andy
     * @reason:手机验证登陆时登陆日志写入延后
     */
    //新增判断，体验用户登陆手机验证登陆login_method=2、直接登录login_method=1
    if(!$focus->login_sms || $_REQUEST['login_method'] == 1 || $_REQUEST['login_method'] == 2){//未开始手机验证码登陆直接写入登陆日志
        $usip = LoginHistory::getIp();
		if($usip=='127.0.0.1'){
			$usip= gethostbyname($_SERVER["SERVER_NAME"]);
		}
	/*	$computername=exec ('nbtstat -A'.' '.$usip.' | find /i "20"');
       echo $computername;
      
		$UserName=(preg_split("/\s+/", trim($computername)));
		$machinename=$UserName[0];
		if(empty($machinename)){
			$machinename=gethostbyaddr($usip);    //获取主机名 
		}*/
        //editor:gyq_92 reason:系统设置登录日志查询增加分类功能  2018/12/18 18:04
        //require globalStatic::$root_directory . 'modules/Users/LoginHistory.php';
        crm_load_class_file('LoginHistory','modules/Users');
        $loghistory = new LoginHistory();
        $intime = date('Y/m/d H:i:s');
        //'qrcodeweixin'=>'PC端企业微信扫码登录','pcqiyeweixin'=>'企业微信PC端登录',''=>'PC端登录'
        $tmp_login_check = time().rand(100000,999999);
        $_SESSION['login_check'] = $tmp_login_check;
        if(isset($_REQUEST['dandian_weixin'])){
            if(empty($_REQUEST['qiyeweixinqrcode'])||$_REQUEST['qiyeweixinqrcode']=='no'){
                $login_type = 'pcqiyeweixin';
            }else{
                $login_type = 'qrcodeweixin';
                
            }
            if($_REQUEST['from_dingtalk']=='yes'){
               
                    $login_type = 'pc_dingtalk';
                }
        }else {
            $login_type = '';
            if ($_REQUEST['from_yunzhijia']=='yes'){
                $login_type = 'pc_yunzhijia';
            }elseif($_REQUEST['from_fanwei']=='yes'){
                $login_type = 'pc_fanwei';
            }elseif($_REQUEST['from_zhiyuan']=='yes'){
                $login_type = 'pc_zhiyuan';
            }
        }
        $_SESSION['login_type'] = $login_type;
        $_SESSION['from_login_type']=$login_type;
        
        $Signin = $loghistory->user_login($focus->column_fields['user_name'], $usip, $intime, '', '', '', 0,$login_type,$tmp_login_check,'');
    }
    //注销SESSION？貌似可以用unset
    unset($_SESSION['login_password']);
    unset($_SESSION['login_error']);
    unset($_SESSION['login_user_name']);
    unset($_SESSION['login_usererror']);
    unset($_SESSION['RegOp']);
    unset($_SESSION['lingdang_User_Password']);
    unset($_SESSION[$root_directory]);
   
    if($_REQUEST['CheckPwdSuccess']=='yes')
    {
      
        include(globalStatic::$root_directory.'modules/Users/UserSMSLogin.php');
    }

?>