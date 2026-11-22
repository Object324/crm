<?php
//计算预算数据 处理过程
global $adb;
$budgetType = $_REQUEST['budgetType'];//预算类型 只有按目标与按业绩的会走到这个文件来计算
$_REQUEST['diony'] = 'yes';
$budget_indicators = $_REQUEST['budget_indicators'];//指标
$indicators_start_date = $_REQUEST['indicators_start_date'];//指标开始时间
$indicators_end_date = $_REQUEST['indicators_end_date'];//指标结束时间
$selected_groupid = $_REQUEST['selected_groupid'];//预算人员
$budget_rate = $_REQUEST['budget_rate'];//预算比例
$record = $_REQUEST['record'];//ID

$detail_list = [];
if($record>0){
    $detail_sql = "select lineitem_id,id,lin_users_id,adjustment_amount,budget_rate,amount,budget_amount,description from  ld_expensebudgetdetail where id=?";
    $detail_res = $adb->pquery($detail_sql,array($record));
    $detail_nums = $adb->num_rows($detail_res);

    if($detail_nums>0){
        for($i=0;$i<$detail_nums;$i++){
            $lin_users_id =  $adb->query_result($detail_res,$i,'lin_users_id');
            $detail_list[$lin_users_id]['lineitem_id'] = $adb->query_result($detail_res,$i,'lineitem_id');
            $detail_list[$lin_users_id]['amount'] = $adb->query_result($detail_res,$i,'amount');
            $detail_list[$lin_users_id]['budget_rate'] = $adb->query_result($detail_res,$i,'budget_rate');
            $detail_list[$lin_users_id]['adjustment_amount'] = $adb->query_result($detail_res,$i,'adjustment_amount');
            $detail_list[$lin_users_id]['budget_amount'] = $adb->query_result($detail_res,$i,'budget_amount');
            $detail_list[$lin_users_id]['description'] = $adb->query_result($detail_res,$i,'description');
        }
    }
}

