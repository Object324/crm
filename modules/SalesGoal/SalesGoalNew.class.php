<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-07-01
 */
crm_load_class_file('SalesGoalOperation','modules/SalesGoal');
crm_load_class_file('cls_related_scope','include/utils');
class SalesGoalNew {
	private static $usertotal = array();//用户总计
	private static $usertotalOld = array();//用户总计
	private static $monthtotal = array();//月度总计
	private static $grouptotal = array();//部门每月总计
	private static $grouptotal_all = array();//部门用户小计总计
	private static $usertotal_all = array();//总用户合计
    public $db;
    public $user;
    public $relatedtype;
    public static  $morethanzerouserid_arr=[];//有销售目标的用户
    public static $length_amountdecimal;
    private $targetid;

    public $MoreThanZeroRecordArr = [];
    public $all_salesgoal_info = [];
    public $permit_groupset_arr = ['noedit','allowedit'];
    public $tag_arr = ['RecordTarget','GroupSum','GroupTarget','RecordTargetSum','GroupTargetSum'];
    public $cur_module = '';
    public $advancesearchArr = [];//外部传进来的高级查找数组  最近6个月目标完成情况穿透使用
    public $list_query_detail ;
    public $row_head_arr = [];
    public $row_total_arr = [];
    public $record_total_by_month_arr = [];
    public $month_total_by_record_arr = [];
    public $group_total_by_month_arr = [];
    public $groupseq_arr = [];
    public $unitlabel_arr=[
        "none"=>["zh_label"=>"","en_label"=>"",'datatype'=>''],
        "yuan"=>["zh_label"=>"元","en_label"=>"yuan",'datatype'=>'amount'],
        "tenthousand"=>["zh_label"=>"万","en_label"=>"ten thousand",'datatype'=>'amount'],
        "million"=>["zh_label"=>"百万","en_label"=>"million",'datatype'=>'amount'],
        "tenmillion"=>["zh_label"=>"千万","en_label"=>"ten million",'datatype'=>'amount'],
        "hundredmillion"=>["zh_label"=>"亿","en_label"=>"hundred million",'datatype'=>'amount'],
        "g"=>["zh_label"=>"克","en_label"=>"g",'datatype'=>'num'],
        "kg"=>["zh_label"=>"千克","en_label"=>"kg",'datatype'=>'num'],
        "jin"=>["zh_label"=>"斤","en_label"=>"jin",'datatype'=>'num'],
        "gongjin"=>["zh_label"=>"公斤","en_label"=>"kg",'datatype'=>'num'],
        "ton"=>["zh_label"=>"吨","en_label"=>"ton",'datatype'=>'num'],
        "m"=>["zh_label"=>"米","en_label"=>"m",'datatype'=>'num'],
        "km"=>["zh_label"=>"千米","en_label"=>"km",'datatype'=>'num'],
        "li"=>["zh_label"=>"里","en_label"=>"li",'datatype'=>'num'],
        "gongli"=>["zh_label"=>"公里","en_label"=>"km",'datatype'=>'num'],
        "user"=>["zh_label"=>"用户","en_label"=>"user",'datatype'=>'num'],
        "part"=>["zh_label"=>"部","en_label"=>"part",'datatype'=>'num'],
        "jian"=>["zh_label"=>"件","en_label"=>"pieces",'datatype'=>'num'],
        "pieces"=>["zh_label"=>"个","en_label"=>"pieces",'datatype'=>'num'],
        "he"=>["zh_label"=>"盒","en_label"=>"boxes",'datatype'=>'num'],
        "tables"=>["zh_label"=>"台","en_label"=>"tables",'datatype'=>'num'],
        "zhi"=>["zh_label"=>"只","en_label"=>"pieces",'datatype'=>'num'],
        "boxes"=>["zh_label"=>"箱","en_label"=>"boxes",'datatype'=>'num'],
        "sets"=>["zh_label"=>"套","en_label"=>"sets",'datatype'=>'num'],
        "time"=>["zh_label"=>"次","en_label"=>"times",'datatype'=>'num'],
    ];
    /**
     * 构造函数
     * @author Tujt 2015-07-01
     */
    public function __construct() {
        global $current_user,$adb;
        $this->db = $adb;
        $this->user = $current_user;
        $this->relatedtype = 'TargetRange';
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
	public function getUserInfo($scope='') {
		global $current_user;
		$MergeSmowner = getCurSmOwnerSearchScope('SalesGoal');
		$UserArr = $MergeSmowner['UserCombo'];
	    if(!empty($scope)){
			switch($scope){
			    case 'SmOwner_Search_All':
				case 'SmOwner_Search_Create':
				case 'SmOwner_Search_SubRole':
				    $users = $this->getScopeUserName('All',1,$UserArr);
			        break;
			    case 'SmOwner_Search_Me':
			        $users = $this->getScopeUserName('person',$current_user->id,$UserArr);
			        break;
				case 'smowner_search_senior':
                    //edit: xll 2023/08/14 XUQIU1001400 首页组件获取完成值时需要修改为对应的键值
                    $senioruserid = $_REQUEST['senioruserid'];
                    if(isset($this->selectUserIds))
                        $senioruserid = $this->selectUserIds;
				    $users = $this->getScopeUserName('senior',$scope,$senioruserid);
				    break;
				default:
					$users = array($scope=>getOwnerName($scope));
			}
		}else{
			$users = $this->getScopeUserName('All',1,$UserArr);
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
	public function getUserSalesGoalInfo($record_info,$yearmonth,$targetid,$usersGroup) {
        global $adb;
		$salesgoal = '';
        $SalesGoalInfo = $this->getSalesGolaInfoByid($targetid);
		$salestarget = $this->getSalesGoalToLook($yearmonth,$targetid);//获取目标值信息
		$salesgoalarr = $this->getSalesGoalOverInfo($targetid,$yearmonth,$record_info);//完成

        $month_total_by_onegroup_arr = []; //每个月份中所有部门的合计
        $month_total_by_record_arr = []; //每个月份中所有单据的合计
        $record_total_by_month_arr = []; //每条单据在所有月份的合计
        $group_total_by_month_arr = []; //每个部门在所有月份的合计
        $row_total_arr = []; //每一行单据的合计
        $row_head_arr = []; //每一行的第一列信息
        $used_record_arr = []; //因为存在一个用户多个部门的情况,避免用户多次计算
        $GroupUserArr =array();

        $num=0;
        $modulename = $SalesGoalInfo['modulename'];
        $datatype = $SalesGoalInfo['datatype'];
        $groupsetting = $SalesGoalInfo['groupsetting'];
        $Decimal = self::getAmountDecimal();
        if($SalesGoalInfo['datatype'] == 'num'){
            $cymbol='';
        }else{
            $cymbol='¥';
        }

        //允许显示部门目标时
        if(in_array($groupsetting,$this->permit_groupset_arr)){
            $num = 0;
            foreach ($usersGroup as $tmp_groupid => $tmp_groupinfo){
                $month_total_by_onegroup_arr = [];
                $tmp_len = sizeof($tmp_groupinfo);
                $groupname = $tmp_groupinfo[0]['groupname'];
                $i = 0;
                do{
                    //获取头部tr
                    $status = $tmp_groupinfo[$i]['status'];
                    $salesgoal.= $this->getTrhtml($num);
                    $tmp_target_sum = 0;
                    $tmp_finish_sum = 0;
                    if($i <$tmp_len){
                        $tmp_type = $modulename;
                        $record = $tmp_groupinfo[$i]['userid'];
                        $GroupUserArr[$tmp_groupid][] = $record;
                        $record_str = $record;
                    }else{
                        $record_str = implode(',',$GroupUserArr[$tmp_groupid]);
                        $tmp_type = 'Group';
                        $record = $tmp_groupid;
                    }

                    foreach($yearmonth as $month){
                        if($i <$tmp_len){
                            //单个用户的目标
                            $targetvalue = $salestarget[$tmp_type][$record][$month];
                            if(empty($targetvalue))$targetvalue = 0;
                            //用户的目标完成值
                            $finishvalue = $salesgoalarr[$record][$month];
                            if(empty($finishvalue))$finishvalue = 0;
                            //用于计算用户合计
                            $month_total_by_record_arr[$month][$record]['target'] = $targetvalue;
                            $month_total_by_record_arr[$month][$record]['finish'] = $finishvalue;
                            //用于计算部门小计
                            $month_total_by_onegroup_arr[$month][$tmp_groupid]['target'] += $targetvalue;
                            $month_total_by_onegroup_arr[$month][$tmp_groupid]['finish'] += $finishvalue;
                        }else{
                            //部门目标合计
                            if(isset($salestarget[$tmp_type][$record][$month]) && $groupsetting == 'allowedit'){
                                $targetvalue = $salestarget[$tmp_type][$record][$month];
                            }else{
                                $targetvalue = $month_total_by_onegroup_arr[$month][$record]['target'];
                            }
                            $finishvalue = $month_total_by_onegroup_arr[$month][$record]['finish'];
                        }
                        $tmp_target_sum += $targetvalue;
                        $tmp_finish_sum += $finishvalue;

                        $showtargetvalue = $this->getShowValue($targetvalue,$Decimal,$datatype,'detail');
                        $showfinishvalue = $this->getShowValue($finishvalue,$Decimal,$datatype,'detail');

                        $salesgoal .= '<td style="background:transparent;"><div>'.$showtargetvalue.'</div></td>';
                        $salesgoal .= '<td style="background:transparent;">';

                        if($finishvalue >0){
                            $salesgoal .='<a href="javascript:void(0)" record_str="'.$record_str.'" search_date_value="'.$month.'" targetid="'.$targetid.'" onclick="openUserCompleteUrl(ld(this))">'.$showfinishvalue.'</a>';
                        }else{
                            $salesgoal .='<div>'.$showfinishvalue.'</div>';
                        }
                        $salesgoal .= '</td>';

                        $finish_percent = 0;
                        if($finishvalue>0 && $targetvalue>0){
                            $finish_percent = sprintf('%.2f',$finishvalue/$targetvalue*100);
                        }
                        if($finish_percent>100){
                            $salesgoal .= '<td style="background:transparent;color:red" ><div id="'.$record.'listgoal'.$month.'">'.$finish_percent.'%</div></td>';
                        }else if($finish_percent<100){
                            $salesgoal .= '<td style="background:transparent;color:green"><div id="'.$record.'listgoal'.$month.'">'.$finish_percent.'%</div></td>';
                        }else{
                            $salesgoal .= '<td style="background:transparent;"><div id="'.$record.'listgoal'.$month.'">'.$finish_percent.'%</div></td>';
                        }
                    }
                    $totol_percent = 0;
                    if($tmp_target_sum>0 && $tmp_finish_sum>0){
                        $totol_percent = sprintf('%.2f',$tmp_finish_sum/$tmp_target_sum*100);
                    }
                    $row_total_arr[$num] = array('targetvalue'=>$tmp_target_sum,'finishvalue'=>$tmp_finish_sum,'percent'=>$totol_percent);
                    if($tmp_type == 'Group'){
                        $row_head_arr[$num] = array('colspan'=>2,'group_label'=>$groupname.'-','name_label'=>getFixedLabel('PAYMENT'));
                        $group_total_by_month_arr[$record]['target'] = $tmp_target_sum;
                        $group_total_by_month_arr[$record]['finish'] = $tmp_finish_sum;
                    }else{
                        $record_total_by_month_arr[$record]['target'] = $tmp_target_sum;
                        $record_total_by_month_arr[$record]['finish'] = $tmp_finish_sum;
                        $row_head_arr[$num] = array('colspan'=>1,'group_label'=>$groupname,'name_label'=>$record_info[$record],'status'=>$status);
                    }
                    $salesgoal .= '</tr>';
                    $i++;
                    $num++;
                }while($i<$tmp_len+1);
            }
        }else{
            $tmp_type = $modulename;
            $num = 0;
			//XUQIU20240415-03 目标管理，增加“显示离职成员”参数（杨雅媚）wsh 20240918
            $usersInfoArr = $this->getUserStatus(implode(',',array_keys($record_info)));
            foreach($record_info as $record=>$info){
                //获取头部tr
                $salesgoal.= $this->getTrhtml($num);
                $tmp_target_sum = 0;
                $tmp_finish_sum = 0;
                $status = $usersInfoArr[$record];
                foreach($yearmonth as $month){
                    $targetvalue = $salestarget[$modulename][$record][$month];
                    $finishvalue = $salesgoalarr[$record][$month];
                    if(empty($targetvalue))$targetvalue = 0;
                    if(empty($finishvalue))$finishvalue = 0;
                    $month_total_by_record_arr[$month][$record]['target'] = $targetvalue;
                    $month_total_by_record_arr[$month][$record]['finish'] = $finishvalue;
                    $tmp_target_sum += $targetvalue;
                    $tmp_finish_sum += $finishvalue;

                    $showtargetvalue = $this->getShowValue($targetvalue,$Decimal,$datatype,'detail');
                    $showfinishvalue = $this->getShowValue($finishvalue,$Decimal,$datatype,'detail');

                    $salesgoal .= '<td style="background:transparent;"><div>'.$showtargetvalue.'</div></td>';
                    $salesgoal .= '<td style="background:transparent;">';

                    if($finishvalue >0){
                        $salesgoal .='<a href="javascript:void(0)" record_str="'.$record.'"  search_date_value="'.$month.'" targetid="'.$targetid.'" onclick="openUserCompleteUrl(ld(this))">'.$showfinishvalue.'</a>';
                    }else{
                        $salesgoal .='<div>'.$showfinishvalue.'</div>';
                    }
                    $salesgoal .= '</td>';

                    $finish_percent = 0;
                    if($finishvalue>0 && $targetvalue>0){
                        $finish_percent = sprintf('%.2f',$finishvalue/$targetvalue*100);
                    }
                    if($finish_percent>100){
                        $salesgoal .= '<td style="background:transparent;color:red" ><div id="'.$record.'listgoal'.$month.'">'.$finish_percent.'%</div></td>';
                    }else if($finish_percent<100){
                        $salesgoal .= '<td style="background:transparent;color:green"><div id="'.$record.'listgoal'.$month.'">'.$finish_percent.'%</div></td>';
                    }else
                        $salesgoal .= '<td style="background:transparent;"><div id="'.$record.'listgoal'.$month.'">'.$finish_percent.'%</div></td>';

                }
                $totol_percent = 0;
                if($tmp_target_sum>0 && $tmp_finish_sum>0){
                    $totol_percent = sprintf('%.2f',$tmp_finish_sum/$tmp_target_sum*100);
                }
                $record_total_by_month_arr[$record]['target'] = $tmp_target_sum;
                $record_total_by_month_arr[$record]['finish'] = $tmp_finish_sum;
                $row_total_arr[$num] = array('targetvalue'=>$tmp_target_sum,'finishvalue'=>$tmp_finish_sum,'percent'=>$totol_percent);
                $row_head_arr[$num] = array('colspan'=>1,'group_label'=>'','name_label'=>$info,'status'=>$status);
                $salesgoal .= '</tr>';
                $num++;
            }
        }
        $this->row_head_arr = $row_head_arr;
        $this->row_total_arr = $row_total_arr;
        //用于显示统计图表
        $this->month_total_by_record_arr = $month_total_by_record_arr;
        //用于显示树状图
        $this->record_total_by_month_arr = $record_total_by_month_arr;
        $this->group_total_by_month_arr = $group_total_by_month_arr;

        //显示合计行
        if(sizeof($month_total_by_record_arr) > 0 ){
            //获取头部tr
            $salesgoal.= $this->getTrhtml($num);
            $tmp_target_sum = 0;
            $tmp_finish_sum = 0;
            foreach($yearmonth as $month){
                $tmp_value_arr = $month_total_by_record_arr[$month];
                $targetvalue = 0;
                $finishvalue = 0;
                foreach ($tmp_value_arr as $tmp_info){
                    $targetvalue += $tmp_info['target'];
                    $finishvalue += $tmp_info['finish'];
                }
                $tmp_target_sum += $targetvalue;
                $tmp_finish_sum += $finishvalue;

                $showtargetvalue = $this->getShowValue($targetvalue,$Decimal,$datatype,'detail');
                $showfinishvalue = $this->getShowValue($finishvalue,$Decimal,$datatype,'detail');

                $salesgoal .= '<td style="background:transparent;"><div>'.$showtargetvalue.'</div></td>';
                $salesgoal .= '<td style="background:transparent;">';
                /*
                if($finishvalue >0){
                    $salesgoal .='<a href="javascript:void(0)" record_str="'.$record.'"  search_date_value="'.$month.'" targetid="'.$targetid.'" onclick="openUserCompleteUrl(ld(this))">'.$showfinishvalue.'</a>';
                }else{
                    $salesgoal .='<div>'.$showfinishvalue.'</div>';
                }*/
                $salesgoal .='<div>'.$showfinishvalue.'</div>';
                $salesgoal .= '</td>';

                $finish_percent = 0;
                if($finishvalue>0 && $targetvalue>0){
                    $finish_percent = sprintf('%.2f',$finishvalue/$targetvalue*100);
                }
                if($finish_percent>100){
                    $salesgoal .= '<td style="background:transparent;color:red" ><div id="'.$record.'listgoal'.$month.'">'.$finish_percent.'%</div></td>';
                }else if($finish_percent<100){
                    $salesgoal .= '<td style="background:transparent;color:green"><div id="'.$record.'listgoal'.$month.'">'.$finish_percent.'%</div></td>';
                }else
                    $salesgoal .= '<td style="background:transparent;"><div id="'.$record.'listgoal'.$month.'">'.$finish_percent.'%</div></td>';

            }
            $salesgoal .= '</tr>';
            $totol_percent = 0;
            if($tmp_target_sum>0 && $tmp_finish_sum>0){
                $totol_percent = sprintf('%.2f',$tmp_finish_sum/$tmp_target_sum*100);
            }
            $this->row_total_arr[$num] = array('targetvalue'=>$tmp_target_sum,'finishvalue'=>$tmp_finish_sum,'percent'=>$totol_percent);
            $this->row_head_arr[$num] = array('colspan'=>2,'name_label'=>getTranstab($modulename).getFixedLabel('SUM'),'linetype'=>'sum');

            $num++;
        }
		return $salesgoal;
	}

	/**
	 * 获取销售目标合计值
	 * @author Tujt 2015-07-01
	 */
	public function getUserSalesGoalSum($datatype) {
        if(!is_array($this->row_total_arr) || sizeof($this->row_total_arr) == 0){
            return '';
        }
        $salesgoal = '';
        $cymbol = '¥';
        $Decimal = self::getAmountDecimal();
        foreach ($this->row_total_arr as $rowindex=> $tmp_info){
            $showtargetvalue = $this->getShowValue($tmp_info['targetvalue'],$Decimal,$datatype,'detail');
            $showfinishvalue = $this->getShowValue($tmp_info['finishvalue'],$Decimal,$datatype,'detail');
            $percent = $tmp_info['percent'];

            $salesgoal .= '<tr>';
            $salesgoal .= '<td><div>'.$showtargetvalue.'</div></td> ';
            $salesgoal .= '<td><div>'.$showfinishvalue.'</div></td> ';
            if($percent>100){
                $salesgoal .= '<td style="color:red;"><div>'.$percent.'%</div></td> ';
            }else if($percent<100){
                $salesgoal .= '<td style="color:green;"><div>'.$percent.'%</div></td> ';
            }else
                $salesgoal .= '<td><div>'.$percent.'%</div></td> ';
            $salesgoal .= '</tr>';
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
	public function getSalesGoalToLook($yearmonth,$targetid) {
	    global $adb;

        if(empty($targetid)){
            return [];
        }
		$query = 'SELECT record,targetvalue,targetyear,targetmonth,type FROM ld_salestarget_info WHERE targetid = '.$targetid.'  and ';
		//整理出开始时间和结束时间
		list($start,$end) = self::getFilterDateInfo($yearmonth);
		$startarr = explode('-',$start);
		$endarr = explode('-',$end);
		$query .= ' (';
        $start_month_arr=explode("-",$yearmonth[0]);
        $end_month_arr=explode("-",$yearmonth[sizeof($yearmonth)-1]);
		if($startarr[0] == $endarr[0]){
		      //相同的年份
			$query .= '(targetyear >= '.$startarr[0].' and targetmonth>='.$start_month_arr[1].' ) and  ( targetmonth<='.$end_month_arr[1].'  and targetyear <= '.$endarr[0].' )';
		}else{
            $query.='  case when targetyear= '.$startarr[0] .' then targetmonth>='.$start_month_arr[1].' when targetyear= '.$endarr[0] .' then targetmonth<='.$end_month_arr[1] .' end ' ;
		}
		$query .= ') ';
		$query .= 'ORDER BY targetyear,targetmonth ';
		$result = $adb->query($query);
		$rows = $adb->num_rows($result);
		$salestarget = array();
        $MoreThanZeroRecordArr = [];
        $SalesTargetInfoArr = [];
		if($rows > 0){
			for($i=0;$i<$rows;++ $i){
				$record = $adb->query_result($result,$i,'record');
				$targetvalue = $adb->query_result($result,$i,'targetvalue');
				$targetyear = $adb->query_result($result,$i,'targetyear');
				$targetmouth = $adb->query_result($result,$i,'targetmonth');
                $type = $adb->query_result($result,$i,'type');
				$goal_date = $targetyear.'-'.$targetmouth;
                if($this->getUnitExist() === 'yes'){//wym 240410 首页-目标完成率-目标值 改为转换后的值
                    $conversion_value=$this->getConversionValue($targetvalue,$targetid);
                    $SalesTargetInfoArr[$type][$record][$goal_date] = floatval($conversion_value);
                }else{
                    $SalesTargetInfoArr[$type][$record][$goal_date] = floatval($targetvalue);
                }
                $MoreThanZeroRecordArr[] = $record;
			}
		}
        $this->MoreThanZeroRecordArr = $MoreThanZeroRecordArr;
		return $SalesTargetInfoArr;
	}
	/**
	 * 得到目标完成值
	 * @author duan 2023-03-31
	 */
	public function getSalesGoalOverInfo($targetid,$yearmonth,$recordinfo)
    {
        $adb = $this->db;
        $current_user = $this->user;
        list($start, $end) = self::getFilterDateInfo($yearmonth);
        $SalesGoalInfo = $this->getSalesGolaInfoByid($targetid);
        //指标详情相关信息
        $record_arr = array_keys($recordinfo);
        $record_str = implode(',', $record_arr);
        $modulename = $SalesGoalInfo['modulename']; //指标对象
        $groupsetting = $SalesGoalInfo['groupsetting']; //部门设置
        $detailinfo = $SalesGoalInfo['detailinfo']; //指标详情信息
        //预准备变量和数组
        $GoalOverInfoArr = [];
        foreach ($detailinfo as $tmp_info){
            //获取查询结果sql
            $query = $this->get_page_query_new($tmp_info,$yearmonth,$recordinfo);
            $result = $adb->pquery($query);
            //查询的结果重命名为tmp_record 和 tmp_value
            $num_rows = $adb->num_rows($result);
            if($num_rows >0){
                for ($i = 0;$i<$num_rows;$i++){
                    $tmp_record = $adb->query_result($result,$i,'tmp_record');
                    $tmp_value = $adb->query_result($result,$i,'tmp_value');
                    $tmp_date = $adb->query_result($result,$i,'tmp_date');
                    $tmp_month = date("Y-n",strtotime($tmp_date));
                    if(!isset($GoalOverInfoArr[$tmp_record][$tmp_month])){
                        $GoalOverInfoArr[$tmp_record][$tmp_month] = 0;
                    }
                    if($this->getUnitExist() === 'yes'){//wym 240410 首页--目标完成率-完成值 改为转换后的值
                        $conversion_value=$this->getConversionValue($tmp_value,$targetid);
                        $GoalOverInfoArr[$tmp_record][$tmp_month] += $conversion_value;
                    }else{
                        $GoalOverInfoArr[$tmp_record][$tmp_month] += $tmp_value;
                    }
                }
            }
        }
        return $GoalOverInfoArr;
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
    public function getSalesGoalInfo($record_info,$yearmonth,$targetid,$usersGroup,$mode) {
        global $adb;
        $salesgoal = '';
        $salesgoalinfo = $this->getSalesGolaInfoByid($targetid);
        $salestarget = $this->getSalesGoalToLook($yearmonth,$targetid);//获取目标值信息]


        $month_total_by_group_arr = []; //每个月份中所有部门的合计
        $month_total_by_record_arr = []; //每个月份中所有单据的合计
        $row_total_arr = []; //每一行单据的合计
        $row_head_arr = []; //每一行的第一列信息
        $used_record_arr = []; //因为存在一个用户多个部门的情况,避免用户多次计算

        $group_total_arr = [];
        $month_total_arr = [];

        $num=0;
        $modulename = $salesgoalinfo['modulename'];
        $datatype = $salesgoalinfo['datatype'];
        $groupsetting = $salesgoalinfo['groupsetting'];
        $Decimal = self::getAmountDecimal();
        $cymbol = '¥';
        //允许显示部门目标时
        if(in_array($groupsetting,$this->permit_groupset_arr)){
            $num = 0;
            foreach ($usersGroup as $tmp_groupid => $tmp_groupinfo){
                $month_total_by_onegroup_arr = [];
                $tmp_len = sizeof($tmp_groupinfo);
                $groupname = $tmp_groupinfo[0]['groupname'];
                $i = 0;
                do{
                    $status = $tmp_groupinfo[$i]['status'];
                    if($groupsetting != 'allowedit' && $i ==$tmp_len +1){
                        break;
                    }
                    //获取头部tr
                    $salesgoal.= $this->getTrhtml($num);
                    $tmp_sum = 0;
                    if($i <$tmp_len){
                        //单个用户的目标
                        $tmp_type = $modulename;
                        $tag = 'RecordTarget';
                        $record = $tmp_groupinfo[$i]['userid'];
                    }else if($i <$tmp_len +1){
                        //部门成员目标小计
                        $tmp_type = 'Groupsum';
                        $tag = 'GroupSum';
                        $record = $tmp_groupid;
                    }else if($groupsetting == 'allowedit'){
                        //部门目标
                        $tmp_type = 'Group';
                        $tag = 'GroupTarget';
                        $record = $tmp_groupid;
                    }else{
                        $tmp_type = 'other';
                        $tag = 'other';
                        $targetvalue = 0;
                    }

                    foreach($yearmonth as $month){
                        if($i <$tmp_len){
                            //单个用户的目标
                            $targetvalue = $salestarget[$tmp_type][$record][$month];
                            if(empty($targetvalue))$targetvalue = 0;
                            //用于计算用户合计
                            $month_total_by_record_arr[$month][$record] = $targetvalue;
                            $month_total_by_onegroup_arr[$month][$tmp_groupid] += $targetvalue;
                        }else if($i <$tmp_len +1){
                            //部门目标小计
                            $targetvalue = $month_total_by_onegroup_arr[$month][$record];
                        }else if($groupsetting == 'allowedit'){
                            //部门目标合计
                            if(isset($salestarget[$tmp_type][$record][$month])){
                                $targetvalue = $salestarget[$tmp_type][$record][$month];
                            }else{
                                $targetvalue = $month_total_by_onegroup_arr[$month][$record];
                            }
                            if(empty($targetvalue))$targetvalue = 0;
                            //用于计算部门合计
                            $month_total_by_group_arr[$month][$record] += $targetvalue;
                        }else{
                            $targetvalue = 0;
                        }
                        $tmp_sum += $targetvalue;

                        $showvalue = $this->getShowValue($targetvalue,$Decimal,$datatype,$mode);

                        if($mode == 'edit'){
                            $labelname = $record.'-'.$month.'-'.$targetid;
                            $salesgoal .= '<td ><div><input class="detailedViewTextBox" month="'.$month.'" groupid="'.$tmp_groupid.'" tag="'.$tag.'" record="'.$record.'" type="text" value="'.$showvalue.'" id="'.$labelname.'" name="'.$labelname.'" style="text-align:right;border:none;" size="8" /></div></td>';
                        }else{
                            $salesgoal .= '<td style="background:transparent;"><div>'.$showvalue.'</div></td>';
                        }
                    }
                    $row_total_arr[$num] = array('value'=>$tmp_sum,'tag'=>$tag,'record'=>$record);
                    if($tmp_type == 'Groupsum'){
                        $row_head_arr[$num] = array('colspan'=>2,'group_label'=>$groupname.'-','name_label'=>getFixedLabel('SUBTOTAL'));
                    }else if($tmp_type == 'Group'){
                        $row_head_arr[$num] = array('colspan'=>2,'group_label'=>$groupname.'-','name_label'=>getFixedLabel('TEMPLATETARGET'));
                    }else{
                        $row_head_arr[$num] = array('colspan'=>1,'group_label'=>$groupname,'name_label'=>$record_info[$record],'status'=>$status);
                    }
                    $salesgoal .= '</tr>';
                    $i++;
                    $num++;
                }while($i<$tmp_len+2);
            }
        }else{
            $tmp_type = $modulename;
            $num = 0;
			//XUQIU20240415-03 目标管理，增加“显示离职成员”参数（杨雅媚）wsh 20240918
            $usersInfoArr = $this->getUserStatus(implode(',',array_keys($record_info)));
            foreach($record_info as $record=>$info){
                $status = $usersInfoArr[$record];
                //获取头部tr
                $salesgoal.= $this->getTrhtml($num);
                $tmp_sum = 0;
                foreach($yearmonth as $month){
                    $targetvalue = $salestarget[$modulename][$record][$month];
                    if(empty($targetvalue)){
                        $targetvalue = 0;
                    }
                    $month_total_by_record_arr[$month][$record] = $targetvalue;
                    $tmp_sum += $targetvalue;
                    $showvalue = $this->getShowValue($targetvalue,$Decimal,$datatype,$mode);
                    $tag = 'RecordTarget';
                    if($mode == 'edit'){
                        $labelname = $record.'-'.$month.'-'.$targetid;
                        $salesgoal .= '<td ><div><input class="detailedViewTextBox" month="'.$month.'" tag="'.$tag.'" record="'.$record.'"  type="text" value="'.$showvalue.'" id="'.$labelname.'" name="'.$labelname.'" style="text-align:right;border:none;" size="8" /></div></td>';
                    }else{
                        $salesgoal .= '<td style="background:transparent;"><div>'.$showvalue.'</div></td>';
                    }
                }
                $row_total_arr[$num] = array('value'=>$tmp_sum,'tag'=>'RecordTarget','record'=>$record);
                $row_head_arr[$num] = array('colspan'=>1,'group_label'=>'','name_label'=>$info,'status'=>$status);
                $salesgoal .= '</tr>';
                $num++;
            }
        }
        $this->row_head_arr = $row_head_arr;
        $this->row_total_arr = $row_total_arr;
        //显示合计行
        if(sizeof($month_total_by_record_arr) > 0){
            //获取头部tr
            $tag = 'RecordTargetSum';
            $salesgoal.= $this->getSumHtml($yearmonth,$month_total_by_record_arr,$num,$datatype,$mode,$tag);
            $this->row_total_arr[$num]['tag'] = 'RecordTargetSum';
            $this->row_head_arr[$num] = array('colspan'=>2,'name_label'=>getTranstab($modulename).getFixedLabel('SUM'),'linetype'=>'sum');
            $num++;
        }
        //显示部门目标合计行
        if($groupsetting == 'allowedit' && sizeof($month_total_by_group_arr) > 0){
            //获取头部tr
            $tag = 'GroupTargetSum';
            $salesgoal.= $this->getSumHtml($yearmonth,$month_total_by_group_arr,$num,$datatype,$mode,$tag);
            $this->row_total_arr[$num]['tag'] = 'GroupTargetSum';
            $this->row_head_arr[$num] = array('colspan'=>2,'group_label'=>'','name_label'=>getFixedLabel('Sector').getFixedLabel('SUM'),'linetype'=>'sum');
            $num++;
        }
        return $salesgoal;
    }
	/**
	 * 获取销售目标合计值
	 * @author Tujt 2015-07-01
	 */
	public function getSalesGoalSum($datatype,$mode) {
	    if(!is_array($this->row_total_arr) || sizeof($this->row_total_arr) == 0){
	        return '';
        }
        $salesgoal = '';
        $cymbol = '¥';
        $Decimal = self::getAmountDecimal();
	    foreach ($this->row_total_arr as $rowindex=> $tmp_info){
            $tag = $tmp_info['tag'].'Row';
            $value = $tmp_info['value'];
            if($datatype == 'amount'){
                if($mode == 'edit'){
                    $showvalue = number_format($value,$Decimal,'.','');
                }else{
                    $showvalue = setNumberFormat($value,$Decimal);
                }
            }else{
                $cymbol = '';
                $showvalue = $value;
            }

            $salesgoal .= '<tr>';
            $salesgoal .= '<td><div>'.$cymbol.'<span tag="'.$tag.'" record="'.$tmp_info['record'].'" id="TargetValueSum" >'.$showvalue.'</span></div></td> ';
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
	public  function getUserGroup($users,$targetid){
        $salesgoalinfo = $this->getSalesGolaInfoByid($targetid);
        if(!in_array($salesgoalinfo['groupsetting'],$this->permit_groupset_arr)){
            return [];
        }
        if(empty($users)) return '';
        if(isset($users['undefind'])) return '';

        global $adb;
        $userGroup=array();
        $this->groupseq_arr = [];
        $usersId = implode(',',array_keys($users));
        $query ='SELECT
		IFNULL(ld_groups.groupid,0) groupid,
		ld_users.id userid,
		ld_users.status,
		ld_groups.groupname,
		ld_groups.parentgroup,
		ld_groups.parentid,
		ld_groups.depth,
        ld_groups.groupseq 
FROM
		ld_users
		LEFT JOIN ld_users2group on ld_users.id = ld_users2group.userid
		LEFT JOIN ld_groups  ON ld_users2group.groupid = ld_groups.groupid
WHERE
		ld_users.id IN ('.$usersId.')
ORDER BY 
		ld_groups.depth asc,ld_groups.groupseq asc,ld_groups.groupid,ld_users.id';
        $result = $adb->pquery($query,array());
        //获取最大的groupseq 值
        $tmp_sql = "SELECT MAX(groupseq) as maxseq from ld_groups";
        $tmp_result = $adb->pquery($tmp_sql);
        if($adb->num_rows($tmp_result)>0){
            $maxseq = $adb->query_result($tmp_result,0,'maxseq');
        }
        $tmp_seq = 0;
        $before_depth = 0;
        while($row = $adb->fetch_array($result)){
            if($before_depth != $row['depth']){
                $tmp_seq = 0;
            }
            $tmp_seq ++;

            $groupobj=new Group();
            if($row['groupname'] == '' && $row['groupid'] == 0){
                continue;
            }
            $groupobj->groupid=$row['groupid'];
            $groupobj->groupname=$row['groupname'];
            $row['groupname']=getWx_GroupName($groupobj);
            $userGroup[$row['groupid']][] =$row;
            //edit:duan date:2024/10/23 reason:特殊处理客户001中groupseq为0的情况
            if($row['groupseq'] == 0){
                $cur_seq = $tmp_seq;
            }else{
                $cur_seq = $row['groupseq'];
            }
            //树状图显示是从下往上，所以获取顺序的时候要逆序
            $this->groupseq_arr[$row['groupid']] = $maxseq - $cur_seq +1;

            $before_depth = $row['depth'];
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
        //获取最大的groupseq 值
        $tmp_sql = "SELECT MAX(groupseq) as maxseq from ld_groups";
        $tmp_result = $adb->pquery($tmp_sql);
        if($adb->num_rows($tmp_result)>0){
            $maxseq = $adb->query_result($tmp_result,0,'maxseq');
        }

        $query ='SELECT
        groupid,groupname,parentgroup,parentid,depth,groupseq
FROM
		ld_groups
ORDER BY 
		depth,groupseq,groupid';
//        $query = 'SELECT groupid,userid FROM ld_users2group WHERE userid IN ('.$usersId .')  ORDER BY groupid';
        $result = $adb->pquery($query,array());
        $groups=array();
        //edit: xll 2024/01/02 BUG0078098 目标管理树状图顺序seq导致数据错乱
        for ($i = 0; $i < $adb->num_rows($result); $i ++){
            $row = $adb->fetch_array($result);
            $groups[$i] = $row;
            //树状图显示是从下往上，所以获取顺序的时候要逆序
            $groups[$i]['groupseq'] = $maxseq - $row['groupseq'] + 1;
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
    public function newGetSalesGoalReport() {
       
        if(empty($this->month_total_by_record_arr)) return array();

        foreach($this->month_total_by_record_arr as $month=>$total_arr){
            $targetvalue = 0;
            $finishvalue = 0;
            foreach ($total_arr as $tmp_info){
                $targetvalue += $tmp_info['target'];
                $finishvalue += $tmp_info['finish'];
            }
            $fieldName[] = $month;
            $fieldValue0[]= $targetvalue; //销售目标数据
            $fieldValue1[]= setNumberFormatEmptySeperator($finishvalue,self::getAmountDecimal()); //目标完成数据
        }
        $lineName =array(getFixedLabel('TEMPLATETARGET'),getFixedLabel('TEMPLATECOMPLETE'));
        $values=compact('lineName','fieldValue1','fieldValue0','fieldName');
        $values['ModuleName']='CompanyAllMonthSalesGoal';
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
    public static function treeChildrenValue(&$data,$groupids,$value,$topParentid,$groupseq_arr)
    {
        $newdata='';
        $groupids = array_values($groupids);
        foreach ($groupids as $k => $groupid) {
            if($k ==0){
                if($groupid==0 || $groupid ==$topParentid){
                    $newdata = &$data['children'];
                }else{
                    $groupseq = $groupseq_arr[$groupid];
                    $newdata = &$data[$groupseq]['children'];
                }
                if (count($groupids) !=1) {
                    unset($groupids[$k]);
                    self::treeChildrenValue($newdata, $groupids, $value,$topParentid,$groupseq_arr);
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
    public static function treeChildrenValue2(&$data,$groupids,$value,$topParentid,$groupseq_arr)
    {
        $newdata='';
        $groupids = array_values($groupids);
        foreach ($groupids as $k => $groupid) {
            if($k ==0){
                if($groupid == 0 || $groupid==$topParentid){
                    $newdata = &$data;
                }else{
                    $groupseq = $groupseq_arr[$groupid];
                    $newdata = &$data['children'][$groupseq];
                }
                if (count($groupids) !=1) {
                    unset($groupids[$k]);
                    self::treeChildrenValue2($newdata, $groupids, $value,$topParentid,$groupseq_arr);
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
    public function getUserStatus($ids)
    {
        global $adb;
        if(empty($targetid)){
            return [];
        }
        $sql = ' select id,`status` from ld_users where id in ' . '(' . $ids .')';
        $result = $adb->query($sql);
        $rows = $adb->num_rows($result);
        $usersInfoArr = [];
        if($rows > 0){
            for($i=0;$i<$rows;++ $i){
                $status = $adb->query_result($result,$i,'status');
                $id = $adb->query_result($result,$i,'id');
                $usersInfoArr[$id] = $status;
            }
        }
        return $usersInfoArr;
    }
    /**
     * name: 返回树状图标json数据
     * User: Dong
     * Date: 2020/5/14 18:30
     * @param $users
     * @param $userGroup
     * @return json
     */
    public function getGetSalesGoalTree($record_info,$userGroup,$search_date,$targetid)
    {
        global $adb;
        $salesgoalinfo = $this->getSalesGolaInfoByid($targetid);
        $modulename = $salesgoalinfo['modulename'];
        $groupsetting = $salesgoalinfo['groupsetting'];
        //把下级部门赋值给上级
        $record_total_by_month_arr = $this->record_total_by_month_arr;
        $group_total_by_month_arr = $this->group_total_by_month_arr;

        if($modulename == 'Users' && in_array($groupsetting,$this->permit_groupset_arr)){
            if(empty($userGroup)) return false;
            $groups = self::getGroup();
        }else{
            $groups[] = ['groupid'=>0,'groupname'=>getTranstab($modulename),'depth'=>0,'parentid'=>-1,'parentgroup'=>0];
            $userGroup = [];
            foreach ($record_info as $tmp_record => $tmp_label){
                $group_total_by_month_arr[0]['target'] += $record_total_by_month_arr[$tmp_record]['target'];
                $group_total_by_month_arr[0]['finish'] += $record_total_by_month_arr[$tmp_record]['finish'];
                $userGroup[0][] = ['userid'=>$tmp_record];
            }
        }
        $datatype = $salesgoalinfo['datatype'];
        $demcial = self::getAmountDecimal();
        $data =array();
        $topParentid='';
        $mode = 'Tree';
        $newUserGroup=$userGroup;

        //记录已经统计过的用户ID,避免一个用户在多个部门中被多次计算
        $used_record_arr = [];
        $all_child_group_arr = [];

        foreach ($groups as $group){
            $tmp_groupid = $group['groupid'];
            $gourpinfo_arr[$tmp_groupid] = $group;
            $all_child_group_arr[$group['parentid']][] = $tmp_groupid;
            $parentGroup = explode('::',$group['parentgroup']);
            arsort($parentGroup); //排序
            foreach ($parentGroup as $k=>$groupid){
                if($groupid == $group['groupid']) continue;
                isset($newUserGroup[$groupid]) ?: $newUserGroup[$groupid]=array();
                isset($userGroup[$group['groupid']]) ?: $userGroup[$group['groupid']]=array();

                $newUserGroup[$groupid] = array_merge($newUserGroup[$groupid],$userGroup[$group['groupid']]);
            }
        }
        //将子部门中的目标添加到上一级部门中
        $orgin_group_total_by_month_arr = $group_total_by_month_arr;//保存原始数据
        $sort_groups = array_reverse($groups);
        //部门的合计按下级部门统计


        foreach ($sort_groups as $tmp_arr){
            $tmp_groupid = $tmp_arr['groupid'];
            $tmp_group = $newUserGroup[$tmp_groupid];
            $child_group_arr = [];


            foreach ($tmp_group as $tmp_info){
                $tmp_userid = $tmp_info['userid'];
                $tmp_child_groupid = $tmp_info['groupid'];
                if(is_array($used_record_arr[$tmp_groupid]) && in_array($tmp_userid,$used_record_arr[$tmp_groupid])){
                    continue;
                }
                if(!is_array($used_record_arr[$tmp_groupid]) || count($used_record_arr[$tmp_groupid]) == 0){
                    $used_record_arr[$tmp_groupid] = [];
                    $group_total_by_month_arr[$tmp_groupid]['finish'] = 0;
                    if($groupsetting != 'allowedit'){
                        $group_total_by_month_arr[$tmp_groupid]['target'] = 0;
                    }
                }
                $used_record_arr[$tmp_groupid][] = $tmp_userid;
                $finish_value = $record_total_by_month_arr[$tmp_userid]['finish'];
                $group_total_by_month_arr[$tmp_groupid]['finish'] += $finish_value;

                if($groupsetting != 'allowedit'){
                    $group_total_by_month_arr[$tmp_groupid]['target'] += $record_total_by_month_arr[$tmp_userid]['target'];
                }
            }
            if($groupsetting == 'allowedit' && !isset($orgin_group_total_by_month_arr[$tmp_groupid])){

                foreach($all_child_group_arr[$tmp_groupid] as $tmp_id){
                    if(!in_array($tmp_id,$child_group_arr)&&isset($group_total_by_month_arr[$tmp_id]['target'])){
                        $tmp_value = $group_total_by_month_arr[$tmp_id]['target'];
                        $group_total_by_month_arr[$tmp_groupid]['target'] += $tmp_value;
                        $child_group_arr[] = $tmp_id;
                    }
                }
            }

        }

        /* 合计按所有下级用户统计
        foreach ($newUserGroup as $tmp_groupid => $tmp_group){
            foreach ($tmp_group as $tmp_info){
                $tmp_userid = $tmp_info['userid'];
                if(in_array($tmp_userid,$used_record_arr[$tmp_groupid])){
                    continue;
                }
                if(count($used_record_arr[$tmp_groupid]) == 0){
                    $group_total_by_month_arr[$tmp_groupid]['finish'] = 0;
                    if($groupsetting != 'allowedit'){
                        $group_total_by_month_arr[$tmp_groupid]['target'] = 0;
                    }
                }
                $used_record_arr[$tmp_groupid][] = $tmp_userid;
                $finish_value = $record_total_by_month_arr[$tmp_userid]['finish'];
                $group_total_by_month_arr[$tmp_groupid]['finish'] += $finish_value;
                if($groupsetting != 'allowedit'){
                    $group_total_by_month_arr[$tmp_groupid]['target'] += $record_total_by_month_arr[$tmp_userid]['target'];
                }else if(!isset($orgin_group_total_by_month_arr[$tmp_groupid])){ //如果该部门没有设置目标值，则计算下级部门中用户的合计
                    $group_total_by_month_arr[$tmp_groupid]['target'] += $record_total_by_month_arr[$tmp_userid]['target'];
                }
            }
        }
        */

        foreach($groups as $k => $group){
            $parentGroup = explode('::',$group['parentgroup']);
            $topParentid =$parentGroup[0];

            if($group['depth'] == 0){
                $data['record_str'] = implode(',',array_keys($record_info));
				//XUQIU20240415-03 目标管理，增加“显示离职成员”参数（杨雅媚）wsh 20240918
                $usersInfoArr = $this->getUserStatus($data['record_str']);
                $groupid = $group['groupid'];
                $groupobj=new Group();
                $groupobj->groupid=$group['groupid'];
                $groupobj->groupname=$group['groupname'];
                $tmp_groupname=getWx_GroupName($groupobj);
                $data['name']=$tmp_groupname;
                $data['search_date']=$search_date;
                $data['targetid']=$targetid;
                $target_value = $group_total_by_month_arr[$groupid]['target'];
                $finish_value = $group_total_by_month_arr[$groupid]['finish'];
                $percent = self::calPercent($finish_value,$target_value);
                $data['tolook']= $this->getShowValue($target_value,$demcial,$datatype,$mode,$targetid);
                $data['complete']= $this->getShowValue($finish_value,$demcial,$datatype,$mode,$targetid);
                //wyt 2209010 1000179销售目标，树状图表的目标、完成值、完成率增加高度或颜色区分（戚涛）
                $height_info = $this->getTargetHegiht($percent);
                $data['tolookheight'] = $height_info['tolook'];
                $data['completeheight'] = $height_info['complete'];
                $data['colorpercent'] = $height_info['color'];

                $data['percent'] = number_format($percent,2);
                $childUser=array();

                foreach ($userGroup[0] as $userid =>$user){  //所有无部门的人员
                    $tmp_userid = $user['userid'];
                    $extra_name = $usersInfoArr[$tmp_userid] == 'Inactive' ? '<span style="color: red;">('.getFixedLabel('Quit').')</span>':'';
                    $target_value = $record_total_by_month_arr[$tmp_userid]['target'];
                    $finish_value = $record_total_by_month_arr[$tmp_userid]['finish'];
                    if($target_value !=0 || $finish_value !=0){
                        $percent = self::calPercent($finish_value,$target_value);
                        $height_info = $this->getTargetHegiht($percent);
                        $tolookheight = $height_info['tolook'];
                        $completeheight = $height_info['complete'];
                        $colorpercent = $height_info['color'];

                        $tempuser = array(
                            'type'=>'1',
                            'name'=>$record_info[$user['userid']],
                            'extra_name'=>$extra_name,
                            'record_str'=>$user['userid'],
                            'search_date'=>$search_date,
                            'targetid'=>$targetid,
                            'tolookheight'=> $tolookheight,
                            'completeheight'=> $completeheight,
                            'colorpercent'=> $colorpercent,
                            'tolook'=>$this->getShowValue($target_value,$demcial,$datatype,$mode,$targetid),
                            'complete'=>$this->getShowValue($finish_value,$demcial,$datatype,$mode,$targetid),
                            'percent'=>number_format($percent,2),
                        );
                        $childUser['user'.$tmp_userid] =$tempuser;
                    }
                }
                foreach ($userGroup[1] as $userid =>$user){
                    $tmp_userid = $user['userid'];
                    $extra_name = $user['status'] == 'Inactive' ? '<span style="color: red;">('.getFixedLabel('Quit').')</span>':'';
                    $target_value = $record_total_by_month_arr[$tmp_userid]['target'];
                    $finish_value = $record_total_by_month_arr[$tmp_userid]['finish'];
                    if($target_value !=0 || $finish_value !=0){
                        $percent = self::calPercent($finish_value,$target_value);
                        //获取
                        $height_info = $this->getTargetHegiht($percent);
                        $tolookheight = $height_info['tolook'];
                        $completeheight = $height_info['complete'];
                        $colorpercent = $height_info['color'];

                        $tempuser = array(
                            'type'=>'1',
                            'name'=>$record_info[$user['userid']],
                            'extra_name'=>$extra_name,
                            'record_str'=>$user['userid'],
                            'search_date'=>$search_date,
                            'targetid'=>$targetid,
                            'tolookheight'=> $tolookheight,
                            'completeheight'=> $completeheight,
                            'colorpercent'=> $colorpercent,
                            'tolook'=>$this->getShowValue($target_value,$demcial,$datatype,$mode,$targetid),
                            'complete'=>$this->getShowValue($finish_value,$demcial,$datatype,$mode,$targetid),
                            'percent'=>number_format($percent,2),
                        );
                        $childUser['user'.$user['userid']] =$tempuser;

                    }
                }

                self::treeChildrenValue($data,$parentGroup,$childUser,$topParentid,$this->groupseq_arr);
            }
            else{
                $tmp_groupid = $group['groupid'];
                //edit: xll 2024/01/02 BUG0078098 目标管理树状图顺序seq导致数据错乱
                if(!isset($this->groupseq_arr[$tmp_groupid])){
                    $this->groupseq_arr[$tmp_groupid] = $group['groupseq'];
                }
                $target_value = $group_total_by_month_arr[$tmp_groupid]['target'];
                $finish_value = $group_total_by_month_arr[$tmp_groupid]['finish'];
                //duan truec 的解释，部门本身设置目标为0 时，可能下级部门或用户目标不是0.先不隐藏部门
                if(($target_value != 0 || $finish_value != 0 || true) && isset($group_total_by_month_arr[$tmp_groupid])){
                    $percent = self::calPercent($finish_value,$target_value);
                    $userStr ='';
                    foreach ($newUserGroup[$tmp_groupid] as $k =>$user){
                        if($k+1 == count($newUserGroup[$tmp_groupid])){
                            $userStr.= $user['userid'];
                        }else{
                            $userStr.= $user['userid'].',';
                        }
                    }
                    $groupobj=new Group();
                    $groupobj->groupid=$tmp_groupid;
                    $groupobj->groupname=$group['groupname'];
                    $groupname=getWx_GroupName($groupobj);

                    $height_info = $this->getTargetHegiht($percent);
                    $tolookheight = $height_info['tolook'];
                    $completeheight = $height_info['complete'];
                    $colorpercent = $height_info['color'];
                    $tempGroup = array(
                        'name' => $groupname,
                        'targetid'=> $targetid,
                        'record_str'=>$userStr,
                        'search_date'=>$search_date,
                        'tolookheight'=> $tolookheight,
                        'completeheight'=> $completeheight,
                        'colorpercent'=> $colorpercent,
                        'tolook'=>$this->getShowValue($target_value,$demcial,$datatype,$mode,$targetid),
                        'complete'=>$this->getShowValue($finish_value,$demcial,$datatype,$mode,$targetid),
                        'percent'=>number_format($percent,2),
                    );

                    self::treeChildrenValue2($data, $parentGroup, $tempGroup,$topParentid,$this->groupseq_arr);

                    $childUser = array();
                    foreach ($userGroup[$group['groupid']] as $userid => $user) {
                        $tmp_userid = $user['userid'];
                        $extra_name = $user['status'] == 'Inactive' ? '<span style="color: red;">('.getFixedLabel('Quit').')</span>':'';
                        $target_value = $record_total_by_month_arr[$tmp_userid]['target'];
                        $finish_value = $record_total_by_month_arr[$tmp_userid]['finish'];
                        if($target_value !=0 || $finish_value !=0){
                            $percent = self::calPercent($finish_value,$target_value);

                            $height_info = $this->getTargetHegiht($percent);
                            $tolookheight = $height_info['tolook'];
                            $completeheight = $height_info['complete'];
                            $colorpercent = $height_info['color'];
                            $tempuser = array(
                                'type'=>'1',
                                'name' => $record_info[$user['userid']],
                                'extra_name'=>$extra_name,
                                'record_str'=>$user['userid'],
                                'search_date'=>$search_date,
                                'targetid'=> $targetid,
                                'tolookheight'=> $tolookheight,
                                'completeheight'=> $completeheight,
                                'colorpercent'=> $colorpercent,
                                'tolook'=>$this->getShowValue($target_value,$demcial,$datatype,$mode,$targetid),
                                'complete'=>$this->getShowValue($finish_value,$demcial,$datatype,$mode,$targetid),
                                'percent'=>number_format($percent,2),
                            );
                            $childUser['user' . $user['userid']] = $tempuser;
                        }
                    }
                    self::treeChildrenValue($data, $parentGroup, $childUser,$topParentid,$this->groupseq_arr);
                }
            }
        }

        self::formateArray($data);
        return ldcrm_json_encode($data);
    }

    public function getGetSalesGoalTreeNogroup($record_info,$userGroup,$search_date,$targetid)
    {



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
    //duan 获取可选销售指标
    public function getPermitSalesGoal($default_targetid){
        $current_user = $this->user;
        $adb = $this->db;
        $languagetype = getLanguageType($current_user);
        if($current_user->is_admin == 'on'){
            $tmp_sql = "SELECT DISTINCT targetid as tmp_id from ld_salestarget_basic
                LEFT JOIN ld_tabshare on ld_salestarget_basic.targetid = ld_tabshare.crmid
                where ld_salestarget_basic.`status` = 'yes'";
            $column_value_arr = [];
        }else{
            //BUG20240429-55 成员管理->目标管理，数据范围没有生效 
            $ScopOfAuthorityobj = new ScopOfAuthority($adb,'SalesGoal');
            $scopeid = $ScopOfAuthorityobj->getCurUserScopeId();
            $scopesql = '';
            //edit: xll 2024/09/10 数据范围为全部则全部可见
            if($scopeid == 'All'){
                $scopesql = ' or 1=1 ';
            }else{
                $scopesql = ' or ld_salestarget_basic.smownerid in ('.$scopeid.')';
            }
            $tmp_sql = "SELECT DISTINCT targetid as tmp_id from ld_salestarget_basic
                LEFT JOIN ld_tabshare on ld_salestarget_basic.targetid = ld_tabshare.crmid
                where ld_salestarget_basic.`status` = 'yes' 
                and (ld_salestarget_basic.smownerid = ? or ld_tabshare.Shareuserid = ? ".$scopesql." )";
            $column_value_arr = [$current_user->id,$current_user->id];
        }
        //edit: xll 2023/08/14 XUQIU1001400 目标管理增加是否在首页显示参数控制
        //wym 240408 XUQIU20240305-01 目标管理，增加“设置指标单位”参数控制，可配置统计字段的计量单位（张华）
        $query = "SELECT targetid,targetname,zhlabel,enlabel,modulename,groupsetting,`scope`,showtype,indicator_unit,conversion_rate,displayinactiv from ld_salestarget_basic INNER JOIN (".
            $tmp_sql.") as tmp on ld_salestarget_basic.targetid = tmp.tmp_id ORDER BY `sequence` asc;";
        $result = $adb->pquery($query,$column_value_arr);

        $num_rows = $adb->num_rows($result);
        $all_salesgoal_info = [];
        $choosed = 'no';
        $resultinfo = [];
        $detailinfo = $this->GetSalesGoalDetailInfo();

        if($num_rows >0){
            $resultinfo = $adb->query_result_all($result);
            foreach($resultinfo as &$tmpinfo){
                $targetid = $tmpinfo['targetid'];
                $tmpinfo['datatype'] = 'amount';
                $indicator_unit = $tmpinfo['indicator_unit'];
                if(isset($this->unitlabel_arr[$indicator_unit]))
                {
                    $tmpinfo['datatype'] = $this->unitlabel_arr[$indicator_unit]['datatype'];
                }
                if($languagetype == 'en'){
                    $tmpinfo['label'] = $tmpinfo['enlabel'];
                }else{
                    $tmpinfo['label'] = $tmpinfo['zhlabel'];
                }
                if($default_targetid == $targetid){
                    $tmpinfo['selected'] = 'yes';
                    $choosed = 'yes';
                }
                if($tmpinfo['modulename'] != 'Users'){
                    $tmpinfo['groupsetting'] = '';
                }
                // duan 20240702 根据单位判断数据类型
                if(isset($detailinfo[$targetid])){
                    $tmpinfo['detailinfo'] = $detailinfo[$targetid];
                }

                $all_salesgoal_info[$targetid] = $tmpinfo;
            }
            if ($choosed == 'no'){
                $resultinfo[0]['selected'] = 'yes';
            }
            $this->all_salesgoal_info = $all_salesgoal_info;
        }
        return $resultinfo;
    }
    //获取销售指标详情信息
    public function GetSalesGoalDetailInfo(){
        $adb = $this->db;
        $sql = "select id,targetid,entitytype,referencefield,funname,countfield,datefield,approvedemand,othercondition from ld_salestarget_detail ORDER BY id;";
        $result = $adb->pquery($sql,array());
        $num_rows = $adb->num_rows($result);
        $detail_info_arr = [];
        if($num_rows >0){
            $all_reulst = $adb->query_result_all($result);
            foreach ($all_reulst as $tmp_Arr){
                $targetid = $tmp_Arr['targetid'];
                $entitytype = $tmp_Arr['entitytype'];
                //判断数据类型，用于显示币种符号和小数位
                $datatype = 'num';
                if($tmp_Arr['funname'] == 'sum'){
                    $tmp_focus = CRMEntity::getInstance($entitytype);
                    $countfield_arr = explode(':',$tmp_Arr['countfield']);
                    $countfield_str = $countfield_arr[0].'.'.$countfield_arr[1];
                    //如果当前计算方式为合计，且字段为金额类型的字段，则需要按金额类型显示
                    if(in_array($countfield_arr[0],[$tmp_focus->table_name,$tmp_focus->customFieldTable[0]])){
                        $fieldinfo = $tmp_focus->fieldobj->getFieldInfoobjBykey('columnname',$countfield_arr[1]);
                    }else{
                        if(!empty($tmp_focus->detailfieldobj)){
                            $fieldinfo = $tmp_focus->detailfieldobj->getFieldInfoobjBykey('columnname',$countfield_arr[1]);
                        }
                    }
                    if(!empty($fieldinfo) && ($fieldinfo->istotalFldMoneyField() || $fieldinfo->isPriceField())){
                        $datatype = 'amount';
                    }
                }
                $tmp_Arr['datatype'] = $datatype;
                $detail_info_arr[$targetid][] = $tmp_Arr;
            }
        }
        return $detail_info_arr;
    }

    //duan 获取列表显示销售指标
    public function getListSalesGoal(){
        $current_user = $this->user;
        $adb = $this->db;
        $languagetype = getLanguageType($current_user);
        if($current_user->is_admin == 'on'){
            $tmp_sql = "SELECT DISTINCT targetid as tmp_id from ld_salestarget_basic
                LEFT JOIN ld_tabshare on ld_salestarget_basic.targetid = ld_tabshare.crmid";
            $column_value_arr = [];
        }else{
            $tmp_sql = "SELECT DISTINCT targetid as tmp_id from ld_salestarget_basic
                LEFT JOIN ld_tabshare on ld_salestarget_basic.targetid = ld_tabshare.crmid
                where  (ld_salestarget_basic.smownerid = ? or ld_tabshare.Shareuserid = ?)";
            $column_value_arr = [$current_user->id,$current_user->id];
        }
        //edit: xll 2023/08/14 XUQIU1001400 目标管理增加是否在首页显示参数控制
        $query = "SELECT targetid,zhlabel,enlabel,modulename,sequence,status,smownerid,smcreatorid,createdtime,modifiedtime,showtype from ld_salestarget_basic INNER JOIN (".
            $tmp_sql.") as tmp on ld_salestarget_basic.targetid = tmp.tmp_id ORDER BY sequence asc;";
        $result = $adb->pquery($query,$column_value_arr);

        $permisson_arr = $this->getAllPermitArr();

        $num_rows = $adb->num_rows($result);
        if($num_rows >0){
            $SharedUserArr = $this->getSharedUser();
            $resultinfo = $adb->query_result_all($result);
            foreach($resultinfo as &$tmpinfo){
                $targetid = $tmpinfo['targetid'];
                if(isset($SharedUserArr[$targetid])){
                    $tmpinfo['shareduserid'] = $SharedUserArr[$targetid];
                }else{
                    $tmpinfo['shareduserid'] = '';
                }
                if($languagetype == 'en'){
                    $tmpinfo['label'] = $tmpinfo['enlabel'];
                }else{
                    $tmpinfo['label'] = $tmpinfo['zhlabel'];
                }
                $tmpinfo['modulelabel'] = getTranstab($tmpinfo['modulename']);
                $tmpinfo['smowneridlabel'] = getUserFullName($tmpinfo['smownerid']);
                $tmpinfo['smcreatoridlabel'] = getUserFullName($tmpinfo['smcreatorid']);
            }
        }else{
            return  [];
        }
        return $resultinfo;
    }
    //获取共享人信息
    public function getSharedUser(){
        $adb = $this->db;
        $sql = "SELECT tmpdata.tmp_userids,ld_salestarget_basic.targetid from ld_salestarget_basic INNER JOIN 
            (SELECT GROUP_CONCAT(Shareuserid) as tmp_userids,crmid from ld_tabshare GROUP BY crmid) as tmpdata
            on tmpdata.crmid = ld_salestarget_basic.targetid";
        $result = $adb->pquery($sql,array());
        $num_rows = $adb->num_rows($result);
        $SharedUserArr = [];
        for ($i=0;$i<$num_rows;$i++){
            $tmp_targetid = $adb->query_result($result,$i,'targetid');
            $tmp_userids = $adb->query_result($result,$i,'tmp_userids');
            $SharedUserArr[$tmp_targetid] = $tmp_userids;
        }

        return $SharedUserArr;
    }
    //获取目标范围单据信息
    public function GetRecordInfo($default_arr,$scope){
        global  $currentModule;
        $cur_module = ($this->cur_module === '') ? $currentModule : $this->cur_module;
        $targetid = $default_arr['targetid'];
        $this->setTargetid($targetid);
        $scopetype = $default_arr['scope']; //目标范围类型
        $modulename = $default_arr['modulename'];
        $relatedid_arr = cls_related_scope::get_related_scope($cur_module,$this->relatedtype,$targetid);
        if($modulename == 'Users'){
            $users = $this->getUserInfo($scope);//获取用户数
            //根据设置的目标范围筛选用户
            $record_info = $this->GetUsersRange($users,$scopetype,$relatedid_arr);
        }else{
            $record_info = SalesGoalOperation::getEntitynameByid($modulename,$relatedid_arr);
        }
        return $record_info;
    }
    //获取用户的目标范围
    public function GetUsersRange($users,$scopetype,$relatedid_arr){
        //全部成员
        global $adb;
        //$adb = $this->db;
        $permit_userid_arr = [];
        $relatedid_str = implode(',',$relatedid_arr);
        global $adb;
        switch ($scopetype){
            case 'all':
                $permit_userid_arr = array_keys($users);
                break;
            case 'user':
                $permit_userid_arr = $relatedid_arr;
                break;
            case 'group':
                $sql = "SELECT GROUP_CONCAT(DISTINCT userid) as tmp_id from ld_users2group where groupid in (".$relatedid_str.")";
                $result = $adb->pquery($sql,[]);
                if($adb->num_rows($result)>0){
                    $tmp_id = $adb->query_result($result,0,'tmp_id');
                    $permit_userid_arr = explode(',',$tmp_id);
                }
                break;
            case 'role':
                $sql = "SELECT GROUP_CONCAT(id) as tmp_id from ld_users where profileid in (".$relatedid_str.")";
                $result = $adb->pquery($sql,[]);
                if($adb->num_rows($result)>0){
                    $tmp_id = $adb->query_result($result,0,'tmp_id');
                    $permit_userid_arr = explode(',',$tmp_id);
                }
                break;
            default:
                break;
        }
        $new_users_arr = [];
        foreach ($users as $tmp_id=>$tmp_name){
            if(in_array($tmp_id,$permit_userid_arr)){
                $new_users_arr[$tmp_id] = $tmp_name;
            }
        }
        return $new_users_arr;
    }
    //根据销售指标id获取信息
    public function getSalesGolaInfoByid($targetid){
        if(!isset($this->all_salesgoal_info[$targetid])){
            $this->getPermitSalesGoal('');
        }
        return $this->all_salesgoal_info[$targetid];
    }
    //判断是否需要显示部门目标
    public function IsShowGroupTarget($targetid){
        $salesgoalinfo = $this->getSalesGolaInfoByid($targetid);
        $groupsetting = $salesgoalinfo['groupsetting'];
        $isshow = 'no';
        if(in_array($groupsetting,$this->permit_groupset_arr)){
            $isshow = 'yes';
        }
        return $isshow;
    }
    //获取tr头部html
    public function getTrhtml($num){
        $salesgoal = '';
        if($num%2==0){
            $salesgoal.='<tr class="lvtColDataBj" onmouseover="SalesGoallistOnMouseOver('.$num.');" onmouseout="SalesGoallistOnMouseOut('.$num.',\'On\');" id="row_'.$num.'">';
        }
        else{
            $salesgoal.='<tr class="lvtColData" onmouseover="SalesGoallistOnMouseOver('.$num.');" onmouseout="SalesGoallistOnMouseOut('.$num.',\'on\');" id="row_'.$num.'">';
        }
        return $salesgoal;
    }
    
    //获取合计行html
    public function getSumHtml($yearmonth,$info_arr,$num,$datatype,$mode,$tag){
        $salesgoal = '';
        $salesgoal.= $this->getTrhtml($num);
        $tmp_row_sum = 0;
        $Decimal = self::getAmountDecimal();
        $cymbol = '¥';
        foreach($yearmonth as $month){
            $tmp_value_arr = $info_arr[$month];
            $targetvalue = 0;
            foreach ($tmp_value_arr as $tmp_value){
                $targetvalue += $tmp_value;
            }
            $tmp_row_sum += $targetvalue;
            if(empty($tmp_value_arr)){
                $targetvalue = 0;
            }
            if($datatype == 'num'){
                $showvalue = $targetvalue;
            }else{
                if($mode == 'edit'){
                    $targetvalue = number_format($targetvalue,$Decimal,'.','');
                    $showvalue = $targetvalue;
                }else{
                    $targetvalue = setNumberFormat($targetvalue,$Decimal);
                    $showvalue = $cymbol.$targetvalue;
                }
            }
            if($mode == 'edit'){
                $labelname = 'TargetValueTotal';
                $salesgoal .= '<td ><div><input class="detailedViewTextBox" record="-1" tag="'.$tag.'" type="text" month="'.$month.'" value="'.$showvalue.'" id="'.$labelname.'" name="'.$labelname.'" style="text-align:right;border:none;" size="8" /></div></td>';
            }else{
                $salesgoal .= '<td style="background:transparent;"><div>'.$showvalue.'</div></td>';
            }
        }
        $salesgoal .= '</tr>';
        $this->row_total_arr[$num] = array('value'=>$tmp_row_sum,'record'=>-1);
        return $salesgoal;
    }
    //获取单据的高级查询条件，包括日期范围，其他条件，并组合到一个高级查询中
    public function  GetSearchCondition($detailinfo,$yearmonth){
        list($start,$end) = self::getFilterDateInfo($yearmonth);
        $entitytype = $detailinfo['entitytype']; //指标模块
        $referencefield = $detailinfo['referencefield']; //对象查询字段
        $funname = $detailinfo['funname']; //计算方法
        $countfield = $detailinfo['countfield']; //统计字段
        $datefield = $detailinfo['datefield']; //日期查询字段
        $approvedemand = $detailinfo['approvedemand']; //审批要求
        $othercondition = $detailinfo['othercondition']; //其他条件

        $focus = CRMEntity::getInstance($entitytype);
        $tmp_arr = [];
        $tmp_arr['searchtype']='advance';
        if(!empty($othercondition)){
            $advft_arr = ldcrm_json_decode($othercondition);
            $tmp_arr['advft_criteria'] = $advft_arr['advft_criteria'];
            $tmp_arr['advft_criteria_groups'] = $advft_arr['advft_criteria_groups'];
        }else{
            $tmp_arr['advft_criteria'] = '';
            $tmp_arr['advft_criteria_groups'] = '';
        }

        $max_groupid = 0;
        if(!empty($tmp_arr['advft_criteria'])){
            foreach($tmp_arr['advft_criteria'] as $tmp_info){
                $tmp_groupid = $tmp_info['groupid'];
                if($tmp_groupid > $max_groupid){
                    $max_groupid = $tmp_groupid;
                }
            }
            $new_groupid = $max_groupid+1;
        }else{
            $tmp_arr['advft_criteria'] = [];
            $tmp_arr['advft_criteria_groups'] = [];
            $new_groupid = $max_groupid+1;
        }
        //准备高级查询条件
        $tmp_advft_criteria = [];
        $tmp_advft_criteria['groupid'] = $new_groupid;
        $tmp_advft_criteria['columncondition'] = 'and';
        //设置审批高级查询条件
        if($approvedemand == 1){
            $sys_approve = getSys_Approvedeploy($entitytype);
            $tmp_column = 'approvestatus';
            if($sys_approve['deploy_value'] == 0 && isset($focus->column_fields[$tmp_column])){
                $approve_column = $focus->table_name.':'.$tmp_column.':'.$tmp_column.':'.$entitytype.'_fieldlabel:V';
                $tmp_advft_criteria['groupid'] = $new_groupid;
                $tmp_advft_criteria['columnname'] = $approve_column;
                $tmp_advft_criteria['comparator'] = 'e';
                $tmp_advft_criteria['value'] = constant('D_A_S_APPROVED');
                $tmp_arr['advft_criteria'][] = $tmp_advft_criteria;
            }
        }
        //日期范围条件
        $tmp_advft_criteria['columnname'] = $datefield;
        $tmp_advft_criteria['comparator'] = 'bw';
        $tmp_advft_criteria['value'] = $start.' 00:00:00'.','.$end.' 23:59:59';
        $tmp_arr['advft_criteria'][] = $tmp_advft_criteria;
        //对象查询字段不为空条件
        $tmp_advft_criteria['columnname'] = $referencefield;
        $tmp_advft_criteria['comparator'] = 'isnotnull';
        $tmp_advft_criteria['value'] = '';
        $tmp_arr['advft_criteria'][] = $tmp_advft_criteria;
        //统计字段不为空条件
        $tmp_advft_criteria['columnname'] = $countfield;
        $tmp_advft_criteria['comparator'] = 'isnotnull';
        $tmp_advft_criteria['value'] = '';
        $tmp_advft_criteria['columncondition'] = '';
        $tmp_arr['advft_criteria'][] = $tmp_advft_criteria;

        if($new_groupid == 1){
            $tmp_arr['advft_criteria_groups'] = array('',array('groupcondition'=>''));
        }else{
            $tmp_arr['advft_criteria_groups'][$max_groupid]['groupcondition'] = 'and';
            $tmp_arr['advft_criteria_groups'][$new_groupid] = array('groupcondition'=>'');
        }

        $tmp_arr['advft_criteria'] = ldcrm_json_encode($tmp_arr['advft_criteria']);
        $tmp_arr['advft_criteria_groups'] = ldcrm_json_encode($tmp_arr['advft_criteria_groups']);
        return $tmp_arr;
    }

    public function get_page_query_new($detailinfo,$yearmonth,$recordinfo){
        $entitytype = $detailinfo['entitytype']; //指标模块
        $referencefield = $detailinfo['referencefield']; //对象查询字段
        $funname = $detailinfo['funname']; //计算方法
        $countfield = $detailinfo['countfield']; //统计字段
        $datefield = $detailinfo['datefield']; //日期查询字段
        $detailid = $detailinfo['id']; //目标分录的主键
        $record_str = implode(',',array_keys($recordinfo));
        //创建查询sql相关对象
        $tmp_focus = CRMEntity::getInstance($entitytype);
        $tmp_queryobj =$this->get_query_obj($entitytype);
        $tmp_queryobj->initForCustomViewById($detailid);
        if(!empty($tmp_queryobj->productDetails)){
            $tmp_queryobj->productDetails->customViewColumnList = $tmp_queryobj->customViewColumnList;
        }
        //控制相关参数
        $tmp_queryobj->moduleobj->orderby_tables = [];
        $tmp_queryobj->notabsharesql = 'yes';
        //销售目标统计时,不判断数据范围
        $tmp_queryobj->scopeobj = '';
        $tmp_queryobj->getSmOwnerSearchSql = '';
        $tmp_queryobj->smownerScope = '';
        $tmp_queryobj->scope_sql = '';
        //获取需要使用的表名和字段名
        $detail_table = $tmp_focus->Detail_table;
        $detail_table_scf = $tmp_focus->Detail_table_scf;
        //组合需要查询的字段
        $countfield_arr = explode(':',$countfield);
        $countfield_str = $countfield_arr[0].'.'.$countfield_arr[1];
        $referencefield_arr = explode(':',$referencefield);
        if($referencefield_arr[1] == 'productname'){
            $referencefield_str = $referencefield_arr[0].'.productid';
        }else{
            $referencefield_str = $referencefield_arr[0].'.'.$referencefield_arr[1];
        }
        $datefield_arr = explode(':',$datefield);
        $datefield_str = $datefield_arr[0].'.'.$datefield_arr[1];
        $field_table_arr = [$countfield_arr[0],$referencefield_arr[0],$datefield_arr[0]];
        $countfield_column = $countfield_arr[1];
        $referencefield_column = $referencefield_arr[1];
        //产品名称特殊处理
        if($referencefield_column == 'productname'){
            $referencefield_column = 'productid';
        }
        $datefield_column = $datefield_arr[1];

        $detail_table_arr = [];
        $detailtype = 'no';
        if(get_file_address($entitytype,"ProductDetails")){
            $detail_table_arr = ['ld_products','ld_productcf',$detail_table,$detail_table_scf];
            $detailtype = 'Products';
        }else if(get_file_address($entitytype,$entitytype."DetailFieldsHtml")){
            $detail_table_arr = [$detail_table,$detail_table_scf];
            $detailtype = 'normal';
            if(in_array($countfield_arr[0],$detail_table_arr)){
                $countfield_column = 'tabdetail_'.$countfield_column;
            }
            if(in_array($referencefield_arr[0],$detail_table_arr)){
                $referencefield_column = 'tabdetail_'.$referencefield_column;
            }
            if(in_array($datefield_arr[0],$detail_table_arr)){
                $datefield_column = 'tabdetail_'.$datefield_column;
            }
        }
        //判断对象查询字段、日期查询字段、统计字段中是否包含分录字段
        $withdetailfield = 'no';
        foreach ($field_table_arr as $tmp_table){
            if(in_array($tmp_table,$detail_table_arr)){
                $withdetailfield = 'yes';
            }
        }

        //组合高级查询条件
        $tmp_arr = $this->GetSearchCondition($detailinfo,$yearmonth);
        $tmp_queryobj->addUserSearchConditions($tmp_arr);
        if(!empty($this->advancesearchArr))
            $tmp_queryobj->addUserSearchConditions($this->advancesearchArr);
        //组合查询sql范围
        $wherecondition = " and $referencefield_str in ($record_str) ";
        //查询带分录字段时可以直接获取字段值
        if($withdetailfield == 'yes' || $detailtype == 'no'){
            $list_query = $tmp_queryobj->getQuery('',2);
            $list_query .= $wherecondition;
        }else{
            //有分录且对象查询字段和统计字段未选择分录时,需要使用distince 避免获取重复的单据信息
            $page_list_query = $tmp_queryobj->getQuery('',2);
            $list_query = "select DISTINCT ".$countfield_column.",".$referencefield_column.",".$datefield_column.",crmid from (".$page_list_query.$wherecondition.") as temp";
        }
        //zxm 20231104 首页穿透 近6个月目标完成情况  我只要$list_query
        $this->list_query_detail = $tmp_queryobj->getQuery('',1).$wherecondition;
        //根据计算方法调用不同的函数
        $prefix = '';
        if($funname == 'count'){
            $fun = "COUNT";
        }else if($funname == 'unicount'){
            $fun = "COUNT";
            $prefix = "DISTINCT";
        }else{
            $fun = "sum";
        }
        $fun_sql = "select ".$fun."(".$prefix." ".$countfield_column.") as tmp_value,".$referencefield_column." as tmp_record,DATE_FORMAT($datefield_column,'%Y-%c') as tmp_date from (".$list_query.") as tmpdata group by tmp_record,tmp_date";
        return $fun_sql;
    }
    //zxm 20231104 首页穿透 近6个月目标完成情况  我只要$list_query
    public function getlist_page_query(){
        return $this->list_query_detail;
    }
    //获取数字显示类型
    public function getShowValue($value,$demical,$datatype,$mode,$targetid=''){
        $cymbol = '¥';
        if($datatype == 'num'){
            if($mode == 'Tree'){
                //wym 240409 XUQIU20240305-01 目标管理，增加设置“指标单位”和“换算率”（张华）
                $conversion_value=$this->getConversionValue($value,$targetid);
                $showvalue = number_format($conversion_value, $demical, '.', '');
            }else{
                $showvalue = $value;
            }
        }else{
            if($mode == 'edit') {
                $showvalue = number_format($value, $demical, '.', '');
            }else if($mode == 'Tree'){
                //wym 240409 XUQIU20240305-01 目标管理，增加设置“指标单位”和“换算率”（张华）
                $conversion_value=$this->getConversionValue($value,$targetid);
                $showvalue = number_format($conversion_value, $demical, '.', '');
            }else{
                $value = number_format($value,$demical,'.',',');
                $showvalue = $cymbol.$value;
            }
        }
        return $showvalue;
    }
    //获取树状图中，上下目标显示高度和颜色
    public function getTargetHegiht($percent){
        if($percent > 100){
            $tolookheight = '20px';
            $completeheight = '40px';
            $colorpercent = 'red';
        }else if($percent<100){
            $tolookheight = '40px';
            $completeheight = '20px';
            $colorpercent = 'green';
        }else{
            $tolookheight = '30px';
            $completeheight = '30px';
            $colorpercent = 'blue';
        }
        return ['tolook'=>$tolookheight,'complete'=>$completeheight,'color'=>$colorpercent];
    }
    //获取查询sql对象
    public function get_query_obj($entitytype){
        $current_user = $this->user;
        $module = $entitytype;
        crm_load_class_file('cls_SalesGoal_CustomView','modules/SalesGoal/cls_SalesGoal');
        crm_load_class_file('cls_SalesGoal_Productdetail','modules/SalesGoal/cls_SalesGoal');
        $customview = new cls_SalesGoal_CustomView($module);
        if(get_file_address($module,"ProductDetails"))
        {
            $productDetails = new cls_SalesGoal_Productdetail($module);
            crm_load_class_file("cls_SalesGoal_ProductQueryGenerator",'modules/SalesGoal/cls_SalesGoal');
            $queryobj = new cls_SalesGoal_ProductQueryGenerator($module, $current_user,$customview,$productDetails);
        }
        else if(get_file_address($module,$module.'DetailFieldsHtml'))
        {
            crm_load_class_file('cls_SalesGoal_TabDetails','modules/SalesGoal/cls_SalesGoal');
            $productDetails = new cls_SalesGoal_TabDetails($module);
            crm_load_class_file("cls_SalesGoal_TabDetailQueryGenerator",'modules/SalesGoal/cls_SalesGoal');
            $queryobj = new cls_SalesGoal_TabDetailQueryGenerator($module, $current_user,$customview,$productDetails);
        }else if($module == 'Accounts' || $module == 'ServiceCharge'){
            $productDetails = new cls_SalesGoal_Productdetail($module);
            crm_load_class_file("cls_SalesGoal_AccountsQueryGenerator",'modules/SalesGoal/cls_SalesGoal');
            $queryobj = new cls_SalesGoal_AccountsQueryGenerator($module, $current_user,$customview,$productDetails);
        }
        else if($module == 'Vendors'){
            $productDetails = new cls_SalesGoal_Productdetail($module);
            crm_load_class_file("cls_SalesGoal_VendorsQueryGenerator",'modules/SalesGoal/cls_SalesGoal');
            $queryobj = new cls_SalesGoal_VendorsQueryGenerator($module, $current_user,$customview,$productDetails);
        }
        else{
            crm_load_class_file('cls_SalesGoal_QueryGenerator','modules/SalesGoal/cls_SalesGoal');
            $queryobj = new cls_SalesGoal_QueryGenerator($module, $current_user,$customview);
        }
        return $queryobj;
    }


    //获取列表显示高级查询条件
    public function getListViewCondition($detailinfo,$searchdate,$record_str,$record_info,$modulename){
        $entitytype = $detailinfo['entitytype']; //指标模块
        $referencefield = $detailinfo['referencefield']; //对象查询字段
        $funname = $detailinfo['funname']; //计算方法
        $countfield = $detailinfo['countfield']; //统计字段
        $datefield = $detailinfo['datefield']; //日期查询字段
        $approvedemand = $detailinfo['approvedemand']; //审批要求
        $othercondition = $detailinfo['othercondition']; //其他条件
        //转化成高级查询的字段格式
        $focus = CRMEntity::getInstance($entitytype);
        $new_referencefield = $this->TransferColumn($focus,$referencefield);
        $new_countfield = $this->TransferColumn($focus,$countfield);
        $new_datefield = $this->TransferColumn($focus,$datefield);
        //为空表示字段未启用,对象查询字段、统计字段、日期查询字段，有一个不启用时，得到的数据不准确，则返回空
        if(empty($new_referencefield) || empty($new_countfield) || empty($new_datefield)){
            return [];
        }

        $tmp_arr = [];
        $tmp_arr['searchtype']='advance';
        //其他条件
        if(!empty($othercondition)){
            $advft_arr = ldcrm_json_decode($othercondition);
            $tmp_arr['advft_criteria'] = $advft_arr['advft_criteria'];
            $tmp_arr['advft_criteria_groups'] = $advft_arr['advft_criteria_groups'];
        }else{
            $tmp_arr['advft_criteria'] = '';
            $tmp_arr['advft_criteria_groups'] = '';
        }
        foreach ($tmp_arr['advft_criteria'] as &$tmp_advft_arr){
            $column = $tmp_advft_arr['columnname'];
            $tmp_advft_arr['columnname'] = $this->TransferColumn($focus,$column);
        }

        $max_groupid = 0;
        if(!empty($tmp_arr['advft_criteria'])){
            foreach($tmp_arr['advft_criteria'] as $tmp_info){
                $tmp_groupid = $tmp_info['groupid'];
                if($tmp_groupid > $max_groupid){
                    $max_groupid = $tmp_groupid;
                }
            }
            $new_groupid = $max_groupid+1;
        }else{
            $tmp_arr['advft_criteria'] = [];
            $tmp_arr['advft_criteria_groups'] = [];
            $new_groupid = $max_groupid+1;
        }
        //准备高级查询条件
        $tmp_advft_criteria = [];
        $tmp_advft_criteria['groupid'] = $new_groupid;
        $tmp_advft_criteria['columncondition'] = 'and';
        //设置审批高级查询条件
        if($approvedemand == 1){
            $sys_approve = getSys_Approvedeploy($entitytype);
            $tmp_column = 'approvestatus';
            if($sys_approve['deploy_value'] == 0 && isset($focus->column_fields[$tmp_column])){
                $approve_column = $focus->table_name.':'.$tmp_column.':'.$tmp_column.':'.$entitytype.'_fieldlabel:V';
                $new_approve_column = $this->TransferColumn($focus,$approve_column);
                $tmp_advft_criteria['groupid'] = $new_groupid;
                $tmp_advft_criteria['columnname'] = $new_approve_column;
                $tmp_advft_criteria['comparator'] = 'e';
                //edit:duan date:2024/11/16 reason:将审批状态更改为翻译字段，并增加颜色显示
                $value = constant('D_A_S_APPROVED');
                $translate_dbvalues= getTranslateDbValueNew($entitytype,$tmp_column);
                if(!empty($translate_dbvalues[$value]) && !empty($translate_dbvalues[$value]['labelbol'])){
                    $value=getFixedLabel($translate_dbvalues[$value]['labelbol']);
                }
                $tmp_advft_criteria['value'] = $value;

                $tmp_arr['advft_criteria'][] = $tmp_advft_criteria;
            }
        }
        //日期范围条件
        $tmp_advft_criteria['columnname'] = $new_datefield;
        $tmp_advft_criteria['comparator'] = 'bw';
        $tmp_advft_criteria['value'] = $searchdate;
        $tmp_arr['advft_criteria'][] = $tmp_advft_criteria;
        //统计字段不为空条件
        $tmp_advft_criteria['columnname'] = $new_countfield;
        $tmp_advft_criteria['comparator'] = 'isnotnull';
        $tmp_advft_criteria['value'] = '';
        $tmp_advft_criteria['columncondition'] = '';
        $tmp_arr['advft_criteria'][] = $tmp_advft_criteria;

        if($new_groupid == 1){
            $tmp_arr['advft_criteria_groups'] = array('',array('groupcondition'=>''));
        }else{
            $tmp_arr['advft_criteria_groups'][$max_groupid]['groupcondition'] = 'and';
            $tmp_arr['advft_criteria_groups'][$new_groupid] = array('groupcondition'=>'');
        }
        //增加单据范围条件
        $next_groupid = $new_groupid+1;
        $record_arr = explode(',',$record_str);
        $length = count($record_arr);
        $tmp_advft_criteria = [];
        $tmp_advft_criteria['groupid'] = $next_groupid;
        $tmp_advft_criteria['columncondition'] = 'or';
        $iskehu001 = isKehu001ServerPc();
        for ($i=0;$i<$length;$i++){
            $tmp_record = $record_arr[$i];
            if($modulename == 'Users' && $iskehu001 == 'yes'){
                $tmp_name = getUserRealName($tmp_record);
            }else{
                $tmp_name = $record_info[$tmp_record];
            }

            $tmp_advft_criteria['columnname'] = $new_referencefield;
            $tmp_advft_criteria['comparator'] = 'e';
            $tmp_advft_criteria['value'] = $tmp_name;
            if($i == $length -1){
                $tmp_advft_criteria['columncondition'] = '';
            }
            $tmp_arr['advft_criteria'][] = $tmp_advft_criteria;
        }
        $tmp_arr['advft_criteria_groups'][$new_groupid]['groupcondition'] = 'and';
        $tmp_arr['advft_criteria_groups'][$next_groupid] = array('groupcondition'=>'');

        $tmp_arr['advft_criteria'] = ldcrm_json_encode($tmp_arr['advft_criteria']);
        $tmp_arr['advft_criteria_groups'] = ldcrm_json_encode($tmp_arr['advft_criteria_groups']);
        return $tmp_arr;
    }
    //将字段转化成高级条件中的字段格式
    public function TransferColumn($focus,$column){
        $column_arr = explode(':',$column);
        $table_name = $focus->table_name;
        $scf_table_name = $focus->customFieldTable[0];
        $main_table_arr = [$table_name,$scf_table_name];
        if(in_array($column_arr[0],$main_table_arr)){
            $tmp_module = $focus->module_name;
            $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$column_arr[1]);
        }else if(!empty($focus->detailfieldobj)){
            $fieldinfo = $focus->detailfieldobj->getFieldInfoobjBykey('columnname',$column_arr[1]);
            if(get_file_address($focus->module_name,"ProductDetails")){
                $tmp_module = 'products';
            }
        }
        $newcolmn = '';
        if(!empty($fieldinfo)){
            $column_arr[3] = $tmp_module .'_'.$fieldinfo->getfieldLabel();
            $newcolmn = implode(':',$column_arr);
        }
        return $newcolmn;
    }
    //获取权限判断结果
    public function getAllPermitArr(){
        $action_arr = ['EditView','Delete','DetailView','Create','Allocate','Share'];
        $module = 'SalesGoal';
        $PermitArr = [];
        foreach ($action_arr as $tmp_action){
            $PermitArr[$tmp_action] = isPermitted($module,$tmp_action);
        }
        return $PermitArr;
    }
    //根据查看范围筛选用户
    function getScopeUserName($type,$userid,$userarr)
    {
        global $current_user;
        //BUG0065561 duan 刘总要求:数据范围默认选全部时,不显示离职成员
        if($type == 'All'){
			//XUQIU20240415-03 目标管理，增加“显示离职成员”参数（杨雅媚）wsh 20240918
            if ($this->all_salesgoal_info[$this->targetid]['displayinactiv'] == 'yes') {
                $active_user_arr = get_user_array(FALSE, "", '');
            } else {
                $active_user_arr = get_user_array(FALSE, "Active", $current_user->id);
            }
        }

        if($type == 'senior'){
            $userid = explode(',',$userarr);
            foreach($userid as $key=>$val)
            {
                $user[$val] = getOwnerName($val);
            }
        }
        else
        {
            foreach($userarr as $key=>$val)
            {
                if($type == 'All' && array_key_exists($key,$active_user_arr))
                {
                    $user[$key] = getOwnerName($key);
                }
                else
                {
                    if($userid == $key)
                        $user[$key] = getOwnerName($key);
                }
            }
            if($type == 'All' || $userid == $current_user->id)
                $user[$current_user->id] = getOwnerName($current_user->id);
        }
        return $user;
    }
    //edit: xll 2023/08/14 XUQIU1001400 根据指标名称获取指标中英文翻译
    public static function getFixedLabel_SalesGoal_Byname($targetname){
        global $languageType,$adb;
        $sql = 'select zhlabel,enlabel from ld_salestarget_basic where targetname = ?';
        $result = $adb->pquery($sql,array($targetname));
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
            $zhlabel = $adb->query_result($result,0,'zhlabel');
            $enlabel = $adb->query_result($result,0,'enlabel');
        }
        $label = ($languageType == 'zh') ? $zhlabel : $enlabel;
        return $label;
    }
    public function set_cur_module($cur_module) {
        $this->cur_module = $cur_module;
    }

    public static function getSalesGoalListViewNavbar(){
        $Navbarlist = [
            array(
                'value'=>0,
                'label'=>getFixedLabel('TREEDIAGRAM')
            ),
            array(
                'value'=>3,
                'label'=>getFixedLabel('TEMPLATESALESGOALIMG')
            ),
            array(
                'value'=>1,
                'label'=>getFixedLabel('OBJECTVIEW_LOOK')
            ),
            array(
                'value'=>2,
                'label'=>getFixedLabel('OBJECTVIEW_EDIT')
            ),
        ];
        //没有详情权限
        if(isPermitted('SalesGoal','DetailView','') == 'yes'){
            
        }else{
            unset($Navbarlist[2]);
        }
        return $Navbarlist;
    }

    //通过targetid返回指标单位中/英文标签
    public function getIndicatorUnitLabel($targetid){
        global $current_user;
        $salesgoalinfo = $this->getSalesGolaInfoByid($targetid);
        //如果这里修改，目标管理界面显示时的数组也要修改（变量名相同 可以直接搜索）
        $unitlabel_arr= $this->unitlabel_arr;
        $indicator_unit = $salesgoalinfo['indicator_unit'];
        $indicator_unit_labelarr=$unitlabel_arr[$indicator_unit];
        $languagetype = getLanguageType($current_user);
        if($languagetype=='zh'){
            $indicator_unit_label = $indicator_unit_labelarr["zh_label"];
        }else{
            $indicator_unit_label = $indicator_unit_labelarr["en_label"];
        }
        return $indicator_unit_label;
    }

    //通过targetid返回转换后的值
    public function getConversionValue($value,$targetid){
        $salesgoalinfo = $this->getSalesGolaInfoByid($targetid);
        $conversion_rate=$salesgoalinfo['conversion_rate'];
        if(!$conversion_rate){
            $conversion_rate=1;
        }
        $conversion_value = $value*$conversion_rate;
        return $conversion_value;
    }

    public function filterTargetRes($recordInfo, &$target) {
        foreach ($target as $targetModule => &$info) {
            foreach ($info as $record => $monthInfo) {
                if(!isset($recordInfo[$record]))
                    unset($info[$record]);
            }
        }
    }

    public $selectUserIds;
    public function setSelectUserIds($userIds)
    {
        $this->selectUserIds = $userIds;
    }

    /**
     * @var string 首页组件中，单位是否需要
     */
    public $unitExist = 'no';
    public function setUnitExist($unitExist) {
        $this->unitExist = $unitExist;
    }
    public function getUnitExist() {
        return $this->unitExist;
    }
    public function getTargetid()
    {
        return $this->targetid;
    }
    public function setTargetid($targetid)
    {
        $this->targetid = $targetid;
    }
}
?>