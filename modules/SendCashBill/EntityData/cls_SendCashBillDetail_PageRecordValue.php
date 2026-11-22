<?php
class cls_SendCashBillDetail_PageRecordValue
{
    var $record;
    var $sourceIds;
    var $sourceModule;
    var $sourceFocus;
    var $pageType;
    var $subtotal;
    var $sendcashbill_currency_id;
    /**
     * $record:表示单据收款单单据ID,如果选择的是出库单，销售发票，则是lineitem_id值，因为出库单和销售发票可以选择多个合同信息
     * $pagemode:当前操作方式($pagemode)： 新增create、编辑edit、详细detail、源单模块sourcemodule_create
     * $frommodule：源单模块名称
     * $module:CashBill
     * */
    public function __construct($module, $pagemode, $record, $frommodule,$sendcashbill_currency_id)
    {
        $this->record = $record;//单据id,如果record<=0则表示创建
         if(empty($frommodule))
            {
                crm_load_class_file('cls_OptionModule','include/OptionModule');
                
               $obj= cls_OptionModule::getInstance($module,$record);
                $frommodule=$obj->getcur_sourceModule();
            }
        $this->sourceModule = $frommodule;
        $this->detailView = $detailView;
        $this->pageType=$pagemode;
        $this->record=$record;
        if($pagemode=='sourcemodule_create')
        {
            $sourceIds = explode(',', $record);
            $sourceIds = array_filter(array_unique($sourceIds));
            $this->sourceIds = implode(',', $sourceIds);
            $this->pageType='select_source';
            
        }
        $this->createSourceFocus();
       $this->sendcashbill_currency_id=$sendcashbill_currency_id;
        
        
    }
    public function createSourceFocus()
    {
         $this->source_focus = CRMEntity::getInstance($this->sourceModule);
    }
    public function getDetailHeader()
    {
            if(sizeof($this->table_header)>0)
            {
                return $this->table_header;
            }
        
           $this->table_header[] = array('fieldlabel'=>getFixedLabel("SOURCETYPE")
                                    ,'columnname'=>'tranmodule','edit_permission'=>1
                                    ,'fieldtype'=>'Span','tablename'=>'ld_cashbill'
                                    ,'typedata'=>'V~O','input_type'=>'0','selectmodule'=>'');
        $this->table_header[] = array('fieldlabel'=> getFixedLabel("ORIGNALBILL")
                                    ,'columnname'=>'href_columnname','edit_permission'=>1
                                    ,'fieldtype'=>'Span','tablename'=>'ld_cashbill'
                                    ,'typedata'=>'V~O','input_type'=>'0','selectmodule'=>'');
                                    
        if($this->sourceModule=='SendPayment')
        {
             $this->table_header[] = array('fieldlabel'=>$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname",'cpperiodtime','fieldlabel')
            ,'columnname'=>'cpperiodtime','edit_permission'=>1,'typedata'=>'V~O','input_type'=>0,'tablename'=>'ld_sendpayment','selectmodule'=>'');
           
            $this->table_header[] =array('fieldlabel'=>$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname",'plandate','fieldlabel')
                                        ,'columnname'=>'plandate','edit_permission'=>1,'typedata'=>'D~O'
                                        ,'input_type'=>0,'tablename'=>'ld_sendpayment','selectmodule'=>'','fieldtype'=>'Span') ;
                                        
           
            
        }
        else
        {
             if($this->sourceModule=='PurchaseOrder')
            {
                $this->table_header[]=array('fieldlabel'=>$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname",'signed_data','fieldlabel')
                                                   ,'columnname'=>'billdate','edit_permission'=>1,'typedata'=>'V~O'
                                                   ,'input_type'=>0,'tablename'=>'ld_salesorder','selectmodule'=>'','fieldtype'=>'Span');
                
            }
            else if($this->sourceModule=='PurchaseInvoice')
            {
                $this->table_header[]= array('fieldlabel'=>$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname",'purchaseinvoicedate','fieldlabel')
                                                   ,'columnname'=>'billdate','edit_permission'=>1,'typedata'=>'D~O'
                                                   ,'input_type'=>0,'tablename'=>'ld_salesorder','selectmodule'=>'','fieldtype'=>'Span') ;
                                                   
            }
            else if($this->sourceModule=='Stock')
            {
                $this->table_header[]=array('fieldlabel'=> $this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname",'createdate','fieldlabel')
                                                   ,'columnname'=>'billdate','edit_permission'=>1,'typedata'=>'D~O'
                                                   ,'input_type'=>0,'tablename'=>'ld_salesorder','selectmodule'=>'','fieldtype'=>'Span');
                                                   
               
            }
        }
         $this->table_header[]=  array('fieldlabel'=>getFixedLabel("AMOUNT")
                                     ,'columnname'=>'total','edit_permission'=>1
                                    ,'fieldtype'=>'Span','tablename'=>'ld_sendcashbill'
                                    ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'');//金额
         
        if($this->sourceModule=='PurchaseOrder')
        {
            if(vtlib_isModuleActive('PurchaseInvoice'))
            {
                  $this->table_header[] =array('fieldlabel'=>getFixedLabel("THENEWINVOICEDATE")
                                                        ,'columnname'=>'invoicedate','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_sendcashbill'
                                                        ,'typedata'=>'D~O','input_type'=>'0','selectmodule'=>'') ;//最近开票日期
                $this->table_header[] = array('fieldlabel'=>getFixedLabel("HASBILLINGAMOUNT")
                                                        ,'columnname'=>'invoicetotal','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_sendcashbill'
                                                        ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'');//已开票总额
                                                        
             
            }
            $this->table_header[] =array('fieldlabel'=> getFixedLabel('CONTRACTLATESTDATEOFPAYMENT')
                                                        ,'columnname'=>'lastsendcashbilldate','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_sendcashbill'
                                                        ,'typedata'=>'D~O','input_type'=>'0','selectmodule'=>'');//最近付款日期
                                                       
            $this->table_header[] =array('fieldlabel'=> getFixedLabel("CONTRACTPAIDTOTALAMOUNT")
                                                        ,'columnname'=>'pay_amount','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_sendcashbill'
                                                        ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'');
                                                        
           
        }
         else if($this->sourceModule=='SendPayment')
         {
            $this->table_header[] =array('fieldlabel'=> getFixedLabel("PAIDTOTALAMOUNT")
                                                        ,'columnname'=>'pay_amount','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_paymentplan'
                                                        ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'');//已符总额
                                                         
            $this->table_header[] =array('fieldlabel'=> getFixedLabel("CONTRACTINFO")
                                                        ,'columnname'=>'contractinfo','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_sendpayment'
                                                        ,'typedata'=>'V~O','input_type'=>'0','selectmodule'=>'');//合同信息
             
            $this->table_header[] =array('fieldlabel'=> getFixedLabel("SALESORDERCONTRACTAMOUNT")
                                                        ,'columnname'=>'contractamount','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_sendpayment'
                                                        ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'');//合同金额
             $this->table_header[]=array('fieldlabel'=> getFixedLabel("CONTRACTPAIDTOTALAMOUNT")
                                                        ,'columnname'=>'contract_pay_amount','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_sendpayment'
                                                        ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'');
  
                                                         
            $this->table_header[] =array('fieldlabel'=> getFixedLabel("THENEWINVOICEDATE")
                                                        ,'columnname'=>'invoicedate','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_sendpayment'
                                                        ,'typedata'=>'D~O','input_type'=>'0','selectmodule'=>'');//最近开票日期
                                                         
            $this->table_header[] =array('fieldlabel'=> getFixedLabel("HASBILLINGAMOUNT")
                                                        ,'columnname'=>'invoicetotal','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_sendpayment'
                                                        ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'');//已开票总额
                                                         
            $this->table_header[] = array('fieldlabel'=> getFixedLabel("CONTRACTLATESTDATEOFPAYMENT")
                                                        ,'columnname'=>'lastsendcashbilldate','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_sendpayment'
                                                        ,'typedata'=>'D~O','input_type'=>'0','selectmodule'=>'');//最近收款日期
         }
         else
         {
            $this->table_header[]=array('fieldlabel'=> getFixedLabel("PAIDTOTALAMOUNT")
                                                        ,'columnname'=>'pay_amount','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_sendpayment'
                                                        ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'');
            
         }
       
         $this->table_header[]=array('fieldlabel'=> getFixedLabel("THEAMOUNTPAYMENT")
                                                        ,'columnname'=>'now_sendcashbill_money','edit_permission'=>0
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_sendpayment'
                                                        ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'');
                                                                                         
    }
    /**
     * 获取明细行数据
     * 
     * */
     public function getrowDetailValueByDetailId($detailid,$sequenceno='0')
    {
         global $adb;
         $this->getDetailHeader();
         $sql='select entitytype from ld_sendcashbill2payment  where sendcashbill2payment_id=?  ';
         $result=$adb->pquery($sql,array($detailid));
         $this->sourceModule=$adb->query_result($result,0,0);
         
         crm_load_class_file('cls_SendCashBill_Parent_EnitytData','modules/SendCashBill/EntityData');
        
        $cashbillobj= cls_CashBill_Parent_EnitytData::getInstance($this->sourceModule,$this->sourceIds,'detailrowvalue',$detailid);
        $data = $cashbillobj->getData();
            
         $ret_values=$this->formateDataValues($data);
        $ret_values=$ret_values[0];
         return $ret_values;
         
    }
    public function getvalues()
    {
        $this->getDetailHeader();
           crm_load_class_file('cls_SendCashBill_Parent_EntityData','modules/SendCashBill/EntityData');
        $sourmodules= getSourceModule('SendCashBill');
         if(empty($this->sourceModule))
         {
            //24516: 销售发票：设置某个用户没有服务合同模块的权限，该用户新建销售发票选择源单类型时仍然显示服务合同
            foreach($sourmodules as $entitytypeinfo)
            {
                if($entitytypeinfo['default']==1)
                {
                    $this->sourceModule=$entitytypeinfo['entitytype'];
                    break;
                }
                else
                {
                    $this->sourceModule=$sourmodules[0]['entitytype'];
                }
            }
            if(sizeof($sourmodules)<=0)
            {
                $this->sourceModule='PurchaseOrder';
            }
         }
      
        if($this->sourceModule=='PurchaseOrder'){
            crm_load_class_file('cls_PurchaseOrder_EntityData','modules/SendCashBill/EntityData');
            $obj=new cls_PurchaseOrder_EntityData($this->record,$this->sourceIds,$this->pageType);
        }
        else if($this->sourceModule=='PurchaseInvoice')
        {
            
            crm_load_class_file('cls_PurchaseInvoice_EntityData','modules/SendCashBill/EntityData');
            $obj=new cls_PurchaseInvoice_EntityData($this->record,$this->sourceIds,$this->pageType);
        }
        else if($this->sourceModule=='Stock')
        {
            crm_load_class_file('cls_Stock_EntityData','modules/SendCashBill/EntityData');
            $obj=new cls_Stock_EntityData($this->record,$this->sourceIds,$this->pageType);
        }
        else if($this->sourceModule=='SendPayment')
        {
            crm_load_class_file('cls_SendPayment_EntityData','modules/SendCashBill/EntityData');
            $obj=new cls_SendPayment_EntityData($this->record,$this->sourceIds,$this->pageType);
        }
        else
        {
            crm_load_class_file('cls_'.$this->sourceModule.'_EntityData','modules/SendCashBill/EntityData');
            $classname='cls_'.$this->sourceModule.'_EntityData';
            $obj=new $classname($this->record,$this->sourceIds,$this->pageType);
        }
        $data=$obj->getData();
   
        $i=0;
        foreach ($data as $index => $row_data) 
        {
           
           
            foreach ($this->table_header as $tmpindex =>  $info) {
                    $columnname=$info['columnname'];
                    
                    $value = $row_data[$columnname];
                   
                    $hiddenvalue=$value;
                     $parentmodule='';   
                    if($columnname=='href_columnname')
                    {
                         $hiddenvalue=$row_data['sourceid'];
                       $parentmodule=$this->sourceModule;
                            
                    }
                    else if($columnname=='total'||$columnname=='pay_amount')
                    {
                        $value=decode_html($row_data['currency_symbol']).setNumberFormat($value);
                      
                    }
                     else if($columnname=='contractinfo')//合同信息
                    {
                        //源单的合同信息（目前只有付款计划）
                         if($row_data['contractinfo']=='')
                            $value='';
                         else{
                                $parentmodule=$row_data['contract_module'];
                                $hiddenvalue=$row_data['contractid'];;
                                
                            }
                    }
                    else if($columnname=='contractamount'||$columnname=='contract_pay_amount'||$columnname=='invoicetotal')
                    {
                         if($row_data['contractinfo']=='')
                            $value='';
                         else
                            $value=decode_html($row_data['contract_currency_symbol']).setNumberFormat($value);
                    }
                    else if($columnname=='now_sendcashbill_money')
                    {
                            if($this->pageType=='select_source' )
                            {
                                 $currency_id=$row_data['currency_id'];//原单币种id
                                
                                 $cashbill_currency_id=$this->sendcashbill_currency_id;//收款单币种id
                                 if($currency_id!=$cashbill_currency_id)
                                   {
                                      $currency_obj=new Currency($adb,$cashbill_currency_id);
                                      $changeCurrency_obj=new Currency($adb,$currency_id);
                                     $value=$currency_obj->ConvertTothisobj_money($changeCurrency_obj,$value);
                                   }
                                 
                            }
                        
                    }
                    $ret_values[$i][$columnname]=array('value'=>$value,'hiddenvalue'=>$hiddenvalue,'option'=>'','parentmodule'=>$parentmodule);
                    $ret_values[$i]['detailid']=$row_data['detailid'];
                    $ret_values[$i]['sourceid']=$row_data['sourceid'];
                    $ret_values[$i]['contract_module']=$row_data['contract_module'];
                    $ret_values[$i]['contractid']=$row_data['contractid'];
                }
                $i++;
         }
        
          
        
         return array('headers'=>$this->table_header,'value'=>$ret_values,'AddProductBtn'=>'no'
         ,'defaultRows'=>sizeof($data),'subtotalvalue'=>'','lastRowValue'=>$this->getLastRow_Value());
         
         
         
    }
    
    public function getLastRow_Value()
    {
        if($this->pageType=='select_source')
        {
            $total=$this->subtotal;
        }
        else
        {
            $focus=CRMEntity::getInstance('SendCashBill');
            $fieldname=$focus->fieldobj->getFieldInfoBykeyValue('columnname','total','fieldname');
            $fieldlabel=$focus->fieldobj->getFieldInfoBykeyValue('columnname','total','fieldlabel');
            $total=$focus->column_fields[$fieldname];
        }
        $arr[]=array('value'=>$total,'fieldname'=>$fieldname,'fieldlabel'=>$fieldlabel);
        return $arr;
    }
    
   
}
?>