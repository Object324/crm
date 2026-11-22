<?php
//zkt 20231010 XUQIU1001341 SQL注入
//$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
//$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb, $current_user, $currentModule,$mod_strings;
require_once('Smarty_setup.php');
$smarty=new lingdangCRM_Smarty;
$user_id = $current_user->id;
$smarty->assign("CURRENT_USER_ID",$user_id);

$user_array=Array();
require('user_privileges/user_privileges_'.$current_user->id.'.php');
require('user_privileges/user_language_'.$current_user->id.'.php');
require_once('modules/Potentials/Potentials.php');
$SearchScope = "";
 /**
  * edit:can
  * date:20131031
  * reason:外网报表没有显示boss数据
  * */
 /**
 *@andy
 *@date 20140526
 *@reason 综合报表增加查询时间和查询范围功能
 *@verson 5.3
 */
 //获取用户数组$_REQUEST['formodule']
$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
$UserArr = $MergeSmowner['UserCombo'];
unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
unset($MergeSmowner['OtherInfo']["SmOwner_Search_Create"]);//去除当前用户
unset($MergeSmowner['OtherInfo']["SmOwer_Search_ShareMe"]);//去除当前用户
unset($MergeSmowner['OtherInfo']["SmOwer_Search_MeToShare"]);//去除当前用户
if(isset($_REQUEST['formodule'])&&$_REQUEST['formodule']!="" && !isset($_REQUEST['Report_form_query']) && $_REQUEST['Report_form_query']=="") 
{
    $scope= 'SmOwner_Search_All';
}else{
    $scope = $_REQUEST['SmOwnerSearchScope'];
}
if(empty($_REQUEST['selectuserid']) && strtolower($scope) == 'smowner_search_senior'){
	$scope= 'SmOwner_Search_All';
}
$scopeobj = new ScopOfAuthority($adb,'Comprehensivereport');
$UserAllModuleScope = $scopeobj->getUserAllModuleScope();
$query = " and 1=1 ";
if($scope){
switch($scope)
    {
        case 'SmOwner_Search_All':
			if($UserAllModuleScope['Comprehensivereport']['scopeauthority'] != 1){
				$Smownerids= getCurSmOwnerSearchScope('Potentials');
				$SearchScope="";
				foreach($Smownerids['UserCombo']as $userid=>$userinfo)
				{
					 if($SearchScope == "")
					{
						$SearchScope .=$userid; 
					}
					else
					{
						$SearchScope .=",".$userid; 
					}	
					
				}
				$query .= " and  %s.smownerid in ( ".$SearchScope.")";
			}
        break;
        case 'SmOwner_Search_Me':
           $query .=" and %s.smownerid=".$current_user->id;
           $user_id=0;
        break;
        case 'SmOwner_Search_Create':
            $query .=" and %s.smcreatorid=".$current_user->id;
            $user_id=0;
        break;
        case 'smowner_search_senior':
            $query .=" and %s.smownerid in ( ".$_REQUEST['selectuserid'].")";
            $user_id=0;
            break;
        default:
          $query .= " and %s.smownerid=".$scope;
          $user_id=0;
    }
}

//获取年份月份
if(isset($_REQUEST['year']) && isset($_REQUEST['month']))
{
    $year = $_REQUEST['year'];
    $month = $_REQUEST['month'];
    //判断为年度表
    if($month == "0")
    {
        $begin_month = "1";
        $end_month = "12";
    }
    else
    {
        $begin_month = $month;
        $end_month = $month;
    }
    
        //判断2月是否是闰年
       if ($_REQUEST['year']%4==0 && ($_REQUEST['year']%100!=0 || $_REQUEST['year']%400==0))
       {
        //是闰年
        $monthday = "1";
       }
       else
       {
        //不是闰年
        $monthday = "2";
       }
       $smarty->assign("monthday",$monthday);
}

//查询时间段赋值
/**
*@author:andy
*@data:20141009
*@reason:查询报表查询时间段样式更改,日历插件更换
*@version:|
*/
if($_REQUEST['Report_form_query'] == 'true')
{
    $begin_date_request = isset($_REQUEST['begin_date'])?$_REQUEST['begin_date']:'';
    $begin_end_date_arr=explode(' ',$begin_date_request);
    $begin_date=trim($begin_end_date_arr[0]);
    $begin_dates=explode('-',$begin_date_request);
    $begin_month=$begin_dates[1];
    $end_date=trim($begin_end_date_arr[2]);
    $end_date_request = isset($_REQUEST['end_date'])?$_REQUEST['end_date']:'';
    $end_dates=explode('-',$end_date_request);
    $end_month=$end_dates[1];
}
else
{   
    $begin_date = "";
    $begin_date = "".$year."-".formatMonth($begin_month)."-01";  
    $end_date = "";
    $lastday=getthemonth($year."-".$end_month.'-1');
    $arrlastday=explode('-',$lastday);
    $lastday=$arrlastday[2];
    $end_date = "".$year."-".formatMonth($end_month)."-".$lastday;
}
$smarty->assign("begin_date",$begin_date);
$smarty->assign("end_date",$end_date);
$begin_end_date='';
$begin_end_date.=$begin_date.' '.'-'.' '.$end_date;
$smarty->assign("begin_end_date",$begin_end_date);
$smarty->assign("selectuserid",$_REQUEST['selectuserid']);
$smarty->assign("SmOwnerSearchScope",$_REQUEST['SmOwnerSearchScope']);
//查询时间段样式更改end



//获取表名字
if(isset($_REQUEST['name']) && $_REQUEST['name'] != '')
{
    $name = $_REQUEST['name'];
}
//print_r($name);

//print_r($end_date);

$sql = "";
$focus = CRMEntity::getInstance('CashBill');
$checkoutstatuswhere = $focus->get_CashBillCheckoutstatusWhere();
//单据分录明细金额字段和单据头货币字段
$sysdeploy_351 = getSys_deploy(351);
$sysdeploy_value_351 = 2;
if(is_numeric($sysdeploy_351['deploy_value'])){
    $sysdeploy_value_351 = $sysdeploy_351['deploy_value'];    
}
//客户回款明细表
if($name == 'account_cashbill')
{
   
   $sql="SELECT 
        ld_account.accountname, 
        ld_account.accountid,
        ifnull(ld_salesorder.total, 0.00)+ifnull(ld_servicecontracts.total, 0.00) AS salesordertotal, 
        ifnull(ld_cashbill.total, 0.00) AS cashbilltotal, 
        ifnull(ld_invoice.total, 0.00) AS invoicetotal 
        FROM 
        ld_account 
        LEFT JOIN ( 
        SELECT 
        accountid, 
        sum(IF (
                			ld_salesorder.currency_id > 1,
                			IFNULL(ld_salesorder.total, 0) / ld_salesorder.conversion_rate,
                			IFNULL(ld_salesorder.total, 0)
                		)) AS total 
        FROM 
        ld_salesorder 
        WHERE 
        deleted = 0 
        AND signed_data BETWEEN '".$begin_date."' 
        AND '".$end_date."' 
        GROUP BY 
        accountid 
        ) AS ld_salesorder ON ld_salesorder.accountid = ld_account.accountid 
        LEFT JOIN ( 
        SELECT 
        accountid, 
        sum(IF (
                			ld_servicecontracts.currency_id > 1,
                			IFNULL(ld_servicecontracts.total, 0) / ld_servicecontracts.conversion_rate,
                			IFNULL(ld_servicecontracts.total, 0)
                		)) AS total
        FROM 
        ld_servicecontracts 
        WHERE 
        deleted = 0 
        AND due_date BETWEEN '".$begin_date."' 
        AND '".$end_date."' 
        GROUP BY 
        accountid 
        ) AS ld_servicecontracts ON ld_servicecontracts.accountid = ld_account.accountid 
        LEFT JOIN ( 
        SELECT 
        accountid, 
        sum(IF (
                			ld_cashbill.currency_id > 1,
                			IFNULL(ld_cashbill.total, 0) / ld_cashbill.conversion_rate,
                			IFNULL(ld_cashbill.total, 0)
                		)) AS Total 
        FROM 
        ld_cashbill 
        WHERE 
        deleted = 0 $checkoutstatuswhere
        AND cashbilldate BETWEEN '".$begin_date."' 
        AND '".$end_date."' 
        GROUP BY 
        accountid 
        ) AS ld_cashbill ON ld_cashbill.accountid = ld_account.accountid 
        LEFT JOIN ( 
        SELECT 
        accountid, 
        sum(IF (
                			ld_invoice.currency_id > 1,
                			IFNULL(ld_invoice.total, 0) / ld_invoice.conversion_rate,
                			IFNULL(ld_invoice.total, 0)
                		)) AS Total 
        FROM 
        ld_invoice 
        WHERE 
        deleted = 0 
        AND invoicedate BETWEEN '".$begin_date."' 
        AND '".$end_date."' 
        GROUP BY 
        accountid 
        ) AS ld_invoice ON ld_invoice.accountid = ld_account.accountid 
        WHERE  
         ( 
        ifnull(ld_salesorder.total, 0.00) <> 0 
        OR ifnull(ld_cashbill.total, 0.00) <> 0 
        OR ifnull(ld_invoice.total, 0.00) <> 0 
        ) ".sprintf($query,'ld_account')." ";

    //echo $sql;
    $result = $adb->pquery($sql,array());
    $num_rows=$adb->num_rows($result);
    $arr_account_cashbill = array();
    $arr_num = array();
    $salesorderall = "";
    $invoiceall = "";
    $cashbillall = ""; 
    if($num_rows)
    {
        for($i=0;$i<$num_rows;$i++)
        {
            $arr_account_cashbill[]=array(
            'accountname'=> $adb->query_result($result,$i,'accountname'),
            'accountid'=> $adb->query_result($result,$i,'accountid'),
            'invoicetotal'=> '¥'.number_format($adb->query_result($result,$i,'invoicetotal'),$sysdeploy_value_351),
            'salesordertotal'=> '¥'.number_format($adb->query_result($result,$i,'salesordertotal'),$sysdeploy_value_351),
            'cashbilltotal'=> '¥'.number_format($adb->query_result($result,$i,'cashbilltotal'),$sysdeploy_value_351)
            );   
            //序号
            $num = $i+1;
             array_push($arr_account_cashbill[$i],$num);
            //小计
            $salesorderall += $adb->query_result($result,$i,'salesordertotal');
            $cashbillall += $adb->query_result($result,$i,'cashbilltotal');
            $invoiceall += $adb->query_result($result,$i,'invoicetotal');
            /**
            更新操作
            edit：cdw
            date：20131127
            reason：	0005705: 客户回款明细表：若客户的订单金额、发票金额、收款金额若全部为0（空），则不显示
            **/
           if($arr_account_cashbill[$i][invoicetotal]=="" && $arr_account_cashbill[$i][salesordertotal]=="" && $arr_account_cashbill[$i][cashbilltotal]=="")
           {
                unset($arr_account_cashbill[$i]);
           }
           elseif($arr_account_cashbill[$i][invoicetotal]=='¥0.00' && $arr_account_cashbill[$i][salesordertotal]=="" && $arr_account_cashbill[$i][cashbilltotal]=="")
           {
                unset($arr_account_cashbill[$i]);
           }
           elseif($arr_account_cashbill[$i][invoicetotal]=="" && $arr_account_cashbill[$i][salesordertotal]=='¥0.00' && $arr_account_cashbill[$i][cashbilltotal]=="")
           {
                unset($arr_account_cashbill[$i]);
           }
           elseif($arr_account_cashbill[$i][invoicetotal]=="" && $arr_account_cashbill[$i][salesordertotal]=="" && $arr_account_cashbill[$i][cashbilltotal]=='¥0.00')
           {
                unset($arr_account_cashbill[$i]);
           }
           elseif($arr_account_cashbill[$i][invoicetotal]=='¥0.00' && $arr_account_cashbill[$i][salesordertotal]=='¥0.00' && $arr_account_cashbill[$i][cashbilltotal]=="")
           {
                unset($arr_account_cashbill[$i]);
           }
           elseif($arr_account_cashbill[$i]['invoicetotal']=='¥0.00' && $arr_account_cashbill[$i][salesordertotal]=="" && $arr_account_cashbill[$i][cashbilltotal]=='¥0.00')
           {
                unset($arr_account_cashbill[$i]);
           } 
           elseif($arr_account_cashbill[$i]['invoicetotal']=="" && $arr_account_cashbill[$i][salesordertotal]=='¥0.00' && $arr_account_cashbill[$i][cashbilltotal]=='¥0.00')
           {
                unset($arr_account_cashbill[$i]);
           }
           elseif($arr_account_cashbill[$i]['invoicetotal']=='¥0.00' && $arr_account_cashbill[$i][salesordertotal]=='¥0.00' && $arr_account_cashbill[$i][cashbilltotal]=='¥0.00')
           {
                unset($arr_account_cashbill[$i]);
           }
           //end
        }
            $salesorderall = '¥' . number_format($salesorderall,$sysdeploy_value_351);
            $cashbillall = '¥' . number_format($cashbillall,$sysdeploy_value_351);
            $invoiceall = '¥' . number_format($invoiceall,$sysdeploy_value_351);
    }
    
}
//print_r($salesorderall);
//print_r($arr_account_cashbill);
//小计赋值
if($languageType == 'en'){
        $asgtotal="Total";
    }
    else{
        $asgtotal="小计";
    }
