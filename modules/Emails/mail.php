<?php
/*********************************************************************************
**{*修改编码格式:统一编码：UTF-8*} 
* The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 ********************************************************************************/

require_once(globalStatic::$root_directory."include/PHPMailer/src/PHPMailer.php");
require_once(globalStatic::$root_directory."include/PHPMailer/src/SMTP.php");

//require_once(globalStatic::$root_directory."modules/Emails/class.phpmailer.php");


/**   Function used to send email
  *   $module 		-- current module
  *   $to_email 	-- to email address
  *   $from_name	-- currently loggedin user name
  *   $from_email	-- currently loggedin ld_users's email id. you can give as '' if you are not in HelpDesk module
  *   $subject		-- subject of the email you want to send
  *   $contents		-- body of the email you want to send
  *   $cc		-- add email ids with comma seperated. - optional
  *   $bcc		-- add email ids with comma seperated. - optional.
  *   $attachment	-- whether we want to attach the currently selected file or all lingdang_files.[values = current,all] - optional
  *   $emailid		-- id of the email object which will be used to get the ld_attachments
  */
function send_mail($module,$to_email,$from_name,$from_email,$subject,$contents,$cc='',$bcc='',$attachment='',$emailid='',$logo='',$sender='')
{
    
	global $adb, $log;
	global $root_directory;
	global $HELPDESK_SUPPORT_EMAIL_ID, $HELPDESK_SUPPORT_NAME;
    static $from_email_field;
    
  
    $subject = "=?UTF-8?B?".base64_encode($subject)."?=";
	$uploaddir = $root_directory ."/test/upload/";
    $adb->println("To id => '".$to_email."'\nSubject ==>'".$subject."'\nContents ==> '".$contents."'");
	//Get the email id of assigned_to user -- pass the value and name, name must be "user_name" or "id"(field names of ld_users lingdang_table)
	//$to_email = getUserEmailId('id',$assigned_user_id);
    
    /**
    * edit:chj
    * date:2014-3-6
    * reason: 邮件群发，收件人设置为密送，默认收件人为第一个
    **/
    if($_REQUEST['parenttab'] == 'Marketing')
    {
        $bcc = $to_email;
        $email_array = explode(',', $to_email);
        $to_email = $email_array[0];
        
    }
	//if module is HelpDesk then from_email will come based on support email id
	if($from_email == '') {
			//if from email is not defined, then use the useremailid as the from address
			$from_email = getUserEmailId('user_name',$from_name);
	}
    $mail = new PHPMailer();  
	//if the newly defined from email field is set, then use this email address as the from address
	//and use the username as the reply-to address
   // if(empty($from_email_field))
    //{
        	$query = "select * from ld_systems where server_type=?";
    	$params = array('email');
    	$result = $adb->pquery($query,$params);
         if($adb->database->_errorMsg!='')
        {
             $errormsg=$adb->database->_errorMsg;
             unset($adb);
             $adb = new PearDatabase();;//::getInstance();
             $adb->connect();
       	    $result = $adb->pquery($query,$params);
           // $sql='insert into ld_adblog(errormsg,crmid,createdtime,`sql`)value(?,?,?,?)';
            //$adb->pquery($sql,array($errormsg,$approvelog['crmid'],date("Y-m-d H:i:s"),$query));
            
        }
        //edit:can 2020-10-12 邮件服务器设置增加“SSL”配置参数
    	$from_email_field = $adb->query_result($result,0,'from_email_field');
         $mail->isSMTP();
        // smtp需要鉴权 这个必须是true
        $mail->SMTPAuth = $adb->query_result($result,0,'smtp_auth');
        if( $adb->query_result($result,0,'smtp_auth')=='false')
        {
            $mail->SMTPAuth=false;
        }
        $mail->isHTML(true);
     // $mail->SMTPDebug = 1;
        $mail->Password = $adb->query_result($result,0,'server_password');
      
        if($adb->query_result($result,0,'smtp_ssl')=='yes')
        {   //$mail
            //$mail->Host ="ssl://".$adb->query_result($result,0,'server').":465";
            $mail->Port=465;
            $mail->Host=$adb->query_result($result,0,'server');
              
            $mail->SMTPSecure = 'ssl';
        }
        else{
            $mail->Port=25;
            $mail->SMTPSecure='none';
            $mail->Host=$adb->query_result($result,0,'server');;
            
        }
  //  }
  //edit:luyx 2021-11-05 邮件服务器设置 SMTP 服务器设置为 smtp.ismail.cn 连不上
$mail->SMTPOptions = array(
	'ssl' => array(
		'verify_peer' => false,
		'verify_peer_name' => false,
		'allow_self_signed' => true
		)
	);
  // 设置发送的邮件的编码
    $mail->CharSet = 'UTF-8';
      //dump($mail->Host);
	if(isUserInitiated()) {
		$replyToEmail = $from_email;
	} else {
		$replyToEmail = $from_email_field;
	}

	if($module != "Calendar")
		$contents = addSignature($contents,$from_name);

	
  
	setMailerProperties($mail,$subject,$contents,$from_email,$from_name,trim($to_email,","),$attachment,$emailid,$moduleo,'',$sender);

	setCCAddress($mail,'cc',$cc);
	setCCAddress($mail,'bcc',$bcc);
 
	if(!empty($replyToEmail)) {
		$mail->AddReplyTo($replyToEmail);
	}

	// vtmailscanner customization: If Support Reply to is defined use it.
	global $HELPDESK_SUPPORT_EMAIL_REPLY_ID;
	if($HELPDESK_SUPPORT_EMAIL_REPLY_ID && $HELPDESK_SUPPORT_EMAIL_ID != $HELPDESK_SUPPORT_EMAIL_REPLY_ID) {
		$mail->AddReplyTo($HELPDESK_SUPPORT_EMAIL_REPLY_ID);
	}
	// END

	// Fix: Return immediately if Outgoing server not configured
    if(empty($mail->Host)) {
		return 0;
    }
    // END
	$mail_status = MailSend($mail);
 
	if($mail_status != 1)
	{
	  // $mail->language='zh';
       
		$mail_error = getMailError($mail,$mail_status,$mailto);
	}
	else
	{
		$mail_error = $mail_status;
	}

    //dump('www');
	return $mail_error;
}

