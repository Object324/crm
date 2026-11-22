<?php
global $versions;
require_once(globalStatic::$root_directory."Register/RegOp.php");
 global $current_user;
 global $adb;

$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='LoginSettings';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
$reg=RegOp::getInstance();
$VersionNo=$reg->GetVersionNo();
if(isSearchCRMVersion()=='yes')
{
    require_once(globalStatic::$root_directory."include/language/zh_cn_search_version.lang.php");
}
else
{
    if(file_exists(globalStatic::$root_directory."dataCache/Login/zh_cn_version_new.lang.php")){
        require_once(globalStatic::$root_directory."dataCache/Login/zh_cn_version_new.lang.php");
    }else{
        require_once(globalStatic::$root_directory."include/language/zh_cn_version.lang.php");
    }
}
require_once(globalstatic::$root_directory."dataCache/Login/LoginSettingsInfo.php");
global $current_user;
$languageType= getLanguageType($current_user);
$smarty=new lingdangCRM_Smarty();

//恢复默认logo与小logo
$sql = 'select * from ld_organizationdetails limit 1';
$result = $adb->pquery($sql, array());
if($_REQUEST['restorelogo_login'] == 'true'){
    $organization_id = $adb->query_result($result,0,'organization_id');
    $sql = 'update ld_organizationdetails set logoname = "",small_logoname="" where organization_id = ?';
    $adb->pquery($sql, array($organization_id));
}
//读取自定义图片logo所在路径
$file_logo = $adb->query_result($result,0,'logoname');
$file_minilogo = $adb->query_result($result,0,'small_logoname');
//wym 原先存在ld_organizationdetails表中,现在修改成在ld_module_setting_byuser表里,如果新表没数据则取老表的数据
$menustyle = getUsersettingByLabel('notbymodule',$current_user->id,'Menustyle');
if($menustyle){
    if($menustyle=='custom')
        $menufont=getUsersettingByLabel('notbymodule',$current_user->id,'Menufont_color');
}else{
    $menustyle = decode_html($adb->query_result($result,0,'menustyle'));
}
if(empty($file_minilogo)){
    //浅色菜单模式
    if($menustyle == 'lightcolour' || $menufont=='black'){
       $file_minilogo = 'logo_mini_light_0721.png';
    }
    else{
        $file_minilogo = 'logo_mini_dark_0721.png';
    }
}
if(empty($file_logo)){
    //浅色菜单模式
    if($menustyle == 'lightcolour' || $menufont=='black'){
       $file_logo = 'logo_big_light_0721.png';
    }
    else{
        $file_logo = 'logo_big_dark_0721.png';
    }
}

if($versions[$VersionNo]['after_zh_title']=='')
{
    $versions[$VersionNo]['after_zh_title']=$versions[$VersionNo]['LBL_BROWSER_TITLE'];
}
if($versions[$VersionNo]['after_en_title']=='')
{
    $versions[$VersionNo]['after_en_title']=$versions[$VersionNo]['EN_LBL_BROWSER_TITLE'];
}
if($versions[$VersionNo]['titleisshow']=='')
{
    $versions[$VersionNo]['titleisshow']='yes';
}
$smarty->assign("VERSIONINFO",$versions[$VersionNo]);
global $global_login_wxbtn;
if(empty($global_login_wxbtn))
{
    $global_login_wxbtn=array('zh'=>"企业微信登录",'en'=>"WeChat login",'isshow'=>'yes','after_en_content'=>"WeChat login","after_zh_content"=>"企业微信登录");
}
$smarty->assign("WXLOGINBTN",$global_login_wxbtn);
if(!array_key_exists('upgradeexplain',$global_logininfo))
{
    //'aboutweblabel'=>array('zh'=>'关于我们','en'=>'About','isshow'=>'no','isedit'=>'yes','content'=>'http://www.51mis.com/about/index.html'),
    $global_logininfo['upgradeexplain']=array('zh'=>'发版说明','en'=>'发版说明','isshow'=>'yes','isedit'=>'yes','content'=>$global_welcome['updateexplain']);
    
}

