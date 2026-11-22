<?php
class cls_SqlEchartsEditView
{
    public $language;
    public $smarty;
    public $current_user;
    public $adb;
    public $params;
    public $CustomEchartsActionsObj;
    public function __construct($params)
    {

        global $adb,$languageType;
        $this->adb = $adb;
        $this->params = $params;
        $this->language = $languageType;
        $this->smarty = new lingdangCRM_Smarty();
        include globalStatic::$root_directory.'modules/CustomEcharts/CustomEchartsActions.php';
        $this->CustomEchartsActionsObj = new CustomEchartsActions($this->params);
        $this->CustomEchartsActionsObj->setHomeParams($this->params);
    }
    /**
     * 新建报表页面
     */
    public function index()
    {
        $report_id = $this->params['report_id'];
        $this->smarty->assign("report_id",$report_id);
        $mode = "create";
        $analysisfolder_id = 0;

        if($report_id>0){
            $mode = "edit";
            $this->smarty->assign('mode',$mode);
            //编辑
            $charts = $this->CustomEchartsActionsObj->getSqlDetailData($this->params['report_id']);
            $analysisfolder_id = $charts['mainInfo']['analysisfolder_id'];
            $charts['chartSet']['chart_type_name'] = $this->CustomEchartsActionsObj->getChartTypeName($charts['chartSet']['chart_type']);
            $charts['mainInfo']['sqlFilterArrCount'] = count($charts['sqlFilterArr']);
            $this->smarty->assign('mainInfo',$charts['mainInfo']);//主表信息 选择文件夹 统计图名称 描述 设为链接模块
            $this->smarty->assign('chartSet',$charts['chartSet']);//图表设置信息  图表类型
            $this->smarty->assign('sqlColumnsArr',$charts['sqlColumnsArr']);//sql解析出来的字段信息
            $this->smarty->assign('sqlFilterArr',$charts['sqlFilterArr']);//sql变量信息
            $this->smarty->assign('groupInfo',$charts['groupInfo']);//统计维度信息
            $this->smarty->assign('columnInfo',$charts['columnInfo']);//统计字段信息
            //获取映射首页条件的变量个数
            $this->smarty->assign('var_multiuser_nums',$this->CustomEchartsActionsObj->var_multiuser_nums);
            $this->smarty->assign('var_time_nums',$this->CustomEchartsActionsObj->var_time_nums);
            $this->smarty->assign('var_approvestatus_nums',$this->CustomEchartsActionsObj->var_approvestatus_nums);
            //字段下拉框
            $fields = $this->CustomEchartsActionsObj->getSqlColumns($report_id);
            $this->smarty->assign('fields ',$fields );
        }

        //获取文件夹树状结构的options zxm 20221109  报表分析模块新建报表库报表
        require_once globalStatic::$root_directory.'modules/ReportAnalysis/ReportAnalysisActions.php';
        $ReportAnalysisActionsObj = new ReportAnalysisActions();
        $folderOptions = $ReportAnalysisActionsObj->getAllFolderOptions($analysisfolder_id);
        $this->smarty->assign('frommodule',$this->params['frommodule']);
        $this->smarty->assign('folderOptions',$folderOptions);//zxm 20221109  报表分析模块新建报表库报表

        //图表类型
        $chartTypeArr = $this->CustomEchartsActionsObj->getChartTypeAll();
        //unset($chartTypeArr['sunburst']);//去掉旭日图
        $this->smarty->assign('chartTypeArr',$chartTypeArr);
        $content = $this->smarty->fetch('CustomEcharts/createChart.tpl');

        $res['content'] = $content;
        $res['title'] = $report_id>0?getFixedLabel("EDIT")."SQL".getFixedLabel("statisticalGraphics"):
            getFixedLabel("CREATE")."SQL".getFixedLabel("statisticalGraphics");
        $res['oktext'] = getFixedLabel("SAVE");
        $this->smarty->assign('request',$this->params);
        //默认parent_id
        $parent_id = $this->params['parent_id'];
        $this->smarty->assign('parent_id',$parent_id);
        $this->params['type'] = 'init';
        $this->smarty->assign('step',$this->params['step']);
        $res['chart_info'] = $charts;


        $ChartSetArr['mode'] = $mode;
        $ChartSetArr['Option']['FolderOptions'] = $folderOptions;
        $this->CustomEchartsActionsObj->getChartSetArrOptionMsg($ChartSetArr['Option']);
        //旭日图 SQL统计图特殊的旭日图显示数据标签
        $ChartSetArr['Option']['SeriesDataLabel'][] = ['Value'=>'inside_tangential','Label'=>getFixedLabel("INTERNAL"),'filter'=>'sunburst'];    //内部 -旭日图
        $ChartSetArr['Option']['SeriesDataLabel'][] = ['Value'=>'inside_radial','Label'=>getFixedLabel("inside_radial"),'filter'=>'sunburst'];    //内部-冲圆心 -旭日图
        $ChartSetArr['Option']['SeriesDataLabel'][] = ['Value'=>'none','Label'=>getFixedLabel("HIDE"),'filter'=>'sunburst'];   //不显示
        $ChartSetArr['FieldList'] = [
            'SqlField' => $charts['sqlColumnsArr'],
            'Variable' => $charts['sqlFilterArr'],
        ];
        $res['ChartSetArr'] = $ChartSetArr;
        if(isset($charts['ChartSetInfo']))
            $res['ChartSetInfo'] = $charts['ChartSetInfo'];
        else
            $res['ChartSetInfo'] = $this->CustomEchartsActionsObj->getChartSetInfoDefault();

        ConvertTojsonString(1,$res,'success');die;
    }
    public function getChartSetInfo($chart_info){
        return $chart_info['ChartSetInfo'];
    }

