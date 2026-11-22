<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);

$root_dir= dirname(dirname(dirname(__FILE__)));



if(!file_exists($root_dir.'/dataCache/weixin/auth_info.txt')
||filesize($root_dir.'/dataCache/weixin/auth_info.txt')<=0)
{
    exit('selfbulitexist');
}
$baimingip=array("139.196.42.204","139.196.108.146","111.231.135.110",'101.80.148.115','127.0.0.1');
date_default_timezone_set('Asia/Shanghai');
global $adb;
$_GET['intervalsearch']='yes';
include($root_dir."/autoRemind/createRemind.php");//自动提醒扫描
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


checkAuthInfo();

$limitnum=$limitnum*5;
if($limitnum>100)
{
    $limitnum=100;
}
/*
$sql="update ld_reminds  set date_time=concat(DATE_FORMAT(date_time,'%Y-%m-%d'),' 09:00:00')
where   date_time<concat(DATE_FORMAT(date_time,'%Y-%m-%d'),' 09:00:00')
and push_to_weixin=2 and date_time<>DATE_FORMAT(date_time,'%Y-%m-%d');";
$adb->pquery($sql,array());*/


if($hourtime>=9 && $hourtime<=18)//工作时间
{
    $sql="select GROUP_CONCAT(remindsid) as remindsid,related_to,reltab,content,remindstype,GROUP_CONCAT(DISTINCT ld_users.wx_userid) as wx_userid,Q.date_time,Q.reminds_ruleid from ld_reminds as Q
    inner JOIN ld_users on ld_users.id = Q.recieverid
        LEFT JOIN ld_tab on ld_tab.name=Q.reltab
        where Q.deleted = 0 
            AND Q.status_rmd = '未读' 
            AND Q.is_del_rec = 0 
            AND Q.push_to_weixin = 2 
            AND Q.date_time < NOW()  
			AND Q.date_time>DATE_SUB(CURDATE(),INTERVAL 1 DAY)
        and ifnull(wxremindstype,'')<> 'immediately'
        and ld_users.wx_userid is not null and ld_users.wx_userid<>''
        and ld_users.push_wx_reminds=1
        and     not exists(select 1 from ld_tmp_wx_reminds where client_type='weixin' and date_add(createdtime, interval 10 minute)>now())
        group by content ,related_to,reltab,date_time,reminds_ruleid
        order by date_time asc  limit  $limitnum";
  
    
}
else
{
     $sql="select GROUP_CONCAT(remindsid) as remindsid,related_to,reltab,remindstype,content,GROUP_CONCAT(DISTINCT ld_users.wx_userid) as wx_userid,Q.date_time,Q.reminds_ruleid
      from ld_reminds  as Q  inner JOIN ld_users on ld_users.id = Q.recieverid
        LEFT JOIN ld_tab on ld_tab.name=Q.reltab
        where Q.deleted = 0 
            AND Q.status_rmd = '未读'
            AND Q.is_del_rec = 0 
            AND Q.push_to_weixin = 2 
            AND Q.date_time < NOW()  
			AND Q.date_time>DATE_SUB(CURDATE(),INTERVAL 1 DAY)
        and ifnull(wxremindstype,'')<> 'immediately'
        and ld_users.wx_userid is not null and ld_users.wx_userid<>''
        and ld_users.push_wx_reminds=1
        and   not exists(select 1 from ld_tmp_wx_reminds where client_type='weixin' and date_add(createdtime, interval 10 minute)>now())
        group by content ,related_to,reltab,date_time,reminds_ruleid
       order by date_time desc  limit $limitnum ";
}
$result=$adb->pquery($sql,array());

$rows=$adb->num_rows($result);
$remindsid='';
if($rows>0)
{
    $sql='insert into ld_tmp_wx_reminds(createdtime,client_type)value(?,?)';
    $adb->pquery($sql,array(date("Y-m-d H:i:s"),'weixin'));
    
}
//$filehandle=fopen($root_dir."/modules/Reminds/1.txt",'a');
//fwrite($filehandle,date("Y-m-d H:i:s").$rows."\n");
//fclose($filehandle);

