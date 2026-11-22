<?php
/* 查重显示列序时簿  */
crm_load_class_file('DupSearch_queryGenerator','include/lingdang');
crm_load_class_file('UnAssignedAccountsAuthority','include/ScopOfAuthority');
class DupSearch_queryGenerator_potentials extends DupSearch_queryGenerator
{
    public $productDetails;
    private $moduleColArray=array();
    public $ProductsTableColumn=array();//列头所涉及到的产品相关表
    public $MainTableColumn=array();//列头涉及主表
    public  $whereMainTable=array();//查询涉及主表
    public $popuptype;
    public $wheretable;
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
    public function getCustomViewFieldObj($tablename,$fieldname)
    {
        $moduleFields=$this->getModuleFieldList();
        $productModuleFields= $this->productDetails->getModuleFields();
        $objfield=$moduleFields[$fieldname];
        return $objfield;
    }

    /**
     * reason:获取查询列头中主表列头数
     * */
    public function getMainColumnCount()
    {

        return $this->productDetails->getRowCount();
    }
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
        if(($field->getTableName())=='ld_products')
        {

            if(!$field||$field->getFieldName()=='')
                return '';
            $products = CRMEntity::getInstance('Products');
            $fieldName=$field->getFieldName();
            $tablename=$field->getTableName();
            $columnname=$field->getColumnName();
            $tablescf=$products->customFieldTable[0];
            $tablescfindex=$products->customFieldTable[1];
            $maintablename=$products->table_name;
            $maintableindex=$products->table_index;
            if(Field::user_fields($field->getUIType()))//审批人,创建人，最近更新人,53:收款单审核人,100:提醒人
            {
                crm_load_class_file('cls_where_user','include/QueryGenerator/SqlWhere/NormalWhere');

                $whereobj=new cls_where_user($this->module,$field,$conditionInfo,$this->moduleobj,$valueSql);
                $whereobj->getWhereCondition();
                $fieldSql.= $fieldGlue.$whereobj->fieldSql;
                if($field->getTableName()!=$maintablename)
                    $this->whereFieldTables[$field->getTableName()]= "  $tablescf on $tablescf.$tablescfindex=$maintablename.$maintableindex ";
                $this->whereFieldTables[$whereobj->where_jointablename]=$whereobj->whereFieldTable;
            }else
            {
                crm_load_class_file("cls_query_other",'include/QueryGenerator/SqlWhere/NormalWhere');
                $whereobj=new cls_query_other($this->module,$field,$conditionInfo,$this->moduleobj,$valueSql,$this);
                $whereobj->getWhereCondition();
                $fieldSql.= $fieldGlue.$whereobj->fieldSql;
                $field_table_index=$this->moduleobj->tab_name_index[$field->getTableName()];
                if($field->getTableName()!=$this->moduleobj->table_name &&$field->getTableName()!='ld_products')
                {
                    $whereobj->where_jointablename=$field->getTableName();
                    $this->whereFieldTables[$field->getTableName()]=$field->getTableName().' on '.$field->getTableName().'.'.$products->tab_name_index[$field->getTableName()].'= '.$this->moduleobj->table_name.'.'.$this->moduleobj->table_index;
                }
            }

            return $fieldSql;
        }

        return     parent::getMainWhere($field,$conditioninfo,$valueSql);
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
        //dump($this->conditionals);
        foreach ($this->conditionals as $index=>$conditionInfo) {
            $fieldSql=$this->setFieldSql($conditionInfo);
            if(!empty($fieldSql))
            {
                $fieldSqlList[$index] = $fieldSql;
            }

        }
        //dump($fieldSqlList);
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

        //dump($this->moduleAllPresenceFieldList);
        //$filed_property='Accounts';
        if(!in_array($conditionInfo['tablename'],$this->whereMainTable))
        {
            $this->wheretablename[] = $conditionInfo['tablename'];
        }

        // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
        $operator = $conditionInfo['operator'];

        if($conditionInfo['tablename']=='ld_products')
        {
            $productDetails = $this->getMeta('Products');

            $modulefield=$productDetails->getModuleAllPreseneceFields();

            //$modulefield = $this->moduleAllPresenceFieldList;
            $field=$modulefield[$conditionInfo['name']];
            //dump($modulefield);
            if(!$field)
                return '';

            // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
            $valueSqlList = $this->getValueSqlList($field, $conditionInfo);

            if(!is_array($valueSqlList)) {
                $valueSqlList = array($valueSqlList);
            }
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

        }else if($conditionInfo['tablename']=='ld_potentialsdetail')
        {
            $fieldSql= $this->getdetailwheresql($conditionInfo['tablename'],$conditionInfo['name'],$conditionInfo['value']);
        }
        else
        {
            $fieldName = $conditionInfo['name'];
            $field = $this->moduleAllPresenceFieldList[$fieldName];
            if(empty($field)) {
                return '';
            }

            // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
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
        return $this->getPotentialsListQuery($type,$popup);

    }
    /**
     * edit:chj
     * date:2014113
     * reason:获取查询语句
     * $type:1:表示获取分页查询语句
     * $type:2表示获取select和from子句
     * */
    private  function getPotentialsListQuery($type,$popup='')
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

