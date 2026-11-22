<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/



class ServiceContracts extends CRMEntity {
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['ServiceContracts']='ServiceContracts';
         if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
	var $db, $log; // Used in class functions of CRMEntity
    var $Detail_table="ld_servicecontractsdetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_servicecontractsdetailscf";//明细scf表
     var $Detail_table_index="id";//明细表和主表关联的字段
	var $table_name = 'ld_servicecontracts';
	var $table_index= 'servicecontractsid';
	var $column_fields = Array();
    var $module_name='ServiceContracts';
	/** Indicator if this is a custom module or standard module */
	var $IsCustomModule = true;

	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_servicecontractscf', 'servicecontractsid');

	/**
	 * Mandatory for Saving, Include tables related to this module.
	 */
	var $tab_name = Array('ld_crmentity', 'ld_servicecontracts', 'ld_servicecontractscf');
      /*
    edit:can
    date:20131024
    reason:打印关联模块
    */
    var $relatedtab=array('servicecontracts'=>'','users'=>'','company'=>'','accounts'=>'','contacts'=>'','products'=>'');
	/**
	 * Mandatory for Saving, Include tablename and tablekey columnname here.
	 */
	var $tab_name_index = Array(
		'ld_crmentity' => 'crmid',
		'ld_servicecontracts' => 'servicecontractsid',
		'ld_servicecontractscf'=>'servicecontractsid'
        );

	
	var $list_fields_name = Array (
		/* Format: Field Label => fieldname */
		'Subject' => 'subject',
		'Assigned To' => 'assigned_user_id',
		'Contract No' =>  'contract_no',
		'Used Units' => 'used_units',
		'Total Units' => 'total_units'
	);

	// Make the field link to detail view
	var $list_link_field = 'subject';



	// For Popup window record selection
	var $popup_fields = Array ('subject');

	// Placeholder for sort fields - All the fields will be initialized for Sorting through initSortFields
	var $sortby_fields = Array('subject');

	// For Alphabetical search
    //[销售通] 服务合同叙事簿界面：基本查找中，按拼音首字母查找，无法查找到数据 
    //更改成根据服务合同的编号进行查询var $def_basicsearch_col = 'subject';
	var $def_basicsearch_col = 'contract_no';

	// Column value to use on detail view record text display
	var $def_detailview_recname = 'subject';

	// Required Information for enabling Import feature
	var $required_fields = Array ('assigned_user_id'=>1);

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
    var $mandatory_fields = Array('assigned_user_id');
	//var $mandatory_fields = Array('subject','assigned_user_id');

	// Callback function list during Importing
	var $special_functions = Array('set_import_assigned_user');

	var $default_order_by = 'subject';
	var $default_sort_order='ASC';
	public $table_code = 'contract_no';

