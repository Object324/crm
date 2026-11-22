<?php
crm_load_class_file('cls_productDetailsData','modules/WorkSheet/ProductDetails');
class cls_MobileCommon_DetailsData extends cls_productDetailsData{
    
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
        $record_id = $frommdouleFocus->id;
        $detail_table = $frommdouleFocus->Detail_table;
        $detailscf_table = $frommdouleFocus->Detail_table_scf;
        $main_table = $frommdouleFocus->table_name;
        $tableindex = $frommdouleFocus->table_index;

        foreach($this->presenceToolField as $columnname => $value){
            if($columnname == 'productdetail_discount_amount'){
                $columnname = 'discount_amount';
            }
            if($columnname == 'entitytype' || $columnname == 'entitytypeid'){
                continue;
            }
            $fieldinfo = $frommdouleFocus->detailfieldobj->getFieldInfoobjBykey('columnname',$columnname);
            if($fieldinfo->getBigtype() == 'image' || $fieldinfo->getBigtype() == 'fileattachment'){
                continue;
            }
            if(!empty($fieldinfo)){
                $tablename = $fieldinfo->getTableName();
                $filed_sql[] =  $tablename.'.'.$columnname;
            }
        }
        if(isset($this->record)){
            $sql = 'select '.implode(',',$filed_sql).',ld_products.productid,ld_worksheetspecialdetail.repaired,
                ld_worksheetspecialdetail.entitytype,ld_worksheetspecialdetail.entitytypeid,ld_worksheetspecialdetail.parent_lineitem_id
                from '.$detail_table.' 
                INNER JOIN '.$main_table.' on '.$detail_table.'.id = '.$main_table.'.'.$tableindex.'
                INNER JOIN ld_products on '.$detail_table.'.productid = ld_products.productid 
                INNER JOIN ld_worksheetspecialdetail on '.$detail_table.'.lineitem_id = ld_worksheetspecialdetail.parent_lineitem_id
                INNER JOIN '.$detailscf_table.' on '.$detailscf_table.'.lineitem_id = ld_worksheetspecialdetail.parent_lineitem_id
                where ld_worksheetspecialdetail.worksheetid = '.$this->record.' and ld_worksheetspecialdetail.entitytype = "'.$this->module.'" 
                    and '.$main_table.'.deleted=0 and ld_products.deleted=0 ';
        }else{
            //新增时走这个sql
            $sql = 'SELECT DISTINCT '.implode(',',$filed_sql).',ld_products.productid,'.$detail_table.'.id as entitytypeid,"'.$this->module.'" as entitytype,
                    '.$detail_table.'.lineitem_id as parent_lineitem_id
                    from '.$detail_table.' 
                    INNER JOIN '.$main_table.' on '.$detail_table.'.id = '.$main_table.'.'.$tableindex.'
                    INNER JOIN ld_products on '.$detail_table.'.productid = ld_products.productid 
                    INNER JOIN '.$detailscf_table.' on '.$detailscf_table.'.lineitem_id = '.$detail_table.'.lineitem_id
                    where '.$detail_table.'.id IN ('.$record_id.') and '.$main_table.'.deleted=0 and ld_products.deleted=0 ';
        }
        return $sql;
    }
    
    public function getProductToolFieldValue($frommdouleFocus,$productdetail_mode){
        if($productdetail_mode == 'sourcemodule_create'){
            $columnname_value = parent::getProductToolFieldValue($frommdouleFocus,$productdetail_mode);
            return $columnname_value;
        }
        
        $query = $this->getProductToolFieldSql($frommdouleFocus);
        $result = $this->db->pquery($query,array());
        $num_rows = $this->db->num_rows($result);

        for($i=0;$i<$num_rows;$i++){
            $columnname_value[$i]['productid'] = $this->db->query_result($result,$i,'productid');
            $columnname_value[$i]['repaired'] = $this->db->query_result($result,$i,'repaired');
            $columnname_value[$i]['parent_lineitem_id'] = $this->db->query_result($result,$i,'parent_lineitem_id');
            foreach($this->presenceToolField as $columnname => $value){
                if($columnname == 'productdetail_discount_amount'){
                    $columnname = 'discount_amount';
                }
                $columnname_value[$i][$columnname] = $this->db->query_result($result,$i,$columnname);   
            }
        }
        return $columnname_value;
    }
}
?>