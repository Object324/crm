<?php
include(globalStatic::$root_directory."include/PHPMailer/src/PHPMailer.php");
include(globalStatic::$root_directory."include/PHPMailer/src/SMTP.php");
include(globalStatic::$root_directory."include/mail/MailDb.php");
include(globalStatic::$root_directory."include/mail/MailAccount.php");
include(globalStatic::$root_directory."include/mail/MailInfo.php");

global $adb;
$mailaccountid=$_REQUEST['mailaccountid'];
$toemail=$_REQUEST['toemail'];
$content=$_REQUEST['content'];
$subject=$_REQUEST['subject'];
$mailaccountobj=new MailAccount();
$mailaccountinfos=$mailaccountobj->getMailAccountInfo();
if(empty($mailaccountinfos))
{
    ConvertTojsonString(-1,array(),'请设置邮箱账号！');
    
}
foreach($mailaccountinfos as $content)
{
    if($content['account_id']==$mailaccountid)
    {
        $frommailinfo=$content;
    }
}
if(empty($frommailinfo))
{
    ConvertTojsonString(-1,array(),'参数错误！');
    
}
// 实例化PHPMailer核心类
$mail = new PHPMailer();
// 是否启用smtp的debug进行调试 开发环境建议开启 生产环境注释掉即可 默认关闭debug调试模式
//$mail->SMTPDebug = 1;
// 使用smtp鉴权方式发送邮件
$mail->isSMTP();
// smtp需要鉴权 这个必须是true
$mail->SMTPAuth = true;
//$mail->SMTPAutoTLS = false;
//$mail->SMTPAuth=false;
// 链接qq域名邮箱的服务器地址
$VersionInfo=getVersionInfo();
$smtpserver=$frommailinfo['smtpserver'];
//smtp.halivo.com:263企业邮箱
if(strtolower($frommailinfo['smtpsec'])=='ssl'&&strtolower($smtpserver)!='smtp.halivo.com'&&$VersionInfo['account']!='langjie')//qq邮箱
{
    //sleep(2);
    $mail->Host ="ssl://".$frommailinfo['smtpserver'].":465";//  gethostbyname('smtp.qq.com');//$frommailinfo['smtpserver'];
}
else
{
      $mail->Host =$frommailinfo['smtpserver'];
    // 设置使用ssl加密方式登录鉴权
    //$mail->SMTPSecure = 'ssl';
    $mail->SMTPSecure=$frommailinfo['smtpsec'];
    // 设置ssl连接smtp服务器的远程服务器端口号
    //$mail->Port = 465;
    if($VersionInfo['account']=='langjie'&&strtolower($frommailinfo['smtpsec'])=='ssl')
    {
            $mail->Port =587;
    }
    else
         $mail->Port = $frommailinfo['smtpport'];
}


// 设置发送的邮件的编码
$mail->CharSet = 'UTF-8';
// 设置发件人昵称 显示在收件人邮件的发件人邮箱地址前的发件人姓名
$mail->FromName =$frommailinfo['popuser'];
// smtp登录的账号 QQ邮箱即可
$mail->Username = $frommailinfo['popuser'];

// smtp登录的密码 使用生成的授权码
$mail->Password = $frommailinfo['poppass'];;

// 设置发件人邮箱地址 同登录账号
$mail->From = $frommailinfo['popuser'];

// 邮件正文是否为html编码 注意此处是一个方法
$mail->isHTML(true);

$toemails=explode(';',trim($toemail,';'));

foreach($toemails as $tmptoemail)
{
    $tmptoemail=trim($tmptoemail);
    
    if(strpos($tmptoemail,'<')!==false&&strpos($tmptoemail,'>')!==false)
    {
        $tomaildisplay=substr($tmptoemail,strpos($tmptoemail,'<')+1,strpos($tmptoemail,'>')-1-strpos($tmptoemail,'<'));
        $tmptoemail=substr($tmptoemail,0,strpos($tmptoemail,'<'));
        $mail->addAddress($tmptoemail,$tomaildisplay);
    }
    else
        $mail->addAddress($tmptoemail);
}
$mcc=$_REQUEST['mcc'];
if(isset($mcc)&&!empty($mcc))
{
 
    
    $mccemails=explode(';',trim($mcc,';'));
    foreach($mccemails as $tmpccemail)
    {
        
        $tmpccemail=trim($tmpccemail);
        
        if(strpos($tmpccemail,'<')!==false&&strpos($tmpccemail,'>')!==false)
        {
            $ccmaildisplay=substr($tmpccemail,strpos($tmpccemail,'<')+1,strpos($tmpccemail,'>')-1-strpos($tmpccemail,'<'));
            $tmpccemail=substr($tmpccemail,0,strpos($tmpccemail,'<'));
            $mail->AddCC($tmpccemail,$ccmaildisplay);
            
        }
        else
            $mail->AddCC($tmpccemail);
    }
}

$mailInfoobj=new MailInfo();
//$mail->addCC("767902223@qq.com");
//$mail->addCC("wcjan123456@126.com");
// 添加该邮件的主题
$mail->Subject = $_REQUEST['subject'];
// 添加邮件正文
$mail->Body = $mail->msgHTML($_REQUEST['content'],globalStatic::$root_directory);
$attachfile_count=$_REQUEST['groupemail-file_num'];

require_once globalStatic::$root_directory.'Register/cls_MyCRMcrypt.php';
$cls_MyCRMcrypt = new cls_MyCRMcrypt();
if($attachfile_count>0)
{
    for($i=1;$i<=60;$i++)
    {
        //// 为该邮件添加附件
        if(!isset($_REQUEST['groupemail-file_name_'.$i]))
        {
            continue;
        }
        $fileName=$_REQUEST['groupemail-file_name_'.$i];
        $path=$_REQUEST['groupemail-file_path_'.$i];
        
        //edit: xll XUQIU1001183 下载优化：newfile_name、path、cloud_path解密
        $isEncrypt = $_REQUEST['groupemail-isEncrypt_'.$i];	//是否加密
        $path = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($path) : $path;
        $fileName = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($fileName) : $fileName;
        
        $mail->addAttachment($path.$fileName);
        $mailInfoobj->attachments[]=array('filename'=>$fileName,'filepath'=>$path);
    }
}

//ls 2021-11-16 0048742: 【优耐特】V8.4.3.8（http://36.154.247.18:85/crm [^]）发送邮件之后，对方邮箱收不到邮件（详情见说明）
//https://github.com/PHPMailer/PHPMailer/wiki/Troubleshooting#php-56-certificate-verification-failure
$mail->SMTPOptions = array(
    'ssl' => array(
        'verify_peer' => false,
        'verify_peer_name' => false,
        'allow_self_signed' => true
    )
);

// 发送邮件 返回状态
$status = $mail->send();


//朗捷特殊控制 邮件发送后保存已填写邮箱
$version_info = getVersionInfo();
if($status == true  && $version_info['account'] == 'langjie' && $_SESSION['Email']['fromModule'] =='CustomForm22'){
    unset($_SESSION['Email']['fromModule']);
    $emailFilePath ='storage/langjieEmailAddress.txt';
    file_put_contents($emailFilePath,$toemail);
}


/*保存发送到数据库*/
$MailDbobj=new MailDb($frommailinfo['popuser']);

$mailInfoobj->mfrom=$frommailinfo['popuser'];
$mailInfoobj->mto=trim($toemail,',');
$mailInfoobj->mbody=$_REQUEST['content'];
$mailInfoobj->msubject=$mail->Subject;
$mailInfoobj->mcc=$mcc;
$MailDbobj->savesendmail($mailInfoobj);
 
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');

?>