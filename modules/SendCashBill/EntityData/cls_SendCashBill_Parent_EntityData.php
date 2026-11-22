<?php
class cls_SendCashBill_Parent_EntityData
{
     var $sourceModule;
     var $record;
     var $sourceids;
     var $href_columnname;//源单超链接字段
     var $href_table_name;//原单超链接字段表名称
     public function __construct($record,$sourceids,$pageType)
    {
        $this->record=$record;
        $this->pageType=$pageType;
        $this->sourceids=$sourceids;
        
         $entitynames=getEntitynameByModulename($this->sourceModule);
         $this->href_columnname = $entitynames['fieldname'];
         $this->href_table_name = $entitynames['tablename'];
  	
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
    public function getsendCashBillDate($result,$i)
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
            //选择源单（第二次后多次)
          $sql=$this->getselect_source_Sql();
          
          $result=$adb->pquery($sql,array());
            
        }
        else if($this->pageType=='relate_create')
        {
            //相关信息创建
            $sql=$this->getrelated_createSql();

            $result=$adb->pquery($sql,array());
        }
        else if($this->pageType=='create')
        {
            //创建页面不不要获取数据
        }
        else if($this->pageType=='detailview'||$this->pageType=='edit')
        {
            //查看，编辑
        
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
            $data[$i]['tranmodule']=getTranstab($this->sourceModule);
            $data[$i]['href_columnname']=$adb->query_result($result,$i,'href_columnname');
            $data[$i]['total']=$adb->query_result($result,$i,'total');
            $data[$i]['billdate']=$adb->query_result($result,$i,'billdate');
            $data[$i]['plandate']=$this->getPlandate($result,$i);
            $data[$i]['cpperiodtime']=$this->getPeriodtime($result,$i);
            $data[$i]['currency_symbol']=$adb->query_result($result,$i,'currency_symbol');
            $data[$i]['currency_id']=$adb->query_result($result,$i,'currency_id');
            $data[$i]['conversion_rate']=$adb->query_result($result,$i,'conversion_rate');
            $data[$i]['pay_amount']=$adb->query_result($result,$i,'pay_amount');
             $data[$i]['invoicedate']=$this->getInvoiceDate($result,$i);
            $data[$i]['invoicetotal']=$this->getInvoicetotal($result,$i);
            $data[$i]['lastsendcashbilldate']=$this->getsendCashBillDate($result,$i);
            $data[$i]['contractid']=$this->getContractid($result,$i);
            $data[$i]['contractinfo']=$this->getContractinfo($result,$i);
            $data[$i]['contractamount']=$this->getContractAmount($result,$i);
            $data[$i]['contract_pay_amount']=$this->getContractPay_Amount($result,$i);
            $contract_currencyifo=$this->getContractCurrencyInfo($result,$i);
            $data[$i]['contract_currency_symbol']=$contract_currencyifo['bol'];
            $data[$i]['contract_currency_id']=$contract_currencyifo['id'];
           $data[$i]['contract_conversion_rate']=$contract_currencyifo['rate'];
            $data[$i]['now_sendcashbill_money']=$adb->query_result($result,$i,'now_sendcashbill_money');;
            $data[$i]['detailid']=$adb->query_result($result,$i,'detailid');
        }
        return $data;
        
    }
}