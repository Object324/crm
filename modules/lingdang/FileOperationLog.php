<?php
global $adb, $current_user;
//$record = $_REQUEST['record'];
$fileId = $_REQUEST['fileId'];
$frommodule = $_REQUEST['frommodule'];
$operating_type = $_REQUEST['operating_type'];//download   preview

if (!empty($frommodule) && isset($_REQUEST['fileId'])) {
    $tabid = getTabid($frommodule);

    //获取newfile_name
    if (strtolower($frommodule) == 'attachment') {
        $query = "SELECT newfile_name from ld_attachmentsforbillsdetails WHERE id = ?";
    } else {
        $query = "SELECT newfile_name FROM ld_attachments WHERE attachmentsid = ?";
    }
    //edit: xll XUQIU1000357 单据分录定制，增加“附件”字段类型（分录附件操作日志）
    $lineitem_id = (empty($_REQUEST['lineitem_id']) || $_REQUEST['lineitem_id'] == '') ? 0 : $_REQUEST['lineitem_id'];
    if($lineitem_id != 0){
        $query = "SELECT type,size,name as filename,newfile_name,path,storage_location,cloud_path FROM ld_detailattachments WHERE id = ?";
    }
    $result = $adb->pquery($query, array($fileId)) or die("Couldn't get file list");

    $newfile_name = '';
    if ($adb->num_rows($result) == 1) {
        $newfile_name = html_entity_decode(@$adb->query_result($result, 0, "newfile_name"), ENT_QUOTES, $default_charset);
    }

    //由于单据详情的附件区块 编辑保存后已存在的附件主键会改变，但newfile_name不会改变，因此需要用newfile_name去匹配
    $select = "select ld_users.last_name,ld_users.wx_userid,log.* from ld_fileoperationlog as log inner join ld_users on ld_users.id=log.operator ";
    $where = "";
    if (isset($_REQUEST['operator']) && $_REQUEST['operator'] > 0) {
        $where = " and operator = " . intval($_REQUEST['operator']);
    }
    //查看下载日志
    if ($operating_type == 'download') {
        $arr['title'] = getFixedLabel('DownloadOperationLog');
        if (IsDownLoadProfile('', $frommodule) == 'yes' && IsFileReadHistoryProfile('', $frommodule) == 'yes') {
            $sql = $select . " where log.newfile_name=? and operating_type = 'download' and tabid = ? and lineitem_id = ?" . $where . " order by operating_time desc";
        } else {
            exit('No View Permission');
        }

    } elseif ($operating_type == 'preview') {
        $arr['title'] = getFixedLabel('PreviewOperationLog');;
        if (IsPreviewProfile('', $frommodule) == 'yes' && IsFileReadHistoryProfile('', $frommodule) == 'yes') {
            $sql = $select . " where log.newfile_name=? and operating_type = 'preview' and tabid = ? and lineitem_id = ?" . $where . " order by operating_time desc";
        } else {
            exit('No View Permission');
        }
    } else {
        exit('operating_type error');
    }
//echo $newfile_name;echo $tabid;dump($sql);
    //edit: xll XUQIU1000357 单据分录定制，增加“附件”字段类型（分录附件操作日志,非分录附件的$lineitem_id为零）
    $result = $adb->pquery($sql, array($newfile_name, $tabid, $lineitem_id));
    $rows = $adb->num_rows($result);
    if ($rows > 0) {
        for ($i = 0; $i < $rows; $i++) {
            $operator = $adb->query_result($result, $i, "operator");
            $operating_time = $adb->query_result($result, $i, "operating_time");

            $wx_userid = $adb->query_result($result, $i, 'wx_userid');
            $username = $adb->query_result($result, $i, 'last_name');
            $userobj = new Users();
            $userobj->wx_userid = $wx_userid;
            $userobj->last_name = $username;
            $username = getUserlastName($userobj);

            $logs[$operator][] = array("operator" => $operator, "username" => $username, "operating_time" => $operating_time, "times" => '');//第一条显示全部列头数据，其余的只显示时间

        }
        foreach ($logs as $key => $val) {
            $logs[$key][0]['times'] = count($logs[$key]);
        }
    } else {
        $logs = '';
    }
    $smarty = new lingdangCRM_Smarty;
    $smarty->assign('LOGS', $logs);
    $arr['logs'] = $logs; //仅用来查看返回值

//下拉框选择选择操作人时
    if (isset($_REQUEST['ajax']) && $_REQUEST['ajax'] == 'yes') {
        $str = $smarty->fetch("FileOperationLogDetail.tpl");
        $_REQUEST['diony'] = 'diony';
        $arr['content'] = $str;
        ConvertTojsonString(1, $arr, 'success');
    }


//操作人下拉框列表
    $tmp_result = $adb->pquery("SELECT ld_users.last_name,ld_users.wx_userid,log.operator FROM ld_fileoperationlog AS log INNER JOIN ld_users ON ld_users.id = log.operator WHERE log.newfile_name=? AND operating_type = ? GROUP BY operator ORDER BY operating_time DESC", array($newfile_name, $operating_type));
    $operator_list = [];
    if ($adb->num_rows($tmp_result) > 0) {
        for ($i = 0; $i < $adb->num_rows($tmp_result); $i++) {
            $operator = $adb->query_result($tmp_result, $i, "operator");

            $wx_userid = $adb->query_result($tmp_result, $i, 'wx_userid');
            $username = $adb->query_result($tmp_result, $i, 'last_name');
            $userobj = new Users();
            $userobj->wx_userid = $wx_userid;
            $userobj->last_name = $username;
            $username = getUserlastName($userobj);
            $operator_list[$operator] = $username;
        }
    }

//下拉框选择查看某一操作人日志时会用到相关参数
    $smarty->assign('fileId', $fileId);
    $smarty->assign('frommodule', $frommodule);
    $smarty->assign('operating_type', $operating_type);
    $smarty->assign('operator_list', $operator_list);
    $str = $smarty->fetch("FileOperationLog.tpl");
    $_REQUEST['diony'] = 'diony';
    $arr['content'] = $str;
    $arr['oktext'] = '';
    $arr['canceltext'] = '';
    ConvertTojsonString(1, $arr, 'success');
}
