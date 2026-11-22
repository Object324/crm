<?php
/**
 * 更新操作
 * edit:can
 * date:20131104
 * reason:常用报表和自定义报表分开需求(V3.1)
 * */
 global $current_user;
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
if($_REQUEST['refreshUseReport']>0){
    //刷新界面的ID
    //40083: （51mis.com/kfbtest）常用报表>选择“库存台账”报表：选择后刷新界面，刷新后自动跳转到了“签到统计表”，而不是停留在刷新前的报表界面中。
    $_REQUEST['UseReport']=$_REQUEST['refreshUseReport'];
}
//editor:gyq_135 reason:修改报表文件结构  2019/8/15 18:12
if($_REQUEST['action']=='index_report'){
    include globalStatic::$root_directory.'modules/OftenUseReport/index_report.php';
    exit;
}

//editor:gyq_86 reason:库存报表,即时库存查询  待出入库数量 明细  2018/11/30 16:57
if($_REQUEST['ajax']=='true' && $_REQUEST['file']=='DetailNation'&&!$_REQUEST['Print']){
    include globalStatic::$root_directory.'modules/OftenUseReport/'.$_REQUEST['file'].'.php';
    exit;
}

include('modules/OftenUseReport/OftenUseReport.php');
//editor:gyq_135 reason:微信打卡同步至月度考勤表  2019/8/9 16:46 ID1000568
require_once(globalStatic::$root_directory.'modules/OftenUseReport/report_function.php');
require_once(globalStatic::$root_directory.'modules/OftenUseReport/renderHtml.php');
$renderHtmlObj = new renderHtml();

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
$tradeInfo = getVersionTradeInfo();
$trade = $tradeInfo['trade'];
$version_account = $tradeInfo['account'];

$parentwhere = $renderHtmlObj->getReportListParentWhere();//报表父节点条件
$where = $renderHtmlObj->getReportListWhere();//报表子节点条件
$sql ='select usereportid,name from ld_usereport where parent_id=0 '.$parentwhere.' order by sequence';//获取父节点报表
$parentresult = $adb->pquery($sql,array());
$reportHeader=array();
#获取父节点下子节点报表
for($i=0;$i<$adb->num_rows($parentresult);$i++)
{
    $sqlchild='select usereportid,name,reporttype from ld_usereport where parent_id=? and presence=0 '.$where.' order by sequence';
    $parentid=$adb->query_result($parentresult,$i,'usereportid');
    $parant_name = $adb->query_result($parentresult,$i,'name');
    $parentlabel=getFixedLabel($parant_name);
    $childresult=$adb->pquery($sqlchild,array($parentid));
    for($j=0;$j<$adb->num_rows($childresult);$j++)
    {
        $childname = $adb->query_result($childresult,$j,'name');
        $child_reporttype = $adb->query_result($childresult,$j,'reporttype');
        $childlabel=getFixedLabel($childname);
        $childusereportid=$adb->query_result($childresult,$j,'usereportid');
        //判断如果是火狐浏览器则不显示签到轨迹表
        if($childname=='Sign_in_track' && strpos($_SERVER['HTTP_USER_AGENT'],'Firefox') !== false){
            continue;
        }
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
        $reportHeader[$parentlabel][] = array(
            'label'=>$childlabel,
            'id'=>$childusereportid,
            'name'=>$childname,
            'type'=>$child_reporttype
        );
        //页面第一次进入获取默认查询的报表，禁止第一次进入的就是月度考情表
        if(!isset($_REQUEST['refreshUseReport'])&&$child_reporttype!=51&&empty($usereportid)) {
            $usereportid = $childusereportid;
        }
    }
}

if($_REQUEST['UseReport']){
    $usereportid=$_REQUEST['UseReport'];
}

$smarty->assign("USEREPORTS",$reportHeader);

//报表名称以及报表其他信息
$renderHtmlObj->setReportId($usereportid);
$reportInfo = $renderHtmlObj->getReportInfo();
$reportname = $reportInfo['reportname'];
$smarty->assign("reportlabel",getFixedLabel($reportname));

$reporttype=$reportInfo['reporttype'];
$reportabid=$reportInfo['reportabid'];
$parentid=$reportInfo['parentid'];
$basicfilter=$reportInfo['basicfilter'];
$advfilter=$reportInfo['advfilter'];
$setcolumns=$reportInfo['setcolumns'];
$pagewidthpercent=$reportInfo['pagewidthpercent'];
$smarty->assign('PARENTID',$parentid);
$smarty->assign('BASICFILTER',$basicfilter);

//签到轨迹表只显示单个用户
if($reportname == 'Sign_in_track'){
    $renderHtmlObj->reportname = $reportname;
}
//人员范围
$MergeSmowner = $renderHtmlObj->getMergeSmowner();
$smarty->assign('Merge_SmOwner',$MergeSmowner);
$smarty->assign("USEREPORTSNAME",$reportname);
Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign('TABID',getTabid('OftenUseReport'));



// zxm 2020-1009 常用报表增加提成报表（按合同和按收款）
if($reportname!=='Serviceperformanceappraisal'&&
    $reportname!='CashBillSum_SalesOrder'&&
    $reportname!='SalesOrderTrack'&&
    $reportname!='SalesCommissionsByCash'&&
    $reportname!='SalesCommissionsByOrder'&&
    $reportname!='CashBillSum_Paymentplan'){
    $smarty->assign('ADVFILTER',$advfilter);
}
$smarty->assign('SETCOLUMNS',$setcolumns);
$smarty->assign('PAGEWIDTHPERCENT',$pagewidthpercent);

//editor:gyq_86 reason:库存报表 2018/11/26 17:45
if($reportname=='InventoryAccount' || $reportname=='InventoryLedger'||$reportname=='InventoryQuery'){
    crm_load_class_file('ReportModel','modules/OftenUseReport');
    $OftenUseReport=new ReportModel();
    //editor:gyq_135 reason:report_parent_type赋值  2019/8/9 14:38 ID1000568
    $OftenUseReport->report_parent_type = 'kucun';
}else{
    $OftenUseReport=new OftenUseReport();
}

