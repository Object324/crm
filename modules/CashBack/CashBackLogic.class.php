<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class CashBackLogic extends BaseLogic {

	/**
	 * 去掉创建按钮
	 * @author Tujt 2015-05-29 
	 */
	public function getListBasicBtn() {
	    parent::getListBasicBtn();
        //ls 20221101 Xuqiu1000213 服务回访单、销售退货单、采购退货单、销售退款单、采购退款单增加“新建”功能（销售退款单）
		/*unset($this->list_buttons['Create']);
		$btn = array();//如何退款
		$btn['howToPurchaseReturn']['label'] = getFixedLabel('HOWTOCASHBACK');
		$btn['howToPurchaseReturn']['permit'] = 'yes';
		$btn['howToPurchaseReturn']['icon'] = 'icon-ask';
        $btn['howToPurchaseReturn']['btnkey'] = 'howToCashBack';
		$this->list_buttons = f_array_insert($this->list_buttons,$btn);*/
	}
    /**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		unset($this->list_buttons['More']['list']['mass_edit']);//删除导入按钮
		unset($this->list_buttons['More']['list']['Import']);//删除导入按钮
	}
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-05
	 */
	public function getDetailBasicBtn() {
		parent::getDetailBasicBtn();
		unset($this->detail_buttons['Create']);
	}
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-05
	 */
	public function getDetailMoreBtn() {
		parent::getDetailMoreBtn();
		unset($this->detail_buttons['moduledetailCopy']);
        unset($this->detail_buttons['Copy']);
	}
}
?>