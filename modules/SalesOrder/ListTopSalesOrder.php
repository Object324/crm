<?php
/***
 * AUTHOR:BY  zxm
 * DATE:20200903
 * DESCRIPTION:近六个月目标完成情况
 * param $data_type 销售指标值
 * param $senioruserid 用户范围 用户id 如1，2，3
 */
/*function getCompanySixMonthSalesRate($scopeType,$senioruserid=0,$data_type="contractamount",$stuffid,$boardid,$boardstuffid){
    // 销售指标默认值“contractamount” 签约额
    global $adb,$current_language;
    $system_351 = getSys_deploy(351);
    $system_deploy_351 = 2;
    if(is_numeric($system_351['deploy_value'])){
        $system_deploy_351 = $system_351['deploy_value'];
    }
    $month_num = '6';   //月份数，最近六个月故而取6
    $now_date = date('Y-n-d', strtotime(date('Y-n-01') . ' +1 month -1 day'));
    $last_date = date('Y-n',strtotime('-'. ($month_num - 1) . ' month')).'-01';
    $yearmonth = [];
    //edit: xll 2023/08/04 BUG0070635 目标为设置导致月份丢失问题
    for($i=1; $i <= $month_num; $i++){
        $tmp_month = date('Y-n',strtotime(date('Y-m').' -'. ($month_num - $i) . ' month'));
        $yearmonth[] = $tmp_month;
    }
    //记住页签
    setUsersettingByLabel('SalesGoal','','CompanySixMonthSalesRate_SalesGoal',$_REQUEST['targetid']);
    // 先求目标
    $salesgoal_arr = getSalesGoalListInfo($data_type,$last_date,$now_date,$scopeType,$yearmonth);
    $salestarget = $salesgoal_arr['Target'];
    $salesgoal_done = $salesgoal_arr['Done'];
    $targetModule = $salesgoal_arr['SalesGoalInfo']['modulename'];
    $targetid = $salesgoal_arr['SalesGoalInfo']['targetid'];
    //根据销售指标判断 返回不同数据
    $userid_arr = explode(',',$senioruserid);
    $res = [];
    //edit: xll 2023/08/04 BUG0070635 目标为设置导致月份丢失问题
    foreach($yearmonth as $key => $tmp_month){
        $res['month'][$tmp_month] = $tmp_month;
        $tmp_target_data = 0.00;
        $tmp_done_data = 0.00;
        $tmp_rate_data = 0.00;
        foreach($salestarget[$targetModule] as $userid=>$usertarget){
            //edit: xll 2024/04/01 BUG20240329-61 目标管理设置客户模块对象的指标，最近六个月没有目标值
            if($targetModule !== 'Users' || in_array($userid,$userid_arr)){
                $monthtarget = $usertarget[$tmp_month];
                $tmp_target_data += $monthtarget;
            }
        }
        $tmp_target_data = round($tmp_target_data,$system_deploy_351);
        foreach($salesgoal_done as $userid=>$userdone){
            $monthdone = $userdone[$tmp_month];
            $tmp_done_data += $monthdone;
        }
        $tmp_done_data = round($tmp_done_data,$system_deploy_351);
        $tmp_rate_data = $tmp_target_data<=0?(($tmp_done_data >= 0) ? 100 : 0) : round($tmp_done_data*100 /$tmp_target_data,$system_deploy_351);

        $res['target'][$tmp_month] = $tmp_target_data;
        $res['done'][$tmp_month] = $tmp_done_data;
        $res['rate'][$tmp_month] = $tmp_rate_data;
    }

    foreach($res['month'] as &$month){
        $month = (int)substr($month,5);
        if($current_language == 'en'){
            $month= DateOperation::getCaldate($month);
        }else{
            $month= $month.'月';
        }
    }

    $res['month'] = array_values($res['month']);
    $res['target'] = array_values($res['target']);
    $res['done'] = array_values($res['done']);
    $res['rate'] = array_values($res['rate']);
    $modstatic = new SalesGoalNew();
    $res['indicator_unit'] = $modstatic->getIndicatorUnitLabel($targetid);
    return ['ModuleName'=>'companySixMonthSalesRate','Entries'=>$res];
}**/

/***
 * AUTHOR:BY  xll
 * DATE:2023/08/08
 * DESCRIPTION:目标完成率仪表盘
 * param $data_type 销售指标值
 * param $senioruserid 用户范围 用户id 如1，2，3
 */
