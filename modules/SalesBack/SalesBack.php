<?php

define("SALESBACKINSTOCK","已入库");
define("SALESBACKOUTSTOCK",'未入库');

class SalesBack extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['SalesBack']='SalesBack';
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
    var $Detail_table="ld_salesbackdetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_salesbackdetailscf";//明细scf表
     var $Detail_table_index="id";//明细表和主表关联的字段
    var $table_name='ld_salesback';
    public $table_index='salesbackid';
    var $table_code='salesback_no';//表编号字段(审批中心)
    var $tab_name=Array('ld_crmentity','ld_salesback','ld_salesbackscf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_salesback'=>'salesbackid','ld_salesbackscf'=>'salesbackid');
   	var $customFieldTable = Array('ld_salesbackscf', 'salesbackid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";

	var $column_fields = Array();
    var $sortby_fields=Array('salesbackid,salesbackdate');
    var $module_name='SalesBack';
    /*
    edit:can
    date:20131024
    reason:打印关联模块
    */
    var $relatedtab=array('accounts'=>'','users'=>'','company'=>'','salesback'=>'','salesorder'=>'','products'=>'');
            
    var $list_link_field= 'salesback_no';
            
            
   	var $search_fields_name = Array(
		          
			);
            
   var $required_fields =  array();

//比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'sendcashbill_no');
	var $default_order_by = 'salesbackid';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="salesback_no";
    var $popup_fields=Array();
    function __construct()
    {
		//$this->log =LoggerManager::getLogger('SalesBack');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj = Field::getInstance('SalesBack',$this->db);
		//$this->column_fields = getColumnFields('SalesBack',$this);
		$this->column_fields = $this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('SalesBack');
        $this->list_link_field=$entityname['fieldname'];
        $this->popup_fields=Array($this->list_link_field);
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
    }
   
   function save_module($module)
   {        
		global $adb;
		/*if(isset($_REQUEST['createview'])&& $_REQUEST['createview']=='create_view')
		{
			$update_query = "update ld_salesback set salesbackstatus='未入库' where salesbackid=?";
			$adb->pquery($update_query, array($this->id));
		}*/
        
        
		if($_REQUEST['action'] != 'SalesBackAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW' 
			&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
			crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
			saveInventoryProductDetails($this, 'SalesBack');
		}
        
        //放在函数的最下面，等待主表更新total字段更新完成
    //    crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
      //  cls_Source_InverseCompute::Source_InveverseCompute($module,$this->id,$this);

		//编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
		if($this->currency_status === true)
		{
			$update_query = "update ld_salesback set currency_id=?, conversion_rate=?,currency_symbol=? where salesbackid=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}
        $fieldinfo=$this->fieldobj->getFieldInfoobjBykey("columnname",'salesbackstatus');
        if($fieldinfo&&$fieldinfo->getDefaultvalue()!=''&&$this->mode!='edit')
        {
            //36933: （1.6）合同订单新增界面>选择产品编号为【PRO2083】的产品>产品数量为100>保存合同订单>关联创建出库单将100个产品全部出库>合同订单关联创建销售退货单>退货20个产品并审批通过：对应的产品总库存数量显示的还是-100（需要补丁）
            //edit:can 2021-01-13 0044224: （https://61mis.com/kfbcrm [^] ）（云泰五金）销售退货单中有一个状态字段，当这个字段设置了默认值之后，新建的时候选择其他选项不会生效。比如默认值是未入库，新建退货单的时候选择已入库没有效果。
            if($this->column_fields['salesbackstatus']=='')
                $this->column_fields['salesbackstatus']=$fieldinfo->getDefaultvalue();
        }

        //编辑时，状态不变，源单改变也需要重新计算
//        if($this->column_fields['salesbackstatus']!=$this->before_save_infos[0]['salesbackstatus'])
//        {
           
            if($this->column_fields['salesbackstatus']==SALESBACKINSTOCK)
                    $this->operationwarehouse($this->id,'instock');
            else if($this->column_fields['salesbackstatus']==SALESBACKOUTSTOCK&&$this->mode=='edit')//新增未入库不做反写处理
            {
               
                  $this->operationwarehouse($this->id,'outstock');
            }
              
//        }

		$update_query = "update ld_salesback set triggercount=triggercount+1 where salesbackid=?";
		$this->db->pquery($update_query,array($this->id));

   }
    
    function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;
        
        $this->trash('SalesBack',$id);
		 
	}
    
    
    function get_communicationLog($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global $adb;
		global $currentModule;
		global $list_max_entries_per_page_new_more;
        $sql = 'select ld_smssend.ReceiveContacts,ld_smssend.CalledNumber,
        ld_smssend.Subject, ld_smssend.SmsContent,ld_smssend.SmsBillingFee,
        case when IFNUll(SmsResult,0)=-1 then "待提交" when IFNUll(SmsResult,0)=1 
        then "发送成功" when (IFNUll(SmsResult,0)<>1 and IFNUll(SmsResult,0)<>-1) 
        then "发送失败" end smsresultname,createtime, ld_users.last_name as operator  
        from ld_smssend left join ld_users on ld_smssend.operator = ld_users.user_name  
        where relatieid = '.$id.' order by ld_smssend.createtime desc ';
        $count_result = $adb->query(mkCountQuery($sql));
		$noofrows = $adb->query_result($count_result,0,'count');
		global $related_left_type;
		if($related_left_type == 3){//获取相关信息条数
			$related_entries = array();
			$related_entries['relcount'] = $noofrows;
			return $related_entries;
		}
		if(isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
			$start = vtlib_purify($_REQUEST['start']);
			if($start == 'last'){
				if($noofrows > 0){
					$start = ceil($noofrows/$list_max_entries_per_page_new_more);
				}
			}
			if(!is_numeric($start)) $start = 1;
			elseif($start < 1) $start = 1;
			$start = ceil($start);
		}else{
			$start = 1;
		}
		global $related_left_start;
		$related_left_start = $start;
		$limstart=($start-1)*$list_max_entries_per_page_new_more;
		$sql .= ' LIMIT '.$limstart.','.$list_max_entries_per_page_new_more.' ';
        //手机、主题、接收人、发送时间、发件人、内容，
        $header = array(
			'<span title="'.getFixedLabel('Mobile').'">' . getFixedLabel('Mobile') . '</span>',
			'<span title="'.getFixedLabel('Recipient').'">' . getFixedLabel('Recipient') . '</span>',
			'<span title="'.getFixedLabel('Delivery_time').'">' . getFixedLabel('Delivery_time') . '</span>',
			'<span title="'.getFixedLabel('FROMMAIL').'">' . getFixedLabel('FROMMAIL') . '</span>',
			'<span title="'.getFixedLabel('Content').'">' . getFixedLabel('Content') . '</span>',
			'<span title="'.getFixedLabel('SENDSTATESMS').'">' . getFixedLabel('SENDSTATESMS') . '</span>'
		);
        $result = $adb->pquery($sql,array());
        $num_rows=$adb->num_rows($result);
        if($num_rows>0)
        {
            for($i=0;$i<$num_rows;$i++)
            {
                $listview_entrie = array();

                $listview_entrie[]= '<span title="'.$adb->query_result($result,$i,'callednumber').'">'.$adb->query_result($result,$i,'callednumber').'</span>';
                //$listview_entrie[]= $adb->query_result($result,$i,'subject');
                $listview_entrie[]= '<span title="'.$adb->query_result($result,$i,'receivecontacts').'">'.$adb->query_result($result,$i,'receivecontacts').'</span>';
                $listview_entrie[]= '<span title="'.$adb->query_result($result,$i,'createtime').'">'.$adb->query_result($result,$i,'createtime').'</span>';
                $listview_entrie[]= '<span title="'.$adb->query_result($result,$i,'operator').'">'.$adb->query_result($result,$i,'operator').'</span>';
                $listview_entrie[]= '<span title="'.$adb->query_result($result,$i,'smscontent').'">'.$adb->query_result($result,$i,'smscontent').'</span>';
                $listview_entrie[]= '<span title="'.$adb->query_result($result,$i,'smsresultname').'">'.$adb->query_result($result,$i,'smsresultname').'</span>';
                $listview_entries[] = $listview_entrie;
            }
        }
		$navigationOutput = Array();$url_qry = '';
        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
		$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
		$navigationOutput[] =  getRecordRangeMessage($result, $limstart,$noofrows);
		$navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry,$currentModule,'CommunicationLog',$id);
        //print_r($listview_entries);
        $return_value = array('header'=>$header,'entries'=>$listview_entries,'navigation'=>$navigationOutput,'noofrows'=>$noofrows);
		return $return_value;
	}
    	//审批成功操作
	public function successApprove($record)
	{
	//	$this->updateCashBillStatus($record);
        global $adb;
        $sql='select salesbackstatus from ld_salesback  where salesbackid=?';
        $result=$adb->pquery($sql,array($record));
        $salesbackstatus=$adb->query_result($result,0,0);
//       if($salesbackstatus!='已入库')
//       {
        //已入库，不能再调用该函数，否则合同订单已出库数量和未出库数量计算错误
            $this->operationwarehouse($record,'instock');
            
//        }
	}
    ////反审批操作
    public function rejectApproved($record)
    {
        //	$this->upadteBackCashBillStatus($record);
        $this->operationwarehouse($record,'outstock');
        
    }
    
    function operationwarehouse($record,$type)
    {
        global $current_user,$adb;
         if($type=='instock')
        {
            $salesbackstatus = SALESBACKINSTOCK;
            $typename = '退货入库';
        }
        else
        {
            $salesbackstatus = SALESBACKOUTSTOCK;
            $typename = '撤销退货';
        }
    	$deployarray=getSys_deploy(85);//未出库订单是否允许退货 1：是，0：否
        $deployvalue = $deployarray['deploy_value'];
    	$sql = "select productid,quantity,parent_lineitem_id,entitytypeid,lineitem_id,batchtext from ld_salesback 
    		inner join ld_salesbackdetail on id=salesbackid where salesbackid = ?";
    	$results=$adb->pquery($sql,array($record));
    	$num_rows=$adb->num_rows($results);
        
    	if($type=='instock' && $deployvalue ==1){
    		//判断产品的数量是否大于该产品的已出库数量
    		//回撤时不需要判断产品数量是否大于该产品的已出库数量
    		
    		for ($i = 0; $i < $num_rows; $i++)
    		{ 
    			$entitytypeid = $adb->query_result($results,$i,'entitytypeid');
    			$parent_lineitem_id = $adb->query_result($results,$i,'parent_lineitem_id');
    			if(!empty($entitytypeid)){
    				$query = 'select sum(ifnull(quantity,0)) as quantity from ld_outboundorderdetail INNER JOIN ld_outboundorder on ld_outboundorder.out_id = ld_outboundorderdetail.id 
    					where entitytypeid = ? and parent_lineitem_id = ?';
    				$result = $adb->pquery($query,array($entitytypeid,$parent_lineitem_id));
    				$isOutnum = $adb->query_result($result,0,0);
    
      
    				$query = 'select sum(ifnull(quantity,0)) as quantity from ld_salesbackdetail 
    							INNER JOIN ld_salesback on ld_salesback.salesbackid = ld_salesbackdetail.id 
    							where entitytypeid = ? and parent_lineitem_id = ? and ld_salesback.salesbackstatus = \'已入库\';';
    				$result = $adb->pquery($query,array($entitytypeid,$parent_lineitem_id));
    				$isbacknum = $adb->query_result($result,0,0);
    				if($isbacknum >= $isOutnum){
    				//	echo "###ERROR###2";
                    $sql='update ld_salesback set salesbackstatus=? where salesbackid=?';
                    $adb->pquery($sql,array(SALESBACKOUTSTOCK,$record));
    				//	exit();
                 //   return ;
    				}
    
    			}
    		}
      }
    
    //更改销售退货单的状态
	$update_query = "update ld_salesback set salesbackstatus= ? where salesbackid=?";
 
    $adb->pquery($update_query, array($salesbackstatus,$record));
    crm_load_function_file("insertCondtion",'include/Stock','CommonStock');
    for ($i = 0; $i < $num_rows; $i++) { 
        $productid = $adb->query_result($results,$i,'productid');
       
        $qty = $adb->query_result($results,$i,'quantity');
        $entitytypeid = $adb->query_result($results,$i,'entitytypeid');
        $parent_lineitem_id = $adb->query_result($results,$i,'parent_lineitem_id');
        //$wareid = $adb->query_result($results,$i,'wareid');
		$lineitem_id = $adb->query_result($results,$i,'lineitem_id');
        $batchtext=$adb->query_result($results,$i,'batchtext');
        insertCondtion($batchtext, $record,$typename,$wareid,$productid,$currentModule,$current_user->id,0,0,$parent_lineitem_id,$lineitem_id);
        
        
    }

    //反写合同订单已入库和未入库数量
	crm_load_class_file("cls_Source_InverseCompute","include/OptionModule");
    cls_Source_InverseCompute::Source_InveverseCompute("SalesBack",$record);
 }

    public function restore($module, $id) {
        parent::restore($module,$id);

        //回收站还原单据时触发反写重新计算
        //反写合同订单已入库和未入库数量
        crm_load_class_file("cls_Source_InverseCompute","include/OptionModule");
        cls_Source_InverseCompute::Source_InveverseCompute("SalesBack",$id);

    }
    
}
SalesBack::require_file();
?>