<?php
class PricePolicyUtils
{
    public static function getModuleCondition() {
        global $currentModule;
        crm_load_class_file('CommonView',"modules/CustomView");
        crm_load_class_file('EffectiveCondition',"modules/Settings");
        crm_load_class_file('cls_AdvftOperate','include');

        $smarty = new lingdangCRM_Smarty();
        $module = $_REQUEST['fromModule'];
        //数据分类开始
        global $oCustomView;
        $oCustomView = new CustomView();
        $modulecollist = $oCustomView->getModuleColumnsList($module);
        $focus = CRMEntity::getInstance($module);
        $modulefields = $focus->fieldobj->getListSearchFields();
        $advfilterlist = EffectiveCondition::getAdvFilter();
        $includeDetail = $_REQUEST['includeDetail'] ?? 'no';
        $columns_block = EffectiveCondition::getByModule_ColumnsHTML($module,$modulecollist,$includeDetail);//高级查询select option
        $fLabels = cls_AdvftOperate::getAdvCriteria();
        $advfilterhtml = EffectiveCondition::getAdvCriteriaHTML('e',$fLabels);
        $moduleList = [ $module => getTranstab($module) ];

        $tmpModule = 'Accounts';
        if(array_key_exists($tmpModule,cls_module_uitype::getAllReferenceModules($module))) {
            $moduleList[$tmpModule] = getTranstab($tmpModule);
            $tmpFocus = CRMEntity::getInstance($tmpModule);
            $oCustomView = new CustomView();
            $accountsColList = $oCustomView->getModuleColumnsList($tmpModule);
            $accountsFields = $tmpFocus->fieldobj->getListSearchFields();
            $accountsBlock = EffectiveCondition::getByModule_ColumnsHTML($tmpModule,$accountsColList,$includeDetail);
        }

        $smarty->assign('module',$currentModule);
        $content = $smarty->fetch("ModuleScope.tpl");
        // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
        $controller = ListViewController::getInstance($module);
        return [
            'columns_block' => $columns_block,
            'flabels' => $fLabels,
            'btn_addnewcombinationtext' => getFixedLabel('NEWCOMBINATION'),
            'btn_addnewcondtiontext' => getFixedLabel('NEWCONDITIONS'),
            'datetimestr' => CommonView::stdFilterDateTimeStr(""),
            'advanceFields' => $controller->getAdvanceFields(),
            'foption' => $advfilterhtml,
            'title' => getFixedLabel("SetTheSourceEntryDetailsRange"),
            'oktext' => getFixedLabel("CONFIRMED"),
            'canceltext' => getFixedLabel("CANCEL"),
            'fieldinfo' => array_values($modulefields),
            'source' => 'PricePolicy_RoleModule',
            'moduleList' => $moduleList,
            'accountsFields' => array_values($accountsFields),
            'accountsBlock' => $accountsBlock,
            'content' => $content,
        ];
    }

    public static function getRoleModuleScope() {
        $row = json_decode($_REQUEST['row'],true);
        $tmpArr = [$row];
        self::getRoleModuleScopeLabel($tmpArr);
        return $tmpArr[0];
    }

    public static function getRoleModuleScopeLabel(&$rowList) {
        crm_load_class_file('cls_AdvftOperate','include');
        foreach ($rowList as &$row) {
            $advance_demand = is_array($row['advance_demand']) ? $row['advance_demand'] : json_decode($row['advance_demand']??"",true);
            $advance_demand_groups = is_array($row['advance_demand_groups']) ? $row['advance_demand_groups'] : json_decode($row['advance_demand_groups']??"",true);
            $AdvftOperateobj = cls_AdvftOperate::getInstance($row['module']);
            $advf_label = $AdvftOperateobj->TransAdvftTostring($advance_demand,$advance_demand_groups);
            $scopeLabel = explode('<br>',$advf_label);
            foreach ($advance_demand as $index => $info) {
                $colArr = explode(':',$info['columnname']);
                $module = explode('_',$colArr[3])[0];
                $scopeLabel[$index] = getTranstab($module).'：' . $scopeLabel[$index];
            }
            $row['advance_demand'] = $advance_demand;
            $row['advance_demand_groups'] = $advance_demand_groups;
            $row['scope'] = $scopeLabel;
        }
        return $rowList;
    }

