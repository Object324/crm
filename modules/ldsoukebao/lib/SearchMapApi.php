<?php
$searchtext = $_REQUEST['searchtext'];
$arr = [];
if(!empty($searchtext)){
    // 构建请求 URL
    $url = "https://apis.map.qq.com/ws/place/v1/suggestion/?region=全国&keyword=".$searchtext."&key=T3CBZ-INP3X-5TD4Z-TZ3YE-AXBC5-6RBAU";

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
    if($data['status'] == 0 && $data['data']){
        $arr = $data;
    }
}
ConvertTojsonString(1,$data,'sussess');
?>