<?php
/**
 * 更新操作
 * edit:can
 * date:20131104
 * reason:常用报表和自定义报表分开需求(V3.1)
 * */
//zkt 20231010 XUQIU1001341 SQL注入
//$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
//$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//editor:gyq_135 reason:修改报表文件结构  2019/8/15 18:12
if($_REQUEST['action']=='index_report'){
    include globalStatic::$root_directory.'modules/OftenUseReport/index_report.php';
    exit;
}
include('modules/OftenUseReport/OftenUseReport.php');
//editor:gyq_135 reason:微信打卡同步至月度考勤表  2019/8/9 16:46 ID1000568
require_once(globalStatic::$root_directory.'modules/OftenUseReport/report_function.php');
//editor:gyq_168 reason:当前仅调用了cls_StaticCommonFun中的getOptionModule   2020/1/20 15:20
require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');
crm_load_class_file('cls_encryptToken','Register');
crm_load_class_file('cls_decryptToken','Register');
global $adb,$current_language,$theme,$currentModule;
if($_REQUEST['UseReportName']!="")
{
    $sql="select usereportid from ld_usereport  where name=?  ";
    $result=$adb->pquery($sql,array($_REQUEST['UseReportName']));
    if($adb->num_rows($result)>0)
    {
        $_REQUEST['UseReport']=$adb->query_result($result,0,'usereportid');
        
    }
}

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
/*
andrew
20140521
打印时languagetype为空
*/
global $current_user;
include('user_privileges/user_language_'.$current_user->id.'.php');

if(isset($_REQUEST['submode'])&&$_REQUEST['submode']=='SaveColumnSet')
{
   UpdateColumnSet();
}
else if(isset($_REQUEST['submode'])&&$_REQUEST['submode']=='editColumnName')
{
   UpdateColumnLabel();
}
$smarty=new lingdangCRM_Smarty();
//edit:can 2020-12-31 043664: （https://61mis.com/kfbcrm [^]）设置普通成员常用报表没有打印和导出Excel权限没有生效，常用报表仍可以打印和导出Excel
$smarty->assign("ExportExcelPermit",isPermitted($currentModule,"Export"));
$smarty->assign("PrintPermit",isPermitted($currentModule,"Print"));

setGLobalURLSmarty($smarty);//设置js,css等访问路径
$smarty->assign("REPORTMOD",$mod_strings);
$smarty->assign("JSURL","");
$mod=$mod_strings;
$sql='select * from ld_version';
$result=$adb->pquery($sql,array());
$trade=$adb->query_result($result,0,'trade');
//SalesOrderImplementation:德卡报表：合同执行情况明细表
//CourseEnquiryReport:培训行业报表

if($trade=='training'){
    $parentwhere = "";
    $where = " and name not in ('SalesOrderImplementation') ";
}
else if($trade=='德卡'){
    $parentwhere = " and name not in ('CourseEnquiryReport')";
    $where = "";
}
else
{
    $parentwhere = " and name not in ('CourseEnquiryReport')";
    $where = " and name not in ('SalesOrderImplementation') ";
}
if(!vtlib_isModuleActive('ServiceContracts')&&!vtlib_isModuleActive('SalesOrder')){
    $where .= " and name not in ('SalesOrderTrack','Contractnumber','Contractamount') ";
}
if($trade!='jierun'){
    $parentwhere .= " and name not in ('JIERUNREPORTS') ";
}
if($trade!='lueyang'){
    $where .= " and name not in ('Reportingpaymentschedulestatistics') ";
}
if($trade!='xycp'){
    $parentwhere .= " and name not in ('XuanYuanLawn')";
}
if($trade!='zhongyuan'){
    $parentwhere .= " and name not in ('ZHONGYUANREPORTS')";
}
if($trade!='futai'){
    $where .= " and name not in ('hoursqueryreport')";
}
if($trade!='ruiai'){
    $where .= " and name not in ('librarytrackreport')";
}
if($trade!='yuanzhou'){
    $where .= " and name not in ('yuanzhoureport')";
}

if(!vtlib_isModuleActive('Potentials')){
    $where .= " and name not in ('Salesforecastandanalysistable') ";
}
if(!vtlib_isModuleActive('CashBill')){
    $where .= " and name not in ('THESINGNINGAMOUNTOFBILLBOARD','CashBillSum_Paymentplan','CashBillSum_SalesOrder','Performancestatisticscollection') ";
}
if(!vtlib_isModuleActive('PurchaseOrder')){
    $where .= " and name not in ('PurchaseOrderTrack') ";
}
if(!vtlib_isModuleActive('Project')){
    $where .= " and name not in ('Thestatisticalreportofprojectperformance') ";
}
if(!vtlib_isModuleActive('SendCashBill')){
    $where .= " and name not in ('SendCashBillSum_PurchaseOrder','SendCashBillSum_SendPayment') ";
}
if(!vtlib_isModuleActive('OutboundOrder')){
    $where .= " and name not in ('CashBillSum_Outboundorder') ";
}
 $sql='select usereportid,name from ld_usereport where parent_id=0 '.$parentwhere.' order by sequence';//获取父节点报表
$parentresult=$adb->pquery($sql,array());
$reportHeader=array();
#获取父节点下子节点报表

$PurchaseOrdertype=vtlib_isModuleActive('PurchaseOrder');

$SalesOrdertype=vtlib_isModuleActive('SalesOrder');
$HelpDesktype=vtlib_isModuleActive('HelpDesk');
$ProjectTasktype=vtlib_isModuleActive('ProjectTask');
$CashBilltype=vtlib_isModuleActive('CashBill');
global $current_user;
$relatednames=array();

//edit:duan date:2024/12/11 reason:报表增加分页导出功能
$get_progress = $_REQUEST['get_progress'];
$startExportRow = $_REQUEST['startExportRow'];
$endExportRow = $_REQUEST['endExportRow'];

if(!is_admin($current_user))
{
    //角色权限增加常用报表权限 
    $SQL='select * from ld_profile2standardpermissions where profileid=? and tabid=?  ';
    $profile_result=$adb->pquery($SQL,array($current_user->profileid,getTabid($currentModule)));
   $relatednames=$adb->query_result($profile_result,0,'relatednames');

   $relatednames=explode(",",$relatednames);
}

for($i=0;$i<$adb->num_rows($parentresult);$i++)
{

    $sqlchild='select usereportid,name,reporttype from ld_usereport where parent_id=? and presence=0 '.$where.' order by sequence';
    $parentid=$adb->query_result($parentresult,$i,'usereportid');
    $parant_name = $adb->query_result($parentresult,$i,'name');
    $parentlabel=getFixedLabel($parant_name);
    if($parant_name=='InventoryReport'){
        //editor:20181229 0035903: 库存报表，当库存模块一个都不启用时，报表应该不显示
        //出库单、入库单、盘点单、库间调拨、销售退货单、采购退货单、库存初始化
        $stock_modules = array('OutboundOrder','Stock','WareHouseTransfer','Checks','Prdtnums','SalesBack','PurchaseBack');
        $atleast_onemodule_active = 0;
        foreach ($stock_modules as $key=>$value){
            if(vtlib_isModuleActive($value)){
                $atleast_onemodule_active = 1;
            }
        }
        if($atleast_onemodule_active===0){
            continue;
        }
    }
    $childresult=$adb->pquery($sqlchild,array($parentid));
    for($j=0;$j<$adb->num_rows($childresult);$j++)
    {
        $childname = $adb->query_result($childresult,$j,'name');
        $child_reporttype = $adb->query_result($childresult,$j,'reporttype');
        $childlabel=getFixedLabel($childname);
		/**
		 * @reason 0012334 常用报表>>服务绩效统计表：希望【客户服务单】、【项目任务】模块都没有开启的情况下，该报表不显示
		 * @author Tujt 2014-11-10
		 */
		if($childname == 'Serviceperformanceappraisal'){//服务绩效统计表
			if(1 != $HelpDesktype && 1 != $ProjectTasktype){
				continue;
			}
		}
        if($childname == 'The billboard of Receivables'){//回款金额龙虎榜
			if(1 != $CashBilltype){
				continue;
			}
		}
		if($childname == 'TimeSheet personal monthly summary'){//判断工时模块是否开启
			if(vtlib_isModuleActive('TimeSheet') == ''){
				continue;
			}
		}
		//chj:应收账款汇总表：如果数据接口没有连接金蝶旗舰版则不显示当前报表
		if($childname == 'AccountsReceivableSummary' && getDatainterface('soft_version') != 5){
			continue;
		}
		if('CashBillSum_Paymentplan' == $childname && !vtlib_isModuleActive('PaymentPlan')){
			continue;
		}
		if('SendCashBillSum_SendPayment' == $childname && !vtlib_isModuleActive('SendPayment')){
			continue;
		}
        $childusereportid=$adb->query_result($childresult,$j,'usereportid');
        if($childname=='DRAWTRACKREPORT')
        {
            crm_load_class_file('RecordEncrypt','include');
            $objuser=new RecordEncrypt("User",$current_user->id);
           
            $smarty->assign("GUIJITOKEN", $objuser->encrypt());
            $smarty->assign("GUIJIREPORTID",$childusereportid);
            $smarty->assign("GUIJIURL",$_SERVER['HTTP_HOST'].$_SERVER['PHP_SELF']);
        }
        else if($childname=='TRACKREREPORTROUTE')
        {
            $smarty->assign("GUIJIROUTEID",$childusereportid);
        }
        if(is_admin($current_user)||in_array($childname,$relatednames))
       {
           //editor:gyq_135 reason:微信打卡同步至月度考勤表  2019/8/6 15:10 ID1000568
            $baobiaoID[]=array('id'=>$childusereportid,'name'=>$childname,'type'=>$child_reporttype) ;//Liver 2016-11-24 获取所有可用报表的id
            $reportHeader[$parentlabel][]=array(
                'label'=>$childlabel ,'id'=>$childusereportid,'name'=>$childname,'type'=>$child_reporttype);
       }
        
    }
}
//页面第一次进入获取默认查询的报表，禁止第一次进入的就是月度考情表
foreach ($baobiaoID as $key=>$value){
    if($value['type'] != 51){
        $usereportid=$value['id'];
        break;
    }
}

$smarty->assign("USEREPORTS",$reportHeader);

if(isset($_REQUEST['UseReport']))
{
    $usereportid=$_REQUEST['UseReport'];
    if(is_numeric($usereportid)&&$usereportid>0){
        
    }
    else
    {
        exit('参数错误');
    }
}

$sql="select name from ld_usereport where usereportid=?";
$result=$adb->pquery($sql,array($usereportid));
$nums_result = $adb->num_rows($result);
if($nums_result > 0){
    $reportnames=$adb->query_result($result,0,0);
}


$MergeSmowner=getCurSmOwnerSearchScope($currentModule);

//人员范围
if($reportnames != 'TimeSheet personal monthly summary'){
   unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户 
}
unset($MergeSmowner["OtherInfo"]['SmOwer_Search_MeToShare']);
unset($MergeSmowner["OtherInfo"]['SmOwner_Search_Create']);
unset($MergeSmowner["OtherInfo"]['SmOwer_Search_ShareMe']); //去掉共享给我的
if($reportnames=='USERTRACKREPORT' || $reportnames == 'TimeSheet personal monthly summary')
{
    unset($MergeSmowner["OtherInfo"]['SmOwer_Search_MeToShare']);
    unset($MergeSmowner["OtherInfo"]['smowner_search_senior']);
    unset($MergeSmowner["OtherInfo"]['SmOwer_Search_ShareMe']);
    
}
if($reportnames=='USERTRACKREPORT')
{
    unset($MergeSmowner["OtherInfo"]['SmOwner_Search_All']);
}
if($reportnames == 'TimeSheet personal monthly summary'){
    unset($MergeSmowner["OtherInfo"]['SmOwner_Search_Me']);
}
$scopeobj = new ScopOfAuthority($adb,'OftenUseReport');
//灵当CRM详细需求-PC端-常用报表查看范围增加按部门选项
if($scopeobj->getUserModuleScoperType() > 0 || $current_user->is_admin == 'on'){
	$fieldlabel_group = getFixedLabel('SETBYDEPARTMENT');
	$MergeSmowner["OtherInfo"]['SmOwner_Search_Group'][$fieldlabel_group] = '';
}
$smarty->assign('Merge_SmOwner',$MergeSmowner);
//echo $reportnames;echo '<br><br>';
$smarty->assign("USEREPORTSNAME",$reportnames);
$smarty->assign("reportlabel",getFixedLabel($reportnames));
Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign('TABID',getTabid('OftenUseReport'));
//echo $usereportid;
#获取当前查询的报表类型
$sql='select reporttype,tabids,parent_id,basicfilter,advfilter,setcolumns,name ,pagewidthpercent from ld_usereport where usereportid=?';
$result=$adb->pquery($sql,array($usereportid));
//echo "<pre>";
//var_dump($result);
$reporttype=$adb->query_result($result,0,0);
$reportabid=$adb->query_result($result,0,1);
$reportname=$adb->query_result($result,0,'name');
$parentid=$adb->query_result($result,0,'parent_id');
$basicfilter=$adb->query_result($result,0,'basicfilter');
$advfilter=$adb->query_result($result,0,'advfilter');
$setcolumns=$adb->query_result($result,0,'setcolumns');
$pagewidthpercent=$adb->query_result($result,0,'pagewidthpercent');
$smarty->assign('PARENTID',$parentid);
$smarty->assign('BASICFILTER',$basicfilter);
if($reportnames!=='Serviceperformanceappraisal'&&$reportnames!='CashBillSum_SalesOrder'&&$reportnames!='SalesOrderTrack'&&$reportnames!='CashBillSum_Paymentplan'){
    $smarty->assign('ADVFILTER',$advfilter);
}
$smarty->assign('SETCOLUMNS',$setcolumns);
$smarty->assign('PAGEWIDTHPERCENT',$pagewidthpercent);
$reportModule=getTabname($reportabid);
if($_REQUEST['types']=='selectchange')
{
   $selectid = $_REQUEST['selectid'];
   $sql="SELECT DISTINCT(ld_products.productname)   
        from ld_inventoryproductrel 
        INNER JOIN ld_products on ld_inventoryproductrel.productid=ld_products.productid 
        where productcategory='$selectid'";
   $selectvalue=$adb->pquery($sql);
   $rowCounts = $adb->num_rows($selectvalue);
   for ($c = 0; $c < $rowCounts; $c++)
    {
                $productname[$c] = $adb->query_result($selectvalue, $c, 'productname');
    }
                //$productname=implode(",",$productname); 
    echo '###SUCCESS###'. json_encode($productname);
    exit();
                
}
//editor:gyq_86 reason:库存报表 2018/11/26 17:45
if($reportnames=='InventoryAccount' || $reportnames=='InventoryLedger'||$reportnames=='InventoryQuery'){
    crm_load_class_file('ReportModel','modules/OftenUseReport');
    $OftenUseReport=new ReportModel();
    //editor:gyq_135 reason:report_parent_type赋值  2019/8/9 14:38 ID1000568
    $OftenUseReport->report_parent_type = 'kucun';
}else{
    $OftenUseReport=new OftenUseReport();
}
#列头查询设置
$sql='select * from ld_usereportcolumns where usereportid=?  order by sequence';
$result=$adb->pquery($sql,array($usereportid));
$reportFindHeader="";

