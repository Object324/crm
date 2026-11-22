<?php
/*+*******************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $theme, $current_user;
$_REQUEST = SqlSearchFilter($_REQUEST);

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

require_once(globalStatic::$root_directory.'include/home.php');
$homeObj=new Homestuff;
$smarty=new lingdangCRM_Smarty;
$smarty->assign("IsAdmin",is_admin($current_user));

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);

if(!empty($_REQUEST['boardid'])){
    $boardid=$_REQUEST['boardid'];
}
if(!empty($_REQUEST['homestuffid'])){
	$stuffid = $_REQUEST['homestuffid'];
}
if(!empty($_REQUEST['blockstufftype'])){
	$stufftype = $_REQUEST['blockstufftype'];
}
if(!empty($_REQUEST['selectuserid']))
{
    $senioruserid = $_REQUEST['selectuserid'];
}
if(!empty($_REQUEST['search_date'])){
	if($_REQUEST['search_date'] == 'custom')
		$search_date = $_REQUEST['date_custom'];
	else
		$search_date = $_REQUEST['search_date'];
}
$search_date = empty($search_date)||$search_date=="null"?'thisyear':$search_date;
//@edit:zhouxiaomei @date:2020-9-7 @reason: 首页增加近6个月销售目标完成情况组件 增加销售指标参数
if(!empty($_REQUEST['data_type'])){
    $data_type = $_REQUEST['data_type'];
}
///获取组件
$homestuff_values=$homeObj->getHomePageStuff($stuffid,$stufftype,$senioruserid,$search_date,$data_type,$boardid);
$type = 'default';
if($_REQUEST['blockstufftype'])
{
    $type=$_REQUEST['blockstufftype'];
}
else
{
    $homedetails = $homeObj->getHomePageFrame($current_user->profileid);
    foreach($homedetails as $infos){
    	if($infos['Stuffid'] == $stuffid){
    		$type = strtolower($infos['Stufftype']);
    	}
    }
}
$smarty->assign("HOME_STUFFID",$stuffid);
setGLobalURLSmarty($smarty);//设置js,css等访问路径

//zxm 20231016 移动端特殊组件
if(($type=='commonmodules'||$type=='salesdragontiger'||$type=='Contractkit'||$type=='customreportblock')&&$_REQUEST['from_module']=='MobileReport'){
    //常用模块 --移动端--stuffid=108
    $cnt = sizeOf($homestuff_values['Details']['list']);
    $width = round(100/$cnt, 1)-0.1;
    $smarty->assign('cnt',$cnt);
    $smarty->assign('CSSWIDTH',$width);
    $smarty->assign("HOME_STUFFTYPE",$type);
    $smarty->assign("HOME_STUFF",$homestuff_values['Details']['list']);
    $smarty->display("Home/".$type."_mobile.tpl");
}else if($type=='servicekanban'){
    $smarty->assign("HOME_STUFF", $homestuff_values['Details']['content']);
    $smarty->display("Home/servicekanban.tpl");
}else
if($type=='notebook'){
    $contents = $homeObj->getNoteBookContents($stuffid);
	$smarty->assign("NOTEBOOK_CONTENTS",$contents);
	$smarty->assign("NOTEBOOKID", $stuffid);
	$smarty->display("Home/notebook.tpl");
}
elseif($type=='default'||$type=='customsheet'){
    $smarty->assign("HOME_STUFFTYPE",$type);
    $smarty->assign("HOME_STUFF",$homestuff_values);
    if(!empty($_REQUEST['loadtype'])&&$_REQUEST['loadtype']=='scroll'){
        //下拉加载
        $res['content'] = $smarty->fetch("Home/HomeBlockContent.tpl");
        $res['pagenum'] = $homestuff_values['Details']['pagenum'];
        $res['havenextpage'] = $homestuff_values['Details']['havenextpage'];
        ConvertTojsonString(1,$res,'success');
    }else{
        $smarty->display("Home/HomeBlock.tpl");
    }
}
elseif($type =='twotable')
{
	$smarty->assign("HOME_STUFF",$homestuff_values);
	$smarty->display("Home/HomeTwoTable.tpl");
}
elseif($type =='twotable2')
{
	$smarty->assign("HOME_STUFF",$homestuff_values);
	$smarty->display("Home/HomeTwoTable2.tpl");
}
elseif($type=='table'){
   $smarty->assign("HOME_STUFF",$homestuff_values);
   $smarty->display("Home/HomeTable.tpl");
}elseif($type == 'transaction'){
    //34交易 33销售排行榜
	$smarty->assign("HOME_STUFF",$homestuff_values['Details']);
	$smarty->display("Home/HomeTable3.tpl");
}elseif($type=='chart' || strtolower($type)=='dragontigerlist' || $type === 'Carousel'){
    $smarty->assign("HOME_STUFF",$homestuff_values);
    ConvertTojsonString(1,$homestuff_values['Details'],'success');die;
}elseif($type == 'saleskit'){
	$smarty->assign("HOME_STUFF",$homestuff_values['Details']);
	if($stuffid == 35||$stuffid == 65){	//销售简报 65工程行业收支报告
        global $adb;
        $cnt = is_array($homestuff_values['Details'])?sizeOf($homestuff_values['Details']):0;
        crm_load_class_file('HomeStuffDetailUtils','modules/Home');
        $boardstuffid = $homeObj->getBoardStuffId($boardid,$stuffid);
        $SaleskitLayout = HomeStuffDetailUtils::getSaleskitLayout([
            'boardid' => $boardid,
            'stuffid' => $stuffid,
            'boardstuffid' => $boardstuffid,
            'count' => $cnt,
        ]);
        $colcount = $SaleskitLayout['colcount'];
        $isshowprevious = $SaleskitLayout['isshowprevious'];
        $ShowPercent = $SaleskitLayout['ShowPercent'];
       if(empty($cnt))
       {
           $width=100;
       }
       else
		    $width = round(100/$cnt, 1)-0.1;
        $smarty->assign('cnt',$cnt);
		$smarty->assign('CSSWIDTH',$width);

		if($_REQUEST['boardid'] <= 0){
            //默认看板
            $colcount = 4;
        }
		$smarty->assign('COLCOUNT',$colcount);
		$smarty->assign('saleskit_isshowpredata',$isshowprevious);
		$smarty->assign('ShowPercent',$ShowPercent);
		$smarty->assign('stuffid',$stuffid);
        $smarty->display("Home/HomeTable4_NEW.tpl");
	}
}
elseif($type=='pendingapproval'){     //审批组件
//  @edit:liushuai,2020-07-16,reason:1000923/首页，增加“待审批”组件
    $smarty->assign("HOME_STUFFTYPE",$type);
    $smarty->assign("HOME_STUFF",$homestuff_values);
    $smarty->display("Home/HomeTable6.tpl");
}else if($type=='calendar'&&vtlib_isModuleActive('Calendar')){
    //@edit:zhouxiaomei,2020-09-08,@reason:首页增加“日程管理”组件
    $smarty->assign("HOME_STUFFTYPE",$type);
    $smarty->assign("HOME_STUFF",$homestuff_values);
    $smarty->display("Home/HomeCalendar.tpl");
}else if($type=='marketingreport'){
    //@edit:zhouxiaomei,2020-1126,reason:誉帆-首页增加营销报告
    $smarty->assign("HOME_STUFFTYPE",$type);
    $smarty->assign("HOME_STUFF",$homestuff_values);
    $dir = dirname(dirname(dirname(__FILE__)));
    $dir = explode('\\',$dir);
    $count = count($dir);
    $smarty->display("Home/MarketingReport.tpl");
}else if($type=='rankinglist'){
    //@edit:zhouxiaomei,2020-1201,reason:誉帆-首页增加排行榜
    $smarty->assign("HOME_STUFFTYPE",$type);
    $smarty->assign("HOME_STUFF",$homestuff_values);
    $smarty->display("Home/RankingListContent.tpl");
}else if($type=='yichongsaleskit'){
    //@edit:zhouxiaomei,2020-1201,reason:誉帆-首页增加排行榜
    $cnt = sizeOf($homestuff_values['Details']);
    $width = round(100/$cnt, 1)-0.1;
    $smarty->assign('cnt',$cnt);
    $smarty->assign('CSSWIDTH',$width);

    $smarty->assign("HOME_STUFFTYPE",$type);
    $smarty->assign("HOME_STUFF",$homestuff_values['Details']);
    $smarty->display("Home/yichongSalesKit.tpl");
}

unset($mod_strings);
unset($app_strings);
unset($current_user);
unset($adb);
?>