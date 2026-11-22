<?php

$function = $_REQUEST['function_name'];
$obj = new YichongReport();
$obj->$function();

class YichongReport
{
    public $adb;
    public $smarty;
    public function __construct()
    {
        global $adb;
        $this->smarty = new lingdangCRM_Smarty();
        $this->adb = $adb;
    }
    //交易客户数量  近12个月 （包含本月）
    public function getCustomsList(){
        $reportlabel = $_REQUEST['reportlabel'];
        $name_arr = [
            'trading_unit'=>'交易客户 近12个月',
            'trading_unit_money'=>'交易客户交易额 本期',
            'important_account_nums'=>'客户 本年',//2021-0218 改成本年
            'business_year_money'=>'客户交易额  本期',
        ];
        $title = $name_arr[$reportlabel];
        $is_ajax = $_REQUEST['is_ajax'];

        //时间 审批状态 人员范围
        $date_over12month = date("Y-m-01 00:00:00",strtotime("-11 month"));//近12个月
        $where = " where a.deleted=0 ";
        //查看人员范围
        $scopeType = 'smowner_search_senior';
        if(!empty($_REQUEST['selectuserid']))
        {
            $senioruserid = $_REQUEST['selectuserid'];
        }
        if(!empty($senioruserid)&&$senioruserid!="all"){
            $scope_obj = new ScopOfAuthority($this->adb,'Home');
            $where .= ' and a.'.$scope_obj->getHomeSmOwnerSearchSql($scopeType,$senioruserid);
        }
        //分页
        $page = $_REQUEST['page'];
        $limit = 100;
        if($reportlabel=="trading_unit"||$reportlabel=="trading_unit_money"){
            $table_th = ['交易单位_（下单客户）','交易客户交易额'];
            $count_field = "a.cf_4801";
            $key_field = "distinct $count_field as `name`,0 as accountid,";
            $groupby = "`name`";
        }else{
            $table_th = ['客户名称','客户交易额'];
            $count_field = "a.accountid";
            $key_field = "distinct $count_field as accountid,account.accountname as `name`,";
            $groupby = "accountid";
        }
        if(!empty($_REQUEST['search_date_custom_value'])){
            $search_date = $_REQUEST['search_date_custom_value'];
        }else{
            $search_date = '';
        }
        //时间条件
        if($reportlabel=="trading_unit"){
            $where .= " and a.outdate >='".$date_over12month."'";
        }else if($reportlabel=="important_account_nums"){
            $date_year_sql = $this->getYearDateScope($search_date);//获取所选择时间的当年时间范围
            $where .= " and a.outdate ".$date_year_sql;
        }else{
            $date_sql = getHomeDateScope($search_date);
            $where .= " and a.outdate ".$date_sql;
        }
        $count_sql = "select count(distinct $count_field) as nums,sum(ifnull(d.sf19302,0)) as money from ld_outboundorder a  left join ld_outboundorderdetail c on a.out_id=c.id left join ld_outboundorderdetailscf d on c.lineitem_id=d.lineitem_id $where";

        $count_res = $this->adb->pquery($count_sql);
        $total_nums = $this->adb->query_result($count_res,0,'nums');//总条数
        $total_money = $this->adb->query_result($count_res,0,'money');//总条数
        $total_pages = ceil($total_nums/$limit);
        $page = empty($page)?1:$page;

        if($total_pages<=$page&&$total_pages>=1){
            $page = $total_pages;
        }
        $page_start = ($page-1)*$limit;

        $_REQUEST['page'] = $page;
        //导出的时候不分页
        $is_limit_where = "limit $page_start,$limit";
        if($_REQUEST['is_export'] == "yes"){
            $is_limit_where = "";
        }
        $sql = "select $key_field sum(ifnull(d.sf19302,0)) as money from ld_outboundorder a left join ld_outboundordercf b on a.out_id=b.out_id left join ld_outboundorderdetail c on a.out_id=c.id left join ld_outboundorderdetailscf d on c.lineitem_id=d.lineitem_id left join ld_account as account on a.accountid=account.accountid $where group by $groupby order by money desc $is_limit_where";

        $res = $this->adb->pquery($sql);
        $nums = $this->adb->num_rows($res);
        $list = [];
        $heji = 0;
        for($i=0;$i<$nums;$i++){
            $list[$i]['no'] = $i+1;
            $name = $this->adb->query_result($res,$i,'name');
            $list[$i]['name'] = empty($name)?'无名称':$name;
            $list[$i]['money'] = $this->adb->query_result($res,$i,'money');
            $heji += $list[$i]['money'];
            $list[$i]['money'] = number_format($list[$i]['money'],2);
            $list[$i]['accountid'] = $this->adb->query_result($res,$i,'accountid');
        }
        $list[] = ['no'=>'本页小计','name'=>'本页小计','money'=>number_format($heji,2)];
        $list[] = ['no'=>'总计','name'=>'总计','money'=>number_format($total_money,2)];
        $_REQUEST['diony'] = 'yes';
        if($is_ajax == "yes"){
            ConvertTojsonString(1,['list'=>$list,'title'=>$title,'page'=>$page,'total_pages'=>$total_pages,'total_nums'=>$total_nums],'success');
        }else{
            $this->smarty->assign('request',$_REQUEST);
            $this->smarty->assign('list',$list);
            $this->smarty->assign('reportlabel',$reportlabel);
            $this->smarty->assign('title',$title);
            $this->smarty->assign('table_th',$table_th);
            $this->smarty->assign('page', $page);
            $this->smarty->assign('total_pages', $total_pages);
            $this->smarty->assign('total_nums', $total_nums);
            $this->smarty->display('yichong/trading_unit.tpl');
        }
    }

