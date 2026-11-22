<?php
	error_reporting(E_ALL & ~E_NOTICE);
	//表单登录验证
	include('includefile.php');
	header("Content-type: text/html; charset=utf-8");
	global $theme;
	global $adb;
	@session_start();
	if(!empty($_SESSION['huawan_account_id'])){		
		$query = "SELECT
						b.productid,
						c.productname,
						a.total as after_total,
						'¥' as currency_symbol,
						a.signed_data,
						DATE_SUB(DATE_ADD(a.signed_data,INTERVAL d.cf_1784 MONTH),INTERVAL 1 DAY) end_date,
						ifnull(e.divid_total,0) as cashmoney,
						f.cashmoney as money,
						f.plandividend_date,
						'¥' as symbol,
						a.salesorderid
					FROM ld_salesorder a
					LEFT JOIN ld_salesordercf d on d.salesorderid=a.salesorderid
					LEFT JOIN ld_inventoryproductrel b ON a.salesorderid=b.id
					LEFT JOIN ld_products c ON c.productid=b.productid
					LEFT JOIN (
						SELECT
							salesorderid,
							sum(cashmoney) as divid_total
						FROM ld_dividendorder
						WHERE deleted=0
							AND `status`= '已派'
						GROUP BY salesorderid 
					) e ON e.salesorderid=a.salesorderid
					LEFT JOIN (
						SELECT DISTINCT 
							*	
						FROM (
							SELECT
								salesorderid,
								plandividend_date,
								cashmoney
							FROM ld_dividendorder
							WHERE deleted=0
								AND `status`= '未派'
							ORDER BY plandividend_date) a
					) f ON f.salesorderid=a.salesorderid
					WHERE a.deleted=0
						AND d.cf_1784>0
						AND a.accountid in (select accountid from ld_account where right(license_no,6)=(select right(license_no,6) from ld_account where accountid=?))
					GROUP BY salesorderid
					ORDER BY a.signed_data";
		

		$result = $adb->pquery($query,array($_SESSION['huawan_account_id']));
		
		//echo $_SESSION['huawan_account_id'].'<br/>';
		//echo $query;
		$num_rows=$adb->num_rows($result);
		for($i = 0; $i<$num_rows; $i++){
			$res[$i]['productid'] = $adb->query_result($result,$i,'productid');
			$res[$i]['productname'] = $adb->query_result($result,$i,'productname');
			$res[$i]['after_total'] = $adb->query_result($result,$i,'currency_symbol') . number_format($adb->query_result($result,$i,'after_total'),2);
			$res[$i]['signed_data'] = $adb->query_result($result,$i,'signed_data');
			$res[$i]['end_date'] = $adb->query_result($result,$i,'end_date');
			$res[$i]['cashmoney'] = '¥' . number_format($adb->query_result($result,$i,'cashmoney'),2);
			if ($adb->query_result($result,$i,'plandividend_date')!=''){
				$res[$i]['money'] = $adb->query_result($result,$i,'symbol') . number_format($adb->query_result($result,$i,'money'),2);			
			}else{
				$res[$i]['money'] = '';
			}
			$res[$i]['plandividend_date'] = $adb->query_result($result,$i,'plandividend_date');
			$res[$i]['symbol'] = $adb->query_result($result,$i,'symbol');
			$res[$i]['salesorderid'] = $adb->query_result($result,$i,'salesorderid');
		}
		
		$query = 'select accountname,license_no from ld_account where accountid = ? limit 1';
		$result = $adb->pquery($query,array($_SESSION['huawan_account_id']));
		$accountname = $adb->query_result($result,0,'accountname');
		$license_no = $adb->query_result($result,0,'license_no');

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
<div class="huawan_quit" onclick="history.back(-1);">退出</div>
<div class="huawan_con">
    <div class="list-title">投资产品及派息信息查询</div>
    <div>
        <ul class="list-info" style="float: left;">
    		<li>基本信息</li>
    		<li class="a"><span>姓&nbsp;&nbsp;&nbsp;&nbsp;名</span><?php echo $accountname;?></li>
    		<li class="a"><span>身份证号</span><?php echo $license_no;?></li>
    		<li>已购产品</li>
    	</ul>
        <div class="junji_zixun">
            <div style="padding: 10px;">
                <div align="center" style="padding-bottom: 5px; font-size:15px; font-weight: bold;">君寄资讯</div>
                <div><a align="center" style="color: #317EE3; font-size:14px;" href="junjiinfos.php">资讯内容</a></div>
            </div>
        </div>
    </div>
	<div style="clear:both"></div>
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
		<?php
			foreach($res as $res_info){
				echo '<tr>';
				echo '<td>' . $res_info['productname'] . '</td>';
				echo '<td align="right">' . $res_info['after_total'] . '</td>';
				echo '<td>' . $res_info['signed_data'] . '</td>';
				echo '<td>' . $res_info['end_date'] . '</td>';
				echo '<td align="right">' . $res_info['cashmoney'] . '</td>';
				echo '<td>' . $res_info['plandividend_date'] . '</td>';
				echo '<td align="right">' . $res_info['money'] . '</td>';
				
				$salesorderid = $res_info['salesorderid'];
				echo '<td align="center"><a id="list-details-button" href=\'javascript:void(0)\' onclick="list_detail('.$res_info['salesorderid'].')">派息历史</td>';
				echo '</tr>';
			}
		?>
		</table>
		
	</div>
</div>
<script>
	function list_detail(salesorderid){
	   if(salesorderid !=''){
			window.open("junjidetails.php?salesorderid="+salesorderid,"html_name","width=600,height=600,top=100,toolbar=no,location=no,status=no");
	   }
	}
</script>
</body>
</html>