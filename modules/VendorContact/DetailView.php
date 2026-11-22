<?php
//zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule, $current_user;

$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;
//$list_buttons_moreD=$focus->getListButtons_moreforD($app_strings,$mod_strings);

if(isset($_REQUEST['record']) && $_REQUEST['record']!='') {
        //Display the error message
        if($_SESSION['image_type_error'] != '')
        {
                echo '<font color="red">'.$_SESSION['image_type_error'].'</font>';
                session_unregister('image_type_error');
        }

        $focus->id=$_REQUEST['record'];
        $focus->retrieve_entity_info($_REQUEST['record'],'VendorContact');
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
global $theme, $current_user;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";


$smarty = new lingdangCRM_Smarty;
//$smarty->assign("MOD", $mod_strings);
//$smarty->assign("APP", $app_strings);

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
/* 详情页按钮 end */

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
//$smarty->assign("UPDATEINFO",updateInfo($focus->id));


$contact_name = $focus->lastname;
/**
 * 去掉英文名称
 * @reason 0012489 供应商联系人明细查看页面显示异常
 * @author Tujt 2014-11-14
 */
//if (getFieldVisibilityPermission($currentModule, $current_user->id,'firstname') == '0') {
	//$contact_name .= ' '.$focus->firstname;
//}
$smarty->assign("NAME",$contact_name);

global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
//放在getblock函数后面，否则会影响布局规则
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("SINGLE_MOD", 'VendorContact');
    /*创建联系记录
    Edit by LD Can
    date:20130217
    */
//if(isPermitted("VendorContact",'Create',"") == 'yes'  && vtlib_isModuleActive('VendorContact'))
    //$smarty->assign('ConvertVendorContact',"permitted");
$smarty->assign("CONTACTID",$_REQUEST['record']);
// Module Sequence Numbering
//$mod_seq_field = getModuleSequenceField($currentModule);
//if ($mod_seq_field != null) {
	//$mod_seq_id = $focus->column_fields[$mod_seq_field['name']];
//} else {
	//$mod_seq_id = $focus->id;
//}
//$smarty->assign('MOD_SEQ_ID', $mod_seq_id);
// END

$smarty->assign("ID", $_REQUEST['record']);

//Security check for related list
$category = getParentTab();
$smarty->assign("CATEGORY",$category);

//$check_button = Button_Check($module);
//$smarty->assign("CHECK", $check_button);
//if( $check_button['moduleSettings'] == 'yes'){
    //$list_buttons_moreD['moduleSettings'] = getFixedLabel('LBL_PAGE_SET');
//}


$data =$fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

$smarty->assign("MODULE",$currentModule);
//$smarty->assign("EDIT_PERMISSION",isPermitted($currentModule,'EditView',$_REQUEST['record']));

//更多信息
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);


if($accountid == 0) $accountid='';
$smarty->assign("ACCOUNTID",$accountid);
//crm_load_function_file('CheckFieldPermission','include','RelatedListView');
//$smarty->assign("TODO_PERMISSION",CheckFieldPermission('parent_id','Calendar'));
//$smarty->assign("CONTACT_PERMISSION",CheckFieldPermission('contact_id','Calendar'));

//if( vtlib_isModuleActive('Calendar'))
   // $smarty->assign("EVENT_PERMISSION",CheckFieldPermission('parent_id','Events'));
$smarty->assign("SinglePane_View", $singlepane_view);
/*上一页和下一页*/
//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}

