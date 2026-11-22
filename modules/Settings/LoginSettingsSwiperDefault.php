<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;

$sql = "DELETE from ld_loginsettingsinfo where `name` = 'loginswiper';";
$adb->pquery($sql,array());
$update = "update ld_loginsettingsinfo set isshow = 'yes',isedit = 'yes' where `name` = 'loginswiper' and type = 'default';";

require_once globalStatic::$root_directory.'WeiXinApp/lib/qcloud/QcloudSTS.php';
$sts = new QcloudSTS();
$type = $sts->getUploadType();
$insertsql = '';
if(!empty($type)){
    if($type == 'cos'){
        $insertsql = "INSERT INTO `ld_loginsettingsinfo` (`name`, `isshow`, `isedit`, `content`, `url`, `type`, `swipertype`, `sequence`) VALUES ('loginswiper', 'yes', 'yes', 'https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/swiper/crm/login/defaultloginswiper1.png', 'https://www.51mis.com/', 'default', '1:2', '2'),
            ('loginswiper', 'yes', 'yes', 'https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/swiper/crm/login/defaultloginswiper2.png', 'https://www.51mis.com/', 'default', '1:2', '3'),
            ('loginswiper', 'yes', 'yes', 'https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/swiper/crm/login/defaultloginswiper3.png', 'https://www.51mis.com/', 'default', '1:2', '1'),
            ('loginswiper', 'yes', 'yes', 'https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/swiper/crm/login/defaultloginswiper1.png', 'https://www.51mis.com/', 'default', '2:1', '2'),
            ('loginswiper', 'yes', 'yes', 'https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/swiper/crm/login/defaultloginswiper2.png', 'https://www.51mis.com/', 'default', '2:1', '3'),
            ('loginswiper', 'yes', 'yes', 'https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/swiper/crm/login/defaultloginswiper3.png', 'https://www.51mis.com/', 'default', '2:1', '1');";
    }
    else{
        $insertsql = "INSERT INTO `ld_loginsettingsinfo` (`name`, `isshow`, `isedit`, `content`, `url`, `type`, `swipertype`, `sequence`) VALUES ('loginswiper', 'yes', 'yes', 'dataCache/test/swiper/defaultloginswiper1.png', 'https://www.51mis.com/', 'default', '1:2', '2')
            ,('loginswiper', 'yes', 'yes', 'dataCache/test/swiper/defaultloginswiper2.png', 'https://www.51mis.com/', 'default', '1:2', '3')
            ,('loginswiper', 'yes', 'yes', 'dataCache/test/swiper/defaultloginswiper3.png', 'https://www.51mis.com/', 'default', '1:2', '1')
            ,('loginswiper', 'yes', 'yes', 'dataCache/test/swiper/defaultloginswiper1.png', 'https://www.51mis.com/', 'default', '2:1', '2')
            ,('loginswiper', 'yes', 'yes', 'dataCache/test/swiper/defaultloginswiper2.png', 'https://www.51mis.com/', 'default', '2:1', '3')
            ,('loginswiper', 'yes', 'yes', 'dataCache/test/swiper/defaultloginswiper3.png', 'https://www.51mis.com/', 'default', '2:1', '1');";
    }
}


if(!empty($insertsql)){

    $adb->pquery($insertsql,array());
}

ConvertTojsonString(1,array(),"success");
?>