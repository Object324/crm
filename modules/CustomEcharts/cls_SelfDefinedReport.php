<?php
include_once globalStatic::$root_directory.'modules/CustomEcharts/EchartSetting.php';
class cls_SelfDefinedReport extends EchartSetting
{
    public $language;
    public $smarty;
    public $current_user;
    public $adb;
    public $params;
    public $ChartSetInfo; //图表设置信息
    public function __construct($params)
    {
        global $languageType,$adb;
        $this->language = $languageType;
        $this->adb = $adb;
        $this->params = $params;//前段传过来的所有参数
        $this->smarty = new lingdangCRM_Smarty();
    }
    /**
     * 报表详情页
     */
    public function getChart()
    {
        //时间数组
        $report_id = $this->params['report_id'];
        $charts = $this->getChartDataArr($report_id);

        $this->smarty->assign('report_id',$report_id);
        $this->smarty->assign("chart_info",$charts['data']);

        $this->smarty->assign("frommobile",$this->params['frommobile']);

        //zxm 20230423 app端的判断
        global $PlatformMC;
        if(is_array($PlatformMC) && array_key_exists('isnativeapp',$PlatformMC)&&$PlatformMC['isnativeapp']=='yes')
        {
            $encryptobj=new cls_MyCRMcrypt();
            $this->smarty->assign("wx_userid",$encryptobj->encode($this->params['userid']));
            $this->smarty->assign("appusertoken",$this->params['appusertoken']);
        }else{
            $this->smarty->assign("wx_userid",$this->params['userid']);
        }

        if($this->params['frommobile']=='yes'){
            //移动端查看页
            $corpurl_all = getCorpUrl();
            $corpurl_arr = explode('WeiXinApp',$corpurl_all);
            $this->smarty->assign("JSURL",$corpurl_arr[0]);
            $this->smarty->assign("CSSURL",$corpurl_arr[0]);
            $this->smarty->assign("CRMCOMMONURL",$corpurl_arr[0]);
            //wx_version
            $version_sql = "select wx_version from ld_version";
            $version_res = $this->adb->pquery($version_sql);
            $wx_version = $this->adb->query_result($version_res,0,0);
            $this->smarty->assign("wx_version",$wx_version);
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
            $this->smarty->assign("homefile",$homefile);
            $this->smarty->assign("environment",$weixin_user->environment);
            $this->smarty->assign("crm_url",$corpurl_arr[0]);
        }
        $isAjax = $this->params['isAjax'];
        $permit_create = isPermitted('ReportAnalysis','Create');
        $permit_edit = isPermitted('ReportAnalysis','EditView');
        if($isAjax=="no"){
            //链接模块
            $content = $this->smarty->fetch('CustomEcharts/chart.tpl');
            echo $content;die;
        }else{
            $content = $this->smarty->fetch('CustomEcharts/chart.tpl');
            $this->params['diony']='diony';
            $res['content'] = $content;
            $res['title'] = $charts['data']['report_name'];
            $res['permit_create'] = $permit_create;
            $res['permit_edit'] = $permit_edit;
            $arr['oktext'] = getFixedLabel("SAVE");
            $arr['canceltext'] = getFixedLabel("CANCEL");
            $res['chart_info'] = $charts['data'];
            $res['ChartSetInfo'] = $this->getChartSetInfo($charts['data']);
            ConvertTojsonString(1,$res,'success');die;
        }
    }
    public function getChartDataArr1($report_id){
        include_once globalStatic::$root_directory.'modules/CustomEcharts/EchartReport.php';
        $sqlObj = new EchartReport($this->params);
        if($this->params['fromhome'] === 'yes')
            $sqlObj->setHomeParams($this->params);


        if($report_id>0){
            $charts = $sqlObj->generalReportChart1($report_id);
        }else{
            $charts = $sqlObj->getChartSetInfoDefault();
        }
        return $charts;
    }
    public function getChartDataArr($report_id){
        include_once globalStatic::$root_directory.'modules/CustomEcharts/EchartReport.php';
        $sqlObj = new EchartReport($this->params);
        if($this->params['fromhome'] === 'yes')
            $sqlObj->setHomeParams($this->params);


        if($report_id>0){
            $charts = $sqlObj->generalReportChart($report_id);
        }else{
            $charts = $sqlObj->getChartSetInfoDefault();
        }
        return $charts;
    }
    /**
     * 报表详情页数据
     */
    public function getChartData()
    {
        //报表预览
        $report_id = $this->params['report_id'];
        $charts = $this->getChartDataArr($report_id);
        $ChartSetInfo = $this->getChartSetInfo($charts['data']);
        ConvertTojsonString($charts['code'],['list'=>$charts['data'],'ChartSetInfo'=>$ChartSetInfo],$charts['msg']);
    }

