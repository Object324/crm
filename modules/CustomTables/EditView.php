<?php
$function = $_REQUEST['function_name'];
$function = empty($function)?'index':$function;
$_REQUEST['diony'] = 'yes';
$obj = new CustomTablesEditView();
$obj->$function();

class CustomTablesEditView
{
    public $CustomTablesActionsObj;
    public $limit = 200;
    public $aliasArr = [
        'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
        'aa','ba','ca','da','ea','fa','ga','ha','ia','ja','ka','la','ma','na','oa','pa','qa','ra','sa','ta','ua','va','wa','xa','ya','za',
        'ab','bb','cb','db','eb','fb','gb','hb','ib','jb','kb','lb','mb','nb','ob','pb','qb','rb','sb','tb','ub','vb','wb','xb','yb','zb'
    ];//少的话可以再加
    public function __construct(){
        include globalStatic::$root_directory.'modules/CustomTables/CustomTablesActions.php';
        $this->CustomTablesActionsObj = new CustomTablesActions();
    }
    //编辑界面 display template 弹窗
    public function index(){
        $report_id = $_REQUEST['report_id'];
        $this->CustomTablesActionsObj->smarty->assign("report_id",$report_id);
        $timeValueArr = $this->CustomTablesActionsObj->getComparatorValue();
        $this->CustomTablesActionsObj->smarty->assign('timeValueArr',json_encode($timeValueArr,JSON_UNESCAPED_UNICODE));
        $mode = "create";
        $analysisfolder_id = 0;
        if($report_id>0){
            $mode = "edit";
            //模块信息--不需要，第一个tab不显示
            //报表信息
            $reportInfo = $this->CustomTablesActionsObj->getReportInfo($report_id);
            $res['columnsCount'] = $reportInfo['columnsCount'];
            $analysisfolder_id = $reportInfo['analysisfolder_id'];
            //模块信息
            $modules = $this->CustomTablesActionsObj->getReportModules($report_id);
            $reportInfo['selectedModules'] = implode(',',$modules);
            $this->CustomTablesActionsObj->smarty->assign("report_info",$reportInfo);
            $this->CustomTablesActionsObj->smarty->assign("report_type",$reportInfo['report_type']);
        }else{
            $this->CustomTablesActionsObj->smarty->assign("report_type",$_REQUEST['report_type']);//前端传过来的报表类型
        }
        $this->CustomTablesActionsObj->smarty->assign('mode',$mode);
        //获取文件夹树状结构的options zxm 20221109  报表分析模块新建报表库报表
        require_once globalStatic::$root_directory.'modules/ReportAnalysis/ReportAnalysisActions.php';
        $ReportAnalysisActionsObj = new ReportAnalysisActions();
        $folderOptions = $ReportAnalysisActionsObj->getAllFolderOptions($analysisfolder_id);
        $this->CustomTablesActionsObj->smarty->assign('frommodule',$_REQUEST['frommodule']);
        $this->CustomTablesActionsObj->smarty->assign('folderOptions',$folderOptions);//zxm 20221109  报表分析模块新建报表库报表

        //模板数组
        $this->CustomTablesActionsObj->smarty->assign('templateTypeArr',$this->CustomTablesActionsObj->getTemplate());

        $content = $this->CustomTablesActionsObj->smarty->fetch('CustomTables/editview.tpl');
        $_REQUEST['diony']='diony';
        $res['content'] = $content;
        //zxm 20231113 编辑报表 编辑+报表名称
        $res['title'] = $report_id>0?getFixedLabel('EDIT').$reportInfo['report_name']:
            getFixedLabel('CREATE').getFixedLabel('MODULE').getFixedLabel('Table');
        ConvertTojsonString(1,$res,'success');die;
    }

