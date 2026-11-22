<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

$deployarray=getSys_deploy(205);//设置销售机会是否显示产品分录明细:0是，1否
if($deployarray['deploy_value']==0)
{
    chmod(globalStatic::$root_directory.'modules/Potentials',0777);
    $filehandler=fopen(globalStatic::$root_directory.'modules/Potentials/ProductDetails.php','w');
    fclose($filehandler);
    include(globalStatic::$root_directory.'modules/lingdang/InventoryListView.php');
    
}
else
{
    @unlink('modules/Potentials/ProductDetails.php');
    
    include(globalStatic::$root_directory.'modules/lingdang/ListView.php');
}

?>