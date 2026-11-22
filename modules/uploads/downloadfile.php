<?php
/********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 ********************************************************************************/

global $adb;
global $fileId, $default_charset, $app_strings;

ob_get_clean();

$attachmentsid = $_REQUEST['fileid'];
$entityid = $_REQUEST['entityid'];

$returnmodule = $_REQUEST['return_module'];
$focus = CRMEntity::getInstance($returnmodule);
$deletecheck = false;
if (!empty($entityid)) {
    $deletecheck = $adb->pquery("SELECT deleted FROM $focus->table_name WHERE $focus->table_index = ?", array($entityid));
}
if (!empty($deletecheck) && $adb->query_result($deletecheck, 0, 'deleted') == 1) {

    echo getFixedLabel('RECORDDELETED');

} else {
    if(isset($_REQUEST['return_module'])&&$_REQUEST['return_module']=='WorkReportList'){
        // 工作汇报列表附下载需要查询ld_workachments表
        $dbQuery = "select `name`,path,newfile_name,storage_location,cloud_path,`size` from ld_workachments where achmentid=? AND type='att'";
        $result = $adb->pquery($dbQuery, array($attachmentsid)) or die("Couldn't get file list");//dump($result);

    }else{
        $dbQuery = "SELECT * FROM ld_attachments WHERE attachmentsid = ?";
        //edit:xll 2023/06/30 XUQIU1000357 单据分录定制，增加“附件”字段类型（分录附件字段的预览下载次数在表ld_fileoperationlog中增加了lineitem_id字段，非分录默认为零）
        $lineitem_id = (empty($_REQUEST['lineitem_id']) || $_REQUEST['lineitem_id'] == '') ? 0 : $_REQUEST['lineitem_id'];
        if($lineitem_id != 0){
            $dbQuery = "SELECT * FROM ld_detailattachments WHERE id = ?";
        }

        $result = $adb->pquery($dbQuery, array($attachmentsid)) or die("Couldn't get file list");//dump($result);
    }
    if ($adb->num_rows($result) == 1) {
        $fileType = @$adb->query_result($result, 0, "type");
        $name = @$adb->query_result($result, 0, "name");
        $filepath = @$adb->query_result($result, 0, "path");
        $name = html_entity_decode($name, ENT_QUOTES, $default_charset);
        $name=ChangeUploadFilename($name);
        $newfile_name = html_entity_decode(@$adb->query_result($result, 0, "newfile_name"), ENT_QUOTES, $default_charset);
        //$saved_filename = $attachmentsid."_".$name;
        $saved_filename = $newfile_name;
        $downloadfilename=$name;
        //editor:gyq_169 reason:腾讯云COS文件上传预览   2020/3/2 17:07
        $cloud_path = @$adb->query_result($result, 0, "cloud_path");
        $storage_location = @$adb->query_result($result, 0, "storage_location");

        // @edit:liushuai,2021-04-08,reason:【ID1001517】附件增加下载和预览次数及操作日志
        $adb->pquery('insert into ld_fileoperationlog(tabid,crmid,lineitem_id,newfile_name,operator,operating_type,operating_time) values(?,?,?,?,?,?,?)', array(getTabid($_REQUEST['return_module']),$entityid,$lineitem_id,$newfile_name, $current_user->id, 'download', date("Y-m-d H:i:s", time())));
        // 知识管理 , 下载附件增加"下载次数"字段
        if($returnmodule == 'Documents'){
            $sql = "SELECT filedownloadcount from ld_notes where notesid= ?";
            $download_count = intval($adb->query_result($adb->pquery($sql,array($entityid)),0,'filedownloadcount')) + 1;
            if(!empty($download_count) && !empty($entityid)){
                $sql="UPDATE ld_notes set filedownloadcount= ? where notesid= ?";
                $adb->pquery($sql,array($download_count,$entityid));
            }
            unset($download_count);
        }
        /*
            edit:andrew
            date:20145019
            reason:0008938: 
            新增附件为中文word打开为中文
            edit:can 
            reason: 11035: 知识管理上传文件报异常
         */
        if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix') {
            //获取系统类型，如果是非windows系统则不用修改编码格式
            //$targetFile=$name;
        } else{
            $saved_filename = mb_convert_encoding($saved_filename, 'gbk', 'UTF-8');
            $downloadfilename=mb_convert_encoding($downloadfilename, 'gbk', 'UTF-8');
        }

        if($storage_location=='cos'){
            //editor:gyq_169 reason:下载云端文件   2020/3/3 16:49
            
            require_once globalStatic::$root_directory.'appCommon/appCommon.php';
            $cloud_path = html_entity_decode($cloud_path, ENT_QUOTES, $default_charset);
            $rigin_cloud_path=$cloud_path;
            
            $filepath = $cloud_path;
            //edit:can 20200820 042442: (61mis.com/kfbcrm)客户问题（四方光电）附件管理模块>选择编号为“ATT99”单据详情界面：附件名称含“+不能法预览和下载（需要补丁）
            
           $paths=explode("/",$cloud_path);
            $cloud_path='';
            for($i=0;$i<sizeof($paths)-1;$i++)
            {
                $cloud_path.=$paths[$i].'/';
            }
           $cloud_path.=urlencode($paths[$i]);
       
            $header_response = get_headers($cloud_path, 1);
            if(strpos( $header_response[0], "404" ) !== false)
            {
                //edit:can 2020-08-3142528: （https://kehu001.com/weixin/kh36798/ [^]）客户问题（茂睿芯），合同订单模块>选择编号为“ZDV20200826004”进入单据详情界面：附件点击“下载”，自动新增页签显示空白（可以预览）
                
                //订单 (茂睿芯）8-26_1598447697000_270.pdf
                $header_response = get_headers($rigin_cloud_path, 1);
                $cloud_path=$rigin_cloud_path;
            }
           
            if ( strpos( $header_response[0], "404" ) !== false ){
                exit('文件丢失1');
            }
          
                $_GET['temp_saved_filename'] = $saved_filename;
            $_GET['temp_saved_filename'] =$downloadfilename;
                if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix') {
                        //获取系统类型，如果是非windows系统则不用修改编码格式
                        //$targetFile=$name;
                    } else
                        $saved_filename = mb_convert_encoding($saved_filename, 'UTF-8', 'gbk');

                downloadCloudFile($cloud_path);
            
             ob_flush();
            ob_clean();
           
            exit;
        }
        elseif($storage_location=='awsserver'){//S3根据key下载文件
            crm_load_class_file('AWS', 'include');
            $aws = AWS::getInstance();
            $s3FilePath = $filepath.$saved_filename;//aws key
            @ob_clean();
            @ob_start();
            $response = $aws->outputFile($s3FilePath,$downloadfilename);
            if (!empty($response['Body'])) {
                header('Content-Type: application/octet-stream');
                header('Content-Disposition: attachment; filename="' . $downloadfilename . '"');
                echo $response['Body'];
                @ob_end_flush();
                exit;
            }else{
                echo $app_strings['LBL_RECORD_NOT_FOUND'];
            }

        }
        else {
            $isconvert='yes';
            if (file_exists($filepath . $saved_filename)) {
                $disk_file_size = filesize($filepath . $saved_filename);
            }
            else if (file_exists($filepath . $newfile_name)) {
                $isconvert='no';
                $disk_file_size = filesize($filepath . $newfile_name);
            }
            
             else {

                $lastfixs = explode(".", $name);
                $lastfix = $lastfixs[count($lastfixs) - 1];
                $saved_filename = $attachmentsid . "_1." . $lastfix;
                if (file_exists($filepath . $saved_filename))
                    $disk_file_size = filesize($filepath . $saved_filename);
                else {
                    /**
                     * edit:can
                     * date:20140211
                     * reason:新需求：上传文件名称在服务器不变；
                     */
                    if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix') {
                        //获取系统类型，如果是非windows系统则不用修改编码格式
                        //$targetFile=$name;
                    } else
                        $saved_filename = mb_convert_encoding($saved_filename, 'gbk', 'UTF-8');
                    //$saved_filename=iconv ( 'UTF-8', 'GBK', $name );
                    $disk_file_size = filesize($filepath . $saved_filename);
                }
            }

            $pops = explode('.', $newfile_name);
            $extname = strtolower(array_pop($pops));

            if ($extname == 'jpg' || $extname == 'jpeg' || $extname == 'gif'
                || $extname == 'txt' || $extname == 'png' || $extname == 'bmp' || $extname == 'ico'
                || $extname == 'dwg' || $extname == 'xml') {

            } else {
                $sizemb = $disk_file_size / 1024 / 1024;
                //edit:can 2020-11-28 43496: （http://192.144.180.107:85/crm [^]）（华田信科）商机立项HTLX20201127-0239这个订单中附件无法下载
                if ($sizemb > 50) {
                    //zkt 20220909 BUG0056286知识管理单据号：DOC25附加下载报错，详细看附件
                    header("Location:" . $filepath . $newfile_name);
                    exit();
                    /*if($isconvert=='yes')
                        header("Location:" . $filepath . $saved_filename);
                    else
                        header("Location:" . $filepath . $newfile_name);
//                    header("Location:" . $filepath . $name);

                    exit();*/
                }
            }
            //$fileUrl = 'http://www.51mis.com/kfbcrm/dataCache/test/logo/login_bg.jpg';
            $diskfilesize = $disk_file_size + ($disk_file_size % 1024);
            if($isconvert=='yes')
                $fileContent = fread(fopen($filepath . $saved_filename, "r"), $diskfilesize);
            else
                $fileContent = fread(fopen($filepath . $newfile_name, "r"), $diskfilesize);
            header("Content-type: $fileType");
            header("Pragma: public");
            header("Cache-Control: private");
            if (stripos($_SERVER['HTTP_USER_AGENT'], 'edge') !== false)//edge浏览器(win10自带)
                header("Content-Disposition: attachment; filename=" . urlencode($name));
            else {
                if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix' || strtolower(PHP_OS) == 'macos') {
                    header("Content-Disposition: attachment; filename=" . $name);
                } else {
                    if($isconvert=='yes')
                        header("Content-Disposition: attachment; filename=" . mb_convert_encoding($name, 'gbk', 'UTF-8'));
                    else
                        header("Content-Disposition: attachment; filename=" . $name);
                }
            }
            //header("Content-Disposition: attachment; filename=\"".$name."\"");
            header("Content-Description: PHP Generated Data");
            header('Content-Encoding: none');
            header("Content-Transfer-Encoding: binary");
            //**********************************
            /*
            edit:can
            date:20130424
            reason:0003461: "知识管理"上传word作为附件后，再下载，下载完成后，无法打开，希望修改。
            */
            ob_clean();
            flush();
            //*********************************
            echo $fileContent;
        }

    } else {
        echo $app_strings['LBL_RECORD_NOT_FOUND'];
    }
}

?>