    public function getPenetrateModuleList(){
        $ClassName = 'CustomEchartsChuantou_Report';
        if(isset($this->params['ClassName']))
            $ClassName = $this->params['ClassName'];
        crm_load_class_file($ClassName,'modules/lingdang/cls_Report/');
        $obj = new $ClassName();
        $obj->setParams($this->params);
        $Fun_Name = 'getListView';
        $obj->$Fun_Name();
    }

    public function getPenetrateModuleList_Mobile(){
        $ChartSetInfo = json_decode($this->params['ChartSetInfo'],true);
        crm_load_class_file('DataRangeHomeboard','modules/Home/');
        $DataRangeHomeboardObj = new DataRangeHomeboard(0, $ChartSetInfo['mainmodule']);

        $params = [
            'ChartSetInfo' => $ChartSetInfo,
            'penetrateModule' => $ChartSetInfo['mainmodule'],
            'DataRangeHomeboardObj' => $DataRangeHomeboardObj,
            'curdatarangsql' => '',
            'scopeType' => 'SmOwner_Search_All',
            'selectuserid' => '',
            'curdatarangsql_str' => '',
            'popuptitle' => $ChartSetInfo['report_name'],
        ];

        crm_load_class_file('CustomEchartsChuantou_Report','modules/lingdang/cls_Report/');
        $obj = new CustomEchartsChuantou_Report();
        $obj->setParams($params);
        $Fun_Name = 'setExtroCondition';
        $obj->$Fun_Name();

        $page_list_query = $obj -> curdatarangsql_str;
        $res = $this->adb->pquery($page_list_query);
        $nums = $this->adb->num_rows($res);
        $ids = '-1';
        if($nums>0){
            $list = $this->adb->query_result_all($res,'a');
            $idsarr = _array_column($list,0);
            $ids = implode(',',$idsarr);
        }
        //小程序的链接
        $environment = $this->params['environment'];
        $result = ['ids'=>$ids];
        if($environment=='wxwork'||$environment=='weixin'){
            $urllink = $this->getMiniprogramUrlLink();
            $result['urllink'] = $urllink;
        }
        $this->params['diony'] = 'yes';
        ConvertTojsonString(1,$result,'success');die;
    }
    //自定义统计图  移动端穿透的时候 需要得到单据id  默认是-1
    public function getModuleSearchIds($selectmodule,$input)
    {
        global $current_user;
        $customView = new CustomView($selectmodule);
        $queryGenerator =QueryGenerator::getInstance($selectmodule, $current_user,$customView);

        $this->params['advft_criteria'] = $input['advft_criteria'];
        $this->params['advft_criteria_groups'] = $input['advft_criteria_groups'];
        $this->params['searchtype'] = $input['searchtype'];

        $queryGenerator->addUserSearchConditions($this->params);
        $page_list_query = $queryGenerator->getQuery('droppop', 1);
        $where = $queryGenerator->getConditionalWhere();

        $res = $this->adb->pquery($page_list_query);
        $nums = $this->adb->num_rows($res);
        $ids = '-1';
        if($nums>0){
            $list = $this->adb->query_result_all($res,'a');
            $idsarr = _array_column($list,0);
            $ids = implode(',',$idsarr);
        }
        return $ids;
    }
    /**
     * 新建报表页面
     */
    public function newChart()
    {
        $report_id = $this->params['report_id'];
        $Show_time_group_type = 'no';
        $mode = "create";
        $analysisfolder_id = 0;
        $charts = $this->getChartDataArr($report_id);
        if($report_id>0){
            $mode = "edit";
            $this->smarty->assign('mode',$mode);
            $charts = $charts['data'];
            $analysisfolder_id = $charts['analysisfolder_id'];
            $charts['chart_type_name'] = $this->getChartTypeName($charts['chart_type']);
        }
        //获取文件夹树状结构的options zxm 20221109  报表分析模块新建报表库报表
        require_once globalStatic::$root_directory.'modules/ReportAnalysis/ReportAnalysisActions.php';
        $ReportAnalysisActionsObj = new ReportAnalysisActions();
        $folderOptions = $ReportAnalysisActionsObj->getAllFolderOptions($analysisfolder_id);
        //图表类型
        $chartTypeArr = $this->getChartTypeAll();
        $this->smarty->assign('chartTypeArr',$chartTypeArr);
        $content = $this->smarty->fetch('CustomEcharts/createChart.tpl');
        $this->params['diony']='diony';
        $res['content'] = $content;
        $res['title'] = $report_id > 0 ? getFixedLabel("EDITCHART") : getFixedLabel("CREATENEWECHARTS") ;
        $arr['oktext'] = getFixedLabel("SAVE");
        $arr['canceltext'] = getFixedLabel("CANCEL");
        $this->params['type'] = 'init';
        $this->smarty->assign('step',$this->params['step']);
        $res['chart_info'] = $charts;
        $res['ChartSetArr']['mode'] = $mode;
        include_once globalStatic::$root_directory.'modules/CustomEcharts/EchartModule.php';
        $echartModuleObj = new EchartModule();
        $res['ChartSetArr']['ModuleArr'] = $echartModuleObj->getModuleArr_TabName();
        $res['ChartSetArr']['AxisFieldBigTypeArr'] = $this->AxisFieldBigTypeArr;
        $res['ChartSetArr']['Option']['FolderOptions'] = $folderOptions;
        $this->getChartSetArrOptionMsg($res['ChartSetArr']['Option']);
        $res['ChartSetInfo'] = $this->getChartSetInfo($charts);
        ConvertTojsonString(1,$res,'success');
    }



