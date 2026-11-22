<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author xiaoshun 2016-06-15
 */
class FundRewardLogic extends BaseLogic {
    
   	/**
	 * 获取列表页按钮对象
	 */
	public function getListBasicBtn() {
	    parent::getListBasicBtn();
        
		unset($this->list_buttons['Create']);
        $btn = array();//业绩报酬
		$btn['fund_accured']['label'] = getFixedLabel('PROVISION');
		$btn['fund_accured']['permit'] = 'yes';
		$btn['fund_accured']['icon'] = 'icon-ask';
        $btn['fund_accured']['btnkey'] = 'fund_accured';
        $this->list_buttons = f_array_insert($this->list_buttons,$btn);
	}
    
   	/**
	 * 获取列表页更多内按钮对象
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();//调用父类方法
	
		unset($this->list_buttons['More']['list']['Import']);
        unset($this->list_buttons['More']['list']['Export']);
        unset($this->list_buttons['More']['list']['mass_edit']);
        unset($this->list_buttons['More']['list']['ChangeCreator']);      
	}
    
    
   	/**
	 * 获取详情页按钮对象
	 */
	public function getDetailBasicBtn() {
		parent::getDetailBasicBtn();
	
		unset($this->detail_buttons['Create']);
       //unset($this->detail_buttons['Edit']);
	}
    public function getEditViewBtn()
    {
        return "";
    }
    
    public function getDetailMoreBtn(){
        parent::getDetailMoreBtn();
     
        unset($this->detail_buttons['More']['list']['Copy']);
    }
    public function getallListViewLink() {
        $btn =parent::getallListViewLink();
        unset($btn['edit']);
        return $btn;
    }
   	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);

		unset($this->listview_link['edit']);
    }
}
?>