	function __construct() {
		
		
		$this->db = new PearDatabase();
        $this->fieldobj=Field::getInstance('ServiceContracts',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
		
          /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('ServiceContracts');
        $this->list_link_field=$entityname['fieldname'];
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
	}
   
	function save_module($module) {
	   global $adb,$ServiceContractsPreremind;
        
		$return_action = $_REQUEST['return_action'];
		$for_module = $_REQUEST['return_module'];
		$for_crmid  = $_REQUEST['return_id'];
		if ($return_action && $for_module && $for_crmid) {
			if ($for_module == 'HelpDesk') {
				$on_focus = CRMEntity::getInstance($for_module);
				$on_focus->save_related_module($for_module, $for_crmid, $module, $this->id);
                /**
                 * edit:can
                 * reason:8879: 服务单明细界面：相关信息，新建服务合同，新窗口保存后，跳转到服务单界面了
                 * */
                $_REQUEST['return_id']=$this->id;
                $_REQUEST['return_module']='ServiceContracts';
                
			}
		}
        if($_REQUEST['action'] != 'ServiceContractsAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
			//Based on the total Number of rows we will save the product relationship with this entity
			//服务合同明细保存
            //crm_load_function_file("saveInventoryProductDetails",'include/utils','InventoryUtils'); 
            //saveInventoryProductDetails($this, 'ServiceContracts');
            
            crm_load_class_file('saveInventory','include/utils');
            $saveInventoryobj=new saveInventory();
            $saveInventoryobj->save($this, 'ServiceContracts');
		}
        
        //放在函数的最下面，等待主表更新total字段更新完成
        crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
        cls_Source_InverseCompute::Source_InveverseCompute($module,$this->id,$this);
		$deployarray=getSys_deploy(48);//灵当CRM详细需求-参数控制出入库单更新库存流水记录触发点  0：审核  1：保存
		crm_load_class_file('cls_OutSale_InverseCompute','include/OptionModule');
        
		if($deployarray['deploy_value']== 1){
			cls_OutSale_InverseCompute::updateSourceModuleOutboundAmount($this->id,$module);
		}
        $detailtable=$this->Detail_table;
        //新增服务合同，给contractid赋值  edit:xiaoshun  date:2016-09-01
        $sql = "update $detailtable set contractid = id where id = ?";
        $adb->pquery($sql,array($this->id));
        
        
		// Update the currency id and the conversion rate for the sales order
		//编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
		if($this->currency_status === true)
		{
			$update_query = "update ld_servicecontracts set currency_id=?, conversion_rate=?,currency_symbol=? where servicecontractsid=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}
		
		
		//XUQIU1000855:服务合同增加数量合计 Add by luyx at 2022-11-10 
		$sql="UPDATE ld_servicecontracts a 
			INNER JOIN (
				SELECT 
					id,
					SUM(IFNULL(quantity,0)) AS totalquantity
				FROM ld_servicecontractsdetail
				WHERE id=?
				GROUP BY id
			) b ON b.id=a.servicecontractsid
			SET 
				a.totalquantity=IFNULL(b.totalquantity,0),
				a.balanceoutboundcount=IFNULL(b.totalquantity,0)-IFNULL(a.haveoutboundcount,0),
				a.balanceoutboundamount=ROUND(IFNULL(a.total,0)-IFNULL(a.haveoutboundamount,0),2);";
		$adb->pquery($sql,array($this->id));

		$sql="UPDATE ld_servicecontracts SET triggercount=triggercount+1 WHERE servicecontractsid=?";
		$adb->pquery($sql,array($this->id));			
		
        $date_now = date("Y-m-d");
        $date_unix= strtotime($date_now);

        if(!is_numeric($ServiceContractsPreremind)){
            $ServiceContractsPreremind = 0;
        }
        $date_sz=60*60*24*$ServiceContractsPreremind;
      
        $date_bg=$date_unix-$date_sz;//间隔unix时间戳(服务合同中产品服务到期前N天提醒应该减掉变量$date_sze)
        if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] > 0)
            $id = $_REQUEST['return_id'];
        else
            $id = $this->id;
        $sql = "select ld_servicecontracts.contract_no,$detailtable.servicecontracts_end_date,ld_account.accountname,ld_products.productname from ld_servicecontracts
                inner join $detailtable on $detailtable.id = ld_servicecontracts.servicecontractsid
                inner join ld_products on ld_products.productid = $detailtable.productid
                left join ld_account on ld_account.accountid = ld_servicecontracts.accountid
                where ld_servicecontracts.servicecontractsid =?";
        $result = $adb->pquery($sql,array($id));
        $num_rows = $adb->num_rows($result);
        
        /* duan 20240305 修复服务合同小编辑后,所有的审批提醒被删除的问题
         //首先删除该服务合同关联的未读的提醒
        $sqldelete="delete from ld_reminds where related_to='$id' and status_rmd='未读'";
        
        $adb->query($sqldelete);
        
        $sqldelete="delete from ld_reminds_accepted where related_to='$id' and status_rmd='未读'";
        $adb->query($sqldelete);
        */

        for($i = 0; $i<$num_rows; $i++)
        {
            $end_date = $adb->query_result($result,$i,'servicecontracts_end_date');
            $accountname = $adb->query_result($result,$i,'accountname');
            $contract_no = $adb->query_result($result,$i,'contract_no');
            $productname = $adb->query_result($result,$i,'productname');
          
            if(strtotime($end_date) >= $date_bg) 
            {
                if(isset($accountname))
                    $accountname = $accountname .getFixedLabel('DE');
                $RemindsContent=getFixedLabel('PRODUCTSERVICEEXPIRATIONREMINDER')." ".$accountname." ".getTranstab('ServiceContracts')." ".$contract_no." ".getFixedLabel('PRODUCTSSPIRITWHEN')." ".$productname." ";
                $RemindsContent.=getFixedLabel('WILLEXPIREAT')." ".$end_date." ".getFixedLabel('PLEASEFOLLOWUPINATIMELYMANNER');
                $datetime=date("Y-m-d",strtotime($end_date) - $date_sz);
                $this-> AddReminds($RemindsContent,$datetime,'',$id);
                
            }
        }
     
       $deploy_arr=  getSys_deploy(47);
        $deploy_value=$deploy_arr['deploy_value'];//服务合同是否启用审批流程。1:否，0:是

       //获取客户的最大服务到期日
       if($deploy_value==1){
           $end_accountid_enable = $this->end_accountid_enable();
           $accountid = $end_accountid_enable == "yes"?$_REQUEST['end_accountid']:$_REQUEST['account_id'];
           $this->getMaxServicDate($accountid);


       }

        /**
         * edit:kevin
         * date:2013-07-22
         * reason:相关客户是否是已分配,分配则改变客户信息
         */
        /* if(isset($_REQUEST['account_id'])){
		//	require_once(globalStatic::$root_directory."modules/Accounts/Accounts.php");
			$account=CRMEntity::getInstance('Accounts');
            
			$account->updateAccountInfo("ServiceContracts",$_REQUEST['account_id']);  
        }
         */
        if(strtolower($this->mode)!='edit')
        {
            $this->autocreateCasbhill($this->id,'create');
        }
        else
       {
        
             //编辑单据反写收款单明细字段
            $sendfocus = CRMEntity::getInstance('CashBill');
            $sendfocus->updateSourceInfo($this->id,'ServiceContracts');
       }
       
          if($_REQUEST['Create'] == 'yes' && $_REQUEST['contract_status'] != '已作废')
        {
           //获取系统参数缓存文件值
            $deployarray=getSys_deploy(161);//设置服务合同新增保存后是否更新客户的客户状态字段为
            $deploy_value_161 = $deployarray['deploy_value'];
            
            if($deploy_value_161 != '' && $_REQUEST['account_id'] != '' && $deploy_value_161 != '')
            {
				$query = 'select rating from ld_account where accountid = ? limit 1';
				$result = $adb->pquery($query,array($_REQUEST['account_id']));
				$rating = $adb->query_result($result,0,0);
				$tabid = getTabid('Accounts');
				$query = "select 1 from ld_settings_advance where tabid = ? and module_field = 'rating' and `enable` = 'yes'";
				$result = $adb->pquery($query,array($tabid));
				$num_rows = $adb->num_rows($result);
				if($num_rows >= 1){
					$adb->pquery("UPDATE ld_account set rating = '".$deploy_value_161."' ,advance_stage = '".$deploy_value_161."',modifiedtime ='".date('Y-m-d H:i:s')."' where accountid =".$_REQUEST['account_id'],array());
				}else{
					$adb->pquery("UPDATE ld_account set rating = '".$deploy_value_161."' ,modifiedtime ='".date('Y-m-d H:i:s')."' where accountid =".$_REQUEST['account_id'],array());
				}
				$account_focus = CRMEntity::getInstance('Accounts');
				$account_focus->SyncAccountToBangwoba($_REQUEST['account_id'],'create');
				if($rating != $deploy_value_161){
					$focus = CRMEntity::getInstance('Accounts');
					$time = date('Y-m-d H:i:s',time());$status = 0;
					$modtrackerId = $adb->getUniqueID('ld_modtracker_basic');
					$query = 'insert into ld_modtracker_basic(id,crmid,module,whodid,changedon,status) values (?,?,?,?,?,?);';
					$adb->pquery($query,array($modtrackerId,$_REQUEST['account_id'],'Accounts',-1,$time,$status));
					//}
					$query = 'insert into ld_modtracker_detail(id,fieldname,prevalue,postvalue) values(?,?,?,?);';

					$adb->pquery($query,array($modtrackerId,'rating',$rating,$deploy_value_161));
					//$focus->getModuleStatic('ModTracker');//字段修改日志
					//$focus->modstatic->saveFieldLogOne('Accounts','rating',$_REQUEST['account_id'],$rating, $deploy_value_161);
				}
            }
        }
        //zxm @date:2024/10/21 @reason: 保存合同之后删除购物车
        $cartid_str =$_REQUEST['cartid'];
        if(!empty($cartid_str)){
            crm_load_class_file('Shopcart','modules/Products');
            $shopcartobj = new Shopcart();
            $shopcartobj->mass_deletecart("",$cartid_str);
        }
	}
    
