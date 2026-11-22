<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user;

//editor:gyq_133 reason:微信小程序，增加首页标签  2019/7/23 17:37 ID1000575
//editor:gyq_138 reason:迅达别墅梯首页  2019/8/23 10:30
crm_load_class_file('home_page_control','WeiXinApp/modules/Home/controller');

crm_load_class_file('WorkReportControllerWX','WeiXinApp/modules/Home');
$report_focus = new WorkReportControllerWX();
$settingData = $report_focus->getCRMSetting('home');

$focus = new home_page_control();
$version = getVersionInfo();
$boardtype = 'MobileReport';
if($current_user->user_type=='prm'){
    $boardtype = 'prmMobileHome';
}
//zxm 20231019 获取看板列表
crm_load_class_file("VisualAnalysisBoardList",'modules/VisualAnalysis');
$boardlistobj = new VisualAnalysisBoardList($boardtype,'All');
$homeboard_list = $boardlistobj -> getBoardListByType();
$boardid_arr = array_keys($homeboard_list);
crm_load_class_file("Homeboard", 'modules/Home');
$Homeboardobj = Homeboard::getInstance(0,'MobileReport');
//zxm 20231019 获取当前选中的看板
$selected_homeboardid = $_REQUEST['selected_homeboardid'];//这个参数是切换看板的时候才传
//没切换看板的话直接读取上次选中的看板
if(!empty($selected_homeboardid)){
    $homeboardid = $selected_homeboardid;
    $Homeboardobj->save_history_homeboard($homeboardid);
}else{
    $homeboardid = $Homeboardobj->get_history_homeboard();//获取上次选中的看板id
    $homeboardid = empty($homeboardid)?$boardid_arr[0]:$homeboardid;//没有值则默认显示默认看板
}
if(!in_array($homeboardid,$boardid_arr)){
    //BUG20240708-36 如果选中的看板 之后又不给权限了  默认显示有权限的第一个看板
    $homeboardid = $boardid_arr[0];
}
if($current_user->user_type=='prm'){
    //PRM用户一定要访问prm看板  prm看板一定会有
    $homeboardid = $boardid_arr[0];
}
//zxm  2021-11-26 zxm 首页默认时间可设置 如果传过来的时间条件为空 则取数据库的默认值
if(empty($_REQUEST['reporttype'])&&$homeboardid<=0){
    $system_deploy = getSys_deploy('345');
    $_REQUEST['reporttype'] = empty($system_deploy['deploy_value'])?'thismonth':$system_deploy['deploy_value'];
}

if($version['account'] == 'xdzg'){//迅达别墅梯首页
    $list = $focus->home_xdzg();
    $out = array('list'=>$list,'setting'=>$settingData['setting']);
    //ConvertTojsonString(1,$out ,'success');
}
elseif($version['account'] == 'xysj'){//兴业数金
    $list = $focus->home_xysj();
    $out = array('list'=>$list,'setting'=>$settingData['setting']);
}
elseif($version['account'] == 'yufan'){//誉帆
    $_REQUEST['scopeType'] = 'smowner_search_senior';
    $list = $focus->home_page();
    $yufan = $focus->home_yufan();
    $list['list1'] = array_merge_recursive($list['list1'],$yufan);
    $out = array('list'=>$list,'setting'=>$settingData['setting']);
}
// edit: xll : 2024/04/09 BUG20240509-09 工程项目行业demo 始终显示默认看板，无法显示自定义新看板，注释
/*
else if($version['trade'] == 'construction'){//zxm 2021-0128 工程项目行业demo
    $_REQUEST['scopeType'] = 'smowner_search_senior';
    $list = $focus->home_page();
    $yufan = $focus->home_construction();
    $list['list1'] = array_merge_recursive($list['list1'],$yufan);
    $out = array('list'=>$list,'setting'=>$settingData['setting']);
}
*/
else if($version['account'] == 'yichong'){
    $_REQUEST['scopeType'] = 'smowner_search_senior';
    $yichong = $focus->home_yichong();
    $list = $focus->home_page();
    $list['list1'] = array_merge_recursive($list['list1'],$yichong);
    $out = array('list'=>$list,'setting'=>$settingData['setting']);
}
else{
    //editor:gyq_141 reason:移动端增加首页标签  2019/9/6 14:30 ID1000602
    $_REQUEST['scopeType'] = 'smowner_search_senior';
    if($homeboardid>0){
        //zxm 20231019 新看板
        $list = $focus->home_pageboard($homeboardid);
    }else{
        $list = $focus->home_page();
        // edit: xll : 2024/04/09 BUG20240509-09 工程项目行业demo 始终显示默认看板
        if($version['trade'] == 'construction'){//zxm 2021-0128 工程项目行业demo
            $_REQUEST['scopeType'] = 'smowner_search_senior';
            $construction = $focus->home_construction();
            $constructionListOrder = array_keys($construction);
            $list['list1'] = array_merge_recursive($list['list1'],$construction);
            //把排序值也放到listorder中 方便前端循环
            $list['listorder'] = array_merge_recursive($list['listorder'],$constructionListOrder);
        }
    }
    $out = array('list'=>$list,'setting'=>$settingData['setting']);
}
$out['homeboard_list'] = array_values($homeboard_list);
$out['homeboardid'] = $homeboardid;//当前选中的看板id
//zxm 20221207 成员基本信息 头像 名字 公司 职位等

crm_load_class_file('UsersUtils','modules/Users');
$UsersUtilsObj = new UsersUtils();
$out['setting']['userinfo'] = $UsersUtilsObj->getCrmUserInfo($current_user->id);
$out['setting']['userinfo']['profilename'] = $current_user->getUserOfProfileName();
$out['arrFixedLabel'] = getHomepageFixedlabel();
$out['arrFixedLabelDateApprove'] = getDateApproveFixedlabel();
ConvertTojsonString(1,$out ,'success');