$showcolLists=array();
$AllReportHeaders=array();

for($i=0;$i<$adb->num_rows($result);$i++)
{
    //columns:表名：字段名称：fieldname:模块名称_fieldlabel:typeofdate

    $columns=$adb->query_result($result,$i,'columns');
	$realcolumns=$adb->query_result($result,$i,'realcolumns');
    $col_tabname=$adb->query_result($result,$i,'tabname');
	$is_advanced=$adb->query_result($result,$i,'is_advanced');


	if(!empty($col_tabname)&&(isPermitted($col_tabname,'index')!='yes'||!vtlib_isModuleActive($col_tabname) ))
    {
        //35772: （1.6登录）普通用户登录：普通用户没有模块权限时，销售业绩考核表中仍显示该模块的数据。预期结果：销售业绩考核表中应不显示该模块的数据
        continue;
    }
    if($languageType=='zh'){
        $realcolumns=$adb->query_result($result,$i,'realcolumns');
    }elseif($languageType=='en'){
        $realcolumns=$adb->query_result($result,$i,'realencolumns');
    }
    $fieldlabels=explode(':',$realcolumns);

    if($fieldlabels[0]=='ld_account'&&!vtlib_isModuleActive("Accounts"))
    {
        continue;
    }
    if($fieldlabels[0]=='ld_contactdetails'&&!vtlib_isModuleActive("Contacts"))
    {
        continue;
    }
    if($fieldlabels[0]=='ld_potentials'&&!vtlib_isModuleActive("Potentials"))
    {
        continue;
    }
    if($fieldlabels[0]=='ld_activies'&&!vtlib_isModuleActive("Calendar"))
    {
        continue;
    }
    if($fieldlabels[0]=='ld_contactrecords'&&!vtlib_isModuleActive("ContactRecords"))
    {
        continue;
    }
    if($fieldlabels[0]=='ld_troubletickets'&&!vtlib_isModuleActive("HelpDesk"))
    {
        continue;
    }
    if($fieldlabels[0]=='ld_cashbill'&&!vtlib_isModuleActive("CashBill"))
    {
        continue;
    }
    if($fieldlabels[0]=='ld_expense'&&!vtlib_isModuleActive("Expense"))
    {
        continue;
    }
    if($reportnames == 'Contractnumber'){
        if( $fieldlabels[0]=='ld_salesorder'&&!vtlib_isModuleActive("SalesOrder")&&!vtlib_isModuleActive("ServiceContracts"))
        {
            continue;
        }
    }else{
        if($fieldlabels[0]=='ld_salesorder'&&!vtlib_isModuleActive("SalesOrder"))
        {
            continue;
        }
    }

    if($fieldlabels[0]=='ld_servicecontracts'&&!vtlib_isModuleActive("ServiceContracts"))
    {
        continue;
    }
    if($fieldlabels[0]=='ld_invoice'&&!vtlib_isModuleActive("Invoice"))
    {
        continue;
    }
    if($fieldlabels[0]=='ld_outboundorder'&&!vtlib_isModuleActive("OutboundOrder"))
    {
        continue;
    }


    $columshow=$adb->query_result($result,$i,'columnshow');

    $AllReportHeaders[]=$columns;

    $typeofdata=$fieldlabels[4];

    if($columshow!=1)
    {
        continue;
    }
    $fieldmodules=explode('_',$fieldlabels[3]);
    $fieldModule=$fieldmodules[0];
    $showcolkey=$fieldModule.'_'.$fieldlabels[1];

    //获取$typeofdata_decimal
    $typeofdata_decimal = 2;
    $uitype = 0;
    $fieldtype = '';
    $isdetailfield = '';
    $tmp_columns = explode(':',$columns);
    $column_module_name = '';
    if(sizeof($tmp_columns)>=4){
        $tmp_module_columns = explode('_',$tmp_columns[3]);
        $column_module_name = $tmp_module_columns[0];
        $column_focus = CRMEntity::getInstance($column_module_name);
        if($column_focus){
            $tmp_columnname = $tmp_columns[1];
            $tmpfieldinfo = '';
            if(is_array($column_focus->tab_name) && in_array($tmp_columns[0],$column_focus->tab_name)){
                $tmpfieldinfo = $column_focus->fieldobj->getFieldInfoobjBykey('columnname',$tmp_columnname);
                $isdetailfield = 'no';
            }
            else if($tmp_columns[0] == $column_focus->Detail_table || $tmp_columns[0] == $column_focus->Detail_table_scf ){
                $tmpfieldinfo = $column_focus->detailfieldobj->getFieldInfoobjBykey('columnname',$tmp_columnname);
                $isdetailfield = 'yes';
            }
            if(!empty($tmpfieldinfo))
            {

                $uitype = $tmpfieldinfo->getUIType();
                $fieldtype = $tmpfieldinfo->getFieldType();
                $tmptypeofdata = $tmpfieldinfo->getTypeOfData();
                $tmptypeofdatas = explode(',', $tmptypeofdata);
                if(sizeof($tmptypeofdatas)>1)
                {
                    $typeofdata_decimal=$tmptypeofdatas[1];
                    if(!is_numeric($typeofdata_decimal)){
                        $typeofdata_decimal = 2;
                    }
                }
                //单据头和单据分录“金额货币”类型字段根据typeofdata取值，其他的仍默认为2
                if(!$tmpfieldinfo->isAmountorCurrencyField()){
                    $typeofdata_decimal = 2;
                }
            }
        }
    }

    $columnname=$fieldlabels[1];
    if($columns!=$realcolumns)
    {
        $fieldlabel=substr($fieldlabels[3],strpos($fieldlabels[3],'_')+1);
        $fieldlabels=explode('_',$fieldlabels[3]);

    }
    else
    {

        $sql='select ld_tranlabel.fieldlabel,typeofdata from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
          where columnname=\''.$fieldlabels[1].'\' and ld_tranlabel.languagetype=? and ld_tranlabel.tabid =(select tabid from ld_tab where name=\''.$fieldModule.'\')';

        $fieldResult=$adb->pquery($sql,array($languageType));
        if($adb->num_rows($fieldResult)>0)
        {
            $fieldlabel=$adb->query_result($fieldResult,0,0);
            $fieldlabel=($fieldlabel);
            $fieldlabel=getTranstab($fieldModule).'_'.$fieldlabel;

            $typeofdata=$adb->query_result($fieldResult,0,'typeofdata');

            $typeofdata=explode('~',$typeofdata);
            $typeofdata=$typeofdata[0];
            
        }
        else
        {
            $fieldlabel=$fieldmodules[1];
            switch($fieldlabel){
                case 'ordernum':
                    $fieldlabel = getFixedLabel('ORDERNUM');
                    break;
                case 'groupbycount':
                    $fieldlabel = getFixedLabel('CONTRACTNUMBERHONE');
                    break;
            }
            /* if(array_key_exists($fieldlabel,$mod))//获取在页面设置中没有标签的报表字段label
             {
                 $fieldlabel=$mod[$fieldlabel];
             }*/
        }
    }
    if($reportname == 'SalesSumSequence'){
        if('invoicetotal' == $columnname){
            $fieldlabel = getTransTab('Invoice') . getFixedLabel('AMOUNT');
        }
        if('outboundordertotal' == $columnname){
            $fieldlabel = getTransTab('OutboundOrder') . getFixedLabel('AMOUNT');
        }
    }
    if($reportname=='SalesSumSequence')//销售业绩考核表
    {
		$ordertype = $_REQUEST['ordertype'];
        $sorder = $_REQUEST['sorder'];
		if($ordertype==''||$columnname!=trim($sorder))
            $reportFindHeader.='<th>
                    <a title="'.$fieldlabel.'"   href="javascript:;" onclick="setReportOrderListView(\''.$_REQUEST['UseReport'].'\',\''.$columnname.'\',\''.$ordertype.'\');">
                    <span title="'.$fieldlabel.'">'.$fieldlabel.'</span>
                    </a></th>';
        else if($ordertype=='asc')
            $reportFindHeader.='<th>
                    <a title="'.$fieldlabel.'"   href="javascript:;" onclick="setReportOrderListView(\''.$_REQUEST['UseReport'].'\',\''.$columnname.'\',\'desc\');">
                    '.$fieldlabel.'  <img border="0" src="themes/images/arrow_down.gif">
                    </a></th>';
        else
            $reportFindHeader.='<th>
                <a title="'.$fieldlabel.'"   href="javascript:;" onclick="setReportOrderListView(\''.$_REQUEST['UseReport'].'\',\''.$columnname.'\',\'asc\');">
                '.$fieldlabel.'  <img border="0" src="themes/images/arrow_up.gif">
                </a></th>';

    }elseif ($reportname=='InventoryAccount'||$reportname=='InventoryLedger'){
        //editor:gyq_86 reason:产品批次 2018/11/16 14:57
        $reportFindHeader.='<th rowspan="2">&nbsp;'.$fieldlabel.'</th>';
    }else
        $reportFindHeader.='<th>&nbsp;'.$fieldlabel.'</th>';
    $exportheader[] = $fieldlabel;
    $datatype[] = $typeofdata ;

    //获取$typeofdata_decimal,拼接到$showcolLists
    if(($typeofdata == 'N'||$typeofdata == 'NN')&& ($fieldModule == 'OftenUseReport')){
        $typeofdata_decimal = 2;
    }
    $showcolLists[ $showcolkey.':'.$typeofdata.':'.$typeofdata_decimal.':'.$uitype.':'.$fieldtype.':'.$isdetailfield]=array($columshow=>$fieldlabels[0]);
	$selected = '';
	if($is_advanced == 1){
		$selected = "selected = ''";
	}
	if(strpos($realcolumns,'ld_products:costprice:costprice:Products') !== false ||  strpos($realcolumns,'ld_outboundorder:out_no:out_no:OutboundOrder') !== false){ 
	}else{
	    //editor:gyq_122临时 reason:高级查找字段隐藏日期字段  2019/6/14 17:46
        if($OftenUseReport->report_parent_type=='kucun'&&$columnname=='bill_date'){
            continue;
        }
		$fieldnames .= "<option value=\'$realcolumns\' $selected>$fieldlabel</option>"; 
	}
    //$reportFindHeader.='<td class="lvtCol"><a onclick="getListViewEntries_js(&quot;Vendors&quot;,&quot;parenttab=Purchase&amp;foldername=Default&amp;order_by=vendor_no&amp;start=&amp;sorder=ASC&quot;);" href="javascript:;">'.$fieldlabel.'</a></td>';
}


//editor:gyq_20190130	0036328: （1.6登录）库存台账导出Excel后，Excel表中“收入、发出、结存”列头没有导出（需要补丁）
//editor:gyq_20190411	库存流水账导出Excel后，Excel表中“收入、发出”列头没有导出
if($reportname=='InventoryLedger'||$reportname=='InventoryAccount'){
    $exportheader[] = getFixedLabel('INCOME').'-'.getFixedLabel('LISTPRICE');
    $exportheader[] = getFixedLabel('INCOME').'-'.getFixedLabel('QUANTITY');
    $exportheader[] = getFixedLabel('INCOME').'-'.getFixedLabel('AMOUNT');
    $exportheader[] = getFixedLabel('SENDOUT').'-'.getFixedLabel('LISTPRICE');
    $exportheader[] = getFixedLabel('SENDOUT').'-'.getFixedLabel('QUANTITY');
    $exportheader[] = getFixedLabel('SENDOUT').'-'.getFixedLabel('AMOUNT');
    if($reportname=='InventoryLedger'){
        $exportheader[] = getFixedLabel('REPORTBALANCE').'-'.getFixedLabel('LISTPRICE');
        $exportheader[] = getFixedLabel('REPORTBALANCE').'-'.getFixedLabel('QUANTITY');
        $exportheader[] = getFixedLabel('REPORTBALANCE').'-'.getFixedLabel('AMOUNT');
    }
}

