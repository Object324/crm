<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $app_strings;
global $mod_strings;
global $currentModule, $singlepane_view,$current_user;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$focus = CRMEntity::getInstance($currentModule);
$languageType= getLanguageType($current_user);
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) 
{
    $focus->retrieve_entity_info($_REQUEST['record'],$currentModule);
    $focus->id = $_REQUEST['record'];
    $focus->name=$focus->column_fields[$focus->list_link_field];
    
    
}
/*
 * edit:yangliu
 * date:2014-07-30
 * reason:明细界面更多按钮权限判断
 */
//$list_buttons_moreD=$focus->getListButtons_moreforD($app_strings,$mod_strings);

$smarty = new lingdangCRM_Smarty;

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
/* 详情页按钮 end */

////审批状态图片
//if(isset($focus->logic->approvebtn['info'])){//有审批
	//$approvestatus = $focus->logic->approvebtn['info']['approvestatus'];
	//if(empty($approvestatus)) $approvestatus = 0;
	//if($languageType=='en'){
		//$smarty->assign('APPROVESTATUS','approveresult'.$approvestatus.'_en.png');
	//}else{
		//$smarty->assign('APPROVESTATUS','approveresult'.$approvestatus.'.png');
	//}
//}

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') 
{
        $focus->id = "";
}

//$sqlstus="select confirmed from ld_bankaccountset where bankaccountsetid=".$_REQUEST['record']; 
//$reslutsturs = $adb->pquery($sqlstus);
//$confirmedst = $adb->query_result($reslutsturs,0,'confirmed');
$smarty->assign("CONFIRMEDST", $confirmedst);
$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);
if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");

global $detail_column_fields_value;
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",json_encode($detail_column_fields_value));
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("SINGLE_MOD", $currentModule);
$category = getParentTab();
$smarty->assign("CATEGORY",$category);
//$smarty->assign("UPDATEINFO",updateInfo($_REQUEST['record']));

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);

$smarty->assign("ID", vtlib_purify($_REQUEST['record']));



$tabid = getTabid($currentModule);
$data =$focus->fieldobj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);


$smarty->assign("MODULE",$currentModule);
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);

$smarty->assign("IS_REL_LIST",$is_rel_list);

//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
	//$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
	//VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}

$smarty->assign("SinglePane_View", $singlepane_view);

if(!$isedit)
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
/*$sql='select expensedetailid,expenseuse,expensetype,startdate,enddate,money,description from ld_expensedetail where expenseid=? order by sequence asc';
$result=$adb->pquery($sql,array($focus->id));
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $trExpense.='<tr id="row'.($i+1).'" style="vertical-align:top">';
            
    $trExpense.=' <td class="crmTableRow small">';
    $trExpense.=$adb->query_result($result,$i,'expenseuse');
    $trExpense.='</td>';
    $trExpense.=' <td class="crmTableRow small">';
    $trExpense.=$adb->query_result($result,$i,'expensetype').'</option>';
                
    $trExpense.='</td>';
    $trExpense.=' <td class="crmTableRow small">';
    $trExpense.=$adb->query_result($result,$i,'startdate');
           
    $trExpense.='</td>';
         
    $trExpense.=' <td class="crmTableRow small">';
    $trExpense.=$adb->query_result($result,$i,'enddate');
            
    $trExpense.='</td>';
            
    $trExpense.=' <td class="crmTableRow small">';
    $trExpense.=number_format($adb->query_result($result,$i,'money'),2);
    $trExpense.='</td>';
            
    $trExpense.=' <td class="crmTableRow small">';
    $trExpense.=$adb->query_result($result,$i,'description');
    $trExpense.='</td>';
            
    $trExpense.='</tr>';
}

$smarty->assign('FORMATTOTAL',number_format($focus->column_fields['hdnGrandTotal'],2));
$smarty->assign('TREXPENSE',$trExpense);    */

//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
 //if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
//	$smarty->assign("CREATEATTACHMENT","permitted");
//$smarty->display("DetailView.tpl");

//andy
//$tabid=getTabid($currentModule);
//$actions_arr_userd=GetAction_userd($tabid);
//$smarty->assign('actions_arr_userd',$actions_arr_userd);
////print_r($actions_arr_userd);
//if(count($actions_arr_userd) == 0)
    //$smarty->assign('action_show_no','yes');

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */
///保存判断
$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));

include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
setGLobalURLSmarty($smarty);//设置js,css等访问路径

//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';
//$smarty->display("DetailView/DetailRelated.tpl");
DetailViewReturn($currentModule,$focus,$smarty);
?>