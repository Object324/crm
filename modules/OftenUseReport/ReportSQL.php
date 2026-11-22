<?php
/**
 * 更新操作
 * edit:can
 * date:20131202
 * reason:常用报表SQL语句(V3.1)
 * */
 
class ReportSQL
{
    static function  getReportSQL($reportname,$reportabid)
    {
        global $current_user;
        if($_REQUEST['searchtype']&&$_REQUEST['searchtype']=='BasicSearch')
        {
            $userids=$_REQUEST['receiverid'];
            $startdate=$_REQUEST['startmonth'];
            $enddate=$_REQUEST['endmonth'];
            $datefindcolumn=$_REQUEST['datefindcolumn'];
            $accountname=$_REQUEST['basicotherfind'];
            $forecastdatewhere = '';
            //销售排行榜
            if('Salesranking' == $reportname){
                if($_REQUEST['salesranking_value'] == 'sendpament_amount'){
                    $datefindcolumn = 'ld_cashbill.cashbilldate';
                }else if($_REQUEST['salesranking_value'] == 'invoice_amount'){
                    $datefindcolumn = 'ld_invoice. invoicedate';
                }else if($_REQUEST['salesranking_value'] == 'out_amount'){
                    $datefindcolumn = 'ld_outboundorder. outdate';
                }else{
                    $datefindcolumn = 'ld_salesorder.signed_data';
                }
            }
            if($reportname!='Serviceperformanceappraisal'&&$reportname!='hoursqueryreport'&&$reportname!='Salesforecastandanalysistable'){
                $where =' and '.$datefindcolumn .' between  \''.$startdate.'\' and \''.$enddate.'\'' ;
                $wherejierun =' and '.$datefindcolumn .' between  \''.$startdate.'\' and \''.$enddate.'\'' ;
                $whereZY = ' ld_projectcf.cf_977 between  \''.$startdate.'\' and \''.$enddate.'\' ';
                if($reportname=='Salesranking'||$reportname=='Contractnumber'||$reportname=='SalesOrderTrack'||$reportname=='CashBillSum_SalesOrder'){
                   $whereServiceContracts=' and ld_servicecontracts.due_date between  \''.$startdate.'\' and \''.$enddate.'\'' ;
                }
            }else if($reportname=='Salesforecastandanalysistable'){

            }
            else{
                //0018859: 常用报表>服务绩效统计表：“今日”数据查询错误。
                if($reportname == 'Serviceperformanceappraisal' && $datefindcolumn == 'ld_troubletickets.realtime'){
                    $startdate = $startdate . ' 00:00:00';
                    $enddate = $enddate . ' 23:59:59';
                }
                $wheretime = ' between  \''.$startdate.'\' and \''.$enddate.'\'';
            }
            if($_REQUEST['basicotherfinds']&&$reportname!='CommencementSchedule'){
                $where.=" and t6.productcategory='".$_REQUEST['basicotherfinds']."' and t6.productname='".$_REQUEST['basicotherfindz']."'";
            }elseif($_REQUEST['basicotherfinds']&&$reportname=='CommencementSchedule'){
                $where.=" and productcategory='".$_REQUEST['basicotherfinds']."' and productname='".$_REQUEST['basicotherfindz']."'";
            }
      
        if($reportname=='Eachprojectcontractincomestatisticsreport'||$reportname=='Allpaymentsstatisticsreport'||$reportname=='Orderexpenditurestatisticsreport'){
            if($_REQUEST['basicotherfind2']){
                $wherejierun.=" and ld_potential.potential_no like '%%".$_REQUEST['basicotherfind2']."%%'";
            }
            if($_REQUEST['basicotherfind3']){
                $wherejierun.=" and ld_account.accountname like '%%".$_REQUEST['basicotherfind3']."%%'";
            }
            if($_REQUEST['basicotherfind4']){
                $wherejierun.=" and ld_salesorder.subject like '%%".$_REQUEST['basicotherfind4']."%%'";
            }
            if($_REQUEST['basicotherfind5']){
                $wherejierun.=" and ld_potential.potentialname like '%%".$_REQUEST['basicotherfind5']."%%'";
            }  
            if($_REQUEST['basicotherfind6']&&$reportname=='Eachprojectcontractincomestatisticsreport'){
                if($_REQUEST['basicotherfind6']=='2'){
                    $wherebill.=" and ifnull(temptable1.total,0) / temptable .total * 100 >= 100";
                }
                if($_REQUEST['basicotherfind6']=='3'){
                    $wherebill.=" and ifnull(temptable1.total,0) / temptable .total * 100 < 100";
                }
            }elseif($_REQUEST['basicotherfind6']&&$reportname=='Allpaymentsstatisticsreport'){
                if($_REQUEST['basicotherfind6']=='2'){
                    $wherebill.=" and (IFNULL(PurchaseOrder_total,0)-IFNULL(temptable1.total, 0)
            	) <=0";
                }
                if($_REQUEST['basicotherfind6']=='3'){
                    $wherebill.=" and (IFNULL(PurchaseOrder_total,0)-IFNULL(temptable1.total, 0)
            	) >0";
                }
            }                  
        }

        if($_REQUEST['basicotherfind2'] && $reportname=='HighAndNewTechnologyEnterpriseSchedule'){
            $whereZY .= " and ld_projectcf.cf_1479 = '".$_REQUEST['basicotherfind2']."'";
        }
        if($_REQUEST['basicotherfind3'] && ($reportname=='HighAndNewTechnologyEnterpriseSchedule' || $reportname=='ProjectCompletionStatisticsReport')){
            $whereZY .= " and ld_project.cf_1478 = '".$_REQUEST['basicotherfind3']."'";
        }
        if($_REQUEST['basicotherfind4'] && ($reportname=='HighAndNewTechnologyEnterpriseSchedule' || $reportname=='ProjectCompletionStatisticsReport')){
            $whereZY .= " and ld_account.accountname like '%%".$_REQUEST['basicotherfind4']."%%'";
        }
        
        if($_REQUEST['basicotherfind2']&&$reportname=='hoursqueryreport'){
            $where.=" and ld_servicecontracts.contract_no like '%%".$_REQUEST['basicotherfind2']."%%'";
        }
        if($_REQUEST['basicotherfind3']&&$reportname=='hoursqueryreport'){
            $where.=" and ld_products.productname like '%%".$_REQUEST['basicotherfind3']."%%'";
        }
        if($_REQUEST['basicotherfind4']&&$reportname=='hoursqueryreport'){
            $where.=" and ld_account.accountname like '%%".$_REQUEST['basicotherfind4']."%%'";
        }
        if($_REQUEST['basicotherfind2']&&$reportname=='PartnerCommencementSchedule'){
            $where.=" and ld_salesordercf.cf_1084='".$_REQUEST['basicotherfind2']."'";
        }
        if($_REQUEST['basicotherfind3']&&($reportname=='LecturerCommencementSchedule'||$reportname=='KPCCommencementDetails'||$reportname=='CourseparticipantsKPClist')){
            $where.=" and ld_salesordercf.cf_1082='".$_REQUEST['basicotherfind3']."'";
        }
        if($_REQUEST['basicotherfind3']&&$reportname=='Xuanyuanlawnbusinessmanagementreport'){
             $where.=" and ld_accountscf.cf_1428='".$_REQUEST['basicotherfind3']."'";
        }
        if($_REQUEST['basicotherfind4']&&$reportname=='Xuanyuanlawnbusinessmanagementreport'){
             $where.=" and ld_products.productname='".$_REQUEST['basicotherfind4']."'";
        }
        if($_REQUEST['basicotherfind3']&&($reportname=='Thestatisticalreportofprojectperformance')){
            $where.=" and ld_project.projectstatus='".$_REQUEST['basicotherfind3']."'";
        }
        if($_REQUEST['basicotherfind4']&&($reportname=='Thestatisticalreportofprojectperformance')){
            $whereprogress =" and ld_project.progress='".$_REQUEST['basicotherfind4']."'";
        }
        if($_REQUEST['basicotherfind4']&&($reportname=='Studentsparticipatinginthetrainingschedule'||$reportname=='CourseparticipantsKPClist'||$reportname=='Contactbusinesstable')){
            $where.=" and ld_contactdetailsSalesOrder.lastname='".$_REQUEST['basicotherfind4']."'";
        }
        if($_REQUEST['basicotherfind5']&&$reportname=='Customersparticipatinginthetrainingschedule'){
            $where.=" and t12.accountname like'%%".$_REQUEST['basicotherfind5']."%%'";
        }
        //echo $_REQUEST['basicotherfindsapp'];
        if($_REQUEST['basicotherfindsapp']&&($reportname=='SalesOrderTrack')&&$_REQUEST['basicotherfindsapp'] == 'true'){
            $whereapp =" and ld_expense.approvestatus='".constant('D_A_S_APPROVED')."'";
            $wherecomm =" and ld_commission.approvestatus='".constant('D_A_S_APPROVED')."'";
        }
        else  if($_REQUEST['basicotherfindsapp']&&($reportname=='PurchaseOrderTrack')&&$_REQUEST['basicotherfindsapp'] == 'true'){
            //35052: 报表-常用报表，采购订单跟踪表这个位置能加“只显示应付款大于0"这个选项
            $whereapp =" and ld_purchaseorder.pay_balance>0 ";
        }
        
        
        else{
            $whereapp = " and 1=1 ";
        } 
		
         //print_r($_REQUEST);
        // echo $_REQUEST['basicotherfindsapp2'];
        //echo $_REQUEST['basicotherfind3'];
        if($_REQUEST['basicotherfind3']&&$reportname=='Serviceperformanceappraisal'&&$_REQUEST['basicotherfind3']!=''){
            $whereservicetype=' and ff1.servicetype="'.$_REQUEST['basicotherfind3'].'"';
        }
        if($_REQUEST['basicotherfindsapp2']&&$reportname=='Serviceperformanceappraisal'&&$_REQUEST['basicotherfindsapp2']=='true'){
           
            $whereapps =" and ld_troubletickets.approvestatus='".constant('D_A_S_APPROVED')."'";
            $wherecomms =" and ld_projecttask.approvestatus='".constant('D_A_S_APPROVED')."'";
        }elseif($_REQUEST['basicotherfindsapp2']&&$reportname=='Serviceperformanceappraisal'&&$_REQUEST['basicotherfindsapp2']=='false'){
           
            $whereapps = " and 1=1 ";
            $wherecomms = ' and 1=1 ';
        }elseif($reportname=='Serviceperformanceappraisal'&&$_REQUEST['basicotherfindsapp2']!=='false' && $_REQUEST['basicotherfindsapp2'] != ''){
            
            $whereapps =" and ld_troubletickets.approvestatus='".constant('D_A_S_APPROVED')."'";
            $wherecomms =" and ld_projecttask.approvestatus='".constant('D_A_S_APPROVED')."'";
        }
        if($reportname=='CashBillSum_SalesOrder' || $reportname=='CashBillSum_Outboundorder'){
            
            {
                $wherePaymentBalance = " HAVING oftenusereport_PaymentBalance <> 0 ";
            }
        }else{
            $wherePaymentBalance = " 1=1 ";
        }
        //echo $whereapps;
       // echo $_REQUEST['basicotherfindsbill'];
        if($_REQUEST['basicotherfindsbill']&&$reportname=='Serviceperformanceappraisal'&&$_REQUEST['basicotherfindsbill']<>0){
            if($_REQUEST['basicotherfindsbill']==1){
                $whereBILL =" and %s<>'ProjectTask'"; 
            }else{
                $whereBILL =" and %s<>'HelpDesk'"; 
            }
        }else{
            //zxm  20210903默认客户服务单 bug-0047826
            $whereBILL =" and %s<>'ProjectTask'";
        }
        if($_REQUEST['basicotherfindsbill']&&$reportname=='SalesOrderTrack'&&$_REQUEST['basicotherfindsbill']<>0){
            if($_REQUEST['basicotherfindsbill']==1){
                $whereBILL =" and %s<>'ServiceContracts'"; 
            }else{
                $whereBILL =" and %s<>'SalesOrder'"; 
            }
        }else{
            //$whereapp = " and 1=1 ";
        }
        global $adb, $current_user, $currentModule,$mod_strings;
        $scope = $_REQUEST['SmOwnerSearchScope'];
		//if(empty($userids) && strtolower($_REQUEST['SmOwnerSearchScope']) == 'smowner_search_senior'){
            //zxm 20220207 注释以下三行 服务绩效统计表按用户查询不生效
//		if(empty($userids)){
//			$scope = 'SmOwner_Search_All';
//		}
          // zxm 2021-0118  //增加销售阶段的筛选 【销售预测分析表，机会编号增加超链接，可根据销售阶段查询】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001000170
          if($reportname=='Salesforecastandanalysistable' ) {
              //$where .= " and ld_potential.sales_stage like '%" . $_REQUEST['potential_salesstage'] . "%' ";
              if($_REQUEST['potential_salesstage']!='') {
                  $potential_salesstage = $_REQUEST['potential_salesstage'];
                  $potential_salesstage = trim($potential_salesstage,',');
				  //chj 2021/11/5 48601: （81mis.com/kfbcrm/index.php）常用报表》销售预测分析表》没有显示数据内容，单据 POT138 数据是符合的
				  if($potential_salesstage != 'all')
					$where .= " and ld_potential.sales_stage in($potential_salesstage) " ;
              }
              //时间查询 zxm 2021-1103 销售机会预测
              $closingdateinput = $_REQUEST['closingdateinput'];
              $receivablesforecastdate = $_REQUEST['receivablesforecastdateinput'];
              if($closingdateinput!=''&&$closingdateinput!='all'){
                  $closingdateinput = getHomeDateScope($closingdateinput);
                  $where .= 'and ld_potential.closingdate '.$closingdateinput.' ';
              }
              if($receivablesforecastdate!=''&&$receivablesforecastdate!='all') {
                  $receivablesforecastdate = getHomeDateScope($receivablesforecastdate);

                  $forecastdatewhere = 'receivablesforecastdate ' . $receivablesforecastdate;
                  //dump($forecastdatewhere);
              }
          }
        if($reportname=='Reportingpaymentschedulestatistics'){
                if($_REQUEST['basicotherfind2']!='')
                $where .=" and cf_1751 like '%%".$_REQUEST['basicotherfind2']."%%'";
                if($_REQUEST['basicotherfind3']!='')
                $where .=" and projectstatus like '%%".$_REQUEST['basicotherfind3']."%%'";
                if($_REQUEST['basicotherfind4']!='')
                $where .=" and IFNULL(ld_salesorder.total, 0) - IFNULL(ld_cashbill.total, 0)>0";
                if($_REQUEST['basicotherfind5']!='')
                $where .=" and ld_account.accountname like '%%".$_REQUEST['basicotherfind5']."%%'";
                if($_REQUEST['basicotherfind6']!='')
                $where .=" and ld_salesorder.subject like '%%".$_REQUEST['basicotherfind6']."%%'";
            }
        //zxm 2022-0328 合同跟踪表  合同类型条件
//            if($reportname=='SalesOrderTrack'){
//                $servicecontract_contracttype_select = $_REQUEST['servicecontract_contracttype_select'];
//                if(!empty($servicecontract_contracttype_select)){
//                    $whereServiceContracts.= ' and find_in_set(ifnull(ld_servicecontracts.contract_type,""),"'.$servicecontract_contracttype_select.'") ';
//                }
//                $salesorder_contracttype_select = $_REQUEST['salesorder_contracttype_select'];
//                if(!empty($salesorder_contracttype_select)){
//                    $where.= ' and find_in_set(ifnull(ld_salesorder.contracttype,""),"'.$salesorder_contracttype_select.'") ';
//                }
//            }
       if($scope){
        switch($scope)
            {
                case 'SmOwner_Search_All':

                $reportabname=getTabname($reportabid);
                //BUG0053178	已分派	严重	zxm  http://www.scyanuo.com:85/crm 四川雅诺；常用报表打印和导出数据是空值(点击搜索也是空值)
                $Smownerids= getCurSmOwnerSearchScope('ReportAnalysis');
                $tmpuserid_arr = array_keys($Smownerids['UserCombo']);
                $tmpuserid_arr[] = $current_user->id;
                $userids = implode(',',$tmpuserid_arr);
//                dump($Smownerids['UserCombo']);
//                foreach($Smownerids['UserCombo']as $userid=>$userinfo)
//                {
//                        if($userids == "")
//                        {
//                            $userids .=$userid;
//                        }
//                        else
//                        {
//                            $userids .=",".$userid;
//                        }
//                }

                $where.='  and %s.smownerid in ( '.$userids.' )';
                $whereServiceContracts.='  and %s.smownerid in ( '.$userids.' )';
                $sharewhere='  or %s.viewuserid in ( '.$userids.' ))';
                $wheres.='  and (%s.smownerid in ( '.$userids.' )';
                $whereZY .= ' and ld_project.smownerid in ('.$userids.')';
                break;
                case 'SmOwner_Search_Me':
                   $where .=" and %s.SmOwnerID=".$current_user->id;
                   $whereServiceContracts.=" and %s.SmOwnerID=".$current_user->id;
                   $sharewhere="  or %s.viewuserid =".$current_user->id.")";
                   $wheres .=" and (%s.SmOwnerID=".$current_user->id;
                   $whereZY .= " and ld_project.smownerid = ".$current_user->id;
                   $userids=$current_user->id;                   
                break;
				case 'SmOwer_Search_ShareMe':
                  // $where .=" and %s.SmOwnerID=".$current_user->id;
                  // $whereServiceContracts.=" and %s.SmOwnerID=".$current_user->id;
                   $sharewhere="  and %s.viewuserid =".$current_user->id.")";
                   //$wheres .=" and (%s.SmOwnerID=".$current_user->id;
                  // $whereZY .= " and ld_project.smownerid = ".$current_user->id;
                   $userids=$current_user->id;                   
                break;
                case 'SmOwner_Search_Create':
                    $where .=" and %s.SmCreatorID=".$current_user->id;
                    $whereServiceContracts .=" and %s.SmCreatorID=".$current_user->id;
                     $sharewhere="  or %s.viewuserid =".$current_user->id.")";
                     $wheres .=" and (%s.SmCreatorID=".$current_user->id;
                     $whereZY .= " and ld_project.smcreatorid=".$current_user->id;
                    $userids=$current_user->id;                    
                break;
                case 'smowner_search_senior':
                    $where .=" and %s.SmOwnerID in ( ".$userids.")";
                    $whereServiceContracts.=" and %s.SmOwnerID in ( ".$userids.")";
                    $sharewhere="  or %s.viewuserid in ( ".$userids."))";
                    $wheres .=" and (%s.SmOwnerID in ( ".$userids.")";
                    $whereZY .=" and ld_project.smownerid in ( ".$userids.")";
                break;
				case 'SmOwner_Search_Group':
					global $adb;
					$query = 'select userid from ld_users2group where groupid in ('.$_REQUEST['receiverid'].') group by userid';
					$result = $adb->pquery($query,array());
					$num_rows = $adb->num_rows($result);
					for($i = 0; $i<$num_rows; $i++){
						$userid_array[] = $adb->query_result($result,$i,'userid');
					}
					$ScopOfAuthority = ScopOfAuthority::getInstance($adb,'ReportAnalysis');
					if($ScopOfAuthority->getUserModuleScoperType() > 1 && $current_user->is_admin != 'on'){
						$intersection = array_intersect($userid_array,$ScopOfAuthority->getUserModuleScopeHigher());
						$intersection[] = $current_user->id;
						$userids = implode(',',$intersection);
					}else{
						$userids = implode(',',$userid_array);
					}
					if(empty($userids))$userids = 0;
                    $where .=" and %s.SmOwnerID in ( ".$userids.")";
                    $whereServiceContracts.=" and %s.SmOwnerID in ( ".$userids.")";
                    $sharewhere="  or %s.viewuserid in ( ".$userids."))";
                    $wheres .=" and (%s.SmOwnerID in ( ".$userids.")";
                    $whereZY .=" and ld_project.smownerid in ( ".$userids.")";
                break;
                default:
                $where .= " and %s.SmOwnerID=".$scope;
                $whereZY .= " and ld_project.smownerid=".$scope;
                $whereServiceContracts .= " and %s.SmOwnerID=".$scope;
                $sharewhere="  or %s.viewuserid =".$scope.")";
                $wheres .= " and (%s.SmOwnerID=".$scope;
                $userids=$scope;                
            }
        }else{
                $reportabname=getTabname($reportabid);
                $Smownerids= getCurSmOwnerSearchScope($reportabname);
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
				if(!empty($userids)){
					$where.='  and %s.smownerid in ( '.$userids.' )';
					$whereServiceContracts.='  and %s.smownerid in ( '.$userids.' )';
					$sharewhere="  or %s.viewuserid in ( ".$userids."))";
					$wheres.='  and (%s.smownerid in ( '.$userids.' )';
					$whereZY .= '  and ld_project.smownerid in ( '.$userids.' )';
				}
        }
        if(isset($_REQUEST['otherfindcolumn'])&&$_REQUEST['basicotherfind']!='')
        {
 
            if($reportname=='SalesOrderTrack'||$reportname=='CashBillSum_SalesOrder')
                $where .=" and ld_accountsalesorder.accountname like '%%".$_REQUEST['basicotherfind']."%%'";
            else if($reportname=='CashBillSum_SalesOrder'&&$_REQUEST['otherfindcolumn']=='ld_cashbill.cashbilldate'
            ||$reportname=='Reportingpaymentschedulestatistics')
            {
            }
            else
                $where .=' and ' .$_REQUEST['otherfindcolumn']." like '%%".$_REQUEST['basicotherfind']."%%'";
            $whereServiceContracts .=' and ld_accountsalesorder.accountname like '."'%%".$_REQUEST['basicotherfind']."%%'";

        }
      }
      else if($_REQUEST['searchtype']=='advSearch')
      {
        require_once 'include/Zend/Json.php';
            $json = new Zend_Json();
            $advft_criteria = $_REQUEST['advft_criteria'];
           // print_r($advft_criteria);
          
            if(!empty($advft_criteria)) $advft_criteria = $json->decode($advft_criteria);
            $advft_criteria_groups = $_REQUEST['advft_criteria_groups'];
            if(!empty($advft_criteria_groups)) $advft_criteria_groups = $json->decode($advft_criteria_groups);
            $where=ReportSQL::RunTimeAdvFilter($advft_criteria,$advft_criteria_groups,$reportabid);
           //print_r($advft_criteria);  echo "<br>";print_r($advft_criteria_groups);echo "<br>".$reportabid;
            //echo $where;
            
            $reportabname=getTabname($reportabid);
            $Smownerids= getCurSmOwnerSearchScope($reportabname);
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
				if(!empty($_REQUEST['hidden_userreportname'])){
					$reportname = $_REQUEST['hidden_userreportname'];
					$startdate=$_REQUEST['startmonth'];
					$enddate=$_REQUEST['endmonth'];
					$datefindcolumn=$_REQUEST['datefindcolumn'];
					if($reportname!='Serviceperformanceappraisal'&&$reportname!='hoursqueryreport'){
						$where .=' and '.$datefindcolumn .' between  \''.$startdate.'\' and \''.$enddate.'\'' ;
					}else{
						//0018859: 常用报表>服务绩效统计表：“今日”数据查询错误。
						if($reportname == 'Serviceperformanceappraisal' && $datefindcolumn == 'ld_troubletickets.realtime'){
							$startdate = $startdate . ' 00:00:00';
							$enddate = $enddate . ' 23:59:59';
						}
						$where .= ' between  \''.$startdate.'\' and \''.$enddate.'\'';
					}
				}
            if(empty($where)){
              $where.=' %s.smownerid in ( '.$userids.' )';  
               $sharewhere="  or %s.viewuserid in ( ".$userids."))";
                $wheres.=' (%s.smownerid in ( '.$userids.' )';  
            }else{
               $where.=' and %s.smownerid in ( '.$userids.' )'; 
                $sharewhere="  or %s.viewuserid in ( ".$userids."))";
                $wheres.=' and (%s.smownerid in ( '.$userids.' )';
            }
            
            
            /**
             * 更新操作
             * edit:can
             * date:20131224
             * reason:6443: 常用报表：点击“转到高级查找”，然后直接点击“立即查找”按钮，结果程序显示“undefined”。
             * */
            if(!empty($where))
            {
              //  $where =' and '.$where;
            }
      }
		//只统计审核通过的单据
		if(!empty($_REQUEST['check_approve_status']) && $_REQUEST['check_approve_status'] == 'yes'){
			if(!empty($_REQUEST['salesranking_value'])){
				if($_REQUEST['salesranking_value'] == 'sendpament_amount'){	//回款金额（收款）
					//$setsystem_approve = getSys_deploy(133);//收款单是否开启审批  0是 1否
					//if($setsystem_approve['deploy_value'] == 1){
						//$where .= ' and %s.checkoutstatus = \'已审核\' ';
					//}else{
						$where .= ' and %s.approvestatus = \'已批准\' ';
					//}
				}else if($_REQUEST['salesranking_value'] == 'out_amount'){	//出库金额（出库）
					$setsystem_approve = getSys_deploy(135);//出库单是否开启审批  0是 1否
					if($setsystem_approve['deploy_value'] == 1){
						$where .= ' and %s.presence = \'已出库\' ';
					}else{
						$where .= ' and %s.approvestatus = \'已批准\' ';
					}
				}else{
					$where .= ' and %s.approvestatus = \'已批准\' ';
					$whereServiceContracts .= ' and %s.approvestatus = \'已批准\' ';
				}
			}else{
				$where .= ' and %s.approvestatus = \'已批准\' ';
				$whereServiceContracts .= ' and %s.approvestatus = \'已批准\' ';
			}
		}
        $versionInfo = getVersionInfo();
        if (!empty($versionInfo['account'])) { //可能有个性化报表开发时
            include_once(globalStatic::$root_directory . 'modules/OftenUseReport/ReportSQLSpecial.php');
        }
        //editor:gyq_17  reason:签约金额、签约数量、回款金额app端共用SQL date:20161009
        crm_load_class_file('cls_MainReportSQL','modules/OftenUseReport');
		//echo $reportname;echo '<br><br>';
        switch(trim($reportname))
        {
            
            case 'SalesOrderTrack'://合同订单跟踪表
                return ReportSQL::getSalesOrderTrack($where,$whereapp,$wherecomm,$whereServiceContracts,$whereBILL);
               
            case 'CashBillSum_Paymentplan'://应收款统计表_按回款计划统计
                return ReportSQL::CashBillSum_Paymentplan($where);
            case 'CashBillSum_SalesOrder'://应收款统计表_按合同订单
                 return ReportSQL::getCashBillSum_SalesOrder($where,$whereServiceContracts,$wherePaymentBalance);
			case 'CashBillSum_Outboundorder'://应收款统计表_按出库单统计
                if($versionInfo['account'] == "zhongwu"){
                    return ReportSQLSpecial::getCashBillSum_Outboundorder_Zhongwu($where,$whereServiceContracts,$wherePaymentBalance);
                }else{
                    return ReportSQL::getCashBillSum_Outboundorder($where,$whereServiceContracts,$wherePaymentBalance);
                }
            case 'SalesSumSequence'://销售统计排名
                return ReportSQL::getSalesSumSequence($userids);
            case 'Contractnumber'://签约数量龙虎榜
                return ReportSQL::getContractnumber($where,$whereServiceContracts);
            case 'Contractamount'://签约金额龙虎榜
                return ReportSQL::getContractamount($where,$whereServiceContracts);
			case 'Salesranking'://销售排行榜 
				if($_REQUEST['salesranking_value'] == 'sendpament_amount'){
				    
					 return ReportSQL::getCashBillamount($where);
				}else if($_REQUEST['salesranking_value'] == 'due_amount'){
					 return ReportSQL::getContractamount($where,$whereServiceContracts);
				}else if($_REQUEST['salesranking_value'] == 'invoice_amount'){
					 return ReportSQL::getInvoiceamount($where);
				}else if($_REQUEST['salesranking_value'] == 'out_amount'){
					 return ReportSQL::getOutboundOrderamount($where);
				}else{
					return ReportSQL::getContractnumber($where,$whereServiceContracts);
				}
			   break;
            case 'THESINGNINGAMOUNTOFBILLBOARD'://回款金额龙虎榜
                return ReportSQL::getCashBillamount($where,$whereServiceContracts);
            case 'PurchaseOrderTrack'://采购订单跟踪表
                return ReportSQL::getPurchaseOrderTrack($where,$whereapp);
            case 'SendCashBillSum_PurchaseOrder'://应付款统计表_按采购订单统计
                return ReportSQL::getSendCashBillSum_PurchaseOrder($where);
            case 'SendCashBillSum_SendPayment'://应付款统计表_按付款计划
                return ReportSQL::getSendCashBillSum_SendPayment($where);
            case 'CommencementSchedule'://开课明细表
                return ReportSQL::getCommencementSchedule($where);
            case 'OverallCommencementSchedule'://总体开课明细表
                return ReportSQL::getOverallCommencementSchedule($where);
            case 'PartnerCommencementSchedule'://伙伴开课明细表
                return ReportSQL::getPartnerCommencementSchedule($where);   
            case 'LecturerCommencementSchedule'://讲师开课明细表
                return ReportSQL::getLecturerCommencementSchedule($where);
            case 'Studentsparticipatinginthetrainingschedule'://学员参训明细表
                return ReportSQL::getStudentsparticipatinginthetrainingschedule($where);
            case 'Customersparticipatinginthetrainingschedule'://客户参训明细表
                return ReportSQL::getCustomersparticipatinginthetrainingschedule($where);             
            case 'KPCCommencementDetails'://嘉博开课明细
                return ReportSQL::getKPCCommencementDetails($where); 
            case 'CourseparticipantsKPClist'://学员参加嘉博课程明细表
                return ReportSQL::getCourseparticipantsKPClist($where);          
            case 'SalesOrderImplementation'://合同执行情况明细表
                return ReportSQL::getSalesOrderImplementation($where);
            case 'Contactbusinesstable'://联系人业务表
                return ReportSQL::getContactbusinesstable($where);
            case 'Performancestatisticscollection'://收款业绩表
                $tradeinfo = getVersionTradeInfo();
                if($tradeinfo['account']=='灵当自用'){
                    require_once(globalStatic::$root_directory."modules/OftenUseReport/ldorderReportSQL.php");
                    return ldorderReportSQL::getPerformancestatisticscollection($where,$startdate,$enddate,$userids,$accountname);
                }else{
                    return ReportSQL::getPerformancestatisticscollection($where,$startdate,$enddate,$userids,$accountname);
                }
            case 'Salesforecastandanalysistable'://>销售预测分析表
                return ReportSQL::getSalesforecastandanalysistable($where,$forecastdatewhere);
            case 'Thestatisticalreportofprojectperformance'://>项目业绩统计表
                return ReportSQL::getThestatisticalreportofprojectperformance($where,$whereprogress);
            case 'Xuanyuanlawnbusinessmanagementreport'://>项目业绩统计表
                return ReportSQL::getXuanyuanlawnbusinessmanagementreport($where);
            case 'Serviceperformanceappraisal'://服务绩效统计表
                return ReportSQL::getServiceperformanceappraisal($where,$wheretime,$whereapps,$wherecomms,$whereBILL,$whereservicetype);
            case 'hoursqueryreport'://复泰课时查询报表
                return ReportSQL::getHoursqueryreport($wherejierun,$wheretime,$wherejierun);
            case 'Eachprojectcontractincomestatisticsreport'://杰润1
                return ReportSQL::getEachprojectcontractincomestatisticsreport($wherejierun,$wherebill,$sharewhere,$wheres);    
            case 'Orderexpenditurestatisticsreport'://杰润2
                return ReportSQL::getOrderexpenditurestatisticsreport($wherejierun,$sharewhere,$wheres); 
            case 'Allpaymentsstatisticsreport'://杰润3
                return ReportSQL::getAllpaymentsstatisticsreport($wherejierun,$wherebill,$sharewhere,$wheres);   
            case 'HighAndNewTechnologyEnterpriseSchedule'://中源 高企进度表
                return ReportSQL::getHighAndNewTechnologyEnterpriseSchedule($whereZY);      
            case 'ProjectCompletionStatisticsReport'://中源 项目完成统计表
                return ReportSQL::getProjectCompletionStatisticsReport($whereZY);
            case 'Reportingpaymentschedulestatistics'://应收款统计表—按申报及款项进度统计
                return ReportSQL::getReportingpaymentschedulestatisticsReport($where);
            case 'yuanzhoureport'://应收款统计表—按申报及款项进度统计
                return ReportSQL::getyuanzhouReport($where);
            case 'librarytrackreport'://ruianreport
                return ReportSQL::getlibrarytrackreport($where);
            default:
             return "";
        }
    }    
    
    static function getlibrarytrackreport($where){
        //echo $where;
       global $adb; 

        $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable1 IGNORE (
                SELECT smownerid,duedate as SalesOrder_duedate,
                cf_1486 as SalesOrder_cf_1486,salesorder_no as SalesOrder_salesorder_no,
                last_name as Users_last_name,cf_1485 as SalesOrder_cf_1485,
                productsheet as Products_productsheet,productname as Products_productname,
                quantity as OutboundOrder_quantity,
                if(fa.currency_id > 1,taxprice/fa.conversion_rate,taxprice) as OutboundOrder_taxprice,
                comment as OutboundOrder_comment,
                name as OutboundOrder_name,ld_salesorder.salesorderid as lbl_action
                FROM ld_salesorder
                LEFT JOIN ld_salesordercf ON ld_salesorder.salesorderid=ld_salesordercf.salesorderid
                LEFT JOIN ld_users ON ld_users.id=ld_salesorder.smownerid
                LEFT JOIN (
                SELECT entitytypeid,productsheet,productname,quantity,taxprice,comment,name,ld_outboundorder.currency_id,
                ld_outboundorder.conversion_rate FROM 
                ld_outboundorder 
                left JOIN ld_outboundorderdetail on ld_outboundorder.out_id = ld_outboundorderdetail.id
                LEFT JOIN ld_outboundorderdetailscf ON ld_outboundorderdetail.lineitem_id=ld_outboundorderdetailscf.lineitem_id
                LEFT JOIN ld_warehouse ON ld_warehouse.id=ld_outboundorder.wareid
                LEFT JOIN ld_products ON ld_outboundorderdetail.productid=ld_products.productid
                where presence='已出库' and ld_outboundorder.deleted=0
                ) AS fa ON ld_salesorder.salesorderid=fa.entitytypeid
                WHERE ld_salesorder.deleted=0 AND sostatus<>'已作废' 
                AND ld_salesorder.approvestatus='已批准' ". sprintf($where,'ld_salesorder').")
                 ;";    
           $adb->query($SQL);     
          //echo $SQL.'<br><br>';  
       $SQL = "Create TEMPORARY table IF NOT EXISTS temptable3 ignore(
                SELECT smownerid,
                ''SalesOrder_duedate,'小计'SalesOrder_cf_1486,''SalesOrder_salesorder_no,
                ''Users_last_name,''SalesOrder_cf_1485,'' as Products_productsheet,
                '' as Products_productname,
                '' as OutboundOrder_quantity,sum(OutboundOrder_taxprice) as OutboundOrder_taxprice,
                '' AS OutboundOrder_comment,
               '' as OutboundOrder_name,''lbl_action
                FROM temptable1 group by smownerid)
                ";
            $adb->query($SQL);     
          //echo $SQL.'<br><br>';   
          $SQL="Create TEMPORARY table IF NOT EXISTS temptable4 ignore(
            select *
             from (SELECT
                *
                 FROM temptable1
                    	UNION ALL
                    		SELECT
                    			*
                    		FROM
                    	temptable3) AS fd2 order by smownerid,lbl_action DESC);";    
             $adb->query($SQL);  
          //echo $SQL.'<br><br>';       
        $SQL="Create TEMPORARY table IF NOT EXISTS temptable2 ignore(
                SELECT  ''smownerid,
                ''SalesOrder_duedate,'合计'SalesOrder_cf_1486,''SalesOrder_salesorder_no,
                ''Users_last_name,''SalesOrder_cf_1485,'' AS Products_productsheet,
                '' AS Products_productname,
                '' AS OutboundOrder_quantity,sum(OutboundOrder_taxprice) AS OutboundOrder_taxprice,
                '' AS OutboundOrder_comment,
               '' AS OutboundOrder_name,''lbl_action
                FROM temptable1
                );";    
           $adb->query($SQL);    
           //echo $SQL.'<br><br>'; 

           $SQL="SELECT
                    		*
                    	FROM
                    		temptable4
                    	UNION ALL
                    		SELECT
                    			*
                    		FROM
                    	temptable2;";    
           //echo $SQL.'<br><br>'; 
           
        return $SQL;  
                        
    }    
    static function getyuanzhouReport($where){
        //echo $where;
       global $adb; 
       $SQL="set @rownum=0;";
       $adb->query($SQL);  
       //echo $SQL.'<br><br>'; 
      // "                @rownum:=@rownum+1 as OftenUseReport_rownum,";
        $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable1 IGNORE (
                SELECT 
                last_name as Users_last_name_order,
                ld_salesorder.salesorderid,
                salesorder_no AS SalesOrder_salesorder_no,
                subject AS SalesOrder_subject,
                last_name AS Users_last_name,accountname AS Accounts_accountname,
                signed_data AS SalesOrder_signed_data,
                ifnull(if(ld_salesorder.currency_id > 1,subtotal/ld_salesorder.conversion_rate,subtotal),0) AS SalesOrder_subtotal,
                ifnull(cashbill.total,0) AS CashBill_subtotal,
                newcashbill.cashbilldate AS CashBill_cashbilldate,
                ifnull(invoice.total,0) AS Invoice_total,newinvoice.invoicedate AS Invoice_invoicedate,
                ifnull(costprice,0) AS Products_costprice,
                ifnull(purchaseorder.total,0) AS PurchaseOrder_subtotal,
                ifnull(ld_commission.taxprice,0) AS Commission_total,
                ifnull(ld_expense.total,0) AS Expense_total,
                round((IFNULL(if(ld_salesorder.currency_id > 1,subtotal/ld_salesorder.conversion_rate,subtotal),0)-IFNULL(costprice,0)-IFNULL(purchaseorder.total,0)-IFNULL(ld_commission.taxprice,0)-IFNULL(ld_expense.total,0))
                /IFNULL(if(ld_salesorder.currency_id > 1,subtotal/ld_salesorder.conversion_rate,subtotal),0),2) AS OftenUseReport_lilv,
                ld_salesorder.salesorderid AS lbl_action
                FROM ld_salesorder 
                LEFT JOIN ld_account ON ld_account.accountid=ld_salesorder.accountid
                left join (
                select ld_salesorder.salesorderid,sum(costprice*quantity) as costprice from ld_salesorder 
                LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id=ld_salesorder.salesorderid
                LEFT JOIN ld_products ON ld_products.productid=ld_salesorderdetail.productid
                group by ld_salesorder.salesorderid
                ) as ld_inventoryproductrel ON ld_inventoryproductrel.salesorderid=ld_salesorder.salesorderid
                LEFT JOIN ld_users ON ld_users.id=ld_salesorder.smownerid
                LEFT JOIN (
                SELECT
                ld_cashbill2paymentplan.entitytypeid AS salesorderid,
                sum(
                if(ld_cashbill.currency_id > 1,ld_cashbill2paymentplan.amount/ld_cashbill.conversion_rate,ld_cashbill2paymentplan.amount)
                ) AS  total
                FROM
                ld_cashbill
                LEFT JOIN ld_cashbill2paymentplan ON ld_cashbill2paymentplan.CashBillID = ld_cashbill.cashbillid
                LEFT JOIN ld_salesorder ON ld_salesorder.salesorderid = ld_cashbill2paymentplan.entitytypeid
                LEFT JOIN ld_servicecontracts ON ld_servicecontracts.servicecontractsid = ld_cashbill2paymentplan.entitytypeid
                WHERE
                ld_cashbill.deleted = 0
                AND ld_cashbill2paymentplan.amount > 0
                AND ld_cashbill.cashbillid > 0 AND ld_cashbill.checkoutstatus='已审核'
                GROUP BY
                ld_cashbill2paymentplan.entitytypeid
                ) AS cashbill ON cashbill.salesorderid=ld_salesorder.salesorderid 
                LEFT JOIN (
                SELECT 	entitytypeid,
                	cashbilldate
                FROM (
                SELECT 
                entitytypeid,
                cashbilldate
                FROM
                ld_cashbill
                LEFT JOIN ld_cashbill2paymentplan ON ld_cashbill.cashbillid = ld_cashbill2paymentplan.CashBillID 
                WHERE deleted=0 AND ld_cashbill.checkoutstatus='已审核'
                ORDER BY ld_cashbill.cashbillid DESC
                ) AS fe3
                GROUP BY
                entitytypeid
                ) AS newcashbill ON newcashbill.entitytypeid=ld_salesorder.salesorderid 
                LEFT JOIN (
                SELECT
                SUM(if(ld_invoice.currency_id > 1,taxprice/ld_invoice.conversion_rate,taxprice)*quantity) AS total,
                entitytypeid
                FROM
                ld_invoice
                LEFT JOIN ld_invoicedetail ON ld_invoicedetail.id = ld_invoice.invoiceid
                WHERE
                ld_invoicedetail.entitytype = 'SalesOrder' AND deleted=0 and approvestatus='已批准'
                GROUP BY
                entitytypeid
                ) AS invoice ON invoice.entitytypeid=ld_salesorder.salesorderid
                LEFT JOIN (
                SELECT 	entitytypeid,
                	invoicedate
                FROM (
                SELECT 
                invoicedate,
                entitytypeid
                FROM
                ld_invoice
                LEFT JOIN ld_invoicedetail ON ld_invoicedetail.id = ld_invoice.invoiceid
                WHERE deleted=0 AND approvestatus='已批准'
                ORDER BY ld_invoice.invoiceid DESC
                ) AS fe3
                GROUP BY
                entitytypeid
                ) AS newinvoice ON newinvoice.entitytypeid=ld_salesorder.salesorderid
                LEFT JOIN (
                SELECT
                SUM(if(ld_purchaseorder.currency_id > 1,taxprice/ld_purchaseorder.conversion_rate,taxprice)*quantity) AS total,
                entitytypeid
                FROM
                ld_purchaseorder
                LEFT JOIN ld_purchaseorderdetail ON ld_purchaseorderdetail.id = ld_purchaseorder.purchaseorderid 
                WHERE deleted=0
                and approvestatus='已批准' and postatus<>'已作废'
                GROUP BY
                entitytypeid
                ) AS purchaseorder ON purchaseorder.entitytypeid=ld_salesorder.salesorderid
                LEFT JOIN (
                SELECT
                SUM(if(ld_commission.currency_id > 1,amount/ld_commission.conversion_rate,amount)) AS taxprice,
                entitytypeid
                FROM
                ld_commission
                LEFT JOIN ld_commission2payment ON ld_commission2payment.commission_id = ld_commission.commission_id
                WHERE
                deleted = 0 and approvestatus='已批准'
                GROUP BY
                entitytypeid
                ) AS ld_commission ON ld_commission.entitytypeid = ld_salesorder.salesorderid 
                LEFT JOIN (
                SELECT
                SUM(if(ld_expense.currency_id > 1,total/ld_expense.conversion_rate,total)) AS total,
                Salesorderid
                FROM
                ld_expense
                WHERE
                deleted = 0 and approvestatus='已批准'
                GROUP BY
                Salesorderid
                ) AS ld_expense ON ld_expense.Salesorderid = ld_salesorder.salesorderid 
                WHERE ld_salesorder.deleted=0 AND sostatus<>'已作废' 
                AND ld_salesorder.approvestatus='已批准' ". sprintf($where,'ld_salesorder').")
                 ;";    
           $adb->query($SQL);     
          //echo $SQL.'<br><br>';   
       $SQL = "Create TEMPORARY table IF NOT EXISTS temptable3 ignore(
                SELECT '小计'Users_last_name_order,'' salesorderid,
                '小计'SalesOrder_salesorder_no,''SalesOrder_subject,Users_last_name,
                ''Accounts_accountname,''SalesOrder_signed_data,sum(SalesOrder_subtotal) as SalesOrder_subtotal,
                sum(CashBill_subtotal) as CashBill_subtotal,
                '' as CashBill_cashbilldate,sum(Invoice_total) as Invoice_total,
                '' AS Invoice_invoicedate,
                sum(Products_costprice) as Products_costprice,sum(PurchaseOrder_subtotal) as PurchaseOrder_subtotal,
                sum(Commission_total) as Commission_total,sum(Expense_total) as Expense_total,''OftenUseReport_lilv,''lbl_action
                FROM temptable1 group by Users_last_name)
                ";
            $adb->query($SQL);     
          //echo $SQL.'<br><br>';         
        $SQL="Create TEMPORARY table IF NOT EXISTS temptable2 ignore(
                SELECT ''OftenUseReport_rownum,'合计'Users_last_name_order,''salesorderid,
                '合计'SalesOrder_salesorder_no,''SalesOrder_subject,''Users_last_name,
                ''Accounts_accountname,''SalesOrder_signed_data,sum(SalesOrder_subtotal) as SalesOrder_subtotal,
                sum(CashBill_subtotal) as CashBill_subtotal,
                '' as CashBill_cashbilldate,sum(Invoice_total) as Invoice_total,
                '' AS Invoice_invoicedate,
                sum(Products_costprice) as Products_costprice,sum(PurchaseOrder_subtotal) as PurchaseOrder_subtotal,
                sum(Commission_total) as Commission_total,sum(Expense_total) as Expense_total,''OftenUseReport_lilv,''lbl_action
                FROM temptable1);";    
           $adb->query($SQL);    
           //echo $SQL.'<br><br>'; 
           $SQL="Create TEMPORARY table IF NOT EXISTS temptable4 ignore(
            select @rownum:=@rownum+1 as OftenUseReport_rownum,
                Users_last_name_order,salesorderid,
                SalesOrder_salesorder_no,SalesOrder_subject,Users_last_name,
                Accounts_accountname,SalesOrder_signed_data,SalesOrder_subtotal,
                CashBill_subtotal,
                CashBill_cashbilldate,Invoice_total,
                Invoice_invoicedate,
                Products_costprice,PurchaseOrder_subtotal,
                Commission_total,Expense_total,OftenUseReport_lilv,lbl_action
             from (SELECT
                *
                 FROM temptable1
                    	UNION ALL
                    		SELECT
                    			*
                    		FROM
                    	temptable3) AS fd2 order by Users_last_name,salesorderid DESC);";    
             $adb->query($SQL);  
           //echo $SQL.'<br><br>'; 
           $SQL="SELECT
                    		*
                    	FROM
                    		temptable4
                    	UNION ALL
                    		SELECT
                    			*
                    		FROM
                    	temptable2;";    
           //echo $SQL.'<br><br>'; 
           
        return $SQL;  
                        
    }    
    static function getReportingpaymentschedulestatisticsReport($where){
        //echo $where;
       global $adb; 
        $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable1 IGNORE (
                	SELECT
                		accountname as Accounts_accountname,
                		ld_salesorder.salesorderid,
                		ld_account.accountid,
                		ld_account.accountid AS paixu,
                		SUBJECT as SalesOrder_subject,
                		productname as Products_productname,
                		potentialname as Potentials_potentialname,
                		salesorder_no as SalesOrder_salesorder_no,
                		project_no as Project_project_no,
                		cf_1751 as Project_cf_1751,
                		potential_users.last_name AS OftenUseReport_businessmanager,
                		cf_1726 as Potentials_cf_1726,
                		cf_1772 as SalesOrder_cf_1772,
                		cf_977 as Project_cf_977,
                		cf_1750 as Project_cf_1750,
                		cf_1109 as SalesOrder_cf_1109,
                		cf_1110 as SalesOrder_cf_1110,
                		cf_1111 as SalesOrder_cf_1111,
                		cf_1704 as SalesOrder_cf_1704,
                		projectstatus as Project_projectstatus,
                		cf_1699 as Project_cf_1699,
                		project_users.last_name AS OftenUseReport_Project_Engineer,
                		cf_1747 as Project_cf_1747,
                		cf_1700 as Project_cf_1700,
                		cf_1746 as Project_cf_1746,
                		cf_1745 as Project_cf_1745,
                		project_modifiedby.last_name AS Project_modifiedby,
                		cf_1773 as Project_cf_1773,
                		ld_project.description AS Project_description,
                		cf_1100 as Potentials_cf_1100,
                		ifnull(ccount,0) as OftenUseReport_ccount,
                		ifnull(ld_cashbill.amount,0) as CashBill_subtotal,
                		ld_cashbill.cashbilldate as CashBill_cashbilldate,
                		ifnull(ld_cashbill.total,0) as CashBill_total,
                		IFNULL(ld_salesorder.total, 0) - IFNULL(ld_cashbill.total, 0) AS CashBill_weishou,
                		ld_cashbill.description AS CashBill_description,
                		cf_1774 as Project_cf_1774,
                		cf_1784 as Project_cf_1784
                	FROM
                		ld_potential
                	LEFT JOIN ld_potentialscf ON ld_potentialscf.potentialid = ld_potential.potentialid
                	LEFT JOIN ld_salesorder ON ld_potential.potentialid = ld_salesorder.potentialid
                	LEFT JOIN ld_salesordercf ON ld_salesorder.salesorderid = ld_salesordercf.salesorderid
                	LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id = ld_salesorder.salesorderid
                	LEFT JOIN ld_products ON ld_salesorderdetail.productid = ld_products.productid
                	AND ld_products.deleted = 0
                	LEFT JOIN ld_account ON ld_account.accountid = ld_salesorder.accountid
                	AND ld_account.deleted = 0
                	LEFT JOIN ld_project ON ld_project.salesorderid = ld_salesorder.salesorderid
                	AND ld_project.deleted = 0
                	LEFT JOIN ld_projectcf ON ld_projectcf.projectid = ld_project.projectid
                	LEFT JOIN ld_users AS project_users ON project_users.id = ld_project.smownerid
                	LEFT JOIN ld_users AS potential_users ON ld_potential.smownerid = potential_users.id
                	LEFT JOIN ld_users AS project_modifiedby ON ld_project.modifiedby = project_modifiedby.id
                	LEFT JOIN (
                		SELECT
                			ld_cashbill2paymentplan.entitytypeid AS salesorderid,
                			SUM(
                
                				IF (
                					ld_cashbill.currency_id > 1,
                					amount / ld_cashbill.conversion_rate,
                					amount
                				)
                			) AS total,
                			ifnull(COUNT(ld_cashbill.cashbillid),0) AS ccount,
                			amount,
                			ld_cashbill.cashbilldate,
                			ld_cashbill.description
                		FROM
                			(SELECT * FROM  ld_cashbill ORDER BY
                			ld_cashbill.cashbillid DESC) AS ld_cashbill
                		INNER JOIN ld_cashbill2paymentplan ON ld_cashbill2paymentplan.CashBillID = ld_cashbill.cashbillid
                		INNER JOIN ld_salesorder ON ld_cashbill2paymentplan.entitytypeid = ld_salesorder.salesorderid
                		WHERE
                			ld_cashbill.deleted = 0
                		AND ld_salesorder.salesorderid > 0
                		AND ld_cashbill.cashbillid > 0
                		GROUP BY
                			ld_cashbill2paymentplan.entitytypeid
                	) AS ld_cashbill ON ld_cashbill.salesorderid = ld_salesorder.salesorderid
                	WHERE
                		ld_potential.deleted = 0
                	AND ld_salesorder.deleted = 0
                	 ". sprintf($where,'ld_project')."
                );";    
           $adb->query($SQL);     
          //echo $SQL.'<br><br>';   
       
        $SQL="Create TEMPORARY table IF NOT EXISTS temptable2 ignore(
                SELECT '小计' Accounts_accountname,salesorderid,accountid,'小计'paixu,
                ''SalesOrder_subject,''Products_productname,''Potentials_potentialname,''SalesOrder_salesorder_no,
                ''SalesOrder_project_no,''Project_cf_1751,'' AS OftenUseReport_businessmanager,
                ''Potentials_cf_1726,''SalesOrder_cf_1772,''Project_cf_977,''Project_cf_1750,''SalesOrder_cf_1109,''SalesOrder_cf_1110,
                ''SalesOrder_cf_1111,''SalesOrder_cf_1704,''Project_projectstatus,''Project_cf_1699,
                '' AS OftenUseReport_Project_Engineer,''Project_cf_1747,''Project_cf_1700,''Project_cf_1746,''Project_cf_1745,'' AS Project_modifiedby
                ,''Project_cf_1773,'' AS Project_description,''Potentials_cf_1100,
                ''OftenUseReport_ccount,SUM(CashBill_subtotal) AS CashBill_subtotal,''CashBill_cashbilldate,SUM(IFNULL(CashBill_total,0)) AS CashBill_total,SUM(IFNULL(CashBill_weishou,0)) AS CashBill_weishou,
                '' AS CashBill_description,
                ''Project_cf_1774,''Project_cf_1784
                FROM temptable1 GROUP BY accountid);";    
           $adb->query($SQL);    
          // echo $SQL.'<br><br>'; 
           $SQL="Create TEMPORARY table IF NOT EXISTS temptable4 ignore(
                SELECT * FROM (SELECT
                    		*
                    	FROM
                    		temptable1
                    	UNION ALL
                    		SELECT
                    			*
                    		FROM
                    	temptable2) AS F2 ORDER BY accountid,paixu,salesorderid);";    
           $adb->query($SQL);  
          // echo $SQL.'<br><br>'; 
           $SQL="SELECT * FROM temptable4 UNION SELECT 
                '合计' Accounts_accountname,'合计'salesorderid,''accountid,'合计'paixu,
                ''SalesOrder_subject,''Products_productname,''Potentials_potentialname,''SalesOrder_salesorder_no,
                ''SalesOrder_project_no,''Project_cf_1751,'' AS OftenUseReport_businessmanager,
                ''Potentials_cf_1726,''SalesOrder_cf_1772,''Project_cf_977,''Project_cf_1750,''SalesOrder_cf_1109,''SalesOrder_cf_1110,
                ''SalesOrder_cf_1111,''SalesOrder_cf_1704,''Project_projectstatus,''Project_cf_1699,
                '' AS OftenUseReport_Project_Engineer,''Project_cf_1747,''Project_cf_1700,''Project_cf_1746,''Project_cf_1745,'' AS Project_modifiedby
                ,''Project_cf_1773,'' AS Project_description,''Potentials_cf_1100,
                ''OftenUseReport_ccount,SUM(CashBill_subtotal) AS CashBill_subtotal,''CashBill_cashbilldate,SUM(CashBill_total) AS CashBill_total,SUM(CashBill_weishou) AS CashBill_weishou,
                '' AS CashBill_description,
                ''Project_cf_1774,''Project_cf_1784
                FROM temptable1;";
           //echo $SQL.'<br><br>'; 
        return $SQL;  
                        
    }    
        
    static function getHighAndNewTechnologyEnterpriseSchedule($whereZY){
       global $adb; 
        $SQL="SELECT 
                	u1.last_name AS 'Users_last_name', 
            		ld_account.accountname AS 'Accounts_accountname', 
            		ld_projectcf.cf_1473 AS 'Project_cf_1473', 
            		ld_projectcf.cf_1474 AS 'Project_cf_1474', 
            		ld_projectcf.cf_1475 AS 'Project_cf_1475', 
            		ld_projectcf.cf_1479 AS 'Project_cf_1479', 
            		ld_projectcf.cf_977 AS 'Project_cf_977', 
            		ld_projectcf.cf_1285 AS 'Project_cf_1285', 
            		ld_projectcf.cf_1287 AS 'Project_cf_1287', 
            		ld_projectcf.cf_1286 AS 'Project_cf_1286', 
            		ld_projectcf.cf_1289 AS 'Project_cf_1289', 
            		ld_project.cf_1478 AS 'Project_cf_1478', 
            		'' AS 数量, 
            		u2.last_name AS 'u2_last_name', 
            		ld_projecttaskcf.cf_1067 AS 'ProjectTask_cf_1067', 
            	CASE WHEN ld_projecttaskcf.cf_1068 <= curdate() THEN DATE_FORMAT(ld_projecttaskcf.cf_1068,'%Y-%m-%d') 
            			ELSE DATE_FORMAT(ld_projecttaskcf.cf_1068,'%Y-%m-%d') END AS 'ProjectTask_cf_1068', 
            	CASE WHEN ld_projecttaskcf.cf_1069 <= curdate() THEN DATE_FORMAT(ld_projecttaskcf.cf_1069,'%Y-%m-%d') 
            			ELSE DATE_FORMAT(ld_projecttaskcf.cf_1069,'%Y-%m-%d') END AS 'ProjectTask_cf_1069', 
            	CASE WHEN ld_projecttaskcf.cf_1070 <= curdate() THEN DATE_FORMAT(ld_projecttaskcf.cf_1070,'%Y-%m-%d') 
            			ELSE DATE_FORMAT(ld_projecttaskcf.cf_1070,'%Y-%m-%d') END AS 'ProjectTask_cf_1070', 
            	CASE WHEN ld_projecttaskcf.cf_1071 <= curdate() THEN DATE_FORMAT(ld_projecttaskcf.cf_1071,'%Y-%m-%d') 
            			ELSE DATE_FORMAT(ld_projecttaskcf.cf_1071,'%Y-%m-%d') END AS 'ProjectTask_cf_1071', 
            	CASE WHEN ld_projecttaskcf.cf_1072 <= curdate() THEN DATE_FORMAT(ld_projecttaskcf.cf_1072,'%Y-%m-%d') 
            			ELSE DATE_FORMAT(ld_projecttaskcf.cf_1072,'%Y-%m-%d') END AS 'ProjectTask_cf_1072', 
            	CASE WHEN ld_projecttaskcf.cf_1073 <= curdate() THEN DATE_FORMAT(ld_projecttaskcf.cf_1073,'%Y-%m-%d') 
            			ELSE DATE_FORMAT(ld_projecttaskcf.cf_1073,'%Y-%m-%d') END AS 'ProjectTask_cf_1073', 
            	CASE WHEN ld_projecttaskcf.cf_1074 <= curdate() THEN DATE_FORMAT(ld_projecttaskcf.cf_1074,'%Y-%m-%d') 
            			ELSE DATE_FORMAT(ld_projecttaskcf.cf_1074,'%Y-%m-%d') END AS 'ProjectTask_cf_1074', 
            	CASE WHEN ld_projecttask.projecttaskname <= curdate() THEN DATE_FORMAT(ld_projecttask.projecttaskname, '%Y-%m-%d') 
            			ELSE DATE_FORMAT(ld_projecttask.projecttaskname, '%Y-%m-%d') END AS 'ProjectTask_projecttaskname', 
            		ld_projecttask.description AS 'ProjectTask_description' 
            FROM 
            		ld_project 
            	LEFT JOIN ld_projectcf ON ld_projectcf.projectid = ld_project.projectid 
            	LEFT JOIN ld_account ON ld_account.accountid = ld_project.accountid 
            	LEFT JOIN ( 
            		SELECT 
            			* 
            		FROM 
            			(SELECT * FROM ld_projecttask WHERE deleted = 0 ORDER BY projectid,createdtime DESC ) AS a 
            		GROUP BY projectid 
            		) AS ld_projecttask ON ld_projecttask.projectid = ld_project.projectid 
            	LEFT JOIN ld_projecttaskcf ON ld_projecttask.projecttaskid = ld_projecttaskcf.projecttaskid 
            	LEFT JOIN ld_users AS u1 ON u1.id = ld_project.smownerid 
            	LEFT JOIN ld_users AS u2 ON u2.id = ld_projecttask.smownerid 
            WHERE 
            		ld_project.deleted = 0 AND $whereZY 
            ORDER BY CONVERT (u1.last_name USING gbk) COLLATE gbk_chinese_ci ASC, ld_projecttaskcf.cf_1067 DESC";    
          //echo $SQL.'<br><br>';   
        return $SQL;  
                        
    }    
    
    static function getProjectCompletionStatisticsReport($whereZY){
       global $adb; 
        $SQL="Create TEMPORARY table IF NOT EXISTS temptable1 ignore(
            select 
                '' AS 'Project_cf_977',
            	SUBSTRING(ld_projectcf.cf_977,6,2) AS 'yue',
				SUBSTRING(ld_projectcf.cf_977,1,4) AS 'nian',
            	u1.last_name AS 'Uname',
                '' AS 'Users_last_name',
            	ld_account.accountname AS 'Accounts_accountname',
            	sum((select COUNT(*) from ld_projectcf where ld_projectcf.projectid=ld_project.projectid and ld_projectcf.cf_1363='一')) AS 'Project_cf_13631',
            	sum((select COUNT(*) from ld_projectcf where ld_projectcf.projectid=ld_project.projectid and ld_projectcf.cf_1363='二')) AS 'Project_cf_13632',
            	sum((select COUNT(*) from ld_projectcf where ld_projectcf.projectid=ld_project.projectid and ld_projectcf.cf_1363='三')) AS 'Project_cf_13633',
            	sum((select COUNT(*) from ld_projectcf where ld_projectcf.projectid=ld_project.projectid and ld_projectcf.cf_1363='四')) AS 'Project_cf_13634',
            	sum((select COUNT(*) from ld_projectcf where ld_projectcf.projectid=ld_project.projectid and ld_projectcf.cf_1363 in('一','二','三','四'))) AS 'Project_cf_1363',
            	sum((select COUNT(*) from ld_projectcf where ld_projectcf.projectid=ld_project.projectid and ld_projectcf.cf_989='一')) AS 'Project_cf_9891',
            	sum((select COUNT(*) from ld_projectcf where ld_projectcf.projectid=ld_project.projectid and ld_projectcf.cf_989='二')) AS 'Project_cf_9892',
            	sum((select COUNT(*) from ld_projectcf where ld_projectcf.projectid=ld_project.projectid and ld_projectcf.cf_989='三')) AS 'Project_cf_9893',
            	sum((select COUNT(*) from ld_projectcf where ld_projectcf.projectid=ld_project.projectid and ld_projectcf.cf_989='复审一')) AS 'Project_cf_9894',
            	sum((select COUNT(*) from ld_projectcf where ld_projectcf.projectid=ld_project.projectid and ld_projectcf.cf_989='复审二')) AS 'Project_cf_9895',
            	sum((select COUNT(*) from ld_projectcf where ld_projectcf.projectid=ld_project.projectid and ld_projectcf.cf_989 in ('一','二','三','复审一','复审二'))) AS 'Project_cf_989',
            	sum((select COUNT(*) from ld_projectcf where ld_projectcf.projectid=ld_project.projectid and ld_projectcf.cf_1029='国家级')) AS 'Project_cf_1029g',
            	sum((select COUNT(*) from ld_salesorder where ld_salesorder.salesorderid=ld_project.salesorderid and ld_salesorder.`subject` like '%加计扣除')) AS 'SalesOrder_subject',
            	sum((select COUNT(*) from ld_projectcf where ld_projectcf.projectid=ld_project.projectid and ld_projectcf.cf_1029='省级')) AS 'Project_cf_1029s',
            	sum((select COUNT(*) from ld_projectcf where ld_projectcf.projectid=ld_project.projectid and ld_projectcf.cf_1029='市级')) AS 'Project_cf_1029c',
            	(
            	sum((select COUNT(*) from ld_projectcf where ld_projectcf.projectid=ld_project.projectid and ld_projectcf.cf_1363 in('一','二','三','四')))+
            	sum((select COUNT(*) from ld_projectcf where ld_projectcf.projectid=ld_project.projectid and ld_projectcf.cf_989 in ('一','二','三','复审一','复审二')))+
            	sum((select COUNT(*) from ld_salesorder where ld_salesorder.salesorderid=ld_project.salesorderid and ld_salesorder.`subject` like '%加计扣除'))+
            	sum((select COUNT(*) from ld_projectcf where ld_projectcf.projectid=ld_project.projectid and ld_projectcf.cf_1029 in ('国家级','省级','市级')))
                ) AS 'Project_cf_1029d'
            from
            	ld_project
            LEFT JOIN ld_projectcf ON ld_project.projectid = ld_projectcf.projectid
            LEFT JOIN ld_account ON ld_account.accountid = ld_project.accountid
            LEFT JOIN ld_users AS u1 ON u1.id = ld_project.smownerid
            WHERE
            	ld_project.deleted=0 AND $whereZY
            GROUP BY SUBSTRING(ld_projectcf.cf_977,1,4),SUBSTRING(ld_projectcf.cf_977,1,4),yue,Uname,ld_account.accountid 
            ORDER BY yue ASC
            )";    
          //echo $SQL.';<br><br>';   
            $adb->query($SQL);
        
        $SQL = "Create TEMPORARY table IF NOT EXISTS temptable2 ignore(
                SELECT 
                    yue AS Project_cf_977,
                    yue,
                    nian,
                    '' AS Uname,
                    '' AS Users_last_name,
                    '' AS Accounts_accountname,
                    sum(Project_cf_13631) AS Project_cf_13631,
                    sum(Project_cf_13632) AS Project_cf_13632,
                    sum(Project_cf_13633) AS Project_cf_13633,
                    sum(Project_cf_13634) AS Project_cf_13634,
                    sum(Project_cf_1363) AS Project_cf_1363,
                    sum(Project_cf_9891) AS Project_cf_9891,
                    sum(Project_cf_9892) AS Project_cf_9892,
                    sum(Project_cf_9893) AS Project_cf_9893,
                    sum(Project_cf_9894) AS Project_cf_9894,
                    sum(Project_cf_9895) AS Project_cf_9895,
                    sum(Project_cf_989) AS Project_cf_989,
                    sum(Project_cf_1029g) AS Project_cf_1029g,
                    sum(SalesOrder_subject) AS SalesOrder_subject,
                    sum(Project_cf_1029s) AS Project_cf_1029s,
                    sum(Project_cf_1029c) AS Project_cf_1029c,
                    sum(Project_cf_1029d) AS Project_cf_1029d
                FROM temptable1
                GROUP BY nian,yue
                )";
                $adb->query($SQL);
                 //echo $SQL.';<br><br>';   
        $SQL = "Create TEMPORARY table IF NOT EXISTS temptable3 ignore(
                SELECT 
                    '' AS Project_cf_977,
                    yue,
                    nian,
                    Uname,
                    Uname AS Users_last_name,
                    '' AS Accounts_accountname,
                    sum(Project_cf_13631) AS Project_cf_13631,
                    sum(Project_cf_13632) AS Project_cf_13632,
                    sum(Project_cf_13633) AS Project_cf_13633,
                    sum(Project_cf_13634) AS Project_cf_13634,
                    sum(Project_cf_1363) AS Project_cf_1363,
                    sum(Project_cf_9891) AS Project_cf_9891,
                    sum(Project_cf_9892) AS Project_cf_9892,
                    sum(Project_cf_9893) AS Project_cf_9893,
                    sum(Project_cf_9894) AS Project_cf_9894,
                    sum(Project_cf_9895) AS Project_cf_9895,
                    sum(Project_cf_989) AS Project_cf_989,
                    sum(Project_cf_1029g) AS Project_cf_1029g,
                    sum(SalesOrder_subject) AS SalesOrder_subject,
                    sum(Project_cf_1029s) AS Project_cf_1029s,
                    sum(Project_cf_1029c) AS Project_cf_1029c,
                    sum(Project_cf_1029d) AS Project_cf_1029d
                FROM temptable1
                GROUP BY Uname,yue
                )";
                $adb->query($SQL);
             //echo $SQL.';<br><br>';       
        $SQL = "Create TEMPORARY table IF NOT EXISTS temptable4 ignore(
                SELECT * 
                FROM 
                    (SELECT * 
                    FROM temptable1 
                    UNION SELECT * FROM temptable2 UNION SELECT * FROM temptable3)as f1 ORDER BY nian,yue,Uname,Accounts_accountname)";
                $adb->query($SQL);
               // echo $SQL.';<br><br>';    
        $SQL = "SELECT * FROM temptable4 UNION SELECT 
                	'".getFixedLabel('TOTAL')."',yue,
                	nian,
                    Uname,
                	'' Users_last_name,
                	'' Accounts_accountname,
                	sum(Project_cf_13631) AS Project_cf_13631,
                	sum(Project_cf_13632) AS Project_cf_13632,
                	sum(Project_cf_13633) AS Project_cf_13633,
                	sum(Project_cf_13634) AS Project_cf_13634,
                	sum(Project_cf_1363) AS Project_cf_1363,
                	sum(Project_cf_9891) AS Project_cf_9891,
                	sum(Project_cf_9892) AS Project_cf_9892,
                	sum(Project_cf_9893) AS Project_cf_9893,
                	sum(Project_cf_9894) AS Project_cf_9894,
                	sum(Project_cf_9895) AS Project_cf_9895,
                	sum(Project_cf_989) AS Project_cf_989,
                	sum(Project_cf_1029g) AS Project_cf_1029g,
                	sum(SalesOrder_subject) AS SalesOrder_subject,
                	sum(Project_cf_1029s) AS Project_cf_1029s,
                	sum(Project_cf_1029c) AS Project_cf_1029c,
                	sum(Project_cf_1029d) AS Project_cf_1029d
                FROM temptable2 GROUP BY nian";
                //echo $SQL.';<br><br>';   
        return $SQL;  
                        
    }
    
    static function getAllpaymentsstatisticsreport($where,$wherebill,$sharewhere,$wherejierun){
       global $adb; 
      // echo $where;
     // echo sprintf($where,'ld_account');
       $SQL = "CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable IGNORE (
               	SELECT
            		ld_potential.potentialid,
            		ld_salesorder.salesorderid,
            		accountname,
            		potentialname,
            		ld_salesorder. SUBJECT AS SalesOrder_subject,
            		IFNULL(
            
            			IF (
            				ld_salesorder.currency_id > 1,
            				ld_salesorder.total / ld_salesorder.conversion_rate,
            				ld_salesorder.Total
            			),
            			0
            		) AS total,
            		ld_salesorder.conversion_rate,
            		ld_salesorder.currency_id
            	FROM
            		ld_potential 
                left join ld_tabshare on ld_tabshare.crmid = ld_potential.potentialid
            	LEFT JOIN ld_salesorder ON ld_salesorder.potentialid = ld_potential.potentialid
            	LEFT JOIN ld_account ON ld_salesorder.accountid = ld_account.accountid
            	WHERE
            		ld_salesorder.deleted = 0
            	AND ld_potential.deleted = 0 $where
            	AND ld_account.deleted = 0 ". sprintf($wherejierun,'ld_potential')."  ". sprintf($sharewhere,'ld_tabshare').");";
                $adb->query($SQL);
          //echo $SQL.'<br><br>';      
        $SQL = "CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable1 IGNORE (
                	SELECT purchaseorderid,salesorderid,SUM(F2.total) AS total,SUM(PurchaseOrder_total) AS PurchaseOrder_total FROM (
                	SELECT DISTINCT purchaseorderid, ld_salesorder.salesorderid,F1.total AS total,PurchaseOrder_total FROM (
                	SELECT 
                		ld_purchaseorder.purchaseorderid AS purchaseorderid,
                		IF (
                				ld_purchaseorder.currency_id > 1,				
                				ld_purchaseorder.total / ld_purchaseorder.conversion_rate,
                				ld_purchaseorder.total
                			) AS PurchaseOrder_total,
                		sum(
                			IF (
                				ld_sendcashbill.currency_id > 1,
                				amount / ld_sendcashbill.conversion_rate,
                				amount
                			)
                		) AS total
                	FROM
                		ld_purchaseorder
                	LEFT JOIN ld_sendcashbill2payment ON ld_sendcashbill2payment.purchaseorder_id = ld_purchaseorder.purchaseorderid
                	LEFT JOIN ld_sendcashbill ON ld_sendcashbill2payment.sendcashbillid = ld_sendcashbill.sendcashbillid
                	WHERE
                		ld_purchaseorder.deleted = 0
                	AND ld_purchaseorder.purchaseorderid > 0
                	GROUP BY
                		ld_purchaseorder.purchaseorderid) AS F1 
                	INNER JOIN ld_purchaseorderdetail ON ld_purchaseorderdetail.id = F1.purchaseorderid 
                	INNER JOIN ld_salesorder ON ld_purchaseorderdetail.entitytypeid = ld_salesorder.salesorderid
                	) AS F2 
                GROUP BY F2.salesorderid
                );";
        $adb->query($SQL);
         // echo $SQL.'<br><br>'; 
                $SQL = "CREATE TEMPORARY TABLE
                        IF NOT EXISTS temptable4 IGNORE (
                        	SELECT
                        		ld_cashbill2paymentplan.entitytypeid AS salesorderid,
                        		SUM(
                        
                        			IF (
                        				ld_cashbill.currency_id > 1,
                        				amount / ld_cashbill.conversion_rate,
                        				amount
                        			)
                        		) AS total
                        	FROM
                        		ld_cashbill
                        	INNER JOIN ld_cashbill2paymentplan ON ld_cashbill2paymentplan.CashBillID = ld_cashbill.cashbillid
                        	INNER JOIN ld_salesorder ON ld_cashbill2paymentplan.entitytypeid = ld_salesorder.salesorderid
                        	WHERE
                        		ld_cashbill.deleted = 0
                        	AND ld_salesorder.salesorderid > 0
                        	AND ld_cashbill.cashbillid > 0
                        	GROUP BY
                        		ld_cashbill2paymentplan.entitytypeid
                        );";
        $adb->query($SQL);
       // echo $SQL.'<br><br>';  
        $SQL = "CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable2 IGNORE (
                SELECT DISTINCT
            	temptable .potentialname AS Potentials_potentialname,
            	temptable .accountname AS Accounts_accountname,
            	temptable .SalesOrder_subject,
            	temptable .total AS SalesOrder_total,
            	IFNULL(temptable4 .total,0) AS OftenUseReport_CashBillamount,
            	(IFNULL(temptable .total,0)-IFNULL(temptable4.total, 0)
            	) AS OftenUseReport_PaymentPlanBalance,
            	IFNULL(PurchaseOrder_total,0) AS PurchaseOrder_total,
            	IFNULL(temptable1.total,0) AS OftenUseReport_SendCashBillamount,
            	(IFNULL(PurchaseOrder_total,0)-IFNULL(temptable1.total, 0)
            	) AS OftenUseReport_SendCashBillBalance,
                 IFNULL(Expense_total,0) AS Expense_total ,IFNULL(outboundorder_total,0) AS outboundorder_total,
                		IFNULL(SalesBack_total,0) AS SalesBack_total,IFNULL(Commission_total,0) AS Commission_total,
                	(IFNULL(PurchaseOrder_total,0)+IFNULL(outboundorder_total,0)+IFNULL(Expense_total,0)+IFNULL(Commission_total,0)-IFNULL(SalesBack_total,0))
                	AS OftenUseReport_chenbenzongji,
                temptable .total-	(IFNULL(PurchaseOrder_total,0)+IFNULL(outboundorder_total,0)+IFNULL(Expense_total,0)+IFNULL(Commission_total,0)-IFNULL(SalesBack_total,0))
                	AS OftenUseReport_lirun,
                (temptable .total-	(IFNULL(PurchaseOrder_total,0)+IFNULL(outboundorder_total,0)+IFNULL(Expense_total,0)+IFNULL(Commission_total,0)-IFNULL(SalesBack_total,0)))
                /temptable .total*100 AS OftenUseReport_lirunlv
            	FROM
            		temptable
            	LEFT JOIN temptable1 ON temptable1.salesorderid = temptable .salesorderid
            	LEFT JOIN temptable4 ON temptable4.salesorderid = temptable .salesorderid
                LEFT JOIN (
            		SELECT SUM(ld_expense.total) AS Expense_total,ld_expense.Salesorderid 
            		FROM ld_expense WHERE ld_expense.deleted=0 GROUP BY Salesorderid
            	) AS ld_expense ON ld_expense.Salesorderid = temptable .salesorderid
            	LEFT JOIN (
            		SELECT SUM(ld_outboundorder.total) AS outboundorder_total,ld_outboundorder.salesorderid 
            		FROM ld_outboundorder WHERE  ld_outboundorder.deleted=0 GROUP BY salesorderid 
            	) AS ld_outboundorder ON ld_outboundorder.Salesorderid = temptable .salesorderid
            	LEFT JOIN (
            		SELECT SUM(ld_salesback.total) AS SalesBack_total,ld_salesback.salesorderid 
            		FROM ld_salesback WHERE  ld_salesback.deleted=0 GROUP BY salesorderid 
            	) AS ld_salesback ON ld_salesback.Salesorderid = temptable .salesorderid
            	LEFT JOIN (
            	SELECT SUM(amount) AS Commission_total,entitytypeid FROM ld_commission 
            		LEFT JOIN ld_commission2payment 
            				ON ld_commission2payment.commission_id = ld_commission.commission_id 
            		WHERE  ld_commission.deleted=0
            		GROUP BY entitytypeid
            	) AS ld_commission ON ld_commission.entitytypeid = temptable .salesorderid
            	WHERE
            		1 = 1 $wherebill
            	ORDER BY
            		temptable .potentialid
                );";   
        $adb->query($SQL);  
       // echo $SQL.'<br><br>';  
        
        $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable3 IGNORE (
                	SELECT 
                		'".getFixedLabel('TOTAL')."' Potentials_potentialname,
                		'' Accounts_accountname,
                		'' SalesOrder_subject,
                		SUM(SalesOrder_total) AS SalesOrder_total,
                        SUM(OftenUseReport_CashBillamount) AS OftenUseReport_CashBillamount,
                        SUM(OftenUseReport_PaymentPlanBalance) AS OftenUseReport_PaymentPlanBalance,
                        SUM(PurchaseOrder_total) AS PurchaseOrder_total,
                        SUM(OftenUseReport_SendCashBillamount) AS OftenUseReport_SendCashBillamount,
                        SUM(OftenUseReport_SendCashBillBalance) AS OftenUseReport_SendCashBillBalance,
                		SUM(
                			Expense_total
                		) AS Expense_total,
                		SUM(
                			outboundorder_total
                		) AS outboundorder_total,
                		SUM(
                			SalesBack_total
                		) AS SalesBack_total,
                		SUM(
                			Commission_total
                		) AS Commission_total,
                		SUM(
                			OftenUseReport_chenbenzongji
                		) AS OftenUseReport_chenbenzongji,
                		SUM(
                			OftenUseReport_lirun
                		) AS OftenUseReport_lirun,
                		SUM(OftenUseReport_lirun)/SUM(SalesOrder_total)*100 AS OftenUseReport_lirunlv
                                	FROM
                		temptable2
                );";
         $adb->query($SQL);  
        // echo $SQL.'<br><br>';  
         
         $SQL="SELECT
                *       
            FROM
            	temptable2
            UNION ALL
            	SELECT
            		*
            	FROM
          		temptable3;";    
         // echo $SQL.'<br><br>';   
        return $SQL;  
                        
    }    
    static function getOrderexpenditurestatisticsreport($where,$sharewhere,$wherejierun){
       global $adb; 
      // echo $where;
     // echo sprintf($where,'ld_account');
       $SQL = "CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable IGNORE (
                	SELECT 
                		ld_potential.potentialid,
                		purchaseorderid,
                		potentialname,
                		accountname,
                		ld_salesorder.subject as SalesOrder_subject,
                		ld_purchaseorder.subject as PurchaseOrder_subject,
                		IFNULL(
                			IF (
                				ld_purchaseorder.currency_id > 1,
                				ld_purchaseorder.total / ld_purchaseorder.conversion_rate,
                				ld_purchaseorder.Total
                			),
                			0
                		) AS total,
                		ld_purchaseorder.conversion_rate,
                		ld_purchaseorder.currency_id
                	FROM
                		ld_potential
                        left join ld_tabshare on ld_tabshare.crmid = ld_potential.potentialid
                	LEFT JOIN ld_salesorder ON ld_salesorder.potentialid = ld_potential.potentialid
                	LEFT JOIN ld_account ON ld_salesorder.accountid = ld_account.accountid 
                
                	LEFT JOIN ld_purchaseorderdetail ON ld_purchaseorderdetail.entitytypeid=ld_salesorder.salesorderid
                	LEFT JOIN ld_purchaseorder ON ld_purchaseorderdetail.id=ld_purchaseorder.purchaseorderid 
                
                	WHERE
                	ld_salesorder.deleted = 0
                	AND ld_potential.deleted = 0
                	AND ld_account.deleted = 0 $where
                	AND ld_purchaseorder.deleted=0 ". sprintf($wherejierun,'ld_potential')."  ". sprintf($sharewhere,'ld_tabshare')."
                );";
                $adb->query($SQL);
          //echo $SQL.'<br><br>';      
        $SQL = "CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable1 IGNORE (
	       SELECT
		      ld_sendcashbill2payment.purchaseorder_id AS purchaseorderid,
		      sum(
                IF (
    				ld_sendcashbill.currency_id > 1,
    				amount / ld_sendcashbill.conversion_rate,
    				amount
    			)
              ) AS total
	       FROM
		      ld_sendcashbill
	       INNER JOIN ld_sendcashbill2payment ON ld_sendcashbill2payment.sendcashbillid = ld_sendcashbill.sendcashbillid
	       INNER JOIN ld_purchaseorder ON ld_sendcashbill2payment.purchaseorder_id = ld_purchaseorder.purchaseorderid
	       WHERE
		      ld_sendcashbill.deleted = 0
	       AND ld_purchaseorder.purchaseorderid > 0
	       AND ld_sendcashbill.sendcashbillid > 0
	       GROUP BY
		      ld_sendcashbill2payment.purchaseorder_id
                );";
        $adb->query($SQL);
        //echo $SQL.'<br><br>';  
        $SQL = "CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable2 IGNORE (
                	SELECT 
                		DISTINCT temptable .purchaseorderid,
                		temptable .potentialname AS Potentials_potentialname,
                		temptable .accountname AS Accounts_accountname,
                		temptable . SalesOrder_subject,
                		temptable . PurchaseOrder_subject,
                		temptable .total AS PurchaseOrder_total,
                		IFNULL(temptable1.total,0) AS OftenUseReport_SendCashBillamount,
                		IFNULL(temptable1.total,0) / temptable .total * 100 AS OftenUseReport_proportionpaid,
                		(
                			IFNULL(
                
                				IF (
                					currency_id > 1,
                					temptable .total / conversion_rate,
                					temptable .total
                				),
                				0
                			) - IFNULL(temptable1.total, 0)
                		) AS OftenUseReport_SendCashBillBalance,
                		(
                			IFNULL(
                
                				IF (
                					currency_id > 1,
                					temptable .total / conversion_rate,
                					temptable .total
                				),
                				0
                			) - IFNULL(temptable1.total, 0)
                		) / temptable .total * 100 AS OftenUseReport_Unpaidproportion
                	FROM
                		temptable
                	LEFT JOIN temptable1 ON temptable1.purchaseorderid = temptable .purchaseorderid
                	WHERE
                		1 = 1
                	ORDER BY
                		temptable .potentialid
                );";   
        $adb->query($SQL);  
      //  echo $SQL.'<br><br>';  
        
        $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable3 IGNORE (
                	SELECT 
                		'".getFixedLabel('TOTAL')."' Potentials_potentialname,
                		'' Accounts_accountname,
                		'' SalesOrder_subject,
                		'' PurchaseOrder_subject,
                		SUM(PurchaseOrder_total) AS PurchaseOrder_total,
                			SUM(
                				OftenUseReport_SendCashBillamount
                		) AS OftenUseReport_SendCashBillamount,
                		concat(
                			FORMAT(
                				SUM(
                					OftenUseReport_SendCashBillamount
                				) / SUM(PurchaseOrder_total) * 100,
                				2
                			),
                			'%'
                		) AS OftenUseReport_proportionpaid,
                			SUM(
                				OftenUseReport_SendCashBillBalance
                		) AS OftenUseReport_SendCashBillBalance,
                		concat(
                			FORMAT(
                				SUM(
                					OftenUseReport_SendCashBillBalance
                				) / SUM(PurchaseOrder_total) * 100,
                				2
                			),
                			'%'
                		) AS OftenUseReport_Unpaidproportion
                	FROM
                		temptable2
                );";
         $adb->query($SQL);  
         //echo $SQL.'<br><br>';  
         
         $SQL="SELECT
            	Potentials_potentialname,
            	Accounts_accountname,
            	SalesOrder_subject,PurchaseOrder_subject,
            	PurchaseOrder_total AS PurchaseOrder_total,
                OftenUseReport_SendCashBillamount,
            	concat(
            		FORMAT(
            			OftenUseReport_proportionpaid,
            			2
            		),
            		'%'
            	) AS OftenUseReport_proportionpaid,
            		OftenUseReport_SendCashBillBalance,
            	concat(
            		FORMAT(
            			OftenUseReport_Unpaidproportion,
            			2
            		),
            		'%'
            	) AS OftenUseReport_Unpaidproportion
            FROM
            	temptable2
            UNION ALL
            	SELECT
            		*
            	FROM
            		temptable3;";    
         // echo $SQL.'<br><br>';   
        return $SQL;  
                        
    }    
    static function getEachprojectcontractincomestatisticsreport($where,$wherebill,$sharewhere,$wherejierun){
       global $adb; 
       //echo $wherejierun;
     // echo sprintf($where,'ld_account');
       $SQL = "CREATE TEMPORARY TABLE 
                IF NOT EXISTS temptable IGNORE ( 
                    SELECT DISTINCT ld_potential.potentialid,cf_1616,ld_salesorder.salesorderid,potentialname,accountname,subject,
                    IFNULL(if(ld_salesorder.currency_id >1,ld_salesorder.total/ld_salesorder.conversion_rate,Total), 0) AS total,
                    ld_salesorder.conversion_rate,ld_salesorder.currency_id 
                    FROM ld_potential 
                    LEFT join ld_tabshare on ld_tabshare.crmid = ld_potential.potentialid
                    LEFT JOIN ld_salesorder ON ld_salesorder.potentialid=ld_potential.potentialid 
                    LEFT JOIN ld_salesordercf ON ld_salesordercf.salesorderid=ld_salesorder.salesorderid 
                    LEFT JOIN ld_account ON ld_salesorder.accountid=ld_account.accountid 
                    WHERE ld_salesorder.deleted = 0 AND ld_potential.deleted=0 AND ld_account.deleted=0  $where
                    ". sprintf($wherejierun,'ld_potential')."  ". sprintf($sharewhere,'ld_tabshare')."
                    );
                    ";
                $adb->query($SQL);
          // echo $SQL.'<br><br>';    
        $SQL = "CREATE TEMPORARY TABLE 
                IF NOT EXISTS temptable1 IGNORE ( 
                SELECT 
                ld_cashbill2paymentplan.entitytypeid AS salesorderid, 
                SUM(if(ld_cashbill.currency_id > 1,amount/ld_cashbill.conversion_rate,amount)) AS total 
                FROM 
                ld_cashbill 
                INNER JOIN ld_cashbill2paymentplan ON ld_cashbill2paymentplan.CashBillID = ld_cashbill.cashbillid 
                INNER JOIN ld_salesorder ON ld_cashbill2paymentplan.entitytypeid = ld_salesorder.salesorderid 
                WHERE 
                ld_cashbill.deleted = 0 
                AND ld_salesorder.salesorderid > 0 
                AND ld_cashbill.cashbillid > 0 
                GROUP BY 
                ld_cashbill2paymentplan.entitytypeid 
                );";
                //echo $SQL.'<br><br>';
        $adb->query($SQL);
        $SQL = "CREATE TEMPORARY TABLE 
                IF NOT EXISTS temptable2 IGNORE ( 
                SELECT 
                	temptable.potentialname as Potentials_potentialname,temptable.potentialid,
                    temptable.accountname as Accounts_accountname, 
                    temptable.subject as SalesOrder_subject,
                    temptable.total AS SalesOrder_total,
                	IFNULL(temptable1.total,0) AS OftenUseReport_CashBillamount,
                	IFNULL(temptable1.total / temptable .total * 100,0) AS OftenUseReport_Receivedproportion,
                	(
                		IFNULL(
                
                			IF (
                				currency_id > 1,
                				temptable .total / conversion_rate,
                				temptable .total
                			),
                			0
                		) - IFNULL(temptable1.total, 0)
                	) AS OftenUseReport_PaymentPlanBalance,
                	(
                		IFNULL(
                
                			IF (
                				currency_id > 1,
                				temptable .total / conversion_rate,
                				temptable .total
                			),
                			0
                		) - IFNULL(temptable1.total, 0)
                	) / temptable .total * 100 AS OftenUseReport_proportionuncollected,
                	cf_1616
                FROM
                	temptable
                LEFT JOIN temptable1 ON temptable1.salesorderid = temptable .salesorderid 
                WHERE 1=1 $wherebill
                ORDER BY temptable.potentialid);";   
               // echo $SQL.'<br><br>';
        $adb->query($SQL);  
        
        $SQL="CREATE TEMPORARY TABLE 
                IF NOT EXISTS temptable3 IGNORE ( SELECT 
                '".getFixedLabel('TOTAL')."'Potentials_potentialname,''potentialid, ''Accounts_accountname, ''SalesOrder_subject,SUM(SalesOrder_total) as SalesOrder_total,
                SUM(OftenUseReport_CashBillamount) as OftenUseReport_CashBillamount,
                concat(FORMAT(SUM(OftenUseReport_CashBillamount)/SUM(SalesOrder_total)*100,2),'%') AS OftenUseReport_Receivedproportion,
                SUM(OftenUseReport_PaymentPlanBalance) AS OftenUseReport_PaymentPlanBalance,
                concat(FORMAT(SUM(OftenUseReport_PaymentPlanBalance)/SUM(SalesOrder_total)*100,2),'%') AS OftenUseReport_proportionuncollected,
                ''SalesOrder_cf_1616
                FROM temptable2);";
               // echo $SQL.'<br><br>';
         $adb->query($SQL);  
         
         $SQL="SELECT 
                Potentials_potentialname,potentialid,Accounts_accountname, SalesOrder_subject, 
                SalesOrder_total,
                OftenUseReport_CashBillamount,
                concat(FORMAT(OftenUseReport_Receivedproportion,2),'%') as OftenUseReport_Receivedproportion,
                OftenUseReport_PaymentPlanBalance,
                concat(FORMAT(OftenUseReport_proportionuncollected,2),'%') as OftenUseReport_proportionuncollected,
                concat(cf_1616,'%') as SalesOrder_cf_1616
          FROM temptable2 UNION SELECT * FROM temptable3;";     
          //echo $SQL.'<br><br>';
        return $SQL;  
                        
    }    
    static function getHoursqueryreport($where,$wheretime){
       global $adb; 
       //echo $where;
     // echo sprintf($where,'ld_account');
       $SQL = "CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable IGNORE (
                SELECT 
                last_name AS Accounts_last_name, 
                F2.potentialid,
                productname AS Products_productname, 
                accountname AS Accounts_accountname, 
                contract_no AS ServiceContracts_contract_no, 
                servicecontracts_start_date AS OftenUseReport_start_date, 
                servicecontracts_end_date AS OftenUseReport_end_date, 
                IFNULL(quantity,0) AS OftenUseReport_quantity, 
                IFNULL(sum(classtime),0) AS OftenUseReport_yiyongtime, 
                IFNULL(quantity - sum(classtime),0) AS OftenUseReport_shenyutime, 
                IFNULL(description,'') AS Potentials_description
                FROM 
                ( 
                SELECT 
                F1.potentialid,
                ld_servicecontracts.description, 
                F1.contactid, 
                ld_users.last_name, 
                ld_account.smownerid, 
                servicecontractsid, 
                contract_no, 
                ld_products.productid, 
                ld_products.productname, 
                ld_account.accountid, 
                ld_account.accountname, 
                servicecontracts_start_date, 
                servicecontracts_end_date, 
                ld_servicecontractsdetail.quantity, 
                F1.classtime, 
                F1.closingdate 
                FROM 
                ld_servicecontracts 
                LEFT JOIN ld_servicecontractsdetail ON ld_servicecontracts.servicecontractsid = ld_servicecontractsdetail.id 
                LEFT JOIN ld_account ON ld_account.accountid = ld_servicecontracts.accountid 
                LEFT JOIN ld_products ON ld_servicecontractsdetail.productid = ld_products.productid 
                LEFT JOIN ld_users ON ld_users.id = ld_account.smownerid 
                LEFT JOIN ( 
                SELECT 
                ld_potential.potentialid,
                ld_potential.description, 
                ld_contpotentialrel.contactid, 
                ld_potential.product_id, 
                ld_contactdetails.accountid, 
                ld_potential.classtime, 
                ld_potential.closingdate 
                FROM 
                ld_potential 
                LEFT JOIN ld_contpotentialrel ON ld_potential.potentialid = ld_contpotentialrel.potentialid 
                LEFT JOIN ld_contactdetails ON ld_contactdetails.contactid = ld_contpotentialrel.contactid 
                WHERE 
                ld_potential.deleted = 0 
                AND ld_contactdetails.deleted = 0 
                ) AS F1 ON F1.accountid = ld_account.accountid 
                AND F1.product_id = ld_servicecontractsdetail.productid 
                AND ( 
                F1.closingdate BETWEEN ld_servicecontractsdetail.servicecontracts_start_date 
                AND ld_servicecontractsdetail.servicecontracts_end_date 
                ) 
                WHERE 
                servicecontractsid > 0 
                AND ld_servicecontracts.contract_status <> '已作废' 
                AND ld_servicecontracts.deleted = 0 
                AND ld_account.deleted = 0 
                AND ld_products.deleted = 0 and servicecontracts_start_date $wheretime 
                AND ld_users.deleted = 0 ". sprintf($where,'ld_account')." 
                ) AS F2 
                GROUP BY 
                smownerid, 
                servicecontractsid, 
                productid ORDER BY smownerid,productid
                );";
                $adb->query($SQL);
           //echo $SQL;     
        $SQL = "CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable2 IGNORE (
                SELECT
            	'".getFixedLabel('TOTAL')."' Accounts_last_name,
                '' potentialid,
            	'' Products_productname,
            	'' Accounts_accountname,
            	'' ServiceContracts_contract_no,
            	'' OftenUseReport_start_date,
            	'' OftenUseReport_end_date,
            	SUM(OftenUseReport_quantity) AS OftenUseReport_quantity,
            	SUM(OftenUseReport_yiyongtime) AS OftenUseReport_yiyongtime,
            	SUM(OftenUseReport_shenyutime) AS OftenUseReport_shenyutime,
            	'' Potentials_description
            FROM
            	temptable);";
        $adb->query($SQL);
        $SQL = "SELECT * FROM (SELECT
                    		*
                    	FROM
                    		temptable
                    	UNION ALL
                    		SELECT
                    			*
                    		FROM
                    	temptable2) AS F2";    
        return $SQL;  
                        
    }
    static function getXuanyuanlawnbusinessmanagementreport($where){
       
       global $adb; 
       
       $SQL = "CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable IGNORE (
                SELECT accountname as Accounts_accountname,ld_account.accountid AS statistical_one,
                ld_salesorder.salesorderid AS statistical_two,
                ld_outboundorder.out_id AS statistical_three,
                cashbillid as statistical_thour,
                cashbillid,cf_1519 as Accounts_cf_1519,rating as Accounts_rating,
                cf_1423 as OutboundOrder_cf_1423,cf_1212 as OutboundOrder_cf_1212,
                ld_contactdetails.lastname as Contacts_lastname,
                outdate as OutboundOrder_outdate,signed_data as SalesOrder_signed_data,ld_products.productname as Products_productname,
                cf_1516 as Products_cf_1516,quantity as SalesOrder_quantity,listprice as SalesOrder_listprice,
                quantity*listprice as SalesOrder_total,
                IFNULL(F2.total, 0) AS CashBill_CashBillamount,
                (IF (ld_salesorder.currency_id > 1,
                IFNULL(ld_salesorder.total, 0) / ld_salesorder.conversion_rate,
                IFNULL(ld_salesorder.total, 0)) - IFNULL(F2.total, 0)) AS oftenusereport_PaymentBalance,
                cf_1209 as SalesOrder_cf_1209,last_name as OftenUseReport_lastname,cf_1428 as Accounts_cf_1428,
                ld_outboundorder.cf_1488 as OutboundOrder_cf_1488,cf_1401 as OutboundOrder_cf_1401 
                FROM ld_salesorder 
                LEFT JOIN ld_account ON ld_account.accountid=ld_salesorder.accountid 
                LEFT JOIN ld_accountscf ON ld_accountscf.accountid=ld_account.accountid
                LEFT JOIN ld_contactdetails ON ld_salesorder.contactid=ld_contactdetails.contactid
                LEFT JOIN ld_salesordercf ON ld_salesorder.salesorderid=ld_salesordercf.salesorderid 
                LEFT JOIN (
                SELECT cf_1488,cf_1401,cf_1423,cf_1212,outdate,entitytypeid,ld_outboundorder.out_id FROM ld_outboundorder 
                LEFT JOIN ld_outboundordercf ON ld_outboundorder.out_id=ld_outboundordercf.out_id 
                LEFT JOIN ld_outboundorderdetail ON ld_outboundorder.out_id=ld_outboundorderdetail.id
                WHERE deleted=0		GROUP BY entitytypeid
		          ORDER BY
			createdtime DESC
                ) AS ld_outboundorder ON ld_outboundorder.entitytypeid=ld_salesorder.salesorderid
                LEFT JOIN ld_salesorderdetail ON ld_salesorder.salesorderid=ld_salesorderdetail.id
                LEFT JOIN ld_products ON ld_products.productid=ld_salesorderdetail.productid
                LEFT JOIN ld_productcf ON ld_products.productid=ld_productcf.productid
                LEFT JOIN (SELECT
                ld_cashbill2paymentplan.entitytypeid AS salesorderid,ld_cashbill.cashbillid,
                sum(IF (ld_cashbill.currency_id > 1,ld_cashbill2paymentplan.amount / ld_cashbill.conversion_rate,ld_cashbill2paymentplan.amount)) AS total
                FROM ld_cashbill
                LEFT JOIN ld_cashbill2paymentplan ON ld_cashbill2paymentplan.CashBillID = ld_cashbill.cashbillid
                LEFT JOIN ld_salesorder ON ld_salesorder.salesorderid = ld_cashbill2paymentplan.entitytypeid
                WHERE ld_cashbill.deleted = 0 AND ld_cashbill.cashbillid > 0 AND ld_salesorder.salesorderid > 0 
                and ld_salesorder.sostatus <> '已作废' 
                GROUP BY ld_cashbill2paymentplan.entitytypeid) AS F2 ON F2.salesorderid = ld_salesorder.salesorderid
                LEFT JOIN ld_users ON ld_users.id=ld_account.smownerid 
                WHERE ld_salesorder.deleted=0 and ld_account.deleted=0 ". sprintf($where,'ld_salesorder')." order by  statistical_one,
                statistical_two,statistical_three,statistical_thour) ;";
                $adb->query($SQL);
                //echo $SQL.'<br><br>';  
                $SQL = "CREATE TEMPORARY TABLE
                        IF NOT EXISTS temptable2 IGNORE (
                            SELECT 		
                			'".getFixedLabel('SUBTOTAL')."' Accounts_accountname,
                            '' statistical_one,'' statistical_two,''statistical_three,''statistical_thour,''cashbillid,
                    		'' Accounts_cf_1519,
                    		'' Accounts_rating,
                            '' OutboundOrder_cf_1423, '' OutboundOrder_cf_1212,
                    		'' Contacts_lastname,
                            '' SalesOrder_signed_data,
                            '' OutboundOrder_outdate,
                    		'' Products_productname,
                    		'' Products_cf_1516,
                    		SUM(SalesOrder_quantity) SalesOrder_quantity,
                    		 SUM(SalesOrder_listprice) SalesOrder_listprice,
                    		 SUM(SalesOrder_total) SalesOrder_total,
                    		SUM(CashBill_CashBillamount) CashBill_CashBillamount,
                		SUM(oftenusereport_PaymentBalance) AS oftenusereport_PaymentBalance, 
                		'' as SalesOrder_cf_1209,
                		'' as OftenUseReport_lastname,
                            '' Accounts_cf_1428,'' OutboundOrder_cf_1488 ,'' OutboundOrder_cf_1401
                FROM (SELECT SUM(SalesOrder_quantity) SalesOrder_quantity,SUM(SalesOrder_listprice) SalesOrder_listprice,
                    		SUM(SalesOrder_total) SalesOrder_total,CashBill_CashBillamount,oftenusereport_PaymentBalance 
                            FROM temptable GROUP BY statistical_one,statistical_two,cashbillid) as F3)
                ;";
                $adb->query($SQL);
         //echo $SQL.'<br><br>';    
         $SQL = "SELECT * FROM (SELECT
                    		*
                    	FROM
                    		temptable
                    	UNION
                    		SELECT
                    			*
                    		FROM
                    			temptable2) AS F2";    
        return $SQL;  
             
    }
    
    //项目立项业绩统计表 
    static function getThestatisticalreportofprojectperformance($where,$whereprogress){
    
        global $adb; 
        //已收金额计算时是否统计未审核的收款单
        $focus = CRMEntity::getInstance('CashBill');
        $checkoutstatuswhere = $focus->get_CashBillCheckoutstatusWhere();
        $SQL ="select trade FROM ld_version";
        $result=$adb->query($SQL);
        $trade=$adb->query_result($result, 0, 'trade');
        $query = 'select 1 from ld_field where columnname = ? and tablename = ?';
        $result = $adb->pquery($query,array('cf_1395','ld_projectcf'));
        if($adb->num_rows($result) >= 1 && $trade=='puyoung'){
            $puyoung="cf_1395,";
        }else{
            $puyoung="'' as cf_1395,";
        }
        
        $SQL = "CREATE TEMPORARY TABLE IF NOT EXISTS temptable5 IGNORE (
                SELECT
                	ld_project.projectid,
                	ld_project.projectname,
                	ld_project.project_no,
                	ld_users.last_name AS projectlast_name,
                	ld_group.groupname,
					ld_users.wx_userid as report_wx_userid,
					ld_group.groupid as report_wx_groupid,
                	ld_account.accountname,
                	ld_account.accountid,
                	ld_usersaccount.last_name AS account_name,
                	ld_users.id AS projectlast_ownerid,
                	$puyoung
                	ld_project.startdate,
                	ld_project.projectstatus,
                	ld_project.progress,
                	ld_project.targetenddate,
                	ld_project.actualenddate,
                	ld_salesorder.salesorder_no,
                	ld_salesorder.salesorderid AS orderid,
                	IFNULL(ld_salesorder.total,0)/IFNULL(ld_salesorder.conversion_rate,1) AS total,
               		IFNULL(ld_salesorder.received_amount,0)/IFNULL(ld_salesorder.conversion_rate,1) AS CashBillamount,
               		IFNULL(ld_salesorder.receivable_balance,0)/IFNULL(ld_salesorder.conversion_rate,1) AS oftenusereport_PaymentBalance
                FROM ld_project 
                LEFT JOIN ld_salesorder ON ld_salesorder.salesorderid = ld_project.salesorderid
                LEFT JOIN ld_projectcf ON ld_project.projectid=ld_projectcf.projectid
                LEFT JOIN ld_users ON ld_users.id = ld_project.smownerid
                LEFT JOIN ld_account ON ld_account.accountid = ld_project.accountid
                LEFT JOIN ld_users AS ld_usersaccount ON ld_usersaccount.id = ld_account.smownerid
               	LEFT JOIN ld_crmentity m ON m.crmid=ld_project.salesorderid
                LEFT JOIN (
                	SELECT 
                		GROUP_CONCAT(ld_groups.groupname) AS groupname,
						GROUP_CONCAT(ld_groups.groupid) as groupid,
                		ld_users2group.userid 
                	FROM ld_users2group
                	LEFT JOIN ld_groups ON ld_groups.groupid = ld_users2group.groupid
                	GROUP BY ld_users2group.userid
                ) AS ld_group ON ld_group.userid = ld_project.smownerid
                WHERE ld_project.deleted = 0
                	AND ld_project.approvestatus<>'已拒绝'
                	AND m.setype='SalesOrder'
                    ". sprintf($where,'ld_project')." $whereprogress
                );";
                    
            //echo $SQL.'<br><br>';
            $adb->query($SQL);
                
        $SQL = "CREATE TEMPORARY TABLE IF NOT EXISTS temptable4 IGNORE (
                SELECT
                	ld_project.projectid,
                	ld_project.projectname,
                	ld_project.project_no,
                	ld_users.last_name AS projectlast_name,
                	ld_group.groupname,
					ld_users.wx_userid as report_wx_userid,
					ld_group.groupid as report_wx_groupid,
                	ld_account.accountname,
                	ld_account.accountid,
                	ld_usersaccount.last_name AS account_name,
                	ld_users.id AS projectlast_ownerid,
                	$puyoung
                	ld_project.startdate,
                	ld_project.projectstatus,
                	ld_project.progress,
                	ld_project.targetenddate,
                	ld_project.actualenddate,
                	ld_salesorder.contract_no AS salesorder_no,
                	ld_salesorder.servicecontractsid AS orderid,
                	IFNULL(ld_salesorder.total,0)/IFNULL(ld_salesorder.conversion_rate,1) AS total,
                	IFNULL(ld_salesorder.received_amount,0)/IFNULL(ld_salesorder.conversion_rate,1) AS CashBillamount,
                	IFNULL(ld_salesorder.receivable_balance,0)/IFNULL(ld_salesorder.conversion_rate,1) AS oftenusereport_PaymentBalance
                FROM ld_project 
                LEFT JOIN ld_servicecontracts ld_salesorder ON ld_salesorder.servicecontractsid = ld_project.salesorderid
                LEFT JOIN ld_projectcf ON ld_project.projectid=ld_projectcf.projectid
                LEFT JOIN ld_users ON ld_users.id = ld_project.smownerid
                LEFT JOIN ld_account ON ld_account.accountid = ld_project.accountid
                LEFT JOIN ld_users AS ld_usersaccount ON ld_usersaccount.id = ld_account.smownerid
               	LEFT JOIN ld_crmentity m ON m.crmid=ld_project.salesorderid
                LEFT JOIN (
                	SELECT 
                		GROUP_CONCAT(ld_groups.groupname) AS groupname,
						GROUP_CONCAT(ld_groups.groupid) as groupid,
                		ld_users2group.userid 
                	FROM ld_users2group
                	LEFT JOIN ld_groups ON ld_groups.groupid = ld_users2group.groupid
                	GROUP BY ld_users2group.userid
                ) AS ld_group ON ld_group.userid = ld_project.smownerid
                WHERE ld_project.deleted = 0
                	AND ld_project.approvestatus<>'已拒绝'
                	AND m.setype='ServiceContracts'                    
                    ". sprintf($where,'ld_project')." $whereprogress
                );";
                    
            //echo $SQL.'<br><br>';
            $adb->query($SQL);
            $SQL = "CREATE TEMPORARY TABLE IF NOT EXISTS temptable IGNORE (
                       SELECT * FROM (SELECT * FROM temptable4 UNION ALL SELECT * FROM temptable5) AS F2
                    );";
           //echo $SQL.'<br><br>'; 
       
        $adb->query($SQL);        
        $SQL = "CREATE TEMPORARY TABLE IF NOT EXISTS temptable2 IGNORE (
                SELECT 		
                	'".getFixedLabel('SUBTOTAL')."' projectid,
                	'' projectname,
                	'' project_no,
                	'".getFixedLabel('SUBTOTAL')."' AS  projectlast_name,
                    '' groupname,
					'' report_wx_userid,
					'' report_wx_groupid,
                    '' accountname,
                    '' accountid,
                	'' AS account_name,
                	projectlast_ownerid,
                	'' cf_1395,
                	'' startdate,
                	'' projectstatus,
                	'' progress,
                	'' targetenddate,
                	'' actualenddate,
                	'' salesorder_no,
                    orderid,
                	SUM(total) AS total, 
                	SUM(CashBillamount) as CashBillamount,
                	SUM(oftenusereport_PaymentBalance) as oftenusereport_PaymentBalance
                FROM (SELECT * FROM temptable GROUP BY projectlast_ownerid,orderid) a
                GROUP BY projectlast_ownerid
            );";
        //echo $SQL.'<br><br>';
        
        $adb->query($SQL);   
        $SQL = "CREATE TEMPORARY TABLE IF NOT EXISTS temptable3 IGNORE (
                	SELECT 
                        * 
                    FROM (SELECT * FROM temptable UNION ALL SELECT * FROM temptable2) AS F2 
                    ORDER BY projectlast_ownerid DESC,startdate DESC,projectid DESC
                );";
        //echo $SQL.'<br><br>';
        $adb->query($SQL); 
        
        $SQL = "SELECT 
                projectid,
                projectname as Project_projectname,
                project_no as Project_project_no,
                projectlast_name AS OftenUseReport_lastname,
                groupname AS OftenUseReport_groupname,
				report_wx_userid,
				report_wx_groupid,
                projectlast_ownerid AS projectlast_name2,
                accountname as Accounts_accountname,
                temptable3.accountid as Accounts_accountid,
                account_name as Accounts_last_name,
                cf_1395 as Project_cf_1395,
                startdate as Project_startdate,
                projectstatus as Project_projectstatus,
                progress as Project_progress,
                targetenddate as Project_targetenddate,
                actualenddate as Project_actualenddate,
                salesorder_no as SalesOrder_salesorder_no,
                total as SalesOrder_total, 
                CashBillamount as CashBill_CashBillamount,
                oftenusereport_PaymentBalance
            FROM temptable3 
            UNION ALL
            SELECT 	
                '".getFixedLabel('TOTAL')."' projectid,
                '' as Project_projectname,
                '' as Project_project_no,
                '".getFixedLabel('TOTAL')."' AS OftenUseReport_lastname,
                '' AS OftenUseReport_groupname,
				'' as report_wx_userid,
				'' as report_wx_groupid,
                '' projectlast_name2,
                '' as Accounts_accountname,
                '' as Accounts_accountid,
                '' as Accounts_last_name,
                '' as Project_cf_1395,
                '' as Project_startdate,
                '' as Project_projectstatus,
                '' as Project_progress,
                '' as Project_targetenddate,
                '' as Project_actualenddate,
                '' as SalesOrder_salesorder_no,
                SUM(total) AS SalesOrder_total, 
                SUM(CashBillamount) as CashBill_CashBillamount,
                SUM(oftenusereport_PaymentBalance) as oftenusereport_PaymentBalance
            FROM (SELECT * FROM temptable WHERE orderid>0 GROUP BY orderid) a";  
        //echo $SQL.'<br><br>';
        return $SQL;  
             
    }
    
    
    static function getCashBillApproveWhere(){
    	//收款单是否启用审批流程  0是 1 否
    	$setsystem_approve = getSys_deploy(133);
    	//已收金额计算时是否统计未审核的收款单  0 是 1 否//这个参数改成是否统计未审批的收款单了
    	 $setsystem_check = getSys_deploy(83);
    	if($setsystem_approve['deploy_value']==0){
    		if($setsystem_check['deploy_value']==1){
    			return ' and ifnull(a.approvestatus,"")=\'已批准\' ';
    		}else{
    			return ' and ifnull(a.approvestatus,"") <> \'已拒绝\' ';
    		}
    	}else{
            return '';
    	}
    }
    //销售预测分析表 
    //Edit by luyx 2016-09-26
    // Reason: 销售预测分析表 算法修改
        //1.实际合同金额和签约日期没有统计服务合同数据 bug：0020049
        //2.实际-收款金额 取合同或者服务合同单据上的已收总额 received_amount,
    static function getSalesforecastandanalysistable($where,$forecastdatewhere)
    {
        $newstr = substr($where,0,1);//
        $where=strtolower($where);
        if($newstr =='('){
            $where=' And '.strtolower($where);
        }
        $F5where = '';
        $forecastwhere = '';
        if(!empty($forecastdatewhere)){
            $F5where = " and F5.".$forecastdatewhere;
            //$forecastwhere = " where ld_receivablesforecast.".$forecastdatewhere;//0049081: （http://xiaoshou360.com/xs/hzshuiyou/ [^] ）（客户问题-税友）常用报表-销售预测分析表，如图查找“中国石油集团测井有限公司”客户的数据，不论怎么调节预计收款日期范围，都无法使下面那个收款预测单独显示  所以去掉
        }
        //$where=str_replace("ld_accountcashbill","ld_account",$where);
        global $adb,$languageType;
		$checkoutstatuswhere = ReportSQL::getCashBillApproveWhere();	//已收金额计算时是否统计未审核的收款单  0 是 1 否
        $SQL_summary="SELECT 
                    	ld_potential.smownerid as statistical_one,
                    	ld_potential.accountid as statistical_two,
                    	ld_potential.potentialid as statistical_three,
                    	IFNULL(F6.entitytypeid ,0) as statistical_four,
                    	ld_potential.smownerid,
                    	ld_potential.smownerid as dsd,
                    	F2.last_name,
						F2.wx_userid as report_wx_userid,
						ld_group.groupid as report_wx_groupid,
						ld_group.groupname,
                    	F4.accountname,
                    	F4.accountid,
                    	F4.account_type,
                    	ld_userspotentials.last_name as smcreatorid_lastname,
						ld_userspotentials.wx_userid as report_wx_userid_creator,
                    	ld_potential.potentialname,
                    	ld_potential.potential_no,
                    	ld_potential.potentialid,
                    	ld_potential.sales_stage,
                    	ld_potential.lastsales_stage,
                    	ld_potential.currency_id AS potential_curid,
                    	ld_potential.conversion_rate AS potential_rate,
                    	ld_potential.currency_symbol AS potential_symbol,
                    	ifnull(ld_potential.amount,0)/IFNULL(ld_potential.conversion_rate,1) AS total,
                    	ld_potential.closingdate,
                    	if(F5.currency_id > 1,ifnull(F5.amount,0)/F5.conversion_rate,ifnull(F5.amount,0)) as reamount,
                    	F5.receivablesforecastdate,
                    	ifnull(F6.total,0) as retotal,
                    	F6.currency_id as sales_curid,
                    	F6.conversion_rate as sales_rate,
                    	F6.currency_symbol as sales_symbol,
                    	F5.currency_id AS re_curid,
                    	F5.conversion_rate AS re_rate,
                    	F5.currency_symbol AS re_symbol,
                    
                    	IFNULL(F6.received_amount,0) AS amount,
                    	F6.currency_id AS ca_curid,
                    	F6.conversion_rate AS ca_rate,
                    	F6.currency_symbol AS ca_symbol,
                    	F6.signed_data as plandate,
                    	F6.cashbilldate as actualdate,
                    	CONCAT('S:',swort_s,' W:',swort_w,' O:',swort_o,' T:',swort_t) AS SWOT,
                    	ld_potential.productcategory
                    FROM (
                        SELECT
                        	ld_potential.*,
                        	GREATEST(1,IFNULL(countsalesorderpotential,0),IFNULL(countforcast,0)) AS rownum
                        FROM ld_potential 
                        LEFT JOIN (
                        	SELECT 
                        		COUNT(1) AS countsalesorderpotential,
                        		ld_potential.potentialid 
                        	FROM ld_salesorder 
                        	INNER JOIN ld_potential ON ld_salesorder.potentialid=ld_potential.potentialid 
                        	GROUP BY potentialid
                        ) AS salesorderpotential ON ld_potential.potentialid=salesorderpotential.potentialid
                        LEFT JOIN (
                        	SELECT 
                        		COUNT(1) AS countforcast,
                        		ld_potential.potentialid 
                        	FROM ld_receivablesforecast 
                        	INNER JOIN ld_potential on ld_receivablesforecast.potentialsid=ld_potential.potentialid
                        	$forecastwhere
                        	GROUP BY ld_potential.potentialid  
                        ) AS forcastpotential on forcastpotential.potentialid=ld_potential.potentialid
                    ) ld_potential
                    CROSS JOIN sequence ON seq>0 AND seq<=ld_potential.rownum
                    LEFT JOIN ld_contactdetails AS ld_contactdetailspotentials ON ld_contactdetailspotentials.contactid = ld_potential.contactid
                    LEFT JOIN ld_users AS F2 ON F2.id = ld_potential.smownerid
                    LEFT JOIN ld_users AS ld_userspotentials ON ld_userspotentials.id = ld_potential.smcreatorid
                    LEFT JOIN ld_account AS F4 ON F4.accountid = ld_potential.accountid
                    LEFT JOIN ld_account AS ld_accountpotentials ON ld_accountpotentials.accountid = ld_potential.accountid
					LEFT JOIN (
						select GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid) as groupname,
                        GROUP_CONCAT(ld_groups.groupid order by ld_groups.groupid ) as groupid,
                        ld_users2group.userid from ld_users2group
						LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
						GROUP BY ld_users2group.userid
					) as ld_group on ld_group.userid = ld_potential.smownerid
                    LEFT JOIN (
                    	SELECT
                    		(@i := CASE WHEN @potentialsid=potentialsid THEN @i + 1 ELSE 1 END )  rownum, 
                    		ld_receivablesforecast.*,
                    		(@potentialsid:=potentialsid) AS parent_potentialsid
                    	FROM ld_receivablesforecast ,
                    	(SELECT  @i := 0, @potentialsid:='') AS a
                    	GROUP BY potentialsid,receivablesforecastid
                    	ORDER BY potentialsid,receivablesforecastdate,receivablesforecastid
                    ) AS F5 ON F5.potentialsid = ld_potential.potentialid AND F5.rownum=sequence.seq
                    LEFT JOIN (
                    	SELECT
                    		(@i := CASE WHEN @potentialid=potentialid THEN @i + 1 ELSE 1 END )  rownum, 
                    		orders.*,
                    		(@potentialid:=potentialid) AS parent_potentialsid
                    	FROM (	
                    	   SELECT
                    			total,
                    			received_amount/IFNULL(conversion_rate, 1) AS received_amount,
                    			cashbilldate,
                    			signed_data,
                    			potentialid,
                    			salesorderid AS entitytypeid,
                    			currency_id,
                    			IFNULL(conversion_rate, 1) AS conversion_rate,
                    			currency_symbol
                    		FROM ld_salesorder
                    		WHERE deleted = 0
                    			AND potentialid>0
                    			AND approvestatus<>'已拒绝'
                    			AND IFNULL(sostatus,'')<>'已作废'
                    		UNION ALL
                    			SELECT
                    				total,
                    				received_amount/ifnull(conversion_rate, 1) AS received_amount,
                    				cashbilldate,
                    				due_date,
                    				potentialid,
                    				servicecontractsid,
                    				currency_id,
                    				IFNULL(conversion_rate, 1) AS conversion_rate,
                    				currency_symbol
                    			FROM ld_servicecontracts
                    			WHERE deleted = 0
                    				AND potentialid>0
                    				AND approvestatus<>'已拒绝'
                    				AND IFNULL(contract_status,'') <> '已作废'
                    	) AS orders,
                    	(SELECT  @i := 0, @potentialid:='') AS a
                    	GROUP BY potentialid,entitytypeid
                    	ORDER BY potentialid,signed_data,entitytypeid
                    ) AS F6 ON F6.potentialid = ld_potential.potentialid AND F6.rownum=sequence.seq
                    WHERE ld_potential.deleted=0  ".$F5where." ". str_replace('%s', 'ld_potential', $where)." ";
//        echo $SQL_summary.'<br><br>';die;
        $resultt=$adb->query($SQL_summary);
        
        //销售机会的小计
        $SQL="CREATE TEMPORARY TABLE IF NOT EXISTS temptable2 IGNORE ( 
			SELECT 
				'".getFixedLabel('SUBTOTAL')."' statistical_one, 
				'' statistical_two, 
				statistical_three, 
				'' statistical_four, 
				'".getFixedLabel('SUBTOTAL')."' smownerid, 
				dsd, 
				'".getFixedLabel('SUBTOTAL')."' last_name,
				'' report_wx_userid,
				'' report_wx_groupid,
				'' groupname,
				'' accountname, 
				'' accountid,
				'' account_type, 
				'' smcreatorid_lastname,
				'' report_wx_userid_creator,
				'' potentialname, '' potential_no,'' potentialid,
				'' sales_stage, 
				'' lastsales_stage,
				potential_curid,
				potential_rate,
				potential_symbol,
				sum(ifnull(total,0)) AS total, 
				'' closingdate, 
				0.00 AS reamount, 
				'' receivablesforecastdate, 
				retotal AS retotal,
				sales_curid,
				sales_rate,
				sales_symbol,
				re_curid,
				re_rate,
				re_symbol, 
				0.00 AS amount,
				ca_curid,
				ca_rate,
				ca_symbol, 
				'' plandate, 
				'' actualdate, 
				'' SWOT, 
				'' productcategory 
			FROM ( 
				$SQL_summary
            ) AS a 
            GROUP BY dsd);";
        //echo $SQL.'<br><br>';die;
        $resultt=$adb->query($SQL);
        
        
        //小计合同金额
        $SQL="CREATE TEMPORARY TABLE IF NOT EXISTS temptable3 IGNORE ( 
            SELECT 
				'".getFixedLabel('SUBTOTAL')."' statistical_one, 
				'' statistical_two, 
				'' as statistical_three, 
				statistical_four, 
				'".getFixedLabel('SUBTOTAL')."' smownerid, 
				dsd, 
				'".getFixedLabel('SUBTOTAL')."' last_name, 
				'' report_wx_userid,
				'' report_wx_groupid,
				'' groupname,
				'' accountname, 
				'' accountid, 
				'' account_type, 
				'' smcreatorid_lastname, 
				'' report_wx_userid_creator,
				'' potentialname, '' potential_no,'' potentialid,
				'' sales_stage,
				  '' lastsales_stage,
				potential_curid,
				potential_rate,
				potential_symbol, 
				0.00 AS total, 
				'' closingdate, 
				0.00 AS reamount, 
				'' receivablesforecastdate, 
				sum(retotal) AS retotal,
				sales_curid,
				sales_rate,
				sales_symbol,
				re_curid,
				re_rate,
				re_symbol, 
				0.00 AS amount,
				ca_curid,
				ca_rate,
				ca_symbol, 
				'' plandate, 
				'' actualdate, 
				'' SWOT, 
				'' productcategory 
            FROM ( 
				$SQL_summary
            ) AS a 
            GROUP BY dsd);";
//        echo $SQL.'<br><br>';die;
        $resultt=$adb->query($SQL);    
        
        
        //预测金额和实际收款金额合计
		$SQL="CREATE TEMPORARY TABLE IF NOT EXISTS temptable4 IGNORE ( 
            SELECT 
				'".getFixedLabel('SUBTOTAL')."' statistical_one, 
				'' statistical_two, 
				'' statistical_three, 
				'' statistical_four, 
				'".getFixedLabel('SUBTOTAL')."' smownerid, 
				dsd, 
				'".getFixedLabel('SUBTOTAL')."' last_name,
				'' report_wx_userid,
				'' report_wx_groupid,
				'' groupname,
				'' accountname, 
				'' accountid, 
				'' account_type, 
				'' smcreatorid_lastname, 
				'' report_wx_userid_creator,
				'' potentialname, '' potential_no, '' potentialid,
				'' sales_stage,
				'' lastsales_stage,
				potential_curid,
				potential_rate,
				potential_symbol, 
				0.00 AS total, 
				'' closingdate, 
				SUM(reamount) AS reamount, 
				'' receivablesforecastdate, 
				0.00 AS retotal,
				sales_curid,
				sales_rate,
				sales_symbol,
				re_curid,
				re_rate,
				re_symbol, 
				SUM(amount) AS amount,
				ca_curid,
				ca_rate,
				ca_symbol, 
				'' plandate, 
				'' actualdate, 
				'' SWOT, 
				'' productcategory 
            FROM (
                $SQL_summary
            ) a
            GROUP BY dsd );";
        $resultt=$adb->query($SQL);
        //echo $SQL.'<br><br>';  
     
		$SQL="CREATE TEMPORARY TABLE IF NOT EXISTS temptable5 IGNORE ( 
            SELECT 
				'".getFixedLabel('SUBTOTAL')."' statistical_one, 
				'' statistical_two, 
				'' statistical_three, 
				'' statistical_four, 
				'".getFixedLabel('SUBTOTAL')."' smownerid, 
				dsd, 
				'".getFixedLabel('SUBTOTAL')."' last_name, 
				'' report_wx_userid,
				'' report_wx_groupid,
				'' groupname,
				'' accountname, 
				'' accountid, 
				'' account_type, 
				'' smcreatorid_lastname, 
				'' report_wx_userid_creator,
				'' potentialname, '' potential_no,'' potentialid,
				'' sales_stage, 
				'' lastsales_stage, 
				potential_curid,
				potential_rate,
				potential_symbol,
				SUM(total) AS total, 
				'' closingdate, 
				 sum(ifnull(reamount,0)) AS reamount, 
				'' receivablesforecastdate, 
				SUM(if(sales_curid>1,retotal/sales_rate,retotal)) AS retotal,
				sales_curid,
				sales_rate,
				sales_symbol,
				re_curid,
				re_rate,
				re_symbol, 
				sum(ifnull(amount,0)) AS amount,
				ca_curid,
				ca_rate,
				ca_symbol, 
				'' plandate, 
				'' actualdate, 
				'' SWOT, 
				'' productcategory 
            FROM ( 
				SELECT * FROM temptable2 
				UNION SELECT * FROM temptable3 
				UNION SELECT * FROM temptable4 ) AS T 
            GROUP BY T.dsd );";  
            
        $resultt=$adb->query($SQL);
        //echo $SQL.'<br><br>';      

		$SQL="CREATE TEMPORARY TABLE IF NOT EXISTS temptable6 IGNORE (
			SELECT
                '合计' statistical_one,
                '' statistical_two,
                '' statistical_three,
                '' statistical_four,
                '' smownerid,
                (select max(id)+1 from ld_users) dsd,
                '合计' last_name,
				'' report_wx_userid,
				'' report_wx_groupid,
				'' groupname,
                '' accountname,
                '' accountid, 
                '' account_type,
                '' smcreatorid_lastname,
				'' report_wx_userid_creator,
                '' potentialname,
                '' potential_no,'' potentialid,
                '' sales_stage,
                '' lastsales_stage,
                '' potential_curid,
                '' potential_rate,
                '' potential_symbol,
                SUM(total) AS total,
                '' closingdate,
                sum(ifnull(reamount,0)) AS reamount,
                '' receivablesforecastdate,
                retotal/ifnull(sales_rate,1) AS retotal,
				'' sales_curid,
				'' sales_rate,
				'' sales_symbol,
                '' re_curid,
                '' re_rate,
                '' re_symbol,
                sum(ifnull(amount,0)) AS amount,
                '' ca_curid,
                '' ca_rate,
                '' ca_symbol,
                '' plandate,
                '' actualdate,
                '' SWOT,
                '' productcategory
			FROM temptable5);";
        $resultt=$adb->query($SQL);  
        //echo $SQL.'<br><br>'; 

        $SQL="SELECT
            statistical_one,
            statistical_two,
            statistical_three,
            statistical_four,
            last_name AS potentials_last_name,
			report_wx_userid,
			report_wx_groupid,
			groupname as potentials_groupname,
            accountname AS accounts_accountname,
            accountid AS accounts_accountid,
            account_type AS accounts_account_type,
            smcreatorid_lastname AS potentials_potentials_smcreatorid,
			report_wx_userid_creator,
            potentialname AS potentials_potentialname,
            potential_no as potentials_potential_no,
             potentialid as potentials_potentialid,
            sales_stage AS potentials_sales_stage,
            lastsales_stage AS potentials_lastsales_stage,
            potential_curid,
            potential_rate,
            potential_symbol,
            total AS salesorder_total,
            closingdate AS potentials_closingdate,
            reamount AS potentials_total,
            receivablesforecastdate AS potentials_receivablesforecastdate,
            retotal AS potentials_retotal,
			sales_curid,
			sales_rate,
			sales_symbol,
            re_curid,
            re_rate,
            re_symbol,
            amount AS potentials_amount,
            ca_curid,
            ca_rate,
            ca_symbol,
            plandate AS potentials_plandate,
            actualdate AS potentials_actualdate,
            SWOT AS potentials_SWOT,
            productcategory AS potentials_productcategory
        FROM (
        	SELECT 
        		*
        	FROM ($SQL_summary) AS a
        	UNION ALL select * from temptable5 
        	UNION ALL select * from temptable6
        	ORDER BY dsd,smownerid,closingdate) a";  
        //echo $SQL.'<br><br>';
        return $SQL;
        
    }
    
    
    // 合同订单跟踪表
    // Edit by luyx 2017-03-14 
    // Reason: 重写算反，报表太慢
    static function getSalesOrderTrack($where,$whereapp,$wherecomm,$whereServiceContracts,$whereBILL)
    {
        
        global $adb,$languageType;
         
          
        crm_load_class_file('cls_Common_Sql','include/utils');
        
        
        //echo '$setsystem='.$setsystem."<br>";
        //echo '$checkoutstatuswhere='.$checkoutstatuswhere."<br>";
        
        
        
        //$where：合同订单查询范围，格式：and ld_salesorder.signed_data between '2017-03-01' and '2017-03-31' and %s.smownerid in ()
        //$where：服务合同查询范围，格式：and ld_servicecontracts.due_date between '2017-03-01' and '2017-03-31' and %s.smownerid in ()
        //$wherecomm：费用报销单范围，格式：and ld_commission.approvestatus='已批准'
        //$wherecomm：佣金单范围，格式：and ld_commission.approvestatus='已批准'       
        //$whereBILL= and %s<>'ServiceContracts'
                
        //echo '$where='.$where."<br>";
        //echo '$whereServiceContracts='.$whereServiceContracts."<br>";
        //echo '$whereapp='.$whereapp."<br>";
        //echo '$whereBILL='.$whereBILL."<br>";
        //echo '$wherecomm='.$wherecomm."<br>";

        //zxm 2022-0328 合同跟踪表  合同类型条件
        $contracttype_str = '';
        $contracttype_arr = [];
        $servicecontract_contracttype_select = $_REQUEST['servicecontract_contracttype_select'];
        if(!empty($servicecontract_contracttype_select)&&$servicecontract_contracttype_select!='null'&&$servicecontract_contracttype_select!='undefined'){
            //dump('wwww');
            $contracttype_arr[] = $servicecontract_contracttype_select;
        }
        $salesorder_contracttype_select = $_REQUEST['salesorder_contracttype_select'];
        if(!empty($salesorder_contracttype_select)&&$salesorder_contracttype_select!='null'&&$salesorder_contracttype_select!='undefined'){
            $contracttype_arr[] = $salesorder_contracttype_select;
        }
        if(!empty($contracttype_arr)){
            $contracttype_str = ' where find_in_set(SalesOrder_contracttype,"'.  implode(',',$contracttype_arr).'")';
        }
        //把 $wherecomm 字符串转化一下：全部->All  已批准->已配准
		if($_REQUEST['basicotherfindsapp']&&$_REQUEST['basicotherfindsapp'] == 'true'){
			$wherecomm = 'yingshou';
		}else{
			$wherecomm='All';
		}
        /*if(strstr($wherecomm,"已批准"))
        {
            $wherecomm='已批准';
        }
        else
        {
            $wherecomm='All';
        }*/
        
        //echo $where;die();
        //echo $whereServiceContracts;die();
        $versioninfo = getVersionTradeInfo();
        $namealias='';
        $namealias2='';
        $tablefield='';
        $subtotalnamealis='';
        $totalnamealis='';
        $leftjointable1='';
        $leftjointable2='';
        //zxm 20230511 	BUG0066198	自用经销商账套，合同跟踪表，增加“合同类型”、“渠道伙伴”和“最终客户”三列
        if($versioninfo['account']=='灵当自用'){
            $namealias = " SalesOrder_end_accountid,";
            $namealias2 = " ld_order.end_accountid AS SalesOrder_end_accountid,";
            $tablefield = " ld_account2.accountname as end_accountid,";
            $subtotalnamealis = " '' as SalesOrder_end_accountid,";
            $totalnamealis = " '',";
            $allnamealis = " SalesOrder_end_accountid,";
            $leftjointable1 = " LEFT JOIN  ld_account AS ld_account2 ON ld_account2.accountid = ld_salesorder.end_accountid ";
            $leftjointable2 = " LEFT JOIN  ld_account AS ld_account2 ON ld_account2.accountid = ld_servicecontracts.end_accountid ";
        }

        //如果单据类型：合同订单
        if(strstr($whereBILL,"ServiceContracts"))
        {
            //$sql_report：合同订单跟踪表报表数据
            $sql_report="(
                SELECT
                	salesorder_smownerid AS SalesOrder_smownerid,
					salesorder_groupname AS OftenUseReport_groupname,
                    report_wx_groupid,report_wx_userid,
                	modulename AS SalesOrder_module,
                	1 AS secfh,
                	statistical_field,
                	SalesOrder_Subject, 
                	SalesOrder_SalesOrder_No, 
                    salesorder_stockpresence,
                	salesOrder_signed_data, 
                	SalesOrder_Accountid,
                	SalesOrder_Accountid_id, 
                	$namealias
                	SalesOrder_soStatus, 
                	SalesOrder_contracttype, 
                	SalesOrder_quantity, 
                	SalesOrder_approvestatus, 
                	SalesOrder_duedate, 
                	SalesOrder_CreatedTime, 
                	ifnull(SalesOrder_Total,0) AS SalesOrder_Total,
                	SalesOrder_Symbol,
                	SalesOrder_Curid,
                	SalesOrder_Rate, 
                	ifnull(invoice_total,0) AS Invoice_Total,
                	ifnull(nothave_invoicetotal,0) AS OftenUseReport_InvoiceBalance,  
                	ifnull(salesorder_havecashbackamount,0) AS SalesOrder_havecashbackamount,  
                	ifnull(salesorder_totalcashbackamount,0) AS SalesOrder_totalcashbackamount,  
                	ifnull(salesorder_balancecashbackamount,0) AS SalesOrder_balancecashbackamount,  
                	ifnull(expense_total,0) OftenUseReport_Expenseamount,
                	ifnull(received_total,0) AS OftenUseReport_CashBillamount,
                	ifnull(receivable_balance,0) AS OftenUseReport_PaymentPlanBalance,
                	ifnull(commission_total,0) AS OftenUseReport_Amount,                   
                	ifnull(TotalCost,0) AS OftenUseReport_TotalCost,
                	IFNUll(ifnull(SalesOrder_Total,0)/IF(ifnull(SalesOrder_Rate,0)=0,1,SalesOrder_Rate),0)-ifnull(expense_total,0)-ifnull(commission_total,0)-ifnull(TotalCost,0) AS OftenUseReport_GrossProfit,
                	(ifnull(SalesOrder_Total,0)/IF(ifnull(SalesOrder_Rate,0)=0,1,SalesOrder_Rate)-ifnull(expense_total,0)-ifnull(commission_total,0)-ifnull(TotalCost,0))*100/( ifnull(SalesOrder_Total,0)/IF(ifnull(SalesOrder_Rate,0)=0,1,SalesOrder_Rate))  AS OftenUseReport_GrossProfitl,
                	CONCAT(lbl_action, 'C') AS lbl_action 
                FROM ( 
                	SELECT
                		ld_order.salesorderid AS lbl_action,
                		ld_users.last_name AS salesorder_smownerid,
                        ld_users.wx_userid as report_wx_userid,
						ld_group.groupname AS salesorder_groupname,
                        ld_group.groupid as report_wx_groupid,
                		CONVERT (ld_users.id, CHAR) AS statistical_field,
                		ld_order.salesorder_no AS salesorder_salesorder_no,
                        ld_order.stockpresence AS salesorder_stockpresence,
                		ld_order.module,
                		ld_order.modulename,
                		ld_order.signed_data AS salesorder_signed_data,
                		ld_order.createdtime AS salesorder_createdtime,
                		ld_order.`subject` AS salesorder_subject,
                		ld_order.accountname AS salesorder_accountid,
                		ld_order.accountid AS salesorder_accountid_id,
                		$namealias2
                		ld_order.sostatus AS salesorder_sostatus,
                		ld_order.contracttype AS salesorder_contracttype,
                		ld_order.totalquantity AS salesorder_quantity,
                		ld_order.approvestatus AS salesorder_approvestatus,
                		ld_order.duedate AS salesorder_duedate,
                		ld_order.total AS salesorder_total,
                		ld_order.received_amount AS received_total,
                		ld_order.receivable_balance AS receivable_balance,
                		ld_order.have_invoicetotal AS invoice_total,
                		ld_order.nothave_invoicetotal AS nothave_invoicetotal,
                		ld_order.havecashbackamount AS salesorder_havecashbackamount,
                		ld_order.totalcashbackamount AS salesorder_totalcashbackamount,
                		ld_order.balancecashbackamount AS salesorder_balancecashbackamount,
                		ld_order.currency_symbol AS salesorder_symbol,
                		ld_order.currency_id AS salesorder_curid,
                		ld_order.conversion_rate AS salesorder_rate,
                		(SELECT 
                			CASE
                			
                                WHEN EXISTS (SELECT * FROM ld_version WHERE trade='puyoung' AND account='lingdang') THEN
                                    SUM(ifnull(a.productcost,0)/IF(ifnull(ld_order.conversion_rate,0)=0,1,ld_order.conversion_rate))  
                				ELSE
                					SUM(IF(ifnull(a.productcost,0)+0=0,ifnull(b.costprice,0),ifnull(a.productcost,0)+0)*ifnull(a.quantity,0)/IF(ifnull(a.productcost,0)+0=0,1,IF(ifnull(ld_order.conversion_rate,0)=0,1,ifnull(ld_order.conversion_rate,1))))
                			END AS productcost
                		FROM ld_salesorderdetail a
                		LEFT JOIN ld_products b ON a.productid=b.productid 
                		WHERE a.id=ld_order.salesorderid) AS TotalCost,
                		ld_expense.total AS expense_total,
                		ld_commission2payment.total AS commission_total
                	FROM (
                		SELECT
                			ld_salesorder.salesorderid,
                			ld_salesorder.salesorder_no,
                            ld_salesorder.stockpresence,
                			ld_salesorder.signed_data,
                			ld_salesorder.duedate,
                			ld_salesorder.createdtime,
                			ld_salesorder.`subject`,
                			ld_salesorder.accountid,
                			$tablefield
                			ld_salesorder.sostatus,
                			ld_salesorder.contracttype,
                			ld_salesorder.totalquantity,
                			ld_salesorder.total,
                			ld_salesorder.received_amount/IF(ifnull(ld_salesorder.conversion_rate,0)=0,1,ld_salesorder.conversion_rate) AS received_amount,
                			ld_salesorder.receivable_balance/IF(ifnull(ld_salesorder.conversion_rate,0)=0,1,ld_salesorder.conversion_rate) AS receivable_balance,
                			ld_salesorder.have_invoicetotal/IF(ifnull(ld_salesorder.conversion_rate,0)=0,1,ld_salesorder.conversion_rate) AS have_invoicetotal,
                			ld_salesorder.nothave_invoicetotal/IF(ifnull(ld_salesorder.conversion_rate,0)=0,1,ld_salesorder.conversion_rate) AS nothave_invoicetotal,
                			ld_salesorder.havecashbackamount/IF(ifnull(ld_salesorder.conversion_rate,0)=0,1,ld_salesorder.conversion_rate) AS havecashbackamount,
                			ld_salesorder.totalcashbackamount/IF(ifnull(ld_salesorder.conversion_rate,0)=0,1,ld_salesorder.conversion_rate) AS totalcashbackamount,
                			ld_salesorder.balancecashbackamount/IF(ifnull(ld_salesorder.conversion_rate,0)=0,1,ld_salesorder.conversion_rate) AS balancecashbackamount,
                			ld_salesorder.currency_symbol,
                			ld_salesorder.currency_id,
                			ld_salesorder.conversion_rate,
                			ld_salesorder.deleted,
                			ld_salesorder.approvestatus,
                			ld_salesorder.smownerid,
                			'SalesOrder' AS module,
               				'".getTranstab('SalesOrder')."' AS modulename,
                			ld_accountsalesorder.accountname
                		FROM ld_salesorder
                		LEFT JOIN ld_account AS ld_accountsalesorder ON ld_accountsalesorder.accountid = ld_salesorder.accountid
                		$leftjointable1
                		WHERE ld_salesorder.deleted=0 AND (
                				CASE
                					WHEN '".$wherecomm."'='yingshou' THEN ld_salesorder.receivable_balance >0 
                					ELSE 1=1
                				END)  
                			AND ifnull(ld_salesorder.sostatus,'')<>'已作废'
                			AND ifnull(ld_salesorder.approvestatus,'')<>'已拒绝' ".str_replace('%s', 'ld_salesorder', $where). "
                		) ld_order
                	LEFT JOIN (
                		SELECT
                			sum(b.amount/IF(ifnull(a.conversion_rate,0)=0,1,a.conversion_rate)) AS total,
                			b.entitytypeid
                		FROM ld_commission a
                		LEFT JOIN ld_commission2payment b ON a.commission_id = b.commission_id
                		WHERE a.deleted = 0
                			AND ifnull(a.approvestatus,'')<>'已拒绝'
                			AND b.entitytypeid>0
                		GROUP BY b.entitytypeid
                		) AS ld_commission2payment ON ld_commission2payment.entitytypeid = ld_order.salesorderid
                	LEFT JOIN (
                		SELECT 
                			ld_expensedetail.entitytypeid,
                			sum(ld_expensedetailscf.rmb_total) as total
                		FROM ld_expense 
                		LEFT JOIN ld_expensedetail on ld_expensedetail.expenseid=ld_expense.expenseid
                		LEFT JOIN ld_expensedetailscf on ld_expensedetail.expensedetailid=ld_expensedetailscf.expensedetailid
                		WHERE ld_expense.deleted=0
                			AND ifnull(ld_expense.approvestatus,'')<>'已拒绝'
                			AND ld_expensedetail.entitytypeid>0
                		GROUP BY ld_expensedetail.entitytypeid
                		) AS ld_expense ON ld_expense.entitytypeid=ld_order.salesorderid
					LEFT JOIN (
						select GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid) as groupname,
                        GROUP_CONCAT(ld_groups.groupid order by ld_groups.groupid ) as groupid,
                        ld_users2group.userid from ld_users2group
						LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
						GROUP BY ld_users2group.userid
					) as ld_group on ld_group.userid = ld_order.smownerid
                	LEFT JOIN ld_users ON ld_users.id = ld_order.smownerid
                ) tmp ".$contracttype_str.")";
//            echo $sql_report."</br></br>";die;
        }
        elseif(strstr($whereBILL,"SalesOrder"))
        {
            //如果单据类型：服务合同
            //$sql_report：合同订单跟踪表报表数据
            $sql_report="(
                SELECT
                	salesorder_smownerid AS SalesOrder_smownerid,
					salesorder_groupname AS OftenUseReport_groupname,
                    report_wx_groupid ,report_wx_userid,
                	modulename AS SalesOrder_module,
                	1 AS secfh,
                	statistical_field,
                	SalesOrder_Subject, 
                	SalesOrder_SalesOrder_No,
                    salesorder_stockpresence, 
                	salesOrder_signed_data, 
                	SalesOrder_Accountid,
                	SalesOrder_Accountid_id, 
                	$namealias
                	SalesOrder_soStatus, 
                	SalesOrder_contracttype, 
                	SalesOrder_quantity, 
                	SalesOrder_approvestatus, 
                	SalesOrder_duedate, 
                	SalesOrder_CreatedTime, 
                	ifnull(SalesOrder_Total,0) AS SalesOrder_Total,
                	SalesOrder_Symbol,
                	SalesOrder_Curid,
                	SalesOrder_Rate, 
                	ifnull(invoice_total,0) AS Invoice_Total,
                	ifnull(nothave_invoicetotal,0) AS OftenUseReport_InvoiceBalance, 
					ifnull(salesorder_havecashbackamount,0) AS SalesOrder_havecashbackamount,  
                	ifnull(salesorder_totalcashbackamount,0) AS SalesOrder_totalcashbackamount,  
                	ifnull(salesorder_balancecashbackamount,0) AS SalesOrder_balancecashbackamount,  
                	ifnull(expense_total,0) OftenUseReport_Expenseamount,
                	ifnull(received_total,0) AS OftenUseReport_CashBillamount,
                	ifnull(receivable_balance,0) AS OftenUseReport_PaymentPlanBalance,
                	ifnull(commission_total,0) AS OftenUseReport_Amount,                   
                	ifnull(TotalCost,0) AS OftenUseReport_TotalCost,
                	ifnull(SalesOrder_Total,0)/IF(ifnull(SalesOrder_Rate,0)=0,1,SalesOrder_Rate)-ifnull(expense_total,0)-ifnull(commission_total,0)-ifnull(TotalCost,0) AS OftenUseReport_GrossProfit,
                	(ifnull(SalesOrder_Total,0)/IF(ifnull(SalesOrder_Rate,0)=0,1,SalesOrder_Rate)-ifnull(expense_total,0)-ifnull(commission_total,0)-ifnull(TotalCost,0))*100/( ifnull(SalesOrder_Total,0)/IF(ifnull(SalesOrder_Rate,0)=0,1,SalesOrder_Rate))  AS OftenUseReport_GrossProfitl,
                	CONCAT(lbl_action, 'C') AS lbl_action 
                FROM ( 
                	SELECT
                		ld_order.salesorderid AS lbl_action,
                		ld_users.last_name AS salesorder_smownerid,
                        ld_users.wx_userid as report_wx_userid,
						ld_group.groupname AS salesorder_groupname,
                        ld_group.groupid AS report_wx_groupid,
                		CONVERT (ld_users.id, CHAR) AS statistical_field,
                		ld_order.salesorder_no AS salesorder_salesorder_no,
                        ld_order.stockpresence AS salesorder_stockpresence,
                		ld_order.module,
                		ld_order.modulename,
                		ld_order.signed_data AS salesorder_signed_data,
                		ld_order.createdtime AS salesorder_createdtime,
                		ld_order.`subject` AS salesorder_subject,
                		ld_order.accountname AS salesorder_accountid,
                		ld_order.accountid AS salesorder_accountid_id,
                		$namealias2
                		ld_order.sostatus AS salesorder_sostatus,
                		ld_order.contracttype AS salesorder_contracttype,
                		ld_order.totalquantity AS salesorder_quantity,
                		ld_order.approvestatus AS salesorder_approvestatus,
                		ld_order.duedate AS salesorder_duedate,
                		ld_order.total AS salesorder_total,
                		ld_order.received_amount AS received_total,
                		ld_order.receivable_balance AS receivable_balance,
                		ld_order.have_invoicetotal AS invoice_total,
                		ld_order.nothave_invoicetotal AS nothave_invoicetotal,
                		ld_order.havecashbackamount AS salesorder_havecashbackamount,
                		ld_order.totalcashbackamount AS salesorder_totalcashbackamount,
                		ld_order.balancecashbackamount AS salesorder_balancecashbackamount,
                		ld_order.currency_symbol AS salesorder_symbol,
                		ld_order.currency_id AS salesorder_curid,
                		ld_order.conversion_rate AS salesorder_rate,
                		(SELECT 
                			CASE
                			
                                WHEN EXISTS (SELECT * FROM ld_version WHERE trade='puyoung' AND account='lingdang') THEN
                                    SUM(ifnull(a.productcost,0)/IF(ifnull(ld_order.conversion_rate,0)=0,1,ifnull(ld_order.conversion_rate,1)))  
                				ELSE
                					SUM(IF(ifnull(a.productcost,0)+0=0,ifnull(b.costprice,0),ifnull(a.productcost,0)+0)*ifnull(a.quantity,0)/IF(ifnull(a.productcost,0)+0=0,1,IF(ifnull(ld_order.conversion_rate,0)=0,1,ifnull(ld_order.conversion_rate,1))))
                			END AS productcost
                		FROM ld_servicecontractsdetail a
                		LEFT JOIN ld_products b ON a.productid=b.productid 
                		WHERE a.id=ld_order.salesorderid) AS TotalCost,
                		ld_expense.total AS expense_total,
                		ld_commission2payment.total AS commission_total
                	FROM (					
                		SELECT
                			ld_servicecontracts.servicecontractsid AS salesorderid,
                			ld_servicecontracts.contract_no AS salesorder_no,
                            ld_servicecontracts.stockpresence,
                			ld_servicecontracts.due_date AS signed_data,
                			ld_servicecontracts.due_date AS duedate,
                			ld_servicecontracts.createdtime,
                			ld_servicecontracts.`subject`,
                			ld_servicecontracts.accountid,
                			$tablefield
                			ld_servicecontracts.contract_status AS sostatus,
                			ld_servicecontracts.contract_type AS contracttype,
                			ld_servicecontracts.totalquantity AS totalquantity,
                			ld_servicecontracts.total,
                			ld_servicecontracts.received_amount/IF(ifnull(ld_servicecontracts.conversion_rate,0)=0,1,ld_servicecontracts.conversion_rate) AS received_amount,
                			ld_servicecontracts.receivable_balance/IF(ifnull(ld_servicecontracts.conversion_rate,0)=0,1,ld_servicecontracts.conversion_rate) AS receivable_balance,
                			ld_servicecontracts.have_invoicetotal/IF(ifnull(ld_servicecontracts.conversion_rate,0)=0,1,ld_servicecontracts.conversion_rate) AS have_invoicetotal,
                			ld_servicecontracts.nothave_invoicetotal/IF(ifnull(ld_servicecontracts.conversion_rate,0)=0,1,ld_servicecontracts.conversion_rate) AS nothave_invoicetotal,
                			0 AS havecashbackamount,
                			0 AS totalcashbackamount,
                			0 AS balancecashbackamount,
                			ld_servicecontracts.currency_symbol,
                			ld_servicecontracts.currency_id,
                			ld_servicecontracts.conversion_rate,
                			ld_servicecontracts.deleted,
                			ld_servicecontracts.approvestatus,
                			ld_servicecontracts.smownerid,
                			'ServiceContracts' AS module,
                			'".getTranstab('ServiceContracts')."' AS modulename,
                			ld_accountsalesorder.accountname
                		FROM ld_servicecontracts
                		LEFT JOIN ld_account AS ld_accountsalesorder ON ld_accountsalesorder.accountid = ld_servicecontracts.accountid
                		$leftjointable2
                		WHERE ld_servicecontracts.deleted=0 AND (
                				CASE
                					WHEN '".$wherecomm."'='yingshou' THEN ld_servicecontracts.receivable_balance >0 
                					ELSE 1=1
                				END)  
                			AND ifnull(ld_servicecontracts.contract_status,'')<>'已作废'
                			AND ifnull(ld_servicecontracts.approvestatus,'')<>'已拒绝' ".str_replace('%s', 'ld_servicecontracts', $whereServiceContracts). "
                		) ld_order
                	LEFT JOIN (
                		SELECT
                			sum(b.amount/IF(ifnull(a.conversion_rate,0)=0,1,a.conversion_rate)) AS total,
                			b.entitytypeid
                		FROM ld_commission a
                		LEFT JOIN ld_commission2payment b ON a.commission_id = b.commission_id
                		WHERE a.deleted = 0
                			AND ifnull(a.approvestatus,'')<>'已拒绝'
                			AND b.entitytypeid>0
                		GROUP BY b.entitytypeid
                		) AS ld_commission2payment ON ld_commission2payment.entitytypeid = ld_order.salesorderid
                	LEFT JOIN (
                		SELECT 
                			ld_expensedetail.entitytypeid,
                			sum(ld_expensedetailscf.rmb_total) as total
                		FROM ld_expense 
                		LEFT JOIN ld_expensedetail on ld_expensedetail.expenseid=ld_expense.expenseid
                		LEFT JOIN ld_expensedetailscf on ld_expensedetail.expensedetailid=ld_expensedetailscf.expensedetailid
                		WHERE ld_expense.deleted=0
                			AND ifnull(ld_expense.approvestatus,'')<>'已拒绝'
                			AND ld_expensedetail.entitytypeid>0
                		GROUP BY ld_expensedetail.entitytypeid
                		) AS ld_expense ON ld_expense.entitytypeid=ld_order.salesorderid
					LEFT JOIN (
						select GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid asc) as groupname,
                            GROUP_CONCAT(ld_groups.groupid order by ld_groups.groupid asc) as groupid,
                            ld_users2group.userid from ld_users2group
						LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
						GROUP BY ld_users2group.userid
					) as ld_group on ld_group.userid = ld_order.smownerid
                	LEFT JOIN ld_users ON ld_users.id = ld_order.smownerid
                ) tmp ".$contracttype_str.")";
            //echo $sql_report."</br></br>";die;
          
        }
        else
        {
            //如果单据类型是：全部
            //$sql_report：合同订单跟踪表报表数据
            $sql_report="(
                SELECT
                	salesorder_smownerid AS SalesOrder_smownerid,
                    '',
					salesorder_groupname AS OftenUseReport_groupname,
                    report_wx_groupid ,report_wx_userid,
                	modulename AS SalesOrder_module,
                	1 AS secfh,
                	statistical_field,
                	SalesOrder_Subject, 
                	SalesOrder_SalesOrder_No,
                    salesorder_stockpresence, 
                	salesOrder_signed_data, 
                	SalesOrder_Accountid,
                	SalesOrder_Accountid_id, 
                	$namealias
                	SalesOrder_soStatus, 
                	SalesOrder_contracttype, 
                	SalesOrder_quantity, 
                	SalesOrder_approvestatus, 
                	SalesOrder_duedate, 
                	SalesOrder_CreatedTime, 
                	ifnull(SalesOrder_Total,0) AS SalesOrder_Total,
                	SalesOrder_Symbol,
                	SalesOrder_Curid,
                	SalesOrder_Rate, 
                	ifnull(invoice_total,0) AS Invoice_Total,
                	ifnull(nothave_invoicetotal,0) AS OftenUseReport_InvoiceBalance,  
                	ifnull(salesorder_havecashbackamount,0) AS SalesOrder_havecashbackamount,  
                	ifnull(salesorder_totalcashbackamount,0) AS SalesOrder_totalcashbackamount,  
                	ifnull(salesorder_balancecashbackamount,0) AS SalesOrder_balancecashbackamount,
                	ifnull(expense_total,0) OftenUseReport_Expenseamount,
                	ifnull(received_total,0) AS OftenUseReport_CashBillamount,
                	ifnull(receivable_balance,0) AS OftenUseReport_PaymentPlanBalance,
                	ifnull(commission_total,0) AS OftenUseReport_Amount,                   
                	ifnull(TotalCost,0) AS OftenUseReport_TotalCost,
                	ifnull(SalesOrder_Total,0)/IF(ifnull(SalesOrder_Rate,0)=0,1,SalesOrder_Rate)-ifnull(expense_total,0)-ifnull(commission_total,0)-ifnull(TotalCost,0) AS OftenUseReport_GrossProfit,
                	(ifnull(SalesOrder_Total,0)/IF(ifnull(SalesOrder_Rate,0)=0,1,SalesOrder_Rate)-ifnull(expense_total,0)-ifnull(commission_total,0)-ifnull(TotalCost,0))*100/( ifnull(SalesOrder_Total,0)/IF(ifnull(SalesOrder_Rate,0)=0,1,SalesOrder_Rate))  AS OftenUseReport_GrossProfitl,
                	CONCAT(lbl_action, 'C') AS lbl_action 
                FROM ( 
                	SELECT
                		ld_order.salesorderid AS lbl_action,
                		ld_users.last_name AS salesorder_smownerid,
                        ld_users.wx_userid as report_wx_userid,
						ld_group.groupname AS salesorder_groupname,
                        ld_group.groupid as report_wx_groupid,
                		CONVERT (ld_users.id, CHAR) AS statistical_field,
                		ld_order.salesorder_no AS salesorder_salesorder_no,
                        ld_order.stockpresence AS salesorder_stockpresence,
                		ld_order.module,
                		ld_order.modulename,
                		ld_order.signed_data AS salesorder_signed_data,
                		ld_order.createdtime AS salesorder_createdtime,
                		ld_order.`subject` AS salesorder_subject,
                		ld_order.accountname AS salesorder_accountid,
                		ld_order.accountid AS salesorder_accountid_id,
                		$namealias2
                		ld_order.sostatus AS salesorder_sostatus,
                		ld_order.contracttype AS salesorder_contracttype,
                		ld_order.totalquantity AS salesorder_quantity,
                		ld_order.approvestatus AS salesorder_approvestatus,
                		ld_order.duedate AS salesorder_duedate,
                		ld_order.total AS salesorder_total,
                		ld_order.received_amount AS received_total,
                		ld_order.receivable_balance AS receivable_balance,
                		ld_order.have_invoicetotal AS invoice_total,
                		ld_order.nothave_invoicetotal AS nothave_invoicetotal,
                		ld_order.havecashbackamount AS salesorder_havecashbackamount,
                		ld_order.totalcashbackamount AS salesorder_totalcashbackamount,
                		ld_order.balancecashbackamount AS salesorder_balancecashbackamount,
                		ld_order.currency_symbol AS salesorder_symbol,
                		ld_order.currency_id AS salesorder_curid,
                		ld_order.conversion_rate AS salesorder_rate,
                		(
							SELECT 
								CASE
								
									WHEN EXISTS (SELECT * FROM ld_version WHERE trade='puyoung' AND account='lingdang') THEN
										SUM(ifnull(a.productcost,0)/IF(ifnull(ld_order.conversion_rate,0)=0,1,ifnull(ld_order.conversion_rate,1)))    
									ELSE
										SUM(IF(ifnull(a.productcost,0)+0=0,ifnull(b.costprice,0),ifnull(a.productcost,0)+0)*ifnull(a.quantity,0)/IF(ifnull(a.productcost,0)+0=0,1,IF(ifnull(ld_order.conversion_rate,0)=0,1,ifnull(ld_order.conversion_rate,1))))
								END AS productcost
							FROM (
								SELECT id,productcost,quantity,productid FROM ld_salesorderdetail
								UNION ALL
								SELECT id,productcost,quantity,productid FROM ld_servicecontractsdetail
							)  a
							LEFT JOIN ld_products b ON a.productid=b.productid 
							WHERE a.id=ld_order.salesorderid
						) AS TotalCost,
                		ld_expense.total AS expense_total,
                		ld_commission2payment.total AS commission_total
                	FROM ((
                		SELECT
                			ld_salesorder.salesorderid,
                			ld_salesorder.salesorder_no,
                            ld_salesorder.stockpresence,
                			ld_salesorder.signed_data,
                			ld_salesorder.duedate,
                			ld_salesorder.createdtime,
                			ld_salesorder.`subject`,
                			ld_salesorder.accountid,
                			$tablefield
                			ld_salesorder.sostatus,
                			ld_salesorder.contracttype,
                			ld_salesorder.totalquantity,
                			ld_salesorder.total,
                			ld_salesorder.received_amount/IF(ifnull(ld_salesorder.conversion_rate,0)=0,1,ld_salesorder.conversion_rate) AS received_amount,
                			ld_salesorder.receivable_balance/IF(ifnull(ld_salesorder.conversion_rate,0)=0,1,ld_salesorder.conversion_rate) AS receivable_balance,
                			ld_salesorder.have_invoicetotal/IF(ifnull(ld_salesorder.conversion_rate,0)=0,1,ld_salesorder.conversion_rate) AS have_invoicetotal,
                			ld_salesorder.nothave_invoicetotal/IF(ifnull(ld_salesorder.conversion_rate,0)=0,1,ld_salesorder.conversion_rate) AS nothave_invoicetotal,
                			ld_salesorder.havecashbackamount/IF(ifnull(ld_salesorder.conversion_rate,0)=0,1,ld_salesorder.conversion_rate) AS havecashbackamount,
                			ld_salesorder.totalcashbackamount/IF(ifnull(ld_salesorder.conversion_rate,0)=0,1,ld_salesorder.conversion_rate) AS totalcashbackamount,
                			ld_salesorder.balancecashbackamount/IF(ifnull(ld_salesorder.conversion_rate,0)=0,1,ld_salesorder.conversion_rate) AS balancecashbackamount,
                			ld_salesorder.currency_symbol,
                			ld_salesorder.currency_id,
                			ld_salesorder.conversion_rate,
                			ld_salesorder.deleted,
                			ld_salesorder.approvestatus,
                			ld_salesorder.smownerid,
                			'SalesOrder' AS module,
                			'".getTranstab('SalesOrder')."' AS modulename,
                			ld_accountsalesorder.accountname
                		FROM ld_salesorder
                		LEFT JOIN ld_account AS ld_accountsalesorder ON ld_accountsalesorder.accountid = ld_salesorder.accountid
                		$leftjointable1
                		WHERE ld_salesorder.deleted=0 AND (
                				CASE
                					WHEN '".$wherecomm."'='yingshou' THEN ld_salesorder.receivable_balance >0 
                					ELSE 1=1
                				END) 
                            AND (
                                CASE
                                    WHEN EXISTS (SELECT 1 FROM ld_tab WHERE presence IN (0,2) AND tabid=22) THEN 1=1
                                    ELSE 1=0
                                END)
                			AND ifnull(ld_salesorder.sostatus,'')<>'已作废'
                			AND ifnull(ld_salesorder.approvestatus,'')<>'已拒绝' ".str_replace('%s', 'ld_salesorder', $where). ")
                		UNION ALL (							
                		SELECT
                			ld_servicecontracts.servicecontractsid AS salesorderid,
                			ld_servicecontracts.contract_no AS salesorder_no,
                            ld_servicecontracts.stockpresence,
                			ld_servicecontracts.due_date AS signed_data,
                			ld_servicecontracts.due_date AS duedate,
                			ld_servicecontracts.createdtime,
                			ld_servicecontracts.`subject`,
                			ld_servicecontracts.accountid,
                			$tablefield
                			ld_servicecontracts.contract_status AS sostatus,
                			ld_servicecontracts.contract_type AS contracttype,
                			ld_servicecontracts.totalquantity AS totalquantity,
                			ld_servicecontracts.total,
                			ld_servicecontracts.received_amount/IF(ifnull(ld_servicecontracts.conversion_rate,0)=0,1,ld_servicecontracts.conversion_rate) AS received_amount,
                			
                			ld_servicecontracts.receivable_balance/IF(ifnull(ld_servicecontracts.conversion_rate,0)=0,1,ld_servicecontracts.conversion_rate) AS receivable_balance,
                			ld_servicecontracts.have_invoicetotal/IF(ifnull(ld_servicecontracts.conversion_rate,0)=0,1,ld_servicecontracts.conversion_rate) AS have_invoicetotal,
                			ld_servicecontracts.nothave_invoicetotal/IF(ifnull(ld_servicecontracts.conversion_rate,0)=0,1,ld_servicecontracts.conversion_rate) AS nothave_invoicetotal,
                			0 AS havecashbackamount,
                			0 AS totalcashbackamount,
                			0 AS balancecashbackamount,
                			ld_servicecontracts.currency_symbol,
                			ld_servicecontracts.currency_id,
                			ld_servicecontracts.conversion_rate,
                			ld_servicecontracts.deleted,
                			ld_servicecontracts.approvestatus,
                			ld_servicecontracts.smownerid,
                			'ServiceContracts' AS module,
                			'".getTranstab('ServiceContracts')."' AS modulename,
                			ld_accountsalesorder.accountname
                		FROM ld_servicecontracts
                		LEFT JOIN ld_account AS ld_accountsalesorder ON ld_accountsalesorder.accountid = ld_servicecontracts.accountid
                		$leftjointable2
                		WHERE ld_servicecontracts.deleted=0 AND (
                				CASE
                					WHEN '".$wherecomm."'='yingshou' THEN ld_servicecontracts.receivable_balance >0 
                					ELSE 1=1
                				END) 
                            AND (
                                CASE
                                    WHEN EXISTS (SELECT 1 FROM ld_tab WHERE presence IN (0,2) AND tabid=37) THEN 1=1
                                    ELSE 1=0
                                END)
                			AND ifnull(ld_servicecontracts.contract_status,'')<>'已作废'
                			AND ifnull(ld_servicecontracts.approvestatus,'')<>'已拒绝' ".str_replace('%s', 'ld_servicecontracts', $whereServiceContracts). ")
                		) ld_order
                	LEFT JOIN (
                		SELECT
                			sum(b.amount/IF(ifnull(a.conversion_rate,0)=0,1,a.conversion_rate)) AS total,
                			b.entitytypeid
                		FROM ld_commission a
                		LEFT JOIN ld_commission2payment b ON a.commission_id = b.commission_id
                		WHERE a.deleted = 0
                			AND ifnull(a.approvestatus,'')<>'已拒绝'
                			AND b.entitytypeid>0
                		GROUP BY b.entitytypeid
                		) AS ld_commission2payment ON ld_commission2payment.entitytypeid = ld_order.salesorderid
                	LEFT JOIN (
                		SELECT 
                			ld_expensedetail.entitytypeid,
                			sum(ld_expensedetailscf.rmb_total) as total
                		FROM ld_expense 
                		LEFT JOIN ld_expensedetail on ld_expensedetail.expenseid=ld_expense.expenseid
                		LEFT JOIN ld_expensedetailscf on ld_expensedetail.expensedetailid=ld_expensedetailscf.expensedetailid
                		WHERE ld_expense.deleted=0
                			AND ifnull(ld_expense.approvestatus,'')<>'已拒绝'
                			AND ld_expensedetail.entitytypeid>0
                		GROUP BY ld_expensedetail.entitytypeid
                		) AS ld_expense ON ld_expense.entitytypeid=ld_order.salesorderid
					LEFT JOIN (
						select GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid asc  ) as groupname,
                            GROUP_CONCAT(ld_groups.groupid order by ld_groups.groupid asc ) as groupid, ld_users2group.userid from ld_users2group
						LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
						GROUP BY ld_users2group.userid
					) as ld_group on ld_group.userid = ld_order.smownerid
                	LEFT JOIN ld_users ON ld_users.id = ld_order.smownerid
                ) tmp ".$contracttype_str.")";
            //echo $sql_report."</br></br>";die;
        }

        //$sql_subtotal：合同订单跟踪表小计
        $sql_subtotal="(
            SELECT 
            	concat(SalesOrder_smownerid,'-".getFixedLabel('SUBTOTAL')."') AS SalesOrder_smownerid,
            	concat(statistical_field, '-') AS statistical_field,
               '' as  report_wx_userid,
                '' as  report_wx_groupid,
                	'' SalesOrder_module,
				'' AS OftenUseReport_groupname,
            	1 secfh,
            	'' AS SalesOrder_Subject,
            	'' AS SalesOrder_SalesOrder_No,
                '' AS salesorder_stockpresence,
            	'' AS salesOrder_signed_data,
            	'' AS SalesOrder_accountid,
            	'' AS SalesOrder_accountid_id,
            	$subtotalnamealis
            	'' AS SalesOrder_Status,
            	'' AS SalesOrder_contracttype,
            	'' AS SalesOrder_approvestatus,
            	sum(ifnull(SalesOrder_quantity,0)) AS SalesOrder_quantity,
            	null AS SalesOrder_duedate,
            	null AS SalesOrder_CreatedTime, 
            	sum(if(SalesOrder_Curid > 1,salesorder_total/SalesOrder_Rate,salesorder_total)) AS SalesOrder_total,
            	'' AS SalesOrder_Symbol,
            	'' AS SalesOrder_Curid,
            	'' AS SalesOrder_Rate,
            	sum(Invoice_Total) AS Invoice_Total,
            	sum(OftenUseReport_InvoiceBalance) AS OftenUseReport_InvoiceBalance, 
            	sum(SalesOrder_havecashbackamount) AS SalesOrder_havecashbackamount,
            	sum(SalesOrder_totalcashbackamount) AS SalesOrder_totalcashbackamount,
            	sum(SalesOrder_balancecashbackamount) AS SalesOrder_balancecashbackamount,
            	sum(OftenUseReport_Expenseamount) AS OftenUseReport_Expenseamount,
            	sum(OftenUseReport_CashBillamount) AS OftenUseReport_CashBillamount,
            	sum(OftenUseReport_PaymentPlanBalance) AS OftenUseReport_PaymentPlanBalance,
            	sum(OftenUseReport_Amount) AS OftenUseReport_Amount,
            	ROUND(sum(if(SalesOrder_Curid > 1,OftenUseReport_TotalCost/SalesOrder_Rate,OftenUseReport_TotalCost))) AS OftenUseReport_TotalCost,
            	SUM(OftenUseReport_GrossProfit) AS OftenUseReport_GrossProfit,
            	ROUND(SUM(OftenUseReport_GrossProfit)/sum(if(SalesOrder_Curid > 1,SalesOrder_Total/SalesOrder_Rate,SalesOrder_Total))*100,2) AS OftenUseReport_GrossProfitl,
            	null AS LBL_ACTION 
            FROM $sql_report a
            GROUP BY statistical_field
        )";

         //$sql_total：合同订单跟踪表合计
        $sql_total="(
            SELECT 
            	'".getFixedLabel('TOTAL')."',
            	'".getFixedLabel('TOTAL')."', 
            	'' as report_wx_userid,
				'' as  report_wx_groupid,
                 '',
                '',
            	2,
            	'',
            	'',
                '',
            	'',
            	'',
            	'',
            	$totalnamealis
            	'',
            	'',
            	'',
            	sum(ifnull(SalesOrder_quantity,0)) AS SalesOrder_totalquantity,
            	'',
            	'',
            	sum(if(SalesOrder_Curid > 1,salesorder_total/SalesOrder_Rate,salesorder_total)) AS SalesOrder_total,
            	'' SalesOrder_Symbol,
            	'' SalesOrder_Curid,
            	'' SalesOrder_Rate, 
            	sum(invoice_total) invoice_total,
            	sum(oftenusereport_invoicebalance) AS oftenusereport_invoicebalance,
            	sum(SalesOrder_havecashbackamount) AS SalesOrder_havecashbackamount,
            	sum(SalesOrder_totalcashbackamount) AS SalesOrder_totalcashbackamount,
            	sum(SalesOrder_balancecashbackamount) AS SalesOrder_balancecashbackamount,
            	sum( oftenusereport_expenseamount) AS  oftenusereport_expenseamount,
            	sum( oftenusereport_cashbillamount) AS oftenusereport_cashbillamount,
            	sum( oftenusereport_paymentplanbalance) AS oftenusereport_paymentplanbalance,
            	sum(OftenUseReport_Amount) OftenUseReport_Amount,
            	ROUND(sum(if(SalesOrder_Curid > 1,OftenUseReport_TotalCost/SalesOrder_Rate,OftenUseReport_TotalCost))) AS OftenUseReport_TotalCost,
            	ROUND(SUM(OftenUseReport_GrossProfit),2) AS OftenUseReport_GrossProfit,
            	ROUND(SUM(OftenUseReport_GrossProfit)/sum(if(SalesOrder_Curid > 1,SalesOrder_Total/SalesOrder_Rate,SalesOrder_Total))*100,2) AS OftenUseReport_GrossProfitl,
            	'' 
            FROM $sql_subtotal tmp)";    

        $SQL="
            SELECT
            	*
            FROM (
            	SELECT 
            		SalesOrder_smownerid,
            		statistical_field,
                    report_wx_userid,
                    report_wx_groupid,
            		SalesOrder_module as OftenUseReport_module_zh,
					OftenUseReport_groupname,
            		secfh,
            		SalesOrder_salesorder_no,
                    salesorder_stockpresence,
            		salesOrder_signed_data,
            		SalesOrder_createdtime,
            		SalesOrder_subject,
            		SalesOrder_accountid,
            		SalesOrder_accountid_id,
            		".$allnamealis."
            		SalesOrder_sostatus,
            		SalesOrder_contracttype,
            		SalesOrder_quantity as SalesOrder_totalquantity,
            		SalesOrder_approvestatus,
            	    SalesOrder_duedate,
            		SalesOrder_total,SalesOrder_Curid,
            		SalesOrder_Rate,
            		SalesOrder_Symbol,
            		Invoice_total,
            		OftenUseReport_InvoiceBalance,
            		SalesOrder_havecashbackamount,
            	    SalesOrder_totalcashbackamount,
            	    SalesOrder_balancecashbackamount,
            		OftenUseReport_Expenseamount,
            		OftenUseReport_CashBillamount,
            		OftenUseReport_PaymentPlanBalance,
            		OftenUseReport_Amount,
            		ROUND(OftenUseReport_TotalCost,2) as OftenUseReport_TotalCost,
            		ROUND(OftenUseReport_GrossProfit,2) as OftenUseReport_GrossProfit,
            		ROUND(OftenUseReport_GrossProfitl,2) as OftenUseReport_GrossProfitl,
            		lbl_action 
            	FROM $sql_report tmp
            	UNION ALL $sql_subtotal UNION ALL $sql_total
            ) tmp
            ORDER BY secfh,
            	convert(SalesOrder_smownerid USING gbk),
            	statistical_field,
            	salesorder_signed_data DESC,
            	Salesorder_SalesOrder_No DESC";
//         echo $SQL.'<br><br>';die;
        return $SQL;
    }
    
    
    //应收款统计表按回款计划
    //Edit by luyx
        //0025640：应收款余额币种不用转换
    static function CashBillSum_Paymentplan($where)
    {
        global $adb;
		//已收金额计算时是否统计未审核的收款单
		$focus = CRMEntity::getInstance('CashBill');
		$checkoutstatuswhere = $focus->get_CashBillCheckoutstatusWhere();
        $SQL="CREATE TEMPORARY TABLE
IF NOT EXISTS `temptable` IGNORE (
	SELECT
		ld_UsersPaymentPlan.last_name AS paymentplan_smownerid,
		ld_UsersPaymentPlan.last_name AS paymentplan_smownerid2,
		ld_group.groupname AS paymentplan_groupname,
		ld_group.groupid as report_wx_groupid,
		ld_UsersPaymentPlan.wx_userid as report_wx_userid,
		ld_accountpaymentplan.accountname AS paymentplan_accountid,
        ld_accountpaymentplan.accountid AS paymentplan_accountid_id,
		ld_salesorder.signed_data AS salesorder_signed_data,
		ld_salesorder.`subject` AS paymentplan_salesorderid,
		ld_salesorder.salesorder_no AS salesorder_salesorder_no,
		ld_salesorder.total AS salesorder_hdnGrandTotal,
        ld_salesorder.currency_id AS salesorder_curid,
		ld_salesorder.conversion_rate AS salesorder_rate,
		ld_salesorder.currency_symbol AS salesorder_symbol,
		ld_paymentplan.paymentplan_no AS paymentplan_paymentplan_no,
		ld_paymentplan.plandate AS paymentplan_plandate,
		ld_paymentplan.periodtime AS paymentplan_periodtime,
		ld_paymentplan.amount AS paymentplan_amount,
        ld_paymentplan.currency_id AS paymentplan_curid,
        ld_paymentplan.conversion_rate AS paymentplan_rate,
        ld_paymentplan.currency_symbol AS paymentplan_symbol,
		ifnull(ld_paymentplan.actualamount,0) AS paymentplan_actualamount,
        ld_cashbill.currency_id AS cashbill_curid,
		ld_cashbill.conversion_rate AS cashbill_rate,
		ld_cashbill.currency_symbol AS cashbill_symbol,
		ld_paymentplan.paymentstatus AS paymentplan_paymentstatus,
        (ifnull(ld_paymentplan.amount,0)-ifnull(ld_paymentplan.actualamount,0))/ifnull(ld_paymentplan.conversion_rate,1) AS oftenusereport_paymentplanbalance,
		ld_paymentplan.paymentplanid AS lbl_action
	FROM ld_paymentplan
	LEFT JOIN ld_account AS ld_accountpaymentplan ON ld_paymentplan.accountid = ld_accountpaymentplan.accountid
	LEFT JOIN ld_salesorder ON ld_salesorder.salesorderid = ld_paymentplan.entitytypeid
	INNER JOIN ld_crmentity ON ld_crmentity.crmid = ld_paymentplan.paymentplanid
	INNER JOIN ld_users as ld_UsersPaymentPlan ON ld_UsersPaymentPlan.id = ld_paymentplan.smownerid
	LEFT JOIN (
		select GROUP_CONCAT(ld_groups.groupname) as groupname,GROUP_CONCAT(ld_groups.groupid) as groupid,ld_users2group.userid from ld_users2group
		LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
		GROUP BY ld_users2group.userid
	) as ld_group on ld_group.userid = ld_paymentplan.smownerid
    LEFT JOIN ld_cashbill2paymentplan ON ld_cashbill2paymentplan.paymentplanid = ld_paymentplan.paymentplanid
	left JOIN (select * from ld_cashbill where 1 $checkoutstatuswhere) as ld_cashbill ON ld_cashbill.cashbillid = ld_cashbill2paymentplan.CashBillID  
	WHERE ld_paymentplan.deleted = 0  and ld_paymentplan.entitytype='SalesOrder'
	   AND ld_salesorder.sostatus <> '已作废' 
	   AND IFNULL(ld_paymentplan.amount, 0) - ifnull(
		ld_paymentplan.actualamount,
		0
	) >= 0 ".sprintf($where,'ld_paymentplan')."  );";
        $adb->query($SQL);
    // echo $SQL."</br>";
              $SQL="CREATE TEMPORARY TABLE
IF NOT EXISTS `temptable2` IGNORE (
	SELECT
		ld_UsersPaymentPlan.last_name AS paymentplan_smownerid,
		ld_UsersPaymentPlan.last_name AS paymentplan_smownerid2,
		ld_group.groupname AS paymentplan_groupname,
		ld_group.groupid as report_wx_groupid,
		ld_UsersPaymentPlan.wx_userid as report_wx_userid,
		ld_accountpaymentplan.accountname AS paymentplan_accountid,
        ld_accountpaymentplan.accountid AS paymentplan_accountid_id,
		ld_servicecontracts.due_date AS salesorder_signed_data,
		ld_servicecontracts.`subject` AS paymentplan_salesorderid,
		ld_servicecontracts.contract_no AS salesorder_salesorder_no,
		ld_servicecontracts.total AS salesorder_hdnGrandTotal,
        ld_servicecontracts.currency_id AS salesorder_curid,
		ld_servicecontracts.conversion_rate AS salesorder_rate,
		ld_servicecontracts.currency_symbol AS salesorder_symbol,
		ld_paymentplan.paymentplan_no AS paymentplan_paymentplan_no,
		ld_paymentplan.plandate AS paymentplan_plandate,
		ld_paymentplan.periodtime AS paymentplan_periodtime,
		ld_paymentplan.amount AS paymentplan_amount,
        ld_paymentplan.currency_id AS paymentplan_curid,
        ld_paymentplan.conversion_rate AS paymentplan_rate,
        ld_paymentplan.currency_symbol AS paymentplan_symbol,
		ifnull(ld_paymentplan.actualamount,0) AS paymentplan_actualamount,
        ld_cashbill.currency_id AS cashbill_curid,
		ld_cashbill.conversion_rate AS cashbill_rate,
		ld_cashbill.currency_symbol AS cashbill_symbol,
		ld_paymentplan.paymentstatus AS paymentplan_paymentstatus,
		if(ld_paymentplan.currency_id >1,IFNULL(ld_paymentplan.amount, 0)/ld_paymentplan.conversion_rate,IFNULL(ld_paymentplan.amount, 0)) - 
        if(ld_cashbill.currency_id > 1,ifnull(ld_paymentplan.actualamount,0)/ld_cashbill.conversion_rate,ifnull(ld_paymentplan.actualamount,0))
         AS oftenusereport_paymentplanbalance,
		ld_paymentplan.paymentplanid AS lbl_action
	FROM
		ld_paymentplan
	LEFT JOIN ld_account AS ld_accountpaymentplan ON ld_paymentplan.accountid = ld_accountpaymentplan.accountid
	LEFT JOIN ld_servicecontracts ON ld_servicecontracts.servicecontractsid = ld_paymentplan.entitytypeid
	INNER JOIN ld_crmentity ON ld_crmentity.crmid = ld_paymentplan.paymentplanid
	INNER JOIN ld_users as ld_UsersPaymentPlan ON ld_UsersPaymentPlan.id = ld_paymentplan.smownerid
	LEFT JOIN (
		select GROUP_CONCAT(ld_groups.groupname) as groupname,GROUP_CONCAT(ld_groups.groupid) as groupid,ld_users2group.userid from ld_users2group
		LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
		GROUP BY ld_users2group.userid
	) as ld_group on ld_group.userid = ld_paymentplan.smownerid
    LEFT JOIN ld_cashbill2paymentplan ON ld_cashbill2paymentplan.paymentplanid = ld_paymentplan.paymentplanid
	left JOIN (select * from ld_cashbill where 1 $checkoutstatuswhere) as ld_cashbill ON ld_cashbill.cashbillid = ld_cashbill2paymentplan.CashBillID  
	WHERE
		ld_paymentplan.deleted = 0 and ld_paymentplan.entitytype='ServiceContracts'
	AND ld_servicecontracts.contract_status <> '已作废' 
	AND IFNULL(ld_paymentplan.amount, 0) - ifnull(
		ld_paymentplan.actualamount,
		0
	) >= 0 ".sprintf($where,'ld_paymentplan')."  );";
        $adb->query($SQL);
      //echo $SQL."</br>";
       $SQL="CREATE TEMPORARY TABLE
IF NOT EXISTS `temptable5` IGNORE (
	SELECT
		ld_UsersPaymentPlan.last_name AS paymentplan_smownerid,
		ld_UsersPaymentPlan.last_name AS paymentplan_smownerid2,
		ld_group.groupname AS paymentplan_groupname,
		ld_group.groupid as report_wx_groupid,
		ld_UsersPaymentPlan.wx_userid as report_wx_userid,
		ld_accountpaymentplan.accountname AS paymentplan_accountid,
		ld_accountpaymentplan.accountid AS paymentplan_accountid_id,
		ld_invoice.invoicedate AS salesorder_signed_data,
		ld_invoice.`subject` AS paymentplan_salesorderid,
		ld_invoice.invoice_no AS salesorder_salesorder_no,
		ld_invoice.total AS salesorder_hdnGrandTotal,
		ld_invoice.currency_id AS salesorder_curid,
		ld_invoice.conversion_rate AS salesorder_rate,
		ld_invoice.currency_symbol AS salesorder_symbol,
		ld_paymentplan.paymentplan_no AS paymentplan_paymentplan_no,
		ld_paymentplan.plandate AS paymentplan_plandate,
		ld_paymentplan.periodtime AS paymentplan_periodtime,
		ld_paymentplan.amount AS paymentplan_amount,
		ld_paymentplan.currency_id AS paymentplan_curid,
		ld_paymentplan.conversion_rate AS paymentplan_rate,
		ld_paymentplan.currency_symbol AS paymentplan_symbol,
		ifnull(
			ld_paymentplan.actualamount,
			0
		) AS paymentplan_actualamount,
		ld_cashbill.currency_id AS cashbill_curid,
		ld_cashbill.conversion_rate AS cashbill_rate,
		ld_cashbill.currency_symbol AS cashbill_symbol,
		ld_paymentplan.paymentstatus AS paymentplan_paymentstatus,

		IF (
			ld_paymentplan.currency_id > 1,
			IFNULL(ld_paymentplan.amount, 0) / ld_paymentplan.conversion_rate,
			IFNULL(ld_paymentplan.amount, 0)
		) -
		IF (
			ld_cashbill.currency_id > 1,
			ifnull(
				ld_paymentplan.actualamount,
				0
			) / ld_cashbill.conversion_rate,
			ifnull(
				ld_paymentplan.actualamount,
				0
			)
		) AS oftenusereport_paymentplanbalance,
		ld_paymentplan.paymentplanid AS lbl_action
	FROM
		ld_paymentplan
	LEFT JOIN ld_account AS ld_accountpaymentplan ON ld_paymentplan.accountid = ld_accountpaymentplan.accountid
	LEFT JOIN ld_invoice ON ld_invoice.invoiceid = ld_paymentplan.entitytypeid
	INNER JOIN ld_crmentity ON ld_crmentity.crmid = ld_paymentplan.paymentplanid
	INNER JOIN ld_users AS ld_UsersPaymentPlan ON ld_UsersPaymentPlan.id = ld_paymentplan.smownerid
	LEFT JOIN (
		select GROUP_CONCAT(ld_groups.groupname) as groupname,GROUP_CONCAT(ld_groups.groupid) as groupid,ld_users2group.userid from ld_users2group
		LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
		GROUP BY ld_users2group.userid
	) as ld_group on ld_group.userid = ld_paymentplan.smownerid
	LEFT JOIN ld_cashbill2paymentplan ON ld_cashbill2paymentplan.paymentplanid = ld_paymentplan.paymentplanid
	LEFT JOIN (
		SELECT
			*
		FROM
			ld_cashbill
		WHERE
			1
	) AS ld_cashbill ON ld_cashbill.cashbillid = ld_cashbill2paymentplan.CashBillID
	WHERE
		ld_paymentplan.deleted = 0 and ld_paymentplan.entitytype='Invoice'
	AND ifnull(ld_invoice.invoicestatus,'') <> '已作废'
	AND IFNULL(ld_paymentplan.amount, 0) - ifnull(
		ld_paymentplan.actualamount,
		0
	) >= 0 ".sprintf($where,'ld_paymentplan')."  );";
	//echo $SQL;echo '<br><br>';
	 $adb->query($SQL);
       $SQL="CREATE TEMPORARY TABLE
        IF NOT EXISTS `temptable3` IGNORE (
	       SELECT * FROM (SELECT * FROM temptable UNION SELECT * FROM temptable2 UNION SELECT * FROM temptable5) as F1 where F1.oftenusereport_paymentplanbalance <> 0 
    );";
           $adb->query($SQL);
    //  echo $SQL."</br>";
        $SQL="create TEMPORARY table if not exists  temptable1  IGNORE(
        SELECT 
                '".getFixedLabel('SUBTOTAL')."' paymentplan_smownerid,
                concat(paymentplan_smownerid,'小计：') paymentplan_smownerid2,
				'' paymentplan_groupname,
				'' report_wx_groupid,
				'' report_wx_userid,
                '' paymentplan_accountid,'' paymentplan_accountid_id,
                '' salesorder_signed_data,'' paymentplan_salesorderid,
                '' salesorder_salesorder_no,
                sum(salesorder_hdnGrandTotal/IFNULL(salesorder_rate,1))  salesorder_hdnGrandTotal,
                salesorder_curid,salesorder_rate,salesorder_symbol,''  paymentplan_paymentplan_no,null paymentplan_plandate,
                '' paymentplan_periodtime,
                sum(if(paymentplan_curid > 1,IFNULL(paymentplan_amount,0)/paymentplan_rate,
                IFNULL(paymentplan_amount,0))) as paymentplan_amount,
                paymentplan_curid,paymentplan_rate,paymentplan_symbol,
                sum(if(cashbill_curid>1,
                IFNULL(paymentplan_actualamount,0)/cashbill_rate,
                IFNULL(paymentplan_actualamount,0)) ) paymentplan_actualamount,
                cashbill_curid,cashbill_rate,
                cashbill_symbol,
                '' paymentplan_paymentstatus,
                sum( oftenusereport_paymentplanbalance ) oftenusereport_paymentplanbalance ,
                '' lbl_action 
        FROM (
                SELECT 
                	paymentplan_smownerid,
                	paymentplan_smownerid2,
					paymentplan_groupname,
					report_wx_groupid,
					report_wx_userid,
                	paymentplan_accountid,
                	paymentplan_accountid_id,
                	salesorder_signed_data,
                	paymentplan_salesorderid,
                	salesorder_salesorder_no,
                	salesorder_hdnGrandTotal,
                	salesorder_curid,
                	salesorder_rate,
                	salesorder_symbol,
                	paymentplan_paymentplan_no,
                	paymentplan_plandate,
                	paymentplan_periodtime,
                	SUM(paymentplan_amount) AS paymentplan_amount,
                	paymentplan_curid,
                	paymentplan_rate,
                	paymentplan_symbol,
                	SUM(paymentplan_actualamount) AS paymentplan_actualamount,
                	cashbill_curid,
                	cashbill_rate,
                	cashbill_symbol,
                	paymentplan_paymentstatus,
                	SUM(oftenusereport_paymentplanbalance) AS oftenusereport_paymentplanbalance,
                	lbl_action
                FROM temptable3
                GROUP BY salesorder_salesorder_no
            ) AS f44
        GROUP BY paymentplan_smownerid
            );";
        $adb->query($SQL);
      // echo $SQL."</br>";
        $SQL="Create TEMPORARY table if not EXISTS  temptable4 (SELECT * from 
                (
                	select * from `temptable3` UNION select * from temptable1 order by paymentplan_smownerid2,salesorder_signed_data
                ) as temp
                );";
         //echo $SQL."</br>";      
        $adb->query($SQL);
        
        $SQL="select  paymentplan_smownerid,paymentplan_smownerid2, paymentplan_groupname,report_wx_groupid,report_wx_userid,paymentplan_accountid,paymentplan_accountid_id,salesorder_signed_data,paymentplan_salesorderid as oftenusereport_salesorderid,
                 salesorder_salesorder_no, salesorder_hdnGrandTotal as SalesOrder_total, salesorder_curid,salesorder_rate,salesorder_symbol,paymentplan_paymentplan_no, paymentplan_plandate
                ,paymentplan_periodtime, paymentplan_amount,paymentplan_curid,paymentplan_rate,paymentplan_symbol, paymentplan_actualamount,cashbill_curid,cashbill_rate,cashbill_symbol, paymentplan_paymentstatus
                ,  oftenusereport_paymentplanbalance ,lbl_action from `temptable4` UNION
                select '".getFixedLabel('TOTAL')."：' paymentplan_smownerid,'合计：' paymentplan_smownerid2,'' paymentplan_groupname,'' report_wx_groupid,'' report_wx_userid,'' paymentplan_accountid,'' paymentplan_accountid_id,
		'' salesorder_signed_data,
		'' AS oftenusereport_salesorderid,
		'' salesorder_salesorder_no,
		sum(salesorder_hdnGrandTotal) SalesOrder_total,
		''salesorder_curid,
		''salesorder_rate,
		''salesorder_symbol,
		'' paymentplan_paymentplan_no,
		NULL paymentplan_plandate,
		'' paymentplan_periodtime,
		sum(
			IFNULL(paymentplan_amount, 0)
		) AS paymentplan_amount,
		''paymentplan_curid,
		''paymentplan_rate,
		''paymentplan_symbol,
		sum(
			IFNULL(paymentplan_actualamount, 0)
		) paymentplan_actualamount,
		''cashbill_curid,
		''cashbill_rate,
		''cashbill_symbol,
		'' paymentplan_paymentstatus,
		sum(
			oftenusereport_paymentplanbalance
		) oftenusereport_paymentplanbalance,
		''
	FROM
		`temptable1`;
                ";
       //echo $SQL."</br>";
        return $SQL;
    }
    
    //应收款统计表_按合同统计
    //Edit by luyx 2016-11-04
        //0025643：“应收金额”和“应收款余额”显示错误 。
    static function getCashBillSum_SalesOrder($where,$whereServiceContracts,$wherePaymentBalance)
    {
        //echo $wherePaymentBalance;
        global $adb;
            $SQL="CREATE TEMPORARY TABLE
            IF NOT EXISTS temptable6 IGNORE (
	           SELECT DISTINCT
        DISTINCT ld_userssalesorder.last_name AS salesorder_smownerid,
		ld_userssalesorder.last_name AS salesorder_smownerid2,
		ld_group.groupname AS salesorder_groupname,
		ld_group.groupid AS report_wx_groupid,
		ld_userssalesorder.wx_userid as report_wx_userid,
		ld_salesorder.salesorder_no AS salesorder_salesOrder_No,
		ld_salesorder.signed_data AS SalesOrder_signed_data,
		ld_salesorder.createdtime AS SalesOrder_CreatedTime,
		ld_salesorder. SUBJECT AS SalesOrder_Subject,
		ld_accountsalesorder.accountname AS SalesOrder_accountid,
        ld_accountsalesorder.accountid AS SalesOrder_accountid_id,
		ld_salesorder.sostatus AS 'SalesOrder_sostatus',
		ld_salesorder.total AS 'SalesOrder_Total',
        ld_salesorder.currency_id AS SalesOrder_Curid,
		ld_salesorder.conversion_rate AS SalesOrder_Rate,
		ld_salesorder.currency_symbol AS SalesOrder_Symbol,
        ld_salesorder.salesorderid as id,
		concat(ld_salesorder.salesorderid,'C') AS LBL_ACTION
        FROM
		ld_salesorder
	LEFT JOIN ld_salesorderdetail AS ld_inventoryproductrelSalesOrder ON ld_salesorder.salesorderid = ld_inventoryproductrelSalesOrder.id
	LEFT JOIN ld_products AS ld_productsSalesOrder ON ld_productsSalesOrder.productid = ld_inventoryproductrelSalesOrder.productid
	LEFT JOIN ld_account AS ld_accountsalesorder ON ld_accountsalesorder.accountid = ld_salesorder.accountid
	LEFT JOIN ld_users AS ld_userssalesorder ON ld_userssalesorder.id = ld_salesorder.smownerid
	LEFT JOIN ld_users ON ld_users.id = ld_salesorder.smownerid
	LEFT JOIN (
		select GROUP_CONCAT(ld_groups.groupname) as groupname,GROUP_CONCAT(ld_groups.groupid) as groupid,ld_users2group.userid from ld_users2group
		LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
		GROUP BY ld_users2group.userid
	) as ld_group on ld_group.userid = ld_salesorder.smownerid
	WHERE
		ld_salesorder.salesorderid > 0
	       AND ifnull(ld_salesorder.sostatus,'') <> '已作废' and  ld_salesorder.approvestatus != '已拒绝' 
	       AND ld_salesorder.deleted = 0 ".str_replace('%s', 'ld_salesorder', $where).
            " ORDER BY
		      salesorder_smownerid ASC,
		      SalesOrder_CreatedTime ASC
            );";
            $adb->query($SQL);
       //echo $SQL.'<br><br>';

    $SQL="CREATE TEMPORARY TABLE
            IF NOT EXISTS temptable5 IGNORE (
	          SELECT DISTINCT
		DISTINCT ld_userssalesorder.last_name AS salesorder_smownerid,
		ld_userssalesorder.last_name AS salesorder_smownerid2,
		ld_group.groupname AS salesorder_groupname,
		ld_group.groupid AS report_wx_groupid,
		ld_userssalesorder.wx_userid as report_wx_userid,
		ld_servicecontracts.contract_no AS salesorder_salesOrder_No,
		ld_servicecontracts.due_date AS SalesOrder_signed_data,
		ld_servicecontracts.createdtime AS SalesOrder_CreatedTime,
		ld_servicecontracts. SUBJECT AS SalesOrder_Subject,
		ld_accountsalesorder.accountname AS SalesOrder_accountid,
        ld_accountsalesorder.accountid AS SalesOrder_accountid_id,
		ld_servicecontracts.contract_status AS 'SalesOrder_sostatus',
		ld_servicecontracts.total AS 'SalesOrder_Total',
        ld_servicecontracts.currency_id AS SalesOrder_Curid,
		ld_servicecontracts.conversion_rate AS SalesOrder_Rate,
		ld_servicecontracts.currency_symbol AS SalesOrder_Symbol,
        ld_servicecontracts.servicecontractsid as id,
		concat(ld_servicecontracts.servicecontractsid,'S') AS LBL_ACTION
	FROM
		ld_servicecontracts
	       LEFT JOIN ld_servicecontractsdetail AS ld_inventoryproductrelsalesorder ON ld_servicecontracts.servicecontractsid = ld_inventoryproductrelsalesorder.id
	LEFT JOIN ld_products AS ld_productssalesorder ON ld_productssalesorder.productid = ld_inventoryproductrelsalesorder.productid
	LEFT JOIN ld_account AS ld_accountsalesorder ON ld_accountsalesorder.accountid = ld_servicecontracts.accountid
	LEFT JOIN ld_users AS ld_userssalesorder ON ld_userssalesorder.id = ld_servicecontracts.smownerid
	LEFT JOIN ld_users ON ld_users.id = ld_servicecontracts.smownerid
	LEFT JOIN (
		select GROUP_CONCAT(ld_groups.groupname) as groupname,GROUP_CONCAT(ld_groups.groupid) as groupid,ld_users2group.userid from ld_users2group
		LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
		GROUP BY ld_users2group.userid
	) as ld_group on ld_group.userid = ld_servicecontracts.smownerid
	WHERE
	 ld_servicecontracts.deleted = 0
	AND	ld_servicecontracts.servicecontractsid > 0
	AND ld_servicecontracts.contract_status <> '已作废' and  ld_servicecontracts.approvestatus != '已拒绝' 
	       AND ld_servicecontracts.due_date and ld_servicecontracts.deleted = 0 ".str_replace('%s', 'ld_servicecontracts', $whereServiceContracts).
                        " ORDER BY
		      salesorder_smownerid ASC,
		      SalesOrder_CreatedTime ASC
            );";
            $adb->query($SQL);
           // echo $SQL.'<br><br>';
             $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable IGNORE (
                SELECT * FROM (SELECT * FROM temptable5 UNION SELECT * FROM temptable6) as f2
            );";
            $adb->query($SQL);
            // echo $SQL.'<br><br>';
            //editor:gyq_20190905 reason:salesorderid缺少表名前缀导致SQL报错  2019/9/5 16:09
            $SQL="CREATE TEMPORARY TABLE IF NOT EXISTS temptable1 IGNORE (
                    SELECT
                    	*
                    FROM (
                    	SELECT
                    		ld_salesorder.salesorderid,
                    		received_amount AS total,
                            receivable_balance
                    	FROM
                    		ld_salesorder
						LEFT JOIN ld_account AS ld_accountsalesorder ON ld_accountsalesorder.accountid = ld_salesorder.accountid
                    	WHERE
                    		ld_salesorder.deleted = 0 AND ifnull(ld_salesorder.sostatus,'') <> '已作废' and  ld_salesorder.approvestatus != '已拒绝' 
	       AND ld_salesorder.deleted = 0 ".str_replace('%s', 'ld_salesorder', $where)."
                    	UNION ALL
                    		SELECT
                    			ld_servicecontracts.servicecontractsid AS salesorderid,
                    			received_amount AS total,
                                receivable_balance
                    		FROM
                    			ld_servicecontracts
							LEFT JOIN ld_account AS ld_accountsalesorder ON ld_accountsalesorder.accountid = ld_servicecontracts.accountid
                    		WHERE
                    			ld_servicecontracts.deleted = 0 AND	ld_servicecontracts.servicecontractsid > 0
	AND ld_servicecontracts.contract_status <> '已作废' and  ld_servicecontracts.approvestatus != '已拒绝' 
	       AND ld_servicecontracts.due_date and ld_servicecontracts.deleted = 0 ".str_replace('%s', 'ld_servicecontracts', $whereServiceContracts).") a
                    );";
            $adb->query($SQL);
           // echo $SQL.'<br><br>';
            
            $SQL="Create TEMPORARY table IF NOT EXISTS temptable2 ignore( 	SELECT
            		salesorder_smownerid,
            		salesorder_smownerid2,
					salesorder_groupname,
					report_wx_groupid,
					report_wx_userid,
            		SalesOrder_Subject,
            		SalesOrder_SalesOrder_No,
            		SalesOrder_Accountid,
                    SalesOrder_Accountid_id,
            		SalesOrder_sostatus,
            		SalesOrder_signed_data,
            		SalesOrder_CreatedTime,
            		SalesOrder_Total AS SalesOrder_Total,
                    SalesOrder_Curid,
                    SalesOrder_Rate,
                    SalesOrder_Symbol,
            		IFNULL(temptable1.total, 0) AS oftenusereport_CashBillamount,
            		 IFNULL(temptable1.receivable_balance, 0) AS oftenusereport_PaymentBalance,
            		LBL_ACTION
            	FROM
            		temptable
            	LEFT JOIN temptable1 ON temptable.id = temptable1.salesorderid
            	GROUP BY
            		salesorder_smownerid,
            		SalesOrder_Subject,
            		SalesOrder_SalesOrder_No,
            		SalesOrder_Accountid,
                    SalesOrder_Accountid_id,
            		SalesOrder_sostatus,
            		SalesOrder_CreatedTime,
            		SalesOrder_Total,
                    SalesOrder_Curid,
                    SalesOrder_Rate,
                    SalesOrder_Symbol
                $wherePaymentBalance);
                    ";
            $adb->query($SQL);
            //echo $SQL.'<br><br>';
            $SQL="Create TEMPORARY table IF NOT EXISTS temptable3 ignore( SELECT '".getFixedLabel('SUBTOTAL')."' salesorder_smownerid,concat(salesorder_smownerid,' :小计') salesorder_smownerid2,'' salesorder_groupname,'' report_wx_groupid,'' report_wx_userid, '' SalesOrder_Subject,'' SalesOrder_SalesOrder_No,'' SalesOrder_Accountid,'' SalesOrder_Accountid_id,'' SalesOrder_sostatus,
                    null SalesOrder_signed_data,null SalesOrder_CreatedTime, 
                    sum(if(SalesOrder_Curid > 1,SalesOrder_Total/SalesOrder_Rate,SalesOrder_Total)) SalesOrder_Total,
                    SalesOrder_Curid,SalesOrder_Rate,SalesOrder_Symbol,
                    sum(if(SalesOrder_Curid > 1,oftenusereport_CashBillamount/SalesOrder_Rate,oftenusereport_CashBillamount)) oftenusereport_CashBillamount
                    ,sum(if(SalesOrder_Curid > 1,oftenusereport_PaymentBalance/SalesOrder_Rate,oftenusereport_PaymentBalance)) oftenusereport_PaymentBalance,
                    null LBL_ACTION FROM temptable2 
                    group by salesorder_smownerid );";
            $adb->query($SQL);
            //echo $SQL.'<br><br>';
            $SQL=" create TEMPORARY table IF NOT EXISTS temptable4 ignore( select * from (select * from temptable2 union select * from temptable3 order by salesorder_smownerid2,SalesOrder_signed_data) as temp);";
            $adb->query($SQL);
            //echo $SQL.'<br><br>';
            $SQL=" select salesorder_smownerid,salesorder_smownerid2,salesorder_groupname,report_wx_groupid,report_wx_userid,SalesOrder_SalesOrder_No,SalesOrder_signed_data,SalesOrder_CreatedTime,SalesOrder_Subject,SalesOrder_Accountid,SalesOrder_Accountid_id,
            SalesOrder_sostatus, SalesOrder_Total ,SalesOrder_Curid,SalesOrder_Rate,SalesOrder_Symbol ,
            oftenusereport_CashBillamount ,oftenusereport_PaymentBalance,LBL_ACTION from temptable4 union 
            select '".getFixedLabel('TOTAL')."','合计','','','','','','','','','','',sum(if(SalesOrder_Curid > 1,SalesOrder_Total/SalesOrder_Rate,SalesOrder_Total)) SalesOrder_Total,'','','¥',
          sum(if(SalesOrder_Curid > 1,oftenusereport_CashBillamount/SalesOrder_Rate,oftenusereport_CashBillamount)) oftenusereport_CashBillamount
                    ,sum(if(SalesOrder_Curid > 1,oftenusereport_PaymentBalance/SalesOrder_Rate,oftenusereport_PaymentBalance)) oftenusereport_PaymentBalance,'' 
            from temptable2;";
            // echo $SQL.'<br><br>';
            // exit();
            return $SQL;
    }
	 //应收款统计表_按出库统计
    static function getCashBillSum_Outboundorder($where,$whereServiceContracts,$wherePaymentBalance)
    {
        //echo $wherePaymentBalance;
        global $adb;
            $SQL="CREATE TEMPORARY TABLE
            IF NOT EXISTS temptable6 IGNORE (
			SELECT DISTINCT
        DISTINCT ld_usersOutboundOrder.last_name AS OutboundOrder_smownerid,
		ld_usersOutboundOrder.last_name AS OutboundOrder_smownerid2,
		ld_group.groupname AS OutboundOrder_groupname,
		ld_group.groupid AS report_wx_groupid,
		ld_usersOutboundOrder.wx_userid AS report_wx_userid,
		ld_outboundorder.out_no AS OutboundOrder_out_no,
		ld_outboundorder.outdate AS OutboundOrder_outdate,
		ld_outboundorder.createdtime AS OutboundOrder_CreatedTime,
		ld_accountoutboundorder.accountname AS OutboundOrder_accountid,
        ld_accountoutboundorder.accountid AS OutboundOrder_accountid_id,
		ld_outboundorder.presence AS 'OutboundOrder_presence',
		ld_outboundorder.total AS 'OutboundOrder_Total',
        ld_outboundorder.currency_id AS OutboundOrder_Curid,
		ld_outboundorder.conversion_rate AS OutboundOrder_Rate,
		ld_outboundorder.currency_symbol AS OutboundOrder_Symbol,
        ld_outboundorder.out_id as id,
		concat(ld_outboundorder.out_id,'C') AS LBL_ACTION
        FROM
		ld_outboundorder
	LEFT JOIN ld_outboundorderdetail AS ld_inventoryproductrelSalesOrder ON ld_outboundorder.out_id = ld_inventoryproductrelSalesOrder.id
	LEFT JOIN ld_products AS ld_productsSalesOrder ON ld_productsSalesOrder.productid = ld_inventoryproductrelSalesOrder.productid
	LEFT JOIN ld_account AS ld_accountoutboundorder ON ld_accountoutboundorder.accountid = ld_outboundorder.accountid
	LEFT JOIN ld_users AS ld_usersOutboundOrder ON ld_usersOutboundOrder.id = ld_outboundorder.smownerid
	LEFT JOIN ld_users ON ld_users.id = ld_outboundorder.smownerid
	LEFT JOIN (
		select GROUP_CONCAT(ld_groups.groupname) as groupname,GROUP_CONCAT(ld_groups.groupid) as groupid,ld_users2group.userid from ld_users2group
		LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
		GROUP BY ld_users2group.userid
	) as ld_group on ld_group.userid = ld_outboundorder.smownerid
	WHERE
		ld_outboundorder.out_id > 0
	       AND ld_outboundorder.approvestatus != '已拒绝' 
	       AND ld_outboundorder.deleted = 0 ".str_replace('%s', 'ld_outboundorder', $where).
            " ORDER BY
		      OutboundOrder_smownerid ASC,
		      OutboundOrder_CreatedTime ASC
            );";
            $adb->query($SQL);
       // echo $SQL.'<br><br>';die;
             $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable IGNORE (
                SELECT * FROM (SELECT * FROM temptable6) as f2
            );";
            $adb->query($SQL);
           // echo $SQL.'<br><br>';
            
            $SQL="CREATE TEMPORARY TABLE IF NOT EXISTS temptable1 IGNORE (
                    SELECT
                    	*
                    FROM (
                    	SELECT
                    		out_id,
                    		received_amount AS total
                    	FROM
                    		ld_outboundorder
						LEFT JOIN ld_account AS ld_accountoutboundorder ON ld_accountoutboundorder.accountid = ld_outboundorder.accountid
                    	WHERE
                    		ld_outboundorder.deleted = 0 and ld_outboundorder.approvestatus != '已拒绝' 
	       AND ld_outboundorder.deleted = 0 ".str_replace('%s', 'ld_outboundorder', $where).")a);";
            $adb->query($SQL);
            //echo $SQL.'<br><br>';
            
            $SQL="Create TEMPORARY table IF NOT EXISTS temptable2 ignore( 	SELECT
            		OutboundOrder_smownerid,
            		OutboundOrder_smownerid2,
					OutboundOrder_groupname,
					report_wx_groupid,
					report_wx_userid,
            		OutboundOrder_out_no,
            		OutboundOrder_accountid,
                    OutboundOrder_accountid_id,
            		OutboundOrder_presence,
            		OutboundOrder_outdate,
            		OutboundOrder_CreatedTime,
            		OutboundOrder_Total AS OutboundOrder_Total,
                    OutboundOrder_Curid,
                    OutboundOrder_Rate,
                    OutboundOrder_Symbol,
            		IFNULL(temptable1.total, 0) AS oftenusereport_CashBillamount,
            		(
                    if(OutboundOrder_Curid > 1,IFNULL(OutboundOrder_Total, 0)/OutboundOrder_Rate,IFNULL(OutboundOrder_Total, 0))
            			 - IFNULL(temptable1.total, 0)
            		) AS oftenusereport_PaymentBalance,
            		LBL_ACTION
            	FROM
            		temptable
            	LEFT JOIN temptable1 ON temptable.id = temptable1.out_id
            	GROUP BY
            		OutboundOrder_smownerid,
            		OutboundOrder_out_no,
            		OutboundOrder_accountid,
                    OutboundOrder_accountid_id,
            		OutboundOrder_presence,
            		OutboundOrder_CreatedTime,
            		OutboundOrder_Total,
                    OutboundOrder_Curid,
                    OutboundOrder_Rate,
                    OutboundOrder_Symbol
                $wherePaymentBalance);
                    ";
            $adb->query($SQL);
          //  echo $SQL.'<br><br>';
            $SQL="Create TEMPORARY table IF NOT EXISTS temptable3 ignore( SELECT '".getFixedLabel('SUBTOTAL')."' OutboundOrder_smownerid,concat(OutboundOrder_smownerid,' :小计') OutboundOrder_smownerid2,'' OutboundOrder_groupname, '' report_wx_groupid,'' report_wx_userid,'' OutboundOrder_out_no,'' OutboundOrder_accountid,'' OutboundOrder_accountid_id,'' OutboundOrder_presence,
                    null OutboundOrder_outdate,null OutboundOrder_CreatedTime, sum(if(OutboundOrder_Curid > 1,OutboundOrder_Total/OutboundOrder_Rate,OutboundOrder_Total)) OutboundOrder_Total,OutboundOrder_Curid,OutboundOrder_Rate,OutboundOrder_Symbol,sum(oftenusereport_CashBillamount) oftenusereport_CashBillamount,sum(oftenusereport_PaymentBalance) oftenusereport_PaymentBalance,
                    null LBL_ACTION FROM temptable2 
                    group by OutboundOrder_smownerid );";
            $adb->query($SQL);
           // echo $SQL.'<br><br>';
            $SQL=" create TEMPORARY table IF NOT EXISTS temptable4 ignore( select * from (select * from temptable2 union select * from temptable3 order by OutboundOrder_smownerid2,OutboundOrder_outdate) as temp);";
            $adb->query($SQL);
           // echo $SQL.'<br><br>';
            $SQL=" select OutboundOrder_smownerid,OutboundOrder_smownerid2,OutboundOrder_groupname,report_wx_groupid,
					report_wx_userid,OutboundOrder_out_no,OutboundOrder_outdate,OutboundOrder_CreatedTime,OutboundOrder_accountid,OutboundOrder_accountid_id,
            OutboundOrder_presence, OutboundOrder_Total ,OutboundOrder_Curid,OutboundOrder_Rate,OutboundOrder_Symbol,oftenusereport_PaymentBalance ,
            oftenusereport_CashBillamount ,LBL_ACTION from temptable4 union 
            select '".getFixedLabel('TOTAL')."','合计','','','','','','','','','',sum(if(OutboundOrder_Curid > 1,OutboundOrder_Total/OutboundOrder_Rate,OutboundOrder_Total)) OutboundOrder_Total,'','','¥',
           sum(oftenusereport_PaymentBalance) oftenusereport_PaymentBalance,sum(oftenusereport_CashBillamount) oftenusereport_CashBillamount,'' 
            from temptable2;";
            //echo $SQL.'<br><br>';
            return $SQL;
    }
    //销售行为考核表
    static  function getSalesSumSequence($zuserids)
    {
		 global $adb;
		//已收金额计算时是否统计未审核的收款单
		$focus = CRMEntity::getInstance('CashBill');
		$checkoutstatuswhere = $focus->get_CashBillCheckoutstatusWhere();
        //$userids=$_REQUEST['receiverid'];
        $startdate=$_REQUEST['startmonth'].' 00:00:00';
        $enddate=$_REQUEST['endmonth'].' 23:59:59';
        $smownerwhere='';
        $smcreatorwhere='';
        
        if(isset($userids)&&$userids!="") 
        {
            $smownerwhere="and smownerid in(".$userids." ) ";
            $smcreatorwhere=" and smownerid in (".$userids." ) ";
            $smuserwhere=' where  ld_users.id in ('.$userids.' ) ';
            $signinwhere =" and userid in (".$userids." )";
        }
        else
        {

           // $smuserwhere=' ';
            $smownerwhere="and smownerid in(".$zuserids." ) ";
            $smcreatorwhere=" and smownerid in (".$zuserids." ) ";
            $smuserwhere=' where  ld_users.id in ('.$zuserids.' ) ';
            $signinwhere =" and userid in (".$zuserids." )";

            
        }
         $SQL="select ld_users.last_name as oftenusereport_last_name,
                 ld_users.wx_userid as oftenusereport_wx_userid,
                ld_group.groupname as oftenusereport_groupname,
                ld_group.groupid as oftenusereport_groupid,
                  IFNULL(singintable.singincount,0) as oftenusereport_singincount
                 ,IFNULL(accounttable.accountcount,0) as oftenusereport_accountcount
                ,IFNULL(potentailtable.potentailcount,0) as oftenusereport_potentialcount
                ,IFNULL(contacttable.contactcount,0) as oftenusereport_contactcount
                ,IFNULL(calendartable.Calendarcount,0) as oftenusereport_calendarcount
                ,IFNULL(contactrecordtable.ContactRecordscount,0) as oftenusereport_ContactRecordscount
                ,IFNULL(helpdesktable.HelpDeskCount,0) as oftenusereport_HelpDeskCount
                ,IFNULL(cashbilltable.CashBilltotal,0) as oftenusereport_CashBilltotal
                ,IFNULL(cashbilltable.CashBillCount,0) as oftenusereport_Cashbillcount
                ,IFNULL(salesordertable.salesordertotal,0) as oftenusereport_salesordertotal
                ,IFNULL(salesordertable_signed_num.salesordercount,0) as oftenusereport_salesordercount
                ,IFNULL(expensetable.expensetotal,0) as oftenusereport_expensetotal
                ,IFNULL(servicecontractstable.servicecontractstotal,0) as oftenusereport_servicecontractstotal
                ,IFNULL(servicecontractstable_due_num.servicecontractscount,0) as oftenusereport_servicecontractscount
				,IFNULL(invoicetable.invoicetotal,0) as oftenusereport_invoicetotal
				,IFNULL(outboundordertable.outboundordertotal,0) as oftenusereport_outboundordertotal
                from ld_users ";
         //外勤签到次数       
         $SQL .="  left join 
                (select  count(1) as singincount,userid as smownerid from ld_singin where  deleted=0   ".$signinwhere." and createdtime between '".$startdate."' and '".$enddate."' GROUP BY userid) as singintable 
                on  singintable.smownerid=ld_users.id ";     
		 $SQL .="  LEFT JOIN (
						select GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid) as groupname,ld_users2group.userid
                          ,GROUP_CONCAT(ld_groups.groupid order by ld_groups.groupid ) as groupid   from ld_users2group
						LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
						GROUP BY ld_users2group.userid
					) as ld_group on ld_group.userid = ld_users.id ";     
        $SQL .="  left join 
                (select  count(1) as accountcount,smownerid from ld_account where  deleted=0  ".$smcreatorwhere." and createdtime between '".$startdate."' and '".$enddate."' and approvestatus<>'已拒绝' GROUP BY smownerid) as accounttable 
                on  accounttable.smownerid=ld_users.id ";
                
        $SQL .=" left join (select  count(1) as potentailcount,smownerid from ld_potential where deleted=0 ".$smcreatorwhere." and createdtime between '".$startdate."' and '".$enddate."' and approvestatus<>'已拒绝' GROUP BY smownerid ) as potentailtable
                on potentailtable.smownerid=ld_users.id ";
        $SQL .=" left join (select count(1) as contactcount,smownerid from ld_contactdetails where deleted=0 ".$smcreatorwhere." and createdtime between '".$startdate."' and '".$enddate."' and approvestatus<>'已拒绝' group by smownerid) contacttable
                on contacttable.smownerid=ld_users.id";
                
        $SQL .=" left join (select count(1) as Calendarcount,smownerid from ld_activity where deleted=0 ".$smcreatorwhere." and createdtime between '".$startdate."' and '".$enddate."' and  activitytype <>'Emails' group by smownerid) calendartable
                on calendartable.smownerid=ld_users.id";
                
        $SQL .=" LEFT JOIN (select count(1) as ContactRecordscount,smownerid from ld_contactrecords where deleted=0 ".$smcreatorwhere." and createdtime between '".$startdate."' and '".$enddate."' and approvestatus<>'已拒绝' group by smownerid)contactrecordtable
                on contactrecordtable.smownerid=ld_users.id ";
                
        $SQL .="  LEFT JOIN (select count(1) as HelpDeskCount,smownerid from ld_troubletickets where deleted=0 ".$smownerwhere." and createdtime between '".$startdate."' and '".$enddate."' and approvestatus<>'已拒绝' and approvestatus<>'已拒绝' GROUP BY smownerid) helpdesktable
                on helpdesktable.smownerid=ld_users.id ";
                
       $SQL .="  LEFT JOIN (select sum(if(ld_cashbill.currency_id > 1,IFNULL(total,0)/ld_cashbill.conversion_rate,IFNULL(total,0))) as CashBilltotal,smownerid, COUNT(1) as CashBillCount from ld_cashbill where deleted=0 ".$smownerwhere." and cashbilldate between '".$startdate."' and '".$enddate."'".$checkoutstatuswhere." and approvestatus<>'已拒绝' group by smownerid) cashbilltable
                on cashbilltable.smownerid=ld_users.id ";
       
	   //合同金额
       $SQL .="  left JOIN (select sum(if(ld_salesorder.currency_id > 1,IFNULL(total,0)/ld_salesorder.conversion_rate,IFNULL(total,0))) as salesordertotal,smownerid  from ld_salesorder  where deleted=0 and sostatus<>'已作废' and total <> 0 ".$smownerwhere." and signed_data between '".$startdate."' and '".$enddate."' and approvestatus<>'已拒绝' group by smownerid) salesordertable
                on salesordertable.smownerid=ld_users.id ";
	   //合同 - 签约数量
	    $SQL .="  left JOIN (select count(1) as salesordercount,smownerid  from ld_salesorder  where deleted=0 and sostatus<>'已作废' ".$smownerwhere." and signed_data between '".$startdate."' and '".$enddate."' and approvestatus<>'已拒绝' group by smownerid) salesordertable_signed_num
                on salesordertable_signed_num.smownerid=ld_users.id ";
                
       $SQL .=" LEFT JOIN(SELECT SUM(if(ld_expense.currency_id > 1,IFNULL(total,0)/ld_expense.conversion_rate,IFNULL(total,0))) as expensetotal ,smownerid from ld_expense  where deleted=0 ".$smownerwhere." and expensedate between '".$startdate."' and '".$enddate."' and approvestatus<>'已拒绝' group by smownerid )  expensetable
                on expensetable.smownerid=ld_users.id ";
       //服务金额
       $SQL .=" left JOIN (select sum(if(ld_servicecontracts.currency_id > 1,IFNULL(total,0)/ld_servicecontracts.conversion_rate,IFNULL(total,0))) as servicecontractstotal,smownerid from ld_servicecontracts where deleted=0 and total <> 0 and contract_status<>'已作废' ".$smownerwhere." and due_date between '".$startdate."' and '".$enddate."' and approvestatus<>'已拒绝' group by smownerid) servicecontractstable on servicecontractstable.smownerid=ld_users.id ";
	   //服务 - 签约数量
	   $SQL .=" left JOIN (select count(1) as servicecontractscount,smownerid from ld_servicecontracts where deleted=0 and contract_status<>'已作废' ".$smownerwhere." and due_date between '".$startdate."' and '".$enddate."' and approvestatus<>'已拒绝' group by smownerid) servicecontractstable_due_num on servicecontractstable_due_num.smownerid=ld_users.id ";
	   //销售发票金额
	   $SQL .=" left JOIN (select sum(if(ld_invoice.currency_id > 1,IFNULL(total,0)/ld_invoice.conversion_rate,IFNULL(total,0))) as invoicetotal,smownerid from ld_invoice where deleted=0 and total <> 0  ".$smownerwhere." and invoicedate between '".$startdate."' and '".$enddate."' and approvestatus<>'已拒绝' group by smownerid) invoicetable on invoicetable.smownerid=ld_users.id ";
	   //出库单金额
	   $approvestatus = '';
	   $deployarray=getSys_deploy(48);//获取出库单或入库单更新库存流水记录触发点 0：审核 1：保存
	   if($deployarray['deploy_value']== 0){
			$approvestatus = ' and approvestatus = "已批准"';
	   }
	   $SQL .=" left JOIN (select sum(if(ld_outboundorder.currency_id > 1,IFNULL(total,0)/ld_outboundorder.conversion_rate,IFNULL(total,0))) as outboundordertotal,smownerid from ld_outboundorder where deleted=0 and total <> 0 ".$smownerwhere." and outdate between '".$startdate."' and '".$enddate."' $approvestatus group by smownerid) outboundordertable on outboundordertable.smownerid=ld_users.id ";
      // echo $SQL.$smuserwhere;
      $SQL.= $smuserwhere;
  // dump($SQL);
	 // echo $SQL .';';
      $SSQL = "Create TEMPORARY table IF NOT EXISTS temptable3 ignore(".$SQL.");";
    //     echo $SSQL ;
      $adb->query($SSQL);

      $SQL="Create TEMPORARY table IF NOT EXISTS temptable2 ( select '".getFixedLabel('TOTAL')."' oftenusereport_last_name,oftenusereport_wx_userid,'' as oftenusereport_groupname,oftenusereport_groupid,sum(oftenusereport_singincount) as oftenusereport_singincount,sum(oftenusereport_accountcount) as oftenusereport_accountcount ,sum(oftenusereport_potentialcount) as oftenusereport_potentialcount ,sum(oftenusereport_contactcount) as oftenusereport_contactcount ,sum(oftenusereport_calendarcount) as oftenusereport_calendarcount ,sum(oftenusereport_ContactRecordscount) as oftenusereport_ContactRecordscount ,sum(oftenusereport_HelpDeskCount) as oftenusereport_HelpDeskCount ,sum(oftenusereport_CashBilltotal) as oftenusereport_CashBilltotal ,sum(oftenusereport_Cashbillcount) as oftenusereport_Cashbillcount ,sum(oftenusereport_salesordertotal) as oftenusereport_salesordertotal ,sum(oftenusereport_salesordercount) as oftenusereport_salesordercount ,sum(oftenusereport_expensetotal) as oftenusereport_expensetotal,sum(oftenusereport_servicecontractstotal) as oftenusereport_servicecontractstotal,sum(oftenusereport_servicecontractscount) as oftenusereport_servicecontractscount,sum(oftenusereport_invoicetotal) as oftenusereport_invoicetotal,sum(oftenusereport_outboundordertotal) as oftenusereport_outboundordertotal from temptable3);";            
  //  echo $SQL;
     $adb->query($SQL);
     $SQL="select * from temptable3 union select * from  temptable2 ";
     if(isset($_REQUEST['sorder']))
        {
            $sorder=$_REQUEST['sorder'];
            $ordertype=$_REQUEST['ordertype'];
            //edit:can 2020-09-0142561: （http://51mis.com.cn/XS/levson/ [^]）客户问题（利物盛），常用报表>销售业绩考核表：点击表头显示列“蓝色字段”，底部“合计”会显示到表格中间（截图红框所示）
            $SQL='select * from (select * from temptable3  ';
            $SQL.=" having 1 order by oftenusereport_$sorder $ordertype ) as tmp_tmp_table   union select * from  temptable2 ";
           
        }
      // echo $SQL ;
        return $SQL;

    }
    
    static function getContractnumber($where,$whereServiceContracts)
    {
        global $adb;
        
        $extraSql = new cls_MainReportSQL();
         $SQL="CREATE TEMPORARY TABLE
        IF NOT EXISTS temptable100 (
	       salesorder_ordernum MEDIUMINT NOT NULL AUTO_INCREMENT,
	       PRIMARY KEY (salesorder_ordernum)
        )(
	       ".$extraSql->Contractnumber($where,$whereServiceContracts)."
        );      ";

         $adb->query($SQL);
         $SQL='select * from temptable100';
         return $SQL;
    }
    static function getCashBillamount($where){
        global $adb;
        $extraSql = new cls_MainReportSQL();
        $SQL = 'CREATE TEMPORARY TABLE
        IF NOT EXISTS temptable1 (
	       CashBill_ordernum MEDIUMINT NOT NULL AUTO_INCREMENT,
	       PRIMARY KEY (CashBill_ordernum)
        )('.$extraSql->CashBillamount($where).');';
        //print_r($SQL);
        $adb->query($SQL);
        //echo $SQL;
        $SQL="select * from temptable1 order by cnt desc ;";                
        return $SQL;
    }
    static function getContractamount($where,$whereServiceContracts)
    {
        global $adb;
        $extraSql = new cls_MainReportSQL();
        $SQL="CREATE TEMPORARY TABLE
        IF NOT EXISTS temptable (
	       salesorder_ordernum MEDIUMINT NOT NULL AUTO_INCREMENT,
	       PRIMARY KEY (salesorder_ordernum)
        )(
	      ".$extraSql->Contractamount($where,$whereServiceContracts).");";
        $adb->query($SQL);
        //echo $SQL;
        $SQL="select * from temptable order by cnt desc ;";  
        return $SQL;
    }
	static function getInvoiceamount($where)
    {
        global $adb;
        $extraSql = new cls_MainReportSQL();
        $SQL="CREATE TEMPORARY TABLE
        IF NOT EXISTS temptable (
	       cntt MEDIUMINT NOT NULL AUTO_INCREMENT,
	       PRIMARY KEY (cntt)
        )(
	      ".$extraSql->Invoiceamount($where).");";
        $adb->query($SQL);
        //echo $SQL;
        $SQL="select * from temptable order by cntt desc ;";  
        return $SQL;
    }
	static function getOutboundOrderamount($where)
    {
        global $adb;
        $extraSql = new cls_MainReportSQL();
        $SQL="CREATE TEMPORARY TABLE
        IF NOT EXISTS temptable (
	       cntt MEDIUMINT NOT NULL AUTO_INCREMENT,
	       PRIMARY KEY (cntt)
        )(
	      ".$extraSql->OutboundOrderamount($where).");";
        $adb->query($SQL);
        //echo $SQL;
        $SQL="select * from temptable order by cntt desc ;";  
        return $SQL;
    }

	
    
    
    // 采购订单跟踪表
    //Edit by luyx 2017-08-23
        //开票余额计算错误，应该直接取采购订单相关字段
    static function getPurchaseOrderTrack($where,$whereapp)
    {   
        
        $newstr = substr($where,0,1);//
        if($newstr =='('){
            $where=' And '.$where;//Liver 将ld_accountcashbill替换为ld_account,为高级查找前面加上and
        }
        global $adb;
        
        $SQL="CREATE TEMPORARY TABLE IF NOT EXISTS temptable2 IGNORE (
        SELECT
        	ld_users.last_name AS purchaseorder_smownerid,
        	ld_users.last_name AS purchaseorder_smownerid2,
			ld_group.groupname AS purchaseorder_groupname,
			ld_users.wx_userid as report_wx_userid,
			ld_group.groupid as report_wx_groupid,
        	ld_purchaseorder.`subject` AS purchaseorder_Subject,
        	ld_purchaseorder.purchaseorder_no AS purchaseorder_purchaseorder_No,
        	ld_purchaseorder.signed_data AS purchaseorder_signed_data,
        	ld_purchaseorder.postatus AS purchaseorder_postatus,
        	ld_purchaseorder.duedate AS purchaseorder_duedate,
        	ld_purchaseorder.createdtime AS purchaseorder_createdtime,
        	ld_purchaseorder.total AS purchaseorder_total,
        	ld_purchaseorder.currency_id AS purchaseorder_curid,
        	ld_purchaseorder.conversion_rate AS purchaseorder_rate,
        	ld_purchaseorder.currency_symbol AS purchaseorder_symbol,
        	ld_purchaseorder.pay_amount/IFNULL(ld_purchaseorder.conversion_rate,1) AS OftenUseReport_SendCashBillamount,
        	ld_purchaseorder.pay_balance/IFNULL(ld_purchaseorder.conversion_rate,1) AS OftenUseReport_SendCashBillbalance,
        	ld_purchaseorder.nothave_invoicetotal/IFNULL(ld_purchaseorder.conversion_rate,1) AS OftenUseReport_InvoiceBalance,
        	ld_purchaseorder.havecashbackamount/IFNULL(ld_purchaseorder.conversion_rate,1) AS purchaseorder_havecashbackamount,
        	ld_purchaseorder.totalcashbackamount/IFNULL(ld_purchaseorder.conversion_rate,1) AS purchaseorder_totalcashbackamount,
        	ld_purchaseorder.balancecashbackamount/IFNULL(ld_purchaseorder.conversion_rate,1) AS purchaseorder_balancecashbackamount,
        	ld_vendor.vendorname AS vendorname,
        	ld_vendor.vendorid AS vendorid,
        	ld_purchaseorder.purchaseorderid AS lbl_action
        FROM ld_purchaseorder
        LEFT JOIN ld_purchaseordercf ON ld_purchaseorder.purchaseorderid = ld_purchaseordercf.purchaseorderid
        LEFT JOIN ld_users ON ld_users.id = ld_purchaseorder.smownerid
		LEFT JOIN (
			select GROUP_CONCAT(ld_groups.groupname) as groupname,GROUP_CONCAT(ld_groups.groupid) as groupid,ld_users2group.userid from ld_users2group
			LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
			GROUP BY ld_users2group.userid
		) as ld_group on ld_group.userid = ld_purchaseorder.smownerid
        LEFT JOIN ld_vendor ON ld_vendor.vendorid = ld_purchaseorder.vendorid
        WHERE ld_purchaseorder.purchaseorderid > 0
            AND ld_purchaseorder.deleted = 0
            AND IFNULL(ld_purchaseorder.postatus,'')<>'已作废'" .str_replace('%s', 'ld_purchaseorder', $where).$whereapp.
            " ORDER BY purchaseorder_smownerid,purchaseorder_signed_data,purchaseorder_createdtime);";
        $resultt=$adb->query($SQL);
       
         

        //采购订单跟踪表小计
        $SQL="CREATE TEMPORARY TABLE IF NOT EXISTS temptable3 IGNORE(
        SELECT 
            '".getFixedLabel('SUBTOTAL')."' purchaseorder_smownerid,
            concat(purchaseorder_smownerid, ' :小计') purchaseorder_smownerid2,
			'' AS purchaseorder_groupname,
			'' report_wx_userid,
			'' report_wx_groupid,
            '' AS purchaseorder_Subject,
            '' AS purchaseorder_purchaseorder_No,
            '' AS purchaseorder_signed_data, 
            '' AS purchaseorder_poStatus,
            NULL AS purchaseorder_duedate, 
            NULL AS purchaseorder_CreatedTime, 
            SUM(purchaseorder_total/IFNULL(purchaseorder_rate,1)) AS purchaseorder_Total,
            '' AS purchaseorder_curid,
            '' AS purchaseorder_rate,
            '' AS purchaseorder_symbol, 
            IFNULL(SUM(OftenUseReport_SendCashBillamount),0) AS OftenUseReport_SendCashBillamount,
            IFNULL(SUM(OftenUseReport_SendCashBillbalance),0) AS OftenUseReport_SendCashBillbalance,
            IFNULL(SUM(OftenUseReport_InvoiceBalance),0) AS OftenUseReport_InvoiceBalance,
            IFNULL(SUM(purchaseorder_havecashbackamount),0) AS purchaseorder_havecashbackamount,
            IFNULL(SUM(purchaseorder_totalcashbackamount),0) AS purchaseorder_totalcashbackamount,
            IFNULL(SUM(purchaseorder_balancecashbackamount),0) AS purchaseorder_balancecashbackamount,
            '' AS vendorname,
            '' AS vendorid, 
            NULL AS LBL_ACTION  
        FROM temptable2 
        GROUP by purchaseorder_smownerid);";
       
        //  echo $SQL.'<br><br>';
        $resultt=$adb->query($SQL);
        
        $SQL="CREATE TEMPORARY TABLE IF NOT EXISTS temptable5 IGNORE ( 
        SELECT 
            * 
        FROM (
            SELECT * FROM temptable2 
            UNION ALL 
            SELECT * FROM temptable3 
            ORDER BY CONVERT(purchaseorder_smownerid2 USING GBK),purchaseorder_signed_data,purchaseorder_createdtime
        ) as temp);";
        //echo $SQL.'<br><br>';
        $resultt=$adb->query($SQL);
      
        // 合同跟踪表最终SQL
         $SQL="SELECT 
            purchaseorder_smownerid,
            purchaseorder_smownerid2,
			purchaseorder_groupname,
			report_wx_userid,
			report_wx_groupid,
            purchaseorder_purchaseorder_No,
            purchaseorder_signed_data,
            purchaseorder_CreatedTime,
            purchaseorder_Subject,
            purchaseorder_postatus,
            purchaseorder_duedate,
            purchaseorder_Total,
            purchaseorder_curid,
            OftenUseReport_SendCashBillbalance,
            OftenUseReport_InvoiceBalance,
            purchaseorder_havecashbackamount,
            purchaseorder_totalcashbackamount,
            purchaseorder_balancecashbackamount,
            purchaseorder_rate,
            purchaseorder_symbol,
            OftenUseReport_SendCashBillamount,
            vendorname as vendors_vendorname,
            vendorid AS vendors_vendorid,
            lbl_action 
         FROM temptable5 
         UNION ALL 
         SELECT 
            '".getFixedLabel('TOTAL')."' , 
            '合计',
			'',
			'',
			'',
            '', 
            '',
            '', 
            '', 
            '', 
            '',
            SUM(purchaseorder_total/IFNULL(purchaseorder_rate,1)) AS purchaseorder_Total,
            '',
            IFNULL(SUM(OftenUseReport_SendCashBillbalance),0) AS OftenUseReport_SendCashBillbalance,
            IFNULL(SUM(OftenUseReport_InvoiceBalance),0) AS OftenUseReport_InvoiceBalance,
            IFNULL(SUM(purchaseorder_havecashbackamount),0) AS purchaseorder_havecashbackamount,
            IFNULL(SUM(purchaseorder_totalcashbackamount),0) AS purchaseorder_totalcashbackamount,
            IFNULL(SUM(purchaseorder_balancecashbackamount),0) AS purchaseorder_balancecashbackamount,
            '',
            '',
            IFNULL(SUM(OftenUseReport_SendCashBillamount),0) AS OftenUseReport_SendCashBillamount,
            '',
            '',
            ''
         FROM temptable2";
        //echo $SQL.'<br><br>';

        return $SQL;   
    }
    
    //应付款统计表_按采购订单统计
    //Edit by luyx 2016-11-04
        //时间查询更改为匹配采购订单的 签约日期
        //0025652：已付金额计算错误的问题
    static function getSendCashBillSum_PurchaseOrder($where)
    {
        //echo $where;
            global $adb;
        
        $newstr = substr($where,0,1);//
        if($newstr =='('){
            $where=' And '.$where;
        }
        
        
            $SQL="CREATE TEMPORARY TABLE IF NOT EXISTS temptable IGNORE (
	       SELECT DISTINCT
		      DISTINCT ld_userspurchaseorder.last_name AS purchaseorder_smownerid,
		      ld_userspurchaseorder.last_name AS purchaseorder_smownerid2,
			  ld_group.groupname AS purchaseorder_groupname,
			  ld_userspurchaseorder.wx_userid as report_wx_userid,
			  ld_group.groupid as report_wx_groupid,
		      ld_purchaseorder.purchaseorder_no AS purchaseorder_purchaseorder_No,
		      ld_purchaseorder.signed_data AS PurchaseOrder_signed_data,
		      ld_purchaseorder.createdtime AS PurchaseOrder_CreatedTime,
		      ld_purchaseorder. SUBJECT AS PurchaseOrder_Subject,
		      ld_vendorpurchaseorder.vendorname AS PurchaseOrder_vendorid,
              ld_vendorpurchaseorder.vendorid AS PurchaseOrder_vendorid_id,
		      ld_purchaseorder.postatus AS 'PurchaseOrder_postatus',
		      ld_purchaseorder.total AS 'PurchaseOrder_Total',
		      ld_purchaseorder.purchaseorderid AS LBL_ACTION,
              ld_purchaseorder.currency_id AS purchaseorder_curid,
		      ld_purchaseorder.conversion_rate AS purchaseorder_rate,
		      ld_purchaseorder.currency_symbol AS purchaseorder_symbol
	       FROM
		      ld_purchaseorder
            INNER JOIN ld_purchaseordercf ON  ld_purchaseordercf.purchaseorderid=ld_purchaseorder.purchaseorderid
	       LEFT JOIN ld_vendor AS ld_vendorpurchaseorder ON ld_vendorpurchaseorder.vendorid = ld_purchaseorder.vendorid
           LEFT JOIN ld_vendor ON ld_vendor.vendorid = ld_purchaseorder.vendorid
	       LEFT JOIN ld_users AS ld_userspurchaseorder ON ld_userspurchaseorder.id = ld_purchaseorder.smownerid
	       LEFT JOIN ld_users ON ld_users.id = ld_purchaseorder.smownerid 
		   LEFT JOIN (
				select GROUP_CONCAT(ld_groups.groupname) as groupname,GROUP_CONCAT(ld_groups.groupid) as groupid,ld_users2group.userid from ld_users2group
				LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
				GROUP BY ld_users2group.userid
			) as ld_group on ld_group.userid = ld_purchaseorder.smownerid
       	    LEFT JOIN ld_purchaseorderdetail ON ld_purchaseorderdetail.id=ld_purchaseorder.purchaseorderid 
           	LEFT JOIN ld_salesorder as ld_salesorderpurchaseorder ON ld_purchaseorderdetail.entitytypeid=ld_salesorderpurchaseorder.salesorderid
	       WHERE
		      ld_purchaseorder.purchaseorderid > 0
	       AND ifnull(ld_purchaseorder.postatus,'') <> '已作废'
	       AND ld_purchaseorder.deleted = 0 ".str_replace('%s', 'ld_purchaseorder', $where).
                        " ORDER BY
		      purchaseorder_smownerid ASC,
		      PurchaseOrder_CreatedTime ASC
        );";
            $adb->query($SQL);
            //echo $SQL.'<br><br>';die;
            
            //Edit by luyx 2016-11-04 已付金额直接取自合同订单
            $SQL="CREATE TEMPORARY TABLE IF NOT EXISTS temptable1 IGNORE (
                    SELECT
                    	purchaseorderid,
                    	currency_id,
                    	conversion_rate,
                    	currency_symbol,
                    	pay_amount/ifnull(conversion_rate,1) as total
                    FROM ld_purchaseorder
                    WHERE deleted=0
                 );";
            $adb->query($SQL);
            //echo $SQL.'<br><br>';
            
            $SQL="Create TEMPORARY table IF NOT EXISTS temptable2 ignore( 
            SELECT purchaseorder_smownerid,purchaseorder_smownerid2,purchaseorder_groupname,report_wx_userid,report_wx_groupid,PurchaseOrder_Subject,PurchaseOrder_PurchaseOrder_No,PurchaseOrder_vendorid,PurchaseOrder_vendorid_id,PurchaseOrder_postatus,PurchaseOrder_signed_data,
            PurchaseOrder_CreatedTime,PurchaseOrder_Total as PurchaseOrder_Total, IFNULL(temptable1.total,0) as oftenusereport_SendCashBillamount, 
            (IFNULL(if(purchaseorder_curid > 1,PurchaseOrder_Total/purchaseorder_rate,PurchaseOrder_Total),0)-IFNULL(temptable1.total,0)) as oftenusereport_SendCashBillBalance, LBL_ACTION,purchaseorder_curid,purchaseorder_rate,purchaseorder_symbol 
            FROM temptable left join temptable1 on LBL_ACTION=temptable1.purchaseorderid 
            group by purchaseorder_smownerid,PurchaseOrder_Subject,PurchaseOrder_PurchaseOrder_No,PurchaseOrder_Vendorid,PurchaseOrder_vendorid_id,PurchaseOrder_postatus,
            PurchaseOrder_CreatedTime,PurchaseOrder_Total having oftenusereport_SendCashBillBalance>=0 ); ";
            $adb->query($SQL);
             //echo $SQL.'<br><br>';
            $SQL="Create TEMPORARY table IF NOT EXISTS temptable3 ignore( 
        SELECT '".getFixedLabel('SUBTOTAL')."' purchaseorder_smownerid,concat(purchaseorder_smownerid,' :小计') purchaseorder_smownerid2,'' purchaseorder_groupname, '' report_wx_userid,'' report_wx_groupid,'' PurchaseOrder_Subject,'' PurchaseOrder_PurchaseOrder_No,
        '' PurchaseOrder_Vendorid,'' PurchaseOrder_Vendorid_id,'' PurchaseOrder_postatus, null PurchaseOrder_signed_data,null PurchaseOrder_CreatedTime, 
        sum(if(purchaseorder_curid > 1,PurchaseOrder_Total/purchaseorder_rate,PurchaseOrder_Total)) PurchaseOrder_Total,sum(oftenusereport_SendCashBillamount) oftenusereport_SendCashBillamount,
        sum(oftenusereport_SendCashBillBalance) oftenusereport_SendCashBillBalance, null LBL_ACTION,purchaseorder_curid,purchaseorder_rate,purchaseorder_symbol 
        FROM temptable2 group by purchaseorder_smownerid );";
            $adb->query($SQL);
            //echo $SQL.'<br><br>';
            $SQL=" create TEMPORARY table IF NOT EXISTS temptable4 ignore( 
        select * from (
        select * from temptable2 union select * from temptable3 order by purchaseorder_smownerid2,PurchaseOrder_CreatedTime
        ) as temp);";
            $adb->query($SQL);
            //echo $SQL.'<br><br>';
            $SQL="select purchaseorder_smownerid,purchaseorder_smownerid2,purchaseorder_groupname,report_wx_userid,report_wx_groupid,PurchaseOrder_PurchaseOrder_No,PurchaseOrder_signed_data,PurchaseOrder_CreatedTime,PurchaseOrder_Subject,
        PurchaseOrder_Vendorid,PurchaseOrder_Vendorid_id,PurchaseOrder_postatus, PurchaseOrder_Total ,oftenusereport_SendCashBillBalance , oftenusereport_SendCashBillamount ,
        LBL_ACTION,purchaseorder_curid,purchaseorder_rate,purchaseorder_symbol from temptable4 union select '".getFixedLabel('TOTAL')."','".getFixedLabel('TOTAL')."','','','','','','','','','','',sum(if(purchaseorder_curid > 1,PurchaseOrder_Total/purchaseorder_rate,PurchaseOrder_Total)) PurchaseOrder_Total, 
        sum(oftenusereport_SendCashBillBalance) oftenusereport_SendCashBillBalance,sum(oftenusereport_SendCashBillamount) oftenusereport_SendCashBillamount,
        '','','','' from temptable2;";
            //echo $SQL.'<br><br>';
            return $SQL;
    }
    
    //应付款统计表_按付款计划
    static function getSendCashBillSum_SendPayment($where)
    {
        global $adb;
      //echo $where;
		//已付金额计算时是否统计未审核的付款单
		$focus = CRMEntity::getInstance('SendCashBill');
		$checkoutstatuswhere = $focus->get_SendCashBillCheckoutstatusWhere();
		$newstr = substr($where,0,1);//
        if($newstr =='('){
            $where=' And '.$where;//Liver 将ld_accountcashbill替换为ld_account,为高级查找前面加上and
        }
      
        $SQL="CREATE TEMPORARY TABLE
IF NOT EXISTS `temptable` IGNORE (
	SELECT
		ld_userssendpayment.last_name AS sendpayment_smownerid,
		ld_userssendpayment.last_name AS sendpayment_smownerid2,
		ld_group.groupname AS sendpayment_groupname,
		ld_userssendpayment.wx_userid as report_wx_userid,
		ld_group.groupid as report_wx_groupid,
		ld_vendorsendpayment.vendorname AS sendpayment_vendorid,
        ld_vendorsendpayment.vendorid AS sendpayment_vendorid_id,
		ld_purchaseorder.signed_data AS purchaseorder_signed_data,
        ld_purchaseorder.currency_id AS purchaseorder_curid,
		ld_purchaseorder.conversion_rate AS purchaseorder_rate,
		ld_purchaseorder.currency_symbol AS purchaseorder_symbol,
		ld_purchaseordersendpayment.`subject` AS sendpayment_purchaseorderid,
		ld_purchaseordersendpayment.purchaseorder_no AS purchaseorder_purchaseorder_no,
		ld_purchaseordersendpayment.total AS purchaseorder_hdnGrandTotal,
		ld_sendpayment.sendpayment_no AS sendpayment_sendpayment_no,
		ld_sendpayment.plandate AS sendpayment_plandate,
		ld_sendpayment.Actualdate AS sendpayment_Actualdate,
		ld_sendpayment.amount AS sendpayment_amount,
		ifnull(ld_sendpayment.actualamount,0) AS sendpayment_actualamount,
		ld_sendpayment.cpstatus AS sendpayment_cpstatus,
        ld_sendpayment.currency_id AS sendpayment_curid,
        ld_sendpayment.conversion_rate AS sendpayment_rate,
        ld_sendpayment.currency_symbol AS sendpayment_symbol,
        ld_sendcashbill.currency_id AS sendcashbill_curid,
		ld_sendcashbill.conversion_rate AS sendcashbill_rate,
		ld_sendcashbill.currency_symbol AS sendcashbill_symbol,
	    ld_sendpayment.pay_balance/(ifnull(ld_sendpayment.conversion_rate,0)) AS oftenusereport_sendpaymentbalance,
		ld_sendpayment.sendpaymentid AS lbl_action
	FROM
		ld_sendpayment
  LEFT JOIN ld_sendpaymentscf ON  ld_sendpaymentscf.sendpaymentid=ld_sendpayment.sendpaymentid
	LEFT JOIN ld_vendor AS ld_vendorsendpayment ON ld_sendpayment.vendorid = ld_vendorsendpayment.vendorid
    LEFT JOIN ld_vendor ON ld_sendpayment.vendorid = ld_vendor.vendorid
	LEFT JOIN ld_purchaseorder ld_purchaseordersendpayment ON ld_purchaseordersendpayment.purchaseorderid = ld_sendpayment.purchaseorder_id
	LEFT JOIN ld_purchaseorder ON ld_purchaseorder.purchaseorderid = ld_sendpayment.purchaseorder_id
	LEFT JOIN ld_users as ld_userssendpayment ON ld_userssendpayment.id = ld_sendpayment.smownerid
	LEFT JOIN (
		select GROUP_CONCAT(ld_groups.groupname) as groupname,GROUP_CONCAT(ld_groups.groupid) as groupid,ld_users2group.userid from ld_users2group
		LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
		GROUP BY ld_users2group.userid
	) as ld_group on ld_group.userid = ld_sendpayment.smownerid
    left join ld_sendcashbill2payment on ld_sendcashbill2payment.purchaseorder_id = ld_sendpayment.purchaseorder_id
	LEFT JOIN (select * from ld_sendcashbill where 1 $checkoutstatuswhere) as ld_sendcashbill on ld_sendcashbill.sendcashbillid = ld_sendcashbill2payment.sendcashbillid
	WHERE
		ld_sendpayment.deleted = 0 
	AND ld_purchaseordersendpayment.postatus <> '已作废' ".sprintf($where,'ld_sendpayment')." GROUP BY ld_sendpayment.sendpaymentid );";
        $adb->query($SQL);

		$SQL="CREATE TEMPORARY TABLE
IF NOT EXISTS `temptable5` IGNORE (
	SELECT
		ld_userssendpayment.last_name AS sendpayment_smownerid,
		ld_userssendpayment.last_name AS sendpayment_smownerid2,
		ld_group.groupname AS sendpayment_groupname,
		ld_userssendpayment.wx_userid as report_wx_userid,
		ld_group.groupid as report_wx_groupid,
		ld_vendorsendpayment.vendorname AS sendpayment_vendorid,
		ld_vendorsendpayment.vendorid AS sendpayment_vendorid_id,
		ld_purchaseinvoice.purchaseinvoicedate AS purchaseorder_signed_data,
		ld_purchaseinvoice.currency_id AS purchaseorder_curid,
		ld_purchaseinvoice.conversion_rate AS purchaseorder_rate,
		ld_purchaseinvoice.currency_symbol AS purchaseorder_symbol,
		ld_purchaseinvoice.`subject` AS sendpayment_purchaseorderid,
		ld_purchaseinvoice.purchaseinvoice_no AS purchaseorder_purchaseorder_no,
		ld_purchaseinvoice.total AS purchaseorder_hdnGrandTotal,
		ld_sendpayment.sendpayment_no AS sendpayment_sendpayment_no,
		ld_sendpayment.plandate AS sendpayment_plandate,
		ld_sendpayment.Actualdate AS sendpayment_Actualdate,
		ld_sendpayment.amount AS sendpayment_amount,
		ifnull(
			ld_sendpayment.actualamount,
			0
		) AS sendpayment_actualamount,
		ld_sendpayment.cpstatus AS sendpayment_cpstatus,
		ld_sendpayment.currency_id AS sendpayment_curid,
		ld_sendpayment.conversion_rate AS sendpayment_rate,
		ld_sendpayment.currency_symbol AS sendpayment_symbol,
		ld_sendcashbill.currency_id AS sendcashbill_curid,
		ld_sendcashbill.conversion_rate AS sendcashbill_rate,
		ld_sendcashbill.currency_symbol AS sendcashbill_symbol,
		ld_sendpayment.pay_balance / (
			ifnull(
				ld_sendpayment.conversion_rate,
				0
			)
		) AS oftenusereport_sendpaymentbalance,
		ld_sendpayment.sendpaymentid AS lbl_action
	FROM
		ld_sendpayment
	LEFT JOIN ld_sendpaymentscf ON ld_sendpaymentscf.sendpaymentid = ld_sendpayment.sendpaymentid
	LEFT JOIN ld_vendor AS ld_vendorsendpayment ON ld_sendpayment.vendorid = ld_vendorsendpayment.vendorid
	LEFT JOIN ld_vendor ON ld_sendpayment.vendorid = ld_vendor.vendorid
	LEFT JOIN ld_purchaseinvoice ON ld_purchaseinvoice.purchaseinvoiceid = ld_sendpayment.purchaseorder_id
	LEFT JOIN ld_users AS ld_userssendpayment ON ld_userssendpayment.id = ld_sendpayment.smownerid
	LEFT JOIN (
		select GROUP_CONCAT(ld_groups.groupname) as groupname,GROUP_CONCAT(ld_groups.groupid) as groupid,ld_users2group.userid from ld_users2group
		LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
		GROUP BY ld_users2group.userid
	) as ld_group on ld_group.userid = ld_sendpayment.smownerid
	LEFT JOIN ld_sendcashbill2payment ON ld_sendcashbill2payment.purchaseorder_id = ld_sendpayment.purchaseorder_id
	LEFT JOIN (
		SELECT
			*
		FROM
			ld_sendcashbill
		WHERE
			1
		AND ifnull(
			ld_sendcashbill.approvestatus,
			''
		) <> '已拒绝'
	) AS ld_sendcashbill ON ld_sendcashbill.sendcashbillid = ld_sendcashbill2payment.sendcashbillid
	WHERE
		ld_sendpayment.deleted = 0
	AND ld_purchaseinvoice.purchaseinvoicestatus <> '已作废' ".sprintf($where,'ld_sendpayment')." GROUP BY ld_sendpayment.sendpaymentid );";
	//echo $SQL;echo '<br><br>';
	 $adb->query($SQL);
	 $SQL="CREATE TEMPORARY TABLE
        IF NOT EXISTS `temptable6` IGNORE (
	       SELECT * FROM (SELECT * FROM temptable UNION SELECT * FROM temptable5) as F1 
    );";
      $adb->query($SQL);
        //echo $SQL."</br>";
        $SQL="
    CREATE TEMPORARY TABLE
    IF NOT EXISTS temptable4 IGNORE (
    SELECT sum(
    			IF (
    				purchaseorder_curid > 1,
    				IFNULL(
    					purchaseorder_hdnGrandTotal,
    					0
    				) / purchaseorder_rate,
    				IFNULL(
    					purchaseorder_hdnGrandTotal,
    					0
    				)
    			)
    		) purchaseorder_hdnGrandTotal,
    	concat(
    			sendpayment_smownerid,
    			'小计：'
    		) sendpayment_smownerid2
     FROM (SELECT * FROM temptable6 GROUP BY purchaseorder_purchaseorder_no)as f4 GROUP BY sendpayment_smownerid2
    );";
    //  echo $SQL."</br>";
       
       $adb->query($SQL);
       $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable1 IGNORE (
                SELECT 
                sendpayment_smownerid,
                F2.sendpayment_smownerid2,
				sendpayment_groupname,
				report_wx_userid,
				report_wx_groupid,
                sendpayment_vendorid,
                sendpayment_vendorid_id,
                sendpayment_purchaseorderid ,
                purchaseorder_signed_data,
                purchaseorder_curid,
                purchaseorder_rate,
                purchaseorder_symbol,
                purchaseorder_purchaseorder_no,
                purchaseorder_hdnGrandTotal ,
                sendpayment_sendpayment_no,
                sendpayment_plandate ,
                sendpayment_periodtime,
                sendpayment_amount,
                sendpayment_actualamount,
                sendpayment_paymentstatus,
                sendpayment_curid,
                sendpayment_rate,
                sendpayment_symbol,
                sendcashbill_curid,
                sendcashbill_rate,
                sendcashbill_symbol,
                oftenusereport_sendpaymentbalance,
                lbl_action 
                 FROM (
                	SELECT
                		'".getFixedLabel('SUBTOTAL')."' sendpayment_smownerid,
                		concat(
                			sendpayment_smownerid,
                			'小计：'
                		) sendpayment_smownerid2,
						'' sendpayment_groupname,
						'' report_wx_userid,
						'' report_wx_groupid,
                		'' sendpayment_vendorid,
                        '' sendpayment_vendorid_id,
                		'' AS sendpayment_purchaseorderid,
                		'' purchaseorder_signed_data,
                		'' purchaseorder_curid,
                		'' purchaseorder_rate,
                		'' purchaseorder_symbol,
                		'' purchaseorder_purchaseorder_no,
                		'' sendpayment_sendpayment_no,
                		NULL sendpayment_plandate,
                		'' sendpayment_periodtime,
                		sum(
                
                			IF (
                				sendpayment_curid > 1,
                				IFNULL(sendpayment_amount, 0) / sendpayment_rate,
                				IFNULL(sendpayment_amount, 0)
                			)
                		) AS sendpayment_amount,
                		sum(
                
                			IF (
                				sendcashbill_curid > 1,
                				IFNULL(sendpayment_actualamount, 0) / sendcashbill_rate,
                				IFNULL(sendpayment_actualamount, 0)
                			)
                		) sendpayment_actualamount,
                		'' sendpayment_paymentstatus,
                		'' sendpayment_curid,
                		'' sendpayment_rate,
                		'' sendpayment_symbol,
                		sendcashbill_curid,
                		sendcashbill_rate,
                		sendcashbill_symbol,
                		sum(
                			oftenusereport_sendpaymentbalance
                		) oftenusereport_sendpaymentbalance,
                		'' lbl_action
                	FROM
                		temptable6 
                	GROUP BY
                		sendpayment_smownerid2) as F2 LEFT JOIN temptable4 ON temptable4.sendpayment_smownerid2=F2.sendpayment_smownerid2
                );";                     
       /* $SQL="create TEMPORARY table if not exists temptable1 IGNORE ( 
        select '".getFixedLabel('SUBTOTAL')."' sendpayment_smownerid,concat(sendpayment_smownerid,'小计：') sendpayment_smownerid2,'' sendpayment_vendorid,'' as sendpayment_purchaseorderid ,
        '' purchaseorder_signed_data,'' purchaseorder_curid,'' purchaseorder_rate,'' purchaseorder_symbol,'' purchaseorder_purchaseorder_no, sum( if(purchaseorder_curid>1,IFNULL(purchaseorder_hdnGrandTotal,0)/purchaseorder_rate,IFNULL(purchaseorder_hdnGrandTotal,0))) purchaseorder_hdnGrandTotal ,
        '' sendpayment_sendpayment_no,null sendpayment_plandate ,'' sendpayment_periodtime,
        sum(if(sendpayment_curid > 1,IFNULL(sendpayment_amount,0)/sendpayment_rate,IFNULL(sendpayment_amount,0))) as sendpayment_amount ,sum(if(sendcashbill_curid>1,IFNULL(sendpayment_actualamount,0)/sendcashbill_rate,IFNULL(sendpayment_actualamount,0))) sendpayment_actualamount,
        '' sendpayment_paymentstatus,'' sendpayment_curid,'' sendpayment_rate,'' sendpayment_symbol ,sendcashbill_curid,sendcashbill_rate,sendcashbill_symbol, sum( oftenusereport_sendpaymentbalance ) oftenusereport_sendpaymentbalance ,'' lbl_action 
        from `temptable` group by sendpayment_smownerid2 );";*/
        $adb->query($SQL);
       // echo $SQL."</br>";
        $SQL="Create TEMPORARY table if not EXISTS  temptable2 (SELECT * from 
                (
                	select * from temptable6 UNION ALL select * from temptable1 order by sendpayment_smownerid2,purchaseorder_signed_data
                ) as temp
                );";
         // echo $SQL."</br>";      
        $adb->query($SQL);
        
        $SQL="select  sendpayment_smownerid,sendpayment_smownerid2, sendpayment_groupname,report_wx_userid,
				report_wx_groupid,sendpayment_vendorid,sendpayment_vendorid_id,sendpayment_purchaseorderid,purchaseorder_signed_data,purchaseorder_curid,purchaseorder_rate,purchaseorder_symbol
                , purchaseorder_purchaseorder_no, purchaseorder_hdnGrandTotal as PurchaseOrder_total, sendpayment_sendpayment_no, sendpayment_plandate
                ,sendpayment_Actualdate, sendpayment_amount, sendpayment_actualamount, sendpayment_CPStatus,sendpayment_curid,sendpayment_rate,sendpayment_symbol,sendcashbill_curid,sendcashbill_rate,sendcashbill_symbol
                ,  oftenusereport_sendpaymentbalance ,lbl_action from `temptable2` UNION ALL
                select '".getFixedLabel('TOTAL')."：' sendpayment_smownerid,'合计：' sendpayment_smownerid2,'' sendpayment_groupname,'' report_wx_userid,
				'' report_wx_groupid,'' sendpayment_vendorid,'' sendpayment_vendorid_id,'' purchaseorder_signed_data,'' purchaseorder_curid,'' purchaseorder_rate,'' purchaseorder_symbol,'' as sendpayment_purchaseorderid
                ,'' purchaseorder_purchaseorder_no,  sum( if(purchaseorder_curid>1,purchaseorder_hdnGrandTotal/purchaseorder_rate,purchaseorder_hdnGrandTotal))  PurchaseOrder_total
                ,''  sendpayment_sendpayment_no,null sendpayment_plandate
                ,'' sendpayment_Actualdate,sum(IFNULL(sendpayment_amount,0)) as sendpayment_amount
                ,sum( IFNULL(sendpayment_actualamount,0)) sendpayment_actualamount,'' sendpayment_CPStatus,'' sendpayment_curid,'' sendpayment_rate,'' sendpayment_symbol,'' sendcashbill_curid,'' sendcashbill_rate,'' sendcashbill_symbol
                , sum( oftenusereport_sendpaymentbalance ) oftenusereport_sendpaymentbalance,''  from `temptable1` ;
                ";
      // echo $SQL."</br>";
        return $SQL;
    }
    
    static function RunTimeAdvFilter($advft_criteria,$advft_criteria_groups,$reportabid) {
	     global $adb;
		$advfilterlist = array();

		if(!empty($advft_criteria)) {
			foreach($advft_criteria as $column_index => $column_condition) {

				if(empty($column_condition)) continue;

				$adv_filter_column = $column_condition["columnname"];
				$adv_filter_comparator = $column_condition["comparator"];
				$adv_filter_value = $column_condition["value"];
				$adv_filter_column_condition = $column_condition["columncondition"];
				$adv_filter_groupid = $column_condition["groupid"];

				$column_info = explode(":",$adv_filter_column);

				$moduleFieldLabel = $column_info[2];
				$fieldName = $column_info[3];
				list($module, $fieldLabel) = explode('_', $moduleFieldLabel, 2);
				$fieldInfo = getFieldByReportLabel($module, $fieldLabel);
				$fieldType = null;
				if(!empty($fieldInfo)) {
					$field = WebserviceField::fromArray($adb, $fieldInfo);
					$fieldType = $field->getFieldDataType();
				}

				if($fieldType == 'currency') {
					// Some of the currency fields like Unit Price, Total, Sub-total etc of Inventory modules, do not need currency conversion
					if($field->getUIType() == '72') {
						$adv_filter_value =setNumberFormatsetNumberFormat($adv_filter_value);
					} else {
						$adv_filter_value = setNumberFormatsetNumberFormat($adv_filter_value);
					}
				}

                $temp_val = explode(",",$adv_filter_value);
                if(($column_info[4] == 'D' || ($column_info[4] == 'T' && $column_info[1] != 'time_start' && $column_info[1] != 'time_end')
                        || ($column_info[4] == 'DT'))
                    && ($column_info[4] != '' && $adv_filter_value != '' ||$adv_filter_comparator=='isnull'||$adv_filter_comparator=='isnotnull')) {
                    $val = Array();
                    for($x=0;$x<count($temp_val);$x++) {
                        if($column_info[4] == 'D') {
							$date = new DateTimeField(trim($temp_val[$x]));
							$val[$x] = $date->getDBInsertDateValue();
						} elseif($column_info[4] == 'DT') {
							$date = new DateTimeField(trim($temp_val[$x]));
							$val[$x] = $date->getDBInsertDateTimeValue();
						} else {
							$date = new DateTimeField(trim($temp_val[$x]));
							$val[$x] = $date->getDBInsertTimeValue();
						}
                    }
                    $adv_filter_value = implode(",",$val);
                }
				$criteria = array();
				$criteria['columnname'] = $adv_filter_column;
				$criteria['comparator'] = $adv_filter_comparator;
				$criteria['value'] = $adv_filter_value;
				$criteria['column_condition'] = $adv_filter_column_condition;

				$advfilterlist[$adv_filter_groupid]['columns'][] = $criteria;
			}

			foreach($advft_criteria_groups as $group_index => $group_condition_info) {
				if(empty($group_condition_info)) continue;
				if(empty($advfilterlist[$group_index])) continue;
				$advfilterlist[$group_index]['condition'] = $group_condition_info["groupcondition"];
				$noOfGroupColumns = count($advfilterlist[$group_index]['columns']);
				if(!empty($advfilterlist[$group_index]['columns'][$noOfGroupColumns-1]['column_condition'])) {
					$advfilterlist[$group_index]['columns'][$noOfGroupColumns-1]['column_condition'] = '';
				}
			}
			$noOfGroups = count($advfilterlist);
			if(!empty($advfilterlist[$noOfGroups]['condition'])) {
				$advfilterlist[$noOfGroups]['condition'] = '';
			}
           //echo '<pre>'; print_r($advfilterlist);
			$advfiltersql =ReportSQL::generateAdvFilterSql($advfilterlist,$reportabid);
		}

		return strtolower($advfiltersql);

	}
    
    static function getCommencementSchedule($where)
    {
        global $adb;
        $SQL="CREATE TEMPORARY TABLE
IF NOT EXISTS temptable1 IGNORE (
	SELECT
		ld_products.productcategory AS statistical_one,
		ld_products.productid AS statistical_two,
		ld_salesorder.salesorderid AS statistical_three,
		ld_salesorder.potentialid,
		ld_products.productcategory,
		ld_products.productname,
		ld_products.product_no,
		TIMESTAMPDIFF(DAY,ld_salesorder.duedate,IFNULL(ld_salesordercf.cf_1204,ld_salesorder.duedate))+1 as duedate,
		ld_salesordercf.cf_1082,
		ld_accountsalesorder.accountname AS salesorder_accountid,
		ld_salesordercf.cf_1084,
		ld_salesorder.salesorder_no,
		IFNULL(ld_salesorder.total, 0) AS salesordertotal,
		IFNULL(ld_salesorder.total, 0) - ifnull(ld_cashbill.total, 0) AS PaymentBalance
	FROM
		ld_salesorderdetail
	INNER JOIN ld_products ON ld_salesorderdetail.productid = ld_products.productid
	LEFT JOIN ld_salesorder ON ld_salesorderdetail.id = ld_salesorder.salesorderid
	LEFT JOIN ld_salesordercf ON ld_salesorder.salesorderid = ld_salesordercf.salesorderid
	LEFT JOIN ld_account AS ld_accountsalesorder ON ld_accountsalesorder.accountid = ld_salesorder.accountid
	LEFT JOIN (
	SELECT
		entitytypeid,
		sum(amount) as total
	FROM
		ld_cashbill2paymentplan
	GROUP BY
		entitytypeid
    ) AS ld_cashbill ON ld_cashbill.entitytypeid = ld_salesorder.salesorderid
	WHERE
		ld_salesorder.sostatus <> '已作废' ".sprintf($where,'ld_SalesOrder').");";
        $adb->query($SQL);
        //echo $SQL."</br>";
        $SQL="Create TEMPORARY table IF NOT EXISTS temptable2 ignore(SELECT ld_potential.potentialid,ld_contactdetails.contactid,ld_accountsalesorder.accountname as contactdetails_accountid,
        ld_contactdetails.lastname,ld_accountsalesorder.phone,ld_contactdetails.email,ld_contactscf.cf_1088,ld_contactdetails.faxx,ld_contactdetails.firstname,ld_accountsalesorder.bill_code,
        concat(ld_accountsalesorder.bill_country,'-',ld_accountsalesorder.bill_state,'-',ld_accountsalesorder.bill_city,'-',ld_accountsalesorder.bill_street) as bill_street,
        ld_accountscf.cf_1089,ld_contactdetails.salutation,ld_contactdetails.title,ld_contactdetails.mobile,ld_contactdetails.pphone 
        from ld_contactdetails 
        LEFT JOIN ld_contpotentialrel on ld_contpotentialrel.contactid=ld_contactdetails.contactid 
        left join ld_account as ld_accountsalesorder on ld_accountsalesorder.accountid = ld_contactdetails.accountid 
        left join ld_accountscf on ld_accountscf.accountid=ld_accountsalesorder.accountid 
        left join ld_contactscf on ld_contactscf.contactid=ld_contactdetails.contactid 
        LEFT JOIN ld_potential on ld_potential.potentialid=ld_contpotentialrel.potentialid);";
         //echo $SQL."</br>";      
        $adb->query($SQL);
        
        $SQL="SELECT temptable1.statistical_one,temptable1.statistical_two,temptable1.statistical_three, productcategory as products_productcategory,cf_1088 as contactscf_cf_1088,faxx as contactdetails_faxx,firstname as contactdetails_firstname,phone as account_phone,bill_code as accountbillads_bill_code,
        bill_street as accountbillads_bill_street,email as contactdetails_email,salutation as contactdetails_salutation,cf_1089 as accountscf_cf_1089,productname as products_productname,product_no as products_product_no,duedate as salesorder_duedate,
        cf_1082 as salesordercf_cf_1082,temptable1.salesorder_accountid,cf_1084 as salesordercf_cf_1084,salesorder_no as salesorder_salesorder_no,salesordertotal as salesorder_salesordertotal,PaymentBalance as salesorder_PaymentBalance,
        contactid,temptable2.contactdetails_accountid,lastname as contactdetails_lastname,title as contactdetails_title,mobile as contactdetails_mobile,pphone as contactdetails_pphone 
        from temptable2 LEFT JOIN temptable1 on temptable1.potentialid=temptable2.potentialid
         WHERE productcategory<>'' ORDER BY productcategory,statistical_two,duedate, statistical_three ,cf_1088;";
      //echo $SQL."</br>";
        return $SQL;
    }
    
static function getOverallCommencementSchedule($where){
     //   echo $where;
    global $adb;
     $SQL="CREATE TEMPORARY TABLE
IF NOT EXISTS temptable2 IGNORE (
	SELECT
		TIMESTAMPDIFF(DAY,ld_salesorder.duedate,IFNULL(ld_salesordercf.cf_1204,ld_salesorder.duedate))+1 AS salesorder_duedate,
		t6.productname AS products_productname,
		ld_salesordercf.cf_1084 AS salesordercf_cf_1084,
		ld_salesordercf.cf_1082 AS salesordercf_cf_1082,
		ld_accountSalesOrder.accountname AS salesorder_accountid,
		concat(
			ld_accountSalesOrder.bill_state,
			' ',
			ld_accountSalesOrder.bill_city,
			' ',
			ld_accountSalesOrder.bill_street
		) AS 伙伴地址,
		ld_salesorder.salesorder_no AS salesorder_salesorder_no,
		ifnull(ld_salesorder.total, 0.00) AS salesorder_salesordertotal,
		ifnull(t7.subtotal, 0.00) AS 已收金额,
		ifnull(ld_salesorder.total, 0) - ifnull(t7.subtotal, 0.00) AS salesorder_PaymentBalance,
		t12.accountname AS contactdetails_accountid,
		concat(
			t12.bill_state,
			' ',
			t12.bill_city
		) AS accountbillads_bill_street,
		ld_contactdetailsSalesOrder.lastname AS contactdetails_lastname,
		ld_contactdetailsSalesOrder.salutation AS contactdetails_salutation,
		t10.cf_1088 AS contactscf_cf_1088,
		ld_contactdetailsSalesOrder.title AS contactdetails_title,
		ld_contactdetailsSalesOrder.mobile AS contactdetails_mobile,
		ld_contactdetailsSalesOrder.phone AS contactdetails_pphone,
		ld_contactdetailsSalesOrder.email AS contactdetails_email,
		ld_salesorder.salesorderid AS statistical_field
	FROM
		ld_salesorder
	INNER JOIN ld_salesordercf ON ld_salesorder.salesorderid = ld_salesordercf.salesorderid
	INNER JOIN ld_account AS ld_accountSalesOrder ON ld_salesorder.accountid = ld_accountSalesOrder.accountid
	INNER JOIN (
		SELECT
			id,
			productid
		FROM
			ld_salesorderdetail
		GROUP BY
			id
	) AS t5 ON ld_salesorder.salesorderid = t5.id
	INNER JOIN ld_products AS t6 ON t5.productid = t6.productid
	LEFT OUTER JOIN (
		SELECT
			entitytypeid,
			sum(amount) AS subtotal
		FROM
			ld_cashbill2paymentplan
		GROUP BY
			entitytypeid
	) AS t7 ON ld_salesorder.salesorderid = t7.entitytypeid
	INNER JOIN ld_contpotentialrel AS t8 ON t8.potentialid = ld_salesorder.potentialid
	INNER JOIN ld_contactdetails AS ld_contactdetailsSalesOrder ON ld_contactdetailsSalesOrder.contactid = t8.contactid
	INNER JOIN ld_contactscf AS t10 ON ld_contactdetailsSalesOrder.contactid = t10.contactid
	
	INNER JOIN ld_account AS t12 ON t12.accountid = ld_contactdetailsSalesOrder.accountid
	
	LEFT JOIN ld_potential AS ld_potentialSalesOrder ON ld_potentialSalesOrder.potentialid = t8.potentialid
	LEFT JOIN ld_users AS ld_UsersSalesOrder ON ld_UsersSalesOrder.id = ld_salesorder.smownerid
	WHERE
		ld_salesorder.sostatus <> '已作废'
	AND ld_salesorder.deleted = 0 ".sprintf($where,'ld_SalesOrder')." 
        ORDER BY
		ld_salesorder.duedate,
		ld_salesorder.salesorderid,
		t6.productname
    );";
    //echo $SQL."</br>";
        $adb->query($SQL);
     $SQL="select * from temptable2 GROUP BY salesorder_salesorder_no;";
    $result=$adb->query($SQL);
     $count = $adb->num_rows($result);
    
            $SQL="Create TEMPORARY table IF NOT EXISTS temptable1 ignore(select '合计开课次数' as salesorder_duedate,$count as products_productname,'' as salesordercf_cf_1084,'' as salesordercf_cf_1082,'' as salesorder_accountid, 
	   '' as 伙伴地址,'' as salesorder_salesorder_no, 
       '' as salesorder_salesordertotal,'' as 已收金额,'' as salesorder_PaymentBalance, 
       '' as contactdetails_accountid,'' as accountbillads_bill_street,'' as contactdetails_lastname, 
       '' as contactdetails_salutation,'' as contactscf_cf_1088,'' as contactdetails_title,'' as contactdetails_mobile,'' as contactdetails_pphone ,'' as contactdetails_email 
       , 0 as statistical_field
        from temptable2 );";
 //echo $SQL."</br>";
         $adb->query($SQL);
    /// echo $SQL."</br>";
        $SQL="SELECT * FROM temptable2 UNION SELECT * FROM temptable1 ;";
    //    echo $SQL."</br>";
      // echo $SQL."</br>";
        return $SQL;
    }
    static function getPartnerCommencementSchedule($where){
        //echo $where;
        global $adb;
     $SQL="CREATE TEMPORARY TABLE
IF NOT EXISTS temptable2 IGNORE (
	SELECT
		ld_salesorder.accountid AS statistical_one,
		ld_salesorder.salesorderid statistical_two,
		ld_accountSalesOrder.accountname AS salesorder_accountid,
		TIMESTAMPDIFF(DAY,ld_salesorder.duedate,IFNULL(ld_salesordercf.cf_1204,ld_salesorder.duedate))+1 AS salesorder_duedate,
		t6.productname AS products_productname,
		ld_salesordercf.cf_1084 AS salesordercf_cf_1084,
		ld_salesordercf.cf_1082 AS salesordercf_cf_1082,
		concat(
			ld_accountSalesOrder.bill_state,
			' ',
			ld_accountSalesOrder.bill_city,
			' ',
			ld_accountSalesOrder.bill_street
		) AS 伙伴地址,
		ld_salesorder.salesorder_no AS salesorder_salesorder_no,
		ifnull(ld_salesorder.total, 0.00) AS salesorder_salesordertotal,
		ifnull(t7.subtotal, 0.00) AS salesorder_yishoutotal,
		ifnull(ld_salesorder.total, 0) - ifnull(t7.subtotal, 0.00) AS salesorder_PaymentBalance,
		t12.accountname AS contactdetails_accountid,
		concat(
			t12.bill_state,
			' ',
			t12.bill_city
		) AS accountbillads_bill_street,
		ld_contactdetailsSalesOrder.lastname AS contactdetails_lastname,
		ld_contactdetailsSalesOrder.salutation AS contactdetails_salutation,
		t10.cf_1088 AS contactscf_cf_1088,
		ld_contactdetailsSalesOrder.title AS contactdetails_title,
		ld_contactdetailsSalesOrder.mobile AS contactdetails_mobile,
		ld_contactdetailsSalesOrder.phone AS contactdetails_pphone,
		ld_contactdetailsSalesOrder.email AS contactdetails_email,
        		ifnull(
			ld_ExpenseSalesOrder.stotal,
			0.00
		) AS expense_total
	FROM
		ld_salesorder
	INNER JOIN ld_salesordercf ON ld_salesorder.salesorderid = ld_salesordercf.salesorderid
	INNER JOIN ld_account AS ld_accountSalesOrder ON ld_salesorder.accountid = ld_accountSalesOrder.accountid
	INNER JOIN (
		SELECT
			id,
			productid
		FROM
			ld_salesorderdetail
		GROUP BY
			id
	) AS t5 ON ld_salesorder.salesorderid = t5.id
	INNER JOIN ld_products AS t6 ON t5.productid = t6.productid
	LEFT OUTER JOIN (
		SELECT
			entitytypeid,
			sum(amount) AS subtotal
		FROM
			ld_cashbill2paymentplan
		GROUP BY
			entitytypeid
	) AS t7 ON ld_salesorder.salesorderid = t7.entitytypeid
	INNER JOIN ld_contpotentialrel AS t8 ON t8.potentialid = ld_salesorder.potentialid
	INNER JOIN ld_contactdetails AS ld_contactdetailsSalesOrder ON ld_contactdetailsSalesOrder.contactid = t8.contactid
	INNER JOIN ld_contactscf AS t10 ON ld_contactdetailsSalesOrder.contactid = t10.contactid
	INNER JOIN ld_account AS t12 ON t12.accountid = ld_contactdetailsSalesOrder.accountid
	LEFT JOIN ld_potential AS ld_potentialSalesOrder ON ld_potentialSalesOrder.potentialid = t8.potentialid
	LEFT JOIN ld_users AS ld_UsersSalesOrder ON ld_UsersSalesOrder.id = ld_salesorder.smownerid 
	LEFT JOIN (
		SELECT
			SUM(total) AS stotal,
			ld_commission2payment.entitytypeid
		FROM
			ld_Commission 
		LEFT JOIN ld_commission2payment ON ld_commission.commission_id=ld_commission2payment.commission_id 
        WHERE ld_Commission.deleted=0 
		GROUP BY
			ld_commission2payment.entitytypeid
	) AS ld_ExpenseSalesOrder ON ld_ExpenseSalesOrder.entitytypeid = ld_salesorder.salesorderid
	WHERE
		ld_salesorder.sostatus <> '已作废'
	AND ld_salesorder.accountid IN (
		SELECT
			accountid
		FROM
			ld_account
		WHERE
			account_type = '合作伙伴'
	)
	AND ld_salesorder.deleted = 0 ".sprintf($where,'ld_SalesOrder')."  
	ORDER BY
		ld_salesorder.accountid,
		ld_salesorder.duedate,
		salesorder_salesorder_no
    );";
   //echo $SQL."</br>";
        $adb->query($SQL);
                
     $SQL="Create TEMPORARY table IF NOT EXISTS temptable3 ignore(
            SELECT salesorder_accountid,COUNT(salesorder_accountid) as count,statistical_one FROM temptable2 
            GROUP BY statistical_one,statistical_two
            );";
        $adb->query($SQL);
       // echo $SQL.'<br>';
     $SQL="Create TEMPORARY table IF NOT EXISTS temptable4 ignore(
     SELECT salesorder_accountid,COUNT(salesorder_salesorder_no) as count ,statistical_one
            FROM temptable2 GROUP BY statistical_two);";
    $adb->query($SQL);
    // echo $SQL."</br>";
         $SQL="Create TEMPORARY table IF NOT EXISTS temptable5 ignore(
	SELECT count(salesorder_accountid) as salesorder_salesorder_count,salesorder_accountid FROM temptable4 GROUP BY statistical_one);";
    $adb->query($SQL);
    // echo $SQL."</br>";
        $SQL="SELECT temptable2.*,temptable5.salesorder_salesorder_count FROM temptable2 LEFT JOIN temptable5 ON temptable2.salesorder_accountid=temptable5.salesorder_accountid;";
      // echo $SQL."</br>";
        return $SQL;
    }
    
    static function getLecturerCommencementSchedule($where){
        //echo $where;
        global $adb;
     $SQL="CREATE TEMPORARY TABLE
IF NOT EXISTS temptable2 IGNORE (
	SELECT
		ld_salesordercf.cf_1082 AS statistical_one,
		ld_salesorder.salesorderid statistical_two,
		TIMESTAMPDIFF(DAY,ld_salesorder.duedate,IFNULL(ld_salesordercf.cf_1204,ld_salesorder.duedate))+1 AS salesorder_duedate,
		t6.productname AS products_productname,
		ld_salesordercf.cf_1084 AS salesordercf_cf_1084,
		ld_salesordercf.cf_1082 AS salesordercf_cf_1082,
		ld_accountSalesOrder.accountname AS salesorder_accountid,
		concat(
			ld_accountSalesOrder.bill_state,
			' ',
			ld_accountSalesOrder.bill_city,
			' ',
			ld_accountSalesOrder.bill_street
		) AS 伙伴地址,
		ld_salesorder.salesorder_no AS salesorder_salesorder_no,
		ifnull(ld_salesorder.total, 0.00) AS salesorder_salesordertotal,
		ifnull(t7.subtotal, 0.00) AS 已收金额,
		ifnull(ld_salesorder.total, 0) - ifnull(t7.subtotal, 0.00) AS salesorder_PaymentBalance,
		t12.accountname AS contactdetails_accountid,
		concat(
			t12.bill_state,
			' ',
			t12.bill_city
		) AS accountbillads_bill_street,
		ld_contactdetailsSalesOrder.lastname AS contactdetails_lastname,
		ld_contactdetailsSalesOrder.salutation AS contactdetails_salutation,
		t10.cf_1088 AS contactscf_cf_1088,
		ld_contactdetailsSalesOrder.title AS contactdetails_title,
		ld_contactdetailsSalesOrder.mobile AS contactdetails_mobile,
		ld_contactdetailsSalesOrder.phone AS contactdetails_pphone,
		ld_contactdetailsSalesOrder.email AS contactdetails_email
	FROM
		ld_salesorder
	INNER JOIN ld_salesordercf ON ld_salesorder.salesorderid = ld_salesordercf.salesorderid
	INNER JOIN ld_account AS ld_accountSalesOrder ON ld_salesorder.accountid = ld_accountSalesOrder.accountid
	INNER JOIN (
		SELECT
			id,
			productid
		FROM
			ld_salesorderdetail
		GROUP BY
			id
	) AS t5 ON ld_salesorder.salesorderid = t5.id
	INNER JOIN ld_products AS t6 ON t5.productid = t6.productid
	LEFT OUTER JOIN (
		SELECT
			entitytypeid,
			sum(amount) AS subtotal
		FROM
			ld_cashbill2paymentplan
		GROUP BY
			entitytypeid
	) AS t7 ON ld_salesorder.salesorderid = t7.entitytypeid
	INNER JOIN ld_contpotentialrel AS t8 ON t8.potentialid = ld_salesorder.potentialid
	INNER JOIN ld_contactdetails AS ld_contactdetailsSalesOrder ON ld_contactdetailsSalesOrder.contactid = t8.contactid
	INNER JOIN ld_contactscf AS t10 ON ld_contactdetailsSalesOrder.contactid = t10.contactid
	INNER JOIN ld_account AS t12 ON t12.accountid = ld_contactdetailsSalesOrder.accountid
	LEFT JOIN ld_potential AS ld_potentialSalesOrder ON ld_potentialSalesOrder.potentialid = t8.potentialid
	LEFT JOIN ld_users AS ld_UsersSalesOrder ON ld_UsersSalesOrder.id = ld_salesorder.smownerid
	WHERE
		ld_salesorder.sostatus <> '已作废'
	AND ld_salesorder.deleted = 0 ".sprintf($where,'ld_SalesOrder')."  
        ORDER BY
		salesordercf_cf_1082,
		ld_salesorder.duedate,
		ld_salesorder.salesorderid
    );";
    //echo $SQL."</br>";
        $adb->query($SQL);
     $SQL="Create TEMPORARY table IF NOT EXISTS temptable3 ignore(
            SELECT salesorder_accountid,COUNT(salesorder_accountid) as count,statistical_one FROM temptable2
             GROUP BY statistical_one,statistical_two
            );";
          //  echo $SQL."</br>";
        $adb->query($SQL);
        
     $SQL="Create TEMPORARY table IF NOT EXISTS temptable4 ignore(
     SELECT salesordercf_cf_1082,COUNT(salesorder_salesorder_no) as count ,statistical_one
            FROM temptable2 GROUP BY statistical_two)";
     //echo $SQL."</br>";
    $adb->query($SQL);
   
         $SQL="Create TEMPORARY table IF NOT EXISTS temptable5 ignore(
	SELECT count(salesordercf_cf_1082) as salesorder_salesorder_count,salesordercf_cf_1082,statistical_one FROM temptable4 GROUP BY salesordercf_cf_1082)";
     //echo $SQL."</br>";
    $adb->query($SQL);
    
        $SQL="SELECT temptable2.*,temptable5.salesorder_salesorder_count FROM temptable2 LEFT JOIN temptable5 ON temptable2.salesordercf_cf_1082=temptable5.salesordercf_cf_1082";
       // echo $SQL."</br>";
        return $SQL;
    }
    
   static function getStudentsparticipatinginthetrainingschedule($where){
       // echo $where;
        global $adb;
     $SQL="Create TEMPORARY table IF NOT EXISTS temptable2 ignore(select TIMESTAMPDIFF(DAY,ld_salesorder.duedate,IFNULL(ld_salesordercf.cf_1204,ld_salesorder.duedate))+1 as salesorder_duedate,t6.productname as products_productname,ld_salesordercf.cf_1084 as salesordercf_cf_1084,ld_salesordercf.cf_1082 as salesordercf_cf_1082,ld_accountSalesOrder.accountname as salesorder_accountid, 
	   concat(ld_accountSalesOrder.bill_state,' ',ld_accountSalesOrder.bill_city,' ',ld_accountSalesOrder.bill_street) as 伙伴地址,ld_salesorder.salesorder_no as salesorder_salesorder_no, 
       ifnull(ld_salesorder.total,0.00) as salesorder_salesordertotal,ifnull(t7.subtotal,0.00) as 已收金额,ifnull(ld_salesorder.total,0)-ifnull(t7.subtotal,0.00) as salesorder_PaymentBalance, 
       t12.accountname as contactdetails_accountid,concat(t12.bill_state,' ',t12.bill_city) as accountbillads_bill_street,ld_contactdetailsSalesOrder.lastname as contactdetails_lastname, 
       ld_contactdetailsSalesOrder.salutation as contactdetails_salutation,t10.cf_1088 as contactscf_cf_1088,
       ld_contactdetailsSalesOrder.title as contactdetails_title,
       ld_contactdetailsSalesOrder.mobile as contactdetails_mobile,ld_contactdetailsSalesOrder.contactid as statistical_field,
       IFNULL(ld_contactdetailsSalesOrder.phone,'') as contactdetails_pphone 
        from ld_salesorder inner join 
     ld_salesordercf on ld_salesorder.salesorderid=ld_salesordercf.salesorderid  inner join 
     ld_account as ld_accountSalesOrder on ld_salesorder.accountid=ld_accountSalesOrder.accountid inner join 
     (select id,productid from ld_salesorderdetail group by id) 
        as t5 on ld_salesorder.salesorderid=t5.id inner join 
     ld_products as t6 on t5.productid=t6.productid left outer join 
     (		SELECT
			entitytypeid,
			sum(amount) AS subtotal
		FROM
			ld_cashbill2paymentplan
		GROUP BY
			entitytypeid) 
        as t7 on ld_salesorder.salesorderid=t7.entitytypeid inner join 
		ld_contpotentialrel as t8 on t8.potentialid=ld_salesorder.potentialid inner join 
		ld_contactdetails as ld_contactdetailsSalesOrder on ld_contactdetailsSalesOrder.contactid=t8.contactid inner join 
		ld_contactscf as t10 on ld_contactdetailsSalesOrder.contactid=t10.contactid inner join 
		ld_account as t12 on t12.accountid=ld_contactdetailsSalesOrder.accountid  
		LEFT JOIN ld_potential as ld_potentialSalesOrder on ld_potentialSalesOrder.potentialid=t8.potentialid 
        left join ld_users as ld_UsersSalesOrder on ld_UsersSalesOrder.id=ld_salesorder.smownerid   
        where ld_salesorder.sostatus<>'已作废' and t10.cf_1088 ='课程学员' and ld_salesorder.deleted=0 ".sprintf($where,'ld_SalesOrder')." ORDER BY contactdetails_lastname,ld_salesorder.duedate);";
   //echo $SQL."</br>";
    $adb->query($SQL);
    $SQL="Create TEMPORARY table IF NOT EXISTS temptable3 ignore(select count(1) as salesorder_salesorder_count,statistical_field from temptable2 
    GROUP BY statistical_field
    )";
    $adb->query($SQL);
  //echo $SQL.'<br>';
    $SQL="SELECT  temptable2.* , temptable3.salesorder_salesorder_count FROM temptable2 LEFT JOIN temptable3 on temptable3.statistical_field=temptable2.statistical_field";
    //echo $SQL;  
        return $SQL;
    }
    
    static function getCustomersparticipatinginthetrainingschedule($where){
        //echo $where;
 
        
        global $adb;
     $SQL="Create TEMPORARY table IF NOT EXISTS temptable2 ignore(select ld_accountSalesOrder.accountid as statistical_field,  TIMESTAMPDIFF(DAY,ld_salesorder.duedate,IFNULL(ld_salesordercf.cf_1204,ld_salesorder.duedate))+1 as salesorder_duedate,t6.productname as products_productname,ld_salesordercf.cf_1084 as salesordercf_cf_1084,ld_salesordercf.cf_1082 as salesordercf_cf_1082,ld_accountSalesOrder.accountname as salesorder_accountid, 
	   concat(ld_accountSalesOrder.bill_state,' ',ld_accountSalesOrder.bill_city,' ',ld_accountSalesOrder.bill_street) as 伙伴地址,ld_salesorder.salesorder_no as salesorder_salesorder_no, 
       ifnull(ld_salesorder.total,0.00) as salesorder_salesordertotal,ifnull(t7.subtotal,0.00) as 已收金额,ifnull(ld_salesorder.total,0)-ifnull(t7.subtotal,0.00) as salesorder_PaymentBalance, 
       t12.accountname as contactdetails_accountid,t12.accountid AS contactdetails_accountid2,concat(t12.bill_state,' ',t12.bill_city) as accountbillads_bill_street,ld_contactdetailsSalesOrder.lastname as contactdetails_lastname, 
       ld_contactdetailsSalesOrder.salutation as contactdetails_salutation,t10.cf_1088 as contactscf_cf_1088,ld_contactdetailsSalesOrder.title as contactdetails_title,ld_contactdetailsSalesOrder.mobile as contactdetails_mobile,ld_contactdetailsSalesOrder.phone as contactdetails_pphone,ld_salesorder.subject as salesorder_subject,
		ifnull(
			ld_ExpenseSalesOrder.stotal,
			0.00
		) AS expense_total  
    from ld_salesorder inner join 
     ld_salesordercf on ld_salesorder.salesorderid=ld_salesordercf.salesorderid inner join 
     ld_crmentity  on ld_salesorder.salesorderid=ld_crmentity.crmid inner join 
     ld_account as ld_accountSalesOrder on ld_salesorder.accountid=ld_accountSalesOrder.accountid inner join 
     (select id,productid from ld_salesorderdetail group by id) 
    as t5 on ld_salesorder.salesorderid=t5.id inner join 
     ld_products as t6 on t5.productid=t6.productid left outer join 
     (		SELECT
			entitytypeid,
			sum(amount) AS subtotal
		FROM
			ld_cashbill2paymentplan
		GROUP BY
			entitytypeid) 
        as t7 on ld_salesorder.salesorderid=t7.entitytypeid inner join 
		ld_contpotentialrel as t8 on t8.potentialid=ld_salesorder.potentialid inner join 
		ld_contactdetails as ld_contactdetailsSalesOrder on ld_contactdetailsSalesOrder.contactid=t8.contactid inner join 
		ld_contactscf as t10 on ld_contactdetailsSalesOrder.contactid=t10.contactid inner join 
		ld_account as t12 on t12.accountid=ld_contactdetailsSalesOrder.accountid  
		LEFT JOIN ld_potential as ld_potentialSalesOrder on ld_potentialSalesOrder.potentialid=t8.potentialid 
        left join ld_users as ld_UsersSalesOrder on ld_UsersSalesOrder.id=ld_SalesOrder.smownerid 
        	LEFT JOIN (
		SELECT
			SUM(total) AS stotal,
			Salesorderid
		FROM
			ld_Expense
		GROUP BY
			Salesorderid
	) AS ld_ExpenseSalesOrder ON ld_ExpenseSalesOrder.Salesorderid = ld_salesorder.salesorderid  
        where ld_salesorder.sostatus<>'已作废' and ld_SalesOrder.deleted=0 ".sprintf($where,'ld_SalesOrder')." group by t12.accountid,ld_salesorder.salesorder_no ORDER BY salesorder_accountid,ld_salesorder.duedate );";
    //echo $SQL."</br>";
    $adb->query($SQL);
  
    $SQL = "CREATE TEMPORARY TABLE
IF NOT EXISTS temptable3 IGNORE (
SELECT F1.*,salesorder_no FROM (
SELECT COUNT(ld_contpotentialrel.contactid) as salesorder_salesorder_count,t12.accountid,ld_contpotentialrel.potentialid 
FROM ld_contpotentialrel 
LEFT JOIN ld_contactdetails ON ld_contactdetails.contactid=ld_contpotentialrel.contactid 
INNER JOIN ld_account AS t12 ON t12.accountid = ld_contactdetails.accountid 
GROUP BY t12.accountid,ld_contpotentialrel.potentialid 
) AS F1 
LEFT JOIN ld_salesorder ON ld_salesorder.potentialid = F1.potentialid
);";
    $adb->query($SQL);
   //echo $SQL."</br>";
    $SQL="SELECT
	temptable2.*, temptable3.salesorder_salesorder_count
FROM
	temptable2
LEFT JOIN temptable3 ON temptable2.contactdetails_accountid2 = temptable3.accountid 
AND temptable3.salesorder_no = temptable2.salesorder_salesorder_no";
    // echo $SQL."</br>"; 
        return $SQL;
    }
    
     static function getKPCCommencementDetails($where){
        //echo $where;
        global $adb;
     $SQL="Create TEMPORARY table IF NOT EXISTS temptable2 ignore(select ld_salesordercf.cf_1082 as statistical_one , ld_salesorder.salesorderid statistical_two,
     TIMESTAMPDIFF(DAY,ld_salesorder.duedate,IFNULL(ld_salesordercf.cf_1204,ld_salesorder.duedate))+1 as salesorder_duedate,t6.productname as products_productname,ld_salesordercf.cf_1084 as salesordercf_cf_1084,ld_salesordercf.cf_1082 as salesordercf_cf_1082,ld_accountSalesOrder.accountname as salesorder_accountid, 
	   concat(ld_accountSalesOrder.bill_state,' ',ld_accountSalesOrder.bill_city,' ',ld_accountSalesOrder.bill_street) as 伙伴地址,ld_salesorder.salesorder_no as salesorder_salesorder_no, 
       ifnull(ld_salesorder.total,0.00) as salesorder_salesordertotal,ifnull(t7.subtotal,0.00) as 已收金额,ifnull(ld_salesorder.total,0)-ifnull(t7.subtotal,0.00) as salesorder_PaymentBalance, 
       t12.accountname as contactdetails_accountid,concat(t12.bill_state,' ',t12.bill_city) as accountbillads_bill_street,ld_contactdetailsSalesOrder.lastname as contactdetails_lastname, 
       ld_contactdetailsSalesOrder.salutation as contactdetails_salutation,t10.cf_1088 as contactscf_cf_1088,ld_contactdetailsSalesOrder.title as contactdetails_title,ld_contactdetailsSalesOrder.mobile as contactdetails_mobile,ld_contactdetailsSalesOrder.phone as contactdetails_pphone ,ld_contactdetailsSalesOrder.email as contactdetails_email,
       		ifnull(
			ld_ExpenseSalesOrder.stotal,
			0.00
		) AS expense_total ,ifnull(cf_1205,'') AS invoice_cf_1205, ifnull(invoicetype,'') AS invoice_invoicetype 
        from ld_salesorder inner join 
     ld_salesordercf  on ld_salesorder.salesorderid=ld_salesordercf.salesorderid inner join 
     ld_crmentity  on ld_salesorder.salesorderid=ld_crmentity.crmid inner join 
     ld_account as ld_accountSalesOrder on ld_salesorder.accountid=ld_accountSalesOrder.accountid inner join 
     (select id,productid from ld_salesorderdetail group by id) 
        as t5 on ld_salesorderdetail.salesorderid=t5.id inner join 
     ld_products as t6 on t5.productid=t6.productid left outer join 
     (		SELECT
			entitytypeid,
			sum(amount) AS subtotal
		FROM
			ld_cashbill2paymentplan
		GROUP BY
			entitytypeid) 
        as t7 on ld_salesorder.salesorderid=t7.entitytypeid inner join 
		ld_contpotentialrel as t8 on t8.potentialid=ld_salesorder.potentialid inner join 
		ld_contactdetails as ld_contactdetailsSalesOrder on ld_contactdetailsSalesOrder.contactid=t8.contactid inner join 
		ld_contactscf as t10 on ld_contactdetailsSalesOrder.contactid=t10.contactid  inner join 
		ld_account as t12 on t12.accountid=ld_contactdetailsSalesOrder.accountid 
        LEFT JOIN ld_potential as ld_potentialSalesOrder on ld_potentialSalesOrder.potentialid=t8.potentialid 
        left join ld_users as ld_UsersSalesOrder on ld_UsersSalesOrder.id=ld_SalesOrder.smownerid  
        	LEFT JOIN (
		SELECT
			SUM(total) AS stotal,
			Salesorderid
		FROM
			ld_Expense
		GROUP BY
			Salesorderid
	) AS ld_ExpenseSalesOrder ON ld_ExpenseSalesOrder.Salesorderid = ld_salesorder.salesorderid 
    LEFT JOIN (
        SELECT ld_invoicedetail.entitytypeid,cf_1205,ld_invoicecf.invoicetype FROM ld_invoice 
        RIGHT JOIN ld_invoicedetail ON ld_invoicedetail.id = ld_invoice.invoiceid 
        INNER JOIN ld_invoicecf ON ld_invoice.invoiceid = ld_invoicecf.invoiceid 
        WHERE ld_invoicedetail.entitytypeid <> 0 AND deleted=0
    ) AS ld_invoiceld_ExpenseSalesOrder ON ld_invoiceld_ExpenseSalesOrder.entitytypeid = ld_salesorder.salesorderid 
        where ld_salesorder.sostatus<>'已作废' and ld_salesorder.accountid=(SELECT accountid FROM ld_account WHERE accountname='上海嘉博管理咨询有限公司') and ld_SalesOrder.deleted=0 ".sprintf($where,'ld_SalesOrder')." ORDER BY salesorder_accountid,ld_salesorder.duedate);";
    //echo $SQL."</br>";
    $adb->query($SQL);
    
         $SQL="Create TEMPORARY table IF NOT EXISTS temptable3 ignore(
            SELECT salesorder_accountid,COUNT(salesordercf_cf_1082) as count,statistical_one FROM temptable2 
            GROUP BY statistical_one,statistical_two
            );";
        $adb->query($SQL);
         //echo $SQL."</br>";
     $SQL="Create TEMPORARY table IF NOT EXISTS temptable4 ignore(
     SELECT salesordercf_cf_1082,COUNT(salesorder_salesorder_no) as count ,statistical_one
            FROM temptable2 GROUP BY statistical_two)";
    $adb->query($SQL);
        //echo $SQL."</br>"; 
    $SQL="Create TEMPORARY table IF NOT EXISTS temptable5 ignore(
	SELECT count(salesordercf_cf_1082) as salesorder_salesorder_count,salesordercf_cf_1082,statistical_one FROM temptable4
     GROUP BY statistical_one)";
    $adb->query($SQL);
     //echo $SQL."</br>";
        $SQL="Create TEMPORARY table IF NOT EXISTS temptable6 ignore( SELECT temptable2.*,temptable5.salesorder_salesorder_count FROM temptable2 LEFT JOIN temptable5 ON temptable2.salesordercf_cf_1082=temptable5.salesordercf_cf_1082);";
     $adb->query($SQL);
        // echo $SQL."</br>";
         
     $SQL="Create TEMPORARY table IF NOT EXISTS temptable7 ignore( SELECT * FROM temptable6 GROUP BY statistical_one);";
     $adb->query($SQL);
         //echo $SQL."</br>";
     $SQL="SELECT * FROM temptable6 union 
SELECT '' as statistical_one , '' as statistical_two, '' as salesorder_duedate,'' as products_productname,
'' as salesordercf_cf_1084,
'合计' as salesordercf_cf_1082,'' as salesorder_accountid, '' as 伙伴地址,'' as salesorder_salesorder_no, '' as salesorder_salesorder_no,
'' as 已收金额,'' as salesorder_PaymentBalance, '' as contactdetails_accountid,
'' as accountbillads_bill_street,'' as contactdetails_lastname, '' as contactdetails_salutation,'' as contactscf_cf_1088,
'' as contactdetails_title,'' as contactdetails_mobile,'' as contactdetails_pphone ,
'' as contactdetails_email,SUM(salesorder_salesorder_count) as salesorder_salesorder_count,'' as expense_total,'' as invoice_invoicetype,'' as invoice_invoicetype FROM temptable7;";
            //echo $SQL."</br>";  
        return $SQL;
    }
    
    static function getCourseparticipantsKPClist($where){
        //echo $where;
        global $adb;
     $SQL="Create TEMPORARY table IF NOT EXISTS temptable2 ignore(select ld_contactdetailsSalesOrder.contactid as statistical_field,  TIMESTAMPDIFF(DAY,ld_salesorder.duedate,IFNULL(ld_salesordercf.cf_1204,ld_salesorder.duedate))+1 as salesorder_duedate,t6.productname as products_productname,ld_salesordercf.cf_1084 as salesordercf_cf_1084,ld_salesordercf.cf_1082 as salesordercf_cf_1082,ld_accountSalesOrder.accountname as salesorder_accountid, 
	   concat(ld_accountSalesOrder.bill_state,' ',ld_accountSalesOrder.bill_city,' ',ld_accountSalesOrder.bill_street) as 伙伴地址,ld_salesorder.salesorder_no as salesorder_salesorder_no, 
       ifnull(ld_salesorder.total,0.00) as salesorder_salesordertotal,ifnull(t7.subtotal,0.00) as 已收金额,ifnull(ld_salesorder.total,0)-ifnull(t7.subtotal,0.00) as salesorder_PaymentBalance, 
       t12.accountname as contactdetails_accountid,concat(t12.bill_state,' ',t12.bill_city) as accountbillads_bill_street,ld_contactdetailsSalesOrder.lastname as contactdetails_lastname, 
       ld_contactdetailsSalesOrder.salutation as contactdetails_salutation,t10.cf_1088 as contactscf_cf_1088,ld_contactdetailsSalesOrder.title as contactdetails_title,ld_contactdetailsSalesOrder.mobile as contactdetails_mobile,ld_contactdetailsSalesOrder.phone as contactdetails_pphone 
        from ld_salesorder inner join 
     ld_salesordercf on ld_salesorder.salesorderid=ld_salesordercf.salesorderid inner join 
     ld_crmentity  on ld_salesorder.salesorderid=ld_crmentity.crmid inner join 
     ld_account as ld_accountSalesOrder on ld_salesorder.accountid=ld_accountSalesOrder.accountid inner join 
     (select id,productid from ld_salesorderdetail group by id) 
    as t5 on ld_salesorder.salesorderid=t5.id inner join 
     ld_products as t6 on t5.productid=t6.productid left outer join 
     (select salesorderid,sum(subtotal) as subtotal from ld_cashbill group by salesorderid) 
        as t7 on ld_salesorder.salesorderid=t7.salesorderid inner join 
		ld_contpotentialrel as t8 on t8.potentialid=ld_salesorder.potentialid inner join 
		ld_contactdetails as ld_contactdetailsSalesOrder on ld_contactdetailsSalesOrder.contactid=t8.contactid inner join 
		ld_contactscf as t10 on ld_contactdetailsSalesOrder.contactid=t10.contactid inner join 
		ld_account as t12 on t12.accountid=ld_contactdetailsSalesOrder.accountid 
        LEFT JOIN ld_potential as ld_potentialSalesOrder on ld_potentialSalesOrder.potentialid=t8.potentialid 
        left join ld_users as ld_UsersSalesOrder on ld_UsersSalesOrder.id=ld_SalesOrder.smownerid  
        where ld_salesorder.sostatus<>'已作废' and ld_salesorder.accountid=(SELECT accountid FROM ld_account WHERE accountname='上海嘉博管理咨询有限公司') and ld_SalesOrder.deleted=0 ".sprintf($where,'ld_SalesOrder')." ORDER BY contactdetails_lastname,ld_salesorder.duedate);";
    //echo $SQL."</br>";
    $adb->query($SQL);
    $SQL="Create TEMPORARY table IF NOT EXISTS temptable3 ignore(select count(1) as salesorder_salesorder_count,contactdetails_lastname,statistical_field from temptable2 GROUP BY statistical_field)";
    $adb->query($SQL);
      // echo $SQL."</br>";
    $SQL="SELECT * FROM temptable2 LEFT JOIN temptable3 on temptable3.statistical_field=temptable2.statistical_field";
         //echo $SQL."</br>";
        
        return $SQL;
    }
    
    static function getContactbusinesstable($where){
        //echo $where;
        global $adb;
     $SQL="Create TEMPORARY table IF NOT EXISTS temptable2 ignore(	SELECT
		ld_contactdetailsSalesOrder.lastname AS contactdetails_lastname,ld_contactdetailsSalesOrder.contactid as statistical_field,
		ld_salesorder.duedate AS salesorder_duedate,
		ifnull(
			ld_ExpenseSalesOrder.stotal,
			0.00
		) AS expense_total,
		t6.productname AS products_productname,
		ld_salesorder.signed_data AS salesorder_signed_data,
		ld_salesordercf.cf_1084 AS salesordercf_cf_1084,
		ld_salesordercf.cf_1082 AS salesordercf_cf_1082,
		ld_salesorder.salesorder_no AS salesorder_salesorder_no,
		ifnull(ld_salesorder.total, 0.00) AS salesorder_salesordertotal,
		ifnull(t7.subtotal, 0.00) AS salesorder_CashBillBalance,
		ifnull(ld_salesorder.total, 0) - ifnull(t7.subtotal, 0.00) AS salesorder_PaymentBalance,
		t12.accountname AS contactdetails_accountid,
		concat(
			t12.bill_state,
			' ',
			t12.bill_city
		) AS accountbillads_bill_street,
		ld_contactdetailsSalesOrder.salutation AS contactdetails_salutation,
		t6.productcategory AS product_productcategory,
		ld_Pot2contactscf.cf_1088 AS contactscf_cf_1088,
		ld_contactdetailsSalesOrder.title AS contactdetails_title,
		ld_contactdetailsSalesOrder.mobile AS contactdetails_mobile,
		ld_contactdetailsSalesOrder.phone AS contactdetails_pphone
	FROM
		ld_salesorder
	INNER JOIN ld_salesordercf ON ld_salesorder.salesorderid = ld_salesordercf.salesorderid
	INNER JOIN ld_crmentity ON ld_salesorder.salesorderid = ld_crmentity.crmid
	INNER JOIN ld_account AS ld_accountSalesOrder ON ld_salesorder.accountid = ld_accountSalesOrder.accountid
	INNER JOIN (
		SELECT
			id,
			productid
		FROM
			ld_salesorderdetail
		GROUP BY
			id
	) AS t5 ON ld_salesorder.salesorderid = t5.id
	INNER JOIN ld_products AS t6 ON t5.productid = t6.productid
	LEFT OUTER JOIN (
		SELECT
			entitytypeid,
			sum(amount) AS subtotal
		FROM
			ld_cashbill2paymentplan
		GROUP BY
			entitytypeid
	) AS t7 ON ld_salesorder.salesorderid = t7.entitytypeid
	left JOIN ld_contactdetails AS ld_contactdetailsSalesOrder ON ld_contactdetailsSalesOrder.contactid = ld_salesorder.contactid
	INNER JOIN ld_contpotentialrel AS t8 ON t8.potentialid = ld_salesorder.potentialid
	
	INNER JOIN ld_account AS t12 ON t12.accountid = ld_contactdetailsSalesOrder.accountid
	
	LEFT JOIN ld_potential AS ld_potentialSalesOrder ON ld_potentialSalesOrder.potentialid = t8.potentialid
    LEFT JOIN ld_contactscf as ld_Pot2contactscf  ON ld_Pot2contactscf.contactid=t8.contactid
	LEFT JOIN ld_users AS ld_UsersSalesOrder ON ld_UsersSalesOrder.id = ld_SalesOrder.smownerid
	LEFT JOIN (
		SELECT
			SUM(total) AS stotal,
			ld_commission2payment.entitytypeid
		FROM
			ld_Commission 
		LEFT JOIN ld_commission2payment ON ld_commission.commission_id=ld_commission2payment.commission_id 
        WHERE ld_Commission.deleted=0 
		GROUP BY
			ld_commission2payment.entitytypeid
	) AS ld_ExpenseSalesOrder ON ld_ExpenseSalesOrder.entitytypeid = ld_salesorder.salesorderid Where 1=1 ".sprintf($where,'ld_SalesOrder')." 
    ORDER BY contactdetails_lastname,ld_contactdetailsSalesOrder.contactid,ld_salesorder.duedate);";
    //echo $SQL."</br>";
    $adb->query($SQL);
    /*
    $SQL="Create TEMPORARY table IF NOT EXISTS temptable3 ignore (
	SELECT
		count(contactdetails_lastname) as salesorder_salesorder_count,
		contactdetails_lastname,
		statistical_field
	FROM
		temptable2
	WHERE
		contactscf_cf_1088 = '课程学员'
	GROUP BY
		statistical_field,salesorder_salesorder_no);";
    $adb->query($SQL);
    */
   //echo $SQL."</br>";
    $SQL="Create TEMPORARY table IF NOT EXISTS temptable4 ignore (
	SELECT
		temptable2.*,ifnull(count(contactdetails_lastname),'')  as salesorder_salesorder_count
	FROM
		temptable2
	where
		contactscf_cf_1088 = '课程学员'
	GROUP BY
		temptable2.salesorder_salesorder_no
	order by
		contactdetails_lastname,salesorder_duedate);";
  //echo $SQL."</br>";
    $adb->query($SQL);
    $SQL="CREATE TEMPORARY TABLE IF NOT EXISTS temptable5 IGNORE (
	SELECT
		concat(
			contactdetails_lastname,
			' :小计'
		) AS contactdetails_lastname,
        '' statistical_field,
		'' AS salesorder_duedate,
		SUM(expense_total) AS expense_total,
		'' AS products_productname,
		'' AS salesorder_signed_data,
		'' AS salesordercf_cf_1084,
		'' salesordercf_cf_1082,
		'' AS salesorder_salesorder_no,
		SUM(salesorder_salesordertotal) AS salesorder_salesordertotal,
		SUM(salesorder_CashBillBalance) salesorder_CashBillBalance,
		SUM(salesorder_PaymentBalance) AS salesorder_PaymentBalance,
		'' AS contactdetails_accountid,
		'' AS accountbillads_bill_street,
		'' AS contactdetails_salutation,
		'' AS product_productcategory,
		'' AS contactscf_cf_1088,
		'' AS contactdetails_title,
		'' AS contactdetails_mobile,
		'' AS contactdetails_pphone,
		SUM(salesorder_salesorder_count) AS salesorder_salesorder_count
	FROM
		temptable4
	GROUP BY
		statistical_field
);";
    //echo $SQL."</br>"; 
    $adb->query($SQL);
        $SQL="Create TEMPORARY table IF NOT EXISTS temptable6 ignore ( 
                select * from (
                select * from temptable4 
                union 
                select * from temptable5 
                order by CONV(HEX(left(CONVERT(contactdetails_lastname USING gbk),1)),16,10),
                      CONV(HEX(left(CONVERT(contactdetails_accountid USING gbk),1)),16,10) desc,salesorder_duedate desc
                ) as temp);";
    $adb->query($SQL);
    //echo $SQL."</br>"; 
    $SQL="SELECT * FROM temptable6 union SELECT '合计' as contactdetails_lastname,'' statistical_field ,'' as salesorder_duedate, SUM(expense_total) as expense_total,'' as products_productname,
    '' as salesorder_signed_data, '' as salesordercf_cf_1084,'' salesordercf_cf_1082,'' as salesorder_salesorder_no,
    SUM(salesorder_salesordertotal) as salesorder_salesordertotal, SUM(salesorder_CashBillBalance) salesorder_CashBillBalance,
    SUM(salesorder_PaymentBalance) as salesorder_PaymentBalance, '' as contactdetails_accountid,
    '' as accountbillads_bill_street,'' as contactdetails_salutation,'' as product_productcategory, 
    '' as contactscf_cf_1088,'' as contactdetails_title,'' as contactdetails_mobile,'' as contactdetails_pphone,
    SUM(salesorder_salesorder_count) as salesorder_salesorder_count FROM temptable4;";
    //echo $SQL."</br>";  
        return $SQL;
    }
    static function generateAdvFilterSql($advfilterlist,$reportabid) {

		global $adb;
        $reportabname=getTabname($reportabid);
		$advfiltersql = "";
       // print_r($advfilterlist);
       $gcount=0;
		foreach($advfilterlist as $groupindex => $groupinfo)
         {
			$groupcondition = $groupinfo['condition'];
			$groupcolumns = $groupinfo['columns'];

			if(count($groupcolumns) > 0) 
            {

				$advfiltergroupsql = "";

				foreach($groupcolumns as $columnindex => $columninfo) 
                {
                    
					$fieldcolname = $columninfo["columnname"];
					$comparator = $columninfo["comparator"];
					$value = $columninfo["value"];
					$columncondition = $columninfo["column_condition"];
                    $fields=explode(":",$fieldcolname);
                    $sql='select uitype,fieldlabel,tablename,columnname from ld_field where columnname=? and tabid=?';
                    $fieldresult=$adb->pquery($sql,array($fields[1],$reportabid));  
                    if($adb->num_rows($fieldresult)>0)
                    {
                        $uitype=$adb->query_result($fieldresult,0,'uitype');
                        $tablename=$adb->query_result($fieldresult,0,'tablename');
                        $columnname=$adb->query_result($fieldresult,0,'columnname');
                        $reportabname = strtolower($reportabname);
                        
                        switch($uitype)
                        {
                            case 57:
                                $tablename='ld_contactdetails'.$reportabname;
                                $columnname='lastname';
                                break;
                            case 53:
                            case 52:
                                $tablename='ld_Users'.$reportabname;
                                $columnname='last_name';
                                break;
                            case 73:
                                $tablename='ld_account'.$reportabname;
                                $columnname='accountname';
                                break;
                            case 78:
                                $tablename='ld_quotes'.$reportabname;
                                $columnname='quote_no';
                                break;
                            case 76:
                                $tablename='ld_potential'.$reportabname;
                                $columnname='potential_no';
                                break;
                            case 80:
                            case 200:
                                $tablename='ld_salesorder'.$reportabname;
                                $columnname='salesorder_no';
                                break;
                            case 150:
                                $tablename='ld_purchaseorder'.$reportabname;
                                $columnname='purchaseorder_no';
                                break; 
                        }
                        if($reportabname=='cashbill'&&$uitype==202){
                            $tablename='ld_cashbill2paymentplan';
                            $columnname='ordery_no';
                            //$advfiltersql = "( ld_cashbill2paymentplan.subject like '%%$value%%')";
                        }
                        $advComparator=ReportSQL::getAdvComparator($comparator,$value);
                        if($columnname=='vendorid'){
                            $columnname='vendorname';
                            $tablename='ld_vendor';
                        }
                        if($comparator=='isnull'){
                            $isnullwhere=$tablename.'.'.$columnname.' IS NULL ';
                            if($gcount!=0)$count=' and ';
                            $advfiltersql.=' '.$count.$tablename.'.'.$columnname.$advComparator.' or '.$isnullwhere.$columncondition.' ';
                        }else{
                            if($gcount!=0)$count=' and ';
                           $advfiltersql.=' '.$count.$tablename.'.'.$columnname.$advComparator.' '.$isnullwhere.$columncondition.' '; 
                        }
                         
                    }
			     }
                
            }
            if($groupcondition!="")
            {
                $advfiltersql='( '.$advfiltersql.' ) '.$groupcondition;
            }
             
             
          $gcount++;   
		}
        
        //echo $advfiltersql;
		if (trim($advfiltersql) != "") $advfiltersql = '('.$advfiltersql.')';

		return $advfiltersql;
	}
    
    static function getAdvComparator($comparator,$value,$datatype="")
	{

		global $adb,$default_charset,$ogReport;
		$value=html_entity_decode(trim($value),ENT_QUOTES,$default_charset);
		$value_len = strlen($value);
		$is_field = false;
		if($value_len > 1 && $value[0]=='$' && $value[$value_len-1]=='$'){
			$temp = str_replace('$','',$value);
			$is_field = true;
		}
		if($datatype=='C'){
			$value = str_replace("yes","1",str_replace("no","0",$value));
		}

		if($is_field==true){
		//	$value = $this->getFilterComparedField($temp);
		}
		if($comparator == "e")
		{
			if(trim($value) == "NULL")
			{
				$rtvalue = " is NULL";
			}elseif(trim($value) != "")
			{
				$rtvalue = " = ".$adb->quote($value);
			}elseif(trim($value) == "" && $datatype == "V")
			{
				$rtvalue = " = ".$adb->quote($value);
			}else
			{
				$rtvalue = " is NULL";
			}
		}
		if($comparator == "n")
		{
			if(trim($value) == "NULL")
			{
				$rtvalue = " is NOT NULL";
			}elseif(trim($value) != "")
			{
				$rtvalue = " <> ".$adb->quote($value);
			}elseif(trim($value) == "" && $datatype == "V")
			{
				$rtvalue = " <> ".$adb->quote($value);
			}else
			{
				$rtvalue = " is NOT NULL";
			}
		}
		if($comparator == "s")
		{
			$rtvalue = " like '". formatForSqlLike($value, 2,$is_field) ."%'";
		}
		if($comparator == "ew")
		{
			$rtvalue = " like '%". formatForSqlLike($value, 1,$is_field) ."'";
		}
		if($comparator == "c")
		{
			$rtvalue = " like '%". formatForSqlLike($value,0,$is_field) ."%'";
		}
		if($comparator == "k")
		{
			$rtvalue = " not like '%". formatForSqlLike($value,0,$is_field) ."%'";
		}
		if($comparator == "l")
		{
			$rtvalue = " < ".$adb->quote($value);
		}
		if($comparator == "g")
		{
			$rtvalue = " > ".$adb->quote($value);
		}
		if($comparator == "m")
		{
			$rtvalue = " <= ".$adb->quote($value);
		}
		if($comparator == "h")
		{
			$rtvalue = " >= ".$adb->quote($value);
		}
		if($comparator == "b") {
			$rtvalue = " < ".$adb->quote($value);
		}
		if($comparator == "a") {
			$rtvalue = " > ".$adb->quote($value);
		}
		if($comparator == "isnull") {
			$rtvalue = " = ".$adb->quote($value);
		}
		if($comparator == "isnotnull") {
			$rtvalue = " <> ".$adb->quote($value);
		}
		if($is_field==true){
			$rtvalue = str_replace("'","",$rtvalue);
			$rtvalue = str_replace("\\","",$rtvalue);
		}
	
		return $rtvalue;
	}
    
     static function isReferenceUIType($uitype) 
     {
    	static $options = array('101', '116', '117', '26', '357',
    		'50', '51', '52', '53', '57', '58', '59', '66', '68',
    		'73', '75', '76', '77', '78', '80', '81'
    	);
    
    	if(in_array($uitype, $options)) {
    		return true;
    	}
    	return false;
    }
    
    
    static function getSalesOrderImplementation($where)
    {
        global $adb;
      
        /*
        where ld_salesorder.salesorderid > 0 and ld_crmentity.deleted=0 and ld_salesorder.sostatus<>'已作废' ".$where."
        order by ld_salesorder.salesorderid desc
        );";*/
        $SQL="create TEMPORARY table if not EXISTS `temptable` IGNORE (
        select case when ld_accountscf.cf_1100 = '' then '空' when ld_accountscf.cf_1100 is null then '空' else ld_accountscf.cf_1100 end as cf_1100,
        ld_salesorder.subject as salesorer_num,ld_account.accountname,
        ld_salesorder.signed_data,ld_userssmowner.last_name,ld_salesorder.total,(ld_salesorder.total-ld_salesorderexpense.expense_total) as salesorder_retotal,
        ld_salesordercf.cf_1081,
        productinfos.product1,productinfos.product2,productinfos.product3,productinfos.product4,productinfos.productother,
        productinfos.product5A,productinfos.product5B,productinfos.product6A,productinfos.product6B,
        ld_account.industry,ld_accountscf.accountproperty,ld_salesordercf.cf_1085,ld_salesorder.duedate,
        ld_salesordercashbill.cashbill_total,(ld_salesorder.total-ld_salesordercashbill.cashbill_total) as noncashbill_total,
        case when (ld_salesorder.total-ld_salesorderexpense.expense_total)>0 then '未清' else '已清' end as contract_status,
        ld_crmentity.description,ld_salesordercf.cf_1091,
        ld_PaymentPlanFirst.firstamount,(ld_PaymentPlanFirst.firstamount/ld_salesorder.total)*100 as firstproportion,ld_PaymentPlanFirst.firstplandate,
        ld_PaymentPlanSecond.secondamount,(ld_PaymentPlanSecond.secondamount/ld_salesorder.total)*100 as secondproportion,ld_PaymentPlanSecond.secondplandate,
        ld_PaymentPlanThird.thirdamount,(ld_PaymentPlanThird.thirdamount/ld_salesorder.total)*100 as thirdproportion,ld_PaymentPlanThird.thirdplandate,
        ld_PaymentPlanFourth.fourthamount,(ld_PaymentPlanFourth.fourthamount/ld_salesorder.total)*100 as fourthproportion,ld_PaymentPlanFourth.fourthplandate
        from ld_salesorder inner join ld_crmentity on ld_crmentity.crmid=ld_salesorder.salesorderid 
        left join ld_salesordercf on ld_salesorder.salesorderid = ld_salesordercf.salesorderid 
        left join ld_account on ld_salesorder.accountid = ld_account.accountid
        left join ld_accountscf on ld_accountscf.accountid = ld_account.accountid
        left join ld_users as ld_userssmowner on ld_crmentity.smownerid = ld_userssmowner.id 
        left join (select ld_salesorder.salesorderid,case when SUM(ld_expense.total) is null then 0 else SUM(ld_expense.total) end as expense_total 
        from ld_salesorder left join ld_expense on ld_salesorder.salesorderid = ld_expense.Salesorderid 
        group by ld_salesorder.salesorderid) as ld_salesorderexpense on ld_salesorder.salesorderid = ld_salesorderexpense.Salesorderid 
        left join (select ld_salesorder.salesorderid,case when SUM(ld_cashbill.total) is null then 0 else SUM(ld_cashbill.total) end as cashbill_total 
        from ld_salesorder left join ld_cashbill on ld_salesorder.salesorderid = ld_cashbill.Salesorderid 
        group by ld_salesorder.salesorderid) as ld_salesordercashbill on ld_salesorder.salesorderid = ld_salesordercashbill.Salesorderid 
        left join (select productinfo.salesorderid,
        SUM(case when productinfo.productname = '家具' then productinfo.quantity*productinfo.listprice else 0 end )as product1,
        SUM(case when productinfo.productname = '排风' then productinfo.quantity*productinfo.listprice else 0 end )as product2,
        SUM(case when productinfo.productname = 'VAV' then productinfo.quantity*productinfo.listprice else 0 end )as product3,
        SUM(case when productinfo.productname = '气路' then productinfo.quantity*productinfo.listprice else 0 end )as product4,
        SUM(case when productinfo.productname = '通风柜THCHLAB' then productinfo.quantity else 0 end )as product5A,
        SUM(case when productinfo.productname = '通风柜THCHLAB' then productinfo.listprice else 0 end )as product5B,
        SUM(case when productinfo.productname = '通风柜machaire' then productinfo.quantity else 0 end )as product6A,
        SUM(case when productinfo.productname = '通风柜machaire' then productinfo.listprice else 0 end )as product6B,
        SUM(case when productinfo.productname not in ('家具','排风','VAV','气路','通风柜THCHLAB''通风柜machaire') 
         then productinfo.quantity*productinfo.listprice else 0 end )as productother
        from (select ld_products.productname,ld_salesorderdetail.quantity,
        ld_salesorderdetail.listprice,ld_salesorder.salesorderid 
        from ld_salesorderdetail 
        left join ld_Products on ld_salesorderdetail.productid = ld_products.productid
        left join ld_salesorder on ld_salesorder.salesorderid = ld_salesorderdetail.id) as productinfo
        group by productinfo.salesorderid) as productinfos on ld_salesorder.salesorderid = productinfos.salesorderid 
        left join (select salesorderid,amount as firstamount,plandate as firstplandate from ld_PaymentPlan where Periodtime = 1 GROUP BY salesorderid) 
        as ld_PaymentPlanFirst on ld_salesorder.salesorderid = ld_PaymentPlanFirst.salesorderid 
        left join (select salesorderid,amount as secondamount,plandate as secondplandate from ld_PaymentPlan where Periodtime = 2 GROUP BY salesorderid) 
        as ld_PaymentPlanSecond on ld_salesorder.salesorderid = ld_PaymentPlanSecond.salesorderid 
        left join (select salesorderid,amount as thirdamount,plandate as thirdplandate from ld_PaymentPlan where Periodtime = 3 GROUP BY salesorderid) 
        as ld_PaymentPlanThird on ld_salesorder.salesorderid = ld_PaymentPlanThird.salesorderid 
        left join (select salesorderid,amount as fourthamount,plandate as fourthplandate from ld_PaymentPlan where Periodtime = 4 GROUP BY salesorderid) 
        as ld_PaymentPlanFourth on ld_salesorder.salesorderid = ld_PaymentPlanFourth.salesorderid 
        where ld_salesorder.salesorderid > 0 and ld_crmentity.deleted=0 and ld_salesorder.sostatus<>'已作废' ".$where." 
        order by ld_salesorder.salesorderid desc
        );";
        $adb->query($SQL);
        
        $SQL=" select cf_1100 as accountscf_cf_1100,salesorer_num as SalesOrder_subject,accountname as account_accountname,
        signed_data as SalesOrder_signed_data,last_name as SalesOrder_smownerid,total as SalesOrder_Total,
        salesorder_retotal as OftenUseReport_SalesOrderRetotal,cf_1081 as salesorderscf_cf_1081,
        product1 as OftenUseReport_product1,product2 as OftenUseReport_product2,product3 as OftenUseReport_product3,
        product4 as OftenUseReport_product4,productother as OftenUseReport_productother,
        product5A as OftenUseReport_product5A,product5B as OftenUseReport_product5B,
        product6A as OftenUseReport_product6A,product6B as OftenUseReport_product6B,
        industry as account_industry,accountproperty as accountscf_accountproperty,cf_1085 as accountscf_cf_1085,
        duedate as SalesOrder_duedate,cashbill_total as OftenUseReport_cashbill_total,noncashbill_total as OftenUseReport_noncashbill_total,
        contract_status as OftenUseReport_contract_status,description as SalesOrder_description,cf_1091 as salesorderscf_cf_1091,
        firstamount as OftenUseReport_firstamount,firstproportion as OftenUseReport_firstproportion,firstplandate as OftenUseReport_firstplandate,
        secondamount as OftenUseReport_secondamount,secondproportion as OftenUseReport_secondproportion,duedate as OftenUseReport_duedate,secondplandate as OftenUseReport_secondplandate,
        thirdamount as OftenUseReport_thirdamount,thirdproportion as OftenUseReport_thirdproportion,thirdplandate as OftenUseReport_thirdplandate,
        fourthamount as OftenUseReport_fourthamount,fourthproportion as OftenUseReport_fourthproportion,fourthplandate as OftenUseReport_fourthplandate
        
        from temptable ";
       
        return $SQL;
    }
    
    
 
    // Edit by luyx 2016-09-12
    // Reason: 收款业绩统计表算法修改
            //1.费用和佣金统计期间内数据 
            //2.产品成本如果是第一次收款计算，否则不计算产品成本 
            //3.期间内没有收款的费用和佣金Union进来
            //4.若期间同一合同有多次收款，费用和佣金仅扣减在第一次
    
    static function getPerformancestatisticscollection($where,$startdate,$enddate,$userids,$accountname)
    {
		if($_REQUEST['basicotherfindsapp']&&$_REQUEST['basicotherfindsapp'] == 'true'){
			$where_expense =" and a.approvestatus='".constant('D_A_S_APPROVED')."'";
			$where_commission =" and a.approvestatus='".constant('D_A_S_APPROVED')."'";
		}
        //Edit by luyx 2017-04-18
        $check_cashbill = ReportSQL::getCashBillApproveWhere();	//已收金额计算时是否统计未批准的收款单  0 是 1 否
        //echo $check_cashbill;
               
        global $adb;

        // @edit:dong @date:2020/08/10 @reason: bug0041038 报表>常用报表>收款业绩统计表：显示列能否增加“收款方式”字 字段名称paymentmethod
        $dateperid=' between  \''.$startdate.'\' and \''.$enddate.'\'';
        if(empty($accountname)==true){
            $name_account='';                
        }else{
            $name_account=" AND ld_account.accountname like '%".$accountname."%'";
        };

        //zxm 2022-0328 合同跟踪表  合同类型条件
        $contracttype_str = '';
        $contracttype_arr = [];
        $servicecontract_contracttype_select = $_REQUEST['servicecontract_contracttype_select'];
        if(!empty($servicecontract_contracttype_select)&&$servicecontract_contracttype_select!='null'&&$servicecontract_contracttype_select!='undefined'){
            $contracttype_arr[] = $servicecontract_contracttype_select;
        }
        $salesorder_contracttype_select = $_REQUEST['salesorder_contracttype_select'];
        if(!empty($salesorder_contracttype_select)&&$salesorder_contracttype_select!='null'&&$salesorder_contracttype_select!='undefined'){
            $contracttype_arr[] = $salesorder_contracttype_select;
        }
        if(!empty($contracttype_arr)){
            $contracttype_str = ' where find_in_set(b.contracttype,"'.  implode(',',$contracttype_arr).'")';
        }
        //echo '$userids='.$userids."</br>";
        //echo "$dateperid=".$dateperid."</br>";
        //echo '$name_account='.$name_account."</br>";
    
        
        /*
         if(strpos($where, 'in (')!==false){        
            $str1=str_replace('ld_account.accountname','Accounts_accountname',substr($where,strpos($where, 'in')));
            //echo $str1.'<br/>';
        }else{
            $str1=str_replace('ld_account.accountname','Accounts_accountname',substr($where,strpos($where, '=')));
            //echo $str1.'<br/>';
        }
        
        $where_smowner = 'WHERE CashBill_smownerid '.$str1;
        
        
        $newstr = substr($where,0,1);
        if($newstr =='('){
            $where=' And '.str_replace("ld_accountcashbill","ld_account",$where);
            //Liver 将ld_accountcashbill替换为ld_account,为高级查找前面加上and
        }
        
        */
        
    //$vw_cashbilldetail1：收款明细信息：如果收款单有调整，计在收款分录中第一条记录上        
    $vw_cashbilldetail1="(
        SELECT
        	cashbillid,
        	sum(amount) AS amount,
        	entitytype,
        	entitytypeid,
        	description
        FROM (
        	SELECT
        		a.smownerid,
        		a.cashbillid,
        		a.cashbill_no,
        		a.cashbilldate,
        		a.accountid,
        		a.currency_symbol,
        		a.conversion_rate,
        		CASE 
        			WHEN b.entitytype='PaymentPlan' THEN
        				(SELECT entitytype FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
        			ELSE b.entitytype
        		END AS entitytype,
        		CASE 
        			WHEN b.entitytype='PaymentPlan' THEN
        				(SELECT entitytypeid FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
        			ELSE b.entitytypeid
        		END AS entitytypeid,
        		CASE
        			WHEN b.CashBillID>0 THEN  b.amount
        			ELSE a.Total
        		END AS amount,
        		a.description
        	FROM ld_cashbill a
        	LEFT JOIN ld_cashbill2paymentplan b ON a.cashbillid = b.CashBillID
        	WHERE a.deleted=0 $check_cashbill 
 	            AND ifnull(a.approvestatus,'') <> '已拒绝'
        		AND a.cashbilldate $dateperid 
        		AND a.smownerid in ($userids)
        ) a
        GROUP BY cashbillid,entitytypeid)"; 
    
      
    //$vw_cashbilldetail2：收款明细情况
    //如果源单类型是回款计划则entitytypeid取对应的订单id，如果不是回款计划则直接取对应订单的id
    $vw_cashbilldetail2="(
        SELECT
        	a.smownerid,
        	d.last_name,
            d.wx_userid as report_wx_userid,
			ld_group.groupname,
            ld_group.groupid as report_wx_groupid,
        	e.last_name AS creator,
        	a.cashbill_no,
        	CASE 
        		WHEN b.entitytype='PaymentPlan' THEN
        			(SELECT entitytype FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
        		ELSE b.entitytype
        	END AS entitytype,
        	CASE 
        		WHEN b.entitytype='PaymentPlan' THEN
        			(SELECT entitytypeid FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
        		ELSE b.entitytypeid
        	END AS entitytypeid,
        	a.currency_id,
        	a.currency_symbol,
        	a.conversion_rate,
        	b.amount,
        	a.cashbilldate,
        	ld_account.accountname,
        	a.accountid,
        	a.description,
        	a.paymentmethod,
        	a.cashbillid
        FROM ld_cashbill a
        LEFT JOIN $vw_cashbilldetail1 b ON a.cashbillid=b.CashBillID
        LEFT JOIN ld_account ON ld_account.accountid=a.accountid
        LEFT JOIN ld_users d ON d.id=a.smownerid
        LEFT JOIN ld_users e ON e.id=a.smcreatorid
		LEFT JOIN (
			select GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid asc ) as groupname,
            GROUP_CONCAT(ld_groups.groupid order by ld_groups.groupid asc ) as groupid,
            ld_users2group.userid from ld_users2group
			LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
			GROUP BY ld_users2group.userid
		) as ld_group on ld_group.userid = a.smownerid
        WHERE a.deleted=0 $name_account $check_cashbill 
            AND a.cashbilldate $dateperid 
           	AND ifnull(a.approvestatus,'') <> '已拒绝'
            AND a.smownerid in ($userids)            
        )";
    //echo "SQL=<br/>".$vw_cashbilldetail2."<br/>";  
       
    //$vw_cashbilldetail3：收款明细数据整理
    //如果同一个收款单多条分录关联了同一个源单（回款计划转化为对应合同），按照源单汇总统计。
    $vw_cashbilldetail3="(
        SELECT
        	smownerid,
        	last_name,
            report_wx_userid,
			groupname,
            report_wx_groupid,
            
        	creator,
        	cashbill_no,
        	entitytype,
        	entitytypeid,
        	currency_id,
        	currency_symbol,
        	conversion_rate,
        	sum(ifnull(amount,0)) AS amount,
        	cashbilldate,
        	accountname,
        	accountid,
        	description,
        	paymentmethod,
        	cashbillid
        FROM $vw_cashbilldetail2 a
        GROUP BY cashbillid,entitytypeid)";

    //$vw_cashbilldetail:收款业绩统计，包括对应源单、费用、佣金、产品成本等信息
    $vw_cashbilldetail="(
        SELECT
        	1 AS report_seq,
            1 AS report_seq2,
        	a.last_name AS statistical_one,
            a.report_wx_userid,
        	a.cashbill_no AS statistical_two,
        	b.order_no AS statistical_three,
        	a.last_name AS OftenUseReport_lastname,
        	a.last_name AS OftenUseReport_lastname2,
			a.groupname AS OftenUseReport_groupname,
            a.report_wx_groupid,
        	a.creator AS OftenUseReport_lastname3,
        	a.cashbill_no AS CashBill_cashbill_no,
        	a.cashbilldate AS CashBill_cashbilldate,
        	IFNULL(b.received_amount,0)/(IFNULL(b.conversion_rate,1)) OftenUseReport_Atotal,
        	a.currency_id AS CashBill_Curid,
        	a.conversion_rate AS CashBill_Rate,
        	a.currency_symbol AS CashBill_Symbol,
        	a.accountname AS Accounts_accountname,
        	a.accountid AS Accounts_accountid,
        	b.`subject` AS SalesOrder_subject,
        	b.currency_id AS SalesOrder_Curid,
        	b.conversion_rate AS SalesOrder_Rate,
        	b.currency_symbol AS SalesOrder_Symbol,
        	e.currency_id AS Expense_Curid,
        	e.conversion_rate AS Expense_Rate,
        	e.currency_symbol AS Expense_Symbol,
        	d.currency_id AS Comm_Curid,
        	d.conversion_rate AS Comm_Rate,
        	d.currency_symbol AS Comm_Symbol,
        	b.order_no AS OftenUseReport_salesorder_no,
        	b.contracttype AS OftenUseReport_contracttype,
        	IFNULL(b.total,0) AS OftenUseReport_ssubtotal,
        	a.amount AS OftenUseReport_pamount,
        	CASE
        		WHEN f.first_cashid=a.cashbillid THEN ROUND(IFNULL(g.productcost/IFNULL(b.conversion_rate,1),0),2)
        		ELSE 0
        	END AS OftenUseReport_productcost,
        	CASE
        		WHEN j.peridmin_cashid=a.cashbillid THEN IFNULL(e.fytotal,0)
        		ELSE 0
        	END AS OftenUseReport_etotal,
        	CASE
        		WHEN j.peridmin_cashid=a.cashbillid THEN 
        			a.amount/IFNULL(a.conversion_rate,1)-IF(f.first_cashid=a.cashbillid,IFNULL(g.productcost/IFNULL(b.conversion_rate,1),0),0)-IFNULL(e.fytotal,0)-IFNULL(d.yjtotal,0)
        		ELSE a.amount
        	END AS OftenUseReport_productgp,
        	c.product_no AS Products_product_no,
        	c.productname AS Products_productname,
        	c.productsheet AS Products_productsheet,
        	c.usageunit AS Products_usageunit,
        	IFNULL(c.unit_price,0) AS Products_unit_price,
        	CASE
        		WHEN j.peridmin_cashid=a.cashbillid THEN IFNULL(d.yjtotal,0)
        		ELSE 0
        	END AS OftenUseReport_CommissionTotal,
        	c.quantity AS OftenUseReport_quantity,
        	CASE
        		WHEN f.first_cashid=a.cashbillid THEN ROUND(IFNULL(c.productcost/IFNULL(b.conversion_rate,1),0),2)
        		ELSE 0
        	END AS Products_costprice,
        	c.discount_amount/(IFNULL(b.conversion_rate,1)) AS OftenUseReport_discountamount,
        	a.smownerid AS CashBill_smownerid,
        	a.entitytypeid AS CashBill_salesorderid,
        	a.description AS CashBill_description,
        	a.paymentmethod AS CashBill_paymentmethod,
        	a.cashbillid AS LBL_ACTION,
        	b.order_id
        FROM $vw_cashbilldetail3 a
        LEFT JOIN (
        	SELECT salesorderid AS order_id,currency_id,conversion_rate,currency_symbol,total,received_amount,`subject`,salesorder_no AS order_no,contracttype  FROM ld_salesorder
        	UNION ALL 
        	SELECT servicecontractsid,currency_id,conversion_rate,currency_symbol,total,received_amount,`subject`,contract_no,contract_type as contracttype FROM ld_servicecontracts
        	UNION ALL 
        	SELECT invoiceid,currency_id,conversion_rate,currency_symbol,total,received_amount,`subject`,invoice_no,'' as contracttype FROM ld_invoice
        	UNION ALL 
        	SELECT out_id,currency_id,conversion_rate,currency_symbol,total,received_amount,'',out_no,'' as contracttype FROM ld_outboundorder
        ) b ON a.entitytypeid=b.order_id
        LEFT JOIN (
       
            	select tmpdetailinfo.id,
                ld_products.productname,
                ld_products.product_no,
                ld_products.productsheet,
                ld_products.usageunit,
                ld_products.unit_price,
                tmpdetailinfo.quantity,
                CASE
                    				WHEN EXISTS (SELECT 1 FROM ld_version WHERE trade='puyoung' AND account='lingdang') THEN
                    					IF((ifnull(tmpdetailinfo.productcost,0)=0),ifnull(ld_products.costprice,0),tmpdetailinfo.productcost)
                    				ELSE
                    					tmpdetailinfo.quantity*IF((ifnull(tmpdetailinfo.productcost,0)=0),ifnull(ld_products.costprice,0),tmpdetailinfo.productcost) 
                    END AS productcost,
                 tmpdetailinfo.discount_amount 
                 from 
                (
                    select id,quantity,productcost,discount_amount,productid,lineitem_id from ld_invoicedetail      
                    union ALL
                    select id,quantity,productcost,discount_amount,productid,lineitem_id from ld_outboundorderdetail 
                    union ALL
                    select id,quantity,productcost,discount_amount,productid,lineitem_id from ld_servicecontractsdetail   
                    union ALL
                    select id,quantity,productcost,discount_amount,productid,lineitem_id from ld_salesorderdetail 
                ) as tmpdetailinfo 
                	 
                LEFT JOIN ld_products   on ld_products.productid=tmpdetailinfo.productid
                GROUP BY tmpdetailinfo.id,ld_products.productid,tmpdetailinfo.lineitem_id

        ) c ON c.id=b.order_id
        LEFT JOIN (
        	SELECT
        		a.currency_id,
        		a.currency_symbol,
        		a.conversion_rate,
        		b.entitytypeid,
        		sum(b.amount/ifnull(a.conversion_rate,1)) AS yjtotal
        	FROM
        		ld_commission a
        	LEFT JOIN ld_commission2payment b ON a.commission_id = b.commission_id
        	LEFT JOIN ld_commission2paymentscf c ON c.commission2payment_id = b.commission2payment_id
        	WHERE a.deleted = 0 $where_commission 
                AND a.expensedate $dateperid
                AND b.entitytypeid > 0
        		AND ifnull(a.approvestatus,'') <> '已拒绝'
        	GROUP BY b.entitytypeid
        ) d ON d.entitytypeid=b.order_id
        LEFT JOIN (
        	SELECT
        		b.entitytypeid,
        		c.currency_id,
        		c.conversion_rate,
        		c.currency_symbol,
        		sum(c.rmb_total) AS fytotal
        	FROM
        		ld_expense a 
        	LEFT JOIN ld_expensedetail b ON a.expenseid = b.expenseid
        	LEFT JOIN ld_expensedetailscf c ON c.expensedetailid = b.expensedetailid
        	WHERE a.deleted = 0 $where_expense
                AND a.expensedate $dateperid
                AND b.entitytypeid > 0
        		AND ifnull(a.approvestatus,'') <> '已拒绝'
        	GROUP BY b.entitytypeid
        ) e ON e.entitytypeid=b.order_id
        LEFT JOIN (
			SELECT
				entitytypeid,
				cashbillid AS first_cashid
			FROM (
				SELECT
					a.cashbillid,
					a.cashbilldate,
					CASE 
                        WHEN b.entitytype='PaymentPlan' THEN
                            (SELECT entitytypeid FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
                        ELSE b.entitytypeid
                    END AS entitytypeid
				FROM ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b ON a.cashbillid=b.CashBillID
				WHERE a.deleted=0 $check_cashbill
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
					AND b.entitytypeid>0
					ORDER BY a.cashbilldate,a.cashbillid
			) a GROUP BY entitytypeid      
    	) f ON f.entitytypeid=b.order_id      
 		LEFT JOIN (
			SELECT
				entitytypeid,
				cashbillid AS peridmin_cashid
			FROM (
				SELECT
					a.cashbillid,
					a.cashbilldate,
					CASE 
                        WHEN b.entitytype='PaymentPlan' THEN
                            (SELECT entitytypeid FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
                        ELSE b.entitytypeid
                    END AS entitytypeid
				FROM ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b ON a.cashbillid=b.CashBillID
				WHERE a.deleted=0 $check_cashbill
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
					AND b.entitytypeid>0
					AND a.cashbilldate $dateperid
					ORDER BY a.cashbilldate,a.cashbillid
			) a GROUP BY entitytypeid
		) j ON j.entitytypeid=b.order_id       
        LEFT JOIN (
            SELECT 
                tmpdetailinfo.id AS order_id,
                CASE
                    WHEN EXISTS (SELECT 1 FROM ld_version WHERE trade='puyoung' AND account='lingdang') THEN
                        SUM(1*IF((ifnull(tmpdetailinfo.productcost,0)=0),ifnull(ld_products.costprice,0),tmpdetailinfo.productcost))
                ELSE
   					SUM(tmpdetailinfo.quantity*IF((ifnull(tmpdetailinfo.productcost,0)=0),ifnull(ld_products.costprice,0),tmpdetailinfo.productcost)) 
                END AS productcost
            FROM (
                SELECT id,quantity,productcost,productid,lineitem_id FROM ld_invoicedetail      
                UNION ALL
                SELECT id,quantity,productcost,productid,lineitem_id FROM ld_outboundorderdetail 
                UNION ALL
                SELECT id,quantity,productcost,productid,lineitem_id FROM ld_servicecontractsdetail     
                UNION ALL
                SELECT id,quantity,productcost,productid,lineitem_id FROM ld_salesorderdetail 
            ) AS tmpdetailinfo  
            LEFT JOIN ld_products ON ld_products.productid=tmpdetailinfo.productid
            GROUP BY tmpdetailinfo.id
        ) g ON g.order_id=b.order_id
        ".$contracttype_str."
        )";
//    echo $vw_cashbilldetail."<br/>";die;

    //$vw_fycost1：费用和佣金支出，有关联客户但是当前期间内源单没有收款记录的费用和佣金在报表中单独列示
    $vw_fycost1="(
        SELECT
        	'feiyong' AS type,
        	a.accountid,
        	a.expensedate,
        	a.expenseid AS order_id,
        	a.expense_no AS order_no,
        	b.entitytypeid,
        	a.approvestatus,
        	a.currency_id,
        	a.currency_symbol,
        	b.Money AS amount,
        	c.rmb_total AS total,
        	a.deleted,
        	a.smcreatorid,
        	a.smownerid,
        	a.description
        FROM ld_expense a
        LEFT JOIN ld_expensedetail b ON a.expenseid = b.expenseid 
        LEFT JOIN ld_expensedetailscf c ON c.expensedetailid = b.expensedetailid
        LEFT JOIN ld_account ON a.accountid=ld_account.accountid $name_account   
        WHERE a.deleted=0 $name_account $where_expense
            AND a.expensedate $dateperid 
            AND a.accountid>0
            AND IFNULL(a.approvestatus,'') <> '已拒绝'
            AND a.smownerid in ($userids)  
        )
        UNION ALL (
        SELECT
        	'yongjin' AS type,
        	a.accountid,
        	a.expensedate,
        	a.commission_id AS order_id,
        	a.commission_no AS order_no,
        	e.entitytypeid,
        	a.approvestatus,
        	a.currency_id,
        	a.currency_symbol,
        	e.amount AS amount,
        	e.amount/a.conversion_rate AS total,
        	a.deleted,
        	a.smcreatorid,
        	a.smownerid,
        	a.description
        FROM ld_commission a
        LEFT JOIN ld_commission2payment e ON a.commission_id = e.commission_id
        LEFT JOIN ld_commission2paymentscf f ON f.commission2payment_id = e.commission2payment_id
        LEFT JOIN ld_account ON a.accountid=ld_account.accountid
        WHERE a.deleted=0 $name_account $where_commission 
            AND a.expensedate $dateperid 
            AND a.accountid>0
            AND IFNULL(a.approvestatus,'') <> '已拒绝'
            AND a.smownerid in ($userids) 
        )";
    //echo $vw_fycost1."<br/>";
  
    //$vw_fycost1:按照用户和时间范围过滤
    $vw_fycost2="(SELECT * FROM ($vw_fycost1) a)";
    //echo $vw_fycost2;
        
    //$vw_fycost：费用和佣金支出，按照合同订单汇总统计，并按照查询期间过滤       
    $vw_fycost="(
        SELECT
        	1 AS report_seq,
            2 AS report_seq2,
        	c.last_name AS statistical_one,
            c.wx_userid as report_wx_userid,
        	a.order_no AS statistical_two,
        	'' AS statistical_three,
        	c.last_name AS OftenUseReport_lastname,
        	c.last_name AS OftenUseReport_lastname2,
			ld_group.groupname AS OftenUseReport_groupname,
            ld_group.groupid as report_wx_groupid,
        	d.last_name AS OftenUseReport_lastname3,
        	a.order_no AS CashBill_cashbill_no,
        	a.expensedate AS CashBill_cashbilldate,
        	0 AS OftenUseReport_Atotal,
        	'' AS CashBill_Curid,
        	'' AS CashBill_Rate,
        	'' AS CashBill_Symbol,
        	ld_account.accountname AS Accounts_accountname,
        	a.accountid AS Accounts_accountid,
        	'' AS SalesOrder_subject,
        	'' AS SalesOrder_Curid,
        	'' AS SalesOrder_Rate,
        	'' AS SalesOrder_Symbol,
        	CASE
        		WHEN a.type = 'feiyong' THEN a.currency_id
        		ELSE ''
        	END AS Expense_Curid,
        	CASE
        		WHEN a.type = 'feiyong' THEN a.expensedate
        		ELSE ''
        	END AS Expense_Rate,
        	CASE
        		WHEN a.type = 'feiyong' THEN a.currency_symbol
        		ELSE ''
        	END AS Expense_Symbol,
        	CASE
        		WHEN a.type = 'yongjin' THEN a.currency_id
        		ELSE ''
        	END AS Comm_Curid,
        	CASE
        		WHEN a.type = 'yongjin' THEN a.expensedate
        		ELSE ''
        	END AS Comm_Rate,
        	CASE
        		WHEN a.type = 'yongjin' THEN a.currency_symbol
        		ELSE ''
        	END AS Comm_Symbol,
        	'' AS OftenUseReport_salesorder_no,
        	'' AS OftenUseReport_contracttype,
        	0 AS OftenUseReport_ssubtotal,
        	0 AS OftenUseReport_pamount,
        	0 AS OftenUseReport_productcost,
        	CASE
        	WHEN a.type = 'feiyong' THEN SUM(a.total)
        	ELSE 0
        	END AS OftenUseReport_etotal,
        	0 - sum(a.total) AS OftenUseReport_productgp,
        	'' AS Products_product_no,
        	'' AS Products_productname,
        	'' AS Products_productsheet,
        	'' AS Products_usageunit,
        	0 AS Products_unit_price,
        	CASE
        		WHEN a.type = 'yongjin' THEN SUM(a.total)
        		ELSE 0
        	END AS OftenUseReport_CommissionTotal,
        	0 AS OftenUseReport_quantity,
        	0 AS Products_costprice,
        	0 AS OftenUseReport_discountamount,
        	a.smownerid AS CashBill_smownerid,
        	'' AS CashBill_salesorderid,
        	a.description CashBill_description,
        	'' AS CashBill_paymentmethod,
        	a.order_id AS LBL_ACTION,
        	a.order_id
        FROM $vw_fycost2 a
        LEFT JOIN ld_account ON a.accountid = ld_account.accountid
        LEFT JOIN ld_users c ON a.smownerid = c.id
        LEFT JOIN ld_users d ON a.smcreatorid = d.id
		LEFT JOIN (
			select GROUP_CONCAT(ld_groups.groupname) as groupname,
            GROUP_CONCAT(ld_groups.groupid) as groupid,
            ld_users2group.userid from ld_users2group
			LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
			GROUP BY ld_users2group.userid
		) as ld_group on ld_group.userid = a.smownerid
        WHERE a.entitytypeid NOT IN (
        		SELECT DISTINCT
        			CASE
        				WHEN ld_cashbill2paymentplan.entitytype='PaymentPlan' THEN
        					(SELECT entitytypeid FROM ld_paymentplan WHERE paymentplanid=ld_cashbill2paymentplan.entitytypeid)
        				ELSE ld_cashbill2paymentplan.entitytypeid
        			END AS entitytypeid
        		FROM ld_cashbill a
        		LEFT JOIN ld_cashbill2paymentplan ON a.cashbillid = ld_cashbill2paymentplan.CashBillID
        		LEFT JOIN ld_account ON ld_account.accountid=a.accountid
        		WHERE a.deleted = 0 $name_account $check_cashbill
                    AND a.cashbilldate $dateperid
                    AND a.smownerid in ($userids)
        			AND ld_cashbill2paymentplan.entitytypeid > 0
            )
        GROUP BY a.order_id)";

    //$sql_report: 收款业绩统计表数据SQL
    $sql_report="($vw_cashbilldetail UNION ALL $vw_fycost)";
    //echo $sql_report."<br><br>";

    $temp_table1="CREATE TEMPORARY TABLE IF NOT EXISTS `temptable1` IGNORE (
            SELECT * from $sql_report tmp
            );"; 
//   echo $temp_table1."<br><br>";
//    dump($temp_table1);
    $adb->query($temp_table1);    
            
            
    $temp_table2="CREATE TEMPORARY TABLE IF NOT EXISTS `temptable2` IGNORE (
            SELECT * from temptable1
            );";  
    $temp_table3="CREATE TEMPORARY TABLE IF NOT EXISTS `temptable3` IGNORE (
            SELECT * from temptable1
            );";  
    $temp_table31="CREATE TEMPORARY TABLE IF NOT EXISTS `temptable31` IGNORE (
            SELECT * from temptable1
            );";  
    
//    echo $temp_table2."<br><br>";
//    echo $temp_table3."<br><br>";
//     echo $temp_table31     ."<br><br>";
    $adb->query($temp_table2);  
    $adb->query($temp_table3);
    $adb->query($temp_table31);
    
    //$sql_subtotal：收款业绩统计表小计SQL
    $sql_subtotal="(
        SELECT
        	1 AS report_seq,
            3 AS report_seq2,
        	'小计' AS statistical_one,
           
        	'小计' AS statistical_two,
        	'小计' AS statistical_three,
        	CONCAT(t1.OftenUseReport_lastname,'-','".getFixedLabel('SUBTOTAL')."') AS OftenUseReport_lastname,
            CONCAT(t1.OftenUseReport_lastname,'-','".getFixedLabel('SUBTOTAL')."')  as report_wx_userid,
        	CONCAT(t1.OftenUseReport_lastname,' :小计') AS OftenUseReport_lastname2,
			'' OftenUseReport_groupname,
            '' as report_wx_groupid,
        	'' OftenUseReport_lastname3,
        	'' AS CashBill_cashbill_no,
        	'' AS CashBill_cashbilldate,
        	IFNULL(t3.OftenUseReport_Atotal,0) AS OftenUseReport_Atotal,
        	'' CashBill_Curid,
        	'' CashBill_Rate,
        	'' CashBill_Symbol,
        	'' AS Accounts_accountname,
        	'' AS Accounts_accountid,
        	'' SalesOrder_subject,
        	'' SalesOrder_Curid,
        	'' SalesOrder_Rate,
        	'' SalesOrder_Symbol,
        	'' Expense_Curid,
        	'' Expense_Rate,
        	'' Expense_Symbol,
        	'' Comm_Curid,
        	'' Comm_Rate,
        	'' Comm_Symbol,
        	'' OftenUseReport_salesorder_no,
        	'' OftenUseReport_contracttype,
        	IFNULL(t4.OftenUseReport_ssubtotal,0) AS OftenUseReport_ssubtotal,
        	IFNULL(t2.OftenUseReport_pamount,0) AS OftenUseReport_pamount,
        	IFNULL(t1.OftenUseReport_productcost,0) AS OftenUseReport_productcost,
        	IFNULL(t3.OftenUseReport_etotal,0) AS OftenUseReport_etotal,
        	IFNULL(t3.OftenUseReport_productgp,0) AS OftenUseReport_productgp,
        	'' Products_product_no,
        	'' Products_productname,
        	'' Products_productsheet,
        	'' Products_usageunit,
        	'' Products_unit_price,
        	IFNULL(t3.OftenUseReport_CommissionTotal,0) AS OftenUseReport_CommissionTotal,
        	IFNULL(t1.OftenUseReport_quantity,0) AS OftenUseReport_quantity,
        	IFNULL(t1.OftenUseReport_productcost,0) AS Products_costprice,
        	IFNULL(t3.OftenUseReport_discountamount,0) AS OftenUseReport_discountamount,
        	'' AS CashBill_smownerid,
        	'' AS CashBill_salesorderid,
        	'' CashBill_description,
        	'' AS CashBill_paymentmethod,
        	'' AS LBL_ACTION,
        	'' AS order_id
        FROM (
        	SELECT
        		OftenUseReport_lastname,
        		SUM(Products_costprice) AS OftenUseReport_productcost,
       			SUM(OftenUseReport_quantity) AS OftenUseReport_quantity
        	FROM temptable1
        	GROUP BY OftenUseReport_lastname
        ) t1
        LEFT JOIN (
        	SELECT
        		OftenUseReport_lastname,
        		SUM(OftenUseReport_pamount) AS OftenUseReport_pamount
        	FROM (
        		SELECT
        			OftenUseReport_lastname,
        			LBL_ACTION,
        			OftenUseReport_pamount/IFNULL(CashBill_Rate,1) AS OftenUseReport_pamount,
        			OftenUseReport_Atotal
        		FROM temptable2
        		GROUP BY LBL_ACTION,order_id
        	) temp
            GROUP BY OftenUseReport_lastname
        ) t2 ON t1.OftenUseReport_lastname=t2.OftenUseReport_lastname
        LEFT JOIN (
        	SELECT
        		OftenUseReport_lastname,
        		SUM(OftenUseReport_ssubtotal) AS OftenUseReport_ssubtotal
        	FROM
        		(
        			SELECT
        				OftenUseReport_lastname,
        				OftenUseReport_ssubtotal / IFNULL(SalesOrder_Rate, 1) AS OftenUseReport_ssubtotal
        			FROM temptable31
        			GROUP BY order_id
        		) tmp
        	GROUP BY OftenUseReport_lastname
        ) t4 ON t4.OftenUseReport_lastname = t1.OftenUseReport_lastname
        LEFT JOIN (
        	SELECT
        		OftenUseReport_lastname,
        		SUM(OftenUseReport_ssubtotal) AS OftenUseReport_ssubtotal,
        		SUM(OftenUseReport_Atotal) AS OftenUseReport_Atotal,
        		SUM(OftenUseReport_productgp) AS OftenUseReport_productgp,
        		SUM(OftenUseReport_etotal) AS OftenUseReport_etotal,
        		SUM(OftenUseReport_CommissionTotal) AS OftenUseReport_CommissionTotal,
        		SUM(OftenUseReport_discountamount) AS OftenUseReport_discountamount
        	FROM (
        		SELECT
        			OftenUseReport_lastname,
        			order_id,
        			OftenUseReport_ssubtotal/IFNULL(SalesOrder_Rate,1) AS OftenUseReport_ssubtotal,
        			OftenUseReport_Atotal,
        			OftenUseReport_productgp,
        			OftenUseReport_etotal,
        			OftenUseReport_CommissionTotal,
        			OftenUseReport_discountamount
        		FROM temptable3
        		GROUP BY lbl_action, order_id
        	) tmp
            GROUP BY OftenUseReport_lastname
        ) t3 ON t3.OftenUseReport_lastname=t1.OftenUseReport_lastname)"; 
           
    
    $temp_table4="CREATE TEMPORARY TABLE IF NOT EXISTS `temptable4` IGNORE (
        SELECT * from $sql_subtotal tmp
        );";
//        echo $temp_table4     ."<br><br>";
        $adb->query($temp_table4);
 
    
    //$sql_total：收款业绩统计表合计SQL
    $sql_total="(
        SELECT
        	3 AS report_seq,
            1 AS report_seq2,
        	'合计' as statistical_one,
            
        	'合计' as statistical_two,
        	'合计' as statistical_three, 
        	'".getFixedLabel('TOTAL')."' as OftenUseReport_lastname,
            '".getFixedLabel('TOTAL')."' as report_wx_userid,
        	'合计' as OftenUseReport_lastname2,
			'' AS OftenUseReport_groupname,
            '' as report_wx_groupid,
        	'' AS OftenUseReport_lastname3,
        	'' AS CashBill_cashbill_no, 
        	'' AS CashBill_cashbilldate,
        	SUM(OftenUseReport_Atotal) as OftenUseReport_Atotal,
        	'' CashBill_Curid,
        	'' CashBill_Rate,
        	'' CashBill_Symbol, 
        	'' as Accounts_accountname,
        	'' as Accounts_accountid,
        	'' SalesOrder_subject,
        	'' SalesOrder_Curid,
        	'' SalesOrder_Rate,
        	'' SalesOrder_Symbol,
        	'' Expense_Curid,
        	'' Expense_Rate,
        	'' Expense_Symbol,
        	'' Comm_Curid,
        	'' Comm_Rate,
        	'' Comm_Symbol,
        	'' OftenUseReport_salesorder_no,
        	'' OftenUseReport_contracttype,
        	SUM(OftenUseReport_ssubtotal) AS OftenUseReport_ssubtotal,
        	SUM(OftenUseReport_pamount) AS OftenUseReport_pamount,
        	SUM(OftenUseReport_productcost) AS OftenUseReport_productcost,
        	SUM(OftenUseReport_etotal) AS OftenUseReport_etotal,
        	SUM(OftenUseReport_productgp) AS OftenUseReport_productgp,
        	'' Products_product_no,
        	'' Products_productname,
        	'' Products_productsheet,
        	'' Products_usageunit, 
        	'' as Products_unit_price,
        	SUM(OftenUseReport_CommissionTotal) AS OftenUseReport_CommissionTotal,
        	SUM(OftenUseReport_quantity) AS OftenUseReport_quantity,
        	SUM(Products_costprice) Products_costprice, 
        	SUM(OftenUseReport_discountamount) OftenUseReport_discountamount, 
        	'' as CashBill_smownerid,
        	'' as CashBill_salesorderid,
        	'' CashBill_description,
        	'' CashBill_paymentmethod,
        	'' as LBL_ACTION,
        	'' AS order_id
        FROM temptable4 tmp)";
    //echo $sql_total;   
    
    $temp_table5="CREATE TEMPORARY TABLE IF NOT EXISTS `temptable5` IGNORE (
            SELECT * from $sql_total tmp
            );";
//    echo $temp_table5;
    $adb->query($temp_table5);     
  //  echo $temp_table5."<br><br>";
   // dump('wwww');
 //   dump('www');

    //收款业绩统计表查询SQL
    $SQL="SELECT *  
        FROM (
            SELECT * FROM temptable3 
            UNION ALL 
            SELECT * FROM temptable4 
            UNION ALL  
            SELECT * FROM temptable5
            ) t
        ORDER BY report_seq,
            CONVERT(OftenUseReport_lastname2 USING gbk),
            report_seq2,
            CashBill_cashbilldate,
            CashBill_cashbill_no,
            OftenUseReport_salesorder_no";
//        echo $SQL."</br></br>";die;
        return $SQL;
    }
    
    static function getServiceperformanceappraisal($where,$wheretime,$whereapps,$wherecomm,$whereBILL,$whereservicetype)
    {
        global $adb,$languageType;

        if($_REQUEST['basicotherfindsapp2']=='true'){
            $bill_range='approved';
        }else{
            $bill_range='all';
        }

        //$result = array();
        //preg_match_all("/(?:\()(.*)(?:\))/i",$where, $result);
        //$userids=$result[1][0];
        //echo $userids;

        //echo $bill_range;
        //echo $whereapps;
        //echo $wherecomm;
        //echo $where.'<br/>';
       // echo $userids;


        //22486: 常用报表>服务绩效统计表：编辑服务回访单的满意度，及时率，解决率为空值时，显示的服务业绩不正确
        // @edit:luyx @date:2020-11-26 @reason: 已和刘总讨论确认，如果没有“实际处理时间”取单据“创建时间”
        $SQL="CREATE TEMPORARY TABLE
        IF NOT EXISTS temptable IGNORE (
	SELECT
		''smownerid2,(
			SELECT
				fieldlabel
			FROM
				ld_tranlabel
			WHERE
				relateid = (
					SELECT
						tabid
					FROM
						ld_tab
					WHERE
						NAME = 'ProjectTask'
				)
			AND tabid = relateid
			AND languagetype = '$languageType'
		) AS module_zh,
		(
			SELECT
				fieldlabel
			FROM
				ld_tranlabel
			WHERE
				relateid = (
					SELECT
						tabid
					FROM
						ld_tab
					WHERE
						NAME = 'ProjectTask'
				)
			AND tabid = relateid
			AND languagetype = 'en'
		) AS module_en,
			(
				SELECT
					fieldlabel
				FROM
					ld_tranlabel
				WHERE
					relateid = (
						SELECT
							tabid
						FROM
							ld_tab
						WHERE
							NAME = 'HelpDesk'
					)
				AND tabid = relateid
				AND languagetype = 'en'
				AND trantable = 'ld_tab'
			) AS module_order,
		ld_users.last_name,
		ld_group.groupname,
		ld_account.accountname,
        ld_account.accountid,
		ld_projecttask.smownerid,
		ld_account.bill_city,
		ld_projecttask.productcategory,
		ld_projecttask.projecttasktype,
		ld_projecttask.startdate as enddate,
		ld_projecttask.traficfee,
		IFNULL(round((
			(IFNULL(ld_productcategory.scores,0)*IFNULL(ld_projecttasktype.weight,0) * 0.01)
            + IFNULL(ld_bill_city.scores, 0.00))*IFNULL((case when ifnull(ld_servicereturn.satisfaction,0)=0 then 100 else ld_servicereturn.satisfaction end)/100,1)
        *IFNULL((case when ifnull(ld_servicereturn.timelyrate,0)=0 then 100 else ld_servicereturn.timelyrate end)/100,1)
        *IFNULL((case when ifnull(ld_servicereturn.resolutionrate,0)=0 then 100 else ld_servicereturn.resolutionrate end)/100,1),2),0)
        AS fwyeji,
		IFNULL(round(((
			IFNULL(
				ld_productcategory.scores,
				100
			) * IFNULL(
				ld_projecttasktype.weight,
				100
			) * 0.01
		) + IFNULL(ld_bill_city.scores, 0)) * IFNULL((
			SELECT Proportion FROM ld_tab WHERE NAME = 'ProjectTask'
		),0)*0.01,2),0) AS jiaotongfei,
		ld_projecttask.projecttask_no,
        '' AS servicetype,
		ld_projecttask.createdtime,
		ld_projecttask.workcontent as description,
		ld_projecttask.solution AS fangan,
        'ProjectTask' AS secfh
	FROM (
        select 
            ld_projecttask.smownerid,ld_projecttask.projecttaskid,ld_projecttask.accountid,
            ld_projecttask.productcategory,
            ld_projecttask.projecttasktype,
            ld_projecttask.startdate,
            ld_projecttask.traficfee,
            ld_projecttask.projecttask_no,
            ld_projecttask.createdtime,
		    ld_projecttask.workcontent,
            ld_projecttask.solution
        from ld_projecttask where ld_projecttask.deleted=0 
        AND (
            CASE
                WHEN '$bill_range'='all' THEN 1=1
                ELSE ld_projecttask.approvestatus='已批准'
            END)
        AND ld_projecttask.enddate $wheretime $wherecomm 
	)ld_projecttask
	LEFT JOIN ld_users ON ld_projecttask.smownerid = ld_users.id
	LEFT JOIN (
		select GROUP_CONCAT(ld_groups.groupname) as groupname,ld_users2group.userid from ld_users2group
		LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
		GROUP BY ld_users2group.userid
	) as ld_group on ld_group.userid = ld_projecttask.smownerid
	LEFT JOIN ld_servicereturn on ld_servicereturn.projecttaskid = ld_projecttask.projecttaskid and ld_servicereturn.deleted=0
	LEFT JOIN (
		SELECT
			accountid,
			accountname,
			CASE
				WHEN EXISTS (SELECT 1 FROM ld_systems_deploy where deploy_type=207 AND deploy_value='bill_city') THEN bill_city
				ELSE bill_area
			END AS bill_city
		FROM ld_account
		WHERE deleted=0
	) AS ld_account ON ld_projecttask.accountid = ld_account.accountid
	LEFT JOIN (
                SELECT
                  listvalue,
                  scores
                FROM ld_picklist_values
                  LEFT JOIN ld_picklist_set
                    ON ld_picklist_set.listid = ld_picklist_values.listid
                WHERE listname = 'productcategory' AND relatetable = 'ld_field')
      AS ld_productcategory ON ld_productcategory.listvalue = ld_projecttask.productcategory

    LEFT JOIN (
                SELECT
                  listvalue,
                  weight
                FROM ld_picklist_values
                  LEFT JOIN ld_picklist_set
                    ON ld_picklist_set.listid = ld_picklist_values.listid
                WHERE listname = 'projecttasktype' AND relatetable = 'ld_field')
      AS ld_projecttasktype ON ld_projecttasktype.listvalue = ld_projecttask.projecttasktype

	LEFT JOIN (
		SELECT
			listvalue,
			scores
		FROM ld_picklist_values
		LEFT JOIN ld_picklist_set ON ld_picklist_set.listid = ld_picklist_values.listid
		WHERE 1=1
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy where deploy_type=207 AND deploy_value='bill_city') THEN listname = 'bill_city'
					ELSE listname = 'bill_area'
				END)
			AND relatetable = 'ld_field'
	) AS ld_bill_city ON ld_bill_city.listvalue = ld_account.bill_city
    
        
	);";
   $adb->query($SQL);
   //echo $SQL."<br>";die;
   
$SQL="CREATE TEMPORARY TABLE
IF NOT EXISTS `temptable1` IGNORE (
    SELECT
			'' smownerid2,
        	(SELECT fieldlabel FROM ld_tranlabel WHERE relateid =13 AND tabid = 13 AND trantable = 'ld_tab' AND languagetype = '$languageType') AS module_zh,
        	(SELECT fieldlabel FROM ld_tranlabel WHERE relateid =13 AND tabid = 13 AND trantable = 'ld_tab' AND languagetype = 'en') AS module_en,
        	(SELECT fieldlabel FROM ld_tranlabel WHERE relateid =13 AND tabid = 13 AND trantable = 'ld_tab' AND languagetype = 'en') AS module_order,
			ld_users.last_name,
			ld_group.groupname,
			ld_account.accountname,
            ld_account.accountid,
			ld_troubletickets.smownerid,
			ld_account.bill_city,
			ld_troubletickets.productcategory,
			ld_troubletickets.category as projecttasktype,
			DATE_FORMAT(ld_troubletickets.realtime,'%Y-%m-%d') as enddate,
			ld_troubletickets.traficfee,
        	IFNULL(round(
                    ((IFNULL(ld_productcategory.scores,0)*IFNULL(ld_ticketcategories.weight,0)*0.01)+IFNULL(ld_bill_city.scores, 0))*ld_servicetype.weight*0.01
                    *IFNULL(ld_servicereturn.satisfaction,100)*0.01
                    *IFNULL(ld_servicereturn.timelyrate,100)*0.01
                    *IFNULL(ld_servicereturn.resolutionrate,100)*0.01
                ,2),0) AS fwyeji,
			IFNULL(round(
				    ((IFNULL(ld_productcategory.scores,0)*IFNULL(ld_ticketcategories.weight,0)*0.01)+IFNULL(ld_bill_city.scores, 0))*ld_servicetype.weight*0.01
                    *IFNULL(ld_servicereturn.satisfaction,100)*0.01
                    *IFNULL(ld_servicereturn.timelyrate,100)*0.01
                    *IFNULL(ld_servicereturn.resolutionrate,100)*0.01
                    *IFNULL((SELECT Proportion FROM ld_tab WHERE NAME = 'HelpDesk'),0)*0.01
                ,2),0) AS jiaotongfei,
			ld_troubletickets.ticket_no as projecttask_no, 
            ld_troubletickets.servicetype,
			ld_troubletickets.createdtime,
			ld_troubletickets.description,
			ld_troubletickets.solution AS fangan,
            'HelpDesk' AS secfh
		FROM (
        select ld_troubletickets.smownerid,
ld_troubletickets.productcategory,ld_troubletickets.realtime,ld_troubletickets.traficfee,
ld_troubletickets.ticket_no,ld_troubletickets.servicetype,
			ld_troubletickets.createdtime,
			ld_troubletickets.description,
			ld_troubletickets.solution,
			ld_troubletickets.accountid,
			ld_troubletickets.ticketid,
			ld_troubletickets.category  
 from ld_troubletickets 
            WHERE ld_troubletickets.deleted=0 
            AND (
                CASE
                    WHEN '$bill_range'='all' THEN 1=1
                    ELSE ld_troubletickets.approvestatus='已批准'
                END)
            AND IFNULL(ld_troubletickets.realtime,ld_troubletickets.createdtime) $wheretime $whereapps 
		)ld_troubletickets
		LEFT JOIN ld_users ON ld_troubletickets.smownerid = ld_users.id
		LEFT JOIN (
			select GROUP_CONCAT(ld_groups.groupname) as groupname,ld_users2group.userid from ld_users2group
			LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
			GROUP BY ld_users2group.userid
		) as ld_group on ld_group.userid = ld_troubletickets.smownerid
    	LEFT JOIN (
    		SELECT
    			accountid,
    			accountname,
    			CASE
    				WHEN EXISTS (SELECT 1 FROM ld_systems_deploy where deploy_type=207 AND deploy_value='bill_city') THEN bill_city
    				ELSE bill_area
    			END AS bill_city
    		FROM ld_account
    		WHERE deleted=0
    	) AS ld_account ON ld_troubletickets.accountid = ld_account.accountid
        LEFT JOIN (
                SELECT
                  listvalue productcategory,
                  scores
                FROM ld_picklist_values
                  LEFT JOIN ld_picklist_set
                    ON ld_picklist_set.listid = ld_picklist_values.listid
                WHERE listname = 'productcategory' AND relatetable = 'ld_field')
        AS ld_productcategory ON ld_productcategory.productcategory=ld_troubletickets.productcategory


        LEFT JOIN (
        	SELECT
        		troubleticketid,
        		AVG(IFNULL(satisfaction,100)) AS satisfaction,
        		AVG(IFNULL(timelyrate,100)) AS timelyrate,
        		AVG(IFNULL(resolutionrate,100)) AS resolutionrate
        	FROM ld_servicereturn
        	WHERE deleted=0
        		AND troubleticketid>0
        	GROUP BY troubleticketid
        ) ld_servicereturn ON ld_servicereturn.troubleticketid = ld_troubletickets.ticketid

        LEFT JOIN (
                SELECT
                  listvalue,
                  weight
                FROM ld_picklist_values
                  LEFT JOIN ld_picklist_set
                    ON ld_picklist_set.listid = ld_picklist_values.listid
                WHERE listname = 'servicetype' AND relatetable = 'ld_field')
        AS ld_servicetype ON ld_servicetype.listvalue = ld_troubletickets.servicetype

        LEFT JOIN (
                SELECT
                  listvalue,
                  weight
                FROM ld_picklist_values
                  LEFT JOIN ld_picklist_set
                    ON ld_picklist_set.listid = ld_picklist_values.listid
                WHERE listname = 'ticketcategories' AND relatetable = 'ld_field')
        AS ld_ticketcategories ON ld_ticketcategories.listvalue = ld_troubletickets.category

    	LEFT JOIN (
    		SELECT
    			listvalue,
    			scores
    		FROM ld_picklist_values
    		LEFT JOIN ld_picklist_set ON ld_picklist_set.listid = ld_picklist_values.listid
    		WHERE 1=1
    			AND (
    				CASE
    					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy where deploy_type=207 AND deploy_value='bill_city') THEN listname = 'bill_city'
    					ELSE listname = 'bill_area'
    				END)
    			AND relatetable = 'ld_field'
    	) AS ld_bill_city ON ld_bill_city.listvalue = ld_account.bill_city


        
    );";
    //echo $SQL;
    $adb->query($SQL);
    //echo $SQL."<br>";
//echo $whereBILL;
$SQL="CREATE TEMPORARY TABLE
IF NOT EXISTS temptable2 IGNORE (
SELECT * FROM (
SELECT * FROM temptable as f22 UNION SELECT * FROM temptable1 as f23
) as ff1 where 1=1 ".sprintf($whereBILL,'secfh')." ".
sprintf($where,'ff1')." $whereservicetype
); ";
  $adb->query($SQL);
//echo $SQL."<br>";

$SQL="CREATE TEMPORARY TABLE
IF NOT EXISTS temptable3 IGNORE (
SELECT '小计'smownerid2,'".getFixedLabel('SUBTOTAL')."' module_zh, module_en,''module_order,''last_name,'' groupname,'' accountname,'' accountid,smownerid,'' bill_city,'' productcategory,'' projecttasktype,'' enddate,
SUM(traficfee) as traficfee,round(SUM(fwyeji),2) AS fwyeji,round(SUM(jiaotongfei),2) as jiaotongfei,
'' projecttask_no,'' servicetype,'' createdtime,'' description,'' fangan,''secfh
FROM temptable2 GROUP BY last_name,module_zh
);";
  $adb->query($SQL);
//echo $SQL."<br>";

$SQL="CREATE TEMPORARY TABLE
IF NOT EXISTS temptable4 IGNORE (SELECT '小计'smownerid2,''module_zh, ''module_en,''module_order,'".getFixedLabel('SUBTOTAL')."' last_name,'' groupname,'' accountname,'' accountid,smownerid,'' bill_city,'' productcategory,'' projecttasktype,'' enddate,
SUM(traficfee) as traficfee,SUM(fwyeji) AS fwyeji,SUM(jiaotongfei) as jiaotongfei,
'' projecttask_no,'' servicetype,'' createdtime,'' description,'' fangan,''secfh
FROM temptable2 GROUP BY last_name);";
  $adb->query($SQL);
//echo $SQL."<br>";
if($whereBILL==''){
   $SQL="CREATE TEMPORARY TABLE
IF NOT EXISTS temptable5 IGNORE (SELECT * FROM (
SELECT * FROM temptable2 as f22 UNION SELECT * FROM temptable3 as f23 UNION SELECT * FROM temptable4 as f24
) as ff1 
ORDER BY smownerid ASC,module_en DESC,module_order DESC,module_zh DESC,last_name,enddate DESC);"; 
}else{
    $SQL="CREATE TEMPORARY TABLE
IF NOT EXISTS temptable5 IGNORE (SELECT * FROM (
SELECT * FROM temptable2 as f22 UNION SELECT * FROM temptable3 as f23 
) as ff1 
ORDER BY smownerid ASC,module_en DESC,module_order DESC,module_zh DESC,last_name,enddate DESC);";
}

  $adb->query($SQL);
//echo $SQL."<br>";

$SQL="SELECT smownerid2,
    smownerid,module_zh as OftenUseReport_module_zh,
	module_en,
	module_order,
    last_name as OftenUseReport_lastname, 
	groupname as OftenUseReport_groupname, 
    accountname as Accounts_accountname,
    accountid as Accounts_accountid,
 bill_city as Accounts_bill_city,
  productcategory as Products_productcategory,
  projecttasktype as HelpDesk_category,
  enddate as HelpDesk_enddate,
traficfee AS HelpDesk_traficfee,
fwyeji AS OftenUseReport_fwyeji,
jiaotongfei as HelpDesk_jiaotongfei,
 projecttask_no as HelpDesk_projecttask_no,servicetype as HelpDesk_servicetype,DATE_FORMAT(createdtime,'%Y-%m-%d') as HelpDesk_createdtime,description as HelpDesk_description
 ,fangan as HelpDesk_solution 
FROM temptable5 
union SELECT '合计'smownerid2,'合计'smownerid,'".getFixedLabel('TOTAL')."' OftenUseReport_Order, ''module_en,''module_order,
'' OftenUseReport_lastname,'' OftenUseReport_groupname,'' Accounts_accountname,'' Accounts_accountid,
'' Accounts_bill_city,'' Products_productcategory,'' HelpDesk_ticketcategories,'' HelpDesk_enddate,
round(SUM(traficfee),2) as HelpDesk_traficfee,round(SUM(fwyeji),2) AS OftenUseReport_fwyeji,round(SUM(jiaotongfei),2) as HelpDesk_jiaotongfei,
'' HelpDesk_projecttask_no,'' HelpDesk_servicetype,'' HelpDesk_createdtime,'' HelpDesk_description,''HelpDesk_solution 
FROM temptable2;";

//echo $SQL."<br>";

        return $SQL;
    }

    /**
     * @param $start_date
     * @param $end_date
     * @param $jititype
     * @param $costtype
     * @param $fee_range
     * @param $order_range
     * @param $accountname
     * @param $ordernum
     * @param $data_range
     * @return string
     * 获取提成报表sql
     * zxm
     * 2020-1010
     */
    static public function getCommissionByOrder($start_date,$end_date,$jititype,$costtype,$fee_range,$order_range,$accountname,$ordernum,$data_range)
    {   
        return "SELECT last_name as smownerid,wx_userid,
	    CASE
		WHEN order_id>0 THEN order_id
		ELSE '00'
	    END AS order_id,
	    CASE
		WHEN accountid>0 THEN accountid
		ELSE '00'
	    END AS accountid,
	    order_no as salesorder_no,
	    stockpresence,
	    signed_data,
	    accountname  as account_id,
        total_display,
        total_rmb as total,
        total_fy,
        total_yj,
        total_cost,
        contractamount AS target,
        yeji,
        b.done_toal,
        b.done_rate,
        b.ticheng_rate,
        a.yeji*b.ticheng_rate*0.01 AS ticheng
    FROM (
	    (SELECT
		smownerid,
		wx_userid,
		last_name,
		1 AS order2,
		order_id,
		accountid,
		order_no,
		stockpresence,
		signed_data,
		accountname,
		CONCAT(currency_symbol,IFNULL(total,0)) AS total_display,
		IFNULL(total,0)/IFNULL(conversion_rate,1) AS total_rmb,
		IFNULL(total_fy,0) AS total_fy,
		IFNULL(total_yj,0) AS total_yj,
		IFNULL(total_cost,0) AS total_cost,
		CASE
			WHEN '$jititype'='1' THEN	
				IFNULL(total,0)/IFNULL(conversion_rate,1)
			WHEN '$jititype'='2' THEN	
				IFNULL(total,0)/IFNULL(conversion_rate,1)-IFNULL(total_fy,0)-IFNULL(total_yj,0)
			WHEN '$jititype'='3' THEN
				IFNULL(total,0)/IFNULL(conversion_rate,1)-IFNULL(total_fy,0)-IFNULL(total_yj,0)-IFNULL(total_cost,0)
		END AS yeji,
		CASE
			WHEN '$jititype'='1' THEN	
				(IFNULL(total,0)/IFNULL(conversion_rate,1))*'$rate'/100
			WHEN '$jititype'='2' THEN	
				(IFNULL(total,0)/IFNULL(conversion_rate,1)-IFNULL(total_fy,0)-IFNULL(total_yj,0))*'$rate'/100
			WHEN '$jititype'='3' THEN
				(IFNULL(total,0)/IFNULL(conversion_rate,1)-IFNULL(total_fy,0)-IFNULL(total_yj,0)-IFNULL(total_cost,0))*'$rate'/100
		END AS ticheng
	FROM (
		SELECT
			a.smownerid,
			b.last_name,
			b.wx_userid,
			a.order_id,
			a.accountid,
			a.order_no,
			a.stockpresence,
			a.signed_data,
			a.total,
			a.currency_symbol,
			a.conversion_rate,
			CASE
				WHEN '$costtype'='1' THEN c.productcost
				WHEN '$costtype'='2' THEN f.total
				WHEN '$costtype'='3' THEN g.total
				WHEN '$costtype'='4' THEN h.total
			END AS total_cost,
			d.rmb_total AS total_fy,
			e.total_yj,
			ld_account.accountname,
			a.deleted,
			a.order_status,
			a.approvestatus	
		FROM (
			SELECT
				smownerid,
				salesorderid AS order_id,
				salesorder_no AS order_no,
				stockpresence,
				signed_data,
				sostatus AS order_status,
				accountid,
				deleted,
				approvestatus,
				currency_symbol,
				conversion_rate,
				total
			FROM ld_salesorder
			WHERE deleted=0
				AND IFNULL(approvestatus,'')<>'已拒绝'
			UNION ALL
			SELECT
				smownerid,
				servicecontractsid,
				contract_no,
				stockpresence,
				due_date,
				contract_status,
				accountid,
				deleted,
				approvestatus,
				currency_symbol,
				conversion_rate,
				total
			FROM ld_servicecontracts
			WHERE deleted=0
				AND IFNULL(approvestatus,'')<>'已拒绝'
		) a
		LEFT JOIN ld_users b ON a.smownerid=b.id
		LEFT JOIN ld_account ON a.accountid=ld_account.accountid
		LEFT JOIN (
			SELECT
				id,	
				SUM(productcost) AS productcost
			FROM (
				SELECT
					a.salesorderid AS id,
					CASE 
						WHEN IFNULL(b.productcost,0)<>0 THEN (b.quantity*b.productcost)/IFNULL(a.conversion_rate,1)
						ELSE b.quantity*IFNULL(c.costprice,0)
					END AS productcost
				FROM ld_salesorder a
				LEFT JOIN ld_salesorderdetail b ON a.salesorderid=b.id
				LEFT JOIN ld_products c ON c.productid=b.productid 
				WHERE a.deleted=0
					AND a.approvestatus<>'已拒绝'
				UNION ALL
				SELECT
					a.servicecontractsid,
					CASE 
						WHEN IFNULL(b.productcost,0)<>0 THEN (b.quantity*b.productcost)/IFNULL(a.conversion_rate,1)
						ELSE b.quantity*IFNULL(c.costprice,0)
					END AS productcost
				FROM ld_servicecontracts a
				LEFT JOIN ld_servicecontractsdetail b ON a.servicecontractsid=b.id
				LEFT JOIN ld_products c ON c.productid=b.productid 
				WHERE a.deleted=0
					AND a.approvestatus<>'已拒绝'
			) a
			GROUP BY id
		) c ON a.order_id=c.id
		LEFT JOIN (
			SELECT
				b.entitytypeid,
				SUM(c.rmb_total) AS rmb_total
			FROM ld_expense a
			LEFT JOIN ld_expensedetail b ON a.expenseid=b.expenseid
			LEFT JOIN ld_expensedetailscf c ON c.expensedetailid=b.expensedetailid
			WHERE a.deleted=0
				AND b.entitytype in ('SalesOrder','ServiceContracts')
				AND IFNULL(a.approvestatus,'')<>'已拒绝'
				AND (
					CASE
						WHEN '$fee_range'='false' THEN 1=1
						ELSE a.approvestatus='已批准'
					END)
			GROUP BY b.entitytypeid
		) d ON d.entitytypeid=a.order_id
		LEFT JOIN (
			SELECT
				b.entitytypeid,
				SUM(b.amount/IFNULL(a.conversion_rate,1)) AS total_yj
			FROM ld_commission a
			LEFT JOIN ld_commission2payment b ON a.commission_id=b.commission_id
			WHERE a.deleted=0
				AND b.entitytype in ('SalesOrder','ServiceContracts')
				AND IFNULL(a.approvestatus,'')<>'已拒绝'
				AND (
					CASE
						WHEN '$fee_range'='false' THEN 1=1
						ELSE a.approvestatus='已批准'
					END)
			GROUP BY b.entitytypeid
		) e ON e.entitytypeid=a.order_id
		LEFT JOIN (
			SELECT
				SUM(b.tax_amount/IFNULL(a.conversion_rate,1)) AS total,
				b.entitytypeid
			FROM ld_purchaseorder a
			LEFT JOIN ld_purchaseorderdetail b ON a.purchaseorderid=b.id
			WHERE a.deleted=0
				AND IFNULL(a.approvestatus,'')<>'已拒绝'
				AND IFNULL(a.postatus,'')<>'已作废'
				AND b.entitytypeid>0
			GROUP BY b.entitytypeid
		) f ON f.entitytypeid=a.order_id	
		LEFT JOIN (
			SELECT
				a.orderid,
				SUM(a.quantity*IFNULL(b.costprice,0)) AS total
			FROM (
				SELECT
					a.salesorderid AS orderid,
					b.productid,
					b.quantity
				FROM ld_salesorder a
				LEFT JOIN ld_salesorderdetail b ON a.salesorderid=b.id
				WHERE a.deleted=0
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
				UNION ALL
				SELECT
					a.servicecontractsid,
					b.productid,
					b.quantity
				FROM ld_servicecontracts a
				LEFT JOIN ld_servicecontractsdetail b ON a.servicecontractsid=b.id
				WHERE a.deleted=0
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
			) a
			LEFT JOIN (
				SELECT
					b.productid,
					SUM(b.tax_amount/IFNULL(a.conversion_rate,1))/SUM(b.quantity) AS costprice
				FROM ld_purchaseorder a
				LEFT JOIN ld_purchaseorderdetail b ON a.purchaseorderid=b.id
				WHERE a.deleted=0
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
					AND IFNULL(a.postatus,'')<>'已作废'
				GROUP BY b.productid
			) b ON b.productid=a.productid
			GROUP BY a.orderid
		) g ON g.orderid=a.order_id
		LEFT JOIN (
			SELECT
				SUM(b.tax_amount/IFNULL(a.conversion_rate,1)) AS total,
				b.entitytypeid
			FROM ld_outboundorder a
			LEFT JOIN ld_outboundorderdetail b ON a.out_id=b.id
			WHERE a.deleted=0
				AND IFNULL(a.approvestatus,'')<>'已拒绝'
				AND b.entitytypeid>0
			GROUP BY b.entitytypeid
		) h ON h.entitytypeid=a.order_id
	) t
	WHERE deleted=0
		AND IFNULL(order_status,'')<>'已作废'
		AND IFNULL(approvestatus,'')<>'已拒绝'
		AND signed_data BETWEEN DATE_FORMAT('$start_date','%Y-%m-%d') AND DATE_FORMAT('$end_date','%Y-%m-%d')
		AND (
			CASE
				WHEN '$order_range'='false' THEN	1=1
				ELSE approvestatus='已批准'		
			END)
		AND (
			CASE
				WHEN '$accountname'='' THEN	1=1
				ELSE accountname like '%$accountname%'		
			END)
		AND (
			CASE
				WHEN '$ordernum'='' THEN	1=1
				ELSE order_no like '%$ordernum%'		
			END)
	) 
	)a
LEFT JOIN (
	SELECT
		smownerid AS ownerid,
		done_toal,
		contractamount,
		done_rate,
		CASE
			WHEN EXISTS (SELECT 1 FROM ld_userreport_commissionrule WHERE is_on='yes' AND unit='万元' AND bytype='byOrder') THEN
				(SELECT commission_rate FROM ld_userreport_commissionrule WHERE is_on='yes' AND unit='万元' AND bytype='byOrder' AND t.done_toal>=`start`*10000 AND t.done_toal<`end`*10000  ORDER BY `start` LIMIT 1)
			ELSE 
				(SELECT commission_rate FROM ld_userreport_commissionrule WHERE is_on='yes' AND unit='%' AND bytype='byOrder' AND t.done_rate>=`start` AND t.done_rate<`end` ORDER BY `start` LIMIT 1)
		END AS ticheng_rate
	FROM (
		SELECT
			a.smownerid,
			a.done_toal,
			CASE
				WHEN IFNULL(b.contractamount,0)=0 THEN 0
				ELSE b.contractamount
			END AS contractamount,
			CASE
				WHEN IFNULL(b.contractamount,0)=0 THEN 0
				ELSE a.done_toal*100/IFNULL(b.contractamount,0)
			END AS done_rate
		FROM (
			SELECT
				a.smownerid,
				SUM(a.total) AS done_toal
			FROM (
				SELECT
					smownerid,
					total/IFNULL(conversion_rate,1) AS total
				FROM ld_salesorder
				WHERE deleted=0
					AND IFNULL(approvestatus,'')<>'已拒绝'
					AND signed_data BETWEEN DATE_ADD(DATE_FORMAT('$start_date','%Y-%m-%d'),INTERVAL - DAY('$start_date')+1 DAY) AND LAST_DAY(DATE_FORMAT('$end_date','%Y-%m-%d'))
				UNION ALL
				SELECT
					smownerid,
					total/IFNULL(conversion_rate,1) AS total
				FROM ld_servicecontracts
				WHERE deleted=0
					AND IFNULL(approvestatus,'')<>'已拒绝'
					AND due_date BETWEEN DATE_ADD(DATE_FORMAT('$start_date','%Y-%m-%d'),INTERVAL - DAY('$start_date')+1 DAY) AND LAST_DAY(DATE_FORMAT('$end_date','%Y-%m-%d'))
			) a
			GROUP BY a.smownerid
		) a
		LEFT JOIN (
			SELECT userid, SUM(contractamount) AS contractamount
            FROM (
                SELECT record AS userid, targetvalue AS contractamount, ld_salestarget_info.*
                FROM ld_salestarget_info LEFT JOIN ld_salestarget_basic ON ld_salestarget_basic.targetid = ld_salestarget_info.targetid
                WHERE ld_salestarget_basic.targetname = 'paymentamount'
                GROUP BY record, targetyear, targetmonth
            ) ld_salestarget
			WHERE DATE_FORMAT(CONCAT(targetyear,'-',targetmonth,'-01'),'%Y-%m-%d') BETWEEN DATE_ADD(DATE_FORMAT('$start_date','%Y-%m-%d'),INTERVAL - DAY('$start_date')+1 DAY) AND LAST_DAY(DATE_FORMAT('$end_date','%Y-%m-%d'))
			GROUP BY userid
		) b ON b.userid=a.smownerid
	) t
) b ON b.ownerid=a.smownerid
WHERE FIND_IN_SET(smownerid,'$data_range')
		AND (
			CASE
				WHEN '$accountname'='' THEN	1=1
				ELSE accountname like '%$accountname%'		
			END)
ORDER BY CONVERT(last_name USING GBK),order2,signed_data,order_no";

    }

    /**
     * @param $start_date
     * @param $end_date
     * @param $jititype
     * @param $costtype
     * @param $fee_range
     * @param $order_range
     * @param $accountname
     * @param $ordernum
     * @param $data_range
     * @return string
     * 获取提成报表sql
     * zxm
     * 2020-1010
     */
    static public function getCommissionByCash($start_date,$end_date,$jititype,$costtype,$fee_range,$order_range,$accountname,$ordernum,$data_range)
    {
        $sql= "SELECT
	last_name as smownerid,
	wx_userid,
	order2,
	CASE
		WHEN cashbillid>0 THEN cashbillid
		ELSE '00'
	END AS cashbillid,
	CASE
		WHEN accountid>0 THEN accountid
		ELSE '00'
	END AS account_id,
	cashbill_no,
	cashbilldate,
	accountname as accountid,
	CASE
		WHEN entitytypeid>0 THEN entitytypeid
		ELSE '00'
	END AS entitytypeid,
	source_no as source_list,
	total_display,
	total_rmb AS total,
	IFNULL(source_displaytotal,'￥0.00') AS source_displaytotal,
	IFNULL(source_rmbtotal,0) source_rmbtotal,
	IFNULL(source_rmbsubtotal,0) source_rmbsubtotal,
	IFNULL(source_displayreceived,'￥0.00') AS source_displayreceived,
	IFNULL(source_rmbreceived,0) AS source_rmbreceived,
	IFNULL(source_rmbsubreceived,0) AS source_rmbsubreceived,
	total_cost,
	total_fy,
	total_yj,
	paymentamount AS target,
	b.done_toal,
	b.done_rate,
	b.ticheng_rate,
	CASE
		WHEN '$jititype'='1' THEN IFNULL(total_rmb,0)
		WHEN '$jititype'='2' THEN IFNULL(total_rmb,0)-IFNULL(total_fy,0)-IFNULL(total_yj,0)
		WHEN '$jititype'='3' THEN IFNULL(total_rmb,0)-IFNULL(total_fy,0)-IFNULL(total_yj,0)-IFNULL(total_cost,0)
	END AS yeji,
	CASE
		WHEN '$jititype'='1' THEN (IFNULL(total_rmb,0)*b.ticheng_rate/100)
		WHEN '$jititype'='2' THEN ((IFNULL(total_rmb,0)-IFNULL(total_fy,0)-IFNULL(total_yj,0)))*b.ticheng_rate/100
		WHEN '$jititype'='3' THEN (IFNULL(total_rmb,0)-IFNULL(total_fy,0)-IFNULL(total_yj,0)-IFNULL(total_cost,0))*b.ticheng_rate/100
	END AS ticheng
FROM (
	SELECT
		last_name,
		wx_userid,
		smownerid,
		1 AS order2,
		cashbillid,
		cashbill_no,
		cashbilldate,
		accountid,
		accountname,
		entitytypeid,
		total_display,
		total_rmb,
		source_no,
		source_displaytotal,
		CASE
			WHEN cashbillid=periodfirst_cashbillid THEN source_rmbtotal
			ELSE 0
		END AS source_rmbtotal,
		CASE
			WHEN cashbillid=min_cashbillid THEN source_rmbtotal
			ELSE 0
		END AS source_rmbsubtotal,
		source_displayreceived,
		CASE
			WHEN cashbillid=periodfirst_cashbillid THEN source_rmbreceived
			ELSE 0
		END AS source_rmbreceived,
		CASE
			WHEN cashbillid=min_cashbillid THEN source_rmbreceived
			ELSE 0
		END AS source_rmbsubreceived,
		CASE
			WHEN cashbillid=first_cashbillid THEN total_cost
			ELSE 0
		END AS total_cost,
		CASE
			WHEN cashbillid=periodfirst_cashbillid THEN IFNULL(total_fy,0)
			ELSE 0
		END AS total_fy,
		CASE
			WHEN cashbillid=periodfirst_cashbillid THEN IFNULL(total_yj,0)
			ELSE 0
		END AS total_yj
	FROM (
		SELECT
			b.last_name,
			b.wx_userid,
			a.smownerid,
			a.cashbillid,
			i.cashbillid AS first_cashbillid,
			j.cashbillid AS periodfirst_cashbillid,
			(SELECT
				min(cashbillid) 
			FROM (
				SELECT
					a.smownerid,
					a.cashbillid,
					b.entitytypeid
				FROM ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b ON a.cashbillid=b.CashBillID
				LEFT JOIN ld_account c ON c.accountid=a.accountid
				WHERE a.deleted=0
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
					AND b.entitytypeid>0
					AND a.cashbilldate BETWEEN DATE_FORMAT('$start_date','%Y-%m-%d') AND DATE_FORMAT('$end_date','%Y-%m-%d')
					AND (
						CASE 
							WHEN EXISTS (SELECT 1 from ld_systems_deploy where deploy_type=83 and deploy_value=0) THEN 1=1
							ELSE a.approvestatus='已批准'
						END)
					AND (
						CASE
							WHEN '$accountname'='' THEN	1=1
							ELSE accountname like '%$accountname%'		
						END)
					ORDER BY a.cashbilldate,a.cashbillid
				) t1 WHERE t1.smownerid=a.smownerid and t1.entitytypeid=a.entitytypeid) AS min_cashbillid,
			a.cashbill_no,
			a.cashbilldate,
			a.currency_symbol,
			a.accountid,
			c.accountname,
			a.entitytype,
			a.entitytypeid,
			CONCAT(a.currency_symbol,FORMAT(IFNULL(a.amount,0),2)) AS total_display,
			a.amount/IFNULL(a.conversion_rate,1) AS total_rmb,
			d.order_no AS source_no,
			CONCAT(d.currency_symbol,FORMAT(IFNULL(d.total,0),2)) AS source_displaytotal,
			IFNULL(d.total,0)/IFNULL(d.conversion_rate,1) AS source_rmbtotal,
			CONCAT(d.currency_symbol,FORMAT(IFNULL(d.received_amount,0),2)) AS source_displayreceived,
			IFNULL(d.received_amount,0)/IFNULL(d.conversion_rate,1) AS source_rmbreceived,
			CASE
				WHEN '$costtype'='1' THEN productcost
				WHEN '$costtype'='2' THEN g.total
				WHEN '$costtype'='3' THEN m.total
				WHEN '$costtype'='4' THEN n.total
			END AS total_cost,
			e.rmb_total AS total_fy,
			f.total_yj,
			a.deleted,
			a.approvestatus
		FROM (
			SELECT
				smownerid,
				cashbillid,
				cashbill_no,
				cashbilldate,
				currency_symbol,
				conversion_rate,
				accountid,
				entitytype,
				entitytypeid,
				SUM(amount) AS amount,
				deleted,
				approvestatus
			FROM (
				SELECT
					a.smownerid,
					a.cashbillid,
					a.cashbill_no,
					a.cashbilldate,
					a.accountid,
					a.currency_symbol,
					a.conversion_rate,
					CASE 
						WHEN b.entitytype='PaymentPlan' THEN
							(SELECT entitytype FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
						ELSE b.entitytype
					END AS entitytype,
					CASE 
						WHEN b.entitytype='PaymentPlan' THEN
							(SELECT entitytypeid FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
						ELSE b.entitytypeid
					END AS entitytypeid,
					CASE
						WHEN b.CashBillID>0 THEN  b.amount
						ELSE a.Total
					END AS amount,
					a.deleted,
					a.approvestatus
				FROM ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b ON a.cashbillid = b.CashBillID
				WHERE a.deleted=0
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
					AND a.cashbilldate BETWEEN DATE_FORMAT('$start_date','%Y-%m-%d') AND DATE_FORMAT('$end_date','%Y-%m-%d')
					AND (
						CASE 
							WHEN EXISTS (SELECT 1 from ld_systems_deploy where deploy_type=83 and deploy_value=0) THEN 1=1
							ELSE a.approvestatus='已批准'
						END)	
			) a
			GROUP BY cashbillid,entitytypeid
		) a
		LEFT JOIN ld_users b ON a.smownerid=b.id
		LEFT JOIN ld_account c ON a.accountid=c.accountid
		LEFT JOIN (
			SELECT salesorderid AS order_id,currency_id,conversion_rate,currency_symbol,total,received_amount,`subject`,salesorder_no AS order_no FROM ld_salesorder where deleted=0
			UNION ALL 
			SELECT servicecontractsid,currency_id,conversion_rate,currency_symbol,total,received_amount,`subject`,contract_no FROM ld_servicecontracts  where deleted=0
			UNION ALL 
			SELECT invoiceid,currency_id,conversion_rate,currency_symbol,total,received_amount,`subject`,invoice_no FROM ld_invoice  where deleted=0
			UNION ALL 
			SELECT out_id,currency_id,conversion_rate,currency_symbol,total,received_amount,'',out_no FROM ld_outboundorder  where deleted=0
		) d ON d.order_id=a.entitytypeid
		LEFT JOIN (
			SELECT
				CASE 
                    WHEN b.entitytype='PaymentPlan' THEN
                        (SELECT entitytypeid FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
                    ELSE b.entitytypeid
                END AS entitytypeid,
				SUM(c.rmb_total) AS rmb_total
			FROM ld_expense a
			LEFT JOIN ld_expensedetail b ON a.expenseid=b.expenseid
			LEFT JOIN ld_expensedetailscf c ON c.expensedetailid=b.expensedetailid
			WHERE a.deleted=0
				AND a.expensedate BETWEEN DATE_FORMAT('$start_date','%Y-%m-%d') AND DATE_FORMAT('$end_date','%Y-%m-%d')
				AND b.entitytype in ('SalesOrder','ServiceContracts')
				AND IFNULL(a.approvestatus,'')<>'已拒绝'
				AND (
					CASE
						WHEN '$fee_range'='false' THEN 1=1
						ELSE a.approvestatus='已批准'
					END)
			GROUP BY b.entitytypeid
		) e ON e.entitytypeid=a.entitytypeid
			LEFT JOIN (
				SELECT
					b.entitytypeid,
					SUM(b.amount/IFNULL(a.conversion_rate,1)) AS total_yj
				FROM ld_commission a
				LEFT JOIN ld_commission2payment b ON a.commission_id=b.commission_id
				WHERE a.deleted=0
					AND a.expensedate BETWEEN DATE_FORMAT('$start_date','%Y-%m-%d') AND DATE_FORMAT('$end_date','%Y-%m-%d')
					AND b.entitytype in ('SalesOrder','ServiceContracts')
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
					AND (
						CASE
							WHEN '$fee_range'='false' THEN 1=1
							ELSE a.approvestatus='已批准'
						END)
				GROUP BY b.entitytypeid
			) f ON f.entitytypeid=a.entitytypeid
		LEFT JOIN (
			SELECT
				SUM(b.tax_amount/IFNULL(a.conversion_rate,1)) AS total,
				b.entitytypeid
			FROM ld_purchaseorder a
			LEFT JOIN ld_purchaseorderdetail b ON a.purchaseorderid=b.id
			WHERE a.deleted=0
				AND IFNULL(a.approvestatus,'')<>'已拒绝'
				AND IFNULL(a.postatus,'')<>'已作废'
				AND b.entitytypeid>0
			GROUP BY b.entitytypeid
		) g ON g.entitytypeid=a.entitytypeid
		LEFT JOIN (
			SELECT
				id,	
				SUM(productcost) AS productcost
			FROM (
				SELECT
					id,
					CASE 
						WHEN IFNULL(a.productcost,0)>0 THEN a.quantity*a.productcost/IFNULL(c.conversion_rate,1)
						ELSE a.quantity*IFNULL(b.costprice,0)
					END AS productcost
				FROM (
					SELECT
						id,
						productid,
						quantity,
						productcost
					FROM ld_salesorderdetail
					UNION ALL
					SELECT
						id,
						productid,
						quantity,
						productcost
					FROM ld_servicecontractsdetail
					) a
				LEFT JOIN ld_products b ON a.productid=b.productid
				LEFT JOIN (
					SELECT salesorderid AS orderid,conversion_rate FROM ld_salesorder
					UNION ALL
					SELECT servicecontractsid,conversion_rate FROM ld_servicecontracts
					UNION ALL 
					SELECT invoiceid,conversion_rate FROM ld_invoice
					UNION ALL 
					SELECT out_id,conversion_rate FROM ld_outboundorder
					) c ON a.id=c.orderid
			) a
			GROUP BY id
		) h ON h.id=a.entitytypeid
		LEFT JOIN (
			SELECT
				a.orderid,
				sum(b.quantity*IFNULL(c.costprice,0)) as total
			FROM (
				SELECT salesorderid AS orderid,conversion_rate FROM ld_salesorder
				UNION ALL
				SELECT servicecontractsid,conversion_rate FROM ld_servicecontracts
			) a
			LEFT JOIN (
				SELECT id,productid,quantity,productcost FROM ld_salesorderdetail
				UNION ALL
				SELECT id,productid,quantity,productcost FROM ld_servicecontractsdetail
			) b ON a.orderid=b.id
			LEFT JOIN (
				SELECT
					b.productid,
					sum(b.tax_amount/IFNULL(a.conversion_rate,1))/sum(b.quantity) as costprice
				FROM ld_purchaseorder a
				LEFT JOIN ld_purchaseorderdetail b ON a.purchaseorderid=b.id
				WHERE a.deleted=0
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
					AND IFNULL(a.postatus,'')<>'已作废'
				GROUP BY b.productid
			) c ON c.productid=b.productid
			GROUP BY a.orderid
		) m ON m.orderid=a.entitytypeid
		LEFT JOIN (
			SELECT
				SUM(b.tax_amount/IFNULL(a.conversion_rate,1)) AS total,
				b.entitytypeid
			FROM ld_outboundorder a
			LEFT JOIN ld_outboundorderdetail b ON a.out_id=b.id
			WHERE a.deleted=0
				AND IFNULL(a.approvestatus,'')<>'已拒绝'
				AND b.entitytypeid>0
			GROUP BY b.entitytypeid
		) n ON n.entitytypeid=a.entitytypeid	
		LEFT JOIN (
			SELECT
				entitytypeid,
				cashbillid
			FROM (
				SELECT
					a.cashbillid,
					a.cashbilldate,
					CASE 
                        WHEN b.entitytype='PaymentPlan' THEN
                            (SELECT entitytypeid FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
                        ELSE b.entitytypeid
                    END AS entitytypeid
				FROM ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b ON a.cashbillid=b.CashBillID
				WHERE a.deleted=0
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
					AND b.entitytypeid>0
					AND (
						CASE 
							WHEN EXISTS (SELECT 1 from ld_systems_deploy where deploy_type=83 and deploy_value=0) THEN 1=1
							ELSE a.approvestatus='已批准'
						END)
					ORDER BY a.cashbilldate,a.cashbillid
			) a GROUP BY entitytypeid
		) i ON i.entitytypeid=a.entitytypeid
		LEFT JOIN (
			SELECT
				entitytypeid,
				cashbillid
			FROM (
				SELECT
					a.cashbillid,
					a.cashbilldate,
					CASE 
                        WHEN b.entitytype='PaymentPlan' THEN
                            (SELECT entitytypeid FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
                        ELSE b.entitytypeid
                    END AS entitytypeid
				FROM ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b ON a.cashbillid=b.CashBillID
				WHERE a.deleted=0
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
					AND b.entitytypeid>0
					AND a.cashbilldate BETWEEN DATE_FORMAT('$start_date','%Y-%m-%d') AND DATE_FORMAT('$end_date','%Y-%m-%d')
					AND (
						CASE 
							WHEN EXISTS (SELECT 1 from ld_systems_deploy where deploy_type=83 and deploy_value=0) THEN 1=1
							ELSE a.approvestatus='已批准'
						END)
					ORDER BY a.cashbilldate,a.cashbillid
			) a GROUP BY entitytypeid
		) j ON j.entitytypeid=a.entitytypeid
		WHERE 1=1
			AND (
				CASE
					WHEN '$accountname'='' THEN	1=1
					ELSE accountname like '%$accountname%'		
				END)
	) temp
	UNION ALL
	SELECT
		a.last_name,
		a.wx_userid,
		t.smownerid,
		2 AS order2,
		t.order_id,
		t.order_no,
		t.expensedate,
		t.accountid,
		b.accountname,
		'' AS entitytypeid,
		'￥0.00' total_display,
		0 total_rmb,
		'' AS source_no,
		'' AS source_displaytotal,
		0 AS source_rmbtotal,
		0 AS source_rmbsubtotal,
		'' AS source_displayreceived,
		0 AS source_rmbreceived,
		0 AS source_rmbsubreceived,
		0 AS total_cost,
		t.total_fy,
		t.total_yj
	FROM (
		(SELECT
			a.smownerid,
			a.expenseid AS order_id,
			a.accountid,
			a.expense_no AS order_no,
			a.expensedate,
			a.total/IFNULL(conversion_rate,1) AS total_fy,
			0 AS total_yj
		FROM ld_expense a
		LEFT JOIN ld_expensedetail b ON a.expenseid=b.expenseid
		WHERE a.deleted=0
			AND a.accountid>0
			AND b.entitytypeid NOT IN (
				SELECT DISTINCT
					CASE 
						WHEN b.entitytype='PaymentPlan' THEN
							(SELECT entitytypeid FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
						ELSE b.entitytypeid
					END AS entitytypeid
				FROM ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b ON a.cashbillid = b.CashBillID
				WHERE a.deleted=0
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
					AND a.cashbilldate BETWEEN DATE_FORMAT('$start_date','%Y-%m-%d') AND DATE_FORMAT('$end_date','%Y-%m-%d')
					AND (
						CASE 
							WHEN EXISTS (SELECT 1 from ld_systems_deploy where deploy_type=83 and deploy_value=0) THEN 1=1
							ELSE a.approvestatus='已批准'
						END)
				)		
			AND a.expensedate BETWEEN DATE_FORMAT('$start_date','%Y-%m-%d') AND DATE_FORMAT('$end_date','%Y-%m-%d')
			AND (
				CASE
					WHEN '$fee_range'='false' THEN 1=1
					ELSE a.approvestatus='已批准'
				END)
		GROUP BY a.expenseid)
		UNION ALL
		(SELECT
			a.smownerid,
			a.commission_id,
			a.accountid,
			a.commission_no,
			a.expensedate,
			0 AS total_fy,
			a.total/IFNULL(conversion_rate,1) AS total_yj
		FROM ld_commission a
		LEFT JOIN ld_commission2payment b ON a.commission_id=b.commission_id
		WHERE a.deleted=0
			AND a.accountid>0
			AND b.entitytypeid NOT IN (
				SELECT DISTINCT
					CASE 
						WHEN b.entitytype='PaymentPlan' THEN
							(SELECT entitytypeid FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
						ELSE b.entitytypeid
					END AS entitytypeid
				FROM ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b ON a.cashbillid = b.CashBillID
				WHERE a.deleted=0
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
					AND a.cashbilldate BETWEEN DATE_FORMAT('$start_date','%Y-%m-%d') AND DATE_FORMAT('$end_date','%Y-%m-%d')
					AND (
						CASE 
							WHEN EXISTS (SELECT 1 from ld_systems_deploy where deploy_type=83 and deploy_value=0) THEN 1=1
							ELSE a.approvestatus='已批准'
						END)
				)
			AND a.expensedate BETWEEN DATE_FORMAT('$start_date','%Y-%m-%d') AND DATE_FORMAT('$end_date','%Y-%m-%d')
			AND (
				CASE
					WHEN '$fee_range'='false' THEN 1=1
					ELSE a.approvestatus='已批准'
				END)
		GROUP BY a.commission_id)
	) t
	LEFT JOIN ld_users a ON a.id=t.smownerid
	LEFT JOIN ld_account b ON b.accountid=t.accountid
) a
LEFT JOIN (
	SELECT
		smownerid AS ownerid,
		done_toal,
		done_rate,
		paymentamount,
		CASE
			WHEN EXISTS (SELECT 1 FROM ld_userreport_commissionrule WHERE is_on='yes' AND unit='万元' AND bytype='byCash') THEN
				(SELECT commission_rate FROM ld_userreport_commissionrule WHERE is_on='yes' AND unit='万元' AND bytype='byCash' AND t.done_toal>=`start`*10000 AND t.done_toal<`end`*10000  ORDER BY `start` LIMIT 1)
			ELSE 
				(SELECT commission_rate FROM ld_userreport_commissionrule WHERE is_on='yes' AND unit='%' AND bytype='byCash' AND t.done_rate>=`start` AND t.done_rate<`end` ORDER BY `start` LIMIT 1)
		END AS ticheng_rate
	FROM (
		SELECT
			a.smownerid,
			a.done_toal,
			CASE
				WHEN IFNULL(b.paymentamount,0)=0 THEN 0
				ELSE b.paymentamount
			END paymentamount,
			CASE
				WHEN IFNULL(b.paymentamount,0)=0 THEN 0
				ELSE a.done_toal*100/IFNULL(b.paymentamount,0)
			END AS done_rate
		FROM (
			SELECT
				a.smownerid,
				SUM(a.total) AS done_toal
			FROM (
				SELECT
					smownerid,
					total/IFNULL(conversion_rate,1) AS total
				FROM ld_cashbill
				WHERE deleted=0
					AND IFNULL(approvestatus,'')<>'已拒绝'
					AND cashbilldate BETWEEN DATE_ADD(DATE_FORMAT('$start_date','%Y-%m-%d'),INTERVAL - DAY('$start_date')+1 DAY) AND LAST_DAY(DATE_FORMAT('$end_date','%Y-%m-%d'))
			) a
			GROUP BY a.smownerid
		) a
		LEFT JOIN (
			SELECT
                userid, SUM(paymentamount) AS paymentamount
            FROM (
                    SELECT record AS userid, targetvalue AS paymentamount, ld_salestarget_info.*
                    FROM ld_salestarget_info LEFT JOIN ld_salestarget_basic ON ld_salestarget_basic.targetid = ld_salestarget_info.targetid
                    WHERE ld_salestarget_basic.targetname = 'paymentamount'
                    GROUP BY record, targetyear, targetmonth
            ) ld_salestarget
			WHERE DATE_FORMAT(CONCAT(targetyear,'-',targetmonth,'-01'),'%Y-%m-%d') BETWEEN DATE_ADD(DATE_FORMAT('$start_date','%Y-%m-%d'),INTERVAL - DAY('$start_date')+1 DAY) AND LAST_DAY(DATE_FORMAT('$end_date','%Y-%m-%d'))
			GROUP BY userid
		) b ON b.userid=a.smownerid
	) t
) b ON b.ownerid=a.smownerid
WHERE FIND_IN_SET(smownerid,'$data_range')
	AND (
		CASE
			WHEN '$accountname'='' THEN	1=1
			ELSE accountname like '%$accountname%'		
		END) and source_no is not null and source_no != ''
ORDER BY CONVERT(last_name USING GBK),order2,cashbilldate,cashbill_no";


//echo $sql;
return $sql;
    }
}