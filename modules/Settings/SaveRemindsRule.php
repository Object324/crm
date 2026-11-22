<?php
/***************************************************
**edit:diony
**date:2014-05-09
**reason:保存自动提醒
***************************************************/
global $adb,$current_user;
//echo '<pre>';
//print_r($_REQUEST);

//echo '</pre>';
$annualremind='no';
if(isset($_REQUEST['annualremind']))
{
    //$annualremind='yes';//每年提醒
}
if(isset($_REQUEST['record']) && $_REQUEST['record']!='')
    $record=$_REQUEST['record'];
if(isset($_REQUEST['blockid']) && $_REQUEST['blockid']!='')
    $blockid=$_REQUEST['blockid'];
if(isset($_REQUEST['mode']) && $_REQUEST['mode']!='')
    $mode=$_REQUEST['mode'];
//规则名称    
if(isset($_REQUEST['remindRuleName']) && $_REQUEST['remindRuleName']!='')
    $remindsname=$_REQUEST['remindRuleName'];
//提醒时间 
if(isset($_REQUEST['reminds_time']) && $_REQUEST['reminds_time']!='')
    $reminds_time=$_REQUEST['reminds_time'];
//起始时间 
if(isset($_REQUEST['startdata']) && $_REQUEST['startdata']!='')
    $reminds_starttime=$_REQUEST['startdata'];
//指定重复次数 
if(isset($_REQUEST['remindsNums']) && $_REQUEST['remindsNums']!='')
    $reminds_nums=$_REQUEST['remindsNums'];
//提醒重复方式 
if(isset($_REQUEST['reminds_method']) && $_REQUEST['reminds_method']!=''){
    $reminds_method=$_REQUEST['reminds_method'];
}

//固定周期，提醒间隔 
if($_REQUEST['reminds_method']==1)
    $reminds_nums1=$_REQUEST['remindnums1'];
else if($_REQUEST['reminds_method']==3)//每年提醒
{
    $reminds_nums1=$_REQUEST['advanceannulremind'];
    $reminds_nums="";
    
}
//指定周期，提醒间隔 

//提醒基本信息 start
if(isset($_REQUEST['stdDateFilterField']) && $_REQUEST['stdDateFilterField']!='')
    $stdDateFilterField=$_REQUEST['stdDateFilterField'];//选择字段
if(isset($_REQUEST['stdDateFilter']) && $_REQUEST['stdDateFilter']!='')
    $stdDateFilter=$_REQUEST['stdDateFilter'];//选择时间段
if(isset($_REQUEST['startdate']) && $_REQUEST['startdate']!='')
    $startdate=$_REQUEST['startdate'];//开始日期
if(isset($_REQUEST['enddate']) && $_REQUEST['enddate']!='')
    $enddate=$_REQUEST['enddate'];//结束日期
//提醒基本信息 end 

//提醒高级条件 start
$columlist = array();
$tmpk=0;
for($i = 0; $i<100;$i++)
{
    //为空值的修改
    if($_REQUEST['fcol' . $i] != '' && $_REQUEST['fop' . $i] != '' )
    {
        $columlist[$tmpk] = array(
            'index'=>$tmpk+1,
            'fcol' =>$_REQUEST['fcol' . $i],
            'fop' =>$_REQUEST['fop' . $i],
            'fval' =>$_REQUEST['fval' . $i],
            'fval_ext' =>$_REQUEST['fval_ext' . $i],
            'fcon' =>$_REQUEST['fcon' . $i],
        );
        $tmpk++;
    }
}
/*
echo '<pre>';
print_r($columlist);
echo '</pre>';
exit;*/
//提醒高级条件 end   
$reminds_nums2arr = array();
for($i=1;$i<=$reminds_nums;$i++)
{
    $reminds_nums2 = 'remindnums2'.$i;
    if(isset($_REQUEST[$reminds_nums2]) && $_REQUEST[$reminds_nums2]!='')
    {
        $reminds_nums2arr[]=array(
        'index'=>$i,
        'indexvalue'=>$_REQUEST[$reminds_nums2]
        );
    }
} 

