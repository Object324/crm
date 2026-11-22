<?php
// ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）
class FileWaterMark{
    public $waterMarkValueBYnewfile_name = array();
    public $waterMarkSettingInfo = array();
    public $waterMarkSetting = array();
    public $waterMarkTextByRecordid = array();
    public $waterMarkTextImageByRecordid = array();
    public $issetGD;
    public $module;
    public function __construct($module)
    {
        $this->module = $module;
        $this->issetGD = extension_loaded('gd')?'yes':'no';

    }
    public static function getInstance($module){
        static $static_filewatermarkobj_arr;
        if(is_array($static_filewatermarkobj_arr)&&array_key_exists($module,$static_filewatermarkobj_arr))
        {
            return $static_filewatermarkobj_arr[$module];
        }
        if(!is_array($static_filewatermarkobj_arr))
        {
            $static_filewatermarkobj_arr=[];
        }

        $static_filewatermarkobj_arr[$module]= new FileWaterMark($module);

        return $static_filewatermarkobj_arr[$module];

    }

    //添加水印
    public function addWaterMark($info){
        global $adb,$current_user;
        //判断是否加载gd库
        if ($this->issetGD == 'no'){
            return false;
        }
        $storage_location = $info['storage_location'];
        $watermark = $info['watermark'];
        $newfile_name = $info['newfile_name'];
        $excel_watermark = $info['excel_watermark'];
        $word_watermark = $info['word_watermark'];
        $module = $info['module'];
        $fieldname = $info['fieldname'];
        $recordid = $info['recordid'];
        $path = $info['path'];
        $uitype = $info['uitype'];
        $attachmentsid = $info['attachmentsid'];
        if ($uitype != 1109 && $uitype != 28 && $uitype != 1108){
            return false;
        }
        if ($storage_location != 'local' || $watermark == 'yes') {//cos暂时不支持
            return false;
        }
        $tmparr = explode('.', $newfile_name);
        $fileSuffix = end($tmparr);//文件后缀
        if ($fileSuffix != 'xlsx'  && $fileSuffix != 'doc' && $fileSuffix != 'docx') {//非excel和word文档不支持
            return false;
        }
        //判断对应文件的设置是否开启
        if ($fileSuffix == 'xlsx' && $excel_watermark == 'yes') {//xlsx文档且开启设置
            $fileType = 'excel';
        } elseif ($fileSuffix == 'docx' && $word_watermark == 'yes') {//word文档且开启设置
            $fileType = 'word';
        } else {
            return false;
        }
//    dump($fileType);
        //水印设置内容
        $info = $this->getWaterMarkSettingInfo($module,$fieldname,$fileType);
//        dump([$module,$fieldname,$fileType]);
        if (empty($info)){
            return false;
        }
        $image_path = $info['image_path'];
        $image_newfilename = $info['image_newfilename'];
        $text_watermark = $info['text_watermark'];
        $image_watermark = $info['image_watermark'];
        $content = $info['content'];
        $image_name = $info['image_name'];

//    dump([$image_watermark,$image_name,$image_path,$image_newfilename]);
        //根据设置内容判断水印
        $filepath = globalStatic::$root_directory. $path . $newfile_name;

//        $imagepath = globalStatic::$root_directory.$image_path . $image_newfilename;
        $iswatermark = 'no';
        if ($fileType == 'excel' && ($text_watermark == 'yes' || $image_watermark == 'yes')){
            require_once(globalStatic::$root_directory.'Watermark.php');
            $water = new \watermark\Watermark($filepath);
            if ($text_watermark == 'yes'){
                $text = $this->getWaterMarkText($module,$fieldname,$fileType,$recordid,$content);
                if (!empty($text)){
                    $textImagePath = $this->getWaterMarkTextImageFile($module,$fieldname,$fileType,$recordid,$text);
                    $num = $water->addImage($textImagePath);
                    $water->getSheet(1)->setBgImg($num);
                    $iswatermark = 'yes';
                    $water->close();
                }
            }elseif ($image_watermark == 'yes'){
                $newimagepath = $this->getGDImage($module,$fieldname,$fileType,$image_path,$image_newfilename,1);
                if (file_exists($newimagepath)){
                    $num = $water->addImage($newimagepath);
                    $water->getSheet(1)->setBgImg($num);
                    $iswatermark = 'yes';
                }
                $water->close();
            }
        }else if ($fileType == 'word' && ($text_watermark == 'yes' || $image_watermark == 'yes')){
            require_once(globalStatic::$root_directory."include/office/WordWaterMark.php");
            $GDpath=$this->getWaterMarkGDPath($module,$fieldname,$fileType);
            //图片全位置
            if ($image_watermark == 'yes'){
                $imagepath=$this->getGDImage($module,$fieldname,$fileType,$image_path,$image_newfilename);
            }else{
                $text = $this->getWaterMarkText($module,$fieldname,$fileType,$recordid,$content);
                $imagepath = $this->getWaterMarkTextImageFile($module,$fieldname,$fileType,$recordid,$text);
            }
            $path_arr=explode('/',$imagepath);
            $imagename=end($path_arr);

            $imageSize = getimagesize($imagepath);

            $wordwatemarkobj=new WordWaterMark(globalStatic::$root_directory.$path,$newfile_name);
            $wordwatemarkobj->addWaterImage($GDpath,$imagename);
            //设置图片大小
            $wordwatemarkobj->setImageSize($imageSize[0],$imageSize[1]);
            //添加水印
            $newDocfilename=$wordwatemarkobj->startWater();
            if (file_exists($filepath)){
                rename($filepath,globalStatic::$root_directory. $path . 'temp_'.$newfile_name);
            }
            if (file_exists($newDocfilename)){
                rename($newDocfilename,$filepath);
                @unlink($newDocfilename);
            }
            $iswatermark = 'yes';
        }
        if ($iswatermark == 'yes'){
            if ($uitype == 1109 || $uitype == 28){
                $updatesql = 'update ld_attachments set watermark = ? where attachmentsid = ? ';
                $adb->pquery($updatesql, array('yes', $attachmentsid));
            }elseif ($uitype == 1108){
                $updatesql = 'update ld_attachmentsforbillsdetails set watermark = ? where newfile_name = ? ';
//                dump([$updatesql,$newfile_name]);
                $adb->pquery($updatesql, array('yes', $newfile_name));
            }
            $this->waterMarkValueBYnewfile_name[$newfile_name] = 'yes';
        }
    }

