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
    $smarty->assign('boardid',$_REQUEST['boardid']);
    $smarty->assign('DATASELECT',$data_select);
    $smarty->assign('deploy_value',$_REQUEST['selecttimevalue']);
    setGLobalURLSmarty($smarty);//设置js,css等访问路径
    $smarty->display("Home/TimeSearchDefault.tpl");
    $content = $smarty->fetch('Home/TimeSearchDefault.tpl');
    $_REQUEST['diony']='diony';
    $res['content'] = $content;
    $res['cancelbtn'] = getFixedLabel('CLOSE');
    $res['okbtn'] = getFixedLabel('SAVE');
    $res['title'] = getFixedLabel('Setquerytimedefault');
    ConvertTojsonString(1,$res,'success');
}elseif($mode=="save"){
    $sql = 'update ld_homeboard set timesearchdefault = ? where boardid = ?;';
    $adb->pquery($sql,array($_REQUEST['select_datavalue'],$_REQUEST['boardid']));
    ConvertTojsonString(1,'','success');
}