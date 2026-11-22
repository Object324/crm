<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);
header('Access-Control-Allow-Origin: *');
//ls 20221025 XUQIU1000796    泛微电脑端审批消息推送开发
$root_dir= dirname(dirname(dirname(__FILE__)));
$baimingip=array("139.196.42.204","139.196.108.146","111.231.135.110",'101.80.148.115','127.0.0.1');
date_default_timezone_set('Asia/Shanghai');
global $adb;
$_GET['intervalsearch']='yes';
//include($root_dir."/autoRemind/createRemind.php");//自动提醒扫描
require_once($root_dir.'/includefile.php');//上面注释的话，需要引入includefile.php
if(!$adb)
{
    $adb=PearDatabase::getInstance();
}
$hourtime=intval(date("H"));
$sql="SELECT id from ld_users  WHERE ld_users.phone_mobile is not null and ld_users.phone_mobile<>'' ";
$result=$adb->pquery($sql,array());
$limitnum=$adb->num_rows($result);

if($limitnum<=0)
{
    exit();
}
$limitnum=$limitnum*5;
if($limitnum>100)
{
    $limitnum=500;
}
//泛微OA消息提醒需求修改：
//1.扫描前，CRM提醒消息已读的不会发送
//2.按顺序有四个人 A B C D审批，很快都审批完了，A有提醒，其他人没有审批提醒
//去掉已读未读条件，没发送过的都发送

$sql="SELECT 
    remindsid,
    Q.smcreatorid AS creator,
    related_to,
    reltab,
    content,
    remindstype,
    ld_users.id AS received_id,
    Q.date_time,Q.reminds_ruleid 
FROM ld_reminds Q
INNER JOIN ld_users on ld_users.id = Q.recieverid
LEFT JOIN ld_tab on ld_tab.name=Q.reltab
WHERE Q.deleted = 0 
--	AND (Q.status_rmd = '未读' OR (Q.status_rmd = '已读' and ifnull(readedtime,'') <> ''))
    AND Q.is_del_rec = 0 
    AND Q.push_to_fw = 2 
    AND Q.date_time < NOW()  
    AND Q.date_time>DATE_SUB(CURDATE(),INTERVAL 1 DAY)
    AND IFNULL(remindstype,'') in('Approve','ExpeditingApprove','ForceAntiApprove','AntiApprove')
    AND ld_users.phone_mobile is not null AND ld_users.phone_mobile<>''
--    AND ld_users.push_wx_reminds=1
    AND NOT EXISTS (SELECT 1 FROM ld_tmp_wx_reminds WHERE client_type='fw')
ORDER BY date_time ASC,remindsid ASC  limit  $limitnum";




$result=$adb->pquery($sql,array());
$query=$sql;
$rows=$adb->num_rows($result);
$remindsid='';
if($rows>0)
{
    $sql='insert into ld_tmp_wx_reminds(createdtime,client_type)value(?,?)';
    $adb->pquery($sql,array(date("Y-m-d H:i:s"),'fw'));

}
//$filehandle=fopen($root_dir."/modules/Reminds/1.txt",'a');
//fwrite($filehandle,date("Y-m-d H:i:s").$rows."\n");
//fclose($filehandle);


for($i=0;$i<$rows;$i++)
{
    $date_time=$adb->query_result($result,$i,'date_time');
    $remindsid.=$adb->query_result($result,$i,'remindsid').',';
    $remindstype=$adb->query_result($result,$i,'remindstype');

    $content=$adb->query_result($result,$i,'content');
    $received_id=$adb->query_result($result,$i,'received_id');
    $reltab=$adb->query_result($result,$i,'reltab');
    $related_to=$adb->query_result($result,$i,'related_to');
    $reminds_ruleid=$adb->query_result($result,$i,'reminds_ruleid');
    $creator=$adb->query_result($result,$i,'creator');
    $tmparray['received_id']=$received_id;
    $tmparray['message']=$content;
    $tmparray['reltab']=$reltab;
    $tmparray['related_to']=$related_to;
    $tmparray['date_time']=$date_time;
    $tmparray['remindtype']=$remindstype;
    $tmparray['remindsid']=$adb->query_result($result,$i,'remindsid');
    $tmparray['reminds_ruleid']=$reminds_ruleid;
    $tmparray['creator']=$creator;
    $r_multi_content[]=$tmparray;


}

$remindsid=trim($remindsid,',');
$remindsid=explode(',',$remindsid);
if(is_array($r_multi_content))
{
    require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_fw.php");

    $remind = new cls_reminds_fw();
    $errorno = $remind->sendAllTypeRemindsImmediately($remindsid,$r_multi_content,'Approve');

}
$sql='delete from ld_tmp_wx_reminds where client_type=\'fw\'';
$adb->pquery($sql,array());

?>