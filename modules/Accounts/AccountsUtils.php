<?php

/**
 *整理CasheInfo.php 中  客户公海 相关的方法到这里  zxm 20221125
 */
class AccountsUtils {
    /**
     * 获取设置公海目标达成条件
     *
     * */
    public function  getAccount_Condition_set()
    {
        static $cache_account_condition_set;
        if(!empty($cache_account_condition_set) && isset($cache_account_condition_set))
            return $cache_account_condition_set;
        $cache_account_condition_set = Cache('Account_Condition_set');
        if(!empty($cache_account_condition_set) && isset($cache_account_condition_set))
            return $cache_account_condition_set;
        global $adb;
        $sql="select * from ld_account_set_condition  order by sequence ";
        $result=$adb->pquery($sql,array());
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $day=$adb->query_result($result,$i,'day');
            $isloop=$adb->query_result($result,$i,'isloop');
            $modulename=$adb->query_result($result,$i,'modulename');
            $columnname=$adb->query_result($result,$i,'columnname');
            $arr[]=array('day'=>$day,'isloop'=>$isloop,'modulename'=>$modulename,'columnname'=>$columnname);
        }
        Cache('Account_Condition_set',$arr);
        return $arr;
    }
    //获取公海客户达成目标条件天数的最大值
    public function getMaxDay_account_set_condition()
    {
        $accountsetconditioninfo=getAccount_Condition_set();
        $days=0;
        foreach($accountsetconditioninfo as $index=>$conditioninfo)
        {
            $tmpday=$conditioninfo['day'];
            if(empty($tmpday))
            {
                continue;
            }
            $arrdays[]=$tmpday;

        }
        sort($arrdays);
        $days=$arrdays[sizeof($arrdays)-1];//获取公海客户达成目标条件天数的最大值
        return $days;
    }
    //获取公海客户达成目标条件天数的最小值
    public function getMinDay_account_set_condition()
    {
        $accountsetconditioninfo=getAccount_Condition_set();
        $days=0;
        foreach($accountsetconditioninfo as $index=>$conditioninfo)
        {
            $tmpday=$conditioninfo['day'];
            if(empty($tmpday))
            {
                continue;
            }
            $arrdays[]=$tmpday;

        }
        sort($arrdays);
        $days=$arrdays[0];//获取公海客户达成目标条件天数的最小值
        return $days;
    }
    public function getAccount_set_ProtectedDays($allocatedate,$accountid)
    {
        global $adb;
        $pool_id = 0;	//公海池id

        if(!empty($accountid)){
            $query = "select pool_id from ld_account where deleted = 0 and accountid = ?";
            $result = $adb->pquery($query,array($accountid));
            $pool_id = $adb->query_result($result,0,0);

        }
        $ruleinfo= getAccount_set_rule("complete",$pool_id);
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
    public function getAccount_set_normal_ProtectedDays_new($allocatedate,$accountid)
    {       global $adb;
        $recycleid = 0;	//普通客户回收规则
        $query = "select id,recycleselect from ld_account_normal";
        $result = $adb->pquery($query,array());
        if($adb->num_rows($result)){
            $recycleid = 0;
            for($i = 0; $i< $adb->num_rows($result); $i++){
                $id = $adb->query_result($result,$i,'id');
                $recycleselect = $adb->query_result($result,$i,'recycleselect');
                if(!empty($recycleselect)){
                    $recycle_query = html_entity_decode($recycleselect) ." and ld_account.accountid=?";
                    $recycle_result = $adb->pquery($recycle_query,array($accountid));
                    if($adb->num_rows($recycle_result) >= 1){
                        $recycleid = $id;
                        break;
                    }
                }else{
                    $recycleid = $id;
                    break;
                }

            }
        }
        $ruleinfo= getAccount_set_normal_rule($recycleid);
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
    public function getAccount_set_rule($type,$pool_id)
    {
        global $adb;
        static $ruleinfos;
        if(!empty($ruleinfos[$type]))
        {
            return $ruleinfos[$type];
        }
        //edit:can 2020-12-28 43751: （61mis.com/kfbcrm）客户管理-客户-旧公海；公海参数配置中，只勾选了“ 单次回收规则自分配或领用之日起3天没有创建考勤签到”；领取或分配公海客户后，公海保护日期为空
        //47158: （https://51mis.com/hy/hzqe [^]）客户问题（王杰），新建“公海已分配”客户，保护结束日期没有计算：创建时间字段隐藏
        $sql="select tabname,ld_account_set_rule.columnname,ld_field.tablename ,`condition`,ld_account_set_rule.days
   ,ld_account_set_rule.otherwhere,ld_account_set_rule.iscycle from ld_account_set_rule  
inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2)  or ld_tab.name='singin')
	left JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and (ld_field.presence in(0,2)  or ld_account_set_rule.tabname='Singin' )
where ld_account_set_rule.type='$type' and ld_account_set_rule.pool_id =?
and ld_account_set_rule.`status`='active'
    order by ld_account_set_rule.days asc   
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
    //chj 2022/7/20 普通客户和公海客户回收规则相关功能优化（杨奇寰）
    public function getAccount_set_normal_rule($normalid)
    {
        global $adb;
        static $normal_ruleinfos;
        if(!empty($normal_ruleinfos[$normalid]))
        {
            return $normal_ruleinfos[$normalid];
        }
        $sql="
		select tabname,ld_account_set_rule_normal.columnname,ld_field.tablename ,`condition`,ld_account_set_rule_normal.days
		,ld_account_set_rule_normal.otherwhere,ld_account_set_rule_normal.iscycle from ld_account_set_rule_normal  
		inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2)  or ld_tab.name='singin')
		left JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
		and (ld_field.presence in(0,2)  or ld_account_set_rule_normal.tabname='Singin' )
		where ld_account_set_rule_normal.normal_id =?
		and ld_account_set_rule_normal.`status`='active'
		order by ld_account_set_rule_normal.days asc";
        $result=$adb->pquery($sql,array($normalid));

        $rows=$adb->num_rows($result);

        $normal_ruleinfo=array();
        for($i=0;$i<$rows;$i++)
        {
            $tabname=$adb->query_result($result,$i,'tabname');
            $columnname=$adb->query_result($result,$i,'columnname');
            $otherwhere=$adb->query_result($result,$i,'otherwhere');
            $condition=$adb->query_result($result,$i,'condition');
            $days=$adb->query_result($result,$i,'days');
            $iscycle=$adb->query_result($result,$i,'iscycle');

            $normal_ruleinfo[]=array("tabname"=>$tabname,'columnname'=>$columnname,
                'condition'=>$condition,'otherwhere'=>$otherwhere,
                'days'=>$days,'iscycle'=>$iscycle);



        }
        $normal_ruleinfos[$normalid]=$normal_ruleinfo;

        return $normal_ruleinfo;
    }
    public function getAccount_AllSet($key)
    {
        static $cache_account_setting;
        //公海参数-》公海成员设置“全部”->新增一个普通用户->用这个普通用户登录，该普通用户无法看见公海页面
        if(!empty($cache_account_setting) &&$key!='adminaccount')
            return $cache_account_setting;
        $cache_account_setting = Cache('account_set');

        if(!$cache_account_setting ||$key=='adminaccount'){
            global $adb;

            $sql = 'SELECT IFNULL(status,0) as status,IFNULL(days,0) as days,bills,
					IFNULL(count,0) as count,IFNULL(adminaccount,0) as adminaccount,
					IFNULL(usersaccount,0) as usersaccount,IFNULL(dataprofile,0) as dataprofile,usersaccount_type,
					IFNULL(getprofile,0) as getprofile,IFNULL(wheathershow,0) as wheathershow,
					IFNULL(userid,0) as userid,IFNULL(astricttype,0) as astricttype,IFNULL(allotaccount,0) as allotaccount ,
					case IFNULL(buttontype,"") when "" then "1" when 0 then "1,2,3" else buttontype end buttontype,ifnull(publicaccount,0) as publicaccount,
					ifnull(publicaccount,0) as publicaccount,normalconvertbuttonprofile,objtainaccountcontroldays
					FROM ld_account_set limit 1;';

            //yyx 2015-4-21 在getAccount_Set方法中添加buttontype字段，用于查找出公海参数值
            $result = $adb->pquery($sql,array());
            $rows = $adb->num_rows($result);
            $cache_account_setting=array();
            if($rows > 0){
                $cache_account_setting['status'] = $adb->query_result($result,0,'status');
                $cache_account_setting['days'] = $adb->query_result($result,0,'days');
                $cache_account_setting['bills'] = $adb->query_result($result,0,'bills');
                $cache_account_setting['count'] = $adb->query_result($result,0,'count');
                $cache_account_setting['adminaccount'] = $adb->query_result($result,0,'adminaccount');
                $cache_account_setting['dataprofile'] = $adb->query_result($result,0,'dataprofile');
                $cache_account_setting['getprofile'] = $adb->query_result($result,0,'getprofile');
                // by andy 公海客户改进
                $cache_account_setting['wheathershow'] = $adb->query_result($result,0,'wheathershow');
                $cache_account_setting['userid'] = $adb->query_result($result,0,'userid');
                $cache_account_setting['astricttype'] = $adb->query_result($result,0,'astricttype');//公海客户限制类型、1.用户，2角色
                $cache_account_setting['allotaccount'] = $adb->query_result($result,0,'allotaccount');
                $cache_account_setting['buttontype'] = $adb->query_result($result,0,'buttontype');//yyx 2015-4-21 把sql语句搜索出的公海参数值赋给buttontype
                $cache_account_setting['publicaccount'] = $adb->query_result($result,0,'publicaccount');//快速创建客户默认的客户公海状态
                $cache_account_setting['normalconvertbuttonprofile']=$adb->query_result($result,0,'normalconvertbuttonprofile');
                $cache_account_setting['objtainaccountcontroldays']=$adb->query_result($result,0,'objtainaccountcontroldays');
                $usersaccount_type = $adb->query_result($result,0,'usersaccount_type');
                if($usersaccount_type == 'user'){
                    $cache_account_setting['usersaccount'] = $adb->query_result($result,0,'usersaccount');
                }else if($usersaccount_type == 'group'){
                    $usersaccount = $adb->query_result($result,0,'usersaccount');
                    require_once(globalStatic::$root_directory.'modules/Users/Group.class.php');
                    $group = new Group();
                    $groupids = explode(',',$usersaccount);
                    for($i = 0; $i<sizeOf($groupids); $i++){
                        $userid_array[$i] = $group->getGroupOfusers($groupids[$i]);
                    }
                    foreach($userid_array as $user_info){
                        foreach($user_info as $userid => $last_name){
                            $userid_arr[$userid] = $userid;
                        }
                    }
                    $cache_account_setting['usersaccount'] = implode(',',$userid_arr);
                }else{
                    $userscope = get_user_array(false, "", '');
                    $userscopeid = array_keys($userscope);
                    $cache_account_setting['usersaccount'] = implode(',',$userscopeid);
                }
            }

            Cache('account_set',$cache_account_setting);

        }
        return $cache_account_setting;
    }
    /**
     * edit:andrew
     * reason:获取公海客户用户限制数量
     * */
    public function getAccount_Set_ByUser()
    {
        static $cache_account_setting;
        if (!empty($cache_account_setting) && isset($cache_account_setting['count']))
            return $cache_account_setting['count'];
        $cache_account_setting = Cache('account_set');
        if (!$cache_account_setting || !isset($cache_account_setting['count'])) {
            global $adb;
            $sql = 'SELECT IFNULL(count,0) as count FROM ld_account_set limit 1;';
            $result = $adb->pquery($sql, array());
            $rows = $adb->num_rows($result);
            if ($rows > 0) {
                $cache_account_setting['count'] = $adb->query_result($result, 0, 'count');
            }
            Cache('account_set', $cache_account_setting);
        }
        if (!empty($cache_account_setting) && isset($cache_account_setting['count']))
            return $cache_account_setting['count'];
        return '';
    }

    //duan 20240816 获取回收方案以及回收规则信息
    public function get_program_set_rule($module,$type,$pool_id){
        global $adb;
        if($type == 'complete'){
            if($module == 'Accounts'){
                $rule_table = 'ld_account_set_rule';
            }else{
                $rule_table = 'ld_leads_set_rule';
            }
            $programme_table = 'ld_module_recovery_programme';

            $sql = "SELECT a.programmeid,a.recycleselect,b.tabname,b.`condition`,b.days,b.columnname,b.otherwhere,b.iscycle 
                from $programme_table a
                INNER JOIN $rule_table b on b.programmeid = a.programmeid
                where a.modulename = ? and a.from_pool_id = ? and a.active = 'yes' and b.`status` = 'active' and b.type = 'complete' ";
            $result= $adb->pquery($sql,[$module,$pool_id]);
        }else{
            if($module == 'Accounts'){
                $sql = "SELECT a.id as programmeid,a.recycleselect,b.tabname,b.`condition`,b.days,b.columnname,b.otherwhere,b.iscycle  
                    from ld_account_normal a INNER JOIN ld_account_set_rule_normal b
                    on a.id = b.normal_id 
                    where a.active = 'yes' and b.`status` = 'active'
                    ORDER BY a.sequence,b.sequence";
                $result= $adb->pquery($sql,[]);
            }else{
                $sql = "SELECT a.id as programmeid,a.recycleselect,b.tabname,b.`condition`,b.days,b.columnname,b.otherwhere,b.iscycle  
                    from ld_leads_normal a INNER JOIN ld_leads_set_rule b
                    on a.id = b.programmeid 
                    where a.active = 'yes' and b.`status` = 'active' and b.type = 'normal'
                    ORDER BY a.sequence,b.sequence";
                $result= $adb->pquery($sql,[]);
            }
        }

        $num_rows = $adb->num_rows($result);
        $pre_id = 0;
        $all_ruleinfo = [];
        for ($i =0 ;$i < $num_rows;$i++){
            $programmeid = $adb->query_result($result,$i,'programmeid');
            if($pre_id != $programmeid){
                $recycleselect = $adb->query_result($result,$i,'recycleselect');
                $all_ruleinfo[$programmeid]['recycleselect'] = $recycleselect;
            }
            $tmp_rule = [];
            $tabname = $adb->query_result($result,$i,'tabname');
            if($tabname == '' || $tabname == 'null' || $tabname == 'undefined'){
                continue;
            }

            $tmp_rule['tabname'] = $tabname;
            $tmp_rule['condition'] = $adb->query_result($result,$i,'condition');
            $tmp_rule['days'] = $adb->query_result($result,$i,'days');
            $tmp_rule['columnname'] = $adb->query_result($result,$i,'columnname');
            $tmp_rule['otherwhere'] = $adb->query_result($result,$i,'otherwhere');
            $tmp_rule['iscycle'] = $adb->query_result($result,$i,'iscycle');
            $all_ruleinfo[$programmeid]['rule_arr'][] = $tmp_rule;
        }
        return $all_ruleinfo;
    }

}