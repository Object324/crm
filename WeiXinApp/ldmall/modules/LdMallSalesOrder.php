<?php
class LdMallSalesOrder extends LdMall
{
    /**
     * 创建订单
     */
    public function create(){
        global $current_user;
        $current_user->id =1;//先写1 后面再改
        $current_user->is_admin ="on";
        $orderFocus = CRMEntity::getInstance('SalesOrder');
        //结算类型 购物车结算cart  直接结算direct
        $type = $_REQUEST['previewOrderType'];
        $type = empty($type)?'cart':$type;
        $accountid = $_REQUEST['accountid'];//客户ID
        $wxuserid = $_REQUEST['wxuserid'];//客户ID
        $_REQUEST['account_id'] = $accountid;
        $contactid = $_REQUEST['contactid'];//联系人（地址）id
        $_REQUEST['contact_id'] = $contactid;
        $orderFocus->column_fields['signed_data'] = date('Y-m-d');
        $orderFocus->column_fields['duedate'] = date('Y-m-d');
        $_REQUEST['duedate'] = date('Y-m-d');

        //获取地址详情
        $contact_sql = "select lastname,mobile,mailingcountry,mailingstate,mailingcity,mailingarea,mailingstreet,smownerid from ld_contactdetails where contactid=?";
        $contact_res = $this->adb->pquery($contact_sql,array($contactid));
        $contact_nums = $this->adb->num_rows($contact_res);

        $mailingstate = $this->adb->query_result($contact_res,0,'mailingstate');
        $mailingcity = $this->adb->query_result($contact_res,0,'mailingcity');
        $mailingarea = $this->adb->query_result($contact_res,0,'mailingarea');
        $mailingstreet = $this->adb->query_result($contact_res,0,'mailingstreet');
        $address = $mailingstate.$mailingcity.$mailingarea.$mailingstreet;
        $lastname = $this->adb->query_result($contact_res,0,'lastname');
        $mobile = $this->adb->query_result($contact_res,0,'mobile');
        $smownerid = $this->adb->query_result($contact_res,0,'smownerid');
        $_REQUEST['assigned_user_id'] = $smownerid;//订单负责人改成联系人负责人

        $_REQUEST['order_status'] = "待付款";
        $_REQUEST['mode'] = "create";
        $_REQUEST['sostatus'] = "已创建";
        // 联科生物特殊开发
        $tradeInfo = getVersionTradeInfo();
        if($tradeInfo['account']=='liankeshengwu'){
            $_REQUEST['cf_2291'] = '销售';
            $_REQUEST['cf_5357'] = '0';
        }
        //发票信息保存
        if(!empty($_REQUEST['wx_invoiceInfo'])) {
            $wx_invoiceInfo = json_decode($_REQUEST['wx_invoiceInfo'], true);
            $_REQUEST['companyname'] = $wx_invoiceInfo['title'];
            $_REQUEST['taxnumber'] = $wx_invoiceInfo['taxNumber'];
            $_REQUEST['companyaddress'] = $wx_invoiceInfo['companyAddress'];
            $_REQUEST['telephone'] = $wx_invoiceInfo['telephone'];
            $_REQUEST['bankname'] = $wx_invoiceInfo['bankName'];
            $_REQUEST['bankaccount'] = $wx_invoiceInfo['bankAccount'];
        }
        $wechatPayDescription = '';
        if($type=="direct") {
            //只有一个商品 产品ID  数量  起止日期sf2662,sf2870,使用天数sf1830
            $productid = $_REQUEST['productid'];
            //查询产品信息
            $product_sql = "select ld_products.productname ,ld_products.unit_price from ld_products left join ld_productcf 
            on ld_products.productid=ld_productcf.productid where ld_products.productid=?";
            $product_res = $this->adb->pquery($product_sql,array($productid));
            $product_nums = $this->adb->num_rows($product_res);
            $unit_price = $this->adb->query_result($product_res,0,'unit_price');
            $wechatPayDescription = $this->adb->query_result($product_res,0,'productname');

            $quantity = $_REQUEST['quantity'];
            $_REQUEST['hdnProductId1'] = $productid;
            $_REQUEST['quantity1'] = $quantity;
            $_REQUEST['unit_price1'] = $unit_price;//续租价格
            $tax_amount = $quantity*$unit_price;
            $_REQUEST['tax_amount1'] = $tax_amount;//租赁费/技术服务费合计
            $_REQUEST['total'] = $tax_amount;//合计
            $_REQUEST['rowcnt'] = 1;
            $_REQUEST['subtotal'] = $tax_amount;//小计
            $_REQUEST['discount_amount'] = 0;//折扣额
        }else{
            //租赁 productid商品ID,quantity数量,start_date开始日期,end_date结束日期
            //购物车ID 数据库直接查出来
            $cartid = $_REQUEST['cartid'];
            $cartid = trim($cartid,',');
            $cart_sql = "select 
            ld_shopcartdetails.cartid,
            ld_shopcartdetails.productid,
            ld_shopcartdetails.quantity,
            ld_products.unit_price as price,
            ld_products.qtyinstock as goodsstock,
            ld_products.productname as productname
            from ld_shopcartdetails
            left join ld_products on ld_shopcartdetails.productid=ld_products.productid
            left join ld_productcf on ld_products.productid=ld_productcf.productid
            where relatedmodule='WeChatUser' and relatedid=? and ld_shopcartdetails.cartid in ($cartid) ";
            $cart_res = $this->adb->pquery($cart_sql,array($wxuserid));
            $cart_nums = $this->adb->num_rows($cart_res);
            $total = 0;//总计
            //分录字段 -- todo--
            if($cart_nums>0){
                for($i=0;$i<$cart_nums;$i++){
                    $key = $i+1;
                    $productid = $this->adb->query_result($cart_res,$i,'productid');
                    $quantity = $this->adb->query_result($cart_res,$i,'quantity');
                    $price = $this->adb->query_result($cart_res,$i,'price');
                    $productname = $this->adb->query_result($cart_res,$i,'productname');
                    $wechatPayDescription .= $productname.',';
                    $_REQUEST['hdnProductId'.$key] = $productid;
                    $_REQUEST['quantity'.$key] = $quantity;
                    $_REQUEST['unit_price'.$key] = $price;//续租价格
                    $tax_amount = $quantity*$price;
                    $_REQUEST['tax_amount'.$key] = $tax_amount;//租赁费/技术服务费合计
                    $total += $tax_amount;
                }
            }else{
                return array(1,['id'=>$cartid],'购物车商品已被清除！');
            }

            $_REQUEST['total'] = $total;//合计
            $_REQUEST['rowcnt'] = $cart_nums;//合计行数
            $_REQUEST['subtotal'] = $total;//小计
            $_REQUEST['discount_amount'] = 0;//折扣额
        }
        if($this->tradeInfo['account']=='liankeshengwu'){
            //联科生物不要微信支付  这个描述字段的值没有填写应该为空
            $_REQUEST['description'] = empty($_REQUEST['description'])?'':$_REQUEST['description'];
        }else{
            //其他客户要微信支付的话 这个字段值必须不为空
            $_REQUEST['description'] = empty($_REQUEST['description'])?$wechatPayDescription:$_REQUEST['description'];
        }

        setObjectValuesFromRequest($orderFocus);
        $orderFocus->getBefore_SumDetailValues();//获取保存前明细字段的合计

        //zxm 20230131 附件字段保存
        if(!empty($_REQUEST['wx_fieldInfo'])) {
            $wx_fieldInfo = json_decode($_REQUEST['wx_fieldInfo']);
            $fieldobj = Field::getInstance('SalesOrder', $this->adb);
            $moduleFields = $fieldobj->getModuleFields();
            foreach ($wx_fieldInfo as $key => $val) {
                $field = $moduleFields[$key];
                //editor:gyq_113 reason:新增知识管理模块  2019/5/23 15:18
                //由于知识管理模块的附件uitype是特殊值28，故新增$field->uitype==28
                if ($field->uitype == 69 || $field->uitype == 1109 || $field->uitype == 1108 || $field->uitype == 28) {
                    foreach ($val as $k => $v) {
                        $_REQUEST[$k] = $v;
                    }
                    unset($_REQUEST[$key]);
                }
            }
        }

        //主表需要存储的字段 salesorder_no,contactid,duedate,total,subtotal,accountid,signed_data,smownerid,smcreatorid,createdtime,modifiedtime,
        $orderFocus->save("SalesOrder");
        $_REQUEST['salesorderid'] = $orderFocus->id;//订单ID
        $_REQUEST['salesorder_no'] = $orderFocus->salesorder_no;//订单编号
        //BUG0053188	2022-06-27	zxm https://www.51mis.com/hy/dzj1101/）合同订单的订单来源未自动识别商城小程序
        $this->adb->pquery("update ld_salesorder set order_source = ? where salesorderid = ?",array('商城小程序',$orderFocus->id));
        //更新收货人 收货地址 收货电话字段
        $update_sql = " update ld_salesorder set appreceivername=?,appreceivermobile=?,appreceiveradress=? where salesorderid=? ";
        $this->adb->pquery($update_sql,array($lastname,$mobile,$address,$orderFocus->id));
        //付款
        $payMethod = $_REQUEST['payMethod'];//付款方式-余额支付
        if($payMethod=="balancePay"){
            $cashRes = $this->balancePay();
            $update_order_status = "待发货";
        }else{
            //好友代付
            //微信支付
            $cashRes = array(1, ['id'=>$orderFocus->id], 'success');
            $update_order_status = "待付款";
        }
        if($cashRes[0]==1){
            //更新订单状态
            $update_sql = " update ld_salesorder set order_status='$update_order_status' where salesorderid=?";
            $update_res = $this->adb->pquery($update_sql, array($orderFocus->id));

            //删除购物车
            if($type!="direct") {
                $cartid = $_REQUEST['cartid'];
                $cartid = trim($cartid,',');
                $delete_sql = " delete from ld_shopcartdetails where cartid in ($cartid)";
                $delete_res = $this->adb->pquery($delete_sql,array());
            }
        }
        //return array(1,['id'=>$orderFocus->id],'success');
        return $cashRes;
    }

