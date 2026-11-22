<?php
 crm_load_class_file('clsTotal_List','include/ListView');
class cls_servicecharge_totalList extends clsTotal_List
{
    public function __construct($listviewcontroller)
    {
        parent::__construct($listviewcontroller);
        $this->listviewcontroller->prefix_detail_colum='';
        
        
    }
     /**
     * 获取合计行查询字段
     * */
    public function getTotalFld_columns()
    {
           
        	
            $main_table_name=$this->queryGenerator->moduleobj->table_name;
            $listviewfields=$this->listviewcontroller->getListViewFields($this->queryGenerator->module);
            
            $moduleFields=$this->listviewcontroller->getModuleFields();
            $productmodulefields=$this->listviewcontroller->getProductModuleFields($this->queryGenerator->module);
            $focusmodule=$this->listviewcontroller->getListViewEntries_FocusModule($this->queryGenerator->module);
            $listpropertymodule=$this->queryGenerator->getPropertyFields();
            $page_list_query=$this->queryGenerator->getQuery("","1");
            $main_sql_column='';
            $detail_sql_column='';
     
            
			//判断模块是否存在币种字段
            foreach($listviewfields as $key=>$fieldname)
            {
                
                    $columnname=$this->listviewcontroller->getColumnName($key,$fieldname);
                    $fieldobj=$this->listviewcontroller->getListViewFieldobj($key,$fieldname);
                    if($fieldobj=='-1')
                        continue;
                    if(!$fieldobj->isFldNumOrMoney()||$fieldobj->isPriceField())
                    {
                        continue;
                    }
                   	$tablename = $fieldobj->getTableName();
                    $columnname=$fieldobj->getColumnName();
                    
					if($listpropertymodule[$key]==$focusmodule){
					  
	                
	                
	                    if($fieldobj->istotalFldNumField())
                        {
                            $main_sql_column .= 'sum(IFNULL('.$tablename.".".$columnname.',0)) as '.$columnname.',';
                        }
                        else if($fieldobj->istotalFldMoneyField())
                        {
                            
                            if($moduleFields['currency_id'])
                            {
                                $main_sql_column .= "sum(IF (currency_id > 1,IFNULL($tablename.$columnname,0) / ifnull($main_table_name.conversion_rate,1),IFNULL($tablename.$columnname,0	))	)  as ".$columnname.',';
                            }
                            
                            else
                            {
                                $main_sql_column .= "sum(IFNULL($tablename.$columnname,0))  as ".$columnname.',';
                            }
                        }
        							
                	}
                    else
                    {
                          $prefix_detail_column=$this->listviewcontroller->prefix_detail_colum;
                            if($fieldobj->istotalFldNumField())
                            {
                                    $detail_sql_column .= '(IFNULL('.$tablename.".".$columnname.',0)) as  '.$prefix_detail_column.$columnname.',';
                            }
                            else if($fieldobj->istotalFldMoneyField())
                            {
                                 
                                      $fieldcurrencyobj=$productmodulefields['currency_id'];
                                      $currencytablename=$fieldcurrencyobj->getTableName();
                                     
                                      $detail_sql_column .= " (IF (ld_servicecontracts.currency_id > 1,IFNULL(	$tablename.$columnname,0) / ifnull(ld_servicecontracts.conversion_rate,1),IFNULL($tablename.$columnname,0	))	)  as $prefix_detail_column".$columnname.',';
                                
                            } 
                            
                            $tmp_detail_column.=  'sum(IFNULL('." ld_servicecontracts.".$columnname.',0)) as  '.$prefix_detail_column.$columnname.',';            
                    }
 			  }
              
          if($main_sql_column!='')
                $main_sql_column.="'a'";
          if($detail_sql_column!='')
		      $detail_sql_column.="'a'";
         if($tmp_detail_column!='')
		      $tmp_detail_column.="'a'";
          $columns['main_columns']=$main_sql_column;
          $columns['detail_columns']=$detail_sql_column;
          $columns['tmp_contracts_columns']=$tmp_detail_column;
          return $columns;
    }
    public function getall_totalFldSql()
      {
            $sql_columns=$this->getTotalFld_columns();
            if($sql_columns=='')
            {
                return '';
            }
            $main_sql_column=$sql_columns['main_columns'];
            $detail_sql_column=$sql_columns['detail_columns'];
            $tmp_detail_sql_column=$sql_columns['tmp_contracts_columns'];
           
      
            $custom_tablename=$this->queryGenerator->moduleobj->customFieldTable[0];
            $custom_table_index=$this->queryGenerator->moduleobj->customFieldTable[1];
            $main_table_name=$this->queryGenerator->moduleobj->table_name;
            $main_table_index=$this->queryGenerator->moduleobj->table_index;
           // $main_sql_column.=" $main_table_name.$main_table_index";
    		$allfld = trim($allfld,',');
         
    		
                    $left_jion.=' from '.$this->queryGenerator->moduleobj->table_name;
                   if(sizeof($this->queryGenerator->moduleobj->customFieldTable)>1)//InventoryAccount：没有自定义表
                        $left_jion.= ' left join  '.$this->queryGenerator->moduleobj->customFieldTable[0]." on  ".$this->queryGenerator->moduleobj->customFieldTable[0].".".$this->queryGenerator->moduleobj->customFieldTable[1].
                                                " = ".$this->queryGenerator->moduleobj->table_name.".".$this->queryGenerator->moduleobj->table_index;
                    
                
                $page_list_query=$this->getallTotal_pageList_query();
               //全部查询sql
               if($main_sql_column!='')
                    $sql['main_sql'] = 'SELECT  '.$main_sql_column.$left_jion .' inner join ( '.$page_list_query.')  as tmp on tmp.'.$this->queryGenerator->moduleobj->table_index.'='.$this->queryGenerator->moduleobj->table_name.'.'.$this->queryGenerator->moduleobj->table_index;
               else
                    $sql['main_sql']='';
               if($detail_sql_column!='')
                    $sql['detail_sql'] = 'select '.$tmp_detail_sql_column.' from ( SELECT ld_servicecontracts.servicecontractsid, '.$detail_sql_column.$this->queryGenerator->getFromClause() .' inner join ( '.$page_list_query.')  as tmp on tmp.'.$this->queryGenerator->moduleobj->table_index.'='.
                     $this->queryGenerator->moduleobj->table_name.'.'.$this->queryGenerator->moduleobj->table_index.$this->queryGenerator->getWhereClause() .' GROUP BY ld_account.accountid,ld_servicecontractsdetail.productid ) as ld_servicecontracts   ';
               else
                    $sql['detail_sql']='';
             
              
          
               return $sql;
      }
      
