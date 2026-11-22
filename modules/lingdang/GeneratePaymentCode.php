<?php
global $adb,$current_user,$weixin_user;
//XUQIU1001280 zxm 20230423 威奥轨道-小程序增加扫码付款功能
require_once  (globalStatic::$root_directory.'WeiXinApp/weixinPay/cls_WeiXinPay.php');
require_once  (globalStatic::$root_directory.'WeiXinApp/weixinPay/cls_getConfig.php');

//$notifyUrl = 'https://81mis.com/kfbcrm/modules/WorkSheet/zxmtest0419.php';
//$url= 'http://'.$_SERVER['SERVER_NAME'].':'.$_SERVER["SERVER_PORT"].$_SERVER["REQUEST_URI"];
$url= $_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['HTTP_HOST']. $_SERVER['PHP_SELF'];;
if($weixin_user->environment_weixin == true){
    $urlarr = explode('WeiXinApp',$url);
}else{
    $urlarr = explode('index.php',$url);
}

$notifyUrl = $urlarr[0].'WeiXinApp/weixinPay/navite_notify.php';
$getConfigObj = new cls_getConfig();
$configArr = $getConfigObj->getNativePaySetting();//商户号配置 获取的方法
$configPath = $getConfigObj->getNativePayKeyPath();//证书路径 获取的方法
if(!file_exists($configPath['merchantPrivateKeyFilePath'])||!file_exists($configPath['platformCertificateFilePath'])){
    ConvertTojsonString(-1,array(),'微信支付商户证书或者平台证书不存在');die;
}
$payObj = new cls_WeiXinPay($configArr,$configPath,$notifyUrl);
if($weixin_user->environment_weixin != true) {
    $smarty = new lingdangCRM_Smarty();
}
//获取单据信息
$frommodule = $_REQUEST['frommodule'];
$record = $_REQUEST['record'];
$createtype = $_REQUEST['createtype'];//是否重新创建二维码
$focus = CRMEntity::getInstance($frommodule);
$focus->id = $record;
$focus->retrieve_entity_info($record, $frommodule);
$fieldArr=$focus->column_fields;
$total = $fieldArr['hdnGrandTotal'];
//判断订单状态
if($fieldArr['payment_status']=='已支付'){
    ConvertTojsonString(-1,array(),getTranstab($frommodule).getFixedLabel('HavePaid'));die;
}
//判断参数
if(empty($configArr)){
    ConvertTojsonString(-1,array(),getFixedLabel('weixinpay_setting').getFixedLabel('Incompletefilling'));die;
}
if($total<=0){
    ConvertTojsonString(-1,array(),getFixedLabel('Nopaymentrequired'));die;
}
//ceshi
//$smarty->assign("frommodule",$frommodule);
//$smarty->assign("record",$record);
//$smarty->assign("code_url_expiredtime",date('Y-m-d H:i:s'));
//$smarty->assign("pathfilename",'storage/phpqrcode/22374161501.png?a=6097.60');
//$arr['content'] = $smarty->fetch('detailview/GeneratePaymentCode.tpl');
//$arr['title'] = getFixedLabel('GeneratePaymentCode');
//
//ConvertTojsonString(1, $arr, '成功！');
//return;



//判断数据库是否有未过期的url
$selectsql = "select * from ld_weixinpay_native 
         where code_url_requeststatus='200'
           and modulename=?
           and record=?
           and apptype=?
           and appid=?
           and mchid=?
           and code_url_expiredtime>? 
         order by code_url_createdtime desc limit 1 ;";
$selectres = $adb->pquery($selectsql,array(
    $frommodule,
    $record,
    $configArr['apptype'],
    $configArr['appid'],
    $configArr['merchantId'],
    date('Y-m-d H:i:s')
));

$selectnums =  $adb->num_rows($selectres);
$code_url = '';
$code_url_expiredtime = '';
if($selectnums>=1&&$createtype!='reGeneratePaymentCode'){
    $code_url = $adb->query_result($selectres,0,'code_url');
    $code_url_expiredtime = $adb->query_result($selectres,0,'code_url_expiredtime');
}else {
    //如果点击了重新生成收款码 需要把之前的收款二维码链接设置关闭订单
    if($selectnums>=1&&$createtype=='reGeneratePaymentCode'){
        $tmpout_trade_no = $adb->query_result($selectres,0,'out_trade_no');
        $payObj->closeNativePayCodeUrl($tmpout_trade_no);
    }
    //$description,$out_trade_no,$total 工单管理-工单编号:sh001
    $description = getTranstab($frommodule) . '-'.gettranslabelfields($frommodule,$focus->table_code).':' . $fieldArr['worksheet_no'];//商品描述--必填

    //商户系统内部订单号，只能是数字、大小写字母_-*且在同一个商户号下唯一,string[6,32]
    $out_trade_no = strtolower($frommodule) . $record . '_' . date('Ymd') . rand(100000, 999999);
    $attach = [
        'record' => $record,//单据id
        'moduleName' => $frommodule//来源模块名
    ];
    $attach = json_encode($attach);
    $res = $payObj->getNativePayCodeUrl($description, $out_trade_no, $total, $attach);
    if(isset($res['statusCode'])&&$res['statusCode']==200) {
        $data = $res['data'];
        $data = Zend_Json::decode($data);
        $code_url = $data['code_url'];
        $code_url_createdtime = date('Y-m-d H:i:s');
        $strtotime = time();
        $code_url_expiredtime = date('Y-m-d H:i:s',$strtotime+7200);
        //将数据insert到ld_entity_weixinpay表
        $insertsql = " insert into ld_weixinpay_native (modulename,
            record,
            total,
            currency,
            apptype,
            appid,
            mchid,
            description,
            out_trade_no,
            code_url,
            code_url_createdtime,
            code_url_expiredtime,
            code_url_requeststatus,
            userid)values(?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        $res = $adb->pquery($insertsql,array(
            $frommodule,
            $record,
            $total,
            'CNY',
            $configArr['apptype'],
            $configArr['appid'],
            $configArr['merchantId'],$description,$out_trade_no,$code_url,$code_url_createdtime,$code_url_expiredtime,$res['statusCode'],$current_user->id
        ));

    }else {
        ConvertTojsonString(-1, array(), $res['msg']);die;
    }
}

//将code_url转成二维码输出
$filename = strtolower($frommodule).$record;
$pathfilename = $payObj->getNativePayCode($code_url,$filename);
if($weixin_user->environment_weixin == true){
    //移动端代码
    ConvertTojsonString(1, ['pathfilename'=>$urlarr[0].$pathfilename.'?a='.rand(1000,9999),'code_url_expiredtime'=>$code_url_expiredtime], getFixedLabel('SUCCESS'));die;
}
$smarty->assign("pathfilename",$pathfilename.'?a='.rand(1000,9999));
$smarty->assign("frommodule",$frommodule);
$smarty->assign("record",$record);
$smarty->assign("code_url_expiredtime",$code_url_expiredtime);
//$smarty->assign("pathfilename",'storage/phpqrcode/22374161501.png?a=6097.60');
$arr['content'] = $smarty->fetch('DetailView/GeneratePaymentCode.tpl');
$arr['title'] = getFixedLabel('GeneratePaymentCode');

ConvertTojsonString(1, $arr, getFixedLabel('SUCCESS'));
