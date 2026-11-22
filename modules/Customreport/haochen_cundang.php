<?php
global $adb,$theme,$current_user;
$smarty=new lingdangCRM_Smarty();
$is_ajax = $_REQUEST['is_ajax'];
$date = date('Y-m-d');
$limit = 15;
$page = $_REQUEST['page'];
$page = empty($page)?1:$page;
if(!empty($_REQUEST['sign_date']) && !empty($_REQUEST['order_no'])){
	$order = $_REQUEST['order_no'];
	$query = "select 1 from ld_cundang where order_no = ?";
	$result = $adb->pquery($query,array($order));
	if($adb->num_rows($result) >= 1){
		echo -1;die;
	}
	$gd_num = substr($order,0,2);
	$gd_year = substr(date('Y-m-d'),2,2);
	$gd_month = substr(date('Y-m-d'),5,2);
	/*$query = "select IFNULL(max(gd_sequence),0)+1 from ld_cundang where gd_num = ? and gd_year = ? and gd_month = ?";
	$result = $adb->pquery($query,array($gd_num,$gd_year,$gd_month));
	$xuhao = $adb->query_result($result,0,0);
	if($gd_num == 'GS'){
		$cundanghao = 'CS'.$gd_year.$gd_month.substr(10000+$xuhao,1,5);
	}else{
		$cundanghao = 'CD'.$gd_year.$gd_month.substr(10000+$xuhao,1,5);
	}*/
	$query = "select IFNULL(max(gd_sequence),0)+1 from ld_cundang where gd_year = ? and gd_month = ?";
	$result = $adb->pquery($query,array($gd_year,$gd_month));
	$xuhao = $adb->query_result($result,0,0);
	$cundanghao = 'CD'.$gd_year.$gd_month.substr(10000+$xuhao,1,5);
	$query = "insert into ld_cundang(gd_num,gd_year,gd_month,gd_sequence,order_no,createdtime,sign_date,recordid,userid,zhuangtai,cundanghao) values (?,?,?,?,?,?,?,?,?,?,?)";
	$adb->pquery($query,array($gd_num,$gd_year,$gd_month,$xuhao,$order,date('Y-m-d H:i:s'),$_REQUEST['sign_date'],0,$current_user->id,'正常',$cundanghao));
	echo $cundanghao;die;
}
$query = "
	select cundanghao as bianhao,order_no,ld_cundang.createdtime,sign_date,last_name 
	from ld_cundang 
	left join ld_users on ld_users.id = ld_cundang.userid
	ORDER BY ld_cundang.id desc
";
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
		$bianhao = $adb->query_result($result,$i,'bianhao');
		$order_no = $adb->query_result($result,$i,'order_no');
		$createdtime = $adb->query_result($result,$i,'createdtime');
		$sign_date = $adb->query_result($result,$i,'sign_date');
		$last_name = $adb->query_result($result,$i,'last_name');
		$data[] = array(
			'bianhao' => $bianhao,
			'order_no' => $order_no,
			'createdtime' => $createdtime,
			'sign_date' => $sign_date,
			'last_name' => $last_name,
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
$kuandu = ceil(($_SESSION['bodywidth']-30)/5);
$header[] = array('label' => '存档号','width' => $kuandu);
$header[] = array('label' => '合同编号','width' => $kuandu);
$header[] = array('label' => '存档时间','width' => $kuandu);
$header[] = array('label' => '签订日期','width' => $kuandu);
$header[] = array('label' => '操作人','width' => $kuandu);									
$width = 0;
foreach($header as $arr){
	$width += $arr['width'];
}
$smarty->assign('ALLWIDTH',$_SESSION['bodywidth']+50); 
$smarty->assign('WIDTH',$width);
$smarty->assign('HEADER',$header);
if($is_ajax == "yes"){
	$smarty->assign('PAGE',$page);
	$smarty->display('haochen/cundang_detail.tpl');
}else{
    $smarty->assign('list',$list);
    //时间默认值
    $smarty->assign('total_pages',$total_pages);
    $smarty->assign('total_nums',$total_nums);
    $smarty->assign('params',$_REQUEST);
	$smarty->assign('PAGE',$page);
    $smarty->display('haochen/cundang.tpl');
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