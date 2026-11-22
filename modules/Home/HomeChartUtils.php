<?php
require_once globalStatic::$root_directory.'modules/Home/HomeParentUtils.php';
//zxm 20230731 首页默认组件统计图类
//重要的参数 $scopeType $senioruserid $search_date $stuffid $boardid $boardstuffid  $approve_value
class HomeChartUtils extends HomeParentUtils{
    public $chartOptionObj;
    public  $getSQLType;

    //键：后台穿透用的参数名   值：穿透点击params的键名
    public $chuantouParamsName = [
        "XAxisName"=>"name",
        "SeriesName"=>"seriesName",
        "dataIndex"=>"dataIndex",
        "SeriesIndex"=>"seriesIndex",
        "name"=>"name"
    ];//统计图穿透点击 需要从params中获取的参数的参数名称  现在基本是这几个 后续如果需要新的参数从这里加（移动端穿透参数用的这个，PC后面也可以改成用这个）

    static public function getInstance(){

    }
    public function __construct($boardid)
    {
        parent::__construct($boardid);

        include_once globalStatic::$root_directory.'modules/Home/HomeChartOption.php';
        $this->chartOptionObj = new HomeChartOption();
    }
    public function setOptionPlateSetting(){
        $platesetting =  $this->getPlateSetting($this->stuffid);
        $tmpstuffinfo = self::$defaultstuffArr[$this->stuffid];
        if(!isset($platesetting['datalabel'])){
            //默认是不显示数据标签
            $platesetting['datalabel'] = 'none';
            if($tmpstuffinfo['charttype']=='funnel'){
                //漏斗图的默认值是显示 显示在内部
                $platesetting['datalabel'] = 'inside';
            }
            // 如果是饼图就默认外部显示
            if($tmpstuffinfo['charttype']=='pie'){
                //漏斗图的默认值是显示 显示在内部
                $platesetting['datalabel'] = 'outside';
            }
        }
        $this->chartOptionObj->setPlateSetting($platesetting);
    }
    //1 //公司最近6个月销售情况
    public function getSALESSIXMONTH($datarangemodule){
        $entries = $this->getSalesLastestSix($datarangemodule,'company');
        return $entries;
    }
    //9 //最近6个月个人销售情况
    public function getINDIVIDUALSIXMONTH($datarangemodule){
        $entries = $this->getSalesLastestSix($datarangemodule,'person');
        return $entries;
    }

    //最近6个月销售情况  最近6个月个人销售情况的sql生成和数据---最近6个月的统计都可以用这个扩展
    public function getSalesLastestSix($datarangemodule,$type){
        global $adb,$current_user,$MobileLanguageType,$languageType;
        $system_deploy_351 = $this->system_deploy_351;//单据分录明细金额字段和单据头货币字段小数位数
        $datarangesqlArr = $this->datarangesqlArr;
        $date = $this->daterangsql;//时间条件 between A and B

        $datarangemodule_arr = explode(',',$datarangemodule);
        $tmpsql_arr = [];
        foreach($datarangemodule_arr as $tmpmodulename){
            //判断模块是否激活开启
            if(!vtlib_isModuleActive($tmpmodulename)){
                continue;
            }
            $tmpfocus = CRMEntity::getInstance($tmpmodulename);
            $maintablename = $tmpfocus->table_name;//主表
            $mainindex = $tmpfocus->table_index;//主表主键
            $scftablename = $tmpfocus->customFieldTable[0];//自定义表
            $tmptimefield = $this->filterArr['timecomponent_'.$tmpmodulename]['filtersfield'];//看板右侧选择的时间字段
            $tmpdate_arr = explode('.',$tmptimefield);

            $tmpquery =" select count(1) as ordercount,sum(if(currency_id >1,IFNULL($maintablename.total,0)/conversion_rate,IFNULL($maintablename.total,0))) as ordertotal, DATE_FORMAT(".$tmptimefield.",'%Y-%m') as ordertime from $maintablename ";
            //如果时间字段是自定义表 需要连自定义表
            if($tmpdate_arr[0]==$scftablename){
                $tmpquery .= " left join $scftablename on $maintablename.$mainindex=$scftablename.$mainindex";
            }
            $tmpquery .= $datarangesqlArr['datarangesql_'.$tmpmodulename];

            if($type=='person')
            {
                $tmpquery.="  where  $maintablename.smownerid=".$current_user->id;
            }
            $tmpquery .=" group by DATE_FORMAT(".$tmptimefield.",'%Y-%m')";
            $tmpsql_arr[] = $tmpquery;
        }
        //两个模块都未激活 返回空数组
        if(sizeof($tmpsql_arr)==0){
            return array();
        }
        $sql = implode(' union all ',$tmpsql_arr);

        $seqsql = "SELECT
		DATE_FORMAT(date,'%Y-%m') AS target_period
	FROM tmp_date a
	WHERE date $date
	GROUP BY DATE_FORMAT(date,'%Y-%m')";
        $sql=' select tmpmonth.target_period as ordertime,sum(ifnull(ordertotal,0)) AS ordertotal,sum(ifnull(ordercount,0)) AS ordercount from ('.$seqsql.')tmpmonth left join ('.$sql.') as temp on tmpmonth.target_period=temp.ordertime group by tmpmonth.target_period  order by tmpmonth.target_period';

        $result=$adb->query($sql);
        $num_row=$adb->num_rows($result);
        $open_company_list=array();
        if($num_row>0){
            for($i=0;$i<$num_row;$i++){
                $open_company_list['count'][$i] = $adb->query_result($result,$i,'ordercount');
                $open_company_list['amount'][$i] = round($adb->query_result($result,$i,'ordertotal'),$system_deploy_351);
                $target_period = $adb->query_result($result,$i,'ordertime');
                $target_period_arr = explode('-',$target_period);
                $month = (int)$target_period_arr[1];
                if($languageType == 'en' || $MobileLanguageType == 'en'){
                    $date= DateOperation::getCaldate((int)$month);
                }else{
                    $date= $month.'月';
                }
                $open_company_list['title'][$i] = $date;
            }
        }
        $this->setOptionPlateSetting();
        $open_company_list['option'] = $this->chartOptionObj->getSalesLastestSixOption($open_company_list);
        $open_company_list['can_penetrate'] = $this->setCanPenetrate();
        return $open_company_list;
    }

