<?php
/******************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 **AUTHOR:BY LD KEVIN
 **DATE:20130407
 **DESPRITION:邮件群发
 ******************************************************/
include(globalStatic::$root_directory . 'include/mail/MailDb.php');
include(globalStatic::$root_directory . 'include/mail/MailAccount.php');
include(globalStatic::$root_directory . 'include/mail/MailInfo.php');
include(globalStatic::$root_directory . 'include/mail/MailRead.php');
global $theme, $adb, $current_language, $currentModule, $default_charset;
global $current_user;
require('user_privileges/user_language_' . $current_user->id . '.php');

$smarty = new lingdangCRM_Smarty();
setGLobalURLSmarty($smarty);
$mailaccountid = $_REQUEST['mailaccountid'];
$mailaccountobj = new MailAccount();
$mailaccountinfos = $mailaccountobj->getMailAccountInfo();
$smarty->assign("MAILACCOUNT", $mailaccountinfos);
$smarty->assign("SELECTMAILACCOUNTID", $mailaccountid);

$mailrecorid = $_REQUEST['mailrecordid'];
$content = "";
if ($mailrecorid > 0) {
    $MailDbobj = new MailDb('');
    $mailReadObj = new MailRead();
    $mailInfo = $MailDbobj->getMailContentInfo($mailrecorid);
//    ls 2021-11-09 【ID1002161】模块相关信息邮件管理功能优化（用友-马朝军）
    $recipient = $mailInfo->mfrom;
    // wsh 2024-06-05 XUQIU20240517-01 邮件管理相关功能优化
//    $pos = stripos($recipient,'<');//Joe <123456789@qq.com>  加上前缀发送后收件人人接收失败，需处理成 123456789@qq.com
//    if ($pos !== false) {
//        $recipient = substr($recipient,$pos+1,-1);
//    }
    if ($type = $_REQUEST['type'] == 'transfer') {
        $recipient = '';
    }
//    preg_match('/<(.*?)>/', $mailInfo->mto, $matches);
    if ($_REQUEST['type'] == 'reply') {
        //回复
        $smarty->assign("MTO", $recipient);
        $smarty->assign("SUBJECT", "回复:" . $mailInfo->msubject);

    } else if ($_REQUEST['type'] == 'replyAll') {
        //wsh 2024-06-25 BUG20240618-78 邮件管理，邮件点击“回复全部”写邮件界面，缺少自动带过来其他的收件人，需要“写邮件”界面自动带过来所有“收件人”
        $mto = $mailReadObj->removeSenderEmail($mailInfo->mto, $mailInfo->mailaccountname);
        $mcc = $mailReadObj->removeSenderEmail($mailInfo->mcc, $mailInfo->mailaccountname);
        if (strpos(trim($mto), trim($recipient)) === false) {
            $mto .= ';' . $recipient;
        }
        $smarty->assign("MTO", $mto);
        $smarty->assign("MCC", $mcc);
        $smarty->assign("SUBJECT", "回复:" . $mailInfo->msubject);
    } else if ($_REQUEST['type'] == 'transfer') {
        //转发
        $smarty->assign("SUBJECT", "转发:" . $mailInfo->msubject);
        $emlpath = MailRead::getemlAttachmentpath($mailInfo->mailaccountname);
        $emlfile = $emlpath . '/' . $mailInfo->uidl . '_1.eml';

        $tfiles = json_decode(file_get_contents($emlfile), true);

        foreach ($mailInfo->attachments as $fileinfos) {

            if ($mailInfo->mailtype == 'pop') {

                foreach ($tfiles as $fileinfo) {
                    if ($fileinfos['filename'] == $fileinfo['filename']) {
                        break;
                    }
                }
                file_put_contents($fileinfos['path'] . $fileinfo['filename'], base64_decode($fileinfo['text']));
            }
            $filesize = filesize($fileinfos['path'] . $fileinfos['filename']);
            $str = ceil($filesize / 1024);
            $str .= 'k';

            $files[] = array('file_name' => $fileinfos['filename'], 'file_size' => $str
            , 'file_type' => '', 'file_path' => $fileinfos['path'], 'newfile_name' => $fileinfos['filename']
            , 'fileid' => '');
        }

        $smarty->assign("ATTACHMENTINFO", json_encode($files));

    }
    $content = '<br/><br/><br/><div style="font-size: 12px;font-family: Arial Narrow;padding:2px 0 2px 0;">------------------&nbsp;原始邮件&nbsp;------------------</div>';
    $content .= '<div style="font-size: 12px;background:#efefef;padding:8px;">';
    $content .= '<div><b>发件人:</b>' . $mailInfo->mfrom . '</div>';
    $content .= '  <div><b>发送时间:</b>' . $mailInfo->mdate . '</div>';
    $content .= ' <div><b>收件人:</b>' . $mailInfo->mto . '</div>';

    $content .= '<div></div>';
    $content .= '<div><b>主题:</b>&nbsp;' . $mailInfo->msubject . '</div>';
    $content .= '</div>';
    $content .= '<div><br><div>';//.$mailInfo->mbody;

    $smarty->assign("MBODY", htmlspecialchars_decode($mailInfo->mbody));
    $smarty->assign("MFROM", $mailInfo->mailaccountname);
    $smarty->assign('CONTENT', $content);
}
$_REQUEST['diony'] = 'yes';
if ($_REQUEST['emailpagetype'] == 'pop') {
    $smarty->assign("EMAILPAGETYPE", 'pop');
    $smarty->display('send_email.tpl');
} else {
    $arr['current_sender'] = $mailInfo->mto;
    $arr['content'] = $smarty->fetch('send_email.tpl');
    ConvertTojsonString(1, $arr, 'success');
}

?>