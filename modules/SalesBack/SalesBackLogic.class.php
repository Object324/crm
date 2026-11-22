<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class SalesBackLogic extends BaseLogic {
	/**
	 * 初始化模块基础按钮
	 * @author Tujt 2015-06-01
	 */
	public function getListBasicBtn() {
		parent::getListBasicBtn();
        //ls 20221101 Xuqiu1000213 服务回访单、销售退货单、采购退货单、销售退款单、采购退款单增加“新建”功能
//		unset($this->list_buttons['Create']);
//		$btn = array();
//		$btn['salesbackhowtogoods']['label'] = getFixedLabel('HOWTOGOODS');
//		$btn['salesbackhowtogoods']['permit'] = 'yes';
//		$btn['salesbackhowtogoods']['icon'] = 'icon-ask';
//        $btn['salesbackhowtogoods']['btnkey'] = 'salesbackhowtogoods';
//		$this->list_buttons = f_array_insert($this->list_buttons,$btn);
	}
    /**
	 * 调用公共更多下拉列表，并添加相关下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();//调用父类方法
		//销售退货单，删除批量编辑、导入按钮
		unset($this->list_buttons['More']['list']['mass_edit']);
        //zkt 20240126 BUG20240126-09 界面放不出来导入这个按键（kfbcrm通用，销售退货单 角色权限里没有“导入”，在列表设置中显示的有“导入”，但是开启后列表上方也不显示）
		unset($this->list_buttons['Import']);
	}

    public function getEditViewBtn()
    {
      
       $buttons=  parent::getEditViewBtn();
      
		 if('结束' == $presence||$this->controller->column_fields['approvestatus']=='结束'){
			$buttons['permit'] = 'no';//已审核状态下不允许删除
		}
        return $buttons;
    }
    public function getDeleteBtn()
    {
        
        $buttons=  parent::getDeleteBtn();
      
         $presence = $this->controller->column_fields['salesbackstatus'];
       
       if('结束' == $presence||$this->controller->column_fields['approvestatus']=='中止'
       ||D_A_S_APPROVED==$this->controller->column_fields['approvestatus']){
			$buttons['permit'] = 'no';//已审核状态下不允许删除
		}
       return $buttons;
    }
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-04
	 */
	public function getDetailMoreBtn() {
		parent::getDetailMoreBtn();//调用父类方法
        unset($this->detail_buttons['Copy']);//删除复制按钮
		unset($this->detail_buttons['More']['list']['Copy']);//删除复制按钮
	}
	/**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-29
	 *///BUG0059378 ls 20221130 销售退货单已入库的未提交审批单据，单据列表界面应该显示编辑按钮
	/*public function setListViewLink($result,$record,$start,$idx) {
		$b = parent::setListViewLink($result,$record,$start,$idx);
		$status = $this->db->query_result($result,$idx,'salesbackstatus');
		$statusarr = array('已入库'=>1,'结束'=>1,'中止'=>1);
		if(isset($statusarr[$status])){
			unset($this->listview_link);
		}
	}*/
}
?>