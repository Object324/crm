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
$field_array = Array();
$presence_array = Array();
$ProId = array();
/** gives the role info, role profile info and role user info details in an array  for the specified role id
  * @param $roleid -- role id:: Type integer
  * @returns $return_data -- array contains role info, role profile info and role user info. This array is used to construct the detail view for the specified role id :: Type varchar
  *
 */
//$odreValue = $_REQUEST['orderType'];
$TabId = $_REQUEST['selected_id'];
//获取产品模块信息
if ($_REQUEST['fstatus']==null)
{
    $Status = getStau($TabId);  
}else
{
    if(getStau($TabId) != null)
        $Status = array_merge(getStau($TabId),$_REQUEST['fstatus']);
    else
        $Status = $_REQUEST['fstatus'];
}
$Width = $_REQUEST['width'];
$Id = $_REQUEST['fieldid'];
if($Status != null && $Width != null)
{
    $AllId = implode(',', $Status);
    $adb->pquery("delete from ld_relatedlists_lable where tabid = '".$TabId."' and edit = 0");
    for($i = 0; $i<count($Status); $i++)
    {
        // 判断是否存在
        $Sql = $adb->pquery("select * from ld_relatedlists_lable where tabid = '".$TabId."' and fieldid = " . $Status[$i]);
        if($adb->num_rows($Sql)<=0)
        {
            $MaxOrder = getMaxOrder($TabId) + $i;
            $adb->pquery("insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence) values 
                    (".$TabId.",".$Status[$i].",$MaxOrder,1)");
        }
    }
    for($j = 0; $j<count($Id); $j++)
    {
        // 判断是否存在
        $Sql = $adb->pquery("select * from ld_relatedlists_lable where tabid = '".$TabId."' and fieldid = " . $Id[$j]);
        if($adb->num_rows($Sql)>0)
        {
            //$sql = "update ld_relatedlists_lable set width = ".$Width[$j]." where fieldid = ".$Id[$j]."";
            $adb->pquery("update ld_relatedlists_lable set width = ? where fieldid = ? and tabid = ? ", array($Width[$j],$Id[$j],$TabId));
        }
    }
   header("Location:index.php?module=Settings&action=RelatedList&parenttab=Settings&tabid=" . $TabId);
}
else
{
    //菜单项中的列单
    $field_array = getInfo(1,0,$TabId);
}
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
            'fieldid'=>$adb->query_result($Pro,$i,"fieldid"),
            'relatedstatus'=>1,
            'relatedname'=>getFieldListName($adb->query_result($Pro,$i,"tabid"),$adb->query_result($Pro,$i,"fieldid"),2),
            'relatedlable'=>getFieldListName($adb->query_result($Pro,$i,"tabid"),$adb->query_result($Pro,$i,"fieldid"),1),
            'relatedwidth'=>$adb->query_result($Pro,$i,"width"),
            'relatededit'=>$adb->query_result($Pro,$i,"edit"),
        );
        $ProId[$i] = $adb->query_result($Pro,$i,"fieldid");
    }
    $ProAllId = implode(',', $ProId);
    $SqlPro = "select fieldid,tabid,fieldname,fieldlabel from  ld_field where tabid =" . $Id . " and fieldid not in (".$ProAllId.") and presence in(0,2) order by sequence asc";
    $Pro=$adb->pquery($SqlPro);
    for($i=0; $i<$adb->num_rows($Pro); $i++)
    {
        $array[$i + $num_rows] = array(
            'tab_id'=>$adb->query_result($Pro,$i,"tabid"),
            'fieldid'=>$adb->query_result($Pro,$i,"fieldid"),
            'relatedstatus'=>0,
            'relatedname'=>getFieldListName($adb->query_result($Pro,$i,"tabid"),$adb->query_result($Pro,$i,"fieldid"),2),
            'relatedlable'=>getFieldListName($adb->query_result($Pro,$i,"tabid"),$adb->query_result($Pro,$i,"fieldid"),1),
            'relatedwidth'=>0,
            'relatededit'=>0,
        );
    }
    return $array;
}
function getFieldListName($TabId,$FieldId,$Type)
{
    global $adb,$current_user;
    require('user_privileges/user_language_'.$current_user->id.'.php');
    $Sql = "select fieldname,ld_tranlabel.fieldlabel from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
     where ld_tranlabel.languagetype=? and trantable=? and fieldid = " . $FieldId;
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
function getMaxOrder($TabId)
{
    global $adb;
    $Sql = "select sequence from ld_relatedlists_lable where tabid = "  . $TabId;
    $Query=$adb->pquery($Sql,array());
    return $adb->query_result($Query,0,"sequence") + 1;
}
//获取产品信息对应的中文名
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
function getStau($TabId)
{
    global $adb;
    $Sql = "select fieldid from ld_relatedlists_lable where tabid = $TabId and edit = 1 ";
    $Query=$adb->pquery($Sql,array());
    if($adb->num_rows($Query) > 0)
    {
        for($i=0; $i<$adb->num_rows($Query); $i++)
        {
            $array[$i] = $adb->query_result($Query,$i,"fieldid");
        }
        
    }
    return $array;
}
//判断有没不可编辑的列项
function getEdit($TabId)
{
    global $adb;
    $Sql = "select id from ld_relatedlists_lable where edit = 1 and tabid = "  . $TabId;
    $Query=$adb->pquery($Sql,array());
    if($adb->num_rows($Query) > 0)
    {
        for($i=0; $i<$adb->num_rows($Query); $i++)
        {
            $array[$i] = $adb->query_result($Query,0,"id");
        }
        
    }
    return $array;
}
//print_r($field_array);
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("APP", $app_strings);
$smarty->assign("FIELDARRAY", $field_array);
$smarty->assign("tabid", $TabId);
$smarty->display("RelatedEdit.tpl");
?>