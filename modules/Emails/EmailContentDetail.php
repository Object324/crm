<?php

include(globalStatic::$root_directory."include/mail/MailDb.php");

include(globalStatic::$root_directory."include/mail/MailRead.php");
include(globalStatic::$root_directory."include/mail/MailInfo.php");
global $adb;
$mailrecorid=$_REQUEST['mailrecordid'];
$mailreadobj=new MailRead();
$MailDbobj=new MailDb("");
$mailInfo=$MailDbobj->getMailContentInfo($mailrecorid);
//$filename = $mailInfo->attachments[0]['filename'];
$emlpath=MailRead::getemlAttachmentpath($mailInfo->mailaccountname);
$smarty=new lingdangCRM_Smarty();
$smarty->assign("PAGESTART",$_REQUEST['pagestart']);
$prevrecorid=$MailDbobj->getPrevRecord($_REQUEST['pagestart'],$mailrecorid);
$nextrecordid=$MailDbobj->getNextRecord($_REQUEST['pagestart'],$mailrecorid);
$smarty->assign('PREVRECORDID',$prevrecorid);
$smarty->assign('NEXRECORDID',$nextrecordid);
$allFilesValid = true;  // 设置一个标志变量，假设所有文件大小都大于0
foreach ($mailInfo->attachments as $attachment) {
    if ($attachment['filesize'] <= 0) {
        $allFilesValid = false;  // 如果发现文件大小不符合条件，改变标志变量并退出循环
        break;
    }
}
if($allFilesValid && $mailInfo->bodyparsed == 1)
{
    //已解析
   // $mailInfo->mbody
}
else
{
    $mailreadobj=new MailRead();
    $mailInfo=$mailreadobj->getMailInfoObj($mailInfo);
    $filename = $mailInfo->attachments[0]['filename'];
   // $contents=$mailreadobj->readfromfile($emlpath."/".$mailInfo->uidl.'.eml',true,true);
    //删除文件
 // @unlink($emlpath."/".$mailInfo->uidl.'.eml');

 // if(!empty($attachs))//如果有附件
    //    file_put_contents($emlpath."/".$mailInfo->uidl.'_1.eml',json_encode($attachs));
   $mailInfo->mailrecordid=$mailrecorid;
   $MailDbobj->mailaccount=$mailInfo->mailaccountname;
   if ($mailInfo->mailtype=='smtp'){

   }else{
       $MailDbobj->updateMailRecord($mailInfo);
   }
//2024-06-12点击邮件查看详情保存附件
    if($mailInfo->mailtype=='pop')
    {
        $emlpath=MailRead::getemlAttachmentpath($mailInfo->mailaccountname);
        $attachpath=MailRead::getAttachmentpath($mailInfo->mailaccountname);
        foreach ($mailInfo->attachments as $tmpfilecontent) {
            $i = 0;
            $filename = $tmpfilecontent['filename'];
            if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix') {
                $tmpfilename = $filename;
            } else
                $tmpfilename = mb_convert_encoding($filename, 'GBK', 'auto');
            if (file_exists($tmpfilecontent['path'] . $tmpfilename)) {
                $path = $tmpfilecontent['path'];
                // $fileContent=file_get_contents($tmpfilecontent['path'].$tmpfilename);
            }
            if (empty($path)) {
                $mailInfo = $mailreadobj->getMailInfoObj($mailInfo, 'yes');
                foreach ($mailInfo->attachments as $tmpfilecontent) {
                    $orgin_filename = $tmpfilecontent['filename'];
                    if ($orgin_filename == $filename || true) {
                        $tmpfilename = mb_convert_encoding($tmpfilecontent['filename'], 'GBK', 'auto');
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
                            $tmpfilename = $orgin_filename;
                        } else {
                            $tmpfilename = mb_convert_encoding($orgin_filename, 'GBK', 'auto');
                        }
                        $result =  file_put_contents($attachpath . '/' . $mailrecorid . '/' . $tmpfilename, $fileContent);
                        if (strpos($path, globalStatic::$root_directory) !== false) {
                            $path = substr($path, strpos($path, globalStatic::$root_directory) + strlen(globalStatic::$root_directory));
                        }
                    }
                }
            }
            $fileSize = filesize($attachpath . '/' . $mailrecorid . '/' . $filename);
            $mailInfo->attachments[$i]['filesize'] = $fileSize;
            $MailDbobj->updateMailAttachment($fileSize, $filename, $mailInfo->mailrecordid);
            $i ++;
            $name = $filename;
        }


    }
    else
    {
        $sql='select * from ld_mailmanager_mailattachments where mailrecordid=? ';
        $result=$adb->pquery($sql,array($_REQUEST['mailrecordid']));
        if($adb->num_rows($result)>0)
        {
            for ($i = 0; $i < $adb->num_rows($result); $i++) {
                $aname = $adb->query_result($result, $i, 'aname');
                $name = $aname;
                $path = $adb->query_result($result, $i, 'path');
                $fileSize = filesize($path . '/' . $name);
                $mailInfo->attachments[$i]['filesize'] = $fileSize;
                $MailDbobj->updateMailAttachment($fileSize, $name, $mailInfo->mailrecordid);
                $name = $filename;
                //$filePath=mb_convert_encoding($path.$aname,'GBK','auto');
                // $fileContent=file_get_contents($filePath);
            }
        }
    }
}

$smarty->assign("MAILINFO",$mailInfo);
$_REQUEST['diony']='yes';
$smarty->assign("popup", $_REQUEST['popup']);//ls 2021-11-09 【ID1002161】模块相关信息邮件管理功能优化（用友-马朝军）（模块相关信息邮件管理-查看-弹框形式，去掉回复、转发、上一封等功能）
$arr['title'] = getFixedLabel('EMAIL').getFixedLabel('details1');
$arr['content'] = $smarty->fetch("EmailContentDetail.tpl");
ConvertTojsonString(1, $arr, 'success');
?>