//echo '<pre>';
//print_r($reminds_nums2arr);exit;
//提醒人 
if(isset($_REQUEST['reminds_to']) && $_REQUEST['reminds_to']!='')
    $reminds_to=$_REQUEST['reminds_to'];
//提醒内容 提醒方式为“对话框/移动端”或“短信”时，提醒内容保存在文本框
if($_REQUEST['remind_method']==0||$_REQUEST['remind_method']==2){
//    $reminds_content=strip_tags($reminds_content);
    if(isset($_POST['reminds_content_text']) && $_POST['reminds_content_text']!=''){
        $reminds_content=$_POST['reminds_content_text']; 
        $reminds_content = str_replace("\r\n","\n",$reminds_content);
    }
}
else{
    if(isset($_POST['reminds_content']) && $_POST['reminds_content']!='')
        $reminds_content=$_POST['reminds_content']; 
}

$reminds_date = date('Y-m-d H:i:s');

$remindmethod=$_REQUEST['remind_method'];//提醒方式
// 语音提醒 模板 zxm 2021-0909 阳光创信 语音提醒 将提醒语音模板ID 存到remindcontent字段
if($remindmethod==201){
    $reminds_content = $_REQUEST['SMSVoice_template'];
}
if($remindmethod==2||$remindmethod==0)//提醒方式为“对话框/移动端”或“短信”时，提醒内容去掉HTML样式
{
    //28954: 自动提醒保存改进：增加判断如果是短信提醒，提醒内容去掉HTML样式
    $reminds_content=strip_tags($reminds_content);
    
}
if($reminds_to=='specifyuser')//指定用户
        $userids=$_REQUEST['userid'];
    else
        $userids='';

//提醒人设置值
$remindervalue = '';
if($reminds_to =='specifyuser'){
    $remindervalue = $_REQUEST['userid'];
}
else if($reminds_to == 3){
    $remindervalue = $_REQUEST['user_role'];
}
else if($reminds_to == 4){
    $remindervalue = $_REQUEST['position'];
}
else if($reminds_to == 5){
    $remindervalue = $_REQUEST['positionlevel'];
}
else if($reminds_to == 6){
    $remindervalue = $_REQUEST['positiondepartment1'].'::'.$_REQUEST['positiondepartment2'];
}
else if(stripos($reminds_to,'UserField##')!==false){
    $tmpreminds_toarr = explode('##', $reminds_to);
    $remindervalue = $tmpreminds_toarr[1].'##'.$tmpreminds_toarr[2];
}

crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = cls_Send_MassSms::getInstance();
$platform = $cls_Send_MassSms->platform;
if($mode=='edit'){
    $query="update ld_automaticreminds set name=?,columnname=?,startdate=?,remindnum=?,remindway=?,
    remindday=?,reminder=?,remindcontent=?,modifiedby=?,modifiedtime=?,
    remindmethod=?,specifyuserids=?,annualremind=?,remindervalue=?  where id=?";
    
        
    $adb->pquery($query,array($remindsname,$reminds_time,$reminds_starttime,$reminds_nums,
    $reminds_method,$reminds_nums1,$reminds_to,$reminds_content,$current_user->id,$reminds_date,$remindmethod,$userids,$annualremind,$remindervalue,$record));

    if ($remindmethod == 2 && $platform == 'aliyun' && isset($_REQUEST['smstemplateid']) && !empty($_REQUEST['smstemplateid'])) {
        $sql = "select 1 from ld_smsrelated where relatedtable=? and relatedid=?";
        $result = $adb->pquery($sql,array("ld_automaticreminds",$record));
        if ($adb->num_rows($result) > 0) {
            $cls_Send_MassSms->updateSmsRelated("ld_automaticreminds", $record, getTabModuleName($blockid), trim($_REQUEST['smstemplateid']), trim($_REQUEST['smstemplateparamconf']), 'autoremind');
        }else{
            $cls_Send_MassSms->insertSmsRelated("ld_automaticreminds", $record, getTabModuleName($blockid), trim($_REQUEST['smstemplateid']), trim($_REQUEST['smstemplateparamconf']),'autoremind');
        }
    }
    
    //删除原有规则
    $params=array($record);
    $sql="delete from ld_remindway where wayid=?";     
    $adb->pquery($sql,$params);
    $sql="delete from ld_remindcvstdfilter where cvid=?"; 
    $adb->pquery($sql,$params);
    $sql="delete from ld_remindcvadvfilter where cvid=?"; 
    $adb->pquery($sql,$params); 
    $sql="delete from ld_remindcvadvfilter_grouping where cvid=?"; 
    $adb->pquery($sql,$params);   
    
    //删除对应的提醒数据（提醒数据表、提醒数据临时表）
    $sql="delete from ld_reminds where reminds_ruleid=? and  ld_reminds.status_rmd = '未读' and ifnull(push_to_weixin,'')<>3"; 
    $adb->pquery($sql,$params); 
    $sql="delete from ld_tmpreminder where reminds_ruleid=?"; 
    $adb->pquery($sql,$params); 
    
    //邮件删除
    $sql='delete from ld_emaildetails  where emailid in(select activityid from ld_seactivityrel
     inner join ld_activity_reminder on ld_activity_reminder.activity_id=ld_seactivityrel.activityid
      where ld_activity_reminder.reminds_ruleid=? and  reminder_sent=0)';
      $adb->pquery($sql,$params);
    $sql='delete from ld_activity where activityid in (select activityid from ld_seactivityrel
     inner join ld_activity_reminder on ld_activity_reminder.activity_id=ld_seactivityrel.activityid
      where ld_activity_reminder.reminds_ruleid=? and  reminder_sent=0)';
     $adb->pquery($sql,$params);
    $sql='delete from ld_crmentity where crmid in(
        select activityid from ld_seactivityrel
     inner join ld_activity_reminder on ld_activity_reminder.activity_id=ld_seactivityrel.activityid
      where ld_activity_reminder.reminds_ruleid=? and  reminder_sent=0)';
    $adb->pquery($sql,$params);
     $sql='delete from 	ld_activity_reminder where activity_id in(select activityid from ld_seactivityrel where ld_seactivityrel.reminds_ruleid=?) and reminder_sent=0';
    $adb->pquery($sql,$params);
    
    //$sql='delete from ld_smssend where reminds_ruleid=? and smsresult=?';//删除该规则下所有未发送的提醒
   //  $adb->pquery($sql,array($record,'-1'));
    
    //循环插入指定周期值
    if($reminds_method == 2){     
        for($i=0;$i<count($reminds_nums2arr);$i++)
        {
            $sql="INSERT INTO ld_remindway (wayid,remindsday,sequence) VALUES(?,?,?)"; 
            $params=array($record,$reminds_nums2arr[$i]['indexvalue'],$reminds_nums2arr[$i]['index']);
            $adb->pquery($sql,$params);
            
        }  
    }
    
    //提醒基本信息设置保存
    if(empty($startdate)&&empty($enddate))
    {
        
    }
    else
    {
            $sql="INSERT INTO ld_remindcvstdfilter (cvid,columnname,stdfilter,startdate,enddate) VALUES(?,?,?,?,?)";
        //$stdDateFilterField=explode(':',$stdDateFilterField);
        //$stdDateFilterField=$stdDateFilterField[1];
        $params=array($record,$stdDateFilterField,$stdDateFilter,$startdate,$enddate);
        $adb->pquery($sql,$params);
    }
  
    //提醒高级条件设置保存
    for($i=0;$i<count($columlist);$i++)
    {
        $sql="INSERT INTO ld_remindcvadvfilter (cvid,columnindex,columnname,comparator,value,column_condition,groupid) VALUES(?,?,?,?,?,?,?)"; 
        //$columname=explode(':',$columlist[$i]['fcol']);
        if($columlist[$i]['fop']=='bw')
        {
            $params=array(
                $record,
                $columlist[$i]['index'],
                $columlist[$i]['fcol'],
                $columlist[$i]['fop'],
                $columlist[$i]['fval'].','.$columlist[$i]['fval_ext'],
                $columlist[$i]['fcon'],
                '1',
            );
        }
        else
        $params=array(
            $record,
            $columlist[$i]['index'],
            $columlist[$i]['fcol'],
            $columlist[$i]['fop'],
            $columlist[$i]['fval'],
            $columlist[$i]['fcon'],
            '1',
        );
        $adb->pquery($sql,$params);
    }
    
     //分组保存
    $nums=$_REQUEST['selectrow'];
    $str="";
    for($i=0;$i<$nums;$i++){
        $str.= $i.' and ';
    }
    $str = trim($str,'and ');
    //echo $str;exit;
    $params=array(1,$record,'',$str);
    $sql="INSERT into ld_remindcvadvfilter_grouping (groupid,cvid,group_condition,condition_expression) 
          VALUES (?,?,?,?)";     
    $adb->pquery($sql,$params);
}
else{
    $sequence = 10000;//设置一个默认值,保证插入数据显示在最后面
    //var_dump($reminds_starttime);exit;
    $query="insert into ld_automaticreminds
    (tabid,name,columnname,startdate,remindnum,remindway,remindday,reminder,remindcontent
    ,status,smcreatorid,createdtime,remindmethod,specifyuserids,annualremind,remindervalue,sequence)";
    $query .="value(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
  
        
    $params=array($blockid,$remindsname,$reminds_time,$reminds_starttime,$reminds_nums,
    $reminds_method,$reminds_nums1,$reminds_to,$reminds_content,1,$current_user->id,$reminds_date,$remindmethod,$userids,$annualremind,$remindervalue,$sequence);
    $adb->pquery($query,$params);
    $record = $adb->getLastInsertID();

    //循环插入指定周期值
    if($reminds_method == 2){     
        for($i=0;$i<count($reminds_nums2arr);$i++)
        {
            $sql="INSERT INTO ld_remindway (wayid,remindsday,sequence) VALUES(?,?,?)"; 
            $params=array($record,$reminds_nums2arr[$i]['indexvalue'],$reminds_nums2arr[$i]['index']);
            $adb->pquery($sql,$params);
            
        }  
    }

    if ($remindmethod == 2 && $platform == 'aliyun' && isset($_REQUEST['smstemplateid']) && !empty($_REQUEST['smstemplateid'])) {
        //写入关联表
        $cls_Send_MassSms->insertSmsRelated("ld_automaticreminds", $record, getTabModuleName($blockid), trim($_REQUEST['smstemplateid']), trim($_REQUEST['smstemplateparamconf']),'autoremind');
    }
    
    //提醒基本信息设置保存
     if(empty($startdate)&&empty($enddate))
    {
        
    }
    else
    {
         $sql="INSERT INTO ld_remindcvstdfilter (cvid,columnname,stdfilter,startdate,enddate) VALUES(?,?,?,?,?)";
        $params=array($record,$stdDateFilterField,$stdDateFilter,$startdate,$enddate);
        $adb->pquery($sql,$params);
    }
    
   
   
    //提醒高级条件设置保存
    for($i=0;$i<count($columlist);$i++)
    {
        $sql="INSERT INTO ld_remindcvadvfilter (cvid,columnindex,columnname,comparator,value,column_condition,groupid) VALUES(?,?,?,?,?,?,?)"; 
        //$columname=explode(':',$columlist[$i]['fcol']);
        $params=array(
            $record,
            $columlist[$i]['index'],
            $columlist[$i]['fcol'],
            $columlist[$i]['fop'],
            $columlist[$i]['fval'],
            $columlist[$i]['fcon'],
            '1',
        );
        $adb->pquery($sql,$params);
    }
    //分组保存
    $nums=$_REQUEST['selectrow'];
    $str="";
    for($i=0;$i<$nums;$i++){
        $str.= $i.' and ';
    }
    $str = trim($str,'and ');
    //echo $str;exit;
    $params=array(1,$record,'',$str);
    $sql="INSERT into ld_remindcvadvfilter_grouping (groupid,cvid,group_condition,condition_expression) 
          VALUES (?,?,?,?)";     
    $adb->pquery($sql,$params);
    
}
@unlink('dataCache/execDays/autoremind.txt');
$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
?>