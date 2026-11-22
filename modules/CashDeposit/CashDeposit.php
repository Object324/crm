<?php
class CashDeposit extends CRMEntity{
    var $table_name = "ld_cashdeposit";
	var $table_index= 'cashdepositid';//主表主键
    var $table_code='cashdeposit_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_cashdeposit','ld_cashdepositscf');
    //定义各个表主键
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_cashdeposit'=>'cashdepositid','ld_cashdepositscf'=>'cashdepositid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_cashdepositscf', 'cashdepositid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";

	var $column_fields = Array();
    var $module_name='CashDeposit';
 //和主表关联的模块
    var $relatedtab=array('putcash'=>'','users'=>'','cashdeposit'=>'','bankaccountset'=>'');
	var $sortby_fields = Array('cashdepositid','cashdeposit_no');
    var $popup_fields=Array();

	var $list_link_field= 'cashdeposit_no';

	var $search_fields = Array(
			'Cashdeposit No'=>array('ld_cashdeposit'=>'cashdeposit_no'),

			'Assigned To'=>Array('ld_crmentity'=>'smownerid'),
			);

	var $search_fields_name = Array(
			'Cashdeposit No'=>'cashdeposit_no',
		
			'Assigned To'=>'assigned_user_id',
			);
	// This is the list of lingdang_fields that are required
	var $required_fields =  array();

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
    //比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'accountname');

	//Default Fields for Email Templates -- Pavani
//	var $emailTemplate_defaultFields = array('accountname','account_type','industry','annualrevenue','phone','email1','rating','website','fax');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'cashdeposit_no';
	var $default_sort_order = 'ASC';

	// For Alphabetical search
    //拼音查询字段
	var $def_basicsearch_col = 'cashdeposit_no';
    public $db;
    function __construct() {
	//	$this->log =LoggerManager::getLogger('CashDeposit');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('CashDeposit',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
          /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('CashDeposit');
        $this->list_link_field=$entityname['fieldname'];
        $this->popup_fields=Array($this->list_link_field);
	}
  
    function  save_module($module) 
    {
       
    }
    
   	function unlinkRelationship($id, $return_module, $return_id)
    {
	
    }
    public function minusBankMoney($records)
    {
         global $before_approveinfo;
        global $adb;
        if(empty($records))
        {
            return ;
        }
        $tmprecords=$records;
        if(is_array($records)&&$records[0]!="")
        {
            $tmprecords=implode(",",$records);
        }
        if($before_approveinfo['approvestatus']==constant('D_A_S_APPROVED'))
        {
            $usql = "UPDATE ld_bankaccountset
                
                    INNER JOIN ld_cashdeposit on ld_bankaccountset.Bankaccountsetid=ld_cashdeposit.outaccount
                     SET curbalancemoney=IFNULL(curbalancemoney,0)+ld_cashdeposit.cashmoney
                 WHERE ld_cashdeposit.cashdepositid in( $tmprecords )";
                $adb->pquery($usql,array());  
                
                 $usql = "UPDATE ld_bankaccountset
                
                    INNER JOIN ld_cashdeposit on ld_bankaccountset.Bankaccountsetid=ld_cashdeposit.inaccount
                     SET curbalancemoney=IFNULL(curbalancemoney,0)-ld_cashdeposit.cashmoney
                 WHERE ld_cashdeposit.cashdepositid in( $tmprecords )";
                $adb->pquery($usql,array());  
           }  
    }
      //转入账号加金额
        //转出账号减金额
    public function addBankMoney($records)
    {
       
        global $adb;
        if(empty($records))
        {
            return ;
        }
        //因为有审批状态为10，所以不宜获取审批日志
        $tmprecords=$records;
        if(is_array($records)&&$records[0]!="")
        {
            $tmprecords=implode(",",$records);
        }
        
             
            $usql = "UPDATE ld_bankaccountset
            
                INNER JOIN ld_cashdeposit on ld_bankaccountset.Bankaccountsetid=ld_cashdeposit.inaccount
                 SET curbalancemoney=IFNULL(curbalancemoney,0)+ld_cashdeposit.cashmoney
             WHERE ld_cashdeposit.cashdepositid in( $tmprecords )";
            $adb->pquery($usql,array());  
            
             $usql = "UPDATE ld_bankaccountset
            
                INNER JOIN ld_cashdeposit on ld_bankaccountset.Bankaccountsetid=ld_cashdeposit.outaccount
                 SET curbalancemoney=IFNULL(curbalancemoney,0)-ld_cashdeposit.cashmoney
             WHERE ld_cashdeposit.cashdepositid in( $tmprecords )";
            $adb->pquery($usql,array());  
        
       
       
    }
    /**
     * edit:can
     * reason:审批-》已批准
     * */
    function successApprove($record)
    {
        //转入账号加金额
        //转出账号减金额
        $this->addBankMoney(array($record));
        
    }
	 ////反审批操作
    public function rejectApproved($record)
    {
        	$this->minusBankMoney(array($record));
    }
}


?>