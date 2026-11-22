<?php
$deployarray=getSys_deploy(205);//设置销售机会是否显示产品分录明细:0是，1否
if($deployarray['deploy_value']==0)
{
    include(globalStatic::$root_directory.'modules/lingdang/Export/ExportInventoryListViewNew.php');

    
}
else
    include(globalStatic::$root_directory.'modules/lingdang/Export/ExportSingleDataNew.php');

?>