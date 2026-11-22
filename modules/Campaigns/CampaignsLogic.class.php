<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class CampaignsLogic extends BaseLogic {
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-06-01
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		//unset($this->list_buttons['More']['list']['Import']);
        unset($this->list_buttons['ChangeCreator']);
	}
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-04
	 */
	public function getDetailBasicBtn() {
	    parent::getDetailBasicBtn();
        unset($this->detail_buttons['ChangeCreator']);
	}
}
?>