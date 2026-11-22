<?php
/**
 * edit:chj
 * date:2016-04-26
 * reason:模块明细（除产品明细模块以外的模块明细）
/**
 * Description of QueryGenerator
 *
 * @author MAK
 */
class TabDetailQueryGenerator extends QueryGenerator {

    public  $TabDetails;
    private $mainFromClause;// from 主表数组
    private $moduleColArray=array();
    
    public $whereMainTable=array();//查询涉及主表
    public $whereDetailTable=array();//查询设计的明细表
    public  $ModuleTableDetailColumn=array();//列头所涉及到的明细相关表
    private $MainTableColumn=array();//列头涉及主表
    
    private $ld_products='ld_products';
	private $ld_productcf='ld_productcf';
    public $moduleTableDetail;//子类用到了该属性 所以改成public zxm 20230705
    public $moduleTableDetailscf;
	private $moduleTablescf;
	public function __construct($module, $user,$customerview='',$productDetailsobj='') {
	    $this->db = PearDatabase::getInstance();
		parent::__construct($module, $user,$customerview);
	    if(!empty($productDetailsobj))
            $this->TabDetails=$productDetailsobj;
		else
            {
                crm_load_class_file("TabDetails",'include/TabDetailFields');
                $this->TabDetails=new TabDetails($module);
            }
		$this->moduleTableDetail = $this->moduleobj->Detail_table;
		$this->moduleTableDetailscf = $this->moduleobj->Detail_table_scf;
		$this->moduleTablescf = $this->moduleobj->customFieldTable[0];
        $this->TabDetails->querygenerator=$this;
        $this->product_field_obj=Field::getInstance('Products',$this->db);
        $this->product_obj=CRMEntity::getInstance('Products');
		//$this->TabDetails->setCustomView($customerview);//分类
	}
 public function getCustomViewFieldObj($tablename,$fieldname)
    {
            $moduleFields=$this->fieldobj->getModuleFields();
            $productFields=$this->TabDetails->getModuleFields();
            if($tablename==$this->moduleobj->Detail_table||$tablename==$this->moduleobj->Detail_table_scf)
            {
                 $objfield=$productFields[$fieldname];
            }
            else
            //判断当前模块字段是否在主模块可显字段中
            $objfield=$moduleFields[$fieldname];
             return $objfield;
    }
	
    public function getPropertyFields(){
        return $this->TabDetails->fields_property;
    }
	