/**	Function to get the user Email id based on column name and column value
  *	$name -- column name of the ld_users lingdang_table
  *	$val  -- column value
  */
function getUserEmailId($name,$val)
{
	global $adb;
	$adb->println("Inside the function getUserEmailId. --- ".$name." = '".$val."'");
	if($val != '')
	{
		//done to resolve the PHP5 specific behaviour
		$sql = "SELECT email1, email2, secondaryemail  from ld_users WHERE status='Active' AND ". $adb->sql_escape_string($name)." = ?";
		$res = $adb->pquery($sql, array($val));
		$email = $adb->query_result($res,0,'email1');
		if($email == '')
		{
			$email = $adb->query_result($res,0,'email2');
			if($email == '')
			{
				$email = $adb->query_result($res,0,'secondaryemail ');
			}
		}
		$adb->println("Email id is selected  => '".$email."'");
		return $email;
	}
	else
	{
		$adb->println("User id is empty. so return value is ''");
		return '';
	}
}

/**	Funtion to add the user's signature with the content passed
  *	$contents -- where we want to add the signature
  *	$fromname -- which user's signature will be added to the contents
  */
function addSignature($contents, $fromname)
{
	global $adb;
	/*$adb->println("Inside the function addSignature");

	$sign = nl2br($adb->query_result($adb->pquery("select signature from ld_users where user_name=?", array($fromname)),0,"signature"));
	if($sign != '')
	{
		$contents .= '<br><br>'.$sign;
		$adb->println("Signature is added with the body => '.".$sign."'");
	}
	else
	{
		$adb->println("Signature is empty for the user => '".$fromname."'");
	}*/
	return $contents;
}

