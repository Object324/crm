<?php
global $adb, $current_user;
//@edit:zkt @date:2024/12/19 @reason: url验证
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//require_once("data/Tracker.php");
//require_once('modules/lingdang/layout_utils.php');
//require_once('include/utils/utils.php');
//require_once('modules/Reminds/Reminds.php');

$cur_time = time();
/**
 * edit:can
 * reason:循环提醒(V5.4)
 * */
$smarty = new lingdangCRM_Smarty;
$deployarray=getSys_deploy(51);
$deployvalue = $deployarray['deploy_value'];
$smarty->assign("Reminds_See_Set",$deployvalue);
$date = date('Y-m-d H:i:s',$cur_time);
$startdate = date('Y-m-d',$cur_time)." 00:00:00";
$enddate = date('Y-m-d',$cur_time)." 23:59:59";

if($_REQUEST['type']=='getViewReminds'){// wyt  221215 BUG0059939 消息提醒，点击头部弹出层中已读，右下角消息弹出层出现了，建议根据系统设置隐藏

$_REQUEST['diony']='yes';
    ConvertTojsonString(1,$deployvalue,"success");
}

$sql ="SELECT distinct ld_tmpreminder.*  FROM ld_tmpreminder
LEFT JOIN ld_reminds ON ld_reminds.related_to = ld_tmpreminder.related_to
AND ld_reminds.reminds_ruleid = ld_tmpreminder.reminds_ruleid 
WHERE  remindtime <='".$enddate."' and ld_tmpreminder.reminderid = '".$current_user->id."' 
and IFNULL(DATE_FORMAT(ld_reminds.date_time,'%y-%m-%d'),'')<>DATE_FORMAT(ld_tmpreminder.remindtime,'%y-%m-%d') 
ORDER BY id ASC,remindtime DESC  limit 0,4";

$tmpresult=$adb->pquery($sql,array());
$entitysql = 'insert into ld_crmentity(crmid,setype) value(?,?);';
$remindsql = 'insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,reminds_ruleid,smcreatorid,smownerid,modifiedby,description,createdtime,modifiedtime)
                    value(?,?,?,?,?,?,?,?,?,?,?,?,?,?);';

//echo $adb->num_rows($tmpresult);
for($i=0;$i<$adb->num_rows($tmpresult);$i++)
{
    $tmpremindid=$adb->query_result($tmpresult,$i,'id');
    $remindcontent=$adb->query_result($tmpresult,$i,'content');
    $reminderid=$adb->query_result($tmpresult,$i,'reminderid');
    $remindtime=$adb->query_result($tmpresult,$i,'remindtime');
    $related_to=$adb->query_result($tmpresult,$i,'related_to');
     $reltab=$adb->query_result($tmpresult,$i,'reltab');
    $remindcontent = getResult($remindcontent,$related_to,$reltab);
 
   
    $reminds_ruleid=$adb->query_result($tmpresult,$i,'reminds_ruleid');
    $crmid= $adb->getUniqueID("ld_crmentity");
    $adb->pquery($entitysql,array($crmid,'Reminds'));
    $adb->pquery($remindsql,array($crmid,$remindcontent,$remindtime,$reminderid,'未读',$related_to,$reltab,$reminds_ruleid,$reminderid,$reminderid,$reminderid,'',$date,$date));     
   
    $sql='delete from ld_tmpreminder where id='.$tmpremindid;
    
    $adb->pquery($sql,array());
}

/**
 * edit:diony
 * 2014-12-04
 * 如果是基金行业
 * 根据有积分变动的客户ID，来更新积分信息 
*/
if(get_versiontrade()=='fund')
{
    require_once(globalStatic::$root_directory.'include/trade/fund.php');
    $fm_months =trade_fund::getMonthForType(2).'-01';
    //$fm_months = '2017-12-01';
    $tiemArr = explode("-",$fm_months);
    $lintegralArray=getSys_deploy(60);
    $lintegralValue = $lintegralArray['deploy_value'];
    $integralSql='select id,accountid from ld_handleintegral order by id asc limit 0,5 ';
    $integralResult=$adb->pquery($integralSql,array());
    
    for($i=0;$i<$adb->num_rows($integralResult);$i++)
    {
        trade_fund::RemindsPopup();
    }
    
    
}

$callback_counts = 'select count(remindsid) from( select remindsid from ld_reminds WHERE ld_reminds.deleted=0 and recieverid='.$current_user->id.' and status_rmd="未读" and is_del_rec=0 and date_time<="'.$date.'" and remindsid > 0 ';

