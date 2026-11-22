<?php
/*******************************************************
**更新操作
**edit:chj
**date:2013-11-26
**reason:库存台账
*******************************************************/
//require_once('Smarty_setup.php');
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $app_strings,$mod_strings,$theme,$currentModule,$adb,$current_user,$oCustomView;
global $list_max_entries_per_page_new,$is_admin;
$smarty=new lingdangCRM_Smarty;
$oCustomView = new CustomView();
$productdetail = "";
$bankcashmenuid = 0;
$curbalancemoney = 0;
//获取基础币种
$sql='select * from ld_currency_info  where id=?';
//edit:can 20210329 044966: (http://xiaoshou360.com/xs/wythill [^]）（美迪医疗（深圳））现金银行流水账（Finance---Bank Transactions）中金额计算不正确；例如建设银行（本月）支出金额的合计不正确，余额也不正确
$result=$adb->pquery($sql,array(1));
 
//获取基础币种符号
$basic_currency_symbol=$adb->query_result($result,0,'currency_symbol');
$basic_currency_id=$adb->query_result($result,0,'id');
$smarty->assign("basic_currency_symbol",$adb->query_result($result,0,'currency_symbol'));
//chj 2021/5/25 46050: PC端->现金银行流水账，查看某个外币账户的现金银行流水账时，不需要转化为人民币小计
if($_REQUEST['bankcashid'] > 0){
	$query = 'select currency_symbol,currency_id from ld_bankaccountset where Bankaccountsetid = ?';
	$result=$adb->pquery($query,array($_REQUEST['bankcashid']));
	
	if($adb->num_rows($result) >= 1){
		$basic_currency_id=$adb->query_result($result,0,'currency_id');
	   $basic_currency_symbol=$adb->query_result($result,0,'currency_symbol');
		$smarty->assign("basic_currency_symbol",$adb->query_result($result,0,'currency_symbol'));
	}
}
//查询期间下拉框 默认为本月
if(!isset($_REQUEST['stdDateFilter']))
    $selcriteria = 'thismonth';
else
    $selcriteria = $_REQUEST['stdDateFilter'];
//获取本月的日期
if(!isset($_REQUEST['startdate']))
    $firstday = date('Y-m-01',time());
else
    $firstday = $_REQUEST['startdate'];
if(!isset($_REQUEST['enddate']))
    $lastday = date('Y-m-t',time());
else
    $lastday = $_REQUEST['enddate'];
if(!isset($_REQUEST['hiddenledger']))
    $ledger = 1;    //默认为选中
else
    $ledger = $_REQUEST['hiddenledger'];
if(isset($_REQUEST['selectbankcashid']) && $_REQUEST['selectbankcashid'] != '')
    $smarty->assign('MOREBANKID',$_REQUEST['selectbankcashid']);
else
    $smarty->assign('MOREBANKID','');
$stdfilterhtml = $oCustomView->getStdFilterCriteria($selcriteria);
//Liver 2017-04-07 bug0027715: 现金银行流水账：查询期间下拉选项值改进
//查询期间仅显示为：自定义、去年、本年、上季度、本季度、昨天、今天、上周、本周、上月、本月，默认显示为“本月”
$demanddate=array('custom','prevfy','thisfy','prevfq','thisfq','tomorrow','today','lastweek','thisweek','lastmonth','thismonth');
foreach($stdfilterhtml as $key => $value){
    if(!in_array($value['value'],$demanddate)){
        unset($stdfilterhtml[$key]);
    }
}
$smarty->assign("STDFILTERCRITERIA",$stdfilterhtml);
$smarty->assign("SELCRITERIA",$selcriteria);
$DateTime = CommonView::stdFilterDateTimeStr($output_type);
$datetimestr=json_encode($DateTime);//���������json���룬������js����ʹ��
$smarty->assign('datetimestr',$datetimestr);
$stdfilterjs = getCriteriaJS();
$smarty->assign("STDFILTER_JAVASCRIPT",$stdfilterjs);
$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
$UserArr = $MergeSmowner['UserCombo'];
foreach($UserArr as $key => $val)
{
    $userid[] = $key;
}
//公司账户
$is_admin=is_admin($current_user);

if($is_admin == true)
    $userfile = '';
else
    $userfile = " and (ld_bankaccountprofile.userid = '".$current_user->id."' or ld_bankaccountprofile.userid=-1)";
$query="select ld_bankaccountset.bankaccountsetid,ld_bankaccountset.accountname from ld_bankaccountset inner join ld_bankaccountprofile 
on ld_bankaccountset.bankaccountsetid = ld_bankaccountprofile.bankaccountsetid where ld_bankaccountset.discontinued = 1 $userfile and ld_bankaccountset.confirmed = 1 group by bankaccountsetid order by bankaccountsetid asc";
$result=$adb->pquery($query,array());
$num_rows=$adb->num_rows($result);

