<?php
//二维码存储的目录
$qrcodePath = 'SocialPromotionQrcode.php?'; //公共生成二维码方法
//设置静态html的文件名 及目录
$prefix  = 'questionnaire_';
$suffix = '.html';
$htmlPath = 'storage/questionnaireHtml/';

function makeQrcode($prefix,$suffix,$htmlPath,$record,$qrcodePath,$currentModule,$userid){
    $shareUserValue =array();
    $htmlFileName = $prefix.$record.$suffix;
//获取当前cmr的url
    //global $site_URL;
    //$siteUrl =$site_URL.'/';
    $siteUrl = $_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['HTTP_HOST'] .rtrim($_SERVER['PHP_SELF'],'index.php');
    $downUrl="index.php?module=uploads&frommodule=".$currentModule."&action=downloadQuestionnaireQrcode";

    $shareUserValue['userid'] = $userid;
    $shareUserValue['lastname'] = getUserFullName($userid);
    $shareUrl = $siteUrl.$htmlPath.$htmlFileName.'?uid='.$userid;
    $shareUserValue['shareUrl'] = $shareUrl;
    //用于img标签里面的二维码地址
    $shareUserValue['qrcode'] = $qrcodePath.'url='.urlencode($shareUrl);
    //下载图片地址需要 http://
    $shareUserValue['downQrcode_URL'] = $downUrl.'&username='.urlencode(getUserFullName($userid)).'&pathfile='.urlencode($siteUrl.$qrcodePath.'&url='.urlencode($shareUrl));

    return $shareUserValue;
}