//人员回款明细
if($name == 'user_cashbill')
{
   
    /**
     *@andy
     *@date 20140526
     *@reason 综合报表增加查询时间和查询范围功能
     *@verson 5.3
    */
    //print_r($_REQUEST);
    
    $sqls="SELECT
			ld_cashbill.cashbillid,
			ld_cashbill.cashbill_no,
			ld_cashbill.cashbilldate,
			ld_cashbill.total,
			ld_cashbill.currency_id AS cashbill_curid,
			ld_cashbill.conversion_rate AS cashbill_rate,
			ld_cashbill.currency_symbol AS cashbill_symbol,
			ld_account.accountname,
			ld_account.accountid,
			ifnull(
				ld_cashbill.NoPaymentplan,
				0
			) AS tt,
			'' paymentplan_no,
			0 amount,
			1 paymentplan_curid,
			1 paymentplan_rate,
			'¥' paymentplan_symbol,
			0 acturelamount,
			'' salesorder_no,
			'' `subject`,
			0 salesordersubtotal,
			1 salesorder_curid,
			1 salesorder_rate,
			'¥' salesorder_symbol,
			ld_users.last_name,ld_users.wx_userid,
			ld_users.id,
			0 entitytypeid
		FROM
			ld_cashbill
		INNER JOIN ld_users ON ld_users.id = ld_cashbill.smownerid
		INNER JOIN ld_account ON ld_account.accountid = ld_cashbill.accountid
    where ld_cashbill.deleted = 0 ".sprintf($query,'ld_cashbill')."  $checkoutstatuswhere
        and ld_cashbill.cashbilldate between '".$begin_date."' and '".$end_date."' 
    ORDER BY
    	last_name,
    	cashbilldate,
        cashbillid,
    	paymentplan_no;";
    //print_r($SearchScope);
    //echo $sqls;
    $result = $adb->pquery($sqls,array());
    $num_rows=$adb->num_rows($result);
    //echo $num_rows;
    $arr_users_cashbill = array();
    $user=array();
    $data=array();     
    if($num_rows)
    {
        for($i=0;$i<$num_rows;$i++)
        {            
            $username=$adb->query_result($result,$i,'last_name');
            $wx_userid=$adb->query_result($result,$i,'wx_userid');
            $userObj=new Users();
            $userObj->wx_userid=$wx_userid;
            $userObj->last_name=$username;
            $username=getUserlastName($userObj);
            $id=$adb->query_result($result,$i,'id');
            if(empty($user)){
                $user[$id]=$username;             
            }
          if(!empty($user) && !array_key_exists($id,$user)){
            $data[]=array(
            'cashbilldate'=>$asgtotal,
            'subtotal'=>'¥'.number_format($sumsubtotal,2),
            'accountname'=>'',
            'subject'=>'',
            'salesorder_no'=>'',
            'salesordersubtotal'=>'¥'.number_format($sumsalesordersubtotal,2),
            'paymentplan_no'=>'',
            'NoPaymentplan'=>number_format($sumsubtt,2),
            'amount'=>'¥'.number_format($sumsubamount,2),//回款计划额度
            'acturelamount'=>number_format($sumsubacturelamount,2),
            'cashbill_no'=>''
            );
                $userdata=array($user,$data,count($data));              
                $arr_users_cashbill[]=$userdata;                
                $user=array();
                $data=array();
                $sumsubtotal=0;
                $sumsubtt=0;  
                $sumsubamount=0;
                $sumsubacturelamount=0;              
                $sumsalesordersubtotal=0;
                $user[$id]=$username;
            }
            
            //$subtotal= $adb->query_result($result,$i,'subtotal');//收款额
            $subtotal= $adb->query_result($result,$i,'total');//收款额
            $subtt= $adb->query_result($result,$i,'tt');
            $subamount= $adb->query_result($result,$i,'amount');  
            $subacturelamount= $adb->query_result($result,$i,'acturelamount');   
           
            //$salesordersubtotal= $adb->query_result($result,$i,'salesordersubtotal');//订单金额
            $salesordersubtotal= $adb->query_result($result,$i,'salesordersubtotal');//订单金额
            $cashbill_curid = $adb->query_result($result,$i,'cashbill_curid');//币种ID
            $cashbill_rate = $adb->query_result($result,$i,'cashbill_rate');//币种汇率
            $cashbill_symbol = $adb->query_result($result,$i,'cashbill_symbol');//收款单货币符号
            $paymentplan_symbol = $adb->query_result($result,$i,'paymentplan_symbol');//回款计划货币符号
            $paymentplan_curid = $adb->query_result($result,$i,'paymentplan_curid');
            $paymentplan_rate = $adb->query_result($result,$i,'paymentplan_rate');
            $salesorder_symbol = $adb->query_result($result,$i,'salesorder_symbol');//合同订单货币符号
            $salesorder_curid = $adb->query_result($result,$i,'salesorder_curid');
            $salesorder_rate = $adb->query_result($result,$i,'salesorder_rate');
            //没有回款计划时
            if(empty($paymentplan_symbol))
                $paymentplan_symbol = $cashbill_symbol;
            
            $data[]=array(
            'accountname'=> $adb->query_result($result,$i,'accountname'),
            'accountid'=> $adb->query_result($result,$i,'accountid'),
            'subject'=> $adb->query_result($result,$i,'subject'),
            'subtotal'=>$cashbill_symbol . number_format($subtotal,2),
            'cashbilldate'=> $adb->query_result($result,$i,'cashbilldate'),
            'salesorder_no'=> $adb->query_result($result,$i,'salesorder_no'),
            'salesordersubtotal'=>$salesorder_symbol . number_format($salesordersubtotal,2),
            'paymentplan_no'=>$adb->query_result($result,$i,'paymentplan_no'),
            'NoPaymentplan'=>number_format($adb->query_result($result,$i,'tt'),2),
            'amount'=>$paymentplan_symbol . number_format($subamount,2),
            'acturelamount'=>number_format($adb->query_result($result,$i,'acturelamount'),2),
            'cashbill_no'=>$adb->query_result($result,$i,'cashbill_no'),
            'cashbillid'=>$adb->query_result($result,$i,'cashbillid'),
            );
            //print_r($data);
            //小计

            //$sumsalesordersubtotal +=$salesordersubtotal;
            if($cashbill_curid > 1)
                $subtotal = $subtotal/$cashbill_rate;
            if($paymentplan_curid > 1)
                $subamount = $subamount/$paymentplan_rate;
            if($salesorder_curid > 1)
                $salesordersubtotal = $salesordersubtotal/$salesorder_rate;
            if($adb->query_result($result,$i,'cashbillid')!==$adb->query_result($result,$i-1,'cashbillid')){
               $sumsubtotal +=$subtotal; 
            }
            if($adb->query_result($result,$i,'salesorder_no')!==$adb->query_result($result,$i-1,'salesorder_no')){
               $sumsalesordersubtotal +=$salesordersubtotal;
            }
            $sumsubtt +=$subtt;
            $sumsubamount +=$subamount;
            $sumsubacturelamount +=$subacturelamount;
            
                                
            if($i==$num_rows-1){
                $data[]=array(
                'cashbilldate'=>$asgtotal,
                'subtotal'=>'¥'.number_format($sumsubtotal,2),
                'accountname'=>'',
                'subject'=>'',
                'salesorder_no'=>'',
                'salesordersubtotal'=>'¥'.number_format($sumsalesordersubtotal,2),
                'paymentplan_no'=>'',
                'NoPaymentplan'=>number_format($sumsubtt,2),
                'amount'=>'¥'.number_format($sumsubamount,2),//回款计划额度
                'acturelamount'=>number_format($sumsubacturelamount,2),
                'cashbill_no'=>'',
                'cashbillid'=>''
                );
                $userdata=array($user,$data,count($data));
                $arr_users_cashbill[]=$userdata;
            }
            
            //合计
            if($adb->query_result($result,$i,'cashbillid')!==$adb->query_result($result,$i-1,'cashbillid')){
            $sumsubtotal_all += $subtotal;
            //echo $adb->query_result($result,$i,'cashbill_no')."-".$adb->query_result($result,$i-1,'cashbill_no')."-".$sumsubtotal;echo "<br>";
            }
            if($adb->query_result($result,$i,'salesorder_no')!==$adb->query_result($result,$i-1,'salesorder_no')){
               $sumsalesordersubtotal_all += $salesordersubtotal;
            }
            $sumsubtt_all += $subtt;
            $sumsubamount_all += $subamount;
            $sumsubacturelamount_all += $subacturelamount;
            
           
        } 
        $sumsubtotal_all='¥'.number_format($sumsubtotal_all,2);
        $sumsubtt_all=number_format($sumsubtt_all,2);
        $sumsubamount_all='¥'.number_format($sumsubamount_all,2);//回款计划额度
        $sumsubacturelamount_all=number_format($sumsubacturelamount_all,2);
        $sumsalesordersubtotal_all='¥'.number_format($sumsalesordersubtotal_all,2);
      
        
        $g=0;
        foreach($arr_users_cashbill as $key=>$arr)
        {
            for($i=0;$i<count($arr_users_cashbill[$key][1]);$i++){
            if($arr_users_cashbill[$key][1][$i]['cashbillid'] == $arr_users_cashbill[$key][1][$i-1]['cashbillid'])
               {
                 $g++;
                 $arr_users_cashbill[$key][1][$i]['rowspan']=$g+1;
                 $arr_users_cashbill[$key][1][$i-1]['rowspan']=0;
               }else{
                $g=0;
                $arr_users_cashbill[$key][1][$i]['rowspan']='####error';
               }
            }
            
            $acount = count($arr_users_cashbill[$key][1]);
            for($c=0;$c<$acount;$c++){
                for($j=0;$j<$acount-$c-1;$j++){
                    if($arr_users_cashbill[$key][1][$j]['cashbill_no']==$arr_users_cashbill[$key][1][$j+1]['cashbill_no']){
                        if($arr_users_cashbill[$key][1][$j]['rowspan']<$arr_users_cashbill[$key][1][$j+1]['rowspan']){
                            $temp = $arr_users_cashbill[$key][1][$j];
                            $arr_users_cashbill[$key][1][$j] = $arr_users_cashbill[$key][1][$j+1];
                            $arr_users_cashbill[$key][1][$j+1] = $temp;
                        }
                    }
                } 
            }
        }  
            

            
    }

}