    //获取文字水印GD图片
    public function getWaterMarkTextImageFile($module,$fieldname,$fileType,$recordid,$text){
        if (!empty($this->waterMarkTextImageByRecordid[$module.'_'.$fieldname.'_'.$fileType.'_'.$recordid])){
            return $this->waterMarkTextImageByRecordid[$module.'_'.$fieldname.'_'.$fileType.'_'.$recordid];
        }else{
            return $this->setWaterMarkTextImageFile($module,$fieldname,$fileType,$recordid,$text);
        }

    }
    //文字水印 GD库合成图片
    public function setWaterMarkTextImageFile($module,$fieldname,$fileType,$recordid,$text){
        global $current_user;
        $font = globalStatic::$root_directory.'simsun.ttc';
        $bbox = imagettfbbox(30, 0, $font, $text);
        $textX = abs($bbox[2] - $bbox[0]);
        $textY = abs($bbox[5] - $bbox[3]);
        $max = $textX>$textY?$textX:$textY;
        $textImage = imagecreatetruecolor(1.2*$max,1.2*$max);
//    $black = imagecolorallocate($textImage,0, 0, 0);
        $white = imagecolorallocatealpha($textImage, 255, 255, 255, 127);
        $black = imagecolorallocatealpha($textImage, 0, 0, 0, 90);
        imagefill($textImage, 0, 0, $white);
        imagealphablending($textImage, false);
        imagesavealpha($textImage, true);
        imagettftext($textImage, 30, 45,($max-$textX)+40, ($max-$textY*0.75), $black, $font, $text);

        $file_path = $this->getWaterMarkGDPath($module,$fieldname,$fileType);
        $file_name = $module.'_'.$fieldname.'_'.$recordid.'_'.$fileType.'_'.$current_user->id.'_text.png';
        // 保存图片文件
        imagepng($textImage, $file_path.$file_name);
        imagedestroy($textImage);
        $this->waterMarkTextImageByRecordid[$module.'_'.$fieldname.'_'.$fileType.'_'.$recordid] = $file_path.$file_name;
        return $file_path.$file_name;
    }
    //内容模版获取转换为内容
    public function getWaterMarkText($module,$fieldname,$fileType,$recordid,$content){
        if (!empty($this->waterMarkTextByRecordid[$module.'_'.$fieldname.'_'.$fileType.'_'.$recordid])){
            return $this->waterMarkTextByRecordid[$module.'_'.$fieldname.'_'.$fileType.'_'.$recordid];
        }else{
            $waterMarkAllText=$this->setWaterMarkAllText($module,$recordid);
            return $waterMarkAllText[$module.'_'.$fieldname.'_'.$fileType.'_'.$recordid];
        }
    }
    //获取单个字段文字水印内容模版的内容
    public function setWaterMarkText($module,$fieldname,$fileType,$recordid,$content){
        global $adb;
        require_once(globalStatic::$root_directory."include/VarGeneralBol/GeneralBolSql.php");
        $generalBolSqlObj = new GeneralBolSql($module,$recordid);
        $generalBolSqlObj->createPrintSQL($content);
        $varselect = $generalBolSqlObj->getVarSelectQuery();
        $leftjoin = $generalBolSqlObj->getFromQuery();
//        dump([$content,$varselect,$leftjoin]);
        $focus = CRMEntity::getInstance($module);
        $table_name = $focus->table_name;
        $table_index = $focus->table_index;
        $sql = 'select '.$table_name.'.'.$table_index.$varselect.' from '.$table_name.' '.$leftjoin.' where '.$table_name.'.'.$table_index.' = ?';
        $varselect_result = $adb->pquery($sql,array($recordid));
        $content_arr = $adb->query_result_all($varselect_result);
        $content_arr = $content_arr[0];
        $content_arr['{currentdate}'] = date("Y-m-d H:i:s");
        $tmpcontent = strtr(strtolower($content),$content_arr);
        $text = iconv(mb_detect_encoding($tmpcontent), "utf-8", $tmpcontent);
        $this->waterMarkTextByRecordid[$module.'_'.$fieldname.'_'.$fileType.'_'.$recordid] = $text;
        return $text;
    }
    //获取模块所有附件字段内容模版
    public function setWaterMarkAllText($module,$recordid){
        global $adb;
        $sql = 'select content,fieldname,type from ld_attachments_watermark_setting where module=? and text_watermark=? and fieldname is not null and type in ("word","excel")';
        $result = $adb->pquery($sql,array($module,'yes'));
        $num_row = $adb->num_rows($result);
        if ($num_row>0){
            require_once(globalStatic::$root_directory."include/VarGeneralBol/GeneralBolSql.php");
            $generalBolSqlObj = new GeneralBolSql($module,$recordid);
            $focus = CRMEntity::getInstance($module);
            $table_name = $focus->table_name;
            $table_index = $focus->table_index;
            $tmpcontentarr = [];
            $contentstr = '';
            for ($i=0;$i<$num_row;$i++){
                $content = $adb->query_result($result,$i,'content');
                $fieldname = $adb->query_result($result,$i,'fieldname');
                $fileType = $adb->query_result($result,$i,'type');
                $contentstr .= $content;
                $tmpcontentarr[$module.'_'.$fieldname.'_'.$fileType.'_'.$recordid] = $content;
            }
            $generalBolSqlObj->createPrintSQL($contentstr);
            $varselect = $generalBolSqlObj->getVarSelectQuery();
            $leftjoin = $generalBolSqlObj->getFromQuery();
//                dump([$content,$varselect,$leftjoin]);
            $sql = 'select '.$table_name.'.'.$table_index.$varselect.' from '.$table_name.' '.$leftjoin.' where '.$table_name.'.'.$table_index.' = ?';

            $varselect_result = $adb->pquery($sql,array($recordid));
            $content_arr = $adb->query_result_all($varselect_result);
            $content_arr = $content_arr[0];
            $content_arr['{currentdate}'] = date("Y-m-d H:i:s");
            foreach ($tmpcontentarr as $tmpkey=>$tmpcontent){
                $tmpcontent = strtr(strtolower($tmpcontent),$content_arr);
                $text = iconv(mb_detect_encoding($tmpcontent), "utf-8", $tmpcontent);
                $this->waterMarkTextByRecordid[$tmpkey] = $text;
            }

        }
        return $this->waterMarkTextByRecordid;


    }


