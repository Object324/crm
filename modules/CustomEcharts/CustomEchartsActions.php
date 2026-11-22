<?php
include_once globalStatic::$root_directory.'modules/CustomEcharts/EchartSetting.php';
include_once globalStatic::$root_directory.'modules/CustomEcharts/cls_showTable.php';

class CustomEchartsActions extends EchartSetting
{

    public $report_info_arr;
    public $groupInfo = [];
    //获取映射首页条件的变量个数
    public $var_multiuser_nums = 0;
    public $var_time_nums = 0;
    public $var_approvestatus_nums = 0;
    public $except = UNABLE2STATISTICSMODULE;
    public $ChartSetInfo; //统计图设置信息Json

    private $primaryname='';//特殊开发预制的报表有这个值

    public function __construct($params)
    {
        parent::__construct($params);
        $this->report_info_arr = [];
    }

    //获取sql统计图 sql解析出来的字段信息
    public function getSqlColumns($report_id){
        $columnsArr = [];
        $columns_sql = "select * from ld_customreportsql_column where report_id=? order by sequence asc;";
        $columns_res = $this->adb->pquery($columns_sql,array($report_id));
        $columns_nums = $this->adb->num_rows($columns_res);
        if($columns_nums>0){
            $columnsArr = $this->adb->query_result_all($columns_res);
        }
        return $columnsArr;
    }
    //获取SQL变量信息
    public function getSqlFilter($report_id){
        $sqlFilterArr = [];
        $sqlFilter_sql = "select * from ld_customreportsql_filter where report_id=? order by sequence asc;";
        $sqlFilter_res = $this->adb->pquery($sqlFilter_sql,array($report_id));
        $sqlFilter_nums = $this->adb->num_rows($sqlFilter_res);
        if($sqlFilter_nums>0){
            $sqlFilterArr = $this->adb->query_result_all($sqlFilter_res);
            foreach($sqlFilterArr as $k=>$filter){
                //用户组件
                if($filter['var_type']=='multiuser'){
                    $modulename = $filter['modulename'];
                    $scopeobj = new ScopOfAuthority($this->adb,$modulename);
                    $userids = $scopeobj->getCurUserScopeIds();
                    $sqlFilterArr[$k]['default_value'] = $userids;//用户默认值
                }
                if($filter['var_type']=='multiuser'&&$filter['filter_relatedtab']=='Home'){
                    $this->var_multiuser_nums=1;
                }
                if(($filter['var_type']=='date'||$filter['var_type']=='datetime')&&$filter['filter_relatedtab']=='Home'){
                    $this->var_time_nums=1;
                }
                if($filter['var_type']=='approvestatus'&&$filter['filter_relatedtab']=='Home'){
                    $this->var_approvestatus_nums=1;
                }
            }
        }
        return $sqlFilterArr;
    }
    public function getReportMainInfo($report_id){
        $mainInfo = [];
        //主表信息  统计图名称 描述 报表类型 创建时间 设为链接模块 选择文件夹 sql语句
        $sql = " select  report_name,report_desc,report_type,createdtime,sqlstr,analysisfolder_id,isshow_table,isshow_search,linkmodulecheck,approveallocatetype,smcreatorid,themename,show_athome,primaryname from ld_customreport where report_id=?";
        $mainInfo_res = $this->adb->pquery($sql,array($report_id));
        $mainInfo_nums = $this->adb->num_rows($mainInfo_res);
        if($mainInfo_nums>0){
            $mainInfo['report_id'] =  $report_id;
            $mainInfo['report_name'] =  $this->adb->query_result($mainInfo_res,0,'report_name');
            $mainInfo['report_desc'] =  $this->adb->query_result($mainInfo_res,0,'report_desc');
            $mainInfo['report_type'] =  $this->adb->query_result($mainInfo_res,0,'report_type');
            $mainInfo['createdtime'] =  $this->adb->query_result($mainInfo_res,0,'createdtime');
            $mainInfo['sqlstr'] =  decode_html($this->adb->query_result($mainInfo_res,0,'sqlstr'));
            $mainInfo['show_athome'] =  $this->adb->query_result($mainInfo_res,0,'show_athome');
            $mainInfo['analysisfolder_id'] =  $this->adb->query_result($mainInfo_res,0,'analysisfolder_id');
            $mainInfo['isshow_table'] =  $this->adb->query_result($mainInfo_res,0,'isshow_table');
            $mainInfo['isshow_search'] =  $this->adb->query_result($mainInfo_res,0,'isshow_search');
            $mainInfo['linkmodulecheck'] =  $this->adb->query_result($mainInfo_res,0,'linkmodulecheck');
            $mainInfo['approveallocatetype'] =  $this->adb->query_result($mainInfo_res,0,'approveallocatetype');
            $mainInfo['smcreatorid'] =  $this->adb->query_result($mainInfo_res,0,'smcreatorid');
            $mainInfo['themename'] =  $this->adb->query_result($mainInfo_res,0,'themename');
            $this->primaryname =  $this->adb->query_result($mainInfo_res,0,'primaryname');
        }

        return $mainInfo;
    }

