<?php
/**
 * User: Dong
 * Project: 禹王邮件解析
 * Date: 2021/6/24 14:58
 * Description:
 */
$root_dir=dirname( dirname(dirname(__FILE__)));
$root_dir.=DIRECTORY_SEPARATOR;
$root_directory=$root_dir;
include($root_dir.'includefile.php');
require_once($root_dir.'Register/RegOp.php');
require_once ($root_dir.'data/CRMEntity.php');
require_once ($root_dir.'include/utils/CommonFun.php');
require_once($root_dir.'Smarty_setup.php');
include_once($root_dir."include/mail/MailRead.php");
global $adb,$currentModule,$site_URL;
$emlUrl = $_REQUEST['eml'];
$record =$_REQUEST['record'];
$filePath = $root_dir."storage/mail/yuwangEmail/"; //eml目录  文件名为record.eml
$attachPath = $root_dir."storage/mail/yuwangEmail/attach/"; //附件目录
$cidAttachPath = $root_dir."storage/mail/yuwangEmail/cid/"; //cid附件目录
$filename = $record.'.eml';
if(!file_exists($filePath)){
    mkdir($filePath,0777);
    chmod($filePath,0777);
}
if(!file_exists($attachPath)){
    mkdir($attachPath,0777);
    chmod($attachPath,0777);
}
if(!file_exists($cidAttachPath)){
    mkdir($cidAttachPath,0777);
    chmod($cidAttachPath,0777);
}

if(!downloadFile($emlUrl,$filePath.$filename)){
    echo $emlUrl.'无法下载eml文件';
    die;
};

//组合参数  仅仅为了使用下面方法
$mailinfo= new stdClass();
$mailinfo->uidl = $record;
$mailinfo->mailaccountname ='yuwangEmail';

$mailInfo=getMailInfoObj($filePath,$mailinfo);

saveAttachment($mailInfo,$record,$attachPath);
$smarty = new lingdangCRM_Smarty();

$smarty->assign('SITEURL',$site_URL);
$smarty->assign('RECORD',$record);
$smarty->assign('MAILINFO',$mailInfo);

$smarty->display('yuwang/yuwangEmail.tpl');


function getMailInfoObj($filePath,$mailInfo,$onlyattach='no')
{
    $mr = new MailRead();
    $contents=$mr->readfromfile($filePath."/".$mailInfo->uidl.'.eml',true,true);


    $mailtype=$contents['header']['Content-Type']['type'];

    $mailInfo->mfrom=$contents['header']['From'];
    $mailInfo->mbcc=$contents['header']['Bcc'];
    $mailInfo->mcc=$contents['header']['Cc'];
    $mailInfo->msubject=$contents['header']['Subject'];

    $mailInfo->mdate=$contents['header']['Date'];
    $mailInfo->mto=$contents['header']['To'];
    $mailInfo->mailrecordid=$_REQUEST['mailrecordid'];
    $mailInfo->mbody=($contents['body']['text/html']['text']);


    $mailInfo->attachments=array();
    $attachs=array();
    $cidpath ='../../storage/mail/yuwangEmail/cid/';


    foreach($contents['body'] as $key=>$Info)
    {


        if(stripos($mailtype,'multipart/related')!==false||stripos($mailtype,'multipart/mixed')!==false)
        {


            if(array_key_exists('Content-ID',$Info['header']) && (!array_key_exists('Content-Disposition',$Info['header']) || $Info['header']['Content-Disposition']['type']=='inline'))
            {
                if($onlyattach=='yes')
                {
                    continue;
                }
                $cidfilename=$Info['header']['Content-ID'];
                $filename=$Info['header']['Content-Type']['name'];
                $strfiles=explode(".",$filename);
                $filexttype=array_pop($strfiles);

                $tmpfilename=implode('',$strfiles);
                //重新生成文件名称
                $filename=$tmpfilename.rand(100,1000000).'.'.$filexttype;

                $mailInfo->mbody=str_replace("cid:".$cidfilename,$cidpath.'/'.$filename,$mailInfo->mbody);

                if(strtolower($Info['header']['Content-Transfer-Encoding'])=='base64')
                {

                    file_put_contents($cidpath.'/'.$filename,base64_decode($Info['text']));

                }
                else if(strtolower($Info['header']['Content-Transfer-Encoding'])=='quoted-printable')
                {
                    file_put_contents($cidpath.'/'.$filename,quoted_printable_decode($attachbody))  ;
                }
                continue;
            }
        }
        if(array_key_exists('Content-Disposition',$Info['header']))
        {

            $filename=$Info['header']['Content-Disposition']['filename'];
            $mailInfo->attachments[]=array("filename"=>$filename);



            if(strtolower($Info['header']['Content-Transfer-Encoding'])=='base64')
            {

                $attachs[]=array('text'=>$Info['text'],'encoding'=>"base64",'filename'=>$filename);
                // file_put_contents($path.'/'.mb_convert_encoding($filename,"GBK","auto"),base64_decode($Info['text']));

            }
            else if(strtolower($Info['header']['Content-Transfer-Encoding'])=='quoted-printable')
            {
                $attachs[]=array('text'=>$Info['text'],'encoding'=>"quoted-printable",'filename'=>$filename);
                //file_put_contents($path.'/'.$filename,quoted_printable_decode($attachbody))  ;
            }
        }
    }
    $mailInfo->attachments=$attachs;
    return $mailInfo;
}
/**
 * Name: 保存附近到本地
 * User: Dong
 * Date: 2021/6/24 15:14
 * @param $mailInfo object 包换eml文件的所有信息
 * @param $filePath string 附件保存路径
 */
function saveAttachment($mailInfo,$record, $filePath)
{
    foreach ($mailInfo->attachments as $tmpfilecontent) {
        $filename = $record.'_'.$tmpfilecontent['filename'];
        if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix') {
            $tmpfilename = $filename;
        } else {
            $tmpfilename = mb_convert_encoding($filename, 'GBK', 'auto');
        }
        if ($tmpfilecontent['encoding'] == 'quoted-printable') {
            $fileContent = quoted_printable_decode($tmpfilecontent['text']);
        } else {
            $fileContent = base64_decode($tmpfilecontent['text']);
        }
        file_put_contents($filePath . $tmpfilename, $fileContent);
    }
}

//下载文件到本地
function downloadFile($fileUrl,$filename) {
    // @edit:dong @date:2021/08/03 @reason: 防止多次下载
    if(file_exists($filename)) return $filename;
    set_time_limit(0);
    $hostfile = fopen($fileUrl, 'r');
    if(!$hostfile) return false;
    $fh = fopen($filename, 'w');
    while (!feof($hostfile)) {
        $output = fread($hostfile, 2048);
        fwrite($fh, $output);
    }
    fclose($hostfile);
    fclose($fh);
    return $filename;
}