    public static function getRoleModules ($focus) {
        global $adb;
        $colName = $focus->colList['roleModule'];
        $selected = [];
        if(!empty($focus->column_fields[$colName])) {
            $selected = explode(' |##| ', $focus->column_fields[$colName]);
        }

        /*获取所有带有产品明细的模块*/
        $query = 'select tabid,name from ld_tab order by tabsequence asc ';
        $result = $adb->pquery($query);
        $num_rows = $adb->num_rows($result);
        $productModule = array();
        $except = ['Productbom', 'ServiceCharge', 'ExpenseBudget'];
        for($i = 0; $i<$num_rows; $i++){
            $isModule = $adb->query_result($result,$i,'name');
            $isTabid = $adb->query_result($result,$i,'tabid');
            $label = getTranstab($isModule);
            if(in_array($label,$selected)) {
                $select = 'selected';
            }
            else {
                $select = '';
            }
            if(in_array($isModule, $except)) {
                continue;
            }
            if(vtlib_isModuleActive($isModule) != 1)
                continue;

            if($isModule=='Potentials'||get_file_address($isModule,'ProductDetails')){

                $productModule[$isModule] = [
                    $label,
                    $isModule,
                    $select,
                ];
            }
        }
        //ksort($productModule);
        return $productModule;
    }

    /** 获取连接ld_related_scope的sql */
    public static function getScopeLeftJoinSql($module){
        $scopeLabel = $module;
        return "select GROUP_CONCAT(relatedid) as scopeid,r.viewid 
                from ld_related_scope r 
                where r.modulename = '$module' and r.type = '$scopeLabel'
                group by viewid ";
    }
    /**
     * 获取有效期内的列表
     */
    public static function getValidityPolicy($focus, $fromFocus = '') {
        global $adb,$current_user;
        $curUserId = $current_user->id;
        $curGroupIdStr = $current_user->groupid;
        $curGroupId = array_pop(explode(',', $curGroupIdStr));
        $curProfileId = $current_user->profileid;
        $validity = [];
        $idCol = $focus->table_index;
        $colList = $focus->colList;
        $colStr = '';
        foreach ($colList as $col) {
            $colStr .= ' ' . $col . ',';
        }
        $colStr = substr($colStr, 0, -1);

        $startTimeCol = $colList['start'];
        $endTimeCol = $colList['end'];

        $scopeCol = $colList['scope'];
        $recommendedCol = $colList['recommended'];
        $priority = $colList['priority'];
        $approveStatusCol = $colList['approveStatus'];
        $table = $focus->table_name;
        $index = $focus->table_index;
        $leftJoin = self::getScopeLeftJoinSql($focus->module_name);

        $sql  = "SELECT $index, $colStr FROM $table p
                LEFT JOIN ( $leftJoin ) r ON r.viewid = p.$index
                WHERE deleted = 0 
                    AND (
                        CASE 
                            WHEN $scopeCol = 'all' THEN TRUE
                            WHEN $scopeCol = 'user' THEN FIND_IN_SET(?,r.scopeid)
                            WHEN $scopeCol = 'group' THEN FIND_IN_SET(?,r.scopeid)
                            WHEN $scopeCol = 'role' THEN FIND_IN_SET(?,r.scopeid)
                            ELSE FALSE
                        END
                    ) ";
        $param = [$curUserId, $curGroupId, $curProfileId];
        // 设置相关
        if(!empty($fromFocus)) {
            crm_load_class_file('PricePolicySetting','modules/PricePolicy');
            $setObj = new PricePolicySetting();
            $effectNode = $setObj->getAffectNode();
            $timeCol = $setObj->getAccordingTo($fromFocus->module_name);
            $timeField = $fromFocus->fieldobj->getFieldInfoobjBykey('columnname',$timeCol);
            $timeVal = time();
            if(!empty($timeField)) {
                $timeFieldName = $timeField->getFieldName();
                $timeFieldVal = $fromFocus->column_fields[$timeFieldName];
                if(!empty($timeFieldVal)) {
                    $timeVal = strtotime($timeFieldVal);
                }
            }
            $timeVal = date('Y-m-d H:i:s', $timeVal);
            if($effectNode === 'approved') {
                $sql .= " AND $approveStatusCol = ? ";
                array_push($param, '已批准');
            }
            // 时间设置
            $sql .= " AND $startTimeCol < ? AND $endTimeCol > ? ";
            array_push($param, $timeVal, $timeVal);
        }
        // 排序SQL
        $sql .= " ORDER BY $recommendedCol DESC, $priority ;";
        $result = $adb->pquery($sql,$param);
        //dump($result);
        $num = $adb->num_rows($result);
        if($num > 0) {
            for($i = 0; $i < $num; $i ++) {
                $item = [];
                foreach ($colList as $key => $col) {
                    $item[$key] = $adb->query_result($result,$i,$col);
                }
                $item['recommended'] = $item['recommended'] === '0' ? 'no' : 'yes';
                $item['default'] = $item['default'] === '0' ? 'no' : 'yes';
                $item['sequence'] = $i;
                $item['id'] = $adb->query_result($result,$i,$index);
                $validity['id_'.$item['id']] = $item;
                //array_push($validity,$item);
            }
        }
        return $validity;
    }