/**	Function to set all the Mailer properties
  *	$mail 		-- reference of the mail object
  *	$subject	-- subject of the email you want to send
  *	$contents	-- body of the email you want to send
  *	$from_email	-- from email id which will be displayed in the mail
  *	$from_name	-- from name which will be displayed in the mail
  *	$to_email 	-- to email address  -- This can be an email in a single string, a comma separated
  *			   list of emails or an array of email addresses
  *	$attachment	-- whether we want to attach the currently selected file or all lingdang_files.
  				[values = current,all] - optional
  *	$emailid	-- id of the email object which will be used to get the ld_attachments - optional
  */
function setMailerProperties($mail,$subject,$contents,$from_email,$from_name,$to_email,$attachment='',$emailid='',$module='',$logo='',$sender='')
{
	global $adb,$currentModule;
	$adb->println("Inside the function setMailerProperties");
	$mail->ishtml(true); 
	if($module == "Support" || $logo ==1)
		$mail->AddEmbeddedImage('themes/images/logo_mail.jpg', 'logo', 'logo.jpg',"base64","image/jpg");
	//0019002: （http://51mis.com/yuntou [^]）群发邮件：文本编辑控件，点击上传图片，群发邮件后。结果：接收人图片显示失败。
	if('Emails' == $currentModule){
		if(!empty($emailid)){
			$query = 'select description from ld_activity where activityid = ? limit 1';
			$result = $adb->pquery($query,array($emailid));
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				$description = $adb->query_result($result,0,'description');
				$desc = explode('src=',$description);
				for($i = 0; $i<count($desc); $i++){
					$imgpath[] = explode(' title',$desc[$i]);
				}
				$cnt = 1;
				foreach($imgpath as $val){
					if(count($val) > 1){
						for($i = 0; $i<count($val); $i++){
							$imagearr = explode('storage/ueditor/image',$val[$i]);
							if(count($imagearr) > 1){
								$scr = explode('src=',$imagearr[0]);
								$newstr = substr($imagearr[1],0,strlen($imagearr[1])-6);
								//$mail->AddEmbeddedImage('storage/ueditor/image/20151118/1447840948671080.jpg', 'Image', 'logo.jpg',"base64","image/jpg");
								$description = str_replace($scr[0] . 'storage/ueditor/image'.$newstr,'"cid:Image'.$cnt,$description);
								$mail->AddEmbeddedImage( 'storage/ueditor/image'.$newstr.'', 'Image'.$cnt.'', 'logo.jpg',"base64","image/jpg");
								$mail->Body =$description;
								$cnt++;
								//$imgarr[] = $newstr;
							}else{
								$mail->Body =$description;
							}
						}
					}else{
						$mail->Body =$description;
					}
				}
			}else{//0025982: 群发邮件 邮件内容收不到 只能看到主题
			     $mail->Body = $contents;
			}
		}
	}else{
		$mail->Body = $contents;
	}
   //$mail->Body= $mail->msgHTML($mail->Body,globalStatic::$root_directory);
	$mail->Subject = $subject;
	//$mail->Body = html_entity_decode(nl2br($contents));	//if we get html tags in mail then we will use this line
	$mail->AltBody = strip_tags(preg_replace(array("/<p>/i","/<br>/i","/<br \/>/i"),array("\n","\n","\n"),$contents));

	$mail->IsSMTP();		//set mailer to use SMTP
	//$mail->Host = "smtp1.example.com;smtp2.example.com";  // specify main and backup server
 
	setMailServerProperties($mail);

	//Handle the from name and email for HelpDesk
	$mail->From = $from_email;
    /**
     * edit:kevin
     * Date:2013-04-22
     * reason:不在取用户的姓名
     */ 
	/*$rs = $adb->pquery("select first_name,last_name from ld_users where user_name=?", array($from_name));
	$num_rows = $adb->num_rows($rs);
	if($num_rows > 0)
		$from_name = getFullNameFromQResult($rs, 0, 'Users');*/

	$mail->FromName =$from_email;
  // echo $sender;echo '<br><br>';
    if(!empty($sender))
	$mail->Sender=$sender;
    else 
    $mail->Sender=$from_email;
 
	if($to_email != '')
	{
		if(is_array($to_email)) {
			for($j=0,$num=count($to_email);$j<$num;$j++) {
    			 $toemail=$to_email[$j];
    			 if(strstr($to_email[$j],'>'))
                 {
                    $strgt=strpos($to_email[$j],'<');
                     $stqt=strpos($to_email[$j],'>');
                     $toemail=substr($to_email[$j],$strgt+1,$stqt-$strgt-1);
                 }
              
				$mail->addAddress($to_email[$j]);
			}
		} else {
			$_tmp = explode(",",$to_email);    
              
			for($j=0,$num=count($_tmp);$j<$num;$j++) {
			 
                 $toemail=$_tmp[$j];
    			 if(strstr($_tmp[$j],'>'))
                 {
                    $strgt=strpos($_tmp[$j],'<');
                     $stqt=strpos($_tmp[$j],'>');
                     $toemail=substr($_tmp[$j],$strgt+1,$stqt-$strgt-1);
                 }
                
				$mail->addAddress($toemail);
			}
		}
	}
      
	//commented so that it does not add from_email in reply to
	//$mail->AddReplyTo($from_email);
	$mail->WordWrap = 50;

	//If we want to add the currently selected file only then we will use the following function
	if($attachment == 'current' && $emailid != '')
	{
		if (isset($_REQUEST['filename_hidden'])) {
			$file_name = $_REQUEST['filename_hidden'];
		} else {
			$file_name = $_FILES['filename']['name'];
		}
		addAttachment($mail,$file_name,$emailid);
	}

	//This will add all the lingdang_files which are related to this record or email
	if($attachment == 'all' && $emailid != '')
	{
		addAllAttachments($mail,$emailid);
	}

	$mail->IsHTML(true);		// set email format to HTML

	return;
}

