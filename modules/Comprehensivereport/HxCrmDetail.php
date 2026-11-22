<?php
/**
 * 更新操作
 * Edit:can
 * date:20131106
 * reason:浩星明细(租金统计表)
 * */
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
 global $adb,$mod_strings;

$smarty=new lingdangCRM_Smarty();

if(isset($_REQUEST['year']) && isset($_REQUEST['month']))
{

    if(is_int(intval($_REQUEST['year']))==false)
    {
        
        echo '报表年份错误！';
        exit();
    }
    
    if(intval($_REQUEST['year'])>date('Y'))
    {
        echo '报表年份错误！';
        exit();
    }
    if(intval($_REQUEST['month'])<0 ||intval($_REQUEST['month'])>12)
    {
        echo '报表月份错误！';
        exit();
    }
    $year = $_REQUEST['year'];
    $month = $_REQUEST['month'];
    //判断为年度表
    if($month == "0")
    {
        $begin_month = "01";
        $end_month = "12";
    }
    else
    {
        $begin_month = $month;
        $end_month = $month;
    }
}
if(strlen($begin_month)==1)
{
    $begin_month='0'.$begin_month;
}

$begin_date = "";
$begin_date = "".$year."-".$begin_month."-01";
$end_date = "";
$end_date = "".$year."-".$end_month."-".date(t,strtotime($year."-".$end_month));
$startyeardate="".$year."-01-01";
$endyeardate="".$year."-12-31";
$smarty->assign("DATETITLE",$_REQUEST['year'].'年'.$_REQUEST['month'].'月');
//cf_861:结束日期
//duedate:起始日期
$sql="select ld_productcf.cf_854,ld_products.costprice, ld_products.productid,
ld_productcf.cf_851 ,ld_productcf.cf_853 as productname,ld_products.productcode,
 ld_productcf.cf_854  as havearea, ifnull(ld_sendarea.sendarea,0) as sendarea 
,ifnull(monthPaymentplan.summonthamount,0) as summonthamount ,sum(ifnull(yearPaymentplan.yearamount,0.00)) as sumyearamount from ld_products left join ld_productcf on ld_products.productid=ld_productcf.productid 
inner join ld_crmentity on ld_crmentity.crmid=ld_products.productid  
left join
(select subject, salesorder_no ,ld_salesorder.salesorderid,duedate,ld_salesorderdetail.productid from ld_salesorder inner join ld_crmentity on ld_crmentity.crmid=ld_salesorder.salesorderid 
left join  ld_salesorderdetail on  ld_salesorderdetail.id=ld_salesorder.salesorderid left join ld_salesordercf on ld_salesordercf.salesorderid=ld_salesorder.salesorderid
where ld_salesorder.deleted=0  and ('$begin_date' between duedate and ld_salesordercf.cf_861 or duedate between '". $begin_date."' and '".$end_date."')) ld_salesorder
on ld_salesorder.productid=ld_products.productid left join ld_salesordercf on ld_salesordercf.salesorderid=ld_salesorder.salesorderid
left join (select sum(ifnull(amount,0)) as summonthamount,salesorderid  from ld_paymentplan inner join ld_crmentity on ld_paymentplan.paymentplanid=ld_crmentity.crmid
where ld_paymentplan.deleted=0 and plandate between '". $begin_date."' and '".$end_date."' group by salesorderid )
monthPaymentplan on monthPaymentplan.salesorderid=ld_salesorder.salesorderid
left join  
(
select sum(IFNULL(sendarea,0))  as sendarea,ld_salesorderdetail.productid from ld_salesorderdetail left join ld_salesorderdetailscf
 on ld_salesorderdetailscf.lineitem_id=ld_salesorderdetail.lineitem_id 
 inner join ld_products on ld_products.productid=ld_salesorderdetail.productid
inner join ld_crmentity on ld_crmentity.crmid=ld_products.productid
 left join ld_salesorder on ld_salesorder.salesorderid=ld_salesorderdetail.id 
 inner join ld_crmentity as ld_salesordercrm on ld_salesordercrm.crmid=ld_salesorder.salesorderid
 left join ld_salesordercf on  ld_salesordercf.salesorderid=ld_salesorder.salesorderid
 where ld_products.deleted=0 and ld_salesorder.deleted=0 and ('$begin_date' between duedate and ld_salesordercf.cf_861 or duedate between '". $begin_date."' and '".$end_date."')
 group by ld_salesorderdetail.productid) ld_sendarea
