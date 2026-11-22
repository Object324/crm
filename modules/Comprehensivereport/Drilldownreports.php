<?php
global $adb,$mod_strings;
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$smarty=new lingdangCRM_Smarty();
//echo $_REQUEST['search_text'];
if(isset($_REQUEST['year']) && isset($_REQUEST['month']))
{
     if(is_int(intval($_REQUEST['year']))==false)
    {
        
        echo '报表年份错误！';
        exit();
    }
    
    if(intval($_REQUEST['year'])>date('Y'))
    {
        echo '报表年份错误！';
        exit();
    }
    if(intval($_REQUEST['month'])<0 ||intval($_REQUEST['month'])>12)
    {
        echo '报表月份错误！';
        exit();
    }
    
    $year = $_REQUEST['year'];
    $month = $_REQUEST['month'];
}


if(isset($_REQUEST['begin_date']) && isset($_REQUEST['end_date'])){
    $begin_date = $_REQUEST['begin_date'];
    $end_date = $_REQUEST['end_date'];
}
$prowhere=' ';
if(isset($_REQUEST['search_text'])&&$_REQUEST['search_text']<>''){
    $prolisgs = explode(',',$_REQUEST['search_text']);
    $prolisgs = implode("','",$prolisgs);
    $prowhere .= " AND e.productname in ('$prolisgs')";
}
if(isset($_REQUEST['search_text2'])&&$_REQUEST['search_text2']<>''){
    $prolisgs = explode(',',$_REQUEST['search_text2']);
    $prolisgs = implode("','",$prolisgs);
    $prowhere .= " AND b.accountname in ('$prolisgs')";
}
if(isset($_REQUEST['search_text3'])&&$_REQUEST['search_text3']<>''){
    $prolisgs = explode(',',$_REQUEST['search_text3']);
    $prolisgs = implode("','",$prolisgs);
    $prowhere .= " AND ld_salesordercf.cf_1158 in ('$prolisgs')";
}
if(isset($_REQUEST['search_text4'])&&$_REQUEST['search_text4']<>''){
    $prolisgs = explode(',',$_REQUEST['search_text4']);
    $prolisgs = implode("','",$prolisgs);
    $prowhere .= " AND ld_salesordercf.cf_1159 in ('$prolisgs')";
}
$salesList = getSalesorderList($month,$year,$begin_date,$end_date,$prowhere);
$Plist = getProList();
$Alist = getAccList();
$Slist = getSector();
$Salist = getSalesman();
//print_r($Plist);
        $g=0;
        foreach($salesList as $key=>$arr){
            for($i=0;$i<count($salesList['list']);$i++){
            if($salesList['list'][$i]['salesorder_no'] == $salesList['list'][$i-1]['salesorder_no'])
               {
                 $g++;
                 $salesList['list'][$i]['rowspan']=$g+1;
                 $salesList['list'][$i-1]['rowspan']=0;
               }else{
                $g=0;
                $salesList['list'][$i]['rowspan']='####error';
               }
            }
            
    $acount = count($salesList['list']);
    for($c=0;$c<$acount;$c++){
        for($j=0;$j<$acount-$c-1;$j++){
            if($salesList['list'][$j]['salesorder_no']==$salesList['list'][$j+1]['salesorder_no']){
                if($salesList['list'][$j]['rowspan']<$salesList['list'][$j+1]['rowspan']){
                    $temp = $salesList['list'][$j];
                    $salesList['list'][$j] = $salesList['list'][$j+1];
                    $salesList['list'][$j+1] = $temp;
                }
            }
        } 
    }
          } 
          
          //print_r($salesList);
