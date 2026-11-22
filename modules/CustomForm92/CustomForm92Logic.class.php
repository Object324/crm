<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class CustomForm92Logic extends BaseLogic {
    
	public function getListBasicBtn() {
		global $current_user;
		parent::getListBasicBtn();//调用父类方法
		//东贸 - 佣金记录模块，不允许新增单据
		$version_info = getVersionInfo();
		if($version_info['account'] == 'dongmao'){
			$this->list_buttons['Create']['permit'] = 'no';
		}
	}

	public function getDetailBasicBtn() {
	    parent::getDetailBasicBtn();//调用父类方法
		//东贸 - 佣金记录模块，不允许新增单据
		$version_info = getVersionInfo();
		if($version_info['account'] == 'dongmao'){
			$this->detail_buttons['Copy']['permit'] = 'no';
		}
		
	}
}
?>