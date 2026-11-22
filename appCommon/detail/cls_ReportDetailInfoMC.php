<?php
include_once globalStatic::$root_directory . 'modules/Home/DataRangeHomeboard.php';
/* gyq_17 */

class cls_ReportDetailInfoMC
{
    protected $reportInfo;
    protected $current_user;
    //edit: xll 2023/08/14 XUQIU1001400 移动端报表增加目标完成率仪表盘
    protected $orignDashStr = '$##$monthweekreport,Salesfunnel,Contractamount,Salessituation,Returnamount,Saleskit,Contractkit,Accountleadsource,Accountaccounttype,AccountsMap,complationRateSixMonth,ContactTimesRanking,PersonalAccountBalance,TargetCompletionRate,SalesPhaseTransformationAnalysis';
    // @edit:zhouxiaomei @date:2020-09-07 @reason: 近6个月销售目标完成情况 增加complationRateSixMonth
    protected $userReportStr = '$##$SalesOrderTrack,CashBillSum_Paymentplan,CashBillSum_SalesOrder';
    //editor:gyq_141 reason:protected改为public，方便home_page_control中调用  2019/9/5 11:38 ID1000602
    public $selectuid;
    public $data_type;// @edit:zhouxiaomei @date:2020-09-07 @reason: 近6个月销售目标完成情况
    protected $timerangeTransfor = array('today' => '今天', 'yesterday' => '昨天', 'week' => '本周',
        'lastmonth' => '上月', 'month' => '本月', 'year' => '本年', 'all' => '全部','previousyear'=>'前年',
        'lastyear'=>'去年');
    protected $timerangeArrOrign = array('today' => 'today', 'yesterday' => 'syesterday', 'week' => 'thisweek',
        'lastmonth' => 'lastmonth', 'month' => 'thismonth', 'year' => 'thisfy','lastyear'=>'prevfy', 'all' => 'all');
    protected $timeRangeDetail;
    //protected $weekRangeTransfor = array('第一周','第二周','第三周','第四周','第五周');
    protected $weekRangeTransfor = array('一','二','三','四','五','六','七');
    public $trueTimeRange;//暂用于周计划统计日期所在月份起止日期
    protected $description;
    private $format_standard;
    private $displayusers; //筛选条件统计图中显示数量或金额为0的用户 ，是【yes】、否【no】
    public $scopeType;
    protected $loghtmlclass;//日周月表，日历样式
    public $fromtype;
    public $searchcondition;//筛选条件
    public $length_amountdecimal;
    public $homeboardid;
    public function __construct($record)
    {
        //editor:gyq_126 reason:允许record传空值  2019/6/20 16:09
        if(!empty($record)) {
            global $adb, $current_user, $PlatformMC;
            $this->current_user = $current_user;
            $this->displayusers = $_REQUEST['displayusers'];
            /* $this->reportInfo['legend'] = '签约数量';*/
            $SQL = 'SELECT name,graphtype,modulenames,labelbol FROM ld_dashboard_app WHERE id=? or name=? limit 1';
            //zxm 20231103 增加report_name的条件  因为现在首页工作台读的是ld_stuff数据  返回的数据没有record
            $RESULT = $adb->pquery($SQL, array($record,$_REQUEST['report_name']));
            $NUMS = $adb->num_rows($RESULT);
            if ($NUMS > 0) {
                $this->reportInfo['graphtype'] = $adb->query_result($RESULT, 0, 'graphtype');
                $this->reportInfo['name'] = $adb->query_result($RESULT, 0, 'name');
                $this->reportInfo['modulenames'] = $adb->query_result($RESULT, 0, 'modulenames');
                $this->reportInfo['labelbol'] = $adb->query_result($RESULT, 0, 'labelbol');
            }

            if (!empty($PlatformMC)) {
                $this->fromtype = $PlatformMC['type'];
            }

        }
        //zxm 20240913 新的数据龙虎榜页签切换。因为没有record导致selectuid为null 所把这三个参数拿出来赋值
        // @edit:zhouxiaomei @date:2020-09-07 @reason: 近6个月销售目标完成情况
        if (isset($_REQUEST['data_type']) && $_REQUEST['data_type'] != '') {
            $this->data_type = $_REQUEST['data_type'];
        }
        if (isset($_REQUEST['scopeType']) && $_REQUEST['scopeType'] != '') {
            $this->scopeType = $_REQUEST['scopeType'];
        }
        $this->getselectuid();
        $system_351 = getSys_deploy(351);//单据分录明细金额字段和单据头货币字段小数位数
        $system_deploy_351 = 2;
        if(is_numeric($system_351['deploy_value'])){
            $system_deploy_351 = $system_351['deploy_value'];    
        }
        $this->length_amountdecimal = $system_deploy_351;
    }
    public function setBoardId($boardid){
        $this->homeboardid = $boardid;
    }
    //根据筛选用户条件得到用户id字符串
    public function getselectuid(){
        global $current_user,$adb;
        if(isset($_REQUEST['selectuid'])){
            $selectuid = trim($_REQUEST['selectuid'],',');
            $reportscope = array();//权限根据报表模块走
            $permittype = 'MobileReport';
            if(in_array($this->reportInfo['name'],$reportscope)) $permittype = 'Report';
            if ($selectuid === 'all') {
                $module_users = getCurSmOwnerSearchScope($permittype);
                $tmp_module_usersarr = array_keys($module_users['UserCombo']);
                $selectuid = implode(',', $tmp_module_usersarr);
                // 20240222 hzx BUG20240220-13 移动端--数据简报--工作汇报日志统计表 会默认显示离职人员数据。
                $Inactivedeploy = getSys_deploy(213);
                if($Inactivedeploy['deploy_value'] == 1){
                    $sql = "select id from ld_users where `status` = 'Active' and FIND_IN_SET(id,?)";
                    $avtive_result = $adb->pquery($sql,array($selectuid));
                    $avtive_num = $adb->num_rows($avtive_result);
                    if($avtive_num > 0){
                        $tmp_selectuid_arr = [];
                        for($i = 0;$i<$avtive_num;$i++){
                            $tmp_selectuid_arr[] = $adb->query_result($avtive_result,$i,'id');
                        }
                        $selectuid = implode(',', $tmp_selectuid_arr);
                    }else{
                        $selectuid = '';
                    }
                }

            }
            elseif($selectuid === 'me'){
                $selectuid = $current_user->id;
            }
            $this->selectuid = $selectuid;
        }
    }
    public function DashboardDetail()
    {
        $name = $this->reportInfo['name'];
        $graphtype = $this->reportInfo['graphtype'];
        $labelbol = getFixedLabel($this->reportInfo['labelbol']);
        //editor:gyq_107 reason:企业微信即时库存查询报表  2019/4/3 11:50

        if($graphtype > 100){
            $jsonArr = $this->$name();
        }else{
            if (strpos($this->orignDashStr, $name) > 0) {
                $orignDashname = 'get'.$name;
                $jsonArr = $this->$orignDashname();
                //用户信息
                $Group_Special = crm_load_class_obj('Group_Special','modules/Users');
                $userinfoArr = $Group_Special->getuserinfoStr($this->selectuid);
               
                $jsonArr['userinfo']=$userinfoArr;
                $jsonArr['name']=$labelbol;
            }elseif(strpos($this->userReportStr, $name) > 0){
                crm_load_class_file('OftenUseReport','modules/OftenUseReport');
                $jsonArr = $this->getUseReportTrack();
                $jsonArr['name']=$labelbol;
            } else {
                $jsonArr = $this->outputHtml();
            }
           
            $time_range = $this->set_filter_time_range();
             
            $jsonArr['time_range'] =$time_range;
        }
        $jsonArr['arrFixedLabel'] = $this->getlabel_arr();

        ConvertTojsonString(1,$jsonArr,'');
    }

    protected function getReportSQL()
    {
        $graphtype = $this->reportInfo['graphtype'];
        $reportname = $this->reportInfo['name'];
        $selectuid = $this->selectuid;
        $reporttype = $_REQUEST['reporttype'];
        if (!empty($reporttype)) {
            //editor:gyq_20180920 0035301: （客户001账套）微信端：报表日期筛选增加“全部”，显示在最后一位
            if($reporttype=='all'){
                $timeBetweenSql = '';
            }else {
                if ($graphtype == 3) {
                    $range = $this->getTimeRange($reporttype);
                    $timeBetweenSql = $range['sql'];
                } else {
                    $timerange = $reporttype;
                    if (array_key_exists($reporttype, $this->timerangeArrOrign)) {
                        $timerange = $this->timerangeArrOrign[$reporttype];
                    }
                    include_once(globalStatic::$root_directory . 'modules/CustomView/CommonView.php');
                    $dateArr = CommonView::stdFilterDateTimeStr('lastmodified');
                    $timerangeArr = $dateArr[$timerange];
                    $timeBetweenSql = 'between  \'' . $timerangeArr[0] . '\' and \'' . $timerangeArr[1] . '\' ';
                }
            }
        }
        $where = '';
        if($graphtype == 3){
            if (!empty($selectuid)) {
                $where .= '  and %s.smcreatorid in ( ' . $selectuid . ' ) ';
            }
            if (!empty($timeBetweenSql)) {
                //zxm 2021-0610手机端日志统计  时间应该取sendlog_workdate字段   0046309: （企业微信移动端-kfbcrm）报表-工作汇报日志统计表（客户问题-李发林），比如9号补写了5号日志，在移动端报表中，5号显示X号，9号显示√号写了日志；PC端显示正常
                if($reportname == 'daylog'){
                    $where .= ' and DATE_FORMAT(%s.sendlog_workdate,\'%Y-%m-%d\') ' . $timeBetweenSql;
                }else{
                    $where .= ' and DATE_FORMAT(%s.createdtime,\'%Y-%m-%d\') ' . $timeBetweenSql;
                }
            }
        } elseif ($reportname == 'signednumber' || $reportname == 'signedamount') {//签约金额 签约数量
            if (!empty($timerangeArr)) {
                // editor:gyqX161019 Bug:0025184: 应用>仪表盘>签约金额龙虎榜：金额与pc端上的不一致
                $where = ' and ld_salesorder.signed_data ' . $timeBetweenSql;
                $whereServiceContracts = ' and ld_servicecontracts.due_date ' . $timeBetweenSql;
            }
            if (!empty($selectuid)) {
                $where .= '  and %s.smownerid in ( ' . $selectuid . ' ) ';
                $whereServiceContracts .= '  and %s.smownerid in ( ' . $selectuid . ' ) ';
            }
            if ($_REQUEST['applovetype'] == 'approved') {
                $where .= ' and %s.approvestatus=\'已批准\' ';
                $whereServiceContracts .= ' and %s.approvestatus=\'已批准\' ';
            }
        } elseif ($reportname == 'cashbillamount') { //回款金额
            if (!empty($selectuid)) {
                $where .= '  and %s.smownerid in ( ' . $selectuid . ' ) ';
            }
            if (!empty($timerangeArr)) {
                $where .= ' and ld_cashbill.cashbilldate ' . $timeBetweenSql;
            }
            if ($_REQUEST['applovetype'] == 'approved') {
                $where .= ' and %s.checkoutstatus=\'已审核\' ';
            }
        } elseif ($reportname == 'expense_commission') { //费用佣金
            if ($_REQUEST['applovetype'] == 'approved') {
                $where .= ' and %s.approvestatus=\'已批准\' ';
            }
            if (!empty($selectuid)) {
                $where .= '  and %s.smownerid in ( ' . $selectuid . ' ) ';
            }
            if (!empty($timerangeArr)) {
                $where .= ' and %s.expensedate ' . $timeBetweenSql;
            }
        }

        include(globalStatic::$root_directory . 'modules/OftenUseReport/cls_MainReportSQL.php');
        $reportObj = new cls_MainReportSQL();
        switch ($reportname) {
            case 'signednumber'://签约数量龙虎榜
                $this->reportInfo['legend'] = getFixedLabel('CONTRACTNUMBERHONE');
                return $reportObj->Contractnumber($where, $whereServiceContracts);
            case 'signedamount'://签约金额龙虎榜
                $this->reportInfo['legend'] = getFixedLabel('CONTRACTAOUNT');
                return $reportObj->Contractamount($where, $whereServiceContracts);
            case 'cashbillamount'://回款金额龙虎榜
                $this->reportInfo['legend'] = getFixedLabel('REBACKAMOUNT');
                return $reportObj->CashBillamount($where);
            case 'expense_commission':
                return $reportObj->expense_commission($where);
            case 'daylog':
                $type = 1;
                return $reportObj->logStatistic($type,$where);
            case 'weeklog':
                $type = 2;
                return $reportObj->logStatistic($type,$where);
            case 'monthlog':
                $type = 3;
                return $reportObj->logStatistic($type,$where);
            default:
                return "";
        }
    }

