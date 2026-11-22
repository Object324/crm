<?php
/**
 * edit:can
 * date:20140223
 * reason:多附件
/**
 * Description of QueryGenerator
 *
 * @author MAK
 */
class cls_QueryGenerator  extends QueryGenerator{

    private $moduleColArray=array();
    
    public $MainTableColumn=array();//列头涉及主表
    public  $whereMainTable=array();//查询涉及主表
  
    private $ld_attachmentdetails='';
	private $ld_attachmentdetailscf='';
    private $fieldlabel_arr = array();
   
   
	public function __construct($module, $user,$customerview='',$productDetails='') {
		parent::__construct($module, $user,$customerview);
	}
  
    public function getPopupSelectColumn()
    {
        return $this->popuselectcolumn;
    }
    public function getPopupfromclause()
    {
        return $this->popufromclasuse;
        
    }
    
	public function reset() {
		$this->fromClause = null;
		$this->whereClause = null;
		$this->columns = null;
		$this->query = null;
	}

	
    public function getPropertyFields()
    {
        return $this->productDetails->fields_property;
    }

    public function getModuleFieldList()
    {
          if(empty($this->moduleFieldList))
          {
            $this->moduleFieldList=$this->fieldobj->getModuleFields();
          }
          return $this->moduleFieldList;
    }
	

	public function getConditionalWhere() {
		return $this->conditionalWhere;
	}
    
