<?php

global $current_user;
$approveid=$_REQUEST['approveid'];
$tabid=$_REQUEST['tabid'];
$stepid=$_REQUEST['stepid'];
$module=getTabname($tabid);
$focus=CRMEntity::getInstance($module);

$flowstepid=$_REQUEST['flowstepid'];
$basicinforlabel=getFixedLabel('BASICINFO');//BASICINFO
$stepnamelabel=getFixedLabel('STEPNAME');//步骤名称
$remarklabel=getFixedLabel('BEIZHU');//
$alloweditlabel=getFixedLabel('AllowApproverEdit');// 允许审批人编辑单据
$setapproverlabel=getFixedLabel('APPROVERINFO');//设置审批人
$approvertypelabel=getFixedLabel('APPROVERTYPE');//审批人类型
$approveruserlabel=getFixedLabel('SPECIFYUSER');//指定成员
$approverrolelabel=getFixedLabel('SPECIFYROLE');//指定角色
$approvercreatorlabel=getFixedLabel('DATACREATOR');//单据创建人
$approversmownerlabel=getFixedLabel('DATASSIGNEDTO');//单据负责人
$approverdeparmentpositionlabel=getFixedLabel('SPECIFYPROMOTERDEP');//单据负责人部门成员的职位级别
$approvertoppositionlabel=getFixedLabel('LBL_POSITIONLEVEL');;//单据负责人直属上级部门成员的职位级别
$approverdepartmentuserlabel=getFixedLabel('LBL_POSITIONDEPARTMENT');//指定部门成员的职位级别
$allowChangeapproverlabel=getFixedLabel('AllowChangeStepApprover');//允许更换本步骤审批人
$allowaddapproverlabel=getFixedLabel('AllowAddApprover');//允许加签
$allowchangesteplabel=getFixedLabel('AllowChangeStep');//允许指定下一步审批节点
$approveremarkrequiredlabel =getFixedLabel('ApproveStepRemark');//审批意见必填
$signrequiredlabel=getFixedLabel('SignRequired');//签名必填
$usedprevsignlabel=getFixedLabel('UsedPrevSign');//使用上次签名
$rewriteagainlabel=getFixedLabel('ReWriteSign');//每次重新签名
$whenapproveremptylabel =getFixedLabel('WHENAPPROVERISEMPTY');//审批人为空时
$autopasslabel=getFixedLabel('AUTOMATICPASS');//自动通过
$autochangeadminlabel=getFixedLabel('AUTPFORWARDTOADMIN');// 自动转交管理员
$specifyapproverlabel=getFixedLabel('SPECIFYUSER').getFixedLabel('APPROVAL');// 指定成员审批
$AllowEndApproveFlowlabel=getFixedLabel('AllowEndApproveFlow');//b.允许直接结束审判流程
$removerepeatapproverlabel=getFixedLabel('RemoveRepeatApprove');//审批人自动去重（自动通过）
$onlyusefirstlabel=getFixedLabel('UsedFirstApprover');//仅保留第一个
$continueapproverlabel=getFixedLabel('RepeatContinueApprover');//仅在连续出现时去重
$ApproverSameSubmitterlabel=getFixedLabel('ApproverSameSubmitter');//审批人和提交人相同时去重
$MultipleapproversOne=getFixedLabel('MultipleapproversOne');//多人审批方式“或签”（一个审批人通过即可通过审批步骤）
$MultipleCountersignature=getFixedLabel('MultipleCountersignature');//多人审批方式“会签”（所有审批人通过才能通过审批步骤）

$approvalrequiredlabel=getFixedLabel('approvalrequired');//审批必填
$setquiredfieldslabel=getFixedLabel('settherequiredfieldsofapprover');//设置审批人必填字段