    public function outputHtml()
    {
        $sql = $this->getReportSQL();
        //editor:gyq_20180917	0035240: （落落计划）企业微信>灵当CRM>报表>工作汇报日志统计表：显示空白。（需要补丁）
        $graphtype = $this->reportInfo['graphtype'];
        $reportname = $this->reportInfo['name'];
        if ($graphtype == '1') { //单柱
            $output = $this->singlecolumnGraph($sql);
        } elseif ($graphtype == '2') { //双柱
            $output = $this->doublecolumnGraph($sql);
        } elseif($graphtype == 3){
            $output = $this->timeSquareGraph($sql,$reportname);
        }
        return $output;
    }
    protected function getTimeRange($time){
        $reportname = $this->reportInfo['name'];

        if($reportname == 'daylog'){
            $result = DateOperation::get_weekrange_by_date($time);
            $timeBetweenSql = ' between  \'' . reset($result) . '\' and \'' . end($result) . '\' ';
            $this->description = reset($result);
        }elseif($reportname == 'weeklog'){
            $result2 = DateOperation::get_monthinfo_by_date($time);
            $this->trueTimeRange = $result2;
            $result = DateOperation::get_weeks($result2['month_start_day'],$result2['month_end_day']);
            $reset52 =  reset($result);
            $end52 = end($result);
            $timeBetweenSql = ' between  \'' . $reset52[0] . '\' and \'' . $end52[6] . '\' ';

            $this->description = $result2['month_start_day'];
        }elseif($reportname == 'monthlog'){
            //前年(previousyear)、去年(lastyear)、本年(year)
            $this->description = $this->timerangeTransfor[$time];
            if($time == 'lastyear'){
                $result3 = date('Y',time()) - 1;
            }elseif($time =='previousyear'){
                $result3 = date('Y',time()) - 2;
            }elseif($time == 'year'){
                $result3 = date('Y',time());
            }else{
                $result3 = date('Y',strtotime($time));
                $this->description =  $result3.'-01-01  -  '.$result3.'-12-31';
            }
            $timeBetweenSql = ' between  \'' . $result3.'-01-01\' and \'' . $result3.'-12-31\' ';
            $result = array(1,2,3,4,5,6,7,8,9,10,11,12);
            /*$result3 = date('Y',strtotime($time));
            $result = $timeObj->get_months($result3.'-01-01',$result3.'-12-31');*/
        }
        $resultF['sql'] = $timeBetweenSql;
        $this->timeRangeDetail = $resultF['detail'] = $result;

        return $resultF;
    }

    protected function daylogHtml($timeRangeDetail,$datailArr,$datailArrName,$createdtimeArr){
        if($this->fromtype=='weixin'){
            $divstr = '';
        }else{
            $divstr = '<div class="sta-tabletime"><i class="'.$this->loghtmlclass.'"></i>'.reset($timeRangeDetail).' -- '.end($timeRangeDetail).'</div>';
        }
        $divstr .= '<div class="sta-table"><table ><tr><th style="font-weight:bold;">'.getFixedLabel('Name').'</th>';
        foreach($timeRangeDetail as $key=> $val){
            $divstr .= '<th>'.date('d',strtotime($val)).'</th>';
        }
        $divstr .= '</tr>';
        $divstrcontent = '';
        foreach($datailArr as $key=>$val){
            $divstrcontent .= '<tr>';
            $divstrcontent .= '<td>'.$datailArrName[$key].'</td>';
            $datailArr[$key] = array_unique($val);
            foreach($timeRangeDetail as $key2=>$val2){
                $position = array_search($val2,$datailArr[$key]);
                if($position > 0 ||$position === 0){
                    if($createdtimeArr[$key][$val2]!=$val2){
                        $divstrcontent .= '<td class="f-greens">补</td>';
                    }else{
                        $divstrcontent .= '<td class="f-greens">√</td>';
                    }
                }else{
                    $divstrcontent .= '<td class="f-reds">×</td>';
                }
            }
            $divstrcontent .= '</tr>';
        }
        $divstr .= $divstrcontent.'</table></div>';
        return $divstr;
    }

    protected function weeklogHtml($timeRangeDetail,$datailArr,$datailArrName,$createdtimeArr){
        if($this->fromtype=='weixin'){
            $divstr = '';
        }else{
            $divstr = '<div class="sta-tabletime"><i class="'.$this->loghtmlclass.'"></i>'.$this->trueTimeRange['month_start_day'].' -- '.$this->trueTimeRange['month_end_day'].'</div>';
        }
        
        $divstr .= '<div class="sta-table"><table ><tr><th>'.getFixedLabel('Name').'</th>';
        foreach($timeRangeDetail as $key=> $val){
            $divstr .= '<th>'.$this->weekRangeTransfor[$key].'</th>';
        }
        $divstr .= '</tr>';
        $divstrcontent = '';
        foreach($datailArr as $key=>$val){
            $divstrcontent .= '<tr>';
            $divstrcontent .= '<td>'.$datailArrName[$key].'</td>';
            $datailArr[$key] = array_unique($val);
            foreach($timeRangeDetail as $key2=>$val2) {
                $intersect = array_intersect($datailArr[$key],$val2);
                if(!empty($intersect)){
                    if($createdtimeArr[$key][$val2[0]]== $val2[0]){
                        $divstrcontent .= '<td class="f-greens">√</td>';
                    }else{
                        $divstrcontent .= '<td class="f-greens">补</td>';
                    }
                }else{
                    $divstrcontent .= '<td class="f-reds">×</td>';
                }
            }
            $divstrcontent .= '</tr>';
        }
        $divstr .= $divstrcontent.'</table></div>';

        return $divstr;
    }

    protected function monthlogHtml($timeRangeDetail,$datailArr,$datailArrName,$createdtimeArr){
        if($this->fromtype=='weixin'){
            $divstr = '';
        }else{
            $divstr = '<div class="sta-tabletime"><i class="'.$this->loghtmlclass.'"></i>'.$this->timerangeTransfor[$_REQUEST['reporttype']].'</div>';
        }

        $divstr .= '<div class="sta-table"><table ><tr><th>'.getFixedLabel('Name').'</th>';
        foreach($timeRangeDetail as $key=> $val){
            //$divstr .= '<th>'.$val.'月</th>';
            $divstr .= '<th>'.$val.'</th>';
        }
        $divstr .= '</tr>';
        $divstrcontent = '';
        foreach($datailArr as $key=>&$val){
            foreach($val as &$v){
                $v = explode('-',$v);
                $v = $v[1];
            }
            $divstrcontent .= '<tr>';
            $divstrcontent .= '<td>'.$datailArrName[$key].'</td>';
            $intersect = array_intersect($createdtimeArr[$key],$datailArr[$key]);
            foreach($timeRangeDetail as $key2=>$val2){
                $val2 = sprintf("%02d", $val2);
                $position = array_search($val2,$datailArr[$key]);
                if($position > 0 ||$position === 0){
                   if(in_array($val2,$intersect)){
                       $divstrcontent .= '<td class="f-greens">√</td>';
                   }else{
                       $divstrcontent .= '<td class="f-greens">补</td>';
                   }

                }else{
                    $divstrcontent .= '<td class="f-reds">×</td>';
                }
            }
            $divstrcontent .= '</tr>';
        }
        $divstr .= $divstrcontent.'</table></div>';
        return $divstr;
    }

    protected function timeSquareGraph($sql,$reportname=''){
        global $adb;
        $result = $adb->pquery($sql, array());
        $nums = $adb->num_rows($result);
        $datailArr = array();
        $datailArrName = array();
        $timeRangeDetail = $this->timeRangeDetail;

        $createdtimeArr = [];
        if ($nums > 0) {
            for ($i = 0; $i < $nums; $i++) {
                $userid = $adb->query_result($result, $i, 'smcreatorid');
                $wx_userid=$adb->query_result($result,$i,'wx_userid');
                $last_name=$adb->query_result($result, $i, 'username');
                $userobj=new Users();
                $userobj->wx_userid=$wx_userid;
                $userobj->last_name=$last_name;
                $datailArrName[$userid] =getUserlastName($userobj);
                if($reportname=='daylog'||$reportname=='weeklog'||$reportname=='monthlog'){
                    $createTime = date('Y-m-d',strtotime($adb->query_result($result, $i, 'createdtime')));
                    $workdate = $adb->query_result($result, $i, 'sendlog_workdate');
                    if($reportname=='weeklog'||$reportname=='monthlog'){
                        $workdate = explode('~',$workdate);
                        $workdate = trim($workdate[0]);
                    }
                    if($reportname=='monthlog'){
                        $createTime = date('m',strtotime($adb->query_result($result, $i, 'createdtime')));
                    }
                    $createdtimeArr[$userid][$workdate] = $createTime;

                    $datailArr[$userid][] = $workdate;
                }else{
                    $datailArr[$userid][] = date('Y-m-d',strtotime($adb->query_result($result, $i, 'createdtime')));
                }
            }
        }
        //editor:gyq_20181009 报表显示数据排序规则：根据人员首字母固定排序，而不是按照创建时间排序
        //ls 2022-09-13 【XUQIU1000505】报表数据默认勾选并显示离职成员数据(移动端工作汇报日志统计表/周计划/月计划)
        $sql2 = 'select id,last_name,wx_userid from ld_users WHERE id in (' . $this->selectuid . ')  order by  convert(last_name using gbk) ASC';
        $datailArrName2 = array();
        $datailArr2 = array();
        $result2 = $adb->pquery($sql2, array());
        $nums2 = $adb->num_rows($result2);
        if ($nums2 > 0) {
            $datailArrDeff = array();
            for ($i = 0; $i < $nums2; $i++) {
                $userid = $adb->query_result($result2, $i, 'id');
                $wx_userid=$adb->query_result($result2,$i,'wx_userid');
                $foreachMark = 0;
                foreach ($datailArrName as $key => $val) {
                    if ($key == $userid) {
                        $foreachMark = 1;
                        $datailArrName2[$userid] = $datailArrName[$userid];
                        $datailArr2[$userid] =$datailArr[$userid];
                    }
                }
                if ($foreachMark == 0) {
                    $last_name=$adb->query_result($result2, $i, 'last_name');
                    $userobj=new Users();
                    $userobj->wx_userid=$wx_userid;
                    $userobj->last_name=$last_name;
                    
                    $datailArrName2[$userid] = getUserlastName($userobj);
                    $datailArr2[$userid] = array();
                }
            }
        }
        if($this->fromtype=='weixin'){
            $this->loghtmlclass = 'iconfont icon-rili';
        }else{
            $this->loghtmlclass = 'lnr-calendar';
        }
        $reportname = $this->reportInfo['name'].'Html';

        if(method_exists($this,$reportname))
             $output = $this->$reportname($timeRangeDetail,$datailArr2,$datailArrName2,$createdtimeArr);
        else
        {
            //销售龙虎榜
            $method="get".$this->reportInfo['name'];
            $output = $this->$method();
            
        }
        if($this->fromtype=='weixin'){
            if($reportname=='daylogHtml'){
                $jsonArray['daterange'] = reset($timeRangeDetail).'  -  '.end($timeRangeDetail);
            }elseif($reportname=='weeklogHtml'){
                $jsonArray['daterange'] = $this->trueTimeRange['month_start_day'].'  -  '.$this->trueTimeRange['month_end_day'];
            }elseif($reportname=='monthlogHtml'){
                $jsonArray['daterange'] = $this->description;
            }
            $jsonArray['name'] = getFixedLabel($this->reportInfo['labelbol']);
        }
        $Group_Special = crm_load_class_obj('Group_Special', 'modules/Users');
        $userinfoArr = $Group_Special->getuserinfoStr($this->selectuid);
        $jsonArray['userinfo']=$userinfoArr;
        
        //$jsonArray['userinfo'] = $userinfoArr;
        $jsonArray['describeinfo'] = $this->description;
        $jsonArray['html'] = $output;
        return $jsonArray;
    }

