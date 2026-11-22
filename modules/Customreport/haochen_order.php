<?php
global $adb,$theme,$current_user;
$smarty=new lingdangCRM_Smarty();
$is_ajax = $_REQUEST['is_ajax'];
$date = date('Y-m-d');
if(!empty($_REQUEST['voucher_startdate'])){
	$start_date = $_REQUEST['voucher_startdate'];
}else{
	$start_date = date('Y-m-01');
}
if(!empty($_REQUEST['voucher_enddate'])){
	$end_date = $_REQUEST['voucher_enddate'];
}else{
	$end_date = date('Y-m-d', strtotime("$start_date +1 month -1 day"));
}
$smarty->assign('STARTDATE',$start_date);
$smarty->assign('ENDDATE',$end_date);
$limit = 15;
$page = $_REQUEST['page'];
$page = empty($page)?1:$page;
if(!empty($_REQUEST['zuofei']) && $_REQUEST['zuofei'] == 'yes'){
	$record = $_REQUEST['record'];
	$id = $_REQUEST['id'];
	if(!empty($record)){
		$query = "update ld_quotescf set cf_2796 = '作废',zuofeiren=? where quoteid = ?";
		$adb->pquery($query,array($current_user->id,$record));
		$query = "update ld_customform14scf 
		INNER JOIN ld_quotes on ld_quotes.source_list = ld_customform14scf.customform14id 
		set hetong_zhuangtai = '作废',zuofeiren=? where ld_quotes.quoteid = ?";
		$adb->pquery($query,array($current_user->id,$record));
	}else{
		$query = "update ld_cundang set zhuangtai = '作废',zuofeiren=? where id = ?";
		$adb->pquery($query,array($current_user->id,$id));
	}

	ConvertTojsonString(1,array(),"success");
}
$query = "select id,last_name from ld_users";
$result = $adb->pquery($query,array());
if($adb->num_rows($result)){
	for($i = 0; $i<$adb->num_rows($result); $i++){
		$id = $adb->query_result($result,$i,'id');
		$last_name = $adb->query_result($result,$i,'last_name');
		$users[$id] = $last_name;
	}
}
$smarty->assign('USERS',$users);
$where = " where sign_date >= '".$start_date."' and sign_date <= '".$end_date."'";
//合同状态
if(!empty($_REQUEST['zhuangtai'])){
	if($_REQUEST['zhuangtai'] == 'zhengchang'){
		$_REQUEST['zhuangtai'] = '正常';
	}else{
		$_REQUEST['zhuangtai'] = '作废';
	}
	$where .= " and (zhuangtai = '".$_REQUEST['zhuangtai']."' or cf_2796 = '".$_REQUEST['zhuangtai']."')";
}
//拆分状态
if(!empty($_REQUEST['chaifen'])){
	if($_REQUEST['chaifen'] == 'weichaifen'){
		$_REQUEST['chaifen'] = '未拆分';
	}else{
		$_REQUEST['chaifen'] = '已拆分';
	}
	$where .= " and (quotestage = '".$_REQUEST['chaifen']."')";
}
//负责人
if(!empty($_REQUEST['userid'])){
	$where .= " and (ld_cundang.userid = '".$_REQUEST['userid']."')";
}
//存档号或者合同编号查找
if(!empty($_REQUEST['order_no'])){
	$where .= " and (order_no like '%".$_REQUEST['order_no']."%' or cundanghao like '%".$_REQUEST['order_no']."%')";
}

$query = "
	select ld_cundang.id,cundanghao,order_no,ld_cundang.createdtime,sign_date,last_name,accountname,cf_2796,recordid,zhuangtai,ld_cundang.zuofeiren,ld_quotescf.zuofeiren as quote_zuofeiren,ld_quotes.source_list  
	from ld_cundang 
	left join ld_quotes on ld_quotes.quoteid = ld_cundang.recordid 
	LEFT JOIN ld_quotescf on ld_quotes.quoteid = ld_quotescf.quoteid 
	left join ld_account on ld_account.accountid = ld_quotes.accountid 
	left join ld_users on ld_users.id = ld_cundang.userid $where 
";

