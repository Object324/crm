<?php
/**
 *  新增采购订单创建付款计划
 *  editor:xxs date:2017-09-16
 */

class cls_MassAdd{
    public $record;     //采购订单id
    public $frommodule;
    public $fromfocus;
    public $sourceinfo;     //采购订单字段信息
    public $total;      //采购订单总金额
    
	public function __construct($record,$frommodule){
	    $this->record = $record;
        $this->frommodule = $frommodule;
        $this->fromfocus = CRMEntity::getInstance($frommodule);
	}
    
    public function masssave(){
        global $current_user;
        
        $sourceinfo = $this->getSourceInfo();
        $setPaymentarr = explode(',',$this->getSendPaymentSetting());
        
        $paymentstatus="未付";
        $currenttime = date('Y-m-d H:i:s',time());
        
        $plandate = '';
        $purchaseorderamount = $sourceinfo['total'];
        unset($sourceinfo['total']);
        
        $plandate=date("Y-m-d");
        $monthlastday = DateOperation::getMonthDays($plandate);//获取当月的总天数
       
        foreach($setPaymentarr as $key=>$percents){
            if($monthlastday == date('d')){
    			$nextMonth = DateOperation::getNextMonthDays($plandate);
    			$plandate = $nextMonth[1];
    		}else{
    			$plandate=date("Y-m-d", strtotime("+$key month"));
    		}

            $amount = $purchaseorderamount*$percents/100;
            
            $cols['sendpayment_no'] = "#:#:#:#:#";
            $cols['amount'] = sprintf("%.2f",$amount);
            $cols['plandate'] = $plandate;
            $cols['cpperiodtime'] = $key+1;
            $cols['cpstatus'] = $paymentstatus;
            $cols['smcreatorid'] = $current_user->id;
            $cols['createdtime'] = $cols['modifiedtime'] = $currenttime;
            $column[] = array('ld_crmentity'=>array('setype'=>'SendPayment'),'ld_sendpayment'=>array_merge($cols,$sourceinfo),'ld_sendpaymentscf'=>array('sendpaymentid'=>''));
        }

        $focus=CRMEntity::getInstance('SendPayment');
        //edit:duan 2022-5-31 移动端采购订单保存后创建付款计划时带出引用字段
        crm_load_class_file('cls_ParentRelatedField_Data','include/RelatedField');
        //采购订单单据引用字段
        $cls_ParentRelatedFields = new cls_ParentRelatedField_Data('SendPayment',$this->record,'');
        $relatedfielddata=$cls_ParentRelatedFields->getEffectValues('html_input');
        foreach($relatedfielddata  as $relateinfo)
        {
            $rawvalue_arr=$relateinfo['rawValue'];
            $fieldname=$rawvalue_arr['input_name'];
            $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
            if($fieldinfo&&$fieldinfo->getSaveDataBase()=='yes')
            {
                foreach($column as $key =>$value){
                    $column[$key][$fieldinfo->getTableName()][$fieldinfo->getColumnName()]=$rawvalue_arr['value'];
                }
            }
            
        }
        //供应商单据引用字段
        if($sourceinfo['vendorid'] >0){
            $cls_ParentRelatedFields = new cls_ParentRelatedField_Data('SendPayment',$sourceinfo['vendorid'],'');
            $relatedfielddata=$cls_ParentRelatedFields->getEffectValues('html_input');
            //edit:can 20210331 45234: （http://42.193.112.228:85/crm [^])；客户—北京永和嘉业房地产经纪有限公司；付款计划单据中两个引用字段“房东联系方式” “房源名称” 引用失败
            foreach($relatedfielddata  as $relateinfo)
            {
                $rawvalue_arr=$relateinfo['rawValue'];
                $fieldname=$rawvalue_arr['input_name'];
                $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
                if($fieldinfo&&$fieldinfo->getSaveDataBase()=='yes')
                {
                    foreach($column as $key =>$value){
                        $column[$key][$fieldinfo->getTableName()][$fieldinfo->getColumnName()]=$rawvalue_arr['value'];
                    }
                }
            }
        }
        
        
        $focus->MassSave(array("ld_sendpayment"=>"SendPayment",'ld_sendpaymentscf'=>'SendPayment'),$column);
    }
    
    protected function getSourceInfo(){
        $this->fromfocus->retrieve_entity_info($this->record,$this->frommodule);
        //0029762: 微信端：服务合同新增保存后，自动创建保存的回款计划单据“负责人”字段值为空
        $fieldinfo=$this->fromfocus->fieldobj->getFieldInfoobjBykey('columnname',$this->fromfocus->getSmownerColumName());
        $sourceinfo['smownerid'] = $this->fromfocus->column_fields[$fieldinfo->getFieldName()];
        $sourceinfo['currency_id'] = $this->fromfocus->column_fields['currency_id'];
        $currencyobj=Currency::getInstance($adb,$currency_id);
        $sourceinfo['conversion_rate'] = $currencyobj->getCurrencyRate();
        $sourceinfo['currency_symbol'] = decode_html($currencyobj->getCurrencySymbol());
        $sourceinfo['vendorid'] = $this->fromfocus->column_fields['vendor_id'];
        $sourceinfo['purchaseorder_id'] = $this->record;
        $sourceinfo['total'] = $this->fromfocus->column_fields['hdnGrandTotal'];
        return $sourceinfo;
    }
    
    protected function getSendPaymentSetting(){
        if(file_exists(globalStatic::$root_directory.'user_privileges/ConfigSendPaymentSet.php')){
            require_once(globalStatic::$root_directory."user_privileges/ConfigSendPaymentSet.php");
            $sendpaymentsetting = $SendPaymentSetting;
        }else{
            $sendpaymentsetting = '30,50,20';
        }
        return $sendpaymentsetting;
    }
    
}
?>