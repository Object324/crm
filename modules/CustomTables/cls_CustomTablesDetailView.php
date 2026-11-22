<?php
crm_load_class_file("cls_ComputerSql","modules/CustomTables/ComputerSql");
crm_load_class_file("cls_TableJoin_module",'include/fields');
crm_load_class_file("ReportTableWhere",'modules/CustomTables/Query');

class cls_CustomTablesDetailView
{
    public $CustomTablesActionsObj;
    public $total_typenumber = "10";//默认底部
    public $module_arr;//模块数组
    public $relatedModule;//相关模块数组
    public $mainmodule;//主模块
    public $column_arr;//统计字段数组
    public $groupcolumn_arr;//分组字段数组
    public $maxcolumn_arr;//求最大值字段 数组
    public $mincolumn_arr;//求最小值字段 数组
    public $sumcolumn_arr;//求和字段 数组
    public $avgcolumn_arr;//求均值字段 数组
    public $countcolumn_arr;//计数字段 数组
    public $mergeColumn_arr;
    public $sorting_list_all; //zxm20220719
    public $sorting_list_bycolumnname; //zxm20220719
    public $sorting_list_byresult; //zxm20220719
    public $group_sql_statistic;//安分组字段 统计字段组合的子sql zxm20220719
    public $aliasArr = [
        'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
        'aa','ba','ca','da','ea','fa','ga','ha','ia','ja','ka','la','ma','na','oa','pa','qa','ra','sa','ta','ua','va','wa','xa','ya','za',
        'ab','bb','cb','db','eb','fb','gb','hb','ib','jb','kb','lb','mb','nb','ob','pb','qb','rb','sb','tb','ub','vb','wb','xb','yb','zb',
        'ac','bc','cc','dc','ec','fc','gc','hc','ic','jc','kc','lc','mc','nc','oc','pc','qc','rc','sc','tc','uc','vc','wc','xc','yc','zc'
    ];//少的话可以再加
    public $distinctcountcolumn_arr;//唯一计数字段 数组
    public $asfixedname;

