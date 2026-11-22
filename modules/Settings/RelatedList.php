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
require_once('include/utils/UserInfoUtil.php');
require_once('include/utils/utils.php');

global $mod_strings;
global $app_strings;
global $theme;
$field_array = Array();
$presence_array = Array();
$ProId = array();
$RelArray = array();
/** gives the role info, role profile info and role user info details in an array  for the specified role id
  * @param $roleid -- role id:: Type integer
  * @returns $return_data -- array contains role info, role profile info and role user info. This array is used to construct the detail view for the specified role id :: Type varchar
  *
 */
/*
chj 2013-9-16 更多信息字段
*/
// 默认选中客户 6
if(isset($_REQUEST['tabid']))
{
    $SelectId = $_REQUEST['tabid'];
}
else
{
  $SelectId = 6;  //默认为客户
}
//下拉模块
$SqlList = 'select ld_tab.tabid,ld_tab.name from ld_profile2field inner join ld_tab on ld_tab.tabid=ld_profile2field.tabid and ld_tab.presence in (0,2) and 
ld_tab.name not in (\'Emails\',\'Faq\',\'Events\',\'Reminds\',\'InventoryAccount\',\'InventoryQuery\') group by ld_tab.tabid order by tabsequence';

$ReList=$adb->pquery($SqlList);
$Cnt = $adb->num_rows($ReList);
for($i=0; $i<$Cnt; $i++)
{
    if($adb->query_result($ReList,$i,"tabid") == 9)
    {
        $id = 16;
    }
    else
    {
        $id = $adb->query_result($ReList,$i,"tabid");
    }
    /**
     * 更新操作
     * edit:kevin
     * date:2013-11-26
     * reason:0005742: 控制面板->菜单定制，点击“编辑子模块名称”，修改子模块名称后，CRM中部分地方的子模块名称名称没有修改
     */ 
    //getfieldName(getName($adb->query_result($ReList,$i,"tabid")),'Settings'),
    $tab=getName($adb->query_result($ReList,$i,"tabid"));
    $RelArray[$i] = array(
        'rela_tabid' => $id,
        'rela_label' => getTranstab($tab),
    );
    
}
//菜单项中的列单
$field_array = getInfo(1,0,$SelectId);
//print_r($field_array);
function getName($TabId)
{
    global $adb;
    $Sql = "select `name` from ld_tab where tabid = " . $TabId;
    $Tab=$adb->pquery($Sql);
    return $adb->query_result($Tab,0,"name");
}
//$odreValue = $_REQUEST['orderType'];
//获取模块列表信息
function getInfo($Type,$Int,$Id)
{
    global $adb;
    $SqlPro = "select tabid,fieldid,width,edit from ld_relatedlists_lable where tabid = ? order by sequence asc";
    //echo $SqlPro;
    $Pro=$adb->pquery($SqlPro,array($Id));
    $num_rows = $adb->num_rows($Pro);
    for($i=0; $i<$num_rows; $i++)
    {
        $array[$i] = array(
            'tab_id'=>$adb->query_result($Pro,$i,"tabid"),
            'relatedstatus'=>1,
            'relatedname'=>getFieldListName($adb->query_result($Pro,$i,"tabid"),$adb->query_result($Pro,$i,"fieldid"),2),
            'relatedlable'=>getFieldListName($adb->query_result($Pro,$i,"tabid"),$adb->query_result($Pro,$i,"fieldid"),1),
            'relatedwidth'=>$adb->query_result($Pro,$i,"width"),
        );
        $ProId[$i] = $adb->query_result($Pro,$i,"fieldid");
    }
    $ProAllId = implode(',', $ProId);
   if(sizeof($ProAllId)>0)
        $SqlPro = "select fieldid,tabid,fieldname,fieldlabel from  ld_field where tabid =" . $Id . " and fieldid not in (".$ProAllId.") and presence in(0,2)";
    else
    /**
     * 更新操作
     * edit:can
     * date:20131230
     * reason:6602: 控制面板-更多信息字段界面：盘点、库存流水账、即时库存查询模块中字段表中没有字段名，如图
     * */
        $SqlPro = "select fieldid,tabid,fieldname,fieldlabel from  ld_field where tabid =" . $Id . "  and presence in(0,2)";
        
    $Pro=$adb->pquery($SqlPro);
    for($i=0; $i<$adb->num_rows($Pro); $i++)
    {
        $array[$i + $num_rows] = array(
            'tab_id'=>$adb->query_result($Pro,$i,"tabid"),
            'relatedstatus'=>getRelatedStatus($adb->query_result($Pro,$i,"fieldid"),$adb->query_result($Pro,$i,"tabid")),
            'relatedname'=>getFieldListName($adb->query_result($Pro,$i,"tabid"),$adb->query_result($Pro,$i,"fieldid"),2),
            'relatedlable'=>getFieldListName($adb->query_result($Pro,$i,"tabid"),$adb->query_result($Pro,$i,"fieldid"),1),
            'relatedwidth'=>0,
        );
    }
    return $array;
}
function getRelatedStatus($FieldId,$TabID)
{
    global $adb;
    $Sql = "select * from ld_relatedlists_lable where tabid = '".$TabID."' and fieldid = '".$FieldId."'";
    $Query=$adb->pquery($Sql,array());
    if($adb->num_rows($Query) > 0)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}
function getFieldListName($TabId,$FieldId,$Type)
{
    global $adb,$current_user;
    require('user_privileges/user_language_'.$current_user->id.'.php');
    $Sql = "select fieldname,ld_tranlabel.fieldlabel from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid where 
     languagetype=? and trantable=? and fieldid = " . $FieldId;
    $Query=$adb->pquery($Sql,array($languageType,'ld_field'));
    $label = $adb->query_result($Query,0,"fieldlabel");
    if( $label == 'Date & Time Sent')
    {
        $label = 'Date Sent';
    }
    if($Type == 1)
    {
        return $adb->query_result($Query,0,"fieldlabel");   
    }
    else
    {
        $Sql = "select name from ld_tab where tabid = ?";
        $result=$adb->pquery($Sql,array($TabId));
        return getTranstab($adb->query_result($result,0,"name"));
    }
}
function getfieldName($FieldName,$Name)
{
    $language_strings = return_module_language($current_language,$Name);
    if($language_strings[$FieldName] != null)
    {
        return $language_strings[$FieldName];
    }
    else
    {
        return $FieldName;
    }
}
//print_r($field_array);
 //加载语言

//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("APP", $app_strings);
$smarty->assign("FIELDARRAY", $field_array);
$smarty->assign("FIE", $presence_array);
$smarty->assign("THEME", $theme);
$smarty->assign("List", $RelArray);

$smarty->assign("SelectId", $SelectId);
$smarty->display("RelatedList.tpl");
?>