<?php
class Expense extends CRMEntity{
    var $table_name = "ld_expense";
	var $table_index= 'expenseid';//主表主键
    var $table_code='expense_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_expense','ld_expensescf');
    //定义各个表主键
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_expense'=>'expenseid','ld_expensescf'=>'expenseid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_expensescf', 'expenseid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";
	var $Detail_table="ld_expensedetail";//明细表名称
	var $Detail_table_id="expensedetailid";//明细表id
	var $Detail_table_scf = "ld_expensedetailscf";//明细scf表
    var $Detail_table_index="expenseid";//明细表和主表关联的字段
    
	var $column_fields = Array();
	var $module_name='Expense';
 //和主表关联的模块
    var $relatedtab=array('salesorder'=>'','users'=>'','accounts'=>'','company'=>'','expense'=>'','potentials'=>'');
	var $sortby_fields = Array('expense_no','smownerid');
    
	
	var $list_link_field= 'expense_no';

	var $search_fields = Array(
			'Expense No'=>array('ld_expense'=>'expense_no'),
            'expensedate'=>array('ld_expense'=>'expensedate'),
            'numcount'=>array('ld_expense'=>'numcount'),
			'Assigned To'=>Array('ld_crmentity'=>'smownerid'),
			);

	var $search_fields_name = Array(
			'Account Name'=>'accountname',
		
			'Assigned To'=>'assigned_user_id',
			);
	// This is the list of lingdang_fields that are required
	var $required_fields =  array();

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
    //比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'accountname');

	//Default Fields for Email Templates -- Pavani
