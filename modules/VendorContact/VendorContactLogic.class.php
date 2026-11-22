<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class VendorContactLogic extends BaseLogic {
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-06-01
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
        //editor:gyq_20180824	0035049: （1.6登录）供应商和供应商联系人序时簿列表界面：更多中应不显示“自动查重合并”按钮
	/*	$btn = array();$module = self::$module;
		$btn['Findduplicates']['label'] = getFixedLabel('CHECKMERGE');
		$btn['Findduplicates']['permit'] = isPermitted($module,'DuplicatesHandling','');
		$count = count($this->list_buttons['More']['list']);
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,$count-1);*/
	}
	/**
	 * 获取对应的关联创建
	 * @author Tujt 2015-06-25
	 */
	public function getActionUserd() {
		parent::getActionUserd();
		$tabid = getTabid('VendorContactRecords');
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&vendor_id='.$this->controller->column_fields['vendor_id'].'&contact_id='.$this->controller->id;
			$this->quickactionLink[$tabid]['tag'] = $tag;
		}
		return $this->quickactionLink;
	}
}
?>