            $page_list_query="SELECT  DISTINCT ld_potential.potentialid FROM  ld_potential ";
            $page_list_query.=$this->LeftJoin_Products();
            $page_list_query.=$this->gettabshareSql();

            $reportertousersql=$this->getReporttoUserSql();//edit:can 20200826 用户界面 汇报人；

            $wherefieldtables=$this->whereFieldTables;
            $joinsql='';

            foreach($wherefieldtables as $wheretable=>$leftjoin)
            {

                if($wheretable!='ld_potential'&&!empty($wheretable))
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

    public function LeftJoin_Products(){
        if(in_array('ld_products',$this->wheretablename)||in_array('ld_potentialsdetail',$this->wheretablename)){
            $sql =' left join  ld_potentialsdetail on ld_potential.potentialid   = ld_potentialsdetail.id
                    left join  ld_products  on ld_products.productid  = ld_potentialsdetail.productid  ';
        }
        return $sql;
    }

    public function getConditionSpecial($value, $operator, $field)
    {
        $sql='';
        if($field->getFieldName() == 'publicaccount')
        {
            crm_load_class_file('cls_publicaccount_where','include/QueryGenerator/SqlWhere');

            return cls_publicaccount_where::getwheresql($operator,$value,$this->module);
        }
        // return $sql;
    }



    public function addCondition($fieldname,$value,$operator,$tablename='',$glue= null,$newGroup = false,
                                 $newGroupType = null) {
        if($value==''&&$value!=0 && $operator!="isnotnull"&&$operator!='isnull')//34443: 单据列表界面>基本查找：应该允许关键字为空时进行搜索。预期：当关键字为空时进行搜索默认为搜索全部。
            return ;
        $conditionNumber = $this->conditionInstanceCount++;
        $this->groupInfo .= "$conditionNumber ";
        $this->whereFields[] = $fieldname;
        $this->reset();
        if($this->getConditionalArray($fieldname,
                $value, $operator)!='')
            $this->conditionals[$conditionNumber] = $this->getConditionalArray($fieldname,
                $value, $operator,$tablename);
    }
    public function getMainFromClause()
    {
        $baseTable=$this->moduleobj->table_name;
        $sql=$this->setMaintable_nameSql();
        $sql.=$this->LeftJoin_Products();
        $main_query=$this->moduleobj->table_name.'.'.$this->moduleobj->table_index;

        foreach($this->selecttables as $tablename=>$info)
        {
            //临时表中包含：main_select_joinTable_，from子句表连接临时表
            if(strpos($tablename,'main_select_joinTable_')!==false)
            {
                $sql.=$info;
            }
            else if(($tablename!=$this->moduleobj->table_name&&array_key_exists($tablename,$this->moduleobj->tab_name_index)))
            {
                $sql.=" left join ".$tablename." on $tablename.".$this->moduleobj->tab_name_index[$tablename]." = ".$main_query;
            }

        }

        $wherefieldtables=$this->whereFieldTables;
        foreach($wherefieldtables as $wheretable=>$leftjoin)
        {
            if($wheretable!=$this->moduleobj->table_name&&!empty($wheretable)&&!array_key_exists($wheretable,$this->selecttables))
            {
                if(array_key_exists($wheretable,$this->whereFieldTableJoinType))
                {
                    $sql.=$this->whereFieldTableJoinType[$wheretable].$leftjoin;
                }
                else
                    $sql.=' left join   '.$leftjoin;
            }
        }
        foreach($this->customview->orderby_tables as $ordertable=>$leftjoin){
            if($ordertable!=$this->moduleobj->table_name&&!empty($ordertable)&&!array_key_exists($ordertable,$this->selecttables)&&!array_key_exists($ordertable,$this->whereFieldTables))
            {
                $sql.=" left join ".$ordertable." on $ordertable.".$this->moduleobj->tab_name_index[$tablename]." = ".$main_query;
            }
        }
        return $sql;
    }
    public function getdetailwheresql($tablename,$columname,$value)//特殊表生成查询条件
    {
        $sql = '( '.$tablename.'.'.$columname.' like ';
        $sql.="'%$value%' ";
        return $sql;
    }
}
?>