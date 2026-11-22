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
//$sql="select  tabid,name,tablabel from ld_tab where name in('accounts','contacts','quotes','salesorder','invoice','products','paymentplan','potentials','helpdesk','expense','contactrecords','vendors','purchaseorder','Stock','OutboundOrder','Checks') and presence in(0,2)";
$sql="select  tabid,name,tablabel from ld_tab where tabid=? and presence in(0,2)";
$result=$adb->pquery($sql,array($_REQUEST['tabid']));
$printtabs=array();
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $printtabs[$adb->query_result($result,$i,'tabid')]=getTranstab($adb->query_result($result,$i,'tablabel'));
}
$smarty->assign("PRINTTABS",$printtabs);
echo "####:###";
$smarty->display("modules/MassSMS/SendInformContent_remind.tpl");

exit();

?>