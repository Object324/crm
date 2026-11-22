<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class CustomForm27Logic extends BaseLogic {
	
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		/*
		*edit:chj
		*date:2020-07-15
		*reason:灵当CRM详细需求-费用报销单、佣金单、自定义表单21-25增加导入功能
		*/
		//unset($this->list_buttons['More']['list']['Import']);//删除导入按钮
	}
    
    public function getListViewButtons() {
        $versioninfo=getVersionInfo();
        if($versioninfo['account']=='langjie')
        {
            $this->list_buttons = Array();
    		$this->getListBasicBtn();//初始化模块基础按钮
            unset($this->list_buttons['More']);
            $this->list_buttons['LangJieLocalAssign']['label'] = "配送任务";
    		$this->list_buttons['LangJieLocalAssign']['permit'] = isPermitted('CustomForm28', 'Create', '');
    		$this->list_buttons['LangJieLocalAssign']['icon'] = 'icon-plus';
            $this->list_buttons['LangJieLocalAssign']['btnkey'] = 'LangJieLocalAssign';
            //更多按钮
    		$this->list_buttons['More']['label'] = getFixedLabel('MORE');
    		$this->list_buttons['More']['permit'] = 'yes';
    		$this->list_buttons['More']['icon'] = 'icon-more';
    		$this->getListMoreBtn();//初始化更多按钮关联下拉列表       
    		return $this->list_buttons;//返回列表按钮结果集
        }
        else
        {
            return parent::getListViewButtons();
        }
        
    }
}
?>