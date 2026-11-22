<?php
/**
 * 更新操作
 * edit:can
 * date:20131106
 * reason:常用报表和自定义报表分开需求(V3.1)
 * */
include(globalStatic::$root_directory . 'modules/OftenUseReport/ReportSQL.php');

class OftenUseReport
{
    var $reporttype;
    var $usereportid;
    var $adb;
    var $groupcolLists;//小计列
    var $showcolLists;//经过设置后报表显示列
    var $AllReportHeaders;//报表所有可以显示的列
    var $where;
    var $startselect;
    var $finalselect;
    var $totalselect;
    var $reportname;
    var $reporttabid;
    var $advfilter;//是否有高级查询
    var $system_deploy_351; //单据头和单据分录“金额/货币”类型的小数位数
    var $mouthlen;
	public $moduleName;
	public $module_name;
    protected $get_progress = 'no';
    protected $start_row = 0;
	protected $end_row = 0;

    function __construct()
    {
        
        $system_351 = getSys_deploy(351);
        if(is_numeric($system_351['deploy_value'])){
            $system_deploy_351 = $system_351['deploy_value'];    
        }
        else {
            $system_deploy_351 = 2;
        }
        $this->system_deploy_351 = $system_deploy_351;
    }

    //editor:gyq_122 reason:删除__construct复杂参数，抽成新方法init_params  2019/6/13 17:23
    public function init_params($reporttype, $reportname, $usereportid, $adb, $showcolLists, $AllReportHeaders, $reporttabid, $advfilter)
    {
        global $adb;
        $this->reporttype = $reporttype;
        $this->usereportid = $usereportid;
        $this->adb = $adb;
        $this->showcolLists = $showcolLists;
        $this->AllReportHeaders = $AllReportHeaders;
        $this->reportname = $reportname;
        $this->reporttabid = $reporttabid;
        $this->advfilter = $advfilter;
        $this->mouthlen = 0;
    }

    function getOftenUserReport_WareHouse()
    {
        global $adb;
        //editor:gyq_107 reason:企业微信即时库存查询报表  2019/4/3 15:06
        require_once(globalStatic::$root_directory . 'include/Stock/CommonStock.php');
        $new_ware = array();
        $first_wareid = 0;
        $ware_arr = array('all' => getFixedLabel('ALL') . getFixedLabel('WAREHOUSE'));
        $wareresult = selWareAll();
        for ($i = 0; $i < $adb->num_rows($wareresult); $i++) {
            $ware_arr[$adb->query_result($wareresult, $i, "id")] = $adb->query_result($wareresult, $i, "name");
        }
        $first_wareid = 'all';
        return array('all' => $ware_arr, 'wareid' => $first_wareid);
    }

    /**
     * edit:can
     * date:20131106
     * reason:获取报表查询内容
     * */
    function getReportListView()
    {
        switch ($this->reporttype) {
            case 2:
                return $this->ListViewTwo();
            case 3:
                return $this->ListViewThree();
            case 4:
                return $this->ListViewFour();
            case 5:
                return $this->ListViewFive();
            case 6://高企进度表 zyh
                return $this->ListViewSix();
            case 10:
                return $this->ListViewten();
            case 11:
                return $this->ListViewtenLink();
            case 20:
                return $this->ListViewTwenty();
            case 21://应收账款汇总表
                return $this->ListViewTable();
            case 25:
                return $this->ListViewTwentyFive();
            case 26:
                return $this->ListViewTwentySix();
            case 50://签到统计表
                return $this->ListViewFifty();
            case 52://签到轨迹表
                return $this->ListViewFifty_two();
            case 55://移动轨迹
                return $this->ListViewFifty_five();
            case 60:
                return $this->ListViewForSalesRanking();
            case 61://zxm 2020-1009 销售提成报表_按合同统计
                //ZXM 2021-0715 东方报警特殊处理
                $versionInfo = getVersionInfo();
                if($versionInfo['account']=='east_alarm'){
                    include_once globalStatic::$root_directory.'modules/OftenUseReport/DongfangBaojingReport.php';
                    $DongfangBaojingReportObj = new DongfangBaojingReport($this->showcolLists);
                    $dataRange = $this->getRangeUserIds();
                    return  $DongfangBaojingReportObj->ListViewForSalesCommissionOrder($dataRange);
                }
                return $this->ListViewForSalesCommissionOrder();
            case 62://zxm 2020-1009销售提成报表_按收款统计
                return $this->ListViewForSalesCommissionCash();
            case 63://zxm 2020-1125 服务收费奖金_按合同统计
                return $this->ListViewForServiceChargeBonus("byorder");
            case 64://zxm 2020-1125服务收费奖金_按收款统计
                return $this->ListViewForServiceChargeBonus("bycash");
            case 65 ://zxm 2021-0220 产品销售排行榜
                $tradeInfo = getVersionTradeInfo();
                if($tradeInfo['account']=='zhihui'){
                    //微迪迦特殊开发
                    include_once globalStatic::$root_directory.'modules/OftenUseReport/WeidijiaReport.php';
                    $WeidijiaReportReportObj = new WeidijiaReport($this->showcolLists);
                    $dataRange = $this->getRangeUserIds();

                    return  $WeidijiaReportReportObj->ListViewForProductRanking($dataRange);
                }
                return $this->ListViewForProductRanking();
            case 66 ://zxm 2021-0220 产品总览 【上海鑫选-产品总览报表开发，已和刘总确认（徐昱轩）】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001002034
                return $this->ListViewForProductOverview();
            case 67 ://zxm 2021-1213 服务看板
                include_once globalStatic::$root_directory.'modules/OftenUseReport/ServiceKanBan.php';
                $ServiceKanBanObj = new ServiceKanBan($this->showcolLists);
                $dataRange = $this->getRangeUserIds();
                return $ServiceKanBanObj->ListViewForServiceKanBan(' and find_in_set(ld_troubletickets.smownerid,"'.$dataRange.'")');
            case 68 ://微迪迦 视频租赁收入表
                include_once globalStatic::$root_directory.'modules/OftenUseReport/WeidijiaReport.php';
                $WeidijiaReportReportObj = new WeidijiaReport($this->showcolLists);
                $dataRange = $this->getRangeUserIds();
                return  $WeidijiaReportReportObj->ListViewForVideoRental($dataRange);
        }
    }
    //zxm 2020-1010 销售提成报表_按收款统计 人员范围条件
    public function getRangeUserIds()
    {
        global $current_user,$adb;
        $scope = $_REQUEST['SmOwnerSearchScope'];
        $userids = $_REQUEST['receiverid'];
        if (!$scope) {
            $scope = 'SmOwner_Search_All';
        }
        switch ($scope) {
            case 'SmOwner_Search_All':
                $Smownerids = getCurSmOwnerSearchScope('ReportAnalysis');

                foreach ($Smownerids['UserCombo'] as $userid => $userinfo) {
                    if ($userids == "") {
                        $userids .= $userid;
                    } else {
                        $userids .= "," . $userid;
                    }
                }
                $userids .= "," . $current_user->id;
                break;
            case 'SmOwner_Search_Me':
                $userids = $current_user->id;
                break;
            case 'SmOwner_Search_Create':
                $userids = $current_user->id;
                break;
            case 'smowner_search_senior':
                if (!empty($userids)) {
                    $userids = $userids;
                }
                break;
            case 'SmOwner_Search_Group':
                $query = 'select userid from ld_users2group where groupid in (' . $_REQUEST['receiverid'] . ') group by userid';
                $result = $adb->pquery($query, array());
                $num_rows = $adb->num_rows($result);
                for ($i = 0; $i < $num_rows; $i++) {
                    $userid_array[] = $adb->query_result($result, $i, 'userid');
                }
                //zxm 2022-1111 常用报表改成报表分析的数据范围
                $ScopOfAuthority = ScopOfAuthority::getInstance($adb,$currentModule);
                $CurUserScopeId = $ScopOfAuthority->getCurUserScopeId();
                if ($CurUserScopeId == 'All') {
                    $intersection = $userid_array;
                } else {
                    $intersection = array_intersect($userid_array, $ScopOfAuthority->getUserModuleScopeHigher());
                }
                $userids = implode(',', $intersection);
                if (empty($userids)) $userids = 0;
                break;
            default:
                $userids = $scope;
        }
        return $userids;
    }

    /**
     * @return string
     * zxm
     * 20201009
     * 销售提成报表_按收款统计
     */
    private function ListViewForSalesCommissionCash()
    {
        //时间搜索条件
        $start_date = $_REQUEST['startmonth'];
        $end_date = $_REQUEST['endmonth'];
        // 业绩计算方法
        $jititype = isset($_REQUEST['achievement_type'])&&$_REQUEST['achievement_type']>=1?$_REQUEST['achievement_type']:1;
        // 成本计算方法
        $costtype = isset($_REQUEST['cost_accounting'])&&$_REQUEST['cost_accounting']>=1?$_REQUEST['cost_accounting']:1;
        // 只统计审批通过的费用和佣金单
        if(isset($_REQUEST['onlyshowapprovefeeandcommissions'])&&$_REQUEST['onlyshowapprovefeeandcommissions']=='yes'){
            $fee_range = "true";
        }else{
            $fee_range = "false";
        }
        // 只统计审批通过的合同订单与服务订单
        if(isset($_REQUEST['onlyshowapprovecontactandservice'])&&$_REQUEST['onlyshowapprovecontactandservice']=='yes'){
            $order_range = "true";
        }else{
            $order_range = "false";
        }
        $accountname = '';
        $ordernum = '';
        $data_range = $this->getRangeUserIds();
        // 查询sql
        $report_sql = ReportSQL::getCommissionByCash($start_date,$end_date,$jititype,$costtype,$fee_range,$order_range,$accountname,$ordernum,$data_range);
        $result = $this->adb->pquery($report_sql);
        $list = [];
        $html = '';
        $nums = $this->adb->num_rows($result);
        $nums_sub = 0;
        if($nums>=1){
            //@edit:liushuai,2020-12-10,reason:43656: （https://61mis.com/WX/kh40954 [^] ）（重庆维普资讯）销售提成报表-业务员的姓名没有正常显示
            $userobj = new Users();
            for ($i = 0; $i < $nums; $i++) {
                $userobj->wx_userid=$this->adb->query_result($result,$i,'wx_userid');
                $userobj->last_name=$this->adb->query_result($result,$i,'smownerid');
                $last_name=getUserlastName($userobj);

//                $last_name = $this->adb->query_result($result,$i,'smownerid');
                $order_id = $this->adb->query_result($result,$i,'order_id');
                $cashbillid = $this->adb->query_result($result,$i,'cashbillid');
                $account_id = $this->adb->query_result($result,$i,'account_id');
                if(!isset($subTotal[$last_name])){
                    $nums_sub = 1;
                }else{
                    $nums_sub += 1;
                }

                $list[$i]["order"] = $i;
                $list[$i]["order_id"] = $order_id;
                $list[$i]["cashbillid"] = $cashbillid;
                $list[$i]["account_id"] = $account_id;

                $source_rmbreceived = $this->adb->query_result($result,$i,'source_rmbreceived');

                $subTotal[$last_name]["order"] = $i+0.5;
                $subTotal["合计"]["order"] = $i+1;
                $subTotal[$last_name]["is_count"] = 1;
                $subTotal['合计']["is_count"] = 1;
                foreach($this->showcolLists  as $fieldName=>$v){
                    $fieldkeys = explode(':',$fieldName);
                    $fieldName = $fieldkeys[0];
                    $start_len = strpos($fieldName,'_')+1;
                    $fieldName = substr($fieldName,$start_len);
                    $typeofdata = $fieldkeys[1];
                    $typeofdata_decimal = $fieldkeys[2];


                    //设置小数位数
                    $list[$i]['typeofdata'] = $typeofdata;
                    $subTotal[$last_name]['typeofdata'] = $typeofdata;
                    $subTotal["合计"]['typeofdata'] = $typeofdata;

                    $list[$i]['typeofdata_decimal'] = $typeofdata_decimal;
                    $subTotal[$last_name]['typeofdata_decimal'] = $typeofdata_decimal;
                    $subTotal["合计"]['typeofdata_decimal'] = $typeofdata_decimal;

                    if($fieldName == 'smownerid'){
                        $subTotal[$last_name][$fieldName] = $last_name . '-' . getFixedLabel('SUBTOTAL');
                        $subTotal["合计"][$fieldName] = getFixedLabel('TOTAL');
                        $list[$i][$fieldName] = $last_name;
                    }else{
                        $list[$i][$fieldName] = $this->adb->query_result($result,$i,$fieldName);
                    }

                    if(in_array($fieldName,['total','yeji','total_fy','total_yj','total_cost','ticheng','source_rmbtotal','source_rmbreceived'])){
                        $subTotal[$last_name][$fieldName] = $subTotal[$last_name][$fieldName] + $list[$i][$fieldName];
                        $subTotal["合计"][$fieldName] = $list[$i][$fieldName];
                    }
                    if($fieldName=='source_displayreceived'){
                        $subTotal[$last_name][$fieldName] += $source_rmbreceived;
                        $subTotal["合计"][$fieldName] += $source_rmbreceived;
                    }
                    if(in_array($fieldName,['cashbilldate','accountid','cashbill_no','source_list'])){
                        $subTotal[$last_name][$fieldName] = '-';
                        $subTotal["合计"][$fieldName] = '-';
                    }
                    if($fieldName == 'done_rate'||$fieldName == 'target'){
                        $subTotal[$last_name][$fieldName] = $list[$i][$fieldName];
                        $subTotal["合计"][$fieldName] = '-';
                    }
                    if($fieldName == 'ticheng_rate'){
                        $subTotal[$last_name][$fieldName] = $list[$i][$fieldName];
                        $subTotal["合计"][$fieldName] = '-';
                    }
                    //设置小数位数
//                    if($typeofdata == 'N'||$typeofdata == 'NN'){
//                        $list[$i][$fieldName] = number_format($list[$i][$fieldName],$typeofdata_decimal);
//                        if($subTotal[$last_name][$fieldName] !== '-'){
//                            $subTotal[$last_name][$fieldName] = number_format($subTotal[$last_name][$fieldName],$typeofdata_decimal);
//                        }
//                        if($subTotal["合计"][$fieldName] !== '-'){
//                            $subTotal["合计"][$fieldName] = number_format($subTotal["合计"][$fieldName],$typeofdata_decimal);
//                        }
//                    }
                }
            }
            $subTotal = array_values($subTotal);
            $list = array_merge($subTotal,$list);

            $sort = _array_column($list,"order");
            array_multisort($sort,SORT_ASC,$list);
            foreach( $list as $key=>$val){
                $style = '';
                $class = 'lvtColData';
                if($key%2==0){
                    $class = 'lvtColDataBj';
                }
                if($val['is_count'] == 1){
                    $style = "style='background-color:#f0f4fc;'";
                }
                $order_id = $val['order_id'];
                $module_order = getSalesEntityType($val['order_id']);
                $module_cash = getSalesEntityType($val['cashbillid']);
                $module_account = getSalesEntityType($val['account_id']);
                $url = urlencode('index.php?pageto_module='.$module_order.'&pageto_action=index&pageto_record='.$order_id);
                $a_order = '<a lasturl="" module="'.$module_order.'" record="'.$order_id.'" href="'.$url.'" onclick="ListLinkClick(ld(this),event)" add_url_getvalue="" title="'.$val['source_list'].'">'.$val['source_list'].'</a>';
                $url = urlencode('index.php?pageto_module='.$module_account.'&pageto_action=index&pageto_record='.$val['account_id']);
                $a_account = '<a lasturl="" module="'.$module_account.'" record="'.$val['account_id'].'" href="'.$url.'" onclick="ListLinkClick(ld(this),event)" add_url_getvalue="" title="'.$val['accountid'].'">'.$val['accountid'].'</a>';
                $url ='index.php?pageto_module='.$module_cash.'&pageto_action=index&pageto_record='.$val['cashbillid'];
                $a_cash = '<a lasturl="" fieldname="cashbill_no" module="'.$module_cash.'" record="'.$val['cashbillid'].'" href="'.$url.'" onclick="ListLinkClick(ld(this),event)" add_url_getvalue="" title="'.$val['cashbill_no'].'">'.$val['cashbill_no'].'</a>';
                $html .= '<tr id="report_'.$key.'" '.$style.' class="'.$class.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')">';
                foreach( $val as $kk=>$vv) {
                    $is_count = $val['is_count'];
                    if ($kk != "order" && $kk!="is_count" && $kk!="cashbillid"&& $kk!="order_id"&& $kk!="account_id"&& $kk!="typeofdata"&& $kk!="typeofdata_decimal") {
                        if($kk == "salesorder_no"){
                            $html .= "<td style='text-align:left' valign='top'>" . $a_order . '</td>';
                        }else if($kk == "cashbill_no"){
                            $html .= "<td style='text-align:left' valign='top'>" . $a_cash . '</td>';
                        }else if($kk == "accountid"){
                            $html .= "<td style='text-align:left' valign='top'>" . $a_account . '</td>';
                        }else if(in_array($kk,['total','yeji','total_fy','total_yj','total_cost','ticheng','source_rmbtotal','source_rmbtotal'])){
                            $vv = !empty($vv)?floatval($vv):0;
                            $vv = number_format($vv,$val['typeofdata_decimal']);
                            $html .= "<td style='text-align:right' valign='top'>￥" . $vv . '</td>';
                        }else if(in_array($kk,['ticheng_rate'])){
                            $vv = !empty($vv)?floatval($vv):0;
                            $vv = number_format($vv,$val['typeofdata_decimal']);
                            $html .= "<td style='text-align:right' valign='top'>" . $vv . '</td>';
                        }else if(in_array($kk,['source_displayreceived'])&&$is_count==1){
                            $vv = !empty($vv)?floatval($vv):0;
                            $vv = number_format($vv,$val['typeofdata_decimal']);
                            $html .= "<td style='text-align:right' valign='top'>￥" . $vv . '</td>';
                        }else if(in_array($kk,['source_displayreceived'])&&empty($is_count)){
                            //$vv = number_format($vv,$val['typeofdata_decimal']);
                            $html .= "<td style='text-align:right' valign='top'>" . $vv . '</td>';
                        }else if($kk == "done_rate" ||$kk == "target"){
                            $vv = !empty($vv)?floatval($vv):0;
                            $vv = number_format($vv,$val['typeofdata_decimal']);
                            if($val['is_count'] == 1){
                                $html .= "<td style='text-align:right' valign='top'>" . $vv . '</td>';
                            }else{
                                $html .= "<td style='text-align:right' valign='top'>-</td>";
                            }
                        }else{
                            $html .= "<td style='text-align:left' valign='top'>" . $vv . '</td>';
                        }
                    }
                }
                $html .= "</tr>";
            }
        }else{
            $html .= "<tr>";
            foreach($this->showcolLists  as $fieldName=>$v){
                $html .= "<td style='text-align:left' valign='top'>-</td>";
            }
            $html .= "</tr>";
        }

        return $html;
    }
    /**
     * @return string
     * zxm
     * 20201009
     * 销售提成报表_按合同统计
     */
    private function ListViewForSalesCommissionOrder()
    {
        //时间搜索条件
        $start_date = $_REQUEST['startmonth'];
        $end_date = $_REQUEST['endmonth'];
        // 业绩计算方法
        $jititype = isset($_REQUEST['achievement_type'])&&$_REQUEST['achievement_type']>=1?$_REQUEST['achievement_type']:1;
        // 成本计算方法
        $costtype = isset($_REQUEST['cost_accounting'])&&$_REQUEST['cost_accounting']>=1?$_REQUEST['cost_accounting']:1;
        // 只统计审批通过的费用和佣金单
        if(isset($_REQUEST['onlyshowapprovefeeandcommissions'])&&$_REQUEST['onlyshowapprovefeeandcommissions']=='yes'){
            $fee_range = "true";
        }else{
            $fee_range = "false";
        }
        // 只统计审批通过的合同订单与服务订单
        if(isset($_REQUEST['onlyshowapprovecontactandservice'])&&$_REQUEST['onlyshowapprovecontactandservice']=='yes'){
            $order_range = "true";
        }else{
            $order_range = "false";
        }
        $accountname = '';
        $ordernum = '';
        $data_range = $this->getRangeUserIds();
        //查询sql
        $report_sql = ReportSQL::getCommissionByOrder($start_date,$end_date,$jititype,$costtype,$fee_range,$order_range,$accountname,$ordernum,$data_range);
        $result = $this->adb->pquery($report_sql);
        $html = '';
        $nums = $this->adb->num_rows($result);
        $list = [];
        $subTotal = [];
        $nums_sub = 0;


        if($nums>=1){
            //@edit:liushuai,2020-12-10,reason:43656: （https://61mis.com/WX/kh40954 [^] ）（重庆维普资讯）销售提成报表-业务员的姓名没有正常显示
            $userobj = new Users();
            for ($i = 0; $i < $nums; $i++) {
                $userobj->wx_userid=$this->adb->query_result($result,$i,'wx_userid');
                $userobj->last_name=$this->adb->query_result($result,$i,'smownerid');
                $last_name=getUserlastName($userobj);

                //$last_name = $this->adb->query_result($result,$i,'smownerid');
                $order_id = $this->adb->query_result($result,$i,'order_id');
                $accountid = $this->adb->query_result($result,$i,'accountid');
                if(!isset($subTotal[$last_name])){
                    $nums_sub = 1;
                }else{
                    $nums_sub += 1;
                }

                $list[$i]["order"] = $i;
                $list[$i]["order_id"] = $order_id;
                $list[$i]["accountid"] = $accountid;
                $subTotal[$last_name]["order"] = $i+0.5;
                $subTotal["合计"]["order"] = $i+1;
                $subTotal[$last_name]["is_count"] = 1;
                $subTotal['合计']["is_count"] = 1;

                foreach($this->showcolLists  as $fieldName=>$v){
                    $fieldkeys = explode(':',$fieldName);
                    $fieldName = $fieldkeys[0];
                    $start_len = strpos($fieldName,'_')+1;
                    $fieldName = substr($fieldName,$start_len);
                    $typeofdata = $fieldkeys[1];
                    $typeofdata_decimal = $fieldkeys[2];

                    //设置小数位数
                    $list[$i]['typeofdata'] = $typeofdata;
                    $subTotal[$last_name]['typeofdata'] = $typeofdata;
                    $subTotal["合计"]['typeofdata'] = $typeofdata;
                    $list[$i]['typeofdata_decimal'] = $typeofdata_decimal;
                    $subTotal[$last_name]['typeofdata_decimal'] = $typeofdata_decimal;
                    $subTotal["合计"]['typeofdata_decimal'] = $typeofdata_decimal;

                    if($fieldName == 'smownerid'){
                        $subTotal[$last_name][$fieldName] = $last_name . '-' . getFixedLabel('SUBTOTAL');
                        $subTotal["合计"][$fieldName] = getFixedLabel('TOTAL');
                        $list[$i][$fieldName] = $last_name;
                    }else{
                        $list[$i][$fieldName] = $this->adb->query_result($result,$i,$fieldName);
                    }

                    if(in_array($fieldName,['total','total_yj','total_fy','total_cost','yeji','ticheng'])){
                        $subTotal[$last_name][$fieldName] += $list[$i][$fieldName];
                        $subTotal["合计"][$fieldName] += $list[$i][$fieldName];
                    }
                    if(in_array($fieldName,['salesorder_no','signed_data','account_id','stockpresence','salesorder_no'])){
                        $subTotal[$last_name][$fieldName] = '-';
                        $subTotal["合计"][$fieldName] = '-';
                    }
                    if($fieldName == 'done_rate'||$fieldName == 'target'){
                        $subTotal[$last_name][$fieldName] = $list[$i][$fieldName];
                        $subTotal["合计"][$fieldName] = '-';
                    }
                    if($fieldName == 'ticheng_rate'){
                        $subTotal[$last_name][$fieldName] = $list[$i][$fieldName];
                        $subTotal["合计"][$fieldName] = '-';
                    }
                    
                    //设置小数位数 --有错 注释 zxm20230206
//                    if($typeofdata == 'N'||$typeofdata == 'NN'){
//                        $list[$i][$fieldName] = number_format($list[$i][$fieldName],$typeofdata_decimal);
//                        if($subTotal[$last_name][$fieldName] !== '-'){
//                            $subTotal[$last_name][$fieldName] = number_format($subTotal[$last_name][$fieldName],$typeofdata_decimal);
//                        }
//                        if($subTotal["合计"][$fieldName] !== '-'){
//                            $subTotal["合计"][$fieldName] = number_format($subTotal["合计"][$fieldName],$typeofdata_decimal);
//                        }
//                    }
                }
            }
            $subTotal = array_values($subTotal);
            $list = array_merge($subTotal,$list);
            $sort = _array_column($list,"order");

            array_multisort($sort,SORT_ASC,$list);
            foreach( $list as $k=>$v){
                $style = '';
                $class = 'lvtColData';
                if($k%2==0){
                    $class = 'lvtColDataBj';
                }
                if($v['is_count'] == 1){
                    $style = "style='background-color:#f0f4fc;'";
                }
                $order_id = $v['order_id'];
                $accountid = $v['accountid'];
                $module_order = getSalesEntityType($order_id);
                $a_order = '<a lasturl="" module="'.$module_order.'" record="'.$order_id.'" href="index.php?pageto_module='.$module_order.'&pageto_action=index&pageto_record='.$order_id.'" onclick="ListLinkClick(ld(this),event)" add_url_getvalue="" title="'.$v['salesorder_no'].'">'.$v['salesorder_no'].'</a>';
                $a_account = '<a lasturl="" module="Accounts" record="'.$accountid.'" href="index.php?pageto_module=Accounts&pageto_action=index&pageto_record='.$accountid.'" onclick="ListLinkClick(ld(this),event)" add_url_getvalue="" title="'.$v['account_id'].'">'.$v['account_id'].'</a>';
                $html .= '<tr id="report_'.$k.'" '.$style.' class="'.$class.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')">';
                foreach( $v as $kk=>$vv) {
                    if ($kk != "order" && $kk!="is_count"&& $kk!="order_id"&& $kk!="accountid"&& $kk!="typeofdata"&& $kk!="typeofdata_decimal") {
                        if($kk == "salesorder_no"){
                            $html .= "<td style='text-align:left' valign='top'><a href=''>" . $a_order . '</a></td>';
                        }else if($kk == "account_id"){
                            $html .= "<td style='text-align:left' valign='top'><a href=''>" . $a_account . '</a></td>';
                        }else if(in_array($kk,['total','total_yj','total_fy','total_cost','yeji','ticheng','ticheng_rate'])){
                            $vv = !empty($vv)?floatval($vv):0;
                            $vv = number_format($vv,$v['typeofdata_decimal']);
                            $html .= "<td style='text-align:right' valign='top'>￥" . $vv . '</td>';
                        }else if(in_array($kk,['ticheng_rate'])){
                            $vv = !empty($vv)?floatval($vv):0;
                            $vv = number_format($vv,$v['typeofdata_decimal']);
                            $html .= "<td style='text-align:right' valign='top'>" . $vv . '</td>';
                        }else if($kk == "done_rate" ||$kk == "target"){
                            $vv = !empty($vv)?floatval($vv):0;
                            $vv = number_format($vv,$v['typeofdata_decimal']);
                            if($v['is_count'] == 1){
                                $html .= "<td style='text-align:right' valign='top'>" . $vv . '</td>';
                            }else{
                                $html .= "<td style='text-align:right' valign='top'>-</td>";
                            }
                        }else{
                            $html .= "<td style='text-align:left' valign='top'>" . $vv . '</td>';
                        }
                    }
                }
                $html .= "</tr>";
            }
        }else{
            $html .= "<tr>";
            foreach($this->showcolLists  as $fieldName=>$v){
                $html .= "<td style='text-align:left' valign='top'>-</td>";
            }
            $html .= "</tr>";
        }
        //dump($html);
        return $html;
    }

