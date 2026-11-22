<?php

class FundReward extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['FundReward']='FundReward';
           
            if(empty(globalStatic::$arr_module_require['Activity']))
            {
                globalStatic::$arr_module_require['Activity']='Activity';
                include(globalStatic::$root_directory.'modules/Calendar/Activity.php');
                
            }
         
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }
    }
    
	var $log;
	var $db;
    var $module_name='FundReward';
	var $table_name = "ld_fund_reward";
	var $table_index= 'rewardid';
	//'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
	//'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
	//'ld_customerdetails'=>'customerid'
	var $tab_name = Array('ld_crmentity','ld_fund_reward','ld_fund_rewardcf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_fund_reward'=>'rewardid','ld_fund_rewardcf'=>'rewardid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_fund_rewardcf', 'rewardid');

	var $column_fields = Array();
    
	var $sortby_fields = Array();

	var $list_link_field= 'reward_no';
    var $relatedtab=array();



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
	var $def_basicsearch_col = 'reward_no';

	function __construct() {
	
		$this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('FundReward',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('FundReward');
        $this->list_link_field=$entityname['fieldname'];
	}
    	/**
	 * 增加getrelated方法
	 * @reason 0010111 快速查找报新公告缺少方法
	 * @author Tujt 2014-07-17
	 
    function getRelated($Type)
    {
        global $adb,$current_user;
        require('user_privileges/user_language_'.$current_user->id.'.php');
       
        $tabid = getTabid('FundReward');
        $SqlField = "select tablename,fieldname,case when ifnull(ld_tranlabel.fieldlabel,'')=''then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
                 from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
              left join ld_relatedlists_lable  on ld_relatedlists_lable.fieldid=ld_field.fieldid
             where languagetype=? and trantable=? and ld_tranlabel.tabid=".$tabid." and ld_field.presence in (0,2)
			 and ld_field.displaytype in (1) order by ld_field.sequence";//ld_relatedlists_lable.presence=1 
        $result = $adb->pquery($SqlField,array($languageType,'ld_field'));
		$rows = $adb->num_rows($result);
        for($i=0;$i<$rows;$i++)
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
     public function   trash($module, $id)
    {
            global $adb;
            $sql=" select group_concat(ld_fund_buyproductquantityhistory.id) from ld_fund_buyproductquantityhistory INNER JOIN 
            ld_fund_reward on ld_fund_reward.product_id=ld_fund_buyproductquantityhistory.productid and ld_fund_reward.accountid=ld_fund_buyproductquantityhistory.accountid
        and ld_fund_reward.basedate=date_format(ld_fund_buyproductquantityhistory.operationtime,'%Y-%m-%d')
            where ld_fund_reward.rewardid=?  and ld_fund_buyproductquantityhistory.redemption_type='program'";
            $result =$adb->pquery($sql,array($id)) ;
            if($adb->num_rows($result)>0)
            {
                $ids=$adb->query_result($result,0,0);
                $sql='delete from ld_fund_buyproductquantityhistory where id in( '.$ids.')';
                $adb->pquery($sql,array());
                
            }
        
         
          $sql='select group_concat(ld_fund_accured_history_detail.id) from ld_fund_accured_history
                        inner join ld_fund_accured_history_detail on ld_fund_accured_history.id=ld_fund_accured_history_detail.fund_accured_historyid
                        inner join ld_fund_reward on ld_fund_accured_history.type=?   
                        and  ld_fund_reward.product_id=ld_fund_accured_history.productid and ld_fund_accured_history_detail.accountid=ld_fund_reward.accountid
                        and ld_fund_reward.basedate=ld_fund_accured_history_detail.accured_date
                where ld_fund_reward.rewardid=?';
        
           $result =$adb->pquery($sql,array('FundReward',$id)) ;
           if($adb->num_rows($result)>0)
           {
                $detail_ids=$adb->query_result($result,0,0);
                //$sql='delete from ld_fund_accured_history  where id in( '.$accured_ids.')';
                //$result=$adb->pquery($sql,array());
                $sql='delete from ld_fund_accured_history_detail where id in( '.$detail_ids.')';
                $result=$adb->pquery($sql,array());
           }
           
            $sql='select  GROUP_CONCAT(ld_fund_accured_history.id) from ld_fund_accured_history   LEFT JOIN ld_fund_accured_history_detail
                on ld_fund_accured_history.id=ld_fund_accured_history_detail.fund_accured_historyid 
                where ld_fund_accured_history.type=?  and fund_accured_historyid is null;';
              $result =$adb->pquery($sql,array('FundReward')) ;
             if($adb->num_rows($result)>0)
             {
                $ids=$adb->query_result($result,0,0);
                $sql='delete from ld_fund_accured_history where id in('.$ids.' )';
                $adb->pquery($sql,array());
             }
             
           
           $sql="select GROUP_CONCAT(ld_fund_reward_low_water.salesorderid) from ld_fund_reward_low_water 
        INNER JOIN ld_fund_reward on ld_fund_reward_low_water.module=? and  ld_fund_reward.product_id=ld_fund_reward_low_water.productid 
         and ld_fund_reward_low_water.accured_date =ld_fund_reward.basedate
        INNER JOIN ld_salesorder on ld_salesorder.salesorderid=ld_fund_reward_low_water.salesorderid
         and ld_salesorder.accountid=ld_fund_reward.accountid
        where  ld_fund_reward.rewardid=?";//份额缩减法删除程序生成赎回单
        $result=$adb->pquery($sql,array('FundReward',$id));
            if($adb->num_rows($result)>0)
                {
                    $salesorderids=$adb->query_result($result,0,0);
                    $sql='delete from ld_fund_redemption  where salesorder_id in('.$salesorderids.')';
                    $result=$adb->pquery($sql,array());
                    
                }
            $sql='select group_concat(ld_fund_reward_low_water.fund_reward_low_waterid) from ld_fund_reward
                INNER JOIN ld_fund_reward_low_water
                 on ld_fund_reward_low_water.module=? and ld_fund_reward_low_water.productid=ld_fund_reward.product_id
                	   and ld_fund_reward.basedate=ld_fund_reward_low_water.accured_date
                INNER JOIN ld_salesorder on ld_salesorder.salesorderid=ld_fund_reward_low_water.salesorderid
                and ld_salesorder.accountid=ld_fund_reward.accountid
                where ld_fund_reward.rewardid=? ';
            $result=$adb->pquery($sql,array('FundReward',$id));
            if($adb->num_rows($result)>0)
                {
                    $fund_reward_low_waterids=$adb->query_result($result,0,0);
                    $sql='delete from ld_fund_reward_low_water  where fund_reward_low_waterid in('.$fund_reward_low_waterids.')';
                    $result=$adb->pquery($sql,array());
                    
                }
            $sql='delete from ld_crmentity where crmid=?';
            $result=$adb->pquery($sql,array($id));
            $sql='delete from ld_fund_reward where rewardid=?';
            $result=$adb->pquery($sql,array($id));
            $sql='delete from ld_fund_rewardcf where rewardid=?';
            $result=$adb->pquery($sql,array($id));
                   
    }
       /**
     * 重算日志
     * */
    public function getRecalculate_log($id, $cur_tab_id, $rel_tab_id, $actions=false)
    {
        crm_load_class_file('cls_Jijin_logshow','include/trade/Jijin');
        $obj=new cls_Jijin_logshow('FundReward',$id);
        return $obj->getRecalculate_log();
        
    }
   	function save_module($module){

    }
    
   /**
     * 计提保存
     * */
    public function save_accured()
    {
       cls_fund_save_accured::save($this);
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
     $query = "SELECT distinct ld_fund_reward.rewardid as crmid,ld_users.last_name " .$fromclause .
			",ld_fund_reward.* FROM ld_fund_reward
                        LEFT JOIN ld_fund_rewardcf on ld_fund_reward.rewardid=ld_fund_rewardcf.rewardid
			LEFT JOIN ld_account
				ON ld_account.accountid = ld_fund_reward.accountid 
			left join ld_accountscf 
				on ld_accountscf.accountid = ld_account.accountid 
			LEFT JOIN ld_users
				ON ld_users.id = ld_fund_reward.smownerid
            LEFT JOIN ld_products on ld_products.productid=ld_fund_reward.product_id   ";
                
		
            
        if(isset($_REQUEST['type']) && $_REQUEST['type']=='alpbt')
            {
                $query .=" inner join  ld_cosler c on ((CONV(HEX(convert(left( ld_fund_reward.";
                $query .= $_REQUEST['search_field']." , 1) using gbk)),16,10) between c.cBegin and c.cEnd and f_PY like '".$_REQUEST['search_text']."%') or ld_contactdetails.". $_REQUEST['search_field']." like '". $_REQUEST['search_text']."%') ";
                
            }
			$query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_fund_reward.rewardid";
			$query .= "  WHERE ld_fund_reward.deleted = 0  and ld_products.productname like '%".$_REQUEST['query_string']."%'" . $where; 
            
            return $query;  
    }
}
FundReward::require_file();
?>