#列头查询设置
$sql='select * from ld_usereportcolumns where usereportid=? and columnshow=1 order by sequence';
$result=$adb->pquery($sql,array($usereportid));
$reportFindHeader="";
$showcolLists=array();
//zxm 微迪迦  视频收入报表 增加一列序号
if($reportname=="VideoRentalIncomeStatement") {
    $reportFindHeader='<th>#</th>';
    $showcolLists['SalesOrder_lineitem_id:V']=['1'=>'SalesOrder'];
}
$AllReportHeaders=array();
$fieldnames = '';
$select_fileds = [];//字段的详细信息，用于高级查找中确定是否为用户字段
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
    $fieldlabels = explode(':',$realcolumns);
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
    //合同跟踪表---	BUG20240130-47 zxm 001服务增强版，合同跟踪表，缺少成本、毛利和毛利率显示字段（服务合同也有“产品成本”字段）
    if($reportname=='SalesOrderTrack'){

    }else {
        if ($reportname == 'Contractnumber') {
            if ($fieldlabels[0] == 'ld_salesorder' && !vtlib_isModuleActive("SalesOrder") && !vtlib_isModuleActive("ServiceContracts")) {
                continue;
            }
        } else {
            if ($fieldlabels[0] == 'ld_salesorder' && !vtlib_isModuleActive("SalesOrder")) {
                continue;
            }
        }

        if ($fieldlabels[0] == 'ld_servicecontracts' && !vtlib_isModuleActive("ServiceContracts")) {
            continue;
        }
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
    $fieldmodules=explode('_',$fieldlabels[3]);
    $fieldModule = $fieldmodules[0];
    $fieldName = $fieldmodules[1];
    $showcolkey=$fieldModule.'_'.$fieldlabels[1];
    
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
        $sql='select ld_tranlabel.fieldlabel,typeofdata,columnname from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
          where columnname=\''.$fieldlabels[1].'\' and ld_tranlabel.languagetype=? and ld_tranlabel.tabid =(select tabid from ld_tab where name=\''.$fieldModule.'\')';
        $fieldResult=$adb->pquery($sql,array($languageType));
        if($adb->num_rows($fieldResult)>0)
        {
            $fieldlabel=$adb->query_result($fieldResult,0,0);
            $fieldlabel=getTranstab($fieldModule).'_'.$fieldlabel;
            $typeofdata=$adb->query_result($fieldResult,0,'typeofdata');
            $typeofdata=explode('~',$typeofdata);
            $typeofdata=$typeofdata[0];
        } else {
            $fieldlabel=$fieldmodules[1];
            switch($fieldlabel){
                case 'ordernum':
                    $fieldlabel = getFixedLabel('ORDERNUM');
                    break;
                case 'groupbycount':
                    $fieldlabel = getFixedLabel('CONTRACTNUMBERHONE');
                    break;
            }
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
    }else if($reportname=='Salesforecastandanalysistable'){
        //zxm 2021-1101 销售机会预测表
        $temp_columns = explode(':',$columns);
        $temp_columnname = $temp_columns[1];
        //前10个字段可以设置  后面的固定
        if(in_array($temp_columnname,['last_name','groupname','accountname','account_type','Potentials_smcreatorid','potentialname','potential_no','productcategory','sales_stage','lastsales_stage'])){
            $reportFindHeader.='<th rowspan="2">&nbsp;'.$fieldlabel.'</th>';
        }
    }else{
        if($reportname=="ProductRanking"){
            //zxm 2020-0220 产品销售排行榜 排行维度改变联动表头改变
            $SalesCommissionObj = new SalesCommission();
            $commissionType = $SalesCommissionObj->getProductRankingDimension('',"product_ranking_type","product_ranking_type","array");
            $commissionTypeBak = $commissionType;
            $product_ranking_type = $_REQUEST['product_ranking_type'];
            $commissionTypeFirstName = array_shift($commissionTypeBak);//产品签约数量
            $commissionTypeFlip = array_flip($commissionType);
            $commissionTypeFirstKey = array_shift($commissionTypeFlip);//productOrderCount

            if(empty($product_ranking_type)){
                $product_ranking_type_name = $commissionTypeFirstName;
                $product_ranking_type = $commissionTypeFirstKey;
            }else{
                $product_ranking_type_name = $commissionType[$product_ranking_type];
            }
            $_REQUEST['product_ranking_type'] = $product_ranking_type;
            if($fieldlabel=='产品签约数量'){
                $reportFindHeader.='<th>&nbsp;'.$product_ranking_type_name.'</th>';
            }else if($fieldlabel=='签约_产品名称'){
                //签约 订单 开票 出库
                //0044717: （61mis.com/kfbcrm）常用报表-产品销售排行榜；“签约_产品名称”没有根据排行维度中的选项显示对应标签
                $commissionType = array_flip($commissionType);
                $tempheader = '';
                switch ($product_ranking_type){
                    case "productSignCount":
                    case "productSignAmount":$tempheader=getFixedLabel("qianyue");break;
                    case "productOrderCount":
                    case "productOrderAmount":$tempheader=getFixedLabel("dingdan");break;
                    case "productInvoiceAmount":$tempheader=getFixedLabel("kaipiao");break;
                    case "productOutboundCount":
                    case "productOutboundAmount":$tempheader=getFixedLabel("chuku");break;
                }
                $tempheader .= '_'.getFixedLabel("PRODUCTNAME");
                $reportFindHeader.='<th>&nbsp;'.$tempheader.'</th>';
            }else{
                $reportFindHeader.='<th>&nbsp;'.$fieldlabel.'</th>';
            }
        }else{
            $reportFindHeader.='<th>&nbsp;'.$fieldlabel.'</th>';
        }
    }
    $exportheader[] = $fieldlabel;
    if(($typeofdata == 'N'||$typeofdata == 'NN')&& ($column_module_name == 'OftenUseReport')){
        $typeofdata_decimal = 2;
    }
    $showcolLists[ $showcolkey.':'.$typeofdata.':'.$typeofdata_decimal.':'.$uitype.':'.$fieldtype.':'.$isdetailfield]=array($columshow=>$fieldlabels[0]);
	$selected = '';
	if($is_advanced == 1){
		$selected = "selected = ''";
	}
	if(strpos($realcolumns,'ld_products:costprice:costprice:Products') !== false ||  strpos($realcolumns,'ld_outboundorder:out_no:out_no:OutboundOrder') !== false||  strpos($realcolumns,'ld_products:productid:productid:Products') !== false||  strpos($realcolumns,'ld_products:product_count:product_count:Products') !== false){
	}else{
	    //editor:gyq_122临时 reason:高级查找字段隐藏日期字段  2019/6/14 17:46
        if($OftenUseReport->report_parent_type=='kucun'&&$columnname=='bill_date'){
            continue;
        }
		$fieldnames .= "<option value=\'$realcolumns\' $selected>$fieldlabel</option>";
	}
}
if($reportname=='Salesforecastandanalysistable'){
    $fieldObj = Field::getInstance('Potentials',$adb);
    $moduleFields = $fieldObj->getModuleFields();
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
            <tr>';
    if(vtlib_isModuleActive("SalesOrder"))
    {
        $reportFindHeader.=' <th class="borderT">'.getFixedLabel('Expect').'-'.getFixedLabel('ContractAmount2').'</th>';
    }
    $reportFindHeader.=' <th class="borderT">'.getFixedLabel('Expect').'-'.getFixedLabel('SigningDate').'</th>
            <th class="borderT">'.getFixedLabel('Expect').'-'.getFixedLabel('CollectionAmount').'</th>
            <th class="borderT">'.getFixedLabel('Expect').'-'.getFixedLabel('CollectionDate').'</th>
            <th class="borderT">'.getFixedLabel('Actual').'-'.getFixedLabel('ContractAmount2').'</th>
            <th class="borderT">'.getFixedLabel('Actual').'-'.getFixedLabel('SigningDate').'</th>
            <th class="borderT">'.getFixedLabel('Actual').'-'.getFixedLabel('CollectionAmount').'</th>
            <th class="borderT">'.getFixedLabel('Actual').'-'.getFixedLabel('CollectionDate').'</th>';
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

/**
 * 更新操作
 * edit:can
 * date:20131223
 * reason:06420: 常用报表后面缺少“查看数据”列，需求上有要求，希望加上，点击之后，应该能够打开对应单据的查看明细界面。
 * */

//var_dump($reportFindHeader);
// Liver add $reporttype==50,原因是签到明细表增加操作列
//Liver 去掉合同订单跟踪表、采购订单跟踪表 操作列，bug0027469
//zxm 2020-1009 常用报表增加提成报表（按合同和按收款）
if(($reporttype==10 || $reporttype==50)&& $reportname !='InventoryAccount'&& $reportname !='InventoryLedger'&& $reportname !='InventoryQuery' && $reportname !='SalesOrderTrack' &&$reportname !='SalesCommissionsByOrder'&&$reportname !='SalesCommissionsByCash' &&   $reportname!='PurchaseOrderTrack')
{
    $showcolLists[ 'lbl_action'.':V']=array(1=>'操作');
    $reportFindHeader.='<th>&nbsp;'.getFixedLabel('OPERATING').'</th>';
}
//zxm 2021-0716  东方报警east_alarm  三列表头 ,'tichengof1','tichengof9','overfloorprice'  其他账套需要把这三列去掉
if($version_account!="east_alarm"){
    unset($showcolLists['tichengof1']);
    unset($showcolLists['tichengof9']);
    unset($showcolLists['overfloorprice']);
}
//editor:gyq_122 reason:删除__construct复杂参数，抽成新方法init_params 2019/6/13 17:31
//editor:gyq_20190726 reason:init_params放到操作按钮代码上面导致序时簿没有操作按钮！！！！！！！！
$OftenUseReport->init_params($reporttype,$reportname,$usereportid,$adb,$showcolLists,$AllReportHeaders,$reportabid,$advfilter);
//editor:gyq_122 reason:三个库存报表，增加“仓库”列，以及增加“高级查找”范围  2019/6/13 15:06
//zxm 2021-0222  产品排行榜增加高级查询
if($OftenUseReport->report_parent_type=='kucun'||$reportname=="ProductRanking"){
    $search_modue_name = 'Products';
    $customView = CustomView::getInstance($search_modue_name);
    $queryGenerator =  QueryGenerator::getInstance($search_modue_name, $current_user,$customView);
    crm_load_class_file('ListViewController','include/ListView');
    $controller = new ListViewController($adb, $current_user, $queryGenerator);
    //editor:gyq_20191205 reason:0038754: （kfbcrm）库存台账，高级查询，缺少“产品编号”和“规格型号”查询（需要补丁）
    //$_REQUEST['kucun_report_advance_search_repeat_field'] = array('productname','product_no','productsheet','unit_price','qtyearly');
    $_REQUEST['kucun_report_advance_search_repeat_field'] = array('productname');
    $fieldnames_product = $controller->getAdvancedSearchOptionString();
	//zkt 20220519 【ID1002788】【管理分类设置条件，高级查找、平铺查找，查询字段选择“单选用户”字段时，选择条件增加“为当前用户”选项（徐煜轩）】
    $tmp_prodtct_focus = CRMEntity::getInstance($search_modue_name);
    $tmp_product_fields = $tmp_prodtct_focus->fieldobj->getFieldListArray();
    $select_fileds = array_merge($select_fileds,$tmp_product_fields['fields']);
    $shtml_p_blockname = "<optgroup label='".getFixedLabel('OFTENUSEREPORTWORD')."-".getFixedLabel('INVENTORY').getFixedLabel('INFORMATION')."' class='select' style='border:none'>";
    $fieldnames = $shtml_p_blockname.$fieldnames.$fieldnames_product;

}
$smarty->assign('ADVANCEFIELDINFO',json_encode($select_fileds));//字段信息
$smarty->assign("FIELDNAMES", $fieldnames);
//Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/16 0016 上午 9:43
crm_load_class_file("cls_PickList", 'modules/PickList');
$objpinklist = new cls_PickList();

#基本查询
$sql="select * from ld_usereportbasic  where usereportid=? order by sequence";
$result=$adb->pquery($sql,array($usereportid));
$basicfilterHtml="";
$month=date("m");
$datemonth=date("Y-m");

for($i=0;$i<$adb->num_rows($result);$i++)
{
    $basicInfos=explode(":",$adb->query_result($result,$i,'columns'));
    $basicdefaultvalue=$adb->query_result($result,$i,'defaultvalue');
    $fieldmodules=explode('_',$basicInfos[3]);
    $fieldModule=$fieldmodules[0];
    $fieldName=$fieldmodules[1];
    if(strtolower($basicInfos[count($basicInfos)-1])=="d")
    {
            //ld_salesorder:signed_data:signed_data:SalesOrder_signed_data:D
            $datefindcolumn = $basicInfos[0] . '.' . $basicInfos[1];
            $smarty->assign("DATEFINDCOLUMN", $datefindcolumn);
            //bug 0012548
            //$basicfilterHtml.="<td><span class='changeday' style='padding-left:0px;'>". getFixedLabel('STATISTTIME').':</span>';
            if ($reportname == 'Salesranking' || $reportname == 'SalesCommissionsByOrder' || $reportname == 'SalesCommissionsByCash') {
                $basicfilterHtml .= "<td width='100%' colspan='2'>";
            } else if ($reportname == 'SIGNINSTATISTICS' || $reportname == 'Sign_in_track'|| $reportname == 'SignDistribution') {
                $basicfilterHtml .= "<td width='600' colspan='4'>";
            } else if($reportname=='Salesforecastandanalysistable'||$reportname=='VideoRentalIncomeStatement'){
                $basicfilterHtml .= "<td>";
            }else if($OftenUseReport->report_parent_type=='kucun'){

            }else{
                $basicfilterHtml .= "<td width='600' colspan='2'>";
            }
            //改变样式
            $basicvalues[0] = $basicdefaultvalue;
            if (strpos($basicdefaultvalue, '~') > 0) {
                $basicvalues = explode('~', $basicdefaultvalue);

            }
            //本日，昨日，本周，本月，时间获取
            $todayselect = date('Y-m-d', time());
            $yesterdayselect = date("Y-m-d", time() - 24 * 60 * 60);
            //zxm 20230416 当今天是周日的时候 本周的日期计算不对  BUG0064378
            $sdefaultDate = date("Y-m-d");
            $first=1;
            $w=date('w',strtotime($sdefaultDate));
            $week_begin=date('Y-m-d',strtotime("$sdefaultDate -".(($w ? $w - $first : 6)).' days'));
            $week_end=date('Y-m-d',strtotime("$week_begin +6 days"));
            $lastweeks = DateOperation::getlastweekrange($todayselect);
            $lastweekbegin = $lastweeks[0];
            $lastweekend = $lastweeks[sizeof($lastweeks) - 1];
            //上月
            $time = strtotime(date('Y-m-d'));
            $smarty->assign("NOW_DATE", date('Y-m-d'));
            $last_month_begin = date('Y-m-01', strtotime(date('Y', $time) . '-' . (date('m', $time) - 1) . '-01'));
            $last_month_end = date('Y-m-d', strtotime("$last_month_begin +1 month -1 day"));
            //本月
            $month_begin = date("Y-m-d", mktime(0, 0, 0, date("m"), 1, date("Y")));
            $month_end = date("Y-m-d", mktime(23, 59, 59, date("m"), date("t"), date("Y")));
            //本年
            $begin_this_year = date('Y-01-01');
            $end_this_year = date('Y-12-31');
            foreach ($basicvalues as $keyvalue => $valuecontent) {
                switch ($valuecontent) {
                    case "thismonth":
                    case "thisstartmonth":
                        $startdatemonth = $datemonth . '-01';
                        $enddatemonth = $datemonth . '-' . date("t", strtotime($datemonth));
                        /**
                         * @author:andy
                         * @data:
                         * @reason:报表查询时间段样式更改，双时间录入框改为单时间段录入框
                         * @version:|
                         */
                        if ($reportname == 'Serviceperformanceappraisal' || $reportname == 'SIGNINSTATISTICS' || $reportname=='Sign_in_track'|| $reportname=='SignDistribution') {
                            $startdatemonth = $todayselect;
                            $enddatemonth = $todayselect;
                            $selected_class_1 = 'onselected_A';
                        }
                        $thequerytime = $startdatemonth . ' ' . '-' . ' ' . $enddatemonth;
                        //editor:gyq_135 reason:月度考勤表跳转到签到表，时间div默认选中  2019/8/14 15:56 ID1000568
                        $selected_class_2 = '';
                        if ($_REQUEST['redirect_from'] == 'checkin_monthly') {
                            $month_start = strtotime($_REQUEST['startmonth'] . ' 00:00:00');
                            $month_end = strtotime($_REQUEST['endmonth'] . ' 23:59:59');
                            $thequerytime = date('Y-m-d', $month_start) . ' ' . '-' . ' ' . date('Y-m-d', $month_end);
                            $selected_class_1 = '';
                            $selected_class_2 = 'onselected_A';
                        }
                        /**
                         * @author:andy
                         * @data:
                         * @reason:bug0012272: 常用报表：所有的报表，点击打开时，时间段都是默认选中的是【今日】，但是后面的日历时间显示的是本月，如图
                         *说明    常用报表：所有的报表，点击打开时，时间段都是默认选中的是【今日】，但是后面的日历时间显示的是本月
                         *常用报表，除【服务绩效统计表】默认为 当日，其他常用报表都默认为本月 刘锁
                         * @version:v5.8
                         */
                        if ($reportname == 'Serviceperformanceappraisal' || $reportname == 'SIGNINSTATISTICS' ) {
                            $basicfilterHtml .= "<a style='margin-left: -6px;' class='" . $selected_class_1 . " changeday' id='today' name='OftenUseReport_search' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'today','$todayselect','$todayselect')\">" . getFixedLabel('checktoday') . "</a>
                            <a id='yesterday' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'yesterday','$yesterdayselect','$yesterdayselect')\">" . getFixedLabel('checkyesterday') . "</a>
                             <a id='lastweek' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'lastweek','$lastweekbegin','$lastweekend')\">" . getFixedLabel('lastweek') . "</a>
                           
                            <a id='week' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'week','$week_begin','$week_end')\">" . getFixedLabel('thisweek') . "</a>
                            <a id='lastmonth' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'lastmonth','$last_month_begin','$last_month_end')\">" . getFixedLabel('lastmonth') . "</a>
                            <a id='month' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'month','$month_begin','$month_end')\">" . getFixedLabel('thismonth') . "</a>
                            <a id='year' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'year','$begin_this_year','$end_this_year')\">" . getFixedLabel('THISYEAR') . "</a> 
                            <a id='all' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'all','2000-01-01','2050-12-31')\">" . getFixedLabel('ALL') . "</a>";
                        } else if ($reportname=='Sign_in_track'||$reportname=='SignDistribution'){
                            //签到轨迹表要求默认选中本周
                            $basicfilterHtml .= "<a style='margin-left: -6px;' class='changeday' id='today' name='OftenUseReport_search' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'today','$todayselect','$todayselect')\">" . getFixedLabel('checktoday') . "</a>
                            <a id='yesterday' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'yesterday','$yesterdayselect','$yesterdayselect')\">" . getFixedLabel('checkyesterday') . "</a>
                             <a id='lastweek' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'lastweek','$lastweekbegin','$lastweekend')\">" . getFixedLabel('lastweek') . "</a>
                            <a id='week' name='OftenUseReport_search' class='" . $selected_class_1 . " changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'week','$week_begin','$week_end')\">" . getFixedLabel('thisweek') . "</a>
                            <a id='lastmonth' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'lastmonth','$last_month_begin','$last_month_end')\">" . getFixedLabel('lastmonth') . "</a>
                            <a id='month' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'month','$month_begin','$month_end')\">" . getFixedLabel('thismonth') . "</a>
                            <a id='year' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'year','$begin_this_year','$end_this_year')\">" . getFixedLabel('THISYEAR') . "</a> 
                            <a id='all' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'all','2000-01-01','2050-12-31')\">" . getFixedLabel('ALL') . "</a>";
                            
                        
                        } else if ($reportname == 'TimeSheet personal monthly summary'||$reportname =='Salesforecastandanalysistable'||$reportname =='VideoRentalIncomeStatement') {
                            //TimeSheet个人月汇总表：不需要显示日期查询
                            //销售机会预览表：不需要显示日期查询

                        } else {
                            $basicfilterHtml .= "<a style='margin-left: -6px;' class='changeday' id='today' name='OftenUseReport_search' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'today','$todayselect','$todayselect')\">" . getFixedLabel('checktoday') . "</a>
                            <a id='yesterday' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'yesterday','$yesterdayselect','$yesterdayselect')\">" . getFixedLabel('checkyesterday') . "</a>
                             <a id='lastweek' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'lastweek','$lastweekbegin','$lastweekend')\">" . getFixedLabel('lastweek') . "</a>
                            <a id='week' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'week','$week_begin','$week_end')\">" . getFixedLabel('thisweek') . "</a>
                            <a id='lastmonth' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'lastmonth','$last_month_begin','$last_month_end')\">" . getFixedLabel('lastmonth') . "</a>
                            <a id='month' name='OftenUseReport_search' class='onselected_A changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'month','$month_begin','$month_end')\">" . getFixedLabel('thismonth') . "</a>
                            <a id='year' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'year','$begin_this_year','$end_this_year')\">" . getFixedLabel('THISYEAR') . "</a>
                            <a id='all' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'all','2000-01-01','2050-12-31')\">" . getFixedLabel('ALL') . "</a>";
                        }
                        if ($reportname == 'HighAndNewTechnologyEnterpriseSchedule' || $reportname == 'ProjectCompletionStatisticsReport') {
                            $riqi = '申报月份';
                        } else if($reportname =='Salesforecastandanalysistable'){
                            //销售机会 预测表
                            if($fieldName=="receivablesforecastdate"){
                                $riqi = '预计收款日期';
                            }else{
                                $riqi = gettranslabelfields($fieldModule,$fieldName);
                            }
                        }else{
                            $riqi = getFixedLabel('DATESELECTION');
                        }
                        if($reportname =='Salesforecastandanalysistable'){
                            //销售机会 预测表  两个时间  预计成交时间 预计收款时间
                            $basicfilterHtml .= '<div class="home_header_top" style="background-color:#fafafa;;" id="'.$fieldName.'"><div class="home-header-top-date width120" style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;height:43px;" title="'.$riqi.'">'.$riqi.'：</div>';
                            $basicfilterHtml .= '<div class="home-header-filter-select date-select">
                        <a class="header_value j-date-value" href="javascript:;" data-value="thismonth">
                            <input name="'.$fieldName.'text" id="'.$fieldName.'text" type="text" value="本月" onkeyup="timelistsearch(this)">
                            <input name="'.$fieldName.'input" id="'.$fieldName.'input" type="hidden" value="thismonth">
                        </a>
                        <div class="select-box date-box fn-hide" style="position: absolute; left: 0px !important; top: 25px !important;display:none;">
                            <ul class="select-list date-list" id="date_list" style="margin-bottom: 0px;">
                                <li class="" data-value="thistoday"> 今日 </li>
                                <li data-value="yestoday"> 昨日 </li>
                                <li data-value="thisweek"> 本周 </li>
                                <li data-value="thismonth" class="selected"> 本月 </li>
                                <li data-value="lastmonth"> 上月 </li>
                                <li data-value="thisquarter"> 本季度 </li>
                                <li data-value="lastquarter"> 上季度 </li>
                                <li data-value="thisyear"> 本年度 </li>
                                <li data-value="lastyear"> 上年度 </li>
                                <li data-value="all"> 全部 </li>
                                <li data-value="custom"> 自定义时间 </li>
					            <li data-value="custom_start" tag="custom_set" style="display:none;">
                                <input id="begin_date" style="height: 20px;" class="Wdate" name="begin_date" tabindex="d" fieldonly="0" size="12" maxlength="10" value="2021-11-02" onclick="WdatePicker()" type="text">
                                </li>
                                <li data-value="custom_end" tag="custom_set" style="display:none;">
                                    <input id="end_date" style="height: 20px;" class="Wdate" name="end_date" tabindex="d" fieldonly="0" size="12" maxlength="10" value="2021-11-02" onclick="WdatePicker()" type="text">
                                </li>
                                <li data-value="custom_btn" tag="custom_set" style="display:none;padding-bottom: 37px;">
                                    <div class="u-datepicker-drop-list-btns-btn">确定</div>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>';
                            if(!isset($_REQUEST[$fieldName.'input'])){
                                $_REQUEST[$fieldName.'input'] = 'thismonth';//默认都是本月
                            }
                        }else if($reportname =='VideoRentalIncomeStatement'){

                            //zxm 2022-0112 微迪迦  报表 视频租赁收入表
                            $riqi = "查询范围";
                            $basicfilterHtml .= '<div class="home_header_top" style="background-color:#fafafa" id="'.$fieldName.'"><div class="home-header-top-date">'.$riqi.'：</div>';
                            $basicfilterHtml .= '<div class="home-header-filter-select date-select">
                                    <a class="header_value j-date-value" href="javascript:;" data-value="thisyear">
                                        <input name="'.$fieldName.'text" id="'.$fieldName.'text" type="text" value="本年" onkeyup="timelistsearch(this)">
                                        <input name="'.$fieldName.'input" id="'.$fieldName.'input" type="hidden" value="thisyear">
                                    </a>
                                    <div class="select-box date-box fn-hide" style="position: absolute; left: 0px !important; top: 25px !important;display:none;">
                                        <ul class="select-list date-list" id="date_list" style="margin-bottom: 0px;">
                                            <li data-value="thisyear"> 今年 </li>
                                            <li data-value="lastyear"> 去年 </li>
                                            <li data-value="nextyear"> 明年 </li>
                                            <li data-value="custom"> 自定义时间 </li>
                                            <li data-value="custom_start" tag="custom_set" style="display:none;">
                                                <input id="begin_date" style="height: 20px;" class="Wdate" name="begin_date" tabindex="d" fieldonly="0" size="12" maxlength="10" value="2021-11-02" onclick="WdatePicker()" type="text">
                                            </li>
                                            <li data-value="custom_end" tag="custom_set" style="display:none;">
                                                <input id="end_date" style="height: 20px;" class="Wdate" name="end_date" tabindex="d" fieldonly="0" size="12" maxlength="10" value="2021-11-02" onclick="WdatePicker()" type="text">
                                            </li>
                                            <li data-value="custom_btn" tag="custom_set" style="display:none;padding-bottom: 37px;">
                                                <div class="u-datepicker-drop-list-btns-btn">确定</div>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </div>';
                            if(!isset($_REQUEST[$fieldName.'input'])){
                                $_REQUEST[$fieldName.'input'] = 'thisyear';//默认都是本月
                            }
                        }
                        else{
                            $basicfilterHtml .= "<span class='" . $selected_class_2 . " changeday colorLink' id='daterangepicker_search'>" . $riqi . "&nbsp;</span>";
                            $data_system = "width:180px;padding-left:3px;margin-left: 5px;";
                            if ($reportname == 'InventoryAccount' || $reportname == 'InventoryLedger') {
                                $basicfilterHtml .= '<span class="changeday">' . getFixedLabel('DATE') . ':</span>';
                                $data_system = "width:180px;padding-left:3px;margin-right:10px;";
                            }
                            $basicfilterHtml .= "<input class='ld-input-inner' type='text' readonly=true value='$thequerytime' id='startmonth' name='startmonth' findcolumn= '" . $adb->query_result($result, $i, 'columns') . "' style='" . $data_system . "'/>";
                        }
                        //销售排行：排行维度
                        if ($reportname == 'Salesranking') {
                            $basicfilterHtml .= '&nbsp;&nbsp;&nbsp;&nbsp;' . getFixedLabel('Rankingdimension') . "：&nbsp;";
                            $basicfilterHtml .= "<select name='salesranking_value' id='salesranking_value' onchange='changeSalesRank(this)' class='commonSelectPop height25'>";
                            if (vtlib_isModuleActive('SalesOrder') || vtlib_isModuleActive('ServiceContracts')) {
                                $due_num_selected = '';
                                if (!empty($_REQUEST['salesranking_value']) && $_REQUEST['salesranking_value'] == 'due_num') {
                                    $due_num_selected = 'selected';
                                }
                                $due_amount_selected = '';
                                if (!empty($_REQUEST['salesranking_value']) && $_REQUEST['salesranking_value'] == 'due_amount') {
                                    $due_amount_selected = 'selected';
                                }
                                $basicfilterHtml .= "<option value='due_num' tag='" . getSalesRankingType('due_num') . "' $due_num_selected>" . getFixedLabel('CONTRACTNUMBERHONE') . "</option>";
                                $basicfilterHtml .= "<option value='due_amount' tag='" . getSalesRankingType('due_amount') . "' $due_amount_selected>" . getFixedLabel('CONTRACTAMOUNTPANEL') . "</option>";
                                $salesrank_array[] = 'due_num';
                                $salesrank_array[] = 'due_amount';
                            }
                            if (vtlib_isModuleActive('CashBill')) {
                                $sendpament_amount_selected = '';
                                if (!empty($_REQUEST['salesranking_value']) && $_REQUEST['salesranking_value'] == 'sendpament_amount') {
                                    $sendpament_amount_selected = 'selected';
                                }
                                $basicfilterHtml .= "<option value='sendpament_amount' tag='" . getSalesRankingType('sendpament_amount') . "' $sendpament_amount_selected>" . getFixedLabel('AMOUNTTO') . "</option>";
                                $salesrank_array[] = 'sendpament_amount';
                            }
                            if (vtlib_isModuleActive('Invoice')) {
                                $selected = '';
                                if(!empty($_REQUEST['salesranking_value']) && $_REQUEST['salesranking_value'] == 'invoice_amount'){
                                    $selected = 'selected';
                                }
                                $basicfilterHtml .= "<option value='invoice_amount' tag='" . getSalesRankingType('invoice_amount') . "' $selected>" . getFixedLabel('INVOICEAMOUNT') . "</option>";
                                $salesrank_array[] = 'invoice_amount';
                            }
                            if (vtlib_isModuleActive('OutboundOrder')) {
                                $selected = '';
                                if(!empty($_REQUEST['salesranking_value']) && $_REQUEST['salesranking_value'] == 'out_amount'){
                                    $selected = 'selected';
                                }
                                $basicfilterHtml .= "<option value='out_amount' tag='" . getSalesRankingType('out_amount') . "' $selected>" . getFixedLabel('AMOUNTLIBRARY') . "</option>";
                                $salesrank_array[] = 'out_amount';
                            }
                            $basicfilterHtml .= "</select>";

                        }
                        $basicfilterHtml .= '</td>';
                        break;
                    case "thisendmonth":
                        $enddatemonth = $datemonth . '-' . date('t', strtotime($datemonth));
                        if ($reportname == 'Serviceperformanceappraisal' || $reportname == 'SIGNINSTATISTICS' || $reportname=='Sign_in_track'|| $reportname=='SignDistribution') {
                            $enddatemonth = $todayselect;
                        }
                        $basicfilterHtml .= '</td>';
                        break;
                }
            }
    }else{
        if($reportname=='CommencementSchedule'||$reportname=='OverallCommencementSchedule'||$reportname=='PartnerCommencementSchedule'||$reportname=='LecturerCommencementSchedule'
        ||$reportname=='Studentsparticipatinginthetrainingschedule'||$reportname=='Customersparticipatinginthetrainingschedule'
        ||$reportname=='Contactbusinesstable'||$reportname=='KPCCommencementDetails'||$reportname=='CourseparticipantsKPClist')
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
           if($fieldlabel=='合作伙伴'&&($reportname=='Studentsparticipatinginthetrainingschedule'||$reportname=='Contactbusinesstable')){$fieldlabel='所在公司';}
           if($fieldlabel=='合作伙伴'&&$fieldModule=='salesorder'&&$reportname=='Customersparticipatinginthetrainingschedule'){
           $fieldlabel='客户';
            }
           
            if(($fieldlabel=='产品类别'||$fieldlabel=='课程类别')&&$trade=='training'){
                                                
                $basicfilterHtml.='<td>业务类别：<select class="ld-select-inner width100" name="basicotherfinds" id="basicotherfinds" onchange="DoOnchange()" findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                foreach($productcategory as $arr){
                $basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
                }
                $basicfilterHtml.='</select></td>'; 
            }elseif(($fieldlabel=='课程名称'||$fieldlabel=='Product Name')&&$trade=='training'){
                $basicfilterHtml.='<td>'.$fieldlabel.'：<select style="width:100px;" class="ld-select-inner" name="basicotherfindz" id="basicotherfindz" findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                foreach($productname as $arr){
                $basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
                }
                $basicfilterHtml.='</select></td>'; 
          }elseif($fieldlabel=='开课地点'||$fieldlabel=='cf_1084'){
                $basicfilterHtml.='<td>&nbsp;&nbsp;'.$fieldlabel.'：<input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" name="basicotherfind2" id="basicotherfind2" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
          }elseif($fieldlabel=='讲师'||$fieldlabel=='cf_1082'){
                $basicfilterHtml.='<td>&nbsp;&nbsp;'.$fieldlabel.'：<select class="ld-select-inner" name="basicotherfind3 " id="basicotherfind3" findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                foreach($cf_1082 as $arr){
                $basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
                }
                $basicfilterHtml.='</select></td>'; 
          }elseif($fieldlabel=='姓名'){
                $basicfilterHtml.='<td> &nbsp;&nbsp;';
                if($reportname=='Contactbusinesstable'){$basicfilterHtml.='联系人';}else{$basicfilterHtml.='学员';};
                $basicfilterHtml.='：<input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" name="basicotherfind4" id="basicotherfind4" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
          }elseif($fieldlabel=='客户'&&$reportname=='Customersparticipatinginthetrainingschedule'){
                $basicfilterHtml.='<td>&nbsp;&nbsp;'.$fieldlabel.'：<input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" name="basicotherfind5" id="basicotherfind5" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
          }else{
                $basicfilterHtml.='<td>&nbsp;&nbsp;'.$fieldlabel.'：<input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" name="basicotherfind" id="basicotherfind" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
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
            if((($searchwhere!='approvestatus'&&$searchwhere!='contract_no'&&$reportname=='SalesOrderTrack')
            ||($searchwhere!='approvestatus'&&$reportname!='SalesOrderTrack'))
            &&($reportname!='hoursqueryreport'&&$reportname!='InventoryAccount'&&$reportname!='InventoryLedger' &&$reportname!='InventoryQuery'&&$reportname!='Eachprojectcontractincomestatisticsreport'
            &&$reportname!='Orderexpenditurestatisticsreport'&&$reportname!='Allpaymentsstatisticsreport'
            &&$reportname!='Serviceperformanceappraisal'&&$reportname!='Thestatisticalreportofprojectperformance'
            &&$reportname!='Xuanyuanlawnbusinessmanagementreport'&&$reportname!='HighAndNewTechnologyEnterpriseSchedule'
            &&$reportname!='ProjectCompletionStatisticsReport'&&$reportname!='Reportingpaymentschedulestatistics'&&
            ($reportname!='ProjectCompletionStatisticsReport'&&$searchwhere!='cashbilldate'))){
                $basicfilterHtml2.='<span class="padL5 padR10" style="line-height: 27px;">'.$fieldlabel.'</span><input class="ld-input-inner gwidth60" type="text" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind" id="basicotherfind" findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
            }
            //editor:gyq_86 reason:产品批次 2018/11/16 15:21
            //单据审批状态，有未提交、审批中、已审批、已驳回4个红字状态，必居其一
            if($reportname=='InventoryAccount' || $reportname=='InventoryLedger'||$reportname=='InventoryQuery'){
                if(empty($basicfilterHtml2)) $basicfilterHtml2='';
                if($searchwhere=='wareid'){
					$new_ware = $OftenUseReport->getOftenUserReport_WareHouse();
					if(!empty($new_ware)){
						$basicfilterHtml2.='<td> <span class="changeday a">'.getFixedLabel('WAREHOUSE').':</span><select class="ld-select-inner width100" name="basicotherfind3" id="basicotherfind3">';
						foreach($new_ware['all'] as $key=>$value){
							$basicfilterHtml2.='<option value ="'.$key.'">'.$value.'</option>';
						}
						$basicfilterHtml2.='</select></td>';
					}
                    //gyqTE
                }elseif($searchwhere=='batchmanagement') {
                    $basicfilterHtml2 .= '<td><span class="changeday">' . getFixedLabel('BATCH') . ':</span><input class="ld-input-inner width120" type="text" value="' . $basicdefaultvalue . '"  name="basicotherfind4" id="basicotherfind4"/></td>';
                }elseif($searchwhere=='productname') {
                    if($reportname=='InventoryLedger'){
                        $basicdefaultvalue = '';	//$##$DefaultProductName$##$
                    }
                    $basicfilterHtml2 .= '<td><span class="changeday">' . $fieldlabel . ':</span><input class="ld-input-inner width120" type="text" value="' . $basicdefaultvalue . '" id="basicotherfind5"  name="basicotherfind5" ></td>';
                }
            }

            if($reportname=='hoursqueryreport'&&$searchwhere=='contract_no'){
                $basicfilterHtml.='<td><span>'.$fieldlabel.'</span><input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind2" id="basicotherfind2" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
            }
            if($reportname=='hoursqueryreport'&&$searchwhere=='productname'){
                $basicfilterHtml.='<td><span>'.$fieldlabel.'</span><input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind3" id="basicotherfind3" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
            }
            if($reportname=='hoursqueryreport'&&$searchwhere=='accountname'){
                $basicfilterHtml2.='<span>'.$fieldlabel.'</span><input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind4" id="basicotherfind4" findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
            }
            if($reportname == 'HighAndNewTechnologyEnterpriseSchedule' || $reportname == 'ProjectCompletionStatisticsReport'){
                if($searchwhere=='cf_1479'){
                    $SQL = "SELECT cf_1479 FROM ld_cf_1479 group by cf_1479;";
                    $fieldResult=$adb->pquery($SQL,array());
                    $rowCountz = $adb->num_rows($fieldResult);
                    for ($c = 0; $c < $rowCountz; $c++) {
                    $cf_1479list[$c] = $adb->query_result($fieldResult, $c, 'cf_1479');
                    }
                    $basicfilterHtml.='<td>'.$fieldlabel.':&nbsp;&nbsp;<select class="ld-select-inner" name="basicotherfind2" id="basicotherfind2"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
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
                    $basicfilterHtml.='<td>'.$fieldlabel.':&nbsp;&nbsp;<select class="ld-select-inner" name="basicotherfind3" id="basicotherfind3"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                    $basicfilterHtml.='<option value ="">'.getFixedLabel('ALL').'</option>';
                    foreach($cf_1478list as $arr){
                    $basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
                    }
                    $basicfilterHtml.='</select></td>';
                }

            }
            if($reportname=='Reportingpaymentschedulestatistics'){
                if($searchwhere=='cf_1751'){
                $basicfilterHtml.='<td><span>重报项目:&nbsp;</span><input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'"  name="basicotherfind2" id="basicotherfind2" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
                 }
                if($searchwhere=='projectstatus'){
                $Project_field_obj=Field::getInstance('Project',$adb);
                $arrpaymentLabelProducts=$Project_field_obj->getFieldLables();
                //Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/16 0016 上午 9:44
                $arrprojectstatus = $objpinklist->getPickListValues('projectstatus',"",array(),"");
                    $projectstatuslist = array_values($arrprojectstatus);

                $basicfilterHtml.='<td>'.$arrpaymentLabelProducts['projectstatus'].':&nbsp;&nbsp;<select class="ld-select-inner" name="basicotherfind3" id="basicotherfind3"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                $basicfilterHtml.='<option value ="">'.getFixedLabel('ALL').'</option>';
                foreach($projectstatuslist as $arr){
                $basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
                }
                $basicfilterHtml.='</select></td>';
                 }
                if($searchwhere=='cf_1784'){
                $basicfilterHtml2.='<td>未收款金额:&nbsp;&nbsp;<select class="ld-select-inner" name="basicotherfind4" id="basicotherfind4"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                $basicfilterHtml2.='<option value ="">'.getFixedLabel('ALL').'</option>';
                $basicfilterHtml2.='<option value ="2">大于0</option>';
                $basicfilterHtml2.='</select></td>'; }

                if($searchwhere=='accountname'){
                $basicfilterHtml.='<td width="400"><span>客户:&nbsp;</span><input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'"  name="basicotherfind5" id="basicotherfind5" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';

                 }
                if($searchwhere=='subject'){
                $Project_field_obj=Field::getInstance('SalesOrder',$adb);
                $arrpaymentLabelProducts=$Project_field_obj->getFieldLables();

                $basicfilterHtml2.='<td><span>'.$arrpaymentLabelProducts['subject'].':&nbsp;</span><input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'"  name="basicotherfind6" id="basicotherfind6" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';

                 }
            }
            if($reportname=='PurchaseOrderTrack')
            {
                //35052: 报表-常用报表，采购订单跟踪表这个位置能加“只显示应付款大于0"这个选项
                        $basicfilterHtml .='<td width="280"><input type="checkbox" id="basicotherfindsapp" name="basicotherfindsapp" style="margin-right:5px;margin-top: -2px;" value="" '.$checked.' />'.getFixedLabel('onlyshowpaymorethanzero').'</td>';

            }

            if($reportname=='Eachprojectcontractincomestatisticsreport'||$reportname=='Orderexpenditurestatisticsreport'||$reportname=='Allpaymentsstatisticsreport'){
                if($searchwhere=='potentialname'){
                    $basicfilterHtml.='<td><span>'.$fieldlabel.'</span><input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind5" id="basicotherfind5" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
                }
                if($searchwhere=='potential_no'){
                    $basicfilterHtml.='<td><span>'.$fieldlabel.'</span><input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind2" id="basicotherfind2" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
                }
                if($searchwhere=='accountname'){
                    $basicfilterHtml.='<td width="400"><span>'.$fieldlabel.'</span><input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind3" id="basicotherfind3" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
                }
                if($searchwhere=='subject'){
                    $basicfilterHtml2.='<span>'.getFixedLabel('ORDER').'</span><input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind4" id="basicotherfind4" findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                }

                if($searchwhere=='signed_data'){
                    $basicfilterHtml2.='<td>'.getFixedLabel('SERVICECONTRACTSTYPE').':&nbsp;&nbsp;<select class="ld-input-inner" name="basicotherfind6" id="basicotherfind6"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                    $basicfilterHtml2.='<option value ="">'.getFixedLabel('ALL').'</option>';
                    $basicfilterHtml2.='<option value ="2">'.getFixedLabel('Collectioncompleted').'</option>';
                    $basicfilterHtml2.='<option value ="3">'.getFixedLabel('Collectionnotcompleted').'</option>';
                    $basicfilterHtml2.='</select></td>';
                }

                if($searchwhere=='salesorder_no'){
                    $basicfilterHtml2.='<td>'.getFixedLabel('SERVICECONTRACTSTYPE').':&nbsp;&nbsp;<select class="ld-select-inner" name="basicotherfind6" id="basicotherfind6"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                    $basicfilterHtml2.='<option value ="">'.getFixedLabel('ALL').'</option>';
                    $basicfilterHtml2.='<option value ="2">'.getFixedLabel('Paymentcompleted').'</option>';
                    $basicfilterHtml2.='<option value ="3">'.getFixedLabel('Paymentnotcompleted').'</option>';
                    $basicfilterHtml2.='</select></td>';
                }
             }
            if($searchwhere=='cf_1428'&&$reportname=='Xuanyuanlawnbusinessmanagementreport'){
                $SQL = "SELECT cf_1428 FROM ld_cf_1428 group by cf_1428;";
                $fieldResult=$adb->pquery($SQL,array());
                $rowCountz = $adb->num_rows($fieldResult);
                for ($c = 0; $c < $rowCountz; $c++) {
                $cf_1428list[$c] = $adb->query_result($fieldResult, $c, 'cf_1428');
                }

                $account_field_obj=Field::getInstance('Accounts',$adb);
                $arrpaymentLabelProducts=$account_field_obj->getFieldLables();
                $basicfilterHtml.='<td>'.$arrpaymentLabelProducts['cf_1428'].':&nbsp;&nbsp;<select class="ld-select-inner" name="basicotherfind3" id="basicotherfind3"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                $basicfilterHtml.='<option value ="">'.getFixedLabel('ALL').'</option>';
                foreach($cf_1428list as $arr){
                $basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
                }
                $basicfilterHtml.='</select></td>';
            }
            if($searchwhere=='productname'&&$reportname=='Xuanyuanlawnbusinessmanagementreport'){
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

                $basicfilterHtml.='<td style="padding-right:10px;">'.$arrpaymentLabelProducts['productname'].':&nbsp;&nbsp;<select class="ld-select-inner" name="basicotherfind4" id="basicotherfind4"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
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
					if($reportname == 'SalesOrderTrack'||$reportname == 'SalesCommissions'){
						$basicfilterHtml .='<td width="280"><input type="checkbox" id="basicotherfindsapp" name="basicotherfindsapp" style="margin-right:5px;margin-top: -2px;" value="" '.$checked.' />'.getFixedLabel('onlyacontractwithmorethan').'</td>';
					}

                    else{
						$basicfilterHtml .='<td width="280"><input type="checkbox" id="basicotherfindsapp" name="basicotherfindsapp" style="margin-right:5px;margin-top: -2px;" value="" '.$checked.' />'.getFixedLabel('EXCOMMTOTAL').implode(getFixedLabel('AND'),$modulelabel_array).'</td>';
					}
				}

                else{
					$basicfilterHtml .= '<td width="280"><input type="hidden" id="basicotherfindsapp" name="basicotherfindsapp" value="" /></td>';
				}

            }

            if($searchwhere=='cashbilldate'&&$reportname=='Serviceperformanceappraisal'){

                $basicfilterHtml.='<td width="235"><input name="basicotherfindsapp2" id="basicotherfindsapp2" style="margin-right:5px;margin-top: -2px;" checked findcolumn=" '.$adb->query_result($result,$i,'columns').'" type="checkbox" value="" />  '.getFixedLabel('Onlythroughdatastatisticsexaminationapproval').'&nbsp;&nbsp;</td>';
            }

           if($reportname == 'Serviceperformanceappraisal' && $searchwhere == 'accountname'){
				$search_module = array('HelpDesk','ProjectTask');
				foreach($search_module as $module){
					if(vtlib_isModuleActive($module)){
						$module_label[] = getTranstab($module);
					}
				}
				 $basicfilterHtml.='<td width="280"><input name="basicotherfindsapp2" style="margin-bottom: 1px;margin-top: -2px;vertical-align: middle;" id="basicotherfindsapp2" type="checkbox" value="" />  '.getFixedLabel('EXCOMMTOTAL').implode(getFixedLabel('AND'),$module_label).'&nbsp;&nbsp;</td>';
		   }
            if($searchwhere=='servicetype'&&$reportname=='Serviceperformanceappraisal'){
                //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 下午 2:22
                $result_pick = $objpinklist->getPickListValues('servicetype',"",array(),"");
                $servicetype = array_values($result_pick);

				$account_field_obj=Field::getInstance('HelpDesk',$adb);
				$arrpaymentLabelProducts=$account_field_obj->getFieldLables();
				if(!empty($arrpaymentLabelProducts['servicetype'])){
					$basicfilterHtml.='<td>'.$arrpaymentLabelProducts['servicetype'].':&nbsp;&nbsp;<select class="ld-select-inner width100" name="basicotherfind3" id="basicotherfind3"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
					$basicfilterHtml.='<option value ="">'.getFixedLabel('ALL').'</option>';
					foreach($servicetype as $arr){
						$basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
					}
					$basicfilterHtml.='</select></td>';
				}
            }
            if($searchwhere=='projectstatus'&&$reportname=='Thestatisticalreportofprojectperformance'){
                //Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/16 0016 上午 9:44
                $arrprojectstatus = $objpinklist->getPickListValues('projectstatus',"",array(),'');
                $servicetype = array_values($arrprojectstatus);


                $account_field_obj=Field::getInstance('Project',$adb);
                $arrpaymentLabelProducts=$account_field_obj->getFieldLables();
				if(!empty($arrpaymentLabelProducts['projectstatus'])){
					$basicfilterHtml.='<td>'.$arrpaymentLabelProducts['projectstatus'].':&nbsp;&nbsp;<select class="ld-select-inner" name="basicotherfind3" id="basicotherfind3"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
					$basicfilterHtml.='<option value ="">'.getFixedLabel('ALL').'</option>';
					foreach($servicetype as $arr){
						$basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
					}
					$basicfilterHtml.='</select></td>';
				}
            }
            if($searchwhere=='accountname'&&$reportname=='Thestatisticalreportofprojectperformance'){
                $basicfilterHtml2.=$fieldlabel.'<input class="ld-input-inner width120" type="text" value="'.$basicdefaultvalue.'" onkeyup="OftenUseReportSearchSubmit(event,\'this\',\'BasicSearch\')" name="basicotherfind" id="basicotherfind" findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
            }
            if($searchwhere=='progress'&&$reportname=='Thestatisticalreportofprojectperformance'){
                //Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/16 0016 上午 9:44
                $arrprogress = $objpinklist->getPickListValues('progress',"",array(),"");
                $servicetype = array_values($arrprogress);


                $account_field_obj=Field::getInstance('Project',$adb);
                $arrpaymentLabelProducts=$account_field_obj->getFieldLables();
				if(!empty($arrpaymentLabelProducts['progress'])){
					$basicfilterHtml.='<td style="padding-right:10px;">'.$arrpaymentLabelProducts['progress'].'<select class="ld-select-inner" name="basicotherfind4" id="basicotherfind4"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
					$basicfilterHtml.='<option value ="">'.getFixedLabel('ALL').'</option>';
					foreach($servicetype as $arr){
						$basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
					}
					$basicfilterHtml.='</select></td>';
				}
            }
            if($searchwhere=='accountname'&&$reportname=='Serviceperformanceappraisal'&&(vtlib_isModuleActive('HelpDesk')||vtlib_isModuleActive('ProjectTask'))){
				$Serviceperformanceappraisal_array[] = $searchwhere;

            }
            if($searchwhere=='contract_no'&&$reportname=='SalesOrderTrack'&&(vtlib_isModuleActive('SalesOrder')||vtlib_isModuleActive('ServiceContracts'))){
                $basicfilterHtml.='<td>'.getFixedLabel('BillType').'<select class="ld-select-inner" onchange="changeCheckLabel()" name="basicotherfindsbill" id="basicotherfindsbill"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
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


        }
    }
}
//zxm 2022-0328 合同跟踪表 SalesOrderTrack 收款业绩统计表 Performancestatisticscollection 合同类型下拉框
if($reportname == 'SalesOrderTrack'||$reportname == 'Performancestatisticscollection'){
    include_once globalStatic::$root_directory.'modules/PickList/PickListUtils.php';
    if(vtlib_isModuleActive('SalesOrder')) {
        $salesorder_contracttype_list = getAllPickListValues('salescontracttype');
        $salesorder_contracttype_select = '<select class="js-example-basic-multiple" style="font-size:12px;width:calc(100% - 160px);" name="salesorder_contracttype_select[]" id="salesorder_contracttype_select" multiple>';
        foreach ($salesorder_contracttype_list as $sales_v) {
            $salesorder_contracttype_select .= '<option  value="' . $sales_v . '">' . $sales_v . '</option>';
        }
        $basicfilterHtml .= '<tr><td colspan="2">' . getTranstab('SalesOrder') . '_' . gettranslabelfields('SalesOrder', 'contracttype') . ':&nbsp;&nbsp;' . $salesorder_contracttype_select . '</td>';
    }
    if(vtlib_isModuleActive('ServiceContracts')) {
        $servicecontract_contracttype_list = getAllPickListValues('contract_type');
        $servicecontract_contracttype_select = '<select class="js-example-basic-multiple" style="font-size:12px;width:calc(100% - 160px);" name="servicecontract_contracttype_select[]" id="servicecontract_contracttype_select" multiple>';
        foreach ($servicecontract_contracttype_list as $service_v) {
            $servicecontract_contracttype_select .= '<option  value="' . $service_v . '">' . $service_v . '</option>';
        }
        $basicfilterHtml .= '<td colspan="2">' . getTranstab('ServiceContracts') . '_'. gettranslabelfields('ServiceContracts', 'contract_type') . ':&nbsp;&nbsp;' . $servicecontract_contracttype_select . '</td>';
    }
        $basicfilterHtml .= '<script>
ld(document).ready(function() {
        ld(".js-example-basic-multiple").select2();
    });
</script>';
}
if($reportname == 'VideoRentalIncomeStatement'){
    //getFixedLabel('Onlythroughdatastatisticsexaminationapproval1')
    $basicfilterHtml .='<td width="280"><input type="checkbox" id="receivable_balance_morethan" name="receivable_balance_morethan" style="margin-right:5px;margin-top: -2px;" value="" '.$checked.' />'.getFixedLabel('onlyacontractwithmorethan').'</td>';
    $basicfilterHtml .='<td width="280"><input type="checkbox" id="VideoRentalOnlyApproved" name="VideoRentalOnlyApproved" style="margin-right:5px;margin-top: -2px;" value="" '.$checked.' />'.getFixedLabel('Onlythroughdatastatisticsexaminationapproval1').getTranstab('SalesOrder').'</td>';
}