    public function orderCash(){
        //订单金额
        $salesorderid = $_REQUEST['salesorderid'];
        $salesorder_sql = "select order_status,total,subtotal,salesorder_no,description from ld_salesorder where salesorderid=? and deleted=0";
        $salesorder_res = $this->adb->pquery($salesorder_sql,array($salesorderid));
        $salesorder_nums = $this->adb->num_rows($salesorder_res);
        if($salesorder_nums<=0){
            return array(-1,['id'=>$salesorderid],'订单不存在或已被删除！');
        }
        $order_status = $this->adb->query_result($salesorder_res,0,'order_status');
        if($order_status!='待付款'){
            return array(-1,['id'=>$salesorderid],'该订单已付款！');
        }
        $_REQUEST['total'] = $this->adb->query_result($salesorder_res,0,'total');
        $_REQUEST['subtotal'] = $this->adb->query_result($salesorder_res,0,'subtotal');
        $_REQUEST['salesorder_no'] = $this->adb->query_result($salesorder_res,0,'salesorder_no');
        $_REQUEST['description'] = $this->adb->query_result($salesorder_res,0,'description');
        $_REQUEST['description'] = empty($_REQUEST['description'])?"商品购买":mb_substr($_REQUEST['description'],0,8).'等商品';

        if($_REQUEST['total']<=0){
            $update_sql = " update ld_salesorder set order_status='待发货' where salesorderid=?";
            $update_res = $this->adb->pquery($update_sql, array($salesorderid));
            $cashRes = array(2,[],'订单无需支付');
            return $cashRes;
        }
        //付款
        $payMethod = $_REQUEST['payMethod'];//付款方式-余额支付
        if($payMethod=="balancePay"){
            $paymethod_balance = self::PAYMETHODBALANCE;
            $this->addPaymentmethod($paymethod_balance);
            $cashRes = $this->balancePay();
            if($cashRes[0]>=1) {
                //更新订单状态
                $update_sql = " update ld_salesorder set order_status='待发货' where salesorderid=?";
                $update_res = $this->adb->pquery($update_sql, array($salesorderid));
            }
        }else if($payMethod=="weixinPay"){
            //好友代付
            //微信支付
            //判断是否存在微信支付证书
            if(!file_exists(globalStatic::$root_directory . 'WeiXinApp/ldmall/WXCertUtil/cert/apiclient_key.pem')){
                return array(2,[],'订单无需支付');
            }
            $paymethod_weixin = self::PAYMETHODWEIXIN;
            $this->addPaymentmethod($paymethod_weixin);
            if($_REQUEST['total']>0){
                $cashRes = $this->weixinPay();
            }else{
                //小于等于0的订单无需支付
                //更新订单状态
                $update_sql = " update ld_salesorder set order_status='待发货' where salesorderid=?";
                $update_res = $this->adb->pquery($update_sql, array($salesorderid));
                $cashRes = array(2,[],'订单无需支付');
            }
        }else if($payMethod=="combinationPay"){
            //组合支付 --先扣余额  再调用微信支付  创建两个收款单 一个余额支付收款单  一个微信支付
            $cashRes = $this->combinationPay();
        }
        return $cashRes;
    }
    /**
     * 余额支付
     * 1.查询预售单
     * 2.创建收款单
     * 3.预售单的余额减去相应金额
     * 4.客户余额字段值减去订单金额
     */
    public function balancePay(){
        $salesorderid = $_REQUEST['salesorderid'];
        $salesorder_total = $_REQUEST['total'];//订单总金额
        //查询余额
        $accountInfo = $this->getAccountInfo($_REQUEST['open_id']);
        if($salesorder_total>$accountInfo['balance_amount']){
            return [-1,[],'余额不足！'];
        }
        //如果余额 小于
        //1.查询预收单  先进先出
        $debuction_sql = "select debuctionbalanceamount,cashbillid from ld_cashbill where accountid=? and deleted=0 and debuctionbalanceamount>0 order by cashbillid asc";
        $debuction_res = $this->adb->pquery($debuction_sql,array($_REQUEST['accountid']));
        $debuction_nums = $this->adb->num_rows($debuction_res);
        if($debuction_nums<=0&&$salesorder_total>0){
            return [-1,[],'没有对应预收单，请重新查询余额！'];
        }
        $debuctionList = [];
        $save_debuctioninfo = [];
        for($i=0;$i<$debuction_nums;$i++){
            $temp_debuctionbalanceamount = $this->adb->query_result($debuction_res,$i,'debuctionbalanceamount');
            $temp_cashbillid = $this->adb->query_result($debuction_res,$i,'cashbillid');
            $debuctionList[$i]['debuctionbalanceamount'] = $temp_debuctionbalanceamount;
            $debuctionList[$i]['cashbillid'] = $temp_cashbillid;
            $save_debuctioninfo[$i]['type'] = 'new';
            $save_debuctioninfo[$i]['debuctionid'] = $temp_cashbillid;

            //{"type":"new","amount":"2840.00","debuctionid":"869"}
            if($salesorder_total<=$temp_debuctionbalanceamount){
                //如果金额正好抵消或者还有余额 则不需要进行下一次循环了 跳出循环
                $save_debuctioninfo[$i]['amount'] = $salesorder_total;
                break;
            }else{
                $save_debuctioninfo[$i]['amount'] = $temp_debuctionbalanceamount;
                //如果金额大于余额 下一次循环
                $salesorder_total = $salesorder_total-$temp_debuctionbalanceamount;
            }
        }
        if(!empty($save_debuctioninfo)){
            $_REQUEST['save_debuctioninfo'] = json_encode($save_debuctioninfo);
        }
        $_REQUEST['mode'] = "create";
        $_REQUEST['Create'] = "yes";
        //2.创建收款单
        //accountid  salesorderid  cashbilldate  paymentmethod  Total  subtotal
        //bankaccountsetid   smownerid   smcreatorid   chreatedtime modifiedtime description
        $_REQUEST['account_id'] = $_REQUEST['accountid'];
        $_REQUEST['selectsourcename'] = 'SalesOrder';
        $_REQUEST['cashtype'] = 'cashbill';
        $_REQUEST['assigned_user_id'] = 1;
        $_REQUEST['paymentmethod'] = self::PAYMETHODBALANCE;
        $_REQUEST['cashbilldate'] = date('Y-m-d');
        $_REQUEST['selectlistval'] = $_REQUEST['salesorderid'];
        $_REQUEST['bankaccountsetid'] = 1;
        $_REQUEST['description'] = "微信订单".self::PAYMETHODBALANCE;
        $_REQUEST['rowcnt'] = 1;
        $_REQUEST['entitytypeid1'] = $_REQUEST['salesorderid'];

        $_REQUEST['amount1'] = $_REQUEST['total'];
        $_REQUEST['cashbill_total'] = 0;
        $cashbillObj = CRMEntity::getInstance('CashBill');
        setObjectValuesFromRequest($cashbillObj);
        $cashbillObj->getBefore_SumDetailValues();
        $cashbillObj->save('CashBill');
        //3.预售单的余额减去相应金额  debuctionbalanceamount -订单金额
        //4.客户余额字段值减去订单金额
        $balance_amount = $accountInfo['balance_amount'] - $_REQUEST['total'];
        $account_sql = "update ld_account set balance_amount=? where accountid=?";
        $this->adb->pquery($account_sql,array($balance_amount,$_REQUEST['accountid']));
        return array(1, ['id'=>$salesorderid], 'success');
    }

