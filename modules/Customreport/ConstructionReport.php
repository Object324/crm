<?php

$function = $_REQUEST['function_name'];
$obj = new ConstructionReport();
$is_ajax = $_REQUEST['is_ajax'];
$obj->$function($is_ajax);
$_REQUEST['diony'] = 'yes';
//判断是否是异步请求 异步请求返回json  否则渲染模板
if($is_ajax == "yes"){
    ConvertTojsonString(1,['list'=>$obj->list,'page'=>$obj->page,'total_pages'=>$obj->total_pages,'total_nums'=>$obj->total_nums],'success');
}else{
    $obj->smarty->assign('request',$_REQUEST);
    $obj->smarty->assign('language',$obj->language);
    $obj->smarty->assign('list',$obj->list);
    $obj->smarty->assign('page', $obj->page);
    $obj->smarty->assign('total_pages', $obj->total_pages);
    $obj->smarty->assign('total_nums', $obj->total_nums);
    $obj->smarty->display('construction/'.$obj->template_name.'.tpl');
}

class ConstructionReport
{
    public $adb;
    public $smarty;
    public $language;
    public $list,$page,$total_pages,$total_nums,$template_name;
    public function __construct()
    {
        global $adb,$languageType;
        $this->smarty = new lingdangCRM_Smarty();
        $this->adb = $adb;
        $this->language = $languageType;
    }

    public function getProjectReport($is_ajax){
        $where = "deleted=0";
        $project_no = $_REQUEST['project_no'];
        $project_no_where = '';
        if(!empty($project_no)){
            $project_no_where = " and b.projectid like '%".$project_no."%'";
        }
        $account_name = $_REQUEST['account_name'];
        $account_name_where = '';
        if(!empty($account_name)){
            $account_name_where = " and c.accountname like '%".$account_name."%'";
        }
        //时间
//        if($is_ajax!="yes"){
            $time_arr = explode('~',$_REQUEST['search_date_custom_value']);
            $date_sql = getHomeDateScope($_REQUEST['search_date_custom_value']);
            $_REQUEST['start_time'] = $time_arr[0].' 00:00:00';
            $_REQUEST['end_time'] = $time_arr[1].' 23:59:59';
//        }else{
//            $start_time = $_REQUEST['start_time'];
//            $end_time = $_REQUEST['end_time'];
//            $date_sql = "between '$start_time' and '$end_time'";
//        }

        //查看人员范围
        $scopeType = 'smowner_search_senior';
        if(!empty($_REQUEST['selectuserid']))
        {
            $senioruserid = $_REQUEST['selectuserid'];
        }
        $d_where = '';
        if(!empty($senioruserid)&&$senioruserid!="all"){
            $scope_obj = new ScopOfAuthority($this->adb,'Home');
            $smownerid_sql = $scope_obj->getHomeSmOwnerSearchSql($scopeType,$senioruserid);
            $d_where = ' and d.'.$smownerid_sql;
            $where .= ' and a.'.$smownerid_sql;
        }
        $same_sql = "(
		SELECT
			ifnull(chanzhi, 0) AS chanzhi,
			ifnull(nums1, 0) AS nums1,
			ifnull(nums2, 0) AS nums2,
			ifnull(nums3, 0) AS nums3,
			ifnull(nums4, 0) AS nums4,
			ifnull(nums5, 0) AS nums5,
			project.projectid,
			project.projectname,
			project.customform60id,
			project.accountname,
			project.branch_office,
			project.hetong_money
		FROM
			(
				SELECT
					a.customform60id,
					a.cf_3654 AS branch_office,
					b.projectid,
					b.projectname,
					c.accountname,
					SUM(total) AS hetong_money
				FROM
				    ld_project b
				LEFT JOIN ld_customform60scf a ON a.customform60id = b.customform60_id
				LEFT JOIN ld_account c ON b.accountid = c.accountid
				LEFT JOIN ld_salesorder d ON b.projectid = d.projectid
				WHERE d.deleted=0 $d_where $account_name_where $project_no_where AND d.createdtime $date_sql
				GROUP BY b.projectid
			) project
		LEFT JOIN (
			SELECT
				sum(a.total) AS chanzhi,
				a.customform60_id,
				a.projectid
			FROM
				ld_servicecontracts a
            LEFT JOIN ld_customform60scf b ON a.customform60_id = b.customform60id 
			WHERE a.$where
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
				ld_purchaseorder a  WHERE a.$where
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
			LEFT JOIN ld_customform25detailscf c ON b.lineitem_id = c.lineitem_id  WHERE a.$where
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
				ld_customform29 a  WHERE a.$where
			AND a.customform29id > 0
			AND a.createdtime $date_sql
		) c ON project.projectid = c.projectid
		LEFT JOIN (
			SELECT
				ifnull(sum(a.total), 0) AS nums4,
				projectid
			FROM
				ld_customform15 a  WHERE a.$where
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
				ld_expense a  WHERE a.$where
			AND a.expenseid > 0
			AND a.expensedate $date_sql
			GROUP BY
				projectid
		) e ON project.projectid = e.projectid";
        //分页
        $page = $_REQUEST['page'];
        $limit = 100;
        $count_field = "count(distinct projectid) as nums";
        $count_sql = "select $count_field 
FROM
	$same_sql
	) a
";
        $count_res = $this->adb->pquery($count_sql);
        $total_nums = $this->adb->query_result($count_res,0,'nums');//总条数
        $total_pages = ceil($total_nums/$limit);
        $page = empty($page)?1:$page;

