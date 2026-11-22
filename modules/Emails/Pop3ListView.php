<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$smarty=new lingdangCRM_Smarty();
include(globalStatic::$root_directory."include/mail/MailAccount.php");
$mailaccountobj=new MailAccount("");
$mailaccounts=$mailaccountobj->getMailAccountInfo();
$smarty->assign("MAILACCOUNTS",$mailaccounts);


/**
 * 获取没有下载到服务器的邮件编号

include("include/mail/Protocol/Base.php");
include("include/mail/Protocol/POP3.php");
include("include/mail/MailDb.php");

include("include/mail/MailRead.php");
include("include/mail/MailInfo.php");


global $adb;
$accdata['popserver']="pop.ismail.cn";
$accdata['popport']="110";
$accdata['popsec']='none';
$accdata['popuser']='can@51mis.com';
$accdata['poppass']='can123';

$mailaccount=new MailAccount("can@51mis.com");
$MailDbobj=new MailDb("can@51mis.com");

$CONN = new Protocol_Client_POP3($accdata['popserver'], $accdata['popport'], 0, $accdata['popsec']);
$_REQUEST['diony']='yes';

if ($CONN->check_connected() !== true) { 
            ConvertTojsonString(1,array(),'服务器：'.$accdata['popserver']."连接失败");
      
 }
 $status = $CONN->login($accdata['popuser'], $accdata['poppass']);
 if (!$status['login']) { // Login failed
            $error = $CONN->get_last_error();
            $CONN->close();
            $JSON['done'] = 1;
            $JSON['error'] = 'Login to '.$accdata['popserver'].' as '.$accdata['popuser'].' failed'.($error ? ' ('.$error.')' : '');
            
            ConvertTojsonString(1,array(),'账号：'.$accdata['popuser']."登录失败".$error);
}
global $list_max_entries_per_page_new;

$mailinfos=$MailDbobj->getHadDownloadEmail();
$listuidls=array();
for($i=0;$i<=sizeof($mailinfos);$i++)
{
    $mailInfo=$mailinfos[$i];
    
    $uidls[]=$mailInfo->uidl;
}
$listuidls=array();
$maillist = $CONN->get_list();

for($i=sizeof($maillist);$i>=1;$i--)
{
    $tmpuidl=$maillist[$i]['uidl'];
    if(!in_array($tmpuidl,$uidls))
   	{
        $listuidls[]=$i;
   	}
    else
    {
        break;
    }
}

arsort($listuidls);//重排序，由小到大
$CONN->close();
 $totalRows= $MailDbobj->getAllTotalRows();

//获取数据库中未读邮件数量
$unreadcount=$MailDbobj->getUnReadCount();
$unreadcount=sizeof($listuidls)+$unreadcount;
$smarty->assign("JSONLISTUIDLS",json_encode($listuidls));
$smarty->assign("TOTALEMAILCOUNT",$totalRows);
$smarty->assign("UNREADCOUNT",$unreadcount);*/

$smarty->display("Emails.tpl");

?>