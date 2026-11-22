<?php

class CustomMadeUtils
{
    /**
     * @param $approve_status
     * @return string
     * zxm
     * 2020-1204
     * 获取审批状态的中文名字
     */
    public static function getApproveStatusName($approve_status){
        switch ($approve_status) {
            case 'unapproved':    //未提交
                $approve_name = D_A_S_UNAPPROVED;
                break;
            case 'approving':    //审批中
                $approve_name = D_A_S_APPROVALOF;
                break;
            case 'approved':    //审批通过
                $approve_name = D_A_S_APPROVED;
                break;
            case 'rejected':    //已拒绝
                $approve_name = D_A_S_REJECTED;
                break;
            case 'dismissed':    //已驳回
                $approve_name = D_A_S_DISMISSED;
                break;
            default:
                $approve_name = "";
                break;
        }
        return $approve_name;
    }

    public function getApproveQuery($tablename){
        //@edit:liushuai,2021-02-24,reason:【ID1001362】首页-审批状态可多选查看（四方光电）
        if(!empty($_REQUEST['approve_value'])){
            if($_REQUEST['approve_value'] == 'all' || strpos($_REQUEST['approve_value'],'all') !== false){
                $query = ' and ifnull('.$tablename.'.approvestatus,"") != \''.D_A_S_REJECTED.'\' ';
            }else{
                $query = ' and '.$tablename.'.approvestatus in ('.$_REQUEST["approve_value"].')';
                $query = str_replace("unapproved","'" . D_A_S_UNAPPROVED . "'",$query);
                $query = str_replace("approving","'" . D_A_S_APPROVALOF . "'",$query);
                $query = str_replace("approved","'" . D_A_S_APPROVED . "'",$query);
                $query = str_replace("rejected","'" . D_A_S_REJECTED . "'",$query);
                $query = str_replace("dismissed","'" . D_A_S_DISMISSED . "'",$query);
            }
        }
        return $query;
    }
//@edit:liushuai,2021-02-24,reason:【ID1001362】首页-审批状态可多选查看（四方光电）
    public static function getApproveStatusQuery(){
        $query = '';
        if(!empty($_REQUEST['approve_value'])){
            if($_REQUEST['approve_value'] == 'all' || strpos($_REQUEST['approve_value'],'all') !== false){
                $query = ' and ifnull(approvestatus,"") != \''.D_A_S_REJECTED.'\' ';
            }else{
                $query = ' and approvestatus in ('.$_REQUEST["approve_value"].')';
                $query = str_replace("unapproved","'" . D_A_S_UNAPPROVED . "'",$query);
                $query = str_replace("approving","'" . D_A_S_APPROVALOF . "'",$query);
                $query = str_replace("approved","'" . D_A_S_APPROVED . "'",$query);
                $query = str_replace("rejected","'" . D_A_S_REJECTED . "'",$query);
                $query = str_replace("dismissed","'" . D_A_S_DISMISSED . "'",$query);
            }
        }
        return $query;
    }

