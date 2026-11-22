<?php
/**
 * 更新操作
 * date:20150817
 * edit：cyb
 * reason:保存模板定制分配人员
 * */
global $adb;
$qrcodetemplateid = $_REQUEST['qrcodetemplateid']; //获取模板ID
//获取域名
//$domain = $_SERVER['HTTP_REFERER'];
//$domain = explode('index.php?',$domain);
//$domain = $domain[0];
//$content = $_REQUEST['CKTemplatePrint'];
//$content = str_replace($domain.'storage/','storage/',$content);
if(empty($qrcodetemplateid)){
    $sql='insert into ld_qrcode_template(template_content,replacespacevalue)values(?,?)';
    $adb->pquery($sql,array($_REQUEST['CKTemplatePrint'],$_REQUEST['replacespacevalue']));
    $qrcodetemplateid = $adb->getLastInsertID();
}else{
    $sql='update ld_qrcode_template set template_content=?,replacespacevalue=? where qrcodetemplateid=?';
    $adb->pquery($sql,array($_REQUEST['CKTemplatePrint'],$_REQUEST['replacespacevalue'],$_REQUEST['qrcodetemplateid']));
}
ConvertTojsonString(1,array('qrcodetemplateid'=>$qrcodetemplateid),"success");
