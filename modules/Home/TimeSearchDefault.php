<?php
global $adb;
//系统设置的默认时间 zxm20211112 【首页，销售简报时间增加可设置默认值（王楠）】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001002217
//首页时间条件 设置默认值
$mode = $_REQUEST['mode'];
if($mode=="edit"){
    $smarty=new lingdangCRM_Smarty;
    crm_load_class_file('DateOperation','include');
    $data_select = DateOperation::getHomeDateSearchSelect();
    unset($data_select["custom"]);
    $smarty->assign('DATASELECT',$data_select);
    //$deploy_value = getSys_deploy('345');
    $select_sql = "select deploy_value from ld_systems_deploy where deploy_type=?";
    $select_res = $adb->pquery($select_sql,array(345));
    $deploy_value = $adb->query_result($select_res,0,0);
    $smarty->assign('deploy_value',$deploy_value);
    setGLobalURLSmarty($smarty);//设置js,css等访问路径
    $smarty->display("Home/TimeSearchDefault.tpl");
    $content = $smarty->fetch('Home/TimeSearchDefault.tpl');
    $_REQUEST['diony']='diony';
    $res['content'] = $content;
    $res['cancelbtn'] = getFixedLabel('CLOSE');
    $res['okbtn'] = getFixedLabel('SAVE');
    $res['title'] = getFixedLabel('Setquerytimedefault');
    ConvertTojsonString(1,$res,'success');
}else{
    $timeValue = $_REQUEST['timeValue'];
    $update_sql = " update ld_systems_deploy set deploy_value=? where deploy_type=?";
    $adb->pquery($update_sql,array($timeValue,345));
    getSys_deploy('aa');
    ConvertTojsonString(1,array(),'success');
}
