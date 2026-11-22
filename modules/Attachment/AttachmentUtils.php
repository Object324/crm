<?php
/**
 *整理CommonUtils.php 中 【附件】 相关的方法到这里  zxm 20221125
 */
require_once globalStatic::$root_directory.'Register/cls_MyCRMcrypt.php';

class AttachmentUtils {
    private static $instanceobj;
    //zkt 20231026 添加getInstance方法
    public function __construct()
    {


    }
    public static function   getInstance()
    {
        if(!empty(self::$instanceobj))
        {
            return self::$instanceobj;
        }
        self:: $instanceobj=new AttachmentUtils();
        return self::$instanceobj;

    }
    public function getApplictionType($type)
    {
        if($type == 'gif')
        {
            $apptype = 'image/gif';
        }
        else if($type == 'jpg'||$type == 'jpeg')
        {
            $apptype = 'image/jpeg';
        }
        else if($type == 'png')
        {
            $apptype = 'image/png';
        }
        else if($type == 'bmp')
        {
            $apptype = 'image/bmp';
        }
        else if($type == 'txt'||$type == 'log')
        {
            $apptype = 'text/plain';
        }
        else if($type == 'doc')
        {
            $apptype = 'application/msword';
        }
        else if($type == 'xls')
        {
            $apptype = 'application/vnd.ms-excel';
        }
        else if($type == 'zip')
        {
            $apptype = 'application/zip';
        }
        else if($type == 'html'||$type == 'htm')
        {
            $apptype = 'text/html';
        }
        else if($type == 'ppt')
        {
            $apptype = 'application/vnd.ms-powerpoint';
        }
        else if($type == 'pdf')
        {
            $apptype = 'application/pdf';
        }
        else if($type == 'js')
        {
            $apptype = 'application/x-javascript';
        }
        else if($type == 'xml')
        {
            $apptype = 'text/xml';
        }
        else if($type == 'rar' || $type == 'psd' || $type == '7z' ||
            $type == 'exe' || $type == '3gp' || $type == 'flv' ||
            $type == 'krc' || $type == 'lrc' || $type == 'chm' ||
            $type == 'sql' || $type == 'con' || $type == 'dat' ||
            $type == 'ini' || $type == 'php' || $type == 'ttf' ||
            $type == 'fon' || $type == 'dll' )
        {
            $apptype = 'application/octet-stream';
        }
        else if($type == 'ico')
        {
            $apptype = 'image/x-icon';
        }
        else if($type == 'avi')
        {
            $apptype = 'video/avi';
        }
        else if($type == 'rmvb')
        {
            $apptype = 'application/vnd.rn-realmedia-vbr';
        }
        else if($type == 'mp3')
        {
            $apptype = 'audio/mpeg';
        }
        else if($type == 'wav')
        {
            $apptype = 'audio/wav';
        }
        else if($type == 'mdb')
        {
            $apptype = 'application/msaccess';
        }
        else
        {
            $apptype = $type;
        }

        return $apptype;
    }

    /**
     * 获取附件信息
     *
     * */
    public function getAttachmentForBills($record,$module)
    {
        global $adb;
        $create=vtlib_purify($_REQUEST['Create']);
        $focus = CRMEntity::getInstance($module);
        $module_fields = $focus->fieldobj->getModuleFields();
        foreach ($module_fields as $field) {
            if ($field->fieldName == 'filename') {// ljj 2023-08-31 BUG0071944 kfbcrm-附件管理-设置附件字段内容不允许复制
                if ($field->disallowed_copy == 'yes' && $create == 'true') {// ljj 20230905 BUG0072032 kfbcrm-附件管理模块-当相关对象为 空 时，“附件”字段“是否能复制”应根据“附件管理”模块“附件”字段权限控制
                    $json_fileinfo = '';
                } else {
                    $cls_MyCRMcrypt = new cls_MyCRMcrypt();
                    $fileattach = "SELECT
                            ld_attachmentsforbills.*,ld_attachmentsforbillsdetails.*, ld_users.last_name FROM ld_attachmentsforbills
                            LEFT JOIN ld_users ON ld_attachmentsforbills.creator = ld_users.id
                            inner JOIN ld_attachmentsforbillsdetails ON ld_attachmentsforbills.attachmentsid=ld_attachmentsforbillsdetails.attachmentsid
                            WHERE ld_attachmentsforbills.attachmentsid =?
                            and ld_attachmentsforbills.deleted=0";
                    $result = $adb->pquery($fileattach, array($record));
                    $result_nums = $adb->num_rows($result);
                    if ($result_nums > 0) {
                        //edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
                        $field->setFileAllowed($module,$recordid);
                        $fileAllowed = $field->getFileAllowed($recordid);
                        for ($i = 0; $i < $result_nums; $i++) {
                            $attachmentsid = $adb->query_result($result, $i, 'attachmentsid');
                            $id = $adb->query_result($result, $i, 'id');
                            $recordid = $record;
                            $attname = html_entity_decode((string)$adb->query_result($result, $i, 'filename'));
                            $isenabled = $adb->query_result($result, $i, 'isenabled');
                            $size = $adb->query_result($result, $i, 'size');
                            $storage_location = $adb->query_result($result, $i, 'storage_location');
                            $path = html_entity_decode((string)$adb->query_result($result, $i, 'path'));
                            $cloud_path = html_entity_decode((string)$adb->query_result($result, $i, 'cloud_path'));
                            //if($storage_location=='cos')
                            //            {
                            //                $path=$cloud_path;
                            //            }
                            $file_type = $adb->query_result($result, $i, 'type');
                            $newfile_name = html_entity_decode((string)$adb->query_result($result, $i, 'newfile_name'));

                            //edit: xll XUQIU1001183 下载优化：newfile_name、path、cloud_path加密
                            $path = $cls_MyCRMcrypt->encode($path);
                            $cloud_path = $cls_MyCRMcrypt->encode($cloud_path);
                            $newfile_name = $cls_MyCRMcrypt->encode($newfile_name);
                            $isEncrypt = 'yes';


                            // edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（生成预览按钮并返回）
                            $httppath = $cls_MyCRMcrypt->decode($cloud_path);
                            $pre_path = $cls_MyCRMcrypt->decode($path) . $cls_MyCRMcrypt->decode($newfile_name);
                            $file = array('id' => $id, 'storage_location' => $storage_location, 'httppath' => $httppath,
                                'pre_path' => $pre_path, 'name' => $attname, 'type' => $file_type, 'isEncrypt' => $isEncrypt,
                                'path' => $path, 'cloud_path' => $cloud_path, 'newfile_name' => $newfile_name);

                            //edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
                            $pre_button = '';
                            if($fileAllowed['Preview'] === 'yes') {
                                $pre_button = self::getPreviewButton($file);
                            }

                            $file_info[] = array('file_name' => $attname, 'file_size' => $size, 'file_type' => $file_type
                            , 'file_path' => $path, 'cloud_path' => $cloud_path, 'newfile_name' => $newfile_name, 'fileid' => $id, 'storage_location' => $storage_location, 'isEncrypt' => $isEncrypt
                            , 'pre_button' => $pre_button);
                        }
                    }
                    $json_fileinfo = Zend_Json::encode($file_info);
                }
            }
        }
        return $json_fileinfo;
    }

