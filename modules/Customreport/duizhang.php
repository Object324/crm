<?php
/**
* reason:联合技术报表：Mid-Year Rate Adjustment
* eidt:xiaoshun
* date:2016-09-21
**/

global $adb,$theme;
global $current_user,$list_max_entries_per_page_new;
$smarty=new lingdangCRM_Smarty();
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$theme_path="themes/".$theme."/";
 
//对账状态
if(!empty($_REQUEST['update_duizhang']) && $_REQUEST['update_duizhang'] == 'yes' && !empty($_REQUEST['billids'])){
	$jobman = $current_user->last_name;
	$bill_mon = $_REQUEST['bill_mon'];
	
	$billids = ltrim($_REQUEST['billids'],','); 
	$query = 'update ld_customform18 set is_duizhang = ?,is_duizhang_date = ? , bill_chkman = ? , bill_mon = ? where customform18id in ('.$billids.') and is_duizhang = \'未对账\'';
	$adb->pquery($query,array('已对账',date('Y-m-d'), $jobman, $bill_mon));
	$query = 'update ld_customform19 set is_duizhang = ?,is_duizhang_date = ? , bill_chkman = ? , bill_mon = ? where customform19id in ('.$billids.')  and is_duizhang = \'未对账\' ';
	$adb->pquery($query,array('已对账',date('Y-m-d'), $jobman, $bill_mon));
	echo $billids.'---'.date('Y-m-d').'---'.$jobman.'---'.$bill_mon;die;
}

$query = 'select id,last_name from ld_users where `status` = \'Active\'';
$result = $adb->pquery($query,array());
$num_rows = $adb->num_rows($result);
if($num_rows >= 1){
	for($i = 0; $i < $num_rows; $i++){
		$id = $adb->query_result($result,$i,'id');
		$users[$id] = $adb->query_result($result,$i,'last_name');
	}
}
$smarty->assign('USERS',$users);

$where = '';
$_REQUEST['search_name'] = $_REQUEST['search_name'];	//客户/供应商
$_REQUEST['job_starttime'] = $_REQUEST['job_starttime'];	//job 开始日期
$_REQUEST['job_endtime'] = $_REQUEST['job_endtime'];	//job 结束日期
$_REQUEST['job_no'] = $_REQUEST['job_no'];	//job no
$_REQUEST['duizhang'] = $_REQUEST['duizhang'];	//对账状态
$_REQUEST['creator'] = $_REQUEST['creator'];	//JOB NO创建人
$_REQUEST['yewu_leixing'] = $_REQUEST['yewu_leixing'];	//业务类型
$_REQUEST['istoerp'] = $_REQUEST['istoerp'];	//对接金蝶
$_REQUEST['billids'] = ltrim($_REQUEST['billids'],','); 
//报关
if($_REQUEST['yewu_leixing'] == '报关'){
	$data = baoguan();
}else if($_REQUEST['yewu_leixing'] == '运输'){	//运输
	$data = yunshu();
}else if($_REQUEST['yewu_leixing'] == '出入库'){	//出入库
	$data = churuku();
}else if($_REQUEST['yewu_leixing'] == '空运'){	//空运
	$data = kongyun();
}else if($_REQUEST['yewu_leixing'] == '海运'){	//海运
	$data = haiyun();
}else if($_REQUEST['yewu_leixing'] == 'Local配送'){	//Local配送
	$data = peisong();
}else if($_REQUEST['yewu_leixing'] == 'ALL'){
	$data = getAll();
}

//对接金额
if(!empty($_REQUEST['save_kingdee']) && $_REQUEST['save_kingdee'] == 'yes' && !empty($_REQUEST['billids'])){
	crm_load_class_file('cls_duizhang_kingdee','modules/Customreport');
	$cls_duizhang_kingdee = new cls_duizhang_kingdee();
	
	foreach($data['list'] as $arr){
		if($arr['istoerp'] == '否' || $arr['zhuangtai'] == '未对账' || $arr['kis_id'] > 0){
			echo 'error';die;
		}
	}
	/*echo '<pre>';
	print_r($data);
	echo '</pre>';
	die;*/
	$cls_duizhang_kingdee->save($data);
	echo 'success';die;
}
//导出
if(!empty($_REQUEST['export']) && $_REQUEST['export'] == 'yes'){
	ExportData($data);

}else{
	/*echo '<pre>';
	print_r($data);
	echo '</pre>';*/
	$smarty->assign('YEWULEIXING',$_REQUEST['yewu_leixing']);
	$smarty->assign('BILLIDS',implode(',',$data['billids']));
	$smarty->assign('DATA',$data);
	if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
	{
		$smarty->display("langjie/duizhang_content.tpl");
	}
		
	else
		$smarty->display('langjie/duizhang_list.tpl');
}
function getCurrencyInfo(){
	global $adb;
	$query = 'select id,description from ld_currency_info INNER JOIN ld_currencies on ld_currencies.currency_name = ld_currency_info.currency_name';
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$id = $adb->query_result($result,$i,'id');
			$description = $adb->query_result($result,$i,'description');
			$cur[$id] = $description;
		}
	}
	return $cur;
}
//权限
function getSmowerSql(){
	global $adb,$theme;
	global $current_user,$list_max_entries_per_page_new;
	$data = array('acc' => '','ven' => '');
	crm_load_class_file('cls_langjie_duizhang_Scop','modules/Customreport');

	
	if($current_user->is_admin == 'off'){
		$cls_langjie_duizhang_Scop=new cls_langjie_duizhang_Scop($adb,'CustomForm18');
		$data['acc'] = $cls_langjie_duizhang_Scop->getModuleListViewQuery();
		$cls_langjie_duizhang_Scop=new cls_langjie_duizhang_Scop($adb,'CustomForm19');
		$data['ven'] = $cls_langjie_duizhang_Scop->getModuleListViewQuery();
	}
	return $data;
}

function getSmowerSqlAndSmcreatorid($smownersearchsql){
	if(!empty($smownersearchsql)){
		$sql_arr = explode(')',$smownersearchsql);
		/*echo '<pre>';
		print_r($sql_arr);
		echo '</pre>';*/
	}

	return $smownersearchsql;
}
//全部
function getAll(){
	global $adb;
	$data = array();
	if(empty($_REQUEST['baoguan_leixing']) || $_REQUEST['baoguan_leixing'] == 'account'){
		$query = all_kehu();
	}else{
		$query = all_gongyingshang();
	}
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	$subtotal = array();$billid_array = array();
	$currency_info = getCurrencyInfo();
	if($num_rows > 0){
		for($i = 0; $i < $num_rows; $i++){
			$billno = $adb->query_result($result,$i,'billno');	
			$billid = $adb->query_result($result,$i,'billid');	//单据ID
			$_REQUEST['istoerp'] = $adb->query_result($result,$i,'istoerp');	//是否对接金蝶
			$zhuangtai = $adb->query_result($result,$i,'zhuangtai');	//对账状态
			$zhuangtai_date = $adb->query_result($result,$i,'zhuangtai_date');	//对账日期
			$yewufenlei = $adb->query_result($result,$i,'yewufenlei');	//业务分类
			$accountorvendor = $adb->query_result($result,$i,'accountorvendor');	//客户/供应商
			$jobno = $adb->query_result($result,$i,'jobno');	//JOB NO
			$jobno_date = $adb->query_result($result,$i,'jobno_date');	//JOB NO日期
			$jobno_creator = $adb->query_result($result,$i,'jobno_creator');	//JOB NO创建人
			$fapiaohao = $adb->query_result($result,$i,'fapiaohao');	//发票号
			$chukou_date = $adb->query_result($result,$i,'chukou_date');	//出口日期
			$jinkou_date = $adb->query_result($result,$i,'jinkou_date');	//进口日期
			$kouan = $adb->query_result($result,$i,'kouan');	//申报口岸
			$shouhuoren = $adb->query_result($result,$i,'shouhuoren');	//收货人
			$pinming = $adb->query_result($result,$i,'pinming');	//品名
			$xiangshubanshu = $adb->query_result($result,$i,'xiangshubanshu');	//箱数/板数
			$qty = $adb->query_result($result,$i,'qty');	//数量
			$huozhi = $adb->query_result($result,$i,'huozhi');	//货值
			$jianshu = $adb->query_result($result,$i,'jianshu');	//件数
			$maozhong = $adb->query_result($result,$i,'maozhong');	//毛重
			$cheixng = $adb->query_result($result,$i,'cheixng');	//车型
			$chepai = $adb->query_result($result,$i,'chepai');	//车牌

			$liuliandanhao = $adb->query_result($result,$i,'liuliandanhao');	//六连单号
			$real_flightdate = $adb->query_result($result,$i,'real_flightdate');	//航班日期
			$real_flightno = $adb->query_result($result,$i,'real_flightno');	//航班号
			$masterorder_no = $adb->query_result($result,$i,'masterorder_no');	//主单号
			$fendanhao = $adb->query_result($result,$i,'fendanhao');	//分单号
			$jifeizhongliang = $adb->query_result($result,$i,'jifeizhongliang');	//计费重量
			$baoguandanhao = $adb->query_result($result,$i,'baoguandanhao');	//报关单号
			$feiyongtype = $adb->query_result($result,$i,'feiyongtype');	//费用项目
			$weishui_amount_tax0 = $adb->query_result($result,$i,'weishui_amount_tax0');	
			$hanshui_amount_tax0 = $adb->query_result($result,$i,'hanshui_amount_tax0');	
			$weishui_amount_tax6 = $adb->query_result($result,$i,'weishui_amount_tax6');	
			$hanshui_amount_tax6 = $adb->query_result($result,$i,'hanshui_amount_tax6');	
			$weishui_amount_tax9 = $adb->query_result($result,$i,'weishui_amount_tax9');	
			$hanshui_amount_tax9 = $adb->query_result($result,$i,'hanshui_amount_tax9');
			$weishui_amount_tax1 = $adb->query_result($result,$i,'weishui_amount_tax1');	
			$hanshui_amount_tax1 = $adb->query_result($result,$i,'hanshui_amount_tax1');
			$shui = $adb->query_result($result,$i,'tax2');		//税
			$weishui_amount = $adb->query_result($result,$i,'weishui_amount');	
			$hanshui_amount = $adb->query_result($result,$i,'hanshui_amount');	
			$currency_id = $adb->query_result($result,$i,'currency_id');	//货值
			$currency_symbol = $adb->query_result($result,$i,'currency_symbol');
			$conversion_rate = $adb->query_result($result,$i,'conversion_rate');
			$kis_id = $adb->query_result($result,$i,'kis_id');
			$comment = $adb->query_result($result,$i,'comment');	//备注
			$fee_creator = $adb->query_result($result,$i,'fee_creator');	//费用单创建人
			$bill_chkman = $adb->query_result($result,$i,'bill_chkman');	//对账人
			$bill_mon = $adb->query_result($result,$i,'bill_mon');	//记账月份人
			
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['currency_symbol'] = $currency_symbol;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax0'] += $weishui_amount_tax0;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax0'] += $hanshui_amount_tax0;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax6'] += $weishui_amount_tax6;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax6'] += $hanshui_amount_tax6;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax9'] += $weishui_amount_tax9;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax9'] += $hanshui_amount_tax9;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax1'] += $weishui_amount_tax1;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax1'] += $hanshui_amount_tax1;
			if($currency_id > 1){
				$weishui_amount_tax0 = $weishui_amount_tax0*$conversion_rate;
				$hanshui_amount_tax0 = $hanshui_amount_tax0*$conversion_rate;
				$weishui_amount_tax6 = $weishui_amount_tax6*$conversion_rate;
				$hanshui_amount_tax6 = $hanshui_amount_tax6*$conversion_rate;
				$weishui_amount_tax9 = $weishui_amount_tax9*$conversion_rate;
				$hanshui_amount_tax9 = $hanshui_amount_tax9*$conversion_rate;
				$weishui_amount_tax1 = $weishui_amount_tax1*$conversion_rate;
				$hanshui_amount_tax1 = $hanshui_amount_tax1*$conversion_rate;
			}
			$total[$accountorvendor]['weishui_amount_tax0'] += $weishui_amount_tax0;
			$total[$accountorvendor]['hanshui_amount_tax0'] += $hanshui_amount_tax0;
			$total[$accountorvendor]['weishui_amount_tax6'] += $weishui_amount_tax6;
			$total[$accountorvendor]['hanshui_amount_tax6'] += $hanshui_amount_tax6;
			$total[$accountorvendor]['weishui_amount_tax9'] += $weishui_amount_tax9;
			$total[$accountorvendor]['hanshui_amount_tax9'] += $hanshui_amount_tax9;
			$total[$accountorvendor]['weishui_amount_tax1'] += $weishui_amount_tax1;
			$total[$accountorvendor]['hanshui_amount_tax1'] += $hanshui_amount_tax1;

			$billid_array[] = $billid;
			if($_REQUEST['yewu_leixing'] == 'ALL') {
				$data[] = array(
				'billno' => $adb->query_result($result,$i,'billno'),
				'billid' => $billid,
				'jobno' => $jobno,
				'feiyongtype' => $feiyongtype,
				'shui' => $shui,
				'weishui_amount' => $weishui_amount,
				'hanshui_amount' => $hanshui_amount,
				'istoerp' => $_REQUEST['istoerp'],
				'zhuangtai' => $zhuangtai,
				'zhuangtai_date' => $zhuangtai_date,
				'kis_id' => $kis_id,
				'yewufenlei' => $yewufenlei,
				'accountorvendor' => $accountorvendor,
				
				'jobno_date' => $jobno_date,
				'jobno_creator' => $jobno_creator,
				'fee_creator' => $fee_creator,
				'bill_chkman' => $bill_chkman,
				'bill_mon' => $bill_mon,
				
				
				'fapiaohao' => $fapiaohao,
				'chukou_date' => $chukou_date,
				'jinkou_date' => $jinkou_date,
				'kouan' => $kouan,
				'shouhuoren' => $shouhuoren,
				'pinming' => $pinming,
				'xiangshubanshu' => $xiangshubanshu,
				'qty' => $qty,
				'huozhi' => $huozhi,
				'jianshu' => $jianshu,
				'maozhong' => $maozhong,
				'cheixng' => $cheixng,
				'chepai' => $chepai,
				'liuliandanhao' => $liuliandanhao,
				'real_flightdate' => $real_flightdate,
				'real_flightno' => $real_flightno,
				'masterorder_no' => $masterorder_no,
				'fendanhao' => $fendanhao,
				'jifeizhongliang' => $jifeizhongliang,
				'baoguandanhao' => $baoguandanhao,
			
				'comment' => $comment,
				'currency_name' => $currency_info[$currency_id],
				'currency_symbol' => $currency_symbol,
				'currency_id' => $currency_id,
			  );
			} else {
			
			$data[] = array(
				'billno' => $adb->query_result($result,$i,'billno'),
				'billid' => $billid,
				'istoerp' => $_REQUEST['istoerp'],
				'zhuangtai' => $zhuangtai,
				'zhuangtai_date' => $zhuangtai_date,
				'kis_id' => $kis_id,
				'yewufenlei' => $yewufenlei,
				'accountorvendor' => $accountorvendor,
				'jobno' => $jobno,
				'jobno_date' => $jobno_date,
				'jobno_creator' => $jobno_creator,
				'fapiaohao' => $fapiaohao,
				'chukou_date' => $chukou_date,
				'jinkou_date' => $jinkou_date,
				'kouan' => $kouan,
				'shouhuoren' => $shouhuoren,
				'pinming' => $pinming,
				'xiangshubanshu' => $xiangshubanshu,
				'qty' => $qty,
				'huozhi' => $huozhi,
				'jianshu' => $jianshu,
				'maozhong' => $maozhong,
				'cheixng' => $cheixng,
				'chepai' => $chepai,
				'liuliandanhao' => $liuliandanhao,
				'real_flightdate' => $real_flightdate,
				'real_flightno' => $real_flightno,
				'masterorder_no' => $masterorder_no,
				'fendanhao' => $fendanhao,
				'jifeizhongliang' => $jifeizhongliang,
				'baoguandanhao' => $baoguandanhao,
				'feiyongtype' => $feiyongtype,
				'shui' => $shui,
				'weishui_amount' => $weishui_amount,
				'hanshui_amount' => $hanshui_amount,
				'comment' => $comment,
				'currency_name' => $currency_info[$currency_id],
				'currency_symbol' => $currency_symbol,
				'currency_id' => $currency_id,
			  );
			}
		}
	}
	$fld_array = array('费用单号','对接金蝶','对账状态','对账日期','对接状态','业务分类','客户/供应商','JOB NO日期','JOB NO','JOB NO创建人','发票号','业务日期','进口日期','申报口岸','收货人','品名','箱数/板数','数量','货值','件数','毛重','六连单号','车型','车牌','航班日期','航班号','主单号','分单号','计费重量','业务单号','费用项目','税率','未税金额','含税金额','备注','币种');
	$total = setTotal($subtotal,$total);$list = setData($data);
	return array('list'=>$list,'subtotal'=>$subtotal,'total'=>$total,'billids'=>$billid_array);
}

