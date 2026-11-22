<?php
//导入完成

global $currentModule;
global $current_user;
 $frommodule=$_REQUEST['frommodule'];
 $focus=CRMEntity::getInstance($frommodule);
 $arr['modulelabel']=gettranstab($frommodule);
 $arr['dupfieldlabel']=getFixedLabel('CHECKIMPORTFIELD');//查重字段
 $arr['fileuploadlabel']=getFixedLabel('FILEUPLOAD');//上传文档
 $arr['mappingfieldlabel']=getFixedLabel('MAPPINGFIELD');//映射字段
 $arr['importdatalabel']=getFixedLabel('IMPORTDATATTITLE');//导入数据
 $arr['finishedlabel']=getFixedLabel('TEMPLATECOMPLETE');//完成
 $smarty=new lingdangCRM_Smarty();
 $smarty->assign("STEPINDEX",$_REQUEST['stepindex']);
 $smarty->assign("ARRLABEL",$arr);
$smarty->assign("MODULE",$currentModule);
$smarty->assign("FILENAME",getTranstab($currentModule).'导入日志.txt');

 $tmp['title']=getFixedLabel("IMPORT").$arr['modulelabel'];
 $tmp['oktext']=getFixedLabel('LBL_FINISH_BUTTON_LABEL');
 $maxrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_maxrows'];
 $successRows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows'];
$addimportrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows'];
$updateRows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows'];

if(empty($successRows))
{
    $successRows=0;
}
if(empty($addimportrows))
{
    $addimportrows=0;
}
if(empty($updateRows))
{
$updateRows=0;
}
$totalrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows'];
 $smarty->assign("HANGSHU",$maxrows);
 $smarty->assign("IMPORTINFO",$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_error']);
 $smarty->assign('SUCCESSROWS',$successRows);
 $smarty->assign('ADDIMPORTROWS',$addimportrows);
 $smarty->assign('UPDATEROWS',$updateRows);
 $smarty->assign('TOTALROWS',$totalrows);
 
 /*
 *edit: chj
 *date: 2020/7/24
 *reason: 42087: （https://61mis.com/kfbtest [^] ）费用报销单->导入：覆盖导入，导入成功后，导入结果提示信息显示错误
 */
$ERRORROWS = ($totalrows-$successRows - $updateRows);
if($ERRORROWS <0){
    $ERRORROWS = 0;
}
//zxm 2021-0117 【提个优化的需求：数据导入完之后，如果有失败提示的话，希望失败提示字样显示红色，看起来比较直观，操作太快老是误点（谢彦涛）】https://www.tapd.cn/63637123/prong/stories/view/1163637123001001150
if($ERRORROWS>=1){
    $smarty->assign('ERRORROWSCOLOR','<span style="color:red">');
}else{
    $smarty->assign('ERRORROWSCOLOR','<span>');
}
 $smarty->assign('ERRORROWS',$ERRORROWS);
 $smarty->assign("PRODUCTIMPORTYPE",$_REQUEST['product_import_type']);
 $smarty->assign("SUCCESSDETAILSCOUNT",$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successdetailcount']);
 $smarty->assign("FAILUREDETAILSCOUNT",$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_failuredetailscount']);

 $filehandler=fopen('storage/importlog_'.$currentModule.'_'.$current_user->id.'.txt','w+');
 $error=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_error'];
if($error=="")
{
    $error='<br>';
}
fwrite($filehandler,str_replace('<br>',"\r\n",$error));
fclose($filehandler);
//系统导入日志
$logid = $_SESSION[$currentModule][$current_user->id]['importlog']['logid'];
$filehandler_backup = $cls_operationLogs->backUpFileWithTime('storage/importlog_'.$currentModule.'_'.$current_user->id.'.txt');
$cls_operationLogs->saveFinishLogs($logid,$filehandler_backup,$totalrows,$ERRORROWS);

$smarty->assign("FILEPATH",'storage/importlog_'.$currentModule.'_'.$current_user->id.'.txt');

 include(globalStatic::$root_directory.'modules/XlsImportNew/ImportclearSession.php');//清空session
 $_REQUEST['diony']='yes';
 $tmp['content']=$smarty->fetch('ImportXlsNew/FinishedImport.tpl');
 ConvertTojsonString(1,$tmp,'success');
?>