<?php
/**
 * 收款单选择原单合同界面
 * */
crm_load_class_file('TabDetails','include/TabDetailFields');

class cls_Approve_TabDetails extends TabDetails 
{
	public $productFields;

	function setModuleFields()
     {
		global $approvestatus,$adb;
        
        
		parent::setModuleFields();
        $focus=CRMEntity::getInstance($this->customviewmodule);
        $tablename=$focus->table_name;

		crm_load_class_file('Approve_Field','modules/Approve/ListView');
		$approvefield = new Approve_Field($this->customviewmodule,$adb);
		$approve_modulefields = $approvefield->getApproveColumnsObj($approvestatus,'tabdetailsfield');
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
		$viewid=$_REQUEST['viewid'];

		if(empty($viewid)){
			$customView = new CustomView($this->customviewmodule);
			$viewid = $customView->getViewId($this->customviewmodule,$this->popup);
		}
        
        $sSQL=$this->getCustomViewSql();
        $result=$adb->pquery($sSQL,array($viewid));
        if($adb->num_rows($result)<=0){
              $result = $adb->pquery($sSQL, array(0));
        }
        $focus=CRMEntity::getInstance($this->customviewmodule);
		$columnlist=$this->setHeaderColumnInfo($result);
//        @edit:liushuai @date:2020-07-13 @reason: 1000895：审批中心查询优化：（费用报销单等）
        $module_name = $this->customviewmodule;
        $table_name = $focus->table_name;
        $fields_property=[];
        $approve_list_fields=[];
        $listViewHeaderSearch=[];

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

		$this->HeaderColumns = array_merge($HeaderColumns,$this->HeaderColumns);

        if(is_array($this->fields_property))
		    $this->fields_property = array_merge($fields_property,$this->fields_property);
        else{

            $this->fields_property =$fields_property;
        }
        if(is_array($this->listViewHeaderSearch))
		    $this->listViewHeaderSearch = array_merge($listViewHeaderSearch,$this->listViewHeaderSearch);
        else
            $this->listViewHeaderSearch=$listViewHeaderSearch;
        if(is_array($this->list_fields))
		    $this->list_fields = array_merge($approve_list_fields,$this->list_fields);
        else
            $this->list_fields=$approve_list_fields;

		$columns = array_merge($approve_columnlist,$columnlist);
        return implode(',', $columns);
    }

	function getSpecialTableName(){
		return 'tmp_approve';
	}

	//处理明细数据  合同列
	function getListViewEntries($list,$pagetype){
	   if($_REQUEST['approvestatus']!='1')
       {
        $this->haveoperationbtn='no';
       }
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