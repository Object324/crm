<?php

class cls_OperationLogs
{
    public $logtype;//日志类型,目前有导入导出日志(ImportExport)
    public $logid;//创建时的日志id
    public $selectmodule;//所选模块
    public $actiontype;//操作行为类型，新增，编辑，删除等
    public $action;//操作，包括关联创建，列表编辑等
    public $userids;//操作人
    public $operationtime;//操作时间
    public $operation_actions = [];//操作行为类型数组
    public $maintable = [];//操作行为主表
    public $operation_tables = [//操作行为及对应表
        'All' => 'ld_crmlog_entity',
        'Create' => 'ld_crmlog_create',
        'Edit' => 'ld_crmlog_edit',
        'Delete' => 'ld_crmlog_delete',
        'Reduction' => 'ld_crmlog_delete',
        'Merge' => 'ld_crmlog_delete',
        'Share' => 'ld_crmlog_share',
        'Import' => 'ld_crmlog_import',
        'Export' => 'ld_crmlog_export',
        'ViewDetail' => 'ld_crmlog_viewdetail',
        'CallRecord' => 'ld_callbutler',
        'Decrypt' => 'ld_crmlog_decrypt',
    ];
    public $hyperlink_sql;//获取超链接内容sql
    public $hyperlink_fieldname;//超链接字段
    public $max_entries;//最大条数
    public $alldata_num_rows;//所有日志总条数
    public $all_listdata;//所有日志
    public $title;
    public $edit_detail_logs;//区分后台调用超链接还是列表调用
    public $allowdeleted_tables = [// 能够删除日志的表
        'ld_crmlog_entity','ld_crmlog_create','ld_crmlog_edit','ld_crmlog_delete','ld_crmlog_share',
    ];
    protected $idname = 'id';// 拼写sql时id的叫法,目前分配,公海操作要连其他表所以有表名前缀
    public $logs_from = 'pc';// pc端还是移动端请求
    public static function getInstance($selectmodule,$actiontype,$userids='',$operationtime='',$logtype='')
    {
        if($logtype == 'ImportExport' || $actiontype == 'Import' || $actiontype == 'Export'){// 导入/导出
            $classname = "cls_OperationLogs_ImportExport";
        }else if($actiontype == 'CallRecord' && $logtype == 'CallRecord'){// 通话录音设置
            $classname = "cls_OperationLogs_CallRecord";
        }else{
            if($selectmodule == '' || $actiontype == '' || $actiontype == 'All'){
                $classname = "cls_OperationLogs";
            }else if($actiontype == 'Transfer' || $actiontype == 'Distribute' || $actiontype == 'Receuve' || $actiontype == 'Release' || $actiontype == 'Delay'){
                $classname = "cls_OperationLogs_Publicpool";
            }else{
                $classname = "cls_OperationLogs_".$actiontype;
            }
        }
        
        $class_url = globalStatic::$root_directory.'modules/Settings/cls_OperationLogs/'.$classname.'.php';
        if(file_exists($class_url)){
            crm_load_class_file($classname,'modules/Settings/cls_OperationLogs');
            $classobj = new $classname($selectmodule,$actiontype,$userids,$operationtime);
            return $classobj;
        }else{
            return '';
        } 
    }
    public function __construct($selectmodule,$actiontype,$userids,$operationtime='')
    {
        global $adb,$current_user;
        $this->selectmodule = $selectmodule;
        $this->actiontype = $actiontype;
        $this->userids = $userids;
        $this->operationtime = $operationtime;

        $this->maintable = $this->operation_tables[$actiontype];

        $this->operation_actions = [];

        // $focus = CRMEntity::getInstance($selectmodule);
        // include(globalStatic::$root_directory.'include/utils/DetailViewUtils.php');
        // // crm_load_class_file('LayoutBlockList','modules/Settings');

        // global $adb,$detail_column_fields_value;
        // dump(getValue());

        // $fieldobj=new Field($selectmodule,$adb);

        // $keyword_sseq_arr1 = $fieldobj->getFieldInfoobjBykey_arr('keywords','yes');
        // $keyword_sseq_arr  = json_decode(json_encode($keyword_sseq_arr1),true);
        // $sortarr = _array_column($keyword_sseq_arr,'keyword_sseq');
        // array_multisort($sortarr,SORT_ASC,$keyword_sseq_arr);//给字段重新排序
        // crm_load_class_file('PickListDependencySetup','modules/PickList');
        // dump(getFieldListEntriesForKeywords($selectmodule));
        // dump(getKeyWordsHtml($focus));

        $this->setTitle();
    }
    //标题
    public function setTitle(){
        $this->title = getFixedLabel('OperationLogs');
    }
    //获取操作行为
    public function setOperationActions() {
        global $adb;
        $selectmodule = $this->selectmodule;
        if($selectmodule == ''){
            $selectmodule = array_keys($this->getselectModules())[0];
        }
        // $modules = array_keys($this->getselectModules());
        // $modulesLength = implode(',', array_fill(0, count($modules), '?'));
        // $modules = implode(',',$modules);
        // $sql = 'SELECT ld_tab.tabid,`name`,ld_btnset.btnkey as btnkey from ld_tab 
        //         INNER JOIN ld_btnset ON ld_btnset.tabid = ld_tab.tabid
        //         where `name` = ?';
        // $result = $adb->pquery($sql,array($selectmodule));
        // $num_rows = $adb->num_rows($result);
    	// if($num_rows > 0) {
        //     for($i = 0; $i<$num_rows; $i++){
        //         $savedactions[$i] = $adb->query_result($result, $i, "btnkey");
        //     }
    	// }
        // $cur_operation_actions = [
        //     'Create',
        //     'Edit',
        //     'Delete',
        //     'Reduction' ,//还原
        //     'Merge',//合并
        //     'Allocate',//分配
        //     'Share',//共享
        // ];
        // $intersection = array_intersect($savedactions, $cur_operation_actions);
        // dump($intersection);

        $this->operation_actions = [
            'All' => getFixedLabel('ALL'),
            'Create' => getFixedLabel('CREATE'),
            'Edit' => getFixedLabel('EDIT'),
            'Delete' => getFixedLabel('DELETE'),
            'Reduction' => getFixedLabel('REDUCTION'),//还原
            'Merge' => getFixedLabel('Merge'),//合并
            'Allocate' => getFixedLabel('ALLOCATE'),//分配
            'Share' => getFixedLabel('SHARE'),//共享
            'ViewDetail'=> getFixedLabel('VIEWDETAILSINFO'),//查看详情
            'Decrypt'=> getFixedLabel('Decrypt'),//解密
        ];
        if($selectmodule == 'Accounts' || $selectmodule == 'Leads' ){
            $publicpool_operation_actions = [
                'Transfer' => getFixedLabel('HIGHSEAS').' - '.getFixedLabel('Transfer'),//变更公海
                'Distribute' => getFixedLabel('HIGHSEAS').' - '.getFixedLabel('ALLOCATE'),//公海分配
                'Receuve' => getFixedLabel('HIGHSEAS').' - '.getFixedLabel('RECEIVE'),//公海领取
                'Release' => getFixedLabel('HIGHSEAS').' - '.getFixedLabel('RELEASE'),//公海释放
                'Delay' => getFixedLabel('HIGHSEAS').' - '.getFixedLabel('ACCOUNTDELAY'),//公海延期
            ];
            $this->operation_actions = $this->operation_actions + $publicpool_operation_actions;
        }

        return $this->operation_actions;
    }
    //获取可选模块
    public function getselectModules()
    {
        global $adb;
       /* $sql = "SELECT tabid,name from ld_tab where isentitytype = 1 and presence in (0,2) and tabid not IN
                (SELECT tabid from ld_tab where name in ('CooperativeWork','WorkReportList','Webmails','Emails','ReportAnalysis','VisualAnalysis'))
                 or name = 'Users' order by tabsequence";*/
        $sql='select ld_tab.tabid ,ld_tab.name from ld_tab inner join ld_field  on ld_tab.tabid =ld_field.tabid 
        where ld_tab.presence in(0,2) group by ld_tab.tabid   order by tabsequence ';
        $result = $adb->query($sql);
        while($moduleinfo=$adb->fetch_array($result))
        {
            $modulelist[$moduleinfo['name']] = getTranstab($moduleinfo['name']);
        }
        return $modulelist;
    }
    //获取表头
    public function getTableHeader()
    {
        $header = [
            getFixedLabel('operatoroer'),
            getFixedLabel('operatoroertime'),
            getFixedLabel('OperationBehavior'),
            getFixedLabel('OperationModules'),
            getFixedLabel('OperationData'),
            getFixedLabel('OperationDetails'),
        ];
        return $header;
    }
    //获取表头宽度
    public function getHeaderWidth()
    {
        $width = ["width:15%;text-align: left;","width:20%;","", "width:10%;", "width:10%;", "width:35%;"];
        return $width;
    }
    //获取单个操作行为日志列表内容
    public function getLogData($pagenum){
        $this->setEditDetailLogs('true');
    	global $adb,$current_user;
        
        $sql = $this->getQuery();
        $sql .= $this->getWhere();
        $sql .= $this->setPageInfo($pagenum);
        $result = $adb->query($sql);
        $num_rows = $adb->num_rows($result);
    	if($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                if($this->actiontype == 'All'){
                    
                }else{
                    $listdata[$i] = $this->getRowData($result,$i);
                }
            }
    	}

