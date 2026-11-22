<?php
$global_approvereminds['groups']=array('before_approve','after_approve','refuse_approve','cancel_approve');
// 提醒方式，提醒人
foreach ($global_approvereminds['groups'] as $index => $type) {
    $global_approvereminds[$type]['method'] = array('dialog','email','sms','weixin');
    if($type == 'before_approve'){
        $global_approvereminds[$type]['dialog']['reminduser']=array('approver','selectuser','selectrole','departmentposition','topposition','departmentuser');
        $global_approvereminds[$type]['email']['reminduser']=array('approver','selectuser','selectrole','departmentposition','topposition','departmentuser','Accounts_email','Contacts_email');
        $global_approvereminds[$type]['sms']['reminduser']=array('approver','selectuser','selectrole','departmentposition','topposition','departmentuser','Accounts_sms','Contacts_sms');
        $global_approvereminds[$type]['weixin']['reminduser']=array('approver','selectuser','selectrole','departmentposition','topposition','departmentuser');
    }else{
        $global_approvereminds[$type]['dialog']['reminduser'] = array('smowner','smcreator','selectuser','selectrole','departmentposition','topposition','departmentuser');
        $global_approvereminds[$type]['email']['reminduser'] = array('smowner','smcreator','selectuser','selectrole','departmentposition','topposition','departmentuser','Accounts_email','Contacts_email');
        $global_approvereminds[$type]['sms']['reminduser'] = array('smowner','smcreator','selectuser','selectrole','departmentposition','topposition','departmentuser','Accounts_sms','Contacts_sms');
        $global_approvereminds[$type]['weixin']['reminduser'] = array('smowner','smcreator','selectuser','selectrole','departmentposition','topposition','departmentuser');
    }
}

$global_approvereminds['reminduser']['chkselect']=array('selectuser','selectrole','departmentposition','topposition','departmentuser','Accounts_email','Contacts_email','Accounts_sms','Contacts_sms');

$global_approvereminds['before_approve']['defaultremind']['approver']='有新的{modulelabel}需要审批，请及时处理！';
$global_approvereminds['before_approve']['defaultremind']['selectuser']='{smownerid}的{modulelabel}已提交审批并抄送给您，请点击查看详情！';
$global_approvereminds['before_approve']['defaultremind']['selectrole']='{smownerid}的{modulelabel}已提交审批并抄送给您，请点击查看详情！';
$global_approvereminds['before_approve']['defaultremind']['departmentposition']='{smownerid}的{modulelabel}已提交审批并抄送给您，请点击查看详情！';
$global_approvereminds['before_approve']['defaultremind']['topposition']='{smownerid}的{modulelabel}已提交审批并抄送给您，请点击查看详情！';
$global_approvereminds['before_approve']['defaultremind']['departmentuser']='{smownerid}的{modulelabel}已提交审批并抄送给您，请点击查看详情！';
$global_approvereminds['before_approve']['defaultremind']['Accounts_email']='您的{modulelabel}已经提交审批，请耐心等待！';
$global_approvereminds['before_approve']['defaultremind']['Contacts_email']='您的{modulelabel}已经提交审批，请耐心等待！';
$global_approvereminds['before_approve']['defaultremind']['Accounts_sms']='您的{modulelabel}已经提交审批，请耐心等待！';
$global_approvereminds['before_approve']['defaultremind']['Contacts_sms']='您的{modulelabel}已经提交审批，请耐心等待！';



$global_approvereminds['after_approve']['defaultremind']['smowner']='您负责的{modulelabel}已通过审批步骤{step}';
$global_approvereminds['after_approve']['defaultremind']['smcreator']='您创建的{modulelabel}已通过审批步骤{step}';
$global_approvereminds['after_approve']['defaultremind']['selectuser']='{smownerid}的{modulelabel}已通过审批步骤{step}并抄送给您，请点击查看详情！';
$global_approvereminds['after_approve']['defaultremind']['selectrole']='{smownerid}的{modulelabel}已通过审批步骤{step}并抄送给您，请点击查看详情！';
$global_approvereminds['after_approve']['defaultremind']['departmentposition']='{smownerid}的{modulelabel}已通过审批步骤{step}并抄送给您，请点击查看详情！';
$global_approvereminds['after_approve']['defaultremind']['topposition']='{smownerid}的{modulelabel}已通过审批步骤{step}并抄送给您，请点击查看详情！';
$global_approvereminds['after_approve']['defaultremind']['departmentuser']='{smownerid}的{modulelabel}已通过审批步骤{step}并抄送给您，请点击查看详情！';
$global_approvereminds['after_approve']['defaultremind']['Accounts_email']='您的{modulelabel}已通过审批步骤{step}';
$global_approvereminds['after_approve']['defaultremind']['Contacts_email']='您的{modulelabel}已通过审批步骤{step}';
$global_approvereminds['after_approve']['defaultremind']['Accounts_sms']='您的{modulelabel}已通过审批步骤{step}';
$global_approvereminds['after_approve']['defaultremind']['Contacts_sms']='您的{modulelabel}已通过审批步骤{step}';



