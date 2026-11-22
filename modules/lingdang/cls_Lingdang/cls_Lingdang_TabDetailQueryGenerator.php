<?php
crm_load_class_file('TabDetailQueryGenerator','include/QueryGenerator');
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
class cls_Lingdang_TabDetailQueryGenerator  extends TabDetailQueryGenerator{

    public function gettabshareSql()
    {
        
        return '';
    }
	public function getQuery($popup='',$type='1'){
        global $current_user;
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

	public function getLeftOrderBy($tableList){
		return '';
	}
    function getSelectColumn($tabid){

        if(!empty($this->columns)){
            return $this->columns;
        }
        $moduleFields = $this->fieldobj->getModuleFields();//lingdangcrmobjectmeta.php
        $accessibleFieldList = array_keys($moduleFields);//获取当前用户能够看见的字段
        $accessibleFieldList[]='id';

        $selectSql =trim($this->TabDetails->getSelectColumn($tabid),',');
        $basetable = $this->moduleobj->table_name;
        $selectSql = strtr($selectSql,array('ld_crmentity.'=>$basetable.'.'));
        $productFields=$this->TabDetails->getModuleFields();
        $columnlist=array_filter(explode(',',$selectSql));
        $finalcolumnlist=array();
        if($basetable=='ld_cashbill'||$basetable=='ld_sendcashbill')
            $finalcolumnlist[]="$basetable.entitytype";
        foreach ($this->customViewColumnList as $tmp_key => $customViewColumnInfo)
        {
            $coltables=explode(':',$customViewColumnInfo);

            if($coltables[0] == $this->moduleTableDetail || $coltables[0] == $this->moduleTableDetailscf
                ||in_array($coltables[0],$this->product_obj->tab_name)){
                $field=$productFields[$coltables[1]];

                if($field&&$field->getFieldType()=='Amount'&&$productFields['currency_id'])
                {
                    $fieldcurrencyobj=$productFields['currency_id'];
                    $this->ModuleTableDetailColumn[$fieldcurrencyobj->getTableName()]=$fieldcurrencyobj->getTableName();

                    $finalcolumnlist[]=$fieldcurrencyobj->getTableName().'.currency_id as tabdetail_currency_id';//防止主表和明细存在相同的字段
                }
                if($field&&$field->getFieldType()=='SourceAmount'&&($productFields['source_total']||$productFields['pay_amount']||$productFields['received_amount']))
                {
                    $finalcolumnlist[]=$this->moduleobj->Detail_table.'.currency_id as tabdetail_currency_id';//防止主表和明细存在相同的字段
                }
                if($field&&($field->getBigType()=='image' || $field->getBigType()=='fileattachment')){
                    //ls 2022-06-13 【ID1002721】单据分录定制，增加“图片”字段类型(非产品模块列表页,列表页明细只显示一个图片字段时)
                }else{
                    $finalcolumnlist[]=$coltables[0].'.'.$coltables[1] . ' as tabdetail_'.$coltables[1];//防止主表和明细存在相同的字段
                }

                $this->ModuleTableDetailColumn[$coltables[0]]=$coltables[0];
                $this->DetailTableColumn[$coltables[0]]=$coltables[0];
                $this->selecttables[$coltables[0]]=$coltables[0];

                continue;
            }
            $fieldinfo=$this->moduleobj->fieldobj->getFieldInfoobjBykey("columnname",$coltables[1]);
            if($fieldinfo&&$fieldinfo->getUIType()==1109)
            {
                continue;
            }
            $tmp_column = $coltables[0].'.'.$coltables[1];
            $tmp_sql_column = $tmp_column;
            if($tmp_key == 'countfield'){
                if($fieldinfo && ($fieldinfo->istotalFldMoneyField() || $fieldinfo->isPriceField())){
                    if(!empty($moduleFields['currency_id']))
                    {
                        $fields = $moduleFields['currency_id'];
                        $tmp_sql_column = "IF(".$fields->getTableName().".currency_id > 1,$tmp_column/".$fields->getTableName().".conversion_rate,$tmp_column) as ".$coltables[1];
                    }
                }
            }

            $finalcolumnlist[]=$tmp_sql_column;

            $this->MainTableColumn[$coltables[0]]=$coltables[0];
            $this->selecttables[$coltables[0]]=$coltables[0];
        }


        $finalcolumnlist=array_unique($finalcolumnlist);
        $this->columns=implode(',',$finalcolumnlist);
        $baseTable = $this->moduleobj->table_name;
        $baseTableIndex = $this->moduleobj->table_index;
        $this->columns.=', '.$baseTable.'.'.$baseTableIndex;
        if(in_array($this->moduleTableDetail,$this->ModuleTableDetailColumn) || in_array($this->moduleTableDetailscf,$this->ModuleTableDetailColumn)){
            $this->columns.=', '.$this->moduleobj->Detail_table.'.'.$this->moduleobj->Detail_table_id;
        }
        //判断非产品明细模块是否包含币种,如果包含，则添加币种字段
        if(!empty($moduleFields['currency_id']))
        {
            $fields = $moduleFields['currency_id'];
            if(empty($this->fields['currency_id']) && strpos($this->columns,$fields->getTableName().'currency_id') <= -1){
                $this->columns .= ',' . $fields->getTableName() . '.currency_id';
            }
            if(empty($this->fields['currency_id']) && strpos($this->columns,'conversion_rate') <= -1){
                $this->columns .= ',' . $fields->getTableName() . '.conversion_rate';
            }
            $this->columns .= ',' . $fields->getTableName() . '.currency_symbol';
        }

        return $this->columns;
    }
}

?>