    public function getChartSetInfo($charts){
        crm_load_class_file('cls_ChartSetInfo','modules/CustomEcharts');
        $ChartSetInfoObj = cls_ChartSetInfo::getInstance($charts['report_id'],'');
        $ChartSetInfoObj->setChartInfo($charts);
        $ChartSetInfo = $ChartSetInfoObj->getChartSetInfo();
        return $ChartSetInfo;
    }

    public function getRelatedModule(){
        $moduleName = $this->params['mainmodule'];
        include_once globalStatic::$root_directory.'modules/CustomEcharts/EchartModule.php';
        $echartModuleObj = new EchartModule();
        $RelMoudleArr = $echartModuleObj->getRelatedModule($moduleName);
        $modules = array_values($RelMoudleArr);
        unset($RelMoudleArr[$moduleName]);
        ConvertTojsonString(1,['relatedModule'=>$modules,'RelMoudleArr'=>$RelMoudleArr],'success');
    }
    /**
     * 根据模块名称获取字段 select-option
     */
    public function getModuleFields()
    {
        ConvertTojsonString(1,['list'=>''],'success');
        $mainModule = $this->params['mainmodule'];
        $relatedModule = $this->params['relatedmodule'];
        $relatedModule = empty($relatedModule)?'':$relatedModule;
        include_once globalStatic::$root_directory.'modules/CustomEcharts/EchartModule.php';
        $echartModuleObj = new EchartModule();
        $fieldnames = $echartModuleObj->getModuleFieldsByModule($relatedModule,$mainModule);
        ConvertTojsonString(1,['list'=>$fieldnames],'success');
    }

