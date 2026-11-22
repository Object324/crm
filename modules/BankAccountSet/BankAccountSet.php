<?php

class BankAccountSet extends CRMEntity{
    static  function require_file($requiremodules='')
    {

        
            globalStatic::$arr_module_require['BankAccountSet']='BankAccountSet';
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }

    }
    var $table_name = "ld_bankaccountset";
	var $table_index= 'bankaccountsetid';//主表主键
    var $table_code='accountname';
    var $module_name='BankAccountSet';
	var $tab_name = Array('ld_crmentity','ld_bankaccountset','ld_bankaccountsetcf');

    //定义各个表主键
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_bankaccountset'=>'bankaccountsetid','ld_bankaccountsetcf'=>'bankaccountsetid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_bankaccountsetcf', 'bankaccountsetid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";
    
 //和主表关联的模块
    var $relatedtab=array('putcash'=>'','users'=>'','cashdeposit'=>'','bankaccountset'=>'');
	var $sortby_fields = Array('bankaccountsetid','accountname');


	var $list_link_field= 'bankaccountsetid';

	var $search_fields = Array(
			'Accountname'=>array('ld_bankaccountset'=>'Accountname'),
			'Assigned To'=>Array('ld_crmentity'=>'smownerid'),
			);

	var $search_fields_name = Array(
			'Account Name'=>'accountname',		
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
	var $default_order_by = 'accountname';
	var $default_sort_order = 'ASC';

	// For Alphabetical search
    //拼音查询字段
	var $def_basicsearch_col = 'accountname';
    var $popup_fields=Array();
    function __construct() {
		
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('BankAccountSet',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('BankAccountSet');
        $this->list_link_field=$entityname['fieldname'];
        $this->popup_fields=Array($this->list_link_field);
	}
    /*
    date：20130916
    reason:更多信息字段
    edit by chj
    
    function getRelated($Type)
    {
       global $adb,$current_user;
        require('user_privileges/user_language_'.$current_user->id.'.php');
       
        $tabid = getTabid('BankAccountSet');
        $SqlField = "select tablename,fieldname,case when ifnull(ld_tranlabel.fieldlabel,'')=''then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
                 from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
              left join ld_relatedlists_lable  on ld_relatedlists_lable.fieldid=ld_field.fieldid
             where languagetype=? and trantable=? and ld_tranlabel.tabid=".$tabid." and ld_field.presence in (0,2)
			 and ld_field.displaytype in (1) and ld_field.tablename != 'ld_bankaccountsetcf' order by ld_field.sequence";//ld_relatedlists_lable.presence=1 
        $result = $adb->pquery($SqlField,array($languageType,'ld_field'));
		$rows = $adb->num_rows($result);
        for($i=0;$i<$rows;$i++)
        {
            
                $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
                        "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
                    );   
                  $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
               
            
        }
    }*/
    function  save_module($module) 
    {
        global $adb,$current_user;
         //编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
        if($this->currency_status === true)
        {
            $update_query = "update ld_bankaccountset set currency_id=?, conversion_rate=?,currency_symbol=? where Bankaccountsetid=?";
    		$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
    		$this->db->pquery($update_query, $update_params);
        }
        //账户更改名称时，同步更新ld_bankaccountset_picklist表中的账户名称
        $query_accountname="select accountname from ld_bankaccountset where Bankaccountsetid=?";
        $result_contrast=$adb->pquery($query_accountname,array($this->id));
        $accountname = $adb->query_result($result_contrast,$i,'accountname');
        $update_bankaccount_picklist="update ld_bankaccountset_picklist set accountname=? where bankaccountsetid=?";
        $adb->pquery($update_bankaccount_picklist,array($accountname,$this->id));
       
    }
    
    function deletebank($recordid){
        $adb = $this->db;
        $adb->pquery("DELETE FROM ld_bankaccountset where bankaccountsetid='".$recordid."'");
       
        $adb->pquery("DELETE FROM ld_crmentity where crmid='".$recordid."'");
        $adb->pquery("DELETE FROM ld_bankaccountsetcf where Bankaccountsetid='".$recordid."'");
        $adb->pquery("DELETE FROM ld_bankaccountprofile where Bankaccountsetid='".$recordid."'");
        $adb->pquery("DELETE FROM ld_bankaccountset_picklist where Bankaccountsetid='".$recordid."'");
    }
   	function unlinkRelationship($id, $return_module, $return_id)
    {
	   parent::unlinkDependencies($id, $return_module, $return_id);
       $this->deletebank($id);
    }
    function  trash($module, $id) 
    {
        parent::trash($module,$id);
        $this->deletebank($id);
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
    $query = 'SELECT 
							ld_bankaccountset.bankaccountsetid as crmid,ld_bankaccountset.* '.$fromclause.' 
						FROM
							ld_bankaccountset 
						LEFT JOIN ld_users 
							ON ld_bankaccountset.smownerid = ld_users.id ';
		   $query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_bankaccountset.bankaccountsetid";
		   $query .= "  WHERE ld_bankaccountset.deleted = 0 " . $where;
      return $query;
    }
    
    
    
        /**
         * edit:can
         * date:reason:20140814
         * reason:获取已确认的账户列表
         * */
       static  function getBackAccount( $currency_id= '')
        {
            global $current_user,$adb;
            static $static_bankaccountids;
            if(is_array($static_bankaccountids)&& array_key_exists($currency_id,$static_bankaccountids))
            {
                //return $static_bankaccountids[$currency_id];//获取转入账户和转出账户字段
            }
            require(globalStatic::$root_directory.'user_privileges/user_privileges_'.$current_user->id.'.php');

            //针对账户字段的排序功能做特殊处理
            if($_REQUEST['modulename']){
                $currentModule=$_REQUEST['modulename'];
            }elseif($_REQUEST['module']){
                $currentModule=$_REQUEST['module'];
            }
            $tabid=getTabid($currentModule);
            $fieldname=$_REQUEST['fieldname'];
            if(empty($fieldname)){
                $fieldname = $_REQUEST['bankset_fieldname'];
                
            }
            
            //其他模块读取表ld_bankaccountset的操作
            if($is_admin==1){
                $sql="SELECT bankaccountsetid,accountname,currency_id,discontinued FROM ld_bankaccountset
                 $leftjons where discontinued='1' and confirmed='1' and deleted=0" ;
            }else{
                $sql="SELECT bankaccountsetid,accountname,currency_id,discontinued FROM ld_bankaccountset $leftjons where discontinued='1' and confirmed='1' 
                and bankaccountsetid in (SELECT bankaccountsetid FROM ld_bankaccountprofile WHERE userid='-1' or userid=$current_user->id) and deleted=0";
            }
            if($currency_id > 0){
                $sql .=" and (CASE WHEN ".$currency_id."=100000000 THEN 1=1 ELSE currency_id = " . $currency_id." END)";
            }
            $result=$adb->pquery($sql,array());
                        
            //每个模块都可以单独设置“账户”排序位置，涉及模块：收款单、付款单、费用报销单、佣金单、借款申请单、销售退款单、采购退款单、出纳提现单、出纳存现单
            if($currentModule=='Expense'||$currentModule=='CashBill'||$currentModule=='SendCashBill'||$currentModule=='Commission'||$currentModule=='PutCash'||
            $currentModule=='LoanApply'||$currentModule=='CashBack'||$currentModule=='PurchaseCashBack'||$currentModule=='CashDeposit'){
                
                //点击【账户设置】按钮，读取ld_bankaccountset_picklist表，获取账户
                if($_REQUEST['mode']=='combox'){
                    $sql_bankaccountset_picklist='select * from ld_bankaccountset_picklist 
                        INNER JOIN (select bankaccountsetid from ld_bankaccountset where discontinued = 1) as tmp on tmp.bankaccountsetid = ld_bankaccountset_picklist.bankaccountsetid
                        where tabid=? and fieldname=? order by sequence';
                    $result_bankaccountset_picklist=$adb->pquery($sql_bankaccountset_picklist,array($tabid,$fieldname));
                    $static_bankaccountids[$currency_id]=$result_bankaccountset_picklist;
                    return $result_bankaccountset_picklist;
                }
                
                //点击【新建/编辑】按钮，两表查询，插入新纪录，再读取ld_bankaccountset_picklist表，获取账户
                $sql_contrast='select ld_bankaccountset.accountname,ld_bankaccountset.bankaccountsetid,ld_bankaccountset_picklist.fieldname from  ld_bankaccountset
                            left join ld_bankaccountset_picklist  on 
                            ld_bankaccountset.bankaccountsetid=ld_bankaccountset_picklist.bankaccountsetid 
														and ld_bankaccountset_picklist.tabid=? and  ld_bankaccountset_picklist.fieldname = ?
                            where ld_bankaccountset_picklist.bankaccountsetid is null and ld_bankaccountset.confirmed=1
                            and ld_bankaccountset.discontinued="1";';
                $result_contrast=$adb->pquery($sql_contrast,array(getTabid($currentModule), $fieldname));
                $num_rows_contrast = $adb->num_rows($result_contrast);
               
                for($i = 0;$i<$num_rows_contrast;$i++){
                    $accountname = $adb->query_result($result_contrast,$i,'accountname');
                    $bankaccountsetid = $adb->query_result($result_contrast,$i,'bankaccountsetid');
                    
                    $sql_insert="insert into ld_bankaccountset_picklist(tabid,fieldname,bankaccountsetid,accountname,sequence) SELECT '$tabid','$fieldname','$bankaccountsetid','$accountname','$bankaccountsetid' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_bankaccountset_picklist WHERE tabid=? AND fieldname=? AND bankaccountsetid=?)";
                    $adb->pquery($sql_insert,array($tabid,$fieldname,$bankaccountsetid));
                }
                $sql_bankaccountset_picklist='select ld_bankaccountset_picklist.*,discontinued from ld_bankaccountset_picklist
                 inner join ld_bankaccountset on ld_bankaccountset.bankaccountsetid=ld_bankaccountset_picklist.bankaccountsetid
                  where ld_bankaccountset.deleted=0 and  tabid=? and fieldname=? ';
                  if($currency_id > 0){
                        $sql_bankaccountset_picklist .=" and (CASE WHEN ".$currency_id."=100000000 THEN 1=1 ELSE ld_bankaccountset.currency_id = " . $currency_id." END)";
                 }
                 //zkt 20230216 BUG0061713收款单新建界面，普通成员仍然可以看见账户权限外的“银行账户”，如（如 支）
                 if($is_admin!=1){
                    $sql_bankaccountset_picklist .=" and ld_bankaccountset.bankaccountsetid in (SELECT bankaccountsetid FROM ld_bankaccountprofile WHERE userid='-1' or userid=$current_user->id) ";
                 }
                 $sql_bankaccountset_picklist.='    and ld_bankaccountset.discontinued="1"';
                 $sql_bankaccountset_picklist.=' order by ld_bankaccountset_picklist.sequence ';
                $result_bankaccountset_picklist=$adb->pquery($sql_bankaccountset_picklist,array($tabid,$fieldname));
                $static_bankaccountids[$currency_id]=$result_bankaccountset_picklist;
              
                return $result_bankaccountset_picklist;           
                
            }
            $static_bankaccountids[$currency_id]=$result;
            return $result;
        }
        
        /**
         * reason:通过id获取已确认的账户名称
         * */
        static  function getBackAccountNameById($id)
        {
            $value = $id;
            global $current_user,$adb;
            static $static_bankaccountids;
            $sql = "SELECT bankaccountsetid,accountname FROM ld_bankaccountset
                 where confirmed='1' and deleted=0 and bankaccountsetid=?;";
            $result = $adb->pquery($sql,array($id));
            $rows = $adb->num_rows($result);
            if($rows>0){
                $value = $adb->query_result($result,0,'accountname');
                return $value;
            }
            else{
                return $value;
            }
        }
        
        
        
        static function  ResetMoney()
        {
            //重算银行账户余额
            
            global $adb;
            
            $sql="UPDATE ld_bankaccountset a
                    LEFT JOIN (
                    	SELECT
                    		a.bankaccountsetid,
                    		SUM(a.Total) AS Total
                    	FROM ld_cashbill a
                    	WHERE a.deleted=0
                    		AND a.approvestatus<>'已拒绝'
                    		AND (
                    			CASE
                    				WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=83 AND deploy_value=0) THEN 1=1
                    				ELSE a.approvestatus='已批准'
                    			END)
                    	GROUP BY a.bankaccountsetid
                    ) s1 ON a.Bankaccountsetid=s1.bankaccountsetid
                    LEFT JOIN (
                    	SELECT
                    		a.bankaccountsetid,
                    		SUM(a.Total) AS Total
                    	FROM ld_sendcashbill a
                    	WHERE a.deleted=0
                    		AND a.approvestatus<>'已拒绝'
                    		AND (
                    			CASE
                    				WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=84 AND deploy_value=0) THEN 1=1
                    				ELSE a.approvestatus='已批准'
                    			END)
                    	GROUP BY a.bankaccountsetid
                    ) z1 ON a.Bankaccountsetid=z1.bankaccountsetid
                    LEFT JOIN (
                    	SELECT
                    		a.inaccount,
                    		SUM(a.cashmoney) AS total
                    	FROM ld_cashdeposit a
                    	WHERE a.deleted=0
                    		AND a.approvestatus='已批准'
                    	GROUP BY a.inaccount
                    ) s2 ON a.Bankaccountsetid=s2.inaccount
                    LEFT JOIN (
                    	SELECT
                    		a.Outaccount,
                    		SUM(a.cashmoney) AS total
                    	FROM ld_cashdeposit a
                    	WHERE a.deleted=0
                    		AND a.approvestatus='已批准'
                    	GROUP BY a.Outaccount
                    ) z2 ON a.Bankaccountsetid=z2.Outaccount
                    LEFT JOIN (
                    	SELECT
                    		a.inaccount,
                    		SUM(a.cashmoney) AS total
                    	FROM ld_putcash a
                    	WHERE a.deleted=0
                    		AND a.approvestatus='已批准'
                    	GROUP BY a.inaccount
                    ) s3 ON a.Bankaccountsetid=s3.inaccount
                    LEFT JOIN (
                    	SELECT
                    		a.Outaccount,
                    		SUM(a.cashmoney) AS total
                    	FROM ld_putcash a
                    	WHERE a.deleted=0
                    		AND a.approvestatus='已批准'
                    	GROUP BY a.Outaccount
                    ) z3 ON a.Bankaccountsetid=z3.Outaccount
                    LEFT JOIN (
                    	SELECT
                    		a.bankaccountsetid,
                    		SUM(a.total) AS total
                    	FROM ld_purchasecashback a
                    	WHERE a.deleted=0
                    	GROUP BY a.bankaccountsetid
                    ) s4 ON a.Bankaccountsetid=s4.bankaccountsetid
                    LEFT JOIN (
                    	SELECT
                    		a.bankaccountsetid,
                    		SUM(a.total) AS total
                    	FROM ld_cashback a
                    	WHERE a.deleted=0
                    	GROUP BY a.bankaccountsetid
                    ) z4 ON a.Bankaccountsetid=z4.bankaccountsetid
                    LEFT JOIN (
                    	SELECT
                    		a.bankaccountsetid,
                    		SUM(a.total) AS total
                    	FROM ld_expense a
                    	WHERE a.deleted=0
                    		AND a.approvestatus='已批准'
                    	GROUP BY a.bankaccountsetid
                    ) z5 ON a.Bankaccountsetid=z5.bankaccountsetid
                    LEFT JOIN (
                    	SELECT
                    		a.bankaccountsetid,
                    		SUM(a.total) AS total
                    	FROM ld_commission a
                    	WHERE a.deleted=0
                    		AND a.approvestatus='已批准'
                    	GROUP BY a.bankaccountsetid
                    ) z6 ON a.Bankaccountsetid=z6.bankaccountsetid
                    SET a.curbalancemoney=IFNULL(a.InitMoney,0)+IFNULL(s1.Total,0)+IFNULL(s2.Total,0)+IFNULL(s3.Total,0)+IFNULL(s4.Total,0)-IFNULL(z1.Total,0)-IFNULL(z2.Total,0)-IFNULL(z3.Total,0)-IFNULL(z4.Total,0)-IFNULL(z5.Total,0)-IFNULL(z6.Total,0); ";
                    
            $adb->pquery($sql,array());

        }
}
BankAccountSet::require_file();

?>