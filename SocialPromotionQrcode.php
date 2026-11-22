<?php
/**
 * User: Dong
 * Project: crm
 * Date: 2020/6/19 11:12
 * Description: 动态二维码
 */

require_once 'modules/SocialPromotion/phpqrcode.php';
$url = $_REQUEST['url'];
// 纠错级别：L、M、Q、H
$level = 'M';
// 点的大小：1到10,用于手机端4就可以了
$size = 7;
if(stripos($url,'https://')!==false)
{
}

else if(stripos($url,'http://')!==false)
{
    
}
else{
    
    exit('路径错误');
}
QRcode::png($url, false, $level, $size);