    /**
     * @param $search_date
     * @return string
     * 获取所给时间的当年时间区间
     * zxm
     * 2020-1204
     */
    public static function getYearDateScope($search_date)
    {
        switch($search_date){
            case 'thistoday':	//今日
            case 'today'://手机daunt
                $year = date('Y')."-01-01";
                $date = date('Y-m-d');
                return " between '$year' and '$date'" ;
            case 'yestoday':	//昨日
            case 'syesterday'://手机daunt
                $year = date('Y-01-01',strtotime("-1 day"));
                $date = date('Y-m-d',strtotime("-1 day"));
                return " between '$year' and '$date'" ;
            case 'thisweek':	//本周
                $year = date('Y-01-01', (time() + (7 - (date('w') == 0 ? 7 : date('w'))) * 24 * 3600));
                $end = date('Y-m-d', (time() + (7 - (date('w') == 0 ? 7 : date('w'))) * 24 * 3600));
                return " between '$year 00:00:00' and '$end 23:59:59' " ;
            case 'lastweek':
                $date = date("Y-m-d");  //当前日期
                $first=1;     //$first =1 表示每周星期一为开始时间 0表示每周日为开始时间
                $w = date("w", strtotime($date));  //获取当前周的第几天 周日是 0 周一 到周六是 1 -6
                $d = $w ? $w - $first : 6;  //如果是周日 -6天
                $nowdate  = date("Y-m-d 00:00:00", strtotime("$date -".$d." days"));
                $nowStart  = date("Y-m-d 00:00:00", strtotime("$nowdate - 7 days")); //上周开始时间
                $year = date("Y-01-01", strtotime("$nowStart +6 days"));
                $nowEnd    = date("Y-m-d 23:59:59", strtotime("$nowStart +6 days"));  //上周结束时间
                return " between '$year 00:00:00' and '$nowEnd 23:59:59' " ;
            case 'thismonth':	//本月
            case 'month':
                $year = date('Y-01-01');
                $date = date('Y-m-d');
                return " between '$year 00:00:00' and '$date 23:59:59' " ;
            case 'lastmonth':	//上月
                $timestamp=strtotime(date('Y-m-d H:i:s'));
                $year = date('Y-01-01',strtotime(date('Y',$timestamp).'-'.(date('m',$timestamp)-1)));
                $date = date('Y-m-d',strtotime("-1 days",strtotime(date('Y-m-01'))));
                return " between '$year 00:00:00' and '$date 23:59:59' " ;
            case 'nextmonth':	//下月
                $timestamp=strtotime(date('Y-m-d H:i:s'));
                $year = date('Y-01-01',strtotime(date('Y',$timestamp).'-'.(date('m',$timestamp)+1)));
                $date = date('Y-m',strtotime(date('Y',$timestamp).'-'.(date('m',$timestamp)+2)));
                return " between '$year 00:00:00' and '$date-01 00-00-00' " ;
            case 'thisyear':	//本年度
            case 'year':
            case 'thisfy'://手机端
                $date = date('Y');
                return " like '%$date%' " ;
            case 'lastyear':	//上年度
            case 'prevfy'://手机端
                $date = date('Y',strtotime("-1 year"));
                return " like '%$date%' " ;
            case 'thisquarter':	//本季度
            case 'quarter':
            case 'thisfq'://手机daunt
                $season = ceil((date('n'))/3);
                $year = date('Y-01-01 00:00:00', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                $end = date('Y-m-d H:i:s', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                return " between '$year' and '$end' " ;
            case 'lastquarter':	//上季度
            case 'prevfq'://手机端
                $season = ceil((date('n'))/3)-1;
                $year = date('Y-01-01 00:00:00', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                $end = date('Y-m-d H:i:s', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                return " between '$year' and '$end' " ;
            case 'all':
                return '';
            default:
                $date = explode('~',$search_date);
                $end_date = explode('-',$date[1]);
                $year = $end_date[0]."-01-01";
                if(sizeof($date) > 1){
                    return " between '$year 00:00:00' and '$date[1] 23:59:59' " ;
                }else{
                    $date = date('Y-m');
                    return " between '$year 00:00:00' and '$date 23:59:59'" ;
                }
        }
    }
    /**
     * @param $start_date
     * @param $end_date
     * @param string $explode
     * @param false $addOne
     * @return array
     * 获取两个日期之间的所有月份
     */
    public static function dateMonths($start_date,$end_date,$explode='-',$addOne=false)
    {
        //判断两个时间是不是需要调换顺序
        $start_int = strtotime($start_date);
        $end_int = strtotime($end_date);
        if($start_int > $end_int){
            $tmp = $start_date;
            $start_date = $end_date;
            $end_date = $tmp;
        }


        //结束时间月份+1，如果是13则为新年的一月份
        $start_arr = explode($explode,$start_date);
        $start_year = intval($start_arr[0]);
        $start_month = intval($start_arr[1]);


        $end_arr = explode($explode,$end_date);
        $end_year = intval($end_arr[0]);
        $end_month = intval($end_arr[1]);


        $data = array();
        $data[] = $start_date;


        $tmp_month = $start_month;
        $tmp_year = $start_year;


        //如果起止不相等，一直循环
        while (!(($tmp_month == $end_month) && ($tmp_year == $end_year))) {
            $tmp_month ++;
            //超过十二月份，到新年的一月份
            if($tmp_month > 12){
                $tmp_month = 1;
                $tmp_year++;
            }
            $data[] = $tmp_year.$explode.str_pad($tmp_month,2,'0',STR_PAD_LEFT);
        }


        if($addOne == true){
            $tmp_month ++;
            //超过十二月份，到新年的一月份
            if($tmp_month > 12){
                $tmp_month = 1;
                $tmp_year++;
            }
            $data[] = $tmp_year.$explode.str_pad($tmp_month,2,'0',STR_PAD_LEFT);
        }


        return $data;
    }

    /**
     * @param $search_date
     * @return string[]
     * zxm
     * 2020-1204
     * 根据首页传输过来的时间值 穿透到数据列表高级查询的时间条件
     */
    public static function getAdvancedQueryOfDate($search_date)
    {
        $date_arr = [
            'datecomparator'=>'',//高级查询的选项 比如today syesterday
            'date_value='=>'',//所选择时间的值
            'date_year_value'=>''//所选择的时间的当年值
        ];

        $current_date = date('Y-m-d');//当前日期
        switch($search_date){
            case 'thistoday'://今日
            case 'today':
                $current_year = date('Y')."-01-01 00:00:00";//当年1-1号
                $date_arr['datecomparator'] = 'today';
                $date_arr['date_value'] = date("Y-m-d");
                $date_arr['date_year_value'] = "$current_year,".$date_arr['date_value']. " 23:59:59";
                break;
            case 'yestoday'://昨日
            case 'syesterday'://昨日手机端
                $date_arr['date_value'] = DateOperation::addDays($current_date,'-1');
                $current_year = date('Y',strtotime($date_arr['date_value']))."-01-01 00:00:00";//当年1-1号
                $date_arr['datecomparator'] = 'syesterday';//高级查询使用
                $date_arr['date_year_value'] = "$current_year,".$date_arr['date_value']. " 23:59:59";
                break;
            case 'thisweek':	//本周
                $date_arr['date_value'] = DateOperation::get_weekinfo_by_date(date("Y-m-d"));
                $date_arr['datecomparator'] = 'thisweek';
                $current_year = date('Y',strtotime($date_arr['date_value']['week_end_day']))."-01-01 00:00:00";//当年1-1号
                $date_arr['date_year_value'] = "$current_year,".$date_arr['date_value']['week_end_day']. " 23:59:59";;
                break;
            case 'lastweek':
                $first = 1;//$first =1 表示每周星期一为开始时间 0表示每周日为开始时间
                $w = date("w", strtotime($current_date));  //获取当前周的第几天 周日是 0 周一 到周六是 1 -6
                $d = $w ? $w - $first : 6;  //如果是周日 -6天
                $nowdate = date("Y-m-d 00:00:00", strtotime("$current_date -".$d." days"));
                $nowStart = date("Y-m-d 00:00:00", strtotime("$nowdate - 7 days")); //上周开始时间
                $nowEnd = date("Y-m-d 23:59:59", strtotime("$nowStart +6 days"));  //上周结束时间
                $date_arr['date_value'] = "$nowStart,$nowEnd";
                $current_year = date('Y',strtotime($nowEnd))."-01-01 00:00:00";//当年1-1号
                $date_arr['date_year_value'] = "$current_year,$nowEnd";
                $date_arr['datecomparator'] = 'lastweek';
                break;
            case 'thismonth':	//本月
            case 'month':
                //本月最后一天
                $endDay = date("Y-m").'-'.DateOperation::getMonthDays(date("Y-m").'-01');
                $date_arr['date_value'] = date("Y-m").'-01,'.$endDay;
                $date_arr['datecomparator'] = 'thismonth';
                $current_year = date('Y',strtotime($endDay))."-01-01 00:00:00";//当年1-1号
                $date_arr['date_year_value'] = "$current_year,$endDay". " 23:59:59";
                break;
            case 'lastmonth':	//上月
                $tmps = DateOperation::getlastMonthDays(date("Y-m-d"));
                $date_arr['date_value'] = $tmps[1];
                $date_arr['datecomparator'] = 'lastmonth';
                $current_year = date('Y',strtotime($tmps[1]))."-01-01 00:00:00";//当年1-1号
                $date_arr['date_year_value'] = "$current_year,".$tmps[1]. " 23:59:59";;
                break;
            case 'thisyear':	//本年度
            case 'year':
            case 'thisfy'://手机端
                $date_arr['datecomparator'] = 'thisfy';
                $season = ceil((date('n'))/3);
                $year = date('Y-01-01 00:00:00', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                $end = date('Y-m-d H:i:s', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                $date_arr['date_year_value'] ="$year,".$end;
                break;
            case 'lastyear':	//上年度
            case 'prevfy'://手机端
                $season = ceil((date('n'))/3)-1;
                $year = date('Y-01-01 00:00:00', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                $end = date('Y-m-d H:i:s', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                $date_arr['date_year_value'] = "$year,".$end;
                $date_arr['datecomparator'] = 'prevfy';
                break;
            case 'thisquarter':	//本季度
            case 'quarter':
            case 'thisfq'://手机daunt
                $season = ceil((date('n'))/3);
                $year = date('Y-01-01 00:00:00', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                $end = date('Y-m-d H:i:s', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                $date_arr['datecomparator'] = 'thisfq';
                $date_arr['date_year_value'] ="$year,".$end;
                break;
            case 'lastquarter':	//上季度
            case 'prevfq'://手机端
                $season = ceil((date('n'))/3)-1;
                $year = date('Y-01-01 00:00:00', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                $end = date('Y-m-d H:i:s', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                $date_arr['date_year_value'] = "$year,".$end;
                $date_arr['datecomparator'] = 'prevfq';
                break;
            case 'all':
                break;
            default:
                $date = explode('~',$search_date);
                if(sizeof($date) > 1){
                    $date_arr['datecomparator'] = 'bw';
                    $date_arr['date_value'] = $date[0].','.$date[1];
                    $date_arr['date_year_value'] = $date[0].'-01-01,'.$date[1];
                }
        }
        return $date_arr;
    }


    /**
     * @param $search_date
     * @return string
     * 获取所给时间的累计时间区间
     * gxy
     * 2021-0317
     */
    public static function getDateScope($search_date)
    {
        switch($search_date){
            case 'thistoday':	//今日
            case 'today'://手机daunt
                $year = date('Y-m-d',strtotime("-100 year"));
                $date = date('Y-m-d');
                return " between '$year' and '$date'" ;
            case 'yestoday':	//昨日
            case 'syesterday'://手机daunt
                $year = date('Y-m-d',strtotime("-100 year"));
                $date = date('Y-m-d',strtotime("-1 day"));
                return " between '$year' and '$date'" ;
            case 'thisweek':	//本周
                $year = date('Y-m-d',strtotime("-100 year"));
                $end = date('Y-m-d', (time() + (7 - (date('w') == 0 ? 7 : date('w'))) * 24 * 3600));
                return " between '$year 00:00:00' and '$end 23:59:59' " ;
            case 'lastweek':
                $date = date("Y-m-d");  //当前日期
                $first=1;     //$first =1 表示每周星期一为开始时间 0表示每周日为开始时间
                $w = date("w", strtotime($date));  //获取当前周的第几天 周日是 0 周一 到周六是 1 -6
                $d = $w ? $w - $first : 6;  //如果是周日 -6天
                $nowdate  = date("Y-m-d 00:00:00", strtotime("$date -".$d." days"));
                $nowStart  = date("Y-m-d 00:00:00", strtotime("$nowdate - 7 days")); //上周开始时间
                $year = date('Y-m-d',strtotime("-100 year"));
                $nowEnd    = date("Y-m-d 23:59:59", strtotime("$nowStart +6 days"));  //上周结束时间
                return " between '$year 00:00:00' and '$nowEnd 23:59:59' " ;
            case 'thismonth':	//本月
            case 'month':
                $year = date('Y-m-d',strtotime("-100 year"));
                $date = date('Y-m-d');
                return " between '$year 00:00:00' and '$date 23:59:59' " ;
            case 'lastmonth':	//上月
                $timestamp=strtotime(date('Y-m-d H:i:s'));
                $year = date('Y-m-d',strtotime("-100 year"));
                $date = date('Y-m-d',strtotime("-1 days",strtotime(date('Y-m-01'))));
                return " between '$year 00:00:00' and '$date 23:59:59' " ;
            case 'nextmonth':	//下月
                $timestamp=strtotime(date('Y-m-d H:i:s'));
                $year = date('Y-m-d',strtotime("-100 year"));
                $date = date('Y-m',strtotime(date('Y',$timestamp).'-'.(date('m',$timestamp)+2)));
                return " between '$year 00:00:00' and '$date-01 00-00-00' " ;
            case 'thisyear':	//本年度
            case 'year':
            case 'thisfy'://手机端
                $year = date('Y-m-d',strtotime("-100 year"));
                $date = date('Y-m-d');
                return " between '$year' and '$date'" ;
            case 'lastyear':	//上年度
            case 'prevfy'://手机端
                $year = date('Y-m-d',strtotime("-100 year"));
                $date = date('Y-01-01',strtotime("-1 day"));
                return " between '$year 00:00:00' and '$date 23:59:59' " ;
            case 'thisquarter':	//本季度
            case 'quarter':
            case 'thisfq'://手机daunt
                $season = ceil((date('n'))/3);
                $year = date('Y-m-d',strtotime("-100 year"));
                $end = date('Y-m-d H:i:s', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                return " between '$year' and '$end' " ;
            case 'lastquarter':	//上季度
            case 'prevfq'://手机端
                $season = ceil((date('n'))/3)-1;
                $year = date('Y-m-d',strtotime("-100 year"));
                $end = date('Y-m-d H:i:s', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                return " between '$year' and '$end' " ;
            case 'all':
                return '';
            default:
                $date = explode('~',$search_date);
                $end_date = explode('-',$date[1]);
                $year = $end_date[0]."-01-01";
                if(sizeof($date) > 1){
                    return " between '$year 00:00:00' and '$date[1] 23:59:59' " ;
                }else{
                    $date = date('Y-m');
                    return " between '$year 00:00:00' and '$date 23:59:59'" ;
                }
        }
    }
}