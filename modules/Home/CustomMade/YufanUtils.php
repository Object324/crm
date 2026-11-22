<?php
include globalStatic::$root_directory."modules/Home/CustomMade/CustomMadeUtils.php";
class YufanUtils extends CustomMadeUtils
{
    public function getStuffData($dfid,$search_date,$scopeType,$senioruserid,$approve_value){
        if($dfid==46){//@edit:zhouxiaomei,2020-1126,reason:誉帆-首页增加营销报告
            //去计算营销报告数据
            $home_values = $this->getMarketingReport($search_date,$scopeType,$senioruserid,$approve_value);
        }else if($dfid==47) {//@edit:zhouxiaomei,2020-1127,reason:誉帆-首页增加项目报告

            //去计算营销报告数据
            $home_values = $this->getProjectReport($search_date,$scopeType,$senioruserid,$approve_value);
        }else if($dfid==48) {//@edit:zhouxiaomei,2020-1127,reason:誉帆-首页增加营销对比报告

            $home_values = $this->getSixMonthMarketingReport($scopeType,$senioruserid);
        }else if($dfid==49) {//@edit:zhouxiaomei,2020-1127,reason:誉帆-首页增加项目对比报告

            $home_values = $this->getSixMonthProjectReport($scopeType,$senioruserid);
        }else if($dfid==50) {//@edit:zhouxiaomei,2020-1202 reason:誉帆-首页增加排行榜

            $listType = $_REQUEST['data_type'];
            $home_values = $this->getRankingListData($search_date,$approve_value,$listType);
        }
        return $home_values;
    }
    /**
     * @param $scopeType
     * @param $senioruserid
     * @return array
     * @throws Exception
     * zxm
     * 2020-1130
     * 誉帆-首页增加近6个月营销对比报告
     */
    public function getSixMonthMarketingReport($scopeType,$senioruserid){
        global $adb,$current_language;
        $where = ' deleted=0 ';
        //审批状态
        $where .= $this->getApproveStatusQuery();
        /*$approve_status = $_REQUEST['approve_value'];
        if(!empty($approve_status)&&$approve_status!="all"){
            $approve_name = $this->getApproveStatusName($approve_status);
            $where .= ' and approvestatus="'.$approve_name.'"';
        }*/
        //查看人员范围
        if(!empty($senioruserid)&&$senioruserid!="all"){
            $scope_obj = new ScopOfAuthority($adb,'MobileReport');
            $where .= ' and '.$scope_obj->getHomeSmOwnerSearchSql($scopeType,$senioruserid);
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
        $hetong_sql = " select sum(total) as hetong,date_format(createdtime,'%Y-%m') as `month` from ld_customform12 where $where group by `month` order by `month` asc";
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
        $res['title'] = $res['month'];
        $res['hetong'] = array_values($res['hetong']);
        $res['kaipiao'] = array_values($res['kaipiao']);
        $res['huikuan'] = array_values($res['huikuan']);
        return $res;
    }

    /***
     * @param $scopeType
     * @param $senioruserid
     * @return array
     * @throws Exception
     * zxm
     * 2020-1204
     * 誉帆 增加近6个月项目对比报告
     */
    public function getSixMonthProjectReport($scopeType,$senioruserid){
        global $adb,$current_language;
        $where = ' deleted=0 ';
        //审批状态
        $where .= $this->getApproveStatusQuery();
        /*$approve_status = $_REQUEST['approve_value'];
        if(!empty($approve_status)&&$approve_status!="all"){
            $approve_name = $this->getApproveStatusName($approve_status);
            $where .= ' and approvestatus="'.$approve_name.'"';
        }*/
        //查看人员范围
        if(!empty($senioruserid)&&$senioruserid!="all"){
            $scope_obj = new ScopOfAuthority($adb,'MobileReport');
            $where .= ' and '.$scope_obj->getHomeSmOwnerSearchSql($scopeType,$senioruserid);
        }
        // 时间范围
        $now_date = date('Y-m',strtotime('+1 month')).'-01 00:00:00';
        $last_date = date('Y-m',strtotime('-5 month')).'-01 00:00:00';
        $date_sql = " between '$last_date' and '$now_date' ";
        //时间数组
        $dateMonthsArr = $this->dateMonths(date('Y-m',strtotime('-5 month')),date('Y-m',time()));
        foreach($dateMonthsArr as $v){
            $chanzhi[$v] = 0;
            $chengben[$v] = 0;
            $maoli[$v] = 0;
            $maoli_rate[$v] = 0;
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
        //项目产值
        $chanzhi_sql = " select (sum(a.total)+sum(b.cf_4254)+sum(b.cf_4255)+sum(b.cf_4256)) as chanzhi,date_format(b.cf_3879,'%Y-%m') as `month` from ld_servicecontracts a left join ld_servicecontractscf b on a.servicecontractsid=b.servicecontractsid where $where and b.cf_3879  $date_sql group by `month` order by `month` asc";
        $chanzhi_res = $adb->pquery($chanzhi_sql);
        $chanzhi_num = $adb->num_rows($chanzhi_res);
        if($chanzhi_num>0){
            for($i=0;$i<$chanzhi_num;$i++){
                $tem_month = $adb->query_result($chanzhi_res,$i,'month');
                $chanzhi[$tem_month] = round($adb->query_result($chanzhi_res,$i,'chanzhi'),2);
            }
        }
        //项目成本
        $cost1_sql = "select sum(total) as cost1 ,date_format(createdtime,'%Y-%m') as `month` from ld_customform14 a left join ld_customform14scf b on a.customform14id=b.customform14id where $where and b.cf_3981 $date_sql group by `month` order by `month` asc";
        $cost1_res = $adb->pquery($cost1_sql);
        $nums1 = $adb->num_rows($cost1_res);
        if($nums1>0){
            for($i=0;$i<$nums1;$i++){
                $tem_month = $adb->query_result($cost1_res,$i,'month');
                $chengben[$tem_month] += round($adb->query_result($cost1_res,$i,'cost1'),2);
            }
        }
        $cost2_sql = "select sum(total) as cost2,date_format(createdtime,'%Y-%m') as `month` from ld_expense where $where and expensedate $date_sql group by `month` order by `month` asc";
        $cost2_res = $adb->pquery($cost2_sql);
        $nums2 = $adb->num_rows($cost2_res);
        if($nums2>0){
            for($i=0;$i<$nums2;$i++){
                $tem_month = $adb->query_result($cost2_res,$i,'month');
                $chengben[$tem_month] += round($adb->query_result($cost2_res,$i,'cost2'),2);
            }
        }
        $cost3_sql = "select sum(total) as cost3,date_format(createdtime,'%Y-%m') as `month` from ld_outboundorder where $where and projectid>0 and outdate $date_sql group by `month` order by `month` asc";
        $cost3_res = $adb->pquery($cost3_sql);
        $nums3 = $adb->num_rows($cost3_res);
        if($nums3>0){
            for($i=0;$i<$nums3;$i++){
                $tem_month = $adb->query_result($cost3_res,$i,'month');
                $chengben[$tem_month] += round($adb->query_result($cost3_res,$i,'cost3'),2);
            }
        }
        // 毛利 毛利率
        for($i=0;$i<6;$i++){
            $chanzhi_temp = isset($chanzhi[$dateMonthsArr[$i]])?$chanzhi[$dateMonthsArr[$i]]:0;
            $chengben_temp = isset($chengben[$dateMonthsArr[$i]])?$chengben[$dateMonthsArr[$i]]:0;
            $maoli[$dateMonthsArr[$i]] = round($chanzhi_temp - $chengben_temp,2);
            $maoli_rate[$dateMonthsArr[$i]] = $chanzhi_temp==0?0:round($maoli[$dateMonthsArr[$i]]*100/$chanzhi_temp,4);
        }
        $res['title'] = $res['month'];
        $res['chanzhi'] = array_values($chanzhi);
        $res['chengben'] = array_values($chengben);
        $res['maoli'] = array_values($maoli);
        $res['maoli_rate'] = array_values($maoli_rate);
        return $res;
    }
    /**
     * @param $search_date
     * @param $scopeType
     * @param $senioruserid
     * @param $approve_status
     * @return mixed
     * @throws Exception
     * zhouxiaomei,2020-1126,reason:誉帆-首页增加营销报告
     */
    public function getMarketingReport($search_date,$scopeType,$senioruserid,$approve_status){
        global $adb;
        global $current_user;
        $query="";
        //审批状态
        if(!empty($approve_status)){
//            @edit:liushuai,2021-02-24,reason:【ID1001362】首页-审批状态可多选查看（四方光电）
            if($approve_status == 'all' || strpos($approve_status,'all') !== false){
                $query = ' and ifnull(approvestatus,"") != \''.D_A_S_REJECTED.'\' ';
            }else{
                $query = ' and approvestatus in ('.$approve_status.')';
                $query = str_replace("unapproved","'" . D_A_S_UNAPPROVED . "'",$query);
                $query = str_replace("approving","'" . D_A_S_APPROVALOF . "'",$query);
                $query = str_replace("approved","'" . D_A_S_APPROVED . "'",$query);
                $query = str_replace("rejected","'" . D_A_S_REJECTED . "'",$query);
                $query = str_replace("dismissed","'" . D_A_S_DISMISSED . "'",$query);
            }
            /*switch($approve_status){
                case 'unapproved':	//未提交
                    $query .= ' and approvestatus = \''.D_A_S_UNAPPROVED.'\' ';
                    break;
                case 'approving':	//审批中
                    $query .= ' and approvestatus = \''.D_A_S_APPROVALOF.'\' ';
                    break;
                case 'approved':	//审批通过
                    $query .= ' and approvestatus = \''.D_A_S_APPROVED.'\' ';
                    break;
                case 'rejected':	//已拒绝
                    $query .= ' and approvestatus = \''.D_A_S_REJECTED.'\' ';
                    break;
                case 'dismissed':	//已驳回
                    $query .= ' and approvestatus = \''.D_A_S_DISMISSED.'\' ';
                    break;
                default:
                    $query .= ' and ifnull(approvestatus,"") != \''.D_A_S_REJECTED.'\' ';
                    break;
            }*/
        }
        //查看范围sql
        $scopeobj = new ScopOfAuthority($adb,'MobileReport');
        if(!empty($scopeType)){
            $scopesql = $scopeobj->getHomeSmOwnerSearchSql($scopeType,$senioruserid);
            if(!empty($scopesql)){
                $query .= ' and ' . $scopesql;
            }
        }else{
            if(!empty($senioruserid)){
                $query .= ' and smownerid in ('.$senioruserid.')';
            }
        }
        $date_sql = getHomeDateScope($search_date);
        //新增项目
        $project_sql = "select count(1) as project_nums from ld_project where deleted=0 $query and createdtime $date_sql";
        $project_res = $adb->pquery($project_sql);
        $nums = $adb->num_rows($project_res);
        $project_nums = $nums>0?$adb->query_result($project_res,0,"project_nums"):0;
        $res['project']['nums'] = empty($project_nums)?0:$project_nums;
        $res['project']['name'] = "新增项目";
        $res['project']['back_img'] = "crm_Project.png";
        $res['project']['module'] = "Project";
        $res['project']['label'] = "new_project";
        //新增客户
        $account_sql = "select count(1) as account_nums from ld_account where deleted=0 $query and createdtime $date_sql";
        $account_res = $adb->pquery($account_sql);
        $nums = $adb->num_rows($account_res);
        $account_nums = $nums>0?$adb->query_result($account_res,0,"account_nums"):0;
        $res['account']['nums'] = empty($account_nums)?0:$account_nums;
        $res['account']['name'] = "新增客户";
        $res['account']['back_img'] = "crm_Accounts.png";
        $res['account']['module'] = "Accounts";
        $res['account']['label'] = "new_account";
        // 新增合同//CustomForm12
        $customform12_sql = "select sum(total) as customform12_total from ld_customform12 where deleted=0 $query and createdtime $date_sql";
        $customform12_res = $adb->pquery($customform12_sql);
        $nums = $adb->num_rows($customform12_res);
        $customform12_total = $nums>0?$adb->query_result($customform12_res,0,"customform12_total"):0.00;
        $res['customform12']['nums'] = "￥" . (empty($customform12_total)?0:number_format($customform12_total,2));
        $res['customform12']['name'] = "新增合同";
        $res['customform12']['back_img'] = "crm_SalesOrder.png";
        $res['customform12']['module'] = "CustomForm12";
        $res['customform12']['label'] = "new_contract";
        //已开票
        $invoice_sql = "select sum(total) as invoice_total from ld_invoice where deleted=0 $query and createdtime $date_sql";
        $invoice_res = $adb->pquery($invoice_sql);
        $nums = $adb->num_rows($invoice_res);
        $invoice_total = $nums>0?$adb->query_result($invoice_res,0,"invoice_total"):0.00;
        $res['invoice']['nums'] = "￥" . (empty($invoice_total)?0:number_format($invoice_total,2));
        $res['invoice']['name'] = "已开票";
        $res['invoice']['back_img'] = "crm_Invoice.png";
        $res['invoice']['module'] = "Invoice";
        $res['invoice']['label'] = "have_invoice";
        //已收款
        $cashbill_sql = "select sum(total) as cashbill_total from ld_cashbill where deleted=0 $query and createdtime $date_sql";
        $cashbill_res = $adb->pquery($cashbill_sql);
        $nums = $adb->num_rows($cashbill_res);
        $cashbill_total = $nums>0?$adb->query_result($cashbill_res,0,"cashbill_total"):0.00;
        $res['cashbill']['nums'] = "￥" . (empty($cashbill_total)?0:number_format($cashbill_total,2));
        $res['cashbill']['name'] = "已收款";
        $res['cashbill']['back_img'] = "crm_CashBill.png";
        $res['cashbill']['module'] = "CashBill";
        $res['cashbill']['label'] = "have_cash";
        //应收账款（合同口径）
//        $customform47_sql = "select sum(cf_4060) as customform47_total from ld_customform47scf b right join ld_customform47 a on a.customform47id=b.customform47id where deleted=0 $query and cf_4059 $date_sql";
//        $customform47_res = $adb->pquery($customform47_sql);
//        $nums = $adb->num_rows($customform47_res);
//        $customform47_total = $nums>0?$adb->query_result($customform47_res,0,"customform47_total"):0.00;
//        $res['customform47']['nums'] = "￥" . (empty($customform47_total)?0:number_format($customform47_total,2));
//        $res['customform47']['name'] = "应收账款（合同口径）";
//        $res['customform47']['back_img'] = "crm_CashBill.png";
//        $res['customform47']['module'] = "CustomForm47";
//        $res['customform47']['label'] = "should_cash_by_contract";
        // 应收账款（产值口径） ServiceContracts
        $servicecontracts_sql = "select sum(total) as servicecontracts_total from ld_servicecontracts a left join ld_servicecontractscf b on a.servicecontractsid=b.servicecontractsid where deleted=0 $query and b.cf_3879  $date_sql";
        $servicecontracts_res = $adb->pquery($servicecontracts_sql);
        $nums = $adb->num_rows($servicecontracts_res);
        $servicecontracts_total = $nums>0?$adb->query_result($servicecontracts_res,0,"servicecontracts_total"):0.00;
        $res['servicecontracts']['nums'] = "￥" . (empty($servicecontracts_total)?0:number_format($servicecontracts_total,2));
        $res['servicecontracts']['name'] = "应收账款（产值口径）";
        $res['servicecontracts']['back_img'] = "crm_CashBill.png";
        $res['servicecontracts']['module'] = "ServiceContracts";
        $res['servicecontracts']['label'] = "should_cash_by_chanzhi";
        //应收账款（合同口径）>3个月
//        $time_str = date("Y-m-d H:i:s",strtotime("-3 month"));
//        $beyondthreemonth_sql = "select sum(cf_4060) as customform47_total from ld_customform47scf b right join ld_customform47 a on a.customform47id=b.customform47id where deleted=0 $query and cf_4059 <'$time_str'";
//        $beyondthreemonth_res = $adb->pquery($beyondthreemonth_sql);
//        $nums = $adb->num_rows($beyondthreemonth_res);
//        $beyondthreemonth_total = $nums>0?$adb->query_result($beyondthreemonth_res,0,"customform47_total"):0.00;
//        $res['beyondthreemonth']['nums'] = "￥" . (empty($beyondthreemonth_total)?0:number_format($beyondthreemonth_total,2));
//        $res['beyondthreemonth']['name'] = "应收账款（合同口径）>3个月";
//        $res['beyondthreemonth']['back_img'] = "crm_Warn.png";
//        $res['beyondthreemonth']['module'] = "CustomForm47";
//        $res['beyondthreemonth']['label'] = "should_cash_over_three";
        return $res;
    }

    /**
     * @param $search_date
     * @param $scopeType
     * @param $senioruserid
     * @param $approve_status
     * @return mixed
     * @throws Exception
     * zxm
     * 2020-1202
     * 誉帆-首页项目报告
     */
    public function getProjectReport($search_date,$scopeType,$senioruserid,$approve_status){
        global $adb;
        global $current_user;
        $query="";
        $query_project="";

        //审批状态
        if(!empty($approve_status)){
//            @edit:liushuai,2021-02-24,reason:【ID1001362】首页-审批状态可多选查看（四方光电）
            if ($approve_status == 'all' || strpos($approve_status,'all') !== false) {
                $query .= '';
                $query_project .='';
            }else{
                $query .= '  and approvestatus in ('.$approve_status.')';
                $query_project .= '  and project.approvestatus in ('.$approve_status.')';
                $approve_status_arr = explode(',', $approve_status);
                if(in_array('unapproved', $approve_status_arr)){
                    $query = str_replace("unapproved","'" . D_A_S_UNAPPROVED . "'",$query);
                    $query_project = str_replace("unapproved","'" . D_A_S_UNAPPROVED . "'",$query_project);
                }
                if(in_array('approving', $approve_status_arr)){
                    $query = str_replace("approving","'" . D_A_S_APPROVALOF . "'",$query);
                    $query_project = str_replace("approving","'" . D_A_S_APPROVALOF . "'",$query_project);
                }
                if(in_array('approved', $approve_status_arr)){
                    $query = str_replace("approved","'" . D_A_S_APPROVED . "'",$query);
                    $query_project = str_replace("approved","'" . D_A_S_APPROVED . "'",$query_project);
                }
                if(in_array('rejected', $approve_status_arr)){
                    $query = str_replace("rejected","'" . D_A_S_REJECTED . "'",$query);
                    $query_project = str_replace("rejected","'" . D_A_S_REJECTED . "'",$query_project);
                }
                if(in_array('dismissed', $approve_status_arr)){
                    $query = str_replace("dismissed","'" . D_A_S_DISMISSED . "'",$query);
                    $query_project = str_replace("dismissed","'" . D_A_S_DISMISSED . "'",$query_project);
                }
            }

            /*switch($approve_status){
                case 'unapproved':	//未提交
                    $query .= ' and approvestatus = \''.D_A_S_UNAPPROVED.'\' ';
                    $query_project .=' and project.approvestatus = \''.D_A_S_UNAPPROVED.'\' ';
                    break;
                case 'approving':	//审批中
                    $query .= ' and approvestatus = \''.D_A_S_APPROVALOF.'\' ';
                    $query_project .=' and project.approvestatus = \''.D_A_S_APPROVALOF.'\' ';
                    break;
                case 'approved':	//审批通过
                    $query .= ' and approvestatus = \''.D_A_S_APPROVED.'\' ';
                    $query_project .=' and project.approvestatus = \''.D_A_S_APPROVED.'\' ';
                    break;
                case 'rejected':	//已拒绝
                    $query .= ' and approvestatus = \''.D_A_S_REJECTED.'\' ';
                    $query_project .=' and project.approvestatus = \''.D_A_S_REJECTED.'\' ';
                    break;
                case 'dismissed':	//已驳回
                    $query .= ' and approvestatus = \''.D_A_S_DISMISSED.'\' ';
                    $query_project .=' and project.approvestatus = \''.D_A_S_DISMISSED.'\' ';
                    break;
                case 'all':
                    $query .= '';
                    $query_project .='';
                    break;
                default:
                    $query .= ' and ifnull(approvestatus,"") != \''.D_A_S_REJECTED.'\' ';
                    $query_project .=' and project.approvestatus = \''.D_A_S_REJECTED.'\' ';
                    break;
            }*/
        }
        $chanzhi_query = $query;
        //查看范围sql
        $scopeobj = new ScopOfAuthority($adb,'MobileReport');
        if(!empty($scopeType)){
            $scopesql = $scopeobj->getHomeSmOwnerSearchSql($scopeType,$senioruserid);
            if(!empty($scopesql)){
                $query .= ' and ' . $scopesql;
                //针对项目的
                $query_project .= ' and project.'.$scopesql;
                //针对产值得
                $chanzhi_selectedid4007 = 'b.'.str_replace('smownerid','cf_4007',$scopesql);
                $chanzhi_selectedid4250 = 'b.'.str_replace('smownerid','cf_4250',$scopesql);
                $chanzhi_selectedid4252 = 'b.'.str_replace('smownerid','cf_4252',$scopesql);
                $chanzhi_query .= ' and a.'.$scopesql;
            }
        }else{
            if(!empty($senioruserid)){
                $query .= ' and smownerid in ('.$senioruserid.')';
                //针对项目的
                $query_project .= ' and project.smownerid in ('.$senioruserid.')';
                //针对产值得
                $chanzhi_query .= ' and a.smownerid in ('.$senioruserid.')';
                $chanzhi_selectedid4007 = ' and b.cf_4007 in ('.$senioruserid.')';
                $chanzhi_selectedid4250 = ' and b.cf_4250 in ('.$senioruserid.')';
                $chanzhi_selectedid4252 = ' and b.cf_4252 in ('.$senioruserid.')';
            }
        }
        $date_sql = getHomeDateScope($search_date);
        //项目产值ServiceContracts
        //ld_servicecontractscf:cf_4254:cf_4254:ServiceContracts_内部结算产值1:N
        //ld_servicecontractscf:cf_4255:cf_4255:ServiceContracts_内部结算产值2:N
        //ld_servicecontractscf:cf_4256:cf_4256:ServiceContracts_内部结算产值3:N
        //申报时间 负责人4007 、4250、4252
        $servicecontracts_sql = "select (ifnull(nums1,0) + ifnull(nums2,0)+ ifnull(nums3,0) + ifnull(nums4,0)) as sumtotal from (select sum(a.total) as nums1,'k' as k from ld_servicecontracts a left join ld_servicecontractscf b on a.servicecontractsid=b.servicecontractsid where a.deleted=0 and a.projectid>0 $chanzhi_query and  b.cf_3879 $date_sql) a 
left join (select sum(b.cf_4254) as nums2,'k' as k from ld_servicecontracts a left join ld_servicecontractscf b on a.servicecontractsid=b.servicecontractsid where a.deleted=0 and a.projectid>0  and  $chanzhi_selectedid4007 and b.cf_3879 $date_sql) b on a.k=b.k
 left join (select sum(b.cf_4255) as nums3,'k' as k from ld_servicecontracts a left join ld_servicecontractscf b on a.servicecontractsid=b.servicecontractsid where a.deleted=0 and a.projectid>0  and  $chanzhi_selectedid4250 and b.cf_3879 $date_sql) c on a.k=c.k
 left join (select sum(b.cf_4256) as nums4,'k' as k from ld_servicecontracts a left join ld_servicecontractscf b on a.servicecontractsid=b.servicecontractsid where a.deleted=0 and a.projectid>0  and  $chanzhi_selectedid4252 and  b.cf_3879 $date_sql) d on a.k=d.k";
//        dump($servicecontracts_sql);die;
//        $servicecontracts_sql = "select  (sum(a.total)+sum(b.cf_4254)+sum(b.cf_4255)+sum(b.cf_4256)) as sumtotal from ld_servicecontracts a left join ld_servicecontractscf b on a.servicecontractsid=b.servicecontractsid  where a.deleted=0 and a.projectid>0 $chanzhi_query and b.cf_3879 $date_sql";
        $servicecontracts_res = $adb->pquery($servicecontracts_sql);
        $nums = $adb->num_rows($servicecontracts_res);
        $servicecontracts_nums = $nums>0?$adb->query_result($servicecontracts_res,0,"sumtotal"):0.00;
        $res['servicecontracts']['nums'] = "￥" . (empty($servicecontracts_nums)?0:number_format($servicecontracts_nums,2));
        $res['servicecontracts']['name'] = "项目产值（上报产值）";
        $res['servicecontracts']['back_img'] = "crm_Project.png";
        $res['servicecontracts']['module'] = "ServiceContracts";
        $res['servicecontracts']['label'] = "chanzhi";
        // 项目产值（外部证据）
        //ld_servicecontractscf:cf_3767:cf_3767:ServiceContracts_有无产值确认单:V
        $servicecontracts2_sql = "select (ifnull(nums2,0)+ ifnull(nums3,0) + ifnull(nums4,0)) as sumtotal from 
(select sum(b.cf_4254) as nums2,'k' as k from ld_servicecontracts a left join ld_servicecontractscf b on a.servicecontractsid=b.servicecontractsid where a.deleted=0 and a.projectid>0  and  $chanzhi_selectedid4007 and b.cf_3879 $date_sql) a 
 left join (select sum(b.cf_4255) as nums3,'k' as k from ld_servicecontracts a left join ld_servicecontractscf b on a.servicecontractsid=b.servicecontractsid where a.deleted=0 and a.projectid>0  and  $chanzhi_selectedid4250 and b.cf_3879 $date_sql) b on a.k=b.k
 left join (select sum(b.cf_4256) as nums4,'k' as k from ld_servicecontracts a left join ld_servicecontractscf b on a.servicecontractsid=b.servicecontractsid where a.deleted=0 and a.projectid>0  and  $chanzhi_selectedid4252 and  b.cf_3879 $date_sql) c on a.k=c.k";
//        $servicecontracts2_sql = "select  (sum(b.cf_4254)+sum(b.cf_4255)+sum(b.cf_4256)) as sumtotal from ld_servicecontracts a left join ld_servicecontractscf b on a.servicecontractsid=b.servicecontractsid  where deleted=0 and a.projectid>0 $chanzhi_query and b.cf_3767='有' and b.cf_3879 $date_sql";
        $servicecontracts2_res = $adb->pquery($servicecontracts2_sql);
        $nums = $adb->num_rows($servicecontracts2_res);
        $servicecontracts2_nums = $nums>0?$adb->query_result($servicecontracts2_res,0,"sumtotal"):0.00;
        $res['servicecontracts2']['nums'] = "￥" . (empty($servicecontracts2_nums)?0:number_format($servicecontracts2_nums,2));
        $res['servicecontracts2']['name'] = "项目产值（外部证据）";
        $res['servicecontracts2']['back_img'] = "crm_Project.png";
        $res['servicecontracts2']['module'] = "ServiceContracts";
        $res['servicecontracts2']['label'] = "chanzhi2";
        //项目成本CustomForm14-total Expense-total OutboundOrder-total(仅统计出库单选择了“项目名称”的出库单金额projectid)
        //分包成本确认单”时间查询条件是按“申报时间”查询显示cf_3981
        $cost1_sql = "select sum(total) as sumtotal from ld_customform14 a left join ld_customform14scf b on a.customform14id=b.customform14id where deleted=0 $query and b.cf_3981 $date_sql";
        $cost1_res = $adb->pquery($cost1_sql);
        $nums1 = $adb->num_rows($cost1_res);
        $cost1_nums = $nums1>0?$adb->query_result($cost1_res,0,"sumtotal"):0.00;
        //项目费用报销单按照“报销日期”查询显示 expensedate
        $cost2_sql = "select sum(total) as sumtotal from ld_expense where deleted=0 $query and expensedate $date_sql";
        $cost2_res = $adb->pquery($cost2_sql);
        $nums2 = $adb->num_rows($cost2_res);
        $cost2_nums = $nums2>0?$adb->query_result($cost2_res,0,"sumtotal"):0.00;
        //出库日期
        $cost3_sql = "select sum(total) as sumtotal from ld_outboundorder where deleted=0 and projectid>0 $query and outdate $date_sql";
        $cost3_res = $adb->pquery($cost3_sql);
        $nums3 = $adb->num_rows($cost3_res);
        $cost3_nums = $nums3>0?$adb->query_result($cost3_res,0,"sumtotal"):0.00;
        $cost_nums = $cost1_nums+$cost2_nums+$cost3_nums;
        $res['cost']['nums'] = "￥" . (empty($cost_nums)?0:number_format($cost_nums,2));
        $res['cost']['name'] = "项目成本";
        $res['cost']['back_img'] = "crm_Project.png";
        $res['cost']['module'] = "CustomForm14,Expense,OutboundOrder";
        $res['cost']['label'] = "chengben";
        // 项目毛利额
        $maoli = $servicecontracts_nums - $cost_nums;
        $res['maoli']['nums'] = "￥" . (empty($maoli)?0.00:number_format($maoli,2));
        $res['maoli']['name'] = "项目毛利额";
        $res['maoli']['back_img'] = "crm_Potentials.png";
        $res['maoli']['module'] = "CustomForm14,Expense,OutboundOrder,ServiceContracts";
        $res['maoli']['label'] = "maoli";
        // 项目毛利率
        $maoli_rate = empty($servicecontracts_nums)?0.00:number_format($maoli*100/$servicecontracts_nums,2);
        $res['maoli_rate']['nums'] = $maoli_rate . "%";
        $res['maoli_rate']['name'] = "项目毛利率";
        $res['maoli_rate']['back_img'] = "crm_Expense.png";
        $res['maoli_rate']['module'] = "CustomForm14,Expense,OutboundOrder";
        $res['maoli_rate']['label'] = "maoli_rate";
        // 项目毛利额 最高最低
        //产值申报日期
        /**$rate_sql = "select projectid,max(maoli_rate) as max_maoli,min(maoli_rate)as min_maoli from
(select
		projectid,(chanzhi-fee)/IFNULL(chanzhi,1) as maoli_rate
	from (SELECT
		IFNULL((sum(a.total)+sum(s.cf_4254)+sum(s.cf_4255)+sum(s.cf_4256)),0) AS chanzhi,
		(IFNULL(sum(b.total),0)+
		IFNULL(sum(c.total),0)+
		IFNULL(sum(d.total),0)) as fee,
		project.projectid
	FROM
		ld_project AS project
	left join ld_servicecontracts as a on project.projectid=a.projectid
	left join ld_servicecontractscf s on a.servicecontractsid=s.servicecontractsid
	left join ld_customform14 as b on project.projectid=b.projectid
	left join ld_customform14scf bs on bs.customform14id=b.customform14id
	left join ld_expense as c on project.projectid=c.projectid
	left join ld_outboundorder as d on project.projectid=d.projectid
	where project.deleted=0
	$query_project and s.cf_3879 $date_sql and b.cf_3981 $date_sql and expensedate $date_sql and  outdate $date_sql
	group by project.projectid
) AS list group by projectid
)as maoli";*/

        $rate_sql = "select max(maoli_rate) as max_maoli,min(maoli_rate) as min_maoli from (SELECT
			project.projectid,project.project_no,
            IFNULL(d.chanzhi,0) AS chanzhi,
            IFNULL(e.expense,0) as baoxiao,
            IFNULL(f.outbound,0) as chuku,
            IFNULL(g.fenbao,0) as fenbao,
        (IFNULL(d.chanzhi,0) - IFNULL(e.expense,0)-IFNULL(f.outbound,0) - IFNULL(g.fenbao,0)) AS maoli,
        (
        case IFNULL(d.chanzhi,0) when 0 then 0
        else  (d.chanzhi - IFNULL(e.expense,0)-IFNULL(f.outbound,0) - IFNULL(g.fenbao,0))/d.chanzhi
        end 
         )AS maoli_rate
		    FROM
			ld_project project left join 
			(SELECT
				a.projectid,
				(
					sum(a.total) + sum(b.cf_4254) + sum(b.cf_4255) + sum(b.cf_4256)
				) AS chanzhi
			FROM
				ld_servicecontracts a
			LEFT JOIN ld_servicecontractscf b ON b.servicecontractsid = a.servicecontractsid
			WHERE
				a.deleted = 0
			$query
			AND a.projectid > 0
			AND b.cf_3879 $date_sql group by a.projectid) d 
			on project.projectid=d.projectid
			LEFT JOIN (
			SELECT
				b.entitytypeid,
				IFNULL(sum(d.rmb_total),0) as expense
			FROM
				ld_expense a
			LEFT JOIN ld_expensedetail b ON b.expenseid = a.expenseid 
			LEFT JOIN ld_expensedetailscf d ON d.expensedetailid=b.expensedetailid
			WHERE
				a.deleted = 0 
            and b.expensetype IN ('项目其他工资','项目绩效工资','项目设备折旧','项目其他费用')
			$query
			AND b.entitytypeid > 0
			AND a.expensedate $date_sql
			GROUP BY
				b.entitytypeid) e 
            ON e.entitytypeid = project.projectid
            LEFT JOIN (
			SELECT
				a.projectid,
				SUM(a.total) AS outbound
			FROM
				ld_outboundorder a
			WHERE
				a.deleted = 0
			$query
			AND a.projectid > 0
			AND a.outdate $date_sql group by a.projectid) f 
			ON f.projectid = project.projectid
			LEFT JOIN (
			SELECT
				a.projectid,
				SUM(a.total) AS fenbao
			FROM
				ld_customform14 a
			LEFT JOIN ld_customform14scf b ON b.customform14id = a.customform14id
			WHERE
				a.deleted = 0
			$query
			AND a.projectid > 0
			AND b.cf_3981 $date_sql group by a.projectid) g 
			ON g.projectid = project.projectid
			where project.deleted=0 $query_project group by projectid order by maoli_rate desc) as maolitable
			";

        $rate_res = $adb->pquery($rate_sql);
        $nums = $adb->num_rows($rate_res);
        $min_rate = $nums>0?$adb->query_result($rate_res,0,"min_maoli"):0.00;
        $max_rate = $nums>0?$adb->query_result($rate_res,0,"max_maoli"):0.00;
        $res['min_rate']['nums'] = number_format($min_rate*100,2) . "%";
        $res['min_rate']['name'] = "最低毛利率";
        $res['min_rate']['back_img'] = "crm_Expense.png";
        $res['min_rate']['module'] = "CustomForm14,Expense,OutboundOrder,Project";
        $res['min_rate']['label'] = "maoli_rate_min";
        $res['max_rate']['nums'] = number_format($max_rate*100,2) . "%";
        $res['max_rate']['name'] = "最高毛利率";
        $res['max_rate']['back_img'] = "crm_Expense.png";
        $res['max_rate']['module'] = "CustomForm14,Expense,OutboundOrder,Project";
        $res['max_rate']['label'] = "maoli_rate_max";
        // 产值考核指标
        $zhibiao_sql = "select sum(amount) as chanzhi,sum(sf307)as lirun 
from ld_customform22 a 
left join ld_customform22scf b on a.customform22id=b.customform22id
left join ld_customform22detail c on a.customform22id=c.id
left join ld_customform22detailscf d on c.lineitem_id=d.lineitem_id
where a.deleted=0 $query and b.cf_4033 $date_sql
";
        $zhibiao_res = $adb->pquery($zhibiao_sql);
        $nums = $adb->num_rows($zhibiao_res);
        $chanzhi = $nums>0?$adb->query_result($zhibiao_res,0,"chanzhi"):0.00;
        $res['chanzhi']['nums'] = number_format($chanzhi,2);
        $res['chanzhi']['name'] = "产值考核指标";
        $res['chanzhi']['back_img'] = "crm_ProjectProgress.png";
        $res['chanzhi']['module'] = "CustomForm22";
        $res['chanzhi']['label'] = "chanzhi_target";
        // 利润考核指标
        $lirun = $nums>0?$adb->query_result($zhibiao_res,0,"lirun"):0.00;
        $res['lirun']['nums'] = number_format($lirun,2);
        $res['lirun']['name'] = "利润考核指标";
        $res['lirun']['back_img'] = "crm_ProjectProgress.png";
        $res['lirun']['module'] = "CustomForm22";
        $res['lirun']['label'] = "lirun_target";
        // 产值考核完成率
        $res['chanzhi_rate']['nums'] = (empty($chanzhi)?0.00:number_format($servicecontracts_nums*100/$chanzhi,2)) . "%";
        $res['chanzhi_rate']['name'] = "产值考核完成率";
        $res['chanzhi_rate']['back_img'] = "crm_Documents.png";
        $res['chanzhi_rate']['module'] = "CustomForm22";
        $res['chanzhi_rate']['label'] = "chanzhi_target_rate";
        // 利润考核完成率
        $res['lirun_rate']['nums'] = (empty($lirun)?0.00:number_format($maoli*100/$lirun,2)) . "%";
        $res['lirun_rate']['name'] = "利润考核完成率";
        $res['lirun_rate']['back_img'] = "crm_Documents.png";
        $res['lirun_rate']['module'] = "CustomForm22";
        $res['lirun_rate']['label'] = "lirun_target_rate";
        return $res;
    }

    /**
     * @param $search_date
     * @param $approve_status
     * @param string $listType
     * @return array
     * @throws Exception
     * zxm
     * 2020-1202
     * 誉帆-首页排行榜
     */
    public function getRankingListData($search_date,$approve_status,$listType="hetongList")
    {
        global $adb;
        $where = "where deleted=0 ";
        //审批状态
        $where .= $this->getApproveStatusQuery();
        /*if(!empty($approve_status)&&$approve_status!="all"){
            switch($approve_status){
                case 'unapproved':	//未提交
                    $approve_name = D_A_S_UNAPPROVED;
                    break;
                case 'approving':	//审批中
                    $approve_name = D_A_S_APPROVALOF;
                    break;
                case 'approved':	//审批通过
                    $approve_name = D_A_S_APPROVED;
                    break;
                case 'rejected':	//已拒绝
                    $approve_name = D_A_S_REJECTED;
                    break;
                case 'dismissed':	//已驳回
                    $approve_name = D_A_S_DISMISSED;
                    break;
                default:
                    $approve_name = D_A_S_REJECTED;
                    break;
            }
            $where .= ' and approvestatus="'.$approve_name.'"';
        }*/
        $date_sql = getHomeDateScope($search_date);
        $result = [];
        switch($listType){
            case "hetongList":
                //customform12
                $result['thead'] = ['排名','分公司名称','合同签约额（￥）'];
                $sql = "select sum(a.total) as money,b.cf_3899 as branch_office from ld_customform12 a left join ld_customform12scf b on a.customform12id=b.customform12id $where and a.createdtime $date_sql group by b.cf_3899 order by money desc";
                break;
            case "chanzhiList":
                //ServiceContracts
                $result['thead'] = ['排名','分公司名称','产值额（￥）'];
                $sql = "select sum(a.total) as money,b.cf_3875 as branch_office from ld_servicecontracts a left join ld_servicecontractscf b on a.servicecontractsid=b.servicecontractsid $where and b.cf_3879 $date_sql group by b.cf_3875 order by money desc";
                break;
            case "maoliList":
                //项目产值减去项目成本
                $result['thead'] = ['排名','分公司名称','毛利额（￥）'];
                $chanzhi_sql = "select sum(a.total) as chanzhi,b.cf_3875 as branch_office from ld_servicecontracts a left join ld_servicecontractscf b on a.servicecontractsid=b.servicecontractsid $where and b.cf_3879 $date_sql group by branch_office";
                $cost1_sql = "select sum(a.total) as cost1,b.cf_4054 as branch_office from ld_customform14 a left join ld_customform14scf b on a.customform14id=b.customform14id $where and b.cf_3981 $date_sql group by branch_office";
                $cost2_sql = "select sum(a.total) as cost2,c.sf305 as branch_office from ld_expense a left join ld_expensedetail b on a.expenseid=b.expenseid left join ld_expensedetailscf c on b.expensedetailid=c.expensedetailid $where and expensedate $date_sql group by branch_office";
                $cost3_sql = "select sum(a.total) as cost3,b.cf_3884 as branch_office from ld_outboundorder a left join ld_outboundordercf b on a.out_id=b.out_id $where and projectid>0 and outdate $date_sql group by branch_office";
                $sql = "select (chanzhi-IFNULL(cost1,0)-IFNULL(cost2,0)-IFNULL(cost3,0)) as money,chanzhi.branch_office from ($chanzhi_sql) as chanzhi left join ($cost1_sql) a on chanzhi.branch_office=a.branch_office  left join ($cost2_sql) b on chanzhi.branch_office = b.branch_office left join ($cost3_sql) c on chanzhi.branch_office = c.branch_office order by money desc";
                break;
            case "maoliRateList":
                $result['thead'] = ['排名','分公司名称','毛利率（%）'];
                $chanzhi_sql = "select sum(a.total) as chanzhi,b.cf_3875 as branch_office from ld_servicecontracts a left join ld_servicecontractscf b on a.servicecontractsid=b.servicecontractsid $where and a.createdtime $date_sql group by branch_office";
                $cost1_sql = "select sum(a.total) as cost1,b.cf_4054 as branch_office from ld_customform14 a left join ld_customform14scf b on a.customform14id=b.customform14id $where and b.cf_3981 $date_sql group by branch_office";
                $cost2_sql = "select sum(a.total) as cost2,c.sf305 as branch_office from ld_expense a left join ld_expensedetail b on a.expenseid=b.expenseid left join ld_expensedetailscf c on b.expensedetailid=c.expensedetailid $where and expensedate $date_sql group by branch_office";
                $cost3_sql = "select sum(a.total) as cost3,b.cf_3884 as branch_office from ld_outboundorder a left join ld_outboundordercf b on a.out_id=b.out_id $where and projectid>0 and outdate $date_sql group by branch_office";
                $sql = "select (IFNULL(maoli,0)*100/chanzhi)as money,branch_office from (select (chanzhi-IFNULL(cost1,0)-IFNULL(cost2,0)-IFNULL(cost3,0)) as maoli,chanzhi,chanzhi.branch_office from ($chanzhi_sql) as chanzhi left join ($cost1_sql) a on chanzhi.branch_office=a.branch_office  left join ($cost2_sql) b on chanzhi.branch_office = b.branch_office left join ($cost3_sql) c on chanzhi.branch_office = c.branch_office) a order by money desc";
                break;
            case "shoukuanList":
                $result['thead'] = ['排名','分公司名称','收款额(￥)'];
                //CashBill
                $sql = "select sum(a.total) as money,b.cf_3757 as branch_office from ld_cashbill a left join ld_cashbillscf b on a.cashbillid=b.cashbillid $where and a.createdtime $date_sql group by b.cf_3757 order by money desc";
                break;
            default:
                //customform12
                $result['thead'] = ['排名','分公司名称','合同签约额（￥）'];
                $sql = "select sum(a.total) as money,b.cf_3899 as branch_office from ld_customform12 a left join ld_customform12scf b on a.customform12id=b.customform12id $where and a.createdtime $date_sql group by branch_office order by money desc";
                break;
        }

        $res = $adb->pquery($sql);
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

    /**
     * @param $search_date
     * @param $reportlabel
     * @return array
     * 营销报告与项目报告穿透条件拼接
     */
    public function setMarketingReportSession($search_date,$reportlabel){
        $date_arr = self::getAdvancedQueryOfDate($search_date);
        $advft_criteria = [];
        switch ($reportlabel) {
            //项目报告-只有三个需要穿透 项目产值 产值考核指标 利润考核指标
            case "chanzhi":
                $tmparr = getApprove_Query("ld_servicecontracts");
                $approve_value = $tmparr['value'];
                $modulename = 'ServiceContracts';
                $approve_columnname = "ld_servicecontracts:approvestatus:approvestatus:ServiceContracts_审批状态:V";
                $time_columnname = "ld_servicecontractscf:cf_3879:cf_3879:ServiceContracts_申报期间（产值归属期间）:D";
                break;
            case "chanzhi2":
                //ld_servicecontractscf:cf_3767:cf_3767:ServiceContracts_有无产值确认单:V
                $tmparr = getApprove_Query("ld_servicecontracts");
                $approve_value = $tmparr['value'];
                $modulename = 'ServiceContracts';
                $approve_columnname = "ld_servicecontracts:approvestatus:approvestatus:ServiceContracts_审批状态:V";
                $time_columnname = "ld_servicecontractscf:cf_3879:cf_3879:ServiceContracts_申报期间（产值归属期间）:D";
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_servicecontractscf:cf_3767:cf_3767:ServiceContracts_有无产值确认单:V",
                    'comparator' => 'e',
                    'value' => "有",
                    'columncondition' => ' and ',
                ];
                break;
            case "chanzhi_target":
            case "lirun_target":
                $tmparr = getApprove_Query("ld_customform22");
                $approve_value = $tmparr['value'];
                $modulename = 'CustomForm22';
                $approve_columnname = "ld_customform22:approvestatus:approvestatus:CustomForm22_审批状态:V";
                $time_columnname = "ld_customform22scf:cf_4033:cf_4033:CustomForm22_考核时间:D";
                break;
            //营销报告新建项目  时间，审批状态
            case "new_project":
                $tmparr = getApprove_Query("ld_project");
                $approve_value = $tmparr['value'];
                $modulename = 'Project';
                $approve_columnname = "ld_project:approvestatus:approvestatus:Project_审批状态:V";
                $time_columnname = "ld_project:createdtime:createdtime:Project_创建时间:DT";
                break;
            //新增客户   时间，审批状态
            case "new_account":
                $tmparr = getApprove_Query("ld_account");
                $approve_value = $tmparr['value'];
                $modulename = 'Accounts';
                $approve_columnname = "ld_account:approvestatus:approvestatus:Accounts_审批状态:V";
                $time_columnname = "ld_account:createdtime:createdtime:Accounts_创建时间:DT";
                break;
            //新增合同
            case "new_contract":
                $tmparr = getApprove_Query("ld_customform12");
                $approve_value = $tmparr['value'];
                $modulename = 'CustomForm12';
                $approve_columnname = "ld_customform12:approvestatus:approvestatus:CustomForm12_审批状态:V";
                $time_columnname = "ld_customform12:createdtime:createdtime:CustomForm12_创建时间:DT";
                break;
            case "have_invoice":
                $tmparr = getApprove_Query("ld_invoice");
                $approve_value = $tmparr['value'];
                $modulename = 'Invoice';
                $approve_columnname = "ld_invoice:approvestatus:approvestatus:Invoice_审批状态:V";
                $time_columnname = "ld_invoice:createdtime:createdtime:Invoice_创建时间:DT";
                break;
            case "have_cash":
                $tmparr = getApprove_Query("ld_cashbill");
                $approve_value = $tmparr['value'];
                $modulename = 'CashBill';
                $approve_columnname = "ld_cashbill:approvestatus:approvestatus:CashBill_审批状态:V";
                $time_columnname = "ld_cashbill:createdtime:createdtime:CashBill_创建时间:DT";
                break;
            case "should_cash_by_contract":
                $tmparr = getApprove_Query("ld_customform47");
                $approve_value = $tmparr['value'];
                $modulename = 'CustomForm47';
                $approve_columnname = "ld_customform47:approvestatus:approvestatus:CustomForm47_审批状态:V";
                $time_columnname = "ld_customform47scf:cf_4059:cf_4059:CustomForm47_合同条款应收日期:DT";
                break;
            case "should_cash_by_chanzhi":
                $tmparr = getApprove_Query("ld_servicecontract");
                $approve_value = $tmparr['value'];
                $modulename = 'ServiceContracts';
                $approve_columnname = "ld_servicecontracts:approvestatus:approvestatus:ServiceContracts_审批状态:V";
                $time_columnname = "ld_servicecontractscf:cf_3879:cf_3879:ServiceContracts_产值申报期间:DT";
                break;
            case "should_cash_over_three":
                $tmparr = getApprove_Query("ld_customform47");
                $approve_value = $tmparr['value'];
                $modulename = 'CustomForm47';
                $approve_columnname = "ld_customform47:approvestatus:approvestatus:CustomForm47_审批状态:V";
                $time_columnname = "ld_customform47scf:cf_4059:cf_4059:CustomForm47_合同条款应收日期:DT";
                break;
            default:
                $approve_value = "";
                $time_columnname = "";
                $modulename = "";
                $approve_columnname = "";
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
}