//echo '<pre>';
//print_r($showcolLists);
//echo '</pre>';

//print_r($reportFindHeader);
/**
 * 更新操作
 * edit:can
 * date:20131223
 * reason:06420: 常用报表后面缺少“查看数据”列，需求上有要求，希望加上，点击之后，应该能够打开对应单据的查看明细界面。
 * */

//var_dump($reportFindHeader);
// Liver add $reporttype==50,原因是签到明细表增加操作列
//Liver 去掉合同订单跟踪表、采购订单跟踪表 操作列，bug0027469
if(($reporttype==10 || $reporttype==50)&& $reportnames !='InventoryAccount'&& $reportnames !='InventoryLedger'&& $reportnames !='InventoryQuery' && $reportnames !='SalesOrderTrack' &&  $reportnames!='PurchaseOrderTrack')
{
    $showcolLists[ 'lbl_action'.':V']=array(1=>'操作');
    $reportFindHeader.='<th>&nbsp;'.getFixedLabel('OPERATING').'</th>';
}
if($reportname=='SalesSumSequence')
{
    //销售业绩
  //  echo 'wwwww';
  //  print_r($showcolLists);
   // foreach($showcolLists as $)
}
//editor:gyq_122 reason:删除__construct复杂参数，抽成新方法init_params 2019/6/13 17:31
//editor:gyq_20190726 reason:init_params放到操作按钮代码上面导致序时簿没有操作按钮！！！！！！！！
$OftenUseReport->init_params($reporttype,$reportname,$usereportid,$adb,$showcolLists,$AllReportHeaders,$reportabid,$advfilter);
if($get_progress == 'yes'){
    $OftenUseReport->setExportNum($get_progress,$startExportRow,$endExportRow);
}

//editor:gyq_122 reason:三个库存报表，增加“仓库”列，以及增加“高级查找”范围  2019/6/13 15:06
if($OftenUseReport->report_parent_type=='kucun'){
    $search_modue_name = 'Products';
    $customView = CustomView::getInstance($search_modue_name);
    $queryGenerator =  QueryGenerator::getInstance($search_modue_name, $current_user,$customView);
    $controller = new ListViewController($adb, $current_user, $queryGenerator);
    //editor:gyq_20191205 reason:0038754: （kfbcrm）库存台账，高级查询，缺少“产品编号”和“规格型号”查询（需要补丁）
    //$_REQUEST['kucun_report_advance_search_repeat_field'] = array('productname','product_no','productsheet','unit_price','qtyearly');
    $_REQUEST['kucun_report_advance_search_repeat_field'] = array('productname');
    $fieldnames_product = $controller->getAdvancedSearchOptionString();
    $shtml_p_blockname = "<optgroup label='".getFixedLabel('OFTENUSEREPORTWORD')."-".getFixedLabel('INVENTORY').getFixedLabel('INFORMATION')."' class='select' style='border:none'>";
    $fieldnames = $shtml_p_blockname.$fieldnames.$fieldnames_product;
}
$smarty->assign("FIELDNAMES", $fieldnames);
//Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/16 0016 上午 9:43
crm_load_class_file("cls_PickList", 'modules/PickList');
$objpinklist = new cls_PickList();

