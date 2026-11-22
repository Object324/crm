<?php
//导入完成

global $currentModule;
global $current_user;
$frommodule = $_REQUEST['frommodule'];
$focus = CRMEntity::getInstance($frommodule);
$arr['modulelabel'] = gettranstab($frommodule);
$arr['dupfieldlabel'] = getFixedLabel('CHECKIMPORTFIELD');//查重字段
$arr['fileuploadlabel'] = getFixedLabel('FILEUPLOAD');//上传文档
$arr['mappingfieldlabel'] = getFixedLabel('MAPPINGFIELD');//映射字段
$arr['importdatalabel'] = getFixedLabel('IMPORTDATATTITLE');//导入数据
$arr['finishedlabel'] = getFixedLabel('TEMPLATECOMPLETE');//完成
$smarty = new lingdangCRM_Smarty();
$smarty->assign("STEPINDEX", $_REQUEST['stepindex']);
$smarty->assign("ARRLABEL", $arr);
$smarty->assign("MODULE", $currentModule);
$smarty->assign("FILENAME", getTranstab('Products') . '导入日志.txt');

$tmp['title'] = getFixedLabel("IMPORTENTRY");
$tmp['oktext'] = getFixedLabel('LBL_FINISH_BUTTON_LABEL');
$maxrows = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_maxrows'];
$successRows = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_successrows'];
$addimportrows = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_addimportrows'];
$updateRows = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_updaterows'];

if (empty($successRows)) {
    $successRows = 0;
}
if (empty($addimportrows)) {
    $addimportrows = 0;
}
if (empty($updateRows)) {
    $updateRows = 0;
}
$totalrows = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_totalrows'];

$smarty->assign("HANGSHU", $maxrows);
$smarty->assign("IMPORTINFO", $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_error']);
$smarty->assign('SUCCESSROWS', $successRows);
$smarty->assign('ADDIMPORTROWS', $addimportrows);
$smarty->assign('UPDATEROWS', $updateRows);
$smarty->assign('TOTALROWS', $totalrows);


$smarty->assign('ERRORROWS', ($totalrows - $addimportrows));
$smarty->assign("PRODUCTIMPORTYPE", $_REQUEST['product_import_type']);

$filehandler = fopen('storage/importlog_' . $currentModule . '_' . $current_user->id . '.txt', 'w+');
$error = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_error'];
if ($error == "") {
    $error = '<br>';
}
fwrite($filehandler, str_replace('<br>', "\r\n", $error));
fclose($filehandler);
$smarty->assign("FILEPATH", 'storage/importlog_' . $currentModule . '_' . $current_user->id . '.txt');
//editor:gyq_162 reason:海格产品分录导入   2019/12/11 16:34
include(globalStatic::$root_directory.'modules/XlsImportNew/ImportclearSession.php');//清空session
$_REQUEST['diony'] = 'yes';
$tmp['content'] = $smarty->fetch('ImportXlsNew/documentEntry/FinishedImport.tpl');
ConvertTojsonString(1, $tmp, 'success');
?>