    public $fields = [];//统计字段
    public $tableIndexFieldArr;//统计字段--各个表的主键字段
    public $fieldsAlias=[];//统计字段别名
    public $fieldsFormulaArr=[];//公式字段别名--
    public $fieldsCurrencySymbol;//字段 -币种符号
    public $fieldsTableHeader;
    public $conditionSql;//条件子sql
    public $typevalue_arr = [];
    public $ordercolumn_arr = [];
    public $sqlOrdercolumn_arr = [];
    public $ordercolumn_suff="_order";
    public $selectColumnFrom;
    public $selectColumnTable_arr = [];
    public $limit;
    public $report_id;
    public $computerfunText_arr = [];
    public $computerfunColor_arr = [];//颜色
    public $firstrColumnComputer_type;//第一列是计算字段的函数类型
    public $detail_type;
    public $sum_type;
    public $max_type;
    public $min_type;
    public $count_type;
    public $avg_type;
    public $wheremodule_arr = [];//有查询条件的模块
    public $distinctcount_type;
    public $show_detail = 'yes';
    public $DetailDableIdField;//明细表的lineitem_id
    public $params;//$_request参数
    public $reportConditions = array();//查看页面的条件数组  包含条件信息和group信息
    public function __construct($params){
        $report_id = $params['report_id'];
        $this->report_id=$report_id;
        $this->params=$params;

        include_once globalStatic::$root_directory.'modules/CustomTables/CustomTablesActions.php';
        $this->asfixedname='belong';
        $this->typevalue_arr=[];
        $this->wheremodule_arr=[];
        $this->CustomTablesActionsObj = new CustomTablesActions();
        $this->detail_type='detail';
        $this->sum_type='sumgroup';
        $this->avg_type='avg';
        $this->max_type='max';
        $this->min_type='min';
        $this->count_type='count';
        $this->distinctcount_type='distinctcount';

        $this->typevalue_arr[$this->detail_type]=1;
        $this->typevalue_arr[$this->sum_type]=2000;
        $this->typevalue_arr[$this->avg_type]=2300;
        $this->typevalue_arr[$this->max_type]=2600;
        $this->typevalue_arr[$this->min_type]=2900;
        $this->typevalue_arr[$this->count_type]=3200;
        $this->typevalue_arr[$this->distinctcount_type]=3500;
        $this->typevalue_arr['alltotal']=10000;
        $this->limit=200;
        $this->firstrColumnComputer_type=[];
        $this->computerfunText_arr=[
            $this->count_type=>getFixedLabel('COUNT').'：',
            $this->distinctcount_type=>getFixedLabel('UCOUNT').'：',
            $this->max_type=>getFixedLabel('MAXVALUE').'：',
            $this->min_type=>getFixedLabel('MINVALUE').'：',
            $this->avg_type=>getFixedLabel('AVGVALUE').'：',
            $this->sum_type=>getFixedLabel('SUBTOTAL').'：'
        ];//小计行名称
        $this->computerfunColor_arr=[
            $this->count_type=>'#EEEEEE',
            $this->distinctcount_type=>'#EEEEEE',
            $this->max_type=>"#EEEEEE",
            $this->min_type=>"#EEEEEE",
            $this->avg_type=>"#EEEEEE",
            $this->sum_type=>'#EEEEEE'
        ];//小计行颜色
        $this->maxcolumn_arr=[];
        $this->mincolumn_arr=[];
        $this->sumcolumn_arr=[];
        $this->groupcolumn_arr=[];
        $this->avgcolumn_arr=[];


    }
    //自定义统计表放首页  首页不传字段信息和条件信息过来 需要从数据库读取
    public function setParams(){
        if(!isset($this->params['columns'])&&$this->report_id>0){
            //将字段参数传进去
            $reportInfo = $this->CustomTablesActionsObj->getReportInfo($this->report_id);
            $columnsInfo = $reportInfo['columnsArr'];
            $this->column_arr = $columnsInfo;

            //统计字段处理--从数据库读取信息 --前端未传
            $this->params['columns'] = _array_column($columnsInfo,'columns');//统计字段
            $this->params['columnmodule'] = _array_column($columnsInfo,'columnmodule');//统计字段所属模块
            $this->params['modulelabel'] = _array_column($columnsInfo,'modulelabel');//统计字段来自模块名称
            $this->params['fieldlabel'] = _array_column($columnsInfo,'fieldlabel');//统计字段名称
            $this->params['bigtype'] = _array_column($columnsInfo,'bigtype');//统计字段bigtype
            $this->params['typeofdata'] = _array_column($columnsInfo,'typeofdata');//统计字段typeofdata
            $this->params['is_group'] = _array_column($columnsInfo,'is_group');//统计字段是否是分组条件
            $this->params['order_by'] = _array_column($columnsInfo,'order_by');//统计字段排序条件
            $this->params['is_merge'] = _array_column($columnsInfo,'is_merge');//统计字段是否合并
            $this->params['total_type'] = _array_column($columnsInfo,'total_type');//统计字段是否合并
            $this->params['align'] = _array_column($columnsInfo,'align');//统计字段对齐方式
            $this->params['alias'] = _array_column($columnsInfo,'alias');//统计字段别名
            $this->params['prefix'] = _array_column($columnsInfo,'prefix');//前缀
            $this->params['suffix'] = _array_column($columnsInfo,'suffix');//后缀
            $this->params['decimal_places'] = _array_column($columnsInfo,'decimal_places');//小数位数
            $this->params['issticky'] = _array_column($columnsInfo,'issticky');//是否列固定
            //报表信息
            $this->params['total_position'] = $reportInfo['total_position'];
            $this->params['show_detail'] = $reportInfo['show_detail']=='yes'?'on':'';
            $this->params['report_name'] = $reportInfo['report_name'];
        }
        if(!isset($this->params['cvadvfilter'])&&$this->report_id>0){
            //条件
            $conditionInfo = $this->CustomTablesActionsObj->getReportConditionadv($this->report_id);
            $this->params['cvadvfilter'] = _array_column($conditionInfo,'columns');
            $this->params['comparator'] = _array_column($conditionInfo,'comparator');
            $this->params['groupid'] = _array_column($conditionInfo,'groupid');//条件所属分组id
            $this->params['columncondition'] =_array_column($conditionInfo,'columncondition');//组内条件之间的关系
            $values =_array_column($conditionInfo,'value');
            foreach($values as $value){
                $value_arr = explode(',',$value);
                $this->params['value1'][] = $value_arr[0];
                $this->params['value2'][] = $value_arr[1];
            }

            //获取条件分组数据 zxm 20220630
            $conditionGroupInfo = $this->CustomTablesActionsObj->getReportConditionGrouping($this->report_id);

            $this->params['group_condition_id'] =_array_column($conditionGroupInfo,'groupid');
            $this->params['group_condition'] =_array_column($conditionGroupInfo,'group_condition');
        }
    }
    //详情页面
    public function index(){
        $report_id = $this->report_id;
        $params = $this->params;

        $this->CustomTablesActionsObj->smarty->assign("report_id",$report_id);
        /*$timeValueArr = $this->CustomTablesActionsObj->getComparatorValue();
        $this->CustomTablesActionsObj->smarty->assign('timeValueArr',json_encode($timeValueArr,JSON_UNESCAPED_UNICODE));*/
        //报表信息
        $reportInfo = $this->CustomTablesActionsObj->getReportInfo($report_id);

        $this->CustomTablesActionsObj->smarty->assign("report_info",$reportInfo);

        if($params['limitrecord'])
        {
            $this->CustomTablesActionsObj->smarty->assign("LimitRecord",$params['limitrecord']);
        }
        else{
            $this->CustomTablesActionsObj->smarty->assign("LimitRecord",$this->limit);

        }
        $templatename = 'detailview.tpl';
        $this->CustomTablesActionsObj->smarty->assign("mode",'detail');
        $this->CustomTablesActionsObj->smarty->assign("iskehu001",isKehu001ServerPc());
        $this->CustomTablesActionsObj->smarty->assign("frommobile",$params['frommobile']);
        if($params['frommobile']=='yes'){
            //移动端查看页
            $corpurl_all = getCorpUrl();
            $corpurl_arr = explode('WeiXinApp',$corpurl_all);
            $this->CustomTablesActionsObj->smarty->assign("JSURL",$corpurl_arr[0]);
            $this->CustomTablesActionsObj->smarty->assign("CSSURL",$corpurl_arr[0]);
            $this->CustomTablesActionsObj->smarty->assign("CRMCOMMONURL",$corpurl_arr[0]);
            //zxm 20230423 app端的判断
            global $PlatformMC;
            if(array_key_exists('isnativeapp',$PlatformMC)&&$PlatformMC['isnativeapp']=='yes')
            {
                $encryptobj=new cls_MyCRMcrypt();
                $this->CustomTablesActionsObj->smarty->assign("wx_userid",$encryptobj->encode($params['userid']));
                $this->CustomTablesActionsObj->smarty->assign("appusertoken",$params['appusertoken']);
            }else{
                $this->CustomTablesActionsObj->smarty->assign("wx_userid",$params['userid']);
            }

            //来自移动端
            global $weixin_user;
            if($weixin_user->environment=='wxwork'||$weixin_user->environment=='weixin'){
                //小程序
                $homefile = "index_mini.php";
            }else if(array_key_exists('isnativeapp',$PlatformMC)&&$PlatformMC['isnativeapp']=='yes') {
                //app
                $homefile = "indexnative.php";
            }else{
                //企业微信
                //云之家
                //钉钉
                $homefile = "index.php";
            }
            $this->CustomTablesActionsObj->smarty->assign("homefile",$homefile);
        }
        if($params['isAjax']=="no"){
            $this->CustomTablesActionsObj->smarty->assign("isAjax",$params['isAjax']);
            $this->CustomTablesActionsObj->smarty->display('CustomTables/'.$templatename);
        }else{
            $content = $this->CustomTablesActionsObj->smarty->fetch('CustomTables/'.$templatename);
            $params['diony']='diony';
            $res['content'] = $content;
            $res['permit_print'] = isPermitted('ReportAnalysis','Print');
            $res['permit_export'] = isPermitted('ReportAnalysis','Export');
            $res['permit_create'] = isPermitted('ReportAnalysis','Create');
            $res['title'] = $reportInfo['report_name'];
            ConvertTojsonString(1,$res,'success');
        }

    }
    //ajax获取图表数据
    public function getDetailData()
    {
        global $currentModule, $current_user;
        $this->setParams();//详情页 页面没有传字段参数  首页没传条件 参数
        $params = $this->params;

        //判断最终合计在顶部还是底部
        $total_position = $params['total_position'];
        //是否显示明细
        $show_detail = $params['show_detail'];//on
        //直接不显示明细 则明细sql不需要获得
        $sql_arr = [];

        $this->initParam();//初始化参数
        $this->conditionSql = $this->getDetailCondition();

        if(empty($show_detail)||$show_detail!="on") {
            //直接不显示明细 则明细sql不需要获得
        }else{
            $detail_sql = $this->getDetailedSql();//明细sql
            $sql_arr[] = $detail_sql;
        }

        //分组求和sql
        $group_count = count($this->groupcolumn_arr);

        $groupbysumsql = $this->getGroupBySumSql();//合计
        if(!empty($groupbysumsql)){
            $sql_arr[] = $groupbysumsql;
        }

        $maxsql=$this->getGroupByMaxSql();//最大值
        if(!empty($maxsql))
        {
            $sql_arr[] = $maxsql;
        }

        $minsql=$this->getGroupByMinSql();//获取最小值
        if(!empty($minsql))
        {
            $sql_arr[] = $minsql;
        }

        $countsql=$this->getGroupByCountSql();//计数
        if(!empty($countsql))
        {
            $sql_arr[] = $countsql;
        }

        $distinctcountsql=$this->getGroupByDistinctCountSql();//唯一计数

        if(!empty($distinctcountsql))
        {
            $sql_arr[] = $distinctcountsql;
        }
        $avgsql=$this->getGroupByAvgSql();//均值
        if(!empty($avgsql))
        {
            $sql_arr[] = $avgsql;
        }

        $sql_str = implode(' union all ',$sql_arr);
        $orderbycolumn_arr = array_filter($this->sqlOrdercolumn_arr);

        if(sizeof($orderbycolumn_arr))
            $orderby= implode(" ,",$orderbycolumn_arr);

        $GroupLeftJoinSql = '';

        if(sizeof($this->sorting_list_byresult)>0&&$this->show_detail!='yes')
        {
            //有统计结果排序的字段
            crm_load_class_file('cls_SetOrderBy','modules/CustomTables');
            $SetOrderByobj=new cls_SetOrderBy($this);
            $SetOrderByobj->setGroupLeftJoin();
            //设置分组排序的left join 子查询
            $GroupLeftJoinSql = $SetOrderByobj->groupLeftJoinSql;
            //设置分组排序的group by
            $orderbySql = " order by " .$SetOrderByobj->orderbySql;
        }else if(!empty($orderby)){
            $orderbySql = " order by $orderby " ;//zxm 20220722仅按列名排序的结果
        }

        $pagenum=$params['pagenum'];
        if(!isset($params['totalrows'])||$params['pagenum']<=1)
        {
            $totalrows = 0;
            if(!empty($sql_str)) {
                $countsql = "select 1 from ($sql_str)a";
                $result = $this->CustomTablesActionsObj->adb->pquery($countsql, array());

                $totalrows = $this->CustomTablesActionsObj->adb->num_rows($result);
            }
        }
        else{
            $totalrows=$params['totalrows'];
        }
        if(isset($params['limitrecord']))
        {
            $this->limit=$params['limitrecord'];
        }else{
            $this->limit=200;
        }
        if($params['Export']=='true'){
            //导出 导出所有的数据 不分页
            $this->limit=$totalrows;
            if ($params['export_first'] == 'yes') {//第一次导出
                unset($_SESSION[$currentModule][$current_user->id]['exportReport']);
            }
            $startExportRow = $params['startExportRow'];
            $endExportRow = $params['endExportRow'];
            $eachExportCount = $endExportRow - $startExportRow;
            $listCounts = $params['listCounts'];
        }

        $fieldsFormulaArr = [];
        foreach($this->fieldsFormulaArr as $formulainfo)
        {
            foreach( $this->fieldsAlias as $tmpcolumn)
            {
                $formulainfo=str_replace($tmpcolumn,"a.$tmpcolumn",$formulainfo);
            }
            $fieldsFormulaArr[] = $formulainfo;
        }
        $fieldsAlias = [];
        foreach($this->fieldsAlias as $tmpcolumn){

            $tmpcolumn="a.$tmpcolumn";
            $fieldsAlias[] = $tmpcolumn;
        }

        $allFieldsArr = array_merge( $fieldsAlias, $fieldsFormulaArr);
        $allFieldsStr = implode(',',$allFieldsArr);
        if(empty($sql_str)){
            $nums = 0;
        }else {
            if (!empty($allFieldsStr)) {
                $sql = "select $allFieldsStr,a.type,a.type_desc from ($sql_str)a ";
            } else {
                $sql = "select a.type,a.type_desc from ($sql_str)a ";
            }
            if (!empty($orderbySql))
                $sql .= " $GroupLeftJoinSql  $orderbySql ";
            else
                $sql .= " $GroupLeftJoinSql order by  `type` asc ";

            $totalpages = ceil($totalrows / $this->limit);
            $offset = ($pagenum - 1) * $this->limit;
            $offset = $offset <= 0 ? 0 : $offset;
            if ($params['Export'] == 'true') {
                $sql .= " limit $startExportRow, " . $eachExportCount;//分批导出
            } else {
                $sql .= " limit $offset," . $this->limit;
            }

            $res = $this->CustomTablesActionsObj->adb->pquery($sql);
            $nums = $this->CustomTablesActionsObj->adb->num_rows($res);
        }
        $html = '';
        $mergeRowInfo = [];
        $errormsg = '';//错误信息
        $returnsql = '';//返回值SQL  SQL报错的时候返回 方便调试
        if($nums){
            crm_load_class_file("ShowHtmlContent",'modules/CustomTables');
            $contentobj=new ShowHtmlContent($this);
            $contentobj->setPageNum($pagenum);
            if($params['Export']=='true'){
                $contentobj->setExport(true);
            }
            $html=$contentobj->getContent($res);


            $mergeRowInfo = $contentobj->mergeRowInfo;
            $total_sql = $this->getTotalSql();//所有数据求和的sql
            if(!empty($total_sql)&&$params['Export']!='true')
            {
                $totalrows+=1;
                //合计行
                $result=$this->CustomTablesActionsObj->adb->pquery("select ".$allFieldsStr.",type,type_desc from ($total_sql) as a order by  `type` asc ");
                $html_total = $contentobj->getTotalRowContent($result);
                if($total_position == "top"){
                    $html = $html_total.$html;
                }else{
                    $html = $html.$html_total;
                }
            }
            $mergeColumnValueArr = $contentobj->getMergeColumnValueArr();
        }else{
            if($this->CustomTablesActionsObj->adb->database->ErrorNo()>0) {
                $errormsg = "ADODB error ->[" . $this->CustomTablesActionsObj->adb->database->ErrorNo() . "]" . $this->CustomTablesActionsObj->adb->database->ErrorMsg();
                $returnsql = $sql;//返回值SQL  SQL报错的时候返回 方便调试
            }
        }
        $params['diony']='diony';
        // wsh 20240814 XUQIU20240708-01 报表管理-报表分析-自定义统计表/SQL统计表 导出优化数据多的情况下做成单据列表那种的进度条导出，现在的做法数据多直接内存溢出
        if($params['Export']=='true'){

            $return_arr = $this->detailExport($html,$res,$mergeColumnValueArr);
            ConvertTojsonString($return_arr["code"],$return_arr,'success');die;
        }

        global  $current_user, $languageType;
        $languageType = getLanguageType($current_user);

        $recordListRangeMsg = '';
        $totalrows = empty($totalrows)?0:$totalrows;
        $totalpages = empty($totalrows)?1:$totalpages;
        if ($languageType == 'zh') {
            $recordListRangeMsg .= ' ' . getFixedLabel('TOTALOF') . " $totalrows" . ' ' . getFixedLabel('RECORDNUMS');
        } else {
            $recordListRangeMsg .= " $totalrows" . ' ' . getFixedLabel('DETAILRECORDNUMS');
        }

        ConvertTojsonString(1,[
            'rows'=>$nums,
            'pagerows'=>$totalrows,
            'errormsg'=>$errormsg,
            'returnsql'=>$returnsql,
            'totalpages'=>$totalpages,//总页数
            'totaldescription'=>$recordListRangeMsg,
            'content'=>$html,
            'mergeRowInfo'=>$mergeRowInfo,
            'columnsCount'=>count($this->column_arr),
            'columnsArr'=>$this->column_arr,
//            'chartInfo'=>['legend'=>['上海','北京','深圳'],'datas'=>['190','280','89']]
//            'chartInfo'=>['legend'=>_array_column($this->data_arr,0),'datas'=>_array_column($this->data_arr,3)]
        ],'success');die;
    }
    //查看页面 条件的显示
    public function getReportConditions(){
        $reportConditions = $this->CustomTablesActionsObj->getReportCondition($this->report_id);
        $timeValueArr = $this->CustomTablesActionsObj->getComparatorValue();
        $searchFieldRes = $this->getSearchField();
        ConvertTojsonString(1,[
            'reportConditions'=>$reportConditions,
            'searchFieldRes'=>$searchFieldRes,
            'timeValueArr'=>$timeValueArr,
        ],'success');die;
    }
    //// wsh 20240814 XUQIU20240708-01 报表管理-报表分析-自定义统计表/SQL统计表 导出优化数据多的情况下做成单据列表那种的进度条导出，现在的做法数据多直接内存溢出
    public function detailExport($html,$result,$allmergecolumnvalue_arr){
        global $adb,$current_user,$currentModule;
        $params = $this->params;
        $mergeArr = [];
        $report_name = $params['report_name'];
        $startExportRow = $params['startExportRow'];
        $listCounts = $params['listCounts'];
        $endExportRow = $params['endExportRow'];
        $htmlparseobj = new simple_html_dom();
        $fieldsTableHeader = $this->fieldsTableHeader;

        $csc = explode("</tr>",$html);

        $csc=array_filter($csc);

        //dump($allmergecolumnvalue_arr);//导出根据这个数组里面的数据判断
        //新建excel对象
        $file_name = $current_user->id.'_'.$report_name . '.xls';
        $file_dir = globalStatic::$root_directory.'storage/';
        require_once( globalStatic::$root_directory.'PHPExcel/PHPExcel.php');
        if(is_array($_SESSION[$currentModule][$current_user->id]['exportReport'])&&array_key_exists('objPHPExcel',$_SESSION[$currentModule][$current_user->id]['exportReport'])) {
            $objPHPExcel = PHPExcel_IOFactory::load($file_dir . $file_name);
            $prevTotalRows = $_SESSION[$currentModule][$current_user->id]['exportReport']['prevTotalRows'];
        } else {
            $objPHPExcel = new PHPExcel();
            $_SESSION[$currentModule][$current_user->id]['exportReport']['objPHPExcel']=serialize($objPHPExcel);
            $prevTotalRows = 2;
        }
        require_once globalStatic::$root_directory . 'appCommon/appCommon.php';
        if ($startExportRow <= $listCounts){
            $objPHPExcel->setActiveSheetIndex(0);
            $activesheet=$objPHPExcel->getActiveSheet();
            $column_arr = $this->column_arr;
//            dump($column_arr);
            $columnNameArr = [];
            //edit: xll 2023/08/03 BUG0070673 导出优化，系统导出的excel表格的表头应有底色，标题应加粗
            crm_load_class_file('cls_ExportListView','include/ListView/ExportListView');
            $Header_FromArray = cls_ExportListView::getListHeaderFormArray();
            foreach($column_arr as $key=>$column){
                $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key) . '1')->applyFromArray($Header_FromArray);
                $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',$column['fieldlabel']);
                $activesheet->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex($key))->setWidth(20);
                $bigtype[]=$column['bigtype'];
                $mergeArr[] = $column["merge"];
                $columnNameArr[] = explode(':',$column['columns'])[1];
            }

            foreach($csc as $kee=>&$arr) {
                $arr = explode("</td>", $arr);
            }
            foreach($csc as $kee=>$tmparr){
                $cscs = $tmparr;
                if(!empty($result)){   //判断是否为小计行 XUQIU1001388
                    $type_desc=$adb->query_result($result,$kee,'type_desc');
                }
                $for_i = 0;

                foreach ($cscs as $keyy=>$value) {
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
                                $tmpparser->outertext ='$userName='.$openid.'$';
                            }
                            else if($openid!='')
                            {
                                $tmpparser->outertext ='$departmentName='.$openid.'$';
                            }
                        }
                        $value=$htmlparseobj->innertext;
                    }
                    /*if (stripos($value, 'tag="tr_totalrow"') !== false && $prevTotalRows < $listCounts) { //去除多余的总计数
                        unset($csc[$kee]);
                        $prevTotalRows --;
                        break;
                    }*/
                    $value = strip_tags(trim($value));
                    //zxm 20231103 BUG0075394 报表分析-工单管理数据总览 非立项客户名称以及问题归属字段数据导出后字段内容缺失，原本数据为safedog，导出后为afedog
                    $value = str_replace('&nbsp;',' ',$value);
                    $value = ltrim($value, ' ');

                    if ($value == '&nbsp;') {
                        $value = '';
                    }

                    $value = str_replace('&yen;', '¥', strip_tags($value));
                    $value = decode_html($value);
                    $tmpvalue = $value;

                    $changetype = $bigtype[$keyy];
                    //XUQIU1001388zl 判断是否需要取小数位数，导出格式与列表显示一致
                    $decvalue = $tmpvalue;
                    $tmpdecimal = 0;
                    if(is_string($decvalue)) {
                        $arr_decimal = explode('.', $decvalue);
                        if(isset($arr_decimal[1])&&is_string($arr_decimal[1]))
                            $tmpdecimal = strlen($arr_decimal[1]);
                    }
                    //拆分格式为字符串拼接，获取小数位数长度，拼接成新格式
                    $tmpstr = '0.00';
                    if (is_numeric($tmpdecimal)) {
                        $tmpstr = number_format($tmpstr, (int)$tmpdecimal);
                    }
                    //XUQIU1001388zl 替换货币符号,转换导出格式为货币
                    $allCurrencies=["¥","￡","￥","$","€","AUD","ALL","HKD","TWD"];
                    $changetype_number_arr = ['currency','amount','moduleno'];
                    if(in_array($changetype,$changetype_number_arr) && $columnNameArr[$keyy] !== 'currency_id'){
                        foreach ($allCurrencies as $currency) {
                            if (strpos($tmpvalue, $currency) !== false) {
                                $containcur = strpos($tmpvalue, $currency) ;
                                $tmpvalue = str_replace($currency, '', strip_tags($tmpvalue));
                            }
                        }
                        $tmpvalue = str_replace(',', '', strip_tags($tmpvalue));
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i) . ($prevTotalRows ))->getNumberFormat()->setFormatCode('#,##' . $tmpstr);
                    }
                    //XUQIU1001388zl 数字类型导出excel自定义可计算
                    else if($changetype=="number"||$changetype=="num"){
                        $tmpvalue = str_replace(',', '', strip_tags($tmpvalue));
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i) . ($prevTotalRows))->getNumberFormat()->setFormatCode($tmpstr);
                    }
                    else if($changetype == 'date')
                    {
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i) . ($prevTotalRows ))->getNumberFormat()->setFormatCode('yyyy-mm-dd');
                    }
                    else if($changetype == 'datetime')
                    {
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i) . ($prevTotalRows ))->getNumberFormat()->setFormatCode('yyyy-mm-dd hh:mm:ss');
                    }else{
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i) . ($prevTotalRows ))->getNumberFormat()->setFormatCode('@');
                    }

                    if(in_array($changetype,array('currency','amount','moduleno','number','num','date','datetime'))){
                        $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($for_i) . ($prevTotalRows ),trim($tmpvalue),PHPExcel_Cell_DataType::TYPE_STRING);
                    }else{

                        //zxm 20231103 BUG0074926 纳税识别号 纯数字的导出变成了科学计数法
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($for_i) . ($prevTotalRows ),trim($tmpvalue),PHPExcel_Cell_DataType::TYPE_STRING);
                    }
                    if (is_array($_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy])&&array_key_exists('startRow',$_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy])){
                        $startRow = $_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy]['startRow'];
                    }else{
                        $startRow = 2;
                    }
                    $tmpcurcolumn = $fieldsTableHeader[$keyy];//当前列的字段名 别名
                    if (is_array($_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy])&&array_key_exists('prevValue',$_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy])){
                        $prevValue = $_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy]['prevValue'];
                    }else{
                        $tmpmerge_value = $allmergecolumnvalue_arr[0][$tmpcurcolumn];
                        $prevValue = $tmpmerge_value;
                        if(!empty($tmpmerge_value)){
                            $prevValue = strip_tags(trim($tmpmerge_value));
                        }

                    }
                    if (is_array($_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy])&&array_key_exists('prevColumnValue',$_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy])){
                        $prevColumnValue = $_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy]['prevColumnValue'];
                    }else{
                        $prevColumnValue = $csc[0][$keyy];
                        if(!empty($prevColumnValue)){
                            $prevColumnValue = strip_tags(trim($prevColumnValue));
                        }
                    }
                    $excelColumn = $this->numberToExcelColumn($keyy+1);  //设置数字对应excel列名(0->A  1->B ...)
                    // wsh 20240814 XUQIU20240708-01 报表管理-报表分析-自定义统计表/SQL统计表 导出优化数据多的情况下做成单据列表那种的进度条导出，现在的做法数据多直接内存溢出
                    //if ($mergeArr[$keyy] == "yes"){//判断字段是否合并
                    $mergecolumnvalue = $allmergecolumnvalue_arr[$kee][$tmpcurcolumn];
                    if (strpos($mergeArr[$keyy],':')!==false && !in_array($mergecolumnvalue,['total','sum','count','distinct_count','avg','max','min'])){//判断字段是否合并 //zxm @date:2024/11/13 @reason:
                        $columnValue = strip_tags(trim($cscs[$keyy]));
                        if (($mergecolumnvalue != $prevValue && $startRow <= $prevTotalRows - 1) || $prevTotalRows - 1 == $listCounts) {
                            if($prevTotalRows - 1 == $listCounts){
                                $endRows = $prevTotalRows; //结束行
                            }else{
                                $endRows = $prevTotalRows - 1; //结束行
                            }
                            if ($startExportRow == $prevTotalRows - 1 || $startRow == $endRows){  //如果起始行等于结束行,更新startRow、prevValue 不合并
                                $_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy]['startRow'] = $prevTotalRows;
                                $_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy]['prevValue'] = $mergecolumnvalue;
                                $_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy]['prevColumnValue'] = $columnValue;
                                ++$for_i;
                                continue;
                            }
                            $activesheet->mergeCells("$excelColumn$startRow:$excelColumn$endRows");
                            // 设置合并后的单元格的值
                            $activesheet->setCellValue("$excelColumn$startRow", $prevColumnValue);
                            $activesheet->getStyle("$excelColumn$startRow:$excelColumn$endRows")->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);//左靠齐
                            $activesheet->getStyle("$excelColumn$startRow:$excelColumn$endRows")->getAlignment()->setVertical(PHPExcel_Style_Alignment::VERTICAL_CENTER);// 居中
                            $_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy]['startRow'] = $prevTotalRows;
                            $_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy]['prevValue'] = $mergecolumnvalue;
                            $_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy]['prevColumnValue'] = $columnValue;
                        }
                    }

                    ++$for_i;
                }
                ++$prevTotalRows;
            }
            $_SESSION[$currentModule][$current_user->id]['exportReport']['prevTotalRows'] = $prevTotalRows;

            $objPHPExcel->getActiveSheet()->setTitle('OftenUseReport');
            $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
            $objWriter->save($file_dir . $file_name);
            $ret_arr1['startExportRow'] = $startExportRow;
            $ret_arr1['endExportRow'] = $endExportRow;
            $ret_arr1['listCount'] = $listCounts;
            $ret_arr1['code'] = 1;
            $ret_arr1['title'] = $report_name . '>' . getFixedLabel('EXPORTDATATITLE');
            return $ret_arr1;
        } else {
            $ret_arr2['report_name'] = $report_name;
            $ret_arr2['code'] = 2;
            if (isKehu001ServerPc() == 'yes') {
                require_once(globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
                $portobj = new cls_WeixinPort();
                $ret_arr2['pathname'] = $portobj->UploadUserInfoFile(globalStatic::$root_directory . 'storage/' . $file_name, $file_name);
            }
            unset($_SESSION[$currentModule][$current_user->id]['exportReport']);
            return $ret_arr2;
        }
    }
