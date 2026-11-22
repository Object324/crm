<?php

/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
 //zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $theme;
global $adb;

if($currentModule == 'ServiceCharge')
{
   // $accountvalue = "请输入客户名称进行查重";
//客户查重

    if(isset($_REQUEST['account_checkrepeat']) && $_REQUEST['account_checkrepeat'] != '')
    {
       
        $serviecharge_field_obj=Field::getInstance('ServiceCharge',$adb);
        $arrFieldlabels=$serviecharge_field_obj->getFieldLables();
        $jssonarr .="{\"Header\":[";
        $jssonarr .="{\"accountname\":"."\"".$arrFieldlabels['accountname']."\",\"accountno\":\"".$arrFieldlabels['account_no'].
                        "\",\"rating\":\"".$arrFieldlabels['rating']."\",\"createdtime\":\"".$arrFieldlabels['createdtime']."\"}";
        
        $accountname = $_REQUEST['account_checkrepeat'];
        $accountname = str_replace("\r\n","",$accountname);
        $sql = " select ld_account.accountname,ld_account.account_no,ld_account.rating,ld_account.createdtime from ld_account ";
        //$sql .= " inner join ld_crmentity ";
        //$sql .= " on ld_crmentity.crmid = ld_account.accountid ";
        $sql .= " where accountname like '%".$accountname."%' order by ld_account.account_no desc limit 5 ";
        
        $result = $adb->pquery($sql,array());
        $num_rows=$adb->num_rows($result);
       
        
        if($adb->num_rows($result)<=0)
        {
            echo "#error#".$jssonarr."]}";
            exit(); 
        }
        $accountinfo = "";
        $jssonarr.="],\"Content\":[";
       // $jssonarr="[";
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
          
            $jssonarr.="{\"accountname\":\"".$adb->query_result($result,$i,"accountname")."\",\"accountno\":\"".$adb->query_result($result,$i,"account_no").
                        "\",\"rating\":\"".$adb->query_result($result,$i,"rating")."\",\"createdtime\":\"".$adb->query_result($result,$i,"createdtime")."\"}";
            if($i!=$adb->num_rows($result)-1)
            {
                $jssonarr.=',';
            }
        }
        $jssonarr.="]}";
        echo "###SUCCESS###".$jssonarr;
        exit();    
    }
   
}
$focus =CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();
 $smarty->assign("accountvalue",$accountvalue);
$category = getParentTab($currentModule);
$record = $_REQUEST['record'];

$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);
//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
//4600 ends

if($record) {
	$focus->id = $record;
	$focus->mode = 'edit';
	$focus->retrieve_entity_info($record, $currentModule);
    /*
    更新操作
    edit:cdw
    date:20131028
    reason:执行修改负责人、分配等操作导致客户负责人变更时，
           根据系统参数控制生成短信通知。
    */
    $smarty->assign("ASSIGNUSERID",$focus->column_fields["assigned_user_id"]);
    $sqlcontact='select columnname,tablename,fieldname from ld_field where tabid in (6,102) and tablename in(?,?) and presence in(0,2)';
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

    if($adb->num_rows($resultcontact)>0)
    {
        for($i=0;$i<sizeof($contactfieldnames);$i++)
        {
            $focus->column_fields[$contactfieldnames[$i]]=$adb->query_result($resultcontact,0,$contactcolumns[$i]);
        }
        $smarty->assign("CONTACTID",$adb->query_result($resultcontact,0,'contactid'));
       
    }
}

//ls 2022-03-22 0050580: （https://kehu001.com/KH/kh30033 [^]）客户问题（普阳会计），客户（服务收费）（原“服务收费管理”模块），设置“省份”字段默认值后，新建界面没有生效
if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
    setObjectValuesFromRequest($focus);
}
//销售负责人默认为自己
$smarty->assign('assigned_user_id',$current_user->id);
$disp_view = getView($focus->mode);

if(isset($_REQUEST['return_module']))   
{
    $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
} 

if(isset($_REQUEST['return_action']))    $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if(isset($_REQUEST['return_id']))        $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['return_viewname'])) $smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true')
{
	$focus->id = "";
	$focus->mode = '';
}
/**
 * 创建单据时，编号为自动生成后的编号
 * @project 创建单据时，自动生成编号
 * @author Tujt 2014-05-13
 */
