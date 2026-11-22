<?php

  crm_load_class_file("TabDetails",'include/TabDetailFields');
class ReportTabDetailView extends TabDetails
{
   
    
   
   
    
    /**
	* edit:can
	* reason:获取基本查找下拉框
	* */
	function getListViewBasicSearch(){ 
	
	}
    

	function getListViewHeaderSearch(){ 
	
	}
    
    public function getListViewHeaderInfo()
    {
        
    }
   
    
  
    public function getCustomViewSql()
    {
   
     
        $tabid=getTabid($this->customviewmodule);
       
          if(get_file_address($this->customviewmodule,'ContactsDetails')== true || get_file_address($this->customviewmodule,'VendorsDetails')){
            $sSQL = "select columnname as columns,columnindex as sequence from ld_cvcolumnlist where cvid = ? order by columnindex asc";   
        }
        else{
            $sSQL = "select sequence,`columns` from ld_tabwithproductview where tabid = $tabid and cvid = ? order by sequence asc";
        }
       
        
        return $sSQL;
    }
    public function getviewid()
    {
        
    }
    /**
	 *
	 * @param String:ModuleName $module
	 * @return EntityMeta
	 */
     function getSelectColumn($tabid){
        
     }
     
     public function  setHeaderColumnInfo($result)
     {
        
     }
     
     function getQuery($tabid,$module)
     {
       
     }
    
    
	function getListViewHeader($tabid,$type){
	
	}
   
    
    
    
    

}





?>