//if(isPermitted('Documents','Create','')=='yes' && vtlib_isModuleActive('Documents'))
//{
//$DocumentsEditView='yes';
//}
$smarty->assign("DocumentsEditView",$DocumentsEditView);
// Record Change Notification
$focus->markAsViewed($current_user->id);
//exit('ghghgh');
// END
/***
更新操作
edit：cdw
date：20131120
reason：联系人序时簿界面群发短信功能改进
**/
global  $adb;


    $sql_contact_SMS = "";
    $sql_contact_SMS .= " select ld_field.tabid,ld_field.fieldlabel,ld_field.tablename,ld_languagepackage.newchinesename,ld_tab.name ";
    $sql_contact_SMS .= " from ld_field inner join ld_languagepackage  ";
    $sql_contact_SMS .= " on ld_field.tabid = ld_languagepackage.tabid inner join ld_tab  on ld_tab.tabid=ld_field.tabid ";
    $sql_contact_SMS .= " where ld_field.tabid = 4 and uitype = 1101 and ld_field.presence<>1 order by fieldlabel desc ";
    
    $contact_SMS_result = $adb->pquery($sql_contact_SMS,array());
    $num_rows_contact = $adb->num_rows($contact_SMS_result);
    $contact_SMS = array();

    for($i=0;$i<$num_rows_contact;$i++)
    {
        //影响取值
       // $tabname=$adb->query_result($contact_SMS_result,$i,'name');
        //require_once('modules/'.$tabname.'/language/zh_cn.lang.php');
//        $fieldlabel=$adb->query_result($contact_SMS_result,$i,'fieldlabel');
//        if(array_key_exists($fieldlabel,$mod_strings))
//        {
//            $fieldlabel=$mod_strings[$fieldlabel];
//        }
//        else if(array_key_exists($fieldlabel,$app_strings))
//        {
//            $fieldlabel=$app_strings[$fieldlabel];
//        }
        $contact_SMS[]=array(
        'tabid'=>$adb->query_result($contact_SMS_result,$i,'tabid'),
        'fieldlabel'=>$adb->query_result($contact_SMS_result,$i,'fieldlabel'),
        'tablename'=>$adb->query_result($contact_SMS_result,$i,'tablename'),
        'newchinesename'=>$adb->query_result($contact_SMS_result,$i,'newchinesename')
        
        );
    }
    for($i=0;$i<$num_rows_contact;$i++)
    {
   
        if($i==0)
        {
            $html_contact_SMS .= "<tr>";
            $html_contact_SMS .= "<td>";
            $html_contact_SMS .= "<input type='checkbox' id='".$i."_checkbox_contact_detail' checked='checked' onclick='chosebox_select_contact_detail();' value='".$contact_SMS[$i]['tabid']."_".$contact_SMS[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$contact_SMS[$i]['newchinesename'].":&nbsp".getTranslatedString($contact_SMS[$i]['fieldlabel'])."";
            $html_contact_SMS .= "</td>";
            $html_contact_SMS .= "</tr>";
        }
        else
        {
            $html_contact_SMS .= "<tr>";
            $html_contact_SMS .= "<td>";
            $html_contact_SMS .= "<input type='checkbox' id='".$i."_checkbox_contact_detail' onclick='chosebox_select_contact_detail();' value='".$contact_SMS[$i]['tabid']."_".$contact_SMS[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$contact_SMS[$i]['newchinesename'].":&nbsp".getTranslatedString($contact_SMS[$i]['fieldlabel'])."";
            $html_contact_SMS .= "</td>";
            $html_contact_SMS .= "</tr>";
        }
    }
$smarty->assign("html_contact_SMS",$html_contact_SMS);
$smarty->assign("num_rows_contact_detail_sms",$num_rows_contact);
//end

/***
更新操作
edit：cdw
date：20131120
reason：联系人序时簿界面群发邮件功能改进
**/



    $sql_contact_email = "";
    $sql_contact_email .= " select ld_field.tabid,ld_field.fieldlabel,ld_field.tablename,ld_languagepackage.newchinesename,ld_tab.name ";
    $sql_contact_email .= " from ld_field inner join ld_languagepackage  ";
    $sql_contact_email .= " on ld_field.tabid = ld_languagepackage.tabid inner join ld_tab  on ld_tab.tabid=ld_field.tabid ";
    $sql_contact_email .= " where ld_field.tabid = 4 and uitype = 13 and ld_field.presence<>1 order by fieldlabel desc ";
    
    $contact_email_result = $adb->pquery($sql_contact_email,array());
    $num_rows_contact_email = $adb->num_rows($contact_email_result);
    $contact_email = array();

    for($i=0;$i<$num_rows_contact_email;$i++)
    {
        //影响取值
       // $tabname=$adb->query_result($contact_SMS_result,$i,'name');
        //require_once('modules/'.$tabname.'/language/zh_cn.lang.php');
//        $fieldlabel=$adb->query_result($contact_SMS_result,$i,'fieldlabel');
//        if(array_key_exists($fieldlabel,$mod_strings))
//        {
//            $fieldlabel=$mod_strings[$fieldlabel];
//        }
//        else if(array_key_exists($fieldlabel,$app_strings))
//        {
//            $fieldlabel=$app_strings[$fieldlabel];
//        }
        $contact_email[]=array(
        'tabid'=>$adb->query_result($contact_email_result,$i,'tabid'),
        'fieldlabel'=>$adb->query_result($contact_email_result,$i,'fieldlabel'),
        'tablename'=>$adb->query_result($contact_email_result,$i,'tablename'),
        'newchinesename'=>$adb->query_result($contact_email_result,$i,'newchinesename')
        
        );
    }
    for($i=0;$i<$num_rows_contact_email;$i++)
    {
   
        if($i==0)
        {
            $html_contact_email .= "<tr>";
            $html_contact_email .= "<td>";
            $html_contact_email .= "<input type='checkbox' id='".$i."_checkbox_contact_detail_email' checked='checked' onclick='isselect_checkbox_contact_detail_email();' value='".$contact_email[$i]['tabid']."_".$contact_email[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$contact_email[$i]['newchinesename'].":&nbsp".$contact_email[$i]['fieldlabel']."";
            $html_contact_email .= "</td>";
            $html_contact_email .= "</tr>";
        }
        else
        {
            $html_contact_email .= "<tr>";
            $html_contact_email .= "<td>";
            $html_contact_email .= "<input type='checkbox' id='".$i."_checkbox_contact_detail_email' onclick='isselect_checkbox_contact_detail_email();' value='".$contact_email[$i]['tabid']."_".$contact_email[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$contact_email[$i]['newchinesename'].":&nbsp".$contact_email[$i]['fieldlabel']."";
            $html_contact_email .= "</td>";
            $html_contact_email .= "</tr>";
        }
    }
  
$smarty->assign("html_contact_email",$html_contact_email);
$smarty->assign("num_rows_contact_detail_email",$num_rows_contact_email);

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
 
 $tabid = getTabid("VendorContact");
// $smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
 /**
  * 供应商联系人界面，添加新增联系记录和附件
  * @reason 0008467
  * @author Tujt 2014-04-21
  */
//if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
//	$smarty->assign("CREATEATTACHMENT","permitted");
//if(isPermitted('VendorContactRecords','Create','')=='yes' && vtlib_isModuleActive('VendorContactRecords'))
//	$smarty->assign("VendorContactRecords","permitted"); 
$smarty->assign('VENDOR_ID',$focus->column_fields['vendor_id']);

/* 关联创建 begin */
$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */


//andy
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
    $smarty->assign('CALLFILENAME',$callbutlername);
    $smarty->assign('CALLDISPLAY','yes');
    
    $callButlerRemarks = "";
    
    $callbutlernameNew = str_replace("\\","\\\\",$callbutlername);    
    $callbutlernameNew = str_replace("\\","\\\\",$callbutlernameNew);
    
    $callbutlerGetSql = "select id from ld_callbutler where soundrecordingfile like '$callbutlernameNew' ";
    $callbutlerGetResult=$adb->pquery($callbutlerGetSql);
    if($adb->num_rows($callbutlerGetResult))
    {
        //存在
        $callButlerID = $adb->query_result($callbutlerGetResult,0,'id');
        
        $sqlUpdate = "update ld_callbutler set vendorcontactid = ?,description = ? where id = ? ";
        $updateResult=$adb->pquery($sqlUpdate,array($_REQUEST['record'],$callButlerRemarks,$callButlerID));
        
        
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
        $insertresult=$adb->pquery($sqlInsert,array('','','接通',null,null,'',$callbutlername,$current_user->id,
        $_REQUEST['record'],0,0,0,0,0,0,$callButlerRemarks));
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
( SELECT tabid,tabsequence FROM ld_tab WHERE presence = 0 AND NAME = 'VendorContact') AS T1 
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

//加载审批历史
$smarty->assign('APPROVEMOD','1');
//审批状态图片
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
//$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
///保存判断
//$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';


//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
DetailViewReturn($currentModule,$focus,$smarty);
//布局规则
//crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
//$fieldruleobj=cls_fieldrule::getInstance($currentModule);
//$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
//
//$smarty->display("DetailView/DetailRelated.tpl");
?>