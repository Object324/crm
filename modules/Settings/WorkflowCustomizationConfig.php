<?php
$smarty=new lingdangCRM_Smarty;
global $adb,$theme,$mod_strings,$app_strings;
$data = [];
if(!empty($_REQUEST['mode']) && $_REQUEST['mode'] == 'get'){
    $config = array(
        'apiurl'=>$_REQUEST['apiurl'],
        'username'=>$_REQUEST['username'],
        'password'=>$_REQUEST['password'],
        'orgid'=>$_REQUEST['orgid'],
        'client_secret'=>$_REQUEST['client_secret'],
        'client_id'=>$_REQUEST['client_id'],
    );
	$token = getAccessToken($config);
	if($token['code'] == -1){
		$_REQUEST['diony']='yes';
		ConvertTojsonString(-1,array('content'=>$token['msg']),"error");
	}else{
		$url = $_REQUEST['apiurl'] .'/jdy/sys/accountGroup?access_token='.$token['token'];
		$result = postUrl($url);
		if($result['success'] == 1 && $result['errorCode'] == 'success'){
			foreach($result['data'][0]['accountGroups'] as $var){
				$data[$var['accountId']] = $var['accountName'];
				
			}
		}
		$_REQUEST['diony']='yes';
		ConvertTojsonString(1,array('content'=>json_encode($data),'serviceid'=>$result['data'][0]['serviceId']),"success");
	}
}
if(!empty($_REQUEST['mode']) && $_REQUEST['mode'] == 'save'){
    $config = array(
        'apiurl'=>$_REQUEST['apiurl'],
        'username'=>$_REQUEST['username'],
        'password'=>$_REQUEST['password'],
        'orgid'=>$_REQUEST['orgid'],
        'client_secret'=>$_REQUEST['client_secret'],
        'client_id'=>$_REQUEST['client_id'],
		'dbname'=>$_REQUEST['dbname'],
		'db_description'=>$_REQUEST['dbname_desc'],
    );
	$query = "select 1 from ld_workflow_api where api_name = 'jdyisv'";
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		$query = "update ld_workflow_api set api_url = ?,client_id = ?,client_secret = ?,username = ?,password = ?,orgid = ?,dbname = ?,db_description = ? where api_name = ?";
		$adb->pquery($query,array($config['apiurl'],$config['client_id'],$config['client_secret'],$config['username'],$config['password'],$config['orgid'],$config['dbname'],$config['db_description'],'jdyisv'));
	}else{
		$query = "insert into ld_workflow_api(api_name,api_url,client_id,client_secret,username,password,orgid,dbname,description,db_description) values (?,?,?,?,?,?,?,?,?,?)";
		$adb->pquery($query,array('jdyisv',$config['apiurl'],$config['client_id'],$config['client_secret'],$config['username'],$config['password'],$config['orgid'],$config['dbname'],'ÔÆÐÇ³½¶Ô½Ó',$config['db_description']));
	}
	$_REQUEST['diony']='yes';
	ConvertTojsonString(1,array(),"success");
}
$data = [];
$query = 'select api_name,api_url,client_id,client_secret,username,password,orgid,dbname,description,db_description from ld_workflow_api where api_name = ?';
$result = $adb->pquery($query,array('jdyisv'));
$num_rows = $adb->num_rows($result);
if($num_rows >= 1){
	$data = array(
		'api_url' => $adb->query_result($result,$i,'api_url'),
		'client_id' => $adb->query_result($result,$i,'client_id'),	
		'client_secret' => $adb->query_result($result,$i,'client_secret'),	
		'username' => $adb->query_result($result,$i,'username'),	
		'password' => $adb->query_result($result,$i,'password'),	
		'orgid' => $adb->query_result($result,$i,'orgid'),	
		'dbname' => $adb->query_result($result,$i,'dbname'),
		'db_description' => $adb->query_result($result,$i,'db_description'),
	);
}
$smarty->assign('DATA',$data);
$_REQUEST['diony']='yes';
$arr['title'] = getFixedLabel('THEINTERFACEPARAMENTERS').getFixedLabel('SETTINGS');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']= $smarty->fetch('WorkflowCustomization/WorkflowCustomizationConfig.tpl');
ConvertTojsonString(1,$arr,"success");

function postUrl($url, $data='',$header=[])
{
	$curl = curl_init();
	curl_setopt($curl, CURLOPT_URL, $url);
	curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, FALSE);
	curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, FALSE);
	curl_setopt($curl, CURLOPT_POST, 1);
	curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
	if( !empty($header)){
		curl_setopt($curl,CURLOPT_HTTPHEADER,$header);
   }
	$output = curl_exec($curl);
	curl_close($curl);
	$output = json_decode($output, true);
	if ($output['errcode'] != 0) {
		echo json_encode(array('code'=>1,'result'=>array('db_content'=>$output['description'].$output['description_cn'])));
		die;
	}

	return $output;
}

function getAccessToken($config)
{
	$url = $config['apiurl'].'/auth/user/access_token' . '?client_id=' . $config['client_id'] . '&client_secret=' . $config['client_secret'] . '&username=' . $config['username'].'&password=' . urlencode($config['password']);
	$result = getUrl($url);
	if ($result['errcode'] == '0') {
		$accessToken['access_token'] = $result['data']['access_token'];
		return array('code'=>1,'token'=>$accessToken['access_token']);
	}else{
		return array('code'=>-1,'msg'=>$result['description_cn']);
		
	}
}

function getUrl($url)
{
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_HEADER, 0);
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
	curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
	$output = curl_exec($ch);
	curl_close($ch);
	$output = json_decode($output, true);
	return $output;
}

?>

