<?php
include("modules/lingdang/ListView.php");

//$smarty->display("RegisterInfo.tpl")
/*

global $list_max_entries_per_page_new;
global $currentModule, $current_user;

if($current_user->is_admin != 'on' && isPermitted($currentModule, 'index', '') == 'no')
{
    die("<br><br><center>".getFixedLabel('NOPERMITTEDEXECUTE')." <a href='javascript:window.history.back()'>".getFixedLabel('RETURN').".</a></center>");
}

//$log = LoggerManager::getLogger('user_list');
 
global $mod_strings,$adb;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
global $current_language;
//$mod_strings = return_module_language($current_language,'Users');
$category = getParentTab();
$focus = new Users();
$no_of_users=UserCount();

$profile = new Profile();
$profileinfo = $profile->getProfileArray();

$fieldlabelarr=$focus->fieldobj->getFieldLables();

$xllb = array(
    'user_name'=>$fieldlabelarr['user_name'],
    'last_name'=>$fieldlabelarr['last_name'],
    'profileid'=>$fieldlabelarr['profileid'],
    'email1'=>$fieldlabelarr['email1'],
    'phone_mobile'=>$fieldlabelarr['phone_mobile'],
    'userlevel'=>$fieldlabelarr['userlevel'],
    'is_admin'=>$fieldlabelarr['is_admin'],
    'status'=>$fieldlabelarr['status']
);


$reg=RegOp::getInstance();

if(isset($_REQUEST['ajax']) && isset($_REQUEST['viewothers']) && isset($_REQUEST['userid'])){
        $sql='update ld_users set viewothers=?,editothers=?,delothers=?,viewselfbills=?,edit_other_mobile=?,is_mobile_style=? where id=?';
        $adb->pquery($sql,array($_REQUEST['viewothers'],$_REQUEST['editothers'],$_REQUEST['delothers'],$_REQUEST['viewselfbills'],$_REQUEST['edit_other_mobile'],$_REQUEST['is_mobile_style'],$_REQUEST['userid']));
		if(!empty($_REQUEST['userid'])){
		  crm_load_function_file('createUserPrivilegesfile','modules/Users','CreateUserPrivilegeFile');
			createUserPrivilegesfile($_REQUEST['userid']);
		}
}

if(isset($_REQUEST['ajax']) && isset($_REQUEST['status']) && isset($_REQUEST['userid'])){
    
  
    $user_query="select 1 from ld_users where status='active'";
     if(isset($_REQUEST['userid'])&& $_REQUEST['userid']>0)
     {
        $user_query .=' and id!='.$_REQUEST['userid'];
     }
     $result=$adb->pquery($user_query);
     $strUsingCount=$adb->num_rows($result);
                  
     if($_REQUEST['status']=='Inactive'||!isset($_REQUEST['userid'])||$_REQUEST['userid']<=0)
     {
                         
        $strUsingCount=$strUsingCount+1;
                       
     }
                 
     
     $regCount=$reg->GetUserCount();
     
     if($reg->compareCount($regCount,$strUsingCount)<=0)
     {
         echo '###ERROR###'. getFixedLabel('USERSAVEREGISTER').$regCount;
        die;
     }
    if($_REQUEST['status']=='Active'){
        $sql='update ld_users set status="Inactive" where id='.$_REQUEST['userid'];
        $adb->pquery($sql);
    }else{
        $sql='update ld_users set status="Active" where id='.$_REQUEST['userid'];
        $adb->pquery($sql);
    }
	$cachekey = 'cache_getusercachenameinfo';
	unsetCache($cachekey);
}

if(isset($_REQUEST['ajax']) && isset($_REQUEST['profileid']) && isset($_REQUEST['userid'])){
        $sql='update ld_users set profileid='.$_REQUEST['profileid'].' where id='.$_REQUEST['userid'];
        $adb->pquery($sql);
}


$smarty = new lingdangCRM_Smarty;
if($_REQUEST['mail_error'] != '')
{
    require_once("modules/Emails/mail.php");
    $error_msg = strip_tags(parseEmailErrorString($_REQUEST['mail_error']));
	$error_msg = getFixedLabel('EMAILCANOTSENDUSER'). ' ' . vtlib_purify($_REQUEST['user']). '. ' .getFixedLabel('PLEASECHECKSERVERSETTINGS');
	$smarty->assign("ERROR_MSG",getFixedLabel('SENDEMAILSTATES').' <b><font class="warning">'.$error_msg.'</font></b>');
}
crm_load_function_file("getListQuery",'include/utils','ListViewUtils');
$list_query = getListQuery("Users");

if($_REQUEST['query']=='true'){
    if(isset($_REQUEST['fieldname'])){
        $_SESSION['UserSearch']['fieldname']=$_REQUEST['fieldname'];
        $_SESSION['UserSearch']['fieldvalue']=$_REQUEST['fieldvalue'];
    }
}


if($_REQUEST['query_session']==1 && isset($_SESSION['UserSearch']['fieldname'])){
    $_REQUEST['fieldname'] = $_SESSION['UserSearch']['fieldname'];
    $_REQUEST['fieldvalue'] = $_SESSION['UserSearch']['fieldvalue'];
    
}else{
    $_REQUEST['query_session']=0;
    unset($_SESSION['UserSearch']['fieldname']);
    unset($_SESSION['UserSearch']['fieldvalue']);
}

if(isset($_REQUEST['fieldname']) ){
    if($_REQUEST['fieldname'] =='profileid' || $_REQUEST['fieldname'] =='is_admin' || $_REQUEST['fieldname'] =='status'|| $_REQUEST['fieldname'] =='userlevel'){
        if($_REQUEST['fieldvalue']=='N'){
            $list_query .= " and ld_users." . $_REQUEST['fieldname'] . " <> ''";
        }elseif($_REQUEST['fieldvalue']=='Y'){
            $list_query .= " and ld_users." . $_REQUEST['fieldname'] . " = ''";
        }else{
            $list_query .= " and ld_users." . $_REQUEST['fieldname'] . " = '" .$_REQUEST['fieldvalue']."'";
        }
    }else{
        $list_query .= " and ld_users." . $_REQUEST['fieldname'] . " like " . "'%".$_REQUEST['fieldvalue']."%'";
    }
}

crm_load_function_file('getAllPickListValues','modules/PickList','PickListUtils');


$smarty->assign("USERLEVEL",getAllPickListValues("userlevel"));

$profileobj=new Profile();
$smarty->assign("PROFILEINFO",$profileobj->getProfileArray());

$userid = array();
$userid_Query = "SELECT id,user_name FROM ld_users WHERE user_name IN ('admin')";
$users = $adb->pquery($userid_Query,array());
$norows = $adb->num_rows($users);
if($norows  > 0){
	for($i=0;$i<$norows ;$i++){
		$id = $adb->query_result($users,$i,'id');
		$userid[$id] = $adb->query_result($users,$i,'user_name');
	}
}
$smarty->assign("USERNODELETE",$userid);

if(!$_SESSION['lvs'][$currentModule]) {
	unset($_SESSION['lvs']);
	$modObj = new ListViewSession();
	$modObj->sorder = $sorder;
	$modObj->sortby = $order_by;
	$_SESSION['lvs'][$currentModule] = get_object_vars($modObj);
}

if($_REQUEST['sorder'] !='')
	$sorder = $adb->sql_escape_string($_REQUEST['sorder']);
else
	$sorder = $focus->getSortOrder();
$_SESSION['USERS_SORT_ORDER'] = $sorder;

if($_REQUEST['order_by'] != '')
	$order_by = $adb->sql_escape_string($_REQUEST['order_by']);
else
	$order_by = $focus->getOrderBy();
$_SESSION['USERS_ORDER_BY'] = $order_by;

if(!empty($order_by)){
	$list_query .= ' ORDER BY '.$order_by.' '.$sorder;
}

if(PerformancePrefs::getBoolean('LISTVIEW_COMPUTE_PAGE_COUNT', false) === true){
	$count_result = $adb->query( mkCountQuery($list_query));
	$noofrows = $adb->query_result($count_result,0,"count");
}else{
	$noofrows = null;
}
$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, '', $queryMode);

$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);

$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;

$list_result = $adb->pquery($list_query. " LIMIT $limit_start_rec, $list_max_entries_per_page_new", array());

$recordListRangeMsg = getRecordRangeMessage($list_result, $limit_start_rec,$noofrows);
$smarty->assign('recordListRange',$recordListRangeMsg);


  $testFile=$reg->isExistFile();
  if($testFile==1)
  {
    $sql="select 1 from ld_users where status='active'";
    $result=$adb->pquery($sql);
    $strUserRegister=getFixedLabel('LICENSEDUSER').$reg->GetUserCount().'，'.getFixedLabel('USED').$adb->num_rows($result).'（'.getFixedLabel('NOTCONTAINUSER').'）';
    $smarty->assign("REGISTERINFO",$strUserRegister);
  }
    else
    {
        $smarty->assign("REGISTERINFO","");
    }
$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string,"Users","index",'');

$smarty->assign("CURRENT_USERID", $current_user->id);
$smarty->assign('ISADMIN',$current_user->is_admin);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("CATEGORY",$category);

$smarty->assign('CONTENTS',$focus->getList($list_result));
$arrUserFieldLabel=$focus->fieldobj->getFieldLables();
$smarty->assign('USERFIELDLABLES',$arrUserFieldLabel);
crm_load_class_file('ListView_Search','include/utils');


$smarty->assign("PAGE_START_RECORD",$limit_start_rec);
$smarty->assign("RECORD_COUNTS", $record_string);
$smarty->assign("NAVIGATION", $navigationOutput);
$smarty->assign('BLOCKIDSETTING',$_REQUEST['blockidsetting']);
$smarty->assign('FIELDIDSETTING',$_REQUEST['fieldidsetting']);
$smarty->assign("TESTFILE",$testFile);

if(empty($_SESSION['UserSearch']))
{
    $arr['fieldname']='user_name';
   $smarty->assign('UserSeach',$arr);
    
}
else

    $smarty->assign('UserSeach',$_SESSION['UserSearch']);
$smarty->assign('LANGUAGETYPE',$languageType);
$smarty->assign('XLLB',$xllb);
$smarty->assign('PARENTTAB',$_REQUEST['parenttab']);
require_once('modules/Settings/SetmenuControl.php');

if($_REQUEST['ajax'] !=''){
	$smarty->display("UserListViewContents.tpl");
 }
else{
	$smarty->display("UserListView.tpl");
}
*/

?>