<?php


require_once('Smarty_setup.php');

global $currentModule,$default_charset;

global $moduleList,$adb;
global $theme;
global $parent_string;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";


//edit:duan reason:复制缓存文件到新的目录下
ChangeCachepath();

if(!file_exists($root_directory."dataCache/Login/LoginSettingsInfo.php"))
{
    file_put_contents($root_directory.'dataCache/Login/LoginSettingsInfo.php',file_get_contents($root_directory."LoginSettingsInfo_default.php"));
}
require_once($root_directory."dataCache/Login/LoginSettingsInfo.php");

$userName =  $current_user->last_name;
$smarty = new lingdangCRM_Smarty;
$smarty->assign("GLOBAL_LOGININFO",$global_logininfo);

//如果有问题我来修改 can,
//获取父菜单可以通过（getAllParenttabmoduleslist（））；约80行
//$header_array = getHeaderArray();
//35823: 登录之后，header.php 中不需要再次获取注册信息，登录后title中不需要再显示版本信息
require_once($root_directory.'dataCache/tabdatas/parent_language.php');
//require($root_directory."user_privileges/user_language_".$current_user->id.'.php');

$smarty->assign("GLOBAL_WELCOME",$global_welcome);
$languageType=getLanguageType($current_user);

$smarty->assign("JSURL","");
$smarty->assign("JSVERSION","");
setGLobalURLSmarty($smarty);
$smarty->assign("LANUGAGETYPE",$languageType);
$smarty->assign("THEME",$theme);
$smarty->assign("IMAGEPATH",$image_path);
$smarty->assign("USER",$userName);

$block_info = getBlockDisplayInfo('AccountContacts');
  //显示位置
$_SESSION[globalStatic::$root_directory.'accountcontacts_display_position']=$block_info['display_position'];

  
     //是否显示
if($block_info['is_display'] == 0)
$_SESSION[globalStatic::$root_directory.'accountcontacts_bestatus']='yes';
else
$_SESSION[globalStatic::$root_directory.'accountcontacts_bestatus']='no';


$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);

$smarty->assign('MODULE_TABID',getTabid($currentModule));
$smarty->assign("MODULE_NAME", $currentModule);

//$date = new DateTimeField(null);
//$smarty->assign("DATE", $date->getDisplayDateTimeValue());
$smarty->assign("CURRENT_USER_MAIL", $current_user->email1);
$smarty->assign("CURRENT_USER", $current_user->user_name);
$sessionvalue=getSession('__UnifiedSearch_SelectedModules__');

if(!empty($_SESSION['__UnifiedSearch_SelectedModules__'])){
	$search_module = implode(',',$sessionvalue);
}else{
	$search_module = 'Accounts,Contacts,ContactRecords,Calendar,DailyReport,WeekReport,MonthReport,SalesOrder';	
}
$smarty->assign('SEARCHMODULE',$search_module);
/*
*更新操作
*edit:diony
*time:2013-11-22
*reson:BUG编号：5684
*/

$smarty->assign("CURRENT_NAME", $current_user->last_name);
$smarty->assign("LASTNAME",getUserlastName($current_user));
$smarty->assign("CURRENT_USER_ID", $current_user->id);
$smarty->assign("MODULELISTS",$app_list_strings['moduleList']);

