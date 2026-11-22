<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class DividendOrderLogic extends BaseLogic {
	/**
	 * 去掉创建按钮 添加如何创建派息单按钮
	 * @author Tujt 2015-06-01
	 */
	public function getListBasicBtn() {
	    parent::getListBasicBtn();
		unset($this->list_buttons['Create']);
		$btn['howTodevidend']['label'] = getFixedLabel('How_to_create_devidend');
		$btn['howTodevidend']['permit'] = 'yes';
		$btn['howTodevidend']['icon'] = 'icon-ask';
        $btn['howTodevidend']['btnkey'] = 'howTodevidend';
		$this->list_buttons = f_array_insert($this->list_buttons,$btn);
	}
    /**
	 * 调用公共更多下拉列表，并添加相关下拉列表
	 * @author Tujt 2015-06-01
	 */
	public function getListMoreBtn() {
		global $current_user;
		parent::getListMoreBtn();//调用父类方法
		$module = self::$module;$more_idx = 0;$is_devidend='no';$is_sendmail='no';
		//删除导入按钮
		unset($this->list_buttons['More']['list']['Import']);
		//批量派息按钮
		if('yes' == isPermitted('DividendOrder', 'Devidend', '') && vtlib_isModuleActive('DividendOrder')){
			$is_devidend = 'yes';$more_idx = 1;
		}
		$btn['s_dividend']['label'] = getFixedLabel('BATCHDIVIDEND');
		$btn['s_dividend']['permit'] = $is_devidend;
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,1);
		//短信设置按钮
		$SMSarray = GetSMSAutograph();
		$smsName = $SMSarray['account_name'];
		//判断短信账户是否设置 并且 只有管理员才可以设置
		if(!empty($smsName) && $current_user->is_admin == 'on'){
			$is_sendmail = 'yes';$more_idx = 1;
		}
		$btn['sms_settings']['label'] = getFixedLabel('SMS') . getFixedLabel('SETTINGS');
		$btn['sms_settings']['permit'] = $is_sendmail;
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,count($this->list_buttons['More']['list']));
		//判断更多按钮是否显示
		if('no' == $this->list_buttons['More']['permit'] && 1 == $more_idx){
			$this->list_buttons['More']['permit'] = 'yes';
		}
	}
    public function getallListViewLink() {
        $btn =array();
        $btn['notsent']['label'] =  getFixedLabel('DIVIDENDBTN').'/'.getFixedLabel('ANTIDIVIDENDBTN');
        $btn = f_array_insert($btn,parent::getallListViewLink());
        return $btn;
    }
	/**
	 * 初始化列表按钮结果集
	 * @author Chj 2015-06-29
	 */
	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
		$module = self::$module;
		if(!empty($record)){
			$focus = CRMEntity::getInstance($module);
			$focus->retrieve_entity_info($record,$module);
			if($focus->column_fields['status'] == DIVIDEND_STATUS_NO){
				$fixedlabel = getFixedLabel('DIVIDENDBTN');
				$sendtype = 0;
				$actionname = 'Devidend';//派息
			}else{
				$fixedlabel = getFixedLabel('ANTIDIVIDENDBTN');
				$sendtype = 1;
				$actionname = 'AbtiDevidend';//反派息
			}
			$this->listview_link['notsent'] = array(
				'label' => 	$fixedlabel,
				'permit' => isPermitted($module, $actionname, $record),
				'click' => 'massDividends(this,\'listview\','.$record.','.$sendtype.')',
				'type' => 'redirect',
				'result'=>array(
					'module'=>$module,
					'action'=>'ListView',
					'record'=>$record,
				),
				'related'=>0,
			);
		}
	}
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-04
	 */
	public function getDetailBasicBtn() {
	    parent::getDetailBasicBtn();
		unset($this->detail_buttons['Create']);
		$module = self::$module;
		if(!empty($this->controller->id)){
			$record =  $this->controller->id;
			$focus = CRMEntity::getInstance($module);
			$focus->retrieve_entity_info($record,$module);
			if($focus->column_fields['status'] == DIVIDEND_STATUS_NO){
				$btn['devidend_btn'] = array(
					'label' => getFixedLabel('DIVIDENDBTN'),
					'permit' => isPermitted($module, 'Devidend', $record),
					'icon' => 'icon-plus',
				);
			}else{
				$btn['abtidevidend_btn'] = array(
					'label' => getFixedLabel('ANTIDIVIDENDBTN'),
					'permit' => isPermitted($module, 'AbtiDevidend', $record),
					'icon' => 'icon-plus',
				);
			}
		}
		$this->detail_buttons = f_array_insert($this->detail_buttons,$btn,2);
	}
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-04
	 */
	public function getDetailMoreBtn() {
	    parent::getDetailMoreBtn();
		//复制
		unset($this->detail_buttons['More']['list']['Copy']);
	}
	/**
	 * 获取对应的关联创建
	 * @author Tujt 2015-06-25
	 */
	public function getActionUserd() {
		parent::getActionUserd();
		return $this->quickactionLink;
	}
}
?>