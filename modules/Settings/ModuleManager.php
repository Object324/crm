<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

include_once('vtlib/lingdang/Utils.php');
global $current_user,$adb;
if($_REQUEST['formodule']!='' && $_REQUEST['formodule']!='undefined')
{
    //模块查看界面点击页面设置
    $_REQUEST['ajax'] ='yes';
    include(globalStatic::$root_directory.'modules/Settings/LayoutBlockList.php');
}
if($_REQUEST['module_settings'] == 'true') {
    $targetmodule = $_REQUEST['formodule'];

    $targetSettingPage = "modules/$targetmodule/Settings.php";
    if(file_exists($targetSettingPage)) {
        lingdang_Utils::checkFileAccessForInclusion($targetSettingPage);
        require_once($targetSettingPage);
    }
}
else{
    $modulemanager_uploaddir = 'dataCache/test/vtlib';

    if($_REQUEST['module_import'] != '') {
        require_once('modules/Settings/ModuleManager/Import.php');
        exit;
    } else if($_REQUEST['module_update'] != '') {
        require_once('modules/Settings/ModuleManager/Update.php');
        exit;
    } else if($_REQUEST['module_import_cancel'] == 'true') {
        $uploadfile = $_REQUEST['module_import_file'];
        $uploadfilename = "$modulemanager_uploaddir/$uploadfile";
        checkFileAccess($uploadfilename);
        if(file_exists($uploadfilename)) unlink($uploadfilename);
    }

//	require_once('Smarty_setup.php');

    global $mod_strings,$app_strings,$theme;
    $smarty = new lingdangCRM_Smarty;
    $smarty->assign("MOD",$mod_strings);

    $smarty->assign("APP",$app_strings);
    $smarty->assign("THEME", $theme);
    $smarty->assign("IMAGE_PATH", "themes/$theme/images/");

    $module_disable = $_REQUEST['module_disable'];
    $module_name = $_REQUEST['module_name'];
    $module_enable = $_REQUEST['module_enable'];
    $module_type = $_REQUEST['module_type'];

    if($module_name != '') {


        if($module_enable == 'true') vtlib_toggleModuleAccess($module_name, true);
        //关闭模块
        if($module_disable== 'true') vtlib_toggleModuleAccess($module_name, false);

        // edit: xll 2024/10/10 BUG20241009-71 价格政策开关，产品总价、累计优惠字段也随之开关
        if($module_name === 'PricePolicy') {
            $presence = $module_enable == 'true' ? '0' : '1';
            $sql = "UPDATE ld_producttoolfield SET presence = ? WHERE columnname IN ('product_licence_price','cumulative_benefits');";
            $adb->pquery($sql, [$presence]);
        }

        clearCacheFiles();

        unsetCacheDirectory('productfields');
        unsetCacheDirectory('fields');
        unsetCacheDirectory('profile');

        //zxm 20230901 修改模块名称需要把拼音模糊搜索的缓存清除掉
        unsetCache('pinyinAlllabel_zh');
        unsetCache('pinyinAlllabel_en');
        unsetCache('getTabModuleIconArr');

        @unlink('include/language/zh.php');
        @unlink('include/language/en.php');
        @unlink('include/language/zh.js');
        @unlink('include/language/en.js');
    }
    //29707: 关闭联系人模块后，系统参数“设置客户明细界面是否显示首要联系人”会不显示。但是客户模块还是显示首要联系人。
    if($module_name == 'Contacts'){
        if($module_enable == 'true'){
            $presence = 0;
        }
        if($module_disable == 'true'){
            $presence = 1;
        }
        $query = 'update ld_systems_deploy set presence = ? where deploy_type = ?';
        $adb->pquery($query,array($presence,72));

        $query = "update ld_blocks set visible = ? where tabid = 6 and blocklabel = 'LBL_ACCOUNT_PRIMARYCONTACT'";
        $adb->pquery($query,array($presence));

        //联系人模块关闭，单据详情相关信息联系人图谱关闭
        $query = 'update ld_relatedlists set presence = ? where related_tabid = ?';
        $adb->pquery($query,array($presence,-18));
    }
    /**
     *@andy:
     *@date:20140819
     *@version:v5.61
     *@reason:编辑模块中英文名称
     */
    $_REQUEST['diony']='yes';
    if(isset($_REQUEST['actionmodle']) && $_REQUEST['actionmodle'] != '' )
    {
        $module=trim($_REQUEST['actionmodle']);
        //zxm 2021-1206 上传菜单图标
        $error_msg = '';
        if(isset($_FILES['active_icon'])){
            $active_icon = iconUpload('active_icon',$module);
            $ret_arr['active_icon'] = $active_icon['filepath'];
            $filepath = $active_icon['filepath'];

            if(!empty($active_icon['errorInfo'])){
                $error_msg = '图标上传失败：'.$active_icon['errorInfo'];
                ConvertTojsonString(-1,array(),$error_msg);
            }
            $update_tab_sql = "update ld_tab set active_icon=? where name=?";
            $update_tab_res = $adb->pquery($update_tab_sql,array($filepath,$module));
        }
        $modulenename_zh=trim($_REQUEST['modulenename_zh']);
        $modulenename_en=trim($_REQUEST['modulenename_en']);
        $updateresult = vtlib_updateModuelTranslabel($modulenename_zh,$modulenename_en,$module);
        if($updateresult==3)
        {
            // echo '###USEDZH###';
            ConvertTojsonString(-1,$ret_arr,'error');
        }
        else if($updateresult==4)
        {
            //echo '###USEDEN###';
            ConvertTojsonString(-2,$ret_arr,'error');
        }
        else
        {
            echo '###SUCCESS###';
            //exit();
        }
        //处理缓存
        create_tab_language();
        $cachekey = 'cache_getparenttabrelinfo';
        unsetCache($cachekey);
        //zxm 20230901 修改模块名称需要把拼音模糊搜索的缓存清除掉
        unsetCache('pinyinAlllabel_zh');
        unsetCache('pinyinAlllabel_en');
        unsetCache('getTabModuleIconArr');
        //36745: 设置-系统设置-模块管理改模块名称的时候要把对应缓存清掉
        @unlink('include/language/zh.php');
        @unlink('include/language/en.php');
        @unlink('include/language/zh.js');
        @unlink('include/language/en.js');
    }
    // Check write permissions on the required directories
    $dir_notwritable = Array();
    // chmod('cron/modules', 0777);
//    chmod('modules', 0777);
//    chmod('Smarty/templates/modules', 0777);
    if(!vtlib_isDirWriteable('dataCache/test/vtlib')) $dir_notwritable[] = 'dataCache/test/vtlib';
    //if(!vtlib_isDirWriteable('cron/modules')) $dir_notwritable[] = 'cron/modules';
//	if(!vtlib_isDirWriteable('modules')) $dir_notwritable[] = 'modules';
//	if(!vtlib_isDirWriteable('Smarty/templates/modules')) $dir_notwritable[] = 'Smarty/templates/modules';
//
    $smarty->assign("DIR_NOTWRITABLE_LIST", $dir_notwritable);
    // END
    //zkt 20230607 BUG0066905  kfbcrm 后台设置--模块管理---搜索不到成员管理模块（邱：页面设置中有，合并的时候丢了）
    //wym 240304 XUQIU20240218-02 新增：节假日管理模块 不需要页面设置
    $modulemanger_arr = vtlib_getToggleModuleInfo_all();
    $modulemanger_noshow_arr = array('Users','Reminds','Tooltip','ModTracker','lingdangBackup','FieldFormulas','Events','Dashboard');
    $modulesettings_noshow_arr = array('BankAccountSet','Tooltip','ModTracker','lingdangBackup','Emails','OftenUseReport','SocialPromotion','WorkReportList','Holiday');
    foreach($modulemanger_noshow_arr as $tmpmodulename){
        $tmptabid = getTabid($tmpmodulename);
        if(!empty($tmptabid)&& isset($modulemanger_arr[$tmptabid])){
            $modulemanger_arr[$tmptabid]['noshowedit'] ='yes';
        }
    }
    foreach($modulesettings_noshow_arr as $tmpmodulename){
        $tmptabid = getTabid($tmpmodulename);
        if(!empty($tmptabid)&& isset($modulemanger_arr[$tmptabid])){
            $modulemanger_arr[$tmptabid]['hassettings'] =false;
        }
    }

    //array_diff_key($modulemanger_arr,$modulesettings_arr)
    $smarty->assign("TOGGLE_MODINFO", $modulemanger_arr);
    $smarty->assign("TOGGLE_MODINFO_JSON", ldcrm_json_encode($modulemanger_arr));
    //print_r(vtlib_getToggleModuleInfo());$languageType
    $smarty->assign("languageType", $languageType);
//	$smarty->assign("TOGGLE_LANGINFO", vtlib_getToggleLanguageInfo());

    //获取帮助手册入口链接，为空则不显示
    //可能有多个帮助链接需要获取
    $helpHtmlArr = array();
    //模块管理帮助
    $labels = array('ModuleManager');
    foreach($labels as $label){
        $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
    }
    $smarty->assign("HelpHtml", $helpHtmlArr);

    if($_REQUEST['mode'] !='') $mode = $_REQUEST['mode'];
    $smarty->assign("MODE", vtlib_purify($mode));
    //echo "ajax".$_REQUEST['ajax'];

    if($_REQUEST['ajax'] == 'true')
    {
        //require_once('SetmenuControl.php');
//        $ret_arr['content']=$smarty->fetch('Settings/ModuleManager/ModuleManagerAjax.tpl');
    }
    else
    {

        $ret_arr['content']=$smarty->fetch('Settings/ModuleManager/ModuleManager.tpl');


    }
    ConvertTojsonString(1,$ret_arr,'success');
}



