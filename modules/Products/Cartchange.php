<?php
/*
edit:duan
time:2021-8-30
reason:购物车的修改响应文件，
包括购物车记录的增加、删除、修改等功能
*/

global $adb,$current_user;
$_REQUEST['diony']='diony';
$mode = $_REQUEST['mode'];
crm_load_class_file('Shopcart','modules/Products');
$shopcartobj = new Shopcart(); 

if($mode == 'add'){ //加入购物车
    $productid = $_REQUEST['record'];
    //zxm @date:2024/10/16 @reason: 增加产品属性
    $productdetail_lineitem_id = $_REQUEST['productdetail_lineitem_id'];
    $result = $shopcartobj->addtocart($productid,$productdetail_lineitem_id);
    $arr['cartdetail_num'] = $shopcartobj->cartdetail_num;
    if($result==-1){
        $arr['confirmstr']=getFixedLabel("SHOPCARTFULL");
    }else{
        $arr['confirmstr']=getFixedLabel("SUCCESSADDCART");
    }
}else if($mode == 'mass_add'){//批量加入购物车
    if($_REQUEST['selectid'] == 'all'){ //全部
        $id_list = getSelectedRecords($_REQUEST,$currentModule,$_REQUEST['selectid'],$_REQUEST['excludedRecords']); 
    }else{
        $select_ids = $_REQUEST['selectid'];
        $select_id = trim($select_ids,",");
        $id_list = explode(",",$select_id); 
    }
    $selectlen = $_REQUEST['selectlen'];
    $result = $shopcartobj->mass_addtocart($id_list,$selectlen);
    $arr['cartdetail_num'] = $shopcartobj->cartdetail_num;
    if($result==-1){
        $arr['confirmstr']=getFixedLabel("SHOPCARTFULL");
    }else{
        $arr['confirmstr']=getVarFixedLabel("SUCCESSMASSADDCART",$selectlen);
    }
//删除购物车记录
}else if($mode=='deletecart'){
    $cartid = $_REQUEST['cartid'];
    $shopcartobj->deletecart($cartid);
}else if($mode=='mass_deletecart'){//批量删除购物车记录
    $cartid_str = $_REQUEST['cartid_str'];
    $shopcartobj->mass_deletecart("",$cartid_str);
}else if($mode == 'quantity_change'){ //修改购物车购买数量
    $cartid = $_REQUEST['cartid'];
    $quantity = $_REQUEST['quantity'];
    $shopcartobj ->quantity_change($cartid,$quantity);
}else if($mode =='saveCartProductProperty'){
    $_REQUEST['diony']='diony';
    $focus = CRMEntity::getInstance('Products');
    $smarty = new lingdangCRM_Smarty();
    $modulename_arr = array('SalesOrder','ServiceContracts');
    $permit = 'no';
    foreach($modulename_arr as $key=>$value){
        if(isPermitted($value,'Create')=='yes'){
            $permit =  'yes';
            break;
        }
    }
    crm_load_class_file('Shopcart','modules/Products');
    $shopcartobj = new Shopcart();
    //暂时只能新建合同订单和服务合同
    foreach($modulename_arr as $key=>$value){
        if(vtlib_isModuleActive($value)){
            $module_presence = 'yes';
            if(isPermitted($value,'Create')=='yes'){
                $permit_arr[] = $value;
                $module_trans_arr[] = getTranstab($value);
            }
        }
    }

    //zxm @date:2024/10/16 @reason: 购物车列表 产品属性更改
    $cartid = $_REQUEST['cartid'];
    $productdetail_lineitem_id = $_REQUEST['productdetail_lineitem_id'];
    $productid = $_REQUEST['productid'];
    $shopcartobj ->saveCartProductProperty($cartid,$productid,$productdetail_lineitem_id);
    $arr = [];
    //设置小数位
    $system_deploy_49 = getSys_deploy(49);
    $QuantityDecimal = $system_deploy_49['deploy_value'];//数量小数位
    $system_deploy_93 = getSys_deploy(93);
    $PriceDecimal = $system_deploy_93['deploy_value'];//单价小数位
    $smarty->assign("QUANTITYDECIMAL",$QuantityDecimal);
    $smarty->assign("PRICEDECIMAL",$PriceDecimal);
    //购物车列表页内容
    $listview_entries = $shopcartobj->ListView_shopcart($focus);
    $smarty->assign("listview_entries",$listview_entries);
    //产品模块相关字段翻译
    $filedlabels = $shopcartobj->get_fieldlabel($focus);
    $smarty->assign("showProductProperty",$shopcartobj->vtlib_isModuleActive);
    $smarty->assign("FILEDLABEL",$filedlabels);
    $smarty->assign("TDWIDTH",68/sizeof($filedlabels));
    $smarty->assign("MODULEPERMIT",$permit_arr);

    $arr['content'] = $smarty->fetch('modules/Products/Listview_cart_content.tpl');
}
ConvertTojsonString(1,$arr,"success");
?>