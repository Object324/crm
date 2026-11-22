<?php
/*+********************************************************************************
   *{*修改编码格式:统一编码：UTF-8*}
  * The contents of this file are subject to the lingdang CRM Public License Version 1.0
  * ("License"); You may not use this file except in compliance with the License
  * The Original Code is:  lingdang CRM Open Source
  * The Initial Developer of the Original Code is lingdang.
  * Portions created by lingdang are Copyright (C) lingdang.
  * All Rights Reserved.
  ********************************************************************************/

$type = $_REQUEST['type'];
$records = $_REQUEST['records'];
$list_query = "";


if($type == 'smslist')
{
    $list_query = "select * from ld_smssend  ";
    $list_query .= " where TaskID =  ".$records;
    
    $result =$adb->pquery($list_query);
    $batchno = $adb->query_result($result,0,'batchno');//作业号
    $receivecontacts = $adb->query_result($result,0,'receivecontacts');//接收姓名
    $callednumber = $adb->query_result($result,0,'callednumber');//接收电话
    $subject = $adb->query_result($result,0,'subject');//主题
    $smscontent = $adb->query_result($result,0,'smscontent');//内容
    
    $smarty->assign("batchno", $batchno);
    $smarty->assign("receivecontacts", $receivecontacts);
    $smarty->assign("callednumber", $callednumber);
    $smarty->assign("subject", $subject);
    $smarty->assign("smscontent", $smscontent);
}
else if ($type == 'smswork')
{
    $list_query = "select BatchNo,Subject, SmsContent from ld_smssend ";
    $list_query .= " where BatchNo = '".$records."'" ." limit 0,1" ;
    
    $result =$adb->pquery($list_query);
    $batchno = $adb->query_result($result,0,'batchno');//作业号
    $subject = $adb->query_result($result,0,'subject');//主题
    $smscontent = $adb->query_result($result,0,'smscontent');//内容
    
    $smarty->assign("batchno", $batchno);
    $smarty->assign("subject", $subject);
    $smarty->assign("smscontent", $smscontent);
    
    $list_querylist = "select BatchNo,Subject, SmsContent,CONCAT(ReceiveContacts,'：',CalledNumber) as receive ";
    $list_querylist .= " from ld_smssend   ";
    $list_querylist .= " where BatchNo = '".$records."'" ;
    
    $resultlist =$adb->pquery($list_querylist);
    $num_rows=$adb->num_rows($resultlist);
    $arr=array();
    if($num_rows){
        for($i=0;$i<$num_rows;$i++){
            $arr[]=array(
            'Receive'=> $adb->query_result($resultlist,$i,'receive') 
            );
        }
        $smarty->assign("resultworklist", $arr);
    }
}

$smarty->assign("type", $type);
/*短信清单*/


$smarty->display("modules/CommunicationLog/CommunicationDetail.tpl");

?>