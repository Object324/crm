<?php

global $current_user;


  /**
    *@author:andy
    *@data:20141014
    *@reason:登录短信验证
    *@version:V5.8
    */
  //云之家网页端 跳转的域名 -传参获得
$corpurl = $_REQUEST['corpurl'];
$corpurl = empty($corpurl)?'':$corpurl;
$focus=$current_user;
//新增判断，体验用户登陆手机验证登陆login_method=2、直接登录login_method=1
if(!$focus->login_sms || $_REQUEST['login_method'] == 1 || $_REQUEST['login_method'] == 2){
		$version_info = getVersionInfo();
		/** 赛克
		 * edit: chj
		 * date: 2020/7/28
		 * reason: crm登录后，直接跳转到saic路径下，显示拨号
		 */
		if($version_info['account'] == 'saic'){
			if(isset($_SESSION['lastpage'])){
                if($_REQUEST['loginajax'] == 'yes'){
                    ConvertTojsonString(2,array('href'=>'saic/index.php?'),'success');
                }
				header("Location: saic/index.php?".$arr);
			}else{
                if($_REQUEST['loginajax'] == 'yes'){
                    ConvertTojsonString(2,array('href'=>'saic/index.php?a=1'),'success');
                }
				header("Location: saic/index.php?a=1");
			}
		}else{
			if(isset($_SESSION['lastpage'])){
			    if($_REQUEST['loginajax'] == 'yes'){
                    ConvertTojsonString(1,array('href'=>$corpurl."index.php?".$arr),'success');
                }
				header("Location: ".$corpurl."index.php?".$arr);
			}else{
    			if($_REQUEST['loginajax'] == 'yes'){
                    ConvertTojsonString(1,array('href'=>$corpurl."index.php?a=1"),'success');
                }
				header("Location: ".$corpurl."index.php?a=1");
			}
		}
    	
    }else{
        if($focus->SmsLoginCheck24Hours()){
            //手机验证码24小时内登陆过，则无需验证，写入登陆日志
            $usip=LoginHistory::getIp();
			if($usip=='127.0.0.1'){
				$usip= gethostbyname($_SERVER["SERVER_NAME"]);  
			}
			/*齐心 阿里云
            $computername=exec ('nbtstat -A'.' '.$usip.' | find /i "20"');
			$UserName=(preg_split("/\s+/", trim($computername)));
			$machinename=$UserName[0];*/
            
			if(empty($machinename)){
				$machinename=gethostbyaddr($usip);    //获取主机名 
			}
            $intime=date("Y/m/d H:i:s");
            require_once('modules/Users/LoginHistory.php');
            $loghistory=new LoginHistory();
            $Signin = $loghistory->user_login($focus->column_fields["user_name"],$usip,$intime,'','',$machinename,0,'','','');
            if($_REQUEST['loginajax'] == 'yes'){
                $tmpparam = (isset($_SESSION['lastpage']))?$arr:'';
                ConvertTojsonString(1,array('href'=>$corpurl."index.php?a=1".$tmpparam),'success');
            }
            if(isset($_SESSION['lastpage']))
        		header("Location: ".$corpurl."index.php?".$arr);
        	else
        		header("Location: ".$corpurl."index.php");
        }else{
            if($_REQUEST['loginajax'] == 'yes'){
                $tmpparam = (isset($_SESSION['lastpage']))?$arr:'';
                ConvertTojsonString(2,array('href'=>$corpurl."UserSMSLogin.php"),'success');
            }
            header("Location:".$corpurl."UserSMSLogin.php");//登陆用户需要短信验证码

        }
    }

?>