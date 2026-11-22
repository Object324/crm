<?php

class PricePolicyBlock
{
    public $module = 'PricePolicy';
    public $hideUnavailableLabel = 'hideUnavailable';
    public $focus;
    public $detailObj;
    public $fromModule;
    public $fromFocus;
    public $detailsHtmlObj;
    public $orderTotal;
    public $productDetailData;
    public function __construct($fromModule, $detaisHtmlObj='') {
        $this->focus = CRMEntity::getInstance($this->module);
        $this->fromModule = $fromModule;
        if(!empty($fromModule)) {
            $this->fromFocus = CRMEntity::getInstance($fromModule);
        }
        if(!empty($detaisHtmlObj)) {
            $this->detailsHtmlObj = $detaisHtmlObj;
        }
    }

    public static function getInstance() {

    }

    public function getDetailObj() {
        if(empty($this->detailObj)) {
            crm_load_class_file('PricePolicyDetailFieldsHtml', 'modules/PricePolicy');
            crm_load_function_file('setProductsInfo', 'include/utils', 'ListViewUtils');
            $this->detailObj = new PricePolicyDetailFieldsHtml($this->focus, $this->module);
        }
        return $this->detailObj;
    }

    public function getBlockInfo() {
        $module = $this->module;
        $list = $this->getValidityListWithDetail();
        $hideUnavailable = getUsersettingByLabel($module, '', $this->hideUnavailableLabel);
        if(empty($hideUnavailable)) {
            $hideUnavailable = 'no';
        }
        return [
            'title' => getTranstab($module),
            'conId' => 'PricePolicyBlock',
            'hideUnavailable' => $hideUnavailable,
            'val' => $list,
        ];
    }

