<?php

/**
 * 获取没有下载到服务器的邮件编号
*/
set_time_limit(0);

include(globalStatic::$root_directory."include/mail/Protocol/Base.php");
include(globalStatic::$root_directory."include/mail/Protocol/POP3.php");
include(globalStatic::$root_directory."include/mail/MailDb.php");
include(globalStatic::$root_directory."include/mail/MailAccount.php");
include(globalStatic::$root_directory."include/mail/MailRead.php");
include(globalStatic::$root_directory."include/mail/MailInfo.php");
include(globalStatic::$root_directory."modules/Emails/Email_ScopOfAuthority.php");
global $adb;
/*
$accdata['popserver']="pop.ismail.cn";
$accdata['popport']="110";
$accdata['popsec']='none';
$accdata['popuser']='can@51mis.com';
$accdata['poppass']='can123';
*/
  $mailaccountobj=new MailAccount("");
  $accdatas=$mailaccountobj->getMailAccountInfo();
  $tmpaccdatas=$accdatas;
if($_REQUEST['account_id']>0)
{
    $tmpaccdatas=array();
    foreach($accdatas as $accdata)
    {
        if($accdata['account_id']==$_REQUEST['account_id'])
       {
         $tmpaccdatas[]=$accdata;
         break;
       }
    }
}
  global $list_max_entries_per_page_new;
$tmp['unreadcount']=0;
$tmp['totalrows']=0;
$accdatas=$tmpaccdatas;

foreach($accdatas as $accdata)
{
    $MailDbobj=new MailDb($accdata['popuser']);

  
    $CONN = new Protocol_Client_POP3($accdata['popserver'], $accdata['popport'], 0, $accdata['popsec']);
    
    if ($CONN->check_connected() !== true) { 
      
         continue;
          
     }
      
   //  if($accdata['popsec']!='none')
   //  {

            $status = $CONN->login($accdata['popuser'], $accdata['poppass']);

         if (!$status['login']) { // Login failed
                    $error = $CONN->get_last_error();
                    
                    $CONN->close();
                    
                    continue;
        }
    // }

    
    $mailinfos=$MailDbobj->getHadDownloadEmail();
  
    $uidls=array();
    $listuidls=array();
    if(is_array($mailinfos))
        for($i=0;$i<=sizeof($mailinfos);$i++)
        {
            $mailInfo=$mailinfos[$i];

            $uidls[]=$mailInfo->uidl;
        }
    $listuidls=array();
 
    $maillist = $CONN->get_listseq();
 
    $count = 0;

    for($i=sizeof($maillist);$i>=1;$i--)
    {
        $count++;
        //duan 20240703 BUG20240624-75:获取到的邮件数量太多（15000多条），一条条判断重复时会超时，增加判断上限
        if($count >100)break;
       if(!is_array($uidls)||$uidls[0]=="")
       {
        //第一次获取数据
         $listuidls[]=$i;
       }
       else
       {
            $tmpuidl=$CONN->uidl($i);
            
            if(!in_array($tmpuidl,$uidls))
           	{
    
                $listuidls[]=$i;
           	}
            else
            {
                break;
            }
       }
        
    }
   $CONN->close();
    //arsort($listuidls);//重排序，由小到大
   
 
     $totalRows= $MailDbobj->getAllTotalRows();
    
    //获取数据库中未读邮件数量
    $unreadcount=$MailDbobj->getUnReadCountByAccountClick();
    
    $unreadcount=sizeof($listuidls)+$unreadcount;
     
    $tmp[$accdata['popuser']]['unreadcount']=$unreadcount;
    $tmp[$accdata['popuser']]['totalrows']=$totalRows+sizeof($listuidls);//获取总数量
    $tmp[$accdata['popuser']]['list']=$listuidls;
    $tmp['popusers'][]=array('popuser'=>$accdata['popuser'],'account_id'=>$accdata['account_id']);
   // $tmp['unreadcount']=$unreadcount+$tmp['unreadcount'];
    //$tmp['totalrows']=$totalRows+sizeof($listuidls)+$tmp['totalrows'];//获取总数量
}

$_REQUEST['diony']='diony';
ConvertTojsonString(1,$tmp,"success");

?>