//icon单文件上传
function  iconUpload($fieldname,$parenttabid){
    $uploaddir = globalStatic::$root_directory ."storage/moduleIcon/";
    if(!is_dir($uploaddir)){
        mkdir($uploaddir, 0777);
    }

    $allowedExts = array("gif", "jpeg", "jpg", "png");
    FileSecurityCheck($_FILES[$fieldname]["name"]);
    $temp = explode(".", $_FILES[$fieldname]["name"]);
    $extension = end($temp);        // 获取文件后缀名
    $errorInfo = '';//错误信息
    $filename_destination = $fieldname.'_'.$parenttabid.".".$extension;
    if ((($_FILES[$fieldname]["type"] == "image/gif")
            || ($_FILES[$fieldname]["type"] == "image/jpeg")
            || ($_FILES[$fieldname]["type"] == "image/jpg")
            || ($_FILES[$fieldname]["type"] == "image/pjpeg")
            || ($_FILES[$fieldname]["type"] == "image/x-png")
            || ($_FILES[$fieldname]["type"] == "image/png"))
        && ($_FILES[$fieldname]["size"] <= 1024*1024)    // 小于 1mb
        && in_array($extension, $allowedExts))
    {
        if ($_FILES[$fieldname]["error"] > 0)
        {
            $errorInfo = $_FILES[$fieldname]["error"];
        }
        else
        {
            //echo "上传文件名: " . $_FILES["file"]["name"] . "<br>";
            //echo "文件类型: " . $_FILES["file"]["type"] . "<br>";
            //echo "文件大小: " . ($_FILES["file"]["size"] / 1024) . " kB<br>";
            //echo "文件临时存储的位置: " . $_FILES[$fieldname]["tmp_name"];
            //移动前判断文件存不存在 存在先删除
            if(file_exists($uploaddir.$filename_destination)){
                unlink($uploaddir.$filename_destination);
            }
            move_uploaded_file($_FILES[$fieldname]["tmp_name"],$uploaddir.$filename_destination);
        }
    }else if ($_FILES[$fieldname]["size"] > 1024*1024){
        $errorInfo = getFixedLabel('menuIconUploadTips');
    }else{
        $errorInfo = '文件格式不合法！';
    }
    if($errorInfo==''){
        return ['code'=>1,'filepath'=>"storage/moduleIcon/".$filename_destination];
    }else{
        return ['code'=>-1,'errorInfo'=>$errorInfo];
    }
}
function vtlib_getToggleModuleInfo_all() {
    global $adb,$current_user;

    $modinfo = Array();
    $regop=RegOp::getInstance();
    /**
     *@andy:
     *@date:20140819
     *@version:v5.61
     *@reason:编辑模块中英文名称，这里获取控制模块
     */
    $query="select ld_tab.tabid,ld_tranlabel.fieldlabel as newtabname,getpinyin(ld_tranlabel.fieldlabel) as pinyin,ld_tab.presence,ld_tab.customized,ld_tab.default_icon,ld_tab.active_icon,
    languagetype,ld_tab.description,ld_tab.name from ld_tab inner join ld_tranlabel on
    ld_tab.tabid=ld_tranlabel.relateid where
    (languagetype='zh' or languagetype='en')
    and trantable='ld_tab'  
    AND ld_tab.presence IN (0,2,5)
    GROUP BY ld_tab.tabid,languagetype,tabid
    ORDER BY ld_tab.presence,ld_tab.tabsequence";
    //echo $query;
    $result=$adb->query($query);
    $num_rows=$adb->num_rows($result);
    $alltabs=array();
    $socialpromotion=$regop->getSocialPromotion();
    $channelcodeprofile=$regop->getchannelcodeprofile();
    for($i=0;$i<$num_rows;$i++){
        $modulename=$adb->query_result($result,$i,'name');


        $tabid=$adb->query_result($result,$i,'tabid');
        if(empty($tabid)){
            continue;
        }
        $alltabs[$tabid]['noshowedit'] ='';
        if($modulename=='SocialPromotion'&&empty($socialpromotion))
        {
            $alltabs[$tabid]['noshowedit'] ='yes';
        }
        if($modulename=='ChannelCode'&&empty($channelcodeprofile))
        {
            $alltabs[$tabid]['noshowedit'] ='yes';
        }
        if($modulename=='Shopping')
        {
            $alltabs[$tabid]['noshowedit'] ='yes';
        }
        $languagetype = $adb->query_result($result,$i,'languagetype');
        $alltabs[$tabid]['presence'] = $adb->query_result($result,$i,'presence');
        $alltabs[$tabid]['customized'] = $adb->query_result($result,$i,'customized');
        $alltabs[$tabid]['default_icon'] = $adb->query_result($result,$i,'default_icon');//zxm 2021-1208 默认图标
        $alltabs[$tabid]['active_icon'] = $adb->query_result($result,$i,'active_icon');//zxm 2021-1208 自定义图标
        if(!empty($alltabs[$tabid]['active_icon'])&&file_exists(globalStatic::$root_directory.$alltabs[$tabid]['active_icon'])){
            $alltabs[$tabid]['active_icon'] = $alltabs[$tabid]['active_icon'].'?a='.rand(0,9999);
        }else{
            $alltabs[$tabid]['active_icon'] = '';
        }
        $alltabs[$tabid]['label'][$languagetype] = $adb->query_result($result,$i,'newtabname');
        $alltabs[$tabid]['label']['pinyin'] = $adb->query_result($result,$i,'pinyin');
        $alltabs[$tabid]['label']['modulename']=$adb->query_result($result,$i,'name');
        $description=$adb->query_result($result,$i,'description');
        if(!empty($description))
            $alltabs[$tabid]['description']=getFixedLabel($description) ;
        else
            $alltabs[$tabid]['description']='';

        if($modulename=='Events')
        {
            $hassettings=file_exists("modules/Calendar/Settings.php");
        }
        else
            $hassettings=file_exists("modules/$modulename/Settings.php");

        $alltabs[$tabid]['hassettings'] =$hassettings;
    }

    //echo '<pre>';
    //print_r($alltabs);
    //echo '</pre>';
    //print_r($alltabs);
    return $alltabs;
    //return $modinfo;
}
?>