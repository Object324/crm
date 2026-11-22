<?php
	error_reporting(E_ALL & ~E_NOTICE);
	//表单登录验证
	include('includefile.php');
	header("Content-type: text/html; charset=utf-8");
	global $theme;
	global $adb;
	@session_start();
	if(!empty($_SESSION['huawan_account_id']) && !empty($_REQUEST['salesorderid'])){
		$query = "select 
					dividendorderid,
					plandividend_date,
					cashmoney,
					dividend_no,
					ld_users.last_name,
					banknum,
					bankcard_no,
					bankname,
					currency_symbol 
				from 
					ld_dividendorder
				LEFT JOIN ld_users ON ld_users.id = ld_dividendorder.smownerid
				WHERE ld_dividendorder.deleted = 0
					AND ld_dividendorder.salesorderid = ?
					AND ld_dividendorder.plandividend_date <= CURDATE()
					AND ld_dividendorder.`status` = '已派'";
		//echo $query;
		$result = $adb->pquery($query,array($_REQUEST['salesorderid']));
		$num_rows = $adb->num_rows($result);
		for($i = 0; $i<$num_rows; $i++){
			$res[$i]['plandividend_date'] = $adb->query_result($result,$i,'plandividend_date');
			$res[$i]['dividend_no'] = $adb->query_result($result,$i,'dividend_no');
			$res[$i]['cashmoney'] = number_format($adb->query_result($result,$i,'cashmoney'),2);
			$res[$i]['last_name'] = $adb->query_result($result,$i,'last_name');
			$res[$i]['banknum'] = $adb->query_result($result,$i,'banknum');
			$res[$i]['bankcard_no'] = $adb->query_result($result,$i,'bankcard_no');
			$res[$i]['bankname'] = $adb->query_result($result,$i,'bankname');
			$res[$i]['currency_symbol'] = $adb->query_result($result,$i,'currency_symbol');
		}
	}else{
		unset($_SESSION['huawan_account_id']);
		header("Location:junjilogin.php");
	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>君寄金融</title>
<meta name="keywords" content="上海君寄金融信息服务有限公司 君寄金融 上海君寄 君寄" />
<meta name="description" content="" />
<script src="junjigroup/js/jquery-1.11.2.min.js" type="text/javascript"></script>

<link rel="stylesheet" type="text/css"  href="junjigroup/css/style.css"/>
</head>
<body>
	<div class="huawan_log"></div>
    <div class="huawan_con">
		<div class="list-title">历史派息信息查询</div>
		<table class="huwan-table" width="90%" border="0" cellspacing="1" cellpadding="0" align="left">
		<tr>
			<th>派息日期</th>
			<th>派息金额</th>
			<th>派息单编号</th>
			<th>负责人</th>
			<th>银行账户</th>
			<th>银行卡号</th>
			<th>开户银行</th>
		</tr>
		<?php
			if(count($res) > 0){
				foreach($res as $res_info){
					echo '<tr>';
					echo '<td>' . $res_info['plandividend_date'] . '</td>';
					echo '<td align="center">' . $res_info['currency_symbol'] . $res_info['cashmoney'] . '</td>';
					echo '<td>' . $res_info['dividend_no'] . '</td>';
					echo '<td>' . $res_info['last_name'] . '</td>';
					echo '<td>' . $res_info['banknum'] . '</td>';
					echo '<td>' . $res_info['bankcard_no'] . '</td>';
					echo '<td>' . $res_info['bankname'] . '</td>';
					echo '</tr>';
				}
			}else{
				echo '<tr>';
				echo '<td colspan="7" align="center">没有找到任何记录!</td>';
				echo '</tr>';
			}	
		?>
		</table>
	</div>
</div>
</body>
</html>