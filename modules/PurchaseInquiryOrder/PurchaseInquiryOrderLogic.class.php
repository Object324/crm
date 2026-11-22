<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class PurchaseInquiryOrderLogic extends BaseLogic {
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-06-01
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
	}
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-03
	 
	public function getDetailBasicBtn() {
		parent::getDetailBasicBtn();
	}*/
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-03
	 */
	public function getDetailMoreBtn() {
		parent::getDetailMoreBtn();
		$VersionInfo = getVersionInfo();
		if($VersionInfo['account'] == 'climaveneta'){
			unset($this->detail_buttons['moduledetailCopy']);
		}
	}
	/**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-26
	 */
	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
        
		$btn = array();
		unset($this->listview_link['checkout']);//审核
		unset($this->listview_link['acheckout']);//反审核
		unset($this->listview_link['print']);//打印
	}
	public function getActionUserd() {
		parent::getActionUserd();//调用父级方法
	}
    
    
}
?>