    //获取报表分组字段信息
    public function getGroupByInfo ($report_id){
        $groupInfo = [];
        //主表信息  统计图名称 描述 报表类型 创建时间 设为链接模块 选择文件夹 sql语句
        $sql = " select group_id,groupbytype,b.`columns` as realcolumns,a.`columns`,b.column_label as groupbyname from ld_customreport_group   a
                 left join  ld_customreportsql_column b on b.id=a.`columns`  where a.report_id=?";
        $groupInfo_res = $this->adb->pquery($sql,array($report_id));
        $groupInfo_nums = $this->adb->num_rows($groupInfo_res);
        if($groupInfo_nums>0){
            $groupInfo =  $this->adb->query_result_all($groupInfo_res);
        }
        return $groupInfo;
    }
    public function getReportColumns ($report_id){
        $columnInfo = [];

        $sql = " select a.column_id,b.columns as realcolumns,a.columns,a.sequence,a.chart_column_type,a.color,a.chart_column_name,a.yaxisindex,b.fieldtype from ld_customreport_total_column a
                 left join  ld_customreportsql_column b on b.id=a.columns                                                            
                 where a.report_id=?";
        $columnInfo_res = $this->adb->pquery($sql,array($report_id));
        $columnInfo_nums = $this->adb->num_rows($columnInfo_res);
        if($columnInfo_nums>0){
            //edit: xll 2023/11/08 XUQIU1002021 “SQL统计图”设置界面、查看界面功能优化
            $columnInfo = [];
            for($i=0;$i<$columnInfo_nums;$i++){
                $InfoArr = ['column_id','realcolumns','columns','sequence','chart_column_type','color','chart_column_name','yaxisindex','fieldtype',];
                foreach ($InfoArr as $col_name) {
                    $columnInfo[$i][$col_name] = $this->adb->query_result($columnInfo_res,$i,$col_name);
                }
                $columnInfo[$i]['typeofdata_decimal'] = 2;//小数位数
                if ($columnInfo[$i]['fieldtype'] == 'number') {
                    $columnInfo[$i]['typeofdata_decimal'] = 0;//小数位数
                }
                //如果为空即未设置显示名称，则显示字段名称
                if(empty($columnInfo[$i]['chart_column_name'])) {
                    $columnInfo[$i]['chart_column_name'] = $columnInfo[$i]['realcolumns'];
                }
                //YAxis对应键值赋值
                $columnInfo[$i]['SeriesType'] = $columnInfo[$i]['chart_column_type']; //展示形式
                $columnInfo[$i]['DisplayName'] = $columnInfo[$i]['chart_column_name'];//显示名称
                $columnInfo[$i]['YAxisIndex'] = $columnInfo[$i]['yaxisindex'];    //选择y轴
            }
        }
        return $columnInfo;
    }
    public function getReportAllInfo($report_id){
        //主表信息 选择文件夹 统计图名称 描述 设为链接模块
        $mainInfo = $this->getReportMainInfo($report_id);
        if(empty($mainInfo['themename'])){
            $mainInfo['themename'] = 'default';
        }
        //图表设置信息  图表类型
        $chartSet = $this->getEchartSet($report_id);
        $chartSet['themename'] = $mainInfo['themename'];
        //sql解析出来的字段信息
        $sqlColumnsArr = $this->getSqlColumns($report_id);
        //sql变量信息
        $sqlFilterArr = $this->getSqlFilter($report_id);
        //统计维度信息
        $groupInfo = $this->getGroupByInfo($report_id);
        //统计字段信息
        $columnInfo = $this->getReportColumns($report_id);
        return [
            'mainInfo'=>$mainInfo,
            'chartSet'=>$chartSet,
            'sqlColumnsArr'=>$sqlColumnsArr,
            'sqlFilterArr'=>$sqlFilterArr,
            'groupInfo'=>$groupInfo,
            'columnInfo'=>$columnInfo
        ];
    }
    //设置筛选框的默认值
    public function setSqlFilterValue($filterArr){
        //时间默认值
        foreach($filterArr as $k=>$filterline){
            $tmp_var_type = $filterline['var_type'];
            $filterArr[$k]['default_value_actual'] = $filterline['default_value'];
            //时间
            if($tmp_var_type=='date'||$tmp_var_type=='datetime'){
                $default_value = $filterline['default_value'];
                $default_value_arr = explode(',',$default_value);
                if($default_value_arr[0]=='selfdefined'){
                    $filterArr[$k]['default_value_actual'] = $default_value_arr[1];
                }else{
                    $filterArr[$k]['default_value_actual'] = $this->getFilterDefaultValue($default_value_arr[0]);
                }
                if($tmp_var_type=='date'){
                    $filterArr[$k]['default_value_actual'] = substr( $filterArr[$k]['default_value_actual'],0,10);
                }
            }
            //下拉框
            if($tmp_var_type=='select'||$tmp_var_type=='multiselect'){
                if(empty($filterline['selectvalues'])){
                    $filterArr[$k]['select_values_arr'] = [];
                }else{
                    $filterArr[$k]['select_values_arr'] = explode(',',$filterline['selectvalues']);
                }
            }
            //多选框
            if($tmp_var_type=='multiselect'){
                if(empty($filterline['default_value'])){
                    $filterArr[$k]['default_values_arr'] = [];
                }else{
                    $filterArr[$k]['default_values_arr'] = explode(',',$filterline['default_value']);
                }
            }
            //用户组件
            if($tmp_var_type=='multiuser'){
                if(empty($filterline['default_value'])){
                    $filterArr[$k]['default_values_arr'] = [];
                }else{
                    $filterArr[$k]['default_values_arr'] = explode(',',$filterline['default_value']);
                }
                $scopeobj = new ScopOfAuthority($this->adb,$filterline['modulename']);
                $tmp_default_value = $scopeobj->getCurUserScopeIds();
                $filterline['default_value'] = $tmp_default_value;
                $fieldname = 'last_name';
                /**if(isKehu001ServerPc()=='yes'){
                $fieldname = 'real_name';
                }**/
                //用户名称
                $user_sql = "select group_concat(".$fieldname.") as last_name from ld_users where id  in (".$filterline['default_value'].") ";
                $user_res = $this->adb->pquery($user_sql);
                $user_nums = $this->adb->num_rows($user_res);
                if($user_nums>0){
                    $usernames_str = $this->adb->query_result($user_res,0,0);
                    $filterArr[$k]['default_value'] = $tmp_default_value;
                    $filterArr[$k]['usernames_str'] = empty($usernames_str)?'':$usernames_str;
                }
            }
            //审批组件的默认值
            if($tmp_var_type=='approvestatus'){
                $default_value = $filterline['default_value'];
                $filterArr[$k]['approvestatus_default_value_arr'] = explode(',', $default_value);
            }
        }
        return $filterArr;
    }
    public function getSqlDetailData($report_id){
        $reportAllInfo = $this->getReportAllInfo($report_id);//报表全部的信息
        $reportAllInfo['chartSet']['report_name'] = $reportAllInfo['mainInfo']['report_name'];//zxm 20230907 不加这个下载图片没有名称
        $columns = $reportAllInfo['columnInfo'];//统计字段信息
        $groupbyInfo = $reportAllInfo['groupInfo'];//分组字段信息
        $this->groupInfo = $groupbyInfo;

        $groupcolumnname_arr = array_column($groupbyInfo,'realcolumns');
        $groupbykey = implode(',',$groupcolumnname_arr);

        $charttype = $reportAllInfo['chartSet']['chart_type'];//统计图 类型
        $echartSet = $reportAllInfo['chartSet'];//统计图样式设置

        $legend_position = $reportAllInfo['chartSet']['legend_position'];//图例位置
        $cls_showTableObj = new cls_showTable($columns);
        $cls_showTableObj->setCanPenetrate($echartSet['can_penetrate']);
        $cls_showTableObj->setChartType($echartSet['chart_type']);
        if($this->params['fromhome']=='yes'){
            $boardid = $this->boardid;
            $sqlstr = $this->getSqlVarExchangeFromHome($reportAllInfo['mainInfo']['sqlstr'],$boardid,$report_id);//获取sql 解析之后的sql 替换了变量的
        }else{
            $sqlstr = $this->getSqlVarExchange($reportAllInfo['mainInfo']['sqlstr']);//获取sql 解析之后的sql 替换了变量的
        }
        $sqlstr = ltrim($sqlstr);//去除sql左侧的字符
        $sqlstr = ltrim($sqlstr,';');//去除sql左侧的分号字符
        $sqlstr_sign = substr($sqlstr,0,4);
        $sqlstr_sign = strtolower($sqlstr_sign);

        $is_procedure = 'no';
        //判断是否是存储过程
        if($sqlstr_sign=='call'){
            $is_procedure='yes';
            //每页条数  第几页的变量处理
        }
        if(!empty($sqlstr)){
            $res = $this->adb->pquery($sqlstr,array());
            $nums = $this->adb->num_rows($res);
        }else{
            $nums = 0;
        }

        $code = 1;
        $errormsg = '';
        $returnsql ='';
        if($nums>0){
            if(count($groupbyInfo)>1&&$echartSet['chart_type']!='simple_sunburst'
                &&$echartSet['chart_type']!='basic_scatter'
                &&$echartSet['chart_type']!='nesting_pie'
                &&$echartSet['chart_type']!='multiple_dimension'){
                //这里应该是多折线 多柱状 折柱混合 柱状堆叠 多条形图 条形堆叠才有
                //默认第一个统计维度作为Y轴刻度，第二统计维度作为不同数据列显示
                $return = $this->twoGroupData($columns[0],$res,$reportAllInfo['chartSet'],$groupbyInfo,$groupbykey);
                if(in_array($echartSet['chart_type'],["stack_strip","simple_strip","multiple_strip"])){
                    $echartSet['yaxis'] = $this->yaxis($echartSet['yaxis'],$return['xdatas']);
                }else{
                    $echartSet['xaxis'] = $this->xaxis($echartSet['xaxis'],$return['xdatas']);
                }
                $series_arr=$return['series'];
                //两个维度的  渲染表格
                $cls_showTableObj->setTotalParams($this->setRowTotal,$this->setColumnTotal,$this->RowTotalDataArr,$this->ColumnTotalDataArr,$this->allTotal);
                $cls_showTableObj->setHeader($return['xdatas']);//设置表格的头
                $cls_showTableObj->showContentTableTwoGroup($series_arr);

            }else {

                //4.根据报表类型  调用不同的数据处理方法
                switch ($charttype) {
                    case 'pie'://空心饼图
                    case 'solid_pie'://实心饼图
                    case 'rose_pie'://玫瑰饼图
                        $return = $this->pieData($columns, $res, $reportAllInfo['chartSet'], $groupbykey);
                        $series_arr = $return['series'];
                        $cls_showTableObj->setTotalParams($this->setRowTotal,'no',$this->RowTotalDataArr,[],$this->allTotal);
                        $cls_showTableObj->setHeader($return['legendData']);//设置表格的头
                        $cls_showTableObj->showContentTable($return['series']);
                        $this->allTotalFormat = $cls_showTableObj->getAllTotalFormat();//汇总金额的格式化
                        $echartSet['xaxis'] = null;
                        $echartSet['yaxis'] = null;
                        break;
                    case 'nesting_pie'://嵌套饼图--可能2个维度
                        $return = $this->pieData($columns, $res, $reportAllInfo['chartSet'], $groupbykey);
                        $series_arr = $return['series'];

                        $cls_showTableObj->setTotalParams($this->setRowTotal,'no',$this->RowTotalDataArr,[],$this->allTotal);
                        $cls_showTableObj->showContentTableNestingPie($return['series'], $groupbyInfo);
                        $echartSet['xaxis'] = null;
                        $echartSet['yaxis'] = null;
                        break;
                    case 'funnel'://梯形漏斗图
                    case 'triangle'://三角形漏斗图
                    case 'bowls'://碗形漏斗图
                        $return = $this->funnelData($columns, $res, $reportAllInfo['chartSet'], $groupbykey);
                        $series_arr = $return['series'];
                        $cls_showTableObj->setTotalParams($this->setRowTotal,'no',$this->RowTotalDataArr,[],$this->allTotal);
                        $cls_showTableObj->setHeader($return['legendData']);//设置表格的头
                        $cls_showTableObj->showContentTable($return['series']);
                        break;
                    case 'simple_sunburst'://旭日图---没有表格--可能2个维度
                        $return = $this->sunburstData($columns,$res, $reportAllInfo['chartSet'],$groupbykey);
                        $series_arr[] = $return['series'];

                        $return_table = $this->twoGroupData($columns[0],$res,$reportAllInfo['chartSet'],$groupbyInfo,$groupbykey);
                        $series_arr_table = $return_table['series'];
                        //两个维度的  渲染表格
                        $cls_showTableObj->setTotalParams($this->setRowTotal,$this->setColumnTotal,$this->RowTotalDataArr,$this->ColumnTotalDataArr,$this->allTotal);
                        $cls_showTableObj->setHeader($return_table['xdatas']);//设置表格的头
                        $cls_showTableObj->showContentTableTwoGroup($series_arr_table);
                        break;
                    case 'basic_scatter'://单维度散点图
                        $scatt_arr = [];
                        $legend = [];
                        foreach ($columns as $tmprowindex => $tmpcolumn) {
                            $return[$tmprowindex] = $this->scatterData($columns, $res, $groupbykey, $tmprowindex, $scatt_arr, $legend);
                        }
                        $series_arr = $this->ResetScatter($groupbyInfo, $scatt_arr);
                        $legend = array_unique($legend);
                        $echartSet['legend'] = $this->legend($echartSet['legend'], $legend, $charttype, $legend_position);

                        //单维度散点图的表格  根据多柱状图数据来处理
                        $return_table = $this->normalData($columns, $res, $reportAllInfo['chartSet'], $groupbykey);
                        $cls_showTableObj->setTotalParams($this->setRowTotal,$this->setColumnTotal,$this->RowTotalDataArr,$this->ColumnTotalDataArr,$this->allTotal);
                        $cls_showTableObj->setHeader($return_table['xdatas']);//设置表格的头
                        $cls_showTableObj->showContentTable($return_table['series']);
                        break;
                    case 'multiple_dimension'://多维度散点图
                        $scatt_arr = [];
                        $legend = [];
                        foreach ($columns as $tmprowindex => $tmpcolumn) {
                            $return[$tmprowindex] = $this->scatterData($columns, $res, $groupbykey, $tmprowindex, $scatt_arr, $legend);
                        }

                        $cls_showTableObj->showContentTable_scatter($scatt_arr);
                        $series_arr = $this->ResetScatter($groupbyInfo, $scatt_arr);
                        $legend = array_unique($legend);
                        $echartSet['legend'] = $this->legend($echartSet['legend'], $legend, $charttype, $legend_position);
                        break;
                    case 'simple_strip'://单条形图
                    case 'multiple_strip'://多条形图
                    case 'stack_strip'://条形堆叠图
                        $return = $this->normalData($columns, $res, $reportAllInfo['chartSet'], $groupbykey);
                        $series_arr = $return['series'];
                        $echartSet['yaxis'] = $this->yaxis($echartSet['yaxis'], $return['xdatas']);
                        $cls_showTableObj->setTotalParams($this->setRowTotal,$this->setColumnTotal,$this->RowTotalDataArr,$this->ColumnTotalDataArr,$this->allTotal);
                        $cls_showTableObj->setHeader($return['xdatas']);//设置表格的头
                        $cls_showTableObj->showContentTable($return['series']);
                        break;
                    default ://柱状图，折线图.柱状堆叠图---只取一个统计维度
                        $return = $this->normalData($columns, $res, $reportAllInfo['chartSet'], $groupbykey);
                        $series_arr = $return['series'];

                        $echartSet['xaxis'] = $this->xaxis($echartSet['xaxis'], $return['xdatas']);
                        $cls_showTableObj->setTotalParams($this->setRowTotal,$this->setColumnTotal,$this->RowTotalDataArr,$this->ColumnTotalDataArr,$this->allTotal);
                        $cls_showTableObj->setHeader($return['xdatas']);//设置表格的头
                        $cls_showTableObj->showContentTable($return['series']);
                        break;
                }
            }
        }
        else{
            if($this->adb->database->ErrorNo()>0){
                $errormsg = "ADODB error ->[".$this->adb->database->ErrorNo()."]".$this->adb->database->ErrorMsg();
                $returnsql = $sqlstr;//返回值SQL  SQL报错的时候返回 方便调试
            }
            $code = 1;
        }

        if($is_procedure == "yes"){
            $res->Close();
        }
        if($echartSet['chart_type']!= 'basic_scatter' ||$echartSet['chart_type']!= 'multiple_dimension')
        {
            $echartSet['legend'] = $this->legend($echartSet['legend'],$return['legendData'],$echartSet['chart_type'],$echartSet['legend_position']);

        }
        $echartSet['th_nums']=$cls_showTableObj->th_nums;

        $echartSet['series']=$series_arr;
        $echartSet['toolbox']=$this->toolbox($echartSet['toolbox'],$echartSet['report_name']);
        $echartSet['option']=$this->option($echartSet);
        if($this->params['fromhome']!='yes') {
            $echartSet['table'] = $cls_showTableObj->getTableHtml();
        }

        $reportAllInfo['code'] = $code;
        $reportAllInfo['errormsg'] = $errormsg;
        $reportAllInfo['returnsql'] = $returnsql;
        $reportAllInfo['chartSet'] = $echartSet;
        $reportAllInfo['fromhome'] = $this->params['fromhome'];

        $reportAllInfo['chartSet']['groupInfo'] = $groupbyInfo;
        $reportAllInfo['chartSet']['totalColumns'] = $columns;
        $reportAllInfo['ChartSetInfo'] = $this->getChartSetInfo($reportAllInfo);
        return $reportAllInfo;
    }