$approveremindslabel=getFixedLabel('APPROVEREMINDS');//审批通知
$apprveremindbeforelabel=getFixedLabel('APPROVEBEFOREPROCESS');//审批处理前
$approvesuccessremindlabel=getFixedLabel('APPROVEDSUCCESS');//审批通过
$approvefailureremindlabel=getFixedLabel('APPROVEREFUSE');//审批不通过
$remindmethodlabel=getFixedLabel('REMINDMETHOD');//提醒方式
$approverreminderlabel=getFixedLabel('REMINDERPEOPLE');//提醒人
$remindcontentlabel=getFixedLabel('REMINDSCONTENT');//提醒内容
$setremindcontentlabel=getFixedLabel('SETREMINDSCONTENT');//设置提醒内容
$advfunlabel=getFixedLabel('ADVFEATURES');//高级功能
$dynamicvaluelabel=getFixedLabel("DYNAMICASSIGNMENT");//动态赋值
$passlabel=getFixedLabel('PASS');//通过
$notpasslabel=getFixedLabel('NOTPASS');//不通过
$ApproveActionlabel=getFixedLabel('ApproveAction');//审批动作
$fieldldabel=getFixedLabel('LBL_Field');//字段
$Valuelabel=getFixedLabel('Value');//值
$stepname='';
$description='';//备注
$approvetype='0';//审批人类型 0:指定成员
$approvevalue='';//审批人值
$approvevaluename='';
$specifyapproverid=1 ;//是否允许修改本步骤审批人0:是
$emptyapproverdeal='transfertomanager';//审批人为空 auto,transfertomanager transfertouser
$emptyapproverdeal_username='';
$countersigner='no';//或签 ，会签
$alloweditbill='no';//允许审批人编辑单据
$ended=1;//允许结束流程 1: 否，0:是
$step=1;//允许变更步骤 1:否，0：是
$augmentsinger='';//允许加签
$approveremarkrequire='no';//审批意见必填
$writesignrequired='no';//手写签名是否必填
$writesignlogtype='';//签名方式
$approverremovetype='no';//审批人去重方式
$module_field='';//审批必填字段
if(!empty($stepid))
{
	$sql="select * from ld_approvestep  where id=?";
	$result=$adb->pquery($sql,array($stepid));
	$i=0;
	$steptype=$adb->query_result($result,$i,'steptype');
	$stepname=$adb->query_result($result,$i,'name');
    $stepname = html_entity_decode($stepname);
	$branchstepid=$adb->query_result($result,$i,'branchflowstepid');
	$flowstepid=$adb->query_result($result,$i,'flowstepid');
	$description=$adb->query_result($result,$i,'description');
    $description = html_entity_decode($description);
	$ended=$adb->query_result($result,$i,'ended');
	$step=$adb->query_result($result,$i,'step');
	$approvetype=$adb->query_result($result,$i,'approvetype');
	$approvevalue=$adb->query_result($result,$i,'approvevalue');
	$specifyapproverid=$adb->query_result($result,$i,'specifyapproverid');
	$alloweditbill=$adb->query_result($result,$i,'alloweditbill');
	$countersigner=$adb->query_result($result,$i,'countersigner');
	$augmentsinger=$adb->query_result($result,$i,'augmentsinger');
	$module_field=$adb->query_result($result,$i,'module_field');
	$approveremarkrequire=$adb->query_result($result,$i,'approveremarkrequire');
	$emptyapproverdeal=$adb->query_result($result,$i,'emptyapproverdeal');
	$childids=$adb->query_result($result,$i,'childids');
	$writesignlogtype=$adb->query_result($result,$i,'writesignlogtype');
	$writesignrequired=$adb->query_result($result,$i,'writesignrequired');
	$approverremovetype=$adb->query_result($result,$i,'approverremovetype');
	$approvalauthority = ldcrm_json_decode(html_entity_decode($adb->query_result($result,$i,'approvalauthority')));
	if(empty($approverremovetype))
	{
		$approverremovetype='no';
	}
    if(empty($description))
	{
		$description='';
	}
	
	$approvevaluename='';
	 if($approvetype==0){
	    $id_arr=explode(',',$approvevalue);
	    
	    foreach($id_arr as $value){
	        $approvevaluename .=getUserFullName($value).",";
	    }
	    
	}elseif($approvetype==1){
	     $id_arr=explode(',',$approvevalue);
	    $profile = new Profile();
	     foreach($id_arr as $profileid)
	     {
	         $profileinfo = $profile->getProfileinfo($profileid);
	         $approvevaluename.=$profileinfo['profilename'].',';
	     }
		
	    $approvevaluename = trim($approvevaluename,',');
	}else if($approvetype == 4){
		$approvearray = explode('::', $approvevalue);
		$approvevaluename = '';
	}else{
	    $approvevaluename=$approvevalue;
	}
	$approvevaluename=trim($approvevaluename,',');
	$emptyapproverdeal_username='';
	 if(empty($emptyapproverdeal)){//选项为空
	   
	}else if($emptyapproverdeal == 'autopass'||$emptyapproverdeal == 'transfertomanager'){//自动通过，自动转交管理员
	    
	}else{//指定审批人
	    $transfer_userids = $emptyapproverdeal;
	    $transfer_userid_arr = explode(',',trim($emptyapproverdeal,','));
	    
	    $transfer_userinfo = get_select_options_array(get_user_array(FALSE, "Active", $current_user->id), $transfer_userid_arr);
	    $transfer_userids = implode(',',$transfer_userid_arr);
	    $emptyapproverdeal_username = implode(',',array_map("getUserFullName",$transfer_userid_arr));
	    
	}

	$emptyapproverdeal_username=trim($emptyapproverdeal_username,'');

}
else{


}
if(empty($approvalauthority))
{
	$approvalauthority = array('showcancelbill'=>'yes');
}
$modulefields=$focus->fieldobj->getModuleFields();
$approverfield_arr=[];
foreach($modulefields as $fieldname=>$fieldinfo)
{
    if(empty($fieldinfo)){
        continue;
    }
    $uitype = $fieldinfo->getUIType();
	if(($uitype==153 ||$uitype==154) && $fieldinfo->getSaveDataBase() == 'yes')
	{
		$approverfield_arr[]=['fieldid'=>$fieldinfo->getFieldId(),'label'=>$fieldinfo->getFieldLabel(),'uitype'=>$uitype];

	}
	 //duan 20230714 审批步骤的必填字段设置，需要用到字段标签
    $fieldlabel=$fieldinfo->getFieldLabel();
    $all_fieldlabel_arr[$fieldname] = $fieldlabel;
}
$arr['all_fieldlabel_arr'] = $all_fieldlabel_arr;

