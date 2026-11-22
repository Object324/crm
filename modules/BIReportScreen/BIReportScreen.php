<?php

class BIReportScreen
{
    /** @var string 文件保存的指定目录路径 */
    public  $directory ;
    /** @var string 后缀名 */
    public  $extensionName = '.json' ;
    /** @var string 图片后缀 */
    public  $indexImgExt = '_indexImg.png' ;
    /** @var string 模块名 */
    public  $module = 'BIReportScreen';
    /** @var string 分配类别名 */
    public  $scopeLabel = 'BIReportScreen_Project';

    public function __construct()
    {
        $this->directory = globalStatic::$root_directory . 'dataCache/BIReportScreen/';
    }

    public function getProjectList() {
        global $adb,$current_user;
        $curUserId = $current_user->id;
        $limit = (int) $_REQUEST['limit'];
        $page = $_REQUEST['page'];
        $search = isset($_REQUEST['search']) && empty($_REQUEST['search']) ? '' : $_REQUEST['search'];
        $start = (int)($page - 1) * $limit;
        $this->delUnSaveProject();
        $scopeLeftJoinSql = $this->getScopeLeftJoinSql();
        $list = [];
        $sql = "select bi.*,r.scopeid,u.last_name,um.last_name AS modifyname from ld_bireportscreen bi
            left join ( $scopeLeftJoinSql ) r on r.viewid = bi.project_id
            left join ld_users u on bi.smcreatorid = u.id
            left join ld_users um on bi.modifiedby = um.id 
            where bi.deleted = 0 and (bi.scope = 'all' or bi.smcreatorid = ? or find_in_set(?,r.scopeid))
            and project_name like '%$search%'
            order by bi.createdtime desc
            limit ?,?;";
        $result = $adb->pquery($sql,[$curUserId, $curUserId, $start, $limit]);
        $num = $adb->num_rows($result);
        if($num > 0) {
            for ($i = 0; $i < $num; $i++) {
                $rowInfo = $adb->query_result_rowdata($result,$i);
                array_push($list,[
                    "id"=> $rowInfo['project_id'],
                    "projectName"=> $rowInfo['project_name'],
                    "state"=> -1,
                    "createTime"=> $rowInfo['createdtime'],
                    "createUserId"=> $rowInfo['smcreatorid'],
                    "createUserName"=> $rowInfo['last_name'],
                    "isDelete"=> -1,
                    "indexImage"=> $rowInfo['index_image'],
                    "remarks"=> $rowInfo['remarks'],
                    "scope"=> $rowInfo['scope'],
                    "scopeid"=> $rowInfo['scopeid'],
                    "modifiedby"=> $rowInfo['modifiedby'],
                    "modifyName"=> $rowInfo['modifyname'],
                    "modifyTime"=> $rowInfo['modifiedtime'],
                ]);
            }
        }
        $countSql = "select count(1) as bi_num from ld_bireportscreen bi
            left join ( $scopeLeftJoinSql ) r on r.viewid = bi.project_id
            where bi.deleted = 0 and (bi.scope = 'all' or bi.smcreatorid = ? or find_in_set(?,r.scopeid))";
        $count = $adb->query_result($adb->pquery($countSql,[$curUserId, $curUserId]),0,'bi_num');
        ConvertToJsonBIReprotScreen(200,$list,'success',[
            'count' => $count
        ]);
    }
    /** 删除未保存的，即创建时间为bull */
    public function delUnSaveProject(){
        global $adb;
        $sql = "delete from ld_bireportscreen where ifnull(createdtime,0) = 0;";
        $adb->pquery($sql);
    }
    /** 获取连接ld_related_scope的sql */
    public function getScopeLeftJoinSql(){
        $module = $this->module;
        $scopeLabel = $this->scopeLabel;
        return "select GROUP_CONCAT(relatedid) as scopeid,r.viewid 
                from ld_related_scope r 
                where r.modulename = '$module' and r.type = '$scopeLabel'
                group by viewid ";
    }
    /** 创建时插入一条数据，获取最新id，创建时间字段不处理，标识为保存 */
    public function createProject() {
        global $adb, $current_user;
        $indexImage = $_REQUEST['indexImage'];
        $remarks = $_REQUEST['remarks'];
        $projectName = $_REQUEST['projectName'];
        //$createTime = date('Y-m-d H:i:s');
        $createUserId = $current_user->id;

        $sql = "select ifnull(max(id), 0) + 1 as project_id from ld_bireportscreen";
        $result = $adb->pquery($sql,[]);
        $projectId = $adb->query_result($result,0,'project_id');

        $insertSql = "insert into ld_bireportscreen(project_id, project_name, smcreatorid, index_image, remarks) VALUES (?,?,?,?,?);";
        $adb->pquery($insertSql,[$projectId, $projectName, $createUserId, $indexImage, $remarks]);
        ConvertToJsonBIReprotScreen(200,[
            "id"=> 'New_'.$projectId,
        ],'success');
    }

