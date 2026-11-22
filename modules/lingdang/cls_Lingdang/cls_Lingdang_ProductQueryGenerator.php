<?php
crm_load_class_file('ProductQueryGenerator','include/QueryGenerator');
class cls_Lingdang_ProductQueryGenerator  extends ProductQueryGenerator{

    public function __construct($module, $user,$customerview='',$productDetailsobj='') {
        $this->db = PearDatabase::getInstance();
        parent::__construct($module, $user,$customerview);
        $this->ownerFields['promodifiedby']='promodifiedby';
        $this->ownerFields['procreator']='procreator';
        $this->ownerFields['assigned_user_id']='assigned_user_id';

        $this->ld_inventoryproductrel=$this->moduleobj->Detail_table;
        $this->ld_scfinventoryproduct=$this->moduleobj->Detail_table_scf;

        if(!empty($productDetailsobj))
        {
            $this->productDetails=$productDetailsobj;
        }
        else
        {
            crm_load_class_file("ProductDetails",'include/ProductDetails');
            $this->productDetails=ProductDetails::getInstance($module);
        }

        $this->productDetails->querygenerator=$this;
        $this->product_field_obj=Field::getInstance('Products',$this->db);
        $this->product_obj=CRMEntity::getInstance('Products');

    }
    public function gettabshareSql()
    {
        
        return '';
    }
	public function getQuery($popup='',$type='1'){
		$select_columns=$this->getSelectColumn(getTabid($this->module));
		$baseTable=$this->moduleobj->table_name;
		$focus=$this->moduleobj;
		$where=$this->getWhereClause();
        $fromclause=$this->getFromClause();
		if($type==1)
		{
			$sql =' SELECT distinct  '.$baseTable.'.'.$focus->table_index.$fromclause;

            $sql.= $where;

            return $sql;
		}
		else if($type==2)
		{
			 $sql= ' SELECT '.$select_columns.', '.$baseTable.'.'.$focus->table_index.' as crmid '. $fromclause;
            $sql.= $where;
            return $sql;
		}
	}
    public function setFieldSql($conditionInfo){
        return   parent::setFieldSql($conditionInfo);
    }
	public function getLeftOrderBy($tableList){
		return '';
	}
    //29241: 系统右下方的审批通知提醒，设为已读后，点击【审批中心】，进入单据列表界面显示没有找到任何记录。
     public  function isStockQuery($module)
     {
        return '';
     }


    function getSelectColumn($tabid)
    {

        $ld_inventoryproductrel=$this->ld_inventoryproductrel;
        $Detail_table_id=$this->moduleobj->Detail_table_id;//明细表主键
        $Detail_table_scf=$this->moduleobj->Detail_table_scf;//明细自定义表
        $Detail_table_index=$this->moduleobj->Detail_table_index;//明细表和主表关联字段

        $mobile_column_bol='no';
        if(!empty($this->columns))
        {
            return $this->columns;
        }

        $moduleFields = $this->getModuleFieldList();//lingdangcrmobjectmeta.php
        $accessibleFieldList = array_keys($moduleFields);//获取当前用户能够看见的字段
        $accessibleFieldList[]='id';

        $selectSql =trim($this->productDetails->getSelectColumn($tabid),',');

        $basetable = $this->moduleobj->table_name;
        $selectSql = strtr($selectSql,array('ld_crmentity.'=>$basetable.'.'));

        $columnlist=array_filter(explode(',',$selectSql));

        $finalcolumnlist=array();
        //排序设置 选择负责人考到到sql语句中没有join ld_user
        //$this->MainTableColumn[] = 'ld_users';
        foreach ($this->customViewColumnList as $tmp_key => $customViewColumnInfo)
        {
            $coltables=explode(':',$customViewColumnInfo);
            $tmp_column = $coltables[0].'.'.$coltables[1];
            if($coltables[0]=='ld_attachments')
                continue;
            if(isProductTable($coltables[0],$this->moduleobj->module_name))
            {

                if(in_array($coltables[0],$this->product_obj->tab_name))
                {
                    $productcolumn=$coltables[1];
                    $this->product_detail_columns[]=$productcolumn;
                }
                $fieldinfo=$this->moduleobj->detailfieldobj->getFieldInfoobjBykey("columnname",$coltables[1]);
                $this->inventory_columns[]=$coltables[1];
                $this->ProductTableColumn[$coltables[0]]=$coltables[0];
                $this->DetailTableColumn[$coltables[0]]=$coltables[0];
            }else{
                $fieldinfo=$this->moduleobj->fieldobj->getFieldInfoobjBykey("columnname",$coltables[1]);
            }

            if($fieldinfo&&$fieldinfo->getUIType()==1109)
            {
                continue;
            }
            $tmp_sql_column = $tmp_column;
            //统计字段需要判断是否除以币种
            if($tmp_key == 'countfield'){
                if($fieldinfo && ($fieldinfo->istotalFldMoneyField() || $fieldinfo->isPriceField())){
                    if(!empty($moduleFields['currency_id']))
                    {
                        $fields = $moduleFields['currency_id'];
                        $tmp_sql_column = "IF(".$fields->getTableName().".currency_id > 1,$tmp_column/".$fields->getTableName().".conversion_rate,$tmp_column) as ".$coltables[1];
                    }
                }
            }
            $finalcolumnlist[]= $tmp_sql_column;
            $this->MainTableColumn[$coltables[0]]=$coltables[0];
            $this->main_columns[]=$coltables[1];
        }

        //判断选择字段中是否存在产品关联字段
        if(count($this->ProductTableColumn) >= 1)
        {
            $this->ProductTableColumn[$this->ld_inventoryproductrel]=$this->ld_inventoryproductrel;
            $this->DetailTableColumn[$this->ld_inventoryproductrel]=$this->ld_inventoryproductrel;
        }

        $this->columns=implode(',',$finalcolumnlist);
        $focus = $this->moduleobj;

        $baseTable = $focus->table_name;
        $baseTableIndex = $focus->table_index;
        //判断列头是否存在产品字段，如果有，则显示产品明细ID

        if(sizeof($this->ProductTableColumn)>=1 )
            $this->columns.= ','.$ld_inventoryproductrel.'.productid,ifnull('.$ld_inventoryproductrel.'.'.$Detail_table_id.',0) as lineitem_id';

        return $this->columns;
    }

}

?>