<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global   $theme, $currentModule, $current_user;

$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty;
if(!empty($_REQUEST['record'])){
	$query = "select channel_name,channel_userid,scan_times,channelverify,words,card_title,card_description,card_href,app_title,app_id,app_src,ld_channelcode.createdtime,ld_users.last_name as creator_name,qr_code,contact_way_type  from ld_channelcode 
	left join ld_users on ld_users.id = ld_channelcode.smcreatorid where ld_channelcode.id = ? and ld_channelcode.deleted = 0 limit 1";
	$result = $adb->pquery($query,array($_REQUEST['record']));
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		$channel_userid = $adb->query_result($result,0,'channel_userid');
		$words = $adb->query_result($result,0,'words');
		$card_title = $adb->query_result($result,0,'card_title');
		$app_title = $adb->query_result($result,0,'app_title');
		$contact_way_type = $adb->query_result($result,0,'contact_way_type');
		if(!empty($words)){
			$channel_type[] = getFixedLabel('Text1');
		}
		if($contact_way_type == 'img'){
			$channel_type[] =getFixedLabel('PICTURE');
		}else if($contact_way_type == 'card'){
			$channel_type[] =getFixedLabel('Card');
		}else if($contact_way_type == 'app'){
			$channel_type[] =getFixedLabel('App');
		}
		$data = array(
			'channel_name' => $adb->query_result($result,0,'channel_name'),
			'channel_userid' => $channel_userid,
			'channel_username' => $focus->getUserName($channel_userid),
			'creator_name' => $adb->query_result($result,0,'creator_name'),
			'createdtime' => $adb->query_result($result,0,'createdtime'),
			'words' => $words,
			'card_title' => $card_title,
			'card_description' => $adb->query_result($result,0,'card_description'),
			'card_href' => $adb->query_result($result,0,'card_href'),
			'app_title' => $app_title,
			'app_id' => $adb->query_result($result,0,'app_id'),
			'app_src' => $adb->query_result($result,0,'app_src'),
			'channeltype' => implode('、',$channel_type),
			'qr_code' => $adb->query_result($result,0,'qr_code'),
		);
		//企业微信标签
		$channellabel = $focus->getChannelLabel($_REQUEST['record']);
		if(!empty($channellabel)){
			$data['channel_label'] = $channellabel['label'];
			$data['channel_label_string'] = $channellabel['label_string'];
		}
	}
	//东贸 - 渠道码增加大巴车司机选项（选择客户字段）
	$version_info = getVersionInfo();
	if($version_info['account'] == 'dongmao' && !empty($_REQUEST['record'])){
		$query = 'select accountid,accountname from ld_channelcode 
		LEFT JOIN ld_account on ld_account.accountid = ld_channelcode.servicecharge_id 
		where id = ? and ld_account.deleted = 0 limit 1';
		$result = $adb->pquery($query,array($_REQUEST['record']));
		$servicecharge_id = $adb->query_result($result,0,'accountid');
		$smarty->assign('SERVICECHAR_ID',$servicecharge_id);
		$smarty->assign('SERVICECHAR_NAME',$adb->query_result($result,0,'accountname'));
		// 商贸批发小程序
		if($version_info['trade'] == 'yongdingcheng'){
			$appid = 'wx2183763e288de430';
			$secret = 'c6295fc9ef68414b6379077be197d69b';
		}
		else if($version_info['trade'] == 'dongmao'){
			$appid = 'wxe00da0486b067af5';
			$secret = '49d4670f5c7e572c29504997169337f6';
		}
		else{
			$appid = 'wxc5453f07146e9ac9';
			$secret = '7abac821de6065b2ebe9689acfc6c712';
		}
		$uploadDir = globalStatic::$root_directory.'/storage/weixinqrcode/';
		$filename ='channel_sign_'.$_REQUEST['record'].'.jpg';
		if (!file_exists($uploadDir.$filename)) { 
			$token_url = 'https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid='.$appid.'&secret='.$secret;
			//访问数据接口
			$ch = curl_init();
			curl_setopt($ch, CURLOPT_URL, $token_url);
			curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE); 
			curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE); 
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
			$output = curl_exec($ch);
			curl_close($ch);
			$jsoninfo = json_decode($output, true);
			$access_token = $jsoninfo["access_token"];
			if(!empty($access_token)){
				require_once globalStatic::$root_directory.'appCommon/appCommon.php';
				$qrcode_url = 'https://api.weixin.qq.com/wxa/getwxacodeunlimit?access_token='.$access_token;
				$param['scene'] = 'channelcodeid='.$_REQUEST['record'];
				$param['page'] = 'pages/sign/sign';
				$qrcode_result = CurlPost($qrcode_url,$param)['content'];
				if(!file_exists($uploadDir)){
					mkdir($uploadDir,0777);
				}
				file_put_contents($uploadDir.$filename,$qrcode_result);
			}
		}
		$imgsrc = 'storage/weixinqrcode/'.$filename;
		$smarty->assign('sign_url',$imgsrc.'?a='.rand(0,9999));

		$query = 'select customform100id,car_no from ld_channelcode 
		LEFT JOIN ld_customform100 on ld_customform100.customform100id = ld_channelcode.customform100_id 
		where id = ? and ld_customform100.deleted = 0 limit 1';
		$result = $adb->pquery($query,array($_REQUEST['record']));
		$smarty->assign('CUSTOMFORM100_ID',$adb->query_result($result,0,'customform100id'));
		$smarty->assign('CUSTOMFORM100_NAME',$adb->query_result($result,0,'car_no'));
	}
}
//扫码客户历史记录
$smarty->assign('HISTORYCOUNT',$focus->getChannelCodeHistoryCount($_REQUEST['record']));
$smarty->assign('RECORD',$_REQUEST['record']);
$smarty->assign('DATA',$data);
$smarty->assign('AJAX',$_REQUEST['ajax']);
$version_info = getVersionInfo();
$smarty->assign('VERSION_ACCOUNT',$version_info['account']);
$_REQUEST['diony']='diony';
//zxm 20221130 渠道表title样式修改
$arr['title'] = '<span class="ld-fieldbg-common" style="background-color:#ff6600;">'.getFixedLabel('channelname') .'</span>&nbsp;&nbsp;' . strip_tags($data['channel_name']).'</span>';
$arr['oktext']= '';
$arr['canceltext']='';
//按钮
$detailButtons['channelcode_edit']['label'] = getFixedLabel('EDIT');
$detailButtons['channelcode_edit']['permit'] = 'yes';
$detailButtons['channelcode_edit']['icon'] = 'icon-more';

$detailButtons['channelcode_delete']['label'] = getFixedLabel('DELETE');
$detailButtons['channelcode_delete']['permit'] = 'yes';
$detailButtons['channelcode_delete']['icon'] = 'icon-more';
$arr['detailButtons']=$detailButtons;
$str=$smarty->fetch("ChannelCode_Detail.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
?>