    public function getImageFileInfo($record,$module)
    {
        global $adb;
        if(empty($record))
        {
            $json_fileinfo = Zend_Json::encode($fieldvalue);
            return $json_fileinfo;
        }
        $module_name=$module;
        $focus=CRMEntity::getInstance($module);
        $maintablename=$focus->table_name;
        $maintableindex=$focus->table_index;
        $query = "select ld_attachments.path, ld_attachments.attachmentsid, ld_attachments.name,ld_attachments.newfile_name ,ld_attachments.size,ld_attachments.type,
        ld_crmentity.setype from $maintablename left join ld_seattachmentsrel on 
        ld_seattachmentsrel.crmid=$maintablename.$maintableindex inner join ld_attachments on
        ld_attachments.attachmentsid=ld_seattachmentsrel.attachmentsid inner join ld_crmentity 
        on ld_crmentity.crmid=ld_attachments.attachmentsid 
        where ld_crmentity.setype=? and $maintableindex=?";
        $result_image = $adb->pquery($query, array($module_name.' image',$record));
        $image_array = [];
        for($image_iter=0;$image_iter < $adb->num_rows($result_image);$image_iter++)
        {
            $image_id_array[] = $adb->query_result($result_image,$image_iter,'attachmentsid');
            $image_array[] = urlencode(decode_html($adb->query_result($result_image,$image_iter,'name')));
            $image_orgname_array[] = decode_html($adb->query_result($result_image,$image_iter,'name'));
            $image_newfilename_array[] = decode_html($adb->query_result($result_image,$image_iter,'newfile_name'));
            $image_path_array[] = $root_dictionary.$adb->query_result($result_image,$image_iter,'path');
            $image_size_array[]= $adb->query_result($result_image,$image_iter,'size');
            $image_type_array[]=$adb->query_result($result_image,$image_iter,'type');

        }
        for($img_itr=0;$img_itr<count($image_array);$img_itr++)
        {
            $arr=explode('.',$image_array[$img_itr]);
            $imagename= $image_orgname_array[$img_itr];
            $imagepath=$image_path_array[$img_itr] ;
            $newfile_name=$image_newfilename_array[$img_itr];
            $fileid=$image_id_array[$img_itr];

            $size=$image_size_array[$img_itr];

            if(empty($size))
            {
                $size=1;
            }

            $fieldvalue[] = array('file_name'=>$imagename, 'newfile_name'=>$newfile_name, 'file_path'=>$image_path_array[$img_itr]
            ,"file_size"=>$size,'file_type'=>$image_type_array[$img_itr]
            ,'fileid'=>$fileid);
        }
        $json_fileinfo = Zend_Json::encode($fieldvalue);
        return $json_fileinfo;
    }