//数字映射EXCEL列值
    public function numberToExcelColumn($number) {
        $column = "";
        while ($number > 0) {
            $mod = ($number - 1) % 26;
            $column = chr(65 + $mod) . $column;
            $number = intdiv($number - 1, 26);
        }
        return $column;
    }

    //处理参数
    public function initParam(){

        $this->selectColumnTable_arr=[];
        $params = $this->params;

        $report_id = $this->report_id;
        $this->module_arr = $this->CustomTablesActionsObj->getReportModules($report_id);

        $this->mainmodule = $this->module_arr['mainmoduleSelected'];
        $focus=CRMEntity::getInstance($this->mainmodule);

        $this->selectColumnFrom=$focus->table_name;
        $this->selectColumnTable_arr[]=$focus->table_name;

        //$this->relatedModule = array_slice($this->module_arr,1);
        //是否显示明细
        $show_detail = $params['show_detail'];
        $this->show_detail = $show_detail=="on"?'yes':'no';

        //统计字段处理
        $columns = $params['columns'];//统计字段
        $columnmodule = $params['columnmodule'];//统计字段所属模块
        $modulelabel = $params['modulelabel'];//统计字段来自模块名称
        $fieldlabel = $params['fieldlabel'];//统计字段名称
        $bigtype = $params['bigtype'];//统计字段bigtype
        $typeofdata = $params['typeofdata'];//统计字段typeofdata
        $is_group = $params['is_group'];//统计字段是否是分组条件
        $order_by = $params['order_by'];//统计字段排序条件
        $is_merge_arr = $params['is_merge'];//统计字段是否合并
        $total_type = $params['total_type'];//统计字段是否合并
        $align = $params['align'];//统计字段对齐方式
        $alias = $params['alias'];//统计字段别名
        foreach ($columns as $aliak => $cVal) {
            if (empty($alias[$aliak])) {
                $alias[$aliak] = $this->aliasArr[$aliak];
            }
        }
        $prefix = $params['prefix'];//前缀
        $suffix = $params['suffix'];//后缀
        $decimal_places = $params['decimal_places'];//小数位数
        $issticky = $params['issticky'];//是否列固定

        $alias_flip = array_flip($alias);//统计字段别名键值反转

        $modulefieldseq=0;
        $prevmodule='';
        $regex3 = "/\{(.+?)\}/"; // {} 花括号，大括号 正则
        $prevmodule='';
        //统计字段主表自定义字段 zxm-2021-12-10

        //排序设置-数据 zxm20220718
        $this->getSortingList();
        $sorting_list_bycolumnname = $this->sorting_list_bycolumnname ;
        //zxm 上下游模块在一个大数组中 进行循环
        $this->getSelectColumnFrom();

        foreach($columns as $tmpFieldinfo)
        {
            //zxm @date:2024/11/22 @reason: 公式字段 {a}*{g} 这样的不需要再连表
            if(strpos($tmpFieldinfo,':')!=false) {
                //跨模块分组字段  排序要使用另外一个模块的字段
                $tmpFieldinfo_arr = explode(":", $tmpFieldinfo);
                $temp_table = $tmpFieldinfo_arr[0];
                $temp_field_module_arr = explode("_", $tmpFieldinfo_arr[3]);
                $temp_field_focus = CRMEntity::getInstance($temp_field_module_arr[0]);

                if ((is_array($temp_field_focus->customFieldTable) && in_array($temp_table, $temp_field_focus->customFieldTable)) && !in_array($temp_table, $this->selectColumnTable_arr)) {
                    //求和字段是自定义表
                    $this->selectColumnFrom .= " left  join $temp_table on " . $temp_field_focus->table_name . "." . $temp_field_focus->table_index . "=$temp_table." . $temp_field_focus->table_index;
                    $this->selectColumnTable_arr[] = $temp_table;
                }
            }

        }

        foreach($this->module_arr as $kk=>$tmpmodule_arr) {
            if ($kk == 'mainmoduleSelected') {
                continue;
            }
            foreach ($tmpmodule_arr as $tmpmodule_index => $tmpmodulename) {

                $modulefieldseq = sizeof($this->fieldsAlias);
                $tmpfocus = CRMEntity::getInstance($tmpmodulename);
                //获取模块超链接字段
                $entitynameinfo = getEntitynameInfo(getTabid($tmpmodulename));
                $entityfieldname = $entitynameinfo['fieldname'];

                foreach ($columns as $k => $columnVal) {
                    if ($total_type[$k] == 'formula' && $tmpmodule_index == 0) {
                        $temp_formula = $columns[$k];

                        $temp_res = preg_replace_callback($regex3, function ($matches) use ($alias, $alias_flip, $columns) {
                            //Array ( [0] => {E} [1] => E )
                            //解析公式
                            //判断除数为0

                            if (isset($matches[1]) && is_array($alias) && in_array($matches[1], $alias)) {
                                $flipkey = $alias_flip[$matches[1]];
                                $temp_column = $columns[$flipkey];
                                $temp_column = explode(':', $temp_column);
                                return ' ifnull(' . $temp_column[0] . $this->asfixedname . $temp_column[1] . ',0) ';
                            }
                        }, $temp_formula);
                        //BUG0053208	已分派	严重	zxm
                        //报表管理-自定义统计表-BPW市场信息收集表-终端客户市场占比分析表 表格里“占比”字段，计算公式的结果应该为0，表格显示却是1
                        $this->fieldsFormulaArr[] = 'ifnull(' . $temp_res . ',0) as ' . $alias[$k];
                        continue;
                    }
                    if ($columnmodule[$k] != $tmpmodulename) {
                        continue;
                    }
                    $col_arr = explode(':', $columnVal);
                    $tmp_tablename = $col_arr[0];
                    $isdetailfield = 'no';

                    if (is_array($tmpfocus->tab_name) && in_array($tmp_tablename, $tmpfocus->tab_name)) {
                        $fieldinfo = $tmpfocus->fieldobj->getFieldInfoobjBykey("columnname", $col_arr[1]);
                        if (!in_array($tmp_tablename, $this->selectColumnTable_arr)) {
                            if ($tmpfocus->customFieldTable[0] == $tmp_tablename) {

                                $tmp_maintablename = $tmpfocus->table_name;
                                $tmp_tableindex = $tmpfocus->table_index;

                                $this->selectColumnFrom .= "  left join $tmp_tablename on  $tmp_tablename.$tmp_tableindex=$tmp_maintablename.$tmp_tableindex ";
                                $this->selectColumnTable_arr[] = $tmp_tablename;

                            }
                        }
                        //edit: xll 2024/03/06 BUG20240306-51 报表，“标签”这个字段没有值
                        if($fieldinfo->getColumnName() === 'tag'){
                            //dump($fieldinfo);
                            $this->selectColumnFrom .= " LEFT JOIN (
                                    SELECT
                                        GROUP_CONCAT(ld_module_tag.tag separator ',') AS tag,
                                        ld_moduledata_tag.record
                                    FROM
                                        ld_moduledata_tag
                                    INNER JOIN ld_module_tag ON ld_module_tag.id = ld_moduledata_tag.parentid
                                    GROUP BY ld_moduledata_tag.record
                                ) tag_$tmpmodulename ON tag_$tmpmodulename.record = $tmp_tablename.$tmpfocus->table_index";
                            $this->selectColumnTable_arr[] = 'tag_'.$tmpmodulename;
                        }
                    } else {
                        $fieldinfo = $tmpfocus->detailfieldobj->getFieldInfoobjBykey("columnname", $col_arr[1]);
                        $isdetailfield = 'yes';

                        if (!in_array($tmp_tablename, $this->selectColumnTable_arr)) {
                            $Detail_table_index = $tmpfocus->Detail_table_index;
                            $tmp_maintablename = $tmpfocus->table_name;
                            $tmp_tableindex = $tmpfocus->table_index;
                            $Detail_table = $tmpfocus->Detail_table;
                            //if($tmp_tablename==$tmpfocus->Detail_table||$tmp_tablename==$tmpfocus->Detail_table_scf)
                            $Detail_table_id = $tmpfocus->Detail_table_id;

                            if (!in_array($Detail_table, $this->selectColumnTable_arr)) {
                                $this->selectColumnFrom .= "  left join $Detail_table on  $Detail_table.$Detail_table_index=$tmp_maintablename.$tmp_tableindex ";
                                $this->selectColumnTable_arr[] = $Detail_table;
                            }

                            if ($tmp_tablename == $tmpfocus->Detail_table_scf) {
                                $this->selectColumnFrom .= " left  join $tmp_tablename on  $tmp_tablename.$Detail_table_id=$Detail_table.$Detail_table_id ";
                                $this->selectColumnTable_arr[] = $tmp_tablename;
                            }

                            if (get_file_address($columnmodule[$k], 'ProductDetails') && ($tmp_tablename == 'ld_products' || $tmp_tablename == 'ld_productcf')) {

                                if (!in_array('ld_products', $this->selectColumnTable_arr)) {
                                    $this->selectColumnFrom .= " left  join ld_products on  ld_products.productid=$Detail_table.productid ";
                                    $this->selectColumnTable_arr[] = 'ld_products';
                                }
                                //zxm 20220111 选择明细字段有产品表自定义表的字段的时候
                                if ($tmp_tablename == 'ld_productcf') {
                                    $this->selectColumnFrom .= " left  join ld_productcf on  ld_products.productid=ld_productcf.productid ";
                                    $this->selectColumnTable_arr[] = $tmp_tablename;
                                }
                            }
                            $this->selectColumnTable_arr[] = $Detail_table;

                        }

                    }
                    $prevmodule = $tmpmodulename;

                    //分组字段
                    if ($is_group[$k] == "yes") {
                        $this->groupcolumn_arr[$modulefieldseq] = $columnVal;
                    } else {
                        //设置了分组的字段 统计方式失效
                        $temp_total_type = explode(',', $total_type[$k]);
                        if (is_array($temp_total_type) && in_array("sum", $temp_total_type)) {
                            $this->sumcolumn_arr[$modulefieldseq] = $columnVal;
                        }
                        if (is_array($temp_total_type) && in_array("count", $temp_total_type)) {
                            $this->countcolumn_arr[$modulefieldseq] = $columnVal;
                        }
                        if (is_array($temp_total_type) && in_array("max", $temp_total_type)) {
                            $this->maxcolumn_arr[$modulefieldseq] = $columnVal;
                        }
                        if (is_array($temp_total_type) && in_array("min", $temp_total_type)) {
                            $this->mincolumn_arr[$modulefieldseq] = $columnVal;
                        }
                        if (is_array($temp_total_type) && in_array("avg", $temp_total_type)) {
                            $this->avgcolumn_arr[$modulefieldseq] = $columnVal;
                        }
                        if (is_array($temp_total_type) && in_array("distinct_count", $temp_total_type)) {
                            $this->distinctcountcolumn_arr[$modulefieldseq] = $columnVal;
                        }
                    }

                    //if ($is_merge_arr[$k] == 'yes') {
                    if (strpos($is_merge_arr[$k],':')!==false) {
                        //zxm @date:2024/11/13 @reason: XUQIU1001471 模块报表/sql报表-增加“按指定字段”合并的需求（丁进）
                        $this->mergeColumn_arr[] = $columnVal;
                    }
                    //统计字段处理
                    $temp_columns_arr = explode(':', $columnVal);
                    if ($fieldinfo->getBigType() == 'currency') {
                        //币种
                        //$this->fields[$modulefieldseq] =" concat( ".$tmpfocus->table_name.'.currency_symbol ,'.$temp_columns_arr[0].".".$temp_columns_arr[1].") as ".$temp_columns_arr[0].$this->asfixedname.$temp_columns_arr[1];
                        $this->fields[$modulefieldseq] = $temp_columns_arr[0] . "." . $temp_columns_arr[1] . " as " . $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];
                        $this->fieldsAlias[$modulefieldseq] = $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];//加上$k 防止两个表的相同字段
                        $modulefieldseq++;

                        $currency_symbolinfo = $tmpfocus->fieldobj->getFieldInfoobjBykey("columnname", 'currency_id');
                        //币种字段不存在则不查询该字段
                        if ($currency_symbolinfo) {
                            $currency_symbol_field = $tmpfocus->table_name . '.currency_symbol';
                        } else {
                            $currency_symbol_field = '"¥"';
                        }
                        if (!in_array($tmpfocus->table_name . 'currency_symbol', $this->fieldsAlias)) {
                            $this->fields[$modulefieldseq] = $currency_symbol_field . ' as ' . $tmpfocus->table_name . 'currency_symbol';
                            $this->fieldsAlias[$modulefieldseq] = $tmpfocus->table_name . 'currency_symbol';
                            $this->fieldsCurrencySymbol[] = $tmpfocus->table_name . 'currency_symbol';
                            $modulefieldseq++;
                        }
                    }
                    else if (
                        //$fieldinfo->getBigType() == 'moduleno' ||//zxm 20231204 超链接字段根据超链接字段设置来
                        $fieldinfo->getFieldName() == $entityfieldname) {
                        //zxm 20231109 如果字段是超链接字段 也要查出来主键ID  为了拼接超链接
                        $this->fields[$modulefieldseq] = $temp_columns_arr[0] . "." . $temp_columns_arr[1] . " as " . $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];
                        $this->fieldsAlias[$modulefieldseq] = $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];//加上$k 防止两个表的相同字段
                        $modulefieldseq++;


                        $this->fields[$modulefieldseq] = $temp_columns_arr[0] . "." . $tmpfocus->table_index . " as " . $temp_columns_arr[0] . $this->asfixedname . $tmpfocus->table_index;
                        $this->fieldsAlias[$modulefieldseq] = $temp_columns_arr[0] . $this->asfixedname . $tmpfocus->table_index;//加上$k 防止两个表的相同字段
                        $modulefieldseq++;
                    }
                    else if ($fieldinfo->getUIType() == 70 && $isdetailfield == 'yes') {
                        $this->fields[$modulefieldseq] = $temp_columns_arr[0] . ".productid as " . $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];
                        //zxm 20220720  用产品名字
                        //$this->fields[$modulefieldseq] = $temp_columns_arr[0] . ".productname as " . $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];
                        $this->fieldsAlias[$modulefieldseq] = $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];//加上$k 防止两个表的相同字段
                        $modulefieldseq++;
                    }
                    //edit: xll 2024/03/06 BUG20240306-51 报表，“标签”这个字段没有值
                    else if ($fieldinfo->getColumnName() === 'tag') {
                        $this->fields[$modulefieldseq] = 'tag_' . $tmpmodulename . ".tag" . " as " . $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];
                        $this->fieldsAlias[$modulefieldseq] = $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];//加上$k 防止两个表的相同字段
                        $modulefieldseq++;
                    }
                    else {
                        $this->fields[$modulefieldseq] = $temp_columns_arr[0] . "." . $temp_columns_arr[1] . " as " . $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];
                        $this->fieldsAlias[$modulefieldseq] = $temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1];//加上$k 防止两个表的相同字段
                        $modulefieldseq++;
                    }
                }
            }
        }
        $this->sumcolumn_arr=array_values($this->sumcolumn_arr);
        if(is_array($this->maxcolumn_arr))
            $this->maxcolumn_arr=array_values($this->maxcolumn_arr);
        else
            $this->maxcolumn_arr=[];
        if(is_array($this->mincolumn_arr))
            $this->mincolumn_arr=array_values($this->mincolumn_arr);
        else
            $this->mincolumn_arr=[];
        if(is_array($this->countcolumn_arr))
            $this->countcolumn_arr=array_values($this->countcolumn_arr);
        else
            $this->countcolumn_arr=[];
        if(is_array($this->distinctcountcolumn_arr))
            $this->distinctcountcolumn_arr=array_values($this->distinctcountcolumn_arr);
        else
            $this->distinctcountcolumn_arr=[];
        $firstcolumn=$columns[0];
        if(in_array($firstcolumn,$this->sumcolumn_arr))
        {
            //获取第一列是否求和
            $this->firstrColumnComputer_type[]=$this->sum_type;

        }
        if(in_array($firstcolumn,$this->maxcolumn_arr))
        {

            $this->firstrColumnComputer_type[]=$this->max_type;

        }
        if(in_array($firstcolumn,$this->mincolumn_arr))
        {

            $this->firstrColumnComputer_type[]=$this->min_type;

        }
        if(in_array($firstcolumn,$this->distinctcountcolumn_arr))
        {

            $this->firstrColumnComputer_type[]=$this->distinctcount_type;

        }
        if(in_array($firstcolumn,$this->countcolumn_arr))
        {

            $this->firstrColumnComputer_type[]=$this->count_type;

        }
        $ordercolumn=$this->ordercolumn_suff;
        $orderbycolumn_arr=[];
        $show_detail = $this->show_detail;
