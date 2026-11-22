<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/

require_once('modules/Documents/Documents.php');

global $adb;
global $current_user;



if(isset($_REQUEST['act']) && $_REQUEST['act'] == 'updateDldCnt')
{
	global $adb;
	$file_id=$_REQUEST['file_id'];
	$sql = "select filedownloadcount from ld_notes where notesid= ?";
	$download_count = $adb->query_result($adb->pquery($sql,array($file_id)),0,'filedownloadcount') ;
    if(empty($download_count))
    {
        $download_count= 1;
    }
    else
    {
        $download_count+= 1;
    }
	$sql="update ld_notes set filedownloadcount= ? where notesid= ?";
	$res=$adb->pquery($sql,array($download_count,$file_id));
}

if(isset($_REQUEST['act']) && $_REQUEST['act'] == 'checkFileIntegrityDetailView')
{	
      
		global $adb,$root_directory;
		$dbQuery = "SELECT * FROM ld_notes where notesid= ?";
		$fileidQuery = "select attachmentsid from ld_seattachmentsrel where crmid = ? ";
		$result = $adb->pquery($dbQuery,array($_REQUEST['noteid']));
		$fileidResult = $adb->pquery($fileidQuery,array($_REQUEST['noteid']));	
		//$activeToinactive_count = 0;
		
		$file_status = $adb->query_result($result,0,"filestatus");
		$download_type = $adb->query_result($result,0,"filelocationtype");
		$notesid = $adb->query_result($result,0,'notesid');
		$fileid = $adb->query_result($fileidResult,0,"attachmentsid");
		$folderid = $adb->query_result($result,0,"folderid");
		$name = $adb->query_result($result,0,"filename");
		/**
       *@edit:andy 
       *@date:20140822
       *@reason:0010880: 知识管理：新增知识管理，上传附件后保存，在明细查看界面点击【 检查附件完整性】，结果提示“该文档不能下载”，实际是能够下载的。
说明	知识管理：新增知识管理，上传附件后保存，在明细查看界面点击【 检查附件完整性】，结果提示“该文档不能下载”，实际是能够下载的。
       *@version:v5.61
       */
        $name=$fileid.'_'.$name;
		if($download_type == 'I'){
			//$saved_filename = $fileid."_".$name;
            $saved_filename = $name;
			$pathQuery = $adb->pquery("select path from ld_attachments where attachmentsid = ?",array($fileid));
			$filepath = $adb->query_result($pathQuery,0,'path');
		
		}
		elseif($download_type == 'E'){
			$saved_filename = $name;
		}
		else
			$saved_filename = '';
			
            /*
            andrew
            20140521
            0008886: 知识管理明细界面：点击检查附件完整性按钮，检查不合理
            */
        //$saved_filenames=iconv('UTF-8','GB2312',$filepath.$fileid.'_'.$saved_filename);
        $saved_filenames=iconv('UTF-8','GB2312',$filepath.$saved_filename);
        $saved_filenamez=iconv('UTF-8','GB2312',$filepath.$saved_filename);
        

        if(file_exists($saved_filenamez))
        {
       	    $saved_filename = $saved_filenamez;
        }
        else
        {           
          
            if(file_exists($saved_filename))
            {
                
            }
            else
            {
                $lastfixs=explode(".",$name);
                $lastfix=$lastfixs[count($lastfixs)-1];
                $saved_filename=$fileid."_1.".$lastfix;
            }
        }
       

        /*
        *edit:diony
        *time：2013-12-28
        *reson:BUG:6530，修改方案：文件类型选择是外部的时候，直接提出无法检测
        */
        if($download_type == 'E'){
			echo "other_integrity";
		}
		else
        {
            //echo $saved_filenames.'----';
            //echo $saved_filename;die();
			if(!file_exists($saved_filename)&&!file_exists($saved_filenames))
    		{
    		  //echo $file_status.'====';
    			if($file_status == 0)
    			{
    				//$dbQuery1 = "update ld_notes set filestatus = 0 where notesid= ?";
    			//	$result1 = $adb->pquery($dbQuery1,array($notesid));
    				echo "lost_integrity";
    			}
    			else 
                {
    				echo "file_not_available";
                }	
    		}
            else 
            {
    			echo "file_available";
    		}
		}
}
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');

?>