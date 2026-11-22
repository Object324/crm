<?php
	error_reporting(E_ALL & ~E_NOTICE);
	//表单登录验证
	if(!empty($_REQUEST['action']) && $_REQUEST['action'] == 'login_form'){
        include('includefile.php');
		header("Content-type: text/html; charset=utf-8");
		global $theme;
		global $adb;
		$username = $_REQUEST['username'];//身份证后6位
		$query = 'select accountid,license_no from ld_account where license_no like "%'.$username.'%" limit 1';
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			$is_true = false;
			for($i = 0; $i<$num_rows; $i++){
				$license_no = $adb->query_result($result,$i,'license_no');
				$accountid = $adb->query_result($result,$i,'accountid');
				if(substr($license_no, -6) == $username){
					@session_start();
					$_SESSION['huawan_account_id'] = $accountid;
					echo $_SESSION['huawan_account_id'];echo '<br><br>';
					$is_true = true;
					break;
				}
			}
			if(!$is_true){
				echo '1';exit();
			}
		}else{
			echo '1';exit();
		}

	}else{
		$str='0123456789';//验证码0~9组成
		for($i<0;$i<4;$i++){
		//随机生成四位验证码
			$start = rand(1,strlen($str) - 1);
			$codenum .=substr($str,$start,1);
			$randnum .= substr($str,$start,1).','; 
		}
		$randnum=substr($randnum,0,strlen($randnum)-1);
	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>华万控股集团</title>
<meta name="keywords" content="华万集团 华万控股 华万控股集团 北京华万 华万基金 华万" />
<meta name="description" content="" />
<script src="huawangroup/js/jquery-1.11.2.min.js" type="text/javascript"></script>
<script type="text/javascript" src="huawangroup/js/login.js"></script>
<link rel="stylesheet" type="text/css"  href="huawangroup/css/style.css"/>
</head>
<body>
	<div class="huawan_log"></div>
	<div class="login">
    <div class="login-title">投资产品及派息信息查询</div>
    <div class="login-input-content">
		<input type="hidden" name="code_num" id="code_num" value="<?php echo $codenum;?>" />
        <div class="login-input">
            <input type="text" placeholder="请输入身份证后6位"  name="username" id="username" class="list-input"/>
        </div>
        <div id="secutity" class="login-input">
            <input type="text" placeholder="验证码" name="secutity_code" id="secutity_code" class="list1-input"/>
			<img src="picture.php?code=<?php echo $randnum;?>" id="change-secutity-img" class="val_m img_b" style="margin-left:4px" width="79" height="29" />
            <a href="javascript:void(0);" style="color:#2E7ECD" id="change-secutity-code">换一张</a>
        </div>
    </div>
    <div class="login-button"><a href="javascript:void(0);" id="login-button-submit">登录</a></div>
</div>
</body>
</html>