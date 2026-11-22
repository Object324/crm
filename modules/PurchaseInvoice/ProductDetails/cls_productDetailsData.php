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
	
	public function ____construct($module){
		parent::__construct($module);
	}
	//重写获取明细sql
	public function getProductToolFieldSql($frommdouleFocus){
	 	$customformmodules=array('CustomForm11','CustomForm12','CustomForm13','CustomForm14','CustomForm15','CustomForm16','CustomForm17','CustomForm18','CustomForm19','CustomForm20');
      
       	$isRelatedModuleCreate=$this->isRelatedModuleCreate($frommdouleFocus);
     
		if(($isRelatedModuleCreate=='yes'&&in_array($frommdouleFocus->module_name,$customformmodules))){
		  
			return parent::getProductToolFieldSql($frommdouleFocus);
		}
        $this->getFromModuleProductToolInfo($frommdouleFocus);
		$sql=$this->getInventorySql($frommdouleFocus);
        //zkt 20230217 BUG0061762 选择源单-设置 带入分录明细范围 (主表字段)=》关联创建时分录未带出
        //设置主表连接
        $sql .= $this->getOtherSourceModuleMainLeftjoin();
        
		if($this->focus->id > 0 && empty($frommdouleFocus->lineitemIds)){//单据编辑、详情条件
        $detailtable=$this->focus->Detail_table;
			$sql .= " where $detailtable.id in ( " . $this->focus->id . ')';	
		}elseif(is_string($frommdouleFocus->lineitemIds) && trim($frommdouleFocus->lineitemIds)!=""){
		  	$detailtable=$frommdouleFocus->Detail_table;
        
		  	//25971: 服务合同明细：关联创建销售发票后，再次创建销售发票时，带出的产品数量为1，这里应该为0；
			// if(strtolower($frommdouleFocus->module_name) == 'salesorder'){
				$sql .= "LEFT JOIN(
					select ifnull(sum(quantity),0) as quantity,productid,parent_lineitem_id from ld_purchaseinvoicedetail 
					INNER JOIN ld_purchaseinvoice on ld_purchaseinvoicedetail.id = ld_purchaseinvoice.purchaseinvoiceid 
					where ld_purchaseinvoice.deleted = 0 and ld_purchaseinvoicedetail.entitytype='$frommdouleFocus->module_name'
					GROUP BY
						ld_purchaseinvoicedetail.parent_lineitem_id
				) as invoice on invoice.parent_lineitem_id = $detailtable.lineitem_id";
			//}
			$sql .= " where $detailtable.lineitem_id in ( " . $frommdouleFocus->lineitemIds. ')';

           	// @edit:liushuai,2021-06-05,reason:【ID1001679】带产品分录的表单，选择源单字段->源单类型定制中增加字段属性参数“剩余数量为0时自动带出“
            $sql .= $this->getWhereNotWithBalanceqty($frommdouleFocus);
		}else{
			return '';
		}
		//设置源单分录明细范围
        $sql .= $this->getOtherSourceModuleSqlWhere();
		$sql .= " order by $detailtable.sequence_no asc";
		//echo $sql;echo '<br><br>';
		return $sql;
	}

	//获取明细sql
	public function getInventorySql($frommdouleFocus = ''){
	   //25971: 服务合同明细：关联创建销售发票后，再次创建销售发票时，带出的产品数量为1，这里应该为0；
       $customformmodules=array('CustomForm11','CustomForm12','CustomForm13','CustomForm14','CustomForm15','CustomForm16','CustomForm17','CustomForm18','CustomForm19','CustomForm20');
      
       $isRelatedModuleCreate=$this->isRelatedModuleCreate($frommdouleFocus);
		if($this->focus->id > 0||($isRelatedModuleCreate=='yes'&&in_array($frommdouleFocus->moduleName,$customformmodules))){
			return parent::getInventorySql($frommdouleFocus);
		}
        $sqleffectcolumn_arr['detailcolumn']=[];
        if($isRelatedModuleCreate=='yes')
        {
            crm_load_class_file('cls_RelatedEntryField_Data','include/RelatedField');
			 
   	         $cls_RelatedEntryField_Dataobj = new cls_RelatedEntryField_Data($this->focus->module_name,'entitytypeid');
             $sqleffectcolumn_arr = $cls_RelatedEntryField_Dataobj->getSelectSourceRelateColumns("trigger",$frommdouleFocus->module_name);
             $this->detaileffectcolumn_arr=array_keys($sqleffectcolumn_arr['detailcolumn']);
             $this->maineffectcolumn_arr=$sqleffectcolumn_arr['maincolumn'];
            $this->sqlfields = $this->frominventoryFields;
            $detailtable=$frommdouleFocus->Detail_table;
            $detailtablescf=$frommdouleFocus->Detail_table_scf;
            $tmptablename=$frommdouleFocus->table_name;
           $tmpproductall=$this->fromproductToolAll;;
        }
        else
          {
            $this->sqlfields = $this->inventoryFields;
            $detailtable=$this->focus->Detail_table;
            $detailtablescf=$this->focus->Detail_table_scf;
            $tmptablename=$this->focus->table_name;
            $tmpproductall=$this->productToolAll;
          }
		foreach($tmpproductall as $columnname => $fieldInfo){
            $tablename = $fieldInfo->getTableName();
			if(!empty($tablename) && $tablename != $tmptablename){
				if($tablename == 'ld_products' && $fieldInfo->getFieldid() > 0 && $fieldInfo->getinput_type() == 1){
					$fieldobj=Field::getInstance('Products',$this->db);
					$profieldarr=$fieldobj->FieldInfoListByKeyValue('fieldid',$fieldInfo->getFieldid());
					$columnname=$profieldarr['columnname'];
				}
                //wym 2023-11-07 分录图片字段无论是否保存数据库,都不会在数据表里插入字段,所以不允许查询
                elseif($fieldInfo->getSaveDataBase() == 'no' || $fieldInfo->getUIType() == 69 || $fieldInfo->getUIType() == 1109){
                    continue;
                }
				else{
					$columnname = $fieldInfo->getColumnName();
				}
				$tablename = strtolower($tablename);
				$field[$tablename][] = $columnname;
			}
		}
		foreach($field as $tablename => $columnnameArray){
			foreach($columnnameArray as $columnname){
				if(!empty($columnname)){
					if($columnname == 'quantity' && $tablename == $detailtable){
					   $autobalancevalue='';
					   if($isRelatedModuleCreate=='yes')
                       {
                           $sourcemodule_arr= getSourceModule('PurchaseInvoice');
                           foreach($sourcemodule_arr as $sourceinfo)
                           {
                             if($sourceinfo['entitytype']==$frommdouleFocus->module_name)
                             {
                                 if($sourceinfo['autobalancevalue']=='quantity')
                                 {
                                    $autobalancevalue='quantity';
                                    break;
                                 }
                             }
                           }
                       }
                       if(!empty($autobalancevalue))
						  $this->sqlfields[$columnname] = " ($detailtable.quantity - IFNULL(invoice.quantity, 0)) as quantity";
                        else
                            $this->sqlfields[$columnname]= $tablename . '.' . $columnname;
					}else{
						$this->sqlfields[$columnname] = $tablename . '.' . $columnname;
					}
					
				}
			}
			$tableArray[] = $tablename;
		}
        if($isRelatedModuleCreate=='yes'){
            $sql ='select ' . implode(',', $this->sqlfields) .$this->addProductbomColumn($detailtable). ", ld_products.batchmanagement ,ld_products.havepricestrategy,ld_products.discontinued" ;
            if(!empty($sqleffectcolumn_arr['detailcolumn']))
            {
               $sql.=','.implode(",",$sqleffectcolumn_arr['detailcolumn']);
            }
            $sql.= " from $detailtable ";
       }else{
            $sql ='select ' . implode(',', $this->sqlfields) .$this->addProductbomColumn($detailtable). ", ld_products.batchmanagement ,ld_products.havepricestrategy,ld_products.discontinued from $detailtable ";
       }
		
		foreach($tableArray as $tablename){
			if($tablename != $this->inventoryTable){
				$leftjoin_table[strtolower($tablename)] = strtolower($tablename);
			}
		}
        $leftjoin_table[strtolower('ld_products')]='ld_products';
		//设置源单分录明细范围
		$leftjoin_table = $this->getOtherSourceModuleTables($leftjoin_table);
		if(sizeOf($leftjoin_table) > 0){
          //edit:duan  2022-5-7 如果源单分录中没有产品模块的字段（productname除外），生成sql时无法关联产品表，导致batchmanagement、havepricestrategy两个字段报错
			if(in_array('ld_products',$leftjoin_table)||true){
				$sql .=" left join ld_products on ld_products.productid=$detailtable.productid ";
			}
			if(in_array('ld_productcf',$leftjoin_table)){
				$sql .=' left join ld_productcf on ld_products.productid=ld_productcf.productid ';
			}
			if(in_array($detailtablescf,$leftjoin_table)){
				$sql .=" left join $detailtablescf on $detailtablescf.lineitem_id=$detailtable.lineitem_id ";
			}
		}
      
		return $sql;
    }

	//重写获取明细行自定义字段和属性
	public function getProductToolTrData($frommdouleFocus='',$productdetail_mode = ''){
		global $adb;
		$productToolTr = parent::getProductToolTrData($frommdouleFocus);
		if(!empty($productToolTr)){
			if($productdetail_mode == 'edit' || $productdetail_mode == 'details'){
			 $detailtable=$this->focus->Detail_table;
				$query = " select entitytype from $detailtable where id = ? and entitytype is not NULL limit 1 ";
				$result = $adb->pquery($query,array($frommdouleFocus->id));
                if($adb->num_rows($result)>0)
				    $entitytype = $adb->query_result($result,0,0);
			}else if($productdetail_mode == 'create'){
				$tabid = getTabid($this->module);
				crm_load_class_file('cls_OptionModule','include/OptionModule');
				$cls_OptionModule = cls_OptionModule::getInstance($this->module,'');
				$optionmodule_data = $cls_OptionModule->getData();
				if(!empty($optionmodule_data[$tabid]) && is_array($optionmodule_data[$tabid])){
					$optionmodule = array_keys($optionmodule_data[$tabid]);
				}else{
					$optionmodule = [];
				}
				if(!empty($optionmodule[0])){
					$entitytype = getTabModuleName($optionmodule[0]);
				}
			}else{
				$entitytype = $frommdouleFocus->module;
			}
			/*foreach($productToolTr as $key => $producttoolinfo){
				if((strtolower($entitytype) == 'purchaseorder' || $_REQUEST['contract_display'] == 'none') && $producttoolinfo->getUIType() == 205){
					unset($productToolTr[$key]);//删除合同信息列
				}
			}*/
			$productToolTr = array_values($productToolTr);
		}
		return $productToolTr;
	}

	public function getHiddenQuantity($isDuplicate,$productdetail_mode,$productinfo,$frommoduleFocus,$quantity){
		global $adb;
		$hiddenquantity = 0;
		if($isDuplicate == true || $productdetail_mode == 'edit'){
		   $isRelatedModuleCreate=$this->isRelatedModuleCreate($frommoduleFocus);
          
          if($isRelatedModuleCreate=='yes')
          {
            //选择原单会调用该函数
           
            $customformmodules=array('CustomForm11','CustomForm12','CustomForm13','CustomForm14','CustomForm15','CustomForm16','CustomForm17','CustomForm18','CustomForm19','CustomForm20');
            if(in_array($frommoduleFocus->moduleName,$customformmodules))
            {
                return $quantity;
            }
            $detailtable=$frommoduleFocus->Detail_table;
          }
          else
		      $detailtable=$this->focus->Detail_table;
			$query = " SELECT
					quantity
				FROM
					$detailtable
				WHERE
					$detailtable.id = ?
				AND $detailtable.productid = ?
				AND $detailtable.lineitem_id = ?";
			$result = $adb->pquery($query,array($productinfo['entitytypeid'],$productinfo['productid'],$productinfo['parent_lineitem_id']));
			$num_rows = $adb->num_rows($result);
           
			if($num_rows >= 1){
				$hiddenquantity = $adb->query_result($result,0,0);
			}
		}
		if($productdetail_mode == 'edit' && $isDuplicate != 'true'){
			$hiddenquantity += $productinfo['column_value'];
		}
          
		return $hiddenquantity;
	}
}
?>