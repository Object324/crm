<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class TimeSheetLogic extends BaseLogic {
    
        /**
	 * 调用公共更多下拉列表，并添加相关下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();//调用父类方法
		//销售退货单，删除批量编辑、导入按钮
		//unset($this->list_buttons['More']['list']['mass_edit']);
		//unset($this->list_buttons['More']['list']['Import']);
	}
    }

?>