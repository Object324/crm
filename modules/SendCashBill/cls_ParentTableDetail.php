<?php

class cls_ParentTableDetail
{
    protected $page_type='';//detail,edit,create
    protected $module;
    protected $ids;
    protected $table_detail_focus;
    var $table_data=array();
    protected $focus;
    protected $invoice_sql=" LEFT JOIN
                    (   select sum(if(ld_purchaseinvoice.currency_id > 1,ld_purchaseinvoice.total/ld_purchaseinvoice.conversion_rate,ld_purchaseinvoice.total)) as totalsum,entitytypeid from ld_purchaseinvoice 
                        inner join 	(select id,entitytypeid from ld_purchaseinvoicedetail  group by id) 
                        as temp on temp.id = ld_purchaseinvoice.purchaseinvoiceid 
                        where ld_purchaseinvoice.deleted = 0 and ld_purchaseinvoice.purchaseinvoiceid > 0 GROUP BY entitytypeid
                    ) as T1 ON T1.entitytypeid=ld_purchaseorder.purchaseorderid 
                   left join  (select * from (select distinct ld_purchaseinvoicedetail.entitytypeid,ld_purchaseinvoice.purchaseinvoicenum,ld_purchaseinvoice.purchaseinvoicedate 
                			from ld_purchaseinvoice inner join 
                			ld_purchaseinvoicedetail on ld_purchaseinvoice.purchaseinvoiceid = ld_purchaseinvoicedetail.id 
                			where ld_purchaseinvoice.deleted = 0 and ld_purchaseinvoice.purchaseinvoicestatus <> \"已作废\" 
                			order by ld_purchaseinvoice.purchaseinvoicedate desc ) as C1 group by C1.entitytypeid
                        ) as invoice on ld_purchaseorder.purchaseorderid = invoice.entitytypeid  ";
    /**
     * 
     * */
    public static function getInstance($module,$ids)
    {
        switch($module)
        {
            case "PurchaseOrder":
				if(!class_exists('cls_purchaseTableDetail')){
					include(globalStatic::$root_directory. 'modules/SendCashBill/cls_purchaseTableDetail.php');
				}
				$table_detail_focus= new cls_purchaseTableDetail($ids);
				break;
            case "SendPayment":
				if(!class_exists('cls_sendPaymentTableDetail')){
					include(globalStatic::$root_directory. 'modules/SendCashBill/cls_sendPaymentTableDetail.php');
				}
				$table_detail_focus= new cls_sendPaymentTableDetail($ids);
				break;
            case "SendPayment#PurchaseOrder":
				if(!class_exists('cls_MultiTableDetail')){
					include(globalStatic::$root_directory. 'modules/SendCashBill/cls_MultiTableDetail.php');
				}
				$table_detail_focus= new cls_MultiTableDetail($ids);
				break;
            case "Vendors":
				if(!class_exists('cls_vendorTableDetail')){
					include(globalStatic::$root_directory. 'modules/SendCashBill/cls_vendorTableDetail.php');
				}
				$table_detail_focus= new cls_vendorTableDetail($ids);
				break;
			default:
				$table_detail_focus= new cls_ParentTableDetail($ids);
                
        }
		$table_detail_focus->ids=$ids;
		$table_detail_focus->focus=CRMEntity::getInstance('SendCashBill');
		$table_detail_focus->table_detail_focus=$table_detail_focus;
        return  $table_detail_focus;
    }
   /**
    * 获取付款单在数据库中已经存在的付款明细
    * 
    * */
    private   function getData_inDataBase()
    {
        global $adb;
        
        if($this->focus->id>0)
        {
            $sql='select sendpaymentid, ld_sendcashbill2payment.purchaseorder_id,ld_sendcashbill2payment.sendcashbillid,amount,checkoutstatus from ld_sendcashbill2payment 
			left join ld_sendcashbill on ld_sendcashbill.sendcashbillid = ld_sendcashbill2payment.sendcashbillid  where ld_sendcashbill2payment.sendcashbillid='.$this->focus->id.' order by sequence asc ';
            $result=$adb->pquery($sql,array());
            for($i=0;$i<$adb->num_rows($result);$i++)
            {
                $sendpaymentid=$adb->query_result($result,$i,'sendpaymentid');
                $purchaseorder_id=$adb->query_result($result,$i,'purchaseorder_id');
				$checkoutstatus = $adb->query_result($result,$i,'checkoutstatus');
                if(!empty($sendpaymentid))
                {
                    $sendpaymentids[]=$sendpaymentid;
                }
                else
                {
                    $purchaseorderids[]=$purchaseorder_id;
                }
                
            }
         
             if(sizeof($sendpaymentids)>0 )
             {
                 if(!class_exists('cls_sendPaymentTableDetail'))
                    include(globalStatic::$root_directory. 'modules/SendCashBill/cls_sendPaymentTableDetail.php');
                $other_table_sendpayment_focus=new cls_sendPaymentTableDetail(implode(",",$sendpaymentids));
                $other_table_sendpayment_focus->getListData();//按照给定的$sendpaymentids顺序生成数组
             }
            
             if(sizeof($purchaseorderids)>0)
             {
                if(!class_exists('cls_purchaseTableDetail'))
                    include(globalStatic::$root_directory. 'modules/SendCashBill/cls_purchaseTableDetail.php');
                  
                $other_table_purchase_focus=new cls_purchaseTableDetail(implode(",",$purchaseorderids));//按照给定的$purchaseorderids顺序生成数组
                $other_table_purchase_focus->getListData();
                
             }
         
             
             //按照数据库付款单sequence顺序重新生成table_data数组
           
             for($i=0;$i<$adb->num_rows($result);$i++)
            {
                    $sendpaymentid=$adb->query_result($result,$i,'sendpaymentid');
                    $purchaseorder_id=$adb->query_result($result,$i,'purchaseorder_id');
                    if(!empty($sendpaymentid))
                    {
                         for($tmp_sendpayment=0;$tmp_sendpayment<sizeof($other_table_sendpayment_focus->table_data);$tmp_sendpayment++)
                         {
                            $data=$other_table_sendpayment_focus->table_data[$tmp_sendpayment];
                            if($data['sendpaymentid']==$sendpaymentid)
                            {
                                $sendcashbill_amount=$adb->query_result($result,$i,'amount');
                                if($this->page_type=='edit')
                                {
                                    //22601: 付款单新增明细界面：“已付金额”字段值不正确
                                    $sendpayment_currency_obj=new Currency($adb,$data['sendpayment_currency_id']);
                                    $sendcashbill_currency_obj=new Currency($adb,$this->focus->column_fields['currency_id']);
									//23762: 付款单编辑界面：付款信息区块的“已付金额”字段值显示错误
									//付款单已审核后，对应付款计划的已付金额才会计算
									if($checkoutstatus == '已审核'){
										$data['actualamount']=$data['actualamount']-$sendpayment_currency_obj->ConvertTothisobj_money($sendcashbill_currency_obj,$sendcashbill_amount);	
									}
                                }
                                $data['cur_amount']=$sendcashbill_amount;//本次收款
                                $this->table_data[]=$data;
                                break;
                            }
                         }
                    }
                    else
                    {
                         for($tmp_purchaseorder=0;$tmp_purchaseorder<sizeof($other_table_purchase_focus->table_data);$tmp_purchaseorder++)
                         {
                            $data=$other_table_purchase_focus->table_data[$tmp_purchaseorder];
                           
                            if($data['purchaseorderid']==$purchaseorder_id)
                            {
                                 $fieldobj=$this->focus->fieldobj->getFieldInfoobjBykey("columnname",'currency_id');
                                 $sendcashbill_currencyid=1;
                                 if($fieldobj)
                                 {
                                    $sendcashbill_currencyid=$this->focus->column_fields[$fieldobj->getFieldName()];
                                 }
                                 //编辑的时候求已付金额需要减去本次付款金额
                                 $sendcashbill_amount=$adb->query_result($result,$i,'amount');
                                 if($this->page_type=='edit')
                                 {
                                    //22601: 付款单新增明细界面：“已付金额”字段值不正确
                                    $sendcashbill_currencyobj=new Currency($adb,$sendcashbill_currencyid);
                                    $purchase_currencyobj=new Currency($adb,$data['purchase_currency_id']);
                                    $data['actualamount']=$data['actualamount']-$purchase_currencyobj->ConvertTothisobj_money($sendcashbill_currencyobj,$sendcashbill_amount);
                                 }
                                
                                $data['cur_amount']=$sendcashbill_amount;//本次收款
                                
                                $this->table_data[]=$data;
                                break;
                            }
                         }
                    }
            }
        }
       
       return $this->table_data;
    }
    

