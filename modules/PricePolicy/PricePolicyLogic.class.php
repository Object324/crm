<?php

class PricePolicyLogic extends BaseLogic
{
    public function checkStatusInfo($module,$record) {
        $msg = 'SUCCESS';
        $module = self::$module;
        $approveFocus = Approve::getInstance($module);
        $approveModuleArr = $approveFocus->startBlocksApprove();
        if(isset($approveModuleArr[$module])) {
            $msg = $this->checkEditInfo($module,$record);
        }
        if($this->checkIsSelected($record)) {
            $msg =  '该政策已被使用，不可编辑';
        }
        return $msg;
    }

    public function setListViewLink($result,$record,$start,$idx) {
        parent::setListViewLink($result,$record,$start,$idx);
        $type = 'checkstatus';
        foreach ($this->listview_link as $btnType => &$info) {
            $info['type'] = $type;
        }
    }

    public function getDetailBasicBtn() {
        parent::getDetailBasicBtn();
        $record = $this->controller->id;
        // 已使用的政策不可编辑删除
        if($this->checkIsSelected($record)) {
            unset($this->detail_buttons['Edit']);
            unset($this->detail_buttons['Delete']);
        }
    }

    public function getDetailBasicSet() {
        // 价格政策模块去除页面设置、单据分录定制、相关信息设置
        return;
    }

    public function checkIsSelected($record = '') {
        if(empty($record)) {
            $record = $this->controller->id;
        }
        crm_load_class_file('PricePolicyBlock','modules/PricePolicy');
        $policyObj = new PricePolicyBlock('');
        return $policyObj->checkIsSelected($record);
    }

    public function getDeleteBtn() {
        $buttons = parent::getDeleteBtn();
        $record = $this->controller->id;
        if($this->checkIsSelected($record)) {
            $buttons['permit'] = 'no';
        }
        return $buttons;
    }

    public function getEditViewBtn() {
        $buttons = parent::getEditViewBtn();
        if($this->checkIsSelected()) {
            $buttons['permit'] = 'no';
        }
        return $buttons;
    }
}