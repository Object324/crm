<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class MarketSpreadLogic extends BaseLogic {
    /**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
	//	parent::getListMoreBtn();
	
	//	$btn = array();
		//$btn += $this->list_buttons['More']['list'];
		//$this->list_buttons['More']['list'] = $btn;
	}
    public function getListBasicBtn() {
        
        //搜索
		$this->list_buttons['Search']['label'] = getFixedLabel('SEARCH');
		$this->list_buttons['Search']['permit'] = 'yes';
		$this->list_buttons['Search']['icon'] = 'icon-search';
        $this->list_buttons['Search']['btnkey'] = 'Search';
        }
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-05
	 */
	public function getDetailBasicBtn() {
		
        
	}
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-05
	 */
	public function getDetailMoreBtn() {
	
	}

	/**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-29
	 */
	public function setListViewLink($result,$record,$start,$idx) {
	//	parent::setListViewLink($result,$record,$start,$idx);
	//	$this->listview_link['edit']['type'] = 'checkstatus';
	}
}
?>