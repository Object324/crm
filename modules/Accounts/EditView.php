<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
global  $currentModule, $theme;
global $adb;
//require_once('Smarty_setup.php');
//require_once('modules/Accounts/Accounts.php');
$smarty = new lingdangCRM_Smarty();
$smarty->assign("ISADMIN",is_admin($current_user));
$focus = CRMEntity::getInstance($currentModule);
$account_field_obj =Field::getInstance('Accounts',$adb);
$fieldobj=$focus->fieldobj;

$record = $_REQUEST['record'];
$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);
$publicaccount=0;
//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
//4600 ends
 $focus->column_fields["contactid"]=0;
if($record) {
	$focus->id = $record;
	$focus->mode = 'edit';
	$focus->retrieve_entity_info($record, $currentModule);
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
    if(!empty($fieldinfo) && $focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
    {
        crm_load_class_file('cls_CurUserDataScope','include/ListView');
        $datascopeobj=cls_CurUserDataScope::getInstance('Accounts','record');
        $datascopeobj->isMyViewData($_REQUEST['record']);
    }
	$publicaccount = $focus->column_fields['publicaccount'];
  //$smarty->assign("PUBLICACCOUNT",$focus->column_fields['publicaccount']);//复制公海客户，新增的客户应该为公海客户
    /*
     *更新操作
     *edit:diony
     *data:20131121
     *reason:客户是否启用审批流程
    */
   if($isduplicate!==true&&$isduplicate!='true')//如果不是复制
   {
     $deployarray=getSys_deploy(11);
       $num = $deployarray['deploy_value'];
        if($num == 0)
        {
            //审批流程begin
            //判断单据的审批状态，如果是已审批或者审批中，小编辑功能失效
            //require_once('modules/Approve/Approve.php');
            //$approve=new Approve();
			$approve = Approve::getInstance('Accounts');
            if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
                echo $approve->EditBlocks($focus->column_fields['assigned_user_id'],$focus->id);
                exit();
            }
            //审批流程end
        }
        
   }
   
    /*
    更新操作
    edit:cdw
    date:20131028
    reason:执行修改负责人、分配等操作导致客户负责人变更时，
           根据系统参数控制生成短信通知。
    */
    $smarty->assign("ASSIGNUSERID",$focus->column_fields["assigned_user_id"]);
    $sqlcontact='select columnname,tablename,fieldname from ld_field where tabid=6 and tablename in(?,?) and presence in(0,2)';
    $resultcontact=$adb->pquery($sqlcontact,array('ld_contactdetails','ld_contactscf'));
    $contactcolumns=Array();
    $contactfieldnames=Array();
    for($i=0;$i<$adb->num_rows($resultcontact);$i++)
    {
        $contactcol=$adb->query_result($resultcontact,$i,'columnname');
        $tablename=$adb->query_result($resultcontact,$i,'tablename');
        $fieldname=$adb->query_result($resultcontact,$i,'fieldname');
        $contactfieldnames[]=$fieldname;
        $contactcolumns[]=$contactcol;
        
    }
    $columns=implode(',',$contactcolumns);
  //inner join ld_crmentity on ld_crmentity.crmid=ld_contactdetails.contactid
	 $sqlcontact="select $columns,ld_contactdetails.contactid from ld_contactdetails 
	  left join ld_contactscf on ld_contactscf.contactid=ld_contactdetails.contactid
	  where accountid=? and reference=1 and ld_contactdetails.deleted=0 order by contact_no asc limit 0,1";
    $resultcontact=$adb->pquery($sqlcontact,array($focus->id));
    $contactfieldjsondata = array();
    if($adb->num_rows($resultcontact)>0)
    {
        
      
        for($i=0;$i<sizeof($contactfieldnames);$i++)
        {
            $focus->column_fields[$contactfieldnames[$i]]=$adb->query_result($resultcontact,0,$contactcolumns[$i]);
        }
        if($isduplicate != 'true') {
            $smarty->assign("CONTACTID",$adb->query_result($resultcontact,0,'contactid'));	
        }
        $contactid = $adb->query_result($resultcontact,0,'contactid');
        $focus->column_fields["contactid"]=$contactid;
        
        $contactfieldjsondata=getAllFile_imageInfo($contactid,'Contacts');
        foreach($contactfieldjsondata as $tmp_columname => $fileinfo){
            if($tmp_columname == 'filename'){
                $new_columnname = $tmp_columname.'_mapping';
                $contactfieldjsondata[$new_columnname] = $fileinfo;
                unset($contactfieldjsondata[$tmp_columname]);
            }
        }
    }
    else
    {
       
    }
    
}