        if($total_pages<=$page&&$total_pages>=1){
            $page = $total_pages;
        }
        $page_start = ($page-1)*$limit;
        $_REQUEST['page'] = $page;
        //导出的时候不分页
        $is_limit_where = "limit $page_start,$limit";
        if($_REQUEST['is_export'] == "yes"){
            $is_limit_where = "";
        }
        $field = "chanzhi,nums1,nums2,nums3,nums4,nums5,projectid,projectname,customform60id,accountname,branch_office,hetong_money,sum(
            nums1 + nums2 + nums3 + nums4 + nums5
        ) AS chengben,
        sum(
            chanzhi - nums1 - nums2 - nums3 - nums4 - nums5
        ) AS maoli,
        CASE WHEN chanzhi <= 0 THEN 0 
        ELSE  sum(
            chanzhi - nums1 - nums2 - nums3 - nums4 - nums5
        )*100 / sum(chanzhi) END AS maoli_rate";

        $sql = "SELECT 
    $field
FROM
	$same_sql
	) a
GROUP BY
	projectid
ORDER BY
	maoli DESC $is_limit_where
;";

        $res = $this->adb->pquery($sql);
        $nums = $this->adb->num_rows($res);
        $list = [];
        $heji = 0;
        for($i=0;$i<$nums;$i++){
            $list[$i]['no'] = $i+1;
            $list[$i]['chanzhi'] = number_format($this->adb->query_result($res,$i,'chanzhi'),2);
            $list[$i]['nums1'] = number_format($this->adb->query_result($res,$i,'nums1'),2);
            $list[$i]['nums2'] = number_format($this->adb->query_result($res,$i,'nums2'),2);
            $list[$i]['nums3'] = number_format($this->adb->query_result($res,$i,'nums3'),2);
            $list[$i]['nums4'] = number_format($this->adb->query_result($res,$i,'nums4'),2);
            $list[$i]['nums5'] = number_format($this->adb->query_result($res,$i,'nums5'),2);
            $list[$i]['projectid'] = $this->adb->query_result($res,$i,'projectid');
            $list[$i]['projectname'] = $this->adb->query_result($res,$i,'projectname');
            $list[$i]['chengben'] = number_format($this->adb->query_result($res,$i,'chengben'),2);
            $list[$i]['accountname'] = $this->adb->query_result($res,$i,'accountname');
            $list[$i]['branch_office'] = $this->adb->query_result($res,$i,'branch_office');
            $list[$i]['branch_office'] = empty($list[$i]['branch_office'])?"-":$list[$i]['branch_office'];
            $list[$i]['hetong_money'] = number_format($this->adb->query_result($res,$i,'hetong_money'),2);
            $list[$i]['maoli'] = number_format($this->adb->query_result($res,$i,'maoli'),2);
            $list[$i]['maoli_rate'] = number_format($this->adb->query_result($res,$i,'maoli_rate'),2);
        }
        $this->list = $list;
        $this->page = $page;
        $this->total_nums = $total_nums;
        $this->total_pages = $total_pages;
        $this->template_name = 'project_report';
    }

    //zxm 2021-0201 直接成本预算实际对比报表
    public function getCostCompare($is_ajax)
    {
        $start = $_REQUEST['start_time'];
        $end = $_REQUEST['end_time'];
        //默认本月
        $curr_month = date('Y-m-01',strtotime('-12 month'));
        $start = empty($start)?$curr_month.' 00:00:00':$start;
        $end = empty($end)?date('Y-m-d H:i:s',time()):$end;
        $_REQUEST['start_time'] = $start;
        $_REQUEST['end_time'] = $end;
        $time_sql = " between '$start' and '$end'";
        $plan_sql = "SELECT
	a.projectid,
	a.projectname,
		CASE d.sf320
		WHEN '材料' THEN
			sum(c.amount)
		ELSE
			0
	END cailiao,
	CASE d.sf320
		WHEN '劳务' THEN
			sum(c.amount)
		ELSE
			0
	END laowu,
CASE d.sf320
		WHEN '分包' THEN
			sum(c.amount)
		ELSE
			0
	END fenbao,
CASE d.sf320
		WHEN '租赁' THEN
			sum(c.amount)
		ELSE
			0
	END zulin
FROM
	ld_project a
LEFT JOIN ld_customform30 b ON a.projectid = b.projectid
LEFT JOIN ld_customform30detail c ON c.id = b.customform30id
LEFT JOIN ld_customform30detailscf d ON d.lineitem_id = c.lineitem_id
WHERE
	a.deleted = 0
AND b.deleted = 0
GROUP BY
	a.projectid,
	d.sf320";
        //分页
        $page = $_REQUEST['page'];
        $limit = 100;
        $count_field = "count(distinct projectid) as nums";
        $count_sql = "select $count_field from ld_project  where deleted=0 and createdtime $time_sql";
        $count_res = $this->adb->pquery($count_sql);
        $total_nums = $this->adb->query_result($count_res,0,'nums');//总条数
        $total_pages = ceil($total_nums/$limit);
        $page = empty($page)?1:$page;
        if($total_pages<=$page&&$total_pages>=1){
            $page = $total_pages;
        }
        $page_start = ($page-1)*$limit;
        $_REQUEST['page'] = $page;
        $is_limit_where = "limit $page_start,$limit";
        $actual_sql = "SELECT
	project.projectid,
	project.projectname,
	a.cailiao,
	b.laowu,
	c.fenbao,
	d.zulin,
	sum(plan.cailiao) AS plan_cailiao,
	sum(plan.laowu) AS plan_laowu,
	sum(plan.fenbao) AS plan_fenbao,
	sum(plan.zulin) AS plan_zulin
FROM
	(
		SELECT
			projectid,
			projectname
		FROM
			ld_project
		WHERE
			deleted = 0
		AND createdtime $time_sql
	) project
LEFT JOIN (
	SELECT
		sum(total) AS cailiao,
		projectid
	FROM
		ld_purchaseorder
	GROUP BY
		projectid
) a ON project.projectid = a.projectid
LEFT JOIN (
	SELECT
		sum(c.sf143) AS laowu,
		a.projectid
	FROM
		ld_customform25 a
	LEFT JOIN ld_customform25detail b ON a.customform25id = b.id
	LEFT JOIN ld_customform25detailscf c ON b.lineitem_id = c.lineitem_id
) b ON project.projectid = b.projectid
LEFT JOIN (
	SELECT
		sum(total) AS fenbao,
		projectid
	FROM
		ld_customform29
) c ON project.projectid = b.projectid
LEFT JOIN (
	SELECT
		sum(total) AS zulin,
		projectid
	FROM
		ld_customform15
) d ON project.projectid = d.projectid
LEFT JOIN ($plan_sql) plan ON project.projectid = plan.projectid
GROUP BY
	projectid $is_limit_where";
        $actual_res = $this->adb->pquery($actual_sql);
        $actual_nums = $this->adb->num_rows($actual_res);
        $res = [];
        //列合计
        $total['no'] = $actual_nums+1;
        $total['projectname'] = '小计';
        $total['projectid'] = '';
        for($i=0;$i<$actual_nums;$i++){
            $res[$i]['no'] = $i+1;
            $res[$i]['projectid'] = $this->adb->query_result($actual_res,$i,'projectid');
            $res[$i]['projectname'] = $this->adb->query_result($actual_res,$i,'projectname');
            $res[$i]['cailiao'] = $this->adb->query_result($actual_res,$i,'cailiao');
            $res[$i]['laowu'] = $this->adb->query_result($actual_res,$i,'laowu');
            $res[$i]['fenbao'] = $this->adb->query_result($actual_res,$i,'fenbao');
            $res[$i]['zulin'] = $this->adb->query_result($actual_res,$i,'zulin');
            $res[$i]['plan_cailiao'] = $this->adb->query_result($actual_res,$i,'plan_cailiao');
            $res[$i]['plan_laowu'] = $this->adb->query_result($actual_res,$i,'plan_laowu');
            $res[$i]['plan_fenbao'] = $this->adb->query_result($actual_res,$i,'plan_fenbao');
            $res[$i]['plan_zulin'] = $this->adb->query_result($actual_res,$i,'plan_zulin');
            $res[$i]['gap_cailiao'] = $res[$i]['plan_cailiao']-$res[$i]['cailiao'];
            $res[$i]['gap_laowu'] = $res[$i]['plan_laowu']-$res[$i]['laowu'];
            $res[$i]['gap_fenbao'] = $res[$i]['plan_fenbao']-$res[$i]['fenbao'];
            $res[$i]['gap_zulin'] = $res[$i]['plan_zulin']-$res[$i]['zulin'];
            $res[$i]['total'] = $res[$i]['cailiao']+$res[$i]['laowu']+$res[$i]['fenbao']+$res[$i]['zulin'];
            $res[$i]['plan_total'] = $res[$i]['plan_cailiao']+$res[$i]['plan_laowu']+$res[$i]['plan_fenbao']+$res[$i]['plan_zulin'];
            $res[$i]['gap_total'] = $res[$i]['plan_total']-$res[$i]['total'];
            $total['cailiao'] += $res[$i]['cailiao'];
            $total['laowu'] += $res[$i]['laowu'];
            $total['fenbao'] += $res[$i]['fenbao'];
            $total['zulin'] += $res[$i]['zulin'];

            $total['plan_cailiao'] += $res[$i]['plan_cailiao'];
            $total['plan_laowu'] += $res[$i]['plan_laowu'];
            $total['plan_fenbao'] += $res[$i]['plan_fenbao'];
            $total['plan_zulin'] += $res[$i]['plan_zulin'];

            $total['gap_cailiao'] += $res[$i]['gap_cailiao'];
            $total['gap_laowu'] += $res[$i]['gap_laowu'];
            $total['gap_fenbao'] += $res[$i]['gap_fenbao'];
            $total['gap_zulin'] += $res[$i]['gap_zulin'];
            $total['total'] += $res[$i]['total'];
            $total['plan_total'] += $res[$i]['plan_total'];
            $total['gap_total'] += $res[$i]['gap_total'];
            foreach($res[$i] as $k=>&$v){
                if(in_array($k,['gap_cailiao','gap_laowu','gap_fenbao','gap_zulin','gap_total'])){
                    if($v<0){
                        $res[$i][$k.'_style'] = 'style="color:red;"';
                    }else{
                        $res[$i][$k.'_style'] = '';
                    }
                }
                if(!in_array($k,['no','projectid','projectname','gap_cailiao_style','gap_laowu_style','gap_fenbao_style','gap_zulin_style','gap_total_style'])){
                    $v = number_format($v,2);
                }
            }
        }
        $total['gap_cailiao_style'] = $total['gap_cailiao']<0?'style="color:red;"':'';
        $total['gap_laowu_style'] = $total['gap_laowu']<0?'style="color:red;"':'';
        $total['gap_fenbao_style'] = $total['gap_fenbao']<0?'style="color:red;"':'';
        $total['gap_zulin_style'] = $total['gap_zulin']<0?'style="color:red;"':'';
        $total['gap_total_style'] = $total['gap_total']<0?'style="color:red;"':'';
        $total['gap_cailiao'] = number_format($total['gap_cailiao'],2);
        $total['gap_laowu'] = number_format($total['gap_laowu'],2);
        $total['gap_fenbao'] = number_format($total['gap_fenbao'],2);
        $total['gap_zulin'] = number_format($total['gap_zulin'],2);
        $total['gap_total'] = number_format($total['gap_total'],2);
        $res[$actual_nums] = $total;
        $this->list = $res;
        $this->page = $page;
        $this->total_nums = $total_nums;
        $this->total_pages = $total_pages;
        $this->template_name = 'cost_compare';
    }
}