on ld_sendarea.productid=ld_products.productid

left join (select ifnull(amount,0) yearamount,ld_salesorder.salesorderid  from ld_paymentplan inner join ld_crmentity on ld_paymentplan.paymentplanid=ld_crmentity.crmid
 inner join ld_salesorder ON
ld_salesorder.salesorderid=ld_paymentplan.entitytypeid INNER JOIN ld_salesorderdetail
 on  ld_salesorderdetail.id= ld_salesorder.salesorderid inner join ld_crmentity as ld_salesordercrm on 
ld_salesordercrm.crmid=ld_salesorder.salesorderid
where ld_paymentplan.deleted=0 and plandate between '". $startyeardate."' and '".$endyeardate."'  )
yearPaymentplan on yearPaymentplan.salesorderid=ld_salesorder.salesorderid
where ld_products.deleted=0   and ld_products.discontinued=1 group by ld_products.productid
order by  CONV(HEX(left(CONVERT(ld_productcf.cf_851 USING gbk),1)),16,10) asc,ld_productcf.cf_853  asc ";
//echo $sql;
$result=$adb->pquery($sql,array());

 $smarty->assign("MOD",$mod_strings);
if($adb->num_rows($result)<=0)
{
    $smarty->display('Comprehensivereport/HxCrmDetail.tpl');
    
    return ;
}

