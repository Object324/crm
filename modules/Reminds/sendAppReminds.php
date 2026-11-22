<?php


error_reporting(E_ALL^E_NOTICE^E_WARNING);

$root_dir= dirname(dirname(dirname(__FILE__)));
 
date_default_timezone_set('Asia/Shanghai');
//用于验证来源是否合法
include($root_dir.'/Register/CheckSessionID.php');

$hourtime=intval(date("H"));
global $adb;
$_GET['intervalsearch']='yes';
include($root_dir."/autoRemind/createRemind.php");//自动提醒扫描
if(!$adb)
{
    $adb=PearDatabase::getInstance();
}

$userid=$_REQUEST['userid'];
require_once(globalStatic::$root_directory.'Register/cls_MyCRMcrypt.php');
$encryptobj=new cls_MyCRMcrypt();
$userid=$encryptobj->decode($userid);
$userid=addslashes($userid);
$limitnum=5;
if($hourtime>=9 && $hourtime<=18)//工作时间
{
    $sql="select  (remindsid) ,related_to,reltab,content,remindstype,Q.date_time,Q.reminds_ruleid from ld_reminds as Q
    inner JOIN ld_users on ld_users.id = Q.recieverid
        LEFT JOIN ld_tab on ld_tab.name=Q.reltab
        where Q.deleted = 0 
            AND Q.status_rmd = '未读' 
            AND Q.is_del_rec = 0 
             AND Q.push_to_nativeapp = 2
            AND Q.date_time < NOW()  
			AND Q.date_time>DATE_SUB(CURDATE(),INTERVAL 1 DAY)
      
         and ld_users.id=?
        and ld_users.push_wx_reminds=1
        and     not exists(select 1 from ld_tmp_wx_reminds where client_type='NativateApp' and date_add(createdtime, interval 10 minute)>now())
        
        order by date_time asc  limit  $limitnum";
   
   
  
    
}
else
{
     $sql="select (remindsid) as remindsid,related_to,reltab,remindstype,content,Q.date_time,Q.reminds_ruleid
      from ld_reminds  as Q  inner JOIN ld_users on ld_users.id = Q.recieverid
        LEFT JOIN ld_tab on ld_tab.name=Q.reltab
        where Q.deleted = 0 
            AND Q.status_rmd = '未读'
            AND Q.is_del_rec = 0 
             AND Q.push_to_nativeapp = 2 
            AND Q.date_time < NOW()  
			AND Q.date_time>DATE_SUB(CURDATE(),INTERVAL 1 DAY)
      
          and ld_users.id=?
        and ld_users.push_wx_reminds=1
        and   not exists(select 1 from ld_tmp_wx_reminds where client_type='NativateApp' and date_add(createdtime, interval 10 minute)>now())
        
       order by date_time desc  limit $limitnum ";
}
/*
$sql='select  (remindsid) ,related_to,reltab,content,remindstype,Q.date_time,Q.reminds_ruleid from ld_reminds as Q
   order by date_time asc  limit   '.$limitnum;*/
   

$result=$adb->pquery($sql,array( $userid));
$rows=$adb->num_rows($result);
file_put_contents(globalStatic::$root_directory.'modules/Reminds/ab.txt',$sql.'Userid:'.$userid);
$_REQUEST['diony']='yes';
$crmurl=$_REQUEST['crmurl'];

if($rows>0)
{
    $sql='insert into ld_tmp_wx_reminds(createdtime,client_type)value(?,?)';
    $adb->pquery($sql,array(date("Y-m-d H:i:s"),'NativateApp'));
    $arr=[];
    $remindsid_arr=[];
    for($i=0;$i<$rows;$i++)
    {
        $content=$adb->query_result($result,$i,'content');
        $remindsid=$adb->query_result($result,$i,'remindsid');
        $related_to=$adb->query_result($result,$i,'related_to');
        $reltab=$adb->query_result($result,$i,'reltab');
        $modulelabel=getTranstab($reltab);
        $remindsid_arr[]=$remindsid;
        
        $title="";
     $content=str_replace("<br>","\n",$content);
        //$content="您有1条公海客户未达成目标，回收到公海池。\n客户名称如下:上海灵当信息科技有限公司";
        $arr[]=['content'=>$content,'remindsid'=>$remindsid,'related_to'=>$related_to,'reltab'=>$reltab,'modulelabel'=>$modulelabel, 'title'=>$title];
        
    }
    if(is_array($arr))
    {
        
        
        //editor:gyq_165 reason:企业微信消息提醒   2020/1/2 14:58
        require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/MessageCorpconversation.php");
     
        
        $remindobj = new MessageCorpconversation();
        $errorno = $remindobj->sendNativeMessage($arr);
         $sql='update ld_reminds set push_to_nativeapp=3,push_time_nativeapp=now() where remindsid in( '.implode(",",$remindsid_arr).')';
        $adb->pquery($sql,array());
        
    }
   
     $sql='delete from ld_tmp_wx_reminds where client_type=\'NativateApp\'';
     $adb->pquery($sql,array());
    ConvertTojsonString(1,['list'=>$arr ],'success');
    
}
 ConvertTojsonString(-1,['list'=>$arr,'userid'=>$userid],'success');


?>