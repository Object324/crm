<?php

include_once globalStatic::$root_directory.'modules/CustomEcharts/EchartSetting.php';
include_once globalStatic::$root_directory.'modules/CustomEcharts/cls_showTable.php';
crm_load_class_file("cls_TableJoin_module",'include/fields');
class EchartReport extends EchartSetting
{
    public $columntype;
    public $focus;
    public $fieldobj;

    public $tables=[];//弃用
    public $groupbytables=[];//统计维度涉及到的表
    public $columnstables=[];//统计字段涉及到的表 按字段
    public $relatedmoduletables=[];//相关模块涉及到的表
    public $joinTable='';//弃用
    public $groupbyjoinTable='';//统计维度需要连的表
    public $columnsjoinTable=[];//统计字段需要连的表 按字段

    public $field;
    public $groupby;
    public $sorting_list; //排序数组 zxm 20220818
    public $sorting_list_default; //排序数组--默认 没有设置排序的时候 默认以排序字段排序 zxm 20220913

    public $groupcolumns;
    public $groupInfo;//GROUPBY 信息
    public $groupCondition;
    public $mainmodule;
    public $relatedmodule;
    public $relatemoduleJoinSql_arr;//关联模块sql
    public $relatemoduleWhereSql_arr;//关联模块的查询
    public $relatemoduleColumn_arr;
    public $relatemoduleJoinTable_arr;
    public $rowfield_arr=[];
    public $rowfieldalias_arr=[];//数据列别名
    public $compare_select_arr=[];//同环比选项

 
 
    public $SeqSet;
    public $columns;
    public $field_arr = [];
    public $advanceInfo;
    public $DependentFieldsList = [];

    public $timeRange=[];//以时间字段为分组字段时  时间的范围
    public $prevAdvanceInfo=[];//环比上期的高级条件
    public $prev_lastyearAdvanceInfo = [];//同比上期的高级条件
    public $groupby_prev = '';//环比上期的 分组字段
    public $groupby_prev_lastyear = '';//同比上期的 分组字段
    public $newtotal_columns_unique = [];