    /**
     * @param $chart_info 统计图信息
     * @return array ChartSetInfo统计图设置信息数组
     */
    public function getChartSetInfo($chart_info){
        $chartInfo = array_merge($chart_info['chartSet'],$chart_info['mainInfo']);
        crm_load_class_file('cls_SqlChartSetInfo','modules/CustomEcharts');
        $ChartSetInfoObj = cls_SqlChartSetInfo::getInstance($chartInfo['report_id'],'sqlchart');
        $ChartSetInfoObj->setChartInfo($chartInfo);
        $ChartSetInfo = $ChartSetInfoObj->getChartSetInfo();
        return $ChartSetInfo;
    }
    /**
     * @param $columns //--只有一个
     * @param $sqlData
     * @param $groupby //--有2个--目前只做2个维度的 也就是只有2层的
     * 旭日图的数据处理--SQL统计图的旭日图
     */
    public function sunburstData($columns,$sqlData,$chartSet,$groupbykey){
        $nums = $this->adb->num_rows($sqlData);
        $realcolumn = $columns[0]['realcolumns'];

        $groupbykey_arr = explode(',',$groupbykey);
        $groupbycolumn0 = $groupbykey_arr[0];//第一个统计维度做内圈
        $groupbycolumn1 = $groupbykey_arr[1];//第二个统计维度做外圈
        $showgroup2 = 'yes';//是否显示第二层
        //zxm @date:2024/12/30 @reason: 特殊开发报表:半导体行业 主要客户分析(出库额)/签约额   不显示第二维度的外圈数据 
        if(in_array($this->primaryname,['bandaoti_mainAccountAnalysis','bandaoti_mainAccountAnalysis_chuku'])){
            $showgroup2 = 'no';
        }
        $data = [];
        $total = 0;
        for($k=0;$k<$nums;$k++){
            $tmptype = $this->adb->query_result($sqlData,$k,'type');
            if($tmptype=='不参与计算'){
                continue;
            }
            $total += $this->adb->query_result($sqlData,$k,$realcolumn);
        }

        for($i=0;$i<$nums;$i++){
            $groupcolumn0 = $this->adb->query_result($sqlData,$i,$groupbycolumn0);
            $groupcolumn1 = $this->adb->query_result($sqlData,$i,$groupbycolumn1);
            $type0 = $this->adb->query_result($sqlData,$i,'type');
            if($type0=='不参与计算'){
                continue;
            }
            if(!isset($data[$groupcolumn0])){
                $data[$groupcolumn0] = [
                    'name'=>$groupcolumn0,
                    'value'=>0,
                    'children'=>[],
                ];
            }
            $tmpvalue = $this->adb->query_result($sqlData,$i,$realcolumn);
            $data[$groupcolumn0]['value'] += (int)$tmpvalue;
            $tmp_percent = 0;
            if($total!=0)$tmp_percent = $data[$groupcolumn0]['value']*100/$total;
            $data[$groupcolumn0]['label'] = array(
                "formatter"=>$groupcolumn0.':'.$data[$groupcolumn0]['value'].'('.round($tmp_percent,2).'%)'
            );
            if($showgroup2=='yes') {
                $data[$groupcolumn0]['children'] = array_values($this->sunburstDataTree($columns,$sqlData,$groupbykey_arr,$groupcolumn0,$total));
            }

        }

        $series['data'] = array_values($data);
        $series['type'] = 'sunburst';
        $series['tooltip'] = array('showw'=>true);
        $series['top'] = '10%';
        $series['nodeClick'] = 'false';
        $series['radius'] = [60, '90%'];
        $series['itemStyle'] = ["borderRadius"=>7, "borderWidth"=>2];
        //$series['label'] = ['show'=>true,'formatter'=>'{b}:{c}','rich'=>''];
        $series = $this->simple_sunburstSeriesSet($series,$chartSet,$total);
        return ['series'=>$series];
    }
    public function sunburstDataTree($columns,$sqlData,$groupbykey_arr,$parentgroup,$total){
        $nums = $this->adb->num_rows($sqlData);
        $realcolumn = $columns[0]['realcolumns'];

        $groupbycolumn0 = $groupbykey_arr[0];//第一个统计维度做内圈
        $groupbycolumn1 = $groupbykey_arr[1];//第二个统计维度做外圈
        $tmpchildren1 = [];
        for ($j = 0; $j < $nums; $j++) {
            $groupcolumn00 = $this->adb->query_result($sqlData, $j, $groupbycolumn0);
            $groupcolumn01 = $this->adb->query_result($sqlData, $j, $groupbycolumn1);
            $type1 = $this->adb->query_result($sqlData,$j,'type');

            if($type1=='不参与计算'){
                continue;
            }
            if ($groupcolumn00 == $parentgroup) {
                if (!isset($tmpchildren1[$groupcolumn01])) {
                    $tmpchildren1[$groupcolumn01] = [
                        'name' => $groupcolumn01,
                        'value' => 0
                    ];
                }
                $tmpvalue2 = $this->adb->query_result($sqlData, $j, $realcolumn);
                $tmpchildren1[$groupcolumn01]['value'] += (int)$tmpvalue2;
                $tmp_percent = 0;
                if($total!=0)$tmp_percent = $tmpchildren1[$groupcolumn01]['value']*100/$total;
                $tmpchildren1[$groupcolumn01]['label'] = array(
                    "formatter"=>$groupcolumn01.':'.$tmpchildren1[$groupcolumn01]['value'].'('.round($tmp_percent,2).'%)'
                );
            }
        }
        return $tmpchildren1;
    }

