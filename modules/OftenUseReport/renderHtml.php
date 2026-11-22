<?php

//页面html生成
class renderHtml
{
    public $quantity_decimal;
    public $amount_decimal;
    public $adb;
    public $usereportid;
    public $reportname;
    public $languageType;
    public $tradeInfo;
    public $OftenUseReport;
    public $AllReportHeaders;
    public $showcolLists;
    public $fieldnames;
    public $currentModule;
    public $current_user;
    public function __construct()
    {
        //小数位数
        $deploy = getSys_deploy(49);
        $this->quantity_decimal = $deploy['deploy_value'];
        $deploy = getSys_deploy(93);
        $this->amount_decimal = $deploy['deploy_value'];
        //$adb;
        global $adb,$currentModule,$current_user,$current_language;
        $this->adb = $adb;
        $this->reportname = $this->getReportName();//报表名称
        $this->languageType = $current_language;
        $this->currentModule = $currentModule;
        $this->current_user = $current_user;
        $this->tradeInfo = getVersionTradeInfo();
        if($this->reportname=='InventoryAccount' || $this->reportname=='InventoryLedger'||$this->reportname=='InventoryQuery'){
            crm_load_class_file('ReportModel','modules/OftenUseReport');
            $this->OftenUseReport = new ReportModel();
            //editor:gyq_135 reason:report_parent_type赋值  2019/8/9 14:38 ID1000568
            $this->OftenUseReport->report_parent_type = 'kucun';
        }else{
            $this->OftenUseReport = new OftenUseReport();
        }
    }
    public function setReportId($usereportid){
        $this->usereportid = $usereportid;//报表ID
    }

    /**
     * @return mixed
     * @throws Exception
     * 获取报表基本信息
     */
    public function getReportInfo(){
        global $adb;
        $usereportid = $this->usereportid;
        $sql = 'select reporttype,tabids,parent_id,basicfilter,advfilter,setcolumns,name ,pagewidthpercent
 from ld_usereport where usereportid=?';
        $result = $this->adb->pquery($sql,array($usereportid));
        $report['reporttype'] = $adb->query_result($result,0,'reporttype');
        $report['reportabid']=$adb->query_result($result,0,'tabids');
        $report['reportname']=$adb->query_result($result,0,'name');
        $report['parentid']=$adb->query_result($result,0,'parent_id');
        $report['basicfilter']=$adb->query_result($result,0,'basicfilter');
        $report['advfilter']=$adb->query_result($result,0,'advfilter');
        $report['setcolumns']=$adb->query_result($result,0,'setcolumns');
        $report['pagewidthpercent']=$adb->query_result($result,0,'pagewidthpercent');
        return $report;
    }
    //获取报表名称
    public function getReportName (){
        $sql = "select name from ld_usereport where usereportid=? ";
        $result = $this->adb->pquery($sql,array($this->usereportid));
        $nums_result = $this->adb->num_rows($result);
        $reportname = '';
        if($nums_result > 0){
            $reportname = $this->adb->query_result($result,0,0);
        }
        return $reportname;
    }

