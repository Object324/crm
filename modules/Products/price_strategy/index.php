<?php
//editor:gyq_84 reason:产品增加价格策略 2018/10/22 15:58
crm_load_class_file('ModelPriceS','modules/Products/price_strategy');
$Model = new ModelPriceS();
if(isset($_REQUEST['second_action'])){
    $se_action = $_REQUEST['second_action'];
    $Model->$se_action();
}
?>