if(!isset($_REQUEST['begin_date']) && !isset($_REQUEST['end_date'])){
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
	
    $begin_date = "";
    $begin_date = "".$year."-".formatMonth($begin_month)."-01";  
    $end_date = "";
    $lastday=getthemonth($year."-".$end_month.'-1');
    $arrlastday=explode('-',$lastday);
    $lastday=$arrlastday[2];
    $end_date = "".$year."-".formatMonth($end_month)."-".$lastday;
}
function getSalesorderList($month,$year,$begin_date,$end_date,$prowhere){
    
    global $adb;
    if($month==0){
        $month=12;
    }
    if(isset($begin_date) && isset($end_date)){
        $where = " AND signed_data between '".$begin_date."' and '".$end_date."'";
    }else{
        $where = " AND MONTH(signed_data)=$month AND YEAR(signed_data)=$year"; 
    }

    
    $sql="select 
    t.*, case t.tejia 
    when 0 then 
    ifnull(round( 
    t.salesamount * ifnull(t.cf_1265,0) *0.01 , 
    2 
    ),0) 
    else 
   	ifnull(
		round(
			t.salesamount * 0.01 ,
			2
		),
		0
	)
    end as fandian ,
    CASE t.tejia
WHEN 0 THEN
	ifnull(
		round(
			t.salesamount *  t.discount_rate * ifnull(t.cf_1266, 0)*0.01*0.01 + 0.000001,
			2
		),
		0
	)
ELSE
0
END AS zhichifeiyong
    from 
    ( 
    select 
    a.signed_data,
    ld_salesordercf.cf_1158,
    ld_salesordercf.cf_1159, 
    r.cf_1265,
    r.cf_1266,
    c.listprice,
    a.salesorder_no, 
    b.accountname, 
    e.productname, 
    b.discount_rate,
    round(c.quantity + 0.000001, 2) as quantity, 
    round(CASE c.productcost
WHEN 0 THEN
	e.costprice 
ELSE
	c.productcost
END + 0.000001, 2)*round(c.quantity + 0.000001, 2) as cost, 
    ifnull( 
    round(b.discount_rate + 0.000001, 2), 
    0 
    ) as account_rate, 
    ifnull(d.sf3, 0) as tejia, 
CASE ifnull(b.discount_rate, 0)
		WHEN 0 THEN
			round(
				100 - ifnull(c.discount_amount, 0) * 100 / c.listprice / c.quantity,
				2
			)
		ELSE
			round(
				100 - ifnull(b.discount_rate, 0) + 0.000001,
				2
			)
		END AS discount_percen, 
    round( 
    ( 
    100 + ifnull(c.tax1, 0) + ifnull(c.tax2, 0) + ifnull(c.tax3, 0) 
    ) * ( 
    round( 
    c.quantity * c.listprice + 0.000001, 
    2 
    ) - round( 
    c.quantity * c.listprice * ifnull(c.discount_percent, 0) * 0.01 + 0.000001, 
    2 
    ) 
    ) * 0.01 + 0.000001, 
    2 
    ) as salesamount 
    from 
    ld_salesorder as a 
    left join ld_account as b on a.accountid = b.accountid 
   	LEFT JOIN ld_accountscf AS r ON a.accountid = r.accountid 
    INNER JOIN ld_salesordercf ON ld_salesordercf.salesorderid = a.salesorderid
    left join ld_salesorderdetail as c on a.salesorderid = c.id 
    left join ld_salesorderdetailscf as d on c.lineitem_id = d.lineitem_id 
    left join ld_products as e on c.productid=e.productid 
    where a.deleted=0 and a.sostatus<>'已作废' $where $prowhere
    ) as t ORDER BY salesorder_no,signed_data;";
//echo $sql;
    $result=$adb->pquery($sql,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
        $quantity = $adb->query_result($result, $i, 'quantity');
        $total = $adb->query_result($result, $i, 'salesamount');
        $productcost = $adb->query_result($result, $i, 'cost');
        $listprice =$adb->query_result($result, $i, 'fandian');
        $zhichifeiyong =$adb->query_result($result, $i, 'zhichifeiyong');
        
        $list['list'][$i]['signed_data'] = $adb->query_result($result, $i, 'signed_data');
        $list['list'][$i]['salesorder_no'] = $adb->query_result($result, $i, 'salesorder_no');
        $list['list'][$i]['accountname'] = $adb->query_result($result, $i, 'accountname');
        $list['list'][$i]['productname'] = $adb->query_result($result, $i, 'productname');
        $list['list'][$i]['cf_1158'] = $adb->query_result($result, $i, 'cf_1158');
        $list['list'][$i]['cf_1159'] = $adb->query_result($result, $i, 'cf_1159');
        $list['list'][$i]['listprice'] = number_format($listprice,2);
        $list['list'][$i]['quantity'] = number_format($quantity,2);
        $list['list'][$i]['total'] = number_format($total,2);
        $list['list'][$i]['productcost'] = number_format($productcost,2);
        $list['list'][$i]['zhichifeiyong'] = number_format($zhichifeiyong,2);
        $productcost_all +=$productcost;
        $total_all +=$total;
        $listprice_all +=$listprice;
        $zhichifeiyong_all +=$zhichifeiyong;
        }
        $list['r']['total_all'] =number_format($total_all,2);
        $list['r']['productcost_all'] =number_format($productcost_all,2);
        $list['r']['listprice_all'] =number_format($listprice_all,2);
        $list['r']['zhichifeiyong_all'] =number_format($zhichifeiyong_all,2);
    return $list;
}

