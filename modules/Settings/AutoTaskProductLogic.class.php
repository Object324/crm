<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @project PROT145 自动任务
 * @author Tujt 2015-01-14
 */
require_once('include/ProductDetails/ProductDetails.php');
//逻辑层 处理数据层数据，组装成query语句，此处处理的是有产品模块数据
class AutoTaskProductLogic{
     private $autoremindView;//自动提醒类对象
     private $meta;//字段对象数组(array('Accounts'=>$meta))
     private $stdFilter;//基本查询条件
     private $advFilter;//高级查询条件
     private $module;
     private $whereFields;
     private $referenceModuleMetaInfo;
     private $conditionInstanceCount;
     private $referenceFieldInfoList;
     private $referenceFieldList;
     private $manyToManyRelatedModuleConditions;
     private $groupInfo;
     private $conditionals;
     private $productDetails;
     private $ProductTableColumn=array();//列头所涉及到的产品相关表
     private $MainTableColumn=array();//列头涉及主表
     private $whereMainTable=array();//查询涉及主表
     private $whereProductTable=array();//查询涉及到的产品相关表
     private $ld_products='ld_products';
     private $ld_inventoryproductrel='';
     private $ld_scfinventoryproduct='';
	 private $createStdFilterSql;
	 private $user;
     public function  __construct($autoremindView,$user,$meta,$module){
		$this->autoremindView=$autoremindView;
		$this->moduleFields=$moduleFields;
		$this->conditionInstanceCount=0;
		$this->meta=$meta;
		$this->module=$module;
		$this->referenceFieldInfoList = $this->meta[$this->module]->getReferenceFieldDetails();
		$this->referenceFieldList = array_keys($this->referenceFieldInfoList);;
		$this->groupInfo = '';
		$this->conditionals=array();
		$this->getcvWhere();
	   $focus=CRMEntity::getInstance($module);
       $this->ld_inventoryproductrel=$focus->Detail_table;
       $this->ld_scfinventoryproduct=$focus->Detail_table_scf;
		$this->productDetails=new ProductDetails($module);
		$this->user = $user;
	}
      public function getFromClause() {
	   if(!empty($this->fromClause))
       {
            return $this->fromClause;
       }
      
       $producttable=array_filter(array_unique(array_merge($this->ProductTableColumn,$this->whereProductTable)));
       $maintable=array_filter(array_unique(array_merge($this->MainTableColumn,$this->whereMainTable)));
       $focus=new $this->module();
	
		$baseTable = $focus->table_name;
		$sql = " FROM $baseTable ";
        //$sql.= ' inner join ld_crmentity on ld_crmentity.crmid='.$baseTable.'.'.$focus->table_index;
		
		/**
		 * 新增一个数组，保存创建人、最近更新人等信息
		 * 放入全局变量中，在获取where条件中获取
		 * @reason 0012349 序时簿数据分类中，无法根据创建人过滤出数据
		 * @author Tujt 2014-11-11
		 */
		global $join_user_arr;
		$join_user_arr = array();
		foreach($maintable as $mtable)
        {
            if($mtable=='')
            {
                continue;
            }
             if($mtable!=$baseTable&&$mtable!='ld_crmentity')
             {
                
                if(array_key_exists($mtable,$focus->tab_name_index))
                {
                    $sql.=" left join  $mtable on ". $mtable.'.'.$focus->tab_name_index[$mtable]."=$baseTable.$focus->table_index ";
                }
                else
                {
                    $tablenames=explode('~~',$mtable);
                    if($tablenames[0]=='ld_users' || $tablenames[0]=='ld_users2')
                    {
                         if(in_array($tablenames[1],$this->ownerFields))
                                $sql.=" left join ld_users on ld_users.id=".$baseTable.".smownerid";
                         else
                         {
                            $field=$this->moduleFieldList[$tablenames[1]];
                            $columnname=$field->getColumnName();
							/**
							 * 对创建人、更新人做特别处理
							 * @reason 0012349 序时簿数据分类中，无法根据创建人过滤出数据
							 * @author Tujt 2014-11-11
							 */
							if($columnname == 'modifiedby'){
								$join_user_arr['modifiedby']['tab'] = 'ld_users1';
								$join_user_arr['modifiedby']['fld'] = 'modifiedby';
								$sql .= ' left join ld_users as ld_users1 on ld_users1.id = '.$baseTable.'.'.$columnname.' ';
							}else if($columnname == 'smcreatorid' || $columnname == 'transfersmownerid'){
								$join_user_arr['creator']['tab'] = 'ld_users2';
								$join_user_arr['creator']['fld'] = 'smcreatorid';
								$sql .= ' left join ld_users as ld_users2 on ld_users2.id = '.$baseTable.'.'.$columnname.' ';
							}
							else{
								$sql .= ' left join ld_users on ld_users.id = '.$baseTable.'.'.$columnname.' ';
							}
                            //$sql.=" left join ld_users on ld_users.id=ld_crmentity.$columnname";
                         }
                    }
                    else
                    {
                        $moduleList=$this->referenceFieldInfoList[$tablenames[1]];
                        require_once('modules/'.$moduleList[0].'/'.$moduleList[0].'.php');
                        $otherfocus=new $moduleList[0];
                        $field=$this->moduleFieldList[$tablenames[1]];
                        $columnname=$field->getColumnName();
                        $sql.=" left join $tablenames[0] on $tablenames[0].$otherfocus->table_index=$baseTable.$columnname";
                    }
                }
             }
              
        }
       
        $sql.=' inner join '.$this->ld_inventoryproductrel .' on '.$this->ld_inventoryproductrel.'.id='.$baseTable.'.'.$focus->table_index;
        if(in_array($this->ld_products,$producttable))
        {
            $sql.=' left join ld_products on ld_products.productid='.$this->ld_inventoryproductrel.'.productid left join ld_productcf on ld_products.productid=ld_productcf.productid';
        }
        if(in_array($this->ld_scfinventoryproduct,$producttable))
        {
            $sql.=' left join '.$this->ld_scfinventoryproduct.' on '.$this->ld_scfinventoryproduct.'.lineitem_id='.$this->ld_inventoryproductrel.'.lineitem_id ';
        }  
        if(in_array('200_ld_salesorder',$producttable))  //合同订单为源单
        {
             $sql.=' left join ld_salesorder on '.$this->ld_inventoryproductrel.'.entitytypeid=ld_salesorder.salesorderid ';
        }  
         if(in_array('201_ld_purchaseorder',$producttable))  //采购订单为源单
        {
             $sql.=' left join ld_salesorder on '.$this->ld_inventoryproductrel.'.entitytypeid=ld_purchaseorder.purchaseorderid ';
        }           
           
		$this->fromClause = $sql;
		return $sql;
	}
   
