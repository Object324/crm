<?php

//zxm 微迪迦
class WeidijiaReport
{
    private $adb;
    private $showcolLists;

    public function __construct($showcolLists)
    {
        global $adb;
        $this->adb = $adb;
        $this->showcolLists = $showcolLists;
    }
    //视频租赁收入表
    public function ListViewForVideoRental($data_range)
    {
        $createdtimeinput = $_REQUEST['createdtimeinput'];
        //时间搜索条件
        switch ($createdtimeinput){
            case "thisyear": $startmonth = date('Y-01-01',time());break;
            case "lastyear": $startmonth = (date('Y',time())-1).'-01-01';break;
            case "nextyear": $startmonth = (date('Y',time())+1).'-01-01';break;
            default : $createdtimeinputarr = explode('~',$createdtimeinput);
                    $startmonth = $createdtimeinputarr[0];break;
        }
        $whereorder = [];
        // 只统计审批通过的合同订单
        if (isset($_REQUEST['VideoRentalOnlyApproved']) && $_REQUEST['VideoRentalOnlyApproved'] == 'yes') {
            $whereorder[] = " ld_salesorder.approvestatus='已通过' ";
        }
        // 只统计待收金额>0 的合同订单
        if (isset($_REQUEST['receivable_balance_morethan']) && $_REQUEST['receivable_balance_morethan'] == 'yes') {
            $whereorder[] = " ld_salesorder.receivable_balance>0 ";
        }
        if (isset($_REQUEST['basicotherfind']) && !empty($_REQUEST['basicotherfind'])) {
            $accountname = $_REQUEST['basicotherfind'];
            $whereorder[] = " ld_account.accountname like '%$accountname%' ";
        }
		//签约日期====2022-4-19 改成开户日期
		if(!empty($_REQUEST['duedate_start']) || !empty($_REQUEST['duedate_end'])){
			if(!empty($_REQUEST['duedate_start'])){
				$whereorder[] = " ld_outboundorder.outdate >= '".$_REQUEST['duedate_start']."' ";
			}
			if(!empty($_REQUEST['duedate_end'])){
				$whereorder[] = " ld_outboundorder.outdate <= '".$_REQUEST['duedate_end']."'";
			}
		}
        //查询sql
        //WHERE FIND_IN_SET(smownerid,'$data_range')
        $report_sql = $this->getVideoRentalSql($whereorder, $data_range);
        $result = $this->adb->pquery($report_sql);
        $html = '<tr>';
        $nums = $this->adb->num_rows($result);
        $list = [];
        $subTotal = [];
        $nums_sub = 0;
        //公共的时间数组
        $end_month = date('Y-m-d',strtotime('+12 month',strtotime($startmonth)));
        $month_arr = $this->dateMonths($startmonth,$end_month);
        $month_nums = sizeof($month_arr);
        if ($nums >= 1) {
            $last_salesorderid = 0;
            for ($i = 0; $i < $nums; $i++) {
                $last_name = $this->adb->query_result($result, $i, 'last_name');
                $salesorderid = $this->adb->query_result($result, $i, 'salesorderid');
                $accountid = $this->adb->query_result($result, $i, 'accountid');
                $productid = $this->adb->query_result($result, $i, 'productid');
                if (!isset($subTotal[$last_name])) {
                    $nums_sub = 1;
                } else {
                    $nums_sub += 1;
                }

                $list[$i]["order"] = $i;
                $list[$i]["salesorderid"] = $salesorderid;
                $list[$i]["accountid"] = $accountid;
                $list[$i]["productid"] = $productid;
				$list[$i]["sequence_no"] = $this->adb->query_result($result, $i, 'sequence_no');
                //出库额的税  含税金额 不含税金额  起止日期
                $notax_amount = $this->adb->query_result($result, $i, 'notax_amount');
                $tax_amount = $this->adb->query_result($result, $i, 'tax_amount');
                $tax = $this->adb->query_result($result, $i, 'tax');
                $start_date = $this->adb->query_result($result, $i, 'start_date');
                $end_date = $this->adb->query_result($result, $i, 'end_date');
                $month_origin_arr = $this->dateMonths($start_date,$end_date);

                $subTotal[$last_name]["order"] = $i + 0.5;
                $subTotal["合计"]["order"] = $i + 1;
                $subTotal[$last_name]["is_count"] = 1;
                $subTotal['合计']["is_count"] = 1;

                $month_origin_arr_nums = sizeof($month_origin_arr);
                //zxm 2022-5-5 bug51414 报表管理——常用报表——视频租赁表，开户申请单明细中，如果服务开始日期跟服务结束日期在同一个月，则算该产品金额平摊到该月中，生成一条报表数据，
                if($month_origin_arr_nums>=2){
                    $start_date_num = substr($start_date,8,2);
                    if($start_date_num>20){
                        unset($month_origin_arr[0]);//服务开始日期是1~20日，则从当月开始计算业绩
                    }
                    $end_date_num = substr($end_date,8,2);
                    if($end_date_num<=20){
                        array_pop($month_origin_arr);//服务开始日期是1~20日，则从当月开始计算业绩
                    }
                }


                $month_origin_nums = sizeof($month_origin_arr);
                if($month_origin_nums<=0){
                    continue;//月份数小于0  下一次循环
                }
                $notax_amount_avg = $notax_amount/$month_origin_nums;
                $tax_amount_avg = $tax_amount/$month_origin_nums;
                $tax_avg = $tax/$month_origin_nums;
                $notax_amount_avg = round($notax_amount_avg,2);
                $tax_amount_avg = round($tax_amount_avg,2);
                $tax_avg = round($tax_avg,2);
                //钱都平摊到每个月，遇到10÷3整除不开的客户说有问题，平摊金额加起来不等于那个产品的金额，他们的意思是，最后一个月的平摊金额等于产品金额减去前面所有月份的金额
                //计算最后一个月的平摊金额
                $notax_amount_avg_thelast = $notax_amount - (($month_origin_nums-1)*$notax_amount_avg);
                $tax_amount_thelast = $tax_amount- (($month_origin_nums-1)*$tax_amount_avg);
                $tax_avg_thelast = $tax- (($month_origin_nums-1)*$tax_avg);
                $this_salesorderid = $this->adb->query_result($result, $i, "salesorderid");
                foreach ($this->showcolLists as $fieldName => $v) {
                    $fieldName = explode(':', $fieldName)[0];
                    $start_len = strpos($fieldName, '_') + 1;
                    $fieldName = substr($fieldName, $start_len);

                    if ($fieldName == 'last_name') {
                        $list[$i][$fieldName] = $last_name;
                    }else if(!in_array($fieldName,['salesorderid','accountid','smownerid','productid','quantity','notax_amount','tax_amount','tax','start_date','end_date'])) {
                        $list[$i][$fieldName] = $this->adb->query_result($result, $i, $fieldName);
                    }

                    if (in_array($fieldName, ['orderamount', 'received_amount', 'receivable_balance', 'invoiceamount', 'nothave_invoicetotal'])) {
                        if($this_salesorderid!=$last_salesorderid){
                            $subTotal[$last_name][$fieldName] += $list[$i][$fieldName];
                            $subTotal["合计"][$fieldName] += $list[$i][$fieldName];
                        }else{
                            $subTotal[$last_name][$fieldName] += 0;
                            $subTotal["合计"][$fieldName] += 0;
                        }
                    }else if($fieldName == 'last_name'){
                        $subTotal[$last_name][$fieldName] = $last_name . '-' . getFixedLabel('SUBTOTAL');
                        $subTotal["合计"][$fieldName] = getFixedLabel('TOTAL');
                    }
                    else if (!in_array($fieldName,['salesorderid','accountid','smownerid','productid','quantity','notax_amount','tax_amount','tax','start_date','end_date'])) {
                        $subTotal[$last_name][$fieldName] = '-';
                        $subTotal["合计"][$fieldName] = '-';
                    }
                }
                //上一个salesorderid 合同订单的金额加和要去重
                $last_salesorderid = $this_salesorderid;
                for($j=0;$j<$month_nums;$j++){
                    if(($month_arr[$j].'-20'>=$start_date&&$month_arr[$j].'-20'<=$end_date)){
                        $end_date_month = $month_origin_arr[$month_origin_nums-1];
                        if($month_arr[$j]==$end_date_month){
                            //计算最后一个月的平摊金额
                            $list[$i][$month_arr[$j].'(不含税)'] = $notax_amount_avg_thelast;
                            $list[$i][$month_arr[$j].'(含税)'] = $tax_amount_thelast;
                            $list[$i][$month_arr[$j].'(税)'] = $tax_avg_thelast;
                            $subTotal[$last_name][$month_arr[$j].'(不含税)'] += $notax_amount_avg_thelast;
                            $subTotal[$last_name][$month_arr[$j].'(含税)'] += $tax_amount_thelast;
                            $subTotal[$last_name][$month_arr[$j].'(税)'] += $tax_avg_thelast;
                            $subTotal["合计"][$month_arr[$j].'(不含税)'] += $notax_amount_avg_thelast;
                            $subTotal["合计"][$month_arr[$j].'(含税)'] += $tax_amount_thelast;
                            $subTotal["合计"][$month_arr[$j].'(税)'] += $tax_avg_thelast;
                        }else{
                            $list[$i][$month_arr[$j].'(不含税)'] = $notax_amount_avg;
                            $list[$i][$month_arr[$j].'(含税)'] = $tax_amount_avg;
                            $list[$i][$month_arr[$j].'(税)'] = $tax_avg;
                            $subTotal[$last_name][$month_arr[$j].'(不含税)'] += $notax_amount_avg;
                            $subTotal[$last_name][$month_arr[$j].'(含税)'] += $tax_amount_avg;
                            $subTotal[$last_name][$month_arr[$j].'(税)'] += $tax_avg;
                            $subTotal["合计"][$month_arr[$j].'(不含税)'] += $notax_amount_avg;
                            $subTotal["合计"][$month_arr[$j].'(含税)'] += $tax_amount_avg;
                            $subTotal["合计"][$month_arr[$j].'(税)'] += $tax_avg;
                        }
                    }else if($month_origin_arr_nums==1&&$month_arr[$j]==$month_origin_arr[0]){
                        //zxm 2022-5-5 bug51414 报表管理——常用报表——视频租赁表，开户申请单明细中，如果服务开始日期跟服务结束日期在同一个月，则算该产品金额平摊到该月中，生成一条报表数据，
                        $list[$i][$month_arr[$j].'(不含税)'] = $notax_amount_avg;
                        $list[$i][$month_arr[$j].'(含税)'] = $tax_amount_avg;
                        $list[$i][$month_arr[$j].'(税)'] = $tax_avg;
                        $subTotal[$last_name][$month_arr[$j].'(不含税)'] += $notax_amount_avg;
                        $subTotal[$last_name][$month_arr[$j].'(含税)'] += $tax_amount_avg;
                        $subTotal[$last_name][$month_arr[$j].'(税)'] += $tax_avg;
                        $subTotal["合计"][$month_arr[$j].'(不含税)'] += $notax_amount_avg;
                        $subTotal["合计"][$month_arr[$j].'(含税)'] += $tax_amount_avg;
                        $subTotal["合计"][$month_arr[$j].'(税)'] += $tax_avg;
                    }else{
                        $list[$i][$month_arr[$j].'(不含税)'] = 0;
                        $list[$i][$month_arr[$j].'(含税)'] = 0;
                        $list[$i][$month_arr[$j].'(税)'] = 0;
                        $subTotal[$last_name][$month_arr[$j].'(不含税)'] += 0;
                        $subTotal[$last_name][$month_arr[$j].'(含税)'] += 0;
                        $subTotal[$last_name][$month_arr[$j].'(税)'] += 0;
                        $subTotal["合计"][$month_arr[$j].'(不含税)'] += 0;
                        $subTotal["合计"][$month_arr[$j].'(含税)'] += 0;
                        $subTotal["合计"][$month_arr[$j].'(税)'] += 0;
                    }
                } 

            }
            $subTotal = array_values($subTotal);

            $list = array_merge($subTotal, $list);
            $sort = _array_column($list, "order");

            array_multisort($sort, SORT_ASC, $list);
			//同步凭证
			if($_REQUEST['getVoucherNum'] == 'yes'){
				$date = date('Y-m-d');
				//$date = '2022-04-11';
				$timestamp=strtotime($date);
				$lastmonth=date('Y-m',strtotime(date('Y',$timestamp).'-'.(date('m',$timestamp)-1).'-01'));
				$key = $lastmonth . '(不含税)';
				foreach($list as $arr){
					if(!empty($arr['salesorderid']) && !empty($arr[$key])){
						$new_list[] = $arr;
					}
				}
				if(isset($_REQUEST['startrow'])){
					$startrow = $_REQUEST['startrow'];
					$res['maxrows'] = sizeOf($new_list);
					$res['selectrows'] = sizeOf($new_list);
					$res['progresstitle'] = '温馨提示';
					//凭证同步类文件
					crm_load_class_file('cls_WeidijiaReportVoucher','modules/OftenUseReport');
					$cls_WeidijiaReportVoucher = new cls_WeidijiaReportVoucher();
					$result = $cls_WeidijiaReportVoucher->setVoucher($new_list[$startrow]);
					$res['message'] = $result;
					echo json_encode($res);exit();
				}
				echo sizeOf($new_list);die;
			}
            foreach ($list as $k => $v) {
                $style = '';
                $class = 'lvtColData';
                if($k%2==0){
                    $class = 'lvtColDataBj';
                }
                if ($v['is_count'] == 1) {
                    $style = "style='background-color:#f0f4fc;'";
                }
				unset($v['sequence_no']);
                $salesorderid = $v['salesorderid'];
                $accountid = $v['accountid'];
                $productid = $v['productid'];
                $module_order = getSalesEntityType($salesorderid);
                $a_order = '<a lasturl="" module="' . $module_order . '" record="' . $salesorderid . '" href="index.php?pageto_module=' . $module_order . '&pageto_action=index&pageto_record=' . $salesorderid . '" onclick="ListLinkClick(ld(this),event)" add_url_getvalue="" title="' . $v['salesorder_no'] . '">' . $v['salesorder_no'] . '</a>';
                $a_account = '<a lasturl="" module="Accounts" record="' . $accountid . '" href="index.php?pageto_module=Accounts&pageto_action=index&pageto_record=' . $accountid . '" onclick="ListLinkClick(ld(this),event)" add_url_getvalue="" title="' . $v['accountname'] . '">' . $v['accountname'] . '</a>';
                $a_product = '<a lasturl="" module="Products" record="' . $productid . '" href="index.php?pageto_module=Products&pageto_action=index&pageto_record=' . $productid . '" onclick="ListLinkClick(ld(this),event)" add_url_getvalue="" title="' . $v['productname'] . '">' . $v['productname'] . '</a>';
                $html .= '<tr id="report_'.$k.'" '.$style.' class="'.$class.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')">';
                foreach ($v as $kk => $vv) {
                    if ($kk != "order" && $kk != "is_count" && $kk != "salesorderid" && $kk != "accountid"&& $kk != "productid"&& $kk != "quantity"&& $kk != "smownerid") {
                        if ($kk == "lineitem_id") {
                            $html .= "<td style='text-align:left' valign='top'>" . $vv . '</td>';
                        }else if ($kk == "salesorder_no") {
                            $html .= "<td style='text-align:left' valign='top'><a href=''>" . $a_order . '</a></td>';
                        } else if ($kk == "accountname") {
                            $html .= "<td style='text-align:left' valign='top'><a href=''>" . $a_account . '</a></td>';
                        }else if ($kk == "productname") {
                            $html .= "<td style='text-align:left' valign='top'><a href=''>" . $a_product . '</a></td>';
                        } else if (in_array($kk, ['orderamount', 'received_amount', 'receivable_balance', 'invoiceamount', 'nothave_invoicetotal'])||is_numeric($vv)) {
                            $html .= "<td style='text-align:right' valign='top'>" . number_format($vv, 2) . '</td>';
                        } else if(!in_array($kk,['salesorderid','accountid','smownerid','type','productid','quantity'])){
                            $html .= "<td style='text-align:left' valign='top'>" . $vv . '</td>';
                        }
                    }
                }
                $html .= "</tr>";

            }
        } else {

            $html .= "<tr>";
            foreach ($this->showcolLists as $fieldName => $v) {
                $html .= "<td style='text-align:left' valign='top'>-</td>";
            }
            $html .= "</tr>";
        }
        return $html;
    }

