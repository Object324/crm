<?php
/**
* @edit:dong
* @data:2020/09/14
* @reason: 导出下载文档附件并压缩
* @description:
*/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $adb,$current_user,$current_language,$currentModule;
$_REQUEST['diony']='yes';
if(isPermitted($currentModule,'DownloadSelected') != 'yes'){
    ConvertTojsonString(0,array('error'=>getFixedLabel('NOPERMITTEDEXECUTE')),'fail');
}
if(checkCurrentModuleHaveAttachmentField() !='yes'){
    ConvertTojsonString(0,array('error'=>getFixedLabel('THISMODULENOTHAVEATTACHMENTFIELDS')),'fail');
}
$tempPath = 'storage/downCacheFile/';
if(!file_exists($tempPath)){
    mkdirs($tempPath);
    chmod($tempPath,0777);
}
$logFile ='storage/downCacheFile/attachmentLogFile.txt';

$idstring = $_REQUEST['idstring'];
$eachExportNum =$_REQUEST['eachExportNum'];
$times =$_REQUEST['times'];
$search_type = $_REQUEST['search_type'];

if(isset($_REQUEST['attachments'])){
    $attachments= json_decode($_REQUEST['attachments'],true);
}
if(isset($_REQUEST['listcounts'])){
    $listcounts=json_decode($_REQUEST['listcounts'],true);
}
if(isset($_REQUEST['log'])){
    $log=json_decode($_REQUEST['log'],true) ;
}
if(isset($_REQUEST['log'])){
    $failNum=json_decode($_REQUEST['failNum'],true);
}
if(isset($_REQUEST['log'])){
    $successNum=json_decode($_REQUEST['successNum']);
}
if(isset($_REQUEST['log'])){
    $tableCode=json_decode($_REQUEST['tableCode'],true);
}
if(isset($_REQUEST['zipName'])){
    $zipName=json_decode($_REQUEST['zipName'],true);
}


if($search_type =='all'){
    //选择所有单据提醒
    ConvertTojsonString(-1,array('error'=>'暂不支持选择全部单据'),'fail');
}
if($search_type =='stop'){
    //点击关闭后删除session
    unset($_SESSION[$currentModule][$current_user->id]['downloadAttachment']);
    die();
}
if($times ==0){
    unset($_SESSION[$currentModule][$current_user->id]['downloadAttachment']);
}
$focus = CRMEntity::getInstance($currentModule);

if($_REQUEST['getprogress']=='yes')
{
    crm_load_class_file("LoginHistory",'modules/Users');
    $historyobj=new LoginHistory();
    $historyobj->user_operation_history('Export',$currentModule);
    include(globalStatic::$root_directory.'modules/lingdang/Export/ExportProgressHtml.php');

}
//    获取订单号
if($search_type =='all'){
    $tableCode = getOrderNo();
}else{
    $tableCode = getOrderNo($idstring);
}

//组合sql

