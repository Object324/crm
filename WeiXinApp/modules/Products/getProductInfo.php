<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user, $currentModule;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
require_once(globalStatic::$root_directory . "modules/$currentModule/$currentModule.php");
require(globalStatic::$root_directory . 'user_privileges/user_privileges_' . $current_user->id . '.php');

require_once(globalStatic::$root_directory . 'include/utils/ListViewUtils.php');
require_once globalStatic::$root_directory . 'appCommon/include/piecesFunctionMC.php';

//@edit:liushuai,2021-03-18,reason:【ID1001451】产品管理单据查看详情界面，相关信息关联创建自动带出产品分录信息
function getProductInfo($return_module, $productid, $currencyid, $wareid, $row_id, $accountid)
{
    //当前模块、、币种ID、仓库ID（可不传）、行
    global $languageType;
    if(isset($_REQUEST['sourcemodulename'])){
        //收付款单选择产品传值使用。
        $_REQUEST['selectmodule'] = $_REQUEST['sourcemodulename'];
    }
    $productToolFields = setProductsInfo($return_module, $productid, $currencyid, $wareid, $row_id, 'app');
    //合同订单、报价单选择客户，如果客户有扣率则直接在产品明细中带出
    if(($return_module == 'SalesOrder' || $return_module == 'Quotes') && $accountid != '' && isset($productToolFields['discount_percent'])){
        //判断客户模块，产品扣率字段是否开启
        $focus_accounts = CRMEntity::getInstance('Accounts');
        $focus_accounts->retrieve_entity_info($accountid,'Accounts');
        $column_fields_accounts = $focus_accounts->column_fields;
        if(isset($column_fields_accounts['discount_rate'])){
            $productToolFields['discount_percent'] = $column_fields_accounts['discount_rate'];
        }
    }
    //合同订单中产品单价自动根据客户最近购买记录带出
    $deploy_values = getSys_deploy(79);
    if (($return_module == 'SalesOrder') && $deploy_values['deploy_value'] == 0 && !empty($accountid)) {
        crm_load_function_file('getPricesForProducts', 'include/utils', 'InventoryUtils');
        $entity = getAccountBuyProductsPirce($return_module, $productid, $accountid, $currencyid);
        if (!empty($entity))
            $productToolFields = array_merge($productToolFields, $entity);
    }
    $jsonArray['list'] = $productToolFields;

    //ls 2022/07/19 XUQIU1000474  当产品模块多图片字段时，分录引用产品图片属性，应根据字段区分显示(合同订单选产品带出图片字段信息时)
    crm_load_class_file('ProductToolFields','include/ProductDetails');
    $productToolFields = new ProductToolFields($return_module);
    //收付款单选择产品，获取字段信息需根据源单类型设置sql where条件
    if(($return_module == 'CashBill'||$return_module == 'SendCashBill')&&isset($_REQUEST['sourcemodulename'])){
        $productToolFields->setsourceModulesqlwhere($_REQUEST['sourcemodulename']);
    }
    $tabid = getTabid($return_module);
    $producttoolfieldInfo = $productToolFields->getModuleProductToolField($tabid, $languageType);
    foreach($producttoolfieldInfo as $columnname => $productfield){
        if($productfield->getUIType() == 69 && ($productfield->getTableName() == 'ld_products'||$productfield->getTableName() == 'ld_productcf') ){
            $jsonArray['list'][$columnname] = getProductImageArr($productid,$columnname);
        }
    }

    return $jsonArray;
}