<?php
//zkt 20231013 XUQIU1001341 SQL注入
// $cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
// $cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule, $current_user;
//渠道码 保存
if(!empty($_REQUEST['savaajax']) && $_REQUEST['savaajax'] == 'yes'){
	$focus = CRMEntity::getInstance($currentModule);
	if(!empty($_REQUEST['channelname']) && $_REQUEST['userid']){
		$channelname = vtlib_purify($_REQUEST['channelname']);	//渠道名称
		$channeluserid = vtlib_purify($_REQUEST['userid']);	//企业微信员工
		$channelverify = 'no';	//客户添加时无需经过确认自动成为好友
		if(!empty($_REQUEST['channelverify'])){
			$channelverify  = $_REQUEST['channelverify'];
		}
		$channellabel_id = vtlib_purify($_REQUEST['channellabel_id']);	//企业微信标签
		$words = vtlib_purify($_REQUEST['words_content']);	//文字
		$card_title = vtlib_purify($_REQUEST['card_title']);	//链接卡片标题
		$card_description = vtlib_purify($_REQUEST['card_description']);	//链接卡片描述
		$card_href = vtlib_purify($_REQUEST['card_href']);	//卡片链接
		$app_title = vtlib_purify($_REQUEST['app_title']);	//小程序标题
		$app_id = vtlib_purify($_REQUEST['app_id']);	//小程序AppID
		$app_src = vtlib_purify($_REQUEST['app_src']);	//小程序 Page 路径
		$file_name = '';
		if($_REQUEST['contact_way_other'] == 'card'){
			$app_title = '';$app_id = '';$app_src = '';
			$file_name = 'cardFile';
		}
		if($_REQUEST['contact_way_other'] == 'app'){
			$card_title = '';$card_description = '';$card_href = '';
			$file_name = 'appFile';
		}
		if($_REQUEST['contact_way_other'] == 'img'){
			$app_title = '';$app_id = '';$app_src = '';$card_title = '';$card_description = '';$card_href = '';
			$file_name = 'imgFile';
		}
		if(empty($_REQUEST['contact_way'])){
			$words = '';
			$file_name = '';
			$_REQUEST['contact_way_other'] = '';
		}
		if(!empty($_REQUEST['channelcode_id'])){
			$query = "update ld_channelcode set channel_name = ?,channel_userid = ?,channelverify = ?,words = ?,card_title = ?,card_description = ?,card_href = ?,app_title = ?,app_id = ?,app_src = ?,contact_way_type = ? where id = ?";
			$adb->pquery($query,array($channelname,$channeluserid,$channelverify,$words,$card_title,$card_description,$card_href,$app_title,$app_id,$app_src,$_REQUEST['contact_way_other'],$_REQUEST['channelcode_id']));
			//清除企业标签
			$delete = "delete from ld_channellabel where channelcode_id = ?";
			$adb->pquery($delete,array($_REQUEST['channelcode_id']));
			$channelcode_id = $_REQUEST['channelcode_id'];
		}else{
			$query = "insert into ld_channelcode(channel_name,channel_userid,channelverify,words,card_title,card_description,card_href,app_title,app_id,app_src,smcreatorid,smownerid,createdtime,contact_way_type) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
			$adb->pquery($query,array($channelname,$channeluserid,$channelverify,$words,$card_title,$card_description,$card_href,$app_title,$app_id,$app_src,$current_user->id,$current_user->id,date('Y-m-d H:i:s'),$_REQUEST['contact_way_other']));
			$channelcode_id = $adb->getLastInsertID();
		}
		//东贸 - 渠道码增加大巴车司机选项（选择客户字段）
		$version_info = getVersionInfo();
		if($version_info['account'] == 'dongmao' && !empty($_REQUEST['servicecharge_id'])){
			$query = 'update ld_channelcode set servicecharge_id = ? where id = ?';
			$adb->pquery($query,array($_REQUEST['servicecharge_id'],$channelcode_id));
		}else{
			$query = 'update ld_channelcode set servicecharge_id = ? where id = ?';
			$adb->pquery($query,array(0,$channelcode_id));
		}
		if($version_info['account'] == 'dongmao' && !empty($_REQUEST['customform100_id'])){
			$query = 'update ld_channelcode set customform100_id = ? where id = ?';
			$adb->pquery($query,array($_REQUEST['customform100_id'],$channelcode_id));
		}else{
		//	$query = 'update ld_channelcode set customform100_id = ? where id = ?';
		//	$adb->pquery($query,array(0,$channelcode_id));
		}
		//图片
		if(!empty($file_name)){
			$focus->saveImage($file_name,$channelcode_id);
		}
		//签名
		if(!empty($_REQUEST['channellabel_id'])){
			$channellabel_str = explode('|::##::|',$_REQUEST['channellabel_id']);
			foreach($channellabel_str as $channellabels){
				$labels = explode('|::|',$channellabels);
				$query = 'insert into ld_channellabel(channelcode_id,label,label_string) values (?,?,?)';
				$adb->pquery($query,array($channelcode_id,$labels[2],$channellabels));
			}

		}
		//生成渠道码
		$focus->addContactWay($channelcode_id);
	}
}
$_REQUEST['diony']='diony';
ConvertTojsonString(1,array('channelcode_id'=>$channelcode_id,'channelname'=>$channelname),"success");
?>