$global_approvereminds['refuse_approve']['defaultremind']['smowner']='您负责的{modulelabel}未通过审批步骤{step}，原因：{description}';
$global_approvereminds['refuse_approve']['defaultremind']['smcreator']='您创建的{modulelabel}未通过审批步骤{step}，原因：{description}';
$global_approvereminds['refuse_approve']['defaultremind']['selectuser']='{smownerid}的{modulelabel}未通过审批步骤{step}，原因：{description}，并抄送给您，请点击查看详情！';
$global_approvereminds['refuse_approve']['defaultremind']['selectrole']='{smownerid}的{modulelabel}未通过审批步骤{step}，原因：{description}，并抄送给您，请点击查看详情！';
$global_approvereminds['refuse_approve']['defaultremind']['departmentposition']='{smownerid}的{modulelabel}未通过审批步骤{step}，原因：{description}，并抄送给您，请点击查看详情！';
$global_approvereminds['refuse_approve']['defaultremind']['topposition']='{smownerid}的{modulelabel}未通过审批步骤{step}，原因：{description}，并抄送给您，请点击查看详情！';
$global_approvereminds['refuse_approve']['defaultremind']['departmentuser']='{smownerid}的{modulelabel}未通过审批步骤{step}，原因：{description}，并抄送给您，请点击查看详情！';
$global_approvereminds['refuse_approve']['defaultremind']['Accounts_email']='您的{modulelabel}未通过审批步骤{step}，原因：{description}';
$global_approvereminds['refuse_approve']['defaultremind']['Contacts_email']='您的{modulelabel}未通过审批步骤{step}，原因：{description}';
$global_approvereminds['refuse_approve']['defaultremind']['Accounts_sms']='您的{modulelabel}未通过审批步骤{step}，原因：{description}';
$global_approvereminds['refuse_approve']['defaultremind']['Contacts_sms']='您的{modulelabel}未通过审批步骤{step}，原因：{description}';


$global_approvereminds['cancel_approve']['defaultremind']['smowner']='您负责的(modulelabel}未通过审批步骤(step}已作废，原因:{description}';
$global_approvereminds['cancel_approve']['defaultremind']['smcreator']='您创建的{modulelabel}未通过审批步骤{step}已作废，原因：{description}';
$global_approvereminds['cancel_approve']['defaultremind']['selectuser']='{smownerid}的{modulelabel}未通过审批步骤{step}已作废，原因：{description}，并抄送给您，请点击查看详情！';
$global_approvereminds['cancel_approve']['defaultremind']['selectrole']='{smownerid}的{modulelabel}未通过审批步骤{step}已作废，原因：{description}，并抄送给您，请点击查看详情！';
$global_approvereminds['cancel_approve']['defaultremind']['departmentposition']='{smownerid}的{modulelabel}未通过审批步骤{step}已作废，原因：{description}，并抄送给您，请点击查看详情！';
$global_approvereminds['cancel_approve']['defaultremind']['topposition']='{smownerid}的{modulelabel}未通过审批步骤{step}已作废，原因：{description}，并抄送给您，请点击查看详情！';
$global_approvereminds['cancel_approve']['defaultremind']['departmentuser']='{smownerid}的{modulelabel}未通过审批步骤{step}已作废，原因：{description}，并抄送给您，请点击查看详情！';
$global_approvereminds['cancel_approve']['defaultremind']['Accounts_email']='您的{modulelabel}未通过审批步骤{step}已作废，原因：{description}';
$global_approvereminds['cancel_approve']['defaultremind']['Contacts_email']='您的{modulelabel}未通过审批步骤{step}已作废，原因：{description}';
$global_approvereminds['cancel_approve']['defaultremind']['Accounts_sms']='您的{modulelabel}未通过审批步骤{step}已作废，原因：{description}';
$global_approvereminds['cancel_approve']['defaultremind']['Contacts_sms']='您的{modulelabel}未通过审批步骤{step}已作废，原因：{description}';