    //双柱
    protected function doublecolumnGraph($sql)
    {
        global $adb;
        if(vtlib_isModuleActive('Expense')&&isPermitted('Expense','index')=='yes'){
            $result = $adb->pquery($sql['expense'], array());
            $nums = $adb->num_rows($result);
            $datailArr1 = array();
            if ($nums > 0) {
                for ($i = 0; $i < $nums; $i++) {
                    $datailArr1[$i]['id'] = $adb->query_result($result, $i, 0);
                    $datailArr1[$i]['name'] = $adb->query_result($result, $i, 1);
                    $money = $adb->query_result($result, $i, 2);
                    $datailArr1[$i]['money'] = $money;
                    if(!empty($money) && empty($this->format_standard)){
                        $this->format_standard = $money;
                    }
                }
            }
        }
        if(vtlib_isModuleActive('Commission')&&isPermitted('Commission','index')=='yes'){
            $result = $adb->pquery($sql['commission'], array());
            $nums = $adb->num_rows($result);
            $datailArr2 = array();
            if ($nums > 0) {
                for ($i = 0; $i < $nums; $i++) {
                    $datailArr2[$i]['id'] = $adb->query_result($result, $i, 0);
                    $datailArr2[$i]['name'] = $adb->query_result($result, $i, 1);
                    $money = $adb->query_result($result, $i, 2);
                    $datailArr2[$i]['money'] = $money;
                    if(!empty($money) && empty($this->format_standard)){
                        $this->format_standard = $money;
                    }
                }
            }
        }
        
        $new_detailArr = array();
        if (!empty($datailArr1) || !empty($datailArr2)) {
            $i = 0;
            foreach ($datailArr1 as $key => $value) {
                $new_detailArr[$i]['id'] = $value['id'];
                $new_detailArr[$i]['name'] = $value['name'];
                $new_detailArr[$i]['expense'] = $value['money'];
                $new_detailArr[$i]['commision'] = $this->getFloatLength(0,$this->format_standard);
                $new_detailArr[$key]['total'] = $value['money'];
                $i++;
            }
            foreach ($datailArr2 as $key2 => $val2) {
                $mark = 0;
                foreach ($new_detailArr as $key => $value) {
                    if ($value['id'] == $val2['id']) {
                        $new_detailArr[$key]['commision'] = $val2['money'];
                        $new_detailArr[$key]['total'] = $val2['money'] + $value['expense'];
                        $mark = 1;
                    }
                }
                if ($mark == 0) {
                    $new_detailArr[$i]['id'] = $val2['id'];
                    $new_detailArr[$i]['name'] = $val2['name'];
                    $new_detailArr[$i]['expense'] = $this->getFloatLength(0,$this->format_standard);
                    $new_detailArr[$i]['commision'] = $val2['money'];
                    $new_detailArr[$i]['total'] = $val2['money'];
                    $i++;
                }
            }
        }
        
        $sort = array(
            'direction' => $this->fromtype=='weixin'?'SORT_DESC':'SORT_ASC', //排序顺序标志 SORT_DESC 降序；SORT_ASC 升序
            'field' => 'total',       //排序字段
        );
        $arrSort = array();
        $arr_sum = array();
        foreach ($new_detailArr AS $uniqid => $row) {
            $arr_sum[$uniqid] = $row['total'];
            foreach ($row AS $key => $value) {
                $arrSort[$key][$uniqid] = $value;
            }
        }
        if ($sort['direction']) {
            array_multisort($arrSort[$sort['field']], constant($sort['direction']), $new_detailArr);
        }

        $entries_first = $entries_second = array();
        //微信端做分页 20180403 xxs
        if($this->fromtype=='weixin'){
            $chunk_arr = array_chunk($new_detailArr,10);
            if(!isset($_REQUEST['page'])||!is_numeric($_REQUEST['page'])){
                $_REQUEST['page'] = 0;
            }
            $new_detailArr = $chunk_arr[$_REQUEST['page']];
            $havenextpage = count($chunk_arr)-1>$_REQUEST['page']?'yes':'no';
            $jsonArray['havenextpage'] = $havenextpage;
        }
        foreach ($new_detailArr as $key => $val) {
            $nameArray[$key] = $val['name'];
            $entries_first[$key] = $val['expense'];
            $entries_second[$key] = $val['commision'];
        }
        if(vtlib_isModuleActive('Expense')&&isPermitted('Expense','index')=='yes'){
            $jsonArray['list']['legend'][] = getFixedLabel('Cost');
            $jsonArray['list']['legendcost'] = array(getFixedLabel('Cost'));
            $jsonArray['list']['costdata'] = $entries_first;
        }
        if(vtlib_isModuleActive('Commission')&&isPermitted('Commission','index')=='yes'){
            $jsonArray['list']['legend'][] = getFixedLabel('COMMISSION');
            $jsonArray['list']['legendcomm'] = array(getFixedLabel('COMMISSION'));
            $jsonArray['list']['commdata'] = $entries_second;
        }
        $jsonArray['list']['name'] = $nameArray;


        $Group_Special = crm_load_class_obj('Group_Special', 'modules/Users');
        $userinfoArr = $Group_Special->getuserinfoStr($this->selectuid);
        $jsonArray['userinfo'] = $userinfoArr;
        if (!empty($_REQUEST['reporttype'])) {
            $reporttype = $this->timerangeTransfor[$_REQUEST['reporttype']];
        } else {
            $reporttype = getFixedLabel('ALL');
        }
        $describeinfo['typename'] = $reporttype;
        $describeinfo['count'] = $this->getFloatLength(array_sum($arr_sum),$this->format_standard);
        if($this->fromtype=='weixin'){
            $jsonArray['list2'] = $this->getCommonSearchCondition();
            $jsonArray['name'] = getFixedLabel($this->reportInfo['labelbol']);
        }
        $jsonArray['describeinfo'] = $describeinfo;
        return $jsonArray;
    }

