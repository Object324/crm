<?php

//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
/**
 * @author phpadmin
 * @copyright 2014
 */

global $default_charset,$adb;
$userid = $_REQUEST['userid'];
$environment = $_SESSION['login_type'];

//$environment = "pc_dingtalk";
global $current_user;
require_once(globalStatic::$root_directory . "appCommon/appCommon.php");
$installweixin= judgeCorpInfo('install_app');
if($installweixin)
{
    $login_type='www';
}
$login_type = "pc_dingtalk";
$pre_type = $_REQUEST['pre_type'] ;
if((!empty($_REQUEST['record']) && isset($_REQUEST['fileId']) ) || !empty($pre_type))
{
	$recordid = $_REQUEST['record'];	//单据id

    $fileid=$_REQUEST['fileId'];	//附件id
	$frommodule = $_REQUEST['frommodule'];	//模块

    //edit: xll 2023/08/17 BUG0071114 普通成员，客户新建界面，上传doc附件后，点击预览，界面一直显示加载中
    //先判断是否是新增编辑界面的预览，如果不是再判断权限
    if(empty($pre_type)){
        if(IsPreviewProfile($_REQUEST['record'],$frommodule)!='yes' )
        {
            ConvertTojsonString(-1,[],'无预览权限');
            //exit("无预览权限");
        }
    }

	$enCodeArr=array("EUC-CN","ASCII","UTF-8","GB2312","GBK",'BIG-5');

	if(!empty($frommodule)){
        //edit:xll 2023/06/30 XUQIU1000357 单据分录定制，增加“附件”字段类型（分录附件字段的预览下载次数在表ld_fileoperationlog中增加了lineitem_id字段，非分录默认为零）
        $lineitem_id = (empty($_REQUEST['lineitem_id']) || $_REQUEST['lineitem_id'] == '') ? 0 : $_REQUEST['lineitem_id'];
		if($lineitem_id != 0){
            $query = "SELECT type,size,name as filename,newfile_name,path,storage_location,cloud_path FROM ld_detailattachments WHERE id = ?";
        } else if(strtolower($frommodule) == 'attachment'){
			$query = "SELECT type,size,filename,path,newfile_name,storage_location,cloud_path from ld_attachmentsforbillsdetails WHERE id = ?";
		} else if($frommodule == 'CooperativeWork' || $frommodule == 'WorkReportList'){
            //edit: xll 2023/07/28 BUG0058594 工作汇报中的附件，不能预览
            $query = "SELECT type,size,`name` as filename,path,newfile_name,storage_location,cloud_path from ld_workachments WHERE achmentid = ?";
        } else {
			$query = "SELECT type,size,name as filename,newfile_name,path,storage_location,cloud_path FROM ld_attachments WHERE attachmentsid = ?" ;
		}
		$result = $adb->pquery($query, array($fileid)) or die("Couldn't get file list");
        $num = $adb->num_rows($result);
        if($num == 1){
            $fileType = @$adb->query_result($result, 0, "type");	//附件类型
            $size = @$adb->query_result($result, 0, "size");	//附件大小
            $filename = @$adb->query_result($result, 0, "filename");	//附件名称

            $path = @$adb->query_result($result, 0, "path");
            $cloud_path = @$adb->query_result($result, 0, "cloud_path");
            $storage_location = @$adb->query_result($result, 0, "storage_location");
            $newfile_name= html_entity_decode(@$adb->query_result($result, 0, "newfile_name"), ENT_QUOTES, $default_charset);

            $FileObj = array('fileid' => $fileid, 'type' => $fileType, 'size' => $size, 'filename' => $filename,
                'path' => $path, 'cloud_path' => $cloud_path, 'storage_location' => $storage_location,
                'newfile_name' => $newfile_name);
        }
	} else if(!empty($pre_type)){
        // edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（新增编辑界面的附件预览）
        $file_array = ['type','size','filename','path','newfile_name','cloud_path','storage_location','isEncrypt'];
        $FileObj = [];
        $fileurl = '';
        foreach ($file_array as $tmpname){
            $FileObj[$tmpname] = $_REQUEST[$tmpname];
            $fileurl .= '&' . $tmpname . '=' . urlencode($_REQUEST[$tmpname]);
        }
        if($FileObj['isEncrypt'] == 'yes'){
            require_once globalStatic::$root_directory.'Register/cls_MyCRMcrypt.php';
            $cls_MyCRMcrypt = new cls_MyCRMcrypt();
            $decode_arr = ['path','newfile_name','cloud_path'];
            foreach ($decode_arr as $tmpname){
                $FileObj[$tmpname] = $cls_MyCRMcrypt->decode($FileObj[$tmpname]);
            }
        }
        if(strpos($FileObj['cloud_path'],'http') !== 0){
            $FileObj['cloud_path'] = 'https://'.$FileObj['cloud_path'];
        }
        $FileObj['fileurl'] = $fileurl;
        $num = 1;
    }

    if($num == 1){
        $encode=mb_detect_encoding((string)$filename, $enCodeArr);
//dump($FileObj);
        // edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（预览文件整理成类Preview_File）
        crm_load_class_file('Preview_File','modules/uploads');
        $FilePreviewObj = new Preview_File($FileObj);

        //duan 20231026 可在config.inc.php 里增加参数($previewfile_http_origin)控制预览pdf附件时，是否需要读取$_SERVER['HTTP_ORIGIN']。  变量参考值：yes\no
		$FilePreviewObj->set_previewfile_http_origin($previewfile_http_origin);
		//duan 20231108 可在config.inc.php 里增加参数($global_previewfile_type)控制预览附件时，是否需要固定读取openoffice或微软接口。 变量参考值：openoffice\microsoftoffice
        $FilePreviewObj->set_previewfile_type($global_previewfile_type); //

        $FilePreviewObj->PreviewByType();
	}else{
        ConvertTojsonString(-1,[],getFixedLabel('THEFILEISMISSPLEASERETURN'));
//		$jarr['error'] = getFixedLabel('THEFILEISMISSPLEASERETURN');
//		echo $str=json_encode($jarr);//将数组进行json编码
//		exit();
    }
	die;
 }  
?>