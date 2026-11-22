<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $adb;
$_REQUEST['diony']='diony';
if ($_REQUEST['mode'] == "eventChange") {
    if (!empty($_REQUEST['record']) && !empty($_REQUEST['start_date']) && !empty($_REQUEST['end_date'])) {
        $sql = "update ld_activity set date_start = ?,due_date = ? where activityid = ?";
        $result = $adb->pquery($sql, array($_REQUEST['start_date'],$_REQUEST['end_date'],$_REQUEST['record']));
    }

    ConvertTojsonString(1,$result,"success");
}
require_once('include/utils/RecurringType.php');
require_once 'modules/lingdang/EditView.php';



if($module=='Calendar'){
    $ACTIVITYDATA=array();    
    $sql="select email_remind from ld_activity_reminder where  activity_id='".$record."'";
    $ACTIVITYDATA[]=$focus->getDatetimeHtml('email_remind',$sql);
    if(empty($record))
    {
        $ACTIVITYDATA[0][1]=0;
    }
    $sql="select date_time from ld_reminds where is_del_send=0 and related_to>0 and related_to='".$record."' and remindstype='CalendarCreateRemind'";
   
    $ACTIVITYDATA[]=$focus->getDatetimeHtml('date_time',$sql);
    if(empty($record))
    {
        $ACTIVITYDATA[1][1]=0;//29271: 日程管理：提醒，发送邮件通知和弹出消息通知，默认修改为否
    }
    $sql="select content from ld_reminds where is_del_send=0 and related_to>0 and related_to='".$record."'";
    $ACTIVITYDATA[]=$focus->getContent($sql);
 
    $smarty->assign('ACTIVITYDATA',$ACTIVITYDATA);
}

