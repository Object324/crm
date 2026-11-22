<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class InventoryQueryLogic extends BaseLogic {
	/**
	 * 初始化模块基础按钮
	 * @author Tujt 2015-06-01
	 */
	public function getListBasicBtn() {
		parent::getListBasicBtn();
		unset($this->list_buttons['Create']);//删除创建按钮
		unset($this->list_buttons['Allocate']);//删除分配按钮
		unset($this->list_buttons['Share']);//删除共享按钮
		unset($this->list_buttons['Delete']);//删除删除按钮
        unset($this->list_buttons['ChangeCreator']);
		unset($this->list_buttons['Settings']);
	}
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-06-01
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		unset($this->list_buttons['More']['list']['mass_edit']);//批量编辑
		unset($this->list_buttons['More']['list']['Import']);//导入
        unset($this->list_buttons['More']['list']['Share']);//共享
		//导出
		if($this->list_buttons['More']['list']['Export']['permit'] == 'yes'){
			$this->list_buttons['Export'] = array(
				'label' => 	$this->list_buttons['More']['list']['Export']['label'],
				'permit' => 'yes',
				'icon' => 'icon-export',
                'btnkey'=>'Export'
			);
		}
		//恢复列宽设置
		if($this->list_buttons['More']['list']['ResetListWidth']['permit'] == 'yes'){
			$this->list_buttons['ResetListWidth'] = array(
				'label' => 	$this->list_buttons['More']['list']['ResetListWidth']['label'],
				'permit' => 'yes',
				'icon' => 'icon-ResetListWidth',
                'btnkey'=>'ResetListWidth'
			);
		}
		unset($this->list_buttons['More']);
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