//人员签单明细表
if($name == 'user_salesorder')
{
    $sql .= "select * from ( select ld_salesorder.smownerid, ld_users.last_name,ld_users.wx_userid, ld_account.accountid,";
    $sql .= " ld_salesorder.subject,ld_salesorder.salesorder_no,ld_account.accountname, ";
    $sql .= " date_format(ld_salesorder.signed_data,'%Y-%m-%d') as createdtime, ";
    $sql .= " round(ld_salesorder.total,$sysdeploy_value_351) as salesordertotal, ";
    $sql .= " ld_salesorder.currency_symbol as salesorder_symbol,ld_salesorder.conversion_rate as salesorder_rate,ld_salesorder.currency_id as salesorder_curid,";
    $sql .= " round(ifnull(ld_salesorder.received_amount,0),$sysdeploy_value_351) as subtotal, ";
    $sql .= " ld_salesorder.receivable_balance as notget,
    round(ifnull(invoice.total,0),2) as invoicetotal,expense.expensetotal,round(IFNULL(commission2payment.amount,0),$sysdeploy_value_351) as commissiontotal ";
    $sql .= " from ld_salesorder ";
    $sql .= " inner join ld_users ";
    $sql .= " on ld_salesorder.smownerid = ld_users.id ";
    $sql .= " inner join ld_account ";
    $sql .= " on ld_account.accountid = ld_salesorder.accountid ";
   
    
    $sql .= " left join ( select sum( if(ld_invoice.currency_id > 1,round( ld_invoice.total,$sysdeploy_value_351 )/ld_invoice.conversion_rate,round( ld_invoice.total,$sysdeploy_value_351 )) ) as total,entitytypeid 
            from ld_invoice 
            left JOIN (SELECT * FROM ld_invoicedetail GROUP BY id ) as ld_inventoryproductrel on ld_invoice.invoiceid=ld_inventoryproductrel.id 
            GROUP BY entitytypeid ) as invoice ";
    $sql .= " on ld_salesorder.salesorderid= invoice.entitytypeid ";
    $sql .= " left join ( ";
    $sql .= " select sum(IF (ld_expense.currency_id > 1,ld_expensedetailscf.rmb_total / ld_expense.conversion_rate,ld_expensedetailscf.rmb_total)) as expensetotal,ld_expensedetail.entitytypeid from  ld_expensedetail 
    left join ld_expensedetailscf on ld_expensedetailscf.expensedetailid=ld_expensedetail.expensedetailid
    LEFT JOIN ld_expense ON ld_expensedetail.expenseid=ld_expense.expenseid
    
    left join ld_salesorder on ld_salesorder.salesorderid = ld_expensedetail.entitytypeid where ld_expense.approvestatus = '".constant('D_A_S_APPROVED')."' group by ld_expensedetail.entitytypeid) as expense";            
    $sql .= " on ld_salesorder.salesorderid = expense.entitytypeid";
    //佣金金额    
    $sql .= " LEFT JOIN(SELECT SUM(if(ld_commission.currency_id > 1,amount/ld_commission.conversion_rate,amount)) as amount,entitytypeid FROM ld_commission2payment left join ld_commission on ld_commission.commission_id = ld_commission2payment.commission_id group by entitytypeid) as commission2payment
        on commission2payment.entitytypeid = ld_salesorder.salesorderid";    
    $sql .= " where ld_salesorder.deleted = 0 and ld_salesorder.sostatus <>'已作废' and ld_salesorder.signed_data between '".$begin_date."' and '".$end_date."' ".sprintf($query,'ld_salesorder')." ";
    $sql .= " group by ld_salesorder.salesorder_no";
    $sql .="
    UNION ALL
    SELECT
	ld_servicecontracts.smownerid,
	ld_users.last_name,ld_users.wx_userid,
	ld_account.accountid,
	ld_servicecontracts.subject,
	ld_servicecontracts.contract_no as salesorder_no,
	ld_account.accountname,
	date_format(
		ld_servicecontracts.due_date,
		'%Y-%m-%d'
	) AS createdtime,
	round(ld_servicecontracts.total, $sysdeploy_value_351) AS salesordertotal,
	ld_servicecontracts.currency_symbol AS salesorder_symbol,
	ld_servicecontracts.conversion_rate AS salesorder_rate,
	ld_servicecontracts.currency_id AS salesorder_curid,
	round(
		ifnull(cashbill.subtotal, 0),
		$sysdeploy_value_351
	) AS subtotal,
	round(

		IF (
			ld_servicecontracts.currency_id > 1,
			ld_servicecontracts.total / ld_servicecontracts.conversion_rate,
			ld_servicecontracts.total
		) - ifnull(cashbill.subtotal, 0),
		$sysdeploy_value_351
	) AS notget,
	round(ifnull(invoice.total, 0), 2) AS invoicetotal,
	expense.expensetotal,
	round(
		IFNULL(
			commission2payment.amount,
			0
		),
		2
	) AS commissiontotal
FROM
	ld_servicecontracts