function getProList(){
    global $adb;
    $SQL = "SELECT ld_inventoryproductrel.productid,ld_products.productname FROM ld_inventoryproductrel 
    LEFT JOIN ld_products ON ld_products.productid = ld_inventoryproductrel.productid 
    WHERE ld_inventoryproductrel.productid<>'' 
    GROUP BY ld_inventoryproductrel.productid";

    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $productid = $adb->query_result($result, $i, 'productname');
        $proList[$productid] = $adb->query_result($result, $i, 'productid');
    }
    
    return $proList;
}

function getAccList(){
    global $adb;
    $SQL = "SELECT 	ld_account.accountname,ld_account.accountid FROM ld_salesorder 
    LEFT JOIN ld_account ON ld_account.accountid = ld_salesorder.accountid 
    WHERE ld_account.accountid<>'' 
    GROUP BY ld_salesorder.accountid ";
    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $accountid = $adb->query_result($result, $i, 'accountname');
        $AccList[$accountid] = $adb->query_result($result, $i, 'accountid');
    }
    
    return $AccList;
}
//部门
function getSector(){
    global $adb;
    $SQL = "SELECT cf_1158id,cf_1158 from ld_cf_1158";
    
    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $cf_1159id = $adb->query_result($result, $i, 'cf_1158id');
        $SectorList[$cf_1159id] = $adb->query_result($result, $i, 'cf_1158');
    }
    
    return $SectorList;
}
//业务员
function getSalesman(){
    global $adb;
    $SQL = "SELECT cf_1159id,cf_1159 from ld_cf_1159";
    
    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $cf_1159id = $adb->query_result($result, $i, 'cf_1159id');
        $SalesmanList[$cf_1159id] = $adb->query_result($result, $i, 'cf_1159');
    }
    
    return $SalesmanList;
}
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
//print_r($salesList['slist']);
//页面赋值
$smarty->assign("YEAR",$year);//年
$smarty->assign("MONTH",$month);
$smarty->assign("uPRODUCTS",$_REQUEST['search_text']);
$smarty->assign("uCustomer",$_REQUEST['search_text2']);
$smarty->assign("uSector",$_REQUEST['search_text3']);
$smarty->assign("uSalesman",$_REQUEST['search_text4']);
$smarty->assign("begin_date",$begin_date);
$smarty->assign("end_date",$end_date);
$smarty->assign("salesList",$salesList['list']);
$smarty->assign("count_num",count($Plist));
$smarty->assign("Acount_num",count($Alist));
$smarty->assign("Sector_num",count($Slist));
$smarty->assign("Salesman_num",count($Salist));
$smarty->assign("r_total",$salesList['r']);
$smarty->assign("productlist",$Plist);
$smarty->assign("accountlist",$Alist);
$smarty->assign("Sectorlist",$Slist);
$smarty->assign("Salesmanlist",$Salist);
$smarty->display('Comprehensivereport/Drilldownreports.tpl');
exit();
?>