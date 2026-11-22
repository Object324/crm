<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global   $theme, $currentModule, $current_user,$site_URL;

$focus = CRMEntity::getInstance($currentModule);
$fieldObj=$focus->fieldobj;
$smarty = new lingdangCRM_Smarty;

//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
//4600 ends
//加载配置
require_once ('SocialPromotionConfig.php');
$smarty->assign('activitytypeArr',json_encode($activitytypeArr));

if (isset($_REQUEST['record']) && $_REQUEST['record'] != '') {
    $focus->id = $_REQUEST['record'];
    $focus->mode = 'edit';
	$focus->retrieve_entity_info($_REQUEST['record'], "SocialPromotion");
	$focus->firstname = $focus->column_fields['firstname'];
	$focus->lastname = $focus->column_fields['lastname'];
    $smarty->assign("ACCOUNTID", $focus->column_fields['account_id']);
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
    if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
    {
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
    }
}


if (isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
	$focus->mode = "";
	/**
	 * 复制时，负责人设置为自己
	 * @author Tujt 2015-07-20
	 */
	$focus->column_fields['assigned_user_id'] = $current_user->id;
}
if (empty($_REQUEST['record']) && $focus->mode != 'edit') {
    setObjectValuesFromRequest($focus);
}

$disp_view = getView($focus->mode);

if($_REQUEST['step']){
    $smarty->assign('step',$_REQUEST['step']);
}else{
    //新建和编辑的时候第一次设置步骤为1
    $_REQUEST['step'] =1;
    $smarty->assign('step',$_REQUEST['step']);
}

/**
 * 创建单据时，编号为自动生成后的编号
 * @project 创建单据时，自动生成编号
 * @author Tujt 2014-05-13
 */
if($focus->mode!='edit'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['socialpromotion_no']=$value;
}
/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */

$smarty->assign('ISADMIN',$current_user->is_admin);
global $global_pick_list_values;
$act_data = getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);

$smarty->assign('siteUrl',$site_URL.'/');

    /**
    * 更新操作
    * edit:can
    * date:20131223
    * reason:添加富文本框
    * */
$richText=$act_data['RichText'];
unset($act_data['RichText']);

$smarty->assign("BLOCKS",$act_data);


//编辑的时候特殊赋值
if(!empty($_REQUEST['record'])){
    foreach ($act_data as $block){
        foreach ($block as $field){
            if($field[5] =='buttoncolor'){
                $buttoncolor =$field['value_name'];
            }
            if($field[5] == 'activityintroduction'){
                $activityintroduction = $field['value_name'];
            }
            if($field[5] == 'buttonname'){
                $buttonname = $field['value_name'];
            }
            if($field[5]=='formheadcolor'){
                $formheadcolor=$field['value_name'];
            }
        }
    }
    $smarty->assign('buttoncolor',$buttoncolor);
    $smarty->assign('buttonname',$buttonname);
    $smarty->assign('formheadcolor',$formheadcolor);
    $smarty->assign('activityintroduction',$activityintroduction);

//    获取单据的共享人
    crm_load_class_file('cls_share','include/Functions/Share');
    $objShare = new cls_share();
    $shareUsers  = $objShare->getSelectedUser($_REQUEST['record']);
    $smarty->assign('newShareUsers',$shareUsers['userid']);
    // @edit:dong @date:2020/7/10 @reason: 页面共享状态选中 1 选中 0 不选中
    $smarty->assign('shareUserType',count($shareUsers['userid'])>0 ? 1:0);
}



$smarty->assign("OP_MODE", $disp_view);

//needed when creating a new contact with a default lingdang_account value passed in
if (isset($_REQUEST['account_name']) && is_null($focus->account_name)) {
      $focus->account_name = $_REQUEST['account_name'];

}
if (isset($_REQUEST['account_id']) && is_null($focus->account_id)) {
      $focus->account_id = $_REQUEST['account_id'];
}

$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";

$smarty->assign("THEME", $theme);

$contact_name = $focus->lastname;
$contact_name .= ' ' . $focus->firstname;

$smarty->assign("NAME", $contact_name);
if (isset($cust_fld)) {
        $smarty->assign("CUSTOMFIELD", $cust_fld);
}
$smarty->assign("ID", $focus->id);
$smarty->assign("MODULE", $currentModule);
$smarty->assign("SINGLE_MOD", 'SocialPromotion');