    //交易客户数量  近12个月 （包含本月）
    public function getCustomsDetail(){
        $reportlabel = $_REQUEST['reportlabel'];
        $name = $_REQUEST['name'];
        $accountid = $_REQUEST['accountid'];
        $date_over12month = date("Y-m-01 00:00:00",strtotime("-11 month"));//近12个月
        $where = " where a.deleted=0 ";
        //查看人员范围
        $scopeType = 'smowner_search_senior';
        if(!empty($_REQUEST['selectuserid']))
        {
            $senioruserid = $_REQUEST['selectuserid'];
        }
        if(!empty($senioruserid)&&$senioruserid!="all"){
            $scope_obj = new ScopOfAuthority($this->adb,'Home');
            $where .= ' and a.'.$scope_obj->getHomeSmOwnerSearchSql($scopeType,$senioruserid);
        }
        if(!empty($_REQUEST['search_date_custom_value'])){
            $search_date = $_REQUEST['search_date_custom_value'];
        }else{
            $search_date = '';
        }
        //时间条件
        if($reportlabel=="trading_unit"){
            $where .= " and a.outdate >='".$date_over12month."'";
        }else if($reportlabel=="important_account_nums"){
            $date_year_sql = $this->getYearDateScope($search_date);//获取所选择时间的当年时间范围
            $where .= " and a.outdate ".$date_year_sql;
        }else{
            $date_sql = getHomeDateScope($search_date);
            $where .= " and a.outdate ".$date_sql;
        }
        if($reportlabel=="trading_unit"||$reportlabel=="trading_unit_money"){
            //交易客户数量
            $where .= " and a.cf_4801='$name' group by a.out_no ";
        }else{
            //客户数量
            $where .= " and a.accountid=$accountid group by a.out_no";
        }

        $sql = "select a.out_id,a.out_no, sum(ifnull(d.sf19302,0)) as money from ld_outboundorder a left join ld_outboundordercf b on a.out_id=b.out_id left join ld_outboundorderdetail c on a.out_id=c.id left join ld_outboundorderdetailscf d on c.lineitem_id=d.lineitem_id left join ld_account as account on a.accountid=account.accountid $where order by money desc";
        $res = $this->adb->pquery($sql);
        $nums = $this->adb->num_rows($res);
        $list = [];
//        $heji = 0;
        for($i=0;$i<$nums;$i++){
            $list[$i]['no'] = $i+1;
            $list[$i]['out_id'] = $this->adb->query_result($res,$i,'out_id');
            $list[$i]['out_no'] = $this->adb->query_result($res,$i,'out_no');
            $list[$i]['money'] = number_format($this->adb->query_result($res,$i,'money'),2);
//            $heji += $list[$i]['money'];
        }
//        $list[] = [''=>'','out_id'=>'','out_no'=>'小计','money'=>$heji];
        $_REQUEST['diony'] = 'yes';
        ConvertTojsonString(1,['list'=>$list],'success');
    }

