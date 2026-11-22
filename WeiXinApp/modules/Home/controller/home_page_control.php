<?php
//editor:gyq_138 reason:迅达别墅梯首页  2019/8/23 10:26
crm_load_class_file('WorkReportControllerWX','WeiXinApp/modules/Home');
class home_page_control extends WorkReportControllerWX
{
    public function __construct() {
        crm_load_class_file('home_page_model','WeiXinApp/modules/Home/cls_Home');
        $this->model = new home_page_model();
    }
    //标准版本首页
    //editor:gyq_141 reason:移动端增加首页标签  2019/9/5 9:37 ID1000602
    public function home_page(){
        global $adb,$MobileLanguageType;
        global $current_user;
        crm_load_class_file('cls_ReportDetailInfoWX','WeiXinApp/modules/Dashboard');
        crm_load_class_file('cls_Home_SpecialMC','appCommon/modules/Home');
        //zsk 2024/3/12 XUQIU1002414 看板交互优化:获取记忆值
        //增加根据用户审批状态设置,获取记忆值功能
        if (empty($userid)) $userid=$current_user->id;
        $adb_select_board2 = 'select content from ld_module_setting_byuser where type = ? and userid = ? and label="lastChangeApproveByUser"';
        $result_select_board2 = $adb->pquery($adb_select_board2,array('-100',$userid));
        if($adb->num_rows($result_select_board2)>0){
            $approve_value = $adb->query_result($result_select_board2, 0, 'content');
        }
        if(!empty($approve_value)) {
            $_REQUEST['approve_value'] =$approve_value;
        }
        //增加根据用户时间范围设置,获取记忆值功能
        $adb_select_board2 = 'select content from ld_module_setting_byuser where type = ? and userid = ? and label="lastChangeTimeByUser"';
        $result_select_board2 = $adb->pquery($adb_select_board2,array('-100',$userid));
        //如果用户记忆值是自定义时间范围,读取具体时间范围
        if($adb->num_rows($result_select_board2)>0){
            $timeSearchDefault= $adb->query_result($result_select_board2, 0, 'content');
            if (strpos($timeSearchDefault, 'custom') !== false) {
                // 如果包含custom
                list($prefix, $dates) = explode(':', $timeSearchDefault, 2);
                $timeSearchDefault=$prefix;
                $customData=$dates;
            }
        }
        //zsk 2024/3/12 XUQIU1002414 看板交互优化:获取记忆值
        $_REQUEST['reporttype'] = empty($timeSearchDefault)?$_REQUEST['reporttype']:$timeSearchDefault;//看板的时间默认值
        if($timeSearchDefault=='custom'){
            $_REQUEST['custom_data']=$customData;
        }
        //增加根据用户查看范围设置,获取记忆值功能
        $adb_select_board2 = 'select content from ld_module_setting_byuser where type = ? and userid = ? and label="lastChangeSearchScopeByUser"';
        $result_select_board2 = $adb->pquery($adb_select_board2,array('-100',$userid));
        $Homeboard_content['selectedSearchScope']='';
        $Homeboard_content['customSearchScopeValue']='';
        if($adb->num_rows($result_select_board2)>0){
            $selectedSearchScope = $adb->query_result($result_select_board2, 0, 'content');
        }
        //zsk 2024/3/12 XUQIU1002414 看板交互优化:获取记忆值
        if(!empty($selectedSearchScope)&&$selectedSearchScope!='') {
            $_REQUEST['selectuid'] = $selectedSearchScope;
        }
        //editor:gyq_159 reason:系统设置增加移动端报表菜单定制  2019/11/8 17:21 ID1000638
        //有权限可显示的移动端报表
        $available_list_one = cls_Home_SpecialMC::getWXReportList();
        $available_list_two = array();
        foreach ($available_list_one as $key1=>$value1){
            foreach ($value1['list'] as $key2=>$value2){
                $available_list_two[$value2['orign_name']] = $value2;
            }
        }
        $reportobj = new cls_ReportDetailInfoWX(null);
        $reportobj->getselectuid();

        $selectusersid = $reportobj->selectuid;
        $selectusersidarr = explode(',',$selectusersid);
        $home_users = getCurSmOwnerSearchScope('Home');
        $home_users = array_keys($home_users['UserCombo']);
        $home_select_userid = implode(',',array_intersect($home_users,$selectusersidarr));

        if (isset($_REQUEST['scopeType']) && $_REQUEST['scopeType'] != '') {
            $reportobj->scopeType = $_REQUEST['scopeType'];
        }
        //暂只显示销售漏斗
        $sql = 'SELECT id,NAME,graphtype,modulenames,image,labelbol,home_presence,home_sequence
        FROM ld_dashboard_app WHERE home_presence=\'yes\' order by home_sequence asc ';

        $result = $adb->pquery($sql,array());
        $nums = $adb->num_rows($result);
        $list = array();
        $listorder = [];

        $output = array();
        if($nums > 0){
            for($i=0;$i<$nums;$i++){
                $reportname = $adb->query_result($result,$i,'name');
                $labelbol = $adb->query_result($result,$i,'labelbol');
                $reportid=$adb->query_result($result,$i,'id');
                if(!array_key_exists($reportname,$available_list_two)&&($reportname!='keyViews'&&$reportname!='customreportblock'&&$reportname!='commonmodules')){
                    continue;
                }
                //salesdragontiger|Saleskit|Salesfunnel|Contractkit|Returnamount|
                if ($reportname == 'commonmodules'){//常用模块记住之前的选择
                    $moduleUsage_type = getUsersettingByLabel('Users',$current_user->id,'ModuleUsageType');
                    $reportname = empty($moduleUsage_type)?'commonmodules':$moduleUsage_type;
                    $list['type'] = $reportname;
                    $list['typelist'] = ['commonmodules','recentModule','highFrequency'];
                }
                $getreportname = 'get'.$reportname;
                $reportList = $reportobj->$getreportname();
                //关键视图、自定义报表区块返回内容为空时跳过，不传至前端
                if(empty($reportList))continue;

                $list[$reportname] = $reportList;
                //关键视图、自定义报表区块不传此参数
                if($reportname!='customreportblock')
                {
                    $list[$reportname]['label'] = getFixedLabel($labelbol);
                    $list[$reportname]['reportid'] = $list[$reportname]['reportid']>0?$list[$reportname]['reportid']:$reportid;
                }
                //常用模块增加更多文本标签
                if($reportname == 'commonmodules'){
                    $list[$reportname]['morelabel'] = getFixedLabel('MORE');
                    $deployarr_13 = getAppsys_deploy(13);
                    $is_open13 = ($deployarr_13 != '') ? $deployarr_13['is_open'] : 'no';
                    $morelabel_icon = ($is_open13 == 'yes') ? 'crm2022_2/crm_more.png' : 'crm2022/crm_more.png';
                    $list[$reportname]['morelabel_icon'] = $morelabel_icon;
                }

                $contentHeight = 300;
                //销售漏斗 原来的图高度240
                if($reportname == 'Salesfunnel'){
                    $contentHeight = 240;
                }
                //销售阶段转化分析 原来的高度500
                if($reportname == 'SalesPhaseTransformationAnalysis'){
                    $contentHeight = 500;
                }
                $contentOutHeight = $contentHeight+20;
                $list[$reportname]['reportHeightinfo'] = ['titleHeight'=>30,'contentPadT'=>10,'contentPadB'=>10,'contentOutHeight'=>$contentOutHeight,'contentHeight'=>$contentHeight];//XUQIU20240613-05 移动端工作台定制--增加组件高度设置，可以自由设置组件高度
                $list[$reportname]['reportname'] = $reportname;
                $listorder[] = $reportname;
            }
        }
        $output['listorder'] = $listorder;

        $output['list1'] = $list;
        //zxm 20231127 默认看板返回审批条件默认值
        $output['selectuid']=$home_select_userid;
        $output['timescope']=$_REQUEST['reporttype'];
        $output['approve_value']=$_REQUEST['approve_value'];
        $output['approve_value_arr'] = ['unapproved','approving','approved','rejected','dismissed'];
        $Group_Special = crm_load_class_obj('Group_Special','modules/Users');
        $userinfoArr = $Group_Special->getuserinfoStr($home_select_userid);
        if($MobileLanguageType == 'en'){
            $userinfoArr['label']=getFixedLabel('VIEWRANGE').':';
        }else{
            $userinfoArr['label']=getFixedLabel('VIEWRANGE').'：';
        }
        
        $output['userinfo']=$userinfoArr;
        $time_range = $reportobj->set_filter_time_range();
        $output['time_range'] =$time_range;

        // diony 2023-09-21 水印
        crm_load_class_file('MenuUtils','modules/Users');
        $MenuUtilsObj = new MenuUtils();
        $watermark_txt = $MenuUtilsObj->getwatermark_setting();
        $output['watermark_txt'] =$watermark_txt;
        
        //待办   zxm 2020-0302
        /*include(globalStatic::$root_directory.'modules/CustomView/ListViewTop.php');
        $_REQUEST['SearchScope'] = 'SmOwner_Search_All';
        $_REQUEST['report_name'] = "keyViews";
        $keyViews = getKeyMetrics('','SmOwner_Search_All','','yes');
        foreach($keyViews as &$v){
            $v['name'] = getTranstab($v['module']).'-'.$v['name'];
        }
        $output['list1']['keyViews'] = $keyViews;
        */
		
        return $output;
    }
    //新看板的数据
    public function home_pageboard($homeboardid){
        global $adb,$MobileLanguageType,$current_user;
        $output = array();
        $list = array();
        $listorder = array();//用来排序的
        //为了不改变以前的方法  这里stufftitle去对应组件方法
        $stufftitletofunctionname = [
            'AMOUNTMONTHCONTRACTYEAR'=>'Contractamount',
            'BACKAMOUNTMONTHYEAR'=>'Returnamount',
            'SALESFUNNEL'=>'Salesfunnel',
            'saleskit'=>'Saleskit',
            'CUSTOMERSOURCEDISSTATIST'=>'Accountleadsource',
            'CUSTOMERTYPEDISSTATIS'=>'Accountaccounttype',
            'SaleDragonTiger'=>'salesdragontiger',
            'CRITICALVIEW'=>'keyViews'
        ];
        crm_load_class_file('cls_ReportDetailInfoWX','WeiXinApp/modules/Dashboard');
        crm_load_class_file('cls_Home_SpecialMC','appCommon/modules/Home');

        //获取看板中组件列表
        crm_load_class_file("Homeboard", 'modules/Home');
        $Homeboardobj = Homeboard::getInstance($homeboardid,'MobileReport');
        $Homeboard_content = $Homeboardobj->get_Homeboard_info($homeboardid);
        //zsk 2024/3/12 XUQIU1002414 看板交互优化:获取记忆值
        if(!empty($Homeboard_content['selectedSearchScope'])&&$Homeboard_content['selectedSearchScope']!='') {
            $_REQUEST['selectuid'] = $Homeboard_content['selectedSearchScope'];
        }
        if(!empty($Homeboard_content['approve_value'])) {
            $_REQUEST['approve_value'] =$Homeboard_content['approve_value'];
        }
        $reportobj = new cls_ReportDetailInfoWX(null);
        $reportobj->getselectuid();

        $selectusersid = $reportobj->selectuid;
        $selectusersidarr = explode(',',$selectusersid);
        $home_users = getCurSmOwnerSearchScope('Home');
        $home_users = array_keys($home_users['UserCombo']);
        $home_select_userid = implode(',',array_intersect($home_users,$selectusersidarr));

        $reportobj->setBoardId($homeboardid);
        if (isset($_REQUEST['scopeType']) && $_REQUEST['scopeType'] != '') {
            $reportobj->scopeType = $_REQUEST['scopeType'];
        }
        //zxm BUG0075114   kfbcrm-移动端-工作台-修改时间查看范围，刷新界面，没有根据看板设置的默认时间值变化
        //zsk 2024/3/12 XUQIU1002414 看板交互优化:获取记忆值
        $_REQUEST['reporttype'] = empty($Homeboard_content['timesearchdefault'])?$_REQUEST['reporttype']:$Homeboard_content['timesearchdefault'];//看板的时间默认值
        if($Homeboard_content['timesearchdefault']=='custom'){
            $_REQUEST['custom_data']=$Homeboard_content['customDateValue'];
        }
        $output['approve_value_arr'] = ['unapproved','approving','approved','rejected','dismissed'];
        if(isset($Homeboard_content['homeboard_plate'][0]['homeboard_plate_stuff'])){
            $stufflist = $Homeboard_content['homeboard_plate'][0]['homeboard_plate_stuff'];

            foreach($stufflist as $stuffinfo){
                $stuffid = $stuffinfo['stuffid'];
                $stufftitle = $stuffinfo['stufftitle'];
                $stufftype = $stuffinfo['stufftype'];
                $stufflisttype = $stuffinfo['stufflisttype'];
                $tmplabel = $MobileLanguageType=='zh'?$stuffinfo['stufftitle_zh']:$stuffinfo['stufftitle_en'];

                if($stufflisttype=='customreport'&&$stufftype=='sqlchart'){
                    $_REQUEST['fromhome']='yes';
                    $reportname = 'sqlchart_'.$stuffid;
                    //SQL统计图
                    include_once globalStatic::$root_directory . 'modules/CustomEcharts/CustomEchartsActions.php';
                    $CustomEchartsActionsObj = new CustomEchartsActions($_REQUEST);
                    $CustomEchartsActionsObj->setToolboxShow('no');//设置工具栏不显示
                    $CustomEchartsActionsObj->setHomeParams([
                        'boardid' => $homeboardid,
                        'boardstuffid' => $stuffinfo['boardstuffid'],
                        'scopeType' => $reportobj->scopeType,
                        'selectuid' => $home_select_userid,
                        'approve_value' => !empty($Homeboard_content['approve_value'])?$Homeboard_content['approve_value']:'all',
                        'search_date' => $_REQUEST['reporttype'],
                        'date_custom' => $_REQUEST['custom_data'],
                    ]);
                    $reportList = $CustomEchartsActionsObj->getSqlDetailData($stuffid);
                    if(empty($reportList))continue;

                    $list[$reportname] = $reportList;

                    $list[$reportname]['label'] = empty($tmplabel)?$stufftitle:$tmplabel;
                    $list[$reportname]['reportid'] = $stuffid;
                    $listorder[] = $reportname;


                }
                else if($stufflisttype=='customreport'&&$stufftype=='chart'){
                    $_REQUEST['fromhome']='yes';
                    $reportname = 'chart_'.$stuffid;
                    //自定义统计图
                    include_once globalStatic::$root_directory.'modules/CustomEcharts/EchartReport.php';
                    $EchartReportObj = new EchartReport($_REQUEST);
                    $EchartReportObj->setToolboxShow('no');//设置工具栏不显示
                    $EchartReportObj->setHomeParams([
                        'boardid' => $homeboardid,
                        'boardstuffid' => $stuffinfo['boardstuffid'],
                        'scopeType' => $reportobj->scopeType,
                        'selectuid' => $home_select_userid,
                        'approve_value' => !empty($Homeboard_content['approve_value'])?$Homeboard_content['approve_value']:'all',
                        'search_date' => $_REQUEST['reporttype'],
                        'date_custom' => $_REQUEST['custom_data'],
                    ]);
                    $reportList = $EchartReportObj->generalReportChart($stuffid);
                    if(empty($reportList))continue;
                    $list[$reportname]['data'] = $reportList['data'];
                    //穿透需要的数据
                    crm_load_class_file('cls_ChartSetInfo','modules/CustomEcharts');
                    $ChartSetInfoObj = cls_ChartSetInfo::getInstance($stuffid,'');
                    $ChartSetInfoObj->setChartInfo($reportList['data']);
                    $ChartSetInfo = $ChartSetInfoObj->getChartSetInfo();
                    $list[$reportname]['ChartSetInfo'] = $ChartSetInfo;

                    $list[$reportname]['label'] = empty($tmplabel)?$stufftitle:$tmplabel;
                    $list[$reportname]['reportid'] = $stuffid;
                    $listorder[] = $reportname;
                }
                else{
                    $reportname = isset($stufftitletofunctionname[$stufftitle])?$stufftitletofunctionname[$stufftitle]:$stufftitle;
                    //默认组件
                    if ($reportname == 'commonmodules'){//常用模块记住之前的选择
                        $moduleUsage_type = getUsersettingByLabel('Users',$current_user->id,'ModuleUsageType');
                        $reportname = empty($moduleUsage_type)?'commonmodules':$moduleUsage_type;
                        $list['type'] = $reportname;
                        $list['typelist'] = ['commonmodules','recentModule','highFrequency'];
                    }
                    $getreportname = 'get'.$reportname;

                    $reportList = $reportobj->$getreportname();
                    if(empty($reportList))continue;
                    $list[$reportname] = $reportList;
                    //关键视图、自定义报表区块不传此参数
                    if($reportname!='customreportblock')
                    {
                        $list[$reportname]['label'] = empty($tmplabel)?getFixedLabel($stufftitle):$tmplabel;
                        $list[$reportname]['reportid'] = $stuffid;
                    }
                    //常用模块增加更多文本标签
                    if($reportname == 'commonmodules'){
                        $list[$reportname]['morelabel'] = getFixedLabel('MORE');
                        $deployarr_13 = getAppsys_deploy(13);
                        $is_open13 = ($deployarr_13 != '') ? $deployarr_13['is_open'] : 'no';
                        $morelabel_icon = ($is_open13 == 'yes') ? 'crm2022_2/crm_more.png' : 'crm2022/crm_more.png';
                        $list[$reportname]['morelabel_icon'] = $morelabel_icon;
                    }

                    $listorder[] = $reportname;
                }
                //不控制高度的组件：简报
                $tmpContentHeight = (int)$stuffinfo['height'] - 50;//组件标题给30 组件内容上下边距给10

                //销售漏斗 原来的图高度240
                if($reportname == 'Salesfunnel'){
                    $contentHeight = 240;
                }
                //销售阶段转化分析 原来的高度500
                if($reportname == 'SalesPhaseTransformationAnalysis'){
                    $contentHeight = 500;
                }
                //天地：销售漏斗  原来的高度400 TD_PotentialsFunnel
                if($reportname == 'TD_PotentialsFunnel'){
                    $contentHeight = 400;
                }

                $contentOutHeight = $tmpContentHeight+20;
                //参数依次是：标题高度,内容上边距，下边距，内容带边距高度，内容不带边距高度---参考盒模型高度
                $list[$reportname]['reportHeightinfo'] = ['titleHeight'=>30,'contentPadT'=>10,'contentPadB'=>10,'contentOutHeight'=>$tmpContentHeight+20,'contentHeight'=>$tmpContentHeight];//XUQIU20240613-05 移动端工作台定制--增加组件高度设置，可以自由设置组件高度
                $list[$reportname]['reportname'] = $reportname;
            }
        }

        $output['listorder'] = $listorder;
        $output['list1'] = $list;
        $Group_Special = crm_load_class_obj('Group_Special','modules/Users');
        $userinfoArr = $Group_Special->getuserinfoStr($home_select_userid);
        if($MobileLanguageType == 'en'){
            $userinfoArr['label']=getFixedLabel('VIEWRANGE').':';
        }else{
            $userinfoArr['label']=getFixedLabel('VIEWRANGE').'：';
        }
        $output['userinfo']=$userinfoArr;
        //zsk 2024/3/12 XUQIU1002414 看板交互优化
        $output['selectuid']=$home_select_userid;
        $output['timescope']=$_REQUEST['reporttype'];
        if(!empty($Homeboard_content['approve_value'])) {
            $output['approve_value'] =$Homeboard_content['approve_value'];
        }
        $time_range = $reportobj->set_filter_time_range();
        $output['time_range'] =$time_range;
        // diony 2023-09-21 水印
        crm_load_class_file('MenuUtils','modules/Users');
        $MenuUtilsObj = new MenuUtils();
        $watermark_txt = $MenuUtilsObj->getwatermark_setting();
        $output['watermark_txt'] =$watermark_txt;
        return $output;
    }
    //迅达别墅梯首页
    public function home_xdzg(){
        $static_report = array('SalesFunnelReport','ClueSourceReport','CluedistributionReport','FailureAnalysisReport');
        crm_load_class_file('cls_ReportDetailInfoWX','WeiXinApp/modules/Dashboard');

        $module_users = getCurSmOwnerSearchScope('Home');
        $userids = array_keys($module_users['UserCombo']);
        $where = ' in ('.implode(',',$userids).') ';

        $data_list = $this->model->home_xdzg_($where);
        //线索签约表
        $xdzg_cluesigning['label'] = '线索签约表';
        $xdzg_cluesigning['legend'] = array('线索', '签约');
        $xdzg_cluesigning['display'] = 'yes';//如果线索、签约都为0，返回no
        $xdzg_cluesigning['series_data1'] = $data_list['xdzg_cluesigning'][0];
        $xdzg_cluesigning['series_data2'] =  $data_list['xdzg_cluesigning'][1];
        $list['xdzg_cluesigning'] = $xdzg_cluesigning;
        //销售完成情况
        $xdzg_salesinfo['label'] = '销售完成情况';
        $xdzg_salesinfo['legend'] = array('认购台量', '已完成台量');
        $xdzg_salesinfo['display'] = 'yes';//如果认购台量、已完成台量都为0，返回no
        $xdzg_salesinfo['series_data1'] = $data_list['xdzg_salesinfo'][0];
        $xdzg_salesinfo['series_data2'] = $data_list['xdzg_salesinfo'][1];
        $list['xdzg_salesinfo'] = $xdzg_salesinfo;
        //销售简报
        $xdzg_briefing['label'] = '销售简报';
        $xdzg_briefing['data1'] = array($data_list['xdzg_briefing']['Accounts']['label'],$data_list['xdzg_briefing']['Accounts']['number'],
                            $data_list['xdzg_briefing']['Potentials']['label'],$data_list['xdzg_briefing']['Potentials']['number']) ;
        $xdzg_briefing['data2'] = array($data_list['xdzg_briefing']['Project']['label'],$data_list['xdzg_briefing']['Project']['number'],
                            $data_list['xdzg_briefing']['ProjectTask']['label'],$data_list['xdzg_briefing']['ProjectTask']['number']) ;
        $list['xdzg_briefing'] = $xdzg_briefing;
        //其他四个报表 SalesFunnelReport ClueSourceReport CluedistributionReport FailureAnalysisReport
        $detailObj = new cls_ReportDetailInfoWX(null);
        foreach ($static_report as $key=>$value){
            $list['xdzg_'.str_replace('report','',strtolower($value))] =  $detailObj->report_detail($value);
        }
        //商机失败原因分析
        $cell_report_info['list'] = $data_list['failure_potential'];
        $cell_report_info['list']['legend'] =  '商机失败原因分析';;
        $cell_report_info['name'] = '失败分析';
        $list['xdzg_failure_potential'] = $cell_report_info;
        return $list;
    }
    //兴业数金
    public function home_xysj(){
        global $adb,$current_user;
        //兴业数金：待办事项
        $sql = 'select
              idnum,cf_2847 idtype
              from
              (select
                  count(con.contactrecordID) idnum,
                  concf.cf_2847
                from ld_contactrecords con
                  left join ld_contactrecordscf concf on con.contactrecordID = concf.contactrecordid
                where concf.cf_2838 = \'待处理\' or concf.cf_2838 = \'处理中\' and con.smownerid=? and con.deleted=0
                group by cf_2847
               union all
               select
                  count(customform01id) idnum,
                  \'提醒事件\' as cf_2847
                from ld_customform01
                where state = \'待处理\' and smownerid=? and deleted=0 ) as a where a.idnum > 0';
        $result = $adb->pquery($sql,array($current_user->id,$current_user->id));
        $list['todoitems'] = $this->home_page_list($result,'ContactRecords');
        //兴业数金：我的零售客户
        $sql = 'select count(a.accountid) idnum,b.important_level idtype from ld_account a
              left join ld_accountscf b on a.accountid = b.accountid
            where a.account_type = \'零售客户\' and a.deleted=0 and a.servicecasher = ?
            group by b.important_level';
        $result = $adb->pquery($sql,array($current_user->id));
        $list['retail'] = $this->home_page_list($result,'ServiceCharge');
        //兴业数金：我的公司客户
        $sql = 'select count(a.accountid) idnum,b.important_level idtype from ld_account a
              left join ld_accountscf b on a.accountid = b.accountid
            where a.account_type = \'公司客户\' and a.deleted=0 and a.smownerid = ?
            group by b.important_level';
        $result = $adb->pquery($sql,array($current_user->id));
        $list['company'] = $this->home_page_list($result,'Accounts');
        //兴业数金：商机统计
        $sql = 'select count(potentialid) idnum  from ld_potential
          where deleted=0 and smownerid=? and sales_stage<>\'成功结案\' and sales_stage <> \'失败结案\'';
        $result = $adb->pquery($sql,array($current_user->id));
        $amount = $adb->query_result($result,0,'idnum');
        $sql2 = 'select count(a.accountid) idnum from ld_account a
              left join ld_accountscf b on a.accountid = b.accountid
            where a.account_type in (\'零售客户\',\'公司客户\') and b.cf_2865=\'线索客户\'
                  and a.deleted=0 and a.smownerid = ?';
        $result2 = $adb->pquery($sql2,array($current_user->id));
        $amount2 = 0;
        if($adb->num_rows($result2) > 0){
            $amount2 = $adb->query_result($result2,0,'idnum');
        }
        $shangji['label'] = '商机统计';
        $list4[] = array('name'=>'商机数','value'=>$amount);
        $list4[] = array('name'=>'线索数','value'=>$amount2);
        $shangji['data'] = $list4;
        $list['shangji'] = $shangji;
        return $list;
    }
    //誉帆 2020-12-16 zxm
    public function home_yufan(){
        crm_load_class_file('cls_ReportDetailInfoWX','WeiXinApp/modules/Dashboard');
        $reportobj = new cls_ReportDetailInfoWX(null);
        $reportobj->getselectuid();
        include globalStatic::$root_directory.'modules/Home/CustomMade/YufanUtils.php';
        $YufanUtilsObj = new YufanUtils();
        //去计算营销报告数据
        if($_REQUEST['selectuid'] == 'all'){
            $selectuid = $reportobj->selectuid;
        }else{
            $selectuid = $_REQUEST['selectuid'];
        }
        //营销报告
        $marketingData = $YufanUtilsObj->getMarketingReport($_REQUEST['reporttype'],$selectuid,$selectuid,'');
        $list['Yufan_MarketingReport']['list'][] = array_shift($marketingData);
        $list['Yufan_MarketingReport']['list'][] = array_shift($marketingData);
        $list['Yufan_MarketingReport']['list1'] = array_values($marketingData);
        $list['Yufan_MarketingReport']['label'] = '营销报告';
        // 项目报告
        $projectData = $YufanUtilsObj->getProjectReport($_REQUEST['reporttype'],$selectuid,$selectuid,'');
        $list['Yufan_ProjectReport']['list'] = array_values($projectData);
        $list['Yufan_ProjectReport']['label'] = '项目报告';
        //营销对比报告
        $marketingCompareData = $YufanUtilsObj->getSixMonthMarketingReport($selectuid,$selectuid);
        $list['Yufan_MarketingCompareReport']['list'] = $marketingCompareData;
        $list['Yufan_MarketingCompareReport']['label'] = '营销对比报告';
        //项目对比报告
        $projectCompareData = $YufanUtilsObj->getSixMonthProjectReport($selectuid,$selectuid);
        $list['Yufan_ProjectCompareReport']['list'] = $projectCompareData;
        $list['Yufan_ProjectCompareReport']['label'] = '项目对比报告';
        // 排行榜
        //tab
        $rankingListTab = array(
            ['id'=>'1','label'=>'合同签约排行榜','rankingType'=>'hetongList'],
            ['id'=>'2','label'=>'产值排行榜','rankingType'=>'chanzhiList'],
            ['id'=>'3','label'=>'毛利排行榜','rankingType'=>'maoliList'],
            ['id'=>'4','label'=>'毛利率排行榜','rankingType'=>'maoliRateList'],
            ['id'=>'5','label'=>'收款排行榜','rankingType'=>'shoukuanList']
        );
        $list['Yufan_RankingListReport']['hetongList'] = $YufanUtilsObj->getRankingListData($_REQUEST['reporttype'],'all',"hetongList");
        $list['Yufan_RankingListReport']['chanzhiList'] = $YufanUtilsObj->getRankingListData($_REQUEST['reporttype'],'all',"chanzhiList");
        $list['Yufan_RankingListReport']['maoliList'] = $YufanUtilsObj->getRankingListData($_REQUEST['reporttype'],'all',"maoliList");
        $list['Yufan_RankingListReport']['maoliRateList'] = $YufanUtilsObj->getRankingListData($_REQUEST['reporttype'],'all',"maoliRateList");
        $list['Yufan_RankingListReport']['shoukuanList'] = $YufanUtilsObj->getRankingListData($_REQUEST['reporttype'],'all',"shoukuanList");
        $list['Yufan_RankingListReport']['label'] = '排行榜';
        $list['Yufan_RankingListReport']['rankingListTab'] = $rankingListTab;
        return $list;
    }
    //工程项目行业账套demo zxm 2021-0128
    public function home_construction()
    {
        crm_load_class_file('cls_ReportDetailInfoWX','WeiXinApp/modules/Dashboard');
        $reportobj = new cls_ReportDetailInfoWX(null);
        $reportobj->getselectuid();
        include globalStatic::$root_directory.'modules/Home/CustomMade/ConstructionUtils.php';
        $ConstructionUtilsObj = new ConstructionUtils();
        //去计算营销报告数据
        if($_REQUEST['selectuid'] == 'all'){
            $selectuid = $reportobj->selectuid;
        }else{
            $selectuid = $_REQUEST['selectuid'];
        }
        //营销报告
        $marketingData = $ConstructionUtilsObj->getMarketingReportData($_REQUEST['reporttype'],$selectuid,$selectuid,'');
        $list['Yufan_MarketingReport']['list'][] = array_shift($marketingData);
        $list['Yufan_MarketingReport']['list'][] = array_shift($marketingData);
        $list['Yufan_MarketingReport']['list1'] = array_values($marketingData);
        $list['Yufan_MarketingReport']['label'] = '营销报告';
        // 项目报告
        $projectData = $ConstructionUtilsObj->getProjectReportData($_REQUEST['reporttype'],$selectuid,$selectuid,'');
        $list['Yufan_ProjectReport']['list'] = array_values($projectData);
        $list['Yufan_ProjectReport']['label'] = '项目报告';
        //营销对比报告
        $marketingCompareData = $ConstructionUtilsObj->getMarketingCompareReportData($_REQUEST['reporttype'],$selectuid,$selectuid,'');
        $list['Yufan_MarketingCompareReport']['list'] = $marketingCompareData;
        $list['Yufan_MarketingCompareReport']['label'] = '营销对比报告';
        //项目对比报告
        $projectCompareData = $ConstructionUtilsObj->getProjectCompareReportData($_REQUEST['reporttype'],$selectuid,$selectuid,'');
        $list['Yufan_ProjectCompareReport']['list'] = $projectCompareData;
        $list['Yufan_ProjectCompareReport']['label'] = '项目对比报告';
        // 排行榜
        //tab
        $rankingListTab = array(
            ['id'=>'1','label'=>'合同签约排行榜','rankingType'=>'hetongList'],
            ['id'=>'2','label'=>'产值排行榜','rankingType'=>'chanzhiList'],
            ['id'=>'3','label'=>'毛利排行榜','rankingType'=>'maoliList'],
            ['id'=>'4','label'=>'毛利率排行榜','rankingType'=>'maoliRateList'],
            ['id'=>'5','label'=>'收款排行榜','rankingType'=>'shoukuanList']
        );
        $list['Yufan_RankingListReport']['hetongList'] = $ConstructionUtilsObj->getRankingListReportData($_REQUEST['reporttype'],'all','all','',"hetongList");
        $list['Yufan_RankingListReport']['chanzhiList'] = $ConstructionUtilsObj->getRankingListReportData($_REQUEST['reporttype'],'all','all','',"chanzhiList");
        $list['Yufan_RankingListReport']['maoliList'] = $ConstructionUtilsObj->getRankingListReportData($_REQUEST['reporttype'],'all','all','',"maoliList");
        $list['Yufan_RankingListReport']['maoliRateList'] = $ConstructionUtilsObj->getRankingListReportData($_REQUEST['reporttype'],'all','all','',"maoliRateList");
        $list['Yufan_RankingListReport']['shoukuanList'] = $ConstructionUtilsObj->getRankingListReportData($_REQUEST['reporttype'],'all','all','',"shoukuanList");
        $list['Yufan_RankingListReport']['label'] = '排行榜';
        $list['Yufan_RankingListReport']['rankingListTab'] = $rankingListTab;
        //收支报告
        $list['Yufan_IncomeAndExpenditureReport']['reportid'] = '65';
        $list['Yufan_IncomeAndExpenditureReport']['label'] = '收支报告';
        $IncomeAndExpenditureReportData= $ConstructionUtilsObj->getIncomeAndExpenditureReportData($_REQUEST['reporttype'],$selectuid,$selectuid,'');
        $list['Yufan_IncomeAndExpenditureReport']['list'] = array_values($IncomeAndExpenditureReportData);
        return $list;
    }
    //yichong zxm 2021-0224
    public function home_yichong(){
        crm_load_class_file('cls_ReportDetailInfoWX','WeiXinApp/modules/Dashboard');
        $reportobj = new cls_ReportDetailInfoWX(null);
        $reportobj->getselectuid();
        include globalStatic::$root_directory.'modules/Home/CustomMade/YichongUtils.php';
        $YichongUtilsObj = new YichongUtils();
        //去计算营销报告数据
        if($_REQUEST['selectuid'] == 'all'){
            $selectuid = $reportobj->selectuid;
        }else{
            $selectuid = $_REQUEST['selectuid'];
        }
        $list['Yichong_Saleskit']['list'] = $YichongUtilsObj->getMarketingOfYichong($selectuid,$selectuid,$_REQUEST['reporttype']);
        $list['Yichong_Saleskit']['label'] = '销售简报';
        return $list;
    }
    //home_page子方法
    public function home_page_list($result,$r_module){
        global $adb;
        $num = $adb->num_rows($result);
        $total_amount_1 = 0;
        $list_1 = array();
        $list_1_name = array();
        for($i=0;$i<$num;$i++){
            $list_1[$i]['amount'] = $amount = $adb->query_result($result,$i,'idnum');
            $total_amount_1 += $amount;
            $list_1[$i]['type'] = $adb->query_result($result,$i,'idtype');
        }
        foreach ($list_1 as $key=>$value){
            $list_1[$key] = array(
                'name'=>$value['type'].'('.$value['amount'].')  '.(setNumberFormat($value['amount']/$total_amount_1,3)*100).'%',
                'value'=>$value['amount']
            );
            $list_1_name[] =   $list_1[$key]['name'];
        }
        $list_out = array(
            'label'=>'我的'.getTranstab($r_module),
            'count'=>$total_amount_1,
            'name'=>$list_1_name,
            'data'=>$list_1
        );
        return $list_out;
    }
}