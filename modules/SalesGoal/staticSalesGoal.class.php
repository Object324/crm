<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-07-01
 */
class staticSalesGoal {
	private static $usertotal = array();//用户总计
	private static $usertotalOld = array();//用户总计
	private static $monthtotal = array();//月度总计
	private static $grouptotal = array();//部门每月总计
	private static $grouptotal_all = array();//部门用户小计总计
	private static $usertotal_all = array();//总用户合计
    public static  $morethanzerouserid_arr=[];//有销售目标的用户
    public static $length_amountdecimal;
    /**
     * 构造函数
     * @author Tujt 2015-07-01
     */
    public function __construct() {
    }
    
    public static function getAmountDecimal(){
        if(!empty(self::$length_amountdecimal))return self::$length_amountdecimal;
        $system_351 = getSys_deploy(351);//单据分录明细金额字段和单据头货币字段小数位数
        $system_deploy_351 = 2;
        if(is_numeric($system_351['deploy_value'])){
            $system_deploy_351 = $system_351['deploy_value'];    
        }
        $length_amountdecimal = $system_deploy_351;
        return $length_amountdecimal;
    }
	/**
	 * 获取销售目标用户结果集
	 * @param String $scope 查看范围
	 * @returns Array User用户结果集
	 * @author Tujt 2015-07-01
	 */
	public static function getUserInfo($scope='') {
		global $current_user;
		$MergeSmowner = getCurSmOwnerSearchScope('SalesGoal');
		$UserArr = $MergeSmowner['UserCombo'];
	    if(!empty($scope)){
			switch($scope){
			    case 'SmOwner_Search_All':
				case 'SmOwner_Search_Create':
				case 'SmOwner_Search_SubRole':
				    $users = getScopeUserName('All',1,$UserArr);
			        break;
			    case 'SmOwner_Search_Me':
			        $users = getScopeUserName('person',$current_user->id,$UserArr);
			        break;
				case 'smowner_search_senior':
				   $users = getScopeUserName('senior',$scope,$_REQUEST['senioruserid']);
				   break;
				default:
					$users = array($scope=>getOwnerName($scope));
			}
		}else{
			$users = getScopeUserName('All',1,$UserArr);
		}
		return $users;
	}
	public static function getMonthTotal(){
		return self::$monthtotal;
	}
	/**
	 * 获取销售目标排列列表
	 * @author Tujt 2015-07-01
	 */
	public static function getUserSalesGoalInfo($users,$yearmonth,$module_look,$usersGroup) {
	    if(empty($users)) return '';
		$salesgoal = '';
		$curr_rate='¥';
		$salestarget = self::getSalesGoalToLook($yearmonth,$module_look);//获取目标值信息
		$salesgoalarr = self::getSalesGoalOverInfo($module_look,$yearmonth);//完成
		self::$usertotal = array();
		self::$monthtotal = array();
		self::$grouptotal = array();
		self::$grouptotal_all = array();
		if($module_look == 'accountsnumber')$curr_rate='';
        $num=0;
        $tempUseridArr= array(); //单用户多部门 避免单人业绩累加
        $groupUserIds =array();
        foreach ($usersGroup as $k =>$usersGroupArr){
            foreach ($usersGroupArr as $key =>$userArr){
                $userId = $userArr['userid'];
                if(!array_key_exists($userId,$salestarget))
                {
                   
                    foreach($yearmonth as $month){
                        $month = self::toDate('Y-m',$month);
                        self::$monthtotal[$month]['tolook'] += 0;
                        self::$monthtotal[$month]['complete']+= 0;
                    }
                    continue;
                }
                 
                ++$num;
                if($num%2==0){
                    $salesgoal.='<tr class="lvtColDataBj" onmouseover="listOnMouseOver('.$num.');" onmouseout="listOnMouseOut('.$num.',\'On\');" id="row_'.$num.'">';
                }
                else{
                    $salesgoal.='<tr class="lvtColData" onmouseover="listOnMouseOver('.$num.');" onmouseout="listOnMouseOut('.$num.',\'on\');" id="row_'.$num.'">';
                }
                
                $groupUserIds[$k][] = $userId;
                foreach($yearmonth as $month){
                    $month = self::toDate('Y-m',$month);
                    $tolook = 0;//目标值
                    if(isset($salestarget[$userId][$month][$module_look])){
                        $tolook = $salestarget[$userId][$month][$module_look];
                    }
                    self::$usertotal[$userArr['groupid']][$userId]['tolook'] += $tolook;

                    self::$grouptotal[$userArr['groupid']][$month]['tolook'] += $tolook;  //部门每月统计
                    self::$grouptotal_all[$userArr['groupid']]['tolook'] += $tolook; //部门总统计

                    $salesgoal .= '<td style="background:transparent;"><div>'.$curr_rate.self::formateValue($tolook,$module_look).'</div></td>';
                    $complete = 0;//目标值
                    if(isset($salesgoalarr[$module_look][$userId][$month])){
                        $complete = $salesgoalarr[$module_look][$userId][$month];
                    }
                    self::$usertotal[$userArr['groupid']][$userId]['complete'] += $complete;
                    if(!in_array($userArr['userid'].$month,$tempUseridArr)){
                        $tempUseridArr[] = $userArr['userid'].$month;
                        self::$monthtotal[$month]['tolook'] += $tolook;
                        self::$monthtotal[$month]['complete'] += $complete;
                    }else{
                        //单列的时候设置下默认值
                        self::$monthtotal[$month]['tolook'] +=0;
                        self::$monthtotal[$month]['complete'] +=0;
                    }
                      
                    self::$grouptotal[$userArr['groupid']][$month]['complete'] += $complete;
                    self::$grouptotal_all[$userArr['groupid']]['complete'] += $complete;

                        // @edit:dong @date:2020/09/15 @reason: bug 0042650  销售目标，目标查看界面，每个月的部门小计完成率计算错误
                    if(self::$grouptotal[$userArr['groupid']][$month]['complete']>0 && self::$grouptotal[$userArr['groupid']][$month]['tolook']>0){
                        self::$grouptotal[$userArr['groupid']][$month]['percent'] = sprintf('%.2f',self::$grouptotal[$userArr['groupid']][$month]['complete']/self::$grouptotal[$userArr['groupid']][$month]['tolook']*100);
                    }else{
                        self::$grouptotal[$userArr['groupid']][$month]['percent'] =0;
                    }
                    $salesgoal .= '<td style="background:transparent;">';

                    if($complete >0){
                        $salesgoal .='<a href="javascript:void(0)" userid="'.$userArr['userid'].'" search_date_value="'.$month.'" module_look="'.$module_look.'" onclick="openUserCompleteUrl(ld(this))">'.$curr_rate.self::formateValue($complete,$module_look).'</a>';
                    }else{
                        $salesgoal .='<div>'.$curr_rate.self::formateValue($complete,$module_look).'</div>';
                    }

                    $salesgoal .= '</td>';
                    $percent = 0;
                    if($tolook > 0 && $complete > 0){
                        //$percent = setNumberFormat(round($complete/$tolook*100,0));
                        $percent = sprintf('%.2f',$complete/$tolook*100);
                    }

                    if($percent>100){
                        $salesgoal .= '<td style="background:transparent;color:red" ><div id="'.$userId.'listgoal'.$month.'">'.$percent.'%</div></td>';

                    }else if($percent<100){
                        $salesgoal .= '<td style="background:transparent;color:green"><div id="'.$userId.'listgoal'.$month.'">'.$percent.'%</div></td>';

                    }else
                    $salesgoal .= '<td style="background:transparent;"><div id="'.$userId.'listgoal'.$month.'">'.$percent.'%</div></td>';
                }
                $salesgoal .= '</tr>';
            }

            ++$num;
//            @edit:liushuai,2021-04-21,reason: 45545: （https://61mis.com/kfbcrm [^] ）“销售目标”中的“目标查看”，里面内容格式混乱（多出一条空tr）
//            $salesgoal.='<tr class="lvtColData" onmouseover="listOnMouseOver('.$num.');" onmouseout="listOnMouseOut('.$num.',\'On\');" id="row_'.$num.'">';

            foreach (self::$grouptotal[$k] as $month =>$subValue){
                $salesgoal .= '<td class="subtotal">' .$curr_rate.self::formateValue($subValue['tolook'],$module_look).'</td>';
                if($subValue['complete'] >0){
                    $salesgoal .= '<td class="subtotal"><a href="javascript:void(0)" userid="'.implode($groupUserIds[$k],',').'" search_date_value="'.$month.'"  module_look="'.$module_look.'"  onclick="openUserCompleteUrl(ld(this))">'.$curr_rate.self::formateValue($subValue['complete'],$module_look).'</a></td>';
                }else{
                    $salesgoal .='<td class="subtotal">'.$curr_rate.self::formateValue($subValue['complete'],$module_look).'</td>';
                }

                if($subValue['percent']>100){
                    $salesgoal .= '<td style="color:red;"><div>'.$subValue['percent'].'%</div></td> ';
                }else if($subValue['percent']<100){
                    $salesgoal .= '<td style="color:green;"><div>'.$subValue['percent'].'%</div></td> ';
                }else
                $salesgoal .='<td class="subtotal">'.$subValue['percent'].'%</td>';
            }
            $salesgoal .= '</tr>';
        }
		return $salesgoal;
	}
	/**
	 * 获取销售目标合计值
	 * @author Tujt 2015-07-01
	 */
	public function getUserSalesGoalSum($usersGroup) {
	 
		if(empty(self::$usertotal)) return '';
		if (empty($usersGroup)) return '';
		$salesgoal = '';
		$curr_rate='¥';
		$tolook = 0;
		$complete = 0;
		self::$usertotal_all = array();
		if(isset($_REQUEST['module_look']) && $_REQUEST['module_look'] == 'accountsnumber')$curr_rate='';
        $module_look = $_REQUEST['module_look'];
		$tempUseridArr= array(); //单用户多部门 避免单人业绩累加
        foreach ($usersGroup as $groupid =>$usersGroupArr){
            foreach ($usersGroupArr as $key =>$userArr){
                if(!array_key_exists($userArr['userid'],self::$morethanzerouserid_arr))
                {
                    continue;
                }
                $tempTolook =self::$usertotal[$groupid][$userArr['userid']]['tolook'];
                $tempComplete =self::$usertotal[$groupid][$userArr['userid']]['complete'];
                $salesgoal .= '<tr>';
                $salesgoal .= '<td><div>'.$curr_rate.self::formateValue($tempTolook,$module_look).'</div></td> ';
                $salesgoal .= '<td><div>'.$curr_rate.self::formateValue($tempComplete,$module_look).'</div></td> ';
                $percent = 0;
                if($tempTolook > 0 && $tempComplete > 0){
                    //$percent = setNumberFormat(round($total['complete']/$total['tolook']*100,0));
                    $percent = sprintf('%.2f',$tempComplete/$tempTolook*100);
                }
                if($percent>100){
                    $salesgoal .= '<td style="color:red;"><div>'.$percent.'%</div></td> ';
                }else if($percent<100){
                    $salesgoal .= '<td style="color:green;"><div>'.$percent.'%</div></td> ';
                }else
                $salesgoal .= '<td><div>'.$percent.'%</div></td> ';
                $salesgoal .= '</tr>';
                if(!in_array($userArr['userid'],$tempUseridArr)){
                    $tempUseridArr[] = $userArr['userid'];
                    $tolook += $tempTolook;
                    $complete += $tempComplete;
                }
            }
            
            //输出部门小计
            if(self::$grouptotal_all[$groupid]['tolook'] >0 && self::$grouptotal_all[$groupid]['complete']>0){
                self::$grouptotal_all[$groupid]['percent'] = sprintf('%.2f',self::$grouptotal_all[$groupid]['complete']/self::$grouptotal_all[$groupid]['tolook']*100);
            }
            else{
               // self::$grouptotal_all[$groupid]['percent'] =0;
            }
            //如果部门没有记录，将不显示部门合计
            // edit:hzx 46360: (81mis.com/kfbcrm/)销售管理-销售目标-目标查看-合计页签界面没对齐，有多余行列（将为0的去掉就可以对齐了）
            if(self::$grouptotal_all[$groupid]['tolook'] >0 || self::$grouptotal_all[$groupid]['complete']>0){
                $salesgoal .= '<tr>';
                $salesgoal .= '<td  class="subtotal"><div>'.$curr_rate.self::formateValue(self::$grouptotal_all[$groupid]['tolook'],$module_look).'</div></td> ';
                $salesgoal .= '<td class="subtotal"><div>'.$curr_rate.self::formateValue(self::$grouptotal_all[$groupid]['complete'],$module_look).'</div></td> ';
                if(self::$grouptotal_all[$groupid]['percent']>100){
                    $salesgoal .= '<td class="subtotal" style="color:red;"><div>'.self::$grouptotal_all[$groupid]['percent'].'%</div></td> ';
//                    $salesgoal .= '<td style="color:red;"><div>'.$percent.'%</div></td> ';
                }else if(self::$grouptotal_all[$groupid]['percent']<100){
//                    $salesgoal .= '<td style="color:green;"><div>'.$percent.'%</div></td> ';
                    $salesgoal .= '<td class="subtotal" style="color:green;"><div>'.self::$grouptotal_all[$groupid]['percent'].'%</div></td> ';

                }else
                $salesgoal .= '<td class="subtotal"><div>'.self::$grouptotal_all[$groupid]['percent'].'%</div></td> ';
                $salesgoal .= '</tr>';
            }

        }
        self::$usertotal_all['tolook'] = $tolook;
        self::$usertotal_all['complete'] = $complete;
        if($tolook>0 && $complete>0){
            self::$usertotal_all['percent'] = setNumberFormat(sprintf('%.2f',$complete/$tolook*100));
        }else{
            self::$usertotal_all['percent'] =0;
        }

		return $salesgoal;
	}