#基本查询
$sql="select * from ld_usereportbasic  where usereportid=? order by sequence";
$result=$adb->pquery($sql,array($usereportid));
//var_dump($result);
$basicfilterHtml="";
$month=date("m");
$datemonth=date("Y-m");
/*$sqls="SELECT DISTINCT(ld_products.productcategory)
                        from ld_inventoryproductrel 
                        INNER JOIN ld_products on ld_inventoryproductrel.productid=ld_products.productid;";
$selectvalue=$adb->pquery($sqls);
$rowCounts = $adb->num_rows($selectvalue);
for ($c = 0; $c < $rowCounts; $c++) 
{
    $productcategory[$c] = $adb->query_result($selectvalue, $c, 'productcategory');
}*/
/*

$sqls="SELECT DISTINCT(ld_products.productname)   
                        from ld_inventoryproductrel 
                        INNER JOIN ld_products on ld_inventoryproductrel.productid=ld_products.productid 
                        where ld_products.productcategory='$productcategory[0]'
                        ;";
$selectvalue=$adb->pquery($sqls);
$rowCountz = $adb->num_rows($selectvalue);

for ($c = 0; $c < $rowCountz; $c++)
 {
    $productname[$c] = $adb->query_result($selectvalue, $c, 'productname');
 }
 $sqls="SELECT DISTINCT(cf_1082) FROM ld_salesordercf where cf_1082 not in ('--无--','');";
 $selectvalue=$adb->pquery($sqls);
 $rowCountz = $adb->num_rows($selectvalue);
 
 for ($c = 0; $c <$rowCountz; $c++) 
 {
    $cf_1082[$c] = $adb->query_result($selectvalue, $c, 'cf_1082');
 }
 */
 
 //echo "<pre>";
 //var_dump($result);       
 //echo $adb->num_rows($result);
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $basicInfos=explode(":",$adb->query_result($result,$i,'columns'));
    $basicdefaultvalue=$adb->query_result($result,$i,'defaultvalue');
    $fieldmodules=explode('_',$basicInfos[3]);
    $fieldModule=$fieldmodules[0];

   // echo strtolower($basicInfos[count($basicInfos)-1]);
   //var_dump(strtolower($basicInfos[count($basicInfos)-1]));
    if(strtolower($basicInfos[count($basicInfos)-1])=="d")
    {
        //ld_salesorder:signed_data:signed_data:SalesOrder_signed_data:D
        $datefindcolumn=$basicInfos[0].'.'.$basicInfos[1];
        $smarty->assign("DATEFINDCOLUMN",$datefindcolumn);
        //bug 0012548
        //$basicfilterHtml.="<td><span class='changeday' style='padding-left:0px;'>". getFixedLabel('STATISTTIME').':</span>';
		if($reportnames == 'Salesranking'){
			$basicfilterHtml.="<td width='100%' colspan='2'>";
		}else{
			$basicfilterHtml.="<td width='600' colspan='2'>";
		}
        //改变样式
        $basicvalues[0]=$basicdefaultvalue;
        if(strpos($basicdefaultvalue,'~')>0)
        {
            $basicvalues=explode('~',$basicdefaultvalue);
           
        }
    
    //本日，昨日，本周，本月，时间获取
    $todayselect=  date('Y-m-d',time());
    $yesterdayselect=  date("Y-m-d",time()-24*60*60); 
    $week_begin =  date("Y-m-d",mktime(0, 0, 0,date("m"),date("d")-date("w")+1,date("Y")));
    $week_end =  date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w")+7,date("Y")));
    $lastweeks=DateOperation::getlastweekrange($todayselect);
    $lastweekbegin=$lastweeks[0];
    $lastweekend=$lastweeks[sizeof($lastweeks)-1];
 
    //上月
    $time=strtotime(date('Y-m-d'));
    $smarty->assign("NOW_DATE",date('Y-m-d'));
    $last_month_begin=date('Y-m-01',strtotime(date('Y',$time).'-'.(date('m',$time)-1).'-01'));
    $last_month_end=date('Y-m-d',strtotime("$last_month_begin +1 month -1 day"));
    //本月
    $month_begin=date("Y-m-d",mktime(0, 0, 0,date("m"),1,date("Y")));    
    $month_end = date("Y-m-d",mktime(23,59,59,date("m"),date("t"),date("Y")));
    //本年
    $begin_this_year=date('Y-01-01');
    $end_this_year=date('Y-12-31');
    //var_dump($reportnames);
    //echo $reportnames."<br>";
    foreach($basicvalues as $keyvalue=>$valuecontent)
    {
            switch($valuecontent)
            {
              
                case "thisstartmonth":
                    $startdatemonth=$datemonth.'-01';
                    $enddatemonth=$datemonth.'-'.date('t',strtotime($datemonth));
                    /**
                    *@author:andy
                    *@data:
                    *@reason:报表查询时间段样式更改，双时间录入框改为单时间段录入框
                    *@version:|
                    */
                    if($reportnames=='Serviceperformanceappraisal'||$reportnames=='SIGNINSTATISTICS'){
                        $startdatemonth=$todayselect;
                        $enddatemonth=$todayselect;
                        $selected_class_1 = 'onselected_A';
                    }
                    $thequerytime=$startdatemonth.' '.'-'.' '.$enddatemonth;
                    //editor:gyq_135 reason:月度考勤表跳转到签到表，时间div默认选中  2019/8/14 15:56 ID1000568
                    $selected_class_2 = '';
                    if($_REQUEST['redirect_from']=='checkin_monthly'){
                        $month_start =  strtotime( $_REQUEST['startmonth'].' 00:00:00');
                        $month_end = strtotime( $_REQUEST['endmonth'].' 23:59:59');
                        $thequerytime = date('Y-m-d',$month_start) . ' ' . '-' . ' ' . date('Y-m-d',$month_end);
                        $selected_class_1 = '';
                        $selected_class_2 = 'onselected_A';
                    }
                    /**
                    *@author:andy
                    *@data:
                    *@reason:bug0012272: 常用报表：所有的报表，点击打开时，时间段都是默认选中的是【今日】，但是后面的日历时间显示的是本月，如图
                    *说明	常用报表：所有的报表，点击打开时，时间段都是默认选中的是【今日】，但是后面的日历时间显示的是本月
                    *常用报表，除【服务绩效统计表】默认为 当日，其他常用报表都默认为本月 刘锁
                    * @version:v5.8
                    */
                    if($reportnames=='Serviceperformanceappraisal'||$reportnames=='SIGNINSTATISTICS'){
                        $basicfilterHtml .="<a class='".$selected_class_1." changeday' id='today' name='OftenUseReport_search' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'today','$todayselect','$todayselect')\">".getFixedLabel('checktoday')."</a>
                        <a id='yesterday' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'yesterday','$yesterdayselect','$yesterdayselect')\">".getFixedLabel('checkyesterday')."</a>
                         <a id='lastweek' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'lastweek','$lastweekbegin','$lastweekend')\">".getFixedLabel('lastweek')."</a>
                       
                        <a id='week' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'week','$week_begin','$week_end')\">".getFixedLabel('thisweek')."</a>
						<a id='lastmonth' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'lastmonth','$last_month_begin','$last_month_end')\">".getFixedLabel('lastmonth')."</a>
                        <a id='month' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'month','$month_begin','$month_end')\">".getFixedLabel('thismonth')."</a>
                        <a id='year' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'year','$begin_this_year','$end_this_year')\">".getFixedLabel('THISYEAR')."</a> 
                        <a id='all' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'all','2000-01-01','2050-12-31')\">".getFixedLabel('ALL')."</a>";
                    }elseif($reportnames=='TimeSheet personal monthly summary'){//TimeSheet个人月汇总表：不需要显示日期查询
                        
                    }else{
                        $basicfilterHtml .="<a class='changeday' id='today' name='OftenUseReport_search' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'today','$todayselect','$todayselect')\">".getFixedLabel('checktoday')."</a>
                        <a id='yesterday' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'yesterday','$yesterdayselect','$yesterdayselect')\">".getFixedLabel('checkyesterday')."</a>
                         <a id='lastweek' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'lastweek','$lastweekbegin','$lastweekend')\">".getFixedLabel('lastweek')."</a>
                        <a id='week' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'week','$week_begin','$week_end')\">".getFixedLabel('thisweek')."</a>
						<a id='lastmonth' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'lastmonth','$last_month_begin','$last_month_end')\">".getFixedLabel('lastmonth')."</a>
                        <a id='month' name='OftenUseReport_search' class='onselected_A changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'month','$month_begin','$month_end')\">".getFixedLabel('thismonth')."</a>
                        <a id='year' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'year','$begin_this_year','$end_this_year')\">".getFixedLabel('THISYEAR')."</a>
                        <a id='all' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'all','2000-01-01','2050-12-31')\">".getFixedLabel('ALL')."</a>";
                    }
                       
                        ///$startdatemonth=$todayselect;
                    //}
                    
                    if($reportnames == 'HighAndNewTechnologyEnterpriseSchedule' || $reportnames == 'ProjectCompletionStatisticsReport')
                    {
                        $riqi = '申报月份';
                    }else{
                        $riqi = getFixedLabel('DATESELECTION');
                    }
                    $basicfilterHtml .="<span class='".$selected_class_2." changeday colorLink' id='daterangepicker_search'>" .$riqi."&nbsp;</span>";
                    $data_system = "width:180px;padding-left:3px;margin-top: -2px;margin-left: 5px;";
                    if($reportnames=='InventoryAccount' || $reportnames=='InventoryLedger'){
                        $basicfilterHtml = '<span class="changeday">'.getFixedLabel('DATE').':</span>';
                        $data_system = "width:180px;padding-left:3px;margin-right:10px;";
                    }
                    $basicfilterHtml .= "<input class='borderALL btn-radius-system' type='text' readonly=true value='$thequerytime' id='startmonth' name='startmonth' findcolumn= '".$adb->query_result($result,$i,'columns')."' style='".$data_system."'/>";

                    //$basicfilterHtml .="&nbsp;<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif' id='img1' onclick='showCalendar(\"startmonth\",\"%Y-%m-%d\",\"true\",\"12\",this)'/>";
					//销售排行：排行维度
					if($reportnames == 'Salesranking'){
						$basicfilterHtml .='&nbsp;&nbsp;&nbsp;&nbsp;'.getFixedLabel('Rankingdimension') . "：&nbsp;";
						$basicfilterHtml .= "<select name='salesranking_value' id='salesranking_value' onchange='changeSalesRank(this)' class='commonSelectPop'>";
						if(vtlib_isModuleActive('SalesOrder') || vtlib_isModuleActive('ServiceContracts')){
							$due_num_selected = '';
							if(!empty($_REQUEST['salesranking_value']) && $_REQUEST['salesranking_value'] == 'due_num'){
								$due_num_selected = 'selected';
							}
							$due_amount_selected = '';
							if(!empty($_REQUEST['salesranking_value']) && $_REQUEST['salesranking_value'] == 'due_amount'){
								$due_amount_selected = 'selected';
							}
							$basicfilterHtml .= "<option value='due_num' tag='".getSalesRankingType('due_num')."' $due_num_selected>".getFixedLabel('CONTRACTNUMBERHONE')."</option>";
							$basicfilterHtml .= "<option value='due_amount' tag='".getSalesRankingType('due_amount')."' $due_amount_selected>".getFixedLabel('CONTRACTAMOUNTPANEL')."</option>";
							$salesrank_array[] = 'due_num';$salesrank_array[] = 'due_amount';
						}
						if(vtlib_isModuleActive('CashBill')){
							$sendpament_amount_selected = '';
							if(!empty($_REQUEST['salesranking_value']) && $_REQUEST['salesranking_value'] == 'sendpament_amount'){
								$sendpament_amount_selected = 'selected';
							}
							$basicfilterHtml .= "<option value='sendpament_amount' tag='".getSalesRankingType('sendpament_amount')."' $sendpament_amount_selected>".getFixedLabel('AMOUNTTO')."</option>";
							$salesrank_array[] = 'sendpament_amount';
						}
						if(vtlib_isModuleActive('Invoice')){
                            $selected = '';
                            if(!empty($_REQUEST['salesranking_value']) && $_REQUEST['salesranking_value'] == 'invoice_amount'){
                                $selected = 'selected';
                            }
							$basicfilterHtml .= "<option value='invoice_amount' tag='".getSalesRankingType('invoice_amount')."' $selected>".getFixedLabel('INVOICEAMOUNT')."</option>";
							$salesrank_array[] = 'invoice_amount';
						}
						if(vtlib_isModuleActive('OutboundOrder')){
                            $selected = '';
                            if(!empty($_REQUEST['salesranking_value']) && $_REQUEST['salesranking_value'] == 'out_amount'){
                                $selected = 'selected';
                            }
							$basicfilterHtml .= "<option value='out_amount' tag='".getSalesRankingType('out_amount')."' $selected>".getFixedLabel('AMOUNTLIBRARY')."</option>";
							$salesrank_array[] = 'out_amount';
						}
						$basicfilterHtml .= "</select>";
						
					}
                    $basicfilterHtml.='</td>';
                    break;
                case "thisendmonth":         
                    $enddatemonth=$datemonth.'-'.date('t',strtotime($datemonth));
                    if($reportnames=='Serviceperformanceappraisal'||$reportnames=='SIGNINSTATISTICS'){
                        $enddatemonth=$todayselect;
                    }    
                    //$basicfilterHtml .="&nbsp;&nbsp; 至 &nbsp;&nbsp;<input class='borderALL' type='text' size=10  readonly=true value=$enddatemonth id='endmonth' name='endmonth' findcolumn= '".$adb->query_result($result,$i,'columns')."'/>";
                    //$basicfilterHtml .="&nbsp;<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif' id='img1' onclick='showCalendar(\"endmonth\",\"%Y-%m-%d\",\"true\",\"12\",this)'/>";
                    $basicfilterHtml.='</td>';
                    break;
            }
        }
    }
    else
    {
        if($reportnames=='CommencementSchedule'||$reportnames=='OverallCommencementSchedule'||$reportnames=='PartnerCommencementSchedule'||$reportnames=='LecturerCommencementSchedule'
        ||$reportnames=='Studentsparticipatinginthetrainingschedule'||$reportnames=='Customersparticipatinginthetrainingschedule'
        ||$reportnames=='Contactbusinesstable'||$reportnames=='KPCCommencementDetails'||$reportnames=='CourseparticipantsKPClist')
        {
           
            if($basicInfos[2]!='cf_1084'&&$basicInfos[2]!='cf_1082'&&$basicInfos[0]!='ld_contactdetails'){
                $smarty->assign("OTHERFINDCOLUMN",$basicInfos[0].'.'.$basicInfos[1]);
            }

            $fieldsql='select ld_tranlabel.fieldlabel from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
             where languagetype=? and trantable=? and  fieldname=? and ld_tranlabel.tabid =(select tabid from ld_tab where name=?)';
            $fieldResult=$adb->pquery($fieldsql,array($languageType,'ld_field', $basicInfos[2],$fieldModule));
            if($adb->num_rows($fieldResult)>0)
            {
                $fieldlabel=$adb->query_result($fieldResult,0,0);
            }
            else
            {
                $fieldlabel=$fieldModule[1];
            }
            $fieldlabel=$fieldlabel;
           if($fieldlabel=='合作伙伴'&&($reportnames=='Studentsparticipatinginthetrainingschedule'||$reportnames=='Contactbusinesstable')){$fieldlabel='所在公司';}
           if($fieldlabel=='合作伙伴'&&$fieldModule=='salesorder'&&$reportnames=='Customersparticipatinginthetrainingschedule'){
           $fieldlabel='客户';
            }
           
            if(($fieldlabel=='产品类别'||$fieldlabel=='课程类别')&&$trade=='training'){
                                                
                $basicfilterHtml.='<td>业务类别：<select class="borderALL btn-radius-system" style="width:100px;" name="basicotherfinds" id="basicotherfinds" onchange="DoOnchange()" findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                foreach($productcategory as $arr){
                $basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
                }
                $basicfilterHtml.='</select></td>'; 
            }elseif(($fieldlabel=='课程名称'||$fieldlabel=='Product Name')&&$trade=='training'){
                $basicfilterHtml.='<td>'.$fieldlabel.'：<select style="width:100px;" class="borderALL btn-radius-system" name="basicotherfindz" id="basicotherfindz" findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                foreach($productname as $arr){
                $basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
                }
                $basicfilterHtml.='</select></td>'; 
          }elseif($fieldlabel=='开课地点'||$fieldlabel=='cf_1084'){
                $basicfilterHtml.='<td>&nbsp;&nbsp;'.$fieldlabel.'：<input class="borderALL btn-radius-system" type="text"  style="width:120px;" value="'.$basicdefaultvalue.'" name="basicotherfind2" id="basicotherfind2" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
          }elseif($fieldlabel=='讲师'||$fieldlabel=='cf_1082'){
                $basicfilterHtml.='<td>&nbsp;&nbsp;'.$fieldlabel.'：<select class="borderALL btn-radius-system" name="basicotherfind3" id="basicotherfind3" findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                foreach($cf_1082 as $arr){
                $basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
                }
                $basicfilterHtml.='</select></td>'; 
          }elseif($fieldlabel=='姓名'){
                $basicfilterHtml.='<td> &nbsp;&nbsp;';
                if($reportnames=='Contactbusinesstable'){$basicfilterHtml.='联系人';}else{$basicfilterHtml.='学员';};
                $basicfilterHtml.='：<input class="borderALL btn-radius-system" type="text" style="width:120px;" value="'.$basicdefaultvalue.'" name="basicotherfind4" id="basicotherfind4" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
          }elseif($fieldlabel=='客户'&&$reportnames=='Customersparticipatinginthetrainingschedule'){
                $basicfilterHtml.='<td>&nbsp;&nbsp;'.$fieldlabel.'：<input class="borderALL btn-radius-system" style="width:100px;" type="text" value="'.$basicdefaultvalue.'" name="basicotherfind5" id="basicotherfind5" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
          }else{
                $basicfilterHtml.='<td>&nbsp;&nbsp;'.$fieldlabel.'：<input class="borderALL btn-radius-system" style="width:100px;" type="text" value="'.$basicdefaultvalue.'" name="basicotherfind" id="basicotherfind" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
            }
            
        }else{
            $smarty->assign("OTHERFINDCOLUMN",$basicInfos[0].'.'.$basicInfos[1]);
            $fieldsql='select ld_tranlabel.fieldlabel,ld_field.columnname from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
             where languagetype=? and trantable=? and  fieldname=? and ld_tranlabel.tabid =(select tabid from ld_tab where name=?)';
            $fieldResult=$adb->pquery($fieldsql,array($languageType,'ld_field', $basicInfos[2],$fieldModule));

            if($adb->num_rows($fieldResult)>0)
            {
                $fieldlabel=$adb->query_result($fieldResult,0,'fieldlabel');
                $searchwhere=$adb->query_result($fieldResult,0,'columnname');
            }
            else
            {
                $fieldlabel=$fieldModule[1];
                $searchwhere=$fieldModule[1];
            }

             $fieldlabel=($fieldlabel);
              //echo $searchwhere."<br>";
             
            if((($searchwhere!='approvestatus'&&$searchwhere!='contract_no'&&$reportnames=='SalesOrderTrack')
            ||($searchwhere!='approvestatus'&&$reportnames!='SalesOrderTrack'))
            &&($reportnames!='hoursqueryreport'&&$reportnames!='InventoryAccount'&&$reportnames!='InventoryLedger' &&$reportnames!='InventoryQuery'&&$reportnames!='Eachprojectcontractincomestatisticsreport'
            &&$reportnames!='Orderexpenditurestatisticsreport'&&$reportnames!='Allpaymentsstatisticsreport'
            &&$reportnames!='Serviceperformanceappraisal'&&$reportnames!='Thestatisticalreportofprojectperformance'
            &&$reportnames!='Xuanyuanlawnbusinessmanagementreport'&&$reportnames!='HighAndNewTechnologyEnterpriseSchedule'
            &&$reportnames!='ProjectCompletionStatisticsReport'&&$reportnames!='Reportingpaymentschedulestatistics'&&
            ($reportnames!='ProjectCompletionStatisticsReport'&&$searchwhere!='cashbilldate'))){
                $basicfilterHtml2.='<span style="padding-left: 5px;padding-right: 10px;line-height: 27px;">'.$fieldlabel.'</span><input class="ld-input-inner gwidth60" type="text" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind" id="basicotherfind" findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
            }
            //editor:gyq_86 reason:产品批次 2018/11/16 15:21
            //单据审批状态，有未提交、审批中、已审批、已驳回4个红字状态，必居其一
            if($reportnames=='InventoryAccount' || $reportnames=='InventoryLedger'||$reportnames=='InventoryQuery'){
                if(empty($basicfilterHtml2)) $basicfilterHtml2='';
                if($searchwhere=='wareid'){
					$new_ware = $OftenUseReport->getOftenUserReport_WareHouse();
					if(!empty($new_ware)){
						$basicfilterHtml2.='<td> <span class="changeday">'.getFixedLabel('WAREHOUSE').':</span><select class="borderALL btn-radius-system width100" name="basicotherfind3" id="basicotherfind3">';
						foreach($new_ware['all'] as $key=>$value){
							$basicfilterHtml2.='<option value ="'.$key.'">'.$value.'</option>';
						}
						$basicfilterHtml2.='</select></td>';
					}
                    //gyqTE
                }elseif($searchwhere=='batchmanagement') {
                    $basicfilterHtml2 .= '<td><span class="changeday">' . getFixedLabel('BATCH') . ':</span><input class="borderALL btn-radius-system" type="text" 
            style="width:120px;" value="' . $basicdefaultvalue . '"  name="basicotherfind4" id="basicotherfind4"/></td>';
                }elseif($searchwhere=='productname') {
                    if($reportnames=='InventoryLedger'){
                        $basicdefaultvalue = '';	//$##$DefaultProductName$##$
                    }
                    $basicfilterHtml2 .= '<td><span class="changeday">' . $fieldlabel . ':</span><input class="borderALL btn-radius-system" type="text" 
            style="width:120px;" value="' . $basicdefaultvalue . '" id="basicotherfind5"  name="basicotherfind5" ></td>';
                }
            }

            if($reportnames=='hoursqueryreport'&&$searchwhere=='contract_no'){
                $basicfilterHtml.='<td><span>'.$fieldlabel.'</span><input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind2" id="basicotherfind2" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
            }
            if($reportnames=='hoursqueryreport'&&$searchwhere=='productname'){
                $basicfilterHtml.='<td><span>'.$fieldlabel.'</span><input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind3" id="basicotherfind3" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
            }
            if($reportnames=='hoursqueryreport'&&$searchwhere=='accountname'){
                $basicfilterHtml2.='<span>'.$fieldlabel.'</span><input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind4" id="basicotherfind4" findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
            }
            if($reportnames == 'HighAndNewTechnologyEnterpriseSchedule' || $reportnames == 'ProjectCompletionStatisticsReport'){
                if($searchwhere=='cf_1479'){
                    $SQL = "SELECT cf_1479 FROM ld_cf_1479 group by cf_1479;";
                    $fieldResult=$adb->pquery($SQL,array());
                    $rowCountz = $adb->num_rows($fieldResult);
                    for ($c = 0; $c < $rowCountz; $c++) {
                    $cf_1479list[$c] = $adb->query_result($fieldResult, $c, 'cf_1479');
                    }
                    $basicfilterHtml.='<td>'.$fieldlabel.':&nbsp;&nbsp;<select class="borderALL btn-radius-system" name="basicotherfind2" id="basicotherfind2"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                    $basicfilterHtml.='<option value ="">'.getFixedLabel('ALL').'</option>';
                    foreach($cf_1479list as $arr){
                    $basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
                    }
                    $basicfilterHtml.='</select></td>';
                }
                if($searchwhere=='cf_1478'){
                    $SQL = "SELECT cf_1478 FROM ld_cf_1478 group by cf_1478;";
                    $fieldResult=$adb->pquery($SQL,array());
                    $rowCountz = $adb->num_rows($fieldResult);
                    for ($c = 0; $c < $rowCountz; $c++) {
                    $cf_1478list[$c] = $adb->query_result($fieldResult, $c, 'cf_1478');
                    }
                    $basicfilterHtml.='<td>'.$fieldlabel.':&nbsp;&nbsp;<select class="borderALL btn-radius-system" name="basicotherfind3" id="basicotherfind3"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                    $basicfilterHtml.='<option value ="">'.getFixedLabel('ALL').'</option>';
                    foreach($cf_1478list as $arr){
                    $basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
                    }
                    $basicfilterHtml.='</select></td>';
                }

            }
            if($reportnames=='Reportingpaymentschedulestatistics'){
                if($searchwhere=='cf_1751'){
                $basicfilterHtml.='<td><span>重报项目:&nbsp;</span><input class="borderALL btn-radius-system" type="text"  style="width:120px;" value="'.$basicdefaultvalue.'"  name="basicotherfind2" id="basicotherfind2" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
                 }
                if($searchwhere=='projectstatus'){
                $Project_field_obj=Field::getInstance('Project',$adb);
                $arrpaymentLabelProducts=$Project_field_obj->getFieldLables();
                //Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/16 0016 上午 9:44
                $arrprojectstatus = $objpinklist->getPickListValues('projectstatus',"",array(),"");
                    $projectstatuslist = array_values($arrprojectstatus);
                /*$SQL="SELECT projectstatus FROM ld_projectstatus";
                $fieldResult=$adb->pquery($SQL,array());
                $rowCountz = $adb->num_rows($fieldResult);
                for ($c = 0; $c < $rowCountz; $c++) {
                $projectstatuslist[$c] = $adb->query_result($fieldResult, $c, 'projectstatus');
                }*/

                $basicfilterHtml.='<td>'.$arrpaymentLabelProducts['projectstatus'].':&nbsp;&nbsp;<select class="borderALL btn-radius-system"  name="basicotherfind3" id="basicotherfind3"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                $basicfilterHtml.='<option value ="">'.getFixedLabel('ALL').'</option>';
                foreach($projectstatuslist as $arr){
                $basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
                }
                $basicfilterHtml.='</select></td>';
                 }
                if($searchwhere=='cf_1784'){
                $basicfilterHtml2.='<td>未收款金额:&nbsp;&nbsp;<select class="borderALL btn-radius-system"  name="basicotherfind4" id="basicotherfind4"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                $basicfilterHtml2.='<option value ="">'.getFixedLabel('ALL').'</option>';
                $basicfilterHtml2.='<option value ="2">大于0</option>';
                $basicfilterHtml2.='</select></td>'; }

                if($searchwhere=='accountname'){
                $basicfilterHtml.='<td width="300"><span>客户:&nbsp;</span><input class="borderALL btn-radius-system" type="text"  style="width:120px;" value="'.$basicdefaultvalue.'"  name="basicotherfind5" id="basicotherfind5" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';

                 }
                if($searchwhere=='subject'){
                $Project_field_obj=Field::getInstance('SalesOrder',$adb);
                $arrpaymentLabelProducts=$Project_field_obj->getFieldLables();

                $basicfilterHtml2.='<td><span>'.$arrpaymentLabelProducts['subject'].':&nbsp;</span><input class="borderALL btn-radius-system" type="text"  style="width:120px;" value="'.$basicdefaultvalue.'"  name="basicotherfind6" id="basicotherfind6" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';

                 }
            }
            if($reportnames=='PurchaseOrderTrack')
            {
                //35052: 报表-常用报表，采购订单跟踪表这个位置能加“只显示应付款大于0"这个选项
                        $basicfilterHtml .='<td width="280"><input type="checkbox" id="basicotherfindsapp" name="basicotherfindsapp" style="margin-left:5px;margin-right:5px;margin-top: -2px;" value="" '.$checked.' />'.getFixedLabel('onlyshowpaymorethanzero').'</td>';

            }
            if($reportnames=='Eachprojectcontractincomestatisticsreport'||$reportnames=='Orderexpenditurestatisticsreport'||$reportnames=='Allpaymentsstatisticsreport'){

                if($searchwhere=='potentialname'){
                    $basicfilterHtml.='<td><span>'.$fieldlabel.'</span><input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind5" id="basicotherfind5" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
                }
                if($searchwhere=='potential_no'){
                    $basicfilterHtml.='<td><span>'.$fieldlabel.'</span><input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind2" id="basicotherfind2" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
                }
                if($searchwhere=='accountname'){

                    $basicfilterHtml.='<td width="300"><span>'.$fieldlabel.'</span><input class="borderALL btn-radius-system" type="text"  style="width:120px;" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind3" id="basicotherfind3" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
                }
                if($searchwhere=='subject'){

                    $basicfilterHtml2.='<span>'.getFixedLabel('ORDER').'</span><input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind4" id="basicotherfind4" findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                }

                if($searchwhere=='signed_data'){
                $basicfilterHtml2.='<td>'.getFixedLabel('SERVICECONTRACTSTYPE').':&nbsp;&nbsp;<select class="borderALL btn-radius-system"  name="basicotherfind6" id="basicotherfind6"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                $basicfilterHtml2.='<option value ="">'.getFixedLabel('ALL').'</option>';
                $basicfilterHtml2.='<option value ="2">'.getFixedLabel('Collectioncompleted').'</option>';
                $basicfilterHtml2.='<option value ="3">'.getFixedLabel('Collectionnotcompleted').'</option>';
                $basicfilterHtml2.='</select></td>'; }

                if($searchwhere=='salesorder_no'){

                $basicfilterHtml2.='<td>'.getFixedLabel('SERVICECONTRACTSTYPE').':&nbsp;&nbsp;<select class="borderALL btn-radius-system" name="basicotherfind6" id="basicotherfind6"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                $basicfilterHtml2.='<option value ="">'.getFixedLabel('ALL').'</option>';
                $basicfilterHtml2.='<option value ="2">'.getFixedLabel('Paymentcompleted').'</option>';
                $basicfilterHtml2.='<option value ="3">'.getFixedLabel('Paymentnotcompleted').'</option>';
                $basicfilterHtml2.='</select></td>'; }
             }
            if($searchwhere=='cf_1428'&&$reportnames=='Xuanyuanlawnbusinessmanagementreport'){
                $SQL = "SELECT cf_1428 FROM ld_cf_1428 group by cf_1428;";
                $fieldResult=$adb->pquery($SQL,array());
                $rowCountz = $adb->num_rows($fieldResult);
                for ($c = 0; $c < $rowCountz; $c++) {
                $cf_1428list[$c] = $adb->query_result($fieldResult, $c, 'cf_1428');
                }

                $account_field_obj=Field::getInstance('Accounts',$adb);
                $arrpaymentLabelProducts=$account_field_obj->getFieldLables();
                $basicfilterHtml.='<td>'.$arrpaymentLabelProducts['cf_1428'].':&nbsp;&nbsp;<select class="borderALL btn-radius-system" name="basicotherfind3" id="basicotherfind3"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                $basicfilterHtml.='<option value ="">'.getFixedLabel('ALL').'</option>';
                foreach($cf_1428list as $arr){
                $basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
                }
                $basicfilterHtml.='</select></td>';
            }
            if($searchwhere=='productname'&&$reportnames=='Xuanyuanlawnbusinessmanagementreport'){
                $SQL = "SELECT ld_inventoryproductrel.productid,productname 
                        FROM ld_inventoryproductrel left join ld_products ON 
                        ld_inventoryproductrel.productid=ld_products.productid WHERE productname<>''
                        group by ld_inventoryproductrel.productid;";
                $fieldResult=$adb->pquery($SQL,array());
                $rowCountz = $adb->num_rows($fieldResult);
                for ($c = 0; $c < $rowCountz; $c++) {
                $productid = $adb->query_result($fieldResult, $c, 'productid');
                $servicetype[$productid] = $adb->query_result($fieldResult, $c, 'productname');
                }

                $account_field_obj=Field::getInstance('Products',$adb);
                $arrpaymentLabelProducts=$account_field_obj->getFieldLables();

                $basicfilterHtml.='<td style="padding-right:10px;">'.$arrpaymentLabelProducts['productname'].':&nbsp;&nbsp;<select class="borderALL btn-radius-system"  name="basicotherfind4" id="basicotherfind4"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                $basicfilterHtml.='<option value ="">'.getFixedLabel('ALL').'</option>';
                foreach($servicetype as $arr){
                $basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
                }
                $basicfilterHtml.='</select></td>';
            }
            if($searchwhere=='approvestatus'){
				$checked = '';
				if(!empty($_REQUEST['basicotherfindsapp']) && $_REQUEST['basicotherfindsapp'] == 'true'){
					$checked = 'checked';
				}
              //修改checkbox宽度
			    $modules_arr = array('Expense','Commission');
				foreach($modules_arr as $mod){
					if(vtlib_isModuleActive($mod) == 'yes'){
						$modulelabel_array[] = getTranstab($mod);
					}
				}


				if(sizeOf($modulelabel_array) > 0){
					if($reportnames == 'SalesOrderTrack'){
						$basicfilterHtml .='<td width="280"><input type="checkbox" id="basicotherfindsapp" name="basicotherfindsapp" style="margin-left:5px;margin-right:5px;margin-top: -2px;" value="" '.$checked.' />'.getFixedLabel('onlyacontractwithmorethan').'</td>';
					}

                    else{
						$basicfilterHtml .='<td width="280"><input type="checkbox" id="basicotherfindsapp" name="basicotherfindsapp" style="margin-left:5px;margin-right:5px;margin-top: -2px;" value="" '.$checked.' />'.getFixedLabel('EXCOMMTOTAL').implode(getFixedLabel('AND'),$modulelabel_array).'</td>';
					}
				}

                else{
					$basicfilterHtml .= '<td width="280"><input type="hidden" id="basicotherfindsapp" name="basicotherfindsapp" value="" /></td>';
				}

            }

            if($searchwhere=='cashbilldate'&&$reportnames=='Serviceperformanceappraisal'){

                $basicfilterHtml.='<td width="235"><input name="basicotherfindsapp2" id="basicotherfindsapp2" style="margin-left:5px;margin-right:5px;margin-top: -2px;" checked findcolumn=" '.$adb->query_result($result,$i,'columns').'" type="checkbox" value="" />  '.getFixedLabel('Onlythroughdatastatisticsexaminationapproval').'&nbsp;&nbsp;</td>';
            }

           if($reportnames == 'Serviceperformanceappraisal' && $searchwhere == 'accountname'){
				$search_module = array('HelpDesk','ProjectTask');
				foreach($search_module as $module){
					if(vtlib_isModuleActive($module)){
						$module_label[] = getTranstab($module);
					}
				}
				 $basicfilterHtml.='<td width="280"><input name="basicotherfindsapp2" style="margin-bottom: 1px;margin-top: -2px;vertical-align: middle;" id="basicotherfindsapp2" type="checkbox" value="" />  '.getFixedLabel('EXCOMMTOTAL').implode(getFixedLabel('AND'),$module_label).'&nbsp;&nbsp;</td>';
		   }
            if($searchwhere=='servicetype'&&$reportnames=='Serviceperformanceappraisal'){
                //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 下午 2:22
                $result_pick = $objpinklist->getPickListValues('servicetype',"",array(),"");
                $servicetype = array_values($result_pick);
				/*$SQL = "SELECT servicetype FROM ld_servicetype;";
				$fieldResult=$adb->pquery($SQL,array());
				$rowCountz = $adb->num_rows($fieldResult);
				for ($c = 0; $c < $rowCountz; $c++) {
				$servicetype[$c] = $adb->query_result($fieldResult, $c, 'servicetype');
				}*/

				$account_field_obj=Field::getInstance('HelpDesk',$adb);
				$arrpaymentLabelProducts=$account_field_obj->getFieldLables();
				if(!empty($arrpaymentLabelProducts['servicetype'])){
					$basicfilterHtml.='<td>'.$arrpaymentLabelProducts['servicetype'].':&nbsp;&nbsp;<select class="borderALL btn-radius-system" style="width:100px;" name="basicotherfind3" id="basicotherfind3"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
					$basicfilterHtml.='<option value ="">'.getFixedLabel('ALL').'</option>';
					foreach($servicetype as $arr){
						$basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
					}
					$basicfilterHtml.='</select></td>';
				}
            }
            if($searchwhere=='projectstatus'&&$reportnames=='Thestatisticalreportofprojectperformance'){
                //Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/16 0016 上午 9:44
                $arrprojectstatus = $objpinklist->getPickListValues('projectstatus',"",array(),'');
                $servicetype = array_values($arrprojectstatus);

                /*$SQL = "SELECT projectstatus FROM ld_projectstatus;";
                $fieldResult=$adb->pquery($SQL,array());
                $rowCountz = $adb->num_rows($fieldResult);
                for ($c = 0; $c < $rowCountz; $c++) {
					$servicetype[$c] = $adb->query_result($fieldResult, $c, 'projectstatus');
                }*/

                $account_field_obj=Field::getInstance('Project',$adb);
                $arrpaymentLabelProducts=$account_field_obj->getFieldLables();
				if(!empty($arrpaymentLabelProducts['projectstatus'])){
					$basicfilterHtml.='<td>'.$arrpaymentLabelProducts['projectstatus'].':&nbsp;&nbsp;<select class="borderALL btn-radius-system"  name="basicotherfind3" id="basicotherfind3"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
					$basicfilterHtml.='<option value ="">'.getFixedLabel('ALL').'</option>';
					foreach($servicetype as $arr){
						$basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
					}
					$basicfilterHtml.='</select></td>';
				}
            }
            if($searchwhere=='accountname'&&$reportnames=='Thestatisticalreportofprojectperformance'){
                $basicfilterHtml2.=$fieldlabel.':&nbsp;&nbsp;<input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind" id="basicotherfind" findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
            }
            if($searchwhere=='progress'&&$reportnames=='Thestatisticalreportofprojectperformance'){
                //Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/16 0016 上午 9:44
                $arrprogress = $objpinklist->getPickListValues('progress',"",array(),"");
                $servicetype = array_values($arrprogress);

                /*$SQL = "SELECT progress FROM ld_progress;";
                $fieldResult=$adb->pquery($SQL,array());
                $rowCountz = $adb->num_rows($fieldResult);
                for ($c = 0; $c < $rowCountz; $c++) {
                $servicetype[$c] = $adb->query_result($fieldResult, $c, 'progress');
                }*/

                $account_field_obj=Field::getInstance('Project',$adb);
                $arrpaymentLabelProducts=$account_field_obj->getFieldLables();
				if(!empty($arrpaymentLabelProducts['progress'])){
					$basicfilterHtml.='<td style="padding-right:10px;">'.$arrpaymentLabelProducts['progress'].':&nbsp;&nbsp;<select class="borderALL btn-radius-system"  name="basicotherfind4" id="basicotherfind4"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
					$basicfilterHtml.='<option value ="">'.getFixedLabel('ALL').'</option>';
					foreach($servicetype as $arr){
						$basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
					}
					$basicfilterHtml.='</select></td>';
				}
            }
            if($searchwhere=='accountname'&&$reportnames=='Serviceperformanceappraisal'&&(vtlib_isModuleActive('HelpDesk')||vtlib_isModuleActive('ProjectTask'))){
				$Serviceperformanceappraisal_array[] = $searchwhere;

            }
            if($searchwhere=='contract_no'&&$reportnames=='SalesOrderTrack'&&(vtlib_isModuleActive('SalesOrder')||vtlib_isModuleActive('ServiceContracts'))){
                $basicfilterHtml.='<td>'.getFixedLabel('BillType').':&nbsp;&nbsp;<select class="borderALL btn-radius-system" style="font-size:12px;" onchange="changeCheckLabel()" name="basicotherfindsbill" id="basicotherfindsbill"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                if(vtlib_isModuleActive('SalesOrder')&&vtlib_isModuleActive('ServiceContracts')){
                    $basicfilterHtml.='<option value ="0" tag="'.getSalesRankingType('SalesOrderTrack').'">'.getFixedLabel('ALL').'</option>';
                }
                if(vtlib_isModuleActive('SalesOrder')){
                    $basicfilterHtml.='<option value ="1" tag="'.getFixedLabel('Onlythroughdatastatisticsexaminationapproval1') . getTransTab('SalesOrder').'">'.getTranstab('SalesOrder').'</option>';
                }
                if(vtlib_isModuleActive('ServiceContracts')){
                    $basicfilterHtml.='<option value ="2" tag="'.getFixedLabel('Onlythroughdatastatisticsexaminationapproval1') . getTransTab('ServiceContracts').'">'.getTranstab('ServiceContracts').'</option>';
                }
                $basicfilterHtml.='</select></td>';
            }

            //$basicfilterHtml.='<td>'.$fieldlabel.'：<input type="text"  width="120px" value="'.$basicdefaultvalue.'" name="basicotherfind" id="basicotherfind" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
        }
    }
}

