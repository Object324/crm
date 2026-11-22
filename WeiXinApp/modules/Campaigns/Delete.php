<?php
global $currentModule;
$focus = CRMEntity::getInstance($currentModule);

//wym 240528 1000063 合同订单等模块增加有关联单据不允许删除功能（王耀文）
if(Delverify($_REQUEST['module'],$_REQUEST['record'])>0){
    $srt1 = getFixedLabel('THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED');
    ConvertTojsonString('-1',null,$srt1);
}else{
    DeleteEntity($_REQUEST['module'],$_REQUEST['module'],$focus,$_REQUEST['record'],'');
    ConvertTojsonString('1',null,'');
}
?>