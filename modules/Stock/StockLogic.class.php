<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */

class StockLogic extends BaseLogic {
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-06-01
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		/*
		*edit:chj
		*date:2020-07-10
		*41970: （61mis.com/kfbcrm）入库单模块列表界面>更多：缺少了“批量编辑”功能
		*/
		//unset($this->list_buttons['More']['list']['mass_edit']);//删除批量编辑按钮
		//unset($this->list_buttons['More']['list']['Import']);//删除导入按钮
	}
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-03
	 */
	public function getDetailBasicBtn() {
		parent::getDetailBasicBtn();
		$btn = array();//
		global $adb;
		$query = 'select presence from ld_stock where stock_id = ?';
		$result = $adb->pquery($query,array($this->controller->id));
		$presence = $adb->query_result($result,0,0);
		if(empty($presence)) $presence = NOTINSTOCK;
		$checkout = isPermitted(self::$module,'Checkout',$this->controller->id);
		$acheckout = isPermitted(self::$module,'ACheckout',$this->controller->id);
        crm_load_class_file('CommonStock','include/Stock'); //0045293
		$curr_power = UserNationPower('Stock',$this->controller->id);
		//入库单是否启用审批流程
		$deployarray=getSys_deploy(136);
		$stock_approvestatusw = $deployarray['deploy_value'];
		//审批不启用时，才显示审核、反审核按钮
		/*if($stock_approvestatusw == 1){
			if(NOTINSTOCK == $presence && 'yes' == $checkout){
				$btn['set_stock_presence_1']['label'] = getFixedLabel('Checkout');
				$btn['set_stock_presence_1']['permit'] = 'yes';
				$btn['set_stock_presence_1']['icon'] = 'icon-check';
				$btn['set_stock_presence_1']['tag'] = $curr_power;
			}else if(ALLINSTOCK == $presence ){
			  if('yes' == $acheckout)
				{
					 $btn['set_stock_presence_2']['label'] = getFixedLabel('ACheckout');
					$btn['set_stock_presence_2']['permit'] = 'yes';
					$btn['set_stock_presence_2']['icon'] = 'icon-aCheckout';
					$btn['set_stock_presence_2']['tag'] = $curr_power;
				}
				$this->detail_buttons['moduledetailEdit']['permit'] = 'no';//已审核，不允许编辑
				$this->detail_buttons['Delete']['permit'] = 'no';//已审核，不允许删除
			}
		}*/
		if(!empty($btn)){
			$this->detail_buttons = f_array_insert($this->detail_buttons,$btn,4);
		}
	}
    public function getEditViewBtn()
    {
        $presence = $this->controller->column_fields['presence'];
       $buttons=parent::getEditViewBtn();
       $deployarray=getSys_deploy(136);
		$stock_approvestatusw = $deployarray['deploy_value'];
        if($stock_approvestatusw==1)//入库单没有启用审批流程
         {
            //36614: （1.6）系统设置>系统参数设置>库存参数>“设置出库和入库类库单据更新库存数量的触发点”设置为保存>新增出库单：新增的出库单保存后没有编辑按钮，如果开启了该模块的审批流程是有编辑按钮的。（需要补丁）
              if($this->controller->column_fields['approvestatus']==D_A_S_APPROVED)
           {
            $buttons['permit']='no';
           }
         }
       return $buttons;
    }
    public function getDeleteBtn()
    {
       $presence = $this->controller->column_fields['presence'];
       $buttons=parent::getDeleteBtn();
       //36614: （1.6）系统设置>系统参数设置>库存参数>“设置出库和入库类库单据更新库存数量的触发点”设置为保存>新增出库单：新增的出库单保存后没有编辑按钮，如果开启了该模块的审批流程是有编辑按钮的。（需要补丁）
       if($this->controller->column_fields['approvestatus']==D_A_S_APPROVED)
       {
        $buttons['permit']='no';
       }
       return $buttons;
    }
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-03
	 */
	public function getDetailMoreBtn() {
		parent::getDetailMoreBtn();
	}
    public function getallListViewLink() {
        $btn =array();
        $printbtn_permit = isPermitted(self::$module,'Print');
        if($printbtn_permit == 'yes') {
            $btn['print']['label'] = getFixedLabel('PRINT');
        }
        $btn = f_array_insert($btn,parent::getallListViewLink(),-1);
        return $btn;
    }
	/**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-26
	 */
	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
		$btn = array();
		unset($this->listview_link['checkout']);//审核
		unset($this->listview_link['acheckout']);//反审核
		unset($this->listview_link['print']);//打印
        crm_load_function_file('selStockInfo','include/Stock','CommonStock');
        $selstockinfos=selStockInfo($record);
		//入库单是否启用审批流程
		$deployarray=getSys_deploy(136);
		$stock_approvestatusw = $deployarray['deploy_value'];
		//审批不启用时，才显示审核、反审核按钮
		/*if($stock_approvestatusw == 1){
			if($selstockinfos['presence'] == NOTINSTOCK && isPermitted(self::$module,'Checkout',$record) == 'yes'){
				$btn['checkout']['label'] = getFixedLabel('Checkout');
				$btn['checkout']['permit'] = 'yes';
				$btn['checkout']['click'] = 'redirect(\'module='.self::$module.'&action=DetailView&record='.$record.'\')';
			}else if($selstockinfos['presence'] == ALLINSTOCK && isPermitted(self::$module,'ACheckout',$record) == 'yes'){
				$btn['acheckout']['label'] = getFixedLabel('ACheckout');
				$btn['acheckout']['permit'] = 'yes';
				$btn['acheckout']['click'] = 'setStockPresence(\''.$record.'\',2,'.UserNationPower(self::$module,$record).')';
				$this->listview_link['edit']['permit']='no';
			}
		}*/
		//打印
        // ljj 20240130 BUG20240129-72 无管理员权限或打印权限 应该没有打印操作按钮
        $printbtn_permit = isPermitted(self::$module,'Print');
        if($printbtn_permit == 'yes'){
            $btn['print']['label'] = getFixedLabel('PRINT');
            $btn['print']['permit'] = 'yes';
            $btn['print']['click'] = 'set_print_view(\''.self::$module.'\',this,\'printview\','.$record.')';
            $this->listview_link = f_array_insert($this->listview_link,$btn);
        }
	}
    
   	public function getActionUserd() {
		parent::getActionUserd();//调用父级方法
		$focus = CRMEntity::getInstance(self::$module);

        //创建销售发票
		$tabid = getTabid('PurchaseInvoice');
 
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&entityid='.$focus->id.'';
			$this->quickactionLink[$tabid]['tag'] .= $tag;
		}		
		return $this->quickactionLink;
	}
    
}
?>