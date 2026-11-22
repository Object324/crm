<?php

/**
 * // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
 */
class AdvanceSearchUtil
{
    public static function spacialAdvancedSearchCriteria($module, &$advfilterlist) {
        if((is_array($advfilterlist) && count($advfilterlist) === 0) || empty($advfilterlist))
            return $advfilterlist;
        $focus = CRMEntity::getInstance($module);
        $fieldObj = $focus->fieldobj;
        $detailFieldObj = $focus->detailfieldobj;
        $userFiledArr = ['users', 'selectoneuser', 'selectmultiuser'];
        $oldBelongArr = ['belong', 'notbelong'];
        $newBelongArr = ['new_belong', 'new_notbelong'];
        $allfield_arr= $fieldObj->getModuleAllPreseneceFields();
        if($detailFieldObj)
            $alldetail_arr = $detailFieldObj->getModuleAllPreseneceFields();
        foreach ($advfilterlist as $groupIndex => $groupInfo) {
            foreach ($groupInfo['columns'] as $columnIndex => $columnInfo) {
                $columnArr = explode(':', $columnInfo['columnname']);
                $tmpColName = $columnArr[1];
                $tmpfieldname=$columnArr[2];


                if(!array_key_exists($tmpfieldname,$allfield_arr))
                {
                    continue;

                }
                $fieldInfo = $allfield_arr[$tmpfieldname];

                if($detailFieldObj)
                    $fieldInfo = $alldetail_arr[$tmpColName];
                if(empty($fieldInfo))
                    continue;
                $bigType = $fieldInfo->getBigType();
                $comparator = $columnInfo['comparator'];
                $value = $columnInfo['value'];
                $valueLabel = $columnInfo['valueLabel'];
                if(in_array($bigType, $userFiledArr) ) {
                    if(in_array($comparator, $oldBelongArr)) {
                        $newVal = self::getUserIdByValueStr('like', $columnInfo['value']);
                        $advfilterlist[$groupIndex]['columns'][$columnIndex]['value'] = $newVal['id'];
                        $advfilterlist[$groupIndex]['columns'][$columnIndex]['valueLabel'] = $newVal['name'];
                        $newComparator = 'new_' . $comparator;
                        $advfilterlist[$groupIndex]['columns'][$columnIndex]['comparator'] = $newComparator;
                        $advfilterlist[$groupIndex]['columns'][$columnIndex]['search_comparator'] = $newComparator;
                        continue;
                    }
                    if(in_array($comparator, $newBelongArr) && !empty($value) && empty($valueLabel)) {
                        $advfilterlist[$groupIndex]['columns'][$columnIndex]['valueLabel'] = self::getValueLabelByIdStr($value);
                        continue;
                    }
                }
            }
        }
        return $advfilterlist;
    }

    /**
     * 通过匹配规则和值获取对应的用户字符串
     * @param $type string 匹配规则
     * @param $value string 值, "|"线分割多个值
     */
    public static function getUserIdByValueStr($type, $value) {
        $delimiterPattern = '/[|]/';  // BUG20240527-55 属于和不属于的分割符号更改为“|”
        $value_arr = preg_split($delimiterPattern, $value);
        $userIds = [];
        $userNames = [];
        foreach ($value_arr as $index => $tmpVal) {
            if($tmpVal!=''){
                $tmpUserInfos = self::getUserIdByOneValue($type, $value);
                $userIds = array_merge($userIds, $tmpUserInfos['idArr']);
                $userNames = array_merge($userNames, $tmpUserInfos['nameArr']);
            }
        }
        $userIds = array_unique($userIds);
        $userNames = array_unique($userNames);
        return [
            'id' => implode(',', $userIds),
            'name' => implode(',', $userNames),
        ];
    }

