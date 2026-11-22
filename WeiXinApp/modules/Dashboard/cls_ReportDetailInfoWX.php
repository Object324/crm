<?php
/**
 * 微信端使用的方法，放在这里面，避免与app冲突
 */
crm_load_class_file('cls_ReportDetailInfoMC','appCommon/detail');
class cls_ReportDetailInfoWX extends cls_ReportDetailInfoMC
{
    public $report_name;
    public $ModuleIcon;
    public $moduleUsageInfo;
    public function getCommonSearchCondition(){
        $name = $this->reportInfo['name'];
        $searchwhere = array();
        //查看范围
        $searchscope['fieldlabel'] = getFixedLabel('VIEWRANGE');
        $searchscope['fieldname'] = 'selectuid';
        $searchscope['option'][] = array('text'=>getFixedLabel('ALL'),'value'=>'all','select'=>'yes');
        if($this->reportInfo['graphtype']==2){
            $searchscope['option'][] = array('text'=>getFixedLabel('REIMBURSED'),'value'=>'me','select'=>'no');
        }
        $searchscope['option'][] = array('text'=>getFixedLabel('LBL_SENIOR'),'value'=>'smowner_search_senior','select'=>'no');
        $searchwhere[] = $searchscope;
        //时间范围
        $rangedatearr['fieldlabel'] = getFixedLabel('TIMEANGE');
        $rangedatearr['fieldname'] = 'reporttype';
        $rangedatearr['option'][] = array('text'=>getFixedLabel('checktoday'),'value'=>'today','select'=>'no');
        $rangedatearr['option'][] = array('text'=>getFixedLabel('checkyesterday'),'value'=>'syesterday','select'=>'no');
        $rangedatearr['option'][] = array('text'=>getFixedLabel('thisweek'),'value'=>'week','select'=>'no');
        $rangedatearr['option'][] = array('text'=>getFixedLabel('lastmonth'),'value'=>'lastmonth','select'=>'no');
        $rangedatearr['option'][] = array('text'=>getFixedLabel('thismonth'),'value'=>'month','select'=>'yes');
        $rangedatearr['option'][] = array('text'=>getFixedLabel('thisfy'),'value'=>'year','select'=>'no');
        $rangedatearr['option'][] = array('text'=>getFixedLabel('ALL'),'value'=>'all','select'=>'no');
        $searchwhere[] = $rangedatearr;
        //审批状态
        $modules = explode(',',$this->reportInfo['modulenames']);
        $approvepermit = false;
        foreach($modules as $val){
            $deployarray = getSys_Approvedeploy($val);
            if($deployarray['deploy_value']==0){
                $approvepermit = true;
                break;
            }
        }
        if($approvepermit){
            $approvestatus['fieldlabel'] = getFixedLabel('approvestatus');
            $approvestatus['fieldname'] = 'applovetype';
            $approvestatus['option'][] = array('text'=>getFixedLabel('ALL'),'value'=>'all','select'=>'yes');
            $approvestatus['option'][] = array('text'=>getFixedLabel('Approved'),'value'=>'approved','select'=>'no');
            $searchwhere[] = $approvestatus;
        }elseif($name=='cashbillamount'){
            $approvestatus['fieldlabel'] = getFixedLabel('Auditstatus');
            $approvestatus['fieldname'] = 'applovetype';
            $approvestatus['option'][] = array('text'=>getFixedLabel('ALL'),'value'=>'all','select'=>'yes');
            $approvestatus['option'][] = array('text'=>getFixedLabel('Audited'),'value'=>'approved','select'=>'no');
            $searchwhere[] = $approvestatus;
        }
        return $searchwhere;
    }
    //editor:gyq_126 reason:迅达别墅梯特殊开发  2019/6/20 16:12
    public function report_detail($r_name){
        $this->report_name = $r_name;
        $module_users = getCurSmOwnerSearchScope('MobileReport');
        $userids = array_keys($module_users['UserCombo']);
        $where = ' and a.smownerid in ('.implode(',',$userids).') ';

        return $this->$r_name($where);
    }
    //销售漏斗
    protected function SalesFunnelReport($r_where){
        global $adb;
        $leadsource = $_REQUEST['leadsource'];
        if(!empty($leadsource) && $leadsource != 'all'){
            $r_where .= ' and a1.leadsource=\''.$leadsource.'\'';
        }
        $sql = 'select \'线索\' as name,count(a.accountid) as number,\'Accounts\' as module_name,smownerid as useid,a1.leadsource
        from ld_account a
          INNER JOIN ld_accountscf a1 on a.accountid=a1.accountid
          where a.deleted=0 and a.publicaccount=0 '.$r_where.'
        union all
        select \'商机\' as name,count(a.potentialid) as number,\'Potentials\' as module_name,a.smownerid as useid,a1.leadsource
        from ld_potential  a
          INNER JOIN ld_accountscf a1 on a.accountid=a1.accountid
          INNER JOIN ld_account a2 on a.accountid=a2.accountid
          where a.deleted=0 and a2.deleted=0 '.$r_where.'
        union all
        select \'签约\' as name,count(projectid) as number,\'Project\' as module_name,a.smownerid as useid,a1.leadsource
        from ld_project  a
          INNER JOIN ld_accountscf a1 on a.accountid=a1.accountid
          INNER JOIN ld_account a2 on a.accountid=a2.accountid
          where a.deleted=0 and a2.deleted=0 '.$r_where.'
        union all
        select \'OIT\' as name,count(projecttaskid) as number,\'ProjectTask\' as module_name,a.smownerid as useid,a1.leadsource
        from ld_projecttask  a
          INNER JOIN ld_accountscf a1 on a.accountid=a1.accountid
          INNER JOIN ld_account a2 on a.accountid=a2.accountid
          where a.deleted=0 and a2.deleted=0 '.$r_where.'
        union all
        select \'到货\' as name,count(projectprogressid) as number,\'ProjectProgress\' as module_name,a.smownerid as useid,a1.leadsource
        from ld_projectprogress  a
          inner JOIN ld_projecttask p on a.projecttaskid=p.projecttaskid
          INNER JOIN ld_accountscf a1 on p.accountid=a1.accountid
          INNER JOIN ld_account a2 on a1.accountid=a2.accountid
          where p.deleted=0 and  a.deleted=0 and a2.deleted=0 '.$r_where;
        $result = $adb->pquery($sql,array());
        $nums = $adb->num_rows($result);
        $account_num = 0;
        for($i=0;$i<$nums;$i++){
            $module_label = $adb->query_result($result,$i,'name');
            $module = $adb->query_result($result,$i,'module_name');
            $number = $adb->query_result($result,$i,'number');
            if($module=='Accounts'){
                $account_num = $number;
            }
            $list[$i] = array(
                'name'=>getTranstab($module),
                'value'=>$module,
                'percent'=>round($number/$account_num*100,2),
                'number'=>$number
            );
        }
        $output = array('list'=>$list,'title'=>array(),'leadsource'=>'all');
        $output['name'] = getFixedLabel('SALESFUNNEL');
        return $output;
    }
    //线索来源
    protected function ClueSourceReport($r_where){
        global $adb;
        $sql = 'select smownerid as useid,count(a.accountid) as number
                from ld_account a where deleted=0 '.$r_where;
        $result = $adb->pquery($sql,array());
        $total_number = $adb->query_result($result,0,'number');
        $sql = 'select smownerid as useid,a1.leadsource,count(a.accountid) as number
                from ld_account a
                  INNER JOIN ld_accountscf a1 on a.accountid=a1.accountid
                where deleted=0 '.$r_where.' GROUP BY a1.leadsource ';
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        for($i=0;$i<$num;$i++){
            $number = $adb->query_result($result,$i,'number');
            $leadsource = $adb->query_result($result,$i,'leadsource');
            $list[$i] = array(
                'name'=>$leadsource,
                'value'=>$number,
                'percent'=>round($number/$total_number*100,2),
                'module'=>'Accounts'
            );
        }
        $output = array('list'=>$list);
        $output['name'] = getFixedLabel('LEADSOURCE');
        return $output;
    }
    //线索分布
    public function CluedistributionReport($r_where){
        global $adb;
        $sql = 'select smownerid as useid,count(a.accountid) as number
                from ld_account a 
                INNER JOIN ld_accountscf a1 on a.accountid=a1.accountid  
                where deleted=0  '.$r_where;
        $result = $adb->pquery($sql,array());
        $total_number = $adb->query_result($result,0,'number');
        $sql = 'select smownerid as useid,count(a.accountid) as number,ld_users.last_name
                from ld_account a
                INNER JOIN ld_accountscf a1 on a.accountid=a1.accountid  
                left join ld_users on smownerid=ld_users.id
                where  a.deleted=0  '.$r_where.' GROUP BY smownerid ';
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        $list = array();
        for($i=0;$i<$num;$i++){
            $number = $adb->query_result($result,$i,'number');
            $last_name = $adb->query_result($result,$i,'last_name');
            $useid = $adb->query_result($result,$i,'useid');
            $list[$i] = array(
                'name'=>$last_name,
                'value'=>$number,
                'percent'=>round($number/$total_number*100,2),
                'module'=>'Accounts',
                'hidden_value'=>$useid
            );
        }
        $output = array('list'=>$list);
        $output['name'] = getFixedLabel('LEADDISTRYBUTION');
        return $output;
    }
    //失败分析
    public function FailureAnalysisReport($r_where){
        global $adb;
        $where = str_replace('a.','a2.',$r_where);
        //editor:gyq_138 reason:迅达别墅梯首页  2019/8/23 14:05
        $sql = 'select a.smownerid,sum(a.cc) as sum_a,sum(a.sd) as sum_b,sum(a.dh) as sum_c,sum(a.qt) as sum_d from (
                select a2.smownerid,
                (case when cf_2915=1 then 1 else 0 end) as cc,
                (case when cf_2919=1 then 1 else 0 end) as sd,
                (case when cf_2923=1 then 1 else 0 end) as dh,
                (case when cf_2925=1 then 1 else 0 end) as qt
                 from ld_accountscf a1
                INNER JOIN ld_account a2 on a1.accountid=a2.accountid
                where DATE_FORMAT(a2.createdtime, \'%Y\') = DATE_FORMAT(NOW(), \'%Y\')
                '.$where.'
                ) as a ';
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        $list = array();
        for($i=0;$i<$num;$i++){
            $list['尺寸']= $adb->query_result($result,$i,'sum_a');
            $list['速度']= $adb->query_result($result,$i,'sum_b');
            $list['非单户家庭']= $adb->query_result($result,$i,'sum_c');
            $list['其他']= $adb->query_result($result,$i,'sum_d');
        }
        arsort($list);
        $output['list'] = array(
            'data'=>array_values($list),
            'name'=>array_keys($list),
            'legend'=>getFixedLabel('FAILUREANALYSIS1')
        );
        $output['name'] = getFixedLabel('FAILUREANALYSIS');
        return $output;
    }
    //editor:gyq_130 reason:微信新增合同简报  2019/7/10 11:38 ID1000554
    public function getContractkit()
    {
        global $adb;
        $versiontrade=getVersionTradeInfo();
        $trade = $versiontrade['trade'];
        //日期依据
        $order_time_range = '1=1';
        //合同日期signed_data,收款日期cashbilldate,发货日期lastoutbounddate,开票日期lastinvoicedate
        //zxm 20230529 合同简报 日期依据变量名为contractkitdate
        if(empty($_REQUEST['contractkitdate'])){
            $date_type = 'signed_data';
        }else{
            $date_type = $_REQUEST['contractkitdate'];
        }
        //editor:gyq_141 reason:移动端增加首页标签  2019/9/5 15:51 ID1000602
        //editor:gyq_160 reason:梳理移动端报表的时间区间获取方法  2019/11/13 13:46 ID1000640
        if($_REQUEST['reporttype']=="custom"){
            //zxm 2021-0113【移动端首页界面，时间查询范围中增加“自定义时间”选项】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001000289
            $custom_data = $_REQUEST['custom_data'];
        }else {
            $custom_data = $_REQUEST['reporttype'];
        }
        $time_range = cls_StaticCommonFun::getTimeRange($custom_data, 'string');
        if(!empty($time_range)){
            $order_time_range = $date_type.' '.$time_range;
        }
        $report_list  = array();
        $list_i = 0;


        $selectuid = $this->selectuid;
        $selectuid_arr = explode(',',$selectuid);
        $scopemodule = 'SalesOrder';//先写死吧 没办法了  合同的数据范围 跟传过来的数据范围 做一个交集
        crm_load_class_file('cls_ScopOfAuthority','modules/lingdang/cls_Report');
        $ModuleScopeObj = new cls_ScopOfAuthority($adb, $scopemodule);
        $ModuleScopeObj->setParams('SmOwner_Search_All', '');
        $SearchUserId_scopemodule = $ModuleScopeObj->getCurUserScopeIds();
        $SearchUserId_scopemodule_arr = explode(',',$SearchUserId_scopemodule);
        $SearchUserId_arr = array_intersect($selectuid_arr,$SearchUserId_scopemodule_arr);
        $SearchUserId = empty($SearchUserId_arr)?'':implode(',',$SearchUserId_arr);
        //$this->selectuid = $SearchUserId;
        //客户联系人end******************
        //合同订单
        if(vtlib_isModuleActive('SalesOrder')) {
            $field_list = array(
                'received_amount'=>'sum_have_rece','receivable_balance'=>'sum_nothave_rece',
                'have_invoicetotal'=>'sum_have_invo','nothave_invoicetotal'=>'sum_nothave_invo',
                'haveoutboundcount'=>'sum_have_boundcount','balanceoutboundcount'=>'sum_nothave_boundcount',
                'haveoutboundamount'=>'sum_have_boundamount','balanceoutboundamount'=>'sum_nothave_boundamount');
            $field_list_label = array(
                'received_amount'=>array('text'=>getFixedLabel('RECEIVEAPPS'),'img'=>'crm_CashBill.png') ,
                'have_invoicetotal'=>array('text'=>getFixedLabel('INVOICEAPP'),'img'=>'crm_PaymentPlan.png'),
                'haveoutboundcount'=>array('text'=>getFixedLabel('DELIVERYAPP'),'img'=>'crm_SendPayment.png'),
                'haveoutboundamount'=>array('text'=>getFixedLabel('DELIVERYAPP'),'img'=>'crm_SendPayment.png'));
            $datescolumnname = array(
                'signed_data'=>array('selected'=>'no'),
                'cashbilldate'=>array('selected'=>'no'),
                'lastoutbounddate'=>array('selected'=>'no'),
                'lastinvoicedate'=>array('selected'=>'no')
            );

            $focus=CRMEntity::getInstance("SalesOrder");
            
            //duan 移动端首页增加审批条件查询
            $tmp_approvesql = $this->getApproveSql('SalesOrder');

            $report_list[$list_i]['name'] = getFixedLabel('ORDER');
            $report_list[$list_i]['imgname'] = 'crm_SalesOrder.png';

            if ($trade == 'zhongfu') {
                $query = 'select count(1) as cnt from ld_salesorder where ' . $order_time_range . ' '.$tmp_approvesql.'  and ifnull(ld_salesorder.approvestatus,"") = \'已批准\' and (IFNULL(ld_salesorder.sostatus,"") = \'合同已签\' or IFNULL(ld_salesorder.sostatus,"") = \'不签合同\') and deleted = 0 and smownerid in (' . $SearchUserId . ')';
            } else {
                $query = 'select count(1) as cnt from ld_salesorder where ' . $order_time_range . ' '.$tmp_approvesql.' and ifnull(sostatus,"") != \'已作废\' and deleted = 0 and smownerid in (' . $SearchUserId . ')';
            }
            //$query .= " and ifnull(total,0)!=0 ";
            $result = $adb->pquery($query, array());
            if ($adb->num_rows($result) > 0) {
                $total_order = $adb->query_result($result, 0, 'cnt');
            } else
                $total_order = 0;

            $amount_sql = 'select
          sum(if(currency_id >1,IFNULL(total,0)/conversion_rate,IFNULL(total,0))) as sum_total,
         sum(if(currency_id>1,ifnull(received_amount,0)/conversion_rate,ifnull(received_amount,0))) sum_have_rece,
          sum(if(currency_id>1,ifnull(receivable_balance,0)/conversion_rate,ifnull(receivable_balance,0))) sum_nothave_rece ,
          sum(if(currency_id>1,ifnull(have_invoicetotal,0)/conversion_rate,ifnull(have_invoicetotal,0))) sum_have_invo,
          sum(if(currency_id>1,ifnull(nothave_invoicetotal,0)/conversion_rate,ifnull(nothave_invoicetotal,0))) sum_nothave_invo,
          sum(ifnull(haveoutboundcount,0)) sum_have_boundcount,
          sum(ifnull(balanceoutboundcount,0)) sum_nothave_boundcount,
          sum(if(currency_id>1,ifnull(haveoutboundamount,0)/conversion_rate,ifnull(haveoutboundamount,0))) sum_have_boundamount,
          sum(if(currency_id>1,ifnull(balanceoutboundamount,0)/conversion_rate,ifnull(balanceoutboundamount,0))) sum_nothave_boundamount
        from ld_salesorder ';
            if ($trade == 'zhongfu') {
                $amount_sql .= " where $order_time_range $tmp_approvesql and deleted=0 and ifnull(ld_salesorder.approvestatus,\"\") = '已批准' and (IFNULL(ld_salesorder.sostatus,'') = '合同已签' or IFNULL(ld_salesorder.sostatus,'') = '不签合同') and smownerid in ($SearchUserId)";
            } else {
                $amount_sql .= " where $order_time_range $tmp_approvesql and deleted=0 and sostatus<>'已作废' and smownerid in ($SearchUserId)";
            }
            $amount_result = $adb->pquery($amount_sql, array());
            if ($adb->num_rows($amount_result) > 0) {
                //签约金额签约数量
                $report_list[$list_i]['list'] = array(
                    array(
                    'content'=>$total_order.'<span style="font-size:13px;color:#999">个</span>',
                    'describe'=>getFixedLabel('CONTRACTQUANTITY'),'module'=>'SalesOrder',
                        'second_para'=>json_encode(array('amount_field'=>'total','date_field'=>$date_type))
                        ,'second_action'=>'contractkit_list_json'),
                    array(
                        'content' => '¥'.setNumberFormat($adb->query_result($amount_result, 0, 'sum_total'),$this->length_amountdecimal),
                        'describe' => getFixedLabel('CONTRACTAMOUNTPANEL'),'module'=>'SalesOrder',
                        'second_para'=>json_encode(array('amount_field'=>'total','date_field'=>$date_type)),
                        'second_action'=>'contractkit_list_json')
                );
                $list_i++;
                $i = 0;
                //其他订单数据
                foreach ($field_list as $key=>$value){
                    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$key);
                    if($fieldinfo&&$fieldinfo->getFieldLabel()!=''){
                        if($key=='haveoutboundcount'||$key=='balanceoutboundcount'){
                            $list_content =setNumberFormat($adb->query_result($amount_result, 0, $value),0).'<span style="font-size:13px;color:#999">个</span>';
                        }else{
                            $list_content ='¥'.setNumberFormat( $adb->query_result($amount_result, 0, $value),$this->length_amountdecimal);
                        }
                        $report_list[$list_i]['list'][] = array(
                            'content'=>$list_content, 'describe'=>$fieldinfo->getFieldLabel(), 'module'=>'SalesOrder',
                            'second_para'=>json_encode(array('amount_field'=>$key,'date_field'=>$date_type)),
                            'second_action'=>'contractkit_list_json');
                    }elseif($i%2!=0 && empty( $report_list[$list_i]['list'])){
                        //整行两个字段都被隐藏，删除该行
                        unset($report_list[$list_i]);
                        $i++;
                        continue;
                    }
                    if($i%2==0){
                        $report_list[$list_i]['name'] = $field_list_label[$key]['text'];
                        $report_list[$list_i]['imgname'] = $field_list_label[$key]['img'];
                    }else{
                        $list_i++;
                    }
                    $i++;
                }
            }
        }
        $jsonArray['list'] = $report_list;
        //editor:gyq_141 reason:移动端增加首页标签  2019/9/5 9:38 ID1000602
        if($_REQUEST['action']!='home_page'){
            //增加筛选条件
            $jsonArray['list2'] = $this->getCommonSearchCondition();
            if(vtlib_isModuleActive('SalesOrder')){
                $datescolumnname[$date_type]['selected']='yes';
                //日期依据翻译 zxm 20230531
                $jsonArray['list2'][2]=array('fieldlabel'=>getFixedLabel('Datebasis'),'fieldname'=>'reportdatecolumn');
                foreach($datescolumnname as $datecolumn=>$info )
                {
                    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$datecolumn);
                    if($fieldinfo&&$fieldinfo->getFieldLabel()!='')
                    {
                        $jsonArray['list2'][2]['option'][]=array('text'=>$fieldinfo->getFieldLabel(),'value'=>$datecolumn,'select'=>$info['selected']);
                    }
                }
            }
        }
        $jsonArray['name'] = getFixedLabel($this->reportInfo['labelbol']);
        return $jsonArray;
    }

    //获取模块的具体数据
    public function getModuleIconByModule($module_tabid_tabname){
        global $adb,$current_user;
        $tmp_arr = explode(':::',$module_tabid_tabname);
        $mod = $tmp_arr[0];
        $tabid = $tmp_arr[1];
        $tab_tabname = $tmp_arr[2];
        //扬锻 销售简报特殊开发
        if ($mod !='saleskit_yangduan' && is_array($this->moduleUsageInfo[$module_tabid_tabname]) && !empty($this->moduleUsageInfo[$module_tabid_tabname])){
            return $this->moduleUsageInfo[$module_tabid_tabname];
        }

        if (empty($mod) && $tab_tabname == 'ld_linkmodulecustom'){

        }else{
            //扬锻 销售简报特殊开发
            if($mod !='saleskit_yangduan') {
                if (in_array($mod, array('GlobalSearch', 'GlobalScan'))) {
                    $deploy_type = $mod == 'GlobalSearch' ? 8 : 9;
                    $sql = 'select deploy_value from ld_appsystem where userid= ? and deploy_type = ? ';
                    $result = $adb->pquery($sql, array($current_user->id, $deploy_type));
                    $num_row = $adb->num_rows($result);
                    if ($num_row > 0) {
                        $deploy_value = $adb->query_result($result, 0, 'deploy_value');
                    }
                    if ($num_row == 0 || $deploy_value == 'no') {
                        return '';
                    }
                } else {
                    if (in_array($mod, array('PublicAccounts', 'PublicLeads'))) {
                        $module = $mod == 'PublicAccounts' ? 'Accounts' : 'Leads';
                    } else {
                        $module = $mod;
                    }
                    if (isPermitted($module) == 'no' || !vtlib_isModuleActive($module)) {
                        return '';
                    }
                }
            }
        }

        $module_icons = $this->getModuleIcon();
        $key = $mod.'_'.$tabid.'_'.$tab_tabname;
        if($module_icons[$key]['modulename']){
            $data = array(
                'label' => $module_icons[$key]['modulename'],
                'name' => $mod,
                'icon' => $module_icons[$key]['active_icon'],
                'report_icon' => $module_icons[$key]['report_icon'],
                'image' => '',
                'tabid' => $tabid,
                'tab_tablename' => $module_icons[$key]['tab_tablename'],
                'checkphp' => $module_icons[$key]['checkphp'],
                'linkcvid' => $module_icons[$key]['linkcvid'],
                'linkid' => $module_icons[$key]['linkid']
            );
        }elseif (in_array($mod,array('GlobalSearch','GlobalScan'))){
            if($mod == 'GlobalSearch'){
                $data = array(
                    'label' => getFixedLabel('QUICKFIND'),
                    'name' => $mod,
                    'icon' => 'https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/wx_images/crm2022_2/crm_GlobalSearch.png',
                    'report_icon' => '',
                    'image' => '',
                    'tabid' => $tabid,
                    'tab_tablename' => 'ld_tools',
                    'checkphp' => '',
                    'linkcvid' => '',
                    'linkid'=>''
                );
            }
            if($mod == 'GlobalScan'){
                $data = array(
                    'label' => getFixedLabel('SCAN'),
                    'name' => $mod,
                    'icon' => 'https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/wx_images/crm2022/crm_GlobalScan.png',
                    'report_icon' => '',
                    'image' => '',
                    'tabid' => $tabid,
                    'tab_tablename' => 'ld_tools',
                    'checkphp' => '',
                    'linkcvid' => '',
                    'linkid'=>''
                );
            }
        }elseif ($mod == 'PublicAccounts' || $mod == 'PublicLeads'){
            $tmptabid = $mod == 'PublicAccounts' ? 6 : getTabid($mod);
            $key = $mod.'_'.$tmptabid.'_ld_tab';
            $data = array(
                'label' => $module_icons[$key]['modulename'],
                'name' => $mod,
                'icon' => $module_icons[$key]['active_icon'],
                'report_icon' => $module_icons[$key]['report_icon'],
                'image' => '',
                'tabid' => $tmptabid,
                'tab_tablename' => 'ld_tab',
                'checkphp' => $module_icons[$key]['checkphp'],
                'linkcvid' => $module_icons[$key]['linkcvid'],
                'linkid' => $module_icons[$key]['linkid']
            );
        }elseif ($mod == 'saleskit_yangduan'){	//扬锻 销售简报特殊开发
            $tmptabid = $mod == 'saleskit_yangduan' ? 22 : getTabid($mod);
            $key = $mod.'_'.$tmptabid.'_ld_tab';
            $data = array(
                'label' => $module_icons[$key]['modulename'],
                'name' => $mod,
                'icon' => $module_icons[$key]['active_icon'],
                'report_icon' => $module_icons[$key]['report_icon'],
                'image' => '',
                'tabid' => $tmptabid,
                'tab_tablename' => 'ld_tab',
                'checkphp' => $module_icons[$key]['checkphp'],
                'linkcvid' => $module_icons[$key]['linkcvid'],
                'linkid' => $module_icons[$key]['linkid']
            );
        }
        if(empty($data)){
            if ($tab_tabname == 'ld_linkmodulecustom' || $tab_tabname == 'ld_linkmodulecustom_category' || empty($tab_tabname)){
                foreach ($module_icons as $key => $info){
                    if($info['linkid'] == $tabid){
                        $data = array(
                            'label' => $module_icons[$key]['modulename'],
                            'name' => $mod,
                            'icon' => $module_icons[$key]['active_icon'],
                            'report_icon' => $module_icons[$key]['report_icon'],
                            'image' => '',
                            'tabid' => $module_icons[$key]['tabid'],
                            'tab_tablename' => $module_icons[$key]['tab_tablename'],
                            'checkphp' => $module_icons[$key]['checkphp'],
                            'linkcvid' => $module_icons[$key]['linkcvid'],
                            'linkid' => $module_icons[$key]['linkid']
                        );
                    }
                }
            }
        }
        if (is_array($data) && sizeof($data) > 0){
            $this->moduleUsageInfo[$module_tabid_tabname] = $data;
        }
        return $data;
    }

    //获取常用模块的最近使用的模块数据
    public function getrecentModule(){
        global $current_user;
        $module_usage = getUsersettingByLabel('Users',$current_user->id,'ModuleUsage');
        $module_usage = html_entity_decode($module_usage);
        $module_usage_arr = ldcrm_json_decode($module_usage);
        $recentModule_arr = $module_usage_arr['recentModule'];
        foreach ($recentModule_arr as $index => $module_tabid_tabname){
            $tmp_arr = $this->getModuleIconByModule($module_tabid_tabname);
            if(!empty($tmp_arr)){
                $arr['list'][]=$tmp_arr;
            }
        }
        //空值默认
        if (sizeof($arr['list']) == 0){
            $arr['list'] = $this->getDefaultModule(8);
        }
        return $arr;
    }
    //获取常用模块的高频使用的模块数据
    public function gethighFrequency(){
        global $current_user;
        $module_usage = getUsersettingByLabel('Users',$current_user->id,'ModuleUsage');
        $module_usage = html_entity_decode($module_usage);
        $module_usage_arr = ldcrm_json_decode($module_usage);
        $highFrequency_arr = $module_usage_arr['highFrequency'];
        arsort($highFrequency_arr,SORT_NUMERIC);
//        $highFrequency_8_arr = array_slice($highFrequency_arr,0,8,true);
        foreach ($highFrequency_arr as $module_tabid_tabname => $count){
            $tmp_arr = $this->getModuleIconByModule($module_tabid_tabname);
            if(!empty($tmp_arr)){
                $arr['list'][]=$tmp_arr;
            }
            if (sizeof($arr['list']) >= 8){
                break;
            }
        }
        if (sizeof($arr['list']) == 0){
            $arr['list'] = $this->getDefaultModule(8);
        }
        return $arr;
    }

	//常用模块
	public function getcommonmodules(){
		global $adb,$current_user;
		$module_icons = $this->getModuleIcon();
		$query = "select setname,tabid,tab_tablename from ld_appuiset where apptype = 'commonmodules' and settype = 'module' and userid = ?";
		$result = $adb->pquery($query,array($current_user->id));
		$num_rows = $adb->num_rows($result);
        $data = [];
        $data['list'] = [];
		if($num_rows >= 1){

			for($i = 0; $i < $num_rows; $i++){
				$mod = html_entity_decode($adb->query_result($result,$i,'setname'));
                $tabid = $adb->query_result($result,$i,'tabid');
                $tab_tabname = $adb->query_result($result,$i,'tab_tablename');
                if(empty($tabid)){
                    $tabid = $module_icons[$mod.'_'.$tabid.'_'.$tab_tabname]['tabid'];
                }
                $tmp_data = $this->getModuleIconByModule($mod.':::'.$tabid.':::'.$tab_tabname);
                if (!empty($tmp_data)){
                    $data['list'][] = $tmp_data;
                }
			}
		}
        if (is_array($data['list'])&& sizeof($data['list']) == 0){
            $data['list'] = $this->getDefaultModule(7);
        }
		return $data;
	}

    public function getDefaultModule($num){
        $module_icons = $this->getModuleIcon();
        $modules = array('Leads','Accounts','Contacts','ContactRecords','Singin','Potentials','SalesOrder');
        foreach($modules as $mod){

            if(isPermitted($mod) == 'yes' && vtlib_isModuleActive($mod)){

                $tabid = getTabid($mod);
                if($mod == 'Singin'){
                    $tabid = '-2';
                }
                $key = $mod.'_'.$tabid.'_ld_tab';
                if($module_icons[$key]['modulename']){
                    $select_commonmodules[] = $mod;
                    if($mod == 'Singin'){
                        $mod = 'Signin';
                    }
                    $data['list'][] = array(
                        'label' => $module_icons[$key]['modulename'],
                        'name' => $mod,
                        'icon' => $module_icons[$key]['active_icon'],
                        'report_icon' => '',
                        'image' => '',
                        'tabid' => $module_icons[$key]['tabid'],
                        'tab_tablename' => $module_icons[$key]['tab_tablename'],
                        'checkphp' => $module_icons[$key]['checkphp'],
                        'linkcvid' => $module_icons[$key]['linkcvid'],
                        'linkid' => $module_icons[$key]['linkid']
                    );
                }
            }
        }
        if(sizeOf($data['list']) < $num){
            for($i = sizeOf($data['list']); $i<$num; $i++){
                foreach($module_icons as $module_str => $arr){
                    $modules = explode('_',$module_str);
                    $module = $modules[0];
                    if($module == 'Signin'){
                        $module = 'Singin';
                    }
                    if(!in_array($module, $select_commonmodules) && !in_array($module,array('NearbyAccounts')) && !empty($arr['active_icon'])){
                        $select_commonmodules[] = $module;
                        $data['list'][] = array(
                            'label' => $arr['modulename'],
                            'name' => $module,
                            'icon' => $arr['active_icon'],
                            'report_icon' => '',
                            'image' => '',
                            'tabid' => $arr['tabid'],
                            'tab_tablename' => $arr['tab_tablename'],
                            'checkphp' => $arr['checkphp'],
                            'linkcvid' => $arr['linkcvid'],
                            'linkid' => $arr['linkid']
                        );
                        break;
                    }
                }
            }
        }
        return $data['list'];
    }

	public function getModuleIcon(){
		global $adb,$current_user,$MobileLanguageType;
        if (is_array($this->ModuleIcon) && !empty($this->ModuleIcon)){
            return $this->ModuleIcon;
        }
		crm_load_class_file('cls_Home_SpecialMC','appCommon/modules/Home');
        $moduleicons_list= cls_Home_SpecialMC::getHomeModule();
        //edit: xll 2023/02/08 XUQIU1000984 移动端图标增加显示简易风格
        $deployarr_13 = getAppsys_deploy(13);
        $is_open13 = ($deployarr_13 != '') ? $deployarr_13['is_open'] : 'no';
        $active_icon_head = ($is_open13 == 'yes') ? 'themes/icon2022/crm2/' : 'themes/icon2022/crm/';
        $data=[];
		foreach($moduleicons_list as $arr){
			foreach($arr['list'] as $info){
				if(!empty($info['report_icon'])){
					$data[$info['module'].'_'.$info['tabid'].'_'.$info['tab_tablename']] = array(
						'report_icon' => $info['report_icon'],
						'active_icon' => '',
						'modulename' => $info['title'],
						'tabid' => $info['tabid'],
						'tab_tablename' => $info['tab_tablename'],
						'checkphp' => $info['checkphp'],
						'linkcvid' => $info['linkcvid'],
						'linkid' => $info['linkid']
					);
				}
				if(!empty($info['active_icon'])){
					$data[$info['module'].'_'.$info['tabid'].'_'.$info['tab_tablename']] = array(
						'active_icon' => $info['active_icon'],
						'report_icon' => '',
						'modulename' => $info['title'],
						'tabid' => $info['tabid'],
						'tab_tablename' => $info['tab_tablename'],
						'checkphp' => $info['checkphp'],
						'linkcvid' => $info['linkcvid'],
                        'linkid' => $info['linkid']
					);
				}
				if($info['tabid'] < 0){
					$data[$info['module'].'_'.$info['tabid'].'_'.$info['tab_tablename']] = array(
						'active_icon' => $active_icon_head.'crm_'.$info['module'].'.png',
						'report_icon' => '',
						'modulename' => $info['title'],
						'tabid' => $info['tabid'],
						'tab_tablename' => $info['tab_tablename'],
						'checkphp' => $info['checkphp'],
						'linkcvid' => $info['linkcvid'],
                        'linkid' => $info['linkid']
					);
				}
			}
		}
		if(empty($data['GlobalSearch'])){
			$data['GlobalSearch_t_1'] = array(
				'active_icon' => $active_icon_head.'crm_GlobalSearch.png',
				'report_icon' => '',
				'modulename' => getFixedLabel('QUICKFIND'),
				'tabid' => 't_1',
				'tab_tablename' => 'ld_tools',
				'checkphp' => '',
				'linkcvid' => '',
                'linkid' => ''
			);
		}
		if(empty($data['GlobalScan'])){
			$data['GlobalScan_t_2'] = array(
				'active_icon' => $active_icon_head.'crm_GlobalScan.png',
				'report_icon' => '',
				'modulename' => getFixedLabel('SCAN'),
				'tabid' => 't_2',
				'tab_tablename' => 'ld_tools',
				'checkphp' => '',
				'linkcvid' => '',
                'linkid' => ''
			);
		}
        if(empty($data['PublicAccounts'])){
            if($MobileLanguageType == 'en'){
		        $modulename = getFixedLabel('HIGHSEAS').' '.getTranstab('Accounts');
		    }else{
		        $modulename = getFixedLabel('HIGHSEAS').getTranstab('Accounts');
		    }
            $data['PublicAccounts_6_ld_tab'] = array(
                'active_icon' => $active_icon_head.'crm_PublicAccounts.png',
                'report_icon' => '',
                'modulename' => $modulename,
                'tabid' => 6,
                'tab_tablename' => 'ld_tab',
                'checkphp' => '',
                'linkcvid' => '',
                'linkid' => ''
            );
        }
        if(empty($data['PublicLeads'])){
            $tabid = getTabid('Leads');
            if($MobileLanguageType == 'en'){
		        $modulename = getFixedLabel('HIGHSEAS').' '.getTranstab('Leads');
		    }else{
		        $modulename = getFixedLabel('HIGHSEAS').getTranstab('Leads');
		    }
            $data['PublicLeads_'.$tabid.'_ld_tab'] = array(
                'active_icon' => $active_icon_head.'crm_PublicLeads.png',
                'report_icon' => '',
                'modulename' => $modulename,
                'tabid' => $tabid,
                'tab_tablename' => 'ld_tab',
                'checkphp' => '',
                'linkcvid' => '',
                'linkid' => ''
            );
        }
        $this->ModuleIcon = $data;
		return $data;
	}
	
    //销售龙虎榜
    public function getsalesdragontiger(){
        global $adb,$MobileLanguageType;
        $dashboard_module=$_REQUEST['ranking_module'];
        $dashboard_sort=$_REQUEST['ranking_sort'];
        $page_num=$_REQUEST['page_num'];
        if(empty($page_num)){
            $page_num=1;
        }
        $sorttype='desc';
        if($dashboard_sort=='low'){
            $sorttype='asc';
        }
        $selectuid=$_REQUEST['selectuid'];
        if($_REQUEST['reporttype']=="custom"){
            //zxm 2021-0113【移动端首页界面，时间查询范围中增加“自定义时间”选项】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001000289
            $time_range = $_REQUEST['custom_data'];
            $time_range = explode('~',$time_range);
            $time_range[0] = $time_range[0].' 00:00:00';
            $time_range[1] = $time_range[1].' 23:59:59';
        }else{
            $time_range = cls_StaticCommonFun::getTimeRange($_REQUEST['reporttype'],'arr');
        }
        if(!isset($_REQUEST['page_step'])||$_REQUEST['page_step']==1){
            $limit=5;
        }
        else{
            $limit=50;
        }
        $sqllimit=($page_num-1)*$limit.','.$limit;
        
        $sql='select  modulenames from ld_dashboard_app  where name="salesdragontiger"';
        $result=$adb->pquery($sql,array());
        $modulenames=$adb->query_result($result,0,'modulenames');
        $arr_modules=explode(",",$modulenames);
        $modules=array();
        foreach($arr_modules as $tmp_modulename){
            $selected='no';
            if($dashboard_module==$tmp_modulename){
                $selected='yes';
            }
            if($tmp_modulename=='Sign'){
                $modules[]=array('label'=>getFixedLabel('NEWSIGNNUMBER'),'modulename'=>$tmp_modulename,'selected'=>$selected);
            }
            //zxm 20201230  龙虎榜增加新选项-线索升级到客户数
            if($tmp_modulename=='LeadsUpToAccounts'&&vtlib_isModuleActive("Accounts")&&vtlib_isModuleActive("Leads")&&isPermitted('Accounts')=="yes"&&isPermitted('Leads')=="yes"){
                $modules[]=array('label'=>getFixedLabel('LeadUgradeToCustomerCount'),'modulename'=>$tmp_modulename,'selected'=>$selected);
            }
            //新增签约额
            if($tmp_modulename=='ContractAmount'&&vtlib_isModuleActive("SalesOrder")&&vtlib_isModuleActive("ServiceContracts")&&isPermitted('SalesOrder')=="yes"&&isPermitted('ServiceContracts')=="yes"){
                $modules[]=array('label'=>getFixedLabel('NEWCONTRACTAMOUNT'),'modulename'=>$tmp_modulename,'selected'=>$selected);
            }
            if(vtlib_isModuleActive($tmp_modulename)&&isPermitted($tmp_modulename)=="yes"){
                if(in_array($tmp_modulename,['SalesOrder','ServiceContracts','Commission'])){
                    $unit = getFixedLabel('AMOUNT1');
                }else{
                    $unit = getFixedLabel('num');
                }
                if($MobileLanguageType == 'zh'){
                    $label = getFixedLabel('NEW').getTranstab($tmp_modulename).$unit;
                }else{
                    $label = getFixedLabel('NEW').' '.getTranstab($tmp_modulename).' '.$unit;
                }
                $modules[]=array('label'=>$label,'modulename'=>$tmp_modulename,'selected'=>$selected);
            }
        }
        if(empty($dashboard_module)){
            $dashboard_module=$modules[0]['modulename'];
            $modules[0]['selected']='yes';
        }
        
        $startdate=$time_range[0];
        $enddate=$time_range[1];
        //time_range为all的时候sql中没做判断 	BUG0066369	zxm 20230515 企业微信，工作台页签，查看范围时间选择全部，销售龙虎榜不显示数据
        if($dashboard_module=='Sign'){
            $sql="select *from (
        
                    select count(DISTINCT ld_singin.id) as countnum,ld_singin.userid  as smownerid,
                        GROUP_CONCAT(distinct ld_groups.groupname) as groupname,ld_users.last_name from ld_singin
                     inner join ld_users on ld_users.id=ld_singin.userid 
                     inner join ld_users2group on ld_users.id=ld_users2group.userid
                     inner join ld_groups on ld_groups.groupid=ld_users2group.groupid
                    where ld_singin.deleted=0 and (case when '$time_range'='' then 1=1 else ld_singin.createdtime between '$startdate' and '$enddate' end)
                    group by ld_singin.userid  ) as counttable ";
        }else if($dashboard_module=='ContractAmount'){
            //duan 20221024 移动端增加审批查询条件
            $salesorder_approvesql = $this->getApproveSql('SalesOrder');
            $servicecontracts_approvesql = $this->getApproveSql('ServiceContracts');
            //新增签约额 zxm 2021-0105 数据错误的修改 重写sql
            $sql = "select * from (select (ifnull(b.countnum,0) + ifnull(c.countnum,0)) AS countnum,
			a.smownerid,
			ifnull(b.groupname, c.groupname) as groupname,
			ifnull(b.last_name, c.last_name) as last_name,
			ifnull(b.wx_userid, c.wx_userid) as wx_userid from (select id as smownerid from ld_users) a left  join (SELECT
		sum(ifnull(total,0)/ifnull(ld_salesorder.conversion_rate,1)) AS countnum,
		smownerid,
		g.groupname,
		ld_users.last_name,
		ld_users.wx_userid
	FROM ld_salesorder
	LEFT JOIN ld_users ON ld_users.id = ld_salesorder.smownerid
	LEFT JOIN (
		SELECT
			ld_users.id,
			GROUP_CONCAT(DISTINCT ld_groups.groupname ORDER BY ld_groups.groupid) AS groupname
		FROM ld_users 
		LEFT JOIN ld_users2group ON ld_users2group.userid = ld_users.id
		INNER JOIN ld_groups ON ld_groups.groupid = ld_users2group.groupid
		GROUP BY ld_users.id
	) g ON g.id=ld_users.id
	WHERE ld_salesorder.deleted = 0
		AND (case when '$time_range'='' then 1=1 else ld_salesorder.createdtime between '$startdate' and '$enddate' end)
        $salesorder_approvesql
	GROUP BY ld_salesorder.smownerid)as b on a.smownerid=b.smownerid left join (SELECT
		sum(ifnull(total,0)/ifnull(ld_servicecontracts.conversion_rate,1)) AS countnum,
		smownerid,
		g.groupname,
		ld_users.last_name,
		ld_users.wx_userid
	FROM ld_servicecontracts
	LEFT JOIN ld_users ON ld_users.id = ld_servicecontracts.smownerid
	LEFT JOIN (
		SELECT
			ld_users.id,
			GROUP_CONCAT(DISTINCT ld_groups.groupname ORDER BY ld_groups.groupid) AS groupname
		FROM ld_users 
		LEFT JOIN ld_users2group ON ld_users2group.userid = ld_users.id
		INNER JOIN ld_groups ON ld_groups.groupid = ld_users2group.groupid
		GROUP BY ld_users.id
	) g ON g.id=ld_users.id
	WHERE ld_servicecontracts.deleted = 0
		AND (case when '$time_range'='' then 1=1 else ld_servicecontracts.createdtime between '$startdate' and '$enddate' end)
        $servicecontracts_approvesql
	GROUP BY ld_servicecontracts.smownerid)as c on a.smownerid=c.smownerid";
        } else{
            if($dashboard_module == "LeadsUpToAccounts"){
                $tmp_module = 'Accounts';
            }else{
                $tmp_module = $dashboard_module;
            }
            //zxm 20230421 BUG0065243	 APP“线索升级到客户数”一直处于加载中（直接看企业微信）
            $focus=CRMEntity::getInstance($tmp_module);
            $tmp_approvesql = $this->getApproveSql($tmp_module);
            $tablename=$focus->table_name;
            $table_index=$focus->table_index;
            //zxm 20201230  龙虎榜增加新选项-线索升级到客户数等6个
            if(in_array($dashboard_module,['SalesOrder','ServiceContracts','Commission'])){
                //zxm  2020-0105 计算求和的错误修改
                $sql = "SELECT * FROM (SELECT
		sum(ifnull(total,0)/ifnull($tablename.conversion_rate,1)) AS countnum,
		smownerid,
		g.groupname,
		ld_users.last_name,
		ld_users.wx_userid
	FROM $tablename
	LEFT JOIN ld_users ON ld_users.id = $tablename.smownerid
	LEFT JOIN (
		SELECT
			ld_users.id,
			GROUP_CONCAT(DISTINCT ld_groups.groupname ORDER BY ld_groups.groupid) AS groupname
		FROM ld_users 
		LEFT JOIN ld_users2group ON ld_users2group.userid = ld_users.id
		INNER JOIN ld_groups ON ld_groups.groupid = ld_users2group.groupid
		GROUP BY ld_users.id
	) g ON g.id=ld_users.id
	WHERE $tablename.deleted = 0
		AND (case when '$time_range'='' then 1=1 else $tablename.createdtime between '$startdate' and '$enddate' end)
        $tmp_approvesql
	GROUP BY $tablename.smownerid
	) AS counttable";
            }else{
                if($dashboard_module == "LeadsUpToAccounts"){
                    $else_where = " and upgrade_source='from_leads' ";
                }else{
                    $else_where = "";
                }
                $field = "count(distinct $tablename.$table_index )";
                $sql=" select * from (select $field as countnum,smownerid 
                        ,GROUP_CONCAT(distinct ld_groups.groupname order by ld_groups.groupid SEPARATOR '#a#'  ) as groupname,
                        GROUP_CONCAT(distinct ld_groups.groupid order by ld_groups.groupid ) as groupids,
                        ld_users.last_name,ld_users.wx_userid from $tablename
                     inner join ld_users on ld_users.id=$tablename.smownerid 
                     inner join ld_users2group on ld_users.id=ld_users2group.userid
                     inner join ld_groups on ld_groups.groupid=ld_users2group.groupid
                      where $tablename.deleted=0 $else_where and (case when '$time_range'='' then 1=1 else $tablename.createdtime between '$startdate' and '$enddate' end)
                      $tmp_approvesql
                group by $tablename.smownerid) as counttable ";
            }
        }
        if($dashboard_module=='ContractAmount'){
            $sql.=' where a.smownerid in( '.$this->selectuid.'))a where countnum is not null and countnum>0';
        }else{
            $sql.=' where smownerid in( '.$this->selectuid.')';
        }
        $totalrows=$adb->num_rows($adb->pquery($sql,array()));
        $pagecount=round($totalrows/$limit);
        if($pagecount*$pagecount<$totalrows){
            $pagecount+=1;
        }
        $sql.=" order by countnum $sorttype,smownerid $sorttype limit $sqllimit ";

        $result=$adb->pquery($sql,array());
        $rows=$adb->num_rows($result);
        $total=0;
        $infos=array();
        $startsequnece=($page_num-1)*$limit;
        
        for($i=0;$i<$rows;$i++){
            $tmpcount=$adb->query_result($result,$i,'countnum');
            $total+=$tmpcount;
            //zxm 20201230  龙虎榜增加新选项-线索升级到客户数等6个 金额格式化
            if(in_array($dashboard_module,['SalesOrder','ServiceContracts','Commission','ContractAmount'])){
                $tmpcount = number_format($tmpcount,$this->length_amountdecimal);
            }

            $userid=$adb->query_result($result,$i,'smownerid');
            $wx_userid=$adb->query_result($result,$i,'wx_userid');
            
            $last_name=$adb->query_result($result,$i,'last_name');
            $groupname=$adb->query_result($result,$i,'groupname');
            $groupids=$adb->query_result($result,$i,'groupids');
            $arr_groups=explode(',',$groupids);
            $arr_groupname=explode('#a#',$groupname);
            $groupnames=array();
            foreach($arr_groups as $groupindex=>$tmpgroupid){
                $groupobj=new Users();
                $groupobj->groupid=$tmpgroupid;
                $groupobj->groupname=$arr_groupname[$groupindex];
                $groupnames[]=getWx_GroupName($groupobj);
                
            }
            $userobj=new Users();
            $userobj->wx_userid=$wx_userid;
            $userobj->id=$userid;
            $userobj->last_name=$last_name;
            $infos[]=array('count'=>$tmpcount,'userid'=>$userid,'last_name'=>getUserlastName($userobj),'groupname'=>implode(',',$groupnames),'sequence'=>$i+1+$startsequnece);
            
        }
      
       foreach($infos as $tmpindex=>$tmpinfo){
            $infos[$tmpindex]['percent']=$total<=0?0:round(($infos[$tmpindex]['count']/$total)*100,2);
            
       }
         $jsonarray=array();
         
        $jsonarray['labels']=$modules;
        $jsonarray['list']=$infos;
        $jsonarray['havenextpage']='no';
        $jsonarray['time_range']=$this->set_filter_time_range();
        if($page_num<$pagecount){
            $jsonarray['havenextpage']='yes';
        }
      
        return $jsonarray;
    }

    /**
     * @return array
     * @throws Exception
     * 区域统计 -蔷薇大树
     * zxm
     * 20201119
     */
    public function getRegionalStatistics()
    {
        global $adb;
        $selectuid = trim($_REQUEST['selectuid'],',');
        if($selectuid=="all"){
            $scope_obj = new ScopOfAuthority($adb,'Home');
            $selectuid = $scope_obj->getHomeScopeUser();
        }
        $where = 'AND (FIND_IN_SET(smownerid,"'.$selectuid.'")  
        OR accountid IN (SELECT crmid FROM ld_tabshare WHERE FIND_IN_SET(viewuserid,"'.$selectuid.'") GROUP BY crmid))';

        $select_sql = "SELECT
            IFNULL(bill_city,'') AS bill_city,
            COUNT(accountid) AS zhuce_cnt,
            SUM(CASE WHEN platform_amt>0 THEN 1 ELSE 0 END) AS shouxin_cnt,
            SUM(CASE WHEN ths_fnc_amt>0 THEN 1 ELSE 0 END) AS rongzi_cnt
        FROM ld_account
        WHERE deleted=0
            $where
        GROUP BY IFNULL(bill_city,'')
        ORDER BY CONVERT(IFNULL(bill_city,'') USING GBK)";
        $select_res = $adb->pquery($select_sql);
        $select_nums = $adb->num_rows($select_res);
        $list = [];
        $total['zhuce'] = 0;
        $total['shouxin'] = 0;
        $total['rongzi'] = 0;
        if($select_nums > 0){
            for($i=0;$i<$select_nums;$i++){
                $list[$i]['bill_city'] = $adb->query_result($select_res,$i,'bill_city');
                $list[$i]['bill_city'] = $list[$i]['bill_city']==''?'无':$list[$i]['bill_city'];
                $list[$i]['zhuce_cnt'] = $adb->query_result($select_res,$i,'zhuce_cnt');
                $total['zhuce'] += $list[$i]['zhuce_cnt'];
                $list[$i]['shouxin_cnt'] = $adb->query_result($select_res,$i,'shouxin_cnt');
                $total['shouxin'] += $list[$i]['shouxin_cnt'];
                $list[$i]['rongzi_cnt'] = $adb->query_result($select_res,$i,'rongzi_cnt');
                $total['rongzi'] += $list[$i]['rongzi_cnt'];
            }
        }
        $total['city_str'] = getFixedLabel('COMPANYCITY');//城市
        $total['zhuce_str'] = getFixedLabel('REGCUST');//注册客户数
        $total['shouxin_str'] = getFixedLabel('CRECUSTNUM');//授信客户数
        $total['rongzi_str'] = getFixedLabel('FINANCECUSTNUM');//融资客户数
        return ['list'=>$list,'total'=>$total];
    }

    /**
     * @return array
     * @throws Exception
     * zxm
     * 2021-0311
     * 跟进频次排行榜 
     */
    public function getContactTimesRanking()
    {
        //zxm 20230907 改成跟PC端走同一个方法   调HomeUtils类传参即可
        if($_REQUEST['reporttype']=="custom"){
            $time_range = $_REQUEST['custom_data'];
        }else{
            $time_range = $_REQUEST['reporttype'];
        }
        include_once globalStatic::$root_directory."modules/Home/HomeChartUtils.php";
        $homeboardid=empty($this->homeboardid)?0:$this->homeboardid;
        $HomeUtilsObj = new HomeChartUtils($homeboardid);
        $params = array(
            'scopeType'=>'smowner_search_senior',
            'senioruserid'=>$this->selectuid,
            'search_date'=>$time_range,
            'approve_value'=>$_REQUEST['approve_value'],
        );
        $HomeUtilsObj->initParam($params);
        $HomeUtilsObj->setStuffid(57,0);
        $home_values = $HomeUtilsObj->getStuffData();
        $home_values['reportid']=57;
        return $home_values;
    }
    
    //zkt 获取关键视图内容
    public function getkeyViews()
    {
        include_once(globalStatic::$root_directory.'modules/CustomView/ListViewTop.php');
        $_REQUEST['SearchScope'] = 'SmOwner_Search_All';
        $_REQUEST['report_name'] = "keyViews";
        $keyViews = getKeyMetrics('','SmOwner_Search_All','','yes');
        foreach($keyViews as &$v){
            $v['name'] = getTranstab($v['module']).'-'.$v['name'];
        }
        return ['list'=>$keyViews];
    }
    
    //获取自定义报表区块内容
    public function getcustomreportblock()
    {
        global $adb,$current_user,$languageType;
        $query = 'SELECT block_id,block_name,parenttab_label,allocatetype,allocateid from ld_mobile_report_parent_tab where parenttab_label =\'customreportblock\'';
        $result = $adb->pquery($query,array());
        $blockid = $adb->query_result($result,0,'block_id');
        $blockname = $adb->query_result($result,0,'block_name');
        $parenttablabel = $adb->query_result($result,0,'parenttab_label');
    	$allocateid = $adb->query_result($result,0,'allocateid');
        $allocatetype = $adb->query_result($result,0,'allocatetype');
        $allocateids = explode(",",$allocateid);
        
        //自定义报表区块可见范围
        if (is_admin($current_user)) {
            $allocatetype = 'all';
        }
        if ($allocatetype == 'user') {
            if (!in_array($current_user->id, $allocateids)) {
                return [];
            }
        } else if ($allocatetype == 'group') {
            $tmpgroup = 'no';
            foreach ($curuser_groupids as $curuser_groupid) {
                if (in_array($curuser_groupid, $allocateids)) {
                    $tmpgroup = 'yes';
                    break;
                }
            }
            if ($tmpgroup == 'no') {
                return [];
            }
        }
        
        //非crm报表url增加传输参数
        //获取用户查看范围
        $db = PearDatabase::getInstance();
        $scopeobj = new ScopOfAuthority($db,$_REQUEST['module']);
        if($scopeobj->modulescolist[$_REQUEST['module']]['scopeauthority']=='1'){
            $uuid_range = 'all';
        }
        else{
            $uuid_range = $scopeobj->getCurUserScopeId();
        }
        $addurl = $scopeobj->getModuleListViewQuery();
        $cur_range = $this->selectuid;
        $cur_period = $_REQUEST['reporttype'];
        $crmreporturl = 'crmreportuuid='.$current_user->id.'&crmreportuuid_range='.$uuid_range.'&crmreportcur_range='.$cur_range.'&crmreportcur_period='.$cur_period;
        
        //自定义报表区块显示内容
        $query = "select tab_tablename,tabid,IFNULL(checkphp,'') AS checkphp from ld_mobile_report_tab_rel where block_id = ? ORDER BY sequence";
        $result = $adb->pquery($query, array($blockid));
        $reportrows = $adb->num_rows($result);
        if($reportrows<=0)return [];
        $list = array();
        for ($k = 0; $k < $reportrows; $k++) {
            $tab_tablename = $adb->query_result($result, $k, 'tab_tablename');
            $checkphp = $adb->query_result($result, $k, 'checkphp');
            $tabid = $adb->query_result($result, $k, 'tabid');

            if ($tab_tablename == 'ld_linkmodulecustom') {
                crm_load_class_file("cls_LinkModuleCustom",'include/utils');
                $tmplinkinfo = cls_LinkModuleCustom::getLinkModuleCustomInfoById($tabid);
                if ($languageType == 'zh') {
                    $tmplabel = $tmplinkinfo['zh_label'];
                } else {
                    $tmplabel = $tmplinkinfo['en_label'];
                }
                //zxm 20231117 金蝶库存查询（PC)不应在自定义报表中显示
                if(stripos($tmplinkinfo['url'],'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=stock_report')!==false)
                {
                    continue;
                }
                //非crm的报表链接地址增加参数
                $url = $tmplinkinfo['url'];
                if(strstr($url,'/CustomReport/JsReport/index.php?crm_report_key')== false&&$tmplinkinfo['entitytype']=='custom')
                {
                    if(strstr($url,'?')!= false)
                    {
                        $url .='&'.$crmreporturl;
                    }
                    else
                    {
                        $url .='?'.$crmreporturl;
                    }
                    //zxm 20231114 默认看板的自定义报表区块  判断如果是自定义报表/自定义统计图 需要加上前面的访问域名
                    if(substr($tmplinkinfo['url'],0,10)=='index.php?') {
                        $corpurl_all_customreort_arr = explode('WeiXinApp', getCorpUrl());
                        $url = $corpurl_all_customreort_arr[0] . $url;
                    }
                }
                $list[] = array('tabid' => $tabid, 'tabname' => $tmplabel,'checkphp' =>$checkphp,'linkcvid'=>$tmplinkinfo['linkcvid'], 'type' => $tab_tablename,'url' => $url);
            }
        }
        if(empty($list))return [];
        return array('list'=>$list,'label'=>$blockname);
    }

    //ls 2022-03-27 呼博士增加"个人账户余额字段"
    public function getPersonalAccountBalance()
    {
        global $adb,$current_user,$PlatformMC;
        $languageType = getLanguageType($current_user);
        $versiontrade = getVersionTradeInfo();
        //        $trade = $versiontrade['trade'];

        $account = $versiontrade['account'];
        //累计充值金额:total_chongzhi  累计专项款金额:zhuankuan_total  充值余额:total_keyong  专项款余额:zhuankuan_keyong 累计订货金额:total_dinghuo 下单可用额度:keyong_amount
        $list = array();
        if ($account == 'huboshi') {
            $sql = "select fieldname,ld_tranlabel.fieldlabel from ld_field  inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
                where languagetype=? and trantable=? and ld_tranlabel.tabid=?
            and fieldname in ('total_chongzhi','zhuankuan_total','total_keyong','zhuankuan_keyong','total_dinghuo','keyong_amount') and ld_field.presence in (0,2) ORDER BY sequence ASC";
            $result = $adb->pquery($sql, array($languageType, 'ld_field', getTabid('Accounts')));
            if ($adb->num_rows($result) > 0) {
                for ($i = 0; $i < $adb->num_rows($result); $i++) {
                    $fieldname = $adb->query_result($result, $i, 'fieldname');
                    $fieldlabel = $adb->query_result($result, $i, 'fieldlabel');
                    $showfield_arr[$fieldname] = $fieldlabel;
                }

                $showfieldname = implode(',', array_keys($showfield_arr));
                if($PlatformMC['type_mini']){
                    $sql1 = "select $showfieldname from ld_account a LEFT JOIN ld_users u ON a.accountid = u.accountid where u.id = ? and ifnull(u.accountid,'') <> ''";
                    $result1 = $adb->pquery($sql1,array($current_user->id));
                }else{
                    $sql1 = "select $showfieldname from ld_account a LEFT JOIN ld_users u ON a.accountid = u.accountid where u.wx_userid = ? and ifnull(u.accountid,'') <> '' limit 1";
                    $result1 = $adb->pquery($sql1, array($_REQUEST['userid']));
                }
                if ($adb->num_rows($result1) > 0) {
                    foreach ($showfield_arr as $name => $label) {
                        $list[] = array("name" => $label, "value" => number_format($adb->query_result($result1, 0, $name), 2));
                    }
                }
            }
        }

        return array('list'=>$list);
    }
}