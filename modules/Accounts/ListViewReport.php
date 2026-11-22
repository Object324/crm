<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
require_once("modules/Accounts/Accounts.php");
class ListViewReport
{
    private $chartfrom;
    private $chartfrom2;
    private $chartwhere;
    private $chartOwner;
    function __construct($queryfrom,$querywhere,$queryOwner)
    {
       $this->chartfrom=$queryfrom;
       $this->chartfrom2=$queryfrom;
       $this->chartwhere=$querywhere;
       $this->chartOwner=$queryOwner;  
    }
    
    /*
        客户类型与状态分布统计
    */
   function getAccountByactivitytype()
   {
      $strSQL=" select ld_account.rating,ld_account.account_type,count( distinct ld_account.accountid) as sumPotentialsCreatedtime   ";
      $strSQL .= $this->chartfrom . $this->chartwhere .$this->chartOwner." 
                     group by ld_account.account_type,ld_account.rating";
      return $strSQL;      
   }
   
   /*
        热度分布统计（只统计热点客户）
    */
   function getAccountByhotdegree()
   {
      $strSQL=" select hotdegree,count(ld_accountscf.hotdegree) as sumhotdegree   ";
      $strSQL .= $this->chartfrom . $this->chartwhere .$this->chartOwner." 
                   and ld_accountscf.hotaccount = 1 group by ld_accountscf.hotdegree ";
       return $strSQL;          
   }
   /*
        省份分布统计
    */ 
   function getAccountsBillState(){
      $strSQL=" select bill_state, count(accountid) AS sumbill_state ";
      $strSQL.=" from (select distinct ld_account.accountid, 
            case when LENGTH(ld_account.bill_state)<1 OR ld_account.bill_state='--无--' OR ld_account.bill_state is NULL THEN '' ELSE ld_account.bill_state END AS bill_state";
      $strSQL.=$this->chartfrom." WHERE ld_account.accountid IN ( SELECT DISTINCT ld_account.accountid ".$this->chartfrom.$this->chartwhere.$this->chartOwner;
      $strSQL.=")) as T GROUP BY bill_state ORDER BY count(accountid) desc";
      return $strSQL;
   }
   /*
        城市分布统计
    */
   function getAccountsBillCity(){
      $strSQL=" select concat(bill_state,bill_city) AS bill_city, count(accountid) AS sumbill_city ";
      $strSQL.=" from (select distinct ld_account.accountid, 
            case when LENGTH(ld_account.bill_city)<1 OR ld_account.bill_city='--无--' OR ld_account.bill_city is NULL THEN '' ELSE ld_account.bill_city END AS bill_city, 
            case when LENGTH(ld_account.bill_city)<1 OR ld_account.bill_city='--无--' OR ld_account.bill_city is NULL THEN '' ELSE ld_account.bill_state END AS bill_state";
      $strSQL.=$this->chartfrom." WHERE ld_account.accountid IN ( SELECT DISTINCT ld_account.accountid ".$this->chartfrom.$this->chartwhere.$this->chartOwner;
      $strSQL.=")) as T GROUP BY bill_state,bill_city ORDER BY count(accountid) desc";
      return $strSQL;
   }
   /*
        热度分类分布统计（只统计热点客户）
    */
   function getAccountByhottypehotdegree()
   {
       $strSQL=" select hotdegree,hottype,count(ld_accountscf.hotdegree) as sumhotdegree   ";
       $strSQL .= $this->chartfrom . $this->chartwhere .$this->chartOwner." 
                   and ld_accountscf.hotaccount = 1 group by ld_accountscf.hotdegree,ld_accountscf.hottype  ";
       return $strSQL;          
   }
   
