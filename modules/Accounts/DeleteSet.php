<?php
global $currentModule;
$focus = CRMEntity::getInstance($currentModule);

global $mod_strings;

//Added to fix 4600
$url = getBasic_Advance_SearchURL();
$deploy_values=getSys_deploy("69");
// 系统参数 有关联单据时不允许删除客户 zyh 20150611
if($deploy_values['deploy_value']==1&&Delverify($currentModule,$_REQUEST['record'])>0){
    //$hurl = 'index.php?module=Accounts&action=DetailView'.'&record='.vtlib_purify($_REQUEST['return_id']).'&parenttab='.$parenttab.'&relmodule='.vtlib_purify($_REQUEST['module']).$url;//这句有问题，用下面的替换。
    $hurl = 'index.php?module=Accounts&action=DetailView'.'&record='.vtlib_purify($_REQUEST['record']).'&parenttab='.$parenttab.'&relmodule='.vtlib_purify($_REQUEST['module']).$url;
    $srt1 = getFixedLabel('THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED');
    $entity['log']['value'] = $srt1;
    $entity['title']['value'] = getFixedLabel('DELETE');//当前页数
   
    $json = new Zend_Json();
    $jsonentity = $json->encode($entity);
    echo $jsonentity;die;
}
else
{
    @ob_clean();
    include(globalStatic::$root_directory.'modules/Accounts/Delete.php');
}

?>