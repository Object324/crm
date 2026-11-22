<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj 2016-11-14
 */
class ApproveLogic extends BaseLogic {
	/**
	 * 初始化模块基础按钮
	 * @author Chj 2016-11-14
	 */
	public function getListBasicBtn() {
		global $approvestatus;
		$buttons=array();
		$this->list_buttons = '';
		//批量提交
		$approve_focus = Approve::getInstance($_REQUEST['fromApproveModule']);
		$startapprovemodule = $approve_focus->startBlocksApprove();
		$issubmit = 'no';
		if(isset($startapprovemodule[$_REQUEST['fromapprovemodule']])) $issubmit = 'yes';
		if($approvestatus == 1)$issubmit = 'no';
		if($approvestatus == 3 || $approvestatus == 4){
			$buttons['resubmitapprove'] = array(
				'label' => getFixedLabel('resubmit'),
				'permit' => $issubmit,
				'icon' => 'icon-check',
                'btnkey'=>'resubmitapprove'
			);
		}else{
			$buttons['batchapprove'] = array(
				'label' => getFixedLabel('APPROVE_BATCHAPPROVED'),
				'permit' => $issubmit,
				'icon' => 'icon-check',
                'btnkey'=>'batchapprove'
			);
		}
		
//		$buttons['Search'] = array(
//			'label' => getFixedLabel('SEARCH'),
//			'permit' => 'yes',
//			'icon' => 'icon-search',
//            'btnkey'=>'Search',
//		);
		$buttons['ResetListWidth'] = array(
			'label' => getFixedLabel('ResetListWidth'),
			'permit' => 'yes',
			'icon' => 'icon-ResetListWidth',
            'btnkey'=>'ResetListWidth'
		);
        $this->list_buttons=$buttons;
	}
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Chj 2016-11-14
	 */
	public function getListMoreBtn() {
		
	}
}
?>