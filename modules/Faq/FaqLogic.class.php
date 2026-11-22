<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class FaqLogic extends BaseLogic {
    /**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		//常见问题模块没有导入功能
		unset($this->list_buttons['More']['list']['Import']);
	}
    
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-04
	 
	public function getDetailBasicBtn() {
	    parent::getDetailBasicBtn();
	}*/
}
?>