//editor:gyq_86 reason:库存报表 2018/11/23 10:49
/*if($reportnames=='InventoryLedger'){
    $basicfilterHtml2.='<td><a class=""  title="'.getFixedLabel('REPORTFORWARD').'" href="javascript:;" 
                onclick="redirect_record(\'qianjin\')">'.getFixedLabel('REPORTFORWARD').'</a></td>';
    $basicfilterHtml2.='<td><a class=""  title="'.getFixedLabel('REPORTBACKWARDS').'" href="javascript:;" 
                onclick="redirect_record(\'houtui\')">'.getFixedLabel('REPORTBACKWARDS').'</a></td>';
}*/
$basicfilterHtml5 = '';
foreach($Serviceperformanceappraisal_array as $searchwhere){
	if($searchwhere=='servicetype'){
		
	}else if($searchwhere=='accountname'){
			$basicfilterHtml5.='<td width="300">'.getFixedLabel('BillType').':&nbsp;&nbsp;<select class="borderALL btn-radius-system" style="font-size:12px;" name="basicotherfindsbill" id="basicotherfindsbill"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
			if(vtlib_isModuleActive('HelpDesk')&&vtlib_isModuleActive('ProjectTask')){
				$basicfilterHtml5.='<option value ="0">'.getFixedLabel('ALL').'</option>';
			}
			if(vtlib_isModuleActive('HelpDesk')){
				$basicfilterHtml5.='<option value ="1">'.getTranstab('HelpDesk').'</option>';
			} 
			if(vtlib_isModuleActive('ProjectTask')){
				$basicfilterHtml5.='<option value ="2">'.getTranstab('ProjectTask').'</option>';
			} 
			$basicfilterHtml5.='</select></td>'; 
	}
}

