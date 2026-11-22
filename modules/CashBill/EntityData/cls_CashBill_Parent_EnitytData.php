<?php
class cls_CashBill_Parent_EnitytData
{
     var $sourceModule;
     var $record;
     var $sourceids;
     var $pageType;

     var $cashbill_focus;
     public static function getInstance($sourceModule,$sourceIds,$pageType,$record)
     {
         //cls_CashBill_Parent_EntityData
        
        $sourmodules = getSourceModule('CashBill');
        
        foreach($sourmodules as $val){
            $modules[] = $val['entitytype'];
        }
        if (empty($sourceModule)||!in_array($sourceModule,$modules)) {
            //24516: 销售发票：设置某个用户没有服务合同模块的权限，该用户新建销售发票选择源单类型时仍然显示服务合同
            foreach ($sourmodules as $entitytypeinfo) {
                if ($entitytypeinfo['default'] == 1) {
                    $sourceModule = $entitytypeinfo['entitytype'];
                    break;
                } else {
                    $sourceModule = $sourmodules[0]['entitytype'];
                }
            }
        }
   
        if ($sourceModule == 'SalesOrder') {
            //cls_SalesOrder_EntityData
            crm_load_class_file('cls_SalesOrder_EntityData', 'modules/CashBill/EntityData');
            $obj = new cls_SalesOrder_EntityData($record, $sourceIds, $pageType);
        } else if ($sourceModule == 'Invoice') {
            crm_load_class_file('cls_Invoice_EntityData', 'modules/CashBill/EntityData');
            $obj = new cls_Invoice_EntityData($record, $sourceIds, $pageType);
        } else if ($sourceModule == 'ServiceContracts') {
            crm_load_class_file('cls_ServiceContracts_EntityData', 'modules/CashBill/EntityData');
            $obj = new cls_ServiceContracts_EntityData($record, $sourceIds, $pageType);
        } else if ($sourceModule == 'PaymentPlan') {
            crm_load_class_file('cls_Payment_EntityData', 'modules/CashBill/EntityData');
            $obj = new cls_Payment_EntityData($record, $sourceIds, $pageType);
        } else if ($sourceModule == 'OutboundOrder') {
            crm_load_class_file('cls_OutboundOrder_EntityData', 'modules/CashBill/EntityData');
            $obj = new cls_OutboundOrder_EntityData($record, $sourceIds, $pageType);
        } else {
            crm_load_class_file('cls_' . $sourceModule . '_EntityData', 'modules/SendCashBill/EntityData');
            $classname = 'cls_' . $sourceModule . '_EntityData';
            $obj = new $classname($record, $sourceIds, $pageType);
        }
        if (sizeof($sourmodules) <= 0) {
                $obj->sourceModule = 'SalesOrder';
            }
        return $obj;
     }
     public function __construct($record,$sourceids,$pageType)
    {
        $this->record=$record;
        $this->pageType=$pageType;
        $this->sourceids=$sourceids;
        $entitynames=getEntitynameByModulename($this->sourceModule);
        $this->href_columnname = $entitynames['fieldname'];

         $this->href_table_name = $entitynames['tablename'];
         
		$this->cashbill_focus = CRMEntity::getInstance('CashBill');

        
    }
     public function getContractmodule($return,$i)
     {
       return "";
     }
    public function getContractinfo($result,$i)
    {
        return "";
    }
    /**
     * 
     * 获取合同Id
     * */
    public function getContractid($result,$i)
    {
        return 0;
    }
    /**
     * 最近开票日期
     * */
    public function getInvoiceDate($result,$i)
    {
      return '';
    }
    /**
     * 最近收款日期
     * 
     * */
    public function getCashBillDate($result,$i)
    {
        return '';
    }
    /**
     * 已开票总额
     * */
    public function getInvoicetotal($result,$i)
    {
       return '0';
    }
  
    public function getPeriodtime($result,$i)
    {
        
        return '';
    }
    public function getPlandate($result,$i)
    {
        return '';
    }
    public function getResult()
    {
        global $adb;
        
        if( $this->pageType=='select_source')
        {
          $sql=$this->getselect_source_Sql();
          $result=$adb->pquery($sql,array());
            
        }
        else if($this->pageType=='relate_create')
        {
            $sql=$this->getrelated_createSql();
            $result=$adb->pquery($sql,array());
        }
        else if($this->pageType=='create')
        {
            //创建页面不不要获取数据
        }
        else if($this->pageType=='detailview'||$this->pageType=='edit')
        {
            $sql=$this->getdetail_editSql();
             $result=$adb->pquery($sql,array());
        }
        else if($this->pageType=='module_create')
        {
            $sql=$this->getmoduleCreateSql();
             $result=$adb->pquery($sql,array());
        }
        else if($this->pageType=='detailrowvalue')
        {
           
            $sql=$this->getrowValueByDetailidSql();
             $result=$adb->pquery($sql,array());
        }
        return $result;
    }
    /**
     * 手机端的管理创建
     * */
    public function getmoduleCreateSql()
    {
         $this->sourceids=$this->record;
         return  $this->getselect_source_Sql();
    }
    public function getData()
    {
        global $adb;
        $result=$this->getResult();
        $rows=$adb->num_rows($result);
       
        for($i=0;$i<$rows;$i++)
        {
            $data[$i]['sourceid']=$adb->query_result($result,$i,'selectsourceid');
            $data[$i]['detailid']=$adb->query_result($result,$i,'detailid');
            $data[$i]['tranmodule']=getTranstab($this->sourceModule);
            $data[$i]['href_columnname']=$adb->query_result($result,$i,'href_columnname');
            $data[$i]['plandate']=$this->getPlandate($result,$i);
            $data[$i]['periodtime']=$this->getPeriodtime($result,$i);
            
			$data[$i]['billdate']=$adb->query_result($result,$i,'billdate');
            $data[$i]['total']=$adb->query_result($result,$i,'total');
            $data[$i]['currency_symbol']=$adb->query_result($result,$i,'currency_symbol');
            $data[$i]['currency_id']=$adb->query_result($result,$i,'currency_id');
            $data[$i]['conversion_rate']=$adb->query_result($result,$i,'conversion_rate');
            $data[$i]['received_amount']=$adb->query_result($result,$i,'received_amount');
            $data[$i]['invoicedate']=$this->getInvoiceDate($result,$i);
            $data[$i]['invoicetotal']=$this->getInvoicetotal($result,$i);
            $data[$i]['lastcashbilldate']=$this->getCashBillDate($result,$i);
             $data[$i]['contractid']=$this->getContractid($result,$i);
            $data[$i]['contractinfo']=$this->getContractinfo($result,$i);
            $data[$i]['contract_module']=$this->getContractmodule($result,$i);
            $data[$i]['contractamount']=$this->getContractAmount($result,$i);
            $data[$i]['contract_receive_amount']=$this->getContract_Receive_Amount($result,$i);
            $contract_currencyifo=$this->getContractCurrencyInfo($result,$i);
            $data[$i]['contract_currency_symbol']=$contract_currencyifo['bol'];
            $data[$i]['contract_currency_id']=$contract_currencyifo['id'];
            $data[$i]['contract_conversion_rate']=$contract_currencyifo['rate'];
           
            
            $data[$i]['now_cashbill_money']=$adb->query_result($result,$i,'now_cashbill_money');
            
        }
        
        return $data;
        
    }
}