    //4 签约额月度同比
    public function getAMOUNTMONTHCONTRACTYEAR($datarangemodule){
        $entires=$this->getCompanyNowLastAllMonth($datarangemodule);
        return $entires;
    }
    //5 收款额月度同比
    public function getBACKAMOUNTMONTHYEAR($datarangemodule){
        $entires=$this->getCompanyNowLastAllMonth($datarangemodule);
        return $entires;
    }
    //41 开票额月度同比
    public function getINVOICEAMOUNTYEAR($datarangemodule){
        $entires=$this->getCompanyNowLastAllMonth($datarangemodule);
        return $entires;
    }
    //42 出库额月度同比
    public function getOUTBOUNDORDERAMOUNTYEAR($datarangemodule){
        $entires=$this->getCompanyNowLastAllMonth($datarangemodule);
        return $entires;
    }
    //同比SQL生成  同比都可以用这个扩展 根据数据取值模块 自动生成同比数据
    public function getCompanyNowLastAllMonth($datarangemodule)
    {
        global $adb,$languageType;
        $mobilePenetrateModule = [];
        $system_deploy_351 = $this->system_deploy_351;//单据分录明细金额字段和单据头货币字段小数位数
        $datarangesqlArr = $this->datarangesqlArr;
        $date = $this->daterangsql;//时间条件 between A and B
        $datarangemodule_arr = explode(',',$datarangemodule);
        $tmpsql_arr = [];
        foreach($datarangemodule_arr as $k=>$tmpmodulename){
            //判断模块是否激活开启
            if(!vtlib_isModuleActive($tmpmodulename)){
                unset($datarangemodule_arr[$k]);
                continue;
            }

            $tmpfocus = CRMEntity::getInstance($tmpmodulename);
            $maintablename = $tmpfocus->table_name;//主表
            $mainindex = $tmpfocus->table_index;//主表主键
            $scftablename = $tmpfocus->customFieldTable[0];//自定义表
            $tmptimefield = $this->filterArr['timecomponent_'.$tmpmodulename]['filtersfield'];//看板右侧选择的时间字段
            $tmpdate_arr = explode('.',$tmptimefield);

            $tmpquery =" SELECT sum(IF (
                			$maintablename.currency_id > 1,
                			IFNULL($maintablename.total, 0) / $maintablename.conversion_rate,
                			IFNULL($maintablename.total, 0)
                		)) AS ordertotal,
                		DATE_FORMAT(".$tmptimefield.",'%Y-%m') AS ordertime
                FROM $maintablename ";
            //如果时间字段是自定义表 需要连自定义表
            if($tmpdate_arr[0]==$scftablename){
                $tmpquery .= " left join $scftablename on $maintablename.$mainindex=$scftablename.$mainindex";
            }
            $tmpquery .= $datarangesqlArr['datarangesql_'.$tmpmodulename];

