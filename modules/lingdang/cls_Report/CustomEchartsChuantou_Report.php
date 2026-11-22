<?php
require_once(globalStatic::$root_directory."modules/lingdang/cls_Report/cls_getPenetrateModuleList.php");
/**
 * 处理自定义统计图穿透的类：报表分析模块
 */
class CustomEchartsChuantou_Report extends cls_getPenetrateModuleList
{
    public $ChartSetInfo;
    public function __construct(){
        parent::__construct();
    }

    public function setParams($params_REQUEST) {
        parent::setParams($params_REQUEST);

        $ChartSetInfo = json_decode($_REQUEST['ChartSetInfo'],true);
        crm_load_class_file('DataRangeHomeboard','modules/Home/');
        $DataRangeHomeboardObj = new DataRangeHomeboard(0,'ReportAnalysis');
        $DataRangeHomeboardObj->resetModuleQueryObj($ChartSetInfo['mainmodule']);
        //获取统计模块信息 zxm 20231208 根据点击的是哪个系列来获取
        $YAxis = $ChartSetInfo['AxisFields']['YAxis'];
        $SeriesIndex = $_REQUEST['SeriesIndex'];
        //漏斗图需要删除尾部的数字
        /*if(in_array($ChartSetInfo['chart_type'],['funnel','triangle','bowls'])){
            $_REQUEST['XAxisName'] = explode('(',$_REQUEST['XAxisName'])[0];
        }*/
        if($ChartSetInfo['chart_type']=='nesting_pie'||count($YAxis)==1){
            //嵌套饼图就一个统计字段
            $cur_computeinfo = $YAxis[0];
        }else{
            $cur_computeinfo = $YAxis[$SeriesIndex];
        }
        $this->params['cur_computeinfo'] = $cur_computeinfo;
        $compare_select = $cur_computeinfo['compare_select'];//同环比选项 //同环比选项  没有同比环比的是cur
        $this->params['compare_select'] = $compare_select;
        $params = [
            'ChartSetInfo' => $ChartSetInfo,
            'penetrateModule' => $cur_computeinfo['FieldModule'],//穿透模块
            'DataRangeHomeboardObj' => $DataRangeHomeboardObj,
            'curdatarangsql' => '',
            'curdatarangsql_str' => '',
            'popuptitle' => $ChartSetInfo['report_name']
        ];

        $this->ChartSetInfo = $params['ChartSetInfo'];
        //$this->penetrateModule = $params['penetrateModule'];
        $this->penetrateModule = $cur_computeinfo['FieldModule'];
        $DataRangeHomeboardObj->resetModuleQueryObj($this->penetrateModule);
        $this->penetrateModuleArr = [];
        $this->penetrateModuleArr[] = $this->penetrateModule;
        $this->scopemodule = $params['penetrateModule'];
        $this->DataRangeHomeboardObj = $params['DataRangeHomeboardObj'];
        $this->curdatarangsql = $params['curdatarangsql'];
        $this->curdatarangsql_str = $params['curdatarangsql_str'];
        $this->popuptitle = $params['popuptitle'];
        if($this->ChartSetInfo['chart_type'] == 'simple_sunburst'){
            if($_REQUEST['treePathInfo']){
                $treePathInfo = $this->treePathInfo = json_decode($_REQUEST['treePathInfo'],true);
                for ($i = 1 ; $i < count($treePathInfo) ; $i ++) {
                    $this->popuptitle .= '->' . $treePathInfo[$i]['name'];
                }
            }
        } else {
            if($_REQUEST['XAxisName'])
                $this->popuptitle .= '->' . $_REQUEST['XAxisName'];
            if($_REQUEST['SeriesName'])
                $this->popuptitle .= '->' . $_REQUEST['SeriesName'];
        }
    }

    public function AdvanceInput_Push (&$tmpinput,$FieldValue,$value,$TimeMethod) {
        $comparator = 'e';
        if(!empty($TimeMethod) && $TimeMethod != 'byField') {
            $comparator = 'bw'; //时间字段统一为区间
            $value = $this->getStartAndEndDate($TimeMethod,$value);
        }
        if($value=='无'||empty($value)){
            //zxm 20231206 传过来的值是无或者空
            $advance_demand_item = [
                'groupid' => '1',
                'columnname' => $FieldValue,//'bw'
                'comparator' => 'isnull',//是空值
                'value' => '',
                'columncondition' => 'and', //且条件
            ];
        }else{
            $advance_demand_item = [
                'groupid' => '1',
                'columnname' => $FieldValue,//'bw'
                'comparator' => $comparator,//默认 e 等于
                'value' => $value,
                'columncondition' => 'and', //且条件
            ];
        }

        array_push($tmpinput['advft_criteria'],$advance_demand_item);

        if(count($tmpinput['advft_criteria_groups'])<=0){
            $advance_demand_groups_item = [
            'groupcondition' => 'and',
            ];
            array_push($tmpinput['advft_criteria_groups'],$advance_demand_groups_item);
        }

    }