    public static function getUserIdByOneValue($type, $value) {
        global $adb;
        $iskehu001=isKehu001ServerPc();
        $userIds = [];
        $userNames = [];
        if($type === 'like') {
            $result = false;
            if($iskehu001 === 'yes') {
                crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
                $port_obj = new cls_WeixinPort();
                $wx_userArr =$port_obj->getwxUserid($type, $value);
                if(array_key_exists('userid',$wx_userArr))
                {
                    $wx_userid = implode("','",$wx_userArr['userid']);
                    $wx_userid = "'".$wx_userid."'";
                    $sql = 'select id, last_name from ld_users where wx_userid in( '.$wx_userid.') ';
                    $result = $adb->pquery($sql,array());
                }
            }
            else {
                $sql="select id, last_name  from ld_users where last_name like ?;";
                $value = "%$value%";
                $result=$adb->pquery($sql, [ $value ]);
            }
            if($result) {
                $num = $adb->num_rows($result);
                if ($num > 0) {
                    for ($i = 0; $i < $num; $i++) {
                        $id = $adb->query_result($result, $i, 'id');
                        $name = $adb->query_result($result, $i, 'last_name');
                        $userIds[] = $id;
                        $userNames[] = $name;
                    }
                }
            }
        }
        return [
            'idArr' => $userIds,
            'nameArr' => $userNames,
        ];
    }

    public static function getValueLabelByIdStr($value) {
        global $adb;
        $delimiterPattern = '/[|]/';  // BUG20240527-55 属于和不属于的分割符号更改为“|”
        $valueStr = preg_replace($delimiterPattern, ',', $value);
        $sql = "SELECT GROUP_CONCAT(last_name) AS name_str FROM ld_users WHERE FIND_IN_SET(id, ?);";
        $result = $adb->pquery($sql, [$valueStr]);
        $nameStr = '';
        if($adb->num_rows($result) > 0) {
            $nameStr = $adb->query_result($result, 0, 'name_str');;
        }
        return $nameStr;
    }