if($isduplicate===true||$isduplicate=='true')
{
    $focus->mode='create';
    $focus->id='';
	/**
	 * 复制时，负责人设置为自己
	 * @author Tujt 2015-07-20
	 */
      //单据复制，默认值设置,https://www.tapd.cn/my_worktable?source_user=2004112531&workspace_id=20699121&workitem_type=story&workitem_id=1120699121001000517#&filter_close=true
//	$focus->column_fields['assigned_user_id'] = $current_user->id;
	if(empty($focus->column_fields['publicaccount'])){
		$publicaccount = $focus->getAccountPublicAccount($record);
	}
}

if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
	setObjectValuesFromRequest($focus);
}


$disp_view = getView($focus->mode);



/**
 *@edit: andy 
 *@date: 20141120
 *@reason:市场活动关联创建客户客户来源默认选中市场活动 
 *@version: v5.9
 */
if(isset($_REQUEST['campaignid']) && $_REQUEST['campaignid']>0){
   $_REQUEST['return_module']='Campaigns';//16118: 客户>明细>相关信息：联系人、销售机会列表，点击【跟进】按钮，保存后，页面跳转到了联系人、销售机会列表。edit:can
   $_REQUEST['return_id']=$_REQUEST['campaignid'];
    if(array_key_exists('leadsource',$focus->column_fields)){
        //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 下午 5:05
        crm_load_class_file("cls_PickList", 'modules/PickList');
        $objpinklist = new cls_PickList();
        $result_pick = $objpinklist->juedgePickListValues('leadsource','市场活动');
        /*$sql_pick="select 1 from ld_leadsource where leadsource='市场活动'";
        $result_pick=$adb->pquery($sql_pick,array());*/
        if(count($result_pick)>0)//有无此下拉选项
            $focus->column_fields['leadsource']='市场活动';
    }
}
if(isset($_REQUEST['return_module']))   
{
    $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
    
} 
if(isset($_REQUEST['return_action']))    $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if(isset($_REQUEST['return_id']))        $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['return_viewname'])) $smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
/**
 * 创建单据时，编号为自动生成后的编号
 * @project 创建单据时，自动生成编号
 * @author Tujt 2014-05-13
 */
if($focus->mode!='edit'||$_REQUEST['isDuplicate']=='true'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($currentModule);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['account_no'] = $value;
}

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
    //zkt 20240711 BUG20240709-41 销售线索升级客户，附件没带上去（kfbcrm也有这个问题）---关联需求：XUQIU1000897
    $fieldjsondata=$mapped_arr['mapped_fieldjsondata'];
    if(is_array($focus->fieldjsondata) && sizeof($focus->fieldjsondata)>0){
        $focus->fieldjsondata = array_merge($focus->fieldjsondata,$fieldjsondata);
    }
    else{
        $focus->fieldjsondata = $fieldjsondata;
    }
}


$version_info = getVersionInfo();
/** 赛克
* edit: chj
* date: 2020-07-21
* reason: 电话呼入时，根据呼入的电话号码，调用赛克出行api，获取订单信息
*/
if($version_info['account'] == 'saic'){
	if($focus->mode == 'edit'){
		$_REQUEST['saic_mobile'] = $focus->column_fields['accountname'];
	}else{
		//$_REQUEST['saic_mobile'] = '';
		/*if(empty($_REQUEST['saic_mobile'])){
			$_REQUEST['saic_mobile'] = '021-58659921';
		}*/
	}
	//if(!empty($_REQUEST['saic_mobile'])){
		$smarty->assign('SAIC_MOBILE',$_REQUEST['saic_mobile']);
		crm_load_class_file('cls_saic_api','modules/Accounts');
		$cls_saic_api = new cls_saic_api();
		$orderlist = $cls_saic_api->getOrderListLog($_REQUEST['saic_mobile']);
		$focus->column_fields['accountname'] = $_REQUEST['saic_mobile'];
		$focus->column_fields['cf_2832'] = $_REQUEST['saic_mobile'];
		$focus->column_fields['cf_2830'] = $_REQUEST['saic_ivrnode'];
		$focus->column_fields['accounttype'] = $_REQUEST['saic_linetype'];
		$smarty->assign('ORDERLISTLOG',$orderlist);
	//}
	
	
}
/* 关联创建单据统一处理方法 end */
global $global_pick_list_values;
global $global_pick_list_values,$edit_column_fields_value;
$act_data=getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));
/**
* 更新操作
* edit:can
* date:20131223
* reason:添加富文本框
* */
$richText=$act_data['RichText'];
unset($act_data['RichText']);
$smarty->assign('BLOCKS', $act_data);
if(!empty($richText))
	$smarty->assign('RICHTEXTBOX',implode(',',$richText));