    public function getValidityListWithDetail( ) {
        $fromModule = $this->fromModule;
        $fromFocus = $this->fromFocus;
        crm_load_class_file('PricePolicyUtils','modules/PricePolicy');
        $validity = PricePolicyUtils::getValidityPolicy($this->focus, $fromFocus);
        if(count($validity) === 0) {
            return [
                'validity' => [],
                'selected' => [],
                'fields' => [],
            ];
        }
        $this->getOrderTotal();
        crm_load_class_file('cls_fieldsearchcondition','include/utils/');
        $fieldSearchObj = cls_fieldsearchcondition::getInstance($fromModule);
        $fieldSearchObj->setRecord($fromFocus->id);
        $fieldSearchObj->setModuleFieldNameValArr($fromModule,$fromFocus->column_fields);
        $accountCol = "accountid";
        $accountField = $fromFocus->fieldobj->getFieldInfoobjBykey('columnname', $accountCol);
        $accountModule = "Accounts";
        if(!empty($accountField) && $accountField instanceof fieldInfo) {
            $accountFieldName = $accountField->getFieldName();
            if(!empty($fromFocus->column_fields[$accountFieldName])) {
                $accountFocus = CRMEntity::getInstance($accountModule);
                $accountFocus->id = $fromFocus->column_fields[$accountFieldName];
                $accountFocus->retrieve_entity_info($accountFocus->id, $accountModule);
                $fieldSearchObj->setModuleFieldNameValArr($accountModule, $accountFocus->column_fields);
            }
        }
        $available = [];
        $unavailable = [];
        $fromLabel = getTranstab($fromModule);
        $fields = [];
        $selected = $_REQUEST['selected'] ?? $this->getSelectedPolicy();
        $selectedArr = isset($selected)?explode(',', $selected):[];
        $superpositionListArr=[];
        if(!empty($selected) && !empty($selectedArr)) {
            // 非已选，再判断是否互斥
            $isFirst = "yes";
            foreach ($selectedArr as $selPolicyId) {
                $this->updateSuperposition($validity, $selPolicyId, $isFirst, $superpositionListArr);
            }
        }
        $defaultSelectedJsonStr = $_REQUEST['defaultSelected'] ?? '';
        if(!empty($defaultSelectedJsonStr)) {
            $defaultSelected = json_decode($defaultSelectedJsonStr, true);
        }
        else {
            $defaultSelected = [];
        }
        $defaultPolicyArr = [];

        foreach ($validity as $tmpKey => &$info) {
            $tmpPolicyId = explode('_', $tmpKey)[1];
            $this->focus->id = $info['id'];
            $roleModuleArr = explode(' |##| ', $info['roleModule']);
            // 去除非当前模块的价格政策
            if(!in_array($fromLabel,$roleModuleArr)) {
                continue;
            }
            if(in_array($tmpPolicyId, $selectedArr)) {
                $info['selected'] = 'yes';
            }
            $roleModuleScope = $info['roleModuleScope'] = json_decode($info['roleModuleScope'], true);
            $flag = true;
            foreach ($roleModuleScope as $i => $scopeInfo) {
                $scopeModule = $scopeInfo['module'];
                if($scopeModule !== $fromModule) {
                    unset($roleModuleScope[$i]);
                    continue;
                }
                $tmp_advance_demand = $scopeInfo['advance_demand']??'';
                if(!empty($tmp_advance_demand)) {
                    $flag = $flag && $fieldSearchObj->getresultbySearchconditioninfo([
                            'advft_criteria' => $scopeInfo['advance_demand'],
                            'advft_criteria_groups' => $scopeInfo['advance_demand_groups'],
                            'searchtype' => 'advance',
                        ]);
                }
                $advance_demands = json_decode($tmp_advance_demand,true);
                foreach ($advance_demands as $advance_demand) {
                    $col = $advance_demand['columnname'];
                    if(!empty($col)) {
                        $colArr = explode(':', $col);
                        $columName = $colArr[1];
                        $fieldName = $colArr[2];
                        $fieldModule = explode('_', $colArr[3])[0];
                        if(!empty($fieldName)) {
                            if($fieldModule === $accountModule) {
                                $tmpField = $fromFocus->fieldobj->getFieldInfoobjBykey('columnname','accountid');
                                $fieldName = $tmpField->getFieldName();
                                $tableName = $tmpField->getTableName();
                                $columName = $tmpField->getColumnName();
                                $typeOfDataArr = explode('~',$tmpField->getTypeOfData());
                                $col = $tableName.":".$columName.":".$fieldName.":".$scopeModule."_fieldlabel:".$typeOfDataArr[0];
                            }
                            $fields[$columName] = $col;
                        }
                    }
                }
            }
            $roleModuleScope = array_merge($roleModuleScope);
            $this->getPolicyContent($info, $fromFocus);
            // 时间格式化
            $info['start'] = date('Y/n/d',strtotime($info['start']));
            $info['end'] = date('Y/n/d',strtotime($info['end']));
            // 是否可选判断
            $info['unavailable'] = 'no';
            $info['unavailableCause'] = [];
            // 条件不满足
            if(!$flag) {
                $info['unavailable'] = 'yes';
                $label = PricePolicyUtils::getRoleModuleScopeLabel($roleModuleScope)[0]['scope'];
                array_push($info['unavailableCause'], '条件不满足！');
                $info['unavailableCause'] = array_merge($info['unavailableCause'],$label);
            }
            // 门槛不满足
            if ($info['thresholdFlag'] === false) {
                $info['unavailable'] = 'yes';
                array_push($info['unavailableCause'], '门槛不满足！');
            }
            $tmpSuperpositionListArr = explode(",",$info['superpositionList']);
            $superpositionFlag = false;
            if(!empty($selected)) {
                if(in_array($tmpPolicyId, $selectedArr)) {
                    $info['selected'] = 'yes';
                    $superpositionFlag = true;
                }
                else {
                    if(in_array($tmpPolicyId,$superpositionListArr))
                    {
                        $superpositionFlag=true;
                    }
                    else
                    {
                        $tmpSelectedArr = array_intersect($selectedArr, $tmpSuperpositionListArr);
                        if(sizeof($tmpSelectedArr) >= sizeof($selectedArr))
                            $superpositionFlag=true;
                    }
                }
            }
            else {
                $superpositionFlag = true;
            }
            if(!$superpositionFlag) {
                $info['unavailable'] = 'yes';
                array_push($info['unavailableCause'], '不可叠加！');
            }
            // 可用且默认政策，直接选中
            if($info['unavailable'] === 'no' && $info['default'] === 'yes' && !in_array($tmpPolicyId, $selectedArr) && !$defaultSelected[$tmpPolicyId]) {
                $info['selected'] = 'yes';
                if(empty($selected)) {
                    $selectedArr = [$tmpPolicyId];
                    $selected = $tmpPolicyId;
                    $this->updateSuperposition($validity, $tmpPolicyId, 'yes', $superpositionListArr);
                }
                else {
                    array_push($selectedArr, $tmpPolicyId);
                    $selected = implode(',', $selectedArr);
                    $this->updateSuperposition($validity, $tmpPolicyId, 'no', $superpositionListArr);
                }
                $this->updateOrderTotal($info);
                array_push($defaultPolicyArr, $tmpPolicyId);

            }

            if ($info['unavailable'] === 'yes') {
                array_push($unavailable, $info);
            }
            else {
                array_push($available, $info);
            }
        }

        // 含有默认选中的政策，还需对 前面已筛选的可用政策进行可叠加判断
        $defaultNum = count($defaultPolicyArr);
        $lastDefaultPolicyId = $defaultPolicyArr[$defaultNum - 1];
        if($defaultNum > 0) {
            foreach ($available as $index => $policyInfo) {
                $policyId = $policyInfo['id'];
                if(!in_array($policyId, $selectedArr) && !in_array($policyId,$superpositionListArr)) {
                    $tmpSuperpositionListArr = explode(",",$policyInfo['superpositionList']);
                    $tmpSelectedArr = array_intersect($selectedArr, $tmpSuperpositionListArr);
                    if(sizeof($tmpSelectedArr) < sizeof($selectedArr)) {
                        $policyInfo['unavailable'] = 'yes';

                        foreach ($unavailable as $tmpIndex => $tmpPolicyInfo) {
                            if($policyInfo['sequence'] < $tmpPolicyInfo['sequence']) {
                                array_splice($unavailable, $tmpIndex, 0, [$policyInfo]);
                            }
                        }

                        unset($available[$index]);
                    }
                }
                if($policyId === $lastDefaultPolicyId) {
                    break;
                }
            }
        }
        return [
            'validity' => array_merge($available, $unavailable),
            'selected' => empty($selected) ? [] : $selectedArr,
            'fields' => $fields,
        ];
    }