    //获取人员范围
    public function getMergeSmowner(){
        $reportnames = $this->reportname;
        $currentModule = $this->currentModule;
        $current_user = $this->current_user;
        $MergeSmowner = getCurSmOwnerSearchScope($currentModule);
        //人员范围
        if($reportnames != 'TimeSheet personal monthly summary' && $reportnames != 'Sign_in_track'){
            unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
        }
        //unset($MergeSmowner["OtherInfo"]['SmOwner_Search_All']);
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
        //签到轨迹表只显示单个用户
        if($reportnames == 'Sign_in_track'){
            unset($MergeSmowner["OtherInfo"]);
        }
        //zxm 2022-1111 常用报表改成报表分析的数据范围
        $scopeobj = new ScopOfAuthority($this->adb,$currentModule);
        //灵当CRM详细需求-PC端-常用报表查看范围增加按部门选项
        if($scopeobj->getUserModuleScoperType() > 0 || $current_user->is_admin == 'on'){
            $fieldlabel_group = getFixedLabel('SETBYDEPARTMENT');
            $MergeSmowner["OtherInfo"]['SmOwner_Search_Group'][$fieldlabel_group] = '';
        }
        return $MergeSmowner;
    }
    //报表父节点条件
    public function getReportListParentWhere (){
        $trade = $this->tradeInfo['trade'];
        if($trade=='training'){
            $parentwhere = "";
        }else {
            $parentwhere = " and name not in ('CourseEnquiryReport')";
        }

        if($trade!='jierun'){
            $parentwhere .= " and name not in ('JIERUNREPORTS') ";
        }
        if($trade!='xycp'){
            $parentwhere .= " and name not in ('XuanYuanLawn')";
        }
        if($trade!='zhongyuan'){
            $parentwhere .= " and name not in ('ZHONGYUANREPORTS')";
        }
        return $parentwhere;
    }
    //报表child条件where
    public function getReportListWhere (){
        //SalesOrderImplementation:德卡报表：合同执行情况明细表
        //CourseEnquiryReport:培训行业报表
        global $currentModule,$current_user;
        $trade = $this->tradeInfo['trade'];
        if($trade=='德卡'){
            $where = "";
        }else {
            $where = " and name not in ('SalesOrderImplementation') ";
        }
        if(!vtlib_isModuleActive('ServiceContracts')&&!vtlib_isModuleActive('SalesOrder')){
            $where .= " and name not in ('SalesOrderTrack','Contractnumber','Contractamount') ";
        }
        if($trade!='lueyang'){
            $where .= " and name not in ('Reportingpaymentschedulestatistics') ";
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
        //zxm 2020-1209 合同与服务合同模块未开则不显示收费奖金报表_按合同 提成报表_按合同
        if(!vtlib_isModuleActive('SalesOrder')&&!vtlib_isModuleActive('ServiceContracts')){
            $where .= " and name not in ('SalesCommissionsByOrder','ServiceChargeBonusByOrder') ";
        }
        //zxm 2020-1209 合同与服务合同模块未开则不显示收费奖金报表_按收款 提成报表_按收款
        if(!vtlib_isModuleActive('CashBill')){
            $where .= " and name not in ('ServiceChargeBonusByCash','SalesCommissionsByCash') ";
        }
        //条件 --
        /**
         * @reason 0012334 常用报表>>服务绩效统计表：希望【客户服务单】、【项目任务】模块都没有开启的情况下，该报表不显示
         * @author Tujt 2014-11-10
         */
        if(1 != vtlib_isModuleActive('HelpDesk') && 1 != vtlib_isModuleActive('ProjectTask')){
            $where .= " and name not in ('Serviceperformanceappraisal') ";//服务绩效统计表
        }

        if(1 != vtlib_isModuleActive('CashBill')){
            $where .= " and name not in ('The billboard of Receivables') ";//回款金额龙虎榜
        }
        if(1 != vtlib_isModuleActive('TimeSheet') ){
            $where .= " and name not in ('TimeSheet personal monthly summary') ";//判断工时模块是否开启
        }
        if(1 != vtlib_isModuleActive('PaymentPlan') ){
            $where .= " and name not in ('CashBillSum_Paymentplan') ";
        }
        if(1 != vtlib_isModuleActive('SendPayment') ){
            $where .= " and name not in ('SendCashBillSum_SendPayment') ";
        }
        //editor:20181229 0035903: 库存报表，当库存模块一个都不启用时，报表应该不显示
        //出库单、入库单、盘点单、库间调拨、销售退货单、采购退货单、库存初始化
        if(1 != vtlib_isModuleActive('OutboundOrder')||
            1 != vtlib_isModuleActive('Stock')||
            1 != vtlib_isModuleActive('WareHouseTransfer')||
            1 != vtlib_isModuleActive('Checks')||
            1 != vtlib_isModuleActive('Prdtnums')||
            1 != vtlib_isModuleActive('SalesBack')||
            1 != vtlib_isModuleActive('PurchaseBack')){
            $where .= " and name not in ('InventoryReport') ";
        }
        //chj:应收账款汇总表：如果数据接口没有连接金蝶旗舰版则不显示当前报表  AccountsReceivableSummary
        if(getDatainterface('soft_version') != 5){
            $where .= " and name not in ('AccountsReceivableSummary') ";
        }

        $where .= " and name not in ('AccountsReceivableSummary') "; //应收款汇总表
        if(!is_admin($current_user))
        {
            //角色权限增加常用报表权限
            $SQL='select ifnull(relatednames,"")as relatednames from ld_profile2standardpermissions where profileid=? and tabid=?  ';
            $profile_result=$this->adb->pquery($SQL,array($current_user->profileid,getTabid($currentModule)));
            $numrows = $this->adb->num_rows($profile_result);
            if($numrows>0) {
                $relatednames = $this->adb->query_result($profile_result, 0, 'relatednames');
                if (!empty($relatednames)) {
                    $relatednames = explode(',', $relatednames);
                    $relatednames = implode("','", $relatednames);
                    $where .= " and name in ('$relatednames') ";
                }
            }
        }
        return $where;
    }
    //常用报表 多选框样式  销售阶段 单独一行
    public function getSalesStageSearch(){
        //增加销售阶段的筛选 【销售预测分析表，机会编号增加超链接，可根据销售阶段查询】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001000170
        $languageType = $this->languageType;
        crm_load_class_file("cls_PickList", 'modules/PickList');
        $obj_pink_list = new cls_PickList();
        $salesStageArr = $obj_pink_list->getPickListValues('sales_stage', '', array(), 'id');
        $html = '';
        $fieldlabel = gettranslabelfields('Potentials','sales_stage');
        $html .= '<tr><td colspan="1"><span class="changeday" style="width:120px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;height:30px;text-align: left;" title="'.$fieldlabel.'">'.$fieldlabel.':</span><div style="line-height: 30px;">';
        foreach($salesStageArr as $stage){
            $html.='<input type="checkbox" checked name="potential_salesstage" value="'.$stage.'" style="margin-left:5px;margin-right:5px;margin-top: -2px;"><span>'.$stage.'</span>';
        }
        $html.='</div>';
        return $html;
    }
    //常用报表 时间搜索条件  之前的样式
    public function getTimeSearch(){

    }
    //表头
    public function renderHeader(){

    }

}