/*$parenttablist=getAllParenttabmoduleslist();
//dump($parenttablist);


if(isPermitted('Users','index')=='yes' && vtlib_isModuleActive('Users')){
    
	$parenttablist['Setup'][] = Array(getTransTab('Users'), 'Users');
}
//$parenttablist['Setup'][] = Array(getFixedLabel('Sector').getFixedLabel('Setup'), 'system_group');
//部门、权限、系统设置
if($current_user->is_admin == 'on'){
	$parenttablist['Setup'][] = Array(getFixedLabel('profileauthority'), 'system_profile');

	$parenttablist['Setup'][] = Array(getFixedLabel('SYSTEM_DESCRIPTION'), 'system_setup');
	$SettingsBlocks = getSettingsBlocks();
	$SettingsFields = getSettingsFields();
	foreach($SettingsFields as $blockid){
		$block_arr[] = $blockid;
	}
	foreach($SettingsBlocks as $blockid){
		if(!in_array($blockid,$block_arr)){
			unset($SettingsBlocks[$blockid]);
		}
	}
	$SettingsBlocks = array_keys($SettingsBlocks);
	$smarty->assign('blockidsetting',$SettingsBlocks[0]);
	$smarty->assign('fieldidsetting',$SettingsFields[$SettingsBlocks[0]][0]['fieldid']);
}
$smarty->assign("QUICKACCESS",$parenttablist);*/

$smarty->assign('ISADMIN',$current_user->is_admin);

/*显示小程序扫码界面 editor:gyq_83 reason:微信小程序账号绑定及扫码 2018/10/16 15:49
$sql_wx_config='select switch from ld_wx_config where name=?';
$result_wx_config = $adb->pquery($sql_wx_config, array('wechat_miniprogram_setting'));
$switch_wx_config = $adb->query_result($result_wx_config,0,'switch');
$smarty->assign('SWITCHWXCONFIG',$switch_wx_config);
*/

$quickcreatemodules = getQuickCreateModules();
$quickcreatemodules_all = [];
foreach ($quickcreatemodules as $info){
    $quickcreatemodules_all[] = $info[1];  //快速创建默认全部模块
}
crm_load_class_file('MenuUtils','modules/Users');
$MenuUtilsObj = new MenuUtils();
$moduleIconArr = $MenuUtilsObj->getTabModuleIconArr();

//@edit:liushuai,2020-12-29,reason:【ID1001225】快速创建增加设置按钮，可设置快速创建显示的模块
$quickcreate_sql = "select quickcreatemodules from ld_users where id=?"; //为空显示全部模块（初始化），为none不显示任何模块(清空)
$quickcreate_result=$adb->pquery($quickcreate_sql,array($current_user->id));
if ($adb->num_rows($quickcreate_result) > 0) {
    $quickmodules=$adb->query_result($quickcreate_result, 0, 0);
    $tmpquickcreatemodules='';

    if(isset($quickmodules))
        $tmpquickcreatemodules = trim(trim($quickmodules, ','));
    if ($tmpquickcreatemodules == '') {
        $tmpquickcreatemodules_arr = $quickcreatemodules_all;
    } else if ($tmpquickcreatemodules == 'none') {
        $tmpquickcreatemodules_arr = array();
    } else if ($tmpquickcreatemodules != '' && $tmpquickcreatemodules != 'none') {
        $tmpquickcreatemodules_arr = explode(',', $tmpquickcreatemodules);
    }
    $_SESSION['__UnifiedQuickcreate_SelectedModules__'] = $tmpquickcreatemodules_arr;
    $_REQUEST['quickcreate_onlyin'] = implode(',', $tmpquickcreatemodules_arr);
}

