<?php
/**
 * 收款单选择原单合同界面
 * */
crm_load_class_file('ProductDetails','include/ProductDetails');

class cls_Approve_Productdetail extends ProductDetails
{
	public $productFields;

	function setModuleFields()
     {
		global $approvestatus,$adb;
		parent::setModuleFields();

        $productdetails_columns=ProductDetails::getInstance($this->customviewmodule,$this->languagetran);
        $tablename=$this->focus->table_name;
       
		if(!empty($productdetails_columns)){
			foreach($productdetails_columns->modulefields as $columnname => $field){
				$productfield=new ProductFields();
				$productfield->setFieldName($columnname);
				$productfield->setcolumnName($columnname);
				$productfield->setTableName($field->getTableName());
				$productfield->setuitType($field->getUIType());
				$productfield->setPresence($field->getPresence());
                if($this->customviewmodule!='Attachment'&&$this->customviewmodule!='Documents')
                {
                    //edit:can 2022-02-28 44771: （61mis.com/kfbcrm）审批中心-待处理-附件管理；从审批中心进入待处理的附件管理审批单据，界面报错，详情请看附件图
                         $productfield->setinput_type($field->getinput_type());
                         $productfield->setTranslatedModule($field->getTranslatedModule());
                }
                else{
                    $productfield->setinput_type(1);
                    $productfield->setTranslatedModule(getTransTab($this->customviewmodule));
                }
				$productfield->settypeOfData($field->gettypeOfData());
				$productfield->setfieldLabel($field->getfieldLabel());
			
				$this->modulefields[$columnname]=$field;
			}
		}

		crm_load_class_file('Approve_Field','modules/Approve/ListView');
		$approvefield = new Approve_Field($this->customviewmodule,$adb);
		$approve_modulefields = $approvefield->getApproveColumnsObj($approvestatus,'productfield');
		$this->modulefields = array_merge($this->modulefields,$approve_modulefields);

    }

    public function getSelectColumn($tabid)
    {

        global $adb,$approvestatus;
          if(!empty($this->HeaderColumns)){
              //zxm 20230830 这个方法返回值应该是个字符串
              return implode(',', $this->HeaderColumns);;
             return $this->HeaderColumns;;
        }
        $viewid=parent::getviewid();
        $sSQL=$this->getCustomViewSql();
        $result=$adb->pquery($sSQL,array($viewid));
        if($adb->num_rows($result)<=0){
              $result = $adb->pquery($sSQL, array(0));
        }
        $focus=CRMEntity::getInstance($this->customviewmodule);
        $module_name = $this->customviewmodule;

        $columnlist=$this->setHeaderColumnInfo($result);

//        @edit:liushuai @date:2020-07-13 @reason: 审批中心查询优化：发起人（提交人）、发起时间（提交时间）、审批步骤（当前审批步骤）， 放在单据表里面（审批中心列头）
        $table_name = $focus->table_name;

        if(vtlib_isModuleActive('Approve'))
        {
			crm_load_class_file('Approve_Field','modules/Approve/ListView');
			$allapprovecolumns = Approve_Field::getAllApproveColumnsInfo($approvestatus);
			$approvecolumns = Approve_Field::getApproveColumns($approvestatus);
			foreach ($approvecolumns as $index => $approvecolumn) {
				$fields_property[] = $module_name;
                $listViewHeaderSearch[$table_name.':'.$approvecolumn.':'.$approvecolumn.':'.$module_name.'_:'.$allapprovecolumns[$approvecolumn]['type']] = $allapprovecolumns[$approvecolumn]['label'];
                $HeaderColumns[sizeof( $this->HeaderColumns)+1] = $table_name.'.'.$approvecolumn;
                $approve_list_fields[] = $approvecolumn;
                $approve_columnlist[] = $table_name.'.'.$approvecolumn;
			}
			
		}

        if(!is_array($this->HeaderColumns))$this->HeaderColumns = [];
        if(!is_array($this->fields_property))$this->fields_property = [];
        if(!is_array($this->listViewHeaderSearch))$this->listViewHeaderSearch = [];
        if(!is_array($this->list_fields))$this->list_fields = [];

		$this->HeaderColumns = array_merge($HeaderColumns,$this->HeaderColumns);
		$this->fields_property = array_merge($fields_property,$this->fields_property);
		$this->listViewHeaderSearch = array_merge($listViewHeaderSearch,$this->listViewHeaderSearch);
		$this->list_fields = array_merge($approve_list_fields,$this->list_fields);
		$columns = array_merge($approve_columnlist,$columnlist);
        return implode(',', $columns);
    }

	function getSpecialTableName(){
		return 'tmp_approve';
	}

	//处理明细数据  合同列
	function getListViewEntries($list,$pagetype){
		$list = parent::getListViewEntries($list,1);
		return $list;
	}

	//去除基本查询中的审批列
	function getBasicSearchFieldInfoList(){
		$ListViewHeaderSearch = $this->getListViewHeaderSearch();
		if(!empty($ListViewHeaderSearch)){
			foreach($ListViewHeaderSearch as $columns => $label){
				$column_arr = explode(':',$columns);
				if($column_arr[0] != 'tmp_approve'){
					$basicSearchField[$columns] = $label;
				}
			}
		}
		return $basicSearchField;
	}


}
?>