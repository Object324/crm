<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user,$adb,$languageType;

if(isset($_REQUEST['module']) && !empty($_REQUEST['module'])){
    $module = $_REQUEST['module'];
}else{
    $module = 'Equipment';
}
$focus = CRMEntity::getInstance($module);
$selected_ids = '';
if(isset($_REQUEST['selected_ids']) && !empty($_REQUEST['selected_ids'])){
    $selected_ids = $_REQUEST['selected_ids'];
}

if(!empty($selected_ids)){
    
    $sql = 'SELECT ld_seattachmentsrel.crmid,ld_seattachmentsrel.attachmentcolumnname as file_col,ld_attachments.cloud_path,ld_attachments.name,ld_attachments.storage_location,ld_attachments.path,ld_attachments.newfile_name 
            FROM ld_seattachmentsrel  LEFT JOIN ld_attachments ON ld_seattachmentsrel.attachmentsid = ld_attachments.attachmentsid WHERE ';

    $attachmentColumnname_arr = ['"qrcodeimage"','"barcodeimage"'];
    $attachmentColumnname_str = implode(',',$attachmentColumnname_arr);
    $sql .= ' ld_seattachmentsrel.attachmentcolumnname IN' . '(' . $attachmentColumnname_str . ')';

    if($seleted_ids != 'all'){
        $selected_ids_arr = explode(';',$selected_ids);
        $selected_ids_arr = array_values($selected_ids_arr);
        $sql .= ' and ld_seattachmentsrel.crmid IN  ';
        $sql .= '(' . trim(str_replace(';', ',', $selected_ids), ',') . ')';
    }

    // 导出的单据个数
    $listcounts = count(explode(';', trim($idstring, ';')));
    //执行sql
    $result = $adb->pquery($sql);
    // dump($result);
    $row_nums = $adb->num_rows($result);
    $attachments = array();
    $attachment_name = [];
    if ($row_nums > 0) {
        // $i = 0;
        crm_load_class_file("cls_fieldsearchcondition", "include/utils");
        $fieldSearchObj = cls_fieldsearchcondition::getInstance($focus->module_name);
        while ($row = $adb->fetch_array($result)) {
            $tmp_attachmentinfo_arr = [];
            //edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
            $crmid = $row['crmid'];
            if($seleted_ids == 'all'){
                $selected_ids_arr[] = $crmid;
            }
            $col = $row['file_col'];
            $focus->retrieve_entity_info($crmid, $focus->module_name);
            $fieldSearchObj->setColumnValues($focus->column_fields);
            $fieldInfo = $focus->fieldobj->getFieldInfoobjBykey('columnname', $col);
            $fieldInfo->setFileAllowed($focus->module_name, $crmid);
            $fileAllowed = $fieldInfo->getFileAllowed($crmid);
            if ($fileAllowed['Download'] === 'no') {
                continue;
            }
            $tmp_attachmentinfo_arr['DownloadAllwed'] = $fileAllowed['Download'];
            if ($row['storage_location'] == 'cos') {
                $tmp_attachmentinfo_arr['path'] = $row['cloud_path'];
            } else {
                $tmp_attachmentinfo_arr['path'] = $row['path'] . $row['newfile_name'];
                
            }
            $tmp_attachmentinfo_arr['name'] = $row['name'];
            $tmp_attachmentinfo_arr['recordname'] = $focus->column_fields['equipmentname'];
            $tmp_attachmentinfo_arr['record_no'] = $focus->column_fields['equipment_no'];
            $tmp_attachmentinfo_arr['equipmentcode'] = $focus->column_fields[$focus->code_fieldname];
            $tmp_attachmentinfo_arr['storage_location'] = $row['storage_location'];
            $attachments[$row['crmid']][] = $tmp_attachmentinfo_arr;
            // $i++;
        }

    } else {
        // 如果所选单据没有附件
        ConvertTojsonString(-2, array('error' => getFixedLabel('NOATTACHMENT')), getFixedLabel('NOATTACHMENT'));
    }
    //循环所有单号 判断哪些单据没有权限
    foreach ($selected_ids_arr as $index => $id) {
        if(empty($id)){
            continue;
        }
        $hrefHtml = '[<a referencemodule="' . $module . '" referencerecord="' . $id . '" tag="reference_list" >' . getModuleHref($module,$id) . '</a>]';

        $focus->id = $id;

        $log[$id] = getFixedLabel('BIll') . $hrefHtml . getFixedLabel('ExportDevicecode') . getFixedLabel('Sent_successfully');
        $successNum++;
        
        // $log[$id] .= getFixedLabel('Attachment') . getFixedLabel('QUANTITY') . ':' . count($attachments[$id]);
    }

    //获取当前模块编号的 字段名
    // $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("fieldname",$focus->code_fieldname);
    // $fieldLableKey = $fieldinfo->fieldLableKey;
    // $fieldLableKey = str_replace('/', '|', $fieldLableKey);
    
    // 创建或打开压缩文件
    $zip = new ZipArchive();

    $zipName = getFixedLabel('Devicecode') . '.zip';
    $tempPath = 'storage/'.strtolower($module).'/';
    // 先删除之前生成的
    if(file_exists($tempPath . $zipName)){
        @unlink($tempPath . $zipName);
    }
    if (!$zip->open($tempPath . $zipName, ZipArchive::CREATE)) {
        echo 'Error, can\'t create a zip file!';
        die();
    }
    // dump($attachments);
    //打开压缩包
    foreach ($attachments as $id => $idAttachments) {
        //压缩包添加文件夹
        $zipPath = (str_replace('/', '|', $idAttachments[0]['recordname']) . '-' . str_replace('/', '|', $idAttachments[0]['record_no']) . '-' . str_replace('/', '|', $idAttachments[0]['equipmentcode']));  //压缩包内文件夹名称
        foreach ($idAttachments as $k => $attachment) {

                $zip->addFile(($attachment['path']), $zipPath . '/' . $attachment['name']);
                if (!file_exists(($attachment['path']))) {
                    $focus->id = $id;
                    $focus->retrieve_entity_info($id,$module);
                    $codeimagepath_arr = $focus->createCodeImages($focus->code_fieldname);// 生成二维码/条形码编码
                    $focus->saveCodeImagesToAttachment($codeimagepath_arr);
                    if (!file_exists(($attachment['path']))) {
                        $hrefHtml = '[<a referencemodule="' . $module . '" referencerecord="' . $id . '" tag="reference_list" >' . getModuleHref($module,$id) . '</a>]';
                        $log[$id] = getFixedLabel('BIll') . $hrefHtml . getFixedLabel('ExportDevicecode') . getFixedLabel('Failed_to_send');
                        $log[$id] .= ' 提示：' . $attachment['name'] . '不存在；';
                    }
                }
        }
        // break;
    }
    $zip->close(); //关闭压缩包
    
    crm_load_class_file("cls_MyCRMcrypt", 'Register');
    $crptobj = new cls_MyCRMcrypt();

    $_SESSION["ziprand"] = mt_rand(1000000, 9999999);
    //导出完成
    // if ($listcounts <= $prev_totalrows) {
        $ret_arr['complete'] = 'yes';
        $zipfile = $zipName;
        $newZipName = str_replace('/', '_', getFixedLabel('Devicecode')) . '.zip';//模块名含有/时，无法下载

        $ret_arr['zipfile'] = $crptobj->encode($tempPath . $newZipName . $_SESSION["ziprand"]);
        // 打包的附件是否存在 所有单据都没有附件则压缩文件不存在 不存在不直接下载文件
        $ret_arr['zipfileStatus'] = file_exists($tempPath . $newZipName) ? 'yes' : 'no';
        // 记录
        // zipFileLog($logFile, $tempPath . changEncode($newZipName));
        //文件日志
        $ret_arr['downLogTitle'] = getFixedLabel('ExportDevicecode');
        $ret_arr['log'] = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">' . sprintf(getFixedLabel('DOWNLOADFILENUM'), $listcounts, $successNum, $failNum) . '</div></div>';
        $ret_arr['log'] .= "<div class='pop_prc_content'>";
        foreach ($log as $key => $value) {
            $logHtml .= $value . '<br/>';
        }
        $ret_arr['log'] .= $logHtml . '</div>';


    // }

    $ret_arr['title'] = getFixedLabel('ExportDevicecode');
    // dump($ret_arr);

    ConvertTojsonString(1, $ret_arr, 'success');
}

?>