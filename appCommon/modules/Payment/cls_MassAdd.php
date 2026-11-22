<?php
/**
 *  新增合同订单服务合同创建回款计划
 *  editor:xxs date:2017-08-22
 */

class cls_MassAdd{
    public $record;     //合同订单id
    public $frommodule;
    public $fromfocus;
    public $sourceinfo;     //合同订单字段信息
    public $total;      //合同订单总金额
    
	public function __construct($record,$frommodule){
	    $this->record = $record;
        $this->frommodule = $frommodule;
        $this->fromfocus = CRMEntity::getInstance($frommodule);
	}
    
    public function masssave(){
        global $current_user;
        
        $sourceinfo = $this->getSourceInfo();
        $setPaymentarr = explode(',',$this->getPaymentPlanSetting());
        
        $paymentstatus="未收";
        $currenttime = date('Y-m-d H:i:s',time());
       // $setsystem = getSys_deploy(53);
        $sys_deploy_value = $setsystem['deploy_value']=2;
        $plandate = '';
        $projectstatus = '';
        $salesorderamount = $sourceinfo['total'];
        unset($sourceinfo['total']);
        
        if($sys_deploy_value==2){
            $plandate=date("Y-m-d");
            $monthlastday = DateOperation::getMonthDays($plandate);//获取当月的总天数
        }elseif($sys_deploy_value==1){
            $projectstatusstr = $this->getProjectStatusStr();
            $projectstatusarr = explode(',',$projectstatusstr);
        }
        
        foreach($setPaymentarr as $key=>$percents){
            if($sys_deploy_value==2){
                if($monthlastday == date('d')){
        			$nextMonth = DateOperation::getNextMonthDays($plandate);
        			$plandate = $nextMonth[1];
        		}else{
        			$plandate=date("Y-m-d", strtotime("+$key month"));
        		}
            }elseif($sys_deploy_value==1){
                $projectstatus = $projectstatusarr[$key];
            }
            $amount = $salesorderamount*$percents/100;
            
            $cols['paymentplan_no'] = "#:#:#:#:#";
            $cols['amount'] = sprintf("%.2f",$amount);
            $cols['plandate'] = $plandate;
            $cols['paymenttype'] = '计划回款日期';
            $cols['projectstatus'] = $projectstatus;
            $cols['periodtime'] = $key+1;
            $cols['paymentstatus'] = $paymentstatus;
            $cols['smcreatorid'] = $current_user->id;
            $cols['createdtime'] = $cols['modifiedtime'] = $currenttime;
            $column[] = array('ld_crmentity'=>array('setype'=>'PaymentPlan'),'ld_paymentplan'=>array_merge($cols,$sourceinfo),"ld_paymentplanscf"=>array('paymentplanid'=>''));
        }

        $focus=CRMEntity::getInstance('PaymentPlan');
        //移动端合同订单保存后创建回款计划时带出引用字段
        crm_load_class_file('cls_ParentRelatedField_Data','include/RelatedField');
        //带出合同订单单据的引用字段
        $cls_ParentRelatedFields = new cls_ParentRelatedField_Data('PaymentPlan',$this->record,'');
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
        //带出客户单据的引用字段
        if($sourceinfo['accountid']>0){
            $cls_ParentRelatedFields = new cls_ParentRelatedField_Data('PaymentPlan',$sourceinfo['accountid'],'');
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
        }
        
        $focus->MassSave(array("ld_paymentplan"=>"PaymentPlan"),$column);
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
        $sourceinfo['accountid'] = $this->fromfocus->column_fields['account_id'];
        $sourceinfo['entitytype'] = $this->frommodule;
        $sourceinfo['entitytypeid'] = $this->record;
        $sourceinfo['total'] = $this->fromfocus->column_fields['hdnGrandTotal'];
        return $sourceinfo;
    }
    
    //system_53:2
    protected function getPaymentPlanSetting(){
        if(file_exists(globalStatic::$root_directory.'user_privileges/ConfigCashBillSet.php')){
            require_once(globalStatic::$root_directory."user_privileges/ConfigCashBillSet.php");
            $paymentsetting = $PaymentPlanSetting;
        }else{
            $paymentsetting = '30,50,20';
        }
        return $paymentsetting;
    }
    
    //system_53:1
    protected function getProjectStatusStr(){
        //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 上午 11:29
        crm_load_class_file("cls_PickList", 'modules/PickList');
        $objpinklist = new cls_PickList();
        $result_pick = $objpinklist->getPickListValues('projectstatus');
        $pliststr = '';
        foreach($result_pick as $key=>$value){
            $pliststr.=$value.',';
        }
        return $pliststr;
        /*global $adb;
        $sqllist='SELECT DISTINCT projectstatus FROM ld_projectstatus WHERE presence=1 order by projectstatusid asc';
        $plistresult=$adb->pquery($sqllist,array());
        $plistrow = $adb->num_rows($plistresult);
        for($i=0;$i<$plistrow;$i++){
            $plistarr[] = $adb->query_result($plistresult,$i,'projectstatus');
            $pliststr.=$adb->query_result($plistresult,$i,'projectstatus').',';
        }
        return $pliststr;*/
    }
    
}
?>