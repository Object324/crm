<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class DocumentsLogic extends BaseLogic {
    /**
	 * 调用公共更多下拉列表，并添加客户相关下拉列表
	 * @author Tujt 2015-06-25
	 */
	public function getListBasicBtn() {
		parent::getListBasicBtn();//调用父类方法
        unset($this->list_buttons['mass_edit']);//导入
        unset($this->list_buttons['Import']);//导入
		//$this->list_buttons['Allocate'];//分配
		//$this->list_buttons['Share'];//共享
		global $current_user;
		/*if(is_admin($current_user)){//必须是管理员
			$btn = array();
			//$btn['Move']['label'] = getFixedLabel('MOVE');//移动
			//$btn['Move']['permit'] = 'yes';
			//$btn['Move']['icon'] = 'icon-zhuanhuan';
			//$btn['Addfolder']['label'] = getFixedLabel('ADDFOLDER');//添加文件夹
			//$btn['Addfolder']['permit'] = 'yes';
			//$btn['Addfolder']['icon'] = 'icon-plus';
			//$this->list_buttons = f_array_insert($this->list_buttons,$btn,2);
		}*/
	}
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-06-25
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		unset($this->list_buttons['More']['list']['mass_edit']);//编辑
		unset($this->list_buttons['More']['list']['Import']);//导入
		$this->list_buttons['More']['list']['Export'];//导出
		$btn = array();
        global $current_user;
        
        if(is_admin($current_user)){
           // $btn['Addfolder']['label'] = getFixedLabel('ADDFOLDER');//添加文件夹
          //  $btn['Addfolder']['permit'] = 'yes';
            $btn['Addtemplate']['label'] = getFixedLabel('ADDTEMPLATE');//添加模板
            $btn['Addtemplate']['permit'] = 'yes';
            //$btn['Move']['label'] = getFixedLabel('MOVE');//移动
            //$btn['Move']['permit'] = 'yes';
        }
		//$btn['Viewemptyfolder']['label'] = getFixedLabel('VIEWEMPTYFOLDER');//查看空文件夹
		//$btn['Viewemptyfolder']['permit'] = 'yes';
		

		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn);
	}
    public function getallListViewLink() {
        $btn =array();
        $btn['download']['label'] = getFixedLabel('DOWNLOAD');
        $btn['preview']['label'] = getFixedLabel('PREVIEW');
        $btn = f_array_insert($btn,parent::getallListViewLink());
        return $btn;
    }
	/**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-26
	 */
	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
		unset($this->listview_link['preview']);
        unset($this->listview_link['download']);//28989: 知识管理查看明细界面： 允许查看或下载为否的单据，普通用户查看其它用户的知识管理明细界面，结果附件显示【Arry]】

        global $adb;
        $module = $this->controller->module_name;
        //edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
        $focus = CRMEntity::getInstance($module);
        $fieldInfo = $focus->fieldobj->getFieldInfoobjBykey('columnname','name');
        $fieldInfo->setFileAllowed($module,$record);
        $fileAllowed = $fieldInfo->getFileAllowed($record);

        // @edit:liushuai,2021-03-18,reason:0045028: （61mis.com/kfbcrm）角色权限增加“下载”“预览”权限功能；首页-知识管理，成员ASD，角色权限123，单据编号DOC38，没有知识管理的下载预览权限，但在操作栏处有对应功能按钮
        $fileId = $adb->query_result($result, $idx, 'attachmentsid');
        if ($fileId) {
            $query = 'select name from ld_attachments where attachmentsid = ? limit 1';
            $result = $adb->pquery($query, array($fileId));
            $filename = $adb->query_result($result, 0, 0);
        }
        if ($fileId > 0) {
            if (IsDownLoadProfile($record, "Documents") == 'yes' && $fileAllowed['Download'] === 'yes') {
                $btn = array();
                $btn['download']['label'] = getFixedLabel('DOWNLOAD');
                $btn['download']['permit'] = 'yes';
                $btn['download']['click'] = "DownLoadDocuments($fileId,$record)";
            }
            if (IsPreviewProfile($record, "Documents") == 'yes' && $fileAllowed['Preview'] === 'yes') {
                $btn['preview']['label'] = getFixedLabel('PREVIEW');
                $btn['preview']['permit'] = 'yes';
                $btn['preview']['click'] = 'open_Attachment(\'' . $record . '\',\'' . $fileId . '\',\'Documents\',\'' . $filename . '\')';
            }
            $this->listview_link = f_array_insert($this->listview_link, $btn, -1);
        }

	}
}
?>