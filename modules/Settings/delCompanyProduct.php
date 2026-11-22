<?php
global $adb;
/***
 * zxm
 * 2020-9-23
 * 公司产品简介的删除
 */
$_REQUEST['diony']='diony';
$id = from_html($_REQUEST['id']);
$sql = "delete from ld_organizationdetails_product where id=".$id;
$res = $adb->pquery($sql);
ConvertTojsonString(1,null,"success");