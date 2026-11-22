<?php
global $adb,$current_user,$currentModule;
$focus=CRMEntity::getInstance("Commission");

$detailfieldobj=$focus->detailfieldobj;
$selectbillid=$_REQUEST['selectbillid'];
$selectbillid=trim($selectbillid,';');
$selectbillid_array=explode(';',$selectbillid);
$selectbilliddetail_id=array();
$mainid_arr=array();
foreach($selectbillid_array as $tmpselectid)
{
    $tmpselectid_arr=explode(",",$tmpselectid);
    if(!empty($tmpselectid_arr[1]))
        $selectbilliddetail_id[]=$tmpselectid_arr[1];//明细表主键ID(数据分类有明细字段)
    else
        $mainid_arr[]=$tmpselectid_arr[0];//主表主键iD
}
if($selectbilliddetail_id[0]!='')
{
    $sql=' select ld_commission2payment.*,ld_commission2paymentscf.*,ld_commission.commission_no from
    ld_commission inner join   ld_commission2payment on ld_commission.commission_id=ld_commission2payment.commission_id
    LEFT JOIN ld_commission2paymentscf  on ld_commission2payment.commission2payment_id=ld_commission2paymentscf.commission2payment_id
    where ld_commission2payment.commission2payment_id in( '.implode(',',$selectbilliddetail_id).')
    order by ld_commission.createdtime desc ,ld_commission2payment.commission2payment_id asc ';
}

else{
    $sql=' select ld_commission2payment.*,ld_commission2paymentscf.*,ld_commission.commission_no from
    ld_commission inner join   ld_commission2payment on ld_commission.commission_id=ld_commission2payment.commission_id
    LEFT JOIN ld_commission2paymentscf  on ld_commission2payment.commission2payment_id=ld_commission2paymentscf.commission2payment_id
    where ld_commission2payment.commission_id in( '.implode(',',$mainid_arr).')
    order by ld_commission.createdtime desc ,ld_commission2payment.commission2payment_id asc ';
}

$result=$adb->pquery($sql,array());

$moduleFields=$detailfieldobj->getModuleFields();
$rows=$adb->num_rows($result);
$tmphrefvalues=array();
$arr=array();
$arr['valueinfo']=array();
//获取明细数据类
crm_load_class_file("TabDetailFieldsHtmlTd",'include/TabDetailFields');
$TabDetailFieldsHtmlTdobj = new TabDetailFieldsHtmlTd($focus,$currentModule);
for($i=0;$i<$rows;$i++)
{

    foreach($moduleFields as $columnname=>$fieldinfo)
    {
        if(strtolower($fieldinfo->getFieldType())=='selectsource')
        {
           
            $showvalue=$TabDetailFieldsHtmlTdobj->getColumnValue($fieldinfo,$columnname,$adb->query_result($result,$i,'commission_id'),SHOW_POPUP);
        }
        else if($columnname=='sf217')
        {
            //商品数量
             /**
            *1.客服下单->出入库订单”，
            当“出库”类型的单据关联“入库”类型单据单时，自动计算并带出剩余可出库数量“商品数量”，
            并且保存时增加校验累积出库数量不允许超出入库数量
            */
            $showvalue=$TabDetailFieldsHtmlTdobj->getColumnValue($fieldinfo,$columnname,$adb->query_result($result,$i,'sf217_balance'),SHOW_POPUP);
        }
        else
            $showvalue=$TabDetailFieldsHtmlTdobj->getColumnValue($fieldinfo,$columnname,$adb->query_result($result,$i,$columnname),SHOW_POPUP);
        
    
        $arr['detailvalueinfo'][$i][]=array("columnname"=>$columnname,'value'=>$showvalue);
    }
    $arr['detailvalueinfo'][$i][]=array("columnname"=>'parent_lineitem_id','value'=>array('value'=>$adb->query_result($result,$i,'commission2payment_id')));
    
    $commission_no=$adb->query_result($result,$i,'commission_no');
    $tmphrefvalues[$commission_no]='';
}

$arr['hrefvalue']=implode(",",array_keys($tmphrefvalues));
$arr['id']=implode(',',$selectbillid_array);
$_REQUEST['diony']='yes';
ConvertTojsonString(1,$arr,'success');

?>