    //获取设置时加载的水印图片
    public function getGDImage($module,$fieldname,$fileType,$image_path,$image_newfilename){
        $GDPath = globalStatic::$root_directory.'storage/FileWaterMarkImage/';
        $imageName = $module.'_'.$fieldname.'_'.$fileType.'_image.png';
        if (is_dir($GDPath) && file_exists($GDPath.$imageName)){
            return $GDPath.$imageName;
        }else{
            return $this->setImageTransparencyandSize($module,$fieldname,$fileType,$image_path,$image_newfilename);
        }

    }

    /*设置图片透明度和大小*/
    public function setImageTransparencyandSize($module,$fieldname,$fileType,$image_path,$image_newfilename){
        $imagePath = globalStatic::$root_directory.$image_path.$image_newfilename;
        $imageInfo = getimagesize($imagePath);
        $width = $imageInfo[0];
        $height = $imageInfo[1];
        $fileSuffix = $imageInfo['mime'];
        $fileSuffix_arr = explode('/', $fileSuffix);
        $fileSuffix_type = end($fileSuffix_arr);//文件后缀
//    dump([$imagePath,$imageInfo]);
        $function_str = 'imagecreatefrom'.$fileSuffix_type;
        $function_save_str = 'image'.$fileSuffix_type;
        if (!function_exists($function_str)){
            return $imagePath;
        }
        //处理原图 提高亮度和白色变透明
        $image = $function_str($imagePath);
        $white = imagecolorallocate($image, 255, 255, 255);
        imagecolortransparent($image, $white);
        imagefilter($image, IMG_FILTER_BRIGHTNESS, 50);

        $newImage = imagecreatetruecolor($width,$height);

        imagealphablending($newImage, false);
        imagesavealpha($newImage, true);
        $white = imagecolorallocatealpha($newImage, 255, 255, 255, 127);
        imagefill($newImage, 0, 0, $white);
        imagecopymerge($newImage,$image,0,0,0,0,$width,$height,50);
//        $function_save_str($image, $filename);
        //判断FileWaterMarkImage
        $filepath = $this->getWaterMarkGDPath($module,$fieldname,$fileType);
        $filename = $module.'_'.$fieldname.'_'.$fileType.'_image.png';//命名1.46
        imagepng($newImage, $filepath.$filename);
    //    dump($filename);cls
        imagedestroy($image);
        imagedestroy($newImage);

        return $filepath.$filename;

    }
    //1109
    public function setWaterMarkByAttachmentsidArr($attachmentsidArr){
        global $adb;
        if (empty($attachmentsidArr) && !is_array($attachmentsidArr)){
            return false;
        }
        $attachmentsid = implode(',', $attachmentsidArr);
        $sql = 'select newfile_name,watermark from ld_attachments where attachmentsid in ( ' . $attachmentsid . ' )';
        $result=$adb->pquery($sql,array());
        $num_row = $adb->num_rows($result);
        if($num_row > 0){
            for ($i=0;$i<$num_row;$i++){
                $newfile_name = $adb->query_result($result,$i,'newfile_name');
                $watermark = $adb->query_result($result,$i,'watermark');
                $watermark = $watermark == 'yes'?'yes':'no';
                $this->waterMarkValueBYnewfile_name[$newfile_name] = $watermark;
            }
        }

    }
    //1108
    public function setWaterMarkByAttachmentsidInBillsArr($attachmentsid){
        global $adb;
        $sql = 'select newfile_name,watermark from ld_attachmentsforbillsdetails where attachmentsid = ?';
        $result=$adb->pquery($sql,array($attachmentsid));
        $num_row = $adb->num_rows($result);
        if($num_row > 0){
            for ($i=0;$i<$num_row;$i++){
                $newfile_name = $adb->query_result($result,$i,'newfile_name');
                $watermark = $adb->query_result($result,$i,'watermark');
                $watermark = $watermark == 'yes'?'yes':'no';
                $this->waterMarkValueBYnewfile_name[$newfile_name] = $watermark;
            }
        }


    }
    //通过newfile_name获取watermark值
    public function getWaterMarkByNewFileName($newfile_name){
        global $adb;
        if (!empty($this->waterMarkValueBYnewfile_name[$newfile_name])){
            return $this->waterMarkValueBYnewfile_name[$newfile_name];
        }else{
            return 'no';
        }
    }
    //通过newfile_name获取watermark值
    public function setWaterMarkByNewFileName($newfile_name,$watermark){
        $this->waterMarkValueBYnewfile_name[$newfile_name] = $watermark;
    }

