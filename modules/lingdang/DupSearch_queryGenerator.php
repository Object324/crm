<?php
/* 查重显示列序时簿  */
crm_load_class_file('QueryGenerator','include/QueryGenerator');
crm_load_class_file('UnAssignedAccountsAuthority','include/ScopOfAuthority');
class DupSearch_queryGenerator extends QueryGenerator
{
    public $productDetails;
    private $moduleColArray=array();
    public $ProductsTableColumn=array();//列头所涉及到的产品相关表
    public $MainTableColumn=array();//列头涉及主表
    public  $whereMainTable=array();//查询涉及主表
    public $popuptype;
    public $focus;
    public function __construct($module, $user,$customerview='',$productDetails='') {
        parent::__construct($module, $user,$customerview);
        if($productDetails=='')
        {
            crm_load_class_file("ProductDetails",'include/ProductDetails');
            $this->productDetails=new ProductDetails($module);
        }
        else
            $this->productDetails=$productDetails;
        $this->productDetails->querygenerator=$this;
    }

    private static $instanceobj;
    public static function getInstance($module, $user,$customerview='',$productDetails='',$isSingle=''){
        if(!empty(self::$instanceobj[$module])){
            return self::$instanceobj[$module];
        }
        if($module=='Accounts') {
            crm_load_class_file("DupSearch_queryGenerator_account",'modules/Accounts');
            self::$instanceobj[$module] = new DupSearch_queryGenerator_account($module, $user,$customerview,$productDetails);
        } else if($module=='Potentials') {
            crm_load_class_file("DupSearch_queryGenerator_potentials",'modules/Potentials');
            self::$instanceobj[$module] = new DupSearch_queryGenerator_potentials($module, $user,$customerview,$productDetails);
        }else{
            self:: $instanceobj[$module] = new DupSearch_queryGenerator($module, $user,$customerview,$productDetails);
        }
        return self:: $instanceobj[$module];
    }