    public function getVideoRentalSql($whereorder, $data_range)
    {
        $whereorder_str = '';
        if(!empty($whereorder)){
            $whereorder_str = ' and ' . implode(' and ',$whereorder);
        }

        return  "select 
ld_salesorder.salesorderid,
ld_salesorder.salesorder_no,
ld_salesorder.signed_data,
orderdetail.orderamount,
ld_salesorder.received_amount,
ld_salesorder.receivable_balance,
ifnull(invoice.invoiceamount,0)as invoiceamount,
(orderdetail.orderamount-ifnull(invoice.invoiceamount,0) )as nothave_invoicetotal,
ld_salesorder.stockpresence,
ld_salesorder.accountid,
ld_account.accountname,
u.groupname,
ld_users.last_name,
ld_salesorder.smownerid,
ld_products.productname,
ld_outboundorderdetailscf.sf1787 as start_date,
 ld_outboundorderdetailscf.sf1952 as end_date,
ld_outboundorderdetail.productid,
ld_outboundorderdetail.sequence_no,
ld_outboundorderdetail.lineitem_id,
ld_outboundorderdetail.quantity,
ld_outboundorderdetail.listprice,
ld_outboundorder.outdate as outstart_date,
(ld_outboundorderdetail.quantity*ifnull(ld_outboundorderdetail.listprice,0)/ifnull(ld_salesorder.conversion_rate,1))as notax_amount,
ld_outboundorderdetail.tax_amount,
(ld_outboundorderdetail.tax_amount-(ld_outboundorderdetail.quantity*ifnull(ld_outboundorderdetail.listprice,0)/ifnull(ld_salesorder.conversion_rate,1)))as tax
from ld_salesorder 
left join ld_outboundorderdetail on ld_salesorder.salesorderid=ld_outboundorderdetail.entitytypeid 
left join ld_outboundorder on ld_outboundorder.out_id=ld_outboundorderdetail.id 
left join ld_outboundorderdetailscf on ld_outboundorderdetail.lineitem_id=ld_outboundorderdetailscf.lineitem_id
left join ld_products on ld_outboundorderdetail.productid=ld_products.productid
left join  ld_account on ld_salesorder.accountid=ld_account.accountid
left join ld_users on ld_users.id=ld_salesorder.smownerid
left join (
	SELECT
		GROUP_CONCAT(g.groupname, ' ') AS groupname,
		u.id AS userid
	FROM
		ld_users u
	LEFT JOIN ld_users2group ON u.id = ld_users2group.userid
	LEFT JOIN ld_groups g ON g.groupid = ld_users2group.groupid
	GROUP BY
		u.id
) u on ld_salesorder.smownerid=u.userid
left join (
	select sum(ld_invoicedetail.tax_amount)as invoiceamount,ld_invoicedetail.entitytypeid as salesorderid
	from ld_invoicedetail 
	left join ld_invoice on ld_invoice.invoiceid=ld_invoicedetail.id
	left join ld_products on ld_invoicedetail.productid=ld_products.productid
	where ld_invoice.deleted=0 and ld_products.productcategory like '%视频租赁%' and ld_products.productcategory<>'视频租赁收入-腾讯会议' and ld_invoicedetail.entitytype='SalesOrder'
	group by ld_invoicedetail.entitytypeid
)invoice on invoice.salesorderid=ld_salesorder.salesorderid 
left join (
	select sum(ld_salesorderdetail.tax_amount)as orderamount,ld_salesorderdetail.id as salesorderid
	from ld_salesorderdetail 
	left join ld_salesorder on ld_salesorder.salesorderid=ld_salesorderdetail.id
	left join ld_products on ld_salesorderdetail.productid=ld_products.productid 
	where ld_salesorder.deleted=0 and ld_products.productcategory like '%视频租赁%' and ld_products.productcategory<>'视频租赁收入-腾讯会议'
	group by ld_salesorderdetail.id 
) orderdetail on orderdetail.salesorderid=ld_salesorder.salesorderid

where ld_salesorder.deleted=0  $whereorder_str   and FIND_IN_SET(ld_salesorder.smownerid,'$data_range')  and ld_products.productcategory like '%视频租赁%'  and ld_products.productcategory<>'视频租赁收入-腾讯会议'
and orderdetail.orderamount>0 
and ld_outboundorderdetail.entitytype='SalesOrder'
and ld_outboundorder.deleted=0
and ld_outboundorderdetailscf.sf1787 is not null 
and ld_outboundorderdetailscf.sf1787 !='0000-00-00' 
and ld_outboundorderdetailscf.sf1952 is not null
and ld_outboundorderdetailscf.sf1952 !='0000-00-00' 
order by ld_salesorder.smownerid desc,ld_salesorder.salesorderid desc  ";

    }