    /**
     * edit: xll 2023/09/26
     * 根据模块名称获取字段列表
     */
    public function getModuleFieldsList()
    {
        $module = $this->params['modulename'];
        $IsMainModule = ($this->params['MainModule'] == $module) ? true : false;
        $focus=CRMEntity::getInstance($module);
        $moduleName = getTranstab($module);
        $moduleFieldsList = [];
        if($focus->fieldobj){
            $moduleFieldsList['main'] = $this->getFieldsList($focus->fieldobj,$module,'main',$IsMainModule);
        }
        //zxm @date:2024/12/3 @reason: BUG20241203-34 新建统计图-选择产品属性，会出产品明细，这边实际上是属性，确认还没做这部分的功能，需要先隐藏
        if($focus->detailfieldobj&&$module!='Products'){
            $moduleFieldsList['detail'] = $this->getFieldsList($focus->detailfieldobj,$module,'detail',$IsMainModule);
        }
        ConvertTojsonString(1,$moduleFieldsList,'success');
    }

    public $AxisFieldBigTypeArr = [
        //统计维度的BigTypeArr
        //wym BUG0075412 跟进记录--“多选联系人”字段，在报表分析--统计图中选不到
        'XAxis' => ['text','reference','users','selectoneuser','picklist','date','datetime','multireference'],
        //统计字段的BigTypeArr
        'YAxis' => ['currency','int','number','moduleno','num','Num','amount','reference','text','date','datetime','multireference'],
    ];

    public function getFieldsList($FieldsObj,$module,$FieldType,$IsMainModule){
        $FieldsArr = [];
        $FieldsList = $FieldsObj->getModuleFields();

        foreach ($FieldsList as $fieldName => $fieldInfo){
            $bigtype = $fieldInfo->getBigtype();
            $IsXAxisField = (in_array($bigtype,$this->AxisFieldBigTypeArr['XAxis'])) ? 'Yes' : 'No';
            $IsYAxisField = (in_array($bigtype,$this->AxisFieldBigTypeArr['YAxis'])) ? 'Yes' : 'No';
            if($IsXAxisField == 'No' && $IsYAxisField == 'No')
                continue;
            $AxisTypeAll = 'All';
            if($IsXAxisField == 'No')
                $AxisTypeAll = 'YAxis';
            if($IsYAxisField == 'No')
                $AxisTypeAll = 'XAxis';
            $AxisType = [
                'XAxis' => $IsXAxisField,
                'YAxis' => $IsYAxisField,
            ];
            $tablename = $fieldInfo->getTableName();
            $columname = $fieldInfo->getColumnName();
            $fieldlabel = $fieldInfo->getfieldLabel();
            $typeofdata_arr = explode('~',$fieldInfo->getTypeOfData());
            $combine_column = $tablename.":".$columname.":".$fieldName.":".$module."_fieldlabel:".$typeofdata_arr[0];
            $FieldsArr[$fieldName] = array(
                'value'=>$combine_column,'label'=>$fieldlabel,'bigtype'=>$bigtype,'AxisType'=>$AxisType,
                'FieldModule'=>$module,'FieldType'=>$FieldType,'AxisTypeAll'=>$AxisTypeAll
            );
        }
        return $FieldsArr;
    }


