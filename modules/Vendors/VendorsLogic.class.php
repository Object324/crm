<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class VendorsLogic extends BaseLogic {
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-06-01
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		//editor:gyq_20180824	0035049: （1.6登录）供应商和供应商联系人序时簿列表界面：更多中应不显示“自动查重合并”按钮
		/*$btn = array();$module = self::$module;
		$btn['Findduplicates']['label'] = getFixedLabel('Merge');
		$btn['Findduplicates']['permit'] = isPermitted($module,'Merge','');
		$setting = $this->list_buttons['More']['list']['Settings'];
		$btn['Settings'] = $setting;
		$count = count($this->list_buttons['More']['list']);
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,$count-1);*/
        $module = self::$module;
        //批量回填
        $backfill_permit = 'no';
        crm_load_class_file('cls_BusinessInformation', 'modules/Users');
        $businessinformationobj = cls_BusinessInformation::getInstance($module);
        if($businessinformationobj->IsEnableBatchbackfill() && isPermitted($module, 'BatchBackFilling','')=='yes'){
            $backfill_permit = 'yes';
        }
        $btn = array();
        $btn['BatchBackFilling']['label'] = getFixedLabel('BatchBackFilling');
        $btn['BatchBackFilling']['permit'] = $backfill_permit;
        $count = count($this->list_buttons['More']['list']);
        $this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,$count-1);
        //泰康开发，供应商增加'重算经纬度'功能
        $recalculation_latandlong = 'no';
		if('yes' == isPermitted($module, 'EditView','')){
			$recalculation_latandlong = 'yes';$more_idx = 1;
		}
        $btn = array();
		$btn['Recalculation_latandlong']['label'] = getFixedLabel('Recalculatethelatitudeandlongitude');
		$btn['Recalculation_latandlong']['permit'] = $recalculation_latandlong;
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,5);
        //合并
        $merge_permit = 'no';
        if('yes' == isPermitted($module, 'Merge','')){
            $merge_permit = 'yes';$more_idx = 1;
        }
        $btn = array();
        $btn['RecordMerge']['label'] = getFixedLabel('Merge');
        $btn['RecordMerge']['permit'] = $merge_permit;
        $this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,6);
        //自动查重合并
        $dup_and_merge_permit = 'no';
        if('yes' == isPermitted($module, 'dup_and_merge','')){
            $dup_and_merge_permit = 'yes';$more_idx = 1;
        }
        $btn = array();
        $btn['Findduplicates']['label'] = getFixedLabel('CHECKMERGE');
        $btn['Findduplicates']['permit'] = $dup_and_merge_permit;
        $this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,7);
	}
	/**
	 * 获取对应的关联创建
	 * @author Tujt 2015-06-25
	 */
	public function getActionUserd() {
		parent::getActionUserd();
		foreach($this->quickactionLink as $key=>&$quick){
			if($key > 0){
				$tag = '&vendor_id='.$this->controller->id.'&fromid='.$this->controller->id.'';
				$quick['tag'] = $tag;
			}
		}
		return $this->quickactionLink;
	}
    /**
     * editor:ljj
     * time:20231220
     * reason:XUQIU1002130
     * content:销售线索增加查重、合并和自动查重合并功能（戚涛）
     * node:设置获取列表界面基础按钮，增加查重按钮
     */
    public function getListBasicBtn() {
        global $current_user;
        parent::getListBasicBtn();//调用父类方法
        $module = self::$module;$btn = array();
        $allocateBtn=array();
        //分配
        $allocateBtn['distribution']['label'] = getFixedLabel('ALLOCATE');
        $allocateBtn['distribution']['permit'] = 'yes';
        $allocateBtn['distribution']['btnkey'] = 'distribution';
        $regobj=RegOp::getInstance();
        if($regobj->GetVersionNo()==58)
        {
            $allocateBtn="";
        }
        else
        {
            //平均分配
            $allocateBtn['leadsaverageDistribution']['label'] = getFixedLabel('AVERAGEDISTRIBUTION');
            $allocateBtn['leadsaverageDistribution']['permit'] = 'yes';
            $allocateBtn['leadsaverageDistribution']['btnkey'] = 'averageDistribution';
        }
        $this->list_buttons['Allocate']['list'] = $allocateBtn;
        $tmp_list_buttons=array();
        foreach($this->list_buttons as $btnname=>$content)
        {
            $tmp_list_buttons[$btnname]=$content;
            if($btnname=='Delete')
            {
                //查重
                $tmp_list_buttons['Datadupcheck']['label'] = getFixedLabel('ACCOUNTDUPLICATECHECK');
                $tmp_list_buttons['Datadupcheck']['permit'] = isPermitted($module,'accountdatadup');
                $tmp_list_buttons['Datadupcheck']['icon'] = 'icon-search';
                $tmp_list_buttons['Datadupcheck']['btnkey'] = 'Datadupcheck';
            }
        }

        $this->list_buttons=$tmp_list_buttons;

    }
}
?>