/**	Function to set the Mail Server Properties in the object passed
  *	$mail -- reference of the mailobject
  */
function setMailServerProperties($mail)
{
	global $adb;
    static $res_result;
    
    if(empty($res_result))
	{
	   $res = $adb->pquery("select * from ld_systems where server_type=?", array('email'));
       $res_result=$res;
	}
	
    else
    {
        $res=$res_result;
    }
	if(isset($_REQUEST['server']))
		$server = $_REQUEST['server'];
	else
		$server = $adb->query_result($res,0,'server');
	if(isset($_REQUEST['server_username']))
		$username = $_REQUEST['server_username'];
	else
	        $username = $adb->query_result($res,0,'server_username');
	if(isset($_REQUEST['server_password']))
		$password = $_REQUEST['server_password'];
	else
        	$password = $adb->query_result($res,0,'server_password');
	// Prasad: First time read smtp_auth from the request
	$smtp_auth = 'true';
	if(isset($_REQUEST['smtp_auth']))
	{
		$smtp_auth = $_REQUEST['smtp_auth'];
		if($smtp_auth == 'on')
			$smtp_auth = 'true';
	}
	else if (isset($_REQUEST['module']) && $_REQUEST['module'] == 'Settings' && (!isset($_REQUEST['smtp_auth'])))
	{
		//added to avoid issue while editing the values in the outgoing mail server.
		$smtp_auth = 'false';
	}
	 else
		$smtp_auth = $adb->query_result($res,0,'smtp_auth'); 
	
	$adb->println("Mail server name,username & password => '".$server."','".$username."','".$password."'");
	if($smtp_auth == "true"){
		$mail->SMTPAuth = true;	// turn on SMTP authentication
	}
	$mail->Host = $server;		// specify main and backup server
	$mail->Username = $username ;	// SMTP username
        $mail->Password = $password ;	// SMTP password

	return;
}

/**	Function to add the file as attachment with the mail object
  *	$mail -- reference of the mail object
  *	$filename -- filename which is going to added with the mail
  *	$record -- id of the record - optional
  */
function addAttachment($mail,$filename,$record)
{
	global $adb, $root_directory;
	$adb->println("Inside the function addAttachment");
	$adb->println("The file name is => '".$filename."'");

	//This is the file which has been selected in Email EditView
        if(is_file($filename) && $filename != '')
        {
                $mail->AddAttachment($root_directory."test/upload/".$filename);
        }
}

/**     Function to add all the lingdang_files as attachment with the mail object
  *     $mail -- reference of the mail object
  *     $record -- email id ie., record id which is used to get the all ld_attachments from database
  */
