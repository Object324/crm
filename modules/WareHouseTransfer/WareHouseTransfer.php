<?php

class WareHouseTransfer extends CRMEntity {
     static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['WareHouseTransfer']='WareHouseTransfer';
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
	var $log;
	var $db;
    var $Detail_table="ld_warehousetransferdetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_warehousetransferdetailscf";//明细scf表
     var $Detail_table_index="id";//明细表和主表关联的字段
	var $table_name = "ld_warehousetransfer";
	var $table_index= 'warehousetransferid';
    var $table_code='transferdate_no';
	var $tab_name = Array('ld_crmentity','ld_warehousetransfer','ld_warehousetransfercf');  //查询
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_warehousetransfer'=>'warehousetransferid','ld_warehousetransfercf'=>'warehousetransferid');
    /**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_warehousetransfercf', 'warehousetransferid');//自定义
	var $entity_table = "ld_crmentity";
	var $object_name = "WareHouseTransfer";
    var $module_name='WareHouseTransfer';
	var $new_schema = true;

	var $column_fields = Array();
    
    var $relatedtab = Array('warehousetransfer'=>'','users'=>'','company'=>'','products'=>'');
    
	var $sortby_fields = Array('transferdate_no','outwarehouse','inwarehouse');    // 查询 排序

	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );

	// This is the list of ld_fields that are in the lists.
	var $list_link_field= 'transferdate_no';

	var $search_fields = Array();

	var $search_fields_name = Array();

	// This is the list of ld_fields that are required.
	var $required_fields =  array();

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'warehousetransferid';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_sogrouprelation','salesorderid');

	var $mandatory_fields = Array();

	// For Alphabetical search
	var $def_basicsearch_col = 'transferdate_no';
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
             
        $result = $adb->pquery($SqlField,array($languageType,'ld_field','WareHouseTransfer'));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
                "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
            );   
            $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";    
        }
    }*/
	/** Constructor Function for SalesOrder class
	 *  This function creates an instance of LoggerManager class using getLogger method
	 *  creates an instance for PearDatabase class and get values for column_fields array of SalesOrder class.
	 */
	function __construct() {
		//$this->log =LoggerManager::getLogger('WareHouseTransfer');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj = Field::getInstance('WareHouseTransfer',$this->db);
		$this->column_fields = $this->fieldobj->getFieldArray('fieldname',$this);
         /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('WareHouseTransfer');
        $this->list_link_field=$entityname['fieldname'];

        //@edit:liushuai,2020-09-16,reason:0042671/调拨单点击新建/编辑，界面加载不出来一直转圈
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
	}

	function save_module($module)
	{
		//in ajax save we should not call this function, because this will delete all the existing product values
		if($_REQUEST['action'] != 'WareHouseTransferAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
			//Based on the total Number of rows we will save the product relationship with this entity
			crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'WareHouseTransfer');
		}
		//编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
		// Update the currency id and the conversion rate for the invoice
		if($this->currency_status === true)
		{
			$update_query = "update ld_warehousetransfer set currency_id=?, conversion_rate=?,currency_symbol=? where warehousetransferid=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}      
        
	}

    function successApprove($record)
    {
        global $adb,$current_user;
        //更新审核状态、审核人
        $adb->pquery('update ld_warehousetransfer set transferstatus = ?,transfersmownerid = ? where warehousetransferid = ?',array('已审核',$current_user->id,$record));
    }
    public function rejectApproved($record)
    {
        global $adb;
        $adb->pquery('update ld_warehousetransfer set transferstatus = ?,transfersmownerid = ? where warehousetransferid = ?',array('未审核',0,$record));
    }

	function setRelationTables($secmodule){
		$rel_tables = array (
			"Calendar" =>array("ld_seactivityrel"=>array("crmid","activityid"),"ld_salesorder"=>"salesorderid"),
			"Invoice" =>array("ld_invoice"=>array("salesorderid","invoiceid"),"ld_salesorder"=>"salesorderid"),
			"Documents" => array("ld_senotesrel"=>array("crmid","notesid"),"ld_salesorder"=>"salesorderid"),
		);
		return $rel_tables[$secmodule];
	}
    
    function trackUnLinkedInfo($module, $crmid, $with_module, $with_crmid)
    {
        
    }
    /**
    *@author:andy
    *@data:20141105
    *@reason:库间调拨直接删除，不出现在回收站
    *@version:v5.8
    */
    function trash($module, $id)
    {
        global $adb;
        $sql='delete from ld_crmentity where crmid=?';
        $adb->pquery($sql,array($id));
        $sql='delete from ld_warehousetransfer where warehousetransferid=?';
        $adb->pquery($sql,array($id));
        $detailtable=$this->Detail_table;
        $sql=" delete from $detailtable where id=?";
        $adb->pquery($sql,array($id));
    }
    /*
      function getListQuery($module, $where = '') {
    $query = "SELECT ld_warehousetransfer.*,ld_warehousetransfer.warehousetransferid as crmid,
			ld_currency_info.currency_name
			FROM ld_warehousetransfer
		
			LEFT JOIN ld_warehousetransfercf
				ON ld_warehousetransfercf.warehousetransferid = ld_warehousetransfer.warehousetransferid
			LEFT JOIN ld_currency_info
				ON ld_warehousetransfer.currency_id = ld_currency_info.id
		
			LEFT JOIN ld_users
				ON ld_users.id = ld_warehousetransfer.smownerid";
                
			$query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_warehousetransfer.warehousetransferid";
			$query .= " WHERE ld_warehousetransfer.deleted = 0 " . $where;
        return $query;
    }*/
}
WareHouseTransfer::require_file();
?>