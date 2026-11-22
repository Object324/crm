<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
$ruleid=$_REQUEST['ruleid'];

// $sql_allpr="SELECT `priority` from ld_loginpolicy";
// $pr_arr = $adb->pquery($sql_allpr);

// $num_rows = $adb->num_rows($pr_arr);
 
// for($i=0;$i<$num_rows;$i++)
// {
//     $allpriority = $adb->query_result($pr_arr,$i,'priority');
//     if($allpriority>$tmppriority){
//     }
// }   
//更新优先级
$sql_pr="SELECT `priority` from ld_loginpolicy where ruleid=?";
$triggerresult = $adb->pquery($sql_pr,array($ruleid));
$tmppriority = $adb->query_result($triggerresult,0,'priority');
$sql_newpr="UPDATE ld_loginpolicy set `priority`=`priority`-1 where `priority`>? ";
$adb->pquery($sql_newpr,array($tmppriority));

//执行两个表的删除
$sql="DELETE from ld_loginpolicy where ruleid=?";
$adb->pquery($sql,array($ruleid));
$sql="DELETE from ld_loginpolicy_user where ruleid=?";
$adb->pquery($sql,array($ruleid));
$arr['msg'] = getFixedLabel('SuccessDeleted');
$_REQUEST['diony']='diony';
ConvertTojsonString(1,$arr,"success");

?>