    //单柱
    protected function singlecolumnGraph($sql)
    {
        global $adb;
        $sysdeploy = getSys_deploy(49);
        /* editor:gyqX170629 0028970: 手机APP仪表盘：金额小数位数显示不正确
                说明	金额的小数位数应该始终是两位，现在根据系统参数数量小数位数显示了
                签约金额龙虎榜、回款金额龙虎榜*/
        if($this->reportInfo['name']=='signedamount'||$this->reportInfo['name']=='cashbillamount'){
            $lengthdecimaldigits=2;
        }else{
            $lengthdecimaldigits = $sysdeploy['deploy_value'];
        }

        $result = $adb->pquery($sql, array());
        $nums = $adb->num_rows($result);
        $datailArr = array();
        if ($nums > 0) {
            //editor:gyq_20181010 0035360: （落落计划）企业微信>灵当CRM>报表>签约数量龙虎榜、签约金额龙虎榜、回款金额龙虎榜：手机企业微信里报表的三张表只显示名字不显示数量金额（需要补丁）
            for ($i = 0; $i < $nums; $i++) {
                $datailArr[$i]['lastname'] = $adb->query_result($result, $i, 0);
                $datailArr[$i]['id'] = $adb->query_result($result, $i, 3);
                $datailArr[$i]['num'] = $adb->query_result($result, $i, 2);
            }
        }
        $newArr = $this->fromtype=='app'?array_reverse($datailArr):$datailArr;
        //微信端做分页 20180403 xxs
        if($this->fromtype=='weixin'){
            $chunk_arr = array_chunk($newArr,10);
            if(!isset($_REQUEST['page'])||!is_numeric($_REQUEST['page'])){
                $_REQUEST['page'] = 0;
            }
            $newArr = $chunk_arr[$_REQUEST['page']];
            $havenextpage = count($chunk_arr)-1>$_REQUEST['page']?'yes':'no';
            $jsonArray['havenextpage'] = $havenextpage;
        }
        foreach ($newArr as $item) {
            $nameArray[] = $item['lastname'];
            $entries[] = setNumberFormatEmptySeperator($item['num'],$lengthdecimaldigits) ;
            $entriesForSum[] =$item['num'] ;
        }
        $entriesN = array_count_values($entries);
        $i = count($entriesN);
        foreach ($entriesN as $k => $v) {
            for ($j = 0; $j < $v; $j++) {
                $entriesNE[$k] = $i;
            }
            $i--;
        }
        $jsonArray['list']['name'] = $nameArray;
        $jsonArray['list']['data'] = $entries;
        if($this->fromtype=='app') $jsonArray['list']['pmdata'] = $entriesNE;
        $jsonArray['list']['legend'] = $this->reportInfo['legend'];
        $Group_Special = crm_load_class_obj('Group_Special', 'modules/Users');
        $userinfoArr = $Group_Special->getuserinfoStr($this->selectuid);
        $jsonArray['userinfo'] = $userinfoArr;
        if (!empty($_REQUEST['reporttype'])) {
            $reporttype = $this->timerangeTransfor[$_REQUEST['reporttype']];
        } else {
            $reporttype = getFixedLabel('ALL');
        }
        $describeinfo['typename'] = $reporttype;
        //$describeinfo['count'] = $this->getFloatLength(array_sum($entries),$this->format_standard) ;
        $describeinfo['count'] = setNumberFormatEmptySeperator(array_sum($entriesForSum),$lengthdecimaldigits) ;
        $jsonArray['describeinfo'] = $describeinfo;
        if($this->fromtype=='weixin'){
            $jsonArray['list2'] = $this->getCommonSearchCondition();
            $jsonArray['name'] = getFixedLabel($this->reportInfo['labelbol']);
        }
        return $jsonArray;
    }
    public function getCommonSearchCondition(){}
    private function getFloatLength($number,$num) {
       // $number = '\''.$number.'\'';
        $number = (string)$number;
      //  $num = '\''.$num.'\'';
        $num = (string)$num;
        $count = 0;
        $temp = explode ( '.', $num );
        if (sizeof ( $temp ) > 1) {
            $decimal = end ( $temp );
            $count = strlen ( $decimal );
        }
        $result = number_format($number,$count);
        return $result;
    }
    //判断模块权限
    public function checkModulePermit($module){
        if(isPermitted($module)=='yes'&&vtlib_isModuleActive($module)){
            return true;
        }
        return false;
    }
    public function getSalesBaseReport($module,$con_field='createdtime',$select='count(1)',$otherwhere=''){
        global $adb,$current_user,$report_userid;
        
        $userid = $this->selectuid;
        $search_type = $_REQUEST['reporttype'];
        if(empty($search_type)) $search_type='thismonth';
        $date = getHomeDateScope($search_type);
        
        if(!$this->checkModulePermit($module)) return 0;
        
        $focus = CRMEntity::getInstance($module);
        $tablename = $focus->table_name;
        $smfield = $focus->getSmownerColumName();
        
        $other_where = $otherwhere;
        if($module=='SalesOrder'){
            $other_where .= " and sostatus!='已作废' and total>0 ";
        }elseif($module=='ServiceContracts'){
            $other_where .= " and contract_status!='已作废' and total>0 ";
        }
		
                
        $sql = "SELECT $select FROM $tablename
                WHERE $smfield in($userid) and deleted=0 $other_where
                AND $con_field $date";
                //AND YEAR (DATE_FORMAT($con_field, '%y-%m-%d')) = YEAR (now())
                //AND MONTH (DATE_FORMAT($con_field, '%y-%m-%d')) = MONTH (now())";
				
			
        $result = $adb->pquery($sql,array());
        
        $count = $adb->query_result($result,0,0);
        return $count;
    }
    public function getFormatMoney($money){
        $money = number_format($money,2,'.','');
        $formatmoney = array();
        if(empty($money)){
            return array('money'=>'0.00','unit'=>'元');
        }
        if(is_numeric($money)){
            $before = explode('.',$money);
            $length = strlen($before[0]);
            if($length<=4){
                $formatmoney['unit'] = '元';
            }elseif($length<=8){
                $money = $money/10000;
                $formatmoney['unit'] = '万';
            }else{
                $money = $money/100000000;
                $formatmoney['unit'] = '亿';
            }
            $formatmoney['money'] = number_format($money,2);
        }
        return $formatmoney;
    }
    public function formatrequest(){
        if(empty($_REQUEST['RangeDate'])){
            $_REQUEST['RangeDate'] = 'thismonth';
        }
        $datearr = cls_StaticCommonFun::rangeTime2DateArr($_REQUEST['RangeDate']);
        $_REQUEST['startmonth'] = $datearr[0];
        $_REQUEST['endmonth'] = $datearr[1];
    }
    //合同跟踪表筛选条件
    public function getUseReportTrackSearch($reportname){
        $searchwhere = array();
        $rangedatearr['fieldlabel'] = getFixedLabel('TIMEANGE');
        $rangedatearr['fieldname'] = 'RangeDate';
        $rangedatearr['option'][] = array('text'=>getFixedLabel('checktoday'),'value'=>'today','select'=>'no');
        $rangedatearr['option'][] = array('text'=>getFixedLabel('checkyesterday'),'value'=>'yesterday','select'=>'no');
        $rangedatearr['option'][] = array('text'=>getFixedLabel('thisweek'),'value'=>'thisweek','select'=>'no');
        $rangedatearr['option'][] = array('text'=>getFixedLabel('lastmonth'),'value'=>'lastmonth','select'=>'no');
        $rangedatearr['option'][] = array('text'=>getFixedLabel('thismonth'),'value'=>'thismonth','select'=>'yes');
        $rangedatearr['option'][] = array('text'=>getFixedLabel('THISYEAR'),'value'=>'thisyear','select'=>'no');
        $rangedatearr['option'][] = array('text'=>getFixedLabel('ALL'),'value'=>'all','select'=>'no');
        $searchwhere[] = $rangedatearr;
        //费用报销单和审批单审批类型
        $modules_arr = array('Expense','Commission');
		foreach($modules_arr as $mod){
			if($this->checkModulePermit($mod)){
				$modulelabel_array[] = getTranstab($mod);
			}
		}
        if(sizeOf($modulelabel_array) > 0){
            $approvearr['fieldlabel'] = implode(getFixedLabel('AND'),$modulelabel_array).getFixedLabel('APPROVALTYPE');
            $approvearr['fieldname'] = 'basicotherfindsapp';
            $approvearr['option'][] = array('text'=>getFixedLabel('ALL'),'value'=>'false','select'=>'yes');
            $approvearr['option'][] = array('text'=>getFixedLabel('Approved'),'value'=>'true','select'=>'no');
            if($reportname=='SalesOrderTrack')
                $searchwhere[] = $approvearr;
        }
        //单据类型
        if($this->checkModulePermit('SalesOrder')||$this->checkModulePermit('ServiceContracts')){
            $billtypearr['fieldlabel'] = getFixedLabel('BillType');
            $billtypearr['fieldname'] = 'basicotherfindsbill';
            $check = 0;
            if($this->checkModulePermit('SalesOrder')&&$this->checkModulePermit('ServiceContracts')){
                $billtypearr['option'][] = array('text'=>getFixedLabel('ALL'),'value'=>'0','select'=>'yes');
                $check = 1;
            }
            if($this->checkModulePermit('SalesOrder')){
                $billtypearr['option'][] = array('text'=>getTranstab('SalesOrder'),'value'=>'1','select'=>$check?'no':'yes');
            }
            if($this->checkModulePermit('ServiceContracts')){
                $billtypearr['option'][] = array('text'=>getTranstab('ServiceContracts'),'value'=>'2','select'=>$check?'no':'yes');
            }
            if($reportname=='SalesOrderTrack')
                $searchwhere[] = $billtypearr;
        }
        //人员范围
        $searchscope['fieldlabel'] = getFixedLabel('RANGESTAFF');
        $searchscope['fieldname'] = 'SmOwnerSearchScope';
        $searchscope['option'][] = array('text'=>getFixedLabel('ALL'),'value'=>'SmOwner_Search_All','select'=>'yes');
        $searchscope['option'][] = array('text'=>getFixedLabel('Mine'),'value'=>'SmOwner_Search_Me','select'=>'no');
        $searchscope['option'][] = array('text'=>getFixedLabel('LBL_SENIOR'),'value'=>'smowner_search_senior','select'=>'no');
        $searchwhere[] = $searchscope;
        return $searchwhere;
    }
    public function getUseReportTrack(){//合同跟踪表
        global $adb,$MobileLanguageType;
        $this->formatrequest();
        $_REQUEST['searchtype'] = "BasicSearch";
        $reportname = $this->reportInfo['name'];
        $entity['list'] = $this->getUseReportTrackSearch($reportname);
        //报表类型
        $result = $adb->pquery('select usereportid,reporttype,tabids from ld_usereport where name=?',array($reportname));
        $usereportid = $adb->query_result($result,0,'usereportid');
        $reporttype = $adb->query_result($result,0,'reporttype');
        $reportabid = $adb->query_result($result,0,'tabids');
        //时间字段
        $sql="select * from ld_usereportbasic  where usereportid=? order by sequence";
        $result=$adb->pquery($sql,array($usereportid));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $basicInfos=explode(":",$adb->query_result($result,$i,'columns'));
            if(strtolower($basicInfos[count($basicInfos)-1])=="d")
            {
                //ld_salesorder:signed_data:signed_data:SalesOrder_signed_data:D  日期查询字段
                 $_REQUEST['datefindcolumn']=$basicInfos[0].'.'.$basicInfos[1];
            }
            //客户查询字段
            $_REQUEST['otherfindcolumn'] = $basicInfos[0].'.'.$basicInfos[1];
        }
        $sql="select * from ld_usereportcolumns where usereportid=? order by sequence";
        $result=$adb->pquery($sql,array($usereportid));
        $reportFindHeader = '<tr>';
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            //columns:表名：字段名称：fieldname:模块名称_fieldlabel:typeofdate    
            $columns=$adb->query_result($result,$i,'columns');
            if($MobileLanguageType == 'en'){
                $realcolumns=$adb->query_result($result,$i,'realencolumns');
            }else{
                $realcolumns=$adb->query_result($result,$i,'realcolumns');
            }
            $fieldlabels=explode(':',$realcolumns);
            if($fieldlabels[0]=='ld_salesorder'&&!$this->checkModulePermit("SalesOrder"))
            {
                continue;
            }
            if($fieldlabels[0]=='ld_servicecontracts'&&!$this->checkModulePermit("ServiceContracts"))
            {
                continue;
            }
            if($fieldlabels[0]=='ld_cashbill'&&!$this->checkModulePermit("CashBill"))
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
            
            $columnname=$fieldlabels[1];
            
