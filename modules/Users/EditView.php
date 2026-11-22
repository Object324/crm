<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('modules/Users/Forms.php');

global $app_list_strings;
global $currentModule,$default_charset;

$smarty=new lingdangCRM_Smarty;
$focus = new Users();
//审批委托人
$last_name="";

if(isset($_REQUEST['record']))
{
    
    $sql = "select last_name,id from ld_users where id in (select approveby from ld_users where id=".$_REQUEST['record']." )";
    $result = $adb->pquery($sql,array());
    $num_rows = $adb->num_rows($result);
    $last_name=array();
    for($i=0;$i<$num_rows;$i++)
    {
    $last_name[]=array(
            'last_name'=> $adb->query_result($result,$i,"last_name"),
            'id'=>$adb->query_result($result,$i,"id")
            );
    }
    $smarty->assign("last_name",$last_name);
}
if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
    //复选框默认值（中孚)
	setObjectValuesFromRequest($focus);
}
//end

//职位级别
$level_show_user="";
if(isset($_REQUEST['record']))
{
    $sql = "select userlevel from ld_users where id=".$_REQUEST['record']."";
    $result = $adb->pquery($sql,array());
    $level_show_user = $adb->query_result($result,0);
    $smarty->assign("level_show_user",$level_show_user);
}
/*$level = array('普通用户','总经理','副总经理');*/
    /**
     * edit:lmx
     * date:20140303
     * reason: 0007297: admin登录，点击右上角“个人设置”，希望将“职位级别”的下拉值改为“普通用户”、“总经理”、“副总经理”。
     * */
$level = array(getFixedLabel('ORDINARYUSER'),getFixedLabel('MANAGER'),getFixedLabel('DEPUTYMANAGER'));
$smarty->assign("level",$level);
$smsarray = GetSMSAutograph();
$smarty->assign('SMS_ACCOUNT_NAME',$smsarray['account_name']);
if(isset($_REQUEST['level_value']) && $_REQUEST['level_value']!="")
{
    //print_r($_REQUEST['level_value']);
   $level_show=$_REQUEST['level_value'];
}
$smarty->assign("level_show",$level_show);
//end
require_once globalStatic::$root_directory.'appCommon/appCommon.php';
//判断是否为kehu001预置帐套
$smarty->assign("KEHU001DEFAULT",'yes');
//32585: 企业微信：kehu001自动分配的账套，增加控制管理员属性不允许编辑
if(!judgeCorpInfo('kehu001')){
    $smarty->assign("KEHU001DEFAULT",'no');
}
//审批委托
$approvestatus_show_user="";
if(isset($_REQUEST['record']))
{
    $sql = "select approvestatus from ld_users where id=".$_REQUEST['record']."";
    $result = $adb->pquery($sql,array());
    $approvestatus_show_user = $adb->query_result($result,0);
    $smarty->assign("approvestatus_show_user",$approvestatus_show_user);
}
$approvestatus = array(getFixedLabel('ACTIVATE'),getFixedLabel('INACTIVATE'));
$smarty->assign("approvestatus",$approvestatus);
if(isset($_REQUEST['approvestatus_show']) && $_REQUEST['approvestatus_show']!="")
{   
    //print_r($_REQUEST['approvestatus_show']);
    $approvestatus_show=$_REQUEST['approvestatus_show'];
}
$smarty->assign("approvestatus_show",$approvestatus_show);
//end
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
	$smarty->assign("ID",vtlib_purify($_REQUEST['record']));
	$mode='edit';
