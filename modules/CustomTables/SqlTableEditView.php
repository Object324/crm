<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$function = $_REQUEST['function_name'];
$function = empty($function)?'index':$function;
$_REQUEST['diony'] = 'yes';
$obj = new SqlTableEditView();
$is_ajax = $_REQUEST['is_ajax'];
$obj->$function($is_ajax);

class SqlTableEditView
{
    public $CustomTablesActionsObj;
    public $echartModuleObj;
    public $limit = 200;
    public function __construct(){
        include globalStatic::$root_directory.'modules/CustomTables/CustomTablesActions.php';
        $this->CustomTablesActionsObj = new CustomTablesActions();
    }
    public function index(){
        $report_id = $_REQUEST['report_id'];
        $parent_id = $_REQUEST['parent_id'];
        $mode = "create";

        $analysisfolder_id = 0;
        if($report_id>0){
            $mode = "edit";
            //模块信息--不需要，第一个tab不显示
            //报表信息
            $reportInfo = $this->CustomTablesActionsObj->getReportInfo($report_id);
            $analysisfolder_id = $reportInfo['analysisfolder_id'];
            $this->CustomTablesActionsObj->smarty->assign("report_info",$reportInfo);
        }
        if($_REQUEST['limitrecord'])
        {
            $this->CustomTablesActionsObj->smarty->assign("LimitRecord",$_REQUEST['limitrecord']);
        }else{
            $this->CustomTablesActionsObj->smarty->assign("LimitRecord",$this->limit);

        }
        //获取文件夹树状结构的options zxm 20221109  报表分析模块新建报表库报表
        require_once globalStatic::$root_directory.'modules/ReportAnalysis/ReportAnalysisActions.php';
        $ReportAnalysisActionsObj = new ReportAnalysisActions();
        $folderOptions = $ReportAnalysisActionsObj->getAllFolderOptions($analysisfolder_id);
        $this->CustomTablesActionsObj->smarty->assign('frommodule',$_REQUEST['frommodule']);
        $this->CustomTablesActionsObj->smarty->assign('folderOptions',$folderOptions);//zxm 20221109  报表分析模块新建报表库报表
        $this->CustomTablesActionsObj->smarty->assign('mode',$mode);
        $content = $this->CustomTablesActionsObj->smarty->fetch('CustomTables/editviewsql.tpl');
        $_REQUEST['diony']='diony';
        $res['content'] = $content;
        $res['permit_print'] = isPermitted('ReportAnalysis','Print');
        $res['permit_export'] = isPermitted('ReportAnalysis','Export');
        $res['permit_create'] = isPermitted('ReportAnalysis','Create');
        $res['title'] = $report_id>0?getFixedLabel('EDIT').getFixedLabel('STATISTICALE'):
            getFixedLabel('CREATE')."SQL".getFixedLabel('Table');
        ConvertTojsonString(1,$res,'success');die;
    }
    //保存统计表配置信息
    public function saveReportInfo(){
        global $current_user;
        $params = $_REQUEST;
        $_REQUEST['diony']='diony';
        //确认按钮的保存数据   没有选择字段给提示
        if((!isset($params['columns'])||empty($params['columns']))&&$params['isfinish']!="no"&&$params['report_type']=='selectfield'){
            ConvertTojsonString(0,[],getFixedLabel('PLEASESELECTLEASTONEFIELD'));
        }
        $report_id = $params['report_id'];
        $report_name = $params['report_name'];
        $linkmodulecheck = $params['linkmodulecheck'];//是否设置为链接模块
        $show_athome = $params['show_athome'];//是否放看板显示
        //获取level
        $level_sql = "select `level` from ld_customtable where report_id=? ";
        $level_res = $this->CustomTablesActionsObj->adb->pquery($level_sql,array($params['parent_id']));
        $level = $this->CustomTablesActionsObj->adb->query_result($level_res,0,0);
        $level = !empty($level)?floatval($level):0;
        $level = $level+1;
        //保存数据
        //主表ld_customtable
        //基本信息
        if(empty($report_id)){
            //新增ld_customtable
            $sql = "insert into ld_customtable (report_name,description,parent_id,deleted,createdtime,smcreatorid,linkmodulecheck,show_athome,total_position,show_subtotal,show_detail,`level`,report_type,analysisfolder_id) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
            $this->CustomTablesActionsObj->adb->pquery($sql,[$report_name,$params['description'],$params['parent_id'],0,date('Y-m-d H:i:s',time()),$current_user->id,$linkmodulecheck,$show_athome,$params['total_position'],$params['show_subtotal'],'yes',$level,'sql',$params['analysisfolder_id']]);
            $_REQUEST['report_id'] = $report_id = $this->CustomTablesActionsObj->adb->getLastInsertID();
            
            //权限表ld_customtable2user默认给所有用户权限--只有新建需要
            $permit_sql='insert into ld_customtable2user(report_id,userid)values(?,?)';
            $this->CustomTablesActionsObj->adb->pquery($permit_sql,array($report_id,'-1'));
        }else{
            //编辑ld_customtable
            $sql = "update ld_customtable set report_name=?,description=?, linkmodulecheck=?,show_athome=?,parent_id=?,modify_time=?,modify_id=?,`level`=?,report_type=?,analysisfolder_id=? where report_id=?";
            $this->CustomTablesActionsObj->adb->pquery($sql,[$report_name,$params['description'],$linkmodulecheck,$show_athome,$params['parent_id'],date('Y-m-d H:i:s',time()),$current_user->id,$level,'sql',$params['analysisfolder_id'],$report_id]);
        }
        $report_info['report_id'] = $report_id;
        //对齐方式  合并 属性更新
        $columns = $params['columns'];
        $is_merge = $params['is_merge'];

        $align = $params['align'];
        $issticky = $params['issticky'];
        //新增表头样式 表体样式 20220914zxm
        $styleset_header = $params['styleset_header'];
        $styleset_body = $params['styleset_body'];
        foreach($columns as $key=>$columnnameline){
            $is_merge[$key] = empty($is_merge[$key])?'noselect':$is_merge[$key];//zxm @date:2024/11/13 @reason: is_merge no不合并 noselect用户未选合并  其他值合并标签字段
            $updatesql_sql ="update ld_customtable_columns set is_merge=?,align=?,sequence=?,issticky=?,styleset_header=?,styleset_body=? where `columns`=? and report_id=?";
            $this->CustomTablesActionsObj->adb->pquery($updatesql_sql,array($is_merge[$key],$align[$key],($key+1),$issticky[$key],$styleset_header[$key],$styleset_body[$key],$columnnameline,$report_id));
        }
        //链接模块
        $this->CustomTablesActionsObj->createLinkModule($report_name,$report_id,$linkmodulecheck,'sql');
        //增加最新浏览记录
        $logsql="select browse_id from ld_report_analysis_folder_log where reportid=? and module=? and userid=?";
        $result=$this->CustomTablesActionsObj->adb->pquery($logsql,[$report_id,'CustomTables',$current_user->id]);
        $nums=$this->CustomTablesActionsObj->adb->num_rows($result);
        $browse_id=$this->CustomTablesActionsObj->adb->query_result($result,0,'browse_id');
        if($nums==0){
            $logsql="insert into ld_report_analysis_folder_log(reportid,module,userid,view_time) value (?,?,?,?)";
            $this->CustomTablesActionsObj->adb->pquery($logsql,array($report_id,'CustomTables',$current_user->id,date("Y-m-d H:i:s")));
        }else{
            $logsql="update ld_report_analysis_folder_log set view_time=?,visible='yes' where browse_id=?";
            $this->CustomTablesActionsObj->adb->pquery($logsql,array(date("Y-m-d H:i:s"),$browse_id));
        }
        ConvertTojsonString(1,['report_info'=>$report_info],'success');
    }
    //保存表头宽度--sql报表和模块报表都有
    public function saveResizeData(){
        $this->CustomTablesActionsObj->saveResizeData();
    }
    //更改报表状态
    public function changeReportStatus(){
        $this->CustomTablesActionsObj->changeReportStatus();
    }
    //2022-0805 执行SQL语句 XUQIU1000530	统计表 自定义统计表-支持SQL语句
    public function parserSql(){
        //$sqlstr = base64_decode($_REQUEST['sqlstr']);
        //zxm 丁程宣的edge浏览器会阻断sql传输  base64加密去掉
        $cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
        $sqlstr =$cls_AESencryptionbykeyobj->getdecryption($_REQUEST['sqlstr']);

        $report_id = $_REQUEST['report_id'];
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
                $insert_sql = "insert into ld_customtable_columns (report_id,tdheader_label,columns,align,sequence,is_merge,fieldtype,linkurl) select $report_id,'$alias','$alias','left',($k+1),'noselect','string','no' from dual
where not exists(select 1 from ld_customtable_columns where columns='$alias' and report_id=?)";
                $this->CustomTablesActionsObj->adb->pquery($insert_sql,array($report_id));
                //已有的字段更新排序
                $updatesql = "update ld_customtable_columns set sequence=? where columns=? and report_id=?";
                $this->CustomTablesActionsObj->adb->pquery($updatesql,array($k+1,$alias,$report_id));
            }
        }
        //存储过程语句
        if($is_procedure=='yes'){
            $pro_res = $this->CustomTablesActionsObj->adb->pquery($sqlstr);
            $columnnames = $this->CustomTablesActionsObj->adb->getFieldsArray($pro_res);
           // $a = $this->CustomTablesActionsObj->adb->query_result_all($pro_res);
            require_once globalStatic::$root_directory.'include/database/PearDatabase.php';
            global $adb;
            $adb = null;
            $adb = PearDatabase::getInstance();
            $this->CustomTablesActionsObj->adb = $adb;
            foreach($columnnames as $k=>$column2){
                //判断该字段在columns表中是否存在 不存在则新增
                $insert2_sql = "insert into ld_customtable_columns (report_id,tdheader_label,columns,align,sequence,is_merge,fieldtype,linkurl) select $report_id,'$column2','$column2','left',($k+1),'noselect','string','no' from dual
where not exists(select 1 from ld_customtable_columns where columns='$column2' and report_id=?);";
                $this->CustomTablesActionsObj->adb->pquery($insert2_sql,array($report_id));

                //已有的字段更新排序
                $updatesql = "update ld_customtable_columns set sequence=? where columns=? and report_id=?";
                $this->CustomTablesActionsObj->adb->pquery($updatesql,array($k+1,$column2,$report_id));
            }
        }
        //将sql和report_name 保存
        $update_sql = "update ld_customtable set report_name=?,sqlstr=? where report_id=?";
        $this->CustomTablesActionsObj->adb->pquery($update_sql,array($_REQUEST['report_name'],$sqlstr,$report_id));
        //将不存在的字段删除
        $deleted_sql = "delete from ld_customtable_columns where report_id=? and `columns` NOT IN ("."'".implode("','",$columnnames)."'".")";
        $this->CustomTablesActionsObj->adb->pquery($deleted_sql,array($report_id));
        //查询字段
        $columnsarr = $this->CustomTablesActionsObj->getCustomtableColumns($report_id);
        $_REQUEST['diony'] = 'yes';
        ConvertTojsonString(1,[
//            'columnsarr'=>array_chunk($columnsarr,3)
            'columnsarr'=>$columnsarr
        ],'SQL yes');die;

    }
    //2022-0805 执行SQL语句 XUQIU1000530	统计表 自定义统计表-支持SQL语句   字段设置页面
    public function editSqlColumns(){
        $columnid = $_REQUEST['columnid'];
        $report_id = $_REQUEST['report_id'];
        $column_sql = "select * from ld_customtable_columns where id=?";
        $column_res = $this->CustomTablesActionsObj->adb->pquery($column_sql,array($columnid));
        $columnInfo = $this->CustomTablesActionsObj->adb->query_result_rowdata($column_res);
        //字段列表
        $columnsArr = $this->CustomTablesActionsObj->getCustomtableColumns($report_id);
        //判断 超链接设置
        $linkurl = $columnInfo['linkurl'];
        if($linkurl=='no'||empty($linkurl)){
            $columnInfo['isset_linkurl'] = 'no';
        }else{
            $columnInfo['isset_linkurl'] = 'yes';//设为链接模块
            $linkurl = Zend_Json::decode($linkurl);
            $columnInfo['linkurl'] = $linkurl;
        }
        $this->CustomTablesActionsObj->smarty->assign("columnInfo",$columnInfo);
        $this->CustomTablesActionsObj->smarty->assign("columnsArr",$columnsArr);
        $content = $this->CustomTablesActionsObj->smarty->fetch('CustomTables/editSqlColumns.tpl');
        $_REQUEST['diony']='diony';
        $res['content'] = $content;
        $res['title'] = getFixedLabel('ACTIVITYFIELDSETTINGS');
        ConvertTojsonString(1,$res,'success');
    }
    //2022-0805 执行SQL语句 XUQIU1000530	统计表 自定义统计表-支持SQL语句   字段设置保存
    public function saveSqlColumns(){
        //只会有编辑 不会有新增
        $isset_linkurl = $_REQUEST['isset_linkurl'];
        //{‘type’:’’,’modulefield’:’’,’recordfield’:’’,’url’:’’}
        $linkurl_arr = [];
        if($isset_linkurl=="yes"){
            $linkurl_arr['type'] = $_REQUEST['linktype'];//穿透类型
            $linkurl_arr['modulefield'] = '';//穿透到列表时 模块
            $linkurl_arr['recordfield'] = $_REQUEST['primarykey_field'];//穿透到详情的主键字段名
            $linkurl_arr['url'] = '';//外部链接穿透 地址
            $linkurl_str = Zend_Json::encode($linkurl_arr);
        }else{
            $linkurl_str = 'no';
        }

        $update_sql = "update ld_customtable_columns set tdheader_label=?,fieldtype=?,linkurl=? where id=? ";
        $this->CustomTablesActionsObj->adb->pquery($update_sql,array($_REQUEST['tdheader_label'],$_REQUEST['fieldtype'],$linkurl_str,$_REQUEST['columnid']));
        ConvertTojsonString(1,['tdheader_label'=>$_REQUEST['tdheader_label']],'success');
    }
    //变量编辑或新增页面
    public function editVariable(){
        $filterid = $_REQUEST['filterid'];
        $report_id = $_REQUEST['report_id'];
        $filter_sql = "select * from ld_customtablesql_filter where id=?";
        $filter_res = $this->CustomTablesActionsObj->adb->pquery($filter_sql,array($filterid));
        $filterInfo = $this->CustomTablesActionsObj->adb->query_result_rowdata($filter_res)??[];
        $filterInfo['report_id'] = $report_id;

        //模块信息--所有模块
        $module_arr = $this->CustomTablesActionsObj->getModuleArr();
        //这里需要返回销售目标  zxm BUG0073264 kfbcrm-报表分析-新建模块报表-变量设置-目标范围选不到 销售目标
        $salesgoalline = [
            'presence'=>'-1',
            'customized'=>'0',
            'name'=>getTranstab('SalesGoal'),
            'modulename'=>'SalesGoal',
            'description'=>''
        ];
        array_push($module_arr,$salesgoalline);

        $this->CustomTablesActionsObj->smarty->assign("module_arr",$module_arr);
        //字段信息
        $picklists = [];
        if($filterid>0&&!empty($filterInfo['modulename'])){
            $picklists = $this->CustomTablesActionsObj->getPickListsByModule($filterInfo['modulename']);
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
        $this->CustomTablesActionsObj->smarty->assign("ApproveList",$approve_list);
        $this->CustomTablesActionsObj->smarty->assign("filterInfo",$filterInfo);
        $this->CustomTablesActionsObj->smarty->assign("picklists",$picklists);
        $this->CustomTablesActionsObj->smarty->assign("show_department",'yes');//自定义SQL统计图 不显示部门和当前用户的变量类型
        $content = $this->CustomTablesActionsObj->smarty->fetch('CustomTables/editVariable.tpl');
        $_REQUEST['diony']='diony';
        $res['content'] = $content;
        $res['title'] = getFixedLabel('VAR').getFixedLabel('SETTINGS');
        ConvertTojsonString(1,$res,'success');
    }
    //变量保存
    public function saveVariable(){
        $filterid = $_REQUEST['filterid'];
        $report_id = $_REQUEST['report_id'];
        $var_type = $_REQUEST['var_type'];
        //变量名不能重复
        $var_name = $_REQUEST['var_name'];
        $select_sql = "select 1 from ld_customtablesql_filter where report_id=? and var_name=?";
        if($filterid>0){
            $select_sql .= " and id<>".$filterid;
        }
        $select_res = $this->CustomTablesActionsObj->adb->pquery($select_sql,array($report_id,$var_name));
        $select_nums = $this->CustomTablesActionsObj->adb->num_rows($select_res);
        if($select_nums>0){
            ConvertTojsonString(-1,[],'变量名不允许重复！');exit;
        }
        //var_name=accountname&display_name=%E5%AE%A2%E6%88%B7%E5%90%8D%E7%A7%B0&var_type=string
        if($filterid>0){
            //编辑
            $update_sql = "update ld_customtablesql_filter set var_name=?,display_name=?,var_type=? where id=?";
            $this->CustomTablesActionsObj->adb->pquery($update_sql,array($var_name,$_REQUEST['display_name'],$var_type,$filterid));
        }else{
            //最大排序值
            $sequence_sql = "select ifnull(max(sequence),0) as sequence from ld_customtablesql_filter where report_id=?";
            $sequence_res = $this->CustomTablesActionsObj->adb->pquery($sequence_sql,array($report_id));
            $sequence = $this->CustomTablesActionsObj->adb->query_result($sequence_res,0,0);

            //新增
            $insert_sql = "insert into ld_customtablesql_filter (var_name,display_name,var_type,report_id,sequence) values(?,?,?,?,?)";
            $insert_res = $this->CustomTablesActionsObj->adb->pquery($insert_sql,array($var_name,$_REQUEST['display_name'],$var_type,$report_id,$sequence+1));
            $filterid = $this->CustomTablesActionsObj->adb->getLastInsertID($insert_res);
        }
        //模糊查找 下拉框 多选框 多选用户 单选用户 日期 日期时间 数字
        //日期 日期时间  存储默认值
        if($var_type=='date'||$var_type=='datetime'){
            $default_value_selectdate = $_REQUEST['default_value_selectdate'];
            $datevalue = $_REQUEST['datevalue'];
            $datetimevalue = $_REQUEST['datetimevalue'];
            if($default_value_selectdate!='selfdefined'){
                $datetimevalue = $this->CustomTablesActionsObj->getFilterDefaultValue($default_value_selectdate);
                $datevalue = substr($datetimevalue,0,10);
            }

            //将值存到 字段中去
            if($var_type=='date'){
                $default_value_selectdate = $default_value_selectdate.','.$datevalue;
            }
            if($var_type=='datetime'){
                $default_value_selectdate = $default_value_selectdate.','.$datetimevalue;
            }

            $update1_sql = "update ld_customtablesql_filter set default_value=? where id=?";
            $this->CustomTablesActionsObj->adb->pquery($update1_sql,array($default_value_selectdate,$filterid));
        }
        else if($var_type=='number'){
            $default_value = $_REQUEST['default_value'];
            $update1_sql = "update ld_customtablesql_filter set default_value=? where id=?";
            $this->CustomTablesActionsObj->adb->pquery($update1_sql,array($default_value,$filterid));
        }
        else if($var_type=='select'){
            //存储下拉框值 默认值等信息
            $select_source = $_REQUEST['select_source'];
            //来源下拉框字段
            if($select_source=='picklist'){
                $update2_sql = "update ld_customtablesql_filter set select_source=?,modulename=?,fieldname=?,selectvalues=?,default_value=? where id=?";
                $this->CustomTablesActionsObj->adb->pquery($update2_sql,array($select_source,$_REQUEST['modulename'],$_REQUEST['fieldname'],$_REQUEST['selectvalues'],$_REQUEST['default_value_select'],$filterid));
            }else{
                $update2_sql = "update ld_customtablesql_filter set select_source=?,selectvalues=?,default_value=? where id=?";
                $this->CustomTablesActionsObj->adb->pquery($update2_sql,array($select_source,$_REQUEST['selectvalues'],$_REQUEST['default_value_select'],$filterid));
            }

        }else if($var_type=='multiselect'){
            //存储下拉框值 默认值等信息
            $select_source = $_REQUEST['select_source'];
            $default_multivalue_select = $_REQUEST['default_multivalue_select'];
            $default_multivalue_select = implode(',',$default_multivalue_select);
            //来源下拉框字段
            if($select_source=='picklist'){
                $update2_sql = "update ld_customtablesql_filter set select_source=?,modulename=?,fieldname=?,selectvalues=?,default_value=? where id=?";
                $this->CustomTablesActionsObj->adb->pquery($update2_sql,array($select_source,$_REQUEST['modulename'],$_REQUEST['fieldname'],$_REQUEST['selectvalues'],$default_multivalue_select,$filterid));
            }else{
                $update2_sql = "update ld_customtablesql_filter set select_source=?,selectvalues=?,default_value=? where id=?";
                $this->CustomTablesActionsObj->adb->pquery($update2_sql,array($select_source,$_REQUEST['selectvalues'],$default_multivalue_select,$filterid));
            }
        }else if($var_type=='multiuser'){
            $modulename = $_REQUEST['modulename'];
            //默认值
            $scopeobj = new ScopOfAuthority($this->CustomTablesActionsObj->adb,$modulename);
            $userids = $scopeobj->getCurUserScopeIds();
            $update3_sql = "update ld_customtablesql_filter set modulename=?,default_value=? where id=?";
            $this->CustomTablesActionsObj->adb->pquery($update3_sql,array($modulename,$userids,$filterid));
        }else if($var_type=='approvestatus'){
            //审批状态组件的默认值
            $default_value_approvestatus_value = $_REQUEST['default_value_approvestatus_value'];
            if(!empty($default_value_approvestatus_value)){
                $default_value_approvestatus_value_str = implode(',',$default_value_approvestatus_value);
                $update4_sql = "update ld_customtablesql_filter set default_value=? where id=?";
                $this->CustomTablesActionsObj->adb->pquery($update4_sql,array($default_value_approvestatus_value_str,$filterid));
            }
        }else if($var_type=='checkbox'){
            //审批状态组件的默认值
            $default_value_checkbox_value = $_REQUEST['default_value_checkbox'];
            $update5_sql = "update ld_customtablesql_filter set default_value=? where id=?";
            $this->CustomTablesActionsObj->adb->pquery($update5_sql,array($default_value_checkbox_value,$filterid));
        }else if($var_type=='department'){
            // 部门组件 zxm --todo --
            // 默认值保存 1.展示全部组织架构信息：勾选/不勾选  默认值存到字段default_value中勾选是all,否则是模块数据范围下的部门id,逗号隔开  模块名称存到modulename中
            $department_allselect_checkbox = $_REQUEST['department_allselect_checkbox'];
            if($department_allselect_checkbox=='on'){
                //展示全部组织架构信息  勾选
                $update6_sql = "update ld_customtablesql_filter set default_value=?,modulename=? where id=?";
                $this->CustomTablesActionsObj->adb->pquery($update6_sql,array($department_allselect_checkbox,'',$filterid));
            }else{
                //展示全部组织架构信息  不勾选  if数据范围如果是按部门来，直接读部门数据，else 先获取数据范围内的userid,
                $modulename = $_REQUEST['modulename'];
                $update7_sql = "update ld_customtablesql_filter set default_value=?,modulename=? where id=?";
                $this->CustomTablesActionsObj->adb->pquery($update7_sql,array($department_allselect_checkbox,$modulename,$filterid));
            }
        }else if($var_type=='curroperator'){
            // 当前操作员组件 zxm
            // 无默认值保存
        }
        $sqlFilterArr = $this->CustomTablesActionsObj->getSqlFilter($report_id);
        ConvertTojsonString(1,['sqlFilterArr'=>$sqlFilterArr],'success！');
    }
    public function getDefaultDateValue(){
        $default_value_selectdate = $_REQUEST['default_value_selectdate'];
        $value = $this->CustomTablesActionsObj->getFilterDefaultValue($default_value_selectdate);
        $value_date = substr($value,0,10);
        ConvertTojsonString(1,['value_date'=>$value_date,'value'=>$value],'success！');
    }
    public function getPickListsByModule(){
        $modulename = $_REQUEST['modulename'];
        $picklists = $this->CustomTablesActionsObj->getPickListsByModule($modulename);
        ConvertTojsonString(1,['picklists'=>$picklists],'success');
    }
    public function resetSqlVarSequence(){
        $filterid_str = $_REQUEST['filterid_str'];
        $sequence_str = $_REQUEST['sequence_str'];
        $filterid_arr = explode(',',$filterid_str);
        foreach($filterid_arr as $index=>$filterid){
            $update_sql = "update ld_customtablesql_filter set sequence=? where id=?";
            $this->CustomTablesActionsObj->adb->pquery($update_sql,array($index+1,$filterid));
        }
        ConvertTojsonString(1,[],'success');
    }
    //删除变量
    public function variableDelete(){
        $filterid = $_REQUEST['filterid'];
        $delete_sql = "delete from ld_customtablesql_filter where id=?";
        $this->CustomTablesActionsObj->adb->pquery($delete_sql,array($filterid));
        ConvertTojsonString(1,[],'success');
    }

    //更新变量
    public function updateVisibile(){
        $columnid = $_REQUEST['columnid'];
        $visibile = $_REQUEST['visibile'];
        $update_sql = "update ld_customtable_columns set visibile=? where id=?";
        $this->CustomTablesActionsObj->adb->pquery($update_sql,array($visibile,$columnid));
        ConvertTojsonString(1,[],'yes');
    }
}