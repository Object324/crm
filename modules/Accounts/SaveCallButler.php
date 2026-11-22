<?php
ini_set('session.cookie_httponly', 1);

session_start();
/**
 * 更新操作
 * edit:diony
 * date:20141024
 * reason:保存电话录音信息
 * */
 foreach($_POST as $key=>$value)
 {
    $_REQUEST[$key]=$value;
 }
global $adb,$current_user;

$current_user->id=$_SESSION['authenticated_user_id'];
 
if(!$adb)
    $adb=PearDatabase::getInstance();

$callType = $_REQUEST['calltype'];//通话类型，0来电；1去电
if($callType=="1")
{
    $callTypeName = "去电";
}
else
{
    $callTypeName = "来电";
}
$callID = $_REQUEST['callid'];//电话号码
$beginTime = $_REQUEST['begintime'];//开始时间
$endTime = $_REQUEST['endtime'];//结束时间
if(empty($endTime))
{
    $endTime = $_REQUEST['enddtime'];//结束时间
}
$seconds = strtotime($endTime) - strtotime($beginTime);//通话时长（秒）
$pathName = $_REQUEST['pathName'];
$fileName = $_REQUEST['filename'];

$pathName=str_replace("\\\\","\\",$pathName);

$fielnames=explode("\\",$fileName);
$realname=$fielnames[sizeof($fielnames)-1];


//判断是否有录音文件，并插入或者修改录音文件信息
$callButlerRemarks = "";
$pathName = str_replace("\\\\","\\",$pathName);

$callbutlerGetSql = "select id from ld_callbutler where  soundrecordingfile like '%$realname%' ";

$callbutlerGetResult=$adb->pquery($callbutlerGetSql);
if($adb->num_rows($callbutlerGetResult))
{
    //存在
    $callButlerID = $adb->query_result($callbutlerGetResult,0,'id');
    
    //附件上传 session丢失
    $sqlUpdate = "update ld_callbutler set calltype = ?,phone = ?,status = ?,
    begintime = ?,endtime = ?,time = ? 
    where id = ? ";
	
    //$updateResult=$adb->pquery($sqlUpdate,array($callTypeName,$callButlerRemarks,$callButlerID));
    $updateResult=$adb->pquery($sqlUpdate,array($callTypeName,$callID,'接通',
    $beginTime,$endTime,$seconds,$callButlerID));
    
    
}
else
{
    //不存在
    $sqlInsert = "insert into ld_callbutler 
    (calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
     accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,description) 
    values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    ";
     
    $insertresult=$adb->pquery($sqlInsert,array($callTypeName,$callID,'接通',$beginTime,$endTime,$seconds,$pathName,$_SESSION['authenticated_user_id'],
    0,0,0,0,0,0,0,$callButlerRemarks));
}
    


crm_load_class_file('fieldValueUitype','include/fields/');

$html = "
<html>
<head>
    <title>".getFixedLabel('RecordfileInfo')."</title>
    <meta http-equiv='X-UA-Compatible' content='IE=edge' />
    <style type='text/css'>@import url('themes/softed/style.css');</style>
    <style type='text/css'>@import url('themes/softed/global.css');</style>
    <style type='text/css'>@import url('themes/softed/popup.css');</style>
</head>
<body style='margin:0 auto;width:100%;' class=small>

<div id='changeLayoutDiv' class='D_pop_box LdPopWidth800px' style='margin: 50px auto 0;'>
<div class='D_pop_tit'>
	<strong class='D_ptita'>".getFixedLabel('RecordfileInfo')."</strong>
</div>";
        $html .= "
        <div style='margin: 10px 0 10px 10px;'>
        ".getFixedLabel('Calltype')."：".$callTypeName."<br/>
        ".$callTypeName.getFixedLabel('Number')."：".fieldValueUitype::setReportMobileStyle($callID)."<br/>
        ".getFixedLabel('CallStartTime')."：".$beginTime."<br/>
        ".getFixedLabel('EndTime')."：".$endTime."<br/>
        ".getFixedLabel('TalkTime')."（".getFixedLabel('Second')."）：".$seconds."<br/>" //getFixedLabel('Recordfile')."：".$pathName."<br/>
        ."</div>";
    $html .= "
</div>
</body>";

print_r($html);
exit();

?>