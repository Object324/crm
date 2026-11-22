<?php

class CustomForm16Logic extends BaseLogic {
	public function getListMoreBtn() {
		global $current_user;
		parent::getListMoreBtn();//���ø��෽��
		$version_info = getVersionInfo();
		//chj 2022/6/15 浩辰特殊开发  合同拆分
		if($version_info['account'] == 'haochen'){
			unset($this->list_buttons['More']['list']['Export']);
			$btn['Export_haochen']['label'] =getFixedLabel('EXPORT');
			$btn['Export_haochen']['permit'] = 'yes';
			$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,1);
			
		}
	}
}
?>