    //模板选择之后 获取相对应的模板的基本信息
    public function getTemplateInfo(){
        $templateid=$_REQUEST['selecttemplateid'];
        $reportInfo = $this->CustomTablesActionsObj->getReportInfo($templateid);
        $res['columnsCount'] = $reportInfo['columnsCount'];
        //模块信息
        $modules = $this->CustomTablesActionsObj->getReportModules($templateid);
        $reportInfo['selectedModules'] = implode(',',$modules);
        $reportInfo['selectedModulesArr'] = $modules;
        foreach($modules as $m){
            //判断模块是否开启和激活
            if(isPermitted($m,'index')=='yes'&&vtlib_isModuleActive($m)){
                $reportInfo['selectedModulesName_arr'][] = getTranstab($m);
            }else{
                ConvertTojsonString(-1,[],getTranstab($m).'未激活！');die;
            }
        }
        $_REQUEST['diony']='diony';
        $res['reportInfo'] = $reportInfo;
        ConvertTojsonString(1,$res,'success');die;
    }
    //2022-0805 执行SQL语句 XUQIU1000530	统计表 自定义统计表-支持SQL语句   保存字段设置信息
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
        $selecttemplateid = $params['selecttemplateid'];
        //根据模板创建的
        if($selecttemplateid>0&&$report_id==0){
            $report_id = 0;
        }
        $report_name = $params['report_name'];
        $linkmodulecheck = $params['linkmodulecheck'];//是否设置为链接模块
        $show_athome = $params['show_athome'];//是否放看板显示
        //获取level
        $level_sql = "select `level` from ld_customtable where report_id=? ";
        $level_res = $this->CustomTablesActionsObj->adb->pquery($level_sql,array($params['parent_id']));
        $level = $this->CustomTablesActionsObj->adb->query_result($level_res,0,0);
        $level =(int)$level+1;
        //保存数据
        //主表ld_customtable
        //基本信息
        if(empty($report_id)){
            //新增ld_customtable
            $sql = "insert into ld_customtable (report_name,description,parent_id,deleted,createdtime,smcreatorid,linkmodulecheck,show_athome,total_position,show_subtotal,show_detail,`level`,analysisfolder_id) values (?,?,?,?,?,?,?,?,?,?,?,?,?)";
            $this->CustomTablesActionsObj->adb->pquery($sql,[$report_name,$params['description'],$params['parent_id'],0,date('Y-m-d H:i:s',time()),$current_user->id,$linkmodulecheck,$show_athome,$params['total_position'],$params['show_subtotal'],'yes',$level,$params['analysisfolder_id']]);
            $_REQUEST['report_id'] = $report_id = $this->CustomTablesActionsObj->adb->getLastInsertID();
            //权限表ld_customtable2user默认给所有用户权限--只有新建需要
            $permit_sql='insert into ld_customtable2user(report_id,userid)values(?,?)';
            $this->CustomTablesActionsObj->adb->pquery($permit_sql,array($report_id,'-1'));
        }else{
            //编辑ld_customtable
            $sql = "update ld_customtable set report_name=?,description=?, linkmodulecheck=?,show_athome=?,total_position=?,show_subtotal=?,show_detail=?,modify_time=?,modify_id=?,`level`=?,analysisfolder_id=? where report_id=?";
            $this->CustomTablesActionsObj->adb->pquery($sql,[$report_name,$params['description'],$linkmodulecheck,$show_athome,$params['total_position'],$params['show_subtotal'],$params['show_detail'],date('Y-m-d H:i:s',time()),$current_user->id,$level,$params['analysisfolder_id'],$report_id]);
        }
        //模块表数据保存
        $this->saveCustomTableModule($params,$report_id);
        //columns表ld_customtable_columns
        $columns = $params['columns'];
        $columnmodule= $params['columnmodule'];
        $modulelabel = $params['modulelabel'];
        $fieldlabel = $params['fieldlabel'];
        $bigtype = $params['bigtype'];
        $typeofdata = $params['typeofdata'];
        $is_group = $params['is_group'];
        $order_by = $params['order_by'];
        $is_merge = $params['is_merge'];
        $total_type = $params['total_type'];
        $align = $params['align'];

        $alias = $params['alias']??[];
        $alias_flip = array_flip($alias);//别名键值反转
        $tdheader_label = $params['tdheader_label'];
        $tdheader_label_en = $params['tdheader_label_en'];
        $prefix = $params['prefix'];
        $suffix = $params['suffix'];
        $decimal_places = $params['decimal_places'];
        $header_width = $params['header_width'];
        $issticky = $params['issticky'];
        //新增表头样式 表体样式 20220914zxm
        $styleset_header = $params['styleset_header'];
        $styleset_body = $params['styleset_body'];
        $column_values = '';