    public function getProjectData() {
        global $adb;
        $projectId = $_REQUEST['projectId'];
        $file = $projectId.$this->extensionName;
        $content = file_get_contents($this->directory . $file);
        $scopeLeftJoinSql = $this->getScopeLeftJoinSql();
        $sql = "select bi.*,r.scopeid,u.last_name,um.last_name AS modifyname from ld_bireportscreen bi
            left join ( $scopeLeftJoinSql ) r on r.viewid = bi.project_id
            left join ld_users u on bi.smcreatorid = u.id 
            left join ld_users um on bi.modifiedby = um.id 
            where bi.project_id = ?;";

        $result = $adb->pquery($sql,[$projectId]);
        if($adb->num_rows($result) > 0){
            $rowInfo = $adb->query_result_rowdata($result,0);
        }
        ConvertToJsonBIReprotScreen(200,[
            "content"=> $content,
            "id"=> $projectId,
            "projectName"=> $rowInfo['project_name'],
            "state"=> -1,
            "createTime"=> $rowInfo['createdtime'],
            "createUserId"=> $rowInfo['smcreatorid'],
            "createUserName"=> $rowInfo['last_name'],
            "isDelete"=> -1,
            "indexImage"=> $rowInfo['index_image'],
            "remarks"=> $rowInfo['remarks'],
            "scope"=> $rowInfo['scope'],
            "scopeid"=> $rowInfo['scopeid'],
            "modifiedby"=> $rowInfo['modifiedby'],
            "modifyName"=> $rowInfo['modifyname'],
            "modifyTime"=> $rowInfo['modifiedtime'],
        ],'success');
    }

    public function SqlParse() {
        global $adb;
        $sql = $this->sqlDecode();
        $matches = $this->getSqlScopeMatches($sql);
        $scopeModuleArr = array_unique($matches[1]);
        foreach ($scopeModuleArr as $index => $scopeModule) {
            if(!vtlib_isModuleActive($scopeModule)) {
                ConvertTojsonString(500,[],"SQL模块错误！ 错误模块名：$scopeModule");
            }
        }
        require_once globalStatic::$root_directory. 'sqlparser/vendor/autoload.php';
        $parser = new PhpMyAdmin\SqlParser\Parser($sql);

        if(sizeof($parser->statements)<=0)
        {
            ConvertTojsonString(500,[],'不符合条件的sql！');
        }
        $parserArr = $parser->statements;
        $columnnames = [];
        $is_procedure = 'no';
        $is_select = 'no';
        foreach($parserArr as $parserOne){
            //判断是不是查询语句 要每个都判断 不放过任何一个不是select的语句
            if($parserOne instanceof PhpMyAdmin\SqlParser\Statements\SelectStatement)
            {
                $is_select = 'yes';
            } else if($parserOne instanceof PhpMyAdmin\SqlParser\Statements\CallStatement) {
                //存储过程
                $is_procedure = 'yes';
            }else{
                ConvertTojsonString(500,[],'不是查询语句！');die;
            }
        }
        $columnsArr = [];
        //查询语句
        if($is_select=='yes'){
            //解析SQL，去最后一个sql
            $expr = end($parserArr)->expr;
            foreach($expr as $k=>$columninfo){
                $alias = $columninfo->alias;
                $column = $columninfo->column;
                if(!empty($alias)){
                    $columnnames[] = $alias;
                }else{
                    $columnnames[] = $column;
                }
                $alias = empty($alias)?$column:$alias;

                $columnsArr[] = $alias;
            }
        }
        //存储过程语句
        if($is_procedure=='yes'){
            $pro_res = $adb->pquery($sql);
            $columnnames = $adb->getFieldsArray($pro_res);
            foreach($columnnames as $k=>$column2){
                $columnsArr[] = $column2;
            }
        }
        ConvertToJsonBIReprotScreen(200,$columnsArr,'SQL yes');
    }

