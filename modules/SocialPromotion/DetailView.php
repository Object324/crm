<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user;
require_once(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');


global $currentModule,$adb;
global $theme;
$focus = CRMEntity::getInstance($currentModule);
$fieldObj=$focus->fieldobj;
$moduleFields=$fieldObj->getModuleFields();

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
}
//需要展示的列名
//BUG0056458 表单推广单据查看详情界面，将负责人字段显示出来
$columnnames = array('activityname','sharetitle','shareintroduction','mappingmodule','smcreatorid','smownerid','createdtime','modifiedtime');
$showFields=array(); //detailView 需要的字段 名称及值
if(!isset($_REQUEST['record']) || $_REQUEST['record']=='') {
    throw new Exception('record error');
}


$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty = new lingdangCRM_Smarty;
$focus->id=$_REQUEST['record'];
$focus->retrieve_entity_info($_REQUEST['record'],'SocialPromotion');

//手机展示的活动标题和介绍
$smarty->assign('activitytitle',$focus->column_fields['activitytitle']);
$smarty->assign('activityintroduction',$focus->column_fields['activityintroduction']);
$smarty->assign('buttoncolor',$focus->column_fields['buttoncolor']);
$smarty->assign('formheadcolor',$focus->column_fields['formheadcolor']);
$smarty->assign('buttonname',$focus->column_fields['buttonname']);
//实时手机显示的内容
//获取自定义字段

$customFields = json_decode($focus->column_fields['customfieldsorder'],true);
foreach ($customFields as $key=>$field){
    if($field['bigtype'] =='picklist'){
        $customFields[$key]['pickListValue'] = explode(';',$field['pickListValue']);
    }
}
$smarty->assign('customFields',$customFields);

//获取当前id的负责人
$sql = 'select smownerid  from ld_socialpromotion where socialpromotionid=?';
$result = $adb->pquery($sql,array($_REQUEST['record']));
$smownerid = $adb->query_result($result,0,0);
//最右侧二维码等信息
crm_load_class_file('cls_share','include/Functions/Share');
$objShare = new cls_share();
$shareUsers  = $objShare->getSelectedUser($_REQUEST['record']);
// @edit:dong @date:2020/07/13 @reason: 创建人 负责人和 共享人 合并去重
$shareUsers = array_filter(array_unique(array_merge(array($focus->column_fields['smcreatorid']),array($smownerid),explode(',',$shareUsers['userid']))));

//二维码的php文件
$socialpromotionid = $focus->column_fields['record_id'];
//加载二维码配置文件
require_once ('SocialPromotionConfig.php');
$shareUserValue = makeUserQcrodeArr($prefix,$suffix,$htmlPath,$socialpromotionid,$qrcodePath,$currentModule,$shareUsers);

$smarty->assign('shareUserValue',$shareUserValue);
//end最右侧二维码等信息

/* 详情页按按钮begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
/* 详情页按按钮end */

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);

if(useInternalMailer() == 1) 
	$smarty->assign("INT_MAILER","true");


global $detail_column_fields_value;
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
//$detail_column_fields_value  $global_pick_list_values 通过getBlocks 后会赋值
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
$useBlocks= array();
foreach ($blocks as $fields){
    foreach($fields as $key=>$colFields){
        $useBlocks = array_merge($useBlocks,$colFields);
    }
}
$newFileds =array();
foreach ($useBlocks as $key=>$field){
    if(in_array($field['colname'],$columnnames)){
        if($field['colname'] == 'mappingmodule'){
            // @edit:dong @date:2020/07/15 @reason: 映射字段翻译为中文
            $newFileds[$key]['value'] = getTranstab($field['value']);
        }else{
            $newFileds[$key] = $field;
        }
    }
}
$newFileds = array_chunk($newFileds,2,true);
$newblocks[getFixedLabel('BASICINFORMATION')] = $newFileds;
//$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $newblocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
//放在getblock函数后面，否则会影响布局规则
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("SINGLE_MOD", 'SocialPromotion');
$smarty->assign("ID", $_REQUEST['record']);

//Security check for related list
$category = getParentTab();
$smarty->assign("CATEGORY",$category);

$tabid = getTabid("SocialPromotion");

//所有字段的验证信息
$data = $fieldObj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
$smarty->assign("MODULE",$currentModule);

//详细页面的tab 按钮
$is_rel_list = isPresentRelatedLists($currentModule);
$is_rel_list = Detail_Edit_View::setForeachRelatedLists($is_rel_list);
foreach ($is_rel_list as $k=> $is_rel) {
    foreach ($is_rel as $key => $value) {
        if ($value['related_module'] == 'SocialPromotionForm') {
            //wym BUG0076310 表单推广-详情页相关信息栏，不显示竖滚动条，无法查看所有数据
            $is_rel_list[$k][$key]['related_module'] = $currentModule;
            $is_rel_list[$k][$key]['related_modulelabel'] = getTranstab($focus->column_fields['mappingmodule']);
        } elseif ($value['related_module'] == 'SocialPromotionReport') {
            $is_rel_list[$k][$key]['related_modulelabel'] = getFixedLabel('STSTISTICS') . getFixedLabel('OFTENUSEREPORTWORD');
        }
    }
}


$smarty->assign("IS_REL_LIST",$is_rel_list);//相关信息
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid)); //打印

//加载配置
require_once ('SocialPromotionConfig.php');
$smarty->assign('activitytypeArr',json_encode($activitytypeArr));

