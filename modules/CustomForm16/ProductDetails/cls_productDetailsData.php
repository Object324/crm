<?php
/**
* 产品明细HTML
* 修改编码格式:统一编码：UTF-8
* @author Chj
*/
/**
* 修改编码格式:统一编码：UTF-8
* @author Chj
*/
crm_load_class_file('Parent_ProductDetailsData','include/ProductDetailsHtml');
class cls_productDetailsData extends Parent_ProductDetailsData{
	
	public function __construct($module){
		parent::__construct($module);
	}
	public function getProductToolFieldValue($frommdouleFocus,$productdetail_mode) {
		$version_info = getVersionInfo();
		//浩辰特殊开发  chj  20220530 合同申请单列表操作列增加关联创建合同拆分按钮
		if($version_info['account'] == 'haochen' && $productdetail_mode == 'sourcemodule_create'){
			global $adb;
			//合同生成
			$query = "select source_list from ld_quotesdetail 
			LEFT JOIN ld_quotes on ld_quotes.quoteid = ld_quotesdetail.id 
			where lineitem_id = ?";
			$result = $adb->pquery($query,array($frommdouleFocus->lineitemIds));
			
			if($adb->num_rows($result) >= 1){
				$customform14_id = $adb->query_result($result,0,0);
				//判断是否有升级约定
				$query = "select GROUP_CONCAT(customform15id) from ld_customform15 where source_list = ? and deleted = 0";
				$result = $adb->pquery($query,array($customform14_id));
				$customform15id = $adb->query_result($result,0,0);
				//有升级约定
				$shengji_shuilv = $this->getTaxValue_For_haochen();
				if(!empty($customform15id)){
						$query = "
						select lineitem_id,productid,sequence_no,entitytype,parent_lineitem_id,entitytypeid,havepurchasecount,balancepurchasecount,haveoutproductcount,balanceoutproductcount,contractid,batchmanagement,havepricestrategy,productname,
						quantity,taxprice,tax_new,tax_amount,COMMENT,listprice,list_amount,tax_total,productcost,prounitprice,productbomid,productbomquantity,cf_4609,sf4240,sf3400,sf3610,sf3820,sf4030,cf_4612,cf_4613,cf_4614 from (
							SELECT
								ld_customform14detail.lineitem_id,
								ld_customform14detail.productid,
								ld_customform14detail.sequence_no,
								ld_customform14detail.entitytype,
								ld_customform14detail.parent_lineitem_id,
								ld_customform14detail.entitytypeid,
								ld_customform14detail.havepurchasecount,
								ld_customform14detail.balancepurchasecount,
								ld_customform14detail.haveoutproductcount,
								ld_customform14detail.balanceoutproductcount,
								ld_customform14detail.contractid,
								ld_products.batchmanagement,
								ld_products.havepricestrategy,
								ld_products.productname,
								ld_customform14detail.quantity,
								ld_customform14detail.taxprice,
								ld_customform14detail.tax_new,
								ld_customform14detail.tax_amount,
								ld_customform14detail. COMMENT,
								ld_customform14detail.listprice,
								ld_customform14detail.list_amount,
								ld_customform14detail.tax_total,
								ld_products.costprice AS productcost,
								ld_products.unit_price AS prounitprice,
								ld_customform14detail.productbomid,
								ld_customform14detail.productbomquantity,
								cf_4609,
								sf4240,
								sf3400,sf3610,sf3820,sf4030,
								ld_productcf.cf_4612,
								ld_productcf.cf_4613,
								ld_productcf.cf_4614
								
							FROM
								ld_customform14detail 
							LEFT JOIN ld_customform14detailscf on ld_customform14detail.lineitem_id = ld_customform14detailscf.lineitem_id 
							LEFT JOIN ld_products ON ld_products.productid = ld_customform14detail.productid 
							LEFT JOIN ld_productcf on ld_products.productid = ld_productcf.productid 
							WHERE
								ld_customform14detail.id = $customform14_id 
							UNION ALL 
							SELECT
								ld_customform15detail.lineitem_id,
								ld_customform15detail.productid,
								ld_customform15detail.sequence_no,
								ld_customform15detail.entitytype,
								ld_customform15detail.parent_lineitem_id,
								ld_customform15detail.entitytypeid,
								ld_customform15detail.havepurchasecount,
								ld_customform15detail.balancepurchasecount,
								ld_customform15detail.haveoutproductcount,
								ld_customform15detail.balanceoutproductcount,
								ld_customform15detail.contractid,
								ld_products.batchmanagement,
								ld_products.havepricestrategy,
								ld_products.productname,
								ld_customform15detail.quantity,
								ld_customform15detail.taxprice,
								ld_customform15detail.tax_new,
								ld_customform15detail.tax_amount,
								ld_customform15detail. COMMENT,
								ld_customform15detail.listprice,
								ld_customform15detail.list_amount,
								ld_customform15detail.tax_total,
								ld_products.costprice AS productcost,
								ld_products.unit_price AS prounitprice,
								ld_customform15detail.productbomid,
								ld_customform15detail.productbomquantity,
								'升级约定' as cf_4609,
								sf4240,
								'升级' as sf3400,sf3610,sf3820,sf4030,
								ld_productcf.cf_4612,
								ld_productcf.cf_4613,
								ld_productcf.cf_4614
							FROM
								ld_customform15detail 
							LEFT JOIN ld_customform15detailscf on ld_customform15detail.lineitem_id = ld_customform15detailscf.lineitem_id 
							LEFT JOIN ld_products ON ld_products.productid = ld_customform15detail.productid 
							LEFT JOIN ld_productcf on ld_products.productid = ld_productcf.productid 
							WHERE
								ld_customform15detail.id in ($customform15id)
						) as temp ";
						//echo $query;echo '<br><br>';
						$result = $adb->pquery($query,array());
						if($adb->num_rows($result) >= 1){
							$num_rows = $adb->num_rows($result);
							if($num_rows >= 1){
								$discount_all = $this->getEntryPrice_For_haochen($result);
								for($i = 0; $i < $num_rows; $i++){
									$cf_4609 = $adb->query_result($result,$i,'cf_4609');	//系统分类
									$sf3400 = $adb->query_result($result,$i,'sf3400');	//许可性质
									$quantity = $adb->query_result($result,$i,'quantity');
									$sf4240 = $adb->query_result($result,$i,'sf4240');	//免费升级次数
									$tax_new = $adb->query_result($result,$i,'tax_new');	//税率
									if(!empty($sf4240)){
										$tax_new = $shengji_shuilv;
									}
									$sf3610 = $adb->query_result($result,$i,'sf3610');	//授权方式	
									$sf4939 = '';	//场地授权有无数量限制	
									$sf5152 = '';	//场地授权限制数量（最大量）
									if($sf3610 == '场地授权'){
										$sf4939 = '有';
										$sf5152 = sprintf('%.2f', $quantity);
									}
									$list_amount = $adb->query_result($result,$i,'list_amount');
									$tax_total = $adb->query_result($result,$i,'tax_total');
									$tax_amount = $adb->query_result($result,$i,'tax_amount');
									if($list_amount + $tax_total < $tax_amount){
										$list_amount = $list_amount + ($tax_amount - $list_amount - $tax_total);
									}

									$columnname_value[$i] = array(
										'lineitem_id' => $adb->query_result($result,$i,'lineitem_id'),	
										'productid' => $adb->query_result($result,$i,'productid'),	
										'sequence_no' => $i + 1,	
										'entitytype' => $adb->query_result($result,$i,'entitytype'),	
										'parent_lineitem_id' => $adb->query_result($result,$i,'parent_lineitem_id'),	
										'entitytypeid' => $adb->query_result($result,$i,'entitytypeid'),	
										'havepurchasecount' => $adb->query_result($result,$i,'havepurchasecount'),	
										'balancepurchasecount' => $adb->query_result($result,$i,'balancepurchasecount'),	
										'haveoutproductcount' => $adb->query_result($result,$i,'haveoutproductcount'),	
										'balanceoutproductcount' => $adb->query_result($result,$i,'balanceoutproductcount'),	
										'contractid' => $adb->query_result($result,$i,'contractid'),	
										'batchmanagement' => $adb->query_result($result,$i,'batchmanagement'),	
										'havepricestrategy' => $adb->query_result($result,$i,'havepricestrategy'),	
										'productname' => $adb->query_result($result,$i,'productname'),	
										'quantity' => $quantity,	
										'taxprice' => $adb->query_result($result,$i,'taxprice'),	
										'tax_new' => $tax_new,	
										'tax_amount' => $tax_amount,	
										'comment' => $adb->query_result($result,$i,'comment'),	
										'listprice' => $adb->query_result($result,$i,'listprice'),	
										'list_amount' => $list_amount,	
										'tax_total' => $tax_total,	
										'productcost' => $adb->query_result($result,$i,'productcost'),	
										'prounitprice' => $adb->query_result($result,$i,'prounitprice'),	
										'productbomid' => $adb->query_result($result,$i,'productbomid'),	
										'productbomquantity' => $adb->query_result($result,$i,'productbomquantity'),
										'cf_4609' => $adb->query_result($result,$i,'cf_4609'),
										'sf4240' => $sf4240,
										'sf3400' => $sf3400,
										'sf3610' => $sf3610,
										'sf3820' => $adb->query_result($result,$i,'sf3820'),
										'sf4030' => $adb->query_result($result,$i,'sf4030'),
										'sf4450' => $discount_all['discount_price'][$i],
										'sf4660' => $discount_all['discount_amount'][$i],
										'sf4939' => $sf4939,
										'sf5152' => $sf5152,
									);
								}
							}
						}
						
				}else{
					
					$query = "
						SELECT
								ld_customform14detail.lineitem_id,
								ld_customform14detail.productid,
								ld_customform14detail.sequence_no,
								ld_customform14detail.entitytype,
								ld_customform14detail.parent_lineitem_id,
								ld_customform14detail.entitytypeid,
								ld_customform14detail.havepurchasecount,
								ld_customform14detail.balancepurchasecount,
								ld_customform14detail.haveoutproductcount,
								ld_customform14detail.balanceoutproductcount,
								ld_customform14detail.contractid,
								ld_products.batchmanagement,
								ld_products.havepricestrategy,
								ld_products.productname,
								ld_customform14detail.quantity,
								ld_customform14detail.taxprice,
								ld_customform14detail.tax_new,
								ld_customform14detail.tax_amount,
								ld_customform14detail. COMMENT,
								ld_customform14detail.listprice,
								ld_customform14detail.list_amount,
								ld_customform14detail.tax_total,
								ld_products.costprice AS productcost,
								ld_products.unit_price AS prounitprice,
								ld_customform14detail.productbomid,
								ld_customform14detail.productbomquantity,
								cf_4609,
								sf4240,
								sf3400,sf3610,sf3820,sf4030,
								ld_productcf.cf_4612,
								ld_productcf.cf_4613,
								ld_productcf.cf_4614
							FROM
								ld_customform14detail 
							LEFT JOIN ld_customform14detailscf on ld_customform14detail.lineitem_id = ld_customform14detailscf.lineitem_id 
							LEFT JOIN ld_products ON ld_products.productid = ld_customform14detail.productid 
							LEFT JOIN ld_productcf on ld_products.productid = ld_productcf.productid 
							WHERE
								ld_customform14detail.id = $customform14_id 
							ORDER BY
								ld_customform14detail.id,
								ld_customform14detail.sequence_no ASC";
						$result = $adb->pquery($query,array());
						if($adb->num_rows($result) >= 1){
							$num_rows = $adb->num_rows($result);
							$tax_amount_type = 0;
							for($i = 0; $i < $num_rows; $i++){
								$tax_amount = $adb->query_result($result,$i,'tax_amount');
								if($tax_amount <= 0.0){
									$tax_amount_type = 1;
								}
							}
							if($tax_amount_type == 1){
								$discount_all = $this->getEntryPrice_For_haochen($result);
							}
							/*echo '<pre>';
							print_r($discount_all);
							echo '</pre>';
							die;*/
							if($num_rows >= 1){
								for($i = 0; $i < $num_rows; $i++){
									$list_amount = $adb->query_result($result,$i,'list_amount');
									$tax_total = $adb->query_result($result,$i,'tax_total');
									$tax_amount = $adb->query_result($result,$i,'tax_amount');
									if($list_amount + $tax_total < $tax_amount){
										$list_amount = $list_amount + ($tax_amount - $list_amount - $tax_total);
									}
									if($tax_amount_type == 1){
										$sf4450 = $discount_all['discount_price'][$i];	//拆分后单价（不含税）人民币
										$sf4660 = $discount_all['discount_amount'][$i];	//拆分后金额（不含税）人民币
									}else{
										$sf4450 = $adb->query_result($result,$i,'listprice');	
										$sf4660 = $list_amount;	
									}
									$quantity =  $adb->query_result($result,$i,'quantity');
									$sf3610 = $adb->query_result($result,$i,'sf3610');	//授权方式	
									$sf4939 = '';	//场地授权有无数量限制	
									$sf5152 = '';	//场地授权限制数量（最大量）
									if($sf3610 == '场地授权'){
										$sf4939 = '有';
										$sf5152 = sprintf('%.2f', $quantity);
									}
									$columnname_value[$i] = array(
										'lineitem_id' => $adb->query_result($result,$i,'lineitem_id'),	
										'productid' => $adb->query_result($result,$i,'productid'),	
										'sequence_no' => $i + 1,	
										'entitytype' => $adb->query_result($result,$i,'entitytype'),	
										'parent_lineitem_id' => $adb->query_result($result,$i,'parent_lineitem_id'),	
										'entitytypeid' => $adb->query_result($result,$i,'entitytypeid'),	
										'havepurchasecount' => $adb->query_result($result,$i,'havepurchasecount'),	
										'balancepurchasecount' => $adb->query_result($result,$i,'balancepurchasecount'),	
										'haveoutproductcount' => $adb->query_result($result,$i,'haveoutproductcount'),	
										'balanceoutproductcount' => $adb->query_result($result,$i,'balanceoutproductcount'),	
										'contractid' => $adb->query_result($result,$i,'contractid'),	
										'batchmanagement' => $adb->query_result($result,$i,'batchmanagement'),	
										'havepricestrategy' => $adb->query_result($result,$i,'havepricestrategy'),	
										'productname' => $adb->query_result($result,$i,'productname'),	
										'quantity' => $quantity,
										'taxprice' => $adb->query_result($result,$i,'taxprice'),	
										'tax_new' => $adb->query_result($result,$i,'tax_new'),	
										'tax_amount' => $tax_amount,	
										'comment' => $adb->query_result($result,$i,'comment'),	
										'listprice' => $adb->query_result($result,$i,'listprice'),	
										'list_amount' => $list_amount,	
										'tax_total' => $tax_total,	
										'productcost' => $adb->query_result($result,$i,'productcost'),	
										'prounitprice' => $adb->query_result($result,$i,'prounitprice'),	
										'productbomid' => $adb->query_result($result,$i,'productbomid'),	
										'productbomquantity' => $adb->query_result($result,$i,'productbomquantity'),
										'cf_4609' => $adb->query_result($result,$i,'cf_4609'),
										'sf4240' => $adb->query_result($result,$i,'sf4240'),
										'sf3400' => $adb->query_result($result,$i,'sf3400'),
										'sf3610' => $adb->query_result($result,$i,'sf3610'),
										'sf3820' => $adb->query_result($result,$i,'sf3820'),
										'sf4030' => $adb->query_result($result,$i,'sf4030'),
										'sf4450' => $sf4450,
										'sf4660' => $sf4660,
										'sf4939' => $sf4939,
										'sf5152' => $sf5152,
									);
								}
							}
						}
				}
				$this->columnname_value = $columnname_value;
				return $columnname_value;
			}
								
		}else{
			return parent::getProductToolFieldValue($frommdouleFocus,$productdetail_mode);
		}
	}