    public function getChartData() {
        global $adb;
        $sql = $this->sqlDecode();
        // 查看范围变量替换
        crm_load_class_file('cls_ScopOfAuthority','modules/lingdang/cls_Report');
        $matches = $this->getSqlScopeMatches($sql);
        $scopeModuleArr = array_unique($matches[1]);
        foreach ($scopeModuleArr as $index => $scopeModule) {
            $ModuleScopeObj = new cls_ScopOfAuthority($adb, $scopeModule);
            $scopeSql = $ModuleScopeObj->getCurUserScopeIds();
            $sql = str_replace($matches[0][$index],$scopeSql,$sql);
        }
        $result = $adb->pquery($sql);

        $resDataType = $_REQUEST['ResDataType'];
        $funName = "getChartData_".$resDataType;
        $res = $this->$funName($result,$_REQUEST['FieldMap']);
        ConvertToJsonBIReprotScreen(200,$res,'success');
    }

    /** SQL解密 */
    public function sqlDecode() {
        $sql = $_REQUEST['sql'];
        $isEncrypt = $_REQUEST['isEncrypt'];
        if($isEncrypt === 'yes') {
            $cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
            $sql = $cls_AESencryptionbykeyobj->getdecryption($sql);
        }
        else if ($isEncrypt === 'base64') {
            $sql = base64_decode($sql);
        }
        return $sql;
    }

    public function getSqlScopeMatches($sql) {
        $matches = null;
        $pattern = '/\{data_range\[\"(.*)\"\]\}/';
        $varNum = preg_match_all($pattern, $sql, $matches);
        return $matches;
    }

    /** 一个字段，直接返回SQL查询值 */
    public function getChartData_value($result,$fieldOption) {
        global $adb;
        $field = $fieldOption[0]['field'];
        $res = null;
        for ($i = 0; $i < $adb->num_rows($result); $i ++) {
            $rowData = [];
            $fieldVal = $adb->query_result($result,$i,$field);
            $res = $fieldVal;
        }
        return $res;
    }

    public function getChartData_dataSet($result,$fieldOption) {
        global $adb;
        $res = [
            "dimensions" => [],
            "source" => [],
        ];
        foreach ($fieldOption as $item) {
            $res['dimensions'][] = $item['field'];
        }
        for ($i = 0; $i < $adb->num_rows($result); $i ++) {
            $rowData = [];
            foreach ($res['dimensions'] as $field) {
                $fieldVal = $adb->query_result($result,$i,$field);
                $rowData[$field] = $fieldVal;
            }
            $res['source'][] = $rowData;
        }
        return $res;
    }

    public function getChartData_map($result,$fieldOption) {
        crm_load_class_file('EchartSetting','modules/CustomEcharts');
        global $adb;
        $res = [
            "map" => [],
        ];
        for ($i = 0; $i < $adb->num_rows($result); $i ++) {
            $dataItem = [];
            foreach ($fieldOption as $item) {
                $key = $item['key'];
                $dataItem[$key] = $adb->query_result($result,$i,$item['field']);
//                if($key === 'province') {
//                    $dataItem[$key] = EchartSetting::prvinceNameChange($dataItem[$key]);
//                }
            }
            $res['map'][] = $dataItem;
        }
        return $res;
    }

    public function getChartData_table($result,$fieldOption) {
        global $adb;
        $res = [
            "dimensions" => [],
            "source" => [],
        ];
        foreach ($fieldOption as $item) {
            $res["dimensions"][] = [
                "title"=> $item['label'],
                "key"=> $item['field'],
            ];
        }
        for ($i = 0; $i < $adb->num_rows($result); $i ++) {
            $dataItem = [
                "key" => $i,
            ];
            foreach ($fieldOption as $item) {
                $dataItem[$item['field']] = $adb->query_result($result,$i,$item['field']);
            }
            $res['source'][] = $dataItem;
        }
        return $res;
    }