//@Edit:luyx  @Date:2020-07-16  @Reason:社交推广没有审批
//$smarty->assign('APPROVEMOD','1'); //审批模块，是否加载审批历史
//$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图章

global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);

include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));

///保存判断
$smarty->assign("HAVEMODCOMMENTS",'no');
setGLobalURLSmarty($smarty);

$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';


$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

$_REQUEST['diony']='yes';
$fields=$focus->fieldobj->getFieldListArray();
$arr['fields']=$fields['fields'];

// @edit:dong @date:2020/07/14 @reason:  社交推广暂时不需要推进
/*//单据推进管理
crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance = new cls_module_advance($currentModule);
$smarty->assign('MODULEADVANCE',$cls_module_advance->get($focus->id));*/

$arr['picklistcontent']=$global_pick_list_values;
$arr['validatasave']=getValidataSave($currentModule);
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
$arr['picklistdepency']=$picklistDependencyDatasource;
$arr['column_fields_value']=$detail_column_fields_value;
//39473: (51mis.com.kfbtest)单据明细界面：表头标题后增加“详情”两字，例如客户模块，改为“客户详情”
// $arr['title']=getTranstab($currentModule).getFixedLabel('details1');
/** 
* @edit:diony 
* @date:2020-07-29 
* @reason:显示列表超链接lable和value 
* @description:【单据详情（查看）界面，弹出层标签显示优化】 https://www.tapd.cn/20699121/prong/stories/view/1120699121001000848
*/
$entityarray = getEntitynameInfo(getTabid($currentModule));
$fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname', $entityarray['fieldname']);
$languageType= getLanguageType($current_user);
if($languageType=='zh'){
    $colon = '：';
}
else {
    $colon = ':';
}
if (isset($_REQUEST['is_linkmodulecustom']) && $_REQUEST['is_linkmodulecustom'] == '1') {
    require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
    $arr['title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($currentModule);
} else {
    $arr['title'] = $fieldinfo->fieldLableKey . $colon . $focus->column_fields[$focus->list_link_field];
}
$arr['list_link_field']=$focus->list_link_field;
$arr['approvemod']=1;
$arr['pagenum']=$_REQUEST['pagenum'];

$arr['nextrecord']=0;
$arr['prevrecord']=0;
$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);

if(is_array($recordNavigationInfo))
{
    if(array_key_exists('nextrecordid',$recordNavigationInfo))
        $arr['nextrecord']=$recordNavigationInfo['nextrecordid'];
    if(array_key_exists("prevrecordid",$recordNavigationInfo))
        $arr['prevrecord']=$recordNavigationInfo['prevrecordid'];
}

//zkt 20230412 BUG0063083 kfbcrm表单推广----评论单据后---重新打开--评论不显示了---需要点击评论框右侧的高级选项才显示 
//获取系统参数358：设置明细界面评论功能是否显示在右侧
if(isPermitted('ModComments','index')=='yes'){
    $system_358 = getSys_deploy(358);
    $modcommentdisplayright = 'yes';
    if($system_358['deploy_value'] == 1){
        $modcommentdisplayright = 'no';
    }
	$smarty->assign('UIKEY',$focus->id);
    $smarty->assign("MODCOMMENTDISPLAYRIGHT",$modcommentdisplayright);
    $arr['modcommentdisplayright']=$modcommentdisplayright;
    $smownercolumnname = $focus->getSmownerColumName();
    $smownerfieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$smownercolumnname);
    if(!empty($smownerfieldinfo)){
        $smownerfieldname = $smownerfieldinfo->getFieldName();
        $userobj=new Users();
        $sql="select id,last_name,wx_userid from ld_users where id=? ";
        $userresult=$adb->pquery($sql,array($focus->column_fields[$smownerfieldname]));
        if($adb->num_rows($userresult)>0)
        {
            $userobj->id = $adb->query_result($userresult, 0, 'id');
            $userobj->wx_userid= $adb->query_result($userresult, 0, 'wx_userid');
            $userobj->last_name= $adb->query_result($userresult, 0, 'last_name');
            $smonerlastname = getUserlastName($userobj);
            $smarty->assign('SMOWERID',$focus->column_fields[$smownerfieldname]);
            $smarty->assign('SMOWERLastName',$smonerlastname);
        }
    }
}

//客户和联系人关联字段
//$block_info = getBlockDisplayInfo('AccountContacts');
//$smarty->assign('DISPLAY_POSITION',$_SESSION[globalStatic::$root_directory.'accountcontacts_display_position']);
//$smarty->assign('BESTATUS',$_SESSION[globalStatic::$root_directory.'accountcontacts_bestatus']);
//$arr['bestatus']=$_SESSION[globalStatic::$root_directory.'accountcontacts_bestatus'];

//$content=$smarty->fetch("modules/SocialPromotion/SocialDetailViewRelated.tpl");
$content=$smarty->fetch("DetailView/PopupDetailRelated.tpl");
$arr['content']=$content;

// zxm20230523 BUG0066867   表单推广右上角操作按钮不见了
$arr['detailButtons'] = getDetailViewBtns($currentModule,$focus);
$arr['imageArr'] = getDetailViewImage($currentModule,$focus);
$arr['detailsettings'] = array_values(array_reverse($focus->logic->detail_settings));//详情页设置按钮
$userinfo['isadmin']=$current_user->is_admin;
$userinfo['userid']=$current_user->id;
$arr['userinfo'] = $userinfo;
ConvertTojsonString(1,$arr,'success');


?>