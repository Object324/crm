<?php

//收款相关的方法
class LdMallCashBill  extends LdMall
{
    /**
     * 小程序端 充值
     * 创建收款单-预算
     * @param  // $account_id 客户ID
     * @param  // $cashbilldate 充值日期
     * @param  // $paymentmethod 收款方式  “微信支付”
     *
     */
    public function recharge(){
        $cashtotal = $_REQUEST['cashtotal'];
        $open_id = $_REQUEST['open_id'] ;
        $accountid = $_REQUEST['accountid'] ;
        if(empty($accountid)){
            return ['-1',[],'你还没有授权手机号！'];
        }
        $configPath = $this->configPath;
        $configArr = $this->configArr;//小程序配置 商户号配置
        //$notifyUrl = $this->corpurl . 'WeiXinApp/ldmall/notify_cash.php';//充值的回调
        global $ldcrm_name;
        $notifyUrl = 'https://xiaoshouzhushou.com/webapi/weixinpro/'.$ldcrm_name.'/notify.php';//充值的回调
        require_once  (globalStatic::$root_directory.'WeiXinApp/weixinPay/cls_WeiXinPay.php');
        $payObj = new cls_WeiXinPay($configArr,$configPath,$notifyUrl);
        //$openid,$description,$out_trade_no,$total
        $description = '充值';
        $out_trade_no = date('Ymd').'_'.$accountid.'_'.rand(100000,999999);
        $attach = [
            'moduleName'=>'CashBill'
        ];
        $attach = json_encode($attach);
        $res = $payObj->getPrepayId($open_id,$description,$out_trade_no,$cashtotal,$attach);
        if($res['statusCode']==200){
            $prepayIdArr = json_decode($res['data'],true);
            $signArr = $payObj->getSign($prepayIdArr['prepay_id']);
            $accountInfo = $this->getAccountInfo($open_id);
            return [1,['signArr'=>$signArr,'balance_amount'=>$accountInfo['balance_amount']+$cashtotal],'success'];
        }else{
            return ['-1',$res,'error'];
        }
    }

    /***
     * @return array
     * @throws Exception
     * 账单
     * 充值以及下单支付账单
     */
    public function getBillByMonth(){
        $time_range = $_REQUEST['time_range'];//时间  年月 and createdtime like '%$time_range%'   and ld_salesorder.createdtime like '%$time_range%'
        $bill_type = $_REQUEST['bill_type'];//账单类型  筛选“0 全部”、“充值（仅显示充值记录）”、“订货支出（仅显示订单记录）”;
        $accountid = $_REQUEST['accountid'];
        $page = $_REQUEST['page'];
        $page = empty($page)?0:$page;
        $limit = $_REQUEST['limit'];
        $limit = empty($limit)?20:$limit;
        $start = ($page-1)*$limit;
        $limit_sql = " limit $start,$limit ";


        $cash_sql = "select 
                        subtotal,
                        createdtime,
                        '充值' as bill_type ,
                        ''as subfix
                        from ld_cashbill 
                        where cashtype='debuction'
                        and deleted=0
                        and accountid=$accountid
                        
                        order by createdtime desc";
        $order_sql = "select 
                    subtotal,
                    createdtime,
                    '订货支出' as bill_type,
                    '-'as subfix 
                    from  ld_salesorder 
                    inner join 
                    (
                        select DISTINCT entitytypeid 
                        from ld_cashbill2paymentplan 
                        left join ld_cashbill on ld_cashbill.cashbillid=ld_cashbill2paymentplan.CashBillID
                        where ld_cashbill.accountid=$accountid 
                        and ld_cashbill.deleted=0
                        and ld_cashbill.cashtype!='debuction'
                    )a on ld_salesorder.salesorderid =a.entitytypeid
                    where ld_salesorder.deleted=0
                    and ld_salesorder.accountid=$accountid 
                    
                     order by createdtime desc";
        if($bill_type=="1"){
            $sql = $cash_sql.' '.$limit_sql;
            $count_sql = $cash_sql;
        }else if($bill_type=="2"){
            $sql = $order_sql.' '.$limit_sql;
            $count_sql = $order_sql;
        }else{
            $sql = "select * from ($cash_sql) a union all ($order_sql)  order by createdtime desc ".$limit_sql;
            $count_sql = "select * from ($cash_sql) a union all ($order_sql)  order by createdtime desc ";
        }
        $count_res = $this->adb->pquery($count_sql,array());
        $count_nums = $this->adb->num_rows($count_res);
        $curpagenum = (int)$page;//当前页
        $totalrows = (int)$count_nums;//总数据条数
        $pagecount = ceil($count_nums/$limit);

        $havenextpage = "yes";
        if($curpagenum>=$pagecount){
            $havenextpage = "no";//是否还有下一页
        }

        $res = $this->adb->pquery($sql);
        $nums = $this->adb->num_rows($res);
        if($nums<=0){
            return array(1,[
                'list'=>[],
                'curpagenum'=>0,
                'totalrows'=>0,
                'pagecount'=>0,
                'pagename'=>'我的账单',
                'havenextpage'=>'no'
            ],'没有记录');
        }
        $list = [];
        for($i=0;$i<$nums;$i++){
            $subfix = $this->adb->query_result($res,$i,'subfix');
            $list[$i]['subtotal'] = $subfix . (number_format($this->adb->query_result($res,$i,'subtotal'),2));
            $list[$i]['createdtime'] = $this->adb->query_result($res,$i,'createdtime');
            $list[$i]['bill_type'] = $this->adb->query_result($res,$i,'bill_type');
        }
        return array(1,[
            'list'=>$list,
            'curpagenum'=>$curpagenum,
            'totalrows'=>$totalrows,
            'pagecount'=>$pagecount,
            'pagename'=>'我的账单',
            'havenextpage'=>$havenextpage
        ],'成功');
    }



}