$quickcreate = [];
foreach($quickcreatemodules as $info){
	$quickmodule = $info[1];
    if (!in_array($quickmodule, $tmpquickcreatemodules_arr)) {  //当前用户权限范围内 去掉未选择快速创建的模块
        continue;
    }
	if(get_file_address($quickmodule,'ProductDetails') && $quickmodule != 'ServiceCharge'){
		$edit = 1;	//带产品分录明细
	}else if(get_file_address($quickmodule,$quickmodule.'DetailFieldsHtml')){
		$edit = 3;	//带明细
	}
	else{
		$edit = 2;
	}
	if($quickmodule == 'Accounts'){
		crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
		$cls_PublicAccounts = new cls_PublicAccounts($currentModule);
		$public_account = $cls_PublicAccounts->getPublicAccountConfig();
		$create_commonaccount = $public_account['is_commonaccount_create'];	//是否允许创建普通客户
		if($create_commonaccount == 'no'&&$public_account['status'] == 'yes'){
			continue;
		}
	}
    if($quickmodule == 'Leads'){
        crm_load_class_file('cls_PublicLeads', 'modules/Leads');
        $cls_PublicAccounts = new cls_PublicLeads($currentModule);
        $public_account = $cls_PublicAccounts->getPublicAccountConfig();
        $create_commonaccount = $public_account['is_commonaccount_create'];	//是否允许创建普通线索
        if($create_commonaccount == 'no'&&$public_account['status'] == 'yes'){
            continue;
        }
    }
    //快速创建时，用来判断是否自定义表弟模块
    $havacustomform = 'no';
    if(strpos($quickmodule,'CustomForm') !==false){
        $havacustomform = 'yes';
    }
	//ModuleDetailCreate
	$quickcreate[] = array(
		'label' => 	$info[0],
		'module' => $info[1],
		'img' => $moduleIconArr[$quickmodule],
		'edit' => $edit,
        'havacustomform'=>$havacustomform,
	);
}
$smarty->assign('QUICKCREATEMODULE',implode(',', $tmpquickcreatemodules_arr));
$smarty->assign("QUICKMODULE",$quickcreate);
$smarty->assign('QUICKMODULECNT',sizeOf($quickcreate));
//35237: 系统设置>点击级联字段设置，浏览器的title这里应该显示【系统设置】
$smarty->assign("ACTION",$_REQUEST['action']);

//获取版本信息
$smarty->assign("VERSIONINFO",$versions[$VersionNo]);
//判断电话管家是否显示 diony 2014-11-07
//editor:gyq_79 reason:系统右上角呼叫中心报表优化 2018/9/5 16:51
$callcenter_type = get_callcenter_type();

$smarty->assign("CALLLINKDISPLAY",$callcenter_type);
if (is_admin($current_user))
{
    $smarty->assign("ADMIN_LINK", "<a href='index.php?module=Settings&action=index'>".getFixedLabel('CONTROLPANEL')."</a>");
}
 if($_REQUEST['quick_query_session']==1)
 {
    //快速查找-》点击明细->点击"返回列表"按钮
    $_REQUEST['query_string']=getSession('quick_query_session');
 }
/*if($_REQUEST['query_string'] != '')
	$smarty->assign("QUERY_STRING",htmlspecialchars($_REQUEST['query_string'],ENT_QUOTES,$default_charset));//BUGIX " Cross-Site-Scripting "
else*/
	$smarty->assign("QUERY_STRING",getFixedLabel('QUICKFIND'));
//global $module_menu;
/*
edit:cdw
date:20130709
reason:0004410: 子菜单栏中模块被选中后模块名称应该要加粗，写报告、看报告、邮件管理、群发邮件点击后没有加粗
*/
if($_REQUEST['reporttype']!='')
{
    $smarty->assign("reporttype",$_REQUEST['reporttype']);
}



$smarty->assign("BODYBWIDTH",$_SESSION['bodywidth']);

//$tracFocus=new Tracker();
//$list = $tracFocus->get_recently_viewed($current_user->id);
//$smarty->assign("TRACINFO",$list);

$hdrcustomlink_params = Array('MODULE'=>$currentModule);

// END

// Pass on the version information
global $lingdang_current_version;
$smarty->assign('VERSION', $lingdang_current_version);
// END
if($current_user->user_type == 'prm'){
    $logoInfo = $MenuUtilsObj->getPRMlogoname();
    $smarty->assign("LOGO",$logoInfo);
    $account_name = $MenuUtilsObj->getPRMAccountName();
    $smarty->assign("ACCOUNTNAME",$account_name);
}
else{
    $logoInfo = $MenuUtilsObj->getorganizationdetailslogo();
    $smarty->assign('MENUSTYLE',$logoInfo['MENUSTYLE']);
    $smarty->assign("LOGO",$logoInfo['LOGO']);
    $smarty->assign("SMALLLOGO",$logoInfo['SMALLLOGO']);
}