    /**
     * 获取当前模块所有附件(包括图片字段)
     * */
    public function getAllFile_imageInfo($record,$module)
    {
        static  $static_getAllFile_imageInfo;
        if(is_array($static_getAllFile_imageInfo[$record]) && $module != 'ModComments')
        {
            return $static_getAllFile_imageInfo[$record];
        }
        //duan20241227 添加一个不带缓存的方法，方便在单据更新后调用
        $file_info = $this->getAllFile_imageInfo_nocache($record,$module);

        $static_getAllFile_imageInfo[$record]=$file_info;
        return $file_info;
    }
    //ls 2022-06-13 【ID1002721】单据分录定制，增加“图片”字段类型
    // 获取当前模块分录图片字段信息
    public function getAllDetailFile_imageInfo($record,$module)
    {
        global $adb,$site_URL;
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();
        static  $static_getAllDetailFile_imageInfo;
        if(is_array($static_getAllDetailFile_imageInfo))
        {
            return $static_getAllDetailFile_imageInfo;
        }

        $file_info=[];

        $focus=CRMEntity::getInstance($module);
        $Detail_table_name=$focus->Detail_table;
        $Detail_table_id=$focus->Detail_table_id;

        if($module == 'CashBill'||$module == 'SendCashBill'||(get_file_address($module,"ProductDetails")&&$module!='ServiceCharge'))
        {
            $sql="select $Detail_table_name.sequence_no,ld_detailattachments.* from ld_detailattachments INNER JOIN $Detail_table_name on $Detail_table_name.$Detail_table_id = ld_detailattachments.lineitem_id WHERE ld_detailattachments.crmid=?";
        }else{
            $sql="select $Detail_table_name.sequence as sequence_no,ld_detailattachments.* from ld_detailattachments INNER JOIN $Detail_table_name on $Detail_table_name.$Detail_table_id = ld_detailattachments.lineitem_id WHERE ld_detailattachments.crmid=?";

        }

        $result=$adb->pquery($sql,array($record));
        $rows=$adb->num_rows($result);

        for($i=0;$i<$rows;$i++)
        {
            $id=$adb->query_result($result,$i,'id');
            $sequence_no=$adb->query_result($result,$i,'sequence_no');
            $recordid = $record;
            $lineitem_id = $adb->query_result($result,$i,'lineitem_id');
            $attname = $adb->query_result($result,$i,'name');

            $size = $adb->query_result($result,$i,'size');
            $path = $adb->query_result($result,$i,'path');
            $cloud_path = $adb->query_result($result,$i,'cloud_path');
            $file_type = $adb->query_result($result,$i,'type');
            $newfile_name=$adb->query_result($result,$i,'newfile_name');
            $columnname=$adb->query_result($result,$i,'columnname');
            $storage_location = $adb->query_result($result,$i,'storage_location');
            $imagefromtype = $adb->query_result($result,$i,'imagefromtype');
            $upload_from = $adb->query_result($result,$i,'upload_from');

            if(checkFileNameIsImg($newfile_name)){
                if($storage_location=='cos'){
                    $filepath_noEncrpt = $cloud_path;
                }else{
                    $filepath_noEncrpt =  $path.$newfile_name;
                }
            }
            //edit: xll XUQIU1001183 下载优化：newfile_name、path、cloud_path加密
            $path = $cls_MyCRMcrypt -> encode($path);
            $cloud_path = $cls_MyCRMcrypt -> encode($cloud_path);
            $newfile_name = $cls_MyCRMcrypt -> encode($newfile_name);
            $isEncrypt = 'yes';

            //if($storage_location=='cos'){
//                $file_path = $cloud_path;
//            }else{
//                $file_path = $path;
//            }

            //分录编辑
            if(is_numeric($size)){
                if ($size < 1024)
                    $size = $size . ' B';
                elseif ($size > 1024 && $size < 1048576)
                    $size = round($size / 1024, 2) . ' KB';
                else if ($size > 1048576)
                    $size = round($size / (1024 * 1024), 2) . ' MB';
            }

            // edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（生成预览按钮并返回）
            $httppath = $cls_MyCRMcrypt -> decode($cloud_path) ;
            $pre_path = $cls_MyCRMcrypt -> decode($path) . $cls_MyCRMcrypt -> decode($newfile_name);
            $file = array('id'=>$id,'storage_location'=>$storage_location,'httppath'=>$httppath,
                'pre_path'=>$pre_path,'name'=>$attname,'type'=>$file_type,'isEncrypt'=>$isEncrypt,
                'path'=>$path,'cloud_path'=>$cloud_path,'newfile_name'=>$newfile_name);
            $pre_button = self::getPreviewButton($file);

            $file_info[$sequence_no][$columnname][] = array('file_name'=>$attname,'file_size'=>$size
            ,'file_type'=>$file_type,'file_path'=>$path,'newfile_name'=>$newfile_name
            ,'cloud_path'=>($cloud_path)
            ,'fileid'=>$id,'storage_location'=>$storage_location,'imagefromtype'=>$imagefromtype,'upload_from'=>$upload_from, 'isEncrypt'=>$isEncrypt
            ,'pre_button'=>$pre_button,'lineitem_id'=>$lineitem_id,'filepath_noEncrpt'=>$filepath_noEncrpt);
        }
        $static_getAllDetailFile_imageInfo=$file_info;
        return $file_info;
    }
    public function getAttachmentsTableInfo($record,$module,$columnname)
    {
        global $adb;
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();
        if(empty($record))
        {
            //  $file_info[] = array('file_name'=>"",'file_size'=>"",'file_type'=>"",'file_path'=>"");
            return Zend_Json::encode($file_info);
        }
        $focus=CRMEntity::getInstance($module);
        $tablename=$focus->table_name;
        $tableindex=$focus->table_index;
        $deletedetailsql='select ld_attachments.*   from ld_attachments 
            inner join ld_seattachmentsrel on ld_seattachmentsrel.attachmentsid=ld_attachments.attachmentsid
            WHERE  ld_seattachmentsrel.crmid=?
            and ld_seattachmentsrel.attachmentcolumnname=?;';
        $result=$adb->pquery($deletedetailsql,array($record,$columnname));
        $result_nums=$adb->num_rows($result);
        if($result_nums>0)
        {
            $allattachmentsid=$adb->query_result($result,0,0);
            if(empty($allattachmentsid))
            {
                return Zend_Json::encode($file_info);
            }
            /*  $sql="select ld_attachments.* from ld_attachments
                  INNER JOIN ld_seattachmentsrel on ld_attachments.attachmentsid=ld_seattachmentsrel.attachmentsid
                  where ld_attachments.attachmentsid in($allattachmentsid) ";
              $result=$adb->pquery($sql,array());*/
            $result_nums=$adb->num_rows($result);
            for($i=0;$i<$result_nums;$i++){


                $id=$adb->query_result($result,$i,'attachmentsid');
                $recordid = $record;
                $attname = $adb->query_result($result,$i,'name');

                $size = $adb->query_result($result,$i,'size');
                $path = $adb->query_result($result,$i,'path');
                $file_type = $adb->query_result($result,$i,'type');
                $newfile_name=$adb->query_result($result,$i,'newfile_name');

                //edit: xll XUQIU1001183 下载优化：newfile_name、path、cloud_path加密
                $path = $cls_MyCRMcrypt -> encode($path);
                //$cloud_path = $cls_MyCRMcrypt -> encode($cloud_path);
                $newfile_name = $cls_MyCRMcrypt -> encode($newfile_name);
                $isEncrypt = 'yes';

                // edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（生成预览按钮并返回）
                $httppath = '';
                $pre_path = $cls_MyCRMcrypt -> decode($path) ;
                $file = array('id'=>$id,'storage_location'=>'','httppath'=>$pre_path,
                    'pre_path'=>$pre_path,'name'=>$attname,'type'=>$file_type,'isEncrypt'=>$isEncrypt,
                    'path'=>$path,'cloud_path'=>'','newfile_name'=>$newfile_name);
                $pre_button = self::getPreviewButton($file);

                $file_info[] = array('file_name'=>$attname,'file_size'=>$size
                ,'file_type'=>$file_type,'file_path'=>$path,'newfile_name'=>$newfile_name
                ,'fileid'=>$id, 'isEncrypt'=>$isEncrypt,'pre_button'=>$pre_button);
            }
            $json_fileinfo = Zend_Json::encode($file_info);
            return $json_fileinfo;
        }
    }
    public function getAttachmentListViewHtml($showvalue, $module, $recordId)
    {
        foreach ($showvalue['value'] as $fileinfo) {
            if($fileinfo['storage_location'] == 'cos'){
                $imgpath =$fileinfo['cloud_path'];
            }else{
                $imgpath = dirname($fileinfo['filepath']) . DIRECTORY_SEPARATOR . $fileinfo['newfile_name'];
            }
            $value .= '<span class="attachments-padL11">';
            $value .= $fileinfo['filename'];
            $value .= '<span>';
            //edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
            if (IsDownLoadProfile($recordId, $module) == 'yes' && $fileinfo['fileAllowed']['Download'] === 'yes'){
                //zkt 20240605 BUG20240520-64  V8.6.2.6 其他——工作记录单-旧模块，23年创建查询分类将附件字段放在序时簿界面，通过序时簿界面下载录屏、录音文件时会跳转到类似预览界面，不能正常下载
                $value .= '<a class="padL8" download="" href="index.php?module=uploads&action=downloadfile&return_module=' . $module . '&fileid=' . $fileinfo['attachmentsid'] . '&entityid=' . $recordId . '" onclick="javascript:dldCntIncrease(\'' . $recordId . '\');"><span>' . getFixedLabel("DOWNLOAD") . '</span></a>';
            }
            if (IsPreviewProfile($recordId, $module) == 'yes' && $fileinfo['storage_location'] != 'awsserver' && $fileinfo['fileAllowed']['Preview'] === 'yes'){
                // @edit:dong @date:2020/07/31 @reason:  判断附件是否是图片
                if(checkFileNameIsImg($fileinfo['newfile_name'])){
                    $value .= '<img  style="display:none" src="'.$imgpath.'">';
                    // @edit:dong @date:2020/07/22 @reason:附件字段，点击查看图片附件，增加图片预览插件；
                    $value .= '<a class="padL8" href="javascript:void(0);"  onclick="previewImage(ld(this).parents(\'td\')[0]);ld(this).parent().find(\'img\').click();savePreviewlog('.$recordId.','
                        .$fileinfo['attachmentsid'].',\''.$module.'\',\''.$fileinfo['filename'].'\');"><span>' . getFixedLabel("PREVIEW") . '</span></a>';
                }elseif(checkFileNameIsVideo($fileinfo['newfile_name'])){
                    //@edit:liushuai,2021-04-21,reason: 0045556: OA表单-请假单，单据编号QJ18，数据分类“成员查看”，附件显示在列表处时，点击预览视频没有直接打开，会进入新页签
                    $value .= '<video controls="controls" id="video_'.$fileinfo['attachmentsid'].'" style="display: none;">
                                        <source src="'.$imgpath.'" type="video/mp4">
                                        <source src="'.$imgpath.'" type="video/webm">
                                        <source src="'.$imgpath.'" type="video/ogg">
                                        nonsupport video
                                    </video>';
                    $value .= '<a class="padL8" href="javascript:void(0);" onclick="preview_video(\''.$fileinfo['attachmentsid'].'\');savePreviewlog('.$recordId.','.$fileinfo['attachmentsid'].',\''.$module.'\',\''.$fileinfo['filename'].'\');"><span>'.getFixedLabel("PREVIEW").'</span></a>';

                } else{
                    $value.='<a class="padL8" href="javascript:void(0);" onclick="open_Attachment('.$recordId.','
                        .$fileinfo['attachmentsid'].',\''.$module.'\',\''.$fileinfo['filename'].'\')"><span>'.getFixedLabel("PREVIEW").'</span></a>';
                }
            }
            $value .= "</span>";
            $value .= "</span>";
            $value .= "<br>";
        }
        return $value;
    }
    public function getImageListViewHtml($showvalue,$module,$lineitemid,$columnname='')
    {
        //$lineitemid:主表字段：record，明细字段:lineitemid,例如合同的明细产品的图片字段
        $value='';
        $value.="<div id='listviewimage_".$lineitemid.$columnname."' name='listviewimage_".$lineitemid.$columnname."'>";
        $value.='<img  data-original="'.$showvalue['value'][0].'"  style="cursor:pointer" alt="'.$showvalue['names'][0]
            .'" onclick="showlistimageview(\''.$lineitemid.$columnname.'\')" src="' . $showvalue['value'][0] .  '" width="50" height="50"  >';
        if(is_array($showvalue['value'])){
            for($imgi=1;$imgi<sizeof($showvalue['value']);$imgi++)
            {
                $value.='<img  data-original="'.$showvalue['value'][$imgi].'" style="display:none" alt="'.$showvalue['names'][$imgi].'" src="' . $showvalue['value'][$imgi] .  '" width="50" height="50" >';
            }
        }
        $value.="</div>";
        return $value;
    }
    //edit: xll 2023/06/26 XUQIU1000357 单据分录增加附件字段（根据showvalue组装html元素）
    public function getLineAttachmentListViewHtml($showvalue, $module, $recordId, $ShowType = 'ListView')
    {
        $value = '';
        foreach ($showvalue['value'] as $fileid => $fileinfo) {
            $httppath = $fileinfo['httppath'];
            $lineitem_id = $fileinfo['lineitem_id'];
            $value .= '<span class="attachments-padL11">';
            $value .= $fileinfo['name'];
            $value .= '<span>';

            if (IsDownLoadProfile($recordId, $module) == 'yes'){
                $value .= ' <a href="index.php?module=uploads&action=downloadfile&return_module=' . $module . '&fileid=' . $fileid . '&entityid=' . $recordId . '&lineitem_id=' . $lineitem_id . '" onclick="update_frequency('. $fileid . ',\'download\');javascript:dldCntIncrease(\'' . $recordId . '\');"><span>' . getFixedLabel("DOWNLOAD") . '</span></a>&nbsp;&nbsp';
                if($ShowType === 'DetailView')
                    $value = self :: getHistoryHtml($recordId,$module,$fileid,$fileinfo,$value,'download');
            }

            if (IsPreviewProfile($recordId, $module) == 'yes' && $fileinfo['storage_location'] != 'awsserver'){
                // @edit:dong @date:2020/07/31 @reason:  判断附件是否是图片
                if(checkFileNameIsImg($fileinfo['newfile_name'])){
                    $value .= '<img  style="display:none" src="'.$httppath.'">';
                    // @edit:dong @date:2020/07/22 @reason:附件字段，点击查看图片附件，增加图片预览插件；
                    $value .= '<a href="javascript:void(0);"  onclick="update_frequency('. $fileid . ',\'preview\');previewImage(ld(this).parents(\'td\')[0]);ld(this).parent().find(\'img\').click();savePreviewlog('.$recordId.','
                        . $fileid .',\''.$module.'\',\''.$fileinfo['name'].'\',' . $lineitem_id . ');"><span>' . getFixedLabel("PREVIEW") . '</span></a>';
                }elseif(checkFileNameIsVideo($fileinfo['newfile_name'])){
                    //@edit:liushuai,2021-04-21,reason: 0045556: OA表单-请假单，单据编号QJ18，数据分类“成员查看”，附件显示在列表处时，点击预览视频没有直接打开，会进入新页签
                    $value .= '<video controls="controls" id="video_'. $fileid .'" style="display: none;">
                                        <source src="'.$httppath.'" type="video/mp4">
                                        <source src="'.$httppath.'" type="video/webm">
                                        <source src="'.$httppath.'" type="video/ogg">
                                        nonsupport video
                                    </video>';
                    $value .= '<a href="javascript:void(0);" onclick="update_frequency('. $fileid . ',\'preview\');preview_video(\''. $fileid .'\');savePreviewlog('
                        .$recordId.','. $fileid .',\''.$module.'\',\''.$fileinfo['name'].'\',' . $lineitem_id . ');"><span>'
                        .getFixedLabel("PREVIEW").'</span></a>';

                } else {
                    $value.='<a href="javascript:void(0);" onclick="update_frequency('. $fileid . ',\'preview\'); open_Attachment('.$recordId.','
                        . $fileid .',\''.$module.'\',\''.$fileinfo['newfile_name'].'\',' . $lineitem_id .')"><span>'
                        .getFixedLabel("PREVIEW")
                        .'</span></a>';
                }
                if($ShowType === 'DetailView')
                    $value = self :: getHistoryHtml($recordId,$module,$fileid,$fileinfo,$value,'preview');
            }
            $value .= "</span>";
            $value .= "</span>";
            $value .= "<br>";
        }
        return $value;
    }
    public function getHistoryHtml($recordId,$module,$fileid,$fileinfo,$value,$type){
        $type_times = ($type == 'download') ? 'download_times' : 'preview_times';
        if(IsFileReadHistoryProfile($recordId,$module)){
            $value .= '<span ';
            if($fileinfo[$type_times] == 0){
                $value .= 'style = "display: none;"';
            }
            $value .= '> ( ';
            $value .= '<a href="javascript:void(0);" name="' . $type . '_' . $fileid . '" onclick="FileReadHistory(' .
                $fileid . ',\'' . $module . '\',\'' . $type . '\',' . $fileinfo['lineitem_id'] .');">';
            $value .= $fileinfo[$type_times];
            $value .= '</a>';
            $value .= getFixedLabel('Frequency') . ')</span>&nbsp;&nbsp;';
        }
        return $value;
    }

    // edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（生成预览按钮的方法）
    public static function getPreviewButton($file){
        $preview_button = '';
        $fileid = $file['id'];
        $httppath = '';
        if ($file['storage_location'] == 'awsserver') {
            return '';
        }else if($file['storage_location'] == 'cos'){
            $httppath = $file['httppath'];
            if(strpos($file['httppath'],'http') !== 0)
                $httppath = 'https://'.$httppath;
        }else{
            $httppath= $file['pre_path'];
        }
        //edit: xll 2023/09/02  BUG0071761 video标签导致小编辑界面一闪而过消失
        $tmp_bool = true;
        if(isset($_REQUEST['pagetype']) && $_REQUEST['pagetype']=='ListEditPagePopup')
            $tmp_bool = false;
        if(strpos($file['type'],'image') !== false){
            $preview_button = '<img  style="display:none" src="'.$httppath.'">';
            $preview_button .= '<a href="javascript:void(0);"' .
                'onclick="previewImage(ld(this).parents(\'.uploader-list\').get(0));ld(this).parent().find(\'img\').click();">' .
                '<span>' . getFixedLabel("PREVIEW") . '</span></a>';
        }
        else if(strpos($file['type'],'video') !== false && $tmp_bool){
            $preview_button = '<video id="video_'. $fileid .'" style="display: none;" controls="controls" playsinline>' .
                '<source src="'.$httppath.'" type="video/mp4">' .
                '<source src="'.$httppath.'" type="video/webm">' .
                '<source src="'.$httppath.'" type="video/ogg">' .
                'nonsupport video' .
                '</video>';
            $preview_button .= '<a href="javascript:void(0);" onclick="preview_video(\''. $fileid .'\');"><span>'
                . getFixedLabel("PREVIEW").'</span></a>';
        }
        //audio标签，音频文件
        else if(strpos($file['type'],'audio') !== false){
            $preview_button = '<audio controls="controls" id="audio_' . $fileid . '" style="display: none;margin: auto 10px;" >' .
                '<source src="'.$httppath.'" type="audio/wav">' .
                '<source src="'.$httppath.'" type="audio/mpeg">' .
                '<source src="'.$httppath.'" type="audio/ogg">' .
                'nonsupport audio' .
                '</audio>';
            $preview_button .= '<a href="javascript:void(0);" onclick="preview_audio(\''. $fileid .'\',this);"><span>'
                . getFixedLabel("PREVIEW").'</span></a>';
        }
        else{
            $preview_button = '<a href="javascript:void(0);" onclick="Pre_Attachment(this)" ' .
                'file_fileid="'.$file['id'].'" file_isEncrypt="'.$file['isEncrypt'].'"' .
                'file_size="'.$file['size'].'" file_filename="'.$file['name'].'" file_path="'.$file['path'].'" ' .
                'file_newfile_name="'.$file['newfile_name'].'" file_cloud_path="'.$file['cloud_path'].'" ' .
                'file_storage_location="'.$file['storage_location'].'" file_type="'.$file['type'].'"><span>'
                . getFixedLabel("PREVIEW")
                . '</span></a>';
        }
        return $preview_button;
    }

