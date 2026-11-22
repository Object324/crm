<?php
/***********************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
**AUTHOR:BY LD KEVIN
**DATE:2013-04-25
**DESCRIPTION:邮件提醒
***********************************************************************/
error_reporting(E_ALL^E_NOTICE^E_WARNING);

$root_dir=dirname( dirname(dirname(__FILE__)));
global $adb;
$_GET['intervalsearch']='yes';
include($root_dir."/autoRemind/createRemind.php");//自动提醒扫描
require_once($root_dir.'/includefile.php');

/**
 * edit:can
 * reason:循环提醒(V5.4)
 * */

require_once($root_dir.'/Register/RegOp.php');

global  $adb;
global $current_user;
$current_user=new Users();
 $tmp_hour=intval(date("H"));
$customsql='';
$adb=PearDatabase::getInstance();
$current_user->is_admin='on';
$current_user->user_name='系统自动发送';

$date = date('Y-m-d');
$datetime = date('Y-m-d H:i:s');
//活动邮件提醒只提醒自己
$query="select T1.activity_id, T1.reminds_ruleid, ld_users.last_name,
case when ifnull( T2.to_email,'')='' then ld_users.email1 else T2.to_email end as email1,T2.subject,
 T2.cc_email ,
T2.date_start,T2.due_date,T2.eventstatus,T2.priority,T2.description ,T2.to_email
from ld_activity_reminder as T1 
left join ld_activity as T2 on T1.activity_id=T2.activityid

 inner join ld_users on ld_users.id=T2.smownerid 
where T2.deleted=0 and T1.reminder_sent=0 and date_format(T1.email_remind,'%Y-%m-%d')<='".$date."' and T1.email_remind<='".$datetime."'
and  T1.email_remind>'0000-00-00 00:00:00'
and (T1.content is null  or T1.content='') order by  T1.email_remind asc  limit 0,20  ";




$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
if($num_rows<=0)
{
   
}
else
{
    $sql="update ld_activity_reminder set reminder_sent=1,email_sendtime=NOW() where    
        reminder_sent=0 and date_format(email_remind,'%Y-%m-%d')<='".$date."' and email_remind>'0000-00-00 00:00:00'
        and (content is null  or content='')  order by  email_remind asc limit 20 "; 
        $adb->query($sql);
        
        
        crm_load_class_file('mail','modules/Emails');
        $sql = 'select * from ld_systems where server_type = ? limit 1;';
        $sqlresult = $adb->pquery($sql,array('email'));
        $records=$adb->num_rows($sqlresult,0,"id");  
        if($records != ''){
        $sender=$adb->query_result($sqlresult,0,'server_username');        		
        } 
        $fieldobj=Field::getInstance('Calendar',$adb);
        $subjectlabel=$fieldobj->getFieldInfoBykeyValue('columnname','subject','fieldlabel');
        $starttimelabel=$fieldobj->getFieldInfoBykeyValue('columnname','date_start','fieldlabel');
        $endtimelabel=$fieldobj->getFieldInfoBykeyValue('columnname','due_date','fieldlabel');
        $statuslabel=$fieldobj->getFieldInfoBykeyValue('columnname','eventstatus','fieldlabel');
        $prioritylabel=$fieldobj->getFieldInfoBykeyValue('columnname','priority','fieldlabel');
        $descriptionlabel=$fieldobj->getFieldInfoBykeyValue('columnname','description','fieldlabel');
        $emailinfo=array();
        if($num_rows){
            for($i=0;$i<$num_rows;$i++)
            {
                $subject=$adb->query_result($result,$i,'subject');
                $date_start=$adb->query_result($result,$i,'date_start');
                $due_date=$adb->query_result($result,$i,'due_date');
                $eventstatus=$adb->query_result($result,$i,'eventstatus');
                $priority=$adb->query_result($result,$i,'priority');
                $description=$adb->query_result($result,$i,'description');
               // $mod_strings=return_module_language($default_language,'Calendar');
                $name=$adb->query_result($result,$i,'last_name');
                $toemail=$adb->query_result($result,$i,'email1');
                $cc_email=$adb->query_result($result,$i,'cc_email');
                $remindsruleid=$adb->query_result($result,$i,'reminds_ruleid');
                $activityid=$adb->query_result($result,$i,'activity_id');
                $activity_to_email=$adb->query_result($result,$i,'to_email');
                if(empty($remindsruleid))
                {
                    
                    if(!empty($activity_to_email))
                    {
                        $list = $description;
                    }
                    else
                   {
                    $list = $name.',';
                     $list .= '<br><br>日程,细节是:<br>';
                    $list .= '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$subjectlabel.': '.$subject;
                    $list .= '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$starttimelabel.': '.$date_start;
                    $list .= '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$endtimelabel.': '.$due_date;
                    $list .= '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$statuslabel.': '.$eventstatus;
                    $list .= '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$prioritylabel.': '.$priority;	
                    $list .= '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$descriptionlabel.': '.$description;
                    $list .= '<br><br>感谢和问候'; 
                    }
                }
                else
                {
                    $list=$description;
                }
                
                $emailinfo[]=array('toemail'=>$toemail,
                'cc_email'=>$cc_email,
                'subject'=>$subject,
                'content'=>$list,
                'lastname'=>$name,
                'activityid'=>$activityid,
                'remindsruleid'=>$remindsruleid
                
                ); 
            }
        }

}



if(count($emailinfo)>0){
    //print_r($emailinfo);
    foreach($emailinfo as $email){
        //edit:can 20210811 47364: （81mis.com/kfbcrm）系统设置-自动提醒设置-“采购订单”，设置了自动提醒采购订单新建提醒发送邮件给供应商；但是收到的邮件含有特殊符号
        $email['content']=html_entity_decode($email['content']);
        $mail_status=send_mail('',$email['toemail'],$current_user->user_name,$sender,$email['subject'],$email['content'],$email['cc_email'],'','','','',$sender);
        if(!empty($email['remindsruleid']))
        {
            $toemail="[\"".$email['lastname'].'<'.$email['toemail'].'>"]';
            $sqlinsert='insert into ld_emaildetails(emailid,from_email,to_email,email_flag)values(?,?,?,?)';
            $adb->pquery($sqlinsert,array($email['activityid'],$sender,$toemail,'SENT'));
        }
    }
   
    
} 


if($_GET['intervalsearch']!='yes')
{
    
    //不是每隔5分钟的扫描
    unset($adb);
    unset($current_user); 
}

 
?>
