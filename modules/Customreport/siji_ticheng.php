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
$siji_startdate=date('Y-m-01', strtotime(date("Y-m-d")));
$siji_enddate = date('Y-m-d', strtotime("$siji_startdate +1 month -1 day"));
if(!empty($_REQUEST['siji_startdate'])){
	$siji_startdate = $_REQUEST['siji_startdate'];
}
if(!empty($_REQUEST['siji_enddate'])){
	$siji_enddate = $_REQUEST['siji_enddate'];
}
//对账状态
if(!empty($_REQUEST['update_duizhang']) && $_REQUEST['update_duizhang'] == 'yes' && !empty($_REQUEST['ids'])){
	$query = 'update ld_customform02 set is_duizhang = ? where customform02id in ('.$_REQUEST['ids'].') and is_duizhang = \'未确认\'';
	$adb->pquery($query,array('已确认'));
}
$query = "SELECT 
	DATE_FORMAT(b.cf_2999,'%Y-%m-%d') AS date,
	c.projectname AS chepai,
	v.vendorname AS siji,
	is_duizhang,
	a.customform02id,
	a.customform02_no AS jihua_no,
	
	a.startplace_01 AS tihuodian_01,
	k1.accountname AS kehu_01,
	b.cf_3045 AS qty_01,
	b.cf_2993 AS xingtai_01,
	a.endplace_01 AS songhuodian_01,
	case when c.projectname = 'DV699' and v.vendorname ='黎国权' then a.tcfee_01 * 2 
         when c.projectname = 'AV972' and v.vendorname ='卓义华' then a.tcfee_01 * 1.5 
         else a.tcfee_01
     end tcfee_01,
	a.btfee_01,

	a.startplace_02 AS tihuodian_02,
	k2.accountname AS kehu_02,
	b.cf_3047 AS qty_02,
	b.cf_3000 AS xingtai_02,
	a.endplace_02 AS songhuodian_02,
	0 tcfee_02,
	0 btfee_02,

	a.startplace_03 AS tihuodian_03,
	k3.accountname AS kehu_03,
	b.cf_3049 AS qty_03,
	b.cf_3005 AS xingtai_03,
	a.endplace_03 AS songhuodian_03,
	0 tcfee_03,
	0 btfee_03,

	a.startplace_04 AS tihuodian_04,
	k4.accountname AS kehu_04,
	b.cf_3051 AS qty_04,
	b.cf_3010 AS xingtai_04,
	a.endplace_04 AS songhuodian_04,
	0 tcfee_04,
	0 btfee_04

FROM ld_customform02 a
LEFT JOIN ld_customform02scf b ON b.customform02id=a.customform02id
LEFT JOIN ld_project c ON c.projectid=a.projectid
LEFT JOIN ld_vendor v ON v.vendorid=a.vendorid
LEFT JOIN ld_account k1 ON k1.accountid=a.accountid_01
LEFT JOIN ld_account k2 ON k2.accountid=a.accountid_02
LEFT JOIN ld_account k3 ON k3.accountid=a.accountid_03
LEFT JOIN ld_account k4 ON k4.accountid=a.accountid_04
WHERE a.deleted=0
	AND a.approvestatus<>'已拒绝'
	AND b.cf_3714='内部司机'