    public function getAdvanceInput (&$tmpinput,$XAxisFields) {
        if($XAxisFields[0]){
            //漏斗图需要删除尾部的数字
            //$XAxisName = explode('(',$_REQUEST['XAxisName'])[0];
            $XAxisName = $_REQUEST['XAxisName'];
            $this -> AdvanceInput_Push($tmpinput,$XAxisFields[0]['FieldValue'],$XAxisName,$XAxisFields[0]['TimeMethod']);
        }
        if($XAxisFields[1]){
            $this -> AdvanceInput_Push($tmpinput,$XAxisFields[1]['FieldValue'],$_REQUEST['SeriesName'],$XAxisFields[1]['TimeMethod']);
        }

        //return $tmpinput;
    }

    public function getAdvanceInput_nesting_pie (&$tmpinput,$XAxisFields) {
        $SeriesIndex = $_REQUEST['SeriesIndex'];
        if($XAxisFields[$SeriesIndex]){
            $this -> AdvanceInput_Push($tmpinput,$XAxisFields[$SeriesIndex]['FieldValue'],$_REQUEST['XAxisName'],$XAxisFields[$SeriesIndex]['TimeMethod']);
        }
    }

    public function getAdvanceInput_simple_sunburst (&$tmpinput,$XAxisFields) {
        $penetrateModule = $this->penetrateModule;
        $treePathInfo = $this->treePathInfo;
        crm_load_class_file('EchartReport','modules/CustomEcharts/');
        $EchartReportObj = new EchartReport();
        $FieldValue = $XAxisFields[0]['FieldValue'];
        $TimeMethod = $XAxisFields[0]['TimeMethod'];
        $FieldName = explode(':',$FieldValue)[2];
        $EchartReportObj->getDependentFields($penetrateModule,$FieldName);
        $DependentFields = $EchartReportObj->DependentFieldsList;
        //根据$treePathInfo的长度确定是否是维度字段的上级字段
        $FieldIndex = count($treePathInfo) - 2; //$treePathInfo的第一个值为空，故$FieldIndex需要 -2
        if($DependentFields[$FieldIndex]) {
            $DirFieldName = $DependentFields[$FieldIndex]['fieldname'];
            $tmpfocus =  CRMEntity::getInstance($penetrateModule);
            $DirFieldInfoObj = $tmpfocus->fieldobj->getFieldInfoobjBykey("fieldname", $DirFieldName);
            $tablename = $DirFieldInfoObj->getTableName();
            $columname = $DirFieldInfoObj->getColumnName();
            $typeofdata_arr = explode('~',$DirFieldInfoObj->getTypeOfData());
            $FieldValue = $tablename.":".$columname.":".$DirFieldName.":".$penetrateModule."_fieldlabel:".$typeofdata_arr[0];
        }
        $this -> AdvanceInput_Push($tmpinput,$FieldValue,$_REQUEST['XAxisName'],$TimeMethod);
    }

