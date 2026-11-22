<?php

//工程行业demo报表 zxm 2020-0126
include globalStatic::$root_directory."modules/Home/CustomMade/CustomMadeUtils.php";

class ConstructionUtils extends CustomMadeUtils
{
    public function getStuffData($dfid,$search_date,$scopeType,$senioruserid,$approve_value){
        //工程行业的数据
        $AllAssmablys['52'] = 'MarketingReport';
        $AllAssmablys['53'] = 'MarketingCompareReport';
        $AllAssmablys['54'] = 'ProjectReport';
        $AllAssmablys['55'] = 'ProjectCompareReport';
        $AllAssmablys['56'] = 'RankingListReport';
        $AllAssmablys['61'] = 'ProjectExecutionAnalysisChart';//项目执行分析图
        $AllAssmablys['62'] = 'AnalysisOnExecutionOfReceivableContract';//应收合同执行分析
        $AllAssmablys['63'] = 'ProjectManagementMap';//项目经营数据统览图
        $AllAssmablys['64'] = 'ProjectsUnderConstructionComprehensive';//
        $AllAssmablys['65'] = 'IncomeAndExpenditureReport';//
        $functionName = 'get'.$AllAssmablys[$dfid].'Data';
        $home_values = $this->$functionName($search_date,$scopeType,$senioruserid,$approve_value);
        return $home_values;
    }
    //项目报告
    public function getProjectReportData($search_date,$scopeType,$senioruserid,$approve_status)
    {
        global $adb;
        $query = "";
        //审批状态
        if(!empty($approve_status)){
            $approveName = self::getApproveStatusName($approve_status);
            if(!empty($approveName)){
                $query .= ' and a.approvestatus ="'.$approveName.'" ';
            }
        }
        //查看范围sql
        $scopeobj = new ScopOfAuthority($adb,'MobileReport');
        if(!empty($scopeType)){
            $scopesql = $scopeobj->getHomeSmOwnerSearchSql($scopeType,$senioruserid);
            if(!empty($scopesql)){
                $query .= ' and a.' . $scopesql;
            }
        }else{
            if(!empty($senioruserid)){
                $query .= ' and a.smownerid in ('.$senioruserid.')';
            }
        }
        $date_sql = getHomeDateScope($search_date);
        //数据
        $label_arr = [
            'customform16'=>[
                "label"=>"chanzhi",
                "name"=>"项目产值",//按“申报时间”查询显示
                "back_img"=>"crm_Project.png",
                "module"=>"CustomForm16",
                "sql"=>"select sum(a.total) as nums from ld_customform16 a left join ld_customform16scf b on a.customform16id=b.customform16id where a.deleted=0 $query and b.cf_4337 $date_sql",
                "nums"=>0,
                "prefix"=>'￥'
            ],
            'salesorder'=>[
                "label"=>"yingshou",
                "name"=>"项目应收",
                "back_img"=>"crm_Project.png",
                "module"=>"SalesOrder",
                "sql"=>"select sum(a.total) as nums from ld_salesorder a where a.deleted=0 $query and a.createdtime $date_sql",
                "nums"=>0,
                "prefix"=>'￥'
            ],
            'cost'=>[
                "label"=>"chengben",
                "name"=>"项目成本",//项目费用报销单”按照“报销日期”查询显示 PurchaseInvoice
                "back_img"=>"crm_Project.png",
                "module"=>"",
                "sql"=>"select (nums1 + nums2) as nums 
from 
(select sum(ifnull(a.total,0)) as nums1,'key' as k from ld_purchaseinvoice a where a.deleted=0 $query and a.createdtime $date_sql) a 
 left join 
 (select sum(ifnull(a.total,0)) as nums2,'key' as k from ld_expense a where a.deleted=0 $query and a.expensedate $date_sql) b  on a.k=b.k  ",
                "nums"=>0,
                "prefix"=>'￥'
            ],
            'maoli'=>[
                "label"=>"maoli",
                "name"=>"毛利额",
                "back_img"=>"crm_Project.png",
                "module"=>"",
                "sql"=>"select (nums - nums1- nums2) as nums 
from 
(select sum(ifnull(a.total,0)) as nums,'key' as k from ld_salesorder a where a.deleted=0 $query and a.createdtime $date_sql) as t 
left join 
(select sum(ifnull(a.total,0)) as nums1,'key' as k from ld_purchaseinvoice a where a.deleted=0 $query and a.createdtime $date_sql) a on t.k=a.k
 left join 
 (select sum(ifnull(a.total,0)) as nums2,'key' as k from ld_expense a where a.deleted=0 $query and a.expensedate $date_sql) b  on t.k=b.k  ",
                "nums"=>0,
                "prefix"=>'￥'
            ]
        ];
        //计算
        foreach($label_arr as $k=>&$v){
            $res = $adb->pquery($v['sql']);
            $v['nums'] = $adb->query_result($res,0,'nums');
            $v['nums'] = number_format($v['nums'],2);
            unset($v['sql']);
        }
        return $label_arr;
    }
    //营销报告
    public function getMarketingReportData($search_date,$scopeType,$senioruserid,$approve_status)
    {
        global $adb;
        $query = "";
        //审批状态
        if(!empty($approve_status)){
            $approveName = self::getApproveStatusName($approve_status);
            if(!empty($approveName)){
                $query .= ' and a.approvestatus ="'.$approveName.'" ';
            }
        }
        //查看范围sql
        $scopeobj = new ScopOfAuthority($adb,'MobileReport');
        if(!empty($scopeType)){
            $scopesql = $scopeobj->getHomeSmOwnerSearchSql($scopeType,$senioruserid);
            if(!empty($scopesql)){
                $query .= ' and a.' . $scopesql;
            }
        }else{
            if(!empty($senioruserid)){
                $query .= ' and a.smownerid in ('.$senioruserid.')';
            }
        }
        $date_sql = getHomeDateScope($search_date);
        $label_arr = [
            'project'=>[
                "label"=>"new_project",
                "name"=>"新增项目",
                "back_img"=>"crm_Project.png",
                "module"=>"Project",
                "sql"=>"select count(1) as nums from ld_project a where a.deleted=0 $query and a.createdtime $date_sql",
                "nums"=>0,
                "prefix"=>''
            ],
            'account'=>[
                "label"=>"new_account",
                "name"=>"新增客户",
                "back_img"=>"crm_Accounts.png",
                "module"=>"Accounts",
                "sql"=>"select count(1) as nums from ld_account a where a.deleted=0 $query and a.createdtime $date_sql",
                "nums"=>0,
                "prefix"=>''
            ],
            'salesorder'=>[
                "label"=>"new_salesorder",
                "name"=>"合同金额",
                "back_img"=>"crm_SalesOrder.png",
                "module"=>"SalesOrder",
                "sql"=>"select count(total) as nums from ld_salesorder a where a.deleted=0 $query and a.createdtime $date_sql",
                "nums"=>0,
                "prefix"=>''
            ],
            'invoice'=>[
                "label"=>"new_invoice",
                "name"=>"已开票",
                "back_img"=>"crm_Invoice.png",
                "module"=>"Invoice",
                "sql"=>"select sum(a.total) as nums from ld_invoice a where a.deleted=0 $query and a.createdtime $date_sql",
                "nums"=>0,
                "prefix"=>'￥'
            ],
            'cashbill'=>[
                "label"=>"new_cashbill",
                "name"=>"已收款",
                "back_img"=>"crm_CashBill.png",
                "module"=>"CashBill",
                "sql"=>"select sum(a.total) as nums from ld_cashbill a where a.deleted=0 $query and a.createdtime $date_sql",
                "nums"=>0,
                "prefix"=>'￥'
            ]
        ];
        //计算
        foreach($label_arr as $k=>&$v){
            $res = $adb->pquery($v['sql']);
            $v['nums'] = $adb->query_result($res,0,'nums');
            $v['nums'] = empty($v['nums'])?0:$v['nums'];
            if($k=='invoice'||$k=='cashbill'){
                $v['nums'] = number_format($v['nums'],2);
            }
            unset($v['sql']);
        }
        return $label_arr;
    }
    //项目对比报告
    public function getProjectCompareReportData($search_date,$scopeType,$senioruserid,$approve_status)
    {
        global $adb;
        global $current_language;
        $where = " ";
        //审批状态
        if(!empty($approve_status)){
            $approveName = self::getApproveStatusName($approve_status);
            if(!empty($approveName)){
                $where .= ' and approvestatus ="'.$approveName.'" ';
            }
        }
        //查看范围sql
        $scopeobj = new ScopOfAuthority($adb,'MobileReport');
        if(!empty($scopeType)){
            $scopesql = $scopeobj->getHomeSmOwnerSearchSql($scopeType,$senioruserid);
            if(!empty($scopesql)){
                $where .= ' and ' . $scopesql;
            }
        }else{
            if(!empty($senioruserid)){
                $where .= ' and a.smownerid in ('.$senioruserid.')';
            }
        }
        // 时间范围
        $now_date = date('Y-m',strtotime('+1 month')).'-01 00:00:00';
        $last_date = date('Y-m',strtotime('-5 month')).'-01 00:00:00';
        $date_sql = " between '$last_date' and '$now_date' ";
        //时间数组
        $dateMonthsArr = $this->dateMonths(date('Y-m',strtotime('-5 month')),date('Y-m',time()));

        foreach($dateMonthsArr as $v){
            $temp_v = explode('-',$v);
            $temp_month_name = $temp_v[1];
            if($current_language == 'en'){
                $month_name= DateOperation::getCaldate($temp_month_name);
            }else{
                $month_name= $temp_month_name.'月';
            }
            $res['month'][] = $month_name;
        }
        //时间临时表
        $dateMonthsStr = '("'.implode('"),("',$dateMonthsArr).'")';
        $temp_sql = "create temporary table tmp_query (datestr varchar(20) NOT NULL PRIMARY KEY,id int(11) default NULL);";
        $temp_insert_sql="insert into tmp_query(datestr) values $dateMonthsStr;";
        $adb->pquery($temp_sql);
        $adb->pquery($temp_insert_sql);
        $chanzhi_sql = " SELECT
	(
		nums1 + nums2 + nums3 + nums4 + nums5
	) AS nums,
	a.`month`,
	ifnull(b.chanzhi,0) as chanzhi
FROM
	(
		SELECT
			ifnull(nums1, 0) AS nums1,
			ifnull(nums2, 0) AS nums2,
			ifnull(nums3, 0) AS nums3,
			ifnull(nums4, 0) AS nums4,
			ifnull(nums5, 0) AS nums5,
			t.`month`
		FROM
			(
				SELECT
					datestr AS `month`
				FROM
					tmp_query
			) AS t
		LEFT JOIN (
			SELECT
				ifnull(sum(a.total), 0) AS nums1,
				date_format(a.createdtime, '%Y-%m') AS `month`
			FROM
				ld_purchaseorder a
			WHERE
				a.deleted = 0
			AND a.purchaseorderid > 0 $where
			AND a.createdtime $date_sql
			GROUP BY
				`month`
		) a ON t.`month` = a.`month`
		LEFT JOIN (
			SELECT
				ifnull(sum(c.sf143), 0) AS nums2,
				date_format(a.createdtime, '%Y-%m') AS `month`
			FROM
				ld_customform25 a
			LEFT JOIN ld_customform25detail b ON a.customform25id = b.entitytypeid
			LEFT JOIN ld_customform25detailscf c ON b.lineitem_id = c.lineitem_id
			WHERE
				a.deleted = 0
			AND a.customform25id > 0 $where
			AND a.createdtime $date_sql
			GROUP BY
				`month`
		) b ON t.`month` = b.`month`
		LEFT JOIN (
			SELECT
				ifnull(sum(a.total), 0) AS nums3,
				date_format(a.createdtime, '%Y-%m') AS `month`
			FROM
				ld_customform29 a
			WHERE
				a.deleted = 0
			AND a.customform29id > 0 $where
			AND a.createdtime $date_sql
			GROUP BY
				`month`
		) c ON t.`month` = c.`month`
		LEFT JOIN (
			SELECT
				ifnull(sum(a.total), 0) AS nums4,
				date_format(a.createdtime, '%Y-%m') AS `month`
			FROM
				ld_customform15 a
			WHERE
				a.deleted = 0
			AND a.customform15id > 0 $where
			AND a.createdtime $date_sql
			GROUP BY
				`month`
		) d ON t.`month` = d.`month`
		LEFT JOIN (
			SELECT
				ifnull(sum(a.total), 0) AS nums5,
				date_format(a.createdtime, '%Y-%m') AS `month`
			FROM
				ld_expense a
			WHERE
				a.deleted = 0
			AND a.expenseid > 0 $where
			AND a.expensedate $date_sql
			GROUP BY
				`month`
		) e ON t.`month` = e.`month`
		GROUP BY
			t.`month`
	) a 
	LEFT JOIN (
        SELECT
            ifnull(sum(a.total),0) AS chanzhi,
            date_format(a.due_date, '%Y-%m') AS `month`
        FROM
            ld_servicecontracts a
        WHERE
            a.deleted = 0 $where
        AND a.due_date $date_sql
        GROUP BY
            `month`
	) b 
	ON a.`month`=b.`month`
ORDER BY
	`month` ASC;";
        $chanzhi_res = $adb->pquery($chanzhi_sql);
        $num_row = $adb->num_rows($chanzhi_res);
        for($i=0;$i<$num_row;$i++){
            $chanzhi[$i] = $adb->query_result($chanzhi_res,$i,'chanzhi');
            $chanzhi[$i] = round($chanzhi[$i],4);
            $chengben[$i] = $adb->query_result($chanzhi_res,$i,'nums');
            $chengben[$i] = round($chengben[$i],4);
            $maoli[$i] = $chanzhi[$i]-$chengben[$i];
            $maolirate[$i] = $chanzhi[$i]==0?0:$maoli[$i]*100/$chanzhi[$i];
        }
        $res['chanzhi'] = $chanzhi;
        $res['chengben'] = $chengben;
        $res['maoli'] = $maoli;
        $res['maoli_rate'] = $maolirate;
        return ['ModuleName'=>'companySixMonthSalesRate','Entries'=>$res];
    }
    //营销对比报告
    public function getMarketingCompareReportData($search_date,$scopeType,$senioruserid,$approve_status)
    {
        global $adb;
        global $current_language;
        $where = " deleted=0";
        //审批状态
        if(!empty($approve_status)){
            $approveName = self::getApproveStatusName($approve_status);
            if(!empty($approveName)){
                $where .= ' and approvestatus ="'.$approveName.'" ';
            }
        }
        //查看范围sql
        $scopeobj = new ScopOfAuthority($adb,'MobileReport');
        if(!empty($scopeType)){
            $scopesql = $scopeobj->getHomeSmOwnerSearchSql($scopeType,$senioruserid);
            if(!empty($scopesql)){
                $where .= ' and ' . $scopesql;
            }
        }else{
            if(!empty($senioruserid)){
                $where .= ' and smownerid in ('.$senioruserid.')';
            }
        }
        // 时间范围
        $now_date = date('Y-m',strtotime('+1 month')).'-01 00:00:00';
        $last_date = date('Y-m',strtotime('-5 month')).'-01 00:00:00';
        $where .= " and createdtime between '$last_date' and '$now_date' ";
        //时间数组
        $dateMonthsArr = $this->dateMonths(date('Y-m',strtotime('-5 month')),date('Y-m',time()));
        foreach($dateMonthsArr as $v){
            $res['hetong'][$v] = 0;
            $res['kaipiao'][$v] = 0;
            $res['huikuan'][$v] = 0;
            $temp_v = explode('-',$v);
            $temp_month_name = $temp_v[1];
            if($current_language == 'en'){
                $month_name= DateOperation::getCaldate($temp_month_name);
            }else{
                $month_name= $temp_month_name.'月';
            }
            $res['month'][] = $month_name;
        }
        //sql
        // 合同金额
        $hetong_sql = " select sum(total) as hetong,date_format(createdtime,'%Y-%m') as `month` from ld_salesorder where $where group by `month` order by `month` asc";
        $hetong_res = $adb->pquery($hetong_sql);
        $hetong_num = $adb->num_rows($hetong_res);
        if($hetong_num>0){
            for($i=0;$i<$hetong_num;$i++){
                $tem_month = $adb->query_result($hetong_res,$i,'month');
                $res['hetong'][$tem_month] = round($adb->query_result($hetong_res,$i,'hetong'),2);
            }
        }
        // 开票金额
        $kaipiao_sql = " select sum(total) as kaipiao,date_format(createdtime,'%Y-%m') as `month` from ld_invoice where $where group by `month` order by `month` asc";
        $kaipiao_res = $adb->pquery($kaipiao_sql);
        $kaipiao_num = $adb->num_rows($kaipiao_res);
        if($kaipiao_num>0){
            for($i=0;$i<$kaipiao_num;$i++){
                $tem_month = $adb->query_result($kaipiao_res,$i,'month');
                $res['kaipiao'][$tem_month] = round($adb->query_result($kaipiao_res,$i,'kaipiao'),2);
            }
        }

        // 回款金额
        $huikuan_sql = " select sum(total) as huikuan,date_format(createdtime,'%Y-%m') as `month` from ld_cashbill where $where group by `month` order by `month` asc";
        $huikuan_res = $adb->pquery($huikuan_sql);
        $huikuan_num = $adb->num_rows($huikuan_res);
        if($huikuan_num>0){
            for($i=0;$i<$huikuan_num;$i++){
                $tem_month = $adb->query_result($huikuan_res,$i,'month');
                $res['huikuan'][$tem_month] = round($adb->query_result($huikuan_res,$i,'huikuan'),2);
            }
        }
        $res['hetong'] = array_values($res['hetong']);
        $res['kaipiao'] = array_values($res['kaipiao']);
        $res['huikuan'] = array_values($res['huikuan']);
        return ['ModuleName'=>'companySixMonthSalesRate','Entries'=>$res];
    }
    public function getRankingListReportData($search_date,$scopeType,$senioruserid,$approve_status,$type='hetongList')
    {
        $listType = $_REQUEST['data_type'];
        $listType = empty($listType)?$type:$listType;
        global $adb;
        $where = "where a.deleted=0 ";
        //审批状态
        //审批状态
        if(!empty($approve_status)){
            $approveName = self::getApproveStatusName($approve_status);
            if(!empty($approveName)){
                $where .= ' and approvestatus ="'.$approveName.'" ';
            }
        }
        $date_sql = getHomeDateScope($search_date);
        $result = [];
        switch($listType){
            case "hetongList":
                //customform12
                $result['thead'] = ['排名','分公司名称','合同签约额（￥）'];
                $sql = "select sum(a.total) as money,b.cf_3654 as branch_office ,b.customform60id from ld_salesorder a left join ld_customform60scf b on a.customform60_id=b.customform60id $where and a.createdtime $date_sql group by b.customform60id order by money desc";
                break;
            case "chanzhiList":
                //ServiceContracts
                $result['thead'] = ['排名','分公司名称','产值额（￥）'];
                $sql = "select sum(a.total) as money,b.cf_3654 as branch_office,b.customform60id from ld_customform60scf b left join ld_servicecontracts a  on a.customform60_id=b.customform60id $where AND a.projectid > 0 and a.due_date $date_sql group by b.customform60id order by money desc";
                break;
            case "maoliList":
                //项目产值减去项目成本
                $result['thead'] = ['排名','分公司名称','毛利额（￥）'];
                $sql = "SELECT
	sum(
		maoli
	) AS money,
	branch_office
FROM
	(
		SELECT
			(ifnull(chanzhi, 0)-ifnull(nums1, 0)-ifnull(nums2, 0)-ifnull(nums3, 0)-ifnull(nums4, 0)-ifnull(nums5, 0)) AS maoli,ifnull(chanzhi, 0) as chanzhi,
			project.customform60id,
			branch_office
		FROM
			(
				SELECT
					a.customform60id,
					a.cf_3654 AS branch_office,
					b.projectid
				FROM
					ld_project b
				LEFT JOIN ld_customform60scf a ON a.customform60id = b.customform60_id
			) project
		LEFT JOIN (
			SELECT
				sum(a.total) AS chanzhi,
				a.customform60_id,
				a.projectid
			FROM
				ld_servicecontracts a
			LEFT JOIN ld_customform60scf b ON a.customform60_id = b.customform60id $where
			AND a.projectid > 0
			AND a.due_date $date_sql
			GROUP BY
				a.projectid
		) chanzhi ON project.projectid = chanzhi.projectid
		LEFT JOIN (
			SELECT
				ifnull(sum(a.total), 0) AS nums1,
				projectid
			FROM
				ld_purchaseorder a $where
			AND a.purchaseorderid > 0
			AND a.createdtime $date_sql
			GROUP BY
				projectid
		) a ON project.projectid = a.projectid
		LEFT JOIN (
			SELECT
				ifnull(sum(c.sf143), 0) AS nums2,
				projectid
			FROM
				ld_customform25 a
			LEFT JOIN ld_customform25detail b ON a.customform25id = b.entitytypeid
			LEFT JOIN ld_customform25detailscf c ON b.lineitem_id = c.lineitem_id $where
			AND a.customform25id > 0
			AND a.createdtime $date_sql
			GROUP BY
				projectid
		) b ON project.projectid = b.projectid
		LEFT JOIN (
			SELECT
				ifnull(sum(a.total), 0) AS nums3,
				projectid
			FROM
				ld_customform29 a $where
			AND a.customform29id > 0
			AND a.createdtime $date_sql
		) c ON project.projectid = c.projectid
		LEFT JOIN (
			SELECT
				ifnull(sum(a.total), 0) AS nums4,
				projectid
			FROM
				ld_customform15 a $where
			AND a.customform15id > 0
			AND a.createdtime $date_sql
			GROUP BY
				projectid
		) d ON project.projectid = d.projectid
		LEFT JOIN (
			SELECT
				ifnull(sum(a.total), 0) AS nums5,
				projectid
			FROM
				ld_expense a $where
			AND a.expenseid > 0
			AND a.expensedate $date_sql
			GROUP BY
				projectid
		) e ON project.projectid = e.projectid
	) a
GROUP BY
	customform60id
ORDER BY
	money DESC;";
                break;
            case "maoliRateList":
                $result['thead'] = ['排名','分公司名称','毛利率（%）'];
                $sql = "SELECT
	CASE WHEN chanzhi = 0 THEN 0 
    ELSE  sum(
		maoli
	)*100 / sum(chanzhi) END AS money,
	branch_office
FROM
	(
		SELECT
			(ifnull(chanzhi, 0)-ifnull(nums1, 0)-ifnull(nums2, 0)-ifnull(nums3, 0)-ifnull(nums4, 0)-ifnull(nums5, 0)) AS maoli,ifnull(chanzhi, 0) as chanzhi,
			project.customform60id,
			branch_office
		FROM
			(
				SELECT
					a.customform60id,
					a.cf_3654 AS branch_office,
					b.projectid
				FROM
					ld_customform60scf a
				LEFT JOIN ld_project b ON a.customform60id = b.customform60_id
			) project
		LEFT JOIN (
			SELECT
				sum(a.total) AS chanzhi,
				a.customform60_id,
				a.projectid
			FROM
				ld_servicecontracts a
			LEFT JOIN ld_customform60scf b ON a.customform60_id = b.customform60id $where
			AND a.projectid > 0
			AND a.due_date $date_sql
			GROUP BY
				a.projectid
		) chanzhi ON project.customform60id = chanzhi.customform60_id
		LEFT JOIN (
			SELECT
				ifnull(sum(a.total), 0) AS nums1,
				projectid
			FROM
				ld_purchaseorder a $where
			AND a.purchaseorderid > 0
			AND a.createdtime $date_sql
			GROUP BY
				projectid
		) a ON project.projectid = a.projectid
		LEFT JOIN (
			SELECT
				ifnull(sum(c.sf143), 0) AS nums2,
				projectid
			FROM
				ld_customform25 a
			LEFT JOIN ld_customform25detail b ON a.customform25id = b.entitytypeid
			LEFT JOIN ld_customform25detailscf c ON b.lineitem_id = c.lineitem_id $where
			AND a.customform25id > 0
			AND a.createdtime $date_sql
			GROUP BY
				projectid
		) b ON project.projectid = b.projectid
		LEFT JOIN (
			SELECT
				ifnull(sum(a.total), 0) AS nums3,
				projectid
			FROM
				ld_customform29 a $where
			AND a.customform29id > 0
			AND a.createdtime $date_sql
		) c ON project.projectid = c.projectid
		LEFT JOIN (
			SELECT
				ifnull(sum(a.total), 0) AS nums4,
				projectid
			FROM
				ld_customform15 a $where
			AND a.customform15id > 0
			AND a.createdtime $date_sql
			GROUP BY
				projectid
		) d ON project.projectid = d.projectid
		LEFT JOIN (
			SELECT
				ifnull(sum(a.total), 0) AS nums5,
				projectid
			FROM
				ld_expense a $where
			AND a.expenseid > 0
			AND a.createdtime $date_sql
			GROUP BY
				projectid
		) e ON project.projectid = e.projectid
	) a
GROUP BY
	customform60id
ORDER BY
	money DESC;";
                break;
            case "shoukuanList":
                $result['thead'] = ['排名','分公司名称','收款额(￥)'];
                //CashBill
                $sql = "select sum(a.total) as money,b.cf_3654 as branch_office from ld_cashbill a left join ld_customform60scf b on a.customform60_id=b.customform60id $where and a.createdtime $date_sql group by a.customform60_id order by money desc";
                break;
            default:
                //customform12
                $result['thead'] = ['排名','分公司名称','合同签约额（￥）'];
                $sql = "select sum(a.total) as money,b.cf_3654 as branch_office from ld_salesorder a left join ld_customform60scf b on a.customform60_id=b.customform60id  $where and a.createdtime $date_sql group by a.customform60_id order by money desc";
                break;
        }
        $res = $adb->pquery($sql);
//        print_r($sql);die;
        $nums = $adb->num_rows($res);
        $list = [];
        if($nums >0 ){
            for($i=0;$i<$nums;$i++){
                $list[$i]["sort"] = $i+1;
                $list[$i]["branch_office"] = $adb->query_result($res,$i,'branch_office');
                $list[$i]["money"] = number_format($adb->query_result($res,$i,'money'),2);
            }
        }
        $result['list'] = $list;
        return $result;
    }

