<?php
crm_load_class_file('TabDetailListViewController','include/ListView');
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
class cls_Approve_TabDetailListViewController extends TabDetailListViewController {
    
    
    public function __construct($adb, $user, $generator,$module)
    {
        parent::__construct($adb, $user, $generator,$module);
        
         crm_load_class_file('Approve_Field','modules/Approve/ListView');
        $meta_fieldobj= new Approve_Field($module,$adb);
        $this->modulefields=$meta_fieldobj->getModuleFields();
        
    }
        /**
         * 字段排序是否按照列头点击排序
         * */
        public function HeaderFieldSortIsBy_request($orderBy,$focus,$field)
        {
            //28402: 审批中心：列表表格【发起时间】列列头增加点击排序功能
                if($orderBy=='tmp_approve.approveby_datetime'&&$field->getColumnName()=='approveby_datetime')
                {
                    return 'yes';
                }
                else
                return parent::HeaderFieldSortIsBy_request($orderBy,$focus,$field);
        }
        /**
     * 列头字段是否可以排序
     * yes:可以排序
     * */
      public function HeaderFieldIsSorted($focus,$module,$fieldinfo,$fieldmoduleskey)
      {
        //28402: 审批中心：列表表格【发起时间】列列头增加点击排序功能
         if($fieldinfo->getColumnName()=='approveby_datetime')
         {
            return 'yes';
         }
         else
            return parent::HeaderFieldIsSorted($focus,$module,$fieldinfo,$fieldmoduleskey);
           
      }
	 public function setListFieldValueObj($focus,$module)
     {
        global $approvestatus;
        crm_load_class_file('ListViewfieldValue','include/ListView');
        $this->listviewFieldValue = new ListViewfieldValue($focus,$module,$this->queryGenerator);
        
        $this->listviewFieldValue->add_url_get_value='&result_aprove='.($approvestatus+1);
        
     }
      public function setshowfieldValueObj($module)
      {
            $arr=parent::setshowfieldValueObj($module);
            $showfieldvalueobj=new ShowFieldValue($this->queryGenerator->moduleobj->fieldobj,$module,SHOW_LISTVIEW);
            $showfieldvalueobj->setownerNameList($this->ownerNameList);
            $arr['approveby_user']=$showfieldvalueobj;
            
            return $arr;
                  
      }
       /**
          * 获取字段所在的模块
          * */
         public function getPropertyModule($key,$fieldinfo)
         {
            if($fieldinfo->getFieldName()=='approveby_user')
            {
                return $this->queryGenerator->moduleobj->module_name;
            }
            $propertyListModule=$this->queryGenerator->getPropertyFields();
            $propertyModule=$propertyListModule[$key];
            return $propertyModule;
         }
	//重写获取模块内容
	function getListViewEntries($focus, $module,$result,$navigationInfo,$skipActions=false,$MoreAction=false,$export='') {
		global $approvestatus,$current_user;
		$data = parent::getListViewEntries($focus, $module,$result,$navigationInfo,$skipActions,$MoreAction,$export);
          
		$approve_focus = Approve::getInstance($module);
		if(!empty($approvestatus) && $approvestatus == 1){
			foreach($data as $record => $listinfo){
				$records = explode(',',$record);
				$blockbuttons = $approve_focus->blocksButton('',$records[0]);
				$field['approveby'] = $focus->column_fields['approveby'];
                //duan 20220923 BUG0056815：审批中心已处理不显示反审批按钮
                $field['approvestatus'] = $focus->column_fields['approvestatus'];
                
				$iscancel = $approve_focus->getCancelApprovedBtn($module,$records[0],$field,$blockbuttons);
				$list_btn[0] = '';
				if($iscancel == 1){
					$list_btn[0] = '<a class="Anu3_a" href="javascript:unApprove_click('.$records[0].',\''.$_REQUEST['fromapprovemodule'].'\',this);" title="'.getFixedLabel('APPROVE_ANTIAPPROVAL').'">'.getFixedLabel('APPROVE_ANTIAPPROVAL').'</a>';
				}
				$list[$record] = array_merge($listinfo,$list_btn);
			}
		}else{
			$list = $data;
		} 
       
		$this->queryGenerator->TabDetails->querygenerator=$this->queryGenerator;
		$list = $this->queryGenerator->TabDetails->getListViewEntries($list,1);    
		return $list;
	}

	//重写 列表一对多格式设置
	public function setListViewProductDetails($module,$data){
		return $data;
	}

	//重写操作列方法
	public function getListViewOperating($module){
			  //已处理，有操作列按钮
      global $approvestatus;
	   if($approvestatus==1)
       {
        return  parent::getListViewOperating($module);
       }
       else
		return array();
	}
	
	//重写获取基本查询列  去除固定列
	public function getBasicSearchFieldInfoList() {
		$basicSearchFieldInfoList = parent::getBasicSearchFieldInfoList();
		$fields = $this->queryGenerator->getFields();
		$meta = $this->queryGenerator->getMeta($this->queryGenerator->getModule());
		$moduleFields = $meta->getModuleFields();
		$accessibleFieldList = array_keys($moduleFields);
		$listViewFields = array_intersect($fields, $accessibleFieldList);
		foreach ($listViewFields as $fieldName) {
			$field = $moduleFields[$fieldName];
			if($field->getTableName() == 'tmp_approve'){
				unset($basicSearchFieldInfoList[$fieldName]);
			}
		}
		return $basicSearchFieldInfoList;
	}

	//重写获取操作列按钮方法
	public function getListViewBtn($focus,$module,$result,$recordId,$start,$i){
		return '';
	}

	public function getSpecialModule(){
		return 'tmp_approve';
	}

	//重写列头排序模块设置
	public function getListViewHeaderByModule($module){
		return 'Approve';
	}
}

?>