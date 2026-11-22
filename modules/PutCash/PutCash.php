<?php
class PutCash extends CRMEntity{
    var $table_name = "ld_putcash";
	var $table_index= 'putcashid';//主表主键
    var $table_code='putcash_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_putcash','ld_putcashscf');
    var $module_name='PutCash';
    //定义各个表主键
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_putcash'=>'putcashid','ld_putcashscf'=>'putcashid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_putcashscf', 'putcashid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";

	var $column_fields = Array();
 //和主表关联的模块
    var $relatedtab=array('putcash'=>'','users'=>'','bankaccountset'=>'');
	var $sortby_fields = Array('putcashid','putcash_no');
    public $db;
	//var $groupTable = Array('lingdang_accountgrouprelation','accountid');

	// 叙事簿列头或者视图列头。include/util/listviewutils/getListviewHeader()中用到该变量
	/*var $list_fields = Array(
		
			'Expense No'=>Array('ld_expense'=>'expense_no'),
			'expensedate'=>Array('ld_expense'=>'expensedate'),
            'numcount'=>array('ld_expense'=>'numcount'),
            'Sales Order'=>array('ld_expense'=>'salesorderid'),
            'Total'=>array('ld_expense'=>'total'),
			'Assigned To'=>Array('ld_crmentity'=>'smownerid')
			);

	var $list_fields_name = Array(
			
			'Expense No'=>'expense_no',
			'expensedate'=>'expensedate',
			'numcount'=>'numcount',
            'Sales Order'=>'salesorder_id',
            'Total'=>'hdnGrandTotal',
			'Assigned To'=>'assigned_user_id'
			);*/
	var $list_link_field= 'putcash_no';

	var $search_fields = Array(
			'Putcash No'=>array('ld_putcash'=>'putcash_no'),
			'Assigned To'=>Array('ld_crmentity'=>'smownerid'),
			);

	var $search_fields_name = Array(
			'Putcash No'=>'putcash_no',	
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
	var $default_order_by = 'putcash_no';
	var $default_sort_order = 'ASC';

	// For Alphabetical search
    //拼音查询字段
	var $def_basicsearch_col = 'putcash_no';
    var $popup_fields=Array();
    function __construct() {
	//	$this->log =LoggerManager::getLogger('PutCash');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('PutCash',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
           /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('PutCash');
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
        global $adb;
        global $before_approveinfo;
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
            //转出账户
                $usql = "UPDATE ld_bankaccountset
                    
                        INNER JOIN ld_putcash on ld_bankaccountset.Bankaccountsetid=ld_putcash.outaccount
                         SET curbalancemoney=IFNULL(curbalancemoney,0)+ld_putcash.cashmoney
                     WHERE ld_putcash.putcashid in( $tmprecords )";
                    $adb->pquery($usql,array());  
                //转入账户
                     $usql = "UPDATE ld_bankaccountset
                    
                        INNER JOIN ld_putcash on ld_bankaccountset.Bankaccountsetid=ld_putcash.inaccount
                         SET curbalancemoney=IFNULL(curbalancemoney,0)-ld_putcash.cashmoney
                     WHERE ld_putcash.putcashid in( $tmprecords )";
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
        //转入账户
             
            $usql = "UPDATE ld_bankaccountset
            
                INNER JOIN ld_putcash on ld_bankaccountset.Bankaccountsetid=ld_putcash.inaccount
                 SET curbalancemoney=IFNULL(curbalancemoney,0)+ld_putcash.cashmoney
             WHERE ld_putcash.putcashid in( $tmprecords )";
            $adb->pquery($usql,array());  
             //转出账户
             $usql = "UPDATE ld_bankaccountset
            
                INNER JOIN ld_putcash on ld_bankaccountset.Bankaccountsetid=ld_putcash.outaccount
                 SET curbalancemoney=IFNULL(curbalancemoney,0)-ld_putcash.cashmoney
             WHERE ld_putcash.putcashid in( $tmprecords )";
            $adb->pquery($usql,array());  
        
       
       
    }
    
    /**
     * edit:can
     * reason:审批-》已批准
     * */
    function successApprove($record)
    {
        /*
        global $adb;
        $smongysql = "SELECT inaccount,outaccount,cashmoney FROM ld_putcash WHERE putcashid=$record";
        $result = $adb->pquery($smongysql);
        $account = $adb->query_result($result,0,'outaccount');
        $monery = $adb->query_result($result,0,'cashmoney');
        $account2 = $adb->query_result($result,0,'inaccount');
        $usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)-$monery WHERE bankaccountsetid=$account";
        $adb->pquery($usql,array());
        $usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)+$monery WHERE bankaccountsetid=$account2";
        $adb->pquery($usql,array());*/
        $this->addBankMoney(array($record));
        
    }
     ////反审批操作
    public function rejectApproved($record)
    {
        	$this->minusBankMoney(array($record));
    }
	/*
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
    $query = 'SELECT 
							ld_putcash.putcashid as crmid,ld_putcash.* '.$fromclause.' 
						FROM
							ld_putcash 
						LEFT JOIN ld_users 
							ON ld_putcash.smownerid = ld_users.id 
						LEFT JOIN ld_putcashscf 
							on ld_putcashscf.putcashid = ld_putcash.putcashid 
						left join ld_bankaccountset as ld_obank 
							on ld_obank.bankaccountsetid = ld_putcash.outaccount 
						left join ld_bankaccountset as ld_ibank 
							on ld_ibank.bankaccountsetid = ld_putcash.inaccount ';
		   $query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_putcash.putcashid";
		   $query .= " WHERE ld_putcash.deleted = 0 " . $where;
     return $query;
    }*/
    
}


?>