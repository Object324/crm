<?php 
include('includefile.php');

crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = new cls_Send_MassSms();
$SMSarray = GetSMSAutograph();
$account_name = $SMSarray['account_name'];
if(!empty($account_name)){
	if($_REQUEST['php_os'] == 'winnt'){
		$count=get_information_in_smssend_by_first();
		if($count > 0){
            $result_smssend = get_information_in_smssend_by_second_winnt();
			foreach($result_smssend as $value){
				//接受人
				$ReceiveContacts=$value['ReceiveContacts'];
				$CalledNumber = $value['CalledNumber'];
				//短信内容
				$SmsContent=$value['SmsContent'];
				if(!empty($ReceiveContacts)){
					$CalledNumber = $CalledNumber . '<'.$ReceiveContacts.'>';
				}
				$BatchNo = $value['BatchNo'];
				$cls_Send_MassSms->updateSend($CalledNumber,$SmsContent,$BatchNo);
			}
		}else{
			 echo '<br>没有需要操作的短信！<br>';
		}
	}else{
		//linux服务器上的自动发送短信的功能
		$count=get_information_in_smssend_by_first();
		if($count > 0){
            $result_smssend = get_information_in_smssend_by_second();
			foreach($result_smssend as $value){
				//接受人
				$ReceiveContacts=$value['ReceiveContacts'];
				$CalledNumber = $value['CalledNumber'];
				//短信内容
				$SmsContent=$value['SmsContent'];
				if(!empty($ReceiveContacts)){
					$CalledNumber = $CalledNumber . '<'.$ReceiveContacts.'>';
				}
				$BatchNo = $value['BatchNo'];
				$cls_Send_MassSms->updateSend($CalledNumber,$SmsContent,$BatchNo);
			}
		}
		exit();
	}
}else{
	if($_REQUEST['php_os'] == 'winnt'){
		 echo '<br>请设置通讯账户！<br>';
	}
}

//判断是否有需要发送的短信信息
function get_information_in_smssend_by_first()
{        
    global $adb;
    $sql="select count(1) as count from ld_smssend where FDataStatu='0' 
    and UNIX_TIMESTAMP(date_add(now(), interval 3 minute))>UNIX_TIMESTAMP(SubmitTime)";
    $result = $adb->query($sql);
    $count = $adb->query_result($result, 0, 'count');
    return $count;
}    

//读取需要发送的短信信息
function get_information_in_smssend_by_second()
{
    global $adb;
    $sql="select * from ld_smssend where FDataStatu != '2' 
    and UNIX_TIMESTAMP(date_add(now(), interval 3 minute))>UNIX_TIMESTAMP(SubmitTime) limit 200 ";
    /*$sql="select * from ld_smssend where FDataStatu=0 and Priority =0 UNION all 
          select * from ld_smssend where FDataStatu=0 and Priority =1 
          and submittime <=  addtime(sysdate(),'00:03:00') ";*/
    
    $result = $adb->query($sql);

	$num_rows = $adb->num_rows($result);
	$arr = [];
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$arr[] = array(
				"ReceiveContacts"=>$adb->query_result($result,$i,'receivecontacts'),
				"CalledNumber"=>$adb->query_result($result,$i,'callednumber'),
				"SmsContent"=>$adb->query_result($result,$i,'smscontent'),
				"BatchNo"=>$adb->query_result($result,$i,'batchno'),
			);
		}
	}

	return $arr;
}
 //读取需要发送的短信信息
function get_information_in_smssend_by_second_winnt()
{
	global $adb;
	$sql="select * from ld_smssend where FDataStatu != '2' limit 200 ";
	$result = $adb->query($sql);

	$num_rows = $adb->num_rows($result);
	$arr = [];
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$arr[] = array(
				"ReceiveContacts"=>$adb->query_result($result,$i,'receivecontacts'),
				"CalledNumber"=>$adb->query_result($result,$i,'callednumber'),
				"SmsContent"=>$adb->query_result($result,$i,'smscontent'),
				"BatchNo"=>$adb->query_result($result,$i,'batchno'),
			);
		}
	}

	return $arr;
}

?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>通讯服务</title>
        <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />   
        <script language="JavaScript">
            function myrefresh(){
                window.location.reload();
            }
            setTimeout('myrefresh()',60000); 
        </script>      
    </head>
<body>
    <br/>
    <div style="color: red;">该页面为通讯服务，请不要关闭，否则会导致系统无法正常使用！</div>
</body>
</html>