<?php
/**
 * User: Dong
 * Project: crm
 * Date: 2020/6/19 11:12
 * Description:
 */
global   $theme, $currentModule, $current_user , $adb;
$socialpromotionid = intval(vtlib_purify($_REQUEST['recordId']));
$socialpromotion_no = vtlib_purify($_REQUEST['socialpromotion_no']);
$step = vtlib_purify($_REQUEST['step']);
$focus = CRMEntity::getInstance($currentModule);
$focus->id =$socialpromotionid;
$focus->mode = 'edit';
$focus->retrieve_entity_info($focus->id, $currentModule);


//共享的id 已包括创建人
$shareUsers = explode(',',$_REQUEST['shareUsers']);
$shareUsers = array_filter(array_unique(array_merge(array($focus->column_fields['smcreatorid']),$shareUsers)));
$shareUserValue =array();

//加载二维码配置文件
require_once ('SocialPromotionConfig.php');
$shareUserValue = makeUserQcrodeArr($prefix,$suffix,$htmlPath,$socialpromotionid,$qrcodePath,$currentModule,$shareUsers);
$smarty = new lingdangCRM_Smarty;
//图片下载请求地址
$smarty->assign('shareUserValue',$shareUserValue);

$smarty->assign('step',$step);
$siteUrl = $_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['HTTP_HOST'] .rtrim($_SERVER['PHP_SELF'],'index.php');
//global $site_URL;
//$siteUrl= $site_URL.'/';
$smarty->assign('site_URL',$siteUrl);
//加载配置
require_once ('SocialPromotionConfig.php');
$smarty->assign('activitytypeArr',json_encode($activitytypeArr));

$str=$smarty->fetch("modules/SocialPromotion/SocialPopupEditRelated.tpl");
$arr['content'] = $str;
$_REQUEST['diony'] ='diony';
$arr['oktext']=getFixedLabel("LBL_FINISH_BUTTON_LABEL");
$arr['title']=getTranstab($currentModule);

ConvertTojsonString(1,$arr,"success");