    /**
     * @return array
     * 订单使用微信支付
     */
    public function weixinPay(){
        $open_id = $_REQUEST['open_id'] ;
        $accountid = $_REQUEST['accountid'] ;
        $configPath = $this->configPath;
        $configArr = $this->configArr;//小程序配置 商户号配置
        //$notifyUrl = $this->corpurl . 'WeiXinApp/ldmall/notify.php';
        global $ldcrm_name;
        $notifyUrl = 'https://xiaoshouzhushou.com/webapi/weixinpro/'.$ldcrm_name.'/notify.php';
        require_once  (globalStatic::$root_directory.'WeiXinApp/weixinPay/cls_WeiXinPay.php');
        $payObj = new cls_WeiXinPay($configArr,$configPath,$notifyUrl);
        //$openid,$description,$out_trade_no,$total
        $description = $_REQUEST['description'];
        $total = $_REQUEST['total'];
        $salesorder_no = $_REQUEST['salesorder_no'];
        $out_trade_no = date('Ymd').'_'.$accountid.'_'.rand(100000,999999);;//商户系统内部订单号string[6,32]
        $attach = [
            'salesorder_no'=>$salesorder_no,
            'moduleName'=>'SalesOrder'
        ];
        $attach = json_encode($attach);
        $res = $payObj->getPrepayId($open_id,$description,$out_trade_no,$total,$attach);
        if($res['statusCode']==200){
            $prepayIdArr = json_decode($res['data'],true);
            $signArr = $payObj->getSign($prepayIdArr['prepay_id']);
            return [1,['signArr'=>$signArr],'success'];
        }else{
            return ['-1',$res,'error'];
        }
    }

