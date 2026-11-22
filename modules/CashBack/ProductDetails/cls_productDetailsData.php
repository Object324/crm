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
	   	$this->getFromModuleProductToolInfo($frommdouleFocus);//关联创建
		$sql=$this->getInventorySql($frommdouleFocus);
		//zkt 20230217 BUG0061762 选择源单-设置 带入分录明细范围 (主表字段)=》关联创建时分录未带出
        //设置主表连接
        $sql .= $this->getOtherSourceModuleMainLeftjoin();
		if($this->focus->id > 0 && empty($frommdouleFocus->lineitemIds)){//单据编辑、详情条件
         $detailtable=$this->focus->Detail_table;
			$sql .= " where $detailtable.id in ( " . $this->focus->id . ')';	
		}elseif(is_string($frommdouleFocus->lineitemIds) && trim($frommdouleFocus->lineitemIds)!=""){	//选择源单条件
            $detailtable=$frommdouleFocus->Detail_table;
			$sql .= " LEFT JOIN(
						select  ifnull(sum(quantity),0) as quantity,productid,parent_lineitem_id from ld_cashbackdetail
						inner join ld_cashback on ld_cashback.cashbackid = ld_cashbackdetail.id
						inner join ld_crmentity on ld_crmentity.crmid = ld_cashback.cashbackid
						where ld_cashback.deleted = 0 GROUP BY ld_cashbackdetail.parent_lineitem_id
					) as cashback on cashback.parent_lineitem_id = $detailtable.lineitem_id";
			$sql .= " where $detailtable.lineitem_id in ( " . $frommdouleFocus->lineitemIds. ')';
		}else{
			return '';
		}
		//设置源单分录明细范围
        $sql .= $this->getOtherSourceModuleSqlWhere();
		$sql .= " order by $detailtable.sequence_no asc ";
		//	echo $sql;echo '<br><br>';
		return $sql;
	}

	//获取明细sql
	public function getInventorySql($frommdouleFocus = ''){
		if($this->focus->id > 0 && empty($frommdouleFocus->lineitemIds)){
			return parent::getInventorySql();
		}
		$isRelatedModuleCreate=$this->isRelatedModuleCreate($frommdouleFocus);
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
				if(($tablename == 'ld_products' || $tablename == 'ld_productcf') && $fieldInfo->getFieldid() > 0 && $fieldInfo->getinput_type() == 1){
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
						$this->sqlfields[$columnname] = " ($detailtable.quantity - IFNULL(cashback.quantity, 0)) as quantity";
					}
                    else if($columnname=='list_amount' && $tablename == $detailtable)
                    {
                        //26836: 已创建销售退款单的销售退货单，再次关联创建销售退款单，带出的产品数量为0，但是金额不为0
                        $this->sqlfields[$columnname] = " ((taxprice/(1+(ifnull(tax1,0)+ifnull(tax2,0)+ifnull(tax3,0))/100))*(1-ifnull(discount_percent,0)/100)*($detailtable.quantity - IFNULL(cashback.quantity, 0))) as list_amount";
                    }
                    else{
						$this->sqlfields[$columnname] = $tablename . '.' . $columnname;
					}
					
				}
			}
			$tableArray[] = $tablename;
		}
        if($this->isRelatedModuleCreate($frommdouleFocus)=='yes'){
            $sql ='select ' . implode(',', $this->sqlfields) .$this->addProductbomColumn($detailtable);
            if(!empty($sqleffectcolumn_arr['detailcolumn']))
            {
               $sql.=','.implode(",",$sqleffectcolumn_arr['detailcolumn']);
            }
            $sql.= " from $detailtable ";
       }else{
            $sql ='select ' . implode(',', $this->sqlfields) .$this->addProductbomColumn($detailtable). " from $detailtable ";
       }
		
		foreach($tableArray as $tablename){
			if($tablename != $this->inventoryTable){
				$leftjoin_table[strtolower($tablename)] = strtolower($tablename);
			}
		}
		//设置源单分录明细范围
		$leftjoin_table = $this->getOtherSourceModuleTables($leftjoin_table);
		if(sizeOf($leftjoin_table) > 0){
			if(in_array('ld_products',$leftjoin_table)){
				$sql .=" left join ld_products on ld_products.productid=$detailtable.productid";
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

	public function getHiddenQuantity($isDuplicate,$productdetail_mode,$productinfo,$frommoduleFocus,$quantity){
		global $adb;
		$hiddenquantity = 0;
		if($isDuplicate == true || $productdetail_mode == 'edit'){
		   $isRelatedModuleCreate=$this->isRelatedModuleCreate($frommoduleFocus);
          if($isRelatedModuleCreate=='yes')
          {
            //选择原单会调用该函数
            $detailtable=$frommoduleFocus->Detail_table;
            $customformmodules=array('CustomForm11','CustomForm12','CustomForm13','CustomForm14','CustomForm15','CustomForm16','CustomForm17','CustomForm18','CustomForm19','CustomForm20');
            if(in_array($frommoduleFocus->moduleName,$customformmodules))
            {
                return $quantity;
            }
          }
          else
		      $detailtable=$this->focus->Detail_table;
			$query = " SELECT
					balanceoutproductcount
				FROM
					$detailtable
				WHERE
					$detailtable.id = ?
				AND $detailtable.productid = ?
				AND $detailtable.lineitem_id = ? ";
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