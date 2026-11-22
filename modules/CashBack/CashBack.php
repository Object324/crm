<?php

require_once(globalStatic::$root_directory.'include/upload/FileUtil.php');
class CashBack extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['CashBack']='CashBack';
            if(empty(globalStatic::$arr_module_require['Accounts']))
            {
                globalStatic::$arr_module_require['Accounts']='Accounts';
                include("modules/Accounts/Accounts.php");
                
            }
            
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $log;
    var $db;
    var $table_name='ld_cashback';
    public $table_index='cashbackid';
    var $tab_name=Array('ld_crmentity','ld_cashback','ld_cashbackscf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_cashback'=>'cashbackid','ld_cashbackscf'=>'cashbackid');
   	var $customFieldTable = Array('ld_cashbackscf', 'cashbackid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";
    var $module_name='CashBack';
	var $column_fields = Array();
    var $sortby_fields=Array('cashbackid,cashbackdate');
    //管理模块
    var $relatedtab=array('accounts'=>'','cashback'=>'','users'=>'','company'=>'','products'=>'');

            
    var $list_link_field= 'cashback_no';
    var $table_code= 'cashback_no';

            
   	var $search_fields_name = Array();
            
   var $required_fields =  array();
    var $Detail_table="ld_cashbackdetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_cashbackdetailscf";//明细scf表
     var $Detail_table_index="id";//明细表和主表关联的字段
//比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'cashback_no');
	var $default_order_by = 'cashbackid';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="cashback_no";
    var $popup_fields=Array();
    function __construct()
    {
	   //$this->log =LoggerManager::getLogger('CashBack');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('CashBack',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('CashBack');
        $this->list_link_field=$entityname['fieldname'];
        $this->popup_fields=Array($this->list_link_field);
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
    }
    
   function  save_module()
   {
       $deployarray = getSys_deploy(352);//是否开启审批  0是 1否
		if(isset($_REQUEST['createview'])&& $_REQUEST['createview']=='create_view')
		{
		}
		else
		{
			/*$cashback_query_old = "select * from ld_cashback where cashbackid =?";
			$cashback_result_old = $this->db->pquery($cashback_query_old, array($this->id));
			$result_total_old = $this->db->query_result($cashback_result_old,0,'total');  
			$bankaccountsetid = $this->db->query_result($cashback_result_old,0,'bankaccountsetid'); 
			$sqls="UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)+$result_total_old WHERE bankaccountsetid=$bankaccountsetid";
			$this->db->pquery($sqls,array());*/

            //ls 20221101 Xuqiu1000213 服务回访单、销售退货单、采购退货单、销售退款单、采购退款单增加“新建”功能（销售退款单编辑时的计算）
            //编辑时先还原每个源单的对应银行账户的钱，以及源单已退款金额，以防编辑后删除源单，导致计算错误
            if ($deployarray['deploy_value'] == 1) {//未开启审批
                $this->resetAmount($this->id);
                $this->addBankMoney($this->id);
            }

		}
        
        
      if($_REQUEST['action'] != 'CashBackAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
					&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
            //Based on the total Number of rows we will save the product relationship with this entity
            crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'CashBack');
		}
      //编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
		if($this->currency_status === true)
		{
			$update_query = "update ld_cashback set currency_id=?, conversion_rate=?,currency_symbol=? where cashbackid=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		} 
        
	

		//原来没有选择源单字段时一个退款单仅对应一个退货单，主表退款单金额是一一对应的，现在多个源单时，需要从详情表去统计每个源单的已退金额
		if ($deployarray['deploy_value'] == 1) {//未开启审批
		   $this->inverseAmount($this->id);
		   $this->minusBankMoney($this->id);//从详情表去统计每个源单的退款金额（价税合计tax_amount）后计算，改为从主表合计计算
		}
	   
	   
		$update_query = "update ld_cashback set triggercount=triggercount+1 where cashbackid=?";
		$this->db->pquery($update_query,array($this->id));
	
   }

    function successApprove($record)
    {
        $this->inverseAmount($record);
        $this->minusBankMoney(array($record));
    }
    public function rejectApproved($record)
    {
        $this->resetAmount($record);
        $this->addBankMoney(array($record));
    }

   //编辑保存前及删除单据时还原已退金额及银行账户
    function resetAmount($record)
    {
        $this->inverseAmount($record);
        /*if ($record) {
            //反算原单销售退货单 分录的退款金额
            crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
            cls_Source_InverseCompute::Source_InveverseCompute($this->module_name,$record,$this);

            $cashback_query_old = "select sum(ifnull(tax_amount,0)) as total,ld_cashbackdetail.entitytype,entitytypeid,bankaccountsetid from ld_cashback inner join ld_cashbackdetail on id=cashbackid where cashbackid = ? and entitytypeid>0 GROUP BY entitytypeid";
            $cashback_result_old = $this->db->pquery($cashback_query_old, array($record));
            for ($i = 0; $i < $this->db->num_rows($cashback_result_old); $i++) {
                $result_total_old = $this->db->query_result($cashback_result_old,$i,'total');
                $result_entitytype = $this->db->query_result($cashback_result_old,$i,'entitytype');//源单模块
                $result_entitytypeid = $this->db->query_result($cashback_result_old,$i,'entitytypeid');

                $tmp_focus = CRMEntity::getInstance($result_entitytype);
                $update_query = "update $tmp_focus->table_name set havebackamount=IFNULL(havebackamount,0)-IFNULL($result_total_old,0) where $tmp_focus->table_index=?";
                $this->db->pquery($update_query, array($result_entitytypeid));
            }
        }*/

    }

    //新建保存后、编辑保存后及回收站还原单据后反写已退金额及银行账户
    function inverseAmount($record)
    {
        if ($record) {
            //反算原单销售退货单 分录的退款金额
            crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
            cls_Source_InverseCompute::Source_InveverseCompute($this->module_name,$record,$this);


            /*$cashback_query = 'select sum(ifnull(tax_amount,0)) as total,ld_cashbackdetail.entitytype,
            entitytypeid,bankaccountsetid from ld_cashback inner join ld_cashbackdetail on id=cashbackid where 
            cashbackid = ? and entitytypeid>0 GROUP BY entitytypeid';
            $cashback_result = $this->db->pquery($cashback_query, array($record));*/

            /*for ($i = 0; $i < $this->db->num_rows($cashback_result); $i++) {
                $result_total = $this->db->query_result($cashback_result, $i, 'total');
                $result_entitytype = $this->db->query_result($cashback_result, $i, 'entitytype');//源单模块
                $result_entitytypeid = $this->db->query_result($cashback_result, $i, 'entitytypeid');//源单id

                //编辑时，可能会删除源单，因此源单保存前已经还原已退金额以及银行账户，因此编辑源单也可以看做是新增源单去计算已退款金额。
                $tmp_focus = CRMEntity::getInstance($result_entitytype);
                $update_query = "update $tmp_focus->table_name set havebackamount=IFNULL(havebackamount,0)+IFNULL($result_total,0) where $tmp_focus->table_index=?";
                $this->db->pquery($update_query, array($result_entitytypeid));

            }*/


            $sql='select entitytypeid,entitytype from ld_cashbackdetail where id=? and entitytypeid>0 group by entitytypeid';
            $result=$this->db->pquery($sql,array($record));
            $entitytypeid_arr=[];
            $rows=$this->db->num_rows($result);
            for($i=0;$i<$rows;$i++)
            {
                $entitytypeid=$this->db->query_result($result,$i,'entitytypeid');
                $entitytype=$this->db->query_result($result,$i,'entitytype');
                $entitytypeid_arr[$entitytypeid]=$entitytype;
            }

            foreach($entitytypeid_arr as $entitytypeid=>$entitytype)
            {
                $sourcefocus=CRMEntity::getInstance($entitytype);
                $sourcetablename=$sourcefocus->table_name;
                $sourcetableindex=$sourcefocus->table_index;


                $sql=" update $sourcetablename  left  JOIN( 
                            select sum( case  when $sourcetablename.currency_id=ld_cashback.currency_id  then ld_cashbackdetail.tax_amount
                            		else ld_cashbackdetail.tax_amount/ld_cashback.conversion_rate*$sourcetablename.conversion_rate  end ) 
                            as havebackamount,
                            		ld_cashbackdetail.entitytypeid
                            			from ld_cashbackdetail
                            
                            INNER JOIN ld_cashback on ld_cashback.cashbackid=ld_cashbackdetail.id
                             INNER JOIN $sourcetablename on $sourcetablename.$sourcetableindex=ld_cashbackdetail.entitytypeid
                            where  ld_cashback.deleted=0 and $sourcetablename.$sourcetableindex=? and ld_cashbackdetail.entitytypeid=? 
                            AND (CASE WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE setype='CashBack' AND deploy_value=0) THEN ld_cashback.approvestatus='已批准' ELSE 1=1 END)
                            ) as tmp  on tmp.entitytypeid=$sourcetablename.salesbackid
                            set $sourcetablename.havebackamount=ifnull(tmp.havebackamount,0)
                            where $sourcetablename.$sourcetableindex=? ";
           ///     file_put_contents(globalStatic::$root_directory.'aaatest.txt',"\r\n销售退款单反算"."sql:".$sql."\r\n"."param:".json_encode(array($entitytypeid,$entitytype),JSON_UNESCAPED_UNICODE),FILE_APPEND);

                $this->db->pquery($sql,array($entitytypeid,$entitytypeid,$entitytypeid));

            }

        }
    }

    public function addBankMoney($records)
    {
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
        $sql="update ld_bankaccountset
            INNER JOIN ld_cashback on ld_bankaccountset.Bankaccountsetid=ld_cashback.bankaccountsetid
            set curbalancemoney=ifnull(curbalancemoney,0)+ifnull(ld_cashback.total,0)
            where ld_cashback.cashbackid in( ".$tmprecords.")";

        $adb->pquery($sql,array());

    }

    public function minusBankMoney($records)
    {
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
        $sql="update ld_bankaccountset
            INNER JOIN ld_cashback on ld_bankaccountset.Bankaccountsetid=ld_cashback.bankaccountsetid
             set curbalancemoney=curbalancemoney-ifnull(ld_cashback.total,0)
              where ld_cashback.cashbackid in( ".$tmprecords.")";
        $adb->pquery($sql,array());

    }

    function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		$this->trash('CashBack',$id);
		 
	}

}
CashBack::require_file();
?>