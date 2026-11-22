<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
class Management extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['Management']='Management';
         if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $log;
    var $db;
    var $table_name='ld_fund_management';
    public $table_index='managementid';
    var $table_code='management_no';//表编号字段(审批中心)
    var $tab_name=Array('ld_crmentity','ld_fund_management','ld_fund_managementscf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_fund_management'=>'managementid','ld_fund_managementscf'=>'managementid');
    var $list_link_field= 'management_no';
   	//关联模块
    var $relatedtab=array('accounts'=>'','users'=>'','salesorder'=>'','company'=>'','management'=>'');
    var $customFieldTable = Array('ld_fund_managementscf', 'managementid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";
    var $module_name='Management';
	var $column_fields = Array();
    var $sortby_fields=Array();
            
            	var $search_fields_name = Array(
		
			);
            
            var $required_fields =  array();

//比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'management_no');
	var $default_order_by = 'management_no';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="management_no";
    var $popup_fields=Array();
    function __construct()
    {
	   //$this->log =LoggerManager::getLogger('Management');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('Management',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
          /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('Management');
        $this->list_link_field=$entityname['fieldname'];
        $this->popup_fields=Array($this->list_link_field);
    }
    
   	function save_module($module){}
    
   
     /*
    date：20130916
    reason:更多信息字段
    edit by chj
    
    function getRelated($Type)
    {
        global $adb,$current_user;
        require('user_privileges/user_language_'.$current_user->id.'.php');
       
        $SqlField = "select tablename,fieldname,case when ifnull(ld_tranlabel.fieldlabel,'')=''then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
                 from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
              inner join ld_relatedlists_lable  on ld_relatedlists_lable.fieldid=ld_field.fieldid
             where languagetype=? and trantable=? and ld_tranlabel.tabid=(select tabid from ld_tab where name=? ) and ld_relatedlists_lable.presence=1  order by ld_relatedlists_lable.sequence";
             
        $result = $adb->pquery($SqlField,array($languageType,'ld_field','Management'));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            
                $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
                        "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
                    );   
                  $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
               
            
        }
    }*/
    function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Accounts' ||$return_module=="SalesOrder"||$return_module=="ServiceContracts") {
			$this->trash('Management',$id);
		} 
	}
  
   /**
     * 计提保存
     * */
    public function save_accured()
    {
       cls_fund_save_accured::save($this);
    }
    
    public function   trash($module, $id)
    {
            global $adb;
          $sql='select group_concat(ld_fund_accured_history_detail.id) from ld_fund_accured_history
                        inner join ld_fund_accured_history_detail on ld_fund_accured_history.id=ld_fund_accured_history_detail.fund_accured_historyid
                        inner join ld_fund_management on ld_fund_accured_history.type=?   
                        and  ld_fund_management.product_id=ld_fund_accured_history.productid and ld_fund_management.accountid=ld_fund_accured_history_detail.accountid
                        and ld_fund_management.expensedate=ld_fund_accured_history_detail.accured_date
                where ld_fund_management.managementid=?';
                        
                   
           $result =$adb->pquery($sql,array('management',$id)) ;
           if($adb->num_rows($result)>0)
           {
               $detail_ids=$adb->query_result($result,0,0);
               // $sql='delete from ld_fund_accured_history  where id in( '.$accured_ids.')';
              //  $result=$adb->pquery($sql,array());
                $sql='delete from ld_fund_accured_history_detail where id in( '.$detail_ids.')';
                $result=$adb->pquery($sql,array());
           }
           //else
           //{
             $sql='select  GROUP_CONCAT(ld_fund_accured_history.id) from ld_fund_accured_history   LEFT JOIN ld_fund_accured_history_detail
                on ld_fund_accured_history.id=ld_fund_accured_history_detail.fund_accured_historyid 
                where ld_fund_accured_history.type=?  and fund_accured_historyid is null;';
              $result =$adb->pquery($sql,array('management')) ;
             if($adb->num_rows($result)>0)
             {
                $ids=$adb->query_result($result,0,0);
                $sql='delete from ld_fund_accured_history where id in('.$ids.' )';
                $adb->pquery($sql,array());
             }
           //}
           
            
            $sql='delete from ld_crmentity where crmid=?';
            $result=$adb->pquery($sql,array($id));
            $sql='delete from ld_fund_management where managementid=?';
            $result=$adb->pquery($sql,array($id));
            $sql='delete from ld_fund_managementscf where managementid=?';
            $result=$adb->pquery($sql,array($id));
                   
    }
    /**
     * 重算日志
     * */
    public function getRecalculate_log($id, $cur_tab_id, $rel_tab_id, $actions=false)
    {
        crm_load_class_file('cls_Jijin_logshow','include/trade/Jijin');
        $obj=new cls_Jijin_logshow('Management',$id);
        return $obj->getRecalculate_log();
        
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
     $query = "SELECT ld_fund_management.managementid as crmid ".$fromclause.
            ",ld_fund_management.* from  ld_fund_management 
			     LEFT JOIN ld_users
				ON ld_users.id = ld_fund_management.smownerid
                LEFT JOIN ld_account on ld_account.accountid=ld_fund_management.accountid
                left join ld_fund_managementscf on ld_fund_managementscf.managementid=ld_fund_management.managementid
                 LEFT JOIN ld_products on ld_products.productid=ld_fund_management.product_id ";
        if(isset($_REQUEST['type']) && $_REQUEST['type']=='alpbt')
            {
                $query .=" inner join  ld_cosler c on ((CONV(HEX(convert(left( ld_fund_management.management_no";
                $query .= $_REQUEST['search_field']." , 1) using gbk)),16,10) between c.cBegin and c.cEnd and f_PY like '".$_REQUEST['search_text']."%') or ld_fund_management.". $_REQUEST['search_field']." like '". $_REQUEST['search_text']."%') ";
                
            }
			$query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_fund_management.managementid";
			$query .= " WHERE ld_fund_management.deleted = 0 and ld_products.productname like '%".$_REQUEST['query_string']."%'" . $where;    
        return $query;
    }
}
Management::require_file();
?>