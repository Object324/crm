<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);
//wyt 220805 XUQIU1000508 小程序增加消息提醒功能，关注公众号，接收提醒（第三版）
//小程序提醒 交付模板  “交付提醒”、“产品服务到期提醒”、“收付款计划到期提醒” “线索、客户回收提醒、即将回收提醒”
$root_dir= dirname(dirname(dirname(__FILE__)));

$baimingip=array("139.196.42.204","139.196.108.146","111.231.135.110",'101.80.148.115','127.0.0.1');
date_default_timezone_set('Asia/Shanghai');
global $adb;
$_GET['intervalsearch']='yes';
include($root_dir."/autoRemind/createRemind.php");//自动提醒扫描
if(!$adb)
{
    $adb = PearDatabase::getInstance();
}
$hourtime=intval(date("H"));
$sql = "select 
    offiaccount.open_id,miniprograme.wechatuserid
    from (
        select * from ld_wechatuser where userfromvalue='CRMminiprogram' and deleted=0 and userid>0 and ifnull(unionid,'')<>''
    )miniprograme
    left join( 
        select * from ld_wechatuser where userfromvalue='CRMoffiaccount' and deleted=0 and ifnull(unionid,'')<>'' and  ifnull(open_id,'')<>''
    )offiaccount on miniprograme.unionid=offiaccount.unionid
    where offiaccount.open_id is not null";
$result=$adb->pquery($sql,array());
$limitnum=$adb->num_rows($result);
if($limitnum<=0)
{
    exit();
}

$limitnum = $limitnum*5;
if($limitnum>100)
{
    $limitnum=100;
}
//zxm 20221104  or reminds_ruleid>0 自动提醒
    $sql="SELECT 
		GROUP_CONCAT(remindsid) as remindsid,
		related_to,
		reltab,
		content,
		remindstype,
		Q.date_time,
		Q.reminds_ruleid 
	FROM ld_reminds as Q
    INNER JOIN ld_users on ld_users.id = Q.recieverid
    LEFT JOIN ld_tab on ld_tab.name=Q.reltab
    WHERE Q.deleted = 0 
        AND Q.status_rmd = '未读' 
        AND Q.is_del_rec = 0 
        AND Q.push_to_offiaccount = 2 
        AND Q.date_time < NOW()  
		AND Q.date_time>DATE_SUB(CURDATE(),INTERVAL 1 DAY)
        AND ifnull(wxremindstype,'')<> 'immediately'
        and ld_users.push_wx_reminds = 1
        AND (remindstype IN ('SalesOrderDueDate','PaymentPlanPlanDate','ServiceContractsDueDate','SendPaymentPlanDate','AccountsRECYCLEREMIND','LeadsRECYCLEREMIND','CalendarCreateRemind','ContactRecordsDate','ModuleCreateRemind','MODULECOMMENTRemind','AccountsBEFOREREMIND','LeadsBEFOREREMIND') OR ifnull(remindstype,'')='' OR reminds_ruleid>0)
    GROUP BY content ,related_to,reltab,date_time,reminds_ruleid
    ORDER BY date_time desc  limit  $limitnum";
$result=$adb->pquery($sql,array());
$rows=$adb->num_rows($result);
$remindsid='';
for($i=0;$i<$rows;$i++)
{
    $date_time=$adb->query_result($result,$i,'date_time');
    $rel_tab=$adb->query_result($result,$i,'reltab');
    $crmid=$adb->query_result($result,$i,'related_to');
    if($crmid>0){
        $salesEntityType = getSalesEntityType($crmid);
        //zxm 20230925 如果单据被删除 例如收款单被删除 后面函数获取单据信息就报错，所以要加这个判断
        if(!empty($salesEntityType)){
            $tmpfocus = CRMEntity::getInstance($rel_tab);

            $tmpfocus->retrieve_entity_info($crmid,$rel_tab);
            $col_fields = $tmpfocus->column_fields;
            $smownercolumname = $tmpfocus->getSmownerColumName();
            $smownerfieldname = 'assigned_user_id';
            if(!empty($tmpfocus->fieldobj)){
                $smownerfieldname = $tmpfocus->fieldobj->getFieldInfoBykeyValue('columnname',$smownercolumname,'fieldname');
            }
            $subject[$crmid]['table_code']=$col_fields[$tmpfocus->table_code];//编号
            $subject[$crmid]['subject'] = $col_fields[$tmpfocus->list_link_field];//超链接字段
            $smownerid = $col_fields[$smownerfieldname];//负责人编号
            $swomnerlastname = getUserFullName($smownerid);
            $subject[$crmid]['smownername'] = $swomnerlastname;//单据负责人
        }
    }

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
                    and status_rmd = '未读'
                    AND is_del_rec = 0 
                    AND push_to_offiaccount = 2 
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
    $remindsid.=$adb->query_result($result,$i,'remindsid').',';
    $remindstype=$adb->query_result($result,$i,'remindstype');
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
    $tmparray['remindtype']='jiaofu';
    $tmparray['reminds_ruleid']=$reminds_ruleid;
    $r_multi_content[]=$tmparray;
}

$remindsid=trim($remindsid,',');
$remindsid=explode(',',$remindsid);
if(is_array($r_multi_content))
{
    //editor:gyq_165 reason:企业微信消息提醒   2020/1/2 14:58
    require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_offiaccount.php");
    //$remind = new MessageCorpconversation();
    //$errorno = $remind->sendAllTypeRemindsImmediately($remindsid,$r_multi_content,'jiaofu',$subject);
    //zxm 20221116 公众号提醒消息单独请求
    $offiaccount_remind = new cls_reminds_offiaccount();
    //wyt 221121 XUQIU1000569 小程序增加消息提醒功能，关注公众号，接收提醒（第四版）  不同模板
    if($remindstype=='CalendarCreateRemind'||$remindstype=='ContactRecordsDate'||$remindstype=='ModuleCreateRemind'){
        $offiaccount_remind->sendAllTypeRemindsImmediately($remindsid,'other',$subject);
    }
    else{
        $offiaccount_remind->sendAllTypeRemindsImmediately($remindsid,'jiaofu',$subject);
    }
    
}

?>