	public function getUserSalesGoalSum_All(){
		return self::$usertotal_all;
	}
	/**
	 * 得到目标值
	 * @author Tujt 2015-07-01
	 */
	public static function getSalesGoalToLook($yearmonth,$module_look) {
	    global $adb;
        //zxm 2022-0317 应收单 应收额目标  上海庆科
        $tradeInfo = getVersionTradeInfo();
        $otherField = '';
        if($tradeInfo['account']=='sh_qingke'){
            $otherField = ',receivableamount';
        }
		$query = 'SELECT userid,targetyear,targetmouth,paymentamount,contractamount,accountsnumber,invoiceamount,outboundorderamount  '.$otherField.'
					FROM ld_salestarget WHERE ';
		//整理出开始时间和结束时间
		list($start,$end) = self::getFilterDateInfo($yearmonth);
		$startarr = explode('-',$start);
		$endarr = explode('-',$end);
		$query .= ' (';
        $start_month_arr=explode("-",$yearmonth[0]);
        $end_month_arr=explode("-",$yearmonth[sizeof($yearmonth)-1]);
		if($startarr[0] == $endarr[0]){
		      //相同的年份
			$query .= '(targetyear >= '.$startarr[0].' and targetmouth>='.$start_month_arr[1].' ) and  ( targetmouth<='.$end_month_arr[1].'  and targetyear <= '.$endarr[0].' )';
		}else{
            $query.='  case when targetyear= '.$startarr[0] .' then targetmouth>='.$start_month_arr[1].' when targetyear= '.$endarr[0] .' then targetmouth<='.$end_month_arr[1] .' end ' ;
		}
		$query .= ') ';
		$query .= 'ORDER BY id ';

		$result = $adb->query($query);
		$rows = $adb->num_rows($result);
		$salestarget = array();
      
        
		if($rows > 0){
			for($i=0;$i<$rows;++ $i){
				$userid = $adb->query_result($result,$i,'userid');
				$targetyear = $adb->query_result($result,$i,'targetyear');
				$targetmouth = $adb->query_result($result,$i,'targetmouth');
				$paymentamount = $adb->query_result($result,$i,'paymentamount');
				$contractamount = $adb->query_result($result,$i,'contractamount');
				$accountsnumber = $adb->query_result($result,$i,'accountsnumber');
				$invoiceamount = $adb->query_result($result,$i,'invoiceamount');
				$outboundorderamount = $adb->query_result($result,$i,'outboundorderamount');
                if($tradeInfo['account']=='sh_qingke'){
                    $receivableamount = $adb->query_result($result,$i,'receivableamount');
                }

				$goal_date = $targetyear.'-'.$targetmouth;
				$goal_date = self::toDate('Y-m',$goal_date);
				$salestarget[$userid][$goal_date]['paymentamount'] = $paymentamount;
                
				$salestarget[$userid][$goal_date]['contractamount'] = $contractamount;
				$salestarget[$userid][$goal_date]['accountsnumber'] = $accountsnumber;
				$salestarget[$userid][$goal_date]['invoiceamount'] = $invoiceamount;
				$salestarget[$userid][$goal_date]['outboundorderamount'] = $outboundorderamount;
                if($tradeInfo['account']=='sh_qingke'){
                    $salestarget[$userid][$goal_date]['receivableamount'] = $receivableamount;
                }


                if(!empty($paymentamount)&&$paymentamount!="0.00"&&$module_look=='paymentamount')
                {
                   self::$morethanzerouserid_arr[$userid]=$userid;
                }
                else if(!empty($contractamount)&&$contractamount!="0.00"&&$module_look=='contractamount')
                {
                    
                    
                    self::$morethanzerouserid_arr[$userid]=$userid;
                }
                else  if(!empty($accountsnumber)&&$accountsnumber!="0.00"&&$module_look=='accountsnumber')
                {
                    
                    self::$morethanzerouserid_arr[$userid]=$userid;
                }
                else  if(!empty($invoiceamount)&&$invoiceamount!="0.00"&&$module_look=='invoiceamount')
                {
                    self::$morethanzerouserid_arr[$userid]=$userid;
                }
                else  if(!empty($outboundorderamount)&&$outboundorderamount!="0.00"&&$module_look=='outboundorderamount')
                {
                    self::$morethanzerouserid_arr[$userid]=$userid;
                }
                else  if(!empty($receivableamount)&&$receivableamount!="0.00"&&$module_look=='receivableamount')
                {
                    self::$morethanzerouserid_arr[$userid]=$userid;
                }
			}
		}
    
       //edit:can 20210128 销售目标功能优化，目标查看界面去掉目标为0的记录
        $goal_arr=[];
        foreach( $salestarget as $tmpuserid =>$goalinfo)
        {
            if(array_key_exists($tmpuserid,self::$morethanzerouserid_arr))
            {
                $goal_arr[$tmpuserid]=$goalinfo;
            }
        }
		return $goal_arr;
	}
	/**
	 * 得到目标完成值
	 * @author Tujt 2015-07-01
	 */
	public static function getSalesGoalOverInfo($type,$yearmonth) {
		global $adb;
		//整理出开始时间和结束时间
        $tradeInfo = getVersionTradeInfo();
        $sostatus_cancel = '已作废';
        //zxm 2022-6-16 四川中兴  合同订单已作废的值改成了 已作废（Voided）  //史文龙讲了只改合同订单的
        if($tradeInfo['account']=='sczhongxing'){
            $sostatus_cancel = '已作废（Voided）';
        }
		list($start,$end) = self::getFilterDateInfo($yearmonth);
        $length_amountdecimal = self::getAmountDecimal();
	    switch($type){
	        case 'paymentamount':
				$group_by = 'FROM_UNIXTIME(UNIX_TIMESTAMP(ld_cashbill.cashbilldate),\'%Y-%m\')';
	            $query = 'SELECT ld_cashbill.smownerid,'.$group_by.' AS goal_date,
							SUM(
								IF(
									ld_cashbill.currency_id > 1,
									ld_cashbill.Total/ld_cashbill.conversion_rate,ld_cashbill.Total
								)
							) AS total 
						FROM ld_cashbill WHERE ld_cashbill.deleted=0 AND ld_cashbill.`cashbillid` > 0 
						AND ld_cashbill.smownerid > 0 AND IFNULL(ld_cashbill.cashbilldate,0) != 0 ';
				$query .= 'AND ld_cashbill.cashbilldate between \''.$start.'\' and \''.$end.'\' ';
				//已收金额计算时是否统计未审核的收款单
				$focus = CRMEntity::getInstance('CashBill');
				$query .= $focus->get_CashBillCheckoutstatusWhere();
				$query .= 'GROUP BY ld_cashbill.smownerid,'.$group_by.' ';
	            break;
	        case 'contractamount':
            //edit:can 20210427 45668: (http://39.99.139.162:6090/crm/ [^])客户问题-工具-销售目标-目标查看-未统计4月份的数据
	            $group_by = 'FROM_UNIXTIME(UNIX_TIMESTAMP(ld_salesorder.signed_data),\'%Y-%m\')';
	            $query = 'SELECT ld_salesorder.smownerid,'.$group_by.' AS goal_date,
							SUM(
								IF(
									ld_salesorder.currency_id > 1,
									ld_salesorder.total/ld_salesorder.conversion_rate,ld_salesorder.total
								)
							) as total 
						FROM ld_salesorder WHERE ld_salesorder.deleted = 0 AND ld_salesorder.salesorderid > 0 
							AND ifnull(ld_salesorder.sostatus,\'\') != \''.$sostatus_cancel.'\' AND ld_salesorder.smownerid > 0 
							AND IFNULL(ld_salesorder.signed_data,0) != 0 ';
				$query .= 'AND ld_salesorder.signed_data between \''.$start.'\' and \''.$end.'\' ';
				$query .= 'GROUP BY ld_salesorder.smownerid,'.$group_by.' ';
              
	            break;
			case 'accountsnumber':
			    $group_by = 'FROM_UNIXTIME(UNIX_TIMESTAMP(ld_account.createdtime),\'%Y-%m\')';
	            $query = 'SELECT ld_account.smownerid,'.$group_by.' AS goal_date,
							COUNT(ld_account.accountid) AS total 
						FROM ld_account WHERE ld_account.deleted = 0 AND ld_account.accountid > 0 
							AND ld_account.smownerid > 0 
							AND IFNULL(ld_account.createdtime,0) != 0 ';
				$query .= 'AND ld_account.createdtime between \''.$start.'\' and \''.$end.'\' ';
				$query .= 'GROUP BY ld_account.smownerid,'.$group_by.' ';
			    break;
			case 'invoiceamount':
			   $group_by = 'FROM_UNIXTIME(UNIX_TIMESTAMP(ld_invoice.invoicedate),\'%Y-%m\')';
		       $query = 'SELECT ld_invoice.smownerid,'.$group_by.' AS goal_date,
							SUM(
								IF(
									ld_invoice.currency_id > 1,
									ld_invoice.total/ld_invoice.conversion_rate,ld_invoice.total
								)
							) as total 
						FROM ld_invoice WHERE ld_invoice.deleted = 0 AND ld_invoice.smownerid > 0 
							AND IFNULL(ld_invoice.invoicedate,0) != 0 ';
				$query .= 'AND ld_invoice.invoicedate between \''.$start.'\' and \''.$end.'\' ';
				$query .= 'GROUP BY ld_invoice.smownerid,'.$group_by.' ';
			   break;
			case 'outboundorderamount':
			   $group_by = 'FROM_UNIXTIME(UNIX_TIMESTAMP(ld_outboundorder.outdate),\'%Y-%m\')';
		       $query = 'SELECT ld_outboundorder.smownerid,'.$group_by.' AS goal_date,
							SUM(
								IF(
									ld_outboundorder.currency_id > 1,
									ld_outboundorder.total/ld_outboundorder.conversion_rate,ld_outboundorder.total
								)
							) as total 
						FROM ld_outboundorder WHERE ld_outboundorder.deleted = 0 AND ld_outboundorder.smownerid > 0 
							AND IFNULL(ld_outboundorder.outdate,0) != 0 ';
				$query .= 'AND ld_outboundorder.outdate between \''.$start.'\' and \''.$end.'\' ';
				$deployarray=getSys_deploy(48);
				if($deployarray['deploy_value']==0){
					$query.=' and ld_outboundorder.approvestatus="已批准"';
				}
				$query .= 'GROUP BY ld_outboundorder.smownerid,'.$group_by.' ';
			   break;
			   //zxm 2022-0317 应收单 应收额目标  上海庆科
            case 'receivableamount':
                $group_by = 'FROM_UNIXTIME(UNIX_TIMESTAMP(ld_customform12scf.cf_4425),\'%Y-%m\')';
                $query = 'SELECT ld_customform12.smownerid,'.$group_by.' AS goal_date,
							SUM(
								IF(
									ld_customform12.currency_id > 1,
									ld_customform12.total/ld_customform12.conversion_rate,ld_customform12.total
								)
							) as total 
						FROM ld_customform12 left join ld_customform12scf on ld_customform12.customform12id=ld_customform12scf.customform12id WHERE ld_customform12.deleted = 0 AND ld_customform12.smownerid > 0 
							AND IFNULL(ld_customform12scf.cf_4425,0) != 0 ';
                $query .= 'AND ld_customform12scf.cf_4425 between \''.$start.'\' and \''.$end.'\' ';

                $query .= 'GROUP BY ld_customform12.smownerid,'.$group_by.' ';
                break;
	    }
		$result = $adb->query($query);
		$rows = $adb->num_rows($result);
		$salesgoalarr = array();
		if($rows > 0){
			for($i=0;$i<$rows;++ $i){
				$userid = $adb->query_result($result,$i,'smownerid');
				$goal_date = $adb->query_result($result,$i,'goal_date');
				$total = $adb->query_result($result,$i,'total');
			    $salesgoalarr[$type][$userid][$goal_date] = $total;
			}
		}
		if('contractamount' == $type){//再计算一下服务合同
			$group_by = 'FROM_UNIXTIME(UNIX_TIMESTAMP(ld_servicecontracts.due_date),\'%Y-%m\')';
			$sql = 'SELECT ld_servicecontracts.smownerid,'.$group_by.' AS goal_date,
						SUM(
							IF(
								ld_servicecontracts.currency_id > 1,
								ld_servicecontracts.total/ld_servicecontracts.conversion_rate,ld_servicecontracts.total
							)
						) as total
					FROM ld_servicecontracts WHERE ifnull(ld_servicecontracts.contract_status,\'\') != \''.$sostatus_cancel.'\' and  ld_servicecontracts.deleted = 0 AND ld_servicecontracts.servicecontractsid > 0 
                    ';
          $sql .= ' AND ld_servicecontracts.due_date between \''.$start.'\' and \''.$end.'\' ';
			$sql .= '			AND ld_servicecontracts.smownerid > 0 
						AND IFNULL(ld_servicecontracts.due_date,0) != 0 ';
			$sql .= 'GROUP BY ld_servicecontracts.smownerid,'.$group_by.' ';
          
			$sqlresult = $adb->query($sql);
			$sqlrows = $adb->num_rows($sqlresult);
			if($sqlrows > 0){
				for($i=0;$i<$sqlrows;++ $i){
				    $userid = $adb->query_result($sqlresult,$i,'smownerid');
					$goal_date = $adb->query_result($sqlresult,$i,'goal_date');
					$total = $adb->query_result($sqlresult,$i,'total');
					$goal_date = self::toDate('Y-m',$goal_date);
					if(isset($salesgoalarr[$type][$userid][$goal_date])){
						$salesgoalarr[$type][$userid][$goal_date] += $total;
					}else{
						$salesgoalarr[$type][$userid][$goal_date] = $total;
					}
				}
			}
		}
		return $salesgoalarr;
	}
	/**
	 * 通过传入的时间区间，获取开始时间，和结束时间
	 * @param Array $yearmonth 时间区间
	 * @returns Array 数组，开始时间和结束时间
	 * @author Tujt 2015-07-02
	 */
	public static function getFilterDateInfo($yearmonth) {
	    $start = $yearmonth[0];
		$end = $yearmonth[count($yearmonth)-1];
		$start = self::toDate('Y-m-d',$start);
		$end = self::toDate('Y-m-d',$end);
        $days= DateOperation::getMonthDays($end);
        $end=self::toDate('Y-m',$end).'-'.$days;

		return array($start,$end);
	}
	/**
	 * 获取下一个月的日期
	 * @author Tujt 2015-07-01
	 */
	public static function getNextMonthDays($date){
		$timestamp = strtotime($date);
		$arr = getdate($timestamp);
		$day = sprintf('%02d',$arr['mday']);
		if($arr['mon'] == 12){
			$year = $arr['year'] + 1;
			$month = $arr['mon'] - 11;
			$firstday = $year.'-0'.$month.'-01';
			$currday = $year.'-0'.$month.'-'.$day;
			$lastday = date('Y-m-d',strtotime("$firstday +1 month -1 day"));
		}else{
			$firstday = date('Y-m-01',strtotime(date('Y',$timestamp).'-'.(date('m',$timestamp)+1).'-01'));
			$currday = date('Y-m-d',strtotime(date('Y',$timestamp).'-'.(date('m',$timestamp)+1).'-'.$day));
			$lastday = date('Y-m-d',strtotime("$firstday +1 month -1 day"));
		}
		return array('first'=>$firstday,'next'=>$currday,'last'=>$lastday);
	}
	/**
	 * 获取月份
	 * @author Tujt 2015-07-01
	 */
	public static function toDate($date,$month) {
	    $data = date($date,strtotime($month));
		return $data;
	}
    /**
     * 销售目标设置，获取销售目标列表
     * @author Tujt 2015-07-01
     */
    public static function getSalesGoalInfo($users,$yearmonth,$module_look) {
        if(empty($users)) return '';
        $salesgoal = '';
        $salestarget = self::getSalesGoalToLook($yearmonth,$module_look);//获取目标值信息]
        $num=0;
        foreach($users as $userId=>$userObj){
            ++$num;
            if($num%2==0){
                $salesgoal.='<tr class="lvtColDataBj" onmouseover="listOnMouseOver('.$num.');" onmouseout="listOnMouseOut('.$num.',\'On\');" id="row_'.$num.'">';
            }
            else{
                $salesgoal.='<tr class="lvtColData" onmouseover="listOnMouseOver('.$num.');" onmouseout="listOnMouseOut('.$num.',\'on\');" id="row_'.$num.'">';
            }

            foreach($yearmonth as $month){
                $month = self::toDate('Y-m',$month);
                if($module_look == 'contractamount'){
                    //签约额
                    $contractamount = 0;
                    if(isset($salestarget[$userId][$month]['contractamount'])){
                        $contractamount = $salestarget[$userId][$month]['contractamount'];
                    }
                    self::$usertotalOld[$userId]['contractamount'] += $contractamount;
                    $salesgoal .= '<td style="background:transparent;"><div>¥'.setNumberFormat($contractamount,self::getAmountDecimal()).'</div></td>';
                }else if($module_look == 'paymentamount'){
                    //回款额
                    $paymentamount = 0;
                    if(isset($salestarget[$userId][$month]['paymentamount'])){
                        $paymentamount = $salestarget[$userId][$month]['paymentamount'];
                    }
                    self::$usertotalOld[$userId]['paymentamount'] += $paymentamount;
                    $salesgoal .= '<td style="background:transparent;"><div>¥'.setNumberFormat($paymentamount,self::getAmountDecimal()).'</div></td>';
                }else if($module_look == 'accountsnumber'){
                    //客户数
                    $accountsnumber = 0;
                    if(isset($salestarget[$userId][$month]['accountsnumber'])){
                        $accountsnumber = $salestarget[$userId][$month]['accountsnumber'];
                    }
                    self::$usertotalOld[$userId]['accountsnumber'] += $accountsnumber;
                    $salesgoal .= '<td style="background:transparent;"><div>'.self::formateValue($accountsnumber,$module_look).'</div></td>';
                }else if($module_look == 'invoiceamount'){
                    //开票额
                    $invoiceamount = 0;
                    if(isset($salestarget[$userId][$month]['invoiceamount'])){
                        $invoiceamount = $salestarget[$userId][$month]['invoiceamount'];
                    }
                    self::$usertotalOld[$userId]['invoiceamount'] += $invoiceamount;
                    $salesgoal .= '<td style="background:transparent;"><div>¥'.setNumberFormat($invoiceamount,self::getAmountDecimal()).'</div></td>';
                }else if($module_look == 'outboundorderamount'){
                    //出库额
                    $outboundorderamount = 0;
                    if(isset($salestarget[$userId][$month]['outboundorderamount'])){
                        $outboundorderamount = $salestarget[$userId][$month]['outboundorderamount'];
                    }
                    self::$usertotalOld[$userId]['outboundorderamount'] += $outboundorderamount;
                    $salesgoal .= '<td style="background:transparent;"><div>¥'.setNumberFormat($outboundorderamount,self::getAmountDecimal()).'</div></td>';
                }
                else if($module_look == 'receivableamount'){
                    //应收额
                    $receivableamount = 0;
                    if(isset($salestarget[$userId][$month]['receivableamount'])){
                        $receivableamount = $salestarget[$userId][$month]['receivableamount'];
                    }
                    self::$usertotalOld[$userId]['receivableamount'] += $receivableamount;
                    $salesgoal .= '<td style="background:transparent;"><div>¥'.setNumberFormat($receivableamount,self::getAmountDecimal()).'</div></td>';
                }
            }
            $salesgoal .= '</tr>';
        }
        return $salesgoal;
    }
    /**
     * 获取销售目标设置列表
     * @author Tujt 2015-07-01
     */
    public static function getSalesGoalEditInfo($users,$yearmonth,$module_look) {
        if(empty($users)) return '';
        $salesgoal = '';
        $salestarget = self::getSalesGoalToLook($yearmonth,$module_look);//获取目标值信息
        foreach($users as $userId=>$userObj){
            $salesgoal .= '<tr>';
            foreach($yearmonth as $month){
                $monthkey = self::toDate('Y-m',$month);
                if($module_look == 'contractamount'){
                    //签约额
                    $contractamount = 0;
                    if(isset($salestarget[$userId][$monthkey]['contractamount'])){
                        $contractamount = $salestarget[$userId][$monthkey]['contractamount'];
                    }
                    self::$usertotalOld[$userId]['contractamount'] += $contractamount;
                    $salesgoal .= '<td ><div><input class="detailedViewTextBox" tag="salesgoalvalue" type="text" onfocus="this.style=\'text-align:right;\'" onblur="this.style=\'border:none;text-align:right;\'" value="'.$contractamount.'" id="'.$userId.'-'.$month.'-1" name="'.$userId.'-'.$month.'-1" style="text-align:right;border:none;" size="8" /></div></td>';
                }else if($module_look == 'paymentamount'){
                    //回款额
                    $paymentamount = 0;
                    if(isset($salestarget[$userId][$monthkey]['paymentamount'])){
                        $paymentamount = $salestarget[$userId][$monthkey]['paymentamount'];
                    }
                    self::$usertotalOld[$userId]['paymentamount'] += $paymentamount;
                    $salesgoal .= '<td ><div><input class="detailedViewTextBox" tag="salesgoalvalue" type="text" onfocus="this.style=\'text-align:right;\'" onblur="this.style=\'border:none;text-align:right;\'" value="'.$paymentamount.'" id="'.$userId.'-'.$month.'-2" name="'.$userId.'-'.$month.'-2" style="text-align:right;border:none;" size="8" /></div></td>';
                }else if($module_look == 'accountsnumber'){
                    //客户数
                    $accountsnumber = 0;
                    if(isset($salestarget[$userId][$monthkey]['accountsnumber'])){
                        $accountsnumber = $salestarget[$userId][$monthkey]['accountsnumber'];
                    }
                    self::$usertotalOld[$userId]['accountsnumber'] += $accountsnumber;
                    $salesgoal .= '<td ><div><input class="detailedViewTextBox" tag="salesgoalvalue" type="text" onfocus="this.style=\'text-align:right;\'" onblur="this.style=\'border:none;text-align:right;\'" value="'.$accountsnumber.'" id="'.$userId.'-'.$month.'-3" name="'.$userId.'-'.$month.'-3" style="text-align:right;border:none;" size="8" /></div></td>';
                }else if($module_look == 'invoiceamount'){
                    //开票额
                    $invoiceamount = 0;
                    if(isset($salestarget[$userId][$monthkey]['invoiceamount'])){
                        $invoiceamount = $salestarget[$userId][$monthkey]['invoiceamount'];
                    }
                    self::$usertotalOld[$userId]['invoiceamount'] += $invoiceamount;
                    $salesgoal .= '<td ><div><input class="detailedViewTextBox" type="text" tag="salesgoalvalue" onfocus="this.style=\'text-align:right;\'" onblur="this.style=\'border:none;text-align:right;\'" value="'.$invoiceamount.'" id="'.$userId.'-'.$month.'-4" name="'.$userId.'-'.$month.'-4" style="text-align:right;border:none;" size="8" /></div></td>';
                }else if($module_look == 'outboundorderamount'){
                    //出库额
                    $outboundorderamount = 0;
                    if(isset($salestarget[$userId][$monthkey]['outboundorderamount'])){
                        $outboundorderamount = $salestarget[$userId][$monthkey]['outboundorderamount'];
                    }
                    self::$usertotalOld[$userId]['outboundorderamount'] += $outboundorderamount;
                    $salesgoal .= '<td ><div><input class="detailedViewTextBox" type="text" tag="salesgoalvalue" onfocus="this.style=\'text-align:right;\'" onblur="this.style=\'border:none;text-align:right;\'" value="'.$outboundorderamount.'" id="'.$userId.'-'.$month.'-5" name="'.$userId.'-'.$month.'-5" style="text-align:right;border:none;" size="8" /></div></td>';
                }else if($module_look == 'receivableamount'){
                    //应收额
                    $receivableamount = 0;
                    if(isset($salestarget[$userId][$monthkey]['receivableamount'])){
                        $receivableamount = $salestarget[$userId][$monthkey]['receivableamount'];
                    }
                    self::$usertotalOld[$userId]['receivableamount'] += $receivableamount;
                    $salesgoal .= '<td ><div><input class="detailedViewTextBox" type="text" tag="salesgoalvalue" onfocus="this.style=\'text-align:right;\'" onblur="this.style=\'border:none;text-align:right;\'" value="'.$receivableamount.'" id="'.$userId.'-'.$month.'-6" name="'.$userId.'-'.$month.'-6" style="text-align:right;border:none;" size="8" /></div></td>';
                }
            }
            $salesgoal .= '</tr>';
        }
        return $salesgoal;
    }
	/**
	 * 获取销售目标合计值
	 * @author Tujt 2015-07-01
	 */
	public static function getSalesGoalSum($module_look) {
		if(empty(self::$usertotalOld)) return '';
		$salesgoal = '';
		foreach(self::$usertotalOld as $total){
			$salesgoal .= '<tr>';
			if($module_look == 'contractamount'){
				$salesgoal .= '<td><div>¥'.setNumberFormat($total['contractamount'],self::getAmountDecimal()).'</div></td> ';
			}else if($module_look == 'paymentamount'){
				$salesgoal .= '<td><div>¥'.setNumberFormat($total['paymentamount'],self::getAmountDecimal()).'</div></td> ';
			}else if($module_look == 'accountsnumber'){
				$salesgoal .= '<td><div>'.self::formateValue($total['accountsnumber'],$module_look).'</div></td> ';
			}else if($module_look == 'invoiceamount'){
				$salesgoal .= '<td><div>¥'.setNumberFormat($total['invoiceamount'],self::getAmountDecimal()).'</div></td> ';
			}else if($module_look == 'outboundorderamount'){
				$salesgoal .= '<td><div>¥'.setNumberFormat($total['outboundorderamount'],self::getAmountDecimal()).'</div></td> ';
			}else if($module_look == 'receivableamount'){
                $salesgoal .= '<td><div>¥'.setNumberFormat($total['receivableamount'],self::getAmountDecimal()).'</div></td> ';
            }
			$salesgoal .= '</tr>';
		}
		return $salesgoal;
	}

    /**
     * 获取用户所在的部门
     * User: Dong
     * Date: 2020/5/9 15:17
     * @param $user
     */
	public  function getUserGroup($users,$type=false){
        if(empty($users)) return '';
        if(isset($users['undefind'])) return '';
        global $adb;
        $userGroup=array();
        $usersId = implode(',',array_keys($users));
        $query ='SELECT
		IFNULL(ld_groups.groupid,0) groupid,
		ld_users.id userid,
		ld_groups.groupname,
		ld_groups.parentgroup,
		ld_groups.parentid,
		ld_groups.depth
FROM
		ld_users
		LEFT JOIN ld_users2group on ld_users.id = ld_users2group.userid
		LEFT JOIN ld_groups  ON ld_users2group.groupid = ld_groups.groupid
WHERE
		ld_users.id IN ('.$usersId.')
ORDER BY 
		ld_groups.groupid';
//        $query = 'SELECT groupid,userid FROM ld_users2group WHERE userid IN ('.$usersId .')  ORDER BY groupid';


        $result = $adb->pquery($query,array());
        if($type != true){
            while($row = $adb->fetch_array($result)){
            	$groupobj=new Group();
				$groupobj->groupid=$row['groupid'];
				$groupobj->groupname=$row['groupname'];
				$row['groupname']=getWx_GroupName($groupobj);
                $userGroup[$row['groupid']][] =$row;
            }
        }
        return $userGroup;
    }
    /**
     * 获取所有部门
     * User: Dong
     * Date: 2020/5/9 15:17
     * @param $user
     */
    public static function getGroup(){
        global $adb;

        $query ='SELECT
        groupid,groupname,parentgroup,parentid,depth
FROM
		ld_groups
ORDER BY 
		groupid';
//        $query = 'SELECT groupid,userid FROM ld_users2group WHERE userid IN ('.$usersId .')  ORDER BY groupid';
        $result = $adb->pquery($query,array());
        $groups=array();
        while($row = $adb->fetch_array($result)){
            $groups[] =$row;
        }
        return $groups;
    }
	/**
	 * 获取统计图数据
	 * @author Tujt 2015-07-02
	 */
	public static function getSalesGoalReport() {
		if(empty(self::$monthtotal)) return array();
		$lastentries = array();//销售目标
		$nowentries = array();//目标完成
		foreach(self::$monthtotal as $month=>$total){
			$lastentries[] = array(
								0 => 1,
								1 => $total['tolook'],
								2 => $month,
							);
			$nowentries[] = array(
								0 => 1,
								1 => $total['complete'],
								2 => $month,
							);
		}
		$values=Array('ModuleName'=>'CompanyAllMonthSalesGoal','Entries'=>$nowentries,'LastEntries'=>$lastentries);
		$resultValue = array('Maxentries'=>12,'Details'=>$values,'type' =>'chart');
		return $resultValue;
	}
    /**
     * 获取统计图数据
     * @author D 2020-05-08
     */
    public static function newGetSalesGoalReport() {
       
        if(empty(self::$monthtotal)) return array();
        foreach(self::$monthtotal as $month=>$total){
            $fieldName[] = $month;
            $fieldValue0[]= $total['tolook']; //销售目标数据
            $fieldValue1[]= setNumberFormatEmptySeperator($total['complete'],self::getAmountDecimal()); //目标完成数据
        }
        $lineName =array(getFixedLabel('TEMPLATETARGET'),getFixedLabel('TEMPLATECOMPLETE'));
        $values=compact('lineName','fieldValue1','fieldValue0','fieldName');
        $values['ModuleName']='CompanyAllMonthSalesGoal';
        $values['title']=getTranstab("SalesGoal").getVarFixedLabel('TEMPLATESALESGOALIMG');
        return $values;
    }

    /**
     * name: 为树状图表的children属性赋值  赋值成员的值
     * User: Dong
     * Date: 2020/5/14 16:23
     * @param $data2
     * @param $groupids
     * @param $value
     */
    public static function treeChildrenValue(&$data,$groupids,$value,$topParentid)
    {
        $newdata='';
        $groupids = array_values($groupids);
        foreach ($groupids as $k => $groupid) {
            if($k ==0){
                if($groupid==0 || $groupid ==$topParentid){
                    $newdata = &$data['children'];
                }else{
                    $newdata = &$data[$groupid]['children'];
                }
                if (count($groupids) !=1) {
                    unset($groupids[$k]);
                    self::treeChildrenValue($newdata, $groupids, $value,$topParentid);
                }else{
                    $newdata ?: $newdata=array();
                    $newdata = $value+$newdata;
                }
            }
        }
    }
    /**
     * name: 为树状图表的children属性赋值  赋值部门的值
     * User: Dong
     * Date: 2020/5/14 16:23
     * @param $data2
     * @param $groupids
     * @param $value
     */
    public static function treeChildrenValue2(&$data,$groupids,$value,$topParentid)
    {
        $newdata='';
        $groupids = array_values($groupids);
        foreach ($groupids as $k => $groupid) {
            if($k ==0){
                if($groupid == 0 || $groupid==$topParentid){
                    $newdata = &$data;
                }else{
                    $newdata = &$data['children'][$groupid];
                }
                if (count($groupids) !=1) {
                    unset($groupids[$k]);
                    self::treeChildrenValue2($newdata, $groupids, $value,$topParentid);
                }else{
                    $newdata ?: $newdata=array();
                    $newdata = $value +$newdata;
                }
            }
        }
    }

    /**
     * name: 格式化数组
     * User: Dong
     * Date: 2020/5/14 18:29
     * @param $data
     */
    public static function formateArray(&$data){
        if(is_array($data['children'])){
            krsort($data['children']);
            $data['children'] = array_values($data['children']);
            foreach($data['children'] as &$child){
                self::formateArray($child);
            }
        }
    }

    /**
     * name: 百分比
     * User: Dong
     * Date: 2020/5/15 9:54
     * @param $complete
     * @param $tolook
     * @return int
     */
    public  static function calPercent($complete,$tolook){
        if($complete >0 && $tolook>0){
//            $percent = setNumberFormat(sprintf('%.2f',$complete/$tolook*100));
            $percent =$complete/$tolook*100;
        }else{
            $percent =0;
        }

        return $percent;
    }

    /**
     * name: 返回树状图标json数据
     * User: Dong
     * Date: 2020/5/14 18:30
     * @param $users
     * @param $userGroup
     * @return json
     */
    public static function getGetSalesGoalTree($users,$userGroup,$search_date,$module_look)
    {
        if(empty($userGroup)) return false;
        $groups = self::getGroup();
        $data =array();
        $topParentid='';
        $newUserGroup=$userGroup;
        //把下级部门赋值给上级
        foreach ($groups as $group){
            $parentGroup = explode('::',$group['parentgroup']);
            arsort($parentGroup); //排序
            foreach ($parentGroup as $k=>$groupid){
                if($groupid == $group[groupid]) continue;
                isset($newUserGroup[$groupid]) ?: $newUserGroup[$groupid]=array();
                isset($userGroup[$group['groupid']]) ?: $userGroup[$group['groupid']]=array();
                $newUserGroup[$groupid] = array_merge($newUserGroup[$groupid],$userGroup[$group['groupid']]);

                self::$grouptotal_all[$groupid]['tolook'] += self::$grouptotal_all[$group['groupid']]['tolook'];
                self::$grouptotal_all[$groupid]['complete'] += self::$grouptotal_all[$group['groupid']]['complete'];
            }
        }
      
        foreach($groups as $k => $group){
            $parentGroup = explode('::',$group['parentgroup']);
            $topParentid =$parentGroup[0];
            if($group['depth'] == 0){
                $data['userid'] = implode(',',array_keys($users));
                $groupobj=new Group();
				$groupobj->groupid=$group['groupid'];
				$groupobj->groupname=$group['groupname'];
				$tmp_groupname=getWx_GroupName($groupobj);
                $data['name']=$tmp_groupname;
                $data['search_date']=$search_date;
                $data['module_look'] = $module_look;
                $data['tolook']=self::formateTreeValue(self::$usertotal_all['tolook'],$module_look);
                $data['complete']=self::formateTreeValue(self::$usertotal_all['complete'],$module_look);
                $total_percent=self::$usertotal_all['percent'];
                //wyt 2209010 1000179销售目标，树状图表的目标、完成值、完成率增加高度或颜色区分（戚涛）
                if($total_percent>100){
                    $data['tolookheight'] = '20px';
                    $data['completeheight'] = '40px';
                    $data['colorpercent'] = 'red';
                }else if($total_percent<100){
                    $data['tolookheight'] = '40px';
                    $data['completeheight'] = '20px';
                    $data['colorpercent'] = 'green';
                }else{
                    $data['tolookheight'] = '30px';
                    $data['completeheight'] = '30px';
                    $data['colorpercent'] = 'blue';
                }
                if(empty($total_percent))
                {
                    $total_percent=0;
                }
                $data['percent'] = number_format($total_percent,2);
                $childUser=array();
                foreach ($userGroup[0] as $userid =>$user){  //所有无部门的人员
                   if(self::$usertotal[$user['groupid']][$user['userid']]['tolook'] !=0 ){
                       $percent = self::calPercent(self::$usertotal[$user['groupid']][$user['userid']]['complete'],self::$usertotal[$user['groupid']][$user['userid']]['tolook']);

                       if($percent<100){
                           $tempuser = array(
                               'type'=>'1',
                               'name'=>$users[$user['userid']],
                               'userid'=>$user['userid'],
                               'search_date'=>$search_date,
                               'module_look'=> $module_look,
                               'tolookheight'=> '40px',
                               'completeheight'=> '20px',
                               'colorpercent'=> 'green',
                               'tolook'=>self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['tolook'],$module_look),
                               'complete'=>self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['complete'],$module_look),
                               'percent'=>number_format($percent,2),
                           );
                       }else if($percent>100){
                           $tempuser = array(
                               'type'=>'1',
                               'name'=>$users[$user['userid']],
                               'userid'=>$user['userid'],
                               'search_date'=>$search_date,
                               'module_look'=> $module_look,
                               'tolookheight'=> '20px',
                               'completeheight'=> '40px',
                               'colorpercent'=> 'red',
                               'tolook'=>self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['tolook'],$module_look),
                               'complete'=>self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['complete'],$module_look),
                               'percent'=>number_format($percent,2),
                           );
                       }else{
                           $tempuser = array(
                               'type'=>'1',
                               'name'=>$users[$user['userid']],
                               'userid'=>$user['userid'],
                               'search_date'=>$search_date,
                               'module_look'=> $module_look,
                               'tolookheight'=> '30px',
                               'completeheight'=> '30px',
                               'colorpercent'=> 'blue',
                               'tolook'=>self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['tolook'],$module_look),
                               'complete'=>self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['complete'],$module_look),
                               'percent'=>number_format($percent,2),
                           );
                       }
                       $childUser['user'.$user['userid']] =$tempuser;
                   }
                }
                foreach ($userGroup[1] as $userid =>$user){
                   if(self::$usertotal[$user['groupid']][$user['userid']]['tolook'] !=0 ){
                       $percent = self::calPercent(self::$usertotal[$user['groupid']][$user['userid']]['complete'],self::$usertotal[$user['groupid']][$user['userid']]['tolook']);
                       if($percent<100){
                           $tempuser = array(
                               'type'=>'1',
                               'name'=>$users[$user['userid']],
                               'userid'=>$user['userid'],
                               'search_date'=>$search_date,
                               'module_look'=> $module_look,
                               'tolookheight'=> '40px',
                               'completeheight'=> '20px',
                               'colorpercent'=> 'green',
                               'tolook'=>self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['tolook'],$module_look),
                               'complete'=>self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['complete'],$module_look),
                               'percent'=>number_format($percent,2),
                           );
                       }else if($percent>100){
                           $tempuser = array(
                               'type'=>'1',
                               'name'=>$users[$user['userid']],
                               'userid'=>$user['userid'],
                               'search_date'=>$search_date,
                               'module_look'=> $module_look,
                               'tolookheight'=> '20px',
                               'completeheight'=> '40px',
                               'colorpercent'=> 'red',
                               'tolook'=>self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['tolook'],$module_look),
                               'complete'=>self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['complete'],$module_look),
                               'percent'=>number_format($percent,2),
                           );
                       }else{
                           $tempuser = array(
                               'type'=>'1',
                               'name'=>$users[$user['userid']],
                               'userid'=>$user['userid'],
                               'search_date'=>$search_date,
                               'module_look'=> $module_look,
                               'tolookheight'=> '30px',
                               'completeheight'=> '30px',
                               'colorpercent'=> 'blue',
                               'tolook'=>self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['tolook'],$module_look),
                               'complete'=>self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['complete'],$module_look),
                               'percent'=>number_format($percent,2),
                           );
                       }
                       $childUser['user'.$user['userid']] =$tempuser;

                   }
                }
                self::treeChildrenValue($data,$parentGroup,$childUser,$topParentid);
            }else{
               if(self::$grouptotal_all[$group['groupid']]['tolook'] != 0) {
                   $percent = self::calPercent(self::$grouptotal_all[$group['groupid']]['complete'], self::$grouptotal_all[$group['groupid']]['tolook']);
                   $userStr ='';
                   foreach ($newUserGroup[$group['groupid']] as $k =>$user){
                       if($k+1 == count($newUserGroup[$group['groupid']])){
                           $userStr.= $user['userid'];
                       }else{
                           $userStr.= $user['userid'].',';
                       }

                   }
				   $groupobj=new Group();
					$groupobj->groupid=$group['groupid'];
					$groupobj->groupname=$group['groupname'];
					$groupname=getWx_GroupName($groupobj);

                   if($percent<100){
                       $tempGroup = array(
                           'name' => $groupname,
                           'module_look'=> $module_look,
                           'userid'=>$userStr,
                           'search_date'=>$search_date,
                           'tolookheight'=> '40px',
                           'completeheight'=> '20px',
                           'colorpercent'=> 'green',
                           'tolook' => self::formateTreeValue(self::$grouptotal_all[$group['groupid']]['tolook'],$module_look),
                           'complete' => self::formateTreeValue(self::$grouptotal_all[$group['groupid']]['complete'],$module_look),
                           'percent'=>number_format($percent,2),
                       );

                   }else if($percent>100){
                       $tempGroup = array(
                           'name' => $groupname,
                           'module_look'=> $module_look,
                           'userid'=>$userStr,
                           'search_date'=>$search_date,
                           'tolookheight'=> '20px',
                           'completeheight'=> '40px',
                           'colorpercent'=> 'red',
                           'tolook' => self::formateTreeValue(self::$grouptotal_all[$group['groupid']]['tolook'],$module_look),
                           'complete' => self::formateTreeValue(self::$grouptotal_all[$group['groupid']]['complete'],$module_look),
                           'percent'=>number_format($percent,2),
                       );
                   }else{
                       $tempGroup = array(
                           'name' => $groupname,
                           'module_look'=> $module_look,
                           'userid'=>$userStr,
                           'search_date'=>$search_date,
                           'tolookheight'=> '30px',
                           'completeheight'=> '30px',
                           'colorpercent'=> 'blue',
                           'tolook' => self::formateTreeValue(self::$grouptotal_all[$group['groupid']]['tolook'],$module_look),
                           'complete' => self::formateTreeValue(self::$grouptotal_all[$group['groupid']]['complete'],$module_look),
                           'percent'=>number_format($percent,2),
                       );
                   }

                   self::treeChildrenValue2($data, $parentGroup, $tempGroup,$topParentid);

                   $childUser = array();
                   foreach ($userGroup[$group['groupid']] as $userid => $user) {
                       if (self::$usertotal[$user['groupid']][$user['userid']]['tolook'] != 0) {
                           $percent = self::calPercent(self::$usertotal[$user['groupid']][$user['userid']]['complete'], self::$usertotal[$user['groupid']][$user['userid']]['tolook']);
                           if($percent<100){
                               $tempuser = array(
                                   'type'=>'1',
                                   'name' => $users[$user['userid']],
                                   'userid'=>$user['userid'],
                                   'search_date'=>$search_date,
                                   'module_look'=> $module_look,
                                   'tolookheight'=> '40px',
                                   'completeheight'=> '20px',
                                   'colorpercent'=> 'green',
                                   'tolook' => self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['tolook'],$module_look),
                                   'complete' => self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['complete'],$module_look),
                                   'percent'=>number_format($percent,2),
                               );

                           }else if($percent>100){
                               $tempuser = array(
                                   'type'=>'1',
                                   'name' => $users[$user['userid']],
                                   'userid'=>$user['userid'],
                                   'search_date'=>$search_date,
                                   'module_look'=> $module_look,
                                   'tolookheight'=> '20px',
                                   'completeheight'=> '40px',
                                   'colorpercent'=> 'red',
                                   'tolook' => self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['tolook'],$module_look),
                                   'complete' => self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['complete'],$module_look),
                                   'percent'=>number_format($percent,2),
                               );
                           }else{
                               $tempuser = array(
                                   'type'=>'1',
                                   'name' => $users[$user['userid']],
                                   'userid'=>$user['userid'],
                                   'search_date'=>$search_date,
                                   'module_look'=> $module_look,
                                   'tolookheight'=> '30px',
                                   'completeheight'=> '30px',
                                   'colorpercent'=> 'blue',
                                   'tolook' => self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['tolook'],$module_look),
                                   'complete' => self::formateTreeValue(self::$usertotal[$user['groupid']][$user['userid']]['complete'],$module_look),
                                   'percent'=>number_format($percent,2),
                               );
                           }
                           $childUser['user' . $user['userid']] = $tempuser;
                       }
                   }
                   self::treeChildrenValue($data, $parentGroup, $childUser,$topParentid);
               }
           }
        }
       self::formateArray($data);

       return ldcrm_json_encode($data);
    }

    /**
     * name: 格式化数值
     * User: Dong
     * Date: 2020/5/12 18:14
     * @param $value
     * @param $module_look
     * @return int
     */
    public static function formateValue($value,$module_look){
        if($module_look != 'accountsnumber'){
            $value = setNumberFormat($value);
        }
        return $value;
    }

    public static function formateTreeValue($value,$module_look){
        if($value){
            if($module_look != 'accountsnumber'){
                $proportion=10000;
                $value = sprintf('%.2f',$value/$proportion);
                $value =setNumberFormat($value);
            }
        }else{
            $value=0;
        }

        return $value;
    }
	/**
     * 构造函数
     * @author Tujt 2015-07-01
     */
    public function __destruct() {
        
    }
}
?>