    public function __construct($params)
    {
        parent::__construct($params);
        $this->relatemoduleColumn_arr=[];
        $this->relatemoduleJoinSql_arr=[];
        $this->relatemoduleWhereSql_arr=[];
        $this->relatemoduleJoinTable_arr=[];
    }
    /**
     * @param $module
     * @param $fieldName
     * @return array
     * @throws Exception
     * 旭日图 需要获取级联字段的上下级字段名称  --旭日图暂只支持三级
     */
    public function getDependentFields($module,$fieldName){
        global $adb;
        $dependentPicklistsField=[];
        $this->DependentFieldsList = [];
        $tmpfieldname=$fieldName;
        $tabId = getTabid($module);
        $i=0;
        while(true)
        {
                $sql="SELECT DISTINCT
                	sourcefield,
                	targetfield,
                	ld_picklist_dependency.tabid
                FROM
                	ld_picklist_dependency
                LEFT JOIN ld_tab ON ld_tab.tabid = ld_picklist_dependency.tabid
                WHERE
                	ld_picklist_dependency.tabid = ?
                AND ld_tab.presence IN (0, 2) and targetfield=? limit 1 ";
            $result=$adb->pquery($sql,array($tabId,$tmpfieldname));
            $rows=$adb->num_rows($result);

            if($rows>0)
            {
                $temp=[];
                $sourcefield = $this->adb->query_result($result, 0, 'sourcefield');//上级
                $targetfield = $this->adb->query_result($result, 0, 'targetfield');//下级
                $tmpfieldname=$sourcefield;
                $temp['fieldname'] = $sourcefield;
                $temp['tablename'] = getTableNameForField($module,$sourcefield);
                $dependentPicklistsField[$sourcefield]=$temp;
                $this->DependentFieldsList[] = $temp;
            }
            else{
                break;
            }
           $i++;
           if($i>1)
           {
            break;
           }
        }
        $this->DependentFieldsList = array_reverse($this->DependentFieldsList);
        $dependentPicklistsField=array_reverse($dependentPicklistsField);
        return $dependentPicklistsField;
    }
    public function generalReportChart1($report_id)
    {
        global $adb;
        $echartSet = $this->getEchartSet($report_id);//统计图样式设置信息
        $report_info = $this->getReportInfo($report_id);//统计图字段配置信息 条件配置信息
        $echartSet = array_merge($echartSet, $report_info);
        $this->mainmodule = $report_info['mainmodule'];
        $this->focus = CRMEntity::getInstance($this->mainmodule);
        $this->fieldobj = $this->focus->fieldobj;
        $groupby = $this->getGroupByData($report_id);
        $echartSet['groupInfo'] = $groupby;
        return $echartSet;
    }
    /**
     * @param $report_id
     * @return array
     * @throws Exception
     * 获取统计图信息
     */
    public function generalReportChart($report_id)
    {
        global $adb;
        $echartSet = $this->getEchartSet($report_id);//统计图样式设置信息
        $report_info = $this->getReportInfo($report_id);//统计图字段配置信息 条件配置信息
        $echartSet = array_merge($echartSet,$report_info);
        $this->mainmodule = $report_info['mainmodule'];
        $this->focus = CRMEntity::getInstance($this->mainmodule);
        $this->fieldobj = $this->focus->fieldobj;
        $this->groupbytables = [$this->focus->table_name];

        $this->joinTable= ' ';

        $this->getSortingColumn($report_id);//2022-0818 zxm
        $echartSet['SeqSet'] = $this->SeqSet;   //排序设置
        $datarangesql = $this->getDataRangSql($this->mainmodule, $this->focus->table_name);


        $sql="select GROUP_CONCAT(column_module) from ld_customreport_total_column where report_id=? and column_module<>? ";
        $result=$adb->pquery($sql,array($report_id,$this->mainmodule));
        if($adb->num_rows($result)>0)
        {
            $this->relatedmodule=$adb->query_result($result,0,0);//多个模块之间用逗号分割
        }

        if(!empty($this->relatedmodule))
        {
            $relatemodule_arr=explode(",",$this->relatedmodule);
            foreach($relatemodule_arr as $tmprelatemodule)
            {
                $this->relatedmoduletables[$tmprelatemodule] = [];
                $relatetablejoinobj=  cls_TableJoin_module::getInstance($this->mainmodule,$tmprelatemodule);
                $tmpjoin_arr=  $relatetablejoinobj->getJoin();

                // $this->joinTable.= $tmpjoin_arr['joinsqltype'].$tmpjoin_arr['joinsql'];
                if(!in_array($tmpjoin_arr['jointable'][0],$this->relatedmoduletables[$tmprelatemodule]))
                {
                    $this->relatemoduleJoinSql_arr[$tmprelatemodule][]=$tmpjoin_arr;
                    $this->relatemoduleJoinTable_arr=array_merge($this->relatemoduleJoinTable_arr,$tmpjoin_arr['jointable']);
                    //generalReportChart 函数
                    $this->relatedmoduletables[$tmprelatemodule]=array_merge($this->relatedmoduletables[$tmprelatemodule],$tmpjoin_arr['jointable']);
                }

                //edit: xll 2024/01/08 BUG0078418 通用问题。新建多柱状图和柱状堆叠图时，Y轴的统计字段选择两个时，统计图无法显示出值
                $relatefocus=CRMEntity::getInstance($tmprelatemodule);
                if(!in_array($relatefocus->table_name,$this->relatedmoduletables[$tmprelatemodule]))
                {
                    $tmpjoin_arr= $relatetablejoinobj->getRelatedJoinSql($relatefocus->table_name);
                   if(!empty($tmpjoin_arr['joinsql'])) {
                       //zxm 选择产品 为主模块 求和选合同订单--求和价税合计  则把已删除的订单的价税合计也计算进去了  故加这一行
                       $tmpjoin_arr['joinsql'] = $tmpjoin_arr['joinsql'] . ' and ' . $relatefocus->table_name . '.deleted=0';
                       $this->relatemoduleJoinSql_arr[$tmprelatemodule][] = $tmpjoin_arr;//' left join '.$tmpjoin_arr['joinsql'];
                       $this->relatemoduleJoinTable_arr[] = $relatefocus->table_name;
                       //edit: xll 2024/03/22 $tmpjoin_arr['jointable'] 是数组
                       $this->relatedmoduletables[$tmprelatemodule] = array_merge($this->relatedmoduletables[$tmprelatemodule], $tmpjoin_arr['jointable']);

                   }
                }
                //generalReportChart 函数
                $this->relatemoduleWhereSql_arr[$tmprelatemodule][]=' and '.$relatefocus->table_name.'.deleted=0';
            }
        }
        $groupby = $this->getGroupBy($report_id,$echartSet['mainmodule'],$echartSet['chart_type']);//数组 需要用，连接
        $echartSet['groupInfo'] = $this->groupInfo;


        $groupby = array_values($groupby);
        $groupbykey_arr = [];
        $unionsumcolumnname='';
        foreach($groupby as $key=>$g){
            $temp_arr = explode(' as ',$g);
            $groupbykey_arr[] = $temp_arr[1];
        }
        $groupbykey = implode(',',$groupbykey_arr);
        $groupbyfield = implode(',',$groupby);//一定是主模块

        $columns = $this->getTotalColumn($report_id);
        //$this->columns = $columns;

        $echartSet['totalColumns'] = $this->columns;

        $this->field_arr=$this->rowfield_arr[0];//排序以第一行为基准
        $orderby_type = $echartSet['orderby_type'];
        $orderby_type = empty($orderby_type)?'desc':$orderby_type;
        $is_search = $this->params['is_search'];
        $fromhome = $this->params['fromhome'];
        $cvadvfilter_condition = ' where '.$this->focus->table_name.'.deleted=0 ';


        if($is_search == 'yes'){
            $this->advanceInfo = [
                'advance_demand' => $this->params['advance_demand'],
                'advance_demand_groups' => $this->params['advance_demand_groups'],
            ];
            //$cvadvfilter_condition .= ' '.$this->getCvadvfilterFromPage();
        }
        else{
            $this->advanceInfo = [
                'advance_demand' => $echartSet['advance_demand'],
                'advance_demand_groups' => $echartSet['advance_demand_groups'],
            ];
            //$cvadvfilter_condition .= ' '.$this->getCvadvfilter($fromhome,$report_id);
        }
        if(count($this->groupInfo)==1&&$this->groupInfo[0]['groupbytype'] != "byField"&&$echartSet['chart_type']!='simple_sunburst') {
            //获取高级查找里面第一个分组时间字段时间范围
            $this->timeRange = $this->getFirstAdvTimeRange($this->groupInfo[0], $this->advanceInfo);//获取当期 上期 同比上期时间区间
        }

        //这里暂时不需要 在后面根据是不是看板组件来判断了
        //$cvadvfilter_where = $this->getHightSearchWhereSql();
        //$this->joinTable .= $cvadvfilter_where;

        $cls_showTableObj = new cls_showTable($columns);
        $cls_showTableObj->setCanPenetrate($echartSet['can_penetrate']);
        $cls_showTableObj->setChartType($echartSet['chart_type']);

        $echartSet['groupCondition'] = $this->groupCondition;

        $limit = $echartSet['limit'];
        if(count($groupby)==1&&!empty($limit)){
            $limit_sql = " limit 0,$limit ";
        }else{
            $limit = 0;
            $limit_sql = ' ';
        }

        //edit: xll 2024/01/08 BUG0078418 通用问题。新建多柱状图和柱状堆叠图时，Y轴的统计字段选择两个时，统计图无法显示出值
        if(is_string($this->relatedmodule))
         $relatemodule_arr=explode(",",$this->relatedmodule);
        else
            $relatemodule_arr=[];
        $series_arr=[];
        $scatt_arr=[];

        $list_query_arr_all=[];//该报表所有的sql 在这个数组里
        $right_joinsql="";


        //获取排序
        $sorting_list_alias=[]; //排序数组 zxm 20220818
        foreach($this->sorting_list as $sortvalue){
            if(isset($sortvalue['alias'])&&!empty($sortvalue['alias'])){
                $sorting_list_alias[$sortvalue['alias']] = $sortvalue['alias_sortmethod'];
            }
        }
        $orderby_field_str = '';
        if(!empty($this->sorting_list_default)){
            $sorting_list_default = _array_column($this->sorting_list_default,'alias_sortmethod');
            $orderby_field_str = "  order by ".implode(',',$sorting_list_default);
        }
        $tmpcompare_field= '';
        $rowfieldalias_str = implode(',',$this->rowfieldalias_arr);
        foreach($this->rowfield_arr as $tmprowindex=>$tmprowfieldinfo)
        {
            $list_query_arr=[];
            $this->field_arr=$tmprowfieldinfo;
            $orderby_field_str = '';
            if(!empty($orderby_type)){
                $orderby_field = [];

                $key_module_arr=array_keys($this->field_arr);
                foreach($this->field_arr[$key_module_arr[0]] as $kk=>$f){
                    $f = explode(' as ',$f);
                    //新的排序zxm 20220825
                    $temp_sort_arr = [];
                    if(!empty($sorting_list_alias)){
                        foreach($sorting_list_alias as $sk=>$sv){
                            /*if($sk=='groupcolumn0'||$sk=='groupcolumn1'){
                                $sv = 'query0.'.$sv;
                            }*/
                            $temp_sort_arr[] = $sv;
                            if($sk==$f[1]){
                                break;
                            }
                        }
                    }

                    $orderby_field[$kk] = $f[1];
                    if($kk==0)
                    {
                        $unionsumcolumnname=$f[1];
                    }
                }
                /* $orderby_field_str = implode(',',$orderby_field);
                 $orderby_field_str = "  order by ".$orderby_field_str.' '.$orderby_type;//查询结果排序--旧的 不要了*/
                //新的排序zxm 20220825
                if(!empty($temp_sort_arr)){
                    $orderby_field_str = implode(',',$temp_sort_arr);
                    $orderby_field_str = "  order by ".$orderby_field_str;//查询结果排序
                }
            }

            $relatemodule_arr=array_unique($relatemodule_arr);

            $tmpcompareselect = $this->compare_select_arr[$tmprowindex];

            $curtmp_uniquearr = $this->newtotal_columns_unique[$tmprowindex];
            foreach($this->newtotal_columns_unique as $kk=>$tmpuniquekey){
                if($tmpuniquekey[0]==$curtmp_uniquearr[0]&&$tmpuniquekey[1]==$curtmp_uniquearr[1]&&$tmpuniquekey[3]==$curtmp_uniquearr[3]&&$tmpuniquekey[2]=='cur'){
                    $tmpcurindex = $kk;
                }
                if($tmpuniquekey[0]==$curtmp_uniquearr[0]&&$tmpuniquekey[1]==$curtmp_uniquearr[1]&&$tmpuniquekey[3]==$curtmp_uniquearr[3]&&$tmpuniquekey[2]=='prev'){
                    $tmpprevindex = $kk;
                }
                if($tmpuniquekey[0]==$curtmp_uniquearr[0]&&$tmpuniquekey[1]==$curtmp_uniquearr[1]&&$tmpuniquekey[3]==$curtmp_uniquearr[3]&&$tmpuniquekey[2]=='prev_lastyear'){
                    $tmpprev_lastyearindex = $kk;
                }
            }
            /*if($tmpcompareselect=='cur'){
                $tmpcurindex = $tmprowindex;
            }
            if($tmpcompareselect=='prev'){
                $tmpprevindex = $tmprowindex;
            }
            if($tmpcompareselect=='prev_lastyear'){
                $tmpprev_lastyearindex = $tmprowindex;
            }*/
            //$tmpcurindex =array_search('cur',$this->compare_select_arr);

            //if(in_array('prev_growth',$this->compare_select_arr)){
            if($tmpcompareselect=='prev_growth'){
                //$tmpprevindex =array_search('prev',$this->compare_select_arr);
                $tmpcompare_field.=',ifnull(co'.$tmpcurindex.'_cur,0)-ifnull(co'.$tmpprevindex.'_prev,0) as co'.$tmprowindex;

            }
            //if(in_array('prev_growth_percent',$this->compare_select_arr)){
            if($tmpcompareselect=='prev_growth_percent'){
                //$tmpprevindex =array_search('prev',$this->compare_select_arr);
                $tmpcompare_field.=',(case when ifnull(co'.$tmpprevindex.'_prev,0)=0 then 100 else (ifnull(co'.$tmpcurindex.'_cur,0)-ifnull(co'.$tmpprevindex.'_prev,0))*100/ifnull(co'.$tmpprevindex.'_prev,0) end ) as co'.$tmprowindex;

            }
            //if(in_array('prev_growth_lastyear',$this->compare_select_arr)){
            if($tmpcompareselect=='prev_growth_lastyear'){
                //$tmpprev_lastyearindex =array_search('prev_lastyear',$this->compare_select_arr);
                $tmpcompare_field.=',ifnull(co'.$tmpcurindex.'_cur,0)-ifnull(co'.$tmpprev_lastyearindex.'_prev_lastyear,0) as co'.$tmprowindex;
            }
            //if(in_array('prev_growth_percent_lastyear',$this->compare_select_arr)){
            if($tmpcompareselect=='prev_growth_percent_lastyear'){
                //$tmpprev_lastyearindex =array_search('prev_lastyear',$this->compare_select_arr);
                $tmpcompare_field.=',(case when ifnull(co'.$tmpprev_lastyearindex.'_prev_lastyear,0)=0 then 100 else (ifnull(co'.$tmpcurindex.'_cur,0)-ifnull(co'.$tmpprev_lastyearindex.'_prev_lastyear,0))*100/ifnull(co'.$tmpprev_lastyearindex.'_prev_lastyear,0) end ) as co'.$tmprowindex;
            }
            /*if(in_array($tmpcompareselect,['prev_growth','prev_growth_percent','prev_growth_lastyear','prev_growth_percent_lastyear'])){
                continue;
            }*/


            foreach($this->field_arr as $tmpmodule=>$tmpfield_arr)
            {

                $field=implode(",",$tmpfield_arr);

                if($tmpcompareselect=='prev'&&!empty($this->groupby_prev)){
                    $tmpgroupby_prev_arr = explode(' as ',$this->groupby_prev);
                    $groupbykey = $tmpgroupby_prev_arr[1];
                    $groupbyfield_new = $this->groupby_prev;
                }else if($tmpcompareselect=='prev_lastyear'&&!empty($this->groupby_prev_lastyear)){
                    $tmpgroupby_prev_lastyear_arr = explode(' as ',$this->groupby_prev_lastyear);
                    $groupbykey = $tmpgroupby_prev_lastyear_arr[1];
                    $groupbyfield_new = $this->groupby_prev_lastyear;
                }else{
                    $groupbyfield_new = $groupbyfield;
                }

                if($fromhome=='yes'){
                    //自定义统计图放首页 需要接收首页看板设置的高级查找条件,首页的数据范围设置时间控制字段,以及自定义图本身设置的高级查找条件
                    $advanceInfo = $this->advanceInfo;
                    $advance_demand = $advanceInfo['advance_demand'];
                    $advance_demand_groups = $advanceInfo['advance_demand_groups'];
                    $advanceinput['advft_criteria'] = $advance_demand;
                    $advanceinput['advft_criteria_groups'] = $advance_demand_groups;
                    $advanceinput['searchtype'] = 'advance';
                    $this->timeRange = [];
                    $tmpconditionsql = $this->getCvadvfilterFromHomeNew($this->boardid,$report_id,$this->boardstuffid,$advanceinput,$tmpmodule,$this->mainmodule,$tmpcompareselect);

                }else {
                    //单独的自定义统计图  只需要处理自定义图本身的高级查找条件即可
                    $tmpconditionsql = $this->getHightSearchWhereSql($tmpcompareselect);
                }

                $query = "select $field, $groupbyfield_new from ".$this->focus->table_name;


                //zxm 20230524 增加一句sql $query_forbytime 只用来给时间分组的方法使用 {groupbytimefield}用来解析的时候做变量替换
                $query_forbytime = "select {groupbytimefield} from ".$this->focus->table_name ;

                //zxm 20231025 如果是首页组件  则不需要这个数据范围  首页看板有自己的数据范围控制
                //zxm 20240729 首页老看板 数据范围跟主模块  另外如果有首页的条件控制再加首页的条件控制
                if($fromhome!='yes'||$this->boardid<=0) {
                    $query .= $datarangesql;
                    $query_forbytime .= $datarangesql;
                }

                //20230314
                //foreach($relatemodule_arr as $tmprelatemodule)

                $tmprelatemodule = $key_module_arr[0];//zxm 20231130 统计字段是相关模块的才需要连相关模块,不然主表字段的统计值会重复计算

                foreach($this->relatemoduleJoinSql_arr[$tmprelatemodule] as $joinsqlinfo_arr)
                {
                    if ($echartSet['chart_type'] == 'basic_scatter' || $echartSet['chart_type'] == 'multiple_dimension') {
                        $joinsqlinfo_arr['joinsqltype'] = ' inner join ';
                    }
                    if (!empty($joinsqlinfo_arr['joinsql'])){
                        $query .= $joinsqlinfo_arr['joinsqltype'] . ' ' . $joinsqlinfo_arr['joinsql'];
                        $query_forbytime .= $joinsqlinfo_arr['joinsqltype'] . ' ' . $joinsqlinfo_arr['joinsql'];
                    }
                }
                //$query.= $this->joinTable ;
                //$query_forbytime.= $this->joinTable ;

                $query.= $this->columnsjoinTable[$tmprowindex] ;
                $query_forbytime.= $this->columnsjoinTable[$tmprowindex] ;

                if($fromhome=='yes'){
                    $query.=$tmpconditionsql;
                    //zxm BUG0075695   报表分析--统计图--设置条件时间为去年，报表显示的X轴依旧是今年 --用来组装时间区间的SQL没拼条件
                    $query_forbytime.=$tmpconditionsql;
                }else{
                    $query.= $tmpconditionsql;
                    //zxm BUG0075695   报表分析--统计图--设置条件时间为去年，报表显示的X轴依旧是今年 --用来组装时间区间的SQL没拼条件
                    $query_forbytime.= $tmpconditionsql;

                }

                //$query.=$cvadvfilter_condition;
                //$query_forbytime.=$cvadvfilter_condition;

                $query.=" group by ".$groupbykey ;

                //一个统计维度 且是时间字段 且不是旭日图
                if(count($this->groupInfo)==1&&$this->groupInfo[0]['groupbytype'] != "byField"&&$echartSet['chart_type']!='simple_sunburst'){
                    $limit_sql = "";
                    $tempfields = [];
                    foreach($tmpfield_arr as $tempfield){
                        $tempfield = explode(' as ',$tempfield);
                        $tempfields[] = 'b.'.$tempfield[1];

                        if($tmpcompareselect=='cur'&&strpos($tempfield[1],'_cur')==false){
                            $tempfields[] = 'b.'.$tempfield[1].' as co'.$tmpcurindex.'_cur';
                        }
                        if($tmpcompareselect=='prev'&&strpos($tempfield[1],'_prev')==false){
                            $tempfields[] = 'b.'.$tempfield[1].' as co'.$tmpprevindex.'_prev';
                        }
                        if($tmpcompareselect=='prev_lastyear'&&strpos($tempfield[1],'_prev_lastyear')==false){
                            $tempfields[] = 'b.'.$tempfield[1].' as co'.$tmpprev_lastyearindex.'_prev_lastyear';
                        }


                    }
                    $tempfields = implode(',',$tempfields);
                    $tempfields = ','.$tempfields;

                    if(in_array($tmpcompareselect,['prev_growth','prev_growth_percent','prev_growth_lastyear','prev_growth_percent_lastyear'])){
                        $tempfields = '';
                    }
                    //一个统计维度 且是时间字段 且不是旭日图
                    $seq_sql = $this->getSeqNew($this->groupInfo[0],$limit,$query_forbytime);
                    $temp_list_query = "select a.target_period as groupcolumn0 $tempfields from ($seq_sql) as a left join ($query) as b on a.target_period=b.groupcolumn0 " ;
                    /*if(in_array($tmpcompareselect,['prev_growth','prev_growth_percent','prev_growth_lastyear','prev_growth_percent_lastyear'])){
                        $temp_list_query = '';
                    }*/
                    $list_query_arr[] = $temp_list_query;
                    $list_query_arr_all[$tmprowindex] = $temp_list_query ;

                    //$orderby_field_str=' order by a.groupcolumn0 asc ';

                }
                else if($echartSet['chart_type']=='simple_sunburst'){
                    //旭日图 特殊的sql  根据级联字段先后关系依次减少group by 字段
                    $child_sql = [];
                    $treeWhere = [];

                    foreach($groupby as $gk=>$gv){
                        //拼接group by
                        $temp = [];
                        for($i=0;$i<=$gk;$i++){
                            $sunburstgroup = explode(" as ",$groupby[$i]);
                            $temp[] = $sunburstgroup[1];
                        }
                        //$temp = implode(',',$temp);
                        $child_sql[$gk] = "select $field, $groupbyfield_new,".$gk." as sunbursttype from ".$this->focus->table_name." ".$this->columnsjoinTable[$tmprowindex]." $cvadvfilter_condition group by ".$temp[$gk] ;
                        if($gk!=0){
                            $treeWhere[] = "groupcolumn".$gk." !='无'";
                        }
                    }
                    $treeWhere = empty($treeWhere)?'':' where '.implode(' and ',$treeWhere);
                    $child_sql = implode(' union all ',$child_sql);
                    $temp_list_query = "select * from ($child_sql) as temp ".$treeWhere;
                    $list_query_arr[] = $temp_list_query;
                    $list_query_arr_all[$tmprowindex] = $temp_list_query;

                }
                else{
                    $list_query_arr[] = $query;
                    $list_query_arr_all[$tmprowindex] = $query;
                }
            }
            $list_query=$list_query_arr[0];

            //zxm 20220825 新的排序  拼接sql

            if($tmprowindex==0){

                if(count($this->groupInfo)==1&&$this->groupInfo[0]['groupbytype'] != "byField"&&$echartSet['chart_type']!='simple_sunburst'){
                    $list_query = "select   * $tmpcompare_field from ($list_query) as query".$tmprowindex;
                    if(in_array($tmpcompareselect,['prev_growth','prev_growth_percent','prev_growth_lastyear','prev_growth_percent_lastyear'])){
                        $orderby_field_str = ' order by a.target_period  asc ';
                    }
                }else{
                    $list_query = "select  * $tmpcompare_field from ($list_query) as query".$tmprowindex;
                    if(in_array($echartSet['chart_type'],['pie','solid_pie','rose_pie','nesting_pie'])){
                        $orderby_field_str = ' order by query'.$tmprowindex.'.co0 desc ';
                    }
                }
            }
            else{
                $sencond_join = '';
                if(count($this->groupInfo)==2)
                {
                    $sencond_join = "  and query".($tmprowindex-1).".groupcolumn1 = query".$tmprowindex.".groupcolumn1";
                }
                if(is_array($list_query_arr_all)&&isset($list_query_arr_all[$tmprowindex-1])&&!empty($list_query_arr_all[$tmprowindex-1])){
                    $right_joinsql = " left join (".$list_query_arr_all[$tmprowindex-1].") as query".($tmprowindex-1)." on query".($tmprowindex-1).".groupcolumn0 = query".$tmprowindex.".groupcolumn0".$sencond_join.$right_joinsql;
                }

                $list_query = "select * $tmpcompare_field from ($list_query) as query".$tmprowindex.$right_joinsql;
                if(count($this->groupInfo)==1&&$this->groupInfo[0]['groupbytype'] != "byField"&&$echartSet['chart_type']!='simple_sunburst') {
                    $orderby_field_str = ' order by query'.$tmprowindex.'.groupcolumn0 asc ';

                }else //饼图的话 按统计值排序
                    if(in_array($echartSet['chart_type'],['pie','solid_pie','rose_pie','nesting_pie'])){
                        $orderby_field_str = ' order by query'.$tmprowindex.'.co0 desc ';
                    }

            }

            if(sizeof($list_query_arr)>1)
            {
                $list_query="select sum(".$unionsumcolumnname.") as $unionsumcolumnname,$groupbykey from ( "
                    .implode(' union all ',$list_query_arr).') as tmp_unionall  group by '.$groupbykey.$orderby_field_str.' '.$limit_sql;
            }
            else{
                $list_query = $list_query.' '.$orderby_field_str.' '.$limit_sql;
            }

        }

        if(empty($list_query)){
            $errormsg = '';
            $returnsql ='';
            $echartSet['errormsg'] = $errormsg;
            $echartSet['returnsql'] = $returnsql;
            $code = -1;
            return ['code'=>$code,'data'=>$echartSet,'msg'=>''];
        }
        
        $res = $this->adb->pquery($list_query);
        /*try {
            $res = $this->adb->pquery($list_query);
        } catch (Exception $e) {
            // 捕捉到异常，打印错误信息（或进行其他错误处理）
            $errorinfo =  $e->getMessage() . "\n";
            return ['code'=>1,'data'=>$echartSet,'msg'=>$errorinfo];
        }*/

        $code = 1;
        $num_rows = $this->adb->num_rows($res);
        if($num_rows<=0){
            $errormsg = '';
            $returnsql ='';
            //有错误信息才返回错误
            if($this->adb->database->ErrorNo()>0) {
                $errormsg = "ADODB error ->[" . $this->adb->database->ErrorNo() . "]" . $this->adb->database->ErrorMsg();
                $returnsql = $list_query;//返回值SQL  SQL报错的时候返回 方便调试
            }
            $code = -1;
        }
        //1.先判断是否开启了第二统计维度
        if(count($groupby)>1&&$echartSet['chart_type']!='simple_sunburst'
            &&$echartSet['chart_type']!='basic_scatter'
            &&$echartSet['chart_type']!='nesting_pie'
            &&$echartSet['chart_type']!='multiple_dimension'){
            //默认第一个统计维度作为Y轴刻度，第二统计维度作为不同数据列显示
            $return = $this->twoGroupData($columns[0],$res,$echartSet,$this->groupInfo,$groupbykey);
            if(in_array($echartSet['chart_type'],["stack_strip","simple_strip","multiple_strip"])){
                $echartSet['yaxis'] = $this->yaxis($echartSet['yaxis'],$return['xdatas']);
            }else{
                $echartSet['xaxis'] = $this->xaxis($echartSet['xaxis'],$return['xdatas']);
            }
            $series_arr=$return['series'];
            //两个维度的  渲染表格
            //foreach($series_arr as $index=>$line){
            $cls_showTableObj->setTotalParams($this->setRowTotal,$this->setColumnTotal,$this->RowTotalDataArr,$this->ColumnTotalDataArr,$this->allTotal);
            $cls_showTableObj->setHeader($return['xdatas']);//设置表格的头
            $cls_showTableObj->showContentTableTwoGroup($series_arr);
            //}

        }else{
            switch($echartSet['chart_type']){
                case 'pie'://空心饼图
                case 'solid_pie'://实心饼图
                case 'rose_pie'://玫瑰饼图
                    $return = $this->pieData($columns,$res,$echartSet,$groupbykey);
                    $series_arr = $return['series'];

                    $cls_showTableObj->setTotalParams($this->setRowTotal,'no',$this->RowTotalDataArr,[],$this->allTotal);
                    $cls_showTableObj->setHeader($return['legendData']);//设置表格的头
                    $cls_showTableObj->showContentTable($return['series']);
                    $this->allTotalFormat = $cls_showTableObj->getAllTotalFormat();//汇总金额的格式化
                    $echartSet['xaxis'] = null;
                    $echartSet['yaxis'] = null;
                    break;
                case 'nesting_pie'://嵌套饼图
                    $return = $this->pieData($columns,$res,$echartSet,$groupbykey);
                    $series_arr = $return['series'];

                    $cls_showTableObj->setTotalParams($this->setRowTotal,'no',$this->RowTotalDataArr,[],$this->allTotal);
                    $cls_showTableObj->showContentTableNestingPie($return['series'],$this->groupInfo);
                    $echartSet['xaxis'] = null;
                    $echartSet['yaxis'] = null;
                    break;
                case 'funnel'://梯形漏斗图
                case 'triangle'://三角形漏斗图
                case 'bowls'://碗形漏斗图
                    $groupcolumnname = 'groupcolumn0';
                    $return = $this->funnelData($columns,$res,$echartSet,$groupcolumnname);
                    $series_arr = $return['series'];
                    $cls_showTableObj->setTotalParams($this->setRowTotal,'no',$this->RowTotalDataArr,[],$this->allTotal);
                    $cls_showTableObj->setHeader($return['legendData']);//设置表格的头
                    $cls_showTableObj->showContentTable($return['series']);
                    break;
                case 'simple_sunburst'://旭日图---没有表格
                    $return = $this->sunburstData($columns,$res,$groupby);
                    $series_arr[] = $return['series'];
                    break;
                case 'basic_scatter'://单维度散点图
                    $legend = [];
                    foreach($columns as $tmprowindex => $tmpcolumn){
                        $return[$tmprowindex] = $this->scatterData($columns,$res,$groupbykey,$tmprowindex,$scatt_arr,$legend);
                    }
                    $series_arr=$this->ResetScatter($groupby,$scatt_arr);
                    $legend = array_unique($legend);
                    $echartSet['legend'] = $this->legend($echartSet['legend'],$legend,$echartSet['chart_type'],$echartSet['legend_position']);

                    //单维度散点图的表格  根据多柱状图数据来处理
                    $return_table = $this->normalData($columns, $res, $echartSet, $groupbykey);
                    $cls_showTableObj->setTotalParams($this->setRowTotal,$this->setColumnTotal,$this->RowTotalDataArr,$this->ColumnTotalDataArr,$this->allTotal);
                    $cls_showTableObj->setHeader($return_table['xdatas']);//设置表格的头
                    $cls_showTableObj->showContentTable($return_table['series']);
                    break;
                case 'multiple_dimension'://多维度散点图
                    foreach($columns as $tmprowindex => $tmpcolumn){
                        $return[$tmprowindex] = $this->scatterData($columns,$res,$groupbykey,$tmprowindex,$scatt_arr,$legend);
                    }
                    $cls_showTableObj->showContentTable_scatter($scatt_arr);
                    $series_arr=$this->ResetScatter($groupby,$scatt_arr);
                    $legend = array_unique($legend);
                    $echartSet['legend'] = $this->legend($echartSet['legend'],$legend,$echartSet['chart_type'],$echartSet['legend_position']);
                    break;
                case 'simple_strip'://单条形图
                case 'multiple_strip'://多条形图
                case 'stack_strip'://条形堆叠图
                    $groupcolumnname = 'groupcolumn0';
                    $return = $this->normalData($columns,$res,$echartSet,$groupcolumnname);
                    $series_arr = array_values($return['series']);
                    $echartSet['yaxis'] = $this->yaxis($echartSet['yaxis'],$return['xdatas']);
                    $cls_showTableObj->setTotalParams($this->setRowTotal,$this->setColumnTotal,$this->RowTotalDataArr,$this->ColumnTotalDataArr,$this->allTotal);
                    $cls_showTableObj->setHeader($return['xdatas']);//设置表格的头
                    $cls_showTableObj->showContentTable($return['series']);
                    break;
                default ://柱状图，折线图.柱状堆叠图
                    $groupcolumnname = 'groupcolumn0';
                    $return = $this->normalData($columns,$res,$echartSet,$groupcolumnname);
                    $series_arr = array_values($return['series']);
                    $echartSet['xaxis'] = $this->xaxis($echartSet['xaxis'],$return['xdatas']);
                    $cls_showTableObj->setTotalParams($this->setRowTotal,$this->setColumnTotal,$this->RowTotalDataArr,$this->ColumnTotalDataArr,$this->allTotal);
                    $cls_showTableObj->setHeader($return['xdatas']);//设置表格的头
                    $cls_showTableObj->showContentTable($return['series']);
                    break;
            }
        }

        if($echartSet['chart_type']!= 'basic_scatter' ||$echartSet['chart_type']!= 'multiple_dimension')
         {
             $echartSet['legend'] = $this->legend($echartSet['legend'],$return['legendData'],$echartSet['chart_type'],$echartSet['legend_position']);

         }
        $echartSet['th_nums']=$cls_showTableObj->th_nums;

        $echartSet['series']=$series_arr;
        $echartSet['toolbox']=$this->toolbox($echartSet['toolbox'],$echartSet['report_name']);

        $echartSet['option']=$this->option($echartSet);
        $echartSet['fromhome']=$fromhome;
        if($fromhome!='yes') {
            $echartSet['table'] = $cls_showTableObj->getTableHtml();
        }
        $echartSet['errormsg'] = $errormsg;
        $echartSet['returnsql'] = $returnsql;
        $echartSet['totalrows'] = $num_rows;//数据总条数
        return ['code'=>$code,'data'=>$echartSet,'msg'=>''];
    }

