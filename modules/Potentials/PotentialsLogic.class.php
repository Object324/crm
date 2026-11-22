<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class PotentialsLogic extends BaseLogic {
    /**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListBasicBtn() {
	   global $current_user;
		parent::getListBasicBtn();//调用父类方法
        $tmp_list_buttons=array();
        foreach($this->list_buttons as $btnname=>$content)
        {
            $tmp_list_buttons[$btnname]=$content;
            if($btnname=='Delete')
            {
         	    $tmp_list_buttons['Datadupcheck']['label'] = getFixedLabel('ACCOUNTDUPLICATECHECK');
		        $tmp_list_buttons['Datadupcheck']['permit'] = isPermitted('Potentials','accountdatadup');
 	            $tmp_list_buttons['Datadupcheck']['icon'] = 'icon-search';
                $tmp_list_buttons['Datadupcheck']['btnkey'] = 'Datadupcheck';
            }
			if($btnname=='Allocate')
            {
				$sys26=getSys_deploy(26);
				if($sys26['deploy_value'] == 'part'){
                	$tmp_list_buttons['Allocate']['btnkey'] = 'seniorAllocate';
				}
            }
        }
        $this->list_buttons=$tmp_list_buttons;

        /*
   	    $this->list_buttons['Datadupcheck']['label'] = getFixedLabel('POTENTIALSDUPLICATECHECK');
		$this->list_buttons['Datadupcheck']['permit'] = isPermitted('Potentials','potentialsdatadup');
	    $this->list_buttons['Datadupcheck']['icon'] = 'icon-search';
        $this->list_buttons['Datadupcheck']['btnkey'] = 'Datadupcheck';
        */
	}
    
    public function getListMoreBtn() {
		parent::getListMoreBtn();
        //中孚 商机列表增加“收入确认计划”按钮，
        $version_info = getVersionInfo();
        if($version_info['trade']=="zhongfu"){
            $this->list_buttons['More']['list']['Revenueplan']['permit']=isPermitted('CustomForm48','Create');
            $this->list_buttons['More']['list']['Revenueplan']['label']=getTranstab('CustomForm48');
        }
		// 是否需要同步共享相关信息
		$btnkeys = array_keys($this->list_buttons['More']['list']);
		if(in_array('Share',$btnkeys)){
			$sys26=getSys_deploy(26);
			if($sys26['deploy_value'] == 'part'){
				$this->list_buttons['More']['list']['Share']['btnkey'] = 'seniorShare';
			}
		}
       
	}
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-04
	 */
	public function getDetailBasicBtn() {
	    parent::getDetailBasicBtn();
		/*$btn = array();
        $fieldobj=$this->controller->fieldobj;
        $field=$fieldobj->getFieldInfoobjBykey('columnname','sales_stage');
        if($field)
        {
            $btn['Advance']['label'] = getFixedLabel('ADVANCE');
    		$btn['Advance']['permit'] = isPermitted(self::$module,'Advance');
    		$btn['Advance']['icon'] = 'icon-check';
        }
		
		$this->detail_buttons = f_array_insert($this->detail_buttons,$btn,4);*/
		$btnkeys = array_keys($this->detail_buttons);
		if(in_array('Allocate',$btnkeys) || in_array('Share',$btnkeys)){
			foreach ($btnkeys as $index => &$btnkey) {
				$sys26=getSys_deploy(26);
				if($sys26['deploy_value'] == 'part'){
					if($btnkey=='Allocate'){
						$btnkey = 'seniorAllocate';
					}
					if($btnkey=='Share'){
						$btnkey = 'seniorShare';
					}
				}
			}
			$this->detail_buttons = array_combine($btnkeys,$this->detail_buttons);
		}

	}
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-04
	 */
	public function getDetailMoreBtn() {
		parent::getDetailMoreBtn();
		/*zxm20221201 刘总说去掉
		$btn = array();
		$btn['createPaymentid']['label'] = getFixedLabel('Createreceivablesforecast');
		$btn['createPaymentid']['permit'] = 'yes';
		$this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn,0);*/
		$btnkeys = array_keys($this->detail_buttons['More']['list']);
		if(in_array('Share',$btnkeys)){
			foreach ($btnkeys as $index => &$btnkey) {
				$sys26=getSys_deploy(26);
				if($sys26['deploy_value'] == 'part'){
					if($btnkey=='Share'){
						$btnkey = 'seniorShare';
						break;
					}
				}
			}
			$this->detail_buttons['More']['list'] = array_combine($btnkeys,$this->detail_buttons['More']['list']);
		}
	}
    public function getallListViewLink() {
        $btn =parent::getallListViewLink();
        if(vtlib_isModuleActive('ContactRecords')){
            $btn['followup']['label'] = getFixedLabel('FOLLOWUP');//跟进
        }
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
		$btn['followup']['click'] = 'CreateContactRecordsByAccounts(this,\''.$related_left_record.'\',\'%d\',\'Potentials\',\'index\')';
		$this->listview_link = f_array_insert($this->listview_link,$btn,-1);
        if(!vtlib_isModuleActive('ContactRecords')){
            unset($this->listview_link['followup']);
        }
	}
}
?>