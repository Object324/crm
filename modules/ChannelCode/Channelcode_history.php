<?php
global   $adb, $currentModule, $current_user;
global $list_max_entries_per_page_new_more,$adb;
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty;
if(!empty($_REQUEST['record'])){
	$start = 1;
	if(!empty($_REQUEST['start'])){
		$start = $_REQUEST['start'];
	}
	$limit_start_rec = ($start-1) * $list_max_entries_per_page_new_more;
	$query = "select record,ld_users.last_name,external_contact_name,external_contact_corpname,external_contact_type,externaluserid,ld_channelcode_history.createdtime,changetype from ld_channelcode_history
		LEFT JOIN ld_users on ld_users.wx_userid = ld_channelcode_history.wx_userid
		where record = ? and ld_channelcode_history.deleted = 0 order by ld_channelcode_history.createdtime desc";
	$result = $adb->pquery($query,array($_REQUEST['record']));
	$noofrows = $adb->num_rows($result);
	$query .= " limit $limit_start_rec,$list_max_entries_per_page_new_more";
	$result = $adb->pquery($query,array($_REQUEST['record']));
	$num_rows = $adb->num_rows($result);
	$all_page = ceil($noofrows/$list_max_entries_per_page_new_more);
	$pre_page = 'no';
	$next_page = 'no';
	$next_page_num = 1;
	$pre_page_num = 1;
	if($all_page > $start){
		$next_page = 'yes';
		$next_page_num = $start + 1;
	}
	if($start > 1){
		$pre_page = 'yes';	
		$pre_page_num = $start - 1;
	}
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$external_contact_type = $adb->query_result($result,$i,'external_contact_type');	//微信类型 1表示该外部联系人是微信用户，2表示该外部联系人是企业微信用户
			if($external_contact_type == 1){
				$type = getFixedLabel('wechat');
			}else if($external_contact_type == 2){
				$type = getFixedLabel('LBL_ENTERPRISEWECHAT');
			}
			$data[$i] = array(
				'last_name' => $adb->query_result($result,$i,'last_name'),
				'external_contact_name' => $adb->query_result($result,$i,'external_contact_name'),
				'external_contact_corpname' => $adb->query_result($result,$i,'external_contact_corpname'),
				'external_contact_type' => $type,
				'createdtime' => $adb->query_result($result,$i,'createdtime'),
			);
		}
	}
}
//渠道码的分页 zxm 20221208
$url_qry = '';
crm_load_class_file('ListView_Page_Special', 'include/utils');
crm_load_class_file('ListViewUtils', 'include/utils');
$navigation_array =  VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
$navigationOutput[] =  getRecordRangeMessage($result, $limit_start_rec,$noofrows);
$navigationOutput[] = ListView_Page_Special::getChannelCodeHistoryHeaderNavigation($navigation_array, $url_qry,$currentModule,'',$_REQUEST['record']);

$smarty->assign('navigationOutput',$navigationOutput);
$smarty->assign('ALLPAGE',$all_page);
$smarty->assign('NEXTPAGENUM',$next_page_num);
$smarty->assign('PREPAGENUM',$pre_page_num);
$smarty->assign('NEXTPAGE',$next_page);
$smarty->assign('PREPAGE',$pre_page);
$smarty->assign('PAGE',$start);
$smarty->assign('COUNTROWS',$noofrows);
$smarty->assign('RECORD',$_REQUEST['record']);
$smarty->assign('DATA',$data);
$smarty->assign('AJAX',$_REQUEST['ajax']);
$_REQUEST['diony']='diony';
$str=$smarty->fetch("Channelcode_history.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
?>