    //根据起止日期获取月份
    public function dateMonths($start_date,$end_date,$explode='-',$addOne=false){
        $start_date = date('Y-m',strtotime($start_date));

        //判断两个时间是不是需要调换顺序
        $start_int = strtotime($start_date);
        $end_int = strtotime($end_date);
        if($start_int > $end_int){
            $tmp = $start_date;
            $start_date = $end_date;
            $end_date = $tmp;
        }


        //结束时间月份+1，如果是13则为新年的一月份
        $start_arr = explode($explode,$start_date);
        $start_year = intval($start_arr[0]);
        $start_month = intval($start_arr[1]);


        $end_arr = explode($explode,$end_date);
        $end_year = intval($end_arr[0]);
        $end_month = intval($end_arr[1]);


        $data = array();
        $data[] = $start_date;


        $tmp_month = $start_month;
        $tmp_year = $start_year;

        $k=0;
        //如果起止不相等，一直循环
        while (!(($tmp_month == $end_month) && ($tmp_year == $end_year))) {
            $tmp_month ++;
//            if($k>=13)
//            {
//                break;
//            }
            //超过十二月份，到新年的一月份
            if($tmp_month > 12){
                $tmp_month = 1;
                $tmp_year++;
            }
            $k++;
            $data[] = $tmp_year.$explode.str_pad($tmp_month,2,'0',STR_PAD_LEFT);
        }


        if($addOne == true){
            $tmp_month ++;
            //超过十二月份，到新年的一月份
            if($tmp_month > 12){
                $tmp_month = 1;
                $tmp_year++;
            }
            $data[] = $tmp_year.$explode.str_pad($tmp_month,2,'0',STR_PAD_LEFT);
        }
        return $data;
    }