   /*
       签约金额TOP10（统计订单状态不是已作废的数据）
    */
   function getAccountByTopTentotal()
   {     
        $servicecontractsql=' from (select ld_account.accountname,ld_account.accountid '.$this->chartfrom .$this->chartwhere .$this->chartOwner.' group by ld_account.accountid)' .' as ld_account';
       $servicecontractsql .=" inner join ld_servicecontracts on ld_account.accountid = ld_servicecontracts.accountid ";
       $servicestrSQL="select sum(if(ld_servicecontracts.currency_id > 1,ld_servicecontracts.total/ld_servicecontracts.conversion_rate,ld_servicecontracts.total)) as sumAccountTopTentotal,ld_account.accountname  ";
      $servicestrSQL .=  $servicecontractsql." 
                   where  ld_servicecontracts.contract_status <> '已作废' and ld_servicecontracts.approvestatus <> '已拒绝' and ld_servicecontracts.deleted=0 group by ld_account.accountname  ";
                   
      
        $otherSQL=' from (select ld_account.accountname,ld_account.accountid '.$this->chartfrom .$this->chartwhere .$this->chartOwner.' group by ld_account.accountid)' .' as ld_account';
  
        $otherSQL .=" inner join ld_salesorder on ld_account.accountid = ld_salesorder.accountid ";
          
   
     $strsalesorderSQL="select sum(if(ld_salesorder.currency_id > 1,ld_salesorder.total/ld_salesorder.conversion_rate,ld_salesorder.total)) as sumAccountTopTentotal,ld_account.accountname  ";
     $strsalesorderSQL .=  $otherSQL." 
                   where  ld_salesorder.sostatus <> '已作废' and ld_salesorder.approvestatus <> '已拒绝' and ld_salesorder.deleted=0 group by ld_account.accountname  ";
  
       
       $tmpsql="select sum(sumAccountTopTentotal) as sumAccountTopTentotal ,accountname from ( " .$servicestrSQL.' union all '.$strsalesorderSQL.") as tmptable group by accountname ";
      $tmpsql='select * from ('.$tmpsql.') as tmpone   order by sumAccountTopTentotal desc limit 0,10';
     return $tmpsql;
     //
   }
   
   /*
       签约金额TOP50（统计订单状态不是已作废的数据）
    */
   function getAccountByTopFiftytotal()
   {
    $otherserviceSQL=' from (select ld_account.accountname,ld_account.accountid '.$this->chartfrom .$this->chartwhere .$this->chartOwner.' group by ld_account.accountid)' .' as ld_account';
     
      $otherserviceSQL .=" INNER JOIN ld_servicecontracts  ON ld_servicecontracts.accountid =ld_account.accountid";
      $strserviceSQL="select sum(if(ld_servicecontracts.currency_id > 1,ld_servicecontracts.total/ld_servicecontracts.conversion_rate,ld_servicecontracts.total)) as sumAccountTopTentotal,ld_account.accountname ";
      $strserviceSQL .=  $otherserviceSQL." 
                  where  ld_servicecontracts.contract_status <> '已作废' and ld_servicecontracts.approvestatus <> '已拒绝' and ld_servicecontracts.deleted=0   group by ld_account.accountname ";
  
  
     $otherSQL=' from (select ld_account.accountname,ld_account.accountid '.$this->chartfrom .$this->chartwhere .$this->chartOwner.' group by ld_account.accountid)' .' as ld_account';
     
      $otherSQL .=" INNER JOIN ld_salesorder  ON ld_salesorder.accountid =ld_account.accountid";
      $strsalesorderSQL="select sum(if(ld_salesorder.currency_id > 1,ld_salesorder.total/ld_salesorder.conversion_rate,ld_salesorder.total)) as sumAccountTopTentotal,ld_account.accountname ";
      $strsalesorderSQL .=  $otherSQL." 
                  where  ld_salesorder.sostatus <> '已作废' and ld_salesorder.approvestatus <> '已拒绝' and ld_salesorder.deleted=0   group by ld_account.accountname ";
     $tmpsql="select sum(sumAccountTopTentotal) as sumAccountTopTentotal,accountname from ( " .$strserviceSQL.' union all '.$strsalesorderSQL.") as tmptable group by accountname ";
    $tmpsql='select * from ('.$tmpsql.') as tmpone   order by sumAccountTopTentotal desc limit 0,50';
      return $tmpsql;
   }
   
   /*
    	回款金额TOP10（统计发票状态是已付款的数据）
    */
   function getAccountByTopTeninvoicetotal()
   {
          
      $otherSQL=' from (select ld_account.accountname,ld_account.accountid '.$this->chartfrom .$this->chartwhere .$this->chartOwner.' group by ld_account.accountid)' .' as ld_account';
      $otherSQL .=" inner join ld_cashbill on ld_account.accountid = ld_cashbill.accountid";
      $strSQL="select ifnull(sum(if(ld_cashbill.currency_id > 1,ld_cashbill.total/ld_cashbill.conversion_rate,ld_cashbill.total)),0) as sumaccounttopteninvoicetotal,ld_account.accountname ";
      $strSQL .=  $otherSQL." 
                   where   ld_cashbill.deleted=0 group by ld_account.accountname order by sumaccounttopteninvoicetotal desc limit 0,10 ";
       return $strSQL;
   }
   
