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
   function getCustomForm12ByLeadSource()
   {
      if(strpos(strtolower($this->chartfrom),"ld_accountscf")==null||strpos(strtolower($this->chartfrom),"ld_accountscf")=='')
      {        
        $this->chartfrom .=" inner join ld_accountscf as T2 on ld_CustomForm11.accountid = T2.accountid  ";
      }
      $strSQL="select T2.leadsource,Count(*) as sumCustomForm12Leadsource  ";
      $strSQL .= $this->chartfrom . $this->chartwhere . $this->chartOwner."  
                    group by T2.leadsource";
       return $strSQL;
      
   }
  
    /*
        订单客户类型分布统计
    */
   function getCustomForm12ByAccountType()
   {
      if(strpos(strtolower($this->chartfrom),"ld_accountscf")==null||strpos(strtolower($this->chartfrom),"ld_accountscf")=='')
      {        
        $this->chartfrom .=" inner join ld_account as T2 on ld_CustomForm12.accountid = T2.accountid  ";
      }
      $strSQL="select T2.account_type,Count(*) as sumCustomForm12AccountType ";
      $strSQL .= $this->chartfrom . $this->chartwhere . $this->chartOwner."  
                    group by T2.account_type";
       return $strSQL;
      
   }
   
     /*
        订单创建时间月份统计
    */
   function getCustomForm12ByCreatedtime()
   {
      $strSQL="select date_format(ld_crmentity.createdtime,'%Y-%m'),count(*) as sumCustomForm12Createdtime ";
      $strSQL .= $this->chartfrom . $this->chartwhere . $this->chartOwner."  
                    group by date_format(ld_crmentity.createdtime,'%Y-%m')";
       return $strSQL;
      
   }
   
    /*
        订单金额TOP10（订单金额最大的�?0个订单，状态不是已作废�?    */
   function getCustomForm12ByTopTentotal()
   {
      $strSQL="select  total as sumCustomForm12TopTentotal,ld_CustomForm12.subject ";
      $strSQL .= $this->chartfrom . $this->chartwhere . $this->chartOwner."  
                   and ld_CustomForm12.sostatus <> '已作�?  order by total desc limit 0,10 ";
       return $strSQL;
      
   }
   
    /*
       订单产品数量TOP10（订单产品数量最多的�?0个订单，状态不是已作废�?    */
   function getCustomForm12ByTopTenproductcount()
   {
      if(strpos(strtolower($this->chartfrom),"ld_accountscf")==null||strpos(strtolower($this->chartfrom),"ld_accountscf")=='')
      {        
        $this->chartfrom .=" inner join ld_inventoryproductrel on ld_CustomForm11.CustomForm11id = ld_inventoryproductrel.id ";
      }
      $strSQL="select sum(quantity) as sumCustomForm12TopTenproductcount,ld_CustomForm12.subject  ";
      $strSQL .= $this->chartfrom . $this->chartwhere . $this->chartOwner."  
                   and ld_CustomForm12.sostatus <> '已作�? group by ld_CustomForm11.subject  order by sum(quantity) desc  limit 0,10 ";
       return $strSQL;
      
   }
   
}
   

?>