    public function updateSuperposition($validity, $selPolicyId, $isFirst, &$superpositionListArr) {
        $selPolicyInfo=$validity[$selPolicyId];

        if (!empty($selPolicyInfo)) {
            $tmpSuperpositionListArr = explode(',',$selPolicyInfo['superpositionList']);//可叠加列表
            if($isFirst === 'yes') {
                $superpositionListArr = $tmpSuperpositionListArr;
                $isFirst = 'no';
            }
            else {
                if(!empty($tmpSuperpositionListArr) && count($tmpSuperpositionListArr) > 0) {
                    $superpositionListArr = array_intersect($superpositionListArr, $tmpSuperpositionListArr);
                }
            }
        }
    }

    public function getPolicyContent(&$info) {
        $this->focus->id = $info['id'];
        $module = $this->module;
        $record = $this->focus->id;
        $detailObj = $this->getDetailObj();
        if(!empty($record) ) {
            $flag = false;
            $maxFlag = true;
            $form = $info['form'];
            $details = $detailObj->getDetailData();
            $funName = "getLabel_" . $form;
            $label = [];
            if(method_exists($this, $funName)) {
                foreach ($details as &$detail) {
                    array_push($label, $this->$funName($detail));

                    $tmpFunName = 'getThreshold_'.$info['type'];
                    if(method_exists($this, $tmpFunName)) {
                        if($info['selected'] === 'yes') {
                            $detail['thresholdFlag'] = true;
                        }
                        else {
                            $detail['thresholdFlag'] = $this->$tmpFunName($detail);
                        }
                        // 门槛flag 满足一个即为 true
                        $flag = $flag || $detail['thresholdFlag'];
                        // 最大门槛flag 全部都满足即为 true
                        $maxFlag = ($maxFlag && $detail['thresholdFlag']);
                    }
                }
            }
            $info['thresholdFlag'] = $flag;
            $info['maxThresholdFlag'] = $maxFlag;
            $info['label'] = $label;
            $info['value'] = $details;
        }
    }

    public function getLabel_product_discount ($detail) {
        $productName = $detail['productname'] ?? '';
        return '购买'.$productName.'满'.$detail['condition'][0].'至'.$detail['condition'][1].'个，产品单价降价'.$detail['content'].'%';
    }

    public function getLabel_product_reduced ($detail) {
        $productName = $detail['productname'] ?? '';
        return '购买'.$productName.'满'.$detail['condition'][0].'至'.$detail['condition'][1].'个，产品单价减免'.$detail['content'];
    }

    public function getLabel_product_fixed ($detail) {
        $productName = $detail['productname'] ?? '';
        return '购买'.$productName.'满'.$detail['condition'][0].'至'.$detail['condition'][1].'个，产品单价降至'.$detail['content'];
    }

