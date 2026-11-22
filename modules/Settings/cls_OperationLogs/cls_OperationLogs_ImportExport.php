<?php

class cls_OperationLogs_ImportExport extends cls_OperationLogs
{
    public $fieldobj;
    private $importtype = [//导入样式
        'Update' => 'IMPORTUPDATE',
        'UpdateAll' => 'IMPORTUPDATEALL',
        'Insert' => 'IMPORTADD',
        'Abort' => 'IMPORTABORT',
    ];
    private $detailimporttype = [//产品分录导入样式
        'NoImportRow' => 'Ignoretheproducts',
        'NoImportData' => 'Ignoretheorder',
        'AddProduct' => 'Automaticallyaddproducts',
    ];
    public function __construct($selectmodule,$actiontype,$userids,$operationtime=''){
		parent::__construct($selectmodule,$actiontype,$userids,$operationtime);
        $focus = CRMEntity::getInstance($selectmodule);
        $this->fieldobj = $focus->fieldobj;
	}
    //标题
    public function setTitle(){
        $this->title = getFixedLabel('ImportExportLogs');
    }
    //获取可选模块
    public function getselectModules()
    {
        global $adb;
        // $sql = "SELECT ld_tab.tabid,name,btnkey from ld_tab 
        //         INNER JOIN ld_btnset ON ld_btnset.tabid = ld_tab.tabid
        //         where isentitytype = 1 and ld_tab.presence in (0,2) and ld_tab.tabid not IN
        //             (SELECT tabid from ld_tab where name in ('ReportAnalysis','VisualAnalysis')) 
        //             and (btnkey = 'Import' or btnkey = 'Export')
        //         order by tabsequence";
        $sql = "SELECT tabid,name from ld_tab where isentitytype = 1 and presence in (0,2) and tabid not IN
                (SELECT tabid from ld_tab where name in ('CooperativeWork','Webmails','Emails','ReportAnalysis','VisualAnalysis')) order by tabsequence";
        $result = $adb->query($sql);
        $i = 0;
        while($moduleinfo=$adb->fetch_array($result))
        {
            $modulelist[$moduleinfo['name']] = getTranstab($moduleinfo['name']);
            $i++;
        }
        return $modulelist;
    }
    //获取操作行为
    public function setOperationActions() {
        global $adb;
        $selectmodule = $this->selectmodule;

        if($selectmodule == ''){
            $selectmodule = array_keys($this->getselectModules())[0];
        }
        $all_operation_actions = [
            'Import' => getFixedLabel('IMPORT'),
            'Export' => getFixedLabel('EXPORT'),
        ];
        // $sql = "SELECT ld_tab.tabid,name,btnkey from ld_tab 
        //         INNER JOIN ld_btnset ON ld_btnset.tabid = ld_tab.tabid
        //         where (btnkey = 'Import' or btnkey = 'Export') and name = ?
        //         order by tabsequence";
        // $result = $adb->pquery($sql,array($selectmodule));
        // $num_rows = $adb->num_rows($result);
    	// if($num_rows > 0) {
        //     for($i = 0; $i<$num_rows; $i++){
        //         $operation_actions[$i] = $adb->query_result($result, $i, "btnkey");
        //     }
        // }
        
        // $keysAssocArray = array_flip($operation_actions);

        // //获取两个关联数组的交集
        // $operation_actions = array_intersect_key($all_operation_actions, $keysAssocArray);

        // return $operation_actions;
        return $all_operation_actions;//目前先返回所有操作
    }
    //获取表头
    public function getTableHeader(){
        global $adb;
        $actiontype = $this->actiontype;

        if($actiontype == ''){
            $actiontype = array_keys($this->setOperationActions())[0];
        }

        if($actiontype == 'Import'){
            $header = [
                getFixedLabel('ImportObject'),
                getFixedLabel('STATUS'),
                getFixedLabel('NumofImportedData'),
                getFixedLabel('NumofFailedImports'),//失败量
                getFixedLabel('ImportResults'),
                getFixedLabel('CHECKIMPORTFIELD'),
                getFixedLabel('ImportMode'),
                getFixedLabel('IMPORT').getFixedLabel('operatoroer'),
                getFixedLabel('IMPORT').getFixedLabel('TIMES'),
                getFixedLabel('Filename'),
            ];
        }else if($actiontype == 'Export'){
            $header = [
                getFixedLabel('ExportObject'),
                getFixedLabel('STATUS'),
                getFixedLabel('NumofExportedData'),
                getFixedLabel('ExportResults'),
                getFixedLabel('EXPORT').getFixedLabel('operatoroer'),
                getFixedLabel('EXPORT').getFixedLabel('TIMES'),
                getFixedLabel('Exportstyles'),
            ];
        }
        return $header;
    }
    //获取表头宽度
    public function getHeaderWidth()
    {
        $actiontype = $this->actiontype;

        if($actiontype == ''){
            $actiontype = array_keys($this->setOperationActions())[0];
        }
        if($actiontype == 'Import'){
            $width = ["width:10%;text-align: left;","width:12%;","width:11%;","width:11%;","width:7%;"
                        ,"width:8%;padding: 4px 15px;","width:11%;padding: 4px 15px;","width:8%;","width:12%;","width:15%;",];
        }else if($actiontype == 'Export'){
            $width = ["width:10%;text-align: left;","width:15%;","width:10%;","width:10%;","width:10%;"
                        ,"width:15%;","width:30%;",];
        }
        return $width;
    }
    //获取单个操作行为日志列表内容
    public function getLogData($pagenum){
    	global $adb,$current_user;

        $sql=$this->getQuery();
        $sql .= $this->getWhere();
        $sql .= $this->setPageInfo($pagenum);
        $result = $adb->query($sql);
        $num_rows = $adb->num_rows($result);

    	if($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                $listdata[$i] = $this->getRowData($result,$i);
            }
    	}