    public function getListData()
    {
        
    }
    public function create_EditView_Html($start_rowid = '')
    {
        $trPayment='';
        if($this->focus->id>0)
        {
            $this->page_type='edit';
        }
        else
        {
            $this->page_type='create';
        }
        $this->getData_inDataBase();
        $this->getListData();
		if(!empty($start_rowid)){
			$j = $start_rowid;
		}else{
			$j=1;
		}
      
        foreach($this->table_data as $data)
        {
            $trPayment.=" <tr id='row".$j."'>";
            $trPayment .="<td><a class='icon-homeimg icon-sdel' href='javascript:;' title='".getFixedLabel('DELETE')."' onclick='deleteRowSendPayment($j);calSendTotal();'></a><input type='hidden' value='0' name='deleterow$j' id='deleterow$j' /></td>";
            
            $trPayment .='<td><input type="hidden" name="hidden_purchaseorder'.$j.'" id="hidden_purchaseorder'.$j.'" value="'.$data['purchase_href'].'">
                     <a referencemodule="PurchaseOrder" referencerecord="'.$data['purchaseorderid'].'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$data['purchase_href'].'</a>
                            <input type="hidden" value="'.$data['purchaseorderid'].'" name="purchaseorder'.$j.'" id="purchaseorder'.$j.'"/> </td>';//合同编号
           
            $trPayment .='<td> '.$data['purchase_currency_symbol'].setNumberFormat($data['purchase_total']).' </td>';//采购金额
            if(vtlib_isModuleActive('SendPayment') == true)
            {
                $trPayment .='<td> <a referencemodule="SendPayment" referencerecord="'.$data['sendpaymentid'].'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$data['sendpayment_no'].'</a>
                                    <input type="hidden" value="'.$data['sendpaymentid'].'" name="SysBol'.$j.'"/> </td>';//编号
                $trPayment .='<td> '.$data['sendpayment_plandate'].'</td>';//计划日期
                $trPayment .='<td> '.$data['sendpayment_periodtime'].'</td>';//期次
                $trPayment .='<td> '.$data['sendpayment_currency_symbol'] .$data['amount'].' <input type="hidden" value="'.$data['amount'].'" name="planamount'.$j.'"/> </td>';
            }
            else
            {
                $trPayment .='<input type="hidden" value="0" name="SysBol'.$j.'"/>';
                $trPayment .='<input type="hidden" value="0" name="planamount'.$j.'"/>';     
            }
            if($data['sendpaymentid']>0)
                $trPayment .='<td>'.$data['sendpayment_currency_symbol'] . setNumberFormat($data['actualamount']).' <input type="hidden" value="'.$data['actualamount'].'"  name="actualamount'.$j.'" /></td>';//已收金额
            else
                $trPayment .='<td>'.$data['purchase_currency_symbol'] . setNumberFormat($data['actualamount']).' <input type="hidden" value="'.$data['actualamount'].'"  name="actualamount'.$j.'" /></td>';//已收金额
            $trPayment .='<td><input value="'.$data['cur_amount'].'" type="text" onchange="return curSendCashBill(this)"  name="amount'.$j.'" id="amount'.$j.'"/></td>';//本次收款
            $trPayment.="</tr>";
            $j++;
        }
        
        return $trPayment;
        
    }
    
