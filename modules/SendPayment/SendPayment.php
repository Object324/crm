<?php
define("NOSENDCASHBILL",'未付');
define("PARTSENDCASHBILL",'部分已付');
define("ALLSENDCASHBILL",'已付');
class SendPayment extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['SendPayment']='SendPayment';
        
    }
  
    var $log;
    var $db;
    var $table_name='ld_sendpayment';
    public $table_index='sendpaymentid';
    var $table_code='sendpayment_no';//表编号字段(审批中心)
    var $tab_name=Array('ld_crmentity','ld_sendpayment','ld_sendpaymentscf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_sendpayment'=>'sendpaymentid','ld_sendpaymentscf'=>'sendpaymentid');
   	//关联模块
    var $relatedtab=array('purchaseorder'=>'','users'=>'','vendors'=>'','company'=>'','sendpayment'=>'');
    var $customFieldTable = Array('ld_sendpaymentscf', 'sendpaymentid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";

	var $column_fields = Array();
    var $sortby_fields=Array('sendpayment_no,plandate');
    var $module_name='SendPayment';
            
    var $list_link_field= 'sendpayment_no';
            
   	var $search_fields_name = Array(
		
			);
            
            var $required_fields =  array();

//比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'sendpayment_no');
	var $default_order_by = 'sendpayment_no';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="sendpayment_no";
    function __construct()
    {
	  // $this->log =LoggerManager::getLogger('SendPayment');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('SendPayment',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
           /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('SendPayment');
        $this->list_link_field=$entityname['fieldname'];
    }
     /**
      * 获取审批状态字段
      * */
     public function getApproveStatusColumnName()
     {
        return '-1';
        
     }
      public function getApproveStatus_label()
     {
      
        return "-1";
     }
   	function save_module($module)
	{
	    global $adb,$weixin_user;
        /*
        *更新操作
        *edit:diony
        *time:2014-03-14
        *reson:付款计划到期提醒
        */
    
		  //编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
          //edit:can 2021-01-1144208: （本地php72，8.3.6）财务管理-付款计划（需要补丁）；单据CP3，打开付款计划单据详情，编辑保存后，金额数字前的币种符号消失了
			if($this->currency_status === true)
			{
				$update_query = "update ld_sendpayment set currency_id=?, conversion_rate=?,currency_symbol=? where sendpaymentid=?";
				$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
				$this->db->pquery($update_query, $update_params);
			}
          
			//反写付款计划选择的源单
 
		/*	if(!empty($_REQUEST['selectsource']) && !empty($_REQUEST['entitytypeid'])){
				$adb->pquery('update ld_sendpayment set entitytype = ?,Purchaseorder_id = ? where sendpaymentid = ?',array($_REQUEST['selectsource'],$_REQUEST['salesorder_id'],$this->id));
 
			 */
            
            //移动端保存后反写付款计划选择的源单
            if(!empty($_REQUEST['selectsource']) && !empty($_REQUEST['entitytypeid'])){
				$adb->pquery('update ld_sendpayment set entitytype = ?,Purchaseorder_id = ? where sendpaymentid = ?',array($_REQUEST['selectsource'],$_REQUEST['entitytypeid'],$this->id));
			}
            
             $prev_remind_days=getSys_deploy(41);//付款款计划提前提醒天数(为空不提醒)
             if($prev_remind_days['deploy_value']!='')
             {
                $plandate=$_REQUEST['plandate'];
                $sql='select id from ld_automaticreminds where defaultnum=41';
               $result=$adb->pquery($sql,array());
               $reminds_ruleid=$adb->query_result($result,0,0);
               if(DateOperation::addDays($plandate,'-'.$prev_remind_days['deploy_value'])>date("Y-m-d"))
               {
                    
               }
               else
               {
                		$this->retrieve_entity_info($this->id, $module);
                       $sql='delete from ld_reminds where reminds_ruleid=? and related_to=?';
                       $adb->pquery($sql,array($reminds_ruleid,$this->id));
                       $vendor_id=$this->column_fields['vendor_id'];
                       $cpperiodtime=$this->column_fields['cpperiodtime'];
                       
                  
                       $sqlvendor='select ld_vendor.vendorname  from ld_vendor where vendorid= '.$this->column_fields['vendor_id'];
                       $vendor_result=$adb->query($sqlvendor);
                       if($adb->num_rows($vendor_result)>0)
                       {
                                $vendorname=$adb->query_result($vendor_result,0,"vendorname");
                       }
                      $amount=$this->column_fields['amount'];
                      
                       $content=getTranstab('SendPayment')."到期,请及时付款！供应商名称：".$vendorname."，期次：".$cpperiodtime.'，金额：'.$amount;   
                        $focus_rel =CRMEntity::getInstance('Reminds');                    
                        $focus_rel->column_fields['date_time'] =DateOperation::addDays($plandate,'-'.$prev_remind_days['deploy_value']);	  
                        $focus_rel->column_fields['related_to']=$this->id;
                        $focus_rel->column_fields['reltab']='SendPayment';
                        $focus_rel->column_fields['remindstype']='SendPaymentPlanDate';
                        $smownerfieldobj=$this->fieldobj->getFieldInfoobjBykey("columnname",'smownerid');
                        $focus_rel->column_fields['recieverid']=$this->column_fields[$smownerfieldobj->getFieldName()];
                        $focus_rel->column_fields['status_rmd']='未读';
                        $focus_rel->column_fields['content']=$content;
                      
                        $focus_rel->mode="create";
                        $focus_rel->save('Reminds');  
                    
                        $sql='update ld_reminds set reminds_ruleid=? where remindsid=?';
                        $adb->pquery($sql,array($reminds_ruleid,$focus_rel->id));
                }
             }
             //编辑单据反写付款单明细字段
             $sendfocus = CRMEntity::getInstance('SendCashBill');
             $sendfocus->updateSourceInfo($this->id,'SendPayment');
    }
    
      function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'PurchaseOrder' ||$return_module=="Vendors") {
			$this->trash('SendPayment',$id);
		} 
	}

	public function trash($module,$id)
    {
        parent::trash('SendPayment',$id);
        $reminds_focus=new Reminds();
        $reminds_focus->deleteRecord($id,'未读');
        
       
    }

	//获取原单模块
    function getSourceField($recordid)
    {
        global $adb;
        $sql = "select entitytype,purchaseorder_id from ld_sendpayment where sendpaymentid = ?";
        $result=$adb->pquery($sql,array($recordid)); 
		$entitytypeid = $adb->query_result($result,0,'purchaseorder_id');
		if(!empty($entitytypeid)){
			$sourceModuleInfo['module'] = getSalesEntityType($entitytypeid);
		}else{
			$sourceModuleInfo['module'] = '';
		}
        $sourceModuleInfo['sourceid']= $entitytypeid;
        return $sourceModuleInfo;
    }

	function getPurchaseOrder($purchaseorderid){
		global $adb;
		$query = 'select purchaseorder_no,total from ld_purchaseorder where purchaseorderid = ? and deleted = 0';
		$result = $adb->pquery($query,array($purchaseorderid));
		$data['purchaseorder_no'] = $adb->query_result($result,0,'purchaseorder_no');
		$data['total'] = $adb->query_result($result,0,'total');
		return $data;
	}
}
SendPayment::require_file();
?>