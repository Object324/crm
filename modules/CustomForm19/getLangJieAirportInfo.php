<?php
/**
 * 服务项目是空运
*带出供应商报价单信息
**/
global $adb;
$selectid=$_REQUEST['selectid'];
$sql='select id,sf174 from ld_customform24detail 
inner join ld_customform24detailscf on ld_customform24detailscf.lineitem_id=ld_customform24detail.lineitem_id
 where id=? order by ld_customform24detail.lineitem_id asc  ';

$main_result=$adb->pquery($sql,array($selectid));
$customform24detailrowcount=$adb->num_rows($main_result);//获取分录的行数
$quantity_arr=array();
$_REQUEST['diony']='yes';
$deploy_value=getSys_deploy(49);//单据明细中数量小数位数
$decimallen=$deploy_value['deploy_value'];

if($adb->num_rows($main_result)==10000)
{
     $_REQUEST['diony']='yes';
    global $adb,$currentModule,$current_user;
    $selectid=$_REQUEST['selectid'];//空运
    $_REQUEST['selectmodule']='CustomForm24';
    
    crm_load_class_file('cls_getLangJiePurchaseOrderInfo','modules/CustomForm19');
    $obj=new cls_getLangJiePurchaseOrderInfo($_REQUEST['selectmodule'],$selectid);
    
    ConvertTojsonString(1,$obj->getData(),'success');

}
else
{
     $tablename='ld_customform24';
    $tablescf='ld_customform24scf';
    $tableindex='customform24id';
    $detailtable='ld_customform24detail';
    $detailtablescf='ld_customform24detailscf';
    
    //判断是否有空运订单回传
    $sql=' select  ld_customform25.customform25id,sf174 from ld_customform25 
          inner join ld_customform25scf on ld_customform25.customform25id=ld_customform25scf.customform25id
         inner join ld_customform25detail on ld_customform25detail.id=ld_customform25.customform25id
         inner join ld_customform25detailscf on ld_customform25detailscf.lineitem_id=ld_customform25detail.lineitem_id
        where deleted=0 and  customform24_id=?  order by modifiedtime desc,createdtime desc ,ld_customform25detail.lineitem_id asc ';
    $result=$adb->pquery($sql,array($selectid));
    if($adb->num_rows($result)>0)
    {
        //有回传订单
        $rows=$adb->num_rows($result);
        for($i=0;$i<$rows;$i++)
        {
            $quantity_arr[]=number_format($adb->query_result($result,$i,'sf174'), $decimallen, '.', '');//setNumberFormat($adb->query_result($result,$i,'sf174'),$decimallen);//获取分单计费计费重量
        }
        $customform25id=$adb->query_result($result,0,'customform25id');
        $sql="select ld_customform25scf.cf_3719,ld_purchaseorder.purchaseorderid,ld_purchaseorder.purchaseorder_no,ld_purchaseorder.currency_id as source_currency_id
         ,ld_purchaseorderdetail.*,ld_purchaseorderdetailscf.*,ld_products.*,ld_productcf.*
         from
          ld_customform25   inner join ld_customform25scf on ld_customform25.customform25id=ld_customform25scf.customform25id
         inner join $tablename on $tablename.$tableindex=ld_customform25.customform24_id
           inner join $tablescf on $tablescf.$tableindex=$tablename.$tableindex
       
         inner join $detailtable on $detailtable.id=$tablename.$tableindex
         inner join $detailtablescf on $detailtablescf.lineitem_id=$detailtable.lineitem_id
         inner join ld_purchaseorder on  $tablename.purchaseorder_id=ld_purchaseorder.purchaseorderid
         inner join ld_purchaseorderdetail on  ld_purchaseorderdetail.id=ld_purchaseorder.purchaseorderid 
         inner join ld_purchaseorderdetailscf on ld_purchaseorderdetail.lineitem_id=ld_purchaseorderdetailscf.lineitem_id
		   and ( ($tablename.start_port=ld_purchaseorderdetailscf.sf11083 and $tablename.end_port=ld_purchaseorderdetailscf.sf11219) 
		          or (ifnull(ld_purchaseorderdetailscf.sf11083,'')='' and ifnull(ld_purchaseorderdetailscf.sf11219,'')='') )
         inner join ld_products on ld_products.productid=ld_purchaseorderdetail.productid
         inner join ld_productcf on ld_productcf.productid=ld_products.productid   ";
          
    }
    else
    {
        $rows=$adb->num_rows($main_result);
        for($i=0;$i<$rows;$i++)
        {
            $quantity_arr[]=number_format($adb->query_result($main_result,$i,'sf174'), $decimallen, '.', '');//setNumberFormat($adb->query_result($result,$i,'sf174'),$decimallen);//获取分单计费计费重量
        }
      
        //cf_3718:主单计费重量,sf174:计费重量
        $sql="select $tablescf.cf_3718 as cf_3719,ld_purchaseorder.purchaseorderid,ld_purchaseorder.purchaseorder_no
            ,ld_purchaseorder.currency_id as source_currency_id
        ,ld_purchaseorderdetail.*,ld_purchaseorderdetailscf.*,ld_products.*,ld_productcf.*
         from $tablename inner join $tablescf on $tablescf.$tableindex=$tablename.$tableindex
         inner join $detailtable on $detailtable.id=$tablename.$tableindex
         inner join $detailtablescf on $detailtablescf.lineitem_id=$detailtable.lineitem_id
         inner join ld_purchaseorder on  $tablename.purchaseorder_id=ld_purchaseorder.purchaseorderid
         inner join ld_purchaseorderdetail on  ld_purchaseorderdetail.id=ld_purchaseorder.purchaseorderid 
         inner join ld_purchaseorderdetailscf on ld_purchaseorderdetail.lineitem_id=ld_purchaseorderdetailscf.lineitem_id
		   and ( ($tablename.start_port=ld_purchaseorderdetailscf.sf11083 and $tablename.end_port=ld_purchaseorderdetailscf.sf11219) 
		          or (ifnull(ld_purchaseorderdetailscf.sf11083,'')='' and ifnull(ld_purchaseorderdetailscf.sf11219,'')='') )
         inner join ld_products on ld_products.productid=ld_purchaseorderdetail.productid
         inner join ld_productcf on ld_productcf.productid=ld_products.productid ";
    }
    $sql.=" where $tablename.$tableindex=? order by ld_purchaseorderdetail.lineitem_id asc ";
 //   echo $selectid;
    //dump($sql);
    $result=$adb->pquery($sql,array($selectid));
    $rows=$adb->num_rows($result);
    $salesorder_focus=CRMEntity::getInstance("PurchaseOrder");
    $modulefields=$salesorder_focus->detailfieldobj->getModuleFields();
    crm_load_class_file('showProductDetailFieldValue','include/fields');
    $rowindex=0;
    $havelineitem_id_arr=array();
    for($i=0;$i<$rows;$i++)
    {
        $purchaseorderid=$adb->query_result($result,$i,'purchaseorderid');
        $purchaseorder_no=$adb->query_result($result,$i,'purchaseorder_no');
        $currency_id=$adb->query_result($result,$i,'source_currency_id');
        $lineitem_id=$adb->query_result($result,$i,'lineitem_id');
        if(in_array($lineitem_id,$havelineitem_id_arr))
        {
            continue;
        }
        $havelineitem_id_arr[]=$lineitem_id;
        $productid=$adb->query_result($result,$i,'productid');
        
        $fendan_charging=$adb->query_result($result,$i,'fendan_charging');//分单计费方式
        $tmp_quantity=array();
        if($fendan_charging=="按主单计费")
        {
            $quantity=$adb->query_result($result,$i,'cf_3719');
            $tmp_quantity[]=number_format($quantity,$decimallen, '.', '');//setNumberFormat($quantity,$decimallen) ;
        }
        else 
        {
            //按分单计费
            //$quantity=$adb->num_rows($result,$i,'sf_174');
            $tmp_quantity=$quantity_arr;
            
        }
       
        foreach($tmp_quantity as $quantityindex=>$tmpquantity)
        {
          
             foreach($modulefields as $tmpcolumnname=>$salesorder_detailfieldinfo)
            {
              
                    
                $value=$adb->query_result($result,$i,$tmpcolumnname);
                $rawValue=$value;
                $tablename=$salesorder_detailfieldinfo->getTableName();
                if($tablename=='ld_products'||$tablename=='ld_productcf')
                {
                      $showfieldvalueobj=new ShowFieldValue($salesorder_focus->fieldobj,"PurchaseOrder",SHOW_POPUP);
                }
                else
                {
                    $showfieldvalueobj=new showProductDetailFieldValue($salesorder_focus->fieldobj,"PurchaseOrder",SHOW_DETAILVIEW);
                    $showfieldvalueobj->setLine_index($i);
                    $showfieldvalueobj->setModuleFields($modulefields);
                }
                $showfieldvalueobj->setRecorId($purchaseorderid);
                $showfieldvalueobj->setadbResult($result);
              
               
                $showvalue=$showfieldvalueobj->getFieldValueByField($salesorder_detailfieldinfo,$rawValue,$value);
                  
                $arr['detailfieldvalue'][$rowindex][$tmpcolumnname]=$showvalue['value'];
                
                
            }
            
            $arr['detailfieldvalue'][$rowindex]['quantity']=$tmpquantity;
            //$arr['detailfieldvalue'][$rowindex]['productid']=$productid;
            $arr['detailfieldvalue'][$rowindex]['fendan_charging']=$adb->query_result($result,$i,'fendan_charging');
            $arr['detailfieldvalue'][$rowindex]['hdnProductId']=$productid;
            $arr['detailfieldvalue'][$rowindex]['lineitem_id']=$lineitem_id;
            $arr['detailfieldvalue'][$rowindex]['batchmanagement']=0;
            $arr['detailfieldvalue'][$rowindex]['pricestrategyobj']=array();
            $rowindex++;
        }
     
        
    }
    if($rows<=0)
    {
            $sql="select ld_purchaseorder.purchaseorderid,ld_purchaseorder.purchaseorder_no,,ld_purchaseorder.currency_id as source_currency_id from $tablename 
                  inner join ld_purchaseorder  on ld_purchaseorder.purchaseorderid=$tablename.purchaseorder_id
                   where  $tablename.$tableindex=? ";
                  
            $result=$adb->pquery($sql,array($selectid));
            $purchaseorderid=$adb->query_result($result,0,'purchaseorderid');
            $purchaseorder_no=$adb->query_result($result,0,'purchaseorder_no');
            $currency_id=$adb->query_result($result,0,'source_currency_id');
    }
    $arr['purchaseorderid']=$purchaseorderid;
    $arr['purchaseorder_no']=$purchaseorder_no;
    $arr['currency_id']=$currency_id;
    ConvertTojsonString(1,$arr,'success');
    
    
}
?>