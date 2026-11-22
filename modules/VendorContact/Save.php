<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

//require_once('modules/VendorContact/VendorContact.php');
//
//added to fix 4600
$search=vtlib_purify($_REQUEST['search_url']);
//$LINGDANG_BULK_SAVE_MODE = true;

global $currentModule;
$focus =CRMEntity::getInstance($currentModule);// new VendorContact();
if(isset($_REQUEST['record']) && $_REQUEST['record'] >0)
{
	$focus->id = $_REQUEST['record'];
    
    $focus->retrieve_entity_info($focus->id,$currentModule);
    $before_columnfieldvalue=$focus->column_fields;
    $focus->mode='edit';
}
/**
 * 原来的代码是直接循环$focus->column_fields，从request中取值，后来这段代码被注释了，
 * 现在直接用通用方法setObjectValuesFromRequest($focus)替换。
 * @reason 0012971: 采购>>供应商模块:相关信息中，供应商联系人创建后不显示。在供应商联系人序时薄中，查看不到创建的供应商联系人信息
 * @author Tujt 2014-12-17
 */
setObjectValuesFromRequest($focus);

//负责人
if($_REQUEST['assigntype'] == 'U')  {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}


//Changing account address - Ends


$focus->save("VendorContact");

$return_id = $focus->id;

$parenttab = getParentTab();
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "VendorContact";
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);


//code added for returning back to the current view after edit from list view
if($_REQUEST['return_viewname'] == '') $return_viewname='0';
if($_REQUEST['return_viewname'] != '')$return_viewname=vtlib_purify($_REQUEST['return_viewname']);


/* editor:gyq_11  reason:新增客户更新通话记录相关信息 date:20160603*/
/*
if(!empty($_REQUEST['jiuweiaccount'])){
	if($_REQUEST['callcenter_switch'] == 5) {
		$adb->pquery("UPDATE ld_jiuweiak_phonerecord SET indexid = ?,modulename='VendorContact' WHERE id=?", array($focus->id, $_REQUEST['jiuweiaccount']));
	}elseif($_REQUEST['callcenter_switch'] == 6){
		$adb->pquery("UPDATE ld_sopho_phonerecord SET indexid = ?,modulename='VendorContact' WHERE id=?", array($focus->id, $_REQUEST['jiuweiaccount']));
	}elseif($_REQUEST['callcenter_switch'] == 4){
	    $adb->pquery("UPDATE ld_hantian_phonerecord SET indexid = ?,modulename='VendorContact' WHERE id=?", array($focus->id, $_REQUEST['jiuweiaccount']));
	}
}
*/

/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-24
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}

$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
 {
     $focus->ReturnAfterSave($before_columnfieldvalue);
      //$arr['fieldhrefname']=$focus->list_link_field;
//     $arr['fieldvalue']=$focus->column_fields;
//    $arr['fieldvalue']['maintable_id']=$focus->id;
//     $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
//    $_SESSION[$currentModule.'_modulebillnotip']='no';
//    ConvertTojsonString(1,$arr,"success");
        
 }
 else  if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
  
    header("Location: index.php?action=$return_action&module=$return_module&parenttab=$parenttab&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);


}
else
{
  
     header("Location: index.php?action=$return_action&module=$return_module&parenttab=$parenttab&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);

}


//header("Location: index.php?action=$return_action&module=$return_module&parenttab=$parenttab&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);

exit();

?>