            $tmpquery .=" group by DATE_FORMAT(".$tmptimefield.",'%Y-%m')";
            $tmpsql_arr[] = $tmpquery;
        }
        //模块都未激活 返回空数组
        if(sizeof($tmpsql_arr)==0){
            return array();
        }
        $sql = implode(' union all ',$tmpsql_arr);
        $seqsql = "SELECT
		DATE_FORMAT(date,'%Y-%m') AS target_period,DATE_FORMAT(date, '%Y') AS target_period_y,DATE_FORMAT(date, '%c') AS target_period_m
	FROM tmp_date a
	WHERE date $date
	GROUP BY DATE_FORMAT(date,'%Y-%m')";
        $sql=' select tmpmonth.target_period as ordertime,tmpmonth.target_period_y,tmpmonth.target_period_m,sum(ifnull(ordertotal,0)) AS ordertotal from ('.$seqsql.')tmpmonth left join ('.$sql.') as temp on tmpmonth.target_period=temp.ordertime group by tmpmonth.target_period  order by tmpmonth.target_period';
        $result=$adb->query($sql);
        $num_row=$adb->num_rows($result);

        $list = array();
        $curYearName = date('Y');//今年
        $lastYearName = $curYearName-1;//去年
        if($num_row>0) {
            for ($i = 0; $i < $num_row; $i++) {
                $target_period_y = $adb->query_result($result,$i,'target_period_y');//年份

                if($target_period_y==$curYearName){
                    $list['year'][] = round($adb->query_result($result,$i,'ordertotal'),$system_deploy_351);
                    $target_period_m = $adb->query_result($result,$i,'target_period_m');//月份
                    $target_period_m = (int)$target_period_m;
                    if($languageType == 'en'){
                        $target_period_m= DateOperation::getCaldate($target_period_m);
                    }else{
                        $target_period_m= $target_period_m.'月';
                    }
                    $list['title'][] = $target_period_m;
                }
                if($target_period_y==$lastYearName){
                    $list['lastyear'][] = round($adb->query_result($result,$i,'ordertotal'),$system_deploy_351);
                }
            }
        }

        $this->setOptionPlateSetting();
        $mobilePenetrateModule[0] = implode(',',$datarangemodule_arr);//移动端穿透模块--两个系列的穿透模块一样
        $mobilePenetrateModule[1] = implode(',',$datarangemodule_arr);//移动端穿透模块--两个系列的穿透模块一样
        $list['mobilePenetrateModule'] = $mobilePenetrateModule;//移动端需要的参数 用来控制穿透到哪个模块以及判断能不能穿透
        $list['option'] = $this->chartOptionObj->getCompanyNowLastAllMonthOption($list);
        $list['can_penetrate'] = $this->setCanPenetrate();
        $list['chuantouParamsName'] = $this->chuantouParamsName;
        return $list;
    }
    //19 销售漏斗
    public function getSALESFUNNEL($datarangemodule){
        global $adb;
        $datarangesqlArr = $this->datarangesqlArr;
        $system_deploy_351 = $this->system_deploy_351;//单据分录明细金额字段和单据头货币字段小数位数
        //销售机会未激活  不显示
        if(!vtlib_isModuleActive($datarangemodule)){
            return array();
        }
        $query = "select 
ifnull(b.potentialcount,0)as potentialcount,
a.listvalue as sales_stage,
ifnull(b.amount,0)as amount,
a.sales_stage_id
from 
( 
	SELECT
		id sales_stage_id,
		listvalue,
		sequence
	FROM
		ld_picklist_values
	LEFT JOIN ld_picklist_set ON ld_picklist_set.listid = ld_picklist_values.listid
	WHERE
		listname = 'sales_stage'
	AND relatetable = 'ld_field'
)a 
LEFT JOIN (
	SELECT
		count(1) AS potentialcount,
		sales_stage,
		sum(amount) AS amount
	FROM
		ld_potential ".$datarangesqlArr['datarangesql_Potentials']."
	GROUP BY
		ld_potential.sales_stage
) AS b ON a.listvalue = b.sales_stage
ORDER BY
	a.sequence asc";//zxm 20230906 SQL优化  原来的方式雅士空调数据量太多会直接卡住

        $result=$adb->query($query);
        $num_rows=$adb->num_rows($result);
        $open_potential_list = array();
        $totalcount = 0;
        $totalamount = 0;
        if($num_rows>0) {
            for ($i = 0; $i < $num_rows; $i++) {
                $sales_stage = $adb->query_result($result,$i,'sales_stage');
                $open_potential_list['clickvalue'][] = $adb->query_result($result,$i,'sales_stage_id');
                $potentialcount = $adb->query_result($result,$i,'potentialcount');
                $amount = $adb->query_result($result,$i,'amount');
                $open_potential_list['count'][] = $potentialcount;

                $open_potential_list['amount'][] = round($amount,$system_deploy_351);
                $open_potential_list['title'][] = $sales_stage;

                $totalcount += $potentialcount;
                $totalamount += $amount;
            }
        }
        //求每个阶段的百分比
        foreach($open_potential_list['count'] as $k=>$tmpcount){
            $percentage = $totalcount<=0?'0':round(($tmpcount/$totalcount)*100,2) ;
            $open_potential_list['percentage'][] = $percentage.'%';
            //funnel_data移动端要用的数组  表格形式显示数据
            $open_potential_list['funnel_data'][] = array(
                'percent'=>$percentage,
                'amount'=>setNumberFormat($open_potential_list['amount'][$k],$system_deploy_351),
                'name'=>$open_potential_list['title'][$k],
                'number'=>$open_potential_list['count'][$k],
            );
        }
        //获取option
        $this->setOptionPlateSetting();
        $open_potential_list['totalcount'] =  $totalcount;//总数量
        $open_potential_list['totalamount'] =  setNumberFormat($totalamount,$system_deploy_351);//总金额
        $open_potential_list['option'] = $this->chartOptionObj->getSALESFUNNELOption($open_potential_list);
        $open_potential_list['can_penetrate'] = $this->setCanPenetrate();
        return $open_potential_list;
    }
    //44 商机统计图_按销售负责人和销售阶段统 StatisticsPotentialsBySalesPersonAndSalesStages
    public  function getStatisticsPotentialsBySalesPersonAndSalesStage($datarangemodule){
        $groupBy = "u.last_name";
        return $this->getPotentialsByStatistics($datarangemodule,$groupBy);
    }
    //45 商机统计图_按所属行业和销售阶段统计   StatisticalPotentialsByTheAccountIndustryAndSalesStage
    public  function getStatisticalPotentialsByTheAccountIndustryAndSalesStage($datarangemodule){
        $groupBy = "a.industry";
        return $this->getPotentialsByStatistics($datarangemodule,$groupBy);
    }

    public function getPotentialsByStatistics($datarangemodule,$groupBy="u.last_name")
    {
        global $adb,$languageType;
        $system_deploy_351 = $this->system_deploy_351;//单据分录明细金额字段和单据头货币字段小数位数
        $datarangesqlArr = $this->datarangesqlArr;
        //销售机会未激活  不显示
        if(!vtlib_isModuleActive($datarangemodule)){
            return array();
        }
        crm_load_class_file("cls_PickList", 'modules/PickList');
        $obj_pink_list = new cls_PickList();
        // 商机阶段数组
        $xkeyArr = $obj_pink_list->getPickListValues('sales_stage','',array(),'id');

        $xkeyArr = array_reverse($xkeyArr);
        //首页--商机统计图_按所属行业和销售阶段统计，第一个数值（查看范围：全部、成员：全部），第一个全部商机有12、但是加起来并没有12  BUG20240722-56  原因是数据库值有的是null有的是空
        $groupbyalias = "";
        if($groupBy == "u.last_name"){
            $xkey = "last_name";
            $leftJoin = " left join ld_users u on u.id=ld_potential.smownerid ";
            if(isKehu001ServerPc()=='yes'){
                $xkey = "real_name";
                $groupBy = "u.real_name";
            }
            $groupbyalias = ",ifnull($groupBy,'') ";
            $groupBy = " ifnull($groupBy,'')as last_name";
        }
        if($groupBy == "a.industry"){
            $xkey = "industry";
            $leftJoin = " LEFT JOIN ld_account a on a.accountid=ld_potential.accountid ";
            $groupbyalias = ",ifnull($groupBy,'') ";
            $groupBy = " ifnull($groupBy,'')as industry";

        }

        $sql = "select 0 as init,count(1) as nums,sales_stage,$groupBy from ld_potential   $leftJoin ".$datarangesqlArr['datarangesql_Potentials']." where ld_potential.accountid is not null group by ld_potential.sales_stage $groupbyalias";
        $result = $adb->pquery($sql);
        $nums = $adb->num_rows($result);
        $list = [];
        for($i=0;$i<$nums;$i++){
            $list[$i]['nums'] = $adb->query_result($result,$i,'nums');
            $list[$i]['sales_stage'] = $adb->query_result($result,$i,'sales_stage');
            $list[$i][$xkey] = $adb->query_result($result,$i,$xkey);
            $list[$i][$xkey] = empty($list[$i][$xkey])?"无":$list[$i][$xkey];
            $list[$i]['init'] = $adb->query_result($result,$i,'init');
        }

        $res = [];
        $names=array();
        foreach($list as $tmpindex=>$tmpinfo)
        {
            //edit:can 2020-10-28 php5.4
            $names[$tmpinfo[$xkey]]=$tmpinfo['init'];

        }
        foreach($xkeyArr as $v){
            $res[$v] = ["name"=>$v,"type"=>"bar","barMaxWidth"=>18,"data"=>$names];
        }
        $res['全部商机'] = ["name"=>'全部商机',"type"=>"line","data"=>$names];
        foreach($list as $k=>$v){
            if(isset($res[$v['sales_stage']])){
                $res[$v['sales_stage']]['data'][$v[$xkey]] = 0;
            }
            if($k == 0){
                $res["全部商机"]['data'][$v[$xkey]] = 0;
            }
            if(isset($res[$v['sales_stage']])&&$v['sales_stage']==$res[$v['sales_stage']]['name']&&$v['nums']>0){
                $res[$v['sales_stage']]['data'][$v[$xkey]] = (int)$v['nums'];
                $res["全部商机"]['data'][$v[$xkey]] += (int)$v['nums'];
            }
        }
        foreach($res as $kk=>&$vv){
            $vv['data']=array_values($vv['data']);
            if($kk!="全部商机"){
                $vv['stack'] = '商机';
            }
        }
        $open_potential_list =  ['data'=>array_values($res),'title'=>array_keys($names)];
        //获取option
        $this->setOptionPlateSetting();
        $open_potential_list['option'] = $this->chartOptionObj->getPotentialsByStatisticsOption($open_potential_list);
        $open_potential_list['can_penetrate'] = $this->setCanPenetrate();
        $open_potential_list['chuantouParamsName'] = $this->chuantouParamsName;
        return $open_potential_list;
    }
    //zxm  2021-0311 跟进频次排行榜
    public function getContactTimesRanking($platesetting)
    {
        global $adb;
        $mobilePenetrateModule = [];
        $datarangesqlArr = $this->datarangesqlArr;
        $can_penetrate = $platesetting['can_penetrate'];
        $datarangesql_sigin = $datarangesqlArr['datarangesql_Singin'];
        $datarangesql_sigin = str_replace('smownerid','userid',$datarangesql_sigin);

        // BUG0068205 txy 06.15 跟进频次排行榜板块的单词之间缺少空格
        $list1 = ['name'=>getTranstab('ContactRecords').' '.getFixedLabel('QUANTITY'),'type'=>'bar','barMaxWidth'=>'18','data'=>[]];
        $list2 = ['name'=>getTranstab('Singin').' '.getFixedLabel('QUANTITY'),'type'=>'bar','barMaxWidth'=>'18','data'=>[]];
        $sql_record = " left join (select count(ld_contactrecords.contactrecordID) as nums1,smownerid from ld_contactrecords ".$datarangesqlArr['datarangesql_ContactRecords']." group by smownerid ) a on a.smownerid=u.id ";
        $sql_singin = " left join (select count(ld_singin.id) as nums2,userid from ld_singin $datarangesql_sigin  group by userid ) b on u.id=b.userid";
        $sql = " select last_name,real_name,nums1,nums2 from ld_users u $sql_record $sql_singin where (nums1>0 or nums2>0) order by nums1 desc,nums2 desc";
        $res = $adb->pquery($sql);
        $nums = $adb->num_rows($res);
        $xdatas = [];
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $list1['data'][$i] = $adb->query_result($res, $i, 'nums1');
                $list1['data'][$i] = empty($list1['data'][$i]) ? 0 : $list1['data'][$i];
                $list2['data'][$i] = $adb->query_result($res,$i,'nums2');
                $list2['data'][$i] = empty($list2['data'][$i])?0:$list2['data'][$i];
                if(isKehu001ServerPc()=="yes"){
                    //zxm 2022-0126 客户001取用真实姓名字段值
                    $xdatas[$i] = $adb->query_result($res,$i,'real_name');
                }else{
                    $xdatas[$i] = $adb->query_result($res,$i,'last_name');
                }
            }
        }

        if(vtlib_isModuleActive('ContactRecords')) {
            $data[] = $list1;
            $mobilePenetrateModule[] = 'ContactRecords';
        }
        if(vtlib_isModuleActive('Singin')) {
            $data[] = $list2;
            $mobilePenetrateModule[] = 'Singin';
        }
        $open_potential_list =  ['data'=>$data,'title'=>$xdatas,'can_penetrate'=>$can_penetrate];
        //获取option
        $this->setOptionPlateSetting();
        $open_potential_list['mobilePenetrateModule'] = $mobilePenetrateModule;//一个或者两个系列  穿透模块顺序
        $open_potential_list['option'] = $this->chartOptionObj->getPotentialsByStatisticsOption($open_potential_list);
        $open_potential_list['can_penetrate'] = $this->setCanPenetrate();
        $open_potential_list['chuantouParamsName'] = $this->chuantouParamsName;
        return $open_potential_list;
    }
    //102-107 XUQIU1001860 PC端首页看板定制中，左侧预设组件增加报表组件 签约数量龙虎榜102、签约金额龙虎榜103、收款金额龙虎榜104、费用佣金统计表105、客户来源分布统计106、客户类型分布统计107（为之后移动端工作台按看板显示的需求做准备）
    public function getStuffDetailData_sql105($stuffid){
        $datarangesqlArr = $this->datarangesqlArr;
        switch ($stuffid){
            case 105:
                $query_expense = "
                SELECT ld_expense.smownerid,sum(ifnull(ld_expense.total,0)/ifnull(ld_expense.conversion_rate,1.00)) total FROM ld_expense " . $datarangesqlArr['datarangesql_Expense'] . " where ld_expense.deleted=0   GROUP BY ld_expense.smownerid 
                ";
                $query_commission = "SELECT ld_commission.smownerid,sum(ifnull(ld_commission.total,0)/ifnull(ld_commission.conversion_rate,1.00)) total FROM ld_commission 
                  " . $datarangesqlArr['datarangesql_Commission'] . " WHERE ld_commission.deleted=0 GROUP BY ld_commission.smownerid ";
                $query = "
                SELECT 
            ld_users.id AS userid, 
            ld_users.real_name,
            ld_users.last_name, 
            a.total as total, 
            b.total as total1
        FROM ld_users
        left join ($query_expense)a on a.smownerid=ld_users.id
        left join ($query_commission)b on b.smownerid=ld_users.id
        where a.total>0 or b.total>0
                ";
                break;
            case 106 :
                $query = " select ld_accountscf.leadsource as groupname,count(1) as total  from ld_account left join ld_accountscf on ld_account.accountid=ld_accountscf.accountid" . $datarangesqlArr['datarangesql_Accounts']." where ld_account.deleted=0 and ifnull(ld_accountscf.leadsource,'')<>''  group by ld_accountscf.leadsource" ;

                break;
            case 107 :
                $query = " select account_type as groupname,count(1) as total  from ld_account " . $datarangesqlArr['datarangesql_Accounts']."  where deleted=0 and ifnull(account_type,'')<>'' group by  account_type";
                break;

        }
        return $query;

    }

    public function getStuffDetailData105($datarangemodule)
    {
        global $adb;
        $stuffid = $this->stuffid;
        $system_deploy_351 = $this->system_deploy_351;//单据分录明细金额字段和单据头货币字段小数位数
        $query=$this->getStuffDetailData_sql105($stuffid);//获取SQL

        //35980: 首页组件-销售排行榜-回款金额排行统计不对
        $res = $adb->query($query);
        $num_rows = $adb->num_rows($res);
        $xdatas = [];
        $name = "";
        $type = "bar";
        if($stuffid==106||$stuffid==107){
            //客户数
            $name = getTranstab('THECUSTOMERNUMER');
        }
        $list = ['name'=>$name,'type'=>$type,'barMaxWidth'=>'18','data'=>[]];
        if($stuffid==105){
            $list = ['name'=>getFixedLabel('Cost'),'type'=>$type,'barMaxWidth'=>'18','data'=>[]];
            $list1 = ['name'=>getFixedLabel('COMMISSION'),'type'=>$type,'barMaxWidth'=>'18','data'=>[]];
        }
        if($num_rows>0){
            for($i=0;$i<$num_rows;$i++){
                $list['data'][$i] = $adb->query_result($res, $i, 'total');
                $list['data'][$i] = empty($list['data'][$i]) ? 0 : round($list['data'][$i],$system_deploy_351);
                if($stuffid==105){
                    $list1['data'][$i] = $adb->query_result($res, $i, 'total1');
                    $list1['data'][$i] = empty($list1['data'][$i]) ? 0 : round($list1['data'][$i],$system_deploy_351);
                }
                if($stuffid==106||$stuffid==107){
                    $xdatas[$i] = $adb->query_result($res,$i,'groupname');
                }else{
                    if(isKehu001ServerPc()=="yes"){
                        //zxm 2022-0126 客户001取用真实姓名字段值
                        $xdatas[$i] = $adb->query_result($res,$i,'real_name');
                    }else{
                        $xdatas[$i] = $adb->query_result($res,$i,'last_name');
                    }
                }
            }
        }
        $data = [$list];
        if($stuffid==105){
            $data[] = $list1;
        }

        $open_potential_list =  ['data'=>$data,'title'=>$xdatas];
        //获取option
        $open_potential_list['mobilePenetrateModule'][0] = $datarangemodule;
        $this->setOptionPlateSetting();
        $open_potential_list['option'] = $this->chartOptionObj->getPotentialsByStatisticsOption($open_potential_list);
        $open_potential_list['can_penetrate'] = $this->setCanPenetrate();
        $open_potential_list['chuantouParamsName'] = $this->chuantouParamsName;
        return $open_potential_list;
    }
    public function getStuffDetailData106($datarangemodule){
        return $this->getStuffDetailData105($datarangemodule);
    }
    public function getStuffDetailData107($datarangemodule){
        return $this->getStuffDetailData105($datarangemodule);
    }

    public function getCustomerIndustryStatistic($datarangemodule){
        global $adb;
        $datarangesqlArr = $this->datarangesqlArr;
        // 统计客户每个行业的数量
        $query = " select ifnull(industry,'') as groupname,count(1) as total  from ld_account " . $datarangesqlArr['datarangesql_Accounts']."  where deleted=0 group by  industry";
        $res = $adb->query($query);
        $num_rows = $adb->num_rows($res);
        // 查询所有数据

        $name = getTranstab('THECUSTOMERNUMER');

        
        $list = ['name'=>$name,'type'=>'pie','data'=>[]];

        if($num_rows>0){
            for($i=0;$i<$num_rows;$i++){
                // 获取该行业总数
                $data_count = $adb->query_result($res, $i, 'total');
                // 获取该行业名称
                $data_name = $adb->query_result($res,$i,'groupname');
                $list['data'][$i]['value'] = $data_count;
                $list['data'][$i]['name'] = empty($data_name)? '无': $data_name;
            }
        }
        $data = [$list];
        $open_potential_list =  ['data'=>$data];
        $open_potential_list['mobilePenetrateModule'][0] = $datarangemodule;
        $this->setOptionPlateSetting();
        $open_potential_list['option'] = $this->chartOptionObj->getPieChartOption($open_potential_list);
        $open_potential_list['can_penetrate'] = $this->setCanPenetrate();
        $open_potential_list['chuantouParamsName'] = $this->chuantouParamsName;
        return $open_potential_list;
    }
    //zxm 20231027 SalesPhaseTransformationAnalysis 销售阶段转化分析
    public function getSalesPhaseTransformationAnalysis(){
        global $adb;
        //获取下拉框值
        require_once( globalStatic::$root_directory.'modules/PickList/PickListUtils.php');
        $picklistvalues = getAllPickListValues('sales_stage');
        $picklistvalues = array_values($picklistvalues);
        $firststage = $picklistvalues[0];

        $successstage = "成功结案";
        $failstage = "失败结案";
        $yingdanlabel = getFixedLabel('Win');
        $totalcolumn = "total*rate";
        $ratecalculationmethod = "byopportunitycount";//转化率计算方法 默认按商机数量
        $system_deploy_351 = $this->system_deploy_351;//单据分录明细金额字段和单据头货币字段小数位数
        $divisor = 1;//除数
        $unit = '';//单位
        $versionInfo = getVersionTradeInfo();
        $accountinfo = $versionInfo['account'];
        //天地的特殊 不保留小数
        if($accountinfo=='tiandi'){
            $system_deploy_351 = 0;
            $divisor = 10000;//除数 天地以万元为单位
            $unit = '万';//单位
        }
        $datarangesql = $this->datarangesqlArr['datarangesql_Potentials'];

        //查询设置 ld_homeboard_plate_setting
        $selectsql = "select * from ld_homeboard_plate_setting where boardid=? and stuffid=?";
        $selectres = $adb->pquery($selectsql,array($this->boardid,$this->stuffid));
        $selectnums = $adb->num_rows($selectres);
        if($selectnums>0) {
            for ($i = 0; $i < $selectnums; $i++) {
                $tmptype = $adb->query_result($selectres, $i, 'type');
                $tmpsetvalue = $adb->query_result($selectres, $i, 'setvalue');
                if ($tmptype == 'successlistvalue') {
                    $tmpsetvalue = explode('########', $tmpsetvalue);
                    $successstage = implode(",", $tmpsetvalue);
                }
                if ($tmptype == 'faillistvalue') {
                    $tmpsetvalue = explode('########', $tmpsetvalue);
                    $failstage = implode(",", $tmpsetvalue);
                }
                if ($tmptype == 'totalcolumn') {
                    $totalcolumn = $tmpsetvalue;
                }
                if ($tmptype == 'ratecalculationmethod') {
                    $ratecalculationmethod = $tmpsetvalue;
                }
            }
        }
        //edit: xll 2024/02/02 BUG20240115-11 实际可能性字段为空字符串
        $possibility = " ( CASE WHEN ifnull( ld_potentialscf.possibility, 100 ) = '' THEN 100 ELSE ld_potentialscf.possibility END )";
        $totalcolumnsql = "sum(ifnull(ld_potential.total,0)* $possibility *0.01/ifnull(ld_potential.conversion_rate,1))";
        if($totalcolumn=='total'){
            $totalcolumnsql = 'sum(ifnull(ld_potential.total,0)/ifnull(ld_potential.conversion_rate,1))';
        }
        //转化率计算--默认按商机数量
        $successratesql = "(case when a.sales_stage='$yingdanlabel' then (case when  a.sales_stage='$yingdanlabel' then a.curnum else 0 end) else ifnull(@throughnum,0)end )/(ifnull(a.allnums,0)) as throughrate,";
        $failratesql = "(case when (ifnull(a.curnum,0)+ifnull(failnum,0)+ifnull(@throughnum,0))=0 then 0 else (ifnull(a.failnum,0))/(ifnull(a.curnum,0)+ifnull(failnum,0)+ifnull(@throughnum,0)) end) as failrate,";
        //如果是按商机数量 需改公式sql
        if($ratecalculationmethod=='byopportunityamount'){
            $successratesql = "(case when a.sales_stage='$yingdanlabel' then (case when  a.sales_stage='$yingdanlabel' then a.curamount else 0 end) else ifnull(@throughamount,0)end )/(ifnull(a.allamount,0)) as throughrate,";
            $failratesql = "(case when (ifnull(a.curamount,0)+ifnull(failamount,0)+ifnull(@throughamount,0))=0 then 0 else (ifnull(a.failamount,0))/(ifnull(a.curamount,0)+ifnull(failamount,0)+ifnull(@throughamount,0)) end) as failrate,";
        }

        $sql = "select a.sales_stage,a.sequence,(case when  a.sales_stage='$yingdanlabel' then 0 else a.curnum end) as curnum,
       (case when  a.sales_stage='$yingdanlabel' then 0 else a.curamount end)as curamount,
       a.failnum,a.failamount,
       (case when  a.sales_stage='$yingdanlabel' then a.curnum else 0 end)as successnum,
      (case when a.sales_stage='$yingdanlabel' then a.curamount else 0 end)as successamount,
      (case when a.sales_stage='$yingdanlabel' then a.curamount/ifnull(a.curnum,1) else 0 end)as avgamount,
      a.allnums,a.allamount,
(case when a.sequence=1 then @throughnum:=ifnull(a.throughnum,0) else @throughnum:=@throughnum-ifnull(a.curnum,0)-ifnull(a.failnum,0) end ) as throughnum,
(case when a.sequence=1 then @throughamount:=ifnull(a.throughamount,0) else @throughamount:=@throughamount-ifnull(a.curamount,0)-ifnull(a.failamount,0) end ) as throughamount,
	ifnull(a.curnum,0)+ifnull(failnum,0)+ifnull(@throughnum,0) as allcurnum,
ifnull(a.curamount,0)+ifnull(failamount,0)+ifnull(@throughamount,0) as allcuramount,
$successratesql
$failratesql
shichang
from (
		select 
		allstage.sales_stage,
		allstage.allnums,
		allstage.allamount,
		allstage.sequence,
		ifnull(curstage.totalnum,0) as curnum,
		ifnull(curstage.totalamount,0) as curamount,
		ifnull(failstage.totalnum,0) as failnum,
		ifnull(failstage.totalamount,0) as failamount,
		(ifnull(allstage.allnums,0)-ifnull(curstage.totalnum,0)-ifnull(failstage.totalnum,0)) as throughnum,
		(ifnull(allstage.allamount,0)-ifnull(curstage.totalamount,0)-ifnull(failstage.totalamount,0)) as throughamount,
		avgtime.shichang
		
		from
		(
			select 
			(case when find_in_set(ld_picklist_values.listvalue,'$successstage')then '$yingdanlabel' else ld_picklist_values.listvalue end) as sales_stage,ld_picklist_values.sequence,
			(select 
				count(1)as totalnum
				from ld_potential
				$datarangesql
            )as allnums,
		    (select 
			$totalcolumnsql as totalamount
			from ld_potential left join ld_potentialscf on ld_potential.potentialid=ld_potentialscf.potentialid
			$datarangesql
			)as allamount
			from ld_picklist_set left join ld_picklist_values on ld_picklist_set.listid=ld_picklist_values.listid
			where ld_picklist_set.listname='sales_stage' and not find_in_set(ld_picklist_values.listvalue ,'$failstage')
			group by (case when find_in_set(ld_picklist_values.listvalue,'$successstage')then '$yingdanlabel' else ld_picklist_values.listvalue end)
			order by ld_picklist_values.sequence asc 
		)allstage 
		left join (
			select  
			count(1)as totalnum,
			$totalcolumnsql as totalamount,
			(case when find_in_set(sales_stage,'$successstage')then '$yingdanlabel' else sales_stage end)as sales_stage
			from ld_potential left join ld_potentialscf on ld_potential.potentialid=ld_potentialscf.potentialid
			$datarangesql
			WHERE IFNULL(sales_stage,'')<>''
			group by (case when find_in_set(sales_stage,'$successstage')then '$yingdanlabel' else sales_stage end)
		)curstage on curstage.sales_stage=allstage.sales_stage
		left join 
		(
			select  
			count(1)as totalnum,
			$totalcolumnsql as totalamount,
			(case when find_in_set(logsql.stage,'$successstage')then '$yingdanlabel' when ifnull(logsql.stage,'')='' then '$firststage' else logsql.stage end ) as sales_stage
			from ld_potential 
            left join ld_potentialscf on ld_potential.potentialid=ld_potentialscf.potentialid
			left join (
				select 
				ld_potstagehistory.potentialid,ld_potstagehistory.stage
				from  ld_potstagehistory 
				inner join(
					select 
					max(historyid) as maxhistoryid
					from  ld_potstagehistory
					group by potentialid,sales_stage
				)maxhistory on maxhistory.maxhistoryid=ld_potstagehistory.historyid
				where find_in_set(ld_potstagehistory.sales_stage ,'$failstage')
				group by ld_potstagehistory.potentialid
				order by ld_potstagehistory.historyid desc 
			)logsql on logsql.potentialid=ld_potential.potentialid
			$datarangesql
			where find_in_set(ld_potential.sales_stage ,'$failstage')
			group by (case when find_in_set(logsql.stage,'$successstage')then '$yingdanlabel' when ifnull(logsql.stage,'')='' then '$firststage' else logsql.stage end )
		)failstage on failstage.sales_stage=allstage.sales_stage 
		left join(
            select  (case when find_in_set(stage_bef,'$successstage')then '$yingdanlabel' else stage_bef end)as stage_bef,(sumshichang/ifnull(counts,1)) as shichang
			from (
			select 
			stage_bef,
			sum(CASE
					WHEN in_time IS NULL THEN
						TIMESTAMPDIFF(SECOND,createdtime,lastmodified)
					ELSE
						TIMESTAMPDIFF(SECOND,in_time,lastmodified)
				END)/count(DISTINCT potential_no) AS sumshichang,count(DISTINCT potential_no)as counts
			from(
				SELECT
					ld_potential.potential_no,
					a.historyid,
					a.stage AS stage_bef,
					a.sales_stage AS stage_aft,
					ld_potential.createdtime,
					a.lastmodified,
					(SELECT lastmodified FROM ld_potstagehistory WHERE sales_stage=a.stage AND historyid<=a.historyid AND potentialid=a.potentialid ORDER BY a.historyid DESC LIMIT 1) AS in_time
				FROM ld_potstagehistory a
				LEFT JOIN ld_potential  ON ld_potential.potentialid=a.potentialid
				$datarangesql
			)a  group by (case when find_in_set(stage_bef,'$successstage')then '$yingdanlabel' else stage_bef end)
            )a
		)avgtime on avgtime.stage_bef=allstage.sales_stage
		order by allstage.sequence asc
)a 
order by a.sequence asc";
        $res = $adb->pquery($sql);
        $list = $adb->query_result_all($res);
        $list = array_reverse($list);//条形图  反转
        $result = [];

        $result['ydatacount'] = count($list);
        $result['maxxdata'] = floor($list[0]['allnums']*2);//X轴最大刻度值
        $result['maxxdata'] = $result['maxxdata']<=$result['ydatacount']*2?$result['ydatacount']*2:$result['maxxdata'];
        $result['stepnum'] = floor($result['maxxdata']/2/$result['ydatacount']);//推进率的一半均分
        //数据行转列

        foreach($list as &$line){
            foreach($line as $linekey=>&$linevalue){
                //金额保留小数
                if(in_array($linekey,['curamount','failamount','successamount','avgamount','allamount','throughamount','allcuramount'])){
                    $linevalue = number_format($linevalue/$divisor,$system_deploy_351);
                }
                //推进率保留2位小数
                if($linekey=='throughrate'||$linekey=='failrate'){
                    $linevalue = round($linevalue*100,2);//推进率

                }
            }
            $result['ydata'][] = $line['sales_stage'];//销售阶段  这是Y轴刻度 要反过来的
            $result['throughrate'][] = $line['throughrate'];//推进率
            if($line['shichang']<=60){
                $line['shichang'] = (empty($line['shichang'])?0:round($line['shichang'],2)).'秒';
            }else if($line['shichang']>60 && $line['shichang']<=3600){
                $line['shichang'] = round($line['shichang']/60,2).'分';
            }else if($line['shichang']>3600 && $line['shichang']<=3600*24){
                $line['shichang'] = round($line['shichang']/3600,2).'时';
            }else{
                $line['shichang'] = round($line['shichang']/3600/24,2).'天';
            }
        }
        $result['list'] = $list;//所有的数据
        $result['accountinfo'] = $accountinfo;//所有的数据
        $result['ydata2'] = array_reverse($result['ydata']);//条形图  反转
        $result['throughrate'] = array_reverse($result['throughrate']);
        $result['fieldlabellist'] = array(
            'unit'=>$unit,
            'Win'=>getFixedLabel('Win'),
            'passthroughnums'=>getFixedLabel('passthroughnums'),
            'curnums'=>getFixedLabel('curnums'),
            'failnums'=>getFixedLabel('failnums'),
            'successnums'=>getFixedLabel('successnums'),
            'allnums'=>getFixedLabel('allnums'),
            'TotalAmount'=>getFixedLabel('TotalAmount'),
            'Conversionrate1'=>getFixedLabel('Conversionrate1'),
            'Averagetimeconsumption'=>getFixedLabel('Averagetimeconsumption'),
            'Currentstay'=>getFixedLabel('Currentstay'),
            'Loss'=>getFixedLabel('Loss'),
            'Winningcycle'=>getFixedLabel('Winningcycle'),
            'avgunitprice'=>getFixedLabel('avgunitprice'),
            'Lossrate'=>getFixedLabel('Lossrate')
        );
        $result['mobilePenetrateModule'][0] = 'Potentials';//穿透模块--四个系列 穿透模块都是销售机会
        $result['mobilePenetrateModule'][1] = 'Potentials';//穿透模块
        $result['mobilePenetrateModule'][2] = 'Potentials';//穿透模块
        $result['mobilePenetrateModule'][3] = 'Potentials';//穿透模块
        $result['can_penetrate'] = $this->setCanPenetrate();
        $result['chuantouParamsName'] = $this->chuantouParamsName;
        return $result;
    }

    //edit: xll 2023/11/13 线索漏斗
    public function getLeadsFunnel($datarangemodule){
        //方法写到了父类  因为线索分析也用到了
        $data = parent::getLeadsFunnel($datarangemodule);
        //获取option
        $this->setOptionPlateSetting();
        $data['datalabel'] = $this->chartOptionObj->getDataLabel();//数据标签显示
        $data['can_penetrate'] = $this->setCanPenetrate();
        return $data;
    }

    /***
     * AUTHOR:BY  zxm
     * DATE:20200903
     * DESCRIPTION:近六个月目标完成情况
     * param $data_type 销售指标值
     * param $senioruserid 用户范围 用户id 如1，2，3
     */
    public function getCOMPLATIONRATESIXMONTH($datarangemodule){
        // 销售指标默认值“contractamount” 签约额
        global $adb,$current_language;
        $system_deploy_351 = $this->system_deploy_351;
        $data_type = $this->params['data_type'];

        $month_num = '6';   //月份数，最近六个月故而取6
        $now_date = date('Y-n-d', strtotime(date('Y-n-01') . ' +1 month -1 day'));
        $last_date = date('Y-n',strtotime('-'. ($month_num - 1) . ' month')).'-01';
        $yearmonth = [];
        //edit: xll 2023/08/04 BUG0070635 目标为设置导致月份丢失问题
        for($i=1; $i <= $month_num; $i++){
            $tmp_month = date('Y-n',strtotime(date('Y-m').' -'. ($month_num - $i) . ' month'));
            $yearmonth[] = $tmp_month;
        }
        //记住页签
        setUsersettingByLabel('SalesGoal','','CompanySixMonthSalesRate_SalesGoal',$_REQUEST['targetid']);
        // 先求目标
        $salesgoal_arr = $this->getSalesGoalListInfo($data_type,$last_date,$now_date,$this->scopeType,$yearmonth);
        $salestarget = $salesgoal_arr['Target'];
        $salesgoal_done = $salesgoal_arr['Done'];
        $targetModule = $salesgoal_arr['SalesGoalInfo']['modulename'];
        $targetid = $salesgoal_arr['SalesGoalInfo']['targetid'];
        //根据销售指标判断 返回不同数据
        $userid_arr = explode(',',$this->senioruserid);
        $res = [];
        //edit: xll 2023/08/04 BUG0070635 目标为设置导致月份丢失问题
        foreach($yearmonth as $key => $tmp_month){
            $res['month'][$tmp_month] = $tmp_month;
            $tmp_target_data = 0.00;
            $tmp_done_data = 0.00;
            $tmp_rate_data = 0.00;
            foreach($salestarget[$targetModule] as $userid=>$usertarget){
                //edit: xll 2024/04/01 BUG20240329-61 目标管理设置客户模块对象的指标，最近六个月没有目标值
                if($targetModule !== 'Users' || in_array($userid,$userid_arr)){
                    $monthtarget = $usertarget[$tmp_month];
                    $tmp_target_data += $monthtarget;
                }
            }
            $tmp_target_data = round($tmp_target_data,$system_deploy_351);
            foreach($salesgoal_done as $userid=>$userdone){
                $monthdone = $userdone[$tmp_month];
                $tmp_done_data += $monthdone;
            }
            $tmp_done_data = round($tmp_done_data,$system_deploy_351);
            $tmp_rate_data = $tmp_target_data<=0?(($tmp_done_data >= 0) ? 100 : 0) : round($tmp_done_data*100 /$tmp_target_data,$system_deploy_351);

            $res['target'][$tmp_month] = $tmp_target_data;
            $res['done'][$tmp_month] = $tmp_done_data;
            $res['rate'][$tmp_month] = $tmp_rate_data;
        }

        foreach($res['month'] as &$month){
            $month = (int)substr($month,5);
            if($current_language == 'en'){
                $month= DateOperation::getCaldate((int)$month);
            }else{
                $month= $month.'月';
            }
        }

        $res['title'] = array_values($res['month']);
        $res['target'] = array_values($res['target']);
        $res['done'] = array_values($res['done']);
        $res['rate'] = array_values($res['rate']);
        //获取option
        $this->setOptionPlateSetting();
        $res['datalabel'] = $this->chartOptionObj->getDataLabel();//数据标签显示

        $modstatic = new SalesGoalNew();
        $res['indicator_unit'] = $modstatic->getIndicatorUnitLabel($targetid);
        $res['can_penetrate'] = $this->setCanPenetrate();
        return $res;
    }

    /***
     * AUTHOR:BY  xll
     * DATE:2023/08/08
     * DESCRIPTION:目标完成率仪表盘
     * param $data_type 销售指标值
     * param $senioruserid 用户范围 用户id 如1，2，3
     */
    public function getTARGETCOMPLETIONRATE($datarangemodule){
        // 销售指标默认值“contractamount” 签约额
        global $adb;
        $system_deploy_351 = $this->system_deploy_351;
        $data_type = $this->params['data_type'];

        $search_date = $_REQUEST['search_date'];
        if($search_date=='custom')$search_date=$_REQUEST['date_custom'];
        $search_date_arr = getHomeDateArray($search_date);
        $starttime = $search_date_arr[0];
        $starmonth = date('Y-n-d',strtotime($starttime));
        $endtime = (isset($search_date_arr[1])) ? $search_date_arr[1] : $search_date_arr[0];
        $endmonth = date('Y-n-d',strtotime($endtime));
        $yearmonth = [$starmonth,$endmonth];

        $now_date = date('Y-m-d', strtotime($endtime));
        $last_date = date('Y-m-d',strtotime($starttime));
        //记住页签
        setUsersettingByLabel('SalesGoal','','TargetCompletionRate_SalesGoal',$_REQUEST['targetid']);
        // 先求目标
        $salesgoal_arr = $this->getSalesGoalListInfo($data_type,$last_date,$now_date,$this->scopeType,$yearmonth);
        $salestarget = $salesgoal_arr['Target'];
        $salesgoal_done = $salesgoal_arr['Done'];
        $targetid = $salesgoal_arr['SalesGoalInfo']['targetid'];

        $res = [];
        $res['target'] = 0.00;
        $res['done'] = 0.00;
        $res['undone'] = 0.00;
        $res['rate'] = 0.00;
        $tmp_target_data = 0.00;
        $tmp_done_data = 0.00;
        //edit: xll 2023/10/06 BUG0073290 成员“hxg”并没有设置相应的目标管理指标，但首页-目标完成率却显示其目标值。
        //目标值收查看范围影响，只循环查看范围内的用户id
        if(isset($salestarget['Users'])) {
            $userid_arr = explode(',', $this->senioruserid);
            foreach ($userid_arr as $userid) {
                if (isset($salestarget['Users'][$userid]))
                    foreach ($salestarget['Users'][$userid] as $tmp_month => $monthtarget) {
                        $tmp_target_data += $monthtarget;
                    }
            }
        }
        //edit: xll 2024/03/07 指标对象为客户管理、产品管理时，数据不显示
        else {
            foreach ($salestarget as $module => $targetInfo) {
                foreach ($targetInfo as $record => $info) {
                    foreach ($info as $tmp_month => $monthtarget) {
                        $tmp_target_data += $monthtarget;
                    }
                }
            }
        }
        $tmp_target_data = round($tmp_target_data,$system_deploy_351);
        foreach($salesgoal_done as $userid=>$userdone){
            foreach($userdone as $tmp_month=>$monthdone){
                //if(in_array($tmp_month,$search_date_arr))
                $tmp_done_data += $monthdone;
            }
        }
        $tmp_done_data = round($tmp_done_data,$system_deploy_351);
        $modstatic = new SalesGoalNew();
        $indicator_unit_label= $modstatic->getIndicatorUnitLabel($targetid);
        $res['target'] = $tmp_target_data;
        $res['done'] = $tmp_done_data;
        if($res['target'] > 0) {
            $res['undone'] = $tmp_target_data - $tmp_done_data;
        }
        //edit: xll 2024/06/01 BUG 超额完成是，未完成改为0
        if($res['undone'] < 0) {
            $res['undone'] = 0;
        }
        $res['undone'] = round($res['undone'],$system_deploy_351);
        $setStuffDataFormatarr = ['target','done','undone'];
        foreach ($setStuffDataFormatarr as $tmpkey){
            $res[$tmpkey] =  $res[$tmpkey].$indicator_unit_label;
        }
        $res['rate'] = ($tmp_target_data<=0) ? (($tmp_done_data >= 0) ? 100 : 0) : round($tmp_done_data*100 /$tmp_target_data,$system_deploy_351);
        $res['can_penetrate'] = $this->setCanPenetrate();
        return $res;
    }
    /***
     * AUTHOR:BY  xll
     * DATE:2023/08/08
     * DESCRIPTION:获取销售目标的目标值与完成值
     * param $data_type 销售指标值
     * param $senioruserid 用户范围 用户id 如1，2，3
     */
    public function getSalesGoalListInfo($data_type,$last_date,$now_date,$scopeType,$yearmonth){
        global $adb;
        require_once globalStatic::$root_directory.'modules/SalesGoal/SalesGoalNew.class.php';
        $SalesGoalNewObj = new SalesGoalNew();
        //设置其数据范围为目标管理模块
        $SalesGoalNewObj->set_cur_module('SalesGoal');
        $SalesGoalNewObj->setUnitExist('yes');
        $SalesGoalNewObj->setSelectUserIds($_REQUEST['selectuid']);
        //获取targetid
        $targetnums = 0;
        if(isset($_REQUEST['targetid']) && !empty($_REQUEST['targetid'])){
            $targetid = $_REQUEST['targetid'];
            $targetnums = 1;
        }else{
            $targetbasicsql = "select targetid from ld_salestarget_basic where targetname=? ";
            $targetbasicres = $adb->pquery($targetbasicsql,array($data_type));
            $targetnums = $adb->num_rows($targetbasicres);
            $targetid = ($targetnums > 0) ? $adb->query_result($targetbasicres,0,'targetid') : null;
        }
        $salestarget = [];
        if($targetnums>0){
            $salestarget = $SalesGoalNewObj->getSalesGoalToLook(array($last_date,$now_date),$targetid);
            $SalesgoalInfo = $SalesGoalNewObj->getSalesGolaInfoByid($targetid);
            //移动端的用户范围需要特殊处理
            if($_REQUEST['selectuid'] == 'all')
                $scopeType = 'SmOwner_Search_All';
            $record_info = $SalesGoalNewObj->GetRecordInfo($SalesgoalInfo,$scopeType);
            $SalesGoalNewObj->filterTargetRes($record_info,$salestarget);
            $salesgoal_done = $SalesGoalNewObj->getSalesGoalOverInfo($targetid,$yearmonth,$record_info) ;
        }
        return array('Target'=>$salestarget,'Done'=>$salesgoal_done,'SalesGoalInfo'=>$SalesgoalInfo);
    }
    /**
     * 线索分析组件，stuffid 116
     */
    public function getLeadsAnalysis ($datarangemodule) {
        $stuffid = $this->stuffid;
        $res_data = $this->getLeadsFunnel($datarangemodule);
        $res = $res_data['total_data'];
        $res['label'] = [];
        $moduleArr = explode(',',$datarangemodule);
        foreach ($moduleArr as $module) {
            $res['label'][$module] = getTranstab($module);
        }
        $count_list = [
            'leads_to_accounts' => ['leads_num','accounts_num'],
            'leads_to_potentials' => ['leads_num','unique_potentials_num'],
            'leads_to_salesorder' => ['leads_num','unique_salesorder_num'],
        ];
        foreach ($count_list as $key => $info) {
            $mol_name = $info[1];
            $mol_value = $res[$mol_name];
            $den_name = $info[0];
            $den_value = $res[$den_name];
            if($den_value == 0)
                $res[$key] = 0;
            else
                $res[$key] = setNumberFormatEmptySeperator($mol_value / $den_value * 100) . '%';
        }
        //edit: xll 2024/03/06 BUG20240306-29 模块关闭不显示对应行
        $result = [];
        if(vtlib_isModuleActive('Leads')){
            array_push($result,[
                'module' => 'Leads',
                'label' => getFixedLabel('LeadsNum'),
                'subLabel' => '',
                'value' => $res['leads_num'],
            ]);
            //edit: xll 2024/03/18 BUG20240318-04 销售线索关闭后，首页“线索分析”组件应该空白
            if(vtlib_isModuleActive('Accounts')){
                array_push($result,[
                    'module' => 'Accounts',
                    'label' => getFixedLabel('LeadsToAccountsNum'),
                    'subLabel' => '',
                    'value' => $res['accounts_num'] . ' / ' . $res['leads_to_accounts'],
                ]);
            }
            if(vtlib_isModuleActive('Potentials')){
                array_push($result,[
                    'module' => 'Potentials',
                    'label' => getFixedLabel('LeadsToPotentialsNum'),
                    'subLabel' => getFixedLabel('PotentialsAmount') . $res['potentials_total'] . getFixedLabel('YUAN'),
                    'value' => $res['unique_potentials_num'] . ' / ' . $res['leads_to_potentials'],
                ]);
            }
            if(vtlib_isModuleActive('SalesOrder')){
                array_push($result,[
                    'module' => 'SalesOrder',
                    'label' => getFixedLabel('LeadsToSalesorderNum'),
                    'subLabel' => getFixedLabel('SalesordersAmount') . $res['salesorder_total'] . getFixedLabel('YUAN') .
                        ' | ' . getFixedLabel('TOTALRECEIVES') . ' : ' . $res['cashbill_total'] . getFixedLabel('YUAN') ,
                    'value' => $res['unique_salesorder_num'] . ' / ' . $res['leads_to_salesorder'],
                ]);
            }
        }

        return $result;
    }

}


