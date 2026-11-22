<?php



class ServiceReturn extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['ServiceReturn']='ServiceReturn';
            if(empty(globalStatic::$arr_module_require['HelpDesk']))
            {
                globalStatic::$arr_module_require['HelpDesk']='HelpDesk';
                include(globalStatic::$root_directory.'modules/HelpDesk/HelpDesk.php');
                
            }
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require['Potentials']))
            {
                globalStatic::$arr_module_require['Potentials']='Potentials';
                include(globalStatic::$root_directory.'modules/Potentials/Potentials.php');
                
            }
            if(empty(globalStatic::$arr_module_require['Activity']))
            {
                globalStatic::$arr_module_require['Activity']='Activity';
                include(globalStatic::$root_directory.'modules/Calendar/Activity.php');
                
            }
            if(empty(globalStatic::$arr_module_require['Documents']))
            {
                globalStatic::$arr_module_require['Documents']='Documents';
                include(globalStatic::$root_directory.'modules/Documents/Documents.php');
               
            }
            if(empty(globalStatic::$arr_module_require['Campaigns']))
            {
                globalStatic::$arr_module_require['Campaigns']='Campaigns';
                include(globalStatic::$root_directory.'modules/Campaigns/Campaigns.php');
                
            }
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }
    }
    
	var $log;
	var $db;
    var $module_name='ServiceReturn';
	var $table_name = "ld_servicereturn";
	var $table_index= 'servicereturnid';
	var $table_code='servicereturn_no';//表编号字段(审批中心)
	//'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
	//'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
	//'ld_customerdetails'=>'customerid'
	var $tab_name = Array('ld_crmentity','ld_servicereturn','ld_servicereturncf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_servicereturn'=>'servicereturnid','ld_servicereturncf'=>'servicereturnid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_servicereturncf', 'servicereturnid');

	var $column_fields = Array();
    
	var $sortby_fields = Array();

	var $list_link_field= 'servicereturn_no';
    var $relatedtab=array('accounts'=>'','contacts'=>'','users'=>'','company'=>'','servicereturn'=>'','project'=>'');



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
	var $def_basicsearch_col = 'servicereturn_no';

    public $servicereturn_no;

	function __construct() {
	
		$this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('ServiceReturn',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('ServiceReturn');
        $this->list_link_field=$entityname['fieldname'];
	}
    function  trash($module, $id) 
    {
        parent::trash($module,$id);
    }
    /*
    *reason:合同订单更多信息新增联系记录
    *edit:by andy
    *date:20140110
    */
    //联系记录
    function get_contactrecords($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global  $singlepane_view,$currentModule,$current_user,$adb;

		$this_module = $currentModule;

        $related_module ="ContactRecords";
	
		$other = CRMEntity::getInstance($related_module);
  
		if($singlepane_view == 'true')
			$returnset = '&return_module='.$this_module.'&return_action=DetailView&return_id='.$id;
		else
			$returnset = '&return_module='.$this_module.'&return_action=CallRelatedList&return_id='.$id;

		$button = '';

		if($actions ) {
			if(is_string($actions)) $actions = explode(',', strtoupper($actions));
			if(in_array('SELECT', $actions) && isPermitted($related_module,4, '') == 'yes') {
				$button .= '<a title="'.getFixedLabel('SELECT').'" href="javascript:void(0);"
				onclick=\'return window.open("index.php?module='.$related_module.'&return_module='.$currentModule.'&action=Popup&popuptype=detailview&select=enable&form=EditView&form_submit=false&recordid='.$id.'&parenttab='.$parenttab.'","test","width=640,height=602,resizable=0,scrollbars=0");\'>
				<span>'.getFixedLabel('SELECT').'</span></a>';
			}
			if(in_array('ADD', $actions) && isPermitted($related_module,"Create", '') == 'yes') {
				$button .= '<a title="'.getFixedLabel('CREATE').'" target="_blank" 
				href="index.php?module='.$related_module.'&action=EditView&return_module='.$related_module.'&return_action=DetailView&Create=yes&salesorder_id='.$id.'&account_id='.$_REQUEST['account_id'].'&contact_id='.$_REQUEST['contact_id'].'&potential_id='.$_REQUEST['potential_id'].'">
				<span>'.getFixedLabel('CREATE').'</span></a>';
			}
		}
		if($current_user->is_admin=='off'&&$current_user->accountallview==0){
			$scopeobj = new ScopOfAuthority($adb,'ContactRecords');
			$getSmOwnerSearchSql =$scopeobj->getSmOwnerSearchSql();
		}
		$query = "
                SELECT 
                    ld_users.last_name as user_name, ld_crmentity.*,ld_contactrecords.*, ld_contactrecords.subject 
                FROM 
                    ld_contactrecords 
                INNER JOIN ld_crmentity ON ld_crmentity.crmid = ld_contactrecords.contactrecordid 
                LEFT OUTER JOIN ld_salesOrder ON ld_salesOrder.salesorderid = ld_contactrecords.salesorderid 
                left join ld_tabshare on ld_tabshare.crmid= ld_contactrecords.contactrecordid
				LEFT JOIN ld_users ON ld_salesOrder.smownerid = ld_users.id 
                WHERE 
                    ld_salesOrder.deleted=0 and ld_salesOrder.salesorderid = ".$id.' '.$getSmOwnerSearchSql;
		if(isset($_REQUEST['responseType']) && $_REQUEST['responseType'] == 'htmlfive'){
			return $query;
		}
		$return_value = GetRelatedList($this_module, $related_module, $other, $query, $button, $returnset);
		if($return_value == null) $return_value = Array();
		$return_value['CUSTOM_BUTTON'] = $button;
		return $return_value;
	}
    
    
    
   	function save_module($module) {

    }
    
    function create_export_query(){
        
    }
    /*
	function getRelated($Type)
    {
        global $adb,$current_user;
        require('user_privileges/user_language_'.$current_user->id.'.php');

        $SqlField = "select tablename,fieldname,ld_tranlabel.fieldlabel
                 from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
              inner join ld_relatedlists_lable  on ld_relatedlists_lable.fieldid=ld_field.fieldid
             where languagetype=? and trantable=? and ld_tranlabel.tabid=(select tabid from ld_tab where name=? )  and ld_relatedlists_lable.presence=1  order by ld_relatedlists_lable.sequence";

        $result = $adb->pquery($SqlField,array($languageType,'ld_field','ServiceReturn'));
        for($i=0;$i<$adb->num_rows($result);$i++)
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
    /*
	function getListQuery()
    {
         $query = "SELECT DISTINCT ld_servicereturn.*,ld_servicereturn.servicereturnid as crmid
			FROM ld_servicereturn 
			left JOIN ld_servicereturncf
			        ON ld_servicereturn.servicereturnid = ld_servicereturncf.servicereturnid		
			LEFT JOIN ld_users
				ON ld_users.id = ld_servicereturn.smownerid
			LEFT JOIN ld_account
				on ld_account.accountid = ld_servicereturn.accountid";
            
        if(isset($_REQUEST['type']) && $_REQUEST['type']=='alpbt')
            {
                $query .=" inner join  ld_cosler c on ((CONV(HEX(convert(left( ld_servicereturn.";
                $query .= $_REQUEST['search_field']." , 1) using gbk)),16,10) between c.cBegin and c.cEnd and f_PY like '".$_REQUEST['search_text']."%') or ld_campaign.". $_REQUEST['search_field']." like '". $_REQUEST['search_text']."%') ";
                
            }
			$query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_servicereturn.servicereturnid";
			$query .= " WHERE ld_servicereturn.deleted = 0 " . $where;  
			
      return $query;
    }*/
    
}
ServiceReturn::require_file();
?>