<?php

/**
 *整理CasheInfo.php 中  销售线索公海 相关的方法到这里  zxm 20221125
 */
class LeadsUtils {
    public function getLeads_set_ProtectedDays($allocatedate,$accountid)
    {       global $adb;
        $pool_id = 0;	//公海池id

        if(!empty($accountid)){
            $query = "select pool_id from ld_leads where deleted = 0 and leadsid = ?";
            $result = $adb->pquery($query,array($accountid));
            $pool_id = $adb->query_result($result,0,0);

        }
        $ruleinfo= getLeads_set_rule("complete",$pool_id);
        $maxdays=0;
        $mindays=9900000000;
        $rows=sizeof($ruleinfo);

        if($ruleinfo[0]['condition']=='or')
        {
            for($i=0;$i<$rows;$i++)
            {
                //保护结束日期获取最大的天数
                $days=$ruleinfo[$i]['days'];

                if($days>$maxdays)
                {
                    $maxdays=$days;
                }
            }
            return $maxdays;
        }
        else
        {
            for($i=0;$i<$rows;$i++)
            {
                //保护结束日期获取最小的天数
                $days=$ruleinfo[$i]['days'];
                $tabname=$ruleinfo[$i]['tabname'];
                $otherwhere=$ruleinfo[$i]['otherwhere'];
                $columnname=$ruleinfo[$i]['columnname'];
                if(empty($allocatedate))
                {
                    return $ruleinfo[0]['days'];//如果没有满足条件的数据则获取第一个最小的天数，例如公海未分配转变公海已分配时
                }
                else
                {

                    $tmpfocus=CRMEntity::getInstance($tabname);
                    $sql='select leadsid from '.$tmpfocus->table_name.' where deleted=0 and  leadsid=? ';
                    if(!empty($otherwhere))
                    {
                        $sql.=$otherwhere;
                    }
                    $sql.=" and date_format( ".$tmpfocus->table_name.".".$columnname.",'%Y-%m-%d') between '$allocatedate' and date_add('$allocatedate',interval $days day) ";
                    $sql=htmlspecialchars_decode($sql);

                    $result=$adb->pquery($sql,array($accountid));
                    if($adb->num_rows($result)<=0)
                    {

                        return $days;
                    }
                }
            }
            return $ruleinfo[0]['days'];//如果没有满足条件的数据则获取第一个最小的天数，例如公海未分配转变公海已分配时

        }
    }
    public function getLeads_set_normal_ProtectedDays($allocatedate,$leads)
    {       global $adb;
        $ruleinfo= getLeads_set_rule("normal",1);
        $maxdays=0;
        $mindays=9900000000;
        $rows=sizeof($ruleinfo);

        if($ruleinfo[0]['condition']=='or')
        {
            for($i=0;$i<$rows;$i++)
            {
                //保护结束日期获取最大的天数
                $days=$ruleinfo[$i]['days'];

                if($days>$maxdays)
                {
                    $maxdays=$days;
                }
            }
            return $maxdays;
        }
        else
        {
            for($i=0;$i<$rows;$i++)
            {
                //保护结束日期获取最小的天数
                $days=$ruleinfo[$i]['days'];
                $tabname=$ruleinfo[$i]['tabname'];
                $otherwhere=$ruleinfo[$i]['otherwhere'];
                $columnname=$ruleinfo[$i]['columnname'];
                if(empty($allocatedate))
                {
                    return $ruleinfo[0]['days'];//如果没有满足条件的数据则获取第一个最小的天数，例如公海未分配转变公海已分配时
                }
                else
                {

                    $tmpfocus=CRMEntity::getInstance($tabname);
                    $sql='select accountid from '.$tmpfocus->table_name.' where deleted=0 and  accountid=? ';
                    if(!empty($otherwhere))
                    {
                        $sql.=$otherwhere;
                    }
                    $sql.=" and date_format( ".$tmpfocus->table_name.".".$columnname.",'%Y-%m-%d') between '$allocatedate' and date_add('$allocatedate',interval $days day) ";
                    $sql=htmlspecialchars_decode($sql);

                    $result=$adb->pquery($sql,array($accountid));
                    if($adb->num_rows($result)<=0)
                    {

                        return $days;
                    }
                }
            }
            return $ruleinfo[0]['days'];//如果没有满足条件的数据则获取第一个最小的天数，例如公海未分配转变公海已分配时

        }
    }
    public function getLeads_set_rule($type,$pool_id)
    {
        global $adb;
        static $ruleinfos;
        if(!empty($ruleinfos[$type]))
        {
            return $ruleinfos[$type];
        }
        //edit:can 2020-12-28 43751: （61mis.com/kfbcrm）客户管理-客户-旧公海；公海参数配置中，只勾选了“ 单次回收规则自分配或领用之日起3天没有创建考勤签到”；领取或分配公海客户后，公海保护日期为空
        $sql="select tabname,ld_leads_set_rule.columnname,ld_field.tablename ,`condition`,ld_leads_set_rule.days
   ,ld_leads_set_rule.otherwhere,ld_leads_set_rule.iscycle from ld_leads_set_rule  
inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2)  or ld_tab.name='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
	and (ld_field.presence in(0,2)  or ld_leads_set_rule.tabname='Singin' )
where ld_leads_set_rule.type='$type' and ld_leads_set_rule.pool_id =?
and ld_leads_set_rule.`status`='active'
    order by ld_leads_set_rule.days asc   
 ";
        $result=$adb->pquery($sql,array($pool_id));

        $rows=$adb->num_rows($result);

        $ruleinfo=array();
        for($i=0;$i<$rows;$i++)
        {
            $tabname=$adb->query_result($result,$i,'tabname');
            $columnname=$adb->query_result($result,$i,'columnname');
            $otherwhere=$adb->query_result($result,$i,'otherwhere');
            $condition=$adb->query_result($result,$i,'condition');
            $days=$adb->query_result($result,$i,'days');
            $iscycle=$adb->query_result($result,$i,'iscycle');

            $ruleinfo[]=array("tabname"=>$tabname,'columnname'=>$columnname,
                'condition'=>$condition,'otherwhere'=>$otherwhere,
                'days'=>$days,'iscycle'=>$iscycle);



        }
        $ruleinfos[$type]=$ruleinfo;

        return $ruleinfo;
    }
}