if(getSession('hantianlogin')=='yes'){
    $smarty->assign("HANTIANLOGIN",'yes');
    unsetSession('hantianlogin');
}
$smarty->assign('RANDNUM',strtotime(date("Y-m-d H:i:s")));
//zxm 20230828 获取客户授权信息直接调用缓存 不查数据库
$tradeinfo = getVersionTradeInfo();
$smarty->assign('trade_version',$tradeinfo['trade']);
$smarty->assign('account_version',$tradeinfo['account']);
/**
 * 审批中心数量，使用sock异步传输机制获取审批中心数量
 * 每次获取的数量都是上次计算的结果
 * @project PROT58 审批中心数量加载速度优化
 * @author Tujt 2014-08-04
 */

require_once(globalStatic::$root_directory.'modules/Reminds/static_reminds.php');

$smarty->assign('REMINDSINFO',static_Reminds::getRemindsContent());//20230609 liushuai 消息内容刷新页面就初始化了


/***
更新操作
edit：cdw
date：20131209
reason：0006122: 工作台->邮件管理，浏览器页签标题错误。
**/
if(isset($_REQUEST['action']) && $_REQUEST['action']=='GroupEmail')
{
    $smarty->assign("name",$_REQUEST['action']);
}

if(isset($_REQUEST['action']) && $_REQUEST['action']=='UnifiedSearch')
{
    $smarty->assign("name",$_REQUEST['action']);
}
if(isset($_REQUEST['action']) && $_REQUEST['action']=='index' && $currentModule == 'Emails')
{
    $smarty->assign("name",$_REQUEST['action']);
}
if(isset($_REQUEST['action']) && $_REQUEST['action']=='CallButler' && $currentModule == 'Users')
{
    $smarty->assign("name",'CallButler');
}
$smarty->assign('ACTION_NAME',$_REQUEST['action']);
if(isset($_REQUEST['groupEmail']))
{
    $smarty->assign("groupEmail",$_REQUEST['groupEmail']);
}

/***
更新操作
edit：diony
date：20140825
reason：在线帮助数组建立并传值
**/

$moduleaction = array(
    'Settings' => array('MultiApproveList'=>'multiapprove','EditMultiApproveList'=>'multiapprove','EditMultiApprove'=>'multiapprove',
                        'TemplateprintList'=>'templateprint','TemplatePrintDetail'=>'templateprint','createtemplatePrint'=>'templateprint')
    
);
//菜单背景色
$menustyleinfo = $MenuUtilsObj->getHeaderMenuColor();
$smarty->assign("MENUSTYLEINFO",$menustyleinfo);