    /*
    根据系统参数控制自动创建收款单
    */
    public function autocreateCasbhill($servicecontractid,$operationtype)
    {
        global  $adb;
        $deploy_values=getSys_deploy(163);
        $deploy_value=$deploy_values['deploy_value'];
        if(empty($deploy_value))
        {
            return ;
        }
        else if($deploy_value==1 || $deploy_value == 3) //wym 240223 XUQIU20240204-05 免费的 销售订单/服务合同 可以设置不生成收款单
        {
            if(strtolower($this->mode)=='edit'||$operationtype!='create')
            {
                return false;
            }
            
        }
        else if($deploy_value==2 || $deploy_value == 4)
        {
            if($operationtype!='approve')
            {
                return false;
            }
            
        }
        crm_load_class_file("CashBill","modules/CashBill");
       
		$this->retrieve_entity_info($servicecontractid,$this->module_name);
       
        $cashbillfocus=new CashBill();
       
        $_REQUEST['account_id']=$this->column_fields['account_id'];
        $_REQUEST['currency_id']=$this->column_fields['currency_id'];
        $_REQUEST['entitytypeid1']=$servicecontractid;
        $_REQUEST['deleterow1']=0;
        //editor:gyq_161 reason:本次收款金额Key值改动   2019/11/26 18:46
        //$_REQUEST['curCashBill1']=$this->column_fields['receivable_balance'];
        if(array_key_exists('receivable_balance',$this->column_fields))
            $_REQUEST['amount1']=$this->column_fields['receivable_balance'];
        else
        {
            $sql='select receivable_balance from ld_servicecontracts where servicecontractsid=?';
            $result=$adb->pquery($sql,array($servicecontractid));
             $_REQUEST['amount1']=$adb->query_result($result,0,'receivable_balance');
             $this->column_fields['receivable_balance']=$adb->query_result($result,0,'receivable_balance');
        }
        //wym 240223 XUQIU20240204-05 免费的 销售订单/服务合同 可以设置不生成收款单
        if ($deploy_value == 3 || $deploy_value == 4) {
            if((int)$_REQUEST['amount1']==0) {
                return false;
            }
        }
        $_REQUEST['selectsource']=$this->module_name;
        $_REQUEST['selectsourcename'] = $this->module_name;
        $_REQUEST['detail_sequence1']=1;
        $_REQUEST['selectlistval']=$servicecontractid;//048450: （www.ycjdy.cn）（客户问题-蔡云桥）服务合同自动生成的收款单，收款单没有显示关联源单和分录中源单金额等信息
        $_REQUEST['cashbill_total']=$this->column_fields['receivable_balance'];
        $smownerfieldname=$this->fieldobj->getFieldInfoBykeyValue("uitype",53,'fieldname');
        $cashbillsmownerfieldname=$cashbillfocus->fieldobj->getFieldInfoBykeyValue("uitype",53,'fieldname');
        $_REQUEST[$cashbillsmownerfieldname] =$this->column_fields[$smownerfieldname];
        $cashbillfocus->autocreateCasbhill($this);
        
        
    }
    