require_once(globalStatic::$root_directory.'modules/Users/Group.class.php');

$group_focus = new Group();
$groupInfo = $group_focus->getGrouplist();


$group_arr=array();
foreach($groupInfo as $tmpgroupinfo)
{
    $tmpgroupid=$tmpgroupinfo['groupid'];
    $depth=$tmpgroupinfo['depth'];
    $tmpgroupname=$tmpgroupinfo['groupname'];
    if($depth>0)
    {
        for($i=0;$i<$depth;$i++)
        {
            $tmpgroupname="&nbsp;".$tmpgroupname;
        }
    }
    
    $group_arr[$tmpgroupname]=$tmpgroupid;
}
$arr['group']=$group_arr;

$sql="select listvalue  from ld_picklist_set  

inner join ld_picklist_values on ld_picklist_set.listid=ld_picklist_values.listid
where listname='userlevel' ORDER BY ld_picklist_set.listid asc; ";

$result=$adb->pquery($sql,array());//获取职位级别
$arr['userlevellabel']=getFixedLabel('POSITIONLEVEL');

$arr['userlevel']=[];

for($i=0;$i<$adb->num_rows($result);$i++)
{
	$arr['userlevel'][]=$adb->query_result($result,$i,'listvalue');
}
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['approverfield']=$approverfield_arr;


