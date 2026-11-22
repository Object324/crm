<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class CashBillLogic extends BaseLogic {
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
		$checkoutstatus = $this->controller->column_fields['checkoutstatus'];
		$ischeckout = isPermitted(self::$module,'Checkout',$this->controller->id);
		$isacheckout = isPermitted(self::$module,'ACheckout',$this->controller->id);
		$btn = array();
		//收款单是否启用审批流程
		$deployarray=getSys_deploy(133);
		$cashbill_approvestatusw = $deployarray['deploy_value'];
        //@edit:zkt @date:2024/12/20 @reason: XUQIU20240821-02   --- 系统参数，设置预收单核销后不允许反审批
        $sys_493 = getSys_deploy(493);//系统参数，设置预收单核销后不允许反审批
        $Iscancelunapproved = $sys_493['deploy_value'];
        if($Iscancelunapproved == 'yes'&&isset($this->controller->column_fields['cashtype'])&&$this->controller->column_fields['cashtype']=='debuction'
        &&isset($this->controller->column_fields['approvestatus'])&&$this->controller->column_fields['approvestatus'] == D_A_S_APPROVED){
            // 预收单、已批准、有反审批按钮时进一步判断是否显示反审批按钮
            if(is_array($this->detail_buttons)&&is_array($this->detail_buttons['cancel'])&&isset($this->detail_buttons['cancel']['permit'])&&$this->detail_buttons['cancel']['permit'] == 'yes')
            {
                $DebuctionInfo_arr = $this->controller->getDebuctionInfoByDebuctionid($this->controller->id);
                if(isset($DebuctionInfo_arr['not_0_count'])&&is_numeric($DebuctionInfo_arr['not_0_count'])&&(int)$DebuctionInfo_arr['not_0_count']>0){
                    $this->detail_buttons['cancel']['permit'] = 'no';
                }

            }
        }
        unset($sys_493,$Iscancelunapproved);
		
		
		if(!empty($btn)){
	       	$this->detail_buttons = f_array_insert($this->detail_buttons,$btn,-3);
		}
        
	}
     public function getListBasicBtn() {
        global $current_user;
		parent::getListBasicBtn();//调用父类方法
		$module = self::$module;$btn = array();
        if($this->list_buttons['Create']['permit']=='yes')
		{
		    $this->list_buttons['Create']['list']['CreateCashBill']['label'] = getFixedLabel('CreateCashBill');
    		$this->list_buttons['Create']['list']['CreateCashBill']['permit'] = 'yes';
    			
    		$this->list_buttons['Create']['list']['CreateDebuction']['label'] = getFixedLabel('CreateDebuction');
    		$this->list_buttons['Create']['list']['CreateDebuction']['permit'] = 'yes';
            
		}
        
    }
    /*
    public function getEditViewBtn()
    {
        //edit:can 20220607 已批准的单据允许编辑，无法判断，个人认为没有必要了，目前收款单审批后都有已批准，历史数据太早了不用考虑了
      
       $buttons=  parent::getEditViewBtn();
       $checkoutstatus = $this->controller->column_fields['checkoutstatus'];
		if('已审核' == $checkoutstatus){
			$buttons['permit'] = 'no';
		}
        return $buttons;
    }*/
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
		$mbtn = 0;
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
	/**
	 * 判断当前单据是否可以编辑
	 * @author Tujt 2015-06-29
	 */
	public function checkStatusInfo($module,$record) {
	   $buttons=  parent::getEditViewBtn();
		 if($buttons['permit']=='no')
		 {
			 $checkoutstatus = $this->getTableFldInfo($module,$record,'checkoutstatus');
				$check_no = $this->getTableFldInfo($module,$record,'cashbill_no');
			 return sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVERING'),$check_no,getFixedLabel('EDIT'));;
		 }
		return 'SUCCESS';
	} 
	/**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-29
	 */
	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
		$checkoutstatus = $this->getTableFldInfo('CashBill',$record,'checkoutstatus');
		$this->listview_link['edit']['type'] = 'checkstatus';
        //历史数据不用考虑了，已批准的单据可以设置编辑。历史数据太早了至少有3年了
		/*if($checkoutstatus == '已审核'){
			$this->listview_link['edit']['permit'] = 'no';
		}*/
	}
}
?>