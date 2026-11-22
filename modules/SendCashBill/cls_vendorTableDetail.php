<?php
class cls_vendorTableDetail extends cls_ParentTableDetail
{
    public function cls_vendorTableDetail($ids)
    {
        $this->ids=$ids;
    }
    
    public function getListData()
    {
        global $adb ;
        $sql="select ld_purchaseorder.purchaseorderid,ld_sendpayment.sendpaymentid from ld_vendor INNER JOIN 

            ld_purchaseorder on ld_vendor.vendorid=ld_purchaseorder.purchaseorderid
            LEFT JOIN ld_sendpayment on ld_purchaseorder.purchaseorderid=ld_sendpayment.Purchaseorder_id
             and ld_sendpayment.deleted=0
            where ld_vendor.vendorid=? and ld_purchaseorder.deleted=0
                order by ld_purchaseorder createdtime desc ,ld_sendpayment.planddate desc ";
       $result=$adb->pquery($sql,array($this->ids));
       for($i=0;$i<$adb->num_rows($result);$i++)
       {
         $sendpaymentid=$adb->query_result($result,$i,'sendpaymentid');
         if(!empty($sendpaymentid))
           $sendpaymentids[]=$sendpaymentid;
         else
           $purchaseorderids[]=$adb->query_result($result,$i,'purchaseorderid');
           
       }
       
        if(sizeof($sendpaymentids)>0)
        {
             if(!class_exists('cls_sendPaymentTableDetail'))
                include(globalStatic::$root_directory. 'modules/SendCashBill/cls_sendPaymentTableDetail.php');
             $other_table_sendpayment_focus=new cls_purchaseTableDetail(implode(",",$sendpaymentids));
             $other_table_sendpayment_focus->getListData();//按照给定的$sendpaymentids顺序生成数组
        }
         if(sizeof($purchaseorderids)>0)
         {
            if(!class_exists('cls_purchaseTableDetail'))
                include(globalStatic::$root_directory. 'modules/SendCashBill/cls_purchaseTableDetail.php');
            $other_table_purchase_focus=new cls_purchaseTableDetail(implode(",",$purchaseorderids));//按照给定的$purchaseorderids顺序生成数组
            $other_table_purchase_focus->getListData();
         }
             //按照数据库顺序重新生成table_data数组
            $tmp_sendpayment=0;
            $tmp_purchaseorder=0;
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
                                $this->table_data[]=$data;
                                break;
                            }
                         }
                    }
            }
            
    }
    
    
    
}

?>