if($currentModule == 'OftenUseReport')
{
    global $adb;
    $sql='select name from ld_usereport where usereportid=? limit 1';
    $result=$adb->pquery($sql,array($_REQUEST['UseReport']));
    if($adb->num_rows($result) > 0){
       $userreportname=$adb->query_result($result,0,'name');
       if(file_exists("LineHelp/OftenUseReport/$userreportname.html")){
            $link = 'LineHelp/OftenUseReport/'.$userreportname.'.html';
            $smarty->assign("ONLINEHELP",$link);
            $smarty->assign("LINESTATUS",'yes');
        }
    }
}
else if($currentModule == 'Settings')
{
    $value = $moduleaction[$currentModule][$action];
    if(!empty($value)){
        $link = 'LineHelp/'.$currentModule.'/'.$value.'.html';
        $smarty->assign("ONLINEHELP",$link);
        $smarty->assign("LINESTATUS",'yes');
    }
}else if($currentModule == 'ReportLog')
{
    if(($_REQUEST['Look']== 'look' || $_REQUEST['look']== 'look')&& file_exists("LineHelp/ReportLog/lookreportlog.html")){
            $link = 'LineHelp/ReportLog/lookreportlog.html';
        }
    else{
        $link = 'LineHelp/ReportLog/writereportlog.html';
           
    }
    $smarty->assign("ONLINEHELP",$link);
    $smarty->assign("LINESTATUS",'yes');
}
else{
    $helpname = strtolower($action);
    if($helpname=='listview')//22777: 序时簿界面，点击【创建分类】后，返回序时簿界面：【帮助】按钮不显示了
        $helpname='index';
    if($helpname == 'customview'){
        if(file_exists("LineHelp/CustomView/$helpname.html")){
            $link = 'LineHelp/CustomView/customview.html';
            $smarty->assign("ONLINEHELP",$link);
            $smarty->assign("LINESTATUS",'yes');
        }
    }else{
        if(file_exists("LineHelp/$currentModule/$helpname.html")){
            $link = 'LineHelp/'.$currentModule.'/'.$helpname.'.html';
            $smarty->assign("ONLINEHELP",$link);
            $smarty->assign("LINESTATUS",'yes');
        }
    }
}
if($common_version['oem_crm']=='no')//不是oem包
{
    $systems_deploy=getSys_deploy(103);//是否隐藏帮我吧在线咨询功能,0:是
    if($systems_deploy)
        $smarty->assign("BANGWO8_LINEHELPJS", '111');
        //22776: 进入界面，右上角没有显示[帮助]按钮
     $smarty->assign("LINESTATUS",'yes');
    $smarty->assign("ONLINEHELP",$common_version['linehelp']);
}
else
{
    $smarty->assign("BANGWO8_LINEHELPJS",0);
} 
$imagecompress_values=    getSys_deploy(165);//设置网页端上传图片时是否压缩,0:压缩
$smarty->assign("IMAGECOMPRESS",$imagecompress_values['deploy_value']);

if($RegisterVersionNo==58)//客户001迷你版
{
    $moduleaction = array();
     $smarty->assign("LINESTATUS",'no');
}
global $upload_maxsize;
if(empty($upload_maxsize))
{
    $smarty->assign("UPLOADFILEMAXSIZE",2000000);
}
else
$smarty->assign("UPLOADFILEMAXSIZE",$upload_maxsize);

$smarty->assign('OEM_CRM',$common_version['oem_crm']);

/*require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
$iskehu001=isKehu001ServerPc();
$smarty->assign("iskehu001",isKehu001ServerPc());
$wx_agentid="";
$wx_corpid="";
$nonceStr="";
$timestamp="";
$agent_signature="";
$signature="";
$jsapi_string="";
$agentjsapi_string="";

if($iskehu001=='yes')
{
    $wx_authinfo=doCorpInfo("get_auth_info",array());
    
    if($wx_authinfo!=''){
      $wx_auth_arr=  json_decode($wx_authinfo,true);
      $wx_agentid=$wx_auth_arr['crm']['auth_info']['agent'][0]['agentid'];
      $wx_corpid=$wx_auth_arr['crm']['auth_corp_info']['corpid'];
    }
   
    
    crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
    $port_obj = new cls_WeixinPort();//Eidtor:gyq_63 Reason:接口支持多应用管理 Date:2018/3/2 0002 下午 1:21
    
    $agentjsapi_ticket = $port_obj->getAgentJsApiTicket();
    $jsapi_ticket=$port_obj->getJsApiTicket();
    
    $http_html_url=GetCurUrl();
    $timestamp = time() ;
    
            //$nonceStr = StaticConst::$sWxConfig['noncestr'];
    $nonceStr =getRandChar(16);
    
    $agentjsapi_string = "jsapi_ticket=" . $agentjsapi_ticket . "&noncestr=" . $nonceStr . "&timestamp=" . $timestamp . "&url=".$http_html_url;
    $jsapi_string = "jsapi_ticket=" . $jsapi_ticket . "&noncestr=" . $nonceStr . "&timestamp=" . $timestamp . "&url=".$http_html_url;
    
    
    $agent_signature = sha1($agentjsapi_string);
    $signature = sha1($jsapi_string);
    
     
}
$smarty->assign("timestamp",$timestamp);
$smarty->assign("nonceStr",$nonceStr);
$smarty->assign("agentsignature",$agent_signature);
$smarty->assign("signature",$signature);
$smarty->assign("agentjsapi_string",$agentjsapi_string);
$smarty->assign("jsapi_string",$jsapi_string);  
$smarty->assign("wx_agentid",$wx_agentid);
$smarty->assign("wx_corpid",$wx_corpid);*/
setWxSmarty($smarty);
if(isset($global_hideleftmenu))
    $smarty->assign('global_hideleftmenu',$global_hideleftmenu);
