<?php
/*
edit:duan,
data:2022-1-13,
reason:微信用户通过扫码（表单码）访问crm系统时,需要验证是否授权
*/
global $adb;

$root_dir=dirname(dirname(__FILE__));
require_once($root_dir.'/includefile.php');
require_once($root_dir.'/WeiXinApp/WeiXin_common/StaticConst.php');
require_once($root_dir.'/WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');
require_once($root_dir.'/WeiXinApp/WeiXin_common/cls_Instance.php');
//小程序参数获取
$_REQUEST['diony']='yes';

crm_load_class_file('weixin_user', 'WeiXinApp/modules/Users');
$weixin_user = new weixin_user();
global $weixin_user;
$weixin_user->environment_weixin = true;
$weixin_user->environment = 'weixin';

if(isset($_REQUEST['action'])&&$_REQUEST['action']=='get_expand'){//判断是否授权登录
    //验证用户openid是否已授权
    require_once($root_dir.'/WeiXinApp/qrcodepro/cls_WechatUser.php');
    $code = trim($_REQUEST['code']);
    $WechatUser = new cls_WechatUser();
    $result = $WechatUser->getwxuserInfo($code);
}
else if(isset($_REQUEST['action'])&&$_REQUEST['action']=='auth_login'){//授权登录
    $open_id = $_REQUEST['openid'];
    require_once($root_dir.'/WeiXinApp/qrcodepro/cls_WechatUser.php');
    $WechatUser = new cls_WechatUser();
    $result = $WechatUser->Authorization($open_id);
}
else if(isset($_REQUEST['action'])&&$_REQUEST['action']=='get_save'){//保存单据
    require_once($root_dir.'/WeiXinApp/qrcodepro/cls_FormCode_Save.php');
    $module = $_REQUEST['module'];
    $qrcodeid = $_REQUEST['qrcodeid'];
    $token = $_REQUEST['token'];
    $str = 'formcode'.$qrcodeid;
    if($token != md5($str)){
        ConvertToJsonString(-1,array(),'此次访问未授权');
    }
    $_REQUEST['previousAction'] = 'EditView';
    $_REQUEST['wx_fieldInfo'] = json_decode($_REQUEST['wx_fieldInfo'],true);
    $Formcode_saveobj = new cls_FormCode_Save($module);
    $Formcode_saveobj->setFieldInfoFromPost();
    $result = $Formcode_saveobj->Formcode_save();
}
else{
    //验证用户openid是否已授权
    require_once($root_dir.'/WeiXinApp/qrcodepro/cls_WechatUser.php');
    $code = trim($_REQUEST['code']);
    $WechatUser = new cls_WechatUser();
    $result = $WechatUser->getwxuserInfo($code);
}
//ls 20221231  XUQIU1000922：表单码-分录可编辑
$result[1]['is_qrcode_expand'] = 'yes';
ConvertToJsonString($result[0],$result[1],$result[2]);
?>