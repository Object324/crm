<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $adb,$currentModule,$current_user;
$_REQUEST['diony'] = 'yes';
$mode = $_REQUEST['mode'];

crm_load_class_file('cls_ImportImage', 'modules/lingdang');
$cls_ImportImageobj = new cls_ImportImage($currentModule);

if ($mode == 'showPopup'){//显示弹窗
    $name_format_fieldname_arr = [];//命名格式的字段
    $name_format_explode_arr = [];//命名格式的分隔符
    //获取有权限上传的图片字段
    $focus = CRMEntity::getInstance($currentModule);
    $fieldinfos = $focus->fieldobj->getModuleFields();
    if (!is_admin($current_user)) {
        $profilefields = $focus->getProfileFields($current_user->profileid);
    }
    $imageField_arr = [];//图片字段数组
    if (is_array($fieldinfos) && sizeof($fieldinfos) > 0 && !empty($fieldinfos)) {
        foreach ($fieldinfos as $fieldname => $fieldinfo){
            if ($fieldinfo){
                $uitype = $fieldinfo->getUIType();
                $savedatabase = $fieldinfo->getSaveDataBase();
                $fieldlabel = $fieldinfo->getFieldLabel();
                if($uitype == 69){//图片
                    $aaaa[$fieldname] = $fieldlabel;
                    if ($savedatabase == 'no') {//不保存数据库
                        continue;
                    }
                    $fieldid = $fieldinfo->getFieldid();
                    if (!empty($profilefields) && ($fieldinfo->getReadOnly() == 1 || $profilefields[$fieldid]['editreadonly'] == 1 ) ) {//字段权限只读
                        continue;
                    }
                    $imageField_arr[$fieldname] = $fieldlabel;
                }
                //命名格式字段
                if ($fieldname == 'productname' || $fieldname == 'product_no'){
                    $name_format_fieldname_arr[$fieldname] = $fieldlabel;
                }
            }
        }
    }
    //没有图片字段返回提示
    if (empty($imageField_arr)){
        ConvertTojsonString(-1,'',getFixedLabel('ImportProductImageNoImageField'));
    }else if (empty($name_format_fieldname_arr)){
//        ConvertTojsonString(-1,'','');
    }

    $smarty = new lingdangCRM_Smarty();
    $smarty->assign('imagefield',$imageField_arr);

    $name_format_explode_arr = array(
        'underline'=>'_{Var}',
        'bracket'=>'({Var})'
    );
    $smarty->assign('NameFormatFieldName',$name_format_fieldname_arr);
    $smarty->assign('NameFormatExplode',$name_format_explode_arr);

    //获取上一次导入的字段和命名格式
    $latest_import_image_fieldname = getUsersettingByLabel($currentModule,$current_user->id,$currentModule.'ImportImageFieldName');
    $latest_import_image_fieldname = $latest_import_image_fieldname??'';
    $latest_name_format_fieldname = getUsersettingByLabel($currentModule,$current_user->id,$currentModule.'ImportImageNameFormatFieldName');
    $latest_name_format_fieldname = $latest_name_format_fieldname??'';
    $latest_name_format_explode = getUsersettingByLabel($currentModule,$current_user->id,$currentModule.'ImportImageNameFormatExplode');
    $latest_name_format_explode = $latest_name_format_explode??'underline';
    $smarty->assign('LatesdNameFormatFieldName',$latest_name_format_fieldname);
    $smarty->assign('LatesdNameFormatExplode',$latest_name_format_explode);
    $smarty->assign('LatesdImportImageFieldName',$latest_import_image_fieldname);
    //提示
    $importImage_tipArr = array(
        'ImportProductImageTip1','ImportProductImageTip2','ImportProductImageTip3'
    );
    foreach ($importImage_tipArr as $tmp_index =>$importImageTip){
        $importImage_tipArr[$tmp_index] = ($tmp_index+1).'.'.getFixedLabel($importImageTip);
    }
    $smarty->assign('ImportImageTip',$importImage_tipArr);

    $content = $smarty->fetch('ImportImage.tpl');

    $arr=[];
    $arr['content'] = $content;
    $arr['nameFormatExample'] = $name_format_explode_arr;
    $arr['title'] = getFixedLabel('ImportProductImage');
    $arr['oktext'] = getFixedLabel('IMPORT');
    $arr['canceltext'] = getFixedLabel('CANCEL');

    unset($name_format_fieldname_arr,$name_format_explode_arr,$focus,$fieldinfos,$profilefields,$imageField_arr,$fieldinfo,$uitype,$savedatabase,$fieldlabel,$fieldid);
    unset($fieldname,$smarty,$importImage_tipArr,$latest_name_format_explode,$latest_name_format_fieldname,$latest_import_image_fieldname,$content);
    unset($cls_ImportImageobj,$mode);
    ConvertTojsonString(1,$arr,'');

}else if ($mode == 'startImportImage'){//导入图片第一步
    $imagefield = $_REQUEST['imagefield'];
    $nameformatfield = $_REQUEST['nameformatfield'];
    $nameformatexplode = $_REQUEST['nameformatexplode'];
    $importImageArr = $_REQUEST['importImageArr'];
    setUsersettingByLabel($currentModule,$current_user->id,$currentModule.'ImportImageFieldName',$imagefield);
    setUsersettingByLabel($currentModule,$current_user->id,$currentModule.'ImportImageNameFormatFieldName',$nameformatfield);
    setUsersettingByLabel($currentModule,$current_user->id,$currentModule.'ImportImageNameFormatExplode',$nameformatexplode);
    $importImageArr = ldcrm_json_decode($importImageArr);
    $imageField_noerror = $cls_ImportImageobj->startImportImage($imagefield,$nameformatfield,$nameformatexplode,$importImageArr);
    unset($nameformatfield,$nameformatexpload,$importImageArr);
    if ($imageField_noerror){
        $cls_ImportImageobj->setOperationLog($imagefield);
        unset($cls_ImportImageobj,$mode,$imagefield);
        ConvertTojsonString(1,'','success');
    }else{
        unset($cls_ImportImageobj,$mode,$imagefield);
        ConvertTojsonString(-1,'',getFixedLabel('ImportProductImageFieldCanNotUse'));
    }

}else if ($mode == 'ImportImage'){//批量导入图片
    $startIndex = $_REQUEST['startIndex'];
    $endIndex = $_REQUEST['endIndex'];
    $cls_ImportImageobj->importImageIntoAttachment($startIndex,$endIndex);
    $endImportTime = date("Y-m-d H:i:s");
    $arr['timeDescription'] = $cls_ImportImageobj->getProgressContent($endImportTime,$endIndex);
    $maxLength = $_SESSION[$currentModule.'ImportImageInfoArr']['imageTotalNums'];
    $progressPercentage = intval((intval($endIndex)+1)/$maxLength*100);
    $progressPercentage = $progressPercentage > 100 ? 100 : $progressPercentage;
    $arr['progressPercentage'] = $progressPercentage;
    $arr['endImportTime']=$endImportTime;
    $arr['endIndex'] = $endIndex;
    unset($startIndex,$endIndex,$cls_ImportImageobj,$endImportTime,$maxLength,$progressPercentage,$mode);
    ConvertTojsonString(1,$arr,'');

}else if ($mode == 'finishImportImage'){//导入图片结束
//    dump($_SESSION[$currentModule.'ImportImageInfoArr']);
    $arr = $cls_ImportImageobj->finsihImportImage();
    $arr['FixedLabelArr'] = array('ImageImportTimeFinishTip1'=>getFixedLabel('ImageImportTimeFinishTip1'),'ImageImportTimeFinishTip2'=>getFixedLabel('ImageImportTimeFinishTip2'));
    unset($cls_ImportImageobj,$mode);
    ConvertTojsonString(1,$arr,'');

}else if ($mode == 'failImport'){
    unset($cls_ImportImageobj,$mode);

}else if($mode == 'download'){
    $timestr = $_REQUEST['time'];
    $filePath='storage/importImagelog_'.$currentModule.'_'.$current_user->id.'_'.$timestr.'.txt';
    $modulelabel=getFixedLabel('ImportImageLog').'.txt';
    $disk_file_size = filesize($filePath);
    $diskfilesize = $disk_file_size + ($disk_file_size % 1024);
    $fileContent = fread(fopen($filePath, "r"), $diskfilesize);
    header("Content-type: application/ocet-stream");
    header("Pragma: public");
    header("Cache-Control: private");
    //iE:下载中文乱码
    header("Content-Disposition: attachment; filename=".$modulelabel);//iconv ( 'UTF-8', 'GBK', $name )
    header("Content-Description: PHP Generated Data");
    header('Content-Encoding: none');
    header("Content-Transfer-Encoding: binary" );
    ob_clean();
    flush();
    echo $fileContent;
    unset($cls_ImportImageobj,$mode,$timestr,$filePath,$modulelabel,$disk_file_size,$diskfilesize,$fileContent);
    exit();

}







?>