//	if (isPermitted("Users", 'index','') == 'no' && $_REQUEST['record'] != $current_user->id) die ("Unauthorized access to user administration.");
    $focus->retrieve_entity_info($_REQUEST['record'],'Users');
	$smarty->assign("USERNAME", $focus->column_fields['last_name']);
	$focus->name=$focus->column_fields[$focus->list_link_field];
}else
{
     if($_SESSION['user_group_list_id_'.$current_user->id])
     {
        $focus->column_fields['groupid']=$_SESSION['user_group_list_id_'.$current_user->id];
     }
	$mode='create';
}

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
	$focus->user_name = "";
	$mode='create';
    if($current_user->id !=1)
    {
        $focus->column_fields['is_admin']=false;//17961: 用户管理改进
    }
   $smarty->assign("ODuplicateID", $_REQUEST['record']); 
    /**
     * edit:can
     * date:20131202
     * reason:5810: 控制面板->用户，编辑“用户”和复制“用户”时，没有对用户账号的唯一性进行判断。
     * */
	$smarty->assign("ID",-1);
	//When duplicating the user the password fields should be empty
	$focus->column_fields['user_password']='';
	$focus->column_fields['confirm_password']='';
    /**
     * 更新操作
     * edit:can
     * date:20131130
     * reason:05810: 控制面板->用户，编辑“用户”和复制“用户”时，没有对用户账号的唯一性进行判断。
     * */
    $focus->column_fields['user_name']='';
    //zkt 20221012 BUG0057602成员管理，复制单据时自动带出了“企业微信/钉钉/云之家/微信小程序通讯录账号”。预期结果：通讯录账号不需要自动带出
    /* edit :duan 20240709 BUG20240709-11 复制
    $focus->column_fields['wx_userid']='';//企业微信通讯录帐号
    $focus->column_fields['wx_openid']='';//小程序通讯录账号
    $focus->column_fields['dingtalk_userid']='';//钉钉通讯录账号
    $focus->column_fields['yunzhijia_wbuserid']='';//云之家通讯录账号
    $focus->column_fields['fanwei_userid']='';//泛微通讯录账号
    $focus->column_fields['zhiyuan_userid']='';//致远
    */
}
if(empty($focus->column_fields['time_zone'])) {
    crm_load_class_file('DateTimeField','include/fields');
	$focus->column_fields['time_zone'] = DateTimeField::getDBTimeZone();
}

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";


$smarty->assign("JAVASCRIPT", get_validate_record_js());

if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");

global $current_language;

$smarty->assign("CURRENT_USERID", $current_user->id);
$smarty->assign('ISADMIN',$current_user->is_admin);


$version_info = getVersionInfo();
$smarty->assign('VERSION_ACCOUNT',$version_info['account']);
if (isset($_REQUEST['error_string'])) $smarty->assign("ERROR_STRING", "<font class='error'>Error: ".vtlib_purify($_REQUEST['error_string'])."</font>");
if (isset($_REQUEST['return_module']))
{
        $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
        $RETURN_MODULE=vtlib_purify($_REQUEST['return_module']);
}
if (isset($_REQUEST['return_action']))
{
        $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
        $RETURN_ACTION = vtlib_purify($_REQUEST['return_action']);
}
if ($_REQUEST['isDuplicate'] != 'true' && isset($_REQUEST['return_id']))
{
        $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
        $RETURN_ID = vtlib_purify($_REQUEST['return_id']);
}
if (is_admin($current_user) || $_REQUEST['record'] == $current_user->id||isPermitted("Users", 'index','') == 'yes' ) {
    $buttons = "<a href='javascript:;' onclick='changepass();'>".getFixedLabel('CHANGEPASSWORD')."</a>";
	$smarty->assign('CHANGE_PW_BUTTON',$buttons);
}
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
$focus->mode = $mode;
$disp_view = getView($focus->mode);
$authtype =  $focus->getAuthType();
$smarty->assign('AUTHTYPE',$authtype);
if($authtype == 'yes' && $focus->mode == 'edit' && $focus->id> 0){
	$imagename = $focus->getUserImage($focus->id);
}else{
	$imagename = $focus->imagename;
}
$smarty->assign("IMAGENAME",$imagename);
$fieldObj=$focus->fieldobj;
$data = $fieldObj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME", $data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE", $data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL", $data['fieldlabel']);
//0014768: 控制面板>用户管理,关于新增用户默认用户的职位问题
//只有$mode等于空才会把默认值赋值过去

global $global_pick_list_values;
if(strtolower($mode)=='create'){
    $act_data=getBlocks($currentModule,$disp_view,'',$focus->column_fields);
}else{
    $act_data=getBlocks($currentModule,$disp_view,$mode,$focus->column_fields);
}


 /**
 * 更新操作
 * edit:can
 * date:20131223
 * reason:添加富文本框
 * */
 $richText=$act_data['RichText'];
 unset($act_data['RichText']);
 $smarty->assign("BLOCKS",$act_data);
$smarty->assign("MODULE", 'Users');
$smarty->assign("MODE",$focus->mode);
if(is_admin($current_user)||isPermitted("Users", 'index','') == 'yes' )
	$smarty->assign("IS_ADMIN", true);
