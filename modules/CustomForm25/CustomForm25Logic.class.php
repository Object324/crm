<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class CustomForm25Logic extends BaseLogic {
	
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		/*
		*edit:chj
		*date:2020-07-15
		*reason:灵当CRM详细需求-费用报销单、佣金单、自定义表单21-25增加导入功能
		*/
		//unset($this->list_buttons['More']['list']['Import']);//删除导入按钮
	}
	
	 public function getDetailBasicBtn() {
        parent::getDetailBasicBtn();//调用父类方法
        //ls 20230301  XUQIU1001143【百特】不良事件报告模块生成pdf和xml文件
        global $awscosconfig;
        require_once(globalStatic::$root_directory."config.inc.php");
        if (!empty($awscosconfig['region']) && !empty($awscosconfig['bucket'])) {
            $VersionInfo = getVersionInfo();
            if($VersionInfo['account']=='baxter')
            {
                $btn['baxterCreatePdfAndXml']['label'] = 'Print Adverse Event';
                $btn['baxterCreatePdfAndXml']['permit'] = 'yes';
                $this->detail_buttons = f_array_insert($this->detail_buttons,$btn,0);
            }
        }

    }
}
?>