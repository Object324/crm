<?php

class Preview_File
{
    public $FileObj; //文件信息对象，json属性
    public $fileid;
    public $type;  //文件类型
    public $size; //文件大小
    public $filename; //文件名
    public $path; //文件存放路径
    public $cloud_path; //文件云路径
    public $storage_location; //文件储存方式
    public $newfile_name; //文件在crm系统中的名字
    public $httppath; //文件全路径
    public $image_path; //图片路径
    public $filepath; //
    public $OStype; //操作系统类型
    public $default_charset;
    public $environment;
    public $login_type;
    public $frommodule;
    public $recordid;
    public $pre_type;
    public $previewfile_http_origin;
    public $previewfile_type;
    public $file_exist;

    public function __construct($FileObj)
    {
        $this->FileObj = $FileObj;
        $this->frommodule = $_REQUEST['frommodule'];
        $this->recordid = $_REQUEST['record'];
        $this->pre_type = $_REQUEST['pre_type'];
        $this->getFileMsg();
        $this->getSysMsg();
    }

    public function getSysMsg()
    {
        global $default_charset;
        require_once(globalStatic::$root_directory . "appCommon/appCommon.php");
        $installweixin = judgeCorpInfo('install_app');
        if ($installweixin) {
            $login_type = 'www';
        }
        $login_type = "pc_dingtalk";
        $this->login_type = $login_type;

        $this->OStype = strtolower(PHP_OS);
        $this->default_charset = $default_charset;
        $this->environment = $_SESSION['login_type'];
    }

    //获取文件信息
    public function getFileMsg()
    {
        $FileObj = $this->FileObj;
        $this->fileid = $FileObj['fileid'];
        $this->type = $FileObj['type'];
        $this->size = $FileObj['size'];
        $this->filename = $FileObj['filename'];
        $this->path = $FileObj['path'];
        $this->cloud_path = $FileObj['cloud_path'];
        $this->storage_location = $FileObj['storage_location'];
        $this->newfile_name = $FileObj['newfile_name'];
    }

    //duan 20231026 判断预览附件时，是否需要读取http_origin
    public function set_previewfile_http_origin($previewfile_http_origin)
    {
        $this->previewfile_http_origin = $previewfile_http_origin;
    }

    public function get_previewfile_http_origin()
    {
        return $this->previewfile_http_origin;
    }

    //duan 20231108自定义文件预览附件方式
    public function set_previewfile_type($previewfile_type)
    {
        $this->previewfile_type = $previewfile_type;
    }

    public function get_previewfile_type()
    {
        return $this->previewfile_type;
    }

