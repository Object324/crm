<?php

//企业微信标签  添加标签
global   $theme, $currentModule, $current_user;
$focus = CRMEntity::getInstance($currentModule);
$fieldObj=$focus->fieldobj;
$smarty = new lingdangCRM_Smarty;
$token=$focus->getAccessToken();
$url = 'https://qyapi.weixin.qq.com/cgi-bin/externalcontact/get_corp_tag_list?access_token='.$token;
$result=$focus->wx_get($url);
$group_id = '';
if($result['errcode'] == 0){
	foreach($result['tag_group'] as $key => $channellabel){
		if($channellabel['group_name'] == $_REQUEST['label_group_name']){
			$group_id = $channellabel['group_id'];
		}
	}
}
if(!empty($_REQUEST['label_content'])){
	$label_array = ldcrm_json_decode($_REQUEST['label_content']);
	foreach($label_array as $key => $tag){
		$tag_arr[] = array(
			'name' => $tag,
			'order' => 0	
		);
	}
	$crop_data = array(
//		'group_id' => $group_id,//etvOShBwAATSC8rRmUrkrpsgQfvsCjyw
		'group_name' => $_REQUEST['label_group_name'],
		'order' => 1,
		'tag' => $tag_arr
	);
    if (!empty($group_id)) { //新增标签组名称时，group_id不能传，传了就不能为空，否则接口报错
        $crop_data['group_id'] = $group_id;//etvOShBwAATSC8rRmUrkrpsgQfvsCjyw
    }
}
$url = 'https://qyapi.weixin.qq.com/cgi-bin/externalcontact/add_corp_tag?access_token='.$token;
$result=$focus->wx_post($url,$crop_data);
$_REQUEST['diony']='diony';
if($result['errcode'] == 0){
	$channellabel = $result['tag_group'];
	foreach($channellabel['tag'] as $arr){
		$label[] = $channellabel['group_id'].'|::|'.$channellabel['group_name'].'|::|'.$arr['name'].'|::|'.$arr['id'];
		$label_name[] = $arr['name'];
	}
	ConvertTojsonString(1,array('label'=>implode('|::##::|',$label),'name'=>implode(',',$label_name)),"success");
}else{
	ConvertTojsonString(-1,$result,getFixedLabel('USERSAVEFAIL'));
}

?>