    public function setMarketingReportSession($search_date,$reportlabel){
        $date_arr = self::getAdvancedQueryOfDate($search_date);
        $advft_criteria = [];
        switch ($reportlabel) {
            //营销报告
            case "new_project":
                $tmparr = getApprove_Query("ld_projects");
                $approve_value = $tmparr['value'];
                $modulename = 'Project';
                $approve_columnname = "ld_project:approvestatus:approvestatus:Project_审批状态:V";
                $time_columnname = "ld_project:createdtime:createdtime:Project_创建时间:DT";
                break;
            case "new_account":
                $tmparr = getApprove_Query("ld_account");
                $approve_value = $tmparr['value'];
                $modulename = 'Accounts';
                $approve_columnname = "ld_account:approvestatus:approvestatus:Accounts_审批状态:V";
                $time_columnname = "ld_account:createdtime:createdtime:Accounts_创建时间:DT";
                break;
            case "new_salesorder":
                $tmparr = getApprove_Query("ld_salesorder");
                $approve_value = $tmparr['value'];
                $modulename = 'SalesOrder';
                $approve_columnname = "ld_salesorder:approvestatus:approvestatus:SalesOrder_审批状态:V";
                $time_columnname = "ld_salesorder:createdtime:createdtime:SalesOrder_创建时间:DT";
                break;
            case "new_invoice":
                $tmparr = getApprove_Query("ld_invoice");
                $approve_value = $tmparr['value'];
                $modulename = 'Invoice';
                $approve_columnname = "ld_invoice:approvestatus:approvestatus:Invoice_审批状态:V";
                $time_columnname = "ld_invoice:createdtime:createdtime:Invoice_创建时间:DT";
                break;
            case "new_cashbill":
                $tmparr = getApprove_Query("ld_cashbill");
                $approve_value = $tmparr['value'];
                $modulename = 'CashBill';
                $approve_columnname = "ld_cashbill:approvestatus:approvestatus:CashBill_审批状态:V";
                $time_columnname = "ld_cashbill:createdtime:createdtime:CashBill_创建时间:DT";
                break;
            //项目报告-只有三个需要穿透 项目产值 产值考核指标 利润考核指标
            case "chanzhi_target":
            case "lirun_target":
            case "chanzhi_rate":
            case "lirun_rate":
                $tmparr = getApprove_Query("ld_customform32");
                $approve_value = $tmparr['value'];
                $modulename = 'CustomForm32';
                $approve_columnname = "ld_customform32:approvestatus:approvestatus:CustomForm32_审批状态:V";
                $time_columnname = "ld_customform32scf:cf_3655:cf_3655:CustomForm32_考核时间:D";
                break;
            case "chanzhi":
                $tmparr = getApprove_Query("ld_customform16");
                $approve_value = $tmparr['value'];
                $modulename = 'CustomForm16';
                $approve_columnname = "ld_customform16:approvestatus:approvestatus:CustomForm16_审批状态:V";
                $time_columnname = "ld_customform16scf:cf_4337:cf_4337:CustomForm16_申报期间（产值归属期间）:D";
                break;
        }
        if(!empty($time_columnname)) {
            $advft_criteria[$reportlabel][$modulename][] = [
                'groupid' => 1,
                'columnname' => $time_columnname,
                "comparator" => $date_arr['datecomparator'],
                "value" => $date_arr['date_value'],
                "columncondition" => "and"
            ];
        }

//        @edit:liushuai,2021-02-24,reason:【ID1001362】首页-审批状态可多选查看（四方光电）
        $sys_approve= getSys_Approvedeploy($modulename);
        $tmp_focus = CRMEntity::getInstance($modulename);
        if($sys_approve['deploy_value']==0 && isset($tmp_focus->column_fields['approvestatus'])) {//开启审批参数,并启用字段
            if(!empty($approve_value)){
                if (is_array($approve_value)) {
                    foreach ($approve_value as $val){
                        $advft_criteria[$reportlabel][$modulename][] = array(
                            'groupid' =>1,
                            'columnname' => $approve_columnname,
                            'comparator' => 'e',
                            'value' => $val,
                            'columncondition' => ' and ',
                        );
                    }
                }else{
                    $advft_criteria[$reportlabel][$modulename][] =  [
                        'groupid' =>1,
                        'columnname' => $approve_columnname,
                        'comparator' => 'e',
                        'value' => $approve_value,
                        'columncondition' => ' and ',
                    ];
                }
            }
        }


        return $advft_criteria;
    }