if($num_rows <= 0)
{
    echo "<div id='warningTable' class='warningTable'>";
    echo "<div class='warningTableContent'>
            <div class='wtc_img'><img src='themes/images/icon-prohibit.png'></div>
            <div class='wtc_title'>".getFixedLabel('REMINDER')."</div>
            <div class='wtc_content'>".getFixedLabel('INSUFFICIENTPRIVILEGES')."</div>
            <div class='wtc_btn'><input value=".getFixedLabel('RETURN')." title=".getFixedLabel('RETURN')." class='createauto' onclick=window.location.href='index.php?module=Home&action=index&parenttab=' type='button'></div>
                </div>";
    echo "</div>";
    echo "<script type='text/javascript' language='JavaScript'>
            var a = ld('.Header').outerHeight(),//头部高度
                c_height = 0,
                s_height = ld(window).height();
            if(a==null) a=0;
            c_height = s_height-a;
            ld('#warningTable').css('height',c_height);
            ld('.warningTableContent').css('margin-top',-a/2);
          </script>";
	exit;
}
$warehouses=array();
$warehouses[] = array('id' => 0,'name'=>getFixedLabel('ALL'),'label'=>getFixedLabel('ALL'));

for($i=0;$i<$num_rows;$i++){
    $warehouses[]=array(
        'id'=>$adb->query_result($result,$i,'bankaccountsetid'),
        'name'=>$adb->query_result($result,$i,'accountname'),
        'label'=>$adb->query_result($result,$i,'accountname')
    );
    $selectbankcashid[] = $adb->query_result($result,$i,'bankaccountsetid');
}
if(isset($_REQUEST['bankcashid']) && $_REQUEST['bankcashid'] > 0)
{
    unset($selectbankcashid);
    $selectbankcashid[] = $_REQUEST['bankcashid'];
}
/*if(count($warehouses)>6){
    $warehousesofeight=array();
    for($i=0;$i<6;$i++){
        $warehousesofeight[]=$warehouses[$i];
    }
    $warehouseslast=array();
    for($i=6;$i<count($warehouses);$i++){
        $warehouseslast[$warehouses[$i]['id']]=$warehouses[$i]['name'];
    }
    $smarty->assign('BANKCASHMENU',$warehousesofeight);//公司账户信息
    $smarty->assign('MOREBANKCASHMENU',$warehouseslast);
}
else
{
    $smarty->assign('BANKCASHMENU',$warehouses);
}*/
//hzx 20231215 列表页面页签优化
$ListViewNavbarcur = 0;
for($i = 0;$i<count($warehouses);$i++){
    if($_REQUEST['bankcashid'] == $warehouses[$i]['id']){
        $ListViewNavbarcur = $i;
    }
}

$smarty->assign('ListViewNavbarcur',$ListViewNavbarcur);
$smarty->assign('ListViewNavbarlist',json_encode($warehouses));

if(isset($_REQUEST['bankcashid']) && $_REQUEST['bankcashid'] >= 0)
{
    $smarty->assign('BANKTYPESUBTOTAL',$_REQUEST['bankcashid']);
    $bankcashmenuid = 1;
} 
else
    $smarty->assign('BANKTYPESUBTOTAL',0);