#常用报表首次进入默认查询
if(!is_null($_REQUEST['begin_createdate']) && strlen($_REQUEST['begin_createdate'])>0 || (isset($_REQUEST['paging']) && $_REQUEST['paging'] == "true"))
{
    $begin_createdate= $_REQUEST['begin_createdate'];
    $end_createdate= $_REQUEST['end_createdate'];
    //$begin_createdate = "2013-08-01";
    if(strlen($begin_createdate)>0)
    {
        $where_sql .= " and createtime between '$begin_createdate' and '$end_createdate' ";
    }
}
#点击链接获取时间
else
{
    $date=date("Y-m-d");
    $fday = date("Y-m-01",strtotime($date));
    $lday = date("Y-m-d",strtotime("$fday +1 month -1 day"));
    $firstday = $fday;
    $lastday = $lday;
    $begin_createdate= $firstday;
    $end_createdate= $lastday;
    $where_sql .= " and createtime between '$begin_createdate' and '$end_createdate' "; 
}
//var_dump($begin_createdate);
$smarty->assign("begin_createdate", $begin_createdate);
$smarty->assign("end_createdate", $end_createdate);
if(!isset($_REQUEST['searchtype'])&&$reportnames!='CommencementSchedule'&&$reportnames!='OverallCommencementSchedule'
        &&$reportnames!='PartnerCommencementSchedule'&&$reportnames!='LecturerCommencementSchedule'
        &&$reportnames!='Studentsparticipatinginthetrainingschedule'&&$reportnames!='Customersparticipatinginthetrainingschedule'
        &&$reportnames!='Contactbusinesstable'&&$reportnames!='KPCCommencementDetails'&&$reportnames!='CourseparticipantsKPClist')
{
    $_REQUEST['searchtype']='BasicSearch';
    $_REQUEST['startmonth']=$startdatemonth.' 00:00:00';
    $_REQUEST['endmonth']=$enddatemonth.' 23:59:59';
    $_REQUEST['datefindcolumn']=$datefindcolumn;
    $smarty->assign('SEARCHTYPE','BasicSearch');
}elseif(!isset($_REQUEST['searchtype'])&&($reportnames=='CommencementSchedule'||$reportnames=='OverallCommencementSchedule'||$reportnames=='PartnerCommencementSchedule'||$reportnames=='LecturerCommencementSchedule'
        ||$reportnames=='Studentsparticipatinginthetrainingschedule'||$reportnames=='Customersparticipatinginthetrainingschedule'
        ||$reportnames=='Contactbusinesstable'||$reportnames=='KPCCommencementDetails'||$reportnames=='CourseparticipantsKPClist')){
    //echo $startdatemonth;
    $_REQUEST['searchtype']='BasicSearch';
    $_REQUEST['startmonth']=$startdatemonth.' 00:00:00';
    $_REQUEST['endmonth']='1200-03-01  23:59:59';
    $_REQUEST['datefindcolumn']=$datefindcolumn;
    $smarty->assign('SEARCHTYPE','BasicSearch');
}
else
{
    $smarty->assign('SEARCHTYPE',$_REQUEST['searchtype']);
    
}
$smarty->assign('BASICFILTERHTML5',$basicfilterHtml5);
$smarty->assign("BASICFILTERHTML",$basicfilterHtml);
//editor:gyq_86 reason:库存报表 2018/11/26 18:15 gyqTE
if(isset($OftenUseReport->report_parent_type) && $OftenUseReport->report_parent_type=='kucun'){
    $basicfilterHtml2.='<td><span class="changeday">'.getFixedLabel('approvestatus').':</span><select class="borderALL btn-radius-system width100" name="basicotherfind6" id="basicotherfind6">';
    //出库单或入库单更新库存流水记录触发点 0：审核  1：保存
    $sys_deploy = getSys_deploy('48');
    $sys_deploy_value = $sys_deploy['deploy_value'];
    if($sys_deploy_value == 1){
        $basicfilterHtml2 .= '<option value="all" selected>'.getFixedLabel('ALL').'</option>';
        $basicfilterHtml2 .= '<option value="已批准">已批准</option>';
    }else{
        $basicfilterHtml2 .= '<option value="all">'.getFixedLabel('ALL').'</option>';
        $basicfilterHtml2 .= '<option value="已批准" selected>已批准</option>';
    }
    $basicfilterHtml2.='</select></td>';
    //editor:gyq_140 reason:即时库存查询优化，增加条件:显示库存数量为0的记录  2019/8/28 15:57
    if($reportnames=='InventoryQuery')
        $basicfilterHtml2.='<td><input name="show_zero_quantity" type="checkbox" class="btn-radius-system marL6" style="float:left;"><span class="changeday">'.getFixedLabel('OFTENUSEREPORTTITLE1').'</span></td>';
}
$smarty->assign("BASICFILTERHTML2",$basicfilterHtml2);

$smarty->assign("APP",$app_strings);
#获取人员范围
//if($reportname!='SIGNINSTATISTICS')
//{
	$ScopOfAuthority = ScopOfAuthority::getInstance($adb,$currentModule);
    if ( is_admin($current_user)==false && ($ScopOfAuthority->getModuleShareInfo() == SHARE_PRIVATE or $ScopOfAuthority->getModuleShareInfo() == SHARE_PUBLIC_READONLY)) {
    			
       $users_combo = get_user_array(FALSE, "Active", $current_user->id, 'private');
    } else {
        $users_combo = get_user_array(FALSE, "Active", $current_user->id);
    }
   

foreach($users_combo as $userid=>$lastname)
{
  
    $arruser[$lastname]=$userid;
}
$sorder='';
$ordertype='';
if(isset($_REQUEST['sorder']))
{
    $sorder=$_REQUEST['sorder'];
    $ordertype=$_REQUEST['ordertype'];
}
$smarty->assign("ARRUSER",$arruser);