    /**
     * 保存统计图设置信息
     * 每个按钮点击都是全部保存
     */
    public function saveReportInfo()
    {
        global $current_user;
        $ChartSetInfo = json_decode($this->params['ChartSetInfo'],true);
        if(empty($ChartSetInfo))
            die('空数据' ) ;
        $this->ChartSetInfo = $ChartSetInfo;

        $report_id = $ChartSetInfo['report_id'];
        $report_name = $ChartSetInfo['report_name'];
        $report_type = isset($this->params['report_type']) ? $this->params['report_type'] : 'chart';
        //$ChartSetInfo['chart_type'];
        $linkmodulecheck = $ChartSetInfo['linkmodulecheck'] ? 'yes' : 'no';//是否设置为链接模块
        $relatedmodule = '';
        $relatedmodule_arr = $ChartSetInfo['relatedmodule'];
        $relatedmodule = implode(',',$relatedmodule_arr);
        $ChartSetInfo['LegendLocate'] = strtolower($ChartSetInfo['LegendLocate']);
        $ChartSetInfo['ThemeSet'] = strtolower($ChartSetInfo['ThemeSet']);
        //$relatedmodule = empty($relatedmodule)?'':implode(',',$relatedmodule);

        //报表名称正则判断
        /*$preg_match = preg_match("/^[\x{4e00}-\x{9fa5}A-Za-z0-9_]+$/u",$report_name);
        if($preg_match!=1){
            ConvertTojsonString(-1,['data'=>'报表名称只允许输入中文数字字母！'],'success');
        }*/
        $stat_approach = $this->params['stat_approach'];
        $stat_approach = empty($stat_approach)?'':$stat_approach;//同比 环比
        //是否显示在首页 勾选
        $show_athome = (isset($ChartSetInfo['show_athome']) && $ChartSetInfo['show_athome']) ? 'yes' : 'no';//显示在首页
        $can_penetrate = (isset($ChartSetInfo['can_penetrate']) && $ChartSetInfo['can_penetrate']) ? 'yes' : 'no';//允许穿透
        //显示类目条数
        $limit = $ChartSetInfo['limit'];
        $limit = empty($limit) ? 0 : $limit;
        //基本信息
        $this->adb->startTransaction();//开启事务
        if(empty($report_id)){
            //新增ld_customreport
            $sql = "insert into ld_customreport (report_name,report_desc,mainmodule,parent_id,report_type,deleted,createdtime,smcreatorid,
                stat_approach,show_athome,linkmodulecheck,can_penetrate,relatedmodule,analysisfolder_id,themename,
                advance_demand,advance_demand_groups,`limit`,isshow_table) 
                values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
            $tmp_params = [
                $ChartSetInfo['report_name'],$ChartSetInfo['report_desc'],$ChartSetInfo['mainmodule'],$this->params['parent_id'],$report_type,0,
                date('Y-m-d H:i:s',time()),$current_user->id,$stat_approach,$show_athome,$linkmodulecheck,$can_penetrate,
                $relatedmodule,$ChartSetInfo['analysisfolder_id'],$ChartSetInfo['ThemeSet'],$ChartSetInfo['OtherCondition']['advance_demand'],
                $ChartSetInfo['OtherCondition']['advance_demand_groups'],$limit,$ChartSetInfo['ReportStyle']
            ];
            $this->adb->pquery($sql,$tmp_params);
            $report_id = $this->adb->getLastInsertID();
            $this->ChartSetInfo['report_id'] = $ChartSetInfo['report_id'] = $report_id;
        }else{
            //编辑ld_customreport
            $sql = "update ld_customreport set report_name=?,report_desc=?,mainmodule=?,parent_id=?,stat_approach=?, show_athome=?,
                linkmodulecheck=?,can_penetrate=?,relatedmodule=?,report_type=?,analysisfolder_id=?,themename=?,advance_demand=?,
                advance_demand_groups=?,`limit`=?,isshow_table=?  
                where report_id=?";
            $tmp_params = [
                $ChartSetInfo['report_name'],$ChartSetInfo['report_desc'],$ChartSetInfo['mainmodule'],$this->params['parent_id'],$stat_approach,
                $show_athome,$linkmodulecheck,$can_penetrate,$relatedmodule,$report_type,$ChartSetInfo['analysisfolder_id'],
                $ChartSetInfo['ThemeSet'],$ChartSetInfo['OtherCondition']['advance_demand'],
                $ChartSetInfo['OtherCondition']['advance_demand_groups'],$limit,$ChartSetInfo['ReportStyle'],$report_id
            ];
            $this->adb->pquery($sql,$tmp_params);
        }
        //默认给所有用户权限
        $permit_sql='insert into ld_customecharts2user(report_id,userid)values(?,?)';
        $this->adb->pquery($permit_sql,array($report_id,'-1'));
        //chertset 图表样式信息的信息保存 Y轴保存
        $this->setChartSet();

