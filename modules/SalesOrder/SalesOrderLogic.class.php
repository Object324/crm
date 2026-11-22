<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class SalesOrderLogic extends BaseLogic {
	/**
	 * 初始化模块基础按钮
	 * @author Tujt 2015-05-28
	 */
	public function getListBasicBtn() {
		parent::getListBasicBtn();
		$module = self::$module;
		$smsarray = GetSMSAutograph();
		$smsName = $smsarray['account_name'];//账号
		//获取前三个元素
		$btn = array();
	 $buttons=array();
     $focus=CRMEntity::getInstance("SalesOrder");
     $version=getVersionTradeInfo();//获取数据库行业版本
     $version_trade=$version['trade'];     
     
        foreach($this->list_buttons as $key=>$button)
        {
            if(strtolower($key)=='more' && $version_trade=='finance') //合同订单序时簿【利息重算】按钮只在finance账套显示
            {
                $buttons['rate_recalculate']['label']=getFixedLabel('RATERECALCULATE');
                
                $buttons['rate_recalculate']['permit'] = isPermitted('DividendOrder', 'EditView', '');
	           	$buttons['rate_recalculate']['icon'] = 'icon-refresh2';
                $buttons['rate_recalculate']['btnkey'] = 'rate_recalculate';
               
            }
          
           $buttons[$key]=$button;
            
        }
        $this->list_buttons=$buttons;
	}
    /**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		$module = self::$module;
		//$approve_focus = $this->controller->getInstance('Approve');
	//	$startapprovemodule = $approve_focus->startBlocksApprove();
		$btn = array();
        $fieldobj=$this->controller->fieldobj;
        $field=$fieldobj->getFieldInfoobjBykey('columnname','sostatus');
        $version = getVersionTradeInfo();
        if($version['trade'] == 'zhongfu')
        {
            $this->list_buttons['More']['list']['Revenueplan']['permit']=isPermitted('CustomForm48','Create');
            $this->list_buttons['More']['list']['Revenueplan']['label']=getTranstab('CustomForm48');
        }
		//chj 2021/6/9 4.销售合同：增加类似“订单状态”的字段，不受审批控制可以随时修改编辑
		if($version['trade'] == 'zhongfu' && 'yes' == isPermitted($module,'Updatestate','')){
			$btn['specialfield_edit']['label'] = getFixedLabel('EDITAPPROVEORDER');
			$btn['specialfield_edit']['permit'] = 'yes';
			$this->list_buttons['More']['permit']='yes';
            $keys=array_keys($this->list_buttons['More']['list']);
            $index=sizeof($keys);
             if(in_array('ChangeCreator',$keys))
             {
                
                $index=array_search('ChangeCreator',$keys);
             }
			$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,$index);
            //中孚：销售合同列表增加“收入确认计划”按钮，
            
		}else{
			if( $field&&'yes' == isPermitted($module,'Updatestate','')){//更改状态
				$btn['Updatestate']['label'] = getFixedLabel('UPDATESTATE');
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
	}

	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-04
	 */
	public function getDetailMoreBtn() {
	    parent::getDetailMoreBtn();
		$module = self::$module;
		/**
		 * 因为回款计划没有创建权限，所以判断回款计划的编辑权限
		 * @reason 0014304: 回款计划，权限问题
		 * @author Tujt 2015-04-22
		 */
         $btn = array();
        $fieldobj=$this->controller->fieldobj;
        $field=$fieldobj->getFieldInfoobjBykey('columnname','sostatus');
		 $version = getVersionTradeInfo();
		//chj 2021/6/9 4.销售合同：增加类似“订单状态”的字段，不受审批控制可以随时修改编辑
		if($version['trade'] == 'zhongfu' && 'yes' == isPermitted($module,'Updatestate','')){
			$btn['specialfield_edit']['label'] = getFixedLabel('EDITAPPROVEORDER');
			$btn['specialfield_edit']['permit'] = 'yes';
			$btn['specialfield_edit']['icon'] = 'icon-check';
			$keys=array_keys($this->detail_buttons['More']['list']);

			$index=array_search('Delete',$keys)+1;
			$this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn,$index);
		}else{
			if($field&&$field&&'yes' == isPermitted(self::$module,'Updatestate')){//更改状态
				$btn['Updatestate']['label'] = getFixedLabel('UPDATESTATE');
				$btn['Updatestate']['permit'] = 'yes';
				$btn['Updatestate']['icon'] = 'icon-check';
				$keys=array_keys($this->detail_buttons['More']['list']);
			  
				$index=array_search('Delete',$keys)+1;
				$this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn,$index);
			}
		}

        /* zxm20221201 刘总说去掉
        $btn=array();
        if(isPermitted('PaymentPlan','EditView') == 'yes' && vtlib_isModuleActive('PaymentPlan')){
            $btn['paymentplancreate']['label'] = getFixedLabel('LBL_Creates').getTranstab('PaymentPlan');
            $btn['paymentplancreate']['permit'] = 'yes';
            $this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn);
        }*/
        $btn = array();
        if(get_file_address(self::$module,'ProductDetails') && '1' == getDatainterface('using_inventory')){
           $btn['synchronousinventory']['label'] = getFixedLabel('SYNCHRONOUSINVENTORY');
           $btn['synchronousinventory']['permit'] = 'yes';
           $this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn,-1);
        }
        //如果是金融行业  显示创建 派息单
        $btn = array();
        $focus=CRMEntity::getInstance("SalesOrder");

        $btn['dividendcreate']['label'] = getFixedLabel('LBL_Creates').getTranstab('DividendOrder');
           $version = getVersionTradeInfo();
        if(strtolower($version['trade']) == TRADE_FINANCE && vtlib_isModuleActive('DividendOrder') && isPermitted('DividendOrder','EditView') == 'yes'){
                 $btn['dividendcreate']['permit'] = 'yes';
              }else{
                 $btn['dividendcreate']['permit'] = 'no';
              }

        $this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn,0);

         if( strtolower($version['trade'])=='jijin') //合同订单查看【业绩报酬计提】按钮只在基金账套显示
            {
                $btn['jijin_management_accured']['label']=getTranstab('Management').getFixedLabel('PROVISION');
                $btn['jijin_management_accured']['permit'] ='yes';
                   $btn['jijin_management_accured']['icon'] = 'icon-ask';
                   $this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn,0);


                 $btn['jijin_management_commission_accured']['label']=getTranstab('Mcommission').getFixedLabel('PROVISION');
                $btn['jijin_management_commission_accured']['permit'] ='yes';
                   $btn['jijin_management_commission_accured']['icon'] = 'icon-ask';
                   $this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn,0);


                $btn['jijin_reward_accured']['label']=getTranstab('FundReward').getFixedLabel('PROVISION');
                $btn['jijin_reward_accured']['permit'] ='yes';
                   $btn['jijin_reward_accured']['icon'] = 'icon-ask';
                   $this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn,0);

                $btn['jijin_reward_commission_accured']['label']=getTranstab('FundRewardCommission').getFixedLabel('PROVISION');
                $btn['jijin_reward_commission_accured']['permit'] ='yes';
                   $btn['jijin_reward_commission_accured']['icon'] = 'icon-ask';
                   $this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn,0);
            }
    }
    /**
     * 获取对应的关联创建
     * @author Tujt 2015-06-17
     */
	public function getActionUserd() {
		parent::getActionUserd();//调用父级方法
		//创建收款单
		$tabid = getTabid('CashBill');
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&convertmode=update_so_val';
			$this->quickactionLink[$tabid]['tag'] .= $tag;
		}
		//创建出库单
		$tabid = getTabid('OutboundOrder');
		if(isset($this->quickactionLink[$tabid])){
			$this->quickactionLink[$tabid]['click'] = 1;//点击事件
			$this->quickactionLink[$tabid]['tag'] = $this->controller->column_fields['account_id'];
		}
		//创建回款计划
		$tabid = getTabid('PaymentPlan');
		if(isset($this->quickactionLink[$tabid])){
			$this->quickactionLink[$tabid]['label'] = getFixedLabel('Adjustment').getTranstab('PaymentPlan');
			$this->quickactionLink[$tabid]['click'] = 1;//点击事件
		}
		//创建销售发票
		$tabid = getTabid('Invoice');
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&entityid='.$this->controller->id.'&convertmode=sotoinvoice&entityname=SalesOrder';
			$tag .= '&account_id='.$this->controller->column_fields['account_id'].'';
            //$this->quickactionLink[$tabid]['tag'] = $tag;  //edit:cyb 之前这里少了连接符，现在加上，确保frommodule有值；
			$this->quickactionLink[$tabid]['tag'] .= $tag;
		}
		//服务合同
		$tabid = getTabid('ServiceContracts');
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&convertmode=update_so_val';
			$this->quickactionLink[$tabid]['tag'] .= $tag;
		}
		//采购订单
		$tabid = getTabid('PurchaseOrder');
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&convertmode=update_so_val';
			$this->quickactionLink[$tabid]['tag'] .= $tag;
		}
		//费用报销
		$tabid = getTabid('Expense');
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&convertmode=update_so_val';
			$tag .= '&potential_id='.$this->controller->column_fields['potential_id'].'';
			$this->quickactionLink[$tabid]['tag'] .= $tag;
		}
		//佣金单
		$tabid = getTabid('Commission');
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&convertmode=update_so_val';
			$this->quickactionLink[$tabid]['tag'] .= $tag;
		}
		//联系记录
		$tabid = getTabid('ContactRecords');
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&potential_id='.$this->controller->column_fields['potential_id'].'';
			$this->quickactionLink[$tabid]['tag'] .= $tag;
		}
		//提醒
		$tabid = getTabid('Reminds');
		if(isset($this->quickactionLink[$tabid])){
			$tag .= '&account_id='.$this->controller->column_fields['account_id'].'';
			//$this->quickactionLink[$tabid]['tag'] = $tag;  //edit:cyb 之前这里少了连接符，现在加上，确保frommodule有值；
            $this->quickactionLink[$tabid]['tag'] .= $tag;
		}
		//项目
		$tabid = getTabid('Project');
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&convertmode=update_so_val';
			$this->quickactionLink[$tabid]['tag'] .= $tag;
		}
		//销售退货单
		$tabid = getTabid('SalesBack');
		if(isset($this->quickactionLink[$tabid])){
			$this->quickactionLink[$tabid]['click'] = 1;
			$type = 0;
			//合同订单直接退货
			$deployarray=getSys_deploy(85);
			$deployvalue = $deployarray['deploy_value'];
			if($deployvalue == 1){
				$type = 1;
			}else{
				require_once ('include/Stock/CommonStock.php');
				if(NOTOUTBOUND != $this->controller->column_fields['stockpresence']){
					$type = 1;
				}	
			}
			$tag = $type.'-'.$this->controller->column_fields['account_id'];
			$this->quickactionLink[$tabid]['tag'] = $tag;
			$this->quickactionLink[$tabid]['label'] = getFixedLabel('LBL_Creates').getTranstab('SalesBack');
		}
		//知识管理 有问题啊
		return $this->quickactionLink;
	}
}
?>