    public function setListSession()
    {
        include globalStatic::$root_directory."modules/Home/CustomMade/CustomMadeUtils.php";
        $reportlabel = $_REQUEST['reportlabel'];
        $date_over12month = date("Y-m-01 00:00:00",strtotime("-11 month"));//近12个月
        //时间条件
        if($reportlabel!="trading_unit"&&$reportlabel!="important_account_nums"){
            if (!empty($_REQUEST['search_date_custom_value'])) {
                $search_date = $_REQUEST['search_date_custom_value'];
            } else {
                $search_date = '';
            }
        }
        $date_arr = CustomMadeUtils::getAdvancedQueryOfDate($search_date);
        $tmparr = getApprove_Query("ld_outboundorder");
        $approve_value = $tmparr['value'];
        $modulename = 'OutboundOrder';
        //时间
        if($reportlabel=="trading_unit"||$reportlabel=="important_account_nums") {
            $advft_criterias[$reportlabel][$modulename][] = [
                'groupid' => 1,
                'columnname' => "ld_outboundorder:outdate:outdate:OutboundOrder_出库日期:D",
                'comparator' => 'h',
                'value' => $date_over12month,
                'columncondition' => ' and ',
            ];
        }else{
            $advft_criterias[$reportlabel][$modulename][] = [
                'groupid' => 1,
                'columnname' => "ld_outboundorder:outdate:outdate:OutboundOrder_出库日期:D",
                'comparator' => $date_arr['datecomparator'],
                'value' => '',
                'columncondition' => ' and ',
            ];
        }
        //客户下单客户名称
        if($_REQUEST['reportlabel']=="trading_unit"||$_REQUEST['reportlabel']=="trading_unit_money"){
            $advft_criterias[$reportlabel][$modulename][] = [
                'groupid' => 1,
                'columnname' => "ld_outboundorder:cf_4801:cf_4801:OutboundOrder_交易单位_（下单客户）:V",
                'comparator' => 'c',
                'value' => $_REQUEST['name'],
                'columncondition' => ' and ',
            ];
        }else{
            $advft_criterias[$reportlabel][$modulename][] = [
                'groupid' => 1,
                'columnname' => "ld_outboundorder:accountid:account_id:OutboundOrder_客户名称:V",
                'comparator' => 'c',
                'value' => $_REQUEST['name'],
                'columncondition' => ' and ',
            ];
        }

        if(isset($advft_criterias['advft_criteria_groups'])){
            $advft_criteria_groups = $advft_criterias['advft_criteria_groups'];
        }
        $advft_criterias = $advft_criterias[$_REQUEST['reportlabel']];
        $modules = explode(",",'OutboundOrder');
        foreach($modules as $tmp_module)
        {
            $advft_criterias[$tmp_module][sizeof($advft_criterias[$tmp_module])-1]['columncondition']='';
            $input['advft_criteria'] = json_encode($advft_criterias[$tmp_module]);
            $input['advft_criteria_groups'] = $advft_criteria_groups;
            $input['searchtype'] = 'advance';
            $_SESSION['LiveViewSearch'][$tmp_module]['input'] = $input;
            $_SESSION['lvs'][$tmp_module]['SearchScope'] = 'smowner_search_senior';
            $_SESSION['lvs'][$tmp_module]['senioruserid'] = $_REQUEST['selectuserid'];
        }
    }