$loop_type_selected = $loop_month_selected = $loop_dayvalue_selected = $expiredate = '';
$reminder_setting_selected = [0];//提醒设置默认值
if(isset($_REQUEST['record']) && $_REQUEST['record']!='') {
    
    $focus->id = vtlib_purify($_REQUEST['record']);
    $focus->mode = 'edit';
  
    $focus->retrieve_entity_info($_REQUEST['record'],$tab_type);//列赋值   
	
	//require_once('./modules/Approve/Approve.php');
	//$approve=new Approve();
//	$approve = Approve::getInstance($currentModule);
	/**
	 * 判断已审批状态不允许编辑
	 * @reason 0012457 日程管理序时簿：在序时簿列表中，点击列表操作后面的【编辑】按钮，若该日程已经审批，希望给出提示“该记录已被审批通过，不允许编辑！”
	 * @author Tujt 2014-11-12
	 */
	if(!isset($_REQUEST['isDuplicate']) || $_REQUEST['isDuplicate'] != 'true'){
		$isPermitted = isPermitted($module,'EditView',$focus->id);
		if($isPermitted == 'no'){
			$alertstr = getFixedLabel('THERECORDAPPROVED');
			echo '<script type="text/javascript">alert("'.$alertstr.'");history.go(-1);</script>';exit();
		}
	}

    $focus->name=$focus->column_fields['subject'];
    $sql = 'select ld_users.*,ld_invitees.* from ld_invitees left join ld_users on ld_invitees.inviteeid=ld_users.id where activityid=?';
    $result = $adb->pquery($sql, array($focus->id));   
    
    $num_rows=$adb->num_rows($result);    
    $invited_users=Array();
    $entity_field_info = getEntityFieldNames('Users');
    $fieldsName = $entity_field_info['fieldname'];
    $invited_userids = [];
    for($i=0;$i<$num_rows;$i++)
    {
	    $userid=$adb->query_result($result,$i,'inviteeid');
	    $username = $adb->query_result($result,$i,$fieldsName);;
	    $invited_users[$userid]=$username;
		$invited_userids[] = $userid;
    }
	if(sizeOf($invited_userids) >= 1){
		$userids = implode(';',$invited_userids);
	}
	//0020739: 首页>日程管理>编辑
	/*$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
	foreach($MergeSmowner["UserCombo"] as $userid => $user_array){
		foreach($user_array as $username => $sel){
			$userDetails[$userid] = $username;
		}
	}*/
    //zkt 20230808 BUG0070750  	http://222.208.64.231:8948/crm ；成都博达；登录账号：13183586778 密码：123 >日程管理>新建保存>找到新建的单据点击编辑>进入编辑页面，点击邀请，可选成员看不到所有人，只能看到自己（通用bug，kfbcrm kfbtest也有此情况） 
    $alluserDetails = getOtherUserName($current_user->id);
    $userDetails = [];
    foreach($alluserDetails as $userid => $username){
        $userDetails[$userid] = $username;
	}
    /**
     *@edit:andy 
     *@date:
     *@reason:日程选择用户左右改进
     *@version:
     */
    //日程管理
    //$userDetails[$current_user->id]=$current_user->last_name;
    $userDetails=array_diff($userDetails,$invited_users);//
    $smarty->assign("USERSLIST",$userDetails);
	$smarty->assign('USERLISTIDS',$userids);
    $smarty->assign("INVITEDUSERS",$invited_users);
    
    //$smarty->assign("UPDATEINFO",updateInfo($focus->id));
    $query = 'SELECT ld_recurringevents.*, ld_activity.date_start,ld_activity.due_date
				FROM ld_recurringevents
					INNER JOIN ld_activity ON ld_activity.activityid = ld_recurringevents.activityid
					WHERE ld_recurringevents.activityid = ?';
            
	$res = $adb->pquery($query, array($focus->id));
    $rows = $adb->num_rows($res);
	$value = array();
    if($rows > 0) {
		$recurringObject = RecurringType::fromDBRequest($adb->query_result_rowdata($res, 0));
	    $value['recurringcheck'] = (isset($_REQUEST['isDuplicate']))?'No':'Yes';
	    $value['repeat_frequency'] = $recurringObject->getRecurringFrequency();
		$value['eventrecurringtype'] = $recurringObject->getRecurringType();
		$recurringInfo = $recurringObject->getUserRecurringInfo();

		if($recurringObject->getRecurringType() == 'Weekly') {
			$noOfDays = count($recurringInfo['dayofweek_to_repeat']);
			for ($i = 0; $i < $noOfDays; ++$i) {
				$value['week'.$recurringInfo['dayofweek_to_repeat'][$i]] = 'checked';
			}

		   } elseif ($recurringObject->getRecurringType() == 'Monthly') {
			$value['repeatMonth'] = $recurringInfo['repeatmonth_type'];
			if ($recurringInfo['repeatmonth_type'] == 'date') {
				$value['repeatMonth_date'] = $recurringInfo['repeatmonth_date'];
			} else {
				$value['repeatMonth_daytype'] = $recurringInfo['repeatmonth_daytype'];
				$value['repeatMonth_day'] = $recurringInfo['dayofweek_to_repeat'][0];
			}
		}
    } else {
	    $value['recurringcheck'] = 'No';
    }
     
    $smarty->assign('RECURRINGVALUE',$value);

    /*循环日程*/
    $query = 'SELECT * FROM ld_loopcalendar_reminds
					/*INNER JOIN ld_activity ON ld_activity.activityid = ld_loopcalendar_reminds.activityid*/
					WHERE ld_loopcalendar_reminds.activityid = ?';

    $result = $adb->pquery($query, array($focus->id));
    $rows = $adb->num_rows($result);
    if($rows > 0) {
        $loop_type_selected = $adb->query_result($result,0,'loop_type');
        $loop_month_selected = $adb->query_result($result,0,'loop_month');
        $loop_month_selected = explode(' |##| ', $loop_month_selected);

        $loop_dayvalue_selected = $adb->query_result($result,0,'loop_dayvalue');
        $loop_dayvalue_selected = explode(' |##| ', $loop_dayvalue_selected);

        $reminder_setting_selected = $adb->query_result($result,0,'reminder_setting');
        $reminder_setting_selected = explode(' |##| ', $reminder_setting_selected);

        $expiredate = $adb->query_result($result,0,'expiredate');
    }
}

