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
    	//获取明细sql
	public function getInventorySql($frommdouleFocus = ''){
	   //25971: 服务合同明细：关联创建销售发票后，再次创建销售发票时，带出的产品数量为1，这里应该为0；
		if($this->focus->id > 0){
			return parent::getInventorySql($frommdouleFocus);
		}
        $this->getFromModuleProductToolInfo($frommdouleFocus);//获取关联创建模块的产品明细字段
        $isRelatedModuleCreate=$this->isRelatedModuleCreate($frommdouleFocus);
        $sqleffectcolumn_arr['detailcolumn']=[];
        if($isRelatedModuleCreate=='yes')
          {
            
            crm_load_class_file('cls_RelatedEntryField_Data','include/RelatedField');
			 $productfocus=CRMEntity::getInstance("Products");
             
   	         $cls_RelatedEntryField_Dataobj = new cls_RelatedEntryField_Data($this->focus->module_name,'entitytypeid');
             $sqleffectcolumn_arr = $cls_RelatedEntryField_Dataobj->getSelectSourceRelateColumns("trigger",$frommdouleFocus->module_name);
             $this->detaileffectcolumn_arr=array_keys($sqleffectcolumn_arr['detailcolumn']);
             $this->maineffectcolumn_arr=$sqleffectcolumn_arr['maincolumn'];
            $detailtablescf=$frommdouleFocus->Detail_table_scf;
            $detailtable=$frommdouleFocus->Detail_table;
            $this->sqlfields = $this->frominventoryFields;
            $tmproductall=$this->fromproductToolAll;
            foreach($this->focus->detailfieldobj->getModuleFields() as $tmpcolumnname=> $detailinfo)
            {
                if(!array_key_exists($tmpcolumnname,$tmproductall))
                {
                    if(array_key_exists($detailinfo->getTableName(),$productfocus->tab_name_index ))
                    {
                        $tmproductall[$tmpcolumnname]=$detailinfo;
                    }
                }
            }
           
            
             
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
                    //zkt 20231225 BUG0077626 页面设置->选择源单中，没有勾选“自动带出源单剩余数量”，也会有计算，例如：销售订单（XSHT265）相关创建采购订单，会自动计算源单剩余数量
                    $this->sqlfields[$columnname] = $tablename . '.' . $columnname;
                    /*
				    //38498: （51mis.com/kfbcrm）采购询价单明细界面>相关创建采购订单：没有将采购询价单的产品数量自动带出来。（需要补丁）
					if($frommdouleFocus->module_name!='PurchaseInquiryOrder'&&$columnname == 'quantity' && $isRelatedModuleCreate=='yes' && $tablename == $frommdouleFocus->Detail_table){
					    $customformmodules=array('CustomForm11','CustomForm12','CustomForm13','CustomForm14','CustomForm15','CustomForm16','CustomForm17','CustomForm18','CustomForm19','CustomForm20');
                        if(in_array($frommdouleFocus->module_name,$customformmodules))
                        {
                            $this->sqlfields[$columnname] = " $detailtable.quantity ";
                        }
                        else
                    	   $this->sqlfields[$columnname] = " ($detailtable.balancepurchasecount) as quantity ";
					}else{
						$this->sqlfields[$columnname] = $tablename . '.' . $columnname;
					}
					*/
				}
			}
			$tableArray[] = $tablename;
		}
        //40507: （http://51mis.com/demo/panlulu007演示账套 [^]）采购->采购订单，新建界面，选择“合同订单”源单时，带出的产品明细中“产品名称”显示乱码
        foreach($this->sqlfields as $tmpcolumnname=>$column_tablename){
            $column_tablenames=explode('.',$column_tablename);
            if(sizeof($column_tablenames)==2&&!in_array($column_tablenames[0],$tableArray)){
                $tableArray[] = $column_tablenames[0];
            }
        }
        if($isRelatedModuleCreate=='yes'){
            $sql ='select ' . implode(',', $this->sqlfields) .$this->addProductbomColumn($detailtable);
            if(!empty($sqleffectcolumn_arr['detailcolumn']))
            {
               $sql.=','.implode(",",$sqleffectcolumn_arr['detailcolumn']);
            }
            $sql.= " from $detailtable ";
       }else{
            $sql ='select ' . implode(',', $this->sqlfields). $this->addProductbomColumn($detailtable) . " from $detailtable ";
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
   //  dump($sql);
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
			$query = "SELECT
					balancepurchasecount,quantity
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
				$quantity = $adb->query_result($result,0,1);
			}
		}
		if($productdetail_mode == 'edit' && $isDuplicate != 'true'){
			$hiddenquantity += $productinfo['column_value'];
		}
		if($hiddenquantity == null){
			$sysdeploy = getSys_deploy(49);
			$quantity = sprintf('%.'.$sysdeploy['deploy_value'].'f',$quantity);
			$hiddenquantity = $quantity;
		}
		return $hiddenquantity;
	}
    
    //重写获取明细sql
	function getProductToolFieldSql($frommdouleFocus){
	   
		$sql=$this->getInventorySql($frommdouleFocus);
		//zkt 20230217 BUG0061762 选择源单-设置 带入分录明细范围 (主表字段)=》关联创建时分录未带出
        //设置主表连接
        $sql .= $this->getOtherSourceModuleMainLeftjoin();
        
		if($this->focus->id > 0 && empty($frommdouleFocus->lineitemIds)){//单据编辑、详情条件
            $detailtable=$this->focus->Detail_table;
			$sql .= " where $detailtable.id in ( " . $this->focus->id . ')';
		}else if( !is_null($frommdouleFocus->lineitemIds)&&trim($frommdouleFocus->lineitemIds)!="") {	//选择源单条件
            $detailtable=$frommdouleFocus->Detail_table;
			$sql .= " where $detailtable.lineitem_id in ( " . $frommdouleFocus->lineitemIds. ')';
		}
        else{
            return "";

        }
		//设置源单分录明细范围
        $sql .= $this->getOtherSourceModuleSqlWhere();
		$sql .= " order by $detailtable.sequence_no asc ";
	  
		return $sql;
	}
    //重写获取明细行自定义字段和属性
	public function getProductToolTrData($frommdouleFocus='',$productdetail_mode = ''){
		global $adb;
		$productToolTr = parent::getProductToolTrData($frommdouleFocus);
        $entitytype="";
		if($productdetail_mode == 'edit' || $productdetail_mode == 'details'){
		  $detailtable=$this->focus->Detail_table;
			$query = " select entitytype from $detailtable where id = ? and entitytype is not NULL limit 1 ";
			$result = $adb->pquery($query,array($frommdouleFocus->id));
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
			}else{
				$is_display = 1;//选择源单为空，默认不显示合同信息
			}
		}else{
			$entitytype = $frommdouleFocus->module;
		}
        if(is_null($entitytype))
        {
            $entitytype="";

        }
		foreach($productToolTr as $key => $producttoolinfo){
			if((strtolower($entitytype) == 'salesorder' || strtolower($entitytype) == 'servicecontracts' || $_REQUEST['contract_display'] == 'none') && $producttoolinfo->getUIType() == 205){
				unset($productToolTr[$key]);
			}
		}
		$productToolTr = array_values($productToolTr);
		
		return $productToolTr;
	}
}
?>