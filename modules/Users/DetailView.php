<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once(globalStatic::$root_directory."Register/RegOp.php");

global $current_user;
global $theme;
global $default_language;
global $adb;
global $currentModule;
//echo "<script> alert('保存成功，请联系管理员设置用户的角色与权限);</script>";

$focus = new Users();
$fieldobj=$focus->fieldobj;
if(!empty($_REQUEST['record'])) 
{
	$focus->retrieve_entity_info($_REQUEST['record'],'Users');
	$focus->id = $_REQUEST['record'];
	$focus->name=$focus->column_fields[$focus->list_link_field];
}
else
{
    echo "
        <script type='text/javascript'>
            window.location = 'index.php?module=Users&action=ListView';
        </script>
        ";
}
$smarty = new lingdangCRM_Smarty;
$reg=RegOp::getInstance();
$smarty->assign("VERSIONNO",$reg->GetVersionNo());
if( $focus->user_name == "" )
{

	if(is_admin($current_user))
	{
    echo "
            <table>
                <tr>
                    <td>
                        <b>User does not exist.</b>
                    </td>
		    </tr>";

    echo "
                <tr>
                    <td>
                        <a href='index.php?module=Users&action=ListView'>List Users</a>
                    </td>
                </tr>
            </table>
	    ";
    exit;
	}

}


if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
}

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";


//$category = getParenttab();
//
$smarty = new lingdangCRM_Smarty;
$smarty->assign("CURRENTMODULE", $currentModule);



//$oGetUserGroups = new GetUserGroups();
//$oGetUserGroups->getAllUserGroups($focus->id);
if(useInternalMailer() == 1)
        $smarty->assign("INT_MAILER","true");

//$smarty->assign("GROUP_COUNT",count($oGetUserGroups->user_groups));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
$smarty->assign("ID", $focus->id);
//$smarty->assign("CATEGORY", $category);
if(isset($focus->imagename) && $focus->imagename!='')
{
	$imagestring="<div id='track1' style='margin: 4px 0pt 0pt 10px; width: 200px; background-image: url(themes/images/scaler_slider_track.gif); background-repeat: repeat-x; background-position: left center; height: 18px;'>
	<div class='selected' id='handle1' style='width: 18px; height: 18px; position: relative; left: 145px;cursor:pointer;'><img src='" . lingdang_imageurl('scaler_slider.gif', $theme) . "'></div>
	</div>
<script language='JavaScript' type='text/javascript' src='include/js/slider.js'></script>

	<div class='scale-image' style='padding: 10px; float: left; width: 83.415px;'><img src='dataCache/test/user/".$focus->imagename."' width='100%'</div>
	<p><script type='text/javascript' src='include/js/scale_demo.js'></script></p>";
	//$smarty->assign("USER_IMAGE",$imagestring);
}

if(isset($_REQUEST['modechk']) && $_REQUEST['modechk'] != '' )
{
	$modepref = $_REQUEST['modechk'];
}
	if($_REQUEST['modechk'] == 'prefview')
		$parenttab = '';
	else
		$parenttab = 'Settings';
