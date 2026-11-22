<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user;
$languageType= getLanguageType($current_user);

global $currentModule;
global $theme;
$focus = CRMEntity::getInstance($currentModule);
$fieldObj=$focus->fieldobj;
$moduleFields=$fieldObj->getModuleFields();
/*
 * edit:yangliu
 * date:2014-07-28
 * reason:明细界面更多按钮权限判断
 */
//$list_buttons_moreD=$focus->getListButtons_moreforD($app_strings,$mod_strings); 

if(isset($_REQUEST['record']) && $_REQUEST['record']!='') {
        //Display the error message
        if($_SESSION['image_type_error'] != '')
        {
                echo '<font color="red">'.$_SESSION['image_type_error'].'</font>';
                session_unregister('image_type_error');
        }

        $focus->id=$_REQUEST['record'];
        $focus->retrieve_entity_info($_REQUEST['record'],'Contacts');
        $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
        if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
        {
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
        }
	$focus->firstname=$focus->column_fields['firstname'];
        $focus->lastname=$focus->column_fields['lastname'];
}
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
}


$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_Smarty;


/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
/* 详情页按钮 end */

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
//$smarty->assign("UPDATEINFO",updateInfo($focus->id));

if(useInternalMailer() == 1) 
	$smarty->assign("INT_MAILER","true");

$contact_name = $focus->lastname;//中文名
//$contact_name .= ' '.$focus->firstname;//英文名 (11892联系人相关信息,只显示联系人中文名称)
$smarty->assign("NAME",$contact_name);

global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
//dump($blocks);
//exit();
//$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
 
//放在getblock函数后面，否则会影响布局规则
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));

$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("SINGLE_MOD", 'Contact');
    /*创建联系记录
    Edit by LD Can
    date:20130217
    */
//if(isPermitted("ContactRecords",'Create',"") == 'yes'  && vtlib_isModuleActive('ContactRecords'))
    //$smarty->assign('ConvertContactRecords',"permitted");
$smarty->assign("CONTACTID",$_REQUEST['record']);

$smarty->assign("ID", $_REQUEST['record']);

//Security check for related list


$tabid = getTabid("Contacts");
/*
$data = $fieldObj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
*/
$smarty->assign("MODULE",$currentModule);

//更多信息
$is_rel_list = array();
$is_rel_list = isPresentRelatedLists($currentModule);

if(get_callLinkDisplay() == 'no'){
    crm_load_class_file('cls_CallRecord','modules/Settings');
    $callrecordobj = new cls_CallRecord($currentModule);
    if($callrecordobj->getModuleCallRecordStatus() == 'no'){
        unset($is_rel_list[f_array_search('CallButler',$is_rel_list)]);
    }
}
if(!empty($is_rel_list) && f_array_search('ContactsHierarchy',$is_rel_list)> 0&& !isset($focus->column_fields['contact_id'])){
    unset($is_rel_list[f_array_search('ContactsHierarchy',$is_rel_list)]);
}
if(empty($moduleFields['contact_id'])){
	unset($is_rel_list[f_array_search('ContactsHierarchy',$is_rel_list)]);
}
$is_rel_list = Detail_Edit_View::setForeachRelatedLists($is_rel_list);

$smarty->assign("IS_REL_LIST",$is_rel_list);

$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);

//快捷链接操作时用到的变量
//$smarty->assign("TODO_PERMISSION",CheckFieldPermission('parent_id','Calendar'));
//$smarty->assign("CONTACT_PERMISSION",CheckFieldPermission('contact_id','Calendar'));
//if(isPermitted("Calendar","Create",'') == 'yes' && vtlib_isModuleActive('Calendar'))
 //   $smarty->assign("EVENT_PERMISSION",CheckFieldPermission('parent_id','Events'));
//审批中心上一条和下一条
//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
	//$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}

$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
/**
 * edit:kevin
 * date:2013-10-14
 * reason:5214
 */ 
 $ismassmail=5;
 $ismasssms=5;
 if(vtlib_isModuleActive('MassEmails'))
    $ismassmail=0;
 if(vtlib_isModuleActive('MassEmails'))
    $ismasssms=0;
 $smarty->assign('ISMASSEMAIL',$ismassmail);
 $smarty->assign('ISMASSSMS',$ismasssms);
//if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
  //  $smarty->assign("CREATEATTACHMENT","permitted");

$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
//$sql_con="SELECT presence from ld_field where tabid=4 and columnname='parentid'";
//$sql_res = $adb->query($sql_con);
//$forshow=$adb->query_result($sql_res,0,presence);

//BUG8874 
//	当且仅当“上级联系人”（'parentid'）显示，并且当前用户有“联系人”创建权限的时候显示该按钮
//edit:can 
if(array_key_exists('contact_id',$focus->column_fields) && isPermitted("Contacts","Create",'') == 'yes' ){
    $smarty->assign("CREATECONTACT","permitted");
}
//	当且仅当“上级联系人”（'parentid'）显示时显示该按钮
if(array_key_exists('contact_id',$focus->column_fields)){
    $smarty->assign('FORSHOW','yes');
}
$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveTag());//审批状态图片

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */
////andy
//$tabid=getTabid($currentModule);
//$actions_arr_userd=GetAction_userd($tabid);
//$smarty->assign('actions_arr_userd',$actions_arr_userd);
////print_r($actions_arr_userd);
//if(count($actions_arr_userd) == 0)
    //$smarty->assign('action_show_no','yes');
    
