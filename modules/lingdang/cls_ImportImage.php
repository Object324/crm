<?php
class cls_ImportImage{

    protected $module;

    function __construct($module)
    {
        $this->module = $module;
    }

    //导入第一步 判断字段是否可以导入 设置session数据
    public function startImportImage($imagefield,$nameformatfield,$nameformatexplode,$importImageArr){
        global $current_user,$adb;
        $module = $this->module;
        if ($nameformatexplode == 'underline'){
            $nameformatexplode = '_';
        }else if ($nameformatexplode == 'bracket'){
            $nameformatexplode = '(';
        }
        //检测导入字段是否启用或有权限
        $focus = CRMEntity::getInstance($module);
        $fieldobj = $focus->fieldobj;
        $imageField_noerror = true;
        if ($fieldobj){
            $image_fieldinfo = $fieldobj->getFieldInfoobjBykey("fieldname", $imagefield);
            if ($image_fieldinfo){
                $savedatabase = $image_fieldinfo->getSaveDataBase();
                if (!is_admin($current_user)) {
                    $profilefields = $focus->getProfileFields($current_user->profileid);
                }
                $fieldid = $image_fieldinfo->getFieldid();
                if ($savedatabase == 'no' || (!empty($profilefields) && ($image_fieldinfo->getReadOnly() == 1 || $profilefields[$fieldid]['editreadonly'] == 1 )) ) {//字段权限只读
                    $imageField_noerror = false;
                }
                $image_columnname = $image_fieldinfo->getColumnname();
            }else{
                $imageField_noerror = false;
            }
        }else{
            $imageField_noerror = false;
        }
        if (!$imageField_noerror){
            return false;
        }
        unset($profilefields,$fieldid,$image_fieldinfo);

        //session中导入图片部分格式化
        $this->initImportImageSession();
        $_SESSION[$module.'ImportImageInfoArr']['imagefield'] = $image_columnname;
        $_SESSION[$module.'ImportImageInfoArr']['nameformatfield'] = $nameformatfield;
        $_SESSION[$module.'ImportImageInfoArr']['nameformatexplode'] = $nameformatexplode;
        if (is_array($importImageArr)){
            $_SESSION[$module.'ImportImageInfoArr']['importImageArr'] = array_values($importImageArr);
            $_SESSION[$module.'ImportImageInfoArr']['imageTotalNums'] = sizeof($importImageArr);
        }

        //获取产品名称/产品编号
        $record_arr = [];
        if (is_array($importImageArr) && sizeof($importImageArr) > 0){
            foreach ($importImageArr as $importImage){
                $fileindex = $importImage['filerowindex'];
                $filename = $importImage['file_name'];
                if (!empty($filename)){
                    $tmp_record_label = $this->getLabelByExploadFileName($filename,$nameformatexplode);
                    if ($tmp_record_label){
                        if (isset($record_arr[$tmp_record_label])){
                            $record_arr[$tmp_record_label][] = $fileindex;
                        }else{
                            $record_arr[$tmp_record_label] = array($fileindex);
                        }
                    }
                }
            }
            $_SESSION[$module.'ImportImageInfoArr']['FileNameIndex'] = $record_arr;
            unset($importImageArr,$fileindex,$filename,$tmp_filename_arr,$tmp_record_label);
        }
        //根据命名格式获取所有单据id
        $tablename = $focus->table_name;
        $tablenamecf = $focus->customFieldTable[0];
        $tableindex = $focus->table_index;
        $tablecfindex = $focus->customFieldTable[1];
        $tablenameindex = $tablename.'.'.$tableindex;
        $tablecfnameindex = $tablenamecf.'.'.$tablecfindex;
        $nameformat_fieldinfo = $fieldobj->getFieldInfoobjBykey("fieldname", $nameformatfield);
        if ($nameformat_fieldinfo){
            $nameformat_columnname = $nameformat_fieldinfo->getColumnName();
            $nameformat_tablename = $nameformat_fieldinfo->getTableName();
            $nameformat_tablename_columnname = $nameformat_tablename.'.'.$nameformat_columnname;
            if (is_array($record_arr) && sizeof($record_arr) > 0){
                $record_key_arr = array_keys($record_arr);
                $record_sql = 'select '.$tablenameindex.','.$nameformat_tablename_columnname.' from '.$tablename;
                $record_sql .= ' left join '.$tablenamecf.' on '.$tablecfnameindex.' = '.$tablenameindex;
                $record_sql .= ' where deleted = 0 ';
                $tmp_record_key_arr = array_fill(0,count($record_key_arr),$nameformat_tablename_columnname.' = ?');
                $record_sql .= ' and ( '.implode(' or ',$tmp_record_key_arr).' )';
                $record_result = $adb->pquery($record_sql,$record_key_arr);
                if ($adb->num_rows($record_result) > 0){
                    $record_info = $adb->query_result_all($record_result);
                    if (is_array($record_info) && sizeof($record_info) > 0){
                        $record_info = array_column($record_info,$nameformat_columnname,$tableindex);
                        $_SESSION[$module.'ImportImageInfoArr']['FileNameRecord'] = $record_info;
                    }
                }
            }
            unset($record_info,$record_result,$record_sql,$nameformat_fieldinfo,$nameformat_columnname,$nameformat_tablename,$nameformat_tablename_columnname,$record_key_arr,$record_arr);
        }
        unset($nameformat_fieldinfo,$tablecfnameindex,$tablenameindex,$tablecfindex,$tableindex,$tablenamecf,$tablename,$focus,$fieldobj);

        return true;
    }

