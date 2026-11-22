<?php


global $adb;
include(globalStatic::$root_directory."include/mail/MailDb.php");

include(globalStatic::$root_directory."include/mail/MailRead.php");
include(globalStatic::$root_directory."include/mail/MailInfo.php");

global $global_forbiddenext;
$mailrecorid = $_REQUEST['mailrecordid'];
$filename = $_REQUEST['filename'];

$mailreadobj=new MailRead();
$MailDbobj=new MailDb('');
$mailInfo=$MailDbobj->getMailContentInfo($mailrecorid);

if($mailInfo->mailtype=='pop')
{
    $emlpath=MailRead::getemlAttachmentpath($mailInfo->mailaccountname);
    $attachpath=MailRead::getAttachmentpath($mailInfo->mailaccountname);
    if (!file_exists($attachpath.'/'.$mailrecorid.'/'.$filename)) {
        foreach ($mailInfo->attachments as $tmpfilecontent) {
            if ($tmpfilecontent['filename'] == $filename) {
                if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix') {

                    $tmpfilename = $filename;
                } else
                    $tmpfilename = mb_convert_encoding($filename, 'GBK', 'auto');
                if (file_exists($tmpfilecontent['path'] . $tmpfilename)) {
                    $path = $tmpfilecontent['path'];
                    // $fileContent=file_get_contents($tmpfilecontent['path'].$tmpfilename);
                    break;
                }
            }
        }

        if (empty($path)) {
            $mailInfo = $mailreadobj->getMailInfoObj($mailInfo, 'yes');
            foreach ($mailInfo->attachments as $tmpfilecontent) {
                if ($tmpfilecontent['filename'] == $filename) {

                    $tmpfilename = mb_convert_encoding($filename, 'GBK', 'auto');

                    if ($tmpfilecontent['encoding'] == 'quoted-printable') {
                        $fileContent = quoted_printable_decode($tmpfilecontent['text']);
                    } else {
                        $fileContent = base64_decode($tmpfilecontent['text']);
                    }
                    if (!file_exists($attachpath . '/' . $mailrecorid)) {
                        mkdir($attachpath . '/' . $mailrecorid, 0777);
                        chmod($attachpath . '/' . $mailrecorid, 0777);
                    }
                    $path = $attachpath . '/' . $mailrecorid;
                    if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix') {

                        $tmpfilename = $filename;
                    } else {
                        $tmpfilename = mb_convert_encoding($filename, 'GBK', 'auto');
                    }

                    $extension=strtolower((string)pathinfo($tmpfilename));

                    if(in_array($extension,$global_forbiddenext))
                    {
                        $tmpfilename.='.lingdang';

                    }
                    $str_arr=['\\','/',':','*','?','"','<>','|','.','<','>'];
                    foreach($global_forbiddenext as $forbidext)
                    {

                        foreach($str_arr as $tmpstr)
                        {
                            if(stripos(  $extension ,$forbidext.$tmpstr)!==false)
                            {

                                $tmpfilename.='.lingdang';
                            }
                        }
                    }
                    file_put_contents($attachpath . '/' . $mailrecorid . '/' . $tmpfilename, $fileContent);
                    if (strpos($path, globalStatic::$root_directory) !== false) {

                        $path = substr($path, strpos($path, globalStatic::$root_directory) + strlen(globalStatic::$root_directory));
                    }
                    break;
                }
            }
        }

        $name = $filename;
    }


}
else
{
    $sql='select * from ld_mailmanager_mailattachments where mailrecordid=? ';
    $result=$adb->pquery($sql,array($_REQUEST['mailrecordid']));
    if($adb->num_rows($result)>0)
    {
        $aname=$adb->query_result($result,0,'aname');
        $name=$aname;
        $path=$adb->query_result($result,0,'path');
        //$filePath=mb_convert_encoding($path.$aname,'GBK','auto');
        // $fileContent=file_get_contents($filePath);

    }

}


$smarty=new lingdangCRM_Smarty();
$smarty->assign("MAILINFO",$mailInfo);
$smarty->assign("FILENAME",$filename);
$smarty->assign("pdfname",$filename);
$smarty->assign("filepah",$path);

$smarty->assign("FROMMODULE",'Emails');
$fileexts=explode(".",$filename);
$fileext=strtolower($fileexts[sizeof($fileexts)-1]);
$smarty->assign('type',strtolower($fileext));
switch($fileext)
{
    case 'jpeg':
    case 'jpg':
    case 'ico':
    case 'png':
    case 'bmp':
    case 'gif':
        $img_src=$path;
        $lastchpath=substr($path,-1);
        if($lastchpath=='/')
            $smarty->assign('img_src',$img_src.$filename);
        else
            $smarty->assign('img_src',$img_src.'/'.$filename);

        $smarty->assign('type','img');
        break;
    case 'txt':
    case 'sql':
        if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'){

            $tmpfilename=$filename;
        }
        else
            $tmpfilename=mb_convert_encoding($filename,'GBK','auto');
        $img_src=$path;
        $lastchpath=substr($path,-1);
        if($lastchpath=='/')
            $content =file_get_contents($path.$tmpfilename);
        else
            $content =file_get_contents($path.'/'.$tmpfilename);
        $smarty->assign('content','<pre>' . $content . '</pre>');
        $smarty->assign('type','text');
        break;
    case 'doc':
    case 'docx':
    case 'ppt':
    case 'pptx':
    case 'xls':
    case 'xlsx':
        $httphost=$_SERVER['HTTP_HOST'];
        $tmphost=$httphost;

        $tmphosts=explode(".",$tmphost);

        if(stripos($httphost,"http://")===false)
        {
            $httphost="http://".$httphost;
            //edit: xll 2024/07/03 BUG20240617-62 邮件附件预览报错问题（url地址多出端口号）
            if(strpos($_SERVER['HTTP_ORIGIN'],':') !== false) {
                $port = $_SERVER['SERVER_PORT'];
                $httphost .= ":".$port;
            }
        }
        $self=substr($_SERVER['PHP_SELF'],0,stripos($_SERVER['PHP_SELF'],"index.php"));
        $hosturl=$httphost.$self;
        $lastchpath=substr($path,-1);
        if($lastchpath=='/')
            $attachmenturl=$hosturl.$path.$filename.'?a=1';
        else
            $attachmenturl=$hosturl.$path.'/'.$filename.'?a=1';
        $smarty->assign("ATTACHMENTURL",$attachmenturl);
        crm_load_class_file('cls_uploads','modules/uploads');
        $cls_uploads = new cls_uploads($filename,$path,$mailrecorid);
        $uploads_info = $cls_uploads->ConvertOffice();
        if($uploads_info['code'] == 1){
            $smarty->assign('type','pdf');
            $smarty->assign('pdfname',$uploads_info['pdfname']);//转换文件名称
            $smarty->assign('filepah',$uploads_info['filepath']);//PDF路径访问路径
        }
        else{

            if((sizeof($tmphosts)>=4&&is_numeric($tmphosts[1])&&is_numeric($tmphosts[2]))||stripos($tmphost,'localhost')!==false)
            {
                //ip地址无法预览
            }
            else
                $smarty->assign('type','application/msword');
        }
        break;
    // edit: xll 2024/07/03 BUG20240617-25 邮的件附件预览不了，打开是空白页面 (后缀名为xlsm)
    default:
        $smarty->assign('type','other');
        break;
}

$smarty->display('Preview_now.tpl');

?>