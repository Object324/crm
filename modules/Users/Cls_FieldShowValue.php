<?php

class Cls_FieldShowValue{
    
    protected $listviewFieldValueobj;
    protected $showfieldvalueobj;
    
    public $list_showtype = SHOW_LISTVIEW;
    public $module;
    public $fieldname;
    public $record;
    public $fieldobj;
    public $fieldvalue;
    public $focus;
    public $showvalue;
    public $listfieldvalue;
    
    public function __construct($module,$record,$fieldname){
        global $reset_retrieve_entity_info;
        
        $this->module = $module;
        $this->record = $record;
        $this->fieldname = $fieldname;
        
        $focus=CRMEntity::getInstance($module);
        $focus->id = $record;
        $focus->mode = 'edit';
        //获取$focus最新的columnfield
        $reset_retrieve_entity_info = 'yes';
        $focus->retrieve_entity_info($record,$module);
        $reset_retrieve_entity_info='no';
        $fieldobj = $focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
        
        $this->fieldvalue = $focus->column_fields[$fieldname];
        
        $this->fieldobj = $fieldobj;
        $this->focus = $focus;
        
        $this->setshowfieldValueObj($module);
        $this->setListFieldValueObj($module);
    }
    public function resetfieldname($fieldname)
    {
        $fieldobj = $this->focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
        $this->fieldobj = $fieldobj;
        $this->fieldname = $fieldname;
        $this->fieldvalue = $this->focus->column_fields[$fieldname];
    }
    
    public function setshowfieldValueObj($module)
    {
        $focus = CRMEntity::getInstance($module);
        $showfieldvalueobj = new ShowFieldValue($focus->fieldobj, $module, $this->list_showtype);
        $showfieldvalueobj->setownerNameList(array());//不知道干嘛用的先设为空
        $this->showfieldvalueobj = $showfieldvalueobj;
    }
    public function setshowfieldlist_showtype($list_showtype)
    {
        $this->showfieldvalueobj->show_type = $list_showtype;
    }
    
    public function setListFieldValueObj($module)
    {
        global $current_user;
        $focus = CRMEntity::getInstance($module);
        
        $customView = CustomView::getInstance($module);
        $queryGenerator =QueryGenerator::getInstance($module, $current_user,$customView);
        crm_load_class_file('ListViewfieldValue', 'include/ListView');
        $this->listviewFieldValueobj = new ListViewfieldValue($focus, $module, $queryGenerator);

    }
    
    public function getFieldValue()
    {
        if(empty($this->fieldvalue))
        {
            $this->fieldvalue = $this->focus->column_fields[$this->fieldname];
        }
        return $this->fieldvalue;
    }
    
    public function getShowfieldValue()
    {
        $showfieldvalueobj = $this->showfieldvalueobj;
        
        $showfieldvalueobj->setRecorId($this->record);
        
        $focus = $this->focus;
        $fieldobj = $this->fieldobj;
        
        $fieldvalue = $this->getFieldValue();
        $value = $fieldvalue;
        $rawValue = $value;

        $this->showvalue = $showfieldvalueobj->getFieldValueByField($fieldobj, $rawValue, $value);
        
        return $this->showvalue;
    }
    
    
    public function getListFieldValue()
    {
        global $adb;
        
        $listviewFieldValueobj = $this->listviewFieldValueobj;
        $listviewFieldValueobj->setRecorId($this->record);
        
        $showfieldvalueobj = $this->showfieldvalueobj;
        $showfieldvalueobj->setRecorId($this->record);
        
        $haveresult = false;
        $focus = $this->focus;
        $tablename = $focus->table_name;
        $tableindex = $focus->table_index;
        $fieldobj = $this->fieldobj;
        if($fieldobj->getUIType() == 25 && !($fieldobj instanceof ProductFields))
        {
            $haveresult = true;
            $sql = "select activityid from ld_activity where $tableindex = ?";
            $result = $adb->pquery($sql,array($focus->id));
        }
        else if($this->fieldname == $listviewFieldValueobj->queryGenerator->moduleobj->list_link_field && $listviewFieldValueobj->module != 'Emails'&& $listviewFieldValueobj->module != 'Users')
        {
            //zkt 20220720  BUG0054032客户问题（税友），成员管理单据列表界面，“姓名”小编辑保存时，弹窗没有关闭（但已保存成功）（kfbcrm也存在这个问题）
            $approve_system_deploys=getSys_Approvedeploy($this->module);
            if($approve_system_deploys['deploy_value']===0||$approve_system_deploys['deploy_value']==='0'){
                $haveresult = true;
                $sql = "select approveexpediting,approveurgent from $tablename where $tableindex = ?";
                $result = $adb->pquery($sql,array($focus->id));
            }
        }
        if($fieldobj->getBigType() == 'picklist' )
        {
            //zkt 20220530 052330成员管理，单据列表界面，使用小编辑，编辑“职位级别”字段保存时，小编辑弹窗没有关闭
            crm_load_class_file('cls_PickList', 'modules/PickList');
            $cls_picklistobj = cls_PickList::getInstance($this->fieldname,$fieldobj);
            //为了获取颜色
            $tmppicklistinfo = $cls_picklistobj->getPickListValues($this->fieldname,$fieldobj);
            
        }
        
        if($haveresult){
            $listviewFieldValueobj->setResult($result);
            $listviewFieldValueobj->setResultRow(0);
        }
        
        $fieldvalue = $this->getFieldValue();
        $value = $fieldvalue;
        $rawValue = $value;

        $listfieldvalue = $listviewFieldValueobj->getListViewFieldValue($fieldobj, $showfieldvalueobj, $rawValue, $value);
        $this->listfieldvalue = $listfieldvalue;

        return $listfieldvalue;
    }
}
?>