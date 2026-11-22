<?php


global   $theme, $currentModule, $current_user;

$focus = CRMEntity::getInstance($currentModule);
$fieldObj=$focus->fieldobj;
$smarty = new lingdangCRM_Smarty;

$token=$focus->getAccessToken();
//$token = 'AOavrmtQ-Qx0azzXfJF8BKb1b4u5wzQ51JpzRTgTubhgonbZoPeDclby98m7bfkeULgA5rRjYlGKHSTrt0UuQtwmwB5rjii0oM2SvV6ZM2ZOXsspQCh_MxBauDollPiWafE8mbQlsJIlvy891lxypVMBFiPURub9rYbtitqGkg8WmsKF4OM2e1njzgOnk75cNKPdm8ovOy_d0fHicNUYqA';
$url = 'https://qyapi.weixin.qq.com/cgi-bin/externalcontact/get_corp_tag_list?access_token='.$token;
$result=$focus->wx_get($url);
if($result['errcode'] == 0){
	foreach($result['tag_group'] as $key => $channellabel){
		$channellabel_array[$key]['group_id'] = $channellabel['group_id'];
		$channellabel_array[$key]['group_name'] = $channellabel['group_name'];
	}
}

//企业微信标签
$smarty->assign('CHANNELLABEL_ARRAY',$channellabel_array);
$_REQUEST['diony']='diony';
$arr['title'] = '新增标签';
$arr['oktext']= getFixedLabel("CONFIRMED");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("ChannelLabel_add.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
?>