<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class ServiceReturnLogic extends BaseLogic {

    /**
	 * 去掉创建按钮
	 * @author Tujt 2015-06-01
	 */
	public function getListBasicBtn() {
	    parent::getListBasicBtn();
        //ls 20221101 Xuqiu1000213 服务回访单、销售退货单、采购退货单、销售退款单、采购退款单增加“新建”功能（服务回访单允许新建）
		/*unset($this->list_buttons['Create']);
		$btn = array();//如何创建回款计划
		$btn['howToservicereturn']['label'] = getFixedLabel('How_to_create_return');
		$btn['howToservicereturn']['permit'] = 'yes';
		$btn['howToservicereturn']['icon'] = 'icon-ask';
        $btn['howToservicereturn']['btnkey'] = 'howToservicereturn';
		$this->list_buttons = f_array_insert($this->list_buttons,$btn);*/
	}
    
    	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-05
	 */
	public function getDetailBasicBtn() {
		parent::getDetailBasicBtn();
		//0013831:回款计划/付款计划>明细,关于编辑/删除权限的问题
	  //
		unset($this->detail_buttons['Create']);
        //32378: 服务回访单明细界面>操作列：不应该有复制按钮。（服务回访单是不能直接新建的）
        unset($this->detail_buttons['Copy']);
		//	0022427: 服务回访单：单据明细界面，没有显示【编辑】按钮
        //unset($this->detail_buttons['Edit']);
	}
    
    public function getListMoreBtn(){
        parent::getListMoreBtn();
       
        unset($this->list_buttons['More']['list']['Import']);
    }
    
    public function getDetailMoreBtn(){
        parent::getDetailMoreBtn();
        //0025893: 服务回访单明细：更多中显示了复制按钮，没有新增权限的单据明细是不会显示这个按钮的
        unset($this->detail_buttons['More']['list']['Copy']);
    }
}
?>