    //zxm 2021-0709 工程行业报表--项目执行分析图
    public function getProjectExecutionAnalysisChartData($search_date,$scopeType,$senioruserid,$approve_status){
        global $adb;
        //时间
        $yearmonth = $this->getAdvancedQueryOfDate($search_date);
        $yearmonth = $yearmonth['date_year_value'];
        $yearmonth = explode(',',$yearmonth);
        $yearmonth = isset($yearmonth[1])?$yearmonth[1]:date('Y-m-d');
        $yearmonth = date('Y-m-d',strtotime($yearmonth));
        //审批状态条件
        $whereApprove = '';
        if(!empty($approve_status)){
            if($approve_status !== 'all' && strpos($approve_status,'all') == false){
                $whereApprove = $approve_status;
                $whereApprove = str_replace("unapproved", D_A_S_UNAPPROVED ,$whereApprove);
                $whereApprove = str_replace("approving",D_A_S_APPROVALOF ,$whereApprove);
                $whereApprove = str_replace("approved", D_A_S_APPROVED,$whereApprove);
                $whereApprove = str_replace("rejected", D_A_S_REJECTED ,$whereApprove);
                $whereApprove = str_replace("dismissed", D_A_S_DISMISSED ,$whereApprove);
            }
        }
        $whereSmownerid = '';
        if(!empty($senioruserid)&&$senioruserid!="all"){
            $scope_obj = new ScopOfAuthority($adb,'MobileReport');
            $whereSmownerid = $scope_obj->getHomeSmOwnerSearchSql($scopeType,$senioruserid);
        }

        $sql = "
SELECT 
target_period,
IFNULL(total_order,0) as total_order,
IFNULL(total_received_amount,0) as total_received_amount,
IFNULL(total_invoice,0) as total_invoice,
IFNULL(total_planamount,0) as total_planamount,
IFNULL(total_receivable_balance,0) as total_receivable_balance,
IFNULL(total_cash,0) as total_cash,
IFNULL(total_nonbusinesscash,0) as total_nonbusinesscash,
IFNULL(total_purchaseorder,0) as total_purchaseorder,
IFNULL(total_pay_amount,0) as total_pay_amount,
IFNULL(total_sendplanamount,0) as total_sendplanamount,
IFNULL(total_expense,0) as total_expense
 from 
(SELECT
	seq,
	DATE_FORMAT(DATE_SUB('$yearmonth',INTERVAL 6-seq MONTH),'%Y-%m') AS target_period
FROM sequence
WHERE seq BETWEEN 1 AND 6
)a 
left join (
SELECT
	DATE_FORMAT(b.duedate,'%Y-%m') as yearmonth,
	SUM(b.total/IF(IFNULL(b.conversion_rate,0)=0,1,b.conversion_rate)) AS total_order,
	SUM(b.received_amount/IF(IFNULL(b.conversion_rate,0)=0,1,b.conversion_rate)) AS total_received_amount,
	SUM(b.have_invoicetotal/IF(IFNULL(b.conversion_rate,0)=0,1,b.conversion_rate)) AS total_invoice
FROM ld_project a
INNER JOIN ld_salesorder b ON b.projectid=a.projectid
WHERE a.deleted=0
	and b.deleted=0
	AND b.approvestatus<>'已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE  FIND_IN_SET(b.approvestatus,'$whereApprove') END)
	AND IFNULL(b.sostatus,'')<>'已作废'	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  b.$whereSmownerid END)
	AND a.projectstatus in('调研','开始','进行中','等待答复','搁置')
GROUP BY yearmonth
)b on a.target_period=b.yearmonth
LEFT JOIN (
SELECT
	DATE_FORMAT(c.plandate,'%Y-%m') as yearmonth,
	SUM(c.amount/IF(IFNULL(c.conversion_rate,0)=0,1,c.conversion_rate)) AS total_planamount,
	SUM(c.receivable_balance/IF(IFNULL(c.conversion_rate,0)=0,1,c.conversion_rate)) AS total_receivable_balance
FROM ld_paymentplan c
WHERE 
	c.deleted=0
	AND c.approvestatus<>'已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(c.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE c.$whereSmownerid END)
GROUP BY yearmonth
)c on a.target_period=c.yearmonth

LEFT JOIN (
SELECT
	DATE_FORMAT(c.cashbilldate,'%Y-%m') as yearmonth,
	SUM(c.Total/IF(IFNULL(c.conversion_rate,0)=0,1,c.conversion_rate)) AS total_cash
FROM ld_project a
INNER JOIN ld_salesorder b ON b.projectid=a.projectid
LEFT JOIN ld_cashbill c on c.source_list=b.salesorderid
WHERE a.deleted=0
	and b.deleted=0
	AND b.approvestatus<>'已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(b.approvestatus,'$whereApprove') END)
	AND IFNULL(b.sostatus,'')<>'已作废'	 AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  b.$whereSmownerid END)
	AND c.entitytype='SalesOrder'
	AND  a.projectstatus in('调研','开始','进行中','等待答复','搁置')
GROUP BY yearmonth
)d on a.target_period=d.yearmonth
LEFT JOIN(
SELECT
	DATE_FORMAT(c.cashbilldate,'%Y-%m') as yearmonth,
	SUM(c.Total/IF(IFNULL(c.conversion_rate,0)=0,1,c.conversion_rate)) AS total_nonbusinesscash
FROM ld_project a
INNER JOIN ld_salesorder b ON b.projectid=a.projectid
LEFT JOIN ld_cashbill c on c.source_list=b.salesorderid
WHERE a.deleted=0
	and b.deleted=0
	AND b.approvestatus<>'已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(b.approvestatus,'$whereApprove') END)
	AND IFNULL(b.sostatus,'')<>'已作废'	 AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  b.$whereSmownerid END)
	AND c.entitytype='SalesOrder'
	AND c.cashbill_type!='业务收款'
	AND  a.projectstatus in('调研','开始','进行中','等待答复','搁置')