            $fieldlabel=substr($fieldlabels[3],strpos($fieldlabels[3],'_')+1);
            $fieldlabels=explode('_',$fieldlabels[3]);
            $reportFindHeader.='<th>&nbsp;'.$fieldlabel.'</th>';
            $showcolLists[ $showcolkey.':'.$typeofdata]=array($columshow=>$fieldlabels[0]);
        }
        $reportFindHeader .= '</tr>';
        //editor:gyq_122 reason:删除__construct复杂参数，抽成新方法init_params 2019/6/13 17:28
        $OftenUseReport=new OftenUseReport();
        $OftenUseReport->init_params($reporttype,$reportname,$usereportid,$adb,$showcolLists,$AllReportHeaders,$reportabid,0);
        $reportcontent = $OftenUseReport->getReportListView();
        $reportcontent = preg_replace("/<a[^>]*>|<\/a>/i",'',$reportcontent);
        $reportcontent = preg_replace("/onmouse(over|out)=.*[>$]/U",'>',$reportcontent);
        $reportcontent = preg_replace("/id='.*'/U",'',$reportcontent);
        $html = '<table class="TableOften"><tbody>'.$reportFindHeader.$reportcontent.'</tbody></table>';
        $entity['html'] = $html;
        $entity['search_reminds'] = getFixedLabel('SERACHACCOUNT');
        return $entity;
    }
    /**
     * @return array
     * @throws Exception
     * 获取移动端-客户地图查询字段
     */
    public function getAccountsMapHighSearchFields(){
        global $adb,$current_user;
        //平铺查找条件
        $sql = 'select id,searchvalue from ld_searchhistory where modulename = ? and searchtype = ? order by searchtime desc';
        $result = $adb->pquery($sql,array('ChinaMap','TiledSearch'));
        $num_rows = $adb->num_rows($result);
        $high_search = [];//最终返回的高级查找数组
        $frommodule = 'Accounts';
        $customView = CustomView::getInstance($frommodule);
        $queryGenerator =QueryGenerator::getInstance($frommodule, $current_user,$customView);
        crm_load_class_file('ProductDetail_ListController','include/ListView/ProductDetail');
        $controller = new ProductDetail_ListController($adb, $current_user, $queryGenerator);
        $meta = $queryGenerator->getMeta($frommodule);
        $AllmoduleFields = $meta->getListSearchFields();
        $detailmodulefields = $controller->getAdvancedSearchAllModuleFields($frommodule);
        $detailmodulefields = $detailmodulefields['contacts'];
        if (is_array($detailmodulefields) && sizeof($detailmodulefields) > 0)
            $AllmoduleFields = array_merge($AllmoduleFields, $detailmodulefields);

        if($num_rows >0){
            $tiledSearch = $adb->query_result($result,0,'searchvalue');
            $tiledSearch = Zend_Json::decode($tiledSearch);
            $advft_criteria = $tiledSearch['advft_criteria'];
            if(sizeof($advft_criteria)>0){
                foreach($advft_criteria as $v){
                    $temp_columnname = $v['columnname'];
                    $temp_value = $v['value'];
                    $temp_value = explode(',',$temp_value);
                    $temp_columnname_arr = explode(':',$temp_columnname);
                    $temp_columnname_str = $temp_columnname_arr[1];
                    $uitype = $AllmoduleFields[$temp_columnname_str]->uitype;
                    $fieldname = $AllmoduleFields[$temp_columnname_str]->fieldLableKey;
                    $field_temp = [
                        'm_content'=>$temp_value[0],
                        'm_content_end'=>$temp_value[1]?$temp_value[1]:'',
                        'selected'=>'',
                        'text'=>$fieldname,
                        'uitype'=>$uitype,
                        'value'=>$temp_columnname,
                    ];
                    $high_search[] = $field_temp;
                }
            }
        }
        return $high_search;
    }
    public function setAccountsMapHighSearchAdvftCriteria(){
        $high_search = $_REQUEST['high_search'];
        $advft_criteria = [];
        //[{"groupid":"1","columnname":"ld_accountscf:leadsource:leadsource:Accounts_客户来源:V","comparator":"isnotnull","value":"","columncondition":""}]
        if(is_array($high_search)&&sizeof($high_search)>0){
            foreach($high_search as $v){
                $temp_columnname = $v['value'];
                $temp_columnname_arr = explode(':',$temp_columnname);
                $bigtype = $temp_columnname_arr[4];
                $comparator_temp='c';
                $value_temp = $v['m_content'];
                if($bigtype=='D'||$bigtype=="T"||$bigtype=="DT"){
                    $comparator_temp = 'bw';
                    $value_temp = $v['m_content'].','.$v['m_content_end'];
                }
                $temp_criteria = [
                    'groupid'=>1,
                    'columnname'=>$v['value'],
                    'comparator'=>$comparator_temp,
                    'value'=>$value_temp,
                    'columncondition'=>'and',
                ];
                $advft_criteria[] = $temp_criteria;
            }
            $advft_criteria[sizeof($advft_criteria)-1]['columncondition'] = '';
            $_REQUEST['advft_criteria_groups'] = '[null,{"groupcondition":""}]';
            $_REQUEST['advft_criteria'] = Zend_Json::encode($advft_criteria);
        }
    }
    //客户地图报表
    public function getAccountsMap(){
        //BUG0063660 移动端，客户地图更改查看范围，客户地图没有改变 edit: hzx 20230329
        if(isset($_REQUEST['selectuid']))
            $_REQUEST['SearchScope']=$_REQUEST['selectuid'];//选择的用户
        if(strtolower($_REQUEST['SearchScope'])=='all')
        {
            $_REQUEST['SearchScope']='SmOwner_Search_All';
        }
        $jsonArray['high_search']['list'] = $this->getAccountsMapHighSearchFields();
        $this->setAccountsMapHighSearchAdvftCriteria();
        //editor:gyq_20190528 reason:将PC代码提取为类方法get_account_map 0036898
        //0036898: （公司自用账套）企业微信>灵当CRM>报表>客户地图：地图没有统计数据，电脑端是有数据的。
        setSearchAllAccount();//设置查询所有的客户（包括公海客户）
        $account_info = $this->get_account_map();
        $i = 0;
        $map_arr = array();
        $exist_state = array();
        foreach ($account_info as $key=>$value){
            $name = $value['name'];
            if(in_array($name,$exist_state))
                continue;
            else{
                $exist_state[] = $name;
                $map_arr[$i] = array('name'=>$name,'value'=>$value['value']);
                foreach ($account_info as $key2=>$value2){
                    if($value2['name']==$name && $key2 != $key){
                        $map_arr[$i]['value'] += $account_info[$key2]['value'];
                    }
                }
                $i++;
            }
        }
        $jsonArray['list'] = $map_arr;
        $jsonArray['json'] = file_get_contents(globalStatic::$root_directory."chinamap/json/china.json"); 
        return $jsonArray;
    }
    //editor:gyq_20190528 reason:将PC代码提取为类方法get_account_map 0036898
    //0036898: （公司自用账套）企业微信>灵当CRM>报表>客户地图：地图没有统计数据，电脑端是有数据的。
    public function get_account_map(){
        global $adb,$current_user;
        $customView = CustomView::getInstance('Accounts');

        //高级条件----2021-1015-- zxm 【客户地图增加“平铺查找”功能】https://www.tapd.cn/63637123/prong/stories/view/1163637123001002063
        crm_load_class_file("ReportTableWhere",'modules/CustomTables/Query');
        $advft_criteria = $_REQUEST['advft_criteria'];
        $advft_criteria = Zend_Json::decode($advft_criteria);
        $advft_criteria_sql_arr = [];
        $left_sql_arr = [];
        $left_table_arr = [];
        if(is_array($advft_criteria)&&sizeof($advft_criteria)>0){
            foreach($advft_criteria as $advft){
                $columnname_temp = explode(':',$advft['columnname']);
                $tablename_temp = $columnname_temp[0];
                $datatype_temp = $columnname_temp[4];
                $value_temp = $advft['value'];
                $comparator_temp = $advft['comparator'];
                $comparator_temp = trim($comparator_temp);
                if($tablename_temp!='ld_account'&&!in_array($tablename_temp,$left_table_arr)){
                    $left_sql_arr[] = ' left join '.$tablename_temp.' on '.$tablename_temp.'.accountid=ld_account.accountid';
                    $left_table_arr[] = $tablename_temp;
                }

                $reportwhereobj = new ReportTableWhere('Accounts');

                $reportwhereobj->setWhereColumn($advft['columnname']);
                $reportwhereobj->setComparator($advft['comparator']);
                $reportwhereobj->setSearchText($advft['value']);
                $tmpwhere = $reportwhereobj->getWhere();
                $tmpwhere = trim($tmpwhere,'((');
                $tmpwhere = trim($tmpwhere,'))');
                $tmpwhere .= ' '.$advft['columncondition'] .' ';
                $advft_criteria_sql_arr[] = $tmpwhere;
            }
        }
        $advft_criteria_sql_str = empty($advft_criteria_sql_arr)?"":' and '.implode('',$advft_criteria_sql_arr);
        $left_table_str = empty($left_sql_arr)?'':implode('',$left_sql_arr);
        $queryGenerator =QueryGenerator::getInstance('Accounts', $current_user,$customView);
        $whereRangeQuery = $queryGenerator->whereRangeQuery();

        $account_info = array();

        if(!empty($_REQUEST['bill_state'])){
            // 按城市分组
            $bill = 'bill_city';
            //zxm 20221216 重庆市下城市字段的下拉框值有重庆市和县两个值  重庆市需要特别判断
            $query = "select distinct bill_state,(case when $bill=bill_state or bill_state='重庆市' then bill_area else $bill end)    as name,count(1) as account_num from ld_account";
            if(!is_admin($current_user)){
                $query .= ' LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_account.accountid and ld_tabshare.Shareuserid='.$current_user->id;
            }
            //高级条件----2021-1015-- zxm 【客户地图增加“平铺查找”功能】https://www.tapd.cn/63637123/prong/stories/view/1163637123001002063
            $query .= $left_table_str;
            $query .= " where deleted = 0 and ifnull(bill_country,'中国')= '中国' and bill_state like '%".$_REQUEST['bill_state']."%' and $bill !='' ";
            //高级条件----2021-1015-- zxm 【客户地图增加“平铺查找”功能】https://www.tapd.cn/63637123/prong/stories/view/1163637123001002063
            $query .= $advft_criteria_sql_str;
            $query .= $whereRangeQuery;
            $query .= " GROUP BY name ";

            $result = $adb->pquery($query,array());
        }else if(!empty($_REQUEST['bill_country'])){
            //zxm 2020-0928 客户地图增加全球的地图的显示 按省份分组的数据增加条件判断
            //按省份分组
            $query = "select distinct bill_country,bill_state as name,count(1) as account_num from ld_account";
            if(!is_admin($current_user)){
                $query .= ' LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_account.accountid and ld_tabshare.Shareuserid='.$current_user->id;
            }
            //高级条件----2021-1015-- zxm 【客户地图增加“平铺查找”功能】https://www.tapd.cn/63637123/prong/stories/view/1163637123001002063
            $query .= $left_table_str;
            $query .=" where deleted = 0 and ifnull(bill_country,'中国') = '中国' and bill_state !='' ";
            //高级条件----2021-1015-- zxm 【客户地图增加“平铺查找”功能】https://www.tapd.cn/63637123/prong/stories/view/1163637123001002063
            $query .= $advft_criteria_sql_str;
            $query .= $whereRangeQuery;
            $query .= ' GROUP BY bill_state ';
            
            $result = $adb->pquery($query,array());
            $account_info[] = array('name'=>'南海诸岛','value'=>0,'itemStyle'=>array('normal'=>array('opacity'=>0,'label'=>array('show'=>false))));
        }else{
            //按国家分组
            //zxm 2020-0928 客户地图增加全球的地图的显示 按国家分组查询数据
            $query = "select distinct bill_country as name,count(1) as account_num from ld_account";
            if(!is_admin($current_user)){
                $query .= ' LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_account.accountid and ld_tabshare.Shareuserid='.$current_user->id;
            }
            //高级条件----2021-1015-- zxm 【客户地图增加“平铺查找”功能】https://www.tapd.cn/63637123/prong/stories/view/1163637123001002063
            $query .= $left_table_str;
            $query .=" where deleted = 0 and bill_country !='' ";
            //高级条件----2021-1015-- zxm 【客户地图增加“平铺查找”功能】https://www.tapd.cn/63637123/prong/stories/view/1163637123001002063
            $query .=  $advft_criteria_sql_str;
            $query .= $whereRangeQuery;
            $query .= ' GROUP BY name ';
            $result = $adb->pquery($query,array());
        }
        $num_rows = $adb->num_rows($result);

        crm_load_class_file('EchartSetting','modules/CustomEcharts');
        for($i = 0; $i<$num_rows; $i++){
            $bill_state = trim($adb->query_result($result,$i,'name'));
            $bill_state = EchartSetting::prvinceNameChange($bill_state);
            $account_num = $adb->query_result($result,$i,'account_num');
            $account_info[] = array('name'=>$bill_state,'value'=>$account_num);
        }
        return $account_info;
    }
    public function getSalesPhaseTransformationAnalysis(){
        //zxm 20231023 移动端看板定制 数据的条件根据看板设置的条件来控制
        require_once(globalStatic::$root_directory.'modules/Home/HomeChartUtils.php');
        $HomeUtilsObj = new HomeChartUtils($this->homeboardid);
        $search_type = $_REQUEST['reporttype'];
        if(empty($search_type)) $search_type='thismonth';
        if($search_type=="custom"){
            $search_type = $_REQUEST['custom_data'];
        }
        $params = array(
            'scopeType'=>$_REQUEST['selectuid']=='all'?'SmOwner_Search_All':$_REQUEST['scopeType'],
            'senioruserid'=>$_REQUEST['selectuid'],
            'search_date'=>$search_type,
            'approve_value'=>$_REQUEST['approve_value'],
            'boardselect_stage_value'=>$_REQUEST['boardselect_stage_value'],
        );
        $HomeUtilsObj->initParam($params);
        $HomeUtilsObj->setStuffid(112,0);
        $home_values = $HomeUtilsObj->getStuffData();

        $jsonArray['list'] = $home_values;
        $jsonArray['mobilePenetrateModule'] = $home_values['mobilePenetrateModule'];
        $jsonArray['chuantouParamsName'] = $home_values['chuantouParamsName'];
        $jsonArray['can_penetrate'] = $home_values['can_penetrate'];
        $jsonArray['title'] = getFixedLabel('SalesPhaseTransformationAnalysis');
        //上级字段下拉框值
        crm_load_class_file('ModuleUtils','modules/lingdang');
        $ModuleUtilsObj = new ModuleUtils();
        $sourcefield = $ModuleUtilsObj->getPrevAdvanceFieldname('Potentials','sales_stage');
        //是级联字段 且有上级字段
        $all_prev_advance_fieldname_value = [];
        if (!empty($sourcefield)) {
            //C:\ldcrm\www\crm\modules\PickList\PickListUtils.php
            crm_load_class_file('PickListUtils','modules/PickList');
            $all_prev_advance_fieldname_value = [''=>''];
            $all_prev_advance_fieldname_value =  array_merge($all_prev_advance_fieldname_value, getAllPickListValues($sourcefield));
        }
        $jsonArray['all_prev_advancelist'] =array_values($all_prev_advance_fieldname_value);
        $jsonArray['reportid']=112;
        return $jsonArray;
    }
    public function getAccountleadsource(){//客户来源统计
        require_once(globalStatic::$root_directory.'modules/Home/HomeChartUtils.php');
        $HomeUtilsObj = new HomeChartUtils($this->homeboardid);
        $search_type = $_REQUEST['reporttype'];
        if(empty($search_type)) $search_type='thismonth';
        if($search_type=="custom"){
            $search_type = $_REQUEST['custom_data'];
        }
        $params = array(
            'scopeType'=>$this->scopeType,
            'senioruserid'=>$this->selectuid,
            'search_date'=>$search_type,
            'approve_value'=>$_REQUEST['approve_value'],
        );
        $HomeUtilsObj->initParam($params);
        $HomeUtilsObj->setStuffid(106,0);
        $home_values = $HomeUtilsObj->getStuffData();
        $home_values['reportid']=106;
        return $home_values;
    }
    public function getAccountaccounttype(){//客户类型统计
        require_once(globalStatic::$root_directory.'modules/Home/HomeChartUtils.php');
        $HomeUtilsObj = new HomeChartUtils($this->homeboardid);
        $search_type = $_REQUEST['reporttype'];
        if(empty($search_type)) $search_type='thismonth';
        if($search_type=="custom"){
            $search_type = $_REQUEST['custom_data'];
        }
        $params = array(
            'scopeType'=>$this->scopeType,
            'senioruserid'=>$this->selectuid,
            'search_date'=>$search_type,
            'approve_value'=>$_REQUEST['approve_value'],
        );
        $HomeUtilsObj->initParam($params);
        $HomeUtilsObj->setStuffid(107,0);
        $home_values = $HomeUtilsObj->getStuffData();
        $home_values['reportid']=107;
        return $home_values;
    }

    public function getCustomerIndustryStatistic(){//客户行业统计
        require_once(globalStatic::$root_directory.'modules/Home/HomeChartUtils.php');
        $HomeUtilsObj = new HomeChartUtils($this->homeboardid);
        $search_type = $_REQUEST['reporttype'];
        if(empty($search_type)) $search_type='thismonth';
        if($search_type=="custom"){
            $search_type = $_REQUEST['custom_data'];
        }
        $params = array(
            'scopeType'=>$this->scopeType,
            'senioruserid'=>$this->selectuid,
            'search_date'=>$search_type,
            'approve_value'=>$_REQUEST['approve_value'],
        );
        $HomeUtilsObj->initParam($params);
        $HomeUtilsObj->setStuffid(119,0);
        $home_values = $HomeUtilsObj->getStuffData();
        $home_values['reportid']=119;
        return $home_values;
    }
    
   
    public function getSaleskit(){//销售简报
        //editor:gyq_20190425 reason:0036958: （http://180.169.77.146:85/crm [^]）
        //企业微信>灵当CRM>报表>销售简报：查看时间为：本月、查看范围为：福建大区，查询出来的数据和pc端查询出来的数据不一致。
        $search_type = $_REQUEST['reporttype'];
        if(empty($search_type)) $search_type='thismonth';
        //zxm 2021-0113【移动端首页界面，时间查询范围中增加“自定义时间”选项】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001000289
        if($search_type=="custom"){
            $search_type = $_REQUEST['custom_data'];
        }
        include_once globalStatic::$root_directory.'modules/Home/HomeStuffDetailUtils.php';
        $HomeStuffDetailUtilsObj = new HomeStuffDetailUtils($this->homeboardid);
        $params = array(
            'scopeType'=>$this->scopeType,
            'senioruserid'=>$this->selectuid,
            'search_date'=>$search_type,
            'approve_value'=>$_REQUEST['approve_value'],
        );
        $HomeStuffDetailUtilsObj->initParam($params);
        $HomeStuffDetailUtilsObj->setStuffid(35,0);

        //zxm 20230807销售简报识别自定义简报内容
        $orign_sales_data = $HomeStuffDetailUtilsObj->getSalesKit();

        $orign_sales_data = array_values($orign_sales_data);
        foreach($orign_sales_data as $key=>$val){
            unset($orign_sales_data[$key]['urls']);
        }
        $jsonArray['list'] = $orign_sales_data;

        //简报布局设置
        include_once globalStatic::$root_directory.'modules/Home/HomeBoardNew/SalesKitEditSetting.php';

        $SalesKitEditObj=new SalesKitEditSetting($this->homeboardid);
        $SalesKitEditObj->setStuffId(35);
        $SalesKitEditObj->setBoardStuffId(0);
        $saleskitlayout = $SalesKitEditObj->getSaleskitLayout(count($orign_sales_data));

        $jsonArray['saleskit_layout'] = $saleskitlayout;
        $jsonArray['reportid']=35;
        return $jsonArray;
    }
    //数据龙虎榜
    public function getDataDragonTigerList(){
        global $current_user;
        //editor:gyq_20190425 reason:0036958: （http://180.169.77.146:85/crm [^]）
        //企业微信>灵当CRM>报表>销售简报：查看时间为：本月、查看范围为：福建大区，查询出来的数据和pc端查询出来的数据不一致。
        $search_type = $_REQUEST['reporttype'];
        if(empty($search_type)) $search_type='thismonth';
        //zxm 2021-0113【移动端首页界面，时间查询范围中增加“自定义时间”选项】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001000289
        if($search_type=="custom"){
            $search_type = $_REQUEST['custom_data'];
        }

        //页签数据
        crm_load_class_file('DragonTigerList','modules/Home/HomeBoardNew');
        $DragonTigerListObj=new DragonTigerList($this->homeboardid);
        //$DragonTigerListObj->setStuffId(100);
        $DragonTigerListObj->setBoardStuffId("");
        $DragonTigerListObj->getSelectedSalesKitList(100);
        $DragonTigerList = $DragonTigerListObj->selected_saleskit_list;
        $DragonTigerList = array_values($DragonTigerList);
        //选中的页签值
        if(isset($_REQUEST['DefaultStuffLabel']) && !empty($_REQUEST['DefaultStuffLabel']) && $_REQUEST['DefaultStuffLabel'] != 'undefined'){
            $DefaultStuffLabel = $_REQUEST['DefaultStuffLabel'];
            //保存选中的页签
            setUsersettingByLabel('MobileReport',$current_user->id,'DragonTigerList_PageTab',$DefaultStuffLabel);
        }
        else{
            $DefaultStuffLabel = getUsersettingByLabel('MobileReport',$current_user->id,'DragonTigerList_PageTab');
            $DefaultStuffLabel = empty($DefaultStuffLabel)?$DragonTigerList[0]['stufflabel']:$DefaultStuffLabel;//没选中过就将第一个值选中
        }
        $TabInfo = [];
        foreach($DragonTigerList as $tmpdragon){
            $TabInfo[] = [
                'homestuffdetailid' => $tmpdragon['homestuffdetailid'],
                'stufflabel' => $tmpdragon['stufflabel'],
                'zh' => $tmpdragon['zh'],
                'en' => $tmpdragon['en'],
                'selected' => $tmpdragon['stufflabel']==$DefaultStuffLabel?'yes':'no',
                'topnumber' => $tmpdragon['topnumber'],
                'label' => $tmpdragon['label'],
                'can_penetrate'=>count($tmpdragon['computeinfo'])==1?'yes':'no',
                'module'=>implode(',',_array_column($tmpdragon['computeinfo'],'computemodule'))
            ];
        }
        $jsonArray['TabInfo'] = $TabInfo ;
        include_once globalStatic::$root_directory.'modules/Home/HomeStuffDetailUtils.php';
        $HomeStuffDetailUtilsObj = new HomeStuffDetailUtils($this->homeboardid);
        $params = array(
            'scopeType'=>$this->scopeType,
            'senioruserid'=>$this->selectuid,
            'search_date'=>$search_type,
            'approve_value'=>$_REQUEST['approve_value'],
            'boardid'=>$this->homeboardid,
            'stuffid'=>100,
            'data_type'=>$DefaultStuffLabel,
            'showIcon'=>'no'//移动端不显示图标  不反悔图标数据
        );
        $HomeStuffDetailUtilsObj->initParam($params);
        $HomeStuffDetailUtilsObj->setStuffid(100,0);
        $orign_sales_data = $HomeStuffDetailUtilsObj->getDragonTigerListData($params);
        $jsonArray['list'] = $orign_sales_data;
        $jsonArray['reportid'] = 100;
        return $jsonArray;
    }
    public function getContractamount(){//签约额度同比
        require_once(globalStatic::$root_directory.'modules/Home/HomeChartUtils.php');
        $HomeUtilsObj = new HomeChartUtils($this->homeboardid);
        $search_type = $_REQUEST['reporttype'];
        if(empty($search_type)) $search_type='thismonth';
        if($search_type=="custom"){
            $search_type = $_REQUEST['custom_data'];
        }
        $params = array(
            'scopeType'=>$this->scopeType,
            'senioruserid'=>$this->selectuid,
            'search_date'=>$search_type,
            'approve_value'=>$_REQUEST['approve_value'],
        );
        $HomeUtilsObj->initParam($params);
        $HomeUtilsObj->setStuffid(4,0);
        $home_values = $HomeUtilsObj->getStuffData();
        if(empty($home_values))return '';
        $home_values['reportid'] = 4;
        return $home_values;
    }
    public function getReturnamount(){//回款金额同比
        require_once(globalStatic::$root_directory.'modules/Home/HomeChartUtils.php');
        $HomeUtilsObj = new HomeChartUtils($this->homeboardid);
        $search_type = $_REQUEST['reporttype'];
        if(empty($search_type)) $search_type='thismonth';
        if($search_type=="custom"){
            $search_type = $_REQUEST['custom_data'];
        }
        $params = array(
            'scopeType'=>$this->scopeType,
            'senioruserid'=>$this->selectuid,
            'search_date'=>$search_type,
            'approve_value'=>$_REQUEST['approve_value'],
        );
        $HomeUtilsObj->initParam($params);
        $HomeUtilsObj->setStuffid(5,0);
        $home_values = $HomeUtilsObj->getStuffData();
        if(empty($home_values))return '';
        $home_values['reportid'] = 5;
        return $home_values;
    }
    public function getSalesfunnel(){//销售漏斗
        $jsonArray = array();
        require_once(globalStatic::$root_directory.'modules/Home/HomeChartUtils.php');
        $HomeUtilsObj = new HomeChartUtils($this->homeboardid);
        $search_type = $_REQUEST['reporttype'];
        if(empty($search_type)) $search_type='thismonth';
        if($search_type=="custom"){
            $search_type = $_REQUEST['custom_data'];
        }
        $params = array(
            'scopeType'=>$this->scopeType,
            'senioruserid'=>$this->selectuid,
            'search_date'=>$search_type,
            'approve_value'=>$_REQUEST['approve_value'],
        );
        $HomeUtilsObj->initParam($params);
        $HomeUtilsObj->setStuffid(19,0);
        $home_values = $HomeUtilsObj->getStuffData();
        if(empty($home_values))return '';
        $jsonArray['list']['funnel_data'] = $home_values['funnel_data'];
        $jsonArray['list']['option'] = $home_values['option'];

        //表格的表头信息
        $moduleobj = CRMEntity::getInstance('Potentials');
        $field=$moduleobj->fieldobj->getFieldInfoobjBykey('columnname','sales_stage');
        $title_arr[] = $field->fieldLableKey;
        $title_arr[] = getFixedLabel('OPPORTUNITIESNUMBER');
        $field=$moduleobj->fieldobj->getFieldInfoobjBykey('columnname','amount');
        $title_arr[] = $field->fieldLableKey;
        $jsonArray['list']['title'] = $title_arr;
        //表格的明细信息 二维数组 amount:"103,597.00"name:"初期沟通"number:"13"percent:"43.3"value:100
        //描述信息
        $describeinfo['amountname'] = getFixedLabel('TotalAmount');
        $describeinfo['totalamount'] = $home_values['totalamount'];
        $describeinfo['totalnumber'] = $home_values['totalcount'];
        $describeinfo['totalnumber_str'] = sprintf(getFixedLabel('OPPORTUNITIESINTOTAL'),$home_values['totalcount']);
        $jsonArray['describeinfo']=$describeinfo;
        $jsonArray['reportid'] = 19;
        return $jsonArray;
    }
    public function getTD_PotentialsFunnel()//销售漏斗(含目标）天地特殊开发
    {
        //zxm 20231023 移动端看板定制 数据的条件根据看板设置的条件来控制
        require_once globalStatic::$root_directory.'modules/Home/CustomMade/TiandiUtils.php';
        $TiandiUtilsObj = new TiandiUtils($this->homeboardid);
        $search_type = $_REQUEST['reporttype'];
        if(empty($search_type)) $search_type='thismonth';
        if($search_type=="custom"){
            $search_type = $_REQUEST['custom_data'];
        }
        $params = array(
            'scopeType'=>$_REQUEST['selectuid']=='all'?'SmOwner_Search_All':$_REQUEST['scopeType'],
            'senioruserid'=>$_REQUEST['selectuid'],
            'search_date'=>$search_type,
            'approve_value'=>$_REQUEST['approve_value'],
            'boardselect_stage_value'=>$_REQUEST['boardselect_stage_value'],
        );
        $TiandiUtilsObj->initParam($params);
        $TiandiUtilsObj->setStuffid(115,0);
        $home_values = $TiandiUtilsObj->getStuffData();
        $jsonArray['list'] = $home_values;
        $jsonArray['title'] = getFixedLabel('TD_PotentialsFunnel');
        $jsonArray['reportid']=115;
        return $jsonArray;
    }
    public function getTargetAnalysis()//目标分析 xll
    {
        $this->getselectuid();
        $_REQUEST['selectuid'] = $this->selectuid;
        $jsonArray = [];
        //zxm 20231023 移动端看板定制 数据的条件根据看板设置的条件来控制
        require_once(globalStatic::$root_directory.'modules/Home/HomeUtils.php');
        $HomeUtilsObj = new HomeUtils($this->homeboardid);
        $search_type = $_REQUEST['reporttype'];
        if(empty($search_type)) $search_type='thismonth';
        if($search_type=="custom"){
            $search_type = $_REQUEST['custom_data'];
        }
        if(!isset($_REQUEST['targetid'])){
            include_once(globalStatic::$root_directory .'Smarty_setup.php');
            crm_load_class_file('TargetAnalysis','modules/Home/HomeBoardNew');
            $TargetAnalysisObj=TargetAnalysis::getInstance($this->homeboardid);
            $jsonArray['TabInfo'] = array_values($TargetAnalysisObj->getNavBarList(''));
            $_REQUEST['targetid'] = $TargetAnalysisObj->TargetID;
        }
        $params = array(
            'scopeType'=>isset($_REQUEST['scopeType'])?$_REQUEST['scopeType']:'smowner_search_senior',
            'senioruserid'=>$this->selectuid,
            'search_date'=>$search_type,
            'approve_value'=>$_REQUEST['approve_value'],
            'boardselect_stage_value'=>$_REQUEST['boardselect_stage_value'],
        );
        $HomeUtilsObj->initParam($params);
        $HomeUtilsObj->setStuffid(114,0);
        $home_values = $HomeUtilsObj->getStuffData();
        $jsonArray['list'] = array_values($home_values['res_data']);
        $jsonArray['title'] = getFixedLabel('TargetAnalysis');
        $jsonArray['reportid']=114;
        return $jsonArray;
    }
    public function getTargetAnalysisChildChart(){
        $this->getselectuid();
        $_REQUEST['selectuid'] = $this->selectuid;
        crm_load_class_file("TargetAnalysisChuantou","modules/lingdang/cls_Report");
        $search_type = $_REQUEST['reporttype'];
        if(empty($search_type)) $search_type='thismonth';
        if($search_type=="custom"){
            $search_type = $_REQUEST['custom_data'];
        }
        $obj = new TargetAnalysisChuantou();
        $obj->setParams([
            'boardid' => $this->homeboardid,
            'boardstuffid' => '',
            'stufftype' => '',
            'stuffid' => 114,
            'scopeType' => $_REQUEST['scopeType'],
            'selectuserid' => $this->selectuid,
            'search_date_custom_value' => $search_type,
            'approve_value' => $_REQUEST['approve_value'],
            'penetrateModule' => $_REQUEST['penetrateModule'],
        ]);
        $obj->getChildChartData();
        $obj->getSearchBtnHtml();
        $jsonArray = $obj->ChildChartData;
        $jsonArray['labelArr'] = [
            'Target' => getFixedLabel('TOLOOKVALUE'),
            'Done' => getFixedLabel('COMPLETIONVALUE'),
        ];
        $jsonArray['optionArr'] = $obj->optionArr;
        return $jsonArray;
    }
    public function getSalessituation(){//最近6个月销售情况
        //zxm 20230907 改成跟PC端走同一个方法   调HomeUtils类传参即可
        if($_REQUEST['reporttype']=="custom"){
            $time_range = $_REQUEST['custom_data'];
        }else{
            $time_range = $_REQUEST['reporttype'];
        }
        include_once globalStatic::$root_directory."modules/Home/HomeChartUtils.php";
        $homeboardid=empty($this->homeboardid)?0:$this->homeboardid;
        $HomeUtilsObj = new HomeChartUtils($homeboardid);
        $params = array(
            'scopeType'=>'smowner_search_senior',
            'senioruserid'=>$this->selectuid,
            'search_date'=>$time_range,
            'approve_value'=>$_REQUEST['approve_value'],
        );
        $HomeUtilsObj->initParam($params);
        $HomeUtilsObj->setStuffid(1,0);
        $jsonArray['list'] = $HomeUtilsObj->getStuffData();
        $jsonArray['reportid']=1;
        return $jsonArray;
    }

    /**
     * @edit:zhouxiaomei
     * @date:2020-09-07
     * @reason:增加最近6个月销售目标完成情况
     */
    public function getcomplationRateSixMonth(){

        //edit: xll 2023/08/14 XUQIU1001400 近六个月目标完成情况的指标页签改为按目标管理中的指标
        if($_REQUEST['getResult'] == 'TabList'){
            $TabList = $this->getReportTabList();
            $jsonArray['list']['TabList'] = $TabList;
            return $jsonArray;
        }
        include_once globalStatic::$root_directory."modules/Home/HomeChartUtils.php";
        $homeboardid=empty($this->homeboardid)?0:$this->homeboardid;
        $HomeUtilsObj = new HomeChartUtils($homeboardid);
        $params = array(
            'scopeType'=>'smowner_search_senior',
            'senioruserid'=>$this->selectuid,
            'data_type'=>$this->data_type,
            'approve_value'=>$_REQUEST['approve_value'],
        );
        $HomeUtilsObj->initParam($params);
        $HomeUtilsObj->setStuffid(40,0);
        $home_values = $HomeUtilsObj->getStuffData();

        //require_once(globalStatic::$root_directory.'modules/SalesOrder/ListTopSalesOrder.php');
        //$home_values=getCompanySixMonthSalesRate($this->scopeType,$this->selectuid,$this->data_type,40,$this->homeboardid,0);

        $d = $home_values['Entries'];
        $jsonArray['list']['month_data']=$d['month'];
        $jsonArray['list']['target_data']=$d['target'];
        $jsonArray['list']['done_data']=$d['done'];
        $jsonArray['list']['rate_data']=$d['rate'];
        $jsonArray['list']['indicator_unit'] = $d['indicator_unit'];//wym 240410 XUQIU20240305-01 目标管理，增加设置“指标单位”和“换算率”（张华）
        $jsonArray['reportid']=40;
        return $jsonArray;
    }
    /**
     * @edit: xll
     * @date: 2023/08/14
     * @reason:移动端增加目标完成率仪表盘
     */
    public function getTargetCompletionRate(){
        if($_REQUEST['getResult'] == 'TabList'){
            $TabList = $this->getReportTabList();
            $jsonArray['list']['TabList'] = $TabList;
            return $jsonArray;
        }
        include_once globalStatic::$root_directory."modules/Home/HomeChartUtils.php";
        $homeboardid=empty($this->homeboardid)?0:$this->homeboardid;
        $HomeUtilsObj = new HomeChartUtils($homeboardid);
        $params = array(
            'scopeType'=>'smowner_search_senior',
            'senioruserid'=>$this->selectuid,
            'data_type'=>$this->data_type,
            'approve_value'=>$_REQUEST['approve_value'],
        );
        $HomeUtilsObj->initParam($params);
        $HomeUtilsObj->setStuffid(101,0);
        $home_values = $HomeUtilsObj->getStuffData();

        //require_once(globalStatic::$root_directory.'modules/SalesOrder/ListTopSalesOrder.php');
        //$home_values=getTargetCompletionRate($this->scopeType,$this->selectuid,$this->data_type,101,0,0);

        $d = $home_values['Entries'];
        $jsonArray['list']['month_data']=$d['month'];
        $jsonArray['list']['target_data']=$d['target'];
        $jsonArray['list']['done_data']=$d['done'];
        $jsonArray['list']['undone_data']=$d['undone'];
        $jsonArray['list']['rate_data']=$d['rate'];
        $jsonArray['reportid']=101;
        return $jsonArray;
    }
    /**
     * @edit: xll
     * @date: 2023/08/14
     * @reason: 获取目标管理中设置的指标列表
     */
    public function getReportTabList(){
        global $languageType;
        $TabList = [];
        $name = $this->reportInfo['name'];
        $nameArr_salesgoal = ['complationRateSixMonth','TargetCompletionRate'];
        if(in_array($name,$nameArr_salesgoal)){
            crm_load_class_file('SalesGoalNew.class','modules/SalesGoal');
            $SalesGoalNewObj = new SalesGoalNew();
            $salesGoalList = $SalesGoalNewObj->getPermitSalesGoal('');
            $labelKey = ($languageType == 'zh') ? 'zhlabel' : 'enlabel';
            foreach ($salesGoalList as $key => $salesGoalInfo){
                $targetid = $salesGoalInfo['targetid'];
                $targetname = $salesGoalInfo['targetname'];
                $showtype = $salesGoalInfo['showtype'];
                if($showtype == 'board'){
                    $TabList[$targetid]['name'] = strtolower($targetname);
                    $TabList[$targetid]['label'] = $salesGoalInfo[$labelKey];
                }
            }
        }
        return $TabList;
    }
    //设置筛选时间
    public function set_filter_time_range(){
        if(!empty($_REQUEST['reporttype'])){
            $defaultTime = $_REQUEST['reporttype'];
        }
        //缺一个上季度
        $time_range = array(
            array('time_key'=>'today','label'=>getMobileFixedLabel('checktoday'),'key'=>'thistoday'),
            array('time_key'=>'syesterday','label'=>getMobileFixedLabel('checkyesterday'),'key'=>'yestoday'),
            array('time_key'=>'lastweek','label'=>getMobileFixedLabel('lastweek'),'key'=>'lastweek'),
            array('time_key'=>'thisweek','label'=>getMobileFixedLabel('thisweek'),'key'=>'thisweek'),
            array('time_key'=>'thismonth','label'=>getMobileFixedLabel('thismonth'),'key'=>'thismonth'),
            array('time_key'=>'lastmonth','label'=>getMobileFixedLabel('lastmonth'),'key'=>'lastmonth'),
            array('time_key'=>'thisfq','label'=>getMobileFixedLabel('thisfq'),'key'=>'thisquarter'),
            array('time_key'=>'prevfq','label'=>getMobileFixedLabel('prevfq'),'key'=>'lastquarter'),
            array('time_key'=>'thisfy','label'=>getMobileFixedLabel('thisyear1'),'key'=>'thisyear'),
            array('time_key'=>'prevfy','label'=>getMobileFixedLabel('lastyear1'),'key'=>'lastyear'),
            array('time_key'=>'all','label'=>getMobileFixedLabel('ALL'),'key'=>'all'),
            array('time_key'=>'custom','label'=>getMobileFixedLabel('CUSTOMTIME'),'key'=>'custom')
        );
        foreach ($time_range as $key=>$content){
            //默认值 系统设置的默认时间 zxm20211112 【首页，销售简报时间增加可设置默认值（王楠）】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001002217
            if($content['key']==$defaultTime || $content['time_key']==$defaultTime){
                $time_range[$key]['selected'] = "yes";
            }else{
                $time_range[$key]['selected'] = "no";
            }
            unset($time_range[$key]['key']);
            // $time_range[$key]['time_range'] = rangeTimeToDate($content['time_key'],time());
        }
        return $time_range;
    }
    
    //editor:gyq_20180930 0035345: （客户001）企业微信-报表：客户来源分布统计、客户类型分布统计，应该根据设定的查询日期选项查询
    public function get_time_range($r_timerange){
        $timeBetweenSql = '';
        if (array_key_exists($r_timerange, $this->timerangeArrOrign)) {
            $timerange = $this->timerangeArrOrign[$r_timerange];
        }else{
            $timerange = $r_timerange;
        }
        include_once(globalStatic::$root_directory . 'modules/CustomView/CommonView.php');
        $dateArr = CommonView::stdFilterDateTimeStr('lastmodified');
        $timerangeArr = $dateArr[$timerange];
        if(!empty($timerangeArr))
            $timeBetweenSql = 'between  \'' . $timerangeArr[0] . '\' and \'' . $timerangeArr[1] . '\' ';
        return $timeBetweenSql;
    }
    //editor:gyq_107 reason:企业微信即时库存查询报表  2019/4/3 11:49 
    public function InventoryQuery(){
        global $adb,$weixin_user;
        crm_load_class_file('cls_ListViewSpecialWX','WeiXinApp/list');
        crm_load_class_file('ReportModel','modules/OftenUseReport');
        crm_load_class_file('ReportSqlInventoryQuery','modules/OftenUseReport/ReportSQL');
        crm_load_class_file('CRMEntity','data');
        //editor:gyq_20190919
        //0038043: （http://51mis.com/demo/panlulu2/ [^]）企业微信端，即时库存查询报表中查询条件“显示库存数量为0的记录”设置为“否”时没有生效
        if($weixin_user->environment_weixin ){
            foreach ($_REQUEST['filter'] as $key=>$value){
                $_REQUEST[$key] = $value;
            }
        }
        $this->InventoryQuery_Search();
        $productname = '';
        $pici = '';
        $cangku  = $_REQUEST['filter']['basicotherfind3'];
        $shenpi = $_REQUEST['filter']['basicotherfind6'];
        //序时簿字段名
        $fieldname_1 = getFixedLabel('PRODUCTS').getFixedLabel('Numbers');
        $fieldname_2 = getFixedLabel('Specifications');
        $fieldname_3 = getFixedLabel('QTYINSTOCK');
        //单据明细中数量小数位数
        $sysdeploy = getSys_deploy(49);
        $length_amountdigits = $sysdeploy['deploy_value'];

        $reportmodel = new ReportModel();
        $shenpi = $reportmodel->setDefaultShenPi($shenpi);
       //edit:can 2021-01-07 044005: （企业微信移动端，kfbcrm）报表-即时库存查询；库存查询页面，右上角筛选功能，仓库筛选异常
        $new_ware = $reportmodel->getOftenUserReport_WareHouse();
        if(empty($cangku)){
            $cangku = $new_ware['wareid'];
        }
        
        if(empty($pici))
            $pici = '';

        //--------begin---------筛选条件
        $filter_list = array();
        $filter_list[0]['fieldlabel'] = getFixedLabel('WAREHOUSE').getFixedLabel('screen');
        $filter_list[0]['fieldname'] = 'basicotherfind3';
        $new_ware_i = 0;
        $filter_option0 = array();
        foreach ($new_ware['all'] as $key=>$value){
            if($new_ware_i===0)
                $filter_option0[$new_ware_i]['select'] = 'yes';
            else
                $filter_option0[$new_ware_i]['select'] = '';
            $filter_option0[$new_ware_i]['text'] = $value;
            $filter_option0[$new_ware_i]['value'] = $key;
            $new_ware_i++;
        }
        $filter_list[0]['option'] = $filter_option0;
        $filter_list[1]['fieldlabel'] = getFixedLabel('approvestatus');
        $filter_list[1]['fieldname'] = 'basicotherfind6';
        $filter_option1 = array();
//        @edit:liushuai,2021-03-18,reason:0045048: （kfbcrm，企业微信移动端）客户问题（美迪医疗），报表->即时库存查询，审批状态默认值没有根据系统参数“设置出库和入库类库单据更新库存数量的触发点”控制（需要补丁）
        $filter_option1[0]['select'] = $shenpi == 'all'?'yes':'';
        $filter_option1[0]['text'] = getFixedLabel('ALL');
        $filter_option1[0]['value'] = 'all';
        $filter_option1[1]['select'] = $shenpi == 'all'?'':'yes';
        $filter_option1[1]['text'] = getFixedLabel('Approved');
        $filter_option1[1]['value'] = getFixedLabel('Approved');

        $filter_list[1]['option'] = $filter_option1;
        //editor:gyq_140 reason:即时库存查询优化，增加条件:显示库存数量为0的记录  2019/8/28 16:46
        $filter_list[2]['fieldlabel'] = getFixedLabel('OFTENUSEREPORTTITLE1');
        $filter_list[2]['fieldname'] = 'show_zero_quantity';
        $filter_list[2]['option'] = array(
            array( 'select'=>'yes','text'=>getFixedLabel('YES'),'value'=>'yes'),
            array( 'select'=>'','text'=>getFixedLabel('NO'),'value'=>'no')
        );
        //--------end---------筛选条件
        //editor:gyq_20181219 0035805: （1.6登录）即时库存查询报表界面：直接点击“待入库数量”或“待出库数量”时，
        //弹出层中不显示单据明细数据，点击【生成报表】后，弹出层中才显示单据明细数据。预期结果：直接点击“待入库数量”或“待出库数量”时，弹出层中应该也显示单据明细数据
        $sql_obj = new ReportSqlInventoryQuery();
        $SQL = $sql_obj->InventoryQuery($cangku,$pici,$productname,$shenpi);
        $count_result = $adb->pquery($SQL,array());
        $listviewspecial = new  cls_ListViewSpecialWX("");
        if (!empty($count_result))
            $noofrows = $adb->num_rows($count_result);
        else
            $noofrows = null;
        $result = $listviewspecial->page($noofrows, $SQL, $adb);
        $numrows = $adb->num_rows($result);
        $list_detail = array();
        $html_content = '';
        if($numrows > 0){
            for($i=0;$i<$numrows;$i++) {
                $productid= $adb->query_result($result,$i,'productid');
                $list_detail[$i]['curid'] = $productid;
                $list_detail[$i]['curid_i'] = $productid.'_'.$i;
                $list_detail[$i]['title']= $adb->query_result($result,$i,'productname');
                $list_detail[$i]['hiddentitle']= $adb->query_result($result,$i,'productname');
                $list_detail[$i]['redkey']= array(2);
                //-----begin-----初始化序时簿显示字段内容
                $fieldcontent = array();
                $fieldcontent[] = $fieldname_1.': '.$adb->query_result($result,$i,'product_no');
                $productsheet = $adb->query_result($result,$i,'productsheet');
                $inventory_qty = $adb->query_result($result,$i,'inventory_qty');
                if(empty($productsheet)) $productsheet = '无';
                $fieldcontent[] = $fieldname_2.': '.$productsheet;
                $fieldcontent[] = $fieldname_3.': '.setNumberFormat($inventory_qty,$length_amountdigits);
                //-----end-----初始化序时簿显示字段内容
                $list_detail[$i]['field'] = $fieldcontent;
                $list_detail[$i]['display_status'] = 0;
                //editor:gyq_20191119 reason:优化报表内容载入速度
                $list_detail[$i]['get_entry_detail'] = implode(',',array($productid,'report',$cangku,$shenpi,$_REQUEST['show_zero_quantity']));
                //$reportmodel->product_detail_qtyinstock($productid,'report',$cangku,$shenpi);
            }
        }
        $list_entry['list'] = $filter_list;
        $list_entry['list1'] = $list_detail;
        $list_entry['search_reminds'] = getFixedLabel('PRODUCTNAME').'、'.getFixedLabel('Specifications').'、'.getFixedLabel('PRODUCTNUM').'、'.getFixedLabel('INVENTORY').'、'.getFixedLabel('BATCH');
        $list_entry = array_merge($list_entry,$listviewspecial->jsonArr);
		$list_entry['stock_view'] = getErpStockView();//CRM   ERP   CRM+ERP
        return $list_entry;
    }
    //editor:gyq_107 reason:企业微信即时库存查询报表  2019/4/4 16:29
    public function InventoryQuery_Search(){
        global $currentModule,$PlatformMC;
        //产品名称、规格型号、产品编号、库存、批次
        //模拟出PC端报表的高级查找条件
        $search_content = $_REQUEST['filter']['searchcontent'] ;
        if(!empty($search_content)) {
            $advft_criteria_inventory = '';
            $advft_criteria_condition = '';
            if (is_numeric($search_content)) {
                $advft_criteria_inventory .= ',{"groupid":"1","columnname":"ld_products:inventory_qty:weight:Products_库存数量:I","comparator":"h","value":"' . $search_content . '","columncondition":""}';
                $advft_criteria_condition = 'or';
            }
            $advft_criteria = '[{"groupid":"1","columnname":"ld_products:productname:productname:Products_产品名称:V","comparator":"c","value":"' . $search_content . '","columncondition":"or"},
                            {"groupid":"1","columnname":"ld_products:product_no:product_no:Products_产品编号:V","comparator":"c","value":"' . $search_content . '","columncondition":"or"},
                            {"groupid":"1","columnname":"ld_products:productsheet:productsheet:Products_型号:V","comparator":"c","value":"' . $search_content . '","columncondition":"or"},
                           
                            {"groupid":"1","columnname":"ld_stock:batchtext:batchtext:Stock_批次:V","comparator":"c","value":"' . $search_content . '","columncondition":"'.$advft_criteria_condition.'"}'
                . $advft_criteria_inventory . ']';
            $_REQUEST['advft_criteria'] = $advft_criteria;
            $_REQUEST['advft_criteria_groups'] = '[null,{"groupcondition":""}]';
            $_REQUEST['searchtype'] = 'advSearch';
            $_REQUEST['module'] = $currentModule = 'OftenUseReport';
        }
    }
    //获取审批条件sql
    public function getApproveSql($module){
        $sys_approve= getSys_Approvedeploy($module);
        $focus = CRMEntity::getInstance($module);
        //对应模块需要开启审批参数,并启用字段
        if($sys_approve['deploy_value']==0 && isset($focus->column_fields['approvestatus'])){
            $tablename = $focus->table_name;
            $approvesql_arr = getApprove_Query($tablename);
            if(!empty($approvesql_arr['query'])){
                $approvesql = ' AND '.$approvesql_arr['query'].' ';
            }else{
                $approvesql = '';
            }
        }else{
            $approvesql = '';
        }
        return $approvesql;
    }
    public function getlabel_arr(){
        $label_arr=array(
            'VIEWRANGE',//查看范围
            'SEARCHREPORTNAME',//搜索报表名称
            'CANCEL',//取消
            'CONFIRMED',//确定
            'DISPLAYSETTINGS',//显示设置
            'NOREPORTVIEWING',//暂无报表查看权限
            'REPORTFORMMODULEDISPLAYSETTINGS',//报表模块显示设置
            'thisfq',//本季度
            'today',//今天
            'thismonth',//本月
            'lastmonth',//上月
            'nextmonth',//下月
            'thisyear1',//本年度
            'lastyear1',//上年度
            'THOUSAND',//千
            'MILLION1',//百万
            'BILLION',//十亿
            'TILLION',//万亿;
            'AMOUNT',//金额
            'QUANTITY',//数量
            'PREVYEAR',//去年
            'CURYEAR',//今年
            'JANUARY1',//1月
            'FEBRUARY1',//2月
            'MARCH1',//3月
            'APRIL1',//4月
            'MAY1',//5月
            'JUNE1',//6月
            'JULY1',//7月
            'AUGUST1',//8月
            'SEPTEMBER1',//9月
            'OCTOBER1',// 10月
            'NOVEMBER1',//11月
            'DECEMBER1',//12月
            'REIMBURSED',//我报销的
            'SALESFUNNEL',//销售漏斗
            'LEADSOURCE',//线索来源
            'LEADDISTRYBUTION',//线索分布
            'FAILUREANALYSIS',//失败分析
            'FAILUREANALYSIS1',//线索失败原因分析
            'COMPANYCITY',//城市
            'REGCUST',//注册客户数
            'CRECUSTNUM',//授信客户数
            'FINANCECUSTNUM',//融资客户数
            'lastweek',//上周
            'nextweek',//下周
            'lastyear',//上年
            'nextyear',//下年
            'Name',//姓名
            'NOSALESFUNNEL',//没有销售漏斗数据
            'NOTTOEXIST',//没有
            'data',//数据
            'ALL',//全部
            'Cost',//费用
            'COMMISSION',//佣金
            'TARGETAMOUNT',//目标金额
            'AMOUNTCOMPLETED',//完成金额
            'Frequency',//次数
            'Percents',//百分比
            'CURRENTBLOCKCANNOTVIEW',//当前区块无法查看详情
            'TOLOOKVALUE',//目标值
            'COMPLETIONVALUE',//完成值
            'COMPLETIONRATE',//完成率
            'SNOWBEARYear',//年度
            'SNOWBEARMonth',//月度
            'SNOWBEARQuarter',//季度
            'AMOUNTRETURN',//回款额
            'CONTRACTAMOUNTS',//签约额
            'THECUSTOMERNUMER',//客户数
            'Invoiceamount1',//开票额
            'outamount',//出库额
            'TOP10',//前10名
            'BOTTOM10',//后10名
            'RANKINGLOWTOHIGH',//排名从低到高
            'RANKINGHIGHTOLOW',//排名从高到低
            'CONTRACTNUMBERHONE',//签约数量
            'CONTRACTAOUNT',//签约金额
            'REBACKAMOUNT',//回款金额
            'CLICKLOADMORE',//点击加载更多
            'TOTALNEWCUSTNUM',//新建客户总数
            'DATE',//日期
            'ACCOUNTCOUNT',//新增客户数
            'nodata',//没有数据
            'INCOMPLETEVALUE', //未完成值
            'RECORDSINTOTAL',//共%d条记录
            'EXPANDINVENTORYDETAILS',//EXPANDINVENTORYDETAILS
            'STOWINVENTORYDETAILS',//收起库存详情
            'InventoryQuery',//即时库存查询
            'INVENTORYINQUIRY',//库存查询
            'SaleDragonTiger',//销售龙虎榜
            'LBL_PLEASE_SELECT',//请选择
            'ACCOUNTSMAP',//客户地图
            'HIGH',//高
            'LOW',//低
        );
        $fixedlabel_arr = TransFieldlabel($label_arr);
        $fixedlabel_arr = CombineLabelSolution('%d','RECORDSINTOTAL',$fixedlabel_arr);

        return $fixedlabel_arr;
    }
}