<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class HolidayLogic extends BaseLogic {
    //节假日模块没有页面设置按钮
    public function getDetailBasicSet(){
        unset($this->detail_settings['Settings']);
        unset($this->detail_settings['DetailsSettings']);
        unset($this->detail_settings['RelevantSettings']);
    }
    //节假日模块没有下载全部附件按钮
    public function getListMoreBtn() {
        parent::getListMoreBtn();//调用父类方法
        unset($this->list_buttons['More']['list']['DownloadSelected']);//删除下载全部附件按钮
    }
}
?>