    /**
     * zxm
     * 2020-1125
     * 服务收费奖金_按合同统计byorder  按收款统计bycash
     */
    private function ListViewForServiceChargeBonus($bytype)
    {
        // byorder  bycash
        if($bytype == "byorder"){
            $table = "ld_servicecontracts";
            $datename = "due_date";
            $reportName = "ServiceChargeBonusByOrder";
            // 只统计审批通过的服务合同
            if (isset($_REQUEST['onlyshowapproveservicecontract']) && $_REQUEST['onlyshowapproveservicecontract'] == 'yes') {
                $contract_range = "yes";
            } else {
                $contract_range = "no";
            }
        }else{
            $table = "ld_cashbill";
            $datename = "cashbilldate";
            $reportName = "ServiceChargeBonusByCash";
            // 只统计审批通过的收款单
            if (isset($_REQUEST['onlyshowapprovecashbill']) && $_REQUEST['onlyshowapprovecashbill'] == 'yes') {
                $contract_range = "yes";
            } else {
                $contract_range = "no";
            }
        }
        //时间搜索条件
        $start_date = $_REQUEST['startmonth'];
        $end_date = $_REQUEST['endmonth'];
        // 只统计审批通过的客户服务单
        if (isset($_REQUEST['onlyshowapproveservicebill']) && $_REQUEST['onlyshowapproveservicebill'] == 'yes') {
            $help_range = "yes";
        } else {
            $help_range = "no";
        }
        $data_range = $this->getRangeUserIds();
        // 查询数据范围成员的总服务合同金额、奖金池比例
        $pool_sql = "SELECT 
	b.pool_rate,
	IFNULL(b.total*b.pool_rate,0)*0.01 AS pool_money,
	b.total as total_order
FROM (
	SELECT
		total,
		CASE
			WHEN EXISTS (SELECT 1 FROM ld_userreport_commissionrule WHERE is_on='yes' AND unit='万元' AND bytype='$reportName') THEN
				(SELECT commission_rate FROM ld_userreport_commissionrule WHERE is_on='yes' AND unit='万元' AND bytype='$reportName' AND a.total>=`start`*10000 AND a.total<`end`*10000  ORDER BY `start` LIMIT 1)
			ELSE 0
		END AS pool_rate
		FROM (
				SELECT
					sum(total/IFNULL(conversion_rate,1))  AS total
				FROM $table
				WHERE deleted=0
					AND IFNULL(approvestatus,'')<>'已拒绝'
					AND (
                    CASE
                        WHEN '$contract_range'='yes' THEN approvestatus='已批准'
                        ELSE 1=1
                    END)
					AND $datename BETWEEN '$start_date' AND '$end_date'
					AND smownerid IN($data_range)
			)a
	) b";
        $pool_res = $this->adb->pquery($pool_sql);
        $pool_nums = $this->adb->num_rows($pool_res);
        if ($pool_nums >= 1) {
            $pool_rate = $this->adb->query_result($pool_res, 0, 'pool_rate');//奖金池比例
            $pool_rate = empty($pool_rate) ? 0 : $pool_rate;
            $pool_money = $this->adb->query_result($pool_res, 0, 'pool_money');//奖金池总金额
            $pool_money = empty($pool_money) ? 0 : $pool_money;
            $total_order = $this->adb->query_result($pool_res, 0, 'total_order');//服务订单总金额
            $total_order = empty($total_order) ? 0 : $total_order;
        } else {
            $pool_rate = 0;
            $pool_money = 0;
            $total_order = 0;
        }

        // 获取数据范围成员的总服务业绩
        $fuwu_sql = "SELECT	
		SUM(((IFNULL(chanpin.scores,0)*IFNULL(guzhang.weight,0)*0.01+IF((SELECT COUNT(1) FROM ld_systems_deploy where deploy_type=207 AND deploy_value='bill_city')=1,IFNULL(city.scores,0),IFNULL(area.scores,0)))
			*IFNULL(fuwufangshi.weight,100)*0.01
			*IFNULL(huifang.rate_jiejue,100)*0.01
			*IFNULL(huifang.rate_jishi,100)*0.01
			*IFNULL(huifang.rate_manyi,100)*0.01)) AS fuwuyeji
	FROM ld_troubletickets a
	LEFT JOIN ld_account k ON k.accountid=a.accountid
	LEFT JOIN (
		SELECT
			b.listvalue AS leibie,
			b.scores
		FROM ld_picklist_set a
		LEFT JOIN ld_picklist_values b ON b.listid = a.listid
		WHERE a.listname='productcategory' 
			AND a.relatetable='ld_field'
	) AS chanpin ON chanpin.leibie=a.productcategory
	LEFT JOIN (
		SELECT
			b.listvalue AS leibie,
			b.weight
		FROM ld_picklist_set a
		LEFT JOIN ld_picklist_values b ON b.listid = a.listid
		WHERE a.listname='servicetype' 
			AND a.relatetable='ld_field'
	) AS fuwufangshi ON fuwufangshi.leibie=a.servicetype
	LEFT JOIN (
		SELECT
			b.listvalue AS leibie,
			b.weight
		FROM ld_picklist_set a
		LEFT JOIN ld_picklist_values b ON b.listid = a.listid
		WHERE a.listname='ticketcategories' 
			AND a.relatetable='ld_field'
	) AS guzhang ON guzhang.leibie=a.category
	LEFT JOIN (
		SELECT
			b.listvalue AS leibie,
			b.scores
		FROM ld_picklist_set a
		LEFT JOIN ld_picklist_values b ON b.listid = a.listid
		WHERE relatetable = 'ld_field'
			AND a.listname = 'bill_city'
	) AS city ON city.leibie=k.bill_city
	LEFT JOIN (
		SELECT
			b.listvalue AS leibie,
			b.scores
		FROM ld_picklist_set a
		LEFT JOIN ld_picklist_values b ON b.listid = a.listid
		WHERE a.relatetable = 'ld_field'
			AND a.listname = 'bill_area'
	) AS area ON area.leibie=k.bill_area
	LEFT JOIN (
		SELECT
			troubleticketid,
			AVG(IFNULL(satisfaction,100)) AS rate_manyi,
			AVG(IFNULL(timelyrate,100)) AS rate_jishi,
			AVG(IFNULL(resolutionrate,100)) AS rate_jiejue
		FROM ld_servicereturn
		WHERE deleted=0
			AND troubleticketid>0
		GROUP BY troubleticketid
	) huifang ON huifang.troubleticketid = a.ticketid
	WHERE a.deleted=0
		AND a.approvestatus<>'已拒绝'
		AND (
			CASE
				WHEN '$help_range'='yes' THEN a.approvestatus='已批准'
				ELSE 1=1
			END)
		AND IFNULL(a.realtime,a.createdtime) BETWEEN '$start_date' AND '$end_date'
		AND a.smownerid IN ($data_range)";
        $fuwu_res = $this->adb->pquery($fuwu_sql);
        $fuwu_nums = $this->adb->num_rows($fuwu_res);
        if($fuwu_nums>0){
            $fuwu_total = $this->adb->query_result($fuwu_res, 0, 'fuwuyeji');
            $fuwu_total = empty($fuwu_total) ? 0 : $fuwu_total;
        }else{
            $fuwu_total = 0;
        }

        // 报表查询SQL
        $res_sql = "SELECT
	u.id,
	u.last_name,
	IFNULL($total_order,0) AS total_order,
	IFNULL($pool_rate,0) AS pool_rate,
	IFNULL($total_order,0)*IFNULL($pool_rate,0)*0.01 AS pool_amount,
	IFNULL(yeji.fuwuyeji,0) AS yeji_geren,
	IFNULL($fuwu_total,0) AS yeji_total,
	CONCAT(IFNULL(yeji.fuwuyeji,0)*100/IFNULL($fuwu_total,0),'%') AS yeji_rate,
	((IFNULL($total_order,0)*IFNULL($pool_rate,0)*0.01)*(IFNULL(yeji.fuwuyeji,0))/IFNULL($fuwu_total,0)) AS jiangjin
FROM ld_users u
LEFT JOIN (
	SELECT	
		a.smownerid,
		SUM(((IFNULL(chanpin.scores,0)*IFNULL(guzhang.weight,0)*0.01+IF((SELECT COUNT(1) FROM ld_systems_deploy where deploy_type=207 AND deploy_value='bill_city')=1,IFNULL(city.scores,0),IFNULL(area.scores,0)))
			*IFNULL(fuwufangshi.weight,100)*0.01
			*IFNULL(huifang.rate_jiejue,100)*0.01
			*IFNULL(huifang.rate_jishi,100)*0.01
			*IFNULL(huifang.rate_manyi,100)*0.01)) AS fuwuyeji
	FROM ld_troubletickets a
	LEFT JOIN ld_users u ON u.id=a.smownerid
	LEFT JOIN ld_account k ON k.accountid=a.accountid
	LEFT JOIN (
		SELECT
			b.listvalue AS leibie,
			b.scores
		FROM ld_picklist_set a
		LEFT JOIN ld_picklist_values b ON b.listid = a.listid
		WHERE a.listname='productcategory' 
			AND a.relatetable='ld_field'
	) AS chanpin ON chanpin.leibie=a.productcategory
	LEFT JOIN (
		SELECT
			b.listvalue AS leibie,
			b.weight
		FROM ld_picklist_set a
		LEFT JOIN ld_picklist_values b ON b.listid = a.listid
		WHERE a.listname='servicetype' 
			AND a.relatetable='ld_field'
	) AS fuwufangshi ON fuwufangshi.leibie=a.servicetype
	LEFT JOIN (
		SELECT
			b.listvalue AS leibie,
			b.weight
		FROM ld_picklist_set a
		LEFT JOIN ld_picklist_values b ON b.listid = a.listid
		WHERE a.listname='ticketcategories' 
			AND a.relatetable='ld_field'
	) AS guzhang ON guzhang.leibie=a.category
	LEFT JOIN (
		SELECT
			b.listvalue AS leibie,
			b.scores
		FROM ld_picklist_set a
		LEFT JOIN ld_picklist_values b ON b.listid = a.listid
		WHERE relatetable = 'ld_field'
			AND a.listname = 'bill_city'
	) AS city ON city.leibie=k.bill_city
	LEFT JOIN (
		SELECT
			b.listvalue AS leibie,
			b.scores
		FROM ld_picklist_set a
		LEFT JOIN ld_picklist_values b ON b.listid = a.listid
		WHERE a.relatetable = 'ld_field'
			AND a.listname = 'bill_area'
	) AS area ON area.leibie=k.bill_area
	LEFT JOIN (
		SELECT
			troubleticketid,
			AVG(IFNULL(satisfaction,100)) AS rate_manyi,
			AVG(IFNULL(timelyrate,100)) AS rate_jishi,
			AVG(IFNULL(resolutionrate,100)) AS rate_jiejue
		FROM ld_servicereturn
		WHERE deleted=0
			AND troubleticketid>0
		GROUP BY troubleticketid
	) huifang ON huifang.troubleticketid = a.ticketid
	WHERE a.deleted=0
		AND a.approvestatus<>'已拒绝'
		AND (
			CASE
				WHEN '$help_range'='yes' THEN a.approvestatus='已批准'
				ELSE 1=1
			END)
		AND IFNULL(a.realtime,a.createdtime) BETWEEN '$start_date' AND '$end_date'
		AND a.smownerid IN ($data_range)
	GROUP BY smownerid
) yeji ON yeji.smownerid=u.id
WHERE u.id IN ($data_range)";
        $res = $this->adb->pquery($res_sql);
        $nums = $this->adb->num_rows($res);
        $result = [];


        if ($nums > 0) {
            $list = [];
            for ($i = 0; $i < $nums; $i++) {
                foreach ($this->showcolLists as $fieldName => $v) {
                    $fieldkeys =explode(':', $fieldName);
                    $fieldName = $fieldkeys[0];
                    $start_len = strpos($fieldName, '_') + 1;
                    $fieldName = substr($fieldName, $start_len);
                    $typeofdata = $fieldkeys[1];
                    $typeofdata_decimal = $fieldkeys[2];
                    if(in_array($fieldName,array('totalmoney','pool_money','yeji_geren','yeji_total','jiangjin'))){
                        $typeofdata_decimal = $this->system_deploy_351;
                    }
                    if ($fieldName == "totalmoney") {
                        $list[$i][$fieldName] = $total_order;
                    } else
                        if ($fieldName == "pool_rate") {
                            $list[$i][$fieldName] = $pool_rate;
                        } else
                            if ($fieldName == "pool_money") {
                                $list[$i]['pool_money'] = $this->adb->query_result($res, $i, 'pool_amount');
                            } else {
                                $list[$i][$fieldName] = $this->adb->query_result($res, $i, $fieldName);
                            }
                    
                    //设置小数位数
                    if($typeofdata == 'N'||$typeofdata == 'NN'){
                        $list[$i][$fieldName] = number_format($list[$i][$fieldName],$typeofdata_decimal);
                    }
                }
            }
            $html = "";
            foreach ($list as $k => $v) {
                $class = 'lvtColData';
                if($k%2==0){
                    $class = 'lvtColDataBj';
                }
                $html .= '<tr id="report_'.$k.'" class="'.$class.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')">';
                foreach ($v as $kk => $vv) {
                    //dump($v);
                    if(in_array($kk,['pool_money','yeji_geren','yeji_total','jiangjin','totalmoney'])){
                        $html .= "<td style='text-align:right' valign='top'>￥" . $vv . '</td>';
                    }
                    else if(in_array($kk,['pool_rate','yeji_rate'])){
                        $html .= "<td style='text-align:right' valign='top'>" . $vv . '</td>';
                    }
                    else{
                        $html .= "<td style='text-align:left' valign='top'>" . $vv . '</td>';
                    }
                }
                $html .= "</tr>";
            }
        }else{
            $html = "<tr>";
            foreach($this->showcolLists  as $fieldName=>$v){
                $html .= "<td style='text-align:left' valign='top'>-</td>";
            }
            $html .= "</tr>";
        }
        return $html;
    }


    private function ListViewForProductRanking(){
        //单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
        if (isset($sysdeploy['deploy_value'])) {
            $lengthdecimaldigits = $sysdeploy['deploy_value'];
        }else {
            $lengthdecimaldigits = 2;
        }
        $where = ' where a.deleted=0 ';
        crm_load_class_file('cls_QueryGenerator','modules/OftenUseReport');
        $queryGenerator = new cls_QueryGenerator('', null,'');
        $queryGenerator->addUserSearchConditions($_REQUEST);
        $advsearch = $queryGenerator->getWhereClause();
        $where_product = '';
        if(!empty($advsearch)){
            $where_product .= ' where '.$advsearch;
        }
        //产品名称模糊搜索
        $product_name = $_REQUEST['product_name'];
        if(!empty($product_name)){
            $where_product = empty($where_product)?" where ":" and ";
            $where_product .= "productname like '%$product_name%'";
        }
        //时间搜索条件
        $start_date = $_REQUEST['startmonth'];
        $end_date = $_REQUEST['endmonth'];
        // 只统计审批通过的合同订单与服务订单
        if(isset($_REQUEST['onlyshowapprovecontactandservice'])&&$_REQUEST['onlyshowapprovecontactandservice']=='yes'){
            $where .= " and a.approvestatus='已批准'";
        }
		$scope = $_REQUEST['SmOwnerSearchScope'];
        if (!$scope) {
            $scope = 'SmOwner_Search_All';
        }
		if($scope == 'SmOwner_Search_All' && is_admin($current_user)){
			
		}else{
			$data_range = $this->getRangeUserIds();
			$where .= " and a.smownerid in (".$data_range.")";
		}
       
        //排行维度
        $product_ranking_type = $_REQUEST['product_ranking_type'];
		//chj 2021/3/19 45057: （http://81.68.124.239:85/crm [^]）在产品销售排行榜中，自定义日期为2020.1.1-2020.12.31，排行维度为“产品签约数量”时报表中可以搜索到产品“致远OA软件”，排行维度变为“产品签约金额”时报表中搜索不到产品“致远OA软
		//订单：due_date 改成 signed_data
        //币种符号
        $unit = '';
        switch ($product_ranking_type){
            case 'productSignCount':
                //ld_salesorder,ld_salesorderdetail,ld_products
                $where_salesorder = $where." and a.signed_data between '$start_date' and '$end_date' ";
                $where_service = $where." and a.due_date between '$start_date' and '$end_date' ";
                $sql = " select 
 (ifnull(b.quantity,0)+ifnull(c.quantity,0)) as product_count,
 productname,
 productsheet,
 product_no,
 a.productid 
 from 
 (select productname,productsheet,product_no,ld_products.productid from ld_products LEFT JOIN ld_productcf on ld_products.productid=ld_productcf.productid $where_product) a left join 
 (select sum(b.quantity) as quantity,b.productid from ld_salesorder a left join 
 ld_salesorderdetail b on a.salesorderid=b.id $where_salesorder  group by b.productid) 
 as b on a.productid=b.productid
 left join 
 (select sum(b.quantity) as quantity,b.productid from ld_servicecontracts a left join ld_servicecontractsdetail b on a.servicecontractsid=b.id $where_service group by b.productid) c on a.productid=c.productid where (ifnull(b.quantity,0)+ifnull(c.quantity,0))>0 group by a.productid order by product_count desc ";
                break;
            case 'productSignAmount':
                $where_salesorder = $where." and a.signed_data between '$start_date' and '$end_date' ";
                $where_service = $where." and a.due_date between '$start_date' and '$end_date' ";
                $sql = " select 
 (ifnull(b.quantity,0)+ifnull(c.quantity,0)) as product_count,
 productname,
 productsheet,
 product_no,
 a.productid 
 from 
 (select productname,productsheet,product_no,ld_products.productid from ld_products LEFT JOIN ld_productcf on ld_products.productid=ld_productcf.productid $where_product) a left join 
 (select sum(b.tax_amount/ifnull(a.conversion_rate,1)) as quantity,b.productid from ld_salesorder a left join 
 ld_salesorderdetail b on a.salesorderid=b.id $where_salesorder group by b.productid) 
 as b on a.productid=b.productid
 left join 
 (select sum(b.quantity*b.taxprice) as quantity,b.productid from ld_servicecontracts a left join ld_servicecontractsdetail b on a.servicecontractsid=b.id $where_service group by b.productid) c on a.productid=c.productid where (ifnull(b.quantity,0)+ifnull(c.quantity,0))>0 group by a.productid order by product_count desc ";
                $unit = '￥';
                break;
            case 'productOrderCount':
                $where = $where." and a.signed_data between '$start_date' and '$end_date' ";
                $sql = "select 
 ifnull(b.quantity,0) as product_count,
 productname,
 productsheet,
 product_no,
 a.productid 
 from 
 (select productname,productsheet,product_no,ld_products.productid from ld_products LEFT JOIN ld_productcf on ld_products.productid=ld_productcf.productid $where_product) a left join 
 (select sum(b.quantity) as quantity,b.productid from ld_salesorder a left join 
 ld_salesorderdetail b on a.salesorderid=b.id $where group by b.productid) 
 as b on a.productid=b.productid
where ifnull(b.quantity,0)>0 group by a.productid order by product_count desc";
                break;
            case 'productOrderAmount':
                $where .= " and a.signed_data between '$start_date' and '$end_date' ";
                $sql = " select 
 ifnull(b.quantity,0) as product_count,
 productname,
 productsheet,
 product_no,
 a.productid 
 from 
 (select productname,productsheet,product_no,ld_products.productid from ld_products LEFT JOIN ld_productcf on ld_products.productid=ld_productcf.productid $where_product) a left join 
 (select sum(b.tax_amount/ifnull(a.conversion_rate,1)) as quantity,b.productid from ld_salesorder a left join 
 ld_salesorderdetail b on a.salesorderid=b.id $where group by b.productid) 
 as b on a.productid=b.productid
 where ifnull(b.quantity,0)>0 group by a.productid order by product_count desc ";
                $unit = '￥';
                break;
            case 'productInvoiceAmount':
                $where .= " and a.invoicedate between '$start_date' and '$end_date' ";
                $sql = "select 
 (ifnull(b.quantity,0)) as product_count,
 productname,
 productsheet,
 product_no,
 a.productid 
 from 
 (select productname,productsheet,product_no,ld_products.productid from ld_products LEFT JOIN ld_productcf on ld_products.productid=ld_productcf.productid $where_product) a left join 
 (select sum(b.tax_amount/ifnull(a.conversion_rate,1)) as quantity,b.productid from ld_invoice a left join 
 ld_invoicedetail b on a.invoiceid=b.id $where group by b.productid) 
 as b on a.productid=b.productid
 where (ifnull(b.quantity,0))>0 group by a.productid order by product_count desc ";
                $unit = '￥';
                break;
            case 'productOutboundCount':
                $where .= " and a.outdate between '$start_date' and '$end_date' ";
                $sql = "select 
 (ifnull(b.quantity,0)) as product_count,
 productname,
 productsheet,
 product_no,
 a.productid 
 from 
 (select productname,productsheet,product_no,ld_products.productid from ld_products LEFT JOIN ld_productcf on ld_products.productid=ld_productcf.productid $where_product) a left join 
 (select sum(b.quantity) as quantity,b.productid from ld_outboundorder a left join 
 ld_outboundorderdetail b on a.out_id=b.id $where group by b.productid) 
 as b on a.productid=b.productid
  where (ifnull(b.quantity,0))>0 group by a.productid order by product_count desc";
                break;
            case 'productOutboundAmount':
                $where .= " and a.outdate between '$start_date' and '$end_date' ";
                $sql = "select 
 (ifnull(b.quantity,0)) as product_count,
 productname,
 productsheet,
 product_no,
 a.productid 
 from 
 (select productname,productsheet,product_no,ld_products.productid from ld_products LEFT JOIN ld_productcf on ld_products.productid=ld_productcf.productid $where_product) a left join 
 (select sum(b.tax_amount/ifnull(a.conversion_rate,1)) as quantity,b.productid from ld_outboundorder a left join 
 ld_outboundorderdetail b on a.out_id=b.id $where group by b.productid) 
 as b on a.productid=b.productid
 where (ifnull(b.quantity,0))>0 group by a.productid order by product_count desc";
                $unit = '￥';
                break;
        }
        $res = $this->adb->pquery($sql);
        $nums = $this->adb->num_rows($res);
        $list = [];

        if ($nums > 0) {
            for ($i = 0; $i < $nums; $i++) {
                foreach ($this->showcolLists as $fieldName => $v) {
                    $fieldName = explode(':', $fieldName)[0];
                    $start_len = strpos($fieldName, '_') + 1;
                    $fieldName = substr($fieldName, $start_len);
                    $list[$i][$fieldName] = $this->adb->query_result($res, $i, $fieldName);
                }
            }
            $html = "<tr>";
            foreach ($list as $k => $v) {
                $class = 'lvtColData';
                if($k%2==0){
                    $class = 'lvtColDataBj';
                }
                $html .= '<tr id="report_'.$k.'" class="'.$class.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')">';
                foreach ($v as $kk => $vv) {
                    if($kk == "product_count"){
                        $vv = !empty($vv)?floatval($vv):0;
                        if(in_array($product_ranking_type,['productSignCount','productOrderCount','productOutboundCount'])){
                            $vv = number_format($vv,$lengthdecimaldigits);
                        }else{
                            $vv = number_format($vv,$this->system_deploy_351);
                        }
                    }
                    if($kk == "productid"){
                        $vv = $k+1;
                    }
                    if($kk == "product_count"){
                        $html .= "<td style='text-align:right;' valign='top'>" . $unit.$vv . '</td>';
                    }else{
                        $html .= "<td style='text-align:left;' valign='top'>" . $vv . '</td>';
                    }
                }
                $html .= "</tr>";
            }
        }else{
            $html = "<tr>";
            foreach($this->showcolLists  as $fieldName=>$v){
                $html .= "<td style='text-align:left' valign='top'>-</td>";
            }
            $html .= "</tr>";
        }
        return $html;

    }

    private function ListViewForProductOverview(){
        global $current_user;
        //单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
        if (isset($sysdeploy['deploy_value'])) {
            $lengthdecimaldigits = $sysdeploy['deploy_value'];
        }else {
            $lengthdecimaldigits = 2;
        }
        $where = ' where a.deleted=0 ';
        $where_out = $where;
        $where_in = $where;
        $where_book = $where;
        $where_product = ' where ld_products.deleted=0 ';
        $scope = $_REQUEST['SmOwnerSearchScope'];
        $userids = $_REQUEST['receiverid'];
        if (!$scope) {
            $scope = 'SmOwner_Search_All';
        }
        switch ($scope) {
            case 'SmOwner_Search_All':
                $Smownerids = getCurSmOwnerSearchScope('OftenUseReport');
                foreach ($Smownerids['UserCombo'] as $userid => $userinfo) {
                    if ($userids == "") {
                        $userids .= $userid;
                    } else {
                        $userids .= "," . $userid;
                    }
                }
                $userids .= "," . $current_user->id;
                $where_product .= '  and ld_products.smownerid in ( ' . $userids . ' )';
                $where_out .=  '  and a.smownerid in ( ' . $userids . ' )';
                $where_in .=  '  and a.smownerid in ( ' . $userids . ' )';
                $where_book .= '  and a.smownerid in ( ' . $userids . ' )';
                break;
            case 'SmOwner_Search_Me':
            case 'SmOwner_Search_Create':
                $where_product .= " and ld_products.smownerid=" . $current_user->id;
                $where_out .= " and a.smownerid=" . $current_user->id;
                $where_in .= " and a.smownerid=" . $current_user->id;
                $where_book .=  " and a.smownerid=" . $current_user->id;
                break;
            case 'SmOwer_Search_ShareMe':
                $where_product = "  and ld_products.viewuserid =" . $current_user->id . "";
                $where_out .= " and a.viewuserid=" . $current_user->id;
                $where_in .= " and a.viewuserid=" . $current_user->id;
                $where_book .=  " and a.viewuserid=" . $current_user->id;
                break;
            case 'smowner_search_senior':
                if (!empty($userids)) {
                    $where_product .= " and ld_products.smownerid in ( " . $userids . ")";
                    $where_out .= " and a.smownerid in ( " . $userids . ")";
                    $where_in .= " and a.smownerid in ( " . $userids . ")";
                    $where_book .=  " and a.smownerid in ( " . $userids . ")";
                }
                break;
            case 'SmOwner_Search_Group':
                $query = 'select userid from ld_users2group where groupid in (' . $_REQUEST['receiverid'] . ') group by userid';
                $result = $this->adb->pquery($query, array());
                $num_rows = $this->adb->num_rows($result);
                for ($i = 0; $i < $num_rows; $i++) {
                    $userid_array[] = $this->adb->query_result($result, $i, 'userid');
                }
                //zxm 2022-1111 常用报表改成报表分析的数据范围
                $ScopOfAuthority = ScopOfAuthority::getInstance($this->adb,$currentModule);
                $CurUserScopeId = $ScopOfAuthority->getCurUserScopeId();
                if ($CurUserScopeId == 'All') {
                    $intersection = $userid_array;
                } else {
                    $intersection = array_intersect($userid_array, $ScopOfAuthority->getUserModuleScopeHigher());
                }
                $userids = implode(',', $intersection);
                if (empty($userids)) $userids = 0;
                $where_product .= " and ld_products.smownerid in ( " . $userids . ")";
                $where_out .= " and a.smownerid in ( " . $userids . ")";
                $where_in .= " and a.smownerid in ( " . $userids . ")";
                $where_book .=  " and a.smownerid in ( " . $userids . ")";
                break;
            default:
                $where_product .= " and a.smownerid=" . $scope;
                $where_out .= " and a.smownerid=" . $scope;
                $where_in .= " and a.smownerid=" . $scope;
                $where_book .=  " and a.smownerid=" . $scope;
        }
        //时间条件
        $today = date('Y-m-d');
        //$today = '2021-09-10';//测试
        $where_out = $where_out ." and a.outdate='$today'";
        $where_in = $where_in ." and a.createdate='$today'";
        $where_book = $where_book ." and a.duedate='$today'";
        //查询排序条件
        $cvid_sql = 'select columnname,sorttype from ld_customview left join ld_cvcolumnlistsort on ld_customview.cvid= ld_cvcolumnlistsort.cvid where entitytype="Products" and viewname="All"';
        $cvid_res = $this->adb->pquery($cvid_sql);
        $cvid_nums = $this->adb->num_rows($cvid_res);
        $order_by_arr = [];
        $order_by_field = '';
        if($cvid_nums>0){
            for($j=0;$j<$cvid_nums;$j++){
                $columnname = $this->adb->query_result($cvid_res, $j, 'columnname');
                $sorttype = $this->adb->query_result($cvid_res, $j, 'sorttype');
                $columnname_arr = explode(':',$columnname);
                $order_by_arr[] = 'a.'.$columnname_arr[1].' '.$sorttype;
                $order_by_field = $columnname_arr[0].'.'.$columnname_arr[1].',';
            }
        }
        $order_by_str = empty($order_by_arr)?'order by a.qtyinstock desc':explode(',',$order_by_arr);
        $sql = "select 
a.*,ifnull(b.outnumber,0)as outnumber,ifnull(c.innumber,0)as innumber,ifnull(d.booknumber,0)as booknumber
 from 
 (
    select $order_by_field ld_products.product_no ,ld_productcf.cf_4158 ,ld_products.productname ,ld_products.productsheet ,
    ld_products.description as description,ld_products.qtyinstock ,ld_products.productid 
    from ld_products left join ld_productcf on ld_products.productid=ld_productcf.productid $where_product
) a left join 
 (
 select sum(ifnull(detail.quantity,0)) as outnumber,detail.productid from ld_outboundorder a left join 
 ld_outboundorderdetail detail on a.out_id=detail.id $where_out group by detail.productid
 ) 
 as b on a.productid=b.productid
 left join 
 (
 select sum(ifnull(detail.quantity,0)) as innumber,detail.productid from ld_stock a left join 
 ld_stockdetail detail on a.stock_id=detail.id $where_in group by detail.productid
 ) 
 as c on a.productid=c.productid
 left join 
 (
 select sum(ifnull(detail.quantity,0)) as booknumber,detail.productid from ld_salesorder a left join 
 ld_salesorderdetail detail on a.salesorderid=detail.id $where_book group by detail.productid
 )as d on a.productid=d.productid
  $order_by_str";
        $res = $this->adb->pquery($sql);
        $nums = $this->adb->num_rows($res);
        $list = [];
        if ($nums > 0) {
            for ($i = 0; $i < $nums; $i++) {
                foreach ($this->showcolLists as $fieldName => $v) {
                    $fieldName = explode(':', $fieldName)[0];
                    $start_len = strpos($fieldName, '_') + 1;
                    $fieldName = substr($fieldName, $start_len);
                    $list[$i][$fieldName] = $this->adb->query_result($res, $i, $fieldName);
                }
                $list[$i]['productid'] = $this->adb->query_result($res, $i, 'productid');
                $list[$i]['product_no'] = $this->adb->query_result($res, $i, 'product_no');
            }
            $html = "<tr>";
            foreach ($list as $k => $v) {
                $productid_temp = $v['productid'];
                $product_no_temp = $v['product_no'];
                $html .= "<tr>";
                foreach ($v as $kk => $vv) {
                    if($kk == "qtyinstock"||$kk == "outnumber"||$kk == "innumber"||$kk == "booknumber"){
                        $vv = !empty($vv)?floatval($vv):0;
                        $vv = number_format($vv,$lengthdecimaldigits);
                    }
                    //产品名称超链接
                    if($kk=="productname"){
                        $vv = '<a class="ld_list_href_name tip-items-list" lasturl="" fieldname="productname" module="Products" record="'.$productid_temp.'" href="javascript:;" onclick="ListLinkClick(ld(this),event)" data-tip="'.$vv.'" data-direction="top" data-type="position">'.$vv.'</a>';
                    }
                    //出库单超链接
                    if($kk=="outnumber"){
                        $vv = '<a class="ld_list_href_name tip-items-list" pageurl="index.php?pageto_module=OutboundOrder&pageto_action=index" module="OutboundOrder" product_no="'.$product_no_temp.'" onclick="setProductOverviewUrl(ld(this))">'.$vv.'</a>';
                    }
                    //入库单超链接
                    if($kk=="innumber"){
                        $vv = '<a class="ld_list_href_name tip-items-list" pageurl="index.php?pageto_module=Stock&pageto_action=index" module="Stock" product_no="'.$product_no_temp.'" onclick="setProductOverviewUrl(ld(this))">'.$vv.'</a>';
                    }
                    //订单超链接
                    if($kk=="booknumber"){
                        $vv = '<a class="ld_list_href_name tip-items-list" pageurl="index.php?pageto_module=SalesOrder&pageto_action=index" module="SalesOrder" product_no="'.$product_no_temp.'" onclick="setProductOverviewUrl(ld(this))">'.$vv.'</a>';
                    }
                    if($kk != "productid"&&$kk != "product_no"){
                        $html .= "<td style='text-align:left;' valign='top'>" . $vv . '</td>';
                    }
                }
                $html .= "</tr>";
            }
        }else{
            $html = "<tr>";
            foreach($this->showcolLists  as $fieldName=>$v){
                $html .= "<td style='text-align:left' valign='top'>-</td>";
            }
            $html .= "</tr>";
        }
        return $html;
    }


    private function ListViewFifty_five()
    {
        global $adb, $current_user, $currentModule, $mod_strings;

        $userids = $_REQUEST['receiverid'];

        if (empty($userids)) {
            $_REQUEST['startmonth'] = date("Y-m-d");
            $_REQUEST['endmonth'] = date("Y-m-d");
            $userids = $current_user->id;
        }
        if ($userids == 'SmOwner_Search_Me') {
            $userids = $current_user->id;
        }
        $sql = ' select * from ld_usertrack where userid=? and createdtime between ? and ? ';


        $startmonth = $_REQUEST['startmonth'] . ' 00:00:00';
        $endmonth = $_REQUEST['endmonth'] . ' 23:59:59';

        $sql .= "  order by createdtime asc ";

        $result = $this->adb->pquery($sql, array($userids, $startmonth, $endmonth));
        $count = 0;
        for ($i = 0; $i < $this->adb->num_rows($result); $i++) {
            $lat = $this->adb->query_result($result, $i, 'latitude');
            $lng = $this->adb->query_result($result, $i, 'longtitude');
            $address = $this->adb->query_result($result, $i, 'address');
            $distince = $this->adb->query_result($result, $i, 'distince');
            $createdtime = $this->adb->query_result($result, $i, 'createdtime');
            if (!empty($address)) {
                if ($count > 0 && $distince == 0) {
                    continue;
                }
                $points[] = array('lng' => $lng, 'lat' => $lat, 'address' => $address, 'distince' => $distince, 'createdtime' => $createdtime);
                if ($distince == 0) {
                    $count += 1;
                } else {
                    $count = 0;
                }
            }

        }


        return json_encode($points);

    }

    /**
     * edit:chj
     * date:2015-5-12
     * reason:应收账款汇总表
     * */
    private function ListViewTable()
    {
        $receivable = $this->getAccountingReceivable();
        $recelen = count($receivable);
        $class = '';
        $Fvalue = '';
        if (!empty($receivable)) {
            foreach ($receivable as $recInfo) {
                $valtemplate .= "<tr>";
                if ($recInfo['FName'] == '合计') {
                    $class = "Alltotal";
                } else {
                    $class = '';
                }
                foreach ($recInfo as $Fname => $Fval) {
                    if ($Fname == 'FName') {
                        if ($this->mouthlen > 1) {
                            if ($Fval != $Fvalue)
                                $valtemplate .= "<td class='$class' style='text-align:left' valign='top' rowspan='" . $this->mouthlen . "' >" . $Fval . '</td>';
                        } else {
                            $valtemplate .= "<td class='$class' style='text-align:left' >" . $Fval . '</td>';
                        }
                        $Fvalue = $Fval;
                    } else if ($Fname == 'FPeriod') {
                        $valtemplate .= "<td class='$class' style='text-align:left' >" . $Fval . '</td>';
                    } else {
                        $valtemplate .= "<td class='$class' style='text-align:right'  >" . $Fval . '</td>';
                    }
                }
                $valtemplate .= "</tr>";
            }
        }
        return $valtemplate;
    }