if($eachExportNum ==0){
    if($search_type =='all'){
        //选择所有单据提醒
        ConvertTojsonString(-1,array('error'=>'暂不支持选择全部单据'),'fail');
    }else{
        $sql = 'SELECT ld_seattachmentsrel.crmid,ld_seattachmentsrel.attachmentcolumnname as file_col,ld_attachments.cloud_path,ld_attachments.name,ld_attachments.storage_location,ld_attachments.path,ld_attachments.newfile_name FROM ld_seattachmentsrel  LEFT JOIN ld_attachments ON ld_seattachmentsrel.attachmentsid = ld_attachments.attachmentsid WHERE ';

        // @edit:dong @date:2020/09/16 @reason: 自定义附件无法下载 去除sql中的where条件
        //附件管理模块特殊判断
        if($currentModule == 'Attachment'){
            $sql ='SELECT
                        ld_attachmentsforbillsdetails.attachmentsid AS crmid,
                        \'filename\' AS file_col,
                        ld_attachmentsforbillsdetails.filename AS name,
                        ld_attachmentsforbillsdetails.newfile_name,
                        ld_attachmentsforbillsdetails.path,
                        ld_attachmentsforbillsdetails.storage_location,
                        ld_attachmentsforbillsdetails.cloud_path 
                    FROM
                        ld_attachmentsforbills
                        LEFT JOIN ld_attachmentsforbillsdetails ON ld_attachmentsforbills.attachmentsid = ld_attachmentsforbillsdetails.attachmentsid WHERE  ld_attachmentsforbills.attachmentsid IN ';
        }else{
            // @edit:dong @date:2020/09/21 @reason: 多附件字段 处理
            $fields = $focus->fieldobj->getModuleFields();
            $attachmentColumnnameString ='';
            foreach ($fields as $fieldColumn =>$info ){
                if($info->uitype == 1109 || $info->uitype == 28){//对附件字段的查找
                    empty($attachmentColumnnameString) ? '' : $attachmentColumnnameString .= ',';
                    $attachmentColumnnameString .= "'" . $fieldColumn . "'";
                }else if ($info->uitype == 69) {//XUQIU1002275 weiyannan 对图片字段的查找
                    empty($attachmentColumnnameString) ? '' : $attachmentColumnnameString .= ',';
                    $attachmentColumnnameString .= "'" . $fieldColumn . "'";
                }
            }
            $sql .= ' ld_seattachmentsrel.attachmentcolumnname IN' .'(' .$attachmentColumnnameString .')';
            $sql .=' and  ld_seattachmentsrel.crmid IN  ';
        }

        $sql .= '(' . trim(str_replace(';', ',', $idstring), ',') . ')';


//    导出的单据个数
        $listcounts= count(explode(';',trim($idstring,';')));
    }
//执行sql
    $result = $adb->pquery($sql);
    $row_nums = $adb->num_rows($result);
    $attachments = array();
	$attachment_name = [];
    if ($row_nums > 0) {
        $i = 0;
		$j = 1;
        crm_load_class_file("cls_fieldsearchcondition", "include/utils");
        $fieldSearchObj = cls_fieldsearchcondition::getInstance($focus->module_name);
        while ($row = $adb->fetch_array($result)) {
            //edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
            $crmid = $row['crmid'];
            $col = $row['file_col'];
            $focus->retrieve_entity_info($crmid,$focus->module_name);
            $fieldSearchObj->setColumnValues($focus->column_fieldsm);
            $fieldInfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$col);
            $fieldInfo->setFileAllowed($focus->module_name,$crmid);
            $fileAllowed = $fieldInfo->getFileAllowed($crmid);
            if ($fileAllowed['Download'] === 'no') {
                continue;
            }
            $attachments[$row['crmid']][$i]['DownloadAllwed'] = $fileAllowed['Download'];
            if ($row['storage_location'] == 'cos') {
                $attachments[$row['crmid']][$i]['path'] = $row['cloud_path'];
            } else {
                $attachments[$row['crmid']][$i]['path'] = $row['path'] . $row['newfile_name'];
				if(in_array($row['name'],$attachment_name)){
					$newfiles=explode('.',strtolower($row['name']));
					$filename_str = '';
					if(!empty($newfiles)){
						foreach($newfiles as $key => $file_name){
							if($key + 1 < sizeOf($newfiles)){
								$filename_str.= $file_name;
							}
						}
					}
					$row['name'] = $filename_str . '_'.$j.'.'.$newfiles[sizeof($newfiles)-1];
					$j++;
				}
				$attachment_name[] = $row['name'];
            }
            $attachments[$row['crmid']][$i]['name'] = $row['name'];
            $attachments[$row['crmid']][$i]['storage_location'] = $row['storage_location'];
            $i++;
        }
    }else{
//        如果所选单据没有附件
        ConvertTojsonString(-2,array('error'=>getFixedLabel('NOATTACHMENT')),'success');
    }
    $failNum =0;
    $successNum = 0;

    //循环所有单号 判断哪些单据没有权限
    foreach ($tableCode as $id =>$codeId){
        $hrefHtml = '[<a referencemodule="'.$currentModule.'" referencerecord="'.$id.'" tag="reference_list" >'.$tableCode[$id].'</a>]';
        $idenabled = 1; //初始化 附件模块是  允许查看或下载  默认1 为允许

        $focus->id =$id;
        //ls 2022-03-23 0050565: (https://81mis.com/kfbcrm/index.php? [^])（需要补丁）附件管理的模块共享规则是公开读写》成员“yhaic”，批量下载；提示没有查看详情下载权限；(isenabled从V8.4.3.1已经从ld_field删掉了，永远为null，故该字段已经不能作为判断条件了，有个“下载全部附件”的权限)
        /*if($currentModule == 'Attachment' ){
            $focus->retrieve_entity_info($id,$currentModule);
            $idenabled = $focus->column_fields['isenabled'];
        }*/

        //没有附件模块下载权限 或者 详情单据下载权限都失败
        //管理员不受限制
        if(!is_admin($current_user)){
            $log[$id]= getFixedLabel('BIll').$hrefHtml.getFixedLabel('downloadAttachmentFail');

//            if（（没有下载权限 || 没有查看下载权限 ））
            if($currentModule == "Attachment" && (isPermitted($currentModule,'DownLoad',$id) != 'yes')) {
                /*if($idenabled == 0){
                    $log[$id] .='详情查看下载权限！';
                }*/
//                if (isPermitted($currentModule, 'DownLoad', $id) != 'yes') {
                    $log[$id] .= '下载权限！';
//                }
                $failNum++;
                unset($attachments[$id]);
            }else{
                $log[$id]= getFixedLabel('BIll').$hrefHtml.getFixedLabel('downloadAttachmentSuccess');
                $successNum ++;
            }

        }else{
            $log[$id]= getFixedLabel('BIll').$hrefHtml.getFixedLabel('downloadAttachmentSuccess');
            $successNum ++;
        }
        $log[$id] .= getFixedLabel('Attachment').getFixedLabel('QUANTITY').':'.count((array)$attachments[$id]);
    }
}else{
    //获取当前模块编号的 字段名
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$focus->table_code);
    $fieldLableKey = $fieldinfo->fieldLableKey;

    // 创建或打开压缩文件
    $zip = new ZipArchive();
    if($zipName == '') $zipName  = time().'.zip';
    if(!$zip->open($tempPath.$zipName, ZipArchive::CREATE)){
        echo 'Error, can\'t create a zip file!';
        die();
    }
    //打开压缩包
    $i=1;
    foreach ($attachments as $id =>$idAttachments){
        if($times == $i){
            //压缩包添加文件夹
            $zipPath = changEncode($fieldLableKey.'_'.($tableCode[$id]?$tableCode[$id]:getFixedLabel('Numbers')),true);  //压缩包内文件夹名称
            foreach ($idAttachments as $k=>$attachment){

                if ($attachment['storage_location'] == 'cos') {
                    //下载cos文件 本地测试下载16m文件 没问题
                    downloadFile($attachment['path'],$tempPath.changEncode($attachment['name']));
                    //向压缩包中添加文件
                    $zip->addFile($tempPath . changEncode($attachment['name']),  $zipPath.'/'.changEncode($attachment['name'],true));
                    if(!file_exists($tempPath . changEncode($attachment['name']))){
                        $log[$id] .= ' 提示：附件'.$attachment['name'].'不存在；';
                       }
                    // 记录
                    zipFileLog($logFile,$tempPath.changEncode($attachment['name']));
                    //                    //记录所有的cos下载的文件
                    $cosFile[] = $tempPath.changEncode($attachment['name']);
                } else {
                    $zip->addFile(changEncode($attachment['path']),  $zipPath.'/'.changEncode($attachment['name'],true));
                    if(!file_exists(changEncode($attachment['path']))){
                        $log[$id] .= ' 提示：附件'.$attachment['name'].'不存在；';
                    }
                    //                记录
                    zipFileLog($logFile,changEncode($attachment['path']));
                }

            }
            break;
        }
        $i++;
    }
    $zip->close(); //关闭压缩包