    public function saveProject() {
        $content = $_REQUEST['content'];
        $projectInfo = json_decode($content,true);
        $projectId = $_REQUEST['projectId'];
        if(strpos($projectId,'New_') !== false) {
            $projectId = explode('_',$projectId)[1];
        }

        if(!empty($projectId)){
            $projectName = $projectInfo['editCanvasConfig']['projectName'];
            $indexImage = $projectId . $this->indexImgExt;
            $this->duplicationJudge($projectName, $projectId);
            if (!is_dir($this->directory)) {
                mkdir($this->directory,0777);
            }
            $file = $projectId . $this->extensionName;
            $flag = file_put_contents($this->directory . $file, $content);
            if($flag === false)
                ConvertToJsonBIReprotScreen(500,[],'failed');
            global $adb, $current_user;
            $updateSql = "update ld_bireportscreen 
                set project_name=?, remarks=?, index_image=?, createdtime=NOW(), scope= 'all', modifiedby = ?, modifiedtime=NOW() where project_id = ?;";
            $adb->pquery($updateSql,[$projectName,'',$indexImage,$current_user->id,$projectId]);

            ConvertToJsonBIReprotScreen(200,[
                "id"=>$projectId,
                "projectName"=>$projectName,
                "indexImage"=> $indexImage,
                "remarks"=> "",
            ],'success');
        }
        ConvertToJsonBIReprotScreen(500,[],'failed');
    }

    public function saveProjectImg() {
        if (isset($_FILES['index_image'])) {
            $uploadFile = $_FILES['index_image'];
            $fielName = basename($uploadFile['name']);
            $tmpFielName = $uploadFile['tmp_name'];

            if (is_uploaded_file($tmpFielName)) {
                // 检查文件大小
                if ($uploadFile['size'] > 1000000) {
                    ConvertToJsonBIReprotScreen(500,[],'failed: upload file oversize');
                }

                // 检查目标目录是否存在
                if (!is_dir($this->directory)) {
                    mkdir($this->directory);
                }

                $projectId = explode('.png',$fielName)[0];
                if(strpos($projectId,'New_') !== false) {
                    $projectId = explode('_',$projectId)[1];
                }
                $fielName = $projectId . $this->indexImgExt;
                $uploadDirFile = $this->directory . $fielName;
                // 检查目标文件是否存在
                if (file_exists($uploadDirFile)) {
                    unlink($uploadDirFile);
                }

                // 移动文件
                if (move_uploaded_file($tmpFielName, $uploadDirFile)) {
                    ConvertToJsonBIReprotScreen(200,[
                        'fileName' => $fielName,
                        'fileurl' => $fielName,
                    ],'success');
                } else {
                    ConvertToJsonBIReprotScreen(500,[],'failed: upload file move error');
                }
            } else {
                ConvertToJsonBIReprotScreen(500,[],'failed: file upload error');
            }
        } else {
            ConvertToJsonBIReprotScreen(500,[],'failed: payload no file');
        }
    }

    public function deleteProject() {
        global $adb;
        $projectId = $_REQUEST['projectId'];
        if(strpos($projectId,'New_') !== false) {
            $projectId = explode('_',$projectId)[1];
        }

        $fileArr = [
            $projectId . $this->indexImgExt,
            $projectId . $this->extensionName,
        ];
        foreach ($fileArr as $fielName) {
            $uploadDirFile = $this->directory . $fielName;
            // 检查目标文件是否存在，存在则删除
            if (file_exists($uploadDirFile)) {
                unlink($uploadDirFile);
            }
        }

        $deleteSql = "update ld_bireportscreen set deleted = 1 where project_id = ?;";
        $adb->pquery($deleteSql,[$projectId]);

        ConvertToJsonBIReprotScreen(200,[],'success');
    }