    public function getLabel_product_present ($detail) {
        $productName = $detail['productname'] ?? '';
        $presentName = $detail['presentName'] ?? '';
        return '购买'.$productName.'满'.$detail['condition'][0].'至'.$detail['condition'][1].'个，赠送'.$detail['content'].'个'.$presentName;
    }

    public function getLabel_order_discount ($detail) {
        return '满'.$detail['condition'][0].'立减'.$detail['content'].'%';
    }

    public function getLabel_order_reduced ($detail) {
        return '满'.$detail['condition'][0].'立减'.$detail['content'];
    }

    public function getLabel_order_present ($detail) {
        $presentName = $detail['presentName'] ?? '';
        return '满'.$detail['condition'][0].'赠送'.$detail['content'].'个'.$presentName;
    }

    public function setOrderTotal($orderTotal = '') {
        $fromFocus = $this->fromFocus;
        $totalCol = 'total';
        $totalField = $fromFocus->fieldobj->getFieldInfoobjBykey('columnname', $totalCol);
        // 数量字段关闭，默认不满足条件
        if(empty($totalField)) {
            return false;
        }
        $totalFieldName = $totalField->getFieldName();
        $totalValue = $fromFocus->column_fields[$totalFieldName];
        if(empty($orderTotal)) {
            $total = 0;
            if (!empty($totalValue)) {
                $total = $totalValue;
            } else if (isset($_REQUEST['productLicencePrice'])) {
                $total = $_REQUEST['productLicencePrice'] ?? 0;
            } else {
                $ProductDetailsHtml = $this->detailsHtmlObj;
                $columnData = $ProductDetailsHtml->product_lastvalue_arr;
                $total = $columnData[$totalCol]['column_value'];
            }
            $this->orderTotal = (float)$total;
        }
        else {
            $this->orderTotal = (float)$orderTotal;
        }
        $fromFocus->column_fields[$totalFieldName] = $this->orderTotal;
    }

    public function getOrderTotal() {
        if(empty($this->orderTotal)) {
            $this->setOrderTotal();
        }
        return $this->orderTotal;
    }

    // todo 后续可能需要再后台进行计算
    public function updateOrderTotal($policyInfo) {
        return;
        $orderTotal = $this->getOrderTotal();
        $cumulativeBenefits = 0;
        $productLicencePrice = 0;

        $productDetails = $this->getProductDetailData();
        foreach ($productDetails as $productDetail) {
            $cumulativeBenefits += $this->getProductDiscountAmount($policyInfo, $productDetail);
        }

        $cumulativeBenefits += $this->getOrderDiscountAmount($policyInfo, $orderTotal - $cumulativeBenefits);

        $policyDetails = $policyInfo['value'];
        foreach ($policyDetails as $policyDetail) {
            
        }
    }

    public function getProductDiscountAmount($policyInfo, $productDetail) {
        $cumulativeBenefits = 0;
        return $cumulativeBenefits;
    }

    public function getOrderDiscountAmount($policyInfo, $orderTotal) {
        $cumulativeBenefits = 0;
        return $cumulativeBenefits;
    }

    public function getThreshold_order($detail) {
        $condition = $detail['condition'];
        $fromFocus = $this->fromFocus;
        $total = $this->getOrderTotal();
        if(!empty($total) && !empty($condition[0])) {
            return $total >= (float)$condition[0];
        }
        return false;
    }

    public function setProductDetailData() {
        if(isset($_REQUEST['detailData'])) {
            $detailData = json_decode(urldecode($_REQUEST['detailData']), true);
        }
        else {
            $ProductDetailsHtml = $this->detailsHtmlObj;
            $detailData = $ProductDetailsHtml->productToolFieldsValues;
        }
        $this->productDetailData = $detailData;
    }

    public function getProductDetailData() {
        if(empty($this->productDetailData)) {
            $this->setProductDetailData();
        }
        return $this->productDetailData;
    }

    public function getThreshold_product($detail) {
        $condition = $detail['condition'];
        $fromFocus = $this->fromFocus;
        $fromModule = $this->fromModule;
        $quantityField = $fromFocus->detailfieldobj->getFieldInfoobjBykey('columnname','quantity');
        // 数量字段关闭，默认不满足条件
        if(empty($quantityField)) {
            return false;
        }
        $quantityFieldName = $quantityField->getFieldName();
        $detailData = $this->getProductDetailData();
        $quantity = 0;
        $flag = true;
        foreach ($detailData as $info) {
            if($info['productid'] === $detail['productid'] && $info['is_present'] !== 'yes')
                $quantity += ($info[$quantityFieldName] ?? 0);
        }
        if(!empty($condition[0])) {
            $flag = ($quantity >= (float)$condition[0]);
            if(!empty($condition[1])) {
                $flag = ($flag && ($quantity < (float)$condition[1]));
            }
            return $flag;
        }
        return false;
    }

