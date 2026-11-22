<?php
/**
 * 根据地址获取经纬度
 * diony 2018-08-29
 * */
$address = $_REQUEST["address"];
// $key = 'P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X';
$key = 'T3CBZ-INP3X-5TD4Z-TZ3YE-AXBC5-6RBAU';
//https://apis.map.qq.com/ws/geocoder/v1/?address=中国上海市上海市浦东大道2000号&key=OB4BZ-D4W3U-B7VVO-4PJWW-6TKDJ-WPB77
if(!empty($key)&&!empty($address)){
    $q = "https://apis.map.qq.com/ws/geocoder/v1/?address=$address&key=$key";
    $result = CurlGet($q);
    $resultQ = json_decode($result['content'],true);
    $data = array();
    if(!empty($resultQ)){
        $data[] = $resultQ['result']['title'];
        $data[] = $resultQ['result']['location']['lat'];
        $data[] = $resultQ['result']['location']['lng'];        
    }
    $entity['list'] = $data;
    if($resultQ['result']['location']['lat']){
        ConvertTojsonString(1,$entity,'success');    
    }
    else{
        ConvertTojsonString(-1,null,'error');    
    }
}else{
    ConvertTojsonString(-1,null,'error');
}
exit();
?>