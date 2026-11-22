<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
define("NOCASHBILL",'未收');
define("PARTCASHBILL",'部分已收');
define("ALLCASHBILL",'已收');
class PaymentPlan extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['PaymentPlan']='PaymentPlan';
         if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $log;
    var $db;
    var $table_name='ld_paymentplan';
    public $table_index='paymentplanid';
    var $table_code='paymentplan_no';//表编号字段(审批中心)
    var $tab_name=Array('ld_crmentity','ld_paymentplan','ld_paymentplanscf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_paymentplan'=>'paymentplanid','ld_paymentplanscf'=>'paymentplanid');
   	//关联模块
    var $relatedtab=array('accounts'=>'','users'=>'','salesorder'=>'','company'=>'','paymentplan'=>'');
    var $customFieldTable = Array('ld_paymentplanscf', 'paymentplanid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";
    var $module_name='PaymentPlan';
	var $column_fields = Array();
    var $sortby_fields=Array('paymentplan_no,plandate');
  
            var $list_link_field= 'paymentplan_no';
            
            	var $search_fields_name = Array(
		
			);
            
            var $required_fields =  array();

//比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'paymentplan_no');
	var $default_order_by = 'paymentplan_no';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="paymentplan_no";
    var $popup_fields=Array();
    function __construct()
    {
	   //$this->log =LoggerManager::getLogger('PaymentPlan');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('PaymentPlan',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
          /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('PaymentPlan');
        $this->list_link_field=$entityname['fieldname'];
        $this->popup_fields=Array($this->list_link_field);
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
	    global $adb;
      
        //echo 123123;exit;
		$this->retrieve_entity_info($this->id, $module);
		if(empty($this->column_fields['plandate'])){
			$plandate = $_REQUEST['plandate'];
		}else{
			$plandate = $this->column_fields['plandate'];
		}
        //编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
        if($this->currency_status == true)
        {
            $currencyobj=Currency::getInstance($adb,$_REQUEST['currency_id']);
            //编辑保存后汇率丢失
            $this->column_fields['currency_id']=$_REQUEST['currency_id'];
        	$this->column_fields['conversion_rate'] = $currencyobj->getCurrencyRate();
        	$this->column_fields['currency_symbol'] = decode_html($currencyobj->getCurrencySymbol());
            $update_query = "update ld_paymentplan set currency_id=?, conversion_rate=?,currency_symbol=? where paymentplanid=?";
    		$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
           
   	        $this->db->pquery($update_query, $update_params);
            
        }
       
        $sqlaccount='select ld_account.accountname  from ld_account where ld_account.accountid= '.$this->column_fields['account_id'];
        $sqlaccountresult=$adb->query($sqlaccount);
		//反写回款计划选择的源单
	/*	if( !empty($_REQUEST['salesorder_id'])){
			$adb->pquery('update ld_paymentplan set entitytype = ?,entitytypeid = ? 
            where paymentplanid = ?',array($_REQUEST['selectsource'],$_REQUEST['salesorder_id'],$this->id));
		}
        else*/  
        //修改原单类型后，entitytype值不改变
		$adb->pquery('update ld_paymentplan 
        left join ld_crmentity on ld_paymentplan.entitytypeid=ld_crmentity.crmid
        set entitytype =ld_crmentity.setype
        where paymentplanid = ?',array( $this->id));
	 
        if($adb->num_rows($sqlaccountresult)>0)
        {
            $accountname=$adb->query_result($sqlaccountresult,0,"accountname");
        }
        $periodtime = $this->column_fields['periodtime'];   
        $amount = $this->column_fields['amount'];
		//wym BUG0073122
        $cur_len = getSys_deploy(351);
        $amount=number_format($amount,$cur_len['deploy_value']);
		//wym BUG0073439
        $currency_id=$this->column_fields['currency_id']??1;
        $currencyobj=new Currency($adb,$currency_id);
        $currencySymbol = decode_html($currencyobj->getCurrencySymbol());
        $prev_remind_days=getSys_deploy(40);//回款计划提前提醒天数(为空不提醒)
      
        if($prev_remind_days['deploy_value']!='')
         {
               $sql='select id from ld_automaticreminds where defaultnum=40';
               $result=$adb->pquery($sql,array());
               $reminds_ruleid=$adb->query_result($result,0,0);
               
               if(DateOperation::addDays($plandate,'-'.$prev_remind_days['deploy_value'])>date("Y-m-d"))
               {
                    
               }
               else
               {
                    if((!empty($plandate)&&$plandate>='1970-01-01')||$this->column_fields['paymenttype']=='项目状态')
                    {
                        //edit:can 20220412 【通用问题】收款计划模块→类型为"项目状态"的单据，无法正常到期提醒（详情见附件和说明）
                        $sql='delete from ld_reminds where reminds_ruleid=? and related_to=?';
                        $adb->pquery($sql,array($reminds_ruleid,$this->id));
                        $focus_rel =CRMEntity::getInstance('Reminds');
                        //wym XUQIU1001598 收款计划增加单选“项目立项”字段，新建收款计划时判断项目状态是否处于提醒状态,如果处于则发送提醒
                        if($this->column_fields['paymenttype']=='项目状态'){
                            $paymentstatus = $this->column_fields['projectstatus'];
                            if(empty($this->column_fields['projectid'])||$this->column_fields['projectid']==0){
                                $sql='select projectid from ld_project where (salesorderid = ? OR salesorderid IN (SELECT entitytypeid FROM ld_invoicedetail WHERE id = ?)) and projectstatus = ? ORDER BY createdtime';
                                $result=$adb->pquery($sql,array($this->column_fields['entitytypeid'],$this->column_fields['entitytypeid'],$paymentstatus));
                                if($adb->num_rows($result) >= 1){
                                    $projectid =  $adb->query_result($result,0);
                                }
                            }else{
                                $projectid = $this->column_fields['projectid'];
                            }
                            if(!empty($projectid)) {
                                $projectname = getModuleHref('Project', $projectid);
                                $focus_project = CRMEntity::getInstance('Project');
                                $focus_project->retrieve_entity_info($projectid,'Project');
                                $projectstatus = $focus_project->column_fields['projectstatus'];
                                $focus_payment=CRMEntity::getInstance('PaymentPlan');
                                $fieldlabel_project=$focus_payment->fieldobj->getFieldInfoBykeyValue("fieldname",'projectid','fieldlabel');
                                //wym BUG0072188 合同订单关联收款计划，根据项目状态收款时，消息提醒中金额的小数位数太多了

                                if($projectstatus==$paymentstatus && !empty($projectstatus)){
                                    $content=getTranstab('PaymentPlan')."到期，请及时催收！公司名称：{$accountname}，收款时项目状态：{$paymentstatus}，{$fieldlabel_project}：{$projectname}，金额：$currencySymbol$amount";
                                    $focus_rel->column_fields['date_time'] =date("Y-m-d H:i");
                                    //关联创建收款计划 收款项目阶段与关联项目的项目阶段一致时，反写预计收款时间和关联项目
                                    $adb->pquery('update ld_paymentplan SET plandate = curdate(), projectid=? where paymentplanid = ?',array($projectid,$this->id));
                                }
                            }
                       }else{
                           $content=getTranstab('PaymentPlan')."到期，请及时催收！公司名称：{$accountname}，期次：{$periodtime}，金额：$currencySymbol$amount";
                           $focus_rel->column_fields['date_time'] =DateOperation::addDays($plandate,'-'.$prev_remind_days['deploy_value']);
                       }
                        if(!empty($content)){
                            $focus_rel->column_fields['related_to']=$this->id;
                            $focus_rel->column_fields['reltab']='PaymentPlan';
                            $focus_rel->column_fields['remindstype']='PaymentPlanPlanDate';
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
               }
               
                
         }
         
         $sql='update ';
        global $adb;
        /*
        if($this->column_fields['paymentstatus']==ALLCASHBILL)
            {
                $sql='delete from ld_crmentity where crmid in(select remindsid from ld_reminds where related_to=? and status_rmd=? and reminds_ruleid>0)  ';
                $adb->pquery($sql,array($this->id,'未读'));

                $sql='delete from ld_crmentity where crmid in(select remindsid from ld_reminds_accepted where related_to=? and status_rmd=? and reminds_ruleid>0)  ';
                $adb->pquery($sql,array($this->id,'未读'));
            }
         */
        //duan 20231201 当ld_crmentity 里的单据数量较多时，上方合并sql的执行效率极低，改成分开两部分就快很多
        if($this->column_fields['paymentstatus']==ALLCASHBILL)
        {
            $remindsid_sql = 'select GROUP_CONCAT(remindsid) as remindid_str from ld_reminds where related_to=? and status_rmd=? and reminds_ruleid>0';
            $result = $adb->pquery($remindsid_sql,[$this->id,'未读']);
            if($adb->num_rows($result) >0){
                $remindid_str = $adb->query_result($result,0,'remindid_str');

                $sql='delete from ld_crmentity where crmid in('.$remindid_str.')  ';
                $adb->pquery($sql);
            }

            $remindsid_sql = 'select GROUP_CONCAT(remindsid) as remindid_str from ld_reminds_accepted where related_to=? and status_rmd=? and reminds_ruleid>0';
            $result = $adb->pquery($remindsid_sql,[$this->id,'未读']);
            if($adb->num_rows($result) >0){
                $remindid_str = $adb->query_result($result,0,'remindid_str');

                $sql='delete from ld_crmentity where crmid in('.$remindid_str.')  ';
                $adb->pquery($sql);
            }
        }
        //zkt BUG20241025-68 收款计划单据修改（如GP442），输入已收金额（图1），保存后已收金额无法保存，会自动变成0（图2），而且修改日志里面没有更新新日志（图3），帮忙看下。
        $sourcemodule_arr = getSourceModule('CashBill');
        foreach($sourcemodule_arr as $tmpsourceinfo){
            if($tmpsourceinfo['entitytype'] == $this->module_name){
                //编辑单据反写收款单明细字段
                $sendfocus = CRMEntity::getInstance('CashBill');
                //zkt 20240904 BUG20240827-17 收款计划（GP880），下推收款单更改收款计划状态为“已收”后，修改收款计划金额时，更新了crm的应收余额，但收款计划状态没有更新为部分已收
                $sendfocus->update_PaymentActualamount($this->id);
                $sendfocus->updateSourceInfo($this->id,'PaymentPlan');
                break;
            }

        }


    }
    
   
     
    function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Accounts' ||$return_module=="SalesOrder"||$return_module=="ServiceContracts") {
			$this->trash('PaymentPlan',$id);
		} 
	}
    public function trash($module,$id)
    {
        parent::trash('PaymentPlan',$id);
        $reminds_focus=new Reminds();
        $reminds_focus->deleteRecord($id,'未读');
        
       
    }
       /**
     * 删除合同(销售，服务)订单关联的回款计划和回款计划提醒(已读)
     * $orderid:订单ID
     * */
    function deletePaymentPlan($orderid,$from_focus)
    {
        global $adb;
        //if(is_array($orderids)&&sizeof($orderids)>0)
       // {
            
             $sql="update    ld_reminds inner join ld_paymentplan  
                            on   ld_paymentplan.paymentplanid=ld_reminds.related_to inner join  $from_focus->table_name on  
                                $from_focus->table_name.$from_focus->table_index =ld_paymentplan.entitytypeid
                                set ld_reminds.deleted=1
                             where ld_reminds.status_rmd='未读' and $from_focus->table_name.$from_focus->table_index =$orderid ";
             $result=$adb->pquery($sql,array());
            
             $sql="update ld_paymentplan  inner join  $from_focus->table_name  on  
                                $from_focus->table_name.$from_focus->table_index =ld_paymentplan.entitytypeid
                        set ld_paymentplan.deleted=1
                         where $from_focus->table_name.$from_focus->table_index =$orderid ";
                         
                    
             $result=$adb->pquery($sql,array());
        //}
    }

	//获取原单模块
    function getSourceField($recordid)
    {
        global $adb;
        $sql = "select entitytype,entitytypeid from ld_paymentplan where paymentplanid = ?";
        $result=$adb->pquery($sql,array($recordid)); 
		$entitytypeid = $adb->query_result($result,0,'entitytypeid');
		if(!empty($entitytypeid)){
			$sourceModuleInfo['module'] = getSalesEntityType($entitytypeid);
		}else{
			$sourceModuleInfo['module'] = '';
		}
        $sourceModuleInfo['sourceid']= $entitytypeid;
        return $sourceModuleInfo;
    }
   
}
PaymentPlan::require_file();
?>