    public static function getAvailableKeyValueByFieldName($opt) {
        $module = $opt['fromModule'];
        $columnName = $opt['columnName'];
        $comparator = $opt['comparator'];
        $columnModule =$opt['columnModule'];
        $value = (string)$opt['value'];
        $valueArr = explode('|', $value);
        if(empty($module)) {
            return [];
        }
        if ($module == 'ServiceCharge' && $columnModule == 'Products'){
            $columnModule = 'ServiceContracts';
        }
        $focus = CRMEntity::getInstance($module);
        $fieldObj = $focus->fieldobj;
        $detailFieldObj = $focus->detailfieldobj;
        $alldetail_arr= [];
        if($detailFieldObj)
            $alldetail_arr = $detailFieldObj->getModuleAllPreseneceFields();
        $fieldInfo = $fieldObj->getFieldInfoobjBykey("columnname", $columnName);
        if(empty($fieldInfo))
            $fieldInfo = $alldetail_arr[$columnName];
        if(empty($fieldInfo)) {
            $colModule = ucfirst($columnModule); // ucfirst 首字母大写 部分 products 、 contacts ;
            $colFocus = CRMEntity::getInstance($colModule);
            $colFieldObj = $colFocus->fieldobj;
            $colDetailFieldObj = $colFocus->detailfieldobj;
            $colalldetail_arr= [];
            if($colDetailFieldObj)
                $colalldetail_arr = $colDetailFieldObj->getModuleAllPreseneceFields();
            $fieldInfo = $colFieldObj->getFieldInfoobjBykey("columnname", $columnName);
            if(empty($fieldInfo))
                $fieldInfo = $colalldetail_arr[$columnName];
        }
        if(empty($fieldInfo))
            return 'failed';
        $fieldname = $fieldInfo->getFieldName();
        $optionValue = [];
        $bigType = $fieldInfo->getBigType();
        $tmpBol = false;
        if(!$tmpBol) {
            if ($fieldname == 'publicaccount' && ($module == 'Accounts' || $module == 'Leads')){
                //普通
                $bigType = 'picklist';
                if ($module == 'Accounts'){
                    $optionValue[] = array('label' => getFixedLabel('COMMONACCOUNT'), 'value' => getFixedLabel('COMMONACCOUNT'), 'selected' => 'selected', 'color' =>'');
                }else{
                    $optionValue[] = array('label' => getFixedLabel('COMMONLEADS'), 'value' => getFixedLabel('COMMONLEADS'), 'selected' => 'selected', 'color' =>'');
                }
                //已分配未分配
                $optionValue[] = array('label' => getFixedLabel('LBL_NOALLOCATE'), 'value' => getFixedLabel('LBL_NOALLOCATE'), 'selected' => '', 'color' =>'');
                $optionValue[] = array('label' => getFixedLabel('LBL_PUBLICALLOCATE'), 'value' => getFixedLabel('LBL_PUBLICALLOCATE'), 'selected' => '', 'color' =>'');
            }else{
                crm_load_function_file('getAssignedPicklistValues', 'modules/PickList', 'PickListUtils');
                $optionValue = getEditViewPagePickList($fieldname, $valueArr[0], $fieldInfo->getUIType(), $fieldInfo);
                if(isset($optionValue['selectedIndex'])) {
                    $optionValue = $optionValue['option'];
                }
                else {
                    foreach ($optionValue as $index => $item) {
                        $optionValue[$index] = [
                            'label' => $item[0],
                            'value' => $item[1],
                            'selected' => $item[2],
                            'color' => $item[3],
                        ];
                    }
                }
            }
        }
        if(count($optionValue) > 0) {
            $comparatorArr = ['belong', 'notbelong'];
            if(in_array($comparator, $comparatorArr)) {
                foreach ($optionValue as $index => $option) {
                    $tmpFlag = false;
                    foreach ($valueArr as $value) {
                        // 包含
                        if(strpos($option['value'], $value) !== false) {
                            $tmpFlag = true;
                            break;
                        }
                    }
                    if($tmpFlag) {
                        $optionValue[$index]['selected'] = 'selected';
                    }
                }
            }
            else {
                foreach ($optionValue as $index => $option) {
                    $tmpFlag = false;
                    foreach ($valueArr as $value) {
                        // 相等
                        if($option['value'] === $value) {
                            $tmpFlag = true;
                            break;
                        }
                    }
                    if($tmpFlag) {
                        $optionValue[$index]['selected'] = 'selected';
                    }
                }
            }
        }
        return $optionValue;
    }
    // edit: xll 2024/11/22 XUQIU1001599 单据序时簿列表界面，高级查找增加“平铺”和“清除筛选值”功能
    public static function saveAdvanceTiled($opt) {
        global $current_user;
        $advft_criteria = isset($opt['advft_criteria']) ? $opt['advft_criteria'] : '';
        $advft_criteria_arr = json_decode($advft_criteria, true);
        foreach ($advft_criteria_arr as $columnindex => $columninfo){
            $columninfo['value'] = '';
            $columninfo['valueLabel'] = '';
            $advft_criteria_arr[$columnindex] = $columninfo;
        }
        $advft_criteria = json_encode($advft_criteria_arr);
        $module = $opt['module'];
        $label = 'AdvanceTiledShow_';
        if (!empty($opt['viewid'])){
            $viewId = $opt['viewid'];
        }else{
            $customView = CustomView::getInstance($module);
            $viewId = $customView->getViewId($module);
        }
        if(empty($viewId)) {
            return 'failed';
        }
        $label = $label.$viewId;
        setUsersettingByLabel($module, $current_user->id, $label, $advft_criteria);
        return 'success';
    }

    public static function getAdvanceTiled($opt) {
        global $current_user;
        $module = $opt['module'];
        $label = 'AdvanceTiledShow_';
        $customView = CustomView::getInstance($module);
        $viewId = $customView->getViewId($module);
        if(empty($viewId)) {
            return 'failed';
        }
        $label = $label.$viewId;
        return getUsersettingByLabel($module, $current_user->id, $label);
    }

    //列表平铺字段展开收起记住
    public static function setAdvanceTiledShowStatus($opt)
    {
        global $current_user;
        $module = $opt['module'];
        $status = $opt['status'];
        $label = 'AdvanceTiledShowStatus_';
        if (!empty($opt['viewid'])){
            $viewId = $opt['viewid'];
        }else{
            $customView = CustomView::getInstance($module);
            $viewId = $customView->getViewId($module);
        }
        if(empty($viewId)) {
            return 'failed';
        }
        $label = $label.$viewId;
        setUsersettingByLabel($module, $current_user->id, $label, $status);
        return 'success';
    }

    public static function getAdvanceTiledShowStatus($module)
    {
        global $current_user;
        $label = 'AdvanceTiledShowStatus_';
        $customView = CustomView::getInstance($module);
        $viewId = $customView->getViewId($module);
        if(empty($viewId)) {
            return 'failed';
        }
        $label = $label.$viewId;
        return getUsersettingByLabel($module, $current_user->id, $label);
    }
}