INNER JOIN ld_users ON ld_servicecontracts.smownerid = ld_users.id
INNER JOIN ld_account ON ld_account.accountid = ld_servicecontracts.accountid
LEFT JOIN (
	SELECT
		ld_cashbill2paymentplan.CashBillID,
		CASE ld_paymentplan.salesorderid
	       WHEN '0' THEN  ld_paymentplan.entitytypeid
		ELSE ld_cashbill2paymentplan.entitytypeid
		  END AS entitytypeid,
		sum(

			IF (
				ld_cashbill.currency_id > 1,
				ld_cashbill2paymentplan.amount / ld_cashbill.conversion_rate,
				ld_cashbill2paymentplan.amount
			)
		) AS subtotal
	FROM
		ld_cashbill2paymentplan
    LEFT JOIN ld_paymentplan on ld_paymentplan.paymentplanid=ld_cashbill2paymentplan.entitytypeid
	INNER JOIN ld_cashbill ON ld_cashbill2paymentplan.CashBillID = ld_cashbill.cashbillid
	AND ld_cashbill.deleted = 0 $checkoutstatuswhere
	GROUP BY
		ld_cashbill2paymentplan.entitytypeid
) AS cashbill ON ld_servicecontracts.servicecontractsid = cashbill.entitytypeid
LEFT JOIN (
	SELECT
		sum(

			IF (
				ld_invoice.currency_id > 1,
				round(ld_invoice.total, $sysdeploy_value_351) / ld_invoice.conversion_rate,
				round(ld_invoice.total, $sysdeploy_value_351)
			)
		) AS total,
		entitytypeid
	FROM
		ld_invoice
	LEFT JOIN (
		SELECT
			*
		FROM
			ld_invoicedetail
		GROUP BY
			id
	) AS ld_inventoryproductrel ON ld_invoice.invoiceid = ld_inventoryproductrel.id
	GROUP BY
		entitytypeid
) AS invoice ON ld_servicecontracts.servicecontractsid = invoice.entitytypeid
LEFT JOIN (
	SELECT
sum(IF (ld_expense.currency_id > 1,ld_expensedetailscf.rmb_total / ld_expense.conversion_rate,ld_expensedetailscf.rmb_total)) AS expensetotal,
		ld_expensedetail.entitytypeid
	FROM
		ld_expensedetail
    left join ld_expensedetailscf on ld_expensedetailscf.expensedetailid=ld_expensedetail.expensedetailid
    LEFT JOIN ld_expense ON ld_expensedetail.expenseid=ld_expense.expenseid    
	LEFT JOIN ld_servicecontracts ON ld_servicecontracts.servicecontractsid = ld_expensedetail.entitytypeid
	WHERE
		ld_expense.approvestatus = '".constant('D_A_S_APPROVED')."'
	GROUP BY
		ld_expensedetail.entitytypeid
) AS expense ON ld_servicecontracts.servicecontractsid = expense.entitytypeid
LEFT JOIN (
	SELECT
		SUM(

			IF (
				ld_commission.currency_id > 1,
				amount / ld_commission.conversion_rate,
				amount
			)
		) AS amount,
		entitytypeid
	FROM
		ld_commission2payment
	LEFT JOIN ld_commission ON ld_commission.commission_id = ld_commission2payment.commission_id
	GROUP BY
		entitytypeid
) AS commission2payment ON commission2payment.entitytypeid = ld_servicecontracts.servicecontractsid
WHERE
	ld_servicecontracts.deleted = 0
AND ld_servicecontracts.contract_status <> '已作废'
AND ld_servicecontracts.due_date BETWEEN '".$begin_date."' and '".$end_date."' ".sprintf($query,'ld_servicecontracts')." 
GROUP BY
	ld_servicecontracts.contract_no
) as F1 
    ORDER BY
	F1.smownerid,
	F1.createdtime
    ";