$tmp_arry_logoname=array('zh'=>'LOGO','en'=>'Logo name','isedit'=>'yes','content'=>"dataCache/test/logo/$file_logo");
$tmp_arry_minilogoname=array('zh'=>'小LOGO','en'=>'Small Logo name','isedit'=>'yes','content'=>"dataCache/test/logo/$file_minilogo");
$tmp_array = array();
//确保LOGO名称，小LOGO名称排在发版说明前面
foreach($global_logininfo as $tmp_key =>$tmp_value ){
    if($tmp_key == 'upgradeexplain'){
        $tmp_array['logoname'] = $tmp_arry_logoname;
        $tmp_array['minilogoname'] = $tmp_arry_minilogoname;
    }
    $tmp_array[$tmp_key] = $tmp_value;
}
$global_logininfo = $tmp_array;

$arr['logoname'] =$file_logo;
$arr['minilogoname'] =$file_minilogo ;
 if(!array_key_exists('after_zh_content',$global_welcome))
 {
    $global_welcome['isshow']='yes';
    $global_welcome['isedit']='yes';
    $global_welcome['after_zh_content']=$global_welcome['zh'];
    $global_welcome['after_en_content']=$global_welcome['en'];
 }


//frank 查看版权所有可否更改的授权
if(method_exists($reg,'getCopyRightModify'))
    $copyrightmodify=$reg->getCopyRightModify();
$global_logininfo['copyrightinfo']['isedit']='no';
if($copyrightmodify=='1'){
    // $global_logininfo['copyrightinfo']['isedit']='yes';
    if(!isset($global_logininfo['copyrightinfo']['content']) || $global_logininfo['copyrightinfo']['content']=='' || empty($global_logininfo['copyrightinfo']['content'])){
        $global_logininfo['copyrightinfo'] = array('zh'=>'版权所有','en'=>'Copyright','isedit'=>'no','content'=>'上海灵当信息科技有限公司');
    }else{
        //$global_logininfo['copyrightinfo']['isshow']='yes';
        unset($global_logininfo['copyrightinfo']['isshow']);

    }
}
else{
    // $global_logininfo['copyrightinfo']['isedit']='no';

    if(!isset($global_logininfo['copyrightinfo']['content']) || $global_logininfo['copyrightinfo']['content']=='' || empty($global_logininfo['copyrightinfo']['content'])){
        $global_logininfo['copyrightinfo'] = array('zh'=>'版权所有','en'=>'Copyright', 'isedit'=>'no','content'=>'上海灵当信息科技有限公司');
    }else{
        unset($global_logininfo['copyrightinfo']['isshow']);
    }
}

foreach($global_logininfo as $key=>$content)
{
   
    if($key=='QQ'||$key=='weixin')
    {
        continue;
    }
     else if($key=='autheninfo'&&$reg->getauthenshow()=='no')
     {
        continue;
     }
    $tmp[$key]=$content;

}

$historylogin = getUsersettingByLabel('Settings',1,'historyloginui');
if($historylogin == 'new'){
    unset($tmp['backgroundbg']);
    unset($tmp['aboutweblabel']);
    unset($tmp['resolution']);
    unset($tmp['loginlocation']);
}


$smarty->assign("authenshow",$reg->getauthenshow());

$smarty->assign("LOGINIFO",$tmp);
$smarty->assign("LANGUAGETYPE",$languageType);
$smarty->assign("SERVERURL",'http://www.'.$_SERVER['HTTP_HOST'].$_SERVER['PHP_SELF'].'?');
$smarty->assign("GLOBALLOGINPAGEURL",$global_loginpage_url);
$smarty->assign("GLOBAL_WELCOME",$global_welcome);
// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
if($_REQUEST['ajax']=='yes')
{
    
    $arr['content']= $smarty->fetch('LoginSettings/DisplayDetailView.tpl');
}
else
    $arr['content']= $smarty->fetch('LoginSettings/DetailView.tpl');
ConvertTojsonString(1,$arr,"success");
?>