$parenttab=$_REQUEST['parenttab'];
$smarty->assign("PARENTTAB", $parenttab);
if ((is_admin($current_user) || $_REQUEST['record'] == $current_user->id||isPermitted("Users","index")=='yes')
		&& isset($default_user_name)
		&& $default_user_name == $focus->user_name
		&& isset($lock_default_user_name)
		&& $lock_default_user_name == true) {
	$buttons = "<input title='".getFixedLabel('EDIT')."' class='editauto' onclick=\"this.form.return_module.value='Users'; this.form.return_action.value='DetailView'; this.form.return_id.value='$focus->id'; this.form.action.value='EditView';\" type='submit' name='Edit' value='".getFixedLabel('EDIT')."'>";
	$smarty->assign('EDIT_BUTTON',$buttons);
}
elseif (is_admin($current_user) || $_REQUEST['record'] == $current_user->id||isPermitted("Users","index")=='yes') {
	$buttons = "<input title='".getFixedLabel('EDIT')."' class='editauto b_radius3' onclick=\"this.form.return_module.value='Users'; this.form.return_action.value='DetailView'; this.form.return_id.value='$focus->id'; this.form.action.value='EditView';\" type='submit' name='Edit' value='".getFixedLabel('EDIT')."'>";
	$smarty->assign('EDIT_BUTTON',$buttons);
	
  $buttons = "<a href='javascript:;' onclick='changepass();'>".getFixedLabel('CHANGEPASSWORD')."</a>";
	$smarty->assign('CHANGE_PW_BUTTON',$buttons);
}
if (is_admin($current_user) || isPermitted("Users", 'index','') == 'yes')
{
	$buttons = "<input title='".getFixedLabel('COPY')."' class='cancelauto b_radius3' onclick=\"this.form.return_module.value='Users'; this.form.return_action.value='DetailView'; this.form.isDuplicate.value=true; this.form.return_id.value='".vtlib_purify($_REQUEST['record'])."';this.form.action.value='EditView'\" type='submit' name='Duplicate' value='".getFixedLabel('COPY')."'   >";
	$smarty->assign('DUPLICATE_BUTTON',$buttons);
	
	//done so that only the admin user can see the customize tab button
	if($_REQUEST['record'] != $current_user->id)
	{
		$buttons = "<input title='".getFixedLabel('DELETE')."' class='deleteauto b_radius3' onclick=\"deleteUser(this,'$focus->id')\" type='button' name='Delete' value='  ".getFixedLabel('DELETE')."  '>";
		$smarty->assign('DELETE_BUTTON',$buttons);
	}

	if($_SESSION['authenticated_user_roleid'] == 'administrator')
	{
		$buttons = "<input title='".getFixedLabel('ROLELIST')."' class='createauto b_radius3' onclick=\"this.form.return_module.value='Users'; this.form.return_action.value='TabCustomise'; this.form.action.value='listroles'; this.form.record.value= '". $current_user->id ."'\" type='submit' name='ListRoles' value=' ".getFixedLabel('ROLELIST')." '>";
		$smarty->assign('LISTROLES_BUTTON',$buttons);
	}

}

if(is_admin($current_user))
	$smarty->assign("IS_ADMIN", true);
else
	$smarty->assign("IS_ADMIN", false);

$lead_tables = Array('ld_users','ld_user2role');
$tabid = getTabid("Users");

$data =$fieldobj->split_validationdataArray();
$blockidsetting=$_REQUEST['blockidsetting'];
$fieldidsetting=$_REQUEST['fieldidsetting'];
$smarty->assign("BLOCKIDSETTING", $blockidsetting);
$smarty->assign("FIELDIDSETTING", $fieldidsetting);
$smarty->assign('isPermitted',isPermitted("Users", 'index',''));

if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");
/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);

/* 关联创建 begin */
$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
//判断是否为kehu001预置帐套
$smarty->assign("KEHU001DEFAULT",'yes');
//32585: 企业微信：kehu001自动分配的账套，增加控制管理员属性不允许编辑
if(!judgeCorpInfo('kehu001')){
    $smarty->assign("KEHU001DEFAULT",'no');
}

//更多信息
$is_rel_list = array();
$is_rel_list = isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);

$fieldObj=$focus->fieldobj;
$smarty->assign('FIELDINFOJSON',json_encode($fieldObj->getModuleFields()));
$data = $fieldObj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
//wym BUG0074447 后台设置--角色权限--未设置“职位级别”权限，但是账号可以在单据详情界面对“职位级别”字段进行小编辑，并保存
$smarty->assign("JOBLEVEL_PERMIT",isPermitted("Users",'JobLevel'));

