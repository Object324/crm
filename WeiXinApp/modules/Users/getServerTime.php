<?php
/** 
* @edit:diony 
* @date:2020-07-20 
* @description:获取服务器时间
*/
$json['servertime'] = time();
$json['time'] = date('Y-m-d H:i:s',time());
ConvertTojsonString(1,$json,'success');
?>