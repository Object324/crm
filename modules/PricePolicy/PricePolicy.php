<?php

class PricePolicy extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['PricePolicy']='PricePolicy';
        if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules])) {
            globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
            include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
        }
    }
    public $id;
    public $db;
    var $table_name = "ld_pricepolicy";
    var $table_index= 'pricepolicyid';//主表主键
    var $table_code='pricepolicy_no';//表编号字段(审批中心)
    var $tab_name = Array('ld_crmentity','ld_pricepolicy');
    //定义各个表主键
    var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_pricepolicy'=>'pricepolicyid');
    var $entity_table = "ld_crmentity";
    var $Detail_table="ld_pricepolicydetail";//明细表名称
    var $Detail_table_id="id";//明细表id
    var $Detail_table_scf = "ld_pricepolicydetailscf";//明细scf表
    var $Detail_table_index="id";//明细表和主表关联的字段
    var $customFieldTable = Array('ld_pricepolicyscf', 'pricepolicyid');//自定义字段所存储的表
    var $column_fields = Array();
    var $module_name='PricePolicy';
    //和主表关联的模块
    var $relatedtab=array('accounts'=>'','pricepolicy'=>'','users'=>'','company'=>'','vendors'=>'');
    var $sortby_fields = Array('pricepolicy_no','pricepolicy_name');
    var $list_link_field= 'pricepolicy_no';

    var $search_fields = Array(
        'PricePolicy No'=>array('ld_pricepolicy'=>'pricepolicy_no'),
        'PricePolicy Name'=>array('ld_pricepolicy'=>'pricepolicy_name'),
        'start_time'=>array('ld_pricepolicy'=>'start_time'),
        'end_time'=>array('ld_pricepolicy'=>'end_time'),
        'description'=>Array('ld_pricepolicy'=>'description'),
    );

    var $search_fields_name = Array(
        'PricePolicy Name'=>'pricepolicy_name',
        'Assigned To'=>'assigned_user_id',
    );
    var $required_fields =  array();
    //比录项
    var $mandatory_fields = Array('assigned_user_id', 'start_time', 'end_time', 'description');
    var $default_order_by = 'pricepolicy_no';
    var $default_sort_order = 'ASC';

    // For Alphabetical search
    //拼音查询字段
    var $def_basicsearch_col = 'pricepolicy_no';
    var $popup_fields=Array();
    var $colList = [
        'name' => 'pricepolicy_name',
        'type' => 'pricepolicy_type',
        'form' => 'pricepolicy_forms',
        'scope' => 'pricepolicy_scope',
        'roleModule' => 'role_module',
        'roleModuleScope' => 'role_module_scope',
        'start' => 'start_time',
        'end' => 'end_time',
        'default' => 'bydefault',
        'recommended' => 'recommended',
        'priority' => 'priority',
        'superpositionList' => 'superposition_list',
        'approveStatus' => 'approvestatus',
    ];
    var $pricePolicyScope = [
        ['label'=> '全部', 'value' => 'all'],
        ['label'=> '按部门', 'value' => 'group'],
        ['label'=> '按用户', 'value' => 'user'],
        ['label'=> '按角色', 'value' => 'role'],
    ];
    function __construct() {
        $this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('PricePolicy',$this->db);
        $this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        crm_load_class_file('TabDetailFields','include/TabDetailFields');
        $this->detailfieldobj=TabDetailFields::getInstance($this->module_name);
        /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('PricePolicy');
        $this->list_link_field=$entityname['fieldname'];
        $this->popup_fields=Array($this->list_link_field);
    }

    function  save_module($module)
    {
        global $adb;
        $record = $this->id;
        $tableName = $this->table_name;
        $tableIndex = $this->table_index;

        $querySql = "SELECT superposition_list FROM $tableName WHERE $tableIndex = ?";
        $queryRes = $adb->pquery($querySql, [$record]);
        $oldSuperposition = $adb->query_result($queryRes, 0, 'superposition_list');

        // 保存模块适用范围、政策范围、可叠加政策
        $sql = "UPDATE $tableName SET role_module_scope=?, pricepolicy_scope=?, superposition_list=? WHERE $tableIndex = ?;";
        $roleModuleScope = json_encode(json_decode($_REQUEST['roleModuleData'],true));
        $scopeArr = json_decode($_REQUEST['scopeData'],true);
        $pricePolicyScope = $scopeArr['scope'];
        $superpositionList = $_REQUEST['superPositionData'];
        $adb->pquery($sql, [ $roleModuleScope, $pricePolicyScope, $superpositionList, $record ]);

        // 保持可叠加政策的双向性
        $superpositionSql = "UPDATE ld_pricepolicy SET superposition_list = IF(superposition_list = '' OR superposition_list IS NULL, ?, CONCAT(superposition_list,',',?))
		                        WHERE FIND_IN_SET(pricepolicyid,?) AND !FIND_IN_SET(?,superposition_list);";
        $adb->pquery($superpositionSql, [ $record, $record, $superpositionList, $record ]);

        $diffSet = array_diff( explode(',', $oldSuperposition), explode(',', $superpositionList) );
        if(!empty($diffSet)) {
            $diffSuper = implode(',', $diffSet );
            $diffSql = "UPDATE ld_pricepolicy SET superposition_list = (
                            CASE
                                WHEN LOCATE(CONCAT(?,','), superposition_list) THEN REPLACE(superposition_list, CONCAT(?,','), '')
                                WHEN LOCATE(CONCAT(',',?), superposition_list) THEN REPLACE(superposition_list, CONCAT(',',?),'')
                                ELSE ''
                            END
                        )
                        WHERE FIND_IN_SET(pricepolicyid,?) AND FIND_IN_SET(?,superposition_list);";
            $adb->pquery($diffSql, [ $record, $record, $record, $record, $diffSuper, $record ]);
        }


        crm_load_class_file("cls_related_scope",'include/utils');
        if($pricePolicyScope == 'all'){
            crm_load_class_file("cls_related_scope",'include/utils');
            cls_related_scope::delete_related_scope($module,$module,$record);
        }
        else{
            crm_load_class_file("cls_related_scope",'include/utils');
            cls_related_scope::save_related_scope($module,$module,$record,explode(',',$scopeArr['scopeVal']));
        }

        $detailTable = $this->Detail_table;
        $detailIndex = $this->Detail_table_index;
        $delSql = "DELETE FROM $detailTable WHERE $detailIndex = ?;";
        $adb->pquery($delSql,[$record]);
        $insertSql = "INSERT INTO $detailTable ($detailIndex, productid, `condition`, present, content) VALUES ";
        $insertParam = [];
        $details = json_decode($_REQUEST['detailData'],true)['val'];
        foreach ($details as $index => $detail) {
            $tmpProductId = $detail['productid'];
            $tmpCondition = json_encode($detail['condition']);
            $tmpPresent = $detail['present'];
            $tmpContent = $detail['content'];
            $insertSql .= " (?,?,?,?,?) ,";
            array_push($insertParam, $record, $tmpProductId, $tmpCondition, $tmpPresent, $tmpContent);
        }
        $insertSql = substr($insertSql, 0, -1);
        $adb->pquery($insertSql,$insertParam);
    }

    public function checkEditInfo() {

    }

}

PricePolicy::require_file();
?>