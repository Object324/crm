<?php


class cls_LangjieModuleDetails
{
	
    public function __construct($order_id,$record,$service_type)
    {
		$this->order_id = $order_id;
		$this->record = $record;
		$this->service_type = $service_type;
		$this->setDeclareOrder();
    }
	
	//获取合同对应相关模块的表体信息
	function getOrderModuleFields(){
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
		$tabid = getTabid($this->declare_module);
		crm_load_class_file('ProductToolFields','include/ProductDetails');
		$ProductToolFields =  new ProductToolFields($this->declare_module);
		$moduleProductToolField = $ProductToolFields->getModuleProductToolField($tabid,$languageType);
		$width = 25;
		if(!empty($this->module_colname_all)){
			foreach($moduleProductToolField as $columnname => $fieldobj){
				if(in_array($columnname,$this->module_colname_all)){
					$width += $fieldobj->getWidth();
					$order_fields[] = $columnname;
				}
			}
		}else{
			foreach($moduleProductToolField as $columnname => $fieldobj){
				$width += $fieldobj->getWidth();
				$order_fields[] = $columnname;
			}
		}
		//3.费用单->如果“费用项目”是“空运订单”，选择“空运订单之后”，在原来根据合同带出已填写字段的基础上，固定显示以下字段：
		//1)空运费：=空运订单第一行分录的“计费重量”*{对用区间价格}
		if($this->declare_module == 'CustomForm15' || $this->declare_module == 'CustomForm16'){
			$order_fields[] = 'sf28899';
		}
		$spec_field = array('sf29035','sf29171','sf29307','sf29443','sf29579');
		foreach($spec_field as $fld){
			if(!empty($this->module_colname_all[$fld])){
				$order_fields[] = $fld;
			}
		}
		
		//$fields=array_diff($cur_fields,$order_fields);
		return array('cur_fields'=>$cur_fields,'fields'=>$order_fields,'width'=>$width);
	}