    //根据命名格式获取名称或编码
    public function getLabelByExploadFileName($filename,$nameformatexplode)
    {
        $filename = rtrim($filename);
        $label = false;
        $last_explode_index = strrpos($filename,$nameformatexplode);
        if ($nameformatexplode == '_' && $last_explode_index !== false) {//下划线
            $label = substr($filename, 0, $last_explode_index);
        }else if ($nameformatexplode == '('){//中英文括号
            $last_explode_index = !$last_explode_index ? strrpos($filename,'（') : $last_explode_index;
            if ($last_explode_index !== false){
                $another_last_explode_index = strrpos($filename,')');
                $another_last_explode_index = !$another_last_explode_index ? strrpos($filename,'）') : $another_last_explode_index;
                if ($another_last_explode_index !== false && $last_explode_index < $another_last_explode_index ){
                    $label = substr($filename, 0, $last_explode_index);
                }
            }
        }

        return $label;
    }

    //导入图片
    public function importImageIntoAttachment($startIndex,$endIndex)
    {
        global $adb;
        $module = $this->module;
        $importImageArr = $_SESSION[$module.'ImportImageInfoArr']['importImageArr'];
        $imagefield = $_SESSION[$module.'ImportImageInfoArr']['imagefield'];
        $nameFormatExplode = $_SESSION[$module.'ImportImageInfoArr']['nameformatexplode'];
        $FileNameRecord = $_SESSION[$module.'ImportImageInfoArr']['FileNameRecord'];
        $FileNameIndex = $_SESSION[$module.'ImportImageInfoArr']['FileNameIndex'];
//        dump([$importImageArr,$imagefield,$nameFormatExplode,$FileNameRecord,$FileNameIndex]);
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();
        import('data.Logic','class');
        import('data.BaseLogic','class');
        if(!file_exists(globalStatic::$root_directory.'modules/'.$module.'/'.$module.'Logic.class.php')) {
            $BaselogicObj = new BaseLogic();
        } else {
            require_once(globalStatic::$root_directory.'modules/'.$module.'/'.$module.'Logic.class.php');
            $cls = $module.'Logic';
            $BaselogicObj = new $cls();
        }
        $BaselogicObj->setModule($module);
        $foucs = CRMEntity::getInstance($module);
        $recordEditPermit = [];//记录单据编辑权限
        for ($i = $startIndex; $i < $endIndex+1; $i++){
//        dump($importImageArr[$startIndex]);
            $tmp_fileinfo = $importImageArr[$i];
            if (is_array($tmp_fileinfo)){
                $filename = $tmp_fileinfo['file_name'];
                $fileindex = $tmp_fileinfo['filerowindex'];
                $recordid = '';
                if (!empty($filename)){
                    $tmp_record_label = $this->getLabelByExploadFileName($filename,$nameFormatExplode);
                    if ($tmp_record_label){
                        $tmp_file_index = $FileNameIndex[$tmp_record_label];
                        if (is_array($tmp_file_index) && array_search($fileindex,$tmp_file_index) > 9){//每条单据导入最多10张
                            $this->setImportLogContent($tmp_fileinfo,'no','overLimit');
                            continue;
                        }
                        $recordid = array_keys($FileNameRecord,$tmp_record_label);
                    }
                }
                if (empty($recordid)){//没有匹配的单据
                    $this->setImportLogContent($tmp_fileinfo,'no','noRecord');
                    continue;
                }
                else if (is_array($recordid) && sizeof($recordid) > 1){//匹配的单据超过10
                    $this->setImportLogContent($tmp_fileinfo,'no','notUnique');
                    continue;
                }
                else{
                    $recordid = $recordid[0];
                }
                //单据编辑权限
                $editpermit = $recordEditPermit[$recordid];
                if (empty($editpermit)){
                    $foucs->id = $recordid;
                    $foucs->retrieve_entity_info($recordid,$module);
                    $BaselogicObj->setController($foucs);
                    $editbutton = $BaselogicObj->getEditViewBtn();
                    $editpermit = $editbutton['permit'];
                    $recordEditPermit[$recordid] = $editpermit;
                }
                if($editpermit != 'yes') {
                    $this->setImportLogContent($tmp_fileinfo,'no','noedit');
                    continue;
                }
                //图片数据处理
                $filename = from_html(preg_replace('/\s+/', '_', $filename));
                $filename = FileFileterString($filename);
                $filetype = $tmp_fileinfo['file_type'];
                $filepath = $tmp_fileinfo['file_path'];
                $filesize = $tmp_fileinfo['file_size'];
                $newfile_name = $tmp_fileinfo['newfile_name'];
                $isEncrypt = $tmp_fileinfo['isEncrypt'];
                $imagefromtype = $tmp_fileinfo['imagefromtype'];
                $imagefromtype = $imagefromtype ?? 'Computer';
                $filepath = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt->decode($filepath) : $filepath;
                $newfile_name = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt->decode($newfile_name) : $newfile_name;
                $newfile_name = FileFileterString($newfile_name);//edit:can 20200824 上传文件的特殊字符过滤和安全性检测
                $newfile_name = str_replace("&", "_", $newfile_name);
                if ($filename == '' && $filesize <= 0.0001) {
                    $this->setImportLogContent($tmp_fileinfo,'no','nullFile');
                    continue;
                }
                $upload_from = $tmp_fileinfo['upload_from'];
                $upload_from = $upload_from ?? '';
                $storage_location = $tmp_fileinfo['storage_location'];
                if (empty($storage_location) || $storage_location == 'undefined') {
                    $storage_location = 'local';
                    $cloud_path = '';
                } elseif ($storage_location == 'cos') {
                    //给存储桶链接增加头，以便界面显示
                    $cloud_path = $tmp_fileinfo['cloud_path'];
                    $cloud_path = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt->decode($cloud_path) : $cloud_path;
                    $cloud_path = str_replace("http://", 'https://', $cloud_path);
                    if (stripos($cloud_path, 'https://') === false) {
                        $cloud_path = 'https://' . $cloud_path;
                    }
                }
                $binFile = sanitizeUploadFileName($filename, '');
                $filename = ltrim(basename(" " . $binFile));
                $filetype = $filetype ?? getFileTypeByfilename($newfile_name);

                //插入
                $current_id = $adb->getUniqueID("ld_crmentity");
                $sql1 = 'insert into ld_crmentity (crmid,setype) values(?,?);';
                $params1 = array($current_id, $module." Image");
                $adb->pquery($sql1, $params1);
                $sql2 = "insert into ld_attachments(attachmentsid,name,newfile_name,description,type,path,size,imagefromtype,cloud_path,storage_location,upload_from) values(?,?,?,?,?,?,?,?,?,?,?)";
                $params2 = array($current_id,$filename,$newfile_name,"",$filetype,$filepath,$filesize,$imagefromtype,$cloud_path,$storage_location,$upload_from);
                $adb->pquery($sql2, $params2);
                $sql3 = 'insert into ld_seattachmentsrel(crmid,attachmentsid,attachmentcolumnname) values(?,?,?)';
                $adb->pquery($sql3, array($recordid, $current_id, $imagefield));
                $this->setImportLogContent($tmp_fileinfo,'yes','');
            }
        }
        unset($filename,$sql3,$sql2,$sql1,$params1,$params2,$filetype,$binFile,$cloud_path,$storage_location,$upload_from,$newfile_name,$imagefromtype,$isEncrypt,$filesize,$fileindex,$recordid);
        unset($current_id,$tmp_fileinfo,$tmp_file_index,$tmp_filename_arr,$tmp_record_label,$cls_MyCRMcrypt,$nameFormatExplode,$importImageArr,$imagefield);
    }