GROUP BY yearmonth
)e on a.target_period=e.yearmonth
LEFT JOIN(
SELECT
	DATE_FORMAT(b.duedate,'%Y-%m') as yearmonth,
	SUM(b.total/IF(IFNULL(b.conversion_rate,0)=0,1,b.conversion_rate)) AS total_purchaseorder,
	SUM(b.pay_amount/IF(IFNULL(b.conversion_rate,0)=0,1,b.conversion_rate)) AS total_pay_amount
FROM ld_project a
INNER JOIN ld_purchaseorder b ON b.projectid=a.projectid
WHERE a.deleted=0
	and b.deleted=0
	AND b.approvestatus<>'已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(b.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  b.$whereSmownerid END)
	AND a.projectstatus in('调研','开始','进行中','等待答复','搁置')
GROUP BY yearmonth
)f on a.target_period=f.yearmonth
left join (
SELECT
	DATE_FORMAT(c.Plandate,'%Y-%m') as yearmonth,
	SUM(c.amount/IF(IFNULL(c.conversion_rate,0)=0,1,c.conversion_rate)) AS total_sendplanamount
FROM ld_sendpayment c
WHERE 
	c.deleted=0
	AND c.approvestatus<>'已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(c.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  c.$whereSmownerid END)
GROUP BY yearmonth
)g on a.target_period=g.yearmonth
LEFT JOIN (
SELECT
	DATE_FORMAT(c.expensedate,'%Y-%m') as yearmonth,
	SUM(c.total/IF(IFNULL(c.conversion_rate,0)=0,1,c.conversion_rate)) AS total_expense
FROM ld_expense c
WHERE 
	c.deleted=0
	AND c.approvestatus<>'已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(c.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  c.$whereSmownerid END)
GROUP BY yearmonth
)h on a.target_period=h.yearmonth";
        $res = $adb->pquery($sql);
        $nums = $adb->num_rows($res);
        $data = [];
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $data['target_period'][$i] = $adb->query_result($res,$i,'target_period');
                $data['total_order'][$i] = $adb->query_result($res,$i,'total_order');
                $data['total_received_amount'][$i] = $adb->query_result($res,$i,'total_received_amount');
                $data['total_invoice'][$i] = $adb->query_result($res,$i,'total_invoice');
                $data['total_planamount'][$i] = $adb->query_result($res,$i,'total_planamount');
                $data['total_receivable_balance'][$i] = $adb->query_result($res,$i,'total_receivable_balance');
                $data['total_cash'][$i] = $adb->query_result($res,$i,'total_cash');
                $data['total_nonbusinesscash'][$i] = $adb->query_result($res,$i,'total_nonbusinesscash');
                $data['total_purchaseorder'][$i] = $adb->query_result($res,$i,'total_purchaseorder');
                $data['total_pay_amount'][$i] = $adb->query_result($res,$i,'total_pay_amount');
                $data['total_sendplanamount'][$i] = $adb->query_result($res,$i,'total_sendplanamount');
                $data['total_expense'][$i] = $adb->query_result($res,$i,'total_expense');
            }
        }
        $data['title'] = $data['target_period'];
        return $data;
    }
    //zxm 2021-0709  应收合同执行分析
    public function getAnalysisOnExecutionOfReceivableContractData($search_date,$scopeType,$senioruserid,$approve_status){
        global $adb;
        //时间
        $yearmonth = $this->getAdvancedQueryOfDate($search_date);
        $yearmonth = $yearmonth['date_year_value'];
        $yearmonth = explode(',',$yearmonth);
        $yearmonth = isset($yearmonth[1])?$yearmonth[1]:date('Y-m-d');
        $yearmonth = date('Y-m-d',strtotime($yearmonth));
        //审批状态条件
        $whereApprove = '';
        if(!empty($approve_status)){
            if($approve_status !== 'all' && strpos($approve_status,'all') == false){
                $whereApprove = $approve_status;
                $whereApprove = str_replace("unapproved", D_A_S_UNAPPROVED ,$whereApprove);
                $whereApprove = str_replace("approving",D_A_S_APPROVALOF ,$whereApprove);
                $whereApprove = str_replace("approved", D_A_S_APPROVED,$whereApprove);
                $whereApprove = str_replace("rejected", D_A_S_REJECTED ,$whereApprove);
                $whereApprove = str_replace("dismissed", D_A_S_DISMISSED ,$whereApprove);
            }
        }
        $whereSmownerid = '';
        if(!empty($senioruserid)&&$senioruserid!="all"){
            $scope_obj = new ScopOfAuthority($adb,'MobileReport');
            $whereSmownerid = $scope_obj->getHomeSmOwnerSearchSql($scopeType,$senioruserid);
        }
        $sql = "
            select 
            target_period,
            IFNULL(total_order,0) as total_order,
            IFNULL(total_received_amount,0) as total_received_amount,
            IFNULL(total_invoice,0) as total_invoice,
            IFNULL(c.total_planamount,0) as total_planamount,
            IFNULL(d.total_planamount,0) as total_planamount_over
            from 
            (SELECT
            	seq,
            	DATE_FORMAT(DATE_SUB('$yearmonth',INTERVAL 6-seq MONTH),'%Y-%m') AS target_period
            FROM sequence
            WHERE seq BETWEEN 1 AND 6
            )a 
            LEFT JOIN
            
            (SELECT
            	DATE_FORMAT(b.duedate,'%Y-%m') as yearmonth,
            	SUM(b.total/IF(IFNULL(b.conversion_rate,0)=0,1,b.conversion_rate)) AS total_order,
            	SUM(b.received_amount/IF(IFNULL(b.conversion_rate,0)=0,1,b.conversion_rate)) AS total_received_amount,
            	SUM(b.have_invoicetotal/IF(IFNULL(b.conversion_rate,0)=0,1,b.conversion_rate)) AS total_invoice
            FROM ld_project a
            INNER JOIN ld_salesorder b ON b.projectid=a.projectid
            WHERE a.deleted=0
            	AND b.deleted=0
            	AND b.approvestatus<>'已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(b.approvestatus,'$whereApprove') END)
            	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  b.$whereSmownerid END)
            	AND IFNULL(b.sostatus,'')<>'已作废'	
            	AND a.projectstatus in('调研','开始','进行中','等待答复','搁置')
            GROUP BY yearmonth)
            b on a.target_period=b.yearmonth
            
            LEFT JOIN
            (SELECT
            	DATE_FORMAT(c.plandate,'%Y-%m') as yearmonth,
            	SUM(c.amount/IF(IFNULL(c.conversion_rate,0)=0,1,c.conversion_rate)) AS total_planamount
            FROM ld_paymentplan c
            WHERE 
            	c.deleted=0
            	AND c.approvestatus<>'已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(c.approvestatus,'$whereApprove') END)
            	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  c.$whereSmownerid END)
            GROUP BY yearmonth
            )
            c on a.target_period=c.yearmonth
            
            left join 
            (
            	SELECT
            	DATE_FORMAT(c.plandate,'%Y-%m') as yearmonth,
            	SUM(c.amount/IF(IFNULL(c.conversion_rate,0)=0,1,c.conversion_rate)) AS total_planamount
            FROM ld_paymentplan c
            WHERE 
            	c.deleted=0
            	AND c.approvestatus<>'已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(c.approvestatus,'$whereApprove') END)
            	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  c.$whereSmownerid END)
            	AND (c.actualdate>c.plandate or CURDATE()>c.plandate)
            GROUP BY yearmonth
            ) d on a.target_period=d.yearmonth