    //添加水印 获取水印设置信息
    public function getWaterMarkSettingInfo($module,$fieldname,$fileType){
        global $adb;
        if (!empty($this->waterMarkSettingInfo[$module.'_'.$fieldname.'_'.$fileType])){
            return $this->waterMarkSettingInfo[$module.'_'.$fieldname.'_'.$fileType];
        }
        $settingsql = 'select image_watermark,text_watermark,content,image_name,image_path,image_newfilename from ld_attachments_watermark_setting where module = ? and fieldname = ? and type = ? order by createdtime desc';
        $settingresult = $adb->pquery($settingsql, array($module, $fieldname, $fileType));
        if ($adb->num_rows($settingresult) > 0) {
            $info['image_watermark'] = $adb->query_result($settingresult, 0, 'image_watermark');
            $info['image_name'] = $adb->query_result($settingresult, 0, 'image_name');
            $info['image_path'] = $adb->query_result($settingresult, 0, 'image_path');
            $info['image_newfilename'] = $adb->query_result($settingresult, 0, 'image_newfilename');
            $info['text_watermark'] = $adb->query_result($settingresult, 0, 'text_watermark');
            $info['content'] = $adb->query_result($settingresult, 0, 'content');
            $this->waterMarkSettingInfo[$module.'_'.$fieldname.'_'.$fileType] = $info;
            return $this->waterMarkSettingInfo[$module.'_'.$fieldname.'_'.$fileType];
        }
    }
    //后台设置水印 获取水印设置信息
    public function getWaterMarkSetting($module,$fieldname,$fileType){
        global $adb;
        if (!empty($this->waterMarkSetting[$module.'_'.$fieldname.'_'.$fileType])){
            return $this->waterMarkSetting[$module.'_'.$fieldname.'_'.$fileType];
        }
        $selectsql = 'select id,image_watermark,text_watermark,content,image_name,image_path,image_newfilename from ld_attachments_watermark_setting where module=? and fieldname=? and type=?';
        $selectresult = $adb->pquery($selectsql,array($module,$fieldname,$fileType));
        if ($adb->num_rows($selectresult)>0){
            $info['image_watermark'] = $adb->query_result($selectresult,0,'image_watermark');
            $info['text_watermark'] = $adb->query_result($selectresult,0,'text_watermark');
            $info['content']= $adb->query_result($selectresult,0,'content');
            $newfile_name = $adb->query_result($selectresult,0,'image_newfilename');
            if (!empty($newfile_name)){
                $tmpjsonData['file_name'] = $adb->query_result($selectresult,0,'image_name');
                $tmpjsonData['file_path'] = $adb->query_result($selectresult,0,'image_path');
                $tmpjsonData['newfile_name'] = $newfile_name;
                $tmpjsonData['settingid'] = $adb->query_result($selectresult,0,'id');
                $info['jsonData'][]=$tmpjsonData;
            }
            $this->waterMarkSetting[$module.'_'.$fieldname.'_'.$fileType] = $info;
            return $this->waterMarkSetting[$module.'_'.$fieldname.'_'.$fileType];
        }
    }
    //后台设置水印 获取水印设置信息
    public function getWaterMarkSettingById($settingid){
        global $adb;
        if (!empty($this->waterMarkSettingbyId[$settingid])){
            return $this->waterMarkSetting[$settingid];
        }
        $info = [];
        $selectsql = 'select id,image_watermark,text_watermark,content,image_name,image_path,image_newfilename from ld_attachments_watermark_setting where id=?';
        $selectresult = $adb->pquery($selectsql,array($settingid));
        if ($adb->num_rows($selectresult)>0){
            $info['image_watermark'] = $adb->query_result($selectresult,0,'image_watermark');
            $info['text_watermark'] = $adb->query_result($selectresult,0,'text_watermark');
            $info['content']= $adb->query_result($selectresult,0,'content');
            $newfile_name = $adb->query_result($selectresult,0,'image_newfilename');
            if (!empty($newfile_name)){
                $tmpjsonData['file_name'] = $adb->query_result($selectresult,0,'image_name');
                $tmpjsonData['file_path'] = $adb->query_result($selectresult,0,'image_path');
                $tmpjsonData['newfile_name'] = $newfile_name;
                $tmpjsonData['settingid'] = $adb->query_result($selectresult,0,'id');
                $info['jsonData'][]=$tmpjsonData;
            }
            $this->waterMarkSetting[$settingid] = $info;
        }
        return $info;
    }
    //后台设置 水印设置保存
    public function saveWaterMarkSetting($settingid,$module,$fieldname,$fileType,$image_checked,$text_checked,$content,$image_name,$image_path,$image_newfilename){
        global $adb;
        if ($image_checked == 'yes'){
            $this->deleteImageGDPath($module,$fieldname,$fileType,$image_path,$image_newfilename);
        }
//        settingid-update 多人新增编辑 可都走settingid
        if (empty($settingid)){
            $insertsql = 'insert into ld_attachments_watermark_setting(module,fieldname,type,image_watermark,text_watermark,content,image_name,image_path,image_newfilename) values (?,?,?,?,?,?,?,?,?)';
            $adb->pquery($insertsql,array($module,$fieldname,$fileType,$image_checked,$text_checked,$content,$image_name,$image_path,$image_newfilename));
            $settingid = $adb->getLastInsertID();
        }else{
            $updatesql = 'update ld_attachments_watermark_setting set image_watermark=?,text_watermark=?,content=?,image_name=?,image_path=?,image_newfilename=? where id=?';
            $adb->pquery($updatesql,array($image_checked,$text_checked,$content,$image_name,$image_path,$image_newfilename,$settingid));
        }
        //提前加载GD图片
        if ($image_checked == 'yes' && !empty($image_path) && !empty($image_newfilename) && file_exists(globalStatic::$root_directory.$image_path.$image_newfilename) && $this->issetGD == 'yes'){
//            $ratio = $fileType == 'excel'?'':1.46;//1.46 word文档默认单页长宽比
            $this->setImageTransparencyandSize($module,$fieldname,$fileType,$image_path,$image_newfilename);
        }
        return $settingid;

    }

