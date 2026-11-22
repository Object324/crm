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
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('include/upload_file.php');


global $currentModule;

$focus = CRMEntity::getInstance($currentModule);
$fieldObj=$focus->fieldobj;

if(isset($_REQUEST['record']) && $_REQUEST['record']!='') {
   //$focus->retrieve_entity_info($_REQUEST['record'],"Attachment");
   $focus->id = $_REQUEST['record'];
   $focus->retrieve_entity_info($_REQUEST['record'],'Attachment');
}


global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_Smarty;
$record = $_REQUEST['record'];

$tabid = getTabid("Attachment");

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$detailViewButton =$focus->logic->detail_buttons;
foreach ($detailViewButton['More']['list'] as $action => $buttonInfo){
    if($action =='DownloadSelected' && $buttonInfo['permit'] == 'yes'){
            // @edit:dong @date:2020/09/16 @reason: 下载全部附件 tapd1001089
            //判断是否有下载权限  附件字段权限  和 详情里面的允许查看或下载 权限
        if('yes' != isPermitted($module, 'Download', '')  || checkCurrentModuleHaveAttachmentField() !='yes'  ||  $focus->column_fields['isenabled'] ==0){
            $detailViewButton['More']['list']['DownloadSelected']['permit'] = 'no';
        }
    }
}
$smarty->assign('DETAILBUTTON',$detailViewButton);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
/* 详情页按钮 end */


$fileattach = "select ld_attachmentsforbills.*,ld_users.last_name from ld_attachmentsforbills left join ld_users 
on ld_attachmentsforbills.creator = ld_users.id where ld_attachmentsforbills.attachmentsid = ?";
$result = $adb->pquery($fileattach,array($record));

$attachmentsid = $adb->query_result($result,0,'attachmentsid');
$attname = $adb->query_result($result,0,'filename');
$isenabled = $adb->query_result($result,0,'isenabled');
$size = $adb->query_result($result,0,'size');
$path = $adb->query_result($result,0,'path');
$description = $adb->query_result($result,0,'description');
$last_name = $adb->query_result($result,0,'last_name');
$creator = $adb->query_result($result,0,'creator');
$createdtime = $adb->query_result($result,0,'createdtime');
$related_to=$adb->query_result($result,0,'related_to');
$smownerid=$adb->query_result($result,0,'smownerid');
$modifiedtime=$adb->query_result($result,0,'modifiedtime');
$uuid=$adb->query_result($result,0,'uuid');
$imagefromtype=$adb->query_result($result,0,'imagefromtype');

/*
zyh
用户详情页增加附件
PROT197 
20150420
*/
$reltab=$adb->query_result($result,0,'reltab');
$relmodule = getEntitySetype($related_to);//获取setype字段方法 tujt 2014-07-
if(!empty($relmodule)){
    if($reltab != '用户' && $reltab != 'Users'){
    	$entitynames=getEntitynameByModulename($relmodule);
        $tablename = $entitynames['tablename'];
        $fieldname = $entitynames['fieldname'];
        $entityidfield = $entitynames['entityidfield'];
        $sql = 'SELECT '.$fieldname.' FROM '.$tablename.' WHERE '.$entityidfield.' = '.$related_to.' LIMIT 1;';
        $relateresult = $adb->pquery($sql,array());
        $related_name = $adb->query_result($relateresult,0,0);
        $related_name = '<a  referencemodule="'.$relmodule.'" referencerecord="'.$related_to.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$related_name.'</a>';
    }else{
       
        $sql = 'select last_name from ld_users where id='.$related_to;
        $relateresult = $adb->pquery($sql,array());
        $related_name = $adb->query_result($relateresult,0,'last_name');
        $related_name = '<a href="index.php?module=Users&action=DetailView&record='.$related_to.'">'.$related_name.'</a>';
    }
}

