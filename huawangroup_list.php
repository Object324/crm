<?php
	error_reporting(E_ALL & ~E_NOTICE);
	//表单登录验证
	include('includefile.php');
	header("Content-type: text/html; charset=utf-8");
	global $theme;
	global $adb;
	@session_start();
	if(!empty($_SESSION['huawan_account_id'])){
		$query = 'select 
			ld_products.productid,
			ld_products.productname,
			ld_buyproducthistory.after_total,
			ld_salesorder.currency_symbol,
			sales_data.signed_data,
			sales_data.end_date,
			temp1.cashmoney,
			temp2.money,
			temp2.plandividend_date,
			temp2.symbol
		from ld_buyproducthistory
		inner join(
			select max(id) as idd,productid 
				from 
			ld_buyproducthistory 
			WHERE ld_buyproducthistory.accountid=?
			group by productid
		)as tmp on tmp.idd=ld_buyproducthistory.id 
		left JOIN(
			select signed_data,end_date,salesorderid,ld_inventoryproductrel.productid from ld_salesorder
			LEFT JOIN ld_inventoryproductrel on ld_inventoryproductrel.id = ld_salesorder.salesorderid where accountid = ? ORDER BY createdtime desc limit 1
		) as sales_data on sales_data.productid = ld_buyproducthistory.productid 
		left JOIN(
			select sum(if(ld_dividendorder.currency_id > 1,ifnull(ld_dividendorder.cashmoney,0)/ld_dividendorder.conversion_rate,ifnull(ld_dividendorder.cashmoney,0))) as cashmoney,dividendorderid,product_id from ld_dividendorder 
			where plandividend_date <= CURDATE() and accountid = ? and `status` = \'已派\'
		) as temp1 on temp1.product_id = ld_buyproducthistory.productid 
		LEFT JOIN(
			select cashmoney as money,plandividend_date,dividendorderid,product_id,ld_dividendorder.currency_symbol as symbol from ld_dividendorder 
			where plandividend_date >= CURDATE() and accountid = ? and `status` = \'未派\' order by plandividend_date asc limit 1
		) as temp2 on temp2.product_id = ld_buyproducthistory.productid 
		INNER JOIN ld_products ON ld_buyproducthistory.productid=ld_products.productid
		LEFT JOIN ld_salesorder on ld_salesorder.salesorderid = ld_buyproducthistory.salesorderid
		WHERE ld_buyproducthistory.accountid=?
		order by ld_products.productname';
		$result = $adb->pquery($query,array($_SESSION['huawan_account_id'],$_SESSION['huawan_account_id'],$_SESSION['huawan_account_id'],$_SESSION['huawan_account_id'],$_SESSION['huawan_account_id']));
		$num_rows = $adb->num_rows($result);
		for($i = 0; $i<$num_rows; $i++){
			$res[$i]['productid'] = $adb->query_result($result,$i,'productid');
			$res[$i]['productname'] = $adb->query_result($result,$i,'productname');
			$res[$i]['after_total'] = $adb->query_result($result,$i,'currency_symbol') . number_format($adb->query_result($result,$i,'after_total'),2);
			$res[$i]['signed_data'] = $adb->query_result($result,$i,'signed_data');
			$res[$i]['end_date'] = $adb->query_result($result,$i,'end_date');
			$res[$i]['cashmoney'] = '¥' . number_format($adb->query_result($result,$i,'cashmoney'),2);
			$res[$i]['money'] = $adb->query_result($result,$i,'symbol') . number_format($adb->query_result($result,$i,'money'),2);
			$res[$i]['plandividend_date'] = $adb->query_result($result,$i,'plandividend_date');
			$res[$i]['symbol'] = $adb->query_result($result,$i,'symbol');
		}
		$query = 'select accountname,license_no from ld_account where accountid = ? limit 1';
		$result = $adb->pquery($query,array($_SESSION['huawan_account_id']));
		$accountname = $adb->query_result($result,0,'accountname');
		$license_no = $adb->query_result($result,0,'license_no');
	}else{
		unset($_SESSION['huawan_account_id']);
		header("Location:huawangroup_login.php");
	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>华万控股集团</title>
<meta name="keywords" content="华万集团 华万控股 华万控股集团 北京华万 华万基金 华万" />
<meta name="description" content="" />
<script src="huawangroup/js/jquery-1.11.2.min.js" type="text/javascript"></script>

<link rel="stylesheet" type="text/css"  href="huawangroup/css/style.css"/>
</head>
<body>
<div class="huawan_log"></div>
<div class="huawan_quit" onclick="history.back(-1);">退出</div>
<div class="huawan_con">
    <div class="list-title">投资产品及派息信息查询</div>
	<ul class="list-info">
		<li>基本信息</li>
		<li class="a"><span>姓&nbsp;&nbsp;&nbsp;&nbsp;名</span><? echo $accountname;?></li>
		<li class="a"><span>身份证号</span><? echo $license_no;?></li>
		<li>已购产品</li>
	</ul>
	<div class="list-table">
		<table class="huwan-table" width="90%" border="0" cellspacing="1" cellpadding="0" align="left">
		<tr>
			<th>所投产品名称</th>
			<th>投入本金</th>
			<th>实际入金时间</th>
			<th>到期时间</th>
			<th>已派息总额</th>
			<th>下次派息日</th>
			<th>下次派息金额</th>
			<th style="text-align:center;">操作</th>
		</tr>
		<?
			foreach($res as $res_info){
				echo '<tr>';
				echo '<td>' . $res_info['productname'] . '</td>';
				echo '<td align="right">' . $res_info['after_total'] . '</td>';
				echo '<td>' . $res_info['signed_data'] . '</td>';
				echo '<td>' . $res_info['end_date'] . '</td>';
				echo '<td align="right">' . $res_info['cashmoney'] . '</td>';
				echo '<td>' . $res_info['plandividend_date'] . '</td>';
				echo '<td align="right">' . $res_info['money'] . '</td>';
				$productid = $res_info['productid'];
				echo '<td align="center"><a id="list-details-button" href=\'javascript:void(0)\' onclick="list_detail('.$res_info['productid'].')">派息历史</td>';
				echo '</tr>';
				// 
			}
		?>
		</table>
		
	</div>
</div>
<script>
	function list_detail(productid){
	   if(productid !=''){
			window.open("huawangroup_details.php?productid="+productid,"html_name","width=600,height=600,top=100,toolbar=no,location=no,status=no");
	   }
	}
</script>
</body>
</html>