/**
function getTargetCompletionRate($scopeType,$senioruserid=0,$data_type="contractamount",$stuffid,$boardid,$boardstuffid){
    // 销售指标默认值“contractamount” 签约额
    global $adb;
    $system_351 = getSys_deploy(351);
    $system_deploy_351 = 2;
    if(is_numeric($system_351['deploy_value'])){
        $system_deploy_351 = $system_351['deploy_value'];
    }
    $search_date = $_REQUEST['search_date'];
    if($search_date=='custom')$search_date=$_REQUEST['date_custom'];
    $search_date_arr = getHomeDateArray($search_date);
    $starttime = $search_date_arr[0];
    $starmonth = date('Y-n',strtotime($starttime));
    $endtime = (isset($search_date_arr[1])) ? $search_date_arr[1] : $search_date_arr[0];
    $endmonth = date('Y-n',strtotime($endtime));
    $yearmonth = [$starmonth,$endmonth];

    $now_date = date('Y-m-d', strtotime($endtime));
    $last_date = date('Y-m-d',strtotime($starttime));
    //记住页签
    setUsersettingByLabel('SalesGoal','','TargetCompletionRate_SalesGoal',$_REQUEST['targetid']);
    // 先求目标
    $salesgoal_arr = getSalesGoalListInfo($data_type,$last_date,$now_date,$scopeType,$yearmonth);
    $salestarget = $salesgoal_arr['Target'];
    $salesgoal_done = $salesgoal_arr['Done'];
    $targetid = $salesgoal_arr['SalesGoalInfo']['targetid'];

    $res = [];
    $res['target'] = 0.00;
    $res['done'] = 0.00;
    $res['undone'] = 0.00;
    $res['rate'] = 0.00;
    $tmp_target_data = 0.00;
    $tmp_done_data = 0.00;
    //edit: xll 2023/10/06 BUG0073290 成员“hxg”并没有设置相应的目标管理指标，但首页-目标完成率却显示其目标值。
    //目标值收查看范围影响，只循环查看范围内的用户id
    if(isset($salestarget['Users'])) {
        $userid_arr = explode(',', $senioruserid);
        foreach ($userid_arr as $userid) {
            if (isset($salestarget['Users'][$userid]))
                foreach ($salestarget['Users'][$userid] as $tmp_month => $monthtarget) {
                    $tmp_target_data += $monthtarget;
                }
        }
    }
    //edit: xll 2024/03/07 指标对象为客户管理、产品管理时，数据不显示
    else {
        foreach ($salestarget as $module => $targetInfo) {
            foreach ($targetInfo as $record => $info) {
                foreach ($info as $tmp_month => $monthtarget) {
                    $tmp_target_data += $monthtarget;
                }
            }
        }
    }
    $tmp_target_data = round($tmp_target_data,$system_deploy_351);
    foreach($salesgoal_done as $userid=>$userdone){
        foreach($userdone as $tmp_month=>$monthdone){
            //if(in_array($tmp_month,$search_date_arr))
                $tmp_done_data += $monthdone;
        }
    }
    $tmp_done_data = round($tmp_done_data,$system_deploy_351);
    $modstatic = new SalesGoalNew();
    $indicator_unit_label= $modstatic->getIndicatorUnitLabel($targetid);
    $res['target'] = $tmp_target_data;
    $res['done'] = $tmp_done_data;
    if($res['target'] > 0) {
        $res['undone'] = $tmp_target_data - $tmp_done_data;
    }
    //edit: xll 2024/06/01 BUG 超额完成是，未完成改为0
    if($res['undone'] < 0) {
        $res['undone'] = 0;
    }
    $res['undone'] = round($res['undone'],$system_deploy_351);
    $setStuffDataFormatarr = ['target','done','undone'];
    foreach ($setStuffDataFormatarr as $tmpkey){
        $res[$tmpkey] =  $res[$tmpkey].$indicator_unit_label;
    }
    $res['rate'] = ($tmp_target_data<=0) ? (($tmp_done_data >= 0) ? 100 : 0) : round($tmp_done_data*100 /$tmp_target_data,$system_deploy_351);

    return ['ModuleName'=>'TargetCompletionRate','Entries'=>$res];
}*/
/***
 * AUTHOR:BY  xll
 * DATE:2023/08/08
 * DESCRIPTION:获取销售目标的目标值与完成值
 * param $data_type 销售指标值
 * param $senioruserid 用户范围 用户id 如1，2，3
 */
function getSalesGoalListInfo($data_type,$last_date,$now_date,$scopeType,$yearmonth){
    global $adb;
    require_once globalStatic::$root_directory.'modules/SalesGoal/SalesGoalNew.class.php';
    $SalesGoalNewObj = new SalesGoalNew();
    //设置其数据范围为目标管理模块
    $SalesGoalNewObj->set_cur_module('SalesGoal');
    $SalesGoalNewObj->setUnitExist('yes');
    $SalesGoalNewObj->setSelectUserIds($_REQUEST['selectuid']);
    //获取targetid
    $targetnums = 0;
    if(isset($_REQUEST['targetid']) && !empty($_REQUEST['targetid'])){
        $targetid = $_REQUEST['targetid'];
        $targetnums = 1;
    }else{
        $targetbasicsql = "select targetid from ld_salestarget_basic where targetname=? ";
        $targetbasicres = $adb->pquery($targetbasicsql,array($data_type));
        $targetnums = $adb->num_rows($targetbasicres);
        $targetid = ($targetnums > 0) ? $adb->query_result($targetbasicres,0,'targetid') : null;
    }
    $salestarget = [];
    if($targetnums>0){
        $salestarget = $SalesGoalNewObj->getSalesGoalToLook(array($last_date,$now_date),$targetid);
		$SalesgoalInfo = $SalesGoalNewObj->getSalesGolaInfoByid($targetid);
		 //移动端的用户范围需要特殊处理
        if($_REQUEST['selectuid'] == 'all')
            $scopeType = 'SmOwner_Search_All';
        $record_info = $SalesGoalNewObj->GetRecordInfo($SalesgoalInfo,$scopeType);
        $SalesGoalNewObj->filterTargetRes($record_info,$salestarget);
        $salesgoal_done = $SalesGoalNewObj->getSalesGoalOverInfo($targetid,$yearmonth,$record_info) ;
    }
    return array('Target'=>$salestarget,'Done'=>$salesgoal_done,'SalesGoalInfo'=>$SalesgoalInfo);
}



