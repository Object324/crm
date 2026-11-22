<?php
class UnifiedSearch_CustomView extends CustomView
{
   
	 public $selectColumnlist;
     public  function __construct($module='')
     {
       
        parent::__construct($module);
        
     }

      public function getOrderWhere($page_list_query,$setype='',$queryGenerator='')
      {
        return $this->getModuleSortOrder($page_list_query);
        
      }
     public function getModuleSortOrder($page_list_query,$setype='',$queryGenerator='')
     {
        $focus=CRMEntity::getInstance($this->customviewmodule);
        $table_name=$focus->table_name;
        $table_index=$focus->table_index;
        if($_REQUEST['order_by']||$_SESSION[$this->customviewmodule.'_quicksearch_orderby']!='')
        {
            if($_REQUEST['order_by'])
            {
                $orderby=$_REQUEST['order_by'];
                $sorder=$_REQUEST['sorder'];
                $_SESSION[$this->customviewmodule.'_quicksearch_orderby']=$orderby;
                $_SESSION[$this->customviewmodule.'_quicksearch_orderbytype']=$sorder;
            }
            else
            {
                $orderby=$_SESSION[$this->customviewmodule.'_quicksearch_orderby'];
                $sorder=$_SESSION[$this->customviewmodule.'_quicksearch_orderbytype'];
            }
          
            
            return array($page_list_query.' order by '.$orderby.' '.$sorder.','.$table_name.'.'.$table_index,$orderby,$sorder);
            
        }
        else
        {
           
            $customsortorder = $this->getCustomViewOrderBy($this->cvid);
            //duan 20240109 全局搜索，如果模块的排序的字段是用户字段，则无法查出数据
            if(!empty($this->orderby_tables)){
                $focus->orderby_tables = $this->orderby_tables;
            }

            $tab_idx=$focus->table_name.'.'.$focus->table_index;
            return array($page_list_query.' order by '.$customsortorder.$table_name.'.'.$table_index,$customsortorder.' '.$tab_idx,' ');
            
        }
     }
     /**
      * 重写父类方法(排序)
      * 
    public function getCustomViewOrderBy($viewid)
    {
        $maintable_name=$this->focus->table_name;
        return $maintable_name.'.'.$this->focus->table_index.' desc';	
    }*/
    /**
     * 重写父类获取列头
     *
    public function getColumnsListByCvid($viewid)
    {
        if(!empty($this->selectColumnlist))
        {
            return $this->selectColumnlist;
        }
           global $adb,$current_user;
        require('user_privileges/user_language_'.$current_user->id.'.php');

        $SqlField = "select tablename,fieldname,ld_tranlabel.fieldlabel,columnname
                 from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
              inner join ld_relatedlists_lable  on ld_relatedlists_lable.fieldid=ld_field.fieldid
             where languagetype=? and trantable=? and ld_tranlabel.tabid=?  and ld_relatedlists_lable.presence=1  
                order by ld_relatedlists_lable.sequence";

        $result = $adb->pquery($SqlField,array($languageType,'ld_field',getTabid($this->customviewmodule)));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $column_list[]=$adb->query_result($result,$i,'tablename').":".$adb->query_result($result,$i,'columnname').":".$adb->query_result($result,$i,'fieldname').":".$this->customviewmodule."_fieldlabel";
            

        }
        $this->selectColumnlist=$column_list;
        return $column_list;
    } **/
    /**
     * 重写父类基本查询方法
     * */
	function getStdFilterByCvid() {
	  return array();
	}
    /**
     * 重写父类高级查询方法
     * */
     public function  getAdvFilterByCvid($cvid) {
         return array();
        }
    
   
    
   
    
}

?>