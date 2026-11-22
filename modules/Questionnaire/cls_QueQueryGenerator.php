<?php
crm_load_class_file('QueryGenerator',globalStatic::$root_directory.'include/QueryGenerator/QueryGenerator.php');
class cls_QueQueryGenerator extends QueryGenerator
{
    public function __construct($module,$customview=''){
        $db = PearDatabase::getInstance();

        $this->module = $module;

        $this->moduleobj= CRMEntity::getInstance($module);
        $this->customview=$customview;
        $this->productDetails=$customview;
        $this->fieldobj = $this->getMeta($module);
        $this->referenceFieldInfoList=$this->fieldobj->getReferenceFieldDetails();
        //print_r($this->referenceFieldInfoList);

        $this->referenceFieldList = array_keys($this->referenceFieldInfoList);;

        $this->ownerFields=array($this->fieldobj->getFieldInfoBykeyValue('columnname','smownerid','fieldname'));
        $this->Init();
    }
    public function getReporttoUserSql()
    {
        //获取汇报人的sql
        global $adb;
        global $current_user;
        if($_REQUEST['SearchScope']=='SmOwner_Search_Create'||$_REQUEST['SearchScope']=='SmOwner_Search_All')
        {
            //  return '';
        }
        $maintablename=$this->moduleobj->table_name;
        $smownercolumnname=$this->moduleobj->getSmownerColumName();
        $tableindex=$this->moduleobj->table_index;

        $sql='';

        //启用了汇报人字段
        $sql='select  id from ld_users where find_in_set(1,reportertouser) ';
        $sql="  select $maintablename.$tableindex from $maintablename  inner join ($sql) as table_reportertouser
         on $maintablename.$smownercolumnname=table_reportertouser.id  ";
        return $sql;
    }
    public function getQuery($popup='',$type='1')
    {
        return $this->getQuestionnaireListQuery($type,$popup);

    }
    private  function getQuestionnaireListQuery($type,$popup='')
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
        $whereRangeQuery = '';
        $where=$this->getWhereClause();
        $advancewheresql = $this->advanceDemandSql();
        $this->chart_where=$where.$advancewheresql['wheretable'];
        $fromclause=$this->getFromClause();
        $this->chart_from=$fromclause;
        if($popup=='popup') $this->SpecialPopup();

        if($type==1||$type=='groupby'||$type==4)
        {

            $page_list_query=$advancewheresql['page_list_query'];
            if($page_list_query == ''){
                $page_list_query="SELECT  DISTINCT ".$focus->table_name.".".$focus->table_index." FROM ".$focus->table_name;
                $wherefieldtables=$this->whereFieldTables;
                $joinsql='';

                foreach($wherefieldtables as $wheretable=>$leftjoin)
                {

                    if($wheretable!=$focus->table_name&&!empty($wheretable))
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
                $page_list_query = $tmpsql;
            }
            if ($_REQUEST['maxrowsshow'] > 0) {
                $key_where_mu = $this->related_key_where($_REQUEST['Keyids'],$_REQUEST['maxrowsshow']);
                $keywhere = $key_where_mu['keywhere'];
                $approvedemand = $_REQUEST['approve_demand'];//审批要求
                if ($approvedemand == 1)//已批准
                {
                    $tablename = $focus->table_name;
                    $where_approve = ' and ifnull( ' . $tablename . ".approvestatus,'')='" . constant('D_A_S_APPROVED') . "' ";
                }
                $orderby = ' order by ' . $focus->table_name . '.createdtime DESC ';

                $limit_sql = $key_where_mu['limit'];
            }

            $tmpsql = $page_list_query.$keywhere.$where_approve.$orderby.$limit_sql;
            return $tmpsql;


        }
        elseif($type==2)
        {
            //distinct 要添加上，否则单据共享后，然后导出的excel行数错误
            $selectColumn = $selectColumn.','.$focus->table_name.'.'.$focus->table_index;
            return ' SELECT  distinct '.$selectColumn.$this->popuselectcolumn. $fromclause.$this->popufromclasuse;

        }
        elseif($type==3)
        {
            //获取带明细的总数量,导出判断使用csv还是excel文件
            $keys=array_keys($this->ContactsTableColumn);
            return ' SELECT distinct '.$this->moduleobj->table_name.".".$this->moduleobj->table_index. $fromclause.$this->popufromclasuse;
        }

    }