    var $curModule;
    public function setCurModule($curModule) {
        $this->curModule = $curModule;
    }

    public function getCurModule() {
        return $this->curModule;
    }
    //duan 20241227 添加一个不带缓存的方法，方便在单据更新后调用
    public function getAllFile_imageInfo_nocache($record,$module):array
    {
        global $adb,$site_URL;
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();

        //edit:can 20210924 048040: （https://www.cubenergy.com.cn/crm/ [^] ）库博能源，“OA表单”—>“其他类付款单”，填写完毕后点击保存无反应
        $file_info=[];
        $focus=CRMEntity::getInstance($module);
        $modulefields=$focus->fieldobj->getModuleFields();
        $attachmentsinfo=array();
        $sql='select ld_attachments.*,ld_seattachmentsrel.attachmentcolumnname  from ld_attachments 
                        inner join ld_seattachmentsrel on ld_seattachmentsrel.attachmentsid=ld_attachments.attachmentsid
                   WHERE   ld_seattachmentsrel.crmid=?
                     ';

        // ljj 2023-08-16 XUQIU1001425 页面设置，字段增加“不允许复制”字段属性（邬丹华、东方报警）
        if($_REQUEST['record']>0 && $_REQUEST['Create']=='true') {
            $disallowed_columnname = [];
            foreach($modulefields as $fieldname=>$fieldinfo){
                if($fieldinfo->getBigType() == "fileattachment" && $fieldinfo->getDisAllowedCopy() == "yes") {
                    $disallowed_columnname[] = $fieldinfo->getColumnName();
                }
            }
            if (!empty($disallowed_columnname)) {
                $sql .= " AND ld_seattachmentsrel.attachmentcolumnname NOT IN ('".implode("', '",$disallowed_columnname)."')";
            }
        }

        $result=$adb->pquery($sql,array($record));
        $rows=$adb->num_rows($result);
        //editor:gyq_169 reason:腾讯云COS文件上传预览    2020/3/2 9:12
        for($i=0;$i<$rows;$i++)
        {
            $id=$adb->query_result($result,$i,'attachmentsid');
            $recordid = $record;
            $attname = html_entity_decode((string)$adb->query_result($result,$i,'name'));

            $size = $adb->query_result($result,$i,'size');
            $path = html_entity_decode((string)$adb->query_result($result,$i,'path'));
            $cloud_path = html_entity_decode((string)$adb->query_result($result,$i,'cloud_path'));
            $file_type = $adb->query_result($result,$i,'type');
            $newfile_name=html_entity_decode((string)$adb->query_result($result,$i,'newfile_name'));
            $attachmentcolumnname=$adb->query_result($result,$i,'attachmentcolumnname');
            $storage_location = $adb->query_result($result,$i,'storage_location');
            $upload_from = $adb->query_result($result,$i,'upload_from');
            $imagefromtype = $adb->query_result($result,$i,'imagefromtype');
            if(checkFileNameIsImg($newfile_name)){
                if($storage_location=='cos'){
                    $filepath_noEncrpt = $cloud_path;
                }else{
                    //$filepath_noEncrpt =  $site_URL.'/'.$path.$newfile_name;
                    $filepath_noEncrpt =  $path.$newfile_name;
                }
            }

            //edit: xll XUQIU1001183 下载优化：newfile_name、path、cloud_path加密
            $path = $cls_MyCRMcrypt -> encode($path);
            $cloud_path = $cls_MyCRMcrypt -> encode($cloud_path);
            $newfile_name = $cls_MyCRMcrypt -> encode($newfile_name);
            $isEncrypt = 'yes';

            //表头编辑
            if(is_numeric($size)){
                if ($size < 1024)
                    $size = $size . ' B';
                elseif ($size > 1024 && $size < 1048576)
                    $size = round($size / 1024, 2) . ' KB';
                else if ($size > 1048576)
                    $size = round($size / (1024 * 1024), 2) . ' MB';
            }

            // edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（生成预览按钮并返回）
            $httppath = $cls_MyCRMcrypt -> decode($cloud_path) ;
            $pre_path = $cls_MyCRMcrypt -> decode($path) . $cls_MyCRMcrypt -> decode($newfile_name);
            $file = array('id'=>$id,'storage_location'=>$storage_location,'httppath'=>$httppath,
                'pre_path'=>$pre_path,'name'=>$attname,'type'=>$file_type,'isEncrypt'=>$isEncrypt,
                'path'=>$path,'cloud_path'=>$cloud_path,'newfile_name'=>$newfile_name);
            $pre_button = self::getPreviewButton($file);

            $file_info[$attachmentcolumnname][] = array('file_name'=>$attname,'file_size'=>$size
            ,'file_type'=>$file_type,'file_path'=>$path,'newfile_name'=>$newfile_name
            ,'cloud_path'=>($cloud_path)
            ,'fileid'=>$id,'storage_location'=>$storage_location,'upload_from'=>$upload_from ,'imagefromtype'=>$imagefromtype, 'isEncrypt'=>$isEncrypt
            ,'pre_button'=>$pre_button,'filepath_noEncrpt'=>$filepath_noEncrpt,'recordid'=>$recordid,'module'=>$module);
        }
        // 附件管理模块的附件
        if($module == 'Attachment'){
            $file_info_json = $this->getAttachmentForBills($record,$module);
            $file_info['filename'] = Zend_Json::decode($file_info_json);
        }

        //向jsondata添加不保存数据库的引用图片附件字段
        $fieldinfo_arr=$focus->fieldobj->getFieldInfoobjBykey_arr("bigtype",'fileattachment');

        $curModule = $this->getCurModule();
        if(empty($curModule)) {
            $previewProfile = IsPreviewProfile($recordid,$module);
        }
        else {
            $previewProfile = IsPreviewProfile($recordid,$curModule);
        }


        foreach ($fieldinfo_arr as $fieldinfo){
            $fieldname=$fieldinfo->getFieldName();
            if($fieldinfo->getSaveDataBase()=='no'){
                $fieldvalue=$focus->column_fields[$fieldname];
                $file_info[$fieldname]=$fieldvalue;
            }
            //edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
            $fieldinfo->setFileAllowed($module,$recordid);
            $fileAllowed = $fieldinfo->getFileAllowed($recordid);
            if ($fileAllowed['Preview'] === 'no' || $previewProfile !== 'yes') {
                foreach ($file_info[$fieldname] as &$file) {
                    $file['fileAllowed'] = $fileAllowed;
                    $file['pre_button'] = '';
                }
            }
        }

        array_unique($file_info);
        $static_getAllFile_imageInfo[$record]=$file_info;
        return $file_info;
    }


