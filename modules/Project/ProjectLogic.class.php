<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class ProjectLogic extends BaseLogic {
    /**
	 * 调用公共更多下拉列表，并添加客户相关下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
	   global $current_user;
		parent::getListMoreBtn();//调用父类方法
		$module = self::$module;
        $tmp_more_list_buttons=array();
        
        $version=getVersionInfo();
       
        if($version['account']=='小白熊')
        {
            
            foreach($this->list_buttons['More']['list'] as $btname=>$content)
            {
                if($btnname=='Export'&&!array_key_exists('ProjectXbxImport',$tmp_more_list_buttons))
                {
                    $tmp_more_list_buttons['ProjectXbxImport']['label']='导入售后处理登记表和客户';
                    $tmp_more_list_buttons['ProjectXbxImport']['permit']='yes';
                }
                $tmp_more_list_buttons[$btname]=$content;
                if($btname=='Import')
                {
                    
                    $tmp_more_list_buttons['ProjectXbxImport']['label']='导入售后处理登记表和客户';
                    $tmp_more_list_buttons['ProjectXbxImport']['permit']='yes';
                }
               
                
            }
    		$this->list_buttons['More']['list']=$tmp_more_list_buttons;
              
        }
	}

	
}
?>