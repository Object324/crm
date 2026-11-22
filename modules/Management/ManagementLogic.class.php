<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class ManagementLogic extends BaseLogic {
	/**
	 * 去掉创建按钮
	 * @author Tujt 2015-06-01
	 */
	public function getListBasicBtn() {
	    parent::getListBasicBtn();
		unset($this->list_buttons['Create']);
        
        $btn = array();//计提管理费
		$btn['fund_accured']['label'] = getFixedLabel('PROVISION');
		$btn['fund_accured']['permit'] = 'yes';
		$btn['fund_accured']['icon'] = 'icon-ask';
        $btn['fund_accured']['btnkey'] = 'fund_accured';
		$this->list_buttons = f_array_insert($this->list_buttons,$btn);
	}
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-06-01
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		unset($this->list_buttons['More']['list']['Import']);//删除导入按钮
        unset($this->list_buttons['More']['list']['Export']);//删除导出按钮
        unset($this->list_buttons['More']['list']['mass_edit']);//删除批量编辑按钮
        //unset($this->list_buttons['More']['list']['Copy']);//删除批量收款按钮

	}
	/**
	 * 获取详情页更多按钮对象
	 * @author Tujt 2015-06-05
	 */
    public function getDetailMoreBtn()
    {
        parent::getDetailMoreBtn();
       unset($this->detail_buttons['More']['list']['Copy']);//删除复制按钮

    }
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-05
	 */
	public function getDetailBasicBtn() {
		parent::getDetailBasicBtn();

		unset($this->detail_buttons['Edit']);
		unset($this->detail_buttons['Create']);
	}
	/**
	 * 获取对应的关联创建
	 * @author Tujt 2015-06-25
	 */
	public function getActionUserd() {
		parent::getActionUserd();
		//收款单
		//$tabid = getTabid('CashBill');

		return $this->quickactionLink;
	}
}
?>