";
        $res = $adb->pquery($sql);
        $nums = $adb->num_rows($res);
        $data = [];
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $data['target_period'][$i] = $adb->query_result($res,$i,'target_period');
                $data['total_order'][$i] = $adb->query_result($res,$i,'total_order');
                $data['total_received_amount'][$i] = $adb->query_result($res,$i,'total_received_amount');
                $data['total_invoice'][$i] = $adb->query_result($res,$i,'total_invoice');
                $data['total_planamount'][$i] = $adb->query_result($res,$i,'total_planamount');
                $data['total_planamount_over'][$i] = $adb->query_result($res,$i,'total_planamount_over');
            }
        }
        $data['title'] = $data['target_period'];
        return $data;
    }
    //Project management data map  项目经营数据统览图
    public function getProjectManagementMapData($search_date,$scopeType,$senioruserid,$approve_status){
        global $adb;
        //时间
        $yearmonth = getHomeDateScope($search_date);
        //审批状态条件
        $whereApprove = '';
        if(!empty($approve_status)){
            if($approve_status !== 'all' && strpos($approve_status,'all') == false){
                $whereApprove = $approve_status;
                $whereApprove = str_replace("unapproved", D_A_S_UNAPPROVED ,$whereApprove);
                $whereApprove = str_replace("approving",D_A_S_APPROVALOF ,$whereApprove);
                $whereApprove = str_replace("approved", D_A_S_APPROVED,$whereApprove);
                $whereApprove = str_replace("rejected", D_A_S_REJECTED ,$whereApprove);
                $whereApprove = str_replace("dismissed", D_A_S_DISMISSED ,$whereApprove);
            }
        }
        $whereSmownerid = '';
        if(!empty($senioruserid)&&$senioruserid!="all"){
            $scope_obj = new ScopOfAuthority($adb,'MobileReport');
            $whereSmownerid = $scope_obj->getHomeSmOwnerSearchSql($scopeType,$senioruserid);
        }
        //edit:can 20210915 0047946: （https://www.51mis.com/hy/gongcyans0527 [^]）【项目经营数据统览图】： 1. （嘉运城郊施工）报表界面显示合同总额4866260，但合同订单界面，该项目合同金额仅5000 2. 许多企业做了数据但表中没有显示，如广州石
        $sql = "SELECT
	a.projectid,
	a.projectname,
	IFNULL(total_order, 0) AS total_order,
	IFNULL(total_received_amount, 0) AS total_received_amount,
	IFNULL(total_receivable_balance, 0) AS total_receivable_balance,
	IFNULL(total_sendcashbill, 0) AS total_sendcashbill,
	IFNULL(total_budget1, 0) + IFNULL(total_budget2, 0) AS total_budget,
	IFNULL(total_purchaseback, 0) AS total_purchaseback,
	IFNULL(total_received_amount, 0) - IFNULL(total_sendcashbill, 0) AS total_maoli
FROM
	(
		SELECT
			projectid,
			projectname
		FROM
			ld_project
		WHERE
			projectstatus IN (
				'调研',
				'开始',
				'进行中',
				'等待答复',
				'搁置'
			)
	) a
LEFT JOIN (
	SELECT
		a.projectid AS projectid,
		SUM(
			b.total /
			IF (
				IFNULL(b.conversion_rate, 0) = 0,
				1,
				b.conversion_rate
			)
		) AS total_order,
		SUM(
			b.received_amount /
			IF (
				IFNULL(b.conversion_rate, 0) = 0,
				1,
				b.conversion_rate
			)
		) AS total_received_amount,
		SUM(
			b.receivable_balance /
			IF (
				IFNULL(b.conversion_rate, 0) = 0,
				1,
				b.conversion_rate
			)
		) AS total_receivable_balance
	FROM
		ld_project a
	INNER JOIN ld_salesorder b ON b.projectid=a.projectid
	WHERE a.deleted = 0
	AND b.deleted = 0
	AND b.approvestatus <> '已拒绝'
	AND IFNULL(b.sostatus, '') <> '已作废' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(b.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  b.$whereSmownerid END) AND b.duedate $yearmonth
	and a.projectstatus in('调研','开始','进行中','等待答复','搁置')
	GROUP BY
		a.projectid
) b ON a.projectid = b.projectid
LEFT JOIN (
	SELECT
		a.projectid AS projectid,
		SUM(
			c.Total /
			IF (
				IFNULL(c.conversion_rate, 0) = 0,
				1,
				c.conversion_rate
			)
		) AS total_sendcashbill
	FROM
		ld_project a
	INNER JOIN ld_purchaseorder b ON b.projectid = a.projectid
	LEFT JOIN ld_sendcashbill c ON c.source_list = b.purchaseorderid
	WHERE a.deleted = 0
	AND b.deleted = 0
	AND b.approvestatus <> '已拒绝'  
	AND c.entitytype = 'PurchaseOrder' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(c.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  c.$whereSmownerid END) AND c.cashbilldate $yearmonth
	and a.projectstatus in('调研','开始','进行中','等待答复','搁置')
	GROUP BY
		a.projectid
) c ON a.projectid = c.projectid
LEFT JOIN (
	SELECT
		a.projectid,
		SUM(a.total) AS total_budget1
	FROM
		ld_customform14 a
	WHERE
		a.deleted = 0
	AND a.approvestatus <> '已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(a.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  a.$whereSmownerid END) AND a.createdtime $yearmonth
	AND a.projectid IN (
		SELECT
			projectid
		FROM
			ld_project
		WHERE
			projectstatus IN (
				'调研',
				'开始',
				'进行中',
				'等待答复',
				'搁置'
			)
	)
) d ON a.projectid = d.projectid
LEFT JOIN (
	SELECT
		a.projectid,
		SUM(a.total) AS total_budget2
	FROM
		ld_customform26 a
	WHERE
		a.deleted = 0
	AND a.approvestatus <> '已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(a.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  a.$whereSmownerid END) AND a.createdtime $yearmonth
	AND a.projectid IN (
		SELECT
			projectid
		FROM
			ld_project
		WHERE
			projectstatus IN (
				'调研',
				'开始',
				'进行中',
				'等待答复',
				'搁置'
			)
	)
) e ON a.projectid = e.projectid 
left join (
    SELECT
		a.projectid AS projectid,
		SUM(
			c.total /
			IF (
				IFNULL(c.conversion_rate, 0) = 0,
				1,
				c.conversion_rate
			)
		) AS total_purchaseback
	FROM
		ld_project a
	INNER JOIN ld_purchaseorder b ON b.projectid = a.projectid
	LEFT JOIN ld_purchaseback c ON c.purchaseorder_id = b.purchaseorderid
	WHERE a.deleted = 0
	AND b.deleted = 0
	AND b.approvestatus <> '已拒绝'  
	AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(b.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE c.$whereSmownerid END) AND c.purchasebackdate $yearmonth
	and a.projectstatus in('调研','开始','进行中','等待答复','搁置')
	GROUP BY
		a.projectid
)f on a.projectid=f.projectid
";

        $res = $adb->pquery($sql);
        $nums = $adb->num_rows($res);
        $data = [];
        $trades = getVersionTradeInfo();
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $data['projectid'][$i] = $adb->query_result($res,$i,'projectid');
                $data['projectname'][$i] = $adb->query_result($res,$i,'projectname');
                if($trades['trade'] == "construction"){
                    $data['projectname'][$i] = mb_substr($data['projectname'][$i],0,5);
                    $data['projectname'][$i] = $data['projectname'][$i].'...';
                }
                $data['total_order'][$i] = $adb->query_result($res,$i,'total_order');
                $data['total_received_amount'][$i] = $adb->query_result($res,$i,'total_received_amount');
                $data['total_receivable_balance'][$i] = $adb->query_result($res,$i,'total_receivable_balance');
                $data['total_sendcashbill'][$i] = $adb->query_result($res,$i,'total_sendcashbill');
                $data['total_budget'][$i] = $adb->query_result($res,$i,'total_budget');
                $data['total_purchaseback'][$i] = $adb->query_result($res,$i,'total_purchaseback');
                $data['total_maoli'][$i] = $adb->query_result($res,$i,'total_maoli');
            }
        }
        $data['title'] = $data['projectname'];
        return $data;
    }

    //在建项目综合数据
    public function getProjectsUnderConstructionComprehensiveData($search_date,$scopeType,$senioruserid,$approve_status){
        global $adb;
        $stuffId = 64;
        //时间
        $yearmonth = getHomeDateScope($search_date);
        //审批状态条件
        $whereApprove = '';
        if(!empty($approve_status)){
            if($approve_status !== 'all' && strpos($approve_status,'all') == false){
                $whereApprove = $approve_status;
                $whereApprove = str_replace("unapproved", D_A_S_UNAPPROVED ,$whereApprove);
                $whereApprove = str_replace("approving",D_A_S_APPROVALOF ,$whereApprove);
                $whereApprove = str_replace("approved", D_A_S_APPROVED,$whereApprove);
                $whereApprove = str_replace("rejected", D_A_S_REJECTED ,$whereApprove);
                $whereApprove = str_replace("dismissed", D_A_S_DISMISSED ,$whereApprove);
            }
        }
        $whereSmownerid = '';
        if(!empty($senioruserid)&&$senioruserid!="all"){
            $scope_obj = new ScopOfAuthority($adb,'MobileReport');
            $whereSmownerid = $scope_obj->getHomeSmOwnerSearchSql($scopeType,$senioruserid);
        }
        $sql = "select * from ld_homestuffdetail
                where ld_homestuffdetail.presence='yes' and stuffid=$stuffId
                ORDER BY ld_homestuffdetail.sequence asc,stufflabel asc;";
        $result = $adb->pquery($sql,array());
        $rows = $adb->num_rows($result);
        $ret_data = array();
        for($i=0;$i<$rows;$i++){
            $stufflabel = $adb->query_result($result,$i,'stufflabel');
            $stufflabeltype = $adb->query_result($result,$i,'stufflabeltype');
            $cssname = $adb->query_result($result,$i,'cssname');
            $pageurl = $adb->query_result($result,$i,'pageurl');
            $icon = $adb->query_result($result,$i,'icon');
            $label=getFixedLabel($stufflabel);
//            项目总应收 TotalProjectReceivables
//            直接成本预算总额 TotalDirectCostBudget
//            间接成本预算总额 TotalIndirectCostBudget
            //应退款总额 TotalAmountOfRefund--0722新增
            //成本总额 TotalExpectedCost --0722新增
//            项目预期利润 ExpectedProfitOfTheProject
//            项目已付款  ProjectPaid
//            项目已收款  ProjectReceived
            //已退款总额 TotalRefunded --0722新增
//            收支净额   NetIncomeAndExpenditure
//            到期应收款   DueReceivables
//            逾期应收款   OverdueReceivables

            //项目条件  未玩成项目
            $projectSql = "select projectid from ld_project  where  projectstatus in('调研','开始','进行中','等待答复','搁置')";
            switch ($stufflabel){
                //项目总应收
                case 'TotalProjectReceivables':
                    $valuesql = "SELECT
	SUM(ifnull(a.total,0)/IF(IFNULL(a.conversion_rate,0)=0,1,a.conversion_rate)) AS totalvalue
FROM ld_salesorder a LEFT JOIN ld_project b on a.salesorderid=b.salesorderid
WHERE a.deleted=0
	AND a.approvestatus<>'已拒绝' 
	AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(a.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  a.$whereSmownerid END) 
	AND a.createdtime $yearmonth
	AND IFNULL(a.sostatus,'')<>'已作废'	
	AND b.projectid IN (select projectid from ld_project  where  projectstatus in('调研','开始','进行中','等待答复','搁置'))";
                    break;
                //直接成本预算总额=>0128改成采购预算总额
                case 'TotalDirectCostBudget':
                    $valuesql = "SELECT
		SUM(ifnull(a.total,0)) AS totalvalue
	FROM
		ld_customform14 a
	WHERE
		a.deleted = 0
	AND a.approvestatus <> '已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(a.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  a.$whereSmownerid END) AND a.createdtime $yearmonth
	AND a.projectid IN ($projectSql)";
                    break;
                //间接成本预算总额=>0128改成 零散费用预算总额
                case 'TotalIndirectCostBudget':
                    $valuesql = "SELECT
		SUM(ifnull(a.total,0)) AS totalvalue
	FROM
		ld_customform26 a
	WHERE
		a.deleted = 0
	AND a.approvestatus <> '已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(a.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  a.$whereSmownerid END) AND a.createdtime $yearmonth
	AND a.projectid IN ($projectSql)";
                    break;
                //应退款总额
                case "TotalAmountOfRefund":
                    $valuesql = "
                    
                    
    SELECT
		SUM(c.total /IF (IFNULL(c.conversion_rate, 0) = 0,1,c.conversion_rate)) AS totalvalue
    FROM ld_purchaseback c
    INNER JOIN ld_purchaseorder b ON b.purchaseorderid = c.purchaseorder_id
    WHERE c.deleted=0
        AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  c.$whereSmownerid END) AND c.createdtime $yearmonth
        AND b.projectid IN ($projectSql)";
    
    //echo $valuesql;die();
                    break;
                //预期成本总额
                case "TotalExpectedCost":
                    $valuesql = " select (ifnull(a.totalvalue,0)+ifnull(b.totalvalue,0)-ifnull(c.totalvalue,0)) as totalvalue from 
 (SELECT
    SUM(ifnull(a.total,0)) AS totalvalue,'dol' as dol
FROM
    ld_customform14 a
WHERE
    a.deleted = 0
AND a.approvestatus <> '已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(a.approvestatus,'$whereApprove') END)
AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  a.$whereSmownerid END) AND a.createdtime $yearmonth
AND a.projectid IN ($projectSql)
) a 
left join (
SELECT
		SUM(ifnull(a.total,0)) AS totalvalue,'dol' as dol
	FROM
		ld_customform26 a
	WHERE
		a.deleted = 0
	AND a.approvestatus <> '已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(a.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  a.$whereSmownerid END) AND a.createdtime $yearmonth
	AND a.projectid IN ($projectSql)
) b on a.dol=b.dol
left join (
SELECT
		SUM(c.total /IF (IFNULL(c.conversion_rate, 0) = 0,1,c.conversion_rate)) AS totalvalue,'dol' as dol
	FROM ld_project a
	INNER JOIN ld_purchaseorder b ON b.projectid = a.projectid
	LEFT JOIN ld_purchaseback c ON c.purchaseorder_id = b.purchaseorderid
	WHERE a.deleted = 0
	AND b.deleted = 0 AND b.approvestatus <> '已拒绝'  
	AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(b.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  c.$whereSmownerid END) AND c.createdtime $yearmonth
	AND a.projectid IN (
		$projectSql
	)
) c on a.dol=c.dol
 ";
                    break;
                //项目预期利润
                case 'ExpectedProfitOfTheProject':
                    $valuesql = "select (ifnull(a.totalvalue,0) - ifnull(b.totalvalue,0) - ifnull(c.totalvalue,0)) as totalvalue from (
    SELECT
	SUM(a.total/IF(IFNULL(a.conversion_rate,0)=0,1,a.conversion_rate)) AS totalvalue,'dol' as dol
    FROM ld_salesorder a LEFT JOIN ld_project b on a.projectid=b.projectid
    WHERE a.deleted=0
	AND a.approvestatus<>'已拒绝' 
	AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(a.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  a.$whereSmownerid END) 
	AND a.createdtime $yearmonth
	AND IFNULL(a.sostatus,'')<>'已作废'	
	AND b.projectid IN ($projectSql)
) a left join (
    SELECT
    SUM(a.total) AS totalvalue ,'dol' as dol
	FROM
		ld_customform14 a
	WHERE
		a.deleted = 0
	AND a.approvestatus <> '已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(a.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  a.$whereSmownerid END) AND a.createdtime $yearmonth
	AND a.projectid IN ($projectSql)
) b on a.dol=b.dol left join (
    SELECT
		SUM(a.total) AS totalvalue,'dol' as dol
	FROM
		ld_customform26 a
	WHERE
		a.deleted = 0
	AND a.approvestatus <> '已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(a.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  a.$whereSmownerid END) AND a.createdtime $yearmonth
	AND a.projectid IN ($projectSql)
)c on a.dol=c.dol";
                    break;
                //项目已付款
                case 'ProjectPaid':
                    //项目已付款
                $valuesql = "
                    SELECT
                        SUM(c.Total/IF(IFNULL(c.conversion_rate,0)=0,1,c.conversion_rate)) AS totalvalue
                	FROM ld_sendcashbill c
                	WHERE c.deleted = 0
                	   AND c.approvestatus <> '已拒绝'  
                	   AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(c.approvestatus,'$whereApprove') END)
                	   AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  c.$whereSmownerid END) AND c.cashbilldate $yearmonth
                       AND c.projectid IN ($projectSql)";
                    //echo $valuesql;die();
                    break;
                //项目已收款
                case 'ProjectReceived':
                    //项目已收款
                $valuesql = "
                    SELECT
                    	SUM(a.received_amount/IF(IFNULL(a.conversion_rate,0)=0,1,a.conversion_rate)) AS totalvalue
                    FROM ld_salesorder a
                    WHERE a.deleted=0
                        AND IFNULL(a.sostatus,'')<>'已作废'	 
                    	AND a.approvestatus<>'已拒绝' 
                        AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(a.approvestatus,'$whereApprove') END)
                        AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  a.$whereSmownerid END) 
                        AND a.signed_data $yearmonth
                    	AND a.projectid IN ($projectSql)";
                    //echo $valuesql;die();
                    break;
                //已退款总额
                case 'TotalRefunded':
                    $valuesql = "
                        SELECT
                            SUM(d.total /IF (IFNULL(d.conversion_rate, 0) = 0,1,d.conversion_rate)) AS totalvalue
                        FROM ld_purchasecashback d
                        LEFT JOIN ld_purchaseback c ON c.purchasebackid = d.purchaseback_id
                        INNER JOIN ld_purchaseorder b ON b.purchaseorderid = c.purchaseorder_id
                        WHERE d.deleted = 0
                            AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  d.$whereSmownerid END) 
                            AND d.createdtime $yearmonth
                            AND b.projectid IN ($projectSql)";
                    //echo $valuesql;die();
                    break;
                //收支净额
                case 'NetIncomeAndExpenditure':
                    //收支净额
                    $valuesql = "
                        SELECT
                        	SUM(totalvalue) AS totalvalue
                        FROM(
                        SELECT
                        	SUM(a.Total/IF(IFNULL(a.conversion_rate,0)=0,1,a.conversion_rate)) AS totalvalue
                        FROM ld_salesorder a
                        WHERE a.deleted=0
                        		AND IFNULL(a.sostatus,'')<>'已作废'	 
                        	AND a.approvestatus<>'已拒绝' 
                        		AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(a.approvestatus,'$whereApprove') END)
                        		AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  a.$whereSmownerid END) 
                        		AND a.signed_data $yearmonth
                        	AND a.projectid IN ($projectSql)
                        UNION ALL
                        SELECT
                        	0-SUM(c.Total/IF(IFNULL(c.conversion_rate,0)=0,1,c.conversion_rate)) AS totalvalue
                        FROM ld_sendcashbill c
                        WHERE c.deleted = 0
                         AND c.approvestatus <> '已拒绝'  
                         AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(c.approvestatus,'$whereApprove') END)
                         AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  c.$whereSmownerid END) AND c.cashbilldate $yearmonth
                        	 AND c.projectid IN ($projectSql)
                        UNION ALL
                        SELECT
                        	SUM(d.total /IF (IFNULL(d.conversion_rate, 0) = 0,1,d.conversion_rate)) AS totalvalue
                        FROM ld_purchasecashback d
                        LEFT JOIN ld_purchaseback c ON c.purchasebackid = d.purchaseback_id
                        INNER JOIN ld_purchaseorder b ON b.purchaseorderid = c.purchaseorder_id
                        WHERE d.deleted = 0
                        	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  d.$whereSmownerid END) 
                        	AND d.createdtime $yearmonth
                        	AND b.projectid IN ($projectSql)
                        ) a";
                    //echo $valuesql;die();
                    break;
                //到期应收款
                case 'DueReceivables':
                    $next30days = date('Y-m-d',strtotime('+30 days'));
                    $valuesql = "SELECT
	SUM(c.amount/IF(IFNULL(c.conversion_rate,0)=0,1,c.conversion_rate)) AS totalvalue
