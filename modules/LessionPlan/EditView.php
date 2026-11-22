<?php
/*+**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $app_strings, $mod_strings, $current_language, $currentModule, $theme;
global $adb;
require_once('modules/LessionPlan/LessionPlan.php');
require_once('modules/LessionPlan/LessionPlanCommon.php');
$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;
$smarty = new lingdangCRM_Smarty();
$record = $_REQUEST['record'];
$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
//模块是否被激活
$smarty->assign('MODULE_ACTIVATE',vtlib_isModuleActive('LessionPlan'));
$convertmode=false;
$tabid = getTabid($currentModule);
if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
	setObjectValuesFromRequest($focus);
}
$disp_view = getView($focus->mode);
$smarty->assign('OP_MODE',$disp_view);
$smarty->assign('APP', $app_strings);
$smarty->assign('MOD', $mod_strings);
$smarty->assign('MODULE', $currentModule);
$smarty->assign('RECPRDID',$_REQUEST['record']);

// TODO: Update Single Module Instance name here.
$smarty->assign('SINGLE_MOD', 'SINGLE_'.$currentModule);
$smarty->assign("THEME", $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('ID', $focus->id);
$smarty->assign('MODE', $focus->mode);
$smarty->assign('DUPLICATE', $isduplicate);

if($focus->mode == 'edit' || $isduplicate) {
	
	$recordName =$focus->column_fields[$focus->list_link_field];
	$smarty->assign('NAME', $recordName);
}
$smarty->assign('LISTVIEWHEADER',getTableHeader($tabid,2,$record)); 
$smarty->assign('LISTJSINFO',getTableHeader($tabid,1,$record));

if(isset($_REQUEST['return_module']))    $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
if(isset($_REQUEST['return_action']))    $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if(isset($_REQUEST['return_id']))        $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['return_viewname'])) $smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
if(isset($_REQUEST['SearchScope'])) $smarty->assign("SEARCHSCOPE",$_REQUEST['SearchScope']);

$validationArray =$fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$validationArray['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$validationArray['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$validationArray['fieldlabel']);

/*
$smarty->assign("CALENDAR_LANG", $app_strings['LBL_JSCALENDAR_LANG']);
$smarty->assign("CALENDAR_DATEFORMAT", parse_calendardate($app_strings['NTC_DATE_FORMAT']));*/
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
    $smarty->assign('CREATE','true');
}
else
{
    $smarty->assign('CREATE','false');
}
function getTableHeader($tabid,$type,$record)
{
    global $adb,$current_user;
    require('user_privileges/user_language_'.$current_user->id.'.php');
    $sql = "select ld_tranlabel.fieldlabel,ld_field.uitype,ld_field.fieldname,ld_field.typeofdata,ld_tranlabel.fieldlabel from ld_field 
inner join ld_tranlabel on ld_field.fieldid = ld_tranlabel.relateid 
where ld_field.tabid = ? and trantable = ? and languagetype = ? and ld_field.displaytype=1";
    $result = $adb->pquery($sql,array($tabid,'ld_field',$languageType));
    $num_rows = $adb->num_rows($result);
    if($record > 0)
    {
        $sqlplan = "select projectid,servicecontractsid,projectmilestoneid,projecttaskid,lessiondate,starttime,endtime,remark from ld_lessionplan where lessionplanid = ? ";
        $plan = $adb->pquery($sqlplan,array($record));
        $plan_rows = $adb->num_rows($plan);
        
    }
    if($type == 2)
    {
        if($plan_rows > 0)
        {
            for($j =0; $j<$plan_rows; $j++)
            {
                for($i = 0; $i<$num_rows; $i++)
                {
                    $fieldlabel[$i]['fieldlabel'] = $adb->query_result($result,$i,'fieldlabel');
                    $fieldlabel[$i]['uitype'] = $adb->query_result($result,$i,'uitype');
                    $fieldlabel[$i]['fieldname'] = $adb->query_result($result,$i,'fieldname');
                    $typeofdata = $adb->query_result($result,$i,'typeofdata');
                    $typedata = explode('~',$typeofdata);
                    $fieldlabel[$i]['typeofdata'] = $typedata[1];
                    $fieldinfo[$i] = $fieldlabel[$i]['fieldname'] . ',' . $fieldlabel[$i]['uitype'] . ',' . $typedata[1] . ',' . $fieldlabel[$i]['fieldlabel'];
                    $fieldlabel[$i]['fdvalue'] = $adb->query_result($plan,$j,$adb->query_result($result,$i,'fieldname'));
                }
            }
        }
        else
        {
            for($i = 0; $i<$num_rows; $i++)
            {
                $fieldlabel[$i]['fieldlabel'] = $adb->query_result($result,$i,'fieldlabel');
                $fieldlabel[$i]['uitype'] = $adb->query_result($result,$i,'uitype');
                $fieldlabel[$i]['fieldname'] = $adb->query_result($result,$i,'fieldname');
                $typeofdata = $adb->query_result($result,$i,'typeofdata');
                $typedata = explode('~',$typeofdata);
                $fieldlabel[$i]['typeofdata'] = $typedata[1];
                $fieldinfo[$i] = $fieldlabel[$i]['fieldname'] . ',' . $fieldlabel[$i]['uitype'] . ',' . $typedata[1] . ',' . $fieldlabel[$i]['fieldlabel'];
            }
        }
    }
    else
    {
        for($i = 0; $i<$num_rows; $i++)
        {
            $typedata = explode('~',$adb->query_result($result,$i,'typeofdata'));
            $fieldinfo[$i] = $adb->query_result($result,$i,'fieldname') . ',' . $adb->query_result($result,$i,'uitype') . ','
             . $typedata[1] . ',' . $adb->query_result($result,$i,'fieldlabel');
        } 
    }
    if($type == 1)
        return implode('|',$fieldinfo);
    else
        return $fieldlabel;
}