    public function getListVal()
    {
        foreach($this->table_data as $data)
        {
            $sendpaymentid=$data['sendpaymentid'];
            if(!empty($sendpaymentid))
            {
                $listval[]=$sendpaymentid."@2";
            }
            else
            {
                $listval[]=$data['purchaseorderid']."@1";
            }
        }
        
        return $listval;
    }
    
    public function create_DetailView_Html()
    {
         $trPayment='';
        
        $this->page_type='detail';
        
        $this->getData_inDataBase();
        $this->getListData();
        $j=1;
        foreach($this->table_data as $data)
        {
            $trPayment.=" <tr id='row".$j."'>";
           
            $trPayment .='<td> <a referencemodule="PurchaseOrder" referencerecord="'.$data['purchaseorderid'].'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$data['purchase_href'].'</a>
                            <input type="hidden" value="'.$data['purchaseorderid'].'" name="purchaseorder'.$j.'" id="purchaseorder'.$j.'"/> </td>';//合同编号
           
            $trPayment .='<td> '.$data['purchase_currency_symbol'].setNumberFormat($data['purchase_total']).' </td>';//采购金额
            if(vtlib_isModuleActive('SendPayment') == true)
            {
                $trPayment .='<td> <a referencemodule="SendPayment" referencerecord="'.$data['sendpaymentid'].'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$data['sendpayment_no'].'</a>
                                    <input type="hidden" value="'.$data['sendpaymentid'].'" name="SysBol'.$j.'"/> </td>';//编号
                $trPayment .='<td> '.$data['sendpayment_plandate'].'</td>';//计划日期
                $trPayment .='<td> '.$data['sendpayment_periodtime'].'</td>';//期次
                $trPayment .='<td> '.$data['sendpayment_currency_symbol'] .$data['amount'].' <input type="hidden" value="'.$data['amount'].'" name="planamount'.$j.'"/> </td>';
            }
            else
            {
                $trPayment .='<input type="hidden" value="0" name="SysBol'.$j.'"/>';
                $trPayment .='<input type="hidden" value="0" name="planamount'.$j.'"/>';     
            }
            if($data['sendpaymentid']>0)
                $trPayment .='<td>'.$data['sendpayment_currency_symbol'] . setNumberFormat($data['actualamount']).' <input type="hidden" value="'.$data['actualamount'].'"  name="actualamount'.$j.'" /></td>';//已收金额
            else
                $trPayment .='<td>'.$data['purchase_currency_symbol'] . setNumberFormat($data['actualamount']).' <input type="hidden" value="'.$data['actualamount'].'"  name="actualamount'.$j.'" /></td>';//已收金额
            $trPayment .='<td>'.$data['cur_amount'].'</td>';//本次收款
            $trPayment.="</tr>";
            $j++;
        }
        
        return $trPayment;
    }
}


?>