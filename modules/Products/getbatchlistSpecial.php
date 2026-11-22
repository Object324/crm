<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//XUQIU20240719-03  ls 240723 【益弹新材料个性化开发】  自定义的批号字段(文本类型)
// 通过api查询金蝶云星空的数据之类的业务，都可以用这个文件
global $current_user,$weixin_user;
$_REQUEST['diony']='diony';

crm_load_class_file('cls_module_api_common','include/Module_Api');
$cls_module_api_common = new cls_module_api_common($_REQUEST['frommodule']);
$productInfo = $arr = [];
if ($cls_module_api_common->version_account == 'yitan' && $_REQUEST['frommodule']=='OutboundOrder') {
    $productid = trim($_REQUEST['productid']);
    $productInfo['productid'] = $productid;
    $cls_module_api_common->setProductInfo($productInfo);

    $tmparr = [];
    $api_data = $cls_module_api_common->getOriginalDataYitan();//返回接口源数据
    //$api_data = '[["XP24051001",1,"上海-TPS产品仓","PRO708"],["XP24051002",2,"浙江-报废仓","PRO708"],["XP24051003",3,"上海-TPEE产品仓","PRO708"]]';
    //接口报错会返回多层级的数组对象数据，接口没问题要么返回空数组，要么返回二维数组结果
    if (count($api_data) > 0 && $api_data[0][0]->Result->ResponseStatus->ErrorCode!='500') {
        crm_load_function_file('getWareInfoByName','include/Stock','CommonStock');

        foreach ($api_data as $item) {
            $wareinfo = getWareInfoByName($item[2]);//已确认，无需判断仓库权限
            $tmparr[] = [
                'sf3080' => $item[0],//批号 sf3080
                'quantity' => $item[1],
                'wareid' => $wareinfo['id'],
                'warehousename' => $item[2],
                'product_no' => $item[3],//物料编码
            ];
        }
    }


//    $arr['title']=getFixedLabel("SELECT").getFixedLabel('BATCH');
    $arr['title'] = "选择批号";
    if ($weixin_user->environment_weixin) {
        $arr['list'] = $tmparr;//移动端用
    }else{
        $smarty = new lingdangCRM_Smarty();

        $smarty->assign("TMPARR", $tmparr);//数组
        $content = $smarty->fetch("batchlistYitan.tpl");

        $arr['api_data'] = $api_data;
        $arr['content'] = $content;
    }

}

ConvertTojsonString(1,$arr,'success');

?>