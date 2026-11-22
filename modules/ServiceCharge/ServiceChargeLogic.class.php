<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class ServiceChargeLogic extends BaseLogic {
	/**
	 * 服务收费，添加移动分组
	 * @author Tujt 2015-05-29
	 */
	public function getListBasicBtn() {
	    parent::getListBasicBtn();//调用父类方法
		$module = self::$module;
		$is_edit = isPermitted($module,'EditView','');
		$btn = array();
		//if('yes' == $is_edit){//有编辑权限，则有移动分组权限
			//$btn['movegroup']['label'] = getFixedLabel('MOVEGROUP');
			//$btn['movegroup']['permit'] = 'yes';
			//$btn['movegroup']['icon'] = 'icon-user';
	//	}
   
		$count = count($this->list_buttons);
		$this->list_buttons = f_array_insert($this->list_buttons,$btn,$count-2);
        
        //收费管理调用客户审批
        $btns = array();
		$approve_focus = $this->controller->getInstance('Approve');
		$startapprovemodule = $approve_focus->startBlocksApprove();
        
        
        $allocateBtn=array();
        //分配
        $allocateBtn['distribution']['label'] = getFixedLabel('ALLOCATE');
        $allocateBtn['distribution']['permit'] = 'yes';
        $allocateBtn['distribution']['btnkey'] = 'distribution';
        //平均分配
        $allocateBtn['averageDistribution']['label'] = getFixedLabel('AVERAGEDISTRIBUTION');
        $allocateBtn['averageDistribution']['permit'] = 'yes';
        $allocateBtn['averageDistribution']['btnkey'] = 'averageDistribution';
        
		$issubmit = 'no';
		if(isset($startapprovemodule['Accounts'])) $issubmit = 'yes';
			$btns['submitapprove']['label'] = getFixedLabel('APPROVE_BATCHSUBMIT');
			$btns['submitapprove']['permit'] = $issubmit;
			$btns['submitapprove']['icon'] = 'icon-check';
            $btns['submitapprove']['btnkey'] = 'submitapprove';
        $this->list_buttons['Allocate']['list'] = $allocateBtn;
		$this->list_buttons = f_array_insert($this->list_buttons,$btns,-1);
          $tmp_list_buttons=array();
        foreach($this->list_buttons as $btnname=>$content)
        {
            $tmp_list_buttons[$btnname]=$content;
            if($btnname=='submitapprove')
            {
           	    $tmp_list_buttons['Datadupcheck']['label'] = getFixedLabel('ACCOUNTDUPLICATECHECK');
        		$tmp_list_buttons['Datadupcheck']['permit'] = isPermitted('ServiceCharge','accountdatadup');
        		$tmp_list_buttons['Datadupcheck']['icon'] = 'icon-search';
                $tmp_list_buttons['Datadupcheck']['btnkey'] = 'Datadupcheck';
            }
        }
        $this->list_buttons=$tmp_list_buttons;
	}
    /**
	 * 调用公共更多下拉列表，并添加相关下拉列表
	 * @author Tujt 2015-05-29
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();//调用父类方法
		//删除批量编辑
		//unset($this->list_buttons['More']['list']['mass_edit']);
	//	unset($this->list_buttons['More']['list']['Import']);
		$is_email = 'no';$is_sms = 'no';$more_idx = 0;
		//群发邮件
		if('yes' == isPermitted('MassEmails', 'index', '') && vtlib_isModuleActive('MassEmails')){
			$is_email = 'yes';$more_idx = 1;
		}
		//群发短信
		if('yes' == isPermitted('MassSMS', 'index', '') && vtlib_isModuleActive('MassSMS')){
			$is_sms = 'yes';$more_idx = 1;
		}
		$btn['s_mail']['label'] = getFixedLabel('BULKMAIL');
		$btn['s_mail']['permit'] = $is_email;
		$btn['s_sms']['label'] = getFixedLabel('BULKSMS');
		$btn['s_sms']['permit'] = $is_sms;
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,1);
		$btn = array();
        //editor:gyq_72 reason:查重合并样式修改 date:20180705
        $dup_and_merge_permit = 'no';
		if('yes' == isPermitted(self::$module, 'dup_and_merge','')){
            $dup_and_merge_permit = 'yes';$more_idx = 1;
		}
		$btn['Findduplicates']['label'] = getFixedLabel('CHECKMERGE');
		$btn['Findduplicates']['permit'] = $dup_and_merge_permit;
		$count = count($this->list_buttons['More']['list']);
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,$count-1);
        //Eidtor:gyq_65 Reason:原查重合并改为合并 Date:2018/3/28 0028 上午 9:32
        $merge_permit = 'no';
		if('yes' == isPermitted(self::$module, 'Merge','')){
            $merge_permit = 'yes';$more_idx = 1;
		}
		$btn = array();
		$btn['RecordMerge']['label'] = getFixedLabel('Merge');
		$btn['RecordMerge']['permit'] = $merge_permit;
		$count = count($this->list_buttons['More']['list']);
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,$count-1);
        
        //批量回填
        $backfill_permit = 'no';
        crm_load_class_file('cls_BusinessInformation', 'modules/Users');
        $businessinformationobj = cls_BusinessInformation::getInstance(self::$module);
        if($businessinformationobj->IsEnableBatchbackfill() && isPermitted(self::$module, 'BatchBackFilling','')=='yes'){
            $backfill_permit = 'yes';
        }
        $btn = array();
        $btn['BatchBackFilling']['label'] = getFixedLabel('BatchBackFilling');
        $btn['BatchBackFilling']['permit'] = $backfill_permit;
        $count = count($this->list_buttons['More']['list']);
        $this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,$count-1);

		//判断更多按钮是否显示
		if(('no' == $this->list_buttons['More']['permit'] && 1 == $more_idx)
        ||$this->list_buttons['submitapprove']['permit']=='yes'){//批量提交按钮被放入更多按钮中
			$this->list_buttons['More']['permit'] = 'yes';
		}
        $tmp_more_list_buttons=array();
        foreach($this->list_buttons['More']['list'] as $btname=>$content)
        {
            $tmp_more_list_buttons[$btname]=$content;
           
            if($btname=='mass_edit')
            {
                $tmp_more_list_buttons['submitapprove']=$this->list_buttons['submitapprove'];
                unset($this->list_buttons['submitapprove']);
                
            }
        }
		$this->list_buttons['More']['list']=$tmp_more_list_buttons;
	}
    
   	/**
	 * 获取详情页按钮对象
	 * @author Andrew 2015-07-06
	 */
	public function getDetailBasicBtn() {
	    parent::getDetailBasicBtn();//调用父类方法
		$approve_focus = $this->controller->getInstance('Approve');
		$startapprovemodule = $approve_focus->startBlocksApprove();
		if(isset($startapprovemodule['Accounts'])){//审批模块
            $btns = array();
			$this->getApproveButton('Accounts',$this->controller,$this->controller->id);
			if(!empty($this->approvebtn['info'])){
				if(1 == $this->approvebtn['submit']){//提交审批
					$btns['submit']['label'] = getFixedLabel('SUBMITAPPROVAL');
					$btns['submit']['permit'] = 'yes';
					$btns['submit']['icon'] = 'icon-check';
				}else if(1 == $this->approvebtn['approve']){//审批
					$btns['approve']['label'] = getFixedLabel('APPROVAL');
					$btns['approve']['permit'] = 'yes';
					$btns['approve']['icon'] = 'icon-check';
				}
				if(1 == $this->approvebtn['cancel']){//反审批
					$btns['cancel']['label'] = getFixedLabel('APPROVE_ANTIAPPROVAL');
					$btns['cancel']['permit'] = 'yes';
					$btns['cancel']['icon'] = 'icon-del';
				}
				if(1 == $this->approvebtn['edit']){//不允许编辑
					$btns['Edit']['permit'] = 'no';
				}
			}else{//默认有提交审批按钮
				$submit = 1;
				//已批准、审批中、已拒绝状态下，不提交审批
				$statusarray = array(
					constant('D_A_S_APPROVED')=>'1',//已批准
					constant('D_A_S_APPROVALOF')=>'1',//审批中
					constant('D_A_S_REJECTED')=>'1'//已拒绝
				);
				if(isset($this->controller->column_fields['approvestatus']) && 
						!empty($this->controller->column_fields['approvestatus'])){
					$approvestatus = $this->controller->column_fields['approvestatus'];
					if($statusarray[$approvestatus]){
						$submit = 0;
					}
					//没有审批历史，但审批状态为已批准，不允许编辑
					if(constant('D_A_S_APPROVED') == $approvestatus){
						$btns['Edit']['permit'] = 'no';
					}
				}
				if($submit == 1){//非已审批、审批中、已拒绝状态，允许提交审批
					$btns['submit']['label'] = getFixedLabel('SUBMITAPPROVAL');
					$btns['submit']['permit'] = 'yes';
					$btns['submit']['icon'] = 'icon-check';
				}
			}
            //32429: 1.服务收费管理、出纳提现单明细界面>操作行>点击审批：显示错误。2.服务收费管理明细界面>操作行>审批按钮：审批按钮的位置错误了，应该在分配按钮的后面
            $i=0;
            foreach($this->detail_buttons as $key=>$content)
            {
                $i++;
                if(strtolower($key)=='allocate')
                {
                    
                    break;
                }
            }
         
            $this->detail_buttons = f_array_insert($this->detail_buttons,$btns,$i);
		}
	}

    public function getallListViewLink() {
        $btn =array();
        if(!vtlib_isModuleActive('ContactRecords')){
            $btn['followup']['label'] = getFixedLabel('FOLLOWUP');//跟进
        }
        $btn = f_array_insert($btn,parent::getallListViewLink());
        return $btn;
    }
	/**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-29
	 */
	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
		global $current_user;
		$btn = array();
		//跟进
		$btn['followup']['label'] = getFixedLabel('FOLLOWUP');//跟进
		$btn['followup']['permit'] = isPermitted('ContactRecords','Create');//是否有联系记录的创建权限
		global $related_left_record;
		if(empty($related_left_record)) $related_left_record = 0;
		$btn['followup']['click'] = 'CreateContactRecordsByAccounts(this,\''.$related_left_record.'\',\'%d\',\'ServiceCharge\',\'index\')';
		$this->listview_link = f_array_insert($this->listview_link,$btn,-1);
        if(!vtlib_isModuleActive('ContactRecords')){
            unset($this->listview_link['followup']);
        }
	}
}
?>