    //2023-0214 执行SQL语句 XUQIU1000607	统计表 自定义统计图-支持SQL语句
    public function parserSql(){
        //$sqlstr = base64_decode($this->>params['sqlstr']);
        $cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
        $sqlstr =$cls_AESencryptionbykeyobj->getdecryption($this->params['sqlstr']);
        $report_id = $this->params['report_id'];
        require_once globalStatic::$root_directory. 'sqlparser/vendor/autoload.php';
        $parser = new PhpMyAdmin\SqlParser\Parser($sqlstr);
        if(sizeof($parser->statements)<=0)
        {
            ConvertTojsonString(0,[],'不符合条件的sql！');die;
        }
        $parserArr = $parser->statements;
        $columnnames = [];
        $is_procedure = 'no';
        $is_select = 'no';
        foreach($parserArr as $parserOne){
            //判断是不是查询语句  要每个都判断 不放过任何一个不是select的语句
            if($parserOne instanceof  PhpMyAdmin\SqlParser\Statements\SelectStatement)
            {
                $is_select = 'yes';

            } else if($parserOne instanceof  PhpMyAdmin\SqlParser\Statements\CallStatement) {
                //存储过程
                $is_procedure = 'yes';
            }else{
                ConvertTojsonString(0,[],'不是查询语句！');die;
            }
        }
        //字段数组
        $columnsarr = [];
        //查询语句
        if($is_select=='yes'){
            //解析SQL
            $expr = $parserArr[0]->expr;
            foreach($expr as $k=>$columninfo){
                $alias = $columninfo->alias;
                $column = $columninfo->column;
                if(!empty($alias)){
                    $columnnames[] = $alias;
                }else{
                    $columnnames[] = $column;
                }
                $alias = empty($alias)?$column:$alias;
                //判断该字段在columns表中是否存在 不存在则新增
                $insert_sql = "insert into ld_customreportsql_column (report_id,column_label,columns,is_group,sequence,fieldtype)select ?,?,?,'no',?,'string' from dual where not exists(select 1 from ld_customreportsql_column where columns=? and report_id=?)";
                $this->adb->pquery($insert_sql,array($report_id,$alias,$alias,$k+1,$alias,$report_id));
            }
        }
        //存储过程语句
        if($is_procedure=='yes'){
            $pro_res = $this->adb->pquery($sqlstr);
            $columnnames = $this->adb->getFieldsArray($pro_res);
            require_once globalStatic::$root_directory.'include/database/PearDatabase.php';
            global $adb;
            $adb = null;
            $adb = PearDatabase::getInstance();
            $this->adb = $adb;
            $this->CustomEchartsActionsObj->adb = $adb;
            foreach($columnnames as $k=>$column2){
                //判断该字段在columns表中是否存在 不存在则新增
                $insert2_sql = "insert into ld_customreportsql_column (report_id,column_label,columns,is_group,sequence,fieldtype) select ?,?,?,'no',?,'string' from dual where not exists(select 1 from ld_customtable_columns where columns=? and report_id=?);";
                $this->adb->pquery($insert2_sql,array($report_id,$column2,$column2,$k+1,$column2,$report_id));
            }
        }

        //将sql和report_name 保存
        $update_sql = "update ld_customreport set report_name=?,sqlstr=? where report_id=?";
        $this->adb->pquery($update_sql,array($this->params['report_name'],$sqlstr,$report_id));

        //将不存在的字段删除
        $deleted_sql = "delete from ld_customreportsql_column where report_id=? and `columns` NOT IN ("."'".implode("','",$columnnames)."'".")";
        $this->adb->pquery($deleted_sql,array($report_id));

        //查询字段
        $columnsarr = $this->CustomEchartsActionsObj->getSqlColumns($report_id);
        $this->params['diony'] = 'yes';
        ConvertTojsonString(1,[
            'columnsarr'=>$columnsarr
        ],'SQL yes');die;

    }