$selModule = array(
    'BankAccountSet' => array( //公司账户
        'module' => 'BankAccountSet',
        'table' => 'ld_bankaccountset',
        'date' => 'ld_bankaccountset.confirmtime',
        'status' => 'ld_bankaccountset.bankaccountsetid',
        'no' => 'ld_bankaccountset.bankaccountsetid',
        'id' => 'ld_bankaccountset.bankaccountsetid',
        'accountid' => 'ld_bankaccountset.bankaccountsetid',
        'inner' => 'ld_bankaccountset.confirmby',
        'total' => 'ld_bankaccountset.initMoney',
        'wherestatus' => 'ld_bankaccountset.confirmed = 1',
        'person' => 'ld_bankaccountset.confirmby',
    ),
    'CashBill' =>array( //收款单
        'module' => 'CashBill',
        'table' => 'ld_cashbill',
        'date' => 'ld_cashbill.cashbilldate',
        'no' => 'ld_cashbill.cashbill_no',
        'status' => 'ld_cashbill.approvestatus',
        'id' => 'ld_cashbill.cashbillid',
        'accountid' => 'ld_cashbill.accountid',
        'inner' => 'ld_cashbill.bankaccountsetid',
        'total' => 'ld_cashbill.Total',
        'wherestatus' => 'ld_cashbill.approvestatus = "'.constant('D_A_S_APPROVED').'"',//已批准
        'person' => 'ld_cashbill.smownerid',
    ),
    
    
    'SendCashBill' =>array( //付款单
        'module' => 'SendCashBill',
        'table' => 'ld_sendcashbill',
        'date' => 'ld_sendcashbill.cashbilldate',
        'no' => 'ld_sendcashbill.sendcashbill_no',
        'id' => 'ld_sendcashbill.sendcashbillid',
        'status' => 'ld_sendcashbill.approvestatus',
        'accountid' => 'ld_sendcashbill.vendorid',
        'inner' => 'ld_sendcashbill.bankaccountsetid',
        'total' => 'ld_sendcashbill.Total',
        'wherestatus' => 'ld_sendcashbill.approvestatus = "'.constant('D_A_S_APPROVED').'"',//已批准
        'person' => 'ld_sendcashbill.smownerid',
    ),
    'CashDeposit' => array( //存款单
        'module' => 'CashDeposit',
        'table' => 'ld_cashdeposit',
        'date' => 'ld_cashdeposit.cashdepositdate',
        'status' => 'ld_cashdeposit.approvestatus',
        'no' => 'ld_cashdeposit.cashdeposit_no',
        'id' => 'ld_cashdeposit.cashdepositid',
        'accountid' => 'ld_cashdeposit.modifiedby',
        'inner' => 'ld_cashdeposit.Outaccount',
        'inneror' => 'ld_cashdeposit.inaccount',
        'total' => 'ld_cashdeposit.cashmoney',
        'wherestatus' => 'ld_cashdeposit.approvestatus = "'.constant('D_A_S_APPROVED').'"',//已批准
        'person' => 'ld_cashdeposit.smownerid',
    ),
    'PutCash' => array( //提现单
        'module' => 'PutCash',
        'table' => 'ld_putcash',
        'date' => 'ld_putcash.putcashdate',
        'status' => 'ld_putcash.approvestatus',
        'no' => 'ld_putcash.Putcash_no',
        'id' => 'ld_putcash.putcashid',
        'accountid' => 'ld_putcash.modifiedby',
        'inner' => 'ld_putcash.Outaccount',
        'inneror' => 'ld_putcash.inaccount',
        'total' => 'ld_putcash.cashmoney',
        'wherestatus' => 'ld_putcash.approvestatus = "'.constant('D_A_S_APPROVED').'"',//已批准
        'person' => 'ld_putcash.smownerid',
    ),
    'CashBack' => array(    //销售退款单
        'module' => 'CashBack',
        'table' => 'ld_cashback',
        'date' => 'ld_cashback.cashbackdate',
        'status' => 'ld_cashback.approvestatus',
        'no' => 'ld_cashback.cashback_no',
        'id' => 'ld_cashback.cashbackid',
        'accountid' => 'ld_cashback.accountid',
        'inner' => 'ld_cashback.bankaccountsetid',
        'total' => 'ld_cashback.total',
        'wherestatus' => 'ld_cashback.approvestatus = "'.constant('D_A_S_APPROVED').'"',
        'person' => 'ld_cashback.smownerid',
    ),
    'Expense' => array( //费用报销单
        'module' => 'Expense',
        'table' => 'ld_expense',
        'date' => 'ld_expense.expensedate',//ls 2022-02-11 49941: 通用问题，银行现金流水账模块，统计费用报销单的流水日期为审批提交的日期，而不是费用报销单中的“报销日期”
        'status' => 'ld_expense.approvestatus',
        'no' => 'ld_expense.expense_no',
        'id' => 'ld_expense.expenseid',
        'accountid' => 'ld_expense.accountid',
        'inner' => 'ld_expense.bankaccountsetid',
        'total' => 'ld_expense.total',
        'wherestatus' => 'ld_expense.approvestatus = "'.constant('D_A_S_APPROVED').'"',//已批准
        'person' => 'ld_expense.smownerid',
    ),
    'Commission' => array( //佣金单
        'module' => 'Commission',
        'table' => 'ld_commission',
        'date' => 'ld_commission.expensedate',
        'status' => 'ld_commission.approvestatus',
        'no' => 'ld_commission.commission_no',
        'id' => 'ld_commission.commission_id',
        'accountid' => 'ld_commission.accountid',
        'inner' => 'ld_commission.bankaccountsetid',
        'total' => 'ld_commission.total',
        'wherestatus' => 'ld_commission.approvestatus = "'.constant('D_A_S_APPROVED').'"',//已批准
        'person' => 'ld_commission.smownerid',
    ),
    'PurchaseCashBack' => array( //采购退款单  //ls 20221201 XUQIU1000685  增加审批功能（增加条件 审批状态为已批准）
        'module' => 'PurchaseCashBack',
        'table' => 'ld_purchasecashback',
        'date' => 'ld_purchasecashback.purchasecashbackdate',
        'status' => 'ld_purchasecashback.approvestatus',
        'no' => 'ld_purchasecashback.purchasecashback_no',
        'id' => 'ld_purchasecashback.purchasecashbackid',
        'accountid' => 'ld_purchasecashback.vendorid',
        'inner' => 'ld_purchasecashback.bankaccountsetid',
        'total' => 'ld_purchasecashback.total',
        'wherestatus' => 'ld_purchasecashback.approvestatus = "'.constant('D_A_S_APPROVED').'"',
        'person' => 'ld_purchasecashback.smownerid',
    ),
    'LoanApply' => array( //借款申请单
        'module' => 'LoanApply',
        'table' => 'ld_loanapply',
        'date' => 'approve.createdtime',
        'status' => 'ld_loanapply.approvestatus',
        'no' => 'ld_loanapply.loanapply_no',
        'id' => 'ld_loanapply.loanapplyid',
        'accountid' => 'ld_loanapply.accountid',
        'inner' => 'ld_loanapply.bankaccountsetid',
        'total' => 'ld_loanapply.loanmoney',
        'wherestatus' => 'ld_loanapply.approvestatus = "'.constant('D_A_S_APPROVED').'"',//已批准
        'person' => 'ld_loanapply.smownerid',
    ),
);
 $deploy_value=getSys_deploy(83);//已收金额计算时是否统计未审核的收款单	

    if($deploy_value['deploy_value']==0)
    {
        $selModule['CashBill']['wherestatus']='';
    }
 $deploy_value=getSys_deploy(84);//已付金额计算时是否统计未审核的付款单
    if($deploy_value['deploy_value']==0)
    {
        $selModule['SendCashBill']['wherestatus']='';
    }
//$selectbankcashid = array(0=>27212);


