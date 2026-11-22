<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class RateLogic extends BaseLogic {
    /**
	 * 调用公共更多下拉列表，并添加相关下拉列表
	 * @author Tujt 2015-06-01
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();//调用父类方法
		$module = self::$module;
		unset($this->list_buttons['More']['list']['Import']);
		//$approve_focus = $this->controller->getInstance('Approve');
	//	$startapprovemodule = $approve_focus->startBlocksApprove();
		$btn = array();
	}
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-04
	 
	public function getDetailBasicBtn() {
	    parent::getDetailBasicBtn();
		$approve_focus = $this->controller->getInstance('Approve');
		$startapprovemodule = $approve_focus->startBlocksApprove();
		$btn = array();
	}*/
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-04
	 */
	public function getDetailMoreBtn() {
	    parent::getDetailMoreBtn();
		$btn = array();
	}
	/**
	 * 获取对应的关联创建
	 * @author Tujt 2015-06-25
	 */
	public function getActionUserd() {
		parent::getActionUserd();
		//供应商联系记录
		$tabid = getTabid('VendorContactRecords');
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&vendor_id='.$this->controller->column_fields['vendor_id'].'';
			$this->quickactionLink[$tabid]['tag'] .= $tag;
		}
		//采购发票
		$tabid = getTabid('PurchaseInvoice');
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&vendor_id='.$this->controller->column_fields['vendor_id'].'';
			$this->quickactionLink[$tabid]['tag'] .= $tag;
		}
		//采购退款单
		$tabid = getTabid('PurchaseCashBack');
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&vendor_id='.$this->controller->column_fields['vendor_id'].'';
			$this->quickactionLink[$tabid]['tag'] .= $tag;
		}
		//采购退货单
		$tabid = getTabid('PurchaseBack');
		if(isset($this->quickactionLink[$tabid])){
			$this->quickactionLink[$tabid]['click'] = 1;
			$this->quickactionLink[$tabid]['label'] = getFixedLabel('Handle returns');
			$stockpresence = $this->controller->column_fields['stockpresence'];
			$stock = 0;
			//未入库、生成入库单、部分入库、全部入库
			if($stockpresence=='部分入库' || $stockpresence=='全部入库') $stock = 1;
			$tag = $stock.','.$this->controller->column_fields['vendor_id'];
			$this->quickactionLink[$tabid]['tag'] = $tag;
		}
        $tabid = getTabid('Rate');
        if(isset($this->quickactionLink[$tabid])){
            $tag = '&vendor_id='.$this->controller->column_fields['vendor_id'].'';
			$this->quickactionLink[$tabid]['tag'] .= $tag;

		
		}
        
		return $this->quickactionLink;
	}
}
?>