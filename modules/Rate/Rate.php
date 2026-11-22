<?php
crm_load_class_file('FileUtil','include/upload/');//editor:gyq data:20170510 reason:不能用require_once
require_once(globalStatic::$root_directory.'include/RelatedListView.php');
/*require_once('include/upload/FileUtil.php');
require_once('include/RelatedListView.php');*/
// Account is used to store ld_account information.
class Rate extends CRMEntity {
    static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['Rate']='Rate';
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
	var $log;
	var $db;
    var $module_name='Rate';
	var $table_name = "ld_rate";
	var $table_index= 'rate_id';
    var $table_code='';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_rate','ld_ratescf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_rate'=>'rate_id','ld_ratescf'=>'rate_id');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_ratescf', 'rate_id');
	var $entity_table = "ld_crmentity";

	var $billadr_table = "";
   //打印管理模块
    var $relatedtab=array('rate'=>'','users'=>'');
    
	var $object_name = "Rate";

	var $new_schema = true;

	var $column_fields = Array();

	var $sortby_fields = Array('subject','crmid','smownerid','accountname','lastname');

	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );

  
	var $list_link_field= 'subject';

	
	// This is the list of ld_fields that are required.
	var $required_fields =  array("accountname"=>1);

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'rate_id';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_quotegrouprelation','quoteid');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'subject';
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
             
        $result = $adb->pquery($SqlField,array($languageType,'ld_field','Rate'));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            
                $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
                        "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
                    );   
                  $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
               
            
        }
    }*/
	/**	Constructor which will set the column_fields in this object
	 */
	function __construct() {
		//$this->log =LoggerManager::getLogger('quote');
		$this->db = PearDatabase::getInstance();
         /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('Rate',$this);
        $this->list_link_field=$entityname['fieldname'];
		 $this->fieldobj=Field::getInstance('Rate',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        
	}
    
    function create_export_query($where)
	{
		global $current_user;
		$thismodule = $_REQUEST['module'];

		include("include/utils/ExportUtils.php");

		//To get the Permitted fields query and the permitted fields list
		$sql = getPermittedFieldsQuery($thismodule, "detail_view");

		$fields_list = getFieldsListFromQuery($sql);

		$query = "SELECT $fields_list
					FROM ld_crmentity INNER JOIN $this->table_name ON ld_crmentity.crmid=$this->table_name.$this->table_index";

		if(!empty($this->customFieldTable)) {
			$query .= " INNER JOIN ".$this->customFieldTable[0]." ON ".$this->customFieldTable[0].'.'.$this->customFieldTable[1] .
				      " = $this->table_name.$this->table_index";
		}

		$query .= " LEFT JOIN ld_groups ON ld_groups.groupid = ld_crmentity.smownerid";
		$query .= " LEFT JOIN ld_users ON ld_crmentity.smownerid = ld_users.id AND ld_users.status='Active'";
		$query .= $this->getNonAdminAccessControlQuery('Services',$current_user);
		$where_auto = " ld_crmentity.deleted=0";

		if($where != '') $query .= " WHERE ($where) AND $where_auto";
		else $query .= " WHERE $where_auto";

		return $query;
	}
	function transform_export_value($key, $value) {
		return parent::transform_export_value($key, $value);
	}
	function save_module()
	{
		global $adb;
		//in ajax save we should not call this function, because this will delete all the existing product values
	   //保存适用范围信息
       if(isset($_REQUEST['selectType']) && isset($_REQUEST['selectValue'])){
            if(!empty($this->id)){
                $query = 'update ld_rate set selecttype=?,selectvalue=? where rate_id = ?';
                $adb->pquery($query,array($_REQUEST['selectType'],$_REQUEST['selectValue'],$this->id));
            }
       }
    }
    //获取适用范围信息
    function getRateSelect($id=''){
        global $adb;
        if(!empty($this->id)){
            $query = 'select selecttype,selectvalue from ld_rate where rate_id = ? limit 1';
            $result = $adb->pquery($query,array($this->id));
            $selectInfo['selecttype'] = $adb->query_result($result,0,'selecttype');
            $selectInfo['selectvalue'] = $adb->query_result($result,0,'selectvalue');
            return $selectInfo;
        }
    }
    
    /*
    function getListQuery($module, $where = '') {
        $query = "SELECT ld_rate.rate_id as crmid,ld_rate.*
			FROM ld_rate
			
			LEFT JOIN ld_ratescf
				ON ld_rate.rate_id = ld_ratescf.rate_id
			
			LEFT JOIN ld_users
				ON ld_users.id = ld_rate.smownerid";
           if(isset($_REQUEST['type']) && $_REQUEST['type']=='alpbt')
            {
                $query .=" inner join  ld_cosler c on ((CONV(HEX(convert(left( ld_rate.";
                $query .= $_REQUEST['search_field']." , 1) using gbk)),16,10) between c.cBegin and c.cEnd and f_PY like '".$_REQUEST['search_text']."%') or ld_Quotes.". $_REQUEST['search_field']." like '". $_REQUEST['search_text']."%') ";
                
            }
			$query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_rate.rate_id";
			$query .= " WHERE ld_rate.deleted = 0 " . $where;
            return $query;
   }*/
	
}
Rate::require_file();
?>
