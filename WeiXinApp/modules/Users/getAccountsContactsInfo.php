<?php
/**
* 获取单据客户和联系人字段信息
* editor:xxs
* date:20180720
*/

crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');

$frommodule = $_REQUEST['frommodule'];

$obj = new cls_DetailViewWX($frommodule);

$accountcontactsinfo = $obj->getAccountsContactsInfo($obj->focus,'true');

ConvertTojsonString(1,array('list'=>$accountcontactsinfo['fieldinfo']),'');
?>