    //记录导入失败或原因
    public function setImportLogContent($fileinfo,$isSuccess,$reason = '') {
        $filename = $fileinfo['file_name'];
        $module = $this->module;
        $content = '';
        if ($isSuccess == 'yes'){
            $content .= getVarFixedLabel('ImageImportSuccessfully',$filename);
            $_SESSION[$module.'ImportImageInfoArr']['successNums']++;
        }else{
            $content .= getVarFixedLabel('ImportFailedReason',$filename);
            switch ($reason) {
                case 'noRecord':
                    $content .= getFixedLabel('ImportFailedReasonNoRecord');
                    break;
                case 'overLimit':
                    $content .= getFixedLabel('ImportFailedReasonOverLimit');
                    break;
                case 'nullFile':
                    $content .= getFixedLabel('INVALIDFILE');
                    break;
                case 'notUnique':
                    $content .= getFixedLabel('ImportFailedReasonNotUnique');
                    break;
                case 'noedit':
                    $content .= getFixedLabel('YOUARENOTALLOWEDTOEDITOTHERUSERSDATE');
                    break;
            }
            $_SESSION[$module.'ImportImageInfoArr']['errorContent'][] = $content;
            $_SESSION[$module.'ImportImageInfoArr']['errorNums']++;
            $_SESSION[$module.'ImportImageInfoArr']['errorFile'] = $fileinfo;
        }
        $_SESSION[$module.'ImportImageInfoArr']['allContent'][] = $content;
        unset($reason,$module,$filename,$isSuccess);
        return $content;
    }