    public function saveSelectedPolicy($selected, $presentRowInfo) {
        global $adb, $current_user;
        $fromFocus = $this->fromFocus;
        $fromModule = $fromFocus->module_name;
        $record = $fromFocus->id;
        $user = $current_user->id;
        $time = date('Y-m-d H:i:s');
        $delSql = "DELETE FROM ld_pricepolicy_use WHERE record = ?";
        $adb->pquery($delSql, [$record]);

        $selectedArr = explode(',',(string) $selected);
        if(!empty($selected) && !empty($selectedArr)) {

            $insertSql = "INSERT INTO ld_pricepolicy_use(module, `user`, record, pricepolicyid) VALUES ";
            $insertParam = [];
            $historySql = "INSERT INTO ld_pricepolicy_use_history(module, time, `user`, record, pricepolicyid) VALUES ";
            $historyParam = [];
            foreach ($selectedArr as $policyId) {
                $insertSql .= " (?,?,?,?),";
                array_push($insertParam, $fromModule, $user, $record, $policyId);
                $historySql .= " (?,?,?,?,?),";
                array_push($historyParam, $fromModule, $time, $user, $record, $policyId);
            }
            $insertSql = substr($insertSql, 0, -1);
            $historySql = substr($historySql, 0, -1);
            $adb->pquery($insertSql, $insertParam);
            $adb->pquery($historySql, $historyParam);
        }

        $delPresentSql = "DELETE FROM ld_pricepolicy_use_present WHERE record = ?";
        $adb->pquery($delPresentSql, [$record]);
        // 赠品行信息保存
        if(count($presentRowInfo) > 0) {
            $presentSql = "INSERT INTO ld_pricepolicy_use_present(module, record, lineitem_id, pricepolicyid, pricepolicy_lineitem_id) VALUES ";
            $presentParam = [];
            foreach ($presentRowInfo as $lineItemId => $present) {
                $tmpArr = explode('_', $present);
                $tmpPolicyId = $tmpArr[0];
                $tmpPolicyIndex = $tmpArr[1];
                $presentSql .= " (?,?,?,?,?),";
                array_push($presentParam, $fromModule, $record, $lineItemId, $tmpPolicyId, $tmpPolicyIndex);
            }
            $presentSql = substr($presentSql, 0, -1);
            $adb->pquery($presentSql, $presentParam);
        }

    }

    public function getSelectedPolicy() {
        global $adb, $current_user;
        $fromFocus = $this->fromFocus;
        $fromModule = $fromFocus->module_name;
        $record = $fromFocus->id;
        // 复制单据
        $duplicateRecord = $this->focus->column_fields['record_id'];
        if(!empty($duplicateRecord)) {
            $record = $duplicateRecord;
        }
        $user = $current_user->id;
        $sql = "SELECT GROUP_CONCAT(pricepolicyid) AS selected FROM ld_pricepolicy_use WHERE record = ? AND `user` = ? AND module = ?;";
        $result = $adb->pquery($sql, [$record, $user, $fromModule]);
        $num = $adb->num_rows($result);
        $selected = '';
        if($num > 0) {
            $selected = $adb->query_result($result, 0, 'selected');
        }
        return $selected;
    }

