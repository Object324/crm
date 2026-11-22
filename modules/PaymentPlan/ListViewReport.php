<?php

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
    是否回款分布统计图
    */
    function getActualamount()
    {
        $strSQL = "select paymentstatus as sumPaymentstatus
                    from ld_paymentplan
                    inner join ld_crmentity
                    	on ld_paymentplan.paymentplanid= ld_crmentity.crmid
                    left join ld_users
                    	on ld_crmentity.smownerid = ld_users.id
                    where ld_crmentity.deleted = 0 and paymentplanid > 0 group by paymentstatus";
                    return $strSQL;
    }
    
    /*
    期次分布统计图
    */
    function getPeriodtimetitle()
    {
        $strSQL = "select Periodtime as sumPaymentPeriodtime
                    from  ld_paymentplan
                    inner join ld_crmentity
                    	on ld_paymentplan.paymentplanid = ld_crmentity.crmid
                    left join ld_users
                    	on ld_crmentity.smownerid = ld_users.id
                    where ld_crmentity.deleted = 0 and paymentplanid > 0 group by Periodtime desc";
                    return $strSQL;
    }
}
?>