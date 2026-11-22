<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user,$currentModule,$theme,$singlepane_view;

$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty;
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"Quotes");
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
     if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
     {
      
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
     }
    $focus->id = $_REQUEST['record'];	
    $focus->name=$focus->column_fields[$focus->list_link_field];
    $smarty->assign('LASTVALINFO',getDetailListValName($_REQUEST['record'],'PurchaseInquiryOrder',1));	
}
//include('user_privileges/user_language_'.$current_user->id.'.php');
//if(isset($focus->logic->approvebtn['info'])){//有审批
	//$approvestatus = $focus->logic->approvebtn['info']['approvestatus'];
	//if(empty($approvestatus)) $approvestatus = 0;
	//if($languageType=='en'){
		//$smarty->assign('APPROVESTATUS','approveresult'.$approvestatus.'_en.png');
	//}else{
		//$smarty->assign('APPROVESTATUS','approveresult'.$approvestatus.'.png');
	//}
//}

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
/* 详情页按钮 end */

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";	
} 

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";



$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
 
if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");

global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
//$smarty->assign("COLUMN_FIELDS_VALUE",json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
//放在getblock函数后面，否则会影响布局规则
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("ID", vtlib_purify($_REQUEST['record']));

$smarty->assign("SINGLE_MOD",'Quote');
//$category = getParentTab();
//$smarty->assign("CATEGORY",$category);


$smarty->assign("CONVERTMODE",'quotetoinvoice');
$smarty->assign("MODULE", $currentModule);
//Get the associated Products and then display above Terms and Conditions
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$smarty->assign('ASSOCIATED_PRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'details'));//产品明细html


 $tabid = getTabid("Quotes");
 $data =$focus->fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list = Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);

$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
$smarty->assign("CONTACTID",$focus->column_fields['contact_id']);
$smarty->assign("POTENTIALID",$focus->column_fields['potential_id']);

$smarty->assign("SinglePane_View", $singlepane_view);

//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
  
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}

$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
 //if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
//	$smarty->assign("CREATEATTACHMENT","permitted");
//$smarty->display("Inventory/InventoryDetailView.tpl");
/**
 * 增加更多信息左边栏
 * @author Tujt 2014-04-10
 */

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */
 $smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
 //andy
//$tabid=getTabid($currentModule);
//$actions_arr_userd=GetAction_userd($tabid);
//$smarty->assign('actions_arr_userd',$actions_arr_userd);
////print_r($actions_arr_userd);
//if(count($actions_arr_userd) == 0)
    //$smarty->assign('action_show_no','yes');
/*
 * edit:yangliu
 * date:2014-07-30
 * reason:明细界面更多按钮权限判断
 * 判断数组是否为空
 */
// print_r($list_buttons_moreD);
//获取客户和联系人区块信息
$block_info = getBlockDisplayInfo('AccountContacts');
//显示位置
$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);

 //是否显示
if($block_info['is_display'] == 0)
    $smarty->assign('BESTATUS','YES');
else
    $smarty->assign('BESTATUS','NO');
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
//$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
//$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
///保存判断
//$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';
$smarty->assign("HaigeSaveTip",$_SESSION[$currentModule.'haigesavetip']);
$_SESSION[$currentModule.'haigesavetip']='';