    public function getSelectedPolicyInfo() {
        global $adb, $current_user;
        $fromFocus = $this->fromFocus;
        $record = $fromFocus->id;
        // 复制单据
        $duplicateRecord = $this->focus->column_fields['record_id'];
        if(!empty($duplicateRecord)) {
            $record = $duplicateRecord;
        }
        $focus = $this->focus;
        $colList = $focus->colList;
        $colStr = '';
        foreach ($colList as $col) {
            $colStr .= ' ' . $col . ',';
        }
        $colStr = substr($colStr, 0, -1);
        $recommendedCol = $colList['recommended'];
        $priority = $colList['priority'];
        $table = $focus->table_name;
        $index = $focus->table_index;
        $sql  = "SELECT p.$index, $colStr FROM $table p
                INNER JOIN ld_pricepolicy_use u ON u.pricepolicyid = p.$index AND u.record = ?
                WHERE deleted = 0 
                ORDER BY $recommendedCol DESC, $priority ;";
        $result = $adb->pquery($sql,[ $record ]);
        $num = $adb->num_rows($result);
        $selected = [];
        if($num > 0) {
            $detailObj = $this->getDetailObj();
            for($i = 0; $i < $num; $i ++) {
                $item = [];
                foreach ($colList as $key => $col) {
                    $item[$key] = $adb->query_result($result,$i,$col);
                }
                $item['recommended'] = $item['recommended'] === '0' ? 'no' : 'yes';
                $item['id'] = $adb->query_result($result,$i,$index);

                $this->focus->id = $item['id'];
                if(!empty($item['id']) ) {
                    $label = [];
                    $form = $item['form'];
                    $details = $detailObj->getDetailData();
                    $funName = "getLabel_" . $form;
                    if(method_exists($this, $funName)) {
                        foreach ($details as &$detail) {
                            $detail['productname'] = urldecode($detail['productname']);
                            $detail['presentName'] = urldecode($detail['presentName']);
                            array_push($label, $this->$funName($detail));
                        }
                    }
                    $item['label'] = $label;
                    $item['value'] = $details;
                }
                array_push($selected, $item);
            }
        }
        return $selected;
    }

    public function getDetailRestBlocks() {
        $detailBlock = $this->getBlockInfo_Detail();
        return [
            $detailBlock,
        ];
    }

    public function getBlockInfo_Detail() {
        $val = $this->getSelectedPolicyInfo();
        $module = $this->module;
        return [
            'title' => getTranstab($module),
            'conId' => 'PricePolicyBlock',
            'method' => 'getPricePolicyBlock',
            'data' => [
                'head' => [
                    ['label' => '政策名称', 'width' => '30%', 'field' => 'name'],
                    ['label' => '政策规则', 'width' => '70%', 'field' => 'label'],
                ],
                'val' => $val,
            ],
        ];
    }

    public function getPresentRowInfo() {
        global $adb;
        $fromFocus = $this->fromFocus;
        $fromModule = $fromFocus->module_name;
        $record = $fromFocus->id;
        $colList = [
            'module' => 'module',
            'record' => 'record',
            'lineItemId' => 'lineitem_id',
            'policyId' => 'pricepolicyid',
            'policyIndex' => 'pricepolicy_lineitem_id',
        ];
        $colStr = implode(', ', array_values($colList));
        $sql = "SELECT $colStr FROM ld_pricepolicy_use_present WHERE module = ? AND record = ?;";
        $result = $adb->pquery($sql, [$fromModule, $record]);
        $num = $adb->num_rows($result);
        $rowInfo = [];
        if($num > 0) {
            for($i = 0; $i < $num; $i ++) {
                $item = [];
                foreach ($colList as $key => $col) {
                    $item[$key] = $adb->query_result($result, $i, $col);
                }
                $rowInfo[$item['lineItemId']] = $item['policyId'].'_'.$item['policyIndex'];
            }
        }
        return $rowInfo;
    }

    public function checkIsSelected($record) {
        $policyId = $this->focus->id;
        global $adb;
        $sql = "SELECT record FROM ld_pricepolicy_use WHERE pricepolicyid = ? LIMIT 1;";
        $result = $adb->pquery($sql, [$record]);
        $num = $adb->num_rows($result);
        if($num > 0) {
            return true;
        }
        return false;
    }

    var $selectedPolicyArr;
    public function checkDetailUsePolicy($rowVal) {
        if($rowVal['is_present'] === 'yes') {
            return false;
        }
        if(empty($this->selectedPolicyArr)) {
            $this->selectedPolicyArr = $this->getSelectedPolicyInfo();
        }
        $selectedPolicyArr = $this->selectedPolicyArr;
        if(count($selectedPolicyArr) === 0) {
            return false;
        }
        $flag = false;
        foreach ($selectedPolicyArr as $index => $policyInfo) {
            if($policyInfo['type'] !== 'product') {
                continue;
            }
            if($policyInfo['form'] === 'product_present') {
                continue;
            }
            $details = $policyInfo['value'];
            $productId = $rowVal['productid'];
            foreach ($details as $i => $detail) {
                if((string)$detail['productid'] === (string)$productId) {
                    $flag = true;
                    break;
                }
            }
            if($flag) {
                break;
            }
        }
        return $flag;
    }
}