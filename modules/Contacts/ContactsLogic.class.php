<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class ContactsLogic extends BaseLogic {
    /**
	 * 调用公共更多下拉列表，并添加客户相关下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();//调用父类方法
		$module = self::$module;$is_email = 'no';$is_sms = 'no';
		$more_idx = 0;$btn = array();
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

        //editor:gyq_72 reason:查重合并样式修改 date:20180705
        $dup_and_merge_permit = 'no';
        if('yes' == isPermitted($module, 'dup_and_merge','')){
            $dup_and_merge_permit = 'yes';$more_idx = 1;
        }
		$btn = array();
		$btn['Findduplicates']['label'] = getFixedLabel('CHECKMERGE');
		$btn['Findduplicates']['permit'] = $dup_and_merge_permit;
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,6);
        //Eidtor:gyq_65 Reason:原查重合并改为合并 Date:2018/3/28 0028 上午 9:28
        $merge_permit = 'no';
		if('yes' == isPermitted($module, 'Merge','')){
            $merge_permit = 'yes';$more_idx = 1;
		}
		$btn = array();
		$btn['RecordMerge']['label'] = getFixedLabel('Merge');
		$btn['RecordMerge']['permit'] = $merge_permit;
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,6);

		//判断更多按钮是否显示
		if('no' == $this->list_buttons['More']['permit'] && 1 == $more_idx){
			$this->list_buttons['More']['permit'] = 'yes';
		}
	}
    public function getallListViewLink() {
        $btn =array();
        if(vtlib_isModuleActive('ContactRecords')){
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
		$btn['followup']['click'] = 'CreateContactRecordsByAccounts(this,\''.$related_left_record.'\',\'%d\',\'Contacts\',\'index\')';
		$this->listview_link = f_array_insert($this->listview_link,$btn,-1);
        if(!vtlib_isModuleActive('ContactRecords')){
            unset($this->listview_link['followup']);
        }
	}
}
?>