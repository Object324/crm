<?php
global $current_user,$adb;
if(isset($_REQUEST['mode']) && $_REQUEST['mode']=='listview'){
    $listviewtype = getSys_deploy(473);
    $smarty = new lingdangCRM_Smarty;
    $smarty->assign("listviewtype", $listviewtype['deploy_value']);
    $arr['content']= $smarty->fetch('listviewtopuisetting.tpl');
    ConvertTojsonString(1,$arr,getFixedLabel('SUCCESSFULLYMODIFIED'));
}
elseif (isset($_REQUEST['mode']) && $_REQUEST['mode']=='save'){
    if(isset($_REQUEST['listviewtype']) && $_REQUEST['listviewtype'] != ''){
        $listviewtype = $_REQUEST['listviewtype'];
        $update_sql = " update ld_systems_deploy set deploy_value=? where deploy_type=?";
        $adb->pquery($update_sql,array($listviewtype,473));
        unsetCache('systems_deploy');
        ConvertTojsonString(1,'',getFixedLabel('SUCCESSFULLYMODIFIED'));
    }

}

?>