    public function restore($module, $id)
    {
        parent::restore($module,$id);
        global $adb;
        $this->id=$id;
        $end_accountid_enable = $this->end_accountid_enable();
        if($end_accountid_enable == "yes"){
            $sql='select end_accountid from ld_servicecontracts where servicecontractsid=?';
        }else{
            $sql='select accountid from ld_servicecontracts where servicecontractsid=?';
        }
        $result=$adb->pquery($sql,array($id));
        if($adb->num_rows($result)>0)
        {
            $accountid=$adb->query_result($result,0,0);
            $this->getMaxServicDate($accountid);
        }
    }
    function special_ImportXls()
    {
        global $adb;
        $_REQUEST['action']= 'ServiceContractsAjax';
         $sql='select accountid from ld_servicecontracts where servicecontractsid=?';
        $result=$adb->pquery($sql,array($this->id));
        if($adb->num_rows($result)>0)
        {
            
            $_REQUEST['account_id']=$adb->query_result($result,0,"accountid");
        }
        
        $this->save_module();
    }
     function massChangeOrder_after($module,$ids)
    {
        if(!is_array($ids))
        {
            $ids=explode(',',$ids);
        }
        global $adb;
         $deploy_arr=  getSys_deploy(47);
        $deploy_value=$deploy_arr['deploy_value'];//服务合同是否启用审批流程。1:否，0:是

        if($deploy_value==1){
            $end_accountid_enable = $this->end_accountid_enable();
            foreach($ids as $servicecontractid )
            {
                if($end_accountid_enable == "yes"){
                    $sql='select end_accountid from ld_servicecontracts where servicecontractsid='.$servicecontractid;
                }else{
                    $sql='select accountid from ld_servicecontracts where servicecontractsid='.$servicecontractid;
                }
                $result=$adb->pquery($sql,array());
                if($adb->num_rows($result)>0)
                {
                    $accountid=$adb->query_result($result,0,0);
                    $this->getMaxServicDate($accountid);
                }

            }
        }

    }
    /**
     * edit:can
     * reason:获取客户最大到期日
     * */
    function getMaxServicDate($accountid)
    {
        global $adb;
        if (empty($accountid)) {
            return false;
        }

        $deploy_arr = getSys_deploy(47);
        $deploy_value = $deploy_arr['deploy_value'];//服务合同是否启用审批流程。1:否，0:是

        //灵当自用
        $end_accountid_enable = $this->end_accountid_enable();
        if ($end_accountid_enable == "yes") {
            $where = " end_accountid=$accountid ";
        } else {
            $where = " accountid=$accountid ";
        }

        $detailtable = $this->Detail_table;
        $sqlMax = 'delete from ld_maxservicedate where accountid=?';
        /*
        $sqlMin = 'delete from ld_minservicedate where accountid=?';
        */
        if (!empty($accountid)) {
            $adb->pquery($sqlMax, array($accountid));
            //$adb->pquery($sqlMin, array($accountid));
            //edit:can 该sql语句要优化，获取客户产品最新服务日期
            if ($deploy_value == 0) {
                $sql = " select $detailtable.servicecontracts_end_date,productid,$detailtable.id from
                        $detailtable where id in(select  servicecontractsid from ld_servicecontracts
                         where $where and 
                         IFNULL(contract_status,'') <> '已作废' and ifnull(contract_status,'')<>'已拒绝' and deleted = 0
                         and ifnull(ld_servicecontracts.approvestatus,'')='" . constant('D_A_S_APPROVED') . "'
                          )";
            } else
                $sql = " select $detailtable.servicecontracts_end_date,productid,$detailtable.id from
                        $detailtable where id in(select  servicecontractsid from ld_servicecontracts
                         where $where and 
                         IFNULL(contract_status,'') <> '已作废' and ifnull(contract_status,'')<>'已拒绝' and deleted = 0
                          )";

            $result = $adb->pquery($sql, array());
            $maxservicedate = [];
            $minservicedate = [];
            // XUQIU1002141 添加了设置最早服务日期
            for ($i = 0; $i < $adb->num_rows($result); $i++) {
                $productid = $adb->query_result($result, $i, 'productid');
                $servicecontracts_end_date = $adb->query_result($result, $i, 'servicecontracts_end_date');
                if (array_key_exists($productid, $maxservicedate)) {
                    if ($maxservicedate[$productid] < $servicecontracts_end_date) {
                        $maxservicedate[$productid] = $servicecontracts_end_date;
                        $maxiventoryid[$productid] = $adb->query_result($result, $i, 'id');
                    }
                } else {
                    $maxservicedate[$productid] = $servicecontracts_end_date;
                    $maxiventoryid[$productid] = $adb->query_result($result, $i, 'id');
                }
                /*
                // 客户有同一产品的多个服务合同，要从相同的产品中找到最小的结束服务时间
                if (array_key_exists($productid, $minservicedate)) {
                    if ($minservicedate[$productid] > $servicecontracts_end_date) {
                        $minservicedate[$productid] = $servicecontracts_end_date;
                        $miniventoryid[$productid] = $adb->query_result($result, $i, 'id');
                    }
                } else {
                    $minservicedate[$productid] = $servicecontracts_end_date;
                    $miniventoryid[$productid] = $adb->query_result($result, $i, 'id');
                }
                */

            }
            foreach ($maxservicedate as $productid => $service_enddate) {
                $inventoryid = $maxiventoryid[$productid];

                $sql = "insert into ld_maxservicedate(inventoryid,productid,accountid,service_enddate)
                    value($inventoryid,$productid,$accountid,'$service_enddate')";
                $adb->pquery($sql, array());
            }
            /*
            // 也需要将同一产品的最小的结束服务时间放入ld_maxservicedate表中
            foreach ($minservicedate as $productid => $service_enddate) {
                $inventoryid = $miniventoryid[$productid];

                $sql = "insert into ld_minservicedate(inventoryid,productid,accountid,service_enddate)
                    value($inventoryid,$productid,$accountid,'$service_enddate')";
                $adb->pquery($sql, array());
            }
            */

            if ($end_accountid_enable == 'yes') {
                $sqlMax = 'delete from ld_maxservicedate where accountid not in (select accountid from ld_account)
                    OR accountid not in (select end_accountid from (select distinct end_accountid from ld_servicecontracts WHERE end_accountid>0) a);';
                /*
                $sqlMin = 'delete from ld_minservicedate where accountid not in (select accountid from ld_account)
                    OR accountid not in (select end_accountid from (select distinct end_accountid from ld_servicecontracts WHERE end_accountid>0) a);';
                */
            } else {
                $sqlMax = 'delete from ld_maxservicedate where accountid not in (select accountid from ld_account)
                    OR accountid not in (select accountid from (select distinct accountid from ld_servicecontracts WHERE accountid>0) a)';
                /*
                $sqlMin = 'delete from ld_minservicedate where accountid not in (select accountid from ld_account)
                    OR accountid not in (select accountid from (select distinct accountid from ld_servicecontracts WHERE accountid>0) a)';
                */
            }

            //echo $sql; die();

            $adb->pquery($sqlMax, array());
            //$adb->pquery($sqlMin, array());

            $sql = "update ld_account set lastservicedate=(SELECT max(service_enddate) from ld_maxservicedate where accountid=?) where accountid=?";
            $adb->pquery($sql, array($accountid, $accountid));

            $sql = "update ld_account set earlyservicedate=(SELECT min(service_enddate) from ld_maxservicedate where accountid=?) where accountid=?";
            $adb->pquery($sql, array($accountid, $accountid));

            //帮我吧同步关联客户的最晚服务到日期
            $query = 'SELECT vendorid,authcode from ld_bangwo8 where presence = 0';
            $resultInfo = $adb->pquery($query);
            if ($adb->num_rows($resultInfo) > 0) {
                $vendorid = $adb->query_result($resultInfo, 0, 'vendorid');
                $authcode = $adb->query_result($resultInfo, 0, 'authcode');
            }
            if (!empty($vendorid) && !empty($authcode)) {
                crm_load_class_file('cls_Bangwoba', 'modules/Users');
                $cls_Bangwoba = new cls_Bangwoba();
                $accountinfo = $cls_Bangwoba->getAccountInfo($accountid);
                $cls_Bangwoba->UpdateSyncAccounts($accountid, $accountinfo[$accountid]);
            }

        }
    }
    function end_accountid_enable()
    {
        $fieldinfo = $this->fieldobj->getFieldInfoobjBykey("fieldname", "end_accountid");
        if($fieldinfo){
            return 'yes';
        }
        return 'no';
    }
    