function addAllAttachments($mail,$record)
{
	global $adb, $root_directory;
        $adb->println("Inside the function addAllAttachments");

	//Retrieve the lingdang_files from database where avoid the file which has been currently selected
	$sql = "select ld_attachments.* from ld_attachments inner join ld_seattachmentsrel on ld_attachments.attachmentsid = ld_seattachmentsrel.attachmentsid inner join ld_crmentity on ld_crmentity.crmid = ld_attachments.attachmentsid where ld_seattachmentsrel.crmid=?";
    $res = $adb->pquery($sql, array($record));
	$count = $adb->num_rows($res);
	if($count >= 1){
		for($i=0;$i<$count;$i++)
		{
			$fileid = $adb->query_result($res,$i,'attachmentsid');
			$filename = decode_html($adb->query_result($res,$i,'name'));
			$filepath = $adb->query_result($res,$i,'path');
			//$encode = mb_detect_encoding($filename, array("ASCII","UTF-8","GB2312","GBK")); 
			//0013977: 邮件管理--明细：写信，附件为excel表格时，发送。收件人，收不到此附件。
			if(strtolower(PHP_OS)!='freebsd'&&strtolower(PHP_OS)!='linux'&&strtolower(PHP_OS)!='unix'){
				$encode = mb_detect_encoding($filename, array("ASCII","UTF-8","GB2312","GBK"));
				/*if ($encode == "UTF-8")
				{                    
					$filename = iconv("UTF-8","GB2312",$filename);
				}*/
                $filename = mb_convert_encoding($filename, "utf-8", $encode);
			}
			$root_directory = str_replace('\\','/',$root_directory);
			$filewithpath = $root_directory.'/'.$filepath.$fileid."_".$filename;
	
		  
			if(is_file($filewithpath))
			{
			//$encode = mb_detect_encoding($filename, array("ASCII","UTF-8","GB2312","GBK"));
				//echo iconv("gb2312","utf-8",$filewithpath);
				$mail->AddAttachment($filewithpath,$filename);
			}
			else
			{
				$filewithpath = $root_directory.'/'.$filepath.$filename;
				$mail->AddAttachment($filewithpath,$filename);
				
			}
		}
	}
	/**
	 * 手动添加当前模块的打印模板附件
	 * @reason 0011749 邮件管理->收信：回复邮件时，点击【选择附件】按钮，程序没有反应
	 * @author Tujt 2014-09-28
	 */
	if(isset($_REQUEST['pdf_attachment']) && !empty($_REQUEST['pdf_attachment'])){
		/*$attachment = $_REQUEST['pdf_attachment'];
		$attachmentarr = explode('_',$attachment);
		$attachment = getTranstab($attachmentarr[0]).'_'.$attachmentarr[1];
		$pdf_attachment = mb_convert_encoding($_REQUEST['pdf_attachment'], 'GB2312','utf-8');
		$attachmentarr = explode('_',$pdf_attachment);
		$attachment = mb_convert_encoding(getTranstab($attachmentarr[0]),'GB2312','utf-8').'_'.$attachmentarr[1];
		$mail->AddAttachment("{$root_directory}/templatePrintFile/$pdf_attachment",$attachment);*/
		//echo $_REQUEST['printid'];echo '<br><br>';die;
		if(isset($_REQUEST['printid']) && $_REQUEST['printid'] > 0){
			global $adb, $root_directory;
			$attachment = $_REQUEST['pdf_attachment'];
			if(strtolower(PHP_OS)!='freebsd'&&strtolower(PHP_OS)!='linux'&&strtolower(PHP_OS)!='unix'){
				$encode = mb_detect_encoding($attachment, array("ASCII","UTF-8","GB2312","GBK")); 
				if ($encode == "UTF-8")
				{                    
					$attachment = iconv("UTF-8","GB2312",$attachment);
				}
			}
			$root_directory = str_replace('\\','/',$root_directory);
			
			$mail->AddAttachment($root_directory . "dataCache/$attachment",$attachment);
		}else{
			$attachment = $_REQUEST['pdf_attachment'];
			$attachmentarr = explode('-',$attachment);
			$dbQuery = "SELECT path FROM ld_attachments WHERE attachmentsid = ?" ;
			$result = $adb->pquery($dbQuery, array($attachmentarr[0])) or die("Couldn't get file list");
			$filepath = @$adb->query_result($result, 0, "path");
			$attachment = $attachmentarr[0] . '_'.$attachmentarr[1];
			$mail->AddAttachment("{$root_directory}/{$filepath}$attachment",$attachment);	
		}
	}
}

