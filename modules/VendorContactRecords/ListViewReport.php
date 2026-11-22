<?php
/*
{*修改编码格式:统一编码：UTF-8*}
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
    负责人/月度跟踪客户数量
    */
   function getassignUserMonthAccount()
   {
    /*
    add:kara $sql_new_add1
    date:2013-06-18
    reason:bug:3891
    */
       $sql_new_add1=" AND ld_Account.accountname is not null  ";
       $strSQL= " select n.querymonth,n.last_name,count(1) as sumrecordcount from ( select m.querymonth,m.last_name,m.accountname from ( 
                select ld_users.last_name,DATE_FORMAT(contactdate,'%Y-%m') as querymonth,ld_Account.accountname";
       $strSQL .= $this->chartfrom . $this->chartwhere .$this->chartOwner.$sql_new_add1." 
                    order by DATE_FORMAT(contactdate,'%Y-%m')) m  group by  m.querymonth,m.last_name,m.accountname)n  group by n.querymonth,n.last_name";
       return $strSQL;
                
      
   }
   /*
   客户联系次数top10
   */
   function getTopTen()
   {
    /*
    add:kara $sql_new_add1
    date:2013-06-18
    reason:bug:3891
    */
        $sql_new_add1=" AND ld_Account.accountname is not null  ";
        $strSQL="select m.accountname,m.sumCountContact  from ( select ld_Account.accountname ,count(1) as sumCountContact ";
        $strSQL .= $this->chartfrom . $this->chartwhere . $this->chartOwner .$sql_new_add1. " group by ld_Account.accountName ) m  order by m.sumCountContact desc,m.accountname desc  limit 0,10";
        return $strSQL;
   }
   
   /*
   客户联系次数TOP50
   */
   function getFifthTen()
   {  
      /*
      add:kara $sql_new_add1
      date:2013-06-18
      reason: bug:3891
      */
      $sql_new_add1=" AND ld_Account.accountname is not null  ";
      $strSQL="select m.sumCountContact,m.accountname from (select ld_Account.accountname ,count(1) as sumCountContact ";
      $strSQL .= $this->chartfrom . $this->chartwhere .$this->chartOwner . $sql_new_add1 . " group by ld_Account.accountName) m  order by m.sumCountContact desc ,m.accountname desc  limit 0,50";
      return $strSQL;
   }
}
   

?>