    //20241227 duan:调整保存数据库的附件字段名和显示的附件字段名
    //$fileinfo:附件字段信息数组 ,$changetype:附件信息用于显示或用于保存 show,save
    public function getTransColumnValue($fileinfo,$changetype):array
    {
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();
        $change_column_arr = [
            'attachmentsid'=>'fileid',
            'name'=>'file_name',
            'newfile_name'=>'newfile_name',
            'type'=>'file_type',
            'path'=>'file_path',
            'size'=>'file_size',
            'imagefromtype'=>'imagefromtype',
            'storage_location'=>'storage_location',
            'upload_from'=>'upload_from',
            'cloud_path'=>'cloud_path',
            'isEncrypt'=>'isEncrypt',
        ];
        $crypt_arr = ['file_path','newfile_name','cloud_path'];
        $return_arr = [];
        foreach ($change_column_arr as $save_column => $show_column){
            if($changetype == 'show'){
                $old_column = $save_column;
                $new_column = $show_column;
            }else{
                $old_column = $show_column;
                $new_column = $save_column;
            }
            if(isset($fileinfo[$old_column])){
                if($fileinfo['isEncrypt'] == 'yes' && in_array($old_column,$crypt_arr)){
                    $return_arr[$new_column] = $cls_MyCRMcrypt -> decode($fileinfo[$old_column]);
                }else{
                    $return_arr[$new_column] = $fileinfo[$old_column];
                }
            }
        }
        unset($cls_MyCRMcrypt);
        return $return_arr;
    }

