<?php

require_once(globalStatic::$root_directory.'WeiXinApp/ldmall/modules/LdMall.php');

class LdMallNotify extends LdMall
{
    /**
     * 充值的回调
     * @param $inBodyResourceArray //回调结果数组
     * @throws Exception
     *
     */
    public function recharge($inBodyResourceArray){
        global $current_user;
        $transaction_id = $inBodyResourceArray['transaction_id'];//微信交易编号
        $out_trade_no = $inBodyResourceArray['out_trade_no'];
        $out_trade_no_arr = explode('_',$out_trade_no);//date('Ymd').'_'.$accountid.'_'.rand(0,9999);
        $trade_state = $inBodyResourceArray['trade_state'];
        $total = $inBodyResourceArray['amount']['payer_total'];
        if($trade_state=="SUCCESS") {//支付成功才更状态以及创建收款单
            //更改订单的状态
            $current_user->id =1;//先写1 后面再改
            $current_user->is_admin ="on";
            $cashbillFocus = CRMEntity::getInstance('CashBill');
            $_REQUEST['mode'] = "create";
            $_REQUEST['account_id'] = $out_trade_no_arr[1];
            $_REQUEST['cashbilldate'] = date('Y-m-d');
            $_REQUEST['paymentmethod'] = self::PAYMETHODWEIXIN;

            $_REQUEST['bankaccountsetid'] = $this->getBankaccountsetid();
            $_REQUEST['assigned_user_id'] = $current_user->id;
            $_REQUEST['cashtype'] = 'debuction';
            $_REQUEST['currency_id'] = 1;
            $_REQUEST['transaction_no'] = $transaction_id;//微信交易单号
            $_REQUEST['cashbilltype'] = 'debuction';
            $_REQUEST['description'] = self::PAYMETHODWEIXIN."充值：".$inBodyResourceArray['trade_state_desc'].',商户系统内部订单号:'.$out_trade_no;
            $_REQUEST['cashbill_total'] = $total/100;
            $_REQUEST['subtotal'] = $total/100;
            setObjectValuesFromRequest($cashbillFocus);
            $cashbillFocus->save("CashBill");
        }
    }