";
if(!empty($siji_startdate) && !empty($siji_enddate)){
	$query .= " and DATE_FORMAT(b.cf_2999,'%Y-%m-%d') >= '".$siji_startdate."' and DATE_FORMAT(b.cf_2999,'%Y-%m-%d') <= '".$siji_enddate."'";
}
if(!empty($_REQUEST['siji_zhuangtai'])){
	$query .= " and is_duizhang = '".$_REQUEST['siji_zhuangtai']."'";
}
if(!empty($_REQUEST['siji_name'])){
	$query .= " and v.vendorname like '%".$_REQUEST['siji_name']."%'";
}
if(!empty($_REQUEST['siji_chepaihao'])){
	$query .= " and c.projectname = '".$_REQUEST['siji_chepaihao']."'";
}
if(!empty($_REQUEST['siji_xingtai'])){
	$query .= " and (b.cf_2993 = '".$_REQUEST['siji_xingtai']."' or b.cf_3000 = '".$_REQUEST['siji_xingtai']."' or b.cf_3005 = '".$_REQUEST['siji_xingtai']."' or b.cf_3010 = '".$_REQUEST['siji_xingtai']."')";
}
$query .= ' ORDER BY CONVERT(v.vendorname USING GBK),date';
//echo $query;echo '<br><br>';
$result = $adb->pquery($query,array());
$num_rows = $adb->num_rows($result);
$total = 0;
$ids = array();
if($num_rows > 0){
	for($i = 0; $i < $num_rows; $i++){
		$data[] = array(
			'date' => $adb->query_result($result,$i,'date'),
			'chepai' => $adb->query_result($result,$i,'chepai'),
			'siji' => $adb->query_result($result,$i,'siji'),
			'is_duizhang' => $adb->query_result($result,$i,'is_duizhang'),
			'customform02id' => $adb->query_result($result,$i,'customform02id'),
			'xiaoji' => $adb->query_result($result,$i,'tcfee_01') + $adb->query_result($result,$i,'btfee_01') + $adb->query_result($result,$i,'tcfee_02')+ $adb->query_result($result,$i,'btfee_02') + $adb->query_result($result,$i,'tcfee_03') + $adb->query_result($result,$i,'btfee_03')+$adb->query_result($result,$i,'tcfee_04')+$adb->query_result($result,$i,'btfee_04'),
			'jihua_no' => $adb->query_result($result,$i,'jihua_no'),
			'tihuodian_01' => $adb->query_result($result,$i,'tihuodian_01'),
			'kehu_01' => $adb->query_result($result,$i,'kehu_01'),
			'qty_01' => $adb->query_result($result,$i,'qty_01'),
			'xingtai_01' => $adb->query_result($result,$i,'xingtai_01'),
			'songhuodian_01' => $adb->query_result($result,$i,'songhuodian_01'),
			'tcfee_01' => $adb->query_result($result,$i,'tcfee_01'),
			'btfee_01' => $adb->query_result($result,$i,'btfee_01'),
			'tihuodian_02' => $adb->query_result($result,$i,'tihuodian_02'),
			'kehu_02' => $adb->query_result($result,$i,'kehu_02'),
			'qty_02' => $adb->query_result($result,$i,'qty_02'),
			'xingtai_02' => $adb->query_result($result,$i,'xingtai_02'),
			'songhuodian_02' => $adb->query_result($result,$i,'songhuodian_02'),
			'tcfee_02' => $adb->query_result($result,$i,'tcfee_02'),
			'btfee_02' => $adb->query_result($result,$i,'btfee_02'),
			'tihuodian_03' => $adb->query_result($result,$i,'tihuodian_03'),
			'kehu_03' => $adb->query_result($result,$i,'kehu_03'),
			'qty_03' => $adb->query_result($result,$i,'qty_03'),
			'xingtai_03' => $adb->query_result($result,$i,'xingtai_03'),
			'songhuodian_03' => $adb->query_result($result,$i,'songhuodian_03'),
			'tcfee_03' => $adb->query_result($result,$i,'tcfee_03'),
			'btfee_03' => $adb->query_result($result,$i,'btfee_03'),
			'tihuodian_04' => $adb->query_result($result,$i,'tihuodian_04'),
			'kehu_04' => $adb->query_result($result,$i,'kehu_04'),
			'qty_04' => $adb->query_result($result,$i,'qty_04'),
			'xingtai_04' => $adb->query_result($result,$i,'xingtai_04'),
			'songhuodian_04' => $adb->query_result($result,$i,'songhuodian_04'),
			'tcfee_04' => $adb->query_result($result,$i,'tcfee_04'),
			'btfee_04' => $adb->query_result($result,$i,'btfee_04'),
		);
		$ids[] = $adb->query_result($result,$i,'customform02id');
	}
	$list['list'] = setData($data);
	foreach($data as $key => $arr){
		$list['subtotal'][$arr['siji']] += $arr['xiaoji'];
		$total += $arr['xiaoji'];
	}
}
$list['total'] = $total;
$smarty->assign('ID',implode(',',$ids));
$smarty->assign('SIJI_STARTDATE',$siji_startdate);
$smarty->assign('SIJI_ENDDATE',$siji_enddate);
$smarty->assign('DATA',$list);

if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
{
    $smarty->display("langjie/siji_ticheng_content.tpl");
}
	
else
	$smarty->display('langjie/siji_ticheng.tpl');

function setData($data){
	if(!empty($data)){
		$before_reocrd = 0;
		$before_reocrd_num = 0;
		$before_accountname = '';
		$before_currecncy = 0;
		foreach($data as $key => $arr){

			//echo $key.'=='.$before_accountname.'------'.$data[$key+1]['accountorvendor'];echo '<br><br>';
			
			if(!empty($before_accountname) && $before_accountname != $data[$key+1]['siji']){
				$key .= '_sumtotal';
				$before_accountname = $data[$key+1]['siji'];
			}else{
				$before_accountname = $arr['siji'];
				/*
				if($before_currecncy > 0 && $before_currecncy !=  $data[$key+1]['currency_id']){
					//$key .= '_subtotal';
				}*/
				if($arr['siji'] != $data[$key+1]['siji'] ){
					$key .= '_sumtotal';
					//$key .= '_subtotal';
				}
				//$before_currecncy = $arr['currency_id'];
			}
			
		

			$list[$key] = $arr;
			
		}
	}
	return $list;
}
?>