//zkt 20220426 【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
//增加提醒标题默认值
$global_approvereminds['before_approve']['defaultremindtitle']['approver']='【{modulelabel}】审批提醒';

$global_approvereminds['after_approve']['defaultremindtitle']['smowner']='【{modulelabel}】审批结果通知';
$global_approvereminds['after_approve']['defaultremindtitle']['smcreator']='【{modulelabel}】审批结果提醒';

$global_approvereminds['refuse_approve']['defaultremindtitle']['smowner']='【{modulelabel}】审批结果提醒';
$global_approvereminds['refuse_approve']['defaultremindtitle']['smcreator']='【{modulelabel}】审批结果提醒';

$global_approvereminds['cancel_approve']['defaultremindtitle']['smowner']='【{modulelabel}】审批结果提醒';
$global_approvereminds['cancel_approve']['defaultremindtitle']['smcreator']='【{modulelabel}】审批结果提醒';

foreach ($global_approvereminds['groups'] as $index => $type) {
    $tmp_selecttype_arr = array('selectuser','selectrole','departmentposition','topposition','departmentuser');
    foreach ($tmp_selecttype_arr as $tmpi => $selecttype) {
        $global_approvereminds[$type]['defaultremindtitle'][$selecttype] = '【{modulelabel}】审批结果提醒';
    }
}

$approveremindlabels['grouplabel']=array('before_approve'=>getFixedLabel('APPROVEBEFOREPROCESS'),'after_approve'=>getFixedLabel('APPROVEDSUCCESS'),'refuse_approve'=>getFixedLabel('APPROVEREFUSE'),'cancel_approve'=>getFixedLabel('APPROVEAFTERINVALIDATION'));
//35752: 审批流程管理>>审批步骤>>审批通知界面：审批处理前、审批通过、审批不通过提醒方式“对话框”后面增加“/微信
$approveremindlabels['methodlabel']=array("dialog"=>getFixedLabel('DIALOG').'/'.getFixedLabel('WEIXIN'),'sms'=>getFixedLabel('SMS')
                                ,'email'=>getFixedLabel('EMAIL'),'weixin'=>getFixedLabel("WEIXIN"));

$approveremindlabels['tablethlabel']=array('remindmethod'=>getFixedLabel('REMINDMETHOD')
                        ,'remindperson'=>getFixedLabel('REMINDERPEOPLE')
                        ,'remindtitle'=>getFixedLabel('ReminderTitle')
                        ,'remindcontent'=>getFixedLabel('REMINDSCONTENT')
                        ,'operating'=>getFixedLabel('OPERATING')
                        ,'delete'=>getFixedLabel('DELETE')
                        ,'new'=>getFixedLabel('NEW'));
                                
$approveremindlabels['reminduserlabel']=array('approver'=>getFixedLabel("APPROVER"),
                    'smowner'=>getFixedLabel("ASSIGNEDTO"),
                    'smcreator'=>getFixedLabel("Person_in_charge"),
                    'selectuser'=>getFixedLabel('SPECIFYUSER'),
                    'selectrole'=>getFixedLabel('SPECIFYROLE'),// 指定角色
                    'departmentposition'=>getFixedLabel('SPECIFYPROMOTERDEP'),// 单据负责人部门用户的职位级别
                    'topposition'=>getFixedLabel('LBL_POSITIONLEVEL'),// 单据负责人直属上级部门用户的职位级别
                    'departmentuser'=>getFixedLabel('LBL_POSITIONDEPARTMENT'),// 指定部门用户的职位级别
                    'Accounts_email'=>getFixedLabel('ASSIGNACCOUNTEMAIL'),
                    'Contacts_email'=>getFixedLabel('ASSIGNCONTACTEMAIL'),
                    'Accounts_sms'=>getFixedLabel('ASSIGNACCOUNTSSMS'),
                    'Contacts_sms'=>getFixedLabel('ASSIGNCONTACTSMS') );
$approveremind_email_user=array('Accounts_email','Contacts_email');
$approveremind_sms_user=array('Accounts_sms','Contacts_sms');
?>