    function AddReminds($RemindsContent,$datetime,$recieverid,$record)
    {
        global $adb,$current_user,$currentModule;
        //editor:gyqX160722 Bug:0023591
        $systemdeploy = getSys_deploy(24);
        //$_REQUEST['caterorid']:分配
        if($systemdeploy['deploy_value'] == ''&&!isset($_REQUEST['caterorid'])){
            return false;
        }
        //zxm  2021-0702 保存的时候提醒删除
        $sql="delete from ld_reminds where related_to='{$record}' and status_rmd='未读' and ifnull(remindstype,'') = 'ServiceContractsDueDate'";
        $result = $adb->query($sql);
        $sql="delete from ld_reminds_accepted where related_to='{$record}' and status_rmd='未读' and ifnull(remindstype,'') = 'ServiceContractsDueDate'";
        $result = $adb->query($sql);
            //$smownersql = "select setype,smownerid from ld_crmentity where crmid = ".$record;
			if(empty($recieverid))
            {
                $smownersql = 'select smownerid from '.$this->table_name.' where '.$this->table_index.' = '.$record.' limit 1;';
                $smownerresult = $adb->query($smownersql);
                
                $recieverid = $adb->query_result($smownerresult,0,'smownerid');
            }
            
            $setype = $currentModule;
           crm_load_class_file("Reminds",'modules/Reminds');
            $focus_rel =CRMEntity::getInstance('Reminds'); ;//
            //edit:can 20210716 46968: https://81mis.com/kfbcrm/ [^]，服务管理——新建服务合同后保存，页面卡住并且屏幕中间不停转圈  
            $focus_rel->id=0;                  
        	$focus_rel->column_fields['date_time'] = $datetime;
          
            $focus_rel->column_fields['related_to']=$record;
            $focus_rel->column_fields['reltab']=$this->module_name;
            
            $focus_rel->column_fields['recieverid']=$recieverid;
            $focus_rel->column_fields['remindstype']='ServiceContractsDueDate';//zxm 2021-0630 合同订单交付日期提醒增加存储提醒类型

            $focus_rel->column_fields['status_rmd']='未读';
            $focus_rel->column_fields['content']=$RemindsContent;
            $focus_rel->mode="create";

            $focus_rel->save('Reminds');
           
            return $focus_rel->id;
          /*  $r_multi_content = array(
                array(
                    'userid'=>$recieverid,//注意,这是微信用户id，即用户表中的wx_userid
                    'message'=>$remindcontent,
                    'reltab'=>$this->module,
                    'related_to'=>$this->record,
                    'date_time'=>$datetime,
                    'remindtype'=>'',
                    )
            );
            $remind = new immediatelyReminds();
            $errorno = $remind->sendReminds(array($focus_rel->id),$r_multi_content);*/
    }
    function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;
        
