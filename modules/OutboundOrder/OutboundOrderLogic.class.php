<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class OutboundOrderLogic extends BaseLogic {
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-06-01
	 
	public function getListMoreBtn() {
		parent::getListMoreBtn();
	//	unset($this->list_buttons['More']['list']['mass_edit']);//删除导入按钮
	//	unset($this->list_buttons['More']['list']['Import']);//删除导入按钮
	}*/
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-03
	 */
	public function getListBasicBtn() {
		parent::getListBasicBtn();
		if(get_versiontrade() == 'anhe'){
			$this->list_buttons['Settlement']['label'] = getFixedLabel('Settlement');
			$this->list_buttons['Settlement']['permit'] = 'yes';
			$this->list_buttons['Settlement']['icon'] = 'icon-check';
			$this->list_buttons['Settlement']['btnkey'] = 'Settlement';
		}
	}
	public function getDetailBasicBtn() {
		parent::getDetailBasicBtn();
		$btn = array();//
		global $adb;
		$query = 'select presence from ld_outboundorder where out_id = ?';
		$result = $adb->pquery($query,array($this->controller->id));
		$presence = $adb->query_result($result,0,0);
		if(empty($presence)) $presence = NOTOUTBOUND;
		$checkout = isPermitted(self::$module,'Checkout',$this->controller->id);
		$acheckout = isPermitted(self::$module,'ACheckout',$this->controller->id);
        crm_load_class_file('CommonStock','include/Stock'); //0045295
		$curr_power = UserNationPower('OutboundOrder',$this->controller->id);
		//出库单是否启用审批流程
		$deployarray=getSys_deploy(135);
		$out_approvestatusw = $deployarray['deploy_value'];
     
		//审批不启用时，才显示审核、反审核按钮
		/*if($out_approvestatusw == 1){
			if(NOTOUTBOUND == $presence && 'yes' == $checkout){
				$btn['set_stock_presence_1']['label'] = getFixedLabel('Checkout');
				$btn['set_stock_presence_1']['permit'] = 'yes';
				$btn['set_stock_presence_1']['icon'] = 'icon-check';
				$btn['set_stock_presence_1']['tag'] = $curr_power;
			}else if(ALLOUTBOUND == $presence && 'yes' == $acheckout){
				$btn['set_stock_presence_2']['label'] = getFixedLabel('ACheckout');
				$btn['set_stock_presence_2']['permit'] = 'yes';
				$btn['set_stock_presence_2']['icon'] = 'icon-aCheckout';
				$btn['set_stock_presence_2']['tag'] = $curr_power;
			}
		}*/
	//	if(ALLOUTBOUND == $presence){
		//	$this->detail_buttons['moduledetailEdit']['permit'] = 'no';//已审核，不允许编辑
		//	$this->detail_buttons['Delete']['permit'] = 'no';//已审核，不允许删除
	//	}
		if(!empty($btn)){
			$this->detail_buttons = f_array_insert($this->detail_buttons,$btn,4);
		}
        //ls 2022-08-09  打印模板定制，增加参数“是否审批通过后才允许打印(这里控制着PC和移动端)
        $query  = "select approvedallowprint from ld_templateprint where tabid = ? and approvedallowprint = 'no'";
        $result = $adb->pquery($query,array(getTabid(self::$module)));
        if ($out_approvestatusw == 0 &&$adb->num_rows($result) <= 0) {//没有打印模板或者打印模板全部设置审批通过后才允许打印，则不显示打印按钮
            if($this->controller->column_fields['approvestatus']!=D_A_S_APPROVED) {
                unset($this->detail_buttons['Print']);
            }
        }
	}
    public function getEditViewBtn()
    {
        
        $presence = $this->controller->column_fields['presence'];
       $buttons=  parent::getEditViewBtn();
       $deployarray=getSys_deploy(135);
		$out_approvestatusw = $deployarray['deploy_value'];
        //36614: （1.6）系统设置>系统参数设置>库存参数>“设置出库和入库类库单据更新库存数量的触发点”设置为保存>新增出库单：新增的出库单保存后没有编辑按钮，如果开启了该模块的审批流程是有编辑按钮的。（需要补丁）
		//edit:can 202007 13 审批不启用时，才显示审核、反审核按钮
        //42100: （61mis.com/kfbcrm）系统设置>审批流程定制>出库单模块：审批流程中设置了“审批结束后允许编辑单据”，单据审批成功后无法编辑。（需要补丁）
	/*	if($out_approvestatusw == 1){
               if($this->controller->column_fields['approvestatus']==D_A_S_APPROVED)
               {
                $buttons['permit']='no';//已出库的单据不允许编辑
               }
        }
        if(ALLOUTBOUND == $presence){
            $buttons['permit']='no';//已出库的单据不允许编辑
        }*/
       return $buttons;
    }
    public function getDeleteBtn()
    {
        $presence = $this->controller->column_fields['presence'];
          $buttons=  parent::getDeleteBtn();
          //approvestatus:批量删除
          //36614: （1.6）系统设置>系统参数设置>库存参数>“设置出库和入库类库单据更新库存数量的触发点”设置为保存>新增出库单：新增的出库单保存后没有编辑按钮，如果开启了该模块的审批流程是有编辑按钮的。（需要补丁）
        $approve_focus = Approve::getInstance(self::$module);;
		  $startapprovemodule = $approve_focus->startBlocksApprove();
    
        //edit:can 2021-01-07 044153: （http://51mis.com/ys/liu322/ [^]）销售菜单—发货申请单审批流程已关闭，但在列表界面仍因为单据已审批的原因不能删除发货申请单单据
       if(isset($startapprovemodule[self::$module])&&$this->controller->column_fields['approvestatus']==D_A_S_APPROVED)
       {
        $buttons['permit']='no';//已出库的单据不允许删除
       }
       return $buttons;
    }
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-03
	 */
	public function getDetailMoreBtn() {
	   $VersionInfo = getVersionInfo();
       if($VersionInfo['trade']=='zhongfu')
	   {
	       //edit:can 2020-08-27 
	       $this->detail_buttons['More']['list']['zf_Changecf_2444']['label'] = "更改签回状态";
            $this->detail_buttons['More']['list']['zf_Changecf_2444']['permit'] ='yes';
       }
		parent::getDetailMoreBtn();
	}
    public function getallListViewLink() {
        $btn =array();
        $printbtn_permit = isPermitted(self::$module,'Print');
        if($printbtn_permit == 'yes'){
            $btn['print']['label'] = getFixedLabel('PRINT');;//确认
        }
        $btn = f_array_insert($btn,parent::getallListViewLink());
        return $btn;
    }
	/**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-26
	 */
	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
        global $adb;
		$btn = array();
		unset($this->listview_link['checkout']);//审核
		unset($this->listview_link['acheckout']);//反审核
		unset($this->listview_link['print']);//打印
        crm_load_function_file('selOutInfo','include/Stock','CommonStock');
		$btninfo = selOutInfo($record,1);
		//出库单是否启用审批流程
		$deployarray=getSys_deploy(135);
		$out_approvestatusw = $deployarray['deploy_value'];
		//审批不启用时，才显示审核、反审核按钮
		/*if($out_approvestatusw == 1){
			if($btninfo['presence'] == NOTOUTBOUND && isPermitted(self::$module,'Checkout',$record) == 'yes'){
				$btn['checkout']['label'] = getFixedLabel('Checkout');
				$btn['checkout']['permit'] = 'yes';
				$btn['checkout']['click'] = 'redirect(\'module='.self::$module.'&action=DetailView&record='.$record.'\')';
			}else if($btninfo['presence'] ==ALLOUTBOUND && isPermitted(self::$module,'ACheckout',$record) == 'yes'){
				$btn['acheckout']['label'] = getFixedLabel('ACheckout');
				$btn['acheckout']['permit'] = 'yes';
				$btn['acheckout']['click'] = 'set_stock_presence(\''.$record.'\',2,'.UserNationPower(self::$module,$record).')';
				$this->listview_link['edit']['permit']='no';
			}
		}*/
		//编辑
		$focus = CRMEntity::getInstance(self::$module);
		$focus->retrieve_entity_info($record,self::$module);
		$presence =$focus->column_fields['presence'];
		$checkout = isPermitted(self::$module,'Checkout',$record);
		$acheckout = isPermitted(self::$module,'ACheckout',$record);
     
		/*if(ALLOUTBOUND == $presence){
			$this->listview_link['edit']['permit'] = 'no';
		}*/
		//打印
        // ljj 20240130 BUG20240129-72 无管理员权限或打印权限 应该没有打印操作按钮
        $printbtn_permit = isPermitted(self::$module,'Print');
        if($printbtn_permit == 'yes'){
            //ls 2022-08-09  打印模板定制，增加参数“是否审批通过后才允许打印（若出库单所有模板都设置的是审批通过后才允许打印时，则单据列表和详情界面不显示“打印”）
            $query  = "select approvedallowprint from ld_templateprint where tabid = ? and approvedallowprint = 'no'";
            $result = $adb->pquery($query,array(getTabid(self::$module)));
            if ($out_approvestatusw == 0 && $adb->num_rows($result) <= 0) {//未审批通过的单据且打印模板全部设置为审批通过后才允许打印时不显示打印按钮，其他情况都显示
                if($this->controller->column_fields['approvestatus']==D_A_S_APPROVED)
                {
                    $btn['print']['label'] = getFixedLabel('PRINT');
                    $btn['print']['permit'] = 'yes';
                    $btn['print']['click'] = 'set_print_view(\''.self::$module.'\',this,\'printview\','.$record.')';
                    $this->listview_link = f_array_insert($this->listview_link,$btn);
                }
            }
            else{
                $btn['print']['label'] = getFixedLabel('PRINT');
                $btn['print']['permit'] = 'yes';
                $btn['print']['click'] = 'set_print_view(\''.self::$module.'\',this,\'printview\','.$record.')';
                $this->listview_link = f_array_insert($this->listview_link,$btn);
            }
        }

	}
	public function getActionUserd() {
		parent::getActionUserd();//调用父级方法
		$focus = CRMEntity::getInstance(self::$module);

        //创建销售发票
		$tabid = getTabid('Invoice');
 
		if(isset($this->quickactionLink[$tabid])){
			$tag = '&account_id='.$focus->column_fields['account_id'].'&entityid='.$focus->id.'&entityname='.self::$module.'';
			$this->quickactionLink[$tabid]['tag'] .= $tag;
		}		
		return $this->quickactionLink;
	}
    
    
}
?>