    public static function getPricePolicyBlock($fromModule) {
        crm_load_class_file('PricePolicyBlock','modules/PricePolicy');
        $obj = new PricePolicyBlock($fromModule);
        return $obj->getBlockInfo();
    }
    public static function getPricePolicyBlockRequest() {
        $fromModule = $_REQUEST['fromModule'];
        crm_load_class_file('PricePolicyBlock','modules/PricePolicy');
        $obj = new PricePolicyBlock($fromModule);
        return $obj->getBlockInfo();
    }

    public static function getPricePolicyScopeLabel($module, $value) {
        $focus = CRMEntity::getInstance($module);
        $label = '';
        foreach ($focus->pricePolicyScope as $index => $info) {
            if($info['value'] === $value) {
                $label = $info['label'];
                break;
            }
        }
        if($value !== 'all') {
            crm_load_class_file("cls_related_scope",'include/utils');
            $scopeVal = cls_related_scope::get_related_scope($module, $module, $focus->id);
            $scopeLabelArr = [];
            if($value === 'user') {
                foreach ($scopeVal as $userId) {
                    $scopeLabelArr[] = getUserFullName($userId);
                }
            }
            elseif($value === 'group') {
                foreach ($scopeVal as $groupId) {
                    $scopeLabelArr[] = getGroupFullName($groupId);
                }
            }
            elseif($value === 'role') {
                $profile_focus = new Profile();
                $allProfile = $profile_focus->getProfileArray();
                foreach ($scopeVal as $profileId) {
                    $scopeLabelArr[] = $allProfile[$profileId];
                }
            }
            $label .= "：" . implode(',', $scopeLabelArr);
        }
        return $label;
    }

    public static function saveHideChoose() {
        $value = $_REQUEST['showHidden'];
        crm_load_class_file('PricePolicyBlock','modules/PricePolicy');
        $fromModule = $_REQUEST['fromModule'];
        $obj = new PricePolicyBlock($fromModule);
        setUsersettingByLabel($obj->module, '', $obj->hideUnavailableLabel, $value);
        return [];
    }

    public static function getSetInfo() {
        crm_load_class_file('PricePolicySetting','modules/PricePolicy');
        $obj = new PricePolicySetting();
        return $obj->getInfo();
    }

    public static function saveSetValue() {
        crm_load_class_file('PricePolicySetting','modules/PricePolicy');
        $obj = new PricePolicySetting();
        return $obj->saveSetValueByType($_REQUEST['type'], $_REQUEST['value']);
    }

    public static function getFocus() {
        return CRMEntity::getInstance('PricePolicy');
    }

    public static function updatePolicyList() {
       // $_REQUEST['productLicencePrice']=0;
        $fromModule = $_REQUEST['fromModule'];
        $fromFocus = CRMEntity::getInstance($fromModule);
        setObjectValuesFromRequest($fromFocus);
        crm_load_class_file('PricePolicyBlock','modules/PricePolicy');
        $obj = new PricePolicyBlock($fromModule);
        return $obj->getValidityListWithDetail($fromModule);
    }

}