    public function getScopeOfAuthority_obj($db,$module)
    {
        //$this->scopeobj = new ScopOfAuthority($db,$module);
        $this->scopeobj = '';
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



    public function initForDefaultCustomView() {
        if(empty($this->customview))
            $this->customview = CustomView::getInstance($this->module);
        $viewId = $this->customview->getViewId($this->module);
        $this->initForCustomViewById($viewId);
    }
    public function getReferenceOrderBy()
    {
        return $this->referenceorder;
    }

    /**
     * reason:获取查询列头中主表列头数
     * */
    public function getDetailWhere($field,$conditioninfo,$valueSql)
    {
        $fieldName=$field->getFieldName();
        $origntablename=$field->getTableName();
        $origncolumnname=$field->getColumnName();
        $fieldsql= parent::getMainWhere($field,$conditioninfo,$valueSql);
        unset($this->whereFieldTables[$this->main_field_whereobj->where_jointablename]);
        return $fieldsql;
    }
    public function getMainWhere($field,$conditioninfo,$valueSql)
    {
        return parent::getMainWhere($field,$conditioninfo,$valueSql);
    }
    public function getWhereClause() {
        global $current_user;
        if(!empty($this->query) || !empty($this->whereClause)) {
            return $this->whereClause;
        }

        $deletedQuery = $this->moduleobj->getEntityDeletedQuery();
        $sql = '';
        if(!empty($deletedQuery))
        {

            $sql .= " WHERE $deletedQuery";

        }
        if($this->conditionInstanceCount > 0) {
            $sql .= ' AND ';
        } elseif(empty($deletedQuery)) {
            $sql .= ' WHERE ';
        }
        $baseTable = $this->moduleobj->table_name;
        $moduleTableIndexList = $this->moduleobj->tab_name_index;

        $this->moduleFieldList = $this->fieldobj->getModuleFields();
        $baseTableIndex = $moduleTableIndexList[$baseTable];
        $groupSql = $this->groupInfo;
        $fieldSqlList = array();
        crm_load_class_file('cls_query_where','include/QueryGenerator/SqlWhere');
        foreach ($this->conditionals as $index=>$conditionInfo) {
            $fieldSql=$this->setFieldSql($conditionInfo);
            if(!empty($fieldSql))
            {
                $fieldSqlList[$index] = $fieldSql;
            }
        }
        $this->whereDetailTable=$this->whereContactsTable;
        $groupSql = $this->makeGroupSqlReplacements($fieldSqlList, $groupSql);
        if($this->conditionInstanceCount > 0) {
            $this->conditionalWhere = $groupSql;//$groupSql是视图的查询条件
            $sql .= $groupSql;
        }
        $sql .= " AND $baseTable.$baseTableIndex > 0";
        $sql=str_replace(DATACATEGORYSEACHEMPTYVALUE,"",$sql);
        $this->whereClause = $sql;
        return $sql;
    }
    public function setFieldSql($conditionInfo)
    {
        global  $adb;
        if($conditionInfo=='') {return '';}
        $fieldSql = '(';
        $fieldGlue = '';
        if(empty($this->moduleAllPresenceFieldList ))
            $this->moduleAllPresenceFieldList = $this->fieldobj->getModuleAllPreseneceFields();

        $fieldName = $conditionInfo['name'];
        $field = $this->moduleAllPresenceFieldList[$fieldName];
        if(empty($field)) {
            return '';
        }

        // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
        $operator = $conditionInfo['operator'];
        $valueSqlList = $this->getValueSqlList($field, $conditionInfo);

        foreach ($valueSqlList as $valueSql) {
            $mainwhere=$this->getMainWhere($field,$conditionInfo,$valueSql);
            if(!empty($mainwhere))
            {
                $fieldSql.=$fieldGlue.$mainwhere;
                $fieldGlue = ' OR';
                //wym 240521 XUQIU1002181 新增查询条件，属于/不属于 条件可以输入多个字段，用“，”或“,”分辨注：中英文的“，”都可以做划分
                if($operator === 'notbelong' || $operator === 'new_notbelong') {
                    $fieldGlue = ' AND';
                }
                $this->whereMainTable=$this->whereFieldTables;
            }
            else
            {
                //edit:can 2020-12-02 43543: （https://kehu001.com/KH/kh30033 [^] ）客户问题（普阳会计），收款单新建界面，选择“客户名称”弹出层中搜索关键字查找不到数据
                if(strtolower(trim($fieldGlue))=='and')
                {
                    $fieldSql.=$fieldGlue.' 1=1 ';
                }
                else
                {
                    $fieldSql.=$fieldGlue.' 1<>1 ';
                }
            }
            /*$fieldSql.=$fieldGlue.$this->getMainWhere($field,$conditionInfo,$valueSql);
            $this->whereMainTable=$this->whereFieldTables;
            $fieldGlue=' OR';*/
        }

        $fieldSql .= ')';
        return $fieldSql;

    }
    /**
     * V6.0 角色权限改进
     * @reason 获取授权范围、共享、查看自己创建的单据 条件
     * 只有查看在全部的情况下，才会去获取以上条件
     * @author Chj
     */
    public function whereRangeQuery(){
        return $this->getSmOwnerSearchSql;
    }

    /**
     * reason:获取列头,同时获取列头查询涉及的表
     * */
    function getSelectColumn($tabid = 0)
    {
        if(!empty($this->columns))
        {
            return $this->columns;
        }
        $moduleFields = $this->fieldobj->getModuleFields();//lingdangcrmobjectmeta.php
        $accessibleFieldList = array_keys($moduleFields);//获取当前用户能够看见的字段
        $accessibleFieldList[]='id';
        $selectSql =trim($this->productDetails->getSelectColumn($tabid),',');

        /**
         * 序时薄可以显示产品的字段，这些字段储存在专门的表中，所以
         * 需要把其中的crmentity替换掉
         * @project PROT12 crmentity 表结构优化
         * @author Tujt 2014-06-25
         */
        $basetable = $this->moduleobj->table_name;

        $selectSql = strtr($selectSql,array('ld_crmentity.'=>$basetable.'.'));
        $columnlist=array_filter(explode(',',$selectSql));
        $finalcolumnlist=array();

        for($i=0;$i<sizeof($columnlist);$i++)
        {
            $coltables=explode('.',$columnlist[$i]);
            $fieldinfo=$this->moduleobj->fieldobj->getFieldInfoobjBykey("columnname",$coltables[1]);
            if($fieldinfo&&$fieldinfo->getUIType()==1109)
            {
                continue;
            }
            $finalcolumnlist[]=$coltables[0].'.'.$coltables[1];
            $this->MainTableColumn[$coltables[0]]=$coltables[0];
            $this->selecttables[$coltables[0]]='';
        }
        $this->columns_array=$finalcolumnlist;
        $this->columns=implode(',',$finalcolumnlist);
        $focus = $this->moduleobj;

        $baseTable = $focus->table_name;
        $baseTableIndex = $focus->table_index;
        if(empty($this->columns))
            $this->columns .= $baseTable . '.'. $baseTableIndex;
        else
            $this->columns .= ', ' . $baseTable . '.'. $baseTableIndex;
        return $this->columns;
    }

    public function getQuery($popup='',$type='1')
    {
        return $this->getmoduleListQuery($type,$popup);

    }
    /**
     * edit:chj
     * date:2014113
     * reason:获取查询语句
     * $type:1:表示获取分页查询语句
     * $type:2表示获取select和from子句
     * */
    private  function getmoduleListQuery($type,$popup='')
    {
        global $theme;
        global $current_user,$currentModule,$adb,$weixin_user;
        $limit = "";
        $focus = $this->moduleobj;
        $this->popuptype = $popup;
        $tab_name = $focus->tab_name;
        $baseTable = $focus->table_name;
        $baseTableIndex = $focus->table_index;
        $tabid = getTabId($this->module);
        $baseTableIndex = $focus->table_index;
        $selectColumn=$this->getSelectColumn($tabid);
        $this->chart_owner="";
        $whereRangeQuery = $this->whereRangeQuery();
        $where=$this->getWhereClause();
        $this->chart_where=$where;
        $fromclause=$this->getFromClause();
        $this->chart_from=$fromclause;
        $this->chart_where=$where;
        if($popup=='popup') $this->SpecialPopup();

        if($type==1||$type=='groupby'||$type==4)
        {

            $page_list_query="SELECT  DISTINCT ".$baseTable.".".$baseTableIndex." FROM  ".$baseTable." ";
            $page_list_query.=$this->gettabshareSql();

            $reportertousersql=$this->getReporttoUserSql();

            $wherefieldtables=$this->whereFieldTables;
            $joinsql='';

            foreach($wherefieldtables as $wheretable=>$leftjoin)
            {

                if($wheretable!=$this->focus->table_name&&!empty($wheretable))
                {
                    if(array_key_exists($wheretable,$this->whereFieldTableJoinType))
                    {
                        $joinsql.=$this->whereFieldTableJoinType[$wheretable].$leftjoin;
                    }
                    else{
                        if(!empty($leftjoin))
                            $joinsql.=' left join  '.$leftjoin;
                    }
                }
            }

            $joinsql.=$this->getPageListQueryOrderByLeftJoin();
            //$page_list_query.=$this->getAlphaSql();
            $page_list_query.=$joinsql;

            if(!empty($reportertousersql))
            {
                $reportertousersql.=$joinsql;
            }
            if($this->scopeobj)
                $scopesql=  $this->scopeobj->getModuleListViewQuery();
            else
                $scopesql='';

            if(empty($scopesql)||empty($reportertousersql))
                $tmpsql= $page_list_query .$this->chart_where.$this->chart_owner.$this->popuwhereclause;
            else{
                $tablename=$this->moduleobj->table_name;
                $tableindex=$this->moduleobj->table_index;

                $tmpsql=$page_list_query .$this->chart_where.$this->chart_owner.$this->popuwhereclause.' union all '.$reportertousersql.$this->chart_where.$this->popuwhereclause;
                $tmpsql="select distinct tmp_Tmp_table.* from $tablename inner join   ( $tmpsql) as tmp_Tmp_table 
                   on $tablename.$tableindex=tmp_Tmp_table.$tableindex  $joinsql $this->chart_where  ";
                //相关信息，所以不能添加group by
                //if($type!=4||$_SESSION['accountlistview']=='yes')
                //$tmpsql.=' group by '.$baseTable.'.'.$focus->table_index;
            }
            return $tmpsql;


        }
        elseif($type==2)
        {
            //distinct 要添加上，否则单据共享后，然后导出的excel行数错误
            return ' SELECT  distinct '.$selectColumn.$this->popuselectcolumn. $fromclause.$this->popufromclasuse;

        }
        elseif($type==3)
        {
            //获取带明细的总数量,导出判断使用csv还是excel文件
            $keys=array_keys($this->ContactsTableColumn);
            return ' SELECT distinct '.$this->moduleobj->table_name.".".$this->moduleobj->table_index. $fromclause.$this->popufromclasuse;
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

    public function getListTotalFrom()
    {

        $this->selecttables=$this->MainTableColumn;
        $focus=$this->moduleobj;
        $baseTable = $focus->table_name;
        $basetableindex=$focus->table_index;
        $sql=$this->getMainFromClause();
        $this->noPinyinFromClause = $sql;
        $sql.=$this->gettabshareSql();

        return $sql;
    }

    public function getFromClause()
    {
        if(!empty($this->chart_from))
        {
            return $this->chart_from;
        }
        $sql=$this->getListTotalFrom();
        $this->fromClause = $sql;
        return $sql;
    }

    public function addCondition($fieldname,$value,$operator,$tablename='',$glue= null,$newGroup = false,
                                 $newGroupType = null) {
        if($value==''&&$value!=0 && $operator!="isnotnull"&&$operator!='isnull')//34443: 单据列表界面>基本查找：应该允许关键字为空时进行搜索。预期：当关键字为空时进行搜索默认为搜索全部。
            return ;
        $conditionNumber = $this->conditionInstanceCount++;
        $this->groupInfo .= "$conditionNumber ";
        $this->whereFields[] = $fieldname;
        $this->reset();
        if($this->getConditionalArray($fieldname,$value, $operator)!='')
            $this->conditionals[$conditionNumber] = $this->getConditionalArray($fieldname,$value, $operator,$tablename);
    }
}
?>