else
    {
        $smarty->assign('global_hideleftmenu','');
    }
 $smarty->assign("PageTo_Module",'');
    $smarty->assign("PageTo_action",'');
    $smarty->assign("PageTo_record",'');
    $smarty->assign("cur_menuid",$_REQUEST['cur_menuid']);
 $smarty->assign("PageTo_MenuFile",'');
 $smarty->assign("page_addurl",'');
 $smarty->assign("Pageto_create",'');
 if($_REQUEST['pageto_module'])
 {
    $smarty->assign("PageTo_Module",$_REQUEST['pageto_module']);
    $smarty->assign("PageTo_Action",$_REQUEST['pageto_action']);
    $smarty->assign("PageTo_Record",$_REQUEST['pageto_record']);

     $page_addurl='';
     
    if(isset($_REQUEST['page_addurl']))
        $page_addurl=str_replace("\\","\\\\",$_REQUEST['page_addurl']);


    $smarty->assign("page_addurl",$page_addurl);
    $smarty->assign("Pageto_create",$_REQUEST['pageto_create']);
     $smarty->assign("view_type",$_REQUEST['view_type']);
 }
 require_once("include/cls_File.php");
 $smarty->assign("cosDirName",cls_File::getCosUploadDir());
 if($_REQUEST['pageto_menufile'])
 {
    $smarty->assign("PageTo_MenuFile",$_REQUEST['pageto_menufile']);
 }

//成员头像
$user_sql='select last_name,phone_mobile,ld_attachments.newfile_name as name,ld_attachments.path,ld_attachments.attachmentsid,
             ld_attachments.storage_location,ld_attachments.cloud_path,reader,wx_userid,ld_users.id from ld_users    
         left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
       left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid 
       where ld_users.id=?';
$result=$adb->pquery($user_sql,array($current_user->id));
if($adb->num_rows($result)>0)
{
    $userimgpath = $adb->query_result($result,0,'path');
    $userimgname = $adb->query_result($result,0,'name');
    $storage_location = $adb->query_result($result,0,'storage_location');
    $cloud_path = $adb->query_result($result,0,'cloud_path');
    if($userimgname != ''){
        if($storage_location == 'cos'){
            $image_str = $cloud_path;
        }
        else{
            $image_str = $userimgpath.$userimgname;
            $userfilepath_True = globalStatic::$root_directory.$image_str;
            //加载图片时图片错误时，显示默认图片
            if(!file_exists($userfilepath_True)||!@getimagesize($userimgpath.$userimgname)){
                $userfilepath=getDefaultAvatar($current_user->id);
            }
        }
        $image_str = 'style="background-image: url('.$image_str.');"';
    }
}
if(empty($image_str)){
    // ljj 20231201 XUQIU1000927 更换默认头像
    $userfilepath=getDefaultAvatar($current_user->id);
    $image_str = 'style="background-image: url('.$userfilepath.');"';
}
$smarty->assign("IMGSTR",$image_str);

//水印  edit：杨彬阳 2022.12.14
$watermark_txt = $MenuUtilsObj->getwatermark_setting();
$smarty->assign("watermark_txt",$watermark_txt);



