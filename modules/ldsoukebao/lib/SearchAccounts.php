<?php
$ajax = $_REQUEST['ajax'];
$data = [];
if(isset($ajax)&&$ajax=='true')
{
    $searchtext = $_REQUEST['searchtext'];
    $searchcolumn = $_REQUEST['searchcolumn'];
    crm_load_class_file("cls_soukebao","modules/ldsoukebao/lib");
    $soukebaoobj = cls_soukebao::getInstance();
    $soukebaoobj->setsearchtext($searchtext);
    $soukebaoobj->setsearchcolumn($searchcolumn);
    $soukebaoobj->setoperationtype("searchtext");
    $data = $soukebaoobj->getlistByoperationtype();
    ConvertTojsonString(1,$data,'sussess');
}
$data['title'] = '找企业，就上搜客宝';
$data['placeholder'] = '请输入公司名称';
$data['searchbuttontext'] = '搜一搜';
$data['searchcolumn'] = 'corpname';
ConvertTojsonString(1,$data,'sussess');
?>