        return $listdata;
    }
    //获取单行日志内容
    public function getRowData($result,$i=0){
    	global $adb,$current_user;

        $listdata['user'] = getUserFullName($adb->query_result($result, $i, "userid"));
        $listdata['operationtime'] = $adb->query_result($result, $i, "operationtime");
        $listdata['id'] = $adb->query_result($result, $i, "id");
        $action = $adb->query_result($result, $i, "action");
        $listdata['action'] = $action;
        $module = $adb->query_result($result, $i, "module");
        $listdata['module'] = $module;

        $crmid = $adb->query_result($result, $i, "crmid");
        $this->logid = $adb->query_result($result, $i, "id");
        $listdata['crmid'] = $crmid;
        $this->setOperationtime($listdata['operationtime']);
        $this->setUserids($listdata['user']);
        $listdata['record'] = cls_OperationLogs::getHyperlinkHtml($module,$crmid);
        $operationdetails_labelbol = $adb->query_result($result, $i, "operationdetails");
        //wsh 2024-07-30 bug BUG20240726-21 后台操作日志，操作数据包含了操作行为和操作对象，重复显示了
//        $operationdetails = $this->getDetailsLabel($operationdetails_labelbol,$module,$crmid);
        $listdata['operationdetails_labelbol'] = $operationdetails_labelbol;
        if ($this->actiontype == 'Edit'){
            $listdata['operationdetails'] = $this->getHyperlinkHtml($module,$crmid);
        }else{
            $listdata['operationdetails'] = '';
        }
        return $listdata;
    }
    //获取全部操作行为日志列表内容
    public function getAllLogData($pagenum){
    	global $adb,$current_user;
        $this->setEditDetailLogs('true');
        $sql = $this->getQuery();
        $sql .= $this->getWhere();
        $sql .= $this->setPageInfo($pagenum);
        $result = $adb->query($sql);
        $num_rows = $adb->num_rows($result);

    	if($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){

                $id = $adb->query_result($result, $i, "id");
                $actiontype = $adb->query_result($result, $i, "actiontype");
                $module = $adb->query_result($result, $i, "module");
                $action_table = $this->operation_tables[$actiontype];

                $classobj = self::getInstance($module,$actiontype);
                $classobj->setEditDetailLogs('true');

                if($actiontype == 'Allocate'){
                    $action_sql = 'SELECT * FROM ld_modtracker_basic as b 
                                    LEFT JOIN ld_modtracker_detail as d ON b.id = d.id 
                                    INNER JOIN ld_crmlog_entity as entity ON b.id = entity.relatedid 
                                    where entity.id = ?';
                }else if($actiontype == 'Transfer' || $actiontype == 'Distribute' || $actiontype == 'Receuve' || $actiontype == 'Release' || $actiontype == 'Delay'){
                    $action_sql = 'SELECT log.id,log.username,operation,opdate,log.userid,zh_name,en_name,'.$classobj->idindex.' from '.$classobj->log_table.' as log
                                    LEFT JOIN '.$classobj->pool_table.' as pool on pool.id = log.pool_id
                                    INNER JOIN ld_crmlog_entity as entity ON log.id = entity.relatedid 
                                    where entity.id = ?';
                }else{
                    $action_sql = 'SELECT * FROM ld_crmlog_entity LEFT JOIN '.$action_table.' 
                                    ON ld_crmlog_entity.id = '.$action_table.'.id where ld_crmlog_entity.id = ?' ;
                }
                $action_result = $adb->pquery($action_sql,array($id));
                $listdata[$i] = $classobj->getRowData($action_result,0);
            }
    	}
        return $listdata;
    }
    //根据crmid获取超链接
    public function getHyperlinkHtml($module,$crmid){
    	global $adb,$current_user,$weixin_user;
        if($module == 'Users'){
            $hyperlink_value = getUserFullName($crmid);
            $hyperlink_value_title = '';
        }else{
            $hyperlink_value = getModuleHref($module,$crmid);
            $hyperlink_value_title = $hyperlink_value;
        }

        if($this->logs_from == 'mobile')
            return $hyperlink_value;
        if($hyperlink_value == ''){
            $hyperlink_html = $this->getDeletedRecordInfo($crmid);
        }else{
            $hyperlink_html = '<a fieldname="'.$this->hyperlink_fieldname.'" module="'.$module.'" record="'.$crmid.'" href="javascript:;"  onclick="ListLinkClick(ld(this),event)" title="'.$hyperlink_value_title.'">'.$hyperlink_value.'</a>';
        }

        return $hyperlink_html;
    }
    //获取多个超链接,穿string
    public function getHyperlinkHtmls($module,$crmids){
        if(empty($crmids))
            return '';

    	global $adb,$current_user;
        $crmids = explode(',',$crmids);
        $hyperlink_html = '';
        foreach($crmids as $index => $crmid){
            if($index > 0){
                $hyperlink_html .= '，';
            }
            $hyperlink_html .= $this->getHyperlinkHtml($module,$crmid);
        }
        
        return $hyperlink_html;
    }
    //获取已彻底删除单据的超链接字段，关键信息等
    public function getDeletedRecordInfo($crmid){
    	global $adb,$current_user;

        $select_sql = 'SELECT * FROM ld_crmlog_deletedrecords WHERE crmid = ?';
        $result = $adb->pquery($select_sql,array($crmid));
        $keyinfo = $adb->query_result($result, 0, "keyinfo");
        $hyperlink_content = $adb->query_result($result, 0, "hyperlink_content");

        return $hyperlink_content;
    }
    //获取多个成员姓名
    public function getUsersFullName($userids){
        if(empty($userids))
            return '';
        $userids = explode(',',$userids);
        $fullnames = '';
        foreach($userids as $index => $userid){
            if($index > 0){
                $fullnames .= '，';
            }
            $fullnames .= getUserFullName($userid);
        }
        return $fullnames;
    }
    //获取查询sql
    public function getQuery(){

        $sql = 'SELECT * FROM ' .$this->maintable;

        return $sql;
    }
    //获取查询条件
    public function getWhere(){

        $time_query = getHomeDateScope($this->operationtime);
        $where = ' where module = "'.$this->selectmodule.'"';
        if($time_query != ''){
            $where .= ' and operationtime '.$time_query.'';
        }else{
            $where .= ' and operationtime > "2000-01-01"';
        }
        if($this->userids != 'SmOwner_Search_All' && !empty($this->userids)){
            $where .= ' and userid in ('.$this->userids.') ';
        }
        if($this->maintable == 'ld_crmlog_delete'){
            $where .= ' and actiontype = "'.$this->actiontype.'"';
        }
        if($this->actiontype == 'All'){
            $actiontypes = implode('","',array_keys(self::setOperationActions()));
            $where .= ' and actiontype in ( "'.$actiontypes.'" ) ';
        }else{
            $where .= ' and action != ""';
        }

        $where .= ' ORDER BY operationtime desc';
        return $where;
    }
    //设置分页信息
    public function setPageInfo($pagenum){
        $rows = ($pagenum-1) * $this->max_entries;
        $query = ' LIMIT '.$this->max_entries.' OFFSET '.$rows;
        return $query;
    }
    //获取总条数
    public function getTotalRows(){
        global $adb;

        $sql = $this->getQuery();
        $sql .= $this->getWhere();
        $result = $adb->query($sql);
        $num_rows = $adb->num_rows($result);
        return $num_rows;
    }
    //获取操作详情
    public function getDetailsLabel($labelbol,$module,$crmid,$content=''){
        $modulename = getTranstab($module);
        $record = $this->getHyperlinkHtml($module,$crmid);

        $labelstr = getFixedLabel($labelbol);
        $labelstr = str_replace('{Module}',$modulename,$labelstr);
        $labelstr = str_replace('{Var}',$record,$labelstr);

        return $labelstr;
    }
    /**
     * 保存日志
     * module 模块 , actiontype 操作行为(Create,Edit等,用于对应子类和表),
     * crmid 单据id(可传单个id字符串或多个id数组), relatedid 关联id,用于分配,公海之类已经有表的
     * content 其他内容,例如表中action的labelbol或共享中的共享人和移除的共享人等 , 数组形式
     */
    public static function saveLogs($module,$actiontype,$crmid,$content=[],$relatedid=''){
        global $adb,$current_user;
        // if($actiontype == '' && isset($content['mode'])){
        //     $actiontype = $content['mode'];
        // }

        $actiontype = is_string($actiontype) ? ucfirst($actiontype) : '';//首字母大写
        if(empty($actiontype) && isset($content['Create']) && $content['Create'] == 'yes'){// 移动端新建单据
            $actiontype = 'Create';
        }
        if(isset($content['mergemode']) && $content['mergemode'] == 'mergesave'){//合并
            if($actiontype == 'Delete'){//合并时产生的删除操作不保存进日志
                return;
            }
            $actiontype = 'Merge';
        }
        if($actiontype == 'Create' || $actiontype == 'Edit'){
            if($module == 'Accounts' && $content['module'] == 'ServiceCharge'){
                $module = 'ServiceCharge';
            }
        }
        $classobj = cls_OperationLogs::getInstance($module,$actiontype);

        if(!empty($classobj) && in_array($actiontype,array_keys($classobj->setOperationActions()))){//判断当前是否支持存储该操作的日志
            $entity_sql = 'INSERT into ld_crmlog_entity(userid,actiontype,module,operationtime,relatedid,crmid) value(?,?,?,?,?,?)';
            //有一次传多个单据id的情况，但一般为一次一个
            if(!is_array($crmid)){
                $crmid_arr = [$crmid];
            }else{
                $crmid_arr = $crmid;
            }
            foreach($crmid_arr as $index => $id){
                $adb->pquery($entity_sql, array($current_user->id,$actiontype,$module,date("Y-m-d H:i:s"),$relatedid,$id));
                $logid[$index] = $adb->getLastInsertID();
            }
            $logid = count($logid)==1?$logid[0]:$logid;//如果只有一个id则还是转换成字符串
            $crmid = count($crmid_arr)==1?$crmid_arr[0]:$crmid_arr;
            if($classobj->isNeedSave($actiontype)){
                $logid = $classobj->save($logid, $module, $actiontype, $crmid, $content);
                return $logid;
            }
        }
    }
    public function save($logid,$module,$actiontype,$crmid,$content=[]){

    }
    //判断是否需要保存在单独的ld_crmlog_表
    public function isNeedSave($actiontype){
        return true;
    }
    //记录要彻底删除的单据信息
    public static function saveDeletedRecordInfo($module,$crmids){
        global $adb;
        foreach($crmids as $i => $crmid){
            $hyperlink_value[$i] = getModuleHref($module,$crmid);
            $keyinfo[$i] = '';
        }
        $sql = 'INSERT into ld_crmlog_deletedrecords(crmid,keyinfo,hyperlink_content) value(?,?,?)';
        foreach($crmids as $i => $crmid){
            $adb->pquery($sql, array($crmid,$keyinfo[$i],$hyperlink_value[$i]));
        }
    }
    // 删除过期日志
    public function autoDeleteLogs(){
        global $adb;

        $sys_468 = getSys_deploy(468);//保存的日志存留时长
        $savedtime = intval($sys_468['deploy_value']);
        // $savedtime = 1;
        // $select_sql = 'SELECT id,actiontype  FROM ld_crmlog_entity WHERE operationtime < DATE_SUB(NOW(), INTERVAL ? MONTH)';
        // $result = $adb->pquery($select_sql,array($savedtime));
        // $num_rows = $adb->num_rows($result);

    	// if($num_rows > 0) {
        //     for($i = 0; $i<$num_rows; $i++){
        //         $id = $adb->query_result($result, $i, "id");
        //         $actiontype = $adb->query_result($result, $i, "actiontype");
        //         $deletelogs[$actiontype] .= $id.',';
        //     }
    	// }
        // foreach($deletelogs as $actiontype => &$ids){
        //     $ids = rtrim($ids, ",");
        //     $ids = explode(",",$ids);
        //     $idLength = implode(',', array_fill(0, count($ids), '?'));

        //     $action_table = $this->operation_tables[$actiontype];
        //     //删除操作自己日志表中数据
        //     if(!empty($action_table)){
        //         $sql = 'DELETE FROM '.$action_table.' WHERE id in ('.$idLength.')';
        //         $adb->pquery($sql,array($ids));
        //     }
        // }
        // //删除总表日志
        // $delete_sql = 'DELETE FROM ld_crmlog_entity WHERE operationtime < DATE_SUB(NOW(), INTERVAL ? MONTH)';
        // $adb->pquery($delete_sql,array($savedtime));

        foreach($this->allowdeleted_tables as $index => $table){
            $delete_sql = "DELETE FROM $table WHERE operationtime < DATE_SUB(NOW(), INTERVAL ? MONTH)";
            $adb->pquery($delete_sql,array($savedtime));
        }

    }
    /**
     * 删除所有过期日志
     * 静态方法，需要加什么日志的自动删除，声明类后加在里面即可
     */
    public static function autoDeleteAllLogs(){
        $cls_operationlogs = cls_OperationLogs::getInstance('','');
        $cls_operationlogs->autoDeleteLogs();
        //导入导出日志自动删除
        $cls_importexportlogs = cls_OperationLogs::getInstance('','','','','ImportExport');
        $cls_importexportlogs->autoDeleteLogs();

        // 其他方法
    }
    /**
     * 获取单据相关信息中操作日志
     * 
     */
    public function getRelatedListInfo($logids){
        global $adb, $PlatformMC;
        $logids = implode(',',$logids);
        $select_sql = $this->getQuery();
        $select_sql .= " WHERE $this->idname in ( $logids )";
        $result = $adb->query($select_sql);
        $num_rows = $adb->num_rows($result);
    	if($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                $list_data = $this->getRowData($result,$i);

                $return_data[$i]['operator'] = $list_data['user'];
                $return_data[$i]['operationtime'] = $list_data['operationtime'];
                $return_data[$i]['operationbehavior'] = getFixedLabel($list_data['action']);
                $return_data[$i]['module'] = getTranstab($list_data['module']);
                $return_data[$i]['record'] = $list_data['record'];
                $return_data[$i]['operationdetails'] = $list_data['operationdetails'];
                //wsh 2024-07-03 XUQIU20240607-08 单据查看详情界面，相关信息操作日志，“编辑”操作详情增加“修改日志详情”操作按钮
                if (!empty($PlatformMC)){
                    $return_data[$i]['logid'] = $list_data['id'];
                    if ($list_data['action'] == 'EDIT' || $list_data['action'] == 'DetailViewEdit' || $list_data['action'] == 'ListEdit'){
                        $return_data[$i]['isEditDetail'] = 'yes';
                    }else{
                        $return_data[$i]['isEditDetail'] = 'no';
                    }
                }
            }
    	}
        return $return_data;
    }


    //wsh 2024-07-03 XUQIU20240607-08 单据查看详情界面，相关信息操作日志，“编辑”操作详情增加“修改日志详情”操作按钮
    public static function SaveOperationLogsRelation($focus){
        //$trackId, $logId, $modTrackerIds
        $trackId = $focus->trackId;
        $logId = $focus->logId;
        $modTrackerIds = $focus->modTrackerIds;
        global $adb;
        foreach ($modTrackerIds as $modTrackerId){
            if(!empty($logId)){
                $query = 'insert into ld_crmlog_relation( type, relation_id, operation_log_id) values (?,?,?)';
                $adb->pquery($query,array( 'modTrackerLog', $modTrackerId, $logId));
            }
        }
        if(!empty($trackId)){
            $query = 'insert into ld_crmlog_relation( type, relation_id, operation_log_id) values (?,?,?)';
            $adb->pquery($query,array( 'detailTrackerLog', $trackId, $logId));
        }
        unset($focus->trackId);
        unset($focus->logId);
        unset($focus->modTrackerIds);
    }
    public function getOperationtime()
    {
        return $this->operationtime;
    }
    public function setOperationtime($operationtime)
    {
        $this->operationtime = $operationtime;
    }
    public function getUserids()
    {
        return $this->userids;
    }
    public function setUserids($userids)
    {
        $this->userids = $userids;
    }
    public function getEditDetailLogs()
    {
        return $this->edit_detail_logs;
    }
    public function setEditDetailLogs($edit_detail_logs): void
    {
        $this->edit_detail_logs = $edit_detail_logs;
    }
    public function setLogsFrom($logs_from)
    {
        $this->logs_from = $logs_from;
    }
}

?>