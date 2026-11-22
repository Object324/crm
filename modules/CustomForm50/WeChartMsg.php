<?php
global $adb,$currentModule,$current_user;
$_REQUEST['diony']='diony';
$query = "select customform10id from ld_customform10 where form10_type = '下游客户' and deleted = 0";
$result = $adb->pquery($query,array());
$customform10id = $adb->query_result($result,0,0);
crm_load_class_file("AccountSetCustomView",'WeiXinApp/dongmao/AccountScope');
crm_load_class_file("AccountSetProductDetails",'WeiXinApp/dongmao/AccountScope');
crm_load_class_file("CurrentUser",'WeiXinApp/dongmao/AccountScope');
$AccountSetCustomView=new AccountSetCustomView($_REQUEST['record']);
$AccountSetProductDetails=new AccountSetProductDetails($_REQUEST['record']);
crm_load_class_file("AccountsQueryGenerator",'include/QueryGenerator');
crm_load_class_file("AccountsSetQueryGenerator",'modules/Accounts/AccountSet');
$queryGenerator =new AccountsSetQueryGenerator('Accounts', $current_user,$AccountSetCustomView,$AccountSetProductDetails);
$queryGenerator->initForDefaultCustomView();
$query= $queryGenerator->getQuery();
$query .= ' and ld_account.customform10_id = '.$customform10id;
$result = $adb->pquery($query,array());
$num_rows = $adb->num_rows($result);
if($_REQUEST['getNum'] == 'yes'){
	ConvertTojsonString(1,array('num_rows'=>$num_rows),"success");
}else{
	require_once (globalStatic::$root_directory.'include/weixinMsg/cls_DongmaoMessage.php');
	require_once (globalStatic::$root_directory.'include/weixinMsg/cls_DMmessageDefault.php');
	$dongmaoObj = new cls_DongmaoMessage();
	$startrow = $_REQUEST['startrow'];
	$endrow = $_REQUEST['endrow'];
	$query .= ' limit ' . $startrow . ',4';
	$result = $adb->pquery($query,array());
	$cnt_rows = $adb->num_rows($result);
	if($cnt_rows >= 1){
		$cus_query = 'select cf_5167,cf_5168,cf_5169,cf_5181,cf_5182,cf_5170,cf_5176,cf_5183,cf_5184,cf_5171,cf_5177,cf_5185,cf_5186,cf_5187,cf_5188,cf_5172,cf_5178,cf_5189,cf_5190,cf_5191,cf_5192,cf_5173,cf_5179,cf_5193,cf_5194,cf_5174,cf_5180,cf_5195,cf_5196,cf_5175,cf_5198,cf_5240,cf_5241,cf_5244,cf_5243,cf_5242 from ld_customform50 
		LEFT JOIN ld_customform50scf on ld_customform50.customform50id = ld_customform50scf.customform50id
		where ld_customform50.customform50id = ?';
		$cus_result = $adb->pquery($cus_query,array($_REQUEST['record']));
		$cf_5167 = $adb->query_result($cus_result,0,'cf_5167');
		//活动信息
		//商户入驻
		//商户上新
		//爆款推荐
		//直播预告
		//商城通告
		if($cf_5167 == '活动信息'){
			$dmMsgData = cls_DMmessageDefault::$DMmessageData['SignUp'];
            $dmMsgPage = cls_DMmessageDefault::$DMmessageJump['SignUp'];
			$data = array(
				'title' => $adb->query_result($cus_result,0,'cf_5168'),	
				'activityname' => $adb->query_result($cus_result,0,'cf_5169'),
				'time' => $adb->query_result($cus_result,0,'cf_5181'),
				'name' => $adb->query_result($cus_result,0,'cf_5182'),
				'remark' => $adb->query_result($cus_result,0,'cf_5170'),
			);
			$dongmaoObj_action = 'SignUp';
		}else if($cf_5167 == '商户入驻'){
			$dmMsgData = cls_DMmessageDefault::$DMmessageData['Settled'];
            $dmMsgPage = cls_DMmessageDefault::$DMmessageJump['Settled'];
			$data = array(
				'title' => $adb->query_result($cus_result,0,'cf_5176'),	
				'shopname' => $adb->query_result($cus_result,0,'cf_5183'),
				'time' => $adb->query_result($cus_result,0,'cf_5184'),
				'remark' => $adb->query_result($cus_result,0,'cf_5171'),
			);
			$dongmaoObj_action = 'Settled';
		}else if($cf_5167 == '商户上新'){
			$dmMsgData = cls_DMmessageDefault::$DMmessageData['Warehousing'];
            $dmMsgPage = cls_DMmessageDefault::$DMmessageJump['Warehousing'];
			$data = array(
				'title' => $adb->query_result($cus_result,0,'cf_5177'),	
				'categoryname' => $adb->query_result($cus_result,0,'cf_5185'),
				'quantity' => $adb->query_result($cus_result,0,'cf_5186'),
				'username' => $adb->query_result($cus_result,0,'cf_5187'),
				'shopname' => $adb->query_result($cus_result,0,'cf_5188'),
				'remark' => $adb->query_result($cus_result,0,'cf_5172'),
			);
			$dongmaoObj_action = 'Warehousing';
		}else if($cf_5167 == '爆款推荐'){
			$dmMsgData = cls_DMmessageDefault::$DMmessageData['Recommend'];
            $dmMsgPage = cls_DMmessageDefault::$DMmessageJump['Recommend'];

            $data = array(
				'title' => $adb->query_result($cus_result,0,'cf_5178'),	
				'categoryname' => $adb->query_result($cus_result,0,'cf_5189'),
				'quantity' => $adb->query_result($cus_result,0,'cf_5190'),
				'username' => $adb->query_result($cus_result,0,'cf_5191'),
				'shopname' => $adb->query_result($cus_result,0,'cf_5192'),
				'remark' => $adb->query_result($cus_result,0,'cf_5173'),
			);
			$dongmaoObj_action = 'Recommend';
		}else if($cf_5167 == '直播预告'){
			$dmMsgData = cls_DMmessageDefault::$DMmessageData['Broadcast'];
            $dmMsgPage = cls_DMmessageDefault::$DMmessageJump['Broadcast'];
			$data = array(
				'title' => $adb->query_result($cus_result,0,'cf_5179'),	
				'time' => $adb->query_result($cus_result,0,'cf_5193'),
				'shopname' => $adb->query_result($cus_result,0,'cf_5194'),
				'nickname' => '',
				'remark' => $adb->query_result($cus_result,0,'cf_5174'),
			);
			$dongmaoObj_action = 'Broadcast';
		}else if($cf_5167 == '客户商城通告'){
			$dmMsgData = cls_DMmessageDefault::$DMmessageData['Announcement'];
            $dmMsgPage = cls_DMmessageDefault::$DMmessageJump['Announcement'];
			$data = array(
				'title' => $adb->query_result($cus_result,0,'cf_5180'),	
				'activityname' => $adb->query_result($cus_result,0,'cf_5195'),
				'time' => $adb->query_result($cus_result,0,'cf_5196'),
				'name' => $adb->query_result($cus_result,0,'cf_5198'),
				'remark' => $adb->query_result($cus_result,0,'cf_5175'),
			);
			$dongmaoObj_action = 'Announcement';
		}else if($cf_5167 == '商户商城通告'){
			require_once (globalStatic::$root_directory.'include/weixinMsg/cls_DongmaoMerchantMessage.php');
			require_once (globalStatic::$root_directory.'include/weixinMsg/cls_DMmessageMerchantDefault.php');
			$dongmaoObj = new cls_DongmaoMerchantMessage();
			$dmMsgData = cls_DMmessageMerchantDefault::$DMmessageData['Announcement'];
			$dmMsgPage = cls_DMmessageMerchantDefault::$DMmessageJump['Announcement'];
			$data = array(
				'title' => $adb->query_result($cus_result,0,'cf_5240'),	
				'shopname' => $adb->query_result($cus_result,0,'cf_5241'),
				'content' => $adb->query_result($cus_result,0,'cf_5243'),
				'time' => $adb->query_result($cus_result,0,'cf_5244'),
				'remark' => $adb->query_result($cus_result,0,'cf_5242'),
			);
			$dongmaoObj_action = 'Announcement';
		}
		for($i = 0; $i < $cnt_rows; $i++){
			$accountid = $adb->query_result($result,$i,'accountid');
			$wxinfo = getAccountForWxinfo($accountid);
			if($cf_5167 == '直播预告' || $cf_5167 == '商户商城通告'){
				if(empty($wxinfo['lastname'])){
					$wxinfo['lastname'] = '微信昵称';
				}
				$data['nickname'] = $wxinfo['lastname'];
			}
			// 兰总:oslAm0mRG-6xUXoeBJ7Xx23Tw7HI;王总:oslAm0ptw4yIccjwf1Ba920DXQ8E;邱小光:oslAm0pdy-Da_vZxBvL9oY90IpYI
            // 兰总:177594;王总:178611;邱小光:121653
			// $wxinfo['open_id'] = 'oslAm0ptw4yIccjwf1Ba920DXQ8E';
			// $wxinfo['wechatuserid'] = 178611;
			$dongmaoObj->send($dongmaoObj_action,$wxinfo['open_id'],$dmMsgPage['page'],$data,$wxinfo['wechatuserid'],'CustomForm50',$_REQUEST['record'],$dmMsgPage['pageType'],$accountid);
		}
	}
	$res['maxrows'] = $num_rows;
	$res['selectrows'] = $num_rows;
	$res['progresstitle'] = '温馨提示';
	echo json_encode($res);exit();
}


function getAccountForWxinfo($accountid){
	global $adb;
	$query = "select unionid,wechatuserid from ld_wechatuser where accountid = ? and deleted = 0";
	$result = $adb->pquery($query,array($accountid));
	$unionid = $adb->query_result($result,0,0);
	$query = "select open_id,wechatuserid,lastname from ld_wechatuser where unionid = ? and deleted = 0 and userfromvalue = 'offiaccount_dmgjsc'";
	$result = $adb->pquery($query,array($unionid));
	$open_id = $adb->query_result($result,0,'open_id');
	$wechatuserid = $adb->query_result($result,0,'wechatuserid');
	$lastname = $adb->query_result($result,0,'lastname');
	return array('open_id' => $open_id,'wechatuserid'=>$wechatuserid,'lastname'=>$lastname);
}
?>