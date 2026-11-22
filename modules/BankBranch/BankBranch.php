<?php


class BankBranch extends CRMEntity {
    var $db, $log; // Used in class functions of CRMEntity
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['BankBranch']='BankBranch';
         if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $table_name = 'ld_bankbranch';
    var $table_index= 'bankbranchid';
    var $column_fields = Array();
    var $table_code='bankbranch_no';//表编号字段(审批中心)
    /** Indicator if this is a custom module or standard module */
    var $IsCustomModule = true;
    var $module_name='BankBranch';

    /**
     * Mandatory table for supporting custom fields.
     */
    var $customFieldTable = Array('ld_bankbranchcf', 'bankbranchid');

    /**
     * Mandatory for Saving, Include tables related to this module.
     */
    var $tab_name = Array('ld_crmentity', 'ld_bankbranch', 'ld_bankbranchcf');

    /**
     * Mandatory for Saving, Include tablename and tablekey columnname here.
     */
    var $tab_name_index = Array(
        'ld_crmentity' => 'crmid',
        'ld_bankbranch'   => 'bankbranchid',
        'ld_bankbranchcf' => 'bankbranchid');

    /**
     * Mandatory for Listing (Related listview)
     */
     /*
    edit:can
    date:20131024
    reason:打印关联模块
    */
    var $relatedtab=array('Parent Accounts'=>'','users'=>'','bankbranch'=>'');

    // Make the field link to detail view from list view (Fieldname)
    var $list_link_field = 'bankbranch_no';

  
    // For Popup window record selection
    var $popup_fields = Array('bankbranch_no');

    // Placeholder for sort fields - All the fields will be initialized for Sorting through initSortFields
    var $sortby_fields = Array();

    // For Alphabetical search
    var $def_basicsearch_col = 'bankbranch_no';

    // Column value to use on detail view record text display
    var $def_detailview_recname = 'bankbranch_no';

    // Required Information for enabling Import feature
    var $required_fields = Array('bankbranch_no'=>1);

    // Callback function list during Importing
    var $special_functions = Array('set_import_assigned_user');

    var $default_order_by = 'bankbranch_no';
    var $default_sort_order='ASC';
    // Used when enabling/disabling the mandatory fields for the module.
    // Refers to ld_field.fieldname values.
    var $mandatory_fields = Array('createdtime', 'modifiedtime');

    function __construct() {
        global  $currentModule;
       
        $this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('BankBranch',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $this->log = $log;
        /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('BankBranch');
        $this->list_link_field=$entityname['fieldname'];
    }
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
             
        $result = $adb->pquery($SqlField,array($languageType,'ld_field','BankBranch'));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            
                $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
                        "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
                    );   
                  $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
               
            
        }
    }*/
    
    function save_module($module) {
        
    }
    
    /**
     * Apply security restriction (sharing privilege) query part for List view.
     */
    function getListViewSecurityParameter($module) {
        global $current_user,$adb;
		$ScopOfAuthority = ScopOfAuthority::getInstance($adb,$module);
        return $ScopOfAuthority->getModuleListViewQuery();
    }
   
        
    function trash($module, $id)
    {    
       global $adb;       
        parent::trash($module,$id);
    }
    function getListQuery()
    {
         $query = "SELECT DISTINCT ld_bankbranch.*,ld_bankbranch.bankbranchid as crmid
			FROM ld_bankbranch 
			left JOIN ld_bankbranchcf
			        ON ld_bankbranch.bankbranchid = ld_bankbranchcf.bankbranchid
		
			LEFT JOIN ld_users
				ON ld_users.id = ld_bankbranch.smownerid ";
            
        if(isset($_REQUEST['type']) && $_REQUEST['type']=='alpbt')
            {
                $query .=" inner join  ld_cosler c on ((CONV(HEX(convert(left( ld_bankbranch.";
                $query .= $_REQUEST['search_field']." , 1) using gbk)),16,10) between c.cBegin and c.cEnd and f_PY like '".$_REQUEST['search_text']."%') or ld_campaign.". $_REQUEST['search_field']." like '". $_REQUEST['search_text']."%') ";
                
            }
			$query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_bankbranch.bankbranchid";
			$query .= " WHERE ld_bankbranch.deleted = 0 " . $where;    
      return $query;
    }
    
}
BankBranch::require_file();
?>