// wym 240126 BUG20240122-35 客户001没有名片接口，应该去掉右上角的电子名片
if(isKehu001ServerPc() == 'yes'){
    $deploy_value = 'no';
}else{
    //添加是否显示电子名片按钮的判断  2021-0220 zxm  20230829 改成调用函数
    $systems_deploy = getSys_deploy(270);
    $deploy_value = $systems_deploy['deploy_value']==0?'yes':'no';
}
$smarty->assign("isCardOpen",$deploy_value);

$regop=RegOp::getInstance();

$servicehelp=$regop->getservicehelp_interface();
if($servicehelp!=0){
     $smarty->assign("isServiceOpen",'yes');
}else{
    $smarty->assign("isServiceOpen",'no');
}
//添加是否显示订单小程序按钮的判断
$orderhelp=$regop->getorder_smallinterface();
if($orderhelp!=0){
     $smarty->assign("isOrderOpen",'yes');
}else{
    $smarty->assign("isOrderOpen",'no');
}
//wym 商城小程序 原本判断用户是否授权商城小程序，现只判断商城模块是否开启
if(vtlib_isModuleactive('ShopSettings')){
    $smarty->assign("isShopOpen",'yes');
}else{
    $smarty->assign("isShopOpen",'no');
}

//@edit:liushuai,2021-05-26,reason:【ID1001533】呼叫中心接口设置，增加接口类型“灵当语音盒”(是否连接语音盒)
$deployarray = getSys_deploy(55);//获取系统参数设定
$isOpenYiwei = 'no';
if (is_string($deployarray['deploy_value'])&&$deployarray['deploy_value'] == '灵当语音盒') {
    $isOpenYiwei = 'yes';
}
$smarty->assign("isOpenYiwei", $isOpenYiwei);
//浏览器缓存
$sysdeploy_357 = getSys_deploy('357');
$isOpenlocalStorage = (empty($sysdeploy_357) || $sysdeploy_357['deploy_value']==1)?'no':'yes';
$smarty->assign("isOpenlocalStorage", $isOpenlocalStorage);
if ($isOpenlocalStorage == 'yes' && empty($localStorageTime)) {
    $localStorageTime = 5;//默认5
}
$smarty->assign("localStorageTime", $localStorageTime);//config.inc.php
//云星空库存查询
$search_stock_view = getErpStockView();
//240506 wym XUQIU1002419 总库存数量字段不可见时，隐藏查看库存按钮；目前这个参数只在编辑页判断是否显示库存按钮，所以直接修改值，如果对其他功能有影响再考虑其他方法。
$profocus=CRMEntity::getInstance("Products");
$qtyinstock_fieldinfo = $profocus->fieldobj->getFieldInfoobjBykey('fieldname','qtyinstock');//不存在说明总库存数量未启用或者角色权限不可见
if(empty($qtyinstock_fieldinfo)){
    $search_stock_view='no';//wym 目前这个参数只在编辑页判断是否显示库存按钮，所以根据总库存数量是否可见对其修改了值，如果对其他功能有影响再考虑其他方法。
}
$smarty->assign("search_stock_view", $search_stock_view);
$smarty->assign("from_login_type",$_SESSION['from_login_type']);
//zkt 增加全局变量，用户字段
$user_uitype_arr = Field::getUseField_arr();
$smarty->assign("user_uitype_arr",json_encode($user_uitype_arr));

$versiontrade=getVersionTradeInfo();
$trade = $versiontrade['trade'];
$smarty->assign("trade",$trade);
$smarty->assign("versionaccount",$versiontrade['account']);//客户名称