    //zxm 20230314 BUG0062347   自定义统计图表，数据范围应该按模块数据范围控制
    public function getDataRangSql($module){
        crm_load_class_file('ReportAnalysisUtils','modules/ReportAnalysis');
        $focus = CRMEntity::getInstance($module);
        $table_name = $focus->table_name;
        $SmownerColumName = $focus->getSmownerColumName();
        $SmownerColumNametmp = $table_name.'.'.$SmownerColumName;
        $datarangesql = ReportAnalysisUtils::getUserIdSql($SmownerColumNametmp,$module,'');
        return $datarangesql;
    }


    /**
     * @param $groupInfo
     * @return array
     * 根据分组字段的字段信息:如果是下拉框字段 获取全部的下拉框值数组
     */
    public function getPicklistValuesArrByGroupInfo($groupInfo){
        $field = explode(':',$groupInfo['groupcolumns']);
        crm_load_class_file("cls_PickList", 'modules/PickList');
        $obj_pink_list = new cls_PickList();
        // 商机阶段数组
        $xkeyArr = $obj_pink_list->getPickListValues($field[2],'',array(),'id');
        $picklistValuesArr = array_values($xkeyArr);
        return $picklistValuesArr;
    }

    /**
     * @param $columns
     * @param $sqlData
     * @param $groupby
     * 旭日图的数据处理
     */
    public function sunburstData($columns,$sqlData,$groupby){
        //旭日图，没有相关模块
        $nums = $this->adb->num_rows($sqlData);
        
        $field = array_merge($groupby,$this->field_arr[$this->mainmodule]);
        $field = array_reverse($field);
        $data = [];
        for($i=0;$i<$nums;$i++){
            $resKey = '';
            $resVal = 0;
            $sunbursttype =  $this->adb->query_result($sqlData, $i, 'sunbursttype');
            foreach($field as $k=>$f) {
                $f = explode(' as ', $f);
                $tempVal = $this->adb->query_result($sqlData, $i, $f[1]);
                if($f[1]=='co0'){
                    $tempVal = empty($tempVal)?0:$tempVal;
                }else{
                    $tempVal = empty($tempVal)?'无':$tempVal;
                    $resKey .= $tempVal.'-';
                }
                $data[$i][$f[1]] = $tempVal;
            }
            $resKey = explode('-',rtrim($resKey,'-'));
            $resKey = array_reverse($resKey);
            $data[$i]['sunbursttype'] = $sunbursttype;
            $data[$i]['parent'] = $sunbursttype==0?0:implode('-',array_slice($resKey,$sunbursttype-1,1));
            $data[$i]['parent'] = empty($data[$i]['parent'])?'全球': $data[$i]['parent'];
            $data[$i]['parent'] = $data[$i]['parent'].'_'.($sunbursttype-1);
            $data[$i]['name'] = implode('-',array_slice($resKey,$sunbursttype,1));
            $data[$i]['name'] = $data[$i]['name'].'_'.$sunbursttype;
        }
        $data = $this->sunburstDataTree($data,'全球_-1','');
        $series['data'] = $data;
        $series['type'] = 'sunburst';
        return ['series'=>$series];
    }
    public function sunburstDataTree($data, $pname,$color='')
    {
        $tree = array();
        foreach($data as $k => $v)
        {
            $tempname = explode('_',$v['name']);
            $temp['name'] = $tempname[0];
            $temp['value'] = (int)$v['co0'];
            if($v['parent'] == $pname)
            {
                $colorArr = $this->getColor();
                if(empty($color)){
                    $colorVal = $colorArr[$k];
                }else{
                    $colorVal = $color;
                }
                $colorVal = $colorArr[$k];
                $temp['itemStyle']['color'] = $colorVal;
                $temp['children'] = $this->sunburstDataTree($data, $v['name'],$colorVal);
                $tree[] = $temp;
                unset($v);
            }
        }
        return $tree;
    }


