<?php
//综合报表的file
if($_REQUEST['reportmodule']=='Comprehensivereport'){
    $moduleFilepath = 'modules/Comprehensivereport/'.$_REQUEST['file'].'.php';
}else{
    $moduleFilepath = 'modules/'.$_REQUEST['module'].'/'.$_REQUEST['file'].'.php';

    if(file_exists($moduleFilepath) == false) {
        $moduleFilepath1 = 'modules/OftenUseReport/'.$_REQUEST['file'].'.php';
        $moduleFilepath2 = 'modules/Customreport/'.$_REQUEST['file'].'.php';
        $moduleFilepath3 = 'modules/Comprehensivereport/'.$_REQUEST['file'].'.php';
        if(file_exists($moduleFilepath1)){
            $moduleFilepath = $moduleFilepath1;
        }else if(file_exists($moduleFilepath2)){
            $moduleFilepath = $moduleFilepath2;
        }else if(file_exists($moduleFilepath3)){
            $moduleFilepath = $moduleFilepath3;
        }else{
            $moduleFilepath = 'modules/lingdang/'.$_REQUEST['file'].'.php';
        }
    }
}
checkFileAccessForInclusion($moduleFilepath);
require_once $moduleFilepath;
?>