//	var $emailTemplate_defaultFields = array('accountname','account_type','industry','annualrevenue','phone','email1','rating','website','fax');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'expense_no';
	var $default_sort_order = 'ASC';

	// For Alphabetical search
    //拼音查询字段
	var $def_basicsearch_col = 'expense_no';
    var $popup_fields=Array();
    function __construct() {
		//$this->log =LoggerManager::getLogger('Expense');
		$this->db = PearDatabase::getInstance();
		 $this->fieldobj=Field::getInstance('Expense',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        crm_load_class_file('TabDetailFields','include/TabDetailFields');
       $this->detailfieldobj=TabDetailFields::getInstance($this->module_name);
             /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('Expense');
        $this->list_link_field=$entityname['fieldname'];
        $this->popup_fields=Array($this->list_link_field);
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
    				$query2payment = "update ld_expensedetail set Money = Money*? where expenseid = ?";
    				$adb->pquery($query2payment,array($conversion_rate,$this->id));
    			}
    			else
    			{
    				$query2payment = "update ld_expensedetail set Money = Money/?*? where expenseid = ?";
    				$adb->pquery($query2payment,array($becurrency_rate,$conversion_rate,$this->id));
    			}
         }
    }
    public function before_save($record)
    {
        global $adb;
        //检查发票状态是否有被使用
        crm_load_class_file('PiaozoneClass', 'modules/lingdang');
        $piaozoneObj = PiaozoneClass::getInstance($this->module_name);
        if ($piaozoneObj->isauthorize && isset($_REQUEST["pz_invoicedata"])) {//移动端没传值，目前是进不来的
            $pz_invoicedata_arr = json_decode($_REQUEST["pz_invoicedata"], true);
            if (is_array($pz_invoicedata_arr) && count($pz_invoicedata_arr)>0) {
                $selectserialno_arr = array_keys($pz_invoicedata_arr);//当前保存所选择的发票的集合

                if ($this->id>0) {//编辑
                    $used_sql = "select GROUP_CONCAT(serialno) from ld_piaozone where serialno in ('" . implode("', '", $selectserialno_arr) . "')"." and crmid <> ?";
                    $used_result=$adb->pquery($used_sql,array($this->id));

                }else{//新建
                    $used_sql = "select GROUP_CONCAT(serialno) from ld_piaozone where serialno in ('" . implode("', '", $selectserialno_arr) . "')";
                    $used_result=$adb->pquery($used_sql,array());

                }
                if ($adb->num_rows($used_result) > 0) {
                    $used_serialno = $adb->query_result($used_result,0,0);//已用发票的集合
                    $used_serialno_arr=[];
                    if(!empty($used_serialno_arr))
                         $used_serialno_arr = explode(',',$used_serialno);

                    $errortip = [];
                    foreach($pz_invoicedata_arr as $tmp_serialno=>$tmp_invoicedata){
                        $tmpinvoiceType = $tmp_invoicedata['invoiceType'];
                        if(in_array($tmp_serialno,$used_serialno_arr)){
                            if($tmpinvoiceType == '9'){//火车票
                                $tmptip = $tmp_invoicedata["printingSequenceNo"];
                            }elseif($tmpinvoiceType == '10'){//飞机票
                                $tmptip = $tmp_invoicedata["printNum"];
                            }else{
                                $tmptip = $tmp_invoicedata["invoiceNo"];
                            }
                            $errortip[] = "发票号码 ".$tmptip." 已用";
                        }
                    }
                    if (is_array($errortip)&&count($errortip)>0) {
                        ConvertTojsonString("-1", array(), implode('<br>',$errortip));

                    }
                }

            }


        }
    }
    function  save_module($module) 
    {
        global $weixin_user;
		$i=1;
		if($_REQUEST['action'] != 'ExpenseAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
		  
        }
        else
        {
            //查看界面的小编辑和批量修改
            return ;
        }
		//编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
		//	if($this->currency_status === true){
		 $currencyfieldinfo= $this->fieldobj->getFieldInfoobjBykey('columnname','currency_id');
			if(!$currencyfieldinfo)
			{
				global $adb;
				 $bankaccountsetfieldinfo= $this->fieldobj->getFieldInfoobjBykey('columnname','bankaccountsetid');
				 if($bankaccountsetfieldinfo)
				 {
						$bankaccountid=  $this->column_fields[$bankaccountsetfieldinfo->getFieldName()];
						$sql='select currency_id, conversion_rate,currency_symbol from ld_bankaccountset where bankaccountsetid=? ';
						$result=$adb->pquery($sql,array($bankaccountid));
						if($adb->num_rows($result)>0)
						{
							$this->column_fields['currency_id']=$adb->query_result($result,0,'currency_id');
							$this->column_fields['conversion_rate']=$adb->query_result($result,0,'conversion_rate');
							$this->column_fields['currency_symbol']=$adb->query_result($result,0,'currency_symbol');
						} 
				 }
			
		  }
        if($this->currency_status === true) {
            //币种隐藏，美元合同关联创建币种错误
            $update_query = "update ld_expense set currency_id=?, conversion_rate=?,currency_symbol=? where expenseid=?";
            $update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'], decode_html($this->column_fields['currency_symbol']), $this->id);
            $this->db->pquery($update_query, $update_params);
        }

		$expensetypeinfo=  $this->getExpenseTypeInfo();
		$tabid = getTabid($module);

        crm_load_class_file('cls_save_moduledetail','data');
        $obj=new cls_save_moduledetail($this->module_name,$this->id);
        $obj->Savedetail();


		$update_query = "update ld_expense set triggercount=triggercount+1 where expenseid=?";
		$update_params = array($this->id);
		$this->db->pquery($update_query, $update_params);
                
    }
    public function after_save()
    {
        global $adb;
        //检查发票状态是否有被使用
        crm_load_class_file('PiaozoneClass', 'modules/lingdang');
        $piaozoneObj = PiaozoneClass::getInstance($this->module_name);


        if ($piaozoneObj->isauthorize && isset($_REQUEST["pz_invoicedata"])) {
            $pz_invoicedata_arr = json_decode($_REQUEST["pz_invoicedata"], true);
            $pz_deleteserialno_arr = json_decode($_REQUEST["pz_deleteserialno_arr"], true);
            $pz_invoicetotal = $_REQUEST["pz_invoicetotal"];

            //1、已删除发票更改状态为“未用”,并删除发票表数据
            if (is_array($pz_deleteserialno_arr) && count($pz_deleteserialno_arr)>0) {
                if ($this->id>0) {//编辑  不用解绑再重绑，直接重绑就可以实现将删除的发票状态改为“未用”
                    /*$post_data = array();
                    $post_data['messageType'] = 'billDel';
                    $post_data['messageId'] = time();
                    $post_data['data'] = array(
                        "billId" => $this->id,
                        "resource" => $piaozoneObj->resource
                    );
                    $resp = $piaozoneObj->billDel($post_data);
                    if (isset($resp['errorCode']) && $resp['errorCode'] == '0000') {
                        $del_sql = "delete from ld_piaozone where serialno in ('" . implode("', '", $pz_deleteserialno_arr) . "')";
                        $adb->pquery($del_sql,array());
                    }else{
                        file_put_contents(globalStatic::$root_directory.'dataCache/Piaozone/'.date("Ym").'.txt',date("Y-m-d H:i:s")." billDel:request：".json_encode($post_data,JSON_UNESCAPED_UNICODE)."\r\n",FILE_APPEND);
                        file_put_contents(globalStatic::$root_directory.'dataCache/Piaozone/'.date("Ym").'.txt',date("Y-m-d H:i:s")." billDel:response：".json_encode($resp,JSON_UNESCAPED_UNICODE)."\r\n",FILE_APPEND);
                    }*/

                    $del_sql = "delete from ld_piaozone where serialno in ('" . implode("', '", $pz_deleteserialno_arr) . "')";
                    $adb->pquery($del_sql,array());

                }

            }

            //2、保存单据
            if (is_array($pz_invoicedata_arr) && count($pz_invoicedata_arr)>0) {
                $selectserialno_arr = array_keys($pz_invoicedata_arr);//当前保存所选择的发票的集合

                //需要绑定的发票流水号的集合
                $selectinvoiceData = array_map(function($item) {
                    return ["serialNo" => $item];
                }, $selectserialno_arr);

                if (empty($selectinvoiceData)) {
                    return;
                }
                $post_data = array();
                $post_data['messageType'] = 'billSave';
                $post_data['messageId'] = time();
                $post_data['data'] = array(
                    "billId" => $this->id,
                    "billNo" => $this->column_fields[$this->table_code],
                    "billType" => "er_dailyreimbursebill",
                    "resource" => $piaozoneObj->resource,
                    "status" => '60',//0 未用  60 已用
                    "invoiceData" => $selectinvoiceData,
                );
                $resp = $piaozoneObj->billSave($post_data); //TODO
                if (isset($resp['errorCode']) && $resp['errorCode'] == '0000') {
                   //发票状态为已用后，插入数据库(serialno唯一索引)
                    foreach ($pz_invoicedata_arr as $tmp_data) {
                        $tmpinvoiceType = $tmp_data['invoiceType'];
                        if($tmpinvoiceType == '9'){//火车票
                            $tmpinvoiceCode = $tmp_data['trainNum'];
                            $tmpinvoiceNo = $tmp_data['printingSequenceNo'];
                        }elseif($tmpinvoiceType == '10'){//飞机票
                            $tmpinvoiceCode = $tmp_data['airNum'];
                            $tmpinvoiceNo = $tmp_data['printNum'];
                        }else{
                            $tmpinvoiceCode = $tmp_data['invoiceCode'];
                            $tmpinvoiceNo = $tmp_data['invoiceNo'];
                        }
                         $sql='select 1 from ld_piaozone where serialno=?';
                        $result=$adb->pquery($sql,array($tmp_data['serialNo']));
                        if($adb->num_rows($result)>0)
                            continue;

                        $ins_sql = "insert into ld_piaozone(crmid,invoicetype,invoicetype_zh,invoicecode,invoiceno,invoicedate,totalamount,buyername,salername,serialno,downloadurl,snapshoturl,invoicedata)
                        select ?,?,?,?,?, ?,?,?,?,?, ?,?,? ";
                        $adb->pquery($ins_sql,array($this->id,$tmp_data['invoiceType'],$piaozoneObj->invoicetype_arr[$tmp_data['invoiceType']],$tmpinvoiceCode
                        ,$tmpinvoiceNo,$tmp_data['invoiceDate'],$tmp_data['totalAmount'],$tmp_data['buyerName'],$tmp_data['salerName'],$tmp_data['serialNo']
                        ,$tmp_data['downloadUrl'],$tmp_data['snapshotUrl'],json_encode($tmp_data) ));
                    }

                }else{
                    file_put_contents(globalStatic::$root_directory.'dataCache/Piaozone/'.date("Ym").'.txt',date("Y-m-d H:i:s")." billSave:request：".json_encode($post_data,JSON_UNESCAPED_UNICODE)."\r\n",FILE_APPEND);
                    file_put_contents(globalStatic::$root_directory.'dataCache/Piaozone/'.date("Ym").'.txt',date("Y-m-d H:i:s")." billSave:response：".json_encode($resp,JSON_UNESCAPED_UNICODE)."\r\n",FILE_APPEND);
                }

            }

            //3、反写主表发票合计字段
            if ($pz_invoicetotal > 0) {
                $up_sql = "update ".$this->table_name." set invoicetotal=? where ".$this->table_index." =?;";
                $adb->pquery($up_sql,array($pz_invoicetotal,$this->id));
            }


        }
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
        $usql = "UPDATE ld_bankaccountset
            
                INNER JOIN ld_expense on ld_bankaccountset.Bankaccountsetid=ld_expense.bankaccountsetid
                 SET curbalancemoney=IFNULL(curbalancemoney,0)-ld_expense.total
             WHERE ld_expense.expenseid in( $tmprecords )"; 
            $adb->pquery($usql,array());  
    }
    public function addBankMoney($records)
    {
        global $before_approveinfo;
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
        if($before_approveinfo['approvestatus']==constant('D_A_S_APPROVED'))
        {
             
            $usql = "UPDATE ld_bankaccountset
            
                INNER JOIN ld_expense on ld_bankaccountset.Bankaccountsetid=ld_expense.bankaccountsetid
                 SET curbalancemoney=IFNULL(curbalancemoney,0)+ld_expense.total
             WHERE ld_expense.expenseid in( $tmprecords )";
            $adb->pquery($usql,array());  
        }
       
       
    }
      /**
     * edit:can
     * reason:审批-》已批准
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
   	function unlinkRelationship($id, $return_module, $return_id)
    {
        /**
        *@author:andy
        *@data:
        *@reason:其他模块关联费用报销相关信息列表无法删除费用报销单据，这里删除有模块限制，‘ServiceContracts’
        *@version:|
        */
	   //if($return_module == 'ServiceContracts') {
			$this->trash('Expense',$id);
		//}
    }
	//联合技术MER特殊控制：获取费用类别
	function getExpenseTypeInfo(){
		//Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/12 0012 上午 11:57
		$objPickList = crm_load_class_obj("cls_PickList_Utrc",'modules/PickList',array());
		$data =$objPickList->getPickListValues_Utrc();
		return $data;
		/*旧代码001 global $adb;
		$query = 'select expensetype,utrc_type from ld_expensetype where presence = 1 order by picklist_valueid asc';
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		for($i = 0; $i<$num_rows; $i++){
			$expensetype = $adb->query_result($result,$i,'expensetype');
			$data[$expensetype] = $adb->query_result($result,$i,'utrc_type');
		}
		return $data;*/
	}
	function getExpenseTypeHtml($column,$rowid,$value = ''){
		global $adb;
		$ExpenseTypeInfo = $this->getExpenseTypeInfo();
		$columnname = $column . $rowid;
		$htmlTd .='<select style="width:95%;" id="'.$columnname.'" name="'.$columnname.'" onchange="getDetailExpenseType(\''.$column.'\',\''.$rowid.'\')">';
		$htmlTd .='<option value=""></option>';
		foreach($ExpenseTypeInfo as $expensetype => $utrc_type){
			$selected = '';
			if(!empty($value)){
				if($value == $expensetype){
					$selected = 'selected="true"';
				}
			}
			$htmlTd .='<option value="'.$expensetype.'" '.$selected.' tag="'.$utrc_type.'">'.$expensetype.'</option>';
		}
		$htmlTd .='</select>';
		return $htmlTd;
	}
	//联合技术MER特殊控制：获取明细第一行数据费用类别的utrc_type
	function getExpenseDetailRowUtrcType($recordid){
		//Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/12 0012 上午 11:57
		$objPickList = crm_load_class_obj("cls_PickList_Utrc",'modules/PickList',array());
		$utrc_type =$objPickList->getExpenseDetailRowUtrcType($recordid);
		return $utrc_type;
		/*global $adb;
		if(!empty($recordid)){
			$query = 'select ld_expensetype.utrc_type from ld_expensedetail 
			LEFT JOIN ld_expense on ld_expense.expenseid = ld_expensedetail.expenseid
			LEFT JOIN ld_expensetype on ld_expensetype.expensetype = ld_expensedetail.expensetype where ld_expense.expenseid = ? limit 1';
			$result = $adb->pquery($query,array($recordid));
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 0){
				return $adb->query_result($result,0,0);
			}
		}else{
			crm_load_class_file("TabDetailFields",'include/TabDetailFields');
			$tabid = getTabid('Expense');
			$TabDetailFields = new TabDetailFields($tabid);
			$tabPresenceDetailFields = $TabDetailFields->getTabPresenceDetailFields();
			$expensetype =  $tabPresenceDetailFields['expensetype'];
			if(!empty($expensetype)){
				$defaultvalue = $expensetype->getDefaultvalue();
				if(!empty($defaultvalue)){
					$query = 'select ld_expensetype.utrc_type from ld_expensetype where expensetype = ? limit 1';
					$result = $adb->pquery($query,array($defaultvalue));
					$num_rows = $adb->num_rows($result);
					if($num_rows >= 0){
						return $adb->query_result($result,0,0);
					}
				}
			}

		}*/
	}
    function getSourceField($fieldname,$recordid)
    {
        global $adb;
        $sql = "select entitytype,salesorderid from ld_expense where expenseid = ?";
        $result = $adb->pquery($sql,array($recordid));
        $sourceModuleInfo['module']= $adb->query_result($result,0,'entitytype');
        $sourceModuleInfo['sourceid']= $adb->query_result($result,0,'salesorderid');
        return $sourceModuleInfo;
    }
    
}
?>