<?php
if(isset($_REQUEST['mode']) && $_REQUEST['mode']=='listview'){
    $menutype = getSys_deploy(476);
    $smarty = new lingdangCRM_Smarty;
    $smarty->assign("menutype", $menutype['deploy_value']);
    $arr['content']= $smarty->fetch('leftmenuuisetting.tpl');
    ConvertTojsonString(1,$arr,"success");
}
elseif (isset($_REQUEST['mode']) && $_REQUEST['mode']=='save'){
    global $adb;
    if(isset($_REQUEST['menutype']) && $_REQUEST['menutype'] != ''){
        $menutype = $_REQUEST['menutype'];
        $update_sql = " update ld_systems_deploy set deploy_value=? where deploy_type=?";
        $adb->pquery($update_sql,array($menutype,476));
        unsetCache('systems_deploy');
        ConvertTojsonString(1,'',"success");
    }

}

?>