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
    负责人/月度跟踪客户数量
    */
    function getassignUserMonthAccount()
    {
        /*
        add:kara $sql_new_add1
        date:2013-06-18
        reason:bug:3891
        */
        if(!strpos($this->chartfrom, 'users_assigned_user_id')){
            $this->chartfrom.=' LEFT JOIN ld_users AS users_assigned_user_id ON users_assigned_user_id.id =  ld_contactrecords.smownerid';
        }
        $sql_new_add1=" AND ld_account.accountname is not null  ";
        $strSQL= " select n.last_name,n.querymonth,n.wx_userid,n.userid,count(1) as sumrecordcount from ( select m.querymonth,m.last_name,m.wx_userid,m.userid,m.accountname from ( 
                select users_assigned_user_id.last_name,users_assigned_user_id.wx_userid,users_assigned_user_id.id as userid,DATE_FORMAT(contactdate,'%Y-%m') as querymonth,ld_account.accountname";
        $strSQL .= $this->chartfrom . $this->chartwhere .$this->chartOwner.$sql_new_add1." 
                    order by DATE_FORMAT(contactdate,'%Y-%m')) m  group by  m.querymonth,m.last_name,m.accountname)n  group by n.querymonth,n.last_name ";
        //zxm BUG0070144  kfbcrm-跟进记录-负责人/月度跟踪客户数量组件，应不显示数量为0的人
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
        $sql_new_add1=" AND ld_account.accountname is not null  ";
        $strSQL="select m.accountname,m.sumCountContact  from ( select ld_account.accountname ,count(1) as sumCountContact ";
        $strSQL .= $this->chartfrom . $this->chartwhere . $this->chartOwner .$sql_new_add1. " group by ld_account.accountName ) m  order by m.sumCountContact desc,m.accountname desc  limit 0,10";
     
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
      $sql_new_add1=" AND ld_account.accountname is not null  ";
      $strSQL="select m.sumCountContact,m.accountname from (select ld_account.accountname ,count(1) as sumCountContact ";
      $strSQL .= $this->chartfrom . $this->chartwhere .$this->chartOwner . $sql_new_add1 . " group by ld_account.accountName) m  order by m.sumCountContact desc ,m.accountname desc  limit 0,50";
      return $strSQL;
   }
}
   

?>