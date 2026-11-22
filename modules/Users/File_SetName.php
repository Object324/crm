<?php

/**
 * @author yyy
 * @copyright 2015
 */
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
 global $adb,$currentModule;
 $filename = $_REQUEST['filename'];//附件名称
 $module_name=$_REQUEST['formmodule'];
 $uitype=$_REQUEST['uitype'];
// dump($module_name);
//$filename = urldecode($filename);
 $filename=str_replace(" ","_",$filename);
 //$filename=$adb->mysql_real_escape_string($filename);
 /*$file_path = globalStatic::$root_directory."modules/Attachment/attachments.txt";
 $filehandle = fopen($file_path,"r");
 $filestring= fgets($filehandle);
 $fileTypes=explode(',',$filestring);*/
$query = 'select GROUP_CONCAT(file_type) from ld_attachmentstype where module_name=? ';
$result = $adb->pquery($query,array($module_name));
$num_rows = $adb->num_rows($result);
$file_type = $adb->query_result($result,0,0);
if($num_rows > 0  && !empty($file_type)){
    $file_type=str_replace("，",",",$file_type);
    $fileTypes = explode(',',$file_type);
}else{
    $query1 = "select GROUP_CONCAT(file_type) from ld_attachmentstype where module_name ='' or module_name is null  ";
    $result1 = $adb->pquery($query1,array());
    $file_type = $adb->query_result($result1,0,0);
    $file_type=str_replace("，",",",$file_type);
    $fileTypes = explode(',',$file_type);
}
//打印模块创建，导入打印模板
if(!empty($_REQUEST['creaetetemplate']) && $_REQUEST['creaetetemplate'] == 'yes'){
	$fileTypes = array('xls','html','xlsx');
}
$fileParts = pathinfo($filename);
//wyt 220909 BUG0056185 客户-新增/详情界面-附件的允许格式，会影响到图片字段的上传
if (!in_array(strtolower($fileParts['extension']),$fileTypes) && $uitype=='1109') {
    @ob_clean();
    @ob_flush();
    $jarr['type']=3;
    $jarr['filename']=$filename;
    echo $str=json_encode($jarr);//将数组进行json编码
    exit();
}
$sys = getSys_deploy(77);
$type = 0;//0 成功 1 失败
$warning = 0;//0 不提示 1 提示  2禁止

/*if($sys['deploy_value'] == 0){//不限制
    $type = 0;
}else if($sys['deploy_value'] == 1 || $sys['deploy_value'] == 2){//提示
    //$query = 'select filename from ld_attachmentsforbills where deleted=0 and  filename =?';
    //Liver 2017-04-10,bug0027621: 控制面板》系统参数设置同名附件上传限制方式禁止，提示，不限制，附件上传没有增加同名附件的限制 
    if($_REQUEST['formmodule']=='Documents'){
        $query ='SELECT ld_attachments.name as filename FROM ld_notes
                 LEFT JOIN ld_seattachmentsrel on ld_notes.notesid=ld_seattachmentsrel.crmid
                 LEFT JOIN ld_attachments on ld_attachments.attachmentsid=ld_seattachmentsrel.attachmentsid
                 where ld_notes.deleted=0 AND ld_attachments.name=?';
    	if(!empty($_REQUEST['arr_record'])){
    		$query .= ' and attachmentsid != ' . $_REQUEST['arr_record'];
    	}
    }else{
        $query ='SELECT ld_attachmentsforbillsdetails.filename FROM ld_attachmentsforbills
         left join ld_attachmentsforbillsdetails on ld_attachmentsforbills.attachmentsid=ld_attachmentsforbillsdetails.attachmentsid
         where deleted=0 and ld_attachmentsforbillsdetails.filename =?';
    	if(!empty($_REQUEST['arr_record'])){
    		$query .= ' and attachmentsid != ' . $_REQUEST['arr_record'];
    	}
    }   

    $result = $adb->pquery($query,array($filename));
    $num_rows = $adb->num_rows($result);
    if($num_rows >= 1){
        $type = 1;
		if($sys['deploy_value'] == 2){
			$warning = 2;
		}else{
			$warning = 1;	
		}
    }
    else{
        $type = 0;   
    }
}*/
$type = 0;
@ob_clean();
@ob_flush();
$jarr['type']=$type;
$jarr['warning'] = $warning;
$jarr['filename']=$filename;
echo $str=json_encode($jarr);//将数组进行json编码 
exit();

?>