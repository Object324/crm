<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class PurchaseOrderLogic extends BaseLogic {
    /**
	 * 调用公共更多下拉列表，并添加相关下拉列表
	 * @author Tujt 2015-06-01
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();//调用父类方法
        global $adb;
		$module = self::$module;
		//unset($this->list_buttons['More']['list']['Import']);
		$approve_focus = $this->controller->getInstance('Approve');
		$startapprovemodule = $approve_focus->startBlocksApprove();
		$btn = array();
		if( 'yes' == isPermitted($module,'Updatestate','')){//更改状态
            $fieldobj = Field::getInstance($module,$adb);
            $postatus_fieldinfo = $fieldobj->getFieldInfoobjBykey('fieldname','postatus');
            if (!empty($postatus_fieldinfo)){
                $btn['Updatestate']['label'] = getFixedLabel('UPDATEPURCHASEORDERSTATUS');
                $btn['Updatestate']['permit'] = 'yes';
                $count = count($this->list_buttons['More']['list']);
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
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-04
	 
	public function getDetailBasicBtn() {
	    parent::getDetailBasicBtn();
		$approve_focus = $this->controller->getInstance('Approve');
		$startapprovemodule = $approve_focus->startBlocksApprove();
		
	} */
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-04
	 */
	public function getDetailMoreBtn() {
	    parent::getDetailMoreBtn();
        global $adb;
		/**
		 * 因为回款计划没有创建权限，所以判断回款计划的编辑权限
		 * @reason 0014304: 回款计划，权限问题
		 * @author Tujt 2015-04-22
		 */
         $btn = array();
        if( 'yes' == isPermitted(self::$module,'Updatestate')){//更改状态
            $fieldobj = Field::getInstance(self::$module,$adb);
            $postatus_fieldinfo = $fieldobj->getFieldInfoobjBykey('fieldname','postatus');
            if (!empty($postatus_fieldinfo)){
                $btn['Updatestate']['label'] = getFixedLabel('UPDATEPURCHASEORDERSTATUS');
                $btn['Updatestate']['permit'] = 'yes';
                $btn['Updatestate']['icon'] = 'icon-check';
                $keys=array_keys($this->detail_buttons['More']['list']);
                $index=array_search('Delete',$keys)+1;
                $this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn,$index);
            }
        }
        /* zxm20221201 刘总说去掉
        $btn=array();
		if(isPermitted('SendPayment','EditView') == 'yes' && vtlib_isModuleActive('SendPayment')){
			$btn['newsendpayment']['label'] = getFixedLabel('LBL_Creates').getTranstab('SendPayment');
			$btn['newsendpayment']['permit'] = 'yes';
			$deploytype = $this->getdeployType($this->controller->id);
			$btn['newsendpayment']['tag'] = $deploytype;
			$this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn);
		}*/
	}
	/**
	 * @author Tujt 2015-06-05
	 */
	public function getDeployType($record) {
		global $adb;
	    $deployarray = getSys_deploy(12);
		$deployvalue = $deployarray['deploy_value'];
		$sqlvendor='select ld_vendor.vendorname,purchaseorder_no,total,subtotal,ld_vendor.vendorid from ld_purchaseorder inner join ld_vendor on ld_purchaseorder.vendorid=ld_vendor.vendorid
						where purchaseorderid= '.$record;
		$purchaserorderresult=$adb->pquery($sqlvendor,array());
		$total=$adb->query_result($purchaserorderresult,0,"total");
		$sql="select if(currency_id > 1,ifnull(amount,0)/conversion_rate,ifnull(amount,0)),purchaseorder_id,cpperiodtime from ld_sendpayment inner join ld_crmentity
			  on ld_crmentity.crmid=ld_sendpayment.sendpaymentid  
			where ld_sendpayment.deleted=0 and purchaseorder_id= ".$record.' group by cpperiodtime order by cpperiodtime asc';
		$paymentresult=$adb->pquery($sql,array());
		$deployType = 0;
		if($adb->num_rows($paymentresult)>0)//如果有付款计划
		{
			for($i=0;$i<$adb->num_rows($paymentresult);$i++)
			{
				$paymentamount+=$adb->query_result($paymentresult,$i,0);//获取采购订单的合计计划金额
			}
			$nopaymentamount=$total-$paymentamount;    
		}
		if($deployvalue == 1 || $adb->num_rows($paymentresult)<=0){
			$deployType = 0;
		}else{
			if($nopaymentamount == 0){
				$deployType = 1;
			}else if($nopaymentamount < 0){
				$deployType = 2;
			}else{
				$deployType = 0;
			}   
		}
		return $deployType;
	}
	/**
	 * 获取对应的关联创建
	 * @author Tujt 2015-06-25
	 */
	public function getActionUserd() {
		parent::getActionUserd();
        $focus = CRMEntity::getInstance(self::$module);
		//供应商联系记录
		foreach($this->quickactionLink as $tabid => $action){
			if($action['module'] == 'Stock'){
				$this->quickactionLink[$tabid]['click'] = 'checkProductNum(\''.$action['module'].'\',\''.$action['return_id'].'\',1,\'\',\''.$this->quickactionLink[$tabid]['tag'].'\'); return false;';
				$this->quickactionLink[$tabid]['tag'] = '';
			}
		}
		$tabid = getTabid('VendorContactRecords');
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&vendor_id='.$this->controller->column_fields['vendor_id'].'';
			$this->quickactionLink[$tabid]['tag'] .= $tag;
		}
		//采购发票
		$tabid = getTabid('PurchaseInvoice');
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&entityid='.$focus->id.'&vendor_id='.$this->controller->column_fields['vendor_id'].'';
			$this->quickactionLink[$tabid]['tag'] .= $tag;
		}
		//采购退款单
		$tabid = getTabid('PurchaseCashBack');
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&vendor_id='.$this->controller->column_fields['vendor_id'].'';
			$this->quickactionLink[$tabid]['tag'] .= $tag;
		}
		//采购退货单
		$tabid = getTabid('PurchaseBack');
		if(isset($this->quickactionLink[$tabid])){
			$this->quickactionLink[$tabid]['click'] = 1;
			$this->quickactionLink[$tabid]['label'] = getFixedLabel('LBL_Creates').getTranstab('PurchaseBack');
			$stockpresence = $this->controller->column_fields['stockpresence'];
			$stock = 0;
            //采购订单直接退货
			$deployarray=getSys_deploy(132);
			$deployvalue = $deployarray['deploy_value'];
			if($deployvalue == 1){
				$stock = 1;
			}else{
			    //部分入库、全部入库
				if($stockpresence==PURCHASEPARTINSTOCK || $stockpresence==PURCHASEALLINSTOCK) $stock = 1;	
			}
			$tag = $stock.','.$this->controller->column_fields['vendor_id'];
			$this->quickactionLink[$tabid]['tag'] = $tag;
		}
		return $this->quickactionLink;
	}
}
?>