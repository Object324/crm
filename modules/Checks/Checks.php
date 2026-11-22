<?php

class Checks extends CRMEntity {
	var $log;
	var $db;
    var $Detail_table="ld_checksdetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_checksdetailscf";//明细scf表
    var $Detail_table_index="id";//明细表和主表关联的字段
	var $table_name = "ld_checks";
	var $table_index= 'id';
	var $tab_name = Array('ld_crmentity','ld_checks','ld_checkscf');  //查询
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_checks'=>'id','ld_checkscf'=>'id');
    /**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_checkscf', 'id');//自定义
	var $entity_table = "ld_crmentity";
	var $object_name = "Checks";
     var $module_name='Checks';
	var $new_schema = true;

	var $column_fields = Array();

	var $sortby_fields = Array('ware_stock_no','wareid','createdate','purchaseorder_id','smownerid','vendor_id','presence');    // 查询 排序

	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );
	  //管理模块
    var $relatedtab=array('checks'=>'','users'=>'','company'=>'','products'=>'');
	// This is the list of ld_fields that are in the lists.
	var $list_link_field= 'subject';

	var $search_fields = Array(
				'Order No'=>Array('salesorder'=>'salesorder_no'),
				'Subject'=>Array('salesorder'=>'subject'),
				'Account Name'=>Array('account'=>'accountid'),
				'Quote Name'=>Array('salesorder'=>'quoteid')
				);

	var $search_fields_name = Array(
					'Order No'=>'salesorder_no',
				        'Subject'=>'subject',
				        'Account Name'=>'account_id',
				        'Quote Name'=>'quote_id'
				      );

	// This is the list of ld_fields that are required.
	var $required_fields =  array("accountname"=>1);

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'stock_id';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_sogrouprelation','salesorderid');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'subject';
   function trash($module,$id)
    {
        global $adb;
        
        //34655: 产品管理列表界面：当产品被创建盘点单后，将创建的盘点单据删除掉后，无法删除被创建盘点单的产品。
         $sql='delete from ld_crmentity where crmid=?';
         $adb->pquery($sql,array($id));
         $sql='delete from ld_checks where id=?';
           
         $adb->pquery($sql,array($id));
        $detailtable=$this->Detail_table;
        $detailtablescf=$this->Detail_table_scf;
       $sql='select GROUP_CONCAT(productid) from ld_checksdetail where id=?';
       $result=$adb->pquery($sql,array($id));
       
        
       $adb->pquery(" delete from $detailtable where id = ?",array($id));
       $sql= "delete from $detailtablescf where lineitem_id not in(select lineitem_id  from $detailtable ) ";
       $adb->pquery($sql,array());
       if($adb->num_rows($result)>0)
       {
            $productid_arr=explode(",",$adb->query_result($result,0,0));
           crm_load_function_file('insertCondtion','include/Stock','CommonStock');
           foreach($productid_arr as $productid)
                insertProductQty($productid,0,1);
       }
       
    }
	/** Constructor Function for SalesOrder class
	 *  This function creates an instance of LoggerManager class using getLogger method
	 *  creates an instance for PearDatabase class and get values for column_fields array of SalesOrder class.
	 */
	function __construct() {
	///	$this->log =LoggerManager::getLogger('Checks');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('Checks',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
         /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('Checks');
        $this->list_link_field=$entityname['fieldname'];
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
	}

	function save_module($module)
	{
	   
		//in ajax save we should not call this function, because this will delete all the existing product values
		if($_REQUEST['action'] != 'ChecksAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
			//Based on the total Number of rows we will save the product relationship with this entity
			//合同订单明细保存
            crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'Checks');
		}