    //获取进度内容
    public function getProgressContent($endImportTime,$endIndex)
    {
        $module = $this->module;
        $endIndex = intval($endIndex) + 1;
        $startImprtTime = $_SESSION[$module.'ImportImageInfoArr']['startDateTime'];
        $maxlength = $_SESSION[$module.'ImportImageInfoArr']['imageTotalNums'];
//        $between_rows = $endIndex-$startIndex;
//        $between_rows = $between_rows ?? 1;
        $between_seconds = DateOperation::sencods_between_time($endImportTime,$startImprtTime);
        $between_seconds = $between_seconds ?? 1;
        $averageTime = $between_seconds/$endIndex;
        $balance_import_nums = $maxlength - $endIndex;
        $balance_import_nums = $balance_import_nums ?? 0;
        $balance_time = intval($averageTime * $balance_import_nums);
        $balance_time = ($balance_time <= 0 && $balance_import_nums >0) ? 1 : $balance_time;
        $hours = intval($balance_time/3600);
        $minutes = intval(($balance_time - intval($balance_time/3600) * 3600)/60);
        $seconds = $balance_time-(60 * $minutes + $hours * 3600);
        $content = getVarFixedLabel('ImageImportTimeTip',$maxlength);
        $content .= '<span>'.$hours.':'.$minutes.':'.$seconds.'</span>';
        unset($hours,$minutes,$seconds,$balance_time,$balance_import_nums,$averageTime,$between_seconds,$maxlength,$startImprtTime,$endImportTime,$module);
        return $content;

    }

    //设置日志 插入数据
    public function setOperationLog($duplicatefield)
    {
        global $current_user,$adb;
        $module = $this->module;
        $startDateTime = date("Y-m-d H:i:s");
        $insert_sql = 'INSERT into ld_crmlog_import(userid,`status`,module,importtype,duplicatefield,starttime,importfilename) value(?,?,?,?,?,?,?)';
        $adb->pquery($insert_sql, array($current_user->id,'INPROGRESS',$module,'',$duplicatefield,$startDateTime,''));
        $_SESSION[$module.'ImportImageInfoArr']['startDateTime'] = $startDateTime;
        $logid = $adb->getLastInsertID();
        $_SESSION[$module.'ImportImageInfoArr']['logid'] = $logid;
        unset($insert_sql,$module);
        return $logid;
    }

