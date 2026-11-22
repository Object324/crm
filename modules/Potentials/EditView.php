<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user;
global $currentModule;
$deployarray=getSys_deploy(205);//设置销售机会是否显示产品分录明细:0是，1否
if($deployarray['deploy_value']==0)
{
    include(globalStatic::$root_directory.'modules/Potentials/ProductEditView.php');
    exit();
}
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();
//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
//4600 ends


if(isset($_REQUEST['record']) && $_REQUEST['record'] != ''){
    $focus->id = $_REQUEST['record'];
    $focus->mode = 'edit';
    $focus->retrieve_entity_info($_REQUEST['record'],"Potentials");
     $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
     if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
     {
      
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
     }
    $focus->name=$focus->column_fields['potentialname'];
    $smarty->assign("ACCOUNTID", $focus->column_fields['account_id']);
    $smarty->assign("CONTACTID", $focus->column_fields['contact_id']);
    //$approve=new Approve();
	$approve = Approve::getInstance($currentModule);
    if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true)
    {
            echo $approve->EditBlocks($focus->column_fields['assigned_user_id'],$focus->id);
            exit();
    }
}
else
{
      if($_REQUEST['fromid']>0&&$_REQUEST['frommodule']!="")
        {
            
            
            //关联创建，引用字段值得获取
                 $fromfocus=CRMEntity::getInstance($_REQUEST['frommodule']);
                 $fromfocus->retrieve_entity_info($_REQUEST['fromid'],$_REQUEST['frommodule']);
                 foreach($fromfocus->column_fields as $fieldname=>$value)
                 {
                     if(array_key_exists($fieldname,$focus->column_fields))
                     {
                        $focus->column_fields[$fieldname]=$value;
                     }
                 }
                 //关联创建条件判断
                 crm_load_class_file('cls_RelateCreateCondition','include');
                 $conditionobj=cls_RelateCreateCondition::getInstance($_REQUEST['frommodule'],$currentModule);
                 $_REQUEST['diony']='yes';
                 
                 if($conditionobj->IsRelateCreate($_REQUEST['fromid'])=='no')
                 {
                    ConvertTojsonString("-1",array(),$conditionobj->errorreason);
                 }
                 //$cls_relateCreateConditionObj=new cls
        }
}
//chj:获取币种ID
if($focus->mode == 'edit')
    $smarty->assign('CURRENCYID',$focus->column_fields['currency_id']);
