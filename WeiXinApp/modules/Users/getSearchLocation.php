<?php
/**
 * 关键字搜索定位
 * diony 2018-08-29
 * */
$region = '中国' ;
$keyword = $_REQUEST["keyword"];
// $key = 'P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X';
$key = 'T3CBZ-INP3X-5TD4Z-TZ3YE-AXBC5-6RBAU';
//https://apis.map.qq.com/ws/place/v1/suggestion/?region=北京&keyword=美食&key=OB4BZ-D4W3U-B7VVO-4PJWW-6TKDJ-WPB77
if(!empty($key)&&!empty($keyword)){
    //duan 20221116 移动端定位搜索时以当前所在位置为中心点进行排序
   /* if(isset($_REQUEST['longtitude']) && isset($_REQUEST['latitude'])){
        $latitude = $_REQUEST['latitude'];
        $longtitude = $_REQUEST['longtitude'];
        $point_url ="&location=$latitude,$longtitude";
    }*/
    
    
    $q = "https://apis.map.qq.com/ws/place/v1/suggestion/?region=$region&keyword=$keyword&key=$key&a=1$point_url";
    
    $result = CurlGet($q);
     
    
    $resultQ = json_decode($result['content'],true);    
    $data = array();
    if(!empty($resultQ['data'])){
        foreach($resultQ['data'] as $val){
            $poisval = array();
            $poisval[] = $val['title'];
            //editor:gyq_20190522 reason:显示完整地址  2019/5/22 16:37
            //0037021: 企业微信，新增客户，定位地址，将title增加到具体地址后。
            $poisval[] = $val['address'].$val['title'];
            $poisval[] = $val['location']['lat'];
            $poisval[] = $val['location']['lng'];
            $poisval[] = '中国';
            $poisval[] = $val['province'];
            $poisval[] = $val['city'];
            $poisval[] = $val['district'];
            $data[] = $poisval;
        }
    }
    $entity['list'] = $data;
    ConvertTojsonString(1,$entity,'success');
}else{
    ConvertTojsonString(-1,null,'error');   
}
exit();
?>