else
{
    /**
     *@edit:andy 
     *@date:
     *@reason:日程选择用户左右改进
     *@version:
     */
    //日程管理
    $userDetails = getOtherUserName($current_user->id);
    $smarty->assign("USERSLIST",$userDetails);
}
/*
 * 循环设置区块数据
 * */
//循环类型
$PickListData['loop_type_info']['options'] = $focus->loop_setting_arr['loop_type_options'];
$PickListData['loop_type_info']['selected'] = $loop_type_selected;

//月份多选框
$loop_month_options = $focus->loop_setting_arr['loop_month_options'];
foreach ($loop_month_options as $optionvalue=>$optiontext) {
    if (is_array($loop_month_selected) && in_array($optionvalue,$loop_month_selected)) {
        $PickListData['loop_month_info'][] = [$optiontext,$optionvalue,'selected',''];
    }else{
        $PickListData['loop_month_info'][] = [$optiontext,$optionvalue,'',''];
    }
}

//每周后面的周几多选框
$loop_dayvalue_options = $focus->loop_setting_arr['loop_dayvalue_options'];
foreach ($loop_dayvalue_options as $optionvalue=>$optiontext) {
    if (is_array($loop_dayvalue_selected) && in_array($optionvalue,$loop_dayvalue_selected)) {
        $PickListData['loop_dayvalue_info'][] = [$optiontext,$optionvalue,'selected',''];
    }else{
        $PickListData['loop_dayvalue_info'][] = [$optiontext,$optionvalue,'',''];
    }
}

//每月后面的几号多选框
$loop_dayvalue_month_options = $focus->loop_setting_arr['loop_dayvalue_month_options'];
foreach ($loop_dayvalue_month_options as $optionvalue=>$optiontext) {
    if (is_array($loop_dayvalue_selected) && in_array($optionvalue,$loop_dayvalue_selected)) {
        $PickListData['loop_dayvalue_monthinfo'][] = [$optiontext,$optionvalue,'selected',''];
    }else{
        $PickListData['loop_dayvalue_monthinfo'][] = [$optiontext,$optionvalue,'',''];
    }
}

//提醒设置多选框
$reminder_setting_options = $focus->loop_setting_arr['reminder_setting_options'];
foreach ($reminder_setting_options as $optionvalue=>$optiontext) {
    if (is_array($reminder_setting_selected) && in_array($optionvalue,$reminder_setting_selected)) {
        $PickListData['reminder_setting_info'][] = [$optiontext,$optionvalue,'selected',''];
    }else{
        $PickListData['reminder_setting_info'][] = [$optiontext,$optionvalue,'',''];
    }
}

//到期日期
$PickListData['expiredate_info'] = $expiredate;
$smarty->assign('PickListData',$PickListData);//tpl赋值
$PickListData_json = ldcrm_json_encode($PickListData);
$smarty->assign('PickListDataObj',$PickListData_json);
$smarty->assign('PageMode',$focus->mode);


if(isset($_REQUEST['parent_id'])&&$_REQUEST['parent_id']!='')
$smarty->assign('PRODUCTID',vtlib_purify($_REQUEST['parent_id']));

setGLobalURLSmarty($smarty);//设置js,css等访问路径
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
   
    $smarty->assign('CREATE','true');
}
else
{
    
     $smarty->assign('CREATE','false');
}
 
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

$approveobj=Approve::getInstance($currentModule);
$approve_arr=[];
global $weixin_user;
if (!is_object($weixin_user)) {
    crm_load_class_file('weixin_user', 'WeiXinApp/modules/Users');
    $weixin_user = new weixin_user();
}