    public function getHightSearchWhereSql($tmpcompareselect){

        if(in_array($tmpcompareselect,['prev','prev_growth','prev_growth_percent'])){
            //环比上期
            $advanceInfo = $this->prevAdvanceInfo;
        }else if(in_array($tmpcompareselect,['prev_lastyear','prev_growth_lastyear','prev_growth_percent_lastyear'])){
            //同比上期
            $advanceInfo = $this->prev_lastyearAdvanceInfo;
        }else{
            //本期
            $advanceInfo = $this->advanceInfo;
        }

        $advance_demand = $advanceInfo['advance_demand'];
        $advance_demand_groups = $advanceInfo['advance_demand_groups'];
        if ($advance_demand == '[]' && $advance_demand_groups == '[]') {
            return '';
        }

        crm_load_class_file('DataRangeHomeboard','modules/Home/');
        $DataRangeHomeboardObj = new DataRangeHomeboard(0,'ReportAnalysis');
        $tmpmodule = $this->mainmodule;
        $tmpfocus = CRMEntity::getInstance($tmpmodule);
        $tmp_queryobj = $DataRangeHomeboardObj->get_query_obj($tmpmodule);

        $tmp_queryobj->setScopeModule($tmpmodule);
        $tmp_queryobj->setSmOwnerSearchSql();
        $tmpinput['advft_criteria'] = $advance_demand;
        $tmpinput['advft_criteria_groups'] = $advance_demand_groups;
        $tmpinput['searchtype'] = 'advance';
        $tmp_queryobj->addUserSearchConditions($tmpinput);
        $tmp_queryobj->getWhereClause();

        $pagelistquerycol_arr = [$tmpfocus->table_name . '.' . $tmpfocus->table_index];
        $joinon_field = $tmpfocus->table_index;
        $jointable = $tmpfocus->table_name;
        $coulmns_table_arr = _array_column($this->columns,'chart_column_table');
        //判断统计字段是主表还是明细表  明细表的话pagelistquery字段是lineitemid 主表的话是salesorderid
        if(in_array($tmpfocus->Detail_table, $coulmns_table_arr)
            ||in_array($tmpfocus->Detail_table_scf, $coulmns_table_arr)
            ||((in_array('ld_products', $coulmns_table_arr)
            ||in_array('ld_productcf', $coulmns_table_arr))&&$tmpmodule != 'Products'))
        {
            if(!empty($tmp_queryobj->whereDetailTable)) {
                $pagelistquerycol_arr = [$tmpfocus->table_name . '.' . $tmpfocus->table_index, $tmpfocus->Detail_table . '.' . $tmpfocus->Detail_table_id];
                $joinon_field = $tmpfocus->Detail_table_id;
                $jointable = $tmpfocus->Detail_table;
            }
        }

        $tmp_queryobj->setPageListQueryColumn($pagelistquerycol_arr);

        $where = $tmp_queryobj->getQuery();

        $tmptablename = 'report_datarangesql_' . strtolower($tmpmodule);

        $where = ' inner join ('.$where.') '.$tmptablename.
        ' on '.$tmptablename.'.'.$joinon_field.'='.$jointable.'.'.$joinon_field;

        return  $where;

    }

