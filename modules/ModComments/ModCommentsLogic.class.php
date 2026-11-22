<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class ModCommentsLogic extends BaseLogic {
    /**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		//评论模块没有导入功能
		unset($this->list_buttons['More']['list']['Import']);
	}
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-05
	 */
	public function getDetailMoreBtn() {
		parent::getDetailMoreBtn();//调用父类方法
		$mbtn = 0;
		$this->detail_buttons['More']['list']['Delete'];
		if(!empty($btn)){
			$this->detail_buttons = f_array_insert($this->detail_buttons,$btn,-2);
		}
		foreach($this->detail_buttons['More']['list'] as $key => $btninfo){
			if($btninfo['permit'] == 'yes'){
				$mbtn = 1;
				break;
				
			}
		}
		if($mbtn == 0){
			$this->detail_buttons['More']['permit']='no';
		}
	}
    public function getallListViewLink() {
        $btn =array();
        $btn['reply']['label'] = getFixedLabel('Reply');
        $btn = f_array_insert($btn,parent::getallListViewLink());
        return $btn;
    }
    /**
	 * 初始化列表按钮结果集
	 * @author Tujt 2022-12-15
	 */
	public function setListViewLink($result,$record,$start,$idx) {
	   global $current_user;
	   parent::setListViewLink($result,$record,$start,$idx);
       $r_m = self::$module;$r_a = 'ListView';$r_r = 0;$related = 0;
       //获取回复按钮
       $permit = isPermitted(self::$module,'Reply',$record);
       if($permit == 'yes'){
            $this->listview_link['reply']['label'] = getFixedLabel('Reply');
            $this->listview_link['reply']['permit'] = $permit;
            $this->listview_link['reply']['click'] = 'check_edit_click(this,\''.self::$module.'\',\'%d\')';
            $this->listview_link['reply']['type'] = 'reply';
            $this->listview_link['reply']['result']['module'] = $r_m;
    		$this->listview_link['reply']['result']['action'] = $r_a;
    		$this->listview_link['reply']['result']['record'] = $r_r;
       }
	}
}
?>