<?php
//editor:gyq_162 reason:海格产品分录导入   2019/12/5 11:40
if ($_REQUEST['module'] == 'Users' && isset($_REQUEST['file'])) {
    /*$_REQUEST['file']=
        ExportTemplateFile 导出模板文件
    */
    include(globalStatic::$root_directory . 'modules/XlsImportNew/documentEntry/' . $_REQUEST['file'] . '.php');
    exit;
}
$frommodule = $_REQUEST['frommodule'];

if ($_REQUEST['stepindex'] == 1) {
    //导入第一步，显示文件上传界面
    include(globalStatic::$root_directory . "modules/XlsImportNew/documentEntry/ImportFirst.php");
} else if ($_REQUEST['stepindex'] == 2) {
    //导入第一步，显示映射字段界面
    if (get_file_address($frommodule, "ProductDetails") && $frommodule != 'ServiceCharge') {

        include(globalStatic::$root_directory . "modules/XlsImportNew/documentEntry/ImportSecondDetail.php");
    } /*else if($frommodule=='Accounts')
    {
        include("modules/XlsImportNew/ImportSecondAccountContact.php");
    }*/
    else if (get_file_address($frommodule, $frommodule . 'DetailFieldsHtml') || $frommodule == 'TimeSheet') {
        include("modules/XlsImportNew/documentEntry/ImportSecondTabDetail.php");
    }
    /*else
        include("modules/XlsImportNew/ImportSecond.php");*/
} else if ($_REQUEST['stepindex'] == 3) {
    if (get_file_address($frommodule, "ProductDetails") && $frommodule != 'ServiceCharge') {
        //eidtor:gyq_20191218 reason:去除源单字段
        include("modules/XlsImportNew/documentEntry/ImportthreeDetail.php");
        /*$focus = CRMEntity::getInstance($frommodule);
        $uitype = $focus->fieldobj->getFieldInfoBykeyValue("uitype", 202, 'uitype');
        if (!empty($uitype)) {
            //有原单的产品明细导入
            include("modules/XlsImportNew/documentEntry/ImportthreeDetailEntity.php");
        } else
            include("modules/XlsImportNew/documentEntry/ImportthreeDetail.php");*/
    } else if (get_file_address($frommodule, $frommodule . 'DetailFieldsHtml')) {
        include("modules/XlsImportNew/documentEntry/ImportthreeTabDetail.php");
    }
} else if ($_REQUEST['stepindex'] == 4) {

    include("modules/XlsImportNew/documentEntry/ImportFinished.php");
} else if ($_REQUEST['clearimportsession'] == 'yes') {
    include("modules/XlsImportNew/ImportclearSession.php");
} else if ($_REQUEST['getimportrows'] == 'yes') {
    //把导入的数据存入到session
    //导入数据的进度条
    if (get_file_address($frommodule, "ProductDetails") && $frommodule != 'ServiceCharge') {
        include("modules/XlsImportNew/documentEntry/XlsInsertTmpMemoryDetail.php");
    } else if (get_file_address($frommodule, $frommodule . 'DetailFieldsHtml') || $frommodule == 'TimeSheet') {
        include("modules/XlsImportNew/documentEntry/XlsInsertTmpTabMemory.php");
    }
} else if ($_REQUEST['getprogress'] = 'yes') {

    include("modules/XlsImportNew/ImportProgress.php");
}
?>
