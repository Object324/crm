<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
* ("License"); You may not use this file except in compliance with the License
* The Original Code is:  lingdang CRM Open Source
* The Initial Developer of the Original Code is lingdang.
* Portions created by lingdang are Copyright (C) lingdang.
* All Rights Reserved.
*
********************************************************************************/



global $app_list_strings;
global $adb;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='PhoneSteward';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
$smarty = new lingdangCRM_Smarty;


require('user_privileges/user_language_'.$current_user->id.'.php');
//editor:gyq_76 reason:呼叫中心来电弹屏增加创建销售机会 2018/8/23 13:24 
$sql="
SELECT 
T1.tabid, 
GROUP_CONCAT(T2.columnname) as columnname, 
GROUP_CONCAT(T3.fieldlabel) as fieldlabel 
FROM 
( 
SELECT tabid,tabsequence FROM ld_tab WHERE presence = 0 AND NAME IN ('Leads','Accounts','Contacts','Vendors','VendorContact','Potentials') 
) AS T1 
LEFT JOIN ( 
SELECT tabid, fieldid,columnname,block,sequence FROM ld_field WHERE uitype IN (11, 1101,1102) AND presence <> 1 and callchecked=1

 order by block ASC,sequence ASC
) AS T2 ON T1.tabid = T2.tabid 
left join ld_tranlabel as T3 on T3.tabid=T2.tabid 
and T3.relateid=T2.fieldid and T3.languagetype=? and T3.trantable=? 
group by T1.tabid
order by T1.tabsequence,T2.block ASC,T2.sequence ASC
";
/* gyq_11  按照对应模块字段block,sequence的顺序排序显示,客户模块可选字段应该去掉首先联系人字段：tablename<>'ld_contactdetails' */
$list_result = $adb->pquery($sql,array($languageType,'ld_field'));
$num_rows=$adb->num_rows($list_result);
$arr=array();
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $arr[]=array(
        'tabid'=> $adb->query_result($list_result,$i,'tabid'),
        'tabname'=> getTabname($adb->query_result($list_result,$i,'tabid')),
        'columnname'=> $adb->query_result($list_result,$i,'columnname'),
        'fieldlabel'=> $adb->query_result($list_result,$i,'fieldlabel')
        );
    }
}

$smarty->assign("RESULTLIST", $arr);
//editor:gyqX161019 Bug:024107: 控制面板>呼叫中心参数：呼叫类型为九维，思孚时，呼叫中心参数区块中只显示了“呼叫类型”字段，没有显示地址之类的字段
$deployarray = getSys_deploy(101);
$php52 = getSys_deploy(107);
$deployarray3 = getSys_deploy(121);
$htrelvalue = getSys_deploy(160);
$deployarray2 = $php52['deploy_value'];
$jiuwei_deployvalue = explode(',',$deployarray['deploy_value']);//gyq_25 date:20170209
$sopho_deployvalue = explode(',',$deployarray2);
$smarty->assign('JIUWEIURL', $jiuwei_deployvalue[0]);
$smarty->assign('CALLCENTERPREFIX', $jiuwei_deployvalue[1]);
$smarty->assign('JIUWEIURL_sopho', $sopho_deployvalue[0]);
$smarty->assign('JIUWEIURL_sopho2', $sopho_deployvalue[1]);
$smarty->assign('HANTIANURL',$deployarray3['deploy_value']);
$smarty->assign('HANTIANRELVALUE',$htrelvalue['deploy_value']);

// @edit:dong @date:2020/09/02 @reason: 天润融通 呼叫中心
$deployarray=getSys_deploy(261);
$smarty->assign('TIANRUNENTERPRISEIDVALUE',$deployarray['deploy_value']);
$deployarray=getSys_deploy(262);
$smarty->assign('TIANRUNZHANGHAOVALUE', $deployarray['deploy_value']);
$deployarray=getSys_deploy(263);
$smarty->assign('TIANRUNPASSWORDVALUE', $deployarray['deploy_value']);

// @edit:dong @date:2020/11/11 @reason: 天润融通新
$deployarray=getSys_deploy(264);
$smarty->assign('NEWTIANRUNURLVALUE',$deployarray['deploy_value']);
$deployarray=getSys_deploy(265);
$smarty->assign('NEWTIANRUNKEYIDVALUE', $deployarray['deploy_value']);
$deployarray=getSys_deploy(266);
$smarty->assign('NEWTIANRUNSECRETVALUE', $deployarray['deploy_value']);

$fieldlabel = getTranslabelSystems(264);
$smarty->assign('NEWTIANRUNINTERFACEADDRESS', $fieldlabel);
$fieldlabel = getTranslabelSystems(265);
$smarty->assign('NEWTIANRUNACCESSKEYID', $fieldlabel);
$fieldlabel = getTranslabelSystems(266);
$smarty->assign('NEWTIANRUNSECRET', $fieldlabel);


$fieldlabel = getTranslabelSystems(101);
$smarty->assign('JIUWEIURLNAME', $fieldlabel);

$fieldlabel = getTranslabelSystems(107);
$smarty->assign('JIUWEIURLNAME_sopho', $fieldlabel);

$fieldlabel = getTranslabelSystems(121);
$smarty->assign('HANTIANURLNAME', $fieldlabel);

$fieldlabel = getTranslabelSystems(160);
$smarty->assign('HANTIANRELATENAME', $fieldlabel);

// @edit:dong @date:2020/09/02 @reason: 添加天润融通旧
$fieldlabel = getTranslabelSystems(261);
$smarty->assign('TIANRUNENTERPRISEID', $fieldlabel);

$fieldlabel = getTranslabelSystems(262);
$smarty->assign('TIANRUNZHANGHAO', $fieldlabel);

$fieldlabel = getTranslabelSystems(263);
$smarty->assign('TIANRUNPASSWORD', $fieldlabel);




$deployarray=getSys_deploy(55);//呼叫中心类型
$smarty->assign("CALLCENTERVALUE", $deployarray['deploy_value']??'');
//$deployarray=getSys_deploy(76);//软拨号自动加拨前缀
//$smarty->assign('INTERFACENUM',$deployarray['deploy_value']);

//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);
$smarty->assign('LANGUAGETYPE',$languageType);

//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
//呼叫中心参数设置帮助
$labels = array('PhoneSteward');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
}
$smarty->assign("HelpHtml", $helpHtmlArr);

$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('Settings/PhoneSteward.tpl');
ConvertTojsonString(1,$arr,"success");
?>