    //删除文字水印临时图片
    public function deleteTextImagePath(){
        if (sizeof($this->waterMarkTextImageByRecordid)>0){
            foreach ($this->waterMarkTextImageByRecordid as $index => $path){
                if (file_exists($path)){
                    @unlink($path);
                }
            }
        }

    }

    //获取水印图片的目录名
    public function getWaterMarkGDPath($module,$fieldname,$fileType){
        $file = globalStatic::$root_directory.'storage/FileWaterMarkImage/';
        if (!is_dir($file)){
            @mkdir($file,0777);
        }
//        if($waterType == 'image' && $fileType == 'word'){//word文档的图片水印目录
//            $file = $file.$module.'_'.$fieldname.'_'.$fileType.'_image/';
//            if (!is_dir($file)){
//                @mkdir($file,0777);
//            }
//        }
        return $file;
    }

    //删除旧数据的水印图片
    public function deleteImageGDPath($module,$fieldname,$fileType,$image_path,$image_newfilename){
        global $adb;
        $selectsql = 'select image_path,image_newfilename from ld_attachments_watermark_setting where module=? and fieldname=? and type=?';
        $selectresult = $adb->pquery($selectsql,array($module,$fieldname,$fileType));
        $num_rows = $adb->num_rows($selectresult);
        if ($num_rows>0){
            $path = $adb->query_result($selectresult,0,'image_path');
            $newfile_name = $adb->query_result($selectresult,0,'image_newfilename');
            if ($path.$newfile_name != $image_path.$image_newfilename && file_exists(globalStatic::$root_directory.$path.$newfile_name)){
                @unlink(globalStatic::$root_directory.$path.$newfile_name);
                if (is_dir(globalStatic::$root_directory.'storage/FileWaterMarkImage/')){
                    $GDImagepath = globalStatic::$root_directory.'storage/FileWaterMarkImage/'.$module.'_'.$fieldname.'_'.$fileType.'_image/';
                    if (is_dir($GDImagepath)){
                        $files = scandir($GDImagepath);
                        foreach ($files as $index => $filename){
                            if ($filename != '.' || $filename != '..'){
                                @unlink($GDImagepath.$filename);
                            }
                        }
                    }
                }
            }
        }
    }


}








?>