//print_r($showcolLists);
//print_r($reportFindHeader);
//销售预测分析表
if($reportnames=='Salesforecastandanalysistable'){
    unset($reportFindHeader);
	$fieldObj = Field::getInstance('Potentials',$adb);
	$moduleFields = $fieldObj->getModuleFields();
	$field_sales_stage = $moduleFields['sales_stage'];
	$field_lastsales_stage = $moduleFields['lastsales_stage'];
    $reportFindHeader='
    <th rowspan="2">'.getFixedLabel('AssignedTo2').'</th>
	<th rowspan="2">'.getFixedLabel('Sector').'</th>
    <th rowspan="2">'.getFixedLabel('AccountName').'</th>
    <th rowspan="2">'.getFixedLabel('AccountType').'</th>
    <th rowspan="2">'.getFixedLabel('Person_in_charge').'</th>
    <th rowspan="2">'.getFixedLabel('Potentials').'</th>
    <th rowspan="2">'.getFixedLabel('Numbers').'</th>
    <th rowspan="2">'.getFixedLabel('ProductCategory').'</th>';
	if(!empty($field_sales_stage)){
		$reportFindHeader .= '<th rowspan="2">'.getFixedLabel('sales_stage').'</th>';
	}
    if(!empty($field_lastsales_stage)){
		$reportFindHeader .= '<th rowspan="2">'. getFixedLabel('lastsales_stage').'</th>';
	}
    //0033665: 常用报表>销售预测分析表>实际（关联合同订单/)：当关闭服务合同后“实际（关联合同订单/)”应该不显示斜杠
    if(vtlib_isModuleActive('SalesOrder')&&vtlib_isModuleActive('ServiceContracts')){
        $actual_description = getFixedLabel('Actual_Description');
    }else{
        $actual_description = str_replace('/','',getFixedLabel('Actual_Description'));
    }
    $reportFindHeader .='<th colspan="4" style="text-align:center;">'.getFixedLabel('Expect_Description').'</th>
    <th colspan="4" style="text-align:center;">'.$actual_description.'</th>
    <th rowspan="2">'.getFixedLabel('SWOTAnalysis').'</th>
    </tr>
    <tr>
    <th class="borderT">'.getFixedLabel('Expect').'-'.getFixedLabel('ContractAmount2').'</th>
    <th class="borderT">'.getFixedLabel('Expect').'-'.getFixedLabel('SigningDate').'</th>
    <th class="borderT">'.getFixedLabel('Expect').'-'.getFixedLabel('CollectionAmount').'</th>
    <th class="borderT">'.getFixedLabel('Expect').'-'.getFixedLabel('CollectionDate').'</th>
    <th class="borderT">'.getFixedLabel('Actual').'-'.getFixedLabel('ContractAmount2').'</th>
    <th class="borderT">'.getFixedLabel('Actual').'-'.getFixedLabel('SigningDate').'</th>
    <th class="borderT">'.getFixedLabel('Actual').'-'.getFixedLabel('CollectionAmount').'</th>
    <th class="borderT">'.getFixedLabel('Actual').'-'.getFixedLabel('CollectionDate').'</th>
    ';
}
//库存流水账 editor:gyq_86 reason:产品批次 2018/11/14 10:36
if($reportnames=='InventoryAccount' ){
    $reportFindHeader .='<th colspan="3" style="text-align:center;">'.getFixedLabel('INCOME').'</th>
    <th colspan="3" style="text-align:center;">'.getFixedLabel('SENDOUT').'</th>
    </tr>
    <tr>
    <th class="borderT">'.getFixedLabel('LISTPRICE').'</th>
    <th class="borderT">'.getFixedLabel('QUANTITY').'</th>
    <th class="borderT">'.getFixedLabel('AMOUNT').'</th>
    <th class="borderT">'.getFixedLabel('LISTPRICE').'</th>
    <th class="borderT">'.getFixedLabel('QUANTITY').'</th>
    <th class="borderT">'.getFixedLabel('AMOUNT').'</th>
    ';
}elseif ($reportnames=='InventoryLedger'){
    $reportFindHeader .='<th colspan="3" style="text-align:center;">'.getFixedLabel('INCOME').'</th>
    <th colspan="3" style="text-align:center;">'.getFixedLabel('SENDOUT').'</th>
    <th colspan="3" style="text-align:center;">'.getFixedLabel('REPORTBALANCE').'</th>
    </tr>
    <tr>
    <th class="borderT">'.getFixedLabel('LISTPRICE').'</th>
    <th class="borderT">'.getFixedLabel('QUANTITY').'</th>
    <th class="borderT">'.getFixedLabel('AMOUNT').'</th>
    <th class="borderT">'.getFixedLabel('LISTPRICE').'</th>
    <th class="borderT">'.getFixedLabel('QUANTITY').'</th>
    <th class="borderT">'.getFixedLabel('AMOUNT').'</th>
     <th class="borderT">'.getFixedLabel('LISTPRICE').'</th>
    <th class="borderT">'.getFixedLabel('QUANTITY').'</th>
    <th class="borderT">'.getFixedLabel('AMOUNT').'</th>
    ';
}

/*
edit:chj
date:2015-5-12
reason:应收账款汇总表
*/
if($reportnames == 'AccountsReceivableSummary'){
	//获取区域信息
	$submes = InterfaceClass::AccountingReceivable(1);
	$smarty->assign('SUBMES',$submes);
	//获取业务人员
	$empinfo = InterfaceClass::AccountingReceivable(2);
	$smarty->assign('EMPINFO',$empinfo);
	//时间
	$smarty->assign('STARTDATE',date('Y-m'));
	$smarty->assign('ENDDATE',date('Y-m'));
	unset($reportFindHeader);
	$reportFindHeader='
	<tr>
		<th>'.getFixedLabel('ACCOUNTINGPROJECTNAME').'</th>
		<th>'.getFixedLabel('PERIODTIME').'</th>
		<th>'.getFixedLabel('openingbalance').'</th>
		<th>'.getFixedLabel('THERECEIVABLE').'</th>
		<th>'.getFixedLabel('THISPERIODOFPAID').'</th>
		<th>'.getFixedLabel('THISYEARTHETOTALRECEIVABLES').'</th>
		<th>'.getFixedLabel('THEACCUMNLATEDPAID').'</th>
		<th>'.getFixedLabel('THEFINALBALANCE').'</th>
	</tr>
	';
}
//销售排行榜 显示列
if($reportnames == 'Salesranking'){
	$salesranking_value = $_REQUEST['salesranking_value'];
	if(empty($salesranking_value)){
		$salesranking_value = $salesrank_array[0];
	}
	if($salesranking_value != 'due_num' && $salesranking_value != ''){
		if('due_amount' == $salesranking_value){
			$module = 'SalesOrder';
		}else if('sendpament_amount' == $salesranking_value){
			$module = 'CashBill';
		}else if('invoice_amount' == $salesranking_value){
			$module = 'Invoice';
		}else if('out_amount' == $salesranking_value){
			$module = 'OutboundOrder';
		}
		$fieldlabel = getTransTab($module) . '_' . getFixedLabel('SUM');
	}else{
		$module = 'SalesOrder';
		$fieldlabel = getFixedLabel('CONTRACTNUMBERHONE');
	}
	$reportFindHeader = '
		<th>'.getFixedLabel('ORDERNUM').'</th>
		<th>'.getTransTab($module).'_'.getFixedLabel('AssignedTo2').'</th>
		<th>'.getFixedLabel('Sector').'</th>
		<th>'.$fieldlabel.'</th>
	';
}
//var_dump($reportFindHeader);
if('SalesOrderTrack' == $reportnames || 'Salesforecastandanalysistable' == $reportnames || 'CashBillSum_SalesOrder' ==$reportnames || 'CashBillSum_Outboundorder' ==$reportnames || 'PurchaseOrderTrack' == $reportnames || 'SendCashBillSum_PurchaseOrder' == $reportnames){
	$salesranking_value = $reportnames;
}
if($reportname=="VideoRentalIncomeStatement") {
    $createdtimeinput = $_REQUEST['createdtimeinput'];
    //时间搜索条件
    switch ($createdtimeinput){
        case "thisyear": $startmonth = date('Y-01-01',time());break;
        case "lastyear": $startmonth = (date('Y',time())-1).'-01-01';break;
        case "nextyear": $startmonth = (date('Y',time())+1).'-01-01';break;
        default : $createdtimeinputarr = explode('~',$createdtimeinput);
            $startmonth = $createdtimeinputarr[0];break;
    }
    //公共的时间数组
    $end_month = date('Y-m-d', strtotime('+12 month', strtotime($startmonth)));
    include_once globalStatic::$root_directory.'modules/OftenUseReport/WeidijiaReport.php';
    $WeidijiaReportReportObj = new WeidijiaReport($showcolLists);
    $month_arr = $WeidijiaReportReportObj->dateMonths($startmonth, $end_month);
    $month_nums = sizeof($month_arr);
    for ($j = 0; $j < $month_nums; $j++) {
        $reportFindHeader .= '<th>' . $month_arr[$j] . '(不含税)' . '</th>';
        $reportFindHeader .= '<th>' . $month_arr[$j] . '(含税)' . '</th>';
        $reportFindHeader .= '<th>' . $month_arr[$j] . '(税)' . '</th>';
    }
}
$smarty->assign('CHECKLABEL',getSalesRankingType($salesranking_value));
$smarty->assign('REPORTFINDHEADER',$reportFindHeader);


if($reportname=='USERTRACKREPORT')//移动轨迹
{
    $points=$OftenUseReport->getReportListView();
    
    if(is_array($points)&&sizeof($points)>0)
    {
        $smarty->assign("MAP_CENTER_LAT",$points[0]['lat']);
        $smarty->assign("MAP_CENTER_LNG",$points[0]['lng']);
    }
    
   
	$smarty->assign('REPORTFILTERHTMLTRACK',$points);
}
else
    $smarty->assign('REPORTFILTERHTML',$OftenUseReport->getReportListView());
if($reportnames=='InventoryLedger'&&$_REQUEST['ajax']!=true){
    $basicfilterHtml2 = str_replace('$##$DefaultProductName$##$',$_REQUEST['InventoryLedger_Productids']['current_name'],$basicfilterHtml2);
    $smarty->assign("BASICFILTERHTML2",$basicfilterHtml2);
}


$smarty->assign("USEREPORTID",$usereportid);


#高级查询下拉框
if($reportabid!=''&&$reportabid!='0')
$columns_block=getadvDropHtml($reportabid);
$smarty->assign("COLUMNS_BLOCK",$columns_block[0]);
$smarty->assign("FOPTION",getAdvCriteriaHTML());

$smarty->assign("REL_FIELDS",Zend_Json::encode($columns_block[1]));
if(!empty($_REQUEST['advft_criteria_groups']) && !empty($_REQUEST['advft_criteria'])){
	$_REQUEST['searchtype'] = 'advSearch';
}
if($_REQUEST['searchtype']=='advSearch')
{
    require_once 'include/Zend/Json.php';
    $json = new Zend_Json();
    
    $advft_criteria = $_REQUEST['advft_criteria'];
    if(!empty($advft_criteria)) $advft_criteria = $json->decode($advft_criteria);
    $advft_criteria_groups = $_REQUEST['advft_criteria_groups'];
    if(!empty($advft_criteria_groups)) $advft_criteria_groups = $json->decode($advft_criteria_groups);
	crm_load_class_file('cls_QueryGenerator','modules/OftenUseReport');
	//$queryGenerator = new cls_QueryGenerator($currentModule, $current_user,'');
	//$queryGenerator->addUserSearchConditions($_REQUEST);
	//$a = $queryGenerator->getWhereClause();
	//echo $a;echo '<br><br>';
}


