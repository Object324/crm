<?PHP
/*
edit:duan
time:2021-8-30
reason:购物车的显示响应文件，
包括购物车记录的显示、创建订单等功能
*/
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $currentModule;
//模块开启判断
if(!vtlib_isModuleActive($currentModule)){
    ConvertTojsonString(-1,[],getFixedLabel("NOPERMITTEDEXECUTE"));
}
$modulename_arr = array('SalesOrder','ServiceContracts');
$permit = 'no';
foreach($modulename_arr as $key=>$value){
    if(isPermitted($value,'Create')=='yes'){
        $permit =  'yes';
        break;
    }
}
//单据新建权限判断
if($permit == 'no'){
    ConvertTojsonString(-1,[],getFixedLabel("NOPERMITTEDEXECUTE"));
}
$_REQUEST['diony']='diony';
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();
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
//新建订单
if($_REQUEST['mode']!=""&&$_REQUEST['mode']=="create"){
    $num = sizeof($permit_arr);
    if($num==1){ //只有一个模块权限时直接新建
        $frommodule = $permit_arr[0];
        $arr['frommodule'] = $frommodule;
        ConvertTojsonString(1,$arr,"success");
    }else if($num > 1){ //两个以上权限时弹出选择框  
        $arr['title'] =getFixedLabel("CREATE").getFixedLabel("BIll");
        $arr['oktext']=getFixedLabel("SAVE");
        $arr['canceltext']=getFixedLabel("CANCEL");
        $arr['module_trans'] = $module_trans_arr;
        $arr['permit'] = $permit_arr;
        ConvertTojsonString(2,$arr,"success");
    }else{ //没有权限时返回提示
        if($module_presence=='yes'){
            $arr['confirmstr'] = getFixedLabel('NOPERMITTEDEXECUTE');
        }else{
            $arr['confirmstr'] = getFixedLabel('MODULEISNOTACTIVATED');
        }
        ConvertTojsonString(-1,$arr,"success");
    }
}else if($_REQUEST['mode']!=""&&$_REQUEST['mode']=="update"){ //新建订单完成后更新购物车信息 购物车新建合同按钮，如果模块未开启则不显示对应模块
    $nums = $_REQUEST['rowcnt'];
    if($nums>0){
        $productid_name = "hdnProductId";
        $productid_str = "";
        for($i=1;$i<=$nums;$i++){
            $tmp_productid = $_REQUEST[$productid_name.$i];
            if($productid_str==""){
                $productid_str = $tmp_productid;
            }else{
                $productid_str .= ','.$tmp_productid;
            }
        }
        $shopcartobj->mass_deletecart($productid_str,"");
    }
    ConvertTojsonString(1,[],"success");
}
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
$smarty->assign("FILEDLABEL",$filedlabels);
$smarty->assign("showProductProperty",$shopcartobj->vtlib_isModuleActive);
$smarty->assign("TDWIDTH",68/sizeof($filedlabels));
$smarty->assign("MODULEPERMIT",$permit_arr);
//zxm @date:2024/10/24 @reason: 购物车创建订单 报错VERSION_ACCOUNT undefined
$VersionInfo = getVersionInfo();
$smarty->assign('VERSION_ACCOUNT',$VersionInfo['account']);

$smarty->display('modules/Products/Listview_cart.tpl');
?>