    /**
     * 组合支付 先锁定余额 再微信支付  微信支付成功扣除余额  没有成功释放余额
     */
    public function combinationPay(){
        $salesorderid = $_REQUEST['salesorderid'];
        $salesorder_no = $_REQUEST['salesorder_no'];
        $accountid = $_REQUEST['accountid'];
        $open_id = $_REQUEST['open_id'] ;
        //获取客户余额
        $accountInfo = $this->getAccountInfo($open_id);
        $balanceAmount = $accountInfo['balance_amount'];
        //计算微信支付金额
        $total = $_REQUEST['total'];//订单总金额
        $weixinpay_total =$total-$balanceAmount;//需要微信支付的金额

        //发起微信支付
        $configPath = $this->configPath;
        $configArr = $this->configArr;
        global $ldcrm_name;
        $notifyUrl = 'https://xiaoshouzhushou.com/webapi/weixinpro/'.$ldcrm_name.'/notify.php';
        require_once  (globalStatic::$root_directory.'WeiXinApp/weixinPay/cls_WeiXinPay.php');
        $payObj = new cls_WeiXinPay($configArr,$configPath,$notifyUrl);
        //$openid,$description,$out_trade_no,$weixinpay_total
        $description = $_REQUEST['description'];

        $out_trade_no = date('Ymd').'_'.$accountid.'_'.rand(100000,999999);;//商户系统内部订单号string[6,32]
        $attach = [
            'salesorder_no'=>$salesorder_no,
            'moduleName'=>'SalesOrder'
        ];
        $attach = json_encode($attach);
        $res = $payObj->getPrepayId($open_id,$description,$out_trade_no,$weixinpay_total,$attach);
        if($res['statusCode']==200){
            $prepayIdArr = json_decode($res['data'],true);
            $signArr = $payObj->getSign($prepayIdArr['prepay_id']);
            //余额支付的部分 将预收付款单存储到一个临时表中  且将预收付款单的deleted=1
            //1.查询预收单  先进先出
            $debuction_sql = "select debuctionbalanceamount,cashbillid from ld_cashbill where accountid=? and deleted=0 and ifnull(debuctionbalanceamount,0)>0  order by cashbillid asc";
            $debuction_res = $this->adb->pquery($debuction_sql,array($_REQUEST['accountid']));
            $debuction_nums = $this->adb->num_rows($debuction_res);
            if($debuction_nums<=0){
                return [-1,[],'没有对应预收单，请重新查询余额！'];
            }
            for($i=0;$i<$debuction_nums;$i++){
                $debuctionbalanceamount = $this->adb->query_result($debuction_res,$i,'debuctionbalanceamount');
                $cashbillid = $this->adb->query_result($debuction_res,$i,'cashbillid');
                $insert_sql = "insert into ld_shop_tempordercash (salesorder_no,cashbillid,cashamount,createdtime) values (?,?,?,?)";
                $this->adb->pquery($insert_sql,array($salesorder_no,$cashbillid,$debuctionbalanceamount,date('Y-m-d H:i:s')));
                $update_sql = "update ld_cashbill set deleted=1 where cashbillid=?";
                $this->adb->pquery($update_sql,array($cashbillid));
            }
            return [1,['signArr'=>$signArr],'success'];
        }else{
            return ['-1',$res,'error'];
        }

    }
    //组合支付的取消支付 需要将删除的预付单的deleted=0  且ld_shop_tempordercash的关联订单的数据删除
    public function cancelPay(){
        $salesorderid = $_REQUEST['salesorderid'];
        $select_sql = "select a.* from ld_shop_tempordercash a  left join ld_salesorder b on a.salesorder_no=b.salesorder_no where b.salesorderid=?";
        $select_res = $this->adb->pquery($select_sql,array($salesorderid));
        $select_nums = $this->adb->num_rows($select_res);
        if($select_nums>0){
            $salesorder_no = $this->adb->query_result($select_res,0,'salesorder_no');//获取订单编号
            for($i=0;$i<$select_nums;$i++){
                $cashbillid = $this->adb->query_result($select_res,$i,'cashbillid');
                $update_sql = "update ld_cashbill set deleted=0 where cashbillid=?";
                $this->adb->pquery($update_sql,array($cashbillid));
                $insert_sql = "delete from ld_shop_tempordercash where cashbillid=? and salesorder_no=?";
                $this->adb->pquery($insert_sql,array($cashbillid,$salesorder_no));
            }
        }
        return [1,[],'success'];
    }
    /**
     * @return array
     * 取消订单
     */
    public function cancel(){
        $salesorderid = $_REQUEST['salesorderid'];
        $update_sql = " update ld_salesorder set order_status='已取消' where salesorderid=?";
        $update_res = $this->adb->pquery($update_sql,array($salesorderid));
        return array(1,[],'success');
    }

    /**
     * @return array
     * 删除订单
     */
    public function delete(){
        $salesorderid = $_REQUEST['salesorderid'];
        $update_sql = " update ld_salesorder set deleted=1 where salesorderid=?";
        $update_res = $this->adb->pquery($update_sql,array($salesorderid));
        return array(1,[],'success');
    }

    /**
     * @return array
     * 确认收货
     */
    public function confirm(){
        $salesorderid = $_REQUEST['salesorderid'];
        $update_sql = " update ld_salesorder set order_status='售后' where salesorderid=?";
        $update_res = $this->adb->pquery($update_sql,array($salesorderid));
        return array(1,[],'success');
    }

