<?php
require_once globalStatic::$root_directory.'modules/Home/HomeParentUtils.php';
class TiandiUtils extends HomeParentUtils{
    //天地 特殊开发 销售漏斗（含目标）
    public function getTD_PotentialsFunnel(){
        global $adb,$languageType;
        if($this->search_date === 'all'){
            $this->search_date = 'thisyear';
        }
        $dateinfo = $this->getDateInfo($this->search_date);
        //$daterangesql = getHomeDateScope($this->search_date);
        $system_deploy_351 = $this->system_deploy_351;//单据分录明细金额字段和单据头货币字段小数位数
        $datarangesql_Potentials = $this->datarangesqlArr['datarangesql_Potentials'];//销售机会的数据范围和审批条件
        $datarangesql_Form35 = $this->datarangesqlArr['datarangesql_CustomForm35'];//目标管理的数据范围和审批条件

        $allstage = '潜在机会,未立项,立项准备,已立项,招投标,合同签订';
        $expectedstage = '潜在机会,未立项,立项准备,已立项,招投标';
        $orderstage = '合同签订';

        //组件按看板的设置信息
        $filterArr = $this->filterArr;
        $potential_isrelated = $filterArr['timecomponent_Potentials']['isrelated'];
        $potential_timefield = $filterArr['timecomponent_Potentials']['filtersfield'];
        $wheretimesql = '';
        if(!empty($potential_timefield)) {
            $wheretimekejiansql = " and " . $potential_timefield . " between '" . $dateinfo['yearstartdate'] . "' and '" . $dateinfo['yearenddate'] . "'";//可见合同金额的限制时间
            if ($potential_isrelated == 'yes') {
                $wheretimesql .= " and " . $potential_timefield . " between '" . $dateinfo['yearstartdate'] . "' and '" . $dateinfo['enddate'] . "'";
            }
        }

        $sql = "select 
stage.listvalue as stagename ,
ifnull(potential.countnum,0)as countnum,
ifnull(potential.sumtotal,0)as sumtotal,
ifnull(potential.kejian,0)as kejian,
ifnull(form35.targetamount,0)as targetamount,
(
    round( (case when stage.listvalue='$orderstage' then ifnull(form35.targetamount,0) - ifnull(potential.zhongbiao,0) else 0 end ), 0 )
) as quekou
from (
	select 
		b.listvalue ,b.sequence
	from ld_picklist_set a 
	left join ld_picklist_values b on a.listid=b.listid 
	where a.listname='sales_stage' and FIND_IN_SET(b.listvalue,'$allstage')
	order by b.sequence asc LIMIT 6 
)stage left join (
	select 
		count(1) as countnum,
		sum(ifnull(ld_potentialscf.cf_8183,0)) as sumtotal,
		0 as zhongbiao,
		ld_potential.sales_stage,
		sum(case when FIND_IN_SET(ld_potential.sales_stage,'$expectedstage')  then ifnull(ld_potentialscf.cf_8183,0)*ifnull(cf_8015,0) else 0 end)as kejian
	from ld_potential left join ld_potentialscf on ld_potential.potentialid=ld_potentialscf.potentialid
	$datarangesql_Potentials
	where ld_potential.deleted=0 $wheretimekejiansql
	and ld_potential.sales_stage <> '$orderstage'
	group by ld_potential.sales_stage
	union ALL	
	select 
		count(1) as countnum,
		sum(ifnull(ld_potentialscf.cf_8183,0)) as sumtotal,
		sum(ifnull(ld_potentialscf.cf_8314,0)) as zhongbiao,
		ld_potential.sales_stage,
		0 as kejian
	from ld_potential left join ld_potentialscf on ld_potential.potentialid=ld_potentialscf.potentialid
	$datarangesql_Potentials
	where ld_potential.deleted=0
	and ld_potential.sales_stage = '$orderstage' 
	
	$wheretimesql
	group by ld_potential.sales_stage
)potential on stage.listvalue=potential.sales_stage
left join (
	select 
	detailscf.sf815 as stagename,
	sum(ifnull(detailscf.sf734,0)) as targetamount
	from ld_customform35 
	left join ld_customform35scf form35scf on form35scf.customform35id=ld_customform35.customform35id
	left join ld_customform35detail detail on detail.id=ld_customform35.customform35id
	left join ld_customform35detailscf detailscf on detailscf.lineitem_id=detail.lineitem_id
	$datarangesql_Form35
	where form35scf.cf_8392=".$dateinfo['yearnum']."
	and detailscf.sf815 is not null and detailscf.sf815<>'$orderstage'
	and form35scf.cf_8534='营销经理'
	and form35scf.cf_8391='项目类'
	group by detailscf.sf815
	union all 
	select 
	detailscf.sf815 as stagename,
	sum(case when ".$dateinfo['monthnum']."=1 then detailscf.sf736
	when ".$dateinfo['monthnum']."=2 then (detailscf.sf736+detailscf.sf737)
	when ".$dateinfo['monthnum']."=3 then (detailscf.sf736+detailscf.sf737+detailscf.sf738)
	when ".$dateinfo['monthnum']."=4 then (detailscf.sf736+detailscf.sf737+detailscf.sf738+detailscf.sf739)
	when ".$dateinfo['monthnum']."=5 then (detailscf.sf736+detailscf.sf737+detailscf.sf738+detailscf.sf739+detailscf.sf740)
	when ".$dateinfo['monthnum']."=6 then (detailscf.sf736+detailscf.sf737+detailscf.sf738+detailscf.sf739+detailscf.sf740+detailscf.sf741)
	when ".$dateinfo['monthnum']."=7 then (detailscf.sf736+detailscf.sf737+detailscf.sf738+detailscf.sf739+detailscf.sf740+detailscf.sf741+detailscf.sf742)
	when ".$dateinfo['monthnum']."=8 then (detailscf.sf736+detailscf.sf737+detailscf.sf738+detailscf.sf739+detailscf.sf740+detailscf.sf741+detailscf.sf742+detailscf.sf743)
	when ".$dateinfo['monthnum']."=9 then (detailscf.sf736+detailscf.sf737+detailscf.sf738+detailscf.sf739+detailscf.sf740+detailscf.sf741+detailscf.sf742+detailscf.sf743+detailscf.sf744)
	when ".$dateinfo['monthnum']."=10 then (detailscf.sf736+detailscf.sf737+detailscf.sf738+detailscf.sf739+detailscf.sf740+detailscf.sf741+detailscf.sf742+detailscf.sf743+detailscf.sf744+detailscf.sf745)
	when ".$dateinfo['monthnum']."=11 then (detailscf.sf736+detailscf.sf737+detailscf.sf738+detailscf.sf739+detailscf.sf740+detailscf.sf741+detailscf.sf742+detailscf.sf743+detailscf.sf744+detailscf.sf745+detailscf.sf746)
	when ".$dateinfo['monthnum']."=12 then (detailscf.sf736+detailscf.sf737+detailscf.sf738+detailscf.sf739+detailscf.sf740+detailscf.sf741+detailscf.sf742+detailscf.sf743+detailscf.sf744+detailscf.sf745+detailscf.sf746+detailscf.sf747)
	else 0 end)as targetamount
	from ld_customform35 
	left join ld_customform35scf form35scf on form35scf.customform35id=ld_customform35.customform35id
	left join ld_customform35detail detail on detail.id=ld_customform35.customform35id
	left join ld_customform35detailscf detailscf on detailscf.lineitem_id=detail.lineitem_id
	$datarangesql_Form35
	where form35scf.cf_8392=".$dateinfo['yearnum']." and detailscf.sf815 is not null and detailscf.sf815='$orderstage'
	and form35scf.cf_8534='营销经理'
	and form35scf.cf_8391='项目类'
	group by detailscf.sf815
	
)form35 on stage.listvalue=form35.stagename
order by stage.sequence asc";

        $res = $adb->pquery($sql);
        $nums = $adb->num_rows($res);

        $result = [
            'total'=>"0.00",
            'totalnum'=>"0",
            'kejian'=>"0.00",
            'quekou'=>"0.00",
        ];
        if($nums>0) {
            $list = $adb->query_result_all($res);
            //edit: xll BUG20240116-08 不保留小数位数
            $system_deploy_351 = 0;
            foreach ($list as $k => &$line) {
                $result['total'] += $line['sumtotal'];
                $result['totalnum'] += $line['countnum'];
                $result['kejian'] += $line['kejian'];
                $result['quekou'] += $line['quekou'];

                $line['sumtotal'] = round($line['sumtotal'] / 10000, $system_deploy_351);
                $line['sumtotal2'] = 0 - $line['sumtotal'];
                $line['targetamount'] = round($line['targetamount'] / 10000, 0);
                $line['targetamount2'] = 0 - $line['targetamount'];

                $line['dacheng_rate'] = empty($line['targetamount']) ? 0 : $line['sumtotal'] * 100 / $line['targetamount'];
                $line['dacheng_rate_str'] = number_format($line['dacheng_rate'], 2) . '%';

                //countnum sumtotal targetamount--千分位格式化的数据
                $line['countnum_str'] = number_format($line['countnum'], $system_deploy_351);
                $line['sumtotal_str'] = number_format($line['sumtotal'], $system_deploy_351);
                $line['targetamount_str'] = number_format($line['targetamount'], $system_deploy_351);
            }
            $list[] = $list[5];// BUG20240618-15 1、销售漏斗显示方式优化（六个阶段匹配六个区块，数据显示在区块中。示例：25亿 / 招投标 / 40亿 / 58%
            $list = array_reverse($list);
            $result['list'] = $list;
            $result['rate_arr'] = (_array_column($list, 'dacheng_rate_str'));
            $result['rate_arr'][0] = '';// BUG20240618-15 1、销售漏斗显示方式优化（六个阶段匹配六个区块，数据显示在区块中。示例：25亿 / 招投标 / 40亿 / 58%

            $result['seriesdata1'] = (_array_column($list, 'targetamount'));
            $result['seriesdata2'] = (_array_column($list, 'targetamount2'));
            $result['seriesdata3'] = (_array_column($list, 'sumtotal'));
            $result['seriesdata4'] = (_array_column($list, 'sumtotal2'));

            $result['legend_arr'] = (_array_column($list, 'stagename'));
            $result['legend_arr'][0] = '';// BUG20240618-15 1、销售漏斗显示方式优化（六个阶段匹配六个区块，数据显示在区块中。示例：25亿 / 招投标 / 40亿 / 58%

            $result['fieldlabellist'] = [
                'unit' => $languageType == 'zh' ? '万' : 'w',
                'QUANTITY' => getFixedLabel('QUANTITY'),
                'Estimatedprojectamount' => getFixedLabel('Estimatedprojectamount'),
                'TOLOOKVALUE' => getFixedLabel('TOLOOKVALUE'),
            ];
            $result['total'] = number_format($result['total'] / 10000, $system_deploy_351);
            $result['kejian'] = number_format($result['kejian'] / 10000, $system_deploy_351);
            $result['quekou'] = number_format($result['quekou'] / 10000, $system_deploy_351);
        }
        return $result;
    }

