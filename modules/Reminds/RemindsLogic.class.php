<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class RemindsLogic extends BaseLogic {
	/**
	 * 初始化模块基础按钮
	 * @author Tujt 2015-05-28
	 */
	public function getListBasicBtn() {
		parent::getListBasicBtn();
		unset($this->list_buttons['Allocate']);
		unset($this->list_buttons['Share']);
		$btn = array();
		/*if('yes' == $this->list_buttons['Delete']['permit']){
			$btn['deleteall']['permit'] = 'yes';
			$btn['deleteall']['label'] = getFixedLabel('CELARALL');
			$btn['deleteall']['icon'] = 'icon-del';
			$this->list_buttons = f_array_insert($this->list_buttons,$btn,2);
		}*/
        		$viewid = '';
		if(isset($_REQUEST['viewname']) && $_REQUEST['viewname'] > 0){
			$viewid = $_REQUEST['viewname'];
		}elseif($_SESSION['lvs']['Reminds']["viewname"] > 0){
            $viewid = $_SESSION['lvs']['Reminds']["viewname"];
		}
      
		$btn = array();
		switch($viewid){
		    case 115://发件箱，隐藏更多
		        $this->list_buttons['More']['permit'] = 'no';
		        break;
		    case 114://已读
		        $btn['unmark']['label'] = getFixedLabel('SETUNREAD');
                $btn['unmark']['icon'] = 'icon-check';
				$btn['unmark']['permit'] = 'yes';
                $btn['unmark']['btnkey'] = 'unmark';
		        break;
			default://未读
				$btn['mark']['label'] = getFixedLabel('SETREAD');
                $btn['mark']['icon'] = 'icon-check';
				$btn['mark']['permit'] = 'yes';
                $btn['mark']['btnkey'] = 'mark';
		        break;
		}
		if(!empty($btn)){
			//$this->list_buttons['More']['list'] = $btn;
            $this->list_buttons = f_array_insert($this->list_buttons,$btn,2);
		}
	}
    /**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
		$viewid = '';
		if(isset($_REQUEST['viewname']) && $_REQUEST['viewname'] > 0){
			$viewid = $_REQUEST['viewname'];
		}
		$btn = array();
	/*	switch($viewid){
		    case 115://发件箱，隐藏更多
		        $this->list_buttons['More']['permit'] = 'no';
		        break;
		    case 114://已读
		        $btn['unmark']['label'] = getFixedLabel('SETUNREAD');
				$btn['unmark']['permit'] = 'yes';
		        break;
			default://未读
				$btn['mark']['label'] = getFixedLabel('SETREAD');
				$btn['mark']['permit'] = 'yes';
		        break;
		}*/
		if(!empty($btn)){
			$this->list_buttons['More']['list'] = $btn;
		}else{
            unset($this->list_buttons['More']);
		}
	}
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-03
	 */
	public function getDetailBasicBtn() {
		parent::getDetailBasicBtn();
		
		unset($this->detail_buttons['Allocate']);
		unset($this->detail_buttons['More']);
	}
    public function getEditViewBtn()
    {
        return "";
    }
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-03
	 */
	public function getDetailMoreBtn() {
		//提醒模块没有更多操作
	}
	/**
	 * 关联创建
	 * @author Tujt 2015-06-18
	 */
	public function setQuickCreateColumn($parent_module,$parent_id) {
		$this->controller->column_fields['reltab'] = $parent_module;
		$this->controller->column_fields['related_to'] = $parent_id;
	}
	/**
	 * 获取列表操作列按钮
	 * @author Tujt 2015-06-29
	 */
	public function getListViewLink($result,$record,$start,$idx) {
		//库存流水账列表没有按钮
	}
}
?>