    function getSelectColumn($tabid = 0){
        global $adb;
        $displaySetting_columnname = '';
        //超链接字段
        $sql = 'select ld_entityname.modulename,ld_field.columnname,ld_field.fieldname,ld_field.tablename,ld_field.fieldlabel from ld_field LEFT JOIN ld_entityname on ld_field.fieldname = ld_entityname.fieldname and ld_field.tabid = ld_entityname.tabid where ld_entityname.tabid = ? ';
        $result=$adb->pquery($sql,array(getTabid($this->module)));
        $rows=$adb->num_rows($result);
        if($rows>0){
            $displaySetting_columnname .= $adb->query_result($result,0,'tablename').'.'.$adb->query_result($result,0,'columnname');
        }
        //负责人 编号字段
        $sql = 'select columnname,fieldname,tablename,fieldlabel from ld_field where tabid = ? and (uitype=4  or uitype=53) ORDER BY uitype desc';
        $result=$adb->pquery($sql,array(getTabid($this->module)));
        $rows=$adb->num_rows($result);
        if($rows>0){
            for($i = 0;$i<$rows;$i++){
                if($displaySetting_columnname != ''){
                    $displaySetting_columnname .=',';
                }
                $displaySetting_columnname .= $adb->query_result($result,$i,'tablename').'.'.$adb->query_result($result,$i,'columnname');
            }
        }
        return $displaySetting_columnname;
    }