//        if($show_detail == 'yes'){
        //如果不显示详情  则直接按用户选择的字段排序--这样也有问题  先去掉
        $tmpsize=sizeof($this->groupcolumn_arr);

        foreach($this->groupcolumn_arr as $tmpindex=> $groupcolumninfo )
        {
            $tmpgroupcolumn_arr=explode(":",$groupcolumninfo);
            $tmpcolumn=$tmpgroupcolumn_arr[1];
            $tablename=$tmpgroupcolumn_arr[0];
            $searchindex=array_search($groupcolumninfo,$columns);

            $orderbycolumn_arr[]=$tablename.$this->asfixedname.$tmpcolumn.$ordercolumn;
            /*  if($tmpsize>1 && $tmpindex==$tmpsize-1)
               {
                    $this->sqlOrdercolumn_arr[]=$tablename.$this->asfixedname.$tmpcolumn.'    desc';
               }
              else*/
            // if($order_by[$searchindex]!='no')
            //zxm 20220720 仅有按列名排序的排序设置
            if(isset($sorting_list_bycolumnname[$groupcolumninfo])){
                if($tmpcolumn=='productname'){
                    //产品名称的时候 特殊处理 zxm BUG0054462
                    $this->sqlOrdercolumn_arr[]='CONVERT(ifnull('.$tablename.$this->asfixedname.$tmpcolumn.$this->ordercolumn_suff.',"") USING gbk) '.$sorting_list_bycolumnname[$groupcolumninfo];
                }else{
                    $this->sqlOrdercolumn_arr[]='CONVERT(ifnull('.$tablename.$this->asfixedname.$tmpcolumn.$this->ordercolumn_suff.',"") USING gbk) '.$sorting_list_bycolumnname[$groupcolumninfo];
                }
            }
            else{
                if($tmpcolumn=='productname') {
                    //产品名称的时候 特殊处理 zxm BUG0054462
                    $this->sqlOrdercolumn_arr[]='CONVERT(ifnull('.$tablename.$this->asfixedname.$tmpcolumn.$this->ordercolumn_suff.',"") USING gbk) asc ';
                }else{
                    $this->sqlOrdercolumn_arr[]='CONVERT(ifnull('.$tablename.$this->asfixedname.$tmpcolumn.',"") USING gbk) asc ';
                }
            }
            //$this->sqlOrdercolumn_arr[]=$tablename.$this->asfixedname.$tmpcolumn.$ordercolumn.' asc ';
            $this->fields[$modulefieldseq] = $tablename.".".$tmpcolumn." as ".$tablename.$this->asfixedname.$tmpcolumn.$ordercolumn;
            $this->fieldsAlias[$modulefieldseq]= $tablename.$this->asfixedname.$tmpcolumn.$ordercolumn;//加上$k 防止两个表的相同字段
            $modulefieldseq++;
        }

        if(sizeof($this->sqlOrdercolumn_arr)>0)
        {
            $this->sqlOrdercolumn_arr[]=' type asc ';
        }

        $sortcolumninfo_arr=[];
        $this->ordercolumn_arr=$orderbycolumn_arr;
        foreach($columns as $k=>$columnVal) {

            $tmp_arr = explode(":", $columnVal);
            $column_tablename = $tmp_arr[0];
            $colum_module = $columnmodule[$k];
            $column_focus = CRMEntity::getInstance($colum_module);
            $typeofdata_decimal = 2;
            $uitype = 0;
            $fieldtype = '';
            $fieldinfo = '';
            if (is_array($column_focus->tab_name) && in_array($column_tablename, $column_focus->tab_name)) {
                $fieldinfo = $column_focus->fieldobj->getFieldInfoobjBykey("columnname", $tmp_arr[1]);
                if(!empty($fieldinfo)){
                    $uitype = $fieldinfo->getUIType();
                    $tmptypeofdata = $fieldinfo->getTypeOfData();
                    $typeofdatas = explode(',', $tmptypeofdata);
                    if(sizeof($typeofdatas)>1)
                    {
                        $typeofdata_decimal=$typeofdatas[1];
                    }
                }
                $isdetailfield = 'no';

            } else if ($total_type[$k] != 'formula') {
                //zxm 2022-0124 公式字段要排除
                $fieldinfo = $column_focus->detailfieldobj->getFieldInfoobjBykey("columnname", $tmp_arr[1]);

                if(!empty($fieldinfo)){
                    $uitype = $fieldinfo->getUIType();
                    $fieldtype = $fieldinfo->getFieldType();
                    $tmptypeofdata = $fieldinfo->getTypeOfData();
                    $typeofdatas = explode(',', $tmptypeofdata);
                    if(sizeof($typeofdatas)>1)
                    {
                        $typeofdata_decimal=$typeofdatas[1];
                    }
                }
                $isdetailfield = 'yes';
            }
            //zkt 20221110 XUQIU1000804 单据头和单据分录“金额货币”类型的字段允许自定义小数位数
            if(!empty($fieldinfo)){
                if($fieldinfo->isAmountorCurrencyField()){
                    $decimal_places[$k] = $typeofdata_decimal;
                }

                $valueFormat = $fieldinfo->getValueFormat();
            }
            $this->column_arr[$k]['uitype'] = $uitype;
            $this->column_arr[$k]['fieldtype'] = $fieldtype;
            $this->column_arr[$k]['value_format'] = $valueFormat ?? '';
            $this->column_arr[$k]['isdetailfield'] = $isdetailfield;
            $this->column_arr[$k]['columns'] = $columnVal;
            $this->column_arr[$k]['columnmodule'] = $columnmodule[$k];
            $this->column_arr[$k]['modulelabel'] = $modulelabel[$k];
            $this->column_arr[$k]['fieldlabel'] = $fieldlabel[$k];
            $this->column_arr[$k]['bigtype'] = $bigtype[$k];
            $this->column_arr[$k]['typeofdata'] = $typeofdata[$k];
            $this->column_arr[$k]['is_group'] = $is_group[$k];
            $this->column_arr[$k]['order_by'] = $order_by[$k];
            $this->column_arr[$k]['merge'] = $is_merge_arr[$k];
            $this->column_arr[$k]['total_type'] = $total_type[$k];
            $this->column_arr[$k]['align'] = $align[$k];
            $this->column_arr[$k]['alias'] = $alias[$k];
            $this->column_arr[$k]['prefix'] = $prefix[$k];
            $this->column_arr[$k]['suffix'] = $suffix[$k];
            $this->column_arr[$k]['decimal_places'] = $decimal_places[$k];
            $this->column_arr[$k]['issticky'] = $issticky[$k];
            //统计字段处理
            $temp_columns_arr = explode(':', $columnVal);
            //zxm 20220720  仅有按列名排序的排序设置 以前的排序方法去掉不用了
//                if($order_by[$k]!='no')
//                {
//                     $this->sqlOrdercolumn_arr[]=$temp_columns_arr[0].$this->asfixedname.$temp_columns_arr[1].' '.$order_by[$k];
//                }
            //zxm 20220720  仅有按列名排序的排序设置
            if (isset($sorting_list_bycolumnname[$columnVal])&&$is_group[$k]!='yes'){
                $orderbycolumn_arr[]=$temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1] ;
                if(in_array($bigtype[$k],array('currency','num','amount'))){
                    //如果是金额和数字 不要转gbk zxm 20231108

                    $sortcolumninfo_arr[$columnVal]='ifnull('.$temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1] . ',0)' . $sorting_list_bycolumnname[$columnVal];

                    // $this->sqlOrdercolumn_arr[] = 'ifnull('.$temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1] . ',0)' . $sorting_list_bycolumnname[$columnVal];
                }else{
                    // $this->sqlOrdercolumn_arr[] = 'CONVERT(ifnull('.$temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1] . ',"") USING gbk) ' . $sorting_list_bycolumnname[$columnVal];
                    $sortcolumninfo_arr[$columnVal]='CONVERT(ifnull('.$temp_columns_arr[0] . $this->asfixedname . $temp_columns_arr[1] . ',"") USING gbk) ' . $sorting_list_bycolumnname[$columnVal];

                }
            }
            if($total_type[$k]=='formula'){
                $this->fieldsTableHeader[$k] = $alias[$k];
            }else{
                $this->fieldsTableHeader[$k] = $temp_columns_arr[0].$this->asfixedname.$temp_columns_arr[1];//加上$k 防止两个表的相同字段
            }
        }

        foreach($sorting_list_bycolumnname as $columninfo=>$sorttype)
        {
            $this->sqlOrdercolumn_arr[]=$sortcolumninfo_arr[$columninfo];

        }
        //zxm 20220721 为了排序  合并字段的排序需要设置到最后
        foreach($this->mergeColumn_arr as $mergecolumninfo)
        {
            $tmpgroupcolumn_arr=explode(":",$mergecolumninfo);
            $tmpcolumn=$tmpgroupcolumn_arr[1];
            $tablename=$tmpgroupcolumn_arr[0];
            if(!in_array($tablename.$this->asfixedname.$tmpcolumn,$orderbycolumn_arr))
            {
                $this->sqlOrdercolumn_arr[]='CONVERT(ifnull('.$tablename.$this->asfixedname.$tmpcolumn.',"") USING gbk) asc ';
            }
        }

    }


    //获取报表搜索字段
    public function getSearchField(){
        include_once globalStatic::$root_directory . 'modules/CustomTables/cls_ModuleInfo.php';
        $ModuleInfoObj = new cls_ModuleInfo($this->params);

        $res = $ModuleInfoObj->getRecursionModuleArrData($this->report_id);
        $mainmodule = $res['mainmoduleSelected'];
        $nextSelectedArr = _array_column($res['nextSelectedArr'],'selectmodule');
        $prevSelectedArr = _array_column($res['prevSelectedArr'],'selectmodule');
        $prevSelectedArr = array_reverse($prevSelectedArr);//上游模块如果要拼接到所有模块的数组上 反转一下
        if(empty($prevSelectedArr[0]))
            unset($prevSelectedArr[0]);

        $modules[] = $mainmodule;

        if(!empty($prevSelectedArr))$modules =array_merge($prevSelectedArr,$modules);
        if(!empty($nextSelectedArr)) $modules =array_merge($modules,$nextSelectedArr);

        $modules = array_unique($modules);
        $searchFieldRes = $this->CustomTablesActionsObj->getModuleFields($modules,$mainmodule,$nextSelectedArr);//选中模块的所有字段
        return $searchFieldRes;
    }
    public function getDetailCondition(){
        //总的条件
        global $current_user;
        $this->setHomeHighSearch();//首页时间条件 和高级查找
        $params = $this->params;
        $allModules = $this->module_arr;
        $moduleCondition_arr=[];
        $condition_arr=[];
        //获取条件数据
        $cvadvfilter = $params['cvadvfilter'];
        $comparator_arr = $params['comparator'];
        $groupid = $params['groupid'];//条件所属分组id
        $columncondition = $params['columncondition'];//组内条件之间的关系

        $value1_arr = $params['value1'];
        $value2_arr = $params['value2'];
        $conditionArr = [];
        //获取条件分组数据 zxm 20220630
        $group_condition_id = $params['group_condition_id'];
        $group_condition = $params['group_condition'];
        $group_condition_arr = [];


        foreach ($group_condition_id as $ck=>$cv){
            $group_condition_arr[$cv] = $group_condition[$ck];
        }
        // todo


        foreach($cvadvfilter as $condKey =>$conditionColumn){
            $temp_column = explode(':',$conditionColumn);
            $temp_table =  $temp_column[0];
            $tmpmodule_arr=explode("_",$temp_column[3]);
            $tmpmodule=$tmpmodule_arr[0];
            $temp_comparator = $comparator_arr[$condKey];

            //zxm 2022-6-9 0052267  1、报表分析-（费用报销单-合同汇总）-编辑条件-合同名称不为空点搜索无效（开发部账套也是一样）
            //2、报表分析-（费用报销单-合同汇总）-对合同名称分组，统计不出来数据（合同名称是分录中源单合同订单引用过来的，估计是因为这个）
            if(($temp_comparator!='isnull'&&$temp_comparator!='isnotnull')&&trim($value1_arr[$condKey])=='')
                continue;
            if($temp_comparator=='bw')
            {
                $moduleCondition_arr[$tmpmodule][]=array(
                    'column'=>$conditionColumn,
                    'comparator'=>$comparator_arr[$condKey],
                    'value'=>$value1_arr[$condKey].','.$value2_arr[$condKey],
                    'groupid'=>$groupid[$condKey],
                    'columncondition'=>$columncondition[$condKey]
                );
            }
            else{
                $moduleCondition_arr[$tmpmodule][]=array(
                    'column'=>$conditionColumn,
                    'comparator'=>$comparator_arr[$condKey],
                    'value'=>$value1_arr[$condKey],
                    'groupid'=>$groupid[$condKey],
                    'columncondition'=>$columncondition[$condKey]
                );
            }
        }

        //zxm 20231009 高级查找条件为空--还是要注释掉，不能返回空
        /*if(empty($moduleCondition_arr)||sizeof($moduleCondition_arr)<=0){
            return '';
        }*/
        //主表条件
        $mainWhere = [];
        $mainWhereDeleted = '';
        $tableIndexField = [];
        $DetailDableIdField = [];
        $tables = [];
        $hadTable_arr=[];
        //获取主sql的各表的索引字段条件  例：accountid in (983,2)
        $this->wheremodule_arr=[];
        //zxm 20231123 循环上游和下游模块

        foreach($allModules as $kk=>$tmpmodule_arr) {
            if ($kk == 'mainmoduleSelected') {
                continue;
            }

            foreach ($tmpmodule_arr as $k => $tempModule) {
                $currModule = $tmpmodule_arr[$k];
                $currModuleFocus = CRMEntity::getInstance($currModule);
                $currTable = $currModuleFocus->table_name;
                $currTableIndex = $currModuleFocus->table_index;

                if ($k == 0&&$kk == 'nextSelectedArr') {
                    //第一个模块 是主模块
                    $mainmoduleFocus = $currModuleFocus;
                    //zxm 20231010 条件SQL中的字段取一个别名：表名belong字段名
                    $tableIndexField[] = $currTable . '.' . $currTableIndex . ' as ' . $currTable . $this->asfixedname . $currTableIndex;
                    //审批条件  统计表放首页的时候可能会有这个条件
                    $mainApprovestatusSql = $this->getMainApprovestatusSql();
                    $mainWhere[] = $currTable . '.deleted=0 '.$mainApprovestatusSql;
                    $mainWhereDeleted = $currTable . '.deleted=0 '.$mainApprovestatusSql;//主表的deleted条件和审批条件 zxm 20220630
                    $tables[] = $currTable;
                    $hadTable_arr[] = $currTable;
                } else {
                    $prevModule = $tmpmodule_arr[$k - 1];
                    if($kk == 'prevSelectedArr'){
                        if($k == 0){
                            $relatetablejoinobj = cls_TableJoin_module::getInstance( $tempModule,$mainmoduleFocus->moduleName);
                        }else{
                            $relatetablejoinobj = cls_TableJoin_module::getInstance($currModule,$prevModule);
                        }
                    }else{
                        $relatetablejoinobj = cls_TableJoin_module::getInstance($prevModule, $currModule);
                    }
                    $relatetablejoinobj->setHadTables($hadTable_arr);
                    $tmpjoin_arr = $relatetablejoinobj->getJoin();



                    //zxm 20231010 条件SQL中的字段取一个别名：表名belong字段名
                    $tableIndexField[] = $currTable . '.' . $currTableIndex . ' as ' . $currTable . $this->asfixedname . $currTableIndex;


                    if ($k == 1) {
                        $tmpjoin_arr['joinsqltype'] = ' left join ';
                    }
                    //if(in_array($currTable,$tmpjoin_arr['jointable'])) {
                    if($kk == 'prevSelectedArr'){
                        if($tmpjoin_arr['bwType'] === 'selectSource'){
                            $tables[] = $tmpjoin_arr['joinsqltype']. " "  .$tmpjoin_arr['bwmodulesql'];

                        }
                        else
                            $tables[] = $tmpjoin_arr['joinsqltype']. " " . $currModuleFocus->table_name. " on " .$tmpjoin_arr['bwmodulesql'];

                        if (!in_array($currModuleFocus->table_name, $tmpjoin_arr['bwomoduletables'])
                            && in_array($currModuleFocus->Detail_table, $tmpjoin_arr['bwomoduletables'])) {
                            $detail_table = $currModuleFocus->Detail_table;

                            $this->selectColumnTable_arr = array_merge($this->selectColumnTable_arr, $tmpjoin_arr['bwomoduletables']);
                            $Detail_table_index = $currModuleFocus->Detail_table_index;
                            if(!in_array($currModuleFocus->table_name,$hadTable_arr))
                                $tables[] = " left join " . $currModuleFocus->table_name . "   on $detail_table.$Detail_table_index=" . $currModuleFocus->table_name . '.' . $currModuleFocus->table_index . ' and ' . $currModuleFocus->table_name . '.deleted=0 ';
                            $hadTable_arr[] = $detail_table;
                            //zxm 20231020 条件sql中 增加明细表主键
                            $tableIndexField[] = $detail_table . '.' . $currModuleFocus->Detail_table_id . ' as ' . $detail_table . $this->asfixedname . $currModuleFocus->Detail_table_id;
                        }

                        $hadTable_arr = array_merge($hadTable_arr, $tmpjoin_arr['bwomoduletables']);
                    }else{
                        $hadTable_arr = array_merge($hadTable_arr, $tmpjoin_arr['jointable']);
//                        if($tmpjoin_arr['bwType'] === 'selectSource') {
//                            //如果是选源单 如市场活动是主模块 下游模块选客户 再选订单 表连接出问题
//                            $tables[] = $tmpjoin_arr['joinsqltype'] . " " . $tmpjoin_arr['bwmodulesql'];
//                        }else{
                            $tables[] = $tmpjoin_arr['joinsqltype'] . " " . $tmpjoin_arr['joinsql'];
//                        }


                        if (!in_array($currModuleFocus->table_name, $tmpjoin_arr['jointable'])
                            && in_array($currModuleFocus->Detail_table, $tmpjoin_arr['jointable'])) {
                            $detail_table = $currModuleFocus->Detail_table;

                            $this->selectColumnTable_arr = array_merge($this->selectColumnTable_arr, $tmpjoin_arr['jointable']);
                            $Detail_table_index = $currModuleFocus->Detail_table_index;
                            if(!in_array($currModuleFocus->table_name,$hadTable_arr))
                                $tables[] = " left join " . $currModuleFocus->table_name . "   on $detail_table.$Detail_table_index=" . $currModuleFocus->table_name . '.' . $currModuleFocus->table_index . ' and ' . $currModuleFocus->table_name . '.deleted=0 ';
                            $hadTable_arr[] = $detail_table;
                            //zxm 20231020 条件sql中 增加明细表主键
                            $tableIndexField[] = $detail_table . '.' . $currModuleFocus->Detail_table_id . ' as ' . $detail_table . $this->asfixedname . $currModuleFocus->Detail_table_id;
                        }
                    }


                }




            }
        }


        foreach($allModules as $kk=>$tmpmodule_arr)
        {

            if ($kk == 'mainmoduleSelected') {
                continue;
            }

            foreach ($tmpmodule_arr as $k => $tempModule) {
                $currModule = $tmpmodule_arr[$k];
                $currModuleFocus = CRMEntity::getInstance($currModule);
                $currTable = $currModuleFocus->table_name;
                $currTableIndex = $currModuleFocus->table_index;
                if (array_key_exists($tempModule, $moduleCondition_arr)) {
                    $this->wheremodule_arr[] = $tempModule;
                    foreach ($moduleCondition_arr[$tempModule] as $conditionindex => $conditionInfo) {

                        $reportwhereobj = new ReportTableWhere($tempModule);

                        $reportwhereobj->setWhereColumn($conditionInfo['column']);
                        $reportwhereobj->setComparator($conditionInfo['comparator']);
                        $reportwhereobj->setSearchText($conditionInfo['value']);
                        $tmpwhere = $reportwhereobj->getWhere();

                        foreach ($reportwhereobj->querygeneratoryobj->whereMainTable as $tmptablename => $leftjoin) {
                            if (!in_array($tmptablename, $hadTable_arr)) {
                                if ($tmptablename == $currModuleFocus->customFieldTable[0]) {
                                    //自定义表
                                    $tables[] = " left join  $tmptablename on $tmptablename.$currTableIndex=$currTable.$currTableIndex ";

                                } else if ($tmptablename == $currModuleFocus->Detail_table) {
                                    $Detail_table_index = $currModuleFocus->Detail_table_index;
                                    $tables[] = " left join  $tmptablename on $tmptablename.$Detail_table_index=$currTable.$currTableIndex ";
                                    $Detail_table_id = $currModuleFocus->Detail_table_id;
                                    $DetailDableIdField[] = $tmptablename . '.' . $Detail_table_id;//明细表的lineitem_id   //zxm 20221012 查询条件是明细表的字段
                                } else if ($tmptablename == $currModuleFocus->Detail_table_scf) {
                                    $detail_table = $currModuleFocus->Detail_table;
                                    $Detail_table_id = $currModuleFocus->Detail_table_id;

                                    $tables[] = " left join  $detail_table on $detail_table.$Detail_table_index=$currTable.$currTableIndex ";

                                    $tables[] = " left join  $tmptablename on $tmptablename.$Detail_table_id=$detail_table.$Detail_table_id ";
                                    $hadTable_arr[] = $detail_table;
                                    $DetailDableIdField[] = $detail_table . '.' . $Detail_table_id;//明细表的lineitem_id //zxm 20221012 查询条件是明细表的字段
                                } else {
                                    $tables[] = ' left join ' . $leftjoin;

                                    $hadTable_arr[] = $tmptablename;
                                }
                                $hadTable_arr[] = $tmptablename;
                            }
                        }


                        foreach ($reportwhereobj->querygeneratoryobj->whereDetailTable as $tmptablename => $tmpleftjoin) {
                            $tmpcolumn_arr = explode(':',$conditionInfo['column']);
                            if(!empty($currModuleFocus->detailfieldobj)) {
                                //zxm 20240410 分录字段是单选关联选择单据 作为搜索条件 需要连一下关联模块
                                $tmpfieldinfo = $currModuleFocus->detailfieldobj->getFieldInfoobjBykey("columnname", $tmpcolumn_arr[1]);
                                $tmpreferencemodule = $tmpfieldinfo->getReferenceModule();
                                $referencemodule_focus = CRMEntity::getInstance($tmpreferencemodule);
                            }

                            if ($tmptablename == $currModuleFocus->Detail_table) {
                                $Detail_table_index = $currModuleFocus->Detail_table_index;

                                if(!in_array($tmptablename,$hadTable_arr))
                                    $tables[] = " left join  $tmptablename on $tmptablename.$Detail_table_index=$currTable.$currTableIndex ";
                                $hadTable_arr[] = $tmptablename;
                                $Detail_table_id = $currModuleFocus->Detail_table_id;
                                $DetailDableIdField[] = $tmptablename . '.' . $Detail_table_id;//明细表的lineitem_id //zxm 20221012 查询条件是明细表的字段
                            } else if ($tmptablename == $currModuleFocus->Detail_table_scf) {
                                $detail_table = $currModuleFocus->Detail_table;
                                $Detail_table_id = $currModuleFocus->Detail_table_id;
                                $DetailDableIdField[] = $detail_table . '.' . $Detail_table_id;//明细表的lineitem_id //zxm 20221012 查询条件是明细表的字段
                                if (!in_array($detail_table, $hadTable_arr)) {
                                    $tables[] = " left join  $detail_table on $detail_table.$Detail_table_index=$currTable.$currTableIndex ";
                                    $hadTable_arr[] = $detail_table;
                                }
                                $tables[] = " left join  $tmptablename on $tmptablename.$Detail_table_id=$detail_table.$Detail_table_id ";
                                $hadTable_arr[] = $tmptablename;

                            } else if($referencemodule_focus&&$tmptablename=='detail_'.$referencemodule_focus->table_name){

                                $tables[] = " left join  ".$tmpleftjoin;
                                $hadTable_arr[] = $tmptablename;
                            }else if ($tmptablename == 'ld_products'&&!in_array($tmptablename,$hadTable_arr)) {
                                //BUG0053953	已分派	系统错误	zxm
                                //报表管理》产品销量排行榜（按出库金额）》点击后里面有数据，添加产品名称模糊搜索条件  没数据了
                                $tables[] = " left join " . $tmpleftjoin;
                                $hadTable_arr[] = $tmptablename;
                            }

                        }
                        $mainWhere[] = $tmpwhere;
                        //组合条件 所有的条件
                        $conditionInfo['sql'] = $tmpwhere;
                        $condition_arr[$conditionInfo['groupid']][] = $conditionInfo;

                    }
                }
            }

        }
        //条件的设置顺序跟模块顺序不一致的时候  条件数组顺序被打乱  and放的位置就不对了
        ksort($condition_arr);
        $mainWhereStr = '';//最后的条件 zxm 20220630 组合条件
        foreach($condition_arr as $groupidkey=>$groupcoditionvalue){
            $groupcoditionvalue_temp = '';
            foreach($groupcoditionvalue as $conditionkey=>$conditionvalue){
                if($conditionkey==0){
                    $groupcoditionvalue_temp = $conditionvalue['sql'];
                }else{

                    $groupcoditionvalue_temp .= $conditionvalue['columncondition'] . ' ' .$conditionvalue['sql'];
                }
            }
            $group_condition_temp = isset($group_condition_arr[$groupidkey])?$group_condition_arr[$groupidkey]:'';
            $mainWhereStr .= $group_condition_temp . '('.$groupcoditionvalue_temp.')';
            $condition_arr[$groupidkey] = $groupcoditionvalue_temp;
        }

        if(!empty($mainWhereStr)){
            $mainWhereStr = $mainWhereDeleted .' and '.$mainWhereStr;
        }else{
            $mainWhereStr = $mainWhereDeleted;
        }

        $this->DetailDableIdField = array_unique($DetailDableIdField);//zxm 20221012 查询条件是明细表的字段
        //$tableIndexField = array_merge($DetailDableIdField,$tableIndexField);//明细表的lineitem_id

        if(!empty($DetailDableIdField)&&!empty($DetailDableIdField[0])){
            //zxm 20231010 条件SQL中的字段取一个别名：表名belong字段名
            $tableIndexField[] = $DetailDableIdField[0].' as '.str_replace('.',$this->asfixedname,$DetailDableIdField[0]);
        }

        $tableIndexField = array_unique($tableIndexField);
        $this->tableIndexFieldArr = $tableIndexField;//各个表的主键字段
        /*foreach($this->tableIndexFieldArr as &$tmpfield){
            $tmpfield_arr = explode('.',$tmpfield);
            $tmpfield .= ' as '.$tmpfield_arr[0].$this->asfixedname.$tmpfield_arr[1];
        }*/
        //zxm 20231010 条件SQL中把分组字段增加进去--20231020 分组字段所在的表最后right join了一下 这里就不需要再加了
        /*foreach($this->groupcolumn_arr as $tmpindex=> $groupcolumninfo  ){
            $groupcolumn_arr=explode(":",$groupcolumninfo);
            $tableIndexField[] = $groupcolumn_arr[0].'.'.$groupcolumn_arr[1].' as '.$groupcolumn_arr[0].$this->asfixedname.$groupcolumn_arr[1];
        }*/
        $tableIndexField = implode(',',$tableIndexField);

        $mainmoduleFocus = CRMEntity::getInstance($this->mainmodule);
        $mainmoduleTable = $mainmoduleFocus->table_name;
        $SmownerColumName = $mainmoduleFocus->getSmownerColumName();
        $SmownerColumNametmp = $mainmoduleTable.'.'.$SmownerColumName;
        $smowneridjoinField = $SmownerColumNametmp.' as '.$mainmoduleTable.$this->asfixedname.$SmownerColumName;

        crm_load_class_file('ReportAnalysisUtils','modules/ReportAnalysis');
        $datarangeSql = ReportAnalysisUtils::getUserIdSql($SmownerColumNametmp,$this->mainmodule,'');
        //$datarangeSql = $this->getDataRangeSql($SmownerColumNametmp,$this->mainmodule);
        $tables[] = $datarangeSql;

        $tables = array_unique($tables);//客户那边设置两个自定明细表的条件  名字自定义表就链接了2次

        $tables = implode(' ',$tables);

        //$mainWhere = implode(" and ",$mainWhere);
        $conditionSql = "select $tableIndexField,$smowneridjoinField from $tables where   ".$mainWhereStr ;

        return $conditionSql;
    }
    //主模块审批条件
    public function getMainApprovestatusSql(){
        return '';
    }
    //首页高级查找条件 时间条件
    public function setHomeHighSearch(){
        return '';
    }
    //获取表连接SQL
    public function getSelectColumnFrom(){
        //zxm 上下游模块在一个大数组中 进行循环
        foreach($this->module_arr as $kk=>$tmpmodule_arr){
            if($kk=='mainmoduleSelected'){
                continue;
            }
            foreach($tmpmodule_arr as $tmpmodule_index=> $tmpmodulename)
            {
                //添加了5个模块，中间两个模块没有字段在界面显示
                $tmpfocus=CRMEntity::getInstance($tmpmodulename);

                $tmp_tablename=$tmpfocus->table_name;
                if(!in_array($tmp_tablename,$this->selectColumnTable_arr))
                {
                    if(!empty($prevmodule)&&$prevmodule!=$tmpmodulename)
                    {

                        $tmp_curcolumn_module=$curcolumn_module_arr[0];

                        if($kk=='prevSelectedArr'){
                            if($tmpmodule_index==0){
                                //第一个上游模块 跟主模块连
                                $prevmodule = $this->mainmodule;
                            }
                            $relatetablejoinobj = cls_TableJoin_module::getInstance($tmpmodulename,$prevmodule);
                        }else{
                            $relatetablejoinobj = cls_TableJoin_module::getInstance($prevmodule, $tmpmodulename);
                        }
                        $relatetablejoinobj->setHadTables($this->selectColumnTable_arr);
                        $relatetablejoinobj->hadJoinTable_arr=$this->selectColumnTable_arr;
                        $join_arr= $relatetablejoinobj->getJoin();

                        if($tmpmodule_index==1)
                        {
                            $join_arr['joinsqltype']=' left join ';

                        }

                        if($kk=='prevSelectedArr'){
                            if($join_arr['bwType'] === 'selectSource'){
                                $this->selectColumnFrom.= $join_arr['joinsqltype']. " " .$join_arr['bwmodulesql'];
                            }
                            else{
                                $this->selectColumnFrom.= $join_arr['joinsqltype']. " " . $tmpfocus->table_name. " on " .$join_arr['bwmodulesql'];
                            }

                            $this->selectColumnTable_arr=array_merge($this->selectColumnTable_arr,$join_arr['bwomoduletables']);



                            if(!in_array($tmpfocus->table_name,$join_arr['bwomoduletables'])
                                &&in_array($tmpfocus->Detail_table,$join_arr['bwomoduletables']))
                            {
                                $detail_table=$tmpfocus->Detail_table;


                                $Detail_table_index=$tmpfocus->Detail_table_index;
                                // $this->selectColumnFrom.=" left join ". $tmpfocus->table_name."   on $detail_table.$Detail_table_index=".$tmpfocus->table_name.'.'.$tmpfocus->table_index.' and '.$tmpfocus->table_name.'.deleted=0';

                            }
                        }else{
//                            if($join_arr['bwType'] === 'selectSource') {
//                                //如果是选源单 如市场活动是主模块 下游模块选客户 再选订单 表连接出问题
//                                $this->selectColumnFrom .= $join_arr['joinsqltype'] . $join_arr['bwmodulesql'];
//                            }else{
                                $this->selectColumnFrom .= $join_arr['joinsqltype'] . $join_arr['joinsql'];
//                            }
                            //zxm 20240313 主模块如果有分录  这个$join_arr['joinsql']就已经连了明细表，需要把表都记录一下 不然后面会重复连
                            $this->selectColumnTable_arr = array_merge($this->selectColumnTable_arr,$join_arr['jointable']);
                            //$this->selectColumnTable_arr[]=$tmpfocus->table_name;

                            if(!in_array($tmpfocus->table_name,$join_arr['jointable'])
                                &&in_array($tmpfocus->Detail_table,$join_arr['jointable']))
                            {
                                $detail_table=$tmpfocus->Detail_table;


                                $Detail_table_index=$tmpfocus->Detail_table_index;
                                $this->selectColumnFrom.=" left join ". $tmpfocus->table_name."   on $detail_table.$Detail_table_index=".$tmpfocus->table_name.'.'.$tmpfocus->table_index.' and '.$tmpfocus->table_name.'.deleted=0';
                                $this->selectColumnTable_arr[]=$tmp_tablename;

                            }
                        }




                    }

                    /*if(!in_array($tmp_tablename,$this->selectColumnTable_arr))
                    {
                        //自定义字段自定义表
                        $tmp_maintablename=$tmpfocus->table_name;
                        $tmp_tableindex=$tmpfocus->table_index;

                        $this->selectColumnFrom.="  left join $tmp_tablename on  $tmp_tablename.$tmp_tableindex=$tmp_maintablename.$tmp_tableindex " ;
                        $this->selectColumnTable_arr[]=$tmp_tablename;
                    }*/
                }
                $prevmodule=$tmpmodulename;
            }
        }
    }
    //获取排序数组
    public function getSortingList(){
        $report_id = $this->report_id;
        $columns_arr = $this->params['columns'];//统计字段

        //排序设置-数据 zxm20220718
        $select_sql = " select * from ld_customtable_sorting where report_id=? order by sequence asc ";
        $select_res = $this->CustomTablesActionsObj->adb->pquery($select_sql,array($report_id));
        $select_nums = $this->CustomTablesActionsObj->adb->num_rows($select_res);
        $sorting_list_all = [];//排序设置所有的值
        $sorting_list_bycolumnname = [];//排序设置按列名称排序的值
        $sorting_list_byresult = [];//按统计结果排序的设置

        if($select_nums>=1){
            for($i=0;$i<$select_nums;$i++){
                $tmp_columns = $this->CustomTablesActionsObj->adb->query_result($select_res,$i,'columns');
                //字段已被删掉  不能再用这个字段做排序了
                if(!in_array($tmp_columns,$columns_arr)){
                    continue;
                }
                $sorting_list_all[$i]['report_id'] = $this->CustomTablesActionsObj->adb->query_result($select_res,$i,'report_id');
                $sorting_list_all[$i]['sorttype'] = $this->CustomTablesActionsObj->adb->query_result($select_res,$i,'sorttype');
                $sorting_list_all[$i]['columnmodule'] = $this->CustomTablesActionsObj->adb->query_result($select_res,$i,'columnmodule');
                $sorting_list_all[$i]['columns'] = $tmp_columns;
                $sorting_list_all[$i]['sortmethod'] = $this->CustomTablesActionsObj->adb->query_result($select_res,$i,'sortmethod');
                $sorting_list_all[$i]['sequence'] = $this->CustomTablesActionsObj->adb->query_result($select_res,$i,'sequence');
                $sorting_list_all[$i]['total_type'] = $this->CustomTablesActionsObj->adb->query_result($select_res,$i,'total_type');

                $tmp_columns_arr = explode(":",$tmp_columns);
                $tmp_column_name = $tmp_columns_arr[1];
                $tmp_table_name = $tmp_columns_arr[0];
                $sorting_list_all[$i]['aliasname'] = $tmp_table_name.$this->asfixedname.$tmp_column_name;

                if($sorting_list_all[$i]['sorttype']=='byresult'){
                    $sorting_list_byresult[$i] = $sorting_list_all[$i];
                }
                if($sorting_list_all[$i]['sorttype']=='bycolumnname'){
                    $sorting_list_bycolumnname[$sorting_list_all[$i]['columns']] = $sorting_list_all[$i]['sortmethod'];//仅有按列名排序的话  只需要这两个值
                }
            }
        }
        $this->sorting_list_all = $sorting_list_all;
        $this->sorting_list_byresult = $sorting_list_byresult;
        $this->sorting_list_bycolumnname = $sorting_list_bycolumnname;
    }

    public function getDetailedSql (){
        //明细1
        //字段
        $this->fields = array_unique($this->fields);//去重 如销售机会模块 选销售机会名称 销售机会编号 这个字段会有两个potentialid导致重复字段报错
        $detail_fields = implode(',',$this->fields);
        $mainModule = $this->mainmodule;
        $mainFocus = CRMEntity::getInstance($mainModule);
        $mainTableName = $mainFocus->table_name;
        $mainTableIndex = $mainFocus->table_index;
        $detailtype=intval($this->typevalue_arr['detail']);
        if(!empty($detail_fields)){
            $detail_fields .= " ,";
        }
        $detail_fields .= " $detailtype as type,'detail' as type_desc,$mainTableName.$mainTableIndex as maintableindex ";
        $detailSql = "select $detail_fields from  ".$this->selectColumnFrom;

        $allModules = $this->module_arr;
        $groupby_arr[]=$mainTableName.'.'.$mainTableIndex;
        foreach($this->module_arr as $kk=>$tmpmodule_arr) {
            if ($kk == 'mainmoduleSelected') {
                continue;
            }
            foreach ($tmpmodule_arr as $tmpmodule_index => $tmpmodulename) {
                if ($tmpmodulename != $mainModule && in_array($tmpmodulename, $this->wheremodule_arr)) {

                    //合同和费用报销 报表
                    //一个合同有4个费用报销，3个已审批
                    //按照费用 报销 的审批状态 查询
                    $tmpfocus = CRMEntity::getInstance($tmpmodulename);

                    $groupby_arr[] = $tmpfocus->table_name . '.' . $tmpfocus->table_index;
                }
            }
        }
        //zxm 20231010
        $joinOn = $mainTableName.'.'.$mainTableIndex.'=conditionSql.'.$mainTableName.$this->asfixedname.$mainTableIndex;

        if(!empty($this->DetailDableIdField)&&!empty($this->DetailDableIdField[0])){
            //zxm 20221012 查询条件是明细表的字段
            $groupby_arr[]= $this->DetailDableIdField[0];
            $DetailDableIdFieldArr = explode('.',$this->DetailDableIdField[0]);
            $joinOn = $this->DetailDableIdField[0].'=conditionSql.'.$DetailDableIdFieldArr[0].$this->asfixedname.$DetailDableIdFieldArr[1];
        }
        //拼接条件 zxm 20231009 条件sql不为空才inner join 条件子查询
        $limitsql = '';
        //edit: xll 2024/03/21 BUG20240110-99 报表编辑界面，点击翻页后没显示数据
        //if(isset($params['pagemode'])&&$params['pagemode']=='edit')
        //$limitsql = ' limit '. $this->getLimitSql();

        if(!empty($this->conditionSql))
            $detailSql .= ' inner join ('.$this->conditionSql.' group by '.implode(",",$groupby_arr).$limitsql.' )as conditionSql on '.$joinOn;


        foreach($this->wheremodule_arr as $tmpwheremodule)
        {
            if(empty($tmpwheremodule))
                continue;
            if($tmpwheremodule!=$mainModule)
            {
                $tmpfocus=CRMEntity::getInstance($tmpwheremodule);
                $wheremoduleindex=$tmpfocus->table_index;
                $tmpwheretablename=$tmpfocus->table_name;
                $detailSql.=" and conditionSql.".$tmpwheretablename.$this->asfixedname.$wheremoduleindex."=$tmpwheretablename.$wheremoduleindex";


            }
        }

        return $detailSql;
    }




    public function getGroupBySumSql()
    {
        if(sizeof($this->groupcolumn_arr)>0&&sizeof($this->sumcolumn_arr)>0)
        {
            crm_load_class_file('cls_sumSql','modules/CustomTables/ComputerSql');
            $sumsqlobj=new cls_sumSql($this);
            return $sumsqlobj->getGroupBySumSql();
        }

    }


    public function getGroupByMaxSql(){
        //按分组字段的求和2，3，4，5，6（最多五个分组字段）
        if(sizeof($this->maxcolumn_arr)>0)
        {
            crm_load_class_file('cls_maxSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_maxSql($this);
            return $maxsqlobj->getGroupBySumSql();
        }
    }

    public function getGroupByMinSql(){
        if(is_array($this->mincolumn_arr)&& sizeof($this->mincolumn_arr)>0)
        {
            crm_load_class_file('cls_minSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_minSql($this);
            return $maxsqlobj->getGroupBySumSql();
        }
    }
    public function getGroupByAvgSql(){
        if(is_array($this->avgcolumn_arr)&& sizeof($this->avgcolumn_arr)>0)
        {
            crm_load_class_file('cls_avgSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_avgSql($this);
            return $maxsqlobj->getGroupBySumSql();
        }
    }
    public function getGroupByCountSql(){

        if(is_array($this->countcolumn_arr)&&sizeof($this->countcolumn_arr)>0)
        {
            crm_load_class_file('cls_countSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_countSql($this);
            return $maxsqlobj->getGroupBySumSql();
        }
    }
    public function getGroupByDistinctCountSql(){
        if(is_array($this->distinctcountcolumn_arr) &&sizeof($this->distinctcountcolumn_arr)>0)
        {
            crm_load_class_file('cls_countDistinctSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_countDistinctSql($this);
            return $maxsqlobj->getGroupBySumSql();
        }
    }
    //求和的所有合计
    public function getTotalSql(){

        $totalsql_arr=[];
        $sumtotalsql='';

        if(is_array($this->groupcolumn_arr)&&is_array($this->sumcolumn_arr)&&sizeof($this->groupcolumn_arr)>0&&sizeof($this->sumcolumn_arr)>0)
        {
            crm_load_class_file('cls_sumSql','modules/CustomTables/ComputerSql');
            $sumsqlobj=new cls_sumSql($this);
            $sumsqlobj->setIstotal('yes');
            $sumtotalsql= $sumsqlobj->getGroupBySumSql();
            $totalsql_arr[]=$sumtotalsql;
        }



        if(sizeof($this->maxcolumn_arr)>0)
        {
            crm_load_class_file('cls_maxSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_maxSql($this);
            $maxsqlobj->setIstotal('yes');
            $totalsql_arr[]= $maxsqlobj->getGroupBySumSql();
        }


        if(sizeof($this->mincolumn_arr)>0)
        {
            crm_load_class_file('cls_minSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_minSql($this);
            $maxsqlobj->setIstotal('yes');
            $totalsql_arr[]= $maxsqlobj->getGroupBySumSql();
        }

        if(sizeof($this->countcolumn_arr)>0)
        {
            crm_load_class_file('cls_countSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_countSql($this);
            $maxsqlobj->setIstotal('yes');
            $totalsql_arr[]= $maxsqlobj->getGroupBySumSql();
        }

        if(sizeof($this->distinctcountcolumn_arr)>0)
        {
            crm_load_class_file('cls_countDistinctSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_countDistinctSql($this);
            $maxsqlobj->setIstotal('yes');
            $totalsql_arr[]= $maxsqlobj->getGroupBySumSql();
        }
        if(sizeof($this->avgcolumn_arr)>0)
        {
            crm_load_class_file('cls_avgSql','modules/CustomTables/ComputerSql');
            $maxsqlobj=new cls_avgSql($this);
            $maxsqlobj->setIstotal('yes');
            $totalsql_arr[]= $maxsqlobj->getGroupBySumSql();
        }
        return implode(" union all ",$totalsql_arr);

    }

    public function getLimitSql (){
        //分页Sql
        $params = $this->params;
        $start=$params['pagenum'];
        if($start>0)
        {
            $start=$start-1;
        }
        else{
            $start=0;
        }
        $startdate=$start*$this->limit;
        return "  $startdate,".$this->limit;

    }


}
?>