      public function getWhereClause() {
	   global $current_user;
		if(!empty($this->query) || !empty($this->whereClause)) {
			return $this->whereClause;
		}
		$deletedQuery = $this->meta[$this->module]->getEntityDeletedQuery();
		$sql = '';
		if(!empty($deletedQuery)) {
			$sql .= " WHERE $deletedQuery";
		}
		if($this->conditionInstanceCount > 0) {
			$sql .= ' AND ';
		} elseif(empty($deletedQuery)) {
			$sql .= ' WHERE ';
		}
		$baseTable = $this->meta[$this->module]->getEntityBaseTable();
		$moduleTableIndexList = $this->meta[$this->module]->getEntityTableIndexList();
     
		$baseTableIndex = $moduleTableIndexList[$baseTable];
		$groupSql = $this->groupInfo;
       
		$fieldSqlList = array();
       
		$producttable = array(strtolower($this->ld_products)=>'1',strtolower($this->ld_inventoryproductrel)=>'1',strtolower($this->ld_scfinventoryproduct)=>'1');
		
		/**
		 * 修改人、创建人对应users表，写死
		 * @reason 0012349 序时簿数据分类中，无法根据创建人过滤出数据
		 * @author Tujt 2014-11-11
		 */
		$join_user_arr = array('modifiedby'=>'ld_users1','creator'=>'ld_users2');
		$this->ownerFields = $this->meta[$this->module]->getOwnerFields();
		foreach ($this->conditionals as $index=>$conditionInfo) {
			if($conditionInfo=='') {continue;}
			$tablename = strtolower($conditionInfo['tablename']);
			if(isset($producttable[$tablename])){
				$modulefield=$this->productDetails->getModuleFields();
				$fieldName = $conditionInfo['name'];
				$field=$modulefield[$conditionInfo['name']];
				$this->whereProductTable[] = $conditionInfo['tablename'];
            }else{
				if(empty($this->moduleFieldList ))
   	            $this->moduleFieldList = $this->meta[$this->module]->getModuleFields();
                $fieldName = $conditionInfo['name'];
			    $field = $this->moduleFieldList[$fieldName]; 
                $this->whereMainTable[]=$conditionInfo['tablename'];
    			if(empty($field)) {
    				continue;
    			}
            }
			$fieldSql = '(';$fieldGlue = '';
			$valueSqlList = $this->getConditionValue($conditionInfo['value'],
				$conditionInfo['operator'],$field);
			if(!is_array($valueSqlList)) {
				$valueSqlList = array($valueSqlList);
			}
			foreach ($valueSqlList as $valueSql) {
				if($field->getUIType()==200){//源单为合同订单
					$this->whereProductTable[]='200_ld_salesorder';
					$fieldSql.=" $fieldGlue ld_salesorder.subject $valueSql";
                    if($conditionInfo['operator']=='isnull'){
                        $fieldSql.=' or ld_salesorder.subject IS NULL ';
                    }
				}elseif($field->getUIType()==201){//源单为采购订单
					$this->whereProductTable[]='201_ld_purchaseorder';
					$fieldSql.=" $fieldGlue ld_purchaseorder.subject $valueSql";
                    if($conditionInfo['operator']=='isnull'){
                        $fieldSql.=' or ld_purchaseorder.subject IS NULL ';
                    }
				}elseif (in_array($fieldName, $this->referenceFieldList)) {
					$moduleList = $this->referenceFieldInfoList[$fieldName];
					if(f_in_array('Users',$moduleList)){
						$moduleList = f_array_unique($moduleList);
					}
					foreach($moduleList as $module) {
						$meta = $this->getMeta($module);
						$nameFields = $this->moduleNameFields[$module];
					   
						$nameFieldList = explode(',',$nameFields);
						$columnList = array();
						foreach ($nameFieldList as $column) {
							if($module == 'Users') {
								$instance = CRMEntity::getInstance($module);
								$referenceTable = $instance->table_name;
								
								$column='last_name';
								if(count($this->ownerFields) > 0 ||
										$this->getModule() == 'Quotes') {
									$referenceTable .= '2';
								}
							} else {
						
								$referenceField = $meta->getFieldByColumnName($column);
								$referenceTable = $referenceField->getTableName();
							}
							if(isset($moduleTableIndexList[$referenceTable])) {
								$referenceTable = "$referenceTable$fieldName";
							}
							/**
							 * 直接把值赋给$columnlist数组
							 * @reason 0012349 序时簿数据分类中，无法根据创建人过滤出数据
							 * @author Tujt 2014-11-11
							 */
							if(isset($join_user_arr[$fieldName])){
								$columnList[] = "{$join_user_arr[$fieldName]}.$column";
							}else{
								$columnList[] = "$referenceTable.$column";
							}
							//$columnList[] = "$referenceTable.$column";
						   
							$this->whereMainTable[]=$referenceTable.'~~'.$fieldName;//关联表
						
						}
						if(count($columnList) > 1) {
							$columnSql = getSqlForNameInDisplayFormat(array('first_name'=>$columnList[0],'last_name'=>$columnList[1]),'Users');
						} else {
							$columnSql = implode('', $columnList);
						}

						$fieldSql .= "$fieldGlue trim($columnSql) $valueSql";
                        if($conditionInfo['operator']=='isnull'){
                            $fieldSql.=' or '.trim($columnSql).' IS NULL ';
                        }
						$fieldGlue = ' OR';
					}
				}elseif (!empty($this->ownerFields) && in_array($fieldName, $this->ownerFields)) {
					$concatSql="ld_users.last_name";
					$fieldSql .= "$fieldGlue trim($concatSql) $valueSql ";
                    if($conditionInfo['operator']=='isnull'){
                            $fieldSql.=' or '.trim($concatSql).' IS NULL ';
                        }
					$this->whereMainTable[]='ld_users~~'.$fieldName;
				}else{
					if($fieldName == 'birthday' && !$this->isRelativeSearchOperators(
							$conditionInfo['operator'])) {
						$fieldSql .= "$fieldGlue DATE_FORMAT(".$field->getTableName().'.'.
								$field->getColumnName().",'%m%d') ".$valueSql;
                        if($conditionInfo['operator']=='isnull'){                                
                        $fieldSql.=' or '."DATE_FORMAT(".$field->getTableName().'.'.
								$field->getColumnName().",'%m%d') ".' IS NULL ';
                        }
					}
					elseif($this->module == 'Checks' || $this->module == 'Stock'  || $this->module == 'OutboundOrder')
					{
						if($fieldName == 'wareid' || $fieldName == 'warehouseid')
						{
						   $fieldSql .= $field->getTableName(). '.' . $field->getColumnName() . " in (select id from ld_warehouse where `name` " . $valueSql . ")";
						}
						else if($fieldName == 'purchaseorder_id')
						{
						   $fieldSql .= $field->getTableName(). '.' . $field->getColumnName() . " in (select purchaseorderid from ld_purchaseorder where `subject` " . $valueSql . ")";
						}
						else if($fieldName == 'subsmownerid')
						{
							$fieldSql .= $field->getTableName(). '.' . $field->getColumnName() . " in (select id from ld_users where `user_name` " . $valueSql . ")";
						}
						else if($fieldName == 'presence' && ($valueSql != "= '0'" && $valueSql != "= '1'"))
						{
							if(strstr($valueSql,'未') || strstr($valueSql,'中'))
								$fieldSql .= $field->getTableName(). '.' . $field->getColumnName() . " = 0";
							else
								$fieldSql .= $field->getTableName(). '.' . $field->getColumnName() . " = 1";
						}
						else
						{
							$fieldSql .= "$fieldGlue ".$field->getTableName().'.'.
								$field->getColumnName().' '.$valueSql;
                             if($conditionInfo['operator']=='isnull'){
                                $fieldSql.=' or '.$field->getTableName().'.'.
								$field->getColumnName().' IS NULL ';
                            }                              
						}
						
					}else {
						$fieldSql .= "$fieldGlue ".$field->getTableName().'.'.
								$field->getColumnName().' '.$valueSql;
                            if($conditionInfo['operator']=='isnull'){
                                $fieldSql.=' or '.$field->getTableName().'.'.
								$field->getColumnName().' IS NULL ';
                            }
                            if($field->getFieldName()=='nextcontactdate'&&$conditionInfo['operator']=='isnull'){
                                    $fieldSql.=' or '.$field->getTableName().'.'.
    								$field->getColumnName()."='0000-00-00'";                                    
                                }elseif($field->getFieldName()=='nextcontactdate'&&$conditionInfo['operator']=='isnotnull'){
                                    $fieldSql.=' and '.$field->getTableName().'.'.
    								$field->getColumnName()."<>'0000-00-00'";     
                                }
					}
				}
				$fieldGlue = ' OR';
			}
			$fieldSql .= ')';
			$fieldSqlList[$index] = $fieldSql;
		}
		/**
		 * 增加一个getFilterGroup方法，获取高级条件的关联（and、or）
		 * @project PROT145 自动任务
		 * @author Tujt 2015-01-15
		 */
		$groupSql = $this->autoremindView->getFilterGroup();
		$groupSql = $this->makeGroupSqlReplacements($fieldSqlList, $groupSql);
		if($this->conditionInstanceCount > 0) {
			$this->conditionalWhere = $groupSql;//$groupSql是视图的查询条件
			$sql .= $groupSql;
		}
		$strfilesql = $this->createStdFilterSql;
        if(!empty($strfilesql))
             $sql .= ' and ( '.$strfilesql.') ';

		$sql .= " AND $baseTable.$baseTableIndex > 0";
        $this->whereProductTable=array_unique($this->whereProductTable);
        $this->whereMainTable=array_unique($this->whereMainTable);
        //重新按数组小标重组数据
        $whereprocolumns=implode(',', $this->whereProductTable);
        $wheremaincolumns=implode(',', $this->whereMainTable);
        $this->whereProductTable=explode(',',$whereprocolumns);
        $this->whereMainTable=explode(',',$wheremaincolumns);
     
		$this->whereClause = $sql;
    
		return $sql;
	}
    private function getConditionValue($value, $operator,$field) {
        global $current_user,$app_strings;
		$operator = strtolower($operator);
		$db = PearDatabase::getInstance();
   
       
		if(is_string($value)) {
			$valueArray = explode(',' , $value);
		} elseif(is_array($value)) {
			$valueArray = $value;
		} else{
			$valueArray = array($value);
		}
		$sql = array();
		if($operator == 'between' || $operator == 'bw') {
			if($field->getFieldName() == 'birthday') {
				$valueArray[0] = getValidDBInsertDateTimeValue($valueArray[0]);
				$valueArray[1] = getValidDBInsertDateTimeValue($valueArray[1]);
				$sql[] = "BETWEEN DATE_FORMAT(".$db->quote($valueArray[0]).", '%m%d') AND ".
						"DATE_FORMAT(".$db->quote($valueArray[1]).", '%m%d')";
			} else {
				if($this->isDateType($field->getFieldDataType())) {
					$valueArray[0] = getValidDBInsertDateTimeValue($valueArray[0]);
					$valueArray[1] = getValidDBInsertDateTimeValue($valueArray[1]);
				}
				$sql[] = "BETWEEN ".$db->quote($valueArray[0])." AND ".
							$db->quote($valueArray[1]);
			}
			return $sql;
		}
		foreach ($valueArray as $value) {
           
			if(!$this->isStringType($field->getFieldDataType())) {
				$value = trim($value);
			}
			if((strtolower(trim($value)) == 'null') ||
					(trim($value) == '' && !$this->isStringType($field->getFieldDataType())) &&
							($operator == 'e' || $operator == 'n')) {
				if($operator == 'e'){
					$sql[] = "IS NULL";
					continue;
				}
				$sql[] = "IS NOT NULL";
				continue;
			} elseif($field->getFieldDataType() == 'boolean') {
		
				$value = strtolower($value);
				if ($value == $app_strings['yes']) {
					$value = 1;
				} elseif($value == $app_strings['no']) {
					$value = 0;
				}
			} elseif($this->isDateType($field->getFieldDataType())) {
				$value = getValidDBInsertDateTimeValue($value);
            }

			if($field->getFieldName() == 'birthday' && !$this->isRelativeSearchOperators(
					$operator)) {
				$value = "DATE_FORMAT(".$db->quote($value).", '%m%d')";
			}else {
				$value = $db->sql_escape_string($value);
			}

			if(trim($value) == '' && ($operator == 's' || $operator == 'ew' || $operator == 'c')
					&& ($this->isStringType($field->getFieldDataType()) ||
					$field->getFieldDataType() == 'picklist' ||
					$field->getFieldDataType() == 'multipicklist')) {
				$sql[] = "LIKE ''";
				continue;
			}

			if(trim($value) == '' && ($operator == 'k') &&
					$this->isStringType($field->getFieldDataType())) {
				$sql[] = "NOT LIKE ''";
				continue;
			}
            if(empty($value)&&$operator!='isnotnull'){
                $operator='isnull';
            }
			switch($operator) {
				case 'e': $sqlOperator = "=";
					break;
				case 'n': $sqlOperator = "<>";
					break;
				case 's': $sqlOperator = "LIKE";
					$value = "$value%";
					break;
				case 'ew': $sqlOperator = "LIKE";
					$value = "%$value";
					break;
				case 'c': $sqlOperator = "LIKE";
					$value = "%$value%";
					break;
				case 'k': $sqlOperator = "NOT LIKE";
					$value = "%$value%";
					break;
				case 'l': $sqlOperator = "<";
					break;
				case 'g': $sqlOperator = ">";
					break;
				case 'm': $sqlOperator = "<=";
					break;
				case 'h': $sqlOperator = ">=";
					break;
				case 'a': $sqlOperator = ">";
					break;
				case 'b': $sqlOperator = "<";
					break;
 				case 'isnull': $sqlOperator = "=";
					break;
				case 'isnotnull': $sqlOperator = "<>";
					break;
			}
			if(!$this->isNumericType($field->getFieldDataType()) &&
					($field->getFieldName() != 'birthday' || ($field->getFieldName() == 'birthday'
							&& $this->isRelativeSearchOperators($operator)))){
				$value = "'$value'";
			}
			if($this->isNumericType($field->getFieldDataType()) && empty($value)) {
				$value = '0';
			}
			//$sql[] = "$sqlOperator $value";
                    $sql[] = "$sqlOperator $value";
		}
		return $sql;
	}
    public function getQuery()
    {
       
        $where=$this->getWhereClause();
        $fromclause=$this->getFromClause();
       return $fromclause.$where;
    }
   	private function makeGroupSqlReplacements($fieldSqlList, $groupSql) {
		$pos = 0;
		$nextOffset = 0;
        global $current_user;
		foreach ($fieldSqlList as $index => $fieldSql) {
			$pos = strpos($groupSql, $index.'', $nextOffset);
			if($pos !== false) {
				$beforeStr = substr($groupSql,0,$pos);
				$afterStr = substr($groupSql, $pos + strlen($index));
				$nextOffset = strlen($beforeStr.$fieldSql);
                
				$groupSql = $beforeStr.$fieldSql.$afterStr;
			} 
		}
       
       
		return $groupSql;
	}
   	private function isRelativeSearchOperators($operator) 
    {
		$nonDaySearchOperators = array('l','g','m','h');
		return in_array($operator, $nonDaySearchOperators);
	}
	private function isNumericType($type) {
		return ($type == 'integer' || $type == 'double' || $type == 'currency');
	}