    //sql解析 解析sql的变量---首页组件
    public function getSqlVarExchangeFromHome($sqlstr,$boardid,$report_id){
        $sqlstr = trim($sqlstr,';');
        if(empty($sqlstr)){
            return $sqlstr;
        }
        $boardstuffid = $this->params['boardstuffid'];
        //变量替换 --新的方式 按看板按组件设置
        //获取设置好的首页数据范围条件
        include_once globalStatic::$root_directory . 'modules/Home/DataRangeHomeboard.php';
        $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($boardid);
        $filterconditionArr = $DataRangeHomeboardObj->boardfilterArr[$this->boardstuffid];
        //变量替换
        $filterArr = $this->getSqlFilter($report_id);
        if(!empty($filterArr)) {
            //edit: xll 2024/02/02 BUG20240201-42 关闭筛选时，替换为默认值
            foreach ($filterArr as $filter) {
                $var_name = $filter['var_name'];
                $tmp_default_value = "";//首页图表 默认值为空
                //查看范围的处理
                if($filter['var_type']=='multiuser') {
                    if(isset($filterconditionArr['usercomponent']) &&$filterconditionArr['usercomponent']['filters']==$filter['id'] &&$filterconditionArr['usercomponent']['isrelated']=='yes'){
                        $tmp_default_value = $this->selectuid;
                    }
                    else {
                        $tmp_default_value = $filter['default_value'];
                    }
                }
                elseif ($filter['var_type']=='date'||$filter['var_type']=='datetime') {
                    if($filterconditionArr['timecomponent1']['isrelated']=='yes'){
                        crm_load_class_file('DateOperation','include');
                        $date_search = DateOperation::getCompareDate($this->search_date);
                        if(isset($filterconditionArr['timecomponent1'])&&$filterconditionArr['timecomponent1']['filters']==$filter['id']&&$filterconditionArr['timecomponent1']['isrelated']=='yes'){
                            $tmp_default_value = $date_search['starttime'];
                        }
                        if(isset($filterconditionArr['timecomponent2'])&&$filterconditionArr['timecomponent2']['filters']==$filter['id']&&$filterconditionArr['timecomponent2']['isrelated']=='yes'){
                            $tmp_default_value = $date_search['endtime'];
                        }
                    }
                    else {
                        $tmp_default_value = explode(',',$filter['default_value'])[1];
                    }
                }
                elseif ($filter['var_type']=='approvestatus') {
                    if(isset($filterconditionArr['approvestatuscomponent']) &&$filterconditionArr['approvestatuscomponent']['filters']==$filter['id'] &&$filterconditionArr['approvestatuscomponent']['isrelated']=='yes'){
                        crm_load_class_file('ReportAnalysisUtils','modules/ReportAnalysis');
                        $tmp_default_value = ReportAnalysisUtils::getSqlReportApprovedValue($this->approve_value);
                    }
                    else {
                        $tmp_default_value = $filter['default_value'];
                    }
                }else{
                    //zxm 20240514 除了人员时间审批之外的条件读取默认值
                    $tmp_default_value = $filter['default_value'];
                }
                $sqlstr = str_replace('{'.$var_name.'}',$tmp_default_value,$sqlstr);
            }
        }
        $sqlstr = ltrim($sqlstr);//去除sql左侧的字符
        return $sqlstr;
    }
    //sql解析 解析sql的变量
    public function getSqlVarExchange($sqlstr){
        $sqlstr = trim($sqlstr,';');
        if(empty($sqlstr)){
            return $sqlstr;
        }
        $report_id = $this->ChartSetInfo['report_id'];
        if(isset($this->params['report_id']) && !empty($this->params['report_id']))
            $report_id = $this->params['report_id'];
        //变量替换
        $filterArr = $this->getSqlFilter($report_id);
        if(!empty($filterArr)){
            foreach($filterArr as $filter){
                $var_name = $filter['var_name'];
                $var_name_pre = "sqlvar_".$var_name;//拼接前缀 防止$this->>params变量名冲突  比如移动端userid就冲突了
                $tmp_default_value = $filter['default_value'];
                $tmp_default_value = empty($tmp_default_value)?'':$tmp_default_value;
                //默认值
                if($filter['var_type']=='date'||$filter['var_type']=='datetime'){
                    $default_value = $filter['default_value'];
                    $default_value_arr = explode(',',$default_value);
                    if($default_value_arr[0]=='selfdefined'){
                        $tmp_default_value = $default_value_arr[1];
                    }else{
                        $tmp_default_value = $this->getFilterDefaultValue($default_value_arr[0]);
                    }
                }
                //界面传过来的值
                if(isset($this->params[$var_name_pre])&&!empty($this->params[$var_name_pre])){
                    $var_name_value = $this->params[$var_name_pre];
                    if($filter['var_type']=='multiselect'||$filter['var_type']=='approvestatus'){
                        $var_name_value = implode(',',$var_name_value);
                    }
                    $tmp_default_value = $var_name_value;
                }
                //用户
                if($filter['var_type']=='multiuser'){
                    $scopeobj = new ScopOfAuthority($this->adb,$filter['modulename']);
                    $tmp_default_value = $scopeobj->getCurUserScopeIds();
                    $var_value_multiuser = $this->params[$var_name_pre];
                    if(!empty($var_value_multiuser)){
                        $tmp_default_value = $var_value_multiuser;
                    }
                }
                //审批组件的处理
                /*if($filter['var_type']=='approvestatus'){
                    $approvestatus_value = $this->>params[$var_name_pre];
                    if(!empty($var_name_pre)){
                        $tmp_default_value = implode(',',$approvestatus_value);
                    }else{
                        $tmp_default_value = '';
                    }
                    $tmp_default_value = trim($tmp_default_value);
                }*/
                $sqlstr = str_replace('{'.$var_name.'}',$tmp_default_value,$sqlstr);
            }
        }
        $sqlstr = ltrim($sqlstr);//去除sql左侧的字符
        return $sqlstr;
    }




