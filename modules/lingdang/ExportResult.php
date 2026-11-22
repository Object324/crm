<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
global $current_user;
$exportformat = $_REQUEST['exportformat'];
$title = $_REQUEST['title'];
$report_name = $_REQUEST['report_name'];
$export_type = $_REQUEST['export_type'];
$versionInfo = getVersionInfo();

if($versionInfo['account'] =='langjie'){
    if($_REQUEST['fileName'] && $_REQUEST['fileName'] != '' ){
        $fileName =$_REQUEST['fileName'];
    }
    if($_REQUEST['fileSuffix'] && $_REQUEST['fileSuffix'] !=''){
        $fileSuffix = $_REQUEST['fileSuffix'];
    }
}
/*
require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
$wx_downloadurl='';
if(isKehu001ServerPc()=='yes')
{
    $modulelabel=getTranstab($currentModule);
    preg_match_all('/[\s\x{4e00}-\x{9fff}a-zA-Z0-9#\[\]\{\}\'\"=+\-\(\)*&%$@]+/iu', $modulelabel, $matches);
    $modulelabels = join('', $matches[0]);
    //edit:can 20200713 上传导出文件，转义用户和部门名称
   if($_REQUEST['exportformat']=='exportcsv')
    {
        $pathname='storage/'.$current_user->id.'_'.$currentModule.'.csv';
       $renamefile= $modulelabels.'.csv';
    }
    else
    {
        $pathname='storage/'.$current_user->id.'_'.$currentModule.'.xls';
        $renamefile= $modulelabels.'.xls';
    
    }
    require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
    $portobj=new cls_WeixinPort();
    
    $wx_downloadurl=  $portobj->UploadUserInfoFile(globalStatic::$root_directory.$pathname,$renamefile);
   
}*/

$strhtml = '<table class="settingPopTable lasttdbordernon marB10" border="0" cellpadding="0" cellspacing="0" width="100%">
      <tbody><tr>
        <td>
            <div class="qui_dialog_body ld-dialog-Boxbody">
                <div class="ld-msgDlg-Boxtop">
                    <div class="ld-commonImg ld-commonImg-BoxSuccess ld-msgDlg-top-icon"></div>
                </div>
                <div class="padT10 ctextalign font16">' . getFixedLabel('ExportSuccessful') . '</div>
            </div>
            <div class="padTB10 ctextalign font16"> ';
            if($versionInfo['account'] =='langjie' && $_REQUEST['langjieExport']){
                if($fileSuffix == '.xlsx'){
                    $strhtml.='<a href="index.php?module=uploads&frommodule='.$currentModule.'&action=downloadLangjieFile&exportformat=exportxls&fileName='.$fileName.'" class="cursorPointer font14">'.getFixedLabel('DOWNLOADXLS').'</a>';
                }else{
                    $strhtml.='<a href="index.php?module=uploads&frommodule='.$currentModule.'&action=downloadLangjieFile&exportformat=exportzip&fileName='.$fileName.'" class="cursorPointer font14">'.getFixedLabel('DOWNLOAD').getFixedLabel('FILE').'</a>';
                }

            }else{
                if($wx_downloadurl!='')
                {
                    //edit:can 20200713 kehu001下载导出文件
                    if ($exportformat == 'exportcsv')
                            $strhtml .= '<a href="'.$wx_downloadurl.'" class="cursorPointer font14">' . getFixedLabel('DOWNLOADCSV') . '</a>';
                    else
                            $strhtml .= '<a href="'.$wx_downloadurl.'" class="cursorPointer font14">' . getFixedLabel('DOWNLOADXLS') . '</a>';
                }//自定义报表 sql报表导出后下载
                else if ($export_type == "report"){//wsh 20240814 XUQIU20240708-01 报表管理-报表分析-自定义统计表/SQL统计表 导出优化数据多的情况下做成单据列表那种的进度条导出，现在的做法数据多直接内存溢出
                    if ($exportformat == 'exportcsv')
                        $strhtml .= '<a href="index.php?module=uploads&frommodule=' . $currentModule . '&action=downloadxls&exportformat=exportcsv&export_type=report&report_name=' . urlencode($report_name) .'" class="cursorPointer font14">' . getFixedLabel('DOWNLOADCSV') . '</a>';
                    else
                        $strhtml .= '<a href="index.php?module=uploads&frommodule=' . $currentModule . '&action=downloadxls&exportformat=exportxls&export_type=report&report_name=' . urlencode($report_name) .'" class="cursorPointer font14">' . getFixedLabel('DOWNLOADXLS') . '</a>';

                }
                else if ($export_type == 'chuantou'){
                    ////zxm @date:2024/11/13 @reason: 天地的简报 中英文名称有html 导出
                    $title = strip_tags($title);
                    if ($exportformat == 'exportcsv')
                        $strhtml .= '<a href="index.php?module=uploads&frommodule=' . $currentModule . '&action=downloadxls&exportformat=exportcsv&export_chuantou=yes&title=' . $title .'" class="cursorPointer font14">' . getFixedLabel('DOWNLOADCSV') . '</a>';
                    else
                        $strhtml .= '<a href="index.php?module=uploads&frommodule=' . $currentModule . '&action=downloadxls&exportformat=exportxls&export_chuantou=yes&title=' . $title .'" class="cursorPointer font14">' . getFixedLabel('DOWNLOADXLS') . '</a>';
                }
                else{
                    if ($exportformat == 'exportcsv')
                        $strhtml .= '<a href="index.php?module=uploads&frommodule=' . $currentModule . '&action=downloadxls&exportformat=exportcsv" class="cursorPointer font14">' . getFixedLabel('DOWNLOADCSV') . '</a>';
                    else
                        $strhtml .= '<a href="index.php?module=uploads&frommodule=' . $currentModule . '&action=downloadxls&exportformat=exportxls" class="cursorPointer font14">' . getFixedLabel('DOWNLOADXLS') . '</a>';
                }
            }
                $strhtml .= ' </div>
               
        </td>
      </tr>
    </tbody></table>';

//系统导出日志
crm_load_class_file('cls_OperationLogs','modules/Settings/cls_OperationLogs');
$cls_operationLogs = cls_OperationLogs::getInstance($_REQUEST['module'],'Export');
$logid = $_SESSION[$currentModule][$current_user->id]['exportlog']['logid'];
$pathname_backup = $cls_operationLogs->backUpFileWithTime($_SESSION[$currentModule][$current_user->id]['exportlog']['pathname']);
$cls_operationLogs->saveFinishLogs($logid,$pathname_backup);

$_REQUEST['diony'] = 'yes';
$arr['content'] = $strhtml;
//$arr['title'] = getTranstab($currentModule) . '>' . getFixedLabel('EXPORT');
global $languageType;
if($languageType == 'en') {
    $arr['title'] = getFixedLabel("EXPORT") .' '. getTranstab($currentModule);
}
else{
    $arr['title'] = getFixedLabel("EXPORT") . getTranstab($currentModule);
}
//$arr['oktext']=getFixedLabel('OK');
unset($_SESSION[$from_module][$current_user->id]['export']);
if($versionInfo['account'] =='langjie') {
    unset($_SESSION[$currentModule][$current_user->id]['export']);
}

ConvertTojsonString(1, $arr, 'success');
?>