   /*
      	回款金额TOP50（统计发票状态是已付款的数据）
    */
   function getAccountByTopFiftyinvoicetotal()
   {
      
      $otherSQL=' from (select ld_account.accountid,ld_account.accountname '.  $this->chartfrom .$this->chartwhere .$this->chartOwner .' group by ld_account.accountid)' .' as ld_account';
  
        $otherSQL.=" inner join ld_cashbill on ld_account.accountid = ld_cashbill.accountid ";
      
     $otherSQL .=" inner join ld_crmentity as paymentplancrm on paymentplancrm.crmid=ld_cashbill.cashbillid";
      
     $strSQL="select ifnull(sum(if(ld_cashbill.currency_id > 1,ld_cashbill.total/ld_cashbill.conversion_rate,ld_cashbill.total)),0) as sumaccounttopfiftyinvoicetotal,ld_account.accountname ".$otherSQL;
      $strSQL .= " 
                   where   ld_cashbill.deleted=0  group by ld_account.accountname order by sumAccountTopFiftyinvoicetotal desc limit 0,50"; 

      return $strSQL;
    
   }
   
   /*
     	应收款客户排行top10
    */
   function getAccountByTopTenreceivable()
   {
       global $current_user;
       $strAccount="select  ld_account.accountid,ld_account.accountname ,ld_crmentity.smownerid ". $this->chartfrom.$this->chartwhere .$this->chartOwner;
       $strSalesorder="select salesorderid,total,taccount.accountname from ld_salesorder inner join ( ";
       $strSalesorder .=$strAccount .") taccount on taccount.accountid=ld_salesorder.accountid";
       $strSalesorder .=" inner join ld_crmentity on ld_crmentity.crmid=ld_salesorder.salesorderid where ld_salesorder.deleted=0  and ld_salesorder.sostatus <> '已作废' ";
    
       
       $strInvoice="select total,salesorderid from ld_invoice 
       inner join ld_crmentity on ld_crmEntity.crmid=ld_invoice.invoiceid 
                where ld_invoice.invoicestatus = '已付款' and  ld_crmentity.deleted=0  ";
                
        $strSQL="select sum( ifnull(ta.total,0))-sum(ifnull(ta.received_total,0))as sumaccounttoptenreceivable,ta.accountname   ";
        $strSQL .=" from (".$strSalesorder . " )ta";
        $strSQL .=" left join ( ".$strInvoice ." )tb on ta.salesorderid=tb.salesorderid ";
        
        $strSQL .=" group by ta.accountname order by sumaccounttoptenreceivable desc limit 0,10 ";             
      
      $strAccount="select  DISTINCT ld_account.accountid,ld_account.accountname ,ld_account.smownerid ". $this->chartfrom.$this->chartwhere .$this->chartOwner;
       
       $strSalesorder="select sum( if(ld_salesorder.currency_id > 1,ifnull(total,0)/ld_salesorder.conversion_rate,ifnull(total,0))) as total,sum(received_amount) as received_total,taccount.accountid from ld_salesorder inner join ( ";
       $strSalesorder .=$strAccount .") taccount on taccount.accountID=ld_salesorder.accountid";
       $strSalesorder .=" where ld_salesorder.deleted=0  and ld_salesorder.sostatus <> '已作废' 
                        group by taccount.accountid ";
       
       $strcashbill="select sum(if(ld_cashbill.currency_id > 1,ifnull(subtotal,0)/ld_cashbill.conversion_rate,ifnull(subtotal,0)) ) as subtotal,accountid  
                    from ld_cashbill inner join ld_crmentity on ld_crmentity.crmid=ld_cashbill.cashbillid 
                    where ld_cashbill.deleted=0 group by accountid ";
                
       $sql ="select  ifnull(ta.total,0)-ifnull(ta.received_total,0)as sumaccounttoptenreceivable,ta.accountid   ";
       $sql .=" from (".$strSalesorder . " ) as ta";
       $sql .=" left join ( ".$strcashbill ." ) as tb  on ta.accountid=tb.accountid  
               order by sumaccounttoptenreceivable desc limit 0,10 ";
           
        $sql_all = "select tc.sumaccounttoptenreceivable, td.accountname
                   from ( ".$sql.")as tc 
                   left join  ld_account as td on tc.accountid = td.accountid;";
      return $sql_all;
   }  
   /*
     	应收款/负责人分布统计
    */
   function getAccountByreceivablesmowner()
   {
       global $current_user;
       $strAccount="select  ld_account.accountid,ld_account.accountname ,ld_account.smownerid ". $this->chartfrom.$this->chartwhere .$this->chartOwner;
       
       $strSalesorder="select sum( if(ld_salesorder.currency_id > 1,ifnull(total,0)/ld_salesorder.conversion_rate,ifnull(total,0))) as total,taccount.accountid from ld_salesorder inner join ( ";
       $strSalesorder .=$strAccount .") taccount on taccount.accountid=ld_salesorder.accountid";
       $strSalesorder .="  where ld_salesorder.deleted=0  and ld_salesorder.sostatus <> '已作废' 
                        group by taccount.accountid ";
       
       $strcashbill="select sum(if(ld_cashbill.currency_id > 1,ifnull(subtotal,0)/ld_cashbill.conversion_rate,ifnull(subtotal,0)) ) as subtotal,accountid  
                    from ld_cashbill 
                    where ld_cashbill.deleted=0 group by accountid ";
                
       $sql ="select  ifnull(ta.total,0)-ifnull(tb.subtotal,0)as sumaccounttoptenreceivable,ta.accountid   ";
       $sql .=" from (".$strSalesorder . " ) as ta";
       $sql .=" left join ( ".$strcashbill ." ) as tb  on ta.accountid=tb.accountid  
               order by sumaccounttoptenreceivable desc limit 0,10 "; 
                         
       $sql_all = "select sum(ifnull(T1.sumaccounttoptenreceivable,0)) as sumaccounttoptenreceivable, ld_users.last_name  from 
                  (".$sql.") as T1 left join  ld_account as T2 on T1.accountid = T2.accountid
                  left JOIN ld_crmentity ON T2.accountid = ld_crmentity.crmid LEFT JOIN ld_users 
                  ON T2.smownerid = ld_users.id group by ld_users.last_name ";                          
      return $sql_all;
     
   }
   
