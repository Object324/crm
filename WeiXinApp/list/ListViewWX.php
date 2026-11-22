<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
$module = $currentModule;
$relatemodule = $_REQUEST['related_module'];
//editor:gyq_130 reason:合同订单  2019/7/10 11:38 ID1000554
//zxm 20201225 销售机会、服务合同-销售助手穿透条件
if($module=='SalesOrder'||$module=='Potentials'||$module=='ServiceContracts'){
    $mobj = cls_Instance::get_moduleAction_Instance($module,'ListView');
}else{
    crm_load_class_file('cls_ListViewWX', 'WeiXinApp/list');
    $mobj = new cls_ListViewWX($currentModule);
}
$details = $mobj->get_listdetail("",null);
//产品相关信息暂时隐藏新增按钮  gyqTE
if (isPermitted($module, 'Create', '') == 'yes'&&$relatemodule!='Products') {
    if(empty($mobj->relatedModuleActions) || strpos($mobj->relatedModuleActions,'add')!==false){
        $list_buttons = array(1);
    }else{
        $list_buttons = array();
    }
} else {
    $list_buttons = array();
}

//diony 20190301 销售退货单、销售退款单、采购退货单、采购退款单去掉新增功能
//ls 20221101 Xuqiu1000213 服务回访单、销售退货单、采购退货单、销售退款单、采购退款单增加“新建”功能（放开新增按钮）
/*if($relatemodule==''){
    switch ($module) {
        case 'CashBack':
        case 'PurchaseBack':
        case 'PurchaseCashBack':
        case 'SalesBack':
            $list_buttons = array();
            break;
    }
}*/
//产品管理-购物车功能
if($module=='Products'){
    crm_load_class_file('Shopcart','modules/Products');
    $shopcartobj = new Shopcart();
    $shopcart_arr = array();
    $result = $shopcartobj->shopcart_button();
    if(sizeof($result)>0){
        $shopcartobj->check_nums();
        $shopcart_arr['permit']='yes';
        $shopcart_arr['cur_num'] = $shopcartobj->cartdetail_num;
    }else{
        $shopcart_arr['permit']='no';
    }
    $details['shopcart'] = $shopcart_arr;
}

//客户查重//editor:gyq_80 reason:微信客户查重改进 2018/9/6 18:10

if(isPermitted($currentModule,'accountdatadup')=='yes')
    $list_buttons[] = 'Datadupcheck';

//editor:gyq_89 reason:小程序有分录的模块暂隐藏新增按钮 2018/12/6 13:52
// @edit:dong @date:2020/07/27 @reason: 表单推广模块隐藏新增
if(judge_productdetail($currentModule) || $module =='SocialPromotion' || $module =='ExpenseBudget'){
    $list_buttons = array();
}

$details['list2'] = array(
    'viewname' => $_REQUEST['viewid'],
    'create_html'=>$list_buttons);
ConvertTojsonString(1, $details, 'success');

?>