$query .= "ORDER BY ld_cundang.id asc";
//echo $query;echo '<br><br>';
$result = $adb->pquery($query,array());
$total_nums = $adb->num_rows($result);
$total_pages = ceil($total_nums/$limit);
if($total_pages<=$page){
	$page = $total_pages;
}
$page_start = ($page-1)*$limit;
if($_REQUEST['is_export'] != "yes"){
	$query .= " limit $page_start,$limit ";
}
//echo $query;echo '<br><br>';
$result = $adb->pquery($query,array());
if($adb->num_rows($result) >= 1){
	for($i = 0; $i < $adb->num_rows($result); $i++){
		$cundanghao = $adb->query_result($result,$i,'cundanghao');
		$order_no = $adb->query_result($result,$i,'order_no');
		$createdtime = $adb->query_result($result,$i,'createdtime');
		$sign_date = $adb->query_result($result,$i,'sign_date');
		$last_name = $adb->query_result($result,$i,'last_name');
		$accountname = $adb->query_result($result,$i,'accountname');
		$recordid = $adb->query_result($result,$i,'recordid');
		$id = $adb->query_result($result,$i,'id');
		$zhuangtai = $adb->query_result($result,$i,'zhuangtai');
		$cf_2796 = $adb->query_result($result,$i,'cf_2796');	//合同状态
		$zuofeiren = $adb->query_result($result,$i,'zuofeiren');
		$quote_zuofeiren = $adb->query_result($result,$i,'quote_zuofeiren');
		$source_list = $adb->query_result($result,$i,'source_list');
		
		if(!empty($recordid)){
			$fangshi = '系统生成';
			$zhuangtai = $cf_2796;
			$caozuo = getUserFullName($quote_zuofeiren);
		}else{
			$fangshi = '手动生成';
			$last_name = '--';
			$accountname = '--';
			$caozuo = getUserFullName($zuofeiren);
		}
		$data[] = array(
			'order_no' => $order_no,
			'bianhao' => $cundanghao,
			'sign_date' => $sign_date,
			'last_name' => $last_name,
			'createdtime' => $createdtime,
			'accountname' => $accountname,
			'zhuangtai' => $zhuangtai,
			'fangshi' => $fangshi,
			'recordid' => $recordid,
			'id' => $id,
			'caozuo' => $caozuo,
			'source_list' => $source_list
		);
	}
}
$smarty->assign('WIDTH',$_SESSION['bodywidth']);
$smarty->assign('LISTENTITY',$data);
$smarty->assign('DATALENGTH',sizeOf($data));
$smarty->assign('USERS',$users);
$prevpage = 'no';
$nextpage = 'no';
if($page == 1 && $total_pages > $page){
	$nextpage = 'yes';
}
if($page > 1){
	if($page < $total_pages){
		$prevpage = 'yes';
		$nextpage = 'yes';
	}
	if($page == $total_pages){
		$prevpage = 'yes';
	}
}
$smarty->assign('PREVPAGE',$prevpage);
$smarty->assign('NEXTPAGE',$nextpage);
$smarty->assign('total_nums',$total_nums);
$smarty->assign('total_pages',$total_pages);
$smarty->assign('PAGE',$page);
$_REQUEST['diony'] = 'yes';
$kuandu = ceil(($_SESSION['bodywidth']-50)/9);
$header[] = array('label' => '合同编号','width' => $kuandu);
$header[] = array('label' => '存档号','width' => $kuandu);
$header[] = array('label' => '签订日期','width' => $kuandu);
$header[] = array('label' => '销售负责人','width' => $kuandu);
$header[] = array('label' => '客户名称','width' => $kuandu);
$header[] = array('label' => '合同状态','width' => $kuandu);
$header[] = array('label' => '存档号生成方式','width' => $kuandu);
$header[] = array('label' => '操作人','width' => $kuandu);
$header[] = array('label' => '操作','width' => $kuandu);
$width = 0;
foreach($header as $arr){
	$width += $arr['width'];
}
$smarty->assign('ALLWIDTH',$_SESSION['bodywidth']+50); 
$smarty->assign('WIDTH',$width);
$smarty->assign('HEADER',$header);
if($is_ajax == "yes"){
	$smarty->assign('PAGE',$page);
	$smarty->display('haochen/order_detail.tpl');
}else{
    $smarty->assign('list',$list);
    //时间默认值
    $smarty->assign('total_pages',$total_pages);
    $smarty->assign('total_nums',$total_nums);
    $smarty->assign('params',$_REQUEST);
	$smarty->assign('PAGE',$page);
    $smarty->display('haochen/order.tpl');
}



