<?php
/*
edit:duan
time:2021-10-29
reason:移动端购物车的修改响应文件，
包括购物车记录的增加、删除、修改等功能
*/
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user,$currentModule;
$_REQUEST['diony']='diony';
$mode = $_REQUEST['mode'];
$focus = CRMEntity::getInstance($currentModule);
crm_load_class_file('Shopcart','modules/Products');
$shopcartobj = new Shopcart(); 

if($mode == 'add'){ //加入购物车
    $productid = $_REQUEST['productid'];
    $productdetail_lineitem_id = $_REQUEST['productdetail_lineitem_id'];
    //获取产品的默认属性 加入购物车
    $result = $shopcartobj->addtocart($productid,$productdetail_lineitem_id);
    $arr['cur_num'] = $shopcartobj->cartdetail_num;
    if($result==-1){
        $arr['confirmstr']=getFixedLabel("SHOPCARTFULL");
    }else{
        $arr['confirmstr']=getFixedLabel("SUCCESSADDCART");
    }
}else if($mode=='deletecart'){
    //删除购物车记录
    $cartid = $_REQUEST['cartid'];
    $shopcartobj->deletecart($cartid);
}else if($mode=='detail'){
    //删除购物车记录
    $productid = $_REQUEST['productid'];
    $arr = $shopcartobj->getProductDetail($productid);
    //增加翻译字符串
    $label_arr=array(
        'RECOMMENREASON',//推荐理由
        'COMMODITYDETAILS',//商品详情
        'SHOPCART',//购物车
        'ORDERIMMEDIATELY',//立即下单
        'ADDTOCART',//加入购物车
        'NOORDERPERMISSION',//当前没有下单权限
        'SUCCESSADDCART',//已添加购物车
    );
    $fixedlabel_arr = TransFieldlabel($label_arr,'no');
    global $MobileLanguageType;
    if($MobileLanguageType == 'en'){
        $fixedlabel_arr['COMMODITYDETAILS'] .= ':';
    }else{
        $fixedlabel_arr['COMMODITYDETAILS'] .= '：';
    }
    $arr['arrFixedLabel'] = $fixedlabel_arr;
}else if($mode=='mass_deletecart'){//批量删除购物车记录
    $cartid_str = $_REQUEST['cartid_str'];
    $shopcartobj->mass_deletecart("",$cartid_str);
}else if($mode == 'quantity_change'){ //修改购物车购买数量
    $cartid = $_REQUEST['cartid'];
    $quantity = $_REQUEST['quantity'];
    $shopcartobj ->quantity_change($cartid,$quantity);
	$salesordersys_value= getSys_deploy(349);
    //不知道为什么这个会传productid
	$productid = $_REQUEST['productid'];
	if(empty($productid)){
		$productid = $shopcartobj ->getProductForShopCart($cartid);
	}
	$price = $_REQUEST['price'];
	$focus = CRMEntity::getInstance('Products');
	$price = $focus->getShopProPrice($productid,$price,$quantity);
	$arr['price'] = $price;
}else if($mode == 'listview'){ //购物车显示页面
    $arr['QuantityDecimal']= $shopcartobj->QuantityDecimal;//数量小数位
    $arr['PriceDecimal'] = $shopcartobj->PriceDecimal;//单价小数位
    $arr['shopcart_listview'] = array_values($shopcartobj->ListView_shopcart($focus));//返回给移动端的数组应该是索引数组
    //增加翻译字符串
    $label_arr=array(
        'SHOPCART',//购物车
        'nodata',//没有数据
        'SUM',//合计
        'PLACEORDER',//下单
        'DELETE',//删除
        'CANCEL',//取消
        'SUREDELETERECORDS',//您确定要删除所选记录吗？
        'SELECTLEASTONEDATA',//请至少选择一条数据
        'NOORDERPERMISSION',//当前没有下单权限
    );
    $fixedlabel_arr = TransFieldlabel($label_arr,'no');
    global $MobileLanguageType;
    if($MobileLanguageType == 'en'){
        $fixedlabel_arr['SUM'] .= ':';
    }else{
        $fixedlabel_arr['SUM'] .= '：';
    }
    $arr['arrFixedLabel'] = $fixedlabel_arr;
}else if($mode == 'before_create'){//通过购物车新建合同订单之前，判断权限
    $tabid = getTabid($currentModule);
    $module_info=$shopcartobj->shopcart_button();
    $arr['permit_list'] = $module_info['permit'];
    $relation_arr = array();
    foreach($module_info['permit'] as $value){
        $related_tabid = getTabid($value);
        $sql = 'select relation_id from ld_relatedlists where tabid = ? and related_tabid = ?;';
        $result = $adb->pquery($sql,array($tabid,$related_tabid));
        $relation_id = $adb->query_result($result,0,'relation_id');
        $relation_arr[$value] = $relation_id;
    }
    $arr['relation_id'] = $relation_arr;
}else if($mode == 'saveCartProductProperty'){
    //zxm @date:2024/10/16 @reason: 购物车列表 产品属性更改
    $cartid = $_REQUEST['cartid'];
    $productdetail_lineitem_id = $_REQUEST['productdetail_lineitem_id'];
    $productid = $_REQUEST['productid'];
    $shopcartobj ->saveCartProductProperty($cartid,$productid,$productdetail_lineitem_id);
    $arr = [];
}
ConvertTojsonString(1,$arr,"success");
?>