   /*
     	客户日程/联系记录TOP50 
    */
   function getAccountByCalendarContactRecords()
   {
       global $current_user;
       /*
       edit:can
       date:20130426
       reason:0003844: 客户列表中 客户日程/联系记录统计表统计的信息不对，将日程或者联系记录删除到回收站 但是在界面上还是统计了被删除的记录
       */
	   //23794: 客户列表：新增数据分类，点击本次查询统计图表-客户日程/联系记录TOP50，点击报错
      if(strpos(strtolower($this->chartfrom),"ld_activity")==null||strpos(strtolower($this->chartfrom),"ld_activity")=='')
      {        
        $this->chartfrom .=" inner join ld_activity on ld_account.accountid = ld_activity.accountid inner join ld_crmentity  as actcrm on actcrm.crmid=ld_activity.activityID LEFT JOIN ld_tabshare on ld_tabshare.viewuserid = ld_account.accountid";
      }
      if(strpos(strtolower($this->chartfrom2),"ld_contactrecords")==null||strpos(strtolower($this->chartfrom2),"ld_contactrecords")=='')
      {
        $this->chartfrom2 .=" inner join ld_contactrecords on ld_account.accountid = ld_contactrecords.accountid inner join ld_crmentity as recordcrm on recordcrm.crmid=ld_contactrecords.contactrecordid LEFT JOIN ld_tabshare on ld_tabshare.viewuserid = ld_account.accountid";
      }
      
      $strSQL=" select (ifnull(ta.activitycount,0)+ ifnull(tb.contactrecordscount,0)) as sumaccountcalendarcontactrecords,ld_account.accountname from ld_account left join 
     (select ld_activity.accountid,count(ld_activity.accountid) as activitycount " 
     . $this->chartfrom . $this->chartwhere .$this->chartOwner."
       and ld_activity.deleted=0 group by ld_activity.accountid) as ta on 
     ld_account.accountid =  ta.accountid 
     left join 
     (select ld_contactrecords.accountid,count(ld_contactrecords.accountid) as contactrecordscount  " 
     . $this->chartfrom2 . $this->chartwhere .$this->chartOwner." 
    and ld_contactrecords.deleted=0 group by ld_contactrecords.accountid) as tb on 
     ld_account.accountid = tb.accountid where  ta.activitycount > 0 or tb.contactrecordscount >0 
     order by sumaccountcalendarcontactrecords desc limit 0,50 ";
     return $strSQL;
   }
}
?>