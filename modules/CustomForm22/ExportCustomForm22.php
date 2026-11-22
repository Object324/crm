<?php
if($_REQUEST['langjieExport']){
    include(globalStatic::$root_directory.'modules/CustomForm22/ExporttabDetailsNewLangjie.php');
}else{
    include(globalStatic::$root_directory.'modules/lingdang/Export/ExporttabDetailsNew.php');
}
?>