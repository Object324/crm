<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class PaymentPlanLogic extends BaseLogic {
	/**
	 * 去掉创建按钮
	 * @author Tujt 2015-06-01
	 */
	public function getListBasicBtn() {
	    parent::getListBasicBtn();
		unset($this->list_buttons['Create']);
		$btn = array();//如何创建回款计划
		$btn['howTopayment']['label'] = getFixedLabel('How_to_create_plan');
		$btn['howTopayment']['permit'] = 'yes';
		$btn['howTopayment']['icon'] = 'icon-ask';
        $btn['howTopayment']['btnkey'] = 'howTopayment';
		$this->list_buttons = f_array_insert($this->list_buttons,$btn);
	}
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-06-01
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		unset($this->list_buttons['More']['list']['Import']);//删除导入按钮
		$btn = array();//如何创建回款计划
		$btn['massCashBill']['label'] = getFixedLabel('RECEIVINGBATCH');
		$btn['massCashBill']['permit'] = 'yes';
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,1);
	}
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-05
	 */
	public function getDetailBasicBtn() {
		parent::getDetailBasicBtn();
		//0013831:回款计划/付款计划>明细,关于编辑/删除权限的问题
	//	if(isset($this->controller->column_fields['paymentstatus']) && ($this->controller->column_fields['paymentstatus'] == '已收' || $this->controller->column_fields['paymentstatus'] == '部分已收')){
	//		unset($this->detail_buttons['Edit']);
	//	}
		unset($this->detail_buttons['Create']);
	}
	/**
	 * 获取对应的关联创建
	 * @author Tujt 2015-06-25
	 */
	public function getActionUserd() {
		parent::getActionUserd();
		//收款单
		$tabid = getTabid('CashBill');
		//0019890: 回款计划>明细界面>相关信息栏新建收款单提示“当前单据已收款，不允许创建收款单”
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&PaymentPlan='.$this->controller->id.'';
			$this->quickactionLink[$tabid]['tag'] .= $tag;
			$focus = CRMEntity::getInstance('PaymentPlan');
			$focus->retrieve_entity_info($this->controller->id,'PaymentPlan');
		//	if($focus->column_fields['paymentstatus'] == '已收'){
			//	unset($this->quickactionLink[$tabid]);
		//	}
			
		}
		return $this->quickactionLink;
	}
}
?>