/*相关信息日期高级查询
Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
//布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段

$smarty->display("DetailView/InventoryDetailRelated.tpl");*/
//海格增加“区域平均折扣信息”区块
$version_info = getVersionInfo();
$smarty->assign('VERSION_ACCOUNT',$version_info['account']);
if($version_info['account'] == 'haige' && $currentModule == 'Quotes'&&isset($_REQUEST['record']))
{
    $haigequoteid = $_REQUEST['record'];
    //zkt 20231228 BUG0078014 海格：区域平均折扣计算错误，没有按产品组分组，显示数据重复
    $haigesql = "select * from ( SELECT
	a.productgroup_name,
	CASE WHEN IFNULL(b.avg_discount,'')='' THEN '' ELSE CONCAT(FORMAT(b.avg_discount,2),'%') END AS avgvalue_banshichu,		
	CASE WHEN IFNULL(c.avg_discount,'')='' THEN '' ELSE CONCAT(FORMAT(c.avg_discount,2),'%') END AS avgvalue_area,			
	CASE WHEN IFNULL(a.zhekou,'')='' THEN '' ELSE CONCAT(a.zhekou,'%') END AS zhekou,	
	FORMAT(ROUND(a.amount,2),2) AS amount	
FROM (
	SELECT
		p.productgroup_id,
		p.productgroup_name,
		a.salesreg_id,
		a.banshichu,
		ROUND(SUM(b.tax_amount),2) AS amount,
		FORMAT(100-SUM(quantity*taxprice)*100/SUM(quantity*standardprice),2) AS zhekou
	FROM ld_quotes a
	LEFT JOIN ld_quotesdetail b ON b.id=a.quoteid
	LEFT JOIN ld_products p ON p.productid=b.productid
	WHERE a.quoteid=?
	GROUP BY p.productgroup_id
) a
LEFT JOIN (
	SELECT
		productgroup_id,
		area_id,
		area_name,
		avg_discount
	FROM ld_customform49
	WHERE deleted=0
        AND years=YEAR(NOW())-1
		AND bill_type='O'
) b ON b.productgroup_id=a.productgroup_id AND b.area_name=a.banshichu
LEFT JOIN (
	SELECT
		productgroup_id,
		area_id,
		area_name,
		avg_discount
	FROM ld_customform49
	WHERE deleted=0
        AND years=YEAR(NOW())-1
		AND bill_type='R'
) c ON c.productgroup_id=a.productgroup_id AND c.area_id=a.salesreg_id
ORDER BY a.productgroup_name) tmpa ORDER BY tmpa.productgroup_name";
    $haigeresult = $adb->pquery($haigesql,array($haigequoteid));
    $haigerows = $adb->num_rows($haigeresult);
    $haigearr = array();
    for($i=0;$i<$haigerows;$i++)
    {
        $productgroup_name = $adb->query_result($haigeresult,$i,'productgroup_name');
        $avgvalue_banshichu = $adb->query_result($haigeresult,$i,'avgvalue_banshichu');
        $avgvalue_area = $adb->query_result($haigeresult,$i,'avgvalue_area');
        $zhekou = $adb->query_result($haigeresult,$i,'zhekou');
        $amount = $adb->query_result($haigeresult,$i,'amount');
        $haigearr[] = array('productgroup_name'=>$productgroup_name,'avgvalue_banshichu'=>$avgvalue_banshichu,'avgvalue_area'=>$avgvalue_area
                            ,'zhekou'=>$zhekou,'amount'=>$amount);
        
    }
    $sql = "select ld_profile.profilename as profilename,ld_users.profileid as profileid from ld_users
        LEFT JOIN ld_profile on ld_profile.profileid = ld_users.profileid
         where id = ?;";
    $result = $adb->pquery($sql,array($current_user->id));
    $haigeuserprofieid = $adb->query_result($result,0,'profileid');
    $haigeuserprofilename = $adb->query_result($result,0,'profilename');
    $haigeareavisible_id = array(1,47,49,53,56);//总经理、价格委员会、大区经理、产品组、TSE
    $haigeareavisible_name = array('总经理','价格委员会','大区经理','产品组','TSE');
    $haigetable = '<table style="width:90%; margin:40px; line-height:35px;text-align: center;" cellspacing="0" cellpadding="0" border="1"><tbody>';
    if(in_array($haigeuserprofieid,$haigeareavisible_id)&&in_array($haigeuserprofilename,$haigeareavisible_name)){
        $width = 'width:20%;';
        $haigetable .= '<tr><td style="padding-left:1mm;">产品组</td>
                            <td style="'.$width.'padding-left:1mm">上一年办事处平均折扣</td>
                            <td style="'.$width.'padding-left:1mm">上一年区域平均折扣</td>
                            <td style="'.$width.'padding-left:1mm">申请折扣</td>
                            <td style="'.$width.'padding-left:1mm">金额</td></tr>';
    }
    else{
        $width = 'width:25%;';
        $haigetable .= '<tr><td style="padding-left:1mm">产品组</td>';
        //销售不显示 上一年办事处平均折扣 (51：销售人员；52销售助理)
        if($haigeuserprofieid!=51){
            $haigetable .='<td style="padding-left:1mm">上一年办事处平均折扣</td>';
        }
        $haigetable .='<td style="'.$width.'padding-left:1mm">申请折扣</td>
                            <td style="'.$width.'padding-left:1mm">金额</td></tr>';
    }
    foreach($haigearr as $index=>$showinfo)
    {
        $haigetable .= '<tr>';
        $haigetable .= '<td style="padding-left:1mm">'.$showinfo['productgroup_name'].'</td>';
        if($haigeuserprofieid!=51){
            $haigetable .= '<td style="padding-left:1mm">'.$showinfo['avgvalue_banshichu'].'</td>';
        }
        if(in_array($haigeuserprofieid,$haigeareavisible_id)&&in_array($haigeuserprofilename,$haigeareavisible_name)){
            $haigetable .= '<td style="padding-left:1mm">'.$showinfo['avgvalue_area'].'</td>';
        }
        
        $haigetable .= '<td style="padding-left:1mm">'.$showinfo['zhekou'].'</td>';
        //金额显示千分位number_format($showinfo['amount'] , 3, '.', ' ')
        $haigetable .= '<td style="padding-left:1mm">'.$showinfo['amount'].'</td>';
        $haigetable .= '</tr>';
    }
    $haigetable .= '</tbody></table>';
    $smarty->assign('HAIGEQUYUZHEKOUTABLE',$haigetable);
}
DetailViewReturnWithProductDetail($currentModule,$focus,$ProductDetailsHtml,$smarty);
?>