    //2022-0805 执行SQL语句 XUQIU1000530	统计表 自定义统计表-支持SQL语句   字段设置页面
    public function editSqlColumns(){
        $columnid = $this->params['columnid'];
        $report_id = $this->params['report_id'];
        $column_sql = "select * from ld_customreportsql_column where id=?";
        $column_res = $this->adb->pquery($column_sql,array($columnid));
        $columnInfo = $this->adb->query_result_rowdata($column_res);
        $this->smarty->assign("columnInfo",$columnInfo);
        $content = $this->smarty->fetch('CustomEcharts/editSqlColumns.tpl');
        $this->params['diony']='diony';
        $res['content'] = $content;
        $res['title'] = getFixedLabel('ACTIVITYFIELDSETTINGS');
        ConvertTojsonString(1,$res,'success');
    }
    //统计图 自定义统计图 -支持SQL语句   字段设置保存
    public function saveSqlColumns(){
        //只会有编辑 不会有新增
        $update_sql = "update ld_customreportsql_column set column_label=?,fieldtype=? where id=? ";
        $this->adb->pquery($update_sql,array($this->params['column_label'],$this->params['fieldtype'],$this->params['columnid']));
        ConvertTojsonString(1,['column_label'=>$this->params['column_label']],'success');
    }
    //变量编辑或新增页面
    public function editVariable(){
        $filterid = $this->params['filterid'];
        $report_id = $this->params['report_id'];
        $filterInfo = [];
        if($filterid>0){
            $filter_sql = "select * from ld_customreportsql_filter where id=?";
            $filter_res = $this->adb->pquery($filter_sql,array($filterid));
            $filterInfo = $this->adb->query_result_rowdata($filter_res);
        }
        $filterInfo['report_id'] = $report_id;

        //模块信息--所有模块
        $module_arr = $this->CustomEchartsActionsObj->getModuleArr();
        //这里需要返回销售目标  zxm BUG0073264 kfbcrm-报表分析-新建模块报表-变量设置-目标范围选不到 销售目标
        $salesgoalline = [
            'presence'=>'-1',
            'customized'=>'0',
            'name'=>getTranstab('SalesGoal'),
            'modulename'=>'SalesGoal',
            'description'=>''
        ];
        array_push($module_arr,$salesgoalline);
        
        $this->smarty->assign("module_arr",$module_arr);
        //字段信息
        $picklists = [];
        if($filterid>0&&!empty($filterInfo['modulename'])){
            $picklists = $this->CustomEchartsActionsObj->getPickListsByModule($filterInfo['modulename']);
        }

        if($filterid>0){
            //下拉框值
            $filterInfo['selectvalues_arr'] = [];
            if($filterInfo['var_type']=='select'||$filterInfo['var_type']=='multiselect') {
                $selectvalues = $filterInfo['selectvalues'];
                $filterInfo['selectvalues_arr'] = explode(',', $selectvalues);
            }
            //多选的默认值
            if($filterInfo['var_type']=='multiselect') {
                $default_value = $filterInfo['default_value'];
                $filterInfo['default_value_arr'] = explode(',', $default_value);
            }
        }
        //日期和日期时间的默认值
        if($filterInfo['var_type']=='date'||$filterInfo['var_type']=='datetime'){
            $default_value = $filterInfo['default_value'];
            $default_value_arr = explode(',',$default_value);
            $filterInfo['default_value'] = $default_value_arr[0];
            $filterInfo['datevalue'] = substr( $default_value_arr[1],0,10) ;
            $filterInfo['datetimevalue'] = $default_value_arr[1];
        }
        //审批组件的默认值
        if($filterInfo['var_type']=='approvestatus'){
            $default_value = $filterInfo['default_value'];
            $filterInfo['approvestatus_default_value_arr'] = explode(',', $default_value);
        }
        //edit:duan date:2024/11/16 reason:将审批状态更改为翻译字段，并增加颜色显示
        $approve_list = getHomeApproveList();
        $this->smarty->assign("ApproveList",$approve_list);
        $this->smarty->assign("filterInfo",$filterInfo);
        $this->smarty->assign("picklists",$picklists);
        $this->smarty->assign("show_department",'no');//自定义SQL统计图 不显示部门和当前用户的变量类型

        $content = $this->smarty->fetch('CustomTables/editVariable.tpl');//模板文件跟自定义统计表的公用
        $this->params['diony']='diony';
        $res['content'] = $content;
        $res['title'] = getFixedLabel('VAR').getFixedLabel('SETTINGS');
        ConvertTojsonString(1,$res,'success');
    }
    //变量保存
    public function saveVariable(){
        $filterid = $this->params['filterid'];
        $report_id = $this->params['report_id'];
        $var_type = $this->params['var_type'];
        //变量名不能重复
        $var_name = $this->params['var_name'];
        $select_sql = "select 1 from ld_customreportsql_filter where report_id=? and var_name=?";
        if($filterid>0){
            $select_sql .= " and id<>".$filterid;
        }
        $select_res = $this->adb->pquery($select_sql,array($report_id,$var_name));
        $select_nums = $this->adb->num_rows($select_res);
        if($select_nums>0){
            ConvertTojsonString(-1,[],'变量名不允许重复！');exit;
        }
        //var_name=accountname&display_name=%E5%AE%A2%E6%88%B7%E5%90%8D%E7%A7%B0&var_type=string
        if($filterid>0){
            //编辑
            $update_sql = "update ld_customreportsql_filter set var_name=?,display_name=?,var_type=? where id=?";
            $this->adb->pquery($update_sql,array($var_name,$this->params['display_name'],$var_type,$filterid));
        }else{
            //最大排序值
            $sequence_sql = "select ifnull(max(sequence),0) as sequence from ld_customreportsql_filter where report_id=?";
            $sequence_res = $this->adb->pquery($sequence_sql,array($report_id));
            $sequence_nums = $this->adb->num_rows($sequence_res);
            if($sequence_nums>0){
                $sequence = $this->adb->query_result($sequence_res,0,0);
            }else{
                $sequence = 0;
            }

            //新增
            $insert_sql = "insert into ld_customreportsql_filter (var_name,display_name,var_type,report_id,sequence) values(?,?,?,?,?)";
            $insert_res = $this->adb->pquery($insert_sql,array($var_name,$this->params['display_name'],$var_type,$report_id,$sequence+1));
            $filterid = $this->adb->getLastInsertID($insert_res);
        }
        //模糊查找 下拉框 多选框 多选用户 单选用户 日期 日期时间 数字
        //日期 日期时间  存储默认值
        if($var_type=='date'||$var_type=='datetime'){
            $default_value_selectdate = $this->params['default_value_selectdate'];
            $datevalue = $this->params['datevalue'];
            $datetimevalue = $this->params['datetimevalue'];
            if($default_value_selectdate!='selfdefined'){
                $datetimevalue = $this->CustomEchartsActionsObj->getFilterDefaultValue($default_value_selectdate);
                $datevalue = substr($datetimevalue,0,10);
            }

            //将值存到 字段中去
            if($var_type=='date'){
                $default_value_selectdate = $default_value_selectdate.','.$datevalue;
            }
            if($var_type=='datetime'){
                $default_value_selectdate = $default_value_selectdate.','.$datetimevalue;
            }

            $update1_sql = "update ld_customreportsql_filter set default_value=? where id=?";
            $this->adb->pquery($update1_sql,array($default_value_selectdate,$filterid));
        }
        else if($var_type=='number'){
            $default_value = $this->params['default_value'];
            $update1_sql = "update ld_customreportsql_filter set default_value=? where id=?";
            $this->adb->pquery($update1_sql,array($default_value,$filterid));
        }
        else if($var_type=='select'){
            //存储下拉框值 默认值等信息
            $select_source = $this->params['select_source'];
            //来源下拉框字段
            if($select_source=='picklist'){
                $update2_sql = "update ld_customreportsql_filter set select_source=?,modulename=?,fieldname=?,selectvalues=?,default_value=? where id=?";
                $this->adb->pquery($update2_sql,array($select_source,$this->params['modulename'],$this->params['fieldname'],$this->params['selectvalues'],$this->params['default_value_select'],$filterid));
            }else{
                $update2_sql = "update ld_customreportsql_filter set select_source=?,selectvalues=?,default_value=? where id=?";
                $this->adb->pquery($update2_sql,array($select_source,$this->params['selectvalues'],$this->params['default_value_select'],$filterid));
            }

        }else if($var_type=='multiselect'){
            //存储下拉框值 默认值等信息
            $select_source = $this->params['select_source'];
            $default_multivalue_select = $this->params['default_multivalue_select'];
            $default_multivalue_select = implode(',',$default_multivalue_select);
            //来源下拉框字段
            if($select_source=='picklist'){
                $update2_sql = "update ld_customreportsql_filter set select_source=?,modulename=?,fieldname=?,selectvalues=?,default_value=? where id=?";
                $this->adb->pquery($update2_sql,array($select_source,$this->params['modulename'],$this->params['fieldname'],$this->params['selectvalues'],$default_multivalue_select,$filterid));
            }else{
                $update2_sql = "update ld_customreportsql_filter set select_source=?,selectvalues=?,default_value=? where id=?";
                $this->adb->pquery($update2_sql,array($select_source,$this->params['selectvalues'],$default_multivalue_select,$filterid));
            }
        }else if($var_type=='multiuser'){
            $modulename = $this->params['modulename'];
            //默认值
            $scopeobj = new ScopOfAuthority($this->adb,$modulename);
            $userids = $scopeobj->getCurUserScopeIds();
            $update3_sql = "update ld_customreportsql_filter set modulename=?,default_value=? where id=?";
            $this->adb->pquery($update3_sql,array($modulename,$userids,$filterid));
        }else if($var_type=='approvestatus'){
            //审批状态组件的默认值
            $default_value_approvestatus_value = $this->params['default_value_approvestatus_value'];
            if(!empty($default_value_approvestatus_value)){
                $default_value_approvestatus_value_str = implode(',',$default_value_approvestatus_value);
                $update4_sql = "update ld_customreportsql_filter set default_value=? where id=?";
                $this->adb->pquery($update4_sql,array($default_value_approvestatus_value_str,$filterid));
            }
        }
        $sqlFilterArr = $this->CustomEchartsActionsObj->getSqlFilter($report_id);
        ConvertTojsonString(1,['sqlFilterArr'=>$sqlFilterArr],'success！');
    }
    public function getDefaultDateValue(){
        $default_value_selectdate = $this->params['default_value_selectdate'];
        $value = $this->CustomEchartsActionsObj->getFilterDefaultValue($default_value_selectdate);
        $value_date = substr($value,0,10);
        ConvertTojsonString(1,['value_date'=>$value_date,'value'=>$value],'success！');
    }
    public function getPickListsByModule(){
        $modulename = $this->params['modulename'];
        $picklists = $this->CustomEchartsActionsObj->getPickListsByModule($modulename);
        ConvertTojsonString(1,['picklists'=>$picklists],'success');
    }
    public function resetSqlVarSequence(){
        $filterid_str = $this->params['filterid_str'];
        $sequence_str = $this->params['sequence_str'];
        $filterid_arr = explode(',',$filterid_str);
        foreach($filterid_arr as $index=>$filterid){
            $update_sql = "update ld_customreportsql_filter set sequence=? where id=?";
            $this->adb->pquery($update_sql,array($index+1,$filterid));
        }
        ConvertTojsonString(1,[],'success');
    }
    //删除变量
    public function variableDelete(){
        $filterid = $this->params['filterid'];
        $delete_sql = "delete from ld_customreportsql_filter where id=?";
        $this->adb->pquery($delete_sql,array($filterid));
        ConvertTojsonString(1,[],'success');
    }