    public function getCvadvfilterFromHomeNew($boardid,$report_id,$boardstuffid,$advanceinput,$modulename,$mainmodule,$tmpcompareselect){
        //变量替换 --新的方式 按看板按组件设置
        //变量替换 --新的方式 按看板按组件设置
        if(!empty($this->selectuid))
        {
            $this->selectuid = SqlSearchFilter($this->selectuid);
            $senioruserid = $this->selectuid;
        }
        $scopeType = $this->scopeType;
        $search_date = $this->search_date;

        //$date_search = getHomeDateScope($search_date);
        $show_athome_person='no';
        $show_athome_timecheck='no';
        $show_athome_approve='no';
        if($boardid<=0){
            //zxm 20231120 默认看板  读取设置好的映射条件
            $cvadvfilter_sql = "select * from ld_customreport_cvadvfilter where comparator in('show_athome_timecheck','show_athome_person','show_athome_approve') and report_id=? order by columnindex asc";
            $cvadvfilter_res = $this->adb->pquery($cvadvfilter_sql,array($report_id));
            $cvadvfilter_nums = $this->adb->num_rows($cvadvfilter_res);
            if($cvadvfilter_nums>0){
                for($i=0;$i<$cvadvfilter_nums;$i++){
                    $comparator = $this->adb->query_result($cvadvfilter_res,$i,'comparator');
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
                $scopeType = 'SmOwner_Search_All';
                $senioruserid = '';
            }
            if($show_athome_timecheck=='no'){
                $search_date = '';
            }
            if($show_athome_approve=='no'){
                $this->approve_value = 'all';
            }
        }

        //获取设置好的首页数据范围条件
        include_once globalStatic::$root_directory . 'modules/Home/DataRangeHomeboard.php';
        $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($boardid);
        $DataRangeHomeboardObj->resetModuleQueryObj($modulename);
        $DataRangeHomeboardObj->setCustomEchartHighSearchParam($advanceinput);
        $tmpfocus = CRMEntity::getInstance($modulename);


        $coulmns_table_arr = _array_column($this->columns,'chart_column_table');
        //判断统计字段是主表还是明细表  明细表的话pagelistquery字段是lineitemid 主表的话是salesorderid
        if(in_array($tmpfocus->Detail_table, $coulmns_table_arr)
            ||in_array($tmpfocus->Detail_table_scf, $coulmns_table_arr)
            ||((in_array('ld_products', $coulmns_table_arr)
                    ||in_array('ld_productcf', $coulmns_table_arr))&&$modulename != 'Products'))
        {
            $iscomputedetailtable = 'yes';
        }
        $filterArr = $DataRangeHomeboardObj->boardfilterArr[$boardstuffid];
        $timeisrelated = $filterArr['timecomponent_' . $modulename]['isrelated'];

        if($timeisrelated=='yes'){
            crm_load_class_file('DateOperation','include');
            $dateinfo = DateOperation::getCompareDate($search_date);
            if(!empty($dateinfo)){
                $this->timeRange = [$dateinfo['starttime'],$dateinfo['endtime']];
            }
            $startdate =$dateinfo['startdate'];
            $enddate =$dateinfo['enddate'];
            crm_load_class_file('ReportAnalysisUtils','modules/ReportAnalysis');
            if($tmpcompareselect=='prev'&&$search_date!='all'){
                //环比上期总条件
                $groupInfo = $this->groupInfo[0];
                $groupbytype = $groupInfo['groupbytype'];
                $prevTimeRange = ReportAnalysisUtils::getHuanbiTimeRange($groupbytype,[$startdate,$enddate]);
                $search_date = implode('~',$prevTimeRange);
            }else if($tmpcompareselect=='prev_lastyear'&&$search_date!='all'){
                //去年同期总条件
                $prev_lastyearTimeRange = ReportAnalysisUtils::getTongbiTimeRange([$startdate,$enddate]);
                $search_date = implode('~',$prev_lastyearTimeRange);
            }
        }

        $stuffDateRangeArr = $DataRangeHomeboardObj->getHomeDateScope($search_date,'no'); //获取时间范围  返回的是一个数组

        $params = array(
            'datarangmodule'=>$mainmodule,
            'computemodule'=>$modulename,
            'stuffid'=>$report_id,
            'boardstuffid'=>$boardstuffid,
            'scope'=>$scopeType,
            'senioruserid'=>$senioruserid,
            'date_adv'=>$stuffDateRangeArr['date_adv'],
            'approve_value'=>$this->approve_value,
            'iscomputedetailtable'=>$iscomputedetailtable,
            'ischuantou'=>'no');

        $DataRangeHomeboardObj->getDataRangeSqlCharts($params);
        $where = $DataRangeHomeboardObj->datarangesqlArr['datarangesql_'.$mainmodule];


        return $where;
    }
    /**
     * @param $report_id
     * @return array
     * @throws Exception
     * 获取统计图的基础信息
     */
    public function getReportInfo($report_id)
    {
        $sql = "select * from ld_customreport where report_id=".$report_id;

        $res = $this->adb->pquery($sql);
        $nums = $this->adb->num_rows($res);
        $reportInfo = [];
        if($nums>0){
            $reportInfo['report_id'] = $this->adb->query_result($res,0,'report_id');
            $reportInfo['report_name'] = $this->adb->query_result($res,0,'report_name');
            $reportInfo['report_desc'] = $this->adb->query_result($res,0,'report_desc');
            $reportInfo['report_type'] = $this->adb->query_result($res,0,'report_type');
            $reportInfo['parent_id'] = $this->adb->query_result($res,0,'parent_id');
            $reportInfo['show_athome'] = $this->adb->query_result($res,0,'show_athome');
            $reportInfo['linkmodulecheck'] = $this->adb->query_result($res,0,'linkmodulecheck');
            $reportInfo['can_penetrate'] = $this->adb->query_result($res,0,'can_penetrate');//允许穿透
            $reportInfo['relatedmodule'] = $this->adb->query_result($res,0,'relatedmodule');

            $reportInfo['sequence'] = $this->adb->query_result($res,0,'sequence');
            $reportInfo['mainmodule'] = $this->adb->query_result($res,0,'mainmodule');
            $reportInfo['createdtime'] = $this->adb->query_result($res,0,'createdtime');
            $reportInfo['modify_time'] = $this->adb->query_result($res,0,'modify_time');
            $reportInfo['modify_id'] = $this->adb->query_result($res,0,'modify_id');

            $reportInfo['limit'] = $this->adb->query_result($res,0,'limit');
            $reportInfo['orderby'] = $this->adb->query_result($res,0,'orderby');
            $reportInfo['orderby_type'] = $this->adb->query_result($res,0,'orderby_type');
            $reportInfo['stat_approach'] = $this->adb->query_result($res,0,'stat_approach');
            $reportInfo['isshow_search'] = $this->adb->query_result($res,0,'isshow_search');
            $reportInfo['isshow_table'] = $this->adb->query_result($res,0,'isshow_table');
            $reportInfo['analysisfolder_id'] = $this->adb->query_result($res,0,'analysisfolder_id');
            $reportInfo['themename'] = $this->adb->query_result($res,0,'themename');
            $reportInfo['themename'] = empty($reportInfo['themename'])?'Default':$reportInfo['themename'];

            $advance_demand = $this->adb->query_result($res,0,'advance_demand');
            $advance_demand_groups = $this->adb->query_result($res,0,'advance_demand_groups');
            $reportInfo['advance_demand'] = $advance_demand;
            $reportInfo['advance_demand_groups'] = $advance_demand_groups;

        }
        //查询展示在首页相关的配置信息
        $show_athome_sql = "select * from ld_customreport_cvadvfilter where report_id=".$report_id." and comparator  in('show_athome_timecheck','show_athome_person','show_athome_approve')";
        $show_athome_res = $this->adb->pquery($show_athome_sql);
        $show_athome_nums = $this->adb->num_rows($show_athome_res);
        $reportInfo['show_athome_info'] = [];
        if($show_athome_nums>0){
            for($i=0;$i<$show_athome_nums;$i++){
                $comparator = $this->adb->query_result($show_athome_res,$i,'comparator');
                if($comparator=='show_athome_person'){
                    $reportInfo['show_athome_info']['person'] = 'yes';
                }else if($comparator=='show_athome_timecheck'){
                    $reportInfo['show_athome_info']['timecheck'] = 'yes';
                    $columns = $this->adb->query_result($show_athome_res,$i,'columns');
                    $reportInfo['show_athome_info']['columns'] = $columns;
                }else if($comparator=='show_athome_approve'){
                    $reportInfo['show_athome_info']['approve'] = 'yes';
                }
            }
        }

        return $reportInfo;
    }
    public function getGroupBy($report_id,$mainModule,$chartType)
    {
        $group_sql = "select * from ld_customreport_group where report_id=? order by `sequence` asc";
        $group_res = $this->adb->pquery($group_sql,[$report_id]);
        $nums = $this->adb->num_rows($group_res);
        $group = [];
        $groupby = [];
        $focus=CRMEntity::getInstance($mainModule);

        $DependentFields = [];
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $group[$i]['groupbytype'] = $this->adb->query_result($group_res,$i,'groupbytype');
                $group[$i]['groupcolumns'] = $this->adb->query_result($group_res,$i,'columns');
                $group[$i]['bigtype'] = $this->adb->query_result($group_res,$i,'bigtype');
                $temp_groupcolumns = explode(':',$group[$i]['groupcolumns']);
                $groupbyname = explode('_',$temp_groupcolumns[3]);
                //edit: xll 2024/02/21 BUG20240201-17 散点图undefined
                $tmpfocus = CRMEntity::getInstance($groupbyname[0]);
                //edit: xll 2024/03/26 BUG20240326-16 主模块是有产品分录的模块-统计维度选择分录中的关联选择单据字段
                $FieldInfo = $tmpfocus->fieldobj->getFieldInfoobjBykey('columnname', $temp_groupcolumns[1]);
                if(!$FieldInfo) {
                    $FieldInfo = $tmpfocus->detailfieldobj->getFieldInfoobjBykey('columnname', $temp_groupcolumns[1]);
                }
                $group[$i]['groupbyname'] = $FieldInfo->getfieldLabel();
                $group[$i]['FieldValue'] = $group[$i]['groupcolumns'];
                $group[$i]['TimeMethod'] = $group[$i]['groupbytype'];
                $group[$i]['BigType'] = $group[$i]['bigtype'];
                //如果是旭日图 需要把级联字段的上级字段名称加进去 只能一个统计维度

                if($chartType=='simple_sunburst'){
                    $DependentFields = $this->getDependentFields($mainModule,$temp_groupcolumns[1],$temp_groupcolumns[0]);
                }
                //edit: xll 2024/03/26 BUG20240326-16 主模块是有产品分录的模块-统计维度选择分录中的产品属性字段
                $tmp_tablename = $temp_groupcolumns[0];
                if(!in_array($tmp_tablename,$this->groupbytables)){
                    //zxm 20240606 主模块选客户  相关模块选自定义模块04  字段不用到主表的只用自定义表的，连自定义表之前需要先连主表
                    if($groupbyname[0]!=$mainModule) {
                        $relatetablejoinobj = cls_TableJoin_module::getInstance($this->mainmodule, $groupbyname[0]);

                        $tmpjoin_arr = $relatetablejoinobj->getJoin();
                        if (!in_array($tmpjoin_arr['jointable'][0], $this->groupbytables)) {
                            $this->groupbyjoinTable .= $tmpjoin_arr['joinsqltype'] . ' ' . $tmpjoin_arr['relatejoinsql'];
                            $this->groupbytables[] = $tmpjoin_arr['jointable'][0];
                        }
                    }
                    if( ($tmp_tablename == 'ld_products' || $tmp_tablename == 'ld_productcf') && get_file_address($groupbyname[0], 'ProductDetails') ) {
                        if(!in_array($tmpfocus->Detail_table,$this->groupbytables)) {
                            $this->groupbyjoinTable .= " left join $tmpfocus->Detail_table on $tmpfocus->Detail_table.$tmpfocus->Detail_table_index=$tmpfocus->table_name.$tmpfocus->table_index ";
                            $this->groupbytables[] = $tmpfocus->Detail_table;
                        }
                        if (!in_array('ld_products', $this->groupbytables)) {
                            $this->groupbyjoinTable .= " left  join ld_products on  ld_products.productid=$tmpfocus->Detail_table.productid ";
                            $this->groupbytables[] = 'ld_products';
                        }
                        if ($tmp_tablename == 'ld_productcf'&&!in_array('ld_productcf', $this->groupbytables)) {
                            $this->groupbyjoinTable .= " left  join ld_productcf on  ld_products.productid=ld_productcf.productid ";
                            $this->groupbytables[] = $tmp_tablename;
                        }
                    }
                    else {
                        $tmpFocusTable = $tmpfocus->table_name;
                        $tmpFocusIndex = $tmpfocus->table_index;
                        $mainDetail = $tmpfocus->Detail_table;
                        $mainDetailField = $mainDetail.'.'.$tmpfocus->Detail_table_index;
                        $mainDetailScf = $this->focus->Detail_table_scf;
                        //edit: xll 2024/04/28 统计维度选分录自定义字段
                        if ($tmp_tablename == $mainDetail || $tmp_tablename == $mainDetailScf) {
                            //求和字段是明细表的住表
                            if(!in_array($mainDetail,$this->groupbytables)){
                                $this->groupbyjoinTable .= " left  join $mainDetail on $mainDetailField = $tmpFocusTable.$tmpFocusIndex ";
                                $this->groupbytables[] = $mainDetail;
                            }
                            if ($tmp_tablename == $mainDetailScf&&!in_array($mainDetailScf,$this->groupbytables)) {
                                $mainDetailScfIndex = $this->focus->Detail_table_id;
                                $mainDetailScfField = $mainDetailScf . '.' . $mainDetailScfIndex;
                                //求和字段是明细表的自定义表表
                                $this->groupbyjoinTable .= " left  join $mainDetailScf on $mainDetail.$mainDetailScfIndex = $mainDetailScfField ";
                                $this->groupbytables[] = $mainDetailScf;
                            }
                        }
                        else {
                            //从连接用户表的后面提到前面  用户字段可能是来自自定义表
                            array_push($this->groupbytables, $tmp_tablename);
                            $this->groupbyjoinTable .= "  left join $tmp_tablename on $tmp_tablename.$tmpFocusIndex = $tmpFocusTable.$tmpFocusIndex ";
                        }
                    }
                }

                //zxm 20231031 非时间类型的只能走这  防止前端判断错误导致数据出错
                if($group[$i]['groupbytype']=="byField"||($group[$i]['bigtype']!='date'&&$group[$i]['bigtype']!='datetime')){
                    $bigtype='';
                    if($temp_groupcolumns[0]==$focus->table_name||$temp_groupcolumns[0]==$focus->customFieldTable[0]) {
                        //主表、
                        $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("columnname", $temp_groupcolumns[1]);
                        $uitype = 0;
                        if ($fieldinfo) {
                            $bigtype = $fieldinfo->getBigType();
                            $uitype = $fieldinfo->getUIType();

                        }

                        switch ($bigtype) {
                            case 'users':
                            case 'Users':
                            case 'smcreatorid':
                            case 'selectoneuser':
                                include_once(globalStatic::$root_directory . 'appCommon/appCommon.php');
                                //zxm 2021-0127 负责人 客户001的负责人的显示改成真实姓名
                                if (isKehu001ServerPc() == 'yes') {
                                    $groupby[$i] = "ld_users.real_name as groupcolumn" . $i;
                                } else {
                                    $groupby[$i] = "ld_users.last_name as groupcolumn" . $i;
                                }
                                $this->groupbyjoinTable .= " left join ld_users on " . $fieldinfo->getTableName() . '.' . $temp_groupcolumns[1] . '=ld_users.id ';
                                $this->groupbytables[] = 'ld_users';
                                break;

                            case 'reference':
                                crm_load_class_file("cls_Uitype_table", "include/fields");

                                $tmp_arr = cls_Uitype_table::getTableJoinByUitype($uitype);
                                $referencemodule = $tmp_arr['module'];
                                $referencefocus = CRMEntity::getInstance($referencemodule);
                                $referencetablename = $referencefocus->table_name;
                                $relatetablejoinobj = cls_TableJoin_module::getInstance($referencemodule, $this->mainmodule);

                                $tmp_arr = $relatetablejoinobj->getJoin();

                                $tmpfocus = $this->focus;//CRMEntity::getInstance($this->mainmodule);

                                if (!in_array($referencetablename, $this->groupbytables)) {

                                    $list_link_field = $referencefocus->list_link_field;

                                    $referencetable_index = $referencefocus->table_index;

                                    $list_link_fieldinfo = $referencefocus->fieldobj->getFieldInfoobjBykey("fieldname", $list_link_field);
                                    $list_link_column = $list_link_fieldinfo->getColumnName();
                                    $listlinktablename = $list_link_fieldinfo->getTableName();

                                    $groupby[$i] = " $listlinktablename.$list_link_column as groupcolumn" . $i;


                                    if (in_array($tmpfocus->Detail_table, $tmp_arr['jointable']) &&
                                        !in_array($tmpfocus->Detail_table, $this->groupbytables)) {
                                        $tmpdetailtable = $tmpfocus->Detail_table;
                                        $Detail_table_index = $tmpfocus->Detail_table_index;
                                        $this->groupbyjoinTable .= ' inner join  ' . $tmpdetailtable . " on $tmpdetailtable.$Detail_table_index=" . $tmpfocus->table_name . '.' . $tmpfocus->table_index;
                                        $this->groupbytables[] = $tmpfocus->Detail_table;

                                    }
                                    $this->groupbyjoinTable .= $tmp_arr['joinsqltype'] . $referencetablename . ' on ' . $tmp_arr['bwmodulesql'];// $tmp_arr['leftjoin'].$fieldinfo->getTableName().'.'.$fieldinfo->getColumnName();

                                    if ($listlinktablename != $referencetablename) {
                                        $this->groupbyjoinTable .= "left join $listlinktablename on $listlinktablename.$referencetable_index=$referencetablename.$referencetable_index";
                                        $this->groupbytables[] = $listlinktablename;
                                    }

                                    $this->groupbytables[] = $referencetablename;
                                }
                                break;
                            default:
                                $tempFieldName = '(case when ifnull(' . $temp_groupcolumns[0] . '.' . $temp_groupcolumns[1] . ',"") = "" then "无" else ' . $temp_groupcolumns[0] . '.' . $temp_groupcolumns[1] . ' end )';
                                $groupby[$i] = $tempFieldName . ' as groupcolumn' . $i;
                                break;
                        }
                    }else{
                        //分录
                        $fieldinfo=$focus->detailfieldobj->getFieldInfoobjBykey("columnname",$temp_groupcolumns[1]);
                        if ($fieldinfo) {
                            $bigtype = $fieldinfo->getBigType();
                        }
                        switch ($bigtype) {
                            case 'users':
                            case 'Users':
                            case 'smcreatorid':
                            case 'selectoneuser':
                                include_once(globalStatic::$root_directory . 'appCommon/appCommon.php');
                                //zxm 2021-0127 负责人 客户001的负责人的显示改成真实姓名
                                if (isKehu001ServerPc() == 'yes') {
                                    $groupby[$i] = "ld_users.real_name as groupcolumn" . $i;
                                } else {
                                    $groupby[$i] = "ld_users.last_name as groupcolumn" . $i;
                                }
                                $this->groupbyjoinTable .= " left join ld_users on " . $fieldinfo->getTableName() . '.' . $temp_groupcolumns[1] . '=ld_users.id ';
                                break;

                            case 'reference':
                                $referencemodule = $fieldinfo->getReferenceModule();
                                if($referencemodule=='Users') {
                                    //先做预算单分录选用户把  其他的遇到了再写
                                    $linktablename = $fieldinfo->getTableName();
                                    $linkcolumnname = $fieldinfo->getColumnName();

                                    $referencefocus = CRMEntity::getInstance($referencemodule);
                                    $referencetablename = $referencefocus->table_name;
                                    $referencetable_index = $referencefocus->table_index;

                                    $this->groupbyjoinTable .= "left join $referencetablename on $linktablename.$linkcolumnname=$referencetablename.$referencetable_index";
                                    $this->groupbytables[] = $referencetablename;

                                    if (isKehu001ServerPc() == 'yes') {
                                        $groupby[$i] = "ld_users.real_name as groupcolumn" . $i;
                                    } else {
                                        $groupby[$i] = "ld_users.last_name as groupcolumn" . $i;
                                    }
                                    $this->groupbytables[] = $referencetablename;
                                }else{

                                }

                                break;
                            default:
                                $tempFieldName = '(case when ifnull(' . $temp_groupcolumns[0] . '.' . $temp_groupcolumns[1] . ',"") = "" then "无" else ' . $temp_groupcolumns[0] . '.' . $temp_groupcolumns[1] . ' end )';
                                $groupby[$i] = $tempFieldName . ' as groupcolumn' . $i;
                                break;
                        }
                    }
                }
                else{
                    //按月 按年 按周等需要特殊处理
                    $temp_group = $this->getDimensionOfTime($temp_groupcolumns[0].'.'.$temp_groupcolumns[1],$group[$i]['groupbytype'],'cur');
                    $groupby[$i] = $temp_group['sqlBy'] . ' as groupcolumn'.$i;
                    //环比上期  groupby值
                    $temp_group_prev = $this->getDimensionOfTime($temp_groupcolumns[0].'.'.$temp_groupcolumns[1],$group[$i]['groupbytype'],'prev');
                    $this->groupby_prev = $temp_group_prev['sqlBy'] . ' as groupcolumn'.$i;
                    //同比上期  groupby值
                    $temp_group_prev_lastyear = $this->getDimensionOfTime($temp_groupcolumns[0].'.'.$temp_groupcolumns[1],$group[$i]['groupbytype'],'prev_lastyear');
                    $this->groupby_prev_lastyear = $temp_group_prev_lastyear['sqlBy'] . ' as groupcolumn'.$i;
                }

                $this->groupcolumns[$i] = $group[$i]['groupcolumns'];
                /*
				if(!in_array($temp_groupcolumns[0],$this->groupbytables)){
                    array_push($this->groupbytables,$temp_groupcolumns[0]);
                    $this->groupbyjoinTable.= "  left join $temp_groupcolumns[0] on $temp_groupcolumns[0]." .
                        $this->focus->table_index . '=' . $this->focus->table_name . '.' . $this->focus->table_index;
                }
                */
                //zxm 20220818 排序设置
                $column_totaltype = $group[$i]['groupcolumns'].'-'.$group[$i]['groupbytype'];
                if(isset($this->sorting_list[$column_totaltype])){
                    $temp_groupby = $groupby[$i];
                    $temp_groupby_arr = explode(' as ',$temp_groupby);
                    $temp_alias = trim($temp_groupby_arr[1]);
                    $this->sorting_list[$column_totaltype]['alias'] = $temp_alias;
                    //中文按拼音排序
                    $this->sorting_list[$column_totaltype]['alias_sortmethod'] = ' CONVERT(query0.'.$temp_alias.' using gbk)  '. $this->sorting_list[$column_totaltype]['sortmethod'];
                }
                //默认排序--20220913
                $this->sorting_list_default[$column_totaltype]['alias'] = $temp_alias;
                $this->sorting_list_default[$column_totaltype]['alias_sortmethod'] = ' CONVERT(query0.'.$temp_alias.' using gbk)  '. $this->sorting_list[$column_totaltype]['sortmethod'];
            }
        }

