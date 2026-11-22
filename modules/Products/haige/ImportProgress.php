<?php
global $currentModule;
global $current_user;
global $cur_progress_step;
global $time_description;
$languageType= getLanguageType($current_user);

//获取进度条数据
 $endimporttime=date("Y-m-d H:i:s");
 $startimporttime=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_startdate'];

 $maxrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_maxrows'];//数组长度+1；
 //$endrow=$_REQUEST['endrow'];
 if(empty($endrow))
 {
    $endrow=1;
 }
 $startrow=$_REQUEST['startrow'];
 $between_rows=$endrow-$startrow;
 if(empty($between_rows))
 {
    $between_rows=1;
 }
 
 $between_seconds=DateOperation::sencods_between_time($endimporttime,$startimporttime);

  if(empty($between_seconds))
  {
    $between_seconds=1;
  }      
 
             
 $Average_time=$between_seconds/$endrow;


 $balance_import_rows=$maxrows-$endrow;

 if($balance_import_rows<=0)
 {
    $balance_import_rows=0;
 }

 $balance_time=intval($Average_time*$balance_import_rows);
 if($balance_import_rows>0&&$balance_time<=0)
 {
    $balance_time=1;
 }
 $totalseconds=intval($maxrows*$Average_time);
 

$hours=intval($balance_time/3600);
$minutes=intval(($balance_time-intval($balance_time/3600)*3600)/60);
$seconds=$balance_time-(60*$minutes+$hours*3600);

if($languageType=='zh')
{
    $time_description="共有 ".$maxrows." 行数据导入，预计剩余时间 <span class='num'>".$hours.":".$minutes.":".$seconds."</span>";
}
else if($languageType=='en')
{
    $time_description=$maxrows." lines to import, the estimated remaining time is about <span class='num'>".$hours.":".$minutes.":".$seconds."</span>";
}


/*
 $time_description="共有".$maxrows.'行数据导入，';
 if($balance_time<60)
 {
    $time_description.="预计剩余时间<span class='num'>".$balance_time."秒</span>";
 }
 else if($balance_time>=3600)
 {
    $hours=intval($balance_time/3600);
    $time_description.="预计剩余时间<span class='num'>".$hours;
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
     $time_description.="预计剩余时间<span class='num'>".$minutes;
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
 */

 $cur_progress_step=intval($endrow/$maxrows*100);
 if($cur_progress_step>=100)
 {
    $cur_progress_step=100;
 }

if(empty($cur_progress_step)){
	$cur_progress_step = 0;
}
 
?>