        return $listdata;
    }
    //获取单行日志内容
    public function getRowData($result,$i=0){
    	global $adb,$languageType;
        $actiontype = $this->actiontype;
        $module = $adb->query_result($result, $i, "module");
        $listdata['module'] = getTranstab($module);
        $status = $adb->query_result($result, $i, "status");
        $starttime = $adb->query_result($result, $i, "starttime");
        $finishtime = $adb->query_result($result, $i, "finishtime");
        $listdata['status'] = getFixedLabel($status);
        if($status == 'COMPLETED'){//已完成需要计算耗时
            $starttime = new DateTime($starttime);
            $finishtime = new DateTime($finishtime);
            $usedtime = $starttime->diff($finishtime);
            $usedtime = $usedtime->format('%i'.getFixedLabel('min2').'%s'.getFixedLabel('Second'));//转换成几分几秒
            $listdata['status'] .= "（".getFixedLabel('TimeUsed').$usedtime."）";
        }
        if($actiontype == 'Import'){
            $listdata['importnum'] = $adb->query_result($result, $i, "importnum");
            $listdata['failedimportnum'] = $adb->query_result($result, $i, "failedimportnum");
            //结果
            $importresult = $adb->query_result($result, $i, "importresult");
            $listdata['importresult'] = '';
            if(!empty($importresult))
                $listdata['importresult'] = '<a href="'.$importresult.'" download="'.getTranstab($module).getFixedLabel('ImportResults').'.txt" class="cursorPointer font14">'.getFixedLabel('DownloadToView').'</a>';
            //查重字段
            $duplicatefield = $adb->query_result($result, $i, "duplicatefield");
            $duplicatefield = Zend_Json::decode($duplicatefield);
            if(empty($duplicatefield)){
                $listdata['duplicatefield'] = getFixedLabel('CAMCARDNONE');
            }else{
                foreach($duplicatefield as $index => $item){
                    if($index % 2 == 0){
                        $tmp_duplicate .= $this->fieldobj->getFieldInfoobjBykey('fieldname',$item)->fieldLableKey;
                    }else{
                        $tmp_duplicate .= '<br>('.getFixedLabel($item).') ';//查重字段条件
                    }
                }
                $listdata['duplicatefield'] = $tmp_duplicate;
            }
            //导入方式
            $importtype = Zend_Json::decode($adb->query_result($result, $i, "importtype"));
            $tmp_importtype = getFixedLabel($importtype[0]);
            if(!empty($importtype[1]))
                $tmp_importtype .= '<br>'.getTranstab('Products').': '.getFixedLabel($importtype[1]);
            $listdata['importtype'] = $tmp_importtype;
            $listdata['user'] = getUserFullName($adb->query_result($result, $i, "userid"));
            $listdata['starttime'] = $adb->query_result($result, $i, "starttime");
            //导入文件名
            $importfilename = $adb->query_result($result, $i, "importfilename");
            $exportformat = pathinfo($importfilename, PATHINFO_EXTENSION);
            $downloadhtml = '';
            if(!empty($importfilename))
                $downloadhtml = '<span class="fileDownload" style="margin:0;">
                                    <a href="index.php?module=uploads&frommodule='.$this->selectmodule.'&action=downloadxls&exportformat=export'.$exportformat.'&fromtype=operationlogs&pathname=storage/Import/'.$importfilename.'" 
                                    class="cursorPointer font14" style="margin-top:1px" title="'.getFixedLabel('DOWNLOAD').'"></a>
                                </span>';
            $listdata['importfilename'] = '<div class="uploadifyQueueItem" style="margin:0;padding:0 10px 0 0;">
                                            <span>'.$importfilename.'</span>
                                            '.$downloadhtml.'
                                            </div>';
        }else if($actiontype == 'Export'){
            $listdata['exportnum'] = $adb->query_result($result, $i, "exportnum");
            $exportresult = $adb->query_result($result, $i, "exportresult");
            $exportformat = pathinfo($exportresult, PATHINFO_EXTENSION);
            $listdata['exportresult'] = '<a href="index.php?module=uploads&frommodule='.$this->selectmodule.'&action=downloadxls&exportformat=export'.$exportformat.'&fromtype=operationlogs&pathname='.$exportresult.'" class="cursorPointer font14">'.getFixedLabel('DownloadToView').'</a>';

            $listdata['user'] = getUserFullName($adb->query_result($result, $i, "userid"));
            $listdata['starttime'] = $adb->query_result($result, $i, "starttime");
            $listdata['exporttype'] = getFixedLabel('Export'.$adb->query_result($result, $i, "exporttype"));
        }

        return $listdata;
    }
    //获取查询条件
    public function getWhere(){

        $time_query = getHomeDateScope($this->operationtime);
        $where = ' where module = "'.$this->selectmodule.'"';
        if($time_query != ''){
            $where .= ' and starttime '.$time_query.'';
        }else{
            $where .= ' and starttime > "2000-01-01"';
        }
        if($this->userids != 'SmOwner_Search_All'){
            $where .= ' and userid in ('.$this->userids.') ';
        }
        $where .= '  ORDER BY starttime desc';
        return $where;
    }
    /**
     * 开始导出，保存日志
     * type：导出样式
     */
    public function saveExportStartLogs($num,$type){
        global $adb,$current_user;

        $module = $this->selectmodule;
        $actiontype = $this->actiontype;
        $status = 'INPROGRESS';//状态
 
        $insert_sql = 'INSERT into ld_crmlog_export(userid,`status`,module,exportnum,starttime,exporttype) value(?,?,?,?,?,?)';
        $adb->pquery($insert_sql, array($current_user->id,$status,$module,$num,date("Y-m-d H:i:s"),$type));
        $logid = $adb->getLastInsertID();
        return $logid;
    }
    /**
     * 开始导入，保存日志
     * type：导入方式
     * duplicatefield：查重字段
     * duplicatecon：查重字段条件
     * filename：用户上传的文件名
     */
    public function saveImportStartLogs($type,$duplicatefield,$duplicatecon,$filename,$detailtype=''){
        global $adb,$current_user;
        $module = $this->selectmodule;
        $actiontype = $this->actiontype;
        $status = 'INPROGRESS';//状态
        $importtype[] = $this->importtype[$type];
        if(!empty($detailtype)){
            $importtype[] = $this->detailimporttype[$detailtype];
        }
        $importtype = Zend_Json::encode($importtype);
        $duplicatefield = Zend_Json::decode($duplicatefield);
        $duplicatecon = Zend_Json::decode($duplicatecon);
        $duplicatefield_arr = [];
        if(is_array($duplicatefield) && count($duplicatefield)>=1){
            // 交叉合并两个数组
            for ($i = 0; $i < count($duplicatefield); $i++) {
                $duplicatefield_arr[] = $duplicatefield[$i]; // 添加查重字段
                if($i < count($duplicatefield)-1){
                    if($duplicatecon[$i] == 'and')// 添加查重字段条件
                        $duplicatefield_arr[] = 'SEARCHAND';
                    else
                        $duplicatefield_arr[] = strtoupper($duplicatecon[$i]); 
                }
            }
            $duplicatefield_arr = Zend_Json::encode($duplicatefield_arr);
        }
        if(empty($duplicatefield_arr))
            $duplicatefield_arr = '[]';

        $insert_sql = 'INSERT into ld_crmlog_import(userid,`status`,module,importtype,duplicatefield,starttime,importfilename) value(?,?,?,?,?,?,?)';
        $adb->pquery($insert_sql, array($current_user->id,$status,$module,$importtype,$duplicatefield_arr,date("Y-m-d H:i:s"),$filename));
        $logid = $adb->getLastInsertID();
        return $logid;
    }
    /**
     * 导入导出完成，保存日志
     * logid：saveStartLogs中返回的logid
     * result：导入/导出结果
     * failednum：导入失败条数
     */
    public function saveFinishLogs($logid,$result,$num = 0,$failednum = 0,$status = 'COMPLETED'){
        global $adb,$current_user;
        $module = $this->selectmodule;
        $actiontype = $this->actiontype;
        // $status = 'COMPLETED';//状态
        if($actiontype == 'Import'){
            $update_sql = 'UPDATE ld_crmlog_import SET `status` = ?,importresult = ?,importnum = ?,failedimportnum = ?,finishtime = ? where id = ?';
            $adb->pquery($update_sql, array($status,$result,$num,$failednum,date("Y-m-d H:i:s"),$logid));
        }else if($actiontype == 'Export'){
            $update_sql = 'UPDATE ld_crmlog_export SET `status` = ?,exportresult = ?,finishtime = ? where id = ?';
            $adb->pquery($update_sql, array($status,$result,date("Y-m-d H:i:s"),$logid));
        }
        if($status == 'COMPLETED'){
            unset($_SESSION[$module][$current_user->id][strtolower($actiontype).'log']);
        }
    }
    //备份文件 - 添加序号防止重名覆盖
    public function backUpFile($filenamess){
        global $current_user;

        $module = $this->selectmodule;
        $actiontype = $this->actiontype;
        $folderPath = 'storage/';
        $extension = pathinfo($filenamess, PATHINFO_EXTENSION);
        $filename = pathinfo($filenamess, PATHINFO_FILENAME);
        if(!empty($filename))// 防止取不到文件名,就取第一个.前的内容
            $filename = explode('.',$filenamess)[0];
        $pathname = $folderPath.$current_user->id.'_'.$module.'.xls';
        $pathname_backup = $folderPath.$actiontype.'/'.$filenamess;
        $i = 1;
        while (file_exists($pathname_backup)) {// 文件同名时为文件名添加序号
            $filenamess = $filename."(".$i.")".".".$extension;
            $pathname_backup = $folderPath.$actiontype.'/'.$filenamess;
            $i++;
        }
        if (!is_dir($folderPath.$actiontype)) {// 创建目录
            mkdir($folderPath.$actiontype, 0777, true);
        }
        
        copy($pathname, $pathname_backup);
        return $filenamess;
    }
    //备份文件 - 添加时间戳
    public function backUpFileWithTime($filepath){
        global $current_user;
        // $module = $this->selectmodule;
        if(is_null($filepath))
            return '';
        $actiontype = $this->actiontype;
        $datetime = date('Ymd_His');
        $folderPath = 'storage/';
        $filename = pathinfo($filepath, PATHINFO_FILENAME);
        $filename_backup = $filename.'_'.$datetime;//添加时间戳
        $filehandler_backup = $folderPath.$actiontype.'/'.$filename_backup.'.txt';
        if (!is_dir($folderPath.$actiontype)) {// 创建目录
            mkdir($folderPath.$actiontype, 0777, true);
        }
        copy($filepath, $filehandler_backup);
        return $filehandler_backup;
    }
    //备份文件 - 写入txt文件
    public function backUpFileWriteIn($error){
        global $current_user;
        $module = $this->selectmodule;
        $actiontype = $this->actiontype;
        $datetime = date('Ymd_His');
        $filename = 'storage/'.$actiontype.'importlog_'.$module.'_'.$current_user->id.'_'.$datetime.'.txt';
        $filehandler=fopen($filename,'w+');
        fwrite($filehandler,str_replace('<br>',"\r\n",$error));
        fclose($filehandler);
        return $filename;
    }
    //删除过期日志和对应文件
    public function autoDeleteLogs(){
        global $adb;

        $sys_468 = getSys_deploy(468);//保存的日志存留时长
        $savedtime = intval($sys_468['deploy_value']);
        // $savedtime = 1;
        //删除文件
        $select_sql = 'SELECT importresult,importfilename FROM ld_crmlog_import WHERE starttime < DATE_SUB(NOW(), INTERVAL ? MONTH)';
        $result = $adb->pquery($select_sql,array($savedtime));
        $num_rows = $adb->num_rows($result);
    	if($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                $deletedfiles[] = globalStatic::$root_directory.($adb->query_result($result, $i, "importresult"));
                $importfilenames = $adb->query_result($result, $i, "importfilename");
                $deletedfiles[] = globalStatic::$root_directory.'storage/Import/'.$importfilenames;
            }
            $select_sql = 'SELECT exportresult FROM ld_crmlog_export WHERE starttime < DATE_SUB(NOW(), INTERVAL ? MONTH)';
            $result = $adb->pquery($select_sql,array($savedtime));
            $num_rows = $adb->num_rows($result);
            if($num_rows > 0) {
                for($i = 0; $i<$num_rows; $i++){
                    $deletedfiles[] = globalStatic::$root_directory.($adb->query_result($result, $i, "exportresult"));
                }
            }
            foreach ($deletedfiles as $filePath) {
                if (file_exists($filePath)) {
                    @unlink($filePath);
                }
            }
            //删除日志
            $sql_delimport = 'DELETE FROM ld_crmlog_import WHERE starttime < DATE_SUB(NOW(), INTERVAL ? MONTH)';
            $adb->pquery($sql_delimport,array($savedtime));
            $sql_delexport = 'DELETE FROM ld_crmlog_export WHERE starttime < DATE_SUB(NOW(), INTERVAL ? MONTH)';
            $adb->pquery($sql_delexport,array($savedtime));
    	}
    }
}

?>