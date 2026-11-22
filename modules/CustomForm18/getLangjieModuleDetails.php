<?php
global $current_user,$currentModule,$adb,$languageType;

$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty;
$order_id = $_REQUEST['order_id'];
$record = $_REQUEST['record'];
$service_type = $_REQUEST['service_type'];
crm_load_class_file('cls_LangjieModuleDetails','modules/CustomForm18');
$cls_LangjieModuleDetails = new cls_LangjieModuleDetails($order_id,$record,$service_type);

$data = $cls_LangjieModuleDetails->getOrderDetails(1);

$order_detail_info = $cls_LangjieModuleDetails->getOrderModuleFields();
$fields = $order_detail_info['fields'];
$width = $order_detail_info['width'];
$cur_fields = $order_detail_info['cur_fields'];

$_REQUEST['diony']='diony';
ConvertTojsonString(1,array('object_data'=>$data,'object_field'=>$fields,'width'=>$width,'object_field_all'=>$cur_fields),"success");
exit();











if($service_type == '报关订单'){
	/*
	*当“服务项目”选择“报关订单”的时候，根据报关单和费用类型带出分录：
	*a.如果“报关订单”的“报关类型”是“出口”，则根据该报关单的“申报口岸”和“合同编号”，自动带出合同->相关信息->出口报关单据分录中对应“出口口岸”的分录信息
	*b.如果“报关订单”的“报关类型”是“进口”，则根据该报关单的“申报口岸”和“合同编号”，自动带出合同->相关信息->进口报关单据分录中对应“进口口岸”的分录信息
	*/
	$query = 'select declare_type,port_no from ld_customform22 where customform22id = ? and deleted = 0 limit 1';
	$result = $adb->pquery($query,array($record));
	$declare_type = $adb->query_result($result,0,0);	//报关类型
	$port_no = $adb->query_result($result,0,1);	//申报口岸
	if($declare_type == '进口'){
		$declare_module = 'CustomForm12';	//进口报关单
	}else{
		$declare_module = 'CustomForm11';	//出口报关单
	}
	$data = getOrderDetails($declare_module,$order_id,1,$port_no);
}else if($service_type == '运输订单'){
	/*
	*当“服务项目”选择“运输订单”的时候，则根据该运输订单分录的“装货地点”和“送货地点”，以及“合同编号”，自动带出合同->相关信息->运输单据中对应“启运地”和“目的地”的单据分录
	*/
	$query = 'select sf158,sf161 from ld_customform23 LEFT JOIN ld_customform23detail on ld_customform23detail.id = ld_customform23.customform23id 
	LEFT JOIN ld_customform23detailscf on ld_customform23detailscf.lineitem_id = ld_customform23detail.lineitem_id
	where ld_customform23.customform23id = ? and deleted = 0';
	$result = $adb->pquery($query,array($record));
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$sf158 = $adb->query_result($result,$i,'sf158');	//装货地点
			$sf161 = $adb->query_result($result,$i,'sf161');	//送货地点
			$yunshudidian[] = $sf158.$sf161;
		}
	}
	$declare_module = 'CustomForm13';	//运输单
	$data = getOrderDetails($declare_module,$order_id,1,$yunshudidian);
}else if($service_type == '仓储订单'){
	/*
	*当“服务项目”选择“仓储订单”的时候，则根据选定的“合同编号”和“Port”，自动带出合同->相关信息->仓储单据中对应“Port”的单据分录
	*/
	$storage_port = $_REQUEST['storage_port'];	//Port
	$declare_module = 'CustomForm14';	//仓储
	$data = getOrderDetails($declare_module,$order_id,1,$storage_port);
}else if($service_type == '空运订单'){
	/*
	*当“服务项目”选择“空运订单”的时候，并且该空运订单的“启运港”是“中国境内”，则根据该空运订单的“合同编号”，自动带出合同->相关信息->出口空运单据的单据分录
	*当“服务项目”选择“空运订单”的时候，并且该空运订单的“目的港”是“中国境内”，则根据该空运订单的“合同编号”，自动带出合同->相关信息->进口空运单据的单据分录
	*/
	$query = 'select start_port,end_port from ld_customform24 where customform24id = ? and deleted = 0 limit 1';
	$result = $adb->pquery($query,array($record));
	$start_port = $adb->query_result($result,0,0);	//启运港
	$end_port = $adb->query_result($result,0,1);	//目的港
	$start_port_detail = array();
	$end_port_detail = array();
	$data = array();
	//如果两个都满足，默认：启运港
	if($start_port == '中国境内' && $end_port == '中国境内'){
		$declare_module = 'CustomForm15';	//仓储
		$data = getOrderDetails($declare_module,$order_id,1,'出口空运');
	}else{
		if($start_port == '中国境内'){
			$declare_module = 'CustomForm15';	//仓储
			$data = getOrderDetails($declare_module,$order_id,1,'出口空运');
		}

		if($end_port == '中国境内'){
			$declare_module = 'CustomForm16';	//仓储
			$data = getOrderDetails($declare_module,$order_id,1,'进口空运');
		}
	}
	/*$details = array_merge($start_port_detail,$end_port_detail);
	if(!empty($details)){
		$i_row = 1;
		foreach($details as $arr){
			$data[$i_row] = $arr;
			$i_row++;
		}
	}*/
}
$order_detail_info = getOrderModuleFields($declare_module);
$fields = $order_detail_info['fields'];
$width = $order_detail_info['width'];
$cur_fields = $order_detail_info['cur_fields'];