    /*
      * 获取本页查询的sql
     * 
     * */
    public function getTotalCurPage_Sql($page_list_query)
    {
           $sql_columns=$this->getTotalFld_columns();
  
          
            
        
           if($sql_columns['main_columns']==''&&$sql_columns['detail_columns']=='')
           {
                return '';
           }
          $cur_page_main_sql='';
          $cur_page_detail_sql='';
        
            //当前页查询sql
            if($sql_columns['main_columns']!='')
            {
                $cur_page_main_sql=  'SELECT  '.$sql_columns['main_columns'].' from '.$this->queryGenerator->moduleobj->table_name;
                if(sizeof($this->queryGenerator->moduleobj->customFieldTable)>1)//InventoryAccount：没有自定义表
                    $cur_page_main_sql.= ' left join  '.$this->queryGenerator->moduleobj->customFieldTable[0]." on  ".$this->queryGenerator->moduleobj->customFieldTable[0].".".$this->queryGenerator->moduleobj->customFieldTable[1].
                                            " = ".$this->queryGenerator->moduleobj->table_name.".".$this->queryGenerator->moduleobj->table_index;
                
               $cur_page_main_sql.= ' inner join ( '.$page_list_query.')  as tmp on tmp.'.
                $this->queryGenerator->moduleobj->table_index.'='.$this->queryGenerator->moduleobj->table_name.'.'
                .$this->queryGenerator->moduleobj->table_index;
              
              
               
            }
           if($sql_columns['detail_columns']!='')
           {
                //edit:can 56347 售后客户模块，历史交易金额、年维标准金额、成交金额这三个字段显示的本页合计不对，查看了一下，本页合计这个取的是这个客户  按照客户名称查询
                 $cur_page_detail_sql=  ' select '. $sql_columns['tmp_contracts_columns'] .' from (SELECT DISTINCT  ld_servicecontracts.servicecontractsid,'.$sql_columns['detail_columns'].$this->queryGenerator->getFromClause() .
                ' inner join ( '.$page_list_query.')  as tmp on tmp.'.
                $this->queryGenerator->moduleobj->table_index.'='.$this->queryGenerator->moduleobj->table_name.'.'
                .$this->queryGenerator->moduleobj->table_index.$this->queryGenerator->getWhereClause();
               if($this->queryGenerator->with_serviceinfo == 'yes'){
                   $cur_page_detail_sql .= ' and (ifnull(ld_servicecontracts.servicecontractsid,0)=0 or ld_servicecontracts.servicecontractsid = serviceinfo.servicecontractsid) ';
               }

               $cur_page_detail_sql.=' GROUP BY	ld_account.accountid,
	ld_servicecontractsdetail.productid ) as ld_servicecontracts
                 ';
               
           }
           $sql['main_sql']=$cur_page_main_sql;
           
           $sql['detail_sql']=$cur_page_detail_sql;
         
        
           return $sql;
        
    }
    
}
?>