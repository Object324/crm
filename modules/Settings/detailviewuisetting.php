<?php
global $current_user,$adb;
if(isset($_REQUEST['mode']) && $_REQUEST['mode']=='listview'){
    $listviewtype = getSys_deploy(474);
    $smarty = new lingdangCRM_Smarty;
    $smarty->assign("listviewtype", $listviewtype['deploy_value']);
    $arr['content']= $smarty->fetch('detailviewuisetting.tpl');
    ConvertTojsonString(1,$arr,"success");
}
elseif (isset($_REQUEST['mode']) && $_REQUEST['mode']=='save'){
    if(isset($_REQUEST['detailviewtype']) && $_REQUEST['detailviewtype'] != ''){
        $listviewtype = $_REQUEST['detailviewtype'];
        $update_sql = " update ld_systems_deploy set deploy_value=? where deploy_type=?";
        $adb->pquery($update_sql,array($listviewtype,474));
        unsetCache('systems_deploy');
        ConvertTojsonString(1,'',getFixedLabel('SUCCESSFULLYMODIFIED'));
    }

}

?>