setGLobalURLSmarty($smarty);//js,css的加载url
if($current_user->id == $_REQUEST['record'] || is_admin($current_user) == true||isPermitted("Users","index")=='yes')
{

	$smarty->assign("MODULE", 'Users');
	$smarty->assign("CURRENT_USERID", $current_user->id);
    global $global_pick_list_values;
    $blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
	global $detail_column_fields_value;
    $fields=$focus->fieldobj->getFieldListArray();
    $smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
    $smarty->assign("MODULELINKFIELD",$focus->list_link_field);
    $smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
    //echo '<pre>';
    //print_r($global_pick_list_values);
    //echo '</pre>';
    $len=sizeof($global_pick_list_values);
    $global_pick_list_values[$len]['fieldname']='approvestatus';
    $global_pick_list_values[$len]['optionvalue']=array(array("","",""),array(getFixedLabel("ACTIVATE"),"0",""),array(getFixedLabel("INACTIVATE"),"1",""));
    if($focus->column_fields['approvestatus']==1)
    {
        $global_pick_list_values[$len]['optionvalue'][2][2]="selected";
    }
    else
    {
         $global_pick_list_values[$len]['optionvalue'][1][2]="selected";
    }
    $smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
    $smarty->assign("BLOCKS", $blocks);
    $smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
     crm_load_function_file('VT_detailViewNavigation','include/utils','DetailViewUtils');
	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
    $smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));

	$sql = "select last_name,id from ld_users where id in (select approveby from ld_users where id=".$_REQUEST['record']." )";
	//print_r($sql);
	$result = $adb->pquery($sql,array());
	$num_rows = $adb->num_rows($result);
	$last_name=array();
	for($i=0;$i<$num_rows;$i++)
	{
		$last_name[]=array('last_name'=> $adb->query_result($result,$i,"last_name"));
	}
	$smarty->assign("last_name",$last_name);
	//print_r($last_name);

	//职位级别
	$level = array(getFixedLabel('ORDINARYUSER'),getFixedLabel('MANAGER'),getFixedLabel('DEPUTYMANAGER'));
	$smarty->assign("level",$level);
	//end

	//审批委托
	$approvestatus = array(getFixedLabel('ACTIVATE'),getFixedLabel('INACTIVATE'));

	$smarty->assign("approvestatus",$approvestatus);
	//end
    $smarty->assign("DUPLICATEDPERMITTED",isPermitted("Users","index"));
    $smarty->assign("DELETE",isPermitted("Users","index"));
    $smarty->assign("Permitted",isPermitted("Users","index"));


	$smarty->assign("USERNAME",  $focus->column_fields['last_name']);
	$smarty->assign("HOUR_FORMAT",$focus->hour_format);
	$smarty->assign("START_HOUR",$focus->start_hour);
	$_SESSION['Users_FORM_TOKEN'] = rand(5, 2000) * rand(2, 7);
	$smarty->assign('FORM_TOKEN', $_SESSION['Users_FORM_TOKEN']);

	//for check audittrail if it is enable or not
	$smarty->assign("AUDITTRAIL",$audit_trail);

	$smarty->assign("view", null);
    global $global_pick_list_depencyfield;
    crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
    $picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
    include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
	//$smarty->display("DetailView/DetailRelated.tpl");
	//相关信息日期高级查询
	//Crm_load_class_file("CommonView","modules/CustomView");
	$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
	$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
    DetailViewReturn($currentModule,$focus,$smarty);
//	$_REQUEST['diony']='diony';
//	//布局规则
//	crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
//	$fieldruleobj=cls_fieldrule::getInstance($currentModule);
//
//	$arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();////获取所有的触发字段
//	$arr['datetimestr']=CommonView::stdFilterDateTimeStr();
//	$arr['picklistcontent']=$global_pick_list_values;
//	$arr['validatasave']=getValidataSave($currentModule);
//	$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
//	$arr['picklistdepency']=$picklistDependencyDatasource;
//	$arr['column_fields_value']=$detail_column_fields_value;
//	$arr['fields']=$fields['fields'];
//	$arr['title']=getTranstab($currentModule);
//	$arr['list_link_field']=$focus->list_link_field;
//	//$arr['oktext']=getFixedLabel("SAVE");
//	//$arr['canceltext']=getFixedLabel("CANCEL");
//	$content=$smarty->fetch("DetailView/PopupDetailRelated.tpl");
//	$arr['content']=$content;
//	ConvertTojsonString(1,$arr,'success');
}
else
{
  
	$output = '<table border="0" cellpadding="5" cellspacing="0" height="450" width="100%">
		<tr><td align = "center">
		<div style="border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 10000000;">
			<table border="0" cellpadding="5" cellspacing="0" width="98%">
			<tr>
				<td rowspan="2" width="11%">
				  	<img src="'. lingdang_imageurl('denied.gif', $theme).'">
				</td>
				<td style="border-bottom: 1px solid rgb(204, 204, 204);" nowrap="nowrap" width="70%">
					<span class="genHeaderSmall">'.getFixedLabel('NOPERMITTEDEXECUTE').'
					</span>
				</td>
			</tr>
			<tr>
				<td class="small" align="right" nowrap="nowrap">
					<a href="javascript:window.history.back();">'.getFixedLabel('RETURN').'</a>
					<br>
				</td>
			</tr>
			</table>
		</div>
		</td></tr>
	</table>';
	echo $output;
}

?>