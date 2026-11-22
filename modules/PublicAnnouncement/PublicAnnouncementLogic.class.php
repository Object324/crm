<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class PublicAnnouncementLogic extends BaseLogic {
	/**
	 * 初始化模块基础按钮
	 * @author Tujt 2015-06-01
	 */
	public function getListBasicBtn() {
		parent::getListBasicBtn();
        //unset($this->list_buttons['Settings']);
       
		
	}
    
    public function getListViewButtons()
    {
        parent::getListViewButtons();//初始化更多按钮关联下拉列表;
         foreach($this->list_buttons['More']['list'] as $key=>$ps)
        {
         
            if(strtolower($key)=='changecreator' || strtolower($key)=='resetlistwidth'||strtolower($key)=='approvalsettings')
            {
               
            }
            else
            {
                unset($this->list_buttons['More']['list'][$key]);
            }
        }
        //zkt 20240129 BUG20240126-38 kfbcrm-公告-列表操作按钮设置处显示“导入”，但是模块右上角不显示
        unset($this->list_buttons['Import']['permit']);
        return $this->list_buttons;//wym BUG0073445 listviewrightsetting.php 42行 需要返回值


    }
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-05
	 */
	public function getDetailMoreBtn() {
		parent::getDetailMoreBtn();//调用父类方法
		unset($this->detail_buttons['More']['list']['Share']);
	}

	public function getDetailBasicBtn() {
	    parent::getDetailBasicBtn();//调用父类方法
		//unset($this->detail_buttons['Settings']);//添加页面设置按钮
	}
}
?>