if($budgetType=="basicBudget"){
    //直接录入预算
    $selected_groupid = explode(',',$selected_groupid);
    $data = [];

    foreach ($selected_groupid as $k=>$v){
        $data[$k]['lineitem_id'] = 0;
        $data[$k]['parent_lineitem_id'] = 0;
        $data[$k]['lin_users_id'] = $v;
        $data[$k]['budget_amount'] = 0.00;
        $data[$k]['description'] = '';
        if(isset($detail_list[$v])){
            $data[$k]['lineitem_id'] = $detail_list[$v]['lineitem_id'];
            $data[$k]['budget_amount'] =$detail_list[$v]['budget_amount'];
            $data[$k]['description'] = $detail_list[$v]['description'];
        }
    }
}else {
    if ($budgetType == 'salesGoalBudget') {
        //按目标金额预算
        // 参数示例  [budget_indicators] => ContractVolumeamount
        //    [budget_rate] => 2
        //    [indicators_start_date] => 2021-06-01
        //    [indicators_end_date] => 2021-06-01
        /*
        $totalcolumn = 'paymentamount';
        switch ($budget_indicators) {
            case "ContractVolumeamount":
                $totalcolumn = "contractamount";
                break;
            case "Invoicedamount":
                $totalcolumn = "invoiceamount";
                break;
            case "Outboundorderamount":
                $totalcolumn = "outboundorderamount";
                break;
            default:
                $totalcolumn = "paymentamount";
                break;
        }
        */
        $targetSql = "SELECT
        	u.id,
        	u.last_name,
            u.wx_userid,
        	ifnull(t.target,0) as target
            FROM
            	ld_users u
            LEFT JOIN (
                SELECT SUM(targetvalue) as target,record as userid from ld_salestarget_basic INNER JOIN ld_salestarget_info 
                    on ld_salestarget_basic.targetid = ld_salestarget_info.targetid
                where type = 'Users' and record in ($selected_groupid) and ld_salestarget_basic.targetname = '$budget_indicators'
                and DATE_FORMAT(concat(targetyear, '-', targetmonth,'-01'),'%Y-%m-%d') >= '$indicators_start_date'
            	AND DATE_FORMAT(concat(targetyear, '-', targetmonth,'-01'),'%Y-%m-%d') <= '$indicators_end_date'
                GROUP BY record
            ) t ON u.id = t.userid
            WHERE
            	u.id IN ($selected_groupid)";
            $targetRes = $adb->pquery($targetSql);
            $nums = $adb->num_rows($targetRes);


    }
    else {
        //按业绩录入预算 参数示例
        //selected_groupid: 135,138
        //budget_indicators: Cashbillamount
        //budget_rate: 2
        //indicators_start_date: 2019-04-30
        //indicators_end_date: 2021-06-07
        //budgetType: salesAchievementBudget
        $indicatorsSql = "select * from ld_expensebudget_totalcolumns where type='salesAchievementBudget' and name='$budget_indicators'";
        $indicatorsRes = $adb->pquery($indicatorsSql);
        $indicatorsNums = $adb->num_rows($indicatorsRes);
        $indicators = [];
        $sqlChildren = [];
        $totalColumns = [];
        if ($indicatorsNums > 0) {
            for ($i = 0; $i < $indicatorsNums; $i++) {
                $columns = $adb->query_result($indicatorsRes, $i, 'columns');
                $modulename = $adb->query_result($indicatorsRes, $i, 'modulename');
                //模块未激活
                if(!vtlib_isModuleActive($modulename)){
                    continue;
                }
                $sys_deploy = getSys_deploy(324);
                $columnsArr = explode('.', $columns);
                $tablename = $columnsArr[0];
                $tableWhere = '';
                //如果是合同订单 特殊条件    approve status！=“已作废”；
                if ($tablename == "ld_salesorder") {
                    $tableWhere = " and " . $tablename . ".sostatus!='已作废' ";
                }
                if($tablename == "ld_servicecontracts"){
                    $tableWhere = " and " . $tablename . ".contract_status!='已作废' ";
                }
                //根据tablename获取模块名 tabid
                $fieldSql = "select tabid from ld_field where tablename=? limit 1 ";
                $fieldRes = $adb->pquery($fieldSql, [$tablename]);
                $tabid = $adb->query_result($fieldRes, 0, 'tabid');
                $time_condition_field = $adb->query_result($indicatorsRes, $i, 'time_condition_field');
                $time_condition_default = $adb->query_result($indicatorsRes, $i, 'time_condition_default');
                $approved = $adb->query_result($indicatorsRes, $i, 'approved');
                //审批条件 是否只统计已审批单据 $approved=='yes'&&开启审批参数
                //$deploy = getSys_deploy();

                if ($approved == 'yes'&&$sys_deploy['deploy_value']==0) {
                    $tableWhere = " and " . $tablename . ".approvestatus='已批准' ";
                }
                $totalColumns[] = "ifnull(temp" . $i . ".sales_total, 0)";
                $sqlChildren[] = "(SELECT
                    		u.id,
                    		u.last_name,
                            u.wx_userid,
                    		sum(
                    			ifnull($columns, 0) * ifnull(
                    				$tablename.conversion_rate,
                    				1
                    			)
                    		) AS sales_total
                    	FROM
                    		ld_users u
                    	inner JOIN " . $tablename . " ON " . $tablename . ".smownerid = u.id
                    	WHERE
                    		u.id IN ($selected_groupid)
                    	AND " . $tablename . ".deleted = 0 $tableWhere
                    	AND $time_condition_field BETWEEN '$indicators_start_date'
                    	AND '$indicators_end_date'
                    	GROUP BY
                    		u.id)temp" . $i . " ON u.id = temp" . $i . ".id";
            }
        }
        if(!empty($sqlChildren)){
            $totalColumns = implode('+', $totalColumns);
            $totalColumns = ",($totalColumns) as  target";
            $sqlChildren = implode(' left join ', $sqlChildren);
            $sqlChildren = ' LEFT JOIN '.$sqlChildren;
        }else{
            $totalColumns = '';
            $sqlChildren = '';
        }

        $targetSql = "SELECT
	u.id,
	u.last_name
	$totalColumns
FROM
	ld_users u
 $sqlChildren where u.id IN ($selected_groupid)";
        $targetRes = $adb->pquery($targetSql);
        $nums = $adb->num_rows($targetRes);
    }

    $detailHtml = '';
    $data = [];
    if ($nums > 0) {
        for ($i = 0; $i < $nums; $i++) {
            $data[$i]['lineitem_id'] = 0;
            $data[$i]['parent_lineitem_id'] = 0;
            $userid = $adb->query_result($targetRes, $i, 'id');
            $data[$i]['lin_users_id'] = $userid;
            $target = $adb->query_result($targetRes, $i, 'target');
            $target = round($target, 2);
            $amount = round($target * $budget_rate / 100, 2);
            $budgetAmount = $amount;
            $rowindex = $i + 1;
            $data[$i]['reference_amount'] = $target;
            $data[$i]['budget_rate'] = $budget_rate;
            $data[$i]['amount'] = $amount;
            $data[$i]['adjustment_amount'] = 0.00;
            $data[$i]['budget_amount'] = $budgetAmount;
            $data[$i]['description'] = '';

            if(isset($detail_list[$userid])){
                $data[$i]['lineitem_id'] = $detail_list[$userid]['lineitem_id'];
                $data[$i]['budget_rate'] =$detail_list[$userid]['budget_rate'];
                $data[$i]['amount'] =$detail_list[$userid]['amount'];;
                $data[$i]['adjustment_amount'] =$detail_list[$userid]['adjustment_amount'];
                $data[$i]['budget_amount'] =$detail_list[$userid]['budget_amount'];
                $data[$i]['description'] = $detail_list[$userid]['description'];
            }
        }
    }
}
$focus = CRMEntity::getInstance('ExpenseBudget');
$focus->column_fields['expensebudget_type'] = $budgetType;
//zkt 20230727 BUG0070085 费用预算单直接录入选择预算人员之后不能填金额 
if($record >0){
    $focus->mode ='edit';
}
else{
    $focus->mode ='create';
}

crm_load_class_file('ExpenseBudgetDetailFieldsHtml', 'modules/ExpenseBudget');
$detailfieldruleobj=cls_detailfieldrule::getInstance('ExpenseBudget');
$columnvalues=$focus->column_fields;
$translatefieldvalues= getTranslateDbValueNew('ExpenseBudget','expensebudget_type');
$labelbol=$translatefieldvalues[$budgetType]['labelbol'];
$columnvalues['expensebudget_type']=getFixedLabel($labelbol);
$detailfieldruleobj->setColumnValues($columnvalues);
$fieldruleproperty= $detailfieldruleobj->getFieldRuleProperty();

$ExpenseBudgetDetailFieldsHtml = new ExpenseBudgetDetailFieldsHtml($focus, 'ExpenseBudget',$data,'yes');
$detailHtml = $ExpenseBudgetDetailFieldsHtml->getTabDetailHtmlContent();
ConvertTojsonString(1, ['detailHtml'=>$detailHtml], "success");