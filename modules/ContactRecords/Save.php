<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
require_once('modules/ContactRecords/ContactRecords.php');

require_once('modules/Reminds/Reminds.php');

//added to fix 4600
$search=vtlib_purify($_REQUEST['search_url']);

$focus =CRMEntity::getInstance('ContactRecords');

global $current_user;
$record=$_REQUEST['record'];
if($record>0)
{
    $before_columnfieldvalue=$focus->retrieve_entity_info($record,'ContactRecords');
}


if(!empty($record))
{
    $focus->id = $_REQUEST['record'];
    /**
     * edit:kevin
     * date:2013-07-23
     * reason:编辑单据时,更新客户
     */
   /* $account=new Accounts();
    $account->updateAccountInfo($currentModule,'',1,$focus->id);*/
    
}

if(isset($_REQUEST['mode']))
{
	$focus->mode = $_REQUEST['mode'];
}
setObjectValuesFromRequest($focus);

//print_r($focus->column_fields);
//负责人
if($_REQUEST['assigntype'] == 'U')  {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}



$LINGDANG_BULK_SAVE_MODE = false;
$focus->save("ContactRecords");

$beforenextcontactdate=$focus->before_save_infos[0]['nextcontactdate'];

$return_id = $focus->id;
/*
$focus_rel = new Reminds(); 

$focus_rel->saveRemindsInfo($module,$return_id);
$focus_rel = new Activity(); 
$focus_rel->id=$return_id;
$focus_rel->insertIntoReminderTable('ld_activity_reminder','Calendar',"");
*/


//code added for returning back to the current view after edit from list view
if($_REQUEST['return_viewname'] == '') $return_viewname='0';
if($_REQUEST['return_viewname'] != '')$return_viewname=vtlib_purify($_REQUEST['return_viewname']);

/**
* edit:chj
* date:2014-4-8
* reason:0008139: 项目任务明细界面，更多信息，联系人记录列表，点击创建按钮，创建后的单据，没有在该列表显示；
**/

if(isset($_REQUEST['projecttaskid']) && $_REQUEST['projecttaskid'] != '' && $_REQUEST['Create'] == 'yes')
{
    $projecttaskid = $_REQUEST['projecttaskid'];
    $adb->pquery("update ld_contactrecords set projecttaskid = $projecttaskid where contactrecordid = $return_id");
}
/**
* edit:chj
* date:2014-4-10
* reason:0008206: 项目明细界面，更多信息，联系人记录列表，点击创建按钮创建的单据，在列表内无显示
**/
if(isset($_REQUEST['projectid']) && $_REQUEST['projectid'] != '' && $_REQUEST['Create'] == 'yes')
{
    $projectid = $_REQUEST['projectid'];
    $adb->pquery("update ld_contactrecords set projectid = $projectid where contactrecordid = $return_id");
}


