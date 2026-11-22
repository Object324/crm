<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @project PROT145 自动任务
 * @author Tujt 2015-01-14
 */
//逻辑层 处理数据层数据，组装成query语句，此处处理的是普通模块数据
class AutoTaskQueryLogic{
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
	private $user;
	private $createStdFilterSql;
    private $focus;
    private $ownerFields;
	public function  __construct($autoremindView,$user,$meta,$module){
		global $adb;
		$this->autoremindView=$autoremindView;
		$this->moduleFields=$moduleFields;
		$this->conditionInstanceCount=0;
		$this->meta=$meta;
		$this->module=$module;
        $this->focus=CRMEntity::getInstance($module);
		$this->fieldobj = Field::getInstance($module,$adb);
		$this->referenceFieldInfoList = $this->fieldobj->getReferenceFieldDetails();
		$this->referenceFieldList = array_keys($this->referenceFieldInfoList);;
		$this->groupInfo = '';
		$this->conditionals=array();
		$this->getcvWhere();
		$this->user = $user;
        $this->ownerFields=array($this->fieldobj->getFieldInfoBykeyValue('columnname','smownerid','fieldname'));
	}
    public function getFromClause()
    {
	 
        $moduleFields = $this->meta[$this->module]->getModuleFields();
		$tableList = array();
		$tableJoinMapping = array();
		$tableJoinCondition = array();
		
		/**
		 * 新增一个数组，保存创建人、最近更新人等信息
		 * 放入全局变量中，在获取where条件中获取
		 * @reason 0012349 序时簿数据分类中，无法根据创建人过滤出数据
		 * @author Tujt 2014-11-11
		 */
		global $join_user_arr;
		$join_user_arr = array();
		if(!empty($this->whereFields)){
			foreach ($this->whereFields as $fieldName) {
				if ($fieldName == 'id') {
					continue;
				}

				$field = $moduleFields[$fieldName];
				
				$baseTable = $field->getTableName();
				
				$tableIndexList = $this->focus->tab_name_index;
				$baseTableIndex = $tableIndexList[$baseTable];       
				if($field->getFieldDataType() == 'reference') {
					
					$moduleList = $this->referenceFieldInfoList[$fieldName];
					$tableJoinMapping[$field->getTableName()] = 'INNER JOIN';
					foreach($moduleList as $module) {
						if($module == 'Users') {
							$tableJoinCondition[$fieldName]['ld_users'] = $field->getTableName().
									".".$field->getColumnName()." = ld_users.id";
					
							//$tableJoinMapping['ld_users'] = 'LEFT JOIN';
						
						}
						/**
						 * 对创建人、更新人做特别处理
						 * @reason 0012349 序时簿数据分类中，无法根据创建人过滤出数据
						 * @author Tujt 2014-11-11
						 */
						if($fieldName == 'modifiedby'){
							$join_user_arr['modifiedby']['tab'] = 'ld_users1';
							$join_user_arr['modifiedby']['fld'] = 'modifiedby';
						}else if($fieldName == 'creator'){
							$join_user_arr['creator']['tab'] = 'ld_users2';
							$join_user_arr['creator']['fld'] = 'smcreatorid';
						}else{
							$tableJoinMapping[$referenceTableName] = 'LEFT JOIN';
						}
					}
				} elseif($field->getFieldDataType() == 'owner') {
					$tableList['ld_users'] = 'ld_users';
					$tableJoinMapping['ld_users'] = 'LEFT JOIN';
				}
				else if($field->getUIType()==251) //转出账户
				{
				   
					$sameTableList[]=array('BankAccountSet','ld_obank','outaccount');
				}
				else if($field->getUIType()==252)//转入账户
				{
					$sameTableList[]=array('BankAccountSet','ld_ibank','inaccount');
				}
				$tableList[$field->getTableName()] = $field->getTableName();
					$tableJoinMapping[$field->getTableName()] =
							$this->focus->getJoinClause($field->getTableName());
				
			}
		}
		$baseTable = $this->focus->table_name;
        
		$moduleTableIndexList = $this->focus->tab_name_index;
		$baseTableIndex = $moduleTableIndexList[$baseTable];
		if(!empty($this->whereFields)){
			 foreach ($this->whereFields as $fieldName) {
				if(empty($fieldName)) {
					continue;
				}
				$field = $moduleFields[$fieldName];
				
				if(empty($field)) {
					// not accessible field.
					continue;
				}
				
				$baseTable = $field->getTableName();
				if(empty($tableList[$baseTable])) {
					$tableList[$baseTable] = $field->getTableName();
					$tableJoinMapping[$baseTable] = $this->meta[$this->module]->getJoinClause($field->getTableName());
				}
				if($field->getFieldDataType() == 'reference') {
				 //得到相关联模块查询字段
					$moduleList = $this->referenceFieldInfoList[$fieldName];
					$tableJoinMapping[$field->getTableName()] = 'INNER JOIN';
					foreach($moduleList as $module) {
						 if(!array_key_exists($module,$this->meta))
							   $meta = $this->getMeta($module);
						else
							$meta=$this->meta[$module];
						$nameFields = $this->moduleNameFields[$module];
						$nameFieldList = explode(',',$nameFields);
						foreach ($nameFieldList as $index=>$column) {
							// for non admin user users module is inaccessible.
							// so need hard code the tablename.
							if($module == 'Users') {
								$instance = CRMEntity::getInstance($module);
								$referenceTable = $instance->table_name;
								$tableIndexList = $instance->tab_name_index;
								$referenceTableIndex = $tableIndexList[$referenceTable];
							} else {
								$referenceField = $meta->getFieldByColumnName($column);
								$referenceTable = $referenceField->getTableName();
								
								$tableIndexList = $meta->getEntityTableIndexList();
								$referenceTableIndex = $tableIndexList[$referenceTable];
							}
							if(isset($moduleTableIndexList[$referenceTable])) {
								$referenceTableName = "$referenceTable $referenceTable$fieldName";
								$referenceTable = "$referenceTable$fieldName";
							} else {
								$referenceTableName = $referenceTable;
							}
						
							$tableJoinMapping[$referenceTableName] = 'LEFT JOIN';
							$tableJoinCondition[$fieldName][$referenceTableName] = $baseTable.'.'.
								$field->getColumnName().' = '.$referenceTable.'.'.$referenceTableIndex;
						}
					}
				} elseif($field->getFieldDataType() == 'owner') {
					$tableList['ld_users'] = 'ld_users';
				
					$tableJoinMapping['ld_users'] = 'LEFT JOIN';
				}
				else if($field->getUIType()==251) //转出账户
				{
				   
					$sameTableList[]=array('BankAccountSet','ld_obank','outaccount');
				}
				else if($field->getUIType()==252)//转入账户
				{
					$sameTableList[]=array('BankAccountSet','ld_ibank','inaccount');
				}
				else {
					$tableList[$field->getTableName()] = $field->getTableName();
					$tableJoinMapping[$field->getTableName()] =
							$this->focus->getJoinClause($field->getTableName());
				}
			}
		}
       
	
		$ownerFields = $this->ownerFields;
		if (count($ownerFields) > 0) {
			$ownerField = $ownerFields[0];
		}
		$baseTable = $this->focus->table_name;
        //echo $baseTable;
		$sql = " FROM $baseTable ";
		unset($tableList[$baseTable]);
		foreach ($defaultTableList as $tableName) {
			$sql .= " $tableJoinMapping[$tableName] $tableName ON $baseTable.".
					"$baseTableIndex = $tableName.$moduleTableIndexList[$tableName]";
			unset($tableList[$tableName]);
		}
		foreach ($tableList as $tablekey=>$tableName) {
			if(strtolower($tableName) == 'ld_users') {
				$field = $moduleFields[$ownerField];
				$sql .= " $tableJoinMapping[$tableName] $tableName ON ".$field->getTableName().".".
					$field->getColumnName()." = $tableName.id";
			} else {
			 
                    if((strtolower($tableName)=='ld_contactdetails'||strtolower($tableName)=='ld_contactaddress')&&strtolower($this->module)=='accounts')
                     {
                        if(strtolower($tableName)=='ld_contactdetails')
                            $sql.=' left join ld_contactdetails on ld_account.accountid=ld_contactdetails.accountid';
                        if(strtolower($tableName)=='ld_contactaddress')
                          $sql.=' left join ld_contactdetails on ld_account.accountid=ld_contactdetails.accountid left join ld_contactaddress on ld_contactaddress.contactaddressid=ld_contactdetails.contactid';
                     }
                     else
                     {
                        	$sql .= " left join  $tableName ON $baseTable.".
    					"$baseTableIndex = $tableName.$moduleTableIndexList[$tableName]";
                     }
			}
		}
		/**
		 * 创建人、自动更新人做特别链接
		 * @reason 0012349 序时簿数据分类中，无法根据创建人过滤出数据
		 * @author Tujt 2014-11-11
		 */
		if(!empty($join_user_arr)){
			foreach($join_user_arr as $join_tab=>$join_arr){
				$sql .= ' left join ld_users as '.$join_arr['tab'].' 
							on '.$join_arr['tab'].'.id = '.$baseTable.'.'.$join_arr['fld'].' ';
			}
		}

		if( $this->module == 'Documents') {
			$tableJoinCondition['folderid'] = array(
				'ld_attachmentsfolder'=>"$baseTable.folderid = ld_attachmentsfolder.folderid"
			);
			$tableJoinMapping['ld_attachmentsfolder'] = 'INNER JOIN';
		}
		unset($tableJoinCondition['creator']);
		unset($tableJoinCondition['modifiedby']);
		if(!empty($tableJoinCondition)){
			foreach ($tableJoinCondition as $fieldName=>$conditionInfo) {
				foreach ($conditionInfo as $tableName=>$condition) {
					if(!empty($tableList[$tableName])) {
						$tableNameAlias = $tableName.'2';
						$condition = str_replace($tableName, $tableNameAlias, $condition);
					} else {
						$tableNameAlias = '';
					}
					$sql .= " $tableJoinMapping[$tableName] $tableName $tableNameAlias ON $condition";
				  
				}
			}
		}
		
		if(!empty($sameTableList)){
			foreach($sameTableList as $samemodulename =>$asTalbename)
			{
				 $samefocus=new $asTalbename[0];
				 if(stripos($sql,$asTalbename[1])<=0)
					$sql.=' left join '.$samefocus->table_name.' as '.$asTalbename[1].' on '.$asTalbename[1].'.'.$samefocus->table_index.'='.$baseTable.'.'.$asTalbename[2];
			}
        }
		$this->fromClause = $sql;
		return $sql;
	}
    public function getWhereClause() {
 

		$deletedQuery = $this->focus->getEntityDeletedQuery();
		$sql = '';
		if(!empty($deletedQuery)) {
			$sql .= " WHERE $deletedQuery";
		}
		if($this->conditionInstanceCount > 0) {
			$sql .= ' AND ';
		} elseif(empty($deletedQuery)) {
			$sql .= ' WHERE ';
		}
        
        
		$moduleFieldList = $this->meta[$this->module]->getModuleFields();
		$baseTable = $this->focus->table_name;
		$moduleTableIndexList = $this->focus->tab_name_index;
		$baseTableIndex = $moduleTableIndexList[$baseTable];
		$groupSql = $this->groupInfo;
       
		$fieldSqlList = array();
		
		foreach ($this->conditionals as $index=>$conditionInfo) {
		  if($conditionInfo=='') {continue;}
			$fieldName = $conditionInfo['name'];
          $fieldSql='';
          $fieldGlue = '';
			$field = $moduleFieldList[$fieldName];
			if(empty($field)) {
				continue;
			}
		
           
			$valueSqlList = $this->getConditionValue($conditionInfo['value'],
				$conditionInfo['operator'], $field);
               
			if(!is_array($valueSqlList)) {
				$valueSqlList = array($valueSqlList);
			}
           /**
			 * 创建人连接信息混乱，有的地方是users1，有的地方是users2，无法具体做出判断
			 * 在此处直接查询连接信息中是否有users1字段，如果有，则链接信息为users1
			 * @reason 0012349 序时簿数据分类中，无法根据创建人 过滤出数据。
			 * @author Tujt 2014-11-10
			 */
			global $join_user_arr;
			$creator_where_b = false;
			if(!empty($this->fromClause) && strpos($this->fromClause,'ld_users1') > -1){
				$creator_where_b = true;
			}
			foreach ($valueSqlList as $valueSql) {
				if (f_in_array($fieldName, $this->referenceFieldList)) {
					$moduleList = $this->referenceFieldInfoList[$fieldName];
					if(f_in_array('Users',$moduleList)){
						$moduleList = f_array_unique($moduleList);
					}
					foreach($moduleList as $module) {
						$nameFields = $this->moduleNameFields[$module];
						$nameFieldList = explode(',',$nameFields);
						$meta = $this->getMeta($module);
						$columnList = array();
						foreach ($nameFieldList as $column) {
							if($module == 'Users') {
								$instance = CRMEntity::getInstance($module);
								$referenceTable = $instance->table_name;
								
								$column = 'last_name';
								if(isset($join_user_arr[$fieldName])){
									/**
									 * 判断当前字段是否在join_user_arr数组中
									 * @reason 0012349 序时簿数据分类中，无法根据创建人过滤出数据
									 * @author Tujt 2014-11-11
									 */
									$referenceTable = $join_user_arr[$fieldName]['tab'];
								}else{
									if(count($this->ownerFields) > 0 ||
											$this->getModule() == 'Quotes') {
										if($creator_where_b) $referenceTable .= '1';
										else $referenceTable .= '2';
									}
								}
							}
                             else {
								$referenceField = $meta->getFieldByColumnName($column);
								$referenceTable = $referenceField->getTableName();
							}
                           
							if(isset($moduleTableIndexList[$referenceTable])) {
								$referenceTable = "$referenceTable$fieldName";
							}
							$columnList[] = "$referenceTable.$column";
                            
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
				}
                elseif ($field->getUIType()==251)//转出账户
                {
                    $fieldSql.=' ld_obank.accountname '.$valueSql;
                    if($conditionInfo['operator']=='isnull'){
                        $fieldSql.=' or ld_obank.accountname IS NULL ';
                    }
                   
                } 
                elseif ($field->getUIType()==252)//转入账户
                {
                    $fieldSql.=' ld_ibank.accountname '.$valueSql;
                    if($conditionInfo['operator']=='isnull'){
                        $fieldSql.=' or ld_ibank.accountname IS NULL ';
                    }
                   
                } 
                elseif (!empty($this->ownerFields) && in_array($fieldName, $this->ownerFields)) {
				
                    $concatSql="ld_users.last_name";
                    $fieldSql .= "$fieldGlue trim($concatSql) $valueSql ";
                    if($conditionInfo['operator']=='isnull'){
                            $fieldSql.=' or '.trim($concatSql).' IS NULL ';
                    }
				} 
               else {
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
		    
			$fieldSqlList[$index] = '('.$fieldSql.')';
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
			$sql .= '( '.$groupSql.' )';
		}
        $strfilesql = $this->createStdFilterSql;
        if(!empty($strfilesql))
             $sql .= ' and ( '.$strfilesql.') ';
	   
    	$sql .= "  AND $baseTable.$baseTableIndex > 0";
        
		//$this->whereClause = $sql;
		return $sql;
	}
    
    public function getQuery()
    {
        return $this->getFromClause().$this->getWhereClause();
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
	private function getConditionValue($value, $operator, $field) 
    {
        global $current_user,$currentModule,$app_strings;
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
            if($currentModule=='Reminds'){
    			 $current_userid=$current_user->id;
                 $current_dates= date('Y-m-d H:i');
    			 $var_arr=array('current_userid','current_dates--:::');
    			 if(in_array($value,$var_arr)){	
    			     $value=str_replace('-','',$value);
                     $value=str_replace(':','',$value);
    			     $value=$$value;
                     $date = new DateTimeField($value);
					 $value = $date->getDisplayDateTimeValue();
    			 }
			 }
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
    	private function isRelativeSearchOperators($operator) {
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
		 */
		private function createStdFilterSql(){
			if(!empty($this->stdFilter)){
				$value = array();
				if(!empty($this->stdFilter['columnname'])) {
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
		public function addConditionGlue($glue){
			$this->groupInfo .= " $glue ";
		}
      private function createAdvFilterSql()
      {
        	if(!empty($this->advFilter)) {
			foreach ($this->advFilter as $groupindex=>$groupcolumns) {
				$filtercolumns = $groupcolumns['columns'];
				if(count($filtercolumns) > 0) {
					
					foreach ($filtercolumns as $index=>$filter) {
						$name = explode(':',$filter['columnname']);
						if(empty($name[2]) && $name[1] == 'crmid' && $name[0] == 'ld_crmentity') {
							$name = $this->getSQLColumn('id');
						} else {
							$name = $name[2];
						}
						$this->addCondition($name, $filter['value'], $filter['comparator']);
                        $columncondition = $filter['column_condition'];
						if(!empty($columncondition)) {
							$this->addConditionGlue($columncondition);
						}
					}
				
				}
			}
		}
      }
      	public function addCondition($fieldname,$value,$operator,$glue= null,$newGroup = false,
			$newGroupType = null)
         {
      
		$conditionNumber = $this->conditionInstanceCount++;
		$this->groupInfo .= "$conditionNumber ";
		$this->whereFields[] = $fieldname;
		$this->reset();
       
        if($this->getConditionalArray($fieldname,
				$value, $operator)!='')
		$this->conditionals[$conditionNumber] = $this->getConditionalArray($fieldname,
				$value, $operator);
                 
                
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
    
   	private function getConditionalArray($fieldname,$value,$operator) {
		if(is_string($value)) {
			$value = trim($value);
		} elseif(is_array($value)) {
			$value = array_map(trim, $value);
		}
		return array('name'=>$fieldname,'value'=>$value,'operator'=>$operator);
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