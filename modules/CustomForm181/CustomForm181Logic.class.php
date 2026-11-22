<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class CustomForm181Logic extends BaseLogic {
	
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		/*
		*edit:chj
		*date:2020-07-15
		*reason:灵当CRM详细需求-费用报销单、佣金单、自定义表单21-25增加导入功能
		*/
		//unset($this->list_buttons['More']['list']['Import']);//删除导入按钮
	}
}
?>