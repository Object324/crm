<?php
//报表工具类
class ReportAnalysisUtils{
    //自定义统计图  环比条件 根据groupbytype获取环比数据总的条件  curTimeRange本期时间区间
    public static function getHuanbiTimeRange($groupbytype,$curTimeRange){
        crm_load_class_file('DateOperation','include');
        //环比上期时间
        $prevTimeRange = [];
        if($groupbytype=='byYear'){
            $prevTimeRange[0] = DateOperation::addMonths($curTimeRange[0],-12);
            $prevTimeRange[1] = DateOperation::addMonths($curTimeRange[1],-12);
        }else if($groupbytype=='byQuarter'){
            $prevTimeRange[0] = DateOperation::addMonths($curTimeRange[0],-3);
            $prevTimeRange[1] = DateOperation::addMonths($curTimeRange[1],-3);
        }else if($groupbytype=='byMonth'){
            $prevTimeRange[0] = DateOperation::addMonths($curTimeRange[0],-1);
            $prevTimeRange[1] = DateOperation::addMonths($curTimeRange[1],-1);
        }else if($groupbytype=='byWeek'){
            $prevTimeRange[0] = DateOperation::addDays($curTimeRange[0],-7);
            $prevTimeRange[1] = DateOperation::addDays($curTimeRange[1],-7);
        }else if($groupbytype=='byDay'){
            $prevTimeRange[0] = DateOperation::addDays($curTimeRange[0],-1);
            $prevTimeRange[1] = DateOperation::addDays($curTimeRange[1],-1);
        }
        return $prevTimeRange;
    }
    //自定义统计图 同比条件 跟分组类型无关
    public static function getTongbiTimeRange($curTimeRange){
        crm_load_class_file('DateOperation','include');
        $prev_lastyearTimeRange = [];
        $prev_lastyearTimeRange[0] = DateOperation::addMonths($curTimeRange[0],-12);
        $prev_lastyearTimeRange[1] = DateOperation::addMonths($curTimeRange[1],-12);
        return $prev_lastyearTimeRange;
    }
    //SQL统计图 SQL统计表 审批组件值的替换
    public static function getSqlReportApprovedValue($approve_value){
        $approve_value_zh = '';
        if (!empty($approve_value)) {
            if ($approve_value == 'all' || strpos($approve_value, 'all') !== false) {
                //$query = ' and ifnull('.$tablename.'.approvestatus,"") != \''.D_A_S_REJECTED.'\' ';
                //zxm 审批状态条件以设置为准,用户在界面勾选什么就判断什么
                $approve_value_zh = D_A_S_UNAPPROVED.','.D_A_S_APPROVALOF.','.D_A_S_APPROVED.','.D_A_S_REJECTED.','.D_A_S_DISMISSED;
            } else {
                $approve_value_zh = $approve_value;
                $approve_value_zh = str_replace("unapproved", D_A_S_UNAPPROVED, $approve_value_zh);
                $approve_value_zh = str_replace("approving", D_A_S_APPROVALOF, $approve_value_zh);
                $approve_value_zh = str_replace("approved", D_A_S_APPROVED, $approve_value_zh);
                $approve_value_zh = str_replace("rejected", D_A_S_REJECTED, $approve_value_zh);
                $approve_value_zh = str_replace("dismissed", D_A_S_DISMISSED, $approve_value_zh);
            }
        }
        return trim($approve_value_zh);
    }
    //非管理员 人员条件子SQL 默认是主模块 首页看板设置了就按设置的控制  自定义统计图 自定义统计表都要使用  拿过来做公共的方法
    /**
     * @param $smowneridjoinField  string //负责人字段  栗子:ld_account.smownerid
     * @param $module string 模块 栗子:Accounts
     * @param $selectuid string 人员ID 栗子:1,2,3,4
     * @return string
     */
    public static function getUserIdSql($smowneridjoinField,$module,$selectuid){
        //数据范围
        global $current_user;
        if(is_admin($current_user)){
            return '';
        }
        $currUserid = $current_user->id;
        $where = '';
        if(!empty($selectuid)){
            //首页传过来的人员范围
            $where = " where find_in_set(userid,'$selectuid')";
        }
        //0049528: （苏州凡图）http://110.40.187.151:85/crm/ [^]，财务管理——客户收款统计，这个报表是用自定义统计表做的一个简单报表，给普通销售数据范围设置只能看到自己的数据，但他们还是能看到全部的数据，除此之外还有别的问题，详情见说明
        $datarangeSql = " INNER JOIN (
                SELECT DISTINCT
                    userid 
                FROM (
                    SELECT 
                        ld_users.id AS userid 
                    FROM ld_users
                    WHERE EXISTS(SELECT 1 FROM ld_setscoperhigher WHERE modulename='$module' and scopeauthority=1 AND userid=$currUserid)
                    UNION
                    SELECT 
                        viewid AS userid 
                    FROM ld_scoperhigher
                    WHERE userid=$currUserid AND modulename='$module' AND EXISTS(SELECT 1 FROM ld_setscoperhigher WHERE userid=$currUserid AND scopeauthority=2 AND modulename='$module')			
                    UNION
                    SELECT DISTINCT 
                        ld_users2group.userid AS userid 
                    FROM ld_scoperhigher 
                    INNER JOIN ld_groups ON ld_groups.groupid=ld_scoperhigher.viewid
                    INNER JOIN ld_users2group ON ld_users2group.groupid=ld_groups.groupid
                    WHERE ld_scoperhigher.userid=$currUserid 
                        AND ld_scoperhigher.modulename='$module'
                        AND ld_scoperhigher.scopeauthority=3 
                        AND EXISTS(SELECT 1 FROM ld_setscoperhigher WHERE modulename='$module' AND scopeauthority=3 AND userid=$currUserid)
                    UNION 
                    SELECT 
                        id AS userid 
                    FROM ld_users  
                    WHERE EXISTS(SELECT 1 FROM ld_users WHERE id=$currUserid AND is_admin='on')
                    UNION
                    SELECT $currUserid) AS vw_users $where
            ) AS tmp_users ON tmp_users.userid=$smowneridjoinField";
        return $datarangeSql;
    }

    /**
     * @param $timename string SQL统计图 SQL统计表 时间变量默认值设置
     * @return void
     */
    public static function getFilterDefaultValue($timename){
        if (date("m") <= 3) {
            $cFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
            $cFq1 = date("Y-m-d", mktime(0, 0, 0, "03", "31", date("Y")));
            $nFq = date("Y-m-d", mktime(0, 0, 0, "04", "01", date("Y")));
            $nFq1 = date("Y-m-d", mktime(0, 0, 0, "06", "30", date("Y")));
            $pFq = date("Y-m-d", mktime(0, 0, 0, "10", "01", date("Y") - 1));
            $pFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y") - 1));
        } else if (date("m") >= 4 and date("m") <= 6) {
            $pFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
            $pFq1 = date("Y-m-d", mktime(0, 0, 0, "03", "31", date("Y")));
            $cFq = date("Y-m-d", mktime(0, 0, 0, "04", "01", date("Y")));
            $cFq1 = date("Y-m-d", mktime(0, 0, 0, "06", "30", date("Y")));
            $nFq = date("Y-m-d", mktime(0, 0, 0, "07", "01", date("Y")));
            $nFq1 = date("Y-m-d", mktime(0, 0, 0, "09", "30", date("Y")));
        }else if (date("m") >=7 and date("m") <= 9) {
            $pFq = date("Y-m-d", mktime(0, 0, 0, "04", "01", date("Y")));
            $pFq1 = date("Y-m-d", mktime(0, 0, 0, "06", "30", date("Y")));
            $cFq = date("Y-m-d", mktime(0, 0, 0, "07", "01", date("Y")));
            $cFq1 = date("Y-m-d", mktime(0, 0, 0, "09", "30", date("Y")));
            $nFq = date("Y-m-d", mktime(0, 0, 0, "10", "01", date("Y")));
            $nFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y")));
        } else {
            $nFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y") + 1));
            $nFq1 = date("Y-m-d", mktime(0, 0, 0, "03", "31", date("Y") + 1));
            $pFq = date("Y-m-d", mktime(0, 0, 0, "07", "01", date("Y")));
            $pFq1 = date("Y-m-d", mktime(0, 0, 0, "09", "30", date("Y")));
            $cFq = date("Y-m-d", mktime(0, 0, 0, "10", "01", date("Y")));
            $cFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y")));
        }
        $arr = [
            'todaystart'=>date('Y-m-d 00:00:00'),
            'todayend'=>date('Y-m-d 23:59:59'),
            'tomorrowstart'=>date('Y-m-d 00:00:00',strtotime("+1 day")),
            'tomorrowend'=>date('Y-m-d 23:59:59',strtotime("+1 day")),
            'yesterdaystart'=>date('Y-m-d 00:00:00',strtotime("-1 day")),
            'yesterdayend'=>date('Y-m-d 23:59:59',strtotime("-1 day")),
            'thismonthstart'=>date('Y-m-01 00:00:00'),
            'thismonthend'=>date('Y-m-d 23:59:59',strtotime(date('Y-m-01')." -1 day +1 month")),
            'lastmonthstart'=>date('Y-m-01 00:00:00',strtotime('-1 month')),
            'lastmonthend'=>date('Y-m-d 23:59:59',strtotime(date('Y-m-01')." -1 day")),
            'nextmonthstart'=>date('Y-m-01 00:00:00',strtotime("+1 month")),
            'nextmonthend'=>date('Y-m-d 23:59:59',strtotime(date('Y-m-01')." -1 day +2 month")),
            'thisquarterstart'=>$cFq.' 00:00:00',
            'thisquarterend'=>$cFq1.' 23:59:59',
            'lastquarterstart'=>$pFq.' 00:00:00',
            'lastquarterend'=>$pFq1.' 23:59:59',
            'nextquarterstart'=>$nFq.' 00:00:00',
            'nextquarterend'=>$nFq1.' 23:59:59',
            'thisyearstart'=>date('Y-01-01 00:00:00'),
            'thisyearend'=>date('Y-12-31 23:59:59'),
            'lastyearstart'=>date('Y-01-01 00:00:00',strtotime('-1 year')),
            'lastyearend'=>date('Y-12-31 23:59:59',strtotime('-1 year')),
            'nextyearstart'=>date('Y-01-01 00:00:00',strtotime('+1 year')),
            'nextyearend'=>date('Y-12-31 23:59:59',strtotime('+1 year'))
        ];
        return $arr[$timename];
    }
    //获取条件值
    public function getComparatorValue(){
        $currTime = date('Y-m-d H:i:s');
        $todayStart = date('Y-m-d 00:00:00');
        $todayEnd = date('Y-m-d 23:59:59');
        $lastdays0 = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d")-1, date("Y")));
        $nextdays0 = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d")+1, date("Y")));

        $sdefaultDate = date("Y-m-d");
        $first=1;
        $w=date('w',strtotime($sdefaultDate));
        $lastweek0=date('Y-m-d',strtotime("$sdefaultDate -".(($w ? $w - $first : 6)+7).' days'));
        $lastweek1=date('Y-m-d',strtotime("$lastweek0 +6 days"));

        $thisweek0=date('Y-m-d',strtotime("$sdefaultDate -".(($w ? $w - $first : 6)).' days'));
        $thisweek1=date('Y-m-d',strtotime("$thisweek0 +6 days"));

        $nextweek0=date('Y-m-d',strtotime("$sdefaultDate -".(($w ? $w - $first : 6)-7).' days'));
        $nextweek1=date('Y-m-d',strtotime("$nextweek0 +6 days"));

        /* $lastweek0 = date("Y-m-d", strtotime("-1 week Monday"));
         $lastweek1 = date("Y-m-d", strtotime("-1 week Sunday"));
         $thisweek0 = date("Y-m-d", strtotime("0 week Monday"));
         $thisweek1 = date("Y-m-d", strtotime("this Sunday"));
         $nextweek0 = date("Y-m-d", strtotime("+1 week Monday"));
         $nextweek1 = date("Y-m-d", strtotime("+1 week Sunday"));*/
        //wyt 220819 XUQIU1000506 自定义报表或图表的日期条件优化
        $defaultStartDate='1960-01-01';
        $defaultEndDate='9999-12-31';
        $before1days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 1, date("Y")));
        $before2days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 2, date("Y")));
        $before3days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 3, date("Y")));
        $before4days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 4, date("Y")));
        $before5days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 5, date("Y")));
        $before6days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 6, date("Y")));
        $before7days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 7, date("Y")));
        $before8days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 8, date("Y")));
        $before9days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 9, date("Y")));
        $before10days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 10, date("Y")));
        $before11days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 11, date("Y")));
        $before12days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 12, date("Y")));
        $before13days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 13, date("Y")));
        $before14days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 14, date("Y")));
        $before15days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 15, date("Y")));
        $before30days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 30, date("Y")));
        $before60days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 60, date("Y")));
        $before90days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 90, date("Y")));
        $before120days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 120, date("Y")));
        $before180days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 180, date("Y")));
        $before365days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 365, date("Y")));

        $last1days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 1, date("Y")));
        $last2days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 2, date("Y")));
        $last3days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 3, date("Y")));
        $last4days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 4, date("Y")));
        $last5days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 5, date("Y")));
        $last6days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 6, date("Y")));
        $last7days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 7, date("Y")));
        $last8days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 8, date("Y")));
        $last9days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 9, date("Y")));
        $last10days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 10, date("Y")));
        $last11days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 11, date("Y")));
        $last12days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 12, date("Y")));
        $last13days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 13, date("Y")));
        $last14days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 14, date("Y")));
        $last15days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 15, date("Y")));
        $last30days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 30, date("Y")));
        $last60days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 60, date("Y")));
        $last90days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 90, date("Y")));
        $last120days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 120, date("Y")));
        $last180days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 180, date("Y")));
        $last365days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 365, date("Y")));

        $next1days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 1, date("Y")));
        $next2days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 2, date("Y")));
        $next3days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 3, date("Y")));
        $next4days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 4, date("Y")));
        $next5days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 5, date("Y")));
        $next6days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 6, date("Y")));
        $next7days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 7, date("Y")));
        $next8days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 8, date("Y")));
        $next9days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 9, date("Y")));
        $next10days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 10, date("Y")));
        $next11days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 11, date("Y")));
        $next12days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 12, date("Y")));
        $next13days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 13, date("Y")));
        $next14days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 14, date("Y")));
        $next15days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 15, date("Y")));
        $next30days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 30, date("Y")));
        $next60days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 60, date("Y")));
        $next90days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 90, date("Y")));
        $next120days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 120, date("Y")));
        $next180days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 180, date("Y")));
        $next365days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 365, date("Y")));

        $after1days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 1, date("Y")));
        $after2days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 2, date("Y")));
        $after3days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 3, date("Y")));
        $after4days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 4, date("Y")));
        $after5days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 5, date("Y")));
        $after6days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 6, date("Y")));
        $after7days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 7, date("Y")));
        $after8days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 8, date("Y")));
        $after9days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 9, date("Y")));
        $after10days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 10, date("Y")));
        $after11days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 11, date("Y")));
        $after12ays  = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 12, date("Y")));
        $after13days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 13, date("Y")));
        $after14days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 14, date("Y")));
        $after15days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 15, date("Y")));
        $after30days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 30, date("Y")));
        $after60days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 60, date("Y")));
        $after90days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 90, date("Y")));
        $after120days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 120, date("Y")));
        $after180days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 180, date("Y")));
        $after365days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 365, date("Y")));

        if (date("m") <= 3) {
            $cFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
            $cFq1 = date("Y-m-d", mktime(0, 0, 0, "03", "31", date("Y")));
            $nFq = date("Y-m-d", mktime(0, 0, 0, "04", "01", date("Y")));
            $nFq1 = date("Y-m-d", mktime(0, 0, 0, "06", "30", date("Y")));
            $pFq = date("Y-m-d", mktime(0, 0, 0, "10", "01", date("Y") - 1));
            $pFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y") - 1));
        } else if (date("m") >= 4 and date("m") <= 6) {
            $pFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
            $pFq1 = date("Y-m-d", mktime(0, 0, 0, "03", "31", date("Y")));
            $cFq = date("Y-m-d", mktime(0, 0, 0, "04", "01", date("Y")));
            $cFq1 = date("Y-m-d", mktime(0, 0, 0, "06", "30", date("Y")));
            $nFq = date("Y-m-d", mktime(0, 0, 0, "07", "01", date("Y")));
            $nFq1 = date("Y-m-d", mktime(0, 0, 0, "09", "30", date("Y")));
        }else if (date("m") >=7 and date("m") <= 9) {
            $pFq = date("Y-m-d", mktime(0, 0, 0, "04", "01", date("Y")));
            $pFq1 = date("Y-m-d", mktime(0, 0, 0, "06", "30", date("Y")));
            $cFq = date("Y-m-d", mktime(0, 0, 0, "07", "01", date("Y")));
            $cFq1 = date("Y-m-d", mktime(0, 0, 0, "09", "30", date("Y")));
            $nFq = date("Y-m-d", mktime(0, 0, 0, "10", "01", date("Y")));
            $nFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y")));
        } else {
            $nFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y") + 1));
            $nFq1 = date("Y-m-d", mktime(0, 0, 0, "03", "31", date("Y") + 1));
            $pFq = date("Y-m-d", mktime(0, 0, 0, "07", "01", date("Y")));
            $pFq1 = date("Y-m-d", mktime(0, 0, 0, "09", "30", date("Y")));
            $cFq = date("Y-m-d", mktime(0, 0, 0, "10", "01", date("Y")));
            $cFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y")));
        }
        $time_arr = [
            "isnull"=>['',''],
            "isnotnull"=>['',''],
            "bw"=>[$todayStart,$todayEnd],//时间内区间
            "l"=>[$currTime,''],//小于
            "n"=>[$currTime,''],//不等于
            "e"=>[$currTime,''],//等于
            "g"=>[$currTime,''],//大于
            "m"=>[$currTime,''],//小于等于
            "h"=>[$currTime,''],//大于等于
            "today"=>[$todayStart,$todayEnd],
            "syesterday"=>[date('Y-m-d 00:00:00',strtotime("-1 day")),date('Y-m-d 23:59:59',strtotime("-1 day"))],//昨天
            "tomorrow"=>[date('Y-m-d 00:00:00',strtotime("+1 day")),date('Y-m-d 23:59:59',strtotime("+1 day"))],//明天
            "thisweek"=>[$thisweek0.' 00:00:00',$thisweek1.' 23:59:59'],
            "lastweek"=>[$lastweek0.' 00:00:00',$lastweek1.' 23:59:59'],
            "nextweek"=>[$nextweek0.' 00:00:00',$nextweek1.' 23:59:59'],
            "thisfq"=>[$cFq.' 00:00:00',$cFq1.' 23:59:59'],
            "prevfq"=>[$pFq.' 00:00:00',$pFq1.' 23:59:59'],
            "nextfq"=>[$nFq.' 00:00:00',$nFq1.' 23:59:59'],
            "thismonth"=>[date('Y-m-01 00:00:00'),date('Y-m-d 23:59:59',strtotime(date('Y-m-01')." -1 day +1 month"))],//本月
            "lastmonth"=>[date('Y-m-01 00:00:00',strtotime('-1 month')),date('Y-m-d 23:59:59',strtotime(date('Y-m-01')." -1 day"))],//上个月
            "nextmonth"=>[date('Y-m-01 00:00:00',strtotime("+1 month")),date('Y-m-d 23:59:59',strtotime(date('Y-m-01')." -1 day +2 month"))],//下个月
            "thisfy"=>[date('Y-01-01 00:00:00'),date('Y-12-31 23:59:59')],//本年
            "prevfy"=>[date('Y-01-01 00:00:00',strtotime('-1 year')),date('Y-12-31 23:59:59',strtotime('-1 year'))],//今年
            "nextfy"=>[date('Y-01-01 00:00:00',strtotime('+1 year')),date('Y-12-31 23:59:59',strtotime('+1 year'))],//明年
            "before1days"=>[$defaultStartDate.' 00:00:00',$before1days.' 23:59:59'],//一天前
            "before2days"=>[$defaultStartDate.' 00:00:00',$before2days.' 23:59:59'],//两天前
            "before3days"=>[$defaultStartDate.' 00:00:00',$before3days.' 23:59:59'],
            "before4days"=>[$defaultStartDate.' 00:00:00',$before4days.' 23:59:59'],
            "before5days"=>[$defaultStartDate.' 00:00:00',$before5days.' 23:59:59'],
            "before6days"=>[$defaultStartDate.' 00:00:00',$before6days.' 23:59:59'],
            "before7days"=>[$defaultStartDate.' 00:00:00',$before7days.' 23:59:59'],
            "before8days"=>[$defaultStartDate.' 00:00:00',$before8days.' 23:59:59'],
            "before9days"=>[$defaultStartDate.' 00:00:00',$before9days.' 23:59:59'],
            "before10days"=>[$defaultStartDate.' 00:00:00',$before10days.' 23:59:59'],
            "before11days"=>[$defaultStartDate.' 00:00:00',$before11days.' 23:59:59'],
            "before12days"=>[$defaultStartDate.' 00:00:00',$before12days.' 23:59:59'],
            "before13days"=>[$defaultStartDate.' 00:00:00',$before13days.' 23:59:59'],
            "before14days"=>[$defaultStartDate.' 00:00:00',$before14days.' 23:59:59'],
            "before15days"=>[$defaultStartDate.' 00:00:00',$before15days.' 23:59:59'],
            "before30days"=>[$defaultStartDate.' 00:00:00',$before30days.' 23:59:59'],
            "before60days"=>[$defaultStartDate.' 00:00:00',$before60days.' 23:59:59'],
            "before90days"=>[$defaultStartDate.' 00:00:00',$before90days.' 23:59:59'],
            "before120days"=>[$defaultStartDate.' 00:00:00',$before120days.' 23:59:59'],
            "before180days"=>[$defaultStartDate.' 00:00:00',$before180days.' 23:59:59'],
            "before365days"=>[$defaultStartDate.' 00:00:00',$before365days.' 23:59:59'],

            "last1days"=>[$last1days.' 00:00:00',$lastdays0.' 23:59:59'],//过去一天
            "last2days"=>[$last2days.' 00:00:00',$lastdays0.' 23:59:59'],//过去两天
            "last3days"=>[$last3days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last4days"=>[$last4days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last5days"=>[$last5days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last6days"=>[$last6days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last7days"=>[$last7days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last8days"=>[$last8days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last9days"=>[$last9days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last10days"=>[$last10days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last11days"=>[$last11days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last12days"=>[$last12days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last13days"=>[$last13days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last14days"=>[$last14days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last15days"=>[$last15days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last30days"=>[$last30days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last60days"=>[$last60days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last90days"=>[$last90days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last120days"=>[$last120days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last180days"=>[$last180days.' 00:00:00',$lastdays0.' 23:59:59'],
            "last365days"=>[$last365days.' 00:00:00',$lastdays0.' 23:59:59'],

            "next1days"=>[$nextdays0.' 00:00:00',$next1days.' 23:59:59'],//未来一天
            "next2days"=>[$nextdays0.' 00:00:00',$next2days.' 23:59:59'],//未来两天
            "next3days"=>[$nextdays0.' 00:00:00',$next3days.' 23:59:59'],
            "next4days"=>[$nextdays0.' 00:00:00',$next4days.' 23:59:59'],
            "next5days"=>[$nextdays0.' 00:00:00',$next5days.' 23:59:59'],
            "next6days"=>[$nextdays0.' 00:00:00',$next6days.' 23:59:59'],
            "next7days"=>[$nextdays0.' 00:00:00',$next7days.' 23:59:59'],
            "next8days"=>[$nextdays0.' 00:00:00',$next8days.' 23:59:59'],
            "next9days"=>[$nextdays0.' 00:00:00',$next9days.' 23:59:59'],
            "next10days"=>[$nextdays0.' 00:00:00',$next10days.' 23:59:59'],
            "next11days"=>[$nextdays0.' 00:00:00',$next11days.' 23:59:59'],
            "next12days"=>[$nextdays0.' 00:00:00',$next12days.' 23:59:59'],
            "next13days"=>[$nextdays0.' 00:00:00',$next13days.' 23:59:59'],
            "next14days"=>[$nextdays0.' 00:00:00',$next14days.' 23:59:59'],
            "next15days"=>[$nextdays0.' 00:00:00',$next15days.' 23:59:59'],
            "next30days"=>[$nextdays0.' 00:00:00',$next30days.' 23:59:59'],
            "next60days"=>[$nextdays0.' 00:00:00',$next60days.' 23:59:59'],
            "next90days"=>[$nextdays0.' 00:00:00',$next90days.' 23:59:59'],
            "next120days"=>[$nextdays0.' 00:00:00',$next120days.' 23:59:59'],
            "next180days"=>[$nextdays0.' 00:00:00',$next180days.' 23:59:59'],
            "next365days"=>[$nextdays0.' 00:00:00',$next365days.' 23:59:59'],

            "after1days"=>[$after1days.' 00:00:00',$defaultEndDate.' 23:59:59'],//一天后
            "after2days"=>[$after2days.' 00:00:00',$defaultEndDate.' 23:59:59'],//两天后
            "after3days"=>[$after3days.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after4days"=>[$after4days.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after5days"=>[$after5days.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after6days"=>[$after6days.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after7days"=>[$after7days.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after8days"=>[$after8days.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after9days"=>[$after9days.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after10days"=>[$after10days.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after11days"=>[$after11days.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after12days"=>[$after12ays.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after13days"=>[$after13days.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after14days"=>[$after14days.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after15days"=>[$after15days.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after30days"=>[$after30days.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after60days"=>[$after60days.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after90days"=>[$after90days.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after120days"=>[$after120days.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after180days"=>[$after180days.' 00:00:00',$defaultEndDate.' 23:59:59'],
            "after365days"=>[$after365days.' 00:00:00',$defaultEndDate.' 23:59:59'],

        ];
        return $time_arr;
    }
}