        //统计维度的信息保存
        $group_deleted = "delete from ld_customreport_group where report_id=?";
        $this->adb->pquery($group_deleted,[$report_id]);
        $XAxisFieldList = $ChartSetInfo['AxisFields']['XAxis'];

        foreach ($XAxisFieldList as $index => $XAxisFieldInfo){
            $columns = $XAxisFieldInfo['FieldValue'];
            //TimeMethod 默认值byField，即非时间类型字段
            $groupbytype = isset($XAxisFieldInfo['TimeMethod']) ? $XAxisFieldInfo['TimeMethod'] : 'byField';
            $bigtype = $XAxisFieldInfo['BigType'];
            $group_insert = "insert into ld_customreport_group (report_id,groupbytype,columns,`sequence`,bigtype) values (?,?,?,$index,?)";
            $this->adb->pquery($group_insert,[$report_id,$groupbytype,$columns,$bigtype,]);
        }
        $group_deleted2 = "delete from ld_customreport_total_column where report_id=?";
        $this->adb->pquery($group_deleted2, array($report_id));
        $YAxisFieldList = $ChartSetInfo['AxisFields']['YAxis'];

        foreach ($YAxisFieldList as $index => $YAxisFieldInfo){
            $total_type = $YAxisFieldInfo['CalcMethod'];
            $columns = $YAxisFieldInfo['FieldValue'];
            $chart_column_type = $YAxisFieldInfo['SeriesType'];
            if (empty($chart_column_type)) {
                //数据列类型为空 给默认值
                $chart_column_type = $this->getSeriesType($ChartSetInfo['chart_type']);
            }
            $color = '';
            $chart_column_name = $YAxisFieldInfo['DisplayName'];
            $yaxisindex = $YAxisFieldInfo['YAxisIndex'];
            $column_module = $YAxisFieldInfo['FieldModule'];
            $compare_select = $YAxisFieldInfo['CompareSelect'];
            $column_insert = "insert into ld_customreport_total_column (total_type,columns,sequence,report_id,chart_column_type,
                color,chart_column_name,yaxisindex,column_module,compare_select) values (?,?,?,?,?,?,?,?,?,?)";
            $column_params = array($total_type,$columns,$index,$report_id,$chart_column_type,$color,
                $chart_column_name,$yaxisindex,$column_module,$compare_select);
            $this->adb->pquery($column_insert,$column_params);
        }

        //勾选创建链接模块
        $this->createLinkModule($report_name,$report_id,$linkmodulecheck);

        //排序设置信息的保存
        $this->saveReportSortingMethod($report_id);
        //勾选首页查询条件  三个  --去掉了20230627 现在这个设置在首页按看板设置
        $res['request'] = $ChartSetInfo;
        $chart_info = $this->getChartDataArr($report_id);

        $res['chart_info'] = $chart_info['data'];
        //增加最新浏览记录
        $logsql="select browse_id from ld_report_analysis_folder_log where reportid=? and module=? and userid=?";
        $result=$this->adb->pquery($logsql,[$report_id,'CustomEcharts',$current_user->id]);
        $nums=$this->adb->num_rows($result);
        $browse_id=$this->adb->query_result($result,0,'browse_id');
        if($nums==0){
            $logsql="insert into ld_report_analysis_folder_log(reportid,module,userid,view_time) value (?,?,?,?)";
            $this->adb->pquery($logsql,array($report_id,'CustomEcharts',$current_user->id,date("Y-m-d H:i:s")));
        }else{
            $logsql="update ld_report_analysis_folder_log set view_time=?,visible='yes' where browse_id=?";
            $this->adb->pquery($logsql,array(date("Y-m-d H:i:s"),$browse_id));
        }

        $saveType = $this->params['saveType'];
        if($saveType === 'Preview') {
            //$this->deleteReportById($ChartSetInfo['report_id']);
        }


        $this->adb->completeTransaction();//结束事务

        if($chart_info['code']==-1){
            ConvertTojsonString(-1,$res,$chart_info['msg']);die;
        }
        //图表信息
        ConvertTojsonString(1,$res,'success');
    }
    //zxm 20220818 排序方式的保存
    public function saveReportSortingMethod($report_id){
        $deleted_sql = "delete from ld_customreport_sorting where report_id=?";
        $this->adb->pquery($deleted_sql,array($report_id));
        $SeqSetInfo = $this->ChartSetInfo['SeqSet'];
        if(count($SeqSetInfo) > 0){
            foreach($SeqSetInfo as $SeqIndex => $SeqItem){
                $SeqType = $SeqItem['SeqType'];
                $SeqFieldArr = explode('-',$SeqItem['SeqField']);
                $SeqField = $SeqFieldArr[0];
                $total_type = $SeqFieldArr[1];   //部分字段需要显示计算方式 / 时间统计方式
                $SeqMethod = $SeqItem['SeqMethod'];
                $insert_sql = "insert into ld_customreport_sorting (report_id,sorttype,columnmodule,`columns`,sortmethod,`sequence`,total_type) select ?,?,?,?,?,?,? from dual
            where not exists(select 1 from ld_customreport_sorting where report_id =? and `columns` = ? and total_type=?)";
                $this->adb->pquery($insert_sql,array($report_id,$SeqType,'',$SeqField,$SeqMethod,$SeqIndex,$total_type,
                    $report_id,$SeqField,$total_type));
            }
        }
    }

    //echarts 样式设置信息
    public function setChartSet(){
        parent::setChartSet();
    }
    //勾选创建链接模块
    public function createLinkModule($report_name,$report_id,$linkmodulecheck){
        global $currentModule, $current_user;

        $url = 'index.php?module='.$currentModule.'&action='.$currentModule.'Ajax&file=SelfDefinedReport&function_name=getChart&isAjax=no&report_id='.$report_id;
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
    //获取小程序短链接
    public function getMiniprogramUrlLink(){
        $mainmodule = $this->params['mainmodule'];
        $ids = $this->params['ids'];
        //查询
        global $adb;
        $sql = " select para_content,para_one from ld_wx_config where name='wechat_miniprogram_setting'";
        $res = $adb->pquery($sql);
        $para_content = $adb->query_result($res,0,'para_content');
        $para_content = Zend_Json::decode($para_content);

        if(empty($para_content)||$para_content['mini_appid']=="wx608d4c0ec205411f"||$para_content['msgsend_type']=='msgsend_typeld'){
            require_once globalStatic::$root_directory.'include/weixinMsg/MsgConfig.php';
            $ldappidsecret = MsgConfig::$ldappidsecret;
            $miniprogram_appid = $ldappidsecret['mini_appid'];//灵当小程序appid
            $miniprogram_secret = $ldappidsecret['mini_secret'];//灵当小程序 app secret
        }else{
            $miniprogram_appid = $para_content['mini_appid'];//小程序appid
            $miniprogram_secret = $para_content['mini_secret'];//小程序 app secret
        }

        include_once globalStatic::$root_directory.'include/weixinMsg/cls_WXaccessToken.php';
        $wxObj = new cls_WXaccessToken($miniprogram_appid,$miniprogram_secret,'CRMminiprogram','CRM小程序','CRMminiprogram');
        $page = "/pages/listview/listview";
        $query = "modulename=".$mainmodule.'&getcode=yes&second_action=report_list&second_para='.$ids;;
        $urllink = $wxObj->getUrlLink($page,$query);
        return $urllink;
    }

}

?>
