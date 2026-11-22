<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class LessionPlanLogic extends BaseLogic {
	/**
	 * 初始化基础按钮
	 * @author Tujt 2015-06-01
	 */
	public function getListBasicBtn() {
	    parent::getListBasicBtn();
		unset($this->list_buttons['Allocate']);
        unset($this->list_buttons['ChangeCreator']);
		unset($this->list_buttons['Settings']);
	}
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-06-01
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		unset($this->list_buttons['More']['list']['mass_edit']);
		unset($this->list_buttons['More']['list']['Import']);
	}

	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
		$this->listview_link['edit']['type'] = 'moduledetailapprove';
	}
}
?>