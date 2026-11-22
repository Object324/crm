<?php
/*
 *{*修改编码格式:统一编码：UTF-8*}
 */
class ListViewReport
{
    private $chartfrom;
    private $chartwhere;
    private $chartOwner;
    function ListViewReport($queryfrom,$querywhere,$queryOwner)
    {
       $this->chartfrom=$queryfrom;
       $this->chartwhere=$querywhere;
       $this->chartOwner=$queryOwner;  
    }
    
    /*
        订单客户来源分布统计
    */
   function getCustomForm167ByLeadSource()
   {
      if(strpos(strtolower($this->chartfrom),"ld_accountscf")==null||strpos(strtolower($this->chartfrom),"ld_accountscf")=='')
      {        
        $this->chartfrom .=" inner join ld_accountscf as T2 on ld_customform167.accountid = T2.accountid  ";
      }
      $strSQL="select T2.leadsource,Count(*) as sumCustomForm167Leadsource  ";
      $strSQL .= $this->chartfrom . $this->chartwhere . $this->chartOwner."  
                    group by T2.leadsource";
       return $strSQL;
      
   }
  
    /*
        订单客户类型分布统计
    */
   function getCustomForm167ByAccountType()
   {
      if(strpos(strtolower($this->chartfrom),"ld_accountscf")==null||strpos(strtolower($this->chartfrom),"ld_accountscf")=='')
      {        
        $this->chartfrom .=" inner join ld_account as T2 on ld_customform167.accountid = T2.accountid  ";
      }
      $strSQL="select T2.account_type,Count(*) as sumCustomForm167AccountType ";
      $strSQL .= $this->chartfrom . $this->chartwhere . $this->chartOwner."  
                    group by T2.account_type";
       return $strSQL;
      
   }
   
     /*
        订单创建时间月份统计
    */
   function getCustomForm167ByCreatedtime()
   {
      $strSQL="select date_format(ld_crmentity.createdtime,'%Y-%m'),count(*) as sumCustomForm167Createdtime ";
      $strSQL .= $this->chartfrom . $this->chartwhere . $this->chartOwner."  
                    group by date_format(ld_crmentity.createdtime,'%Y-%m')";
       return $strSQL;
      
   }
   
    /*
        订单金额TOP10（订单金额最大的�?0个订单，状态不是已作废�?    */
   function getCustomForm167ByTopTentotal()
   {
      $strSQL="select  total as sumCustomForm167TopTentotal,ld_customform167.subject ";
      $strSQL .= $this->chartfrom . $this->chartwhere . $this->chartOwner."  
                   and ld_customform167.sostatus <> '已作�?  order by total desc limit 0,10 ";
       return $strSQL;
      
   }
   
    /*
       订单产品数量TOP10（订单产品数量最多的�?0个订单，状态不是已作废�?    */
   function getCustomForm167ByTopTenproductcount()
   {
      if(strpos(strtolower($this->chartfrom),"ld_accountscf")==null||strpos(strtolower($this->chartfrom),"ld_accountscf")=='')
      {        
        $this->chartfrom .=" inner join ld_inventoryproductrel on ld_customform167.customform167id = ld_inventoryproductrel.id ";
      }
      $strSQL="select sum(quantity) as sumCustomForm167TopTenproductcount,ld_customform167.subject  ";
      $strSQL .= $this->chartfrom . $this->chartwhere . $this->chartOwner."  
                   and ld_customform167.sostatus <> '已作�? group by ld_customform167.subject  order by sum(quantity) desc  limit 0,10 ";
       return $strSQL;
      
   }
   
}
   

?>