else
    $smarty->assign('CURRENCYID',1);

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
	$focus->mode = '';
	/**
	 * 复制时，负责人设置为自己
	 * @author Tujt 2015-07-20
	 */
	//$focus->column_fields['assigned_user_id'] = $current_user->id;
}
/***********************editor:gyq_76 reason:呼叫中心增加销售机会 2018/8/22 16:46 Begin*************************/
if (isset($_REQUEST['accountscallid']) && $_REQUEST['accountscallid'] != '') {
    $accountid = $_REQUEST['accountscallid'];
    $smarty->assign("CALLTYPE", 'true');
    $result = $adb->pquery("select accountid,accountname from ld_account where accountid=?", array($accountid));
    $accountname = $adb->query_result($result, 0, 'accountname');
    $smarty->assign("ACCOUNTID", $accountid);
    $smarty->assign("ACCOUNTNAME", $accountname);
}
if (isset($_REQUEST['contactscallid']) && $_REQUEST['contactscallid'] != '') {
    $contactsid = $_REQUEST['contactscallid'];
    $smarty->assign("CALLTYPE", 'true');
    $result = $adb->pquery("select T1.accountid,accountname,contactid,lastname from ld_contactdetails as T1 
    left join ld_account as T2 on T1.accountid = T2.accountid
    where contactid = ?", array($contactsid));
    $accountid = $adb->query_result($result, 0, 'accountid');
    $accountname = $adb->query_result($result, 0, 'accountname');
    $lastname = $adb->query_result($result, 0, 'lastname');
    $smarty->assign("ACCOUNTID", $accountid);
    $smarty->assign("ACCOUNTNAME", $accountname);
    $smarty->assign("CONTACTID", $contactsid);
    $smarty->assign("LASTNAME", $lastname);
}
if(isset($_REQUEST['account_id']) && $_REQUEST['account_id'] > 0)
{
    $smarty->assign("ACCOUNTID", $_REQUEST['account_id']);
}
if(isset($_REQUEST['contact_id']) && $_REQUEST['contact_id'] > 0)
{
    $smarty->assign("CONTACTID", $_REQUEST['contact_id']);
}


$smarty->assign('MODE',$focus->mode);

//中孚需求：销售商机：商机推进到“S2需求确认”阶段后，设置“项目组长”和“大区事业部总”字段为必填并自动带出：
$version_info = getVersionInfo();
if($version_info['trade']=="zhongfu"){
    if(isset($_REQUEST['advance_field']) && $_REQUEST['advance_field'] == 'sales_stage'){
        if(isset($_REQUEST['advance_field_value']) && $_REQUEST['advance_field_value'] == "S2-需求确认")//销售阶段确认
        {
            //1)“项目组长”自动取值“销售负责人”
            if(empty($focus->column_fields['cf_3085']))
            {
                $focus->column_fields['cf_3085'] = $focus->column_fields['assigned_user_id'];
            }
            //1)“大区事业部总”根据当前“销售负责人”所在部门的“大区销售总经理”自动带出其名字
            if(empty($focus->column_fields['cf_3088']))
            {
                $focus->column_fields['cf_3088'] = $focus->getUserForGroupId($focus->column_fields['assigned_user_id']);
            }
        }
    }
}
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
    $smarty->assign('CALLTYPE',$_REQUEST['calltype']);
    $smarty->assign('CALLDISPLAY','yes');
}
else
{
    $smarty->assign('CALLDISPLAY','no');
}
/* editor:gyq_11 reason:九维呼叫通话记录id date:20160603*/
if(!empty($_REQUEST['jiuweiid'])){
    $smarty->assign('JiuWeiAccount',$_REQUEST['jiuweiid']);
    $smarty->assign('CALLCENTERSWITCH',$_REQUEST['callcenter_switch']);
}
/******************reason:呼叫中心增加销售机会 2018/8/22 16:46 End***********************/

if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
	setObjectValuesFromRequest($focus);
}
/**
 *@edit: andy 
 *@date: 20141120
 *@reason:市场活动关联创建销售机会 商机来源默认选中市场活动 
 *@version: v5.9
 */
if(isset($_REQUEST['campaignid']) && $_REQUEST['campaignid']>0){
    if(array_key_exists('leadsource',$focus->column_fields)){

        //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 下午 5:05
        crm_load_class_file("cls_PickList", 'modules/PickList');
        $objpinklist = new cls_PickList();
        $result_pick = $objpinklist->juedgePickListValues('leadsource','市场活动');
        if(count($result_pick)>0)//有无此下拉选项
            $focus->column_fields['leadsource']='市场活动';

        /*$sql_pick="select 1 from ld_leadsource where leadsource='市场活动'";
        $result_pick=$adb->pquery($sql_pick,array());
        if($adb->num_rows($result_pick)>0)//有无此下拉选项
            $focus->column_fields['leadsource']='市场活动';*/
    }
}
$disp_view = getView($focus->mode);

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}

if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}

$smarty->assign("upgradefrommodule",$_REQUEST['upgradefrommodule']);
$smarty->assign("upgradefromid",$_REQUEST['upgradefromid']);
//wym 240321 XUQIU20240204-09 销售线索可编辑追踪字段（把原先内容整理成方法）
if($_REQUEST['upgradefrommodule']!=''&&$_REQUEST['upgradefromid']>0) {
    crm_load_class_file('cls_MappingFields', 'modules/Leads');
    $cls_MappingFields = new cls_MappingFields($_REQUEST['upgradefrommodule']);
    //获取升级设置对应字段
    $mapped_arr = $cls_MappingFields->getMapfieldsTomodule($_REQUEST['upgradefromid'],$currentModule);
    $focus->column_fields=array_merge($focus->column_fields,$mapped_arr['mapped_column_fields']);
    $fieldjsondata=$mapped_arr['mapped_fieldjsondata'];
    if(is_array($focus->fieldjsondata) && sizeof($focus->fieldjsondata)>0){
        $focus->fieldjsondata = array_merge($focus->fieldjsondata,$fieldjsondata);
    }
    else{
        $focus->fieldjsondata = $fieldjsondata;
    }
}


