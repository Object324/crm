<?php 
/*
edit:diony
date:20240325
resson:移动端获取字符串翻译
*/
global $MobileLanguageType;
if(isset($_REQUEST['mode']) && !empty($_REQUEST['mode'])){
    $mode = $_REQUEST['mode'];
}

if($mode == 'setting'){
    $label_arr=array(
        'APPSETTINGS',//设置
        'PUSHMESSAGEREMINDER',//推送消息提醒
        'PERSONALDATA',//个人资料
        'CHANGEPASSWORD',//修改密码
        'LANGUAGE',//语言
        'VERSIONSWITCHING',//版本切换
        'CURRENTVERSION',//当前版本
        'ENTERPRISEACCOUNT',//企业号
        'LOGOUT',//退出登录
        'WARMPROMPT', //温馨提示
        'LOADING',//加载中
        'CONFIRMED',//确定
        'CANCEL',//取消
        'SUREWANTEXIT',//确定退出?
    );
}
if($mode == 'settingpublic'){
    $label_arr=array(
        'BLOCKDISPLAY',//区块显示
        'LISTDISPLAY',//列表显示
        'MOREFEATURESINDUSTRY',//更多功能和行业解决方案
        'PLEASECALLINQUIRE',//请来电咨询
        'PERSONALDATA',//修改个人资料
        'CHANGELOGINPASSWORD',//修改登录密码
        'WHENSWITCHINGVERSIONSTIP',//切换版本时，可能会导致其他正在使用的用户无法保存数据，无法刷新列表（可通过退出，重新进入解决）
        'SWITCHING',//切换中...
        'SWITCHSUCCESSFUL',//切换成功
    );
}
if($mode == 'updatepwd'){
    $label_arr=array(
        'CHANGEPASSWORD',//修改密码
        'OLDPASSWORD',//旧密码
        'NEWPASSWORD',//新密码
        'Password_confirmation',//确认密码
        'pleaseenter',//请输入
        'OLDPASSWORDCANOTEMPTY',//旧密码不能为空
        'ENTERNEWPASSWORD',//新密码不能为空
        'ENTERNEWPASSWORDAGAIN',//确认密码不能为空
        'PMINCONSISTENTPASSWORD',//新密码和确认密码不一致
        'SUCCESSFULLYMODIFIED',//修改成功
        'SAVE',//保存
    );
}
if($mode == 'EntryDetail'){
    $label_arr=array(
        'ENTRYINFORMATION',//分录信息
        'nodata',//没有数据
        'CANCEL',//取消
        'DOWNLOAD',//下载
        'CANNOTVIEWMULTIPLEDOC',//多条单据无法查看明细
        'PLEASECONFIRMSOFTWAREFORFILE',//请确定是否有对应文件的打开软件
        'OPENING',//打开中...
    );
}
if($mode == 'reply'){
    $label_arr=array(
        'COMMENTAPP',//点评
        'LBL_COOPERATIVEWORK',//工作汇报
        'Reply',//回复
        'HAVEREVIEWED',//已点评
        'SCORE',//评分
        'NOTFILLEDINTHECONTENT',//您还没有填写内容
        'PLEASEFILLINTHECONTENT',//请填写内容
        'RELEASENEW',//发布
    );
}
if($mode == 'forward'){
    $label_arr=array(
        'FORWARDING',//转发
        'PLEASESELECTCCRANGE',//请选择抄送范围
        'CCRANGE',//抄送范围
        'PLEASEFILLINTHECONTENT',//请填写内容
        'RELEASENEW',//发布
    );
}
if($mode == 'searchtable'){
    $label_arr=array(
        'FILTERCRITERIA',//筛选条件
        'ALL',//全部
        'Days',//天
        'today',//今天
        'syesterday',//昨天
        'Week',//周
        'thisweek',//本周
        'lastweek',//上周
        'nMonth',//月
        'thismonth',//本月
        'lastmonth',//上月
        'QUARTER',//季
        'thisfq',//本季度
        'prevfq',//上季度
        'nYear',//年
        'thisyear1',//本年度
        'lastyear1',//上年度
        'custom',//自定义
        'Start_Date',//开始日期
        'End_Date',//结束日期
        'PLEASESELECTENDDATE',//请选择结束日期
        'PLEASESELECTSTARTDATE',//请选择开始日期
        'approvestatus',//审批状态
        'CONFIRMED',//确定
        'CANCEL',//取消
        'Unapproved',//未提交
        'Approvalof',//审批中
        'Approved',//已批准
        'Rejected',//已拒绝
        'Dismissed',//已驳回
        'CUSTOMTIME',//自定义时间
        'STARTDATENOTBEEMPTY',//开始日期不能为空
        'ENDDATENOTBEEMPTY',//结束日期不能为空
        'STARTDATECANOTGREATERENDDATEAPP',//开始日期不能大于结束日期！
    );
}
if($mode == 'approve_submit'){
    $label_arr=array(
        'SUBMITAPPROVAL',//提交审批
        'Approval_Process',//审批流程
        'UrgentApproval',//需要加急审批
        'APPURGENTAPPROVAL',//加急审批
        'SUBMITCOMMENTS',//提交意见
        'PLEASEFILLINYOURCOMMENTS',//请填写意见
        'SUBMIT',//提交
        'APPROVER',//审批人
        'ConcurrentApproval',//并发审批
        'Countersigner',//会签审批人
        'AddApprover',//添加审批人
        'APPROVERISEMPTY',//审批人为空，无法提交
        'APPROVEREMARKREQUIRE',//审批意见不能为空
        'SUCCESSFULLYSUBMITTEDAPPROVAL',//提交审批成功
        'CONFIRMED',//确定
        'CANCEL',//取消
    );
}
if($mode == 'approve_expediting'){
    $label_arr=array(
        'Expediting',//催审
        'APPROVALSTEP',//审批步骤
        'Recipient',//接收人
        'REMINDSCONTENT',//提醒内容
        'PLEASEFILLINREMINDERCONTENT',//请填写提醒内容
        'SUBMIT',//提交
        'EXPEDITIONSUCCEEDED',//催审成功
        'CONFIRMED',//确定
        'CANCEL',//取消
    );
}


$fixedlabel_arr = TransFieldlabel($label_arr,'no');
$jsonArray['arrFixedLabel']=$fixedlabel_arr;
ConvertTojsonString(1,$jsonArray,'success');
?>