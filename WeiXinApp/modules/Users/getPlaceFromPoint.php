<?php
/**
 * 根据经纬度获取地址
 * xxs 2017-12-20
 * */

$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$latitude = $_REQUEST["latitude"] ;
$longitude = $_REQUEST["longitude"];
// $key = 'P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X';
$key = 'T3CBZ-INP3X-5TD4Z-TZ3YE-AXBC5-6RBAU';
//https://apis.map.qq.com/ws/geocoder/v1/?location=39.984154,116.307490&key=T3CBZ-INP3X-5TD4Z-TZ3YE-AXBC5-6RBAU&get_poi=1
if(!empty($key)&&!empty($latitude)&&!empty($longitude)){
    //腾讯地图坐标转换官网：http://lbs.qq.com/webservice_v1/guide-convert.html
    $q = "https://apis.map.qq.com/ws/geocoder/v1/?location=$latitude,$longitude&key=$key&get_poi=1";
    //$q = "http://apis.map.qq.com/ws/geocoder/v1/?location=$latitude,$longitude&key=$key&get_poi=1";
    // &poi_options=address_format=short;radius=5000;policy=5
    $result = CurlGet($q);
    $resultQ = json_decode($result['content'],true);
   // global  $current_user;

   // file_put_contents(globalStatic::$root_directory."dataCache/maplocation.txt","date:".date("Y-m-d H:i:s")."status:".$resultQ['status']."userid:".$current_user->id."\n\n",FILE_APPEND);

    if(empty($resultQ['status']))
    {
            /*0 	结果正常
                ------------ 	配额鉴权相关（非系统错误）
                110 	请求来源未被授权 111 	签名验证失败 112 	IP未被授权 113 	此功能未被授权
                120 	此key每秒请求量已达到上限 121 	此key每日调用量已达到上限 160 	sig参数不支持此请求类型
                161 	sig参数不支持和非object的POST JSON一起使用 190 	无效的KEY 199 	此key未开启webservice功能
                ------------ 	参数错误（非系统错误）
                301 	缺少必要字段key 311 	key格式错误 300 	缺少必要字段 306 	缺少参数 326 	起终点距离过近 375 	局域网IP无法定位
                365 	纬度不能超过±90
                366 	经度不能超过±180  373 	起终点距离超长 374 	起终点坐标错误 382 	IP无法定位
            */

    }
    else{
        global  $current_user;

        file_put_contents(globalStatic::$root_directory."dataCache/maplocation.txt","date:".date("Y-m-d H:i:s")."status:".$resultQ['status']."userid:".$current_user->id."\n\n",FILE_APPEND);

        ConvertTojsonString(-1,[],'error');
    }
    //$resultQ = json_decode(file_get_contents($q),true);
    $pois = array();
    if(!empty($resultQ['result']['pois'])){
        foreach($resultQ['result']['pois'] as $val){
            $poisval = array();
            $val['address'] = str_replace("闸北区","静安区",$val['address']);
            $poisval[] = $val['title'];
            //editor:gyq_20190709 reason:address内容追加titile形成完整地址
            // $poisval[] = $val['address'].$val['title'];//加上title，再根据地址获取经纬度会有偏差
            $poisval[] = $val['address'];
            $poisval[] = $val['location']['lat'];
            $poisval[] = $val['location']['lng'];
            $poisval[] = $resultQ['result']['address_component']['nation'];
            $poisval[] = $val['ad_info']['province'];
            $poisval[] = $val['ad_info']['city'];
            $poisval[] = $val['ad_info']['district'];
            $pois[] = $poisval;
        }
    }
    $nation = '';
    $province = '';
    $city = '';
    $district = '';
    if($resultQ["result"]['address_component']){
        $address_component = $resultQ["result"]['address_component'];
        if($address_component['nation']){
            $nation = $address_component['nation'];
        }
        if($address_component['province']){
            $province = $address_component['province'];
        }
        if($address_component['city']){
            $city = $address_component['city'];
        }
        if($address_component['district']){
            $district = $address_component['district'];
        }
    }
    
    $address = $resultQ["result"]["address"];
    $isdetailaddress = preg_match('/[0-9]/',$address); //地址中是否包含数字
    $lat = $latitude;
    $lng = $longitude;
    if(!$isdetailaddress&&!empty($pois[0][1])){
        $address = $pois[0][1];
        $lat = $pois[0][2];
        $lng = $pois[0][3];
    }
    $address = str_replace("闸北区","静安区",$address);
    $entity['nation'] = $nation;
    $entity['province'] = $province;
    $entity['city'] = $city;
    $entity['district'] = $district;
    $entity['address'] = $address;
    $entity['lat'] = $lat;
    $entity['lng'] = $lng;
    $entity['pois'] = $pois;
    ConvertTojsonString(1,$entity,'success');
}else{
    ConvertTojsonString(-1,null,'error');   
}
exit();
?>