    //勾选创建链接模块
    public function createLinkModule($report_name,$report_id,$linkmodulecheck){
        global $currentModule, $current_user;
        $url = 'index.php?module='.$currentModule.'&action='.$currentModule.'Ajax&file=SqlEchartsDetailView&function_name=getChart&isAjax=no&report_id='.$report_id.'&report_type=sqlchart';
        if($linkmodulecheck=='yes'){
            $sql ='select * from ld_linkmodulecustom where url =?';
            $result = $this->adb->pquery($sql,array($url));
            $nums = $this->adb->num_rows($result);

            if($nums>0){  //设置里面自己添加的自定义模块
                $sql='update ld_linkmodulecustom set zh_label=? ,en_label=? ,`scope`=? where url=?';
                $this->adb->pquery($sql,array($report_name,$report_name,'all',$url));
            }else{
                $sql='insert into ld_linkmodulecustom(zh_label,en_label,url,`scope`,entitytype,linkmodule)value(?,?,?,?,?,?) ';
                $this->adb->pquery($sql,array($report_name,$report_name,$url,'all','category','CustomEcharts'));
                $id = $this->adb->getLastInsertID();
                $this->adb->pquery("update ld_linkmodulecustom set name=? where id=?",array("CRMLinkModuleCustom".$id,$id));
            }
        }else{
            //删除菜单设置
            $selectSql = "select * from ld_linkmodulecustom where url =?";
            $selectRes = $this->adb->pquery($selectSql,array($url));
            $selectNums = $this->adb->num_rows($selectRes);
            if($selectNums>0){
                $linkmoduleId = $this->adb->query_result($selectRes,0,'id');
                //ld_parenttabrel
                $sql ='delete from ld_linkmodulecustom where url =?';
                $this->adb->pquery($sql,array($url));
                $sql2 ='delete from ld_parenttabrel where tabid =? and tab_tablename="ld_linkmodulecustom"';
                $this->adb->pquery($sql2,array($linkmoduleId));
                //移动端菜单
                $sqlMobile = "delete from ld_mobile_report_tab_rel where tabid =? and tab_tablename='ld_linkmodulecustom'";
                $this->adb->pquery($sqlMobile,array($linkmoduleId));
            }

        }
        //zxm 20230901 修改模块名称需要把拼音模糊搜索的缓存清除掉
        unsetCache('pinyinAlllabel_zh');
        unsetCache('pinyinAlllabel_en');
    }

