<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class QuotesChangeLogic extends BaseLogic {
    
	public function getDetailMoreBtn()
	{
		parent::getDetailMoreBtn();
		$this->detail_buttons['More']['list']['Copy']['permit'] = 'no';
	}
	public function getListBasicBtn() {
		global $current_user;
		parent::getListBasicBtn();//调用父类方法
		$module = self::$module;$btn = array();
		//editor:gyq_161 reason:带分录模块弹出层   2019/11/21 17:48
		unset($this->list_buttons['Create']);
		//unset($this->list_buttons['ModuleDetailCreate']);
		$btn = array();//如何创建报价变更单
		$btn['howToquoteschange']['label'] = getFixedLabel('How_to_create_quoteschange');
		$btn['howToquoteschange']['permit'] = 'yes';
		$btn['howToquoteschange']['icon'] = 'icon-ask';
        $btn['howToquoteschange']['btnkey'] = 'howToquoteschange';
		$this->list_buttons = f_array_insert($this->list_buttons,$btn);
	}

	/**
	 * 获取详情页按钮对象
	 * @author chj 2017-08-11
	 */
	public function getDetailBasicBtn() {
	    parent::getDetailBasicBtn();
		unset($this->detail_buttons['Create']);
	}
}
?>