<?php
global $currentModule;
//crm_load_class_file('cls_ListViewWX', 'WeiXinApp/list');
//$mobj = new cls_ListViewWX($currentModule);

//zxm 2020-1225 收款计划 销售助手跳转条件 预计收款日期
$mobj = cls_Instance::get_moduleAction_Instance('PaymentPlan','ListView');
$details = $mobj->get_listdetail(null,null);
$list_buttons = array();
$details['list2'] = array(
    'viewname' => $_REQUEST['viewid'],
    'create_html'=>$list_buttons);
ConvertTojsonString(1, $details, 'success');
?>