        $DependentFields = array_reverse(array_values($DependentFields));
        foreach($DependentFields as $dk => $dv){
            $tempFieldName = '(case '.$dv['tablename'].'.'. $dv['fieldname'].' when null then "无" when "" then "无" else '.$dv['tablename'].'.'. $dv['fieldname'].' end )';
            $temp_dv = $tempFieldName. ' as groupcolumn'.($dk+1);
            if(!in_array($dv['tablename'],$this->groupbytables)){
                array_unshift($this->groupbytables,$dv['tablename']);
                $this->groupbyjoinTable.= "  left join ".$dv['tablename']." on ".$dv['tablename'].'.'.
                    $this->focus->table_index . '=' . $this->focus->table_name . '.' . $this->focus->table_index;
            }
            array_unshift($groupby,$temp_dv);
        }
        $this->groupInfo = $group;

        return array_unique($groupby);
    }
    public function getGroupByData($report_id)
    {
        $group_sql = "select * from ld_customreport_group where report_id=? order by `sequence` asc";
        $group_res = $this->adb->pquery($group_sql,[$report_id]);
        $nums = $this->adb->num_rows($group_res);
        $group = [];
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $group[$i]['groupbytype'] = $this->adb->query_result($group_res,$i,'groupbytype');
                $group[$i]['groupcolumns'] = $this->adb->query_result($group_res,$i,'columns');
                $group[$i]['bigtype'] = $this->adb->query_result($group_res,$i,'bigtype');
                $temp_groupcolumns = explode(':',$group[$i]['groupcolumns']);
                $groupbyname = explode('_',$temp_groupcolumns[3]);
                //edit: xll 2024/02/21 BUG20240201-17 散点图undefined
                $tmpfocus = CRMEntity::getInstance($groupbyname[0]);
                //edit: xll 2024/03/26 BUG20240326-16 主模块是有产品分录的模块-统计维度选择分录中的关联选择单据字段
                $FieldInfo = $tmpfocus->fieldobj->getFieldInfoobjBykey('columnname', $temp_groupcolumns[1]);
                if(!$FieldInfo) {
                    $FieldInfo = $tmpfocus->detailfieldobj->getFieldInfoobjBykey('columnname', $temp_groupcolumns[1]);
                }
                $group[$i]['groupbyname'] = $FieldInfo->getfieldLabel();
                $group[$i]['FieldValue'] = $group[$i]['groupcolumns'];
                $group[$i]['TimeMethod'] = $group[$i]['groupbytype'];
                $group[$i]['BigType'] = $group[$i]['bigtype'];
            }
        }
        return $group;
    }
    public function getSortingColumn($report_id){
        $select_sql = " select * from ld_customreport_sorting 
where report_id=? order by sequence asc ";
        $select_res = $this->adb->pquery($select_sql,array($report_id));
        $select_nums = $this->adb->num_rows($select_res);
        $sorting_list = [];
        $SeqSet = [];
        if($select_nums>=1){
            for($i=0;$i<$select_nums;$i++){
                $sorttype = $this->adb->query_result($select_res,$i,'sorttype');
                $columnmodule = $this->adb->query_result($select_res,$i,'columnmodule');
                $columns = $this->adb->query_result($select_res,$i,'columns');
                $total_type = $this->adb->query_result($select_res,$i,'total_type');
                $total_type = empty($total_type)?'':'-'.$total_type;

                $columnmodule_columns = $columns.$total_type;

                $sorting_list[$columnmodule_columns]['sorttype'] = $sorttype;
                $sorting_list[$columnmodule_columns]['columnmodule'] = $columnmodule;
                $sorting_list[$columnmodule_columns]['columns'] = $columns;
                $sortmethod = $this->adb->query_result($select_res,$i,'sortmethod');
                $sorting_list[$columnmodule_columns]['sortmethod'] = $sortmethod;
                $sorting_list[$columnmodule_columns]['sequence'] = $this->adb->query_result($select_res,$i,'sequence');
                $sorting_list[$columnmodule_columns]['columnmodule_columns'] = $columnmodule_columns;

                $SeqSet[] = [
                    'SeqType' => $sorttype, 'SeqField' => $columns, 'SeqMethod' => $sortmethod,
                ];
            }
        }
        $this->sorting_list = $sorting_list;
        $this->SeqSet = $SeqSet;
    }
    public function getTotalColumn($report_id)
    {
        $focus=CRMEntity::getInstance($this->mainmodule);
        if(is_string($this->relatedmodule))
            $relatemodule_arr=explode(",",$this->relatedmodule);
        else{
            $relatemodule_arr=[];
        }
        $ret_columns=array();

        //$columns_sql = "select * from ld_customreport_total_column where report_id=?";
        //按排序顺序  查询统计字段
        $columns_sql = "select a.* from ld_customreport_total_column a left join ld_customreport_sorting b on a.report_id=b.report_id and a.total_type=b.total_type and a.columns=b.columns  
            where a.report_id=? order by b.sequence asc,a.sequence asc";
        $columns_res = $this->adb->pquery($columns_sql,[$report_id]);
        $columns_nums = $this->adb->num_rows($columns_res);
        $total_columns = $newtotal_columns = [];
        $haveFieldColumns = [];//用来保存 已经放到数组中的列  total_type columns compare_select column_module 这几个项都需要判断
        $oldcompare_select_arr = [];
        for($k=0;$k<$columns_nums;$k++){
            $tmptotal_type = $this->adb->query_result($columns_res,$k,'total_type');
            $columns_str = $this->adb->query_result($columns_res,$k,'columns');
            $column_module = $this->adb->query_result($columns_res,$k,'column_module');
            $compare_select = $this->adb->query_result($columns_res,$k,'compare_select');//同环比选项 cur prev prev_growth prev_lastyear
            $haveFieldColumns[] = $tmptotal_type.$columns_str.$compare_select.$column_module;
            $oldcompare_select_arr[$k]=$compare_select;//每个字段对应的同环比 旧的
        }
        $fieldindex = 0;
        $fieldindex2 = 0;
        $newtotal_columns_unique = [];
        for($i=0;$i<$columns_nums;$i++){
            $total_type = $this->adb->query_result($columns_res,$i,'total_type');
            $columns_str = $this->adb->query_result($columns_res,$i,'columns');
            $column_module = $this->adb->query_result($columns_res,$i,'column_module');
            $compare_select = $this->adb->query_result($columns_res,$i,'compare_select');//同环比选项 cur prev prev_growth prev_lastyear
            $temp_column_totalttype = $columns_str.'-'.$total_type; //zxm 20220818 排序设置
            $newtotal_columns_tmp = [];
            $total_columns[$i]['total_type'] = $newtotal_columns_tmp['total_type'] = $total_type;
            $total_columns[$i]['compare_select'] = $newtotal_columns_tmp['compare_select'] = $compare_select;//同环比选项

            $total_columns[$i]['columns'] = $newtotal_columns_tmp['columns'] = $columns_str;

            $columns = explode(',',$columns_str);

            $total_columns[$i]['sequence'] = $newtotal_columns_tmp['sequence'] = $this->adb->query_result($columns_res,$i,'sequence');
            $total_columns[$i]['chart_column_type'] = $newtotal_columns_tmp['chart_column_type'] = $this->adb->query_result($columns_res,$i,'chart_column_type');
            $chart_column_name = $this->adb->query_result($columns_res,$i,'chart_column_name');
            $total_columns[$i]['typeofdata_decimal'] = $newtotal_columns_tmp['typeofdata_decimal'] = 0;
            $FieldArr = explode(':',$columns[0]);
            //如果为空即未设置显示名称，则显示字段名称
            if(empty($chart_column_name)){

                $FieldName = $FieldArr[2];
                $FieldModule = explode('_',$FieldArr[3])[0];
                $FieldModuleFocus = CRMEntity::getInstance($FieldModule);
                if($FieldModuleFocus->fieldobj){
                    $MainFields = $FieldModuleFocus->fieldobj->getModuleFields();
                    $FieldInfo = isset($MainFields[$FieldName]) ? $MainFields[$FieldName] : '';
                }
                if($FieldModuleFocus->detailfieldobj){
                    $DetrailFields = $FieldModuleFocus->detailfieldobj->getModuleFields();
                    $FieldInfo = isset($DetrailFields[$FieldName]) ? $DetrailFields[$FieldName] : '';
                }

                if($FieldInfo)
                    $chart_column_name = $FieldInfo -> getfieldLabel();
            }
            $total_columns[$i]['chart_column_table'] = $newtotal_columns_tmp['chart_column_table'] = $FieldArr[0];//统计字段所在表名
            $total_columns[$i]['chart_column_name'] = $newtotal_columns_tmp['chart_column_name'] = $chart_column_name;
            $total_columns[$i]['color'] = $newtotal_columns_tmp['color'] = $this->adb->query_result($columns_res,$i,'color');
            $total_columns[$i]['yaxisindex'] = $newtotal_columns_tmp['yaxisindex'] = $this->adb->query_result($columns_res,$i,'yaxisindex');

            //YAxis对应键值赋值
            $total_columns[$i]['CalcMethod'] = $newtotal_columns_tmp['CalcMethod'] = $total_columns[$i]['total_type'];    //计算方式
            $total_columns[$i]['FieldValue'] = $newtotal_columns_tmp['FieldValue'] = $total_columns[$i]['columns'];       //字段值
            $total_columns[$i]['SeriesType'] = $newtotal_columns_tmp['SeriesType'] = $total_columns[$i]['chart_column_type']; //展示形式
            $total_columns[$i]['DisplayName'] = $newtotal_columns_tmp['DisplayName'] = $total_columns[$i]['chart_column_name'];//显示名称
            $total_columns[$i]['YAxisIndex'] = $newtotal_columns_tmp['YAxisIndex'] = $total_columns[$i]['yaxisindex'];    //选择y轴
            $total_columns[$i]['FieldModule'] = $newtotal_columns_tmp['FieldModule'] = $this->adb->query_result($columns_res,$i,'column_module');  //字段模块
            $total_columns[$i]['CompareSelect'] = $newtotal_columns_tmp['CompareSelect'] = $compare_select;  //同环比
            //zxm 20220818 排序设置
            if(isset($this->sorting_list[$temp_column_totalttype])){
                $this->sorting_list[$temp_column_totalttype]['alias'] = 'co'.$i;
                $this->sorting_list[$temp_column_totalttype]['alias_sortmethod'] = 'co'.$i.' '.$this->sorting_list[$temp_column_totalttype]['sortmethod'];
            }

            $fieldTemp = [];
            $countTemp = [];
            $sumTemp = [];
            $columodulename='';



            foreach($columns as $column){
                $column = explode(':',$column);
                $column_relatemodule='';

                $bigtype='';
                $tmp_maintablename='';

                if(in_array($column[0],$focus->tab_name))
                {
                    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$column[1]);
                    $tmp_maintablename=$focus->table_name;
                    $ret_columns[]=$total_columns;
                    $columodulename=$this->mainmodule;

                }
                else if($column[0]==$focus->Detail_table||$column[0]==$focus->Detail_table_scf)
                {

                    $fieldinfo=$focus->detailfieldobj->getFieldInfoobjBykey("columnname",$column[1]);
                    $tmp_maintablename=$focus->table_name;
                    $ret_columns[]=$total_columns;
                    $columodulename=$this->mainmodule;
                }
                else if(!empty($this->relatedmodule)){

                    foreach($relatemodule_arr as $tmprelatemodule)
                    {
                        $relatefocus=CRMEntity::getInstance($tmprelatemodule);
                        $column_relatemodule=$tmprelatemodule;
                        $columodulename=$tmprelatemodule;

                        if(in_array($column[0],$relatefocus->tab_name))
                        {
                            $fieldinfo=$relatefocus->fieldobj->getFieldInfoobjBykey("columnname",$column[1]);
                            $tmp_maintablename=$relatefocus->table_name;

                            $this->relatemoduleColumn_arr[$tmprelatemodule][]=$total_columns;
                            break;
                        }
                        else if($column[0]==$relatefocus->Detail_table||$column[0]==$relatefocus->Detail_table_scf)
                        {

                            $fieldinfo=$relatefocus->detailfieldobj->getFieldInfoobjBykey("columnname",$column[1]);
                            $tmp_maintablename=$relatefocus->table_name;
                            $this->relatemoduleColumn_arr[$tmprelatemodule][]=$total_columns;
                            break;
                        }
                    }
                }
                if($fieldinfo)
                {
                    global $adb;
                    $bigtype=$fieldinfo->getBigType();
                    if($bigtype=='reference'||$bigtype=='numeric'||$bigtype=='money')
                    {
                        $sql='update '.$fieldinfo->getTableName().' set '.$column[1].'=0 where ifnull( '.$column[1].',0)=0;';
                    }
                    else
                        $sql='update '.$fieldinfo->getTableName().' set '.$column[1].'="" where ifnull( '.$column[1].',"")="";';
                    //  dump($sql);
                    $adb->pquery('set @disable_triggers=1;',array());
                    $adb->pquery($sql,array());

                    //zkt 20221109 XUQIU1000804 单据头和单据分录“金额货币”类型的字段允许自定义小数位数
                    $typeofdata_decimal=$fieldinfo->gettypeofdata_decmail();
                    //单据头和单据分录“金额货币”类型字段根据typeofdata取值，其他的仍默认为2
//                    if($fieldinfo->isAmountorCurrencyField()){
//                        if(!is_numeric($typeofdata_decimal)){
//                            $typeofdata_decimal = 2;
//                        }
                    if($total_type=='distinct_count'||$total_type=='count'){
                        $typeofdata_decimal = 0;
                    }
                    $total_columns[$i]['typeofdata_decimal'] = $newtotal_columns_tmp['typeofdata_decimal'] = $typeofdata_decimal;
//                    }

                }else{
                    //typeofdata_decimal 给默认值
                    if($total_type=='distinct_count'||$total_type=='count'){
                        $total_columns[$i]['typeofdata_decimal'] = $newtotal_columns_tmp['typeofdata_decimal'] = 0;
                    }else{
                        $total_columns[$i]['typeofdata_decimal'] = $newtotal_columns_tmp['typeofdata_decimal'] = 2;
                    }
                }

                if($total_type=='avg'){
                    $countTemp[$columodulename] = " count($column[0].$column[1])";
                    //判断该模块是否有币种字段 没有币种字段则不换算
                    if(($bigtype=='currency'||$bigtype=='amount')&&isHaveCurrrencyColumn($columodulename))
                    {
                        //zkt 20220513 51766（http://tuvaustria.gnway.cc/crm/）首页》销售排行榜（开案金额），成员Vanessa Wang，显示的是96.69元，实际成交了635美元，报表的汇率转换错误
                        $fieldTemp[$columodulename][] =  " sum(if(ifnull($tmp_maintablename.currency_id,1)=1,$column[0].$column[1],$column[0].$column[1]/$tmp_maintablename.conversion_rate)) ";

                    }
                    else
                        $fieldTemp[$columodulename][] = " sum($column[0].$column[1])";

                } else if($total_type=='distinct_count') {
                    $fieldTemp[$columodulename][] = " count(DISTINCT $column[0].$column[1])";
                } else{

                    if(($bigtype=='currency'||$bigtype=='amount')&&in_array($total_type,['sum','max','min'])&&isHaveCurrrencyColumn($columodulename))
                    {
                        //zkt 20220513 51766（http://tuvaustria.gnway.cc/crm/）首页》销售排行榜（开案金额），成员Vanessa Wang，显示的是96.69元，实际成交了635美元，报表的汇率转换错误
                        $fieldTemp[$columodulename][] =  " ".$total_type."(if(ifnull($tmp_maintablename.currency_id,1)=1,$column[0].$column[1],$column[0].$column[1]/$tmp_maintablename.conversion_rate)) ";

                    }
                    else
                        $fieldTemp[$columodulename][] = " $total_type($column[0].$column[1])";
                }

                $total_columns[$i]['bigtype'] = $newtotal_columns_tmp['bigtype'] = $bigtype;

                $this->columnstables[$fieldindex2] = [];
                if(!isset($this->relatedmoduletables[$column_relatemodule])){
                    $this->relatedmoduletables[$column_relatemodule] = [];
                }
                $this->columnsjoinTable[$fieldindex2] = $this->groupbyjoinTable ;
                $this->columnstables[$fieldindex2] = array_merge($this->columnstables[$fieldindex2],$this->groupbytables,$this->relatedmoduletables[$column_relatemodule]);

                if(!in_array($column[0],$this->columnstables[$fieldindex2])){
                    $mainTable = $this->focus->table_name;
                    $mainIndex = $this->focus->table_index;
                    $mainDetail = $this->focus->Detail_table;
                    $mainDetailField = $mainDetail . '.' . $this->focus->Detail_table_index;
                    if(!in_array($column[0],$this->columnstables[$fieldindex2]) && $column[0]==$mainDetail)
                    {
                        //zxm 2022-6-7 跟明细表关联 关联的字段是Detail_table_index
                        $this->columnsjoinTable[$fieldindex2] .= "  left join $column[0] on $mainDetailField = $mainTable.$mainIndex ";
                        if($column[0]!=$tmp_maintablename)
                        {
                            $this->columnstables[$fieldindex2][]=$column[0];
                        }
                    }
                    else if(array_key_exists($column[0],$this->focus->tab_name_index )){
                        //zxm 2022-08-29 跟主表自定义表表关联 关联的字段是Detail_table_index
                        $this->columnsjoinTable[$fieldindex2] .= "  left join $column[0] on $column[0].$mainIndex = $mainTable.$mainIndex ";
                        if($column[0]!=$tmp_maintablename)
                        {
                            $this->columnstables[$fieldindex2][]=$column[0];
                        }
                    }
                    else if(!empty($column_relatemodule)) {
                        //相关模块的字段
                        $relatetablejoinobj = cls_TableJoin_module::getInstance($this->mainmodule, $column_relatemodule);
                        $relatetablejoinobj->getJoin();
                        $tmpjoin_arr = $relatetablejoinobj->getRelatedJoinSql($column[0]);

                        $column_relatemoduleFcous = CRMEntity::getInstance($column_relatemodule);
                        $relateTable = $column_relatemoduleFcous->table_name;
                        $relateIndex = $column_relatemoduleFcous->table_index;
                        // array_push($this->columnstables[$fieldindex], $tmpjoin_arr['jointable']);
                        //edit: xll 2024/03/22 BUG20240322-28 相关模块选自定义字段的问题，去掉 ['joinsql'] 中的 left join
                        if (in_array($column[0], $column_relatemoduleFcous->customFieldTable)) {
                            //自定义表
                            $tmpjoin_arr['joinsql'] .= " left join $column[0] on $column[0].$relateIndex = $relateTable.$relateIndex ";
                            $this->relatemoduleJoinSql_arr[$column_relatemodule][] = $tmpjoin_arr;
                            $this->columnstables[$fieldindex2][] = $column[0];
                        }
                        //getotalcolumns 函数
                        $tmpdetailtable=$column_relatemoduleFcous->Detail_table;
                        $tmpdetailtablescf=$column_relatemoduleFcous->Detail_table_scf;
                        $tmpdetailtableindex = $column_relatemoduleFcous->Detail_table_index ;
                        if (!in_array($column[0], $this->columnstables[$fieldindex2]) && ($column[0] == $tmpdetailtable || $column[0] == $tmpdetailtablescf)) {
                            $Detail_table_index = $column_relatemoduleFcous->Detail_table_index;
                            if(!in_array($tmpdetailtable,$this->columnstables[$fieldindex2]))
                            {
                                $this->columnstables[$fieldindex2][]=$tmpdetailtable;
                                $tmpjoin_arr['joinsql']=" left join $tmpdetailtable on  $tmpdetailtable.$Detail_table_index = $relateTable.$relateIndex ";
                            }

                            if ($column[0] == $tmpdetailtablescf) {
                                $Detail_table_id=$column_relatemoduleFcous->Detail_table_id;
                                $tmpjoin='';
                                if(!in_array($tmpdetailtable,$this->columnstables[$fieldindex2]) )
                                {
                                    $tmpjoin=' left  join ';

                                }
                                $tmpjoin_arr['joinsql'] .= " $tmpjoin  $tmpdetailtablescf on $tmpdetailtablescf.$Detail_table_id=$tmpdetailtable.$Detail_table_id ";
                                $this->columnstables[$fieldindex2][]=$tmpdetailtablescf;
                            }

                            //zxm 20230526 BUG0067086 报表分析，新建统计图，实心饼图，按产品名称统计，统计合同编号的数量，没有显示图
                            $this->relatemoduleJoinSql_arr[$column_relatemodule][] = $tmpjoin_arr;
                        }
                    }
                    //getotalcolumns 函数
                    $mainDetailScf = $this->focus->Detail_table_scf;

                    if (!in_array($column[0], $this->columnstables[$fieldindex2]) && ($column[0] == $mainDetail || $column[0] == $mainDetailScf)) {
                        //求和字段是明细表的住表
                        if (!in_array($mainDetail, $this->columnstables[$fieldindex2])){
                            $this->columnsjoinTable[$fieldindex2] .= " left  join " . $mainDetail . " on " . $this->focus->table_name . "." . $this->focus->table_index . "=" . $mainDetailField . " ";
                            $this->columnstables[$fieldindex2][] = $mainDetail;
                        }
                        if ($column[0] == $mainDetailScf) {
                            $mainDetailScfIndex = $this->focus->Detail_table_id;
                            $mainDetailScfField = $mainDetailScf . '.' . $mainDetailScfIndex;
                            //求和字段是明细表的自定义表表
                            $this->columnsjoinTable[$fieldindex2] .= " left  join " . $mainDetailScf . " on " . $mainDetail . "." . $mainDetailScfIndex . "=" . $mainDetailScfField . " ";
                            $this->columnstables[$fieldindex2][] = $mainDetailScf;
                        }
                    }

                }


                if('prev_growth'==$compare_select||'prev_growth_percent'==$compare_select){
                    $tmpkey = $total_type.$columns_str.'cur'.$column_module;
                    if(!in_array($tmpkey,$haveFieldColumns)){
                        $fieldindex2++;
                        $this->columnsjoinTable[$fieldindex2] = $this->columnsjoinTable[$fieldindex2-1];
                    }
                    $tmpkey = $total_type.$columns_str.'prev'.$column_module;
                    if(!in_array($tmpkey,$haveFieldColumns)){
                        $fieldindex2++;
                        $this->columnsjoinTable[$fieldindex2] = $this->columnsjoinTable[$fieldindex2-1];
                    }
                }
                if('prev_growth_lastyear'==$compare_select||'prev_growth_percent_lastyear'==$compare_select){
                    $tmpkey = $total_type.$columns_str.'cur'.$column_module;
                    if(!in_array($tmpkey,$haveFieldColumns)){
                        $fieldindex2++;
                        $this->columnsjoinTable[$fieldindex2] = $this->columnsjoinTable[$fieldindex2-1];
                    }
                    $tmpkey = $total_type.$columns_str.'prev_lastyear'.$column_module;
                    if(!in_array($tmpkey,$haveFieldColumns)){
                        $fieldindex2++;
                        $this->columnsjoinTable[$fieldindex2] = $this->columnsjoinTable[$fieldindex2-1];
                    }
                }
                $fieldindex2++;

            }
            $module_arr=[$this->mainmodule];
            if(is_array($relatemodule_arr))
                $module_arr=array_merge($module_arr,$relatemodule_arr);
            $module_arr=array_unique($module_arr);
            foreach($module_arr as $tmpmodule)
            {
                if(!array_key_exists($tmpmodule,$fieldTemp)||empty($tmpmodule))
                {
                    continue;
                }
                if($total_type=='avg') {

                    //$countTemp = '('.implode('+', $fieldTemp[$tmpmodule]).')';
                    $sumTemp = '('.implode('+', $fieldTemp[$tmpmodule]).')';
                    $tmp_fieldTemp = '('.$sumTemp.'/'.$countTemp[$tmpmodule].') as co';
                }else{
                    $tmp_fieldTemp = implode('+',$fieldTemp[$tmpmodule]);
                    $tmp_fieldTemp = '('.$tmp_fieldTemp.') as co';
                }

                //echo $tmp_fieldTemp;
                //  $this->field_arr[$tmpmodule][] = $tmp_fieldTemp;

                //prev_growth
                //prev_growth_percent 如果要计算环比增长值 环比增长率  需要计算本期和上期数据 如果用户没有选择这个统计值 需要追加

//                if(in_array('prev_growth',$oldcompare_select_arr)
//                    ||in_array('prev_growth_percent',$oldcompare_select_arr)){
                if('prev_growth'==$compare_select||'prev_growth_percent'==$compare_select){
                    $tmpkey = $total_type.$columns_str.'cur'.$column_module;
                    if(!in_array($tmpkey,$haveFieldColumns)){
                        $this->rowfield_arr[$fieldindex][$tmpmodule][]=$tmp_fieldTemp.$fieldindex.'_cur';
                        $haveFieldColumns[] = $tmpkey;
                        $this->compare_select_arr[$fieldindex]='cur';
                        $newtotal_columns[$fieldindex] = [];
                        $newtotal_columns_unique[$fieldindex] = [$total_type,$columns_str,'cur',$column_module];
                        $fieldindex++;
                    }
                    $tmpkey = $total_type.$columns_str.'prev'.$column_module;
                    if(!in_array($tmpkey,$haveFieldColumns)){
                        $this->rowfield_arr[$fieldindex][$tmpmodule][]=$tmp_fieldTemp.$fieldindex.'_prev';
                        $haveFieldColumns[] = $tmpkey;
                        $this->compare_select_arr[$fieldindex]='prev';
                        $newtotal_columns[$fieldindex] = [];
                        $newtotal_columns_unique[$fieldindex] = [$total_type,$columns_str,'prev',$column_module];
                        $fieldindex++;
                    }
                }
                //print_r($this->compare_select_arr);
                //prev_growth_lastyear
                //prev_growth_percent_lastyear
//                if(in_array('prev_growth_lastyear',$oldcompare_select_arr)
//                    ||in_array('prev_growth_percent_lastyear',$oldcompare_select_arr)){
                if('prev_growth_lastyear'==$compare_select||'prev_growth_percent_lastyear'==$compare_select){
                    $tmpkey = $total_type.$columns_str.'cur'.$column_module;
                    if(!in_array($tmpkey,$haveFieldColumns)){
                        $this->rowfield_arr[$fieldindex][$tmpmodule][]=$tmp_fieldTemp.$fieldindex.'_cur';
                        $haveFieldColumns[] = $tmpkey;
                        $this->compare_select_arr[$fieldindex]='cur';
                        $newtotal_columns[$fieldindex] = [];
                        $newtotal_columns_unique[$fieldindex] = [$total_type,$columns_str,'cur',$column_module];;;
                        $fieldindex++;
                    }
                    $tmpkey = $total_type.$columns_str.'prev_lastyear'.$column_module;
                    if(!in_array($tmpkey,$haveFieldColumns)){
                        $this->rowfield_arr[$fieldindex][$tmpmodule][]=$tmp_fieldTemp.$fieldindex.'_prev_lastyear';
                        $haveFieldColumns[] = $tmpkey;
                        $this->compare_select_arr[$fieldindex]='prev_lastyear';
                        $newtotal_columns[$fieldindex] = [];
                        $newtotal_columns_unique[$fieldindex] = [$total_type,$columns_str,'prev_lastyear',$column_module];
                        $fieldindex++;
                    }
                }
                $this->rowfield_arr[$fieldindex][$tmpmodule][]=$tmp_fieldTemp.$fieldindex;
                if(!in_array($compare_select,['prev_growth','prev_growth_percent','prev_growth_lastyear','prev_growth_percent_lastyear'])){
                    $this->rowfieldalias_arr[] = 'co'.$fieldindex;
                }

                $this->compare_select_arr[$fieldindex]=$compare_select;
                $newtotal_columns_tmp['realcolumns'] = 'co'.$fieldindex;//SQL结果获取的时候需要这个值
                $newtotal_columns[$fieldindex] = $newtotal_columns_tmp;
                $newtotal_columns_unique[$fieldindex] = [$total_type,$columns_str,$compare_select,$column_module];
                $fieldindex++;

            }

        }
        $this->columns = $total_columns;
        $this->newtotal_columns_unique = $newtotal_columns_unique;
        return $newtotal_columns;
        //return $total_columns;
    }

    /**
     * @param $groupBy
     * @param $limit
     * @return string
     * 时间格式化sql
     */
    public function getSeqNew($groupInfo,$limit,$query_forbytime){
        $groupbytype = $groupInfo['groupbytype'];
        $groupcolumns = $groupInfo['groupcolumns'];
        $groupcolumns_arr = explode(':',$groupcolumns);
        $where = '';
        if(!empty($this->timeRange)){
            $mintimesql = $this->timeRange[0];
            $maxtimesql = $this->timeRange[1];
            $where = " BETWEEN '$mintimesql' AND '$maxtimesql' ";
        }else {
            $query_forbytime = str_replace('{groupbytimefield}', $groupcolumns_arr[0] . '.' . $groupcolumns_arr[1] . ' as groupcolumn0 ', $query_forbytime);
            //$mintimesql = " select min(groupcolumn0) FROM (" . $query_forbytime . ")a WHERE groupcolumn0 >'1970-1-1'";
            //$maxtimesql = " select max(groupcolumn0) FROM (" . $query_forbytime . ")a WHERE groupcolumn0 >'1970-1-1'";
            //$where = " BETWEEN ($mintimesql) AND ($maxtimesql) ";
            //zxm @date:2024/12/31 @reason: 把最大最小时间查出来 SQL复杂
            $timesql = " select min(groupcolumn0)as mintime, max(groupcolumn0) as maxtime FROM (" . $query_forbytime . ")a WHERE groupcolumn0 >'1970-1-1'";

            $timeres = $this->adb->pquery($timesql);
            $timenums = $this->adb->num_rows($timeres);

            if($timenums>0){
                $mintimesql = $this->adb->query_result($timeres,0,'mintime');
                $maxtimesql = $this->adb->query_result($timeres,0,'maxtime');
                $where = " BETWEEN '$mintimesql' AND '$maxtimesql' ";
            }
        }

        switch ($groupbytype){
            case "byYear":
                $dateField = "DATE_FORMAT(date,'%Y')";
                break;
            case "byMonth":
                $dateField = "DATE_FORMAT(date,'%Y-%m')";
                break;
            case "byQuarter":
                $dateField = "concat(YEAR(date),'第',QUARTER(date),'季度')";
                break;
            case "byWeek":
                $dateField = "DATE_FORMAT(date,'%Y-%u')";
                break;
            /*case "byDay":
                $dateField = "DATE_FORMAT(date,'%Y-%m-%d')";
                break;*/
            default:
                //默认按天吧
                $dateField = "DATE_FORMAT(date,'%Y-%m-%d')";
                break;
        }
        $seq_sql = "SELECT
		$dateField AS target_period
	FROM tmp_date a
	WHERE `date` $where 
	GROUP BY $dateField ";
        if($limit>0){
            $seq_sql = "select * from (select * from ($seq_sql)a order by target_period desc limit $limit)a order by target_period asc ";
        }

        return $seq_sql;
    }
    /**
     * @param $field_name
     * @param $groupBy
     * @param $compare_select  当期 同环比
     * @return string[]|string[][]
     * 获取分组条件为时间的时候 格式化得名称以及字段sql
     */
    public function getDimensionOfTime($field_name,$groupBy,$compare_select){
        //年 季度 月度  周  日
        //DATE_FORMAT(ld_salesorder.signed_data,'%Y-%m')

        if(in_array($compare_select,['prev','prev_growth','prev_growth_percent'])){
            $groupByQuarter = [
                'byYear'=>'1 YEAR',
                'byQuarter'=>'3 MONTH',
                'byMonth'=>'1 MONTH',
                'byWeek'=>'1 WEEK',
                'byDay'=>'1 DAY',
            ];
            //环比步长
            $comparestep = $groupByQuarter[$groupBy];
            //环比上期
            $field_name = "DATE_ADD($field_name, INTERVAL ".$comparestep.")";
        }else if(in_array($compare_select,['prev_lastyear','prev_growth_lastyear','prev_growth_percent_lastyear'])){
            //同比上期
            $field_name = "DATE_ADD($field_name, INTERVAL 1 YEAR)";
        }

        $arr = [
            'byYear'=>['name'=>'日期（年度）','sqlBy'=>"DATE_FORMAT($field_name,'%Y')"],
            'byQuarter'=>['name'=>'日期（季度）','sqlBy'=>"concat(Year($field_name),'第',quarter($field_name),'季度')"],
            'byMonth'=>['name'=>'日期（月度）','sqlBy'=>"DATE_FORMAT($field_name,'%Y-%m')"],
            'byWeek'=>['name'=>'日期（周）','sqlBy'=>"DATE_FORMAT($field_name,'%Y-%u')"],
            'byDay'=>['name'=>'日期（日）','sqlBy'=>"DATE_FORMAT($field_name,'%Y-%m-%d')"],
        ];
        if(empty($groupBy)||!isset($arr[$groupBy])){
            return $arr;
        }
        return $arr[$groupBy];
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
            'mainmodule'=>'Accounts',
            'createdtime'=>'',
            'modify_time'=>'',
            'modify_id'=>'',
            'limit'=>'0',
            'orderby'=>'',
            'orderby_type'=>'desc',
            'stat_approach'=>'',
            'isshow_search'=>'yes',
            'isshow_table'=>'Bottom',
            'analysisfolder_id'=>'1',
            'show_athome_info'=>[],
            'th_nums'=>'1',
            'table'=>'',
            'chart_type_name'=>'',
            'AxisFields' => [
                'XAxis' => [],
                'YAxis' => [],
            ],
            'SeqSet' => [
                [
                    'SeqField' => '',
                    'SeqMethod' => '',
                    'SeqType' => '',
                ],
            ],
            'OtherCondition' => [
                'computemodule' => '',
                'advance_demand' => '',
                'advance_demand_groups' => '',
            ],
            'mode' => 'create',
        ];
        return $ChartSetInfo;
    }
    //获取高级查找里面第一个分组时间字段时间范围
    /**1.如果没有设置高级查找条件或者没有设置统计维度时间字段的时间条件：直接按单据的最早时间和最晚时间 限制显示X轴刻度值
    2.如果设置了统计维度时间字段的时间条件：以这个时间条件为限制显示X轴刻度值
    3.如果这个组件放看板了：
    A选择关联看板筛选条件：以看板时间筛选限制X轴刻度值
    B不关联看板筛选条件：同1和2判断
     **/
    public function getFirstAdvTimeRange($groupInfo,$advanceInfo){
        //$timeRange = [date('Y-01-01'),date('Y-12-31')];
        $timeRange = [];

        $advance_demand = $advanceInfo['advance_demand'];
        $advance_demand_groups = $advanceInfo['advance_demand_groups'];

        $groupbycolumn = $groupInfo['groupcolumns'];
        $groupbytype = $groupInfo['groupbytype'];
        if ($advance_demand == '[]' && $advance_demand_groups == '[]') {
            return $timeRange;
        }
        $advance_demand_arr = Zend_Json::decode($advance_demand);
        $prevadvance_demand_arr = $advance_demand_arr;
        $prev_lastyearadvance_demand_arr = $advance_demand_arr;

        foreach($advance_demand_arr  as $k=>$lineAdv){
            if($lineAdv['columnname']==$groupbycolumn){
                $timeRange = explode(',',$lineAdv['value']);

                //环比上期时间
                crm_load_class_file('ReportAnalysisUtils','modules/ReportAnalysis');
                $prevTimeRange = ReportAnalysisUtils::getHuanbiTimeRange($groupbytype,$timeRange);
                $prevTimeRangeStr = implode(',',$prevTimeRange);

                $prevadvance_demand_arr[$k]['comparator'] = 'bw';
                $prevadvance_demand_arr[$k]['value'] = $prevTimeRangeStr;
                //同比上期时间
                $prev_lastyearTimeRange = ReportAnalysisUtils::getTongbiTimeRange($timeRange);
                $prev_lastyearTimeRangeStr = implode(',',$prev_lastyearTimeRange);
                $prev_lastyearadvance_demand_arr[$k]['comparator'] = 'bw';
                $prev_lastyearadvance_demand_arr[$k]['value'] = $prev_lastyearTimeRangeStr;
                break;
            }
        }

        $this->prevAdvanceInfo['advance_demand'] = Zend_Json::encode($prevadvance_demand_arr);;//环比上期的高级条件
        $this->prevAdvanceInfo['advance_demand_groups'] = $advance_demand_groups;
        $this->prev_lastyearAdvanceInfo['advance_demand'] = Zend_Json::encode($prev_lastyearadvance_demand_arr);;//同比上期的高级条件
        $this->prev_lastyearAdvanceInfo['advance_demand_groups'] = $advance_demand_groups;
        return $timeRange;
    }

    public function getTranslateFieldAllArr($groupInfo){
        $groupcolumns_arr = explode(':',$groupInfo['groupcolumns']);
        $module_arr = explode('_',$groupcolumns_arr[3]);
        $translatefield_value = getTranslateDbValueNew($module_arr[0],$groupcolumns_arr[1]);
        $translatefield_arr = [];
        foreach($translatefield_value as $k=>$v){
            $translatefield_arr[$k] = getFixedLabel($v['labelbol']);
        }
        return $translatefield_arr;
    }

}