    //echarts 保存样式设置信息
    public function setChartSet(){
        parent::setChartSet();
    }
    public function getModuleArr()
    {
        $query="SELECT
        	ld_tab.tabid,
        	ld_tranlabel.fieldlabel AS newtabname,
        	ld_tab.presence,
        	ld_tab.customized,
        	languagetype,
        	ld_tab.description,
        	ld_tab.name
        FROM
        	ld_tab
        INNER JOIN ld_tranlabel ON ld_tab.tabid = ld_tranlabel.relateid
        WHERE
            languagetype = '".$this->language."'
        AND trantable = 'ld_tab'
        AND ld_tab. NAME NOT IN ($this->except)
        AND ld_tab.presence = 0
        GROUP BY
        	ld_tab.tabid,
        	languagetype,
        	tabid
        ORDER BY
        	ld_tab.tabsequence ASC";

        $result = $this->adb->query($query);
        $num_rows=$this->adb->num_rows($result);
        $alltabs = [
            [
                'presence'=>'-1',
                'customized'=>'0',
                'name'=>'',
                'modulename'=>'',
                'description'=>''
            ]
        ];
        for($i=0;$i<$num_rows;$i++){
            $name = $this->adb->query_result($result,$i,'name');
            if(isPermitted($name,'index') == 'yes'&&vtlib_isModuleActive($name)){
                //zxm 20240816  用户组件的下拉框模块  不要判断是否有下拉框字段
                //$focus = CRMEntity::getInstance($name);
                //if(!empty($focus->fieldobj)){
                    //$fieldinfo_arr=$focus->fieldobj->getFieldInfoobjBykey_arr("bigtype",'picklist');
                    //if(!empty($fieldinfo_arr)) {
                        $tabid = $this->adb->query_result($result, $i, 'tabid');
                        $alltabs[$tabid]['presence'] = $this->adb->query_result($result, $i, 'presence');
                        $alltabs[$tabid]['customized'] = $this->adb->query_result($result, $i, 'customized');
                        $alltabs[$tabid]['name'] = $this->adb->query_result($result, $i, 'newtabname');
                        $alltabs[$tabid]['modulename'] = $name;
                        $description = $this->adb->query_result($result, $i, 'description');
                        if (!empty($description)) {
                            $alltabs[$tabid]['description'] = getFixedLabel($description);
                        } else {
                            $alltabs[$tabid]['description'] = '';
                        }
                    //}
                //}
            }
        }
        return $alltabs;
    }
    //获取模块的下拉框字段
    public function getPickListsByModule($modulename){
        $focus = CRMEntity::getInstance($modulename);
        $fieldinfo_arr=$focus->fieldobj->getFieldInfoobjBykey_arr("bigtype",'picklist');
        //分录的下拉框字段也要显示出来
        if((get_file_address($modulename,"ProductDetails") or !empty($focus->detailfieldobj) )&&$modulename!='ServiceCharge'){
            $detailfieldinfo_arr = $focus->detailfieldobj->getFieldInfoobjBykey_arr("bigtype",'picklist');
            $fieldinfo_arr = array_merge($fieldinfo_arr,$detailfieldinfo_arr);
        }
        crm_load_class_file("cls_PickList", 'modules/PickList');
        $objpinklist = new cls_PickList();

        $tempOption = [];
        crm_load_class_file('PickListUtils','modules/PickList');
        foreach($fieldinfo_arr as $fieldInfo)
        {
            if($focus->module_name=='Accounts'&&($fieldInfo->getTableName()=='ld_contactdetails'||$fieldInfo->getTableName()=='ld_contactscf'))
                continue;
            $label = $fieldInfo->getFieldLabel();
            $typeOfData = $fieldInfo->getTypeOfData();
            $typeOfData = explode('~',$typeOfData);
            $bigtype = $fieldInfo->getBigType();
            if ($bigtype == 'qrcode') continue;
            $optionValue = $fieldInfo->getTableName() . ":" . $fieldInfo->getColumnName() . ":" . $fieldInfo->getFieldName() . ":" . $modulename . "_" . $fieldInfo->getFieldLabel() . ":" . $typeOfData[0];
            //$picklists = getAllPickListValues($fieldInfo->getFieldName());
            $picklists = $objpinklist->getPickListValues($fieldInfo->getFieldName(),$fieldInfo,array(),'');
            $tempOption[] = [
                'bigtype'=>$bigtype,
                'value'=>$optionValue,
                'label'=>$label,
                'columnmodule'=>$modulename,
                'columnname'=>$fieldInfo->getColumnName(),
                'picklists'=>$picklists,
                'picklist_str'=>implode(',',$picklists),
                'typeofdata'=>$typeOfData[0],
                'detailField'=>"no"];
        }

        return $tempOption;
    }