if($focus->id>0)
{
    if(!array_key_exists('approvestatus',$focus->column_fields)&&empty($focus->column_fields['approvestatus']))
    {
        //审批状态字段隐藏
        $sql= "select approvestatus from "  .$focus->table_name." where "  .$focus->table_index."=?";
        $result=$adb->pquery($sql,array($focus->id));
        $focus->column_fields['approvestatus']=$adb->query_result($result,0,0);

    }
    $status=$approveobj->getApproveStatus($focus->column_fields['approvestatus']);
    if($status==0||$status==3 ||$status==4 || ($status == 2 && $approveobj->recordAgainSubmit($currentModule)))
    {
        $weixin_user->action='default_on_submit';
        $weixin_user->environment='pc';
        $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);
    }
}
else{
    $weixin_user->action='default_on_new';
    $weixin_user->environment='pc';
    $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);

}
$smarty->assign("APPROVE_ARR",$approve_arr);

if(empty($qcreate_array['form']) || (is_array($qcreate_array['form']) && sizeof($qcreate_array['form'])<=0))
{
    $quickcreatestr="##noquickdata##";
}
else
    $quickcreatestr=$smarty->fetch("DetailView/PopupEditQuickCreate.tpl");
$data = $focus->fieldobj->split_validationdataArray();
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($focus->module_name);
$fieldruleobj->fieldPropertys = '';
$fieldruleobj->setColumnValues($focus->column_fields);

$fields=$focus->fieldobj->getFieldListArray();
$str=$smarty->fetch("DetailView/PopupEditRelated.tpl");

$_REQUEST['diony']='diony';
if (isset($_REQUEST['is_linkmodulecustom']) && $_REQUEST['is_linkmodulecustom'] == '1') {
    require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
    $arr['title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($currentModule);
} else {
    $arr['title'] = getTranstab($currentModule);
}
$arr['approve_arr']=$approve_arr;
$arr['savesubmittext']=getFixedLabel('SaveSubmitApprove');
//zxm 2021-0701 新建编辑页面增加页面设置按钮 判断是否有页面设置按钮
$settingsBtn = $focus->getModuleLogic($currentModule)->getSettingsBtn();
$is_page_setting = "no";
if(isset($settingsBtn['Settings'])&&$settingsBtn['Settings']['permit']=='yes'){
    $is_page_setting = "yes";
}
$arr['is_page_setting'] = $is_page_setting;
$arr['calendar_picklistdata_json'] = $PickListData_json;

$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['mainfieldformula']=$focus->fieldobj->getFormula();
$arr['content']=$quickcreatestr;
$arr['allcontent']=$str;
$arr['fieldname']=$data['fieldname'];
$arr['datatype']=$data['datatype'];
$arr['fieldlabel']=$data['fieldlabel'];
$arr['fields']=$fields['fields'];
$arr['filejsondata']=$fieldjsondata;
$arr['isadmin']=$current_user->is_admin;
$arr['columnfields_value']=$focus->column_fields;
$arr['picklistcontent']=$global_pick_list_values;
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
$arr['isduplicate'] = getTabDuplicate('Calendar');
///保存判断
$arr["validatasave"]=getValidataSave($currentModule);
$arr["validatasaverule"]=getAllRule($currentModule);
//布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发字段
//敏感规则 zkt 20231116 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
crm_load_class_file('cls_fieldSensitiverule','include/fields');
$fieldSensitiveruleobj=cls_fieldSensitiverule::getInstance($currentModule);
$arr['sensitiverelatedfield']=$fieldSensitiveruleobj->getAllRealtedfieldbyfieldname();//获取所有的触发字段
//duan 20240923 在编辑页面结尾对返回值增加统一操作
crm_load_class_file('CommonEditViewReturn','modules/lingdang');
$CommonEditViewReturnObj = new CommonEditViewReturn();
$arr = $CommonEditViewReturnObj->setReturnArr($arr);

ConvertTojsonString(1,$arr,"success");
?>