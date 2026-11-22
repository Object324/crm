<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class SendCashBillLogic extends BaseLogic {
    /**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		//unset($this->list_buttons['More']['list']['Import']);//删除导入按钮
		$btn = array();
		$btn += $this->list_buttons['More']['list'];
		$this->list_buttons['More']['list'] = $btn;
	}
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-05
	 */
	public function getDetailBasicBtn() {
		parent::getDetailBasicBtn();
		$mbtn = 0;
		$checkoutstatus = $this->controller->column_fields['checkoutstatus'];
		$ischeckout = isPermitted(self::$module,'Checkout',$this->controller->id);
		$isacheckout = isPermitted(self::$module,'ACheckout',$this->controller->id);
		$btn = array();
		//付款单是否启用审批流程
		$deployarray=getSys_deploy(134);
		$sendcashbill_approvestatusw = $deployarray['deploy_value'];
		/*if($sendcashbill_approvestatusw == 1){
			if(('未审核' == $checkoutstatus || $checkoutstatus == '') && 'yes' == $ischeckout){
				$btn['checkcashbill_1']['label'] = getFixedLabel('Checkout');
				$btn['checkcashbill_1']['permit'] = 'yes';
				$btn['checkcashbill_1']['icon'] = 'icon-check';
			}else if('已审核' == $checkoutstatus ){
				  if('yes' == $isacheckout)
					{
					 $btn['checkcashbill_2']['label'] = getFixedLabel('ACheckout');
					 $btn['checkcashbill_2']['permit'] = 'yes';
						$btn['checkcashbill_2']['icon'] = 'icon-aCheckout';
					}
				//16045: 收款单>明细,关于反审核图标显示问题.
			
				$this->detail_buttons['moduledetailEdit']['permit'] = 'no';//已审核状态下不允许编辑
			}
		}*/
		$checkoutstatus = $this->controller->column_fields['checkoutstatus'];
		if('已审核' == $checkoutstatus){
			$this->detail_buttons['Delete']['permit'] = 'no';//已审核状态下不允许删除
		}
		if(!empty($btn)){
			$this->detail_buttons = f_array_insert($this->detail_buttons,$btn,-3);
		}
	}
      public function getEditViewBtn()
    {
      
       $buttons=  parent::getEditViewBtn();
       $checkoutstatus = $this->controller->column_fields['checkoutstatus'];
       $deployarray=getSys_deploy(134);
		$sendcashbill_approvestatusw = $deployarray['deploy_value'];
        if($sendcashbill_approvestatusw==1)
		{
		  if('已审核' == $checkoutstatus||$this->controller->column_fields['approvestatus']==D_A_S_APPROVED){
		          	$buttons['permit'] = 'no';//已审核状态下不允许删除
            }
		}
        return $buttons;
    }
    public function getDeleteBtn()
    {
        
        $buttons=  parent::getDeleteBtn();
       $checkoutstatus = $this->controller->column_fields['checkoutstatus'];
	   if('已审核' == $checkoutstatus)
       {
        $buttons['permit']='no';//已审核的单据不允许删除
       }
       return $buttons;
    }
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-05
	 */
	public function getDetailMoreBtn() {
		parent::getDetailMoreBtn();
        foreach($this->detail_buttons['More']['list'] as $key => $btninfo){
			if($btninfo['permit'] == 'yes'){
				$mbtn = 1;
				break;
				
			}
		}
		if($mbtn == 0){
			$this->detail_buttons['More']['list']['permit']='no';
		}
	}
	/**
	 * 判断当前单据是否可以编辑
	 * @author Tujt 2015-06-29
	 */
	public function checkStatusInfo($module,$record) {
	    $checkoutstatus = $this->getTableFldInfo($module,$record,'checkoutstatus');
		$check_no = $this->getTableFldInfo($module,$record,'sendcashbill_no');
		$approvestatus = $this->getTableFldInfo($module,$record,'approvestatus');
		$this->controller->id = $record;
		//付款单是否启用审批流程
		$deployarray=getSys_deploy(134);
		$sendcashbill_approvestatusw = $deployarray['deploy_value'];	//0 开启  1不开启
		if($sendcashbill_approvestatusw  == 1){
			if('已审核' == $checkoutstatus) return sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECK'),$check_no,getFixedLabel('EDIT'));
		}else{
		    //duan 20230801 修复付款单模块,设置了参数后,审批结束后无法编辑的问题
		    $button_info = $this->getEditViewBtn();
		    if($button_info['permit'] == 'yes'){
                return 'SUCCESS';
            }
			if($approvestatus == D_A_S_APPROVALOF || $approvestatus == D_A_S_APPROVED || $approvestatus == D_A_S_REJECTED){
				return sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVERING'),$check_no,getFixedLabel('EDIT'));
			}
		}
		return 'SUCCESS';
	}
	/**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-29
	 */
	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
		$checkoutstatus = $this->getTableFldInfo('SendCashBill',$record,'checkoutstatus');

        $this->listview_link['edit']['type'] = 'checkstatus';
        //duan 20230801 修复付款单模块,设置了参数后,审批结束后无法编辑的问题
        $deployarray=getSys_deploy(134);
        $sendcashbill_approvestatusw = $deployarray['deploy_value'];	//0 开启  1不开启
        if($sendcashbill_approvestatusw  == 1){
            if($checkoutstatus == '已审核'){
                $this->listview_link['edit']['permit'] = 'no';
            }
        }
	}
}
?>