//diony 2014-10-15 弹屏新增时自动传值
if(isset($_REQUEST['callphone']) && $_REQUEST['callphone'] != '')
{
    $smarty->assign('CALLPHONE',$_REQUEST['callphone']);
}
if(isset($_REQUEST['callfilename']) && $_REQUEST['callfilename'] != '')
{
     $one_callfiles=explode('\\',$_REQUEST['callfilename']);
     $two_callfilename=$one_callfiles[sizeof($one_callfiles)-1];
     $callfilenames=explode('_',$two_callfilename);
     $callphone=$callfilenames[0];
     $xinghao_phone= fieldValueUitype::setReportMobileStyle($callphone);
     for($i=0;$i<sizeof($one_callfiles)-1;$i++)
     {
        $filenames.=$one_callfiles[$i].'\\';
     }
    $one_filenames=$filenames.$xinghao_phone.'_'.$callfilenames[1];
    crm_load_class_file('cls_PhoneEncrypt','include');
    $obj=new cls_PhoneEncrypt();
 
    $two_filenames=$filenames.$obj->createToken_Phone($callphone).'_'.$callfilenames[1] ;

    $smarty->assign('CALLFILENAME',$one_filenames);
    $smarty->assign('ENCRYPT_FILENAME',$two_filenames);
    $smarty->assign('CALLDISPLAY','yes');
    
    $callButlerRemarks = "";
    
    $callbutlernameNew = str_replace("\\","\\\\",$callbutlername);    
    $callbutlernameNew = str_replace("\\","\\\\",$callbutlernameNew);
    
    $callbutlerGetSql = "select id from ld_callbutler where soundrecordingfile like '%$two_callfilename%' ";
    $callbutlerGetResult=$adb->pquery($callbutlerGetSql);
  
    if($adb->num_rows($callbutlerGetResult))
    {
        //存在
        $callButlerID = $adb->query_result($callbutlerGetResult,0,'id');
       
        $sqlUpdate = "update ld_callbutler set accountid = ?,contactid = ?,description = ?,userid=? where id = ? ";
        $updateResult=$adb->pquery($sqlUpdate,array($focus->column_fields['account_id'],$_REQUEST['record'],$callButlerRemarks,$current_user->id,$callButlerID));
        
        
    }
    else
    {
       
        
        //不存在
        $sqlInsert = "insert into ld_callbutler 
        (calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
         accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,description) 
        values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        ";
        $callbutlername = str_replace("\\\\","\\",$callbutlername);
        $insertresult=$adb->pquery($sqlInsert,array('','','接通',null,null,'',$one_filenames,$current_user->id,
        0,$_REQUEST['record'],0,0,0,0,0,$callButlerRemarks));
    }
}
else
{
    $smarty->assign('CALLDISPLAY','no');
}

/*
 *bug 0015129
 *date 20150522
 *edit zyh
 */
$sql="
SELECT 
T1.tabid, 
GROUP_CONCAT(T2.columnname) as columnname
FROM 
( SELECT tabid,tabsequence FROM ld_tab WHERE presence = 0 AND NAME = 'Contacts') AS T1 
LEFT JOIN ( 
SELECT tabid, fieldid,columnname FROM ld_field WHERE uitype IN (11, 1101) AND presence <> 1 and callchecked=1 
) AS T2 ON T1.tabid = T2.tabid 
group by T1.tabid
order by T1.tabsequence";
$list_result = $adb->pquery($sql);
$num_rows=$adb->num_rows($list_result);
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $columnname = $adb->query_result($list_result,$i,'columnname');
    }
}
$smarty->assign("PhoneSteward", $columnname);
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);

include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');

///保存判断


setGLobalURLSmarty($smarty);//设置js,css等访问路径

//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';

//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");

$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
DetailViewReturn($currentModule,$focus,$smarty);
/*
$_REQUEST['diony']='diony';
//布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);

$arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();////获取所有的触发字段
//$arr['datetimestr']=CommonView::stdFilterDateTimeStr();
$arr['picklistcontent']=$global_pick_list_values;
$arr['validatasave']=getValidataSave($currentModule);
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
$arr['picklistdepency']=$picklistDependencyDatasource;
$arr['column_fields_value']=$detail_column_fields_value;
$arr['fields']=$fields['fields'];
$arr['title']=getTranstab($currentModule);
$arr['list_link_field']=$focus->list_link_field;
//$arr['oktext']=getFixedLabel("SAVE");
//$arr['canceltext']=getFixedLabel("CANCEL");
$content=$smarty->fetch("DetailView/PopupDetailRelated.tpl");
$arr['content']=$content;
ConvertTojsonString(1,$arr,'success');*/

?>