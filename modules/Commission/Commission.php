<?php
include_once('config.php');


class Commission extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['Commission']='Commission';
          
            
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $log;
    var $db;
    var $table_name='ld_commission';
    var $table_index='commission_id';
    var $table_code='commission_no';//表编号字段(审批中心)
    var $tab_name=Array('ld_crmentity','ld_commission','ld_commissionscf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_commission'=>'commission_id','ld_commissionscf'=>'commission_id');
   	var $customFieldTable = Array('ld_commissionscf', 'commission_id');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";
    var $Detail_table="ld_commission2payment";//明细表名称
    var $Detail_table_id="commission2payment_id";//主表和明细表关联的主键字段名称
	var $Detail_table_scf = "ld_commission2paymentscf";//明细scf表
     var $Detail_table_index="commission_id";//明细表和主表关联的字段
	var $column_fields = Array();
    var $module_name='Commission';
    var $sortby_fields=Array('commission_no');
    //管理模块
    var $relatedtab=array('accounts'=>'','salesorder'=>'','users'=>'','company'=>'','cashbill'=>'','commission'=>'');
            
    var $list_link_field= 'cashbill_no';
   	var $search_fields_name = Array();
    var $required_fields =  array();

//比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'commission_no');
	var $default_order_by = 'commission_no';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="commission_no";
    
    var $detailfieldobj;
    function __construct()
    {
	  // $this->log =LoggerManager::getLogger('Commission');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('Commission',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('Commission');
        $this->list_link_field=$entityname['fieldname'];
        crm_load_class_file('TabDetailFields','include/TabDetailFields');
        $this->detailfieldobj=TabDetailFields::getInstance($this->module_name);
    }
   
    function massEdit_save_before($module,$ids)
    {
        
            global  $adb;
            $becurrency_id=$this->column_fields['currency_id'];
            parent::massEdit_save_before($module,$ids);
            if(isset($_REQUEST['currency_id_mass_edit_check'])&&$becurrency_id!=$_REQUEST['currency_id_mass_edit_check'])
            {
                
                	$conversion_rate = $this->currencyobj->getCurrencyRate();
    				$currency_symbol = $this->currencyobj->getCurrencySymbol();
                    $becurrency_rate=$this->before_currencyobj->getCurrencyRate();
            		
                   if($becurrency_id == 1)//编辑前的币种人民币
        			{
        				$query = "update ld_commission set total = total*?,nosendpayment=nosendpayment*?,subtotal = subtotal*? where commission_id = ?";
        				$adb->pquery($query,array($conversion_rate,$conversion_rate,$conversion_rate,$this->id));
        				$query2payment = "update ld_commission2payment set amount = amount/? where commission_id = ?";
        				$adb->pquery($query2payment,array($conversion_rate,$this->id));
        			}
        			else
        			{
        				$query = "update ld_commission set total = total/?*?,nosendpayment=nosendpayment/?*?,subtotal = subtotal/?*? where commission_id = ?";
        				$adb->pquery($query,array($becurrency_rate,$conversion_rate,$becurrency_rate,$conversion_rate,$becurrency_rate,$conversion_rate,$this->id));
        				$query2payment = "update ld_commission2payment set amount = amount/?*? where commission_id = ?";
        				$adb->pquery($query2payment,array($becurrency_rate,$conversion_rate,$this->id));
        			}
         }
    }
   	function save_module($module)
	{
        global $adb,$weixin_user;
        $i=1;
        //dump($this->before_save_infos);
      if($_REQUEST['action'] != 'CommissionAjax' && $_REQUEST['ajaxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
		  
        }
        else
        {
            //查看界面的小编辑和批量修改
            return ;
        }
        
		//编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
		if($this->currency_status === true)
		{
			$update_query = "update ld_commission set currency_id=?, conversion_rate=?,currency_symbol=? where commission_id=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}
		$tabid = getTabid($module);
        
        crm_load_class_file('cls_save_moduledetail','data');
        $obj=new cls_save_moduledetail($this->module_name,$this->id);
        $obj->Savedetail();

    }
    public function langjieaftersave($updatelangjieparent_lineitem_id_arr){
        //  dump($updatelangjieparent_lineitem_id_arr);
        $old_detailid_arr=array_keys($updatelangjieparent_lineitem_id_arr);
        if(sizeof($old_detailid_arr)>0&&$old_detailid_arr[0]>0)
        {
            foreach($updatelangjieparent_lineitem_id_arr as $old_detailid=>$new_detailid)
            {
                //需要反写出库的parent_lineitem_id;
                $update='update ld_commission2payment set parent_lineitem_id=? where parent_lineitem_id=?';
                $adb->pquery($update,array($new_detailid,$old_detailid));

            }
        }
        $bfore_selectlistval=$this->before_save_infos[0]['selectlistval'];
        $after_selectlistval=$_REQUEST['selectlistval'];
        $selectlistval_arr=array();
        if(trim($bfore_selectlistval,',')!='')
        {
            $selectlistval_arr=explode(',',trim($bfore_selectlistval,','));
        }

        if(trim($after_selectlistval,',')!='')
        {
            $selectlistval_arr=array_merge($selectlistval_arr,explode(",",trim($after_selectlistval,',')));

        }

        if($selectlistval_arr[0]>0)
            $this->updateLangJiesf217(array_unique($selectlistval_arr));
        else if($_REQUEST['commissiontype']=='入库')
        {

            /*$sql='update ld_commission2paymentscf
           INNER JOIN ld_commission2payment on ld_commission2paymentscf.commission2payment_id
          =ld_commission2payment.commission2payment_id  set sf217_balance=sf217 where
          ld_commission2payment.commission_id=? ';
          $adb->pquery($sql,array($this->id));*/
            //edit:can 20200818 更新郎捷的剩余商品数量

            $this->updateLangJiesf217(array($this->id));

        }
    }
    /**
     * edit:can 20200818
     * 更新郎捷的原单 剩余商品数量和已出库商品数量
     * */
    public function updateLangJiesf217($entitytypeid_arr){
        global $adb;
        $str=implode(",",$entitytypeid_arr);
        $sql="update ld_commission2paymentscf  left JOIN (
                select ld_commission2payment.commission2payment_id,sum(out_commissionpaymentscf.sf217) as outquantity
                  from ld_commission2payment
                INNER JOIN ld_commission2paymentscf on ld_commission2paymentscf.commission2payment_id 
                =ld_commission2payment.commission2payment_id
                INNER JOIN ld_commission2payment as out_commissionpayment
                	   on out_commissionpayment.parent_lineitem_id=ld_commission2payment.commission2payment_id
                 INNER JOIN ld_commission2paymentscf 
                 as out_commissionpaymentscf on out_commissionpaymentscf.commission2payment_id=out_commissionpayment.commission2payment_id
                         inner join ld_commission on ld_commission.commission_id=out_commissionpayment.commission_id
                and ld_commission.deleted=0 
                
        where out_commissionpayment.entitytypeid in($str) group by out_commissionpayment.parent_lineitem_id ) as tmptable
         on tmptable.commission2payment_id=ld_commission2paymentscf.commission2payment_id
         inner join ld_commission2payment on ld_commission2paymentscf.commission2payment_id=ld_commission2payment.commission2payment_id
        set  ld_commission2paymentscf.sf217_out=outquantity,ld_commission2paymentscf.sf217_balance=ld_commission2paymentscf.sf217-ifnull(outquantity,0)
        where ld_commission2payment.commission_id in($str)";
      
        $adb->pquery($sql,array());
        
        
    }
    function getSourceField($fieldname,$recordid)
    {
        global $adb;
        return array();
        $sql = "select entitytype,entitytypeid from ld_commission2payment where commission_id = ?";
        
        $result = $adb->pquery($sql,array($recordid));
        return $adb->query_result($result,0,0);
    }
    public function trash($module,$id)
    {
        parent::trash($module,$id);
        $versioninfo=getVersionInfo();
        if($versioninfo['account']=='langjie')
        {
            global $adb;
            $sql='select group_concat(ld_commission2payment.entitytypeid) as entitytypeids from  ld_commission2payment 
            where  ld_commission2payment.commission_id=?';
            $result= $adb->pquery($sql,array($id));
          
            $entitytypeids=$adb->query_result($result,0,'entitytypeids');
            if(trim($entitytypeids,',')!='')
            {
                //edit:can 20200818 更新郎捷的剩余商品数量
                $this->updateLangJiesf217(array_unique(explode(",",$entitytypeids)));
            }
        }
    }
    function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Accounts'||$return_module=="SalesOrder"||$return_module=="PaymentPlan"|| $return_module == 'ServiceContracts'  ) {
			$this->trash('Commission',$id);
		} 
	}
    public function minusBankMoney($records)
    { global $before_approveinfo;
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
       // if($before_approveinfo['approvestatus']==constant('D_A_S_APPROVED'))
       // {
         $usql = "UPDATE ld_bankaccountset
            
                INNER JOIN ld_commission on ld_bankaccountset.Bankaccountsetid=ld_commission.bankaccountsetid
                 SET curbalancemoney=IFNULL(curbalancemoney,0)-ld_commission.total
             WHERE ld_commission.commission_id in( $tmprecords )"; 
            $adb->pquery($usql,array());  
        //}
    }
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
            
                INNER JOIN ld_commission on ld_bankaccountset.Bankaccountsetid=ld_commission.bankaccountsetid
                 SET curbalancemoney=IFNULL(curbalancemoney,0)+ld_commission.total
             WHERE ld_commission.commission_id in( $tmprecords )";
            $adb->pquery($usql,array());  
        
       
       
    }
    
  /**
     * edit:can
     * reason:审批-》已批准
     * 17144: 佣金单>新增,关于审批佣金单没有正确计算账户余额的问题
     * */
    function successApprove($record)
    {
       $this->minusBankMoney(array($record));
        
    }
     ////反审批操作
    public function rejectApproved($record)
    {
         $this->addBankMoney(array($record));
        	
    }
    function getCommissionField($fieldname,$recordid)
    {
        global $adb;
        $sql = "select $fieldname from ld_commission where commission_id = $recordid";
        $result = $adb->pquery($sql,array());
        return $adb->query_result($result,0,0);
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
						distinct	ld_commission.commission_id as crmid,ld_commission.* '.$fromclause.' 
						FROM
							ld_commission 
						LEFT JOIN ld_users 
							ON ld_commission.smownerid = ld_users.id 
                        left join ld_commissionscf on ld_commissionscf.commission_id=ld_commission.commission_id
						left join ld_account 
							on ld_account.accountid = ld_commission.accountid 
                            left join ld_commission2payment on ld_commission2payment.commission_id=ld_commission.commission_id
                        LEFT JOIN ld_bankaccountset on ld_bankaccountset.Bankaccountsetid=ld_commission.bankaccountsetid';
		   $query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_commission.commission_id";
		   $query .= " WHERE ld_commission.deleted = 0 " . $where;
       return $query;
    }*/
}
Commission::require_file();
?>