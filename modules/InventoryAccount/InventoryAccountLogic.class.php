<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class InventoryAccountLogic extends BaseLogic {
	/**
	 * 初始化模块基础按钮
	 * @author Tujt 2015-06-01
	 */
	public function getListBasicBtn() {
		///parent::getListBasicBtn();
        //32516: 库存流水账、即时库存查询列表界面：不要更多按钮了，把里面的导出、恢复预设列框按钮放在同一行上面
        $module = self::$module;
        if('yes' == isPermitted($module, 'Export', '')){//判断导出权限
			$is_report = 'yes';
		}
       	$this->list_buttons['Export']['label'] = getFixedLabel('EXPORT');
		$this->list_buttons['Export']['permit'] = $is_report;
        $this->list_buttons['Export']['icon'] = 'icon-export';
        $this->list_buttons['Export']['btnkey'] = 'Export';
        //恢复列宽默认设置
		$this->list_buttons['ResetListWidth']['label'] = getFixedLabel('ResetListWidth');
		$this->list_buttons['ResetListWidth']['permit'] = 'yes';
        $this->list_buttons['ResetListWidth']['icon'] = 'icon-ResetListWidth';
        $this->list_buttons['ResetListWidth']['btnkey'] = 'ResetListWidth';
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