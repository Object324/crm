<?php



class Personnelfile extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['Personnelfile']='Personnelfile';
        if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules])) {
            globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
            include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
        }
    }
    
	var $log;
	var $db;
    var $module_name='Personnelfile';
	var $table_name = "ld_personnelfile";
	var $table_index= 'personnelfile_id';
	var $tab_name = Array('ld_crmentity','ld_personnelfile','ld_personnelfilescf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_personnelfile'=>'personnelfile_id','ld_personnelfilescf'=>'personnelfile_id');
	/**
	 * Mandatory table for supporting custom fields.
	 */
    var $customFieldTable = Array('ld_personnelfilescf', 'personnelfile_id');
	var $column_fields = Array();
    //其他自定义模块也用这些字段,可能这些变量已被弃用,先延用
	var $sortby_fields = Array('lastname','firstname','title','email','phone','smownerid','accountname');
	var $list_link_field= 'lastname';
    var $relatedtab=array('accounts'=>'','personnelfile'=>'','users'=>'','company'=>'','vendors'=>'');
    var $table_code='personnelfile_no';//瀹℃壒涓摼鎺ュ瓧娈?
	var $search_fields = Array(
	'Name' => Array('contactdetails'=>'lastname'),
	'Title' => Array('contactdetails'=>'title'),
	'Account Name'=>Array('contactdetails'=>'account_id'),
	'Assigned To'=>Array('crmentity'=>'smownerid'),
    );
	var $search_fields_name = Array(
	'Name' => 'lastname',
	'Title' => 'title',
	'Account Name'=>'account_id',
	'Assigned To'=>'assigned_user_id'
	);
	// This is the list of lingdang_fields that are required
	var $required_fields =  array("lastname"=>1);
	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
	var $mandatory_fields = Array('assigned_user_id','createdtime' ,'modifiedtime');
	//Default Fields for Email Templates -- Pavani
	var $emailTemplate_defaultFields = array('firstname','lastname','salutation','title','email','department','phone','mobile','support_start_date','support_end_date');
	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'lastname';
	var $default_sort_order = 'ASC';
	// For Alphabetical search
	var $def_basicsearch_col = 'lastname';

	function __construct() {
		$this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('Personnelfile',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('Personnelfile');
        $this->list_link_field=$entityname['fieldname'];
	}
	/** Function to handle module specific operations when saving a entity
	*/
	function save_module($module)
	{
        global $adb;
        if($_REQUEST['frommodule']&&$_REQUEST['fromid']>0) {
            //关联创建的模块，隐藏了模块字段
            $uitypes=cls_module_uitype::getModuleUitype($this->module_name,$_REQUEST['frommodule']);
            $uitype=$uitypes['uitype'];
            if(!empty($uitype)) {
                $this->fieldobj->getFieldInfoobjBykey("uitype",$uitype);
                $sql='select columnname,tablename,presence from ld_field where uitype=? and tabid=?';
                $result=$adb->pquery($sql,array($uitype,getTabid($this->module_name)));
                if($adb->num_rows($result)>0)
                {
                    $columnname=$adb->query_result($result,0,'columnname');
                    $tablename=$adb->query_result($result,0,'tablename');
                    $tableindex=$this->tab_name_index[$tablename];
                    $presence=$adb->query_result($result,0,'presence');
                    if($presence==1)
                    {
                        $sql="update $tablename set $columnname=? where $tableindex=? ";

                        $adb->pquery($sql,array($_REQUEST['fromid'],$this->id));
                    }
                }
            }
       }
	}
	
	function restore($module, $id) {
		parent::restore($module,$id);
   	}
}
Personnelfile::require_file();
?>