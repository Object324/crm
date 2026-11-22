<?php


class LdMall
{
    //发版    小程序
    const LINGDANG = "灵当商城";//默认情况下  小程序首页的title
    const KEFUTEL = "400-888-5110";//默认情况下  客服电话
    const PAYMETHODWEIXIN = "微信支付";//定义微信支付的值
    const PAYMETHODBALANCE = "余额支付";//定义余额支付的值
    public $configArr;
    public $phoneArr;
    public $configPath;
    public $corpurl;
    public $defaultProductImage = 'themes/ldmallimg/goods/default_cartimg.png';//商品默认图
    public $adb;
    public $kuaidi100_conf;
    public $orderStatusArr = [
        '已取消'=>['name'=>'cancel','label'=>'已取消','nums'=>0,'image'=>'themes/ldmallimg/icon/cancel.png'],
        '待付款'=>['name'=>'toCash','label'=>'待付款','nums'=>0,'image'=>'themes/ldmallimg/icon/toCash.png'],
        '待发货'=>['name'=>'toDeliver','label'=>'待发货','nums'=>0,'image'=>'themes/ldmallimg/icon/toDeliver.png'],
        '待收货'=>['name'=>'toGet','label'=>'待收货','nums'=>0,'image'=>'themes/ldmallimg/icon/toGet.png'],
        '售后'=>['name'=>'afterSale','label'=>'售后','nums'=>0,'image'=>'themes/ldmallimg/icon/afterSale.png']
    ];
    //字符串显示字段 --目前只把产品编号字段放进来--做联科生物的需求  他们要求不显示product_no,显示productcode
    public $showProductNoField = 'product_no';
    public $showAtt  = 'no';//创建订单页 订单详情页 是否显示附件信息
    public $tradeInfo  = '';
    public function __construct(){
        global $adb,$corpurl;
        $this->corpurl = $corpurl;
        $this->defaultProductImage = $corpurl.$this->defaultProductImage;
        foreach($this->orderStatusArr as $k=>$v){
            $this->orderStatusArr[$k]['image'] = $corpurl.$this->orderStatusArr[$k]['image'];
        }
        $this->adb = $adb;
        //商户证书路径  平台证书路径
        $this->configPath = array(
            'merchantPrivateKeyFilePath'=>'file://' . globalStatic::$root_directory . 'WeiXinApp/ldmall/WXCertUtil/cert/apiclient_key.pem',// 注意 `file://` 开头协议不能少
            'platformCertificateFilePath'=>'file://' . globalStatic::$root_directory . 'WeiXinApp/ldmall/WXCertUtil/cert/cert.pem'// 注意 `file://` 开头协议不能少
        );
        require_once  (globalStatic::$root_directory.'WeiXinApp/weixinPay/cls_getConfig.php');
        $getConfigObj = new cls_getConfig();
        $this->configArr = $getConfigObj->getShopSetting();
        $this->phoneArr = $getConfigObj->getShopPhone();  //新增一个phoneArr，相对于configArr的默认情况，可以获取所有客服电话
        $tradeInfo = getVersionTradeInfo();
        $this->tradeInfo = $tradeInfo;
        if($tradeInfo['account']=='dzj1101' || $tradeInfo['account']=='liankeshengwu'){
            $this->showAtt = 'yes';
        }
        //字符串显示字段 --目前只把产品编号字段放进来--做联科生物的需求  他们要求不显示product_no,显示productcode
        if($tradeInfo['account']=='liankeshengwu'){
            $this->showProductNoField = 'productcode';
        }
        if(file_exists(globalStatic::$root_directory.'user_privileges/KuaiDi100.inc.php')) {
            global $conf;
            require_once(globalStatic::$root_directory.'user_privileges/KuaiDi100.inc.php');
            $this->kuaidi100_conf = $conf;
        }
    }

