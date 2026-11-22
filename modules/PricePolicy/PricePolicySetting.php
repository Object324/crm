<?php

class PricePolicySetting
{
    public $module = 'PricePolicy';
    public $focus;
    public $allSetValues;
    public $setValues = [];
    public $affectNodeCol = 'affectNode';
    public $accordingToCol = 'accordingTo';
    public function __construct() {
        $this->focus = CRMEntity::getInstance($this->module);
    }

    public static function getInstance() {

    }

    public function getAffectNode() {
        return $this->getSetValueByType($this->affectNodeCol) ?? 'saved';
    }

    public function getAccordingTo($module) {
        return $this->getSetValueByType($module.'_'.$this->accordingToCol) ?? 'createdtime' ?? 'now';
    }

    public function getFieldOptions() {
        $fieldOptions = [];
        $fieldOptions[$this->affectNodeCol] = [
            ['label' => '保存后生效', 'value' => 'saved'],
            ['label' => '审批通过后生效', 'value' => 'approved'],
        ];
        $fieldOptions[$this->accordingToCol] = [
            ['label' => '当前时间', 'value' => 'now'],
        ];
        return $fieldOptions;
    }

    public function getInfo() {
        $modules = PricePolicyUtils::getRoleModules($this->focus);
        $fieldsArr = [];
        $body = [];
        foreach ($modules as $module => $info) {
            $fieldsArr[$module] = [];
            $tmpFocus = CRMEntity::getInstance($module);
            $allFields = $tmpFocus->fieldobj->getModuleAllPreseneceFields();
            foreach ($allFields as $fieldName => $fieldInfo) {
                $bigType = $fieldInfo->getBigType();
                if($bigType !== 'datetime' && $bigType !== 'date') {
                    continue;
                }
                $displayType = $fieldInfo->getDisplayType();
                $allowEdit = $fieldInfo->get_allowedit();
                if($displayType !== '1' || $allowEdit === 'no') {
                    continue;
                }
                $tableName = $fieldInfo->getTableName();
                $columName = $fieldInfo->getColumnName();
                $typeOfDataArr = explode('~',$fieldInfo->getTypeOfData());
                $col = $tableName.":".$columName.":".$fieldName.":".$module."_fieldlabel:".$typeOfDataArr[0];
                $fieldsArr[$module][$columName] = [
                    'value' => $columName,
                    'label' => $fieldInfo->getFieldLabelKey(),
                ];
            }
            $createTimeCol = 'createdtime';
            if(!$fieldsArr[$module][$createTimeCol]) {
                $fieldsArr[$module][$createTimeCol] = [
                    'value' => $createTimeCol,
                    'label' => '创建时间',
                ];
            }
            $fieldsArr[$module] = array_values($fieldsArr[$module]);
            array_push($body, [
                'module' => $module,
                'moduleLabel' => $info[0],
                'accordingTo' => $this->getAccordingTo($module),
            ]);
        }
        return [
            'head' => [
                'title' => getFixedLabel('LBI_PRICEPOLICY_SETTINGS'),
                'val' => [
                    [ 'label' => '设置促销活动生效触发点', 'value' => $this->getAffectNode(), 'field' => $this->affectNodeCol]
                ]
            ],
            'body' => [
                'conId' => 'PricePolicySetBody',
                'data' => [
                    'head' => [
                        ['label' => '所属模块', 'width' => '20%', 'field' => 'module'],
                        ['label' => '适用范围', 'width' => '80%', 'field' => $this->accordingToCol],
                    ],
                    'val' => $body,
                ]
            ],
            'fieldOptions' => $this->getFieldOptions(),
            'moduleFields' => $fieldsArr,
        ];
    }

    public function getAllSetValues() {
        global $adb;
        if(is_array($this->allSetValues)) {
            $sql = "SELECT type, value FROM ld_pricepolicy_settings ";
            $result = $adb->pquery($sql, []);
            $num = $adb->num_rows($result);
            $val = [];
            if ($num > 0) {
                for ($i = 0; $i < $num; $i++) {
                    $type = $adb->query_result($result, $i, 'type');
                    $value = $adb->query_result($result, $i, 'value');
                    $val[$type] = $value;
                }
            }
            $this->allSetValues = $val;
        }
        return $this->allSetValues;
    }

    public function getSetValueByType($type) {
        if($this->allSetValues) {
            return $this->allSetValues[$type];
        }
        if(!$this->setValues[$type]) {
            global $adb;
            $sql = "SELECT type, value FROM ld_pricepolicy_settings WHERE type = ?";
            $result = $adb->pquery($sql, [$type]);
            $num = $adb->num_rows($result);
            $value = null;
            if ($num > 0) {
                $value = $adb->query_result($result, 0, 'value');
            }
            $this->setValues[$type] = $value;
        }
        return $this->setValues[$type];
    }

    public function saveSetValueByType($type, $value) {
        global $adb;
        if(empty($this->getSetValueByType($type))) {
            $sql = "INSERT INTO ld_pricepolicy_settings(type, value) VALUES (?, ?) ";
            $adb->pquery($sql, [$type, $value]);
        }
        else {
            $sql = "UPDATE ld_pricepolicy_settings SET value = ? WHERE type ?";
            $adb->pquery($sql, [$value, $type]);
        }
    }
}