<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/*确认出库时是否发送短信通知客户*/

global $adb;
global $current_user;
$smarty = new lingdangCRM_Smarty;
if($_REQUEST['frommodule'] == 'SalesOrder'){
	$contenttype = 7;
}
else if($_REQUEST['frommodule']=='HelpDesk')
{
    if($_REQUEST['smstype']=='ser')
        $contenttype = 12;
	else if($_REQUEST['smstype'] == 'allocate')	//分配发送短信
		$contenttype = 13;
    else
        $contenttype=11;
}
else if($_REQUEST['frommodule'] == 'SalesBack')
{
    $contenttype = 8;
}
else{
	$contenttype = 1;
}
$sqlContent="select * from ld_sendinformcontent where type = ".$contenttype;
$sqlContentResult=$adb->query($sqlContent,array());
$Content = $adb->query_result($sqlContentResult,0,'content');

/**
 * 更新操作
 * edit:lmx
 * time:20140303
 * reson:0007275: 建议：“出库单”设置短信短语格式，希望变量信息中，默认为当前模块
 */
 //21018: 控制面板>审批流程管理：审批步骤新增界面-审批通知页签，设置提醒内容弹出层--变量信息不是显示当前的模块
//$sql="select  tabid,name,tablabel from ld_tab where name in('accounts','contacts','quotes','salesorder','invoice','products','paymentplan','potentials','helpdesk','expense','contactrecords','vendors','purchaseorder','Stock','OutboundOrder','Checks') and presence in(0,2)";
$sql="select  tabid,name,tablabel from ld_tab where  presence in(0,2)";
$result=$adb->pquery($sql,array());
$printtabs=array();
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $printtabs[$adb->query_result($result,$i,'tabid')]=getTranstab($adb->query_result($result,$i,'name'));
}

/*
 * editor:gyq_05
 * reason:设置提醒信息格式弹框，新增适配审批步骤;   更新通配符提示，适用中英文
 * date  :2016 2 24
 * */

if($_REQUEST['approveStepType']){
    $remindtitle = getFixedLabel('REMINDSCONTENT');
    $wildcard = getFixedLabel('WILDCARD').':　'.getFixedLabel('APPROVALSTEP').'{step}　　　　'.getFixedLabel('APPROVER')
        .'{approver}　　　　'.getFixedLabel('APPROVALNOTE').'{description}';
}else{
    $remindtitle = getFixedLabel('SMS_content');
    $wildcard = getFixedLabel('WILDCARD').':　'.getFixedLabel('CONTACTNAME').'{name}　　　　'.getFixedLabel('CONTACTAPPELLATION') .'{app}';
}
$smarty->assign('REMINDTITLE',$remindtitle);
$smarty->assign('WILDCARD',$wildcard);

$smarty->assign('FROMMODULE',$_REQUEST['frommodule']);

$smarty->assign('TABID',getTabid($_REQUEST['frommodule']));
$smarty->assign("CONTENT",$Content);
$smarty->assign("PRINTTABS",$printtabs);
$smarty->assign("OUT_ID",$_REQUEST['out_id']);
$smarty->assign('CONTENTTYPE',$contenttype);
//if($_REQUEST['frommodule']=='HelpDesk')
//{
    $_REQUEST['diony']='diony';
	if($_REQUEST['approveStepType'])
		$arr['title']=getFixedLabel("REMINDSCONTENT");
    else{
		if(!empty($_REQUEST['is_send'])){
			if($_REQUEST['is_send'] == 1){
				$arr['title']=getFixedLabel("SETHEMESSAGEFORMAT");
			}else{
				$arr['title']=getFixedLabel("setmailformat");
			}
		}else{
			$arr['title']=getFixedLabel("SENDTEXTMESSAGESTOINFORM");
		}
	}
	$arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $str=$smarty->fetch("modules/MassSMS/SendInformContent.tpl");
    $arr['content']=$str;
    ConvertTojsonString(1,$arr,"success");
    exit();
//}
//else
//{
    //echo "####:###";

    //$smarty->display("modules/MassSMS/SendInformContent.tpl");
//}

exit();

?>