//    echo $sql;die;
    $result = $adb->pquery($sql,array());
    $num_rows=$adb->num_rows($result);
    $arr_users_salesorder = array();
    $user=array();
    $data=array();
    $sumsalesorderall=0;
    $sumsuball=0;
    $sumnotgetall=0;
    $suminvoiceall=0;
    $sumexpenseall=0;
    $sumecommissionall=0;
    $sumcashbillgrossall=0;
    if($num_rows)
    {
        for($i=0;$i<$num_rows;$i++)
        {
            $username=$adb->query_result($result,$i,'last_name');
            $wx_userid=$adb->query_result($result,$i,'wx_userid');
            $userObj=new Users();
            $userObj->wx_userid=$wx_userid;
            $userObj->last_name=$username;
            $username=getUserlastName($userObj);
            $id=$adb->query_result($result,$i,'smownerid');
            
            if(empty($user)){
                $user[$id]=$username;             
            }
            $salesordertotal=$adb->query_result($result,$i,'salesordertotal')??0;
            $subtotal=$adb->query_result($result,$i,'subtotal')??0;
            $notget=$adb->query_result($result,$i,'notget')??0;
            $invoicetotal=$adb->query_result($result,$i,'invoicetotal')??0;
            $expensetotal=$adb->query_result($result,$i,'expensetotal')??0;
            $commissiontotal = $adb->query_result($result,$i,'commissiontotal')??0;
            $salesorder_symbol = $adb->query_result($result,$i,'salesorder_symbol');
            $salesorder_curid = $adb->query_result($result,$i,'salesorder_curid')??0;
            $salesorder_rate = $adb->query_result($result,$i,'salesorder_rate')??0;
            if($salesorder_curid > 1 && $salesorder_rate != 0){
                $sumsub = $sumsub/$salesorder_rate;
            }else{
                $sumsub = 0;
            }
            if(!empty($user) && !array_key_exists($id,$user)){
                $data[]=array(
                'subject'=>$asgtotal,
                'salesorder_no'=>'',
                'accountname'=>'',
                'createdtime'=>'',
                'salesordertotal'=>$salesorder_symbol.number_format($sumsalesorder,$sysdeploy_value_351),
                'subtotal'=>$salesorder_symbol.number_format($sumsub,$sysdeploy_value_351),
                'notget'=>$salesorder_symbol.number_format($sumnotget,$sysdeploy_value_351),
                'invoicetotal'=>'¥'.number_format($suminvoice,$sysdeploy_value_351),
                'expensetotal'=>'¥'.number_format($sumexpense,$sysdeploy_value_351),
                'commissiontotal'=>'¥'.number_format($sumecommission,$sysdeploy_value_351),
                'cashbillgrosstotal'=>'¥'.number_format($sumsub-$sumexpense-$sumecommission,$sysdeploy_value_351)
                );
                $userdata=array($user,$data,count($data));              
                $arr_users_salesorder[]=$userdata;                
                $user=array();
                $data=array();
                $sumsalesorder=0;
                $sumsub=0;
                $sumnotget=0;
                $suminvoice=0;
                $sumexpense=0;
                $sumecommission=0;
                $user[$id]=$username;
            }
            $subtotal_exchange = $subtotal;
            if($salesorder_curid > 1) {
                $subtotal_exchange = $subtotal / $salesorder_rate;
            }
            if (!is_numeric($notget)) { //wym BUG20240129-40 人员签单明细表底部合计数据显示“nan”（数据库存值为空）
                $notget = 0;
            }
            $data[]=array(
            'subject'=>$adb->query_result($result,$i,'subject'),
            'salesorder_no'=>$adb->query_result($result,$i,'salesorder_no'),
            'accountname'=>$adb->query_result($result,$i,'accountname'),
            'accountid'=>$adb->query_result($result,$i,'accountid'), 
            'createdtime'=>$adb->query_result($result,$i,'createdtime'),
            'salesordertotal'=>$salesorder_symbol . number_format($salesordertotal,$sysdeploy_value_351),
            'subtotal'=>$salesorder_symbol .number_format($subtotal,$sysdeploy_value_351),
            'notget'=>$salesorder_symbol .number_format($notget,$sysdeploy_value_351),
            'invoicetotal'=>'¥'.number_format($invoicetotal,$sysdeploy_value_351),
            'expensetotal'=>'¥'.number_format($expensetotal,$sysdeploy_value_351),
            'commissiontotal'=>'¥'.number_format($commissiontotal,$sysdeploy_value_351)  ,
            'cashbillgrosstotal'  =>'¥'.   number_format($subtotal_exchange-$expensetotal-$commissiontotal,$sysdeploy_value_351)
            );
            //小计
            //echo gettype($subtotal);
            // 转换为人民币 后在累加
            if($salesorder_curid > 1){
                $salesordertotal = $salesordertotal/$salesorder_rate;
                $subtotal = $subtotal/$salesorder_rate;
                $notget = $notget/$salesorder_rate;
            }

            $sumsalesorder +=$salesordertotal;
            $sumsub +=$subtotal;
            $sumnotget +=$notget;
            $suminvoice +=$invoicetotal;
            $sumexpense +=$expensetotal;
            $sumecommission +=$commissiontotal;
            if($i==$num_rows-1){
                 $data[]=array(
                    'subject'=>$asgtotal,
                    'salesorder_no'=>'',
                    'accountname'=>'',
                    'createdtime'=>'',
                    'salesordertotal'=>'¥'.number_format($sumsalesorder,$sysdeploy_value_351),
                    'subtotal'=>'¥'.number_format($sumsub,$sysdeploy_value_351),
                    'notget'=>'¥'.number_format($sumnotget,$sysdeploy_value_351),
                    'invoicetotal'=>'¥'.number_format($suminvoice,$sysdeploy_value_351),
                    'expensetotal'=>'¥'.number_format($sumexpense,$sysdeploy_value_351),
                    'commissiontotal'=>'¥'.number_format($sumecommission,$sysdeploy_value_351),
                    'cashbillgrosstotal'  =>'¥'.number_format($sumsub-$sumexpense-$sumecommission,$sysdeploy_value_351)
                    );
                $userdata=array($user,$data,count($data));
                $arr_users_salesorder[]=$userdata;
            }
            
            //合计
            $sumsalesorderall +=$salesordertotal;
            $sumsuball +=$subtotal;
            $sumnotgetall +=$notget;
            $suminvoiceall +=$invoicetotal;
            $sumexpenseall +=$expensetotal;
            $sumecommissionall +=$commissiontotal;    
            $sumcashbillgrossall+=  $subtotal  -$expensetotal -$commissiontotal;          
        }
    }
            $sumsalesorderall ='¥'.number_format($sumsalesorderall,2);
            $sumsuball ='¥'.number_format($sumsuball,2);
            $sumnotgetall ='¥'.number_format($sumnotgetall,2);
            $suminvoiceall ='¥'.number_format($suminvoiceall,2);
            $sumexpenseall ='¥'.number_format($sumexpenseall,2);
            $sumecommissionall ='¥'.number_format($sumecommissionall,2);      
            $sumcashbillgrossall ='¥'.number_format($sumcashbillgrossall,2);      
}
//交付毛利汇总表
if($name == 'costprice_salesorder')
{
    
            $sql="SELECT 
                 F1.productname,
            	sum(
                    round(
                		if(currency_id>1,
                            
                    		  tax_amount/conversion_rate,
                    		  tax_amount
                    		
                        ),$sysdeploy_value_351)
            	) AS subtotal,
            	sum(
            		F1.quantity
            	) AS quantity,
            	sum(
            		round(
            			F1.quantity * (
            				CASE
            				WHEN ifnull(F1.productcost,0) = 0 THEN
            					  ifnull(F1.costprice,0)
            				ELSE
            					ifnull(F1.productcost,0)
            				END
            			) + 0.000001,
            			2
            		)
            	) AS sumcostprice
            FROM (
            	SELECT
                                ld_products.productcode,
            					ld_products.productname,
            					 tax_amount,
            					
            						ld_servicecontractsdetail.quantity,
           							ld_servicecontracts.currency_id,
            						ld_servicecontracts.conversion_rate,
            							ld_servicecontractsdetail.productcost ,
            						ld_products.costprice
            FROM
            	ld_servicecontracts
            INNER JOIN ld_servicecontractsdetail ON ld_servicecontracts.servicecontractsid = ld_servicecontractsdetail.id
            INNER JOIN ld_products ON ld_servicecontractsdetail.productid = ld_products.productid
            WHERE
            	ld_servicecontracts.deleted = 0
            ".sprintf($query,'ld_servicecontracts')." 
            AND ld_servicecontracts.due_date between '$begin_date' and '$end_date' 
            AND ld_servicecontracts.contract_status <> '已作废'
            UNION ALL
            	SELECT
                                ld_products.productcode,
                        		ld_products.productname,
                        		tax_amount,
            						
            						ld_salesorderdetail.quantity,
            							ld_salesorder.currency_id,
            							ld_salesorder.conversion_rate,
            							ld_salesorderdetail.productcost ,
            						ld_products.costprice
            	FROM
            		ld_salesorder
            	INNER JOIN ld_salesorderdetail ON ld_salesorder.salesorderid = ld_salesorderdetail.id
            	INNER JOIN ld_products ON ld_salesorderdetail.productid = ld_products.productid
            	WHERE
            		ld_salesorder.deleted = 0
                ".sprintf($query,'ld_salesorder')." 
            	AND ld_salesorder.signed_data between '$begin_date' and '$end_date' 
            	AND ld_salesorder.sostatus <> '已作废') as F1
            	GROUP BY
            	F1.productname
            	ORDER BY
            	F1.productcode";
    
    $result = $adb->pquery($sql,array());
    $num_rows = $adb->num_rows($result);
    $quantityall = 0;
    $subtotalall = 0;
    $grossprofitall = 0;
    $arr_costprice_salesorder = array();
    if($num_rows)
    {
		//单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
		if(isset($sysdeploy['deploy_value']))
			$lengthdecimaldigits = $sysdeploy['deploy_value'];
		else
			$lengthdecimaldigits  = 2;
       
        for($i=0;$i<$num_rows;$i++)
        {
            $subtotal=$adb->query_result($result,$i,'subtotal');
             $grossprofit=$subtotal-$adb->query_result($result,$i,'sumcostprice');
           
            $grossprofitrate=$grossprofit/$subtotal*100;
          
            if($subtotal==0)
            {
                $grossprofitrate=0;
            }
            $arr_costprice_salesorder[]=array(
            'productname'=> $adb->query_result($result,$i,'productname'),
			'quantity' => setNumberFormat($adb->query_result($result,$i,'quantity'),$lengthdecimaldigits),
            'subtotal'=> '¥'.number_format($subtotal,$sysdeploy_value_351),
            'grossprofit'=> '¥'.number_format($grossprofit,2),
            'grossprofitrate'=> setNumberFormat($grossprofitrate,2),
            ); 
          
            //序号
            $num = $i+1;
            array_push($arr_costprice_salesorder[$i],$num);
            //合计
            $quantityall += $adb->query_result($result,$i,'quantity');
            $subtotalall += $adb->query_result($result,$i,'subtotal');
            $grossprofitall += $grossprofit;
        }
            //$quantityall = number_format($quantityall,2);
			$quantityall = setNumberFormat($quantityall,$lengthdecimaldigits);
            $subtotalall = '¥'.number_format($subtotalall,$sysdeploy_value_351);
           $grossprofitall = '¥'.number_format($grossprofitall,2);
    }

}
//交付毛利明细表
if($name == 'grossprofitdetial')
{
    $sql .= "SELECT * from (select "; 
    $sql .= " ld_salesorder.signed_data as duedate,ld_products.productid, ";
    $sql .=" ld_salesorderdetail.discount_percent, ";
    $sql .=" ld_salesorderdetail.discount_amount, ";
    $sql .=" ld_salesorderdetail.id as recordid, ";
    
    $sql .= " ld_products.productname, ";
    $sql .= " ld_salesorder.salesorder_no, ";
    $sql .= " ld_salesorder.subject, ld_salesorder.currency_id,ld_salesorder.conversion_rate,ld_salesorder.currency_symbol,";
    $sql .= " ld_account.accountname, ";
    $sql .= " ld_account.accountid,";
    $sql .= " ld_salesorderdetail.quantity, ";
    $sql .= " round(tax_amount,2) as tax_amount, ";
    
    $sql .= " round(ld_salesorderdetail.quantity*
                            (case when ifnull(ld_salesorderdetail.productcost,0)=0 
                            then if(ld_salesorder.currency_id>1 , ifnull(ld_products.costprice,0)*ld_salesorder.conversion_rate,ifnull(ld_products.costprice,0)) else ld_salesorderdetail.productcost end),2) 
                            as sumcostprice ";
  
    $sql .= " from ld_products "; 
    $sql .= " inner join ld_salesorderdetail  ";
    $sql .= " on ld_products.productid = ld_salesorderdetail.productid "; 
    $sql .= " inner join ld_salesorder ";
    $sql .= " on ld_salesorder.salesorderid = ld_salesorderdetail.id ";
    $sql .= " inner join ld_account "; 
    $sql .= " on ld_account.accountid = ld_salesorder.accountid "; 
    $sql .= " where ld_salesorder.deleted = 0 and ld_salesorder.sostatus <> '已作废' 
    ".sprintf($query,'ld_salesorder')." and ld_salesorder.signed_data between '".$begin_date."' and '".$end_date."'";
    $sql .= "UNION ALL
                SELECT
            	ld_servicecontracts.due_date AS duedate,
            	ld_products.productid,
            	ld_servicecontractsdetail.discount_percent,
            	ld_servicecontractsdetail.discount_amount,
            	ld_servicecontractsdetail.id AS recordid,
            	ld_products.productname,
            	ld_servicecontracts.contract_no,
            	ld_servicecontracts.subject,
            	ld_servicecontracts.currency_id,
            	ld_servicecontracts.conversion_rate,
            	ld_servicecontracts.currency_symbol,
            	ld_account.accountname,
                ld_account.accountid,
            	ld_servicecontractsdetail.quantity,
            	round(
            		tax_amount,
            		2
            	) AS tax_amount,
                
            	round(
            		ld_servicecontractsdetail.quantity * (
            			CASE
            			WHEN ifnull(ld_servicecontractsdetail.productcost,0)= 0 THEN
            			   if(ld_servicecontracts.currency_id>1, 	ifnull(ld_products.costprice,0) *ld_servicecontracts.conversion_rate,ifnull(ld_products.costprice,0))
            			ELSE
            				ifnull(ld_servicecontractsdetail.productcost,0)
            			END
            		),
            		2
            	) AS grossprofit
            FROM
            	ld_products
            INNER JOIN ld_servicecontractsdetail ON ld_products.productid = ld_servicecontractsdetail.productid
            INNER JOIN ld_servicecontracts ON ld_servicecontracts.servicecontractsid = ld_servicecontractsdetail.id
            INNER JOIN ld_account ON ld_account.accountid = ld_servicecontracts.accountid
            WHERE
            	ld_servicecontracts.deleted = 0
            AND ld_servicecontracts.contract_status <> '已作废'".sprintf($query,'ld_servicecontracts')."
            AND ld_servicecontracts.due_date BETWEEN  '".$begin_date."' and '".$end_date."'
            ) as F1
            ORDER BY
            	F1.duedate,
            	F1. SUBJECT,
            	F1.productname
    ";
  
    $result = $adb->pquery($sql,array());
    $num_rows = $adb->num_rows($result);
    $arr_grossprofitdetial = array();
    
    $quantitydetialall = "";
    $listpricedetialall = "";
    $grossprofitdetialall = "";
    
   if($num_rows)
    {
	    //单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
		if(isset($sysdeploy['deploy_value']))
			$lengthdecimaldigits = $sysdeploy['deploy_value'];
		else
			$lengthdecimaldigits  = 2;
        for($i=0;$i<$num_rows;$i++)
        {
            $currency_id = $adb->query_result($result,$i,'currency_id');
            $conversion_rate = $adb->query_result($result,$i,'conversion_rate');
            $currency_symbol = $adb->query_result($result,$i,'currency_symbol');
            $grossprofit=$adb->query_result($result,$i,'tax_amount')-$adb->query_result($result,$i,'sumcostprice');
            
            $grossprofitrate=$grossprofit/$adb->query_result($result,$i,'tax_amount')*100;
            if($adb->query_result($result,$i,'tax_amount')==0)
            {
                $grossprofitrate='0';
                
            }
            $arr_grossprofitdetial[]=array(
                'productname'=> $adb->query_result($result,$i,'productname'),
                'duedate'=> $adb->query_result($result,$i,'duedate'),
                'subject'=> $adb->query_result($result,$i,'subject'),
                'salesorder_no'=> $adb->query_result($result,$i,'salesorder_no'),
                'accountname'=> $adb->query_result($result,$i,'accountname'),
                'accountid'=> $adb->query_result($result,$i,'accountid'),
                //'quantity'=> number_format($adb->query_result($result,$i,'quantity'),2),
    			'quantity' => setNumberFormat($adb->query_result($result,$i,'quantity'),$lengthdecimaldigits),
                //'listprice'=> $adb->query_result($result,$i,'listprice'),
                'grossprofit'=>$currency_symbol.number_format($grossprofit,2),
                'subtotal'=> number_format($adb->query_result($result,$i,'subtotal'),$sysdeploy_value_351),    
                'listprice'=>$currency_symbol.number_format($adb->query_result($result,$i,'tax_amount'),$sysdeploy_value_351),
                'grossprofitrate'=> number_format($grossprofitrate,2)
            );
            
            //序号
            $num = $i+1;
            array_push($arr_grossprofitdetial[$i],$num);
            //合计
            $tax_amount = $adb->query_result($result,$i,'tax_amount');
            if($currency_id > 1)
            {
                $grossprofit=$grossprofit/$conversion_rate;
                $tax_amount = $tax_amount / $conversion_rate;
            }
                
            $quantitydetialall += $adb->query_result($result,$i,'quantity');
            $listpricedetialall += $tax_amount;
            
            $grossprofitdetialall += $grossprofit;
        }
        $listpricedetialall='¥'.number_format($listpricedetialall,$sysdeploy_value_351);
        $grossprofitdetialall='¥'.number_format($grossprofitdetialall,2);
        $quantitydetialall=setNumberFormat($quantitydetialall,$lengthdecimaldigits);
    }
}

