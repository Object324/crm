<?php
$ip = $_REQUEST['ip'];
$key = "T3CBZ-INP3X-5TD4Z-TZ3YE-AXBC5-6RBAU";  // 这里填写从腾讯地图获取的 API Key

// 构建请求 URL
$url = "https://apis.map.qq.com/ws/location/v1/ip?ip=".$ip."&key=".$key;

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "GET");
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); //不验证证书
curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false); //不验证证书
curl_setopt($ch, CURLOPT_TIMEOUT, 0);
curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$curl_data = curl_exec($ch);
curl_close($ch);
$data = json_decode($curl_data,true);

$arr = [];
if($data['message'] == 'Success' && $data['status'] == 0){
    $arr['location'] = $data['result']['location'];
    $arr['ad_info'] = $data['result']['ad_info']['nation'].$data['result']['ad_info']['province'].$data['result']['ad_info']['city'].$data['result']['ad_info']['district'];
}

ConvertTojsonString(1,$arr,'sussess');
?>