	//浩辰特殊开发    升级约定拆分的税率，从税率模块中获取
	public function getTaxValue_For_haochen(){
		global $adb;
		$query = "select cf_4615 from ld_customform02scf LEFT JOIN ld_customform02 on ld_customform02.customform02id = ld_customform02scf.customform02id where cf_4616 = '自有产品' and cf_4617 = '升级' and deleted = 0 limit 1";
		$result = $adb->pquery($query,array());
		if($adb->num_rows($result) >= 1){
			return $adb->query_result($result,0,'cf_4615');
		}
		return 0;
	}
	//浩辰特殊开发    拆分价格重算
	public function getEntryPrice_For_haochen($result){
		global $adb;
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			$all_total = 0;	//总金额
			$all_list_amount = 0;	//总的不含税金额
			for($i = 0; $i < $num_rows; $i++){
				$cf_4609 = $adb->query_result($result,$i,'cf_4609');	//系统分类
				$sf3400 = $adb->query_result($result,$i,'sf3400');	//许可性质
				$quantity = $adb->query_result($result,$i,'quantity');
				$list_amount = $adb->query_result($result,$i,'list_amount');
				$sf4240 = $adb->query_result($result,$i,'sf4240');	//免费升级次数
				//$price 参考报价
				if($cf_4609 == '产品' || $cf_4609 == '升级约定'){
					if($sf3400 == '新购' || $sf3400 == '其他'){
						$price = $adb->query_result($result,$i,'cf_4612');
					}else if($sf3400 == '升级'){
						$price = $adb->query_result($result,$i,'cf_4613');
					}else if($sf3400 == '租赁' || $sf3400 == '订阅'){
						$price = $adb->query_result($result,$i,'cf_4614');
					}
				}else if($cf_4609 == '技术服务'){
					$price = $adb->query_result($result,$i,'cf_4612');
				}
				if(!empty($sf4240))
					$all_total += $price*$quantity*$sf4240;
				else
					$all_total += $price*$quantity;
				$all_list_amount += $list_amount;
				
			}
			//拆分后单价（不含税）人民币
			$discount_price = [];
			//拆分后金额（不含税）人民币
			$discount_amount = [];
			for($i = 0; $i < $num_rows; $i++){
				$cf_4609 = $adb->query_result($result,$i,'cf_4609');	//系统分类
				$sf3400 = $adb->query_result($result,$i,'sf3400');	//许可性质
				$quantity = $adb->query_result($result,$i,'quantity');
				$sf4240 = $adb->query_result($result,$i,'sf4240');	//免费升级次数
				if($cf_4609 == '产品' || $cf_4609 == '升级约定'){
					if($sf3400 == '新购' || $sf3400 == '其他'){
						$price = $adb->query_result($result,$i,'cf_4612');
					}else if($sf3400 == '升级'){
						$price = $adb->query_result($result,$i,'cf_4613');
					}else if($sf3400 == '租赁' || $sf3400 == '订阅'){
						$price = $adb->query_result($result,$i,'cf_4614');
					}
				}else if($cf_4609 == '技术服务'){
					$price = $adb->query_result($result,$i,'cf_4612');
				}
				if(!empty($sf4240))
					$temp_discount_amount = $price*$quantity*$sf4240/$all_total*$all_list_amount;
				else
					$temp_discount_amount = $price*$quantity/$all_total*$all_list_amount;
				
				$discount_price[$i] =  sprintf('%.2f', $temp_discount_amount/$quantity);
				$discount_amount[$i] =  sprintf('%.2f', $temp_discount_amount);
				$all_dis_amouint += sprintf('%.2f', $temp_discount_amount);
			}
			if($all_list_amount != $all_dis_amouint){
				$max_discount_amount_key = array_keys($discount_amount,max($discount_amount))[0];
				$discount_amount[$max_discount_amount_key] = $discount_amount[$max_discount_amount_key] + $all_list_amount - $all_dis_amouint;
			}
			/*$all_amount = 0; //单据 总的参考总价
			$total = 0; //单据合计
			for($i = 0; $i < $num_rows; $i++){
				$cf_4609 = $adb->query_result($result,$i,'cf_4609');	//系统分类
				$sf3400 = $adb->query_result($result,$i,'sf3400');	//许可性质
				$quantity = $adb->query_result($result,$i,'quantity');
				$sf4240 = $adb->query_result($result,$i,'sf4240');	//免费升级次数
				$list_amount = $adb->query_result($result,$i,'list_amount');
				$tax_new = $adb->query_result($result,$i,'tax_new');	//税率
				//$price 参考报价
				if($cf_4609 == '产品' || $cf_4609 == '升级约定'){
					if($sf3400 == '新购' || $sf3400 == '其他'){
						$price = $adb->query_result($result,$i,'cf_4612');
					}else if($sf3400 == '升级'){
						$price = $adb->query_result($result,$i,'cf_4613');
					}else if($sf3400 == '租赁' || $sf3400 == '订阅'){
						$price = $adb->query_result($result,$i,'cf_4614');
					}
				}else if($cf_4609 == '技术服务'){
					$price = $adb->query_result($result,$i,'cf_4612');
				}
				echo $price;echo '<br><br>';
				//amount 参考总价
				if($cf_4609 == '升级约定'){
					$quantity = $quantity*$sf4240;
				}
				$tax_new = 1 + $tax_new/100;
				$amount = $price * $quantity/$tax_new;
				$pro_price[$i] = $price;
				$pro_tax_new[$i] = $tax_new;
				$pro_quantity[$i] = $quantity;
				$all_amount += $amount;
				$total += $list_amount;
				//echo 'price='.$price.'<br>';
				//echo 'amount='.$amount.'<br>';
			}
			//拆分后单价（不含税）人民币
			$discount_price = [];
			//拆分后金额（不含税）人民币
			$discount_amount = [];
			//echo 'all_amount='.$all_amount.'<br>';
			foreach($pro_price as $key => $price){
				//z*c/(1+(y)/100)
				$dis_price = $price/$all_amount*$total/$pro_tax_new[$key];
				//echo 'dis_price='.$dis_price.'<br>';
				$discount_price[$key] = $dis_price;
				$dis_amount = sprintf('%.2f', $dis_price*$pro_quantity[$key]);
				$all_dis_amouint += $dis_amount;
				$discount_amount[$key] = $dis_amount;
			}*/
			/*echo '<pre>';
			print_r($discount_amount);
			echo '</pre>';
			echo 'total='.$total.'<br>';
			echo $all_dis_amouint;*/
			//3、误差处理    拆分后，用各项的拆分总价（不含税）之和减合同总额（不含税）得到误差，将这个误差加到拆分总价（不含税）最大一项中
			/*if($total != $all_dis_amouint){
				$max_discount_amount_key = array_keys($discount_amount,max($discount_amount))[0];
				$discount_amount[$max_discount_amount_key] = $discount_amount[$max_discount_amount_key] + $total - $all_dis_amouint;
			}*/
		}
		return array('discount_price'=>$discount_price,'discount_amount'=>$discount_amount);
	}
}
?>