    //edit:duan date:2024/12/27 reason：保存附件的历史数据
    public function saveAttachmentImgLogs($attachmentlogsinfo_arr):void
    {
        global $adb;
        $insertlogs_attachmentsid_arr = [];
        foreach ($attachmentlogsinfo_arr as $tmp_fieldname => $tmp_fileinfo){
            $tmp_fileid_arr = array_keys($tmp_fileinfo);
            $insertlogs_attachmentsid_arr = array_merge($insertlogs_attachmentsid_arr,$tmp_fileid_arr);
        }
        $insertlogs_attachmentsid_arr = array_unique($insertlogs_attachmentsid_arr);

        if(count($insertlogs_attachmentsid_arr)>0){
            $insert_tablename = 'ld_attachments_history';
            $all_insertlogs_attachmentsid_str = implode(',',$insertlogs_attachmentsid_arr);
            $select_sql = "SELECT GROUP_CONCAT(attachmentsid) FROM $insert_tablename WHERE attachmentsid in ( $all_insertlogs_attachmentsid_str );";
            $select_result = $adb->pquery($select_sql,array());
            $num_rows = $adb->num_rows($select_result);
            $saved_attachmentsid_str = $adb->query_result($select_result,0,0);
            // 去掉已经保存过的
            if(!empty($saved_attachmentsid_str)){
                $saved_attachmentsid_arr = explode(',',$saved_attachmentsid_str);
                $insertlogs_attachmentsid_arr = array_diff($insertlogs_attachmentsid_arr,$saved_attachmentsid_arr);
            }
            foreach ($attachmentlogsinfo_arr as $tmp_fieldname => $tmp_fileinfo) {
                foreach ($tmp_fileinfo as $attid => $info) {
                    if(in_array($attid,$insertlogs_attachmentsid_arr)){
                        $insert_sql = "INSERT INTO $insert_tablename (`attachmentsid`,`crmid`, `name`, `newfile_name`, `type`, `path`, `size`, `imagefromtype`, 
									`storage_location`, `upload_from`, `cloud_path`, `description`, `watermark`) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";
                        $adb->pquery($insert_sql,array($info['attachmentsid'],$info['crmid'],$info['name'],$info['newfile_name'],$info['type'],$info['path'],$info['size'],$info['imagefromtype'],
                            $info['storage_location'],$info['upload_from'],$info['cloud_path'],$info['description'],$info['watermark']));
                    }
                }
            }
        }
    }

    //edit:duan date:2024/12/27 reason：获取附件的历史数据
    public function getAttachmentImgHistory($record,$logtype='field'):array
    {
        global $adb;
        if($logtype == 'detail'){
            $select_tablename = 'ld_detailattachments_history';
        }else{
            $select_tablename = 'ld_attachments_history';
        }
        $attachment_img_logs_arr = [];
        // 一次性都查找出来
        $att_select_sql = "SELECT `attachmentsid`, `name`, `newfile_name`, `path`, `storage_location`, `cloud_path`,`size`,`imagefromtype`,`upload_from` FROM $select_tablename 
                            WHERE crmid = ?;";
        $att_select_result = $adb->pquery($att_select_sql,array($record));
        $att_num_rows = $adb->num_rows($att_select_result);

        if($att_num_rows > 0) {
            for($i = 0; $i<$att_num_rows; $i++){
                $attachments_id = $adb->query_result($att_select_result, $i, 'attachmentsid');
                $attachment_img_logs_arr[$attachments_id] = [
                    'attachmentsid' => $attachments_id,
                    'name' => $adb->query_result($att_select_result, $i, 'name'),
                    'newfile_name' => $adb->query_result($att_select_result, $i, 'newfile_name'),
                    'path' => $adb->query_result($att_select_result, $i, 'path'),
                    'storage_location' => $adb->query_result($att_select_result, $i, 'storage_location'),
                    'cloud_path' => $adb->query_result($att_select_result, $i, 'cloud_path'),
                    'size' => $adb->query_result($att_select_result, $i, 'size'),
                    'imagefromtype' => $adb->query_result($att_select_result, $i, 'imagefromtype'),
                    'upload_from' => $adb->query_result($att_select_result, $i, 'upload_from'),
                ];
            }
        }
        return $attachment_img_logs_arr;
    }

    //edit:duan date:2024/12/27 reason：删除无用的历史附件记录
    public function deleteUnuseFileHistory($record,$old_fileid,$tmp_fieldname):void
    {
        global $adb;
        if(!empty($old_fileid)){
            //读取在修改日志中使用的附件id
            $select_log_sql = "SELECT GROUP_CONCAT(CONCAT(prevalue,',',postvalue)) as old_logfileid from ld_modtracker_basic 
                                            INNER JOIN ld_modtracker_detail on ld_modtracker_basic.id = ld_modtracker_detail.id
                                            where ld_modtracker_basic.crmid = ? and ld_modtracker_detail.fieldname = ?";
            $select_log_result = $adb->pquery($select_log_sql,[$record,$tmp_fieldname]);
            $old_logfileid_str = -1;
            if($adb->num_rows($select_log_result)>0){
                $old_logfileid = $adb->query_result($select_log_result,0,'old_logfileid');
                $old_logfileid_arr = explode(',',$old_logfileid);
                if(sizeof($old_logfileid_arr)>0){
                    $old_logfileid_arr = array_filter($old_logfileid_arr); //去除空选项
                    $old_logfileid_arr = array_unique($old_logfileid_arr); //去除重复值
                    if(sizeof($old_logfileid_arr)>0){
                        $old_logfileid_str = implode(',',$old_logfileid_arr);
                    }
                }
            }
            //删除已不在推进日志中使用，且不在修改日志中使用的id
            $delete_sql = "DELETE from ld_attachments_history where attachmentsid in ($old_fileid) and attachmentsid not in ($old_logfileid_str)";
            $adb->pquery($delete_sql,array());
        }
    }

}