/**	Function to set the CC or BCC addresses in the mail
  *	$mail -- reference of the mail object
  *	$cc_mod -- mode to set the address ie., cc or bcc
  *	$cc_val -- addresss with comma seperated to set as CC or BCC in the mail
  */
function setCCAddress($mail,$cc_mod,$cc_val)
{
	global $adb;
	$adb->println("Inside the functin setCCAddress");

	if($cc_mod == 'cc')
		$method = 'AddCC';
	if($cc_mod == 'bcc')
		$method = 'AddBCC';
	if($cc_val != '')
	{
		$ccmail = explode(",",trim($cc_val,","));
		for($i=0;$i<count($ccmail);$i++)
		{
			$addr = $ccmail[$i];
			$cc_name = preg_replace('/([^@]+)@(.*)/', '$1', $addr); // First Part Of Email
			if(stripos($addr, '<')) {
				$name_addr_pair = explode("<",$ccmail[$i]);
				$cc_name = $name_addr_pair[0];
				$addr = trim($name_addr_pair[1],">");
			}
			if($ccmail[$i] != '')
				$mail->$method($addr,$cc_name);
		}
	}
}

/**	Function to send the mail which will be called after set all the mail object values
  *	$mail -- reference of the mail object
  */
function MailSend($mail)
{

	if(!$mail->Send())
        {
	
		return $mail->ErrorInfo;
        }
	else
	{
		 
		return 1;
	}
}

/**	Function to get the Parent email id from HelpDesk to send the details about the ticket via email
  *	$returnmodule -- Parent module value. Contact or Account for send email about the ticket details
  *	$parentid -- id of the parent ie., contact or lingdang_account
  */
function getParentMailId($parentmodule,$parentid)
{
	global $adb;
	$adb->println("Inside the function getParentMailId. \n parent module and id => ".$parentmodule."&".$parentid);

        if($parentmodule == 'Contacts')
        {
                $tablename = 'ld_contactdetails';
                $idname = 'contactid';
		$first_email = 'email';
		$second_email = 'secondaryemail';
        }
        if($parentmodule == 'Accounts')
        {
                $tablename = 'ld_account';
                $idname = 'accountid';
		$first_email = 'email1';
		$second_email = 'email2';
        }
	if($parentid != '')
	{
	   	//$query = 'select * from '.$tablename.' where '.$idname.' = '.$parentid;
	   	$query = 'select * from '.$tablename.' where '. $idname.' = ?';
		$res = $adb->pquery($query, array($parentid));
	    $mailid = $adb->query_result($res,0,$first_email);
		$mailid2 = $adb->query_result($res,0,$second_email);
	}
        if($mailid == '' && $mailid2 != '')
        	$mailid = $mailid2;

	return $mailid;
}

/**	Function to parse and get the mail error
  *	$mail -- reference of the mail object
  *	$mail_status -- status of the mail which is sent or not
  *	$to -- the email address to whom we sent the mail and failes
  *	return -- Mail error occured during the mail sending process
  */
function getMailError($mail,$mail_status,$to)
{
	//Error types in class.phpmailer.php
	/*
	provide_address, mailer_not_supported, execute, instantiate, file_access, file_open, encoding, data_not_accepted, authenticate,
	connect_host, recipients_failed, from_failed
	*/

	global $adb;
	$adb->println("Inside the function getMailError");
    //edit:can 2020-11-09 43163: (61mis.com/WX/kh41345)营销-群发邮件（客户问题）；选择联系人email添加后，操作群发邮件；页面会一直缓冲转圈，邮箱是已收到邮件的。
	$msg = array_search($mail_status,$mail->getTranslations());
	$adb->println("Error message ==> ".$msg);

	if($msg == 'connect_host')
	{
		$error_msg =  $msg;
	}
	elseif(strstr($msg,'from_failed'))
	{
		$error_msg = $msg;
	}
	elseif(strstr($msg,'recipients_failed'))
	{
		$error_msg = $msg;
	}
	else
	{
		$adb->println("Mail error is not as connect_host or from_failed or recipients_failed");
		//$error_msg = $msg;
	}

	$adb->println("return error => ".$error_msg);
	return $error_msg;
}