//产品毛利汇总表
if($name == 'product_grossprofit')
{
    $sql .= " select ld_products.productname,ld_products.productid, ";
    $sql .= " ld_account.accountname,ld_account.accountid,ld_salesorder.salesorder_no,ld_salesorder.signed_data as duedate, ";
    $sql .=" ld_salesorderdetail.id as recordid, ";
    $sql .=" ld_salesorder.currency_id,ld_salesorder.conversion_rate,ld_salesorder.currency_symbol, ";

    $sql .= " round(ld_salesorderdetail.quantity,2) as quantity, IFNULL(round(ld_salesorderdetail.listprice,2),0.00) as listprice,";
    $sql .= " round(tax_amount,$sysdeploy_value_351) as subtotal, ";
    $sql .= " round(case when ifnull(ld_salesorderdetail.productcost,0)=0 then 
                        if(ld_salesorder.currency_id>1, ifnull(ld_products.costprice,0)*ld_salesorder.conversion_rate,ifnull(ld_products.costprice,0)) else 
                        ld_salesorderdetail.productcost end,2) as costprice ";
  
    
    $sql .= " from ld_products ";
    $sql .= " inner join  ld_salesorderdetail ";
    $sql .= " on ld_salesorderdetail.productid = ld_products.productid ";
    $sql .= " inner join (
                SELECT salesorderid,accountid,salesorder_no,signed_data,currency_id,ld_salesorder.conversion_rate,currency_symbol,SmOwnerid FROM ld_salesorder 
                WHERE ld_salesorder.deleted = 0 AND ld_salesorder.sostatus <> '已作废'
                UNION ALL
                SELECT servicecontractsid as salesorderid,accountid,contract_no as salesorder_no,due_date as signed_data,currency_id,ld_servicecontracts.conversion_rate,currency_symbol,SmOwnerid  
                FROM ld_servicecontracts 
                WHERE ld_servicecontracts.deleted = 0 AND ld_servicecontracts.contract_status <> '已作废'
                ) as ld_salesorder ";
    $sql .= " on ld_salesorder.salesorderid = ld_salesorderdetail.id ";
    $sql .= " inner join ld_account ";
    $sql .= " on ld_account.accountid = ld_salesorder.accountid ";
    $sql .= " where  ld_salesorder.signed_data between '".$begin_date."' and '".$end_date."' ".sprintf($query,'ld_salesorder')."  order by productname asc,ld_products.productcode desc,ld_account.accountname desc,ld_salesorder.signed_data,ld_salesorder.salesorder_no asc ";
    
    //echo $sql;
    $result = $adb->pquery($sql,array());
    $num_rows=$adb->num_rows($result);
    $arr_product_grossprofit = array();
    
    $product=array();
    $data=array();

    if($num_rows)
    {
		//单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
		if(isset($sysdeploy['deploy_value']))
			$lengthdecimaldigits = $sysdeploy['deploy_value'];
		else
			$lengthdecimaldigits  = 2;
        for($i=0;$i<$num_rows;$i++)
        {
            $productname=$adb->query_result($result,$i,'productname');
            $id=$adb->query_result($result,$i,'productid');
            //print_r($username);
            
            if(empty($product)){
                $product[$id]=$productname;             
            }
            
            if(!empty($product) && !array_key_exists($id,$product)){
                $data[]=array(
                'accountname'=>$asgtotal,
                'subject'=>'',
                'duedate'=>'',
                'listprice'=>'',
                //'quantity'=>number_format($sumquantity,2),
				'quantity'=>setNumberFormat($sumquantity,$lengthdecimaldigits),
                'subtotal'=>'¥'.number_format($sumsubtotal,2),
                'costprice'=>'',
                'grossprofit'=>'¥'.number_format($sumgrossprofit,2),
                'grossprofitrate'=>''
                );
                
                $productdata=array($product,$data,count($data));              
                $arr_product_grossprofit[]=$productdata;
                    
                $sumquantity=0;
                $sumsubtotal=0;
                $sumgrossprofit=0; 
                           
                $product=array();
                $data=array();
                $product[$id]=$productname;
            }
            $quantity=$adb->query_result($result,$i,'quantity');
            $currency_id = $adb->query_result($result,$i,'currency_id');
            $currency_symbol = $adb->query_result($result,$i,'currency_symbol');
            $costprice=$adb->query_result($result,$i,'costprice');
            $conversion_rate = $adb->query_result($result,$i,'conversion_rate');
            $subtotal = $adb->query_result($result,$i,'subtotal');
            $grossprofit=$subtotal-$quantity*$costprice;
            $grossprofitrate=$subtotal==0?0:$grossprofit/$subtotal*100;
            if($subtotal==0)
            {
                $grossprofitrate=0;
            }
            $data[]=array(
            'accountname'=> $adb->query_result($result,$i,'accountname'),
            'accountid'=> $adb->query_result($result,$i,'accountid'),
            'subject'=> $adb->query_result($result,$i,'salesorder_no'),
            'duedate'=> $adb->query_result($result,$i,'duedate'),
            'listprice'=> $currency_symbol.number_format($adb->query_result($result,$i,'listprice'),2),
            //'quantity'=> number_format($quantity,2),
			'quantity'=> setNumberFormat($quantity,$lengthdecimaldigits),
            'subtotal'=> $currency_symbol.number_format($subtotal,$sysdeploy_value_351),
            'costprice'=> number_format($adb->query_result($result,$i,'costprice'),2),
            'grossprofit'=> $currency_symbol.number_format($grossprofit,2),
            'grossprofitrate'=> number_format($grossprofitrate,2)
            );
  
            //小计
            $sumquantity +=$quantity;
            //echo gettype($subtotal);
            if($currency_id > 1)
            {
                $subtotal = $subtotal/$conversion_rate;
                $grossprofit = $grossprofit/$conversion_rate;
            }
            $sumsubtotal +=$subtotal;         
            $sumgrossprofit +=$grossprofit;
            if($i==$num_rows-1){
                $data[]=array(
                'accountname'=>$asgtotal,
                'subject'=>'',
                'duedate'=>'',
                'listprice'=>'',
                //'quantity'=>number_format($sumquantity,2),
				'quantity'=>setNumberFormat($sumquantity,$lengthdecimaldigits),
                'subtotal'=>'¥'.number_format($sumsubtotal,$sysdeploy_value_351),
                'costprice'=>'',
                'grossprofit'=>'¥'.number_format($sumgrossprofit,2),
                'grossprofitrate'=>''
                );
               
                $productdata=array($product,$data,count($data));
                $arr_product_grossprofit[]=$productdata;
            }

            //合计$arr_product_grossprofit
            $sumquantity_all +=$quantity;
            $sumsubtotal_all +=$subtotal;
            $sumgrossprofit_all +=$grossprofit;
        }
            //$sumquantity_all =number_format($sumquantity_all,2);
			$sumquantity_all =setNumberFormat($sumquantity_all,$lengthdecimaldigits);
            $sumsubtotal_all ='¥'.number_format($sumsubtotal_all,$sysdeploy_value_351);
            $sumgrossprofit_all ='¥'.number_format($sumgrossprofit_all,2);
    }
}
//客户毛利明细
if($name == 'account_grossprofit')
{
    $sql .=" select ";
    $sql .=" ld_salesorderdetail.productid, ";
    $sql .=" ld_salesorderdetail.id as recordid, ";
    $sql .="salesorder.currency_id,salesorder.conversion_rate,salesorder.currency_symbol, ";
    $sql .=" ld_account.accountid, ";
    $sql .=" ld_account.accountname, ";
    $sql .=" ld_products.productname, ";
    $sql .=" salesorder.subject, ";
    $sql .=" salesorder.salesorder_no, ";
    $sql .=" salesorder.signed_data as duedate, "; 
    $sql .=" IFNULL(round(ld_salesorderdetail.listprice,2),0.00) as listprice, ";
    $sql .=" ld_salesorderdetail.quantity,round(ld_salesorderdetail.tax_amount,$sysdeploy_value_351) as subtotal, ";
  
    $sql .=" round((ld_salesorderdetail.quantity * (case when ifnull(ld_salesorderdetail.productcost,0)=0 
                    then if(salesorder.currency_id>1,ifnull(ld_products.costprice,0)*salesorder.conversion_rate,
                    ifnull(ld_products.costprice,0))
                     else ld_salesorderdetail.productcost end)),2) as sumcostprice "; 
    
    $sql .=" from ld_account  ";
    $sql .=" inner join(	SELECT
		salesorderid,SUBJECT,
		accountid,deleted,sostatus,
		salesorder_no,
		signed_data,
		currency_id,
		conversion_rate,
		currency_symbol,
		SmOwnerid
	FROM
		ld_salesorder
	WHERE
		ld_salesorder.deleted = 0 ".sprintf($query,'ld_salesorder')."
		UNION ALL
		SELECT
			servicecontractsid AS salesorderid,SUBJECT,
			accountid,deleted,contract_status as sostatus,
			contract_no AS salesorder_no,
			due_date AS signed_data,
		
			currency_id,
			conversion_rate,
			currency_symbol,
			SmOwnerid
		FROM
			ld_servicecontracts where ld_servicecontracts.deleted = 0 ".sprintf($query,'ld_servicecontracts').") as salesorder "; 
    
    $sql .=" on ld_account.accountid = salesorder.accountid "; 
    $sql .=" inner join ld_salesorderdetail "; 
    $sql .=" on salesorder.salesorderid = ld_salesorderdetail.id "; 
    $sql .=" inner join ld_products "; 
    $sql .=" on ld_products.productid = ld_salesorderdetail.productid "; 
    $sql .=" where ld_account.deleted = 0 "; 
    $sql .=" and salesorder.sostatus <> '已作废' "; 

    $sql .=" and salesorder.signed_data between '".$begin_date."' and '".$end_date."' "; 
    $sql .=" order by CONV(HEX(left(CONVERT(ld_account.accountname USING gbk),1)),16,10),ld_products.productcode,salesorder.signed_data,salesorder.salesorder_no ";
   //print_r($sql);

    $result = $adb->pquery($sql,array());
    $num_rows=$adb->num_rows($result);
    $arr_account_grossprofit = array();
    
    $account=array();
    $data=array();
    
    if($num_rows)
    {
		//单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
		if(isset($sysdeploy['deploy_value']))
			$lengthdecimaldigits = $sysdeploy['deploy_value'];
		else
			$lengthdecimaldigits  = 2;
        for($i=0;$i<$num_rows;$i++)
        {
            $accountname=$adb->query_result($result,$i,'accountname');
            $id=$adb->query_result($result,$i,'accountid');
            
            if(empty($account)){
                $account[$id]=$accountname;             
            }
            if(!empty($account) && !array_key_exists($id,$account)){
                $data[]=array( 
                'productname'=>$asgtotal,
                'subject'=>'',
                'salesorder_no'=>'',
                'duedate'=>'',
                'listprice'=>'',
                //'quantity'=>number_format($sumquantity,2),
				'quantity'=>setNumberFormat($sumquantity,$lengthdecimaldigits),
                'subtotal'=>'¥'.number_format($sumsubtotal,$sysdeploy_value_351),
                'grossprofit'=>'¥'.number_format($sumgrossprofit,2),
                'grossprofitrate'=>''
                );
                
                $accountdata=array($account,$data,count($data));              
                $arr_account_grossprofit[]=$accountdata;
                
                $sumquantity=0;
                $sumsubtotal=0;
                $sumgrossprofit=0; 
                
                $account=array();
                $data=array();
                $account[$id]=$accountname;
                
                }
                $quantity=$adb->query_result($result,$i,'quantity');
                $currency_id = $adb->query_result($result,$i,'currency_id');
                $currency_symbol = $adb->query_result($result,$i,'currency_symbol');
                $conversion_rate = $adb->query_result($result,$i,'conversion_rate');
                $subtotal=$adb->query_result($result,$i,'subtotal');
                $grossprofit=($subtotal-$adb->query_result($result,$i,'sumcostprice'));
                
                $data[]=array(
                'productname'=> $adb->query_result($result,$i,'productname'),
                'subject'=> $adb->query_result($result,$i,'subject'),
                'salesorder_no'=> $adb->query_result($result,$i,'salesorder_no'),
                'duedate'=> $adb->query_result($result,$i,'duedate'),
                'listprice'=> $currency_symbol . $adb->query_result($result,$i,'listprice'),
                //'quantity'=> number_format($quantity,2),
				'quantity'=>setNumberFormat($quantity,$lengthdecimaldigits),
                'subtotal'=> $currency_symbol.number_format($subtotal,$sysdeploy_value_351),
                'grossprofit'=> $currency_symbol.number_format($grossprofit,2),
                'grossprofitrate'=> number_format($grossprofit/$subtotal*100,2)
                );
                //小计
                if($currency_id > 1)
                {
                    $subtotal = $subtotal/$conversion_rate;
                    $grossprofit = $grossprofit/$conversion_rate;
                }
                    
                $sumquantity +=$quantity;
                $sumsubtotal +=$subtotal;
                $sumgrossprofit +=$grossprofit;
                
                if($i==$num_rows-1){
                    $data[]=array( 
                    'productname'=>$asgtotal,
                    'subject'=>'',
                    'salesorder_no'=>'',
                    'duedate'=>'',
                    'listprice'=>'',
                    //'quantity'=>$sumquantity,
					'quantity'=>setNumberFormat($sumquantity,$lengthdecimaldigits),
                    'subtotal'=>'¥'.number_format($sumsubtotal,$sysdeploy_value_351),
                    'grossprofit'=>'¥'.number_format($sumgrossprofit,2),
                    'grossprofitrate'=>''
                    );
                    
                    $accountdata=array($account,$data,count($data));
                    $arr_account_grossprofit[]=$accountdata; 
                    }
            //合计
            $sumquantity_account_all +=$quantity;
            $sumsubtotal_account_all +=$subtotal;
            $sumgrossprofit_account_all +=$grossprofit;
        }
			$sumquantity_account_all = setNumberFormat($sumquantity_account_all,$lengthdecimaldigits);
            $sumsubtotal_account_all = '¥'.number_format($sumsubtotal_account_all,2);
            $sumgrossprofit_account_all ='¥'.number_format($sumgrossprofit_account_all,2);
    }                
}