	public function getModuleFieldList(){
		if(empty($this->moduleFieldList)){
			$this->moduleFieldList=$this->fieldobj->getModuleFields();
		}
		return $this->moduleFieldList;
    }
    /**
     * reason:获取查询列头中主表列头数
     * */
	public function getMainColumnCount(){
		return $this->TabDetails->getRowCount();
	}
    public function iswhereDetailTable()
    {
           //如果where查询条件没有明细表，则page_list_qquery不需要groupby distinct 
            return 'yes';
           
    }
    public function getDetailWhere($field,$conditionInfo,$valueSql)
    {
        global $current_user;
        $fieldName=$field->getFieldName();
        $origntablename=$field->getTableName();
        $origncolumnname=$field->getColumnName();
        $baseTable=$this->moduleobj->table_name;
        $this->whereDetailTable[$this->moduleobj->Detail_table]= $this->moduleobj->Detail_table.' on '.$this->moduleobj->Detail_table.".".$this->moduleobj->Detail_table_index.'='.$this->moduleobj->table_name.".".$this->moduleobj->table_index;
      //  echo globalStatic::$root_directory.'include/QueryGenerator/SqlWhere/TabDetailWhere/DetailWhere/cls_query_'.strtolower($field->getFieldType()).'.php';

        if($field->getTableName()==$this->moduleTableDetailscf)
        {
            $this->whereDetailTable[$this->moduleTableDetailscf]=$this->moduleTableDetailscf.' on '.$this->moduleTableDetailscf.'.'.$this->moduleobj->Detail_table_id.'='.$this->moduleTableDetail.'.'.$this->moduleobj->Detail_table_id;
            
        }
        else{
            if($field->getTableName()==$this->ld_products&&!array_key_exists($this->ld_products,$this->whereDetailTable))
			 {
				 $this->whereDetailTable[$this->ld_products]=" ld_products on ld_products.productid=".$this->moduleobj->Detail_table.".productid ";
			 }
			 else if($field->getTableName()==$this->ld_productcf&&!array_key_exists($this->ld_productcf,$this->whereDetailTable))
			 {
			     if(!array_key_exists($this->ld_products,$this->whereDetailTable)){
			         $this->whereDetailTable[$this->ld_products]=" ld_products on ld_products.productid=".$this->moduleobj->Detail_table.".productid ";
			     }
			     $this->whereDetailTable[$this->ld_productcf]=' ld_productcf on ld_productcf.productid='.$this->moduleobj->Detail_table.'.productid';
			 }
        }
		//关联选择单据查询
		if($field->getBigType() == 'reference'){
			$referencemodule = $field->getReferenceModule();
			if(!empty($referencemodule)){
				$referencemodule_focus = CRMEntity::getInstance($referencemodule);
                
                $entityarray = getEntitynameInfo(getTabid($referencemodule));
			     $tmptabname = $entityarray['tablename'];//模块主表
			     if($tmptabname!=$referencemodule_focus->table_name)
                 {
                    $tmptableindex=$referencemodule_focus->tab_name_index[$tmptabname];
                     $this->whereDetailTable['detail_'.$tmptabname]=$tmptabname.
                    ' as detail_'.$tmptabname.' on detail_'.$tmptabname.'.'
                    .$tmptableindex.'='.$origntablename.'.'.$origncolumnname;
                 }
                 else
				    $this->whereDetailTable['detail_'.$referencemodule_focus->table_name]=$referencemodule_focus->table_name.
                    ' as detail_'.$referencemodule_focus->table_name.' on detail_'.$referencemodule_focus->table_name.'.'
                    .$referencemodule_focus->table_index.'='.$origntablename.'.'.$origncolumnname;
			}
		}
       	if($field->getColumnName()=='conversion_rate'){
			$ratetablename=$field->getTableName();
			$fieldSql .= "$fieldGlue truncate($ratetablename.conversion_rate,2) $valueSql";
		}else if($field->getFieldType()=='SelectCurrency'){//币种
			$astablename='currency_'.$fieldName;
			global $app_currency_strings;

			if($conditionInfo['operator']=='isnull'){
				$fieldSql .= "$fieldGlue  ($astablename.id=0 or $astablename.id is null or $origntablename.$origncolumnname=0|| $origntablename.$origncolumnname is null or $origntablename.$origncolumnname="."'')";

			}else if($conditionInfo['operator']=='isnotnull'){
				$fieldSql .= " ( $astablename.id>0 and $origntablename.$origncolumnname>0)";
			
			   
			}else{
				$fieldSql.=" $origntablename.$origncolumnname in (select ld_currency_info.id from ld_currency_info left join 
								ld_currencies on ld_currencies.currency_code=ld_currency_info.currency_code where ld_currencies.description $valueSql )  ";
			}
			
		}
		else if(file_exists(globalStatic::$root_directory.'include/QueryGenerator/SqlWhere/TabDetailWhere/DetailWhere/cls_query_'.strtolower($field->getFieldType()).'.php'))
		{

			crm_load_class_file('cls_query_'.strtolower($field->getFieldType()),'include/QueryGenerator/SqlWhere/TabDetailWhere/DetailWhere');
		   $classname='cls_query_'.strtolower($field->getFieldType());
		 //  echo $classname;
			$whereobj=new $classname($this->module,$field,$conditionInfo,$this->moduleobj,$valueSql);
			$whereobj->getWhereCondition();
			$fieldSql.= $fieldGlue.$whereobj->fieldSql;
		   if(!empty($whereobj->where_jointablename))
		   {
					$leftjointablename=$whereobj->where_jointablename;
					 $this->whereDetailTable[$whereobj->where_jointablename]=$whereobj->whereFieldTable;
		   }
				  
			//$this->whereProductTable[$this->moduleobj->Detail_table]= $this->moduleobj->Detail_table.' on '.$this->moduleobj->Detail_table.".".$this->moduleobj->Detail_table_id.'='.$this->moduleobj->table_name.".".$this->moduleobj->table_index;
			
		}
		else {
			 

				if($conditionInfo['operator']=='isnull'&&($field->getFieldDataType()=='datetime'||$field->getFieldDataType()=='date'))
				 {
						//17177: 联系记录模块下，创建数据分类有误
						$fieldSql .= " (DATE_FORMAT($origntablename.$origncolumnname,'%Y-%m-%d')<='1600-01-01' or $origntablename.$origncolumnname is null or $origntablename.$origncolumnname='')";
				 }
				 else if($conditionInfo['operator']=='isnull'&&$this->isNumericType($field->getFieldDataType()))
				 {
						$fieldSql .= " ($origntablename.$origncolumnname=0 or $origntablename.$origncolumnname is null or $origntablename.$origncolumnname="."''".")";
				 }
				 elseif($conditionInfo['operator']=='isnotnull'&&($field->getFieldDataType()=='datetime'||$field->getFieldDataType()=='date'))
				 {
						//17177: 联系记录模块下，创建数据分类有误
						$fieldSql .= " (DATE_FORMAT($origntablename.$origncolumnname,'%Y-%m-%d')>'1600-01-01')";
				}
				else if($conditionInfo['operator']=='isnotnull'&&$this->isNumericType($field->getFieldDataType()))
				{
						$fieldSql .= " ($origntablename.$origncolumnname>0 or $origntablename.$origncolumnname is not null or $origntablename.$origncolumnname<>"."''".")";
				}else{

					//基本查询源单查询
					if(($field->getTableName() == $this->moduleTableDetail || $field->getTableName() == $this->moduleTableDetailscf) && $field->getFieldType() == 'SelectSource'){
						$fieldSql .= $field->getTableName().'.entitytype_value '.$valueSql;
					}else if(  $field->getBigType() == 'reference'){//引用字段 在自定义表
						$referencemodule = $field->getReferenceModule();
						if(!empty($referencemodule)){
							$entityarray = getEntitynameInfo(getTabid($referencemodule));
							$tabname = $entityarray['tablename'];//模块主表
							$tabfieldname = $entityarray['fieldname'];//模块链接字段
							$referencemodule_focus = CRMEntity::getInstance($referencemodule);
							$fieldSql .= 'detail_'.$tabname.'. '.$tabfieldname.' '.$valueSql;
						}
					}
                    else if( $field->getBigType() == 'entitytype')
                    {
                        $languageType= getLanguageType($current_user);
                        $fieldSql.=  $field->getTableName().".entitytype  in   (select ld_tab.name  from ld_tab INNER JOIN ld_tranlabel on 
                                            ld_tranlabel.Relateid=ld_tab.tabid
                                            where    ld_tranlabel.trantable='ld_tab'  
                                            and ld_tranlabel.fieldlabel $valueSql   group by ld_tab.name )";

                    }
                    else{
						$fieldSql .=$field->getTableName().'.'.$field->getColumnName().' '.$valueSql;
					}
					
					if($conditionInfo['operator']=='isnull'){
						$fieldSql.=' or '.$field->getTableName().'.'.$field->getColumnName().' IS NULL ';
					}
					//chj 2021/5/27 46087: 闽发铝业（http://210.13.216.146:85/crm [^]）销售业绩单-高级查找：客户名称为空。无法筛查（详情见附件）
					if($field->getTableName() == $this->moduleTableDetail && $field->getBigType() == 'reference'){
						if($conditionInfo['operator']=='isnull'){
							$fieldSql.=' or '.$field->getTableName().'.'.$field->getColumnName().' = 0 ';
						}else if($conditionInfo['operator']=='isnotnull'){
							$fieldSql.=' or '.$field->getTableName().'.'.$field->getColumnName().' > 0 ';
						}
					}
					
				}
		}

		return $fieldSql;
    }
    public function getMainWhere($field,$conditioninfo,$valueSql)
    {
        
          if($field->getColumnName()=='conversion_rate')
          {
                   
                     $ratetablename=$field->getTableName();
                    return  $fieldSql .= " truncate($ratetablename.conversion_rate,2) $valueSql";
          }
          else 
            return     parent::getMainWhere($field,$conditioninfo,$valueSql);
    }
    public function getWhereClause() {
		global $current_user;
		if(!empty($this->query) || !empty($this->whereClause)) {
			return $this->whereClause;
		}
		$deletedQuery = $this->moduleobj->getEntityDeletedQuery();
		$sql = '';

        $related_module = vtlib_purify($_REQUEST['related_module']);
		if(!empty($deletedQuery)) {
			$sql .= " WHERE $deletedQuery";
		}
		if($this->conditionInstanceCount > 0 && $related_module != 'trends') {
			$sql .= ' AND ';
		} elseif(empty($deletedQuery)) {
			$sql .= ' WHERE ';
		}
		$baseTable = $this->moduleobj->table_name;
		$moduleTableIndexList = $this->moduleobj->tab_name_index;
		$baseTableIndex = $moduleTableIndexList[$baseTable];
		$groupSql = $this->groupInfo;
       
		$fieldSqlList = array();
		 crm_load_class_file('cls_query_where','include/QueryGenerator/SqlWhere');

		foreach ($this->conditionals as $index=>$conditionInfo) {
			$fieldSql=$this->setFieldSql($conditionInfo);
            if(!empty($fieldSql))
			 $fieldSqlList[$index] = $fieldSql;
		}

		$this->whereProductTable=$this->whereDetailTable;
       
		$groupSql = $this->makeGroupSqlReplacements($fieldSqlList, $groupSql);
		if($this->conditionInstanceCount > 0 && $related_module != 'trends') {
			$this->conditionalWhere = $groupSql;//$groupSql是视图的查询条件
            $this->wherecondition=$groupSql;
			$sql .= $groupSql;
            
		}
     
		$sql .= " AND $baseTable.$baseTableIndex > 0";
        //数据分类查询空值，加上基本查询是有问题，所以这样修改
        $sql=str_replace(DATACATEGORYSEACHEMPTYVALUE,'',$sql);
       	//zkt 列表界面、选择产品界面增加树结构显示
        if(isset($_REQUEST['isshowModuleListTree'])&&$_REQUEST['isshowModuleListTree']=='yes')
        {
            
            $modulequery = $this ->getModuletreelistconditonquery();
            $sql .= $modulequery;
        }
		$this->whereClause = html_entity_decode($sql);

		return $sql;
	}
   public function setFieldSql($conditionInfo)
   {
            if($conditionInfo=='')return '';
			if(strtolower($conditionInfo['tablename'])==strtolower($this->moduleTableDetail)
            ||strtolower($conditionInfo['tablename'])==strtolower($this->moduleTableDetailscf)
               ){
				$modulefield=$this->TabDetails->getModuleFields();
                
				$field=$modulefield[$conditionInfo['name']];
				if($field->getFieldType() == 'SelectSource'){
					$conditionInfo['name'] = 'entitytype_value';
				}
                
				if($field->getBigType() == 'reference'){
					$referencemodule = $field->getReferenceModule();
					if(!empty($referencemodule)){
						$entityarray = getEntitynameInfo(getTabid($referencemodule));
						$conditionInfo['tablename'] = $entityarray['tablename'];//链接字段表名
						$conditionInfo['name'] = $entityarray['fieldname'];//模块链接字段
					}
				}
				$fieldName=$conditionInfo['name'];
		
			}else {
				if(empty($this->moduleFieldList ))
					$this->moduleFieldList = $this->fieldobj->getModuleFields();
				$fieldName = $conditionInfo['name'];
				$field = $this->moduleFieldList[$fieldName]; 
				//$this->whereMainTable[]=$conditionInfo['tablename'];
    			if(empty($field)) {
    				return '';
    			}
            }
			$fieldSql = '(';
			$fieldGlue = '';
          
			$valueSqlList = $this->getConditionValue($conditionInfo['value'],$conditionInfo['operator'],$field);
			if(!is_array($valueSqlList)) {
				$valueSqlList = array($valueSqlList);
			}
       
			if($field instanceof TabDetailToolFields)
            {
                foreach ($valueSqlList as $valueSql) {
                        $fieldSql.=$fieldGlue.$this->getDetailWhere($field,$conditionInfo,$valueSql);
                        $fieldGlue=' OR';
                    }
            }
            else if($field instanceof ProductFields)
            {
                foreach ($valueSqlList as $valueSql) {
                        $fieldSql.=$fieldGlue.$this->getDetailWhere($field,$conditionInfo,$valueSql);
                        $fieldGlue=' OR';
                    }
            }    
			else 
            {
                foreach ($valueSqlList as $valueSql) {
			  
    			     $fieldSql.=$fieldGlue.$this->getMainWhere($field,$conditionInfo,$valueSql);
                     $this->whereMainTable=$this->whereFieldTables;
                     $fieldGlue=' OR';
			     }
            }

			$fieldSql .= ')';
            return $fieldSql;
            
   }
    /**
     * reason:获取列头,同时获取列头查询涉及的表
     * */
    function getSelectColumn($tabid){

         if(!empty($this->columns)){
            return $this->columns;
         }
        $moduleFields = $this->fieldobj->getModuleFields();//lingdangcrmobjectmeta.php
        $accessibleFieldList = array_keys($moduleFields);//获取当前用户能够看见的字段
        $accessibleFieldList[]='id';
      
		$selectSql =trim($this->TabDetails->getSelectColumn($tabid),',');
		$basetable = $this->moduleobj->table_name;
		$selectSql = strtr($selectSql,array('ld_crmentity.'=>$basetable.'.'));
        $productFields=$this->TabDetails->getModuleFields();
        $columnlist=array_filter(explode(',',$selectSql));
        $finalcolumnlist=array();
        if($basetable=='ld_cashbill'||$basetable=='ld_sendcashbill')
            $finalcolumnlist[]="$basetable.entitytype";
        for($i=0;$i<sizeof($columnlist);$i++)
        {
             $coltables=explode('.',$columnlist[$i]);
             
            /*  if(in_array($coltables[0],$this->product_obj->tab_name))
             {

                $productcolumn=$coltables[1];
                $finalcolumnlist[]=$coltables[0].'.'.$productcolumn . ' as tabdetail_'.$coltables[1];//主表和产品表都有负责人和创建人
                $this->product_detail_columns[]=$productcolumn;
                $this->inventory_columns[]=$coltables[1];
               
                $this->ModuleTableDetailColumn[$coltables[0]]=$coltables[0];
                continue;
             } */
            
             if($coltables[0] == $this->moduleTableDetail || $coltables[0] == $this->moduleTableDetailscf
             ||in_array($coltables[0],$this->product_obj->tab_name)){
                $field=$productFields[$coltables[1]];

                if($field&&$field->getFieldType()=='Amount'&&$productFields['currency_id'])
                {
                    $fieldcurrencyobj=$productFields['currency_id'];
                    $this->ModuleTableDetailColumn[$fieldcurrencyobj->getTableName()]=$fieldcurrencyobj->getTableName();
                   
                    $finalcolumnlist[]=$fieldcurrencyobj->getTableName().'.currency_id as tabdetail_currency_id';//防止主表和明细存在相同的字段
                }
                if($field&&$field->getFieldType()=='SourceAmount'&&($productFields['source_total']||$productFields['pay_amount']||$productFields['received_amount']))
                {
                    $finalcolumnlist[]=$this->moduleobj->Detail_table.'.currency_id as tabdetail_currency_id';//防止主表和明细存在相同的字段
                }
                if($field&&($field->getBigType()=='image' || $field->getBigType()=='fileattachment')){
                    //ls 2022-06-13 【ID1002721】单据分录定制，增加“图片”字段类型(非产品模块列表页,列表页明细只显示一个图片字段时)
                }else{
                    $finalcolumnlist[]=$coltables[0].'.'.$coltables[1] . ' as tabdetail_'.$coltables[1];//防止主表和明细存在相同的字段
                }

                $this->ModuleTableDetailColumn[$coltables[0]]=$coltables[0];
                 $this->DetailTableColumn[$coltables[0]]=$coltables[0];
                $this->selecttables[$coltables[0]]=$coltables[0];    
               
                continue;
             }
            $fieldinfo=$this->moduleobj->fieldobj->getFieldInfoobjBykey("columnname",$coltables[1]);
            if($fieldinfo&&$fieldinfo->getUIType()==1109)
            {
                continue;
            }
			$finalcolumnlist[]=$coltables[0].'.'.$coltables[1];
			
			$this->MainTableColumn[$coltables[0]]=$coltables[0];
            $this->selecttables[$coltables[0]]=$coltables[0];
        }
	
        
    
        $finalcolumnlist=array_unique($finalcolumnlist);
        $this->columns=implode(',',$finalcolumnlist);
        $baseTable = $this->moduleobj->table_name;
        $baseTableIndex = $this->moduleobj->table_index;
        $this->columns.=', '.$baseTable.'.'.$baseTableIndex;
		if(in_array($this->moduleTableDetail,$this->ModuleTableDetailColumn) || in_array($this->moduleTableDetailscf,$this->ModuleTableDetailColumn)){
			$this->columns.=', '.$this->moduleobj->Detail_table.'.'.$this->moduleobj->Detail_table_id;
		}	
		//判断非产品明细模块是否包含币种,如果包含，则添加币种字段
        if(!empty($moduleFields['currency_id']))
        {
            $fields = $moduleFields['currency_id'];
            if(empty($this->fields['currency_id']) && strpos($this->columns,$fields->getTableName().'currency_id') <= -1){
                $this->columns .= ',' . $fields->getTableName() . '.currency_id';
            }
            if(empty($this->fields['currency_id']) && strpos($this->columns,'conversion_rate') <= -1){
                $this->columns .= ',' . $fields->getTableName() . '.conversion_rate';
            }
            $this->columns .= ',' . $fields->getTableName() . '.currency_symbol';
        }
        //zkt 20231113 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
        crm_load_class_file("cls_fieldSensitiverule", "include/fields");
        $cls_fieldSensitiveruleobj = cls_fieldSensitiverule::getInstance($this->module);
        $this->columns = $cls_fieldSensitiveruleobj->getlistRealtedfieldbyfield($this->columns);
      
        return $this->columns;
    }
  public  function getQuery($popup='',$type='1')
  { 
    return $this->getTabDetailListQuery($type,$popup);
    
  }
    /**
     * edit:can
     * date:20140223
     * reason:获取查询语句
     * $type:1:表示获取分页查询语句
     * $type:2表示获取select和from子句
     * */
    private  function getTabDetailListQuery($type,$popup='')
    {
        global $theme;
        global $current_user,$currentModule;
     
        $limit = "";
        $focus = $this->moduleobj;
        $tab_name = $focus->tab_name;
        $baseTable = $focus->table_name;
        $baseTableIndex = $focus->table_index;
        $tabid = getTabId($this->module);
        $baseTableIndex = $focus->table_index;
        $selectColumn=$this->getSelectColumn($tabid);
        $this->chart_owner="";
        $where=$this->getWhereClause();
        $this->chart_where=$where;
        $fromclause=$this->getFromClause();
		$drop_array=array('Project'=>119);
		/*
		* edit:chj
		* date:2020-07-16
		* reason:客户反馈问题，个人用户：当自定义表单24,作为字段类型：关联选择单据时，数据范围设置全部时，仍然无法查询到数据
		*/
		if($popup=='droppop'&&!is_admin($current_user))//控制面板的页面设置-》设置选择单据的默认值，fieldname在ld_field不存在
        {
            $frommodule = $_REQUEST['frommodule'];
            $fromfocus = CRMEntity::getInstance($frommodule);
            $fieldname = $_REQUEST['fieldname'];
            //editor:gyq_20191202 reason:原生app新增合同订单选择产品报错
            if (!empty($fieldname)) {
				if($_REQUEST['selectrelationfrom']=='entry')
                {
                    $fieldinfo=$fromfocus->detailfieldobj->getFieldInfoobjBykey("columnname",$fieldname);
                }
                else
                    $fieldinfo = $fromfocus->fieldobj->getFieldInfoobjBykey("fieldname", $fieldname);
                //zkt 20231226 BUG0077736 请路总安排，自动分配，客服角色无法选分配标准。
                if(!empty($fieldinfo)){
                    //edit: xll 2023/06/05 XUQIU1001203 相关对象改为选择源单样式，此处为数据范围控制
                    if(strtolower($fieldinfo->getBigType())=='selectsource' || $fieldinfo->getUIType()=='112')
                    {
                        //选择原单
                        crm_load_class_file('cls_OptionModule','include/OptionModule');
                        $frommodule=$_REQUEST['frommodule'];
                        $tabid=getTabid($frommodule);

                        $selectentitytype=$_REQUEST['selectmodule'];
                       if(empty($selectentitytype))
                       {
                        $selectentitytype=$this->moduleobj->module_name;
                       }
                        $option_tabid=getTabid($selectentitytype);
                       $optionmoduleobj= cls_OptionModule::getInstance($frommodule);
                       $options=$optionmoduleobj->getData();
                       $datarang=$options[$tabid][$option_tabid]['datarang'];
                    }else{
                        $datarang = $fieldinfo->getDataRang();//数据查看范围all,permit;
                    }
                }
            }
            if ($datarang == 'permit') {
                $this->chart_owner = $this->getSmOwnerSearchSql;
            }
		}
		else
		{
			$this->chart_owner=$this->getSmOwnerSearchSql;
		}
		
       if($popup=='popup')
       {
       
         $this->SpecialPopup();
        
       }
        /**
        * 默认添加货币币种字段
        * @project PROT58 速度优化：缓存
        * @author Tujt 2014-07-31
        */
        $tablename = $this->moduleobj->table_name;
        if($type==1||$type==4||$type=='groupby')
        {
            
             if($type==1||$type==4)
             $page_list_query="SELECT distinct
            		$baseTable.$focus->table_index
            	FROM
            		$baseTable ";
             else
                $page_list_query="SELECT 
            		$baseTable.$focus->table_index
            	FROM
            		$baseTable ";
            

             $reportertousersql=$this->getReporttoUserSql();//edit:can 20200826 用户界面 汇报人；
             $joinsql='';
             $wherefieldtables=$this->whereFieldTables;
              
              foreach($wherefieldtables as $wheretable=>$leftjoin)
              {
               
                 if($wheretable!=$baseTable&&!empty($wheretable))
                 {
                    if(array_key_exists($wheretable,$this->whereFieldTableJoinType))
                    {
                        $joinsql.=$this->whereFieldTableJoinType[$wheretable].$leftjoin;
                    }
                    else
                        $joinsql.=' left join  '.$leftjoin;
                   
                 }
              }
               
              foreach( $this->whereDetailTable as $detailtablename=>$leftjoin)
              {
                $joinsql.=" left join ".$leftjoin;
              }
             
              $joinsql.=$this->getPageListQueryOrderByLeftJoin();
              $page_list_query.=$joinsql;
              //duan 20230927 调整表连接顺序,存在客户共享表中数据很多的情况,放在末尾优化速度
              $page_list_query.=$this->gettabshareSql();
              if(!empty($reportertousersql))
              {
                $reportertousersql.=$joinsql;
              }
               if($this->scopeobj)
                      $scopesql=  $this->scopeobj->getModuleListViewQuery();
              else
                    $scopesql='';
              if(empty($scopesql)||empty($reportertousersql))
                $tmpsql= $page_list_query.$this->chart_where.$this->chart_owner.$this->popuwhereclause;
              else{
                    $tablename=$this->moduleobj->table_name;
                    $tableindex=$this->moduleobj->table_index;
                    
                    $tmpsql=$page_list_query .$this->chart_where.$this->chart_owner.$this->popuwhereclause.' union all '.$reportertousersql.$this->chart_where.$this->popuwhereclause;
                    $tmpsql="select distinct tmp_Tmp_table.* from $tablename inner join   ( $tmpsql) as tmp_Tmp_table 
                       on $tablename.$tableindex=tmp_Tmp_table.$tableindex $joinsql $this->chart_where  ";
                   //相关信息，所以不能添加group by
                    //if($type!=4)
                        //$tmpsql.=' group by '.$baseTable.'.'.$focus->table_index;
              }
              if($type=='groupby')
                 $tmpsql.=$this->getGroupBy();
              return html_entity_decode($tmpsql);
        }
        elseif($type==2)
        {//$this->noPinyinFromClause:表示不要用拼音查询的from
        //要添加distinct ,如果不添加导出没有明细列时，进度条有错误
            //dump(' SELECT distinct '.$selectColumn.$this->popuselectcolumn. $this->noPinyinFromClause.$this->popufromclasuse);
           
            return ' SELECT distinct '.$selectColumn.$this->popuselectcolumn. $this->noPinyinFromClause.$this->popufromclasuse;
        }
        elseif($type==3)
        {
            //获取带明细的总数量
          
         	if(in_array($this->moduleTableDetail,$this->ModuleTableDetailColumn) || in_array($this->moduleTableDetailscf,$this->ModuleTableDetailColumn))
            {
                return ' SELECT distinct '.$this->moduleobj->table_name.'.'.$this->moduleobj->table_index.','.$this->moduleobj->Detail_table
                .'.'.$this->moduleobj->Detail_table_id. $this->noPinyinFromClause.$this->popufromclasuse;
                
            }
            else
            {
                return ' SELECT distinct '.$this->moduleobj->table_name.'.'.$this->moduleobj->table_index. $this->noPinyinFromClause.$this->popufromclasuse;
            }
        }
      
       
    }
	
   
  
	public function getSQLColumn($name) {
		if ($name == 'id') {
			$baseTable = $this->moduleobj->table_name;
			$moduleTableIndexList = $this->moduleobj->tab_name_index;
			$baseTableIndex = $moduleTableIndexList[$baseTable];
			return $baseTable.'.'.$baseTableIndex;
		}

		$moduleFields = $this->fieldobj->getModuleFields();
		$field = $moduleFields[$name];
		$sql = '';
		$column = $field->getColumnName();
		return $field->getTableName().'.'.$column;
	}
    public function getDetailTable()
    {
        $tabdetail_table=[];
        if(sizeof($this->whereDetailTable)>0)
        {
            
            $tabdetail_table=array_merge($tabdetail_table,$this->whereDetailTable);
        }
       
      
        if(sizeof($this->ModuleTableDetailColumn)>0)
        {
           
            $tabdetail_table=array_merge($tabdetail_table,$this->ModuleTableDetailColumn);
        }
        if(array_key_exists('ld_products',$tabdetail_table)&&!array_key_exists($this->moduleobj->Detail_table,$tabdetail_table)){
            $tabdetail_table[$this->moduleobj->Detail_table]=$this->moduleobj->Detail_table;
                
        }
        if(array_key_exists('ld_productcf',$tabdetail_table)&&!array_key_exists($this->moduleobj->Detail_table,$tabdetail_table)){
            $tabdetail_table[$this->moduleobj->Detail_table]=$this->moduleobj->Detail_table;
                
        }
        if(array_key_exists($this->moduleobj->Detail_table_scf,$tabdetail_table)&&!array_key_exists($this->moduleobj->Detail_table,$tabdetail_table)){
            $tabdetail_table[$this->moduleobj->Detail_table]=$this->moduleobj->Detail_table;
                
        }
        return $tabdetail_table;
    }
    public function getListTotalFrom()
    {
         $this->selecttables=$this->MainTableColumn;
       $tabdetail_table=$this->getDetailTable();
      $tablejoin_arr=[];
       $focus=$this->moduleobj;
	
		$baseTable = $focus->table_name;
        $basetableindex=$focus->table_index;
		$sql=$this->getMainFromClause();//获取主表sql
  	      
         if(array_key_exists($this->moduleobj->Detail_table,$tabdetail_table)||array_key_exists($this->moduleobj->Detail_table_scf,$tabdetail_table))
         {
            $sql.=' left join '.$this->moduleobj->Detail_table. ' on '.$this->moduleobj->Detail_table.'.'.$this->moduleobj->Detail_table_index.'='.$baseTable.'.'.$basetableindex;
            $tablejoin_arr[]=$this->moduleobj->Detail_table;
         }
         if(array_key_exists($this->moduleobj->Detail_table_scf,$tabdetail_table))
         {
            $tablejoin_arr[]=$this->moduleobj->Detail_table_scf;
            $sql.=' left join '.$this->moduleobj->Detail_table_scf.' on '.$this->moduleobj->Detail_table_scf.'.'.$this->moduleobj->Detail_table_id.' = '.$this->moduleobj->Detail_table.'.'.$this->moduleobj->Detail_table_id;
         }
         if(array_key_exists('ld_products',$tabdetail_table))
         {
            $tablejoin_arr[]='ld_products';
             $sql.=' left join ld_products on '.$this->moduleobj->Detail_table.'.productid=ld_products.productid ';
         }
         if(array_key_exists('ld_productcf',$tabdetail_table))
         {
            $tablejoin_arr[]='ld_productcf';
             $sql.=' left join ld_productcf  on '.$this->moduleobj->Detail_table.'.productid=ld_productcf.productid ';
         }
         foreach($this->whereDetailTable as $detailtablename=>$leftjoin)
         {
            if(!in_array($detailtablename,$tablejoin_arr))
            {
                 $tablejoin_arr[]=$detailtablename;
                $sql.=' left join '.$leftjoin;
            }
            
         }
        //edit:can 2020-09-04  42589: 郎捷：蒋敏账号小程序，待审批数据不对，显示2个，点击没有数据
        //$sql .= $this->getOrderByLeftJoin();
      
        $this->noPinyinFromClause=$sql;
        $sql.=$this->gettabshareSql();
        return $sql;
    }
	public function getFromClause() {
	   if(!empty($this->fromClause))
       {
            return $this->fromClause;
       }
      
       $sql=$this->getListTotalFrom();
	
		$this->fromClause = $sql;
		return $sql;
	}
    


	public function addCondition($fieldname,$value,$operator,$tablename='',$glue= null,$newGroup = false,$newGroupType = null) {
        //wym BUG0074710 kfbcrm-收款单-平铺查找-筛选条件不生效
		if($value==''&&$operator!='isnotnull'&&$operator!='isnull'&&$operator!='curuser')//34443: 单据列表界面>基本查找：应该允许关键字为空时进行搜索。预期：当关键字为空时进行搜索默认为搜索全部。
			return ;
		$conditionNumber = $this->conditionInstanceCount++;
		$this->groupInfo .= "$conditionNumber ";
		$this->whereFields[] = $fieldname;
		$this->reset();
        if($this->getConditionalArray($fieldname,$value, $operator)!=''){
			if($fieldname == 'timetype' && $this->module == 'TimeSheet'){
				$direct_value = $this->moduleobj->getDirectType($value);
				if(!empty($direct_value)){
					$value = $direct_value;
					$operator = 'e';
				}
			}
			$this->conditionals[$conditionNumber] = $this->getConditionalArray($fieldname,$value, $operator,$tablename);
		}
                 
                
	}
	public function addConditionADV($fieldname,$value) {
        if(isset($value)){
            $this->field_conditionals[$fieldname] =  $value;  
        }     
	}



   

}
?>