/* 关联创建单据统一处理方法 end */

//adding support for uitype 10
if(!empty($_REQUEST['contact_id'])){
	$focus->column_fields['related_to'] = $_REQUEST['contact_id'];
    $smarty->assign("CONTACTID", $_REQUEST['contact_id']);
}
if(!empty($_REQUEST['account_id'])){
	$focus->column_fields['related_to'] = $_REQUEST['account_id'];
    $smarty->assign("ACCOUNTID", $_REQUEST['account_id']);
}
global $global_pick_list_values;
if($disp_view == 'edit_view')
	$act_data=getBlocks($currentModule,$disp_view,$mode,$focus->column_fields);

else
{
	/**
	 * 创建单据时，编号为自动生成后的编号
	 * @project 创建单据时，自动生成编号
	 * @author Tujt 2014-05-13
	 */
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['potential_no']=$value;
    

}
crm_load_function_file("getEditCommonSmarty",'include/utils','EditViewUtils');
//布局规则和新增编辑界面都会用到该函数
getEditCommonSmarty($smarty,'',$currentModule,$focus,$mode);



$smarty->assign('ISADMIN',$current_user->is_admin);
$smarty->assign("OP_MODE",$disp_view);
$category = getParentTab();
$smarty->assign("CATEGORY",$category);

//needed when creating a new opportunity with a default lingdang_account value passed in
if (isset($_REQUEST['accountname']) && is_null($focus->accountname)) {
	$focus->accountname = $_REQUEST['accountname'];
}
if (isset($_REQUEST['accountid']) && is_null($focus->related_to)) {
	$focus->related_to = $_REQUEST['accountid'];
}
if (isset($_REQUEST['contactid']) && is_null($focus->related_to)) {
	$focus->related_to = $_REQUEST['contactid'];
}

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";


if (isset($focus->name))
$smarty->assign("NAME", $focus->name);
else
$smarty->assign("NAME", "");

if(isset($cust_fld))
{
        $smarty->assign("CUSTOMFIELD", $cust_fld);
}
if($focus->mode == 'edit')
{
	//$smarty->assign("UPDATEINFO",updateInfo($focus->id));
	$smarty->assign("MODE", $focus->mode);
}
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

/*
$smarty->assign("CALENDAR_LANG", $app_strings['LBL_JSCALENDAR_LANG']);
$smarty->assign("CALENDAR_DATEFORMAT", parse_calendardate($app_strings['NTC_DATE_FORMAT']));
*/
if (isset($_REQUEST['return_module']))
$smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
if (isset($_REQUEST['return_action']))
$smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if (isset($_REQUEST['return_id']))
$smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['return_viewname']))
$smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
$smarty->assign("ID", $focus->id);
$smarty->assign("MODULE",$currentModule);

$smarty->assign("SINGLE_MOD",'Potential');


 $tabid = getTabid("Potentials");
 $data =$focus->fieldobj->split_validationdataArray();

 $smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
 $smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
 $smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
//fix for potential duplicate header
$smarty->assign("DUPLICATE",vtlib_purify($_REQUEST['isDuplicate']));

//$check_button = Button_Check($module);
//$smarty->assign("CHECK", $check_button);

global $adb;


/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));

/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/

if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
   
   
    $smarty->assign('CREATE','true');
}
else
{
    
     $smarty->assign('CREATE','false');
}
//获取客户和联系人区块信息
$block_info = getBlockDisplayInfo('AccountContacts');
//显示位置
$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
 //是否显示
if($block_info['is_display'] == 0)
    $smarty->assign('BESTATUS','YES');
else
    $smarty->assign('BESTATUS','NO');
    
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

