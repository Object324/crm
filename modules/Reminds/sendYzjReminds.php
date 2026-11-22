<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);

$root_dir= dirname(dirname(dirname(__FILE__)));
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
$sql="SELECT id from ld_users  WHERE ld_users.yunzhijia_openid is not null and ld_users.yunzhijia_openid<>'' ";
$result=$adb->pquery($sql,array());
$limitnum=$adb->num_rows($result);

if($limitnum<=0)
{
    exit();
}
$limitnum=$limitnum*5;
if($limitnum>100)
{
    $limitnum=10;
}

if($hourtime>=9 && $hourtime<=18)//工作时间
{
    $sql="SELECT 
		GROUP_CONCAT(remindsid) AS remindsid,
		related_to,
		reltab,
		content,
		remindstype,
		GROUP_CONCAT(DISTINCT ld_users.id) AS received_id,
		Q.date_time,Q.reminds_ruleid 
	FROM ld_reminds Q
    INNER JOIN ld_users on ld_users.id = Q.recieverid
	LEFT JOIN ld_tab on ld_tab.name=Q.reltab
	WHERE Q.deleted = 0 
		AND Q.status_rmd = '未读' 
		AND Q.is_del_rec = 0 
		AND Q.push_to_yzj = 2 
		AND Q.date_time < NOW()  
		AND Q.date_time>DATE_SUB(CURDATE(),INTERVAL 1 DAY)
		AND IFNULL(wxremindstype,'')<> 'immediately'
		AND ld_users.yunzhijia_openid is not null AND ld_users.yunzhijia_openid<>''
        and (yunzhijia_wbuserid is not null and yunzhijia_wbuserid<>'')
		AND ld_users.push_wx_reminds=1
		AND NOT EXISTS (SELECT 1 FROM ld_tmp_wx_reminds WHERE client_type='yunzhijia' AND date_add(createdtime, interval 10 minute)>now())
	GROUP BY content ,related_to,reltab,date_time,reminds_ruleid
	ORDER BY date_time ASC  limit  $limitnum";

}
else
{
    $sql="SELECT 
		GROUP_CONCAT(remindsid) as remindsid,
		related_to,
		reltab,
		remindstype,
		content,
		GROUP_CONCAT(DISTINCT ld_users.id) as received_id,
		Q.date_time,Q.reminds_ruleid
	FROM ld_reminds Q  inner JOIN ld_users on ld_users.id = Q.recieverid
	LEFT JOIN ld_tab on ld_tab.name=Q.reltab
	WHERE Q.deleted = 0 
		AND Q.status_rmd = '未读'
		AND Q.is_del_rec = 0 
		AND Q.push_to_yzj = 2 
		AND Q.date_time < NOW() 
		AND Q.date_time>DATE_SUB(CURDATE(),INTERVAL 1 DAY)
		AND ifnull(wxremindstype,'')<> 'immediately'
		AND ld_users.yunzhijia_openid is not null and ld_users.yunzhijia_openid<>'' 
        and (yunzhijia_wbuserid is not null and yunzhijia_wbuserid<>'')
		AND ld_users.push_wx_reminds=1
		AND not exists(SELECT 1 FROM ld_tmp_wx_reminds WHERE client_type='yunzhijia' AND date_add(createdtime, interval 10 minute)>now())
	GROUP BY content ,related_to,reltab,date_time,reminds_ruleid
	ORDER BY date_time DESC limit $limitnum ";
}

$result=$adb->pquery($sql,array());
$query=$sql;
$rows=$adb->num_rows($result);
$remindsid='';
if($rows>0)
{
	$sql='insert into ld_tmp_wx_reminds(createdtime,client_type)value(?,?)';
	$adb->pquery($sql,array(date("Y-m-d H:i:s"),'yunzhijia'));

}
//$filehandle=fopen($root_dir."/modules/Reminds/1.txt",'a');
//fwrite($filehandle,date("Y-m-d H:i:s").$rows."\n");
//fclose($filehandle);

require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_yzj.php");

$remind = new cls_reminds_yzj();
for($i=0;$i<$rows;$i++)
{
    $date_time=$adb->query_result($result,$i,'date_time');
    $remindsid=$adb->query_result($result,$i,'remindsid').',';
    $remindstype=$adb->query_result($result,$i,'remindstype');
    if($hourtime>=9 && $hourtime<=18)
    {

    }
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
    $r_multi_content=[];
    $content=$adb->query_result($result,$i,'content');
    $received_id=$adb->query_result($result,$i,'received_id');
    $reltab=$adb->query_result($result,$i,'reltab');
    $related_to=$adb->query_result($result,$i,'related_to');
    $reminds_ruleid=$adb->query_result($result,$i,'reminds_ruleid');
    $tmparray['received_id']=$received_id;
    $tmparray['message']=$content;
    $tmparray['reltab']=$reltab;
    $tmparray['related_to']=$related_to;
    $tmparray['date_time']=date("Y-m-d H:i:s");
    $tmparray['remindtype']=$remindstype;
	$tmparray['remindsid']=$adb->query_result($result,$i,'remindsid');
    $tmparray['reminds_ruleid']=$reminds_ruleid;
    $r_multi_content[]=$tmparray;
    $remindsid=trim($remindsid,',');
    $remindsid_arr=explode(',',$remindsid);
    if(is_array($r_multi_content))
    {

        $errorno = $remind->sendAllTypeRemindsImmediately($remindsid_arr,$r_multi_content);

    }

}


$sql='delete from ld_tmp_wx_reminds where client_type=\'yunzhijia\'';
$adb->pquery($sql,array());
 
?>