	//获取满足条件的标体数据
	public function getOrderDetails($i_row){
		global $adb;
		$declare_focus = CRMEntity::getInstance($this->declare_module);
		if($_REQUEST['feiyong_type'] == '应付'){
			//供应商合同编号
			$query = 'select GROUP_CONCAT('.$declare_focus->table_index.') as id from '.$declare_focus->table_name.' where customform04_id = ? and deleted = 0';
		}else{
			//客户合同编号
			$query = 'select GROUP_CONCAT('.$declare_focus->table_index.') as id from '.$declare_focus->table_name.' where potentialid = ? and deleted = 0';	
		}
		$result = $adb->pquery($query,array($this->order_id));
	//	echo $result->sql;echo '<br><br>';
		$declare_record = $adb->query_result($result,0,0);
		$declare_focus = CRMEntity::getInstance($this->declare_module);
		$declare_record_array = explode(',',$declare_record);
		if(!empty($declare_record_array)){
			crm_load_class_file('cls_productDetailsData',"modules/".$this->declare_module."/ProductDetails");
			$ProductDetailsData = new cls_productDetailsData($this->declare_module);
			$deploysystem = $ProductDetailsData->getSystemMethod();
			$ProductDetailFields = $ProductDetailsData->presenceToolField;
			
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
							if($col == 'sf' && ((is_numeric($value) == true && $value <= 0.00 && $value != -1 ) || $value == '')){
								unset($res[$columnname]);
							}else{
								if($value == -1) $value = 0;
								if(!empty($ProductDetailFields[$columnname])){
									$field = $ProductDetailFields[$columnname];
									$uitype = $field->getUIType();
									$typedata = $field->getTypeOfData();
									 $systemPointArr = array('sys_49' => $deploysystem['lengthdecimaldigits'], 'sys_93' => $deploysystem['lengthprice']);
									if ($uitype >= 10 && $uitype <= 50) {
										if ($uitype == 15 || $uitype == 20) {
											if ($columnname != 'usageunit') {
												$numtype = explode(',', $typedata);
												if ($numtype[1] == 0) {
													$value = (int)$value;
												} else {
													//$value = number_format($value, (int)$numtype[1]);
												}
											}
										} elseif ($uitype == 10) {
											//$value = number_format($value, $systemPointArr['sys_49']);
										} else {
											//$value = number_format($value, 2);
										}
									}elseif ($uitype == 163||$uitype==730||$uitype==731||$uitype==810||$uitype==811) {
										//$value = number_format($value, $systemPointArr['sys_93']);
									}
									$res[$columnname] = $value;
								}
							}
						}
					}
					if($this->declare_module == 'CustomForm12'){
						if($this->service_type == '简易报关草单'){
							$data[$i_row] = $res;
							$i_row++;
						}else{
							if($res['sf1427'] == $this->where_colname){
								$data[$i_row] = $res;
								$i_row++;
							}
						}
					}else if($this->declare_module == 'CustomForm11'){
						if($this->service_type == '简易报关草单'){
							$data[$i_row] = $res;
							$i_row++;
						}else{
							if($res['sf1291'] == $this->where_colname){
								$data[$i_row] = $res;
								$i_row++;
							}
						}
					}else if($this->declare_module == 'CustomForm13'){
						$dizhi = $res['sf5099'].$res['sf5235'].$res['sf5371'];
						if(in_array($dizhi,$this->where_colname)){
							$data[$i_row] = $res;
							$i_row++;
						}
					}else if($this->declare_module == 'CustomForm14'){
						if($res['sf8499'] == $this->where_colname){
							$data[$i_row] = $res;
							$i_row++;
						}
					}else if($this->declare_module == 'CustomForm15' || $this->declare_module == 'CustomForm16'){
						if($res['productname'] == $this->where_colname){
							$data[$i_row] = $res;
							$i_row++;
						}
					}
				}
			}
		}
		if(!empty($data)){

			foreach($data as $key => $prd_value){
				foreach($prd_value as $col_name => $val){
					//仓储订单：出入库费= 合同报价单出入库费 * 仓储订单--箱数/板数
					if('CustomForm14' == $this->declare_module){
						if($col_name == 'sf8635'){
							$banshu = $this->getCommissionBanshu($this->order_id);
							$data[$key][$col_name] = $val * $banshu;
						}
					}
					$this->module_colname_all[$col_name] = $col_name;
				}
			}
			if($this->declare_module == 'CustomForm15' || $this->declare_module == 'CustomForm16'){
				foreach($data as $key => $prd_value){
					$data[$key]['sf28899'] = $this->getKongyunzhongliang($prd_value);
					$this->module_colname_all['sf28899'] = 'sf28899';
					//CFS场站费(KG)金额：当CFS场站费(KG)、CFS场站费(KG)（MIN）都显示时就自动显示该字段：如果  CFS场站费(KG)>1 CFS场站费(KG)金额=CFS场站费(KG)*CFS场站费(KG)（MIN）,否则=CFS场站费(KG)（MIN）
					if(!empty($prd_value['sf11627']) && !empty($prd_value['sf28491'])){
						$this->module_colname_all['sf29035'] = 'sf29035';
						if($prd_value['sf11627'] > 1){
							$data[$key]['sf29035'] = $prd_value['sf11627'] * $prd_value['sf28491'];
						}else{
							$data[$key]['sf29035'] = $prd_value['sf28491'];
						}
					}
					//THC过站费(非危险品)（KG）金额：当THC过站费(非危险品)（KG）、THC过站费(非危险品)（MIN） 都显示时就自动显示该字段：如果  THC过站费(非危险品)（KG）>1  THC过站费(危险品)（KG）金额=THC过站费(非危险品)（KG）*THC过站费(非危险品)（MIN）,否则=THC过站费(非危险品)（MIN）
					if(!empty($prd_value['sf13395']) && !empty($prd_value['sf28219'])){
						$this->module_colname_all['sf29171'] = 'sf29171';
						if($prd_value['sf13395'] > 1){
							$data[$key]['sf29171'] = $prd_value['sf13395'] * $prd_value['sf28219'];
						}else{
							$data[$key]['sf29171'] = $prd_value['sf28219'];
						}
					}
					//THC过站费(危险品)（KG）金额：当THC过站费(危险品)（KG）、THC过站费(危险品)（MIN）都显示时就自动显示该字段：如果 THC过站费(危险品)（KG）>1 THC过站费(危险品)（KG）金额=THC过站费(危险品)（KG）*THC过站费(危险品)（MIN），否则=THC过站费(危险品)（MIN）
					if(!empty($prd_value['sf13531']) && !empty($prd_value['sf28355'])){
						$this->module_colname_all['sf29307'] = 'sf29307';
						if($prd_value['sf13531'] > 1){
							$data[$key]['sf29307'] = $prd_value['sf13531'] * $prd_value['sf28355'];
						}else{
							$data[$key]['sf29307'] = $prd_value['sf28355'];
						}
					}
					//主单拆分费（kg）金额：当主单拆分费（kg）、主单拆分费（kg）(MIN)都显示时就自动显示该字段：如果 主单拆分费（kg）>1 主单拆分费（kg）金额=主单拆分费（kg）*主单拆分费（kg）(MIN)，否则=主单拆分费（kg）(MIN)
					if(!empty($prd_value['sf13803']) && !empty($prd_value['sf28627'])){
						$this->module_colname_all['sf29443'] = 'sf29443';
						if($prd_value['sf13803'] > 1){
							$data[$key]['sf29443'] = $prd_value['sf13803'] * $prd_value['sf28627'];
						}else{
							$data[$key]['sf29443'] = $prd_value['sf28627'];
						}
					}
					//5)仓储费（kg）金额：当仓储费（kg/天）、仓储费（MIN）都显示时就自动显示该字段：如果 仓储费（kg/天）>1 仓储费（kg）金额=仓储费（kg/天）*仓储费（MIN），否则=仓储费（MIN）
					if(!empty($prd_value['sf14075']) && !empty($prd_value['sf28763'])){
						$this->module_colname_all['sf29579'] = 'sf29579';
						if($prd_value['sf14075'] > 1){
							$data[$key]['sf29579'] = $prd_value['sf14075'] * $prd_value['sf28763'];
						}else{
							$data[$key]['sf29579'] = $prd_value['sf28763'];
						}
					}
				}
			}
		}
		return $data;
	}
	
	//根据客户合同编号，获取仓储订单对应的箱数板数
	public function getCommissionBanshu($record){
		global $adb;
		$query = "select ld_commission2paymentscf.sf210 from ld_commission 
		LEFT JOIN ld_commission2payment on ld_commission2payment.commission_id = ld_commission.commission_id 
		LEFT JOIN ld_commission2paymentscf on ld_commission2paymentscf.commission2payment_id = ld_commission2payment.commission2payment_id
		where potentialid = $record";
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			return $adb->query_result($result,0,'sf210');
		}else{
			return 0;
		}
	}
	//1)空运费：=空运订单第一行分录的“计费重量”*{对用区间价格}
	public function getKongyunzhongliang($prd_value){
		global $adb;
		$query = 'select sf174 from ld_customform24detail LEFT JOIN ld_customform24detailscf on ld_customform24detailscf.lineitem_id = ld_customform24detail.lineitem_id 
		where id = ? and sequence = 1 limit 1';
		$result = $adb->pquery($query,array($this->record));
		$zhongliang = $adb->query_result($result,0,0);
		if(empty($zhongliang)){
			return 0;
		}else{
			if($zhongliang >= 45 && $zhongliang <=100){
				return $zhongliang*$prd_value['sf10267'];
			}else if($zhongliang >= 100 && $zhongliang <=300){
				return $zhongliang*$prd_value['sf10403'];
			}else if($zhongliang >= 300 && $zhongliang <=500){
				return $zhongliang*$prd_value['sf10539'];
			}else if($zhongliang >= 500 && $zhongliang <=1000){
				return $zhongliang*$prd_value['sf10675'];
			}else{
				return $zhongliang*$prd_value['sf10811'];
			}
		}
	}
	public function setDeclareOrder(){
		global $adb;
		if($this->service_type == '报关订单'){
			/*
			*当“服务项目”选择“报关订单”的时候，根据报关单和费用类型带出分录：
			*a.如果“报关订单”的“报关类型”是“出口”，则根据该报关单的“申报口岸”和“合同编号”，自动带出合同->相关信息->出口报关单据分录中对应“出口口岸”的分录信息
			*b.如果“报关订单”的“报关类型”是“进口”，则根据该报关单的“申报口岸”和“合同编号”，自动带出合同->相关信息->进口报关单据分录中对应“进口口岸”的分录信息
			*/
			$query = 'select declare_type,port_no from ld_customform22 where customform22id = ? and deleted = 0 limit 1';
			$result = $adb->pquery($query,array($this->record));
			$declare_type = $adb->query_result($result,0,0);	//报关类型
			$this->where_colname = $adb->query_result($result,0,1);	//申报口岸
			if($declare_type == '进口'){
				$this->declare_module = 'CustomForm12';	//进口报关单
			}else{
				$this->declare_module = 'CustomForm11';	//出口报关单
			}
		}else if($this->service_type == '简易报关草单'){
			/*
			*当“服务项目”选择“报关订单”的时候，根据报关单和费用类型带出分录：
			*a.如果“报关订单”的“报关类型”是“出口”，则根据该报关单的“申报口岸”和“合同编号”，自动带出合同->相关信息->出口报关单据分录中对应“出口口岸”的分录信息
			*b.如果“报关订单”的“报关类型”是“进口”，则根据该报关单的“申报口岸”和“合同编号”，自动带出合同->相关信息->进口报关单据分录中对应“进口口岸”的分录信息
			*/
			$query = 'select declare_type from ld_customform21 where customform21id = ? and deleted = 0 limit 1';
			$result = $adb->pquery($query,array($this->record));
			$declare_type = $adb->query_result($result,0,0);	//报关类型
			$this->where_colname = $adb->query_result($result,0,1);	//申报口岸
			if($declare_type == '进口'){
				$this->declare_module = 'CustomForm12';	//进口报关单
			}else{
				$this->declare_module = 'CustomForm11';	//出口报关单
			}
		}else if($this->service_type == '运输订单'){
			/*
			*当“服务项目”选择“运输订单”的时候，则根据该运输订单分录的“装货地点”和“送货地点”，以及“合同编号”，自动带出合同->相关信息->运输单据中对应“启运地”和“目的地”的单据分录
			*/
			$query = 'select sf158,sf161,carriage_type from ld_customform23 LEFT JOIN ld_customform23detail on ld_customform23detail.id = ld_customform23.customform23id 
			LEFT JOIN ld_customform23detailscf on ld_customform23detailscf.lineitem_id = ld_customform23detail.lineitem_id
			where ld_customform23.customform23id = ? and deleted = 0';
			$result = $adb->pquery($query,array($this->record));
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				for($i = 0; $i < $num_rows; $i++){
					$sf158 = $adb->query_result($result,$i,'sf158');	//装货地点
					$sf161 = $adb->query_result($result,$i,'sf161');	//送货地点
					$carriage_type = $adb->query_result($result,$i,'carriage_type');	//车型
					$this->where_colname[] = $sf158.$sf161.$carriage_type;
				}
			}
			$this->declare_module = 'CustomForm13';	//运输单
		}else if($this->service_type == '仓储订单'){
			/*
			*当“服务项目”选择“仓储订单”的时候，则根据选定的“合同编号”和“Port”，自动带出合同->相关信息->仓储单据中对应“Port”的单据分录
			*/
			$this->where_colname = $_REQUEST['storage_port'];	//Port
			$this->declare_module = 'CustomForm14';	//仓储
		}else if($this->service_type == '空运订单'){
			/*
			*当“服务项目”选择“空运订单”的时候，并且该空运订单的“启运港”是“中国境内”，则根据该空运订单的“合同编号”，自动带出合同->相关信息->出口空运单据的单据分录
			*当“服务项目”选择“空运订单”的时候，并且该空运订单的“目的港”是“中国境内”，则根据该空运订单的“合同编号”，自动带出合同->相关信息->进口空运单据的单据分录
			*/
			$query = 'select start_port,end_port from ld_customform24 where customform24id = ? and deleted = 0 limit 1';
			$result = $adb->pquery($query,array($this->record));
			$start_port = $adb->query_result($result,0,0);	//启运港
			$end_port = $adb->query_result($result,0,1);	//目的港
			//如果两个都满足，默认：启运港
			if($start_port == '中国境内' && $end_port == '中国境内'){
				$this->declare_module = 'CustomForm15';	//仓储
				$this->where_colname = '出口空运';
			}else{
				if($start_port == '中国境内'){
					$this->declare_module = 'CustomForm15';	//仓储
					$this->where_colname = '出口空运';
				}else{
					if($end_port == '中国境内'){
						$this->declare_module = 'CustomForm16';	//仓储
						$this->where_colname = '进口空运';
					}else{
						$this->declare_module = 'CustomForm15';	//仓储
						$this->where_colname = '出口空运';
					}
				}

				
			}
		}
	}
}


?>