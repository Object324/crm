<?php

//发送立即发送失败提醒数据
error_reporting(E_ALL^E_NOTICE^E_WARNING);

$root_dir=dirname(dirname(dirname(__FILE__))) ;

@include($root_dir.'/includefile.php');
$baimingip=array("139.196.42.204","139.196.108.146","111.231.135.110",'101.80.148.115','127.0.0.1');
date_default_timezone_set('Asia/Shanghai');
global $adb;
if(!$adb)
{
    $adb=PearDatabase::getInstance();
}
$hourtime=intval(date("H"));
$sql="SELECT id from ld_users  WHERE ld_users.wx_userid is not null and ld_users.wx_userid<>'' ";
$result=$adb->pquery($sql,array());
$limitnum=$adb->num_rows($result);
if($limitnum<=0)
{
    exit();
}
$limitnum=$limitnum*20;

if($hourtime>=9 && $hourtime<=18)//工作时间
{
    $sql="select GROUP_CONCAT(remindsid) as remindsid,related_to,remindstype,reltab,content,GROUP_CONCAT(DISTINCT ld_users.wx_userid) as wx_userid,Q.date_time from ld_reminds as Q
    inner JOIN ld_users on ld_users.id = Q.recieverid
        LEFT JOIN ld_tab on ld_tab.name=Q.reltab
        where Q.deleted = 0 
            AND Q.status_rmd = '未读' 
            AND Q.is_del_rec = 0 
            AND Q.push_to_weixin = 2 
            AND Q.date_time < NOW()  
        and ifnull(wxremindstype,'')='immediately'
        and ld_users.wx_userid is not null and ld_users.wx_userid<>''
      and ld_users.push_wx_reminds=1
        group by content ,related_to,reltab,date_time
        order by date_time asc  limit  $limitnum";
    
}
else
{
     $sql="select GROUP_CONCAT(remindsid) as remindsid,related_to,remindstype,reltab,content,GROUP_CONCAT(DISTINCT ld_users.wx_userid) as wx_userid,Q.date_time
      from ld_reminds  as Q  inner JOIN ld_users on ld_users.id = Q.recieverid
        LEFT JOIN ld_tab on ld_tab.name=Q.reltab
        where Q.deleted = 0 
            AND Q.status_rmd = '未读'
            AND Q.is_del_rec = 0 
            AND Q.push_to_weixin = 2 
            AND Q.date_time < NOW()  
         and ifnull(wxremindstype,'')='immediately'
         and ld_users.push_wx_reminds=1
        group by content ,related_to,reltab,date_time
       order by date_time desc  limit $limitnum ";
}
$result=$adb->pquery($sql,array());

$rows=$adb->num_rows($result);
$remindsids='';



for($i=0;$i<$rows;$i++)
{
    $date_time=$adb->query_result($result,$i,'date_time');
    $remindsid.=$adb->query_result($result,$i,'remindsid').',';
    $remindstype=$adb->query_result($result,$i,'remindstype');
    if($hourtime>=9 && $hourtime<=18)
    {
        
    }
    else
    {
        $tmptime=date("H:i:s",strtotime($date_time));
        if($tmptime=='00:00:00')
        {
            //下班时间是安装date_time降序获取数据，所以可以break
            break;
        }
    }
    $content=$adb->query_result($result,$i,'content');
    $wx_userid=$adb->query_result($result,$i,'wx_userid');
    $reltab=$adb->query_result($result,$i,'reltab');
    $related_to=$adb->query_result($result,$i,'related_to');
    
    $userids=explode(',',$wx_userid);
    $tmparray['userid']=array_unique($userids);
    $tmparray['message']=$content;
    $tmparray['reltab']=$reltab;
    $tmparray['related_to']=$related_to;
    $tmparray['date_time']=date("Y-m-d H:i:s");
    $r_multi_content[]=$tmparray;
   

   
}
 $remindsid=trim($remindsid,',');
    $remindsid=explode(',',$remindsid);
if(is_array($r_multi_content))
{
    require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/immediatelyReminds.php");
    $remind = new immediatelyReminds();
    $errorno = $remind->sendReminds($remindsid,$r_multi_content);
}


require_once($root_dir.'/WeiXinApp/modules/Reminds/cls_remindsWX.php');
$remind = new cls_remindsWX();
$remindarr = $remind->sendErrorWorkReport();
if(empty($remindarr)){
    exit;
}
$url = StaticConst::$server_remindapi;

$data['news'] = json_encode($remindarr,JSON_UNESCAPED_UNICODE);
$result = push_news($url,$data);
function push_news($url,$data){
    $ch = curl_init ();
    curl_setopt ( $ch, CURLOPT_URL, $url );
    curl_setopt ( $ch, CURLOPT_POST, 1 );
    curl_setopt ( $ch, CURLOPT_HEADER, 0 );
    curl_setopt ( $ch, CURLOPT_RETURNTRANSFER, 1 );
    curl_setopt ( $ch, CURLOPT_POSTFIELDS, $data );
     curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 1);
    $output = curl_exec ( $ch );

    curl_close ( $ch );
}
/*$r_multi_content = array(
                array(
                    'userid'=>$recieverid,//注意,这是微信用户id，即用户表中的wx_userid
                    'message'=>$remindcontent,
                    'reltab'=>$this->module_name,
                    'related_to'=>$record,
                    'date_time'=>$datetime,
                    'remindtype'=>'',
                    )
            );
            $remind = new immediatelyReminds();
            $errorno = $remind->sendReminds(array($focus_rel->id),$r_multi_content);*/

?>