    public function getDateInfo($search_date){
        $yearnum = '2023';//年份
        $yearstartdate = '2023-01-01';//年度开始日期
        $enddate = '2023-12-14';//求目标的截至日期
        $monthnum = date('m');
        $date = date('Y-m-d');
        /*return [
            'yearnum'=>$yearnum,
            'yearstartdate'=>$yearstartdate,
            'enddate'=>$enddate,
            'monthnum'=>$monthnum,
            'date'=>$date
        ];*/
        switch($search_date){
            case 'thistoday':	//今日
            case 'today'://手机daunt
                $yearnum = date('Y');
                $yearstartdate = date('Y-01-01');
                $enddate = date('Y-m-d');
                $monthnum = date('m');
                $date = date('Y-m-d');
                break;
            case 'yestoday':	//昨日
            case 'syesterday'://手机daunt
                $yearnum = date('Y',strtotime("-1 day"));
                $yearstartdate = date('Y-01-01',strtotime("-1 day"));
                $enddate = date('Y-m-d',strtotime("-1 day"));
                $monthnum = date('m',strtotime("-1 day"));
                $date = date('Y-m-d',strtotime("-1 day"));
                break;
            case 'thisweek':	//本周
                $endtimestamp = (time() + (7 - (date('w') == 0 ? 7 : date('w'))) * 24 * 3600);

                $yearnum = date('Y',$endtimestamp);
                $yearstartdate = date('Y-01-01',$endtimestamp);
                $enddate = date('Y-m-d',$endtimestamp);
                $monthnum = date('m',$endtimestamp);
                $date = date('Y-m-d',$endtimestamp);
                break;
            case 'lastweek':
                $date = date("Y-m-d");  //当前日期
                $first=1;     //$first =1 表示每周星期一为开始时间 0表示每周日为开始时间
                $w = date("w", strtotime($date));  //获取当前周的第几天 周日是 0 周一 到周六是 1 -6
                $d = $w ? $w - $first : 6;  //如果是周日 -6天
                $nowdate  = date("Y-m-d 00:00:00", strtotime("$date -".$d." days"));
                $nowStart  = date("Y-m-d 00:00:00", strtotime("$nowdate - 7 days")); //上周开始时间
                $endtimestamp = strtotime("$nowStart +6 days");

                $yearnum = date('Y',$endtimestamp);
                $yearstartdate = date('Y-01-01',$endtimestamp);
                $enddate = date('Y-m-d',$endtimestamp);
                $monthnum = date('m',$endtimestamp);
                $date = date('Y-m-d',$endtimestamp);
                break;
            case 'thismonth':	//本月
            case 'month':
                $yearnum = date('Y');
                $yearstartdate = date('Y-01-01');
                $enddate = date('Y-m-d');
                $monthnum = date('m');
                $date = date('Y-m-d');
                break;
            case 'lastmonth':	//上月
                $timestamp=strtotime(date('Y-m-d H:i:s'));
                $endtimestamp = strtotime(date('Y',$timestamp).'-'.(date('m',$timestamp)-1));
                $yearnum = date('Y',$endtimestamp);
                $yearstartdate = date('Y-01-01',$endtimestamp);
                $enddate = date('Y-12-31',$endtimestamp);
                $monthnum = date('m',$endtimestamp);
                $date = date('Y-m-d',$endtimestamp);
                break;
            case 'nextmonth':	//下月
                $timestamp=strtotime(date('Y-m-d H:i:s'));
                $endtimestamp = strtotime(date('Y',$timestamp).'-'.(date('m',$timestamp)+1));
                $yearnum = date('Y',$endtimestamp);
                $yearstartdate = date('Y-01-01',$endtimestamp);
                $enddate = date('Y-12-31',$endtimestamp);
                $monthnum = date('m',$endtimestamp);
                $date = date('Y-m-d',$endtimestamp);
                break;
            case 'thisyear':	//本年度
            case 'year':
            case 'thisfy'://手机端
                $yearnum = date('Y');
                $yearstartdate = date('Y-01-01');
                $enddate = date('Y-12-31');
                $monthnum = '12';
                $date = date('Y-12-31');
                break;
            case 'lastyear':	//上年度
            case 'prevfy'://手机端
                $endtimestamp = strtotime("-1 year");
                $yearnum = date('Y',$endtimestamp);
                $yearstartdate = date('Y-01-01',$endtimestamp);
                $enddate = date('Y-12-31',$endtimestamp);
                $monthnum = '12';
                $date = date('Y-12-31',$endtimestamp);
                break;
            case 'thisquarter':	//本季度
            case 'quarter':
            case 'thisfq'://手机daunt
                $season = ceil((date('n'))/3);
                $endtimestamp = mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y'));
                $yearnum = date('Y',$endtimestamp);
                $yearstartdate = date('Y-01-01',$endtimestamp);
                $enddate = date('Y-m-d',$endtimestamp);
                $monthnum = date('m',$endtimestamp);
                $date = date('Y-m-d',$endtimestamp);
                break;
            case 'lastquarter':	//上季度
            case 'prevfq'://手机端
                $season = ceil((date('n'))/3)-1;
                $endtimestamp = mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y'));
                $yearnum = date('Y',$endtimestamp);
                $yearstartdate = date('Y-01-01',$endtimestamp);
                $enddate = date('Y-m-d',$endtimestamp);
                $monthnum = date('m',$endtimestamp);
                $date = date('Y-m-d',$endtimestamp);
                break;
            case 'all':
                break;
            default:
                $date = explode('~',$search_date);
                if(sizeof($date) > 1){
                    $endtimestamp = strtotime($date[1].' 23:59:59');
                    $yearnum = date('Y',$endtimestamp);
                    $yearstartdate = date('Y-01-01',$endtimestamp);
                    $enddate = date('Y-m-d',$endtimestamp);
                    $monthnum = date('m',$endtimestamp);
                    $date = date('Y-m-d',$endtimestamp);
                }

        }
        return [
            'yearnum'=>$yearnum,
            'yearstartdate'=>$yearstartdate,
            'yearenddate'=>date('Y-12-31',strtotime($yearstartdate)),
            'enddate'=>$enddate,
            'monthnum'=>$monthnum,
            'date'=>$date
        ];
    }
}
?>