    public function getWhereClause() {
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

    public function initForCustomViewById($viewId) {
        if(empty($this->customview))
        {
            $this->customview = CustomView::getInstance($this->module);
        }

        $this->sequence_fields=$this->customview->getCustomViewOrderBy($viewId);

        global $adb;
        $displaySetting_columnname = [];
        //超链接字段
        $sql = 'select ld_entityname.modulename,ld_field.columnname,ld_field.fieldname,ld_field.tablename,ld_field.fieldlabel from ld_field LEFT JOIN ld_entityname on ld_field.fieldname = ld_entityname.fieldname and ld_field.tabid = ld_entityname.tabid where ld_entityname.tabid = ? ';
        $result=$adb->pquery($sql,array(getTabid($this->module)));
        $rows=$adb->num_rows($result);
        if($rows>0){
            $displaySetting_columnname[] = $adb->query_result($result,0,'tablename').':'.$adb->query_result($result,0,'columnname').':'.$adb->query_result($result,0,'fieldname').':_fieldlabel';
        }
        //负责人 编号字段
        $sql = 'select columnname,fieldname,tablename,fieldlabel from ld_field where tabid = ? and (uitype=4  or uitype=53) ORDER BY uitype desc';
        $result=$adb->pquery($sql,array(getTabid($this->module)));
        $rows=$adb->num_rows($result);
        if($rows>0){
            for($i = 0;$i<$rows;$i++){
                $displaySetting_columnname[] = $adb->query_result($result,$i,'tablename').':'.$adb->query_result($result,$i,'columnname').':'.$adb->query_result($result,$i,'fieldname').':_fieldlabel';
            }
        }


        $this->customViewColumnList = $displaySetting_columnname;




        if(!empty($this->customViewColumnList)){
            foreach ($this->customViewColumnList as $customViewColumnInfo) {
                $details = explode(':', $customViewColumnInfo);
                $moduelsinfo=explode('_',$details[3]);
                $objfield=$this->getCustomViewFieldObj($details[0],$details[2]);
                if(!$objfield)
                    continue;
                if(empty($details[2]) && $details[1] == 'crmid' && $details[0] == 'ld_crmentity') {
                    $name = 'id';
                    $this->customViewFields[] = $name;
                }

                else {
                    $this->fields[] = $details[2];
                    $this->customViewFields[] = $details[2];
                }
                $moduelsinfo=explode('_',$details[3]);
                $this->fields_property[]=$moduelsinfo[0];//获取当前字段所属模块
            }
        }
        if($this->module == 'Calendar' && !in_array('activitytype', $this->fields)) {
            $this->fields[] = 'activitytype';
        }

        $this->fields[] = 'id';


        //edit:can reason:12997: 库存>>盘点明细界面,相关信息中，附件管理界面,打开附件后,看不到信息.
        //盘点的主键名称为id,在上面被删除了
        if(!in_array('id',$this->fields))
        {
            $this->fields[]='id';
        }
        for ($i = 0; $i < count($displaySetting_columnname); $i++) {
            if ($i == count($displaySetting_columnname) - 1) {
                $this->advFilterList[1]['columns'][] = array(
                    'columnname' => $displaySetting_columnname[$i],
                    'comparator' => 'c',
                    'value' => $_REQUEST['value'],
                    'column_condition' => ''
                );
            } else {
                $this->advFilterList[1]['columns'][] = array(
                    'columnname' => $displaySetting_columnname[$i],
                    'comparator' => 'c',
                    'value' => $_REQUEST['value'],
                    'column_condition' => 'or'
                );
            }
        }
        $this->advFilterList[1]['condition'] = '';
        //dump($this->advFilterList);
        //$this->advFilterList = $this->customview->getAdvFilterByCvid($viewId);



        if($this->conditionInstanceCount <= 0 && is_array($this->advFilterList) && count($this->advFilterList) > 0) {
            $this->startGroup('');
        } elseif($this->conditionInstanceCount > 0 && is_array($this->advFilterList) && count($this->advFilterList) > 0) {
            $this->addConditionGlue(self::$AND);
        }



        if(is_array($this->advFilterList) && count($this->advFilterList) > 0) {

            $this->datetimestr=$this->getDateTimestr();
            foreach ($this->advFilterList as $groupindex=>$groupcolumns) {
                $filtercolumns = $groupcolumns['columns'];
                if(count($filtercolumns) > 0) {
                    $this->startGroup('');
                    foreach ($filtercolumns as $index=>$filter) {
                        $name = explode(':',$filter['columnname']);
                        $table_name = $name[0];
                        if(empty($name[2]) && $name[1] == 'crmid' && $name[0] == 'ld_crmentity') {
                            $name = $this->getSQLColumn('id');
                        } else {
                            $name = $name[2];
                        }
                        if($filter['value']=='')
                        {
                            $filter['value']=DATACATEGORYSEACHEMPTYVALUE;
                        }
                        $this->addCondition($name, $filter['value'], $filter['comparator'],$table_name);

                        $columncondition = $filter['column_condition'];
                        if(!empty($columncondition)) {
                            $this->addConditionGlue($columncondition);
                        }
                    }
                    $this->endGroup();
                    $groupConditionGlue = $groupcolumns['condition'];

                    if(!empty($groupConditionGlue))
                        $this->addConditionGlue($groupConditionGlue);
                }
            }
        }

        if($this->conditionInstanceCount > 0) {
            $this->endGroup();
        }

    }
    public function addCondition($fieldname,$value,$operator,$tablename='',$glue= null,$newGroup = false, $newGroupType = null) {
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

        if($conditionInfo['tablename']=='ld_products')
        {
            $productDetails = $this->getMeta('Products');

            $modulefield=$productDetails->getModuleAllPreseneceFields();

            //$modulefield = $this->moduleAllPresenceFieldList;
            $field=$modulefield[$conditionInfo['name']];
            //dump($modulefield);
            if(!$field)
                return '';
            $valueSqlList = $this->getConditionValue($conditionInfo['value'],$conditionInfo['operator'],$field);

            if(!is_array($valueSqlList)) {
                $valueSqlList = array($valueSqlList);
            }

            foreach ($valueSqlList as $valueSql) {
                $mainwhere=$this->getMainWhere($field,$conditionInfo,$valueSql);
                if(!empty($mainwhere))
                {
                    $fieldSql.=$fieldGlue.$mainwhere;
                    $fieldGlue = ' OR';
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
            $valueSqlList = $this->getConditionValue($conditionInfo['value'],$conditionInfo['operator'],$field);

            if(!is_array($valueSqlList)) {
                $valueSqlList = array($valueSqlList);
            }
            foreach ($valueSqlList as $valueSql) {
                $mainwhere=$this->getMainWhere($field,$conditionInfo,$valueSql);
                if(!empty($mainwhere))
                {
                    $fieldSql.=$fieldGlue.$mainwhere;
                    $fieldGlue = ' OR';
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

    public function advanceDemandSql(){
        $advance_demand = html_entity_decode($_REQUEST['advance_demand']);
        $advance_demand_groups = html_entity_decode($_REQUEST['advance_demand_groups']);
        if ($advance_demand && $advance_demand != '[]') {
            //$advft_criteria_groups = '[null,{"groupcondition":"and"},{"groupcondition":""}]';
            $advance_demand_group_arr=json_decode($advance_demand_groups,true);
            $advance_demand_group_arr[sizeof($advance_demand_group_arr)-1]['groupcondition']='';
            $advance_demand_groups=json_encode($advance_demand_group_arr);


            $_REQUEST['advft_criteria'] = $advance_demand;
            $_REQUEST['advft_criteria_groups'] = $advance_demand_groups; //  ''
            $_REQUEST['searchtype'] = 'advance';
            // $_REQUEST['search_type'] = 'false';

            $this->addUserSearchConditions($_REQUEST);
            $page_list_query = parent::getQuery('droppop', 1);
            $where = $this->getConditionalWhere();

            if ($where)
                $wheretable = ' and '.$where;
        }
        return array('wheretable'=>$wheretable,'page_list_query'=>$page_list_query);
    }

    public function related_key_where($r_keyids, $r_maxrowsshow)
    {
        $keywhere = '';
        $limit_sql = '';
        if ($this->module != 'Accounts' && $r_keyids != '' && $this->module != 'Vendors') {
            $field = $this->moduleobj->fieldobj->getFieldInfoobjBykey('uitype', 73);
            if ($field && $field->getFieldName() != "")
                $keywhere = ' and ' . $field->getTableName() . '.' . $field->getColumnName() . '=' . $r_keyids;
            $field = $this->moduleobj->fieldobj->getFieldInfoobjBykey('uitype', 81);
            if ($field && $field->getFieldName() != "") {
                $settype = getSalesEntityType($r_keyids);
                if ($settype == 'Vendors')//基金行业，合同选择代销协议
                    $keywhere = ' and ' . $field->getTableName() . '.' . $field->getColumnName() . '=' . $r_keyids;
            }
            $field = $this->moduleobj->fieldobj->getFieldInfoobjBykey('uitype', 82);//

            if ($field && $field->getFieldName() != "") {
                //30434: 项目进度新增界面：选择项目计划弹出层中的数据没有根据所选择的项目名称来显示
                $settype = getSalesEntityType($r_keyids);
                if ($settype == 'Project')
                    $keywhere = ' and ' . $field->getTableName() . '.' . $field->getColumnName() . '=' . $r_keyids;
            }
            if (!$field) {
                $limit_sql = ' limit 0,' . $r_maxrowsshow;
            }
        } else {
            //	$system_deploy=getSys_deploy(151);
            //  $deployvalue=$system_deploy['deploy_value'];
            //36928: （1.6）采购订单新增界面>供应商名称、供应商联系人姓名选择弹出层：显示的条数应该要根据“设置客户查重和选择客户列表每页显示记录的条数”这条参数进行控制。
            //0037168: （1.6）销售机会新增界面>选择联系人弹出框：显示条数根据【设置客户查重和选择客户/供应商列表每页显示记录的条数】参数设置的条数显示，手机端也需要做出对应的修改
            $limit_sql = ' limit 0,' . $r_maxrowsshow;
        }
        return array('keywhere' => $keywhere, 'limit' => $limit_sql);
    }
}
?>