//$smarty->display('salesEditView.tpl');
/**
 * 编辑、新增页面，增加更多信息左边栏
 * @author Tujt 2014-04-11
 */
$relmodule = (isset($_REQUEST['module']))?$_REQUEST['module']:$currentModule;
;
$smarty->assign("PICKLISTCONTENT",json_encode($global_pick_list_values));

$str=$smarty->fetch("DetailView/PopupEditRelated.tpl");
$_REQUEST['diony']='diony';
$arr['title']=getTranstab($currentModule);
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']='';
$arr['allcontent']=$str;
$arr['fieldname']=$data['fieldname'];
$arr['datatype']=$data['datatype'];
$arr['fieldlabel']=$data['fieldlabel'];
$arr['fields']=array();
//wym BUG0074511 当关联创建模块包含附件或图片类型的引用字段时，focus对象上有fieldjsondata（此时foucs->id无值）
$fieldjsondata = empty($focus->fieldjsondata)?array():$focus->fieldjsondata;
/*if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')!='')
            $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')]=json_decode( getAttachmentsTableInfo($focus->id,$currentModule));
        if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')!='')
            $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')]= json_decode(getImageFileInfo($focus->id,$currentModule));*/
if(($focus->id>0||$_REQUEST['record']>0)&&$focus->fieldobj->getFieldInfoBykeyValue('bigtype','fileattachment','fieldname')!='')
{
    if($focus->id>0){
        $tmp_record = $focus->id;
    }else if($_REQUEST['record']>0){ //edit:duan date:2021-9-30 复制的时候带出附件信息
        $tmp_record = $_REQUEST['record'];
    }
    $fieldjsondata=getAllFile_imageInfo($tmp_record,$currentModule);
}
$arr['filejsondata']=$fieldjsondata;
$arr['isadmin']=$current_user->is_admin;
$arr['columnfields_value']=$focus->column_fields;
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
$arr['picklistcontent']=$global_pick_list_values;
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
$arr['isduplicate'] = 'yes';
$arr['fieldrulecols']=$fieldrulecols;
///保存判断
$arr["validatasave"]=getValidataSave($currentModule);
$arr["validatasaverule"]=getAllRule($currentModule);
$arr['fieldrulefieldnames']=array();//获取所有的触发字段
ConvertTojsonString(1,$arr,"success");
?>