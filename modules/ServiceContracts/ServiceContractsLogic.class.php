<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class ServiceContractsLogic extends BaseLogic {
	public function getListBasicBtn() {
		global $current_user;
		parent::getListBasicBtn();//调用父类方法
		//克莱门特  服务合同只能由销售合同、合同性质为“维保合同”关联生成，不允许单独创建服务合同。后半句，能把服务合同列表的新建按钮去掉吗？
		$VersionInfo = getVersionInfo();
		if($VersionInfo['account'] == 'climaveneta'){
		    //editor:gyq_161 reason:带产品分录模块弹出层   2019/11/21 17:43
			unset($this->list_buttons['Create']);
			//unset($this->list_buttons['ModuleDetailCreate']);
		}
	}
    /**
	 * 调用公共更多下拉列表，并添加相关下拉列表
	 * @author Tujt 2015-05-29
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();//调用父类方法
		$module = self::$module;
	//	$approve_focus = $this->controller->getInstance('Approve');
	//	$startapprovemodule = $approve_focus->startBlocksApprove();
		$btn = array();
        $fieldobj=$this->controller->fieldobj;
        $field=$fieldobj->getFieldInfoobjBykey('columnname','contract_status');
		if($field&&'yes' == isPermitted($module,'Updatestate','')){//更改状态
                $fieldobj=$this->controller->fieldobj;
            $field=$fieldobj->getFieldInfoobjBykey('columnname','contract_status');
            
			$btn['Updatestate']['label'] = getVarFixedLabel('CHANGECREATED',$field->getfieldLabel());
		
			$btn['Updatestate']['permit'] = 'yes';
			$this->list_buttons['More']['permit']='yes';
            $keys=array_keys($this->list_buttons['More']['list']);
            $index=sizeof($keys);
             if(in_array('ChangeCreator',$keys))
             {
                
                $index=array_search('ChangeCreator',$keys);
             }
            
		}
   
		if(!empty($btn)){
			$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,$index);
		}
	}

	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-04
	 */
	public function getDetailMoreBtn() {
	    parent::getDetailMoreBtn();//调用父类方法

		$btn = array();
        $fieldobj=$this->controller->fieldobj;
        $field=$fieldobj->getFieldInfoobjBykey('columnname','contract_status');
       
		if($field&& 'yes' == isPermitted(self::$module,'Updatestate')){//更改状态
            
			$btn['Updatestate']['label'] = getVarFixedLabel('CHANGECREATED',$field->getfieldLabel());
			$btn['Updatestate']['permit'] = 'yes';
			$btn['Updatestate']['icon'] = 'icon-check';
             $keys=array_keys($this->detail_buttons['More']['list']);
            
             if(in_array('Delete',$keys))
             {
                 $index=array_search('Delete',$keys)+1;
              	
             }
             else if(in_array('Share',$keys))
             {
                $index=array_search('Share',$keys)+1;
             }
             else if(in_array('Copy',$keys))
             {
                $index=array_search('Copy',$keys)+1;
             }
             else if(in_array('ChangeCreator',$keys))
             {
                
                $index=array_search('ChangeCreator',$keys);
             }
             $this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn,$index);
              
		}
            $btn=array();
		/**
		 * 因为回款计划没有创建权限，所以判断回款计划的编辑权限
		 * @reason 0014304: 回款计划，权限问题
		 * @author Tujt 2015-04-22
		 */
        /* zxm20221201 刘总说去掉if(isPermitted('PaymentPlan','EditView') == 'yes' && vtlib_isModuleActive('PaymentPlan')){
            $btn['paymentplancreate']['label'] = getFixedLabel('LBL_Creates').getTranstab('PaymentPlan');
            $btn['paymentplancreate']['permit'] = 'yes';
            $this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn);
        }*/

    }
    /**
     * 关联创建
     * @author Tujt 2015-06-18
     */
     /**
      * 注释：reason:0023539: 客户>明细：关联创建服务合同，负责人根据当前客户负责人显示，应该是显示当前用户。
      * date:2016/07/08 Liver
      
	public function setQuickCreateColumn($parent_module,$parent_id) {
		parent::setQuickCreateColumn($parent_module,$parent_id);
		if('Accounts' == $parent_module){
			$account_focus = CRMEntity::getInstance('Accounts');
			$account_focus->id = $parent_id;
			$account_focus->retrieve_entity_info($parent_id, 'Accounts');
			$this->controller->column_fields['ServiceContractsassigned_user_id'] = 
					$account_focus->column_fields['assigned_user_id'];
		}
	}*/
    
	/**
	 * 关联创建合同订单
	 * @author xiaoshun 2016-04-06
	 */
	public function getActionUserd() {
		parent::getActionUserd();//调用父级方法
		//创建服务合同
		$tabid = getTabid('PurchaseOrder');
		if(isset($this->quickactionLink[$tabid])){
            $tag = $this->quickactionLink[$tabid]['tag'];
            
            $tag .= '&vendor_id='.$this->controller->column_fields['vendor_id'].'&contact_id='.$this->controller->column_fields['vendorcontacts_id'];

            $this->quickactionLink[$tabid]['tag'] = $tag;
		}		
      
		return $this->quickactionLink;
	}
}

?>