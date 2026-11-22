<?php
//zxm 钉钉文件预览 转成PDF
//【钉钉，可以直接预览附件。可控制直接预览和保存到钉盘预览（邬丹华）】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001966
global $default_charset,$adb,$current_user;
$userid = $_REQUEST['userid'];
$environment = $_SESSION['login_type'];
$login_type = "pc_dingtalk";
//$environment = 'pc_dingtalk';
$smarty = new lingdangCRM_Smarty;
if(!empty($_REQUEST['record']) && isset($_REQUEST['fileId']) )
{
    $recordid = $_REQUEST['record'];	//单据id

    $fileid=$_REQUEST['fileId'];	//附件id
    $frommodule = $_REQUEST['frommodule'];	//模块

    if(IsPreviewProfile($_REQUEST['record'],$frommodule)!='yes')
    {
        exit("无预览权限");
    }


    $smarty->assign('mode',$frommodule);
    $smarty->assign("FROMMODULE",$frommodule);

    $enCodeArr=array("EUC-CN","ASCII","UTF-8","GB2312","GBK",'BIG-5');


    if(!empty($frommodule)){
        if(strtolower($frommodule) == 'attachment'){
            $query = "SELECT type,size,filename,path,newfile_name,storage_location,cloud_path from ld_attachmentsforbillsdetails WHERE id = ?";
        }else {
            $query = "SELECT type,size,name as filename,newfile_name,path,storage_location,cloud_path FROM ld_attachments WHERE attachmentsid = ?" ;
        }
        $result = $adb->pquery($query, array($fileid)) or die("Couldn't get file list");
    }

    if($adb->num_rows($result) == 1){
        $fileType = @$adb->query_result($result, 0, "type");	//附件类型
        $size = @$adb->query_result($result, 0, "size");	//附件大小
        $filename = @$adb->query_result($result, 0, "filename");	//附件名称

        $path = @$adb->query_result($result, 0, "path");
        $cloud_path = @$adb->query_result($result, 0, "cloud_path");
        $storage_location = @$adb->query_result($result, 0, "storage_location");
        $newfile_name= html_entity_decode(@$adb->query_result($result, 0, "newfile_name"), ENT_QUOTES, $default_charset);
        $oldfilename=$newfile_name;
        $encode=mb_detect_encoding($filename, $enCodeArr);

        //获取系统类型，如果是非windows系统则不用修改编码格式
        if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'){
            $targetFile=$newfile_name;
        }
        else
        {
            $newfile_name= html_entity_decode($newfile_name, ENT_QUOTES, $default_charset);
            $targetFile=iconv ( 'UTF-8', 'GBK', $newfile_name );
        }
        $targetFile = html_entity_decode($targetFile, ENT_QUOTES, $default_charset);
        //editor:gyq_169 reason:腾讯云COS文件上传预览   2020/2/26 23:18
        $file_exist = false;
        $smarty->assign('storage_location',$storage_location);
        if($storage_location=='cos'){
            $filepath = $cloud_path;
            $httppath=$cloud_path;
            $image_path=$cloud_path;
            $header_response = @get_headers($cloud_path, 1);
            if ( strpos( $header_response[0], "404" ) === false ){
                $file_exist = true;
            }
        }else{
            $filepath = $path;
            $httppath=$filepath.$targetFile;
            $image_path=$filepath.$newfile_name;
            $file_exist = file_exists(globalStatic::$root_directory.$httppath);
            if(!$file_exist)
            {
              
                $httppath=$filepath.$oldfilename;
                
                
                $file_exist=file_exists(globalStatic::$root_directory.$httppath);
            }
        }

        if($file_exist){
            $image_info = getimagesize($httppath);
            $image_type = end($image_info);

            $newfiles=explode('.',strtolower($newfile_name));
            if($newfiles[sizeof($newfiles)-1]=='doc'||$newfiles[sizeof($newfiles)-1]=='docx'
                ||$newfiles[sizeof($newfiles)-1]=='xls'||$newfiles[sizeof($newfiles)-1]=='xlsx'
                ||$newfiles[sizeof($newfiles)-1]=='ppt'||$newfiles[sizeof($newfiles)-1]=='pptx')
            {
                $fileType="application/vnd.openxmlformats-officedocument.wordprocessingml.document";

            }

            if($fileType == 'text/plain' || $fileType == 'application/octet-stream'){	//文本
                $pops=explode('.',$newfile_name);
                $extname=array_pop($pops);
                if($extname=='rar'||$extname=='zip')
                {
                    $smarty->assign('type','rar');
                }
                else
                {
                    $f = fopen ($httppath, "r");
                    $ln= 0;
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
            }elseif($fileType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' ||
                $fileType == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' || $fileType == 'application/msword' ||
                $fileType == 'application/octet-stream' || $fileType == 'docx'||$fileType == 'doc' || $fileType=='xlsx' ||$fileType=='xls' ||
                $fileType == 'application/vnd.ms-excel'||$fileType == 'application/vnd.openxmlformats-officedocument.presentationml.presentation'||$fileType == 'application/pdf'){
                //word xls xlss ppt pdf 除了PDF之外其他的格式全部转pdf  其他格式沿用以前的方式
                if($fileType != 'application/pdf'){
                    crm_load_class_file('cls_uploads','modules/uploads');
                    $cls_uploads = new cls_uploads($newfile_name,$filepath,$fileid);
                    $uploads_info = $cls_uploads->ConvertOffice();
                    $fileallpath = $uploads_info['filepath'].$uploads_info['pdfname'];
                }else{
                    if($storage_location=='cos')
                    {
                        $fileallpath = $filepath;
                    }
                    else
                        $fileallpath = $filepath.$newfile_name;
                }

//                if($_REQUEST['mobile']=="yes"){
//                    $corpurl = $_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['HTTP_HOST']. rtrim($_SERVER['PHP_SELF'],'WeiXinApp/dingtalk/index.php').'/';
//                }else{
                //在linux的docker部署的crm系统，在经由nginx转到docker内部时，访问地址会变成 172.0.0.1:88 
                //从而使得在企业微信pc端预览附件时，无法获取到文件

                if($environment==$login_type && strtolower(PHP_OS)=='linux' && (isset($_SERVER['HTTP_ORIGIN'])&&!empty($_SERVER['HTTP_ORIGIN']))){
                    $httphost = $_SERVER['HTTP_ORIGIN'];
                }else{
                    $httphost = $_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['HTTP_HOST'];
                }
                $corpurl = $httphost. rtrim($_SERVER['PHP_SELF'],'index.php');
                if($storage_location=='cos')
                {
                    $fileallpath = $fileallpath;
                }
                else{
                    $fileallpath = $corpurl.$fileallpath;
                }
                $fileallpath.="&storage_location=$storage_location";

                crm_load_class_file("Tokencls",'include');
                $token=Tokencls::getTimeEncryptToken();
                $filetopdf = urlencode($corpurl."data/pdf.php?url=".$fileallpath);
//                if($_REQUEST['mobile']=="yes"){
//                    $filepah = $corpurl."WeiXinApp/dingtalk/index.php?module=Upload&action=Preview_pdfviewer&ReportHeader=DHeader&corpurl=".$corpurl.'&filename='.$filetopdf.'&title='.$filename.'&viewpdf=yes&userid='.$userid;
//                }else{
                    $filepah = $corpurl."index.php?module=uploads&action=Preview_pdfviewer&ReportHeader=DHeader&corpurl=".$corpurl.'&filename='.$filetopdf.'&title='.$filename.'&viewpdf=yes&userid='.$userid;
//                }

                $smarty->assign('name',$filename);
                $smarty->assign('filepah',$filepah."&token=".$token);
                $smarty->assign('storage_location','cos');
                $smarty->assign('type','pdf');
            }else{
                $smarty->assign('type','other');
            }
            $attacmentfile=$_REQUEST['Attachment_file'];
            if(!empty($_REQUEST['Attachment_file'])&&$environment!=$login_type){
               // $jarr['error'] = 'ok';
               // echo $str=json_encode($jarr);
                  ConvertTojsonString(2,[],'ok');
            //    exit();
            }else{
                //@edit:liushuai,2021-04-08,reason:【ID1001517】附件增加下载和预览次数及操作日志
                //edit:xll 2023/06/30 XUQIU1000357 单据分录定制，增加“附件”字段类型（分录附件字段的预览下载次数在表ld_fileoperationlog中增加了lineitem_id字段，非分录默认为零）
                $lineitem_id = (empty($_REQUEST['lineitem_id']) || $_REQUEST['lineitem_id'] == '') ? 0 : $_REQUEST['lineitem_id'];
                $adb->pquery('insert into ld_fileoperationlog(tabid,crmid,lineitem_id,newfile_name,operator,operating_type,operating_time) values(?,?,?,?,?,?,?)', array(getTabid($frommodule),$recordid,$lineitem_id,$newfile_name, $current_user->id, 'preview', date("Y-m-d H:i:s", time())));
                //图片预览或者其他文件预览都会走到这里
                if (isset($_REQUEST['is_target']) && $_REQUEST['is_target'] == 'no') { //图片视频预览特殊处理保存预览日志
                    exit('预览，无需跳转，只为添加预览日志');
                }
                if(strtolower($frommodule) == 'attachment'){
                    $att_query = "select id,ld_attachmentsforbillsdetails.filename from ld_attachmentsforbills 
                    LEFT JOIN ld_attachmentsforbillsdetails on ld_attachmentsforbillsdetails.attachmentsid = ld_attachmentsforbills.attachmentsid 
                    where ld_attachmentsforbills.attachmentsid = ?";
                    $att_result = $adb->pquery($att_query,array($recordid));
                    $att_num_rows = $adb->num_rows($att_result);
                    for($k = 0; $k < $att_num_rows; $k++){
                        $attachmentsid = $adb->query_result($att_result,$k,'id');
                        $att_data[$attachmentsid] = $adb->query_result($att_result,$k,'filename');
                        $att_data_key[] = $attachmentsid;
                    }
                }else {
                    $att_query = "select ld_seattachmentsrel.attachmentsid,`name` from ld_seattachmentsrel 
                    LEFT JOIN ld_attachments on ld_seattachmentsrel.attachmentsid = ld_attachments.attachmentsid 
                    where crmid = ?" ;
                    $att_result = $adb->pquery($att_query,array($recordid));
                    $att_num_rows = $adb->num_rows($att_result);
                    for($k = 0; $k < $att_num_rows; $k++){
                        $attachmentsid = $adb->query_result($att_result,$k,'attachmentsid');
                        $att_data[$attachmentsid] = $adb->query_result($att_result,$k,'name');
                        $att_data_key[] = $attachmentsid;
                    }
                }
                $pre = 0;
                foreach($att_data_key as $key => $attachmentsid){
                    if($attachmentsid == $fileid){
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

                SaveAuditlog($recordid,'预览',$filename,$frommodule);//存储附件的预览记录
                $smarty->assign('name',$filename);
                $replace_filename = str_replace("%","%25",$filename);
                $replace_filename = str_replace("#","%23",$replace_filename);
                $smarty->assign('replace_filename',$replace_filename);
                $smarty->assign('entityid',$recordid);
                $smarty->assign('fileId',$fileid);
                $smarty->assign('isPop',$_REQUEST['isPop']);
                //$smarty->display('Preview_pdf.tpl');
                if($environment==$login_type){
                    //弹框预览

                    $smarty->assign('inpopup','yes');
                    $content = $smarty->fetch('Preview_pdf.tpl');
                    $_REQUEST['diony']='diony';
                    $res['content'] = $content;
                    $res['title'] = $filename;
                    ConvertTojsonString(1,$res,'success');
                }else{
                    $smarty->display('Preview_pdf.tpl');
                }
                exit;
            }
        }else{
            $jarr['error'] = getFixedLabel('THEFILEISMISSPLEASERETURN');//文件已丢失，请返回
            echo $str=json_encode($jarr);
            exit();
        }
    }else{
        $jarr['error'] = getFixedLabel('THEFILEISMISSPLEASERETURN');
        echo $str=json_encode($jarr);//将数组进行json编码
        exit();
    }
    die;
}
