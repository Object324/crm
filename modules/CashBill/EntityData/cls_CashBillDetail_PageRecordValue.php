<?php
class cls_CashBillDetail_PageRecordValue
{
    var $record;
    var $sourceIds;
    var $sourceModule;
    var $sourceFocus;
    var $pageType;
    var $subtotal;
    var $cashbill_currency_id;
    public $module;
    /**
     * $record:表示单据收款单单据ID,如果选择的是出库单，销售发票，则是lineitem_id值，因为出库单和销售发票可以选择多个合同信息
     * $pagemode:当前操作方式($pagemode)： 新增create、编辑edit、详细detail、源单模块sourcemodule_create
     * $frommodule：源单模块名称
     * $module:CashBill
     * */
    public function __construct($module, $pagemode, $record, $frommodule,$cashbill_currency_id=1)
    {
        $this->record = $record;//单据id,如果record<=0则表示创建
        $this->module = $module;
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
       $this->cashbill_currency_id=$cashbill_currency_id;
        
        
    }
    public function createSourceFocus()
    {
         $this->source_focus = CRMEntity::getInstance($this->sourceModule);
    }
    public function getDetailHeader()
    {
        $this->table_header[] = array('fieldlabel'=>getFixedLabel("SOURCETYPE")
                                    ,'columnname'=>'tranmodule','edit_permission'=>1
                                    ,'fieldtype'=>'Span','tablename'=>'ld_cashbill'
                                    ,'typedata'=>'V~O','input_type'=>'0','selectmodule'=>'');
        $this->table_header[] = array('fieldlabel'=> getFixedLabel("ORIGNALBILL")
                                    ,'columnname'=>'href_columnname','edit_permission'=>1
                                    ,'fieldtype'=>'Span','tablename'=>'ld_cashbill'
                                    ,'typedata'=>'V~O','input_type'=>'0','selectmodule'=>'');
                                    
        if ($this->sourceModule == 'PaymentPlan') {
            $fieldlabel=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname", 'periodtime', 'fieldlabel');
            $referencefieldname=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname", 'periodtime', 'fieldname');
            $this->table_header[] = array('fieldlabel'=>$fieldlabel,'referencefieldname'=>$referencefieldname
            ,'columnname'=>'periodtime','edit_permission'=>1,'typedata'=>'V~O','input_type'=>0,'tablename'=>'ld_paymentplan','selectmodule'=>'');
           $fieldlabel=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname", 'plandate', 'fieldlabel');
            $referencefieldname=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname", 'plandate', 'fieldname');
            $this->table_header[] =array('fieldlabel'=>$fieldlabel,'referencefieldname'=>$referencefieldname
                                        ,'columnname'=>'plandate','edit_permission'=>1,'typedata'=>'V~O'
                                        ,'input_type'=>0,'tablename'=>'ld_paymentplan','selectmodule'=>'','fieldtype'=>'Span') ;
        } else {
            if ($this->sourceModule == 'SalesOrder') {
                $fieldlabel=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname", 'signed_data', 'fieldlabel');
                $referencefieldname=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname", 'signed_data', 'fieldname');
                
                $this->table_header[] =array('fieldlabel'=>$fieldlabel
                                                   ,'columnname'=>'billdate','edit_permission'=>1,'typedata'=>'V~O','referencefieldname'=>$referencefieldname
                                                   ,'input_type'=>0,'tablename'=>'ld_salesorder','selectmodule'=>'','fieldtype'=>'Span') ;
            } else if ($this->sourceModule == 'Invoice') {
                $fieldlabel=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname", 'invoicedate', 'fieldlabel');
                $referencefieldname=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname", 'invoicedate', 'fieldname');
                $this->table_header[] = array('fieldlabel'=>$fieldlabel,'referencefieldname'=>$referencefieldname
                                                   ,'columnname'=>'billdate','edit_permission'=>1,'typedata'=>'D~O'
                                                   ,'input_type'=>0,'tablename'=>'ld_salesorder','selectmodule'=>'','fieldtype'=>'Span') ;
                                                   
                
            } else if ($this->sourceModule == 'ServiceContracts') {
                $fieldlabel=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname", 'due_date', 'fieldlabel');
                $referencefieldname=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname", 'due_date', 'fieldname');
                $this->table_header[] = array('fieldlabel'=>$fieldlabel,'referencefieldname'=>$referencefieldname
                                                   ,'columnname'=>'billdate','edit_permission'=>1,'typedata'=>'D~O'
                                                   ,'input_type'=>0,'tablename'=>'ld_salesorder','selectmodule'=>'','fieldtype'=>'Span') ;
                
                 
            } else if ($this->sourceModule == 'OutboundOrder') {
                $fieldlabel=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname", 'outdate', 'fieldlabel');
                $referencefieldname=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname", 'outdate', 'fieldname');
                $this->table_header[] = array('fieldlabel'=>$fieldlabel,'referencefieldname'=>$referencefieldname
                                                   ,'columnname'=>'billdate','edit_permission'=>1,'typedata'=>'D~O'
                                                   ,'input_type'=>0,'tablename'=>'ld_salesorder','selectmodule'=>'','fieldtype'=>'Span') ;
                                                   
                
            }
        }
        $referencefieldname='';
        if(!empty($this->sourceModule))
            $referencefieldname=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname",'total','fieldname');
        $this->table_header[] = array('fieldlabel'=>getFixedLabel("AMOUNT"),'referencefieldname'=>$referencefieldname
                                     ,'columnname'=>'total','edit_permission'=>1
                                    ,'fieldtype'=>'Span','tablename'=>'ld_cashbill'
                                    ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'');//金额
        if ($this->sourceModule == 'SalesOrder' || $this->sourceModule == 'ServiceContracts') {
            if (vtlib_isModuleActive('Invoice')) {
                $referencefieldname=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname",'lastinvoicedate','fieldname');
                
                $this->table_header[] =array('fieldlabel'=>getFixedLabel("THENEWINVOICEDATE"),'referencefieldname'=>$referencefieldname
                                                        ,'columnname'=>'invoicedate','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_cashbill'
                                                        ,'typedata'=>'D~O','input_type'=>'0','selectmodule'=>'') ;//最近开票日期
                $referencefieldname=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname",'have_invoicetotal','fieldname');
                $this->table_header[] = array('fieldlabel'=>getFixedLabel("HASBILLINGAMOUNT"),'referencefieldname'=>$referencefieldname
                                                        ,'columnname'=>'invoicetotal','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_cashbill'
                                                        ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'');//已开票总额
                
            }
            $referencefieldname=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname",'cashbilldate','fieldname');
            $this->table_header[] =array('fieldlabel'=> getFixedLabel("LATESTCOLLECTION"),'referencefieldname'=>$referencefieldname
                                                        ,'columnname'=>'lastcashbilldate','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_cashbill'
                                                        ,'typedata'=>'D~O','input_type'=>'0','selectmodule'=>'');//最近收款日期
           $referencefieldname=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname",'received_amount','fieldname');                                            
            $this->table_header[] =array('fieldlabel'=> getFixedLabel("CONTRACTRECIVETOTAL"),'referencefieldname'=>$referencefieldname
                                                        ,'columnname'=>'received_amount','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_cashbill'
                                                        ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'');//合同已收总额
                                                        
                                                         
            //LATESTCOLLECTION
        } else if ($this->sourceModule == 'PaymentPlan') {
            $referencefieldname=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname",'received_amount','fieldname');
            $this->table_header[] =array('fieldlabel'=> getFixedLabel("TOTALRECEIVES"),'referencefieldname'=>$referencefieldname
                                                        ,'columnname'=>'received_amount','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_paymentplan'
                                                        ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'');//已收总额
                                                         
            $this->table_header[] =array('fieldlabel'=> getFixedLabel("CONTRACTINFO")
                                                        ,'columnname'=>'contractinfo','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_paymentplan'
                                                        ,'typedata'=>'V~O','input_type'=>'0','selectmodule'=>'');//合同信息
             
            $this->table_header[] =array('fieldlabel'=> getFixedLabel("SALESORDERCONTRACTAMOUNT")
                                                        ,'columnname'=>'contractamount','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_paymentplan'
                                                        ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'');//合同金额
                                                        
            $this->table_header[] =array('fieldlabel'=> getFixedLabel("THENEWINVOICEDATE")
                                                        ,'columnname'=>'invoicedate','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_paymentplan'
                                                        ,'typedata'=>'D~O','input_type'=>'0','selectmodule'=>'');//最近开票日期
                                                         
            $this->table_header[] =array('fieldlabel'=> getFixedLabel("HASBILLINGAMOUNT")
                                                        ,'columnname'=>'invoicetotal','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_paymentplan'
                                                        ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'');//已开票总额
                                                         
            $this->table_header[] = array('fieldlabel'=> getFixedLabel("LATESTCOLLECTION")
                                                        ,'columnname'=>'lastcashbilldate','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_paymentplan'
                                                        ,'typedata'=>'D~O','input_type'=>'0','selectmodule'=>'');//最近收款日期
            
            $this->table_header[] =array('fieldlabel'=>  getFixedLabel("CONTRACTRECIVETOTAL")
                                                        ,'columnname'=>'contract_receive_amount','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_paymentplan'
                                                        ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'') ;//合同已收总额
                                                       

        } else {
            $referencefieldname='';
        if(!empty($this->sourceModule))
            $referencefieldname=$this->source_focus->fieldobj->getFieldInfoBykeyValue("columnname",'received_amount','fieldname');
            
            $this->table_header[] =array('fieldlabel'=>   getFixedLabel("TOTALRECEIVES"),'referencefieldname'=>$referencefieldname
                                                        ,'columnname'=>'received_amount','edit_permission'=>1
                                                        ,'fieldtype'=>'Span','tablename'=>'ld_paymentplan'
                                                        ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'') ;
        }
        $this->table_header[] =array('fieldlabel'=>  getFixedLabel("THEAMOUNTCOLLECTED")
                                                        ,'columnname'=>'now_cashbill_money','edit_permission'=>0
                                                        ,'fieldtype'=>'Text','tablename'=>'ld_paymentplan'
                                                        ,'typedata'=>'N~O','input_type'=>'0','selectmodule'=>'');//本次收款金额
                                                        
    }