$user_count_arr = [];
for($i=0;$i<$rows;$i++)
{
    $date_time=$adb->query_result($result,$i,'date_time');
    
    if($hourtime>=9 && $hourtime<=18)
    {
        
    }
    /*else if(($hourtime>=0 && $hourtime<=8)||empty($hourtime))
    {
      
    }*/
    else
    {
        $tmptime=date("H:i:s",strtotime($date_time));
        if($hourtime>=0 && $hourtime<=8)
        {
            //edit:can 20210728 自动提醒设置和客户回收提醒时间修改为上午9点
            if(($tmptime>='00:00:00'&&$tmptime<'09:00:00')||$tmptime=="")
            {
               
               $sql="update ld_reminds set 
                  date_time=CONCAT(DATE_FORMAT(date_time,'%Y-%m-%d'),' 09:00:00')
                 where ld_reminds.date_time>DATE_SUB(CURDATE(),INTERVAL 1 DAY)
                    and ifnull(wxremindstype,'')<> 'immediately'
                    and   status_rmd = '未读'
                    AND is_del_rec = 0 
                    AND push_to_weixin = 2 
                    AND date_time < NOW()  
                    and DATE_FORMAT(date_time,'%H:%i:%s')
                    BETWEEN '00:00:00' and '09:00:00' ";
                 $adb->pquery($sql,array());
                 
                            
                break;
            }
        }
        else{
              if($tmptime=='00:00:00'||$tmptime=="")
              {
                  //下班时间是按照date_time降序获取数据，所以可以break
                    break;
              }
        }
    }
    $wx_userid=$adb->query_result($result,$i,'wx_userid');
    $userids=explode(',',$wx_userid);
    $userids = array_unique($userids);
    $limit_user = 'no';
    //duan 20240520 企业微信接口限制:控制每次给每个用户发送的消息数量不超过30
    foreach($userids as $tmp_userid ){
        if(isset($user_count_arr[$tmp_userid])){
            if($user_count_arr[$tmp_userid] >=30){
                $limit_user = 'yes';
                break;
            }else{
                $user_count_arr[$tmp_userid] += 1;
            }
        }else{
            $user_count_arr[$tmp_userid] = 1;
        }
    }
    if($limit_user == 'yes'){
        continue;
    }

    $remindsid.=$adb->query_result($result,$i,'remindsid').',';
    $remindstype=$adb->query_result($result,$i,'remindstype');
    $content=$adb->query_result($result,$i,'content');
    $wx_userid=$adb->query_result($result,$i,'wx_userid');
    $reltab=$adb->query_result($result,$i,'reltab');
    $related_to=$adb->query_result($result,$i,'related_to');
    $reminds_ruleid=$adb->query_result($result,$i,'reminds_ruleid');
    
    
    $userids=explode(',',$wx_userid);
    $tmparray['remindsid']=$adb->query_result($result,$i,'remindsid');
    $tmparray['userid']=array_unique($userids);
    $tmparray['message']=$content;
    $tmparray['reltab']=$reltab;
    $tmparray['related_to']=$related_to;
    $tmparray['date_time']=date("Y-m-d H:i:s");
    $tmparray['remindtype']=$remindstype;
    $tmparray['reminds_ruleid']=$reminds_ruleid;
    $r_multi_content[]=$tmparray;
    
    
}

$remindsid=trim($remindsid,',');
$remindsid=explode(',',$remindsid);
if(is_array($r_multi_content))
{
    
    
    //editor:gyq_165 reason:企业微信消息提醒   2020/1/2 14:58
    require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/MessageCorpconversation.php");
 
    
    $remind = new MessageCorpconversation();
    $errorno = $remind->sendAllTypeRemindsImmediately($remindsid,$r_multi_content,'scanreminder');
    
}
$sql='delete from ld_tmp_wx_reminds where client_type=\'weixin\'';
$adb->pquery($sql,array());

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

//ls 2022-03-07 自动提醒（每3分钟访问一次该文件）添加功能使【crm\dataCache\weixin\auth_info.txt】文件自动生成
function checkAuthInfo(){
    if (!is_dir(globalStatic::$root_directory . 'dataCache/weixin')) {
        @mkdir(globalStatic::$root_directory . 'dataCache/weixin/', 0777, true);
    }
    if (!file_exists(globalStatic::$root_directory . 'dataCache/weixin/auth_info.txt')) {
        file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/auth_info.txt', '');
        chmod(globalStatic::$root_directory . 'dataCache/weixin/auth_info.txt', 0777);
    }

    $exist_auth_info = getWeiXinAuthInfo();
    $exist_auth_arr = json_decode($exist_auth_info, true);

    if (!isset($exist_auth_arr['crm'])) {//为空时生成
        if (isset($_REQUEST['corpindex']) && !empty($_REQUEST['corpindex'])) {
            crm_load_class_file('StaticConst','WeiXinApp/WeiXin_common');
            require_once(globalStatic::$root_directory.'appCommon/appCommon.php');

            $corpindex = (int)$_REQUEST['corpindex'];
            $sessiontime = 'lingdang' . $_REQUEST['sessiontime'];
            $url = StaticConst::$server_api_header . 'debug/index.php?corpindex='.$corpindex.'&sessiontime='.$sessiontime;
            $output = CurlGet($url);

        }else{
            return false;
        }
    }

    return true;
}
?>