    //处理高级查找和基本查找
    public function setExtroCondition() {
        $ChartSetInfo = $this->ChartSetInfo;
        $XAxisFields = $ChartSetInfo['AxisFields']['XAxis'];
        $tmpinput = [
            'advft_criteria' => [],
            'advft_criteria_groups' => [],
            'searchtype' => 'advance',
        ];
        $tmpinput['advft_criteria'] = [];
        $tmpinput['advft_criteria_groups'] = [];
        $tmpinput['searchtype'] = 'advance';

        $getAdvanceInput_Fun = 'getAdvanceInput';
        //特殊图表类型
        $ChartType_Arr = ['nesting_pie','simple_sunburst'];
        if(in_array($ChartSetInfo['chart_type'],$ChartType_Arr))
            $getAdvanceInput_Fun .= '_' . $ChartSetInfo['chart_type'];
        //根据图表类型拼装高级查找条件

        $this->$getAdvanceInput_Fun($tmpinput,$XAxisFields);
        $tmpinput['advft_criteria'] = json_encode($tmpinput['advft_criteria']);
        $tmpinput['advft_criteria_groups'] = json_encode($tmpinput['advft_criteria_groups']);

        $DataRangeHomeboardObj = $this->DataRangeHomeboardObj;

        $mainmodule = $ChartSetInfo['mainmodule'];
        $tmp_queryobj = $DataRangeHomeboardObj->get_query_obj($mainmodule);
        $tmp_queryobj->setScopeModule($mainmodule);
        $tmp_queryobj->setSmOwnerSearchSql();
        $tmp_queryobj->addUserSearchConditions($tmpinput);

        $advance_demand = $ChartSetInfo['OtherCondition']['advance_demand'];
        $advance_demand_groups = $ChartSetInfo['OtherCondition']['advance_demand_groups'];
        if ($advance_demand && $advance_demand != '[]') {
            $tmpinput_2 = [
                'advft_criteria' => $advance_demand,
                'advft_criteria_groups' => $advance_demand_groups,
                'searchtype' => 'advance',
            ];
            $tmp_queryobj->addUserSearchConditions($tmpinput_2);
        }

        //穿透界面的基本、高级查找条件
        if(!empty($this->basicsearchArr)) {
            $tmp_queryobj->addUserSearchConditions($this->basicsearchArr);
        }
        if(!empty($this->advancesearchArr)) {
            $tmp_queryobj->addUserSearchConditions($this->advancesearchArr);
        }

        if($this->boardid<=0){
            global $adb;
            //zxm 20231120 默认看板  读取设置好的映射条件
            $cvadvfilter_sql = "select * from ld_customreport_cvadvfilter where comparator in('show_athome_timecheck','show_athome_person','show_athome_approve') and report_id=? order by columnindex asc";
            $cvadvfilter_res = $adb->pquery($cvadvfilter_sql,array($this->stuffid));
            $cvadvfilter_nums = $adb->num_rows($cvadvfilter_res);
            if($cvadvfilter_nums>0){
                for($i=0;$i<$cvadvfilter_nums;$i++){
                    $comparator = $adb->query_result($cvadvfilter_res,$i,'comparator');
                    if($comparator=='show_athome_person'){
                        $show_athome_person='yes';
                    }else if($comparator=='show_athome_timecheck'){
                        $show_athome_timecheck='yes';
                    }else if($comparator=='show_athome_approve'){
                        $show_athome_approve='yes';
                    }
                }
            }
            if($show_athome_person=='no'){
                $this->scopeType = 'SmOwner_Search_All';
                $this->senioruserid = '';
            }
            if($show_athome_timecheck=='no'){
                $this->date_search = '';
                $this->daterange = '';
            }
            if($show_athome_approve=='no'){
                $this->approve_value = 'all';
            }
        }
        $search_date = $this->search_date_custom_value;
        $filterArr = $DataRangeHomeboardObj->boardfilterArr[$this->boardstuffid];
        $timeisrelated = $filterArr['timecomponent_' . $this->penetrateModule]['isrelated'];
        $tmpcompareselect = 'cur';
        if(isset($this->params['compare_select'])&&!empty($this->params['compare_select'])){
            $tmpcompareselect = $this->params['compare_select'];
        }
        if($timeisrelated=='yes'){
            crm_load_class_file('DateOperation','include');
            $dateinfo = DateOperation::getCompareDate($search_date);
            $startdate =$dateinfo['startdate'];
            $enddate =$dateinfo['enddate'];
            crm_load_class_file('ReportAnalysisUtils','modules/ReportAnalysis');
            if($tmpcompareselect=='prev'&&$search_date!='all'){
                //环比上期总条件
                $groupInfo = $XAxisFields;
                $groupbytype = $groupInfo['groupbytype'];
                $prevTimeRange = ReportAnalysisUtils::getHuanbiTimeRange($groupbytype,[$startdate,$enddate]);
                $search_date = implode('~',$prevTimeRange);
            }else if($tmpcompareselect=='prev_lastyear'&&$search_date!='all'){
                //去年同期总条件
                $prev_lastyearTimeRange = ReportAnalysisUtils::getTongbiTimeRange([$startdate,$enddate]);
                $search_date = implode('~',$prev_lastyearTimeRange);
            }
        }
        //zxm 20240612 改成调用公共
        $stuffDateRangeArr = $DataRangeHomeboardObj->getHomeDateScope($search_date,'no'); //获取时间范围  返回的是一个数组

        $cur_computeinfo = $this->params['cur_computeinfo'];
        $chart_column_table = $cur_computeinfo['chart_column_table'];
        $penetrateModule = $this->penetrateModule;
        $tmpfocus =  CRMEntity::getInstance($penetrateModule);
        $iscomputedetailtable = 'no';
        //判断统计字段是主表还是明细表  明细表的话pagelistquery字段是lineitemid 主表的话是salesorderid
        if($tmpfocus->Detail_table==$chart_column_table
            ||$tmpfocus->Detail_table_scf==$chart_column_table
            ||('ld_products'==$chart_column_table
                    ||'ld_productcf'==$chart_column_table&&$penetrateModule != 'Products'))
        {
            $iscomputedetailtable='yes';
        }
        $params = array(
            'datarangmodule'=>$mainmodule,
            'computemodule'=>$this->penetrateModule,
            'stuffid'=>$this->ChartSetInfo['report_id'],
            'boardstuffid'=>$this->boardstuffid,
            'scope'=>$this->scopeType,
            'senioruserid'=>$this->selectuserid,
            'date_adv'=>$stuffDateRangeArr['date_adv'],
            'approve_value'=>$this->approve_value,
            'iscomputedetailtable'=>$iscomputedetailtable,
            'ischuantou'=>'yes',
        );

        if($mainmodule==$this->penetrateModule){
            //穿透模块（统计模块）和主模块（主模块：带了高级查找条件，首页条件等）一致
            $datarangesqlArr = $DataRangeHomeboardObj->getDataRangeSqlCharts($params);
            $this->curdatarangsql = $DataRangeHomeboardObj->datarangesqlArr['datarangesql_'.$mainmodule];//带innerjoin的
            $this->curdatarangsql_str = $datarangesqlArr[$mainmodule];//没有innerjoin的

        }else{
            //穿透模块（统计模块）和主模块（主模块：带了高级查找条件，首页条件等）不一致  只有穿透才会出现这个情况 比如主模块选客户，相关模块选合同订单 分组字段选客户的客户名称 统计字段选合同的合计  获取统计值的时候是连了客户表的所以没问题，穿透的时候只有合同订单表，没连客户表
            //将主模块的高级查找条件 转化成穿透模块的条件SQL page_list_query
            $datarangesqlArr = $DataRangeHomeboardObj->getDataRangeSqlCharts($params);
            $jointype = $DataRangeHomeboardObj->datarangesqlArr['jointype_'.$mainmodule];

            //需要获取统计模块和主模块的关联关系
            if($jointype=='main'){
                $computemodule = $this->penetrateModule;
                $computemoduleFocus = CRMEntity::getInstance($computemodule);
                $mainmoduleFocus = CRMEntity::getInstance($mainmodule);
                crm_load_class_file("cls_TableJoin_module",'include/fields');
                $relatetablejoinobj = cls_TableJoin_module::getInstance($mainmodule,$computemodule);
                $tmpjoin = $relatetablejoinobj->getJoin();
                $tmprelateinfo = $relatetablejoinobj->relateinfo;
                $reference_column=$tmprelateinfo['reference_column'];

                $reference_column = strpos($reference_column,'ld_')!=false?$reference_column:'ld_'.$reference_column;
                $reference_column_arr = explode('.',$reference_column);

                $mainjointable = $reference_column_arr[0];
                $mainjoinon_field = $reference_column_arr[1];
                $conputemoduleQueryObj = $DataRangeHomeboardObj->get_query_obj($computemodule);
                $computemodulepage_list_query = $conputemoduleQueryObj->getQuery();
                $computemodulepage_list_query_arr = explode('WHERE',$computemodulepage_list_query);

                $mainmodule_curdatarangsql = $DataRangeHomeboardObj->datarangesqlArr['datarangesql_'.$mainmodule];//带innerjoin的
                $mainmodule_curdatarangsql_str = $datarangesqlArr[$mainmodule];//没有innerjoin的

                if($tmpjoin['bwType']=='selectSource'){
                    $tmpinnerjoinon = $mainmoduleFocus->table_index.'='.$mainmoduleFocus->table_name.'.'.$mainmoduleFocus->table_index;
                    $leftjoinsql = $tmpjoin['joinsqltype'].$tmpjoin['bwmodulesql'];
                }else{
                    $leftjoinsql = '';
                    $tmpinnerjoinon = $mainjoinon_field.'='.$mainjointable.'.'.$mainjoinon_field;
                }

                $computemodulepage_list_query = $computemodulepage_list_query_arr[0].$leftjoinsql.' inner join ('.$mainmodule_curdatarangsql_str.')  datarangesql_'.strtolower($mainmodule).' on datarangesql_'.strtolower($mainmodule).'.'.$tmpinnerjoinon.'  WHERE '.$computemodulepage_list_query_arr[1];

                $this->curdatarangsql =' inner join ('.$computemodulepage_list_query.') datarangesql_'.strtolower($computemodule).' on datarangesql_'.strtolower($computemodule).'.'.$computemoduleFocus->table_index.'='.$computemoduleFocus->table_name.'.'.$computemoduleFocus->table_index;
                $this->curdatarangsql_str = $computemodulepage_list_query;

            }else{

                $this->curdatarangsql ='';
                $this->curdatarangsql_str = '';
            }
        }
    }

    public function getListView() {
        $this->getPageSearch();

        $this->setOrderByTable();
        $this->setExtroCondition();

        $this->commonReturn();
    }


}



?>