    //更新日志内容
    public function updateImportLog($status)
    {
        global $adb;
        $logid = $_SESSION[$this->module.'ImportImageInfoArr']['logid'];
        $LogFilePath = $_SESSION[$this->module.'ImportImageInfoArr']['ImportImageLogFilePath'];
        if ($status == 'yes') {
            $status = 'COMPLETED';
            $successNums = $_SESSION[$this->module.'ImportImageInfoArr']['successNums'];
            $failNums = $_SESSION[$this->module.'ImportImageInfoArr']['errorNums'];
        }else if ($status == 'no'){
            $status = 'ImportFailed';
            $successNums = 0;
            $failNums = 0;
        }
        $update_sql = 'UPDATE ld_crmlog_import SET `status` = ?,importresult = ?,importnum = ?,failedimportnum = ?,finishtime = ? where id = ?';
        $adb->pquery($update_sql, array($status,$LogFilePath,$successNums,$failNums,date("Y-m-d H:i:s"),$logid));
        unset($update_sql,$status,$LogFilePath,$successNums,$failNums,$logid);
    }

    //获取日志文件路径
    public function getLogFilePath()
    {
        global $current_user;
        $module = $this->module;
        if (isset($_SESSION[$module.'ImportImageInfoArr']['ImportImageLogFilePath']) && $_SESSION[$module.'ImportImageInfoArr']['ImportImageLogFilePath'] != ''){
            return $_SESSION[$module.'ImportImageInfoArr']['ImportImageLogFilePath'];
        }
        $timestr = strtotime($_SESSION[$module.'ImportImageInfoArr']['startDateTime']);
        $filePath='storage/importImagelog_'.$module.'_'.$current_user->id.'_'.$timestr.'.txt';
        $_SESSION[$module.'ImportImageInfoArr']['ImportImageLogFilePath'] = $filePath;
        unset($module);
        return $filePath;
    }


    //导入产品的seesion初始化
    public function initImportImageSession()
    {
        $module = $this->module;
        $_SESSION[$module.'ImportImageInfoArr'] = [];
        $_SESSION[$module.'ImportImageInfoArr']['imagefield'] = '';
        $_SESSION[$module.'ImportImageInfoArr']['nameformatfield'] = '';
        $_SESSION[$module.'ImportImageInfoArr']['nameformatexpload'] = '';
        $_SESSION[$module.'ImportImageInfoArr']['importImageArr'] =[];
        $_SESSION[$module.'ImportImageInfoArr']['FileNameRecord'] = [];
        $_SESSION[$module.'ImportImageInfoArr']['FileNameIndex'] = [];
        $_SESSION[$module.'ImportImageInfoArr']['logid'] = '';
        $_SESSION[$module.'ImportImageInfoArr']['ImportImageLogFilePath'] = '';
        $_SESSION[$module.'ImportImageInfoArr']['successNums'] = 0;
        $_SESSION[$module.'ImportImageInfoArr']['errorNums'] = 0;
        $_SESSION[$module.'ImportImageInfoArr']['errorFile'] = [];
        $_SESSION[$module.'ImportImageInfoArr']['imageTotalNums'] = 0;
        $_SESSION[$module.'ImportImageInfoArr']['startDateTime'] = '';

        $_SESSION[$module.'ImportImageInfoArr']['allContent'] = [];
        $_SESSION[$module.'ImportImageInfoArr']['errorContent'] = [];
    }


    //导入结束
    public function finsihImportImage()
    {
        $module = $this->module;
        //日志写入
        $allContent = $_SESSION[$module.'ImportImageInfoArr']['allContent'];
        $logFilePath = $this->getLogFilePath();
        $filehandler=fopen($logFilePath,'w+');
        fwrite($filehandler,implode("\r\n",$allContent));
        fclose($filehandler);
        $this->updateImportLog('yes');

        $arr['successNums'] = $_SESSION[$module.'ImportImageInfoArr']['successNums'];
        $arr['errorNums'] = $_SESSION[$module.'ImportImageInfoArr']['errorNums'];
        if ($arr['errorNums'] > 0){
            $arr['logFilePath'] = $logFilePath;
            $arr['timestr'] =  strtotime($_SESSION[$module.'ImportImageInfoArr']['startDateTime']);
        }
        //清空产品导入的Session
        $_SESSION[$module.'ImportImageInfoArr'] = [];
        unset($_SESSION[$module.'ImportImageInfoArr']);

        return $arr;

    }

}




?>