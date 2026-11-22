<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class SendPaymentLogic extends BaseLogic {
	/**
	 * 去掉创建按钮
	 * @author Tujt 2015-06-01
	 */
	public function getListBasicBtn() {
	    parent::getListBasicBtn();
		unset($this->list_buttons['Create']);
		$btn = array();//如何创建回款计划
		$btn['howTosendpayment']['label'] = getFixedLabel('How_to_send_create_plan');
		$btn['howTosendpayment']['permit'] = 'yes';
		$btn['howTosendpayment']['icon'] = 'icon-ask';
        $btn['howTosendpayment']['btnkey'] = 'howTosendpayment';
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
		$btn['massSendCashBill']['label'] = getFixedLabel('BATCHPAYMENT');
		$btn['massSendCashBill']['permit'] = 'yes';
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,1);
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
	 * 获取对应的关联创建
	 * @author Tujt 2015-06-25
	 */
	public function getActionUserd() {
		parent::getActionUserd();
		//付款单
		$tabid = getTabid('SendCashBill');
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&SendPayment='.$this->quickactionLink[$tabid]['return_id'].'';
			$this->quickactionLink[$tabid]['tag'] .= $tag;
           // if($this->controller->column_fields['cpstatus'] == '已付'){
    			//	unset($this->quickactionLink[$tabid]);
    		//	}
		}
		return $this->quickactionLink;
	}
}
?>