/**	Function to get the mail status string (string of sent mail status)
  *	$mail_status_str -- concatenated string with all the error messages with &&& seperation
  *	return - the error status as a encoded string
  */
function getMailErrorString($mail_status_str)
{
	global $adb;
	$adb->println("Inside getMailErrorString function.\nMail status string ==> ".$mail_status_str);

	$mail_status_str = trim($mail_status_str,"&&&");
	$mail_status_array = explode("&&&",$mail_status_str);
	$adb->println("All Mail status ==>\n".$mail_status_str."\n");

	foreach($mail_status_array as $key => $val)
	{
		$list = explode("=",$val);
		$adb->println("Mail id & status ==> ".$list[0]." = ".$list[1]);
		if($list[1] == 0)
		{
			$mail_error_str .= $list[0]."=".$list[1]."&&&";
		}
	}
	$adb->println("Mail error string => '".$mail_error_str."'");
	if($mail_error_str != '')
	{
		$mail_error_str = 'mail_error='.base64_encode($mail_error_str);
	}
	return $mail_error_str;
}

/**	Function to parse the error string
  *	$mail_error_str -- base64 encoded string which contains the mail sending errors as concatenated with &&&
  *	return - Error message to display
  */
function parseEmailErrorString($mail_error_str)
{
	//TODO -- we can modify this function for better email error handling in future
	global $adb, $mod_strings;
	$adb->println("Inside the parseEmailErrorString function.\n encoded mail error string ==> ".$mail_error_str);

	$mail_error = base64_decode($mail_error_str);
	$adb->println("Original error string => ".$mail_error);
	$mail_status = explode("&&&",trim($mail_error,"&&&"));
	foreach($mail_status as $key => $val)
	{
		$status_str = explode("=",$val);
		$adb->println('Mail id => "'.$status_str[0].'".........status => "'.$status_str[1].'"');
		if($status_str[1] != 1 && $status_str[1] != '')
		{
			$adb->println("Error in mail sending");
			if($status_str[1] == 'connect_host')
			{
				$adb->println("if part - Mail sever is not configured");
				$errorstr .= '<br><b><font color=red>'.$mod_strings['MESSAGE_CHECK_MAIL_SERVER_NAME'].'</font></b>';
				break;
			}
			elseif($status_str[1] == '0')
			{
				$adb->println("first elseif part - status will be 0 which is the case of assigned to ld_users's email is empty.");
				$errorstr .= '<br><b><font color=red> '.$mod_strings['MESSAGE_MAIL_COULD_NOT_BE_SEND'].' '.$mod_strings['MESSAGE_PLEASE_CHECK_FROM_THE_MAILID'].'</font></b>';
				//Added to display the message about the CC && BCC mail sending status
				if($status_str[0] == 'cc_success')
				{
                                        $cc_msg = 'But the mail has been sent to CC & BCC addresses.';
					$errorstr .= '<br><b><font color=purple>'.$cc_msg.'</font></b>';
				}
			}
			elseif(strstr($status_str[1],'from_failed'))
			{
				$adb->println("second elseif part - from email id is failed.");
				$from = explode('from_failed',$status_str[1]);
				$errorstr .= "<br><b><font color=red>".$mod_strings['MESSAGE_PLEASE_CHECK_THE_FROM_MAILID']." '".$from[1]."'</font></b>";
			}
			else
			{
				$adb->println("else part - mail send process failed due to the following reason.");
				$errorstr .= "<br><b><font color=red> ".$mod_strings['MESSAGE_MAIL_COULD_NOT_BE_SEND_TO_THIS_EMAILID']." '".$status_str[0]."'. ".$mod_strings['PLEASE_CHECK_THIS_EMAILID']."</font></b>";
			}
		}
	}
	$adb->println("Return Error string => ".$errorstr);
	return $errorstr;
}
	function insertIntoAttachment($module,$id) {
		global $adb;
		$file_saved = false;

		//Added to send generated Invoice PDF with mail
		$pdfAttached = $_REQUEST['pdf_attachment'];
		//created Invoice pdf is attached with the mail
		if (isset($_REQUEST['pdf_attachment']) && $_REQUEST['pdf_attachment'] != '') {
			$file_saved = pdfAttach($this, $module, $pdfAttached, $id);
		}

		//This is to added to store the existing attachment id of the contact where we should delete this when we give new image

		foreach ($_FILES as $fileindex => $files) {
			if ($files['name'] != '' && $files['size'] > 0) {
		      
				$files['original_name'] = vtlib_purify($_REQUEST[$fileindex . '_hidden']);                
				$file_saved = $this->uploadAndSaveFile($id, $module, $files);
			}
		}
          
		if ($module == 'Emails' && isset($_REQUEST['att_id_list']) && $_REQUEST['att_id_list'] != '') {
			$att_lists = explode(";", $_REQUEST['att_id_list'], -1);
			$id_cnt = count($att_lists);
			if ($id_cnt != 0) {
				for ($i = 0; $i < $id_cnt; $i++) {
					$sql_rel = 'insert into ld_seattachmentsrel values(?,?)';
					$adb->pquery($sql_rel, array($id, $att_lists[$i]));
				}
			}
		}
		if ($_REQUEST['att_module'] == 'Webmails') {
			require_once(globalStatic::$root_directory."modules/Webmails/Webmails.php");
			require_once(globalStatic::$root_directory."modules/Webmails/MailParse.php");
			require_once(globalStatic::$root_directory.'modules/Webmails/MailBox.php');
			//$mailInfo = getMailServerInfo($current_user);
			//$temprow = $adb->fetch_array($mailInfo);

			$MailBox = new MailBox($_REQUEST["mailbox"]);
			$mbox = $MailBox->mbox;
			$webmail = new Webmails($mbox, $_REQUEST['mailid']);
			$array_tab = Array();
			$webmail->loadMail($array_tab);
			if (isset($webmail->att_details)) {
				foreach ($webmail->att_details as $fileindex => $files) {
					if ($files['name'] != '' && $files['size'] > 0) {
						//print_r($files);
						$file_saved = $this->saveForwardAttachments($id, $module, $files);
					}
				}
			}
		}
	}