//    获取每次请求的下载cos文件 并删除
    foreach ($cosFile as $file){
        @unlink($file);
    }
}
$prev_totalrows = $eachExportNum *$times;

//进度条
if($_REQUEST['getprogress']=='yes') {
    include(globalStatic::$root_directory . 'modules/lingdang/Export/ExportProgressDescription.php');
    $ret_arr['timedescription'] = $time_description;  //进度条框的文字
    if($times==0)  $ret_arr['timedescription'] = '共有'.$listcounts.'行数据导出';
    $ret_arr['content']=$progresshtml;  //进度条框的html
}
$ret_arr['times'] =$times+1;
crm_load_class_file("cls_MyCRMcrypt",'Register');
$crptobj=new cls_MyCRMcrypt();

$_SESSION["ziprand"]=mt_rand(1000000, 9999999);
//导出完成
if($listcounts <= $prev_totalrows){
    $ret_arr['complete'] ='yes';
    $zipfile = $zipName;
    $newZipName = str_replace('/', '_',getTranstab($currentModule)).'_'.date('Ymd').'.zip';//模块名含有/时，无法下载
    $GBKnewZipName = changEncode($newZipName);
    //GBK的中文乱码 用ConvertTojsonString返回有错误
    @unlink($tempPath.$GBKnewZipName);
    rename($tempPath.$zipName,$tempPath.$GBKnewZipName);
    
  //  $ret_arr['ziprand']=$_session["ziprand"];
   
    $ret_arr['zipfile'] = $crptobj->encode($tempPath.$newZipName.$_SESSION["ziprand"]);  
//    打包的附件是否存在 所有单据都没有附件则压缩文件不存在 不存在不直接下载文件
    $ret_arr['zipfileStatus'] = file_exists($tempPath.$newZipName) ? 'yes':'no';
//    记录
    zipFileLog($logFile,$tempPath.changEncode($newZipName));
    //文件日志
    $ret_arr['downLogTitle']=getFixedLabel('DOWNLOADFILE');
    $ret_arr['log']='<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.sprintf(getFixedLabel('DOWNLOADFILENUM'),$listcounts,$successNum,$failNum).'</div></div>';
    $ret_arr['log'] .="<div class='pop_prc_content'>";
    foreach ($log as $key=>$value){
        $logHtml .= $value.'<br/>';
    }
    $ret_arr['log'] .= $logHtml.'</div>';


}else{
    //$ret_arr['zipfile'] = $crptobj->encode(globalStatic::$root_directory).$_session["ziprand"];  
    $ret_arr['complete'] ='no';
    $ret_arr['tableCode'] =$tableCode;
    $ret_arr['attachments']=$attachments;
    $ret_arr['listcounts']=$listcounts;
    $ret_arr['log']=$log;
    $ret_arr['failNum']=$failNum;
    $ret_arr['successNum']=$successNum;
    $ret_arr['zipName']=$zipName;
}

