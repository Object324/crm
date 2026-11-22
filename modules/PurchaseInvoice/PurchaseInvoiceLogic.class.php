<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class PurchaseInvoiceLogic extends BaseLogic {
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-06-01
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		//unset($this->list_buttons['More']['list']['Import']);//删除导入按钮
		$module = self::$module;
	//	$approve_focus = $this->controller->getInstance('Approve');
	//	$startapprovemodule = $approve_focus->startBlocksApprove();
		$btn = array();
        $fieldobj=$this->controller->fieldobj;
        $field=$fieldobj->getFieldInfoobjBykey('columnname','purchaseinvoicestatus');
		if($field&& 'yes' == isPermitted($module,'Updatestate','')){//更改状态
			$btn['Updatestate']['label'] =  getVarFixedLabel('CHANGECREATED',$field->getfieldLabel());
			$btn['Updatestate']['permit'] = 'yes';
			$this->list_buttons['More']['permit']='yes';
			$keys=array_keys($this->list_buttons['More']['list']);
            $index=sizeof($keys);
             if(in_array('ChangeCreator',$keys))
             {
                
                $index=array_search('ChangeCreator',$keys);
             }
			$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,$index);
		}
	}
    
   	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-04
	
	public function getDetailBasicBtn() {
	    parent::getDetailBasicBtn();
		$approve_focus = $this->controller->getInstance('Approve');
		$startapprovemodule = $approve_focus->startBlocksApprove();
		
	} */
    
    public function getDetailMoreBtn()
    {
        parent::getDetailMoreBtn();
         /* zxm20221201 刘总说去掉
		$btn=array();
		if(isPermitted('SendPayment','EditView') == 'yes' && vtlib_isModuleActive('SendPayment')){
			$btn['newsendpayment']['label'] = getFixedLabel('LBL_Creates').getTranstab('SendPayment');
			$btn['newsendpayment']['permit'] = 'yes';
			$this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn);
		}
        */
        $btn = array();
        $fieldobj=$this->controller->fieldobj;
        $field=$fieldobj->getFieldInfoobjBykey('columnname','purchaseinvoicestatus');
		if($field&& 'yes' == isPermitted(self::$module,'Updatestate')){//更改状态
			$btn['Updatestate']['label'] = getVarFixedLabel('CHANGECREATED',$field->getfieldLabel());
			$btn['Updatestate']['permit'] = 'yes';
			$btn['Updatestate']['icon'] = 'icon-check';
			$keys=array_keys($this->detail_buttons['More']['list']);
            $index=array_search('Delete',$keys)+1;
			$this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn,$index);
		}
    }
}
?>