    //更新变量
    public function updateVisibile(){
        $columnid = $this->params['columnid'];
        $visibile = $this->params['visibile'];
        $update_sql = "update ld_customtable_columns set visibile=? where id=?";
        $this->adb->pquery($update_sql,array($visibile,$columnid));
        ConvertTojsonString(1,[],'yes');
    }
    //保存统计表配置信息
    public function saveReportInfo(){
        global $current_user;
        $ChartSetInfo = json_decode($this->params['ChartSetInfo'],true);
        if(empty($ChartSetInfo))
            die('空数据' ) ;
        $this->params['diony'] = 'diony';


        $report_id = $ChartSetInfo['report_id'];
        $report_name = $ChartSetInfo['report_name'];
        $report_type = isset($this->params['report_type']) ? $this->params['report_type'] : 'sqlchart';
        $report_name = empty($report_name) ? $ChartSetInfo['chart_type'] : $report_name;//报表名称默认值
        $linkmodulecheck = $ChartSetInfo['linkmodulecheck'] ? 'yes' : 'no';//是否设置为链接模块
        //是否显示在首页 勾选
        $show_athome = (isset($ChartSetInfo['show_athome']) && $ChartSetInfo['show_athome']) ? 'yes' : 'no';//显示在首页
        $can_penetrate = 'no';//允许穿透
        //保存数据 主表ld_customtable 基本信息
        $this->adb->startTransaction();//开启事务
        if(empty($report_id)){
            //新增ld_customreport
            $sql = "insert into ld_customreport (report_name,report_desc,report_type,deleted,createdtime,smcreatorid,show_athome,linkmodulecheck,can_penetrate,analysisfolder_id,themename,sequence,isshow_table) values (?,?,?,?,?,?,?,?,?,?,?,?,?)";
            $this->adb->pquery($sql,[$report_name,$ChartSetInfo['report_desc'],$ChartSetInfo['report_type'],0,date('Y-m-d H:i:s',time()),$current_user->id,$show_athome,$linkmodulecheck,$can_penetrate,$ChartSetInfo['analysisfolder_id'],$ChartSetInfo['ThemeSet'],0,$ChartSetInfo['ReportStyle']]);
            $ChartSetInfo['report_id'] = $report_id = $this->adb->getLastInsertID();
        }
        else{
            //编辑ld_customtable
            $sql = "update ld_customreport set report_name=?,report_desc=?, linkmodulecheck=?,modify_time=?,modify_id=?,report_type=?,analysisfolder_id=?,themename=?,show_athome=?,isshow_table=? where report_id=?";
            $this->adb->pquery($sql,[$report_name,$ChartSetInfo['report_desc'],$linkmodulecheck,date('Y-m-d H:i:s',
                time()),$current_user->id,$report_type,$ChartSetInfo['analysisfolder_id'],$ChartSetInfo['ThemeSet'],
                $show_athome,$ChartSetInfo['ReportStyle'],$report_id]);
        }

        //默认给所有用户权限
        $permit_sql='insert into ld_report_analysis2user(report_id,modulename,userid)values(?,?,?)';
        $this->adb->pquery($permit_sql,array($report_id,'CustomEcharts','-1'));

        //chertset 图表样式信息的信息保存 Y轴保存
        $this->CustomEchartsActionsObj->ChartSetInfo = $ChartSetInfo;
        $this->CustomEchartsActionsObj->setChartSet();
        //统计维度的信息保存
        $XAxisFieldList = $ChartSetInfo['AxisFields']['XAxis'];
        if(count($XAxisFieldList) > 0 ){
            $group_deleted = "delete from ld_customreport_group where report_id=?";
            $this->adb->pquery($group_deleted,[$report_id]);
        }
        foreach ($XAxisFieldList as $index => $XAxisFieldInfo){
            $columns = $XAxisFieldInfo['id'];
            $group_insert = "insert into ld_customreport_group (report_id,groupbytype,columns,`sequence`) values (?,?,?,0)";
            $this->adb->pquery($group_insert,[$report_id,'bysql',$columns]);
        }

        //columns 统计字段信息的保存
        $group_deleted2 = "delete from ld_customreport_total_column where report_id=?";
        $this->adb->pquery($group_deleted2, array($report_id));
        $YAxisFieldList = $ChartSetInfo['AxisFields']['YAxis'];

        foreach ($YAxisFieldList as $index => $YAxisFieldInfo){
            $columns = $YAxisFieldInfo['id'];
            $chart_column_type = $YAxisFieldInfo['SeriesType'];
            if (empty($chart_column_type)) {
                //数据列类型为空 给默认值
                $chart_column_type = $this->CustomEchartsActionsObj->getSeriesType($ChartSetInfo['chart_type']);
            }
            $color = '';
            $chart_column_name = $YAxisFieldInfo['DisplayName'];
            $yaxisindex = $YAxisFieldInfo['YAxisIndex'];
            $column_insert = "insert into ld_customreport_total_column (total_type,columns,sequence,report_id,chart_column_type,color,chart_column_name,
                yaxisindex,column_module) values (?,?,?,?,?,?,?,?,?)";
            $column_params = array('',$columns,$index,$report_id,$chart_column_type,$color,
                $chart_column_name,$yaxisindex,'');
            $this->adb->pquery($column_insert,$column_params);
            //$chart_series[] = ['type'=>$chart_column_type];
        }