//20210220产品销售排行榜
if($reportname=='ProductRanking'||$reportname=='ProductRanking_wdj'){
    //排行维度
    $SalesCommissionObj = new SalesCommission();
    $commissionType = $SalesCommissionObj->getProductRankingDimension('',"product_ranking_type","product_ranking_type","html");
    $basicfilterHtml.= '<td width="280">'.$commissionType.'</td>';
    if(vtlib_isModuleActive('ServiceContracts')&&vtlib_isModuleActive('SalesOrder')){
        $label = "onlyshowapprovecontactandservice";
    }elseif(!vtlib_isModuleActive('ServiceContracts')&&vtlib_isModuleActive('SalesOrder')){
        $label = "onlyshowapproveorder";
    }else if(vtlib_isModuleActive('ServiceContracts')&&!vtlib_isModuleActive('SalesOrder')){
        $label = "onlyshowapproveservicecontract";
    }else{
        $label = '';
    }
    $ProductRankingLabel = [
        'qianyue'=>getFixedLabel($label),
        'order'=>getFixedLabel('onlyshowapproveorder'),
        'invoice'=>getFixedLabel('Onlythroughdatastatisticsexaminationapproval1').getTranstab('Invoice'),
        'outbound'=>getFixedLabel('Onlythroughdatastatisticsexaminationapproval1').getTranstab('OutboundOrder'),
    ];
    $smarty->assign("ProductRankingLabel",json_encode($ProductRankingLabel));
    // 只统计审批通过的合同订单
    $basicfilterHtml .='<tr><td width="280"><input type="checkbox" id="onlyshowapprovecontactandservice" name="onlyshowapprovecontactandservice" style="margin-right:5px;margin-top: -2px;" value="" '.$checked.' /><span>'.getFixedLabel($label).'</span></td>';

    //产品名称
    $basicfilterHtml .= '<td><span style="vertical-align: middle;">'.getFixedLabel('PRODUCTNAME').':&nbsp;</span><input class="detailedViewTextBox" type="text" style="width:150px;" value="" name="product_name" id="product_name"></td>';
}
//zxm 2021-12-13 服务看板
if($reportname=='ServiceKanban'){
    $servicetypeSql = "select b.listvalue,ld_field.fieldid,ld_field.fieldlabel from ld_picklist_set a left join ld_field on a.listname=ld_field.columnname left join ld_picklist_values b on a.listid=b.listid where a.listname=? and a.relatetable=?";
    $servicetypeRes = $adb->pquery($servicetypeSql,array('servicetype','ld_field'));
    $servicetypeNums = $adb->num_rows($servicetypeRes);
    $fieldlabel_temp = $adb->query_result($servicetypeRes,0,'fieldlabel');
    $basicfilterHtml.='<td width="400">'.$fieldlabel_temp.':&nbsp;&nbsp;<select class="ld-select-inner gwidth60" name="basicotherfindsservicetype" id="basicotherfindsservicetype">';
    if($servicetypeNums>0){
        $basicfilterHtml.='<option value ="0">请选择</option>';
        for($s=0;$s<$servicetypeNums;$s++){
            $listvalue_temp = $adb->query_result($servicetypeRes,$s,'listvalue');
            $basicfilterHtml.='<option value ="'.$listvalue_temp.'">'.$listvalue_temp.'</option>';
        }
    }
    $basicfilterHtml.='</select></td>';
    //审批状态
    $basicfilterHtml.='<tr><td colspan="2"><div style="padding-left:5px;">审批状态:&nbsp;&nbsp;
			<input type="checkbox" name="approve_header_select_value[]" value="未提交" checked="">未提交&nbsp;
			<input type="checkbox" name="approve_header_select_value[]" value="审批中" checked="">审批中&nbsp;
			<input type="checkbox" name="approve_header_select_value[]" value="已审批" checked="">已审批 &nbsp;
			<input type="checkbox" name="approve_header_select_value[]" value="已拒绝" checked="">已拒绝&nbsp;
			<input type="checkbox" name="approve_header_select_value[]" value="已驳回" checked="">已驳回&nbsp;
		</div></td></tr>';

}
/*zxm 2020-0929 销售提成报表 */
if($reportname=='SalesCommissionsByOrder'||$reportname=='SalesCommissionsByCash')
{
    if(vtlib_isModuleActive('ServiceContracts')&&vtlib_isModuleActive('SalesOrder')){
        $label = "onlyshowapprovecontactandservice";
    }elseif(!vtlib_isModuleActive('ServiceContracts')&&vtlib_isModuleActive('SalesOrder')){
        $label = "onlyshowapproveorder";
    }else if(vtlib_isModuleActive('ServiceContracts')&&!vtlib_isModuleActive('SalesOrder')){
        $label = "onlyshowapproveservicecontract";
    }else{
        $label = '';
    }
    // 只统计审批通过的合同订单---SalesCommissionsByOrder才有这个条件
    $basicfilterHtml .='<tr>';
    if($reportname=='SalesCommissionsByOrder'){
        $basicfilterHtml .='<td width="33%"><input type="checkbox" id="onlyshowapprovecontactandservice" name="onlyshowapprovecontactandservice" style="margin-right:5px;margin-top: -2px;" value="" '.$checked.' />'.getFixedLabel($label).'</td>';
    }
    // 只统计审批通过的佣金单
    $basicfilterHtml .='<td width="33%"><input type="checkbox" id="onlyshowapprovefeeandcommissions" name="onlyshowapprovefeeandcommissions" style="margin-right:5px;margin-top: -2px;" value="" '.$checked.' />'.getFixedLabel('onlyshowapprovefeeandcommissions').'</td><td width="33%"></td></tr>';

    $SalesCommissionObj = new SalesCommission();
    $moduleName = $reportname== "SalesCommissionsByOrder"?"合同":"收款";

    $commissionType = $SalesCommissionObj->getCommissionType($moduleName,"commission_type","commission_type","html");
    $smarty->assign("commissionType",$commissionType);

    $basicfilterHtml.= '<tr><td width="33%">'.$SalesCommissionObj->getCostAccounting("cost_accounting","cost_accounting","html").'</td>';
    //zxm 2021-0716 东方报警  销售提成报表 按合同  订单分类的下拉框
    if($version_account=="east_alarm"){
        $basicfilterHtml.= '<td width="33%">'.$SalesCommissionObj->getAccountType("OrderClassification","OrderClassification","html").'</td>';
    }
    $basicfilterHtml.= '<td width="33%">'.$SalesCommissionObj->getAchievementType($moduleName,"achievement_type","achievement_type","html").'</td></tr>';
    include("SalesCommissionAction.php");
    if($reportname=='SalesCommissionsByOrder'){
        $byType="byOrder";
    }else{
        $byType="byCash";
    }

    $smarty->assign("byType",$byType);
}
/*zxm 2020-1124 服务收费将建 */
if($reportname=='ServiceChargeBonusByOrder'||$reportname=='ServiceChargeBonusByCash') {
    $smarty->assign("byType",$reportname);
    if($reportname == "ServiceChargeBonusByOrder"){
        // 只统计审批通过的服务合同
        $basicfilterHtml .= '<tr><td width="280"><input type="checkbox" id="onlyshowapproveservicecontract" name="onlyshowapproveservicecontract" style="margin-right:5px;margin-top: -2px;" value="" ' . $checked . ' />'.getFixedLabel('onlyshowapproveservicecontract').'</td>';
    }
    if($reportname == "ServiceChargeBonusByCash") {
        // 只统计审批通过的收款单
        $basicfilterHtml .= '<tr><td width="280"><input type="checkbox" id="onlyshowapprovecashbill" name="onlyshowapprovecashbill" style="margin-right:5px;margin-top: -2px;" value="" ' . $checked . ' />'.getFixedLabel('onlyshowapprovecashbill').'</td>';
    }
    // 只统计审批通过的客户服务单
    $basicfilterHtml .= '<td width="280"><input type="checkbox" id="onlyshowapproveservicebill" name="onlyshowapproveservicebill" style="margin-right:5px;margin-top: -2px;" value="" ' . $checked . ' />'.getFixedLabel('onlyshowapproveservicebill').'</td></tr>';
}

