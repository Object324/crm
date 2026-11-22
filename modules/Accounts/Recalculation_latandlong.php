<?php
/**
* edit: chj
* reason: 客户  重算经纬度
* date: 2020/12/16
**/
global $adb,$current_user,$currentModule;
require_once globalStatic::$root_directory.'appCommon/appCommon.php';
$smarty=new lingdangCRM_Smarty();
crm_load_class_file('cls_Tencent_Map', 'include/utils');
$cls_Tencent_Map = new cls_Tencent_Map();
//重算经纬度 - 加载进度条
if(!empty($_REQUEST['mode']) && $_REQUEST['mode'] == 'update' || $_REQUEST['show_progress'] == 'yes'){
	//经纬度按什么方式重算（省份+城市+区域+地址），重算后是否反写 定位地址
	//获取批量处理数
	$deployarray=getSys_deploy(67);
	$btach_num =  $deployarray['deploy_value'];
	//成功条目数
	$success_num = $_REQUEST['success_num'];
	$records_arr = [];
	$endimporttime=date("Y-m-d H:i:s");
	$startrow = $_REQUEST['startrow'];
	$endrow = $_REQUEST['endrow'];
	//重算结果日志
	$progress_log = '';
	if($_REQUEST['show_progress'] == 'yes'){
		$_SESSION['recalculation_lat_and_long_'.$currentModule.'_'.$current_user->id.'_startdate'] = date("Y-m-d H:i:s");
	}
	$startimporttime=$_SESSION['recalculation_lat_and_long_'.$currentModule.'_'.$current_user->id.'_startdate'];
	$records_arr = explode(',',$_REQUEST['records']);
	$maxrows = sizeOf($records_arr);
	if(empty($endrow))
	{
		$endrow=1;
	}
	$between_rows=$endrow-$startrow;
	if(empty($between_rows)){
		$between_rows=1;
	}
	$between_seconds=DateOperation::sencods_between_time($endimporttime,$startimporttime);
	if(empty($between_seconds)){
		$between_seconds=1;
	}           
	$Average_time=$between_seconds/$endrow;
	if($btach_num < $maxrows)
		$balance_import_rows=$btach_num-$endrow;
	else
		$balance_import_rows=$maxrows-$endrow;

	if($balance_import_rows<=0){
		$balance_import_rows=0;
	}

	$balance_time=intval($Average_time*$balance_import_rows);
	if($balance_import_rows>0&&$balance_time<=0){
		$balance_time=1;
	}
	if($btach_num < $maxrows)
		$totalseconds=intval($btach_num*$Average_time);
	else
		$totalseconds=intval($maxrows*$Average_time);
 
	$hours=intval($balance_time/3600);
	$minutes=intval(($balance_time-intval($balance_time/3600)*3600)/60);
	$seconds=$balance_time-(60*$minutes+$hours*3600);
	
	$time_description = sprintf(getFixedLabel('AtotalofNdatarecalculationoflatitudeandlongitude'),$maxrows) . "<span class='num'>".$hours.":".$minutes.":".$seconds."</span>";
	
	//显示进度条
	if($_REQUEST['show_progress'] == 'yes'){
		$_REQUEST['diony']='diony';
		$content=$smarty->fetch("Accounts/Recalculation_latandlong_progress.tpl");
		$arr['title']=getFixedLabel("Recalculatethelatitudeandlongitude");
		$arr['content']=$content;
		$arr['oktext']=getFixedLabel("CONFIRME");
		$arr['timedescription'] = $time_description;
		$arr['maxrows'] = $maxrows;
		ConvertTojsonString(1,$arr,"success");
	}
	$ids = [];
	foreach($records_arr as $key => $record){
		if($key < $btach_num){
			if($key >= $startrow && $key <= $endrow){
				$ids[] = $record;
			}
		}
	}
	if(!empty($ids)){
		$query = "select CONCAT_WS('',bill_state,bill_city,bill_area,bill_street) as address,accountid,accountname from ld_account where accountid in (".implode(',',$ids).") and deleted = 0";
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i=0; $i<$num_rows; $i++){
				$address = $adb->query_result($result,$i,'address');
				$accountid = $adb->query_result($result,$i,'accountid');
				$accountname = $adb->query_result($result,$i,'accountname');
				$point = $cls_Tencent_Map->getPoint($address);
				//44557: PC端保存客户、重算经纬度功能异常，无法计算经纬度
				//$accountAddressInfos=getCoordinateByTecentApi($address);
				if(!empty($point)){
					$success_num++;
					//单据重算经纬度成功！
					$progress_log .= sprintf(getFixedLabel('Documentrecalculationlongitudeandlatitudesuccess'),'<a href="javascript:;" module="Accounts" record="'.$accountid.'"  onclick="ListLinkClick(ld(this),event)">'.$accountname.'</a>').'<br>';
					$longtitude = $point['lng'];
					$latitude = $point['lat'];
					$adb->pquery('update ld_account set location_address =?, longtitude = ?, latitude = ? where accountid = ?',array($address,$longtitude,$latitude,$accountid));
				}else{
					//单据重算经纬度失败！原因：地址信息不完整！
					$progress_log .= sprintf(getFixedLabel('Documentrecalculationoflatitudeandlongitudefailed'),'<a href="javascript:;" module="Accounts" record="'.$accountid.'"  onclick="ListLinkClick(ld(this),event)">'.$accountname.'</a>').'<br>';
				}
			}
		}
	}
	if($btach_num < $maxrows)
		$cur_progress_step=intval($endrow/$btach_num*100);
	else
		$cur_progress_step=intval($endrow/$maxrows*100);
	if($cur_progress_step >= 100)
	{
		$cur_progress_step=100;
	}
	$progress_result = sprintf(getFixedLabel('Therearealtogetherdatarecalculations'),$maxrows,$success_num,$maxrows - $success_num);	//执行结果
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,array('endrow'=>$endrow,'timedescription'=>$time_description,'cur_progress_step'=>$cur_progress_step,'maxrows'=>$maxrows,'progress_result'=>$progress_result,'success_num'=>$success_num,'progress_log'=>$progress_log),"success");
}else{	//显示重算经纬度界面	
	$have_address = 0;	//重算所有有地址的记录
	$have_address_and_no_latandlong = 0;	//重算有地址没有经纬度的记录
	if(!empty($_REQUEST['select_ids'])){
		$record_str = '';	//需要处理的单据id
		if($_REQUEST['select_ids'] == 'all'){
			$customView = CustomView::getInstance($currentModule);
			$queryGenerator =QueryGenerator::getInstance($currentModule, $current_user,$customView);
			$viewid = $customView->getViewId($currentModule);
			if ($viewid != "0") {
			   $queryGenerator->initForCustomViewById($viewid);
			} else {
				$queryGenerator->initForDefaultCustomView();
			}
			if($_REQUEST['query'] == 'true') {
				$_REQUEST['searchtype'] = trim($_REQUEST['searchtype']);
				$queryGenerator->addUserSearchConditions($_REQUEST);
			}
			$page_list_query=$queryGenerator->getQuery('',1);
			list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);
			$result = $adb->pquery($page_list_query,array());
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				for($i = 0; $i < $num_rows; $i++){
					$all_records[] = $adb->query_result($result,$i,'accountid');
				}
			}
			$record_str = implode(',',$all_records);
		}else{
			$all_records = explode(';',rtrim($_REQUEST['select_ids'],';'));
			$record_str = implode(',',$all_records);
		}
		if(!empty($record_str)){
			//重算有地址没有经纬度的记录
			$query = 'select GROUP_CONCAT(accountid) as ids,count(1) as cnt from ld_account where accountid in ('.$record_str.') and CONCAT_WS(\'\',ifnull(bill_state,\'\'),ifnull(bill_city,\'\'),ifnull(bill_street,\'\')) <> \'\' and (longtitude is null or longtitude = \'\' or latitude is null or latitude = \'\') ';
			$result = $adb->pquery($query,array());
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				$have_address_and_no_latandlong = $adb->query_result($result,0,'cnt');
				$have_address_and_no_latandlong_records = $adb->query_result($result,0,'ids');
			}
			//重算所有有地址的记录
			$query = 'select GROUP_CONCAT(accountid) as ids,count(1) as cnt from ld_account where accountid in ('.$record_str.') and CONCAT_WS(\'\',ifnull(bill_state,\'\'),ifnull(bill_city,\'\'),ifnull(bill_street,\'\')) <> \'\' ';
			$result = $adb->pquery($query,array());
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				$have_address = $adb->query_result($result,0,'cnt');
				$have_address_records = $adb->query_result($result,0,'ids');
			}
			
		}
	}
	$smarty->assign('HAVE_ADDRESS_RECORDS_DESC',sprintf(getFixedLabel('Recalculateallrecords'),$have_address));
	$smarty->assign('HAVE_ADDRESS_AND_NO_LATANDLONG_RECORDS_DESC',sprintf(getFixedLabel('Recalculationhavenorecordoflatitudeandlongitude'),$have_address_and_no_latandlong));
	$smarty->assign('HAVE_ADDRESS_RECORDS',$have_address_records);
	$smarty->assign('HAVE_ADDRESS_AND_NO_LATANDLONG_RECORDS',$have_address_and_no_latandlong_records);
	$_REQUEST['diony']='diony';
	$content=$smarty->fetch("Accounts/Recalculation_latandlong.tpl");
	$arr['title']=getFixedLabel("Recalculatethelatitudeandlongitude");
	$arr['oktext']=getFixedLabel("CONFIRME");
	$arr['canceltext']=getFixedLabel("CANCEL");
	$arr['content']=$content;
	ConvertTojsonString(1,$arr,"success");
}
?>