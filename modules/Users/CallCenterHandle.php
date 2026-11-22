<?php
/**
 * 详情页每次都获取当前系统的呼叫中心参数
 * @project PROT190 汉天呼叫中心接口
 * @author Tujt 2015-03-30
 */
global $adb,$current_user;
require './modules/Users/staticUsers.class.php';
$setype = $_REQUEST['setype'];
switch($setype){
    case 'gettype':
    	$value = staticUsers::getCallCenterType();
        @ob_clean();
		if($value == 1){
			$sys = getSys_deploy(76);//软拨号自动加拨前缀
			echo $value . '-' . $sys['deploy_value'];die;
    	}else{
			echo $value;die;
		}
		
  //       $query = 'select id,deploy_value,deploy_type,description from ld_systems_deploy 
		// 			where deploy_type = 55 limit 1;';
		// $result = $adb->pquery($query,array());
		// $rows = $adb->num_rows($result);
		// $callcentertype = array('电话录音盒'=>1,'三汇板卡'=>2,'天润接口'=>3,'汉天EC2'=>4);
		// if(1 == $rows){
		// 	$deploy_value = $adb->query_result($result,0,'deploy_value');
		// 	if(isset($callcentertype[$deploy_value])){
		// 		echo $callcentertype[$deploy_value];die;
		// 	}
		// }
        break;
    case 'call':
		// require './user_privileges/hantian.inc.php';
  //       $mobile = $_REQUEST['mobile'];
  //       if(strpos($mobile,'-') > -1){
  //       	$modulearr = explode('-', $mobile);
  //       	$mobile = $modulearr[0].$modulearr[1];
  //       }
		// $serverIp = $hantian['ec2_server_ip'];
		// $serverPort = $hantian['ec2_server_port'];
		// $url = 'http://'.$serverIp.':'.$serverPort.'/ec2/http/common/dial?';
		// if(!empty($current_user->column_fields['description'])){
		// 	$url .= 'username='.$current_user->column_fields['description'].'&destNum='.$mobile.'';
		// }
		// if(!empty($hantian['accessId'])){
		// 	$url .= '&accessId='.$hantian['accessId'].'&accessKey='.$hantian['accessKey'].'';
		// }
		// $output = file_get_contents($url);
		// if(!empty($output)){
		// 	echo $output;die;
		// }
    	$source = '';
    	if(isset($_REQUEST['source'])){
    		$source = $_REQUEST['source'];
    	}
    	$output = staticUsers::CallCenterCall($_REQUEST['mobile'],$source);
    	if(!empty($output)){
			echo $output;die;
		}
        break;
}
die;
?>