function get_qichu($productid,$batchtext){
	global $adb;
	if(empty($_REQUEST['start_date'])){
		return 0;
	}
	if(!empty($productid)){
		$query = "select ifnull(sum(quantity),0) from ld_stock 
		LEFT JOIN ld_stockdetail on ld_stock.stock_id = ld_stockdetail.id 
		LEFT JOIN ld_products on ld_products.productid = ld_stockdetail.productid 
		where ld_stock.deleted = 0 and ld_stock.approvestatus = '已批准' 
		and ld_stockdetail.productid = ? and batchtext = ?";
		if(!empty($_REQUEST['start_date'])){
			$query .= " and createdate < '".$_REQUEST['start_date']."'";
		}
		$result = $adb->pquery($query,array($productid,$batchtext));
		$ruku = $adb->query_result($result,0,0);
		
		$query = "select IFNULL(sum(quantity),0) from ld_outboundorder 
		LEFT JOIN ld_outboundorderdetail on ld_outboundorder.out_id = ld_outboundorderdetail.id 
		LEFT JOIN ld_products on ld_products.productid = ld_outboundorderdetail.productid 
		where ld_outboundorder.deleted = 0 and ld_outboundorder.approvestatus = '已批准' 
		and ld_outboundorderdetail.productid = ? and batchtext = ?";
		if(!empty($_REQUEST['start_date'])){
			$query .= " and outdate < '".$_REQUEST['start_date']."'";
		}
		$result = $adb->pquery($query,array($productid,$batchtext));
		$chuku = $adb->query_result($result,0,0);
		return $ruku - $chuku;
	}
	return '';
}

function get_ruku($productid,$batchtext){
	global $adb;
	$query = "select ifnull(sum(quantity),0) from ld_stock 
	LEFT JOIN ld_stockdetail on ld_stock.stock_id = ld_stockdetail.id 
	LEFT JOIN ld_products on ld_products.productid = ld_stockdetail.productid 
	where ld_stock.deleted = 0 and ld_stock.approvestatus = '已批准' 
	and ld_stockdetail.productid = ? and batchtext = ?";
	if(!empty($_REQUEST['start_date']) && !empty($_REQUEST['end_date'])){
		$query .= " and createdate >= '".$_REQUEST['start_date']."' and createdate <= '".$_REQUEST['end_date']."'";
	}
	$result = $adb->pquery($query,array($productid,$batchtext));
	$ruku = $adb->query_result($result,0,0);
	return $ruku;
}

function get_chuku($productid,$batchtext){
	global $adb;
	$query = "select IFNULL(sum(quantity),0) from ld_outboundorder 
	LEFT JOIN ld_outboundorderdetail on ld_outboundorder.out_id = ld_outboundorderdetail.id 
	LEFT JOIN ld_products on ld_products.productid = ld_outboundorderdetail.productid 
	where ld_outboundorder.deleted = 0 and ld_outboundorder.approvestatus = '已批准' 
	and ld_outboundorderdetail.productid = ? and batchtext = ?";
	if(!empty($_REQUEST['start_date']) && !empty($_REQUEST['end_date'])){
		$query .= " and outdate >= '".$_REQUEST['start_date']."' and outdate <= '".$_REQUEST['end_date']."'";
	}
	$result = $adb->pquery($query,array($productid,$batchtext));
	$ruku = $adb->query_result($result,0,0);
	return $ruku;
}

function getErpInfo($module,$order_no){
	global $adb;
	if(!empty($order_no)){
		$query = "select 1 from erp_log where module = ? and order_no = ?";
		$result = $adb->pquery($query,array($module,$order_no));
		if($adb->num_rows($result) >= 1){
			return '已生成';
		}
	}
	return '未生成';
}