#高级查询保存
if(isset($_REQUEST['submode'])&& $_REQUEST['submode']=='saveCriteria')
{
    	
        updateUseReportCriteria($usereportid,$advft_criteria,$advft_criteria_groups);
}
#读取高级查询
$advft_criteria=getAdvancedFilterList($usereportid);
if($_REQUEST['ajax']&&$_REQUEST['ajax']=='true'&&$_REQUEST['Export']=='true')
{
    if($_REQUEST['Export']=='true')
    {		
		if($reportnames == 'Salesranking'){
			$salesranking_value = $_REQUEST['salesranking_value'];
			if(empty($salesranking_value)){
				$salesranking_value = $salesrank_array[0];
			}
			if($salesranking_value != 'due_num' && $salesranking_value != ''){
				if('due_amount' == $salesranking_value){
					$module = 'SalesOrder';
				}else if('sendpament_amount' == $salesranking_value){
					$module = 'CashBill';
				}else if('invoice_amount' == $salesranking_value){
					$module = 'Invoice';
				}else if('out_amount' == $salesranking_value){
					$module = 'OutboundOrder';
				}
				$fieldlabel = getTransTab($module) . '_' . getFixedLabel('SUM');
			}else{
				$module = 'SalesOrder';
				$fieldlabel = getFixedLabel('CONTRACTNUMBERHONE');
			}
			$exportheader[] = getFixedLabel('ORDERNUM');
			$exportheader[] = getTransTab($module).'_'.getFixedLabel('AssignedTo2');
			$exportheader[] = getFixedLabel('Sector');
			$exportheader[] = $fieldlabel;
		}
                //edit: xll 2023/08/02 BUG0067515 kfbcrm-报表分析-可视化分析-导出签到统计表-图片类型字段导出错误
                crm_load_class_file("cls_excelImage",'include');
                $excelimageobj=new cls_excelImage();
                $sql="select crm_address from ld_organizationdetails";
                $result = $adb->pquery($sql, array());
                $organization_crm_address = $adb->query_result($result,0,'crm_address');
                $OftenUseReport->export_type = 'excel';

                $csc = explode("</tr>",$OftenUseReport->getReportListView());

                include('PHPExcel/PHPExcel.php');

                $modulelabel = getTranstab('OftenUseReport');
                $modulelabel = str_replace(' ','_',iconv('UTF-8','gbk',$modulelabel));
                $file_name = 'OftenUseReport.xls';
                $file_dir = './storage/';

                if($get_progress == 'yes' && $startExportRow>0 ){
                    $objPHPExcel = PHPExcel_IOFactory::load($file_dir . $file_name);
                    $prevTotalRows = $_SESSION[$currentModule][$current_user->id]['exportReport']['prevTotalRows'];
                    $j = $prevTotalRows;
                }else{
                    $objPHPExcel = new PHPExcel();
                    $j = 2;
                }
                $objPHPExcel->setActiveSheetIndex(0);
                $activesheet=$objPHPExcel->getActiveSheet();
                foreach($exportheader as $key=>$arr){
                    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',$arr);
                    $tmp= PHPExcel_Cell::stringFromColumnIndex($key);
                    $objPHPExcel->getActiveSheet()->getColumnDimension($tmp)->setWidth(20);
                }

                require_once(globalStatic::$root_directory."include/simple_html_dom.php");
                //zxm 20230519 重复引用去掉
                //require_once(globalStatic::$root_directory."include/utils/CommonUtils.php");
                foreach($csc as $arr){
                	$cscs = explode("</td>",$arr);
                    $for_i = 0;
                    //37601: （1.6）常用报表> 应收款统计表_按合同统计表>导出Excel：导出的模板中【应收款余额】的数据没有被导出来。（需要补丁）
                    /*if($reporttype==10){
                	   array_pop($cscs);
                       if($reportname!='SalesOrderTrack')//28869: 常用报表>合同跟踪表:导出excel，导出的文件中【状态】列值为空
                       array_pop($cscs);
                	}*/
                	foreach($cscs as $tmpindex=>$value){
                        if(stripos($value,'/ww-open-data')!==false)
                        {
                             $htmlparseobj = new simple_html_dom();
                              $htmlparseobj->load($value);
                              $tmphtml_arr=$htmlparseobj->find('ww-open-data');
                              foreach($tmphtml_arr as $tmpparser)
                                {
                                    $type=$tmpparser->type;
                                    $openid=$tmpparser->openid;
                                    if($type=='userName'){
                                        $value=getUserRealNameBywxuserid($openid);
                                    }
                                    else if($openid!='')
                                    {
                                        
                                        $value =getGroupRealName($openid);
                                    }
                                }
                               
                                
                        }
                		$value = strip_tags(trim($value));
                        
						//$value = ltrim($value,'&nbsp;');
                        // duan 20231121 ltrim 会把字符串左侧的p 识别到并去掉（？）,改成别的方法
                        $value = str_replace('&nbsp;','',$value);

                		if($value == '&nbsp;'){
                			$value = '';
                		}
                        //BUG0068065 操作列不导出
                        if($tmpindex+1 > sizeof($exportheader))
                        {
                            $value = '';
                        }
                        $value=str_replace('&yen;','¥',strip_tags($value));
                		$value = decode_html($value);

                        //获取导出excel需要修改格式的字段类型
                        $changetype = 'V';
                        if($tmpindex <sizeof($datatype)){
                            $changetype = $datatype[$tmpindex];
                        }
                        //特殊处理数字部分
                        $tmpvalue = $value;

                        //获取金额与数量的小数位数为$tmpd,组成数组$decimal_arr
                        foreach ($OftenUseReport->showcolLists as $temp_val => $keyother) {
                            $fieldkeys = explode(':', $temp_val);
                            $tmpd= $fieldkeys[2];
                            $temp_val = $fieldkeys[0];
                            if (in_array($temp_val, array('OftenUseReport_PaymentBalance', 'OftenUseReport_PaymentPlanBalance', 'OftenUseReport_CashBillamount',
                                'OftenUseReport_SendCashBillamount', 'OftenUseReport_SendCashBillbalance', 'OftenUseReport_InvoiceBalance',
                                'oftenusereport_SendCashBillamount', 'oftenusereport_SendCashBillBalance', 'OftenUseReport_SendPaymentBalance'))) {
                                $tmpd = $OftenUseReport->system_deploy_351;
                            }
                            $decimal_arr[] =$tmpd;
                        }

                        //XUQIU1001388zl 增加货币符号数组,筛选货币字段
                        $allCurrencies=["¥","￡","￥","$","€","AUD","ALL","HKD","TWD"];

                        if($changetype == 'N' || $changetype == 'NN') {
                            $tmpdecimal = $decimal_arr[$tmpindex];
                            //拆分格式为字符串拼接，获取小数位数长度，拼接成新格式
                            $tmpstr = number_format(0, (int)$tmpdecimal);
                            $tmpvalue = str_replace(',', '', strip_tags($tmpvalue));
                            //数字类型设置小数位数
                            $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i) . $j)->getNumberFormat()->setFormatCode($tmpstr);

                            //XUQIU1001388zl 去除货币符号,转换导出格式为货币
                            foreach ($allCurrencies as $currency) {
                                if (strpos($tmpvalue, $currency) !== false) {
                                    $containcur = strpos($tmpvalue, $currency);
                                    $tmpvalue = str_replace($currency, '', strip_tags($tmpvalue));
                                    //货币设置为货币类型
                                    $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i) . $j)->getNumberFormat()->setFormatCode('#,##' . $tmpstr);
                                }
                            }
                        }
                        //XUQIU1001388zl 通过typeofdata筛选日期类型字段,修改导出格式为自定义
                        else if($changetype == 'D')
                        {
                            $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i).$j)->getNumberFormat()->setFormatCode('yyyy-mm-dd');
                        }
                        else if($changetype == 'DT')
                        {
                            $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i).$j)->getNumberFormat()->setFormatCode('yyyy-mm-dd hh:mm:ss');
                        }
                        else if($changetype == 'T')
                        {
                            $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i).$j)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_DATE_TIME3);
                        }
                        //edit: xll 2023/08/02 BUG0067515 kfbcrm-报表分析-可视化分析-导出签到统计表-图片类型字段导出错误
                        if(strpos($tmpvalue,'isImageField') === 0)
                        {
                            $imgStr = explode('//:/',$tmpvalue)[1];
                            $imgArr = explode('//;/',$tmpvalue);
                            //取第一个图片的path
                            $img_path = explode('//,/',$imgArr[0])[1];
                            $excelimageobj->setCellImage($objPHPExcel,$img_path,$j,$for_i,$activesheet,$organization_crm_address);
                        }else if(in_array($changetype,array('N','NN','D','DT','T'))){
                            $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($for_i) . $j, strip_tags($tmpvalue));
                        } else {
                            //报表分析-服务绩效统计表-选择时间“上月”生成报表，再点击导出excel，显示报错 zxm 20240419 BUG20240417-55
                            $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($for_i) . $j,trim($tmpvalue),PHPExcel_Cell_DataType::TYPE_STRING);
                        }

                		++ $for_i;
                	}
                	++ $j;
                }


                
                $objPHPExcel->getActiveSheet()->setTitle(getFixedLabel($reportname));
                $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
                $objWriter->save($file_dir.$file_name);
                require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
                //edit:duan date:2024/12/11 reason:签到统计报表增加分页导出功能
                if($get_progress == 'yes'){
                    $_SESSION[$currentModule][$current_user->id]['exportReport']['prevTotalRows'] = $j-1;
                    $total_row = $_SESSION[$currentModule][$current_user->id]['exportReport']['total_row'];
                    $result = [
                        'title'=>getFixedLabel('ExportExcel'),
                        'startExportRow'=>$endExportRow,
                        'endExportRow'=>$endExportRow+10,
                        'total_row'=>$total_row,
                        'downloadurl'=>'index.php?module='.$currentModule.'&action=ExportReport&ReportHeader=dheader&modulelabel='.$reportname.''
                    ];
                    if($endExportRow > $total_row){
                        $code = 2;
                        unset($_SESSION[$currentModule][$current_user->id]);
                    }else{
                        $code = 1;
                    }
                    ConvertTojsonString($code,$result, 'success');
                }

                if(isKehu001ServerPc()=='sssyes')
                {
                    $file_name = 'OftenUseReport.xls';
                    $file_dir = 'storage/';
                    $pathname=$file_dir.$file_name;
                     require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
                    $portobj=new cls_WeixinPort();
                 
                    
                  
                    $wx_downloadurl=  $portobj->UploadUserInfoFile(globalStatic::$root_directory.$pathname,$modulelabel.'.xls');
                     header("Location:".$wx_downloadurl);
                }
                else
                 header('Location: index.php?module='.$currentModule.'&action=ExportReport&ReportHeader=dheader&modulelabel='.$reportname.'');
                exit();
}}
$smarty->assign("isADMIN",is_admin($current_user));
$smarty->assign("CRITERIA_GROUPS",$advft_criteria);
$smarty->assign("THEME", $theme);
$rname = getFixedLabel($reportnames);
$smarty->assign("REPORTNAMES", $rname);
$smarty->assign("MODULE", $currentModule);
$smarty->assign("IMAGE_PATH", $image_path);

//editor:gyq_86 reason:库存台账前进后退功能 2018/11/23 10:12
if( $reportnames=='InventoryLedger'){
    if(!empty($_REQUEST['productids'])){
        $smarty->assign('ILPRODUCTIDS',$_REQUEST['productids'] );
        $smarty->assign('ILPRODUCTIDSCURRENT',$_REQUEST['productids_current']);
        $smarty->assign('ILPRODUCTIDSNAME',$_REQUEST['productids_name']);
    }else{
        $productids = $_REQUEST['InventoryLedger_Productids'];
        $productinfo = $_REQUEST['InventoryLedger_ProductidInfo'];
        if(!empty($productids)){
            $smarty->assign('ILPRODUCTIDS',implode(',',$productids['ids']) );
            $smarty->assign('ILPRODUCTIDSCURRENT',$productids['current']);
            $smarty->assign('ILPRODUCTIDSNAME',implode(',',$productids['name']));
            //****************************要考虑空值的情况********************************
			$smarty->assign('ILPRODUCTIDSCOUNT',count($productinfo));
            $smarty->assign('ILPRODUCTINFO_ORIGN', $productinfo);
            $smarty->assign('ILPRODUCTINFO', urlencode( json_encode($productinfo)));
            //editor:gyq_140 reason:库存台账当前产品显示的字段  2019/8/30 11:16
            $smarty->assign('ILPRODUCTLABEL', $_REQUEST['InventoryLedger_ProductidLabel']);
        }else{
			$smarty->assign('ILPRODUCTIDSCOUNT',0);
		}
    }
}
//editor:gyq_86 reason:库存报表 2018/11/26 18:15
if(isset($OftenUseReport->report_parent_type) && $OftenUseReport->report_parent_type=='kucun'){
    $page_html_arr = $OftenUseReport->page_html_arr;
    $smarty->assign("parent_type", $OftenUseReport->report_parent_type);
    $smarty->assign("recordListRange", $page_html_arr['total']);
    $smarty->assign("NAVIGATION", $page_html_arr['redirect_num']);
}
//时间插件
$date=date("Y-m-d");
$fday=date("Y-m-01",strtotime($date));
$lday=date("Y-m-d",strtotime("$fday +1 month -1 day"));
$begin_createdate = $fday;
$end_createdate = $lday;
$smarty->assign("begin_createdate", $begin_createdate);
$smarty->assign("end_createdate", $end_createdate);

if($reportnames=='TimeSheet personal monthly summary'){
	//Timesheet 个人月汇总表
	$UserCombo = array_keys($MergeSmowner['UserCombo']);
	//员工姓名不为空时
	if(!empty($_REQUEST['userid'])){
		$userid = $_REQUEST['userid'];
		$start_date = $_REQUEST['begin_createdate'];
		$end_date = $_REQUEST['end_createdate'];
	}else{
		$userid = $UserCombo[0];
		$date1=date("Y-m-d");
		$start_date=date("Y-m-01",strtotime($date1));
		$end_date=date("Y-m-d",strtotime("$start_date +1 month -1 day"));
	}
	$reportfilterhtml = getTimeSheetReport($start_date,$end_date,$userid);
	$smarty->assign('REPORTFILTERHTML',$reportfilterhtml);
}
if($reportnames=='SIGNINSTATISTICS'){
	$sendlog_date = $_REQUEST['sendlog_date'];
	if($_REQUEST['worktype'] == 'worktype_1'){
		$start_date = $sendlog_date;
		$end_date = $sendlog_date;
	}else{
		$sendlog_dates = explode('~',$sendlog_date);
		$start_date = trim($sendlog_dates[0]);
		$end_date = trim($sendlog_dates[1]);
	}
	$smarty->assign('WORKSTARTDATE',$start_date);
	$smarty->assign('WORKENDDATE',$end_date);
	if(empty($_REQUEST['userid'])){
		$smarty->assign('WORKUSERID','SmOwner_Search_Me');	
	}else{
		$smarty->assign('WORKUSERID',$_REQUEST['userid']);
	}
	//editor:gyq_135 reason:月度考勤表跳转考勤签到，默认选中用户  2019/8/14 15:38 ID1000568
    if($_REQUEST['SmOwnerSearchScope'] > 0&&$_REQUEST['redirect_from']=='checkin_monthly'){
        $smarty->assign("SmOwnerSearchScope",$_REQUEST['SmOwnerSearchScope']);
    }
    //editor:gyq_168 reason:签到统计表功能优化，增加考勤对象类型   2020/1/20 15:17
    $smarty->assign('OPTIONMODULE',cls_StaticCommonFun::getOptionModule('Singin'));
}
$smarty->assign('WORKTYPE',$_REQUEST['worktype']);
//echo $reportfilterhtml;echo '<br><br>';
if(empty($reportnames)){//所有报表都没有显示的情况下
    echo getFixedLabel('NOREPORTEAVAIL');
    exit();
}
if($_REQUEST['ajax']&&$_REQUEST['ajax']=='true')
{
    if($reportnames=='TimeSheet personal monthly summary'){
        echo '###SUCCESS###';
        echo $reportfilterhtml;
        exit();
    }else{
        if($_REQUEST['Print']!='true'){
			echo '###SUCCESS###';
			if($reportname=='USERTRACKREPORT'){
				ob_clean();
				echo json_encode($points);
			}else{
				if($_REQUEST['usereport_search'] == 'yes' && $reportnames == 'InventoryLedger'){
					$smarty->display("modules/OftenUseReport/UseReportEntries.tpl");
				}else{
					$smarty->display("modules/OftenUseReport/UseReportListContent.tpl");
				}
			}
				
		}else{
		  
          
            
            setWxSmarty($smarty);//获取企业微信的相关信息
            
			$smarty->display("modules/OftenUseReport/UseReportPrint.tpl");
		}
		exit();
    }

}else if($_REQUEST['frommodule']=='ReportAnalysis'||$currentModule=='ReportAnalysis'){
    //报表分析模块来的请求
    $smarty->assign('frommodule','ReportAnalysis');//如果是报表分析来的请求 把中间的报表菜单隐藏
    $smarty->display("ReportAnalysis/NewUseReportList.tpl");
}
else
{
    $smarty->display("modules/OftenUseReport/UseReportList.tpl");

}
?>