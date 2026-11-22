<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
crm_load_class_file('cls_TabDetailFieldsHtml','include/TabDetailFields');
Class PricePolicyDetailFieldsHtml extends cls_TabDetailFieldsHtml {

    function __construct($focus,$module){
        parent::__construct($focus,$module);
    }

    //获取明细
    public function getTabDetailFieldsHtml($entitytypeid=''){
        $this->entitytypeid = $entitytypeid;
        return '';
        //return parent:: getTabDetailFieldsHtml($entitytypeid);
    }

    //费用报销明细最后一行 合计
    public function getProductHtmlLastContent(){

    }

    public function getRestBlocks() {
        crm_load_class_file('PricePolicyUtils','modules/PricePolicy');
        return [
            $this->getRoleModuleBlock(),
            $this->getScopeBlock(),
            $this->getDetailBlock(),
            $this->getSuperpositionBlock(),
        ];
    }

    public function getDetailRestBlocks() {
        crm_load_class_file('PricePolicyUtils','modules/PricePolicy');
        $roleModuleBlock = $this->getRoleModuleBlock();
        $roleModuleHead = &$roleModuleBlock['data']['head'];
        unset($roleModuleHead[count($roleModuleHead) - 1]);
        $detailBlock = $this->getDetailBlock();
        $detailHead = &$detailBlock['data']['head'];
        unset($detailHead[count($detailHead) - 1]);
        return [
            $roleModuleBlock,
            $detailBlock,
        ];
    }

    public function getRoleModuleBlock() {
        $focus = $this->focus;
        $colName = $focus->colList['roleModuleScope'];
        $fieldObj = $focus->fieldobj->getFieldInfoobjBykey('columnname',$colName);

        if(!empty($focus->column_fields[$colName])) {
            $val = json_decode($focus->column_fields[$colName], true);
            PricePolicyUtils::getRoleModuleScopeLabel($val);
        }
        else {
            $val = [];
        }
        return [
            'title' => $fieldObj->getFieldLabelKey(), //'政策适用范围',
            'conId' => 'roleModule',
            'method' => 'getRoleModuleCon',
            'data' => [
                'head' => [
                    ['label' => '政策作用模块', 'width' => '20%', 'field' => 'module'],
                    ['label' => '适用范围', 'width' => '60%', 'field' => 'scope'],
                    ['label' => '操作', 'width' => '20%', 'field' => 'operate'],
                ],
                'val' => $val,
                'operate' => ['edit'],
            ],
        ];
    }

    public function getScopeBlock() {
        $val = [
            'scope' =>'all',
            'scopeVal' => '',
        ];
        $focus = $this->focus;
        $colName = $focus->colList['scope'];
        $fieldObj = $focus->fieldobj->getFieldInfoobjBykey('columnname',$colName);
        if(!empty($focus->column_fields[$colName])) {
            $val['scope'] = $focus->column_fields[$colName];
            if($val['scope'] !== 'all') {
                crm_load_class_file("cls_related_scope",'include/utils');
                $val['scopeVal'] = cls_related_scope::get_related_scope($this->module,$this->module,$focus->id);
            }
        }

        return [
            'title' => $fieldObj->getFieldLabelKey(),
            'conId' => 'pricePolicyScope',
            'method' => 'getScopeCon',
            'data' => [
                'label' => '适用范围',
                'list' => $focus->pricePolicyScope,
                'val' => $val,
            ],
        ];
    }

    public function getDetailBlock() {
        $val = $this->getDetailData();
        $focus = $this->focus;
        $form = '';
        $colName = $focus->colList['form'];
        if(!empty($focus->column_fields[$colName])) {
            $form = $focus->column_fields[$colName];
        }
        return [
            'title' => '政策设置',
            'conId' => 'pricePolicyDetail',
            'method' => 'getDetailCon',
            'data' => [
                'head' => [
                    ['label' => '#', 'width' => '10%', 'field' => 'no'],
                    ['label' => '政策规则', 'width' => '70%', 'field' => 'rules'],
                    ['label' => '操作', 'width' => '20%', 'field' => 'operate'],
                ],
                'val' => $val,
                'operate' => ['copy','del'],
                'form' => $form,
            ],
        ];
    }

    public function getDetailData() {
        $val = [];
        // 复制的情形
        $duplicateRecord = $this->focus->column_fields['record_id'];
        if(!empty($duplicateRecord)) {
            // 赋值以获取分录值
            $this->focus->id = $duplicateRecord;
        }
        $policyId = $this->focus->id;
        if(!empty($policyId)) {
            crm_load_function_file('setProductsInfo', 'include/utils', 'ListViewUtils');
            $currencyid = 1; //人民币
            $wareid = '';
            $rowid = '';
            $details = $this->tabDetailFieldData->getTabDetailHtmlContentData();
            foreach ($details as $index => $detail) {
                $productId = $detail['productid'];
                if(!empty($productId)) {
                    $productInfo = setProductsInfo($this->module, $productId, $currencyid, $wareid, $rowid, 'yes');
                    $productInfo['productname'] = urldecode($productInfo['productname']);
                }
                $present = $detail['present'];//赠品ID
                if(!empty($present)) {
                    if ($present === $productId && !empty($productInfo)) {
                        $presentInfo = $productInfo;
                    } else {
                        $presentInfo = setProductsInfo($this->module, $present, $currencyid, $wareid, $rowid, 'yes');
                    }
                    // 赠品价格均置为零
                    $presentInfo['listprice'] = 0;
                    $presentInfo['taxprice'] = 0;
                    $presentInfo['quantity'] = $detail['content'];
                    $presentInfo['is_present'] = 'yes';
                    $presentInfo['present'] = $policyId.'_'.$index;
                    $presentInfo['productname'] = urldecode($presentInfo['productname']);
                }
                array_push($val, [
                    'productid' => $detail['productid'],
                    'productname' => $productInfo['productname'] ?? '',
                    'condition' => json_decode($detail['condition'],true),
                    'present' => $detail['present'],
                    'presentName' => $presentInfo['productname'] ?? '',
                    'presentInfo' => $presentInfo ?? '',
                    'content' => $detail['content'],
                ]);
            }
        }
        // 复制的情形
        if(!empty($duplicateRecord)) {
            // 恢复空值
            $this->focus->id = '';
        }
        return $val;
    }

    public function getSuperpositionBlock() {
        global $adb;
        $focus = $this->focus;
        $available = [];
        $selected = [];
        $colName = $focus->colList['superpositionList'];
        $fieldObj = $focus->fieldobj->getFieldInfoobjBykey('columnname',$colName);
        $selectedList = !empty($focus->column_fields[$colName]) ? explode(',', $focus->column_fields[$colName]) : [];
        $validityList = PricePolicyUtils::getValidityPolicy($focus);
        foreach ($validityList as $item) {
            if($item['id'] !== $focus->id) {
                $tmpItem = [
                    'text' => $item['name'],
                    'value' => $item['id'],
                ];
                array_push($available, $tmpItem);
                if (in_array($item['id'], $selectedList)) {
                    array_push($selected, $tmpItem);
                }
            }
        }
        return [
            'title' => $fieldObj->getFieldLabelKey(),
            'conId' => 'superpositionList',
            'method' => 'getSuperPositionListCon',
            'data' => [
                'available' => $available,
                'selected' => $selected,
            ],
        ];
    }

}

?>