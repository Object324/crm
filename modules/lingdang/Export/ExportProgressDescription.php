<?php
global $detailcounts;
global $currentModule,$current_user;

$starttime=$_SESSION[$currentModule][$current_user->id]['export']['starttime'];

$enddtime=date("Y-m-d H:i:s");
$between_seconds=DateOperation::sencods_between_time($enddtime,$starttime);

if(empty($between_seconds))
{
    $between_seconds=1;
}

  //BUG0076790 ls 20231207 批量勾选单据>更多>下载全部附件>弹出的下载进度条的剩余时间显示为0
$detailcounts = $listcounts;

if(!empty($prev_totalrows)){
    $prev_totalrows = floatval($prev_totalrows);
    $Average_time = $between_seconds/$prev_totalrows;
}else{
    $Average_time = 0;
}

$balance_import_rows=$detailcounts-$prev_totalrows;

if($balance_import_rows<=0)
{
    $balance_import_rows=0;
}
if($detailcounts>1000&&$detailcounts<=2000)
 $balance_time=intval($Average_time*$balance_import_rows*1.5);
else if($detailcounts>2000&&$detailcounts<=5000)
    $balance_time=intval($Average_time*$balance_import_rows*2.5);
else if($detailcounts>5000)
    $balance_time=intval($Average_time*$balance_import_rows*4);
else
    $balance_time=intval($Average_time*$balance_import_rows);
if($balance_import_rows>0&&$balance_time<=0)
{
    $balance_time=1;
}
$totalseconds=intval($detailcounts*$Average_time);

//系统导出日志
if($_REQUEST['getprogress']=='yes'){
    crm_load_class_file('cls_OperationLogs','modules/Settings/cls_OperationLogs');
    $cls_operationLogs = cls_OperationLogs::getInstance($_REQUEST['module'],'Export');
    $logid = $cls_operationLogs->saveExportStartLogs($listcounts,$_REQUEST['export_style']);//完成导出的第一步保存，并记住返回的日志id
    $_SESSION[$currentModule][$current_user->id]['exportlog']['logid'] = $logid;
    $_SESSION[$currentModule][$current_user->id]['exportlog']['pathname'] = $pathname;
}

$time_description="共有".$listcounts.'行数据导出，';
$balance_time = $balance_time + $balance_import_rows;//每次网络请求也需要时间，$balance_time计算就不太准
 if($balance_time<60)
 {
    $time_description.="预计剩余时间<span style='color:#ff7d1d'>".$balance_time."秒</span>";
 }
 else if($balance_time>=3600)
 {
   
    $hours=intval($balance_time/3600);
    $time_description.="预计剩余时间<span style='color:#ff7d1d'>".$hours;
    $minutes=intval(($balance_time-intval($balance_time/3600)*3600)/60);
    if($minutes>0){
        $time_description.="小时".$minutes."分钟";
        $seconds=$balance_time-(60*$minutes+$hours*3600);
        if($seconds>0)
        {
            $time_description.=$seconds.'秒</span>';
        }
        else
        {
            $time_description.='</span>';
        }
    }
    else
    {
        $time_description.=$minutes."小时</span>";
    }
   
 }
 else
 {
     $minutes=intval($balance_time/60);
     $time_description.="预计剩余时间<span style='color:#ff7d1d'>".$minutes;
     $seconds=$balance_time-intval($balance_time/60)*60;
     if(!empty($seconds)){
        $time_description.="分钟".$seconds.'秒</span>';
        //
     }
     else
     {
        $time_description.="分钟</span>";
     }
     
 }

?>