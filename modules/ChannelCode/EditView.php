<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();


global   $theme, $currentModule, $current_user;

$focus = CRMEntity::getInstance($currentModule);
$fieldObj=$focus->fieldobj;
$smarty = new lingdangCRM_Smarty;
 require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
$wx_authinfo=doCorpInfo("get_auth_info",array());
if(empty($wx_authinfo)){
	$_REQUEST['diony']='diony';
	ConvertTojsonString(-1,$arr,"success");
}
if(!empty($_REQUEST['record']) && $_REQUEST['mode'] == 'edit'){
	$query = "select channel_name,channel_userid,scan_times,channelverify,words,card_title,card_description,card_href,app_title,app_id,app_src,deleted,createdtime,file_path,file_name,contact_way_type from ld_channelcode where id = ? and deleted = 0 limit 1";
	$result = $adb->pquery($query,array($_REQUEST['record']));
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		$channel_userid = $adb->query_result($result,0,'channel_userid');
		$words = $adb->query_result($result,0,'words');
		$card_title = $adb->query_result($result,0,'card_title');
		$app_title = $adb->query_result($result,0,'app_title');
		$data = array(
			'channel_name' => $adb->query_result($result,0,'channel_name'),
			'channel_userid' => $channel_userid,
			'channel_username' => $focus->getUserName($channel_userid),
			'channelverify' => $adb->query_result($result,0,'channelverify'),
			'words' => $words,
			'card_title' => $card_title,
			'card_description' => $adb->query_result($result,0,'card_description'),
			'card_href' => $adb->query_result($result,0,'card_href'),
			'app_title' => $app_title,
			'app_id' => $adb->query_result($result,0,'app_id'),
			'app_src' => $adb->query_result($result,0,'app_src'),
			'file_path' => $adb->query_result($result,0,'file_path'),
			'file_name' => $adb->query_result($result,0,'file_name'),
			'contact_way_type' => $adb->query_result($result,0,'contact_way_type'),
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
		$smarty->assign('SERVICECHAR_ID',$adb->query_result($result,0,'accountid'));
		$smarty->assign('SERVICECHAR_NAME',$adb->query_result($result,0,'accountname'));

		$query = 'select customform100id,car_no from ld_channelcode 
		LEFT JOIN ld_customform100 on ld_customform100.customform100id = ld_channelcode.customform100_id 
		where id = ? and ld_customform100.deleted = 0 limit 1';
		$result = $adb->pquery($query,array($_REQUEST['record']));
		$smarty->assign('CUSTOMFORM100_ID',$adb->query_result($result,0,'customform100id'));
		$smarty->assign('CUSTOMFORM100_NAME',$adb->query_result($result,0,'car_no'));
	}
}
$smarty->assign('RELATED',$_REQUEST['related']);
$smarty->assign('RECORD',$_REQUEST['record']);
$smarty->assign('DATA',$data);
$version_info = getVersionInfo();
$smarty->assign('VERSION_ACCOUNT',$version_info['account']);
$_REQUEST['diony']='diony';
$fields=$focus->fieldobj->getFieldListArray();
$arr['fields']=$fields['fields'];
$arr['title'] = getFixedLabel('NEW').getFixedLabel('channelcode');
$arr['oktext']= getFixedLabel('Generate').getFixedLabel('channelcode');
$arr['canceltext']=getFixedLabel("CANCEL");
//zxm 2020-1104 示例悬浮 0043103: (https://61mis.com/kfbcrm [^])渠道码新建、编辑界面，文字、小程序、链接卡片的文字欢迎示例、小程序示例和链接卡片欢迎示例还没有加上。预期效果是，鼠标经过这些字段时，会有图片悬浮。
$smarty->assign('imgExampleArr',[
    'text'=>'data:image/png;base64,'.base64_encode(file_get_contents(globalStatic::$root_directory."themes/images/wx/text.png")),
    'card'=>'data:image/png;base64,'.base64_encode(file_get_contents(globalStatic::$root_directory."themes/images/wx/card.png")),
    'miniprogram'=>'data:image/png;base64,'.base64_encode(file_get_contents(globalStatic::$root_directory."themes/images/wx/miniprogram.png"))
]);
$str=$smarty->fetch("ChannelCode_Edit.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");

?>