// ljj 20231207 XUQIU1002271 系统PC端头部处可设置
function setHeaderSettingShow($key,$current_user)
{
    // 拼接获取生效范围字段关键字
    $keyScope = $key.'Scope';
    // 获取生效范围字段
    $contentScope=getUsersettingByLabel('Header','-1',$keyScope);
    if($contentScope=='single'){
        // 获取个人生效时参数设置
        $contentSingle=getUsersettingByLabel('Header',$current_user->id,$key);
        if (empty($contentSingle) || $contentSingle == 'undefined'){
            $contentSingle='all';
        }
        return $contentSingle;
    }else{
        // 获取全员生效时参数设置
        $contentAll=getUsersettingByLabel('Header','-1',$key);
        if (empty($contentAll) || $contentAll == 'undefined'){
            $contentAll='all';
        }
        return $contentAll;
    }
}
// 数据库中字段=》tpl文件中的字段，通过数据库的值设置tpl中select中的选项
$headersetting_arr=array(
    'QucikFindSetting'=>'quickfindsetting',
    'QucikCreateSetting'=>"quickcreatesetting",
    'HelpManualSetting'=>'helpmanualsetting',
    'ApproveRemindSetting'=>'approvalremindsetting',
    'UserInfoSetting'=>'userinfosetting');
// 遍历上面集合，通过setHeaderSettingShow函数查询数据库中记录select状态
foreach ($headersetting_arr as $key => $value){
    $smarty->assign($value,setHeaderSettingShow($key,$current_user));
}

$sysdep476 = getSys_deploy(476);

//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpUrlArr = array();
//帮助总入口，后台设置帮助
$labels = array('AllHelp','SettingsHelp');
foreach($labels as $label){
    $helpUrlArr[$label] = getHelpUrlByLabel('Header',1,'HelpUrl_'.$label);
}
$smarty->assign("HelpUrl", $helpUrlArr);

$smarty->assign('MENUTYPE',$sysdep476['deploy_value']);

$smarty->assign('CURRENT_USER',$current_user);
//dump($current_user->user_type);
if($_REQUEST['pageto_module'] && $_REQUEST['pageto_module'] == 'Settings' && ($_REQUEST['pageto_action'] != 'loginpolicy' && $_REQUEST['pageto_action'] != 'listroles')){
    $smarty->assign('module','Settings');
    $smarty->assign('BROWSETITLE',getFixedLabel('SYSTEM_DESCRIPTION'));
    $smarty->assign('BACKENDSETTINGS','yes');
}
$popupbuttontype = getSys_deploy(488);
if(is_array($popupbuttontype))
    $smarty->assign("popupbuttontype", $popupbuttontype['deploy_value']);
else
    $smarty->assign("popupbuttontype", "");
$smarty->display("LeftMenu.tpl");

function setBodyWidth($bodywidth)
{
    setSession('bodywidth',$bodywidth);
    
}

//edit:duan 复制缓存文件到新的目录下，过两个版本才删除文件
function ChangeCachepath(){
    //为了避免更新后报错，需要转移缓存文件
    //缓存文件不存在时，重新生成
	if(!file_exists('dataCache/tabdatas/tab_language.php')){
        require_once('include/utils/SystemCache.php');
       
        SystemCache::create_tab_language();
    }
   	if(!file_exists('dataCache/tabdatas/tabdata.php')){
        require_once('include/utils/SystemCache.php');
       
        SystemCache::create_tab_data_file();
    }
    if(!file_exists('dataCache/tabdatas/parent_language.php')){
        require_once('include/utils/SystemCache.php');
       
        SystemCache::create_parent_language();
    }
    if(!file_exists('dataCache/tabdatas/parent_tabdata.php')){
        require_once('include/utils/SystemCache.php');
       
       SystemCache::create_parenttab_data_file();
    }
     
       
    $old2new_filename=array(
                            'LoginSettingsInfo.php'=>'dataCache/Login/LoginSettingsInfo.php',
                           
                       
                            );    
    foreach($old2new_filename as $pre_file=>$post_file){
        if(file_exists($pre_file)&&!file_exists($post_file)){
          
            copy($pre_file,$post_file);
        }
    }
}

?>

<?php
if(issetSession('bodywidth'))
    $bodywidth=intval(getSession('bodywidth'));

if(empty($bodywidth))
{
    $bodywidth=1360;
     setBodyWidth($bodywidth);
}


