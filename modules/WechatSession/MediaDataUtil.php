<?php
$type = $_REQUEST['type'];  //文件处理类型
if (isset($type)) {
    switch($type)
    {
        case 'preview':
            preview();exit;
            break;
        case 'download':
            download();exit;
            break;
        default:
            echo 'Please make a new selection...';
            break;
    }
}

//下载
function download(){
    global $default_charset;
    ob_get_clean();
    $filepath = $_REQUEST['filepath'];
    $filename = $_REQUEST['filename'];

    $filename = html_entity_decode($filename, ENT_QUOTES, $default_charset);
    if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix') {
        //获取系统类型，如果是非windows系统则不用修改编码格式
    } else
        $filename = mb_convert_encoding($filename, 'gbk', 'UTF-8');

    if (strpos($filepath, 'http') !== false) {
        require_once globalStatic::$root_directory.'appCommon/appCommon.php';
        $_GET['temp_saved_filename'] =  $filename;
        downloadCloudFile($filepath);
    }
    ob_flush();
    ob_clean();
    exit;
}

//预览
function preview(){
    global $default_charset, $adb;
    //    $filepath = $_REQUEST['filepath'];
    //    $filename = $_REQUEST['filename'];
    $msgid = $_REQUEST['msgid'];
    $sessionid = $_REQUEST['sessionid'];  //ld_wechatsession 主键id

    $smarty = new lingdangCRM_Smarty;
    $smarty->assign('mode','Accounts');
    $smarty->assign("FROMMODULE",'Accounts');

    $query = "select * from ld_wechatsession  where id = ?" ;
    $result = $adb->pquery($query, array($sessionid)) or die("Couldn't get file list");
    if($adb->num_rows($result) == 1){
        $filepath = $adb->query_result($result, 0, "filepath");
        $filename = $adb->query_result($result, 0, "filename");
        $storage_location = @$adb->query_result($result, 0, "upload_way");
        $smarty->assign('storage_location',$storage_location);

        if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'){
        }
        else
        {
            $filename= html_entity_decode($filename, ENT_QUOTES, $default_charset);
            $filename=iconv ( 'UTF-8', 'GBK', $filename );
        }

        $file_exist = false;
        if($storage_location=='cos'){
            $httppath=$filepath;
            $image_path=$filepath;
            $header_response = @get_headers($filepath, 1);
            if ( strpos( $header_response[0], "404" ) === false ){
                $file_exist = true;
            }
        }else{
            $filepath = explode('storage',$filepath);//   /ldcrm/storage/wechatsession/2020/10/20/13137031303471600295_1604045319_external.jpg
            $filepath = 'storage'.$filepath[1];//   storage/wechatsession/2020/10/20/13137031303471600295_1604045319_external.jpg

            $httppath=$filepath;
            $image_path=$filepath;
            $file_exist = file_exists($filepath);
        }

        if($file_exist){
            $image_info = getimagesize($httppath);
            $image_type = end($image_info);

            $newfiles=explode('.',strtolower($filename));
            if($newfiles[sizeof($newfiles)-1]=='doc'||$newfiles[sizeof($newfiles)-1]=='docx'
                ||$newfiles[sizeof($newfiles)-1]=='xls'||$newfiles[sizeof($newfiles)-1]=='xlsx'
                ||$newfiles[sizeof($newfiles)-1]=='ppt'||$newfiles[sizeof($newfiles)-1]=='pptx')
            {
                $fileType="application/vnd.openxmlformats-officedocument.wordprocessingml.document";

            }
            if($fileType == 'text/plain' || $fileType == 'application/octet-stream'){	//文本
                $pops=explode('.',$filename);
                $extname=array_pop($pops);
                if($extname=='rar'||$extname=='zip')
                {
                    $smarty->assign('type','rar');
                }
                else
                {
                    $f = fopen ($httppath, "r");
                    $ln= 0;
                    $content = '';
                    while (! feof ($f)) {
                        $line= fgets ($f);
                        ++$ln;
                        $content .= $line;
                    }
                    fclose ($f);
                    $encodetype=mb_detect_encoding($content, array("ASCII",'UTF-8',"GB2312","GBK"));
                    $content=mb_convert_encoding($content,"utf-8",$encodetype);
                    $smarty->assign('content','<pre>' . $content . '</pre>');
                    $smarty->assign('type','text');
                }
            }else if(!empty($image_type)){	//图片

                $img_src= $image_path;

                $smarty->assign('img_src',$img_src);
                $smarty->assign('type','img');
            }elseif($fileType == 'application/pdf'){	//PDF
                $smarty->assign('type','pdf');
                $smarty->assign('name',$filename);

                $smarty->assign('filepah',$filepath);//PDF路径访问路径
            }elseif($fileType == 'application/vnd.openxmlformats-officedocument.presentationml.presentation' ){	//ppt
                $smarty->assign('type','ppt');
            }elseif($fileType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' ||
                $fileType == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' || $fileType == 'application/msword' ||
                $fileType == 'application/octet-stream' || $fileType == 'docx'||$fileType == 'doc' || $fileType=='xlsx' ||$fileType=='xls' ||
                $fileType == 'application/vnd.ms-excel'){	//word xls xlss
                if($storage_location=='cos'){
                    $attachmenturl= $filepath.'?a=1';
                }else{
                    $httphost=$_SERVER['HTTP_HOST'];
                    $tmphost=$httphost;
                    $tmphosts=explode(".",$tmphost);
                    $port = $_SERVER['SERVER_PORT'];

                    if(stripos($httphost,"http://")===false)
                    {
                        $httphost="http://".$httphost.":".$port;
                    }
                    $self=substr($_SERVER['PHP_SELF'],0,stripos($_SERVER['PHP_SELF'],"index.php"));
                    $hosturl=$httphost.$self;
                    //@chj mantis:41918:附件管理模块>选择编号为“ATT90 ”单据详情界面：附件名称含“+”无法预览和下载（需要补丁））
                    $attachmenturl=$hosturl.$filepath.urlencode(decode_html($filename)).'?a=1';
                }
                $smarty->assign("ATTACHMENTURL",$attachmenturl);
                crm_load_class_file('cls_uploads','modules/uploads');
                $cls_uploads = new cls_uploads($filename,$filepath,$sessionid);
                $uploads_info = $cls_uploads->ConvertOffice();
                if($uploads_info['code'] == 1){
                    $smarty->assign('type','pdf');
                    $smarty->assign('pdfname',$uploads_info['pdfname']);//转换文件名称
                    $smarty->assign('filepah',$uploads_info['filepath']);//PDF路径访问路径
                }else{

                    if((sizeof($tmphosts)>=4&&is_numeric($tmphosts[1])&&is_numeric($tmphosts[2]))||stripos($tmphost,'localhost')!==false)
                    {
                        //ip地址无法预览
                    }
                    else
                        $smarty->assign('type','application/msword');
                }
            }else{
                $smarty->assign('type','other');
            }

            $att_query = "select id,filename from ld_wechatsession  where msgid = ?" ;
            $att_result = $adb->pquery($att_query,array($msgid));
            $att_num_rows = $adb->num_rows($att_result);
            for($k = 0; $k < $att_num_rows; $k++){
                $attachmentsid = $adb->query_result($att_result,$k,'id');
                $att_data[$attachmentsid] = $adb->query_result($att_result,$k,'filename');
                $att_data_key[] = $attachmentsid;
            }

            $pre = 0;
            foreach($att_data_key as $key => $attachmentsid){
                if($attachmentsid == $sessionid){
                    $pre = $key;
                }
            }
            if($pre >= 1){
                $smarty->assign('PRE_ATTACHID',$att_data_key[$pre-1]);
                $smarty->assign('PRE_STAT','yes');
            }else{
                $smarty->assign('PRE_STAT','no');
            }
            if($pre == sizeOf($att_data_key)-1){
                $smarty->assign('NEXT_STAT','no');
            }else{
                $smarty->assign('NEXT_ATTACHID',$att_data_key[$pre+1]);
                $smarty->assign('NEXT_STAT','yes');
            }
            $smarty->assign('ATT_NUM_ROWS',$att_num_rows);
            $smarty->assign('ATT_DATA',$att_data);

//            SaveAuditlog($msgid,'预览',$filename,$frommodule);//存储附件的预览记录
            $smarty->assign('name',$filename);
            $replace_filename = str_replace("%","%25",$filename);
            $replace_filename = str_replace("#","%23",$replace_filename);
            $smarty->assign('replace_filename',$replace_filename);
            $smarty->assign('entityid',$msgid);
            $smarty->assign('fileId',$sessionid);
            $smarty->display('Preview_now.tpl');
            exit;

        }
        else{
            $jarr['error'] = getFixedLabel('THEFILEISMISSPLEASERETURN');//文件已丢失，请返回
            echo $str=json_encode($jarr);
            exit();
        }
    }
    else{
        $jarr['error'] = getFixedLabel('THEFILEISMISSPLEASERETURN');
        echo $str=json_encode($jarr);//将数组进行json编码
        exit();
    }
}