<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

class ListViewReport
{
    private $chartfrom;
    private $chartwhere;
    private $chartOwner;
    function __construct($queryfrom,$querywhere,$queryOwner)
    {
       $this->chartfrom=$queryfrom;
       $this->chartwhere=$querywhere;
       $this->chartOwner=$queryOwner;  
    }
    
    /*
    ?	机会创建时间月份统计
    */
   function getPotentialsByCreatedtime()
   {
      $strSQL="select date_format(ld_potential.createdtime,'%Y-%m'),count(distinct ld_potential.potentialid) as sumPotentialsCreatedtime ";
      $strSQL .= $this->chartfrom . $this->chartwhere . $this->chartOwner." 
                    group by date_format(ld_potential.createdtime,'%Y-%m')";

      return $strSQL;      
   }
   
   /*
    ?	负责人机会创建时间月份统计
    */
   function getPotentialsBySmowneridCreatetime()
   {
      $strSQL="select users_assigned_user_id.last_name,date_format(ld_potential.createdtime,'%Y-%m'),count(distinct ld_potential.potentialid) as sumPotentialsCreatedtime  ";
      $strSQL .= $this->chartfrom . $this->chartwhere . $this->chartOwner." 
                     group by date_format(ld_potential.createdtime,'%Y-%m'),users_assigned_user_id.last_name";
       return $strSQL;
      
   }
   
}
   

?>