//检测任务完成情况统计表start

if($name == 'SalesOrder_Testingdetial')
{   
    //获取服务单审批流程,获取一条审批信息
    $sqlHelpDeskApprove = "select * from ld_approve where tabid = 13 order by createdtime desc LIMIT 1";
    $resultHelpDesk = $adb->query($sqlHelpDeskApprove);
    if($adb->num_rows($resultHelpDesk))
    {
        $helpDesk_Approve_id=$adb->query_result($resultHelpDesk,0,'id');//审批id
        $helpDesk_Approve_name=$adb->query_result($resultHelpDesk,0,'name');//审批主题
        
        //获取审批步骤信息
        $sqlHelpDeskApproveStep = "select * from ld_approvestep where approveid = ? order by sequence  ";
        $resultHelpDeskStep = $adb->pquery($sqlHelpDeskApproveStep,array($helpDesk_Approve_id));
        
        $arr_HelpDeskApproveStep = array();//
        $HelpDeskStepCount = $adb->num_rows($resultHelpDeskStep);
         
        if($adb->num_rows($resultHelpDeskStep))
        {
            for($i=0;$i<$HelpDeskStepCount;$i++)
            {
                $arr_HelpDeskApproveStep[] =array(
                    'HelpDeskStep'=> $adb->query_result($resultHelpDeskStep,$i,'id'),
                    'HelpDeskStepName'=> $adb->query_result($resultHelpDeskStep,$i ,'name'),
                    'HelpDeskStepAppStatus'=> '',
                    'HelpDeskStepPastStatus'=> ''
                    ); 
            }
        }
    }
    
    //获取合同订单审批流程
    $sqlSalesOrderApprove = "select * from ld_approve where tabid = 22 order by createdtime desc LIMIT 1";
    $resultSalesOrder = $adb->query($sqlSalesOrderApprove);
    if($adb->num_rows($resultSalesOrder))
    {
        $salesOrder_Approve_id=$adb->query_result($resultSalesOrder,0,'id');
        $salesOrder_Approve_name=$adb->query_result($resultSalesOrder,0,'name');
        
        $sqlSalesOrderApproveStep = "select * from ld_approvestep where approveid = ? order by sequence  ";
        $resultSalesOrderStep = $adb->pquery($sqlSalesOrderApproveStep,array($salesOrder_Approve_id));
        
        $arr_SalesOrderApproveStep = array();
        $SalesOrderStepCount = $adb->num_rows($resultSalesOrderStep);
        if($adb->num_rows($resultSalesOrderStep))
        {
            for($i=0;$i<$SalesOrderStepCount;$i++)
            {
                $arr_SalesOrderApproveStep[] =array(
                    'SalesOrderStep'=> $adb->query_result($resultSalesOrderStep,$i,'id'),
                    'SalesOrderStepName'=> $adb->query_result($resultSalesOrderStep,$i ,'name'),
                    'SalesOrderStepAppStatus'=> '',
                    'SalesOrderStepPastStatus'=> ''
                    ); 
            }
        }
    }
    
    $sql_salesorder="select ld_account.accountname,ld_salesorder.`subject`,
                    ld_salesordercf.cf_955,ld_salesorder.salesorderid,
                    ld_salesorder.duedate 
                    from ld_account,ld_salesorder,ld_crmentity, ld_salesordercf 
                    where ld_account.accountid=ld_salesorder.accountid 
                    and 
                    ld_salesordercf.salesorderid=ld_salesorder.salesorderid 
                    and 
                    ld_crmentity.crmid=ld_salesorder.salesorderid 
                    and 
                    ld_crmentity.deleted=0
                    and
                    ld_crmentity.createdtime between '{$begin_date}' and '{$end_date}' ";
    
    $result = $adb->pquery($sql_salesorder,array());
    $num_rows=$adb->num_rows($result);
    $arr_grossprofitdetial = array();
    if($num_rows){
        for($i=0;$i<$num_rows;$i++)
        {   
            $salesorderapp_step_arr = array(); 
            $salesorderapp_step_arr =$arr_SalesOrderApproveStep;
            //合同订单编号
            $salesorderid=$adb->query_result($result,$i,'salesorderid'); 
            
            $sql_salesorderapp="select ld_approvelog.* from ld_salesorder 
                    INNER JOIN ld_approvelog on ld_salesorder.salesorderid = ld_approvelog.crmid
                    where ld_salesorder.salesorderid=$salesorderid "; 
            $result_salesorderapp= $adb->pquery($sql_salesorderapp,array()); 

            //获取审批信息              
            if($adb->num_rows($result_salesorderapp))
            {   
                for($j1 = 0;$j1 < $SalesOrderStepCount ;$j1++)
                {
                    $SalesOrder_stepid = $salesorderapp_step_arr[$j1]['SalesOrderStep'];

                    for($j=0;$j<$adb->num_rows($result_salesorderapp);$j++)
                    {
                        $salesorderapp_stepid=$adb->query_result($result_salesorderapp,$j,'stepid');
                        $salesorderapp_stepid_approveresult=$adb->query_result($result_salesorderapp,$j,'approveresult');
                        if($SalesOrder_stepid==$salesorderapp_stepid)
                        {
                            $salesorderapp_step_arr[$j1]['SalesOrderStepAppStatus'] = 1;
                            $salesorderapp_step_arr[$j1]['SalesOrderStepPastStatus'] = $salesorderapp_stepid_approveresult;
                        }
                    }
                    
                }
            }
            
            $helpdeskapp_step_arr = array();
            $helpdeskapp_step_arr = $arr_HelpDeskApproveStep;
            //***************************************
            //服务单数据,默认取第一条
            $sql_helpdesk="select * from ld_troubletickets where salesorderid='{$salesorderid}' order by ticketid desc LIMIT 1 ";
            $result_helpdesk = $adb->pquery($sql_helpdesk,array());   
            if($adb->num_rows($result_helpdesk))
            {   
                $ticket_no= $adb->query_result($result_helpdesk,0,'ticket_no');
                $title= $adb->query_result($result_helpdesk,0,'title');
                $ticketid= $adb->query_result($result_helpdesk,0,'ticketid');
                //获取审批信息
                $sql_helpdeskapp="select ld_approvelog.* from ld_troubletickets 
                    INNER JOIN ld_approvelog on ld_troubletickets.ticketid = ld_approvelog.crmid
                    where ld_troubletickets.ticketid='{$ticketid}' ";
                $result_helpdeskapp= $adb->query($sql_helpdeskapp);
                
                if($adb->num_rows($result_helpdeskapp))
                {   
                    for($j1 = 0;$j1 < $HelpDeskStepCount ;$j1++)
                    {
                        $helpdesk_stepid = $helpdeskapp_step_arr[$j1]['HelpDeskStep'];
                        for($j=0;$j<$adb->num_rows($result_helpdeskapp);$j++)
                        {
                            $helpdeskapp_stepid=$adb->query_result($result_helpdeskapp,$j,'stepid');
                            $helpdeskapp_stepid_approveresult=$adb->query_result($result_helpdeskapp,$j,'approveresult');
                            if($helpdesk_stepid==$helpdeskapp_stepid)
                            {
                                $helpdeskapp_step_arr[$j1]['HelpDeskStepAppStatus'] = 1;
                                $helpdeskapp_step_arr[$j1]['HelpDeskStepPastStatus'] = $helpdeskapp_stepid_approveresult;                            
                            }
                        }  
                    }
                }
            }
            else
            {
                $ticket_no='';
                $title='';
            }
            
            $arr_grossprofitdetial[] =array(
                'accountname'=> $adb->query_result($result,$i,'accountname'),
                'subject'=> $adb->query_result($result,$i ,'subject'),
                'salesorderid'=> $adb->query_result($result,$i,'salesorderid'),
                'cf_955'=>$adb->query_result($result,$i,'cf_955'),
                'duedate'=> $adb->query_result($result,$i,'duedate'),
                'ticket_no'=> $ticket_no,
                'title'=> $title,
                'helpdeskapp_step_arr'=>$helpdeskapp_step_arr,
                'arr_SalesOrderApproveStep'=>$salesorderapp_step_arr,
                ); 
        }
    }
}
//检测任务完成情况统计表end
$smarty->assign("result",$arr_grossprofitdetial);
$smarty->assign('SALESORDER_ARR',$arr_SalesOrderApproveStep);
$smarty->assign('HELPDESK_ARR',$arr_HelpDeskApproveStep);
//客户毛利汇总表
$smarty->assign("arr_account_grossprofit",$arr_account_grossprofit);
$smarty->assign("sumquantity_account_all",$sumquantity_account_all);
$smarty->assign("sumsubtotal_account_all",$sumsubtotal_account_all);
$smarty->assign("sumgrossprofit_account_all",$sumgrossprofit_account_all);
//print_r($arr_product_grossprofit);
//产品毛利汇总表
$smarty->assign("arr_product_grossprofit",$arr_product_grossprofit);
$smarty->assign("sumquantity_all",$sumquantity_all);
$smarty->assign("sumsubtotal_all",$sumsubtotal_all);
$smarty->assign("sumgrossprofit_all",$sumgrossprofit_all);
//交付毛利明细表
$smarty->assign("arr_grossprofitdetial",$arr_grossprofitdetial);
$smarty->assign("quantitydetialall",$quantitydetialall);
$smarty->assign("listpricedetialall",$listpricedetialall);
$smarty->assign("grossprofitdetialall",$grossprofitdetialall);
//print_r($arr_costprice_salesorder);
//交付毛利汇总表
$smarty->assign("result_costprice_salesorder",$arr_costprice_salesorder);
$smarty->assign("quantityall",$quantityall);
$smarty->assign("subtotalall",$subtotalall);
$smarty->assign("grossprofitall",$grossprofitall);
//人员签单详细表
//print_r($sumnotgetall);
$smarty->assign("result_users_salesorder",$arr_users_salesorder);
$smarty->assign("suminvoiceall",$suminvoiceall);
$smarty->assign("sumnotgetall",$sumnotgetall);
$smarty->assign("sumsuball",$sumsuball);
$smarty->assign("sumsalesorderall",$sumsalesorderall);
$smarty->assign("sumexpenseall",$sumexpenseall);
$smarty->assign("sumcommissionall",$sumecommissionall);
$smarty->assign("sumcashbillgrossall",$sumcashbillgrossall);
//人员回款明细
$smarty->assign("result_users_cashbill", $arr_users_cashbill);
$smarty->assign("sumsubtotal_all",$sumsubtotal_all);
$smarty->assign("sumsubtt_all",$sumsubtt_all);
$smarty->assign("sumsubamount_all",$sumsubamount_all);
$smarty->assign("sumsubacturelamount_all",$sumsubacturelamount_all);
$smarty->assign("sumsalesordersubtotal_all",$sumsalesordersubtotal_all);
//客户回款明细
$smarty->assign("result_account_cashbill", $arr_account_cashbill);
$smarty->assign("salesorderall",$salesorderall);
$smarty->assign("cashbillall",$cashbillall);
$smarty->assign("invoiceall",$invoiceall);
//总体
$smarty->assign("formodule",$_REQUEST['formodule']);
$smarty->assign("begin_month",$begin_month);
$smarty->assign("end_month",$end_month);
$smarty->assign("year",$year);
$smarty->assign("name",$name);
$smarty->assign('Merge_SmOwner',$MergeSmowner);
//20240305 hzx XUQIU20240112-01 查询分类显示优化（仿腾讯云），一行显示4个，点击出现弹出层注：注意区分普通、悬浮、选中状态
if(count($MergeSmowner) > 0 && $currentModule != 'InventoryAccount' && $currentModule != 'InventoryQuery' && $currentModule != 'BankAccountSet' && $currentModule != 'Reminds'){
    $SmOwner_option_arr = [];
    $showviewrange = false;
    foreach($MergeSmowner as $User_Key => $User_value){
        foreach($User_value as $User_id => $User_name){
            foreach($User_name as $User_name_key => $User_name_value){
                $SmOwner_option_arr[] = array('label'=>$User_name_key,'value'=>$User_id);
                if($User_id == 'smowner_search_senior'){
                    $showviewrange = true;
                }
            }
        }
    }
    if($showviewrange == true){
        $smarty->assign('showviewrange',$showviewrange);
    }
}else{
    $SmOwner_option_arr = [];
    $SmOwner_option_arr[] = array('label'=>getFixedLabel('ALL'),'value'=>'SmOwner_Search_All','selected'=>true);
}
$smarty->assign('Merge_SmOwner_arr',json_encode($SmOwner_option_arr));
$smarty->assign('LANUGAGETYPE',$languageType);
$smarty->assign('curmodule',$_REQUEST['module']);
setWxSmarty($smarty);//获取kehu001的信息
$smarty->display('Comprehensivereport/ComprehensivereportDetail.tpl');

function formatMonth($month)
{
    if($month<10){
        $month='0'.$month;
    }
    return $month;
}
function getthemonth($date)
{
$firstday = date('Y-m-01', strtotime($date));
$lastday = date('Y-m-d', strtotime("$firstday +1 month -1 day"));
return $lastday;
}
exit();
?>