$callback_counts .= ' union all select remindsid from ld_reminds_accepted WHERE ld_reminds_accepted.deleted=0 and recieverid='.$current_user->id.' and status_rmd="未读" and is_del_rec=0 and date_time<="'.$date.'" and remindsid > 0 ) as tmp';
//zkt 20220527 51613【亿海蓝】首页下方弹窗提醒，点击下一条消息。下方显示很多代码杨海超：kfbcrm也有同样的问题
$id=$_REQUEST['remindsid'];
if($_REQUEST['pages']=='down')
{
   $order="where remindsid < '$id' order by remindsid desc,date_time desc";
   $pagenum=$_REQUEST['pagenum'];
   $smarty->assign('PAGENUM',$pagenum+1);
}
elseif($_REQUEST['pages']=='up')
{
   $pagenum=$_REQUEST['pagenum'];
   $order="where  remindsid > '$id' order by remindsid asc,date_time desc";
   $smarty->assign('PAGENUM',$pagenum-1);
}
//edit:xll 2023/05/04 BUG0065801 kfbcrm-右上角消息，点击推迟后应留在当页
elseif($_REQUEST['current_page'] > 0){
    $current_page = $_REQUEST['current_page'];
    $is_last = $_REQUEST['is_last'];
    $smarty->assign('PAGENUM',$current_page);
    $order = "where remindsid < '$id' order by remindsid desc,date_time desc";
    $order_last = "where  remindsid > '$id' order by remindsid asc,date_time desc";
    $order = ($is_last == 1) ? $order_last : $order;
    //dump($order);
}
else{
    $smarty->assign('PAGENUM',1);
    $order="order by remindsid desc,date_time desc ";
}
$callback_query = 'select ld_reminds.reltab,ld_reminds.date_time,ld_reminds.content,ld_reminds.related_to
        ,ld_users.last_name,remindsid from ld_reminds 
left join ld_users ON ld_reminds.smcreatorid = ld_users.id 
WHERE ld_reminds.deleted=0 and 
recieverid='.$current_user->id.' and status_rmd="未读" and is_del_rec=0
 and date_time<="'.$date.'" and remindsid > 0 ';
 
 
 $callback_query.=' union all select ld_reminds_accepted.reltab,ld_reminds_accepted.date_time,ld_reminds_accepted.content,ld_reminds_accepted.related_to
        ,ld_users.last_name,remindsid from ld_reminds_accepted 
left join ld_users ON ld_reminds_accepted.smcreatorid = ld_users.id 
WHERE ld_reminds_accepted.deleted=0 and 
recieverid='.$current_user->id.' and status_rmd="未读" and is_del_rec=0
 and date_time<="'.$date.'" and remindsid > 0 ';
 
 
 $callback_query='select * from ( '.$callback_query.') as tmp '.$order.' limit 1 ';

$result_counts = $adb->query($callback_counts);
$counts=0;
if($adb->num_rows($result_counts)>0)
$counts = $adb->query_result($result_counts, 0);

if($counts<=0)
    exit();

$result = $adb->query($callback_query);