//工作台翻译文本
function getHomepageFixedlabel(){
    global $MobileLanguageType;
    $homepage_label_arr = array();
    $homepage_label_arr=array(
        'RANKINGLOWTOHIGH',//排名从低到高
        'RANKINGHIGHTOLOW',//排名从高到低
        'HOMEPAGE',//首页
        'BULLETINBOARD',//看板
        'VIEWRANGE',//查看范围
        'nodata',//没有数据
        'SaleDragonTiger',//销售龙虎榜
        'SLAESORDERTOTAL',//总额
        'APPWORKBENCH',//工作台
        'APPFUNCTION',//功能
        'staydo',//待办
        'OFTENUSEREPORTWORD',//报表
        'APPSETTINGS',//设置
        'CRITICALVIEW',//关键视图
        'Quickly_create',//快速创建
        'CURRENTBLOCKCANNOTVIEW',//当前区块无法查看详情
        'QUANTITY',//数量
        'THOUSAND',//千
        'MILLION1',//百万
        'BILLION',//十亿
        'TILLION',//万亿
        'AMOUNT',//金额
        'prevfy',//去年
        'CURYEAR',//今年
        'Frequency',//次数
        'SELECTUSER1',//选择用户
        'CUSTOMTIME',//自定义时间
        'SALESORDERTOTAL',//合同金额
        'INVOICEAMOUNT',//开票金额
        'AMOUNTTO',//收款金额
        'OUTPUTVALUE',//产值
        'Costp',//成本
        'GROSSPROFIT',//毛利
        'GROSSMARGIN',//毛利率
        'TOTAL1',//总量
        'CANNOTOPENINMOBILE',//当前模块移动端无法打开
        'CODEINFORMATIONINVALID',//当前扫码信息无效
        'VERSIONLOWPLEASEUPGRADE',//版本过低请升级
        'SUCCESSFULLYCALLED',//成功调用
        'MarketingReport',//营销报告
        'MarketingCompareReport',//营销对比报告
        'ProjectReport',//项目报告
        'ProjectCompareReport',//项目对比报告
        'RankingListReport',//排行榜
        'JANUARY',//一月
        'FEBRUARY',//二月
        'MARCH',//三月
        'APRIL',//四月
        'MAY',//五月
        'JUNE',//六月
        'JULY',//七月
        'AUGUST',//八月
        'SEPTEMBER',//九月
        'OCTOBER',//十月
        'NOVEMBER',//十一月
        'DECEMBER',//十二月
        'NO',//否
        'YES',//是
        'MORE',//更多
        'COMMONLYUSED',//常用
        'COMPLETIONVALUE',//完成值
        'TOLOOKVALUE',//目标值
        'SET',//设置
        'COMPLETIONRATE',//完成率
        'recentModule',//最近使用
        'highFrequency',//高频使用
        'commonmodules'//常用模块
        );
    $homepage_fixedlabel_arr = TransFieldlabel($homepage_label_arr);
    if($MobileLanguageType == 'en'){
        $homepage_fixedlabel_arr['SLAESORDERTOTAL'] .= ':';
        $homepage_fixedlabel_arr['Special_price_home'] = '* K:'.getFixedLabel('THOUSAND').',M:'.getFixedLabel('MILLION1').',G:'.getFixedLabel('BILLION').',T:'.getFixedLabel('TILLION');
    }else{
        $homepage_fixedlabel_arr['SLAESORDERTOTAL'] .= '：';
        $homepage_fixedlabel_arr['Special_price_home'] = '* K:'.getFixedLabel('THOUSAND').'，M:'.getFixedLabel('MILLION1').'，G:'.getFixedLabel('BILLION').'，T:'.getFixedLabel('TILLION');
    }
    //将中文的一月转化为1月
    $month_label_arr = array('JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE','JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER');
    $count = 0;
    foreach($month_label_arr as $tmp_label){
        $count ++;
        if($MobileLanguageType == 'zh'){
            $homepage_fixedlabel_arr[$tmp_label] = $count.getFixedLabel('nMonth');
        }
    }
    return $homepage_fixedlabel_arr;
}
//首页日期和审批条件组件翻译
function getDateApproveFixedlabel(){
    $label_arr=array(
        'ALL',//全部
        'Days',//天
        'today',//今天
        'syesterday',//昨天
        'Week',//周
        'thisweek',//本周
        'lastweek',//上周
        'nMonth',//月
        'thismonth',//本月
        'lastmonth',//上月
        'QUARTER',//季
        'thisfq',//本季度
        'prevfq',//上季度
        'nYear',//年
        'thisyear1',//本年度
        'lastyear1',//上年度
        'custom',//自定义
        'Start_Date',//开始日期
        'End_Date',//结束日期
        'PLEASESELECTENDDATE',//请选择结束日期
        'PLEASESELECTSTARTDATE',//请选择开始日期
        'approvestatus',//审批状态
        'CONFIRMED',//确定
        'CANCEL',//取消
        'Unapproved',//未提交
        'Approvalof',//审批中
        'Approved',//已批准
        'Rejected',//已拒绝
        'Dismissed',//已驳回
        'CUSTOMTIME',//自定义时间
        'STARTDATENOTBEEMPTY',//开始日期不能为空
        'ENDDATENOTBEEMPTY',//结束日期不能为空
        'STARTDATECANOTGREATERENDDATEAPP',//开始日期不能大于结束日期！
    );
    $dateapprove_fixedlabel_arr = TransFieldlabel($label_arr,'no');
    return $dateapprove_fixedlabel_arr;
}
?>