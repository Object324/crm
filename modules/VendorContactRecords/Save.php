<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
//require_once('modules/VendorContactRecords/VendorContactRecords.php');
//
require_once('modules/Reminds/Reminds.php');

//added to fi"\color{clNavy}PearDatabase\color{clBlack}::\color{clGreen}pquery\color{clBlack}(", "sql;", "params;", "[dieOnError='false'];", "[msg=''''];", ")"
$search=vtlib_purify($_REQUEST['search_url']);

//Ended

global $currentModule;

$focus =CRMEntity::getInstance($currentModule);
global $current_user;

if(isset($_REQUEST['record']) && $_REQUEST['record'] >0)
{
	$focus->id = $_REQUEST['record'];
    
    $focus->retrieve_entity_info($focus->id,$currentModule);
    $before_columnfieldvalue=$focus->column_fields;
    $focus->mode='edit';
}
/*
foreach($focus->column_fields as $fieldname => $val)
{
	if(isset($_REQUEST[$fieldname]))
	{
		if(is_array($_REQUEST[$fieldname]))
			$value = $_REQUEST[$fieldname];
   
		else
			$value = trim($_REQUEST[$fieldname]);
	
		$focus->column_fields[$fieldname] = $value;
	}
}*/
setObjectValuesFromRequest($focus);
//print_r($_REQUEST);
//exit;
//负责人
if($_REQUEST['assigntype'] == 'U')  {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}


//Changing account address - Ends
$LINGDANG_BULK_SAVE_MODE = false;

$focus->save("VendorContactRecords");
$return_id = $focus->id;
//add by tifa for reminds 20130301
$parenttab = getParentTab();
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "VendorContactRecords";
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);

//code added for returning back to the current view after edit from list view
if($_REQUEST['return_viewname'] == '') $return_viewname='0';
if($_REQUEST['return_viewname'] != '')$return_viewname=vtlib_purify($_REQUEST['return_viewname']);

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
     //$arr['fieldhrefname']=$focus->list_link_field;
//     $arr['fieldvalue']=$focus->column_fields;
//    $arr['fieldvalue']['maintable_id']=$focus->id;
//     $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
//    $_SESSION[$currentModule.'_modulebillnotip']='no';
//    ConvertTojsonString(1,$arr,"success");
        
        $focus->ReturnAfterSave($before_columnfieldvalue);
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