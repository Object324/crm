<?php



class FundNet extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['FundNet']='FundNet';
           
          
            if(empty(globalStatic::$arr_module_require['Activity']))
            {
                globalStatic::$arr_module_require['Activity']='Activity';
                include(globalStatic::$root_directory.'modules/Calendar/Activity.php');
                
            }
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }
    }
    
	var $log;
	var $db;
    var $module_name='FundNet';
	var $table_name = "ld_fund_net";
	var $table_index= 'fundnetid';

	var $tab_name = Array('ld_crmentity','ld_fund_net','ld_fund_netcf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_fund_net'=>'fundnetid','ld_fund_netcf'=>'fundnetid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_fund_netcf', 'fundnetid');

	var $column_fields = Array();
    
	var $sortby_fields = Array();

	var $list_link_field= 'fund_no';
    var $relatedtab=array();

	var $search_fields = Array(
	);

	var $search_fields_name = Array(
	);

	// This is the list of lingdang_fields that are required
	var $required_fields =  array();

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
	var $mandatory_fields = Array();

	//Default Fields for Email Templates -- Pavani
	var $emailTemplate_defaultFields = array();

	//Added these variables which are used as default order by and sortorder in ListView
	//var $default_order_by = 'lastname';
	//var $default_sort_order = 'ASC';

	// For Alphabetical search
	var $def_basicsearch_col = 'fund_no';
    	/**
	 * 增加getrelated方法
	 * @reason 0010111 快速查找报新公告缺少方法
	 * @author Tujt 2014-07-17
	 
    function getRelated($Type)
    {
        global $adb,$current_user;
        require('user_privileges/user_language_'.$current_user->id.'.php');
       
        $tabid = getTabid('FundNet');
        $SqlField = "select tablename,fieldname,case when ifnull(ld_tranlabel.fieldlabel,'')=''then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
                 from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
              left join ld_relatedlists_lable  on ld_relatedlists_lable.fieldid=ld_field.fieldid
             where languagetype=? and trantable=? and ld_tranlabel.tabid=".$tabid." and ld_field.presence in (0,2)
			 and ld_field.displaytype in (1) order by ld_field.sequence";//ld_relatedlists_lable.presence=1 
        $result = $adb->pquery($SqlField,array($languageType,'ld_field'));
		$rows = $adb->num_rows($result);
        for($i=0;$i<$rows;$i++)
        {
            
                $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
                        "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
                    );   
                  $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
               
            
        }
        if($Type==1)
        {
            return $this->list_fields;
        }
        else
        {
            return $this->list_fields_name;
        }
        
    }*/
	function __construct() {
	
		$this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('FundNet',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('FundNet');
        $this->list_link_field=$entityname['fieldname'];
	}
    function trash($module, $id)
    {
        parent::trash($module,$id);
    }
    
    function save($module, $id="")
    {
        global $adb;       
        if($this->mode == 'create' || $this->mode == ''){
            $productid = $_REQUEST['product_id'];
            $navdate = $_REQUEST['navdate'];
            $sql='select fundnetid from ld_fund_net where product_id=? and navdate=? and deleted=0';
            $result=$adb->pquery($sql,array($productid,$navdate));
            if($adb->num_rows($result)>0)
            {
                $fundnetid = $adb->query_result($result,0,0);
                $this->id = $fundnetid;
                $this->mode = 'edit';
                return parent::save($module);
            }else{
                $sql='delete from ld_fund_net where product_id=? and navdate=?';
                $adb->pquery($sql,array($productid,$navdate));
                return parent::save($module);
            }        
        }else{
            return parent::save($module);
        }
    }
      function getListQuery($module, $where = '') {
     
        $customview=CustomView::getInstance($module);
        $moduleobj=$this;
    	
    	$table_name = $moduleobj->table_name;
    
        $viewid=$customview->getViewId($module);
        $columnlist=$customview->getColumnsListByCvid($viewid);
       
        $fromclause="";
    	$ismodtable = array('ld_crmentity'=>'1','ld_accountbillads'=>'1',
    		'ld_accountshipads'=>'1','ld_contactaddress'=>'1','ld_contactsubdetails'=>'1');
    
        foreach($columnlist as $colmn)
        {
             $arrcolumn=explode(":",$colmn);
    	   if(isset($ismodtable[strtolower($arrcolumn[0])])){
    				$arrcolumn[0] = $table_name;
    			 }
            $fromclause .=" ,".$arrcolumn[0].".".$arrcolumn[1];
        }
     $query = "SELECT distinct ld_fund_net.fundnetid as crmid,ld_users.last_name " .$fromclause .
			",ld_fund_net.* FROM ld_fund_net
                        LEFT JOIN ld_fund_netcf on ld_fund_net.fundnetid=ld_fund_netcf.fundnetid
			
			LEFT JOIN ld_users
				ON ld_users.id = ld_fund_net.smownerid
            LEFT JOIN ld_products on ld_products.productid=ld_fund_net.product_id   ";
                
	
            
        if(isset($_REQUEST['type']) && $_REQUEST['type']=='alpbt')
            {
                $query .=" inner join  ld_cosler c on ((CONV(HEX(convert(left( ld_contactdetails.";
                $query .= $_REQUEST['search_field']." , 1) using gbk)),16,10) between c.cBegin and c.cEnd and f_PY like '".$_REQUEST['search_text']."%') or ld_contactdetails.". $_REQUEST['search_field']." like '". $_REQUEST['search_text']."%') ";
                
            }
			$query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_fund_net.fundnetid";
			$query .= "  WHERE ld_fund_net.deleted = 0  and ld_products.productname like '%".$_REQUEST['query_string']."%'" . $where; 
            
            return $query;  
    }   
   	function save_module($module) {
        
    }
    
    function create_export_query(){
        
    }
	
}
FundNet::require_file();
?>