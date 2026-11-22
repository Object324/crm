<?php

class SendCashBill extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['SendCashBill']='SendCashBill';
        
         if(empty(globalStatic::$arr_module_require['SendPayment']))
            {
                globalStatic::$arr_module_require['SendPayment']='SendPayment';
                include(globalStatic::$root_directory.'modules/SendPayment/SendPayment.php');

            }
    
         
    }
    var $log;
    var $db;
    var $table_name='ld_sendcashbill';
    public $table_index='sendcashbillid';
    var $table_code='sendcashbill_no';//表编号字段(审批中心)
    var $tab_name=Array('ld_crmentity','ld_sendcashbill','ld_sendcashbillscf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_sendcashbill'=>'sendcashbillid','ld_sendcashbillscf'=>'sendcashbillid');
   	var $customFieldTable = Array('ld_sendcashbillscf', 'sendcashbillid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";
    var $Detail_table="ld_sendcashbill2payment";//明细表名称
    var $Detail_table_index="sendcashbillid";
    var $Detail_table_id="sendcashbill2payment_id";//明细表和主表关联ID
    var $Detail_table_scf = "ld_sendcashbill2paymentscf";//明细scf表    
    var $popup_fields=array();
	var $column_fields = Array();
    var $sortby_fields=Array('sendcashbill_no,cashbilldate');
    var $module_name='SendCashBill';
    /*
    edit:can
    date:20131024
    reason:打印关模块
    */
    var $relatedtab=array('vendors'=>'','users'=>'','company'=>'','purchaseorder'=>'','sendcashbill'=>'');
            
    var $list_link_field= 'sendcashbill_no';
            
            
   	var $search_fields_name = Array(
		          
			);
            
   var $required_fields =  array();

//比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'sendcashbill_no');
	var $default_order_by = 'sendcashbill_no';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="sendcashbill_no";
    var $detailfieldobj;//明细表字段对象
    function __construct()
    {
	   //$this->log =LoggerManager::getLogger('SendCashBill');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('SendCashBill',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
           /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('SendCashBill');
        $this->list_link_field=$entityname['fieldname'];
        $this->popup_fields=Array($this->list_link_field);
        crm_load_class_file('TabDetailFields','include/TabDetailFields');
        $this->detailfieldobj=TabDetailFields::getInstance($this->module_name);
    }
	//根据源单类型重设分录字段对象
    function Resetdetailfieldobj($sourceModule=''){
        crm_load_class_file('TabDetailFields','include/TabDetailFields');
        $TabDetailFields = new TabDetailFields(getTabid("CashBill"));
        if(empty($sourceModule)){
            $selectlistval = $this->column_fields['selectlistval'];
            $selectlistval_arr=explode(",",$selectlistval);
            if(!empty($selectlistval_arr)){
                $sourceModule = getSalesEntityType($selectlistval_arr[0]);//获取对应模块
            }
        }
        $TabDetailFields->setsourceModulesqlwhere($sourceModule);
        $this->detailfieldobj=TabDetailFields::getInstance($this->module_name);
        $this->detailfieldobj->setsourceModulesqlwhere($sourceModule);
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
                    $becurrency_rate = $this->before_currencyobj->getCurrencyRate();
                if($becurrency_id ==1)//编辑前的币种人民币
        			{
        				$query = "update ld_sendcashbill set total = total*?,nosendpayment=nosendpayment*?,subtotal = subtotal*? where sendcashbillid = ?";
        				$adb->pquery($query,array($conversion_rate,$conversion_rate,$conversion_rate,$this->id));
        				$query2payment = "update ld_sendcashbill2payment set amount = amount/? where sendcashbillid = ?";
        				$adb->pquery($query2payment,array($conversion_rate,$this->id));
        			}
        			else
        			{
        				$query = "update ld_sendcashbill set total = total/?*?,nosendpayment=nosendpayment/?*?,subtotal = subtotal*?/? where sendcashbillid = ?";
        				$adb->pquery($query,array($becurrency_rate,$conversion_rate,$becurrency_rate,$conversion_rate,$becurrency_rate,$conversion_rate,$this->id));
        				$query2payment = "update ld_sendcashbill2payment set amount = amount*?/? where sendcashbillid = ?";
        				$adb->pquery($query2payment,array($becurrency_rate,$conversion_rate,$this->id));
        			}
         }
        // $setsystem_check = getSys_deploy(84);
        //if(($_REQUEST['currency_id_mass_edit_check']||$_REQUEST['bankaccountsetid_mass_edit_check'])&&$setsystem_check['deploy_value']==0)
                  //  $this->addBankMoney($ids);//save_module函数已调用了
    }
    /**
     * 批量修改保存(保存以后)
     * ids:单据id的集合(数组)
     * */
    function  massEdit_save_after($module,$ids)
    {
        global $adb;
        parent::massEdit_save_after($module,$ids);
        if(($_REQUEST['currency_id_mass_edit_check']||$_REQUEST['cashbilldate_mass_edit_check']!='')&&sizeof($ids)>0)
        {
             $sendcashbillids=implode(',',$ids);
            $sql="select GROUP_CONCAT(tmp.sendpaymentid) from (
                        select sendpaymentid  from ld_sendcashbill2payment where sendcashbillid in($sendcashbillids)   GROUP BY sendpaymentid) as tmp";
        
            $sendcashbill_result=$adb->pquery($sql,array());
            if($adb->num_rows($sendcashbill_result)>0)
            {
                $Sendpaymentidlist=$adb->query_result($sendcashbill_result,0,0);
                $this->update_SendPaymentActualamount($Sendpaymentidlist);
            }
        }
       /// $setsystem_check = getSys_deploy(84);
       // if(($_REQUEST['currency_id_mass_edit_check']||$_REQUEST['bankaccountsetid_mass_edit_check'])&&$setsystem_check['deploy_value']==0)
            //        $this->minusBankMoney($ids);
    }
    //获取源单已付总额，源单总额等信息更新付款单明细表相应字段
    function updateSourceInfo($entitytypeids,$sourcemodule)
    {
        global $adb;
         if(is_array($entitytypeids)){
            $entitytypeids=array_unique($entitytypeids);
        }else{
            if(!empty($entitytypeids)){
                $entitytypeids=array($entitytypeids);
            }
        }
        
        if(empty($entitytypeids)||empty($entitytypeids[0])) return;
        $source_focus = CRMEntity::getInstance($sourcemodule);
       

        $entitynamearr = getEntityName($sourcemodule,$entitytypeids);
        foreach($entitytypeids as $entitytypeid){
            //zkt 20221031 BUG0058188付款单审批流程，在审批过程中修改之后保存，一直在转圈，刷新后还保存不了
            if(empty($entitytypeid)){
                continue;
            }
            if(empty($source_focus)){
                $tmpsourcemodule =  getSalesEntityType($entitytypeid);
                $source_focus = CRMEntity::getInstance($tmpsourcemodule);
                $entitynamearr = getEntityName($tmpsourcemodule,$entitytypeids);
            }
            if($sourcemodule == 'SendPayment'){
                $query = "select amount as source_total,actualamount as pay_amount,currency_id,conversion_rate,currency_symbol from $source_focus->table_name where $source_focus->table_index = $entitytypeid";
            
                //付款计划付款，反写采购订单单据相关的付款单明细信息
                $sendpayment_sql = "select purchaseorder_id from ld_sendpayment where sendpaymentid=$entitytypeid";
                $result = $adb->pquery($sendpayment_sql);
                if($adb->num_rows($result)>0){
                    $this->updateSourceInfo($adb->query_result($result,0,'purchaseorder_id'),'PurchaseOrder');
                }
            }else{
                $query = "select total as source_total,pay_amount as pay_amount,currency_id,conversion_rate,currency_symbol from $source_focus->table_name where $source_focus->table_index = $entitytypeid";
            }
            
            $source_result = $adb->pquery($query,array());
            
            //zkt 20230620 BUG0068537 客户在保存付款单的时候，一直在转圈，不会自己停下，也没有报错。
            if($adb->num_rows($source_result)>0){
                $source_total = $adb->query_result($source_result,0,'source_total');
                $pay_amount = $adb->query_result($source_result,0,'pay_amount');
                $currency_id = $adb->query_result($source_result,0,'currency_id');
                $conversion_rate = $adb->query_result($source_result,0,'conversion_rate');
                $currency_symbol = $adb->query_result($source_result,0,'currency_symbol');
                $entityname = $entitynamearr[$entitytypeid];
                $updatesql = "update ld_sendcashbill2payment set source_total=?,pay_amount=?,entitytype_value=?,
                        currency_id=?,conversion_rate=?,currency_symbol=? where entitytypeid=?";
                $adb->pquery($updatesql,array($source_total,$pay_amount,$entityname,$currency_id,$conversion_rate,$currency_symbol,$entitytypeid));
            }
        }
    }
    public function before_save($id)
    {
        $setsystem_check = getSys_deploy(84);//是否统计已审批单据，0：是
        if($setsystem_check['deploy_value']==0&&$this->id>0)
        {
            $this->addBankMoney($id);
        }
    }
   function  save_module()
   {
    	 global $adb;
        $i=1;
        if($_REQUEST['action'] != 'SendCashBillAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
		  
        }
        else
        {
            $setsystem_check = getSys_deploy(84);//是否统计已审批单据，0：是
            if($setsystem_check['deploy_value']==0)
            {
                $this->minusBankMoney($this->id);
            }
            //查看界面的小编辑和批量修改
            return ;
        }
     
         $sql='select entitytype,entitytypeid from ld_sendcashbill2payment  where sendcashbillid=? and entitytype=?';
         $result=$adb->pquery($sql,array($this->id,'SendPayment'));
         $num_rows=$adb->num_rows($result);
         $old_entitypeids = [];
         for($i=0;$i<$num_rows;$i++)
         {
            //获取保存前原单，用于修改已付总额，付款计划状态
            $old_entitypeids[]=$adb->query_result($result,$i,'entitytypeid');
         }
         //edit can 20210331 045233: (http://42.193.112.228:85/crm [^])；客户—北京永和嘉业房地产经纪有限公司；付款计划已下推付款单并保存，但付款计划状态未改变              
        $sourceModule = $_REQUEST['selectsourcename'];
      
		//编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
        if($this->currency_status === true)
        {
			$update_query = "update ld_sendcashbill set currency_id=?, conversion_rate=?,currency_symbol=? where sendcashbillid=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
        }

       //保存分录封装到一个方法中,方便其他地方调用
       $return_arr = $this->SaveModuleDetail();

       $now_entitypeids = $return_arr['now_entitypeids'];
        

        $SqlUpdate="update ld_sendcashbill set total=?,subtotal=? ,nosendpayment=? where sendcashbillid=?";
        if(!empty($_REQUEST['nosendpayment'])){
            $nopaymentplan = $_REQUEST['nosendpayment'];    //调整金额
        }else{
            $nopaymentplan=0;
        }
		if($_REQUEST['otherselect'] != 1){//调整（增加或减少),1:增加
			$nopaymentplan = 0 - $_REQUEST['nosendpayment'];
		}
        if(!empty($_REQUEST['subtotal'])){
            $subtotal = $_REQUEST['subtotal'];    //调整金额
        }else{
            $subtotal = 0;
        }

        $total = $subtotal+$nopaymentplan;
		if($_REQUEST['sendcashbill_total']){
			$total = $subtotal = $_REQUEST['sendcashbill_total'];
		}
        $adb->pquery($SqlUpdate,array($total,$subtotal,$nopaymentplan,$this->id));
        
        if(sizeof($old_entitypeids)>0&&sizeof($now_entitypeids)>0)
                $entitytypeids=array_merge($old_entitypeids,$now_entitypeids);
        else if(sizeof($old_entitypeids)>0)
            $entitytypeids=$old_entitypeids;
        else
            $entitytypeids=$now_entitypeids;
      
        if(is_array($entitytypeids)&&sizeof($entitytypeids)>0)
        {
            $entitytypeids=array_unique($entitytypeids);
            $this->update_SendPaymentActualamount(implode(',',$entitytypeids));
         
        }
        $setsystem_check = getSys_deploy(84);//已付金额计算时是否统计未审核的付款单，0：是
        if($setsystem_check['deploy_value']==0)
        {
            $this->minusBankMoney($this->id);
        }
         
         //回款计划的已收金额计算存入触发器
   }
   
   /**
     * $records:按钮操作的ID集合
     * 修改银行账户添加金额 （编辑/批量编辑保存前，删除，批量删除,反审核，反审批)
     * */
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
            INNER JOIN ld_sendcashbill on ld_bankaccountset.Bankaccountsetid=ld_sendcashbill.bankaccountsetid
            set curbalancemoney=curbalancemoney+ifnull(ld_sendcashbill.total,0)
            where ld_sendcashbill.sendcashbillid in( ".$tmprecords.")";
        $adb->pquery($sql,array());
         
    }
     /**
     * $records:按钮操作的ID集合
     * 修改银行账户减少金额（编辑/批量编辑保存后，审核，审批)
     * */
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
            INNER JOIN ld_sendcashbill on ld_bankaccountset.Bankaccountsetid=ld_sendcashbill.bankaccountsetid
             set curbalancemoney=curbalancemoney-ifnull(ld_sendcashbill.total,0)
              where ld_sendcashbill.sendcashbillid in( ".$tmprecords.")";
        $adb->pquery($sql,array());
         
    }
    function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Vendors'||$return_module=="PurchaseOrder"||$return_module=="SendPayment"  ) {
			$this->trash('SendCashBill',$id);
		} 
	}
    /**
     * edit:Can
     * date:20140107
     * reason:付款单删除
     * */
    function trash($module, $id)
    {
        
        global $adb;
        $setsystem_check = getSys_deploy(84);//是否统计已审批单据，0：是
        if($setsystem_check['deploy_value']==0)
        {
            $this->addBankMoney($id);
        }
        $sql="select entitytypeid,amount,ld_sendcashbill.currency_id,ld_sendcashbill.conversion_rate from ld_sendcashbill2payment 
                LEFT JOIN ld_sendcashbill on ld_sendcashbill.sendcashbillid = ld_sendcashbill2payment.sendcashbillid where ld_sendcashbill2payment.sendcashbillid= $id";
        $result=$adb->pquery($sql,array());
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
         
            
            $sendpaymentid=$adb->query_result($result,$i,"entitytypeid");
           
            $sendpaymentidList.=$sendpaymentid.',';
        }
       // parent::trash($module,$id);
       $sql='delete from ld_sendcashbill where sendcashbillid=?';
       $adb->pquery($sql,array($id));
       
       $sql='delete from ld_crmentity where crmid=?';
       $adb->pquery($sql,array($id));
       
       
       $selectsql = "select entitytypeid,entitytype from ld_sendcashbill2payment where sendcashbillid = ?";
       $result = $adb->pquery($selectsql,array($id));
       for($i=0;$i<$adb->num_rows($result);$i++)
       {
            $entitytypeids[]=$adb->query_result($result,$i,"entitytypeid");//收款单对应的回款计划ID   
            $sourcemodule = $adb->query_result($result,$i,"entitytype");
       }
       
       $sql='delete from ld_sendcashbill2payment where sendcashbillid=?';
       $adb->pquery($sql,array($id));
       //重新计算付款单对应付款计划的已付金额
       $sendpaymentidList=substr($sendpaymentidList,0,strlen($sendpaymentidList)-1); 
       $this->update_SendPaymentActualamount($sendpaymentidList);
       $this->updateSourceInfo($entitytypeids,$sourcemodule);
       $this->updateSourceMainamount($entitytypeids,$sourcemodule);
       $this->updateSourceDetailamout($entitytypeids,$sourcemodule);
    }
    /*
    edit:can
    date:20130620
    reason:付款单还原后，也要还原相关的付款计划
    */
    function restore($module, $id)
    {
        parent::restore($module,$id);
       
    }
     function MassSave($modules,$columns)
      {
             global $adb,$current_user;
            $this->db->println("TRANS saveentity starts $module");
           
            if($_REQUEST['SendCashBillDate']=='curdate')
            {
                $actualdate=date("Y-m-d");
            }
            else if($_REQUEST['SendCashBillDate']=='customdate')
            {
                $actualdate=$_REQUEST['cashdate'];
            } 
            $entitytime=date('Y-m-d H:i:m',time());
        	$this->db->startTransaction();
            $i=1;
            while(true)
            {
                if(!isset($_REQUEST['thistime'.$i]))
                {
                    break;
                }
                
                if($_REQUEST['chkPayment'.$i]!="0")
                {
                    $i++;
                    continue;
                }
             
                $sendpaymentid=$_REQUEST['SysBol'.$i];
                //$actualamount=$_REQUEST['actualamount'.$i];
                $thistime=$_REQUEST['thistime'.$i];
                $iscashbill=$_REQUEST['criscashbill'.$i];
                $paymentmethod=$_REQUEST['crpaymentmethod'.$i];
                $purchaseorderid=$_REQUEST['purchaseorder'.$i];
                $vendorid=$_REQUEST['vendor'.$i];
                $bankaccountsetid=$_REQUEST['bankaccountsetid'.$i];
                $current_id=$adb->getUniqueID("ld_crmentity");
                $smownerid=$current_user->id;
              
                 if($_REQUEST['SendCashBillDate']=='plandate')
                 {
                        $sql='select plandate from ld_sendpayment where sendpaymentid=?';
                        $paymentresult=$adb->pquery($sql,array($sendpaymentid));
                        if($adb->num_rows($paymentresult)>0)
                        {
                            $actualdate=$adb->query_result($paymentresult,0,0);
                        }
                 }     
				$currencyinfo = getModuleCurrencyInfo($sendpaymentid,'SendPayment');
                $sql="insert into ld_crmentity(crmid,setype)
                                                values(?,?)";
                                                
                $adb->pquery($sql,array($current_id,"SendCashBill"));
                
                $CashBillNo=$this->Library('SystemCode')->setModuleSeqNumber("increment", "SendCashBill"); 
               
                $sql="insert into ld_sendcashbill(sendcashbillid,source_list,entitytype ,sendcashbill_no,vendorid,purchaseorder_id,cashbilldate,crpaymentmethod,criscashbill,total,subtotal,nosendpayment,smcreatorid,smownerid,modifiedby,createdtime,modifiedtime,bankaccountsetid,currency_id,conversion_rate,currency_symbol)
                                        values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                $adb->pquery($sql,array($current_id,$sendpaymentid,"SendPayment",$CashBillNo,$vendorid,$purchaseorderid,$actualdate,$paymentmethod,$iscashbill,$thistime,$thistime,0.00,$smownerid,$smownerid,$smownerid,$entitytime,$entitytime,$bankaccountsetid,$currencyinfo['curid'],$currencyinfo['rate'],decode_html($currencyinfo['symbol'])));                  
                
                $sql="insert into ld_sendcashbill2payment(sendcashbillid,sendpaymentid,amount,sequence,sendcashbillstatus,entitytypeid,entitytype)
                        values(?,?,?,?,?,?,?)";
                $adb->pquery($sql,array($current_id,$sendpaymentid,$thistime,$i,0,$sendpaymentid,'SendPayment'));
				$sendpaymentplanid_arr[] = $sendpaymentid;
                // 已付金额计算时是否统计未审核的付款单  删除后重新计算已付金额
                /*if($this->get_SendCashBillCheckoutstatusWhere()=='')
                {
                        $sql="update ld_sendpayment set actualamount=amount,cpstatus='已付',actualdate=? where sendpaymentid=?";
                         
                         $adb->pquery($sql,array($actualdate,$sendpaymentid));    
                         $this->deleteReminds($sendpaymentid);
                    
                }*/
				//因为插入不会调用触发器，所以在这update一下，更新订单的已付总额
				$adb->pquery('update ld_sendcashbill set sendcashbillid = ? where sendcashbillid = ?',array($current_id,$current_id));
                $i++;
            }
            $this->update_SendPaymentActualamount(implode(',',$sendpaymentplanid_arr));
        	$this->db->completeTransaction();
        	$this->db->println("TRANS saveentity ends");
      }
      
      
      
    /**
     * 删除付款计划所对应的提醒
     * 
     * */
    private function deleteReminds($sendpaymentid)
    {
        crm_load_class_file('Reminds','modules/Reminds');
         $remind_focus=new Reminds();
         $remind_focus->deleteRecord($sendpaymentid,'未读') ;
    }
    /**
    *andrew
    * 2015-10-19
    * 重新计算付款计划已付款金额
    **/
	function update_SendPaymentActualamount($Sendpaymentidlist)
	{
		global $adb,$current_user;
        if (empty($Sendpaymentidlist)) {
            return;
        }
        /**
        *SQL说明：获取付款单id,已付金额，最近付款日期，付款计划金额
        * 已付金额：付款单金额转人民币金额->转付款计划币种金额
        */
        $selectSQL="SELECT ld_sendpayment.sendpaymentid,
					SUM(
                    		IFNULL(
                    
                    			IF (
                    				ld_sendpayment.currency_id > 1,
                    
                    			IF (
                    				ld_sendcashbill.currency_id > 1,
                    				ld_sendcashbill.amount / ifnull(
                    					ld_sendcashbill.conversion_rate,
                    					1
                    				),
                    				ld_sendcashbill.amount
                    			) * ifnull(
                    				ld_sendpayment.conversion_rate,
                    				1
                    			),
                    
                    		IF (
                    			ld_sendcashbill.currency_id > 1,
                    			ld_sendcashbill.amount / ifnull(
                    				ld_sendcashbill.conversion_rate,
                    				1
                    			),
                    			ld_sendcashbill.amount
                    		)
                    			),
                    			0
                    		)
                    	) AS actualamount,
					

                    ld_sendpayment.amount,ifnull(max(cashbilldate),'0000-00-00') as actualdate,CPStatus 
                    FROM ld_sendpayment 
                   	LEFT JOIN (
                    	SELECT entitytypeid,
                    		ld_sendcashbill2payment.amount,ld_sendcashbill.sendcashbillid,ld_sendcashbill.currency_id,ld_sendcashbill.conversion_rate,cashbilldate
                    	FROM
                    		ld_sendcashbill 
                    INNER JOIN ld_sendcashbill2payment ON ld_sendcashbill.sendcashbillid = ld_sendcashbill2payment.sendcashbillid
                    	WHERE
                    		deleted = 0 "
                    .$this->get_SendCashBillCheckoutstatusWhere().") as
                    ld_sendcashbill ON ld_sendcashbill.entitytypeid=ld_sendpayment.sendpaymentid
                    WHERE ld_sendpayment.sendpaymentid in ($Sendpaymentidlist) AND ld_sendpayment.deleted=0 
                     GROUP BY ld_sendpayment.sendpaymentid";

        $actualamountresult=$adb->pquery($selectSQL,array());
    
        $rowCount = $adb->num_rows($actualamountresult);
        for ($i = 0; $i < $rowCount; $i++) {
            $sendpaymentid=$adb->query_result($actualamountresult,$i,'sendpaymentid');
            $actualamount=$adb->query_result($actualamountresult,$i,'actualamount');
            $actualdate=$adb->query_result($actualamountresult,$i,'actualdate');
            $amount=$adb->query_result($actualamountresult,$i,'amount');
			$CPStatus=$adb->query_result($actualamountresult,$i,'cpstatus');
            if(empty($CPStatus)){
				$CPStatus = '未付';
			}
            //付款计划金额和已付金额比对出付款状态
            if($actualamount + 0.1 >=$amount)
            {
                $paymentstatus='已付';
                $this->deleteReminds($sendpaymentid);
                
            }
            elseif($actualamount<=0)
            {
                $paymentstatus="未付";
            }
            else
            {
                $paymentstatus='部分已付';
            }
			//chj 2021/8/4 47242: （https://kehu001.com/weixin/kh44095 [^]）（客户问题-合肥山河教育） 付款计划跟踪进度设置指定字段为收款状态，状态变更时进度条不推进
            if($CPStatus != $paymentstatus){
				$time = date('Y-m-d H:i:s',time());$status = 0;
				$id = $adb->getUniqueID('ld_modtracker_basic');
				$query = 'insert into ld_modtracker_basic(id,crmid,module,whodid,changedon,status) 
									values(?,?,?,?,?,?);';
				$adb->pquery($query,array($id,$sendpaymentid,'SendPayment',$current_user->id,$time,$status));
				$query = 'insert into ld_modtracker_detail(id,fieldname,prevalue,postvalue) values(?,?,?,?);';
				$adb->pquery($query,array($id,'cpstatus',$CPStatus,$paymentstatus));
			}
    		$query = "UPDATE ld_sendpayment SET actualamount=?,actualdate=?,cpstatus=? WHERE ld_sendpayment.sendpaymentid=?;";
            
            $adb->pquery($query,array($actualamount,$actualdate,$paymentstatus,$sendpaymentid));
            //edit: xll 2023/08/03 BUG0070577 付款计划状态改变，自动化进度字段值也需要更新
            $this->save_advancestage($sendpaymentid,'SendPayment');
        }
      
	}
    
    /**
    *andrew
    * 2015-10-19
    * 已付金额计算时是否统计未审核的付款单,参数判断返回where条件
    **/
	function get_SendCashBillCheckoutstatusWhere()
	{
		global $adb;
		//付款单是否启用审批流程  0是 1 否
		$setsystem_approve = getSys_deploy(134);
        $setsystem_check = getSys_deploy(84);
		if($setsystem_approve['deploy_value']==0){
			if($setsystem_check['deploy_value']==1){
				return ' and ifnull(ld_sendcashbill.checkoutstatus,"")=\'已审核\' and ifnull(ld_sendcashbill.approvestatus,"") <> \'已拒绝\' ';
			}else{
				return ' and ifnull(ld_sendcashbill.approvestatus,"") <> \'已拒绝\' ';		
			}
		}else{
			
			if($setsystem_check['deploy_value']==1){
				return ' and ifnull(ld_sendcashbill.checkoutstatus,"")=\'已审核\' ';
			}else{
				return '';		
			}
		}
	}

	//获取付款计划的源单tab
	function getSourceField($fieldname,$recordid)
    {
        global $adb;
        if($recordid > 0)
        {                
            $sql = "select entitytype from ld_sendcashbill where sendcashbillid = ? and entitytype is not NULL limit 1";
            $result = $adb->pquery($sql,array($recordid));
            return $adb->query_result($result,0,0);
        }
        
        return '';
    }

	/**
	 * 付款单  - 审核操作
	 * @param $record：付款单id
	 * @return
	 * @author Chj
	 */
	function updateSendCashBillStatus($record) 
	{
		global $adb,$current_user;
		$sql = "update ld_sendcashbill set checkoutstatus='已审核',checker=$current_user->id ,approveby=?,approvestatus=?,approvetime=? where deleted=0 and sendcashbillid in ($record)"; 
		$adb->pquery($sql,array($current_user->id,D_A_S_APPROVED,date("Y-m-d H:i:s")));
     
		$this->updateSendCashbillSourceDetail($record);  
		$smongysql = "SELECT bankaccountsetid,total FROM ld_sendcashbill WHERE checkoutstatus='已审核' and sendcashbillid in ($record)";
		$result = $adb->pquery($smongysql);
		$num_rows = $adb->num_rows($result);
		/*if($num_rows >= 1){
			for($i=0;$i<$num_rows;$i++){
				$account = $adb->query_result($result,$i,'bankaccountsetid');
				$monery = $adb->query_result($result,$i,'total');
				$usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)-$monery WHERE deleted=0 and bankaccountsetid=$account";
				$adb->pquery($usql,array());
			}
	
		}*/
        $records=explode(",",$record);
         $setsystem_check = getSys_deploy(84);//是否统计已审批单据，0：是
        if($setsystem_check['deploy_value']==1)
             $this->minusBankMoney($record);
        global $adb;
		$getPaymentIdSQL="SELECT DISTINCT ld_sendcashbill2payment.entitytypeid FROM ld_sendcashbill 
							INNER JOIN ld_sendcashbill2payment ON ld_sendcashbill.sendcashbillid = ld_sendcashbill2payment.sendcashbillid
							INNER JOIN ld_sendpayment ON ld_sendpayment.sendpaymentid = ld_sendcashbill2payment.entitytypeid
							WHERE ld_sendpayment.deleted=0 AND ld_sendcashbill.sendcashbillid in ($record)";
		$PaymentIdresult=$adb->pquery($getPaymentIdSQL,array());
		for($i=0;$i<$adb->num_rows($PaymentIdresult);$i++){
			$paymentidlist .= $adb->query_result($PaymentIdresult,$i,'entitytypeid').',';
		}
		$paymentidlist=substr($paymentidlist,0,strlen($paymentidlist)-1);
         
         $this->update_SendPaymentActualamount($paymentidlist);
           
	}
	
	/**
	 * 付款单  - 反审核
	 * @param $record：付款单id
	 * @return
	 * @author Chj
	 */
	function upadteBackSendCashBillStatus($record) 
	{
		global $adb;
		$query = 'select checkoutstatus from ld_sendcashbill where sendcashbillid = ?';
		$result = $adb->pquery($query,array($record));
		$before_checkoutstatus = $adb->query_result($result,0,0);
        //edit:can 2020-09-07 42598: (61mis.com/kfcrm)客户问题（美迪），付款单模块>选择编号为“CR75 ”进入单据详情界面：点击“提交审批”按钮，然后再点击“审批”选择“审批失败，结束流程”点击确认，审批状态没有更新为“已拒绝”
		$sql = "update ld_sendcashbill set checkoutstatus='未审核', checker=0,approveby=0,approvetime=?  where deleted=0 and sendcashbillid = ?";  
		$adb->pquery($sql,array(null,$record));   

        	$this->updateSendCashbillSourceDetail($record);

		if($before_checkoutstatus == '已审核'){
		//	$usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)+? WHERE deleted=0 and bankaccountsetid=?";
		$setsystem_check = getSys_deploy(84);//是否统计已审批单据，0：是
        if($setsystem_check['deploy_value']==1)
            $this->addBankMoney(array($record));
        
        
		}
		$this->updateSendPaymentActualamount($record);//审核后重新计算已收款金额
	}

	//审核后重算付款单明细表字段
	function updateSendCashbillSourceDetail($record){
		global $adb;
   
		$ids = explode(',',$record);
      
		foreach($ids as $sendcashbillid){
			$selectsql = "select entitytypeid,entitytype from ld_sendcashbill2payment where sendcashbillid = ?";
			$result = $adb->pquery($selectsql,array($sendcashbillid));
			for($i=0;$i<$adb->num_rows($result);$i++)
			{
				$entitytypeids[]=$adb->query_result($result,$i,"entitytypeid");//收款单对应的回款计划ID   
				$sourcemodule = $adb->query_result($result,$i,"entitytype");
			}

		}
		if(!empty($sourcemodule)){
            $this->updateSourceInfo($entitytypeids,$sourcemodule);
        }
	}
    
     public function updateSourceMainamount($entitytypeid_arr,$sourcemodule)
    {
        if($sourcemodule=='PurchaseOrder'||$sourcemodule=='PurchaseInvoice'||$sourcemodule=='Stock'||$sourcemodule=='SendPayment')
            return ;
        global $adb;
            $sourcemodulearr = getSourceModule($this->moduleName);
            $isproductsourcemodule = '';
            foreach($sourcemodulearr as $sourcemoduleinfo){
                if($sourcemoduleinfo['entitytype']==$sourcemodule){
                    $isproductsourcemodule = 'yes';
                }
            }
            if(empty($isproductsourcemodule)||sizeof($entitytypeid_arr)<=0){
                return ;
            }
          $source_focus=CRMEntity::getInstance($sourcemodule);
          $source_Table_name = $source_focus->table_name;
          $source_table_index=$source_focus->table_index;
          $table_name = $this->table_name;
          $table_index = $this->table_index;
           $Detail_table_id = $this->Detail_table_id;
        $Detail_table_index = $this->Detail_table_index;
        $DetailTable_name = $this->Detail_table;
          $strentitytypid=implode(",",$entitytypeid_arr);
   	    $cashbillwheresql =  $this->get_SendCashBillCheckoutstatusWhere();
      $sql="update $source_Table_name LEFT JOIN (select sum(case when $source_Table_name.currency_id=$table_name.currency_id then amount 
            else  amount/$table_name.conversion_rate*$source_Table_name.conversion_rate end)  as sumamount,$DetailTable_name.entitytypeid
             from $DetailTable_name
            
            INNER JOIN $table_name on $table_name.$table_index=$DetailTable_name.$Detail_table_index
            inner join $source_Table_name  on $DetailTable_name.entitytypeid=$source_Table_name.$source_table_index
            where $DetailTable_name.entitytypeid in($strentitytypid) $cashbillwheresql
             group by entitytypeid )  as tmpsum  
            on tmpsum.entitytypeid=$source_Table_name.$source_table_index 
            set  $source_Table_name.pay_amount=tmpsum.sumamount ,$source_Table_name.pay_balance=$source_Table_name.total-ifnull(tmpsum.sumamount,0)
           where $source_Table_name.$source_table_index in($strentitytypid)
            ";
      $adb->pquery($sql);
          
    }
    //zkt 20220816 更新源单产品已付总额
    function updateSourceDetailamout($entitytypeid_arr,$sourcemodule){
        global $adb;
        $sourcemodulearr = getSourceModule($this->moduleName);
        $isproductsourcemodule = 'no';
        foreach($sourcemodulearr as $sourcemoduleinfo){
            if($sourcemoduleinfo['entitytype']==$sourcemodule&&$sourcemoduleinfo['withdetail']=='yes'){
                $isproductsourcemodule = 'yes';
                break;
            }
        }
       
        if($isproductsourcemodule != 'yes'){
            return ;
        }
        
        $source_focus=CRMEntity::getInstance($sourcemodule);
        $table_name = $this->table_name;
        $table_index = $this->table_index;
        $DetailTable_name = $this->Detail_table;
        $Detail_table_id = $this->Detail_table_id;
        $Detail_table_index = $this->Detail_table_index;
        $DetailTable_name = $this->Detail_table;
         $source_Table_name = $source_focus->table_name;
        $source_DetailTable_name = $source_focus->Detail_table;
        $source_Detail_table_id = $source_focus->Detail_table_id;
        $source_Detail_table_index = $source_focus->Detail_table_index;
      
        $sourcetable_index=$source_focus->table_index;
         
        $strentitytypid=implode(",",$entitytypeid_arr);
    	$sendcashbillwheresql = $this->get_SendCashBillCheckoutstatusWhere();
         $sql=  "  update $source_DetailTable_name
         left join (
        
        select sum( case when ($table_name.currency_id=$source_Table_name.currency_id) then amount
        		else  amount/$table_name.conversion_rate*$source_Table_name.conversion_rate end ) as havepayamount,parent_lineitem_id
                     from $table_name INNER JOIN $DetailTable_name
        
        on $DetailTable_name.$table_index=$table_name.$table_index
        inner join $source_Table_name on $source_Table_name.$sourcetable_index=$DetailTable_name.entitytypeid
        where $table_name.deleted=0 and  $DetailTable_name.entitytypeid in($strentitytypid)  $sendcashbillwheresql
            and $DetailTable_name.entitytype='$sourcemodule'
        group by $DetailTable_name.parent_lineitem_id
        ) as tmp on tmp.parent_lineitem_id=$source_DetailTable_name.lineitem_id
        set $source_DetailTable_name.havepayamount=tmp.havepayamount,
        balancepayamount=$source_DetailTable_name.tax_amount-ifnull(tmp.havepayamount,0)
         where $source_DetailTable_name.$source_Detail_table_index in($strentitytypid)";
         $adb->pquery($sql,array());
       
         return false;
         
		$sendcashbillwheresql = $this->get_SendCashBillCheckoutstatusWhere();
        $change_amount_arr = array();//单据保存涉及到的源单。
        foreach($before_db_value as $before_lineitem_id =>$before_value_arr){
            if(!array_key_exists($before_value_arr['entitytypeid'],$change_amount_arr)){
                $entitytypeid = $before_value_arr['entitytypeid'];
                $sourcemodulename = getSalesEntityType($entitytypeid);
                $change_amount_arr[$sourcemodulename][] = $entitytypeid;
            }
        }
        foreach($all_detailvalue as $new_lineitem_id =>$new_value_arr){
            if(!array_key_exists($new_value_arr['entitytypeid'],$change_amount_arr)){
                $entitytypeid = $new_value_arr['entitytypeid'];
                $sourcemodulename = getSalesEntityType($entitytypeid);
                $change_amount_arr[$sourcemodulename][] = $entitytypeid;
            }
        }
        $DetailTable_name = $this->Detail_table;
        $table_name = $this->table_name;
        $table_index = $this->table_index;
        $DetailTable_name = $this->Detail_table;
        $Detail_table_id = $this->Detail_table_id;
        $Detail_table_index = $this->Detail_table_index;
        foreach($change_amount_arr as $sourcemodulename=>$entitytypeid_arr)
        {
            //反写产品已收金额至产品分录
            if(!empty($sourcemodulename)&&get_file_address($sourcemodulename,'ProductDetails')){
                $entitytypeids = implode(',',$entitytypeid_arr);
                $source_focus = CRMEntity::getInstance($sourcemodulename);
                $source_Table_name = $source_focus->table_name;
                $source_DetailTable_name = $source_focus->Detail_table;
                $source_Detail_table_id = $source_focus->Detail_table_id;
                $source_Detail_table_index = $source_focus->Detail_table_index;
                
                $sql = "update $source_DetailTable_name 
                left join ( select sum(amount) as havepayedamount,parent_lineitem_id from $DetailTable_name 
                    left join $table_name on $table_name.$table_index = $DetailTable_name.$Detail_table_index
                    where $table_name.deleted = 0 $sendcashbillwheresql
                 GROUP BY parent_lineitem_id) as tmp
                on tmp.parent_lineitem_id=$source_DetailTable_name.$source_Detail_table_id
                set $source_DetailTable_name.havepayedamount = tmp.havepayedamount 
                where $source_DetailTable_name.$source_Detail_table_index in ($entitytypeids)";
                $adb->pquery($sql,array());
            }
        }
    }

	//审核后重新计算已收款金额
	function updateSendPaymentActualamount($sendcashbillid){
		global $adb;
		$getSendPaymentIdSQL="SELECT DISTINCT ld_sendcashbill2payment.entitytypeid FROM ld_sendcashbill 
							INNER JOIN ld_sendcashbill2payment ON ld_sendcashbill.sendcashbillid = ld_sendcashbill2payment.sendcashbillid
							INNER JOIN ld_sendpayment ON ld_sendpayment.sendpaymentid = ld_sendcashbill2payment.entitytypeid
							WHERE ld_sendpayment.deleted=0 AND ld_sendcashbill.sendcashbillid in ($sendcashbillid)";
		$SendPaymentIdresult=$adb->pquery($getSendPaymentIdSQL,array());
		for($i=0;$i<$adb->num_rows($SendPaymentIdresult);$i++){
			$Sendpaymentidlist .=$adb->query_result($SendPaymentIdresult,$i,'entitytypeid').',';
		}
	   
		$Sendpaymentidlist=substr($Sendpaymentidlist,0,strlen($Sendpaymentidlist)-1); 
		$this->update_SendPaymentActualamount($Sendpaymentidlist);
	}

	//审批成功操作
	public function successApprove($record)
	{
	  
		$this->updateSendCashBillStatus($record);
        global $adb;
        $selectsql = "select entitytypeid,entitytype from ld_sendcashbill2payment where sendcashbillid = ?";
       $result = $adb->pquery($selectsql,array($record));
       for($i=0;$i<$adb->num_rows($result);$i++)
       {
            $entitytypeids[]=$adb->query_result($result,$i,"entitytypeid");//收款单对应的回款计划ID   
            $sourcemodule = $adb->query_result($result,$i,"entitytype");
       }
       $this->updateSourceMainamount($entitytypeids,$sourcemodule);
       $this->updateSourceDetailamout($entitytypeids,$sourcemodule);
	}
	
	//反审批操作
	public function rejectApproved($record){
		$this->upadteBackSendCashBillStatus($record);
         global $adb;
        $selectsql = "select entitytypeid,entitytype from ld_sendcashbill2payment where sendcashbillid = ?";
       $result = $adb->pquery($selectsql,array($record));
       for($i=0;$i<$adb->num_rows($result);$i++)
       {
            $entitytypeids[]=$adb->query_result($result,$i,"entitytypeid");//收款单对应的回款计划ID   
            $sourcemodule = $adb->query_result($result,$i,"entitytype");
       }
       $this->updateSourceMainamount($entitytypeids,$sourcemodule);
       $this->updateSourceDetailamout($entitytypeids,$sourcemodule);
	}

	//已拒绝
	public function failedApproved($record){
		$this->upadteBackSendCashBillStatus($record);
	}

	public function SaveModuleDetail(){
	    global $adb;
        $return_arr = [];
        //选择源单
        $isProductDetail = 'no';
        $sourcemodules=getSourceModule($this->module_name);

        //获取收款单选择源单类型
        $selectlistval = $this->column_fields['selectlistval'];
        $selectlistval_arr=explode(",",$selectlistval);
        if(!empty($selectlistval_arr)){
            $selectsourceModule = getSalesEntityType($selectlistval_arr[0]);//获取对应模块
        }
        if(isset($_REQUEST['selectsourcename'])){
            $selectsourceModule = $_REQUEST['selectsourcename'];
        }
        if(isset($_REQUEST['selectsource'])){
            $selectsourceModule = $_REQUEST['selectsource'];
        }
        foreach($sourcemodules as $tmp=>$sourcemoduleinfo)
        {
            if($selectsourceModule==$sourcemoduleinfo['entitytype']&&$sourcemoduleinfo['withdetail']=='yes')
            {
                $isProductDetail='yes';
                break;
            }
        }
        if($isProductDetail == 'yes'){
            $ProductToolFields = ProductToolFields::getInstance($this->module_name);
            $ProductToolFields-> ResetBillEmpty();
            $ProductToolFields->setsourceModulesqlwhere($selectsourceModule);
            $selectsql = "select entitytypeid,entitytype from ld_sendcashbill2payment where sendcashbillid = ?";
            $result = $adb->pquery($selectsql,array($this->id));
            for($i=0;$i<$adb->num_rows($result);$i++)
            {
                $before_entitytypeids[]=$adb->query_result($result,$i,"entitytypeid");
                $before_sourcemodule = $adb->query_result($result,$i,"entitytype");
            }
            $this->updateSourceInfo($before_entitytypeids,$before_sourcemodule);
            //收款单明细保存
            crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, $this->module_name);

            $sql='select entitytype,entitytypeid from ld_sendcashbill2payment  where sendcashbillid=? and entitytype=?';
            $result=$adb->pquery($sql,array($this->id,'SendPayment'));
            $num_rows=$adb->num_rows($result);
            for($i=0;$i<$num_rows;$i++)
            {
                $entitytypeid = $adb->query_result($result,$i,'entitytypeid');
                //获取保存后原单，用于修改已收总额
                if(!empty($entitytypeid)){
                    $now_entitypeids[]=$entitytypeid;
                }

            }
        }
        else{
            crm_load_class_file('cls_save_moduledetail','data');
            $obj=new cls_save_moduledetail($this->module_name,$this->id);
            //记录保存前的分录信息
            $before_db_value_arr = $obj->save_before_detailinfo();

            if(isset($_REQUEST['selectsourcename']))
            {
                $sourceModule=$_REQUEST['selectsourcename'];
            }
            $aferentitytid_arr=[];
            $before_sourcemodule='';
            $before_entitytypeids=[];
            //删除明细表后，更新编辑前源单字段值
            $selectsql = "select entitytypeid,entitytype from ld_sendcashbill2payment where sendcashbillid = ?";
            $result = $adb->pquery($selectsql,array($this->id));
            for($i=0;$i<$adb->num_rows($result);$i++)
            {
                $before_entitytypeids[]=$adb->query_result($result,$i,"entitytypeid");
                $before_sourcemodule = $adb->query_result($result,$i,"entitytype");
            }
            $adb->pquery('delete from ld_sendcashbill2payment where sendcashbillid = ' . $this->id);
            $this->updateSourceInfo($before_entitytypeids,$before_sourcemodule);

            $i=1;

            $row_index = 0;
            $num = 1;
            if (!isset($_REQUEST['rowcnt'])) {
                $_REQUEST['rowcnt'] = 1;
            }
            $TabDetailFields = new TabDetailFields(getTabid($this->module_name));

            $TabDetailFields->setsourceModulesqlwhere($selectsourceModule);
            $tabDetailFields = $TabDetailFields->getTabDetailFields();//获取了所有字段，包括隐藏字段
            $tab_name_index = $this->tab_name_index;
            //循环开始
            while(true)
            {

                /*if((!isset($_REQUEST['entitytypeid'.$i])) && (!isset($_REQUEST['deleterow'.$i])))
                {
                    break ;
                }*/
                if($row_index >= $_REQUEST['rowcnt']){
                    break ;
                }

                $entitytypeid = $_REQUEST['entitytypeid'.$i];	//原单id
                $detail_sequence=$_REQUEST['detail_sequence'.$i];//
                if(!empty($entitytypeid))
                    $aferentitytid_arr[]=$entitytypeid;
                if(!empty($entitytypeid)){
                    $after_entitytypeids[]= $entitytypeid;
                    if($selectsourceModule=='SendPayment')
                    {
                        $now_entitypeids[]=$entitytypeid;

                    }
                }

                $row_index++;
                if(isset($_REQUEST['deleterow'.$i])&&$_REQUEST['deleterow'.$i] == 0)
                {
                    $insertTable = array();
                    foreach($tabDetailFields as $columnname => $field){
                        $columnname = $field->getColumnName();
                        $savedatabase = $field->getSaveDataBase();
                        if($savedatabase == 'no'){
                            continue;
                        }
                        if($field->getPresence()==1)
                            continue;
                        $tablename = $field->getTableName();
                        if($field->getNewLine() == 1)
                            $value = $_REQUEST[$columnname];
                        else
                            $value = $_REQUEST[$columnname . $i];

                        //edit:duan date:2024/12/13 reason:用户没有选择源单字段的权限时，根据源单取值
                        if($columnname=='entitytype'){
                            if(!empty($sourceModule)){
                                $value = $sourceModule;
                            }elseif(!empty($entitytypeid)){
                                $value = getSalesEntityType($entitytypeid);
                            }else{
                                $value = '';
                            }
                        }

                        //复选框
                        if($field->getFieldType() == 'CheckBox'){
                            if($value === 'on'||$value==1){
                                $value = 1;
                            }else{
                                $value = 0;
                            }
                        }
                        if($field->getFieldType() == 'SelectComBox'){
                            //$value = implode(' |##| ',$value);
                            $value = str_replace('########'," |##| ",$value);
                        }
                        $insertTable[$tablename][$columnname] = $value;
                        if($columnname == 'currency_id'){
                            $currencyobj=new Currency($adb,$value);
                            $insertTable[$tablename]['currency_symbol'] = decode_html($currencyobj->getCurrencySymbol());
                        }
                    }

                    $insertValue['ld_sendcashbill'] = $insertTable['ld_sendcashbill'];
                    $insertValue['ld_sendcashbill2payment'] = $insertTable['ld_sendcashbill2payment'];
                    $insertValue['ld_sendcashbill2paymentscf'] = $insertTable['ld_sendcashbill2paymentscf'];
                    foreach($insertValue as $tablename => $columvalues){
                        if(empty($columvalues) || !is_array($columvalues)){
                            continue;
                        }
                        $column = array_keys($columvalues);
                        $updatefld = array();
                        if($tablename != strtolower($this->table_name)){
                            foreach($column as $col){
                                $updatefld[] = '`' . $col . '`' . '=?';
                            }
                            //明细
                            if($tablename == $this->Detail_table){
                                $query = 'insert into '.$tablename.'('.$this->table_index.','.implode(',',$column). ',sequence,sequence_no) values('.$this->id.','.generateQuestionMarks($columvalues).',?,?)';
                                $columvalues['sequence']=$i;
                                $columvalues['sequence_no']=$i;
                                $this->db->pquery($query,$columvalues);
                                $id=$this->db->getLastInsertID();

                                if($_REQUEST[$this->Detail_table_id.$i]>0){
                                    $detail_id = $_REQUEST[$this->Detail_table_id.$i];
                                    $new_detailid_arr[$detail_id] = $id;

                                }else{
                                    $new_detailid_arr[$id] = $id;
                                    $detail_id = $id;
                                }
                                if(is_array($insertValue[$this->Detail_table_scf])&&sizeof($insertValue[$this->Detail_table_scf])>0){
                                    $request_value_arr[$detail_id] = array_merge($columvalues,$insertValue[$this->Detail_table_scf]);
                                }else{
                                    $request_value_arr[$detail_id] = $columvalues;
                                }
                                //记录行数与lineitem_id的关系
                                $new_lineitemid[$i] = array('new_lineitemid'=>$id,'old_lineitemid'=>$_REQUEST[$this->Detail_table_id.$i]);
                            }//明细scf
                            else if($tablename == $this->Detail_table_scf){
                                $query = 'insert into '.$tablename.'('.$this->Detail_table_id.',`'.implode('`,`',$column). '`) values('.$id.','.generateQuestionMarks($columvalues).')';
                                $this->db->pquery($query,$columvalues);
                            }
                        }
                    }
                }
                if(!empty($entitytypeid)){
                    $now_entitypeids[] = $entitytypeid;
                }
                $i++;
            }

            //循环结束
            $this->updateSourceInfo($after_entitytypeids,$sourceModule);
            //保存分录修改日志
            $obj->save_moduleddetail_log($before_db_value_arr,$new_detailid_arr,$request_value_arr);
            //保存分录图片
            $obj->insertIntoImage($new_lineitemid);

            if($sourceModule==$before_sourcemodule)
            {
                if(sizeof($before_entitytypeids)>0)
                    $entitytypeid_arr=array_merge($before_entitytypeids,$aferentitytid_arr);
                else
                    $entitytypeid_arr=$aferentitytid_arr;
                $entitytypeid_arr=array_unique($entitytypeid_arr);

                $this->updateSourceMainamount($entitytypeid_arr,$sourceModule);
            }
            else{
                if(sizeof($before_entitytypeids)>0)
                {
                    $this->updateSourceMainamount($before_entitytypeids,$before_sourcemodule);
                }
                if(sizeof($aferentitytid_arr)>0){

                    $this->updateSourceMainamount($aferentitytid_arr,$sourceModule);
                }
            }
        }
        $return_arr['now_entitypeids'] = $now_entitypeids;

        return $return_arr;
    }

}
SendCashBill::require_file();
?>