foreach($selectbankcashid as $bankkey =>$bankval)
{//开始
		$after_importtotal[$bankval] =0;
		$after_outtotal[$bankval]=0;
    foreach($selModule as $key =>$val)
    {
        $focus=CRMEntity::getInstance($key);
        $tablename=$focus->table_name;
        $table_index=$focus->table_index;
        
        $query = "select ld_bankaccountset.bankaccountsetid,ld_bankaccountset.accountname,".$val['table'].".currency_id,".$val['table'].".conversion_rate,".$val['table'].".currency_symbol,".$val['table'].".modifiedtime,".$val['date']." as date, 
        ".$val['no']." as no,".$val['id']." as id,".$val['accountid']." as accountid,".$val['status']." as status,
        ".$val['person']." as smownerid,".$val['table'].".createdtime,".$val['total']." as total";
        if($key =='CashDeposit' || $key =='PutCash')
        {
            $query .=",".$val['inneror']."";
        }
        $query .= " from ld_bankaccountset ";
        if($key != 'BankAccountSet')
        {
            $query .=" left join ".$val['table']." on ".$val['inner']." = ld_bankaccountset.bankaccountsetid ";
            if($key == 'PutCash' || $key == 'CashDeposit')
                $query .=" or ".$val['inneror']." = ld_bankaccountset.bankaccountsetid ";
            
        }
    	//费用报销根据单据的已批准时间进行查询
    	if(strtolower($key) == 'expense'){
    		$query .= 'INNER JOIN(SELECT
                    		max(ld_approvelog.createdtime) AS createdtime,
                    		crmid
                    	FROM
                    		ld_approvelog inner join ld_expense on ld_expense.expenseid=ld_approvelog.crmid
                    	GROUP BY
                    		crmid) as approve on approve.crmid = ld_expense.expenseid';
    	}
//        @edit:liushuai,2021-05-21,reason:【ID1001643】借款申请单增加“账户”字段，并计入银行账户和现金银行流水账(小计、余额列是在tpl里计算的)
        if($key == 'LoanApply'){

            $query .= 'INNER JOIN(select max(ld_approvelog.createdtime) as createdtime,crmid from ld_approvelog
            inner join  ld_loanapply on ld_loanapply.loanapplyid=ld_approvelog.crmid
               
             GROUP BY crmid) as approve on approve.crmid = ld_loanapply.loanapplyid';
        }
    	//$query .="inner join ld_crmentity on ".$val['id']." = ld_crmentity.crmid";
    	if(isset($_REQUEST['bankcashid']) && $_REQUEST['bankcashid'] > 0)
            $query .= " where ld_bankaccountset.bankaccountsetid = ". $_REQUEST['bankcashid'];
        else
            $query .= " where ld_bankaccountset.bankaccountsetid in (".implode(',', $selectbankcashid).")";
        $afterquery = $query;
        $afterquery .= " and ".$val['date']." < '$firstday'";

        if(isset($firstday) || isset($lastday))
        {
            if(isset($firstday) && $lastday == '')
                $query .=" and ".$val['date']." >= '$firstday 00:00:00'";
            else if(isset($lastday) && $firstday == '')
                $query .=" and ".$val['date']." <= '$lastday 23:59:59'";
            else
                $query .=" and (".$val['date']." >= '$firstday 00:00:00' and ".$val['date']." <= '$lastday 23:59:59' )";
        }
        if($key=='CashBack')
        {
             $deployarray = getSys_deploy(352);//是否开启审批  0是 1否
             if ($deployarray['deploy_value'] == 1)  //未开启审批
             {
                $val['wherestatus']='';
             }
            
        }
        if($ledger == 1 && $val['wherestatus']!="")
        {
            $query .= " and ".$val['wherestatus']."";
            $afterquery .= " and ".$val['wherestatus']."";
        }
        $query .=" and ".$val['table'].".deleted = 0 and ld_bankaccountset.bankaccountsetid = $bankval order by date asc,createdtime asc";

        $afterquery .=" and ".$val['table'].".deleted = 0 and ld_bankaccountset.bankaccountsetid = $bankval ;";

    	//echo $afterquery;echo '<br><br>';
        //if($key == 'BankAccountSet')
           // echo $query.'<br><br><br><br>';
        if($key == 'BankAccountSet')
            $type = 1;
        else
            $type = 0;
        //$afterquery 开始日期之前的余额统计
    // echo $afterquery."<br><br>";
        $afterresult = $adb->pquery($afterquery);
        $after_num_rows=  $adb->num_rows($afterresult);
		
        if($after_num_rows > 0)
        {
            for($i = 0; $i<$after_num_rows; $i++)
            {
				$conversion_rate = $adb->query_result($afterresult,$i,'conversion_rate');
				if($conversion_rate == '')$conversion_rate =1;
                if($val['module'] =='PutCash'||$val['module'] =='CashDeposit')
                {
                    if($adb->query_result($afterresult,$i,'inaccount') == $bankval)
                    {
                        $after_importtotal[$bankval] += $adb->query_result($afterresult,$i,'total');
                    }else
                    {
                        $after_outtotal[$bankval] += $adb->query_result($afterresult,$i,'total');
                    }  
                }
                elseif($val['module'] == 'Commission' || $val['module'] == 'SendCashBill' ||$val['module'] == 'Expense'||$val['module'] == 'CashBack' || $val['module'] == 'LoanApply')
                {
                    $after_outtotal[$bankval] += $adb->query_result($afterresult,$i,'total')/$conversion_rate;   
                }
                else if($val['module'] == 'PurchaseCashBack' || $val['module'] == 'CashBill'||$val['module'] == 'BankAccountSet')
                {
                    $after_importtotal[$bankval] += $adb->query_result($afterresult,$i,'total')/$conversion_rate;
					$tmpmodule=$val['module'];
					//echo  $after_importtotal[$bankval]."i.$i.$tmpmodule.<br>";
                }
            }
        }

        $result = $adb->pquery($query);
        $num_rows = $adb->num_rows($result);
        $setCash = 0;
        
        if($num_rows > 0)
        {    
            for($i = 0; $i<$num_rows; $i++)
            {
                if($key =='PutCash'||$key =='CashDeposit')
                {
                    if($adb->query_result($result,$i,'inaccount') == $bankval)
                        $setCash = 1;   //加
                    else
                        $setCash = 2;   //减少
                }
                // 存 取  费用报销
                if($key =='CashDeposit' || $key =='PutCash' || $key =='Expense' || $key =='LoanApply' || $key =='CashBack')
                {
                    $status = $adb->query_result($result,$i,'status');
                    if($status == constant('D_A_S_APPROVED'))//已批准
                        $date = $adb->query_result($result,$i,'modifiedtime');
                    else
                        $date = $adb->query_result($result,$i,'date');
                    
                }
                /*else if($key =='CashBack')
                {
                    $date = $adb->query_result($result,$i,'date');
                    $status = '';
                }*/
                else if($key =='BankAccountSet')
                {
                    $date = $adb->query_result($result,$i,'date');
                    $status = '已确认';
                }
                /*else if($key == 'PurchaseCashBack')
                {
                    $status = '';
                }*/
                else
                {
                    $date = $adb->query_result($result,$i,'date');
                    $status = $adb->query_result($result,$i,'status');
                }
                if($val['module'] == 'PutCash'||$val['module'] == 'CashDeposit')
                {
                    if($setCash == 1)
                    {
                        $importtotal = $adb->query_result($result,$i,'total');
                        $outtotal = 0;
                    }
                    else
                    {
                        $importtotal = 0;
                        $outtotal = $adb->query_result($result,$i,'total');
                    }
                }
                elseif($val['module'] == 'Commission' || $val['module'] == 'SendCashBill' ||$val['module'] == 'Expense'||$val['module'] == 'CashBack' || $val['module'] == 'LoanApply')
                {
                    $importtotal = 0;
                    $outtotal = $adb->query_result($result,$i,'total'); 
			
                }
                else if($val['module'] == 'PurchaseCashBack' || $val['module'] == 'CashBill'||$val['module'] == 'BankAccountSet')
                {
                    $importtotal = $adb->query_result($result,$i,'total');
                    $outtotal = 0;
                }
               
               
    			//date("Y-m-d",strtotime($date))
                $banklist[$bankkey][] = array(
				'bankaccountsetid'=>$bankval,
                    'date' => date('Y-m-d',strtotime($adb->query_result($result,$i,'date'))),
                    'cashname' => $adb->query_result($result,$i,'accountname'),
                    'cashid' => $bankval,
                    'bill' => getTranstab($key) . getCashName($key,$setCash),
                    'billno' => getBillNo($key,$adb->query_result($result,$i,'no'),$adb->query_result($result,$i,'id')),
                    'accountid' => getPerson($key,$adb->query_result($result,$i,'accountid'),0),
                    'status' => $status,
                    'person' => getPerson($key,$adb->query_result($result,$i,'smownerid'),1),
                    'importtotal' => $importtotal,
                    'outtotal' => $outtotal,
                    'createdtime' => $adb->query_result($result,$i,'createdtime'),
                    'module' => $val['module'],
                    'setcash' => $setCash,
    				'currency_id' =>$adb->query_result($result,$i,'currency_id'),
    				'currency_symbol' =>$adb->query_result($result,$i,'currency_symbol'),
    				'conversion_rate' =>$adb->query_result($result,$i,'conversion_rate'),
                    'type'=>$type
                );
                $bankcasharr[$bankkey]= $banklist[$bankkey];
            }
        }

    }