// gvendor
function all_gongyingshang(){ 
	$smower_sql = getSmowerSql();
	$ven_smower_sql = '';
	if(!empty($smower_sql['ven'])){
		$ven_smower_sql = str_replace("ld_customform19","a",$smower_sql['ven']);
	}
	$billids = '';
	if(!empty($_REQUEST['billids']) ){
		$billids = " and a.customform19id in (" . $_REQUEST['billids'].")";
	}
	$where = '';
	if(!empty($_REQUEST['search_name'])){
		$where .= " and k.vendorname like '%".$_REQUEST['search_name']."%'";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '已对接'){
		$where .= " and a.kis_id > 0";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '未对接'){
		$where .= " and a.kis_id = 0";
	}
	if(!empty($_REQUEST['bill_mon']) ){
		$where .= " and a.bill_mon = '".$_REQUEST['bill_mon']."'";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && empty($_REQUEST['duizhang_enddate'])){
		$where .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."'";
	}
	if(empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$where .= " and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$where .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."' and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	if(!empty($_REQUEST['duizhang'])){
		$where .= " and a.is_duizhang = '".$_REQUEST['duizhang']."'";
	}
	if(!empty($_REQUEST['istoerp']) && $_REQUEST['istoerp'] == '是'){
		$where .= " and a.istoerp = '是'";
	}
	if(!empty($_REQUEST['billid']) ){
		$where .= " and a.customform19id = " . $_REQUEST['billid'];
	}
	if(!empty($_REQUEST['creator'])){
		$where .= " and u.last_name = '".$_REQUEST['creator']."'";
	}
	$query = "
		 SELECT
			t.* , CASE
					WHEN t.currency_id=1 THEN 1.000000
					WHEN t.currency_id=6 THEN 
						(SELECT conversionrate_rmbtoeur FROM ld_customform48 WHERE deleted=0 AND concat(t.bill_mon, '-01') 
								BETWEEN validfrom AND validtill AND vendorid=t.vendorid ORDER BY modifiedtime DESC LIMIT 1)
					WHEN t.currency_id=7 THEN 
						(SELECT conversionrate_rmbtousd FROM ld_customform48 WHERE deleted=0 AND concat(t.bill_mon, '-01') 
								BETWEEN validfrom AND validtill AND vendorid=t.vendorid ORDER BY modifiedtime DESC LIMIT 1)
					WHEN t.currency_id=10 THEN 
						(SELECT conversionrate_rmbtokrw FROM ld_customform48 WHERE deleted=0 AND concat(t.bill_mon, '-01') 
								BETWEEN validfrom AND validtill AND vendorid=t.vendorid ORDER BY modifiedtime DESC LIMIT 1)
					WHEN t.currency_id=11 THEN 
						(SELECT conversionrate_rmbtohkd FROM ld_customform48 WHERE deleted=0 AND concat(t.bill_mon, '-01') 
								BETWEEN validfrom AND validtill AND vendorid=t.vendorid ORDER BY modifiedtime DESC LIMIT 1)
					WHEN t.currency_id=12 THEN 
						(SELECT conversionrate_rmbtovnd FROM ld_customform48 WHERE deleted=0 AND concat(t.bill_mon, '-01') 
								BETWEEN validfrom AND validtill AND vendorid=t.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				END AS conversion_rate
		FROM (
			SELECT 
				a.customform19_no AS billno,
				a.customform19id AS billid,
				a.customform19_no,
				a.vendorid,
				a.istoerp,a.kis_id,
				a.is_duizhang AS zhuangtai,
				a.is_duizhang_date AS zhuangtai_date,
				a.service_type AS yewufenlei,
				k.vendorname AS accountorvendor,
				j.customform03_no AS jobno,
				DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
				u.last_name AS jobno_creator,

				case when ifnull(y.invoice_no,'')='' then GROUP_CONCAT(DISTINCT e.sf407) else y.invoice_no end AS fapiaohao,
				x.cf_2823 AS chukou_date,
				NULL AS jinkou_date,
				y.port_no AS kouan,
				NULL AS shouhuoren,
				e.sf138 AS pinming,
				NULL AS xiangshubanshu,
				ROUND(SUM(e.sf140),3) AS qty,
				ROUND(SUM(e.sf193),3) AS huozhi,
				y.piece AS jianshu,
				ROUND(SUM(y.gross_weight),3) AS maozhong,
				NULL AS cheixng,
				NULL AS chepai,
				CASE 
					WHEN LENGTH(LEFT(y.trans_name,1))=CHAR_LENGTH(LEFT(y.trans_name,1)) THEN y.trans_name
					ELSE ''
				 END AS liuliandanhao,
				NULL AS real_flightdate,
				NULL AS real_flightno,
				NULL AS masterorder_no,
				NULL AS fendanhao,
				NULL AS jifeizhongliang,

				CASE
					WHEN x.cf_3033='否' THEN y.apply_no
					ELSE x.cf_3034
				END AS baoguandanhao,
				p.productname AS feiyongtype,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax0,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax0,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax6,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax6,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax9,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax9,
				CASE
					WHEN b.tax2=1 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax1,
				CASE
					WHEN b.tax2=1 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax1,
				ROUND(b.tax_amount,2) AS weishui_amount,
				b.tax2,
				ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
				a.currency_id,
				a.currency_symbol, b.comment, uu.last_name fee_creator, a.bill_chkman, a.kis_ifman, a.bill_mon
			FROM ld_customform19 a
			LEFT JOIN ld_vendor k ON k.vendorid=a.vendorid
			lEFT JOIN ld_customform22 y ON y.customform22id=a.customform22_id
			lEFT JOIN ld_customform22scf x ON x.customform22id=y.customform22id
			LEFT JOIN ld_customform22detail d ON d.id=y.customform22id
			LEFT JOIN ld_customform22detailscf e ON e.lineitem_id=d.lineitem_id
			LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
			LEFT JOIN ld_users u ON u.id=j.smcreatorid
			LEFT JOIN ld_customform19detail b ON b.id=a.customform19id
			LEFT JOIN ld_products p ON p.productid=b.productid 
			LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.vendorid
			LEFT JOIN ld_users uu ON uu.id = a.smcreatorid
			WHERE a.deleted=0
				AND a.approvestatus<>'已拒绝'
				AND a.service_type='报关' $ven_smower_sql $billids $where 
			GROUP BY a.customform19id,b.lineitem_id
			UNION ALL
			SELECT 
				a.customform19_no AS billno,
				a.customform19id AS billid,
				a.customform19_no,
				a.vendorid,
				a.istoerp,a.kis_id,
				a.is_duizhang AS zhuangtai,
				a.is_duizhang_date AS zhuangtai_date,
				a.service_type AS yewufenlei,
				k.vendorname AS accountorvendor,
				j.customform03_no AS jobno,
				DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
				u.last_name AS jobno_creator,

				GROUP_CONCAT(DISTINCT e.sf157) AS fapiaohao,
				y.ship_date AS chukou_date,
				NULL AS jinkou_date,
				y.customs_port AS kouan,
				e.sf156 AS shouhuoren,
				e.sf165 AS pinming,
				ROUND(SUM(distinct e.sf164),0) AS xiangshubanshu,
				ROUND(SUM(distinct e.sf167),3) AS qty,
				NULL AS huozhi,
				NULL AS jianshu,
				ROUND(SUM(e.sf204),3) AS maozhong,
				aa.carriage_type chexing,
				aa.chepaihao AS chepai,
				NULL AS liuliandanhao,
				NULL AS real_flightdate,
				NULL AS real_flightno,
				NULL AS masterorder_no,
				NULL AS fendanhao,
				NULL AS jifeizhongliang,

				y.customform23_no AS yewudanhao,
				p.productname AS feiyongtype,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax0,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax0,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax6,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax6,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax9,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax9,
				CASE
					WHEN b.tax2=1 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax1,
				CASE
					WHEN b.tax2=1 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax1,
				ROUND(b.tax_amount,2) AS weishui_amount,
				b.tax2,
				ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
				a.currency_id,
				a.currency_symbol,b.comment, uu.last_name fee_creator, a.bill_chkman, a.kis_ifman, a.bill_mon
			FROM ld_customform19 a
			LEFT JOIN ld_vendor k ON k.vendorid=a.vendorid
			LEFT JOIN ld_customform02 aa ON aa.customform02id=a.customform02_id
			LEFT JOIN ld_customform23 y ON y.customform23id = GREATEST(aa.yunshudanid_01,aa.yunshudanid_02,aa.yunshudanid_03,aa.yunshudanid_04)
			lEFT JOIN ld_customform23scf x ON x.customform23id=y.customform23id
			LEFT JOIN ld_customform23detail d ON d.id=y.customform23id
			LEFT JOIN ld_customform23detailscf e ON e.lineitem_id=d.lineitem_id
			LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
			LEFT JOIN ld_users u ON u.id=j.smcreatorid
			LEFT JOIN ld_customform19detail b ON b.id=a.customform19id
			LEFT JOIN ld_products p ON p.productid=b.productid 
			LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.vendorid 
      LEFT JOIN ld_users uu ON uu.id = a.smcreatorid
			WHERE a.deleted=0
				AND a.approvestatus<>'已拒绝'
				AND a.service_type='运输' $ven_smower_sql $billids $where  
			GROUP BY a.customform19id,b.lineitem_id
			UNION ALL
			SELECT 
				a.customform19_no AS billno,
				a.customform19id AS billid,
				a.customform19_no,
				a.vendorid,
				a.istoerp,a.kis_id,
				a.is_duizhang AS zhuangtai,
				a.is_duizhang_date AS zhuangtai_date,
				a.service_type AS yewufenlei,
				k.vendorname AS accountorvendor,
				j.customform03_no AS jobno,
				DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
				u.last_name AS jobno_creator,

				NULL AS fapiaohao,
				NULL AS chukou_date,
				NULL AS jinkou_date,
				NULL AS kouan,
				NULL AS shouhuoren,
				d.product_name AS pinming,
				ROUND(SUM(d.quantity),0) AS xiangshubanshu,
				ROUND(SUM(e.sf217),3) AS qty,
				NULL AS huozhi,
				NULL AS jianshu,
				ROUND(SUM(e.sf215),3) AS maozhong,
				NULL AS cheixng,
				NULL AS chepai,
				NULL AS liuliandanhao,
				NULL AS real_flightdate,
				NULL AS real_flightno,
				NULL AS masterorder_no,
				NULL AS fendanhao,
				NULL AS jifeizhongliang,

				y.commission_no AS yewudanhao,
				p.productname AS feiyongtype,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax0,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax0,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax6,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax6,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax9,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax9,
				CASE
					WHEN b.tax2=1 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax1,
				CASE
					WHEN b.tax2=1 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax1,
				ROUND(b.tax_amount,2) AS weishui_amount,
				b.tax2,
				ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
				a.currency_id,
				a.currency_symbol,b.comment, uu.last_name fee_creator, a.bill_chkman, a.kis_ifman, a.bill_mon
			FROM ld_customform19 a
			LEFT JOIN ld_vendor k ON k.vendorid=a.vendorid
			lEFT JOIN ld_commission y ON y.commission_id=a.commission_id
			LEFT JOIN ld_commission2payment d ON d.commission_id=y.commission_id
			LEFT JOIN ld_commission2paymentscf e ON e.commission2payment_id=d.commission2payment_id
			LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
			LEFT JOIN ld_users u ON u.id=j.smcreatorid
			LEFT JOIN ld_customform19detail b ON b.id=a.customform19id
			LEFT JOIN ld_products p ON p.productid=b.productid 
			LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.vendorid 
      LEFT JOIN ld_users uu ON uu.id = a.smcreatorid
			WHERE a.deleted=0
				AND a.approvestatus<>'已拒绝'
				AND a.service_type='出入库' $ven_smower_sql $billids $where 
			GROUP BY a.customform19id,b.lineitem_id
			UNION ALL
			SELECT 
				a.customform19_no AS billno,
				a.customform19id AS billid,
				a.customform19_no,
				a.vendorid,
				a.istoerp,a.kis_id,
				a.is_duizhang AS zhuangtai,
				a.is_duizhang_date AS zhuangtai_date,
				a.service_type AS yewufenlei,
				k.vendorname AS accountorvendor,
				j.customform03_no AS jobno,
				DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
				u.last_name AS jobno_creator,

				NULL AS fapiaohao,
				IFNULL(x.real_flightdate, y.flight_date) AS chukou_date,
				NULL AS jinkou_date,
				NULL AS kouan,
				NULL AS shouhuoren,
				e.sf170 AS pinming,
				NULL AS xiangshubanshu,
				NULL AS qty,
				NULL AS huozhi,
				ROUND(SUM(distinct e.sf171),3) AS jianshu,
				ROUND(SUM(distinct e.sf174),3) AS maozhong,
				NULL AS cheixng,
				NULL AS chepai,
				NULL AS liuliandanhao,
				x.real_flightdate,
				x.real_flightno,
				x.masterorder_no,
				GROUP_CONCAT(IFNULL(e.sf169,'') SEPARATOR '
			') AS fendanhao,
				GROUP_CONCAT(ROUND(IFNULL(e.sf174,0),3) SEPARATOR '
			') AS jifeizhongliang,

				y.customform24_no AS yewudanhao,
				p.productname AS feiyongtype,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax0,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax0,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax6,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax6,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax9,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax9,
				CASE
					WHEN b.tax2=1 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax1,
				CASE
					WHEN b.tax2=1 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax1,
				ROUND(b.tax_amount,2) AS weishui_amount,
				b.tax2,
				ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
				a.currency_id,
				a.currency_symbol,b.comment, uu.last_name fee_creator, a.bill_chkman, a.kis_ifman, a.bill_mon
			FROM ld_customform19 a
			LEFT JOIN ld_vendor k ON k.vendorid=a.vendorid
			lEFT JOIN ld_customform24 y ON y.customform24id=a.customform24_id
			LEFT JOIN ld_customform25 x ON x.customform24_id=y.customform24id AND x.deleted=0
			LEFT JOIN ld_customform25detail d ON d.id=x.customform25id
			LEFT JOIN ld_customform25detailscf e ON e.lineitem_id=d.lineitem_id
			LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
			LEFT JOIN ld_users u ON u.id=j.smcreatorid
			LEFT JOIN ld_customform19detail b ON b.id=a.customform19id
			LEFT JOIN ld_products p ON p.productid=b.productid 
			LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.vendorid 
      LEFT JOIN ld_users uu ON uu.id = a.smcreatorid
			WHERE a.deleted=0
				AND a.approvestatus<>'已拒绝'
				AND a.service_type='空运' $ven_smower_sql $billids $where 
			GROUP BY a.customform19id,b.lineitem_id
			UNION ALL
			SELECT 
				a.customform19_no AS billno,
				a.customform19id AS billid,
				a.customform19_no,
				a.vendorid,
				a.istoerp,a.kis_id,
				a.is_duizhang AS zhuangtai,
				a.is_duizhang_date AS zhuangtai_date,
				a.service_type AS yewufenlei,
				k.vendorname AS accountorvendor,
				j.customform03_no AS jobno,
				DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
				u.last_name AS jobno_creator,
				
				NULL AS fapiaohao,
				xx.cf_3664 AS chukou_date,
				NULL AS jinkou_date,
				NULL AS kouan,
				NULL AS shouhuoren,
				e.sf218 AS pinming,
				ROUND(SUM(e.sf223+e.sf224),0) AS xiangshubanshu,
				ROUND(SUM(e.sf132),3) AS qty,
				NULL AS huozhi,
				NULL AS jianshu,
				ROUND(SUM(e.sf135),3) AS maozhong,
				NULL AS cheixng,
				NULL AS chepai,
				NULL AS liuliandanhao,
				NULL AS real_flightdate,
				NULL AS real_flightno,
				NULL AS masterorder_no,
				NULL AS fendanhao,
				NULL AS jifeizhongliang,

				y.customform21_no AS yewudanhao,
				p.productname AS feiyongtype,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax0,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax0,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax6,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax6,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax9,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax9,
				CASE
					WHEN b.tax2=1 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax1,
				CASE
					WHEN b.tax2=1 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax1,
				ROUND(b.tax_amount,2) AS weishui_amount,
				b.tax2,
				ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
				a.currency_id,
				a.currency_symbol,b.comment, uu.last_name fee_creator, a.bill_chkman, a.kis_ifman, a.bill_mon
			FROM ld_customform19 a
			LEFT JOIN ld_vendor k ON k.vendorid=a.vendorid
			lEFT JOIN ld_customform21 y ON y.customform21id=a.customform21_id
			LEFT JOIN ld_customform26 x ON x.customform21_id=y.customform21id AND x.deleted=0
			LEFT JOIN ld_customform26scf xx ON x.customform26id = xx.customform26id
			LEFT JOIN ld_customform26detail d ON d.id=x.customform26id
			LEFT JOIN ld_customform26detailscf e ON e.lineitem_id=d.lineitem_id
			LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
			LEFT JOIN ld_users u ON u.id=j.smcreatorid
			LEFT JOIN ld_customform19detail b ON b.id=a.customform19id
			LEFT JOIN ld_products p ON p.productid=b.productid 
			LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.vendorid 
      LEFT JOIN ld_users uu ON uu.id = a.smcreatorid
			WHERE a.deleted=0
				AND a.approvestatus<>'已拒绝'
				AND a.service_type='海运' $ven_smower_sql $billids $where 
			GROUP BY a.customform19id,b.lineitem_id
			UNION ALL
			SELECT 
				a.customform19_no AS billno,
				a.customform19id AS billid,
				a.customform19_no,
				a.vendorid,
				a.istoerp,a.kis_id,
				a.is_duizhang AS zhuangtai,
				a.is_duizhang_date AS zhuangtai_date,
				a.service_type AS yewufenlei,
				k.vendorname AS accountorvendor,
				j.customform03_no AS jobno,
				DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
				u.last_name AS jobno_creator,

				NULL AS fapiaohao,
				z.cf_3699 AS chukou_date,
				NULL AS jinkou_date,
				NULL AS kouan,
				CONCAT(CONCAT(GROUP_CONCAT(DISTINCT dd.sf402),' >> '), GROUP_CONCAT(DISTINCT dd.sf403)) AS shouhuoren,
				NULL AS pinming,
				NULL AS xiangshubanshu,
				NULL AS qty,
				NULL AS huozhi,
				NULL AS jianshu,
				NULL AS maozhong,
				NULL AS cheixng,
				NULL AS chepai,
				NULL AS liuliandanhao,
				NULL AS real_flightdate,
				NULL AS real_flightno,
				NULL AS masterorder_no,
				NULL AS fendanhao,
				NULL AS jifeizhongliang,

				y.customform28_no AS yewudanhao,
				p.productname AS feiyongtype,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax0,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax0,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax6,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax6,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax9,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax9,
				CASE
					WHEN b.tax2=1 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax1,
				CASE
					WHEN b.tax2=1 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax1,
				ROUND(b.tax_amount,2) AS weishui_amount,
				b.tax2,
				ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
				a.currency_id,
				a.currency_symbol,b.comment, uu.last_name fee_creator, a.bill_chkman, a.kis_ifman, a.bill_mon
			FROM ld_customform19 a
			LEFT JOIN ld_vendor k ON k.vendorid=a.vendorid
			lEFT JOIN ld_customform28 y ON y.customform28id=a.customform28_id
      LEFT JOIN ld_customform28scf z on y.customform28id = z.customform28id
			LEFT JOIN ld_customform28detail d ON d.id=y.customform28id
			LEFT JOIN ld_customform28detailscf dd ON dd.lineitem_id=d.lineitem_id
			LEFT JOIN ld_customform27 c ON c.customform27id=d.entitytypeid
			LEFT JOIN ld_customform03 j ON j.customform03id=c.customform03_id
			LEFT JOIN ld_users u ON u.id=j.smcreatorid
			LEFT JOIN ld_customform19detail b ON b.id=a.customform19id
			LEFT JOIN ld_products p ON p.productid=b.productid 
			LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.vendorid 
      LEFT JOIN ld_users uu ON uu.id = a.smcreatorid
			WHERE a.deleted=0
				AND a.approvestatus<>'已拒绝'
				AND a.service_type='Local配送' $ven_smower_sql $billids $where 
			GROUP BY a.customform19id,b.lineitem_id
		) t where 1=1 
		
	";
	
	if(!empty($_REQUEST['job_starttime']) && empty($_REQUEST['job_endtime'])){
		$query .= " and chukou_date >= '".$_REQUEST['job_starttime']."'";
	}
	if(empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and chukou_date <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and chukou_date >= '".$_REQUEST['job_starttime']."' and chukou_date <= '".$_REQUEST['job_endtime']."'";
	}
	// if(!empty($_REQUEST['job_no'])){
		// $query .= " and jobno = '".$_REQUEST['job_no']."'";
	// }
	$mjob_no = nl2br($_REQUEST['job_no']);	
	if(!empty($mjob_no) ){		
		$mjob_nos = explode('<br />', $mjob_no );
		$job_no_sql = '';
		foreach($mjob_nos as $mjob){
			if(strlen($mjob) > 4) {
				$job_no_sql .= "'".trim($mjob)."',";
			}
		}
		
		$job_no_sql = substr($job_no_sql,0,strlen($job_no_sql)-1);
		
		$query .= " and jobno in (" . $job_no_sql .")";
	}
	
	$query .= " ORDER BY vendorid,jobno,currency_id,tax2,FIELD(yewufenlei,'报关','运输','出入库','空运','海运','Local配送'),jobno_date";
	//echo $query;echo '<br><br>';
	return $query;
}

// gcustomer gaccount
function all_kehu(){
	$smower_sql = getSmowerSql();
	$acc_smower_sql = '';
	if(!empty($smower_sql['acc'])){
		$acc_smower_sql = str_replace("ld_customform18","a",$smower_sql['acc']);
	}
	$billids = '';
	if(!empty($_REQUEST['billids']) ){
		$billids = " and a.customform18id in (" . $_REQUEST['billids'].")";
	}
	$where = '';
	if(!empty($_REQUEST['duizhang'])){
		$where .= " and a.is_duizhang = '".$_REQUEST['duizhang']."'";
	}
	
	if(!empty($_REQUEST['istoerp']) && $_REQUEST['istoerp'] == '是'){
		$where .= " and a.istoerp = '是'";
	}
	if(!empty($_REQUEST['billid']) ){
		$where .= " and a.customform18id = " . $_REQUEST['billid'];
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '已对接'){
		$where .= " and a.kis_id > 0";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '未对接'){
		$where .= " and a.kis_id = 0";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && empty($_REQUEST['duizhang_enddate'])){
		$where .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."'";
	}
	if(empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$where .= " and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$where .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."' and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	if(!empty($_REQUEST['bill_mon']) ){
		$where .= " and a.bill_mon = '".$_REQUEST['bill_mon']."'";
	}
	if(!empty($_REQUEST['search_name'])){
		$where .= " and k.accountname like '%".$_REQUEST['search_name']."%'";
	}
	if(!empty($_REQUEST['creator'])){
		$where .= " and u.last_name = '".$_REQUEST['creator']."'";
	}
	$query = "
			SELECT t.*
                 , CASE
    				WHEN t.currency_id=1 THEN 1.000000
    				WHEN t.currency_id=6 THEN 
    					(SELECT conversionrate_rmbtoeur FROM ld_customform47 WHERE deleted=0 AND concat(t.bill_mon, '-01') 
    							BETWEEN validfrom AND validtill AND accountid=t.accountid ORDER BY modifiedtime DESC LIMIT 1)
    				WHEN t.currency_id=7 THEN 
    					(SELECT conversionrate_rmbtousd FROM ld_customform47 WHERE deleted=0 AND concat(t.bill_mon, '-01') 
    							BETWEEN validfrom AND validtill AND accountid=t.accountid ORDER BY modifiedtime DESC LIMIT 1)
    				WHEN t.currency_id=10 THEN 
    					(SELECT conversionrate_rmbtokrw FROM ld_customform47 WHERE deleted=0 AND concat(t.bill_mon, '-01') 
    							BETWEEN validfrom AND validtill AND accountid=t.accountid ORDER BY modifiedtime DESC LIMIT 1)
    				WHEN t.currency_id=11 THEN 
    					(SELECT conversionrate_rmbtohkd FROM ld_customform47 WHERE deleted=0 AND concat(t.bill_mon, '-01') 
    							BETWEEN validfrom AND validtill AND accountid=t.accountid ORDER BY modifiedtime DESC LIMIT 1)
    				WHEN t.currency_id=12 THEN 
    					(SELECT conversionrate_rmbtovnd FROM ld_customform47 WHERE deleted=0 AND concat(t.bill_mon, '-01') 
    							BETWEEN validfrom AND validtill AND accountid=t.accountid ORDER BY modifiedtime DESC LIMIT 1)
    			END AS conversion_rate
		FROM (
			SELECT 
				a.customform18_no AS billno,
				a.customform18id AS billid,
				a.customform18_no,
				a.accountid,
				a.istoerp,a.kis_id,
				a.is_duizhang AS zhuangtai,
				a.is_duizhang_date AS zhuangtai_date,
				a.service_type AS yewufenlei,
				k.accountname AS accountorvendor,
				j.customform03_no AS jobno,
				DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
				u.last_name AS jobno_creator,

				case when ifnull(y.invoice_no,'')='' then GROUP_CONCAT(DISTINCT e.sf407) else y.invoice_no end AS fapiaohao,
				x.cf_2823 AS chukou_date,
				'' AS jinkou_date,
				y.port_no AS kouan,
				NULL AS shouhuoren,
				e.sf138 AS pinming,
				NULL AS xiangshubanshu,
				ROUND(SUM(e.sf140),3) AS qty,
				ROUND(SUM(e.sf193),3) AS huozhi,
				y.piece AS jianshu,
				ROUND(SUM(y.gross_weight),3) AS maozhong,
				NULL AS cheixng,
				NULL AS chepai,
				CASE 
					WHEN LENGTH(LEFT(y.trans_name,1))=CHAR_LENGTH(LEFT(y.trans_name,1)) THEN y.trans_name
					ELSE ''
				 END AS liuliandanhao,
				NULL AS real_flightdate,
				NULL AS real_flightno,
				NULL AS masterorder_no,
				NULL AS fendanhao,
				NULL AS jifeizhongliang,

				CASE
					WHEN x.cf_3033='否' THEN y.apply_no
					ELSE x.cf_3034
				END AS baoguandanhao,
				p.productname AS feiyongtype,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax0,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax0,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax6,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax6,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax9,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax9,
				ROUND(b.tax_amount,2) AS weishui_amount,
				b.tax2,
				ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
				a.currency_id,
				a.currency_symbol,b.comment, uu.last_name fee_creator, a.bill_chkman, a.kis_ifman, a.bill_mon
			FROM ld_customform18 a
			LEFT JOIN ld_account k ON k.accountid=a.accountid
			lEFT JOIN ld_customform22 y ON y.customform22id=a.customform22_id
			lEFT JOIN ld_customform22scf x ON x.customform22id=y.customform22id
			LEFT JOIN ld_customform22detail d ON d.id=y.customform22id
			LEFT JOIN ld_customform22detailscf e ON e.lineitem_id=d.lineitem_id
			LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
			LEFT JOIN ld_users u ON u.id=j.smcreatorid
			LEFT JOIN ld_customform18detail b ON b.id=a.customform18id
			LEFT JOIN ld_products p ON p.productid=b.productid 
			LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.accountid
      LEFT JOIN ld_users uu ON uu.id=a.smcreatorid
			WHERE a.deleted=0
				AND a.approvestatus<>'已拒绝'
				AND a.service_type='报关' $acc_smower_sql $billids $where  
			GROUP BY a.customform18id,b.lineitem_id
			UNION ALL
			SELECT 
				a.customform18_no AS billno,
				a.customform18id AS billid,
				a.customform18_no,
				a.accountid,
				a.istoerp,a.kis_id,
				a.is_duizhang AS zhuangtai,
				a.is_duizhang_date AS zhuangtai_date,
				a.service_type AS yewufenlei,
				k.accountname AS accountorvendor,
				j.customform03_no AS jobno,
				DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
				u.last_name AS jobno_creator,

				GROUP_CONCAT(DISTINCT e.sf157) AS fapiaohao,
				y.ship_date AS chukou_date,
				NULL AS jinkou_date,
				y.customs_port AS kouan,
				e.sf156 AS shouhuoren,
				e.sf165 AS pinming,
				ROUND(SUM(distinct e.sf164),0) AS xiangshubanshu,
				ROUND(SUM(distinct e.sf167),3) AS qty,
				NULL AS huozhi,
				NULL AS jianshu,
				ROUND(SUM(e.sf204),3) AS maozhong,
				y.carriage_type AS chexing,
				(
					SELECT 
						CASE
							WHEN ld_customform02scf.cf_3714='内部司机' THEN ld_project.projectname
							ELSE ld_customform02.chepaihao
						END AS chepai
					FROM ld_customform02
                    LEFT JOIN ld_customform02scf ON ld_customform02scf.customform02id=ld_customform02.customform02id
					LEFT JOIN ld_project ON ld_project.projectid=ld_customform02.projectid
					WHERE ld_customform02.deleted=0 
						AND ld_customform02.approvestatus<>'已拒绝' 
						AND (
							ld_customform02.yunshudanid_01=a.customform23_id 
								OR ld_customform02.yunshudanid_02=a.customform23_id  
								OR ld_customform02.yunshudanid_03=a.customform23_id  
								OR ld_customform02.yunshudanid_04=a.customform23_id 
							)
					ORDER BY ld_customform02.modifiedtime DESC LIMIT 1
				) AS chepai,
				NULL AS liuliandanhao,
				NULL AS real_flightdate,
				NULL AS real_flightno,
				NULL AS masterorder_no,
				NULL AS fendanhao,
				NULL AS jifeizhongliang,

				y.customform23_no AS yewudanhao,
				p.productname AS feiyongtype,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax0,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax0,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax6,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax6,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax9,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax9,
				ROUND(b.tax_amount,2) AS weishui_amount,
				b.tax2,
				ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
				a.currency_id,
				a.currency_symbol,b.comment, uu.last_name fee_creator, a.bill_chkman, a.kis_ifman, a.bill_mon
			FROM ld_customform18 a
			LEFT JOIN ld_account k ON k.accountid=a.accountid
			lEFT JOIN ld_customform23 y ON y.customform23id=a.customform23_id
			lEFT JOIN ld_customform23scf x ON x.customform23id=y.customform23id
			LEFT JOIN ld_customform23detail d ON d.id=y.customform23id
			LEFT JOIN ld_customform23detailscf e ON e.lineitem_id=d.lineitem_id
			LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
			LEFT JOIN ld_users u ON u.id=j.smcreatorid
			LEFT JOIN ld_customform18detail b ON b.id=a.customform18id
			LEFT JOIN ld_products p ON p.productid=b.productid 
			LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.accountid
      LEFT JOIN ld_users uu ON uu.id=a.smcreatorid 
			WHERE a.deleted=0
				AND a.approvestatus<>'已拒绝'
				AND a.service_type='运输' $acc_smower_sql $billids $where 
			GROUP BY a.customform18id,b.lineitem_id
			UNION ALL
			SELECT 
				a.customform18_no AS billno,
				a.customform18id AS billid,
				a.customform18_no,
				a.accountid,
				a.istoerp,a.kis_id,
				a.is_duizhang AS zhuangtai,
				a.is_duizhang_date AS zhuangtai_date,
				a.service_type AS yewufenlei,
				k.accountname AS accountorvendor,
				j.customform03_no AS jobno,
				DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
				u.last_name AS jobno_creator,

				GROUP_CONCAT(DISTINCT d.fapiao_no) AS fapiaohao,
				ifnull(y.in_date,y.out_date) AS chukou_date,
				NULL AS jinkou_date,
				NULL AS kouan,
				NULL AS shouhuoren,
				d.product_name AS pinming,
				ROUND(SUM(d.quantity),0) AS xiangshubanshu,
				ROUND(SUM(e.sf217),3) AS qty,
				NULL AS huozhi,
				NULL AS jianshu,
				ROUND(SUM(e.sf215),3) AS maozhong,
				NULL AS cheixng,
				NULL AS chepai,
				NULL AS liuliandanhao,
				NULL AS real_flightdate,
				NULL AS real_flightno,
				NULL AS masterorder_no,
				NULL AS fendanhao,
				NULL AS jifeizhongliang,

				y.commission_no AS yewudanhao,
				p.productname AS feiyongtype,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax0,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax0,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax6,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax6,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax9,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax9,
				ROUND(b.tax_amount,2) AS weishui_amount,
				b.tax2,
				ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
				a.currency_id,
				a.currency_symbol,b.comment, uu.last_name fee_creator, a.bill_chkman, a.kis_ifman, a.bill_mon
			FROM ld_customform18 a
			LEFT JOIN ld_account k ON k.accountid=a.accountid
			lEFT JOIN ld_commission y ON y.commission_id=a.commission_id
			LEFT JOIN ld_commission2payment d ON d.commission_id=y.commission_id
			LEFT JOIN ld_commission2paymentscf e ON e.commission2payment_id=d.commission2payment_id
			LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
			LEFT JOIN ld_users u ON u.id=j.smcreatorid
			LEFT JOIN ld_customform18detail b ON b.id=a.customform18id
			LEFT JOIN ld_products p ON p.productid=b.productid 
			LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.accountid
      LEFT JOIN ld_users uu ON uu.id=a.smcreatorid 
			WHERE a.deleted=0
				AND a.approvestatus<>'已拒绝'
				AND a.service_type='出入库' $acc_smower_sql $billids $where 
			GROUP BY a.customform18id,b.lineitem_id
			UNION ALL
			SELECT 
				a.customform18_no AS billno,
				a.customform18id AS billid,
				a.customform18_no,
				a.accountid,
				a.istoerp,a.kis_id,
				a.is_duizhang AS zhuangtai,
				a.is_duizhang_date AS zhuangtai_date,
				a.service_type AS yewufenlei,
				k.accountname AS accountorvendor,
				j.customform03_no AS jobno,
				DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
				u.last_name AS jobno_creator,

				NULL AS fapiaohao,
				IFNULL(x.real_flightdate, y.flight_date) AS chukou_date,
				NULL AS jinkou_date,
				NULL AS kouan,
				NULL AS shouhuoren,
				e.sf170 AS pinming,
				NULL AS xiangshubanshu,
				NULL AS qty,
				NULL AS huozhi,
				ROUND(SUM(distinct e.sf171),3) AS jianshu,
				ROUND(SUM(distinct e.sf174),3) AS maozhong,
				NULL AS cheixng,
				NULL AS chepai,
				NULL AS liuliandanhao,
				x.real_flightdate,
				x.real_flightno,
				x.masterorder_no,
				GROUP_CONCAT(IFNULL(e.sf169,'') SEPARATOR '
			') AS fendanhao,
				GROUP_CONCAT(ROUND(IFNULL(e.sf174,0),3) SEPARATOR '
			') AS jifeizhongliang,

				y.customform24_no AS yewudanhao,
				p.productname AS feiyongtype,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax0,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax0,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax6,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax6,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax9,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax9,
				ROUND(b.tax_amount,2) AS weishui_amount,
				b.tax2,
				ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
				a.currency_id,
				a.currency_symbol,b.comment, uu.last_name fee_creator, a.bill_chkman, a.kis_ifman, a.bill_mon
			FROM ld_customform18 a
			LEFT JOIN ld_account k ON k.accountid=a.accountid
			lEFT JOIN ld_customform24 y ON y.customform24id=a.customform24_id
			LEFT JOIN ld_customform25 x ON x.customform24_id=y.customform24id AND x.deleted=0
			LEFT JOIN ld_customform25detail d ON d.id=x.customform25id
			LEFT JOIN ld_customform25detailscf e ON e.lineitem_id=d.lineitem_id
			LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
			LEFT JOIN ld_users u ON u.id=j.smcreatorid
			LEFT JOIN ld_customform18detail b ON b.id=a.customform18id
			LEFT JOIN ld_products p ON p.productid=b.productid 
			LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.accountid
      LEFT JOIN ld_users uu ON uu.id=a.smcreatorid 
			WHERE a.deleted=0
				AND a.approvestatus<>'已拒绝'
				AND a.service_type='空运' $acc_smower_sql $billids $where 
			GROUP BY a.customform18id,b.lineitem_id
			UNION ALL
			SELECT 
				a.customform18_no AS billno,
				a.customform18id AS billid,
				a.customform18_no,
				a.accountid,
				a.istoerp,a.kis_id,
				a.is_duizhang AS zhuangtai,
				a.is_duizhang_date AS zhuangtai_date,
				a.service_type AS yewufenlei,
				k.accountname AS accountorvendor,
				j.customform03_no AS jobno,
				DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
				u.last_name AS jobno_creator,
				
				NULL AS fapiaohao,
				xx.cf_3664 AS chukou_date,
				NULL AS jinkou_date,
				NULL AS kouan,
				NULL AS shouhuoren,
				e.sf218 AS pinming,
				ROUND(SUM(e.sf223+e.sf224),0) AS xiangshubanshu,
				ROUND(SUM(e.sf132),3) AS qty,
				NULL AS huozhi,
				NULL AS jianshu,
				ROUND(SUM(e.sf135),3) AS maozhong,
				NULL AS cheixng,
				NULL AS chepai,
				NULL AS liuliandanhao,
				NULL AS real_flightdate,
				NULL AS real_flightno,
				NULL AS masterorder_no,
				NULL AS fendanhao,
				NULL AS jifeizhongliang,

				y.customform21_no AS yewudanhao,
				p.productname AS feiyongtype,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax0,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax0,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax6,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax6,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax9,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax9,
				ROUND(b.tax_amount,2) AS weishui_amount,
				b.tax2,
				ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
				a.currency_id,
				a.currency_symbol,b.comment, uu.last_name fee_creator, a.bill_chkman, a.kis_ifman, a.bill_mon
			FROM ld_customform18 a
			LEFT JOIN ld_account k ON k.accountid=a.accountid
			lEFT JOIN ld_customform21 y ON y.customform21id=a.customform21_id
			LEFT JOIN ld_customform26 x ON x.customform21_id=y.customform21id AND x.deleted=0
			LEFT JOIN ld_customform26scf xx ON x.customform26id = xx.customform26id
			LEFT JOIN ld_customform26detail d ON d.id=x.customform26id
			LEFT JOIN ld_customform26detailscf e ON e.lineitem_id=d.lineitem_id
			LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
			LEFT JOIN ld_users u ON u.id=j.smcreatorid
			LEFT JOIN ld_customform18detail b ON b.id=a.customform18id
			LEFT JOIN ld_products p ON p.productid=b.productid 
			LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.accountid 
      LEFT JOIN ld_users uu ON uu.id=a.smcreatorid
			WHERE a.deleted=0
				AND a.approvestatus<>'已拒绝'
				AND a.service_type='海运' $acc_smower_sql $billids $where 
			GROUP BY a.customform18id,b.lineitem_id
			UNION ALL
			SELECT 
				a.customform18_no AS billno,
				a.customform18id AS billid,
				a.customform18_no,
				a.accountid,
				a.istoerp,a.kis_id,
				a.is_duizhang AS zhuangtai,
				a.is_duizhang_date AS zhuangtai_date,
				a.service_type AS yewufenlei,
				k.accountname AS accountorvendor,
				j.customform03_no AS jobno,
				DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
				u.last_name AS jobno_creator,

				GROUP_CONCAT(DISTINCT e.sf388) AS fapiaohao,
				z.cf_3688 AS chukou_date,
				NULL AS jinkou_date,
				NULL AS kouan,
				NULL AS shouhuoren,
				e.sf392 AS pinming,
				ROUND(SUM(e.sf395),0) AS xiangshubanshu,
				ROUND(SUM(e.sf394),3) AS qty,
				NULL AS huozhi,
				NULL AS jianshu,
				ROUND(SUM(e.sf389),3) AS maozhong,
				NULL AS cheixng,
				NULL AS chepai,
				NULL AS liuliandanhao,
				NULL AS real_flightdate,
				NULL AS real_flightno,
				NULL AS masterorder_no,
				NULL AS fendanhao,
				NULL AS jifeizhongliang,

				y.customform27_no AS yewudanhao,
				p.productname AS feiyongtype,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax0,
				CASE
					WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax0,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax6,
				CASE
					WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax6,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
					ELSE 0
				END AS weishui_amount_tax9,
				CASE
					WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
					ELSE 0
				END AS hanshui_amount_tax9,
				ROUND(b.tax_amount,2) AS weishui_amount,
				b.tax2,
				ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
				a.currency_id,
				a.currency_symbol,b.comment, uu.last_name fee_creator, a.bill_chkman, a.kis_ifman, a.bill_mon
			FROM ld_customform18 a
			LEFT JOIN ld_account k ON k.accountid=a.accountid
			lEFT JOIN ld_customform27 y ON y.customform27id=a.customform27_id
      LEFT JOIN ld_customform27scf z ON y.customform27id = z.customform27id
			LEFT JOIN ld_customform27detail d ON d.id=y.customform27id
			LEFT JOIN ld_customform27detailscf e ON e.lineitem_id=d.lineitem_id
			LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
			LEFT JOIN ld_users u ON u.id=j.smcreatorid
			LEFT JOIN ld_customform18detail b ON b.id=a.customform18id
			LEFT JOIN ld_products p ON p.productid=b.productid 
			LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.accountid
      LEFT JOIN ld_users uu ON uu.id=a.smcreatorid 
			WHERE a.deleted=0
				AND a.approvestatus<>'已拒绝'
				AND a.service_type='Local配送' $acc_smower_sql $billids $where  
				GROUP BY a.customform18id,b.lineitem_id 
			
		) t where 1=1 
		
	";
	
	if(!empty($_REQUEST['job_starttime']) && empty($_REQUEST['job_endtime'])){
		$query .= " and chukou_date >= '".$_REQUEST['job_starttime']."'";
	}
	if(empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and chukou_date <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and chukou_date >= '".$_REQUEST['job_starttime']."' and chukou_date <= '".$_REQUEST['job_endtime']."'";
	}
	// if(!empty($_REQUEST['job_no'])){
		// $query .= " and jobno = '".$_REQUEST['job_no']."'";
	// }
	
	$mjob_no = nl2br($_REQUEST['job_no']);	
	if(!empty($mjob_no) ){		
		$mjob_nos = explode('<br />', $mjob_no );
		$job_no_sql = '';
		foreach($mjob_nos as $mjob){
			if(strlen($mjob) > 4) {
				$job_no_sql .= "'".trim($mjob)."',";
			}
		}
		
		$job_no_sql = substr($job_no_sql,0,strlen($job_no_sql)-1);
		
		$query .= " and jobno in (" . $job_no_sql .")";
	}
	
	$query .= " ORDER BY accountid,jobno,tax2,currency_id,FIELD(yewufenlei,'报关','运输','出入库','空运','海运','Local配送'),jobno_date";
	//echo $query;echo '<br><br>';
	return $query;
}
//Local配送
function peisong(){
	global $adb;
	$data = array();
	if(empty($_REQUEST['baoguan_leixing']) || $_REQUEST['baoguan_leixing'] == 'account'){
		$query = peisong_kehu();
	}else{
		$query = peisong_gongyingshang();
	}
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	$subtotal = array();$billid_array = array();
	$currency_info = getCurrencyInfo();
	if($num_rows > 0){
		for($i = 0; $i < $num_rows; $i++){
			$billno = $adb->query_result($result,$i,'billno');	
			$billid = $adb->query_result($result,$i,'billid');	//单据ID
			$_REQUEST['istoerp'] = $adb->query_result($result,$i,'istoerp');	//是否对接金蝶
			$zhuangtai = $adb->query_result($result,$i,'zhuangtai');	//对账状态
			$zhuangtai_date = $adb->query_result($result,$i,'zhuangtai_date');	//对账日期
			$yewufenlei = $adb->query_result($result,$i,'yewufenlei');	//业务分类
			$accountorvendor = $adb->query_result($result,$i,'accountorvendor');	//客户/供应商
			$jobno = $adb->query_result($result,$i,'jobno');	//JOB NO
			$jobno_date = $adb->query_result($result,$i,'jobno_date');	//JOB NO日期
			$jobno_creator = $adb->query_result($result,$i,'jobno_creator');	//JOB NO创建人
			$yewudanhao = $adb->query_result($result,$i,'yewudanhao');	//Local配送单号
			$feiyongtype = $adb->query_result($result,$i,'feiyongtype');	//费用项目
			$weishui_amount_tax0 = $adb->query_result($result,$i,'weishui_amount_tax0');	
			$hanshui_amount_tax0 = $adb->query_result($result,$i,'hanshui_amount_tax0');	
			$weishui_amount_tax6 = $adb->query_result($result,$i,'weishui_amount_tax6');	
			$hanshui_amount_tax6 = $adb->query_result($result,$i,'hanshui_amount_tax6');	
			$weishui_amount_tax9 = $adb->query_result($result,$i,'weishui_amount_tax9');	
			$hanshui_amount_tax9 = $adb->query_result($result,$i,'hanshui_amount_tax9');
			$shui = $adb->query_result($result,$i,'shui');		//税
			$weishui_amount = $adb->query_result($result,$i,'weishui_amount');	
			$hanshui_amount = $adb->query_result($result,$i,'hanshui_amount');	
			$currency_id = $adb->query_result($result,$i,'currency_id');	//货值
			$currency_symbol = $adb->query_result($result,$i,'currency_symbol');
			$conversion_rate = $adb->query_result($result,$i,'conversion_rate');
			$kis_id = $adb->query_result($result,$i,'kis_id');
			$comment = $adb->query_result($result,$i,'comment');	//备注
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['currency_symbol'] = $currency_symbol;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax0'] += $weishui_amount_tax0;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax0'] += $hanshui_amount_tax0;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax6'] += $weishui_amount_tax6;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax6'] += $hanshui_amount_tax6;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax9'] += $weishui_amount_tax9;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax9'] += $hanshui_amount_tax9;
			if($currency_id > 1){
				$weishui_amount_tax0 = $weishui_amount_tax0*$conversion_rate;
				$hanshui_amount_tax0 = $hanshui_amount_tax0*$conversion_rate;
				$weishui_amount_tax6 = $weishui_amount_tax6*$conversion_rate;
				$hanshui_amount_tax6 = $hanshui_amount_tax6*$conversion_rate;
				$weishui_amount_tax9 = $weishui_amount_tax9*$conversion_rate;
				$hanshui_amount_tax9 = $hanshui_amount_tax9*$conversion_rate;
			}
			$total[$accountorvendor]['weishui_amount_tax0'] += $weishui_amount_tax0;
			$total[$accountorvendor]['hanshui_amount_tax0'] += $hanshui_amount_tax0;
			$total[$accountorvendor]['weishui_amount_tax6'] += $weishui_amount_tax6;
			$total[$accountorvendor]['hanshui_amount_tax6'] += $hanshui_amount_tax6;
			$total[$accountorvendor]['weishui_amount_tax9'] += $weishui_amount_tax9;
			$total[$accountorvendor]['hanshui_amount_tax9'] += $hanshui_amount_tax9;
			$billid_array[] = $billid;
			$data[] = array(
				'billno' => $adb->query_result($result,$i,'billno'),
				'billid' => $billid,
				'istoerp' => $_REQUEST['istoerp'],
				'zhuangtai' => $zhuangtai,
				'zhuangtai_date' => $zhuangtai_date,
				'kis_id' => $kis_id,
				'yewufenlei' => $yewufenlei,
				'accountorvendor' => $accountorvendor,
				'jobno' => $jobno,
				'jobno_date' => $jobno_date,
				'jobno_creator' => $jobno_creator,
				'yewudanhao' => $yewudanhao,
				'feiyongtype' => $feiyongtype,
				'shui' => $shui,
				'weishui_amount' => $weishui_amount,
				'hanshui_amount' => $hanshui_amount,
				'comment' => $comment,
				'currency_name' => $currency_info[$currency_id],
				'currency_id' => $currency_id,
				'currency_symbol' => $currency_symbol,
			);
		}
	}
	$total = setTotal($subtotal,$total);$list = setData($data);
	return array('list'=>$list,'subtotal'=>$subtotal,'total'=>$total,'billids'=>$billid_array);
}
//Local配送  客户
function peisong_kehu(){
	$smower_sql = getSmowerSql();
	$acc_smower_sql = '';
	if(!empty($smower_sql['acc'])){
		$acc_smower_sql = str_replace("ld_customform18","a",$smower_sql['acc']);
	}
	$query = "
		SELECT 
			a.customform18_no AS billno,
			a.customform18id AS billid,
			a.istoerp,
			a.is_duizhang AS zhuangtai,
			a.is_duizhang_date AS zhuangtai_date,
			a.service_type AS yewufenlei,
			k.accountname AS accountorvendor,
			j.customform03_no AS jobno,
			DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
			u.last_name AS jobno_creator,

			y.customform27_no AS yewudanhao,

			p.productname AS feiyongtype,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax0,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax0,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax6,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax6,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax9,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax9,
			ROUND(b.tax_amount,2) AS weishui_amount,
			ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
			b.tax2 as shui,
			a.currency_id,
			a.currency_symbol,
			CASE
				WHEN a.currency_id=1 THEN 1.000000
				WHEN a.currency_id=6 THEN 
					(SELECT conversionrate_rmbtoeur FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=10 THEN 
					(SELECT conversionrate_rmbtokrw FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=11 THEN 
					(SELECT conversionrate_rmbtohkd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=12 THEN 
					(SELECT conversionrate_rmbtovnd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
			END AS conversion_rate,
            a.kis_id,b.comment
		FROM ld_customform18 a
		LEFT JOIN ld_account k ON k.accountid=a.accountid
		lEFT JOIN ld_customform27 y ON y.customform27id=a.customform21_id
		LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
		LEFT JOIN ld_users u ON u.id=j.smcreatorid
		LEFT JOIN ld_customform18detail b ON b.id=a.customform18id
		LEFT JOIN ld_products p ON p.productid=b.productid LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.accountid 
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND a.service_type='Local配送' $acc_smower_sql 
	";
	if(!empty($_REQUEST['search_name'])){
		$query .= " and accountname like '%".$_REQUEST['search_name']."%'";
	}
	if(!empty($_REQUEST['job_starttime']) && empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."'";
	}
	if(empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."' and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_no'])){
		$query .= " and customform03_no = '".$_REQUEST['job_no']."'";
	}
	if(!empty($_REQUEST['duizhang'])){
		$query .= " and a.is_duizhang = '".$_REQUEST['duizhang']."'";
	}
	if(!empty($_REQUEST['creator'])){
		$query .= " and u.last_name = '".$_REQUEST['creator']."'";
	}
	if(!empty($_REQUEST['istoerp']) && $_REQUEST['istoerp'] == '是'){
		$query .= " and a.istoerp = '是'";
	}
	if(!empty($_REQUEST['billid']) ){
		$query .= " and a.customform18id = " . $_REQUEST['billid'];
	}
	if(!empty($_REQUEST['billids']) ){
		$query .= " and a.customform18id in (" . $_REQUEST['billids'].")";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '已对接'){
		$query .= " and a.kis_id > 0";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '未对接'){
		$query .= " and a.kis_id = 0";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."'";
	}
	if(empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."' and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	$query .= " GROUP BY a.customform18id,b.lineitem_id ORDER BY jobno,a.accountid,b.tax2,a.currency_id,jobno_date";
	return $query;
}
//Local配送
function peisong_gongyingshang(){
	$smower_sql = getSmowerSql();
	$ven_smower_sql = '';
	if(!empty($smower_sql['ven'])){
		$ven_smower_sql = str_replace("ld_customform19","a",$smower_sql['ven']);
	}
	$query = "
		SELECT 
			a.customform19_no AS billno,
			a.customform19id AS billid,
			a.istoerp,
			a.is_duizhang AS zhuangtai,
			a.is_duizhang_date AS zhuangtai_date,
			a.service_type AS yewufenlei,
			k.vendorname AS accountorvendor,
			j.customform03_no AS jobno,
			DATE_FORMAT(MAX(j.createdtime),'%Y-%m-%d') AS jobno_date,
			u.last_name AS jobno_creator,

			y.customform28_no AS yewudanhao,

			p.productname AS feiyongtype,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax0,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax0,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax6,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax6,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax9,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax9,
			ROUND(b.tax_amount,2) AS weishui_amount,
			ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
			b.tax2 as shui,
			a.currency_id,
			a.currency_symbol,
			CASE
				WHEN a.currency_id=1 THEN 1.000000
				WHEN a.currency_id=6 THEN 
					(SELECT conversionrate_rmbtoeur FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=10 THEN 
					(SELECT conversionrate_rmbtokrw FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=11 THEN 
					(SELECT conversionrate_rmbtohkd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=12 THEN 
					(SELECT conversionrate_rmbtovnd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
			END AS conversion_rate,
            a.kis_id,b.comment
		FROM ld_customform19 a
		LEFT JOIN ld_vendor k ON k.vendorid=a.vendorid
		lEFT JOIN ld_customform28 y ON y.customform28id=a.customform28_id
		LEFT JOIN ld_customform28detail d ON d.id=y.customform28id
		LEFT JOIN ld_customform27 c ON c.customform27id=d.entitytypeid
		LEFT JOIN ld_customform03 j ON j.customform03id=c.customform27id
		LEFT JOIN ld_users u ON u.id=j.smcreatorid
		LEFT JOIN ld_customform19detail b ON b.id=a.customform19id
		LEFT JOIN ld_products p ON p.productid=b.productid 
		LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.vendorid 
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND a.service_type='Local配送' $ven_smower_sql 
	";
	if(!empty($_REQUEST['search_name'])){
		$query .= " and vendorname like '%".$_REQUEST['search_name']."%'";
	}
	if(!empty($_REQUEST['job_starttime']) && empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."'";
	}
	if(empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."' and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_no'])){
		$query .= " and customform03_no = '".$_REQUEST['job_no']."'";
	}
	if(!empty($_REQUEST['duizhang'])){
		$query .= " and a.is_duizhang = '".$_REQUEST['duizhang']."'";
	}
	if(!empty($_REQUEST['creator'])){
		$query .= " and u.last_name = '".$_REQUEST['creator']."'";
	}
	if(!empty($_REQUEST['istoerp']) && $_REQUEST['istoerp'] == '是'){
		$query .= " and a.istoerp = '是'";
	}
	if(!empty($_REQUEST['billid']) ){
		$query .= " and a.customform19id = " . $_REQUEST['billid'];
	}
	if(!empty($_REQUEST['billids']) ){
		$query .= " and a.customform19id in (" . $_REQUEST['billids'].")";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '已对接'){
		$query .= " and a.kis_id > 0";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '未对接'){
		$query .= " and a.kis_id = 0";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."'";
	}
	if(empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."' and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	$query .= " GROUP BY a.customform19id,b.lineitem_id ORDER BY jobno,a.vendorid,b.tax2,a.currency_id,jobno_date";
	return $query;
}
//海运
function haiyun(){
	global $adb;
	$data = array();
	if(empty($_REQUEST['baoguan_leixing']) || $_REQUEST['baoguan_leixing'] == 'account'){
		$query = haiyun_kehu();
	}else{
		$query = haiyun_gongyingshang();
	}
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	$subtotal = array();$billid_array = array();
	$currency_info = getCurrencyInfo();
	if($num_rows > 0){
		for($i = 0; $i < $num_rows; $i++){
			$billno = $adb->query_result($result,$i,'billno');	
			$billid = $adb->query_result($result,$i,'billid');	//单据ID
			$_REQUEST['istoerp'] = $adb->query_result($result,$i,'istoerp');	//是否对接金蝶
			$zhuangtai = $adb->query_result($result,$i,'zhuangtai');	//对账状态
			$zhuangtai_date = $adb->query_result($result,$i,'zhuangtai_date');
			$yewufenlei = $adb->query_result($result,$i,'yewufenlei');	//业务分类
			$accountorvendor = $adb->query_result($result,$i,'accountorvendor');	//客户/供应商
			$jobno = $adb->query_result($result,$i,'jobno');	//JOB NO
			$jobno_date = $adb->query_result($result,$i,'jobno_date');	//JOB NO日期
			$jobno_creator = $adb->query_result($result,$i,'jobno_creator');	//JOB NO创建人
			$yewudanhao = $adb->query_result($result,$i,'yewudanhao');	//海运单号
			$feiyongtype = $adb->query_result($result,$i,'feiyongtype');	//费用项目
			$weishui_amount_tax0 = $adb->query_result($result,$i,'weishui_amount_tax0');	
			$hanshui_amount_tax0 = $adb->query_result($result,$i,'hanshui_amount_tax0');	
			$weishui_amount_tax6 = $adb->query_result($result,$i,'weishui_amount_tax6');	
			$hanshui_amount_tax6 = $adb->query_result($result,$i,'hanshui_amount_tax6');	
			$weishui_amount_tax9 = $adb->query_result($result,$i,'weishui_amount_tax9');	
			$hanshui_amount_tax9 = $adb->query_result($result,$i,'hanshui_amount_tax9');
			$shui = $adb->query_result($result,$i,'shui');		//税
			$weishui_amount = $adb->query_result($result,$i,'weishui_amount');	
			$hanshui_amount = $adb->query_result($result,$i,'hanshui_amount');	
			$currency_id = $adb->query_result($result,$i,'currency_id');	//货值
			$currency_symbol = $adb->query_result($result,$i,'currency_symbol');
			$conversion_rate = $adb->query_result($result,$i,'conversion_rate');
			$kis_id = $adb->query_result($result,$i,'kis_id');
			$comment = $adb->query_result($result,$i,'comment');	//备注
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['currency_symbol'] = $currency_symbol;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax0'] += $weishui_amount_tax0;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax0'] += $hanshui_amount_tax0;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax6'] += $weishui_amount_tax6;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax6'] += $hanshui_amount_tax6;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax9'] += $weishui_amount_tax9;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax9'] += $hanshui_amount_tax9;
			if($currency_id > 1){
				$weishui_amount_tax0 = $weishui_amount_tax0*$conversion_rate;
				$hanshui_amount_tax0 = $hanshui_amount_tax0*$conversion_rate;
				$weishui_amount_tax6 = $weishui_amount_tax6*$conversion_rate;
				$hanshui_amount_tax6 = $hanshui_amount_tax6*$conversion_rate;
				$weishui_amount_tax9 = $weishui_amount_tax9*$conversion_rate;
				$hanshui_amount_tax9 = $hanshui_amount_tax9*$conversion_rate;
			}
			$total[$accountorvendor]['weishui_amount_tax0'] += $weishui_amount_tax0;
			$total[$accountorvendor]['hanshui_amount_tax0'] += $hanshui_amount_tax0;
			$total[$accountorvendor]['weishui_amount_tax6'] += $weishui_amount_tax6;
			$total[$accountorvendor]['hanshui_amount_tax6'] += $hanshui_amount_tax6;
			$total[$accountorvendor]['weishui_amount_tax9'] += $weishui_amount_tax9;
			$total[$accountorvendor]['hanshui_amount_tax9'] += $hanshui_amount_tax9;
			$billid_array[] = $billid;
			$data[] = array(
				'billno' => $adb->query_result($result,$i,'billno'),
				'billid' => $billid,
				'istoerp' => $_REQUEST['istoerp'],
				'zhuangtai' => $zhuangtai,
				'zhuangtai_date' => $zhuangtai_date,
				'kis_id' => $kis_id,
				'yewufenlei' => $yewufenlei,
				'accountorvendor' => $accountorvendor,
				'jobno' => $jobno,
				'jobno_date' => $jobno_date,
				'jobno_creator' => $jobno_creator,
				'yewudanhao' => $yewudanhao,
				'feiyongtype' => $feiyongtype,
				'shui' => $shui,
				'weishui_amount' => $weishui_amount,
				'hanshui_amount' => $hanshui_amount,
				'comment' => $comment,
				'currency_name' => $currency_info[$currency_id],
				'currency_id' => $currency_id,
				'currency_symbol' => $currency_symbol,
			);
		}
	}
	$total = setTotal($subtotal,$total);$list = setData($data);
	return array('list'=>$list,'subtotal'=>$subtotal,'total'=>$total,'billids'=>$billid_array);
}
//海运  客户
function haiyun_kehu(){
	$smower_sql = getSmowerSql();
	$acc_smower_sql = '';
	if(!empty($smower_sql['acc'])){
		$acc_smower_sql = str_replace("ld_customform18","a",$smower_sql['acc']);
	}
	$query = "
		SELECT 
			a.customform18_no AS billno,
			a.customform18id AS billid,
			a.istoerp,
			a.is_duizhang AS zhuangtai,
			a.is_duizhang_date AS zhuangtai_date,
			a.service_type AS yewufenlei,
			k.accountname AS accountorvendor,
			j.customform03_no AS jobno,
			DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
			u.last_name AS jobno_creator,

			y.customform21_no AS yewudanhao,

			p.productname AS feiyongtype,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax0,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax0,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax6,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax6,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax9,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax9,
			ROUND(b.tax_amount,2) AS weishui_amount,
			ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
			b.tax2 as shui,
			a.currency_id,
			a.currency_symbol,
			CASE
				WHEN a.currency_id=1 THEN 1.000000
				WHEN a.currency_id=6 THEN 
					(SELECT conversionrate_rmbtoeur FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=10 THEN 
					(SELECT conversionrate_rmbtokrw FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=11 THEN 
					(SELECT conversionrate_rmbtohkd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=12 THEN 
					(SELECT conversionrate_rmbtovnd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
			END AS conversion_rate,
            a.kis_id,b.comment
		FROM ld_customform18 a
		LEFT JOIN ld_account k ON k.accountid=a.accountid
		lEFT JOIN ld_customform21 y ON y.customform21id=a.customform21_id
		LEFT JOIN ld_customform26 x ON x.customform21_id=y.customform21id AND x.deleted=0
		LEFT JOIN ld_customform26detail d ON d.id=x.customform26id
		LEFT JOIN ld_customform26detailscf e ON e.lineitem_id=d.lineitem_id
		LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
		LEFT JOIN ld_users u ON u.id=j.smcreatorid
		LEFT JOIN ld_customform18detail b ON b.id=a.customform18id
		LEFT JOIN ld_products p ON p.productid=b.productid 
		LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.accountid 
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND a.service_type='海运' $acc_smower_sql 
	";
	if(!empty($_REQUEST['search_name'])){
		$query .= " and accountname like '%".$_REQUEST['search_name']."%'";
	}
	if(!empty($_REQUEST['job_starttime']) && empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."'";
	}
	if(empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."' and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_no'])){
		$query .= " and customform03_no = '".$_REQUEST['job_no']."'";
	}
	if(!empty($_REQUEST['duizhang'])){
		$query .= " and a.is_duizhang = '".$_REQUEST['duizhang']."'";
	}
	if(!empty($_REQUEST['creator'])){
		$query .= " and u.last_name = '".$_REQUEST['creator']."'";
	}
	if(!empty($_REQUEST['istoerp']) && $_REQUEST['istoerp'] == '是'){
		$query .= " and a.istoerp = '是'";
	}
	if(!empty($_REQUEST['billid']) ){
		$query .= " and a.customform18id = " . $_REQUEST['billid'];
	}
	if(!empty($_REQUEST['billids']) ){
		$query .= " and a.customform18id in (" . $_REQUEST['billids'].")";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '已对接'){
		$query .= " and a.kis_id > 0";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '未对接'){
		$query .= " and a.kis_id = 0";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."'";
	}
	if(empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."' and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	$query .= " GROUP BY a.customform18id,b.lineitem_id ORDER BY jobno,a.accountid,b.tax2,a.currency_id,jobno_date";
	return $query;
}
//海运 - 供应商
function haiyun_gongyingshang(){
	$smower_sql = getSmowerSql();
	$ven_smower_sql = '';
	if(!empty($smower_sql['ven'])){
		$ven_smower_sql = str_replace("ld_customform19","a",$smower_sql['ven']);
	}
	$query = "
		SELECT 
			a.customform19_no AS billno,
			a.customform19id AS billid,
			a.istoerp,
			a.is_duizhang AS zhuangtai,
			a.is_duizhang_date AS zhuangtai_date,
			a.service_type AS yewufenlei,
			k.vendorname AS accountorvendor,
			j.customform03_no AS jobno,
			DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
			u.last_name AS jobno_creator,

			y.customform21_no AS yewudanhao,

			p.productname AS feiyongtype,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax0,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax0,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax6,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax6,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax9,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax9,
			ROUND(b.tax_amount,2) AS weishui_amount,
			ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
			b.tax2 as shui,
			a.currency_id,
			a.currency_symbol,
			CASE
				WHEN a.currency_id=1 THEN 1.000000
				WHEN a.currency_id=6 THEN 
					(SELECT conversionrate_rmbtoeur FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=10 THEN 
					(SELECT conversionrate_rmbtokrw FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=11 THEN 
					(SELECT conversionrate_rmbtohkd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=12 THEN 
					(SELECT conversionrate_rmbtovnd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
			END AS conversion_rate,
            a.kis_id,b.comment
		FROM ld_customform19 a
		LEFT JOIN ld_vendor k ON k.vendorid=a.vendorid
		lEFT JOIN ld_customform21 y ON y.customform21id=a.customform21_id
		LEFT JOIN ld_customform26 x ON x.customform21_id=y.customform21id AND x.deleted=0
		LEFT JOIN ld_customform26detail d ON d.id=x.customform26id
		LEFT JOIN ld_customform26detailscf e ON e.lineitem_id=d.lineitem_id
		LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
		LEFT JOIN ld_users u ON u.id=j.smcreatorid
		LEFT JOIN ld_customform19detail b ON b.id=a.customform19id
		LEFT JOIN ld_products p ON p.productid=b.productid 
		LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.vendorid 
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND a.service_type='海运' $ven_smower_sql
	";
	if(!empty($_REQUEST['search_name'])){
		$query .= " and vendorname like '%".$_REQUEST['search_name']."%'";
	}
	if(!empty($_REQUEST['job_starttime']) && empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."'";
	}
	if(empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."' and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_no'])){
		$query .= " and customform03_no = '".$_REQUEST['job_no']."'";
	}
	if(!empty($_REQUEST['duizhang'])){
		$query .= " and a.is_duizhang = '".$_REQUEST['duizhang']."'";
	}
	if(!empty($_REQUEST['creator'])){
		$query .= " and u.last_name = '".$_REQUEST['creator']."'";
	}
	if(!empty($_REQUEST['istoerp']) && $_REQUEST['istoerp'] == '是'){
		$query .= " and a.istoerp = '是'";
	}
	if(!empty($_REQUEST['billid']) ){
		$query .= " and a.customform19id = " . $_REQUEST['billid'];
	}
	if(!empty($_REQUEST['billids']) ){
		$query .= " and a.customform19id in (" . $_REQUEST['billids'].")";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '已对接'){
		$query .= " and a.kis_id > 0";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '未对接'){
		$query .= " and a.kis_id = 0";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."'";
	}
	if(empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."' and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	$query .= " GROUP BY a.customform19id,b.lineitem_id ORDER BY jobno,a.vendorid,b.tax2,a.currency_id,jobno_date";
	return $query;
}
//空运
function kongyun(){
	global $adb;
	$data = array();
	if(empty($_REQUEST['baoguan_leixing']) || $_REQUEST['baoguan_leixing'] == 'account'){
		$query = kongyun_kehu();
	}else{
		$query = kongyun_gongyingshang();
	}
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	$subtotal = array();$billid_array = array();
	$currency_info = getCurrencyInfo();
	if($num_rows > 0){
		for($i = 0; $i < $num_rows; $i++){
			$billno = $adb->query_result($result,$i,'billno');	
			$billid = $adb->query_result($result,$i,'billid');	//单据ID
			$_REQUEST['istoerp'] = $adb->query_result($result,$i,'istoerp');	//是否对接金蝶
			$zhuangtai = $adb->query_result($result,$i,'zhuangtai');	//对账状态
			$zhuangtai_date = $adb->query_result($result,$i,'zhuangtai_date');
			$yewufenlei = $adb->query_result($result,$i,'yewufenlei');	//业务分类
			$accountorvendor = $adb->query_result($result,$i,'accountorvendor');	//客户/供应商
			$jobno = $adb->query_result($result,$i,'jobno');	//JOB NO
			$jobno_date = $adb->query_result($result,$i,'jobno_date');	//JOB NO日期
			$jobno_creator = $adb->query_result($result,$i,'jobno_creator');	//JOB NO创建人
			$real_flightdate = $adb->query_result($result,$i,'real_flightdate');	//航班日期
			$real_flightno = $adb->query_result($result,$i,'real_flightno');	//航班号
			$masterorder_no = $adb->query_result($result,$i,'masterorder_no');	//主单号
			$fendanhao = $adb->query_result($result,$i,'fendanhao');	//分单号
			$jifeizhongliang = $adb->query_result($result,$i,'jifeizhongliang');	//计费重量
			$yewudanhao = $adb->query_result($result,$i,'yewudanhao');	//空运单号
			$feiyongtype = $adb->query_result($result,$i,'feiyongtype');	//费用项目
			$weishui_amount_tax0 = $adb->query_result($result,$i,'weishui_amount_tax0');	
			$hanshui_amount_tax0 = $adb->query_result($result,$i,'hanshui_amount_tax0');	
			$weishui_amount_tax6 = $adb->query_result($result,$i,'weishui_amount_tax6');	
			$hanshui_amount_tax6 = $adb->query_result($result,$i,'hanshui_amount_tax6');	
			$weishui_amount_tax9 = $adb->query_result($result,$i,'weishui_amount_tax9');	
			$hanshui_amount_tax9 = $adb->query_result($result,$i,'hanshui_amount_tax9');
			$shui = $adb->query_result($result,$i,'shui');		//税
			$weishui_amount = $adb->query_result($result,$i,'weishui_amount');	
			$hanshui_amount = $adb->query_result($result,$i,'hanshui_amount');	
			$currency_id = $adb->query_result($result,$i,'currency_id');	//货值
			$currency_symbol = $adb->query_result($result,$i,'currency_symbol');
			$conversion_rate = $adb->query_result($result,$i,'conversion_rate');
			$kis_id = $adb->query_result($result,$i,'kis_id');
			$comment = $adb->query_result($result,$i,'comment');	//备注
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['currency_symbol'] = $currency_symbol;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax0'] += $weishui_amount_tax0;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax0'] += $hanshui_amount_tax0;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax6'] += $weishui_amount_tax6;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax6'] += $hanshui_amount_tax6;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax9'] += $weishui_amount_tax9;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax9'] += $hanshui_amount_tax9;
			if($currency_id > 1){
				$weishui_amount_tax0 = $weishui_amount_tax0*$conversion_rate;
				$hanshui_amount_tax0 = $hanshui_amount_tax0*$conversion_rate;
				$weishui_amount_tax6 = $weishui_amount_tax6*$conversion_rate;
				$hanshui_amount_tax6 = $hanshui_amount_tax6*$conversion_rate;
				$weishui_amount_tax9 = $weishui_amount_tax9*$conversion_rate;
				$hanshui_amount_tax9 = $hanshui_amount_tax9*$conversion_rate;
			}
			$total[$accountorvendor]['weishui_amount_tax0'] += $weishui_amount_tax0;
			$total[$accountorvendor]['hanshui_amount_tax0'] += $hanshui_amount_tax0;
			$total[$accountorvendor]['weishui_amount_tax6'] += $weishui_amount_tax6;
			$total[$accountorvendor]['hanshui_amount_tax6'] += $hanshui_amount_tax6;
			$total[$accountorvendor]['weishui_amount_tax9'] += $weishui_amount_tax9;
			$total[$accountorvendor]['hanshui_amount_tax9'] += $hanshui_amount_tax9;
			$billid_array[] = $billid;
			$data[] = array(
				'billno' => $adb->query_result($result,$i,'billno'),
				'billid' => $billid,
				'istoerp' => $_REQUEST['istoerp'],
				'zhuangtai' => $zhuangtai,
				'zhuangtai_date' => $zhuangtai_date,
				'kis_id' => $kis_id,
				'yewufenlei' => $yewufenlei,
				'accountorvendor' => $accountorvendor,
				'jobno' => $jobno,
				'jobno_date' => $jobno_date,
				'jobno_creator' => $jobno_creator,
				'real_flightdate' => $real_flightdate,
				'real_flightno' => $real_flightno,
				'masterorder_no' => $masterorder_no,
				'shenbaokouan' => $shenbaokouan,
				'fendanhao' => $fendanhao,
				'jifeizhongliang' => $jifeizhongliang,
				'yewudanhao' => $yewudanhao,
				'feiyongtype' => $feiyongtype,
				'shui' => $shui,
				'weishui_amount' => $weishui_amount,
				'hanshui_amount' => $hanshui_amount,
				'comment' => $comment,
				'currency_name' => $currency_info[$currency_id],
				'currency_id' => $currency_id,
				'currency_symbol' => $currency_symbol,
			);
		}
	}
	$total = setTotal($subtotal,$total);$list = setData($data);
	return array('list'=>$list,'subtotal'=>$subtotal,'total'=>$total,'billids'=>$billid_array);
}

//空运 - 客户
function kongyun_kehu(){
	$smower_sql = getSmowerSql();
	$acc_smower_sql = '';
	if(!empty($smower_sql['acc'])){
		$acc_smower_sql = str_replace("ld_customform18","a",$smower_sql['acc']);
	}
	$query = "
		SELECT 
			a.customform18_no AS billno,
			a.customform18id AS billid,
			a.istoerp,
			a.is_duizhang AS zhuangtai,
			a.is_duizhang_date AS zhuangtai_date,
			a.service_type AS yewufenlei,
			k.accountname AS accountorvendor,
			j.customform03_no AS jobno,
			DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
			u.last_name AS jobno_creator,
			x.real_flightdate,
			x.real_flightno,
			x.masterorder_no,
			GROUP_CONCAT(IFNULL(e.sf169,'') SEPARATOR '
		') AS fendanhao,
			GROUP_CONCAT(ROUND(IFNULL(e.sf174,0),3) SEPARATOR '
		') AS jifeizhongliang,
			y.customform24_no AS yewudanhao,
			p.productname AS feiyongtype,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax0,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax0,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax6,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax6,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax9,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax9,
			ROUND(b.tax_amount,2) AS weishui_amount,
			ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
			b.tax2 AS shui,
			a.currency_id,
			a.currency_symbol,
			CASE
				WHEN a.currency_id=1 THEN 1.000000
				WHEN a.currency_id=6 THEN 
					(SELECT conversionrate_rmbtoeur FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=10 THEN 
					(SELECT conversionrate_rmbtokrw FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=11 THEN 
					(SELECT conversionrate_rmbtohkd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=12 THEN 
					(SELECT conversionrate_rmbtovnd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
			END AS conversion_rate,
            a.kis_id,b.comment
		FROM ld_customform18 a
		LEFT JOIN ld_account k ON k.accountid=a.accountid
		lEFT JOIN ld_customform24 y ON y.customform24id=a.customform24_id
		LEFT JOIN ld_customform25 x ON x.customform24_id=y.customform24id AND x.deleted=0
		LEFT JOIN ld_customform25detail d ON d.id=x.customform25id
		LEFT JOIN ld_customform25detailscf e ON e.lineitem_id=d.lineitem_id
		LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
		LEFT JOIN ld_users u ON u.id=j.smcreatorid
		LEFT JOIN ld_customform18detail b ON b.id=a.customform18id
		LEFT JOIN ld_products p ON p.productid=b.productid 
		LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.accountid 
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND a.service_type='空运' $acc_smower_sql 
	";
	if(!empty($_REQUEST['search_name'])){
		$query .= " and accountname like '%".$_REQUEST['search_name']."%'";
	}
	if(!empty($_REQUEST['job_starttime']) && empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."'";
	}
	if(empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."' and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_no'])){
		$query .= " and customform03_no = '".$_REQUEST['job_no']."'";
	}
	if(!empty($_REQUEST['duizhang'])){
		$query .= " and a.is_duizhang = '".$_REQUEST['duizhang']."'";
	}
	if(!empty($_REQUEST['creator'])){
		$query .= " and u.last_name = '".$_REQUEST['creator']."'";
	}
	if(!empty($_REQUEST['istoerp']) && $_REQUEST['istoerp'] == '是'){
		$query .= " and a.istoerp = '是'";
	}
	if(!empty($_REQUEST['billid']) ){
		$query .= " and a.customform18id = " . $_REQUEST['billid'];
	}
	if(!empty($_REQUEST['billids']) ){
		$query .= " and a.customform18id in (" . $_REQUEST['billids'].")";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '已对接'){
		$query .= " and a.kis_id > 0";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '未对接'){
		$query .= " and a.kis_id = 0";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."'";
	}
	if(empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."' and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	$query .= " GROUP BY a.customform18id,b.lineitem_id ORDER BY jobno,a.accountid,b.tax2,a.currency_id,jobno_date";
	return $query;
}
//空运 - 供应商
function kongyun_gongyingshang(){
	$smower_sql = getSmowerSql();
	$ven_smower_sql = '';
	if(!empty($smower_sql['ven'])){
		$ven_smower_sql = str_replace("ld_customform19","a",$smower_sql['ven']);
	}
	$query = "
		SELECT 
			a.customform19_no AS billno,
			a.customform19id AS billid,
			a.istoerp,
			a.is_duizhang AS zhuangtai,
			a.is_duizhang_date AS zhuangtai_date,
			a.service_type AS yewufenlei,
			k.vendorname AS accountorvendor,
			j.customform03_no AS jobno,
			DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
			u.last_name AS jobno_creator,
			y.customform24_no AS yewudanhao,

			x.real_flightdate,
			x.real_flightno,
			x.masterorder_no,
			GROUP_CONCAT(IFNULL(e.sf169,'') SEPARATOR '
		') AS fendanhao,
			GROUP_CONCAT(ROUND(IFNULL(e.sf174,0),3) SEPARATOR '
		') AS jifeizhongliang,

			p.productname AS feiyongtype,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax0,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax0,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax6,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax6,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax9,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax9,
			ROUND(b.tax_amount,2) AS weishui_amount,
			ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
			b.tax2 AS shui,
			a.currency_id,
			a.currency_symbol,
			CASE
				WHEN a.currency_id=1 THEN 1.000000
				WHEN a.currency_id=6 THEN 
					(SELECT conversionrate_rmbtoeur FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=10 THEN 
					(SELECT conversionrate_rmbtokrw FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=11 THEN 
					(SELECT conversionrate_rmbtohkd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=12 THEN 
					(SELECT conversionrate_rmbtovnd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
			END AS conversion_rate,
            a.kis_id,b.comment
		FROM ld_customform19 a
		LEFT JOIN ld_vendor k ON k.vendorid=a.vendorid
		lEFT JOIN ld_customform24 y ON y.customform24id=a.customform24_id
		LEFT JOIN ld_customform25 x ON x.customform24_id=y.customform24id AND x.deleted=0
		LEFT JOIN ld_customform25detail d ON d.id=x.customform25id
		LEFT JOIN ld_customform25detailscf e ON e.lineitem_id=d.lineitem_id
		LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
		LEFT JOIN ld_users u ON u.id=j.smcreatorid
		LEFT JOIN ld_customform19detail b ON b.id=a.customform19id
		LEFT JOIN ld_products p ON p.productid=b.productid 
		LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.vendorid 
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND a.service_type='空运' $ven_smower_sql 
	";
	if(!empty($_REQUEST['search_name'])){
		$query .= " and vendorname like '%".$_REQUEST['search_name']."%'";
	}
	if(!empty($_REQUEST['job_starttime']) && empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."'";
	}
	if(empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."' and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_no'])){
		$query .= " and customform03_no = '".$_REQUEST['job_no']."'";
	}
	if(!empty($_REQUEST['duizhang'])){
		$query .= " and a.is_duizhang = '".$_REQUEST['duizhang']."'";
	}
	if(!empty($_REQUEST['creator'])){
		$query .= " and u.last_name = '".$_REQUEST['creator']."'";
	}
	if(!empty($_REQUEST['istoerp']) && $_REQUEST['istoerp'] == '是'){
		$query .= " and a.istoerp = '是'";
	}
	if(!empty($_REQUEST['billid']) ){
		$query .= " and a.customform19id = " . $_REQUEST['billid'];
	}
	if(!empty($_REQUEST['billids']) ){
		$query .= " and a.customform19id in (" . $_REQUEST['billids'].")";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '已对接'){
		$query .= " and a.kis_id > 0";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '未对接'){
		$query .= " and a.kis_id = 0";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."'";
	}
	if(empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."' and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	$query .= " GROUP BY a.customform19id,b.lineitem_id ORDER BY jobno,a.vendorid,b.tax2,a.currency_id,jobno_date";
	return $query;
}
//出入库
function churuku(){
	global $adb;
	$data = array();
	if(empty($_REQUEST['baoguan_leixing']) || $_REQUEST['baoguan_leixing'] == 'account'){
		$query = churuku_kehu();
	}else{
		$query = churuku_gongyingshang();
	}
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	$subtotal = array();$billid_array = array();
	$currency_info = getCurrencyInfo();
	if($num_rows > 0){
		for($i = 0; $i < $num_rows; $i++){
			$billno = $adb->query_result($result,$i,'billno');	
			$billid = $adb->query_result($result,$i,'billid');	//单据ID
			$_REQUEST['istoerp'] = $adb->query_result($result,$i,'istoerp');	//是否对接金蝶
			$zhuangtai = $adb->query_result($result,$i,'zhuangtai');	//对账状态
			$yewufenlei = $adb->query_result($result,$i,'yewufenlei');	//业务分类
			$zhuangtai_date = $adb->query_result($result,$i,'zhuangtai_date');
			$accountorvendor = $adb->query_result($result,$i,'accountorvendor');	//客户/供应商
			$jobno = $adb->query_result($result,$i,'jobno');	//JOB NO
			$jobno_date = $adb->query_result($result,$i,'jobno_date');	//JOB NO日期
			$jobno_creator = $adb->query_result($result,$i,'jobno_creator');	//JOB NO创建人
			$pinming = $adb->query_result($result,$i,'pinming');	//品名
			$xiangshubanshu = $adb->query_result($result,$i,'xiangshubanshu');	//箱数/板数
			
			$qty = $adb->query_result($result,$i,'qty');	//数量
			$maozhong = $adb->query_result($result,$i,'maozhong');	//毛重
			$baoguandanhao = $adb->query_result($result,$i,'yewudanhao');	//报关单号
			$feiyongtype = $adb->query_result($result,$i,'feiyongtype');	//费用项目
			$weishui_amount_tax0 = $adb->query_result($result,$i,'weishui_amount_tax0');	
			$hanshui_amount_tax0 = $adb->query_result($result,$i,'hanshui_amount_tax0');	
			$weishui_amount_tax6 = $adb->query_result($result,$i,'weishui_amount_tax6');	
			$hanshui_amount_tax6 = $adb->query_result($result,$i,'hanshui_amount_tax6');	
			$weishui_amount_tax9 = $adb->query_result($result,$i,'weishui_amount_tax9');	
			$hanshui_amount_tax9 = $adb->query_result($result,$i,'hanshui_amount_tax9');
			$shui = $adb->query_result($result,$i,'shui');		//税
			$weishui_amount = $adb->query_result($result,$i,'weishui_amount');	
			$hanshui_amount = $adb->query_result($result,$i,'hanshui_amount');	
			$currency_id = $adb->query_result($result,$i,'currency_id');	//货值
			$currency_symbol = $adb->query_result($result,$i,'currency_symbol');
			$conversion_rate = $adb->query_result($result,$i,'conversion_rate');
			$kis_id = $adb->query_result($result,$i,'kis_id');
			$comment = $adb->query_result($result,$i,'comment');	//备注
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['currency_symbol'] = $currency_symbol;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax0'] += $weishui_amount_tax0;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax0'] += $hanshui_amount_tax0;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax6'] += $weishui_amount_tax6;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax6'] += $hanshui_amount_tax6;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax9'] += $weishui_amount_tax9;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax9'] += $hanshui_amount_tax9;
			if($currency_id > 1){
				$weishui_amount_tax0 = $weishui_amount_tax0*$conversion_rate;
				$hanshui_amount_tax0 = $hanshui_amount_tax0*$conversion_rate;
				$weishui_amount_tax6 = $weishui_amount_tax6*$conversion_rate;
				$hanshui_amount_tax6 = $hanshui_amount_tax6*$conversion_rate;
				$weishui_amount_tax9 = $weishui_amount_tax9*$conversion_rate;
				$hanshui_amount_tax9 = $hanshui_amount_tax9*$conversion_rate;
			}
			$total[$accountorvendor]['weishui_amount_tax0'] += $weishui_amount_tax0;
			$total[$accountorvendor]['hanshui_amount_tax0'] += $hanshui_amount_tax0;
			$total[$accountorvendor]['weishui_amount_tax6'] += $weishui_amount_tax6;
			$total[$accountorvendor]['hanshui_amount_tax6'] += $hanshui_amount_tax6;
			$total[$accountorvendor]['weishui_amount_tax9'] += $weishui_amount_tax9;
			$total[$accountorvendor]['hanshui_amount_tax9'] += $hanshui_amount_tax9;
			$billid_array[] = $billid;
			$data[] = array(
				'billno' => $adb->query_result($result,$i,'billno'),
				'billid' => $billid,
				'istoerp' => $_REQUEST['istoerp'],
				'zhuangtai' => $zhuangtai,
				'zhuangtai_date' => $zhuangtai_date,
				'kis_id' => $kis_id,
				'yewufenlei' => $yewufenlei,
				'accountorvendor' => $accountorvendor,
				'jobno' => $jobno,
				'jobno_date' => $jobno_date,
				'jobno_creator' => $jobno_creator,
				'pinming' => $pinming,
				'qty' => $qty,
				'xiangshubanshu' => $xiangshubanshu,
				'maozhong' => $maozhong,
				'yewudanhao' => $baoguandanhao,
				'feiyongtype' => $feiyongtype,
				'shui' => $shui,
				'weishui_amount' => $weishui_amount,
				'hanshui_amount' => $hanshui_amount,
				'comment' => $comment,
				'currency_name' => $currency_info[$currency_id],
				'currency_id' => $currency_id,
				'currency_symbol' => $currency_symbol,
			);
		}
	}
	$total = setTotal($subtotal,$total);$list = setData($data);
	return array('list'=>$list,'subtotal'=>$subtotal,'total'=>$total,'billids'=>$billid_array);
}
//出入库 - 客户
function churuku_kehu(){
	$smower_sql = getSmowerSql();
	$acc_smower_sql = '';
	if(!empty($smower_sql['acc'])){
		$acc_smower_sql = str_replace("ld_customform18","a",$smower_sql['acc']);
	}
	$query = "
		SELECT 
			a.customform18_no AS billno,
			a.customform18id AS billid,
			a.istoerp,
			a.is_duizhang AS zhuangtai,
			a.is_duizhang_date AS zhuangtai_date,
			a.service_type AS yewufenlei,
			k.accountname AS accountorvendor,
			j.customform03_no AS jobno,
			DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
			u.last_name AS jobno_creator,
			d.product_name AS pinming,
			ROUND(SUM(d.quantity),0) AS xiangshubanshu,
			ROUND(SUM(e.sf217),3) AS qty,
			ROUND(SUM(e.sf215),3) AS maozhong,
			y.commission_no AS yewudanhao,
			p.productname AS feiyongtype,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax0,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax0,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax6,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax6,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax9,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax9,
			ROUND(b.tax_amount,2) AS weishui_amount,
			ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
			b.tax2 AS shui,
			a.currency_id,
			a.currency_symbol,
			CASE
				WHEN a.currency_id=1 THEN 1.000000
				WHEN a.currency_id=6 THEN 
					(SELECT conversionrate_rmbtoeur FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=10 THEN 
					(SELECT conversionrate_rmbtokrw FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=11 THEN 
					(SELECT conversionrate_rmbtohkd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=12 THEN 
					(SELECT conversionrate_rmbtovnd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
			END AS conversion_rate,
            a.kis_id,b.comment
		FROM ld_customform18 a
		LEFT JOIN ld_account k ON k.accountid=a.accountid
		lEFT JOIN ld_commission y ON y.commission_id=a.commission_id
		LEFT JOIN ld_commission2payment d ON d.commission_id=y.commission_id
		LEFT JOIN ld_commission2paymentscf e ON e.commission2payment_id=d.commission2payment_id
		LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
		LEFT JOIN ld_users u ON u.id=j.smcreatorid
		LEFT JOIN ld_customform18detail b ON b.id=a.customform18id
		LEFT JOIN ld_products p ON p.productid=b.productid 
		LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.accountid 
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND a.service_type='出入库' $acc_smower_sql 
	";
	if(!empty($_REQUEST['search_name'])){
		$query .= " and accountname like '%".$_REQUEST['search_name']."%'";
	}
	if(!empty($_REQUEST['job_starttime']) && empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."'";
	}
	if(empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."' and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_no'])){
		$query .= " and customform03_no = '".$_REQUEST['job_no']."'";
	}
	if(!empty($_REQUEST['duizhang'])){
		$query .= " and a.is_duizhang = '".$_REQUEST['duizhang']."'";
	}
	if(!empty($_REQUEST['creator'])){
		$query .= " and u.last_name = '".$_REQUEST['creator']."'";
	}
	if(!empty($_REQUEST['istoerp']) && $_REQUEST['istoerp'] == '是'){
		$query .= " and a.istoerp = '是'";
	}
	if(!empty($_REQUEST['billid']) ){
		$query .= " and a.customform18id = " . $_REQUEST['billid'];
	}
	if(!empty($_REQUEST['billids']) ){
		$query .= " and a.customform18id in (" . $_REQUEST['billids'].")";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '已对接'){
		$query .= " and a.kis_id > 0";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '未对接'){
		$query .= " and a.kis_id = 0";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."'";
	}
	if(empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."' and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	$query .= " GROUP BY a.customform18id,b.lineitem_id ORDER BY jobno,a.accountid,b.tax2,a.currency_id,jobno_date";
	return $query;
}
//出入库 - 供应商
function churuku_gongyingshang(){
	$smower_sql = getSmowerSql();
	$ven_smower_sql = '';
	if(!empty($smower_sql['ven'])){
		$ven_smower_sql = str_replace("ld_customform19","a",$smower_sql['ven']);
	}
	$query = "
		SELECT 
			a.customform19_no AS billno,
			a.customform19id AS billid,
			a.istoerp,
			a.is_duizhang AS zhuangtai,
			a.is_duizhang_date AS zhuangtai_date,
			a.service_type AS yewufenlei,
			k.vendorname AS accountorvendor,
			j.customform03_no AS jobno,
			DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
			u.last_name AS jobno_creator,

			d.product_name AS pinming,
			ROUND(SUM(d.quantity),0) AS xiangshubanshu,
			ROUND(SUM(e.sf217),3) AS qty,
			ROUND(SUM(e.sf215),3) AS maozhong,
			y.commission_no AS yewudanhao,


			p.productname AS feiyongtype,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax0,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax0,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax6,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax6,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax9,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax9,
			ROUND(b.tax_amount,2) AS weishui_amount,
			ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
			b.tax2 AS shui,
			a.currency_id,
			a.currency_symbol,
			CASE
				WHEN a.currency_id=1 THEN 1.000000
				WHEN a.currency_id=6 THEN 
					(SELECT conversionrate_rmbtoeur FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=10 THEN 
					(SELECT conversionrate_rmbtokrw FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=11 THEN 
					(SELECT conversionrate_rmbtohkd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=12 THEN 
					(SELECT conversionrate_rmbtovnd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
			END AS conversion_rate,
            a.kis_id,b.comment
		FROM ld_customform19 a
		LEFT JOIN ld_vendor k ON k.vendorid=a.vendorid
		lEFT JOIN ld_commission y ON y.commission_id=a.commission_id
		LEFT JOIN ld_commission2payment d ON d.commission_id=y.commission_id
		LEFT JOIN ld_commission2paymentscf e ON e.commission2payment_id=d.commission2payment_id
		LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
		LEFT JOIN ld_users u ON u.id=j.smcreatorid
		LEFT JOIN ld_customform19detail b ON b.id=a.customform19id
		LEFT JOIN ld_products p ON p.productid=b.productid 
		LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.vendorid 
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND a.service_type='出入库' $ven_smower_sql 
	";
	if(!empty($_REQUEST['search_name'])){
		$query .= " and vendorname like '%".$_REQUEST['search_name']."%'";
	}
	if(!empty($_REQUEST['job_starttime']) && empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."'";
	}
	if(empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."' and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_no'])){
		$query .= " and customform03_no = '".$_REQUEST['job_no']."'";
	}
	if(!empty($_REQUEST['duizhang'])){
		$query .= " and a.is_duizhang = '".$_REQUEST['duizhang']."'";
	}
	if(!empty($_REQUEST['creator'])){
		$query .= " and u.last_name = '".$_REQUEST['creator']."'";
	}
	if(!empty($_REQUEST['istoerp']) && $_REQUEST['istoerp'] == '是'){
		$query .= " and a.istoerp = '是'";
	}
	if(!empty($_REQUEST['billid']) ){
		$query .= " and a.customform19id = " . $_REQUEST['billid'];
	}
	if(!empty($_REQUEST['billids']) ){
		$query .= " and a.customform19id in (" . $_REQUEST['billids'].")";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '已对接'){
		$query .= " and a.kis_id > 0";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '未对接'){
		$query .= " and a.kis_id = 0";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."'";
	}
	if(empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."' and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	$query .= " GROUP BY a.customform19id,b.lineitem_id ORDER BY jobno,a.vendorid,b.tax2,a.currency_id,jobno_date";
	return $query;
}
//报关
function baoguan(){
	global $adb;
	$data = array();
	if(empty($_REQUEST['baoguan_leixing']) || $_REQUEST['baoguan_leixing'] == 'account'){
		$query = baoguan_kehu();
	}else{
		$query = baoguan_gongyingshang();
	}
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	$subtotal = array();$billid_array = array();
	$currency_info = getCurrencyInfo();
	if($num_rows > 0){
		for($i = 0; $i < $num_rows; $i++){
			$billid = $adb->query_result($result,$i,'billid');	//单据ID
			$_REQUEST['istoerp'] = $adb->query_result($result,$i,'istoerp');	//是否对接金蝶
			$zhuangtai = $adb->query_result($result,$i,'zhuangtai');	//对账状态
			$zhuangtai_date = $adb->query_result($result,$i,'zhuangtai_date');
			$yewufenlei = $adb->query_result($result,$i,'yewufenlei');	//业务分类
			$accountorvendor = $adb->query_result($result,$i,'accountorvendor');	//客户/供应商
			$jobno = $adb->query_result($result,$i,'jobno');	//JOB NO
			$jobno_date = $adb->query_result($result,$i,'jobno_date');	//JOB NO日期
			$jobno_creator = $adb->query_result($result,$i,'jobno_creator');	//JOB NO创建人
			$fapiaohao = $adb->query_result($result,$i,'fapiaohao');	//发票号
			$chukou_date = $adb->query_result($result,$i,'chukou_date');	//出口日期
			$jinkou_date = $adb->query_result($result,$i,'jinkou_date');	//进口日期
			$shenbaokouan = $adb->query_result($result,$i,'shenbaokouan');	//申报口岸
			$pinming = $adb->query_result($result,$i,'pinming');	//品名
			$qty = $adb->query_result($result,$i,'qty');	//数量
			$huozhi = $adb->query_result($result,$i,'huozhi');	//货值
			$jianshu = $adb->query_result($result,$i,'jianshu');	//件数
			$maozhong = $adb->query_result($result,$i,'maozhong');	//毛重
			$baoguandanhao = $adb->query_result($result,$i,'baoguandanhao');	//报关单号
			$trans_name = $adb->query_result($result,$i,'trans_name');	//六连单号
			$feiyongtype = $adb->query_result($result,$i,'feiyongtype');	//费用项目
			$weishui_amount_tax0 = $adb->query_result($result,$i,'weishui_amount_tax0');	
			$hanshui_amount_tax0 = $adb->query_result($result,$i,'hanshui_amount_tax0');	
			$weishui_amount_tax6 = $adb->query_result($result,$i,'weishui_amount_tax6');	
			$hanshui_amount_tax6 = $adb->query_result($result,$i,'hanshui_amount_tax6');	
			$weishui_amount_tax9 = $adb->query_result($result,$i,'weishui_amount_tax9');	
			$hanshui_amount_tax9 = $adb->query_result($result,$i,'hanshui_amount_tax9');
			$shui = $adb->query_result($result,$i,'shui');		//税
			$weishui_amount = $adb->query_result($result,$i,'weishui_amount');	
			$hanshui_amount = $adb->query_result($result,$i,'hanshui_amount');	
			$currency_id = $adb->query_result($result,$i,'currency_id');	//货值
			$currency_symbol = $adb->query_result($result,$i,'currency_symbol');
			$conversion_rate = $adb->query_result($result,$i,'conversion_rate');
			$kis_id = $adb->query_result($result,$i,'kis_id');
			$comment = $adb->query_result($result,$i,'comment');	//备注
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['currency_symbol'] = $currency_symbol;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax0'] += $weishui_amount_tax0;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax0'] += $hanshui_amount_tax0;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax6'] += $weishui_amount_tax6;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax6'] += $hanshui_amount_tax6;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax9'] += $weishui_amount_tax9;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax9'] += $hanshui_amount_tax9;
			if($currency_id > 1){
				$weishui_amount_tax0 = $weishui_amount_tax0*$conversion_rate;
				$hanshui_amount_tax0 = $hanshui_amount_tax0*$conversion_rate;
				$weishui_amount_tax6 = $weishui_amount_tax6*$conversion_rate;
				$hanshui_amount_tax6 = $hanshui_amount_tax6*$conversion_rate;
				$weishui_amount_tax9 = $weishui_amount_tax9*$conversion_rate;
				$hanshui_amount_tax9 = $hanshui_amount_tax9*$conversion_rate;
			}
			$total[$accountorvendor]['weishui_amount_tax0'] += $weishui_amount_tax0;
			$total[$accountorvendor]['hanshui_amount_tax0'] += $hanshui_amount_tax0;
			$total[$accountorvendor]['weishui_amount_tax6'] += $weishui_amount_tax6;
			$total[$accountorvendor]['hanshui_amount_tax6'] += $hanshui_amount_tax6;
			$total[$accountorvendor]['weishui_amount_tax9'] += $weishui_amount_tax9;
			$total[$accountorvendor]['hanshui_amount_tax9'] += $hanshui_amount_tax9;
			$billid_array[] = $billid;
			$data[] = array(
				'billno' => $adb->query_result($result,$i,'billno'),
				'billid' => $billid,
				'istoerp' => $_REQUEST['istoerp'],
				'zhuangtai' => $zhuangtai,
				'zhuangtai_date' => $zhuangtai_date,
				'kis_id' => $kis_id,
				'yewufenlei' => $yewufenlei,
				'accountorvendor' => $accountorvendor,
				'jobno' => $jobno,
				'jobno_date' => $jobno_date,
				'jobno_creator' => $jobno_creator,
				'fapiaohao' => $fapiaohao,
				'chukou_date' => $chukou_date,
				'jinkou_date' => $jinkou_date,
				'shenbaokouan' => $shenbaokouan,
				'pinming' => $pinming,
				'qty' => $qty,
				'huozhi' => $huozhi,
				'jianshu' => $jianshu,
				'maozhong' => $maozhong,
				'baoguandanhao' => $baoguandanhao,
				'trans_name' => $trans_name,
				'feiyongtype' => $feiyongtype,
				'shui' => $shui,
				'weishui_amount' => $weishui_amount,
				'hanshui_amount' => $hanshui_amount,
				'comment' => $comment,
				'currency_name' => $currency_info[$currency_id],
				'currency_id' => $currency_id,
				'currency_symbol' => $currency_symbol,
			);
		}
	}
	$total = setTotal($subtotal,$total);$list = setData($data);
	return array('list'=>$list,'subtotal'=>$subtotal,'total'=>$total,'billids'=>$billid_array);
}

// set data
function setData($data){
	if(!empty($data)){
		$before_reocrd = 0;
		$before_reocrd_num = 0;
		$before_accountname = '';
		$before_currecncy = 0;
		foreach($data as $key => $arr){
			if($before_reocrd == $arr['billid']){
				$arr['is_kong'] = 'yes';
			}else{
				$arr['is_kong'] = 'no';
			}
			//echo $key.'=='.$before_accountname.'------'.$data[$key+1]['accountorvendor'];echo '<br><br>';
			if(!empty($before_accountname) && $before_accountname != $data[$key+1]['accountorvendor']){
				$key .= '_sumtotal';
				$before_accountname = $data[$key+1]['accountorvendor'];
			}else{
				$before_accountname = $arr['accountorvendor'];
				if($before_currecncy > 0 && $before_currecncy !=  $data[$key+1]['currency_id']){
					//$key .= '_subtotal';
				}
				if($arr['accountorvendor'] != $data[$key+1]['accountorvendor']){
					$key .= '_sumtotal';
					//$key .= '_subtotal';
				}
				$before_currecncy = $arr['currency_id'];
			}
			
			$before_reocrd = $arr['billid'];
			
			$list[$key] = $arr;
			
		}
	}
	return $list;
}
//报关 - 客户
function baoguan_kehu(){
	$smower_sql = getSmowerSql();
	$acc_smower_sql = '';
	if(!empty($smower_sql['acc'])){
		$acc_smower_sql = str_replace("ld_customform18","a",$smower_sql['acc']);
	}
	$query = "
		SELECT 
			a.customform18_no AS billno,
			a.customform18id AS billid,
			a.istoerp,
			a.is_duizhang AS zhuangtai,
			a.is_duizhang_date AS zhuangtai_date,
			a.service_type AS yewufenlei,
			k.accountname AS accountorvendor,
			j.customform03_no AS jobno,
			DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
			u.last_name AS jobno_creator,
			case when ifnull(y.invoice_no,'')='' then GROUP_CONCAT(DISTINCT e.sf407) else y.invoice_no end AS fapiaohao,
			y.export_date AS chukou_date,
			y.import_date AS jinkou_date,
			y.port_no AS shenbaokouan,
			e.sf138 AS pinming,
			ROUND(SUM(e.sf140),3) AS qty,
			ROUND(SUM(e.sf193),3) AS huozhi,
			y.piece AS jianshu,
			ROUND(SUM(y.gross_weight),3) AS maozhong,
			CASE
				WHEN x.cf_3033='否' THEN y.apply_no
				ELSE x.cf_3034
			END AS baoguandanhao,
			CASE 
			  WHEN LENGTH(LEFT(y.trans_name,1))=CHAR_LENGTH(LEFT(y.trans_name,1)) THEN y.trans_name
			  ELSE ''
			 END AS trans_name,
			p.productname AS feiyongtype,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax0,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax0,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax6,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax6,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax9,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax9,
			b.tax2 AS shui,
			ROUND(b.tax_amount,2) AS weishui_amount,
			ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
			a.currency_id,
			a.currency_symbol,
			CASE
				WHEN a.currency_id=1 THEN 1.000000
				WHEN a.currency_id=6 THEN 
					(SELECT conversionrate_rmbtoeur FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=10 THEN 
					(SELECT conversionrate_rmbtokrw FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=11 THEN 
					(SELECT conversionrate_rmbtohkd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=12 THEN 
					(SELECT conversionrate_rmbtovnd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
			END AS conversion_rate,
            a.kis_id,b.comment
		FROM ld_customform18 a
		LEFT JOIN ld_account k ON k.accountid=a.accountid
		lEFT JOIN ld_customform22 y ON y.customform22id=a.customform22_id
		lEFT JOIN ld_customform22scf x ON x.customform22id=y.customform22id
		LEFT JOIN ld_customform22detail d ON d.id=y.customform22id
		LEFT JOIN ld_customform22detailscf e ON e.lineitem_id=d.lineitem_id
		LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
		LEFT JOIN ld_users u ON u.id=j.smcreatorid
		LEFT JOIN ld_customform18detail b ON b.id=a.customform18id
		LEFT JOIN ld_products p ON p.productid=b.productid 
		LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.accountid 
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND a.service_type='报关' $acc_smower_sql 
	";
	if(!empty($_REQUEST['search_name'])){
		$query .= " and accountname like '%".$_REQUEST['search_name']."%'";
	}
	if(!empty($_REQUEST['job_starttime']) && empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."'";
	}
	if(empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."' and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_no'])){
		$query .= " and customform03_no = '".$_REQUEST['job_no']."'";
	}
	if(!empty($_REQUEST['duizhang'])){
		$query .= " and a.is_duizhang = '".$_REQUEST['duizhang']."'";
	}
	if(!empty($_REQUEST['creator'])){
		$query .= " and u.last_name = '".$_REQUEST['creator']."'";
	}
	if(!empty($_REQUEST['istoerp']) && $_REQUEST['istoerp'] == '是'){
		$query .= " and a.istoerp = '是'";
	}
	if(!empty($_REQUEST['billid']) ){
		$query .= " and a.customform18id = " . $_REQUEST['billid'];
	}
	if(!empty($_REQUEST['billids']) ){
		$query .= " and a.customform18id in (" . $_REQUEST['billids'].")";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '已对接'){
		$query .= " and a.kis_id > 0";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '未对接'){
		$query .= " and a.kis_id = 0";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."'";
	}
	if(empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."' and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	$query .= " GROUP BY a.customform18id,b.lineitem_id ORDER BY jobno,a.accountid,b.tax2,a.currency_id,jobno_date";
	//echo $query;echo '<br><br>';die;
	return $query;
}

//报关 - 供应商
function baoguan_gongyingshang(){
	$smower_sql = getSmowerSql();
	$ven_smower_sql = '';
	if(!empty($smower_sql['ven'])){
		$ven_smower_sql = str_replace("ld_customform19","a",$smower_sql['ven']);
	}
	$query = "
		SELECT
		a.customform19_no AS billno,
		a.customform19id AS billid,
		a.istoerp,
		a.is_duizhang AS zhuangtai,
		a.is_duizhang_date AS zhuangtai_date,
		a.service_type AS yewufenlei,
		k.vendorname AS accountorvendor,
		j.customform03_no AS jobno,
		DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
		u.last_name AS jobno_creator,
		y.invoice_no AS fapiaohao,
		y.export_date AS chukou_date,
		y.import_date AS jinkou_date,
		y.port_no AS shenbaokouan,
		e.sf138 AS pinming,
		ROUND(SUM(e.sf140),3) AS qty,
		ROUND(SUM(e.sf193),3) AS huozhi,
		y.piece AS jianshu,
		ROUND(SUM(y.gross_weight),3) AS maozhong,
		CASE
			WHEN x.cf_3033='否' THEN y.apply_no
			ELSE x.cf_3034
		END AS baoguandanhao,
		CASE 
		  WHEN LENGTH(LEFT(y.trans_name,1))=CHAR_LENGTH(LEFT(y.trans_name,1)) THEN y.trans_name
		  ELSE ''
		 END AS trans_name,
		p.productname AS feiyongtype,
		CASE
			WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
			ELSE 0
		END AS weishui_amount_tax0,
		CASE
			WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
			ELSE 0
		END AS hanshui_amount_tax0,
		CASE
			WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
			ELSE 0
		END AS weishui_amount_tax6,
		CASE
			WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
			ELSE 0
		END AS hanshui_amount_tax6,
		CASE
			WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
			ELSE 0
		END AS weishui_amount_tax9,
		CASE
			WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
			ELSE 0
		END AS hanshui_amount_tax9,
		ROUND(b.tax_amount,2) AS weishui_amount,
		ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
		b.tax2 AS shui,
		a.currency_id,
		a.currency_symbol,
		CASE
			WHEN a.currency_id=1 THEN 1.000000
			WHEN a.currency_id=6 THEN 
				(SELECT conversionrate_rmbtoeur FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
						BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
			WHEN a.currency_id=7 THEN 
				(SELECT conversionrate_rmbtousd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
						BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
			WHEN a.currency_id=7 THEN 
				(SELECT conversionrate_rmbtousd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
						BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
			WHEN a.currency_id=10 THEN 
				(SELECT conversionrate_rmbtokrw FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
						BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
			WHEN a.currency_id=11 THEN 
				(SELECT conversionrate_rmbtohkd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
						BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
			WHEN a.currency_id=12 THEN 
				(SELECT conversionrate_rmbtovnd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
						BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
		END AS conversion_rate,
        a.kis_id,b.comment
	FROM ld_customform19 a
	LEFT JOIN ld_vendor k ON k.vendorid=a.vendorid
	lEFT JOIN ld_customform22 y ON y.customform22id=a.customform22_id
	lEFT JOIN ld_customform22scf x ON x.customform22id=y.customform22id
	LEFT JOIN ld_customform22detail d ON d.id=y.customform22id
	LEFT JOIN ld_customform22detailscf e ON e.lineitem_id=d.lineitem_id
	LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
	LEFT JOIN ld_users u ON u.id=j.smcreatorid
	LEFT JOIN ld_customform19detail b ON b.id=a.customform19id
	LEFT JOIN ld_products p ON p.productid=b.productid 
	LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.vendorid 
	WHERE a.deleted=0
		AND a.approvestatus<>'已拒绝'
		AND a.service_type='报关' $ven_smower_sql 
	";
	if(!empty($_REQUEST['search_name'])){
		$query .= " and vendorname like '%".$_REQUEST['search_name']."%'";
	}
	if(!empty($_REQUEST['job_starttime']) && empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."'";
	}
	if(empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."' and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_no'])){
		$query .= " and customform03_no = '".$_REQUEST['job_no']."'";
	}
	if(!empty($_REQUEST['duizhang'])){
		$query .= " and a.is_duizhang = '".$_REQUEST['duizhang']."'";
	}
	if(!empty($_REQUEST['creator'])){
		$query .= " and u.last_name = '".$_REQUEST['creator']."'";
	}
	if(!empty($_REQUEST['istoerp']) && $_REQUEST['istoerp'] == '是'){
		$query .= " and a.istoerp = '是'";
	}
	if(!empty($_REQUEST['billid']) ){
		$query .= " and a.customform19id = " . $_REQUEST['billid'];
	}
	if(!empty($_REQUEST['billids']) ){
		$query .= " and a.customform19id in (" . $_REQUEST['billids'].")";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '已对接'){
		$query .= " and a.kis_id > 0";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '未对接'){
		$query .= " and a.kis_id = 0";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."'";
	}
	if(empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."' and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	$query .= " GROUP BY a.customform19id,b.lineitem_id ORDER BY jobno,a.vendorid,b.tax2,a.currency_id,jobno_date";
	//echo $query;echo '<br><br>';die;
	return $query;
}

//运输
function yunshu(){
	global $adb;
	$data = array();
	if(empty($_REQUEST['baoguan_leixing']) || $_REQUEST['baoguan_leixing'] == 'account'){
		$query = yunshu_kehu();
	}else{
		$query = yunshu_gongyingshang();
	}
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	$subtotal = array();$billid_array = array();
	$currency_info = getCurrencyInfo();
	if($num_rows > 0){
		for($i = 0; $i < $num_rows; $i++){
			$billid = $adb->query_result($result,$i,'billid');	//单据ID
			$_REQUEST['istoerp'] = $adb->query_result($result,$i,'istoerp');	//是否对接金蝶
			$zhuangtai = $adb->query_result($result,$i,'zhuangtai');	//对账状态
			$zhuangtai_date = $adb->query_result($result,$i,'zhuangtai_date');
			$yewufenlei = $adb->query_result($result,$i,'yewufenlei');	//业务分类
			$accountorvendor = $adb->query_result($result,$i,'accountorvendor');	//客户/供应商
			
			$jobno = $adb->query_result($result,$i,'jobno');	//JOB NO
			$jobno_date = $adb->query_result($result,$i,'jobno_date');	//JOB NO日期
			$jobno_creator = $adb->query_result($result,$i,'jobno_creator');	//JOB NO创建人
			$tongguankouan = $adb->query_result($result,$i,'tongguankouan');	//通关口岸
			$shouhuoren = $adb->query_result($result,$i,'shouhuoren');	//收货人
			$xiangshubanshu = $adb->query_result($result,$i,'xiangshubanshu');	//箱数/板数
			$qty = $adb->query_result($result,$i,'qty');	//数量
			$maozhong = $adb->query_result($result,$i,'maozhong');	//毛重
			$yewudanhao = $adb->query_result($result,$i,'yewudanhao');	//业务单号
			$carriage_type = $adb->query_result($result,$i,'carriage_type');	
			$chepai = $adb->query_result($result,$i,'chepai');
			$feiyongtype = $adb->query_result($result,$i,'feiyongtype');	//费用项目
			$weishui_amount_tax0 = $adb->query_result($result,$i,'weishui_amount_tax0');	
			$hanshui_amount_tax0 = $adb->query_result($result,$i,'hanshui_amount_tax0');	
			$weishui_amount_tax6 = $adb->query_result($result,$i,'weishui_amount_tax6');	
			$hanshui_amount_tax6 = $adb->query_result($result,$i,'hanshui_amount_tax6');	
			$weishui_amount_tax9 = $adb->query_result($result,$i,'weishui_amount_tax9');	
			$hanshui_amount_tax9 = $adb->query_result($result,$i,'hanshui_amount_tax9');
			$shui = $adb->query_result($result,$i,'shui');		//税
			$weishui_amount = $adb->query_result($result,$i,'weishui_amount');	
			$hanshui_amount = $adb->query_result($result,$i,'hanshui_amount');	
			$currency_id = $adb->query_result($result,$i,'currency_id');	//货值
			$currency_symbol = $adb->query_result($result,$i,'currency_symbol');
			$conversion_rate = $adb->query_result($result,$i,'conversion_rate');
			$kis_id = $adb->query_result($result,$i,'kis_id');
			$comment = $adb->query_result($result,$i,'comment');	//备注
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['currency_symbol'] = $currency_symbol;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax0'] += $weishui_amount_tax0;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax0'] += $hanshui_amount_tax0;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax6'] += $weishui_amount_tax6;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax6'] += $hanshui_amount_tax6;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['weishui_amount_tax9'] += $weishui_amount_tax9;
			$subtotal[$accountorvendor][$currency_info[$currency_id]]['hanshui_amount_tax9'] += $hanshui_amount_tax9;
			if($currency_id > 1){
				$weishui_amount_tax0 = $weishui_amount_tax0*$conversion_rate;
				$hanshui_amount_tax0 = $hanshui_amount_tax0*$conversion_rate;
				$weishui_amount_tax6 = $weishui_amount_tax6*$conversion_rate;
				$hanshui_amount_tax6 = $hanshui_amount_tax6*$conversion_rate;
				$weishui_amount_tax9 = $weishui_amount_tax9*$conversion_rate;
				$hanshui_amount_tax9 = $hanshui_amount_tax9*$conversion_rate;
			}
			$total[$accountorvendor]['weishui_amount_tax0'] += $weishui_amount_tax0;
			$total[$accountorvendor]['hanshui_amount_tax0'] += $hanshui_amount_tax0;
			$total[$accountorvendor]['weishui_amount_tax6'] += $weishui_amount_tax6;
			$total[$accountorvendor]['hanshui_amount_tax6'] += $hanshui_amount_tax6;
			$total[$accountorvendor]['weishui_amount_tax9'] += $weishui_amount_tax9;
			$total[$accountorvendor]['hanshui_amount_tax9'] += $hanshui_amount_tax9;
			$billid_array[] = $billid;
			$data[] = array(
				'billno' => $adb->query_result($result,$i,'billno'),
				'billid' => $billid,
				'istoerp' => $_REQUEST['istoerp'],
				'zhuangtai' => $zhuangtai,
				'zhuangtai_date' => $zhuangtai_date,
				'kis_id' => $kis_id,
				'yewufenlei' => $yewufenlei,
				'accountorvendor' => $accountorvendor,
				'jobno' => $jobno,
				'jobno_date' => $jobno_date,
				'jobno_creator' => $jobno_creator,
				'tongguankouan' => $tongguankouan,
				'shouhuoren' => $shouhuoren,
				'xiangshubanshu' => $xiangshubanshu,
				'qty' => $qty,
				'maozhong' => $maozhong,
				'yewudanhao' => $yewudanhao,
				'chexing' => $carriage_type,
				'chepai' => $chepai,
				'feiyongtype' => $feiyongtype,
				'shui' => $shui,
				'weishui_amount' => $weishui_amount,
				'hanshui_amount' => $hanshui_amount,
				'comment' => $comment,
				'currency_name' => $currency_info[$currency_id],
				'currency_id' => $currency_id,
				'currency_symbol' => $currency_symbol,
			);
		}
	}
	$total = setTotal($subtotal,$total);$list = setData($data);
	return array('list'=>$list,'subtotal'=>$subtotal,'total'=>$total,'billids'=>$billid_array);
}

// set total
function setTotal($subtotal,$total){
	foreach($subtotal as $accountorvendor => $curr_total){
		if(sizeOf($curr_total) > 1){
			foreach($curr_total as $currency_name => $arr){
				if($currency_name == '人民币'){
					$cur_weishui_amount_tax0_label[] = $currency_name . '：'.$arr['currency_symbol'].$total[$accountorvendor]['weishui_amount_tax0'];
					$cur_hanshui_amount_tax0_label[] = $currency_name . '：'.$arr['currency_symbol'].$total[$accountorvendor]['hanshui_amount_tax0'];
					$cur_weishui_amount_tax6_label[] = $currency_name . '：'.$arr['currency_symbol'].$total[$accountorvendor]['weishui_amount_tax6'];
					$cur_hanshui_amount_tax6_label[] = $currency_name . '：'.$arr['currency_symbol'].$total[$accountorvendor]['hanshui_amount_tax6'];
					$cur_weishui_amount_tax9_label[] = $currency_name . '：'.$arr['currency_symbol'].$total[$accountorvendor]['weishui_amount_tax9'];
					$cur_hanshui_amount_tax9_label[] = $currency_name . '：'.$arr['currency_symbol'].$total[$accountorvendor]['hanshui_amount_tax9'];
					$cur_weishui_amount_tax1_label[] = $currency_name . '：'.$arr['currency_symbol'].$total[$accountorvendor]['weishui_amount_tax1'];
					$cur_hanshui_amount_tax1_label[] = $currency_name . '：'.$arr['currency_symbol'].$total[$accountorvendor]['hanshui_amount_tax1'];
				}else{
					$cur_weishui_amount_tax0_label[] = $currency_name . '：'.$arr['currency_symbol'].$arr['weishui_amount_tax0'];
					$cur_hanshui_amount_tax0_label[] = $currency_name . '：'.$arr['currency_symbol'].$arr['hanshui_amount_tax0'];
					$cur_weishui_amount_tax6_label[] = $currency_name . '：'.$arr['currency_symbol'].$arr['weishui_amount_tax6'];
					$cur_hanshui_amount_tax6_label[] = $currency_name . '：'.$arr['currency_symbol'].$arr['hanshui_amount_tax6'];
					$cur_weishui_amount_tax9_label[] = $currency_name . '：'.$arr['currency_symbol'].$arr['weishui_amount_tax9'];
					$cur_hanshui_amount_tax9_label[] = $currency_name . '：'.$arr['currency_symbol'].$arr['hanshui_amount_tax9'];
					$cur_weishui_amount_tax1_label[] = $currency_name . '：'.$arr['currency_symbol'].$arr['weishui_amount_tax1'];
					$cur_hanshui_amount_tax1_label[] = $currency_name . '：'.$arr['currency_symbol'].$arr['hanshui_amount_tax1'];
				}
			}
			$total[$accountorvendor]['weishui_amount_tax0_label'] = '（'.implode('，',$cur_weishui_amount_tax0_label).'）';
			$total[$accountorvendor]['hanshui_amount_tax0_label'] = '（'.implode('，',$cur_hanshui_amount_tax0_label).'）';
			$total[$accountorvendor]['weishui_amount_tax6_label'] = '（'.implode('，',$cur_weishui_amount_tax6_label).'）';
			$total[$accountorvendor]['hanshui_amount_tax6_label'] = '（'.implode('，',$cur_hanshui_amount_tax6_label).'）';
			$total[$accountorvendor]['weishui_amount_tax9_label'] = '（'.implode('，',$cur_weishui_amount_tax9_label).'）';
			$total[$accountorvendor]['hanshui_amount_tax9_label'] = '（'.implode('，',$cur_hanshui_amount_tax9_label).'）';
			$total[$accountorvendor]['weishui_amount_tax1_label'] = '（'.implode('，',$cur_weishui_amount_tax1_label).'）';
			$total[$accountorvendor]['hanshui_amount_tax1_label'] = '（'.implode('，',$cur_hanshui_amount_tax1_label).'）';
		}
		
		$total[$accountorvendor]['weishui_amount_tax0'] =  number_format($total[$accountorvendor]['weishui_amount_tax0'],2);
		$total[$accountorvendor]['weishui_amount_tax1'] =  number_format($total[$accountorvendor]['hanshui_amount_tax1']/1.01,2);
		$total[$accountorvendor]['weishui_amount_tax6'] =  number_format($total[$accountorvendor]['hanshui_amount_tax6']/1.06,2);
		$total[$accountorvendor]['weishui_amount_tax9'] =  number_format($total[$accountorvendor]['hanshui_amount_tax9']/1.09,2);
		
		$total[$accountorvendor]['hanshui_amount_tax0'] =  number_format($total[$accountorvendor]['hanshui_amount_tax0'],2);
		$total[$accountorvendor]['hanshui_amount_tax1'] =  number_format($total[$accountorvendor]['hanshui_amount_tax1'],2);
		$total[$accountorvendor]['hanshui_amount_tax6'] =  number_format($total[$accountorvendor]['hanshui_amount_tax6'],2);
		$total[$accountorvendor]['hanshui_amount_tax9'] =  number_format($total[$accountorvendor]['hanshui_amount_tax9'],2);
	}
	return $total;
}
//运输 - 客户
function yunshu_kehu(){
	$smower_sql = getSmowerSql();
	$acc_smower_sql = '';
	if(!empty($smower_sql['acc'])){
		$acc_smower_sql = str_replace("ld_customform18","a",$smower_sql['acc']);
	}
	$query = "
		SELECT 
			a.customform18_no AS billno,
			a.customform18id AS billid,
			a.istoerp,
			a.is_duizhang AS zhuangtai,
			a.is_duizhang_date AS zhuangtai_date,
			a.service_type AS yewufenlei,
			k.accountname AS accountorvendor,
			j.customform03_no AS jobno,
			DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
			u.last_name AS jobno_creator,
			y.customs_port AS tongguankouan,
			e.sf156 AS shouhuoren,
			ROUND(SUM(e.sf164),0) AS xiangshubanshu,
			ROUND(SUM(e.sf167),3) AS qty,
			ROUND(SUM(e.sf204),3) AS maozhong,
			y.customform23_no AS yewudanhao,
			y.carriage_type as chexing,
			(
				SELECT 
					CASE
						WHEN ld_customform02scf.cf_3714='内部司机' THEN ld_project.projectname
						ELSE ld_customform02.chepaihao
					END AS chepai
				FROM ld_customform02
                LEFT JOIN ld_customform02scf ON ld_customform02scf.customform02id=ld_customform02.customform02id
				LEFT JOIN ld_project ON ld_project.projectid=ld_customform02.projectid
				WHERE ld_customform02.deleted=0 
					AND ld_customform02.approvestatus<>'已拒绝' 
					AND (
						ld_customform02.yunshudanid_01=a.customform23_id 
							OR ld_customform02.yunshudanid_02=a.customform23_id  
							OR ld_customform02.yunshudanid_03=a.customform23_id  
							OR ld_customform02.yunshudanid_04=a.customform23_id 
						)
				ORDER BY ld_customform02.modifiedtime DESC LIMIT 1
			) AS chepai,
			p.productname AS feiyongtype,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax0,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax0,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax6,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax6,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax9,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax9,
			b.tax2 as shui,
			ROUND(b.tax_amount,2) AS weishui_amount,
			ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
			a.currency_id,
			a.currency_symbol,
			CASE
				WHEN a.currency_id=1 THEN 1.000000
				WHEN a.currency_id=6 THEN 
					(SELECT conversionrate_rmbtoeur FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=7 THEN 
					(SELECT conversionrate_rmbtousd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=10 THEN 
					(SELECT conversionrate_rmbtokrw FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=11 THEN 
					(SELECT conversionrate_rmbtohkd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
				WHEN a.currency_id=12 THEN 
					(SELECT conversionrate_rmbtovnd FROM ld_customform47 WHERE deleted=0 AND a.createdtime 
							BETWEEN validfrom AND validtill AND accountid=a.accountid ORDER BY modifiedtime DESC LIMIT 1)
			END AS conversion_rate,
            a.kis_id,b.comment
		FROM ld_customform18 a
		LEFT JOIN ld_account k ON k.accountid=a.accountid
		lEFT JOIN ld_customform23 y ON y.customform23id=a.customform23_id
		lEFT JOIN ld_customform23scf x ON x.customform23id=y.customform23id
		LEFT JOIN ld_customform23detail d ON d.id=y.customform23id
		LEFT JOIN ld_customform23detailscf e ON e.lineitem_id=d.lineitem_id
		LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
		LEFT JOIN ld_users u ON u.id=j.smcreatorid
		LEFT JOIN ld_customform18detail b ON b.id=a.customform18id
		LEFT JOIN ld_products p ON p.productid=b.productid LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.accountid 
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND a.service_type='运输' $acc_smower_sql 
	";
	if(!empty($_REQUEST['search_name'])){
		$query .= " and k.accountname like '%".$_REQUEST['search_name']."%'";
	}
	if(!empty($_REQUEST['job_starttime']) && empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."'";
	}
	if(empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."' and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_no'])){
		$query .= " and customform03_no = '".$_REQUEST['job_no']."'";
	}
	if(!empty($_REQUEST['duizhang'])){
		$query .= " and a.is_duizhang = '".$_REQUEST['duizhang']."'";
	}
	if(!empty($_REQUEST['creator'])){
		$query .= " and u.last_name = '".$_REQUEST['creator']."'";
	}
	if(!empty($_REQUEST['istoerp']) && $_REQUEST['istoerp'] == '是'){
		$query .= " and a.istoerp = '是'";
	}
	if(!empty($_REQUEST['billid']) ){
		$query .= " and a.customform18id = " . $_REQUEST['billid'];
	}
	if(!empty($_REQUEST['billids']) ){
		$query .= " and a.customform18id in (" . $_REQUEST['billids'].")";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '已对接'){
		$query .= " and a.kis_id > 0";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '未对接'){
		$query .= " and a.kis_id = 0";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."'";
	}
	if(empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."' and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	$query .= " GROUP BY a.customform18id,b.lineitem_id ORDER BY jobno,a.accountid,b.tax2,a.currency_id,jobno_date";
	return $query;
}

//运输 - 供应商
function yunshu_gongyingshang(){
	$smower_sql = getSmowerSql();
	$ven_smower_sql = '';
	if(!empty($smower_sql['ven'])){
		$ven_smower_sql = str_replace("ld_customform19","a",$smower_sql['ven']);
	}
	$query = "
		SELECT
			a.customform19_no AS billno,
			a.customform19id AS billid,
			a.istoerp,
			a.is_duizhang AS zhuangtai,
			a.is_duizhang_date AS zhuangtai_date,
			a.service_type AS yewufenlei,
			k.vendorname AS accountorvendor,
			j.customform03_no AS jobno,
			DATE_FORMAT(j.createdtime,'%Y-%m-%d') AS jobno_date,
			u.last_name AS jobno_creator,
			y.customs_port AS tongguankouan,
			e.sf156 AS shouhuoren,
			ROUND(SUM(e.sf164),0) AS xiangshubanshu,
			ROUND(SUM(e.sf167),3) AS qty,
			ROUND(SUM(e.sf204),3) AS maozhong,
			y.customform23_no AS yewudanhao,
			(
				SELECT 
					ld_customform02.carriage_type
				FROM ld_customform02
				LEFT JOIN ld_project ON ld_project.projectid=ld_customform02.projectid
				WHERE ld_customform02.deleted=0 
					AND ld_customform02.approvestatus<>'已拒绝' 
					AND (
						ld_customform02.yunshudanid_01=a.customform23_id 
							OR ld_customform02.yunshudanid_02=a.customform23_id  
							OR ld_customform02.yunshudanid_03=a.customform23_id  
							OR ld_customform02.yunshudanid_04=a.customform23_id 
						)
				ORDER BY ld_customform02.modifiedtime DESC LIMIT 1
			) AS chexing,
			(
				SELECT 
					ld_customform02.chepaihao
				FROM ld_customform02
				LEFT JOIN ld_project ON ld_project.projectid=ld_customform02.projectid
				WHERE ld_customform02.deleted=0 
					AND ld_customform02.approvestatus<>'已拒绝' 
					AND (
						ld_customform02.yunshudanid_01=a.customform23_id 
							OR ld_customform02.yunshudanid_02=a.customform23_id  
							OR ld_customform02.yunshudanid_03=a.customform23_id  
							OR ld_customform02.yunshudanid_04=a.customform23_id 
						)
				ORDER BY ld_customform02.modifiedtime DESC LIMIT 1
			) AS chepai,
			p.productname AS feiyongtype,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax0,
			CASE
				WHEN b.tax2=0 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax0,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax6,
			CASE
				WHEN b.tax2=6 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax6,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount,2)
				ELSE 0
			END AS weishui_amount_tax9,
			CASE
				WHEN b.tax2=9 OR b.tax2 IS NULL THEN ROUND(b.tax_amount*(1+b.tax2*0.01),2)
				ELSE 0
			END AS hanshui_amount_tax9,
			b.tax2 as shui,
			ROUND(b.tax_amount,2) AS weishui_amount,
			ROUND(b.tax_amount*(1+b.tax2*0.01),2) AS hanshui_amount,
			a.currency_id,
			a.currency_symbol,
    		CASE
    			WHEN a.currency_id=1 THEN 1.000000
    			WHEN a.currency_id=6 THEN 
    				(SELECT conversionrate_rmbtoeur FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
    						BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
    			WHEN a.currency_id=7 THEN 
    				(SELECT conversionrate_rmbtousd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
    						BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
    			WHEN a.currency_id=7 THEN 
    				(SELECT conversionrate_rmbtousd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
    						BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
    			WHEN a.currency_id=10 THEN 
    				(SELECT conversionrate_rmbtokrw FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
    						BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
    			WHEN a.currency_id=11 THEN 
    				(SELECT conversionrate_rmbtohkd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
    						BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
    			WHEN a.currency_id=12 THEN 
    				(SELECT conversionrate_rmbtovnd FROM ld_customform48 WHERE deleted=0 AND a.createdtime 
    						BETWEEN validfrom AND validtill AND vendorid=a.vendorid ORDER BY modifiedtime DESC LIMIT 1)
    		END AS conversion_rate,
            a.kis_id,b.comment
		FROM ld_customform19 a
		LEFT JOIN ld_vendor k ON k.vendorid=a.vendorid
		LEFT JOIN ld_customform02 aa ON aa.customform02id=a.customform02_id
		LEFT JOIN ld_customform23 y ON y.customform23id = GREATEST(aa.yunshudanid_01,aa.yunshudanid_02,aa.yunshudanid_03,aa.yunshudanid_04)
		lEFT JOIN ld_customform23scf x ON x.customform23id=y.customform23id
		LEFT JOIN ld_customform23detail d ON d.id=y.customform23id
		LEFT JOIN ld_customform03 j ON j.customform03id=y.customform03_id
		LEFT JOIN ld_customform23detailscf e ON e.lineitem_id=d.lineitem_id
		LEFT JOIN ld_users u ON u.id=j.smcreatorid
		LEFT JOIN ld_customform19detail b ON b.id=a.customform19id
		LEFT JOIN ld_products p ON p.productid=b.productid 
		LEFT JOIN ld_tabshare ON ld_tabshare.crmid=k.vendorid  
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND a.service_type='运输' $ven_smower_sql 
	";
	if(!empty($_REQUEST['search_name'])){
		$query .= " and vendorname like '%".$_REQUEST['search_name']."%'";
	}
	if(!empty($_REQUEST['job_starttime']) && empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."'";
	}
	if(empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_starttime']) && !empty($_REQUEST['job_endtime'])){
		$query .= " and j.createdtime >= '".$_REQUEST['job_starttime']."' and j.createdtime <= '".$_REQUEST['job_endtime']."'";
	}
	if(!empty($_REQUEST['job_no'])){
		$query .= " and customform03_no = '".$_REQUEST['job_no']."'";
	}
	if(!empty($_REQUEST['duizhang'])){
		$query .= " and a.is_duizhang = '".$_REQUEST['duizhang']."'";
	}
	if(!empty($_REQUEST['creator'])){
		$query .= " and u.last_name = '".$_REQUEST['creator']."'";
	}
	if(!empty($_REQUEST['istoerp']) && $_REQUEST['istoerp'] == '是'){
		$query .= " and a.istoerp = '是'";
	}
	if(!empty($_REQUEST['billid']) ){
		$query .= " and a.customform19id = " . $_REQUEST['billid'];
	}
	if(!empty($_REQUEST['billids']) ){
		$query .= " and a.customform19id in (" . $_REQUEST['billids'].")";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '已对接'){
		$query .= " and a.kis_id > 0";
	}
	if(!empty($_REQUEST['duijie']) && $_REQUEST['duijie'] == '未对接'){
		$query .= " and a.kis_id = 0";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."'";
	}
	if(empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	if(!empty($_REQUEST['duizhang_startdate']) && !empty($_REQUEST['duizhang_enddate'])){
		$query .= " and a.is_duizhang_date >= '".$_REQUEST['duizhang_startdate']."' and a.is_duizhang_date <= '".$_REQUEST['duizhang_enddate']."'";
	}
	if(!empty($_REQUEST['bill_mon']) ){
		$query .= " and a.bill_mon = " . $_REQUEST['bill_mon'];
	}
	
	$query .= " GROUP BY a.customform19id,b.lineitem_id ORDER BY jobno,a.vendorid,b.tax2,a.currency_id,jobno_date";
	//echo $query;echo '<br><br>';die;
	return $query;
}

//ExportData export data excel
function ExportData($data){
	 ob_get_clean();
	 global $adb,$current_user,$currentModule;
	if(file_exists('storage/duizhangbiao.xls'))
	{
		@unlink('storage/duizhangbiao.xls');
	}
	$headers=array('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z');
	$forheaders=array('','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z');
	$i=0;
	include('PHPExcel/PHPExcel.php');
	$objPHPExcel = new PHPExcel();
	$objPHPExcel->setActiveSheetIndex(0);
	$objPHPExcel->getActiveSheet()->setTitle('对账单报表');
	$kk=0;
	$activesheet=$objPHPExcel->getActiveSheet();
	$dupfield_count=0;
	if($_REQUEST['yewu_leixing'] == '报关'){
		$fld_array = array('费用单号','对接金蝶','对账状态','对账日期','对接状态','业务分类','客户/供应商','JOB NO','JOB NO日期','JOB NO创建人','发票号','出口日期','进口日期','申报口岸','品名','数量','货值','件数','毛重','报关单号','六连单号','费用项目','税率','未税金额','含税金额','备注','币种');
		$weishui_row = 24;
		$hanshui_row = 25;
		$row_iw = 'W';
	}else if($_REQUEST['yewu_leixing'] == '运输'){
		$fld_array = array('费用单号','对接金蝶','对账状态','对账日期','对接状态','业务分类','客户/供应商','JOB NO','JOB NO日期','JOB NO创建人','通关口岸','收货人','箱数/板数','数量','毛重','运输单号','车型','车牌','费用项目','税率','未税金额','含税金额','备注','币种');
		$weishui_row = 20;
		$hanshui_row = 21;
		$row_iw = 'T';
	}else if($_REQUEST['yewu_leixing'] == '出入库'){
		$fld_array = array('费用单号','对接金蝶','对账状态','对账日期','对接状态','业务分类','客户/供应商','JOB NO','JOB NO日期','JOB NO创建人','品名','箱数/板数','数量','毛重','运出入库单号','费用项目','税率','未税金额','含税金额','备注','币种');
		$weishui_row = 17;
		$hanshui_row = 18;
		$row_iw = 'N';
	}else if($_REQUEST['yewu_leixing'] == '空运'){
		$fld_array = array('费用单号','对接金蝶','对账状态','对账日期','对接状态','业务分类','客户/供应商','JOB NO','JOB NO日期','JOB NO创建人','航班日期','航班号','主单号','分单号','计费重量','空运单号','费用项目','税率','未税金额','含税金额','备注','币种');
		$weishui_row = 18;
		$hanshui_row = 19;
		$row_iw = 'R';
	}else if($_REQUEST['yewu_leixing'] == '海运'){
		$fld_array = array('费用单号','对接金蝶','对账状态','对账日期','对接状态','业务分类','客户/供应商','JOB NO','JOB NO日期','JOB NO创建人','海运单号','费用项目','税率','未税金额','含税金额','备注','币种');
		$weishui_row = 13;
		$hanshui_row = 14;
		$row_iw = 'M';
	}else if($_REQUEST['yewu_leixing'] == 'Local配送'){
		$fld_array = array('费用单号','对接金蝶','对账状态','对账日期','对接状态','业务分类','客户/供应商','JOB NO','JOB NO日期','JOB NO创建人','Local配送单号','费用项目','税率','未税金额','含税金额','备注','币种');
		$weishui_row = 13;
		$hanshui_row = 14;
		$row_iw = 'M';
	}else{	//全部
		$fld_array = array('费用单号','JOB NO','费用项目','税率','未税金额','含税金额','对接金蝶','对账状态','对账日期','对接状态','业务分类','客户/供应商','JOB NO日期','JOB NO创建人','费用单创建人','对账人','记账月份','发票号','业务日期','进口日期','申报口岸','收货人','品名','箱数/板数','数量','货值','件数','毛重','车型','车牌','六连单号','航班日期','航班号','主单号','分单号','计费重量','业务单号','备注','币种');
		$weishui_row = 4;
		$hanshui_row = 5;
		$row_iw = 'D';
		// $weishui_row = 32;
		// $hanshui_row = 33;
		//$row_iw = 'AF';		
		
	}
	foreach($fld_array as $fieldLabel){
		$columnindex=PHPExcel_Cell::stringFromColumnIndex($kk).'1';
		$objPHPExcel->setActiveSheetIndex(0);
		$activesheet->setCellValue($columnindex,$fieldLabel);
		$activesheet->getColumnDimension($columnindex)->setWidth(20);
		$kk++;
	}
	if(!empty($data['list'])){
		$row = 2;
		
		foreach($data['list'] as $key => $cols){
			$dupfield_count=0;
			$accountorvendor = '';
			foreach($cols as $col_name => $col_value){
				if(in_array($col_name,array('currency_id','currency_symbol','billid','is_kong'))){
					continue;
				}
				if($col_name == 'kis_id'){
					if($col_value > 0)
						$col_value = '已对接';
					else
						$col_value = '未对接';
				}
				if($col_name == 'accountorvendor'){
					$accountorvendor = $col_value;
				}
				$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).$row,$col_value);
				//发票号、报关单号 位数过长显示不正常 
				if($_REQUEST['yewu_leixing'] == 'ALL') {
					if ($dupfield_count== 17 || $dupfield_count== 36)						
						$objPHPExcel->getActiveSheet()->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).$row,$col_value, PHPExcel_Cell_DataType::TYPE_STRING);
				} else {
					if ($dupfield_count== 10 || $dupfield_count== 29)						
						$objPHPExcel->getActiveSheet()->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).$row,$col_value, PHPExcel_Cell_DataType::TYPE_STRING);
				}
                

				
				$dupfield_count++;
			}
			$row++;
			if(strpos($key,'sumtotal') > 0){
				if(!empty($data['subtotal'][$accountorvendor])){
					//小计
					foreach($data['subtotal'][$accountorvendor] as $currency_name => $curr_val){
						$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).$row,'小计：'.$currency_name.'-税0%');
						$objPHPExcel->getActiveSheet()->mergeCells('A'.$row.':'.$row_iw.$row);
						$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($weishui_row).$row,$curr_val['currency_symbol'].$curr_val['weishui_amount_tax0']);
						$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($hanshui_row).$row,$curr_val['currency_symbol'].$curr_val['hanshui_amount_tax0']);
						$row++;
						$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).$row,'小计：'.$currency_name.'-税1%');
						$objPHPExcel->getActiveSheet()->mergeCells('A'.$row.':'.$row_iw.$row);
						$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($weishui_row).$row,$curr_val['currency_symbol'].$curr_val['weishui_amount_tax1']);
						$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($hanshui_row).$row,$curr_val['currency_symbol'].$curr_val['hanshui_amount_tax1']);
						$row++;
						$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).$row,'小计：'.$currency_name.'-税6%');
						$objPHPExcel->getActiveSheet()->mergeCells('A'.$row.':'.$row_iw.$row);
						$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($weishui_row).$row,$curr_val['currency_symbol'].$curr_val['weishui_amount_tax6']);
						$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($hanshui_row).$row,$curr_val['currency_symbol'].$curr_val['hanshui_amount_tax6']);
						$row++;
						$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).$row,'小计：'.$currency_name.'-税9%');
						$objPHPExcel->getActiveSheet()->mergeCells('A'.$row.':'.$row_iw.$row);
						$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($weishui_row).$row,$curr_val['currency_symbol'].$curr_val['weishui_amount_tax9']);
						$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($hanshui_row).$row,$curr_val['currency_symbol'].$curr_val['hanshui_amount_tax9']);
						$row++;
					}
					//合计
					$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).$row,'合计：人民币-税0%'.$data['total'][$accountorvendor]['weishui_amount_tax0_label']);
					$objPHPExcel->getActiveSheet()->mergeCells('A'.$row.':'.$row_iw.$row);
					$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($weishui_row).$row,'¥'.$data['total'][$accountorvendor]['weishui_amount_tax0']);
					$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($hanshui_row).$row,'¥'.$data['total'][$accountorvendor]['hanshui_amount_tax0']);
					$row++;
					$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).$row,'合计：人民币-税1%'.$data['total'][$accountorvendor]['weishui_amount_tax1_label']);
					$objPHPExcel->getActiveSheet()->mergeCells('A'.$row.':'.$row_iw.$row);
					$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($weishui_row).$row,'¥'.$data['total'][$accountorvendor]['weishui_amount_tax1']);
					$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($hanshui_row).$row,'¥'.$data['total'][$accountorvendor]['hanshui_amount_tax1']);
					$row++;
					$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).$row,'合计：人民币-税6%'.$data['total'][$accountorvendor]['weishui_amount_tax6_label']);
					$objPHPExcel->getActiveSheet()->mergeCells('A'.$row.':'.$row_iw.$row);
					$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($weishui_row).$row,'¥'.$data['total'][$accountorvendor]['weishui_amount_tax6']);
					$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($hanshui_row).$row,'¥'.$data['total'][$accountorvendor]['hanshui_amount_tax6']);
					$row++;
					$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).$row,'合计：人民币-税9%'.$data['total'][$accountorvendor]['weishui_amount_tax9_label']);
					$objPHPExcel->getActiveSheet()->mergeCells('A'.$row.':'.$row_iw.$row);
					$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($weishui_row).$row,'¥'.$data['total'][$accountorvendor]['weishui_amount_tax9']);
					$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($hanshui_row).$row,'¥'.$data['total'][$accountorvendor]['hanshui_amount_tax9']);
					$row++;
					/*echo '<pre>';
					print_r($data['subtotal'][$accountorvendor]);
					echo '</pre>';
					die;*/
				}
			}
		}
	}
	//die;
	$modulelabel = str_replace(' ','_',iconv('UTF-8','gbk','对账单报表'));
	$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
	$objWriter->save('storage/duizhangbiao.xls');   
	//下载文件
	$file_name = "duizhangbiao.xls";
	$file_dir = "storage/";
	$file = fopen($file_dir.$file_name,"r"); 
	Header("Content-type: application/octet-stream");
	Header("Accept-Ranges: bytes");
	Header("Accept-Length: ".filesize($file_dir . $file_name));

	//$modulelabel=iconv('UTF-8','gb2312',$modulelabel);
	Header("Content-Disposition: attachment; filename=".$modulelabel.".xls" );
	ob_get_clean();
	ob_clean();   
	flush(); 
	echo fread($file, filesize($file_dir.$file_name));
	fclose($file);
}
?>