$ret_arr['title']=getTranstab($currentModule).'>'. getFixedLabel('DOWNLOADFILE');

ConvertTojsonString(1,$ret_arr,'success');


//改变编码
function changEncode($str,$true=false){
//    $arr=array("ASCII","UTF-8","GB2312","GBK",'BIG-5');
//    $encode=mb_detect_encoding($string, $arr);
//    strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'
    if(strtolower(substr(PHP_OS,0,3))=='win' || $true){
        $str= mb_convert_encoding($str,'gbk','auto');
    }
    return $str;
}
//记录压缩时 被压缩文件是否存在
function zipFileLog($logFile,$filename){
    global  $current_user;
    $status = changEncode(file_exists($filename)? '存在':'不存在');
    file_put_contents($logFile,'id:'.$current_user->id .'-'.date('Y-m-d H:i:s').'-'.$filename.'-'.$status."\r\n",FILE_APPEND);
}

/**
 * Name: 下载cos的附件
 * User: Dong
 * Date: 2020/6/22 14:53
 * @param $fileUrl
 * @param $filename
 * @return mixed
 */
function downloadFile($fileUrl,$filename) {
    set_time_limit(0);
    $hostfile = fopen($fileUrl, 'r');
    $fh = fopen($filename, 'w');
    while (!feof($hostfile)) {
        $output = fread($hostfile, 2048);
        fwrite($fh, $output);
    }
    fclose($hostfile);
    fclose($fh);
}

//通过id获取订单编号
function getOrderNo($ids =''){
    global  $adb,$currentModule;
    $focus =CRMEntity::getInstance($currentModule);
    $tablename = $focus->table_name;
    $table_index = $focus->table_index;
    $table_code = $focus->table_code;
    $sql = 'SELECT '.$table_index.','.$table_code.'  FROM '. $tablename .' where deleted =0  ';
    if($ids != ''){
        $sql .= ' and '. $table_index.' in ';
        $sql .= '('.trim(str_replace(';',',',$ids),',').')';
    }
    $result = $adb->pquery($sql);
    $row_nums = $adb->num_rows($result);
    $returnArr =array();
    if($row_nums>0){
        for($i=0;$i<$row_nums;$i++){
            $id = $adb->query_result($result,$i,$table_index);
            $returnArr[$id] = $adb->query_result($result,$i,$table_code);
        }
    }
    return $returnArr;
}
