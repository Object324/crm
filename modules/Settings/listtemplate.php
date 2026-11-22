<?php
/****************************************************
 *{*修改编码格式:统一编码：UTF-8*}
**AUTHOR:BY LD KEVIN
**DATE:20130219
**DESCRIPTION:组件模板列表
****************************************************/
global $mod_strings,$app_strings,$default_charset;

global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='listtemplate';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
$smarty = new lingdangCRM_Smarty;


$templateinfo=getAllTemplates();

$return_data=array();
foreach($templateinfo as $tempid=>$ttemplateinfo)
{
	
	$standCustFld = array();
	$standCustFld['templateid']= $tempid;	
	$standCustFld['templatename']= $ttemplateinfo[0];
	$standCustFld['rolename']= $ttemplateinfo[1];
    $standCustFld['modifiedname']= $ttemplateinfo[2];
    $standCustFld['modifiedtime']= $ttemplateinfo[3];
    $standCustFld['deleted']=$ttemplateinfo[4];
	$return_data[]=$standCustFld;
}
$list_header=array(getFixedLabel('TOOLS'),getFixedLabel('TEMLATENAME'),getFixedLabel('RELATEDROLES'),getFixedLabel('MODIFIEDBY'),getFixedLabel('MODIFIEDTIME'));
$smarty->assign('LIST_HEADER',$list_header);
$smarty->assign("LIST_ENTRIES",$return_data);

$smarty->assign('APP',$app_strings);
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign('CMOD',$mod_strings);

global $current_user;
//中英文包
require("user_privileges/user_language_".$current_user->id.'.php');
if(empty($languageType))
{
    $languageType = 'zh';
}
$smarty->assign("LANGUAGETYPE",$languageType);

//@edit:liushuai,2020-09-08,reason:【ID1000285】PC端：首页增加首页视图设置
if (isset($_REQUEST['from_module']) && $_REQUEST['from_module'] == 'home') {
    $smarty->assign("from_module",'home');
    $arr['title'] = getFixedLabel('LBL_TEMPLATES');
}

// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('ListTemplate.tpl');
ConvertTojsonString(1,$arr,"success");

function getAllTemplates(){
    global $default_charset;
	global $adb;
	$query="select ld_templates.*,ld_users.last_name as last_name,ld_users.real_name,ld_users.wx_userid from ld_templates left join ld_users on ld_users.id=ld_templates.modifiedby";
	$result = $adb->pquery($query, array());
	$num_rows=$adb->num_rows($result);
	$template_details=Array();
	$profile = new Profile();
	for($i=0;$i<$num_rows;$i++)
	{
		$tempInfo=Array();
        $roleName='';
        $deleted=$adb->query_result($result,$i,'deleted');
		$tempid=$adb->query_result($result,$i,'templateid');        
		$tempname=$adb->query_result($result,$i,'templatename');
        $query='select profileid from ld_templatesrole where templateid=? and profileid > 0';
        $resultrole=$adb->pquery($query,array($tempid));
        $num_role_rows=$adb->num_rows($resultrole);

         for($j=0;$j<$num_role_rows;$j++){
            $roleid=$adb->query_result($resultrole,$j,'profileid');
            $roleinfo = $profile->getProfileinfo($roleid);
            $roleName .= $roleinfo['profilename'].'; ';
         }
		$modifiedby=$adb->query_result($result,$i,'modifiedby');
        //判断kehu001的创建人的显示
        $last_name = $adb->query_result($result,$i,'last_name');
        $wx_userid = $adb->query_result($result,$i,'wx_userid');
        $userobj = new Users();
        $userobj->wx_userid=$wx_userid;
        $userobj->id=$modifiedby;
        $userobj->last_name=$last_name;
        $modifiedname = getUserlastName($userobj);
        $modifiedtime=$adb->query_result($result,$i,'modifiedtime');
		$tempInfo[0]=$tempname;
		$tempInfo[1]=trim($roleName,'; ');
        $tempInfo[2]=$modifiedname;
        $tempInfo[3]=$modifiedtime;
        $tempInfo[4]=$deleted;
		$template_details[$tempid]=$tempInfo;
	}
	return $template_details;
}
?>