FROM ld_paymentplan c
WHERE 
	c.deleted=0
	AND c.approvestatus<>'已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(c.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  c.$whereSmownerid END)
	AND c.plandate<'$next30days' and  c.actualdate is null";
                    //到期应收款
                    break;
                //逾期应收款
                case 'OverdueReceivables':
                    $next30days = date('Y-m-d',strtotime('+30 days'));
                    $now = date('Y-m-d');
                    $valuesql = "SELECT
	SUM(c.amount/IF(IFNULL(c.conversion_rate,0)=0,1,c.conversion_rate)) AS totalvalue
FROM ld_paymentplan c
WHERE 
	c.deleted=0
	AND c.approvestatus<>'已拒绝' AND (CASE WHEN '$whereApprove'='' THEN 1=1 ELSE FIND_IN_SET(c.approvestatus,'$whereApprove') END)
	AND (CASE WHEN '$whereSmownerid'='' THEN 1=1 ELSE  c.$whereSmownerid END)
	AND c.plandate<'$now'  AND  c.actualdate is null";
                    //逾期应收款
                    break;
                
            }
            $valueresult = $adb->pquery($valuesql,array());
            $totalvalue = 0;
            if($adb->num_rows($valueresult)>0){
                $totalvalue = $adb->query_result($valueresult,0,'totalvalue');
                $totalvalue = empty($totalvalue)?0:$totalvalue;
            }
            $ret_data[$stufflabel] = array(
                'nums'=>'￥'.number_format($totalvalue,2),
                'label'=>$stufflabel,
                'module'=>'',
                'css'=>$cssname,
                'name'=>$label,
                'urls'=>$pageurl,
                'back_img'=>$icon);

        }
        return $ret_data;
    }

    //收支报告65
    public function  getIncomeAndExpenditureReportData($search_date,$scopeType,$senioruserid,$approve_status){
        $stuffId = 65;
        require_once globalStatic::$root_directory.'modules/Home/HomeStuffDetailUtils.php';
        $HomeStuffDetailUtilsObj = new HomeStuffDetailUtils(0);
        $params = array(
            'scopeType'=>$scopeType,
            'senioruserid'=>$senioruserid,
            'search_date'=>$search_date,
            'approve_value'=>$approve_status,
        );
        $HomeStuffDetailUtilsObj->initParam($params);
        $HomeStuffDetailUtilsObj->setStuffid($stuffId,0);
        $home_values = $HomeStuffDetailUtilsObj->getSalesKit();
        return $home_values;
    }
}