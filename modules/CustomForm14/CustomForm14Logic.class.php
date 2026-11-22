<?php

class CustomForm14Logic extends BaseLogic {
	public function getDetailBasicBtn() {
		parent::getDetailBasicBtn();
		global $current_user,$adb;
		$version_info = getVersionInfo();
		//浩辰特殊开发  chj  20220530 合同生成 模块详情页面增加作废按钮
		if($version_info['account'] == 'haochen'){
			$btn['Haochen_VoidOrder']['label'] = getFixedLabel('Void');//作废
			$btn['Haochen_VoidOrder']['permit'] = 'yes';
			$btn['Haochen_VoidOrder']['icon'] = 'icon-return';
			if(!empty($this->controller->id)){
				global $adb;
				$query = 'select approvestatus from ld_customform14 where customform14id = ?';
				$result = $adb->pquery($query,array($this->controller->id));
				$approvestatus = $adb->query_result($result,0,0);
				if($approvestatus == '已批准'){
					$btn['Haochen_VoidOrder']['permit'] = 'no';
				}
			}
			$btn['Print']['label'] = getFixedLabel('PRINT');//作废
			$btn['Print']['permit'] = 'yes';
			$btn['Print']['icon'] = 'icon-set';
			$this->detail_buttons = f_array_insert($this->detail_buttons,$btn,-7);//页面设置按钮之前
			$this->detail_buttons['submit']['permit'] = 'no';
			$this->detail_buttons['cancel']['permit'] = 'no';
		}
	}
	public function getDetailMoreBtn() {
		parent::getDetailMoreBtn();//调用父类方法
        $version_info = getVersionInfo();
        //浩辰特殊开发  chj  20220530 合同生成页面的提交审批和批量提交按钮隐藏
        if($version_info['account'] == 'haochen'){
            $this->detail_buttons['More']['list']['Print']['permit'] = 'no';
        }
	}
	public function getListBasicBtn() {
		global $current_user;
		parent::getListBasicBtn();//调用父类方法
		$version_info = getVersionInfo();
		//浩辰特殊开发  chj  20220530 合同生成页面的提交审批和批量提交按钮隐藏
		if($version_info['account'] == 'haochen'){
			$this->list_buttons['submitapprove']['permit'] = 'no';
		}
	}

	public function getListMoreBtn() {
		global $current_user;
		parent::getListMoreBtn();//调用父类方法
		$version_info = getVersionInfo();
		//浩辰特殊开发  chj  20220530 合同生成页面的提交审批和批量提交按钮隐藏
		if($version_info['account'] == 'haochen'){
			$this->list_buttons['More']['list']['mass_edit']['permit'] = 'no';
		}
	}

}
?>