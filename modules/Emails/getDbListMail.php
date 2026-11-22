<?php
include(globalStatic::$root_directory."include/mail/MailAccount.php");
include(globalStatic::$root_directory."include/mail/MailDb.php");
include(globalStatic::$root_directory."include/mail/MailInfo.php");
include(globalStatic::$root_directory."modules/Emails/Email_ScopOfAuthority.php");
$smarty=new lingdangCRM_Smarty();
/**
 * 从数据库获取邮件
 * */
 $account_id=$_REQUEST['account_id'];
 $mailaccount=new MailAccount();
$mailaccounts=$mailaccount->getMailAccountInfo();
 $findaccount='no';
foreach($mailaccounts as $tmpaccdata)
{
    if($tmpaccdata['account_id']==$account_id)
    {
        $accdata=$tmpaccdata;
        $findaccount='yes';
        break;
    }
}
if($findaccount!='yes')
{
    //没有找到则，清空
    $accdata=array();
    $accdata['popuser']="";
    
}
$listtype=$_REQUEST['listtype'];
$MailDbobj=new MailDb($accdata['popuser']);
$pagestart=isset($_REQUEST['pagestart'])? $_REQUEST['pagestart']:1;
if($listtype=='starmail')
{
    $starmail='yes';
}
else
{
    $starmail='';
    
}
if($_REQUEST['smowner_search_senior']&&$_REQUEST['senioruserid'])
{
    //高级查询
    $_SESSION['email_seach_senior_userid']=$_REQUEST['senioruserid'];
    $_SESSION['email_searchscope']='';
    $smarty->assign("SelectedOwner2",'smowner_search_senior');
}
else if($_REQUEST['SearchScope']!='')
{
    $_SESSION['email_searchscope']=$_REQUEST['SearchScope'];
     $smarty->assign("SelectedOwner2",$_SESSION['email_searchscope']);
     $_SESSION['email_seach_senior_userid']='';
     
}
else if($_SESSION['email_seach_senior_userid']!='')
{
    //高级查询
    $_SESSION['email_searchscope']='';
    $_REQUEST['senioruserid']=$_SESSION['email_seach_senior_userid'];
    $smarty->assign("SelectedOwner2",'smowner_search_senior');
}
else if($_SESSION['email_searchscope'])
{
    $smarty->assign("SelectedOwner2",$_SESSION['email_searchscope']);
}
else
{
    $_SESSION['email_searchscope']='SmOwner_Search_All';
    $_SESSION['email_seach_senior_userid']='';
    $_REQUEST['SearchScope']='SmOwner_Search_All';
    $smarty->assign("SelectedOwner2",'SmOwner_Search_All');
    
}

if(isset($_REQUEST['orderby']))
{
  
    $_SESSION['email_orderby']=$_REQUEST['orderby'];
    $_SESSION['email_orderby']=$_REQUEST['ordertype'];
}
else
{
    $_REQUEST['orderby']=$_SESSION['email_orderby'];
    $_REQUEST['ordertype']=$_SESSION['email_orderby'];
}
$maillist=$MailDbobj->getlist($pagestart,$_REQUEST['email_deleted'],$starmail);

$totalRows=$MailDbobj->getAllTotalRows($_REQUEST['email_deleted'],$starmail);
$unreadcount=$MailDbobj->getUnReadCount($starmail);

$MergeSmowner=getCurSmOwnerSearchScope($currentModule);


if(is_array($MergeSmowner))
{
    unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
    unset($MergeSmowner["OtherInfo"]['SmOwner_Search_Create']);//我创建的
    unset($MergeSmowner["OtherInfo"]['SmOwer_Search_ShareMe']);//共享给我的
    unset($MergeSmowner["OtherInfo"]['SmOwer_Search_MeToShare']);//我共享给他人的
    unset($MergeSmowner["OtherInfo"]['SmOwner_Search_Me']);//我负责的
}

$smarty->assign('Merge_SmOwner',$MergeSmowner);
//20240305 hzx XUQIU20240112-01 查询分类显示优化（仿腾讯云），一行显示4个，点击出现弹出层注：注意区分普通、悬浮、选中状态
if(count($MergeSmowner) > 0 && $currentModule != 'InventoryAccount' && $currentModule != 'InventoryQuery' && $currentModule != 'BankAccountSet' && $currentModule != 'Reminds'){
    $SmOwner_option_arr = [];
    $showviewrange = false;
    foreach($MergeSmowner as $User_Key => $User_value){
        foreach($User_value as $User_id => $User_name){
            foreach($User_name as $User_name_key => $User_name_value){
                $SmOwner_option_arr[] = array('label'=>$User_name_key,'value'=>$User_id);
                if($User_id == 'smowner_search_senior'){
                    $showviewrange = true;
                }
            }
        }
    }
    if($showviewrange == true){
        $smarty->assign('showviewrange',$showviewrange);
    }
}else{
    $SmOwner_option_arr = [];
    $SmOwner_option_arr[] = array('label'=>getFixedLabel('ALL'),'value'=>'SmOwner_Search_All','selected'=>true);
}
$smarty->assign('Merge_SmOwner_arr',json_encode($SmOwner_option_arr));
$smarty->assign("SEARCHTEXT",$_REQUEST['searchtext']);
$smarty->assign("SEARCHFIELD",$_REQUEST['searchfield']);

$smarty->assign("MAILLIST",$maillist);
$smarty->assign("AJAX",'yes');
$smarty->assign("TOTALROWS",$totalRows);
$smarty->assign("UNREADCOUNT",$unreadcount);
global $list_max_entries_per_page_new;
$pages=floor($totalRows/$list_max_entries_per_page_new);
if($pages*$list_max_entries_per_page_new<$totalRows)
{
    $pages=$pages+1;
}

$smarty->assign("TOTALPAGES",$pages);
$smarty->assign("PAGESTART",$pagestart);
$smarty->assign("LISTYPE",$_REQUEST['listtype']);
$smarty->assign("ORDERBY",$_REQUEST['orderby']);
$smarty->assign("ORDERTYPE",$_REQUEST['ordertype']);

$arr['content']=$smarty->fetch("EmailContents.tpl");
$arr['totalrows']=$totalRows;
$arr['unreadcount']=$unreadcount;
$_REQUEST['diony']='yes';
ConvertTojsonString(1,$arr,'success');


?>