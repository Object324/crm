<?php


class cls_LangjieModuleDetails
{
    public function __construct($record, $select_module)
    {
        $this->record = $record;
        $this->select_module = $select_module;
    }

    //获取数据
    public function getOrderDetails()
    {
        global $adb;
        $select_focus = CRMEntity::getInstance($this->select_module);
        $query = 'select GROUP_CONCAT('.$select_focus->Detail_table_id.') as id from '.$select_focus->Detail_table.' 
        LEFT JOIN '.$select_focus->table_name.' ON '.$select_focus->table_name.'.'.$select_focus->table_index.' = '.$select_focus->Detail_table.'.'.$select_focus->Detail_table_index.' where id = ? and deleted = 0';
        $result = $adb->pquery($query,array($this->record));

        $select_record_arr = explode(',',$adb->query_result($result,0,0));
        $dataArr =array();
        if(!empty($select_record_arr)){
            crm_load_class_file("TabDetailFieldsData",'include/TabDetailFields');
            $select_focus->id = $this->record;
            $select_focus->mode = 'edit';
            $tabDetailFieldsData = new TabDetailFieldsData($select_focus,$this->select_module);
            $dataArr = $tabDetailFieldsData->getTabDetailHtmlContentData();
        }
        return $dataArr;
    }
}

?>