    public function getrowDetailValueByDetailId($detailid,$sequenceno='0')
    {
         global $adb;
         $this->getDetailHeader();
         $sql='select entitytype from ld_cashbill2paymentplan  where cashbill2paymentplan_id=?  ';
         $result=$adb->pquery($sql,array($detailid));
         $this->sourceModule=$adb->query_result($result,0,0);

         crm_load_class_file('cls_CashBill_Parent_EnitytData','modules/CashBill/EntityData');

        $cashbillobj= cls_CashBill_Parent_EnitytData::getInstance($this->sourceModule,$this->sourceIds,'detailrowvalue',$detailid);
        $data = $cashbillobj->getData();

         $ret_values=$this->formateDataValues($data);
        $ret_values=$ret_values[0];
         return $ret_values;

    }
    public function getvalues()
    {
        $this->getDetailHeader();
         crm_load_class_file('cls_CashBill_Parent_EnitytData','modules/CashBill/EntityData');
        $cashbillobj= cls_CashBill_Parent_EnitytData::getInstance($this->sourceModule,$this->sourceIds,$this->pageType,$this->record);
        $data = $cashbillobj->getData();


        $ret_values=$this->formateDataValues($data);


         return array('headers'=>$this->table_header,'value'=>$ret_values,'AddProductBtn'=>'no'
         ,'defaultRows'=>sizeof($data),'subtotalvalue'=>'','lastRowValue'=>$this->getLastRow_Value());

    }
    public function formateDataValues($data)
    {
         $i=0;
        foreach ($data as $index => $row_data) 
        {
           
           
            foreach ($this->table_header as $tmpindex =>  $info) {
                    $columnname=$info['columnname'];
                    
                    $value = $row_data[$columnname];
                    $hiddenvalue=$value;
                     $parentmodule='';   
                    if ($columnname == 'href_columnname') {
                       $hiddenvalue=$row_data['sourceid'];
                       $parentmodule=$this->sourceModule;
                        
                    } else if ($columnname == 'total' || $columnname == 'received_amount')//源单金额和源单已收总额
                    {
                        $value = decode_html($row_data['currency_symbol']) . setNumberFormat($value);
    
                    } else if ($columnname == 'contractinfo')//合同信息
                    {
                        //源单的合同信息（目前之后回款计划）
                        if ($row_data['contractinfo'] == '')
                            $value = '';
                        else {
                            $parentmodule=$row_data['contract_module'];
                            $hiddenvalue=$row_data['contractid'];
                            
    
                        }
                    } else if ($columnname == 'contractamount' || $columnname == 'contract_receive_amount' || $columnname == 'invoicetotal') {
    
                        //源单的合同金额，源单的合同已收总额，源单的合同已开票总额
                        if ($row_data['contractinfo'] == '')
                            $value = '';
                        else
    
                            $value = decode_html($row_data['contract_currency_symbol']) . setNumberFormat($value);
                    } else if ($columnname == 'now_cashbill_money') {
    
                        if ($this->pageType == 'select_source') {
                            $currency_id = $row_data['currency_id'];//原单币种id
    
                            $cashbill_currency_id = $this->cashbill_currency_id;//收款单币种id
    
                            if ($currency_id != $cashbill_currency_id) {
                                $currency_obj = new Currency($adb, $cashbill_currency_id);
                                $changeCurrency_obj = new Currency($adb, $currency_id);
                                $value = number_format($currency_obj->ConvertTothisobj_money($changeCurrency_obj, $value),2,".","");
                               
                            }
    
                        }
                        $this->subtotal += $value;
                       
                    }
                    $ret_values[$i][$columnname]=array('value'=>$value,'hiddenvalue'=>$hiddenvalue,'option'=>'','parentmodule'=>$parentmodule);
                    $ret_values[$i]['detailid']=$row_data['detailid'];
                    $ret_values[$i]['sourceid']=$row_data['sourceid'];
                    $ret_values[$i]['contract_module']=$row_data['contract_module'];
                    $ret_values[$i]['contractid']=$row_data['contractid'];
                }
                $i++;
         }
        return $ret_values;
       /*  return array('headers'=>$this->table_header,'value'=>$ret_values,'AddProductBtn'=>'no'
         ,'defaultRows'=>sizeof($data),'subtotalvalue'=>'','lastRowValue'=>$this->getLastRow_Value());*/
    }
    
    public function getLastRow_Value()
    {
        $focus=CRMEntity::getInstance('CashBill');
        $fieldname=$focus->fieldobj->getFieldInfoBykeyValue('columnname','total','fieldname');
        $fieldlabel=$focus->fieldobj->getFieldInfoBykeyValue('columnname','total','fieldlabel');
        if($this->pageType=='select_source')
        {
            $total=$this->subtotal;
        }
        else
        {
            $total=$focus->column_fields[$fieldname];
        }
        $arr[]=array('value'=>$total,'fieldname'=>$fieldname,'fieldlabel'=>$fieldlabel);
        return $arr;
    }
    
   
}
?>