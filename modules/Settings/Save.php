<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $mod_strings,$adb;
$server=vtlib_purify($_REQUEST['server']);
$port=vtlib_purify($_REQUEST['port']);
$server_username=vtlib_purify($_REQUEST['server_username']);
$server_password=vtlib_purify($_REQUEST['server_password']);
$server_type = vtlib_purify($_REQUEST['server_type']);
$server_path = vtlib_purify($_REQUEST['server_path']);
$from_email_field = vtlib_purify($_REQUEST['from_email_field']);
$smtp_ssl=vtlib_purify($_REQUEST['smtp_ssl']);
$db_update = true;

if($_REQUEST['smtp_auth'] == 'on' || $_REQUEST['smtp_auth'] == 1)
	$smtp_auth = 'true';
else
	$smtp_auth = 'false';
	
$sql="select * from ld_systems where server_type = ?";
$id=$adb->query_result($adb->pquery($sql, array($server_type)),0,"id");

if($server_type == 'proxy')
{
	$action = 'ProxyServerConfig&proxy_server_mode=edit';
	if (!$sock =@fsockopen($server, $port, $errno, $errstr, 30))
	{
		$error_str = 'error=无法连接 "'.$server.':'.$port.'"';
		$db_update = false;
	}else
	{
		$url = "http://www.google.co.in";
		$proxy_cont = '';
        
		$sock = fsockopen($server, $port);
		if (!$sock)    {return false;}
		fputs($sock, "GET $url HTTP/1.0\r\nHost: $server\r\n");
		fputs($sock, "Proxy-Authorization: Basic " . base64_encode ("$server_username:$server_password") . "\r\n\r\n");
		while(!feof($sock)) {$proxy_cont .= fread($sock,4096);}
		fclose($sock);
		$proxy_cont = substr($proxy_cont, strpos($proxy_cont,"\r\n\r\n")+4);
		
		if(substr_count($proxy_cont, "Cache Access Denied") > 0)
		{
			$error_str = 'error=LBL_PROXY_AUTHENTICATION_REQUIRED';
			$db_update = false;
		}
		else
		{
			$action = 'ProxyServerConfig';
		}
	}
}

if($server_type == 'ftp_backup')
{
	$action = 'BackupServerConfig&bkp_server_mode=edit&server='.$server.'&server_user='.$server_username.'&password='.$server_password;
	if(!function_exists('ftp_connect')){
		$error_str = 'error=FTP支持不启用.';
		$db_update = false;
	}else
	{	  
		$conn_id = @ftp_connect($server);
		if(!$conn_id)
		{
			$error_str = 'error=无法连接 "'.$server.'"';
			$db_update = false;
		}else
		{
			if(!@ftp_login($conn_id, $server_username, $server_password))
			{
				$error_str = 'error=不能连接到 "'.$server.'" as user "'.$server_username.'"';
				$db_update = false;
			}
			else
			{
				$action = 'BackupServerConfig';
			}
			ftp_close($conn_id);
		}
	}
}
if($server_type == 'local_backup')
{
	$action = 'BackupServerConfig&local_server_mode=edit&server_path="'.$server_path.'"';
	if(!is_dir($server_path)){
		//$error_str = 'error1=Folder doesnt Exist or Specified a path which is not a folder';
        $error_str = 'error1=指定的路径不对';
		$db_update = false;
	}else
	{
		if(!is_writable($server_path))
		{
			$error_str = 'error1=拒绝访问 "'.$server_path.'"';
			$db_update = false;
		}else
		{
			$action = 'BackupServerConfig';
		}
	}
}

if($server_type == 'proxy' || $server_type == 'ftp_backup' || $server_type == 'local_backup'||$server_type=='email')
{
	if($db_update)
	{
		if($id=='') {
			$id = $adb->getUniqueID('ld_systems');
			$sql="insert into ld_systems(id,server,server_port,server_username,server_password,server_type,smtp_auth,server_path,from_email_field,smtp_ssl) values(?,?,?,?,?,?,?,?,?,?)";
			$params = array($id, $server, $port, $server_username, $server_password, 
                $server_type, $smtp_auth,$server_path,$from_email_field,$smtp_ssl);
		}
		else {
			$sql="update ld_systems set server = ?, server_username = ?, server_password = ?, smtp_auth= ?,
             server_type = ?, server_port= ?, server_path = ?, from_email_field=?,smtp_ssl=? where id = ?";
			$params = array($server, $server_username, $server_password, $smtp_auth, $server_type
            , $port, $server_path,$from_email_field,$smtp_ssl, $id);
		}
		$adb->pquery($sql, $params);
	}
}
//Added code to send a test mail to the currently logged in user
if($server_type != 'ftp_backup' && $server_type != 'proxy' && $server_type != 'local_backup')
{
   
	require_once("modules/Emails/mail.php");
	global $current_user;

	$to_email = getUserEmailId('id',1);
    
    /**
     * AUTHOR:BY LD KEVIN
     * Date:2013-04-22
     * Description:设置smtp服务器时，发件人地址是smtp设置的地址，收件人是管理员的邮箱地址
     */ 
	$from_email = $server_username;
  
	$subject = 'Test mail about the mail server configuration.';
	$description = 'Dear '.$current_user->user_name.', <br><br><b> This is a test mail sent to confirm if a mail is actually being sent through the smtp server that you have configured. </b><br>Feel free to delete this mail.<br><br>Thanks  and  Regards<br><br>';
	if($to_email != '')
	{

		$mail_status = send_mail('Users',$to_email,$current_user->user_name,$from_email,$subject,$description);
     
		$mail_status_str = $to_email."=".$mail_status."&&&";
	}
	else
	{
		$mail_status_str = "'".$to_email."'=0&&&";
	}
	$error_str = getMailErrorString($mail_status_str);

	$action = 'EmailConfig';
	if($mail_status != 1) {
		$action = 'EmailConfig&emailconfig_mode=edit&server_name='.
			vtlib_purify($_REQUEST['server']).'&server_user='.
			vtlib_purify($_REQUEST['server_username']).'&auth_check='.
			vtlib_purify($_REQUEST['smtp_auth']);
	}
	else{
         
		if($db_update)
        	{
                	if($id=='') {
                        $id = $adb->getUniqueID("ld_systems");
                        $sql="insert into ld_systems values(?,?,?,?,?,?,?,?,?)";
						$params = array($id, $server, $port, $server_username, $server_password, $server_type, $smtp_auth, '',$from_email_field);
                	} else {
                        $sql="update ld_systems set server=?, server_username=?, server_password=?, smtp_auth=?, server_type=?, server_port=?,from_email_field=? where id=?";
                		$params = array($server, $server_username, $server_password, $smtp_auth, $server_type, $port,$from_email_field,$id);
					}
				$adb->pquery($sql, $params);
        	}	
	}
}
$_REQUEST['diony']='diony';
if(!empty($error_str)){
	if(strpos($error_str,'mail_error=') !== false){
		$error_msg = getFixedLabel('MAILSENDERROR');
		$error_str = getFixedLabel('TESTMAILSTATUS').' <b><font class="warning">'.$error_msg.'</font></b>';
	}
	ConvertTojsonString(-1,array('error'=>$error_str),"");
}else{
	ConvertTojsonString(1,array(),"success");
}
?>