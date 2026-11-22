<?php
if(isset($_REQUEST['mode']) && $_REQUEST['mode']=='listview'){
    $smarty = new lingdangCRM_Smarty;
    $listviewtabletype = getSys_deploy(484);
    $menutype = getSys_deploy(476);
    $listviewtype = getSys_deploy(473);
    $detailviewtype = getSys_deploy(474);
    $popupbuttontype = getSys_deploy(488);
    $smarty->assign("listviewtabletype", $listviewtabletype['deploy_value']);
    $smarty->assign("menutype", $menutype['deploy_value']);
    $smarty->assign("listviewtype", $listviewtype['deploy_value']);
    $smarty->assign("detailviewtype", $detailviewtype['deploy_value']);
    $smarty->assign("popupbuttontype", $popupbuttontype['deploy_value']);
    $arr['content']= $smarty->fetch('globaluisetting.tpl');
    ConvertTojsonString(1,$arr,"success");
}
elseif (isset($_REQUEST['mode']) && $_REQUEST['mode']=='save'){
    global $adb;
    if(isset($_REQUEST['uitype']) && $_REQUEST['uitype'] != '' && isset($_REQUEST['uisetting']) && $_REQUEST['uisetting'] != ''){
        $uitype = $_REQUEST['uitype'];
        $uisetting=$_REQUEST['uisetting'];
        $deploy_type='';
        switch ($uisetting){
            case 'ld_leftmenu_ui_setting':
                $deploy_type=476;
                break;
            case 'ld_listview_top_ui_setting':
                $deploy_type=473;
                break;
            case 'ld_listview_tabel_ui_setting':
                $deploy_type=484;
                break;
            case 'ld_detailview_detail_ui_setting':
                $deploy_type=474;
                break;
            case 'ld_popup_button_ui_setting':
                $deploy_type=488;
                break;
            default:
                break;
        }
        if(!empty($deploy_type)){
            $update_sql = " update ld_systems_deploy set deploy_value=? where deploy_type=?";
            $adb->pquery($update_sql,array($uitype,$deploy_type));
            unsetCache('systems_deploy');
        }
        ConvertTojsonString(1,'',"success");
    }
}