//审批提醒
global $global_approvereminds,$approveremindlabels,$approveremind_email_user,$approveremind_sms_user;
include(globalStatic::$root_directory."modules/Approve/CommonApproveVar.php");
crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = cls_Send_MassSms::getInstance();
$platform = $cls_Send_MassSms->platform;
$global_approvereminds['sms_platform'] = $platform;

$arr['remindinfo']=$global_approvereminds;
$arr['remindlabel']=$approveremindlabels;
$remind_num_rows=0;
$fieldvalue_arr=[];
$reminddatas=[];
if(!empty($stepid))
{
//    $sql='select * from ld_approvereminds where stepid=?';
    $sql = "select ld_approvereminds.*,ld_smsrelated.template_id,ld_smsrelated.templateparamconf,ld_smstemplates.templatecontent from ld_approvereminds 
left join ld_smsrelated ON ld_approvereminds.id = ld_smsrelated.relatedid AND relatedtable='ld_approvereminds'
left join ld_smstemplates ON ld_smsrelated.template_id = ld_smstemplates.templateid and ld_smstemplates.platform='aliyun'
where stepid=?";
    $remindresult=$adb->pquery($sql,array($stepid));
    $remind_num_rows=$adb->num_rows($remindresult);
    for($i=0;$i<$remind_num_rows;$i++){

        $remindtype=$adb->query_result($remindresult,$i,'type');
        $remindmethod=$adb->query_result($remindresult,$i,'remindmethod');
        $reminduser=$adb->query_result($remindresult,$i,'reminduser');
        $remindcontent=$adb->query_result($remindresult,$i,'remindcontent');
		$reminduserid=$adb->query_result($remindresult,$i,'reminduserid');
        $remindcolumnname=$adb->query_result($remindresult,$i,'remindcolumnname');
        //zkt 20220426 【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
        //添加提醒标题，用于移动端显示
        $remindtitle=$adb->query_result($remindresult,$i,'remindtitle');

        $templateid=$adb->query_result($remindresult,$i,'template_id');
        $templateparamconf=$adb->query_result($remindresult,$i,'templateparamconf');
        if (!empty($templateparamconf)) {
            $templateparamconf=Zend_Json::decode(decode_html($templateparamconf));
        }
        $templatecontent=$adb->query_result($remindresult,$i,'templatecontent');


        $groupname=$global_approvereminds['groups'][$remindtype];
        $reminddatas[$groupname][]=array('method'=>$remindmethod,'users'=>$reminduser,'reminduserid'=>$reminduserid,'remindcolumnname'=>$remindcolumnname
        ,'content'=>$remindcontent,'title'=>$remindtitle
        ,'platform'=>$platform,'templateid'=>$templateid,'templateparamconf'=>$templateparamconf,'templatecontent'=>$templatecontent
        );
       
        
    }
    
   $sql='select * from ld_approvestepdetails  where stepid=? order by  approvestepdetailid asc ';
   $result=$adb->pquery($sql,array($stepid));
   $rows=$adb->num_rows($result);
    $fieldvalue_arr=[];
    for($i=0;$i<$rows;$i++)
    {
         $fieldvalue_arr[]=array('passtype'=>$adb->query_result($result,$i,'pass')
            ,'value'=>$adb->query_result($result,$i,'modulestatus')
            ,'columnname'=>$adb->query_result($result,$i,'pickcolumnname'));
               
    }


    //duan 20230714 读取审批步骤的必填字段信息
    crm_load_class_file('cls_ApproveMandatoryField','modules/Approve');
    $mandatoryfield_str = cls_ApproveMandatoryField::getMandatoryField($stepid);

}
else 
{
    //增加提醒默认值
    
    $reminddatas['before_approve'][]=array('method'=>'dialog','users'=>'approver','reminduserid'=>'','remindcolumnname'=>'', 'content'=>$global_approvereminds['before_approve']['defaultremind']['approver'],'title'=>$global_approvereminds['before_approve']['defaultremindtitle']['approver']);
    $reminddatas['after_approve'][]=array('method'=>'dialog','users'=>'smowner', 'reminduserid'=>'','remindcolumnname'=>'','content'=>$global_approvereminds['after_approve']['defaultremind']['smowner'],'title'=>$global_approvereminds['after_approve']['defaultremindtitle']['smowner']);
    $reminddatas['refuse_approve'][]=array('method'=>'dialog','users'=>'smowner','reminduserid'=>'','remindcolumnname'=>'','content'=>$global_approvereminds['refuse_approve']['defaultremind']['smowner'],'title'=>$global_approvereminds['refuse_approve']['defaultremindtitle']['smowner']);
    $reminddatas['cancel_approve'][]=array('method'=>'dialog','users'=>'smowner','reminduserid'=>'','remindcolumnname'=>'','content'=>$global_approvereminds['cancel_approve']['defaultremind']['smowner'],'title'=>$global_approvereminds['cancel_approve']['defaultremindtitle']['smowner']);
           
     
}
$changefieldValue_arr=[];//高级功能   
$moduleFields=$focus->fieldobj->getModuleFields();
foreach($moduleFields as $fieldname=>$fieldinfo) {
	$displaytype = $fieldinfo->getDisplaytype();
	$presence = $fieldinfo->getPresence();
	$allowedit = $fieldinfo->get_allowedit();
	$columnname=$fieldinfo->getColumnName();
	$fieldlabel=$fieldinfo->getfieldLabel();
    $bigtype = $fieldinfo->getBigType();
    if($fieldinfo->getSaveDataBase()=='no')
        continue;
    //zkt 20220407 50857: （https://kh.xiaoshou360.com/haiyeyiliao/ [^]）海业医疗-复选框字段在被设置为审批必填字段时，不勾选无法保存
    //复选框字段不设置必填
    if($bigtype == 'boolean'){
        continue;
    }
    if($fieldinfo->get_allowedit()=='yes')
    {
        if($bigtype=='picklist'||$bigtype=='text'||$bigtype=='textarea'||$bigtype=='longtextarea')
        {
            $changefieldValue_arr[]=['columnname'=>$columnname,'fieldlabel'=>$fieldlabel,'bigtype'=>$bigtype];
            
        }
    }
    if($displaytype == 1 && $presence != 1 && $allowedit == 'yes'){
		$module_fields[] = array(
			'fieldname' => $fieldname,
			'fieldlabel' => $fieldlabel
		);
	}
    
    
}
//审批必填字段
if(!empty($module_fields)){
	$kk = 0;
	foreach($module_fields as $key => $fieldarr){
		$key = $key + 1;
		$all_module_fields[$kk][] = $fieldarr;
		if($key%4==0){
			$kk++;
		}
	}
} 
 $arr['changefieldvalue']=$changefieldValue_arr;