else
	$smarty->assign('RICHTEXTBOX','');
$smarty->assign('RICHTEXTCOUNT',is_array($richText)?sizeof($richText):0);
    //Edit by LD Can 本版本用不到这两个变量
  
$smarty->assign('OP_MODE',$disp_view);


$smarty->assign('MODULE', $currentModule);
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
	$focus->mode = '';
}
// TODO: Update Single Module Instance name here.
$smarty->assign('SINGLE_MOD', 'SINGLE_'.$currentModule);
$smarty->assign('CATEGORY', $category);
$smarty->assign("THEME", $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('ID', $focus->id);
$smarty->assign('MODE', $focus->mode);
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

if($focus->mode == 'edit' || $isduplicate) {

	$recordName = $focus->column_fields[$focus->list_link_field];
	$smarty->assign('NAME', $recordName);
//	$smarty->assign('UPDATEINFO',updateInfo($record));
}

if(isset($_REQUEST['SearchScope'])) $smarty->assign("SEARCHSCOPE",$_REQUEST['SearchScope']);
$data=$fieldobj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

$fields=$focus->fieldobj->getFieldListArray();

// $toolfields['fields']=
$smarty->assign("DUPLICATE", vtlib_purify($_REQUEST['isDuplicate']));
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
//$global_pick_list_depencyfield=lingdang_DependencyPicklist::getPickListDepencyFields($currentModule);

$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);


/**
* edit:chj
* date:2014-6-20
* reason:教育模塊 班級新增學員
*/
$smarty->assign('PROJECTID',$_REQUEST['projectid']);
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
if( ($_REQUEST['relatedcreate']=='yes')|| $_REQUEST['isDuplicate']=='true'||(isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')))
{
  
    $smarty->assign('CREATE','true');
}
else
{
  
     $smarty->assign('CREATE','false');
}

$is_rel_list = array();
//$is_rel_list = isPresentRelatedLists($currentModule);
if(get_callLinkDisplay() == 'no'){
    	unset($is_rel_list[f_array_search('CallButler',$is_rel_list)]);
}


if($_REQUEST['publicaccount'])
{
    $publicaccount=$_REQUEST['publicaccount'];
}
crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
$cls_PublicAccounts = new cls_PublicAccounts($currentModule);
$public_account = $cls_PublicAccounts->getPublicAccount();
//$status=getAccount_Set('status');
if($public_account['status'] != 'yes')
{
    $publicaccount=0;
}
$smarty->assign('PUBLICACCOUNT',$publicaccount);
//ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块（新建及快速创建、复制时判断上限）
if ($focus->mode != 'edit' && $publicaccount == 0) {
    if($_REQUEST['upgradefrommodule']!=''&&$_REQUEST['upgradefromid']>0) {//线索升级上来的默认是普通客户
        //判断是否允许新建普通客户
        $leads_focus = CRMEntity::getInstance('Leads');
        $leads_focus->retrieve_entity_info($_REQUEST['upgradefromid'], 'Leads');
        $tmp_smowner = $leads_focus->column_fields['assigned_user_id'];
    }else{
        //判断是否允许新建普通客户
        $tmp_smowner = $current_user->id;
    }
    $limit_count = $focus->getCommonAccountLimitCount($tmp_smowner);//普通客户数量上限
    if($limit_count<9999999999)
    {
        $haved_count = $focus->getSmowerNumForCommonAccount($tmp_smowner);//已有客户数量
        if ($limit_count <= $haved_count) {
            ConvertTojsonString(-1,[],$public_account['status']=='yes'?getFixedLabel('CreateReacheMaximumError1'):getFixedLabel('CreateReacheMaximumError'));
        }
    }

}

//diony 2014-10-15 弹屏新增时自动传值
if(isset($_REQUEST['callphone']) && $_REQUEST['callphone'] != '')
{
    $smarty->assign('CALLPHONE',$_REQUEST['callphone']);
}
if(isset($_REQUEST['potential_id']) && $_REQUEST['potential_id'] != '')
{
	$smarty->assign('potential_id',$_REQUEST['potential_id']);
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
}
else
{
    $smarty->assign('CALLDISPLAY','no');
}
if(vtlib_isModuleActive('Contacts'))
	$smarty->assign('CONTACTSSTATUS','yes');
else
	$smarty->assign('CONTACTSSTATUS','no');
/* editor:gyq_11 reason:九维呼叫通话记录id date:20160603*/
if(!empty($_REQUEST['jiuweiid'])){
    $smarty->assign('JiuWeiAccount',$_REQUEST['jiuweiid']);
    $smarty->assign('CALLCENTERSWITCH',$_REQUEST['callcenter_switch']);
}

$smarty->assign('VERSIONTRADE',$version_info['trade']);
$smarty->assign('VERSIONACCOUNT',$version_info['account']);

/*$smarty->assign('ACCOUNTLISTBUS',1);
$regop=RegOp::getInstance();
$business_searchlike=$regop->getbusiness_searchlike();
$business_searchenddate=$regop->getbusiness_searchlike_enddate();
if($business_searchlike==1&&$business_searchenddate>=date("Y-m-d"))
    $smarty->assign('ACCOUNTLISTBUS',0);*/
$qcreate_array=$focus->fieldobj->QuickCreate();
$smarty->assign('quickcreate_publicaccount',$_REQUEST['quickcreate_publicaccount']);
$smarty->assign("QUICKCREATE", $qcreate_array['form']);
setGLobalURLSmarty($smarty);//设置js,css等访问路径
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

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
        $weixin_user->environment='pc';
          $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);
    }
}
else{
     $weixin_user->action='default_on_new';
    $weixin_user->environment='pc';
    $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);
    
}
$smarty->assign("APPROVE_ARR",$approve_arr);
if(sizeof($qcreate_array['form'])<=0)
{
    $quickcreatestr="##noquickdata##";
}
else
$quickcreatestr=$smarty->fetch("DetailView/PopupEditQuickCreate.tpl");