    public function getFilterDefaultValue($timename){
        crm_load_class_file('ReportAnalysisUtils','modules/ReportAnalysis');
        return ReportAnalysisUtils::getFilterDefaultValue($timename);
    }
    //初始信息
    public function getChartSetInfoDefault(){
        $ChartSetInfo = [
            'report_id' => '',
            //'chart_type'=>'bar',
            'show_percent'=>'no',
            'funnel_type'=>'',
            'legend_position'=>'RightTop',
            'themename'=>'default',
            'report_name'=>'',
            'report_desc'=>'',
            'report_type'=>'chart',
            'parent_id'=>'',
            'show_athome'=>'no',

            'show_rowtotal'=>'no',
            'show_columntotal'=>'no',
            'show_columntotal_inchart'=>'no',
            'show_alltotal_inchart'=>'no',

            'linkmodulecheck'=>'no',
            'can_penetrate'=>'no',
            'show_toolbox'=>'no',
            'relatedmodule'=> [],
            'sequence'=>'',
            'isshow_table'=>'Bottom',
            'analysisfolder_id'=>'1',
            'show_athome_info'=>[],
            'table'=>'',
            'chart_type_name'=>'',
            'AxisFields' => [
                'XAxis' => [],
                'YAxis' => [],
            ],
            'OtherCondition' => [
                'computemodule' => '',
                'advance_demand' => '',
                'advance_demand_groups' => '',
            ],
            'sqlstr_origin' => '',
            'TitleSwitch' => '',
            'LegendOrient' => '',
            'mode' => 'create',
        ];
        return $ChartSetInfo;
    }
}