//$banklist = array_sort($banklist,'createdtime');
}//结束

$j = 0;
//echo $after_importtotal .'==' .$after_outtotal;

global $aftertotal;
foreach($after_importtotal as $bankid=>$money)
{
	$tmp[$bankid]=$money - $after_outtotal[$bankid];
	
}
$aftertotal=$tmp;
$smarty->assign('AFTERTOTAL',$tmp);
//$smarty->assign('AFTERTOTAL',$after_importtotal - $after_outtotal);
$bankcashalllist = array();
if(!empty($bankcasharr)){
	foreach($bankcasharr as $key => $val)
	{
		//createdtime
		$setarr = array_sort($val,'date');
		
		//$setarr=$val;
		foreach($setarr as $setkey => $setval)
		{
			$num = $setkey;
			break; 
		}
		for($i = 0; $i<=count($setarr); $i++)
		{
			$j++;
			if($num>0 && count($setarr) == 1 )
			{
				$setbankcashalllist[$j] = $setarr[$i+1];
			}else{
				if(isset($setarr[$i]))
				{
					$setbankcashalllist[$j] = $setarr[$i];
				}
			}
		}
		$k = 0;
		foreach($setbankcashalllist as $list)
		{	
			if(!empty($list)){
				$bankcashalllist[$k] = $list;
				$k++;
			}
		}
		/*foreach($setarr as $skey=>$sval)
		{
			$bankcashalllist[$i] = $sval;
			$i++;
		}*/
	}
}

