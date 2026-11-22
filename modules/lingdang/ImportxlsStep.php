<?php
//editor:gyq_162 reason:海格产品分录导入   2019/12/5 11:59
if(isset($_REQUEST['second_file_index']) && $_REQUEST['second_file_index']=='documentEntry'){
    include(globalStatic::$root_directory."modules/XlsImportNew/documentEntryIndex.php");
    exit;
}
$frommodule=$_REQUEST['frommodule'];
crm_load_class_file('cls_OperationLogs','modules/Settings/cls_OperationLogs');//系统导入日志
$cls_operationLogs = cls_OperationLogs::getInstance($frommodule,'Import');
if($_REQUEST['stepindex']==1)
{
    include("modules/XlsImportNew/ImportFirst.php");
    
}
else if($_REQUEST['stepindex']==2)
{
    if(get_file_address($frommodule,"ProductDetails")&&$frommodule!='ServiceCharge')
    {
        include("modules/XlsImportNew/ImportSecondDetail.php");
    }
    else if($frommodule=='Accounts')
    {
         include("modules/XlsImportNew/ImportSecondAccountContact.php");
    }
    else if($frommodule=='CashBill'||$frommodule == 'SendCashBill')
    {
         include("modules/XlsImportNew/ImportSecondBillDetail.php");
    }
    else if(get_file_address($frommodule,$frommodule.'DetailFieldsHtml')||$frommodule=='TimeSheet')
    {
        include("modules/XlsImportNew/ImportSecondTabDetail.php");
    }
    else{
        include("modules/XlsImportNew/ImportSecond.php");
    }
}
else if($_REQUEST['stepindex']==3)
{
    //导入失败，日志更新
    if($_REQUEST['finishimportlog']=='yes'){
        $logid = $_SESSION[$currentModule][$current_user->id]['importlog']['logid'];
        $filehandler_backup = $cls_operationLogs->backUpFileWriteIn(json_decode($_REQUEST['errormsg']));
        $cls_operationLogs->saveFinishLogs($logid,$filehandler_backup,0,0,'ImportFailed');
        ConvertTojsonString(1,array(),'success');
    }

    if(get_file_address($frommodule,"ProductDetails")&&$frommodule!='ServiceCharge')
    {
        $focus=CRMEntity::getInstance($frommodule);
        $uitype=$focus->fieldobj->getFieldInfoBykeyValue("uitype",202,'uitype');
        if(!empty($uitype))
        {
            //有原单的产品明细导入
            include("modules/XlsImportNew/ImportthreeDetailEntity.php");
        }
        else
            include("modules/XlsImportNew/ImportthreeDetail.php");
    }
    else if($frommodule=='CashBill'||$frommodule == 'SendCashBill')
    {
        include("modules/XlsImportNew/ImportthreeBillDetail.php");
    }
     else if(get_file_address($frommodule,$frommodule.'DetailFieldsHtml'))
    {
        include("modules/XlsImportNew/ImportthreeTabDetail.php");
    }
    else if($frommodule=='Accounts')
    {
        include("modules/XlsImportNew/ImportthreeAccountContact.php");
    }
    else if($frommodule=='TimeSheet')
    {
        include("modules/XlsImportNew/ImportTimeSheetThree.php");
    }
    else
        include("modules/XlsImportNew/Importthree.php");
    
}
else if($_REQUEST['stepindex']==4){

    include("modules/XlsImportNew/ImportFinished.php");
}
else if($_REQUEST['clearimportsession']=='yes')
{
    include("modules/XlsImportNew/ImportclearSession.php");
}
else if($_REQUEST['getimportrows']=='yes')
{   
    // dump($_REQUEST);
    //导入失败，日志更新
    if($_REQUEST['finishimportlog']=='yes'){
        $logid = $_SESSION[$currentModule][$current_user->id]['importlog']['logid'];
        $filehandler_backup = $cls_operationLogs->backUpFileWriteIn(json_decode($_REQUEST['errormsg']));
        $cls_operationLogs->saveFinishLogs($logid,$filehandler_backup,0,0,'ImportFailed');
        ConvertTojsonString(1,array(),'success');
    }else{
        //开始导入，生成日志，系统导入日志
        $filenamess_bkup = $cls_operationLogs->backUpFile($_SESSION[$currentModule][$current_user->id]['importlog']['filenamess']);//备份文件
        $logid = $cls_operationLogs->saveImportStartLogs($_REQUEST['choose'],$_REQUEST['importdupcheckfields'],$_REQUEST['importdupfields_condition'],$filenamess_bkup,$_REQUEST['product_import_type']);//导入开始
        $_SESSION[$currentModule][$current_user->id]['importlog']['logid'] = $logid;
    }
    //把导入的数据存入到session
    //导入数据的进度条
    if(get_file_address($frommodule,"ProductDetails")&&$frommodule!='ServiceCharge')
    {
        include("modules/XlsImportNew/XlsInsertTmpMemoryDetail.php");
    }
    else if($frommodule=='Accounts')
    {
        include("modules/XlsImportNew/XlsInsertAccountContactMemory.php");
    }
    else if(get_file_address($frommodule,$frommodule.'DetailFieldsHtml')||$frommodule=='TimeSheet')
    {
        include("modules/XlsImportNew/XlsInsertTmpTabMemory.php");
    }
    else{
        include("modules/XlsImportNew/XlsInsertTmpMemory.php");
    }

}
else if($_REQUEST['getprogress']='yes'){
    
     include("modules/XlsImportNew/ImportProgress.php");
}
?>