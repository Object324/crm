<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('include/ListView/ListViewSession.php');

global $mod_strings;
global $app_strings;
global $app_list_strings;
global  $currentModule, $singlepane_view;

$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;
require_once('modules/Commission/Commission.php');
$other = new Commission();
$smarty = new lingdangCRM_Smarty;
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"Commission");
    $focus->id = $_REQUEST['record'];	
	 /**
	  * cashbillno 修改为 commission_no
	  * @author Tujt 2014-04-11
	  */

    $smarty->assign('LASTVALINFO',getDetailListValName($_REQUEST['record'],'Commission',1));
}

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
 
if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");
$smarty->assign("BLOCKS", getBlocks("Commission","detail_view",'',$focus->column_fields));

$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("ID", $_REQUEST['record']);
$smarty->assign("SINGLE_MOD",'Commission');
$category = getParentTab();
$smarty->assign("CATEGORY",$category);


$tabid = getTabid("LessionPlan");
$validationData = $fieldobj->getDBValidationData($focus->tab_name,$tabid);

$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid)); //打印工具

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
/**
 * 佣金单审批开始
 * by andy 
 * data:20140415
 * end
 */ 
//require_once('modules/Approve/Approve.php');
//$approve=new Approve();
//$approve = Approve::getInstance();
//$issubmit=0;
//$isapprove=0;
//$isedit=0;
//$isdelete=0;
//$startapprove=$approve->startBlocksApprove();
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"CashDeposit");
    $focus->id = $_REQUEST['record'];
    $focus->name=$focus->column_fields[$focus->list_link_field];

}

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
/* 详情页按钮 end */

//include('user_privileges/user_language_'.$current_user->id.'.php');
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
//审批流程end
//审批流程按钮传值begin
//$smarty->assign('ISSUBMIT',$issubmit);
//$smarty->assign('ISAPPROVE',$isapprove);
//$smarty->assign('APPROVE',$approvelog);
$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
//$smarty->assign('ISEDIT',$isedit);
//$smarty->assign('ISDELETE',$isdelete);
/*审批结束*/
//$check_button = Button_Check($module);
//$smarty->assign("CHECK", $check_button);
$smarty->assign("MODULE",$currentModule);
//$smarty->assign("EDIT_PERMISSION",isPermitted($currentModule,'EditView',$_REQUEST['record']));

if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
}
//更多信息
$smarty->assign("IS_REL_LIST",isPresentRelatedLists($currentModule));
$smarty->assign("USE_ASTERISK", get_use_asterisk($current_user->id));
$smarty->assign("EVENT_PERMISSION",'true');
$smarty->assign("SinglePane_View", $singlepane_view);
// Record Change Notification
$focus->markAsViewed($current_user->id);
// END


$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
$entitynames=getEntitynameByModulename('SalesOrder');
$subject = $entitynames['fieldname'];
$sqlpayment="select ld_salesorder.salesorderid,ld_salesorder.$subject,ld_salesorder.`total`,ld_salesorder.signed_data,temp.cashbilldate,temp.paymentmethod,
            ld_commission2payment.remark,ld_commission2payment.rate,ld_commission2payment.amount
            from ld_commission2payment 
            inner join ld_commission on ld_commission2payment.commission_id = ld_commission.commission_id 
            inner join ld_salesorder on ld_salesorder.salesorderid = ld_commission2payment.salesorderid
            left join (
            select cashbilldate,paymentmethod,ld_cashbill2paymentplan.salesorderid from ld_cashbill 
            inner join ld_cashbill2paymentplan on ld_cashbill.cashbillid = ld_cashbill2paymentplan.CashBillID
            inner join ld_commission2payment on ld_commission2payment.salesorderid = ld_cashbill2paymentplan.salesorderid
            inner join ld_commission on ld_commission2payment.commission_id = ld_commission.commission_id
            where ld_commission.commission_id = ".$focus->id." group by cashbilldate order by  cashbilldate desc
            ) as temp on temp.salesorderid = ld_commission2payment.salesorderid
            where ld_commission.commission_id = ".$focus->id."";                           
$result=$adb->pquery($sqlpayment,array());

for($i=0;$i<$adb->num_rows($result);$i++)
{
               
    $j=$i+1;
    $trPayment.="<tr id='row".$j."'>";
   
    
    $trPayment .='<td> <a  referencemodule="SalesOrder" referencerecord="'.$adb->query_result($result,$i,'salesorderid').'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$adb->query_result($result,$i,"$subject").'</a>
                        <input type="hidden" value="'.$adb->query_result($result,$i,"salesorderid").'" name="salesorder'.$j.'" id="salesorder'.$j.'"/> </td>';//源单
    $trPayment .='<td> '.$adb->query_result($result,$i,"total").' </td>';//合同金额
    $trPayment .='<td> '.$adb->query_result($result,$i,"signed_data").' </td>';//合同金额
    $trPayment .='<td> '.$adb->query_result($result,$i,"cashbilldate").' </td>';//最近收款日期
    $trPayment .='<td> '.$adb->query_result($result,$i,"paymentmethod").'</td>';//收款方式
    $trPayment .='<td> '.$adb->query_result($result,$i,"remark").'</td>';//备注
    $trPayment .='<td> '.$adb->query_result($result,$i,"rate").'%</td>';    //佣金比例
    $trPayment .='<td>'.$adb->query_result($result,$i,"amount").'</td>';//佣金
    $trPayment.="</tr>";
    $lastvalinfo[] = '<a  referencemodule="SalesOrder" referencerecord="'.$adb->query_result($result,$i,'salesorderid').'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$adb->query_result($result,$i,"$subject").'</a>';
}
array_unique($lastvalinfo);
$smarty->assign('LASTVALINFO',implode(',',$lastvalinfo));
$smarty->assign("PAYMENTLIST",$trPayment);
if($adb->num_rows($result) == 0)
{
    $sql = "select total,nopaymentplan from ld_cashbill where cashbillid = $focus->id";
    $result = $adb->pquery($sql);
    $total = $adb->query_result($result,0,'total');
    $totalnopaymentamount = $adb->query_result($result,0,'nopaymentplan');
}    
$smarty->assign("TOTALPAYMENTAMOUNT",number_format($focus->column_fields['hdnGrandTotal'],2));//小计
$smarty->assign("TOTALHAVEEPAYMENTAMOUNT",number_format($focus->column_fields['hdnSubTotall'],2));//总计
$smarty->assign("TOTALNOPAYMENTAMOUNT",number_format($focus->column_fields['noamount'],2));//调整
$smarty->assign('TABLECOSPLAN',7);
$thHtml='';
$thHtml.='<td>'.getTranstab('SalesOrder').'</td>';//源单
$thHtml.='<td>'.getFixedLabel('SALESORDERCONTRACTAMOUNT').'</td>';//合同金额
$thHtml.='<td>'.getFixedLabel('DATEOFCONTRACT').'</td>';//签约日期
$thHtml.='<td>'.getFixedLabel('LATESTDATEOFRECEIPT').'</td>'; //最近收款日期
$thHtml.='<td>'.getFixedLabel('SPAYMENT').'</td>';//收款方式
$thHtml.='<td>'.getFixedLabel('REMARK').'</td>';//备注
$thHtml.='<td>'.getFixedLabel('COMMISSION').getFixedLabel('PROPORTTION').'</td>';//佣金比例
$thHtml.='<td>'.getFixedLabel('COMMISSION').'</td>';//佣金
$smarty->assign('THHTML',$thHtml);
$smarty->display("DetailView/DetailRelated.tpl");
?>