<?php
crm_load_class_file('Parent_ProductDetailsData','include/ProductDetailsHtml');
class cls_Common_DetailsData extends Parent_ProductDetailsData{
    public $record;
    public $worksheet_sourcevalue_arr;

    public function __construct($module){
        parent::__construct($module);
        $Detail_table=$this->focus->Detail_table;
        $this->inventoryFields ['repaired'] = $Detail_table.'.repaired';
        $this->worksheet_sourcevalue_arr = [];
    }

    public function getProductToolFieldSql($frommdouleFocus){
        if($this->productdetail_mode == 'sourcemodule_create'){
            $sql = parent::getProductToolFieldSql($frommdouleFocus);

            return $sql;
        }
        $filed_sqlarr = array();
        $record = $this->record;
        $detail_table = $frommdouleFocus->Detail_table;
        $detailscf_table = $detail_table.'scf';
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
            if(!empty($fieldinfo)){
                if($fieldinfo->getSaveDataBase() != 'yes'){
                    continue;
                }
                $tablename = $fieldinfo->getTableName();
                $filed_sql[] =  $tablename.'.'.$columnname;
            }
        }

        $sql = 'select '.implode(',',$filed_sql).',ld_products.productid,ld_worksheetspecialdetail.repaired,
            ld_worksheetspecialdetail.entitytype,ld_worksheetspecialdetail.entitytypeid,ld_worksheetspecialdetail.parent_lineitem_id
            from '.$detail_table.' 
            INNER JOIN '.$main_table.' on '.$detail_table.'.id = '.$main_table.'.'.$tableindex.'
            INNER JOIN ld_products on '.$detail_table.'.productid = ld_products.productid 
            INNER JOIN ld_productcf on ld_products.productid = ld_productcf.productid
            INNER JOIN ld_worksheetspecialdetail on '.$detail_table.'.lineitem_id = ld_worksheetspecialdetail.parent_lineitem_id
            INNER JOIN '.$detailscf_table.' on '.$detailscf_table.'.lineitem_id = ld_worksheetspecialdetail.parent_lineitem_id
            where ld_worksheetspecialdetail.worksheetid = '.$this->record.' and ld_worksheetspecialdetail.entitytype = "'.$this->module.'" 
                and '.$main_table.'.deleted=0 and ld_products.deleted=0 ';

        return $sql;
    }
    
    public function getProductToolFieldValue($frommdouleFocus,$productdetail_mode){
     
        $columnname_value = [];
        if($productdetail_mode == 'sourcemodule_create'){
           
            $columnname_value = parent::getProductToolFieldValue($frommdouleFocus,$productdetail_mode);
             
            foreach($columnname_value as $i=>$valueinfo)
            {
                $this->worksheet_sourcevalue_arr[$i]['lineitem_id'] = $valueinfo['lineitem_id'];
                
                $this->worksheet_sourcevalue_arr[$i]['entitytype'] =$frommdouleFocus->module_name;
                $this->worksheet_sourcevalue_arr[$i]['entitytypeid'] =$frommdouleFocus->id;
            }
           return $columnname_value;
        }
        
        if($this->record > 0){
            $query = $this->getProductToolFieldSql($frommdouleFocus);
            $result = $this->db->pquery($query,array());
            $num_rows = $this->db->num_rows($result);
    
            for($i=0;$i<$num_rows;$i++){
                $columnname_value[$i]['productid'] = $this->db->query_result($result,$i,'productid');
                $columnname_value[$i]['repaired'] = $this->db->query_result($result,$i,'repaired');
                $columnname_value[$i]['parent_lineitem_id'] = $this->db->query_result($result,$i,'parent_lineitem_id');
                $this->worksheet_sourcevalue_arr[$i]['lineitem_id'] = $this->db->query_result($result,$i,'parent_lineitem_id');
                $this->worksheet_sourcevalue_arr[$i]['entitytype'] = $this->db->query_result($result,$i,'entitytype');
                $this->worksheet_sourcevalue_arr[$i]['entitytypeid'] = $this->db->query_result($result,$i,'entitytypeid');
                foreach($this->presenceToolField as $columnname => $value){
                    if($columnname == 'productdetail_discount_amount'){
                        $columnname = 'discount_amount';
                    }
                    $columnname_value[$i][$columnname] = $this->db->query_result($result,$i,$columnname);   
                }
            }
        }

        return $columnname_value;
    }
}
?>