$basicfilterHtml5 = '';
foreach($Serviceperformanceappraisal_array as $searchwhere){
	if($searchwhere=='servicetype'){
		
	}else if($searchwhere=='accountname'){
			$basicfilterHtml5.='<td width="400">'.getFixedLabel('BillType').':&nbsp;&nbsp;<select class="ld-select-inner" name="basicotherfindsbill" id="basicotherfindsbill"  findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
			if(vtlib_isModuleActive('HelpDesk')&&vtlib_isModuleActive('ProjectTask')){
				$basicfilterHtml5.='<option value ="0">'.getFixedLabel('ALL').'</option>';
			}
			if(vtlib_isModuleActive('HelpDesk')){
                //zxm  20210903默认客户服务单 bug-0047826
				$basicfilterHtml5.='<option value ="1" selected>'.getTranstab('HelpDesk').'</option>';
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
if(!isset($_REQUEST['searchtype'])&&$reportname!='CommencementSchedule'&&$reportname!='OverallCommencementSchedule'
        &&$reportname!='PartnerCommencementSchedule'&&$reportname!='LecturerCommencementSchedule'
        &&$reportname!='Studentsparticipatinginthetrainingschedule'&&$reportname!='Customersparticipatinginthetrainingschedule'
        &&$reportname!='Contactbusinesstable'&&$reportname!='KPCCommencementDetails'&&$reportname!='CourseparticipantsKPClist'
        &&$reportname!='Sign_in_track'&&$reportname!='SignDistribution')
{
    $_REQUEST['searchtype']='BasicSearch';
    $_REQUEST['startmonth']=$startdatemonth.' 00:00:00';
    $_REQUEST['endmonth']=$enddatemonth.' 23:59:59';
    $_REQUEST['datefindcolumn']=$datefindcolumn;
    $smarty->assign('SEARCHTYPE','BasicSearch');
}elseif(!isset($_REQUEST['searchtype'])&&($reportname=='CommencementSchedule'||$reportname=='OverallCommencementSchedule'||$reportname=='PartnerCommencementSchedule'||$reportname=='LecturerCommencementSchedule'
        ||$reportname=='Studentsparticipatinginthetrainingschedule'||$reportname=='Customersparticipatinginthetrainingschedule'
        ||$reportname=='Contactbusinesstable'||$reportname=='KPCCommencementDetails'||$reportname=='CourseparticipantsKPClist'||$reportname=='Salesforecastandanalysistable')){
    //echo $startdatemonth;
    $_REQUEST['searchtype']='BasicSearch';
    $_REQUEST['startmonth']=$startdatemonth.' 00:00:00';
    $_REQUEST['endmonth']='1200-03-01  23:59:59';
    $_REQUEST['datefindcolumn']=$datefindcolumn;
    $smarty->assign('SEARCHTYPE','BasicSearch');
}
elseif(!isset($_REQUEST['searchtype'])&&($reportname=='Sign_in_track'||$reportname=='SignDistribution')){
    //签到轨迹表默认选中本周
    $week_begin = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - date("w") + 1, date("Y")));
    $week_end = date("Y-m-d", mktime(23, 59, 59, date("m"), date("d") - date("w") + 7, date("Y")));
    $_REQUEST['startmonth']=$week_begin.' 00:00:00';
    $_REQUEST['endmonth']=$week_end.' 23:59:59';   
}
else
{
    $_REQUEST['datefindcolumn']=$datefindcolumn;
    $smarty->assign('SEARCHTYPE',$_REQUEST['searchtype']);
    
}

$smarty->assign('BASICFILTERHTML5',$basicfilterHtml5);
$smarty->assign("BASICFILTERHTML",$basicfilterHtml);
//editor:gyq_86 reason:库存报表 2018/11/26 18:15 gyqTE
if(isset($OftenUseReport->report_parent_type) && $OftenUseReport->report_parent_type=='kucun'){
    $basicfilterHtml2.='<td> <span class="changeday">'.getFixedLabel('approvestatus').':</span><select class="borderALL btn-radius-system width100 height25" name="basicotherfind6" id="basicotherfind6">';
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
    if($reportname=='InventoryQuery'){
        $basicfilterHtml2.='<td><input name="show_zero_quantity" type="checkbox" class="btn-radius-system marL6 lfloat"><span class="changeday">'.getFixedLabel('OFTENUSEREPORTTITLE1').'</span></td>';
    }
}
if($reportname=='Salesforecastandanalysistable') {
    $basicfilterHtml2 .= $renderHtmlObj->getSalesStageSearch();
}
$smarty->assign("BASICFILTERHTML2",$basicfilterHtml2);

$smarty->assign("APP",$app_strings);

$sorder='';
$ordertype='';
if(isset($_REQUEST['sorder']))
{
    $sorder=$_REQUEST['sorder'];
    $ordertype=$_REQUEST['ordertype'];
}

//库存流水账 editor:gyq_86 reason:产品批次 2018/11/14 10:36
if($reportname=='InventoryAccount' ){
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
}elseif ($reportname=='InventoryLedger'){
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
if($reportname == 'AccountsReceivableSummary'){
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
if($reportname == 'Salesranking'){
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
if('SalesOrderTrack' == $reportname || 'Salesforecastandanalysistable' == $reportname || 'CashBillSum_SalesOrder' ==$reportname || 'CashBillSum_Outboundorder' ==$reportname || 'PurchaseOrderTrack' == $reportname || 'SendCashBillSum_PurchaseOrder' == $reportname){
	$salesranking_value = $reportname;
}
$smarty->assign('CHECKLABEL',getSalesRankingType($salesranking_value));
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
}else if($reportname == 'Sign_in_track' ||$reportname == 'SignDistribution' ){
    $signin_info = $OftenUseReport->getReportListView();
    $smarty->assign('REPORTFILTERHTML',$signin_info);
}else{
    $smarty->assign('REPORTFILTERHTML',$OftenUseReport->getReportListView());
}
if($reportname=='InventoryLedger'&&$_REQUEST['ajax']!=true){
    $basicfilterHtml2 = str_replace('$##$DefaultProductName$##$',$_REQUEST['InventoryLedger_Productids']['current_name'],$basicfilterHtml2);
    $smarty->assign("BASICFILTERHTML2",$basicfilterHtml2);
}
if($reportname == 'Sign_in_track'&&!empty($_REQUEST['SmOwnerSearchScope'])){
    $smarty->assign("SmOwnerSearchScope",$_REQUEST['SmOwnerSearchScope']);
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
    //zxm 20231116 报表---常用报表---即时库存查询，点“高级查询”输入关键字，点查询没反应  
    //require_once 'include/Zend/Json.php';
    //$json = new Zend_Json();
    
    $advft_criteria = $_REQUEST['advft_criteria'];
    if(!empty($advft_criteria)) $advft_criteria = Zend_Json::decode($advft_criteria);
    $advft_criteria_groups = $_REQUEST['advft_criteria_groups'];
    if(!empty($advft_criteria_groups)) $advft_criteria_groups = Zend_Json::decode($advft_criteria_groups);
	crm_load_class_file('cls_QueryGenerator','modules/OftenUseReport');
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
		if($reportname == 'Salesranking'){
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
                $csc = explode("</tr>",$OftenUseReport->getReportListView());
                include('PHPExcel/PHPExcel.php');
                $objPHPExcel = new PHPExcel();
                $objPHPExcel->setActiveSheetIndex(0);
                $activesheet=$objPHPExcel->getActiveSheet();
                
                foreach($exportheader as $key=>$arr){
                    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',$arr);
                }
                
                $j = 2;
                foreach($csc as $arr){
                	$cscs = explode("</td>",$arr);
                    
                    $for_i = 0;
                    //37601: （1.6）常用报表> 应收款统计表_按合同统计表>导出Excel：导出的模板中【应收款余额】的数据没有被导出来。（需要补丁）
                    /*if($reporttype==10){
                	   array_pop($cscs);
                       if($reportname!='SalesOrderTrack')//28869: 常用报表>合同跟踪表:导出excel，导出的文件中【状态】列值为空
                       array_pop($cscs);
                	}*/
                	
                	foreach($cscs as $value){
                		$value = strip_tags(trim($value));
						$value = ltrim($value,'&nbsp;');
                		if($value == '&nbsp;'){
                			$value = '';
                		}
                        $value=str_replace('&yen;','¥',strip_tags($value));
                		$value = decode_html($value);
                		$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($for_i).$j,$value);
                		++ $for_i;
                	}
                	++ $j;
                }
                
                $modulelabel = getTranstab('OftenUseReport');
                $modulelabel = str_replace(' ','_',iconv('UTF-8','gbk',$modulelabel));
                $file_name = 'OftenUseReport.xls';
                $file_dir = './storage/';
                
                $objPHPExcel->getActiveSheet()->setTitle('OftenUseReport');
                $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
                $objWriter->save($file_dir.$file_name);
                
                header('Location: index.php?module=ReportAnalysis&action=ExportReport&ReportHeader=dheader&modulelabel='.$reportname.'');
                exit();
}}
$smarty->assign("isADMIN",is_admin($current_user));
$smarty->assign("CRITERIA_GROUPS",$advft_criteria);
$smarty->assign("THEME", $theme);
$rname = getFixedLabel($reportname);
$smarty->assign("REPORTNAMES", $rname);
$smarty->assign("MODULE", $currentModule);
$smarty->assign("IMAGE_PATH", $image_path);

//editor:gyq_86 reason:库存台账前进后退功能 2018/11/23 10:12
if( $reportname=='InventoryLedger'){
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

if($reportname=='TimeSheet personal monthly summary'){
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
if($reportname=='SIGNINSTATISTICS' || $reportname=='Sign_in_track'|| $reportname=='SignDistribution'){
	$sendlog_date = $_REQUEST['sendlog_date']??'';
	if($_REQUEST['worktype'] == 'worktype_1'){
		$start_date = $sendlog_date;
		$end_date = $sendlog_date;
	}else{
		$sendlog_dates = !empty($sendlog_date)?explode('~',$sendlog_date):[];
        if(empty($sendlog_dates)){
            $start_date = '';
            $end_date = '';
        }else{
            $start_date = trim($sendlog_dates[0]);
            $end_date = trim($sendlog_dates[1]);
        }
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
    require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');
    $smarty->assign('OPTIONMODULE',cls_StaticCommonFun::getOptionModule('Singin'));
}
$smarty->assign('WORKTYPE',$_REQUEST['worktype']);
//echo $reportfilterhtml;echo '<br><br>';
if(empty($reportname)){//所有报表都没有显示的情况下
    echo getFixedLabel('NOREPORTEAVAIL');
    exit();
}
if($_REQUEST['ajax']&&$_REQUEST['ajax']=='true')
{
    if($reportname=='TimeSheet personal monthly summary'){
        echo '###SUCCESS###';
        echo $reportfilterhtml;
        exit();
    }else if($reportname=='Sign_in_track'||$reportname=='SignDistribution'){
        echo '###SUCCESS###';
        echo $signin_info;
        exit();
    }else{
        if($_REQUEST['Print']!='true'){
            echo '###SUCCESS###';
			if($reportname=='USERTRACKREPORT'){
				ob_clean();
				echo json_encode($points);
			}else{
				if($_REQUEST['usereport_search'] == 'yes' && $reportname == 'InventoryLedger'){
					$smarty->display("modules/OftenUseReport/UseReportEntries.tpl");
				}else{
                    $smarty->display("modules/OftenUseReport/UseReportListContent.tpl");
				}
			}
				
		}else{
			$smarty->display("modules/OftenUseReport/NewUseReportList.tpl");
		}
		exit();
    }

}
else if($_REQUEST['leftmenuclick']=='yes')
{
    echo '###SUCCESS###';
    $smarty->display("modules/OftenUseReport/LeftClickContent.tpl");
    exit();
}
else if($_REQUEST['frommodule']=='ReportAnalysis'||$currentModule=='ReportAnalysis'){
    //报表分析模块来的请求
    $smarty->assign('frommodule','ReportAnalysis');//如果是报表分析来的请求 把中间的报表菜单隐藏

    $listtype = $_REQUEST['listtype'];
    $listtype = empty($listtype)?'list':$listtype;
    $smarty->assign('listtype',$listtype);//如果是报表分析来的请求 把中间的报表菜单隐藏
    if($listtype=='screen'){
        $content = $smarty->fetch("ReportAnalysis/NewUseReportList.tpl");
        ConvertTojsonString(1,['content'=>$content],'success');
    }else{
        $smarty->display("ReportAnalysis/NewUseReportList.tpl");
    }

}else
{
    $smarty->display("modules/OftenUseReport/NewUseReportList.tpl");

}
// zxm 20201009 常用报表增加提成统计报表（按合同和按金额）
class SalesCommission{

    /***
     * @param string $type
     * @param $type_key
     * @param $name
     * @param $id
     * @return string|string[]
     * 成本计算方法 选项返回
     */
    public function getCostAccounting($name,$id,$type="html",$type_key="")
    {
        $title = getFixedLabel("costCounting");//"成本计算方法"
        $list = [
            "1"=>getFixedLabel("chooseCost"),//"取成本价或参考成本价",
            "2"=>getFixedLabel("choosePurchaseCost"),//"取订单产品的采购成本",
            "3"=>getFixedLabel("chooseAvgCost"),//"取产品的采购平均均价",
            "4"=>getFixedLabel("chooseOutBoundCost"),//"取订单产品的出库价格"
        ];
        if($type=="html"){
            return $this->getSelectHtml($list,$title,$name,$id);
        }else if($type=="array"){
            return $list;
        }else if($type=="string"){
            return (!empty($type_key)&&isset($list[$type_key]))?$list[$type_key]:"未知成本计算方式";
        }
    }

    //zxm 2021-0716 东方报警  销售提成报表 按合同  订单分类的下拉框
    public function getAccountType($name,$id,$type="html",$type_key="")
    {
        $title = getFixedLabel("OrderClassification");//"订单分类"
        $list = [
            "1" => getFixedLabel("ALL"),//"全部",
            "2"=>getFixedLabel("DirectOrder"),//"直销订单",
            "3"=>getFixedLabel("DealerOrder")//"经销商订单",
        ];
        if($type=="html"){
            return $this->getSelectHtml($list,$title,$name,$id);
        }else if($type=="array"){
            return $list;
        }else if($type=="string"){
            return (!empty($type_key)&&isset($list[$type_key]))?$list[$type_key]:getFixedLabel("ALL");
        }
    }
    /**
     * @param $moduleName
     * @param string $type
     * @param $type_key
     * @param $name
     * @param $id
     * @return string|string[]
     * 业绩计算方法  收款|合同
     */
    public function getAchievementType($moduleName,$name,$id,$type="html",$type_key="")
    {
        $title = getFixedLabel("awardCounting");//"业绩计算方法";
        $list = [
            "1"=>$moduleName.getFixedLabel("AMOUNT"),
            "2"=>getFixedLabel("deductionFyAndYj"),//扣除费用和佣金
            "3"=>getFixedLabel("deductionFyAndCost")//扣除费用佣金和产品成本
        ];
        if($type=="html"){
            return $this->getSelectHtml($list,$title,$name,$id);
        }else if($type=="array"){
            return $list;
        }else if($type=="string"){
            return (!empty($type_key)&&isset($list[$type_key]))?$list[$type_key]:"未知业绩计算方式";
        }
    }

    /**
     * @param $moduleName
     * @param $name
     * @param $id
     * @param string $type
     * @param string $type_key
     * @return string|string[]
     * 提成计算方式
     */
    public function getCommissionType($moduleName,$name,$id,$type="html",$type_key="")
    {
        $title = "提成计算方法";
        $list = [
            "amount"=>$moduleName.getFixedLabel("AMOUNT"),
            "target_rate"=>$moduleName."目标完成率"
        ];
        if($type=="html"){
            return $this->getSelectHtml($list,$title,$name,$id);
        }else if($type=="array"){
            return $list;
        }else if($type=="string"){
            return (!empty($type_key)&&isset($list[$type_key]))?$list[$type_key]:"未知提成计算方式";
        }
    }

    /**
     * @param $moduleName
     * @param $name
     * @param $id
     * @param string $type
     * @param string $type_key
     * @return string|string[]
     * 产品排行榜 排行维度数组
     */
    public function getProductRankingDimension($moduleName,$name,$id,$type="html",$type_key="")
    {
        $title = "排行维度";
        $list = [];
        if(vtlib_isModuleActive('ServiceContracts')&&vtlib_isModuleActive('SalesOrder')){
            $list['productSignCount'] = getFixedLabel('CONTRACTQUANTITY');
            $list['productSignAmount'] = getFixedLabel('SignContractAmount');
        }
        if(vtlib_isModuleActive('SalesOrder')){
            $list['productOrderCount'] = getFixedLabel('dingdan').getFixedLabel('QTY');
            $list['productOrderAmount'] = getFixedLabel('dingdan').getFixedLabel('AMOUNT');
        }
        if(vtlib_isModuleActive('Invoice')){
            $list['productInvoiceAmount'] = getFixedLabel('kaipiao').getFixedLabel('AMOUNT');
        }
        if(vtlib_isModuleActive('OutboundOrder')){
            $list['productOutboundCount'] = getFixedLabel('chuku').getFixedLabel('QTY');
            $list['productOutboundAmount'] = getFixedLabel('chuku').getFixedLabel('AMOUNT');
        }

        if($type=="html"){
            return $this->getSelectHtml($list,$title,$name,$id);
        }else if($type=="array"){
            return $list;
        }else if($type=="string"){
            return (!empty($type_key)&&isset($list[$type_key]))?$list[$type_key]:"未知提成计算方式";
        }
    }
    /**
     * @param $list
     * @param $title
     * @param $name
     * @param $id
     * @return string
     * 数组组装select
     */
    public function getSelectHtml($list,$title,$name,$id)
    {
        $html = '<label class="fontnormal">'.$title.':&nbsp;&nbsp;</label><select class="ld-select-inner" onchange="'.$id.'_change(this)" name="'.$name.'" id="'.$id.'">';
        $selected = 'selected';
        foreach($list as $k=>$v){
            $html .= '<option '.$selected.' value="'.$k.'">'.$v.'</option>';
            $selected = '';
        }
        $html .= '</select>';
        return $html;
    }
 }