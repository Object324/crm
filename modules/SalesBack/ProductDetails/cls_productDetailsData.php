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
            $deploy_values= getSys_deploy(48);//出库单或入库单更新库存流水记录触发点 0：审核  1：保存
            if($deploy_values['deploy_value']==0)
            {
                $outboundwhere=" and    ld_outboundorder.approvestatus='".D_A_S_APPROVED."' ";
            }
            
            if($frommdouleFocus->module_name=='OutboundOrder')
            {
                $sql.=" left join 
                    (select (outquantity-ifnull(backquantity,0)) as outquantity,tmp_outquantity.wareid,tmp_outquantity.productid
                    ,ifnull(tmp_outquantity.batchtext,'')  as batchtext
                    from (select  sum(quantity) as outquantity,ld_outboundorderdetail.wareid,ld_products.productid,ifnull(batchtext,'') as batchtext
                     from ld_outboundorderdetail INNER JOIN
                    ld_outboundorder on ld_outboundorder.out_id=ld_outboundorderdetail.id
                    inner join ld_products on ld_products.productid =ld_outboundorderdetail.productid
                  
                    where ld_outboundorder.deleted=0 
                     and $detailtable.lineitem_id in 
                            (" . $frommdouleFocus->lineitemIds. " )
                     $outboundwhere
                    group by ld_outboundorderdetail.wareid, ld_products.productid
                    ,case when ld_products.batchmanagement=1 then ifnull(batchtext,'') 
                    						else '' END ) as tmp_outquantity
                    left JOIN (
                    
                    select sum(quantity) as backquantity,ld_salesback.wareid,ld_products.productid,ifnull(batchtext,'') as batchtext from ld_salesback
                    INNER JOIN ld_salesbackdetail on 
                    ld_salesback.salesbackid=ld_salesbackdetail.id
                    inner join ld_products on ld_products.productid =ld_salesbackdetail.productid
                     where ld_salesbackdetail.parent_lineitem_id in (" . $frommdouleFocus->lineitemIds. " )
                    and  ld_salesback.salesbackstatus not in ('中止', '未入库','结束')
                    group by ld_salesback.wareid, ld_products.productid,case when ld_products.batchmanagement=1 then ifnull(batchtext,'') 
                    						else '' END ) as tmp_backquantity
                    on tmp_backquantity.wareid=tmp_outquantity.wareid and tmp_backquantity.productid=tmp_outquantity.productid
                    and tmp_backquantity.batchtext=tmp_outquantity.batchtext)  as tmpoutquantity_table 
                    on tmpoutquantity_table.productid=$detailtable.productid ";
            }
            else
            {
                $sql.=" left join 
                    (select (outquantity-ifnull(backquantity,0)) as outquantity,tmp_outquantity.wareid,tmp_outquantity.productid
                    ,ifnull(tmp_outquantity.batchtext,'')  as batchtext
                    from (select  sum(quantity) as outquantity,ld_outboundorderdetail.wareid,ld_products.productid,ifnull(batchtext,'') as batchtext
                     from ld_outboundorderdetail INNER JOIN
                    ld_outboundorder on ld_outboundorder.out_id=ld_outboundorderdetail.id
                    inner join ld_products on ld_products.productid =ld_outboundorderdetail.productid
                    inner join (SELECT 	productid,id FROM $detailtable where $detailtable.lineitem_id in 
                            (" . $frommdouleFocus->lineitemIds. " ))
                     as tmpsourcemoduleproducts_table on tmpsourcemoduleproducts_table.productid=ld_products.productid 
                     and ld_outboundorderdetail.entitytypeid=tmpsourcemoduleproducts_table.id
                    where ld_outboundorder.deleted=0 
                     $outboundwhere
                    group by ld_outboundorderdetail.wareid, ld_products.productid
                    ,case when ld_products.batchmanagement=1 then ifnull(batchtext,'') 
                    						else '' END ) as tmp_outquantity
                    left JOIN (
                    
                    select sum(quantity) as backquantity,ld_salesback.wareid,ld_products.productid,ifnull(batchtext,'') as batchtext from ld_salesback
                    INNER JOIN ld_salesbackdetail on 
                    ld_salesback.salesbackid=ld_salesbackdetail.id
                    inner join ld_products on ld_products.productid =ld_salesbackdetail.productid
                     where ld_salesbackdetail.parent_lineitem_id in (" . $frommdouleFocus->lineitemIds. " )
                    and  ld_salesback.salesbackstatus not in ('中止', '未入库','结束')
                    group by ld_salesback.wareid, ld_products.productid,case when ld_products.batchmanagement=1 then ifnull(batchtext,'') 
                    						else '' END ) as tmp_backquantity
                    on tmp_backquantity.wareid=tmp_outquantity.wareid and tmp_backquantity.productid=tmp_outquantity.productid
                    and tmp_backquantity.batchtext=tmp_outquantity.batchtext)  as tmpoutquantity_table 
                    on tmpoutquantity_table.productid=$detailtable.productid ";
            }
                    
            $sql .= " where $detailtable.lineitem_id in ( " . $frommdouleFocus->lineitemIds. ')';
            //$sql .= ' and (ld_inventoryproductrel.haveoutproductcount - IFNULL(salesback.quantity,0)) > 0 ';
		}else{
            return '';
        }
		//未出库订单是否允许退货 
		if(empty($this->focus->id)){
			$saleback_deploy_arr=getSys_deploy(85);
			if($saleback_deploy_arr['deploy_value']==0){
			 
             $sql.=' and tmpoutquantity_table.outquantity>0 ';
			}
				
		}
		//设置源单分录明细范围
        $sql .= $this->getOtherSourceModuleSqlWhere();
		$sql .= " order by $detailtable.sequence_no asc";
	//	echo $sql;echo '<br><br>';
  // dump($sql);
		return $sql;
	}

	//获取明细sql
	public function getInventorySql($frommdouleFocus = ''){
		if($this->focus->id > 0 && empty($frommdouleFocus->lineitemIds)){
			return parent::getInventorySql($frommdouleFocus);
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
						//$this->sqlfields[$columnname] = '(ld_inventoryproductrel.haveoutproductcount) as quantity';
                        $this->sqlfields[$columnname] = 'tmpoutquantity_table.outquantity as quantity ';
                        
					}
                    else if($columnname == 'batchtext' && $tablename == $detailtable)
                    {
                        $this->sqlfields[$columnname] = 'tmpoutquantity_table.batchtext as batchtext ';
                    }
                    else{
						$this->sqlfields[$columnname] = $tablename . '.' . $columnname;
					}
					
				}
			}
			$tableArray[] = $tablename;
		}
        if($isRelatedModuleCreate=='yes'){
            $sql ='select ' . implode(',', $this->sqlfields) . ",ld_products.batchmanagement,ld_products.havepricestrategy,ld_products.discontinued" .$this->addProductbomColumn($detailtable);
            if(!empty($sqleffectcolumn_arr['detailcolumn']))
            {
               $sql.=','.implode(",",$sqleffectcolumn_arr['detailcolumn']);
            }
            $sql.= " from $detailtable ";
       }else{
            $sql ='select ' . implode(',', $this->sqlfields) . ",ld_products.batchmanagement,ld_products.havepricestrategy,ld_products.discontinued " .$this->addProductbomColumn($detailtable)
                ." from $detailtable ";
       }
		
		foreach($tableArray as $tablename){
			if($tablename != $detailtable){
				$leftjoin_table[strtolower($tablename)] = strtolower($tablename);
			}
		}
		//设置源单分录明细范围
		$leftjoin_table = $this->getOtherSourceModuleTables($leftjoin_table);
       $sql .=" left join ld_products on ld_products.productid=$detailtable.productid ";
		if(sizeOf($leftjoin_table) > 0){
		  //edit:duan  2022-4-7 如果源单分录中没有产品模块的字段（productname除外），生成sql时无法关联产品表，导致batchmanagement、havepricestrategy两个字段报错
		
			if(in_array('ld_productcf',$leftjoin_table)){
				$sql .=' left join ld_productcf on ld_products.productid=ld_productcf.productid ';
			}
			if(in_array($detailtablescf,$leftjoin_table)){
				$sql .=" left join $detailtablescf on $detailtablescf.lineitem_id=$detailtable.lineitem_id";
			}
		}
        //dump($sql);
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