$str=$smarty->fetch("DetailView/PopupEditRelated.tpl");
/*if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')!='')
            $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')]=json_decode( getAttachmentsTableInfo($focus->id,$currentModule));
        if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')!='')
            $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')]= json_decode(getImageFileInfo($focus->id,$currentModule));*/
//wym BUG0074511 当关联创建模块包含附件或图片类型的引用字段时，focus对象上有fieldjsondata（此时foucs->id无值）
$fieldjsondata = empty($focus->fieldjsondata)?array():$focus->fieldjsondata;

if(($focus->id>0||$_REQUEST['record']>0)&&$focus->fieldobj->getFieldInfoBykeyValue('bigtype','fileattachment','fieldname')!='')
{
    if($focus->id>0){
        $tmp_record = $focus->id;
    }else if($_REQUEST['record']>0){ //edit:duan date:2021-9-30 复制的时候带出附件信息
        $tmp_record = $_REQUEST['record'];
    }
    $fieldjsondata=getAllFile_imageInfo($tmp_record,$currentModule);
    
    if(is_array($contactfieldjsondata) && sizeof($contactfieldjsondata)>0){
        $fieldjsondata = array_merge($contactfieldjsondata,$fieldjsondata);
    }
}
$fromuitype=array();
//市场活动管理创建联系人和客户等类似功能
$arr['tablerelfields']="";
if($_REQUEST['frommodule']&&$_REQUEST['fromid']>0)
{
    $fromuitype=cls_module_uitype::getModuleUitype("Accounts",$_REQUEST['frommodule']);

    if(empty($fromuitype))
    {
        $arr['tablerelfields']=array('module'=>$_REQUEST['frommodule'],'fromid'=>$_REQUEST['fromid']);
    }
    if(isset($_REQUEST['frommodule']) && $_REQUEST['frommodule']=='Project' && getEduType('Edu') == true)
    {
        $arr['tablerelfields']=array('module'=>$_REQUEST['frommodule'],'fromid'=>$_REQUEST['fromid']);
    }
}

 //布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
 
 
