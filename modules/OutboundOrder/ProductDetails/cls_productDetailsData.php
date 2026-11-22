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
    
	//重写获取明细sql
	function getProductToolFieldSql($frommdouleFocus){
	  
       
		$sql=$this->getInventorySql($frommdouleFocus);
		//zkt 20230217 BUG0061762 选择源单-设置 带入分录明细范围 (主表字段)=》关联创建时分录未带出
        //设置主表连接
        $sql .= $this->getOtherSourceModuleMainLeftjoin();
      
       // $sql.=',ld_products.havepricestrategy,ld_products.batchmanagement ';
		if($this->focus->id > 0 && empty($frommdouleFocus->lineitemIds)){//单据编辑、详情条件
        $detailtable=$this->focus->Detail_table;
			$sql .= " where $detailtable.id in ( " . $this->focus->id . ')';
		}elseif(!is_null($frommdouleFocus->lineitemIds)&&trim($frommdouleFocus->lineitemIds)!="") {	//选择源单条件
                $detailtable=$frommdouleFocus->Detail_table;
			$sql .= " where $detailtable.lineitem_id in ( ". $frommdouleFocus->lineitemIds. ')';

//			@edit:liushuai,2021-06-05,reason:【ID1001679】带产品分录的表单，选择源单字段->源单类型定制中增加字段属性参数“剩余数量为0时自动带出“
            //$sql .= $this->getWhereNotWithBalanceqty($frommdouleFocus);
		}
        else{
            return '';
        }
		//设置源单分录明细范围
        $sql .= $this->getOtherSourceModuleSqlWhere();
		//出库或入库时必须严格参照源单（每种产品累计数量不允许超出源单或者出现源单外的产品）。0:是，1:否
		/*if($_REQUEST['isDuplicate'] != 'true' && $this->productdetail_mode != 'edit' && $this->productdetail_mode != 'details'){
			$sysdeploy3= getSys_deploy(10);
             $customformmodules=array('CustomForm11','CustomForm12','CustomForm13','CustomForm14','CustomForm15','CustomForm16','CustomForm17','CustomForm18','CustomForm19','CustomForm20');
             
			if($sysdeploy3['deploy_value'] == 0&&!in_array($frommdouleFocus->module_name,$customformmodules)){
					$sql .=" and $detailtable.balanceoutproductcount > 0";
			}
		}*/

		$sql .= " order by $detailtable.sequence_no asc";


		return $sql;
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
			 
			$cls_RelatedEntryField_Dataobj = new cls_RelatedEntryField_Data($this->focus->module_name,'entitytypeid');
			$sqleffectcolumn_arr = $cls_RelatedEntryField_Dataobj->getSelectSourceRelateColumns("trigger",$frommdouleFocus->module_name);
			$this->detaileffectcolumn_arr=array_keys($sqleffectcolumn_arr['detailcolumn']);
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
				if(($fieldInfo->getTableName() == 'ld_products'||$fieldInfo->getTableName() == 'ld_productcf') && $fieldInfo->getFieldid() > 0 && $fieldInfo->getinput_type() == 1){
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
				    //統一到  带出原单剩余数量或金额
					//if($columnname == 'quantity' && $isRelatedModuleCreate=='yes' && $tablename == $frommdouleFocus->Detail_table){
					//	$this->sqlfields[$columnname] = " ($detailtable.balanceinvoicecount) as quantity ";
				//	}else{
						$this->sqlfields[$columnname] = $tablename . '.' . $columnname;
				//	}
					
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
        //edit:can 2021-01-13 42240: （https://61mis.com/kfbtest/ [^]）采购订单（PO23）单据查看详情界面，相关信息中关联创建“采购发票”时，应该带出产品套餐名称和组合数量
		if($isRelatedModuleCreate=='yes'){
            $sql ='select ' . implode(',', $this->sqlfields) .$this->addProductbomColumn($detailtable) ;
            if(!empty($sqleffectcolumn_arr['detailcolumn']))
            {
               $sql.=','.implode(",",$sqleffectcolumn_arr['detailcolumn']);
            }
            $sql.= " from $detailtable ";
       }else{
            $sql ='select ' . implode(',', $this->sqlfields) .$this->addProductbomColumn($detailtable) ." from $detailtable ";
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
       // dump($sql);
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
			$query =  " SELECT
					balanceoutproductcount,quantity 
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
				$quantity = $adb->query_result($result,0,1); 
			}
		}
		if($productdetail_mode == 'edit' && $isDuplicate != 'true'){
			$hiddenquantity += $productinfo['column_value'];
		}
		//如果热线单有关联的报损单，则自动带出报损单的产品明细到维修内容中
		$VersionInfo = getVersionInfo();
		if($VersionInfo['account'] == 'climaveneta'){
			$sysdeploy = getSys_deploy(49);
			$quantity = sprintf('%.'.$sysdeploy['deploy_value'].'f',$quantity);
			$hiddenquantity = $quantity;
		}
		return $hiddenquantity;
	}

	//重写获取明细行自定义字段和属性
	public function getProductToolTrData($frommdouleFocus='',$productdetail_mode = ''){
		global $adb;
		$productToolTr = parent::getProductToolTrData($frommdouleFocus);
		if($productdetail_mode == 'edit' || $productdetail_mode == 'details'){
		  $detailtable=$this->focus->Detail_table;
			$query = " select entitytype from $detailtable where id = ? and entitytype is not NULL limit 1 ";
			$result = $adb->pquery($query,array($frommdouleFocus->id));
			$entitytype = $adb->query_result($result,0,0)??'';
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
		foreach($productToolTr as $key => $producttoolinfo){
			if(!empty($entitytype) && (strtolower($entitytype) == 'salesorder' || strtolower($entitytype) == 'servicecontracts' || $_REQUEST['contract_display'] == 'none') && $producttoolinfo->getUIType() == 205){
			//	unset($productToolTr[$key]);
			}
		}
		$productToolTr = array_values($productToolTr);
		
		return $productToolTr;
	}

    public function getSourceModuleBalanceValue($frommoduleFocus,$autobalancecolumnname)
    {
        static $static_sourcebalancevalue_arr;
        if(is_array($static_sourcebalancevalue_arr)&&array_key_exists($frommoduleFocus->id,$static_sourcebalancevalue_arr))
        {
            return $static_sourcebalancevalue_arr[$frommoduleFocus->id];
        }
        global $adb;
        $sourcefieldinfo=$frommoduleFocus->detailfieldobj->getFieldInfoobjBykey("columnname",$autobalancecolumnname);
        if(empty($sourcefieldinfo)){
            return array();
        }

        $fieldinfo=$this->focus->detailfieldobj->getFieldInfoobjBykey("columnname",$autobalancecolumnname);
        if(empty($fieldinfo)){
            return array();
        }
        if($autobalancecolumnname != 'quantity' || $frommoduleFocus->moduleName != 'SalesOrder'){
            return parent::getSourceModuleBalanceValue($frommoduleFocus,$autobalancecolumnname);
        }
        $system_49 = getSys_deploy(49);
        if(is_numeric($system_49['deploy_value'])){
            $typeofdata_decimal = $system_49['deploy_value'];
        }
        else {
            $typeofdata_decimal = 2;
        }
        $source_detailtabname = $frommoduleFocus->Detail_table;
        $sql = "select lineitem_id, IFNULL(balanceoutproductcount,IFNULL(quantity,0)-IFNULL(haveoutproductcount,0)) as $autobalancecolumnname from $source_detailtabname where id=? ";
        $result=$adb->pquery($sql,array($frommoduleFocus->id));
        $rows=$adb->num_rows($result);
        for($i=0;$i<$rows;$i++)
        {

            $lineitem_id=$adb->query_result($result,$i,'lineitem_id');
            $value=$adb->query_result($result,$i,$autobalancecolumnname);
            $balancevalue=setNumberFormatEmptySeperator($value,$typeofdata_decimal);
            $tmp_arr[$lineitem_id]=$balancevalue;

        }
        $static_sourcebalancevalue_arr=[];
        $static_sourcebalancevalue_arr[$frommoduleFocus->id]=$tmp_arr;

        return $tmp_arr;
    }
}
?>