<?php


// Account is used to store ld_account information.
class Quotes extends CRMEntity {
    static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['Quotes']='Quotes';
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $Detail_table="ld_quotesdetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_quotesdetailscf";//明细scf表
     var $Detail_table_index="id";//明细表和主表关联的字段
	var $log;
	var $db;
    var $module_name='Quotes';
	var $table_name = "ld_quotes";
	var $table_index= 'quoteid';
    var $table_code='quote_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_quotes','ld_quotescf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_quotes'=>'quoteid','ld_quotescf'=>'quoteid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_quotescf', 'quoteid');
	var $entity_table = "ld_crmentity";

	var $billadr_table = "ld_quotesbillads";
   //打印管理模块
    var $relatedtab=array('quotes'=>'','users'=>'','potential'=>'','contacts'=>'','accounts'=>'','products'=>'','company'=>'');
    
	var $object_name = "Quotes";

	var $new_schema = true;

	var $column_fields = Array();

	var $sortby_fields = Array('subject','crmid','smownerid','accountname','lastname');

	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );

  
	var $list_link_field= 'subject';

	
	// This is the list of ld_fields that are required.
	var $required_fields =  array("accountname"=>1);

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'quoteid';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_quotegrouprelation','quoteid');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'subject';
 
	/**	Constructor which will set the column_fields in this object
	 */
	function __construct() {
		//$this->log =LoggerManager::getLogger('quote');
		$this->db = PearDatabase::getInstance();
         /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('Quotes',$this);
        $this->list_link_field=$entityname['fieldname'];
		 $this->fieldobj=Field::getInstance('Quotes',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
        
	}

	function save_module()
	{
		global $adb;
        global $currentModule;
		//in ajax save we should not call this function, because this will delete all the existing product values
		if($_REQUEST['action'] != 'QuotesAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
		    crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
			
            saveInventoryProductDetails($this, 'Quotes');
		}
      //编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
		if($this->currency_status == true)
		{
			$update_query = "update ld_quotes set currency_id=?, conversion_rate=?,currency_symbol=? where quoteid=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}
		//更新客户的最新报价日期
		if($this->mode != 'edit'){
			$this->updateAccountsLastQuotesDate($this->column_fields['account_id']);
		}   
        
        /*
        *更新操作
        *edit:diony
        *time:2014-1-01-06
        *reson:附件目录，保存报价单时，判断是否引用了销售机会
        如果引用再判断引用的销售机会是否有附件
        如果包含附件，那么将该附件保存到对应的报价单附件目录中
        */
        //判断是否引用销售机会
        
        if($this->column_fields['potential_id']!='')
        {
            //判断销售机会是否有附件
            $potentialid = $this->column_fields['potential_id'];
            $sql = "select * from ld_attachmentsforbills where record =? ";
            $result = $adb->pquery($sql,array($potentialid));
            if($adb->num_rows($result))
            {
                $quotesid = $this->id;
                $potentialsPath = 'storage/Potentials/'.$potentialid.'/';
                $quotesPath = 'storage/Quotes/'.$quotesid.'/';
                //如果存在文件夹，将该文件夹复制到对应的额报价单附件文件夹下
                if(is_dir($potentialsPath))
                {
                    //判断报价单附件目录是否存在，不存在的话创建附件
                    if (!is_dir('storage/Quotes/')) 
                    {
                		mkdir('storage/Quotes/');
                    }
                    if (!is_dir($quotesPath)) 
                    {
                		mkdir($quotesPath);
                    }
                    //判断在报价单附件中创建销售机会的附件文件夹
                    if (!is_dir($quotesPath.'Potentials/')) 
                    {
                		mkdir($quotesPath.'Potentials/');
                    }
                    crm_load_class_file('FileUtil','include/upload');
                    $fu = new FileUtil();
                    $fu->copyDir($potentialsPath, $quotesPath.'Potentials/');                    
                }
            }
        }
        
        //放在函数的最下面，等待主表更新total字段更新完成
        $VersionInfo = getVersionInfo();
        
        if($VersionInfo['account'] == 'haige')
        {
            
            /*if($this->mode == 'create' &&$_REQUEST['duplicateid']<=0)
            {
                //判断特价单号是否创建过报价单，如果创建过，那他就是复制的
                $sql = "select max(quote_version+0) as quote_version,quoteid from ld_quotes where deleted=0 and potentialid=?;";
                $result=$adb->pquery($sql,array($this->column_fields['potential_id']));
                if($adb->num_rows($result)>0)
                {
                    $tmpquote_version = $adb->query_result($result,0,'quote_version');
                    if($tmpquote_version>1){
                        $duplicateid = $adb->query_result($result,0,'quoteid');
                        $_REQUEST['duplicateid'] = $duplicateid;
                    }
                }
            }*/
            if($_REQUEST['duplicateid']>0)
            {
                
            
                 $sql='select quote_version from ld_quotes where quoteid=?';
                $result=$adb->pquery($sql,array($_REQUEST['duplicateid']));
               
                $quote_version=$adb->query_result($result,0,'quote_version');
                $sql='update ld_quotes set copyid=?,quote_version=? where quoteid=?';
               
                $adb->pquery($sql,array($_REQUEST['duplicateid'],($quote_version+1).".0",$this->id));
                //39055: 海格->报价单复制：如果报价单有“已下单数量”，复制的时候逻辑控制错误
                /*$sql='
                update ld_quotesdetail 
                inner join (select sum(ifnull(haveordercount,0)) as sumhaveordercount,productid  from ld_quotesdetail 
                inner join ld_quotes on ld_quotes.quoteid=ld_quotesdetail.id  where ld_quotes.deleted=0 and ld_quotes.potentialid=?
                group by ld_quotes.potentialid,ld_quotesdetail.productid)
                as tmpparent on tmpparent.productid=ld_quotesdetail.productid
                set ld_quotesdetail.haveordercount=tmpparent.sumhaveordercount,
                balanceordercount=quantity-ld_quotesdetail.haveordercount
                where ld_quotesdetail.id=? ';
                if($this->mode!='edit')
                    $adb->pquery($sql,array($_REQUEST['potential_id'],$this->id));*/
                    
            }
            else if( $this->mode == 'edit'){
                $sql='select copyid,potentialid from ld_quotes where quoteid=?';
                $result=$adb->pquery($sql,array($this->id));
                $_REQUEST['duplicateid']=$adb->query_result($result,0,'copyid');
                $_REQUEST['potential_id']=$adb->query_result($result,0,'potentialid');
                
            
            }
            //海格设置取价日期
            $sql = 'select price_date,createdtime,quote_version from ld_quotes where quoteid=?';
            $result=$adb->pquery($sql,array($this->id));
            $rows = $adb->num_rows($result);
            if($rows>=0){
                $price_date = $adb->query_result($result,0,'price_date');
                $createtime = $adb->query_result($result,0,'createdtime');
                $version = $adb->query_result($result,0,'quote_version');
                if(empty($price_date)){
                    //1.0版本取取价日期，大于1.0取前一版本取价日期
                    if($version=='1.0'){
                        $price_date = $createtime;
                    }
                    else{
                        $sql = 'select price_date from ld_quotes where quoteid=?';
                        $result = $adb->pquery($sql,array($_REQUEST['duplicateid']));
                        $price_date = $adb->query_result($result,0,'price_date');
                    }
                    $adb->pquery('update ld_quotes set price_date = ? where quoteid = ?',array($price_date,$this->id));
                }
            }
           
            crm_load_class_file("cls_HaigeConst",'modules/Quotes');
            crm_load_class_file("cls_HaigeApproveJudge",'modules/Quotes');
            $HaigeApproveObj=new cls_HaigeApproveJudge($_REQUEST['potential_id'],$_REQUEST['quotetype'],$_REQUEST['total']);
            $HaigeApproveObj->setRecord($this->id);
            
            if($HaigeApproveObj->isChange()=='yes')
            {
                 $sql='update ld_quotes set isclose=?,allowcopy=? where quoteid=?';
                 $adb->pquery($sql,array('yes','no',$_REQUEST['duplicateid']));//被复制的单据关闭和不允许复制
				 $sql='update ld_quotes set quick_approval=? where quoteid=?';
                 $adb->pquery($sql,array('yes',$this->id));
                 $_SESSION[$currentModule."haigesavetip"]='本次变更需要走快速审批流程';
            }
           
            else //目前只有海格
            {
                $sql='update ld_quotes set isclose=?,allowcopy=? where quoteid=?';
                $adb->pquery($sql,array('yes','no',$_REQUEST['duplicateid']));//被复制的单据关闭和不允许复制
                $sql='update ld_quotes set quick_approval=? where quoteid=?';
                $adb->pquery($sql,array('no',$this->id));
                $_SESSION[$currentModule."haigesavetip"]='本次变更程需要走完整审批流程';
            }
            
        } 
		
		$sql='UPDATE ld_quotes SET triggercount=triggercount+1 WHERE quoteid=?';
		$adb->pquery($sql,array($this->id));
		 
        //else  
        //{
              crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
       
             cls_Source_InverseCompute::Source_InveverseCompute("Quotes",$this->id,$this);
        //}
	}

	//还原单据
	public function restore($module, $id)
    {
        global $adb;
        parent::restore($module,$id);
        $this->massDelete_after($module, array($id));
    }

	//批量删除后，执行的操作
	public function massDelete_after($returnmodule,$ids){
		global $adb;
		if(sizeOf($ids)>= 1){
			$query = 'select accountid,copyid from ld_quotes where quoteid in ('.implode(',',$ids).')';
			$result = $adb->pquery($query,array());
			$num_rows = $adb->num_rows($result);
                $copyids=array();
			if($num_rows > 0){
				for($i = 0; $i<$num_rows; $i++){
				    if($adb->query_result($result,$i,'copyid')>0)
				          $copyids[]=$adb->query_result($result,$i,'copyid');
					$arr[] = $adb->query_result($result,$i,'accountid');
				}
			}
			$accountid_arr = array_unique($arr);
			foreach($accountid_arr as $accountid){
				$this->updateAccountsLastQuotesDate($accountid);
			}
            $VersionInfo = getVersionInfo();
        
            if($VersionInfo['account'] == 'haige')
            { 
                $strcopyid=trim(trim(implode(",",$copyids),','),'');
                if(!empty($strcopyid))
                {
                    $sql='update ld_quotes set isclose=?,allowcopy=? where quoteid in('.$strcopyid.')';
                    $adb->pquery($sql,array('no','yes'));
                }
            }
            
		}
	}
	   
	//更新客户的最新报价日期
	public function updateAccountsLastQuotesDate($accountid){
		global $adb;
		if(!empty($accountid)){
			$query = 'select createdtime from ld_quotes where accountid = ? and deleted = 0 ORDER BY createdtime desc limit 1';
			$result = $adb->pquery($query,array($accountid));
			$createdtime = '';
			if($adb->num_rows($result) >= 1){
				$createdtime = $adb->query_result($result,0,0);
			}
			$adb->pquery('update ld_account set lastquotedate=? where accountid=?',array($createdtime,$accountid));
		}
	}

    public function addComboxIntoDataBase($table_name='')
    { 
		global $adb;
                if(!array_key_exists("quotestage",$this->column_fields))
                {
                    return ;
                }
				$history_field_array = Array(
				
					"Quotes" => "quotestage"
				
				);

				$inventory_module = "Quotes";
   
				if ($_REQUEST['ajxaction'] == 'DETAILVIEW') {//if we use ajax edit
				
						$relatedname = getModuleHref('Accounts',$this->column_fields['account_id']);

					    $total = $this->column_fields['hdnGrandTotal'];
				}
				else {//using edit button and save
				
						$relatedname = $_REQUEST["account_name"];

					$total = $_REQUEST['total'];
				}

				if ($this->column_fields["$history_field_array[$inventory_module]"] == $app_strings['LBL_NOT_ACCESSIBLE']) {

					//If the value in the request is Not Accessible for a picklist, the existing value will be replaced instead of Not Accessible value.
					$his_col = $history_field_array[$inventory_module];
					$his_sql = "select $his_col from  $this->table_name where " . $this->table_index . "=?";
					$his_res = $adb->pquery($his_sql, array($this->id));
					$status_value = $adb->query_result($his_res, 0, $his_col);
					$stat_value = $status_value;
				} else {
					$stat_value = $this->column_fields["$history_field_array[$inventory_module]"];
				}
				$oldvalue = getSingleFieldValue($this->table_name, $history_field_array[$inventory_module], $this->table_index, $this->id);
				if ($this->column_fields["$history_field_array[$inventory_module]"] != '' && $oldvalue != $stat_value) {
					crm_load_function_file('addInventoryHistory','include/utils','InventoryUtils');
					addInventoryHistory($inventory_module, $this->id, $relatedname, $total, $stat_value);
				}
    }

	// Function to get column name - Overriding function of base class
	function get_column_value($columname, $fldvalue, $fieldname, $uitype, $datatype='') {
		if ($columname == 'potentialid' || $columname == 'contactid') {
			if ($fldvalue == '') return null;
		}
		return parent::get_column_value($columname, $fldvalue, $fieldname, $uitype, $datatype);
	}



	/*
	 * Function to get the relation tables for related modules
	 * @param - $secmodule secondary module name
	 * returns the array with table names and fieldnames storing relations between module and this module
	 */
	function setRelationTables($secmodule){
		$rel_tables = array (
			"SalesOrder" =>array("ld_salesorder"=>array("quoteid","salesorderid"),"ld_quotes"=>"quoteid"),
			"Calendar" =>array("ld_seactivityrel"=>array("crmid","activityid"),"ld_quotes"=>"quoteid"),
			"Documents" => array("ld_senotesrel"=>array("crmid","notesid"),"ld_quotes"=>"quoteid"),
			"Accounts" => array("ld_quotes"=>array("quoteid","accountid")),
			"Contacts" => array("ld_quotes"=>array("quoteid","contactid")),
			"Potentials" => array("ld_quotes"=>array("quoteid","potentialid")),
		);
		return $rel_tables[$secmodule];
	}

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Accounts' ) {
			$this->trash('Quotes',$id);
		} elseif($return_module == 'Potentials') {
			$relation_query = 'UPDATE ld_quotes SET potentialid=? WHERE quoteid=?';
			$this->db->pquery($relation_query, array(null, $id));
		} elseif($return_module == 'Contacts') {
			$relation_query = 'UPDATE ld_quotes SET contactid=? WHERE quoteid=?';
			$this->db->pquery($relation_query, array(null, $id));
		} else {
			$sql = 'DELETE FROM ld_crmentityrel WHERE (crmid=? AND relmodule=? AND relcrmid=?) OR (relcrmid=? AND module=? AND crmid=?)';
			$params = array($id, $return_module, $return_id, $id, $return_module, $return_id);
			$this->db->pquery($sql, $params);
		}
	}
    
    
     public function successApprove($record)
     {
        global  $adb,$current_user;
           $VersionInfo = getVersionInfo();	
           //海格报价单审批通过时，若有多个送货地址或较前一版本有送货地址增加，
           //   则创建送货地址确认单并提交审批同时将报价单状态改为不可用
           if($VersionInfo['account']=='haige')
           {
                $haigeresult = $adb->pquery('select approvestatus from '.$this->table_name. ' where '.$this->table_index.' = ?',array($record));
                $approvestatus = $adb->query_result($haigeresult,0,'approvestatus');
                if($VersionInfo['account']=='haige' && $approvestatus==constant('D_A_S_APPROVED'))
                {
                    
                    //根据送货地址信息判断是否需要创建送货地址确认单
                    crm_load_function_file('isMultipleAddressByid','modules/Quotes','Haigequotefunction');
                    if(isMultipleAddressByid($record))
                    {
                        //修改报价单使用状态为不可用，创建地址变更单并提交审批
                        
                        $adb->pquery("update ld_quotes set available_status = '不可用' where quoteid = $record");
                        
                        
                        $haigesql = "select smownerid,smcreatorid,quote_version,cf_3023,cf_3024,cf_3025,cf_3026,cf_3027,cf_2918 from ld_quotes 
                                    left join ld_quotescf on ld_quotes.quoteid=ld_quotescf.quoteid where ld_quotes.quoteid = $record";
                        $haigeresult = $adb->pquery($haigesql,array());
                        $haige_smownerid = $adb->query_result($haigeresult,0,'smownerid');
                        $haige_smcreatorid = $haige_smownerid;//地址变更单创建人取报价单负责人
                        $haige_quote_version = $adb->query_result($haigeresult,0,'quote_version');
                        $haige_address1 = $adb->query_result($haigeresult,0,'cf_3023');
                        $haige_address2 = $adb->query_result($haigeresult,0,'cf_3024');
                        $haige_address3 = $adb->query_result($haigeresult,0,'cf_3025');
                        $haige_address4 = $adb->query_result($haigeresult,0,'cf_3026');
                        $haige_address5 = $adb->query_result($haigeresult,0,'cf_3027');
                        $haige_xm_name = $adb->query_result($haigeresult,0,'cf_2918');
                        $haige_modifiedby = $haige_smownerid;
                        $haige_approvesubmitby = $haige_smownerid;
                        
                        $customform48focus = CRMEntity::getInstance('CustomForm48');
                        $haige_customform48_no = $customform48focus->Library('SystemCode')->getModuleSeqNumRecord('CustomForm48');
                        $customform48focus->Library('SystemCode')->setModuleSeqNumber("increment", 'CustomForm48');
                        
                        $approve = new Approve();
                        $approveinfo = $approve->getAllApprovesByUserid(getTabid('CustomForm48'),$haige_smcreatorid);
                        $haige_customform48id=$adb->getUniqueID('ld_crmentity');
                        $nextStepInfo_arr = $approve->getApproveStepInfo($approveinfo[0]['approveid'], $haige_customform48id);
                        $haige_approveid = $approveinfo[0]['approveid'];
                        $haige_nextstepid = $nextStepInfo_arr[0]['stepid'];
                        $haige_nextstepapproveby = $nextStepInfo_arr[0]['stepuserids'];
                        $haige_countersigner = $nextStepInfo_arr[0]['countersigner'];
                        
                        
                        $sql='insert into ld_crmentity(crmid,setype)value(?,?)';
                        $adb->pquery($sql,array($haige_customform48id,'CustomForm48'));
                       
                        $haige_custom48query = "insert into ld_customform48(customform48id,customform48_no,smownerid,smcreatorid,createdtime,modifiedby,modifiedtime,approvestatus,approvetime,approveby,currentapprover,approvesubmitter,approvesubmittedtime,currentapprovestepid,quoteid,quote_version,shipping_address1,shipping_address2,shipping_address3,shipping_address4,shipping_address5,xm_name)
                                                             value(?,?,?,?,now(),?,now(),?,now(),0,?,?,now(),-1,?,?,?,?,?,?,?,?)";
                        $adb->pquery($haige_custom48query,array($haige_customform48id,$haige_customform48_no,$haige_smownerid,$haige_smcreatorid,$haige_modifiedby,'审批中',$haige_nextstepapproveby,$haige_approvesubmitby,$record,$haige_quote_version,$haige_address1,$haige_address2,$haige_address3,$haige_address4,$haige_address5,$haige_xm_name));
                        
                        
                        $sql='insert into ld_customform48scf(customform48id)value(?)';
                        $adb->pquery($sql,array($haige_customform48id));
                        
                        
                        
                        //获取$nextstep_countersigner
                        $query = 'select id,sequence,approvetype,approvevalue,countersigner,concurrentid from ld_approvestep 
                						where approveid=? and id= ?;';
                		$result = $adb->pquery($query,array($haige_approveid,$haige_nextstepid));  
                        $nextstep_countersigner=$adb->query_result($result,0,'countersigner');
                        
                        $approvelogid = $adb->getUniqueID('ld_approvelog');
                        $haige_custom48approvequery = 'insert into ld_approvelog(id,crmid,description,approveid,stepid,approved_by,
                          	     approveresult,createdtime,seqtime,nextstepid,nextstepapproveby,countersigner,nextstep_countersigner,approve_autograph,approve_autograph_path,stepseq,urgent) ';
                        $haige_custom48approvequery .= 'value(?,?,?,?,?,?,?,now(),current_timestamp(6),?,?,?,?,?,?,0,?)';
                        $adb->pquery($haige_custom48approvequery,array($approvelogid,$haige_customform48id,'',$haige_approveid,-1,$haige_approvesubmitby,1,$haige_nextstepid,$haige_nextstepapproveby,$haige_countersigner,
                                    $nextstep_countersigner,'no','','no'));
                    }
                    
                    $sql = 'select quotetype,quotestage from ld_quotes where quoteid = ? and deleted = 0';
                    $result = $adb->pquery($sql,array($record));
                    $num_rows = $adb->num_rows($result);
                    if($num_rows>0){
                        crm_load_class_file("cls_HaigeConst",'modules/Quotes');
                        //$quotetype = $adb->query_result($result,0,'quotetype');
                        $quotestage = $adb->query_result($result,0,'quotestage');
                        //状态为最终优化清单的报价单审批后通过邮件向供应商发送产品数量清单
                        if($quotestage==cls_HaigeConst::$QuoteStage_Qingdang){
                            crm_load_function_file('HaigeSendProductlist','modules/Quotes','Haigequotefunction');
                            HaigeSendProductlist($this->module_name,$record);
                        }                
                    }
                }
           }
     }
}
Quotes::require_file();
?>