//@edit:liushuai,2021-07-05,reason:0046710: （http://marrscrm.xicp.vip:34103/crm [^]）客户问题（邬丹华），项目报备（原销售机会）模块，不启用产品分录明细时，单据新建界面没有显示【保存并提交审批】按钮
//新增、编辑单据可直接保存并提交审批
$approveobj=Approve::getInstance($currentModule);
$approve_arr=[];
global $weixin_user;
if($focus->id>0)
{
    if(!array_key_exists('approvestatus',$focus->column_fields)&&empty($focus->column_fields['approvestatus']))
    {
        //审批状态字段隐藏
        $sql= "select approvestatus from "  .$focus->table_name." where "  .$focus->table_index."=?";
        $result=$adb->pquery($sql,array($focus->id));
        $focus->column_fields['approvestatus']=$adb->query_result($result,0,0);

    }
    $status=$approveobj->getApproveStatus($focus->column_fields['approvestatus']);
    if($status==0||$status==3 ||$status==4 || ($status == 2 && $approveobj->recordAgainSubmit($currentModule)))
    {
        $weixin_user->action='default_on_submit';
        $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);
    }
}
else{
    $weixin_user->action='default_on_new';
    $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);

}
$smarty->assign("APPROVE_ARR",$approve_arr);

//editor:gyq_76 reason:呼叫中心来电弹屏增加创建销售机会 2018/8/23 17:09 
if($_REQUEST['callfilename']||$_REQUEST['callphone'])
{   // //editor:gyq_20181030 reason:单据创建增加销售机会
    
 

}
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
    $qcreate_array = $focus->fieldobj->QuickCreate();

    $smarty->assign("QUICKCREATE", $qcreate_array['form']);
    if (sizeof($qcreate_array['form']) <= 0) {
        $quickcreatestr = "##noquickdata##";
    } else
        $quickcreatestr = $smarty->fetch("DetailView/PopupEditQuickCreate.tpl");
    $data = $focus->fieldobj->split_validationdataArray();
    $str = $smarty->fetch("DetailView/PopupEditRelated.tpl");
    
    $_REQUEST['diony'] = 'diony';

    //zxm 2021-0902 结尾返回的arr提取
    require_once 'modules/lingdang/CommonEditViewReturn.php';
    $CommonEditViewReturnObj = new CommonEditViewReturn();
    $arr = $CommonEditViewReturnObj->getReturnArr($focus);
    //duan 2022-2-14 销售线索增加'升级到客户和销售机会选项'判断是否需要升级到销售机会
    if(isset($_REQUEST['upgradetomodule'])&&$_REQUEST['upgradetomodule']!=''){
        $arr['upgradetomodule']=$_REQUEST['upgradetomodule'];
        $arr['fromid']= $_REQUEST['fromid'];
    }
    $arr['mainfieldformula']=$focus->fieldobj->getFormula();
    $arr['picklistcontent'] = $global_pick_list_values;
    $arr['approve_arr']=$approve_arr;
    $arr['content'] = $quickcreatestr;
    $arr['allcontent'] = $str;
    $arr['fieldname'] = $data['fieldname'];
    $arr['datatype'] = $data['datatype'];
    $arr['fieldlabel'] = $data['fieldlabel'];
    $arr['fields'] = $fields['fields'];
    $arr['filejsondata'] = $fieldjsondata;
    //$arr['columnfields_value'] = $focus->column_fields;
    $arr['picklistDependencyDatasource'] = $picklistDependencyDatasource;
    $arr['picklistdepencyfields'] = $global_pick_list_depencyfield;
    //wym 240321 XUQIU20240204-09 销售线索可编辑追踪字段
    $arr['isduplicate'] = getTabDuplicate($currentModule);
    $arr['upgradefromid']=0;
    $arr['upgradefrommodule']='';
    if($_REQUEST['upgradefrommodule']!=''&&$_REQUEST['upgradefromid']>0)
    {
        $arr['isduplicate']='yes';
        $arr['upgradefromid']=$_REQUEST['upgradefromid'];
        $arr['upgradefrommodule']=$_REQUEST['upgradefrommodule'];
        $arr['upgradestatus']=$_REQUEST['upgradestatus'];

    }
    if(isset($_REQUEST['upgradetomodule'])&&$_REQUEST['upgradetomodule']!=''){
        $arr['upgradetomodule']=$_REQUEST['upgradetomodule'];
        $arr['upgradestatus']=$_REQUEST['upgradestatus'];
    }
    //duan 20240124 在编辑页面结尾对返回值增加统一操作
    $arr = $CommonEditViewReturnObj->setReturnArr($arr);

    ConvertTojsonString(1, $arr, "success");

?>