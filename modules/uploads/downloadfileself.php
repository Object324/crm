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
global $current_user;

ob_get_clean();

$attachmentsid = $_REQUEST['fileid'];

//$dbQuery = "SELECT * FROM ld_attachmentsforbills WHERE attachmentsid = ?" ;
$dbQuery = "SELECT * FROM ld_attachmentsforbillsdetails WHERE id = ?" ;
$result = $adb->pquery($dbQuery, array($attachmentsid)) or die("Couldn't get file list");

if($adb->num_rows($result) == 1)
{
    $fileType = @$adb->query_result($result, 0, "type");
	$name = @$adb->query_result($result, 0, "filename");
   
    $newfile_name = @$adb->query_result($result, 0, "newfile_name");
    
	$filepath = @$adb->query_result($result, 0, "path");
	$creator = @$adb->query_result($result, 0, "creator");
	//editor:gyq_169 reason:腾讯云COS文件上传预览   2020/3/6 16:33
    $cloud_path = @$adb->query_result($result, 0, "cloud_path");
    $storage_location = @$adb->query_result($result, 0, "storage_location");

    //    @edit:liushuai,2021-04-08,reason:【ID1001517】附件增加下载和预览次数及操作日志（附件模块 tabid=78）
    $adb->pquery('insert into ld_fileoperationlog(tabid,crmid,newfile_name,operator,operating_type,operating_time) values(?,?,?,?,?,?)', array(78,$_REQUEST['recordid'],$newfile_name, $current_user->id, 'download', date("Y-m-d H:i:s", time())));

    if($filepath=='undefined')
    {
         echo '##error##';
            exit();
    }
    //插入附件下载操作日志
    
	/**
	 * 列表上的下载按钮没有添加公开、私有权限判断，所以权限判断加在这儿
	 * @reason 0013910: 附件管理--新建：可见性，设置公开，失效。
	 * @author Tujt 2015-03-09
	 */
	
	$isenabled = @$adb->query_result($result, 0, "isenabled");
    //22610: 附件管理：管理员用户点击单据操作列的【下载】，结果提示：您没有权限执行这个操作！
	if('否' == $isenabled && $creator != $current_user->id&&$current_user->is_admin=='off'){
		echo '<script type="text/javascript">alert("'.getFixedLabel('NOPERMITTEDEXECUTE').'");location.href="index.php?module=Attachment&action=ListView";</script>';
		exit();
	}
    $name = html_entity_decode($name, ENT_QUOTES, $default_charset);//表示上传文件的名称
    $newfile_name= html_entity_decode($newfile_name, ENT_QUOTES, $default_charset);
	$saved_filename = $newfile_name;
    $downloadfilename=$name;
    $filesplit=explode('/',$filepath);
    $stri='storage';
    for($i=1;$i<sizeof($filesplit);$i++)
    {
        $stri.='/'.$filesplit[$i];
    }
    $stri.='/'.$saved_filename;

    /**
     * edit:can
     * date:20140211
     * reason:新需求：上传文件名称在服务器不变；
     */
    $stri = 'storage';
    $saved_filename = urlencode($newfile_name);
    if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix') {
        //获取系统类型，如果是非windows系统则不用修改编码格式
        $tmpsaved_filename = $newfile_name;
    } else {
//        $tmpsaved_filename = iconv('UTF-8', 'GBK', $newfile_name);
        $arr=array("ASCII","UTF-8","GB2312","GBK",'BIG-5');//同上传编码保持一致
        $encode=mb_detect_encoding($newfile_name, $arr);
        if($encode != 'UTF-8'){
            if (function_exists("mb_convert_encoding")) {
                $tmpsaved_filename = @mb_convert_encoding($newfile_name, "UTF-8", $encode);
            } else {
                if (function_exists("iconv")) {
                    $tmpsaved_filename = @iconv($encode, "UTF-8" . "//IGNORE", $newfile_name);
                }
            }
        }else{
            $tmpsaved_filename = $newfile_name;
        }
    }
   
    if($storage_location=='cos'){
        //editor:gyq_169 reason:下载云端文件   2020/3/3 16:49
        require_once globalStatic::$root_directory.'appCommon/appCommon.php';
        $filepath = $cloud_path;
        $rigin_cloud_path=$cloud_path;
        $paths=explode("/",$cloud_path);
        $cloud_path='';
        for($i=0;$i<sizeof($paths)-1;$i++)
        {
            $cloud_path.=$paths[$i].'/';
        }
       $cloud_path.=urlencode($paths[$i]);
  
        $header_response = get_headers($cloud_path, 1);
        //61mis.com/kfbcrm)客户问题（四方光电）附件管理模块>选择编号为“ATT99”单据详情界面：附件名称含“+不能法预览和下载（需要补丁
        if(strpos( $header_response[0], "404" ) !== false)
        {
          
            $header_response = get_headers($rigin_cloud_path, 1);
            $cloud_path=$rigin_cloud_path;
        }
    
        if ( strpos( $header_response[0], "404" ) !== false ){
            exit('文件丢失');
        }
        
      
            
        if ( strpos( $header_response[0], "404" ) === false ){
            $_GET['temp_saved_filename'] = $tmpsaved_filename;
            $_GET['temp_saved_filename'] = $downloadfilename;
            downloadCloudFile($cloud_path);
        }
        
        ob_flush();
        ob_clean();
        exit;
    }else {

        for ($i = 1; $i < sizeof($filesplit); $i++) {
            $stri .= '/' . $filesplit[$i];
        }
        $tmpstri = $stri;
        $stri .= $tmpsaved_filename;
        $tmpstri .= '/' . $tmpsaved_filename;

        if (!file_exists($tmpstri)) {
            echo '##error##';
            exit();
        }
        if (isset($_REQUEST['saveDownTimes']) && $_REQUEST['saveDownTimes'] == 'yes') {
            SaveAuditlog($_REQUEST['recordid'], '下载', $name, 'Attachment');//存储附件的下载记录

            exit();
        }
        $pops = explode('.', $newfile_name);
        $extname = strtolower(array_pop($pops));

        if ($extname == 'jpg' || $extname == 'jpeg' || $extname == 'gif'
            || $extname == 'txt' || $extname == 'png' || $extname = 'bmp' || $extname == 'ico'
                    || $extname == 'dwg' || $extname == 'xml') {

        } else {
            header("Location:" . $stri);

            exit();
        }


        $disk_file_size = filesize($stri);
        /*  }*/

        $diskfilesize = $disk_file_size + ($disk_file_size % 1024);

        //$fileContent = fread(fopen($stri, "r"), $diskfilesize);
        //iconv ( 'UTF-8', 'GBK', $name )
        $agent = $_SERVER["HTTP_USER_AGENT"];


        if (strpos($agent, 'MSIE') || strpos($agent, 'Trident')) {
            if (preg_match('/Trident\/(\d+)\..*/i', $agent, $regs)) {
                $name = $saved_filename;
            }
        }
        //35639: （1.6）附件管理列表界面>单据编号为“ATT15”：点击下载附件，下载下来的附件不能打开，上传的是word文档。
        $saved_filename = str_replace(';', '_', urldecode($saved_filename));
        $saved_filename = str_replace("`", '_', urldecode($saved_filename));

        $name = str_replace(';', '_', urldecode($name));
        $name = str_replace("`", '_', urldecode($name));
        header('content-type:application/octet-stream');
        header('accept-ranges: bytes');
        header('content-length: ' . filesize($stri));
        if (stripos($_SERVER['HTTP_USER_AGENT'], 'edge') !== false)//edge浏览器(win10自带)
            header("Content-Disposition: attachment; filename=" . urlencode($name));
        else
            header('content-disposition:attachment;filename=' . urldecode($name));
        ob_clean();
        flush();
        set_time_limit(0);


        $fp = fopen($stri, "rb");


        $buffer = 4096;
        $buffer_count = 0;
        while (!feof($fp) && $disk_file_size - $buffer_count > 0) {
            $data = fread($fp, $buffer);
            $buffer_count += $buffer;
            echo $data;
            ob_flush();  //把数据从PHP的缓冲中释放出来
            flush();      //
        }
        fclose($fp);
        exit();
    }
}
else
{
	echo $app_strings['LBL_RECORD_NOT_FOUND'];
}

?>