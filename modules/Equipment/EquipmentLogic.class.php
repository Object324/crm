<?php

class EquipmentLogic extends BaseLogic {

    /**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
		global $current_user;
		parent::getListMoreBtn();//调用父类方法
		$module = self::$module;
        $list_buttons = [];
        foreach ($this->list_buttons['More']['list'] as $btnkey => $btninfo) {
            $list_buttons[$btnkey] = $btninfo;
            // "导出设备码"默认放在"导出"后面
            if($btnkey == 'Export'){
                $list_buttons['ExportDevicecode']['label'] = getFixedLabel('ExportDevicecode');
                $list_buttons['ExportDevicecode']['permit'] = isPermitted($module, 'ExportDevicecode', '');
                $list_buttons['ExportDevicecode']['btnkey'] = 'ExportDevicecode';
            }
        }
        $this->list_buttons['More']['list'] = $list_buttons;
	}
    /**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-29
	 */
	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
		global $current_user;
        $module = self::$module;
		// 故障报修（关联创建客户服务单）
        $target_module = 'HelpDesk';
		$this->listview_link['FaultRepair']['label'] = getFixedLabel('FaultRepair');
		$this->listview_link['FaultRepair']['permit'] = isPermitted('HelpDesk','Create');// 是否有创建权限
        $target_url = 'index.php?module=' . $target_module . '&action=EditView&return_module=' . $target_module.'&return_action=DetailView&relatedcreate=yes&Create=true'
                        .'&frommodule=' . $module . '&fromid=' . $record . '&parent_id=' . $record;
		$this->listview_link['FaultRepair']['click'] = 'related_add_url(\'' . $target_url . '\',\'' . $module . '\',\'' . $target_module . '\',\'' . $record . '\')';
        if(!vtlib_isModuleActive('HelpDesk')){
            unset($this->listview_link['FaultRepair']);
        }
	}
    public function getallListViewLink() {
        $btn =array();
        $btn = parent::getallListViewLink();
        if(vtlib_isModuleActive('HelpDesk')){
            $btn['FaultRepair']['label'] = getFixedLabel('FaultRepair');// 故障报修
        }
        return $btn;
    }
    /**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-03
	 */
	public function getDetailBasicBtn() {
        parent::getDetailBasicBtn();//调用父类方法
        $share_btn_arr = $this->detail_buttons['More']['list']['Share'];
        unset($this->detail_buttons['More']['list']['Share']);

        // "导出设备码" 默认放在 "共享" 前面
        $this->detail_buttons['More']['list']['ExportDevicecode']['label'] = getFixedLabel('ExportDevicecode');
        $this->detail_buttons['More']['list']['ExportDevicecode']['permit'] = isPermitted(self::$module, 'ExportDevicecode', '');;
        $this->detail_buttons['More']['list']['ExportDevicecode']['icon'] = 'icon-selfserviceqrcode';
        
        $this->detail_buttons['More']['list']['Share']['label'] = $share_btn_arr['label'];
        $this->detail_buttons['More']['list']['Share']['permit'] = $share_btn_arr['permit'];
        $this->detail_buttons['More']['list']['Share']['icon'] = $share_btn_arr['icon'];
    }
}
?>