	private function isStringType($type) {
		return ($type == 'string' || $type == 'text' || $type == 'email' || $type == 'reference');
	}

	private function isDateType($type) {
		return ($type == 'date' || $type == 'datetime');
	}
       private function getModuleFields()
       {
            return $this->meta[$this->module]->getModuleFields();
       }
      /**
       * 获取自动提醒条件
       * */
      public function getcvWhere()
      {
        $this->stdFilter=$this->autoremindView->getStdFilterByautoid();
        $this->advFilter=$this->autoremindView->getAdvFilterByautoid();
        
       $this->createStdFilterSql();
       $this->createAdvFilterSql();
          
      }
      /**
       * 获取基本查询条件sql;
       * */
      private function createStdFilterSql()
      {
        if(is_array($this->stdFilter))
         {
			$value = array();
			if(!empty($this->stdFilter['columnname'])) 
            {
			
				$name = explode(':',$this->stdFilter['columnname']);
				$this->whereFields[] =$name[2];
				$value[] = $this->fixDateTimeValue($name[2], $this->stdFilter['startdate']);
				$value[] = $this->fixDateTimeValue($name[2], $this->stdFilter['enddate'], false);
				$sql= $name[0].'.'.$name[1].' between \''.$value[0].'\' and \''.$value[1]."'";
			}
            $this->createStdFilterSql = $sql;
		}
        return '';
      }
 	public function addConditionGlue($glue)
    {
		$this->groupInfo .= " $glue ";
    }
      private function createAdvFilterSql()
      {
        	if(is_array($this->advFilter) && count($this->advFilter) > 0) {
        	  
			foreach ($this->advFilter as $groupindex=>$groupcolumns) {
				$filtercolumns = $groupcolumns['columns'];
				if(count($filtercolumns) > 0) {
					
					foreach ($filtercolumns as $index=>$filter) {
						$name = explode(':',$filter['columnname']);
						if(empty($name[2]) && $name[1] == 'crmid' && $name[0] == 'ld_crmentity') {
							$name = $this->getSQLColumn('id');
							$tablename = 'ld_crmentity';
						} else {
							$tablename = $name[0];
							$name = $name[2];
						}
						$this->addCondition($name, $filter['value'], $filter['comparator'],$tablename);
                        $columncondition = $filter['column_condition'];
						if(!empty($columncondition)) {
							$this->addConditionGlue($columncondition);
						}
					}
				}
			}
		}
      }
 	public function addCondition($fieldname,$value,$operator,$tablename='',$glue= null,$newGroup = false,
			$newGroupType = null)
         {
      
		$conditionNumber = $this->conditionInstanceCount++;
		$this->groupInfo .= "$conditionNumber ";
		$this->whereFields[] = $fieldname;
		$this->reset();
       
		$conditionals = $this->getConditionalArray($fieldname,$value, $operator,$tablename);
        if(!empty($conditionals))
			$this->conditionals[$conditionNumber] = $conditionals;
	}
	   private function fixDateTimeValue($name, $value, $first = true) 
       {
	       $moduleFields=$this->getModuleFields();
          $field = $moduleFields[$name];
    	$type = $field->getFieldDataType();
		if($type == 'datetime')
        {
    			if(strrpos($value, ' ') === false) {
    				if($first) {
    					return $value.' 00:00:00';
    				}else{
    					return $value.' 23:59:59';
    				}
    			}
    		}
    		return $value;
	}
    
   	private function getConditionalArray($fieldname,$value,$operator,$tablename='') {
		if(is_string($value)) {
			$value = trim($value);
		} elseif(is_array($value)) {
			$value = array_map(trim, $value);
		}
		return array('name'=>$fieldname,'value'=>$value,'operator'=>$operator,'tablename'=>$tablename);
	}
 	public function reset()
     {
		$this->fromClause = null;
		$this->whereClause = null;
		$this->columns = null;
		$this->query = null;
	 }
	public function getModule() {
		return $this->module;
	}
	public function getMeta($module) {
		$db = PearDatabase::getInstance();
		if (empty($this->referenceModuleMetaInfo[$module])) {
			$handler = vtws_getModuleHandlerFromName($module, $this->user);
			$meta = $handler->getMeta();//lingdangCRMObjectMeta.php
			$this->referenceModuleMetaInfo[$module] = $meta;
			$this->moduleNameFields[$module] = $meta->getNameFields();
            $this->meta[$module]=$meta;
		}
		return $this->referenceModuleMetaInfo[$module];
	}
}


?>