    /**
     * @return array
     * 物流
     */
    public function wuliu(){
        $salesorderid = $_REQUEST['salesorderid'];
        // 订单信息
        $orderdata = $this->DetailView('yes');
        $orderinfo = $orderdata[1]['list'];

        $select_sql = "select express_company,express_no,appreceivermobile from ld_salesorder where salesorderid=?";
        $select_res = $this->adb->pquery($select_sql,array($salesorderid));
        $select_nums = $this->adb->num_rows($select_res);
        if($select_nums>0){
            $express_company = $this->adb->query_result($select_res,0,'express_company');
            $express_no = $this->adb->query_result($select_res,0,'express_no');
            $phone = $this->adb->query_result($select_res,0,'appreceivermobile');
        }
        else{
            return array(1, array('wuliu'=>'','order'=>$orderinfo),'没有物流信息');
        }

        crm_load_class_file('KuaiDi100','WeiXinApp/kuaidi100');
        $kuaidi100_obj = new KuaiDi100();
        if (empty($express_no)) {
            return array(-1, array('wuliu'=>'','order'=>$orderinfo), getFixedLabel('LOGISTICSCANNOTEMPTY'));
        }
        //查询物流信息
        $result = $this->adb->pquery("SELECT * FROM ld_expressinfo where express_no = ?",array($express_no));
        $syncquery_time = '';
        if ($this->adb->num_rows($result) > 0) {
            $express_info = $this->adb->query_result($result, 0, 'express_info');
            $syncquery_time = $this->adb->query_result($result, 0, 'query_time');
        }

        //查询的时间点，缓存判断间隔默认40分钟以上
        if (!empty($syncquery_time)) {
            $cur_time = time();
            if (($cur_time-strtotime($syncquery_time)) < 60*60*24*7) {
                return array(1, array('wuliu'=>Zend_Json::decode($express_info),'order'=>$orderinfo), sprintf(getFixedLabel('WAITANOTHERTMPMINUTES'),(40-floor(($cur_time-strtotime($syncquery_time))/60))));
            }
        }

        $data = $kuaidi100_obj->synquery($express_no,$express_company,$phone);
        if($data['com']){
            $data['comName'] = $express_company;
            $data['comImg'] = 'http://www.71mis.cn/shopimg/kuaidi/'.$data['com'].'.png';
        }
        
        if (empty($data['returnCode'])) {//为空说明返回值正常
            $this->adb->pquery("DELETE FROM ld_expressinfo where express_no = ?",array($express_no));
            $this->adb->pquery("INSERT INTO ld_expressinfo(`express_no`,`express_info`,`query_time`) values(?,?,?)",array($express_no,ldcrm_json_encode($data),date("Y-m-d H:i:s")));
        }else{
            return array(-1,array('wuliu'=>$data,'order'=>$orderinfo),$data['message']);
        }
        return array(1,array('wuliu'=>$data,'order'=>$orderinfo),'success');
    }