$reltab = $adb->query_result($result, 0,'reltab');
$date_time = $adb->query_result($result, 0,'date_time');
$last_name = $adb->query_result($result, 0,'last_name');
$content = $adb->query_result($result, 0,'content');
$remindsid = $adb->query_result($result, 0,'remindsid');
$parent_id = $adb->query_result($result, 0,'related_to');
if($last_name=='')$last_name='system';
	if (!empty($parent_id)) {
			$parent_module = getSalesEntityType($parent_id);
			$valueTitle = $parent_module;
			$valueTitle = getTranstab($valueTitle);
			$displayValueArray = getEntityName($parent_module, $parent_id);
			if (!empty($displayValueArray)) {
				foreach ($displayValueArray as $key => $value) {
					$displayValue = $value;
				}
			}
			$label_fld ="<a target='_blank' href='index.php?pageto_module=$parent_module&pageto_action=index&pageto_record=$parent_id' title='$valueTitle'>$displayValue</a>";
			/**
			 * 判断合同订单、服务收费模块时，获取对应的客户信息并添加到单据后面
			 * @reason 0014117: 合同订单（服务合同），审批通过后，提醒信息改进需求
			 * @author Tujt 2015-04-28
			 */
			$accountarr = array();
			switch($parent_module){
			    case 'SalesOrder':
			        $qeury = 'SELECT ld_account.accountid,ld_account.accountname 
								FROM ld_salesorder 
									INNER JOIN ld_account 
										ON ld_account.accountid = ld_salesorder.accountid 
								WHERE ld_salesorder.salesorderid = '.$parent_id.' LIMIT 1;';
					//and ld_salesorder.deleted = 0
					$result = $adb->query($qeury);
					$rows = $adb->num_rows($result);
					if(1 == $rows){
						$accountarr['accountid'] = $adb->query_result($result, 0,'accountid');
						$accountarr['accountname'] = $adb->query_result($result, 0,'accountname');
					}
			        break;
			    case 'ServiceContracts':
			        $qeury = 'SELECT ld_account.accountid,ld_account.accountname 
								FROM ld_servicecontracts 
									INNER JOIN ld_account 
										ON ld_account.accountid = ld_servicecontracts.accountid 
								WHERE ld_servicecontracts.servicecontractsid = '.$parent_id.' LIMIT 1;';
					//and ld_salesorder.deleted = 0
					$result = $adb->query($qeury);
					$rows = $adb->num_rows($result);
					if(1 == $rows){
						$accountarr['accountid'] = $adb->query_result($result, 0,'accountid');
						$accountarr['accountname'] = $adb->query_result($result, 0,'accountname');
					}
			        break;
	           case 'ContactRecords':
			        $qeury = 'SELECT ld_account.accountid,ld_account.accountname 
								FROM ld_contactrecords 
									INNER JOIN ld_account 
										ON ld_account.accountid = ld_contactrecords.accountid 
								WHERE ld_contactrecords.contactrecordID = '.$parent_id.' LIMIT 1;';
					//and ld_salesorder.deleted = 0
					$result = $adb->query($qeury);
					$rows = $adb->num_rows($result);
					if(1 == $rows){
						$accountarr['accountid'] = $adb->query_result($result, 0,'accountid');
						$accountarr['accountname'] = $adb->query_result($result, 0,'accountname');
					}
			        break;
			}
			if(!empty($accountarr)){
			     /*
                 *  diony 2016-06-20
                 *	0022975: 温馨提醒弹出层：弹出层中客户名称链接字段值没有显示为蓝色字体
                 *  去掉 style="color:#666666;" 
                 */
				 //chj 2021/1/5 43984: 右下角消息提醒：合同订单提醒，分别点击超链接中的“合同编号”和“客户名称”，打开详情界面方式不一样
                 $label_fld .="<a target='_blank' href='index.php?pageto_module=Accounts&pageto_action=index&pageto_record=".$accountarr['accountid']."' title='".$accountarr['accountname']."'>(".$accountarr['accountname'].")</a>";
				//$label_fld .= '&nbsp;<a referencemodule="Accounts" referencerecord="'.$accountarr['accountid'].'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" title="'.getTranstab('Accounts').'">('.$accountarr['accountname'].')</a>';
			}//end
      }
//如果最新的一条提醒没有relatab，则列表刷新不生成对话框提醒
if($counts>0) {
    $smarty->assign("reltab", $reltab);
    $smarty->assign("date_time", $date_time);
    $smarty->assign("last_name", $last_name);
    //考虑提醒有html的内容
    
    $smarty->assign("content",htmlentities($content));
    $smarty->assign("counts", $counts);
    $smarty->assign("remindsid",$remindsid);
    $smarty->assign("label_fld",$label_fld);
  
    if($reltab!='ReportLog'&&!empty($reltab)&&$reltab!='CooperativeWork')
    {
        $relfocus=CRMEntity::getInstance($reltab);
        if($relfocus)
        {//32501: 企业微信消息提醒
            $listlinkfield=$relfocus->list_link_field;
            $fieldlabel=$relfocus->fieldobj->getFieldInfoBykeyValue("fieldname",$listlinkfield,'fieldlabel');
            $smarty->assign("LISTLINKFIELDLABEL",$fieldlabel);
        }
    }
    else
    {
        $smarty->assign("LISTLINKFIELDLABEL",getTranstab($reltab));
    }
    $smarty->assign("Expand",'no');
    if($_REQUEST['pagenum']>0||$_REQUEST['action']=='SetRemindReaden')
    {
        $smarty->assign("Expand",'yes');
    }
	$smarty->display("RemindsPopup.tpl");
}

function getResult($Content,$crmid,$reltab)
{        
    global $adb;
     crm_load_class_file('AutoRemindContent','include/VarGeneralBol');
    
     
     $approvenotice=new AutoRemindContent($reltab,$crmid);//变量提醒内容
     $remindcontent=$approvenotice->getContent($Content);

     
     return $remindcontent;
    
    return implode('',$printcols);
}

?>