if ($focus->mode == 'edit') {
	//$smarty->assign("UPDATEINFO", updateInfo($focus->id));
	$smarty->assign("MODE", $focus->mode);
}else{
    $smarty->assign("MODE", 'create');
}
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

if (isset($_REQUEST['activity_mode']) && $_REQUEST['activity_mode'] != '')
	$smarty->assign("ACTIVITYMODE", vtlib_purify($_REQUEST['activity_mode']));

if (isset($_REQUEST['return_module']))
 	$smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
if (isset($_REQUEST['return_action']))
 	$smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if (isset($_REQUEST['return_id']))
 	$smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['return_viewname']))
 	$smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=" . session_id() . $GLOBALS['request_string']);

$tabid = getTabid($currentModule);
$data = $fieldObj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME", $data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE", $data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL", $data['fieldlabel']);
$fields=$focus->fieldobj->getFieldListArray();

$fields['module']=$currentModule;
//$smarty->assign('FIELDINFOJSON',json_encode($fields));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());


$smarty->assign("DUPLICATE", vtlib_purify($_REQUEST['isDuplicate']));

global $adb;
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
   
    $smarty->assign('CREATE','true');
}
else
{
     $smarty->assign('CREATE','false');
}

/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);

//删除后picklist会点击错误
    if(empty($focus->id)||$isduplicate==true)
            $qcreate_array=$focus->fieldobj->QuickCreate();

    $smarty->assign("QUICKCREATE", $qcreate_array['form']);
    if(empty($qcreate_array['form']) || (is_array($qcreate_array['form']) && sizeof($qcreate_array['form'])<=0))
    {
        $quickcreatestr="##noquickdata##";
    }
    else
    $quickcreatestr=$smarty->fetch("DetailView/PopupEditQuickCreate.tpl");

    //end删除后picklist会点击

    $str=$smarty->fetch("modules/SocialPromotion/SocialPopupEditRelated.tpl");
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
    }

    $_REQUEST['diony']='diony';
    if (isset($_REQUEST['is_linkmodulecustom']) && $_REQUEST['is_linkmodulecustom'] == '1') {
        require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
        $arr['title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($currentModule);
    } else {
        $arr['title'] = getTranstab($currentModule);
    }

    if($_REQUEST['step'] ==4){
        $arr['lastStep']='1';
        $arr['oktext']=getFixedLabel("LBL_FINISH_BUTTON_LABEL"); //最后一步为完成。
    }else{
        $arr['oktext']=getFixedLabel("NEXTSTEP");
    }

    //去除下拉框的空白行
    foreach ($global_pick_list_values as $key =>$pick_list_value){
        unset($global_pick_list_values[$key]['optionvalue'][0]);
        $global_pick_list_values[$key]['optionvalue']= array_values($global_pick_list_values[$key]['optionvalue']);

        //映射单据字段下拉框翻译为模块中文名称
        if($pick_list_value['fieldname'] =='mappingmodule'){
            $value = $global_pick_list_values[$key]['optionvalue'];
            foreach ($value as $k=>$v){
                $global_pick_list_values[$key]['optionvalue'][$k][1] = getTranstab($v[0]);
            }
        }
    }



    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['backStep']=getFixedLabel("ASTEP");
    $arr['socialPromotionBack']=getFixedLabel("ASTEP");

    $arr['content']=$quickcreatestr;
    $arr['allcontent']=$str;
    $arr['fieldname']=$data['fieldname'];
    $arr['datatype']=$data['datatype'];
    $arr['fieldlabel']=$data['fieldlabel'];
    $arr['fields']=$fields['fields'];
    $arr['filejsondata']=$fieldjsondata;
    $arr['isadmin']=$current_user->is_admin;
    $arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
    $arr['columnfields_value']=$focus->column_fields;
    $arr['picklistcontent']=$global_pick_list_values;
    $arr['picklistdepencyfields']=$global_pick_list_depencyfield;
	$arr['isduplicate'] = getTabDuplicate($currentModule);
    ///保存判断
    $arr["validatasave"]=getValidataSave($currentModule);
    $arr["validatasaverule"]=getAllRule($currentModule);
    //布局规则
  //  crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
  //  $fieldruleobj=cls_fieldrule::getInstance($currentModule);
  //  $arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();
      $arr['fieldrulefieldnames']=array();
    ConvertTojsonString(1,$arr,"success");


?>