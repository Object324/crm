<?php
/**
 * User: Dong
 * Project: crm
 * Date: 2020/7/10 9:51
 * Description: 二维码 静态页面配置文件展示配置文件
 */
//二维码为动态生成
$qrcodePath = 'SocialPromotionQrcode.php?';
//设置静态html的文件名 及目录
$prefix  = 'social_';
$suffix = '.html';
$htmlPath = 'storage/socialHtml/';
//可以获取的自定义字段的uitype
$needUiType = array(1,21,19,11,1101,1102,1103,1109,15,33,56,7,71,5,14,86,17);
//级联字段
$cascadeFields=array('bill_country');

//全局变量 做判断用
$activitytypeArr = array('onlyForm'=>'仅表单','H5+form'=>'H5页面链接 + 表单');

function makeUserQcrodeArr($prefix,$suffix,$htmlPath,$socialpromotionid,$qrcodePath,$currentModule,$shareUsers){
    $shareUserValue =array();
    $htmlFileName = $prefix.$socialpromotionid.$suffix;
//获取当前cmr的url
//    global $site_URL;
//    $siteUrl =$site_URL.'/';
    // 20240220 hzx BUG20240219-46 表单推广生成的二维码链接为内网地址，而不是外网地址，手机扫码后无法打开
    $siteUrl = $_SERVER['HTTP_ORIGIN'].rtrim($_SERVER['PHP_SELF'],'index.php');
    $downUrl="index.php?module=uploads&frommodule=".$currentModule."&action=downloadSocialPromotionQrcode";
    foreach ($shareUsers as $key =>$userid){
        $shareUserValue[$key]['userid'] = $userid;
        $shareUserValue[$key]['lastname'] = getUserFullName($userid);
        $shareUrl = $siteUrl.$htmlPath.$htmlFileName.'?uid='.$userid;
        //html地址
        $shareUserValue[$key]['shareUrl'] = $shareUrl;
        //用于img标签里面的二维码地址
        $shareUserValue[$key]['qrcode'] = $qrcodePath.'url='.urlencode($shareUrl);
        //下载图片地址需要 http://
        $shareUserValue[$key]['downQrcode_URL'] = $downUrl.'&username='.urlencode(getUserFullName($userid)).'&pathfile='.urlencode($siteUrl.$qrcodePath.'&url='.urlencode($shareUrl));

    }
    return $shareUserValue;
}