    //根据文件类型选择预览方法
    public function PreviewByType()
    {
        $smarty = new lingdangCRM_Smarty;
        $file_exist = $this->Dir_File_Exist();
        if ($file_exist) {
            $httppath = $this->httppath;
            $newfile_name = $this->newfile_name;
            $fileType = $this->type;
            $image_info = getimagesize($httppath);
            $image_type='';
            if(is_array($image_info))
            $image_type = end($image_info);
            $pops = explode('.', $newfile_name);
            $extname = array_pop($pops);
            $newfiles = explode('.', strtolower($newfile_name));
            $file_lastname = $newfiles[sizeof($newfiles) - 1];
            $officeArray = ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'];    //office文件类型
            if (in_array($file_lastname, $officeArray)) {
                $fileType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            }
            if ($this->frommodule == 'CooperativeWork' || $this->frommodule == 'WorkReportList') {
                $txt_arr = ['txt', 'exe'];
                $fileType = in_array($file_lastname, $txt_arr) ? 'text/plain' : $fileType;
                $fileType = checkFileNameIsImg($newfile_name) ? 'image' : $fileType;
                $fileType = checkFileNameIsVideo($newfile_name) ? 'video' : $fileType;
                $fileType = checkFileNameIsAudio($newfile_name) ? 'audio' : $fileType;
            }

            //word xls xlss 类型
            $fileType_office = ['application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'application/msword', 'docx', 'doc', 'xlsx', 'xls', 'application/vnd.ms-excel'];

            $kkFileView = $this->PreviewBy_kkFileView($smarty);
            if(!$kkFileView) {
                if ($fileType == 'text/plain' || $fileType == 'application/octet-stream') {
                // if($fileType == 'text/plain'){
                    $this->Preview_Txt($smarty);
                } else if (!empty($image_type) || $fileType == 'image') {    //图片
                    $this->Preview_Img($smarty);
                } else if ($extname == 'ofd') {    //ofd

                } else if (strpos($fileType, 'audio') === 0) {
                    //音频文件
                    $this->Preview_Audio($smarty);
                } else if (strpos($fileType, 'video') === 0) {
                    //音频文件
                    $this->Preview_Video($smarty);
                } elseif ($fileType == 'application/pdf') {    //PDF
                    $this->Preview_PDF($smarty);
                } elseif ($fileType == 'application/vnd.openxmlformats-officedocument.presentationml.presentation') {    //ppt
                    $this->Preview_PPT($smarty);
                }
                //  && ($regop instanceof RegOp)
                elseif (in_array($fileType, $fileType_office)) {    //word xls xlss
                    $this->Preview_Office($smarty);
                } else {
                    $smarty->assign('type', 'other');
                }
            }
            if (!empty($_REQUEST['Attachment_file']) && $this->environment != $this->login_type) {
                if ($fileType == 'application/pdf' || $extname == 'ofd') {
                    ConvertTojsonString(3, [], 'ok');
                }
                else
                    ConvertTojsonString(2, [], 'ok');
            }
            else {
                if(!$kkFileView) {
                    //chj 2022/9/1 PDF预览改用PDF.js
                    if ($fileType == 'application/pdf') {
                        $file_url = $this->Preview_PDF_New($smarty);
                        if ($_REQUEST['getPDF'] === 'yes') {
                            if ($this->storage_location !== 'cos') {
                                $file_url = globalStatic::$root_directory . $this->filepath . $this->filename;
                            }
                            $this->SaveOperateLog();
                            echo file_get_contents($file_url);
                        } else {
                            $smarty->display('Preview_PDF_New.tpl');
                        }
                        die;
                    } elseif ($extname == 'ofd') {
                        //wsh 2024/6/4 XUQIU1001658 新增OFD文件预览
                        $file_url = $this->Preview_OFD($smarty);
                        $this->SaveOperateLog();
                        $smarty->assign("FILE_URL", $file_url);
                        $smarty->assign('BASE_URL', curPageURL());
                        $smarty->display("Preview_OFD.tpl");
                        die;
                    }
                }
                $this->SaveOperateLog();
                $this->Show_PreviewContent($smarty);
            }
        } else {
            //文件已丢失，请返回
            ConvertTojsonString(-1, [], getFixedLabel('THEFILEISMISSPLEASERETURN'));
        }
    }

    public function Show_PreviewContent($smarty)
    {
        global $adb;
        $frommodule = $this->frommodule;
        $recordid = $this->recordid;
        $fileid = $this->fileid;
        $filename = $this->filename;
        $pre_type = $this->pre_type;
        //图片预览或者其他文件预览都会走到这里
        if (isset($_REQUEST['is_target']) && $_REQUEST['is_target'] == 'no') { //图片视频预览特殊处理保存预览日志
            exit('预览，无需跳转，只为添加预览日志');
        }
        if (!empty($pre_type)) {
            $att_data_key[] = $fileid;
            $att_num_rows = 1;
            $att_data[$fileid] = $filename;
        } else {
            $att_query = $this->getFileListSQL();
            $att_result = $adb->pquery($att_query, array($recordid));
            $att_num_rows = $adb->num_rows($att_result);
            for ($k = 0; $k < $att_num_rows; $k++) {
                $attachmentsid = $adb->query_result($att_result, $k, 'id');
                $att_data[$attachmentsid] = $adb->query_result($att_result, $k, 'filename');
                $att_data_key[] = $attachmentsid;
            }
        }
        $pre = 0;
        foreach ($att_data_key as $key => $attachmentsid) {
            if ($attachmentsid == $fileid) {
                $pre = $key;
            }
        }
        if ($pre >= 1) {
            $smarty->assign('PRE_ATTACHID', $att_data_key[$pre - 1]);
            $smarty->assign('PRE_STAT', 'yes');
        } else {
            $smarty->assign('PRE_STAT', 'no');
        }
        if ($pre == sizeOf($att_data_key) - 1) {
            $smarty->assign('NEXT_STAT', 'no');
        } else {
            $smarty->assign('NEXT_ATTACHID', $att_data_key[$pre + 1]);
            $smarty->assign('NEXT_STAT', 'yes');
        }
        $smarty->assign('ATT_NUM_ROWS', $att_num_rows);
        $smarty->assign('ATT_DATA', $att_data);


        $smarty->assign('name', $filename);
        $replace_filename = str_replace("%", "%25", $filename);
        $replace_filename = str_replace("#", "%23", $replace_filename);
        $smarty->assign('replace_filename', $replace_filename);
        $smarty->assign('entityid', $recordid);
        $smarty->assign('fileId', $fileid);

        $smarty->assign('mode', $frommodule);
        $smarty->assign("FROMMODULE", $frommodule);


        if (empty($pre_type))
            SaveAuditlog($recordid, '预览', $filename, $frommodule);//存储附件的预览记录
        else {
            $smarty->assign('pre_type', $pre_type);
            $fileurl = $this->FileObj['fileurl'];
            $smarty->assign('filedata_url', $pre_type . $fileurl);
            $smarty->assign('storage_location', $this->storage_location);
        }

        if ($this->environment == $this->login_type) {
            //弹框预览
            $content = $smarty->fetch('preview_popup.tpl');
            $_REQUEST['diony'] = 'diony';
            $res['content'] = $content;
            $res['title'] = $filename;
            ConvertTojsonString(1, $res, 'success');
        } else {
            $smarty->display('Preview_now.tpl');
        }

        exit;
    }
    public function getFileListSQL()
    {
        $recordid = $this->recordid;
        $frommodule = $this->frommodule;
        $att_query = '';
        if (strtolower($frommodule) == 'attachment') {
            $att_query = "select id,ld_attachmentsforbillsdetails.filename from ld_attachmentsforbills 
                    LEFT JOIN ld_attachmentsforbillsdetails on ld_attachmentsforbillsdetails.attachmentsid = ld_attachmentsforbills.attachmentsid 
                    where ld_attachmentsforbills.attachmentsid = ?";
        } else if ($frommodule == 'CooperativeWork' || $this->frommodule == 'WorkReportList') {
            //edit: xll 2023/07/28 BUG0058594 工作汇报中的附件，不能预览
            $att_query = "select achmentid as id,ld_workachments.`name` as filename from ld_workachments 
                    where ld_workachments.workreportid = ?";
        } else {
            $att_query = "select ld_seattachmentsrel.attachmentsid as id,`name` as filename from ld_seattachmentsrel 
                    LEFT JOIN ld_attachments on ld_seattachmentsrel.attachmentsid = ld_attachments.attachmentsid 
                    where crmid = ?";
        }
        return $att_query;
    }

    //判断目标文件是否存在
    public function Dir_File_Exist()
    {
        $newfile_name = $this->newfile_name;
        $storage_location = $this->storage_location;
        $cloud_path = $this->cloud_path;
        $path = $this->path;
        $oldfilename = $this->filename;
        $default_charset = $this->default_charset;

        $OStype = $this->OStype;
        $OSarray = ['freebsd', 'linux', 'unix'];
        //获取系统类型，如果是非windows系统则不用修改编码格式
        if (in_array($OStype, $OSarray)) {
            $targetFile = $newfile_name;
        } else {
            $newfile_name = html_entity_decode($newfile_name, ENT_QUOTES, $default_charset);
            $targetFile = iconv('UTF-8', 'GBK', $newfile_name);
        }
        //editor:gyq_169 reason:腾讯云COS文件上传预览   2020/2/26 23:18
        $file_exist = false;
        if ($storage_location == 'cos') {
            //zkt 20220621 0051819（https://81mis.com/kfbtest/index.php?）自定义表单52》单据详情的附件，下载时提示文件丢失（可能是带符号的问题）
            $cloud_path = html_entity_decode($cloud_path, ENT_QUOTES, $default_charset);
            $filepath = $cloud_path;
            $httppath = $cloud_path;
            $image_path = $cloud_path;
            $header_response = @get_headers($cloud_path, 1);
            if (strpos($header_response[0], "404") === false) {
                $file_exist = true;
            }
        } else {
            $filepath = $path;
            //edit: xll 2023/10/06 BUG0072908 客户管理（包括但不限于，比如报价单、销售订单等等）数据列表，无法通过快速编辑添加视频附件。
            $httppath = $filepath . $targetFile;
            $image_path = $filepath . $newfile_name;
            $file_exist = file_exists($path . $newfile_name);//判断未转码是否文件存在
            if (!$file_exist) {
                $file_exist = file_exists($httppath);
                if (!$file_exist) {
                    $httppath = $filepath . $oldfilename;
                    $file_exist = file_exists(globalStatic::$root_directory . $httppath);
                }
            }
        }
        $this->newfile_name = $newfile_name;
        $this->cloud_path = $cloud_path;
        $this->httppath = $httppath;
        $this->image_path = $image_path;
        $this->filepath = $filepath;
        $this->file_exist = $file_exist;
        return $file_exist;
    }

    public function Preview_Txt($smarty)
    {
        $newfile_name = $this->newfile_name;
        $httppath = $this->httppath;
        $pops = explode('.', $newfile_name);
        $extname = array_pop($pops);
        if ($extname == 'rar' || $extname == 'zip') {
            $smarty->assign('type', 'rar');
        } else {
            $f = fopen($httppath, "r");
            $ln = 0;
            while (!feof($f)) {
                $line = fgets($f);
                ++$ln;
                $content .= $line;
            }
            fclose($f);
            $encodetype = mb_detect_encoding($content, array("ASCII", 'UTF-8', "GB2312", "GBK"));
            $content = mb_convert_encoding($content, "utf-8", $encodetype);
            $smarty->assign('content', '<pre>' . $content . '</pre>');
            $smarty->assign('type', 'text');
        }
    }

    public function Preview_Img($smarty)
    {
        $smarty->assign('img_src', $this->image_path);
        $smarty->assign('type', 'img');
    }

    public function Preview_Audio($smarty)
    {
        $smarty->assign('img_src', $this->image_path);
        $smarty->assign('type', 'audio');
        //ConvertTojsonString(4,array('src'=>$src),'ok');
    }

    public function Preview_Video($smarty)
    {
        $smarty->assign('img_src', $this->image_path);
        $smarty->assign('type', 'video');
    }

    public function Preview_PDF($smarty)
    {
        $environment = $this->environment;
        $login_type = $this->login_type;
        $filepath = $this->filepath;

        $newfile_name = $this->newfile_name;
        //在这里做判断是访问preview_now 还是preview_pdf
        if ($environment == $login_type) {
            //如果是dingding 访问preview_pdf
            include_once globalStatic::$root_directory . 'modules/uploads/Preview_pdf.php';
        } else {
            $smarty->assign('type', 'pdf');
            $filename = $newfile_name;
            $this->filename = $filename;
            $smarty->assign('name', $filename);
            $smarty->assign('filepah', $filepath);//PDF路径访问路径
        }
    }

    public function Preview_PPT($smarty)
    {
        $smarty->assign('type', 'ppt');
    }

    public function Preview_Office($smarty)
    {
        //word xls xlss
        $storage_location = $this->storage_location;
        $cloud_path = $this->cloud_path;
        $newfile_name = $this->newfile_name;
        $fileid = $this->fileid;
        $filepath = $this->filepath;
//        dump($this);
        if ($storage_location == 'cos') {
            $attachmenturl = $cloud_path . '?a=1';
        } else {
            $httphost = $_SERVER['HTTP_HOST'];
            $tmphost = $httphost;
            $tmphosts = explode(".", $tmphost);
            $port = $_SERVER['SERVER_PORT'];
            if (stripos($httphost, "http://") === false) {
                //edit:can 2020-11-5 43137: (crmm.mfexcel.com/crm/index.php)合同-品牌合同-详情-附件-下载/预览（小源科技客户问题）；单据编号BD01-80，附件下载文件名有误；点击附件预览提示An error occurred；销售-销售报价单，单据QUO913
                //duan 20221020 增加stripos($httphost,":".$port) 判断
                if ($port != 80 && $port != 443 && stripos($httphost, ":" . $port) === false)
                    $httphost = "http://" . $httphost . ":" . $port;
                else
                    if (strtolower($_SERVER['REQUEST_SCHEME']) == 'https') {
                        $httphost = "https://" . $httphost;
                    } else
                        $httphost = "http://" . $httphost;
            }
            $self = substr($_SERVER['PHP_SELF'], 0, stripos($_SERVER['PHP_SELF'], "index.php"));
            $hosturl = $httphost . $self;
            //duan 20240416 处理特殊情况，直接获取crm地址
            global $global_base_crm_url;
            if (!empty($global_base_crm_url)) {
                $hosturl = $global_base_crm_url;
            }
            //@chj mantis:41918:附件管理模块>选择编号为“ATT90 ”单据详情界面：附件名称含“+”无法预览和下载（需要补丁））
            file_put_contents(globalStatic::$root_directory . 'dataCache/test1.txt', date('Y-m-d H:i:s') . '|' . $httphost . "|" . $self . "|" . $filepath . ":" . $port, FILE_APPEND);
            $attachmenturl = $hosturl . $filepath . urlencode(decode_html($newfile_name)) . '?a=1';
        }
        $smarty->assign("ATTACHMENTURL", $attachmenturl);
        crm_load_class_file('cls_uploads', 'modules/uploads');
        $cls_uploads = new cls_uploads($newfile_name, $filepath, $fileid);
//        dump($cls_uploads);
        //控制
        $previewfile_type = $this->get_previewfile_type();
        //duan 20240227 cos的文件可以直接用微软接口预览
        if ($storage_location != 'cos' && $previewfile_type != 'microsoftoffice') {
            if ((sizeof($tmphosts) >= 4 && is_numeric($tmphosts[1]) && is_numeric($tmphosts[2])) || stripos($tmphost, 'localhost') !== false
                || ($port != 80 && $port != 443) || $previewfile_type == 'openoffice') {
                if ($this->environment == $this->login_type) {
                    //如果是dingding 访问preview_pdf
                    include_once globalStatic::$root_directory . 'modules/uploads/Preview_pdf.php';
                } else {
                    //ip地址无法预览
                    $uploads_info = $cls_uploads->ConvertOffice();
                }
            }
        }

        if ($uploads_info['code'] == 1) {
            $smarty->assign('type', 'pdf');
            $smarty->assign('pdfname', $uploads_info['pdfname']);//转换文件名称
            $smarty->assign('filepah', $uploads_info['filepath']);//PDF路径访问路径
        } else {
            if (((is_array($tmphosts)&& sizeof($tmphosts) >= 4 && is_numeric($tmphosts[1]) && is_numeric($tmphosts[2])) ||
                    stripos((string)$tmphost, 'localhost') !== false) && $previewfile_type != 'microsoftoffice') {
                //ip地址无法预览
            } else
                $smarty->assign('type', 'application/msword');
        }
    }

    public function Preview_OFD($smarty)
    {
        return $this->getFileUrl();
    }

    public function Preview_PDF_New($smarty)
    {
        $storage_location = $this->storage_location;
        $filepath = $this->filepath;
        $filename = $this->filename;
        //zkt 20230316  $_SERVER['HTTPS']与$_SERVER['HTTP_X_FORWARDED_PROTO']不存在
        $http_type = ((isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on') || (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https')
            || (isset($_SERVER['HTTP_ORIGIN']) && strpos($_SERVER['HTTP_ORIGIN'], 'https') !== false)) ? 'https://' : 'http://';

        //duan 20231026 判断预览附件时，是否需要读取http_origin
        if (isset($_SERVER['HTTP_ORIGIN']) && $this->get_previewfile_http_origin() == 'yes') {
            $crm_url = str_replace("index.php", "", $_SERVER['HTTP_ORIGIN'] . $_SERVER['PHP_SELF']);
        } else {
            $crm_url = $http_type . str_replace("index.php", "", $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF']);
        }

        if ($storage_location == 'cos') {
            $file_url = $filepath;
        } else {
            $file_url = $crm_url . $filepath . $filename;
        }
        return $file_url;
    }

    public function SaveOperateLog()
    {
        global $adb, $current_user;
        $lineitem_id = (empty($_REQUEST['lineitem_id']) || $_REQUEST['lineitem_id'] == '') ? 0 : $_REQUEST['lineitem_id'];
        $frommodule = $this->frommodule;
        $recordid = $_REQUEST['record'];
        $tabid = getTabid($frommodule);
        $newfile_name = $this->newfile_name;
        $userid = $current_user->id;
        $time = date("Y-m-d H:i:s", time());

        $insert_sql = 'insert into ld_fileoperationlog(tabid,crmid,lineitem_id,newfile_name,operator,operating_type,operating_time) values(?,?,?,?,?,?,?)';
        $adb->pquery($insert_sql, array($tabid, $recordid, $lineitem_id, $newfile_name, $userid, 'preview', $time));
    }

    public function getFileUrl()
    {
        $storage_location = $this->storage_location;
        $filepath = $this->filepath;
        $filename = $this->newfile_name;

        //duan 20231026 判断预览附件时，是否需要读取http_origin
        if (isset($_SERVER['HTTP_ORIGIN']) && $this->get_previewfile_http_origin() == 'yes') {
            $crm_url = str_replace("index.php", "", $_SERVER['HTTP_ORIGIN'] . $_SERVER['PHP_SELF']);
        } else {
            $http_type = self::getHttpType();
            $crm_url = $http_type . str_replace("index.php", "", $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF']);
        }
        global $kkFileView_fileHead ;
        if(!empty($kkFileView_fileHead)) {
            $crm_url = $kkFileView_fileHead;
        }
        if($crm_url[strlen($crm_url) - 1] !== '/') {
            $crm_url .= '/';
        }

        if ($storage_location == 'cos') {
            $file_url = $filepath;
        } else {
            $file_url = $crm_url . $filepath . $filename;
        }
        return $file_url;
    }

    public function PreviewBy_kkFileView($smarty) {
        global $kkFileView_url;
        if(!empty($kkFileView_url)) {
            $file_url = $this->getFileUrl();;
            $file_url = urlencode(base64_encode($file_url));
            $smarty->assign('type','kkFileView');
            $smarty->assign('kkFileViewUrl',self::get_kkFileViewHead().$file_url);
            return true;
        }
        return false;
    }

    public static function get_kkFileViewHead() {
        global $kkFileView_url;
        //edit: xll 2024/07/09 $_SERVER['SERVER_NAME'] 可web服务器配置修改，避免配置出错影响预览，使用HTTP_HOST
        $serverName = explode(':',$_SERVER['HTTP_HOST'])[0];
        if(strpos($kkFileView_url,'http') === false && strpos($kkFileView_url,'127.0.0.1') === false){
            $kkFileViewPort = $kkFileView_url;
            if(!empty($kkFileViewPort)){
                $http_type = self::getHttpType();
                $kkFileView_url = $http_type.$serverName.":".$kkFileViewPort;
            }
        }
        // 替换http
        $kkFileView_url = str_replace('http://127.0.0.1',self::getHttpType().$serverName,$kkFileView_url);
        $tail = "onlinePreview?url=";
        // 最后一位斜杠处理，http处理
        if(substr($kkFileView_url,-1) !== '/') {
            $tail = "/".$tail;
        }
        if(strpos($kkFileView_url,'http') !== 0) {
            $kkFileView_url = self::getHttpType() . $kkFileView_url;
        }
        return $kkFileView_url.$tail;
    }

    public static function getHttpType() {
        return ((isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on') || (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https')
            || (isset($_SERVER['HTTP_ORIGIN']) && strpos($_SERVER['HTTP_ORIGIN'], 'https') !== false)) ? 'https://' : 'http://';
    }

}