$tdtotalhtml='<td class="listTableRow small" style="background-color:#EEEEEE;">';
$tdhtml='<td class="listTableRow">';
$tdtotalright='<td class="listTableRow small" style="background-color:#EEEEEE;" align="right">';
$tdright='<td class="listTableRow" align="right">';
$reporthtml='';
$subtotalhavearea=0;
$subtotalsendarea=0;
$subtotalcostprice=0;
$subtotalRMBMonth=0;
$subtotalRMBYear=0;
$totalcostprice=0;
$totalsendarea=0;
$totalhavearea=0;
$totalRMBMonth=0;
$totalRMBYear=0;
$lastproductregion=$adb->query_result($result,0,'cf_851');
$lastproductid='';
$lastproductcode='';
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $productregion=$adb->query_result($result,$i,'cf_851');//地区
    $productname=$adb->query_result($result,$i,'productname');//产品名称
    $productid=$adb->query_result($result,$i,'productid');//产品id
    //$salesorderno=$adb->query_result($result,$i,'subject');//合同订单
    //$salesorderid=$adb->query_result($result,$i,'salesorderid');
    $productcode=$adb->query_result($result,$i,'productcode');//性质
   /* if($salesorderno=="")
    {
        $salesorderno='-';
    }*/
    
    $havearea=$adb->query_result($result,$i,'havearea');//可租面积
    $producthavearea=$adb->query_result($result,$i,'cf_854');//产品实际可租面积
    $sendarea=$adb->query_result($result,$i,'sendarea');//已租面积
    if(empty($sendarea))
    {
        $sendarea=number_format(0,2);
    }
    $RMBMonth=round($adb->query_result($result,$i,'summonthamount'),2);//元每月
    $RMBYear=round($adb->query_result($result,$i,'sumyearamount'),2);//元每年
    //满租率
    if(empty($havearea))
    {
        $rentpercent='0%';
        $havearea=number_format(0,2);
        
    }
    else
    {
        $rentpercent=$sendarea/$havearea*100;
       
        $rentpercent=getIntVal($rentpercent).'%';
    }
    //元/月/平米
    if(empty($sendarea))
    {
        $RMBEveryMonthMeter=number_format(0,2);
        $sendarea=number_format(0,2);
    }
    else
    {
        $RMBEveryMonthMeter=round($RMBMonth/$sendarea,2);
    }
   
    if($lastproductregion!=$productregion)
    {
         //满租率小计
        if(empty($subtotalhavearea))
        {
            $subtotalrentpercent='0%';
        }
        else
        {
            $subtotalrentpercent=getIntVal($subtotalsendarea/$subtotalhavearea*100).'%';
        }
        //元/月/平米
        if(empty($subtotalsendarea))
        {
            $subtotalMonthmMeter=number_format(0,2);
        }
        else
        {
            $subtotalMonthmMeter=round($subtotalRMBMonth/$subtotalsendarea,2);
        }
        if(empty($subtotalhavearea))
        {
            $subtotalhavearea=number_format(0,2);
        }
        if(empty($subtotalsendarea))
        {
            $subtotalsendarea=number_format(0,2);
        }
        $reporthtml.='<tr>';
        $reporthtml.=$tdtotalhtml.'小计</td>'.$tdtotalhtml.'-</td>';
        $reporthtml.=$tdtotalright.getDecimalTwoVal($subtotalhavearea).'</td>'.$tdtotalright.getDecimalTwoVal($subtotalsendarea).'</td>'.$tdtotalright.$subtotalrentpercent.'</td>';
        $reporthtml.=$tdtotalright.getDecimalTwoVal($subtotalMonthmMeter).'</td>'.$tdtotalright.getDecimalTwoVal($subtotalRMBMonth).'</td>'.$tdtotalright.getDecimalTwoVal($subtotalRMBYear).'</td>';
        $reporthtml.=$tdtotalright.getDecimalTwoVal($subtotalcostprice).'</td>';
        $reporthtml.='</tr>';
        $reporthtml.='<tr>';
       
       $reporthtml.=$tdhtml.$productregion.'</td>'.$tdhtml.$productname.'</td>';
       /* if(!empty($salesorderid))
             $reporthtml.=$tdhtml.'<a href="index.php?module=SalesOrder&action=DetailView&record='.$salesorderid.'"  target="_blank">'.$salesorderno.'</a></td>';
        else
             $reporthtml.=$tdhtml.$salesorderno.'</td>';*/
        $reporthtml.=$tdright.getDecimalTwoVal($havearea).'</td>'.$tdright.getDecimalTwoVal($sendarea).'</td>'.$tdright.$rentpercent.'</td>';
        $reporthtml.=$tdright.getDecimalTwoVal($RMBEveryMonthMeter).'</td>'.$tdright.getDecimalTwoVal($RMBMonth).'</td>'.$tdright.getDecimalTwoVal($RMBYear).'</td>';
        $reporthtml.=$tdright.'-</td>';
        $reporthtml.='</tr>';
       
        $lastproductregion=$productregion;
        $totalcostprice+=$subtotalcostprice;
        $totalsendarea+=$subtotalsendarea;
        $totalhavearea+=$subtotalhavearea;
        $totalRMBMonth+=$subtotalRMBMonth;
        $totalRMBYear+=$subtotalRMBYear;
        $codes=explode('Car Park',$productname);
        if(count($codes)<2)//去除产品英文名称包含Car Park的可租面积
        {
             $subtotalhavearea=$havearea;
        }
        else
            $subtotalhavearea=0;
        if(count($codes)<2)
        {
             $subtotalsendarea=$sendarea;
        }
        else
            $subtotalsendarea=0;
       
        $subtotalcostprice=$adb->query_result($result,$i,'costprice');
        $subtotalRMBMonth=$RMBMonth;
        $subtotalRMBYear=$RMBYear;
        $lastproductid=$productid;
        $lastproductcode=$productcode;
        //$subtotalcostprice+=$adb->query_result($result,$i,'costprice');
    }
    else
    {
       
        $codes=explode('Car Park',$productname);//去除产品英文名称包含Car Park的可租面积
        if(count($codes)<2)
        {
            $subtotalsendarea+=$sendarea;
        }
        
        $subtotalRMBMonth+=$RMBMonth;
        $subtotalRMBYear+=$RMBYear;
        $reporthtml.='<tr>';
        $reporthtml.=$tdhtml.$productregion.'</td>'.$tdhtml.$productname.'</td>';
             
        $reporthtml.=$tdright.getDecimalTwoVal($havearea).'</td>'.$tdright.getDecimalTwoVal($sendarea).'</td>'.$tdright.$rentpercent.'</td>';
        $reporthtml.=$tdright.getDecimalTwoVal($RMBEveryMonthMeter).'</td>'.$tdright.getDecimalTwoVal($RMBMonth).'</td>'.$tdright.getDecimalTwoVal($RMBYear).'</td>';
        $reporthtml.=$tdright.'-</td>';
        $reporthtml.='</tr>';
        if($lastproductid!=$productid)
        {
            $subtotalcostprice+=$adb->query_result($result,$i,'costprice');//资产成本小计
            if(count($codes)<2)//去除产品性质包含停车场的可租面积
            {
                $subtotalhavearea+=$producthavearea;
            }
            $lastproductid=$productid;
          
        }
    
    }
    
}
//满租率小计
if(empty($subtotalhavearea))
{
    $subtotalrentpercent='0%';
}
else
{
    $subtotalrentpercent=getIntVal($subtotalsendarea/$subtotalhavearea*100).'%';
}
//元/月/平米
if(empty($subtotalsendarea))
{
    $subtotalMonthmMeter=number_format(0,2);
}
else
{
    $subtotalMonthmMeter=round($subtotalRMBMonth/$subtotalsendarea,2);
}
 $totalcostprice+=$subtotalcostprice;
 $totalsendarea+=$subtotalsendarea;
 $totalhavearea+=$subtotalhavearea;
 $totalRMBMonth+=$subtotalRMBMonth;
 $totalRMBYear+=$subtotalRMBYear;
 //满租率总计