        /*if(!empty($YAxisFieldList)){
            $chart_series = json_encode($chart_series,JSON_UNESCAPED_UNICODE);
            $chart_update = "update ld_customreport_chartset set series=? where report_id=?";
            $this->adb->pquery($chart_update,[$chart_series,$report_id]);
        }*/


        //勾选创建链接模块
        $this->CustomEchartsActionsObj->createLinkModule($report_name,$report_id,$linkmodulecheck);
        $res['request'] = $ChartSetInfo;
        $chart_info = $this->CustomEchartsActionsObj->getSqlDetailData($ChartSetInfo['report_id']);
        $chart_info['report_id'] = $ChartSetInfo['report_id'];
        $chart_info['themename'] = $ChartSetInfo['themename'];
        $res['ChartSetInfo'] = $chart_info['ChartSetInfo'];
        $res['chart_info'] = $chart_info;

        //条件 改变了条件需要及时更新页面
        $filterArr = $this->CustomEchartsActionsObj->setSqlFilterValue($chart_info['sqlFilterArr']);
        $filterArr = array_chunk($filterArr,2);
        $this->smarty->assign('sqlFilterArr',$filterArr);//sql解析出来的字段信息
        $conditionContent = $this->smarty->fetch('CustomEcharts/sqlConditions.tpl');
        $res['conditionContent'] = $conditionContent;
        //增加最新浏览记录
        $sql="select browse_id from ld_report_analysis_folder_log where reportid=? and module=? and userid=?";
        $result=$this->adb->pquery($sql,[$report_id,'CustomEcharts',$current_user->id]);
        $nums=$this->adb->num_rows($result);
        $browse_id=$this->adb->query_result($result,0,'browse_id');
        if($nums==0){
            $sql="insert into ld_report_analysis_folder_log(reportid,module,userid,view_time) value (?,?,?,?)";
            $this->adb->pquery($sql,array($report_id,'CustomEcharts',$current_user->id,date("Y-m-d H:i:s")));
        }else{
            $sql="update ld_report_analysis_folder_log set view_time=?,visible='yes' where browse_id=?";
            $this->adb->pquery($sql,array(date("Y-m-d H:i:s"),$browse_id));
        }
        if(empty($ChartSetInfo['report_name'])){
            $update_sql = 'update ld_customreport set deleted=1 where report_id=?';
        }else{
            $update_sql = 'update ld_customreport set deleted=0 where report_id=?';
        }
        $this->adb->pquery($update_sql,array($report_id));

        $saveType = $this->params['saveType'];
        if($saveType === 'Preview') {
            //$this->deleteReportById($ChartSetInfo['report_id']);
        }

        $this->adb->completeTransaction();//结束事务
        //图表信息
        ConvertTojsonString(1,$res,'success');
    }

}
?>