$smarty->assign('UUID',$uuid);
$smarty->assign('IMAGEFROMTYPE',$imagefromtype);
$smarty->assign('smownerid',getUserFullName($smownerid));
$smarty->assign('MODIFIEDTIME',$modifiedtime);
$smarty->assign('RELTAB',getTranstab($reltab));
$smarty->assign('RELATEDTO',$related_name);
$smarty->assign("ATTACHMENTSID",$attachmentsid);
$smarty->assign("RECORD", $record);
$smarty->assign("FILENAME", $attname);
$smarty->assign("ISENABLED",$isenabled);
$smarty->assign("SIZE", $size);
$smarty->assign("PATH", $path);
$smarty->assign("DESCRIPTION",$description);
$smarty->assign("LASTNAME",$last_name);
$smarty->assign("CREATEDTIME",$createdtime);

$smarty->assign("ISADMIN",is_admin($current_user));
if($current_user->id==$creator)
{
    $smarty->assign("ISSELF",true);
}
else
{
    $smarty->assign("ISSELF",false);
}




$smarty->assign("FILEID",$fileid);
$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);

//$allblocks = getBlocks($currentModule,"detail_view",'',$focus->column_fields);
//$smarty->assign("BLOCKS", $allblocks);
$flag = 0;


if($flag == 1)
	$smarty->assign("FILE_EXIST","yes");
elseif($flag == 0)
	$smarty->assign("FILE_EXIST","no");

//$smarty->assign("UPDATEINFO",updateInfo($focus->id));

if (isset($attname)) $smarty->assign("NAME", $attname);
else $smarty->assign("NAME", "");


if (isset($_REQUEST['return_module'])) $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
if (isset($_REQUEST['return_action'])) $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if (isset($_REQUEST['return_id'])) $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
$smarty->assign("ID", $focus->id);




$smarty->assign("SINGLE_MOD", 'Document');

//$check_button = Button_Check($module);
//$smarty->assign("CHECK", $check_button);
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);

$smarty->assign("IS_REL_LIST",$is_rel_list);

 $data = $fieldObj->split_validationdataArray();

 $smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
 $smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
 $smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
 if(is_admin($current_user))
{
 	$smarty->assign("CHECK_INTEGRITY_PERMISSION","yes");
    $smarty->assign("ADMIN","yes");
}
$smarty->assign("FILE_STATUS",$filestatus);
 $smarty->assign("DLD_TYPE",$filelocationtype);
 $smarty->assign("NOTESID",$focus->id);
 $smarty->assign("FOLDERID",$folderid);
 $smarty->assign("DLD_PATH",$filepath);

$smarty->assign("MODULE",$currentModule);

if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
  //  crm_load_function_file('VT_detailViewNavigation','include/utils','DetailViewUtils');
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
}

//打印
$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));

/* 关联创建 begin */

//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */

//andy
//$tabid=getTabid($currentModule);
//$actions_arr_userd=GetAction_userd($tabid);
//$smarty->assign('actions_arr_userd',$actions_arr_userd);
////print_r($actions_arr_userd);
//if(count($actions_arr_userd) == 0)
    //$smarty->assign('action_show_no','yes');
    
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));

$attachement_field_obj=Field::getInstance('Attachment',$adb);
$arrfileLabel=$attachement_field_obj->getFieldLables();
global $detail_column_fields_value;

global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
$smarty->assign("BLOCKS", $blocks);
//ls 2022-03-03 0050246: （http://aodejx.gnway.org/crm [^] [^] ）（奥德）在附件管理PP2203024中有两个字段，‘机型’和‘出厂价’，在编辑的时候有这两个字段，但是保存之后详情页就不显示了
//放在getblock函数后面，否则会影响布局规则
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',ldcrm_json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());

$arrblockLabel=array();
$i=0;
foreach($attachement_field_obj->getBlockInfos() as $key=>$arr){
    $arrblockLabel[$i][0]=$arr['blocklabel'];
}
//$arrblockLabel=$languagetransslate->get_index_BlockLabels();
$smarty->assign('ARRBLOCKLABELS',$arrblockLabel);
$smarty->assign('user_id',$_REQUEST['user_id']);
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
///保存判断
//$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';
DetailViewReturn($currentModule,$focus,$smarty);
/*相关信息日期高级查询

Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

$smarty->display("DetailView/DetailRelated.tpl");*/

//$smarty->display("DetailView/Attachment_DetailRelated.tpl");
?>