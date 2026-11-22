<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

global $current_user,$adb;
$createdtime=date('Y-m-d H:i:s');

if(isset($_REQUEST['ReportLogId'])&&$_REQUEST['ReportLogId']!=''){
    $ReportLogId=$_REQUEST['ReportLogId'];
}
if(isset($_REQUEST['ReportLogType'])&&$_REQUEST['ReportLogType']!=''){
    $ReportLogType=$_REQUEST['ReportLogType'];
}
$str='';

if(isset($_REQUEST['ModComments'])&&$_REQUEST['ModComments']!=''){
    $modcomments=$_REQUEST['ModComments'];
    $reportcommentid=$adb->getUniqueID('ld_reportcomments');
    $query="insert into ld_reportcomments(reportcommentid,commentcontent,commentdate,commentatorid,reportid,type)";
    $query .=" values(?,?,?,?,?,?)";
  
    $result=$adb->pquery($query,array($reportcommentid,$modcomments,$createdtime,$current_user->id,$ReportLogId,$ReportLogType));

    $num_rows=$adb->num_rows($result);
      
   
}

if(isset($_REQUEST['Scope'])&&$_REQUEST['Scope']){
    $scope=$_REQUEST['Scope'];
    $sqlLast='';
    $sqlMine='';
    if($scope=='All'){
        
    }elseif($scope=='Last5'){
        $sqlLast=' limit 5';
    }
    else{
        $sqlMine=' and T1.commentatorid='.$current_user->id;
    }
}
$query="select T1.commentcontent,T1.commentdate,T2.last_name as lastname from ld_reportcomments as T1 left join ld_users 
        as T2 on T1.commentatorid=T2.id
         where T1.reportid=? and T1.type=?".$sqlMine." order by T1.commentdate desc".$sqlLast;
        $result=$adb->pquery($query,array($ReportLogId,$ReportLogType));
        $num_rows=$adb->num_rows($result);
        if($num_rows){
            for($i=0;$i<$num_rows;$i++){
                $commentcontent=$adb->query_result($result,$i,'commentcontent');
                $commentdate=$adb->query_result($result,$i,'commentdate');
                $lastname=$adb->query_result($result,$i,'lastname');
                $str .="<div class='dataField' valign='top' style='width: 95%; padding-top: 5px;'>$commentcontent</div>";
                $str .="<div class='dataLabel' valign='top' style='border-bottom: 1px dotted rgb(204, 204, 204); width: 95%; padding-bottom: 5px;'>";
                $str .="<font color='darkred'>作者：{$lastname} 添加于{$commentdate}</font>";
                $str .="</div>";
            }
            }
echo "#####".$str;
exit();
?>