<?php


global   $theme, $currentModule, $current_user;

$focus = CRMEntity::getInstance($currentModule);
$fieldObj=$focus->fieldobj;
$smarty = new lingdangCRM_Smarty;
//已选标签
$channellabel_id = $_REQUEST['channellabel_id'];
//所有企业微信标签
$token=$focus->getAccessToken();
//$token = 'AOavrmtQ-Qx0azzXfJF8BKb1b4u5wzQ51JpzRTgTubhgonbZoPeDclby98m7bfkeULgA5rRjYlGKHSTrt0UuQtwmwB5rjii0oM2SvV6ZM2ZOXsspQCh_MxBauDollPiWafE8mbQlsJIlvy891lxypVMBFiPURub9rYbtitqGkg8WmsKF4OM2e1njzgOnk75cNKPdm8ovOy_d0fHicNUYqA';
$url = 'https://qyapi.weixin.qq.com/cgi-bin/externalcontact/get_corp_tag_list?access_token='.$token;
$result=$focus->wx_get($url);
if($result['errcode'] == 0){
	foreach($result['tag_group'] as $key => $channellabel){
		$channellabel_array[$key]['group_id'] = $channellabel['group_id'];
		$channellabel_array[$key]['group_name'] = $channellabel['group_name'];
		foreach($channellabel['tag'] as $key2 => $labelobj){
			if(!empty($channellabel_id) && strpos($channellabel_id,$channellabel['group_id']) !== false && strpos($channellabel_id,$labelobj['id']) !== false){
				continue;
			}
			$channellabel_array[$key]['tag'][$key2]['id'] = $labelobj['id'];
			$channellabel_array[$key]['tag'][$key2]['name'] = $labelobj['name'];
			
		}
	}
}
$selected_channellabel_array = array();
if(!empty($channellabel_id)){
	$channellabel_id_arr = explode('|::##::|',$channellabel_id);
	foreach($channellabel_id_arr as $key => $label_string){
		$label_arr = explode('|::|',$label_string);
		$selected_channellabel_array[$key]['group_id'] = $label_arr[0];
		$selected_channellabel_array[$key]['group_name'] = $label_arr[1];
		$selected_channellabel_array[$key]['tag'][$key]['id'] = $label_arr[3];
		$selected_channellabel_array[$key]['tag'][$key]['name'] = $label_arr[2];
	}
}

$smarty->assign('CHANNELLABEL_ARRAY',$channellabel_array);
$smarty->assign('SELETED_CHANNELLABEL_ARRAY',$selected_channellabel_array);
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel("EnterpriseWeChatCustomerTags");
$arr['oktext']= getFixedLabel("CONFIRMED");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("ChannelLabel.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
?>