$sql = "select accountname from ld_account where accountid=?";
$accountname = $adb->query_result($adb->pquery($sql, array($_REQUEST['account_id'])),0,'accountname');
$datetime=$_REQUEST['nextcontactdate'];
$recieverid=$_REQUEST['assigned_user_id'];
if(empty($recieverid)){
    $recieverid=$current_user->id;//Liver 20170302 bug0027412: 跟进记录：若该用户的数据权限中，销售负责人为只读字段，则该用户收不到下次回访日期提醒。
}
/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-25
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
//duan 2022-6-8 将pc端和移动端的代码整合到一起，并支持小编辑调用
//if($_REQUEST['contactdate'] < $_REQUEST['nextcontactdate']&&
//        ($focus->before_save_infos[0]['account_id']!=$_REQUEST['account_id']||$beforenextcontactdate!=$_REQUEST['nextcontactdate']))
//{
//    
//    $sql="delete from ld_reminds where related_to=? and reltab=?  and content like '%".getFixedLabel('RETURNVISIT')."%' 
//                and (reminds_ruleid is null or reminds_ruleid=0)";
//    $adb->pquery($sql,array($focus->id,'ContactRecords'));
//    
//        $RemindsContent=getFixedLabel('RETURNVISIT').gettranslabelfields('Accounts','accountname').'：'.$accountname;
//        $record=$_REQUEST['currentid'];
//		if(empty($record)){
//			$record = $return_id;
//		}
//        //新建创建提醒
//        AddReminds($RemindsContent,$datetime,$recieverid,$record,$_REQUEST['contactdate'],$_REQUEST['nextcontactdate']);
//  } 
  
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{   
    
    if($_REQUEST['refreshpage']=='no')
    {
        /* $arr['fieldhrefname']=$focus->list_link_field;
         $arr['fieldvalue']=$focus->column_fields;
        $arr['fieldvalue']['maintable_id']=$focus->id;
         $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
        $_SESSION[$currentModule.'_modulebillnotip']='no';
        ConvertTojsonString(1,$arr,"success");*/
        $focus->ReturnAfterSave($before_columnfieldvalue);
        
        
    }
   else  if($_REQUEST['gengjin']){
		@ob_clean();
		@ob_flush();
		$jarr['code']='1';
		echo $str=json_encode($jarr);//将数组进行json编码
		exit();
    }else{
        header("Location: index.php?action=$return_action&module=$return_module&parenttab=$parenttab&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
    }


}
else
{
   
    //;
    
 
    if($_REQUEST['refreshpage']=='no')
    {
      /*  $arr['fieldhrefname']=$focus->list_link_field;
         $arr['fieldvalue']=$focus->column_fields;
        $arr['fieldvalue']['maintable_id']=$focus->id;
         $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
     $_SESSION[$currentModule.'_modulebillnotip']='no';
        ConvertTojsonString(1,$arr,"success");*/
         $focus->ReturnAfterSave($before_columnfieldvalue);
        
    }
   else if($_REQUEST['gengjin']){
    
    }else{
        header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
    }
}

     if($_REQUEST['refreshpage']=='no')
    {
        
        /*$arr['fieldhrefname']=$focus->list_link_field;
         $arr['fieldvalue']=$focus->column_fields;
        $arr['fieldvalue']['maintable_id']=$focus->id;
         $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
         $_SESSION[$currentModule.'_modulebillnotip']='no';
        ConvertTojsonString(1,$arr,"success");*/
        //$this->ReturnAfterSave($before_columnfieldvalue);
         $focus->ReturnAfterSave($before_columnfieldvalue);
        
    }
   else if($_REQUEST['gengjin']){
      
    }else{
        header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
    }
/**
 * 更新操作
 * 创建连系记录新增提醒，提醒销售负责人
 * edit by andy
 * date: 20140218
**/
//echo "<pre>";
//print_r($_REQUEST);
//function AddReminds($RemindsContent,$datetime,$recieverid,$record,$date1,$date2)
//{
//    global $adb,$current_user;
//      //  if($date1<$date2){
//            //下次回访日期更新，首先删除该联系记录关联的未读的提醒
//            //$sql="delete from ld_reminds where related_to='{$record}' and status_rmd='未读' and ifnull(remindstype,'') != 'Approve'";
//           
//           // $result = $adb->query($sql);  
//       // }
//        $smownersql = "select * from ld_crmentity where crmid = ".$record;
//        $smownerresult = $adb->query($smownersql);
//        $setype = $adb->query_result($smownerresult,0,'setype');
//        $focus_rel =CRMEntity::getInstance('Reminds');                    
//    	$focus_rel->column_fields['date_time'] = $datetime;	   
//        $focus_rel->column_fields['related_to']=$record;
//        $focus_rel->column_fields['reltab']=$setype;
//        //zxm  2021-0702 跟进记录提醒 设置个remindstype
//        $focus_rel->column_fields['remindstype']='ContactRecordsDate';
//        $focus_rel->column_fields['recieverid']=$recieverid;
//      //  $focus_rel->column_fields['wxremindstype']='immediately';
//        $focus_rel->column_fields['status_rmd']='未读';
//        $focus_rel->column_fields['content']=$RemindsContent;
//        $focus_rel->mode="create";
//        $focus_rel->save('Reminds');
//        /*
//        $r_multi_content = array(
//                array(
//                    'userid'=>$recieverid,//注意,这是微信用户id，即用户表中的wx_userid
//                    'message'=>$remindcontent,
//                    'reltab'=>$setype,
//                    'related_to'=>$record,
//                    'date_time'=>$datetime,
//                    'remindtype'=>'',
//                    )
//            );
//            $remind = new immediatelyReminds();
//            $errorno = $remind->sendReminds($ids,$r_multi_content);
//            */
//}
exit();

?>