if($_REQUEST['callfilename1111']||$_REQUEST['callphone1111'])
{
    $smarty->assign("PICKLISTDEPENCYFIELDS",ldcrm_json_encode($global_pick_list_depencyfield));
    $smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
    $smarty->assign('FIELDINFOJSON',ldcrm_json_encode($fields['fields']));
    $smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
    ///保存判断
    $smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
	$smarty->assign("VALIDATASAVERULE",ldcrm_json_encode(getAllRule($currentModule)));
    $smarty->display("DetailView/EditRelated.tpl");
    
}
else
{
    global $global_picklist_colors,$global_picklist_colors_byvalue;
    $arr['global_picklist_colors_byvalue']=$global_picklist_colors_byvalue;
    $smarty->assign("global_pick_list_colors_byvalue",json_encode($global_picklist_colors_byvalue));

    $_REQUEST['diony']='diony';
    $arr['picklistcontent']=$global_pick_list_values;
    if (isset($_REQUEST['is_linkmodulecustom']) && $_REQUEST['is_linkmodulecustom'] == '1') {
        require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
        $arr['title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($currentModule);
    } else {
        $arr['title'] = getTranstab($currentModule);
    }
    //zxm 2021-0701 新建编辑页面增加页面设置按钮 判断是否有页面设置按钮
    $settingsBtn = $focus->getModuleLogic($currentModule)->getSettingsBtn();
    $is_page_setting = "no";
    if(isset($settingsBtn['Settings'])&&$settingsBtn['Settings']['permit']=='yes'){
        $is_page_setting = "yes";
    }
    $arr['is_page_setting'] = $is_page_setting;
    //edit:can 20210719 46993: （https://81mis.com/kfbcrm [^]）（客户问题-需要补丁）系统设置-单据编号定制，设置客户的编号为城市拼音首字母，当城市字段设置默认值时编号没有效果，需手动选择后才有
    $arr['systemcodenumprefixtype']= $focus->Library('SystemCode')->getModentityfield('prefixtype',$currentModule);
    $arr['approve_arr']=$approve_arr;
    $arr['mainfieldformula']=$focus->fieldobj->getFormula();
    $arr['savesubmittext']=getFixedLabel('SaveSubmitApprove');
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['content']=$quickcreatestr;
    $arr['allcontent']=$str;
    $arr['fieldname']=$data['fieldname'];
    $arr['datatype']=$data['datatype'];
    $arr['fieldlabel']=$data['fieldlabel'];
    $arr['fields']=$fields['fields'];
    $arr['filejsondata']=$fieldjsondata;
    $arr['isadmin']=$current_user->is_admin;
    ///保存判断
    $arr["validatasave"]=getValidataSave($currentModule);
	$arr["validatasaverule"]=getAllRule($currentModule);
    $arr['columnfields_value']=$focus->column_fields;
    $arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
    $arr['picklistdepencyfields']=$global_pick_list_depencyfield;
	$arr['isduplicate'] = getTabDuplicate($currentModule);
    $arr['upgradefromid']=0;
    $arr['upgradefrommodule']='';
    if($_REQUEST['upgradefrommodule']!=''&&$_REQUEST['upgradefromid']>0)
    {
        $arr['isduplicate']='yes';
        $arr['upgradefromid']=$_REQUEST['upgradefromid'];
        $arr['upgradefrommodule']=$_REQUEST['upgradefrommodule'];
        $arr['upgradestatus']=$_REQUEST['upgradestatus'];//wym 240321 XUQIU20240204-09 销售线索可编辑追踪字段
        //duan 2022-2-14 销售线索增加'升级到客户和销售机会选项'判断是否需要升级到销售机会
        if(isset($_REQUEST['upgradetomodule'])&&$_REQUEST['upgradetomodule']!=''){
            $arr['upgradetomodule']=$_REQUEST['upgradetomodule']; 
        }
    }
    //布局规则
    crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
    $fieldruleobj=cls_fieldrule::getInstance($currentModule);
    $arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发字段
    //敏感规则 zkt 20231116 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
    crm_load_class_file('cls_fieldSensitiverule','include/fields');
    $fieldSensitiveruleobj=cls_fieldSensitiverule::getInstance($currentModule);
    $arr['sensitiverelatedfield']=$fieldSensitiveruleobj->getAllRealtedfieldbyfieldname();//获取所有的触发字段

    //duan 20240923 在编辑页面结尾对返回值增加统一操作
    crm_load_class_file('CommonEditViewReturn','modules/lingdang');
    $CommonEditViewReturnObj = new CommonEditViewReturn();
    $arr = $CommonEditViewReturnObj->setReturnArr($arr);

    ConvertTojsonString(1,$arr,"success");
}
?>