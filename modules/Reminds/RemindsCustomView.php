<?php
class RemindsCustomView extends CustomView
{
	private static $_instance;
	public  function __construct($module = ''){
        $this->customviewmodule = 'Reminds';
        parent::__construct($this->customviewmodule);
	}
	public static function getInstance($module = ''){
        if(FALSE == (self::$_instance[$module] instanceof self)){
            self::$_instance[$module] = new self($module);
           
        }
        return self::$_instance[$module];
    }
	/**
	 * 获取消息分类
	 */
	public function getCustomView_RemindsCategory($popup=''){
		$remindscategory_arr = $this->getCustomViewByCustomcategory('RemindsCategory',$popup);
		return $remindscategory_arr;
	}
	/**
	 * 获取消息页签, "未读""已读"等
	 */
	public function getCustomView_RemindsNavBar($popup=''){
		$remindsnavbar_arr = $this->getCustomViewByCustomcategory('RemindsNavBar',$popup);
		// "全部"页签排序在最上面
		$tmp_viewinfo = [];
		$new_remindsnavbar_arr = [];
		foreach ($remindsnavbar_arr as $index => &$viewinfo) {
            if($viewinfo['viewname'] == 'allreminds'){
                $tmp_viewinfo = $viewinfo;
				$tmp_viewinfo['viewname'] = getFixedLabel('ALL');
				unset($remindsnavbar_arr[$index]);
				break;
            }
        }
		$new_remindsnavbar_arr[] = $tmp_viewinfo;
		$new_remindsnavbar_arr = array_merge($new_remindsnavbar_arr,$remindsnavbar_arr);

		return $new_remindsnavbar_arr;
	}
	/**
	 * 根据ld_customview中customcategory, 区分分类和"未读""已读"页签
	 */
	private function getCustomViewByCustomcategory($customcategory,$popup=''){
		$customView_arr = parent::getCustomViewAll('',$this->customviewmodule,'',$popup);
		$return_arr = [];
		foreach ($customView_arr as $index => $viewinfo) {
			// 预置的全部消息不可删除和拖动
			if($viewinfo['customcategory'] == 'RemindsCategory' && $viewinfo['icon_path'] == 'themes/icon2024/remindscategory-all.png'){
				$viewinfo['del_permit'] = 'no';
				$viewinfo['drag_permit'] = 'no';
				$viewinfo['preset_all'] = 'yes';// 代表是预置的"全部消息"分类
			}
            if($viewinfo['customcategory'] == $customcategory){
                $return_arr[] = $viewinfo;
            }
        }
		return $return_arr;
	}
}

?>