//小计
$bankcashalllistlen = $outTotal = $inTotal = 0;
if(!empty($bankcashalllist)){
	$bankcashalllistlen = count($bankcashalllist);
	for($i = 0; $i<$bankcashalllistlen; $i++){
		$inTotal += $bankcashalllist[$i]['importtotal'];
		$outTotal += $bankcashalllist[$i]['outtotal'];
	}
}

/*echo '<pre>';
print_r($bankcashalllist);
print_r($after_outtotal);
echo '</pre>';*/

$smarty->assign('SUBTOTAL',array('0'=>$inTotal,'1'=>$outTotal,'2'=>$inTotal - $outTotal));

$smarty->assign('BANKLIST',$bankcashalllist);
$smarty->assign('BANKLISTNUMROWS',$bankcashalllistlen);
$smarty->assign('BANKCASHID',$_REQUEST['bankcashid']);
$smarty->assign('BANKCASHMENUID',$bankcashmenuid);
function getCashName($module,$type)
{
    if($module == 'CashDeposit' || $module == 'PutCash')
    {
        if($type == 1)//转入
            return '(' . getFixedLabel('TOCHANGEINTO') .')';
        elseif($type == 2)
            return '(' . getFixedLabel('ROLLOUT') .')';
    }
}
//0 获取客户/供应商  1 获取相关人员  2 获取合计
function getPerson($module,$id,$type)
{
    if($type == 1)
        return getOwnerName($id);
    elseif($type == 2)
        return getTotal($module,$id);
    if($module == 'CashBill' || $module == 'Expense' || $module == 'CashBack' || $module == 'Commission' || $module == 'LoanApply')
    {
        $name = getModuleHref('Accounts',$id);
        $sMdoule = 'Accounts';
    }
    elseif($module == 'SendCashBill' || $module == 'PurchaseCashBack')
    {
        $name = getModuleHref('Vendors',$id);
        $sMdoule = 'Vendors';
    }
    elseif($module == 'CashDeposit')
    {
        return '';
    }
    return "<a href='javascript:;' onclick='DetailViewReferenceLinkClick(ld(this),event)' referencemodule='".$sMdoule."' referencerecord='" . $id . "' >" . $name . "</a>";
}
function getApproveLog($crmid,$type)
{
    global $adb;
    $sql = "select approveresult,createdtime from ld_approvelog 
    inner join ld_cashdeposit on ld_approvelog.crmid = ld_cashdeposit.cashdepositid where crmid = ? order by createdtime desc limit 0,1";
    $result = $adb->pquery($sql,array($crmid));
    if($adb->num_rows($result) <= 0)
    {
        if($type == 0)
            return getAppStatus(0);
        else
            return '';
    }
    else
    {
        $AppSatatus = getAppStatus($adb->query_result($result,0,'approveresult'));
        if($type == 0)
        {
            return $AppSatatus;
        }
        else
        {
            if($AppSatatus == constant('D_A_S_APPROVED'))//已批准
                return date("Y-m-d",strtotime($adb->query_result($result,0,'createdtime')));
            else
                return '';
        }
    }
}
function array_sort_key($arr)
{
    $newarr = array();
    foreach($arr as $val)
    {
        $newarr[] = $val;
    }
    return $newarr;
}
function array_sort($arr, $keys, $type = 'asc') {
    $keysvalue = $new_array = array();
    foreach ($arr as $k => $v)
    {
        $keysvalue[$k] = $v[$keys];
    }
    if ($type == 'asc')
    {
        asort($keysvalue);
    } else {
        arsort($keysvalue);
    }
    reset($keysvalue);
    $i = 1;
    foreach ($keysvalue as $k => $v)
    {
        if($arr[$k]['type'] == 1)
        {
            $new_array[0] = $arr[$k];
        }else{
            $new_array[$i] = $arr[$k];
            $i++;
        }
    }
    //$arr = current($new_array);
//    foreach ($new_array as $key => $val)
//    {
//        if($new_array[$key]['type'] !=1)
//       {
//            for($i = 0; $i<count($new_array); $i++)
//            {
//                $newArr[$i] = $new_array[$i];
//            }
//            return $new_array;
//       }   
//    }
    //print_r($newArr);
    
    return $new_array;
}
function getAppStatus($id)
{
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 上午 11:34
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $result = $objpinklist->getPickListValues_Byid($id);
    return $result;
   /* global $adb;
    $sql = "select approvestatus from ld_approvestatus where statusid = ?";
    $result = $adb->pquery($sql,array($id));
    return  $adb->query_result($result,0,0);*/
}
//0转入金额  1转出金额
function getTotal($module,$id,$type)
{
    global $adb;
    if($module == 'CashBill' && $type == 0)
        $sql = "select total from ld_cashbill where cashbillid = ?";
    elseif($module == 'SendCashBill' && $type == 1)
        $sql = "select total from ld_sendcashbill where sendcashbillid = ?";
    else
        return 0;
        
    $result = $adb->pquery($sql,array($id));
    return $adb->query_result($result,0,0);
}
function getBillNo($module,$billbo,$id)
{
    if($module == 'BankAccountSet')
        return '';
    else
        return "<a href='javascript:;' onclick='DetailViewReferenceLinkClick(ld(this),event)' referencemodule='".$module."' referencerecord='" . $id . "' >".$billbo."</a>";
}

