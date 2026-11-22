<?php
include(globalStatic::$root_directory."include/RecordEncrypt.php");
$smarty=new lingdangCRM_Smarty();

global $adb;
$Obj=new RecordEncrypt("Accounts",$_REQUEST['accountid']);
$accountid=  $Obj->decrypt();
if(empty($accountid))
{
    exit();
}

$fieldobj=Field::getInstance("Accounts",$adb);
$accountnamelabel=$fieldobj->getFieldInfoBykeyValue('columnname','accountname','fieldlabel');
$smarty->assign("ACCOUNTNAMELABEL",$accountnamelabel);
crm_load_function_file('getPicklistValesForNORole','modules/PickList','PickListUtils');
$sql='select campaignaccountrelstatus from  ld_campaignaccountrel  where campaignid=? and accountid=? ';
$result=$adb->pquery($sql,array($_REQUEST['campaignid'],$accountid));

//@edit:liushuai,2020-09-17,reason:0042687/市场活动>单据详情界面>相关点击“客户”：列表操作列点击“状态”按钮没有反应
$statuscombox=getEditViewPagePickList('campaignaccountrelstatus',$adb->query_result($result,0,0),array(),'');

$smarty->assign('STATUSCOMBOXVALUE',$statuscombox);


$sql='select accountname from ld_account  where accountid=? ';
$result=$adb->pquery($sql,array($accountid));
$accountname=$adb->query_result($result,0,0);

$smarty->assign("ACCOUNTNAME",$accountname);
$smarty->assign('RELATIONID',$_REQUEST['relatedid']);
$smarty->assign('ACCOUNTID',$_REQUEST['accountid']);
$smarty->assign('CAMPAIGNSID',$_REQUEST['campaignid']);
$smarty->assign("FIELDNAME",'campaignaccountrelstatus');

//CrmPopup.getPopupObj('last').picklist_arrow_click(event,'industry')
$strcontent=$smarty->fetch('modules/Campaigns/AccountStatus.tpl');
$_REQUEST['diony']='diony';
$arr['content']=$strcontent;
$arr['title']=getFixedLabel("STATUS");
$arr['oktext']=getFixedLabel("CONFIRME");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['fieldname']='campaignaccountrelstatus';
$arr['statuscombox']=$statuscombox;
ConvertTojsonString(1,$arr,'success');

?>