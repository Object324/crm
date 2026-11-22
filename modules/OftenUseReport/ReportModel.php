<?php
//editor:gyq_86 reason:产品批次 2018/11/15 15:12
crm_load_class_file('OftenUseReport','modules/OftenUseReport');
class ReportModel extends OftenUseReport
{
    public $report_parent_type;//父报表类型，用来和其他报表区分开
    public $page_html_arr;
    public $report_pagerecordcount;
    public $report_name;
    public $ware_list;
    public function __construct()
    {
        //editor:gyq_135 reason:report_parent_type取消默认值  2019/8/9 16:26 ID1000568
        //$this->report_parent_type = 'kucun';
        crm_load_class_file('ListViewUtils','include/utils');
    }
    //库存流水账editor:gyq_86 reason:产品批次 2018/11/16 15:23
    //生成报表序时簿内容
    public function getReportListView(){
        $reportname = $this->reportname;
        return $this->$reportname();
    }
    //生成左边报表列表
    public function left_report_list($r_smarty,$r_trade){
        global $adb,$current_user,$currentModule;
        $trade_where_list = $this->trade_where($r_trade);
        $where = $trade_where_list['where'];
        $parentwhere = $trade_where_list['parentwhere'];

        $sql='select usereportid,name from ld_usereport where parent_id=0 '.$parentwhere.' order by sequence';//获取父节点报表
        $parentresult=$adb->pquery($sql,array());
        $reportHeader=array();
        //获取父节点下子节点报表
        $PurchaseOrdertype=vtlib_isModuleActive('PurchaseOrder');
        $SalesOrdertype=vtlib_isModuleActive('SalesOrder');
        $HelpDesktype=vtlib_isModuleActive('HelpDesk');
        $ProjectTasktype=vtlib_isModuleActive('ProjectTask');
        $CashBilltype=vtlib_isModuleActive('CashBill');
        $relatednames=array();
        if(!is_admin($current_user))
        {
            //角色权限增加常用报表权限
            $SQL='select * from ld_profile2standardpermissions where profileid=? and tabid=?  ';
            $profile_result=$adb->pquery($SQL,array($current_user->profileid,getTabid($currentModule)));
            $relatednames=$adb->query_result($profile_result,0,'relatednames');
            $relatednames=explode(",",$relatednames);
        }
        $default_report_id = 0;
        for($i=0;$i<$adb->num_rows($parentresult);$i++)
        {
            $sqlchild='select usereportid,name,reporttype from ld_usereport where parent_id=? and presence=0 '.$where.' order by sequence';
            $parentid=$adb->query_result($parentresult,$i,'usereportid');
            $parant_name = $adb->query_result($parentresult,$i,'name');
            $parentlabel=getFixedLabel($parant_name);
            if($parant_name=='InventoryReport'){
                //editor:20181229 0035903: 库存报表，当库存模块一个都不启用时，报表应该不显示
                //出库单、入库单、盘点单、库间调拨、销售退货单、采购退货单、库存初始化
                $stock_modules = array('OutboundOrder','Stock','WareHouseTransfer','Checks','Prdtnums','SalesBack','PurchaseBack');
                $atleast_onemodule_active = 0;
                foreach ($stock_modules as $key=>$value){
                    if(vtlib_isModuleActive($value)){
                        $atleast_onemodule_active = 1;
                    }
                }
                if($atleast_onemodule_active===0){
                    continue;
                }
            }
            $childresult=$adb->pquery($sqlchild,array($parentid));
            for($j=0;$j<$adb->num_rows($childresult);$j++)
            {
                $childname = $adb->query_result($childresult,$j,'name');
                $child_reporttype = $adb->query_result($childresult,$j,'reporttype');
                $childlabel=getFixedLabel($childname);
                /**
                 * @reason 0012334 常用报表>>服务绩效统计表：希望【客户服务单】、【项目任务】模块都没有开启的情况下，该报表不显示
                 * @author Tujt 2014-11-10
                 */
                if($childname == 'Serviceperformanceappraisal'){//服务绩效统计表
                    if(1 != $HelpDesktype && 1 != $ProjectTasktype){
                        continue;
                    }
                }
                if($childname == 'The billboard of Receivables'){//回款金额龙虎榜
                    if(1 != $CashBilltype){
                        continue;
                    }
                }
                if($childname == 'TimeSheet personal monthly summary'){//判断工时模块是否开启
                    if(vtlib_isModuleActive('TimeSheet') == ''){
                        continue;
                    }
                }
                //chj:应收账款汇总表：如果数据接口没有连接金蝶旗舰版则不显示当前报表
                if($childname == 'AccountsReceivableSummary' && getDatainterface('soft_version') != 5){
                    continue;
                }
                if('CashBillSum_Paymentplan' == $childname && !vtlib_isModuleActive('PaymentPlan')){
                    continue;
                }
                if('SendCashBillSum_SendPayment' == $childname && !vtlib_isModuleActive('SendPayment')){
                    continue;
                }
                $childusereportid=$adb->query_result($childresult,$j,'usereportid');

                /*if($i==0&&$j==0)
                {
                    //$usereportid=7;
                    $usereportid=$childusereportid;//页面第一次进入获取默认查询的报表

                }*/
                if($childname=='DRAWTRACKREPORT')
                {
                    crm_load_class_file('RecordEncrypt','include');
                    $objuser=new RecordEncrypt("User",$current_user->id);

                    $r_smarty->assign("GUIJITOKEN", $objuser->encrypt());
                    $r_smarty->assign("GUIJIREPORTID",$childusereportid);
                    $r_smarty->assign("GUIJIURL",$_SERVER['HTTP_HOST'].$_SERVER['PHP_SELF']);
                }
                else if($childname=='TRACKREREPORTROUTE')
                {
                    $r_smarty->assign("GUIJIROUTEID",$childusereportid);
                }
                if(is_admin($current_user)||in_array($childname,$relatednames))
                {
                    //页面第一次进入获取默认查询的报表，禁止第一次进入的就是月度考情表
                    if($child_reporttype != 51 && $default_report_id===0){
                        $default_report_id = $childusereportid;
                    }
                    $reportHeader[$parentlabel][]=array(
                        'label'=>$childlabel ,'id'=>$childusereportid,'name'=>$childname,'type'=>$child_reporttype);
                }

            }
        }
        return array('header'=>$reportHeader,'default'=>$default_report_id) ;
    }
    //人员范围
    public function Merge_SmOwner(){
        global $currentModule,$current_user,$adb;
        $MergeSmowner=getCurSmOwnerSearchScope($currentModule);
        if($this->report_name != 'TimeSheet personal monthly summary'){
            unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
        }
        unset($MergeSmowner["OtherInfo"]['SmOwer_Search_MeToShare']);
        unset($MergeSmowner["OtherInfo"]['SmOwner_Search_Create']);
        unset($MergeSmowner["OtherInfo"]['SmOwer_Search_ShareMe']); //去掉共享给我的
        //zxm 2022-1111 常用报表改成报表分析的数据范围
        $scopeobj = new ScopOfAuthority($adb,$currentModule);
        //灵当CRM详细需求-PC端-常用报表查看范围增加按部门选项
        if($scopeobj->getUserModuleScoperType() > 0 || $current_user->is_admin == 'on'){
            $fieldlabel_group = getFixedLabel('SETBYDEPARTMENT');
            $MergeSmowner["OtherInfo"]['SmOwner_Search_Group'][$fieldlabel_group] = '';
        }
        return $MergeSmowner;
    }
    //列头查询设置
    public function reportcolumns($r_usereportid){
        global $adb,$languageType;
        $sql = "select usertype from ld_wx_config where name=?";
        $result = $adb->pquery($sql,array('checkin_monthly'));
        $interfaceType = 'weixin';
        if($adb->num_rows($result)){
            $interfaceType = $adb->query_result($result,0,'usertype');
        }
        $sql='select * from ld_usereportcolumns where usereportid=?  order by sequence';
        $result=$adb->pquery($sql,array($r_usereportid));
        $reportFindHeader="";
        $showcolLists=array();
        $AllReportHeaders=array();
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            //columns:表名：字段名称：fieldname:模块名称_fieldlabel:typeofdate
            $columns=$adb->query_result($result,$i,'columns');
            $realcolumns=$adb->query_result($result,$i,'realcolumns');
            $col_tabname=$adb->query_result($result,$i,'tabname');
            $is_advanced=$adb->query_result($result,$i,'is_advanced');

            if($languageType=='zh'){
                $fieldlabel=$adb->query_result($result,$i,'realcolumns');
            }elseif($languageType=='en'){
                $fieldlabel=$adb->query_result($result,$i,'realencolumns');
            }

            $columshow=$adb->query_result($result,$i,'columnshow');

            if($columshow!=1)
            {
                continue;
            }
            //editor:gyq_155 reason:钉钉考勤同步  2019/10/30 16:23 ID1000624
            //editor:gyq_20191209 reason:0038779: （kfbcrm）月度考勤统计表和考勤异常明细表缺少【补卡】显示列（需要补丁）
            if($interfaceType=='dingtalk') {
                if($this->report_name=='checkin_abnormal'){
                    if($columns=='frequency'||$columns=='reissue_card'){
                        continue;
                    }elseif ($columns=='first_checkin'){
                        $fieldlabel = getFixedLabel('DINGTALKONDUTY');
                    }elseif ($columns=='latest_checkin'){
                        $fieldlabel = getFixedLabel('DINGTALKOFFDUTY');
                    }
                }elseif ($this->report_name=='checkin_monthly'){
                    if($columns=='reissue_card'){
                        continue;
                    }
                }
            }
            //销售业绩考核表
            $reportFindHeader.='<th>&nbsp;'.$fieldlabel.'</th>';

            $AllReportHeaders[]=$columns;
            $exportheader[] = $fieldlabel;
            $showcolLists[ ]=array();
            $selected = '';
            if($is_advanced == 1){
                $selected = "selected = ''";
            }
                //editor:gyq_122临时 reason:高级查找字段隐藏日期字段  2019/6/14 17:46
            if($this->report_parent_type=='kucun'&&$columnname=='bill_date'){
                continue;
            }
            $fieldnames .= "<option value=\'$columns\' $selected>$fieldlabel</option>";
        }
        //editor:gyq_20190130	0036328: （1.6登录）库存台账导出Excel后，Excel表中“收入、发出、结存”列头没有导出（需要补丁）
//editor:gyq_20190411	库存流水账导出Excel后，Excel表中“收入、发出”列头没有导出
        if($this->report_name=='InventoryLedger'||$this->report_name=='InventoryAccount'){
            $exportheader[] = getFixedLabel('INCOME').'-'.getFixedLabel('LISTPRICE');
            $exportheader[] = getFixedLabel('INCOME').'-'.getFixedLabel('QUANTITY');
            $exportheader[] = getFixedLabel('INCOME').'-'.getFixedLabel('AMOUNT');
            $exportheader[] = getFixedLabel('SENDOUT').'-'.getFixedLabel('LISTPRICE');
            $exportheader[] = getFixedLabel('SENDOUT').'-'.getFixedLabel('QUANTITY');
            $exportheader[] = getFixedLabel('SENDOUT').'-'.getFixedLabel('AMOUNT');
            if($this->report_name=='InventoryLedger'){
                $exportheader[] = getFixedLabel('REPORTBALANCE').'-'.getFixedLabel('LISTPRICE');
                $exportheader[] = getFixedLabel('REPORTBALANCE').'-'.getFixedLabel('QUANTITY');
                $exportheader[] = getFixedLabel('REPORTBALANCE').'-'.getFixedLabel('AMOUNT');
            }
        }
        return array('AllReportHeaders'=>$AllReportHeaders,'exportheader'=>$exportheader,
                    'showcolLists'=>$showcolLists,'fieldnames'=>$fieldnames,'reportFindHeader'=>$reportFindHeader
                    );
    }
    //获取人员范围
    public function users_combo(){
        global $adb,$currentModule,$current_user;
        $ScopOfAuthority = ScopOfAuthority::getInstance($adb,$currentModule);
        if ( is_admin($current_user)==false && ($ScopOfAuthority->getModuleShareInfo() == SHARE_PRIVATE or $ScopOfAuthority->getModuleShareInfo() == SHARE_PUBLIC_READONLY)) {

            $users_combo = get_user_array(FALSE, "Active", $current_user->id, 'private');
        } else {
            $users_combo = get_user_array(FALSE, "Active", $current_user->id);
        }
        foreach($users_combo as $userid=>$lastname)
        {
            $arruser[$lastname]=$userid;
        }
        return $arruser;
    }
    //editor:gyq_20191216 reason:0038913: 安装包、升级包>常用报表>考勤异常明细表、月度考勤统计表、请假明细表、：点击导出Excel报错。
    //打印
    public function report_export($exportheader,$r_report_list_view,$rListContentExist='no'){
        //editor:gyq_135 reason:绕过getReportListView，方便更灵活调用  2019/8/14 13:35 ID1000568
        if($rListContentExist==='no')
            $csc = explode("</tr>",$this->getReportListView());
        else
            $csc = explode("</tr>",$r_report_list_view);
        include( globalStatic::$root_directory.'PHPExcel/PHPExcel.php');
        $objPHPExcel = new PHPExcel();
        $objPHPExcel->setActiveSheetIndex(0);
        $activesheet=$objPHPExcel->getActiveSheet();
        foreach($exportheader as $key=>$arr){
            $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',$arr);
        }
        $j = 2;
        foreach($csc as $arr){
            $cscs = explode("</td>",$arr);
            $for_i = 0;
            foreach ($cscs as $value) {
                $value = strip_tags(trim($value));
                $value = ltrim($value, '&nbsp;');
                if ($value == '&nbsp;') {
                    $value = '';
                }
                $value = str_replace('&yen;', '¥', strip_tags($value));
                $value = decode_html($value);
                $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($for_i) . $j, $value);
                ++$for_i;
            }
            ++ $j;
        }
        $modulelabel = getTranstab('OftenUseReport');
        $modulelabel = str_replace(' ','_',iconv('UTF-8','gbk',$modulelabel));
        $file_name = 'OftenUseReport.xls';
        //editor:gyq_135 reason:路径有疑问 ./storage/ 2019/8/7 11:51 ID1000568
        $file_dir = globalStatic::$root_directory.'storage/';

        $objPHPExcel->getActiveSheet()->setTitle('OftenUseReport');
        $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
        $objWriter->save($file_dir.$file_name);

        //月度考勤报表导出提示模块未激活
        header('Location: index.php?module=ReportAnalysis&action=ExportReport&ReportHeader=dheader&modulelabel='.$this->report_name.'');
        exit();
    }
    //高级查询
    public function get_advft_html($smarty,$reportabid,$usereportid){
        if($reportabid!=''&&$reportabid!='0')
            $columns_block=getadvDropHtml($reportabid);
        if(!empty($_REQUEST['advft_criteria_groups']) && !empty($_REQUEST['advft_criteria'])){
            $_REQUEST['searchtype'] = 'advSearch';
        }
        if($_REQUEST['searchtype']=='advSearch')
        {
            require_once 'include/Zend/Json.php';
            $json = new Zend_Json();
            $advft_criteria = $_REQUEST['advft_criteria'];
            if(!empty($advft_criteria)) $advft_criteria = $json->decode($advft_criteria);
            $advft_criteria_groups = $_REQUEST['advft_criteria_groups'];
            if(!empty($advft_criteria_groups)) $advft_criteria_groups = $json->decode($advft_criteria_groups);
            crm_load_class_file('cls_QueryGenerator','modules/OftenUseReport');
        }
        //高级查询保存
        if(isset($_REQUEST['submode'])&& $_REQUEST['submode']=='saveCriteria')
        {
            updateUseReportCriteria($usereportid,$advft_criteria,$advft_criteria_groups);
        }
        //读取高级查询
        $advft_criteria=getAdvancedFilterList($usereportid);
        $smarty->assign("COLUMNS_BLOCK",$columns_block[0]);
        $smarty->assign("FOPTION",getAdvCriteriaHTML());
        $smarty->assign("REL_FIELDS",Zend_Json::encode($columns_block[1]));
        $smarty->assign("CRITERIA_GROUPS",$advft_criteria);
    }
    //版本判断
    public function trade_where($r_trade){
        //SalesOrderImplementation:德卡报表：合同执行情况明细表
        //CourseEnquiryReport:培训行业报表
        if($r_trade=='training'){
            $parentwhere = "";
            $where = " and name not in ('SalesOrderImplementation') ";
        }
        else if($r_trade=='德卡'){
            $parentwhere = " and name not in ('CourseEnquiryReport')";
            $where = "";
        }
        else
        {
            $parentwhere = " and name not in ('CourseEnquiryReport')";
            $where = " and name not in ('SalesOrderImplementation') ";
        }
        if(!vtlib_isModuleActive('ServiceContracts')&&!vtlib_isModuleActive('SalesOrder')){
            $where .= " and name not in ('SalesOrderTrack','Contractnumber','Contractamount') ";
        }
        if($r_trade!='jierun'){
            $parentwhere .= " and name not in ('JIERUNREPORTS') ";
        }
        if($r_trade!='lueyang'){
            $where .= " and name not in ('Reportingpaymentschedulestatistics') ";
        }
        if($r_trade!='xycp'){
            $parentwhere .= " and name not in ('XuanYuanLawn')";
        }
        if($r_trade!='zhongyuan'){
            $parentwhere .= " and name not in ('ZHONGYUANREPORTS')";
        }
        if($r_trade!='futai'){
            $where .= " and name not in ('hoursqueryreport')";
        }
        if($r_trade!='ruiai'){
            $where .= " and name not in ('librarytrackreport')";
        }
        if($r_trade!='yuanzhou'){
            $where .= " and name not in ('yuanzhoureport')";
        }

        if(!vtlib_isModuleActive('Potentials')){
            $where .= " and name not in ('Salesforecastandanalysistable') ";
        }
        if(!vtlib_isModuleActive('CashBill')){
            $where .= " and name not in ('THESINGNINGAMOUNTOFBILLBOARD','CashBillSum_Paymentplan','CashBillSum_SalesOrder','Performancestatisticscollection') ";
        }
        if(!vtlib_isModuleActive('PurchaseOrder')){
            $where .= " and name not in ('PurchaseOrderTrack') ";
        }
        if(!vtlib_isModuleActive('Project')){
            $where .= " and name not in ('Thestatisticalreportofprojectperformance') ";
        }
        if(!vtlib_isModuleActive('SendCashBill')){
            $where .= " and name not in ('SendCashBillSum_PurchaseOrder','SendCashBillSum_SendPayment') ";
        }
        if(!vtlib_isModuleActive('OutboundOrder')){
            $where .= " and name not in ('CashBillSum_Outboundorder') ";
        }
        return array('where'=>$where,'parentwhere'=>$parentwhere);
    }

    //生成人员范围筛选条件
    public function SmOwnerSearchScope(){
        $where='';
        global $adb, $current_user,$currentModule;

        $scope = $_REQUEST['SmOwnerSearchScope'];
        $userids = $receiverid = $_REQUEST['receiverid'];
        if(!$scope){
            $scope='SmOwner_Search_All';
        }
        switch($scope)
        {
            case 'SmOwner_Search_All':
                $Smownerids= getCurSmOwnerSearchScope('ReportAnalysis');

                foreach($Smownerids['UserCombo']as $userid=>$userinfo)
                {
                    if($userids == "")
                    {
                        $userids .=$userid;
                    }
                    else
                    {
                        $userids .=",".$userid;
                    }
                }
                $userids.=",".$current_user->id;
                break;
            case 'SmOwner_Search_Me':
                $userids = $current_user->id;
                break;
            case 'SmOwner_Search_Create':
                $userids = $current_user->id;
                break;
            case 'SmOwer_Search_ShareMe':
                $where="  and ld_tabshare.viewuserid =".$current_user->id."";
                break;
            case 'smowner_search_senior':
                if(!empty($userids)){
                    $where .=" and ld_singin.userid in ( ".$userids.")";
                }
                break;
            case 'SmOwner_Search_Group':
                $query = 'select userid from ld_users2group where groupid in ('.$receiverid.') group by userid';
                $result = $adb->pquery($query,array());
                $num_rows = $adb->num_rows($result);
                for($i = 0; $i<$num_rows; $i++){
                    $userid_array[] = $adb->query_result($result,$i,'userid');
                }
                //zxm 2022-1111 常用报表改成报表分析的数据范围
                $ScopOfAuthority = ScopOfAuthority::getInstance($adb,$currentModule);
                //editor:gyq_20190412 0036848: （http://kehu001.com/KH/kh32777 [^]）常用表报>签到统计表>筛选条件选择全部：
                //点击按部门范围进行查找显示没有数据，按全部是有数据的。
                $CurUserScopeId = $ScopOfAuthority->getCurUserScopeId();
                if($CurUserScopeId=='All'){
                    $intersection = $userid_array;
                }else{
                    $intersection = array_intersect($userid_array,$ScopOfAuthority->getUserModuleScopeHigher());
                }
                $userids = implode(',',$intersection);
                if(empty($userids))$userids = 0;
                break;
            default:
                $userids = $scope;
        }
        return $userids;
    }
    //部门名称列表
    public function group_label_list(){
        global $adb;
        $group_label_list = array();
        $sql = 'select groupid,groupname from ld_groups';
        $result = $adb->pquery($sql,array());
        $nums  = $adb->num_rows($result);
        for($i=0;$i<$nums;$i++){
            $group_label_list[$adb->query_result($result,$i,'groupid')] = $adb->query_result($result,$i,'groupname');
        }
        return $group_label_list;
    }
    //即时库存查询
    public function InventoryQuery(){
        global $adb;
        $productname = $_REQUEST['basicotherfind5'];
        $pici = $_REQUEST['basicotherfind4'];
        $cangku = $_REQUEST['basicotherfind3'];
        $shenpi = $this->setDefaultShenPi($_REQUEST['basicotherfind6'])  ;
        //editor:gyq_122 reason:获取仓库名称列表  2019/6/13 11:09
        $new_ware = $this->getOftenUserReport_WareHouse();
        if(empty($cangku)){
            $cangku = $new_ware['wareid'];
		}
        if(empty($pici))
            $pici = '';
        //editor:gyq_20181219 0035805: （1.6登录）即时库存查询报表界面：直接点击“待入库数量”或“待出库数量”时，弹出层中不显示单据明细数据，点击【生成报表】后，弹出层中才显示单据明细数据。预期结果：直接点击“待入库数量”或“待出库数量”时，弹出层中应该也显示单据明细数据
        $basicotherfind = $cangku.','.$pici.','.$productname.','.$shenpi;
        crm_load_class_file('ReportSqlInventoryQuery','modules/OftenUseReport/ReportSQL');
        $sql_obj = new ReportSqlInventoryQuery();
        $SQL = $sql_obj->InventoryQuery($cangku,$pici,$productname,$shenpi);

        $showcolLists = $this->showcolLists;
        //单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
        $length_amountdigits = $sysdeploy['deploy_value'];
        $sysdeploy = getSys_deploy(93);
        $length_pricedigits = $sysdeploy['deploy_value'];

        $page_list_result = $this->page_list_result($SQL);
        $result = $page_list_result['result'];
        $numrows = $page_list_result['rows'];
        $list_entry = array();
        $html_content = '';
		if($numrows > 0){
			for($i=0;$i<$numrows;$i++){

				$trclass = 'lvtColData';
				$tr_on = 'on';
				if($i % 2 != 0){
					$trclass = 'lvtColDataBj';
					$tr_on = 'On';
				}//onmouseout="reportListOnMouseOut(0,'on')"
				$html_content .='<tr id="report_'.$i.'" class="'.$trclass.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\''.$tr_on.'\')">';

                $tmprowproductname = $adb->query_result($result,$i,'productname');
                $tmprowproductname_arr = explode(' - ',$tmprowproductname);
                $tmprowproductname = $tmprowproductname_arr[0];
                $tmprowbatchtext = $adb->query_result($result,$i,'batchtext');
                $basicotherfind = $cangku.','.$tmprowbatchtext.','.$tmprowproductname.','.$shenpi;
				foreach ($showcolLists as $fieldkey=>$value){
					$first = stripos($fieldkey,'_');
					$second  = substr($fieldkey,$first+1);
					$third = explode(':',$second);
					//获取显示字段名
					$fieldkey2 = $third[0];
                    $productid = $adb->query_result($result,$i,'productid');
					if($fieldkey2 == 'productname'){
						$list_entry[$i]['record']['bianhao'] = $adb->query_result($result,$i,'productname');
						$list_entry[$i]['record']['module'] = 'Products';
						$list_entry[$i]['record']['id'] = $productid;

						/*$html_content .='<td ><a target=\'_blank\' href=\'index.php?module='.$list_entry[$i]['record']['module'].
							'&action=DetailView&record='.trim($list_entry[$i]['record']['id']).'\'>'.$list_entry[$i]['record']['bianhao'].'</a></td>';*/
                            
                        $html_content .='<td ><a  href=\'javascript:;\' referencemodule="'.$list_entry[$i]['record']['module'].
							'" referencerecord="'.trim($list_entry[$i]['record']['id']).'" onclick="ListReferenceLinkClick(ld(this),event)">'.$list_entry[$i]['record']['bianhao'].'</a></td>';
					}elseif($fieldkey2=='unit_price'){
						$unit_price = $adb->query_result($result,$i,$fieldkey2);
						$html_content .='<td align="right">'.setNumberFormat($adb->query_result($result,$i,$fieldkey2),$length_pricedigits).'</td>';
					}elseif($fieldkey2=='costprice') {
                        $unit_price1 = $adb->query_result($result,$i,'unit_price');
                        $inventory_qty1 = $adb->query_result($result,$i,'inventory_qty');
						$html_content .= '<td align="right">' . setNumberFormat($unit_price1*$inventory_qty1, $length_amountdigits) . '</td>';
					}elseif($fieldkey2=='qtyearly'||$fieldkey2=='inventory_qty'||$fieldkey2=='cha_qty'){

						$qty_format = setNumberFormat($adb->query_result($result, $i, $fieldkey2), $length_amountdigits);
						if($fieldkey2=='inventory_qty'){
							$inventory_qty = $adb->query_result($result,$i,$fieldkey2);
							if($qty_format != 0 && $qty_format !='' && $cangku=='all'){
								$html_content .= '<td align="right"><a  href="javascript:;" onclick="product_detail_qtyinstock('.$productid.',\'report\')">' . $qty_format . '</a></td>';
							}else{
								$html_content .= '<td align="right">' . $qty_format . '</td>';
							}
						}else {
							$html_content .= '<td align="right">' . $qty_format . '</td>';
						}
					}elseif($fieldkey2=='dairu_qty'||$fieldkey2=='daichu_qty') {
						$dairuchu_qty = $adb->query_result($result,$i,$fieldkey2);
						$dairuchu_qty = setNumberFormat($dairuchu_qty, $length_amountdigits);
						if($dairuchu_qty > 0 ){
							$html_content .= '<td align="right"><a href="javascript:void(0)" onclick="setNationDetailReport('.$productid.',\''.$fieldkey2.'\',\''.$basicotherfind.'\')" title="">'.$dairuchu_qty.'</a></td>';
						}else{
							$html_content .='<td align="right">'.$dairuchu_qty.'</td>';
						}
                    }elseif($fieldkey2=='wareid') {
					    //editor:gyq_122 reason:翻译仓库ID  2019/6/13 10:50
                        $fieldvalue = $adb->query_result($result,$i,$fieldkey2);
                        $html_content .='<td>'.$new_ware['all'][$fieldvalue].'</td>';
					}else{
						$fieldvalue = $adb->query_result($result,$i,$fieldkey2);
						$html_content .='<td>'.$fieldvalue.'</td>';
					}
				}
				$html_content .='</tr>';
			}
		}else{
			if($_REQUEST['ajax']=='true'){
				$html_content =  '###ERROR###'.getFixedLabel('USEREPORTENTRIESREMIND3');
				ob_clean();
				echo $html_content;exit;
			}
			//如果没有提示：指定查询范围中没有相应记录，请重新选择。
			//英文提示信息：There is no record in the specified query scope. Please choose again.
		}
        return $html_content;
    }
    //获取库存流水账报表editor:gyq_86 reason:产品批次 2018/11/20 14:37
    public function InventoryAccount(){
        global $adb;
        $this->clearTempotatyTable();
        $showcolLists = $this->showcolLists;

        $startmonth = $_REQUEST['startmonth'];
        $endmonth = $_REQUEST['endmonth'];
        $find3 = $_REQUEST['basicotherfind3'];//仓库
        if(empty($find3)){
			$new_ware = $this->getOftenUserReport_WareHouse();
            $find3 = $new_ware['wareid'];
        }
        $find4 = $_REQUEST['basicotherfind4'];//批次
        $shenpi = $this->setDefaultShenPi($_REQUEST['basicotherfind6']);
        $productname = $_REQUEST['basicotherfind5'];

        crm_load_class_file('ReportSqlInventoryAccount','modules/OftenUseReport/ReportSQL');
        $sql_obj = new ReportSqlInventoryAccount();
        $SQL = $sql_obj->InventoryAccount($startmonth,$endmonth,$find3,$find4,$shenpi,$productname);

        //单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
        $length_amountdigits = $sysdeploy['deploy_value'];
        $sysdeploy = getSys_deploy(93);
        $length_pricedigits = $sysdeploy['deploy_value'];

        $page_list_result = $this->page_list_result($SQL);
        $result = $page_list_result['result'];
        $numrows = $page_list_result['rows'];

        $list_entry = array();
        $html_content = '';
		if($numrows > 0){
			for($i=0;$i<$numrows;$i++){
				if($i % 2 != 0){
					$trclass = 'lvtColDataBj';
					$tr_on='On';
					$html_content .='<tr id="report_'.$i.'" class="'.$trclass.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),'.'\'On\''.')">';
				}else{
					$trclass = 'lvtColData';
					$tr_on='on';
					$html_content .='<tr id="report_'.$i.'" class="'.$trclass.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')">';
				}
				foreach ($showcolLists as $fieldkey=>$value){
					$first = stripos($fieldkey,'_');
					$second  = substr($fieldkey,$first+1);
					$third = explode(':',$second);
					//获取显示字段名
					$fieldkey2 = $third[0];

					if($fieldkey2 == 'bill_no'){
						$list_entry[$i]['record']['bianhao'] = $adb->query_result($result,$i,'bill_no');
						$list_entry[$i]['record']['module'] = $adb->query_result($result,$i,'billtype');
						$list_entry[$i]['record']['id'] = $adb->query_result($result,$i,'bill_id');
						//$html_content .='<td><a target=\'_blank\' href=\'index.php?module='.$list_entry[$i]['record']['module'].
                    //		'&action=DetailView&record='.trim($list_entry[$i]['record']['id']).'\'>'.$list_entry[$i]['record']['bianhao'].'</a></td>';
                            $html_content .='<td ><a  href=\'javascript:;\' referencemodule="'.$list_entry[$i]['record']['module'].
							'" referencerecord="'.trim($list_entry[$i]['record']['id']).'" onclick="ListReferenceLinkClick(ld(this),event)">'.$list_entry[$i]['record']['bianhao'].'</a></td>';
					}elseif($fieldkey2=='productname'){
						$list_entry[$i]['product']['id'] = $adb->query_result($result,$i,'productid');
						$list_entry[$i]['product']['name'] = $adb->query_result($result,$i,'productname');
					//	$html_content .='<td><a target=\'_blank\' href=\'index.php?module=Products
//					&action=DetailView&record='.trim($list_entry[$i]['product']['id']).'\'>'.$list_entry[$i]['product']['name'].'</a></td>';
                    $html_content .='<td ><a  href=\'javascript:;\' referencemodule="Products" referencerecord="'.trim($list_entry[$i]['product']['id']).'" onclick="ListReferenceLinkClick(ld(this),event)">'.$list_entry[$i]['product']['name'].'</a></td>';
					}else{
						$fieldvalue = $adb->query_result($result,$i,$fieldkey2);
						$html_content .='<td>'.$fieldvalue.'</td>';
					}
				}
				//判断是收入还是发出
				$sendout_qty = $adb->query_result($result,$i,'sendout_qty');
				$income_qty = $adb->query_result($result,$i,'income_qty');
				//发出
				if($income_qty==0.00000000&&$sendout_qty!=0.00000000){
					$html_content .='<td></td><td></td><td></td>';
					$list_entry[$i]['sendout_price'] =  setNumberFormat($adb->query_result($result,$i,'sendout_price'),$length_pricedigits);
					$html_content .='<td align="right">'.$list_entry[$i]['sendout_price'].'</td>';
					$list_entry[$i]['sendout_qty'] =  setNumberFormat($adb->query_result($result,$i,'sendout_qty'),$length_amountdigits);
					$html_content .='<td align="right"><font color="green">'.$list_entry[$i]['sendout_qty'].'</font></td>';
					$list_entry[$i]['sendout_amount'] =  setNumberFormat($adb->query_result($result,$i,'sendout_amount'),$length_pricedigits);
					$html_content .='<td align="right">'.$list_entry[$i]['sendout_amount'].'</td>';
				}elseif($income_qty==0.00000000&&$sendout_qty==0.00000000){
					$html_content .='<td></td><td></td><td></td><td></td><td></td><td></td>';
				}elseif($income_qty!=0.00000000&&$sendout_qty==0.00000000){
					//收入
					$list_entry[$i]['income_price'] = setNumberFormat($adb->query_result($result,$i,'income_price'),$length_pricedigits);
					$html_content .='<td align="right">'.$list_entry[$i]['income_price'].'</td>';
					$list_entry[$i]['income_qty'] = setNumberFormat($adb->query_result($result,$i,'income_qty'),$length_amountdigits);
					$html_content .='<td align="right"><font color="red">'.$list_entry[$i]['income_qty'].'</font></td>';
					$list_entry[$i]['income_amount'] = setNumberFormat($adb->query_result($result,$i,'income_amount'),$length_pricedigits);
					$html_content .='<td align="right">'.$list_entry[$i]['income_amount'].'</td>';
					$html_content .='<td></td><td></td><td></td>';
				}
				$html_content .='</tr>';
			}
		}else{
			if($_REQUEST['ajax']=='true'){
				$html_content =  '###ERROR###'.getFixedLabel('USEREPORTENTRIESREMIND3');
				ob_clean();
				echo $html_content;exit;
			}
			//如果没有提示：指定查询范围中没有相应记录，请重新选择。
			//英文提示信息：There is no record in the specified query scope. Please choose again.
		}
        return $html_content;
    }
    //库存台账
    public function InventoryLedger(){
        global $adb;
        //editor:gyq_140 reason:库存台账当前产品显示的字段  2019/8/30 11:15
        $static_label_field = array('product_no','usageunit','made_in','productdate');
        $this->reportname = 'InventoryLedger';
        $this->clearTempotatyTable();
        $startmonth = $_REQUEST['startmonth'];
        $endmonth = $_REQUEST['endmonth'];
        $productname = $_REQUEST['basicotherfind5'];
        $pici = $_REQUEST['basicotherfind4'];
        $shenpi = $this->setDefaultShenPi($_REQUEST['basicotherfind6']);
        $productid_re = $_REQUEST['productid_current'];
        $cangku = $_REQUEST['basicotherfind3'];//仓库
        //editor:gyq_122 reason:增加$this->ware_list,以便getProductInfo方法中使用 2019/6/14 16:01
        $new_ware= $this->ware_list = $this->getOftenUserReport_WareHouse();
        if(empty($cangku)){
            $cangku = $new_ware['wareid'];
        }
        if(empty($pici))
            $pici = '';
        crm_load_class_file('ReportSqlInventoryLedger','modules/OftenUseReport/ReportSQL');
        $sql_obj = new ReportSqlInventoryLedger();

        //判断是否是前进后退的操作
        if($productid_re > 0){
            $sql_second = $sql_obj->getInventoryLedgerSecond($startmonth,$endmonth,$cangku,$pici,$productid_re,$shenpi);
            $page_list_result = $this->page_list_result($sql_second);
            $result = $page_list_result['result'];
            $html_content_cell = $this->getProductInfo($sql_obj->cls_adb,$result);
            $html_content = $html_content_cell;
            return $html_content;
        }else{
            $sql_first = $sql_obj->getInventoryLedgerFirst($startmonth,$endmonth,$cangku,$pici,$productname,$shenpi);
            $sql_first_result  = $adb->pquery($sql_first,array());
            $num_rows = $adb->num_rows($sql_first_result);
            $html_content = '';
            if($num_rows > 0){
                $record_field_label = array();
                $productname_arr = array();
                $productinfo_arr = array();
                $fieldobj = Field::getInstance('Products',$adb);
                foreach ($static_label_field as $value){
                    $columnobj = $fieldobj->getFieldByColumnName($value);
                    if(is_object($columnobj))
                        $record_field_label[$value] = $columnobj->fieldLableKey;
                }
                for($i=0;$i<$num_rows;$i++){
                    $cell_productid = $adb->query_result($sql_first_result,$i,'productid');
                    $productname = $adb->query_result($sql_first_result,$i,'productname');
                    $productids[$i] = $cell_productid;
                    $productname_arr[$i] = $productname;
                    $productinfo_arr[$i]['productid'] = $cell_productid;
                    $productinfo_arr[$i]['productname'] = $productname;
                    //产品详情
                    foreach ($static_label_field as $value){
                        $productinfo_arr[$i][$value] = $adb->query_result($sql_first_result,$i,$value);
                    }
                }
                $tr_key = 0;
                foreach ($productids as $key=>$value){
                    $sql_second = $sql_obj->getInventoryLedgerSecond($startmonth,$endmonth,$cangku,$pici,$value,$shenpi);

                    $page_list_result = $this->page_list_result($sql_second);
                    $result = $page_list_result['result'];

                    $html_content_cell = $this->getProductInfo($sql_obj->cls_adb,$result);
                    $html_content .= $html_content_cell;
                    if(!empty($html_content_cell)){
                        break;
                    }
                    $tr_key++;
                }
                $_REQUEST['InventoryLedger_Productids'] = array('ids'=>$productids,'name'=>$productname_arr,'current'=>$tr_key,'current_name'=>$productname_arr[0]) ;
                $_REQUEST['InventoryLedger_ProductidInfo'] = $productinfo_arr ;
                $_REQUEST['InventoryLedger_ProductidLabel'] = $record_field_label ;
            }else{
                if($_REQUEST['ajax']=='true'){
                    $html_content =  '###ERROR###'.getFixedLabel('USEREPORTENTRIESREMIND3');
                    ob_clean();
                    echo $html_content;exit;
                }
                //如果没有提示：指定查询范围中没有相应记录，请重新选择。
                //英文提示信息：There is no record in the specified query scope. Please choose again.
            }
            return $html_content;
        }

    }
    //库存台账报表获取每个产品的信息
    public function getProductInfo($r_adb,$r_result){
        $html_content = '';
        $showcolLists = $this->showcolLists;
        $adb = $r_adb;
        $result = $r_result;
        $numrows = $adb->num_rows($r_result);
        //单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
        $length_amountdigits = $sysdeploy['deploy_value'];
        $sysdeploy = getSys_deploy(93);
        $length_pricedigits = $sysdeploy['deploy_value'];

        $list_entry = array();
        for($i=0;$i<$numrows;$i++){
            $trclass = 'lvtColData';
            $tr_on='on';
            if($i % 2 != 0){
                $trclass = 'lvtColDataBj';
                $tr_on='On';
            }
            $html_content .='<tr id="report_'.$i.'" class="'.$trclass.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\''.$tr_on.'\')">';
            foreach ($showcolLists as $fieldkey=>$value){
                $first = stripos($fieldkey,'_');
                $second  = substr($fieldkey,$first+1);
                $third = explode(':',$second);
                //获取显示字段名
                $fieldkey2 = $third[0];
                $list_entry[$i]['record']['bianhao'] = $adb->query_result($result, $i, 'bill_no');
                $list_entry[$i]['record']['module'] = $adb->query_result($result, $i, 'billtype');
                $list_entry[$i]['record']['id'] = $adb->query_result($result, $i, 'bill_id');
                if ($fieldkey2 == 'bill_no') {
                    $list_entry[$i]['record']['bianhao'] = $adb->query_result($result, $i, 'bill_no');
                    $list_entry[$i]['record']['module'] = $adb->query_result($result, $i, 'billtype');
                    $list_entry[$i]['record']['id'] = $adb->query_result($result, $i, 'bill_id');
                    //$html_content .= '<td><a target=\'_blank\' href=\'index.php?module=' . $list_entry[$i]['record']['module'] .
//                        '&action=DetailView&record=' . trim($list_entry[$i]['record']['id']) . '\'>' . $list_entry[$i]['record']['bianhao'] . '</a></td>';
                    $html_content .='<td ><a  href=\'javascript:;\' referencemodule="'.$list_entry[$i]['record']['module'].
							'" referencerecord="'.trim($list_entry[$i]['record']['id']).'" onclick="ListReferenceLinkClick(ld(this),event)">'.$list_entry[$i]['record']['bianhao'].'</a></td>';
                            
                } elseif ($fieldkey2 == 'out_no') {
                    $fieldvalue = $adb->query_result($result, $i, 'billtype_label');
                    $html_content .= '<td>' . $fieldvalue . '</td>';
                } elseif ($fieldkey2 == 'wareid') {
                    $fieldvalue = $adb->query_result($result, $i, $fieldkey2);
                    $html_content .= '<td>' . $this->ware_list['all'][$fieldvalue] . '</td>';
                } else {
                    $fieldvalue = $adb->query_result($result, $i, $fieldkey2);
                    $html_content .= '<td>' . $fieldvalue . '</td>';
                }
            }
            //判断是收入还是发出
            $billseq = $adb->query_result($result,$i,'billseq');
            $income_seq = array(0,1,2,5,7);
            $outcome_seq = array(3,4,6,8);
            //发出
            if(in_array($billseq,$outcome_seq)){
                $html_content .='<td></td><td></td><td></td>';
                $list_entry[$i]['sendout_price'] =  setNumberFormat($adb->query_result($result,$i,'sendout_price'),$length_pricedigits);
                $html_content .='<td align="right">'.$list_entry[$i]['sendout_price'].'</td>';
                $list_entry[$i]['sendout_qty'] =  setNumberFormat($adb->query_result($result,$i,'sendout_qty'),$length_amountdigits);
                $html_content .='<td align="right"><font color="green">'.$list_entry[$i]['sendout_qty'].'</font></td>';
                $list_entry[$i]['sendout_amount'] =  setNumberFormat($adb->query_result($result,$i,'sendout_amount'),$length_pricedigits);
                $html_content .='<td align="right">'.$list_entry[$i]['sendout_amount'].'</td>';
            }elseif($billseq==100){
                $html_content .='<td></td><td></td><td></td><td></td><td></td><td></td>';
            }elseif(in_array($billseq,$income_seq)){
                //收入
                $list_entry[$i]['income_price'] = setNumberFormat($adb->query_result($result,$i,'income_price'),$length_pricedigits);
                $html_content .='<td align="right">'.$list_entry[$i]['income_price'].'</td>';
                $list_entry[$i]['income_qty'] = setNumberFormat($adb->query_result($result,$i,'income_qty'),$length_amountdigits);
                $html_content .='<td align="right"><font color="red">'.$list_entry[$i]['income_qty'].'</font></td>';
                $list_entry[$i]['income_amount'] = setNumberFormat($adb->query_result($result,$i,'income_amount'),$length_pricedigits);
                $html_content .='<td align="right">'.$list_entry[$i]['income_amount'].'</td>';
                $html_content .='<td></td><td></td><td></td>';
            }elseif($billseq==101||$billseq==102){
                $list_entry[$i]['income_price'] = setNumberFormat($adb->query_result($result,$i,'income_price'),$length_pricedigits);
                $html_content .='<td align="right">'.$list_entry[$i]['income_price'].'</td>';
                $list_entry[$i]['income_qty'] = setNumberFormat($adb->query_result($result,$i,'income_qty'),$length_amountdigits);
                $html_content .='<td align="right"><font color="red">'.$list_entry[$i]['income_qty'].'</font></td>';
                $list_entry[$i]['income_amount'] = setNumberFormat($adb->query_result($result,$i,'income_amount'),$length_pricedigits);
                $html_content .='<td align="right">'.$list_entry[$i]['income_amount'].'</td>';
                $list_entry[$i]['sendout_price'] =  setNumberFormat($adb->query_result($result,$i,'sendout_price'),$length_pricedigits);
                $html_content .='<td align="right">'.$list_entry[$i]['sendout_price'].'</td>';
                $list_entry[$i]['sendout_qty'] =  setNumberFormat($adb->query_result($result,$i,'sendout_qty'),$length_amountdigits);
                $html_content .='<td align="right"><font color="green">'.$list_entry[$i]['sendout_qty'].'</font></td>';
                $list_entry[$i]['sendout_amount'] =  setNumberFormat($adb->query_result($result,$i,'sendout_amount'),$length_pricedigits);
                $html_content .='<td align="right">'.$list_entry[$i]['sendout_amount'].'</td>';
            }
            $list_entry[$i]['balance_price'] = setNumberFormat($adb->query_result($result,$i,'balance_price'),$length_pricedigits);
            $html_content .='<td align="right">'.$list_entry[$i]['balance_price'].'</td>';
            $list_entry[$i]['balance_qty'] = setNumberFormat($adb->query_result($result,$i,'balance_qty'),$length_amountdigits);
            $html_content .='<td align="right"><font color="blue">'.$list_entry[$i]['balance_qty'].'</font></td>';
            $list_entry[$i]['balance_amount'] = setNumberFormat($adb->query_result($result,$i,'balance_amount'),$length_pricedigits);
            $html_content .='<td align="right">'.$list_entry[$i]['balance_amount'].'</td>';
            $html_content .='</tr>';
        }
        return $html_content;
    }
    //对序时簿Result进行分页处理
    public function page_list_result($r_sql,$r_para=array()){
        global $adb;
        $result_orign = $adb->pquery($r_sql,$r_para);
        $numrows_orign = $adb->num_rows($result_orign);
        //editor:gyq_20191211 reason:0038728: （http://51mis.com/demo/juzi191107/ [^]）考勤异常统计表：导出Excel表时应该导出全部数据，目前只导出了第一页的数据（需要补丁）
        if($_REQUEST['Export']==true && $this->report_parent_type=='checkin'){
            $arr['rows'] = $numrows_orign;
            $arr['result'] = $result_orign;
            $arr['page_list_query'] = $r_sql;
        }else {
            $page_sql = $this->page_list_query($numrows_orign, $r_sql);
            //editor:gyq_20181212	0035741: 报表-常用报表-库存报表-库存台账，库存流水账，即时库存查询，导出excel，应该是导出全部数据，不应是只导出本页数据
            if ($_REQUEST['Export'] == true) {
                $arr['rows'] = $numrows_orign;
                $arr['result'] = $result_orign;
                $arr['page_list_query'] = $page_sql;
            } else {
                $recordListRangeMsg = getRecordRangeMessage($result_orign, '', $numrows_orign);
                $this->page_html_arr['total'] = $recordListRangeMsg;
                $navigation_array = VT_getSimpleNavigationValues($_REQUEST['start'], $this->report_pagerecordcount, $numrows_orign);
                if ($this->reportname == 'InventoryLedger') {
                    $module = $this->reportname;
                } else {
                    $module = 'report_cangku';
                }
                $this->page_html_arr['redirect_num'] = getTableHeaderSimpleNavigation2($navigation_array, '', $module, 'index', '');
                if ($this->report_parent_type == 'kucun') {
                    $result = $adb->pquery($page_sql, array($r_para));
                    $numrows = $adb->num_rows($result);
                    $arr['rows'] = $numrows;
                    $arr['result'] = $result;
                }
                $arr['page_list_query'] = $page_sql;
            }
        }
        return $arr;
    }
    //库存报表分页查询语句
    public function page_list_query($noofrows, $page_list_query)
    {
        //序时簿列表每页显示记录条数
        if(empty($this->report_pagerecordcount)){
            //zxm 20230629 13的系统参数被删掉了 所以取这个全局变量
            global $list_max_entries_per_page_new;
            $this->report_pagerecordcount = $mobile_pagerecordcount = $list_max_entries_per_page_new;
        }else{
            $mobile_pagerecordcount = $this->report_pagerecordcount;
        }

        $endpagenum = $mobile_pagerecordcount;
        $endpagerecord = $mobile_pagerecordcount;
        $haveprevpage = 'yes';
        $havenextpage = 'yes';
        $totalpagecount = ceil($noofrows / $mobile_pagerecordcount);
        if ($totalpagecount * $mobile_pagerecordcount < $noofrows) {
            $totalpagecount += 1;
        }
        if (!isset($_REQUEST['start'])) {
            $_REQUEST['start'] = 1;
        }
        $startpagenum = $_REQUEST['start'] - 1;
        if ($_REQUEST['start'] >= $totalpagecount)//是否有下一页
        {
            $havenextpage = 'no';
            $startpagenum = $totalpagecount - 1;
        }
        if ($_REQUEST['start'] <= 1)//是否有上一页
        {
            $haveprevpage = 'no';
            $startpagenum = 0;
        }
        $startpagerecord = $startpagenum * $mobile_pagerecordcount;

        $page_list_query .= ' LIMIT ' . $startpagerecord . ',' . $mobile_pagerecordcount;

        return $page_list_query;
    }
    //editor:gyq_86 reason:库存报表,即时库存查询  待出入库数量 明细  2018/12/3 16:07
    public function InventoryQuery_ProductDetailQuery($r_cangku,$r_pici,$r_productname,$r_shenpi,$r_productid,$r_churu_type){
        global $adb;
        crm_load_class_file('ReportSqlInventoryQuery','modules/OftenUseReport/ReportSQL');
        $sql_obj = new ReportSqlInventoryQuery();
        $SQL = $sql_obj->ProductDetailQuery($r_cangku,$r_pici,$r_productname,$r_shenpi,$r_productid,$r_churu_type);

        $result = $adb->pquery($SQL,array());
        $numrows = $adb->num_rows($result);

        //单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
        $length_amountdigits = $sysdeploy['deploy_value'];

        $nationarr = array();
        for ($i=0;$i<$numrows;$i++){
            $nationarr[$i]['ware_no'] = $adb->query_result($result,$i,'fieldlabel');
            $nationarr[$i]['bill_no'] ='<a  href=\'javascript:;\' referencemodule="'.$adb->query_result($result,$i,'billtype').
							'" referencerecord="'.trim($adb->query_result($result,$i,'billid')).'" onclick="ListReferenceLinkClick(ld(this),event)">'.$adb->query_result($result,$i,'bill_no').'</a>';
            $nationarr[$i]['id'] = $i+1;
            $nationarr[$i]['quantity'] = setNumberFormat($adb->query_result($result,$i,'qyt'),$length_amountdigits);
            $nationarr[$i]['presence'] = $adb->query_result($result,$i,'presence');
            $nationarr[$i]['createdtime'] = $adb->query_result($result,$i,'bill_date');
            $nationarr[$i]['smownerid'] = $adb->query_result($result,$i,'last_name');
            $nationarr[$i]['modifiedtime'] = $adb->query_result($result,$i,'modifiedtime');
        }
        return $nationarr;
    }
    //根据系统参数给审批赋默认值
    public function setDefaultShenPi($r_shenpi){
        if(empty($r_shenpi)){
            $sys_deploy = getSys_deploy('48');
            $sys_deploy_value = $sys_deploy['deploy_value'];
            if($sys_deploy_value == 1){
                $r_shenpi = 'all';
            }else{
                $r_shenpi = '已批准';
            }
        }
        return $r_shenpi;
    }
    //editor:gyq_101 reason:产品单据明细界面,查看产品所在仓库数量分布情况  2019/1/29 10:52
    public function product_detail_qtyinstock($r_productid,$r_type,$r_cangku='',$r_shenpi=''){
        global $adb,$weixin_user;
        $module = 'Products';
        $title_orign = array(
            'warehouse'=>getFixedLabel('WAREHOUSE'),
            'batch'=>getFixedLabel('BATCH'),
            'inventory'=>getFixedLabel('INVENTORY').getFixedLabel('QUANTITY')
        );
        if($r_type=='detail'){
            $title = $title_orign;
        }else{
            $fieldname_arr = array('product_no','productname','productsheet','usageunit');
            $fieldobj = Field::getInstance($module,$adb);
            foreach ($fieldname_arr as $value){
                $columnobj = $fieldobj->getFieldByColumnName($value);
                $title2[$value]  = $columnobj->fieldLableKey;
            }
            $title = array_merge($title2,$title_orign);
        }
        require_once globalStatic::$root_directory.'modules/OftenUseReport/ReportSQL/ReportSqlInventoryQuery.php';
        $obj_sql = new ReportSqlInventoryQuery();
        //BUG20240304-23 报表分析->即时库存查询，审批状态选择全部，点击库存数量600，弹出层中没有显示仓库明细
        $shenpi = $this->setDefaultShenPi($r_shenpi);
        /*if($weixin_user->environment_weixin){
            //editor:gyq_20190508 reason:ProductDetailWX方法后两个参数需要有默认值

            if(empty($r_cangku)){
                //editor:gyq_20190517 reason:默认全部仓库，不采用PC逻辑调用getOftenUserReport_WareHouse 2019/5/17 17:20
                //0037054: 企业微信-报表-即时库存查询（珞珞计划）：展开库存详情没有数据，全部显示为0
                $r_cangku = 'all';
            }
            $sql = $obj_sql->ProductDetailWX($r_productid,$shenpi,$r_cangku);

        }else{
            $sql = $obj_sql->ProductDetail($r_productid);
        }*/

        if(empty($r_cangku)){
            //editor:gyq_20190517 reason:默认全部仓库，不采用PC逻辑调用getOftenUserReport_WareHouse 2019/5/17 17:20
            //0037054: 企业微信-报表-即时库存查询（珞珞计划）：展开库存详情没有数据，全部显示为0
            $r_cangku = 'all';
        }
        $sql = $obj_sql->ProductDetailWX($r_productid,$shenpi,$r_cangku);

        $result = $adb->pquery($sql,array());
        $nums = $adb->num_rows($result);
        $list_entry = array();
        $list_total = array('warehouse'=>array(),'total'=>0);

        $sysdeploy = getSys_deploy(49);
        $length_amountdigits = $sysdeploy['deploy_value'];
        //产品明细页库存数量
        if($r_type=='detail'){
            for($i=0;$i<$nums;$i++){
                $list_entry[$i]['i'] = $i+1;
                $list_entry[$i]['warehouse'] = $adb->query_result($result,$i,'warehouse');
                $list_entry[$i]['batchtext'] = $adb->query_result($result,$i,'batchtext');
                $list_entry[$i]['inventory_qty'] = setNumberFormat($adb->query_result($result,$i,'inventory_qty'), $length_amountdigits);
            }
        }else{
            //editor:gyq_20190527 0037057: PC端和移动端：查询总库存数量，需要增加按仓库小计，最后增加合计
            //即时库存，产品库存数量分布明细
            $total_i = 0;//拓展序号，用于在列表中插入小计
            $warehouse_list = array();//记录库存数量小计
            $warehouse_havetotal = array();//记录仓库频率
            //下方算法的目的：按仓库进行小计，小计位于每个仓库的下方；库存信息只有一条时，不显示小计
            for ($i = 0; $i < $nums; $i++) {
                $warehouse = $adb->query_result($result, $i, 'warehouse');
                $inventory = $adb->query_result($result, $i, 'inventory_qty');
                $product_no = $adb->query_result($result,$i,'product_no');
                $productname = $adb->query_result($result,$i,'productname');
                if (isset($warehouse_list[$warehouse])) {
                    //记录每个仓库的合计信息
                    $warehouse_list[$warehouse] += $inventory;
                    //记录每个仓库，库存信息出现的频率，以便控制“库存信息只有一条时，不显示小计”
                    $warehouse_havetotal[$warehouse] += 1;
                } else {
                    $warehouse_list[$warehouse] = $inventory;
                    $warehouse_havetotal[$warehouse] = 1;
                }
                //小计情况一：当前库存信息的仓库名与前一个仓库名不一样，给前一个仓库插入合计
                if($total_i > 0 && $warehouse != $list_entry[$total_i - 1]['warehouse']){
                    $pre_warehouse = $list_entry[$total_i - 1]['warehouse'];
                    if($warehouse_havetotal[$pre_warehouse] > 1){
                        $list_entry[$total_i]['warehouse'] = $pre_warehouse.'-'.getFixedLabel('NETTOTAL');
                        $list_entry[$total_i]['batchtext'] = '';
                        $list_entry[$total_i]['inventory_qty'] = setNumberFormat($warehouse_list[$pre_warehouse], $length_amountdigits);
                        $total_i++;
                    }
                }
                $list_entry[$total_i]['i'] = $i+1;
                $list_entry[$total_i]['product_no'] = $product_no;
                $list_entry[$total_i]['productname'] = $productname;
                $list_entry[$total_i]['productsheet'] = $adb->query_result($result,$i,'productsheet');
                $list_entry[$total_i]['usageunit'] = $adb->query_result($result,$i,'usageunit');
                $list_entry[$total_i]['warehouse'] = $warehouse;
                $list_entry[$total_i]['batchtext'] = $adb->query_result($result,$i,'batchtext');
                $list_entry[$total_i]['inventory_qty'] = setNumberFormat($inventory, $length_amountdigits);
                $total_i++;
                //下面的小计情况二、三，其实整个循环已经结束，但以防万一，加了多余代码$total_i++;
                //小计情况二：最后一条库存信息,且有多个仓库，插入小计
                if($total_i > 0&& $nums > 1 && $i+1==$nums && $warehouse_havetotal[$warehouse] > 1 && $warehouse_havetotal[$warehouse] != $nums){
                    $list_entry[$total_i]['warehouse'] = $warehouse.'-'.getFixedLabel('NETTOTAL');
                    $list_entry[$total_i]['batchtext'] = '';
                    $list_entry[$total_i]['inventory_qty'] = setNumberFormat($warehouse_list[$warehouse], $length_amountdigits);
                    $total_i++;
                }
                //小计情况三：最后一条库存信息,只有一个仓库,插入小计
                if($warehouse_havetotal[$warehouse] == $nums && $nums > 1){
                    $list_entry[$total_i]['warehouse'] = $warehouse.'-'.getFixedLabel('NETTOTAL');
                    $list_entry[$total_i]['batchtext'] = '';
                    $list_entry[$total_i]['inventory_qty'] = setNumberFormat($warehouse_list[$warehouse], $length_amountdigits);
                    $total_i++;
                }
                $list_total['total'] += $inventory;
            }
            $total_inventory_num = setNumberFormat($list_total['total'],$length_amountdigits);
            $list_total_multi =array(0=>array('label'=> '合计','value'=>$total_inventory_num));
            if($weixin_user->environment_weixin){
                $title_before = $title;
                $title = array();
                $title['warehouse'] = $title_before['warehouse'];
                $title['batch'] = $title_before['batch'];
                $title['inventory_qty'] = $title_before['inventory'];
            }else{
                $list_entry[$total_i]['warehouse'] = getFixedLabel('TOTAL');
                $list_entry[$total_i]['batchtext'] = '';
                $list_entry[$total_i]['inventory_qty'] = $total_inventory_num;
            }
        }
        $versionInfo = getVersionTradeInfo();

        if($versionInfo['account']=='Audiowell'){
            //XUQIU20241209-03 【奥迪威】需要改查库存中一个字段取值，查库存中“批量”字段取值改成分录中字段“非限制使用库存”字段（管伟涛）
            $this->adwSpecielInventory($r_productid,$title,$list_entry);
        }
        $final_output = array('list'=>$list_entry,'title'=>$title,'total'=>$list_total_multi);
        return $final_output;
    }

    public function adwSpecielInventory($r_productid,&$title,&$list_entry){
        //XUQIU20241209-03 【奥迪威】需要改查库存中一个字段取值，查库存中“批量”字段取值改成分录中字段“非限制使用库存”字段（管伟涛）
        $title['batch'] = '非限制使用库存';
        $title['inventory'] = '限制使用库存';
        //查询SQL
        $adwsql = "select 
            dscf.sf10545 as batchtext,
            detail.productid,
            ld_stock.wareid ,
            w.`name` AS warehouse
            from ld_stockdetail detail 
            left join ld_stockdetailscf dscf on  dscf.lineitem_id=detail.lineitem_id
            inner join ld_stock on detail.id=ld_stock.stock_id
            inner join ( 
                select max(ld_stock.createdtime) as maxcreatedtime  from ld_stock 
                inner join ld_stockdetail on ld_stock.stock_id=ld_stockdetail.id
                where ld_stock.deleted=0 and ld_stockdetail.productid=?
                 group by ld_stock.wareid
            )s on s.maxcreatedtime=ld_stock.createdtime
            LEFT JOIN ld_warehouse w ON w.id=ld_stock.wareid
            where ld_stock.deleted=0 and detail.productid=? ";
        global $adb;
        $res = $adb->pquery($adwsql,array($r_productid,$r_productid));
        $nums = $adb->num_rows($res);
        $wareHouseList = [];
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $warehouse = $adb->query_result($res,$i,'warehouse');
                $warehouse = empty($warehouse)?'nowarehouse':$warehouse;
                $batchtext = $adb->query_result($res,$i,'batchtext');
                $wareHouseList[$warehouse] = $batchtext;
            }
        }
        foreach($list_entry as $k=>$line_entry){
            $tmp_warehouse = $line_entry['warehouse'];
            $tmp_warehouse = empty($tmp_warehouse)?'nowarehouse':$tmp_warehouse;
            $list_entry[$k]['batchtext'] = isset($wareHouseList[$tmp_warehouse])?$wareHouseList[$tmp_warehouse]:0;
        }
    }
}