    public function projectScoped() {
        global $adb,$current_user;
        $module = $this->module;
        $scopeLabel = $this->scopeLabel;
        $projectId = $_REQUEST['projectId'];
        $scope = $_REQUEST['scope'];
        $scopeid = $_REQUEST['scopeid'];
        $nowTime = date('Y-m-d H:i:s');
        $sql = 'UPDATE ld_bireportscreen set scope = ?,modifiedby = ?,modifiedtime = ? where project_id = ?;';
        $adb->pquery($sql,array($scope,$current_user->id,$nowTime,$projectId));
        if($scope == 'all'){
            crm_load_class_file("cls_related_scope",'include/utils');
            cls_related_scope::delete_related_scope($module,$scopeLabel,$projectId);
        }else{
            crm_load_class_file("cls_related_scope",'include/utils');
            cls_related_scope::save_related_scope($module,$scopeLabel,$projectId,explode(',',$scopeid));
        }
        ConvertToJsonBIReprotScreen(200,[
            "modifyName" => $current_user->last_name,
            "modifyTime" => $nowTime,
        ],'success');
    }

    public function copyProject(){
        $projectData = $_REQUEST['projectData'];
        $projectId = $projectData['id'];
        $copyProjectName = trim($_REQUEST['projectName']);
        if(strpos($projectId,'New_') !== false) {
            $projectId = explode('_',$projectId)[1];
        }

        if(!empty($projectId)){
            $copyProjectId = $projectId.'_copy';
            global $adb, $current_user;

            $this->duplicationJudge($copyProjectName);

            $sql = "SELECT max(id) + 1 AS new_id FROM ld_bireportscreen";
            $result = $adb->pquery($sql,[]);
            if($adb->num_rows($result) > 0){
                $copyProjectId = $adb->query_result($result,0,'new_id');
            }
            $createUserId =  $current_user->id;
            $copyIndexImg = $copyProjectId.$this->indexImgExt;
            $scope = 'all';
            $flag = true;
            if (!is_dir($this->directory)) {
                mkdir($this->directory,0777);
            }
            $file = $projectId . $this->extensionName;
            $copyFile = $copyProjectId . $this->extensionName;
            $flag = $flag && copy($this->directory . $file,$this->directory . $copyFile);
            $flag = $flag && copy($this->directory . $projectId . $this->indexImgExt,$this->directory . $copyIndexImg);

            if($flag) {
                $nowTime = date('Y-m-d H:i:s');
                $copySql = "INSERT INTO ld_bireportscreen(project_id, project_name, deleted, smcreatorid, createdtime, index_image, remarks, scope, modifiedtime, modifiedby) 
                        VALUES (?,?,?,?,?,?,?,?,?,?)";
                $adb->pquery($copySql, [$copyProjectId, $copyProjectName, 0, $createUserId, $nowTime, $copyIndexImg, '', $scope, $nowTime, $createUserId]);

                ConvertToJsonBIReprotScreen(200, [
                    "id" => $copyProjectId,
                    "projectName" => $copyProjectName,
                    "indexImage" => $copyIndexImg,
                    "remarks" => "",
                    "state"=> -1,
                    "createTime"=> $nowTime,
                    "createUserId"=> $createUserId,
                    "createUserName"=> $current_user->last_name,
                    "isDelete"=> -1,
                    "scope"=> $scope,
                    "scopeid"=> '',
                    "modifyName"=> $current_user->last_name,
                    "modifyTime"=> $nowTime,
                ], 'success');
            }
        }
        ConvertToJsonBIReprotScreen(500,[],'failed');
    }

    /**
     * 重名判断
     * @param $projectName
     */
    public function duplicationJudge($projectName, $projectId = null) {
        global $adb;
        $dupSql = "SELECT id FROM ld_bireportscreen WHERE project_name = '$projectName' AND deleted = 0 AND project_id <> IFNULL($projectId,0);";
        if($adb->num_rows($adb->pquery($dupSql,[])) > 0){
            ConvertToJsonBIReprotScreen(200,[],'Name duplication');
        }
    }

    /**
     * 更新名称
     */
    public function updateProject()
    {
        global $adb;
        $projectName = $_REQUEST['projectName'];
        $projectId = $_REQUEST['id'];
        $sql = "UPDATE ld_bireportscreen SET project_name = '$projectName' WHERE project_id = $projectId;";
        $adb->pquery($sql,[]);
        ConvertToJsonBIReprotScreen(200,[],'success');
    }
}

?>