if($focus->mode!='edit'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord('Accounts');
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
/* 关联创建单据统一处理方法 end */
global $global_pick_list_values;
$act_data=getBlocks($currentModule, $disp_view, $focus->mode, $focus->column_fields);

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
$smarty->assign('ISADMIN',$current_user->is_admin);
$smarty->assign('OP_MODE',$disp_view);

$smarty->assign('MODULE', 'ServiceCharge');

// TODO: Update Single Module Instance name here.
$smarty->assign('SINGLE_MOD', 'SINGLE_'.$currentModule);
$smarty->assign('CATEGORY', $category);
$smarty->assign("THEME", $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('ID', $focus->id);
$smarty->assign('MODE', $focus->mode);
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

//$smarty->assign('CHECK', Button_Check($currentModule));
//$smarty->assign('DUPLICATE', $isduplicate);

if($focus->mode == 'edit' || $isduplicate) {
	
	$recordName = $focus->column_fields[$focus->list_link_field];
	$smarty->assign('NAME', $recordName);//获取客户名
}

if(isset($_REQUEST['SearchScope'])) $smarty->assign("SEARCHSCOPE",$_REQUEST['SearchScope']);
// Field Validation Information
$tabid = getTabid($currentModule);
$validationArray =$focus->fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$validationArray['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$validationArray['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$validationArray['fieldlabel']);
/*
$smarty->assign("CALENDAR_DATEFORMAT", parse_calendardate('yyyy-mm-dd'));
*/
global $adb;
/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow','Accounts');
$smarty->assign('ISALLOW',$isallow);
global $global_pick_list_depencyfield;
crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
   
    $smarty->assign('CREATE','true');
}
else
{
    
     $smarty->assign('CREATE','false');
}
/**
 * 客户编辑页面，增加更多信息左边栏
 * @author Tujt 2014-04-08
 */
//$smarty->assign("IS_REL_LIST",isPresentRelatedLists($currentModule));

/**
 * 基础版，销售通，因为只有合同订单模块，所以没必要显示往来对账
 * @author Tujt 2014-06-12
 */
$reg =RegOp::getInstance();
$testFile = $reg->isExistFile();
if($testFile == 0){//不存在
    require_once("VersionType.php");
    global $VersionNo;
    $RegisterVersionNo = $VersionNo;
}else{
    $RegisterVersionNo = $reg->GetVersionNo();
}
$modbalancestr = '';
if($RegisterVersionNo != '2'&&$RegisterVersionNo != '7'){//基础版，销售通不显示往来对账
	/**
	 * @project PROT21 龙威机械：往来对账
	 * @author Tujt 2014-06-06
	 */
	$modbalance = array('SalesOrder','CashBill','SalesBack','CashBack');
	if($current_user->is_admin == 'on'){
		foreach($modbalance as $mod){
			if(vtlib_isModuleActive($mod))
				$modbalancestr .= $mod.',';
		}
	}else{
		foreach($modbalance as $mod){
			if(isPermitted($mod,'index','')=='yes' && vtlib_isModuleActive($mod))
				$modbalancestr .= $mod.',';
		}
	}
	$modbalancestr = trim($modbalancestr,',');
}
$smarty->assign('MODBALANCESTR',$modbalancestr);


$publicaccount=0;
if($_REQUEST['publicaccount'])
{
    $publicaccount=$_REQUEST['publicaccount'];
}
$smarty->assign('PUBLICACCOUNT',$publicaccount);

$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$qcreate_array=$focus->fieldobj->QuickCreate();
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
$smarty->assign("QUICKCREATE", $qcreate_array['form']);
if(empty($qcreate_array['form']) || (is_array($qcreate_array['form']) && sizeof($qcreate_array['form'])<=0))
{
    $quickcreatestr="##noquickdata##";
}
else
$quickcreatestr=$smarty->fetch("DetailView/PopupEditQuickCreate.tpl");

$str=$smarty->fetch("DetailView/PopupEditRelated.tpl");
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
$_REQUEST['diony']='diony';
//zxm 2021-0902 结尾返回的arr提取
require_once 'modules/lingdang/CommonEditViewReturn.php';
$CommonEditViewReturnObj = new CommonEditViewReturn();
$arr = $CommonEditViewReturnObj->getReturnArr($focus);
$arr['picklistcontent']=$global_pick_list_values;
$arr['content']=$quickcreatestr;
$arr['allcontent']=$str;
$arr['fieldname']=$data['fieldname'];
$arr['datatype']=$data['datatype'];
$arr['fieldlabel']=$data['fieldlabel'];
$arr['fields']=$fields['fields'];
$arr['filejsondata']=$fieldjsondata;
//$arr['columnfields_value']=$focus->column_fields;
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
//duan 20240124 在编辑页面结尾对返回值增加统一操作
$arr = $CommonEditViewReturnObj->setReturnArr($arr);

ConvertTojsonString(1,$arr,"success");
?>