if(empty($totalhavearea))
{
    $totalrentpercent='0%';
}
else
{
    $totalrentpercent=getIntVal(($totalsendarea/$totalhavearea)*100).'%';
}
//元/月/平米(总计)
if(empty($totalsendarea))
{
    $totalMonthmMeter=number_format(0,2);
}
else
{
    $totalMonthmMeter=round($totalRMBMonth/$totalsendarea,2);
}
if(empty($totalhavearea))
{
    $totalhavearea=number_format(0,2);
}
if(empty($subtotalhavearea))
{
    $subtotalhavearea=number_format(0,2);
}
if(empty($totalsendarea))
{
    $totalsendarea=number_format(0,2);
}
if(empty($subtotalsendarea))
{
    $subtotalsendarea=number_format(0,2);
}
 $reporthtml.='<tr>';
 $reporthtml.=$tdtotalhtml.'小计</td>'.$tdtotalhtml.'-</td>';
 $reporthtml.=$tdtotalright.getDecimalTwoVal($subtotalhavearea).'</td>'.$tdtotalright.getDecimalTwoVal($subtotalsendarea).'</td>'.$tdtotalright.$subtotalrentpercent.'</td>';
 $reporthtml.=$tdtotalright.getDecimalTwoVal($subtotalMonthmMeter).'</td>'.$tdtotalright.getDecimalTwoVal($subtotalRMBMonth).'</td>'.$tdtotalright.getDecimalTwoVal($subtotalRMBYear).'</td>';
 $reporthtml.=$tdtotalright.getDecimalTwoVal($subtotalcostprice).'</td>';
 $reporthtml.='</tr>';
 $reporthtml.='<tr>';
 $reporthtml.=$tdtotalhtml.'总计</td>'.$tdtotalhtml.'-</td>';
 $reporthtml.=$tdtotalright.getDecimalTwoVal($totalhavearea).'</td>'.$tdtotalright.getDecimalTwoVal($totalsendarea).'</td>'.$tdtotalright.$totalrentpercent.'</td>';
 $reporthtml.=$tdtotalright.getDecimalTwoVal($totalMonthmMeter).'</td>'.$tdtotalright.getDecimalTwoVal($totalRMBMonth).'</td>'.$tdtotalright.getDecimalTwoVal($totalRMBYear).'</td>';
 $reporthtml.=$tdtotalright.getDecimalTwoVal($totalcostprice).'</td>';
 $reporthtml.='</tr>';

 $smarty->assign("REPORTHTML",$reporthtml);

 $smarty->display('Comprehensivereport/HxCrmDetail.tpl');
 function getIntVal($data)
{
    $integ=0;
    $digit='';
    
    if(strpos($data,'.')>0)
    {
         $integ=substr($data,0,strpos($data,'.'));
         $digit=substr($data,strpos($data,'.')+1,1);
         if($digit>=5)
         {
            $integ=$integ+1;
         }
    }
    else
    {
        $integ=$data;
    }
    return $integ;
    
}
 
?>