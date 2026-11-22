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
$sql="SELECT id FROM ld_users  WHERE ld_users.wx_userid is not null AND ld_users.wx_userid<>'' ";
$result=$adb->pquery($sql,array());
$limitnum=$adb->num_rows($result);


if($limitnum<=0)
{
    exit();
}
$limitnum=$limitnum*5;
if($limitnum>100)
{
    $limitnum=100;
}
//file_put_contents($root_dir."/dataCache/weixin/selfbuildinfo.txt",'selfbuildinfo');

if($hourtime>=9 && $hourtime<=18)//工作时间
{
	//工作时间：发送全部提醒，按照提醒时间倒序发送当天的提醒
    $sql="
		SELECT
			GROUP_CONCAT(remindsid) AS remindsid,
			related_to,
			reltab,
			content,
			remindstype,
			GROUP_CONCAT(DISTINCT wx_userid) AS wx_userid,
			date_time,
			reminds_ruleid 
		FROM (
			SELECT 
					remindsid,
					related_to,
					reltab,
					content,
					remindstype,
					ld_users.wx_userid,
					Q.date_time,Q.reminds_ruleid 
			FROM ld_reminds AS Q
			INNER JOIN ld_users ON ld_users.id = Q.recieverid
			LEFT JOIN ld_tab ON ld_tab.name=Q.reltab
			WHERE Q.deleted = 0 
				AND Q.status_rmd = '未读' 
				AND Q.is_del_rec = 0 
				AND Q.push_to_wxselfbuilt = 2 
				AND Q.date_time < NOW()  
				AND Q.date_time>DATE_SUB(CURDATE(),INTERVAL 5 MINUTE)
				AND ifnull(wxremindstype,'')<> 'immediately'
				AND ld_users.wx_userid is not null AND ld_users.wx_userid<>''
				AND ld_users.push_wx_reminds=1
				AND NOT exists(SELECT 1 FROM ld_tmp_wx_reminds WHERE client_type='wxselfbuilt' AND date_add(createdtime, interval 10 minute)>now())
			ORDER BY date_time DESC LIMIT $limitnum
		) a
		GROUP BY content,related_to,reltab,date_time";
}
else
{
	//非工作时间：只发送最近1个小时之内提醒，按照提醒时间倒序发送当天的提醒 (by luyx 2024-05-23)
 $sql="
		SELECT
			GROUP_CONCAT(remindsid) AS remindsid,
			related_to,
			reltab,
			content,
			remindstype,
			GROUP_CONCAT(DISTINCT wx_userid) AS wx_userid,
			date_time,
			reminds_ruleid 
		FROM (
			SELECT 
					remindsid,
					related_to,
					reltab,
					content,
					remindstype,
					ld_users.wx_userid,
					Q.date_time,Q.reminds_ruleid 
			FROM ld_reminds AS Q
			INNER JOIN ld_users ON ld_users.id = Q.recieverid
			LEFT JOIN ld_tab ON ld_tab.name=Q.reltab
			WHERE Q.deleted = 0 
				AND Q.status_rmd = '未读' 
				AND Q.is_del_rec = 0 
				AND Q.push_to_wxselfbuilt = 2 
				AND Q.date_time < NOW()  
				AND Q.date_time>DATE_SUB(NOW(),INTERVAL 60 MINUTE)
				AND ifnull(wxremindstype,'')<> 'immediately'
				AND ld_users.wx_userid is not null AND ld_users.wx_userid<>''
				AND ld_users.push_wx_reminds=1
				AND NOT exists(SELECT 1 FROM ld_tmp_wx_reminds WHERE client_type='wxselfbuilt' AND date_add(createdtime, interval 10 minute)>now())
			ORDER BY date_time DESC LIMIT $limitnum
		) a
		GROUP BY content,related_to,reltab,date_time";
}
$result=$adb->pquery($sql,array());

$rows=$adb->num_rows($result);
$remindsid='';
if($rows>0)
{
    $sql='insert into ld_tmp_wx_reminds(createdtime,client_type)value(?,?)';
    $adb->pquery($sql,array(date("Y-m-d H:i:s"),'wxselfbuilt'));
    
}

for($i=0;$i<$rows;$i++)
{
    $date_time=$adb->query_result($result,$i,'date_time');
    $rid = $adb->query_result($result,$i,'remindsid');
    $remindsid .= $rid.',';
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
                    AND push_to_wxselfbuilt = 2 
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
    $content=$adb->query_result($result,$i,'content');
    $wx_userid=$adb->query_result($result,$i,'wx_userid');
    $reltab=$adb->query_result($result,$i,'reltab');
    $related_to=$adb->query_result($result,$i,'related_to');
    $reminds_ruleid=$adb->query_result($result,$i,'reminds_ruleid');
    
    
    $userids=explode(',',$wx_userid);
    $tmparray['userid']=array_unique($userids);
    $tmparray['message']=$content;
    $tmparray['reltab']=$reltab;
    $tmparray['related_to']=$related_to;
    $tmparray['date_time']=date("Y-m-d H:i:s");
    $tmparray['remindtype']=$remindstype;
    $tmparray['reminds_ruleid']=$reminds_ruleid;
    $tmparray['remindsid']=$rid;
    $r_multi_content[]=$tmparray;
    
    
}

$remindsid=trim($remindsid,',');
$remindsid=explode(',',$remindsid);
if(is_array($r_multi_content))
{
    require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/MessageCorpconversation.php");

    $remind = new MessageCorpconversation();
    $errorno = $remind->sendAllTypeRemindsImmediately($remindsid,$r_multi_content);
    
}

$sql='delete from ld_tmp_wx_reminds where client_type=\'wxselfbuilt\'';
$adb->pquery($sql,array());
echo 'ok';
?>