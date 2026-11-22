<?php
/**
 * 更新操作
 * Edit:can
 * date:20131106
 * reason:浩星租金收益(利润分析表)
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
    if($month == '0')
    {
        $begin_month = '01';
        $end_month = '12';
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

$smarty->assign("DATETITLE",$_REQUEST['year'].'年'.$_REQUEST['month'].'月');
$begin_date ='';
$begin_date = ''.$year.'-'.$begin_month.'-01';
$end_date = '';
$end_date = ''.$year.'-'.$end_month.'-'.date(t,strtotime($year.'-'.$end_month));
$startyeardate=''.$year.'-01-01';
$endyeardate=''.$year.'-12-31';
$cashbillstartdate=''.$year.'-01-01';
$realMonths=0;//实际月份数目
if($year==date('Y'))
{
    $cashbillendate=''.$year.'-'.date('m').'-'.date(t,strtotime(date()));
    $realMonths=round(date('m'));
}
else
{
    $cashbillendate=''.$year.'-12-31';
    $realMonths=12;
}
$reportmonth=array();
for($j=0;$j<=$realMonths;$j++)
{
    $reportmonth[$j]='';
    $subtotalEveryMonth[$j]=0;
    $totalEveryMonth[$j]=0;
}
//cf_861:结束日期
//duedate:起始日期
//cf_851:地区,havearea：可租面积,产品名称：productname
//sendarea：已租面积，rentpercent：满租率,rmbmonthmeter:月租金/平米
//summonthamount：元/月，sumyearamount：元/年(可收)
//sumcashbillyear:元/年(实收),sumpaymentplanlmonth:（每个月计划收入),plandate:月份
//costprice:成本,cashbilldate:实际收入月份
$sql="select distinct ld_products.costprice, ld_products.productid,ld_productcf.cf_851 ,ifnull(ld_productcf.cf_854,0) as havearea
, ld_productcf.cf_853 as productname,ld_products.productcode,ifnull(ld_sendarea.sendarea,0) as sendarea
,case when ifnull(ld_productcf.cf_854,0)=0 then 0  else ld_sendarea.sendarea/ld_productcf.cf_854 end as rentpercent
,case when sendarea=0 then 0 else ld_monthPaymentPlan.summonthamount/sendarea end as rmbmonthmeter
,sum(ifnull(ld_monthPaymentPlan.summonthamount,0) ) as summonthamount ,sum(ifnull(ld_yearPaymentPlan.sumyearamount,0)) as sumyearamount 
,sum(ifnull(ld_yearcashbill.sumcashbillyear,0))  as sumcashbillyear
,ifnull(ld_eachmonthpaymentplan.plandate,'') as plandate,ifnull(ld_eachmonthpaymentplan.sumpaymentplanmonth,0) as  sumpaymentplanmonth
from ld_products left join ld_productcf on ld_products.productid=ld_productcf.productid inner join
ld_crmentity on ld_crmentity.crmid=ld_products.productid ";
 //计算已租面积
$sql.= "
  left join 
(
select  ld_salesorderdetail.productid ,sum(ifnull(ld_salesorderdetailscf.sendarea,0)) as sendarea
from ld_salesorder inner join ld_crmentity on ld_crmentity.crmid=ld_salesorder.salesorderid left join ld_salesorderdetail on 
ld_salesorderdetail.id=ld_salesorder.salesorderid 
left join ld_salesorderdetailscf on ld_salesorderdetailscf.lineitem_id=ld_salesorderdetail.lineitem_id
inner join ld_products  on ld_products.productid=ld_salesorderdetail.productid
inner join ld_crmentity  ld_productcrm on ld_productcrm.crmid=ld_products.productid
left join ld_salesordercf on ld_salesordercf.salesorderid=ld_salesorder.salesorderid
where ld_salesorder.deleted=0 and ld_products.deleted=0 and ('$begin_date' between duedate and ld_salesordercf.cf_861 or duedate between '". $begin_date."' and '".$end_date."')
group by ld_salesorderdetail.productid 
)  ld_sendarea on ld_sendarea.productid=ld_products.productid ";

$sql.= "
left join
(
select  ld_salesorderdetail.productid ,ld_salesorder.salesorderid
from ld_salesorder inner join ld_crmentity on ld_crmentity.crmid=ld_salesorder.salesorderid left join ld_salesorderdetail on 
ld_salesorderdetail.id=ld_salesorder.salesorderid 
left join ld_salesordercf on ld_salesordercf.salesorderid=ld_salesorder.salesorderid 
where ld_salesorder.deleted=0 and   ('$begin_date' between duedate and ld_salesordercf.cf_861 or duedate between '". $begin_date."' and '".$end_date."')
 )  ld_salesorder on ld_salesorder.productid=ld_products.productid";
 //计算元/月
 $sql.=" left join 
(
select sum(ifnull(amount,0)) as summonthamount,ld_salesorder.salesorderid from ld_paymentplan inner join ld_crmentity on ld_paymentplan.paymentplanid=ld_crmentity.crmid 
inner join ld_salesorder
on ld_salesorder.salesorderid=ld_paymentplan.entitytypeid 
inner join ld_salesorderdetail  on ld_salesorderdetail.id=ld_salesorder.salesorderid
where ld_paymentplan.deleted=0 and plandate between '". $begin_date."' and '".$end_date."' group by ld_salesorderdetail.productid
) ld_monthPaymentPlan   on ld_monthPaymentPlan.salesorderid=ld_salesorder.salesorderid";

 //计算元/年（可收)
 $sql.= "
left join 
(
select sum(ifnull(amount,0)) as sumyearamount,ld_salesorder.salesorderid from ld_paymentplan inner join ld_crmentity on ld_paymentplan.paymentplanid=ld_crmentity.crmid 
inner join ld_salesorder
on ld_salesorder.salesorderid=ld_paymentplan.entitytypeid 
inner join ld_salesorderdetail  on ld_salesorderdetail.id=ld_salesorder.salesorderid
where ld_paymentplan.deleted=0 and plandate  between '". $startyeardate."' and '".$endyeardate."' group by ld_salesorderdetail.productid
) ld_yearPaymentPlan   on ld_yearPaymentPlan.salesorderid=ld_salesorder.salesorderid";
//计算元/年（实收)
$sql.= "
left join 
(
select sum(ifnull(ld_cashbill.total,0))  as sumcashbillyear,ld_salesorder.salesorderid  from ld_cashbill  
inner join ld_crmentity on ld_crmentity.crmid=ld_cashbill.cashbillid 
inner join ld_cashbill2paymentplan on ld_cashbill2paymentplan.CashBillID=ld_cashbill.cashbillid 
inner join ld_salesorder
on ld_salesorder.salesorderid=ld_cashbill2paymentplan.entitytypeid    inner join ld_salesorderdetail  on ld_salesorderdetail.id=ld_salesorder.salesorderid
where ld_cashbill.deleted=0 and cashbilldate between '". $startyeardate."' and '".$endyeardate."' group by ld_salesorderdetail.productid
)  ld_yearcashbill  on ld_salesorder.salesorderid=ld_yearcashbill.salesorderid";
//计算每个月产品的实收金额
$sql.= "
left join 
(
select sum(ifnull(ld_paymentplan.amount,0)) as sumpaymentplanmonth,ld_salesorderdetail.productid,ld_salesorder.salesorderid ,date_format(plandate,'%Y-%m')  as plandate
 from ld_paymentplan
  inner join ld_crmentity on ld_crmentity.crmid=ld_paymentplan.paymentplanid inner join ld_salesorder
on ld_salesorder.salesorderid=ld_paymentplan.salesorderid 
inner join ld_salesorderdetail  on ld_salesorderdetail.id=ld_salesorder.salesorderid
  where ld_paymentplan.deleted=0 and  plandate between '". $cashbillstartdate."' and '".$cashbillendate."' group by ld_salesorderdetail.productid, date_format(plandate,'%Y-%m')
)  ld_eachmonthpaymentplan on  ld_products.productid =ld_eachmonthpaymentplan.productid
where ld_products.deleted=0  and ld_products.discontinued=1 group by ld_products.productid,ld_eachmonthpaymentplan.plandate
order by CONV(HEX(left(CONVERT(ld_productcf.cf_851 USING gbk),1)),16,10) asc, ld_productcf.cf_853 asc ,ld_products.productid asc,ld_eachmonthpaymentplan.plandate asc";
//CONV(HEX(left(CONVERT(ld_productcf.cf_851 USING gbk),1)),16,10)
//echo $sql;
$result=$adb->pquery($sql,array());
$smarty->assign("MOD",$mod_strings);
//$MonthName=array('一','二','三','四','五','六','七','八','九','十','十一','十二');

$MonthName=array('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
foreach($reportmonth as $kmonth=>$kvalue)
{
    if($kmonth!=count($reportmonth)-1)
        $reportmonthHeader.='<td class="colHeader small" align="center" width="80">'.$MonthName[$kmonth].'(RMB)</td>';
}

$smarty->assign('REPORTMONTHHEADER',$reportmonthHeader);
if($adb->num_rows($result)<=0)
{
    $smarty->display('Comprehensivereport/HxCrmPaymentplan.tpl');
    return ;
}
$reporthtml='';
$tdtotalhtml='<td class="listTableRow small" style="background-color:#EEEEEE;">';
$tdtotalright='<td class="listTableRow small" style="background-color:#EEEEEE;" align="right">';
$tdright='<td class="listTableRow" align="right">';
$tdhtml='<td class="listTableRow">';
$subtotalhavearea=0;
$subtotalsendarea=0;
$subtotalcostprice=0;
$subtotalRMBMonth=0;
$subtotalRMBPaymentYear=0;
$subtotalRMBCashBillYear=0;
$totalcostprice=0;
$totalsendarea=0;
$totalhavearea=0;
$totalRMBMonth=0;
$totalRMBPaymentYear=0;
$totalRMBCashBillYear=0;
$lastmonth='';

$lastproductregion=$adb->query_result($result,0,'cf_851');
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $productid=$adb->query_result($result,$i,'productid');//产品id
   
    $productregion=$adb->query_result($result,$i,'cf_851');//地区
    $productname=$adb->query_result($result,$i,'productname');//产品名称
    $productid=$adb->query_result($result,$i,'productid');//产品id
    $havearea=$adb->query_result($result,$i,'havearea');//可租面积
    $sendarea=$adb->query_result($result,$i,'sendarea');//已租面积
    $rentpercent=getIntVal($adb->query_result($result,$i,'rentpercent')*100).'%';//满租率
    $RMBPaymentYear=$adb->query_result($result,$i,'sumyearamount');//元/年(可收)
    $RMBCashBillYear=$adb->query_result($result,$i,'sumcashbillyear');//元/年(实收)
    $RMBMonth=$adb->query_result($result,$i,'summonthamount');//元/月
    $RMBMonthMeter=$adb->query_result($result,$i,'rmbmonthmeter');//月租金
    $costPrice=$adb->query_result($result,$i,'costprice');//成本
    $productcode=$adb->query_result($result,$i,'productcode');//性质
    
    //毛利率
    if(empty($costPrice))
    {
        $grossprofit=0;
    }
    else
    {
        $grossprofit=getIntVal($RMBPaymentYear/$costPrice*100).'%';
        
    }
    
    if($lastproductregion!=$productregion)
    {
        $totalhavearea+=$subtotalhavearea;
        $totalsendarea+=$subtotalsendarea;
        $totalRMBPaymentYear+=$subtotalRMBPaymentYear;
        $totalRMBCashBillYear+=$subtotalRMBCashBillYear;
        $totalRMBMonth+=$subtotalRMBMonth;
        $totalcostprice+=$subtotalcostprice;
        for($k=0;$k<$realMonths;$k++)
        {
            //实际收入每个月份的合计
            $totalEveryMonth[$k]+=$subtotalEveryMonth[$k];
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
        //月租金/平米
        if(empty($subtotalsendarea))
        {
            $subtotalEveryMonthMeter=number_format(0,2);
        }
        else
        {
            $subtotalEveryMonthMeter=round($subtotalRMBMonth/$subtotalsendarea,2);
        }
        //毛利率小计
        if(empty($subtotalcostprice))
        {
            $subtotalgrossprofit='0%';
        }
        else
        {
            $subtotalgrossprofit=getIntVal($subtotalRMBPaymentYear/$subtotalcostprice*100).'%';
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
        $reporthtml.=$tdtotalhtml.'小计</td>'.$tdtotalhtml.'-</td>'.$tdtotalright.getDecimalTwoVal($subtotalhavearea).'</td>';
        $reporthtml.=$tdtotalright.getDecimalTwoVal($subtotalsendarea).'</td>'.$tdtotalright.$subtotalrentpercent.'</td>'.$tdtotalright.getDecimalTwoVal($subtotalRMBPaymentYear).'</td>';
        $reporthtml.=$tdtotalright.getDecimalTwoVal($subtotalRMBCashBillYear).'</td>'.$tdtotalright.getDecimalTwoVal($subtotalRMBMonth).'</td>'.$tdtotalright.getDecimalTwoVal($subtotalEveryMonthMeter).'</td>';
        $reporthtml.=$tdtotalright.getDecimalTwoVal($subtotalcostprice).'</td>'.$tdtotalright.$subtotalgrossprofit.'</td>';
        for($k=0;$k<$realMonths;$k++)
        {
            //每个月份实际收入小计
            $reporthtml.=$tdtotalright.getDecimalTwoVal($subtotalEveryMonth[$k]).'</td>';
            $subtotalEveryMonth[$k]=number_format(0,2);
        }
        $reporthtml.='</tr>';
        $subtotalhavearea=0;
        $subtotalsendarea=0;
        $subtotalcostprice=0;
        $subtotalRMBMonth=0;
        $subtotalRMBPaymentYear=0;
        $subtotalRMBCashBillYear=0;
        $lastproductregion=$productregion;
    }
     if($lastproductid!=$productid)
    {
        if(empty($sendarea))
        {
            $sendarea=number_format(0,2);
        }
        if(empty($havearea))
        {
            $havearea=number_format(0,2);
        }
        //相同产品合并为一行
        $reporthtml.='<tr>';
        $reporthtml.=$tdhtml.$productregion.'</td>'.$tdhtml.$productname.'</td>'.$tdright.getDecimalTwoVal($havearea).'</td>';
        $reporthtml.=$tdright.getDecimalTwoVal($sendarea).'</td>'.$tdright.$rentpercent.'</td>'.$tdright.getDecimalTwoVal($RMBPaymentYear).'</td>';
        $reporthtml.=$tdright.getDecimalTwoVal($RMBCashBillYear).'</td>'.$tdright.getDecimalTwoVal($RMBMonth).'</td>'.$tdright.getDecimalTwoVal($RMBMonthMeter).'</td>';
        $reporthtml.=$tdright.getDecimalTwoVal($costPrice).'</td>'.$tdright.$grossprofit.'</td>';
        $lastproductid=$productid;
        $codes=explode('Car Park',$productname);
        if(count($codes)<2)//去除产品英文名称包含Car Park的可租面积
        {
            $subtotalhavearea+=$havearea;
        }
        if(count($codes)<2)
        {
            $subtotalsendarea+=$sendarea;
        }
        
        $subtotalRMBPaymentYear+=$RMBPaymentYear;
        $subtotalRMBCashBillYear+=$RMBCashBillYear;
        $subtotalRMBMonth+=$RMBMonth;
        $subtotalcostprice+=$costPrice;
       
        $m=0;
        
        while(true)
        {
            //把相同产品下月份合并为一行
            $plandate=$adb->query_result($result,$i,'plandate');
            if(empty($plandate)){
                $mth=intval(date('m',strtotime(date('y-m').'-01')))-1;
            }else{
                $mth=intval(date('m',strtotime($plandate.'-01')))-1;
            }
            
           
            $RMBcashbillmonth=$adb->query_result($result,$i,'sumpaymentplanmonth');//产品每个月实际收入金额
            for($m;$m<$mth;$m++)
            {
                $reporthtml.=$tdright.'0.00</td>';
                $subtotalEveryMonth[$m]+=number_format(0,2);
            }
            $reporthtml.=$tdright.getDecimalTwoVal($RMBcashbillmonth).'</td>';
            $subtotalEveryMonth[$m]+=$RMBcashbillmonth;
            $m++;
        
            $i++;
            //echo $productid."<br>";
            //echo $adb->query_result($result,$i,'productid')."<br>";
            if($adb->query_result($result,$i,'productid')!=$productid)
            {
               $i--;
                break;
            }
        }
        for($m;$m<$realMonths;$m++)
        {
             $reporthtml.=$tdright.'0.00</td>';
        }
        $reporthtml.'</tr>';
        
    }      
}

//最后一个地区的小计
$totalhavearea+=$subtotalhavearea;
$totalsendarea+=$subtotalsendarea;
$totalRMBPaymentYear+=$subtotalRMBPaymentYear;
$totalRMBCashBillYear+=$subtotalRMBCashBillYear;
$totalRMBMonth+=$subtotalRMBMonth;
$totalcostprice+=$subtotalcostprice;
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
for($k=0;$k<$realMonths;$k++)
{
    //实际收入每个月份的合计
    $totalEveryMonth[$k]+=$subtotalEveryMonth[$k];
}
//满租率小计
if(empty($subtotalhavearea))
{
    $subtotalrentpercent=0;
}
else
{
    $subtotalrentpercent=getIntVal($subtotalsendarea/$subtotalhavearea*100).'%';
}
//月租金/平米
if(empty($subtotalsendarea))
{
    $subtotalEveryMonthMeter=number_format(0,2);
}
else
{
    $subtotalEveryMonthMeter=round($subtotalRMBMonth/$subtotalsendarea,2);
}
//毛利率小计
if(empty($subtotalcostprice))
{
    $subtotalgrossprofit='0%';
}
else
{
    $subtotalgrossprofit=getIntVal($subtotalRMBPaymentYear/$subtotalcostprice*100).'%';
}
$reporthtml.='<tr>';
$reporthtml.=$tdtotalhtml.'小计</td>'.$tdtotalhtml.'-</td>'.$tdtotalright.getDecimalTwoVal($subtotalhavearea).'</td>';
$reporthtml.=$tdtotalright.getDecimalTwoVal($subtotalsendarea).'</td>'.$tdtotalright.$subtotalrentpercent.'</td>'.$tdtotalright.getDecimalTwoVal($subtotalRMBPaymentYear).'</td>';
$reporthtml.=$tdtotalright.getDecimalTwoVal($subtotalRMBCashBillYear).'</td>'.$tdtotalright.getDecimalTwoVal($subtotalRMBMonth).'</td>'.$tdtotalright.getDecimalTwoVal($subtotalEveryMonthMeter).'</td>';
$reporthtml.=$tdtotalright.getDecimalTwoVal($subtotalcostprice).'</td>'.$tdtotalright.$subtotalgrossprofit.'</td>';


//小计
for($k=0;$k<$realMonths;$k++)
{
            //每个月份实际收入小计
    $reporthtml.=$tdtotalright.getDecimalTwoVal($subtotalEveryMonth[$k]).'</td>';
    //$totalEveryMonth[$k]=number_format(0,2);
}
$reporthtml.='</tr>';


//满租率总计
if(empty($totalhavearea))
{
    $totalrentpercent='0%';
}
else
{
    $totalrentpercent=getIntVal($totalsendarea/$totalhavearea*100).'%';
}
//月租金/平米
if(empty($totalsendarea))
{
    $totalEveryMonthMeter=number_format(0,2);
}
else
{
    $totalEveryMonthMeter=round($totalRMBMonth/$totalsendarea,2);
}
//毛利率总计
if(empty($totalcostprice))
{
    $totalgrossprofit=0;
}
else
{
    $totalgrossprofit=getIntVal($totalRMBPaymentYear/$totalcostprice*100).'%';
}
$reporthtml.='<tr>';
$reporthtml.=$tdtotalhtml.'总计</td>'.$tdtotalhtml.'-</td>'.$tdtotalright.getDecimalTwoVal($totalhavearea).'</td>';
$reporthtml.=$tdtotalright.getDecimalTwoVal($totalsendarea).'</td>'.$tdtotalright.$totalrentpercent.'</td>'.$tdtotalright.getDecimalTwoVal($totalRMBPaymentYear).'</td>';
$reporthtml.=$tdtotalright.getDecimalTwoVal($totalRMBCashBillYear).'</td>'.$tdtotalright.getDecimalTwoVal($totalRMBMonth).'</td>'.$tdtotalright.getDecimalTwoVal($totalEveryMonthMeter).'</td>';
$reporthtml.=$tdtotalright.getDecimalTwoVal($totalcostprice).'</td>'.$tdtotalright.$totalgrossprofit.'</td>';
for($k=0;$k<$realMonths;$k++)
{
            //每个月份实际收入总计
    $reporthtml.=$tdtotalright.getDecimalTwoVal($totalEveryMonth[$k]).'</td>';
}
$reporthtml.='</tr>';

$smarty->assign("REPORTHTML",$reporthtml);
$smarty->display('Comprehensivereport/HxCrmPaymentplan.tpl');

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