    public function getAccessToken()
    {
        $appid = $this->configArr['appid'];
        $appsecret = $this->configArr['appsecret'];
        $projectname = 'ldmall';

        $access_token_offiaccount = file_get_contents(globalStatic::$root_directory.'storage/accesstoken/'.$projectname.'_'.$appid.'.txt');
        $access_token_offiaccount = json_decode($access_token_offiaccount,true);
        if(!empty($access_token_offiaccount['access_token'])&&(time()<($access_token_offiaccount['create_time']+3600))){
            $token = $access_token_offiaccount['access_token'];
        }else{
            $url = "https://api.weixin.qq.com/cgi-bin/token?appid=".$appid."&grant_type=client_credential&secret=".$appsecret;
            $jsonwx = json_decode($this->curlGet($url));
            // 存储session以及过期时间
            $access_token_offiaccount['access_token'] = $jsonwx->access_token;
            $access_token_offiaccount['expires_in'] = $jsonwx->expires_in;
            $access_token_offiaccount['create_time'] = time();
            $access_token_offiaccount = json_encode($access_token_offiaccount);
            if(!is_dir(globalStatic::$root_directory.'storage/accesstoken')){
                mkdir(globalStatic::$root_directory.'storage/accesstoken',0777);
            }
            file_put_contents(globalStatic::$root_directory.'storage/accesstoken/'.$projectname.'_'.$appid.'.txt',$access_token_offiaccount);
            $token = $jsonwx->access_token;
        }
        return $token;
    }
    /**
     * @param $url
     * @return bool|string
     * curl get方法
     */
    public function curlGet($url)
    {
        //初始化
        $ch = curl_init();

        curl_setopt($ch, CURLOPT_URL,$url);
        // 执行后不直接打印出来
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HEADER, false);
        // 跳过证书检查
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        // 不从证书中检查SSL加密算法是否存在
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);

        //执行并获取HTML文档内容
        $output = curl_exec($ch);

        //释放curl句柄
        curl_close($ch);

        return $output;
    }

    /**
     * @param $url
     * @param array $data
     * @return bool|string
     * curl post方法
     */
    public function curlPost($url , $data=array()){

        $ch = curl_init();

        curl_setopt($ch, CURLOPT_URL, $url);

        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);

        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);

        // POST数据

        curl_setopt($ch, CURLOPT_POST, 1);

        // 把post的变量加上

        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);

        $output = curl_exec($ch);

        curl_close($ch);

        return $output;

    }

    //获取账户信息
    public function getAccountInfo($open_id){
        $accountInfo = [
            'logoimg'=>$this->corpurl.'themes/ldmallimg/logo/logo.png',
            'balance_amount'=>0,//用来计算的数字
            'balanceAmountShow'=>0,//格式化的 用来显示的
            'accountname'=>'',
            'imagename'=>'',
            'lastname'=>'',
            'accountid'=>0,
            'open_id'=>$open_id,
            'session_key' => $_REQUEST['session_key'],
            'unionid'=>'',
            'mobile'=>'',
            'hidemobile'=>'',
            'wxuserid'=>0,
        ];
        if(!empty($open_id)) {
            $select_query = 'select 
        ifnull(b.balance_amount,0)as balance_amount,ifnull(b.accountname,"")as accountname,b.deleted,a.*
        from ld_wechatuser a left join ld_account b on a.accountid=b.accountid  
        where open_id=? and a.deleted=0 ';
            $select_result = $this->adb->pquery($select_query, array($open_id));
            $select_rows = $this->adb->num_rows($select_result);
            if ($select_rows > 0) {
                $deleted = $this->adb->query_result($select_result, 0, 'deleted');
                $accountInfo['balance_amount'] = 0;
                $accountInfo['accountname'] = '';
                if ($deleted == 0) {
                    $accountInfo['balance_amount'] = $this->adb->query_result($select_result, 0, 'balance_amount');//公司余额
                    $accountInfo['balance_amount'] = empty($accountInfo['balance_amount']) ? 0 : round($accountInfo['balance_amount'],2);
                    $accountInfo['balanceAmountShow'] = number_format($accountInfo['balance_amount'], 2);//保留2位小数
                    $accountInfo['accountname'] = $this->adb->query_result($select_result, 0, 'accountname');//公司名字
                }
                $accountInfo['imagename'] = $this->adb->query_result($select_result, 0, 'imagename');//$avatarurl;//微信头像
                $accountInfo['lastname'] = $this->adb->query_result($select_result, 0, 'lastname');//姓名
                $accountInfo['accountid'] = $this->adb->query_result($select_result, 0, 'accountid');
                $accountInfo['open_id'] = $this->adb->query_result($select_result, 0, 'open_id');;
                $accountInfo['unionid'] = $this->adb->query_result($select_result, 0, 'unionid');
                $accountInfo['mobile'] = $this->adb->query_result($select_result, 0, 'mobile');
                //电话中间四位隐藏
                if(!empty($accountInfo['mobile'])){
                    $accountInfo['hidemobile'] = substr_replace($accountInfo['mobile'],'****',3,4);
                }
                $accountInfo['wxuserid'] = $this->adb->query_result($select_result, 0, 'wechatuserid');
            }
        }
        return $accountInfo;
    }

    /**
     * @param $phone
     * @return string|string[]|null
     * 电话号码 隐藏中间4位为****
     */
    public function hidtel($phone){
        $IsWhat = preg_match('/(0[0-9]{2,3}[\-]?[2-9][0-9]{6,7}[\-]?[0-9]?)/i',$phone); //固定电话
        if($IsWhat == 1){
            return preg_replace('/(0[0-9]{2,3}[\-]?[2-9])[0-9]{3,4}([0-9]{3}[\-]?[0-9]?)/i','$1****$2',$phone);
        }else{
            return  preg_replace('/(1[358]{1}[0-9])[0-9]{4}([0-9]{4})/i','$1****$2',$phone);
        }
    }
    //订单状态
    public function getOrderStatus($statusId=null){

        $arr = [
            'cancel'=>'已取消',
            'toCash'=>'待付款',
            'toDeliver'=>'待发货',
            'toGet'=>'待收货',
            //'evaluate'=>'评价',
            'afterSale'=>'售后'
        ];
        if(empty($statusId)){
            return $arr;
        }
        if(!isset($arr[$statusId])){
            return '';
        }
        return $arr[$statusId];
    }
    //订单按钮
    public function getOrderBtns($status,$express_no){
        $accountInfo = $this->getAccountInfo($_REQUEST['open_id']);
        if($status=="已取消"){
            $arr = array(
                ['name'=>'delete', 'label'=>'删除订单', 'color'=>'#ff6600', 'bordercolor'=>'#ff6600']
            );
        }else if($status=="待付款"){
            $arr = array(
                ['name'=>'cancel', 'label'=>'取消订单', 'color'=>'#ff6600', 'bordercolor'=>'#ff6600'],
                ['name'=>'weixinpay', 'label'=>'微信支付', 'color'=>'#ff6600', 'bordercolor'=>'#ff6600']
            );
            if($accountInfo['balance_amount']>0){
                $arr[] = ['name'=>'balancePay', 'label'=>'余额支付', 'color'=>'#ff6600', 'bordercolor'=>'#ff6600'];
            }
        }else if($status=="待发货"){
            $arr = array(
                ['name'=>'confirm', 'label'=>'确认收货', 'color'=>'#ff6600', 'bordercolor'=>'#ff6600']
            );
        }else if($status=="待收货"){
            $arr = array(
                ['name'=>'confirm', 'label'=>'确认收货', 'color'=>'#ff6600', 'bordercolor'=>'#ff6600']
            );
            $conf = $this->kuaidi100_conf;
            if(!empty($conf)&&!empty($conf['url']) && !empty($conf['key']) && !empty($conf['customer'])&&!empty($express_no)){
                $focus = CRMEntity::getInstance('SalesOrder');
                $fieldobj = $focus->fieldobj->getFieldInfoobjBykey_arr("bigtype",'express');
                if($fieldobj){
                    $arr[] = ['name'=>'wuliu', 'label'=>'查看物流', 'color'=>'#666', 'bordercolor'=>'#999'];
                }
            }
        }else if($status=="售后"){
            $arr = array(
                ['name'=>'delete', 'label'=>'删除订单', 'color'=>'#ff6600', 'bordercolor'=>'#ff6600']
            );
            $conf = $this->kuaidi100_conf;
            if(!empty($conf)&&!empty($conf['url']) && !empty($conf['key']) && !empty($conf['customer'])&&!empty($express_no)){
                $focus = CRMEntity::getInstance('SalesOrder');
                $fieldobj = $focus->fieldobj->getFieldInfoobjBykey_arr("bigtype",'express');
                if($fieldobj){
                    $arr[] = ['name'=>'wuliu', 'label'=>'查看物流', 'color'=>'#666', 'bordercolor'=>'#999'];
                }
            }
        }else{
            $arr = array(
                ['name'=>'delete', 'label'=>'删除订单', 'color'=>'#ff6600', 'bordercolor'=>'#ff6600']
            );
        }
        return $arr;
    }

    /**
     * @param $price
     * @return false|string[]
     * 格式化价格字段--变成数组
     * 将显示的价格切割成数组  因为要整数位和小数位显示不一样的大小
     */
    public function formatPrice($price){
        $price_str = number_format($price, 2, '.', '');
        $price_arr = explode('.',$price_str);
        $price_arr[0] = $price_arr[0].'.';
        return $price_arr;
    }


    /**
     * @param $paymethod
     * @throws Exception
     * 增加付款方式下拉框  增加一个【微信支付 】
     * 商城小程序创建收款单的时候，判断下拉框值有没有微信支付，如果没有则新增一个下拉框值；
     * 直接调用即可
     */
    public function addPaymentmethod($paymethod){

        $select_sql = "select listid from ld_picklist_set 
where ld_picklist_set.listname='paymentmethod'";
        $select_res = $this->adb->pquery($select_sql);
        $listid = $this->adb->query_result($select_res,0,0);

        $weixin_exist_sql = " select 1 from ld_picklist_values where listid=? and listvalue=? ";
        $weixin_exist_res = $this->adb->pquery($weixin_exist_sql,array($listid,$paymethod));
        $weixin_exist_nums = $this->adb->num_rows($weixin_exist_res);

        if($weixin_exist_nums<=0){
            $sequence_sql = "select max(`sequence`) as maxsequence from ld_picklist_values where listid=? ";
            $sequence_res = $this->adb->pquery($sequence_sql,array($listid));
            $sequence = $this->adb->query_result($sequence_res,0,0);
            $sequence = $sequence+1;

            $insert_sql = "INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT $listid,'$paymethod',$sequence FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid =@listid AND listvalue ='$paymethod')";
            $this->adb->pquery($insert_sql);

        }
    }
}