		$this->trash('ServiceContracts',$id);
	}
    function trash($module,$id)
    {
        global $adb;

        $end_accountid_enable = $this->end_accountid_enable();
        if($end_accountid_enable == "yes"){
            $sql='select end_accountid as accountid from ld_servicecontracts  where servicecontractsid=?';
        }else{
            $sql='select accountid from ld_servicecontracts  where servicecontractsid=?';

        }

        $result=$adb->pquery($sql,array($id));
        if($adb->num_rows($result)>0)
        {
            $accountid=$adb->query_result($result,0,0);
        }
       
        parent::trash($module,$id);

        $this->getMaxServicDate($accountid);//获取客户的最大服务到期日,edit:can
        
        $payment_focus=CRMEntity::getInstance("PaymentPlan");
        $payment_focus->deletePaymentPlan($id,$this);
   
        crm_load_class_file("cls_Source_InverseCompute",'include/OptionModule');
        cls_Source_InverseCompute::Source_InveverseCompute($module,$id);
        //刘总反馈客户财讯通问题：服务合同删除后，对应的产品服务到期提醒没有是删除
          $sqldelete="delete from ld_reminds where related_to='$id' and status_rmd='未读'";
         $adb->query($sqldelete);
         $sqldelete="delete from ld_reminds_accepted where related_to='$id' and status_rmd='未读'";
         $adb->query($sqldelete);
      
   
    }




	/**
	 * Apply security restriction (sharing privilege) query part for List view.
	 */
	function getListViewSecurityParameter($module) {
		global $current_user,$adb;
		$ScopOfAuthority = ScopOfAuthority::getInstance($adb,$module);
		return $ScopOfAuthority->getModuleListViewQuery();
	}

	/**
	 * Function which will give the basic query to find duplicates
	 */
	function getDuplicatesQuery($module,$table_cols,$field_values,$ui_type_arr,$select_cols='') {
		$select_clause = "SELECT ". $this->table_name .".".$this->table_index ." AS recordid, ld_users_last_import.deleted,".$table_cols;

		// Select Custom Field Table Columns if present
		if(isset($this->customFieldTable)) $select_clause .= ", " . $this->customFieldTable[0] . ".* ";

		$from_clause = " FROM $this->table_name";

		// Consider custom table join as well.
		if(isset($this->customFieldTable)) {
			$from_clause .= " INNER JOIN ".$this->customFieldTable[0]." ON ".$this->customFieldTable[0].'.'.$this->customFieldTable[1] .
				      " = $this->table_name.$this->table_index";
		}
		$from_clause .= " LEFT JOIN ld_users ON ld_users.id = $this->table_name.smownerid
				LEFT JOIN ld_groups ON ld_groups.groupid = $this->table_name.smownerid";

		$where_clause = "	WHERE $this->table_name.deleted = 0";
		$where_clause .= $this->getListViewSecurityParameter($module);

		if (isset($select_cols) && trim($select_cols) != '') {
			$sub_query = "SELECT $select_cols FROM  $this->table_name AS t ";
			// Consider custom table join as well.
			if(isset($this->customFieldTable)) {
				$sub_query .= " INNER JOIN ".$this->customFieldTable[0]." tcf ON tcf.".$this->customFieldTable[1]." = t.$this->table_index";
			}
			$sub_query .= " WHERE $this->table_name.deleted=0 GROUP BY $select_cols HAVING COUNT(*)>1";
		} else {
			$sub_query = "SELECT $table_cols $from_clause $where_clause GROUP BY $table_cols HAVING COUNT(*)>1";
		}

		$query = $select_clause . $from_clause .
					" LEFT JOIN ld_users_last_import ON ld_users_last_import.bean_id=" . $this->table_name .".".$this->table_index .
					" INNER JOIN (" . $sub_query . ") AS temp ON ".get_on_clause($field_values,$ui_type_arr,$module) .
					$where_clause .
					" ORDER BY $table_cols,". $this->table_name .".".$this->table_index ." ASC";
		return $query;
	}
    function get_lessionplan($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global $singlepane_view,$currentModule,$current_user;
		$this_module = $currentModule;
        $related_module = "LessionPlan";
		$other = CRMEntity::getInstance($related_module);
		if($singlepane_view == 'true')
			$returnset = '&return_module='.$this_module.'&return_action=DetailView&return_id='.$id;
		else
			$returnset = '&return_module='.$this_module.'&return_action=CallRelatedList&return_id='.$id;
		$button = '';
		if($actions) {
			if(is_string($actions)) $actions = explode(',', strtoupper($actions));
			if(in_array('SELECT', $actions) && isPermitted($related_module,4, '') == 'yes') {
				$button .= '<a title="'.getFixedLabel('SELECT').'" href="javascript:void(0);"
					onclick=\'return window.open("index.php?module='.$related_module.'&return_module='.$currentModule.'&action=Popup&popuptype=detailview&select=enable&form=EditView&form_submit=false&recordid='.$id.'&parenttab='.$parenttab.'","test","width=640,height=602,resizable=0,scrollbars=0");\'>
    				<span>'.getFixedLabel('SELECT').'</span>
    				</a>';
			}
			if(in_array('ADD', $actions) && isPermitted($related_module,"Create", '') == 'yes') {
                $button .= '<a title="'.getFixedLabel('CREATE').'"
                    href="index.php?module='.$related_module.'&action=EditView&return_module='.$related_module.'&return_action=DetailView&Create=yes&projectid='.$id.'&account_id='.$_REQUEST['account_id'].'&contact_id='.$_REQUEST['contact_id'].'&potential_id='.$_REQUEST['potential_id'].'&salesorder_id='.$_REQUEST['salesorder_id'].'" target="_blank"/>
                    <span>'.getFixedLabel('CREATE').'</span>
                    </a>';
			}
		}
		$query = "select ld_lessionplan.* from ld_lessionplan
inner join ld_servicecontracts on ld_lessionplan.projectid = ld_servicecontracts.servicecontractsid 
inner join ld_crmentity on ld_crmentity.crmid = ld_lessionplan.lessionplanid 
where ld_lessionplan.deleted =0 and ld_servicecontracts.servicecontractsid = ".$id;
        //echo 'query1:'.$query.'<br>';
		crm_load_function_file('GetRelatedList','include','RelatedListView');
		$return_value = GetRelatedList($this_module, $related_module, $other, $query, $button, $returnset);
		if($return_value == null) $return_value = Array();
		$return_value['CUSTOM_BUTTON'] = $button;
		return $return_value;
	}

	/**
	 * Handle saving related module information.
	 * NOTE: This function has been added to CRMEntity (base class).
	 * You can override the behavior by re-defining it here.
	 */
	function save_related_module($module, $crmid, $with_module, $with_crmids) {

		if(!is_array($with_crmids)) $with_crmids = Array($with_crmids);
		foreach($with_crmids as $with_crmid) {
		 
			parent::save_related_module($module, $crmid, $with_module, $with_crmid);
			if ($with_module == 'HelpDesk') {
				$this->updateHelpDeskRelatedTo($crmid,$with_crmid);
              
				$this->updateServiceContractState($crmid);
			}
             
		}
	 }

	 // Function to Update the parent_id of HelpDesk with sc_related_to of ServiceContracts if the parent_id is not set.
	 function updateHelpDeskRelatedTo($focusId, $entityIds) {

		if(!is_array($entityIds)) $entityIds = array($entityIds);
		$selectTicketsQuery = "SELECT ticketid FROM lingdang_troubletickets WHERE (parent_id IS NULL OR parent_id = 0) AND ticketid IN (" . generateQuestionMarks($entityIds) .")";
		$selectTicketsResult = $this->db->pquery($selectTicketsQuery, array($entityIds));
		$noOfTickets = $this->db->num_rows($selectTicketsResult);
		for($i=0; $i < $noOfTickets; ++$i) {
			$ticketId = $this->db->query_result($selectTicketsResult,$i,'ticketid');
			$updateQuery = "UPDATE lingdang_troubletickets, ld_servicecontracts SET parent_id=ld_servicecontracts.sc_related_to" .
						" WHERE ld_servicecontracts.sc_related_to IS NOT NULL AND ld_servicecontracts.sc_related_to != 0" .
						" AND ld_servicecontracts.servicecontractsid = ? AND lingdang_troubletickets.ticketid = ?";
			$updateResult = $this->db->pquery($updateQuery, array($focusId, $ticketId));
		}

		
	}

	// Function to Compute and Update the Used Units and Progress of the Service Contract based on all the related Trouble tickets.
	function updateServiceContractState($focusId) {
		$this->id = $focusId;
		$this->retrieve_entity_info($focusId,'ServiceContracts');
        
		$contractTicketsResult = $this->db->pquery("SELECT relcrmid FROM ld_crmentityrel
														WHERE module = 'ServiceContracts'
														AND relmodule = 'HelpDesk' AND crmid = ?
													UNION
														SELECT crmid FROM ld_crmentityrel
														WHERE relmodule = 'ServiceContracts'
														AND module = 'HelpDesk' AND relcrmid = ?",
													array($focusId,$focusId));

		$noOfTickets = $this->db->num_rows($contractTicketsResult);
		$ticketFocus = CRMEntity::getInstance('HelpDesk');
		$totalUsedUnits = 0;
		for($i=0; $i < $noOfTickets; ++$i) {
			$ticketId = $this->db->query_result($contractTicketsResult, $i, 'relcrmid');
			$ticketFocus->id = $ticketId;
			if(isRecordExists($ticketId)) {
				$ticketFocus->retrieve_entity_info($ticketId, 'HelpDesk');
				if (strtolower($ticketFocus->column_fields['ticketstatus']) == 'closed') {
					$totalUsedUnits += $this->computeUsedUnits($ticketFocus->column_fields);
				}
			}
		}
    
		$this->updateUsedUnits($totalUsedUnits);

		$this->calculateProgress();
	}

	// Function to Upate the Used Units of the Service Contract based on the given Ticket id.
	function computeUsedUnits($ticketData, $operator='+') {
		$trackingUnit = strtolower($this->column_fields['tracking_unit']);
		$workingHoursPerDay = 24;

		$usedUnits = 0;
		if ($trackingUnit == 'incidents') {
			$usedUnits = 1;
		} elseif ($trackingUnit == 'days') {
			if(!empty($ticketData['days'])) {
				$usedUnits = $ticketData['days'];
			} elseif(!empty($ticketData['hours'])) {
				$usedUnits = $ticketData['hours'] / $workingHoursPerDay;
			}
		} elseif ($trackingUnit == 'hours') {
			if(!empty($ticketData['hours'])) {
				$usedUnits = $ticketData['hours'];
			} elseif(!empty($ticketData['days'])) {
				$usedUnits = $ticketData['days'] * $workingHoursPerDay;
			}
		}
		return $usedUnits;
	}

	// Function to Upate the Used Units of the Service Contract.
	function updateUsedUnits($usedUnits) {
		$this->column_fields['used_units'] = $usedUnits;
		$updateQuery = "UPDATE ld_servicecontracts SET used_units = $usedUnits WHERE servicecontractsid = ?";
		$this->db->pquery($updateQuery, array($this->id));
	}

	// Function to Calculate the End Date, Planned Duration, Actual Duration and Progress of a Service Contract
	function calculateProgress() {
		$updateCols = array();
		$updateParams = array();

		$startDate = $this->column_fields['start_date'];
		$dueDate = $this->column_fields['due_date'];
		$endDate = $this->column_fields['end_date'];

		$usedUnits = $this->column_fields['used_units'];
		$totalUnits = $this->column_fields['total_units'];

		$contractStatus = $this->column_fields['contract_status'];

		// Update the End date if the status is Complete or if the Used Units reaches/exceeds Total Units
		// We need to do this first to make sure Actual duration is computed properly
		if($contractStatus == 'Complete' || (!empty($usedUnits) && !empty($totalUnits) && $usedUnits >= $totalUnits)) {
			if(empty($endDate)) {
				$endDate = date('Y-m-d');
				$this->db->pquery('UPDATE ld_servicecontracts SET end_date=? WHERE servicecontractsid = ?', array(date('Y-m-d'), $this->id));
			}
		} else {
		  /*
          andrew
          20140227
          	0007280: 服务合同“服务截止日期”保存不了
          */
			//$endDate = null;
			$this->db->pquery('UPDATE ld_servicecontracts SET end_date=? WHERE servicecontractsid = ?', array($endDate, $this->id));
		}

		// Calculate the Planned Duration based on Due date and Start date. (in days)
		if(!empty($dueDate) && !empty($startDate)) {
			$plannedDurationUpdate = " planned_duration = (TO_DAYS(due_date)-TO_DAYS(start_date)+1)";
		} else {
			$plannedDurationUpdate = " planned_duration = ''";
		}
		array_push($updateCols, $plannedDurationUpdate);

		// Calculate the Actual Duration based on End date and Start date. (in days)
		if(!empty($endDate) && !empty($startDate)) {
			$actualDurationUpdate = "actual_duration = (TO_DAYS(end_date)-TO_DAYS(start_date)+1)";
		} else {
			$actualDurationUpdate = "actual_duration = ''";
		}
		array_push($updateCols, $actualDurationUpdate);

		// Update the Progress based on Used Units and Total Units (in percentage)
		if(!empty($usedUnits) && !empty($totalUnits)) {
			$progressUpdate = 'progress = ?';
			$progressUpdateParams = floatval(($usedUnits * 100) / $totalUnits);
		} else {
			$progressUpdate = 'progress = ?';
			$progressUpdateParams = null;
		}
		array_push($updateCols, $progressUpdate);
		array_push($updateParams, $progressUpdateParams);

		if(count($updateCols) > 0) {
			$updateQuery = 'UPDATE ld_servicecontracts SET '. implode(",", $updateCols) .' WHERE servicecontractsid = ?';
			array_push($updateParams, $this->id);
			$this->db->pquery($updateQuery, $updateParams);
		}
	}

	/**
	 * Handle deleting related module information.
	 * NOTE: This function has been added to CRMEntity (base class).
	 * You can override the behavior by re-defining it here.
	 */
	function delete_related_module($module, $crmid, $with_module, $with_crmid) {
	 	parent::delete_related_module($module, $crmid, $with_module, $with_crmid);
	 	if ($with_module == 'HelpDesk') {
	 		$this->updateServiceContractState($crmid);
	 	}
	}
	 ////反审批操作
    public function rejectApproved($record)
    {
        	$deploy_arr=  getSys_deploy(47);
        $deploy_value=$deploy_arr['deploy_value'];//服务合同是否启用审批流程。1:否，0:是
        
        if($deploy_value==0&&$this->column_fields['account_id']<=0){
            $this->retrieve_entity_info($record,$this->module_name);

            $end_accountid_enable = $this->end_accountid_enable();
            if($end_accountid_enable == "yes"){
                $accountid = $this->column_fields['end_accountid'];
            }else{
                $accountid=$this->column_fields['account_id'];
            }
            $this->getMaxServicDate($accountid);

           //批量审批两个以上的合同且合同所对应的客户不一样
           $this->column_fields['account_id']=0;
           $reset_retrieve_entity_info='yes';
        }
        
        
    }
	public function successApprove($crmid){
		//杨锻客户，erp对接特殊判断
		$deployarray=getSys_deploy(92);
		if(isset($deployarray['deploy_value']) && $deployarray['deploy_value'] == 0){
			if(get_versiontrade() == 'yangduan'){
				crm_load_class_file('cls_interface_yadon','include/InterfaceClass');
				$cls_interface_yadon = new cls_interface_yadon();
				$_SESSION['kiserror'] = $cls_interface_yadon->ServiceContracts_Synchronous($crmid,'ServiceContracts');
			}
		}
      
        //服务合同保存后是否创建收款单
        $this->autocreateCasbhill($crmid,'approve');
        $deploy_arr=  getSys_deploy(47);
        $deploy_value=$deploy_arr['deploy_value'];//服务合同是否启用审批流程。1:否，0:是
        global $reset_retrieve_entity_info;
        $before_value = $reset_retrieve_entity_info;
        if($deploy_value==0){
            //duan 20230728 多条服务合同批量审批时，仅更新一条服务收费管理，“最晚服务到期日”字段数据
            $reset_retrieve_entity_info='yes';
            $this->retrieve_entity_info($crmid,$this->module_name);

            $end_accountid_enable = $this->end_accountid_enable();
            if($end_accountid_enable == "yes"){
                $this->getMaxServicDate($this->column_fields['end_accountid']);

                $this->column_fields['end_accountid']=0;
                $reset_retrieve_entity_info=$before_value;
            }else{
                $this->getMaxServicDate($this->column_fields['account_id']);
                //批量审批两个以上的合同且合同所对应的客户不一样
                $this->column_fields['account_id']=0;
                $reset_retrieve_entity_info=$before_value;
            }
        }
        
        
	}
}
ServiceContracts::require_file();
?>