$_REQUEST['diony']='diony';
ConvertTojsonString(1,array('object_data'=>$data,'object_field'=>$fields,'width'=>$width,'object_field_all'=>$cur_fields),"success");

//获取合同对应相关模块的表体信息
function getOrderModuleFields($module){
	global $languageType,$currentModule;
	//当前模块的所有字段
	$tabid = getTabid($currentModule);
	crm_load_class_file('ProductToolFields','include/ProductDetails');
	$ProductToolFields =  new ProductToolFields($currentModule);
	$curmoduleProductToolField = $ProductToolFields->getModuleProductToolField($tabid,$languageType);
	foreach($curmoduleProductToolField as $columnname => $fieldobj){
		$cur_fields[] = $columnname;
	}
	//合同对应相关模块的表体字段
	$tabid = getTabid($module);
	crm_load_class_file('ProductToolFields','include/ProductDetails');
	$ProductToolFields =  new ProductToolFields($module);
	$moduleProductToolField = $ProductToolFields->getModuleProductToolField($tabid,$languageType);
	$width = 25;
	foreach($moduleProductToolField as $columnname => $fieldobj){
		$width += $fieldobj->getWidth();
		$order_fields[] = $columnname;
	}
	//$fields=array_diff($cur_fields,$order_fields);
	return array('cur_fields'=>$cur_fields,'fields'=>$order_fields,'width'=>$width);
}

//获取满足条件的标体数据
function getOrderDetails($declare_module,$order_id,$i_row,$where_colname){
	global $adb;
	$declare_focus = CRMEntity::getInstance($declare_module);
	if($_REQUEST['feiyong_type'] == '应付'){
		//供应商合同编号
		$query = 'select GROUP_CONCAT('.$declare_focus->table_index.') as id from '.$declare_focus->table_name.' where customform04_id = ? and deleted = 0';
	}else{
		//客户合同编号
		$query = 'select GROUP_CONCAT('.$declare_focus->table_index.') as id from '.$declare_focus->table_name.' where potentialid = ? and deleted = 0';	
	}
	$result = $adb->pquery($query,array($order_id));
	$declare_record = $adb->query_result($result,0,0);
	$declare_focus = CRMEntity::getInstance($declare_module);
	$declare_record_array = explode(',',$declare_record);
	if(!empty($declare_record_array)){
		crm_load_class_file('cls_productDetailsData',"modules/$declare_module/ProductDetails");
		$ProductDetailsData = new cls_productDetailsData($declare_module);
		foreach($declare_record_array as $id){
			$declare_focus->id = $id;
			$declare_focus->mode = 'edit';
			$ass_data = $ProductDetailsData->getProductToolFieldValue($declare_focus,'edit');
			foreach($ass_data as $res){
				foreach($res as $columnname => $value){
					$col = substr($columnname, 0, 2);
					if(!in_array($columnname,array('productid','productname','comment')) && $col != 'sf'){
						unset($res[$columnname]);
					}else{
						if($col == 'sf' && ((is_numeric($value) == true && $value <= 0.00) || $value == '')){
							unset($res[$columnname]);
						}
					}
				}
				if($declare_module == 'CustomForm12'){
					if($res['sf1427'] == $where_colname){
						$data[$i_row] = $res;
						$i_row++;
					}
				}else if($declare_module == 'CustomForm11'){
					if($res['sf1291'] == $where_colname){
						$data[$i_row] = $res;
						$i_row++;
					}
				}else if($declare_module == 'CustomForm13'){
					$dizhi = $res['sf5099'].$res['sf5235'];
					if(in_array($dizhi,$where_colname)){
						$data[$i_row] = $res;
						$i_row++;
					}
				}else if($declare_module == 'CustomForm14'){
					if($res['sf8499'] == $where_colname){
						$data[$i_row] = $res;
						$i_row++;
					}
				}else if($declare_module == 'CustomForm15' || $declare_module == 'CustomForm16'){
					if($res['productname'] == $where_colname){
						$data[$i_row] = $res;
						$i_row++;
					}
				}
			}
		}
	}
	return $data;
}
?>