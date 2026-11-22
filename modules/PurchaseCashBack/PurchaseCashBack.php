<?php

// include_once('config.php');
// require_once('include/logging.php');
// require_once('include/upload/FileUtil.php');

class PurchaseCashBack extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['PurchaseCashBack']='PurchaseCashBack';
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
    var $Detail_table="ld_purchasecashbackdetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_purchasecashbackdetailscf";//明细scf表
     var $Detail_table_index="id";//明细表和主表关联的字段
    var $table_name='ld_purchasecashback';
    public $table_index='purchasecashbackid';
    var $table_code='purchasecashback_no';//表编号字段(审批中心)
    var $tab_name=Array('ld_crmentity','ld_purchasecashback','ld_purchasecashbackscf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_purchasecashback'=>'purchasecashbackid','ld_purchasecashbackscf'=>'purchasecashbackid');
   	var $customFieldTable = Array('ld_purchasecashbackscf', 'purchasecashbackid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";
    var $module_name='PurchaseCashBack';
	var $column_fields = Array();
    var $sortby_fields=Array('purchasecashbackid,purchasecashbackdate');
    /*
    edit:can
    date:20131024
    reason:打印关联模块
    */
    var $relatedtab=array('accounts'=>'','users'=>'','company'=>'','purchasecashback'=>'','purchaseorder'=>'','products'=>'');
            
    var $list_link_field= 'purchasecashback_no';
            
            
   	var $search_fields_name = Array(
		          
			);
            
   var $required_fields =  array();

//比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'sendcashbill_no');
	var $default_order_by = 'purchasecashbackid';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="purchasecashback_no";
    var $popup_fields=Array();
    function __construct()
    {
	   // $this->log =LoggerManager::getLogger('PurchaseCashBack');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('PurchaseCashBack',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('PurchaseCashBack');
        $this->list_link_field=$entityname['fieldname'];
        $this->popup_fields=Array($this->list_link_field);
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
    }
     /*
    date：20130916
    reason:更多信息字段
    edit by chj
   
    function getRelated($Type)
    {
         global $adb,$current_user;
        require('user_privileges/user_language_'.$current_user->id.'.php');
       
        $tabid = getTabid('PurchaseCashBack');
        $SqlField = "select tablename,fieldname,case when ifnull(ld_tranlabel.fieldlabel,'')=''then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
                 from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
              left join ld_relatedlists_lable  on ld_relatedlists_lable.fieldid=ld_field.fieldid
             where languagetype=? and trantable=? and ld_tranlabel.tabid=".$tabid." and ld_field.presence in (0,2)
			 and ld_field.displaytype in (1) and ld_field.tablename != 'ld_purchasecashbackscf' order by ld_field.sequence";//ld_relatedlists_lable.presence=1 
        $result = $adb->pquery($SqlField,array($languageType,'ld_field'));
		$rows = $adb->num_rows($result);
        for($i=0;$i<$rows;$i++)
        {
            
                $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
                        "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
                    );   
                  $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
               
            
        }
    } */
    
   function save_module($module)
   {        
		global $adb;
       $deployarray = getSys_deploy(354);//是否开启审批  0是 1否
		if(isset($_REQUEST['createview'])&& $_REQUEST['createview']=='create_view')
		{
		}
		else
		{
			/*$purchasecashback_query = "select total,bankaccountsetid from ld_purchasecashback where purchasecashbackid =?";
			$purchasecashback_result = $this->db->pquery($purchasecashback_query, array($this->id));
			$result_total_old = $this->db->query_result($purchasecashback_result,0,'total');  
			$bankaccountsetid = $this->db->query_result($purchasecashback_result,0,'bankaccountsetid'); 
			$sqls="UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)-$result_total_old WHERE bankaccountsetid=$bankaccountsetid";
			$this->db->pquery($sqls,array());*/

            //ls 20221101 Xuqiu1000213 服务回访单、销售退货单、采购退货单、销售退款单、采购退款单增加“新建”功能（采购退款单编辑时的计算）
            if ($deployarray['deploy_value'] == 1) {//未开启审批
                $this->resetAmount($this->id);
                $this->minusBankMoney($this->id);
            }
		}
		if($_REQUEST['action'] != 'PurchaseCashBackAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
		//Based on the total Number of rows we will save the product relationship with this entity
        crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
			saveInventoryProductDetails($this, 'PurchaseCashBack');
		}
      
		//编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
		if($this->currency_status === true)
		{
			$update_query = "update ld_purchasecashback set currency_id=?, conversion_rate=?,currency_symbol=? where purchasecashbackid=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}

	

       //原来没有选择源单字段时一个退款单仅对应一个退货单，主表退款单金额是一一对应的，现在多个源单时，需要从详情表去统计每个源单的已退金额
       if ($deployarray['deploy_value'] == 1) {//未开启审批
           $this->resetAmount($this->id);
           $this->addBankMoney($this->id);
       }
   }

    function successApprove($record)
    {
        $this->resetAmount($record);
        $this->addBankMoney($record);
    }
    public function rejectApproved($record)
    {
        $this->resetAmount($record);
        $this->minusBankMoney($record);
    }

    //编辑保存前及删除单据时还原已退金额及银行账户
    function resetAmount($record)
    {
       $this->inverseAmount($record);
    }

    //新建保存后、编辑保存后及回收站还原单据后反写已退金额及银行账户
    function inverseAmount($record)
    {
        if (!empty($record)) {
            //反算原单采购退货单 分录的已退款金额、应退款金额
            crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
            cls_Source_InverseCompute::Source_InveverseCompute($this->module_name,$record);

            global $adb;
            $sql='select entitytypeid,entitytype from ld_purchasecashbackdetail where id=? and entitytypeid>0 group by entitytypeid';
            $result=$adb->pquery($sql,array($record));
            $entitytypeid_arr=[];
            $rows=$adb->num_rows($result);
            for($i=0;$i<$rows;$i++)
            {
                $entitytypeid=$adb->query_result($result,$i,'entitytypeid');
                $entitytype=$adb->query_result($result,$i,'entitytype');
                $entitytypeid_arr[$entitytypeid]=$entitytype;

            }

         //edit:can 20230320 62775 采购退货模块，“已退款”字段的金额不对，是真实退款金额的2倍。如图，全部单据都是
              $deployarray = getSys_deploy(354);//是否开启审批  0是 1否
            foreach($entitytypeid_arr as  $entitytypeid=>$entitytype)
            {
                $sourcefocus=CRMEntity::getInstance($entitytype);
                $sourcetablename=$sourcefocus->table_name;
                $sourcetableindex=$sourcefocus->table_index;
                if($deployarray['deploy_value']==1)
                    $sql=" update $sourcetablename  left  JOIN( 
                            select sum( case  when $sourcetablename.currency_id=ld_purchasecashback.currency_id  then ld_purchasecashbackdetail.tax_amount
                            		else ld_purchasecashbackdetail.tax_amount/ld_purchasecashback.conversion_rate*$sourcetablename.conversion_rate  end ) 
                            as havebackamount,
                            		ld_purchasecashbackdetail.entitytypeid
                            			from ld_purchasecashbackdetail
                            
                            INNER JOIN ld_purchasecashback on ld_purchasecashback.purchasecashbackid=ld_purchasecashbackdetail.id
                             INNER JOIN $sourcetablename on $sourcetablename.$sourcetableindex=ld_purchasecashbackdetail.entitytypeid
                            where  ld_purchasecashback.deleted=0 and $sourcetablename.$sourcetableindex=? and   ld_purchasecashbackdetail.entitytypeid=?
                            ) as tmp  on tmp.entitytypeid=$sourcetablename.purchasebackid
                            set $sourcetablename.havebackamount=ifnull(tmp.havebackamount,0)
                            where $sourcetablename.$sourcetableindex=? ";
                else
                     $sql=" update $sourcetablename  left  JOIN( 
                            select sum( case  when $sourcetablename.currency_id=ld_purchasecashback.currency_id  then ld_purchasecashbackdetail.tax_amount
                            		else ld_purchasecashbackdetail.tax_amount/ld_purchasecashback.conversion_rate*$sourcetablename.conversion_rate  end ) 
                            as havebackamount,
                            		ld_purchasecashbackdetail.entitytypeid
                            			from ld_purchasecashbackdetail
                            
                            INNER JOIN ld_purchasecashback on ld_purchasecashback.purchasecashbackid=ld_purchasecashbackdetail.id
                             INNER JOIN $sourcetablename on $sourcetablename.$sourcetableindex=ld_purchasecashbackdetail.entitytypeid
                            where  ld_purchasecashback.approvestatus='".D_A_S_APPROVED."' and $sourcetablename.purchasebackid=? and   ld_purchasecashbackdetail.entitytypeid=?
                            ) as tmp  on tmp.entitytypeid=$sourcetablename.purchasebackid
                            set $sourcetablename.havebackamount=ifnull(tmp.havebackamount,0)
                            where $sourcetablename.$sourcetableindex=? ";
                file_put_contents(globalStatic::$root_directory.'aaatest.txt',"\r\n采购退款单反算"."sql:".$sql."\r\n"."param:".json_encode(array($entitytypeid,$entitytype),JSON_UNESCAPED_UNICODE),FILE_APPEND);
                $adb->pquery($sql,array($entitytypeid,$entitytypeid,$entitytypeid));
                    
                        
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
            INNER JOIN ld_purchasecashback on ld_bankaccountset.Bankaccountsetid=ld_purchasecashback.bankaccountsetid
            set curbalancemoney=ifnull(curbalancemoney,0)+ifnull(ld_purchasecashback.total,0)
            where ld_purchasecashback.purchasecashbackid in( ".$tmprecords.")";

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
            INNER JOIN ld_purchasecashback on ld_bankaccountset.Bankaccountsetid=ld_purchasecashback.bankaccountsetid
             set curbalancemoney=curbalancemoney-ifnull(ld_purchasecashback.total,0)
              where ld_purchasecashback.purchasecashbackid in( ".$tmprecords.")";
        $adb->pquery($sql,array());

    }

    function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;
        
        $this->trash('PurchaseCashBack',$id);
		 
	}
	
}
PurchaseCashBack::require_file();
?>