function isUserInitiated() {
	return (($_REQUEST['module'] == 'Emails' || $_REQUEST['module'] == 'Webmails') &&
			($_REQUEST['action'] == 'mailsend' || $_REQUEST['action'] == 'webmailsend' || $_REQUEST['action'] == 'Save'));
}

/**
 * Function to get the group users Email ids
 */
function getDefaultAssigneeEmailIds($groupId) {
	global $adb;
	$emails = Array();
	if($groupId != '') {
		require_once globalStatic::$root_directory.'include/utils/GetGroupUsers.php';//gyq_122
		$userGroups = new GetGroupUsers();
		$userGroups->getAllUsersInGroup($groupId);
		$result = $adb->pquery('SELECT email1,email2,secondaryemail FROM ld_users WHERE ld_users.id IN
											('.  generateQuestionMarks($userGroups->group_users).')',
								array($userGroups->group_users));
		$rows = $adb->num_rows($result);
		for($i = 0;$i < $rows; $i++) {
			$email = $adb->query_result($result,$i,'email1');
			if($email == '') {
				$email = $adb->query_result($result,$i,'email2');
				if($email == '') {
					$email = $adb->query_result($result,$i,'secondaryemail');
				} else {
					$email = '';
				}
			}
			array_push($emails,$email);
		}
		$adb->println("Email ids are selected  => '".$emails."'");
		return $emails;
	} else {
		$adb->println("User id is empty. so return value is ''");
		return '';
	}
}


?>