    //产品销售排行榜
    public function ListViewForProductRanking($data_range){
        //单据明细中数量小数位数 tujt 2014-08-14
        $sysdeploy = getSys_deploy(49);
        if (isset($sysdeploy['deploy_value'])) {
            $lengthdecimaldigits = $sysdeploy['deploy_value'];
        }else {
            $lengthdecimaldigits = 2;
        }
        $where = ' where a.deleted=0 ';
        crm_load_class_file('cls_QueryGenerator','modules/OftenUseReport');
        $queryGenerator = new cls_QueryGenerator('', null,'');
        $queryGenerator->addUserSearchConditions($_REQUEST);
        $advsearch = $queryGenerator->getWhereClause();

        $where_product = '';
        if(!empty($advsearch)){
            $where_product .= ' where '.$advsearch;
        }
        //产品名称模糊搜索
        $product_name = $_REQUEST['product_name'];
        if(!empty($product_name)){
            $where_product = empty($where_product)?" where ":" and ";
            $where_product .= "productname like '%$product_name%'";
        }

        //时间搜索条件
        $start_date = $_REQUEST['startmonth'];
        $end_date = $_REQUEST['endmonth'];
        // 只统计审批通过的合同订单与服务订单
        if(isset($_REQUEST['onlyshowapprovecontactandservice'])&&$_REQUEST['onlyshowapprovecontactandservice']=='yes'){
            $where .= " and a.approvestatus='已批准'";
        }
        $where .= " and a.smownerid in (".$data_range.")";

        //排行维度
        $product_ranking_type = $_REQUEST['product_ranking_type'];
        //chj 2021/3/19 45057: （http://81.68.124.239:85/crm [^]）在产品销售排行榜中，自定义日期为2020.1.1-2020.12.31，排行维度为“产品签约数量”时报表中可以搜索到产品“致远OA软件”，排行维度变为“产品签约金额”时报表中搜索不到产品“致远OA软
        //订单：due_date 改成 signed_data
        //币种符号
        //订单金额 订单数量 开票金额  出库数量 出库金额
        $orderby = " order by a.order_count desc ";
        switch ($product_ranking_type){
            case 'productOrderCount':
                $orderby = "  order by a.order_count desc ";
                break;
            case 'productOrderAmount':
                $orderby = "  order by b.order_amount desc ";
                break;
            case 'productInvoiceAmount':
                $orderby = "  order by c.invoice_amount desc ";
                break;
            case 'productOutboundCount':
                $orderby = "  order by d.out_count desc ";
                break;
            case 'productOutboundAmount':
                $orderby = "  order by e.out_amount desc ";
                break;
        }
        $where1 = $where." and a.signed_data between '$start_date' and '$end_date' ";
        $sql1 = "select 
 ifnull(b.quantity,0) as order_count,
 productname,
 productsheet,
 product_no,
 a.productid 
 from 
 (select productname,productsheet,product_no,productid from ld_products $where_product) a left join 
 (select sum(b.quantity) as quantity,b.productid from ld_salesorder a left join 
 ld_salesorderdetail b on a.salesorderid=b.id $where1 group by b.productid) 
 as b on a.productid=b.productid
where ifnull(b.quantity,0)>0 group by a.productid ";
        $where2 = $where." and a.signed_data between '$start_date' and '$end_date' ";
        $sql2 = " select 
 ifnull(b.quantity,0) as order_amount,
 productname,
 productsheet,
 product_no,
 a.productid 
 from 
 (select productname,productsheet,product_no,productid from ld_products $where_product) a left join 
 (select sum(b.quantity*b.taxprice*ifnull(a.conversion_rate,1)) as quantity,b.productid from ld_salesorder a left join 
 ld_salesorderdetail b on a.salesorderid=b.id $where2 group by b.productid) 
 as b on a.productid=b.productid
 where ifnull(b.quantity,0)>0 group by a.productid";
        $where3 = $where." and a.invoicedate between '$start_date' and '$end_date' ";
        $sql3 = "select 
 (ifnull(b.quantity,0)) as invoice_amount,
 productname,
 productsheet,
 product_no,
 a.productid 
 from 
 (select productname,productsheet,product_no,productid from ld_products $where_product) a left join 
 (select sum(b.quantity*b.taxprice*ifnull(a.conversion_rate,1)) as quantity,b.productid from ld_invoice a left join 
 ld_invoicedetail b on a.invoiceid=b.id $where3 group by b.productid) 
 as b on a.productid=b.productid
 where (ifnull(b.quantity,0))>0 group by a.productid";
        $where4 = $where." and a.outdate between '$start_date' and '$end_date' ";
        $sql4 = "select 
 (ifnull(b.quantity,0)) as out_count,
 productname,
 productsheet,
 product_no,
 a.productid 
 from 
 (select productname,productsheet,product_no,productid from ld_products $where_product) a left join 
 (select sum(b.quantity) as quantity,b.productid from ld_outboundorder a left join 
 ld_outboundorderdetail b on a.out_id=b.id $where4 group by b.productid) 
 as b on a.productid=b.productid
  where (ifnull(b.quantity,0))>0 group by a.productid";
        $where5 = $where." and a.outdate between '$start_date' and '$end_date' ";
        $sql5 = "select 
 (ifnull(b.quantity,0)) as out_amount,
 productname,
 productsheet,
 product_no,
 a.productid 
 from 
 (select productname,productsheet,product_no,productid from ld_products $where_product) a left join 
 (select sum(b.quantity*b.taxprice*ifnull(a.conversion_rate,1)) as quantity,b.productid from ld_outboundorder a left join 
 ld_outboundorderdetail b on a.out_id=b.id $where5 group by b.productid) 
 as b on a.productid=b.productid
 where (ifnull(b.quantity,0))>0 group by a.productid";
        //拼接总的sql
        $sql = "select a.*,b.order_amount,c.invoice_amount,d.out_count,e.out_amount from ($sql1)a 
left join ($sql2)b on a.productid=b.productid
left join ($sql3)c on a.productid=c.productid
left join ($sql4)d on a.productid=d.productid
left join ($sql5)e on a.productid=e.productid
".$orderby;
        $res = $this->adb->pquery($sql);
        $nums = $this->adb->num_rows($res);
        $list = [];

        if ($nums > 0) {
            for ($i = 0; $i < $nums; $i++) {
                foreach ($this->showcolLists as $fieldName => $v) {
                    $fieldName = explode(':', $fieldName)[0];
                    $start_len = strpos($fieldName, '_') + 1;
                    $fieldName = substr($fieldName, $start_len);
                    $list[$i][$fieldName] = $this->adb->query_result($res, $i, $fieldName);
                }
            }
            $html = "<tr>";
            foreach ($list as $k => $v) {
                $class = 'lvtColData';
                if($k%2==0){
                    $class = 'lvtColDataBj';
                }
                $html .= '<tr id="report_'.$k.'" class="'.$class.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')">';
                foreach ($v as $kk => $vv) {
                    if(in_array($kk,["order_count","order_amount","invoice_amount","out_count","out_amount"])){
                        if(in_array($kk,['order_count','out_count'])){
                            $vv = number_format($vv,$lengthdecimaldigits);
                        }else{
                            $vv = '￥'.number_format($vv,2);
                        }
                    }
                    if($kk == "productid"){
                        $vv = $k+1;
                    }
                    $html .= "<td style='text-align:left;' valign='top'>" . $vv . '</td>';
                }
                $html .= "</tr>";
            }
        }else{
            $html = "<tr>";
            foreach($this->showcolLists  as $fieldName=>$v){
                $html .= "<td style='text-align:left' valign='top'>-</td>";
            }
            $html .= "</tr>";
        }
        return $html;

    }
}