    /**
     * 申请开票 -- todo--
     */
    public function invoice(){

    }
    /**
     * 订单列表
     */
    public function ListView(){
        $accountid = $_REQUEST['accountid'];
        $order_status = $_REQUEST['order_status'];

        $where = " where ld_salesorder.deleted=0 and ld_salesorder.accountid='$accountid' ";
        if(!empty($order_status)){
            $order_status = $this->getOrderStatus($order_status);
            $where .= " and ld_salesorder.order_status='$order_status' ";
        }
		if($this->tradeInfo['account']=='liankeshengwu'){
			$where .= " and ld_salesorder.order_source='商城小程序' ";
		}
        //获取金额保留的小数位数

        $page = $_REQUEST['page'];
        $page = empty($page)?0:$page;
        $limit = $_REQUEST['limit'];
        $limit = empty($limit)?20:$limit;
        $start = $page*$limit;
        $limit_sql = " limit $start,$limit ";
        $count_sql = "select 
                count(1) as nums
                from ld_salesorder
                $where";
        $count_res = $this->adb->pquery($count_sql);
        $count_nums = $this->adb->query_result($count_res,0,'nums');
        $curpagenum = (int)$page;//当前页
        $totalrows = (int)$count_nums;//总数据条数
        $pagecount = ceil($count_nums/$limit);

        $havenextpage = "yes";
        if(($curpagenum+1)>=$pagecount){
            $havenextpage = "no";//是否还有下一页
        }

        $orderList = [];
        $order_sql = "select 
        ld_salesorder.salesorderid,
        ld_salesorder.salesorder_no,
        ld_salesorder.duedate,
        ld_salesorder.total,
        ld_salesorder.order_status,
        ld_salesorder.express_no
        from ld_salesorder 
        left join ld_salesordercf on ld_salesorder.salesorderid=ld_salesordercf.salesorderid
        $where
        order by ld_salesorder.createdtime desc $limit_sql
        ";
        $order_res = $this->adb->pquery($order_sql);
        $order_nums = $this->adb->num_rows($order_res);
        if($order_nums>0){
            for($i=0;$i<$order_nums;$i++){
                $salesorderid = $this->adb->query_result($order_res,$i,'salesorderid');
                $orderList[$salesorderid]['salesorderid'] = $salesorderid;
                $orderList[$salesorderid]['salesorder_no'] = $this->adb->query_result($order_res,$i,'salesorder_no');
                $orderList[$salesorderid]['duedate'] = $this->adb->query_result($order_res,$i,'duedate');
                $temp_order_status = $this->adb->query_result($order_res,$i,'order_status');
                $temp_express_no = $this->adb->query_result($order_res,$i,'express_no');
                $orderList[$salesorderid]['order_status'] = $temp_order_status;
                $orderList[$salesorderid]['salesorderBtns'] = $this->getOrderBtns($temp_order_status,$temp_express_no);
                $orderList[$salesorderid]['total'] = $this->adb->query_result($order_res,$i,'total');
                $orderList[$salesorderid]['total'] = round($orderList[$salesorderid]['total'],2);
                $orderList[$salesorderid]['total_arr'] = $this->formatPrice($orderList[$salesorderid]['total']);
            }
        }
        $corpurl = $this->corpurl;
        $defaultImage = $this->defaultProductImage;

        $orderdetail_sql = "select 
        ld_products.unit_price as price,
        ld_products.productname as productname,
		ld_products.".$this->showProductNoField.",
		ld_products.productsheet,
        ifnull(ld_products.imagename,'') as image,
        ld_salesorderdetail.quantity,
        ld_salesorderdetail.productid,
        ld_salesorderdetail.tax_amount,
        ld_salesorderdetail.id
        from ld_salesorderdetail  
        left join ld_salesorderdetailscf on ld_salesorderdetail.lineitem_id=ld_salesorderdetailscf.lineitem_id
        left join ld_products on ld_products.productid=ld_salesorderdetail.productid
        inner join 
        (select ld_salesorder.salesorderid from ld_salesorder  $where
        order by ld_salesorder.createdtime desc $limit_sql) 
        temporder on temporder.salesorderid=ld_salesorderdetail.id
        ";
        $orderdetail_res = $this->adb->pquery($orderdetail_sql);
        $orderdetail_nums = $this->adb->num_rows($orderdetail_res);
        if($orderdetail_nums>0){
            for($j=0;$j<$orderdetail_nums;$j++){
                $salesorderid = $this->adb->query_result($orderdetail_res,$j,'id');
                $productid = $this->adb->query_result($orderdetail_res,$j,'productid');
                $temp_product = [];
                $temp_product['salesorderid'] = $salesorderid;
                $temp_product['productid'] = $productid;
                $temp_product['buynum'] = $this->adb->query_result($orderdetail_res,$j,'quantity');
                $temp_product['buynum'] = (int)$temp_product['buynum'];
                $temp_product['name'] = $this->adb->query_result($orderdetail_res,$j,'productname');
				$temp_product['num'] = $this->adb->query_result($orderdetail_res,$j,$this->showProductNoField);
				$temp_product['sheet'] = $this->adb->query_result($orderdetail_res,$j,'productsheet');
                $temp_product['price'] = $this->adb->query_result($orderdetail_res,$j,'price');
                $temp_product['price'] = round($temp_product['price'],2);
                $temp_product['price_arr'] = $this->formatPrice($temp_product['price']);
                $temp_product['subtotal'] = $this->adb->query_result($orderdetail_res,$j,'tax_amount');//单个商品的价税合计
                $temp_product['subtotal'] = round($temp_product['subtotal'],2);
                $temp_product['subtotal_arr'] = $this->formatPrice($temp_product['subtotal']);
                //查询所有附件
                $attachment_sql = "select a.attachmentcolumnname,b.storage_location,b.path,b.newfile_name,b.cloud_path from ld_seattachmentsrel a left join ld_attachments b on a.attachmentsid=b.attachmentsid where a.crmid=?";
                $attachment_res = $this->adb->pquery($attachment_sql,array($productid));
                $attachment_nums = $this->adb->num_rows($attachment_res);
                if($attachment_nums>0){
                    for($k=0;$k<$attachment_nums;$k++){
                        $temp_attachmentcolumnname = $this->adb->query_result($attachment_res,$k,'attachmentcolumnname');
                        $temp_storage_location = $this->adb->query_result($attachment_res,$k,'storage_location');
                        $temp_path = $this->adb->query_result($attachment_res,$k,'path');
                        $temp_newfile_name = $this->adb->query_result($attachment_res,$k,'newfile_name');
                        $temp_cloud_path = $this->adb->query_result($attachment_res,$k,'cloud_path');
                        //封面
                        if($temp_attachmentcolumnname=="imagename"){
                            if($temp_storage_location == "cos"){
                                $temp_product['image'] = $temp_cloud_path;
                            }
                            if($temp_storage_location == "local"){
                                $temp_product['image'] = $corpurl . $temp_path.$temp_newfile_name;
                            }
                        }
                    }
                }else{
                    $temp_product['image'] = $defaultImage;
                }
                $orderList[$salesorderid]['detail'][] = $temp_product;
            }
        }
        $orderList = array_values($orderList);
        return array(1,[
            "list"=>$orderList,
            'curpagenum'=>$curpagenum,
            'totalrows'=>$totalrows,
            'pagecount'=>$pagecount,
            'pagename'=>'订单列表',
            'havenextpage'=>$havenextpage
        ],'success');
    }
    public function DetailView($hidebtn='no'){
        $accountid = $_REQUEST['accountid'];//客户ID
        $salesorderid = $_REQUEST['salesorderid'];//订单ID
        $corpurl = $this->corpurl;

        //物流信息 已付款且填写物流单号的显示--todo--

        //显示收货地址  姓名：联系人表读取？   电话 地址
        //订单产品信息 如订单列表类似显示
        //订单信息 订单编号-复制按钮，微信支付交易号（已支付可显示），创建时间，付款时间（已支付可显示），发货时间（已发货可现实）
        //按钮组
        $orderInfo = [];
        $order_sql = "select 
        ld_salesorder.salesorderid,
        ld_salesorder.salesorder_no,
        ld_salesorder.duedate,
        ld_salesorder.total,
        ld_salesorder.createdtime,
        ld_salesorder.order_status,
        ld_salesorder.description,
        ifnull(ld_salesorder.express_company,'')as express_company,
        ifnull(ld_salesorder.express_no,'')as express_no,
        ld_salesorder.appreceivername,
        ld_salesorder.appreceivermobile,
        ld_salesorder.appreceiveradress,
        ld_contactdetails.lastname,
        ld_contactdetails.mobile,
        ifnull(ld_contactdetails.mailingcountry,'') as mailingcountry,
        ifnull(ld_contactdetails.mailingstate,'') as mailingstate,
        ifnull(ld_contactdetails.mailingcity,'') as mailingcity,
        ifnull(ld_contactdetails.mailingarea,'') as mailingarea,
        ifnull(ld_contactdetails.mailingstreet,'') as mailingstreet,
        companyname,
        taxnumber,
        companyaddress,
        telephone,
        bankname,
        bankaccount
        from ld_salesorder 
        left join ld_salesordercf on ld_salesorder.salesorderid=ld_salesordercf.salesorderid
        left join ld_contactdetails on ld_contactdetails.contactid=ld_salesorder.contactid
        where ld_salesorder.salesorderid=?
        ";
        $order_res = $this->adb->pquery($order_sql,array($salesorderid));
        $order_nums = $this->adb->num_rows($order_res);


        //订单附件
        //查询所有附件 20230131
        if($this->showAtt=='yes') {
            $sattachment_sql = "select a.attachmentcolumnname,b.storage_location,b.path,b.newfile_name,b.cloud_path from ld_seattachmentsrel a left join ld_attachments b on a.attachmentsid=b.attachmentsid where a.crmid=?";
            $sattachment_res = $this->adb->pquery($sattachment_sql, array($salesorderid));
            $sattachment_nums = $this->adb->num_rows($sattachment_res);
            if ($sattachment_nums > 0) {
                for ($k1 = 0; $k1 < $sattachment_nums; $k1++) {
                    $temp_attachmentcolumnname = $this->adb->query_result($sattachment_res, $k1, 'attachmentcolumnname');
                    $temp_storage_location = $this->adb->query_result($sattachment_res, $k1, 'storage_location');
                    $temp_path = $this->adb->query_result($sattachment_res, $k1, 'path');
                    $temp_newfile_name = $this->adb->query_result($sattachment_res, $k1, 'newfile_name');
                    $temp_cloud_path = $this->adb->query_result($sattachment_res, $k1, 'cloud_path');
                    //订单的所有附件
                    if ($temp_attachmentcolumnname == "filename") {
                        if ($temp_storage_location == "cos") {
                            $orderInfo['filename'][] = $temp_cloud_path;
                        }
                        if ($temp_storage_location == "local") {
                            $orderInfo['filename'][] = $corpurl . $temp_path . $temp_newfile_name;
                        }
                    }
                }
            }
        }
        $orderInfo['addressInfo'] = [];
        $orderInfo['timeInfo'] = [];
        $timeInfo = [];//订单的各种时间数组
        if($order_nums>0){
            $salesorderid = $this->adb->query_result($order_res,0,'salesorderid');
            $orderInfo['salesorderid'] = $salesorderid;
            $salesorder_no = $orderInfo['salesorder_no'] = $this->adb->query_result($order_res,0,'salesorder_no');
            $timeInfo["1"] = ["fieldname"=>"订单编号","fieldvalue"=>$salesorder_no];//方便前端循环
            $temp_order_status = $this->adb->query_result($order_res,0,'order_status');
            $orderInfo['order_status'] = $temp_order_status;
            $timeInfo["9"] = ["fieldname"=>"订单备注","fieldvalue"=>$this->adb->query_result($order_res,0,'description')];//订单备注
            $createdtime = $orderInfo['createdtime'] = $this->adb->query_result($order_res,0,'createdtime');//创建时间
            $timeInfo["2"] = ["fieldname"=>'创建时间',"fieldvalue"=>$createdtime];

            $orderInfo['express_company'] = $this->adb->query_result($order_res,0,'express_company');//物流公司
            if($orderInfo['express_company'] != ''){
                $timeInfo["7"] = ["fieldname"=>'物流公司',"fieldvalue"=>$orderInfo['express_company']];
            }
            $orderInfo['express_no'] = $this->adb->query_result($order_res,0,'express_no');//物流单号
            if($orderInfo['express_no'] != ''){
                $timeInfo["8"] = ["fieldname"=>'物流单号',"fieldvalue"=>$orderInfo['express_no']];
            }
            if($hidebtn == 'no'){
                $orderInfo['salesorderBtns'] = $this->getOrderBtns($temp_order_status,$orderInfo['express_no'] );
            }
            $orderInfo['addressInfo']['lastname'] = $this->adb->query_result($order_res,0,'appreceivername');//联系人名字
            $orderInfo['addressInfo']['mobile'] = $this->adb->query_result($order_res,0,'appreceivermobile');//联系人电话
            $orderInfo['addressInfo']['address'] = $this->adb->query_result($order_res,0,'appreceiveradress');//订单地址
            //地址不存在  则读取联系人地址
            $mailingstate = $this->adb->query_result($order_res,0,'mailingstate');
            $mailingcity = $this->adb->query_result($order_res,0,'mailingcity');
            $mailingarea = $this->adb->query_result($order_res,0,'mailingarea');
            $mailingstreet = $this->adb->query_result($order_res,0,'mailingstreet');
            $orderInfo['addressInfo']['address'] = empty($orderInfo['addressInfo']['address'])?$mailingstate.' '.$mailingcity.' '.$mailingarea.' '.$mailingstreet:$orderInfo['addressInfo']['address'];//订单地址
            $orderInfo['addressInfo']['address'] = ltrim($orderInfo['addressInfo']['address']);
            $orderInfo['addressInfo']['lastname'] = empty($orderInfo['addressInfo']['lastname'])?$this->adb->query_result($order_res,0,'lastname'):$orderInfo['addressInfo']['lastname'];//联系人名字
            $orderInfo['addressInfo']['mobile'] = empty($orderInfo['addressInfo']['mobile'])?$this->adb->query_result($order_res,0,'mobile'):$orderInfo['addressInfo']['mobile'];//联系人电话

            $orderInfo['total'] = $this->adb->query_result($order_res,0,'total');
            $orderInfo['total'] = round($orderInfo['total'],2);
            $orderInfo['total_arr'] = $this->formatPrice($orderInfo['total']);
            //开票信息显示
            $orderInfo['wx_invoiceInfo'][] = ["fieldname"=>'名称',"fieldvalue"=>$this->adb->query_result($order_res,0,'companyname')];
            $orderInfo['wx_invoiceInfo'][] = ["fieldname"=>'税号',"fieldvalue"=>$this->adb->query_result($order_res,0,'taxnumber')];
            $orderInfo['wx_invoiceInfo'][] = ["fieldname"=>'单位地址',"fieldvalue"=>$this->adb->query_result($order_res,0,'companyaddress')];
            $orderInfo['wx_invoiceInfo'][] = ["fieldname"=>'电话号码',"fieldvalue"=>$this->adb->query_result($order_res,0,'telephone')];
            $orderInfo['wx_invoiceInfo'][] = ["fieldname"=>'开户银行',"fieldvalue"=>$this->adb->query_result($order_res,0,'bankname')];
            $orderInfo['wx_invoiceInfo'][] = ["fieldname"=>'银行账户',"fieldvalue"=>$this->adb->query_result($order_res,0,'bankaccount')];
            //如果订单状态是待发货 待收货 售后 需要查询付款时间/支付方式/微信交易号  -- 关联的收款单的时间
            if(in_array($temp_order_status,['待发货','待收货','售后'])){
                $cashbill_sql = "select ifnull(transaction_no,'')as transaction_no,createdtime,paymentmethod from ld_cashbill where entitytype='SalesOrder' and source_list=? limit 1";
                $cashbill_res = $this->adb->pquery($cashbill_sql,array($salesorderid));
                $cashbill_nums = $this->adb->num_rows($cashbill_res);
                if($cashbill_nums>0){
                    $paymentmethod = $this->adb->query_result($cashbill_res,0,'paymentmethod');
                    $timeInfo["3"] = ["fieldname"=>'付款时间',"fieldvalue"=>$this->adb->query_result($cashbill_res,0,'createdtime')];
                    $timeInfo["4"] = ["fieldname"=>'支付方式',"fieldvalue"=>$paymentmethod];
                    if($paymentmethod=="微信支付"){//微信支付才显示微信交易号
                        $timeInfo["5"] = ["fieldname"=>'微信交易号',"fieldvalue"=>$this->adb->query_result($cashbill_res,0,'transaction_no')];
                    }
                }
            }
            //如果订单状态时待收货 售后 需要查询发货时间 -- 关联的出库单的时间
            //if(in_array($temp_order_status,['待收货','售后'])){
                $outboundorder_sql = "select createdtime  from ld_outboundorder where source_list=? limit 1";
                $outboundorder_res = $this->adb->pquery($outboundorder_sql,array($salesorderid));
                $outboundorder_nums = $this->adb->num_rows($outboundorder_res);
                if($outboundorder_nums>0){
                    $timeInfo["6"] = ["fieldname"=>'发货时间',"fieldvalue"=>$this->adb->query_result($outboundorder_res,0,'createdtime')];
                }
            //}

        }
        ksort($timeInfo);
        $orderInfo['timeInfo'] = array_values($timeInfo);
        $defaultImage = $this->defaultProductImage;
        $orderdetail_sql = "select 
        ld_products.unit_price as price,
        ld_products.productname as productname,
        ld_products.".$this->showProductNoField.",
        ld_products.productsheet,
        ifnull(ld_products.imagename,'') as image,
        ld_salesorderdetail.quantity,
        ld_salesorderdetail.productid,
        ld_salesorderdetail.tax_amount,
        ld_salesorderdetail.id
        from ld_salesorderdetail  
        left join ld_salesorderdetailscf on ld_salesorderdetail.lineitem_id=ld_salesorderdetailscf.lineitem_id
        left join ld_products on ld_products.productid=ld_salesorderdetail.productid
        where ld_salesorderdetail.id=?
        ";
        $orderdetail_res = $this->adb->pquery($orderdetail_sql,array($salesorderid));
        $orderdetail_nums = $this->adb->num_rows($orderdetail_res);
        if($orderdetail_nums>0){
            for($j=0;$j<$orderdetail_nums;$j++){
                $salesorderid = $this->adb->query_result($orderdetail_res,$j,'id');
                $productid = $this->adb->query_result($orderdetail_res,$j,'productid');
                $temp_product = [];
                $temp_product['salesorderid'] = $salesorderid;
                $temp_product['productid'] = $productid;
                $temp_product['buynum'] = $this->adb->query_result($orderdetail_res,$j,'quantity');
                $temp_product['buynum'] = (int)$temp_product['buynum'];
                $temp_product['name'] = $this->adb->query_result($orderdetail_res,$j,'productname');
                $temp_product['num'] = $this->adb->query_result($orderdetail_res,$j,$this->showProductNoField);
                $temp_product['sheet'] = $this->adb->query_result($orderdetail_res,$j,'productsheet');
                $temp_product['price'] = $this->adb->query_result($orderdetail_res,$j,'price');
                $temp_product['price'] = round($temp_product['price'],2);
                $temp_product['price_arr'] = $this->formatPrice($temp_product['price']);
                $temp_product['subtotal'] = $this->adb->query_result($orderdetail_res,$j,'tax_amount');//单个商品的价税合计
                $temp_product['subtotal'] = round($temp_product['subtotal'],2);
                $temp_product['subtotal_arr'] = $this->formatPrice($temp_product['subtotal']);
                //查询所有附件
                $attachment_sql = "select a.attachmentcolumnname,b.storage_location,b.path,b.newfile_name,b.cloud_path from ld_seattachmentsrel a left join ld_attachments b on a.attachmentsid=b.attachmentsid where a.crmid=?";
                $attachment_res = $this->adb->pquery($attachment_sql,array($productid));
                $attachment_nums = $this->adb->num_rows($attachment_res);
                if($attachment_nums>0){
                    for($k=0;$k<$attachment_nums;$k++){
                        $temp_attachmentcolumnname = $this->adb->query_result($attachment_res,$k,'attachmentcolumnname');
                        $temp_storage_location = $this->adb->query_result($attachment_res,$k,'storage_location');
                        $temp_path = $this->adb->query_result($attachment_res,$k,'path');
                        $temp_newfile_name = $this->adb->query_result($attachment_res,$k,'newfile_name');
                        $temp_cloud_path = $this->adb->query_result($attachment_res,$k,'cloud_path');
                        //封面
                        if($temp_attachmentcolumnname=="imagename"){
                            if($temp_storage_location == "cos"){
                                $temp_product['image'] = $temp_cloud_path;
                            }
                            if($temp_storage_location == "local"){
                                $temp_product['image'] = $corpurl . $temp_path.$temp_newfile_name;
                            }
                        }
                    }
                }else{
                    $temp_product['image'] = $defaultImage;
                }
                $orderInfo['detail'][] = $temp_product;
            }
        }
        return array(1,[
            "list"=>$orderInfo,
            'pagename'=>'订单详情',
        ],'success');
    }


    /**
     * @return array
     * @throws Exception
     * 获取个人中心页面-各类型订单的数量
     * 客户信息
     */
    public function PersonalInfo(){
        $accountInfo  =$this->getAccountInfo($_REQUEST['open_id']);
        $accountid = $accountInfo['accountid'];
        $orderStatusArr = $this->orderStatusArr;
        $sql = " select count(salesorderid) as nums,order_status from ld_salesorder where deleted=0 and accountid=? group by order_status";
        $res = $this->adb->pquery($sql,array($accountid));
        $nums = $this->adb->num_rows($res);
        if($nums>0) {
            for ($j = 0; $j < $nums; $j++) {
                $temp_order_status = $this->adb->query_result($res,$j,'order_status');
                $temp_nums = $this->adb->query_result($res,$j,'nums');
                if(isset($orderStatusArr[$temp_order_status])){
                    $orderStatusArr[$temp_order_status]['nums'] = $temp_nums;
                }
            }
        }
        return array(1 ,[
            "list"=>array_values($orderStatusArr),
            'accountInfo'=>$accountInfo,
            'pagename'=>'我的'

        ],'success');
    }
}