		// Update the currency id and the conversion rate for the sales order
		
	}

    function successApprove($record)
    {
        $this->operationwarehouse($record,'checked');
    }
    public function rejectApproved($record)
    {
        $this->operationwarehouse($record,'checking');
    }

    //同updateCheckPresence()
    function operationwarehouse($record,$type)
    {
        global $current_user,$adb,$currentModule;
        //更新盘点状态、确认盘点人及产品库存数量
        crm_load_class_file('CommonStock','include/Stock');
        if($type=='checked')
        {
            $pre = CHECKEND;
            $var = "确认盘点";
            $subsmownerid=$current_user->id;
        }
        else
        {
            $pre = CHECKING;
            $var = "撤销盘点";
            $subsmownerid=0;
        }

        $warid = selCheckInfo($record,2);
        $userid = selCheckInfo($record,3);

        $adb->pquery('update ld_checks set presence = "'.$pre.'",subsmownerid = '.$subsmownerid.' where id = '.$record.';');
        $sql = "select productid,parent_lineitem_id,lineitem_id,batchtext from ld_checksdetail where id = ?";
        $result=$adb->pquery($sql,array($record));
        $num_rows=$adb->num_rows($result);
        for($i = 0; $i<$num_rows; $i++)
        {
            $productid = $adb->query_result($result,$i,'productid');
            $parent_lineitem_id =  $adb->query_result($result,$i,'parent_lineitem_id');
            $lineitem_id =  $adb->query_result($result,$i,'lineitem_id');
            $batchtext=$adb->query_result($result,$i,'batchtext');
            insertCondtion($batchtext,$record,$var,$warid,$productid,$currentModule,$userid,0,0,$parent_lineitem_id,$lineitem_id);
        }

    }

	/*
    日程管理
    ediby By LD can
    date:20130226
    reason:“待办日程”和“活动历史”合并为“日程管理”
 
     */
	function get_schedule($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global $singlepane_view,$currentModule,$current_user;
		
		$this_module = $currentModule;

        $related_module = getTabname($rel_tab_id);
		require_once("modules/$related_module/Activity.php");
		$other = new Activity();
       
		$singular_modname = vtlib_toSingular($related_module);

		$parenttab = getParentTab();

		if($singlepane_view == 'true')
			$returnset = '&return_module='.$this_module.'&return_action=DetailView&return_id='.$id;
		else
			$returnset = '&return_module='.$this_module.'&return_action=CallRelatedList&return_id='.$id;

		$button = '';

		$button .= '<input type="hidden" name="activity_mode">';

		if($actions) {
			if(is_string($actions)) $actions = explode(',', strtoupper($actions));
			if(in_array('ADD', $actions) && isPermitted($related_module,"Create", '') == 'yes') {
			//	if(getFieldVisibilityPermission('Calendar',$current_user->id,'parent_id', 'readwrite') == '0') {
//					$button .= "<input title='".getFixedLabel('CREATE'). " ". getTranstab($related_module) ."' class='createauto'" .
//						" onclick='this.form.action.value=\"EditView\";this.form.module.value=\"$related_module\";this.form.return_module.value=\"$this_module\";this.form.activity_mode.value=\"Events\";MoreCreateModuleFromSalesOrder(this,this.form)' type='button' name='button'" .
//						" value='". getFixedLabel('CREATE'). " " . getTranstab($related_module) ."'>&nbsp;";

					$button .= '<button class="Anu1_a" title="'.getFixedLabel('CREATE').'"
					type="button" name="button" onclick="this.form.action.value=\'EditView\';this.form.module.value=\''.$related_module.'\';this.form.return_module.value=\''.$this_module.'\';this.form.activity_mode.value=\'Events\';MoreCreateModuleFromSalesOrder(this,this.form);">
				<img src="themes/softed/button/icon_add.png" /><span>'.getFixedLabel('CREATE').'</span>
				</button>';
			//	}
			}
		}

		//$userNameSql = getSqlForNameInDisplayFormat(array('first_name'=>
						//	'ld_users.first_name', 'last_name' => 'ld_users.last_name'), 'Users');
		$query = "SELECT ld_users.last_name as user_name,ld_contactdetails.lastname, ld_contactdetails.firstname, ld_contactdetails.contactid, ld_activity.*,ld_seactivityrel.*,ld_crmentity.crmid, ld_crmentity.smownerid, ld_crmentity.modifiedtime from ld_activity inner join ld_seactivityrel on ld_seactivityrel.activityid=ld_activity.activityid inner join ld_crmentity on ld_crmentity.crmid=ld_activity.activityid left join ld_contactdetails on ld_contactdetails.contactid = ld_activity.contactid left join ld_users on ld_users.id=ld_crmentity.smownerid where ld_seactivityrel.crmid=".$id."  and ld_crmentity.deleted=0 ";

		$return_value = GetRelatedList($this_module, $related_module, $other, $query, $button, $returnset);

		if($return_value == null) $return_value = Array();
		$return_value['CUSTOM_BUTTON'] = $button;

		return $return_value;
	}


	/*
	 * Function to get the relation tables for related modules
	 * @param - $secmodule secondary module name
	 * returns the array with table names and fieldnames storing relations between module and this module
	 */
	function setRelationTables($secmodule){
		$rel_tables = array (
			"Calendar" =>array("ld_seactivityrel"=>array("crmid","activityid"),"ld_salesorder"=>"salesorderid"),
			"Invoice" =>array("ld_invoice"=>array("salesorderid","invoiceid"),"ld_salesorder"=>"salesorderid"),
			"Documents" => array("ld_senotesrel"=>array("crmid","notesid"),"ld_salesorder"=>"salesorderid"),
		);
		return $rel_tables[$secmodule];
	}

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Accounts') {
			$this->trash('SalesOrder',$id);
		}
		elseif($return_module == 'Quotes') {
			$relation_query = 'UPDATE ld_salesorder SET quoteid=? WHERE salesorderid=?';
			$this->db->pquery($relation_query, array(null, $id));
		}
		elseif($return_module == 'Potentials') {
			$relation_query = 'UPDATE ld_salesorder SET potentialid=? WHERE salesorderid=?';
			$this->db->pquery($relation_query, array(null, $id));
		}
		elseif($return_module == 'Contacts') {
			$relation_query = 'UPDATE ld_salesorder SET contactid=? WHERE salesorderid=?';
			$this->db->pquery($relation_query, array(null, $id));
		} else {
			$sql = 'DELETE FROM ld_crmentityrel WHERE (crmid=? AND relmodule=? AND relcrmid=?) OR (relcrmid=? AND module=? AND crmid=?)';
			$params = array($id, $return_module, $return_id, $id, $return_module, $return_id);
			$this->db->pquery($sql, $params);
		}
	}

	public function getJoinClause($tableName) {
		if (strtolower($tableName) == 'ld_invoice_recurring_info') {
			return 'LEFT JOIN';
		}
		return parent::getJoinClause($tableName);
	}
    /*
    function getListQuery($module, $where = '') {
		crm_load_function_file('getWareidAll','include/Stock','CommonStock');
        $query="SELECT distinct ld_checks.*, ld_checks.id as crmid FROM ld_checks LEFT JOIN ld_users ON ld_checks.smownerid = ld_users.id left join ld_checkscf on ld_checkscf.id = ld_checks.id";
		$query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_checks.id";
		$query .= " WHERE ld_checks.deleted = 0 and ld_checks.id > 0 and ld_checks.wareid in (" . getWareidAll($current_user->id) . ") " . $where;
        return $query;
    }*/
}

?>