	public function getAdvancedSearchCriteriaList($advft_criteria, $advft_criteria_groups, $module='',$queryGenerator=null){
		global $currentModule, $current_user,$adb;
		if(empty($module)) {
			$module = $currentModule;
		}
		$focus = CRMEntity::getInstance($module);
		$advfilterlist = array();
		Crm_load_class_file("CommonView",'modules/CustomView');
		$datetimestr=CommonView::stdFilterDateTimeStr("");//获取日期，时间本年，明年等下拉框字符串
		//  $detail_module_fields=$focus->fieldobj->getModuleFields();
		if(!empty($queryGenerator)){
			if(get_file_address($module,'ProductDetails')||get_file_address($module,'VendorsDetails')||get_file_address($module,'ContactsDetails'))
				$productModuleFields=$queryGenerator->productDetails->getModuleFields();
			else if(get_file_address($module,$module.'DetailFieldsHtml'))
			{
				$productModuleFields=$queryGenerator->TabDetails->getModuleFields();
			}
		}
		if(!empty($advft_criteria)){
			foreach($advft_criteria as $column_index => $column_condition) {
				if(empty($column_condition)) continue;

				$adv_filter_column = $column_condition["columnname"];
				$adv_filter_columns=explode(":",$adv_filter_column);
				$columnname = $adv_filter_columns[1];            
				$fieldname=$adv_filter_columns[2];            
				
				$adv_filter_comparator = $column_condition["comparator"];
				$adv_filter_value = $column_condition["value"];
				$adv_filter_column_condition = $column_condition["columncondition"];
				$adv_filter_groupid = $column_condition["groupid"];
				
				$criteria = array();
				$criteria['columnname'] = $adv_filter_column;
				$criteria['comparator'] = $adv_filter_comparator;
				$criteria['search_comparator'] = $adv_filter_comparator;
				if(array_key_exists($criteria['comparator'],$datetimestr))
				{
					
						$temp_val[0]=$datetimestr[$criteria['comparator']][0];
						$temp_val[1]=$datetimestr[$criteria['comparator']][1];
						$adv_filter_value=implode(",",$temp_val);
						$criteria['comparator']='bw';
				}
			
				$criteria['value'] = $adv_filter_value;
			
			
				$criteria['column_condition'] = $adv_filter_column_condition;

				$advfilterlist[$adv_filter_groupid]['columns'][] = $criteria;
			}
		}

		foreach($advft_criteria_groups as $group_index => $group_condition_info) {
			if(empty($group_condition_info)) continue;
		   if(empty($group_condition_info["groupcondition"]))continue;
			if(empty($advfilterlist[$group_index])) continue;
			$advfilterlist[$group_index]['condition'] = $group_condition_info["groupcondition"];
			$noOfGroupColumns = count($advfilterlist[$group_index]['columns']);
			if(!empty($advfilterlist[$group_index]['columns'][$noOfGroupColumns-1]['column_condition'])) {
				$advfilterlist[$group_index]['columns'][$noOfGroupColumns-1]['column_condition'] = '';
			}
		}
		//0028200: 序时簿列表，查找->高级查找，删除一个组合，再新增两个组合进行查找时，结果无法查找到数据
		$keys = array_keys($advfilterlist);
		if(!empty($advfilterlist[$keys[sizeof($keys)-1]]['condition'])) {
			$advfilterlist[$keys[sizeof($keys)]-1]['condition'] = '';
		}
		//28205: 序时簿列表，查找->高级查找，删除组合再新增新组合进行查找，进入单据明细界面再返回列表，组合查询被删除了
		$tmpindex=1;
		foreach($advfilterlist as $index=>$groupinfo)
		{
			if(empty($groupinfo))
			{

				continue;
			}

			$tmp_advfilterlist[$tmpindex]=$groupinfo;
			$tmpindex++;
		}

  
		return $tmp_advfilterlist;
	}
	public function addUserSearchConditions($input) {	   
		$json = new Zend_Json();
		$advft_criteria = $_REQUEST['advft_criteria']??'';
		if(!empty($advft_criteria))	$advft_criteria = $json->decode($advft_criteria);
		//editor:gyq_107 reason:企业微信即时库存查询报表,->decode无法解析手写的json  2019/4/4 16:16
		if(empty($advft_criteria)) $advft_criteria = json_decode((string)$_REQUEST['advft_criteria'],true);

		$advft_criteria_groups = $_REQUEST['advft_criteria_groups']??'';
		if(!empty($advft_criteria_groups))	$advft_criteria_groups = $json->decode($advft_criteria_groups);
        if(empty($advft_criteria_groups)) $advft_criteria_groups = json_decode((string)$_REQUEST['advft_criteria_groups'],true);
		if(empty($advft_criteria) || count($advft_criteria) <= 0) {
			return ;
		}
		$advfilterlist = $this->getAdvancedSearchCriteriaList($advft_criteria, $advft_criteria_groups, $this->getModule(),$this);
		if(empty($advfilterlist) || count($advfilterlist) <= 0) {
			return ;
		}
		if($this->conditionInstanceCount > 0) {
			 
			$this->startGroup(self::$AND);
		} else {
			$this->startGroup('');
		}
		$groupsqlIndex=0;
		foreach ($advfilterlist as $groupindex=>$groupcolumns) {
			$filtercolumns = $groupcolumns['columns'];
	  
			if(count($filtercolumns) > 0) {
				$this->startGroup('');
				foreach ($filtercolumns as $index=>$filter) {
			
					$name = explode(':',$filter['columnname']);
					$tablename=$name[0];
					$fieldlabels = explode('_',$name[3]);
					$this->fieldlabel_arr[] = $fieldlabels[1];
					if(empty($name[2]) && $name[1] == 'crmid' && $name[0] == 'ld_crmentity') {
						$name = $this->getSQLColumn('id');
					} else {
						$name = $name[2];
					}
					$this->addCondition($name, $filter['value'], $filter['comparator'],$tablename);
					$columncondition = $filter['column_condition'];
					if(!empty($columncondition)) {
						$this->addConditionGlue($columncondition);
					}
				}
				$this->endGroup();
				$groupConditionGlue = $groupcolumns['condition'];
				 $groupsqlIndex++;
				if($groupsqlIndex<sizeof($advfilterlist))
				{
				  
					$this->addConditionGlue($groupConditionGlue);//高级查询组合有and和or,edit:can
				}

			}
		}
		$this->endGroup();
	}
	public function addCondition($fieldname,$value,$operator,$tablename= null,$newGroup = false,
			$newGroupType = null) {
			 
		if($value==''&& $operator!="isnotnull"&&$operator!='isnull')//34443: 单据列表界面>基本查找：应该允许关键字为空时进行搜索。预期：当关键字为空时进行搜索默认为搜索全部。
        return ;
		$conditionNumber = $this->conditionInstanceCount++;
		$this->groupInfo .= "$conditionNumber ";
       // echo $fieldname;
       // echo $this->groupInfo."aa<br>";
		$this->whereFields[] = $fieldname;
		$this->reset();
        if($this->getConditionalArray($fieldname,$value, $operator)!='')
			$this->conditionals[$conditionNumber] = $this->getConditionalArray($fieldname,$value, $operator,$tablename);
                 
                
	}
	public function getConditionSpecial($value, $operator, $field)
    {
		return '';
	}
	public function getConditionSql($value, $operator,$fieldname)
    {
		$sqlOperator=QueryGenerator::createSqlOperator($operator,$value);
		if(in_array($fieldname,array('unit_price','inventory_qty','qtyearly',''))){
			return "$sqlOperator $value";
		}else{
			return "$sqlOperator '$value'";
		}
	}
	public function getConditionDateSql($value, $operator, $field)
    {
        
        $db = PearDatabase::getInstance();
        if(($operator == 'between' || $operator == 'bw' ||array_key_exists($operator,$this->datetimestr)) && !is_array($value)) {
			$valueArray = explode(',' , $value);
		}
		else if(is_array($value)) {
			$valueArray = $value;
		} else{
			$valueArray = array($value);
		}
		$sql = array();
		if($operator == 'between' || $operator == 'bw'||array_key_exists($operator,$this->datetimestr)) {
			
				
				$sql[] = "BETWEEN ".$db->quote($valueArray[0])." AND ".
							$db->quote($valueArray[1]);

			return $sql;
		}
    }
	public function getWhere($moduletype){
		$this->moduletype = $moduletype;
		return $this->getWhereClause();
	}
    public function getWhereClause() {
		global $current_user;
		$sql = '';
		$baseTable = $this->moduleobj->table_name;
		$moduleTableIndexList = $this->moduleobj->tab_name_index;
		$this->moduleFieldList = $this->fieldobj->getModuleFields();
		$baseTableIndex = $moduleTableIndexList[$baseTable];
		$groupSql = $this->groupInfo;

		$fieldSqlList = array();
		crm_load_class_file('cls_query_where','include/QueryGenerator/SqlWhere');
		foreach ($this->conditionals as $index=>$conditionInfo) {
			if($conditionInfo=='') {continue;}
			$fieldSql = '(';
			$fieldGlue = '';
			$origncolumnname= $columnName = $conditionInfo['name'];
			if($origncolumnname == 'ware_stock_no'){
				$origncolumnname = 'bill_no';
			}else if($origncolumnname == 'createdate'){
				$origncolumnname = 'bill_date';
			}else if($origncolumnname == 'warhouse'){
			    //editor:gyq_20191216 reason:0038912: （kfbcrm）常用报表->库存流水账：高级查询，查询条件“仓库为空值”时，查询不到数据（需要补丁）
				$origncolumnname = 'ifnull(name,\'\')';
				//0038738: （kfbcrm）即时库存查询报表：高级查询，按仓库等于或包含关键字查询数据时，数据显示不对（需要补丁）
            }else if($origncolumnname == 'wareid' && $this->moduletype != 'InventoryLedger'){
			    //editor:gyq_20191204 0038738: （kfbcrm）即时库存查询报表：高级查询，按仓库等于或包含关键字查询数据时，数据显示不对（需要补丁）
                $origncolumnname = 'ifnull(house.name,\'\')';
			}else if($origncolumnname == 'weight'){
				$origncolumnname = 'inventory_qty';
			}else if($origncolumnname == 'qtyearly'){
				if($this->fieldlabel_arr[$index] == '待入库数量'){
					$origncolumnname = 'dairu_qty';
				}else if($this->fieldlabel_arr[$index] == '待出库数量'){
					$origncolumnname = 'daichu_qty';
				}else if($this->fieldlabel_arr[$index] == '安全库存差额'){
					$origncolumnname = 'cha_qty';
				}
			}
			 
            $origntablename=$conditionInfo['tablename'];
			$valueSqlList = $this->getConditionValue($conditionInfo['value'],$conditionInfo['operator'],$origncolumnname);
			if(!is_array($valueSqlList)) {
				$valueSqlList = array($valueSqlList);
			}
			foreach ($valueSqlList as $valueSql) {
				if($this->moduletype == 'InventoryLedger') {
                    //editor:gyq_122 reason:除了这三个字段，其他字段均属于产品及产品自定义表  2019/6/14 14:13
                    if($origncolumnname=='bill_date'||$origncolumnname=='bill_no'||$origncolumnname=='batchtext'){
                        $fieldSql.='a.'.$origncolumnname . ' ' . $valueSql;
                    }else{
                        //editor:gyq_20191224 039001: （kfbcrm）常用报表->库存台账、即时库存查询：高级查询，按照“仓库为空值”查询条件查询时，查询不到数据（需要补丁）
                        if($columnName=='wareid'){
                            $fieldSql.=' (CASE WHEN a.wareid=0 THEN \'\' '.$valueSql.' ELSE ifnull(a.wareid,\'\')  '.$valueSql.' END) ';
                        }else{
                            $fieldSql.=$origntablename.'.'.$origncolumnname . ' ' . $valueSql;
                        }
                    }
                }else
					$fieldSql.=$origncolumnname . ' ' . $valueSql;
				$fieldGlue=' OR ';
			}
           
			$fieldSql .= ')';
			$fieldSqlList[$index] = $fieldSql;
		}
		$groupSql = $this->makeGroupSqlReplacements($fieldSqlList, $groupSql);
		if($this->conditionInstanceCount > 0) {
			$this->conditionalWhere = $groupSql;//$groupSql是视图的查询条件
			$sql .= $groupSql;
            
		}
		return $sql;
	}

}
?>