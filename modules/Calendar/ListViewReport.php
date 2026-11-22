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
        ?日程类型分布统计
    */
   function getCalendarByactivitytype()
   {
      if(strpos(strtolower($this->chartfrom),"ld_users")==null||strpos(strtolower($this->chartfrom),"ld_users")=='')
      {        
        $this->chartfrom .=" inner join ld_users ON ld_activity.smownerid = ld_users.id ";
      }
      $strSQL="select activitytype,count(ld_activity.activitytype) as sumCalendaractivitytype ";
      //24838: 日程管理：事件类型分布统计表上显示2个“上门”
      $strSQL .= ' from  (select distinct ld_activity.activityid  ' .$this->chartfrom . $this->chartwhere . $this->chartOwner." ) as tmp 
                    inner join ld_activity on ld_activity.activityid=tmp.activityid
                    group by rtrim(ld_activity.activitytype) ";
        
      return $strSQL;      
   }
  
    /*
        日程状态分布统计
    */
   function getCalendarByaeventstatus()
   {
      if(strpos(strtolower($this->chartfrom),"ld_users")==null||strpos(strtolower($this->chartfrom),"ld_users")=='')
      {        
        $this->chartfrom .=" inner join ld_users ON ld_activity.smownerid = ld_users.id ";
      }
     
      $strSQL="select eventstatus,count(ld_activity.eventstatus) as sumCalendareventstatus ";
      $strSQL .= ' from  (select distinct ld_activity.activityid  ' .$this->chartfrom . $this->chartwhere . $this->chartOwner." ) as tmp 
                    inner join ld_activity on ld_activity.activityid=tmp.activityid
                    group by ld_activity.eventstatus ";
      return $strSQL;      
   }
   
     /*
        负责人分布统计
    */
   function getCalendarBySmownerid()
   {
      if(strpos(strtolower($this->chartfrom),"ld_users")==null||strpos(strtolower($this->chartfrom),"ld_users")=='')
      {        
        $this->chartfrom .=" inner join ld_users ON ld_activity.smownerid = ld_users.id ";
      }
      
      $strSQL="select ld_users.last_name,count(ld_users.last_name) as sumCalendarSmownerid  ";
      $strSQL .=' from  (select distinct ld_activity.activityid  ' .$this->chartfrom . $this->chartwhere . $this->chartOwner." ) as tmp 
                    inner join ld_activity on ld_activity.activityid=tmp.activityid
                     left join ld_users on ld_users.id=ld_activity.smownerid
                    group by ld_users.last_name";
       return $strSQL;
      
   }
   
    /*
        客户日程次数TOP10
    */
   function getCalendarByTopTenCount()
   {
      if(strpos(strtolower($this->chartfrom),"ld_users")==null||strpos(strtolower($this->chartfrom),"ld_users")=='')
      {        
        $this->chartfrom .=" inner join ld_users ON ld_activity.smownerid = ld_users.id ";
      }
      if(strpos(strtolower($this->chartfrom),"ld_account")==null||strpos(strtolower($this->chartfrom),"ld_account")=='')
      {        
        $this->chartfrom .=" inner join ld_account ON ld_account.accountid = ld_activity.accountid ";
      }
    /*
    add:kara $sql_new_add1,2
    date:2013-06-18
    reason:bug:3891
    */
      $sql_new_add1=" FROM ld_activity 
            INNER JOIN ld_crmentity ON ld_activity.activityid = ld_crmentity.crmid 
            LEFT JOIN ld_users ON ld_activity.smownerid = ld_users.id 
            left join ld_account on ld_account.accountid=ld_activity.accountid ";
     // $sql_new_add2=" WHERE ld_activity.activityid > 0 AND ld_activity.deleted = 0  AND ld_activity.accountid>0 and ld_account.deleted=0 ";
      //$this->chartfrom=$sql_new_add1;
      $this->chartwhere.=' AND ld_activity.accountid>0';
     
      $strSQL=" select m.sumcalendartoptencount,m.accountname from 
                    ( select ld_account.accountname , count(ld_activity.accountid) as sumcalendartoptencount ";
      $strSQL .= ' from (select distinct ld_activity.activityid   '.
                        $this->chartfrom . $this->chartwhere . $this->chartOwner.')as tmp 
                            inner join ld_activity on ld_activity.activityid=tmp.activityid
                             left join ld_account on ld_account.accountid=ld_activity.accountid ';
      
    $strSQL .=  " group by ld_account.accountName ) m  order by m.sumcalendartoptencount desc,m.accountname desc limit 0,10";
    
      return $strSQL;
    
      
   }
   
    /*
       客户日程次数TOP50
    */
   function getCalendarByTopFiftyCount()
   {
      if(strpos(strtolower($this->chartfrom),"ld_users")==null||strpos(strtolower($this->chartfrom),"ld_users")=='')
      {        
        $this->chartfrom .=" inner join ld_users ON ld_crmentity.smownerid = ld_users.id ";
      }
      if(strpos(strtolower($this->chartfrom),"ld_account")==null||strpos(strtolower($this->chartfrom),"ld_account")=='')
      {        
        $this->chartfrom .=" inner join ld_account ON ld_account.accountid = ld_activity.accountid ";
      }
      $strSQL="select count(ld_activity.accountid) as sumCalendarTopTenCount,ld_account.accountname ";
      $strSQL .= ' from  (select distinct ld_activity.activityid  ' .$this->chartfrom . $this->chartwhere . $this->chartOwner." ) as tmp 
                    inner join ld_activity on ld_activity.activityid=tmp.activityid
                   group by ld_account.accountname  limit 0,50 ";
      return $strSQL;
      
   }
   
}
   

?>