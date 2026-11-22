<?php
crm_load_class_file('cls_productDetailsData','modules/WorkSheet/ProductDetails');
class cls_SalesOrder_DetailsData extends cls_productDetailsData{
    
    public function __construct($module){
        parent::__construct($module);
        $this->product_columnname_arr = array('productname','product_no','productsheet','entitytype','entitytypeid');
        $Detail_table=$this->focus->Detail_table;
        $this->inventoryFields ['repaired'] = $Detail_table.'.repaired';
    }
    
    public function getProductToolFieldSql($frommdouleFocus){
        if($this->productdetail_mode == 'sourcemodule_create'){
            $sql = parent::getProductToolFieldSql($frommdouleFocus);
            return $sql;
        }
        
        $filed_sqlarr = array();
        $record = $this->record;
        $detail_table = $frommdouleFocus->Detail_table;
        $main_table = $frommdouleFocus->table_name;
        $tableindex = $frommdouleFocus->table_index;
        foreach($this->product_columnname_arr as $columnname){
            $fieldinfo = $frommdouleFocus->detailfieldobj->getFieldInfoobjBykey('columnname',$columnname);
            if(!empty($fieldinfo)){
                $tablename = $fieldinfo->getTableName();
                $filed_sql[] =  $tablename.'.'.$columnname;
            }
        }
        $sql = 'select '.implode(',',$filed_sql).',ld_products.productid,ld_worksheetspecialdetail.repaired,
            ld_worksheetspecialdetail.entitytype,ld_worksheetspecialdetail.entitytypeid,ld_worksheetspecialdetail.parent_lineitem_id
            from '.$detail_table.' 
            INNER JOIN '.$main_table.' on '.$detail_table.'.id = '.$main_table.'.'.$tableindex.'
            INNER JOIN ld_products on '.$detail_table.'.productid = ld_products.productid 
            INNER JOIN ld_worksheetspecialdetail on '.$detail_table.'.lineitem_id = ld_worksheetspecialdetail.parent_lineitem_id
            where ld_worksheetspecialdetail.worksheetid = ? and ld_worksheetspecialdetail.entitytype = ? 
                and '.$main_table.'.deleted=0 and ld_products.deleted=0 ';

        return $sql;
    }
    
    public function getProductToolFieldValue($frommdouleFocus,$productdetail_mode){
        if($productdetail_mode == 'sourcemodule_create'){
            $columnname_value = parent::getProductToolFieldValue($frommdouleFocus,$productdetail_mode);
            return $columnname_value;
        }
        
        $query = $this->getProductToolFieldSql($frommdouleFocus);
        $result = $this->db->pquery($query,array($this->record,$this->module));
        $num_rows = $this->db->num_rows($result);

        for($i=0;$i<$num_rows;$i++){
            $columnname_value[$i]['productid'] = $this->db->query_result($result,$i,'productid');
            $columnname_value[$i]['repaired'] = $this->db->query_result($result,$i,'repaired');
            $columnname_value[$i]['parent_lineitem_id'] = $this->db->query_result($result,$i,'parent_lineitem_id');
            foreach($this->product_columnname_arr as $columnname){
                $columnname_value[$i][$columnname] = $this->db->query_result($result,$i,$columnname);   
            }
        }

        return $columnname_value;
    }
}
?>