    /**
     * @param $inBodyResourceArray //回调结果数组
     * @throws Exception
     * $inBodyResourceArray
     */
    public function salesorderWeixinPay($inBodyResourceArray){
        global $current_user;
        //更改订单的状态
        $current_user->id =1;//先写1 后面再改
        $current_user->is_admin ="on";

        $transaction_id = $inBodyResourceArray['transaction_id'];//微信交易编号
        $attach = $inBodyResourceArray['attach'];//附加数据  传输模块名称 用以判断是订单支付还是充值
        $attach = json_decode($attach,true);
        $salesorder_no = $attach['salesorder_no'];
        $trade_state = $inBodyResourceArray['trade_state'];
        $total = $inBodyResourceArray['amount']['payer_total'];
        if($trade_state=="SUCCESS"){//支付成功才更状态以及创建收款单
            //去临时表查询 是否要扣除余额的
            $debuction_sql = "select * from ld_shop_tempordercash where salesorder_no=?";
            $debuction_res = $this->adb->pquery($debuction_sql,array($salesorder_no));
            $debuction_nums = $this->adb->num_rows($debuction_res);
            if($debuction_nums>0){
                //订单信息
                $salesorder_sql = "select accountid,salesorderid,total from ld_salesorder where salesorder_no=?";
                $salesorder_res = $this->adb->pquery($salesorder_sql,array($salesorder_no));
                $accountid = $this->adb->query_result($salesorder_res,0,'accountid');
                $salesorderid = $this->adb->query_result($salesorder_res,0,'salesorderid');
                $salesorder_total = $this->adb->query_result($salesorder_res,0,'total');
                $balance_total =$salesorder_total-($total/100);
                //余额部分支付处理
                $debuctionList = [];
                $save_debuctioninfo = [];
                for($i=0;$i<$debuction_nums;$i++){
                    $temp_debuctionbalanceamount = $this->adb->query_result($debuction_res,$i,'cashamount');
                    $temp_cashbillid = $this->adb->query_result($debuction_res,$i,'cashbillid');
                    $debuctionList[$i]['debuctionbalanceamount'] = $temp_debuctionbalanceamount;
                    $debuctionList[$i]['cashbillid'] = $temp_cashbillid;
                    $save_debuctioninfo[$i]['type'] = 'new';
                    $save_debuctioninfo[$i]['debuctionid'] = $temp_cashbillid;
                    $update_sql = "update ld_cashbill set deleted=0 where cashbillid=?";
                    $this->adb->pquery($update_sql,array($temp_cashbillid));
                    $insert_sql = "delete from ld_shop_tempordercash where cashbillid=? and salesorder_no=?";
                    $this->adb->pquery($insert_sql,array($temp_cashbillid,$salesorder_no));
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
                $_REQUEST['account_id'] = $accountid;
                $_REQUEST['selectsourcename'] = 'SalesOrder';
                $_REQUEST['cashtype'] = 'cashbill';
                $_REQUEST['assigned_user_id'] = $current_user->id;
                $_REQUEST['paymentmethod'] = self::PAYMETHODBALANCE;
                $_REQUEST['cashbilldate'] = date('Y-m-d');
                $_REQUEST['selectlistval'] = $salesorderid;
                $_REQUEST['bankaccountsetid'] = 1;
                $_REQUEST['description'] = "微信订单".self::PAYMETHODBALANCE;;
                $_REQUEST['rowcnt'] = 1;
                $_REQUEST['currency_id'] = 1;
                $_REQUEST['entitytypeid1'] = $salesorderid;

                $_REQUEST['amount1'] = $balance_total;
                $_REQUEST['cashbill_total'] = 0;
                $cashbillObj = CRMEntity::getInstance('CashBill');
                setObjectValuesFromRequest($cashbillObj);
                $cashbillObj->getBefore_SumDetailValues();
                $cashbillObj->save('CashBill');
            }
            $_REQUEST['save_debuctioninfo'] = '';
            //订单信息
            $salesorder_sql = "select salesorderid,accountid from ld_salesorder where salesorder_no=?";
            $salesorder_res = $this->adb->pquery($salesorder_sql, array($salesorder_no));
            $salesorderid = $this->adb->query_result($salesorder_res,0,"salesorderid");
            $accountid = $this->adb->query_result($salesorder_res,0,"accountid");
            //付款单信息
            $cashbillObj = CRMEntity::getInstance('CashBill');
            $_REQUEST['mode'] = "create";
            //2.创建收款单
            //accountid  salesorderid  cashbilldate  paymentmethod  Total  subtotal
            //bankaccountsetid   smownerid   smcreatorid   chreatedtime modifiedtime description
            $_REQUEST['account_id'] = $accountid;
            $_REQUEST['selectsourcename'] = 'SalesOrder';
            $_REQUEST['cashbilltype'] = 'cashbill';
            $_REQUEST['assigned_user_id'] = $current_user->id;
            $_REQUEST['paymentmethod'] = self::PAYMETHODWEIXIN;
            $_REQUEST['transaction_no'] = $transaction_id;//微信交易单号
            $_REQUEST['cashbilldate'] = date('Y-m-d');
            $_REQUEST['selectlistval'] = $salesorderid;
            $_REQUEST['bankaccountsetid'] = $this->getBankaccountsetid();
            $_REQUEST['description'] = self::PAYMETHODWEIXIN."：".$inBodyResourceArray['trade_state_desc'];
            $_REQUEST['rowcnt'] = 1;
            $_REQUEST['entitytypeid1'] = $salesorderid;
            $_REQUEST['amount1'] = $total/100;
            $_REQUEST['cashbill_total'] = $total/100;

            setObjectValuesFromRequest($cashbillObj);
            $cashbillObj->getBefore_SumDetailValues();
            $cashbillObj->save('CashBill');
            $cashbillid = $cashbillObj->id;
            $updatecash_sql = "update ld_cashbill set transaction_no=? where cashbillid=?";
            $this->adb->pquery($updatecash_sql, array($transaction_id,$cashbillid));
            //更改订单的状态
            $update_sql = " update ld_salesorder set order_status='待收货' where salesorder_no=?";
            $this->adb->pquery($update_sql, array($salesorder_no));
        }
    }

    /**
     * @return int|mixed|string|string[]|null
     * @throws Exception
     * 获取默认账户
     */
    public function  getBankaccountsetid(){
        //查询账户 人民币账户  有效的账户
        $bank_sql = "select Bankaccountsetid from ld_bankaccountset where deleted=0 and currency_id=1 and discontinued=1 order by Bankaccountsetid asc limit 1 ";
        $bank_res = $this->adb->pquery($bank_sql);
        $bankaccountsetid = $this->adb->query_result($bank_res,0,'Bankaccountsetid');
        return $bankaccountsetid;
    }
}