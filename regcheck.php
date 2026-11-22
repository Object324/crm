<?php

error_reporting(E_ALL & ~E_NOTICE);
header("Content-type: text/html; charset=utf-8");
include('includefile.php');
require_once (globalStatic::$root_directory .'include/cls_UrlEncryptyJudge.php');
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->setJudgeUrlstringbyarr($_REQUEST);
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb, $theme,$global_iskehu001;
@session_start();


$languageType = $_REQUEST['languageType'] ?: 'zh';
require_once("Register/RegOp.php");
$regop=RegOp::getInstance();
require_once(globalStatic::$root_directory . 'Smarty_setup.php');
$smarty = new lingdangCRM_Smarty;

//客户001未分配预置账套不允许登录 D:\wamp\www\ldcrm\modules\Users\Login.php D:\wamp\www\ldcrm\Smarty\templates\Login.tpl
if($global_iskehu001=='no')
{
    $KEHU001_NO_DISTRIBUTE = true;
    preg_match('#weixin/(\w+)/#i',$_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'],$matches);
    preg_match('#kh/(\w+)/#i',$_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'],$khmatches);
    if(!empty($matches)||!empty($khmatches)) {


        $crmversion=$regop->GetVersionNo();
        if(!judgeCorpInfo('install_app')){
            $smarty->assign('WEIXINLOGIN','no');
            $smarty->assign('KEHU001_NO_DISTRIBUTE','yes');
            $KEHU001_NO_DISTRIBUTE = false;
        }
    }
    if($KEHU001_NO_DISTRIBUTE){
        //判断是否授权安装CRM微信套件应用 gyq_51  20171128
        $corpurl = getQRcodeForLogin();
        $smarty->assign('WEIXINLOGINURL',$corpurl);//

    }
    //自建应用
    crm_load_class_file("cls_WeiXinSelfBuiltApp", 'WeiXinApp/WeiXin_common');
    $wxselfbuilt_obj = new cls_WeiXinSelfBuiltApp();

    $corpid = $wxselfbuilt_obj->corpid;
    $corpsecret = $wxselfbuilt_obj->corpsecret;//自建应用的secret
    $agentid = $wxselfbuilt_obj->agentid;//自建应用生成前端链接时，agentid传上去
    $smarty->assign("agentid",$agentid);
    $smarty->assign("corpid",$corpid);
    if(!empty($agentid))
    {
        $corpurl = $wxselfbuilt_obj->corp_link;// 同 $corpurl
        $smarty->assign('WEIXINLOGINURL',constant("WxSelfBuildURL").'/wxSelfbuiltQrCodeLogin.php?corpurl='.$corpurl);//
    }

}
else if($global_iskehu001=='yes')
{
    $corpurl = getQRcodeForLogin();
    $smarty->assign('WEIXINLOGINURL',$corpurl);
}
if(empty($corpurl)){
    $smarty->assign('WEIXINLOGIN','no');
}else{
    $smarty->assign('WEIXINLOGIN','yes');
}
if(empty($global_login_wxbtn))
{
    $global_login_wxbtn=array('zh'=>"企业微信登录",'en'=>"WeChat login",'isshow'=>'yes','after_en_content'=>"WeChat login","after_zh_content"=>"企业微信登录");
}
if(!array_key_exists('after_en_content',$global_login_wxbtn))
{
    $global_login_wxbtn['after_en_content']='WeChat login';

}
$smarty->assign("WXLOGINBTN",$global_login_wxbtn);

require_once(globalStatic::$root_directory . 'dataCache/Login/LoginSettingsInfo.php');
$smarty->assign("LOGININFO", $global_logininfo);
$smarty->assign("LANGUAGETYPE", $languageType);
$smarty->assign("STEP", 1);
$smarty->assign("LOGININFO",$global_logininfo);
$global_loginpage_url_arr = [];
for($i = 0;$i < count($global_loginpage_url);$i++){
    if($global_loginpage_url[$i]['isshow'] == 'yes'){
        $global_loginpage_url_arr[] = array('label'=>$global_loginpage_url[$i]['content'],'value'=>$global_loginpage_url[$i]['content'],'url'=>$global_loginpage_url[$i]['url']);
    }
}
$smarty->assign("global_loginpage_url_arr",json_encode($global_loginpage_url_arr));
$smarty->assign("loginpage_url_num",count($global_loginpage_url_arr));
$getLoginInfoData = getLoginInfoData();
$loginswiperarr = $getLoginInfoData['loginswiperarr'];
$swiperratio = $getLoginInfoData['swiperratio'];
$smarty->assign("LOGINSWIPERARR",$loginswiperarr);
$smarty->assign("SWIPERRATIO",$swiperratio);
$smarty->display('regcheck.tpl');
?>