    public static function getYearDateScope($search_date)
    {
        switch($search_date){
            case 'thistoday':	//今日
            case 'today'://手机daunt
                $year = date('Y')."-01-01";
                $date = date('Y-m-d');
                return " between '$year' and '$date'" ;
            case 'yestoday':	//昨日
            case 'syesterday'://手机daunt
                $year = date('Y-01-01',strtotime("-1 day"));
                $date = date('Y-m-d',strtotime("-1 day"));
                return " between '$year' and '$date'" ;
            case 'thisweek':	//本周
                $year = date('Y-01-01', (time() + (7 - (date('w') == 0 ? 7 : date('w'))) * 24 * 3600));
                $end = date('Y-m-d', (time() + (7 - (date('w') == 0 ? 7 : date('w'))) * 24 * 3600));
                return " between '$year 00:00:00' and '$end 23:59:59' " ;
            case 'lastweek':
                $date = date("Y-m-d");  //当前日期
                $first=1;     //$first =1 表示每周星期一为开始时间 0表示每周日为开始时间
                $w = date("w", strtotime($date));  //获取当前周的第几天 周日是 0 周一 到周六是 1 -6
                $d = $w ? $w - $first : 6;  //如果是周日 -6天
                $nowdate  = date("Y-m-d 00:00:00", strtotime("$date -".$d." days"));
                $nowStart  = date("Y-m-d 00:00:00", strtotime("$nowdate - 7 days")); //上周开始时间
                $year = date("Y-01-01", strtotime("$nowStart +6 days"));
                $nowEnd    = date("Y-m-d 23:59:59", strtotime("$nowStart +6 days"));  //上周结束时间
                return " between '$year 00:00:00' and '$nowEnd 23:59:59' " ;
            case 'thismonth':	//本月
            case 'month':
                $year = date('Y-01-01');
                $date = date('Y-m-d');
                return " between '$year 00:00:00' and '$date 23:59:59' " ;
            case 'lastmonth':	//上月
                $timestamp=strtotime(date('Y-m-d H:i:s'));
                $year = date('Y-01-01',strtotime(date('Y',$timestamp).'-'.(date('m',$timestamp)-1)));
                $date = date('Y-m-d',strtotime("-1 days",strtotime(date('Y-m-01'))));
                return " between '$year 00:00:00' and '$date 23:59:59' " ;
            case 'nextmonth':	//下月
                $timestamp=strtotime(date('Y-m-d H:i:s'));
                $year = date('Y-01-01',strtotime(date('Y',$timestamp).'-'.(date('m',$timestamp)+1)));
                $date = date('Y-m',strtotime(date('Y',$timestamp).'-'.(date('m',$timestamp)+2)));
                return " between '$year 00:00:00' and '$date-01 00-00-00' " ;
            case 'thisyear':	//本年度
            case 'year':
            case 'thisfy'://手机端
                $date = date('Y');
                return " like '%$date%' " ;
            case 'lastyear':	//上年度
            case 'prevfy'://手机端
                $date = date('Y',strtotime("-1 year"));
                return " like '%$date%' " ;
            case 'thisquarter':	//本季度
            case 'quarter':
            case 'thisfq'://手机daunt
                $season = ceil((date('n'))/3);
                $year = date('Y-01-01 00:00:00', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                $end = date('Y-m-d H:i:s', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                return " between '$year' and '$end' " ;
            case 'lastquarter':	//上季度
            case 'prevfq'://手机端
                $season = ceil((date('n'))/3)-1;
                $year = date('Y-01-01 00:00:00', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                $end = date('Y-m-d H:i:s', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                return " between '$year' and '$end' " ;
            case 'all':
                return '';
            default:
                $date = explode('~',$search_date);
                $end_date = explode('-',$date[1]);
                $year = $end_date[0]."-01-01";
                if(sizeof($date) > 1){
                    return " between '$year 00:00:00' and '$date[1] 23:59:59' " ;
                }else{
                    $date = date('Y-m');
                    return " between '$year 00:00:00' and '$date 23:59:59'" ;
                }
        }
    }
}