    /**
     * edit:can
     * date:20131106
     * reason:reporttype:10
     * */
    private function ListViewten()
    {
        $this->clearTempotatyTable();
        //$this->getSQLs();

        $SQL = ReportSQL::getReportSQL($this->reportname, $this->reporttabid);
        $result = $this->adb->query($SQL);

        $y = $this->adb->num_fields($result);
        $custom_field_values = $this->adb->fetch_array($result);

        $reportabname = getTabname($this->reporttabid);
        $total_row = 0;
        //单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
        if (isset($sysdeploy['deploy_value']))
            $lengthdecimaldigits = $sysdeploy['deploy_value'];
        else
            $lengthdecimaldigits = 2;
        $decimaledreport = false;
        if ($this->reportname == 'Performancestatisticscollection') {
            $decimaledreport = true;
        }
        $i = 0;
        $userobj=new Users();
        $groupobj=new stdClass();

        do {
            $isSubtotal = false;
            $isTotalAll = false;
            if (strstr($custom_field_values[0], getFixedLabel('SUBTOTAL'))) {
                
                $isSubtotal = true;
                $total_row++;
            }
            if (strstr($custom_field_values[0], getFixedLabel('TOTAL'))) {
                $isTotalAll = true;
                $total_row++;
            }
            $arraylists = Array();
            $newvalue = $custom_field_values[0];

            if ($this->reportname == 'Performancestatisticscollection') {
                $newvalue2 = $custom_field_values[1];
                $newvalue3 = $custom_field_values[3];
                $newvalue4 = $custom_field_values[4];
                $newvalue6 = $custom_field_values[6];
                $newvalue7 = $custom_field_values[7];
                $newvalue8 = $custom_field_values[2];
                $newvalue9 = $custom_field_values[5];
            }
            if ($newvalue == "") $newvalue = "-";

            if ($i % 2 == 0) {
                $valtemplate .= "<tr id='report_$i' class='lvtColData' onmouseover='listOnMouseOver(ld(this))' onmouseout=listOnMouseOut(ld(this),'on')>";
            } else {
                $valtemplate .= "<tr id='report_$i' class='lvtColDataBj' onmouseover='listOnMouseOver(ld(this))' onmouseout=listOnMouseOut(ld(this),'On')>";
            }
            $i++;
            $startcol=0;
            foreach ($this->showcolLists as $temp_val => $keyother) {
                $fieldkeys = explode(':', $temp_val);
                $typeofdata = $fieldkeys[1];
                $temp_val = $fieldkeys[0];
                $fieldvalue = trim((string)$custom_field_values[strtolower($temp_val)]);
                $typeofdata = $fieldkeys[1];
                $typeofdata_decimal = $fieldkeys[2];
                if(in_array($temp_val,array('OftenUseReport_PaymentBalance','OftenUseReport_PaymentPlanBalance','OftenUseReport_CashBillamount',
                'OftenUseReport_SendCashBillamount','OftenUseReport_SendCashBillbalance','OftenUseReport_InvoiceBalance',
                'oftenusereport_SendCashBillamount','oftenusereport_SendCashBillBalance','OftenUseReport_SendPaymentBalance'))){
                    $typeofdata_decimal = $this->system_deploy_351;
                }
                //&&array_key_exists('report_wx_groupid',$custom_field_values)
              
                if($temp_val=='SalesOrder_smownerid'&&array_key_exists('report_wx_userid',$custom_field_values)){
                    
                    $userobj->wx_userid=$custom_field_values['report_wx_userid'];
                    $userobj->last_name=$fieldvalue;
                    $fieldvalue=getUserlastName($userobj);
                    if(!$isSubtotal)
                        $last_wx_userid=$custom_field_values['report_wx_userid'];
                }
                else if($temp_val=='OftenUseReport_groupname'&&array_key_exists('report_wx_groupid',$custom_field_values)){
                    
                   
                    $tmp_groupids=explode(',',$custom_field_values['report_wx_groupid']);
                   
                    $tmp_groupnames=explode(',',$fieldvalue);
                    $arr_groupname=array();
                    foreach($tmp_groupids as $tmpgroupindex=>$tmpgroupid){
                        
                          $groupobj->groupname=$tmp_groupnames[$tmpgroupindex];
                         
                          $groupobj->groupid=$tmpgroupid;

                          $arr_groupname[]=getWx_GroupName($groupobj);
                          
                          
                    }
                  
                    $fieldvalue=implode(",",$arr_groupname);
                      
                }
                
                //echo strtolower($temp_val).'@'.$fieldvalue.'<br>';
                if (strtolower($typeofdata) == 'd' || strtolower($typeofdata) == 'dt') {

                    if (date('Y-m-d', strtotime($fieldvalue)) < '1600-01-01' || $fieldvalue < '1600-01-01' || $fieldvalue == '0000-00-00') {

                        $fieldvalue = '-';
                    }
                }

                if (trim($fieldvalue) == "") {
                    $fieldvalue = "-";
                }
                if ($temp_val == 'lbl_action' && $isSubtotal != true && $isTotalAll != true && trim($fieldvalue) != '-' && trim($fieldvalue) != '') {

                    if ($this->reportname == 'SalesOrderTrack' || $this->reportname == 'CashBillSum_SalesOrder' || $this->reportname == 'CashBillSum_Outboundorder') {
                        $viewtype = substr($fieldvalue, -1);

                        if ($viewtype == 'S') {
                            $reportabname = 'ServiceContracts';
                        } else {
                            $reportabname = 'SalesOrder';
                        }
                        $fieldvalue = substr($fieldvalue, 0, -1);
                    }
                    //22285: 常用报表>合同跟踪表：个人用户登录后，点击服务合同单据，界面出现的提示不对
                    if ($this->advfilter == 1)//有高级查询
                    {
                        $reportabname = getTabname($this->reporttabid);
                    }
                    $reportMoudlename = getSalesEntityType(trim($fieldvalue));

                    /*$valtemplate .= '<td>
                                <a target=\'_blank\' href=\'index.php?module=' . $reportMoudlename . '&action=DetailView&record=' . trim($fieldvalue) . '\'>' . getFixedLabel('VIEWDETAILS') . '</a></td>';
                           */
                        $valtemplate.="<td> <a href='javascript:;' referencemodule='$reportMoudlename' referencerecord='$fieldvalue' onclick='ListReferenceLinkClick(ld(this),event)'> " .getFixedLabel('VIEWDETAILS') . '</a></td>';
                           
                                

                    continue;
                }

                if (((($lastvalue2 == $fieldvalue) && $temp_val == 'CashBill_last_name')
                        || ((($lastvalue3 == $fieldvalue) && $temp_val == 'CashBill_cashbilldate'))
                        || ((($lastvalue4 == $fieldvalue) && $temp_val == 'CashBill_total'))
                        || ((($lastvalue6 == $fieldvalue) && $temp_val == 'SaleSorder_subject'))
                        || ((($lastvalue7 == $fieldvalue) && $temp_val == 'SaleSorder_salesorder_no'))
                        || ((($lastvalue8 == $fieldvalue) && $temp_val == 'CashBill_cashbill_no'))
                        || ((($lastvalue9 == $fieldvalue) && $temp_val == 'Accounts_accountname'))
                    )
                    && $this->reportname == 'Performancestatisticscollection') {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right'>&nbsp;</td>";
                        } else

                            $valtemplate .= "<td  style='text-align:right'>&nbsp;</td>";
                    } else {
                        if ($isSubtotal)
                            $valtemplate .= "<td class='Subtotal'>&nbsp;</td>";
                        else
                            $valtemplate .= "<td >&nbsp;</td>";
                    }
                } else {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {

                        /**
                         * @project PROT75 数量小数位数
                         * @author Tujt 2014-08-14
                         */
                        $fld = explode('_', $temp_val);
                        //采购订单跟踪表 、 应付款统计表 - 按采购订单统计、应付款统计表 - 按付款计划统计
                        if ($this->reportname == 'PurchaseOrderTrack' || $this->reportname == 'SendCashBillSum_PurchaseOrder'
                            || $this->reportname == 'SendCashBillSum_SendPayment')
                            $currency_symbol = $custom_field_values['purchaseorder_symbol'];
                        else
                            $currency_symbol = $custom_field_values['salesorder_symbol'];
                        
                        if ($decimaledreport && $fld[1] == 'quantity') {
                            $fieldvalue = setNumberFormat($fieldvalue, $lengthdecimaldigits);
                        } else {
                            //chj:小计、统计行，默认币种为人民币
                            //echo $temp_val . '<br>';
                            if ($isTotalAll == true || $isSubtotal == true) {
                                if ($fieldvalue == '' || $fieldvalue == '-') {
                                    $fieldvalue = 0.00;
                                }
                                if ($this->reportname == 'SalesOrderTrack' && $temp_val == 'OftenUseReport_GrossProfitl')
                                    $fieldvalue = setNumberFormat($fieldvalue,$typeofdata_decimal);
                                else if ($this->reportname == 'SalesOrderTrack' && $temp_val == 'SalesOrder_totalquantity')
                                    $fieldvalue = setNumberFormat($fieldvalue,$typeofdata_decimal);
                                else if ($this->reportname == 'SalesOrderTrack' && $temp_val == 'SalesOrder_approvestatus')
                                    $fieldvalue = '';
                                else
                                    $fieldvalue = getDefaultCurrecySymbol() . setNumberFormat($fieldvalue,$typeofdata_decimal);
                            } else {
                                //佣金金额、销售发票合计、费用金额、已收款金额、应收款余额、毛利
                                if ($this->reportname == 'SalesOrderTrack' && ($temp_val == 'OftenUseReport_amount'
                                        || $temp_val == 'Invoice_total' || $temp_val == 'OftenUseReport_Expenseamount'
                                        || $temp_val == 'OftenUseReport_CashBillamount' || $temp_val == 'OftenUseReport_PaymentPlanBalance'
                                        || $temp_val == 'OftenUseReport_InvoiceBalance' || $temp_val == 'OftenUseReport_TotalCost' || $temp_val == 'OftenUseReport_GrossProfit' || $temp_val == 'OftenUseReport_GrossProfitl'|| $temp_val == 'SalesOrder_totalquantity'|| $temp_val == 'SalesOrder_approvestatus')) {
                                    //毛利率不加币种符号
                                    if ($temp_val == 'OftenUseReport_GrossProfitl'||$temp_val == 'SalesOrder_totalquantity'||$temp_val == 'SalesOrder_approvestatus')
                                        $currency_symbol = '';
                                    else
                                        $currency_symbol = getDefaultCurrecySymbol();
                                } else if ($this->reportname == 'CashBillSum_Paymentplan') {// 应收款统计表_按回款计划统计
                                    //回款计划金额
                                    if ($temp_val == 'PaymentPlan_amount')
                                        $currency_symbol = $custom_field_values['paymentplan_symbol'];
                                    elseif ($temp_val == 'PaymentPlan_actualamount')//回款计划已收金额
                                    {
                                        if ($custom_field_values['cashbill_symbol'] != '') {
                                            $currency_symbol = $custom_field_values['cashbill_symbol'];
                                        } else {
                                            $currency_symbol = $custom_field_values['paymentplan_symbol'];
                                        }

                                    } elseif ($temp_val == 'OftenUseReport_PaymentPlanBalance')//应收款余额
                                        $currency_symbol = getDefaultCurrecySymbol();
                                } else if ($this->reportname == 'CashBillSum_SalesOrder') {// 应收款统计表_按订单统计
                                    //回款计划金额
                                    if ($temp_val == 'OftenUseReport_CashBillamount' || $temp_val == 'OftenUseReport_PaymentBalance')//已收金额
                                        $currency_symbol = $custom_field_values['salesorder_symbol'];
                                    //zxm 20230710 应收款统计表_按合同统计 已收金额 应收余额币种符号应该跟单据币种保持一致
                                } else if ($this->reportname == 'PurchaseOrderTrack')//采购订单跟踪表
                                {
                                    if ($temp_val == 'OftenUseReport_SendCashBillamount')    //已付款金额
                                        $currency_symbol = getDefaultCurrecySymbol();
                                    if ($temp_val == 'OftenUseReport_SendCashBillbalance')    //应付款余额
                                        $currency_symbol = getDefaultCurrecySymbol();
                                    if ($temp_val == 'OftenUseReport_InvoiceBalance')    //开票余额
                                        $currency_symbol = getDefaultCurrecySymbol();
                                } else if ($this->reportname == 'SendCashBillSum_PurchaseOrder')//应付款统计表 - 按采购订单统计
                                {
                                    if ($temp_val == 'oftenusereport_SendCashBillamount' || $temp_val == 'oftenusereport_SendCashBillBalance')    //已付款金额
                                        $currency_symbol = getDefaultCurrecySymbol();
                                } else if ($this->reportname == 'SendCashBillSum_SendPayment')//应付款统计表 - 按付款计划统计
                                {
                                    if ($temp_val == 'SendPayment_amount')
                                        $currency_symbol = $custom_field_values['sendpayment_symbol'];
                                    elseif ($temp_val == 'SendPayment_actualamount')
                                        $currency_symbol = $custom_field_values['sendpayment_symbol'];
                                    elseif ($temp_val == 'OftenUseReport_SendPaymentBalance')
                                        $currency_symbol = getDefaultCurrecySymbol();
                                } elseif ($this->reportname == 'CashBillSum_Outboundorder') {// 应收款统计表_按出库单统计
                                    //ls 2022-06-22 BUG0052853:常用表单》“应收款统计表_按销售出库单统计”没有币种符号
                                    if ($custom_field_values['outboundorder_symbol'] != '') {
                                        $currency_symbol = $custom_field_values['outboundorder_symbol'];
                                    } else {
                                        $currency_symbol = getDefaultCurrecySymbol();
                                    }
                                }

                                if ($fieldvalue == '' || $fieldvalue == '-') {

                                    $fieldvalue = 0.00;
                                }
                                $fieldvalue = $currency_symbol . setNumberFormat($fieldvalue,$typeofdata_decimal);
                            }

                        }
                        if ($isSubtotal == true) {
                            if ($this->reportname == 'SalesOrderTrack' && $temp_val == 'OftenUseReport_GrossProfitl') {
                                $valtemplate .= "<td class='Subtotal' style='text-align:right' >" . $fieldvalue . "%</td>";
                            } else {
                                $valtemplate .= "<td class='Subtotal' style='text-align:right' >" . $fieldvalue . "</td>";
                            }
                        } else {
                            if ($isTotalAll == true) {
                                if ($this->reportname == 'SalesOrderTrack' && $temp_val == 'OftenUseReport_GrossProfitl') {
                                    $valtemplate .= "<td class='Alltotal' style='text-align:right' >" . $fieldvalue . "%</td>";
                                } else {
                                    $valtemplate .= "<td class='Alltotal' style='text-align:right' >" . $fieldvalue . "</td>";
                                }
                            } else {
                                if ($this->reportname == 'SalesOrderTrack' && $temp_val == 'OftenUseReport_GrossProfitl') {
                                    $valtemplate .= "<td style='text-align:right' >" . $fieldvalue . "%</td>";
                                } else {
                                    $valtemplate .= "<td style='text-align:right' >" . $fieldvalue . "</td>";
                                }

                            }

                        }
                    } else {
                        if ($isSubtotal == true) {
                            if($startcol==0)
                            {
                               // $userobj=new Users();
                                 $userobj->wx_userid=$last_wx_userid;
                                  $userobj->last_name=$fieldvalue;
                                 $fieldvalue=getUserlastName($userobj) ;
                                 if(stripos($fieldvalue,'ww-open-data')!==false)
                                     $valtemplate .= "<td class='Subtotal'>" . getUserlastName($userobj) .'-'.getFixedLabel('SUBTOTAL')."</td>";
                                 else
                                     $valtemplate .= "<td class='Subtotal'>" . getUserlastName($userobj) . "</td>";
                            }
                            else{
                                $valtemplate .= "<td class='Subtotal'>" . $fieldvalue . "</td>";
                            }
                            $startcol++;
                        } else {
                            if ($isTotalAll == true) {
                                $valtemplate .= "<td class='Alltotal'>" . $fieldvalue . "</td>";
                            } else {
                                /**
                                 * cme
                                 * 供应商超链接
                                 * */
                                if ($this->reportname == 'PurchaseOrderTrack' && $temp_val == 'Vendors_vendorname') {
                                    $vendors_vendorid = $custom_field_values['vendors_vendorid'];
                                    $reportabname = 'Vendors';
                                   // $valtemplate .= '<td>&nbsp;<a target=\'_blank\' href=\'index.php?module=' . $reportabname . '&action=DetailView&record=' . trim($vendors_vendorid) . '\'>' . $fieldvalue . '</a></td>';
                                    
                                    $valtemplate.="<td> &nbsp;<a href='javascript:;' referencemodule='$reportabname' referencerecord='$vendors_vendorid' onclick='ListReferenceLinkClick(ld(this),event)'> " .$fieldvalue . '</a></td>';
                                } elseif ($this->reportname == 'PurchaseOrderTrack' && $temp_val == 'PurchaseOrder_purchaseorder_No') {
                                    $purchaseorder_id = trim(substr($custom_field_values['lbl_action'], 0, -1));
                                    $reportabname = getSalesEntityType(trim($purchaseorder_id));
                                    //$valtemplate .= '<td>&nbsp;<a target=\'_blank\' href=\'index.php?module=' . $reportabname . '&action=DetailView&record=' . trim($purchaseorder_id) . '\'>' . $fieldvalue . '</a></td>';
                                    $valtemplate.="<td> &nbsp;<a href='javascript:;' referencemodule='$reportabname' referencerecord='$purchaseorder_id' onclick='ListReferenceLinkClick(ld(this),event)'> " .$fieldvalue . '</a></td>';
                                } else {
                                    if ($this->reportname == 'CashBillSum_Paymentplan' && $temp_val == 'PaymentPlan_accountid' && $fieldvalue != '' && $fieldvalue != '-') {//应收款统计表_按回款计划 客户字段超链接
                                        $vendors_vendorid = $custom_field_values['paymentplan_accountid_id'];
                                        $reportabname = 'Accounts';
                                        //$valtemplate .= '<td>&nbsp;<a target=\'_blank\' href=\'index.php?module=' . $reportabname . '&action=DetailView&record=' . trim($vendors_vendorid) . '\'>' . $fieldvalue . '</a></td>';
                                        $valtemplate.="<td> &nbsp;<a href='javascript:;' referencemodule='$reportabname' referencerecord='$vendors_vendorid' onclick='ListReferenceLinkClick(ld(this),event)'> " .$fieldvalue . '</a></td>';
                                        
                                    } elseif ($this->reportname == 'CashBillSum_SalesOrder' && $temp_val == 'SalesOrder_accountid' && $fieldvalue != '' && $fieldvalue != '-') {//应收款统计表_按合同统计 客户字段超链
                                        $accountid = $custom_field_values['salesorder_accountid_id'];
                                        $reportabname = 'Accounts';
                                       // $valtemplate .= '<td>&nbsp;<a target=\'_blank\' href=\'index.php?module=' . $reportabname . '&action=DetailView&record=' . trim($accountid) . '\'>' . $fieldvalue . '</a></td>';
                                        $valtemplate.="<td>&nbsp;<a href='javascript:;' referencemodule='$reportabname' referencerecord='$accountid' onclick='ListReferenceLinkClick(ld(this),event)'> " .$fieldvalue . '</a></td>';
                                    } elseif ($this->reportname == 'SendCashBillSum_SendPayment' && $temp_val == 'SendPayment_vendorid' && $fieldvalue != '' && $fieldvalue != '-') {
                                        $vendors_vendorid = $custom_field_values['sendpayment_vendorid_id'];
                                        $reportabname = 'Vendors';
                                       // $valtemplate .= '<td>&nbsp;<a target=\'_blank\' href=\'index.php?module=' . $reportabname . '&action=DetailView&record=' . trim($vendors_vendorid) . '\'>' . $fieldvalue . '</a></td>';
                                       $valtemplate.="<td>&nbsp;<a href='javascript:;' referencemodule='$reportabname' referencerecord='$vendors_vendorid' onclick='ListReferenceLinkClick(ld(this),event)'> " .$fieldvalue . '</a></td>';
                                    } elseif ($this->reportname == 'SendCashBillSum_PurchaseOrder' && $temp_val == 'PurchaseOrder_vendorid' && $fieldvalue != '' && $fieldvalue != '-') {
                                        $vendors_vendorid = $custom_field_values['purchaseorder_vendorid_id'];
                                        $reportabname = 'Vendors';
                                        //$valtemplate .= '<td>&nbsp;<a target=\'_blank\' href=\'index.php?module=' . $reportabname . '&action=DetailView&record=' . trim($vendors_vendorid) . '\'>' . $fieldvalue . '</a></td>';
                                        $valtemplate.="<td>&nbsp;<a href='javascript:;' referencemodule='$reportabname' referencerecord='$vendors_vendorid' onclick='ListReferenceLinkClick(ld(this),event)'> " .$fieldvalue . '</a></td>';
                                    } elseif ($this->reportname == 'SalesOrderTrack' && $temp_val == 'SalesOrder_accountid' && $fieldvalue != '' && $fieldvalue != '-') {
                                        $accountid = $custom_field_values['salesorder_accountid_id'];
                                        $reportabname = 'Accounts';
                                       // $valtemplate .= '<td>&nbsp;<a target=\'_blank\' href=\'index.php?module=' . $reportabname . '&action=DetailView&record=' . trim($accountid) . '\'>' . $fieldvalue . '</a></td>';
                                       $valtemplate.="<td>&nbsp;<a href='javascript:;' referencemodule='$reportabname' referencerecord='$accountid' onclick='ListReferenceLinkClick(ld(this),event)'> " .$fieldvalue . '</a></td>';
                                    } elseif ($this->reportname == 'SalesOrderTrack' && $temp_val == 'SalesOrder_salesorder_no' && $fieldvalue != '' && $fieldvalue != '-') {
                                        $salesorder_id = substr($custom_field_values['lbl_action'], 0, -1);
                                        $reportabname = getSalesEntityType(trim($salesorder_id));
                                        //$valtemplate .= '<td>&nbsp;<a target=\'_blank\' href=\'index.php?module=' . $reportabname . '&action=DetailView&record=' . trim($salesorder_id) . '\'>' . $fieldvalue . '</a></td>';
                                        $valtemplate.="<td>&nbsp;<a href='javascript:;' referencemodule='$reportabname' referencerecord='$salesorder_id' onclick='ListReferenceLinkClick(ld(this),event)'> " .$fieldvalue . '</a></td>';
                                    } else {
										//echo $temp_val;echo '<br><br>';
										if('PaymentPlan_smownerid' == $temp_val || 'salesorder_smownerid' == $temp_val || 'OutboundOrder_smownerid' == $temp_val || 'PurchaseOrder_smownerid' == $temp_val|| 'SendPayment_smownerid' == $temp_val){
											
											$userobj->wx_userid=$custom_field_values['report_wx_userid'];
											$userobj->last_name=$fieldvalue;
											$fieldvalue=getUserlastName($userobj);
										}
										
										if('PaymentPlan_groupname' == $temp_val || 'SalesOrder_groupname' == $temp_val || 'OutboundOrder_groupname' == $temp_val || 'PurchaseOrder_groupname' == $temp_val|| 'SendPayment_groupname' == $temp_val){
											$groupobj=new Group();
											$groupobj->groupid=$custom_field_values['report_wx_groupid'];
											$groupobj->groupname=$fieldvalue;
											$fieldvalue=getWx_GroupName($groupobj);
										}
	
                                        $valtemplate .= "<td>&nbsp;" . $fieldvalue . "</td>";
                                    }//

                                }

                            }
                        }
                    }

                }
            }
            $valtemplate .= "</tr>";
            $lastvalue = $newvalue;

