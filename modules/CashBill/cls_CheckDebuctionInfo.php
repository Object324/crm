<?php

class cls_CheckDebuctionInfo{
    public $record;
    public $errorinfo;
    public $debuctionids;
    public $debuctioninfos;//预收款信息
    /**
     * $debuctionids:预收款单id（数组）
     * 
     * */
    public function __construct($record,$debuctioninfos){
        $this->record=$record;
        $this->errorinfo='';
      //  $this->debuctionids=$debuctionids;
        $debuctionids=array();//预收款单id
        
        foreach($debuctioninfos as $debuctionid=>$amount){
                $debuctionids[]=$debuctionid;
        }
        $this->debuctionids=$debuctionids;
        $this->debuctioninfos=$debuctioninfos;
            
    }
    //public function setAccountid($accountid)
    /**
     * 
     * $req_accountid:前端选择的客户id
     * $req_bankaccountsetid:前端选择的账户
     * */
    public function Check($req_accountid,$req_bankaccountsetid){
        global $adb;
        $record=$this->record;
        $debuctionids=$this->debuctionids;
        $db_debuctioninfo = [];
        $db_cashbillnos = [];
        if($record<=0){
            if(!is_array($debuctionids)||empty($debuctionids))
            {
                return ;
            }
            //收款单新增界面获取预收款的剩余可抵扣金额
            $sql='select debuctionbalanceamount,cashbillid,ld_cashbill.cashbill_no from ld_cashbill where cashbillid in ('.implode(',',$debuctionids).')';
            $result=$adb->pquery($sql,array());
            $rows=$adb->num_rows($result);
            
            for($i=0;$i<$rows;$i++){
                $cashbillid=$adb->query_result($result,$i,'cashbillid');
                $debuctionbalanceamount=$adb->query_result($result,$i,'debuctionbalanceamount');
                $db_debuctioninfo[$cashbillid]=$debuctionbalanceamount;
                $db_cashbillnos[$cashbillid]=$adb->query_result($result,$i,'cashbill_no');
            }
                
        }
        else{
            $sql='select accountid,bankaccountsetid,cashtype,debuctionbalanceamount,total,currency_id from ld_cashbill where cashbillid=?';
            $result=$adb->pquery($sql,array($record));
            $debuctionbalanceamount=$adb->query_result($result,0,'debuctionbalanceamount')??0;
            $$debuctionbalanceamount=number_format($debuctionbalanceamount,2,'.', '');
            $total=$adb->query_result($result,0,'total')??0;
            $total=number_format($total,2,'.', '');
            $accountid=$adb->query_result($result,0,'accountid');
            $Bankaccountsetid=$adb->query_result($result,0,'bankaccountsetid');
            $cashtype=$adb->query_result($result,0,'cashtype');
            $currency_id=$adb->query_result($result,0,'currency_id');
            
            if(!empty($accountid)&&$accountid!=$req_accountid){
                
                if($cashtype=='debuction')//预收款保存
                {
                    if($$debuctionbalanceamount!=$total)
                    {
                        $this->errorinfo='该单据已有核销,客户名称不允许修改！';
                        return ;
                    }
                }
                else{
                    $sql='select * from ld_cashbilldebuctiondetail where cashbillid=? limit 1';
                    
                    $tmpresult=$adb->pquery($sql,array($record));
                    if($adb->num_rows($tmpresult)>0){
                        $this->errorinfo='该单据已有核销,客户名称不允许修改！';
                        return ;
                    }
                }
                
            }
            $req_currency_id=$this->getreqCurrencyId($req_bankaccountsetid);
        
            if(!empty($currency_id)&&$currency_id!=$req_currency_id){
                
                if($cashtype=='debuction')//预收款保存
                {
                    if($debuctionbalanceamount!=$total)
                    {
                        $this->errorinfo='该单据已有核销,币种不允许修改';
                        return ;
                    }
                }
                else{
                    $sql='select * from ld_cashbilldebuctiondetail where cashbillid=? limit 1';
                    
                        $tmpresult=$adb->pquery($sql,array($record));
                        if($adb->num_rows($tmpresult)>0){
                        $this->errorinfo='该单据已有核销,币种不允许修改';
                        return ;
                        }
                }
                
                
            }
            
            if(!empty($Bankaccountsetid)&&$Bankaccountsetid!=$req_bankaccountsetid){
                
                if($cashtype=='debuction')//预收款保存
                {
                    if($$debuctionbalanceamount!=$total)
                    {
                        $this->errorinfo='该单据已有核销,账户名称不允许修改';
                        return ;
                    }
                }
                else{
                    $sql='select * from ld_cashbilldebuctiondetail where cashbillid=? limit 1';
                    
                        $tmpresult=$adb->pquery($sql,array($record));
                        if($adb->num_rows($tmpresult)>0){
                        $this->errorinfo='该单据已有核销,账户名称不允许修改';
                        return ;
                        }
                }
                
                
            }
            if(!is_array($this->debuctioninfos)||$this->debuctioninfos==''){
                return ;
            }

            $rows = 0;
            if(!empty($debuctionids)){
                //编辑界面
                $sql="select ld_cashbill.debuctionbalanceamount,ld_cashbill.cashbillid,
                        ld_cashbilldebuction.amount,ld_cashbill.cashbill_no  from ld_cashbill
            
                    left  JOIN (
                        select sum(amount) as amount,cashbillid,debuctionid
                        from ld_cashbilldebuctiondetail where  cashbillid = ?
                        group by cashbillid,debuctionid ) as ld_cashbilldebuction
                                    
                            on ld_cashbill.cashbillid=ld_cashbilldebuction.debuctionid
                    where   ld_cashbill.cashbillid in (".implode(',',$debuctionids).')';
                        ;//获取编辑的收款单数据库中已收金额
                
                $result=$adb->pquery($sql,array($record));
                $rows=$adb->num_rows($result);
            }
            for($i=0;$i<$rows;$i++){
                $cashbillid=$adb->query_result($result,$i,'cashbillid');//预收款单的ID
                $debuctionbalanceamount=$adb->query_result($result,$i,'debuctionbalanceamount');
                $amount=$adb->query_result($result,$i,'amount');
                
                
                if(empty($amount)){
                    $amount=0;
                }
                if(!array_key_exists($cashbillid,$db_debuctioninfo)){
                    $db_debuctioninfo[$cashbillid]=$debuctionbalanceamount+$amount;
                }
                else
                    $db_debuctioninfo[$cashbillid]=$db_debuctioninfo[$cashbillid]+$amount;
                $db_cashbillnos[$cashbillid]=$adb->query_result($result,$i,'cashbill_no');
            }
        }
          
        foreach($this->debuctioninfos as $debuctionid => $tmpamount)
        {
            if($tmpamount>$db_debuctioninfo[$debuctionid])
            {
                $this->errorinfo="预收".$db_cashbillnos[$cashbillid].'本次收款金额大于可抵扣金额';
                return ;
                //  ConvertTojsonString("-1",array(),$msg);
                
            }
        }
    }
    public function setEcho()
    {
        $_REQUEST['diony']='yes';
        if(empty($this->errorinfo)){
            ConvertTojsonString(1,array(),'success');
        }
        else{
            ConvertTojsonString(-1,array(),$this->errorinfo);;
        }
    }
    /**
     * edit:can 2020-08-31 收款单关联预收单做核销的时，无需控制“银行账户”一致，控制币种一致即可
     * 获取界面选择的币种
     * */
    public function getreqCurrencyId($req_bankaccountid)
    {
        global $adb;
        $req_currency_id=$_REQUEST['currency_id'];
      
        if(empty($req_currency_id)&&!empty($req_bankaccountid))
        {
            $sql='select currency_id from ld_bankaccountset where bankaccountsetid=?';
            $result=$adb->pquery($sql,array($req_bankaccountid));
            return $adb->query_result($result,0,0);
            
        }
        else if(empty($req_currency_id)&&empty($req_bankaccountid))
        {
            return 1;
        }
        
        return $req_currency_id;
    }
    /**
     * xxy 2023-12-28 判断预收单金额和可抵扣金额是否允许录入负数
     * */
    public function checkNegativeValues($total,$debuctioninfo,$cashbilltype)
    {
        $sys_465 = getSys_deploy(465);//系统参数，设置预收单金额和可抵扣金额录入负数时是否允许保存
        $AllowSaveNegativenum = $sys_465['deploy_value'];
        if($AllowSaveNegativenum == 'no'){
            if($cashbilltype == 'debuction'){//预收单实际收款金额
                if($total < 0){
                    $this->errorinfo = getFixedLabel('ActualReceiptsMustGreater0');
                    return 'no';
                }
            }else if($cashbilltype == 'cashbill'){
                $debuctioninfo = Zend_Json::decode($debuctioninfo);
                foreach ($debuctioninfo as $index => $item) {
                    if($item['amount'] < 0){
                        $this->errorinfo = getVarFixedLabel('DeductibleAmountMustGreater0',($index+1));   
                        return 'no';
                    }
                }
            }
        }
        return 'yes';
    }
}
?>