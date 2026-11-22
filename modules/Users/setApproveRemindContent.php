<?php
//设置控制面板 审批提醒内容
global $adb;
global $current_user;
$smarty = new lingdangCRM_Smarty;
$remindmethod=$_REQUEST['remindmethod'];
$groupname=$_REQUEST['groupname'];
include(globalStatic::$root_directory.'modules/Approve/CommonApproveVar.php');
$approvereminds=$global_approvereminds;
foreach($approvereminds['groups'] as $index=> $tmpgroupname)
{
    if($typegroupname==$groupname)
    {
        $type=$index;
        break;
    }
}

if($_REQUEST['remindcontent']!="")
{
    $Content=$_REQUEST['remindcontent'];
}
else if($_REQUEST['stepid']>0)
{
    $sqlContent="select * from ld_approvereminds where stepid = ".$_REQUEST['stepid']." and type=? and remindmethod=?";
    $param[]=$type;
    $param[]=$_REQUEST['remindmethod'];
    
    if($_REQUEST['reminduser']!="")
    {
        $sqlContent.=" and reminduser=?";
        $param[]=$_REQUEST['reminduser'];
    }
   
    $sqlContentResult=$adb->pquery($sqlContent,$param);
    if($adb->num_rows($sqlContentResult)>0)
         $Content = $adb->query_result($sqlContentResult,0,'remindcontent');
}


/**
 * 更新操作
 * edit:lmx
 * time:20140303
 * reson:0007275: 建议：“出库单”设置短信短语格式，希望变量信息中，默认为当前模块
 */
 //21018: 控制面板>审批流程管理：审批步骤新增界面-审批通知页签，设置提醒内容弹出层--变量信息不是显示当前的模块
//$sql="select  tabid,name,tablabel from ld_tab where name in('accounts','contacts','quotes','salesorder','invoice','products','paymentplan','potentials','helpdesk','expense','contactrecords','vendors','purchaseorder','Stock','OutboundOrder','Checks') and presence in(0,2)";
$sql="select  tabid,name,tablabel from ld_tab where  presence in(0,2) and (`name` not like '%mobile%' or `name` = 'MobileReport')";
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
 **/


    $remindtitle = getFixedLabel('REMINDSCONTENT');
    if($remindmethod=='email')
    {
        $wildcard = getFixedLabel('WILDCARD').':　'.getFixedLabel('APPROVALSTEP').'{step}　　　'.getFixedLabel('APPROVER')
        .'{approver}　　　'.getFixedLabel('APPROVALNOTE').'{description}　　　'.getFixedLabel('MODULENAME').'{modulelabel}　　　　'.getFixedLabel('DATASSIGNEDTO').'{smownerid}　　　'.getFixedLabel("Hyperlink").' {modulehyperlink}';
    }
    else
    $wildcard = getFixedLabel('WILDCARD').':　'.getFixedLabel('APPROVALSTEP').'{step}　　　　'.getFixedLabel('APPROVER')
        .'{approver}　　　　'.getFixedLabel('APPROVALNOTE').'{description}　　　'.getFixedLabel('MODULENAME').'{modulelabel}　　　　'.getFixedLabel('DATASSIGNEDTO').'{smownerid}';

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

    $arr['title']=getFixedLabel("REMINDSCONTENT");
    
	$arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $str=$smarty->fetch("Approve/setApproveRemindContent.tpl");
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