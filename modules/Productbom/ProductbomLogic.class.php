<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class ProductbomLogic extends BaseLogic {
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-06-01
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		unset($this->list_buttons['More']['list']['mass_edit']);
		unset($this->list_buttons['More']['list']['Import']);
	}
    public function getallListViewLink() {
        $btn =array();
        if(isPermitted(self::$module,'Create') == 'yes') {
            $btn['copy']['label'] = getFixedLabel('COPY');
        }
        $btn = f_array_insert($btn,parent::getallListViewLink(),-1);
        return $btn;
    }
	/**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-26
	 */
	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
		unset($this->listview_link['copy']);
		if(isPermitted(self::$module,'Create') == 'yes'){
			$btn = array();
			$btn['copy']['label'] = getFixedLabel('COPY');
			$btn['copy']['permit'] = 'yes';
			$btn['copy']['click'] = "bom_edit('".$record.",34','copy')";
			$this->listview_link = f_array_insert($this->listview_link,$btn);
		}
	}
}
?>