$arr['module_allfields']=$all_module_fields;//审批必填字段
$arr['label']=['basicinfo'=>$basicinforlabel,'stepname'=>$stepnamelabel,'remark'=>$remarklabel,
'allowedit'=>$alloweditlabel,'setapprover'=>$setapproverlabel,'approvertype'=>$approvertypelabel,
'approveruser'=>$approveruserlabel,'approverrole'=>$approverrolelabel,
'approvercreator'=>$approvercreatorlabel,'approversmowner'=>$approversmownerlabel,
'approverdeparmentposition'=>$approverdeparmentpositionlabel,
'approvertopposition'=>$approvertoppositionlabel,'approverdepartmentuser'=>$approverdepartmentuserlabel,
'allowchangeapprover'=>$allowChangeapproverlabel,'allowaddapprover'=>$allowaddapproverlabel,
'allowchangestep'=>$allowchangesteplabel,'approveremarkrequired'=>$approveremarkrequiredlabel,
'signrequired'=>$signrequiredlabel,'usedprevsign'=>$usedprevsignlabel,
'rewriteagain'=>$rewriteagainlabel,'whenapproverempty'=>$whenapproveremptylabel,'autopass'=>$autopasslabel,
'autochangeadmin'=>$autochangeadminlabel,'specifyapprover'=>$specifyapproverlabel,
'allowendapproveflow'=>$AllowEndApproveFlowlabel,'removerepeatapprover'=>$removerepeatapproverlabel,
'onlyusefirst'=>$onlyusefirstlabel,'continueapprover'=>$continueapproverlabel,'approversamesubmitter'=>$ApproverSameSubmitterlabel,
'multipleapproversone'=>$MultipleapproversOne,'multiplecountersignature'=>$MultipleCountersignature,
'approvalrequired'=>$approvalrequiredlabel,'setquiredfields'=>$setquiredfieldslabel,
'approvereminds'=>$approveremindslabel,'apprveremindbefore'=>$apprveremindbeforelabel,
'approvesuccessremind'=>$approvesuccessremindlabel,'approvefailureremind'=>$approvefailureremindlabel,
'remindmethod'=>$remindmethodlabel,'approverreminder'=>$approverreminderlabel,
'remindcontent'=>$remindcontentlabel,'setremindcontent'=>$setremindcontentlabel,'advfun'=>$advfunlabel,
'dynamicvalue'=>$dynamicvaluelabel,'pass'=>$passlabel,'notpass'=>$notpasslabel,'approveaction'=>$ApproveActionlabel,'field'=>$fieldldabel,'value'=>$Valuelabel,
'approvestep'=>getFixedLabel('APPROVALSTEP'),'approvecontrol'=>getFixedLabel('ApproveControl'),
'member'=>getFixedLabel('SPECIFYUSER'),'sameapprovemany'=>getFixedLabel('SameApproveMany')
,'dynamicassignvalue'=>getFixedLabel('DYNAMICASSIGNMENT'),'AssignValueMethod'=>getFixedLabel('AssignValueMethod')
,'fields'=>getFixedLabel('FIELDS'),'Value'=>getFixedLabel('Value'),'operating'=>getFixedLabel('OPERATING')
,'new'=>getFixedLabel('NEW'),'modulefield'=>getFixedLabel('settherequiredfieldsofapprover')
,'approvalauthority'=>getFixedLabel('ApprovalAuthority'),'showcancelbill'=>getFixedLabel('DisplayRejectDocumentVoidOption')
];
$arr['value']=['stepname'=>$stepname,'description'=>$description,'approvetype'=>$approvetype,'module_field'=>explode(",",$module_field),
	'approvevalue'=>$approvevalue,'approvevalue_name'=>$approvevaluename, 'specifyapproverid'=>$specifyapproverid,
	'emptyapproverdeal'=>$emptyapproverdeal,'emptyapproverdeal_username'=>$emptyapproverdeal_username, 'countersigner'=>$countersigner,
	'alloweditbill'=>$alloweditbill,'ended'=>$ended,'step'=>$step,'augmentsinger'=>$augmentsinger,
	'approveremarkrequire'=>$approveremarkrequire,'writesignrequired'=>$writesignrequired,
    'writesignlogtype'=>$writesignlogtype,'approverremovetype'=>$approverremovetype,
    'reminddata'=>$reminddatas,'fieldvalue'=>$fieldvalue_arr,'mandatoryfield'=>$mandatoryfield_str,'approvalauthority'=>$approvalauthority];

// 参数的提示信息
$arr['tipslabel'] = ['showcancelbill'=>'1. '.getFixedLabel('DisplayRejectDocumentVoidOptionTips1').'<br>'.'2. '.getFixedLabel('DisplayRejectDocumentVoidOptionTips2')];

ConvertTojsonString(1,$arr,'success');

?>