            $arr_val[] = $arraylists;
            $isSubtotal = false;
        } while ($custom_field_values = $this->adb->fetch_array($result));
        $valtemplate .= "</tr>";

        return $valtemplate;
    }
    //签到统计表重写
    protected function signinStatistics(){

    }
    //签到统计表
    private function ListViewFifty()
    {
        global $adb, $current_user, $currentModule, $mod_strings;
        $sql = $this->ListViewFiftySql();
        $result = $this->adb->query($sql, array());
        $isexport = 'no';
        if($_REQUEST['Export']==true&&isKehu001ServerPc()=='yes'){
            $isexport = 'yes';
        }
        $y = $this->adb->num_fields($result);
        $custom_field_values = $this->adb->fetch_array($result);
        $total_row = $this->adb->num_rows($result);;
        $i = 0;
        $valtemplate = '';
        //echo $sql;
        $userobj=new Users();
        $count=0;
        if($this->get_progress == 'yes'){
            $_SESSION[$currentModule][$current_user->id]['exportReport']['total_row'] = $total_row;
        }
        do {
            //edit:duan date:2024/12/11 reason:报表增加分页导出功能
            if($this->get_progress == 'yes'){
                if($i < $this->start_row || $i>= $this->end_row){
                    $i++;
                    $newvalue = $custom_field_values[0];
                    $oftenusereport_last_name = $custom_field_values['oftenusereport_last_name'];
                    $oftenusereport_real_name = $custom_field_values['oftenusereport_real_name'];
                    $oftenusereport_wx_userid = $custom_field_values['oftenusereport_wx_userid'];
                    if($oftenusereport_last_name_last!=$oftenusereport_last_name&&$i>0){
                        $count = 1;
                    }else if(!empty($oftenusereport_last_name)){
                        $count = $count+1;
                    }
                    $oftenusereport_last_name_last = $oftenusereport_last_name;
                    $oftenusereport_real_name_last = $oftenusereport_real_name;
                    $oftenusereport_wx_userid_last = $oftenusereport_wx_userid;
                    $lastvalue = $newvalue;
                    continue;
                }
            }

            $arraylists = Array();
            // @edit:dong @date:2020/08/24 @reason: bug0042482 模块管理中关闭模块后， 签到统计表中也应该不显示该模块
            if(!empty($custom_field_values['oftenusereport_record'] )){
                $singin_module = getSalesEntityType($custom_field_values['oftenusereport_record']);
                if(!vtlib_isModuleActive($singin_module)) continue;
            }
            $newvalue = $custom_field_values[0];
            //wyt 220623 签到统计表新增个人小计列
            $oftenusereport_last_name = $custom_field_values['oftenusereport_last_name'];
            $oftenusereport_real_name = $custom_field_values['oftenusereport_real_name'];
            $oftenusereport_wx_userid = $custom_field_values['oftenusereport_wx_userid'];

            if($oftenusereport_last_name_last!=$oftenusereport_last_name&&$i>0){
                if($isexport=='yes'){
                    $fieldvalue = $oftenusereport_real_name_last;
                }else{
                    $userobj->wx_userid=$oftenusereport_wx_userid_last;
                    $userobj->last_name=$oftenusereport_last_name_last;
                    $fieldvalue=getUserlastName($userobj);
                }

                $valtemplate .= '<tr><td class="Subtotal">'.$fieldvalue.'-'.getFixedLabel('SUBTOTAL').'</td><td class="Subtotal">'.$count.getFixedLabel('TIME1').'</td>';
                $countcolumn = sizeof($this->showcolLists)-2;
                for($j=0;$j<$countcolumn;$j++){
                    $valtemplate .='<td class="Subtotal">-</td>';
                }
                $valtemplate .= '</tr>';
                $count = 1;

            }else if(!empty($oftenusereport_last_name)){
                $count = $count+1;
            }
            if ($newvalue == "") $newvalue = "-";
            if ($i % 2 == 0) {
                $valtemplate .= "<tr id='report_$i' class='lvtColData'  onmouseover='listOnMouseOver(ld(this))' onmouseout=listOnMouseOut(ld(this),'on')>";
            } else {
                $valtemplate .= "<tr id='report_$i' class='lvtColDataBj'  onmouseover='listOnMouseOver(ld(this))' onmouseout=listOnMouseOut(ld(this),'On')>";
            }
            $account_longtitude = '-1';
            $account_latitude = '-1';
            $sign_latitude = '-1';
            $sign_longtitude = '-1';
            $accountid = 0;
            $signid = $custom_field_values['oldsignid'];
            $distince = $custom_field_values['distince'];
            $accountid = $custom_field_values['accountid'];
            $newsignid = $custom_field_values['newsignid'];
            $signoutid = $custom_field_values['signout_id'];

            $i++;
            //$sign_img = $this->getAttachmentsSignImage($signid);
            $sign_img = $this->getnewAttachmentsSignImage($newsignid);
            $signout_img = $this->getnewAttachmentsSignoutImage($signoutid);
			foreach ($this->showcolLists as $temp_val => $keyother) {
				$temp_val = explode(':', $temp_val);                
				$typeofdata = $temp_val[1];
                $temp_val = $temp_val[0];
                $fieldvalue = '';
                //操作按钮
                if (stripos($temp_val, '_action') !== false) {
                    $valtemplate .= '<td>';
                    if (!empty($signid)) $valtemplate .= '<a href=\'javascript:void(1)\' onclick="sign_recalculate(this,' . $signid . ')">' . getFixedLabel('RECALCULATED') . ' </a>';
                    $valtemplate .= '</td>';

                    continue;
                }
                //查看图片
                //@edit:liushuai,2020-12-21,reason:【ID1001187】签到统计表增加【图片】列，将操作列中的【查看图片（n）】显示在【图片】列中
                if (stripos($temp_val, 'OftenUseReport_picture') !== false) {
                    $valtemplate .= '<td>';
                    //edit: xll 2023/08/02 BUG0067515 kfbcrm-报表分析-可视化分析-导出签到统计表-图片类型字段导出错误
                    if(isset($this->export_type) && !empty($this->export_type)){
                        $valtemplate .= 'isImageField//:/';
                        foreach ($sign_img as $imgs) {
                            $valtemplate .= $imgs['id'] . '//,/';
                            $valtemplate .= $imgs['img'] . '//;/';
                        }
                    }
                    else{
                        if (sizeOf($sign_img) > 0) {
                            $valtemplate .= '<a href=\'javascript:void(1)\' onclick="signimg_preview(' . $signid . ')">' . getFixedLabel('PREVIEWPICTURE') . '(' . sizeof($sign_img) . ')' . '</a>';
                            $valtemplate .= '<div style="display:none;" id="signimage_' . $signid . '">';
                            $valtemplate .= '<div class="ui-cont-list relation-list ">';
                            foreach ($sign_img as $imgs) {
                                $valtemplate .= '<span achmentid="' . $imgs['id'] . '">';
                                $valtemplate .= '<img class="" style="height: 67px; width: 106px; cursor: pointer;" src="' . $imgs['img'] . '" alt="">';
                                $valtemplate .= '</span>';
                            }
                            $valtemplate .= '</div></div>';
                        }else{
                            $valtemplate .= "-";
                        }
                    }
                    $valtemplate .= '</td>';
                    continue;
                }
                //2024-4-3 xxy 签退图片
                if (stripos($temp_val, 'OftenUseReport_signout_imagename') !== false) {
                    $valtemplate .= '<td>';
                    //edit: xll 2023/08/02 BUG0067515 kfbcrm-报表分析-可视化分析-导出签到统计表-图片类型字段导出错误
                    if(isset($this->export_type) && !empty($this->export_type)){
                        $valtemplate .= 'isImageField//:/';
                        foreach ($signout_img as $imgs) {
                            $valtemplate .= $imgs['id'] . '//,/';
                            $valtemplate .= $imgs['img'] . '//;/';
                        }
                    }
                    else{
                        if (sizeOf($signout_img) > 0) {
                            $valtemplate .= '<a href=\'javascript:void(1)\' onclick="signimg_preview(' . $signid . ')">' . getFixedLabel('PREVIEWPICTURE') . '(' . sizeof($signout_img) . ')' . '</a>';
                            $valtemplate .= '<div style="display:none;" id="signimage_' . $signid . '">';
                            $valtemplate .= '<div class="ui-cont-list relation-list ">';
                            foreach ($signout_img as $imgs) {
                                $valtemplate .= '<span achmentid="' . $imgs['id'] . '">';
                                $valtemplate .= '<img class="" style="height: 67px; width: 106px; cursor: pointer;" src="' . $imgs['img'] . '" alt="">';
                                $valtemplate .= '</span>';
                            }
                            $valtemplate .= '</div></div>';
                        }else{
                            $valtemplate .= "-";
                        }
                    }
                    $valtemplate .= '</td>';
                    continue;
                }
                if (stripos($temp_val, 'OftenUseReport_distance') !== false || stripos($temp_val, '_bill_street') !== false) {
                    $sign_address = $custom_field_values['oftenusereport_address']??'';//签到地址


                    $province = $custom_field_values['bill_state']??'';
                    $address = $custom_field_values['oftenusereport_bill_street']??'';
                    $city = $custom_field_values['bill_city']??'';
                    //editor:gyq_20190408 reason:0036480: 常用报表>签到统计表>拜访地址（CRM系统数据）：判断客户上的区域字段， 如果客户模块有显示，则要加上这个域名栏目
                    $bill_area = $custom_field_values['bill_area']??'';
                    //给$detail_address赋初值
                    $detail_address = $address;
                    //当客户模块街道信息模糊不全时，判断后补全,并给$detail_address重新赋值 Begin
                    if (stripos($address, $bill_area) === false && !empty($bill_area) && $bill_area != '--无--') {
                        $address = trim($bill_area) . $address;
                    }
                    if (stripos($address, $city) === false && !empty($city) && $city != '--无--') {
                        $detail_address = trim($city) . $address;
                    }
                    if (stripos($detail_address, $province) === false && !empty($province) && $province != '--无--') {
                        $detail_address = trim($province) . $detail_address;
                    }
                    //当客户模块街道信息模糊不全时，判断后补全,并给$detail_address重新赋值 End
                    if (empty($custom_field_values['accountid'])) {
                        $detail_address = $custom_field_values['entityaddress'];
                    }

                }
                if (stripos($temp_val, 'OftenUseReport_distance') !== false) {
                    //editor:gyq_20181217 	0035793: （51mis.com/kfbcrm）常用报表>签到统计表：当签到地址跟拜访地址一样的情况下签到“误差”显示为“无法计算”，当点击重新计算后误差显示为“0”（需要补丁）
                    //17796: 常用报表->签到报表->添加重新计算按钮
                    if ((!empty($distince) || $distince === '0') && !isset($_REQUEST['recalculated_distance']) && $_REQUEST['recalculated_distance'] != 'yes') {
                        //$valtemplate .= "<td  style='text-align:right'>$distince</td> ";
                        //zkt 20220530 52308（https://61mis.com/order/index.php）常用报表》签到统计表，误差值，需显示成千分位格式，方便查看数值
                        $tmpdistince=number_format(floatval($distince),0,'.',',');
                        $valtemplate .= "<td tag='distance' style='text-align:right'>$tmpdistince</td> ";
                        continue;
                    }
                    $sign_latitude = $custom_field_values['latitude'];//签到纬度
                    $sign_longtitude = $custom_field_values['longtitude'];//签到经度
                    if (!empty($sign_address) && $account_longtitude != '-1' && $_REQUEST['Export'] != 'true' && $accountid > 0)//导出不需要重新获取经纬度
                    {
                        //$signfilecontent=file_get_contents("http://api.map.baidu.com/geocoder/v2/?address=".urlencode($sign_address)."&output=json&ak=Hgvb6X18khZw223dBW1hFHuT");
                        //$signfilecontent=file_get_contents("https://apis.map.qq.com/ws/geocoder/v1/?address=".$sign_address."&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X");
                        $signAddressInfos = getCoordinateByTecentApi($sign_address);
                        $second_sign_latitude = $signAddressInfos['result']['location']['lat'];
                        $second_sign_longtitude = $signAddressInfos['result']['location']['lng'];
                    }


                    if ($account_latitude == '-1' || $account_longtitude == '-1' || empty($sign_address)) {
                        $fieldvalue = '无法计算';
                        $updatesql = 'update ld_singin set distince=? where id=?';
                        $this->adb->pquery($updatesql, array($fieldvalue, $signid));
                    } else {

                        $fieldvalue = getDistance($account_latitude, $account_longtitude, $sign_latitude, $sign_longtitude);
                        $secondfieldvalue = getDistance($account_latitude, $account_longtitude, $second_sign_latitude, $second_sign_longtitude);

                        $fieldvalue = min($secondfieldvalue, $fieldvalue);

                        //20120: 常用报表>签到统计表中误差算法增加修正计算，修正误差500米
                        if (round($fieldvalue, 2) > round(500, 2)) {
                            $fieldvalue -= 500;
                        }
                        $updatesql = 'update ld_singin set distince=? where id=?';
                        $this->adb->pquery($updatesql, array($fieldvalue, $signid));
                        //zkt 20220530 52308（https://61mis.com/order/index.php）常用报表》签到统计表，误差值，需显示成千分位格式，方便查看数值
                        $fieldvalue = number_format($fieldvalue,0,'.',',');

                    }
                    //如果$fieldvalue值为0,就会产生bug,所以此处添加(string):can
                    if (((string)$fieldvalue) == '无法计算') $fieldvalue = '-';

                    //$valtemplate .= "<td  style='text-align:right'>$fieldvalue</td> ";
                    $valtemplate .= "<td tag='distance' style='text-align:right'>$fieldvalue</td> ";
                } else if (stripos($temp_val, 'OftenUseReport_accountname') !== false) {
                    $fieldvalue = $custom_field_values[strtolower($temp_val)];
                    $accountid = $custom_field_values['accountid'];
                    //$valtemplate .= "<td  style='text-align:left'><a href='index.php?module=Accounts&action=DetailView&record=$accountid' target='_blank'>$fieldvalue</a></td> ";
                    $valtemplate.="<td style='text-align:left'><a href='javascript:;' referencemodule='Accounts' referencerecord='$accountid' onclick='ListReferenceLinkClick(ld(this),event)'> " .$fieldvalue . '</a></td>';

                    //$valtemplate .= "<td style='text-align:left'><a href='index.php?module=Accounts&action=DetailView&record=$accountid' target='_blank'>$fieldvalue</a></td> ";
                } elseif (stripos($temp_val, '_bill_street') !== false) {
                    //editor:gyq_20181023	0035431: 报表-常用报表-签到统计表，点击重新计算的时候应该根据客户最新的地址跟签到地址显示误差
                    $fieldvalue = $custom_field_values[strtolower($temp_val)];
                    //18376: 常用报表-签到统计表： 相关客户地址（CRM系统数据）列，列值中增加客户的【省份】【城市】值
                    $fieldvalue = $detail_address;
                    $valtemplate .= "<td tag='bill_street'>" . $fieldvalue . "</td>";
                } 
                //2024-4-3 xxy 签退相关字段
                elseif (stripos($temp_val, '_signout') !== false) {
                    $fieldvalue = $custom_field_values[strtolower($temp_val)];

                    if(!isset($issupsignout))//判断签退是否为补签
                        $issupsignout = $custom_field_values[strtolower('OftenUseReport_signout_type')]=='supsign'?'yes':'no';

                    $tmp_temp_val = substr(strstr($temp_val, "_"), 1);
                    if($tmp_temp_val == 'signout_address'){
                        $hyperlink_value = getModuleHref('Signout',$fieldvalue);
                        $valtemplate.="<td style='text-align:left'><a href='javascript:;' referencemodule='Signout' referencerecord='$fieldvalue' onclick='ListReferenceLinkClick(ld(this),event)'> " .$hyperlink_value . '</a></td>';
                    }else{
                        if($tmp_temp_val == 'signout_type' && !empty($fieldvalue)){
                            $fieldvalue = $fieldvalue=='supsign'?getFixedLabel('SUPSIGN'):getFixedLabel('SIGNOUT2');
                        }
                        $valtemplate .= "<td tag='".$tmp_temp_val."'>" . $fieldvalue . "</td>";
                    }

                } elseif (stripos($temp_val, '_timeused') !== false) {//签到签退用时
                    $fieldvalue = $custom_field_values[strtolower($temp_val)];
                    $fieldstyle = '';
                    if($issupsignout && $issupsignout == 'yes')
                        $fieldstyle = "style='color:red;'";
                    $valtemplate .= "<td tag='timeused'><span ".$fieldstyle.">" . $fieldvalue . "</span></td>";
                }else {

                    $fieldvalue = $custom_field_values[strtolower($temp_val)]; 
                    if(strpos(strtolower($temp_val),'oftenusereport_last_name')!==false){
                        $wx_userid=$custom_field_values['oftenusereport_wx_userid'];
                        if($isexport=='yes'){
                            $fieldvalue = $oftenusereport_real_name;
                        }else {
                            $userobj->wx_userid = $wx_userid;
                            $userobj->last_name = $fieldvalue;
                            $fieldvalue = getUserlastName($userobj);
                        }

                    }
                    else if(strpos(strtolower($temp_val),'oftenusereport_groupname')!==false){
                        $wx_groupid = $custom_field_values['oftenusereport_groupid'];
                        $groupid_arr = !empty($wx_groupid)?explode(',', $wx_groupid):[];
                        $groupname_arr = !empty($wx_groupid)?explode(',', $fieldvalue):[];
                        $groupname_fieldvalue = array();
                        foreach($groupid_arr as $tmpgroupindex=>$tmpgroupid){
                            $groupobj=new Users();
                            $groupobj->groupid=$tmpgroupid;
                            $groupobj->groupname=$groupname_arr[$tmpgroupindex];
                            $groupname_fieldvalue[]=getWx_GroupName($groupobj);
                        }
                        $fieldvalue=implode(',',$groupname_fieldvalue);
                    }
                    //拜访对象类型
                    if (strtolower($temp_val) == 'oftenusereport_record') {
                        if (!empty($fieldvalue)) {
                            $fieldvalue = getSalesEntityType($fieldvalue);
                            $fieldvalue = getTransTab($fieldvalue);
                        }
                        //editor:gyq_20190419 reason:兼容还在用APP签到的数据
                        if ($fieldvalue == 0 && !empty($custom_field_values['accountid2'])) {
                            $fieldvalue = getTransTab('Accounts');
                        }
                        if(empty($fieldvalue))
                        {
                            //edit:can 2020-09-16 42483: （https://61mis.com/kfbcrm/ [^]）常用报表->签到统计表中，日期查询条件为“本年”时，【拜访对象类型】列部分数据显示0
                            $fieldvalue='';
                        }
                    }
                    //拜访对象
                    if (strtolower($temp_val) == 'oftenusereport_entityname') {

                        if (!empty($fieldvalue)) {
                            $singin_module = getSalesEntityType($custom_field_values['oftenusereport_record']);
                            $reocrdid = $custom_field_values['oftenusereport_record'];

                            //$fieldvalue = "<a href='index.php?module=$singin_module&action=DetailView&record=$reocrdid' target='_blank'>$fieldvalue</a>";
                            $fieldvalue= " <a referencemodule='$singin_module' referencerecord='$reocrdid' onclick='ListReferenceLinkClick(ld(this),event)' href='javascript:;'>". $fieldvalue . '</a>';

                        } else {
                            //editor:gyq_20190419 reason:兼容还在用APP签到的数据

                            if (!empty($custom_field_values['accountid2'])) {
                                $singin_module = getSalesEntityType($custom_field_values['accountid2']);
                                $reocrdid = $custom_field_values['accountid2'];
                                $fieldvalue = $custom_field_values['accountname2'];

                                //$fieldvalue = "<a href='index.php?module=$singin_module&action=DetailView&record=$reocrdid' target='_blank'>$fieldvalue</a>";
                                $fieldvalue= " <a referencemodule='$singin_module' referencerecord='$reocrdid' onclick='ListReferenceLinkClick(ld(this),event)' href='javascript:;'>". $fieldvalue . '</a>';
                            }
                        }
                    }
					//duan 20221212 读取自定义字段值，去掉模块名前缀
                    if($keyother[1] == 'ld_singinscf'){
                        $tmp_columnname = str_replace('OftenUseReport_','',$temp_val);
                        $fieldvalue = $custom_field_values[$tmp_columnname];
                        //处理多选框值
                        $fieldvalue = str_replace(' |##| ',',',$fieldvalue);
                    }
                    
					$temp_val = $fld->name;
                    if (empty($fieldvalue) || trim($fieldvalue) == "") {
                        $fieldvalue = "-";
                    }

                    if (($lastvalue == $fieldvalue)) {
                        if ($typeofdata == 'N' || $typeofdata == 'NN') {

                            $valtemplate .= "<td  style='text-align:right'>&nbsp;</td>";
                        } else {
                            $valtemplate .= "<td >&nbsp;</td>";
                        }

                    } else {
                        if ($typeofdata == 'N' || $typeofdata == 'NN') {
                            $valtemplate .= "<td style='text-align:right'>" . $fieldvalue . "</td>";
                        } else {
                            $valtemplate .= "<td>" . $fieldvalue . "</td>";
                        }
                    }
                }
            }
            $valtemplate .= "</tr>";
            $oftenusereport_last_name_last = $oftenusereport_last_name;
            $oftenusereport_real_name_last = $oftenusereport_real_name;
            $oftenusereport_wx_userid_last = $oftenusereport_wx_userid;
            $lastvalue = $newvalue;
            $arr_val[] = $arraylists;
            unset($issupsignout);
        } while ($custom_field_values = $this->adb->fetch_array($result));

        if($this->get_progress == 'no' || $this->end_row > $total_row){
            //wyt 220623 签到统计表新增个人小计列
            if(!empty($oftenusereport_last_name)){
                if($isexport=='yes'){
                    $fieldvalue = $oftenusereport_real_name;
                }else {
                    $userobj->wx_userid = $oftenusereport_wx_userid;
                    $userobj->last_name = $oftenusereport_last_name;
                    $fieldvalue = getUserlastName($userobj);
                }
                $valtemplate .= '<tr><td class="Subtotal">'.$fieldvalue.'-'.getFixedLabel('SUBTOTAL').'</td><td class="Subtotal">'.$count.getFixedLabel('TIME1').'</td>';
                $countcolumn = sizeof($this->showcolLists)-2;
                for($j=0;$j<$countcolumn;$j++){
                    $valtemplate .='<td class="Subtotal">-</td>';
                }
                $valtemplate .= '</tr>';
            }

        }
        return $valtemplate;
    }
    //editor:gyq_168 reason:签到统计表功能优化，增加考勤对象类型   2020/1/20 16:07
    protected function ListViewFiftySql(){
        global $adb, $current_user, $currentModule, $mod_strings;
        $where = '';
        $scope = $_REQUEST['SmOwnerSearchScope'];
        $userids = $_REQUEST['receiverid'];
        if (!$scope) {
            $scope = 'SmOwner_Search_All';
        }
        switch ($scope) {
            case 'SmOwner_Search_All':
                $Smownerids = getCurSmOwnerSearchScope($currentModule);

                foreach ($Smownerids['UserCombo'] as $userid => $userinfo) {
                    if ($userids == "") {
                        $userids .= $userid;
                    } else {
                        $userids .= "," . $userid;
                    }
                }
                $userids .= "," . $current_user->id;
                $where .= '  and ld_singin.userid in ( ' . $userids . ' )';
                break;
            case 'SmOwner_Search_Me':
                $where .= " and ld_singin.userid=" . $current_user->id;
                break;
            case 'SmOwner_Search_Create':
                $where .= " and ld_singin.userid=" . $current_user->id;
                break;
            case 'SmOwer_Search_ShareMe':
                $where = "  and ld_tabshare.viewuserid =" . $current_user->id . "";
                break;
            case 'smowner_search_senior':
                if (!empty($userids)) {
                    $where .= " and ld_singin.userid in ( " . $userids . ")";
                }
                break;
            case 'SmOwner_Search_Group':
                $query = 'select userid from ld_users2group where groupid in (' . $_REQUEST['receiverid'] . ') group by userid';
                $result = $adb->pquery($query, array());
                $num_rows = $adb->num_rows($result);
                for ($i = 0; $i < $num_rows; $i++) {
                    $userid_array[] = $adb->query_result($result, $i, 'userid');
                }
                //zxm 2022-1111 常用报表改成报表分析的数据范围
                $ScopOfAuthority = ScopOfAuthority::getInstance($adb,$currentModule);
                //editor:gyq_20190412 0036848: （http://kehu001.com/KH/kh32777 [^]）常用表报>签到统计表>筛选条件选择全部：
                //点击按部门范围进行查找显示没有数据，按全部是有数据的。
                $CurUserScopeId = $ScopOfAuthority->getCurUserScopeId();
                if ($CurUserScopeId == 'All') {
                    $intersection = $userid_array;
                } else {
                    $intersection = array_intersect($userid_array, $ScopOfAuthority->getUserModuleScopeHigher());
                }
                $userids = implode(',', $intersection);
                if (empty($userids)) $userids = 0;
                $where .= " and ld_singin.userid in ( " . $userids . ")";
                break;
            default:
                $where .= " and ld_singin.userid=" . $scope;
        }
		//zxm 20230206 kfbcrm 拜访签到模块单据删除后----签到统计表表中任然统计
        $where .= ' and ld_singin.deleted=0 ';
		//拜访对象名称
        $entityname = $_REQUEST['basicotherfind'];
        //拜访对象类型（所属模块）
        $moduleName = $_REQUEST['basicotherfind2'];
        //签退方式
        $signout_type = $_REQUEST['basicotherfind3'];
        $leftJoin = '';
        $searchWhere = array();
        //zxm 20230517 	BUG0066398	签到统计表，增加两列数据”客户名称和客户代码“字段。
        $versioninfo = getVersionTradeInfo();
        if($versioninfo['account']=='gdxinchuang'){
            $moduleName = "ContactRecords";
        }
        //拜访对象搜索条件
        if ($entityname != ''||$versioninfo['account']=='gdxinchuang') {
            if(!empty($moduleName)){
                $focus = CRMEntity::getInstance($moduleName);
                $searchFieldName = $focus->list_link_field;
                $searchTableName = $focus->table_name;
                $searchTableIndex = $focus->table_index;
                $searchTableid = getTabid($moduleName);
                $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname','accountid');
                $leftJoin .= ' LEFT JOIN '.$searchTableName.' on '.$searchTableName.'.'.$searchTableIndex.'=ld_singin.record ';
                if($moduleName !='Accounts'){
                    if($fieldinfo){
                        $leftJoin .= ' LEFT JOIN ld_account on ld_account.accountid='.$searchTableName.'.accountid ';
                    }else{
                        $leftJoin .= ' LEFT JOIN ld_account on ld_account.accountid=ld_singin.record';
                    }
                }
                $searchWhere[] = ' ld_singin.tabid='.$searchTableid.' and '.$searchTableName.'.'.$searchFieldName.' like \'%'.$entityname.'%\' ';
            }else{
//               @edit:liushuai,2020-08-20,reason:【ID1001018】签到统计表拜访对象类型增加“全部”选项
                //拜访对象类型为全部，值为''
                require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');
                $optionModuleList = cls_StaticCommonFun::getOptionModule('Singin');
                $optionModule = array_column($optionModuleList, 'value');
                for ($i=0; $i<count($optionModule); $i++) {
                    $tmp_moduleName = $optionModule[$i];
                    $focus = CRMEntity::getInstance($tmp_moduleName);
                    $searchFieldName = $focus->list_link_field;
                    $searchTableName = $focus->table_name;
                    $searchTableIndex = $focus->table_index;
//                    $searchTableid = getTabid($tmp_moduleName);
                    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname','accountid');
                    $leftJoin .= ' LEFT JOIN '.$searchTableName.' on '.$searchTableName.'.'.$searchTableIndex.'=ld_singin.record ';
                    if($tmp_moduleName !='Accounts'){
                        if($fieldinfo){
                            $leftJoin .= ' LEFT JOIN ld_account '.strtolower($tmp_moduleName).' on '.strtolower($tmp_moduleName).'.accountid='.$searchTableName.'.accountid ';
                        }
                        //如果$fieldinfo为空，那么leftjoin只需要一次 LEFT JOIN ld_account f ON ld_account.accountid = ld_singin.record，因为ld_leads，ld_campaign都没有该值，故需要去掉else，否则会重复left join
                    }
                    $tmp_searchWhere[] = $searchTableName.'.'.$searchFieldName.' like \'%'.$entityname.'%\' ';
                }
                $searchWhere[] = '('.implode(' or ',$tmp_searchWhere).')';

            }

        }else{
            if(!empty($moduleName)){
                $searchTableid = getTabid($moduleName);
                $searchWhere[] = ' ld_singin.tabid='.$searchTableid;
            }
            $leftJoin .= ' LEFT JOIN ld_account on ld_account.accountid=ld_singin.record';
        }
        //时间搜索条件
        if(!empty($_REQUEST['startmonth'])){
            $startmonth = $_REQUEST['startmonth'] . ' 00:00:00';
            $endmonth = $_REQUEST['endmonth'] . ' 23:59:59';
            $searchWhere[] = " ld_singin.createdtime between '$startmonth' and '$endmonth' ";
        }
        //签退方式条件
        if(!empty($signout_type)){
            $searchWhere[] = " ld_singin.signout_type = '$signout_type' ";
        }
        //查看范围搜索条件
        if ($scope == 'SmOwer_Search_ShareMe') {
            $leftJoin .= ' LEFT JOIN ld_tabshare ON ld_tabshare.crmid = ld_singin.id ';
        }
        $sql = 'select
            ld_singin.id as oldsignid ,ld_singin.createdtime as OftenUseReport_createdtime ,
            ld_singin.address as OftenUseReport_address, 
             ld_account.accountname as OftenUseReport_accountname,
             ld_account.account_no as OftenUseReport_account_no,
             ld_account.bill_street as OftenUseReport_bill_street,
             ld_account.bill_state,ld_account.bill_city,ld_account.bill_area,
             ld_account.accountid,ACC2.accountid accountid2,ACC2.accountname accountname2,
             ld_users.last_name as OftenUseReport_last_name,ld_users.wx_userid as OftenUseReport_wx_userid,ld_users.real_name as OftenUseReport_real_name,
             GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid ) as OftenUseReport_groupname,GROUP_CONCAT(ld_groups.groupid order by ld_groups.groupid ) as OftenUseReport_groupid,
             ld_singin.uuid as OftenUseReport_uuid,ld_singin.content as OftenUseReport_content,ld_singin.latitude,ld_singin.longtitude ,ld_singin.distince  as distince,
             ld_singin.entityname as OftenUseReport_entityname,ld_singin.record as OftenUseReport_record,ld_singin.entityaddress,ld_singin.tabid as OftenUseReport_tabid,
             ld_singin.userid as OftenUseReport_userid,ld_singin.signid as newsignid,
             ld_singin.signout_id,ld_singin.signout_time as OftenUseReport_signout_time,ld_singin.signout_id as OftenUseReport_signout_address,ld_singin.signout_distance as OftenUseReport_signout_distance,
             ld_singin.timeused as OftenUseReport_timeused,ld_singin.signout_type as OftenUseReport_signout_type,
             ld_singinscf.*
             
             from ld_singin 
             '.$leftJoin.'
             LEFT JOIN ld_users on ld_users.id=ld_singin.userid 
             LEFT JOIN ld_users2group on ld_users2group.userid = ld_singin.userid
             LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid 
             LEFT JOIN ld_account ACC2 on ACC2.accountid=ld_singin.accountid 
             LEFT JOIN ld_singinscf on ld_singinscf.signid=ld_singin.signid';
        $sql .= ' where '.implode(' and ',$searchWhere).' '.$where;
        $sql .= ' GROUP BY ld_singin.userid,ld_singin.createdtime,ld_singin.content  ORDER BY ld_users.last_name, ld_singin.createdtime desc ';
        //wyt 220623 签到统计表新增个人小计列
        /**$sql="select * from (
        select
        ld_singin.id as signid ,ld_singin.createdtime as OftenUseReport_createdtime ,ld_singin.createdtime as time11,
        ld_singin.address as OftenUseReport_address,
        ld_account.accountname as OftenUseReport_accountname,
        ld_account.bill_street as OftenUseReport_bill_street,
        ld_account.bill_state,ld_account.bill_city,ld_account.bill_area,
        ld_account.accountid,ACC2.accountid accountid2,ACC2.accountname accountname2,
        ld_users.last_name as OftenUseReport_last_name,ld_users.wx_userid as OftenUseReport_wx_userid,
        GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid ) as OftenUseReport_groupname,GROUP_CONCAT(ld_groups.groupid order by ld_groups.groupid ) as OftenUseReport_groupid,
        ld_singin.uuid as OftenUseReport_uuid,ld_singin.content as OftenUseReport_content,ld_singin.latitude,ld_singin.longtitude ,ld_singin.distince  as distince,
        ld_singin.entityname as OftenUseReport_entityname,ld_singin.record as OftenUseReport_record,ld_singin.entityaddress
        from ld_singin
        $leftJoin
        LEFT JOIN ld_users on ld_users.id=ld_singin.userid
        LEFT JOIN ld_users2group on ld_users2group.userid = ld_singin.userid
        LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
        LEFT JOIN ld_account ACC2 on ACC2.accountid=ld_singin.accountid
        $wheresql  $groupsql
        )a
        union all
        (
        select
        signid , '' as OftenUseReport_createdtime ,'' as time11,
        ' ' as OftenUseReport_address,
        '' as OftenUseReport_accountname,
        '' as OftenUseReport_bill_street,
        '',' ',' ',
        ' ',' ',' ',
        OftenUseReport_last_name,' ' as OftenUseReport_wx_userid,
        CONCAT('签到小计:',count(distinct signid),'次') as OftenUseReport_groupname,' ' as OftenUseReport_groupid,
        ' ' as OftenUseReport_uuid,' ' as OftenUseReport_content,' ',' ' ,''  as distince,
        ' ' as OftenUseReport_entityname,OftenUseReport_record,entityaddress
        from (
        select
        ld_singin.id as signid ,ld_singin.createdtime as OftenUseReport_createdtime ,ld_singin.createdtime as time11,
        ld_singin.address as OftenUseReport_address,
        ld_account.accountname as OftenUseReport_accountname,
        ld_account.bill_street as OftenUseReport_bill_street,
        ld_account.bill_state,ld_account.bill_city,ld_account.bill_area,
        ld_account.accountid,ACC2.accountid accountid2,ACC2.accountname accountname2,
        ld_users.last_name as OftenUseReport_last_name,ld_users.wx_userid as OftenUseReport_wx_userid,
        GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid ) as OftenUseReport_groupname,GROUP_CONCAT(ld_groups.groupid order by ld_groups.groupid ) as OftenUseReport_groupid,
        ld_singin.uuid as OftenUseReport_uuid,ld_singin.content as OftenUseReport_content,ld_singin.latitude,ld_singin.longtitude ,ld_singin.distince  as distince,
        ld_singin.entityname as OftenUseReport_entityname,ld_singin.record as OftenUseReport_record,ld_singin.entityaddress
        from ld_singin
        $leftJoin
        LEFT JOIN ld_users on ld_users.id=ld_singin.userid
        LEFT JOIN ld_users2group on ld_users2group.userid = ld_singin.userid
        LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
        LEFT JOIN ld_account ACC2 on ACC2.accountid=ld_singin.accountid
        $wheresql  $groupsql
        )a  GROUP BY OftenUseReport_wx_userid
        ) order by OftenUseReport_last_name, time11 desc ";*/

        return $sql;
    }
    //签到轨迹表
    private function ListViewFifty_two()
    {
        global $adb, $current_user, $currentModule, $mod_strings;
        //默认选中当前用户
        if(!isset($_REQUEST['SmOwnerSearchScope'])|| $_REQUEST['SmOwnerSearchScope']==''){
            $_REQUEST['SmOwnerSearchScope'] = $current_user->id;
        }
        
        $sql = $this->ListViewFiftySql();
        $result = $this->adb->query($sql, array());
        $y = $this->adb->num_fields($result);
        $num_rows = $this->adb->num_rows($result);
        $custom_field_values = array();
        
        $signin_info = array();
        $column_arr = array('oftenusereport_last_name','latitude','longtitude','oftenusereport_createdtime','oftenusereport_tabid',
                            'oftenusereport_record','oftenusereport_entityname','oftenusereport_address','oftenusereport_userid');
        //按时间顺序读取
        for($i = $num_rows-1;$i >=0;$i-- ){
            foreach($column_arr as $key =>$tmp_column){
                $custom_field_values[$tmp_column] = $adb->query_result($result,$i,$tmp_column);
            }
            $tabid = $custom_field_values['oftenusereport_tabid'];
            if($tabid >0){
                $custom_field_values['oftenusereport_module'] = getTabname($tabid);
            }
            $signin_info[] = $custom_field_values;
        }
        
        
        $signin_info_json = ldcrm_json_encode($signin_info);
        $html = $signin_info_json;
        //$html = "<input type='hidden' name='signin_info' value='".$signin_info_json."'  tag='1' /> ";
        return $html;
    }
    
    private function ListViewFour()
    {
        $this->clearTempotatyTable();
        //$this->getSQLs();

        $SQL = ReportSQL::getReportSQL($this->reportname, $this->reporttabid);

        $result = $this->adb->query($SQL);

        $y = $this->adb->num_fields($result);

        $custom_field_values = $this->adb->fetch_array($result);

        $reportabname = getTabname($this->reporttabid);
        //单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
        if (isset($sysdeploy['deploy_value']))
            $lengthdecimaldigits = $sysdeploy['deploy_value'];
        else
            $lengthdecimaldigits = 2;
        $decimaledreport = false;
        if ($this->reportname == 'Performancestatisticscollection') {
            $decimaledreport = true;
        }
        $i = 0;
        $total_row = 0;
        $userobj=new Users();
        $groupobj=new Users();
        do {
            $isSubtotal = false;
            $isTotalAll = false;
           

            $arraylists = Array();
            $newvalue = $custom_field_values[0];
            $statistical_one = $custom_field_values['statistical_one'];
            $statistical_two = $custom_field_values['statistical_two'];
            $statistical_three = $custom_field_values['statistical_three'];
             if (strstr($statistical_one, getFixedLabel('SUBTOTAL'))) {

                $isSubtotal = true;
                $total_row++;
               
                
            }
            if (strstr($statistical_one, getFixedLabel('TOTAL'))) {
                $isTotalAll = true;
                $total_row++;
            }
            if ($newvalue == "") $newvalue = "-";
            if ($i % 2 == 0) {
                $valtemplate .= "<tr id='report_$i' class='lvtColData' onmouseover='listOnMouseOver(ld(this))' onmouseout=listOnMouseOut(ld(this),'on')>";
            } else {
                $valtemplate .= "<tr id='report_$i' class='lvtColDataBj' onmouseover='listOnMouseOver(ld(this))' onmouseout=listOnMouseOut(ld(this),'On')>";
            }
            $i++;
            foreach ($this->showcolLists as $temp_val => $keyother) {

                $temp_val = explode(':', $temp_val);
                $typeofdata = $temp_val[1];
                $typeofdata_decimal = $temp_val[2];
                $temp_val = $temp_val[0];
                if(in_array($temp_val,array('OftenUseReport_pamount','OftenUseReport_ssubtotal','OftenUseReport_Atotal','OftenUseReport_etotal'
                    ,'OftenUseReport_CommissionTotal'))){
                    $typeofdata_decimal = $this->system_deploy_351;
                }

                $fieldvalue = $custom_field_values[strtolower($temp_val)];
                if($temp_val=='OftenUseReport_lastname'&&array_key_exists('report_wx_userid',$custom_field_values)){
                    $userobj->wx_userid=$custom_field_values['report_wx_userid'];
                    $userobj->last_name=$fieldvalue;
                    //if(!$isSubtotal)
                        
                    if(!$isSubtotal)
                    {
                        $last_wx_userid=$custom_field_values['report_wx_userid'];
                         $fieldvalue=getUserlastName($userobj);
                    }
                    else
                    {
                        $userobj->wx_userid=$last_wx_userid;
                        $fieldvalue=getUserlastName($userobj);
                        if(stripos($fieldvalue,'ww-open-data')){
                            $fieldvalue.='-'.getFixedLabel('SUBTOTAL');
                        }
                    }
                   
                        
                        
                }
                else if($temp_val=='OftenUseReport_groupname'&&array_key_exists('report_wx_groupid',$custom_field_values)){
                    $tmp_groupids=explode(',',$custom_field_values['report_wx_groupid']);
                   
                    $tmp_groupnames=explode(',',$fieldvalue);
                    $arr_groupname=array();
                    foreach($tmp_groupids as $tmpgroupindex=>$tmpgroupid){
                        
                          $groupobj->groupname=$tmp_groupnames[$tmpgroupindex];
                         
                          $groupobj->groupid=$tmpgroupid;

                          $arr_groupname[]=getWx_GroupName($groupobj);
                          
                          
                    }
                  
                    $fieldvalue=implode(",",$arr_groupname);
                }
                if (trim($fieldvalue) == "") {
                    $fieldvalue = "-";
                }
                if (((($lastvalueone == $statistical_one && $lastvaluetwo == $statistical_two && $lastvaluethree == $statistical_three)
                            && ($temp_val == 'salesordercf_cf_1082'
                                || $temp_val == 'salesorder_accountid'
                                || $temp_val == 'salesorder_salesordertotal'
                                || $temp_val == 'salesorder_duedate'
                                || $temp_val == 'salesorder_salesorder_no'
                                || $temp_val == 'salesorder_PaymentBalance'
                                || $temp_val == 'salesordercf_cf_1084'
                            )) ||
                        ($lastvalueone == $statistical_one &&
                            $temp_val == 'products_productcategory') ||
                        (($lastvalueone == $statistical_one && $lastvaluetwo == $statistical_two) &&
                            ($temp_val == 'products_productname'
                                || $temp_val == 'products_product_no')))
                    && $this->reportname == 'CommencementSchedule') {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right'>&nbsp;</td>";
                        } else if ($isTotalAll == true) {
                            $valtemplate .= "<td class='Alltotal' style='text-align:right'>&nbsp;</td>";
                        } else

                            $valtemplate .= "<td class='' style='text-align:right'>&nbsp;</td>";
                    } else {
                        if ($isSubtotal)
                            $valtemplate .= "<td class='Subtotal'>&nbsp;</td>";
                        else if ($isTotalAll == true)
                            $valtemplate .= "<td class='Alltotal' style='text-align:right'>&nbsp;</td>";
                        else
                            $valtemplate .= "<td class=''>&nbsp;</td>";
                    }
                } elseif (((($lastvalueone == $statistical_one && $lastvaluetwo == $statistical_two && $lastvaluethree == $statistical_three)
                            && ($temp_val == 'CashBill_cashbilldate'
                                // @edit:dong @date:2020/08/10 @reason: bug0041038 报表>常用报表>收款业绩统计表：显示列能否增加“收款方式”字
                                || $temp_val == 'CashBill_paymentmethod'
                                || $temp_val == 'Accounts_accountname'
                                || $temp_val == 'Accounts_end_accountidname'
                                || $temp_val == 'OftenUseReport_lastname3'
                                || $temp_val == 'OftenUseReport_Atotal'
                                || $temp_val == 'OftenUseReport_salesorder_no'
                                || $temp_val == 'OftenUseReport_ssubtotal'
                                || $temp_val == 'OftenUseReport_pamount'
                                || $temp_val == 'OftenUseReport_productcost'
                                || $temp_val == 'OftenUseReport_etotal'
                                || $temp_val == 'OftenUseReport_productgp'
                                || $temp_val == 'OftenUseReport_CommissionTotal'
                            )) ||
                        ($lastvalueone == $statistical_one &&
                            ($temp_val == 'OftenUseReport_lastname' || $temp_val == 'OftenUseReport_groupname')) ||
                        (($lastvalueone == $statistical_one && $lastvaluetwo == $statistical_two) &&
                            ($temp_val == 'CashBill_cashbill_no'
                                //||$temp_val=='OftenUseReport_salesorder_no'
                            )))
                    && $this->reportname == 'Performancestatisticscollection') {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right'>&nbsp;</td>";
                        } else if ($isTotalAll == true) {
                            $valtemplate .= "<td class='Alltotal' style='text-align:right'>&nbsp;</td>";
                        } else

                            $valtemplate .= "<td class='' style='text-align:right'>&nbsp;</td>";
                    } else {
                        if ($isSubtotal)
                            $valtemplate .= "<td class='Subtotal'>&nbsp;</td>";
                        else if ($isTotalAll == true)
                            $valtemplate .= "<td class='Alltotal' style='text-align:right'>&nbsp;</td>";
                        else
                            $valtemplate .= "<td class=''>&nbsp;</td>";
                    }
                } else {

                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        if ($isSubtotal == true && $typeofdata == 'N') {
                            $fld = explode('_', $temp_val);
                            if ($decimaledreport && $fld[1] == 'quantity') {
                                $fieldvalue = setNumberFormat($fieldvalue, $lengthdecimaldigits);
                            } else {
                                $fieldvalue = getDefaultCurrecySymbol() . setNumberFormat($fieldvalue,$typeofdata_decimal);
                            }
                            $valtemplate .= "<td class='Subtotal' style='text-align:right' >" . $fieldvalue . "</td>";
                        } elseif (($typeofdata == 'NN' || $typeofdata == 'N') && $isSubtotal != true && $isTotalAll != true) {
                            $fld = explode('_', $temp_val);
                            if ($decimaledreport && $fld[1] == 'quantity') {
                                $fieldvalue = setNumberFormat($fieldvalue, $lengthdecimaldigits);
                            } elseif ($this->reportname == 'Performancestatisticscollection')//收款业绩统计表
                            {
                                if ($temp_val == 'OftenUseReport_ssubtotal')//合同总金额
                                {
                                    if ($custom_field_values[strtolower('SalesOrder_Symbol')] == '')
                                        $currenct_symbol = getDefaultCurrecySymbol();
                                    else
                                        $currenct_symbol = $custom_field_values[strtolower('SalesOrder_Symbol')];
                                } elseif ($temp_val == 'OftenUseReport_Atotal' || $temp_val == 'OftenUseReport_etotal'
                                    || $temp_val == 'OftenUseReport_CommissionTotal' || $temp_val == 'Products_costprice'
                                    || $temp_val == 'OftenUseReport_productgp' || $temp_val == 'OftenUseReport_productcost')//收款金额
                                {
                                    //|| $temp_val == 'OftenUseReport_productcost'
                                    $currenct_symbol = getDefaultCurrecySymbol();
                                } elseif ($temp_val == 'OftenUseReport_pamount') {
                                    if ($custom_field_values[strtolower('CashBill_Symbol')] == '')
                                        $currenct_symbol = getDefaultCurrecySymbol();
                                    else
                                        $currenct_symbol = $custom_field_values[strtolower('CashBill_Symbol')];
                                } else {
                                    if ($custom_field_values[strtolower('SalesOrder_Symbol')] == '')
                                        $currenct_symbol = getDefaultCurrecySymbol();
                                    else
                                        $currenct_symbol = $custom_field_values[strtolower('SalesOrder_Symbol')];
                                }
                                $fieldvalue = $currenct_symbol . setNumberFormat($fieldvalue,$typeofdata_decimal);
                            } else {
                                $fieldvalue = setNumberFormat($fieldvalue,$typeofdata_decimal);
                            }
                            $valtemplate .= "<td style='text-align:right' >" . $fieldvalue . "</td>";

                        } elseif ($isSubtotal == true && $typeofdata == 'NN') {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right' >" . getDefaultCurrecySymbol() . setNumberFormat($fieldvalue,$typeofdata_decimal) . "</td>";

                        } elseif ($isTotalAll == true && ($typeofdata == 'NN' || $typeofdata == 'N')) {
                            if ($temp_val != 'OftenUseReport_quantity')
                                $valtemplate .= "<td class='Alltotal' style='text-align:right' >" . getDefaultCurrecySymbol() . setNumberFormat($fieldvalue,$typeofdata_decimal) . "</td>";
                            else
                                $valtemplate .= "<td class='Alltotal' style='text-align:right' >" . setNumberFormat($fieldvalue,$typeofdata_decimal) . "</td>";
                        } else {
                            $valtemplate .= "<td style='text-align:right' >" . $fieldvalue . "</td>";
                        }
                    } else {
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal'>" . $fieldvalue . "</td>";
                        } else {
                            if ($this->reportname == 'Performancestatisticscollection' && $temp_val == 'Accounts_accountname' && $fieldvalue != '' && $fieldvalue != '-') {//收款业绩统计表 客户字段超链接
                                $vendors_vendorid = $custom_field_values['accounts_accountid'];
                                $reportabname = 'Accounts';
                                $valtemplate .= '<td> <a record="'.$vendors_vendorid.'" module="'.$reportabname.'" onclick="ListLinkClick(ld(this),event)"  href="javascript:;">' . $fieldvalue . '</a></td>';

                            } else {
                                if ($isSubtotal == true) {
                                    $valtemplate .= "<td class='Subtotal'>" . $fieldvalue . "</td>";
                                } else if ($isTotalAll == true) {
                                    $valtemplate .= "<td class='Alltotal'>" . $fieldvalue . "</td>";
                                } else {
                                    $valtemplate .= "<td>" . $fieldvalue . "</td>";
                                }

                            }

                        }

                    }

                }
            }
            $valtemplate .= "</tr>";

            $lastvalueone = $statistical_one;
            $lastvaluetwo = $statistical_two;
            $lastvaluethree = $statistical_three;
            $arr_val[] = $arraylists;
            $isSubtotal = false;
        } while ($custom_field_values = $this->adb->fetch_array($result));
        $valtemplate .= "</tr>";
        return $valtemplate;
    }

    private function ListViewFive()
    {
        //获取账套版本
        $tradeInfo = getVersionTradeInfo();

        $this->clearTempotatyTable();
        //$this->getSQLs();

        $SQL = ReportSQL::getReportSQL($this->reportname, $this->reporttabid);
        $result = $this->adb->query($SQL);
        $y = $this->adb->num_fields($result);

        $custom_field_values = $this->adb->fetch_array($result);
        $reportabname = getTabname($this->reporttabid);
        //单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
        if (isset($sysdeploy['deploy_value']))
            $lengthdecimaldigits = $sysdeploy['deploy_value'];
        else
            $lengthdecimaldigits = 2;
        $decimaledreport = false;
        if ($this->reportname == 'Salesforecastandanalysistable' || $this->reportname == 'Thestatisticalreportofprojectperformance') {
            $decimaledreport = true;
        }
        $total_row = 0;
        $i = 0;
        $userobj=new Users();
        do {
            $isSubtotal = false;
            $isTotalAll = false;
            if (strstr($custom_field_values[0], getFixedLabel('SUBTOTAL'))) {

                $isSubtotal = true;
                $total_row++;
            }
            if (strstr($custom_field_values[0], getFixedLabel('TOTAL'))) {
                $isTotalAll = true;
                $total_row++;
            }
            $arraylists = Array();
            $newvalue = $custom_field_values[0];
            $statistical_one = $custom_field_values['statistical_one'];
            $statistical_two = $custom_field_values['statistical_two'];
            $statistical_three = $custom_field_values['statistical_three'];
            $statistical_four = $custom_field_values['statistical_four'];
            if ($newvalue == "") $newvalue = "-";

            if ($i % 2 == 0) {
                $valtemplate .= "<tr id='report_$i' class='lvtColData' onmouseover='listOnMouseOver(ld(this))' onmouseout=listOnMouseOut(ld(this),'on')>";
            } else {
                $valtemplate .= "<tr id='report_$i' class='lvtColDataBj' onmouseover='listOnMouseOver(ld(this))' onmouseout=listOnMouseOut(ld(this),'On')>";
            }
            $i++;
            foreach ($this->showcolLists as $temp_val => $keyother) {

                $temp_val = explode(':', $temp_val);
                $typeofdata = $temp_val[1];
                $typeofdata_decimal = $temp_val[2];
                $temp_val = $temp_val[0];
                if(in_array(strtolower($temp_val),array('potentials_retotal','potentials_amount','cashbill_cashbillamount','oftenusereport_paymentbalance') )){
                    $typeofdata_decimal = $this->system_deploy_351;
                }

                $fieldvalue = $custom_field_values[strtolower($temp_val)];
                if (is_string($fieldvalue)&&trim($fieldvalue) == "") {
                    $fieldvalue = "-";
                }

                /*if($temp_val == 'potentialname'){
                               echo $lastvaluetwo."-".$statistical_two."<br>";
                            }
                            echo $temp_val."<br>";*/
                if (((($lastvalueone == $statistical_one && $lastvaluethree == $statistical_three)
                            && ($temp_val == 'Potentials_Potentials_smcreatorid'
                                || $temp_val == 'Potentials_potentialname'
                                || $temp_val == 'Potentials_productcategory'
                                || $temp_val == 'Potentials_potential_no'
                                || $temp_val == 'Potentials_sales_stage' || $temp_val == 'Potentials_lastsales_stage' || $temp_val == 'SalesOrder_total'
                                || $temp_val == 'Potentials_closingdate'
                            )) ||
                        ($lastvalueone == $statistical_one &&
                            ($temp_val == 'Potentials_last_name' || $temp_val == 'Potentials_groupname')) ||
                        (($lastvalueone == $statistical_one && $lastvaluetwo == $statistical_two) &&
                            ($temp_val == 'Accounts_accountname'
                                || $temp_val == 'Accounts_account_type'
                            )) ||
                        (($lastvalueone == $statistical_one && $lastvaluefour == $statistical_four) &&
                            ($temp_val == 'Potentials_plandate'
                            )
                        ))
                    && $this->reportname == 'Salesforecastandanalysistable'&&$tradeInfo['account']!="hzshuiyou") {
                     //echo $temp_val."<br>";die;
                    //0048663: （http://xiaoshou360.com/xs/hzshuiyou/ [^]）（客户问题-王杰）常用报表》销售预测分析表》销售负责人列和所属部门列，相同的值要显示出来
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right'>&nbsp;</td>";
                        } else
                            $valtemplate .= "<td  style='text-align:right'>&nbsp;</td>";
                    } else {
                        if ($isSubtotal)
                            $valtemplate .= "<td class='Subtotal'>&nbsp;</td>";
                        else
                            $valtemplate .= "<td >&nbsp;</td>";
                    }
                } else {
                    //销售机会币种符号
                    $currencysymbol = $custom_field_values['potential_symbol'];
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        if ($isSubtotal == true && ($typeofdata == 'N' || $typeofdata == 'NN')) {
                            $fld = explode('_', $temp_val);
                            if ($decimaledreport && $fld[1] == 'quantity') {
                                $fieldvalue = setNumberFormat($fieldvalue, $lengthdecimaldigits);
                            } else {
                                $fieldvalue = setNumberFormat($fieldvalue,$typeofdata_decimal);
                            }
                            if ($fieldvalue == '')
                                $valtemplate .= "<td class='Subtotal' style='text-align:right' >" . $fieldvalue . "</td>";
                            else
                                $valtemplate .= "<td class='Subtotal' style='text-align:right' >" . getDefaultCurrecySymbol() . $fieldvalue . "</td>";
                        } elseif (($typeofdata == 'NN' || $typeofdata == 'N') && $isSubtotal != true && $isTotalAll != true) {

                            $fld = explode('_', $temp_val);
                            if ($decimaledreport && $fld[1] == 'quantity') {
                                $fieldvalue = setNumberFormat($fieldvalue, $lengthdecimaldigits);
                            } elseif ($decimaledreport && $temp_val == 'Potentials_total') {
                                $fieldvalue = getDefaultCurrecySymbol() . setNumberFormat($fieldvalue,$typeofdata_decimal);
                            } elseif ($decimaledreport && $temp_val == 'SalesOrder_total') {
                                $fieldvalue = getDefaultCurrecySymbol() . setNumberFormat($fieldvalue,$typeofdata_decimal);
                            } elseif ($decimaledreport && $temp_val == 'CashBill_CashBillamount') {
                                $fieldvalue = getDefaultCurrecySymbol() . setNumberFormat($fieldvalue,$typeofdata_decimal);
                            } elseif ($decimaledreport && $temp_val == 'oftenusereport_PaymentBalance') {
                                $fieldvalue = getDefaultCurrecySymbol() . setNumberFormat($fieldvalue,$typeofdata_decimal);
                            } elseif ($temp_val == 'Potentials_retotal') {
                                $salessymbol = $custom_field_values['sales_symbol'];
                                if (empty($salessymbol))//edit：can 如果该销售机会没有合同，则合同币种符号以销售机会为准
                                {
                                    $salessymbol = $currencysymbol;
                                }
                                $fieldvalue = $salessymbol . setNumberFormat($fieldvalue,$typeofdata_decimal);
                            } elseif ($temp_val == 'Potentials_amount') {
                                $fieldvalue = getDefaultCurrecySymbol() . setNumberFormat($fieldvalue,$typeofdata_decimal);
                            } else {
                                $fieldvalue = $currencysymbol . setNumberFormat($fieldvalue,$typeofdata_decimal);
                            }

                            $valtemplate .= "<td style='text-align:right' >" . $fieldvalue . "</td>";
                            /* if($isSubtotal==true)
                                     {
                                        $valtemplate .= "<td class='Subtotal' style='text-align:right' >".$fieldvalue."ff</td>";
                                     }
                                     else{
                                        if($isTotalAll == true){
                                            $valtemplate .= "<td class='Alltotal' style='text-align:right' >".$fieldvalue."ff</td>";
                                        }else{
                                            $valtemplate .= "<td style='text-align:right' >".$fieldvalue."</td>";
                                        }

                                     }*/
                        } elseif ($isSubtotal == true && ($typeofdata == 'N' || $typeofdata == 'NN')) {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right' >" . getDefaultCurrecySymbol() . setNumberFormat($fieldvalue,$typeofdata_decimal) . "</td>";
                        } elseif ($this->reportname == 'Allpaymentsstatisticsreport' && $temp_val == 'OftenUseReport_lirunlv') {
                            $valtemplate .= "<td class='Alltotal' style='text-align:right'>" . setNumberFormat($fieldvalue,$typeofdata_decimal) . "</td>";
                        } else if ($isTotalAll == true && ($typeofdata == 'N' || $typeofdata == 'NN')) {
                            $valtemplate .= "<td class='Alltotal' style='text-align:right'>" . getDefaultCurrecySymbol() . setNumberFormat($fieldvalue,$typeofdata_decimal) . "</td>";
                        } else {
                            $valtemplate .= "<td style='text-align:right' >" . $fieldvalue . "</td>";
                        }
                    } else {
                        //	0024887: （芝浦帐套）常用报表-销售预测分析表打开报错
                        if (($temp_val == 'Potentials_sales_stage' || $temp_val == 'Potentials_lastsales_stage') && $this->reportname == 'Salesforecastandanalysistable') {
                            $fieldObj = Field::getInstance('Potentials', $adb);
                            $moduleFields = $fieldObj->getModuleFields();
                            if ($temp_val == 'Potentials_sales_stage') {
                                $field_sales_stage = $moduleFields['sales_stage'];

                                if (empty($field_sales_stage)) {
                                    //BUG0063447	已分派	功能BUG	正常处理	周晓梅 71申请的演示账套：报表分析-销售预测分析表显示列和下面数值错位（所有演示账套都有这个问题，开发部账套正常）
                                    if($isSubtotal==true){
                                        $valtemplate .= "<td class='Subtotal'>-</td>";

                                    }else if($isTotalAll==true){
                                        $valtemplate .= "<td class='Alltotal'>-</td>";

                                    }else{
                                        $valtemplate .= "<td>-</td>";
                                    }
                                    continue;
                                }
                            }
                            if ($temp_val == 'Potentials_lastsales_stage') {
                                $field_lastsales_stage = $moduleFields['lastsales_stage'];
                                if (empty($field_lastsales_stage)){
                                    //BUG0063447	已分派	功能BUG	正常处理	周晓梅 71申请的演示账套：报表分析-销售预测分析表显示列和下面数值错位（所有演示账套都有这个问题，开发部账套正常）
                                    if($isSubtotal==true){
                                        $valtemplate .= "<td class='Subtotal'>-</td>";

                                    }else if($isTotalAll==true){
                                        $valtemplate .= "<td class='Alltotal'>-</td>";

                                    }else{
                                        $valtemplate .= "<td>-</td>";
                                    }
                                    continue;
                                }
                            }
                        }
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal'>" . $fieldvalue . "</td>";

                        } else {
                            if ($isTotalAll == true) {
                                $valtemplate .= "<td class='Alltotal'>" . $fieldvalue . "</td>";
                            } else {
                                /**
                                 *cme
                                 *所有报表“客户名称”字段增加超链接
                                 **/
                                if ($this->reportname == 'Salesforecastandanalysistable' && $temp_val == 'Accounts_accountname' && $fieldvalue != '-' && $fieldvalue != '') {//销售预测分析表
                                    $reportabname = 'Accounts';
                                    $accountid = $custom_field_values['accounts_accountid'];
                                     $valtemplate .= "<td> <a referencemodule='$reportabname' referencerecord='$accountid' onclick='ListReferenceLinkClick(ld(this),event)' href='javascript:;'>". $fieldvalue . '</a></td>';
                                    
                                //    $valtemplate .= '<td> <a target=\'_blank\' href=\'index.php?module=' . $reportabname . '&action=DetailView&record=' . trim($accountid) . '\'>' . $fieldvalue . '</a></td>';
                                } elseif($this->reportname == 'Salesforecastandanalysistable' && $temp_val == 'Potentials_potential_no'){
                                    $reportabname = 'Potentials';
                                    $potentialid = $custom_field_values['potentials_potentialid'];
                                    $valtemplate .= "<td> <a referencemodule='$reportabname' referencerecord='$potentialid' onclick='ListReferenceLinkClick(ld(this),event)' href='javascript:;'>". $fieldvalue . '</a></td>';
                                }elseif ($this->reportname == 'Thestatisticalreportofprojectperformance' && $temp_val == 'Accounts_accountname' && $fieldvalue != '' && $fieldvalue != '-') {//项目业绩统计表
                                    $reportabname = 'Accounts';
                                    $accountid = $custom_field_values['accounts_accountid'];
                                //   $valtemplate .= '<td> <a target=\'_blank\' href=\'index.php?module=' . $reportabname . '&action=DetailView&record=' . trim($accountid) . '\'>' . $fieldvalue . '</a></td>';
                                    $valtemplate .= "<td> <a referencemodule='$reportabname' referencerecord='$accountid' onclick='ListReferenceLinkClick(ld(this),event)' href='javascript:;'>". $fieldvalue . '</a></td>';

                                } else {
									//echo $temp_val;echo '<br><br>';
									if('Potentials_last_name' == $temp_val || 'OftenUseReport_lastname' == $temp_val){
										
										$userobj->wx_userid=$custom_field_values['report_wx_userid'];
										$userobj->last_name=$fieldvalue;
										$fieldvalue=getUserlastName($userobj);
									}
									if('Potentials_Potentials_smcreatorid' == $temp_val){
										$userobj->wx_userid=$custom_field_values['report_wx_userid_creator'];
										$userobj->last_name=$fieldvalue;
										$fieldvalue=getUserlastName($userobj);
									}
									if('Potentials_groupname' == $temp_val || 'OftenUseReport_groupname' == $temp_val){
										$groupobj=new Group();
										$groupobj->groupid=$custom_field_values['report_wx_groupid'];
										$groupobj->groupname=$fieldvalue;
										$fieldvalue=getWx_GroupName($groupobj);
									}
									
                                    $valtemplate .= "<td>" . $fieldvalue . "</td>";
                                }

                            }
                        }
                    }

                }
            }
            $valtemplate .= "</tr>";

            $lastvalueone = $statistical_one;
            $lastvaluetwo = $statistical_two;
            $lastvaluethree = $statistical_three;
            $lastvaluefour = $statistical_four;
            $arr_val[] = $arraylists;
            $isSubtotal = false;
        } while ($custom_field_values = $this->adb->fetch_array($result));
        $valtemplate .= "</tr>";
        return $valtemplate;
    }

    private function ListViewSix()
    {
        $this->clearTempotatyTable();
        //$this->getSQLs();

        $SQL = ReportSQL::getReportSQL($this->reportname, $this->reporttabid);

        $result = $this->adb->query($SQL);

        $y = $this->adb->num_fields($result);

        $custom_field_values = $this->adb->fetch_array($result);

        $reportabname = getTabname($this->reporttabid);
        //单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
        if (isset($sysdeploy['deploy_value']))
            $lengthdecimaldigits = $sysdeploy['deploy_value'];
        else
            $lengthdecimaldigits = 2;
        $decimaledreport = false;
        if ($this->reportname == 'Salesforecastandanalysistable' || $this->reportname == 'Thestatisticalreportofprojectperformance') {
            $decimaledreport = true;
        }
        $total_row = 0;
        do {
            $isSubtotal = false;
            $isTotalAll = false;
            if (strstr($custom_field_values[0], getFixedLabel('SUBTOTAL'))) {

                $isSubtotal = true;
                $total_row++;
            }
            if (strstr($custom_field_values[0], getFixedLabel('TOTAL'))) {
                $isTotalAll = true;
                $total_row++;
            }
            $arraylists = Array();
            $newvalue = $custom_field_values[0];
            $statistical_one = $custom_field_values['statistical_one'];
            $statistical_two = $custom_field_values['statistical_two'];
            $statistical_three = $custom_field_values['statistical_three'];
            $statistical_four = $custom_field_values['statistical_four'];
            if ($newvalue == "") $newvalue = "-";

            $valtemplate .= "<tr>";
            foreach ($this->showcolLists as $temp_val => $keyother) {

                $temp_val = explode(':', $temp_val);
                $typeofdata = $temp_val[1];
                $temp_val = $temp_val[0];

                $fieldvalue = $custom_field_values[strtolower($temp_val)];
                if (trim($fieldvalue) == "") {
                    $fieldvalue = "-";
                }
                if ($isSubtotal == true) {
                    $valtemplate .= "<td class='Subtotal'>" . $fieldvalue . "</td>";
                } else {
                    if ($isTotalAll == true) {
                        $valtemplate .= "<td class='Alltotal'>" . $fieldvalue . "</td>";
                    } else {
                        $valtemplate .= "<td>" . $fieldvalue . "</td>";
                    }
                }
                //$valtemplate .= "<td>".$fieldvalue."</td>";

            }
            $valtemplate .= "</tr>";

            $lastvalueone = $statistical_one;
            $lastvaluetwo = $statistical_two;
            $lastvaluethree = $statistical_three;
            $lastvaluefour = $statistical_four;
            $arr_val[] = $arraylists;
            $isSubtotal = false;
        } while ($custom_field_values = $this->adb->fetch_array($result));
        $valtemplate .= "</tr>";
        return $valtemplate;
    }

    private function ListViewThree()
    {
        $this->clearTempotatyTable();
        //$this->getSQLs();

        $SQL = ReportSQL::getReportSQL($this->reportname, $this->reporttabid);

        $result = $this->adb->query($SQL);

        $y = $this->adb->num_fields($result);

        $custom_field_values = $this->adb->fetch_array($result);

        $reportabname = getTabname($this->reporttabid);

        $total_row = 0;
        do {
            $isSubtotal = false;
            $isTotalAll = false;
            if (strstr($custom_field_values[0], getFixedLabel('SUBTOTAL'))) {

                $isSubtotal = true;
                $total_row++;
            }
            if (strstr($custom_field_values[0], getFixedLabel('TOTAL'))) {
                $isTotalAll = true;
                $total_row++;
            }
            $arraylists = Array();
            $newvalue = $custom_field_values[0];
            $statistical_one = $custom_field_values['statistical_one'];
            $statistical_two = $custom_field_values['statistical_two'];
            $statistical_three = $custom_field_values['statistical_three'];
            $statistical_thour = $custom_field_values['statistical_thour'];
            $statistical_thour = !empty($statistical_thour) ? $statistical_thour : $statistical_two;
            if ($newvalue == "") $newvalue = "-";

            $valtemplate .= "<tr>";
            //print_r($this->showcolLists);
            foreach ($this->showcolLists as $temp_val => $keyother) {

                $temp_val = explode(':', $temp_val);
                $typeofdata = $temp_val[1];
                $temp_val = $temp_val[0];

                $fieldvalue = $custom_field_values[strtolower($temp_val)];
                if (trim($fieldvalue) == "") {
                    $fieldvalue = "-";
                }
                if (((($lastvalueone == $statistical_one && $lastvaluetwo == $statistical_two) &&
                            ($temp_val == 'salesorder_duedate'
                                || $temp_val == 'products_productname'
                                || $temp_val == 'salesordercf_cf_1084'
                                || $temp_val == 'salesordercf_cf_1082'
                                || $temp_val == 'salesorder_salesorder_no'
                                || $temp_val == 'salesorder_salesordertotal'
                                || $temp_val == 'salesorder_PaymentBalance'
                            )) || (($lastvalueone == $statistical_one) &&
                            ($temp_val == 'salesorder_accountid'
                                || $temp_val == 'salesorder_salesorder_count')))
                    && $this->reportname == 'PartnerCommencementSchedule') {

                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right'>&nbsp;</td>";
                        } else

                            $valtemplate .= "<td  style='text-align:right'>&nbsp;</td>";
                    } else {
                        if ($isSubtotal)
                            $valtemplate .= "<td class='Subtotal'>&nbsp;</td>";
                        else
                            $valtemplate .= "<td >&nbsp;</td>";
                    }
                } elseif (((($lastvalueone == $statistical_one && $lastvaluetwo == $statistical_two)
                            && ($temp_val == 'products_productname'
                                || $temp_val == 'salesorder_duedate'
                                || $temp_val == 'salesordercf_cf_1084'
                                || $temp_val == 'salesorder_accountid'
                                || $temp_val == 'salesorder_salesorder_no'
                                || $temp_val == 'salesorder_PaymentBalance'
                                || $temp_val == 'salesorder_salesordertotal'
                            )) ||
                        (($lastvalueone == $statistical_one) &&
                            ($temp_val == 'salesordercf_cf_1082' || $temp_val == 'salesorder_salesorder_count')))
                    && $this->reportname == 'LecturerCommencementSchedule') {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right'>&nbsp;</td>";
                        } else

                            $valtemplate .= "<td  style='text-align:right'>&nbsp;</td>";
                    } else {
                        if ($isSubtotal)
                            $valtemplate .= "<td class='Subtotal'>&nbsp;</td>";
                        else
                            $valtemplate .= "<td >&nbsp;</td>";
                    }
                } elseif (((($lastvalueone == $statistical_one && $lastvaluetwo == $statistical_two)
                            && ($temp_val == 'products_productname'
                                || $temp_val == 'salesorder_duedate'
                                || $temp_val == 'salesordercf_cf_1084'
                                || $temp_val == 'salesorder_accountid'
                                || $temp_val == 'salesorder_salesorder_no'
                                || $temp_val == 'salesorder_PaymentBalance'
                                || $temp_val == 'salesorder_salesordertotal'
                            )) ||
                        (($lastvalueone == $statistical_one) &&
                            ($temp_val == 'salesordercf_cf_1082' || $temp_val == 'salesorder_salesorder_count')))
                    && $this->reportname == 'KPCCommencementDetails') {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right'>&nbsp;</td>";
                        } else

                            $valtemplate .= "<td  style='text-align:right'>&nbsp;</td>";
                    } else {
                        if ($isSubtotal)
                            $valtemplate .= "<td class='Subtotal'>&nbsp;</td>";
                        else
                            $valtemplate .= "<td >&nbsp;</td>";
                    }
                } elseif (((($lastvalueone == $statistical_one && $lastvaluethour == $statistical_thour)
                            && (
                                $temp_val == 'CashBill_CashBillamount'
                                || $temp_val == 'oftenusereport_PaymentBalance'
                            ))
                        ||
                        (($lastvalueone == $statistical_one && $lastvaluethree == $statistical_three)
                            && (
                                $temp_val == 'OutboundOrder_cf_1488'
                                || $temp_val == 'OutboundOrder_cf_1401' || $temp_val == 'OutboundOrder_outdate'
                            ))
                        || (($lastvalueone == $statistical_one && $lastvaluetwo == $statistical_two)
                            && (
                                $temp_val == 'SalesOrder_signed_data'
                                || $temp_val == 'SalesOrder_cf_1209'
                            )) ||
                        (($lastvalueone == $statistical_one) &&
                            ($temp_val == 'Accounts_accountname'
                                || $temp_val == 'Accounts_cf_1519'
                                || $temp_val == 'Accounts_rating'
                                || $temp_val == 'OftenUseReport_lastname'
                                || $temp_val == 'Accounts_cf_1428')))
                    && $this->reportname == 'Xuanyuanlawnbusinessmanagementreport') {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right'>&nbsp;</td>";
                        } else

                            $valtemplate .= "<td  style='text-align:right'>&nbsp;</td>";
                    } else {
                        if ($isSubtotal)
                            $valtemplate .= "<td class='Subtotal'>&nbsp;</td>";
                        else
                            $valtemplate .= "<td >&nbsp;</td>";
                    }
                } else {
                    if ($typeofdata == 'N' || $typeofdata == 'NN' && $this->reportname != 'Xuanyuanlawnbusinessmanagementreport') {
                        if ($isSubtotal == true && $typeofdata == 'N') {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right' >" . $fieldvalue . "</td>";
                        } elseif ($typeofdata == 'NN' && $isSubtotal != true) {
                            $valtemplate .= "<td style='text-align:right' >" . getDecimalTwoVal($fieldvalue) . "</td>";

                        } elseif ($isSubtotal == true && $typeofdata == 'NN') {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right' >" . getDecimalTwoVal($fieldvalue) . "</td>";
                        } else {
                            $valtemplate .= "<td style='text-align:right' >" . $fieldvalue . "</td>";
                        }
                    } elseif (($typeofdata == 'N' || $typeofdata == 'NN') && $this->reportname == 'Xuanyuanlawnbusinessmanagementreport') {
                        if ($isSubtotal == true && $typeofdata == 'N') {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right' >" . $fieldvalue . "</td>";
                        } elseif ($typeofdata == 'NN' && $isSubtotal != true) {
                            $valtemplate .= "<td style='text-align:right' >" . getDefaultCurrecySymbol() . getDecimalTwoVal($fieldvalue) . "</td>";

                        } elseif ($isSubtotal == true && $typeofdata == 'NN') {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right' >" . getDefaultCurrecySymbol() . getDecimalTwoVal($fieldvalue) . "</td>";
                        } else {
                            $valtemplate .= "<td style='text-align:right' >" . $fieldvalue . "</td>";
                        }

                    } else {
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal'>" . $fieldvalue . "</td>";
                        } else
                            $valtemplate .= "<td>" . $fieldvalue . "</td>";
                    }

                }
            }
            $valtemplate .= "</tr>";

            $lastvalueone = $statistical_one;
            $lastvaluetwo = $statistical_two;
            $lastvaluethree = $statistical_three;
            $lastvaluethour = $statistical_thour;
            $arr_val[] = $arraylists;
            $isSubtotal = false;
        } while ($custom_field_values = $this->adb->fetch_array($result));
        $valtemplate .= "</tr>";
        return $valtemplate;
    }

    private function ListViewTwo()
    {
        $this->clearTempotatyTable();
        $SQL = ReportSQL::getReportSQL($this->reportname, $this->reporttabid);

        $result = $this->adb->query($SQL);

        $y = $this->adb->num_fields($result);

        $custom_field_values = $this->adb->fetch_array($result);
        $reportabname = getTabname($this->reporttabid);

        $total_row = 0;
        do {
            $isSubtotal = false;
            $isTotalAll = false;
            $arraylists = Array();
            $newvalue = $custom_field_values[0];
            if (strstr($custom_field_values[0], getFixedLabel('SUBTOTAL'))) {
                $isSubtotal = true;
                $total_row++;

            }
            if (strstr($custom_field_values[0], getFixedLabel('TOTAL'))) {
                $isTotalAll = true;
                $total_row++;
            }

            $statistical_field = $custom_field_values['statistical_field'];

            if ($newvalue == "") $newvalue = "-";

            $valtemplate .= "<tr>";
            // print_r($this->showcolLists);
            foreach ($this->showcolLists as $temp_val => $keyother) {

                $temp_val = explode(':', $temp_val);
                $typeofdata = $temp_val[1];
                $temp_val = $temp_val[0];

                $fieldvalue = $custom_field_values[strtolower($temp_val)];
                if (trim($fieldvalue) == "") {
                    $fieldvalue = "-";
                }
                if ($lastvalue == $statistical_field && ($temp_val == 'salesordercf_cf_1084'
                        || $temp_val == 'salesordercf_cf_1082'
                        || $temp_val == 'salesorder_accountid'
                        || $temp_val == 'salesorder_salesorder_no'
                        || $temp_val == 'salesorder_duedate'
                        || $temp_val == 'salesorder_PaymentBalance'
                        || $temp_val == 'products_productname')
                    && $this->reportname == 'OverallCommencementSchedule') {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right'>&nbsp;</td>";
                        } else

                            $valtemplate .= "<td  style='text-align:right'>&nbsp;</td>";
                    } else {
                        if ($isSubtotal)
                            $valtemplate .= "<td class='Subtotal'>&nbsp;</td>";
                        else
                            $valtemplate .= "<td >&nbsp;</td>";
                    }
                } elseif ($lastvalue == $statistical_field && ($temp_val == 'contactdetails_lastname'
                        || $temp_val == 'contactdetails_accountid'
                        || $temp_val == 'contactdetails_title'
                        || $temp_val == 'contactdetails_mobile'
                        || $temp_val == 'contactdetails_pphone'
                        || $temp_val == 'salesorder_salesorder_count')
                    && $this->reportname == 'Studentsparticipatinginthetrainingschedule') {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right'>&nbsp;</td>";
                        } else

                            $valtemplate .= "<td  style='text-align:right'>&nbsp;</td>";
                    } else {
                        if ($isSubtotal)
                            $valtemplate .= "<td class='Subtotal'>&nbsp;</td>";
                        else
                            $valtemplate .= "<td >&nbsp;</td>";
                    }
                } elseif ($lastvalue == $statistical_field && ($temp_val == 'contactdetails_title'
                        || $temp_val == 'contactdetails_lastname'
                        || $temp_val == 'contactdetails_mobile'
                        || $temp_val == 'contactdetails_pphone'
                        || $temp_val == 'contactdetails_accountid') && ($lastvalue != '')
                    && $this->reportname == 'Contactbusinesstable') {
                    //echo $statistical_field;
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right'>&nbsp;</td>";
                        } else

                            $valtemplate .= "<td  style='text-align:right'>&nbsp;</td>";
                    } else {
                        if ($isSubtotal)
                            $valtemplate .= "<td class='Subtotal'>&nbsp;</td>";
                        else
                            $valtemplate .= "<td >&nbsp;</td>";
                    }
                } elseif ($lastvalue == $statistical_field && ($temp_val == 'contactdetails_lastname'
                        || $temp_val == 'contactdetails_accountid'
                        || $temp_val == 'contactdetails_title'
                        || $temp_val == 'contactdetails_mobile'
                        || $temp_val == 'contactdetails_pphone'
                        || $temp_val == 'salesorder_salesorder_count')
                    && $this->reportname == 'CourseparticipantsKPClist') {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right'>&nbsp;</td>";
                        } else

                            $valtemplate .= "<td  style='text-align:right'>&nbsp;</td>";
                    } else {
                        if ($isSubtotal)
                            $valtemplate .= "<td class='Subtotal'>&nbsp;</td>";
                        else
                            $valtemplate .= "<td >&nbsp;</td>";
                    }
                } else {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        if ($isSubtotal == true && $typeofdata == 'N') {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right' >" . $fieldvalue . "</td>";
                        } elseif ($typeofdata == 'NN' && $isSubtotal != true) {
                            $valtemplate .= "<td style='text-align:right' >" . getDecimalTwoVal($fieldvalue) . "</td>";

                        } elseif ($isSubtotal == true && $typeofdata == 'NN') {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right' >" . getDecimalTwoVal($fieldvalue) . "</td>";
                        } else {
                            $valtemplate .= "<td style='text-align:right' >" . $fieldvalue . "</td>";
                        }
                    } else {
                        if ($isSubtotal == true) {
                            $index = strpos($fieldvalue, getFixedLabel('SUBTOTAL'));

                            //$strnewvalue=substr($fieldvalue,0,$index-1);
                            if ($index > 0)
                                $valtemplate .= "<td class='Subtotal'>" . getFixedlabel('SUBTOTAL') . ":</td>";
                            else
                                $valtemplate .= "<td class='Subtotal'>" . $fieldvalue . "</td>";
                        } else
                            $valtemplate .= "<td>" . $fieldvalue . "</td>";
                    }

                }
            }
            $valtemplate .= "</tr>";

            $lastvalue = $statistical_field;
            $arr_val[] = $arraylists;
            $isSubtotal = false;
        } while ($custom_field_values = $this->adb->fetch_array($result));
        $valtemplate .= "</tr>";
        return $valtemplate;
    }

    private function ListViewTwentySix()
    {
        $this->clearTempotatyTable();
        //$this->clearTempotatyTable();
        //$this->getSQLs();
        $SQL = ReportSQL::getReportSQL($this->reportname, $this->reporttabid);
        $result = $this->adb->query($SQL);

        $y = $this->adb->num_fields($result);

        $custom_field_values = $this->adb->fetch_array($result);

        $total_row = 0;
        $i = 0;
        do {

            $isTotalAll = false;
            $isSubtotal = false;
            if (strstr($custom_field_values[0], getFixedLabel('SUBTOTAL'))) {
                $isSubtotal = true;
                $total_row++;
            }
            if (strstr($custom_field_values[0], getFixedLabel('TOTAL'))) {
                $isTotalAll = true;
                $total_row++;
            }
            $arraylists = Array();
            $newvalue = $custom_field_values[0];

            if ($newvalue == "") $newvalue = "-";
            if ($i % 2 == 0) {
                $valtemplate .= "<tr id='report_$i' class='lvtColData' onmouseover='listOnMouseOver(ld(this))' onmouseout=listOnMouseOut(ld(this),'on')>";
            } else {
                $valtemplate .= "<tr id='report_$i' class='lvtColDataBj' onmouseover='listOnMouseOver(ld(this))' onmouseout=listOnMouseOut(ld(this),'On')>";
            }
            $i++;
            foreach ($this->showcolLists as $temp_val => $keyother) {
                $temp_val = explode(':', $temp_val);
                $typeofdata = $temp_val[1];
                $fieldname = $temp_val[0];
                $temp_val = $temp_val[0];
                $fieldvalue = $custom_field_values[strtolower($temp_val)];

                if (trim($fieldvalue) == "") {
                    $fieldvalue = "-";
                }

                if (($lastvalue == $fieldvalue) && $fieldvalue !== '小计') {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        if ($isTotalAll == true) {
                            $valtemplate .= "<td class='Alltotal' style='text-align:right'>&nbsp;</td>";
                        } elseif ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right'>&nbsp;</td>";
                        } else {
                            $valtemplate .= "<td >&nbsp;</td>";
                        }

                    } else {
                        if ($isTotalAll == true) {
                            $valtemplate .= "<td class='Alltotal' style='text-align:right'>&nbsp;</td>";
                        } elseif ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right'>&nbsp;</td>";
                        } else {
                            $valtemplate .= "<td >&nbsp;</td>";
                        }
                    }

                } else {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        //0015376去掉币种
                        if ($isTotalAll == true) {
                            if ($fieldname == 'HelpDesk_traficfee')
                                $valtemplate .= "<td class='Alltotal' style='text-align:right'>" . getDefaultCurrecySymbol() . getDecimalTwoVal($fieldvalue) . "</td>";
                            else
                                $valtemplate .= "<td class='Alltotal' style='text-align:right'>" . getDecimalTwoVal($fieldvalue) . "</td>";
                        } elseif ($isSubtotal == true) {
                            if ($fieldname == 'HelpDesk_traficfee')
                                $valtemplate .= "<td class='Subtotal' style='text-align:right'>" . getDefaultCurrecySymbol() . getDecimalTwoVal($fieldvalue) . "</td>";
                            else
                                $valtemplate .= "<td class='Subtotal' style='text-align:right'>" . getDecimalTwoVal($fieldvalue) . "</td>";
                        } else {
                            if ($fieldname == 'HelpDesk_traficfee')
                                $valtemplate .= "<td style='text-align:right'>" . getDefaultCurrecySymbol() . getDecimalTwoVal($fieldvalue) . "</td>";
                            else
                                $valtemplate .= "<td style='text-align:right'>" . getDecimalTwoVal($fieldvalue) . "</td>";
                        }

                    } elseif ($fieldname == 'HelpDesk_description' || $fieldname == 'HelpDesk_solution') {
                        /*if($isTotalAll == true){
                            $valtemplate .= "<td class='Alltotal' style='white-space: normal;'>".$fieldvalue."</td>";
                        }elseif($isSubtotal == true){
                            $valtemplate .= "<td class='Subtotal' style='white-space: normal;'>".$fieldvalue."</td>";
                        }else{
                            $valtemplate .= "<td style='white-space: normal;'>".$fieldvalue."</td>";
                        }*/

                        //echo mb_strlen(mb_substr($fieldvalue,0,24,'utf-8'), 'UTF-8');
                        $cstr = '';
                        if (mb_strlen($fieldvalue, 'UTF-8') > 13) {
                            $cstr = '...';
                        }
                        if ($isTotalAll == true) {
                            $valtemplate .= "<td class='Alltotal'>" . mb_substr(strip_tags($fieldvalue), 0, 12, 'utf-8') . $cstr . "</td>";
                        } elseif ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal'>" . mb_substr(strip_tags($fieldvalue), 0, 12, 'utf-8') . $cstr . "</td>";
                        } else {
                            $valtemplate .= "<td>" . mb_substr(strip_tags($fieldvalue), 0, 12, 'utf-8') . $cstr . "</td>";
                        }

                    } else {
                        if ($isTotalAll == true) {
                            $valtemplate .= "<td class='Alltotal'>" . $fieldvalue . "</td>";
                        } elseif ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal'>" . $fieldvalue . "</td>";
                        } else {
                            if ($this->reportname == 'Serviceperformanceappraisal' && $temp_val == 'Accounts_accountname' && $fieldvalue != '' && $fieldvalue != '-') {//服务绩效统计表 客户字段超链接
                                $reportabname = 'Accounts';
                                $accountid = $custom_field_values['accounts_accountid'];
                                $valtemplate .= "<td> <a referencemodule='$reportabname' referencerecord='$accountid' onclick='ListReferenceLinkClick(ld(this),event)' href='javascript:;'>". $fieldvalue . '</a></td>';
                                //$valtemplate .= '<td> <a target=\'_blank\' href=\'index.php?module=' . $reportabname . '&action=DetailView&record=' . $accountid . '\'>' . $fieldvalue . '</a></td>';

                            } else {
                                $valtemplate .= "<td>" . $fieldvalue . "</td>";
                            }

                        }

                    }

                }
            }
            $valtemplate .= "</tr>";
            $lastvalue = $newvalue;
            $arr_val[] = $arraylists;
        } while ($custom_field_values = $this->adb->fetch_array($result));
        $valtemplate .= "</tr>";
        return $valtemplate;
    }

    private function ListViewTwentyFive()
    {
        global $adb;
        $this->clearTempotatyTable();
        //$this->clearTempotatyTable();
        //$this->getSQLs();
        $SQL = ReportSQL::getReportSQL($this->reportname, $this->reporttabid);
        $result = $adb->query($SQL);
        $y = $this->adb->num_fields($result);
        
        $custom_field_values = $this->adb->fetch_array($result);
        $total_row = 0;
        $i = 0;
        $defaultcurrency = getDefaultCurrecySymbol();
        do {

            $isTotalAll = false;

            if (strstr($custom_field_values[0], getFixedLabel('TOTAL'))) {
                $isTotalAll = true;
                $total_row++;
            }
            $arraylists = Array();
            $newvalue = $custom_field_values[0];
            if ($newvalue == "") $newvalue = "-";
            if ($i % 2 == 0) {
                $valtemplate .= "<tr id='report_$i' class='lvtColData' onmouseover='listOnMouseOver(ld(this))' onmouseout=listOnMouseOut(ld(this),'on')>";
            } else {
                $valtemplate .= "<tr id='report_$i' class='lvtColDataBj' onmouseover='listOnMouseOver(ld(this))' onmouseout=listOnMouseOut(ld(this),'On')>";
            }
            $i++;
           
            foreach ($this->showcolLists as $temp_val => $keyother) {
                $temp_val = explode(':', $temp_val);
                $typeofdata = $temp_val[1];
                $typeofdata_decimal = $temp_val[2];
                $fieldname = $temp_val = $temp_val[0];
                $fieldvalue = $custom_field_values[strtolower($temp_val)];
                if(in_array($temp_val,array('OftenUseReport_cashbilltotal','OftenUseReport_salesordertotal','OftenUseReport_expensetotal',
                'OftenUseReport_servicecontractstotal','OftenUseReport_invoicetotal','OftenUseReport_outboundordertotal'))){
                    $typeofdata_decimal = $this->system_deploy_351;
                }
                if(strpos(strtolower($temp_val),'oftenusereport_last_name')!==false){
					//43718: （https://61mis.com/WX/kh41816 [^] ）（自用的最新版本）销售业绩考核表最下方的合计显示错误。
					if ($isTotalAll == false) {
						$wx_userid=$custom_field_values['oftenusereport_wx_userid'];
						$userobj=new Users();
						$userobj->wx_userid=$wx_userid;
						$userobj->last_name=$fieldvalue;
						$fieldvalue=getUserlastName($userobj);
					}
                    
                }
                else if(strpos(strtolower($temp_val),'oftenusereport_groupname')!==false){
					if ($isTotalAll == false) {
						$wx_groupid=$custom_field_values['oftenusereport_groupid'];
						$groupid_arr=explode(',',$wx_groupid);
						$groupname_arr=explode(',',$fieldvalue);
						$groupname_fieldvalue=array();
						foreach($groupid_arr as $tmpgroupindex=>$tmpgroupid){
							$groupobj=new Users();
							$groupobj->groupid=$tmpgroupid;
							$groupobj->groupname=$groupname_arr[$tmpgroupindex];
							$groupname_fieldvalue[]=getWx_GroupName($groupobj);
						}
						$fieldvalue=implode(',',$groupname_fieldvalue);
					}
                }
                $temp_val = $fld->name;
                if (trim($fieldvalue) == "") {
                    $fieldvalue = "-";
                }

                if (($lastvalue == $fieldvalue)) {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {

                        $valtemplate .= "<td  style='text-align:right'>&nbsp;</td>";
                    } else {
                        $valtemplate .= "<td >&nbsp;</td>";
                    }

                } else {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        if ($isTotalAll == true) {

                            if ($this->reportname == 'SalesSumSequence' && ($fieldname == 'OftenUseReport_cashbilltotal' || $fieldname == 'OftenUseReport_salesordertotal'
                                    || $fieldname == 'OftenUseReport_expensetotal' || $fieldname == 'OftenUseReport_servicecontractstotal' || $fieldname == 'OftenUseReport_invoicetotal' || $fieldname == 'OftenUseReport_outboundordertotal')) {
                                $valtemplate .= "<td class='Alltotal' style='text-align:right'>$defaultcurrency" . setNumberFormat($fieldvalue,$typeofdata_decimal) . "</td>";
                            } else {
                                $valtemplate .= "<td class='Alltotal' style='text-align:right'>" . $fieldvalue . "</td>";
                            }
                        } else {
                            //销售业绩考核表 ： 回款额、合同额、费用、服务合同金额 加上人民币符号
                            if ($this->reportname == 'SalesSumSequence' && ($fieldname == 'OftenUseReport_cashbilltotal' || $fieldname == 'OftenUseReport_salesordertotal'
                                    || $fieldname == 'OftenUseReport_expensetotal' || $fieldname == 'OftenUseReport_servicecontractstotal' || $fieldname == 'OftenUseReport_invoicetotal' || $fieldname == 'OftenUseReport_outboundordertotal')) {
                                $valtemplate .= "<td style='text-align:right'>$defaultcurrency" . setNumberFormat($fieldvalue,$typeofdata_decimal) . "</td>";
                            } else {
                                $valtemplate .= "<td style='text-align:right'>" . $fieldvalue . "</td>";
                            }

                        }

                    } else {
                        if ($isTotalAll == true) {
                            $valtemplate .= "<td class='Alltotal'>" . $fieldvalue . "</td>";
                        } else {
                            $valtemplate .= "<td>" . $fieldvalue . "</td>";
                        }

                    }

                }
            }
            $valtemplate .= "</tr>";
            $lastvalue = $newvalue;
            $arr_val[] = $arraylists;
        } while ($custom_field_values = $this->adb->fetch_array($result));
        $valtemplate .= "</tr>";
        return $valtemplate;
    }

    //销售排行榜
    private function ListViewForSalesRanking()
    {
        $this->clearTempotatyTable();
        $SQL = ReportSQL::getReportSQL($this->reportname, $this->reporttabid);
        $result = $this->adb->query($SQL);
        $num_rows = $this->adb->num_rows($result);
        $columns = array('user_last_name', 'groupname', 'cnt');
        $valtemplate = '';
        //单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
        if (isset($sysdeploy['deploy_value']))
            $lengthdecimaldigits = $sysdeploy['deploy_value'];
        else
            $lengthdecimaldigits = 2;
        $totalcount = 0;
        $userobj=new Users();
        $groupobj=new Users();
       
        for ($i = 0; $i < $num_rows; $i++) {
            if ($i % 2 == 0) {
                $valtemplate .= "<tr id='report_$i' class='lvtColData' onmouseover='listOnMouseOver(ld(this))' onmouseout=listOnMouseOut(ld(this),'on')>";
            } else {
                $valtemplate .= "<tr id='report_$i' class='lvtColDataBj' onmouseover='listOnMouseOver(ld(this))' onmouseout=listOnMouseOut(ld(this),'On')>";
            }
            $num = $i + 1;
            $valtemplate .= "<td>" . $num . "</td>";
            foreach ($columns as $columnname) {
                 $value = $this->adb->query_result($result, $i, $columnname);
                if($columnname=='user_last_name'){
                    $userobj->wx_userid=$this->adb->query_result($result, $i, 'report_wx_userid');
                    $userobj->last_name=$value;
                    $value=getUserlastName($userobj);
                    
                }
                else if($columnname=='groupname'){
                    $groupids=explode(',',$this->adb->query_result($result, $i, 'report_wx_groupid'));
                    $groupnames=explode(",",$value);
                    $arr_groupname=array();
                    foreach($groupids as $tmpgroupindex=>$tmpgroupid)
                    {
                        $groupobj->groupid=$tmpgroupid;
                        $groupobj->groupname=$groupnames[$tmpgroupindex];
                        $arr_groupname[]=getWx_GroupName($groupobj);
                    }
                    $value=implode(',',$arr_groupname);
                }
                if ($columnname == 'cnt') {
                    if ($_REQUEST['salesranking_value'] == 'due_num' || $_REQUEST['salesranking_value'] == '')
                        $valtemplate .= "<td style='text-align:right'>" . $fieldvalue = setNumberFormat($value, $lengthdecimaldigits) . "</td>";
                    else
                        $valtemplate .= "<td style='text-align:right'>¥" . $fieldvalue = setNumberFormat($value, $this->system_deploy_351) . "</td>";
                    $totalcount += $value;
                } else {
                    $valtemplate .= "<td>" . $value . "</td>";
                }
            }
            $valtemplate .= "</tr>";
        }
        if ($_REQUEST['salesranking_value'] == 'due_num' || $_REQUEST['salesranking_value'] == ''){
            $totalcount = setNumberFormat($totalcount, $lengthdecimaldigits);
        }else{
            $totalcount = '￥'.setNumberFormat($totalcount, $this->system_deploy_351);
        }
        $valtemplate .= '<tr id="report_32" class="lvtColData" onmouseover="listOnMouseOver(ld(this))"
                 onmouseout="listOnMouseOut(ld(this),\'on\')"><td class="Alltotal">' . getFixedLabel('TOTAL') . '</td>
                 <td class="Alltotal">-</td><td class="Alltotal">-</td><td class="Alltotal" style="text-align:right">' . $totalcount . '</td>
                 </tr>';

        return $valtemplate;
    }

    private function ListViewTwenty()
    {
        $this->clearTempotatyTable();
        $SQL = ReportSQL::getReportSQL($this->reportname, $this->reporttabid);

        $result = $this->adb->query($SQL);
        $y = $this->adb->num_fields($result);
        $custom_field_values = $this->adb->fetch_array($result);
        $total_row = 0;
        //单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
        if (isset($sysdeploy['deploy_value']))
            $lengthdecimaldigits = $sysdeploy['deploy_value'];
        else
            $lengthdecimaldigits = 2;

        $defaultcurrency = getDefaultCurrecySymbol();
        $i = 0;
        do {
            $arraylists = Array();
            $newvalue = $custom_field_values[0];
            if ($newvalue == "") $newvalue = "-";
            if ($i % 2 == 0) {
                $valtemplate .= "<tr id='report_$i' class='lvtColData' onmouseover='listOnMouseOver(ld(this))' onmouseout=listOnMouseOut(ld(this),'on')>";
            } else {
                $valtemplate .= "<tr id='report_$i' class='lvtColDataBj' onmouseover='listOnMouseOver(ld(this))' onmouseout=listOnMouseOut(ld(this),'On')>";
            }
            $i++;
            foreach ($this->showcolLists as $temp_val => $keyother) {
                $temp_val = explode(':', $temp_val);
                $typeofdata = $temp_val[1];
                $fieldname = $temp_val = $temp_val[0];
                $fieldvalue = $custom_field_values[strtolower($temp_val)];
                $temp_val = $fld->name;
                if (trim($fieldvalue) == "") {
                    $fieldvalue = "-";
                }

                if (($lastvalue == $fieldvalue) && $i == 0 && $this->reportname <> 'Contractnumber') {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        $valtemplate .= "<td  style='text-align:right'>&nbsp;</td>";
                    } else {
                        $valtemplate .= "<td >&nbsp;</td>";
                    }

                } else {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        /**
                         * @project PROT75 数量小数位数
                         * @author Tujt 2014-08-14
                         */
                        $fldarr = explode('_', $fieldname);
                        if ($fldarr[1] == 'groupbycount') {
                            $fieldvalue = setNumberFormat($fieldvalue, $lengthdecimaldigits);
                        } else {
                            $fieldvalue = getDecimalTwoVal($fieldvalue);
                        }
                        if ($this->reportname == 'Contractamount' || $this->reportname == 'The billboard of Receivables' || $this->reportname == 'THESINGNINGAMOUNTOFBILLBOARD') {
                            $fieldvalue = $defaultcurrency . $fieldvalue;
                        }

                        $valtemplate .= "<td style='text-align:right'>" . $fieldvalue . "</td>";
                    } else {
                        $valtemplate .= "<td>" . $fieldvalue . "</td>";
                    }

                }
            }
            $valtemplate .= "</tr>";
            $lastvalue = $newvalue;
            $arr_val[] = $arraylists;
        } while ($custom_field_values = $this->adb->fetch_array($result));
        $valtemplate .= "</tr>";

        return $valtemplate;
    }

    private function ListViewtenLink()
    {
        $this->clearTempotatyTable();
        //$this->getSQLs();

        $SQL = ReportSQL::getReportSQL($this->reportname, $this->reporttabid);
        $result = $this->adb->query($SQL);

        $y = $this->adb->num_fields($result);

        $custom_field_values = $this->adb->fetch_array($result);

        $reportabname = getTabname($this->reporttabid);
        $total_row = 0;
        //单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
        if (isset($sysdeploy['deploy_value']))
            $lengthdecimaldigits = $sysdeploy['deploy_value'];
        else
            $lengthdecimaldigits = 2;
        $decimaledreport = false;
        do {
            $isSubtotal = false;
            $isTotalAll = false;
            if (strstr($custom_field_values[0], getFixedLabel('SUBTOTAL'))) {

                $isSubtotal = true;
                $total_row++;
            }
            if (strstr($custom_field_values[0], getFixedLabel('TOTAL'))) {
                $isTotalAll = true;
                $total_row++;
            }
            $arraylists = Array();
            $newvalue = $custom_field_values[0];

            if ($newvalue == "") $newvalue = "-";

            $valtemplate .= "<tr>";
            foreach ($this->showcolLists as $temp_val => $keyother) {

                $temp_val = explode(':', $temp_val);
                $typeofdata = $temp_val[1];
                $temp_val = $temp_val[0];

                $fieldvalue = $custom_field_values[strtolower($temp_val)];
                if (trim($fieldvalue) == "") {
                    $fieldvalue = "-";
                }
                //echo $temp_val.'<br>';
                // echo $custom_field_values;
                if ($temp_val == 'OftenUseReport_yiyongtime' && $isSubtotal != true && $isTotalAll != true && trim($fieldvalue) != '-' && trim($fieldvalue) != '') {
                    if (trim($custom_field_values['potentialid']) == '') {
                        $custom_field_values['potentialid'] = 0;
                    }
                    $valtemplate .= "<td  style='text-align:right' >
                            <a onclick='ViewReportPopup(" . trim($custom_field_values['potentialid']) . ",this);' href='#'>" . setNumberFormat($fieldvalue) . "</a></td>";
                    continue;
                }
                if ($temp_val == 'lbl_action' && $isSubtotal != true && $isTotalAll != true && trim($fieldvalue) != '-' && trim($fieldvalue) != '') {
                    $valtemplate .= "<td> <a referencemodule='$reportabname' referencerecord='$fieldvalue' onclick='ListReferenceLinkClick(ld(this),event)' href='javascript:;'>". getFixedLabel('VIEWDETAILS') . '</a></td>';
                    //$valtemplate .= '<td>
//                            <a target=\'_blank\' href=\'index.php?module=' . $reportabname . '&action=DetailView&record=' . trim($fieldvalue) . '\'>' . getFixedLabel('VIEWDETAILS') . '</a></td>';
                    continue;
                }
                //echo $temp_val;echo "<br>";
                //echo $lastvalue6.'-'.$fieldvalue;echo '<br>';
                if (($lastvalue == $fieldvalue)) {
                    if ($typeofdata == 'N') {
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right'>&nbsp;</td>";
                        } else

                            $valtemplate .= "<td  style='text-align:right'>&nbsp;</td>";
                    } else {
                        if ($isSubtotal)
                            $valtemplate .= "<td class='Subtotal'>&nbsp;</td>";
                        else
                            $valtemplate .= "<td >&nbsp;</td>";
                    }

                } else {
                    if ($typeofdata == 'N' || $typeofdata == 'NN') {
                        /**
                         * @project PROT75 数量小数位数
                         * @author Tujt 2014-08-14
                         */
                        $fld = explode('_', $temp_val);
                        $currency_symbol = $custom_field_values['salesorder_symbol'];
                        if ($decimaledreport && $fld[1] == 'quantity') {
                            $fieldvalue = setNumberFormat($fieldvalue, $lengthdecimaldigits);
                        } else {
                            $fieldvalue = setNumberFormat($fieldvalue);
                        }
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal' style='text-align:right' >" . $fieldvalue . "</td>";
                        } else {
                            if ($isTotalAll == true) {
                                $valtemplate .= "<td class='Alltotal' style='text-align:right' >" . $fieldvalue . "</td>";
                            } else {
                                $valtemplate .= "<td style='text-align:right' >" . $fieldvalue . "</td>";
                            }

                        }
                    } else {
                        if ($isSubtotal == true) {
                            $valtemplate .= "<td class='Subtotal'>" . $fieldvalue . "</td>";
                        } else {
                            if ($isTotalAll == true) {
                                $valtemplate .= "<td class='Alltotal'>" . $fieldvalue . "</td>";
                            } else {
                                $valtemplate .= "<td>" . $fieldvalue . "</td>";
                            }
                        }
                    }

                }
            }
            $valtemplate .= "</tr>";
            $lastvalue = $newvalue;
            $arr_val[] = $arraylists;
            $isSubtotal = false;
        } while ($custom_field_values = $this->adb->fetch_array($result));
        $valtemplate .= "</tr>";
        return $valtemplate;
    }

    /**
     * edit:can
     * date:20131105
     * reason:获取报表SQL数组
     * */
    private function getSQLs()
    {

        $reportSQL = array();
        $startselectcolumns = "ld_crmentity.crmid as LBL_Action";
        $finalselect = "";
        $where = "";
        $totalselect = "'总计' ,";
        $j = 0;
        foreach ($this->AllReportHeaders as $reportheader) {
            $fieldcolumns = explode(':', $reportheader);
            $modulearr = explode('_', $fieldcolumns[3]);
            $module = $modulearr[0];
            // echo $module.'<br>';
            if (strtolower($module) != 'oftenusereport') {
                $sql = 'select uitype from ld_field where columnname=? and tabid in(select tabid from ld_tab where name=?)';
                $fieldresult = $this->adb->pquery($sql, array($fieldcolumns[1], $module));
                $uitype = $this->adb->query_result($fieldresult, 0, 0);
                switch ($uitype) {
                    case 57://联系人
                        $startselectcolumns .= ' , ' . $fieldcolumns[0] . '.lastname as ' . $module . '_' . $fieldcolumns[1];
                        break;
                    case 73://客户
                        $startselectcolumns .= ' , ' . $fieldcolumns[0] . '.accountname as ' . $module . '_' . $fieldcolumns[1];
                        break;
                    case 53://用户
                        $startselectcolumns .= ' , ' . $fieldcolumns[0] . '.last_name as ' . $module . '_' . $fieldcolumns[1];
                        break;
                    default:
                        $startselectcolumns .= ', ' . $fieldcolumns[0] . '.' . $fieldcolumns[1] . ' as ' . $module . '_' . $fieldcolumns[1];
                }
            }

            if (strtolower($fieldcolumns[4]) == 'n') {
                $totalselect .= 'sum( ' . $module . '_' . $fieldcolumns[1] . ') ' . $module . '_' . $fieldcolumns[1] . ',';
            } elseif ($j != 0)//总计已经是一列了
            {
                $totalselect .= " '' ,";

            }
            $j++;
            $finalselect .= $module . '_' . $fieldcolumns[1] . ',';
        }
        $finalselect .= '1 ';
        $totalselect .= '1 ';
        $this->where = $where;
        $this->startselect = $startselectcolumns;
        $this->finalselect = $finalselect;
        $this->totalselect = $totalselect;
        $sql = 'select  usewhere from ld_usereportfilter where usereportid=? order by sequence';
        $result = $this->adb->pquery($sql, array($this->usereportid));
        for ($i = 0; $i < $this->adb->num_rows($result); $i++) {
            $SQL = $this->adb->query_result($result, $i, 'usewhere');
            if (strpos(strtolower($SQL), '{$startselect}') > 0) {
                $SQL = str_replace('{$startselect}', $startselectcolumns, strtolower($SQL));
            }
            if (strpos(strtolower($SQL), '{$where}') > 0) {
                $SQL = str_replace('{$where}', $where, strtolower($SQL));
            }
            if (strpos(strtolower($SQL), '{$totalselect}') > 0) {
                $SQL = str_replace('{$totalselect}', $totalselect, strtolower($SQL));
            }
            if (strpos(strtolower($SQL), '{$finalselect}') > 0) {
                $SQL = str_replace('{$finalselect}', $finalselect, strtolower($SQL));
            }
            $reportSQL[] = $SQL;

        }
        return $reportSQL;
    }

    function clearTempotatyTable()
    {
        global $adb;
        $sSQL5 = "drop TEMPORARY  table if exists temptable4;";
        $result1 = $adb->query($sSQL5);
        $sSQL5 = "drop TEMPORARY  table if exists temptable3;";
        $result1 = $adb->query($sSQL5);
        $sSQL5 = "drop TEMPORARY  table if exists temptable2;";
        $result1 = $adb->query($sSQL5);
        $sSQL5 = "drop TEMPORARY  table if exists temptable1;";
        $result1 = $adb->query($sSQL5);
        $sSQL5 = "drop TEMPORARY  table if exists temptable;";
        $result1 = $adb->query($sSQL5);
        $sSQL6 = "drop TEMPORARY  table if exists temptable8;";
        $result1 = $adb->query($sSQL6);
        $sSQL7 = "drop TEMPORARY  table if exists temptable5;";
        $result1 = $adb->query($sSQL7);
        $sSQL11 = "drop TEMPORARY  table if exists temptable11;";
        $result1 = $adb->query($sSQL11);
        $sSQL8 = "drop TEMPORARY  table if exists temptable100;";
        $result1 = $adb->query($sSQL8);
        $sSQL8 = "drop TEMPORARY  table if exists temptable6;";
        $result1 = $adb->query($sSQL8);
        $sSQL8 = "drop TEMPORARY  table if exists temptable7;";
        $result1 = $adb->query($sSQL8);
        $sSQL8 = "drop TEMPORARY  table if exists temptable12;";
        $result1 = $adb->query($sSQL8);
        $sSQL8 = "drop TEMPORARY  table if exists temptable13;";
        $result1 = $adb->query($sSQL8);
        $sSQL8 = "drop TEMPORARY  table if exists temptable14;";
        $result1 = $adb->query($sSQL8);
        $sSQL8 = "drop TEMPORARY  table if exists temptable15;";
        $result1 = $adb->query($sSQL8);
        $sSQL8 = "drop TEMPORARY  table if exists temptable16;";
        $result1 = $adb->query($sSQL8);
        $sSQL8 = "drop TEMPORARY  table if exists temptable17;";
        $result1 = $adb->query($sSQL8);
        $sSQL8 = "drop TEMPORARY  table if exists temptable18;";
        $result1 = $adb->query($sSQL8);
        $sSQL8 = "drop TEMPORARY  table if exists temptable19;";
        $result1 = $adb->query($sSQL8);
    }

    /**
     * //应收款汇总表 ：金蝶KIS旗舰版
     * @param
     * @author Chj 2015/5/12
     */
    function getAccountingReceivable()
    {
        $sa = getDatainterface('sa');    //获取DB用户名
        $pwd = getDatainterface('pwd');//获取DB密码
        $hostname = getDatainterface('hostname');//获取服务器IP地址
        $databasename = getDatainterface('databasename');//获取DB name
        $soft_version = getDatainterface('soft_version');//获取金蝶版本 1：kis3 2：金蝶专业版 5:金蝶旗舰版
        require_once("mssql/SqlServer.php");
        //链接数据库
        $SqlCon = new SqlServer($sa, $pwd, $databasename, $hostname);
        $conResult = $SqlCon->Connect();
        //区域条件
        if (isset($_REQUEST['address'])) {
            $RegionSql = " and b.FCustomer  in(select FItemID from vw_rp_companyinfo   where 1=1  and FRegionNumber='" . $_REQUEST['address'] . "')";
            $FSupplySql = " and b.FSupplyID  in(select FItemID from vw_rp_companyinfo   where 1=1  and FRegionNumber='" . $_REQUEST['address'] . "')";
        }
        //客户名称
        if (isset($_REQUEST['orgfname'])) {
            $orgfname = convert2gbk($_REQUEST['orgfname']);
        }
        //业务人员代码编号
        if (isset($_REQUEST['fname'])) {
            $fname = " and e.FNumber='" . $_REQUEST['fname'] . "'";
        } else {
            $FNameArr = InterfaceClass::AccountingReceivable(2);//获取当前用户有权限看到的所有职员
            $keys = array_keys($FNameArr);
            if (!empty($keys)) {
                foreach ($keys as $val) {
                    $FNumSql[] = " e.FNumber = '" . $val . "'";
                }
                $fname = " and (" . implode('or', $FNumSql) . ")";
            }
        }
        //时间区间
        if (isset($_REQUEST['startdate'])) {
            $startdate = explode('-', date('Y-n', strtotime($_REQUEST['startdate'])));
            $start_monthlen = $startdate[0] * 12 + $startdate[1];//获取年月份总数
            if ($start_monthlen > 24182) {

            }
        }
        if (isset($_REQUEST['enddate'])) {
            $enddate = explode('-', date('Y-n', strtotime($_REQUEST['enddate'])));
            $end_monthlen = $enddate[0] * 12 + $enddate[1];
            //获取年月份  差集
            $starttime = strtotime($_REQUEST['startdate']); // 自动为00:00:00 时分秒
            $endtime = strtotime($_REQUEST['enddate']);
            $monarr = array();
            $monarr[] = date('Y-n', strtotime($_REQUEST['startdate'])); // 开始月
            while (($starttime = strtotime('+1 month', $starttime)) <= $endtime) {
                $monarr[] = date('Y-n', $starttime); // 取得递增月
            }
            $this->mouthlen = count($monarr);
        } else {
            if (!empty($startdate)) {
                $end_monthlen = $startdate[0] * 12 + $startdate[1];
                $monarr[] = date('Y-n', strtotime($_REQUEST['startdate'])); // 开始月
            }
            $this->mouthlen = 1;
        }
        if (isset($_REQUEST['startdate']) && isset($_REQUEST['enddate']) && ($_REQUEST['startdate'] == $_REQUEST['enddate'])) {
            $startdate = explode('-', date('Y-n', strtotime($_REQUEST['startdate'])));
            $s_len = $start_monthlen = $startdate[0] * 12 + $startdate[1];//获取年月份总数
            $end_monthlen = $start_monthlen;
            if ($start_monthlen > 24182) {
                $start_monthlen = 24182;
                $sql_year = "and ((b.FYear*12+b.FPeriod>$start_monthlen
				 and b.FYear*12+b.FPeriod<$end_monthlen
				 and b.FStatus & 1 = 1 and b.FStatus & 16 = 0)
				 or (b.FYear*12+b.FPeriod<$end_monthlen
				 and b.FStatus = 0 and b.FStatus & 16 = 0)) ";
            } else {
                $sql_year = " and (b.FYear*12+b.FPeriod<$start_monthlen 
				and b.FStatus = 0 and b.FStatus & 16 = 0 ) ";
            }
            $where_len = $end_monthlen;
        } else {
            $startdate = explode('-', date('Y-n', strtotime($_REQUEST['startdate'])));
            $s_len = $start_monthlen = $startdate[0] * 12 + $startdate[1];//获取年月份总数
            if ($start_monthlen > 24182) {
                $sql_year = "and ((b.FYear*12+b.FPeriod>24182
				 and b.FYear*12+b.FPeriod<$start_monthlen
				 and b.FStatus & 1 = 1 and b.FStatus & 16 = 0)
				 or (b.FYear*12+b.FPeriod<$start_monthlen
				 and b.FStatus = 0 and b.FStatus & 16 = 0)) ";
            } else {
                $sql_year = " and (b.FYear*12+b.FPeriod<$start_monthlen 
				and b.FStatus = 0 and b.FStatus & 16 = 0 ) ";
            }
            //echo $sql_year;
            $where_len = $start_monthlen;
        }
        $SQL = '
			drop Table tempSubTable;
			drop Table TempInitForSubTable;
			drop Table TTempGen;
			drop Table TTempGenDetail;
			drop Table TTempGenTable;
			Create Table tempSubTable(
			   FDate DateTime, 
			   FFincDate DateTime, 
			   FBillType varchar(355), 
			   FNumber varchar(355), 
			   FSubBillType varchar(355), 
			   FVoucherNo varchar(355), 
			   FJSBillNo varchar(355), 
			   FAccountName varchar(355), 
			   FExplanation varchar(510), 
			   FContractNo varchar(355), 
			   FDepartment int default(0), 
			   FDeptName varchar(355), 
			   FClassTypeID int default(0), 
			   FTranType int default(0),
			   FInterID int default(0),
			   FImport int default(0), 
			   FEmployee int default(0), 
			   FEmpName varchar(355), 
			   FMustRPAmountFor decimal(28,4), 
			   FMustRPAmount decimal(28,4), 
			   FRPAmountFor decimal(28,4), 
			   FRPAmount decimal(28,4), 
			   FDiscountAmountFor decimal(28,4), 
			   FDiscountAmount decimal(28,4), 
			   FSumSort int default(0), 
			   FEndBalanceFor decimal(28,4), 
			   FEndBalance decimal(28,4), 
			   FBillID int default(0), 
			   FType int default(0), 
			   FPre int default(0), 
			   FYear int default(0), 
			   FPeriod int default(0), 
			   FCurrencyID int null, 
			   FCurrencyName varchar(355), 
			   FCustomer varchar(355) 
			);
			Create Table TempInitForSubTable(
				FYear int default(0),
				FMustRPAmountFor decimal(28,4) default(0),
				FMustRPAmount decimal(28,4) default(0),
				FRPAmountFor decimal(28,4) default(0),
				FRPAmount decimal(28,4) default(0),
				FEndBalanceFor decimal(28,4) default(0),
				FEndBalance decimal(28,4) default(0),
				FCurrencyID int null, 
				FCustomer int default(0),
				FDepartment int default(0),
				FEmployee int default(0)
			);
			CREATE TABLE TTempGen(FSonCompany VarChar(255) null,
				FLngYear int null,
				FLngPeriod int null,
				FCustomer int null,
				FCurrencyID int null, 
				FPeriod varchar(255) null,
				FNumber Varchar(255) null,
				FName varchar(255) null,
				FDepartment int null,
				FDeptNumber Varchar(255) null,
				FDeptName varchar(255) null,
				FEmployee int null,
				FEmpNumber Varchar(255) null,
				FEmpName varchar(255) null,
				FExplanation Varchar(200) null,
				FLevelID int not null default(0),
				FBegAmount decimal(28,4) null default(0),
				FBegAmountFor decimal(28,4) null default(0),
				FMustRPAmount decimal(28,4) null default(0),
				FMustRPAmountFor decimal(28,4) null default(0),
				FRPAmount decimal(28,4) null default(0),
				FRPAmountFor decimal(28,4) null default(0),
				FEndBalance decimal(28,4) null default(0),
				FEndBalanceFor decimal(28,4) null default(0),
				FYearRPAmount decimal(28,4) null default(0),
				FYearRPAmountFor decimal(28,4) null default(0),
				FYearMustRPAmount decimal(28,4) null default(0),
				FYearMustRPAmountFor decimal(28,4) null default(0),
				FDispRPAmtFor bit null,
				FDispAmtFor decimal(28,4) null default(0), 
				FDispEndBal decimal(28,4) null default(0),
				FType int null,
				FIsNewYear int null,
				FSumSort int null default(0),
				FIsOcc int null default(0),
				FAmountDecimal int default(2)
			);
			CREATE TABLE TTempGenDetail(FSonCompany VarChar(255) null,
				FLngYear int null,
				FLngPeriod int null,
				FCustomer int null,
				FCurrencyID int null, 
				FPeriod varchar(255) null,
				FNumber Varchar(255) null,
				FName varchar(255) null,
				FDepartment int null,
				FDeptNumber Varchar(255) null,
				FDeptName varchar(255) null,
				FEmployee int null,
				FEmpNumber Varchar(255) null,
				FEmpName varchar(255) null,
				FExplanation Varchar(510) null,
				FLevelID int not null default(0),
				FBegAmount decimal(28,4) null default(0),
				FBegAmountFor decimal(28,4) null default(0),
				FMustRPAmount decimal(28,4) null default(0),
				FMustRPAmountFor decimal(28,4) null default(0),
				FRPAmount decimal(28,4) null default(0),
				FRPAmountFor decimal(28,4) null default(0),
				FEndBalance decimal(28,4) null default(0),
				FEndBalanceFor decimal(28,4) null default(0),
				FYearRPAmount decimal(28,4) null default(0),
				FYearRPAmountFor decimal(28,4) null default(0),
				FYearMustRPAmount decimal(28,4) null default(0),
				FYearMustRPAmountFor decimal(28,4) null default(0),
				FDispRPAmtFor bit null,
				FDispAmtFor decimal(28,4) null default(0), 
				FDispEndBal decimal(28,4) null default(0),
				FType int null,
				FIsNewYear int null,
				FSumSort int null default(0),
				FIsOcc int null default(0),
				FAmountDecimal int default(2)
			);
			CREATE CLUSTERED INDEX idx_temp ON TTempGenDetail  (FCustomer,FlngYear,FlngPeriod);
			CREATE TABLE TTempGenTable(FSonCompany VarChar(255) null,
				FLngYear int null,
				FLngPeriod int null,
				FCustomer int null,
				FCurrencyID int null, 
				FPeriod varchar(255) null,
				FNumber Varchar(255) null,
				FName varchar(255) null,
				FDepartment int null,
				FDeptNumber Varchar(255) null,
				FDeptName varchar(255) null,
				FEmployee int null,
				FEmpNumber Varchar(255) null,
				FEmpName varchar(255) null,
				FExplanation Varchar(510) null,
				FLevelID int not null default(0),
				FBegAmount decimal(28,4) null default(0),
				FBegAmountFor decimal(28,4) null default(0),
				FMustRPAmount decimal(28,4) null default(0),
				FMustRPAmountFor decimal(28,4) null default(0),
				FRPAmount decimal(28,4) null default(0),
				FRPAmountFor decimal(28,4) null default(0),
				FEndBalance decimal(28,4) null default(0),
				FEndBalanceFor decimal(28,4) null default(0),
				FYearRPAmount decimal(28,4) null default(0),
				FYearRPAmountFor decimal(28,4) null default(0),
				FYearMustRPAmount decimal(28,4) null default(0),
				FYearMustRPAmountFor decimal(28,4) null default(0),
				FDispRPAmtFor bit null,
				FDispAmtFor decimal(28,4) null default(0), 
				FDispEndBal decimal(28,4) null default(0),
				FType int null,
				FIsNewYear int null,
				FSumSort int null default(0),
				FIsOcc int null default(0),
				FSort int null default(0),
				FAmountDecimal int default(2)
			);
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
			SET NOCOUNT OFF;
			';
        $SqlCon->Query_result($SQL);
        //插入期初数据
        //echo $start_monthlen;echo '<br><br>';echo $end_monthlen;echo '<br><br>';echo $startdate[0];echo '<br><br>';
        //echo $sql_year;echo '<br><br>';
        $insert_TempInitForSubTable = "Insert Into TempInitForSubTable(FYear,FCustomer,FDepartment,FEmployee,
					FMustRPAmountFor,FMustRPAmount,FRPAmountFor,FRPAmount,FEndBalanceFor,FEndBalance,FCurrencyID)";
        if ($s_len > 24182) {
            $insert_TempInitForSubTable .= "
				Select FYear,FCustomer,FDepartment,FEmployee,sum(FYtdDebitFor),sum(FYtdDebit),sum(FYtdCreditFor),sum(FYtdCredit),sum(FEndBalanceFor),sum(FEndBalance),b.FCurrencyID
				From t_rp_contactbal b 
				 join t_item k on b.FCustomer = k.FItemID and k.FName like '%$orgfname%'
				 left join t_item d on b.FDepartment = d.FItemID 
				 left join t_item e on b.FEmployee = e.FItemID  
				 left join t_account t on b.FAccountID = t.FAccountID 
				 where b.FRP=1 and b.FItemClassID=1 $fname
				 and b.FCurrencyID=1
				 and b.FYear*12+b.FPeriod=24182
				 Group by b.FYear,b.FCustomer,FDepartment,FEmployee,b.FCurrencyID
			";
        } else {
            $insert_TempInitForSubTable .= "
				Select FYear,FCustomer,FDepartment,FEmployee,sum(FYtdDebitFor - FDebitFor),sum(FYtdDebit - FDebit),sum(FYtdCreditFor - FCreditFor),sum(FYtdCredit - FCredit),sum(FBeginBalanceFor),sum(FBeginBalance),b.FCurrencyID
				From t_rp_contactbal b 
				 join t_item k on b.FCustomer = k.FItemID and k.FName like '%$orgfname%'
				 left join t_item d on b.FDepartment = d.FItemID 
				 left join t_item e on b.FEmployee = e.FItemID  
				 left join t_account t on b.FAccountID = t.FAccountID 
				 where b.FRP=1 and b.FItemClassID=1 $fname 
				 and b.FCurrencyID=1
				 and b.FYear*12+b.FPeriod=$start_monthlen
				 Group by b.FYear,b.FCustomer,FDepartment,FEmployee,b.FCurrencyID
			";
        }
        $insert_TempInitForSubTable .= "
			Union All 
				Select FYear,FCustomer,FDepartment,FEmployee,sum(case when FType = 9 then -FAmountFor else FAmountFor end),sum(case when FType = 9 then -FAmount else FAmount end),
				0,0,sum(case when FType = 9 then -FAmountFor else FAmountFor end),sum(case when FType = 9 then -FAmount else FAmount end),b.FCurrencyID 
				From (
						select b.FDate,b.FFincDate,b.FAmount,b.FAmountFor,b.FIsinit,b.FType,b.FCustomer,b.FEmployee,b.FInvoiceType,
							b.FDepartment , b.FRP, b.FPeriod, b.FYear, b.FStatus, b.FItemClassID, b.FCurrencyID,
							(case b.FIsinit when 1 then s1.FAccountID else(case when b.FType>=1 and b.FType<=2 then s2.FAccountID
							when b.FType=3 then s3.FCussentAcctID when b.FType=4 then s3.FCussentAcctID else b.FAccountID end )end)FAccountID
						from  t_rp_contact b
						left join  t_rp_begData s1 on b.FBegID=s1.FInterID and b.FIsinit=1
						left join  t_rp_arpbill s2 on b.FRPBillID=s2.FBillID and b.FType=1
						left join  icsale s3 on b.FInvoiceID=s3.FInterID and b.FType=3
						where b.FRP=1 and b.FType in (1,3,11,13,9) and isnull(s3.FCancellation,0) <> 1 ) b
				 join t_item k on b.FCustomer = k.FItemID and k.FName like '%$orgfname%'
				 left join t_item d on b.FDepartment = d.FItemID 
				 left join t_item e on b.FEmployee = e.FItemID  
				 left join t_account t on b.FAccountID = t.FAccountID 
				 where b.FRP=1 and b.FItemClassID=1 $fname
				 and b.FCurrencyID=1
				 and b.FInvoiceType not in (3,4)
				 and b.FType in (1,3,9)
				 $sql_year 
				 Group by b.FYear,b.FCustomer,FDepartment,FEmployee,b.FCurrencyID
			Union All 
				Select FYear,FCustomer,FDepartment,FEmployee,
				  sum(CASE b.FISBAD WHEN 1 THEN isnull(tb.FAmountFor,0) ELSE 0 END) as FAmountFor,
				  sum(CASE b.FISBAD WHEN 1 THEN isnull(tb.FAmount,0) ELSE 0 END) as FAmount,
				  sum(b.FAmountFor) as ReceiveAmountFor,
				  sum(b.FAmount) as ReceiveAmount,
				  sum(CASE b.FISBAD WHEN 1 THEN isnull(tb.FAmountFor,0) ELSE 0 END - (b.FAmountFor))  FEndBalanceFor,
				  sum(CASE b.FISBAD WHEN 1 THEN isnull(tb.FAmount,0) ELSE 0 END - (b.FAmount)) FEndBalance,b.FCurrencyID
				From (
						select b.FClassTypeID,b.FBillID as FInterID,0 as FID,b.FYear,b.FPeriod, b.FRP as FRP,(case when b.FRP = 0 then 6 else 5 end) as FType,b.FDate as FDate,isnull(b.FFincDate,b.FDate) as FFincDate,b.FNumber as FNumber,
							b.FPre,b.FCustomer as FCustomer,b.FDepartment as FDepartment,b.FEmployee as FEmployee,b.FCurrencyID,b.FExchangeRate,b.FContractNo,
							case when b.FPre = -1 then (-1)*(isnull(a.FSettleAmount,0)+isnull(a.FDiscount,0)) else isnull(a.FSettleAmount,0)+isnull(a.FDiscount,0) end FAmount,
							case when b.FPre = -1 then (-1)*(isnull(a.FSettleAmountFor,0)+isnull(a.FDiscountFor,0)) else isnull(a.FSettleAmountFor,0)+isnull(a.FDiscountFor,0) end FAmountFor,
							case when b.FPre = -1 then (-1)*a.FRemainAmount else a.FRemainAmount end FRemainAmount,
							case when b.FPre = -1 then (-1)*a.FRemainAmountFor else a.FRemainAmountFor end FRemainAmountFor,
							isnull(ct.Fisbad,0) as FIsBad,b.FVoucherID as FVoucherID,v.FGroupID as FGroupID,a.FAccountID as FAccountID,0 as FIsInit,b.FStatus as FStatus,
							b.FBillType as FDetailBillType,c1.FName as FDetailBillTypeName,0 as FInvoiceType,b.FItemClassID,b.FExplanation FExplanation,
						   b.FSubSystemID,0 as FTranType,CAST(v1.FName AS Nvarchar(30))+'-'+CAST(v.FNumber AS Nvarchar(30))  as FVoucherNo,bt.FName as FBillTypeName,'' as FJSBillNo
						from t_rp_newreceivebill b
						 join t_rp_contact ct on ct.FBillID=b.FBillID and ct.FType = 5
						 join t_rp_arbillofsh a on b.fbillid=a.fbillid
						 left join t_rp_billType bt on b.FClasstypeid=bt.FID
						 left join t_voucher v on b.FVoucherID=v.FVoucherID
						 left join t_VoucherGroup v1 on v.FGroupID=v1.FGroupID
						 left join t_rp_systemEnum c1 on b.FBillType= c1.FItemID
						Where (b.FSubSystemID = 0 Or (b.FSubSystemID = 1 And fconfirm = 1)) and b.FRP = 1) b
				 join t_item k on b.FCustomer = k.FItemID and k.FName like '%$orgfname%'
				 left join t_item d on b.FDepartment = d.FItemID 
				 left join t_item e on b.FEmployee = e.FItemID  
				 left join t_account t on b.FAccountID = t.FAccountID 
				 left join (select FReContactID,sum(FAmount) as FAmount,sum(FAmountFor) as FAmountFor
						From t_RP_NewBadDebt
						Where IsNull(FType, 0) = 0 And FReContactID > 0
						group by FReContactID) tb on b.FInterID=tb.FReContactID
				 where b.FRP=1 and b.FItemClassID=1 $fname
				 and b.FCurrencyID=1
				 $sql_year
				 Group by b.FYear,b.FCustomer,FDepartment,FEmployee,b.FCurrencyID
			Union All 
				Select FYear,FCustomer,FDepartment,FEmployee,sum(FAmountFor),sum(FAmount),
				  sum(case when b.FInvoicetype in (3,4) then FAmountFor else 0 end),
				  sum(case when b.FInvoicetype in (3,4) then FAmount else 0 end),
				  sum(case when b.FInvoicetype in (3,4) then 0 else FAmountFor end),
				  sum(case when b.FInvoicetype in (3,4) then 0 else FAmount end),b.FCurrencyID 
				From t_rp_contact b
				 join t_item k on b.FCustomer = k.FItemID and k.FName like '%$orgfname%'
				 left join t_item d on b.FDepartment = d.FItemID 
				 left join t_item e on b.FEmployee = e.FItemID  
				 left join t_account t on b.FAccountID = t.FAccountID 
				 where b.FRP=1 and b.FItemClassID=1 $fname
				 and b.FCurrencyID=1
				 and b.FInvoiceType in (3,4)
				 and b.FType in (1,3)
				 and (b.FYear*12+b.FPeriod<$start_monthlen and b.FYear = $startdate[0]
				 and b.FStatus & 16 = 0) 
				 Group by b.FYear,b.FCustomer,FDepartment,FEmployee,b.FCurrencyID
			 	Union All 
				Select isnull(tp.FYear,0),b.FSupplyID,FDeptID,FEmpID,
				  sum(case when ty.FEquityHook=1 then 0 when a.FQty=0  then 0 else ((a.FQty-isnull(tz.FHookQty,0))*a.FConsignAmount/a.FQty) end) FAmountFor,
				  sum(case when ty.FEquityHook=1 then 0 when a.FQty=0  then 0 else ((a.FQty-isnull(tz.FHookQty,0))*a.FConsignAmount/a.FQty) end) FAmount,
				  0,0,sum(case when ty.FEquityHook=1 then 0 when a.FQty=0  then 0 else ((a.FQty-isnull(tz.FHookQty,0))*a.FConsignAmount/a.FQty) end ) FEndBalanceFor,
				  sum(case when ty.FEquityHook=1 then 0 when a.FQty=0  then 0 else ((a.FQty-isnull(tz.FHookQty,0))*a.FConsignAmount/a.FQty) end ) FEndBalance,1 
				From ICStockBill b
				join ICStockBillEntry a on a.FInterID=b.FInterID
				left join t_Voucher v on b.FVchInterID=v.FVoucherID
				left join t_perioddate tp on b.FDate>=tp.FStartDate and b.FDate<=tp.FEndDate
				left join (select fibinterid,fentryid, sum(fhookqty) as fhookqty from  icHookRelations
								  where FIBTag=1 and ftrantype<>1002523 and (Fyear*12 + FPeriod) <=$end_monthlen
								  group by fibinterid,fentryid ) tz on a.finterid=tz.fibinterid and a.fentryid=tz.fentryid
				 left join (select fibinterid,FEquityHook from  icHookRelations
								  where FIBTag=1 and FEquityHook=1 and (Fyear*12 + FPeriod) <=$end_monthlen
								  group by fibinterid,FEquityHook) ty on b.finterid=ty.fibinterid
				 join t_item k on b.FSupplyID = k.FItemID and k.FName like '%$orgfname%'
				 left join t_item d on b.FDeptID = d.FItemID 
				 left join t_item e on b.FEmpID = e.FItemID  
				 left join t_account t on b.FCussentAcctID = t.FAccountID 
				 where 1=1 and 1=1 $fname
				 and 1=1
				 and (tp.FYear*12+tp.FPeriod <$start_monthlen or tp.FYear is null)
				 and b.FTranType = 21 and b.FCancellation<>1 and not exists  (select 1 From ICHookRelations Where FIBTag=4  and FIBInterID=b.finterid)
				 Group by isnull(tp.FYear,0),b.FSupplyID,FDeptID,FEmpID";
        $SqlCon->Query_result($insert_TempInitForSubTable);
        //插入期间数据
        $insert_tempSubTable .= "
					Insert into tempSubTable (FDate,FFincDate,FBillType,FNumber,FSubBillType,FVoucherNo,FJSBillNo,FAccountName,FExplanation,FDepartment,FEmployee,
    FContractNo,FDeptName,FClassTypeID,FTranType,FInterID,FImport,FEmpName,FMustRPAmountFor,FMustRPAmount,
    FRPAmountFor,FRPAmount,FDiscountAmountFor,FDiscountAmount,FSumSort,FEndBalanceFor,FEndBalance,FBillID,FType,FPre,FYear,FPeriod,FCurrencyName,FCustomer)
					Select  '','','','','','','','','',b.FDepartment,b.FEmployee,'','',0,0,0,0,'',
                      sum(b.famountfor),sum(b.famount),
                      sum(case when b.FInvoiceType in (3,4) then b.FAmountFor else 0 end),
                      sum(case when b.FInvoiceType in (3,4) then b.FAmount else 0 end),0,0,0,
                      sum(case when b.FInvoiceType in (3,4) then 0 else b.FAmountFor end)  FEndBalanceFor,
                      sum(case when b.FInvoiceType in (3,4) then 0 else b.FAmount end) FEndBalance,
                      0 FBillID,0 FType,0 FPre,b.FYear FYear,b.FPeriod FPeriod,b.FCurrencyID,b.FCustomer
                    From (
                            select b.FDate,b.FFincDate,b.FAmount,b.FAmountFor,b.FIsinit,b.FType,b.FCustomer,b.FEmployee,b.FInvoiceType,
                                b.FDepartment , b.FRP, b.FPeriod, b.FYear, b.FStatus, b.FItemClassID, b.FCurrencyID,
                                (case b.FIsinit when 1 then s1.FAccountID else(case when b.FType>=1 and b.FType<=2 then s2.FAccountID
                                when b.FType=3 then s3.FCussentAcctID when b.FType=4 then s3.FCussentAcctID else b.FAccountID end )end)FAccountID
                            from  t_rp_contact b
                            left join  t_rp_begData s1 on b.FBegID=s1.FInterID and b.FIsinit=1
                            left join  t_rp_arpbill s2 on b.FRPBillID=s2.FBillID and b.FType=1
                            left join  icsale s3 on b.FInvoiceID=s3.FInterID and b.FType=3
                            where b.FRP=1 and b.FType in (1,3,11,13,9) and isnull(s3.FCancellation,0) <> 1 ) b
                     join t_item k on b.FCustomer = k.FItemID and k.FName like '%$orgfname%'
                     left join t_item d on b.FDepartment = d.FItemID 
                     left join t_item e on b.FEmployee = e.FItemID  
                     left join t_account t on b.FAccountID = t.FAccountID 
                     where b.FRP=1 and b.FItemClassID=1 $fname 
                     and b.FCurrencyID=1 $RegionSql
                     and b.FYear*12+b.FPeriod>=$where_len and b.FYear*12+b.FPeriod<=$end_monthlen
                     and b.FStatus & 16 = 0 
                     and b.FType in (1,2,3,4) and b.FIsinit<>1 
                     Group By b.FDepartment,b.FEmployee,b.fyear,b.fperiod,b.FCurrencyID,b.fcustomer
				 Union All
                     Select  b.FDate,b.FFincDate,b.FBillTypeName,b.FNumber,b.FDetailBillTypeName as FDetailBillTypeName,b.FVoucherNo,b.FJSBillNo,t.fName,
                      case b.FIsBad when 1 then '' else b.FExplanation end as FExplanation,b.FDepartment,b.FEmployee,
                      b.FContractNo,d.FName,b.fClasstypeID,0,b.FInterID,b.FSubsystemid,e.fName,
                      sum(CASE b.FISBAD WHEN 1 THEN isnull(tb.FAmountFor,0) ELSE 0 END) as FAmountFor, 
                      sum(CASE b.FISBAD WHEN 1 THEN isnull(tb.FAmount,0) ELSE 0 END) as FAmount,
                      sum(b.FAmountFor) as ReceiveAmountFor,
                      sum(b.FAmount) as ReceiveAmount,
                      0,0,0 as FSumSort,
                      sum(CASE b.FISBAD WHEN 1 THEN isnull(tb.FAmountFor,0) ELSE 0 END) - sum(b.FAmountFor)  FEndBalanceFor,sum(CASE b.FISBAD WHEN 1 THEN isnull(tb.FAmount,0) ELSE 0 END) - sum(b.FAmount) FEndBalance,
                      0 FBillID,case when min(b.FClassTypeID) in (1000016,1000005) then 2 when min(b.FClassTypeID) in (1000017,1000015) then 3 else 4 end FType,0 FPre,b.FYear FYear,b.FPeriod FPeriod,b.FCurrencyID,b.FCustomer
                    From (
                            select b.FClassTypeID,b.FBillID as FInterID,0 as FID,b.FYear,b.FPeriod, b.FRP as FRP,(case when b.FRP = 0 then 6 else 5 end) as FType,b.FDate as FDate,isnull(b.FFincDate,b.FDate) as FFincDate,b.FNumber as FNumber,
                                b.FPre,b.FCustomer as FCustomer,b.FDepartment as FDepartment,b.FEmployee as FEmployee,b.FCurrencyID,b.FExchangeRate,b.FContractNo,
                                case when b.FPre = -1 then (-1)*(isnull(a.FSettleAmount,0)+isnull(a.FDiscount,0)) else isnull(a.FSettleAmount,0)+isnull(a.FDiscount,0) end FAmount,
                                case when b.FPre = -1 then (-1)*(isnull(a.FSettleAmountFor,0)+isnull(a.FDiscountFor,0)) else isnull(a.FSettleAmountFor,0)+isnull(a.FDiscountFor,0) end FAmountFor,
                                case when b.FPre = -1 then (-1)*a.FRemainAmount else a.FRemainAmount end FRemainAmount,
                                case when b.FPre = -1 then (-1)*a.FRemainAmountFor else a.FRemainAmountFor end FRemainAmountFor,
                                isnull(ct.Fisbad,0) as FIsBad,b.FVoucherID as FVoucherID,v.FGroupID as FGroupID,a.FAccountID as FAccountID,0 as FIsInit,b.FStatus as FStatus,
                                b.FBillType as FDetailBillType,c1.FName as FDetailBillTypeName,0 as FInvoiceType,b.FItemClassID,b.FExplanation FExplanation,
                               b.FSubSystemID,0 as FTranType,CAST(v1.FName AS Nvarchar(30))+'-'+CAST(v.FNumber AS Nvarchar(30))  as FVoucherNo,bt.FName as FBillTypeName,'' as FJSBillNo
                            from t_rp_newreceivebill b
                             join t_rp_contact ct on ct.FBillID=b.FBillID and ct.FType = 5
                             join t_rp_arbillofsh a on b.fbillid=a.fbillid
                             left join t_rp_billType bt on b.FClasstypeid=bt.FID
                             left join t_voucher v on b.FVoucherID=v.FVoucherID
                             left join t_VoucherGroup v1 on v.FGroupID=v1.FGroupID
                             left join t_rp_systemEnum c1 on b.FBillType= c1.FItemID
                            Where (b.FSubSystemID = 0 Or (b.FSubSystemID = 1 And fconfirm = 1)) and b.FRP = 1) b
                     join t_item k on b.FCustomer = k.FItemID and k.FName like '%$orgfname%'
                     left join t_item d on b.FDepartment = d.FItemID 
                     left join t_item e on b.FEmployee = e.FItemID  
                     left join t_account t on b.FAccountID = t.FAccountID 
                     left join (select FReContactID,sum(FAmount) as FAmount,sum(FAmountFor) as FAmountFor
                            From t_RP_NewBadDebt
                            Where IsNull(FType, 0) = 0 And FReContactID > 0
                            group by FReContactID) tb on b.FInterID=tb.FReContactID
                     where b.FRP=1 and b.FItemClassID=1 $fname
                     and b.FCurrencyID=1 $RegionSql
                     and b.FYear*12+b.FPeriod>=$where_len and b.FYear*12+b.FPeriod<=$end_monthlen
                     and b.FStatus & 16 = 0 
                     Group By b.fdate,b.ffincdate,b.fbilltypename,b.fnumber,b.FDetailBillTypeName,b.fvoucherno,b.FJSBillNo,t.fname,b.fexplanation,b.FDepartment,b.FEmployee,b.FIsBad,
                              b.FContractNo,d.FName,b.fclasstypeid,b.finterid,b.fsubsystemid,e.fname,b.fyear,b.fperiod,b.FCurrencyID,b.fcustomer	
				 Union All 
                    Select p.FEndDate,p.FEndDate,'',':'+cast(b.FAdjustID as NVarchar(30)) as FBillNo,'' DetailTypeName,
                      CAST(v1.FName AS Nvarchar(10))+'-'+CAST(v.FNumber AS Nvarchar(10)) as FVoucherNo,'' as FJSBillNo,t.FName AccountName,
                      CAST(p.FYear AS Nvarchar(4))+''+CAST(p.FPeriod as NVarchar(2))+'' as FNote,
                      b.FDepartment,b.FEmployee,'',d.FName, -91314 FClassTypeID,0 FTranType,b.FInterID,0, e.FName,
                      sum(case When b.FRP=1 then CASE When b.FAccountID>0 then Case When b.FDC=1 then b.FAdjustAmountFor else 0 end  ELSE b.FAdjustAmountFor END Else CASE When b.FAccountID>0 then Case When b.FDC=-1 then b.FAdjustAmountFor 
                    else 0 end ELSE  b.FAdjustAmountFor END End),
                      sum(case When b.FRP=1 then CASE When b.FAccountID>0 then Case When b.FDC=1 then b.FAdjustAmount else 0 end ELSE b.FAdjustAmount END Else CASE When b.FAccountID>0 then Case When b.FDC=-1  then b.FAdjustAmount else 0 end 
                    ELSE b.FAdjustAmount END End),
                      sum(case When b.FRP=1 then CASE When b.FAccountID>0 then Case When b.FDC=-1 then b.FAdjustAmountFor else 0 end ELSE 0 END Else CASE When b.FAccountID>0 then Case When b.FDC=1  then b.FAdjustAmountFor else 0 end ELSE 0 
                    END End),
                      sum(case When b.FRP=1 then CASE When b.FAccountID>0 then Case When b.FDC=-1 then b.FAdjustAmount else 0 end ELSE 0 END Else CASE When b.FAccountID>0 then Case When b.FDC=1  then b.FAdjustAmount else 0 end ELSE 0 END 
                    End),0,0,0,
                      sum(case When b.FRP=1 then CASE When b.FAccountID>0 then Case When b.FDC=1 then b.FAdjustAmountFor else 0 end  ELSE b.FAdjustAmountFor END Else CASE When b.FAccountID>0 then Case When b.FDC=-1 then b.FAdjustAmountFor 
                    else 0 end ELSE  b.FAdjustAmountFor END End) - 
                      sum(case When b.FRP=1 then CASE When b.FAccountID>0 then Case When b.FDC=-1 then b.FAdjustAmountFor else 0 end ELSE 0 END Else CASE When b.FAccountID>0 then Case When b.FDC=1  then b.FAdjustAmountFor else 0 end ELSE 0 
                    END End),
                      sum(case When b.FRP=1 then CASE When b.FAccountID>0 then Case When b.FDC=1 then b.FAdjustAmount else 0 end ELSE b.FAdjustAmount END Else CASE When b.FAccountID>0 then Case When b.FDC=-1  then b.FAdjustAmount else 0 end 
                    ELSE b.FAdjustAmount END End) - 
                      sum(case When b.FRP=1 then CASE When b.FAccountID>0 then Case When b.FDC=-1 then b.FAdjustAmount else 0 end ELSE 0 END Else CASE When b.FAccountID>0 then Case When b.FDC=1  then b.FAdjustAmount else 0 end ELSE 0 END 
                    End),
                      0 FBillID,3,0,b.FYear,b.FPeriod,1 FCurrencyID,b.FCustomer 
                    From t_rp_adjustaccount b
                     left join t_PeriodDate p on b.FYear=p.FYear and b.FPeriod=p.FPeriod
                     left join t_voucher v on b.FVoucherID=v.FVoucherID
                     left join t_VoucherGroup v1 on v.FGroupID=v1.FGroupID
                     join t_item k on b.FCustomer = k.FItemID and k.FName like '%$orgfname%'
                     left join t_item d on b.FDepartment = d.FItemID 
                     left join t_item e on b.FEmployee = e.FItemID  
                     left join t_account t on b.FAccountID = t.FAccountID 
                     where b.FRP=1 and b.FItemClassID=1 $fname 
                     and b.FCurrencyID=1 $RegionSql
                     and b.FYear*12+b.FPeriod>=$where_len
                     and b.FYear*12+b.FPeriod<=$end_monthlen
                     Group By p.FEndDate,v1.FName,v.FNumber,t.FName,d.FName,b.FInterID,e.FName,b.fyear,b.fperiod,b.FDepartment,b.FEmployee,b.fcustomer,b.FAdjustID,p.FYear,p.FPeriod 
                Union All 
                    Select  b.FDate,b.FFincdate,'' as FBillTypeName,b.fnumber,'',
                      CAST(v1.FName AS Nvarchar(30))+'-'+CAST(v.FNumber AS Nvarchar(30)),'' as FJSBillNo,t.FName,b.FExplanation,b.FDepartment,b.FEmployee,'',
                      d.fName,0,0,0,0,e.fname,-sum(b.FAmountFor) as FAmountFor, -sum(b.FAmount) as FAmount,0,0,
                      0,0,0 as FSumSort,-sum(b.FAmountFor)  FEndBalanceFor,-sum(b.FAmount) FEndBalance,0 FBillID,
                      8 FType,0 FPre,b.FYear FYear,b.FPeriod FPeriod,b.FCurrencyID,b.FCustomer
                    From t_rp_contact b
                     left join t_voucher v on b.FVoucherID=v.FVoucherID
                     left join t_VoucherGroup v1 on v.FGroupID=v1.FGroupID
                     join t_item k on b.FCustomer = k.FItemID and k.FName like '%$orgfname%'
                     left join t_item d on b.FDepartment = d.FItemID 
                     left join t_item e on b.FEmployee = e.FItemID  
                     left join t_account t on b.FAccountID = t.FAccountID 
                     where b.FRP=1 and b.FItemClassID=1 $fname
                     and b.FCurrencyID=1 $RegionSql
                     and b.FType = 8 and b.FIsinit<>1 
                     and b.FYear*12+b.FPeriod>=$where_len and b.FYear*12+b.FPeriod<=$end_monthlen
                     and b.FStatus & 16 = 0 
                     Group By b.fdate,b.ffincdate,b.fnumber,CAST(v1.FName AS Nvarchar(30))+'-'+CAST(v.FNumber AS Nvarchar(30)),
                              b.FDepartment,b.FEmployee,t.fname,b.fexplanation,d.FName,b.FCurrencyID,e.fname,b.fyear,b.fperiod,b.fcustomer
                Union All
                    Select  b.FDate,isnull(v.FDate,b.FDate) FFincDate,'' FBillTypeName,
                      b.FBillNO FNumber,'' FDetailBillTypeName,CAST(v1.FName AS Nvarchar(30))+'-'+CAST(v.FNumber AS Nvarchar(30))  as FVoucherNo,'' as FJSBillNo,t.fName,b.FExplanation,
                      b.FDeptID,b.FEmpID,'',d.FName,0 FClasstypeID,b.FTrantype,b.FInterID,0 FSubsystemid,e.fName,
                      sum(case when a.FQty=0  then a.FConsignAmount else (a.FQty-isnull(tz.FHookQty,0))*a.FConsignAmount/a.FQty end),
                      sum(case when a.FQty=0  then a.FConsignAmount else (a.FQty-isnull(tz.FHookQty,0))*a.FConsignAmount/a.FQty end),
                      0,0,0,0,0,
                      sum(case when a.FQty=0  then a.FConsignAmount else (a.FQty-isnull(tz.FHookQty,0))*a.FConsignAmount/a.FQty end)  FEndBalanceFor,
                      sum(case when a.FQty=0  then a.FConsignAmount else (a.FQty-isnull(tz.FHookQty,0))*a.FConsignAmount/a.FQty end) FEndBalance,
                      0 FBillID,5 FType,0 FPre,isnull(tp.FYear,0) FYear,isnull(tp.FPeriod,0) FPeriod,1 FCurrencyID,b.FSupplyID
                    From ICStockBill b
                    join ICStockBillEntry a on a.FInterID=b.FInterID
                    inner join t_perioddate tp on b.FDate>=tp.FStartDate and b.FDate<=tp.FEndDate
                    left join t_Voucher v on b.FVchInterID=v.FVoucherID
                    left join t_VoucherGroup v1 on v.FGroupID=v1.FGroupID
                     join t_item k on b.FSupplyID = k.FItemID and k.FName like '%$orgfname%'
                     left join t_item d on b.FDeptID = d.FItemID 
                     left join t_item e on b.FEmpID = e.FItemID  
                     left join t_account t on b.FCussentAcctID = t.FAccountID 
                     left join (select fibinterid,fentryid, sum(fhookqty) as fhookqty from  icHookRelations
                                      where FIBTag=1 and ftrantype<>1002523 and (Fyear*12 + FPeriod) <=$end_monthlen
                                      group by fibinterid,fentryid ) tz on b.finterid=tz.fibinterid and a.fentryid=tz.fentryid
                     left join (select fibinterid from  icHookRelations
                                      where FIBTag=1 and ftrantype<>1002523 and FEquityHook=1 and (Fyear*12 + FPeriod) <=$end_monthlen
                                      ) ty on b.finterid=ty.fibinterid
                     where 1=1 and 1=1 $fname
                     and 1=1 $FSupplySql
                     and b.FTranType = 21 and b.FCancellation<>1 and b.FInterID not in (select distinct FIBInterID From ICHookRelations Where FIBTag=4)
                     and tp.FYear*12+tp.FPeriod>=$where_len and tp.FYear*12+tp.FPeriod<=$end_monthlen
                     and (case when a.FQty=0  then a.FConsignAmount else (a.FQty-isnull(tz.FHookQty,0))*a.FConsignAmount/a.FQty end)<>0
                     and  ty.fibinterid is null 
                     Group By b.fdate,v.fdate,b.FBillNO,v1.FName,v.FNumber,t.fname,b.fexplanation,b.FDeptID,b.FEmpID,
                              d.FName,b.ftrantype,b.finterid,e.fname,tp.fyear,tp.fperiod,b.FSupplyID
                ";
        $SqlCon->Query_result($insert_tempSubTable);

        //把期初数据，期间数据汇总到一中间临时表
        $insert_TTempGenDetail = "
				insert TTempGenDetail (FlngYear,FlngPeriod,FPeriod,FCustomer,FBegAmount,FBegAmountFor,FEndBalance,FEndBalanceFor,FIsNewYear)
				select $startdate[0],$startdate[1],cast($startdate[0] as varchar(4))+'.'+cast(1 as varchar(2)),FCustomer,sum(FEndBalance),sum(FEndBalanceFor),sum(FEndBalance),sum(FEndBalanceFor),1 from TempInitForSubTable Group by FCustomer
				update TTempGenDetail set FYearRPAmount = b.FRPAmount, 
					 FYearRPAmountFor = b.FRPAmountFor,
					 FYearMustRPAmount = b.FMustRPAmount,
					 FYearMustRPAmountFor = b.FMustRPAmountFor
				from TTempGenDetail a,(select FCustomer,sum(FMustRPAmountFor) FMustRPAmountFor,sum(FMustRPAmount) FMustRPAmount,sum(FRPAmountFor) FRPAmountFor,sum(FRPAmount) FRPAmount 
					from TempInitForSubTable where FYear=$startdate[0] group by FCustomer) b 
				where  a.FCustomer=b.FCustomer 
				update TTempGenDetail set FRPAmount = b.FRPAmount, 
					 FRPAmountFor = b.FRPAmountFor,
					 FMustRPAmount = b.FMustRPAmount,
					 FMustRPAmountFor = b.FMustRPAmountFor,
					 FYearRPAmount = FYearRPAmount + b.FRPAmount, 
					 FYearRPAmountFor = FYearRPAmountFor + b.FRPAmountFor,
					 FYearMustRPAmount = FYearMustRPAmount + b.FMustRPAmount,
					 FYearMustRPAmountFor = FYearMustRPAmountFor + b.FMustRPAmountFor, 
					 FEndBalance = FEndBalance + b.FMustRPAmount - b.FRpAmount,
					 FEndBalanceFor = FEndBalanceFor + b.FMustRPAmountFor - b.FRpAmountFor, 
					 FIsOcc = 1 
				from TTempGenDetail a,
					 (select FCustomer,FYear,FPeriod,sum(FMustRPAmountFor) FMustRPAmountFor,
							sum(FMustRPAmount) FMustRPAmount,sum(FRPAmountFor) FRPAmountFor,sum(FRPAmount) FRPAmount 
					 from tempSubTable group by FCustomer,FYear,FPeriod) b 
				where  a.FCustomer=b.FCustomer  and a.FlngYear=b.FYear and a.FlngPeriod=b.FPeriod
				insert TTempGenDetail (FlngYear,FlngPeriod,FPeriod,FCustomer,FMustRPAmount,FMustRPAmountFor,FRPAmount,FRPAmountFor,
					FYearMustRPAmount,FYearMustRPAmountFor,FYearRPAmount,FYearRPAmountFor,FEndBalance,FEndBalanceFor,FIsNewYear,FIsOcc)
				select a.FYear,a.FPeriod,cast(a.FYear as varchar(4))+'.'+cast(a.FPeriod as varchar(2)),a.FCustomer,a.FMustRPAmount,a.FMustRPAmountFor,a.FRPAmount,a.FRPAmountFor,
					a.FMustRPAmount,a.FMustRPAmountFor,a.FRPAmount,a.FRPAmountFor,a.FMustRPAmount - a.FRPAmount,a.FMustRPAmountFor - a.FRPAmountFor,case a.FPeriod when 1 then 1 else 0 end,1
				from (select FCustomer,FYear,FPeriod,sum(FMustRPAmountFor) FMustRPAmountFor,sum(FMustRPAmount) FMustRPAmount,sum(FRPAmountFor) FRPAmountFor,sum(FRPAmount) FRPAmount 
						from tempSubTable group by FCustomer,FYear,FPeriod) a 
				left join (select distinct FCustomer,FlngYear FYear,FlngPeriod as FPeriod from TTempGenDetail) b 
					 on  a.FCustomer=b.FCustomer  and a.FYear=b.FYear and a.FPeriod=b.FPeriod 
				where b.FYear is null;

				drop Table Period;
				create table Period (FYear integer,FPeriod integer,FYearPeriod varchar(10)) 
				";
        //echo $insert_TTempGenDetail;
        $SqlCon->Query_result($insert_TTempGenDetail);

        foreach ($monarr as $key => $y_mouth) {
            $y_mouth_arr = explode('-', $y_mouth);
            $insert_Period .= "insert into Period (FYear,FPeriod,FYearPeriod) values ($y_mouth_arr[0],$y_mouth_arr[1],' $y_mouth_arr[0]. $y_mouth_arr[1]')";
        }
        $SqlCon->Query_result($insert_Period);
        $insert_TTempGen = "
				Insert into TTempGenDetail(FSonCompany,FLngYear,FLngPeriod,FCustomer,FPeriod )
				Select '',c.FYear,c.FPeriod,FCustomer,c.FYearPeriod 
				from (Select distinct FCustomer from TTempGenDetail) a,Period c 
				where not exists (select 1 from TTempGenDetail b where  a.FCustomer=b.FCustomer  and b.FlngYear= c.FYear and b.FlngPeriod=c.FPeriod);";
        $SqlCon->Query_result($insert_TTempGen);
        /*测试*/
        /*$aa = "select FBegAmount from TTempGenDetail where FCustomer = 6315";
                $aa_re = $SqlCon->Query_result($aa);
                $num_rows=$SqlCon->num_rows($aa_re);
                for($i=0;$i<$num_rows;$i++)
				{
				    $row=$SqlCon->fetch_row($aa_re);
					echo $row[0] .'=='.$row[1] .'=='.$row[2] .'=='.$row[3] .'=='.$row[4] .'=='.$row[5] .'=='.$row[6] .'=='.$row[7].'<br>';
                }*/
        $query_TTempGenDetail = "select FCustomer from TTempGenDetail group by FCustomer";
        $Result_TTempGenDetail = $SqlCon->Query_result($query_TTempGenDetail);
        $num_rows = $SqlCon->num_rows($Result_TTempGenDetail);
        for ($i = 0; $i < $num_rows; $i++) {
            $row = $SqlCon->fetch_row($Result_TTempGenDetail);
            $FCustomer = $row[0];
            $update_TTempGenDetail = "
						declare @amount decimal(28,4),@amount1 decimal(28,4),@amount2 decimal(28,4) 
						declare @amount3 decimal(28,4),@amount4 decimal(28,4),@amount5 decimal(28,4) 
						declare @Year int 
						set @amount = 0  set @amount1 = 0 set @amount2 = 0
						set @amount3 = 0 set @amount4 = 0 set @amount5 = 0
						set @Year=$startdate[0]
						update v1 set @amount = @amount + v1.FEndBalance ,@amount1 = @amount1 + v1.FEndBalanceFor, 
							@amount2 = (case when v1.FlngYear=@Year then @amount2 + v1.FYearMustRPAmount  else v1.FYearMustRPAmount end),@amount3 = (case when v1.FlngYear=@Year then @amount3 + v1.FYearMustRPAmountFor  else v1.FYearMustRPAmountFor end), 
							@amount4 = (case when v1.FlngYear=@Year then @amount4 + v1.FYearRPAmount  else v1.FYearRPAmount end),@amount5 = (case when v1.FlngYear=@Year then @amount5 + v1.FYearRPAmountFor  else v1.FYearRPAmountFor end), 
							v1.FEndBalance = @amount,v1.FEndBalanceFor = @amount1,FYearMustRPAmount=@amount2,FYearMustRPAmountFor=@amount3,FYearRPAmount=@amount4,FYearRPAmountFor=@amount5,@Year=v1.FlngYear
						from TTempGenDetail v1  where FCustomer = $FCustomer
					";
            //echo $update_TTempGenDetail . '<br><br><br>';
            $SqlCon->Query_result($update_TTempGenDetail);
        }
        /**/
        //叠加期末余额，本年累计
        $insert_TTempGenDetail = "
				update TTempGenDetail set FBegAmount = FEndBalance + FRPAmount - FMustRPAmount,FBegAmountFor = FEndBalanceFor + FRPAmountFor - FMustRPAmountFor;
				update TTempGenDetail set FPeriod=cast(FlngYear as varchar(4))+'.'+cast(FlngPeriod as varchar(2)),FNumber=k.FNumber,FName=k.FName,
					FDeptNumber=d.FNumber,FDeptName=d.FName,FEmpNumber=e.FNumber,FEmpName=e.FName 
				 from TTempGenDetail a
					left join t_Item k on a.FCustomer=k.FItemID
					left join t_item d on a.FDepartment=d.FItemID
					left join t_item e on a.FEmployee=e.FItemID";

        //生成汇总数据(把所有汇总数据填充到临时表)
        $insert_TTempGenDetail .= "
				insert TTempGen (FLngYear,FLngPeriod,FPeriod,FBegAmountFor,FBegAmount,FMustRPAmountFor,FMustRPAmount,FRPAmountFor,FRPAmount,
					FYearMustRPAmountFor,FYearMustRPAmount,FYearRPAmountFor,FYearRPAmount,FEndBalanceFor,FEndBalance,FSumSort,FIsOcc)
				 select FLngYear,FLngPeriod,FPeriod,
					sum(FBegAmountFor) FBegAmountFor,sum(FBegAmount) FBegAmount,sum(FMustRPAmountFor) FMustRPAmountFor,sum(FMustRPAmount) FMustRPAmount,sum(FRPAmountFor) FRPAmountFor,sum(FRPAmount) FRPAmount,
					sum(FYearMustRPAmountFor) FYearMustRPAmountFor,sum(FYearMustRPAmount) FYearMustRPAmount,sum(FYearRPAmountFor) FYearRPAmountFor,sum(FYearRPAmount) FYearRPAmount,
					sum(FEndBalanceFor) as FEndBalanceFor,sum(FEndBalance) FEndBalance,
					106 as fsumsort,max(FIsOcc)
				 from TTempGenDetail
				 Group by FLngYear,FLngPeriod,FPeriod";

        //合并期间数据和汇总数据到汇总表
        $insert_TTempGenDetail .= "
				insert TTempGenTable  (FSumSort,FlngYear,FlngPeriod,FPeriod,FBegAmountFor,FBegAmount,FMustRPAmountFor,FMustRPAmount,FRPAmountFor,FRPAmount,FYearMustRPAmountFor,FYearMustRPAmount,FYearRPAmountFor,FYearRPAmount,FEndBalanceFor,FEndBalance,FIsOcc)
				select FSumSort,FLngYear,FLngPeriod,FPeriod,sum(FBegAmountFor) FBegAmountFor,sum(FBegAmount) FBegAmount,sum(FMustRPAmountFor) FMustRPAmountFor,sum(FMustRPAmount) FMustRPAmount,sum(FRPAmountFor) FRPAmountFor,sum(FRPAmount) FRPAmount,
					sum(FYearMustRPAmountFor) FYearMustRPAmountFor,sum(FYearMustRPAmount) FYearMustRPAmount,sum(FYearRPAmountFor) FYearRPAmountFor,sum(FYearRPAmount) FYearRPAmount,
					sum(FEndBalanceFor) as FEndBalanceFor,sum(FEndBalance) FEndBalance,max(FIsOcc) 
				From TTempGen where FSumSort <> 0
				group by FSumSort,FLngYear,FLngPeriod,FPeriod
				
				insert TTempGenTable  (FCustomer,FSumSort,FlngYear,FlngPeriod,FPeriod,FBegAmountFor,FBegAmount,FMustRPAmountFor,FMustRPAmount,FRPAmountFor,FRPAmount,FYearMustRPAmountFor,FYearMustRPAmount,FYearRPAmountFor,FYearRPAmount,FEndBalanceFor,FEndBalance,FIsOcc)
				select FCustomer,FSumSort,FlngYear,FlngPeriod,FPeriod,sum(FBegAmountFor) FBegAmountFor,sum(FBegAmount) FBegAmount,sum(FMustRPAmountFor) FMustRPAmountFor,sum(FMustRPAmount) FMustRPAmount,sum(FRPAmountFor) FRPAmountFor,sum(FRPAmount) FRPAmount,
					sum(FYearMustRPAmountFor) FYearMustRPAmountFor,sum(FYearMustRPAmount) FYearMustRPAmount,sum(FYearRPAmountFor) FYearRPAmountFor,sum(FYearRPAmount) FYearRPAmount,
					sum(FEndBalanceFor) as FEndBalanceFor,sum(FEndBalance) FEndBalance,max(FIsOcc) FIsOcc 
				From TTempGenDetail where FSumSort = 0 
				group by FCustomer,FSumSort,FlngYear,FlngPeriod,FPeriod

				Update TTempGenTable set FName = k.FName,FNumber=k.FNumber 
				 from TTempGenTable b left join t_item k on b.FCustomer = k.FItemID

				Update TTempGenTable Set FName = '" . convert2gbk('合计') . "' ,FSumSort=101  WHERE FSumSort=106
			";
        $SqlCon->Query_result($insert_TTempGenDetail);
        $query = 'select FName,FBegAmount,FMustRPAmount,FRPAmount,FYearMustRPAmount,FYearRPAmount,FEndBalanceFor,FPeriod from TTempGenTable order by FSumSort, FNumber';
        $result = $SqlCon->Query_result($query);
        $num_rows = $SqlCon->num_rows($result);
        for ($i = 0; $i < $num_rows; $i++) {
            $row = $SqlCon->fetch_row($result);
            $submesarr[$i]['FName'] = iconv('GB2312//IGNORE', 'utf-8', $row[0]);
            $submesarr[$i]['FPeriod'] = $row[7];
            $submesarr[$i]['FBegAmount'] = getDefaultCurrecySymbol() . getDecimalTwoVal($row[1]);
            $submesarr[$i]['FMustRPAmount'] = getDefaultCurrecySymbol() . getDecimalTwoVal($row[2]);
            $submesarr[$i]['FRPAmount'] = getDefaultCurrecySymbol() . getDecimalTwoVal($row[3]);
            $submesarr[$i]['FEndBalanceFor'] = getDefaultCurrecySymbol() . getDecimalTwoVal($row[4]);
            $submesarr[$i]['FYearRPAmount'] = getDefaultCurrecySymbol() . getDecimalTwoVal($row[5]);
            $submesarr[$i]['FYearMustRPAmount'] = getDefaultCurrecySymbol() . getDecimalTwoVal($row[6]);
        }
        return $submesarr;
    }

    //获取外勤签到上传图片
    function getAttachmentsSignImage($signid)
    {
        global $adb;
        $query = 'select CONCAT(path,filename) as img,id,storage_location,cloud_path from ld_attachmentsforsign where signid = ?';
        $result = $adb->pquery($query, array($signid));
        $num_rows = $adb->num_rows($result);
        if ($num_rows > 0) {
            for ($i = 0; $i < $num_rows; $i++) {
                $storage_location=$adb->query_result($result,$i,'storage_location');
                if($storage_location=='cos')
                {
                    $img[$i]['img'] = $adb->query_result($result, $i, 'cloud_path');
                }
                else
                    $img[$i]['img'] = $adb->query_result($result, $i, 'img');
                $img[$i]['id'] = $adb->query_result($result, $i, 'id');
            }
            return $img;
        }
        return;
    }
    
    //duan 20221212 修改签到图片读取方式，改为从ld_attachments 读取
    function getnewAttachmentsSignImage($signid)
    {
        global $adb;
        $query = 'SELECT CONCAT(path,newfile_name) as img,ld_attachments.attachmentsid,storage_location,cloud_path from ld_attachments 
            INNER JOIN ld_seattachmentsrel on ld_attachments.attachmentsid = ld_seattachmentsrel.attachmentsid
            where ld_seattachmentsrel.attachmentcolumnname = "imagename" and ld_seattachmentsrel.crmid = ?;';
        $result = $adb->pquery($query, array($signid));
        $num_rows = $adb->num_rows($result);
        if ($num_rows > 0) {
            for ($i = 0; $i < $num_rows; $i++) {
                $storage_location=$adb->query_result($result,$i,'storage_location');
                if($storage_location=='cos')
                {
                    $img[$i]['img'] = $adb->query_result($result, $i, 'cloud_path');
                }
                else
                    $img[$i]['img'] = $adb->query_result($result, $i, 'img');
                $img[$i]['id'] = $adb->query_result($result, $i, 'attachmentsid');
            }
            return $img;
        }
        return [];
    }
    function getnewAttachmentsSignoutImage($signoutid)
    {
        global $adb;
        $query = 'SELECT CONCAT(path,newfile_name) as img,ld_attachments.attachmentsid,storage_location,cloud_path from ld_attachments 
            INNER JOIN ld_seattachmentsrel on ld_attachments.attachmentsid = ld_seattachmentsrel.attachmentsid
            where ld_seattachmentsrel.attachmentcolumnname = "signout_imagename" and ld_seattachmentsrel.crmid = ?;';
        $result = $adb->pquery($query, array($signoutid));
        $num_rows = $adb->num_rows($result);
        if ($num_rows > 0) {
            for ($i = 0; $i < $num_rows; $i++) {
                $storage_location=$adb->query_result($result,$i,'storage_location');
                if($storage_location=='cos')
                {
                    $img[$i]['img'] = $adb->query_result($result, $i, 'cloud_path');
                }
                else
                    $img[$i]['img'] = $adb->query_result($result, $i, 'img');
                $img[$i]['id'] = $adb->query_result($result, $i, 'attachmentsid');
            }
            return $img;
        }
        return [];
    }

    function setExportNum($get_progress,$start_row,$end_row){
        $this->get_progress = $get_progress;
        $this->start_row = $start_row;
        $this->end_row = $end_row;
    }
}

?>