        //把别号数组中已用的字母剔除
        $this->aliasArr = array_merge(array_diff($this->aliasArr, $alias));
        $this->aliasArr = array_values($this->aliasArr);
        $regex = "/\{(.+?)\}/"; // {} 花括号，大括号 正则
        $i=0;
        $columns_deleted = "delete from ld_customtable_columns where report_id=?";
        $this->CustomTablesActionsObj->adb->pquery($columns_deleted,[$report_id]);
        $userid = $this->CustomTablesActionsObj->current_user->id;
        $columns_deleted = "delete from ld_list_headerwidth where relateid=? and `module`=? and userid=?";
        $this->CustomTablesActionsObj->adb->pquery($columns_deleted,[$report_id,"CustomTables",$userid]);
        foreach($columns as $k=>$v){
            $temp_tdheader_label = $tdheader_label[$k];
            $temp_tdheader_label = empty($temp_tdheader_label)?$fieldlabel[$k]:$temp_tdheader_label;
            $temp_total_type = $total_type[$k];
            $temp_columnstring = '';
            //编辑
            $temp_alias = $alias[$k];
            if(empty($report_id)||empty($temp_alias)){
                $temp_alias = '';
                //新增
                //if($temp_total_type!='formula'){
                    $temp_alias = $this->aliasArr[$i];
                    $i++;
                //}
            }else{
                $temp_alias = $alias[$k];
            }
            if($temp_total_type=='formula'){
                //公式内变量  变量含义字段columnstring存值{formulavar:[{'lettervar':'a','column':'servicecontracts_start_date'}]}
                preg_match_all($regex, $v, $pat_array);
                $pat_array = $pat_array[1];
                $temp_columnstring_arr = [];
                foreach($pat_array as $pk=>$pat) {
                    if(isset($alias_flip[$pat])){
                        $pat_key = $alias_flip[$pat];
                        $temp_columnstring_arr[$pk]['lettervar']=$pat;
                        $temp_columnstring_columns = $columns[$pat_key];
                        $temp_columnstring_columns_arr = explode(':',$temp_columnstring_columns);
                        unset($temp_columnstring_columns_arr[4]);
                        $temp_columnstring_columns_arr[3] = explode('_',$temp_columnstring_columns_arr[3]);
                        $temp_columnstring_columns_arr[3] =  $temp_columnstring_columns_arr[3][0];
                        $temp_columnstring_columns_str = implode(':',$temp_columnstring_columns_arr);
                        $temp_columnstring_arr[$pk]['column'] = $temp_columnstring_columns_str;
                    }
                }
                $temp_columnstring = "{formulavar:".Zend_Json::encode($temp_columnstring_arr);
            }
            $is_merge[$k] = empty($is_merge[$k])?'noselect':$is_merge[$k];//zxm @date:2024/11/13 @reason: is_merge no不合并 noselect用户未选合并  其他值合并标签字段
            $column_values="($report_id,'$temp_tdheader_label','$columns[$k]','$columnmodule[$k]','$is_group[$k]','$order_by[$k]','$is_merge[$k]','$total_type[$k]','$align[$k]',$k,'$tdheader_label_en[$k]','$temp_alias','$suffix[$k]','$decimal_places[$k]','$temp_columnstring','$prefix[$k]','$issticky[$k]','$styleset_header[$k]','$styleset_body[$k]')";
            $column_insert = "insert into ld_customtable_columns (report_id,tdheader_label,columns,columnmodule,is_group,order_by,is_merge,total_type,align,`sequence`,tdheader_label_en,alias,suffix,decimal_places,columnstring,prefix,issticky,styleset_header,styleset_body) values $column_values";
            $insert_columns_res = $this->CustomTablesActionsObj->adb->pquery($column_insert);
            $columns_id = $this->CustomTablesActionsObj->adb->getLastInsertID($insert_columns_res);
            $widthinsert_sql = "insert into ld_list_headerwidth (header_width,userid,type,module,columns,relateid) values (?,?,?,?,?,?)";
            $this->CustomTablesActionsObj->adb->pquery($widthinsert_sql,array($header_width[$k], $userid, 'CustomTables', 'CustomTables', $columns_id, $report_id));
        }
        //$column_values = rtrim($column_values,',');
        //$column_insert = "insert into ld_customtable_columns (report_id,tdheader_label,columns,columnmodule,is_group,order_by,is_merge,total_type,align,`sequence`,tdheader_label_en,alias,suffix,decimal_places,columnstring,prefix) values $column_values";
        //$this->CustomTablesActionsObj->adb->pquery($column_insert);
        //高级设置 condition表ld_customtable_condition--todo--
        $cvadvfilter = $params['cvadvfilter'];
        $comparator = $params['comparator'];
        $groupid = $params['groupid'];//行条件的groupid-zxm20220629
        $columncondition = $params['columncondition'];//行条件的关系-zxm20220629
        $value1 = $params['value1'];
        $value2 = $params['value2'];
        $group_condition_id = $params['group_condition_id'];//条件组之间的groupid-zxm20220629
        $group_condition = $params['group_condition'];//条件组之间的关系-zxm20220629
        $condition_values = '';
        foreach($cvadvfilter as $key=>$val){
            $temp_value = $value1[$key];
            if(isset($value2[$key])&&!empty($value2[$key])){
                $temp_value .= ','.$value2[$key];
            }
            $condition_values.="($report_id,'$val','$comparator[$key]','$temp_value','$groupid[$key]','$columncondition[$key]'),";//zxm20220629
        }
        $condition_values = rtrim($condition_values,',');
        $condition_deleted = "delete from ld_customtable_condition where report_id=?";
        $this->CustomTablesActionsObj->adb->pquery($condition_deleted,[$report_id]);
        if(!empty($condition_values)){
            $condition_insert = "insert into ld_customtable_condition (report_id,columns,comparator,`value`,groupid,columncondition) values $condition_values";//zxm20220629
            $this->CustomTablesActionsObj->adb->pquery($condition_insert);
        }
        //组关系数据
        $values1 = '';
        foreach($group_condition_id as $k1=>$v1){
            $values1.="($report_id,'$v1','$group_condition[$k1]'),";//zxm20220629
        }
        $values1 = rtrim($values1,',');
        $deleted = "delete from ld_customtable_condition_grouping where report_id=?";
        $this->CustomTablesActionsObj->adb->pquery($deleted,[$report_id]);
        if(!empty($values1)){
            $insert = "insert into ld_customtable_condition_grouping (report_id,groupid,group_condition) values $values1";//zxm20220629
            $this->CustomTablesActionsObj->adb->pquery($insert);
        }
        //链接模块
        $this->CustomTablesActionsObj->createLinkModule($report_name,$report_id,$linkmodulecheck,'selectfield');
        $report_info['report_id'] = $report_id;
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
	//保存模块信息
    public function saveCustomTableModule($params,$report_id){
        $mainmodule = $params['mainmoduleSelected'];
        $nextSelectedArr = Zend_Json::decode($params['nextSelectedArr'],true);
        $prevSelectedArr = Zend_Json::decode($params['prevSelectedArr'],true);

        //删除模块
        $module_delete = "delete from ld_customtable_module where report_id=?";
        $this->CustomTablesActionsObj->adb->pquery($module_delete,array($report_id));
        $parent_id = 0;
        //保存主模块
        $mainmodulesql = "insert into ld_customtable_module (report_id,parent_id,tabid,modulename,pathtype) values(?,?,?,?,?)";
        $this->CustomTablesActionsObj->adb->pquery($mainmodulesql,array($report_id,$parent_id,getTabid($mainmodule),$mainmodule,'mainmodule'));
        $mainmodule_id = $this->CustomTablesActionsObj->adb->getLastInsertID();
        $parent_id = $mainmodule_id;

        foreach($nextSelectedArr as $k=>$moduleinfo){
            $module = $moduleinfo['selectmodule'];
            if(!empty($module)){
                $tabid = getTabid($module);
                $module_sql = "insert into ld_customtable_module (report_id,parent_id,tabid,modulename,pathtype) values (?,?,?,?,?)";
                $this->CustomTablesActionsObj->adb->pquery($module_sql,array($report_id,$parent_id,$tabid,$module,'next'));
                $parent_id = $this->CustomTablesActionsObj->adb->getLastInsertID();
            }
        }
        $parent_id = $mainmodule_id;
        foreach($prevSelectedArr as $k2=>$moduleinfo2){
            $module2 = $moduleinfo2['selectmodule'];
            if(!empty($module2)){
                $tabid = getTabid($module2);
                $module_sql = "insert into ld_customtable_module (report_id,parent_id,tabid,modulename,pathtype) values (?,?,?,?,?)";
                $this->CustomTablesActionsObj->adb->pquery($module_sql,array($report_id,$parent_id,$tabid,$module2,'prev'));
                $parent_id = $this->CustomTablesActionsObj->adb->getLastInsertID();
            }
        }
    }
    //保存表头宽度--sql报表和模块报表都有
    public function saveResizeData(){
        $this->CustomTablesActionsObj->saveResizeData();
    }

    public function changeReportStatus(){
        $this->CustomTablesActionsObj->changeReportStatus();
    }

}
?>