function  formatPrice($value, $decimal=2)
{
	$currencyField = new CurrencyField($value);
	return $currencyField->getDisplayValue(null, true);
}
$smarty->assign('InventoryInfo',$InventoryArray);
$smarty->assign('COUNTARRAY',$CountArray);
if(is_array($Sum)){
    for($i = 0; $i<count($Sum); $i++)
    {
        $Sum[$i] = getDecimalTwoVal($Sum[$i]);
    }
}
$smarty->assign('APP',$app_strings);
$smarty->assign('MOD',$mod_strings);
$smarty->assign('THEME',$theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('MODULE',$currentModule);
$smarty->assign('LASTDAY',$lastday);
$smarty->assign('FIRSTDAY',$firstday);
$smarty->assign('UNPRICE',$unprice);
$smarty->assign('PRODUCTINFO',$productinfo);
$smarty->assign('LEDGER',$ledger);
$smarty->assign('PRODUCTDETAIL',$productdetail);
$contacts_field_obj=Field::getInstance('Products',$adb);
$productFieldlabels=$contacts_field_obj->getFieldLables();
$smarty->assign('PRODUCTFIELDLABELS',$productFieldlabels);
//setGLobalURLSmarty($smarty);//设置js,css等访问路径
if($_REQUEST['action']!='ExportBankCash'){
	if(!empty($_REQUEST['ajax']) && $_REQUEST['ajax'] == 'yes'){
		 $smarty->display('BankCashListViewEntries.tpl');

	}else{
		 $smarty->display('BankCashListView.tpl');
	}
   
}
/**
 * reason：查询期间下拉框切换事件
 * date:201-06-28
 * edit:cyb 
 **/
function getCriteriaJs()
{   
        $todayDateTime =date('Y-m-d');
        
		$tomorrow = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 1, date("Y")));
		$tomorrowDateTime = $tomorrow ;

		$syesterday = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 1, date("Y")));
		$syesterdayDateTime = $syesterday ;

		$currentmonth0 = date("Y-m-d", mktime(0, 0, 0, date("m"), "01", date("Y")));
		$currentMonthStartDateTime = $currentmonth0 ;
		$currentmonth1 = date("Y-m-t");
		$currentMonthEndDateTime = $currentmonth1 ;

		$lastmonth0 = date("Y-m-d", mktime(0, 0, 0, date("m") - 1, "01", date("Y")));
		$lastMonthStartDateTime = $lastmonth0;
		$lastmonth1 = date("Y-m-t", strtotime("-1 Month"));
		$lastMonthEndDateTime = $lastmonth1 ;

		$nextmonth0 = date("Y-m-d", mktime(0, 0, 0, date("m") + 1, "01", date("Y")));
		$nextMonthStartDateTime = $nextmonth0 ;
		$nextmonth1 = date("Y-m-t", strtotime("+1 Month"));
		$nextMonthEndDateTime = $nextmonth1 ;

		$lastweek0 = date("Y-m-d",mktime(0, 0, 0,date("m"),date("d")-date("w")-6,date("Y")));
		$lastWeekStartDateTime = $lastweek0 ;
		$lastweek1 = date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w"),date("Y")));
		$lastWeekEndDateTime = $lastweek1 ;

        //$thisweek0 = date("Y-m-d", strtotime("this monday"));
        $thisweek0 = date("Y-m-d",mktime(0, 0, 0,date("m"),date("d")-date("w")+1,date("Y")));
		$thisWeekStartDateTime = $thisweek0 ;
		//$thisweek1 = date("Y-m-d", strtotime("this sunday"));
        $thisweek1 = date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w")+7,date("Y")));
		$thisWeekEndDateTime = $thisweek1 ;

		$nextweek0 = date("Y-m-d",mktime(0, 0, 0,date("m"),date("d")-date("w")+8,date("Y")));
		$nextWeekStartDateTime = $nextweek0 ;
		$nextweek1 = date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w")+14,date("Y")));
		$nextWeekEndDateTime = $nextweek1 ;	     
            
        $defaultStartDate= "2000-01-01";
        $defaultStartDateTime=$defaultStartDate ;
        $defaultEndDate="2020-12-31";
        $defaultEndDateTime=$defaultEndDate ;     
   
		$currentFY0 = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
		$currentFYStartDateTime = $currentFY0 ;
		$currentFY1 = date("Y-m-t", mktime(0, 0, 0, "12", date("d"), date("Y")));
		$currentFYEndDateTime = $currentFY1 ;

		$lastFY0 = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y") - 1));
		$lastFYStartDateTime = $lastFY0 ;
		$lastFY1 = date("Y-m-t", mktime(0, 0, 0, "12", date("d"), date("Y") - 1));
		$lastFYEndDateTime =$lastFY1 ;

		$nextFY0 = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y") + 1));
		$nextFYStartDateTime = $nextFY0 ;
		$nextFY1 = date("Y-m-t", mktime(0, 0, 0, "12", date("d"), date("Y") + 1));
		$nextFYEndDateTime =$nextFY1 ;
		if (date("m") <= 3) {
			$cFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
			$cFqStartDateTime = $cFq ;
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "03", "31", date("Y")));
			$cFqEndDateTime = $cFq1 ;

			$nFq = date("Y-m-d", mktime(0, 0, 0, "04", "01", date("Y")));
			$nFqStartDateTime = $nFq ;
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "06", "30", date("Y")));
			$nFqEndDateTime =$nFq1;

			$pFq = date("Y-m-d", mktime(0, 0, 0, "10", "01", date("Y") - 1));
			$pFqStartDateTime =$pFq ;
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y") - 1));
			$pFqEndDateTime = $pFq1 ;
		} else if (date("m") > 3 and date("m") <= 6) {

			$pFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
			$pFqStartDateTime = $pFq ;
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "03", "31", date("Y")));
			$pFqEndDateTime = $pFq1 ;

			$cFq = date("Y-m-d", mktime(0, 0, 0, "04", "01", date("Y")));
			$cFqStartDateTime = $cFq ;
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "06", "30", date("Y")));
			$cFqEndDateTime = $cFq1 ;

			$nFq = date("Y-m-d", mktime(0, 0, 0, "07", "01", date("Y")));
			$nFqStartDateTime = $nFq ;
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "09", "30", date("Y")));
			$nFqEndDateTime = $nFq1 ;
		} else if (date("m") > 6 and date("m") <= 9) {

			$nFq = date("Y-m-d", mktime(0, 0, 0, "10", "01", date("Y")));
			$nFqStartDateTime = $nFq ;
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y")));
			$nFqEndDateTime = $nFq1 ;

			$pFq = date("Y-m-d", mktime(0, 0, 0, "04", "01", date("Y")));
			$pFqStartDateTime = $pFq ;
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "06", "30", date("Y")));
			$pFqEndDateTime = $pFq1 ;

			$cFq = date("Y-m-d", mktime(0, 0, 0, "07", "01", date("Y")));
			$cFqStartDateTime = $cFq ;
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "09", "30", date("Y")));
			$cFqEndDateTime = $cFq1 ;
		} else if (date("m") > 9 and date("m") <= 12) {
			$nFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y") + 1));
			$nFqStartDateTime = $nFq ;
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "03", "31", date("Y") + 1));
			$nFqEndDateTime = $nFq1 ;

			$pFq = date("Y-m-d", mktime(0, 0, 0, "07", "01", date("Y")));
			$pFqStartDateTime = $pFq ;
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "09", "30", date("Y")));
			$pFqEndDateTime = $pFq1 ;

			$cFq = date("Y-m-d", mktime(0, 0, 0, "10", "01", date("Y")));
			$cFqStartDateTime = $cFq ;
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y")));
			$cFqEndDateTime =$cFq1 ;
		}
        $DateTime=array
              (
                      "prevfy"=>Array($lastFYStartDateTime,$lastFYEndDateTime),
                      "thisfy"=>Array($currentFYStartDateTime,$currentFYEndDateTime),
                      "nextfy"=>Array($nextFYStartDateTime,$nextFYEndDateTime),
                      "prevfq"=>Array($pFqStartDateTime,$pFqEndDateTime),
                      "thisfq"=>Array($cFqStartDateTime,$cFqEndDateTime),
                      "nextfq"=>Array($nFqStartDateTime,$nFqEndDateTime),
                      "syesterday"=>Array($syesterdayDateTime,$syesterdayDateTime),
                      "today"=>Array($todayDateTime,$todayDateTime),
                      "tomorrow"=>Array($tomorrowDateTime,$tomorrowDateTime),
                      "lastweek"=>Array($lastWeekStartDateTime,$lastWeekEndDateTime),
                      "thisweek"=>Array($thisWeekStartDateTime,$thisWeekEndDateTime),
                      "nextweek"=>Array($nextWeekStartDateTime,$nextWeekEndDateTime),
                      "lastmonth"=>Array($lastMonthStartDateTime,$lastMonthEndDateTime),
                      "thismonth"=>Array($currentMonthStartDateTime,$currentMonthEndDateTime),
                      "nextmonth"=>Array($nextMonthStartDateTime,$nextMonthEndDateTime)                                       
                               
             );
        $lastdays= CommonView::$lastdays; 
        $beforedays= CommonView::$beforedays;
        $nextdays= CommonView::$nextdays; 
        $afterdays= CommonView::$afterdays;
        foreach($beforedays as $key_beforedays=>$value_beforedays){                 
            $DateTime['before'.$value_beforedays.'days']=Array($defaultStartDate,date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - $value_beforedays+1, date("Y"))));
        }         
        foreach($lastdays as $key_lastdays=>$value_lastdays){
            $DateTime['last'.$value_lastdays.'days']=Array(date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - $value_lastdays+1, date("Y"))),$todayDateTime);
        }         
        foreach($nextdays as $key_nextdays=>$value_nextdays){
            $DateTime['next'.$value_nextdays.'days']=Array($todayDateTime,date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") +$value_nextdays-1 , date("Y"))));
        }
        foreach($afterdays as $key_afterdays=>$value_afterdays){
            $DateTime['after'.$value_afterdays.'days']=Array(date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") +$value_afterdays-1 , date("Y"))),$defaultEndDate);
        }        
        $datetimestr=json_encode($DateTime);//将数组进行json编码，方便在js当中使用               
		$sjsStr = '<script language="JavaScript" type="text/javaScript">
			function showDateRange( type ) {
                if (type!="custom") {
    				document.massdelete.startdate.readOnly=true;
    				document.massdelete.enddate.readOnly=true;			
                } 
                else {
    				document.massdelete.startdate.readOnly=false;
    				document.massdelete.enddate.readOnly=false;
       	            document.massdelete.startdate.value = "";
			    	document.massdelete.enddate.value = "";			
			    }               
                var resultobj=eval('.$datetimestr.');  
                for(var i in resultobj)
                {                   
                    if(type==i){                        
                           document.massdelete.startdate.value = resultobj[i][0];
    					   document.massdelete.enddate.value = resultobj[i][1];  
                        }                       
                }              
 			}
		</script>';        
        return $sjsStr;        
    }      
?>