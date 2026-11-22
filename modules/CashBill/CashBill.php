
<?php

include (globalStatic::$root_directory.'modules/CashBill/CashBillDetailFields.php');
class CashBill extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['CashBill']='CashBill';
            if(empty(globalStatic::$arr_module_require['PaymentPlan']))
            {
                globalStatic::$arr_module_require['PaymentPlan']='PaymentPlan';
                include("modules/PaymentPlan/PaymentPlan.php");
                
            }
            
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $detail_field_objs;
    var $db;
    var $table_name='ld_cashbill';
    public $table_index='cashbillid';
    var $table_code='cashbill_no';//表编号字段(审批中心)
    var $tab_name=Array('ld_crmentity','ld_cashbill','ld_cashbillscf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_cashbill'=>'cashbillid','ld_cashbillscf'=>'cashbillid');
   	var $customFieldTable = Array('ld_cashbillscf', 'cashbillid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";
    var $Detail_table="ld_cashbill2paymentplan";//明细表名称
    var $Detail_table_index="cashbillid";//明细表和主表关联ID
    var $Detail_table_id="cashbill2paymentplan_id";//明细表主键名称
    var $Detail_table_scf = "ld_cashbill2paymentplanscf";//明细scf表    
	var $column_fields = Array();
    var $module_name='CashBill';
    var $sortby_fields=Array('cashbill_no,cashbilldate');
    //管理模块
    var $relatedtab=array('accounts'=>'','salesorder'=>'','users'=>'','company'=>'','cashbill'=>'');
    var $list_link_field= 'cashbill_no';
    var $search_fields_name = Array();
    var $required_fields =  array();
    //比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'cashbill_no');
	var $default_order_by = 'cashbilldate';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="cashbill_no";
    var $detailfieldobj;//明细字段对象
    private $debuctioninfobyid_arr;//预收单id对应的info信息
    function __construct()
    {
	   //$this->log =LoggerManager::getLogger('CashBill');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('CashBill',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $this->module_name="CashBill";
        crm_load_class_file('TabDetailFields','include/TabDetailFields');
        
        $this->detailfieldobj=TabDetailFields::getInstance($this->module_name);
       
        
        /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('CashBill');
        $this->list_link_field=$entityname['fieldname'];
        $detailFields=array('enitytypeid','paymentplanid','cur_amount','sequence','amount');
        $tmpfield_arr = [];
        foreach($detailFields as $columnanme)
        {
            $detail_field_obj=new CashBillDetailFields();
            $detail_field_obj->setcolumnName($columnanme);
            $detail_field_obj->setTableName($this->Detail_table);
            $this->detail_field_objs[]=$detail_field_obj;
            $before_detail_field_obj=new CashBillDetailFields();
            $before_detail_field_obj->setcolumnName($columnanme);
            $before_detail_field_obj->setTableName($this->Detail_table);
            $tmpfield_arr[$columnanme]=$before_detail_field_obj;
            
            
        }
        $this->before_detail_info[] = $tmpfield_arr;
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
     /**
     * 批量修改保存(保存前)
     * **/
    function massEdit_save_before($module,$ids)
    {
            global  $adb;
            $becurrency_id=$this->column_fields['currency_id'];
            parent::massEdit_save_before($module,$ids);
            //duan 20221201 收款单批量保存报错，不知道原因，暂时注释
            //$this->before_field_info[]=$this->column_fields;
            if(isset($_REQUEST['currency_id_mass_edit_check'])&&$becurrency_id!=$_REQUEST['currency_id_mass_edit_check'])
            {
                
                $conversion_rate = $this->currencyobj->getCurrencyRate();
				$currency_symbol = $this->currencyobj->getCurrencySymbol();
                $becurrency_rate=$this->before_currencyobj->getCurrencyRate();
                if($becurrency_id == 1)//编辑前的币种人民币
    			{
    				$query = "update ld_cashbill set total = total*?,NoPaymentplan=NoPaymentplan*?,subtotal = subtotal*? where cashbillid = ?";
    				$adb->pquery($query,array($conversion_rate,$conversion_rate,$conversion_rate,$this->id));
    				$query2payment = "update ld_cashbill2paymentplan set amount = amount/? where cashbillid = ?";
    				$adb->pquery($query2payment,array($conversion_rate,$this->id));
    			}
    			else
    			{
    				$query = "update ld_cashbill set total = total/?*?,NoPaymentplan=NoPaymentplan/?*?,subtotal = subtotal/?*? where cashbillid = ?";
    				
    				$adb->pquery($query,array($becurrency_rate,$conversion_rate,$becurrency_rate,$conversion_rate,$becurrency_rate,$conversion_rate,$this->id));
    				$query2payment = "update ld_cashbill2paymentplan set amount = amount*?/? where cashbillid = ?";
    				$adb->pquery($query2payment,array($becurrency_rate,$conversion_rate,$this->id));
    			}
            }
             //已收金额计算时是否统计未审核的收款单  0 是 1 否
		// $setsystem_check = getSys_deploy(83);//save_module函数已调用了
      //  if(($_REQUEST['currency_id_mass_edit_check']||$_REQUEST['bankaccountsetid_mass_edit_check'])&&$setsystem_check['deploy_value']==0)
            //        $this->minusBankMoney($ids);
        	
    }
      /**
     * 批量修改保存(保存以后)
     * ids:单据id的集合(数组)
     * */
    function  massEdit_save_after($module,$ids)
    {
        
         global $adb;
        if(($_REQUEST['fldName']=='cashbilldate'||$_REQUEST['currency_id_mass_edit_check']||$_REQUEST['cashbilldate_mass_edit_check']!='')&&sizeof($ids)>0)
        {
             $cashbillids=implode(',',$ids);
            $sql="select GROUP_CONCAT(tmp.paymentplanid) from (
                        select paymentplanid  from ld_cashbill2paymentplan where cashbillid in($cashbillids)   GROUP BY paymentplanid) as tmp";
        
            $cashbill_result=$adb->pquery($sql,array());
            if($adb->num_rows($cashbill_result)>0)
            {
                $paymentidlist=$adb->query_result($cashbill_result,0,0);
                $this->update_PaymentActualamount($paymentidlist);
            }
        }
          //已收金额计算时是否统计未审核的收款单  0 是 1 否
		 //$setsystem_check = getSys_deploy(83);
        // if(($_REQUEST['currency_id_mass_edit_check']||$_REQUEST['bankaccountsetid_mass_edit_check'])&&$setsystem_check['deploy_value']==0)
          //          $this->addBankMoney($ids);//save_module函数已调用了
        
    }

    /**
     * 更新明细表源单字段信息（源单已收总额，源单总额）
     * 
     * */
    //获取源单已收总额，源单总额等信息更新收款单明细表相应字段 
    function updateSourceInfo($entitytypeids,$sourcemodule)
    {
        global $adb;
       if (is_array($entitytypeids)) {
           $entitytypeids = array_unique($entitytypeids);
       } else {
           if (!empty($entitytypeids)) {
               $entitytypeids = array($entitytypeids);
           }
       }
        if (empty($entitytypeids) || empty(trim($entitytypeids[0]))) return;
        if (empty($sourcemodule)) {
            $sourcemodule = getSalesEntityType($entitytypeids[0]);
        }
        $source_focus = CRMEntity::getInstance($sourcemodule);
       
        $entitynamearr = getEntityName($sourcemodule,$entitytypeids);
        foreach($entitytypeids as $entitytypeid){
            if($entitytypeid == ''){
                continue;
            }
            
            if($sourcemodule == 'PaymentPlan'){
                $query = "select amount as source_total,actualamount as received_amount,currency_id,conversion_rate,currency_symbol 
                            from $source_focus->table_name where $source_focus->table_index = $entitytypeid";
                //回款计划收款，反写合同信息单据相关的收款单明细信息
                $payment_sql = "select entitytype,entitytypeid from ld_paymentplan where paymentplanid=$entitytypeid";
              
                $result = $adb->pquery($payment_sql);
                if($adb->num_rows($result)>0){
                    $this->updateSourceInfo($adb->query_result($result,0,'entitytypeid'),$adb->query_result($result,0,'entitytype'));
                }
            }
            else{
                $query = "select total as source_total,received_amount as received_amount,currency_id,conversion_rate,currency_symbol 
                            from $source_focus->table_name where $source_focus->table_index = $entitytypeid";
            }
           
            $source_result = $adb->pquery($query,array());
            
            $source_total = $adb->query_result($source_result,0,'source_total');
            $received_amount = $adb->query_result($source_result,0,'received_amount');
            $currency_id = $adb->query_result($source_result,0,'currency_id');
            $conversion_rate = $adb->query_result($source_result,0,'conversion_rate');
            
            if($conversion_rate<=0.0000001)
            {
                $conversion_rate=1;
            }
            $currency_symbol = $adb->query_result($source_result,0,'currency_symbol');
            $entityname = $entitynamearr[$entitytypeid];
            $updatesql = "update ld_cashbill2paymentplan set source_total=?,received_amount=?,entitytype_value=?,
                    currency_id=?,conversion_rate=?,currency_symbol=? where entitytypeid=?";
            $adb->pquery($updatesql,array($source_total,$received_amount,$entityname,$currency_id,$conversion_rate,html_entity_decode($currency_symbol),$entitytypeid));
        }
    }
    /**
     * @reason: 保存前的特殊判断,确定是否可以保存单据,不可保存时直接返回
     * @param:
     * @edit:zkt
     * @date:2024/12/20
     */
    function IsAllowSaveBeforeSave():array
    {
        $return_arr = [];
        $allowsave = 'yes';
        //@edit:zkt @date:2024/12/19 @reason: XUQIU20240821-02   --- 系统参数，设置计算预收单金额时是否统计未审批通过的预收单
        $adb = $this->db;
        $sys_492 = getSys_deploy(492);//系统参数，设置计算预收单金额时是否统计未审批通过的预收单
        $IsCalculateunapproved = $sys_492['deploy_value'];
        $cashbilltype = $_REQUEST['cashbilltype']??'';
        if($IsCalculateunapproved == 'no'&&$cashbilltype=='cashbill'){
            //不统计 未审批的预收单时,需要判断保存的预收单是否已审批
            //要判断的 预收单包括 之前核销的预收单-本次删除的预收单+本次新增的预收单
            $deleted_debuctioninfodetailid = isset($_REQUEST['deleted_debuctioninfodetailid'])?trim($_REQUEST['deleted_debuctioninfodetailid']):'';//删除的预收单
            if(!empty($deleted_debuctioninfodetailid)){
                $deleted_debuction_arr=explode(',',$deleted_debuctioninfodetailid);//编辑界面删除的预收款明细(ld_cashbilldebuctiondetail的主键)
            }
            $cashbilldebuctionid_arr=array();
            if($this->mode=='edit')
            {
                //获取修改的预收款信息
                $sql='select group_concat(distinct debuctionid) as debuctionids  from ld_cashbilldebuctiondetail where cashbillid=? ';
                if(!empty($deleted_debuction_arr)&&is_array($deleted_debuction_arr)&&!empty(implode(',',$deleted_debuction_arr))){
                    $sql .= " AND id not in (".implode(',',$deleted_debuction_arr).') ';
                }
                $tmpresult=$adb->pquery($sql,array($this->id));
                if($adb->num_rows($tmpresult)>0)
                {
                    $debuctionids = $adb->query_result($tmpresult,0,'debuctionids');
                    if(!empty($debuctionids)){
                        $cashbilldebuctionid_arr=explode(",",$debuctionids);
                    }
                }
            }
            $request_save_debuctioninfo = $_REQUEST['save_debuctioninfo']??'';
            if(!empty($request_save_debuctioninfo)){
                $save_debuctioninfo = [];
                if (is_array($request_save_debuctioninfo)) {
                    //手机端
                    $save_debuctioninfo = $request_save_debuctioninfo;
                } else {
                    $save_debuctioninfo = json_decode($request_save_debuctioninfo, true);
                }
                foreach($save_debuctioninfo as $tmpindex=>$debuctioninfo){
                    $trtype=$debuctioninfo['type'];
                    if($trtype=='new'){
                        $debuctionid=$debuctioninfo['debuctionid'];
                        $cashbilldebuctionid_arr[]=$debuctionid;
                    }
                }
                unset($save_debuctioninfo);
            }
            unset($deleted_debuctioninfodetailid,$deleted_debuction_arr);
            if(!empty($cashbilldebuctionid_arr)&&is_array($cashbilldebuctionid_arr)){
                $cashbilldebuctionid_arr = array_unique($cashbilldebuctionid_arr);
                //保存的所有预收单,需要判断是否审批
                $tmpsql='select *  from  '.$this->table_name.' ';
                $tabid = getTabid($this->module_name);
                $entityarray = getEntitynameInfo($tabid);
                $tabname = $entityarray['tablename'];
                $tabindex = $entityarray['entityidfield'];
                $tabfieldname = $entityarray['fieldname'];
                if($tabname != $this->table_name){
                    $tmpsql .= " left join ".$this->customFieldTable[0]." on ".$this->customFieldTable[0].".$tabindex = ".$this->table_name.".$tabindex ";
                }
                $tmpsql .= ' where cashbillid in ('.implode($cashbilldebuctionid_arr).")  and ld_cashbill.approvestatus != '".D_A_S_APPROVED."' ";
                $tmpresult=$adb->pquery($tmpsql,array());
                $tmpnumrows = $adb->num_rows($tmpresult);
                unset($tmpsql);
                if($tmpnumrows>0)
                {
                    $msg = "";
                    //存在未审批的预收单,不可保存
                    for($tmpi= 0; $tmpi<$tmpnumrows; $tmpi++)
                    {
                        $debuction_no = $adb->query_result($tmpresult,$tmpi,$tabfieldname);
                        $msg = $debuction_no."、";
                    }
                    $msg = trim($msg,"、");
                    $msg =sprintf(getFixedLabel('UNAPPROVEDADVANCERECEIPTNOTWRITTEN'),$msg);
                    $this->saveerrormsg = $msg;
                    $allowsave = 'no';
                }
            }
        }
        $return_arr['allowsave'] = $allowsave;

        return $return_arr;
    }
    /**
     * @reason: save方法重写,收款单保存存在特殊逻辑:设置计算预收单金额时是否统计未审批通过的预收单
     * @param
     * @edit:zkt
     * @date:2024/12/20
     */
    function save($module_name, $fileid = ''):array
    {
        $allowsave_arr = $this->IsAllowSaveBeforeSave();
        if($allowsave_arr['allowsave'] == 'no'){
            $msg = $this->saveerrormsg;
            return ['code'=>"-1",[],$msg];
        }

        return parent::save($module_name,$fileid);

    }
    public function before_save($record)
    {
        //已收金额计算时是否统计未审核的收款单  0 是 1 否
        $setsystem_check = getSys_deploy(83);
        if ($setsystem_check['deploy_value'] == 0 && $this->id > 0)
            $this->minusBankMoney($record);
        // 2024-12-06 xxy 自动创建收款单会取"收款类型"的默认值，例如预置的默认值是"收款"，需要转换下存数据库
        if($this->column_fields['cashtype'] != 'cashbill' && $this->column_fields['cashtype'] != 'debuction'){
            if($this->column_fields['cashtype'] == '收款'){
                $this->column_fields['cashtype'] = 'cashbill';
            }else if($this->column_fields['cashtype'] == '预收'){
                $this->column_fields['cashtype'] = 'debuction';
            }else{
                $this->column_fields['cashtype'] = 'cashbill';
            }
        }
        
    }
    /**
     * edit:can
     * date:201306014
     * reason:批量回款更新
     * */
   	function save_module($module)
	{
        global $adb,$current_user;
        if($this->column_fields['cashtype']=='debuction'&& $this->id>0){
            $sql = "update ld_cashbill set entitytype = '' where cashbillid = ?;";
            $adb->pquery($sql,array($this->id));
        }
        
        if($_REQUEST['action'] != 'CashBillAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
		      
              
		  
        }else{
             //查看界面的小编辑和批量修改
             //已收金额计算时是否统计未审核的收款单  0 是 1 否
    		 $setsystem_check = getSys_deploy(83);
             if($setsystem_check['deploy_value']==0)
                     $this->addBankMoney($this->id);
            return ;
        }
        $currencyfieldinfo= $this->fieldobj->getFieldInfoobjBykey('columnname','currency_id');
        if(!$currencyfieldinfo)
        {
            $bankaccountsetfieldinfo= $this->fieldobj->getFieldInfoobjBykey('columnname','bankaccountsetid');
            if($bankaccountsetfieldinfo)
            {
                $bankaccountid=  $this->column_fields[$bankaccountsetfieldinfo->getFieldName()];
                if(!empty($bankaccountid))
                {
                    $sql='select currency_id, conversion_rate,currency_symbol from ld_bankaccountset where bankaccountsetid=? ';
                    $result=$adb->pquery($sql,array($bankaccountid));
                    if($adb->num_rows($result)>0)
                    {
                        $this->column_fields['currency_id']=$adb->query_result($result,0,'currency_id');
                        $this->column_fields['conversion_rate']=$adb->query_result($result,0,'conversion_rate');
                        $this->column_fields['currency_symbol']=$adb->query_result($result,0,'currency_symbol');
                    }
                }
            }else if(trim($_REQUEST['selectlistval'],',')!=''){
                $selectsourcemodule=$_REQUEST['selectsourcename'];
                $selectlistval_arr=explode(",",$_REQUEST['selectlistval']);
                $selectsourcefocus=CRMENtity::getInstance($selectsourcemodule);
                $selectsourcetablename=$selectsourcefocus->table_name;
                $selectsourcetableindex=$selectsourcefocus->table_index;
                $sql=" select currency_id, conversion_rate,currency_symbol from $selectsourcetablename where $selectsourcetableindex=? ";
                $result=$adb->pquery($sql,array($selectlistval_arr[0]));
                if($adb->num_rows($result)>0)
                {
                    $this->column_fields['currency_id']=$adb->query_result($result,0,'currency_id');
                    $this->column_fields['conversion_rate']=$adb->query_result($result,0,'conversion_rate');
                    $this->column_fields['currency_symbol']=$adb->query_result($result,0,'currency_symbol');
                }
            }
                
                
        }//币种隐藏，美元合同关联创建币种错误
        $update_query = "update ld_cashbill set currency_id=?, conversion_rate=?,currency_symbol=? where cashbillid=?";
        if(empty($this->column_fields['conversion_rate']))
        {
            //李曹辉益而高 编辑 汇率和币种符号丢失
            $currencyobj=Currency::getInstance($adb,$this->column_fields['currency_id']);
            $this->column_fields['conversion_rate'] = $currencyobj->getCurrencyRate();
            $this->column_fields['currency_symbol'] = decode_html($currencyobj->getCurrencySymbol());
        }
		$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],decode_html($this->column_fields['currency_symbol']), $this->id);
		$this->db->pquery($update_query, $update_params);
        $sql='select entitytype,entitytypeid from ld_cashbill2paymentplan  where cashbillid=? and entitytype=?';
        $result=$adb->pquery($sql,array($this->id,'paymentplan'));
        $num_rows=$adb->num_rows($result);
        $old_entitypeids = [];
        for($i=0;$i<$num_rows;$i++)
        {
            //获取保存前原单，用于修改已收总额，回款计划状态
            $old_entitypeids[]=$adb->query_result($result,$i,'entitytypeid');
        }

        //保存分录封装到一个方法中,方便其他地方调用
        $return_arr = $this->SaveModuleDetail();

        $subtotal = $return_arr['subtotal'];
        $now_entitypeids = $return_arr['now_entitypeids'];

        $SqlUpdate="update ld_cashbill set total=?,subtotal=? ,nopaymentplan=? where cashbillid=?";
		$nopaymentplan = is_numeric($_REQUEST['nopaymentplan'])?$_REQUEST['nopaymentplan']:0;    //调整金额
		if($_REQUEST['otherselect'] != 1){//调整（增加或减少),1:增加
			$nopaymentplan = 0 - $nopaymentplan;
		}
        $total = $subtotal+$nopaymentplan;

        if(isset($_REQUEST['cashbill_total'])&&$_REQUEST['cashbill_total']!='undefined'){
            $total =  $_REQUEST['cashbill_total'];
        }
        if(isset($_REQUEST['subtotal'])&&$_REQUEST['subtotal']!='undefined'){
            $subtotal = $_REQUEST['subtotal'];
        }
        $request_cashtype = isset($_REQUEST['cashtype'])?$_REQUEST['cashtype']:'';
        if($request_cashtype == 'debuction')
        {
            if(isset($_REQUEST['cashbill_total'])){
                $subtotal =  $_REQUEST['cashbill_total'];
            }
        }
        $adb->pquery($SqlUpdate,array($total,$subtotal,$nopaymentplan,$this->id));
        
        $versioninfo=getVersionInfo();
        if($versioninfo['account']=='zhongde'&&$request_cashtype=='debuction')
        {
            $update_crmid = [];
            if($_REQUEST['cashbill_01']>0)
            {
                //$sql='update  ld_cashbill set zhongde_backmoneny=0-? where cashbillid=? ';
                //$adb->pquery($sql,array($total,$_REQUEST['cashbill_01']));
                $update_crmid[] = $_REQUEST['cashbill_01'];
            }
            if($this->before_field_info['cashbill_01']>0&&$_REQUEST['cashbill_01']!=$this->before_field_info['cashbill_01'])
            {
                //$sql='update  ld_cashbill set zhongde_backmoneny=0 where cashbillid=? ';
                //$adb->pquery($sql,array( $this->before_field_info['cashbill_01']));
                $update_crmid[] = $this->before_field_info['cashbill_01'];
            }
            foreach ($update_crmid as $tmp_crmid){
                $sql='select sum(total) as zhongdebackmoney from ld_cashbill where cashbill_01=? ';
                $zhongdebackmoney=0;
                $tmpresult=$adb->pquery($sql,array($tmp_crmid));
                if($adb->num_rows($tmpresult)>0)
                {
                    $zhongdebackmoney=$adb->query_result($tmpresult,0,'zhongdebackmoney');

                }
                $updatesql='update ld_cashbill set zhongde_backmoneny=0-? where cashbillid=? ';
                $adb->pquery($updatesql,array($zhongdebackmoney,$tmp_crmid));
            }
        }
        /**
        * edit:kevin
        * date:2013-07-22
        * reason:相关客户是否是已分配,分配则改变客户信息
        */
        /*if(isset($_REQUEST['account_id'])){
            $account=CRMEntity::getInstance('Accounts');
            $account->updateAccountInfo($module,$_REQUEST['account_id']);  
        }*/
         
        if( is_array($old_entitypeids)&& sizeof($old_entitypeids)>0&& is_array($now_entitypeids)&&sizeof($now_entitypeids)>0 )
            $entitytypeids=array_merge($old_entitypeids,$now_entitypeids);
        else if(is_array($old_entitypeids)&&sizeof($old_entitypeids)>0)
            $entitytypeids=$old_entitypeids;
        else
            $entitytypeids=$now_entitypeids;
      
        if(is_array($entitytypeids)&&sizeof($entitytypeids)>0)
        {
         $entitytypeids=array_unique($entitytypeids);
         $this->update_PaymentActualamount(implode(',',$entitytypeids));
         
        }
        $this->column_fields['hdnGrandTotal']=$_REQUEST['cashbill_total'];
        $this->after_save_infos[]=$this->column_fields;
        //已收金额计算时是否统计未审核的收款单  0 是 1 否
		 $setsystem_check = getSys_deploy(83);
        if($setsystem_check['deploy_value']==0)
            $this->addBankMoney($this->id);

        $request_save_debuctioninfo = $_REQUEST['save_debuctioninfo'];
        $save_debuctioninfo = [];
        if(!empty($request_save_debuctioninfo)){
            if (is_array($request_save_debuctioninfo)) {
                //手机端
                $save_debuctioninfo = $request_save_debuctioninfo;
            } else {
                $save_debuctioninfo = json_decode($request_save_debuctioninfo, true);
            }
        }

        $deleted_debuctioninfodetailid = '';
        if(isset($_REQUEST['deleted_debuctioninfodetailid']) && !empty($_REQUEST['deleted_debuctioninfodetailid'])){
            $deleted_debuctioninfodetailid = $_REQUEST['deleted_debuctioninfodetailid'];
        }
        $deleted_debuctioninfo=explode(',',$deleted_debuctioninfodetailid);//编辑界面删除的预收款明细(ld_cashbilldebuctiondetail的主键)
       
        $editdebuctionids=array();
         
        if($this->mode=='edit'&&$_REQUEST['cashbilltype']=='cashbill')
        {
            //获取修改的预收款信息
            $sql='select group_concat(distinct debuctionid) as debuctionids  from ld_cashbilldebuctiondetail
              where cashbillid=? ';
            $tmpresult=$adb->pquery($sql,array($this->id));
            if($adb->num_rows($tmpresult)>0)
            {
                $debuctionids = $adb->query_result($tmpresult,0,'debuctionids');
                if(!empty($debuctionids))
                    $editdebuctionids=explode(",",$debuctionids);
            }
        }
        if(is_array($deleted_debuctioninfo)&&$deleted_debuctioninfo[0]!=''){
            $tmpdetailids=trim($deleted_debuctioninfodetailid,',');
            if(!empty($tmpdetailids)&&$tmpdetailids!='undefined')
            {
                $sql='delete from  ld_cashbilldebuctiondetail where id in( '.$tmpdetailids.')';

                $adb->pquery($sql,array());
            }
            
        }
          
         //插入预收款信息
     
        foreach($save_debuctioninfo as $tmpindex=>$debuctioninfo){
            $trtype=$debuctioninfo['type'];
            if($trtype=='new'){
                $debuctionid=$debuctioninfo['debuctionid'];
                $debuctionamount=$debuctioninfo['amount'];
                
                $sql='insert into ld_cashbilldebuctiondetail(cashbillid,debuctionid,amount,modifiedtime,userid)
                        value(?,?,?,?,?)';
                     
                $adb->pquery($sql,array($this->id,$debuctionid,$debuctionamount,date("Y-m-d H:i:s"),$current_user->id));
                
                $editdebuctionids[]=$debuctionid;
            }
            

                
        }
        //dump($editdebuctionids);
        if($_REQUEST['cashbilltype']=='debuction'){
            $editdebuctionids[]=$this->id;
        }
        else{
            $editdebuctionids=array_filter(array_unique($editdebuctionids));
            
        }
          
         //计算预收款剩余抵扣金额和已抵扣金额
        crm_load_class_file('cls_DebuctionInfo','modules/CashBill');
        $this->column_fields['cashtype']=$_REQUEST['cashbilltype'];
        cls_DebuctionInfo::updateDebuctionInfo($editdebuctionids);
        //预收单 需要修改客户的两个字段值
        $accountid = $this->column_fields['account_id'];
        $cashtype = $this->column_fields['cashtype'];
        $this->updateAccountBalanceAmount($accountid,$cashtype);
		
		
		$sql = "update ld_cashbill set triggercount=triggercount+1 where cashbillid = ?";
		$adb->pquery($sql,array($this->id));
        
        $now_entitypeids=[];
        $sourceModule='';
        $selectsql = "select entitytypeid,entitytype from ld_cashbill2paymentplan where cashbillid = ?";
        $result = $adb->pquery($selectsql,array($this->id));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $tmpentitytypeid = $adb->query_result($result,$i,"entitytypeid");
            if(!empty($tmpentitytypeid)){
                $now_entitypeids[]=$tmpentitytypeid;
                $sourceModule = $adb->query_result($result,$i,"entitytype");
            }

        }
        if(!empty($sourceModule))
            $this->updateSourceInfo($now_entitypeids,$sourceModule);


    }
    //预收单充值  收款单创建 zxm20220217
    //收款单（预收）创建或者编辑，程序（save_module）修改客户余额与累计充值金额；--debuction预收
    //收款单（收款）创建或者编辑，程序（save_module）修改累计订货金额
    public function updateAccountBalanceAmount($accountid,$cashtype){
        global $adb;
        //获取累计充值金额 充值余额
        $select_sql = " select 
                sum(ifnull(total,0)) as total,sum(ifnull(debuctionbalanceamount,0)) as debuctionbalanceamount
                from ld_cashbill 
                where accountid=?  and cashtype='debuction' and deleted=0  ";
        $select_res = $adb->pquery($select_sql,array($accountid));
        $total = $adb->query_result($select_res,0,'total');
        $debuctionbalanceamount = $adb->query_result($select_res,0,'debuctionbalanceamount');
        //修改累计充值余额
        $update_sql = " update ld_account set recharge_amount=?,balance_amount=? where accountid=?";
        $adb->pquery($update_sql,array($total,$debuctionbalanceamount,$accountid));

        if($cashtype!="debuction"){
            //获取累计订货金额
            $select_sql = " select 
                    sum(ifnull(b.amount,0)) as total
                    from ld_cashbill a left join ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
                    left join ld_salesorder s on s.salesorderid=b.entitytypeid
                    where s.accountid=?  and a.cashtype!='debuction' and b.entitytype='SalesOrder' and a.deleted=0 and s.deleted=0  ";
            $select_res = $adb->pquery($select_sql,array($accountid));
            $total = $adb->query_result($select_res,0,0);
            //修改累计订货金额
            $update_sql = " update ld_account set order_amount=? where accountid=?";
            $adb->pquery($update_sql,array($total,$accountid));
        }
    }
    /*
    自动创建收款单
    */
    public function autocreateCasbhill($fromfocus)
    {
        global $adb;
        crm_load_class_file("BankAccountSet","modules/BankAccountSet");
        $_REQUEST['cashbilldate']=date("Y-m-d");
        //230327 wym XUQIU1001157 自动生成的收款单据，默认账户排序
        $origin_module = $_REQUEST['modulename'];
        $_REQUEST['modulename'] = 'CashBill';
        $_REQUEST['bankset_fieldname'] = 'bankaccountsetid';
        $result=BankAccountSet::getBackAccount($_REQUEST['currency_id']);
        $_REQUEST['modulename'] = $origin_module;

        if($adb->num_rows($result)>0)
        {
            $_REQUEST['bankaccountsetid']=$adb->query_result($result,0,'bankaccountsetid');
        }
        else
        {
            $_REQUEST['bankaccountsetid']=0;
        }
        //zkt 20230222 BUG0061928新增合同订单是自动创建收款单，收款单单据分录，数据价税合计为0，收款金额只有第一行为总值 
        $isProductDetail = 'no';
        $sourcemodules=getSourceModule($this->module_name);
        foreach($sourcemodules as $tmp=>$sourcemoduleinfo)
        {
            if($fromfocus->module_name==$sourcemoduleinfo['entitytype'])
            {
                if($sourcemoduleinfo['withdetail']=='yes'){
                    $isProductDetail='yes';
                }
                break;
            }
        }
        //合同订单、服务合同按产品明细收款需要重新设置$_REQUEST
        if($isProductDetail == 'yes'){
            $fromDetail_table = $fromfocus->Detail_table;
            $fromDetail_table_index = $fromfocus->Detail_table_index;
            $tmpsql = "select productid,sequence_no,lineitem_id,tax_amount,ifnull(balancereceivedamount,tax_amount-ifnull(havereceivedamount,0)) as balancereceivedamount
             from $fromDetail_table  where $fromDetail_table_index = ? order by lineitem_id ";
            $productResult = $adb->pquery($tmpsql, array($fromfocus->id));
            $productTotal = $adb->num_rows($productResult);
            $_REQUEST['entitytypeid'] = $fromfocus->id;//源单ID
            $_REQUEST['rowcnt'] = $productTotal;
            for ($i = 1; $i <= $productTotal; $i++) {
                $_REQUEST['selectSourceModuleid' . $i] = $fromfocus->id;//源单ID
                $_REQUEST['lineitem_id' . $i] = $adb->query_result($productResult, $i - 1, "lineitem_id");//关联ID
                $_REQUEST['entitytype' . $i] = $fromfocus->module_name;//源单模块
                $_REQUEST['entitytypeid' . $i] = $fromfocus->id;//源单ID
                $_REQUEST['hdnProductId' . $i] = $adb->query_result($productResult, $i - 1, "productid");
                $_REQUEST['hidden_rowid_' . $i] = 0;
                $_REQUEST['tax_amount' . $i] = $adb->query_result($productResult, $i - 1, "tax_amount");
                $_REQUEST['amount' . $i] = $adb->query_result($productResult, $i - 1, "balancereceivedamount");
            }
        }
        else{
            //zkt 20231017 BUG0073942  	v8604销售后端-销售合同模块，新建保存时一直转圈，刷新后 有时保存不上（录屏见附件）
            $_REQUEST['rowcnt'] = 1;
        }
        //审批有错误，如果不添加该语句
        $tmprecord=$_REQUEST['record'];
        $_REQUEST['record']=0;
        $_REQUEST['description']=getFixedLabel('AUTOCREATE');
        //$_REQUEST['hdnGrandTotal']=$_REQUEST['curCashBill1'];
        $_REQUEST['hdnGrandTotal']=$_REQUEST['amount1'];
        $_REQUEST['mode']='Create';
        $this->mode="Create";
        setObjectValuesFromRequest($this);
    
        $this->save("CashBill");
        $_REQUEST['record']=$tmprecord;
    }
  /**
     * $records:按钮操作的ID集合
     * 修改银行账户添加金额（编辑/批量编辑保存后，审核，审批)
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
            INNER JOIN ld_cashbill on ld_bankaccountset.Bankaccountsetid=ld_cashbill.bankaccountsetid
            set curbalancemoney=ifnull(curbalancemoney,0)+ifnull(ld_cashbill.total,0)
            where ld_cashbill.cashbillid in( ".$tmprecords.")";
       
        $adb->pquery($sql,array());
         
    }
     /**
     * $records:按钮操作的ID集合
     * 修改银行账户减少金额（编辑/批量编辑保存前，删除，批量删除,反审核，反审批)
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
            INNER JOIN ld_cashbill on ld_bankaccountset.Bankaccountsetid=ld_cashbill.bankaccountsetid
             set curbalancemoney=curbalancemoney-ifnull(ld_cashbill.total,0)
              where ld_cashbill.cashbillid in( ".$tmprecords.")";
        $adb->pquery($sql,array());
         
    }
    function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		//if($return_module == 'Accounts'||$return_module=="SalesOrder"||$return_module=="PaymentPlan"||$return_module=="ServiceContracts"  ) {
			$this->trash('CashBill',$id);
	//	} 
	}
    function getSourceField($fieldname,$recordid)
    {
        global $adb;
        if($recordid > 0)
        {                
            $sql = "select entitytype from ld_cashbill where cashbillid = ? and entitytype is not NULL limit 1";        
          
            $result = $adb->pquery($sql,array($recordid));
            return $adb->query_result($result,0,0);
        }
        
        return '';
    }
    /**
     * edit:Can
     * date:20130619
     * reason:收款单删除
     * */
    function trash($module, $id)
    {
        $setsystem_check = getSys_deploy(83);
         if($setsystem_check['deploy_value']==0)
                 $this->minusBankMoney($id);//减少对应的银行的账户金额
        
       // $payment=new PaymentPlan();
       
        global $adb;
         $versioninfo=getVersionInfo();
         if($versioninfo['account']=='zhongde')
        {
             $sql="select cashbill_01,entitytypeid,amount,ld_cashbill.currency_id,ld_cashbill.conversion_rate from  ld_cashbill
		left join ld_cashbill2paymentplan on ld_cashbill.cashbillid = ld_cashbill2paymentplan.cashbillID where ld_cashbill.cashbillid=$id";
        }
        else
            $sql="select entitytypeid,amount,ld_cashbill.currency_id,ld_cashbill.conversion_rate from ld_cashbill2paymentplan 
    		left join ld_cashbill on ld_cashbill.cashbillid = ld_cashbill2paymentplan.cashbillID where ld_cashbill2paymentplan.cashbillid=$id";
        $result=$adb->pquery($sql,array());
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
         
            
            $paymentplanid=$adb->query_result($result,$i,"entitytypeid");//收款单对应的回款计划ID
           
                
            $paymentplanidList.=$paymentplanid.',';
        }

        $sql='select ld_cashbill.cashtype,ld_cashbill.accountid from ld_cashbill where cashbillid=? ';
         $tmp_result=$adb->pquery($sql,array($id));
        $cashtype=$adb->query_result($tmp_result,0,'cashtype');
        $accountid=$adb->query_result($tmp_result,0,"accountid");//客户id
        $debuctionids=array();
        $this->id = $id;
        $cashbill_01=0;
        
        if($cashtype=='cashbill'){
            //重新计算预收款单的可抵扣金额
            crm_load_class_file('cls_DebuctionInfo','modules/CashBill');
            $sql='select group_concat(distinct debuctionid) from  ld_cashbilldebuctiondetail where cashbillid=?';
            $tmpresult=$adb->pquery($sql,array($id));
            if($adb->num_rows($tmpresult)>0)
            {
                $tmpdebuctionids = $adb->query_result($tmpresult,0,0)??'';
                $debuctionids=explode(",",$tmpdebuctionids);
                unset($tmpdebuctionids);
                //$sql='delete from ld_cashbilldebuction where cashbillid=?';
//                $adb->pquery($sql,array($id));
                $sql='delete from ld_cashbilldebuctiondetail where cashbillid=?';
                $adb->pquery($sql,array($id));
            }
        }
        else {
             if($versioninfo['account']=='zhongde')
             {
                $cashbill_01=$adb->query_result($result,0,'cashbill_01');
               
             }
        }
        //  $this->retrieve_entity_info($id);
       
        $sql='delete from ld_cashbill where cashbillid=?';
        $adb->pquery($sql,array($id));
        if(!empty($cashbill_01))
        {
            $sql='select sum(total) as zhongdebackmoney from ld_cashbill where cashbill_01=? ';
            $zhongdebackmoney=0;
            $tmpresult=$adb->pquery($sql,array($cashbill_01));
            if($adb->num_rows($tmpresult)>0)
            {
                $zhongdebackmoney=$adb->query_result($tmpresult,0,'zhongdebackmoney');
            
            }
            $updatesql='update ld_cashbill set zhongde_backmoneny=0-? where cashbillid=? ';
            $adb->pquery($updatesql,array($zhongdebackmoney,$cashbill_01));
        
        }
        //系统操作日志
        crm_load_class_file('cls_OperationLogs','modules/Settings/cls_OperationLogs');
        cls_OperationLogs::saveDeletedRecordInfo($module,[$id]);
        // parent::trash($module,$id);
        $sql='delete from ld_crmentity where crmid=?';
        $adb->pquery($sql,array($id));
      
        $selectsql = "select entitytypeid,entitytype from ld_cashbill2paymentplan where cashbillid = ?";
        $result = $adb->pquery($selectsql,array($id));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $entitytypeids[]=$adb->query_result($result,$i,"entitytypeid");//收款单对应的回款计划ID   
            $sourcemodule = $adb->query_result($result,$i,"entitytype");
        }
       
        $sql='delete from ld_cashbill2paymentplan where cashbillid=?';
        $adb->pquery($sql,array($id));
        $sql='delete from ld_approvelog where crmid=?';
        $adb->pquery($sql,array($id));
       
       //重新计算收款单对应回款计划的已收金额
        $paymentplanidList=substr($paymentplanidList,0,strlen($paymentplanidList)-1); 
        $this->update_PaymentActualamount($paymentplanidList);
        $this->updateSourceInfo($entitytypeids,$sourcemodule);
        if($cashtype=='cashbill'){
            
              
            cls_DebuctionInfo::updateDebuctionInfo($debuctionids);
            
        }
        $this->updateSourceMainamount($entitytypeids,$sourcemodule);
        $this->updateSourceDetailamout($entitytypeids,$sourcemodule);
        //zxm 20221115 收款单删除 客户的充值余额 充值总金额没有更新的bug
        $this->updateAccountBalanceAmount($accountid,$cashtype);
        $logcontent = $_REQUEST;
        $logcontent["deletetype"] = "rassdelete";
        cls_OperationLogs::saveLogs($module,'Delete',$id,$logcontent);
    }
    /*
    edit:can
    date:20130620
    reason:收款单还原后，也要还原相关的回款计划
    */
    function restore($module, $id)
    {
        parent::restore($module,$id);
       
    }
    /*
    edit:can
    date:20130620
    reason:回款计划批量修改
    
    */
      function MassSave($modules,$columns)
      {
         global $adb,$current_user;
        $this->db->println("TRANS saveentity starts $modules");
         /**
             * 更新操作
             * edit:can
             * date:20131202
             * reason:5954: 批量收款改进：批量收款时可选择设定“收款日期”（皓星）
             * */
        if($_REQUEST['CashBillDate']=='curdate')
        {
            $actualdate=date("Y-m-d");
        }
        else if($_REQUEST['CashBillDate']=='customdate')
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
         
            $paymentplanid=$_REQUEST['SysBol'.$i];
            //$actualamount=$_REQUEST['actualamount'.$i];
            $thistime=$_REQUEST['thistime'.$i];
            $iscashbill= '';
            //$iscashbill=$_REQUEST['iscashbill'.$i];
            $paymentmethod=$_REQUEST['paymentmethod'.$i];
            $salesorderid=$_REQUEST['salesorder'.$i];
            $accountid=$_REQUEST['account'.$i];
            $bankaccountsetid=$_REQUEST['bankaccountsetid'.$i];
            $current_id=$adb->getUniqueID("ld_crmentity");
            $smownerid=$current_user->id;
            /**
             * 更新操作
             * edit:can
             * date:20131202
             * reason:5954: 批量收款改进：批量收款时可选择设定“收款日期”（皓星）
             * */
             if($_REQUEST['CashBillDate']=='plandate')
             {
                    $sql='select plandate from ld_paymentplan where paymentplanid=?';
                    $paymentresult=$adb->pquery($sql,array($paymentplanid));
                    if($adb->num_rows($paymentresult)>0)
                    {
                        $actualdate=$adb->query_result($paymentresult,0,0);
                    }
             }     
            $sql='insert into ld_crmentity(crmid,setype) values(?,?);';
                                            
            $adb->pquery($sql,array($current_id,"CashBill"));
            
            $CashBillNo=$this->Library('SystemCode')->setModuleSeqNumber("increment", "CashBill"); 
			$currencyinfo = getModuleCurrencyInfo($paymentplanid,'PaymentPlan');
            /**
            andrew
            原批量回款entitytype写死为合同订单的。现在修改我合同订单和服务合同都可以
            */
                // $entype="SELECT entitytype FROM ld_paymentplan WHERE paymentplanid=$paymentplanid";
               //  $entyperesult=$adb->pquery($entype,array());  
                // $entyperel=$adb->query_result($entyperesult,0,0); 
            //edit:Can 20210514 045885: 深圳赢方（http://124.71.102.36:86/crm [^])多个收款计划批量收款的时候，收款单中无法自动带出源单单号。
            $sql = 'insert into ld_cashbill(cashbillid,source_list,cashbill_no,accountid,salesorderid,cashbilldate,paymentmethod,iscashbill,total,subtotal,nopaymentplan,smcreatorid,smownerid,modifiedby,createdtime,modifiedtime,bankaccountsetid,entitytype,currency_id,conversion_rate,currency_symbol)
                                    values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);';
            $adb->pquery($sql,array($current_id,$paymentplanid,$CashBillNo,$accountid,'',$actualdate,$paymentmethod,$iscashbill,$thistime,$thistime,0.00,$smownerid,$smownerid,$smownerid,$entitytime,$entitytime,$bankaccountsetid,'PaymentPlan',$currencyinfo['curid'],$currencyinfo['rate'],decode_html($currencyinfo['symbol'])));                  
             $sql='insert into ld_cashbill2paymentplan(cashbillid,paymentplanid,amount,sequence,cashbillstatus,salesorderid,entitytypeid,entitytype)
                    values(?,?,?,?,?,?,?,?)';

            $adb->pquery($sql,array($current_id,'',$thistime,$i,0,'',$paymentplanid,'PaymentPlan'));
			$paymentplanid_arr[] = $paymentplanid;
           /* if($this->get_CashBillCheckoutstatusWhere()=='')
              {
                  $sql='update ld_paymentplan set actualamount=amount,paymentstatus="已收",actualdate=? where paymentplanid=?';
               
               
                $adb->pquery($sql,array($actualdate,$paymentplanid));
                $this->deleteReminds($paymentplanid);
                
            }*/
			//因为插入不会调用触发器，所以在这update一下，更新订单的已收总额、最新收款日期
			$adb->pquery('update ld_cashbill set cashbillid = ? where cashbillid = ?',array($current_id,$current_id));
            $i++;
        }
		$this->update_PaymentActualamount(implode(',',$paymentplanid_arr));
        
    	$this->db->completeTransaction();
    	$this->db->println("TRANS saveentity ends");
      }
      private function deleteReminds($id)
      {
         crm_load_class_file('Reminds','modules/Reminds');
        $reminds_focus=new Reminds();
        $reminds_focus->deleteRecord($id,'未读');
        
      }
	function getEntitytypeId($id)
	{
		global $adb;
		$query = "select 1 from ld_cashbill2paymentplan where cashbillid = ?";
		$result = $adb->pquery($query,array($id));
		if($adb->num_rows($result) >= 1)
			return $adb->num_rows($result);
		else
			return 0;
	}
    /**
    *andrew
    * 2015-10-19
    * 重新计算回款计划已收款金额
    **/
	function update_PaymentActualamount($paymentidlist)
	{
		global $adb;
        if(empty($paymentidlist)||trim($paymentidlist)==',')
        {
            return;
        }
    
        
        /**
        *SQL说明：获取收款单id,已收金额，最近收款日期，回<?php
	
                    ?>款计划金额
        * 已收金额：收款单金额转人民币金额->转回款计划币种金额
        */
        
        $selectSQL="SELECT
                    	ld_paymentplan.paymentplanid,
                    	SUM(
                                	case when ld_cashbill.currency_id=ld_paymentplan.currency_id
													 then ld_cashbill.amount
													else 
														ld_cashbill.amount/ld_cashbill.conversion_rate*ld_paymentplan.conversion_rate
													end 
                    	) AS actualamount,
                     
                    	ld_paymentplan.amount,
                    	ifnull(max(cashbilldate),'0000-00-00') AS actualdate
                    FROM
                    	ld_paymentplan
                    LEFT JOIN (
                    	SELECT entitytypeid,
                    		ld_cashbill2paymentplan.amount,ld_cashbill.cashbillid,ld_cashbill.currency_id,ld_cashbill.conversion_rate,cashbilldate
                    	FROM
                    		ld_cashbill 
                    INNER JOIN ld_cashbill2paymentplan ON ld_cashbill.cashbillid = ld_cashbill2paymentplan.cashbillid
                    	WHERE
                    		deleted = 0 "
                    .$this->get_CashBillCheckoutstatusWhere().") as
                     ld_cashbill ON ld_cashbill.entitytypeid = ld_paymentplan.paymentplanid
                    WHERE ld_paymentplan.paymentplanid in ($paymentidlist) AND ld_paymentplan.deleted=0 
                     GROUP BY ld_paymentplan.paymentplanid";
                
        $actualamountresult=$adb->pquery($selectSQL,array());
        $rowCount = $adb->num_rows($actualamountresult);
        
        for ($i = 0; $i < $rowCount; $i++) {
            $paymentplanid=$adb->query_result($actualamountresult,$i,'paymentplanid');
            $actualamount=$adb->query_result($actualamountresult,$i,'actualamount');
            $actualdate=$adb->query_result($actualamountresult,$i,'actualdate');
            $amount=$adb->query_result($actualamountresult,$i,'amount');
            
            //回款计划金额和已收金额比对出回款状态
            if($actualamount<=0)
            {
                $paymentstatus="未收";
            }
            elseif($actualamount + 0.001 >=$amount)
            {
                $this->deleteReminds($paymentplanid);
                $paymentstatus='已收';
            }
            else
            {
                $paymentstatus='部分已收';
            }
            
    		$query = "UPDATE ld_paymentplan SET actualamount=?,actualdate=?,paymentstatus=? WHERE ld_paymentplan.paymentplanid=?;";
            $adb->pquery($query,array($actualamount,$actualdate,$paymentstatus,$paymentplanid));
			if($paymentstatus == '已收'){
				$version_info = getVersionInfo();
                // 商贸批发小程序
				if($version_info['account'] == 'dongmao'&&$version_info['trade'] == 'dongmao' && !empty($paymentplanid)){
					$this->dongmao_DMessageForPayment($paymentplanid);
				}
				$this->deleteReminds($paymentplanid);
			}
            //edit: xll 2023/08/03 BUG0070577 收款计划状态值更新，自动化进度字段值也需更新
			$this->save_advancestage($paymentplanid,'PaymentPlan');
        }

		
	}
	
	//东贸 微信缴费成功通知 - 缴费商户
	function dongmao_DMessageForPayment($crmid){
		global $adb;
		$query = "select amount,accountid from ld_paymentplan where paymentplanid = ?";
		$result = $adb->pquery($query,array($crmid));
		$amount = $adb->query_result($result,0,'amount');	//金额
		$accountid = $adb->query_result($result,0,'accountid');
		if(!empty($accountid)){
			$query = "select unionid,wechatuserid from ld_wechatuser where accountid = ? and deleted = 0";
			$result = $adb->pquery($query,array($accountid));
			$unionid = $adb->query_result($result,0,0);
			$query = "select open_id,wechatuserid from ld_wechatuser where unionid = ? and deleted = 0 and userfromvalue = 'offiaccount_dmsh'";
			$result = $adb->pquery($query,array($unionid));
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				$open_id = $adb->query_result($result,0,'open_id');
				$wechatuserid = $adb->query_result($result,0,'wechatuserid');
				require_once (globalStatic::$root_directory.'include/weixinMsg/cls_DongmaoMerchantMessage.php');
				require_once (globalStatic::$root_directory.'include/weixinMsg/cls_DMmessageMerchantDefault.php');
				$dongmaoObj = new cls_DongmaoMerchantMessage();
				$dmMsgData = cls_DMmessageMerchantDefault::$DMmessageData['PaymentSucceeded'];
				$dmMsgPage = cls_DMmessageMerchantDefault::$DMmessageJump['PaymentSucceeded'];
				// $open_id = 'oFb1D6vrhRAR99vOVhwslZTaJhKs';
				// $wechatuserid = 227441;
				$data = array(
					'title' => $dmMsgData['titme'],	
					'amount' => $amount . '元',
					'time' => date('Y-m-d H:i:s'),
					'time_end' => date('Y-m-d H:i:s'),
					'remark' => $dmMsgData['remark']
				);
				
				$dongmaoObj->send('PaymentSucceeded',$open_id,$dmMsgPage['page'],$data,$wechatuserid,'HelpDesk',$crmid,$dmMsgPage['pageType'],$accountid);
			}
		}

		
	}
    /**
	 * edit:chj
	 * reason:获取回款计划的对应订单ID
	 * date:2014-8-20
	 * */
	function getPlanmentSalesOrderId($planmentid)
	{
		global $adb;
		$sql = "select entitytypeid from ld_paymentplan where paymentplanid = ?";
		$result = $adb->pquery($sql,array($planmentid));
		return $adb->query_result($result,0,0);
	}
    /**
    *andrew
    * 2015-10-19
    * 已收金额计算时是否统计未审核的收款单,参数判断返回where条件
	* 0 是 1 否
    **/
	function get_CashBillCheckoutstatusWhere()
	{
		global $adb;
		//收款单是否启用审批流程  0是 1 否
		$setsystem_approve = getSys_deploy(133);
		//已收金额计算时是否统计未审核的收款单  0 是 1 否
		 $setsystem_check = getSys_deploy(83);
		if($setsystem_approve['deploy_value']==0){
			if($setsystem_check['deploy_value']==1){
				return ' and ifnull(ld_cashbill.approvestatus,"")=\''.D_A_S_APPROVED.'\' ';
			}/*else{
				return ' and ifnull(ld_cashbill.approvestatus,"") <> \'已拒绝\' ';
			}*/
		}else{
			if($setsystem_check['deploy_value']==1){
			 return ' and 1=1 ';
			//	return ' and ifnull(ld_cashbill.approvestatus,"")=\''.D_A_S_UNAPPROVED.'\' ';
			}else{
				return '';		
			}
		}
	}
   
	/**
	 * 收款单  - 审核操作
	 * @param $record：收款单id
	 * @return
	 * @author Chj
	 */
	function updateCashBillStatus($record) {
		global $adb,$current_user;
		$sql = "update ld_cashbill set checkoutstatus='已审核',checker=$current_user->id where deleted=0 and cashbillid in ($record)"; 
		$adb->pquery($sql,array());
		$this->updateCashbillSourceDetail($record);
        $setsystem_check = getSys_deploy(83);
         if($setsystem_check['deploy_value']==1)
         {
             $this->addBankMoney(array($record));
                /*$smongysql = "SELECT bankaccountsetid,total FROM ld_cashbill WHERE checkoutstatus='已审核' and cashbillid in ($record)";
        		$result = $adb->pquery($smongysql,array());
        		$num_rows = $adb->num_rows($result);
               
        		if($num_rows >= 1){
        			for($i=0;$i<$num_rows;$i++){
        				$account = $adb->query_result($result,$i,'bankaccountsetid');
        				$monery = $adb->query_result($result,$i,'total');
        				$usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)+? WHERE deleted=0 and bankaccountsetid=?";
        				$adb->pquery($usql,array($monery,$account));
        			}
        		}*/
         }
		
		//重新计算已收款金额
		$this->updatePaymentActualamount($record);
	}
    
	/**
	 * 反审核,凡审批
	 * @param $record：收款单id
	 * @return
	 * @author Chj
	 */
	function upadteBackCashBillStatus($record) {
		global $adb;
		//edit:can reason:10865: “收款单、付款单”明细查看界面：点击【反审核】按钮后，“审核人”应该被清空。
		$query = 'select checkoutstatus from ld_cashbill where cashbillid = ?';
		$result = $adb->pquery($query,array($record));
		$before_checkoutstatus = $adb->query_result($result,0,0);
		$sql = "update ld_cashbill set checkoutstatus='未审核' ,checker=0 where deleted=0 and cashbillid= ?";
		$adb->pquery($sql,array($record)); 
        $this->updateCashbillSourceDetail($record);
         $setsystem_check = getSys_deploy(83);
         if($setsystem_check['deploy_value']==1)
         {
            if($before_checkoutstatus == '已审核'){
                $this->minusBankMoney(array($record));
                
                }
    		/*$smongysql = "SELECT bankaccountsetid,total FROM ld_cashbill WHERE checkoutstatus='未审核' and cashbillid= ?";
            $result = $adb->pquery($smongysql,array($record));
            $account = $adb->query_result($result,0,'bankaccountsetid');
            $monery = $adb->query_result($result,0,'total');
    		if($before_checkoutstatus == '已审核'){
    			$usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)- ? WHERE deleted=0 and bankaccountsetid=?";
    			$adb->pquery($usql,array($monery,$account));
    		}*/
            
         }
        
        $this->updatePaymentActualamount($record);//重新计算已收款金额
	}
    
   
	//审核后重算收款单明细表字段
	function updateCashbillSourceDetail($record){
		global $adb;
		$ids = explode(',',$record);
		foreach($ids as $cashbillid){
			$selectsql = "select entitytypeid,entitytype from ld_cashbill2paymentplan where cashbillid = ?";
			$result = $adb->pquery($selectsql,array($cashbillid));
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
        global $adb;
       
        if($sourcemodule=='SalesOrder'||$sourcemodule=='ServiceContracts'||$sourcemodule=='Invoice'||$sourcemodule=='OutboundOrder'
        ||$sourcemodule=='PaymentPlan')  
            return ;
          
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
   	    $cashbillwheresql = $this->get_CashBillCheckoutstatusWhere();
        //zkt 20230515 BUG0066342 销售合同（原“销售机会”模块）关联收款单保存后，收款金额没有反写至单据中 
      $sql="update $source_Table_name LEFT JOIN (select sum(case when $source_Table_name.currency_id=$table_name.currency_id then $DetailTable_name.amount 
            else  $DetailTable_name.amount/$table_name.conversion_rate*$source_Table_name.conversion_rate end)  as sumamount,$DetailTable_name.entitytypeid
             from $DetailTable_name
            
            INNER JOIN $table_name on $table_name.$table_index=$DetailTable_name.$Detail_table_index
            inner join $source_Table_name  on $DetailTable_name.entitytypeid=$source_Table_name.$source_table_index
            where $DetailTable_name.entitytypeid in($strentitytypid) $cashbillwheresql
             group by entitytypeid )  as tmpsum  
            on tmpsum.entitytypeid=$source_Table_name.$source_table_index 
            set  $source_Table_name.received_amount=tmpsum.sumamount ,$source_Table_name.receivable_balance=$source_Table_name.total-ifnull(tmpsum.sumamount,0)  
           where $source_Table_name.$source_table_index in($strentitytypid)
            ";
        
      $adb->pquery($sql);
             
    }
    //zkt 20220816 更新源单产品已收总额
    function updateSourceDetailamout($entitytypeid_arr,$sourcemodule){
        global $adb;
        
        $sourcemodulearr = getSourceModule($this->moduleName);
        $isproductsourcemodule = 'no';
        foreach($sourcemodulearr as $sourcemoduleinfo){
            if($sourcemoduleinfo['entitytype']==$sourcemodule&&$sourcemoduleinfo['withdetail']=='yes'){
                $isproductsourcemodule = 'yes';
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
        	$cashbillwheresql = $this->get_CashBillCheckoutstatusWhere();
             $sql=  "  update $source_DetailTable_name
             left join (
            
            select sum( case when ($table_name.currency_id=$source_Table_name.currency_id) then amount
            		else  amount/$table_name.conversion_rate*$source_Table_name.conversion_rate end ) as havereceivedamount,parent_lineitem_id
                         from $table_name INNER JOIN $DetailTable_name
            
            on $DetailTable_name.$table_index=$table_name.$table_index
            inner join $source_Table_name on $source_Table_name.$sourcetable_index=$DetailTable_name.entitytypeid
            where $table_name.deleted=0 and  $DetailTable_name.entitytypeid in($strentitytypid)  $cashbillwheresql
                and $DetailTable_name.entitytype='$sourcemodule'
            group by $DetailTable_name.parent_lineitem_id
            ) as tmp on tmp.parent_lineitem_id=$source_DetailTable_name.lineitem_id
            set $source_DetailTable_name.havereceivedamount=ifnull(tmp.havereceivedamount,0),
            balancereceivedamount=$source_DetailTable_name.tax_amount-ifnull(tmp.havereceivedamount,0)
             where $source_DetailTable_name.$source_Detail_table_index in($strentitytypid)";
             $adb->pquery($sql,array());
             return false;
            
         
    }
    
    function updateSourcereceived_Amount(){
        return false;
        /*
        if($sourcemodule == 'SalesOrder'&&$sourcemodule == 'ServiceContacts'&&$sourcemodule == 'Invoice'
        &&$sourcemodule == 'PaymentPlan'&&$sourcemodule == 'OutboundOrder'){
            //反写已收总额至源单
            
        }
        */
    }

	//$cashbillid收款单ID
	//审核后重新计算已收款金额
	function updatePaymentActualamount($cashbillid){
		global $adb;
		$getPaymentIdSQL="SELECT DISTINCT ld_cashbill2paymentplan.entitytypeid FROM ld_cashbill 
							INNER JOIN ld_cashbill2paymentplan ON ld_cashbill.cashbillid = ld_cashbill2paymentplan.cashbillid
							INNER JOIN ld_paymentplan ON ld_paymentplan.paymentplanid = ld_cashbill2paymentplan.entitytypeid
							WHERE ld_paymentplan.deleted=0 AND ld_cashbill.cashbillid in ($cashbillid)";
		$PaymentIdresult=$adb->pquery($getPaymentIdSQL,array());
        $paymentidlist = '';
        if($adb->num_rows($PaymentIdresult)<=0)
            return ;
		for($i=0;$i<$adb->num_rows($PaymentIdresult);$i++){
			$paymentidlist .= $adb->query_result($PaymentIdresult,$i,'entitytypeid').',';
		}
        if(is_string($paymentidlist)&&strlen($paymentidlist)>0){
		    $paymentidlist=substr($paymentidlist,0,strlen($paymentidlist)-1);
        }
		$this->update_PaymentActualamount($paymentidlist);
	}

	//审批成功操作
	public function successApprove($record)
	{
		$this->updateCashBillStatus($record);
         global $adb;
    	$selectsql = "select entitytypeid,entitytype from ld_cashbill2paymentplan where cashbillid = ?";
		$result = $adb->pquery($selectsql,array($record));
		for($i=0;$i<$adb->num_rows($result);$i++)
		{
			$entitytypeids[]=$adb->query_result($result,$i,"entitytypeid");//收款单对应的回款计划ID   
			$sourcemodule = $adb->query_result($result,$i,"entitytype");
		}
        $this->updateSourceMainamount($entitytypeids,$sourcemodule);
       $this->updateSourceDetailamout($entitytypeids,$sourcemodule);
	}
    ////反审批操作
    public function rejectApproved($record)
    {
        	$this->upadteBackCashBillStatus($record);
             global $adb;
    	$selectsql = "select entitytypeid,entitytype from ld_cashbill2paymentplan where cashbillid = ?";
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
		///$this->upadteBackCashBillStatus($record);
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
        if(isset($_REQUEST['selectsource'])){//不知道哪里传的
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

        $subtotal = 0;
        if($isProductDetail == 'yes')
        {
            $ProductToolFields = ProductToolFields::getInstance($this->module_name);
            $ProductToolFields-> ResetBillEmpty();
            $ProductToolFields->setsourceModulesqlwhere($selectsourceModule);

            $before_product_havereceivedammount = array();
            //
            $selectsql = "select entitytypeid,entitytype,amount from ld_cashbill2paymentplan where cashbillid = ?";
            $result = $adb->pquery($selectsql,array($this->id));
            for($i=0;$i<$adb->num_rows($result);$i++)
            {
                $tmp_entityttypeid = $adb->query_result($result,$i,"entitytypeid");
                $before_entitytypeids[]=$tmp_entityttypeid;
                $before_sourcemodule = $adb->query_result($result,$i,"entitytype");
                $before_amount = $adb->query_result($result,$i,"amount");
            }
            $this->updateSourceInfo($before_entitytypeids,$before_sourcemodule);
            //收款单明细保存
            crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            $savereturnarr = saveInventoryProductDetails($this, $this->module_name);
            $subtotal = $savereturnarr['subtotal'];
            $sql='select entitytype,entitytypeid from ld_cashbill2paymentplan  where cashbillid=? and entitytype=?';
            $result=$adb->pquery($sql,array($this->id,'PaymentPlan'));
            $num_rows=$adb->num_rows($result);
            for($i=0;$i<$num_rows;$i++)
            {
                $entitytypeid = $adb->query_result($result,$i,$selectsourceModule);
                if(!empty($entitytypeid)){
                    $now_entitypeids[]=$entitytypeid;
                }

            }
        }
        else
        {
            crm_load_class_file('cls_save_moduledetail','data');
            $obj=new cls_save_moduledetail($this->module_name,$this->id);
            //记录保存前的分录信息
            $before_db_value_arr = $obj->save_before_detailinfo();
            $sourceModule = $_REQUEST['selectsource'];
            //更改收款单的源单模块 module
            //issourcemodule 当前DB中已选模块  $sourceModule当前选择源单模块名
            if(isset($sourceModule))
            {
                $adb->pquery('update ld_cashbill set entitytype = "'.$sourceModule.'" where cashbillid = ' . $this->id);
            }
            else if(isset($_REQUEST['selectsourcename']))
            {
                $sourceModule=$_REQUEST['selectsourcename'];
            }
            $before_entitytypeids=[];
            $before_sourcemodule=[];
            //删除明细表后，更新编辑前源单字段值
            $selectsql = "select entitytypeid,entitytype from ld_cashbill2paymentplan where cashbillid = ?";
            $result = $adb->pquery($selectsql,array($this->id));
            for($i=0;$i<$adb->num_rows($result);$i++)
            {
                $before_entitytypeids[]=$adb->query_result($result,$i,"entitytypeid");
                $before_sourcemodule = $adb->query_result($result,$i,"entitytype");
            }
            /****获取保存前的值end ***/
            $query = 'delete from ld_cashbill2paymentplanscf where cashbill2paymentplan_id in( select cashbill2paymentplan_id from ld_cashbill2paymentplan where cashbillid = ?) ';
            $adb->pquery($query,array($this->id));
            $adb->pquery('delete from ld_cashbill2paymentplan where cashbillid = ' . $this->id);
            $this->updateSourceInfo($before_entitytypeids,$before_sourcemodule);
            $subtotal=0;
            $i=1;
            $row_index = 0;
            //0050404: （蝶金时代）http://116.63.172.133:85/crm [^] 代理商系统 审批通过后服务合同没有自动创建收款单(创建收款单明细时判断会使用$_REQUEST['rowcnt'])
            if (!isset($_REQUEST['rowcnt'])) {
                $_REQUEST['rowcnt'] = 1;
            }
            $TabDetailFields = new TabDetailFields(getTabid("CashBill"));

            $TabDetailFields->setsourceModulesqlwhere($selectsourceModule);
            $tabDetailFields = $TabDetailFields->getTabDetailFields();//获取了所有字段，包括隐藏字段
            $aferentitytid_arr=[];
            $tab_name_index = $this->tab_name_index;
            //循环开始
            while(true)
            {

                if($row_index >= $_REQUEST['rowcnt']){
                    break ;
                }

                $entitytypeid = $_REQUEST['entitytypeid'.$i];	//原单id
                $detail_sequence=$_REQUEST['detail_sequence'.$i];//
                if(!empty($entitytypeid))
                    $aferentitytid_arr[]=$entitytypeid;
                $row_index++;
                if($_REQUEST['deleterow'.$i] == 0)
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
                    $subtotal += $_REQUEST['amount'.$i];
                    $insertValue['ld_cashbill'] = $insertTable['ld_cashbill'];
                    $insertValue['ld_cashbill2paymentplan'] = $insertTable['ld_cashbill2paymentplan'];
                    $insertValue['ld_cashbill2paymentplanscf'] = $insertTable['ld_cashbill2paymentplanscf'];
                    foreach($insertValue as $tablename => $columvalues){
                        if(!is_array($columvalues))
                        {
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
                                //echo $query.'<br>';
                                //echo '<pre>';print_r($columvalues);echo '<pre>';
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
            $nopaymentplan=0;

            //非产品分录-保存分录修改日志
            $obj->save_moduleddetail_log($before_db_value_arr,$new_detailid_arr,$request_value_arr);

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

        $return_arr['subtotal'] = $subtotal;
        $return_arr['now_entitypeids'] = $now_entitypeids;

        return $return_arr;
    }
    /**
     * @reason: 获取预收单信息:
     * @param: $debuctionid
     * @edit:zkt
     * @date:2024/12/20
     */
    public function getDebuctionInfoByDebuctionid($debuctionid):array
    {
        if(is_array($this->debuctioninfobyid_arr)&&isset($this->debuctioninfobyid_arr[$debuctionid])){
            return $this->debuctioninfobyid_arr[$debuctionid];
        }
        $return_arr = [];
        $sql = "select * from ld_cashbilldebuctiondetail where debuctionid = ?;";
        $result = $this->db->pquery($sql,array($debuctionid));
        $num_rows = $this->db->num_rows($result);
        $not_0_count = 0;//核销金额非0的数据数量
        if($num_rows>0){
            for($tmpi = 0; $tmpi<$num_rows; $tmpi++){
                $id = $this->db->query_result($result,$tmpi,'id');
                $amount = $this->db->query_result($result,$tmpi,'amount');
                if((float)$amount!=0){
                    $not_0_count++;
                }
            }
        }
        $return_arr['not_0_count'] = $not_0_count;
        $this->debuctioninfobyid_arr[$debuctionid] = $return_arr;
        return $return_arr;
    }

   
}
CashBill::require_file();
?>