else
	$smarty->assign("IS_ADMIN", false);
$smarty->assign("HOUR_FORMAT",$focus->hour_format);
$smarty->assign("START_HOUR",$focus->start_hour);
if ($_REQUEST['Edit'] == ' Edit ')
{
	$smarty->assign("READONLY", "readonly");
	$smarty->assign("USERNAME_READONLY", "readonly");

}
if(isset($_REQUEST['record']) && $_REQUEST['isDuplicate'] != 'true')
{
	$smarty->assign("USERNAME_READONLY", "readonly");
}
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$smarty->assign("BLOCKIDSETTING", $_REQUEST['blockidsetting']);
$smarty->assign("FIELDIDSETTING", $_REQUEST['fieldidsetting']);
$smarty->assign('USEREDIT','useredit');


$smarty->assign("DUPLICATE",vtlib_purify($_REQUEST['isDuplicate']));

$smarty->assign("USER_MODE",$mode);
$smarty->assign('PARENTTAB', getParentTab());
$_SESSION['Users_FORM_TOKEN'] = rand(5, 2000) * rand(2, 7);
$smarty->assign('FORM_TOKEN', $_SESSION['Users_FORM_TOKEN']);
$smarty->assign("ALLSETROLEDATAPROFILE",isPermitted("Users","AllowSetRoleDataProfile"));
/*---仓库信息---*/
require_once ('include/Stock/CommonStock.php');
$wareresult = selWareAll($current_user->id);
for($i = 0; $i<$adb->num_rows($wareresult); $i++)
{
    $wareArray[$adb->query_result($wareresult, $i, "id")] = $adb->query_result($wareresult, $i, "name");
}
$smarty->assign("WAREALL", $wareArray);
/**
 * 编辑、新增页面，增加更多信息左边栏
 *
 */
//wym BUG0074511 当关联创建模块包含附件或图片类型的引用字段时，focus对象上有fieldjsondata（此时foucs->id无值）
$fieldjsondata = empty($focus->fieldjsondata)?array():$focus->fieldjsondata;
if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue('bigtype','fileattachment','fieldname')!='')
{
    $fieldjsondata=getAllFile_imageInfo($focus->id,$currentModule);
} 
if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue('uitype','105','fieldname')!='')
{
    
    $userimagefieldjsondata=getUser_imageInfo($focus->id);
}
if(is_array($fieldjsondata)&&is_array($userimagefieldjsondata)){
    $fieldjsondata=array_merge($fieldjsondata,$userimagefieldjsondata);
}

else if(is_array($userimagefieldjsondata)){
    $fieldjsondata=$userimagefieldjsondata;
}

//$smarty->assign("IS_REL_LIST",isPresentRelatedLists($currentModule));
if($focus->id>0)
{
    $smarty->assign("OP_MODE","edit_view");
}
global $global_pick_list_depencyfield;
crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList');

$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
setGLobalURLSmarty($smarty);//js,css的加载url
//edidt:can 2021-03-17 45037: 用户管理-页面设置，增加关联选择单据选择“CustomForm21”，新增和编辑界面无法显示字段
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
$str=$smarty->fetch("DetailView/PopupEditRelated.tpl");
$_REQUEST['diony']='diony';

//zxm 2021-0902 结尾返回的arr提取
require_once 'modules/lingdang/CommonEditViewReturn.php';
$CommonEditViewReturnObj = new CommonEditViewReturn();
$arr = $CommonEditViewReturnObj->getReturnArr($focus);
$arr['content']='';
$arr['allcontent']=$str;
$arr['fieldname']=$data['fieldname'];
$arr['datatype']=$data['datatype'];
$arr['fieldlabel']=$data['fieldlabel'];
$arr['fields']=$fields['fields'];
$arr['filejsondata']=$fieldjsondata;
//$arr['columnfields_value']=$focus->column_fields;
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
$arr['picklistcontent']=$global_pick_list_values;
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
$arr['cur_groupinfo']=getUserGroupinfo($focus);
//duan 20240124 在编辑页面结尾对返回值增加统一操作
$arr = $CommonEditViewReturnObj->setReturnArr($arr);

ConvertTojsonString(1,$arr,"success");


 //布局规则
//crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
//$fieldruleobj=cls_fieldrule::getInstance($currentModule);
//$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
//    
//    
//$smarty->display('DetailView/EditRelated.tpl');

?>