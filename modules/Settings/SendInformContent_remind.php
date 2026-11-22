<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/*确认出库时是否发送短信通知客户*/

global $adb;
global $current_user;
$smarty = new lingdangCRM_Smarty;
if(isset($_REQUEST['record']) && $_REQUEST['record'] != '')
{   
    $smarty->assign("CONTENT",strip_tags($_REQUEST['remind_content']));
    
    $smarty->assign("record",$_REQUEST['record']);
}else{
    $smarty->assign("CONTENT",strip_tags($_REQUEST['remind_content']));
}


/**
 * 更新操作
 * edit:lmx
 * time:20140303
 * reson:0007275: 建议：“出库单”设置短信短语格式，希望变量信息中，默认为当前模块
 */
//ls 2021-09-16 【ID1002056】短信“内容模板”中增加“负责人”、“负责人手机”、“客户公司电话”通配符(自动提醒可选其它模块变量)
//$sql="select  tabid,name,tablabel from ld_tab where name in('accounts','contacts','quotes','salesorder','invoice','products','paymentplan','potentials','helpdesk','expense','contactrecords','vendors','purchaseorder','Stock','OutboundOrder','Checks') and presence in(0,2)";
//$result=$adb->pquery($sql,array());
//$sql="select  tabid,name,tablabel from ld_tab where tabid=? and presence in(0,2)";
//$result=$adb->pquery($sql,array($_REQUEST['tabid']));

//ls 2021-09-24 0048074: （https://81mis.com/kfbcrm [^]）系统设置->自动提醒设置，内容模板选择变量时选不到“收款单、销售线索”等模块变量信息（sql同AutomaticReminds.php一致）
$languageType= getLanguageType($current_user);
$sql="select DISTINCT ld_tab.tabid,name ,tablabel from ld_tab
inner join ld_tranlabel on ld_tab.tabid=ld_tranlabel.relateid
 where  languagetype=? and trantable=?  and presence in(0,2) 
AND name NOT IN ('Home','MassSMS','MassEmails','SmsPhrases','MailManager','Emails','SalesGoal',
'EmailListtmp','CommunicationLog','Navigation','InventoryLedger','InventoryAccount',
'InventoryQuery','Prdtnums','BankCash','OftenUseReport','Dashboard','Comprehensivereport',
'Reports','Reminds','FieldFormulas','Cache','reportlog','recyclebin','Faq','Customreport','CooperativeWork','ChinaMap','CustomEcharts') and ld_tab.tabid > 0 GROUP BY tabid  order by tabsequence ";
$result=$adb->pquery($sql,array($languageType,'ld_tab'));

$printtabs=array();
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $printtabs[$adb->query_result($result,$i,'tabid')]=getTranstab($adb->query_result($result,$i,'tablabel'));
}
$smarty->assign("PRINTTABS",$printtabs);
$smarty->assign("TABID",$_REQUEST['tabid']);

 $_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('REMINDSCONTENT');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['reminder_user_array'] = json_encode($reminder_user_array);
$str=$smarty->fetch("modules/MassSMS/SendInformContent_remind.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();

?>