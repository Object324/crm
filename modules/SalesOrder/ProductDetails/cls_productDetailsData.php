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
            else if($frommoduleFocus->module_name=='Quotes')
              {
                    $detailtable=$frommoduleFocus->Detail_table;
            			$query = " SELECT
            					balanceordercount
            				FROM
            					$detailtable
            				WHERE
            					$detailtable.id = ?
            				AND $detailtable.productid = ?
            				AND $detailtable.lineitem_id = ? ";
              }
              else{//教育行业
                 $detailtable=$this->focus->Detail_table;
        			$query = " SELECT
        					quantity
        				FROM
        					$detailtable
        				WHERE
        					$detailtable.id = ?
        				AND $detailtable.productid = ?
        				AND $detailtable.lineitem_id = ? ";
             }
          }
          
          else
             {
                 $detailtable=$this->focus->Detail_table;
        			$query = " SELECT
        					quantity
        				FROM
        					$detailtable
        				WHERE
        					$detailtable.id = ?
        				AND $detailtable.productid = ?
        				AND $detailtable.lineitem_id = ? ";
             }
            
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
    //获取明细sql
	public function getInventorySql($frommdouleFocus = ''){
	  
		if($this->focus->id > 0){
			return parent::getInventorySql($frommdouleFocus);
		}
        $this->getFromModuleProductToolInfo($frommdouleFocus);//获取关联创建模块的产品明细字段
        $isRelatedModuleCreate=$this->isRelatedModuleCreate($frommdouleFocus);
        $sqleffectcolumn_arr['detailcolumn']=[];
        if($isRelatedModuleCreate=='yes')
		{
            crm_load_class_file('cls_RelatedEntryField_Data','include/RelatedField');
			 
			$cls_RelatedEntryField_Dataobj = new cls_RelatedEntryField_Data($this->focus->module_name,'entitytypeid');
			$sqleffectcolumn_arr = $cls_RelatedEntryField_Dataobj->getSelectSourceRelateColumns("trigger",$frommdouleFocus->module_name);
			if (is_array($sqleffectcolumn_arr['detailcolumn'])) {
				$this->detaileffectcolumn_arr = array_keys($sqleffectcolumn_arr['detailcolumn']);
			}
			$this->maineffectcolumn_arr=$sqleffectcolumn_arr['maincolumn'];
            $detailtablescf=$frommdouleFocus->Detail_table_scf;
            $detailtable=$frommdouleFocus->Detail_table;
            $this->sqlfields = $this->frominventoryFields;
           
            $tmproductall=$this->fromproductToolAll;
            $tmp_tablename=$frommdouleFocus->table_name;
		}
        else
		{
            $detailtablescf=$this->focus->Detail_table_scf;
            $detailtable=$this->focus->Detail_table;
            $this->sqlfields = $this->inventoryFields;
            $tmproductall=$this->productToolAll;
            $tmp_tablename=$this->focus->table_name;
		}
		
		foreach($tmproductall as $columnname => $fieldInfo){
		  $tablename = $fieldInfo->getTableName();
			if(!empty($tablename) && $tablename != $tmp_tablename){
				if(($fieldInfo->getTableName() == 'ld_products' || $fieldInfo->getTableName() == 'ld_productcf' )&& $fieldInfo->getFieldid() > 0 && $fieldInfo->getinput_type() == 1){
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
        
		//chj 2021/6/28 深圳灵当-报价单-详情-关联创建的合同订单模块-新建-选择源单报价单-产品分录里不自带数量及价格信息 
		$tableArray = [];
        foreach($this->sqlfields as $tmpcolumnname=>$column_tablename){
            $column_tablenames=explode('.',$column_tablename);
            if(sizeof($column_tablenames)==2&&!in_array($column_tablenames[0],$tableArray)){
                $tableArray[] = $column_tablenames[0];
            }
        }

		foreach($field as $tablename => $columnnameArray){
			foreach($columnnameArray as $columnname){
				if(!empty($columnname)){
					if($frommdouleFocus->module_name=='Quotes'&&$columnname == 'quantity' && $isRelatedModuleCreate=='yes' && $tablename == $frommdouleFocus->Detail_table){
						//chj 2021/6/4 合同订单选择报价单，产品数量带出错误，没有根据页面设置-源单设置：  自动带出源单剩余
						$autobalancevalue = '';
						foreach($this->sourcemodule_arr as $sourcemoduleinfo)
						{
							if($frommdouleFocus->module_name==$sourcemoduleinfo['entitytype'])
							{
								if($columnname==$sourcemoduleinfo['autobalancevalue'])
									$autobalancevalue=$sourcemoduleinfo['autobalancevalue'];
								break;
							}
						}
						if($autobalancevalue != ''){
						  //zkt 20230803 BUG0070415  kfbcrm-报价单下推生成销售订单时，分录中数量字段没有根据报价单中的数量带出
							$this->sqlfields[$columnname] = " (ifnull($detailtable.balanceordercount,$detailtable.quantity)) as quantity ";
                        }
						else
							$this->sqlfields[$columnname] = $tablename . '.' . $columnname;
					}else{
						$this->sqlfields[$columnname] = $tablename . '.' . $columnname;
					}
					
				}
			}
			$tableArray[] = $tablename;
		}

		if($isRelatedModuleCreate=='yes'){
            $sql ='select ' . implode(',', $this->sqlfields) .$this->addProductbomColumn($detailtable) ;
            if(!empty($sqleffectcolumn_arr['detailcolumn']))
            {
               $sql.=','.implode(",",$sqleffectcolumn_arr['detailcolumn']);
            }
            $sql.= " from $detailtable ";
       }else{
            $sql ='select ' . implode(',', $this->sqlfields) .$this->addProductbomColumn($detailtable) . " from $detailtable ";
       }
		foreach($tableArray as $tablename){
			if($tablename != $detailtable){
				$leftjoin_table[strtolower($tablename)] = strtolower($tablename);
			}
		}
		//设置源单分录明细范围
		$leftjoin_table = $this->getOtherSourceModuleTables($leftjoin_table);
		
		if(sizeOf($leftjoin_table) > 0){
			if(in_array('ld_products',$leftjoin_table)){
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
}
?>