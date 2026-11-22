<?php
//$_REQUEST['mobile'] = "yes";//移动端
//include_once(globalStatic::$root_directory .'Smarty_setup.php');
//include_once(globalStatic::$root_directory .'modules/uploads/Preview_pdf.php');
//以上是之前的方式

//zxm 钉钉移动端文件预览 转成PDF
//【钉钉，可以直接预览附件。可控制直接预览和保存到钉盘预览（邬丹华）】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001966
global $default_charset, $adb, $current_user,$weixin_user;
$userid = $_REQUEST['userid'];
$corpurl = $_REQUEST['corpurl'];
$res = [];

if (!empty($_REQUEST['record']) && isset($_REQUEST['fileId']) || $_REQUEST['preview_type'] == 'yes') {
    $recordid = $_REQUEST['record'];    //单据id
    $fileid = $_REQUEST['fileId'];    //附件id
    $frommodule = $_REQUEST['frommodule'];    //模块
    if (IsPreviewProfile($_REQUEST['record'], $frommodule) != 'yes') {
        ConvertTojsonString(-1, null, getFixedLabel('NOPREVIEWPERMISSION'));
    }
    $enCodeArr = array("EUC-CN", "ASCII", "UTF-8", "GB2312", "GBK", 'BIG-5');
    $preview_type = $_REQUEST['preview_type'];

    if (!empty($preview_type) && empty($fileid)) {
        $fileType = $_REQUEST['filetype'];    //附件类型
        $size = $_REQUEST['size'];    //附件大小
        $filename = $_REQUEST['filename'];    //附件名称
        $path = $_REQUEST['path'];
        $path_arr = explode("/", $path);

        $cloud_path = $_REQUEST['httppath'];
        $storage_location = $_REQUEST['storage_location'];

        if ($path_arr[sizeof($path_arr) - 1] == $_REQUEST['newfile_name']) {
            unset($path_arr[sizeof($path_arr) - 1]);
            $path = implode("/", $path);
        }

        $newfile_name = html_entity_decode($_REQUEST['newfile_name'], ENT_QUOTES, $default_charset);
        $numrows = 1;
    } else if (!empty($frommodule)) {
        if (strtolower($frommodule) == 'attachment') {
            $query = "SELECT type,size,filename,path,newfile_name,storage_location,cloud_path from ld_attachmentsforbillsdetails WHERE id = ?";
        } else {
            $query = "SELECT type,size,name as filename,newfile_name,path,storage_location,cloud_path FROM ld_attachments WHERE attachmentsid = ?";
            if ($_REQUEST['isentry'] && $_REQUEST['isentry'] == 'entry') {
                $query = "SELECT type,size,name as filename,newfile_name,path,storage_location,cloud_path FROM ld_detailattachments WHERE id = ?";
            }
        }
        $result = $adb->pquery($query, array($fileid)) or die("Couldn't get file list");
        if ($adb->num_rows($result) == 1) {
            $fileType = @$adb->query_result($result, 0, "type");    //附件类型
            $size = @$adb->query_result($result, 0, "size");    //附件大小
            $filename = @$adb->query_result($result, 0, "filename");    //附件名称
            $path = @$adb->query_result($result, 0, "path");
            $cloud_path = @$adb->query_result($result, 0, "cloud_path");
            $storage_location = @$adb->query_result($result, 0, "storage_location");
            $newfile_name = html_entity_decode(@$adb->query_result($result, 0, "newfile_name"), ENT_QUOTES, $default_charset);
            $numrows = 1;
        }
    }
    global $weixin_user;

    if ($numrows == 1) {

        $encode = mb_detect_encoding($newfile_name, $enCodeArr);

        //获取系统类型，如果是非windows系统则不用修改编码格式
        if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix') {
            $targetFile = $newfile_name;
        } else {
            // edit: xll 2024/09/25 BUG20240914-23 编码问题
            $newfile_name = html_entity_decode($newfile_name, ENT_QUOTES, $default_charset);
            $arr = array("ASCII","UTF-8","GB2312","GBK",'BIG-5');
            $encode = mb_detect_encoding($newfile_name, $arr);
            if($encode!='UTF-8'){
                $targetFile = mb_convert_encoding($newfile_name ,'utf-8' , $encode);
            }
            else {
                $targetFile = $newfile_name;
            }
            //$targetFile = iconv('UTF-8', 'GBK', $newfile_name);
        }
        $targetFile = html_entity_decode($targetFile, ENT_QUOTES, $default_charset);
        //editor:gyq_169 reason:腾讯云COS文件上传预览   2020/2/26 23:18
        $oldfilepath = '';
        $file_exist = false;
        if ($storage_location == 'cos') {
            $filepath = $cloud_path;
            $httppath = $cloud_path;
            $image_path = $cloud_path;
            $header_response = @get_headers($cloud_path, 1);
            if (strpos($header_response[0], "404") === false) {
                $file_exist = true;
            }
        } else {
            $filepath = $path;
            $oldfilepath = $filepath;
            $httppath = $filepath . $targetFile;
            $image_path = $filepath . $newfile_name;
            $file_exist = file_exists(globalStatic::$root_directory . $httppath);
        }
        if ($file_exist) {
            $image_info = getimagesize($httppath);
            $image_type = end($image_info);
            $pops = explode('.', $newfile_name);
            $extname = array_pop($pops);
            $newfiles = explode('.', strtolower($newfile_name));

            $fileallpath = $filepath . $newfile_name;
            if ($storage_location == 'cos')
                $fileallpath = $cloud_path;
            else
                $fileallpath = $corpurl . $fileallpath;

            //office 类型
            $fileType_office = ['application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                'application/vnd.openxmlformats-officedocument.presentationml.presentation', 'application/msword', 'application/vnd.ms-excel',
                'docx', 'doc', 'xlsx', 'xls', 'ppt', 'pptx',];

            //edit: xll kkFileView文件预览
            global $kkFileView_url, $kkFileView_fileHead;
            if(!empty($kkFileView_url)){
                $res['type'] = $fileType;
                $res['previewBy'] = 'kkFileView';
                if(!empty($kkFileView_fileHead) && $storage_location !== 'cos') {
                    $fileallpath = $kkFileView_fileHead . $filepath . $newfile_name;
                }
                $fileallpath = urlencode(base64_encode($fileallpath));
                crm_load_class_file('Preview_File','modules/uploads');
                $res['file'] = Preview_File::get_kkFileViewHead().$fileallpath;
            }
            else {
                if ($fileType == 'text/plain' || $fileType == 'application/octet-stream' || $fileType == 'application/ofd') {    //文本
                    if ($extname == 'rar' || $extname == 'zip') {
                        //$smarty->assign('type', 'rar');
                        ConvertTojsonString(-1, null, getFixedLabel('NOTALLOWEDFORTHISTYPE'));
                    }
                    else if ($extname == 'ofd') {
                        //wsh 2024/06/04 XUQIU1001658 移动端ofd文件预览
                        $filetopdf = urlencode($corpurl . "data/pdf.php?url=" . $fileallpath);
                        //zkt 20241021 BUG20241018-32 https://61mis.com/WX/kh41942/地址预览附件存在问题
                        if(stripos($_SERVER['PHP_SELF'],"WeiXinApp/indexnative.php")!==false)
                        {
                            //edit:can BUG20241204-35
                            $php_self = getCrmUrl().'/WeiXinApp/indexnative.php';
                        }
                        else
                                $php_self = getCrmUrl().'/WeiXinApp/index.php';
                        crm_load_class_file("Tokencls",'include');
                        $token=Tokencls::getTimeEncryptToken();
                        $filepah =  $php_self . "?module=Upload&action=Preview_ofdviewer&corpurl=" . $corpurl . '&title=' . $filename . '&viewpdf=yes&userid=' . $userid . '&filename=' . $filetopdf;
                        $token.="&token=".$token;

                        $res['type'] = 'ofd';
                        if (stripos($fileallpath, '.html') === false && $_REQUEST['platform'] != 'ios') {
                            $res['file'] = $filepah;
                        } else {
                            $res['file'] = $fileallpath;
                        }
                        if ($weixin_user->environment == 'app') {
                            $encryptobj = new cls_MyCRMcrypt();
                            $tmpuserid = $encryptobj->encode($_REQUEST['userid']);
                            $res['file'] = $res['file'] . "&userid=" . $tmpuserid . '&appusertoken=' . $_REQUEST['appusertoken'];
                        }
                    }
                    else {
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
                        $res['type'] = 'text';
                        $res['content'] = 'content';
                    }
                }
                else if (!empty($image_type)) {    //图片
                    $img_src = $image_path;
                    ConvertTojsonString(-1, null, getFixedLabel('PICTURE') . '！');
                }
                elseif (in_array($fileType,$fileType_office) || $fileType == 'application/pdf') {
                    //word xls xlss ppt pdf 除了PDF之外其他的格式全部转pdf  其他格式沿用以前的方式
                    crm_load_class_file("Tokencls",'include');
                    $token=Tokencls::getTimeEncryptToken();
                    $filetopdf = urlencode($corpurl . "data/pdf.php?url=" . $fileallpath);
                    if(stripos($_SERVER['PHP_SELF'],"WeiXinApp/indexnative.php")!==false)
                    {
                        //edit:can BUG20241204-35
                        $php_self = getCrmUrl().'/WeiXinApp/indexnative.php';
                    }
                    else
                            $php_self = getCrmUrl().'/WeiXinApp/index.php';
                    $filepah = $php_self . "?module=Upload&action=Preview_pdfviewer&corpurl=" . $corpurl . '&title=' . $filename . '&viewpdf=yes&userid=' . $userid . '&filename=' . $filetopdf;
                    $filepah.="&token=".$token;
                    if(isset($weixin_user->wx_userid)&&$weixin_user->environment=='weixinh5')
                    {
                        if(isset($weixin_user->wx_userid))
                        {
                            $filepah.="&userid=".$weixin_user->wx_userid;
                        }
                    }
                    $res['type'] = 'pdf';
                    if (stripos($fileallpath, '.html') === false && $_REQUEST['platform'] != 'ios') {
                        $res['file'] = $filepah;
                    } else {
                        $res['file'] = $fileallpath;
                    }
                    if ($weixin_user->environment == 'app') {
                        $encryptobj = new cls_MyCRMcrypt();
                        $tmpuserid = $encryptobj->encode($_REQUEST['userid']);
                        $res['file'] = $res['file'] . "&userid=" . $tmpuserid . '&appusertoken=' . $_REQUEST['appusertoken'];
                    }
                    $msOfficeExtArr = ['doc','docx','xls','xlsx','ppt','pptx'];
                    if (in_array($extname,$msOfficeExtArr)) {
                        if ($storage_location == 'cos')
                            $res['file'] = 'https://view.officeapps.live.com/op/embed.aspx?src=' . $cloud_path;
                        else {
                            $tmphosts = explode(".", $corpurl);
                            $copurl_arr = explode(":", $corpurl);
                            $port = 80;
                            if (sizeof($copurl_arr) > 2) {
                                $tmpurl = $copurl_arr[2];
                                $tmpurl_arr = explode('/', $tmpurl);//获取端口号
                                $port = $tmpurl_arr[0];
                                if ($port == 80 || $port == 443) {
                                    $tmphosts[1] = 'aa';
                                }
                            }
                            if ((sizeof($tmphosts) >= 4 && is_numeric($tmphosts[1]) && is_numeric($tmphosts[2]))
                                || stripos($tmphost, 'localhost') !== false ||
                                ($port != 80 && $port != 443)) {
                                //ip地址无法预览
                                if ($fileType != 'application/pdf') {
                                    crm_load_class_file('cls_uploads', 'modules/uploads');
                                    $cls_uploads = new cls_uploads($newfile_name, $filepath, $fileid);
                                    $uploads_info = $cls_uploads->ConvertOffice();
                                    $fileallpath = $uploads_info['filepath'] . $uploads_info['pdfname'];
                                }
                                $fileallpath = $corpurl . $fileallpath;
                                $filetopdf = urlencode($corpurl . "data/pdf.php?url=" . $fileallpath);
                                crm_load_class_file("Tokencls",'include');
                                $token=Tokencls::getTimeEncryptToken();
                                $filepah = $php_self . "?module=Upload&action=Preview_pdfviewer&corpurl=" . $corpurl . '&title=' . $filename . '&viewpdf=yes&userid=' . $userid . '&filename=' . $filetopdf;
                                $filepah.='&token='.$token;
                                if(isset($weixin_user->wx_userid)&&$weixin_user->environment=='weixinh5')
                                {
                                    if(isset($weixin_user->wx_userid))
                                    {
                                        $filepah.="&userid=".$weixin_user->wx_userid;
                                    }
                                }
                                $res['type'] = 'pdf';
                                if (stripos($fileallpath, '.html') === false && $_REQUEST['platform'] != 'ios') {
                                    $res['file'] = $filepah;
                                } else
                                    $res['file'] = $fileallpath;

                                if ($weixin_user->environment == 'app') {
                                    $encryptobj = new cls_MyCRMcrypt();
                                    $tmpuserid = $encryptobj->encode($_REQUEST['userid']);
                                    $res['file'] = $res['file'] . "&userid=" . $tmpuserid . '&appusertoken=' . $_REQUEST['appusertoken'];
                                }

                            } else {
                                $attachmenturl = $corpurl . $filepath . urlencode(decode_html($newfile_name)) . '?a=1';
                                $res['file'] = 'https://view.officeapps.live.com/op/embed.aspx?src=' . $attachmenturl;
                            }

                        }
                    }
                    file_put_contents(globalStatic::$root_directory . 'WeiXinApp/modules/Upload/ab.txt', $res['file']);
                }
                else {
                    ConvertTojsonString(-1, null, getFixedLabel('NOTALLOWEDFORTHISTYPE'));
                }
            }
            if (!empty($_REQUEST['Attachment_file'])) {
                ConvertTojsonString(-1, null, getFixedLabel('FILEPREVIEWERROR'));
            } else {
                //@edit:liushuai,2021-04-08,reason:【ID1001517】附件增加下载和预览次数及操作日志
                //edit:xll 2023/06/30 XUQIU1000357 单据分录定制，增加“附件”字段类型（分录附件字段的预览下载次数在表ld_fileoperationlog中增加了lineitem_id字段，非分录默认为零）
                //edit:duan 20241226 移动端会另外发一个请求用来记录预览日志，这个先不用了
                //$lineitem_id = (empty($_REQUEST['lineitem_id']) || $_REQUEST['lineitem_id'] == '') ? 0 : $_REQUEST['lineitem_id'];
                //$adb->pquery('insert into ld_fileoperationlog(tabid,crmid,lineitem_id,newfile_name,operator,operating_type,operating_time) values(?,?,?,?,?,?,?)', array(getTabid($frommodule), $recordid, $lineitem_id, $newfile_name, $current_user->id, 'preview', date("Y-m-d H:i:s", time())));

                //图片预览或者其他文件预览都会走到这里
                if (isset($_REQUEST['is_target']) && $_REQUEST['is_target'] == 'no') { //图片视频预览特殊处理保存预览日志
                    ConvertTojsonString(-2, null, '预览，无需跳转，只为添加预览日志');
                }
                SaveAuditlog($recordid, '预览', $filename, $frommodule);//存储附件的预览记录
                ConvertTojsonString(1, $res, 'success');

            }
        } else {
            ConvertTojsonString(-1, null, getFixedLabel('THEFILEISMISSPLEASERETURN'));//文件已丢失，请返回
        }
    } else {
        ConvertTojsonString(-1, null, getFixedLabel('THEFILEISMISSPLEASERETURN'));//文件已丢失，请返回
    }
}
ConvertTojsonString(-1, null, getFixedLabel('DOCUMENTIDISMISSING'));
